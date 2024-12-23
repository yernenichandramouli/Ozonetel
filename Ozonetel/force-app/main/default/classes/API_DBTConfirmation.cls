/*
* Name           : API_DBTConfirmation
* Created Date   : 14 Aug 2020
* Created By     : Veeramanikanta R
* Purpose        : API to Confirm DBT Transactions
* Test class     : API_DBTConfirmationTest
*/
@RestResource(urlMapping='/redBus/DBTConfirmation/*')
global without sharing class API_DBTConfirmation
{   
    @HttpPost
    global static Response DBTConfirm()
    {  
        Response resp=new Response();               
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
       // string jsonBody=req.requestBody.toString();
       // string jsonBOdy='{"bankName":"bca","voucherId":"1233","amount":200,"createdDate":"2020-08-17T00:00:00Z"}';
       // string jsonBody='{"bankName":"bca","voucherId":"1233","amount":200,"createdDate":"2020-08-17"}';
       string jsonBOdy=req.requestBody.toString();
        Request  reqObj= (Request)JSON.deserialize(jsonBody,Request.class); 
     
        if(string.isBlank(reqObj.bankName) || reqObj.amount==null || string.isBlank(reqObj.createdDate)){         
          resp.message='Something is missing!! Bank Name, Amount and Createddate are mandatory';
          resp.statusCode=200.22;
        }else{
        System.debug('resp-->'+string.valueOf(resp));
        DBTConfirmGeneric dbCf=new DBTConfirmGeneric();
        resp=dbCf.voucherMatch('API',reqObj.voucherId,reqObj.bankName,reqObj.amount,reqObj.createdDate+'T00:00:00Z');        
        }    
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c = 'DBT API';
        dbl.Request_Data__c=jsonBody;
        dbl.Response_Received__c=string.valueOf(resp);
        insert dbl;        
        return resp;    
    }  
    
    global class Request{
        public string voucherId;
        public string bankName;
        public decimal amount;
        public string createdDate;      
    }  
    
    global class Response{
        global string message;
        global decimal statusCode;
    }       
}