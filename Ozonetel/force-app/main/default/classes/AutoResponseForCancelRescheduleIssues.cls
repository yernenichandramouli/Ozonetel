/**
 * (c) 2019 RedBus
 *
 * Name           : AutoResponseForCancelRescheduleIssues 
 * Created Date   : 02 April 2019
 * Created By     : Sreenivas M
 * Purpose        : Batch class to process the cancellation/reschdeule issues to auto update the case
 * Test class     : AutoResponseForCancelRescheduleIssuesTest
 *
 **/
 
global class AutoResponseForCancelRescheduleIssues implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts
{  
    global final String query;
    list<Case> listCasesToUpdate = new List<Case>();
    List<CaseComment> listCommToInsert = new List<CaseComment>();
    transient List<Messaging.SingleEmailMessage> listEMail;
    String partCancelSTC = System.Label.PartialCanNotAllowedSTC;
    String CancelSTC = System.Label.CancellationNotAllowedSTC;
   
    
    public AutoResponseForCancelRescheduleIssues(){
     listEMail = new List<Messaging.SingleEmailMessage>();
    }
    
    public AutoResponseForCancelRescheduleIssues(String q)
    {
         
        listEMail = new List<Messaging.SingleEmailMessage>();
        
        if(String.isNotBlank(q))
           query = q;
        else
           query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CancelorRescheduleForComplaintTracker'].QueryDetails__c;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug('query-->>'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext scon)
    {
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CancelorRescheduleForComplaintTracker'].Duration__c;
        System.schedule('AutoResponseForCancellationIssues - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new AutoResponseForCancelRescheduleIssues(query),40);
    }
    
    global void execute(Database.BatchableContext BC, list<Case> CaseList)
    {  
      system.debug('----start---');
        listCasesToUpdate.clear();
        listCommToInsert.clear();
        listEMail = new List<Messaging.SingleEmailMessage>();
        Set<String> cancelCodes = new Set<String>(System.Label.AutoCancelCodes.Split(','));

        Set<String> setSubIssues = new Set<String>{'I am not able to cancel my ticket','I am not able to cancel my ticket partially'};
        Id orgEmailId = [select id, Address, DisplayName from OrgWideEmailAddress where Address ='noreply_feedback@redbus.in' limit 1].id;
        for(Case cs : CaseList)
        {
           cs.Is_ML_Processed__c = true;
           if(String.isNotBlank(cs.issue_type__c) && String.isNotBlank(cs.Issue_Sub_Category__c) && 'Ticket Cancellation'.equalsIgnoreCase(cs.issue_type__c) && (setSubIssues.contains(cs.Issue_Sub_Category__c)) && string.isNotBlank(cs.Booking_Email_ID__c) && string.isNotBlank(cs.TIN_No__c))
           {
              system.debug('----if entered---');
              string jsonBody='{"email":"'+cs.Booking_Email_ID__c+'","tin":"'+cs.TIN_No__c+'"}';
              Http http = new Http();
              HttpResponse res = new HttpResponse();
              HttpRequest req = new HttpRequest();
              req = HttpRequestUtil.populateCAPIHeaders(req);
              req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IsTicketCancellableURLV2'].Endpoint__c);
              req.setMethod('POST');
              req.setBody(jsonBody);
              system.debug('RequestValue-->>'+req.getbody());
              res = http.send(req);                      
              string responseValue = res.getBody();
              system.debug('responseValue-->>'+responseValue+''+res.getbody());
              if(string.isNotBlank(string.valueof(responseValue)))
              {
                
                  map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                  string msg = IsCan.KeySet().contains('message')?String.valueof(IsCan.get('message')):IsCan.KeySet().contains('Message')?String.valueof(IsCan.get('Message')):'';
                  Boolean isCancellable =  IsCan.KeySet().contains('isTicketCancellable')?boolean.valueof(IsCan.get('isTicketCancellable')):false;
                  Boolean isPartialCanellationAllowed =  IsCan.KeySet().contains('isPartialCancellation')?boolean.valueof(IsCan.get('isPartialCancellation')):false;
                  string tcpOpted=string.valueOf(IsCan.get('tcpPromotionalText'));
                  //IsCan.KeySet().contains('tcpPromotionalText')
                  if(string.isBlank(tcpOpted)){
                  //Cancellation Window Expired Can not be Canceled
                  if(!isCancellable && String.isNotBlank(msg) && ('This ticket cannot be cancelled'.equalsIgnoreCase(msg) || 'Cancellation Failed'.equalsIgnoreCase(msg)) && cancelCodes.contains(String.valueof(IsCan.get('Code'))))
                     prepareEmailBody(cs,'Cancellation_Policy_Expired',orgEmailId,CancelSTC);
                 
                  //Cancellation window is not expired but partial cancellation is not allowed
                  else if('I am not able to cancel my ticket partially'.equalsIgnoreCase(cs.Issue_Sub_Category__c) && isCancellable && !isPartialCanellationAllowed)
                     prepareEmailBody(cs,'Partial_Cancellation_Expired',orgEmailId,partCancelSTC);
                 
                  else
                    listCasesToUpdate.add(cs);  
                    
                  }
               }

              }
          }
          
        
        if(!listCasesToUpdate.isEmpty())
        {
            if(!listCommToInsert.isEmpty())
            {
                Database.saveResult[] caseCommUpdateResult =Database.insert(listCommToInsert,false);
                for(Database.saveResult comSR :caseCommUpdateResult)
                {
                  system.debug('Sucess...'+comSR.isSuccess());
                  if(!comSR.isSuccess())
                  System.debug('error..'+comSR.getErrors());
                }  
            }
            
            Database.saveResult[] caseUpdateResult = Database.update(listCasesToUpdate,false);
            
            
             
              for(Database.saveResult cres :caseUpdateResult)
            {
              system.debug('Sucess...'+cres.isSuccess());
              if(!cres.isSuccess())
              System.debug('error..'+cres.getErrors());
             }
     
        }
        if(!listEMail.isEmpty())
        {
            Messaging.sendEmail(listEMail);
        }
    
    }
    
    public void prepareEmailBody(Case cs,String templateName,Id orgEmaId,String comments)
    {    
     system.debug('---email-----');
        cs.First_Closure__c=system.now();
        cs.status='Closed';   
        cs.Is_ML_Processed__c = true;       
        EmailTemplate emailTemp = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate where DeveloperName =:templateName];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{cs.Booking_Email_ID__c});
        mail.setTemplateId(emailTemp.id);
        mail.setOrgWideEmailAddressId(orgEmaId);
        mail.setUseSignature(false);
        mail.setSubject(emailTemp.Subject.replace('{!Case.CaseNumber}',cs.CaseNumber));
               
        Http ht = new Http();
        HttpRequest polReq= new HttpRequest();
        HttpResponse polRes = new HttpResponse();
        polReq = HttpRequestUtil.populateCAPIHeaders(polReq);
        polReq.setMethod('GET');
        polReq.setEndpoint(System.Label.CAPI_Cancelation_Policy_URI+cs.OrderItem_Uuid__c);
        polRes = ht.send(polReq);
        string polResp = polRes.getBody();
        system.debug('polResp-->>'+polResp);
        CancellationPolicyCntrl.CancellationPolicyResponse cancelResponse = new CancellationPolicyCntrl.CancellationPolicyResponse();

        if(polRes.getStatus()=='OK' & polRes.getStatusCode()==200 && String.isNotBlank(polResp))
        {
            cancelResponse = (CancellationPolicyCntrl.CancellationPolicyResponse)JSON.deserialize( polResp, CancellationPolicyCntrl.CancellationPolicyResponse.class);
            system.debug('---------resp---------------'+cancelResponse);
            if(!cancelResponse.BookedViaTcp){
            String strhtmlBody = ' <html>';
            strhtmlBody += ' <table border="1" cellpadding="4" cellspacing="0" allign="center"> ';
            strhtmlBody += ' <thead bgcolor="mediumspringgreen"><tr> <th><B>Time of Cancellation </B></th> <th><B>Cancellation Percentage</B></th> </tr></thead> <tbody  style="font-family: Arial; font-size: 9pt;">';
            String expiriryTime='';                      
            for(CancellationPolicyCntrl.cancelpolicylist policy: cancelResponse.cancelpolicylist)
            {
                
                if(String.isBlank(expiriryTime))
                    expiriryTime = policy.duration.replace('After','').replace('Before','').replace('Till','');
                
                strhtmlBody += '<tr>';
                strhtmlBody += '<td>' + policy.duration + '</td>';
                strhtmlBody += '<td>' + policy.percentage + '</td>';
                strhtmlBody += '</tr>';
             
            }
            if(String.isNotBlank(expiriryTime))
            {
                strhtmlBody+= '</tbody></table></html>';
                String htmlBody = emailTemp.HtmlValue;
                htmlBody = htmlBody.replace('{!Case.Description}',strhtmlBody).replace('{!Case.Expected_Closure_Time__c}',expiriryTime).replace('{!Case.TIN_No__c}',cs.TIN_No__c);
                mail.setHtmlBody(htmlBody);
                cs.Closed_By_Agent__c = 'Salesforce System';
                cs.Closed_By__c = 'Salesforce System'; 
                CaseComment comm = new CaseComment();
                comm.commentbody = comments.replace('{expiryDate}',expiriryTime);
                comm.parentid = cs.id;
                listCommToInsert.add(comm);
                listCasesToUpdate.add(cs);
                listEMail.add(mail);
            }
           }
         }
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                           WHERE Id =:BC.getJobId()];
       if(a.NumberOfErrors>0)
       {
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           List<String> toAddresses = new List<String>();
           toAddresses.add('veeramanikanta.r@redbus.com');
           mail.setToAddresses(toAddresses);
           mail.setSubject('Cancellation Auto Closure Exception'+a.Status);
           mail.setPlainTextBody
           ('The batch Apex job processed ' + a.TotalJobItems +
           ' batches with '+ a.NumberOfErrors + ' failures.');
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      }
    }
  }