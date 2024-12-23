/**
 * (c) 2016 RedBus
 *
 * Name           : HttpRequestUtil
 * Created Date   : 15 Dec 2016
 * Created By     : Sreenivas M
 * Purpose        : Utility class to populate HttpRequest headers and data
 *
 **/
 
public class HttpRequestUtil
{
 public static HttpRequest populateHeaders(HttpRequest req)
 {
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('BusinessUnit', 'BUS');
        req.setHeader('Country_Name', 'IND');
        req.setHeader('SelectedCurrency', 'INR');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Currency', 'INR');
        return req;
 }
 
 public static HttpRequest populateCMAPIHeaders(HttpRequest req,string BusUnit)
 {  
        string countryName;
        string selCurrency;
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'WEB_DIRECT');
        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
        req.setHeader('BusinessUnit', 'BUS');
        req.setHeader('Country_Name', 'IND');
        req.setHeader('SelectedCurrency', 'INR');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Currency', 'INR');
        system.debug('--BusUnit--'+BusUnit);
        if(string.isNotblank(BusUnit)){
        String comBusUnit = 'REDBUS_'+BusUnit.split('_')[1];
        OrderItemTransactionResource__c values = OrderItemTransactionResource__c.getValues(comBusUnit);
        if (values !=null){
            if(values.Auth_Key__c != null){
               countryName = OrderItemTransactionResource__c.getValues(comBusUnit).Auth_Key__c;
               req.setHeader('Country_Name', countryName);
            }
            
            if(values.Default_Currency__c != null){
              selCurrency= OrderItemTransactionResource__c.getValues(comBusUnit).Default_Currency__c; 
               req.setHeader('SelectedCurrency', selCurrency);
               req.setHeader('Currency', selCurrency);     
            }
          }
        } 
       
        return req;
 }
 
 public static HttpRequest populateCAPIHeaders(HttpRequest req)
 {
        
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'SFA');
        req.setHeader('auth_key','a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
        req.setHeader('Country_Name', 'IND');
        req.setHeader('SelectedCurrency', 'INR');
        req.setHeader('BusinessUnit', 'BUS');
        req.setHeader('Content-Type', 'application/json');
        return req;
 }
 public static HttpRequest populateCAPICountryHeaders(HttpRequest req,string BusUnit,string country)
 {
        
        req.setTimeout(120000);
        req.setHeader('Channel_Name', 'SFA');
        req.setHeader('auth_key','a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
        req.setHeader('Country_Name', 'IND');
        req.setHeader('SelectedCurrency', 'INR');
        req.setHeader('BusinessUnit', 'BUS');
        req.setHeader('Content-Type', 'application/json');
        
        if(BusUnit.contains('_PE') || 'Peru'.equalsIgnoreCase(country)){
           req.setHeader('Country_Name', 'PER');
           req.setHeader('SelectedCurrency', 'PEN');
           req.setHeader('Currency', 'PEN');
         }
           
         if(BusUnit.contains('_CO') || 'Colombia'.equalsIgnoreCase(country)){
           req.setHeader('Country_Name', 'COL');
           req.setHeader('SelectedCurrency', 'COP');
           req.setHeader('Currency', 'COP');
         }
        /* 
         if(BusUnit.contains('_MY') || 'Malaysia'.equalsIgnoreCase(country)){
           req.setHeader('Country_Name', 'MYS');
           req.setHeader('SelectedCurrency', 'MYR');
         }
        
         
          if(BusUnit.contains('_SG') || 'Singapore'.equalsIgnoreCase(country)){
           req.setHeader('Country_Name', 'SGP');
           req.setHeader('SelectedCurrency', 'SGD');
         }
         
          if(BusUnit.contains('_ID') || 'Indonesia'.equalsIgnoreCase(country)){
           req.setHeader('Country_Name', 'IDN');
           req.setHeader('SelectedCurrency', 'IDR');
         }*/
       
        return req;
 }
 
  public static HttpRequest populateBusHireHeaders(HttpRequest req)
 {
        
        req.setTimeout(120000);
        req.setHeader('client_id','RB_SFA');
        req.setHeader('Content-Type','application/json');
        req.setHeader('client_token','cJyuerXxR-ePPlkll3Z5K-yemvR89Y2g-p90qwgE5mJ-gdH28injYY');
        return req;
 }
 
  public static HttpRequest populateAckoInsuranceHeaders(HttpRequest req)
 {
        
        req.setTimeout(120000);
        req.setHeader('Content-Type','application/json'); 
        req.setHeader('Cache-Control','no-cache');  
        req.setHeader('AuthToken','Qiq61FzmiEirAXkjIdyh6MA');
        req.setHeader('Country','IND');
        return req;
 }
 
  public static HttpRequest populateDisbursalHeaders(HttpRequest req)
 {
        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('AuthToken','GDHFGHF5645HJGJGJ564564JHGJGHKRG5654677523324325');
        req.setTimeout(120000); 
        return req;
 }
 
 public static HttpRequest populatePassUpdatePGTxnIdHeaders(HttpRequest req)
 {
        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('AuthToken','kjgjkgjkg3873639843g3dn93893dbffv983903bjbxbzcxhcx9h');
        req.setTimeout(120000); 
        return req;
 }
 
 //This method is used to create one smsdata
 public static  HttpRequestWrappersUtil.Smsdata prepareSMSReqData(String tempName,String jsonData,String complexity,String senId,String mobile,String msg,Boolean isuniCode,String lang,Boolean isTempUsed)
 {
 
    HttpRequestWrappersUtil.CustomMessageDetails custMsg = new HttpRequestWrappersUtil.CustomMessageDetails();
    custMsg.TemplateName = tempName;
    custMsg.DataJsonStr = jsonData;
    custMsg.DataComplexity = String.isNotBlank(complexity)?complexity:'KVP';
    
    HttpRequestWrappersUtil.SMSMessage smsMsg =new HttpRequestWrappersUtil.SMSMessage();
    smsMsg.senderId  = String.isNotBlank(senId)?senId:'REDBUS';
    smsMsg.mobileNo = mobile;
    smsMsg.message = String.isNotBlank(msg)?msg:'';
    smsMsg.isUnicodeSms = isuniCode;
    smsMsg.CustomMessageDetails = custMsg;
    
    HttpRequestWrappersUtil.SMSRequest smsReq= new HttpRequestWrappersUtil.SMSRequest();
    smsReq.SMSMessage=smsMsg;
    
    HttpRequestWrappersUtil.Smsdata smsdataReq = new HttpRequestWrappersUtil.Smsdata();
    smsdataReq.SMSRequest = new List<HttpRequestWrappersUtil.SMSRequest>{smsReq};
    smsdataReq.NotificationType  ='SMS';
    smsdataReq.Language  =String.isNotBlank(lang)?lang:'en';
    smsdataReq.IsTemplateUsedForMessage  =isTempUsed;
    
   /* HttpRequestWrappersUtil.SendSMSEMailReqWrapper smsEmailReq = new HttpRequestWrappersUtil.SendSMSEMailReqWrapper();
    smsEmailReq.type= new List<String>{'smsdata'};
    smsEmailReq.smsdata = smsdataReq;
   */
   
    return smsdataReq;
 
 
 }
 
 //This method is used to create email data
 public static HttpRequestWrappersUtil.Emaildata prepareEmailReqData(String tempName,String jsonData,String complexity,String sub,String sen,String recv,String body,String dispName,String emLang,String lang,Boolean isTempUsed)
 {
 
    HttpRequestWrappersUtil.CustomMessageDetails custMsg = new HttpRequestWrappersUtil.CustomMessageDetails();
    custMsg.TemplateName = tempName;
    custMsg.DataJsonStr = jsonData;
    custMsg.DataComplexity = String.isNotBlank(complexity)?complexity:'KVP';
    
    HttpRequestWrappersUtil.EmailServiceRequest emailSerReq =new HttpRequestWrappersUtil.EmailServiceRequest();
    emailSerReq.Subject  =sub;
    emailSerReq.Sender =sen;
    emailSerReq.Receiver = recv;
    emailSerReq.SenderDisplayName =dispName;
    emailSerReq.language =emLang;
    emailSerReq.CustomMessageDetails =custMsg;
    
    HttpRequestWrappersUtil.EmailRequest emailReq= new HttpRequestWrappersUtil.EmailRequest();
    emailReq.EmailServiceRequest =emailSerReq;
    
    HttpRequestWrappersUtil.Emaildata emaildataReq = new HttpRequestWrappersUtil.Emaildata();
    emaildataReq.EmailRequests = new List<HttpRequestWrappersUtil.EmailRequest>{emailReq};
    emaildataReq.NotificationType  ='EMAIL';
    emaildataReq.Language  =String.isNotBlank(lang)?lang:'en';
    emaildataReq.IsTemplateUsedForMessage  =isTempUsed;
   /* 
    HttpRequestWrappersUtil.SendSMSEMailReqWrapper smsEmailReq = new HttpRequestWrappersUtil.SendSMSEMailReqWrapper();
    smsEmailReq.type= new List<String>{'smsdata'};
    smsEmailReq.smsdata = smsdataReq;
   */
    return emaildataReq;
 
 
 }
 
 //This method is used to create one SMS Request
  public static HttpRequestWrappersUtil.SMSRequest prepareSMSRequest(String tempName,String jsonData,String complexity,String senId,String mobile,String msg,Boolean isuniCode)
 {
    HttpRequestWrappersUtil.CustomMessageDetails custMsg = new HttpRequestWrappersUtil.CustomMessageDetails();
    custMsg.TemplateName = tempName;
    custMsg.DataJsonStr = jsonData;
    custMsg.DataComplexity = String.isNotBlank(complexity)?complexity:'KVP';
    
    HttpRequestWrappersUtil.SMSMessage smsMsg =new HttpRequestWrappersUtil.SMSMessage();
    smsMsg.senderId  = String.isNotBlank(senId)?senId:'REDBUS';
    smsMsg.mobileNo = mobile;
    smsMsg.message = String.isNotBlank(msg)?msg:'';
    smsMsg.isUnicodeSms = isuniCode;
    smsMsg.CustomMessageDetails = custMsg;
    
    HttpRequestWrappersUtil.SMSRequest smsReq= new HttpRequestWrappersUtil.SMSRequest();
    smsReq.SMSMessage=smsMsg;
    return smsReq;
 }
 
 //This method is used to create one EMail Request
 public static HttpRequestWrappersUtil.EmailRequest prepareEmailRequest(String tempName,String jsonData,String complexity,String sub,String sen,String recv,String body,String dispName,String emLang)
 {
    HttpRequestWrappersUtil.CustomMessageDetails custMsg = new HttpRequestWrappersUtil.CustomMessageDetails();
    custMsg.TemplateName = tempName;
    custMsg.DataJsonStr = jsonData;
    custMsg.DataComplexity = String.isNotBlank(complexity)?complexity:'KVP';
    
    HttpRequestWrappersUtil.EmailServiceRequest emailSerReq =new HttpRequestWrappersUtil.EmailServiceRequest();
    emailSerReq.Subject  =sub;
    emailSerReq.Sender =sen;
    emailSerReq.Receiver = recv;
    emailSerReq.SenderDisplayName =dispName;
    emailSerReq.language =emLang;
    emailSerReq.CustomMessageDetails =custMsg;
    
    HttpRequestWrappersUtil.EmailRequest emailReq= new HttpRequestWrappersUtil.EmailRequest();
    emailReq.EmailServiceRequest =emailSerReq;
    return emailReq;
 }
 
//This method is used to create a whatsapp request
public static HttpRequestWrappersUtil.WhatsAppRequestWrapper prepareWhatsappRequest(String tempName,String jsonData,Integer complexity,String tin,String mobNum,String emLang)
 {
    HttpRequestWrappersUtil.MessageDetails msgDet = new HttpRequestWrappersUtil.MessageDetails();
    msgDet.TemplateName =tempName;
    msgDet.DataJsonStr=jsonData;
    msgDet.DataComplexity =String.isNotBlank(String.valueof(complexity))?complexity:2;
    msgDet.Language = String.isNotBlank(emLang)?emLang:'en';
    msgDet.TIN =tin;
    
    HttpRequestWrappersUtil.Address addr = new HttpRequestWrappersUtil.Address();
    addr.whatsapp_number = mobNum;
    addr.links = '';
   
    HttpRequestWrappersUtil.WhatsAppRequestWrapper whatsappReq = new HttpRequestWrappersUtil.WhatsAppRequestWrapper();
    whatsappReq.channels = new List<String>{'whatsapp'};
    whatsappReq.address = addr;
    whatsappReq.AttachmentDetails= new HttpRequestWrappersUtil.AttachmentDetails();
    whatsappReq.MessageDetails = msgDet;
    return whatsappReq;
  
 }
 
 public static HttpRequest populateRailPNRHeaders(HttpRequest req)
 {
        req.setTimeout(120000);
        req.setHeader('os', 'Android');
         req.setHeader('appversion', '9.5.0 Dev');
        req.setHeader('AppVersionCode', '95000');
        req.setHeader('DeviceId', '28f0c5badc368b19');
        //req.setHeader('regid', 'fTK3PtEJh0k:APA91bGmlsBPdzUfgvDBP8UuGGKSlGjaFQQZ8Vra8Xfgv4bNmxeoPkumBn_rqfpDqUdRVClgPkpcAQTjEaDm_GDGWOq15Z5Ij6lUFRMqQzYm0Gpnel39pZ8A4xSpqFexZP53ozWPZl0CIp7HRxm9XYA63wtxEQ8M6Q');
        // req.setHeader('AuthToken', 'f37dcf1e-39e6-4372-b34a-9da6dc123507,373d2ef7-c7a5-4389-a5dc-b018d5f3eb5f,565d9ef4-744c-441f-b75a-89fdb96caa56,ea723ac7-8993-4993-8475-c089516fed43');
        req.setHeader('OSVersion', '7.1.2');
        req.setHeader('Channel_Name', 'MOBILE_APP');
        req.setHeader('PigeonDID', 'c6033f28418cf9a7b0a5d2c02aa82bb2');
        req.setHeader('Accept', 'application/json');          
        req.setHeader('auth_key', '487a342c-92f1-41ae-81fa-aaa5120f6bb3');
        req.setHeader('BusinessUnit', 'RAILS');
        req.setHeader('Country_Name', 'IND');
        req.setHeader('SelectedCurrency', 'INR');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Currency', 'INR');
        return req;
 }
  public static HttpRequest populateCapiPayatBusHeaders(HttpRequest req)
 {
        req.setTimeout(120000);
        req.setHeader('Country_Name', 'PER');
        req.setHeader('auth_key', '2d00da61-5b39-4b2a-899f-016c2ae51319');
        req.setHeader('country', 'peru');
        req.setHeader('currency', 'PEN');
        req.setHeader('SelectedCurrency', 'PEN');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Channel_Name', 'MOBILE_WEB');
        req.setHeader('BusinessUnit', 'BUS');
        return req;
 }

public static HttpRequest populatesgmySendNotification(HttpRequest req){
       req.setTimeout(120000);
       req.setHeader('Language','en');
       req.setHeader('Channel_Name','SFA');
       req.setHeader('auth_key','487a342c-92f1-41ae-81fa-aaa5120f6bb3');
       req.setHeader('BusinessUnit','ACTIVITIES');
       req.setHeader('Accept','application/json');
       req.setHeader('Content-Type','application/json');
       return req;
}
}