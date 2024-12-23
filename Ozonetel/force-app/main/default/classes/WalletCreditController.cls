/**
* Name           : WalletCreditController
* Created Date   : 15 June 2017
* Created By     : Veeramanikanta
* Purpose        : Manual Credits Amount for Account
* Test class     : WalletcreditControllerTest
*
**/
public class WalletCreditController{
    
    public string mobile{get;set;}
    public string email{get;set;}
    public string description{get;set;}
    public decimal amount{get;set;}
    public string tin{get;set;}
    public boolean submitButton{get;set;}   
    public Order_Items__c orIt{get;set;}
    public String selectedCurrency {get;set;}
    public string selectedSubCategory {get; set; }
    public string selectedRefundCategory {get; set; }
    public string loggedInUserId {get; set;}
    public string businessUnit {get; set;}
    public List<SelectOption> parentCases{get;set;}
    public String selParentCase{get;set;}
    public string rbusrId{get;set;}
    public string ordItmBusUnit;

    public WalletCreditController(){
        
        submitButton=true;
        String tId=Apexpages.currentpage().getparameters().get('Id');
        List<String> internalIssueType = System.Label.Internal_IssueTypes.split(',');
        parentCases = new List<SelectOption>();
        string ordItmBusUnit;
        orIt=new Order_Items__c ();
        System.debug('tid-->'+tid);
        
        if(tId!=null){
        Order_Items__c ordItem = [Select Rb_User_ID__c,Business_Unit__c,Package_Id__c,Order_Id__c,Transaction_Source__c from Order_Items__c Where id=:tid limit 1];
        ordItmBusUnit ='REDBUS_'+ordItem.Business_Unit__c.split('_')[1];
        rbusrId=ordItem.Rb_User_ID__c;
        }
        
        if(tId!=null){
            orIt=[select id,name,Customer_Name__c,Booking_Signed_in_Email_ID__c,RecordType.Name,Booking_Signed_in_Phone_Number__c,Business_Unit__c,Customer_Name__r.PersonEmail,Customer_Name__r.PersonMobilePhone,Order_Item_Reference_No__c,(SELECT id,casenumber,issue_type__c FROM Cases__r WHERE Issue_Type__c NOT IN :internalIssueType AND Status NOT IN('Closed','Rejected For Bus Cancellation')) from Order_Items__c where id=:tId];       
            ordItmBusUnit ='REDBUS_'+orIt.Business_Unit__c.split('_')[1];
        }
        
        if(orIt!=null){
          if(orIt.RecordType.name == 'Hotels')
          {
               mobile=orIt.Booking_Signed_in_Phone_Number__c;
               email=orIt.Booking_Signed_in_Email_ID__c;
               businessUnit='REDBUS_IN';
               
          
          }
          else
           
          {
            email=String.isBlank(orIt.Customer_Name__r.PersonEmail)?'':orIt.Customer_Name__r.PersonEmail;
            mobile=orIt.Customer_Name__r.PersonMobilePhone;
            businessUnit=orIt.Business_Unit__c;
            
            String firstTwoDigitsMobile = string.isNotBlank(mobile)?mobile.substring(0, 2):'';
            Country_Codes__c ccObj= Country_Codes__c.getValues(orIt.Business_Unit__c);
            system.debug('>>>firstTwoDigitsMobile>>'+firstTwoDigitsMobile);
            if(string.isNotBlank(firstTwoDigitsMobile) && firstTwoDigitsMobile!=ccObj.Country_Code__c){
               mobile = ccObj.Country_Code__c+mobile;
               system.debug('>>>email>>'+email+'>>>mobile>>'+mobile);
             }
             
            if(!orIt.Cases__r.isEmpty())
            {
                for(Case c:orIt.Cases__r)
                {
                    if(String.isNotBlank(c.issue_type__c))
                        parentCases.add(new SelectOption(c.id,c.casenumber+'--'+c.issue_type__c));
                }
            }
          }
            tin=orIt.Order_Item_Reference_No__c;
           
        }
        string jsonbody = '{"emailId":"'+email+'","phone":"'+mobile+'","userId":"","amount":""}';
        try
        {
            
            if(!orIt.Cases__r.isEmpty())
            {
                HttpResponse resp =getWalletStatus(jsonbody);
                System.debug('resp-->'+resp);
                if(resp!=null && resp.getStatusCode()==200 && String.isNotBlank(resp.getBody()))
                {
                    System.debug('Response-->'+resp.getBody());
                    map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(resp.getBody());
                    map<String,Object> statusMap= (map<string,object>)resMap.get('Status');
                    string data= (string)resMap.get('Data');
                    String statusCode=string.valueof(statusMap.get('code'));
                                           
                    if(String.isNotBlank(data))
                    {
                        map<String,Object> dataMap= (map<string,object>)JSON.deserializeUntyped(data);
                        if(dataMap.containsKey('UserId') && dataMap.get('UserId')!=null)
                        {
                        loggedInUserId=string.valueof(dataMap.get('UserId'));
                        } 
                        if(dataMap.containsKey('PreferredCurrency') && dataMap.get('PreferredCurrency')!=null && String.isNotBlank(string.valueof(dataMap.get('PreferredCurrency'))))
                        {
                        selectedCurrency=string.valueof(dataMap.get('PreferredCurrency'));
                        }
                        else if(dataMap.containsKey('CountryCode') && dataMap.get('CountryCode')!=null)
                        {
                            Map<string,string> country_to_currency=new Map<string,string>();
                            for(OrderItemTransactionResource__c o:OrderItemTransactionResource__c.getAll().values()){
                               country_to_currency.put(o.Auth_Key__c,o.Default_Currency__c);
                            }
                            selectedCurrency=country_to_currency.get(string.valueof(dataMap.get('CountryCode')));
                            System.debug('else if selectedCurrency--> '+selectedCurrency);
                        }
                    
                   }   
                    if(statusCode =='200' && selectedCurrency!='' && businessUnit.right(2)!=selectedCurrency.substring(0,2)){
                        System.debug('submitButton ..'+submitButton);
                        submitButton = false;
                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Warning,'Wallet belongs to different currency than selected currency while Booking,\n Please Convert currency before case creation');
                        ApexPages.addMessage(errorMsg);
                    }

                    else if(statusCode =='201'){
                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Info,'Wallet Is Not Active');
                        ApexPages.addMessage(errorMsg);
                    }
                    else if(statusCode=='400')
                    {
                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Info,'For the Given Details Either Wallet/UserId Doesn\'t Exist');
                        ApexPages.addMessage(errorMsg);
                    }
                    else
                    {
                     submitButton = false;
                    System.debug('statusCode..'+statusCode);
                    }

                }
                
                else
                {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Something went wrong-'+resp.getStatusCode()+'-'+resp.getBody());
                    ApexPages.addMessage(errorMsg);
                    System.debug('Proper response has not received from the backend..'+resp);

                }
            }
            else
            {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Open Parent Case Found For This Transaction');
            ApexPages.addMessage(errorMsg);
            }
            
            
        }
        Catch(Exception e)
        {
              system.debug('-------Get Wallet Status--Exception---------------'+e);
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
         System.debug('submitButton ..'+submitButton);
 
    }
    
    public HttpResponse getWalletStatus(String jsonBody)
    {
        System.debug('>>body...'+jsonbody);
        Http http = new Http();
        HttpResponse res = new HttpResponse();       
        HttpRequest req = new HttpRequest();
        //req = HttpRequestUtil.populateHeaders(req);
        req = HttpRequestUtil.populateCMAPIHeaders(req,ordItmBusUnit);
        req.setBody(jsonbody);
        req.setMethod('POST');        
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='WalletStatusCheck'].Endpoint__c;
        req.setEndpoint(endPoint);
        string jsonHeaders='-Headers-Channel_Name--'+Req.getHeader('Channel_Name')+'---Country_Name--'+Req.getHeader('Country_Name')+'--auth_key-'+Req.getHeader('auth_key')+'--BusinessUnit--'+Req.getHeader('BusinessUnit')+'--SelectedCurrency--'+Req.getHeader('SelectedCurrency')+'--Currency-'+Req.getHeader('Currency');
       
        try
        {
            res = http.send(req);
        }
        Catch(Exception e)
        {
            System.debug('Exception in wallet status check..'+e);
             
        }
        return res;
    }
    
/* Used for
1. Check all mandaotory fields 
2. Amount credit limit  
3. Case Insertion
*/
    public PageReference submit(){
        //System.debug('test----- '+wallet_credit__c);
        System.debug('test--- '+wallet_credit__c.getValues(selectedCurrency));
        System.debug('test---jiji-- '+wallet_credit__c.getValues(selectedCurrency).Amount__c);
        Decimal amountLimit= wallet_credit__c.getValues(selectedCurrency).Amount__c;
        System.debug('amountLimit-->'+amountLimit);
        System.debug('acc Amount-->'+amount);
        
        if(mobile=='' || amount<=0 || description ==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter all mandatory fields');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(amount>amountLimit)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'You can not add more than <font size="2"><b>'+amountLimit+'</b></font> amount for <b><font size="2">'+selectedCurrency+'</font></b>');
            ApexPages.addMessage(myMsg);
             return null;
        }
        
        Id recTypeId = Schema.getGlobalDescribe().get('case').getDescribe().getRecordTypeInfosByName().get('Wallet Credit').getRecordTypeId();
        Case cObj=new Case();
        cObj.RecordTypeId=recTypeId;        
        cObj.description=description;
        cObj.Customer_Email_ID__c=email;
        cObj.Customer_Phone_Number__c=mobile;
        cObj.Accountid=orIt.customer_name__c;
        cObj.Transaction_ID__c=orIt.id; 
        cObj.Amount__c =amount;
        cObj.TIN_No__c=tin;
        cObj.Issue_Type__c='Wallet Credit';
        cObj.Origin='InBound Call';
        cObj.Price_Paid_Currency_ctp__c=selectedCurrency;
        cObj.Signed_In_UserId__c = loggedInUserId;
        cObj.Issue_Sub_Category__c=(String.isNotBlank(orIt.RecordType.name) && 'Hotels'.equalsIgnoreCase(orIt.RecordType.name))?selectedSubCategory:selectedRefundCategory;
        cObj.ParentId = selParentCase;
        cObj.Business_Type__c = (String.isNotBlank(orIt.RecordType.name) && 'Hotels'.equalsIgnoreCase(orIt.RecordType.name))?'Hotel':'Bus';
        try{ 
            insert cObj;
            submitButton=true;
            case c=[select id,casenumber from case where id=:cObj.id];           
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.confirm,'Case has been created for approval.Case Number is -'+c.CaseNumber);
            ApexPages.addMessage(myMsg);
        } 
        catch(Exception e)
        {
            System.debug('Error..'+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,''+e);
            ApexPages.addMessage(myMsg);
        }
         return null;
    }
    
   
    /* Used for get all Currency types from custom settings */
    public List<selectOption> currencyCodes{
        get{
            List<selectOption> options = new List<selectOption>();
            for (Wallet_Credit__c c: Wallet_Credit__c.getAll().values())
                options.add(new SelectOption(c.name,c.name));
            return options;
        }set;
    }    
    public List<selectOption> subCategory{
        get{
            List<selectOption> options = new List<selectOption>();            
                options.add(new SelectOption('Customer Delight','Customer Delight'));
                options.add(new SelectOption('Offer Cashback','Offer Cashback'));
                options.add(new SelectOption('redHotel Moneyback','redHotel Moneyback'));
                options.add(new SelectOption('Exceptional Refund','Exceptional Refund'));
            return options;
        }set;
    }  

    public List<selectOption> refundOptions{
        get{
            List<selectOption> options = new List<selectOption>();            
                options.add(new SelectOption('ZQP','ZQP'));
                options.add(new SelectOption('Technical Error','Technical Error'));
                options.add(new SelectOption('Customer Delight','Customer Delight'));
            return options;
        }set;
    } 
}