/**
* (c) 2017 RedBus
*
* Name           : UserTripsCntrl
* Created Date   : 30 Jan 2017
* Created By     : Sreenivas M
* Modifed By     : Sreenivas M on 19 May 2017 -Used for new User Trips Page
* Purpose        : Controller class for UserTripsPage
* Test Class     : SyncAPICntrlTest
*
**/

public class UserTripsCntrl {
    
    public UserTripsCntrl(ApexPages.StandardController controller) {
        stdRecId=controller.getid();      
    }
    
    
    public static List<UserTripsResponse> tripsResponse{get;set;} 
    public string ordId{get;set;}
    public string redirectUrl{get;set;}
    public static string console{get;set;}
    public static String countryCode{get;set;}
    
    public string emailId{get;set;}
    public string PhoneNo{get;set;}
    public string Tin{get;set;}
    public string tripId{get;set;}
    public string region{get;set;}
    public string vendor{get;set;}
    Public string railsPnr{get;set;}
    
    public boolean resultFound{get;set;}
    public boolean showNoResult{get;set;}
    public string userDetReq{get;set;}
    public string userResp{get;set;}
    public boolean b2bSel{get;set;}
    public string utripsReq;
    public string utripsResp{get;set;}    
    public B2BUserTrips userTripsResp{get;set;}
    public boolean cuntryCode{get;set;}
    public string cCode{get;set;}
    public string phoneNum{get;set;}
    private string recId;
    public string stdRecId;
    public boolean isRails{get;set;}
    public boolean disB2CTin{get;set;}
    public boolean isTripIdSearch{get;set;}
    
    public UserTripsCntrl()
    {
        cuntryCode=false;
        disB2CTin = false;
        isTripIdSearch = false;
        userTripsResp=new B2BUserTrips();
        recId = ApexPages.currentPage().getParameters().get('id');
        system.debug('--recId---'+recId); 
        if(String.isNotBlank(recId)){
            Account acc= [select id,PersonEmail,email_copy__c,PersonMobilePhone,CountryCode__c,Phone_10_Digits__c from Account where id =: recId];
            cCode=acc.CountryCode__c;
            emailId=acc.PersonEmail;
            phoneNum=acc.PersonMobilePhone;
            system.debug('--recId---'+acc.CountryCode__c); 
        }
        
        if('IND'.equalsIgnoreCase(cCode)|| string.isblank(cCode)){
            cuntryCode=true;
        }else{cuntryCode=false;       }
        
        b2bSel=false;isRails=false;
    }
    
    public void EnableB2B(){
        
        disB2CTin = region=='COUPON' || region=='THINGSTODO'?true:false;     
        if(region=='Amazon' || region=='IRCTC'){
            b2bSel=true;  isRails=false;
            system.debug('--b2bSel--'+b2bSel);
        }else if(region=='Rails'){
            isRails=true;
        }else{
            b2bSel=false;  isRails=false;
        }
        
    } 
    
    public void fetchUserTrips()
    {
        list<account> accList=new list<account>();
        accList=[select id,PersonEmail,PersonMobilePhone,CountryCode__c from account where id=:stdRecId];
        string emailIdU;
        string phoneNumU;
        string countryCodeU;
        if(!accList.isEmpty()){
            emailIdU=accList[0].PersonEmail;
            phoneNumU=accList[0].PersonMobilePhone;
            countryCodeU=accList[0].CountryCode__c;
        }
        if('IND'.equalsIgnoreCase(cCode)|| string.isblank(cCode)){
            cuntryCode=true;
        }else{
            cuntryCode=false;
        }
        String serOrder = ApexPages.currentPage().getParameters().get('sercOrd');
        system.debug('serOrder'+serOrder);
        if(String.isNotBlank(serOrder) && Boolean.valueOf(serOrder))
        {
            region = ApexPages.currentPage().getParameters().get('reg');
            ordId = ApexPages.currentPage().getParameters().get('ordId2');
            searchOrder();
        }
        
        else
        {
            tripsResponse = new List<UserTripsResponse>();
            HttpResponse res = new HttpResponse();        
            Http http = new Http();            
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);            
            String emailId = ApexPages.currentPage().getParameters().get('emailId');
            String phoneNum = ApexPages.currentPage().getParameters().get('phone');
            console = ApexPages.currentPage().getParameters().get('isConole');
            countryCode= ApexPages.currentPage().getParameters().get('code');
            emailId=string.isNotBlank(emailId)?emailId:emailIdU;
            phoneNum =string.isNotBlank(phoneNum)?phoneNum:phoneNumU;
            countryCode=string.isNotBlank(countryCode)?countryCode:countryCodeU;
            
            String apiEndPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='UserTrips'].Endpoint__c;
            apiEndPoint = apiEndPoint+'emailid='+emailid+'&phone='+phoneNum+'&tripid=&tin=';
            System.debug('..apiEndPoint...'+apiEndPoint);
            req.setEndpoint(apiEndPoint);
            req.setHeader('Channel_Name', 'WEB_DIRECT');
            req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');       
            req.setHeader('Country_Name', 'IND');            
            req.setMethod('GET');             
            
            try
            {
                res = http.send(req);
                string responseValue = res.getBody();
                System.debug('responseValue ...'+responseValue);          
                if(res.getStatus()=='OK')
                {
                    
                    UserTripsResponse utResp = new UserTripsResponse();
                    tripsResponse = (List<UserTripsResponse>)JSON.deserialize( responseValue, List<UserTripsResponse>.class);
                    system.debug('-------tripsResponse--resp-----------'+tripsResponse);
                }
                
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,res.getStatus()+'. Please contact your System Admisntrator'));
                    
                }
            }
            Catch(Exception e)
            {
                system.debug('-------tripsResponse--Exception---------------'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
                
            }
        } 
    }
    
    public object searchUserTrips()
    {
        tripsResponse=new  List<UserTripsResponse>();
        tripsResponse.clear();
        isTripIdSearch = false;
        
        
        if(String.isBlank(region)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Region'));
            return null;     
        }
        
        if(String.isBlank(emailId) && String.isBlank(PhoneNo)&& String.isBlank(tripId) && String.isBlank(Tin) && string.isBlank(railsPnr))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter at least one field value to fulfill the search criteria'));
            return null;        
        }
        
        if(!((tin!='' && tripid=='' && PhoneNo=='' && emailId=='' ) || (tin=='' && tripid!='' && PhoneNo=='' && emailId=='') || (tin=='' && tripid=='' && (PhoneNo!='' || emailId!='')) || (tin=='' && tripid=='' && PhoneNo=='' && emailId=='' && railsPnr!=''))){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please search only with one field'));
            return null; 
        }
        
        isTripIdSearch = String.isNotBlank(tripid)?true:false;
        
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateHeaders(req);
        String apiEndPoint='';
        if(region=='Rails'){
            apiEndPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RailsUserTrips'].Endpoint__c;
            apiEndPoint = apiEndPoint+'phone='+PhoneNo+'&tin='+Tin+'&pnr='+railsPnr+'&emailid='+emailId;           
            // https://capi.redbus.com/entangle/api/User/Rails/v1/MyTrips?phone=&tin=&pnr=6605095251&emailid=
        }else{
            apiEndPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='UserTrips'].Endpoint__c;
            apiEndPoint = apiEndPoint+'emailid='+emailId+'&phone='+PhoneNo+'&tripid='+tripId+'&tin='+Tin;
            
        }
        
        req.setEndpoint(apiEndPoint); 
        req.setMethod('GET');
        countryCode='IND';
        
        if('COUPON'.equalsIgnoreCase(region))
        {
            req.setHeader('Country_Name', 'INTL');
            req.setHeader('BusinessUnit', 'COUPON');
            countryCode='INTL';
        } 
        if('INTL'.equalsIgnoreCase(region)){
            req.setHeader('Country_Name', 'INTL');    
            countryCode='INTL';
        }  
        
        else if('RDC'.equalsIgnoreCase(region)){
            req.setHeader('Country_Name', 'RDC'); 
        }
        
        else if('THINGSTODO'.equalsIgnoreCase(region)){
            req.setHeader('BusinessUnit','THINGSTODO');
            req.setHeader('Country_Name', 'INTL');
        }
        
        system.debug('endpoint...'+req.getEndpoint()+'..'+req.getHeader('BusinessUnit'));
        Continuation con = new Continuation(120);         
        con.continuationMethod='processUserTripsResponse';     
        this.userDetReq= con.addHttpRequest(req);
        return con;          
        
    }
    
    public Object processUserTripsResponse()
    {
        try{
            HttpResponse response = Continuation.getResponse(this.userDetReq);
            string respnBody;
            this.userResp= response.getBody();
            respnBody=this.userResp;     
            System.debug('response-->'+response);
            System.debug('respnBody-->'+respnBody);      
            // string responseValue = res.getBody();
            //  System.debug('responseValue2 ...'+responseValue);          
            if(response.getStatusCode()==200)
            {
                tripsResponse = (List<UserTripsResponse>)JSON.deserialize( respnBody, List<UserTripsResponse>.class);
                
                system.debug('-------tripsResponse2--resp-----------'+tripsResponse);
                if(tripsResponse==null)
                {
                    resultFound = false; showNoResult = true;
                }
                else
                {
                    for(UserTripsResponse u:tripsResponse){
                        System.debug('::: hasPayment = '+u.hasPayment);
                        if(string.isNotBlank(tripId)){
                            u.isTripIdSearch = true;
                        }else{
                            u.isTripIdSearch = false;
                        }
                    }
                    showNoResult = false; resultFound = true;
                }
            }
            
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,response.getStatus()+'. Please contact your System Admisntrator'));
                
            }
        }
        Catch(Exception e)
        {
            system.debug('-------tripsResponse2--Exception---------------'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            
        }
        return null;
    }
    
    
    public PageReference searchOrder()
    {
        System.debug('.started..'+ordId);
        List<Orders__c> order = new List<Orders__c>();
        String orderName =  ApexPages.currentPage().getParameters().get('ordId2');
        System.debug('...'+orderName+'..region..'+region);
        List<Order_Items__c> OrdItemLs=new List<Order_Items__c>();
        OrdItemLs=[select id,Order_Id__c from Order_Items__c where Order_Id__c=:orderName];
        system.debug('----OrdItemLs---'+OrdItemLs);
        if(UserInfo.getUiThemeDisplayed() == 'Theme4u' && !OrdItemLs.isEmpty() ){
            
            redirectUrl='/lightning/r/Order_Items__c/'+OrdItemLs[0].id+'/view';
            system.debug('<redirectUrl'+redirectUrl);
            
            
        }
        else{
            system.debug('---280--');
            redirectUrl ='/_ui/search/ui/UnifiedSearchResults?initialViewMode=summary&searchAll=true&str='+ordId;
        }
        
        if(OrdItemLs.isEmpty())
        {
            string body='';
            if(region=='Rails'){
                body = '{"orderId":"'+ordId+'","emailId":"","phone":"","caller":"UserTrips","isRails":true}';
            }else{
                body = '{"orderId":"'+ordId+'","emailId":"","phone":"","caller":"UserTrips"}';
            }
            System.debug('..body...'+body+'..'+region);
            
            if(region=='RDC'){
                countryCode ='RDC';
            }else if(region=='Rails'){
                countryCode ='IND';
            }else{
                countryCode = String.isBlank(region)?'IND':'IND'.equalsIgnoreCase(region)?region:'INTL';
            }
            SyncAPICntrl.asyncProcess(body,countryCode);
            
            /*
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Data Sync is happening please wait for few minutes and then click on Search Again button!'));
Pagereference pg = new Pagereference('/apex/SyncPollingPage?id='+ordId);
pg.setRedirect(true);
return pg;
*/
            redirectUrl ='/apex/SyncPollingPage?id='+ordId;
            
        }
        
        return null;
        
    }
    
    public PageReference searchB2BTin()
    {
        system.debug(UserInfo.getUiThemeDisplayed());
        System.debug('.started..'+ordId);
        List<Order_Items__c> orderItms = new List<Order_Items__c>();
        String tinNo=  ApexPages.currentPage().getParameters().get('tin');
        orderItms = [Select id,Order_Item_Reference_No__c from Order_Items__c where Order_Item_Reference_No__c=:ordId];
        if(UserInfo.getUiThemeDisplayed() == 'Theme4u' && !orderItms.isEmpty() ){
            
            redirectUrl='/lightning/r/Order_Items__c/'+orderItms[0].id+'/view';
            system.debug('<redirectUrl'+redirectUrl);
            
            
        }
        else{
            redirectUrl ='/_ui/search/ui/UnifiedSearchResults?initialViewMode=summary&searchAll=true&str='+ordId;
            
        }   
        if(orderItms.isEmpty())
        {
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(system.label.B2B_Transaction_Account);           
            string accountNo=string.valueOf(resObj.get(region));
            system.debug('Entered if');
            string body = '{"tin":"'+ordId+'","caller":"B2B UserTrips"}';
            System.debug('..body...'+body+'..'+region);
            //countryCode = String.isBlank(region)?'IND':'IND'.equalsIgnoreCase(region)?region:'INTL';
            SyncAPICntrl.B2BAsyncProcess(body,'IND');    
            redirectUrl ='/apex/SyncPollingPage?id='+ordId+'&source=B2B';    
        }    
        
        
        return null;    
    }
    
    public object SearchB2BTrips(){
        system.debug('---b2b---');
        if(String.isBlank(region)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Region'));
            return null;     
        }
        
        if(String.isBlank(emailId) && String.isBlank(PhoneNo)&& String.isBlank(Tin))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter at least one field value to fulfill the search criteria'));
            return null;        
        }
        
        if(string.isNotBlank(tin) && string.isNotBlank(PhoneNo)){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please search only with one field'));
            return null;      
        }else if(string.isNotBlank(tin)){
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(system.label.B2B_Transaction_Account);           
            string accountNo=string.valueOf(resObj.get(region));
            string tinResp='{ "bookings": [{ "tin": "'+tin+'" } ] }';
            // string tinResp='{ "bookings": [{ "tin": "'+tin+'_'+accountNo+'" } ] }';
            userTripsResp = (B2BUserTrips)JSON.deserialize(tinResp, B2BUserTrips.class);
            resultFound = true;
            showNoResult = false;
            return null;
        } 
        
        
        //PhoneNo='8884580492';
        // emailId='nilika.haldar@redbus.com';
        if(string.isBlank(PhoneNo)){
            PhoneNo=null;
        }
        if(string.isBlank(emailId)){
            emailId=null;
        }
        API_EndPoints__mdt  APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BUserTrips'];
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();        
        // req.setEndpoint(APIMData.Endpoint__c+'?mobile='+PhoneNo+'&email='+emailId);
        req.setEndpoint(APIMData.Endpoint__c+'mobile='+PhoneNo+'&email='+emailId);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        OAuthGeneric oauthObj=new OAuthGeneric();
        if(region=='Amazon'){
           vendor ='Amazon';
        }else if(region=='IRCTC'){
          vendor ='IRCTC';
        }
        string oauthParams=oauthObj.sign(req,vendor);
       	string endPoint=APIMData.Endpoint__c+'mobile='+PhoneNo+'&email='+emailId+'&'+oauthParams;
        req.setEndpoint(endPoint);
        System.debug('endPoint-->'+endPoint);         
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetSearchB2BTripsResponse';
        this.utripsReq= con.addHttpRequest(req); 
        return con;
    }
    
    public object GetSearchB2BTripsResponse(){
        HttpResponse response = Continuation.getResponse(this.utripsReq);
        this.utripsResp= response.getBody();
        System.debug('resp-->'+utripsResp);
        string mockResp='{ "bookings": [{ "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 5.30, "doj": 1564515720000, "arrivalTime": 1680, "departureTime": 72, "tin": "84YQC3P2", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TNSTC (1430BANCHE)", "busType": null, "fare": 495.00, "doj": 1564563600000, "arrivalTime": 1350, "departureTime": 900, "tin": "84Z47NVF", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 8.46, "doj": 1565811000000, "arrivalTime": 780, "departureTime": 60, "tin": "84HJYHTJ", "status": "BOOKED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "SPG Travels (7)", "busType": null, "fare": 400.00, "doj": 1565107800000, "arrivalTime": 1710, "departureTime": 1370, "tin": "844YZXGT", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "Bharathi Travels (491)", "busType": null, "fare": 577.50, "doj": 1565109000000, "arrivalTime": 1650, "departureTime": 1325, "tin": "84GSR53T", "status": "CANCELLED" }, { "source": "Jammu", "destination": "Katra ", "travels": "JKSRTC (6)", "busType": null, "fare": 93.00, "doj": 1565089200000, "arrivalTime": 1110, "departureTime": 990, "tin": "84B79EF6", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "Bharathi Travels (363)", "busType": null, "fare": 550.00, "doj": 1565740800000, "arrivalTime": 675, "departureTime": 370, "tin": "84XJ8FCV", "status": "BOOKED" }, { "source": "Chennai", "destination": "Aluva", "travels": "TESTING ACCOUNT", "busType": null, "fare": 15.00, "doj": 1565159400000, "arrivalTime": 2220, "departureTime": 720, "tin": "84J9Z2FX", "status": "BOOKED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 4.24, "doj": 1565811720000, "arrivalTime": 1680, "departureTime": 72, "tin": "84MDNKVM", "status": "CANCELLED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 10.00, "doj": 1564979400000, "arrivalTime": 960, "departureTime": 600, "tin": "845TCA9Y", "status": "CANCELLED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 10.00, "doj": 1564979400000, "arrivalTime": 960, "departureTime": 600, "tin": "84TRMXJB", "status": "CANCELLED" }, { "source": "Jamnagar", "destination": "Rajkot", "travels": "Samay travels (45057)", "busType": null, "fare": 500.00, "doj": 1565456400000, "arrivalTime": 1454, "departureTime": 1393, "tin": "845764R4", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 4.24, "doj": 1566330120000, "arrivalTime": 1680, "departureTime": 72, "tin": "84DCNTTB", "status": "CANCELLED" }, { "source": "Lucknow", "destination": "Delhi", "travels": "Uttar Pradesh State Road Transport Corporation(UPSRTC) (85371)", "busType": null, "fare": 564.00, "doj": 1565634600000, "arrivalTime": null, "departureTime": 0, "tin": "84JE6NV6", "status": "CANCELLED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 10.00, "doj": 1564979400000, "arrivalTime": 960, "departureTime": 600, "tin": "84NXC638", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Hyderabad", "travels": "VRL Travels (812623)", "busType": null, "fare": 1260.00, "doj": 1565712000000, "arrivalTime": 1765, "departureTime": 1215, "tin": "84H9FHGA", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 4.23, "doj": 1566156600000, "arrivalTime": 780, "departureTime": 60, "tin": "8496AE8M", "status": "CANCELLED" }, { "source": "Bangalore", "destination": "Chennai", "travels": "TESTING ACCOUNT", "busType": null, "fare": 6.36, "doj": 1564947720000, "arrivalTime": 1680, "departureTime": 72, "tin": "84RH5CMJ", "status": "BOOKED" }, { "source": "Chennai", "destination": "Bangalore", "travels": "TESTING ACCOUNT", "busType": null, "fare": 9.45, "doj": 1566635400000, "arrivalTime": 1500, "departureTime": 840, "tin": "94P53FTR", "status": "BOOKED" }, { "source": "Mysore", "destination": "Davanagere", "travels": "TESTING ACCOUNT", "busType": null, "fare": 6.36, "doj": 1565096100000, "arrivalTime": 1101, "departureTime": 1105, "tin": "94ZEJ7F9", "status": "CANCELLED" } ] }';
        userTripsResp = (B2BUserTrips)JSON.deserialize(utripsResp, B2BUserTrips.class);
        system.debug('>>>>userTripsResp>>>'+userTripsResp);
        if(userTripsResp!=null && userTripsResp.bookings!=null && !userTripsResp.bookings.isEmpty())
        {
            resultFound = true;  showNoResult = false;
        }
        else
        {
            showNoResult = true;   resultFound = false;
        }
        return null;
    }
    
    public class UserTripsResponse
    {
        public string tin{get;set;}
        public string transactionNo{get;set;}
        public string cartId{get;set;}
        public string status{get;set;}
        public string dateOfJourney{get;set;}
        public string source{get;set;}
        public string destination{get;set;}
        public string travels{get;set;}
        public string pnr{get;set;}
        public string seats{get;set;}
        public string userId{get;set;}
        public string emailId{get;set;}
        public string phone{get;set;}
        public string creationDate{get;set;} 
        public string trainName{get;set;}
        public string trainNo{get;set;}
        public boolean hasPayment{get;set;}
        
        public boolean isTripIdSearch{get;set;}
        
        public UserTripsResponse()
        {
            System.debug('Display..'+tin+transactionNo+cartId+status+dateOfJourney+source+destination+travels+pnr+seats+userId+emailId+phone+creationDate);
            
        }
    }
    
    public class B2BUserTrips{
        public List<bookingsWrapper> bookings{get;set;}
        public B2BUserTrips(){
            bookings=new List<bookingsWrapper>();
        }
        
    }
    public class bookingsWrapper{
        public string source{get;set;}
        public string destination{get;set;}
        public string travels{get;set;}
        public string busType{get;set;}
        public string fare{get;set;}
        public string doj{get;set;}
        public string arrivalTime{get;set;}
        public string departureTime{get;set;}
        public string tin{get;set;}
        public string status{get;set;}
        
    }
    
}