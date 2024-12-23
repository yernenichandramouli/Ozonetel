/*
* Name           : SendSmsEmailExtension
* Created Date   : 23 May 2017
* Created By     : Veeramanikanta R
* Purpose        : Sending SMS and Email to Customers 
* Test class     : SendSmsEmailExtensionTest
*/
public class SendSmsEmailExtension {
    
    public string mobile{get;set;}
    public string email{get;set;}
    public boolean eCheck{get;set;}
    public boolean mCheck{get;set;}
    public string paramValue{get;set;}
    public Order_Items__c tObj{get;set;}
    public List<DBLog_Summary__c> dbLogList;
    public boolean mobileEnable{get;set;}
    public boolean emailEnable{get;set;}
    public string tempBusinessUnit;
    public string sendRequestData;
    public string sendResponseData;
    public DBLog_Summary__c dbLog;
    public integer statusCode{get;set;}
    public boolean type{get;set;}
    public string comCurrency{get;set;}
    public string comCountry{get;set;}
    // Start - send Notification
    public string response{get;set;}
    
    // ENd - send Notification    
    public SendSmsEmailExtension(ApexPages.StandardController controller) {
        if(controller.getId()!=null){
            tObj=[select id,name,recordtypeid,Order_Item_Reference_No__c,Inventory_Type__c,country__c,Amount_Recieved_Currency__c,Email__c,Mobile__c,Business_Unit__c,Order_Id__c,Item_Type__c,Transaction_Status__c from Order_Items__c where id=:controller.getId()];            
            tempBusinessUnit=tObj.Business_Unit__c;
            comCurrency=tObj.Amount_Recieved_Currency__c;
            comCountry=tObj.country__c;
            if(!tempBusinessUnit.contains('REDBUS')){
                tempBusinessUnit='REDBUS'+tempBusinessUnit.right(3);
            }
            if(tObj.recordtypeid==Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId()) {
                type=true;
            }        
            DateTime dbLatest;
            decimal decMinutes;
            dbLogList =new list<DBLog_Summary__c>(); 
        }
        dbLog=new DBLog_Summary__c();
    }
    
    public string Send(){
        DateTime dbLatest;
        decimal decMinutes;
        
        
        
        System.debug('paramValue-->'+paramValue);
        String sMobile;
        String sEmail;
        
        if(mCheck==true && mobile!='' )
            sMobile=selectedCountry+mobile;
        else{
            if(tObj.Mobile__c.startsWith('0')){
                String value = tObj.Mobile__c;
                value = value.substring(1);
                sMobile='91'+value;
                System.debug('correct mob'+sMobile);
            }else{
                sMobile=tObj.Mobile__c;
            }
        }
        
        System.debug('sM-->'+sMobile); 
        
        if(eCheck==true && email!='')
            sEmail=email;
        else
            sEmail=tObj.email__c;
        
        dbLogList=[select id,name,createddate,e_m_Ticket_Status__c from DBLog_Summary__c where Payment_Transaction_Name__c=:tObj.id  AND Send_To__c=:sMobile AND e_m_Ticket_Status__c='SMS Success' order by CreatedDate DESC LIMIT 1];        
        if(!dbLogList.isEmpty() && paramValue=='mTicket'){
            dbLatest= dbLogList[0].createddate;
            decMinutes = ((System.now().getTime())/1000/60)-((dbLatest.getTime())/1000/60);
            System.debug('came inside 1');
            if(decMinutes<=15){
                System.debug('came inside 2');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You already sent to '+sMobile+''));
                return null;
            }
            
        }
        
        dbLogList=[select id,name,createddate,e_m_Ticket_Status__c from DBLog_Summary__c where Payment_Transaction_Name__c=:tObj.id  AND Send_To__c=:sEmail AND e_m_Ticket_Status__c='Email Success' order by CreatedDate DESC LIMIT 1];        
        if(!dbLogList.isEmpty() && paramValue=='eTicket'){
            dbLatest= dbLogList[0].createddate;
            decMinutes = ((System.now().getTime())/1000/60)-((dbLatest.getTime())/1000/60);
            System.debug('came inside 1');
            if(decMinutes<=15){
                System.debug('came inside 2');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You already sent to '+sEmail+''));
                return null;
            }
            
        }
        
        
        system.debug('tempBusinessUnit-->'+tempBusinessUnit);
        //Country_Codes__c ccObj= Country_Codes__c.getValues(tempBusinessUnit);        
        //system.debug('ccObj--->'+ccObj);
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);               
        req.setHeader('auth_key','a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
        req.setHeader('Channel_Name', 'SFA');
         if('REDBUS_COM'.equalsIgnoreCase(tempBusinessUnit)){
            system.debug('==comCurrency=='+comCurrency);  
            DOTCOM_Values__c dotoComVal= DOTCOM_Values__c.getValues(comCurrency);
            
            system.debug('--dotoComVal__'+dotoComVal);
            if(string.isNotBlank(dotoComVal.Country__c)){
            system.debug('--dotoComVal=='+dotoComVal.Country__c);
            req.setHeader('Country_Name', dotoComVal.Country__c);
            req.setHeader('SelectedCurrency',dotoComVal.SelectedCurrency__c);
            req.setHeader('Currency',dotoComVal.SelectedCurrency__c);
             }
            }else{
             Country_Codes__c ccObj= Country_Codes__c.getValues(tempBusinessUnit);
             req.setHeader('Country_Name', ccObj.Country_Header__c);
            }
            
       if(!tObj.Business_Unit__c.contains('REDBUS_')){
            list<string> busLs=new list<string>();
            busLs=tObj.Business_Unit__c.split('_');
            req.setHeader('Operator',busLs[0]);
        }
         system.debug('>>>'+req.getHeader('Country_Name'));
        req.setMethod('GET');
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='e_m_Ticket'];
        String endPoint;
        if(paramValue=='mTicket')
            endPoint=APIMData.Endpoint__c+tObj.Order_Item_Reference_No__c+'?flag=1&EmailId='+sEmail+'&ContactNo='+sMobile;
        else if(paramValue=='eTicket')
            endPoint=APIMData.Endpoint__c+tObj.Order_Item_Reference_No__c+'?flag=2&EmailId='+sEmail+'&ContactNo='+sMobile;
        
        req.setEndpoint(endPoint);                       
        System.debug('endponit-->'+endPoint);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Payment_Transaction_Name__c=tObj.id;
        dbl.Request_Data__c = req.getEndpoint();
        dbl.Traveller_Info_Failed__c='..Headers...'+req.getHeader('Channel_Name')+'=authKey-'+req.getHeader('auth_key')+'-bu-'+req.getHeader('BusinessUnit')+'-co--'+req.getHeader('Country_Name')+'--curncy..'+req.getHeader('SelectedCurrency')+'--curency-'+req.getHeader('Currency');
        dbl.EndPoint__c = String.valueOf(req.getEndpoint());

        try{
            res=h.send(req);   
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());     
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.Response_Received__c = res.getBody();
            System.debug('res body'+res.getBody());
            
            ResponseWrapper respWrapper= (ResponseWrapper)System.JSON.deserialize(res.getBody(),ResponseWrapper.class);
            if(paramValue=='mTicket' && (respWrapper.IsSMSSent==true || respWrapper.isWhatsAppSent==true)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'SMS has been sent successfully to <b>'+sMobile+' </b>'));
                dbl.Type__c = 'M Ticket';
                dbl.e_m_Ticket_Status__c= 'SMS Success';
                dbl.Send_To__c=sMobile;              
            }else if(paramValue=='mTicket'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to send SMS. Please try again.'));
                dbl.Type__c = 'M Ticket';
                dbl.e_m_Ticket_Status__c= 'SMS Failed';
                dbl.Send_To__c=sMobile;               
            }
            
            if(paramValue=='eTicket' && respWrapper.IsEmailSent==true){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Email has been sent successfully to <b>'+sEmail+' </b>'));
                dbl.Type__c = 'E Ticket';
                dbl.e_m_Ticket_Status__c= 'Email Success';
                dbl.Send_To__c=sEmail;                
            }else if(paramValue=='eTicket'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to send Email. Please try again.'));
                dbl.Type__c = 'E Ticket';
                dbl.e_m_Ticket_Status__c= 'Email Failed';
                dbl.Send_To__c=sEmail;              
            }
            if(APIMData.EnableLog__c==true)
                insert dbl;
        }catch(Exception e){           
            dbl.e_m_Ticket_Status__c= 'API Failed';
            dbl.Response_Received__c=res.getBody();
            if(paramValue=='mTicket'){
                dbl.Send_To__c=sMobile;
                dbl.Type__c = 'M Ticket';
            }else{
                dbl.Send_To__c=sEmail;
                dbl.Type__c = 'E Ticket';
            }
            if(APIMData.EnableLog__c==true)
                insert dbl;  
            //If the TIN number is invalid then it doesn't send m/e ticket and throws below error
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured!! Please Contact Admin'));
            
        }
        
        return null;
    }
    
    public object sendTicket(){
        String sMobile;
        String sEmail;
        dbLog=new DBLog_Summary__c();
        if(mCheck==true && mobile!='' )
            sMobile=selectedCountry+mobile;
        else{
            if(tObj.Mobile__c.startsWith('0')){
                String value = tObj.Mobile__c;
                value = value.substring(1);
                sMobile='91'+value;
                System.debug('correct mob'+sMobile);
            }else{
                sMobile=tObj.Mobile__c;
            }
        }
        
        if(eCheck==true && email!='')
            sEmail=email;
        else
            sEmail=tObj.email__c;
        
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BSend_E_M_Ticket'];
        
        RequestWrapper rwp=new RequestWrapper();
        rwp.tin=tObj.Order_Item_Reference_No__c;
        string strVal;
        if(string.isNotBlank(sEmail) && paramValue=='eTicket'){
            rwp.userEmailId=sEmail;
            rwp.notificationTypeSet.add('EMAIL');
            strVal='E Ticket';
            dbLog.Send_To__c=sEmail;
        }else{
            rwp.userMobileNumber=sMobile;
            rwp.notificationTypeSet.add('SMS');
            strVal='M Ticket';
            dbLog.Send_To__c=sMobile;
        }
        String sendJson=json.serialize(rwp); 
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();        
        req.setEndpoint(APIMData.Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');  
        req.setBody(sendJson); 
        OAuthGeneric oauthObj=new OAuthGeneric();             
        string oauthParams=oauthObj.sign(req,tObj.Inventory_Type__c);
        string endPoint=APIMData.Endpoint__c+'?'+oauthParams;
        req.setEndpoint(endPoint);
        dbLog.Request_Data__c = req+'..Body..'+sendJson;
        dbLog.EndPoint__c = String.valueOf(req.getEndpoint());
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetSendTicketResponse';
        this.sendRequestData= con.addHttpRequest(req);
        return con;
    }
    
    public object GetSendTicketResponse(){    
        dbLog.Type__c='B2B E/M Ticket';
        dbLog.Payment_Transaction_Name__c=tObj.id;
        HttpResponse response = Continuation.getResponse(this.sendRequestData);
        dbLog.CallOut_Status__c = string.valueOf(response.getStatus());
        this.sendResponseData= response.getBody();
        dbLog.Response_Received__c = response+'..Resp Body..'+this.sendResponseData;
        statusCode=response.getStatusCode();
        insert dbLog;
        if(statusCode==204){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Notification has been sent successfully!!'));                     
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Something went wrong, Please try again!! Status Code->'+statusCode));                     
        }
        return null;
    }
    
    public String selectedCountry {get;set;}
    public List<selectOption> countryCodes {
        get {
           List<selectOption> options = new List<selectOption>();
            
            for (Country_Codes__c c: Country_Codes__c.getAll().values())
                options.add(new SelectOption(c.Country_Code__c,c.Business_Unit__c+' - '+c.Country_Code__c));
                string busUnit='';
            if('REDBUS_COM'.equalsIgnoreCase(tempBusinessUnit)){
               DOTCOM_Values__c dotoComVal= DOTCOM_Values__c.getValues(comCountry);
               selectedCountry=dotoComVal.Country_code__c;
            }else{
             Country_Codes__c ccObj= Country_Codes__c.getValues(tempBusinessUnit);
             selectedCountry=ccObj.Country_Code__c;
            }
            
            if(string.isBlank(selectedCountry)){
             selectedCountry='91';
            }
            System.debug('ccObj--->'+selectedCountry );
            return options;
        }
        set;
    }
    //Start - Send Notification Button 
    public void sendNotification( ){
        
        string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='e_m_Ticket'].Endpoint__c;
        system.debug('order name'+ tobj.Order_Id__c);
        endpoint = endpoint+tobj.Order_Id__c+'?isAddon=true';
        Http http = new Http();
        HttpRequest req = HttpRequestUtil.populateHeaders(new HttpRequest());
        req.setHeader('Postman-Token', 'cce2e099-6ac0-4338-8e19-a0b5347b042d');
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        system.debug('req'+req);
        res = http.send(req); 
        system.debug('res'+res);
        if(res.getStatusCode() == 200){
            HttpRequestWrappersUtil.NotificationResponse notificationResponse = new HttpRequestWrappersUtil.NotificationResponse();
            notificationResponse = (HttpRequestWrappersUtil.NotificationResponse)system.JSON.deserialize(res.getbody(), HttpRequestWrappersUtil.NotificationResponse.class); 
            system.debug('notificationResponse'+notificationResponse);
            system.debug('status Message'+notificationResponse.statusMessage);
            if(notificationResponse.isEmailSent|| notificationResponse.isSMSSent|| notificationResponse.isWhatsAppSent){
                if(notificationResponse.isEmailSent && notificationResponse.isSMSSent && notificationResponse.isWhatsAppSent)
                    this.response = 'Email, SMS and Whatsapp message has sent successfully to '+ tObj.Email__c +' and '+tObj.Mobile__c +' respectively.' ;                                        
                else if(notificationResponse.isEmailSent && notificationResponse.isSMSSent && !notificationResponse.isWhatsAppSent)
                    this.response = 'Email and SMS has sent successfully to '+ tObj.Email__c +' and '+tObj.Mobile__c +' respectively.' ;                                        
                else if(notificationResponse.isEmailSent && !notificationResponse.isSMSSent && notificationResponse.isWhatsAppSent)
                    this.response = 'Email and Whatsapp message has sent successfully to '+ tObj.Email__c +' and '+tObj.Mobile__c +' respectively.' ;                                        
                else if(notificationResponse.isEmailSent && !notificationResponse.isSMSSent && !notificationResponse.isWhatsAppSent)
                    this.response = 'Email has sent successfully to '+ tObj.Email__c +'.';                
                else if(!notificationResponse.isEmailSent && notificationResponse.isSMSSent && notificationResponse.isWhatsAppSent)               
                  this.response = 'SMS and Whatsapp message has sent successfully to '+tObj.Mobile__c +'.' ;                                        
                else if(!notificationResponse.isEmailSent && notificationResponse.isSMSSent && !notificationResponse.isWhatsAppSent)
                  this.response = 'SMS has sent successfully to '+tObj.Mobile__c +'.' ;                                        
                else
                    this.response = 'Whatsapp message has sent successfully to '+tObj.Mobile__c +'.' ;                                        
            }
            else
                this.response = 'Something went Wrong. Please try again';
        }
        else {
            System.debug('response'+res.getBody());
        }
    }
    
    //End - Send Notification Button     
    
    
    public class ResponseWrapper{
        public string StatusMessage;
        public boolean IsEmailSent;
        public boolean isWhatsAppSent;
        public boolean IsSMSSent;
        public string EmailRespId;
        public string SMSRespId;
        public string Data;        
    }
    public class RequestWrapper{
        public string tin;
        public string userEmailId;
        public string userMobileNumber;
        public list<string> notificationTypeSet=new list<string>();      
    }
}