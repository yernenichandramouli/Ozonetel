global class NonCallableBoAutoEmailRemainderScheduler implements Schedulable
{  
    global final String reportName;
    public static integer emailCt=0;
    public void execute(SchedulableContext scon) // Non-Callable BOs
    {
        ReminderCases();
    }
    
    public void ReminderCases(){
        list<case> caseList = new list<case>();
        datetime currentTime=system.now();
        string caseQuery=[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='NonCallableBo_Query'].QueryDetails__c;
        caseList= (List<case>)Database.query(caseQuery);
        list<case> fCases=new list<case>();
        list<case> sCases=new list<case>();
        list<case> tCases=new list<case>();    
        list<casecomment> ccList=new list<casecomment>();   
        
        DateTime currTime = System.Now();
        
        
        for(case c:caseList){
            System.debug('--c-->'+c);
            //addMinutes
            
            datetime TwentyFourHrsCaseCreated =c.createddate.addhours(24);
            //addhours(24);
            
            datetime ThirtySixHrsCaseCreated =c.createddate.addhours(36);
            
            datetime  FourtyEightHrsCaseCreated =c.createddate.addhours(48);
            
            if(c.Creation_Age__c > 24 &&  c.Creation_Age__c < 35 && (c.Reminders__c==null || (c.Reminders__c!=null && !c.Reminders__c.contains('2')))){           
                fCases.add(c); 
                system.debug('--fCases--'+fCases);             
            }
            
            if(c.Creation_Age__c > 36 &&  c.Creation_Age__c < 47 && (c.Reminders__c==null || (c.Reminders__c!=null && !c.Reminders__c.contains('3')))){             
                sCases.add(c); 
                system.debug('--sCases--'+sCases);             
                
            }
            
            if(c.Creation_Age__c > 48){
                tCases.add(c);
                system.debug('--tCases--'+tCases);             
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
        integer i=0;
        DataDeletionSetup__mdt  dt=new DataDeletionSetup__mdt();
        dt=[SELECT QueryDetails__c,Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='NonCallableBo_Query'];
        Group bdQueueId=[Select Id from Group where name='BD Queue' limit 1];
        list<case> csList=new list<case>();
        list<casecomment> ccList=new list<casecomment>(); 
        for(case c:cases){  
            System.debug('rem-->'+c.Reminders__c);
            EmailMessage emailMsg = new EmailMessage(); 
                emailCt++; 
                List<String> toAddresses = new List<String>();  
                List<String> CcAddresses = new List<String>(); 
                
                string BoMailAddress = string.isNotBlank(c.BO_Email__c) ? c.BO_Email__c : string.isNotBlank(c.BO_Email1__c) ? c.BO_Email1__c :'';
                
                string BdMailAddress = string.isNotBlank(c.BD_Email__c) ? c.BD_Email__c : string.isNotBlank(c.BD_Email1__c) ? c.BD_Email1__c :'';
                         
                //OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :mailAddress];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                /* if(owea.size() > 0 ){
email.setOrgWideEmailAddressId(owea.get(0).Id);
}*/
                
                email.setUseSignature(false);
                email.setSaveAsActivity(true);
                
                if(templateName=='first'){
                    c.Reminders__c=c.Reminders__c+',2';
                    email.setSubject('Reminder 1 - '+'caseNumber:'+c.caseNumber);
                    email.setHtmlBody('<html><body>Dear Bus Operator, <br/> <br/> This is to remind you that we are yet to receive an update from your end on the issue raised by the customer.Kindly check and respond at the earliest.<br/><br/> Thanks for your support, <br/>Team redBus</body></html>');
                }else if(templateName=='second'){
                    c.Reminders__c=c.Reminders__c+',3';
                    email.setSubject('Reminder 2 - '+'caseNumber:'+c.caseNumber);
                    email.setHtmlBody('<html><body>Dear Bus Operator, <br/> <br/> It has been 36 hrs and we are yet to receive an update from your end. Kindly revert at the earliest, as post 48hrs the issue will be escalated to the respective BD team for further support.<br/><br/> Thanks for your support, <br/>Team redBus</body></html>');
                }else if(templateName=='third'){
                    c.status='Escalated to BD';
                    c.All_Previous_Status_Dates__c=c.status+','+String.valueOf(System.now())+';'+c.All_Previous_Status_Dates__c;
                    c.Reminders__c=c.Reminders__c+',4';
                    // email.setSubject('Reminder 3 - '+'caseNumber:'+c.caseNumber);
                    //email.setHtmlBody('<html><body>Dear Bus Operator, <br/> <br/> This is to remind you that we are yet to receive an update from your end on the issue raised by the customer.Kindly check and respond at the earliest.<br/><br/> Thanks for your support, <br/>Team redBus</body></html>');
                    c.Assigned_to_BD__c=System.now();
                    c.Assigned_By__c='Non callble scheduler';
                    //c.Assigned_to_BD_OwnerName__c=UserInfo.getUsername();         
                    c.ownerid=bdQueueId.id;
                    casecomment cc=new casecomment();
                    cc.commentbody='It has been 48 hrs, no response from BO so it has been Escalated to BD';
                    cc.parentid=c.id;
                    ccList.add(cc);
                }
                //String[] toAddresses = new String[] {'mahendrareddy.k.r@redbus.com'};
                toAddresses.add(BoMailAddress);
                if(templateName=='first' || templateName=='second'){
                    
                    //toAddresses.add(BoMailAddress);
                    CcAddresses.add(BdMailAddress);
                    
                    system.debug('-->>>>>'+BdMailAddress+'--ccc--'+CcAddresses);
                    email.setToAddresses(toAddresses);
                    email.setCcAddresses(CcAddresses);
                    
                    email.setReplyTo('noncallablebo@263o95hdom324eg6l6t3v9p3si5rnscfbes44g0vdfr0ah6d3c.28-1kzyaeaw.ind112.apex.salesforce.com');           
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
                }
                
                csList.add(c);
                  
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