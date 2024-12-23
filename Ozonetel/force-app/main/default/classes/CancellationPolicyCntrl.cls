/**
* (c) 2016 RedBus
*
* Name           : CancellationPolicyCntrl
* Created Date   : 06 Dec 2016
* Created By     : Sreenivas M
* Purpose        : Controller class for CancellationPolicyPage
*
**/

public class CancellationPolicyCntrl {
    
    /*   public static CancellationResponse cancelResponse{get;set;} 

public static void fetchCanclPolicyDetails()
{
cancelResponse = new CancellationResponse();
HttpResponse res = new HttpResponse();        
Http http = new Http();

String guId= ApexPages.currentPage().getParameters().get('guId'); 
String transactionId= ApexPages.currentPage().getParameters().get('transactionId'); 
String tinNum= ApexPages.currentPage().getParameters().get('tinNum'); 
String email= ApexPages.currentPage().getParameters().get('email'); 
//  String endpoint='http://cmapi-pp.redbus.com/api/Transaction/v2/CancelPolicy?ticket='+tinNum+'&email='+email;      
//   System.debug('endpoint-->'+endpoint);
HttpRequest req = new HttpRequest();
req.setTimeout(120000);

//  req.setEndpoint(System.Label.Cancelation_Policy_URI+tinNum+'&email='+email);
req.setEndpoint(System.Label.Cancelation_Policy_URI+'?orderIdOrOrderUuid='+guId+'&orderItemId='+transactionId);
//  req.setEndpoint(endpoint);
req.setHeader('Channel_Name', 'WEB_DIRECT');
req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
req.setHeader('BusinessUnit', 'BUS');
req.setHeader('Country_Name', 'IND');
req.setHeader('SelectedCurrency', 'INR');
req.setHeader('Content-Type', 'application/json');
req.setHeader('Currency', 'INR');        
req.setMethod('GET');


try
{
res = http.send(req);
string responseValue = res.getBody();

if(res.getStatus()=='OK')
{
cancelResponse = (CancellationResponse)JSON.deserialize( responseValue, CancellationResponse.class);
system.debug('---------resp---------------'+cancelResponse);
}
}
Catch(Exception e)
{
system.debug('---------Exception---------------'+e);
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 

}

}

public class CancellationResponse
{
public boolean IsPartialCancellation{get;set;}
public string zecafepolicy{get;set;}
public cls_cancelpolicy[] cancelPolicy{get;set;}

}


public class cls_cancelpolicy {
public String chargeAssociated{get;set;} //Rs. 2044
public String duration{get;set;}//After 06:00 PM  on 24th Dec
public String RefundAmount{get;set;}
public String percentage{get;set;}
}*/
    
    public static CancellationPolicyResponse cancelResponse{get;set;} 
    public static  string respStatus{get;set;}  
    public static string recId;
    public static string reschedulePolicy{get;set;}
    public CancellationPolicyCntrl(ApexPages.StandardController std)
    {
        
        if(String.isBlank(recId))
            recId = ApexPages.currentPage().getParameters().get('id');
        System.debug('con recId----'+recId);
    }
    public static void fetchCanclPolicyDetails()
    {
        
        cancelResponse = new CancellationPolicyResponse();
        string guId='';
        string busnsUnit='';
        string amountRecvdCurrncy='';
        string comnBusUnit='';
        CancellationPolicyCntrl.IsCancellable();
        guId= ApexPages.currentPage().getParameters().get('guId'); 
        busnsUnit= ApexPages.currentPage().getParameters().get('busnsUnit'); 
        
        if(string.isNotBlank(recId)){
            Order_Items__c ordItem = [Select Business_Unit__c,Guid__c,Order_Id__c,Amount_Recieved_Currency__c,Transaction_Source__c from Order_Items__c Where id=:recId limit 1];
            system.debug('--ordItem--'+ordItem);
            busnsUnit=ordItem.Business_Unit__c;
            comnBusUnit = 'REDBUS_'+busnsUnit.split('_')[1];

            amountRecvdCurrncy=ordItem.Amount_Recieved_Currency__c;
            guId=ordItem.Guid__c;
        }
            string comCurrency;
            String country='IND';
            String selCurrency='INR';
            
          if(string.isNotBlank(comnBusUnit)){
            if('REDBUS_COM'.equalsIgnoreCase(comnBusUnit)){
                comCurrency=amountRecvdCurrncy;
                string busUnit='';
                if('SGD'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_SG';
                }else if('IDR'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_ID';
                }else if('COP'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_CO';
                }else if('PEN'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_PE';
                }else if('MYR'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_MY';
                }else if('USD'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_SG';
                    selCurrency='USD';
                }
               OrderItemTransactionResource__c resource =  OrderItemTransactionResource__c.getValues(busUnit);
                 if (resource != null) {
                    if(resource.Auth_Key__c != null){
                       country = resource.Auth_Key__c;
                    }
                    if(resource.Default_Currency__c !=null){
                     selCurrency=resource.Default_Currency__c;
                    }
                }
                
                if(!'USD'.equalsIgnoreCase(comCurrency) && busUnit!=''){
                  selCurrency= OrderItemTransactionResource__c.getValues(busUnit).Default_Currency__c;
                }
            }else{
                system.debug('--comnBusUnit--'+comnBusUnit);
                OrderItemTransactionResource__c resource = OrderItemTransactionResource__c.getValues(comnBusUnit);
                
                if (resource != null) {
                    if(resource.Auth_Key__c != null){
                       country = resource.Auth_Key__c;
                    }
                    if(resource.Default_Currency__c !=null){
                     selCurrency=resource.Default_Currency__c;
                    }
                }
             
            }
            
        }
        
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setHeader('Country_Name',country);
        req.setHeader('SelectedCurrency',selCurrency);
        req.setEndpoint(System.Label.CAPI_Cancelation_Policy_URI+guId);
        req.setMethod('GET');
        DBLog_Summary__c dbl = new DBLog_Summary__c();  
        dbl.Type__c = 'CAPI Cancellation Policy';
        dbl.SentAt__c = system.now();
        dbl.Request_Data__c =req.getbody()+'--req---'+string.valueof(req)+'Headers-currency--'+req.getHeader('SelectedCurrency')+'---countryname--'+req.getHeader('Country_Name')+'--auth_key--'+req.getHeader('auth_key')+'--Channel_Name--'+req.getHeader('Channel_Name');
        
        try
        {
            res = http.send(req);
            string responseValue = res.getBody();
            respStatus=res.getStatus();
            dbl.Response_Received__c = String.valueOf(res+'---respVal---'+responseValue);  
            if(res.getStatus()=='OK')
            {
                
                system.debug('---res Body---'+res.getBody());
                cancelResponse = (CancellationPolicyResponse)JSON.deserialize( responseValue, CancellationPolicyResponse.class);
                system.debug('--------- cancl resp---------------'+cancelResponse);
                dbl.Response_Received__c = String.valueOf(res+'---respVal---'+responseValue);  
                dbl.Payment_Request_Response_Data__c=string.valueof(cancelResponse);
            }
        }
        Catch(Exception e)
        {
            system.debug('---------Exception---------------'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            dbl.Response_Received__c = String.valueOf(res+'---respVal---'+res.getbody());  
            dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());    
        }
        insert dbl;
    }
    
    public static void IsCancellable(){
        string jsReqBody;
        
        string comnBusUnit='';
        string amountRecvdCurrncy='';
        
        string comCurrency;
        String country='IND';
        String selCurrency='INR';

        if(string.isNotBlank(recId)){
            Order_Items__c ordItem = [Select Business_Unit__c,Order_Item_Reference_No__c,Guid__c,Order_Id__c,Mobile__c,Email__c,Amount_Recieved_Currency__c,Transaction_Source__c from Order_Items__c Where id=:recId limit 1];
            jsReqBody='{"emailId": "'+ordItem.Email__c+'", "ticketNo": "'+ordItem.Order_Item_Reference_No__c+'", "MobileNo":"'+ordItem.Mobile__c+'", "isRescheduled": true, "isAddonCancellation": false, "SeatsToBeCancelled":"" }';
                       
            if(string.isNotBlank(ordItem.Business_Unit__c)){
               comnBusUnit = 'REDBUS_'+ordItem.Business_Unit__c.split('_')[1];
               amountRecvdCurrncy=ordItem.Amount_Recieved_Currency__c;
             }
        }
       
           if(string.isNotBlank(comnBusUnit)){  
            if('REDBUS_COM'.equalsIgnoreCase(comnBusUnit)){
                comCurrency=amountRecvdCurrncy;
                string busUnit='';
                if('SGD'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_SG';
                }else if('IDR'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_ID';
                }else if('COP'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_CO';
                }else if('PEN'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_PE';
                }else if('MYR'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_MY';
                }else if('USD'.equalsIgnoreCase(comCurrency)){
                    busUnit='REDBUS_SG';
                    selCurrency='USD';
                }
                
               OrderItemTransactionResource__c resource = OrderItemTransactionResource__c.getValues(busUnit);
                 if (resource != null) {
                    if(resource.Auth_Key__c != null){
                       country = resource.Auth_Key__c;
                    }
                    if(resource.Default_Currency__c !=null){
                     selCurrency=resource.Default_Currency__c;
                    }
                }
                if(!'USD'.equalsIgnoreCase(comCurrency) && busUnit!=''){
                    String conmBusUnit = 'REDBUS_'+busUnit.split('_')[1];
                    selCurrency= OrderItemTransactionResource__c.getValues(busUnit).Default_Currency__c;
                }
            }else{
            
                 OrderItemTransactionResource__c resource = OrderItemTransactionResource__c.getValues(comnBusUnit);
                
                if (resource != null) {
                    if(resource.Auth_Key__c != null){
                       country = resource.Auth_Key__c;
                    }
                    if(resource.Default_Currency__c !=null){
                     selCurrency=resource.Default_Currency__c;
                    }
                }
          
                //country = OrderItemTransactionResource__c.getValues(comnBusUnit).Auth_Key__c;
                //selCurrency= OrderItemTransactionResource__c.getValues(comnBusUnit).Default_Currency__c;
            }
            
          }
            
        if(Test.isRunningTest())
            jsReqBody='{"emailId":"daulatkarbele33@gmail.com","ticketNo":"TR2H89372464","MobileNo":"917778048680","isRescheduled": true,"isAddonCancellation": false,"SeatsToBeCancelled":""}';
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='IsTicketCancellableURL'];       
        
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        HttpResponse res = new HttpResponse();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setHeader('Country_Name',country);
        req.setHeader('SelectedCurrency',selCurrency);
        req.setMethod('POST');
        req.setBody(jsReqBody);
        req.setEndpoint(APIMData.Endpoint__c);
        res = http.send(req);
        string responseValue = res.getBody();
        integer statusCode=res.getStatusCode();
        System.debug('responseValue-->'+responseValue);
        System.debug('statusCode-->'+statusCode);
        map<string,object> resMap;
        if(responseValue!='')
            resMap= (map<string,object>)JSON.deserializeUntyped(responseValue);
        if(statusCode==200 && responseValue!=''){
            reschedulePolicy=string.valueOf(resMap.get('ReschedulePolicyMsg'));
            System.debug('res mes-->'+resMap.get('ReschedulePolicyMsg'));
        }else if(statusCode==400){
            reschedulePolicy='Reschedule time has been expired.';
        }         
    }
    
    public class Cancelpolicylist
    {
        public string RefundableAmount { get; set; }
        public string chargeAssociated { get; set; }
        public string duration { get; set; }
        public string percentage { get; set; }
        public string ZCafepercent { get; set; }
        public string ZCafeCharge { get; set; }
        public boolean isZCafeApplicable { get; set; }
        public boolean currentSlot { get; set; }
        public string charges { get; set; }
    }
    
    public class CancellationPolicyResponse
    {
        public List <Cancelpolicylist> cancelpolicylist { get; set; }
        public boolean isPartialCancellationAllowed { get; set; }
        public boolean isZcafeApplied { get; set; }
        public integer zcafeDuration { get; set; }
        public boolean zcafeSponsoredByRedbus { get; set; }
        public string zcafePolicy { get; set; }
        public boolean bookedViaTCP { get; set; }
    }    
}