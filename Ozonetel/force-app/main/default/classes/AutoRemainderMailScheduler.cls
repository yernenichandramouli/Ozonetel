global class AutoRemainderMailScheduler implements Schedulable
{  
    global final String reportName;
    public static integer emailCt=0;
    public void execute(SchedulableContext scon)
    {
        ReminderCases();
    }
    
    public void ReminderCases(){
        list<case> caseList = new list<case>();
        datetime currentTime=system.now();
        string caseQuery=[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CaseRemainder_Query'].QueryDetails__c;
        caseList= (List<case>)Database.query(caseQuery);
        list<case> fCases=new list<case>();
        list<case> sCases=new list<case>();
        list<case> tCases=new list<case>();    
        list<casecomment> ccList=new list<casecomment>();    
        for(case c:caseList){
            System.debug('c-->'+c+'cust delay->'+c.Customer_Revert_Delay__c);
            if(c.Customer_Revert_Delay__c>=6 && c.Customer_Revert_Delay__c<12 && (c.Reminders__c==null || (c.Reminders__c!=null && !c.Reminders__c.contains('1'))) ){               
                fCases.add(c);             
            }
            if(c.Customer_Revert_Delay__c>=12 && c.Customer_Revert_Delay__c<24 && (c.Reminders__c==null || (c.Reminders__c!=null && !c.Reminders__c.contains('2')))){             
                sCases.add(c);               
            }
          if(c.Customer_Revert_Delay__c>=24 && (c.Reminders__c==null || (c.Reminders__c!=null && !c.Reminders__c.contains('3')))){                
                tCases.add(c);
            }
        }
        if(!fcases.isEmpty()){          
            sendEmail(fCases,'first');
        }
        if(!sCases.isEmpty()){          
            sendEmail(sCases,'second');
        }
        if(!tCases.isEmpty()){                     
            sendEmail(tCases,'third'); 
        }     
    }
    
    public void sendEmail(list<case> cases,string templateName){
        list<EmailMessage> emsgList=new list<EmailMessage>();
        Map<string,string> countryMap=new Map<string,string>();
        countryMap.put('India','in');
        countryMap.put('Singapore','sg');
        countryMap.put('Indonesia','id');
        countryMap.put('Malaysia','my');
        countryMap.put('Peru','pe');
        countryMap.put('Colombia','co');
        countryMap.put('Cambodia','kh');
        string wbLink;
        integer i=0;
        DataDeletionSetup__mdt  dt=new DataDeletionSetup__mdt();
        dt=[SELECT QueryDetails__c,Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CaseRemainder_Query'];
        list<case> csList=new list<case>();
        list<casecomment> ccList=new list<casecomment>(); 
        for(case c:cases){  
        System.debug('rem-->'+c.Reminders__c);
        EmailMessage emailMsg = new EmailMessage(); 
            if(emailCt<dt.Batch_Size__c){   
             emailCt++; 
            List<String> toAddresses = new List<String>();  
            string mailAddress;
            if(string.IsNotBlank(c.country__c)){    
               string cutry=countryMap.get(c.country__c);
               mailAddress='noreply_feedback@redbus.'+cutry;
               wbLink='https://m.redbus.'+cutry+'/help';
             }else{
                mailAddress='noreply_feedback@redbus.in'; 
                wbLink='https://m.redbus.in/help';
              }
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :mailAddress];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(owea.size() > 0 ){
                 email.setOrgWideEmailAddressId(owea.get(0).Id);
             }
            email.setUseSignature(false);
            email.setSaveAsActivity(true);
            if(templateName=='first'){
                c.Reminders__c='1';
                email.setSubject('Reminder 1 - '+c.thread_id__c);
                email.setHtmlBody('<html><body>Dear Customer, <br/> <br/> As per the communication from our customer service team, we had requested you to share some key details that are required from your end to action your request. It would be helpful if you can respond at the earliest. To respond, please click the link below <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Thanks, <br/>redBus Support team </body></html>');
            }else if(templateName=='second'){
                c.Reminders__c=c.Reminders__c+',2';
                email.setSubject('Reminder 2 - '+c.thread_id__c);
                email.setHtmlBody('<html><body>Dear Customer, <br/> <br/> As requested in the earlier email from us, we are still awaiting some key details. It would be helpful if you can respond at the earliest. To respond, please click the link below <br/> <a href="'+wbLink+'" target="_blank"> '+wbLink+'  </a> <br/><br/> Thanks, <br/>redBus Support team </body></html>');
            }else if(templateName=='third'){
                c.status='Closed';
                c.Reminders__c=c.Reminders__c+',3';
                c.Closed_By__c=c.owner.name;
                c.Closed_By_Agent__c=c.owner.name;
                c.Auto_Closure__c=true;
                //c.Closed_By_Agent_Role__c=c.owner.team__c;
                casecomment cc=new casecomment();
                cc.commentbody='Auto Closed - Customer not reverted';
                cc.parentid=c.id;
                ccList.add(cc);
                email.setSubject('Final Reminder - '+c.thread_id__c);
                email.setHtmlBody('<html><body>Dear Customer, <br/><br/>We believe it must have been an inconvenient time for you to share the required details and understand your time constraints. As of now, we will be closing this particular complaint in our system since we have not received any response from you over 48 hrs. Please feel free to respond back with prescribed details whenever you find time and we will be more than happy to assist you. To respond, please click the link below<br/> <a href="'+wbLink+'" target="_blank"> '+wbLink+' </a> <br/><br/> Thanks, <br/>redBus Support team </body></html>');            
            }
            //String[] toAddresses = new String[] {'veeramanikanta.r@redbus.com'};
            toAddresses.add(c.TAT_Notifier_Email__c);
           // toAddresses.add('veeramanikanta.r@redbus.com');
            email.setToAddresses(toAddresses);
            email.setReplyTo('care@redbus.in');           
            Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {email};
            Messaging.sendEmail(emailList);              
            System.debug(emailList[0].getToAddresses());
            emailMsg.ToAddress=(emailList[0].getToAddresses())[0];
            emailMsg.Subject=emailList[0].getSubject();
            emailMsg.HtmlBody=emailList[0].getHtmlBody();
            emailMsg.ParentId = c.Id; //Attach with the case
            emailMsg.MessageDate = system.now();
            emailMsg.Status = '0';
            emsgList.add(emailMsg);
            csList.add(c);
            }
        }
        
        if(!ccList.isEmpty()){
          insert ccList;
        }
         
        if(!csList.isEmpty()){
           update csList;
        } 
        
        if(!emsgList.isEmpty()){
            insert emsgList;
        }
    }
}