/**
* (c) 2024 RedBus
*
* Name           : VM_MIMbookingNoPnrEmailRndrScheduler 
* Created Date   : 28 feb 2024
* Created By     : Mahenda k
* Purpose        : Sending Email Alert for the NO Pnr for VM_MIM Booking
*
**/

global class VM_MIMbookingNoPnrEmailRndrScheduler implements Schedulable
{  
    global final String reportName;
    public static integer emailCt=0;
    public void execute(SchedulableContext scon) 
    {
        ReminderForNoPNRtranscations();
    }
    
    public void ReminderForNoPNRtranscations(){
        
        list<Order_Items__c> ordrItList = new list<Order_Items__c>();
        string transQuery=[SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='NoPNR_Transcations'].QueryDetails__c;
        ordrItList= (List<Order_Items__c>)Database.query(transQuery);
        list<Order_Items__c> noPNRTransLst=new list<Order_Items__c>();
        list<casecomment> ccList=new list<casecomment>();   
        
        Datetime currentTime=system.now();
        
        for(Order_Items__c orItm:ordrItList){
            System.debug('--orItm-->'+orItm);
            
            String dateTimeString = orItm.Date_of_Journey_Local__c;
            // Split the string based on spaces to separate date and time
            String[] parts = dateTimeString.split(' ');
            
            // Extract date components
            String dateString = parts[0];
            String[] dateParts = dateString.split('-');
            Integer day = Integer.valueOf(dateParts[0]);
            Integer month = Integer.valueOf(dateParts[1]);
            Integer year = Integer.valueOf(dateParts[2]);
            
            // Extract time components
            String timeString = parts[1];
            String[] timeParts = timeString.split(':');
            Integer hour = Integer.valueOf(timeParts[0]);
            Integer minute = Integer.valueOf(timeParts[1]);
            
            // Adjust hour for PM
            String amPm = parts[2];
            if (amPm == 'PM' && hour != 12) {
                hour += 12; // Convert to 24-hour format
            } else if (amPm == 'AM' && hour == 12) {
                hour = 0; // Midnight
            }
            
            // Create Datetime object
            Datetime dt = Datetime.newInstance(year, month, day, hour, minute, 0);
            System.debug('>>>>>'+dt);
            
            
            //addMinutes addhours
            // Datetime doj = Datetime.valueof(orItm.Date_of_Journey_Local__c);
            datetime fifteenMinutesTrans =orItm.Ticket_Confirmed_Time__c.addMinutes(15);
            datetime actTranscfrmTime =orItm.Ticket_Confirmed_Time__c.addMinutes(360);// 12.45pm
            
            Integer currentHourGMT = Integer.valueOf(DateTime.now().formatGMT('HH'));
            
            // Get the current local time
            DateTime currentTimeLocal = DateTime.now().addMinutes(-330);
            
            // Convert local time to UTC
            DateTime currentTimeUTC = DateTime.newInstanceGmt(
                currentTimeLocal.year(),
                currentTimeLocal.month(),
                currentTimeLocal.day(),
                currentTimeLocal.hour(),
                currentTimeLocal.minute(),
                currentTimeLocal.second()
            );
            
            System.debug('Current Time in UTC: ' + currentTimeUTC);
            
            system.debug('>>actTranscfrmTime>>>'+actTranscfrmTime+'--currentUTC--'+currentTimeUTC+'--cnfrmTime--'+orItm.Ticket_Confirmed_Time__c+'>>>>id--'+orItm.Order_Id__c);
            if(actTranscfrmTime > currentTimeUTC){
                noPNRTransLst.add(orItm);
                system.debug('--noPNRTransLst--'+noPNRTransLst.size());             
            }
        } 
        
        if(!noPNRTransLst.isEmpty()){                     
            sendEmail(noPNRTransLst); 
        }
        
    }
    
    public void sendEmail(list<Order_Items__c> orItmslst){
        list<EmailMessage> emsgList=new list<EmailMessage>();
        integer i=0;
        DataDeletionSetup__mdt  dt=new DataDeletionSetup__mdt();
        dt=[SELECT QueryDetails__c,Batch_Size__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='NonCallableBo_Query'];
        Group bdQueueId=[Select Id from Group where name='BD Queue' limit 1];
        list<Order_Items__c> upOrItmList=new list<Order_Items__c>();
        list<casecomment> ccList=new list<casecomment>(); 
        
        String emailBody = '<table border="1"><tr><th>Trip Id</th><th>BO Name</th><th>DOJ</th><th>Source</th><th>Destination</th><th>Total Ticket Amount</th></tr>';
        
        for(Order_Items__c orItm:orItmslst){  
            System.debug('rem-->'+orItm);
            
            String encodedText = EncodingUtil.urlEncode(orItm.Destination__c, 'UTF-8');
            String decodedDest = EncodingUtil.urlDecode(encodedText, 'UTF-8');
            
            String encodedSText = EncodingUtil.urlEncode(orItm.Source__c, 'UTF-8');
            String decodedSour = EncodingUtil.urlDecode(encodedSText, 'UTF-8'); 
            
            
            emailBody +='<tr><td>' + orItm.Order_Id__c + '</td><td>'+ orItm.Service_Provider_Name__c +'</td><td>' +orItm.Date_of_Journey_Local__c+'</td><td>' +decodedSour+ '</td><td>' +decodedDest+ '</td><td>' +orItm.Total_Fare__c +'</td></tr>';
            
            // '<tr><td>' + orItm.Order_Id__c + '</td><td>'+ orItm.Corrected_Date_of_Journey__c +'</td><td>' +orItm.CreatedDate + '</td></tr>';
        }
        emailBody += '</table>';
        
        EmailMessage emailMsg = new EmailMessage(); 
        emailCt++; 
        
        List<String> toAddresses = new List<String>();  
        List<String> CcAddresses = new List<String>(); 
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setUseSignature(false);
        email.setSaveAsActivity(true);
        
        Datetime nowUTC = Datetime.now(); // Get the current server time (in UTC)
        System.debug('Current UTC Time: ' + nowUTC);
        
        // Convert UTC time to Vietnam time (ICT)
        Integer vietnamOffset = 7; // Vietnam time zone offset (UTC+7)
        Datetime nowICT = nowUTC.addHours(vietnamOffset);
        System.debug('Current Vietnam Time (ICT): ' + nowICT);
        
        email.setSubject(' VM MIM Booking - No. PNR/TIN alert : ' + nowICT);
        
        /* String emailBody = '<table border="1"><tr><th>Trip Id</th><th>DOJ</th><th>CreatedDate</th></tr>';
emailBody += '<tr><td>' + orItm.Order_Id__c + '</td><td>'+ orItm.Corrected_Date_of_Journey__c +'</td><td>' +orItm.CreatedDate + '</td></tr>';
emailBody += '</table>';*/
        
        email.setCharset('UTF-8'); // Set the character encoding
        
        // string toMaiilAddress ='nilika.haldar@redbus.com';
        //'thao.nguyen@redbus.com';
        // string testMaiilAddress ='mahendrareddy.k@redbus.com';
        toAddresses.addAll(System.Label.VM_MIMbookingNoPnrEmailIds.split(','));
        
        //toAddresses.add(toMaiilAddress);
        //  toAddresses.add(testMaiilAddress);
        
        system.debug('-->>>>>'+toAddresses);
        email.setToAddresses(toAddresses);
        email.setHtmlBody(emailBody);
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {email};
            Messaging.sendEmail(emailList);              
        System.debug(emailList[0].getToAddresses());
        emailMsg.ToAddress=(emailList[0].getToAddresses())[0];
        emailMsg.Subject=emailList[0].getSubject();
        emailMsg.HtmlBody=emailList[0].getHtmlBody();
        // emailMsg.ParentId = orItm.Id; //Attach with the case
        emailMsg.MessageDate = system.now();
        emailMsg.Status = '0';
        emsgList.add(emailMsg);
        //upOrItmList.add(orItm);
        
        if(!upOrItmList.isEmpty()){
            update upOrItmList;
        } 
        
        if(!emsgList.isEmpty()){
            //insert emsgList;
        }
    }
}