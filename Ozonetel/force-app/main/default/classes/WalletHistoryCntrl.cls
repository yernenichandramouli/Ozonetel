/**
 * (c) 2016 RedBus
 *
 * Name           : WalletHistoryCntrl
 * Created Date   : 21 Dec 2016
 * Created By     : Praveen 
 * Purpose        : Controller class for WalletHistoryDetails
 *
 **/
 
public class WalletHistoryCntrl {

    public static list<WalletHistoryResponse> walletHisResponse{get;set;} 
    public string emailId {get;set;}
    public string phone {get;set;}
    public string userId {get;set;} 
    public string recId{get;set;}
    public string phoneNum{get;set;}
    public string acEmailId{get;set;}
    public string tendgtPhoneno{get;set;}
    public boolean sendendpiont{get;set;}
    public string accCode{get;set;}
    public WalletHistoryCntrl(ApexPages.StandardController controller){
    recId = ((Account)controller.getRecord()).id;
    sendendpiont=false;
    //recId = ApexPages.currentPage().getParameters().get('id');
    list<Account> listacc= [select id,PersonEmail,email_copy__c,PersonMobilePhone,CountryCode__c,Phone_10_Digits__c from Account where id=:recId];
    for(Account acc:listacc){
      phoneNum=acc.PersonMobilePhone;
      acEmailId=acc.PersonEmail;
      tendgtPhoneno=acc.Phone_10_Digits__c;
      accCode=acc.CountryCode__c;
    }
    
    if(string.isNotBlank(phoneNum)){
     phoneNum=phoneNum;
    }else if(string.isNotBlank(tendgtPhoneno) && 'IND'.equalsIgnorecase(accCode)){
      phoneNum='91'+accCode;
    }
   
   system.debug('---id---'+recId);
   
   } 
    
    public void fetchWalletHistoryDetails()
    {
        walletHisResponse = new List<WalletHistoryResponse>();
        HttpResponse res = new HttpResponse();        
        Http http = new Http();
        
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
        req.setMethod('GET');
          
        emailId = ApexPages.currentPage().getParameters().get('emailId');
        phone= ApexPages.currentPage().getParameters().get('phone');
        userId=ApexPages.currentPage().getParameters().get('userId');
        system.debug('---emails---'+acEmailId+'----'+emailId);
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='WalletHistory'].Endpoint__c;
         //lightning golbal action
          system.debug('---'+acEmailId);
        if(string.isNotBlank(phoneNum) ) {
            sendendpiont=true;
             req.setEndpoint(endPoint+'acEmailId=&phone='+phoneNum);
             system.debug('---'+acEmailId+'--'+phoneNum);
        }else if(string.isNotBlank(phone)){
        
         req.setEndpoint(endPoint+'emailId=&phone='+phone);
        }
        
        //We are considering only mobile number currently for all wallet related details
       /* if(String.isNotBlank(userId)&&!!sendendpiont) {
        system.debug('--65-userid--'+sendendpiont);
             req.setEndpoint(endPoint+'emailId=&phone='+phone+'&userId='+userId);
        }
        else if (!!sendendpiont){
                 system.debug('--69-userid--'+sendendpiont);

             req.setEndpoint(endPoint+'emailId=&phone='+phone);
        }*/
      
        try
        {
            res = http.send(req);
            string responseValue = res.getBody();
                        
            if(res.getStatus()=='OK')
            {
                walletHisResponse = (List<WalletHistoryResponse>)JSON.deserialize( responseValue, List<WalletHistoryResponse>.class);
                system.debug('----Success wallet history-----resp---------------'+walletHisResponse);
                if(Test.isRunningTest())
                  new WalletHistoryResponse();
            }
        }
        Catch(Exception e)
        {
              system.debug('-------wallet history--Exception---------------'+e);
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
       
    }
    
    public class WalletHistoryResponse
    {
        public string TransactionDate { get; set; }
        public string TransactionMode { get; set; }
        public string TransactionType { get; set; }
        public string Amount { get; set; }
        public string ExprationDate { get; set; }
        public string OfferName { get; set; }
        public string AmountUsed { get; set; }
        public string OpeningBalance { get; set; }
        public string ClosingBalance { get; set; }
        public string SalesChannel { get; set; }
        public string ReferenceNo { get; set; }
        
        public WalletHistoryResponse()
        {
         System.debug('All..'+TransactionDate+TransactionMode+TransactionType+Amount+ExprationDate+OfferName+AmountUsed+OpeningBalance+ClosingBalance+SalesChannel+ReferenceNo);
        }
    }

}