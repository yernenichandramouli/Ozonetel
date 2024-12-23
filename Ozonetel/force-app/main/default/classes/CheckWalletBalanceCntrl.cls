/**
 * (c) 2017 RedBus
 *
 * Name           : CheckWalletBalanceCntrl
 * Created Date   : 11 Oct 2017
 * Created By     : Praveen 
 * Purpose        : Controller class for CheckWalletBalanceCntrl
 *
 **/
 
public class CheckWalletBalanceCntrl{
    
    public static WalletBalanceResponse walletBalResponse{get;set;} 
    public string emailId {get;set;}
    public string phone {get;set;}
    public string userId {get;set;} 
    public string acrecId{get; set;}
    public string acMail{get; set;}
    public string acPhone{get; set;}
    
    public CheckWalletBalanceCntrl(){
    acrecId = ApexPages.currentPage().getParameters().get('id');
    if(string.isNotBlank(acrecId)){
    Account accnt = [select id,Bank_Account_Number__c, AccountNumber,Description,Review__c,PersonEmail,PersonMobilePhone,BankName__c,User_Id__c,IFSCCode__c,BranchName__c,Beneficiary_Name__c,Amount__c from Account where id=:acrecId limit 1];
    acMail=accnt.PersonEmail;
    acPhone=accnt.PersonMobilePhone;
    }
    
    }
    public void fetchWalletBalance()
    {
        walletBalResponse= new WalletBalanceResponse();
        HttpResponse res = new HttpResponse();        
        Http http = new Http();
        
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
        req.setMethod('POST');
          
        emailId = ApexPages.currentPage().getParameters().get('emailId');
        phone= ApexPages.currentPage().getParameters().get('phone');
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();       
        if(string.isNotBlank(acMail)&&string.isNotBlank(acPhone)){
           gen.writeStringField('emailId',acMail );
           gen.writeStringField('phone', acPhone);
        }else{
          gen.writeStringField('emailId',emailId );
          gen.writeStringField('phone', phone);
        }
        gen.writeEndObject();
            
        String walletJson= gen.getAsString();
        
        
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Wallet_Balance_Check'].Endpoint__c;
        //String endPoint = 'http://cmapi-pp.redbus.com/api/Wallet/v1/WalletBalanceCheck';        
      
        try
        {
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            req.setBody(walletJson);           
            
            res=http.send(req);
            System.debug('Response-->'+res.getBody()); 
           
            res = http.send(req);
            string responseValue = res.getBody();
                        
            if(res.getStatus()=='OK')
            {
                walletBalResponse= (WalletBalanceResponse)JSON.deserialize( responseValue, WalletBalanceResponse.class);
                system.debug('----Success Check wallet Balance-----resp---------------'+walletBalResponse);
                if(Test.isRunningTest())
                  new WalletBalanceResponse();
            }
        }
        Catch(Exception e)
        {
              system.debug('------- Check wallet Balance --Exception---------------'+e);
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
       
    }
    
    public class WalletBalanceResponse
    {        
        public Data Data { get; set; }
        public string WalletId { get; set; }
        public Status Status { get; set; }
        public string ResponseMessage { get; set; }   
        
        public WalletBalanceResponse()
        {
         System.debug('All..'+Data +WalletId +Status +ResponseMessage );
        }
    }
    
    public class Data
    {
        public double totalBalance { get; set; }
        public double offerBalance { get; set; }
        public double coreBalance  { get; set; }        
    }
    
    public class Status
    {
        public integer code { get; set; }
        public integer statusCode { get; set; }
        public string error { get; set; }
        public string statusMessage { get; set; }
        public string type { get; set; }

    }

}