/*
* Name           : PostGresConnect
* Created Date   : 18 Sep 2017
* Created By     : Veeramanikanta R
* Purpose        : Used for display recharge itmes detailed info on VF
* Test class     : PostGresConnectTest
*/

public class PostGresConnect{
    
    public String orderId;
    public PostGres_Data__c pData;
    public boolean validGFT{get;set;}
    public String sMessage{get;set;}
    public boolean InitiateRefundButton{get;set;}
    public boolean wfttogftRefundButton{get;set;}
    public boolean checkWftToGftButton{get;set;}
    public PostGresConnect(ApexPages.StandardController controller) {
        
        orderId=ApexPages.currentPage().getParameters().get('orderId');
        String recId=ApexPages.currentPage().getParameters().get('id');
        validGFT=false;
        InitiateRefundButton=false;
        wfttogftRefundButton=false;
        checkWftToGftButton=false;
        pData=[select id,name,Order_Id__c from PostGres_Data__c where id=:recId];
        getTransactionStatus();
        
    }
    
    public string data{get;set;}
    public ResponseWrapper respWrapper{get;set;}
    public TransactionStatusWrapper tWrapper{get;set;}
    
    public void getOrders(){
        
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RechargeItems'];
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);   
        req.setHeader('Channel_Name','MOBILE_APP');  
        req.setHeader('BusinessUnit','RECHARGE');            
        req.setHeader('auth_key', '487a342c-92f1-41ae-81fa-aaa5120f6bb3');
        req.setHeader('Accept', 'application/msgpack1');
        req.setMethod('GET');
        req.setEndpoint(APIMData.Endpoint__c+pData.Order_Id__c);      
        
        try{
            res=h.send(req);
            System.debug('order resp'+res.getbody());  
            data=res.getBody();
            // data='{"OperatorType":1,"Plan":"2G","CreatedDate":"2017-08-17T06:52:47.918619Z","RechargeAmount":15,"TransactionRefNo":"","OperatorRefNo":"","RechargeStatus":"","OperatorName":"Airtel","EmailId":"","MobileNo":"9686548919","OrderId":592,"OrderStatus":"ORDER_TRANS_FAIL","PaymentItems":[{"id":413,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":20,"type_of_payment":"ONLINE","additonal_details":""}]}';
            //  data='{"OperatorType":1,"Plan":"2G","CreatedDate":"2017-08-17T06:52:47.918619Z","RechargeAmount":15,"TransactionRefNo":"","OperatorRefNo":"","RechargeStatus":"","OperatorName":"Airtel","EmailId":"","MobileNo":"9686548919","OrderId":592,"OrderStatus":"ORDER_TRANS_FAIL","PaymentItems":[{"id":413,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":20,"type_of_payment":"ONLINE","additonal_details":""},{"id":414,"create_date":"2017-07-19T15:03:26.350738Z","status":"PI_CREATE","price":30,"type_of_payment":"DIRECT","additonal_details":""}]}';
            if(data!=''){
                respWrapper= (ResponseWrapper)System.JSON.deserialize(data,ResponseWrapper.class);
                string s=respWrapper.EmailId;
                System.debug('respWrapper-->'+respWrapper);
                
                respWrapper.OrderStatus= RechargeStatus__c.getValues(respWrapper.OrderStatus).Recharge_Status_Value__c;           
                
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Response.'));
            }
        } catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Get Order API error occured, please contact Admin'+e));
        }
    }
    public void initiateRefund(){
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();       
        gen.writeStringField('OrderId', pData.Order_Id__c);
        gen.writeEndObject();
        String orderJson= gen.getAsString();
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Recharge_InitiateRefund'];
        
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);   
        req.setHeader('Channel_Name','SFA');  
        req.setHeader('BusinessUnit','RECHARGE');            
        req.setHeader('auth_key', 'a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
        req.setHeader('Accept', 'application/msgpack1');
        // req.setMethod('POST');
        req.setMethod('GET');
        req.setEndpoint(APIMData.Endpoint__c+pData.Order_Id__c);  
        // req.setBody(orderJson); 
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Request_Data__c=pData.Order_Id__c;
        
        try{ 
            res=h.send(req); 
            System.debug('response-->'+res+'....'+res.getBody()+'...'+String.isBlank(res.getbody()));
            
            string response=res.getBody();          
            dbl.Type__c = 'Initiate Recharge Refund';
            dbl.Order_Items_Success__c=string.valueof(res.getbody());          
            System.debug('response-->'+res);
            System.debug('response body-->'+res.getbody()); 
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Refund has been done successfully!'));
            String mResp='{"Code":"11.22","Message":"Refund is alreday processed for the provided order id.","DetailedMessage":"Refund is alreday processed for the provided order id.","HttpStatusCode":200}';
            //res.getbody()
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
            if(string.valueof(resObj.get('Code'))=='11.22'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Refund is processed successfully.'));
                InitiateRefundButton=true;
            }
            else if (string.valueof(resObj.get('Code'))=='11.25'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This order is not a valid GFT'));
                InitiateRefundButton=true;
            } 
            else if (string.valueof(resObj.get('Code'))=='11.24'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Refund is already processed'));
                InitiateRefundButton=true;
            }
            else if (string.valueof(resObj.get('Code'))=='11.23'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Refund is failed, Please contact admin'));
                InitiateRefundButton=true;
            }  
            
            
        }catch(Exception e){
            dbl.Type__c = 'Initiate Recharge Refund';
            dbl.Exception_Description__c='Error-->'+e;           
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Initiate Refund error occured, please contact Admin'+e));
        }
        insert dbl;       
        
    }
    
    public void getTransactionStatus(){
        System.debug('calling here');
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Transaction_Status_RC'];
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req);   
        req.setHeader('ORDERID','MR'+pData.Order_Id__c);  
        req.setMethod('GET');
        req.setEndpoint(APIMData.Endpoint__c);  
        
        try{                
            res=h.send(req);               
            System.debug('response 2-->'+res.getbody());
            String response=res.getbody();
            System.debug('response-->'+response);
            System.debug('line');       
            tWrapper= (TransactionStatusWrapper)System.JSON.deserialize(response,TransactionStatusWrapper.class);
            
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'API Failed, Please contact Admin'+e));
        }
        
    }
    
    public void checkValidWFTtoGFT(){
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ValidWFTTOGFT'];
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req); 
        req.setHeader('Channel_Name','SFA');
        req.setHeader('auth_key', '487a342c-92f1-41ae-81fa-aaa5120f6bb3');    
        req.setMethod('GET');
        req.setEndpoint(APIMData.Endpoint__c+pData.Order_Id__c); 
        DBLog_Summary__c dbl = new DBLog_Summary__c(); 
        dbl.Type__c = 'Check WFTorGFT';
        dbl.Request_Data__c=string.valueof(req); 
        
        try{             
            res=h.send(req);  
            System.debug('res-->'+res.getbody());            
            dbl.Order_Items_Success__c=res.getbody();
            
            string responseJ='{"Code":"11.21","Message":"Invalid WFT to GFT case.","DetailedMessage":"Invalid WFT to GFT case.","HttpStatusCode":200}';
            //  Map<string,object> cObj= (Map<string,object>)System.JSON.deserialize(responseJ, Map<string,object>.class);
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
            //map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(responseJ);            
            // System.debug('code-->'+cObj.get('code')); 
            System.debug('code-->'+resObj);
            System.debug('code val-->'+string.valueof(resObj.get('HttpStatusCode')));
            
            if(string.valueof(resObj.get('HttpStatusCode'))=='200'){
                validGFT=true;
                checkWftToGftButton=true;
                sMessage='It\'s a valid WFT to GFT Case';
            }else{            
                sMessage='It\'s an Invalid WFT to GFT Case';
                checkWftToGftButton=true;
            }                        
        }catch(Exception e){
            dbl.Exception_Description__c='Error-->'+e;           
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'API Failed, Please contact Admin'+e));
        }
        insert dbl;        
    }
    
    public void doRefundForValidGFT(){
        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RefundValidGFT'];
        
        HTTP h = new HTTP();
        HttpRequest req= new HttpRequest();
        HTTPResponse res=new HTTPResponse();        
        req = HttpRequestUtil.populateHeaders(req); 
        req.setHeader('Channel_Name','SFA');
        req.setHeader('auth_key', '487a342c-92f1-41ae-81fa-aaa5120f6bb3');        
        req.setMethod('GET');
        req.setEndpoint(APIMData.Endpoint__c+pData.Order_Id__c); 
        
        DBLog_Summary__c dbl = new DBLog_Summary__c(); 
        dbl.Type__c = 'Refund Valid GFT';
        dbl.Request_Data__c=string.valueof(req);  
        
        try{              
            res=h.send(req);
            dbl.Order_Items_Success__c=res.getbody();            
            System.debug('res-->'+res.getbody());
            string responseJ='{"Code":"11.17","Message":"Invalid WFT to GFT case.","DetailedMessage":"Invalid WFT to GFT case.","HttpStatusCode":400}';
            //map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
            System.debug('code-->'+resObj);
            System.debug('code val-->'+string.valueof(resObj.get('Code')));
            
            if(string.valueof(resObj.get('Code'))=='11.17'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Refund is processed successfully.'));
                wfttogftRefundButton=true;
            }else if (string.valueof(resObj.get('Code'))=='11.19'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This order does not have the online payment Item'));
                wfttogftRefundButton=true;
            } 
            else if (string.valueof(resObj.get('Code'))=='11.14'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Request, Amount not debited at PAAS.'));
                wfttogftRefundButton=true;
            } 
            else if (string.valueof(resObj.get('Code'))=='11.15'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed, Unable to update the payment item status.'));
                wfttogftRefundButton=true;
            } 
            else if (string.valueof(resObj.get('Code'))=='11.16'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed, Something went wrong while processing refund.'));
                wfttogftRefundButton=true;
            }       
        }catch(Exception e){
            dbl.Exception_Description__c='Error-->'+e;           
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'API Failed, Please contact Admin'+e));
        }        
        insert dbl;
        
    }
    
    public class ResponseWrapper{
        public Integer OperatorType{get;set;}   
        public String Plan{get;set;}  
        public String CreatedDate{get;set;}   
        public decimal RechargeAmount{get;set;}  
        public String TransactionRefNo{get;set;} 
        public String OperatorRefNo{get;set;}    
        public String RechargeStatus{get;set;}  
        public String OperatorName{get;set;} 
        public String EmailId{get;set;}  
        public String MobileNo{get;set;} 
        public Integer OrderId{get;set;}  
        public String OrderStatus{get;set;} 
        public List<PaymentItems> PaymentItems{get;set;}   
    }
    public class PaymentItems {
        public Integer id{get;set;}   
        public String create_date{get;set;}   
        public String status{get;set;}   
        public decimal price{get;set;}  
        public String type_of_payment{get;set;}   
        public String additonal_details{get;set;}    
    }
    
    public class TransactionStatusWrapper{
        public String Status{get;set;}    
        public Data Data{get;set;}
        public String Error{get;set;}
    }
    public class Data {
        public PaymentStatus PaymentStatus{get;set;}
        //public RefundStatus RefundStatus{get;set;}
    }
    public class PaymentStatus {
        // public String PgTransactionId{get;set;} 
        //  public Integer PaasTransactionId{get;set;}  
        //  public decimal Amount{get;set;} 
        // public String PGType{get;set;}  
        public String GatewayName{get;set;}
        // public String PaymentStatus{get;set;}   
        // public String PaymentMessage{get;set;}  
    }
    /*  public class RefundStatus {
public String txnId{get;set;}
public String orderId{get;set;}
public List<refundItemList> refundItemList{get;set;}
}
public class refundItemList{
public string Status{get;set;}
public string amount{get;set;}
public string creationTime{get;set;}
public string processedTime{get;set;}
public string refundRefNo{get;set;}
public string bankRefNo{get;set;}
}*/
    
}