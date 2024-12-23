/*
* Name           : UPIController
* Created Date   : 01 May 2019
* Created By     : Veeramanikanta R
* Purpose        : To Refund UPI failures to process manually 
* Test class     : UPIControllerTest
*/
public class UPIController {    
    public string vpa{get;set;}
    public string tId{get;set;}
    public API_EndPoints__mdt APIMData;
    public string genericEndpoint;
    public string refStReq{get;set;}
    public string refStResp{get;set;}
    public string refAmtStResp{get;set;}
    public string refAmount{get;set;}
    public string pgTransactionId{get;set;}
    public string pgOrderId{get;set;}
    public Order_Items__c ordItObj{get;set;}
    public string trexOrderItmId{get;set;}
    public boolean enableRefund{get;set;}
    public boolean disInputs{get;set;}
    public user uObj{get;set;}
    public boolean refInitBt{get;set;}
    public string InitRequest;
    public set<string> payUUids;
    public List<Orders__c> ordLs;
    public set<string> transIds;
    
    
    public UPIController(){
        vpa='';
        refAmount='';
        pgTransactionId='';
        pgOrderId='';
        trexOrderItmId='';
        ordItObj=new Order_Items__c();
        ordLs=new List<Orders__c>();
        disInputs=true;
        List<Order_Items__c> oLs=new List<Order_Items__c>();
        oLs=[select id,Payment_Details__c,Order_Id__c from Order_Items__c where id=:Apexpages.currentpage().getparameters().get('id')];
        if(!oLs.isEmpty()){
            transIds=new set<string>();
            Map<string,object> payMap=(Map<string,object>)JSON.deserializeUntyped(oLs[0].Payment_Details__c);
            for(Order_Items__c ort:[select id,Guid__c from Order_Items__c where Order_Id__c=:oLs[0].Order_Id__c]){
                transIds.add(ort.Guid__c);
            }
            List<Object> payList=(List<Object>)PayMap.get('paymentItemList');
            disInputs=false;
            System.debug('payList-->'+payList);
            payUUids=new set<string>();
            for(object o:payList){
                string uuId='';
                map<string,object> pm=(map<string,object>)o;
                System.debug('pm-->'+pm.get('uuid'));  
                uuId=string.valueOf(pm.get('uuid'));
                payUUids.add(uuId);            
            }
            System.debug('payUUids-->'+payUUids); 
            genericEndpoint= [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'].Endpoint__c;
            uObj=[select id,Phone,MobilePhone,email from user where id=:UserInfo.getUserID()];
        }
        
    }
    
    public Object RefundStatusCheck()
    {
        vpa=vpa.trim();
        refAmount=refAmount.trim();
        pgTransactionId=pgTransactionId.trim();
        If(vpa=='' || refAmount=='' || pgTransactionId==''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter all values'));
        }else{
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            headers.put('Source','SALESFORCE');
            headers.put('Authorization','Bearer j1QDNJnu8kaSqkoJVVm_MQ');
            headers.put('Country_Name','IND');
            list<HeadersWrapper> hlist=new list<HeadersWrapper>();
            for(string o:headers.keyset()){                     
                hlist.add(new HeadersWrapper(o,headers.get(o))); 
            }
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);  
            // UPIRefundWrapper urw=new UPIRefundWrapper();
            string upiBody='{"r_a":"'+refAmount+'","c_vpa":"'+vpa+'","t":"'+pgTransactionId+'"}'; 
            upiBody=json.serialize(upiBody);  
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='UPIRefundStatusCheck'];
            string jsonB='{"action":"POST","body":'+upiBody+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
            System.debug('josnB-->'+jsonB);
            HttpRequest httpReq= new HttpRequest();
            httpReq = HttpRequestUtil.populateHeaders(httpReq);          
            httpReq.setMethod('POST');
            httpReq.setEndpoint(genericEndpoint);
            httpReq.setBody(jsonB);
            Continuation con = new Continuation(120);         
            con.continuationMethod='RefundStatusCheckProcess'; 
            System.debug('httpReq....'+httpReq);
            this.refStReq= con.addHttpRequest(httpReq);
            return con;
        }
        return null;
    }  
    public Object RefundStatusCheckProcess(){
        try{
            HttpResponse response = Continuation.getResponse(this.refStReq);
            refStResp=response.getBody();
            System.debug('refStResp-->'+refStResp);
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(refStResp);      
            string mockResp='{message=Transaction Already exists, status=false}';
            System.debug('resObj-->'+resObj);
            System.debug('sss-->'+resObj.get('status'));
            if(resObj.get('status')==true){
                enableRefund=true;
                disInputs=true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'This amount can be refundable'));
            }else{
                enableRefund=false;
                disInputs=true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,string.valueOf(resObj.get('message'))));
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Occured. Please try again/contact Admin'));
        }
        return null;   
    }  
    public Object RefundInitiate(){
        pgOrderId=pgOrderId.trim();
        trexOrderItmId=trexOrderItmId.trim();
        If(pgOrderId=='' || trexOrderItmId==''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter all values'));
        }else if(!payUUids.contains(pgOrderId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You entered wrong PG Order id, Please enter correcct one!!'));
        }else if(!transIds.contains(trexOrderItmId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You entered wrong Trex Order Items id, Please enter correcct one!!'));
        }else{
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='UPIRefundProcess'];
            UPIRefundWrapper urw=new UPIRefundWrapper(pgOrderId,pgTransactionId,uObj.email,refAmount,trexOrderItmId,vpa);
            string refInJs=json.serialize(urw);  
            refInJs=json.serialize(refInJs);  
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            headers.put('Source','OMS');
            headers.put('Authorization','Bearer MAfuiy0u7EWkwZUkrLY-kA');
            headers.put('Country_Name','IND');

            list<HeadersWrapper> hlist=new list<HeadersWrapper>();
            for(string o:headers.keyset()){                     
                hlist.add(new HeadersWrapper(o,headers.get(o))); 
            }
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);  
            string jsonB='{"action":"POST","body":'+refInJs+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
            System.debug('josnB-->'+jsonB);
            HttpRequest httpReq= new HttpRequest();
            httpReq = HttpRequestUtil.populateHeaders(httpReq);          
            httpReq.setMethod('POST');
            httpReq.setEndpoint(genericEndpoint);
            httpReq.setBody(jsonB);
            InitRequest=httpReq.getBody();
            Continuation con = new Continuation(120);         
            con.continuationMethod='RefundInitiateProcess'; 
            System.debug('httpReq....'+httpReq);
            this.refStReq= con.addHttpRequest(httpReq);
            return con;  
        }       
        return null; 
    }  
    public Object RefundInitiateProcess(){
        DBLog_Summary__c dbLog=new DBLog_Summary__c();
        dbLog.type__c='UPI Refund';
        try{
            dbLog.Request_Data__c=InitRequest;        
            HttpResponse response = Continuation.getResponse(this.refStReq);
            refAmtStResp=response.getBody();
            dbLog.Response_Received__c=refAmtStResp;
            // string mockResp='{"publishStatus":"SUCCESS","errors":""}';
            map<string,object> resInObj= (map<string,object>)JSON.deserializeUntyped(refAmtStResp);
            System.debug('ini Amut-->'+refAmtStResp);
            //System.debug('st--->'+resInObj.get('status'));      
            if(resInObj.get('publishStatus')=='SUCCESS'){
                refInitBt=true;
                dbLog.Orders_Process_Status__c='Success';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully published into Kafka and will be credited into customer within 10 min'));                
            }else{
                dbLog.Orders_Process_Status__c='Fail';
                refInitBt=false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Unable to publish into Kafka, Please try again!!'));
            }
        }catch(Exception e){
            dbLog.Orders_Process_Status__c='Exception';
            dbLog.Exception_Description__c=String.valueOf(e);
        }
        insert dbLog;                
        return null;        
    }  
    
    public class HeadersWrapper{       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
    
    public class UPIRefundWrapper{
        public string d_t='REFUND';
        public string o;
        public string t;
        public string tn_a;
        public string t_s='1';
        public string r_s='INITIATED';
        public string cntry='INDIA';
        public string r_ib='SF';
        public string r_t='ONLINE';
        public string r_pb;
        public string r_a;
        public string r_rsn='User Cancellation';
        public string r_refId;
        public string t_bn;
        public UPIRefundWrapper(string o,string t,string r_pb,string r_a,string r_refId,string t_bn){
            this.o=o;
            this.t=t;         
            this.r_pb=r_pb;
            this.r_a=r_a;
            this.r_refId=r_refId;
            this.t_bn=t_bn;
        }   
    }
}