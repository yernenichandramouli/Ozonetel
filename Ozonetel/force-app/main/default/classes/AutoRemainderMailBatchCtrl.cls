/**
 * (c) 2023 RedBus
 *
 * Name           : AutoRemainderMailBatchCtrl
 * Created Date   : 12 JUL 2023
 * Created By     : VR Sudarshan
 * Purpose        : Batch class to send auto remainder email for waiting for customer cases.
 * Test class     : AutoRemainderMailBatchSchedulerCtrlTest
 *
 **/
global class AutoRemainderMailBatchCtrl implements DataBase.Batchable<sObject>, Schedulable{
    public string query;

    public AutoRemainderMailBatchCtrl(String strQuery) {
        if(String.isNotBlank(strQuery)){
            Query = strQuery;
        }else{
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CaseRemainder_Query'].QueryDetails__c;
        }
    }

    public void execute(SchedulableContext scon){
        System.abortJob(scon.getTriggerId());
        Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='CaseRemainder_Query'].Duration__c;
        System.schedule('AutoRemainderMailBatchScheduler - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);
        Database.executeBatch(new AutoRemainderMailBatchCtrl(Query));
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext bc){
        System.Debug(':::: Query :::: '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(DataBase.BatchableContext bc,List<Case> caseList){
        list<case> fCases=new list<case>();
        list<case> sCases=new list<case>();
        list<case> tCases=new list<case>();
        list<casecomment> ccList=new list<casecomment>();
        set<id> caseids = New set<id>();
        for(case c:caseList){
            caseids.add(c.id);
        }
        List<Case> caseListToprocess = [select id,status,Auto_Closure__c,Waiting_for_Customer_Time__c,Country__c,Customer_Revert_Delay__c,TAT_Notifier_Email__c,suppliedEmail,Thread_Id__c,Owner.name,Owner.userRole.name,Reminders__c,Issue_Type__c,Account_Holder_Name__c, skipValidationRule__c from case where Id=:caseids];
        for(case c:caseListToprocess){
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
        list<case> csList=new list<case>();
        list<casecomment> ccList=new list<casecomment>();
        for(case c:cases){
            System.debug('rem-->'+c.Reminders__c);
            EmailMessage emailMsg = new EmailMessage(); 
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
            if(owea.size()>0){
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            email.setUseSignature(false);
            email.setSaveAsActivity(true);
            if(templateName=='first'){
                c.Reminders__c='1';
                if('Peru'.equalsIgnoreCase(c.Country__c)){
                        wbLink='https://m.redbus.pe/help';
                        email.setSubject('Reminder 1 - Información necesaria'+c.thread_id__c);
                        email.setHtmlBody('<html><body>Estimado cliente, <br/> <br/>Para poder procesar su solicitud de manera eficiente, necesitamos que nos proporcione algunos detalles adicionales. Agradeceríamos mucho si pudiera responder a la brevedad. Por favor, haga clic en el siguiente enlace para enviar la información requerida : <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Gracias por su comprensión.<br/><br/> Atentamente, <br/>El equipo de soporte de redBus</body></html>');
                }else if('Colombia'.equalsIgnoreCase(c.Country__c)){
                    wbLink='https://m.redbus.co/help';
                    email.setSubject('Reminder 1 - Información necesaria'+c.thread_id__c);
                    email.setHtmlBody('<html><body>Estimado cliente, <br/> <br/>Para poder procesar su solicitud de manera eficiente, necesitamos que nos proporcione algunos detalles adicionales. Agradeceríamos mucho si pudiera responder a la brevedad. Por favor, haga clic en el siguiente enlace para enviar la información requerida : <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Gracias por su comprensión.<br/><br/> Atentamente, <br/>El equipo de soporte de redBus</body></html>');
                }else{
                    email.setSubject('Reminder 1 - Information needed'+c.thread_id__c);
                    email.setHtmlBody('<html><body>Dear Customer, <br/> <br/> As per the communication from our customer service team, we had requested you to share some key details that are required from your end to action your request. It would be helpful if you can respond at the earliest. To respond, please click the link below <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Thanks, <br/>redBus Support team </body></html>');
                }
            }else if(templateName=='second'){
                c.Reminders__c=c.Reminders__c+',2';
                 if('Peru'.equalsIgnoreCase(c.Country__c)){
                     wbLink='https://m.redbus.pe/help';
                     email.setSubject('Reminder 2 - Información necesaria'+c.thread_id__c);
                     email.setHtmlBody('<html><body>Estimado cliente, <br/> <br/>Como mencionamos en nuestro correo electrónico anterior, aún estamos a la espera de algunos detalles clave para procesar su solicitud. Le agradeceríamos mucho si pudiera proporcionarlos a la mayor brevedad posible.<br/><br/>Para enviar la información requerida, por favor haga clic en el siguiente enlace: <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Gracias por su comprensión.<br/><br/> Atentamente, <br/>El equipo de soporte de redBus</body></html>');
                }else if('Colombia'.equalsIgnoreCase(c.Country__c)){
                   wbLink='https://m.redbus.co/help';
                   email.setSubject('Reminder 2 - Información necesaria'+c.thread_id__c);
                   email.setHtmlBody('<html><body>Estimado cliente, <br/> <br/>Como mencionamos en nuestro correo electrónico anterior, aún estamos a la espera de algunos detalles clave para procesar su solicitud. Le agradeceríamos mucho si pudiera proporcionarlos a la mayor brevedad posible.<br/><br/>Para enviar la información requerida, por favor haga clic en el siguiente enlace: <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Gracias por su comprensión.<br/><br/> Atentamente, <br/>El equipo de soporte de redBus</body></html>');
                }else{
                    email.setSubject('Reminder 2 - Information needed'+c.thread_id__c);
                  email.setHtmlBody('<html><body>Dear Customer, <br/> <br/> As requested in the earlier email from us, we are still awaiting some key details. It would be helpful if you can respond at the earliest. To respond, please click the link below <br/> <a href="'+wbLink+'" target="_blank"> '+wbLink+'  </a> <br/><br/> Thanks, <br/>redBus Support team </body></html>');
               }
            }else if(templateName=='third'){
                c.status='Closed';
                c.Reminders__c=c.Reminders__c+',3';
                c.Closed_By__c=c.owner.name;
                c.Closed_By_Agent__c=c.owner.name;
                c.Auto_Closure__c=true;
                c.skipValidationRule__c=(c.Issue_Type__c=='Force Cancellation' && String.isBlank(c.Account_Holder_Name__c))?true:false;
                casecomment cc=new casecomment();
                cc.commentbody='Auto Closed - Customer not reverted';
                cc.parentid=c.id;
                ccList.add(cc);
                email.setSubject('Final Reminder - '+c.thread_id__c);
                if('Peru'.equalsIgnoreCase(c.Country__c)){
                     wbLink='https://m.redbus.pe/help';
                     email.setSubject('Reminder 3 - Información necesaria'+c.thread_id__c);
                      email.setHtmlBody('<html><body>Estimado cliente, <br/> <br/> Entendemos que pudo haber sido un momento inconveniente para compartir los detalles requeridos y comprendemos sus limitaciones de tiempo. Procederemos a cerrar esta solicitud en nuestro sistema, ya que no hemos recibido respuesta de su parte en más de 24 horas. No dude en responder con la información solicitada cuando tenga oportunidad; estaremos encantados de asistirle.<br/><br/>Para enviar la información requerida, por favor haga clic en el siguiente enlace: <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Gracias por su comprensión.<br/><br/> Atentamente, <br/>El equipo de soporte de redBus</body></html>');
                }else if('Colombia'.equalsIgnoreCase(c.Country__c)){
                   wbLink='https://m.redbus.co/help';
                   email.setSubject('Reminder 3 - Información necesaria'+c.thread_id__c);
                    email.setHtmlBody('<html><body>Estimado cliente, <br/> <br/> Entendemos que pudo haber sido un momento inconveniente para compartir los detalles requeridos y comprendemos sus limitaciones de tiempo. Procederemos a cerrar esta solicitud en nuestro sistema, ya que no hemos recibido respuesta de su parte en más de 24 horas. No dude en responder con la información solicitada cuando tenga oportunidad; estaremos encantados de asistirle.<br/><br/>Para enviar la información requerida, por favor haga clic en el siguiente enlace: <br/><a href="'+wbLink+'" target="_blank">'+wbLink+'</a> <br/><br/> Gracias por su comprensión.<br/><br/> Atentamente, <br/>El equipo de soporte de redBus</body></html>');
                }else{
                    email.setSubject('Reminder 3 - Information needed'+c.thread_id__c);
                   email.setHtmlBody('<html><body>Dear Customer, <br/><br/>We believe it must have been an inconvenient time for you to share the required details and understand your time constraints. As of now, we will be closing this particular complaint in our system since we have not received any response from you over 48 hrs. Please feel free to respond back with prescribed details whenever you find time and we will be more than happy to assist you. To respond, please click the link below<br/> <a href="'+wbLink+'" target="_blank"> '+wbLink+' </a> <br/><br/> Thanks, <br/>redBus Support team </body></html>');            
                }
            }
            
            if(string.isNotBlank(c.TAT_Notifier_Email__c)){
               toAddresses.add(c.TAT_Notifier_Email__c);
            }else if(string.isNotBlank(c.SuppliedEmail)){
              toAddresses.add(c.SuppliedEmail);
            }
            
            email.setToAddresses(toAddresses);
            email.setReplyTo('care@redbus.in');           
            Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {email};
            Messaging.sendEmail(emailList);              
            System.debug(emailList[0].getToAddresses());
            emailMsg.ToAddress=(emailList[0].getToAddresses())[0];
            emailMsg.Subject=emailList[0].getSubject();
            emailMsg.HtmlBody=emailList[0].getHtmlBody();
            emailMsg.ParentId = c.Id;
            emailMsg.MessageDate = system.now();
            emailMsg.Status = '0';
            emsgList.add(emailMsg);
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

    global void finish(DataBase.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sudarshan.vr@redbus.com'});
        mail.setSubject('Wainting for customer batch has processed...'+a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}