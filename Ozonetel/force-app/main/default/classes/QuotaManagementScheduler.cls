/*
* Name           : QuotaManagementScheduler 
* Created Date   : 27 Apr 2019
* Created By     : Veeramanikanta R
* Purpose        : Send all quota seats to CX as HTML image  
* Test class     : QuotaManagementSchedulerTest
*/
global class QuotaManagementScheduler implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts{
    global final String Query;
    public QuotaManagementScheduler(){
    }
    global QuotaManagementScheduler(String q){
        
        if(String.isNotBlank(q))
            Query = q;
        else
            Query = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='QuotaMgmtQuery'].QueryDetails__c;
    }
    
    global void execute(SchedulableContext sc) {
       
      //  System.abortJob(sc.getTriggerId());
       // Decimal nextInterval = [SELECT Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='QuotaMgmtQuery'].Duration__c;
        //System.schedule('QuotaManagementScheduler - '+String.valueOf(DateTime.now()), '0 '+DateTime.now().addMinutes(Integer.valueOf(nextInterval)).minute()+' */1 ? * *', this);

        Database.executeBatch(new QuotaManagementScheduler(query),40);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {

        System.debug('query..'+Query);        
        return Database.getQueryLocator([SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='QuotaMgmtQuery'].QueryDetails__c);
    }
    
    global void execute(Database.BatchableContext BC, list<Case> listCase)
    {     
        System.debug('calling');
       // listCase=[select id,casenumber,Seats__c,Name_ct__c,BO_Mobile_Number__c,Phone_No_ct__c,PNR_No__c,Date_of_Issue_of_Ticket__c,Source__c,Destination__c,Date_of_Journey__c,Service_Provider_Name__c,BO_Number__c,Service_Provider_Id__c,No_of_Seats__c from case where issue_type__c='Quota Management' AND BO_Mobile_Number__c!=null];
        
        Map<String, String> headerMap= new Map<String, String>();
        headerMap.put('Content-Type','application/json');
        headerMap.put('Channel_Name','WEB_DIRECT');
        headerMap.put('Country_Name','IDN');  
        headerMap.put('BusinessUnit','BUS');
        headerMap.put('endpoint_identifier','INDONESIA_PARTNER_SUPP');
        list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
        for(string o:headerMap.keyset())                       
            hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headerMap.get(o)));
        
        List<DBLog_Summary__c> dbList=new List<DBLog_Summary__c>();
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        string cxEndPoint=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SendHTMLImage'].Endpoint__c;
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
        
        Map<string,List<case>> caseMap=new Map<string,List<case>>();
        System.debug('listCase-->'+listCase);
        for(case c:listCase){
            if(c.Service_Provider_Id__c!=null){   
                if(caseMap.containsKey(c.Service_Provider_Id__c)){            
                    caseMap.get(c.Service_Provider_Id__c).add(c);            
                }else{            
                    caseMap.put(c.Service_Provider_Id__c,new list<case>{c});            
                }    
            }
        }
        
        for(string s:caseMap.keyset()){
            System.debug('ke-->'+caseMap.keyset().size());
            string allCases;
            string fmJs;
            string comFormatJs;
            string htmlStr='<HTML> <head> <style> table { border-collapse: collapse; } table, td, th { border: 1px solid black; } </style> </head> <body> <table style="width:100%" > <tr> <th>Nama</th> <th>No Handphone</th> <th>Waktu perjalanam</th> <th>PNR</th> <th>DOI</th> <th>Asal</th> <th>Tujuan</th> <th>DOJ</th> <th>Service Name</th> <th>Seat(s) Name</th> <th>Dipesan Oleh</th> <th>Keterangan</th> </tr>';                       
            set<string> sMobiles=new set<string>();
            for(case c:caseMap.get(s)){
                string alC;
                datetime doi;
                datetime doj;
                if(c.Date_of_Issue_of_Ticket__c!=null){
                  //doi=c.Date_of_Issue_of_Ticket__c-(90)/1440;
                  doi=c.Transaction_Creation_Time__c.addminutes(750);
                  }
                if(c.Date_of_Journey__c!=null){
                   doj=c.Date_of_Journey__c.addminutes(750);
                }  
               // fmJs='{"Nama":"'+c.Name_ct__c+'","NoHandphone":"'+c.Phone_No_ct__c+'","WaktuPerjalanam":"'+c.casenumber+'","PNR":"'+c.PNR_No__c+'","DOI":"'+c.Date_of_Issue_of_Ticket__c+'","Asal":"'+c.Source__c+'","Tujuan":"'+c.Destination__c+'","DOJ":"'+c.Date_of_Journey__c+'","ServiceName":"'+c.Service_Provider_Name__c+'","SeatsName":"'+c.No_of_Seats__c+'","DipesanOleh":"'+c.id+'","Keterangan":"'+c.id+'"}';
                fmJs='{"Nama":"'+c.Name_ct__c+'","NoHandphone":"'+c.Phone_No_ct__c+'","PNR":"'+c.PNR_No__c+'","DOI":"'+doi+'","Asal":"'+c.Source__c+'","Tujuan":"'+c.Destination__c+'","DOJ":"'+doj+'","ServiceName":"'+c.Service_Provider_Name__c+'","SeatsName":"'+c.Seats__c+'"}';
                alC='<tr><td>'+c.Name_ct__c+'</td><td>'+c.Phone_No_ct__c+'</td><td>'+c.casenumber+'</td><td>'+c.PNR_No__c+'</td><td>'+c.Date_of_Issue_of_Ticket__c+'</td><td>'+c.Source__c+'</td><td>'+c.Destination__c+'</td><td>'+c.Date_of_Journey__c+'</td><td>'+c.Service_Provider_Name__c+'</td><td>'+c.Service_Provider_Name__c+'</td><td>'+c.No_of_Seats__c+'</td><td>'+c.id+'</td></tr> ';
                allCases=allCases+alC;
                comFormatJs=comFormatJs+','+fmJs;
                fmJs='';
                List<string> sM=new List<string>();               
                sm=c.BO_Mobile_Number__c.split(',');
                sMobiles.addall(sM);
            }
            System.debug('smobiles-->'+sMobiles);
            comFormatJs='['+comFormatJs+']';
            comFormatJs=JSON.serialize(comFormatJs);
            comFormatJs=comFormatJs.substring(1, comFormatJs.length()-1);
            // comFormatJs=JSON.serialize(comFormatJs);
            System.debug('comFormatJs-->'+comFormatJs);
            System.debug('csm-->'+caseMap.get(s));
            string fromatedDescription;
            string name='Today DOJ Tickets';
            comFormatJs=JSON.serialize(comFormatJs);
                comFormatJs=comFormatJs.substring(1, comFormatJs.length()-1);
                comFormatJs=JSON.serialize(comFormatJs);
                comFormatJs=comFormatJs.substring(1, comFormatJs.length()-1);
            for(string sm:sMobiles){
                System.debug('smF-->'+sm);
                //SendNotificationWrapper sn=new SendNotificationWrapper('BO_CONFIRM_MAIL',null,sm,'CONFIRM_BO_EMAIL_IDN');            
                SendNotificationWrapper sn=new SendNotificationWrapper('Today Quota DOJ Bookings','getJSN',sm,'CONFIRM_BO_EMAIL_IDN');            
                String wsJsonBody=JSON.serialize(sn);
                wsJsonBody=JSON.serialize(wsJsonBody);
                /*comFormatJs=JSON.serialize(comFormatJs);
                comFormatJs=comFormatJs.substring(1, comFormatJs.length()-1);
                comFormatJs=JSON.serialize(comFormatJs);
                comFormatJs=comFormatJs.substring(1, comFormatJs.length()-1);*/
                wsJsonBody=wsJsonBody.replaceAll('getJSN', comFormatJs);
                
                htmlStr=htmlStr+allCases+'</table> </body> </HTML>';
                System.debug('js-->'+htmlStr);              
                string finalHeaderJson=json.serialize(json.serialize(hlist));
                
                string jsonCM='{"action":"POST","body":'+wsJsonBody+',"endPoint":"'+cxEndPoint+'","headers":'+finalHeaderJson+'}';
                System.debug('jsonCM-->'+jsonCM);
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                HTTP h = new HTTP();
                HttpRequest req= new HttpRequest();
                HTTPResponse res=new HTTPResponse();        
                req = HttpRequestUtil.populateHeaders(req);               
                req.setHeader('Channel_Name', 'WEB_DIRECT');
                req.setMethod('POST');
                req.setBody(jsonCM);
                req.setEndpoint(APIMData.Endpoint__c);
                dbl.SentAt__c = system.now();
                dbl.Type__c = 'Quota Management Scheduler';
                dbl.Payment_Request_Sent_Time__c = system.now();
                dbl.Request_Data__c= string.valueof(req)+jsonCM;
                try{
                     res=h.send(req);  
                    System.debug('resB--->'+res.getBody());
                    if(res.getBody()!=null){
                        dbl.Response_Received__c= String.valueOf(res+'<--Res body-->'+res.getBody()).left(9999);                
                        dbl.Payment_Request_Response_Time__c = System.now();
                        dbl.Payment_Ping_Status__c = 'Success';  
                    }
                }catch(Exception e){
                    dbl.Payment_Ping_Status__c = 'Failed';  
                    dbl.Exception_Description__c = string.valueOf(e);
                }
                dbList.add(dbl);              
            }
        }
        if(!dbList.isEmpty())
            insert dbList; 
        
    }    
    global void finish(Database.BatchableContext BC) 
    {                 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob 
                          WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addall(Label.RoundRobinNotification.Split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject('Quota Management Scheduler Finished '+a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        if(a.NumberOfErrors>0)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    public class SendNotificationWrapper{
        public List<string> channels=new List<string>{'whatsapp'};
            public string name;
        public address address=new address();
        public MessageDetails MessageDetails=new MessageDetails();
        public SendNotificationWrapper(string name,string description,string mobileNo,string templateName ){
            this.address.whatsapp_number=mobileNo;
            this.MessageDetails.DataJsonStr=description;
            this.MessageDetails.TemplateName=templateName;  
            this.name=name;          
        }        
    }
    public class address{
        public string whatsapp_number;
        public string links;
    }
    public class MessageDetails{
        public string TemplateName;
        public string DataJsonStr;
        public integer DataComplexity=2;
        public string Language='en';
        public string tin;   
    }  
}