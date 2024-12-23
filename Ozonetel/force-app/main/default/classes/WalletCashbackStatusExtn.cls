/**
 * (c) 2016 RedBus
 *
 * Name           : WalletCashbackStatusExtn
 * Created Date   : 29 Dec 2016
 * Created By     : Sreenivas M
 * Purpose        : Extension class for WalletCashbackStatusPage
 *
 **/
 
public class WalletCashbackStatusExtn {

    public Order_Items__c orIt{get;set;}
    public List<CaskBackStatusResponse> cashBackResponse{get;set;}
    public boolean showStatus{get;set;}
    public String tinNumber{get;set;}
    
    public WalletCashbackStatusExtn(ApexPages.StandardController controller) 
    {
        orIt = new Order_Items__c();
        orIt = (Order_Items__c)controller.getRecord();
        cashBackResponse = new List<CaskBackStatusResponse>();
        showStatus = false;
    }
    
    public pagereference fetchCashbackStatus()
    {
       Http http = new Http();
       HttpResponse res = new HttpResponse();
       HttpRequest req = new HttpRequest();
       req = HttpRequestUtil.populateHeaders(req);
       tinNumber = [SELECT Order_Item_Reference_No__c from Order_items__c where id =:orIt.Id].Order_Item_Reference_No__c;
       if(String.isBlank(tinNumber))
       {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'TIN number for this transaction is blank.So we can\'t process your request'));
            return null;           
       
       }
       
       //String endPoint = System.Label.Wallet_History_URL.replace('History?','Cashback/Status/tin='+tinNumber);
       String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='WalletCashBack'].Endpoint__c+tinNumber;
       req.setEndpoint(endPoint);
       req.setMethod('GET');
       try
        {
           res = http.send(req);
           string responseValue = res.getBody();
                    
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
            {
               System.debug('wallet cashback status call is success...'+responseValue);
               cashBackResponse = (List<CaskBackStatusResponse>)System.JSON.deserialize(responseValue ,List<CaskBackStatusResponse>.class);
               if(Test.isRunningTest())
                   new CaskBackStatusResponse();
                if(cashBackResponse.isEmpty())
                   showStatus= true;
             
            }
        }
        Catch(Exception e)
        {
              system.debug('---Exception in wallet cashback status call---------------'+e);
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
              return null;
            
        }
        return null;
    }
    
 public class CaskBackStatusResponse
 {
    public string Type{get;set;}
    public string Amount{get;set;}
    public string Status{get;set;}
    public string OfferCode{get;set;}
    public string TIN{get;set;}
    
    public CaskBackStatusResponse()
    {
        System.debug('All fields '+Type+Amount+status+OfferCode+TIN);
    }
 }

}