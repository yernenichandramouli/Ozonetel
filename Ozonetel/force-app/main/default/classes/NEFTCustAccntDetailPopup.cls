/**
* (c) 2017 RedBus
*
* Name           : NEFTCustAccntDetailPopup
* Created Date   : 04 Mar 2017
* Created By     : Sreenivas M
* Purpose        : Apex class to insert bus cancellation case and NEFT Wallet Debit case
* Test class     : NEFTCustAccntDetailPopup_Test
*
**/

public class NEFTCustAccntDetailPopup {
    
    public String AgentName {get;set;}
    public String accntId {get;set;}    
    public Account accnt{get;set;}
    public Case cObj{get;set;}
    public boolean ClosePopup{ get; set; }    
    public Boolean showPanelAccnt{get;set;}    
    public Boolean showBusCancelPane{get;set;}
    public Boolean showARNUpdateForm{get;set;}
    public Boolean showTicketConfirm{get;set;}
    public Boolean showRefundStatus{get;set;}
    public Boolean showCallPopup{get;set;}
    public Boolean BPnumberr{get;set;}
    public String caseOrigin {get;set;}
    public String arnNumber{get;set;}
    public string selCallopt{get;set;}
    Public string pnrvalue{get;set;}
    Public string seatno{get;set;}
    public string mobileno{get;set;}
    public string commnts{get;set;}
    public string description{get;set;}
    public Date refundedDate{get;set;}
    public String refundRefNum{get;set;}
    public String refStatus{get;set;}
    public boolean sendSMS{get;set;}
    public list<Order_Items__c> lstordrItm{get;set;} 
    public list<Bus_Order_Item_Details__c>  boList{get;set;}
    public boolean busCanBt{get;set;}
    public DBLog_Summary__c dbLogBC;
    public string busCReq;
    public string busCResp{get;set;}
    public boolean CmpltPaymnt{get;set;}
    public list<Payment_Items__c> paymntItemlst{get;set;}
    public string pgRefId{get;set;}
    public list<selectOption> totalPgIds{get;set;}
    public string selectedPGid{get;set;}
    public string ordItId{get;set;}
    public List<Order_Items__c> ordItm{get;set;}
    private string acrecId;
    public string allPaymnetOnlineUUIds;
    public boolean B2BfarebreakUp{get;set;}

    
    public NEFTCustAccntDetailPopup()
    { 
        cObj = new Case();
        string busCancrecId = ApexPages.currentPage().getParameters().get('recId');
        acrecId = ApexPages.currentPage().getParameters().get('id');
        system.debug('--acrecId--'+acrecId+'---busCancrecId--'+busCancrecId);
        busCanBt=false;
        //List<Order_Items__c> ordItm=new List<Order_Items__c>();
        totalPgIds=new list<selectOption>();
        ordItm=[select recordtypeid,id,Service_Provider_Id__c,Business_Unit__c,name from Order_Items__c where id=:busCancrecId];
        if(!ordItm.isEmpty() && ordItm[0].recordtypeid==Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId()){
            busCanBt=true;
        }
        Map<string,string> queryString =  ApexPages.currentPage().getParameters();
        system.debug('queryString==>>'+queryString+queryString.get('busCancelBit'));
        string enableBusCancelPanel= queryString.get('busCancelBit'); 
        
        if(queryString.containskey('orItId') && queryString.get('orItId') != null)
        {
            ordItId = queryString.get('orItId');
            lstordrItm = new list<Order_Items__c>();
            boList= new list<Bus_Order_Item_Details__c>();
            lstordrItm =[select id,recordtypeid,RecordType.Name,Guid__c,Mobile__c,Transaction_Status__c,Service_Provider_Id__c,Service_Provider_Name__c,Boarding_Point__c,Agent_IP__c,Service_Provider_Reference_PNR_No__c,Service_Provider_Reference_No__c,status__c,Order_Item_Reference_No__c,Business_Unit__c,Order_Id__c,Cancellation_Policy__c,Route_Id__c,DOI_DOJ__c,Seat_No__c,No_of_seats__c from Order_Items__c where id=:ordItId];
            boList=[select id,name,Order_Item_Name__c,Boarding_Point_ID__c from Bus_Order_Item_Details__c where Order_Item_Name__c =:ordItId];
            
        }
        if(queryString.containskey('id') && queryString.get('id') != null)
        {
            accnt = new Account(); 
            accnt = [select id,Bank_Account_Number__c, AccountNumber,Description,Review__c,PersonEmail,PersonMobilePhone,BankName__c,User_Id__c,IFSCCode__c,BranchName__c,Beneficiary_Name__c,Amount__c from Account where id=:queryString.get('id')limit 1];
            accnt.Review__c = '';
            accnt.Amount__c=null;
        }
        
        if(string.isNotBlank(acrecId)){
            accnt = [select id,Bank_Account_Number__c, AccountNumber,Description,Review__c,PersonEmail,PersonMobilePhone,BankName__c,User_Id__c,IFSCCode__c,BranchName__c,Beneficiary_Name__c,Amount__c from Account where id=:acrecId limit 1];
            accnt.Review__c = '';
            accnt.Amount__c=null;
            system.debug('---accnt--'+accnt+'--accntId--'+accnt.id);
        }
        
        caseOrigin = 'InBound Call';
        showPanelAccnt = true;
        showBusCancelPane = false;
        showARNUpdateForm = false;
        
        if(String.isNotBlank(enableBusCancelPanel) && Boolean.ValueOf(enableBusCancelPanel))
        {
            showPanelAccnt = false;
            showBusCancelPane = true;
            ClosePopup = false;
        }
        if(queryString.containskey('arnBit') && Boolean.valueOf(queryString.get('arnBit')))
        {
            showARNUpdateForm = true;
            showPanelAccnt = false;
        }
        
        if(queryString.containskey('cnfrm') && Boolean.valueOf(queryString.get('cnfrm')))
        {
            showTicketConfirm = true;
            showPanelAccnt = false;
            
        }
        if(queryString.containskey('BPnumber') && Boolean.valueOf(queryString.get('BPnumber')))
        {
            BPnumberr = true;
            showPanelAccnt = false;
            
        }
        if(queryString.containskey('sendSMS') && Boolean.valueOf(queryString.get('sendSMS')))
        {
            sendSMS= true;
            showPanelAccnt = false;
            mobileNo=lstordrItm[0].mobile__c;
        }
        if(queryString.containskey('refStatus') && Boolean.valueOf(queryString.get('refStatus')))
        {
            showRefundStatus = true;
            showPanelAccnt = false;
        }
        
        if(queryString.containskey('sitCall') && Boolean.valueOf(queryString.get('sitCall')))
        {
            showCallPopup= true;
            showPanelAccnt = false;
            cObj =[Select TIN_No__c,Service_Provider_Id__c,Bus_Operator_Name__c,Is_Primary__c,Date_Of_Journey_New__c,Route_Id__c,SS_Route_Id__c,id from Case Where Id=:queryString.get('recId')];
            
        }
        
        if(queryString.containskey('CmpltPaymnt') && Boolean.valueOf(queryString.get('CmpltPaymnt')))
        {
            CmpltPaymnt= true;
            showPanelAccnt = false;
            paymntItemlst=[select id,ID__c,PG_Type__c,Guid__c,Latest_Payment_Status__c,Order_Item_Name__r.Business_Unit__c,Order_Item_Name__r.Amount_Recieved_Currency__c,PG_Reference_ID__c,Payment_Status__c,Order_Item_Name__c from Payment_Items__c where Payment_Status__c='INITIATED' AND Latest_Payment_Status__c NOT IN ('SUCCESS') AND Payment_System__c = 'ONLINE' AND Order_Item_Name__c=:ordItId ORDER BY Creation_Time__C DESC];
            for(Payment_Items__c paItms :paymntItemlst){
                if(paItms.ID__c!=null){
                    system.debug('-payId-'+paItms.ID__c);
                    totalPgIds.add(new selectOption(string.Valueof(paItms.ID__c),string.Valueof(paItms.ID__c)));
                }
                if(string.isNotBlank(paItms.Guid__c)){
                if(string.isBlank(allPaymnetOnlineUUIds)){
                    allPaymnetOnlineUUIds='"'+paItms.Guid__c+'"';
                    }else{
                    allPaymnetOnlineUUIds=allPaymnetOnlineUUIds+'","'+paItms.Guid__c+'"';
                    }
                }
            }
        }
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('InBound Call','InBound Call'));
        options.add(new SelectOption('InBound BO/BD','InBound BO/BD'));
        options.add(new SelectOption('SPOC Inbound','SPOC Inbound'));
        options.add(new SelectOption('Email BO/BD','Email BO/BD'));
        options.add(new SelectOption('Alerts BOGDS','Alerts BOGDS'));
        options.add(new SelectOption('Alerts TRIMAX','Alerts TRIMAX'));
        options.add(new SelectOption('ALerts BITLA','Alerts BITLA'));
        options.add(new SelectOption('Alerts ITS','Alerts ITS'));    
        return options;
    }
    
    public String getcaseOrigin() {
        return caseOrigin;
    }
    
    public void setcaseOrigin(String countries) {
        this.caseOrigin= caseOrigin;
    }
    
     public PageReference BusCancelSubmit()
    {
        Group noncallableQueueId=[Select Id from Group where name='Non Callable Queue' limit 1];
        string recId = ApexPages.currentPage().getParameters().get('recId');
        Case caseObj = new Case();
        caseObj.Issue_Type__c = 'Bus Cancellation';
        caseObj.Issue_Sub_Category__c = 'Initiate Bus Cancellation';
        
       list<RPW_BO_ids__mdt>  boltMetaData = [SELECT Id,Bolt_Bo_ids__c,Non_Callable_BO_Id__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
       Set<String> instantRefundBoIds = new Set<String>(boltMetaData[0].Bolt_Bo_ids__c.split(','));
       
       List<Service_Provider__c> servList =[SELECT Operator_Id__c,Location__c,BD_Email__c,BD_Email1__c,BO_Email__c,BO_Email1__c,BO_Type__c FROM Service_Provider__c where Operator_Id__c= :ordItm[0].Service_Provider_Id__c];
       if(servList.size()>0){
            for(Service_Provider__c se:servList){
               if(se.BO_Type__c =='Non Callable' && !instantRefundBoIds.contains(ordItm[0].Service_Provider_Id__c) ){
                  caseObj.status='Awaiting BO/BD Response';
                  caseObj.Origin ='Complaint Tracker';
                  caseObj.ownerid=noncallableQueueId.id;

               }else{
                  caseObj.Status = 'Initiated';
                  caseObj.Origin = caseOrigin;
                  caseObj.ownerid=UserInfo.getUserid();
               }
            }
        }
        caseObj.BO_Description__c =cObj.BO_Description__c;   
        caseObj.Transaction_ID__c = recId;
        caseObj.Business_Unit_ct__c = ordItm[0].Business_Unit__c;
        String conBusUnit = 'REDBUS_'+ordItm[0].Business_Unit__c.split('_')[1];
        caseObj.Business_Type__c=OrderItemTransactionResource__c.getValues(conBusUnit).Case_Business_Type__c;
        caseObj.country__c=OrderItemTransactionResource__c.getValues(conBusUnit).Case_Country__c;
        caseObj.recordtypeid= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        System.debug('cObj.ParentId..'+cObj.ParentId);
        caseObj.ParentId = cObj.ParentId;        
        
        try{
            insert caseObj;      
            
            system.debug('--caseObj--'+caseObj);
            
            Case caseRec= [select casenumber from Case where id=:caseObj.Id limit 1];
            
            system.debug('--caseRec--'+caseRec);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Case has been created successfully. Case Number:'+caseRec.casenumber);
            ApexPages.addMessage(myMsg);
            
            ClosePopup =true;
        }catch(Exception e){
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                ApexPages.addMessages(e);
            else
            {
                
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.Type__c ='Bus Cancellation Duplicate Insertion Fail';
                dbl.Payment_Transaction_Name__c=recId;
                dbl.Exception_Description__c = e.getMessage();
                insert dbl;
            }
            
        }
        return null;
    }
    
    public PageReference NEFTSubmit() 
    {
        if(accnt.Amount__c <=0 )
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Amount Should be greater than 0');
            ApexPages.addMessage(myMsg);
            ClosePopup =false;
            return null;
        }
        
        string walletCheckStatus =  checkWalletBalance(accnt.id);
        
        if(String.isNotBlank(walletCheckStatus))
        {
            if(walletCheckStatus == 'Insufficient Wallet Balance' || walletCheckStatus == 'Refund amount is less than or equal to 0.' || walletCheckStatus == 'Wallet Does not exist' || walletCheckStatus =='Wallet Balance Check Ping Failed')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,walletCheckStatus);
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        string userId= ApexPages.currentPage().getParameters().get('userId'); 
        string PersonMobilePhone= ApexPages.currentPage().getParameters().get('PersonMobilePhone'); 
        string PersonEmail= ApexPages.currentPage().getParameters().get('PersonEmail');
        string AccntId= ApexPages.currentPage().getParameters().get('id');     
        
        update accnt;
        
        Group gp= [SELECT Id, Name, Type FROM Group where Type='Queue' and Name = 'NEFT Walelt Debit'];      
        
        Case caseRec = new Case();
        caseRec.status='Open';
        caseRec.Issue_Type__c='NEFT Wallet Debit';
        caseRec.OwnerId= gp.Id;
        caseRec.AccountId= accnt.Id;
        caseRec.InitiatedBy__c =UserInfo.getName()+'('+UserInfo.getUserName()+')';
        caseRec.Amount__c = accnt.Amount__c;
        caseRec.Review__c = accnt.Review__c;
        caseRec.Description = accnt.Description;
        caseRec.Origin= 'InBound Call';
        caseRec.IFSC_Code__c = accnt.IFSCCode__c;
        caseRec.Bank_Name__c = accnt.BankName__c;
        caseRec.Account_Holder_Name__c = accnt.Beneficiary_Name__c;
        caseRec.Account_Number__c = accnt.Bank_Account_Number__c;       
        caseRec.recordtypeid= Schema.SObjectType.Case.getRecordTypeInfosByName().get('NEFT Wallet Debit').getRecordTypeId();
        insert caseRec;
        
        Case caseRes= [select casenumber from Case where id=:caseRec.Id limit 1];
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Case has been created successfully. Case Number:'+caseRes.casenumber);
        ApexPages.addMessage(myMsg);
        
        ClosePopup =false;
        return null;
    }
    
    public string checkWalletBalance(string accntId)
    {
        NEFTResponse resp = new NEFTResponse();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        HttpResponse res = new HttpResponse();   
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        API_EndPoints__mdt apiProp = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Wallet_Balance_Check'];
        
        try
        {       
            system.debug('******accnt *******'+accnt );
            string tempuserid = string.isblank(accnt.User_Id__c) ? '' : accnt.User_Id__c;
            
            string jsonbody = '{"emailId":"'+accnt.PersonEmail+'","phone":"'+accnt.PersonMobilePhone+'","userId":"'+tempuserid +'","amount":"'+string.valueof(accnt.Amount__c)+'"}';
            System.debug('body....'+jsonbody);
            
            req = HttpRequestUtil.populateHeaders(req);
            req.setMethod('POST');            
            req.setBody(jsonbody);
            req.setEndpoint(apiProp.Endpoint__c);
            
            dbl.Type__c = 'NEFT Wallet Debit - Balance Check';
            dbl.Payment_Request_Sent_Time__c = system.now();
            //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+jsonBody;
            dbl.Request_Data__c = string.valueof(req)+jsonBody;
            dbl.SentAt__c = system.now();
            
            res = http.send(req);
            string responseValue = res.getBody();
            Case caseObj = new Case(); 
            dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            
            
            if(res.getStatus()=='OK' && res.getStatusCode()==200)
            {
                system.debug('------responseValue---------------'+responseValue);
                resp  = (NEFTResponse)JSON.deserialize( responseValue, NEFTResponse.class);
                system.debug('------resp  status 200---------------'+resp  );
                
                if(resp != null && resp.Status !=null && resp.Status.statusCode=='200' && (resp.ResponseMessage =='Success'))
                {
                    dbl.Payment_Ping_Status__c = 'Wallet Balance Check Success';
                }
                else
                {
                    dbl.Payment_Ping_Status__c = 'Wallet Balance Check Failed-'+resp.ResponseMessage;
                }
                
                if(resp.ResponseMessage == 'Insufficient Wallet Balance')
                {
                    dbl.Payment_Ping_Status__c = 'Insufficient Wallet Balance';
                }
                if(apiProp.EnableLog__c)
                    insert dbl;
                
                return resp.ResponseMessage;
            }
            else
            {
                dbl.Payment_Ping_Status__c = 'Wallet Balance Check Ping Failed';
                
            }
            
            if(apiProp.EnableLog__c)
                insert dbl;
            
            return 'Wallet Balance Check Ping Failed';   
            
            
        }
        Catch(Exception e)
        {
            dbl.Response_Received__c = String.valueOf(res+'..Body..'+res.getBody());
            //dbl.Payment_Request_Response_Data__c = String.valueOf(res+'..Body..'+res.getBody());
            dbl.Payment_Request_Response_Time__c = System.now();
            dbl.Payment_Ping_Status__c = 'Wallet Balance Check Exception';
            dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());              
            system.debug('-------Wallet Balance API--Exception---------------'+e);
            
            if(apiProp.EnableLog__c)
                insert dbl;
            
            if(ApexPages.currentPage()!=null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
            
        }
    }
    
    public void updateARNNumber()
    {
        /* HttpRequestWrappersUtil.PaasRefundUpsertRequest refReq = new HttpRequestWrappersUtil.PaasRefundUpsertRequest();
refReq.isInsertTrue = false;
refReq.refundStatus = HttpRequestWrappersUtil.RefundStatus.SUCCESS;
refReq.refundMsg ='Refunded From Console';
refReq.requestId =selRecId;
refReq.orderId ='';// Payment UUID d.orderId;
refReq.transactionId ='' // RB Pg reference Id d.transactionId ;
refReq.bankArnNumber =arnNumber;
refReq.amount =d.amount;
refReq.refundedBy =UserInfo.getName()+'('+UserInfo.getUserName()+')';
refReq.modifiedSource = 'SFA';
refReq.initiatedTime = refundedDate==null? String.valueOf(System.Today()):String.valueOf(refundedDate);

dbl.type__c ='Update PG Ref in Paas';
dbl.Payment_Items_Success__c = selRecId;
dbl.Payment_Ping_Status__c = 'Payment Ping Initiated';
dbl.Orders_Received_Data_Ids__c = d.trexOrderUuid;
dbl.Payment_Items_Data_Received_Ids__c = d.orderId;
dbl.Payment_Items_Process_Status__c = d.transactionId;*/
        
    }
    
    public void updateRefundStatus()
    {
        List<String> listPayType = new List<String>();
        listPayType = System.Label.PaymentItemType.split(',');
        List<Payment_Items__c> listPayitems = new List<Payment_Items__c>();
        listPayitems =[Select Guid__c from Payment_Items__c Where Payment_System__c IN :listPayType AND Order_Item_Name__c=:lstordrItm[0].id AND (Payment_Status__c='COMPLETED' OR Latest_Payment_Status__c='SUCCESS')];
        String omsReq = '{"refNo":"'+refundRefNum+'","orderItemId":"'+lstordrItm[0].Guid__c+'","channel":"SFA","refundStatus":"'+refStatus+'"}';
        HttpResponse resp = new HttpResponse();
        String endpoint = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='OMSIntlRefundUpdate'].Endpoint__c+listPayitems[0].Guid__c+'/refunds';
        System.debug('endpoint ...'+endpoint +'..'+Json.serialize(omsReq));
        Map<String, String> omsHeaders= new Map<String, String>();
        omsHeaders.put('Content-Type','application/json');
        resp = HTTPUtil.sendGenericHTTPRequest(endpoint,'PUT',Json.serialize(omsReq),omsHeaders,100000,'OMS GFT Refund Status Update');
        
        try
        {
            if(resp!=null && resp.getStatusCode()==200 && String.isNotBlank(resp.getBody()))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Refund Status Has Been Updated Sucessfully');
                ApexPages.addMessage(myMsg);
                ClosePopup =true;
                
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Refund Status Update Has Failed'+resp.getBody());
                ApexPages.addMessage(myMsg);
            }
        }
        Catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error Occured While Updating Refund Status'+String.valueOf(e));
            ApexPages.addMessage(myMsg);
        }
    }
    public class NEFTResponse
    {
        public string ResponseMessage{get;set;}
        public Status status{get;set;}
    }
    
    public class Status
    {
        
        public string code {get;set;}
        public string statusCode {get;set;}
        public string statusMessage {get;set;}
        public string error {get;set;}
        public string type{get;set;}
        
        public Status()
        {
            System.debug('Testing..'+code+statusCode+statusMessage+error+type);       
        }
    }    
    
    /* public PageReference confirmGFT()
{
if(String.isNotBlank(seatno))
{
String[] listSeats = seatno.split(',');
System.debug('listSeats...'+listSeats);
if(lstordrItm[0].No_of_seats__c!=listSeats.size())
{
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Total number of seats requested by the customer is '+lstordrItm[0].No_of_seats__c+' but updated seat numbers count is '+listSeats.size()+' only.So,please update properly..'));
return null;
}
}

DBLog_Summary__c dbl = new DBLog_Summary__c();
dbl.type__c ='GFT Confirmation Call';
Http ht = new Http();
HttpRequest reqq = HttpRequestUtil.populateCAPIHeaders(new HttpRequest(),lstordrItm[0].Business_Unit__c);
HttpResponse resp = new HttpResponse();
system.debug('listval=>>'+lstordrItm);
reqq.setEndpoint([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ConfirmGFT'].Endpoint__c+'/'+lstordrItm[0].Guid__c+'?pnr='+pnrvalue+'&seatnames='+seatno);
system.debug('setEndpoint==>>'+reqq.getEndpoint());
reqq.setMethod('POST');
String jsonbdy ='';
reqq.setbody(jsonbdy);
dbl.Request_Data__c = String.valueOf(reqq.getEndpoint())+'..Body :'+jsonbdy+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+reqq.getHeader('Country_Name')+',SelectedCurrency:'+reqq.getHeader('SelectedCurrency');
dbl.Payment_Ping_Status__c ='GFT Conformation Ping Initiated';
try
{

resp=ht.send(reqq);
system.debug('resp==>'+resp);
dbl.Response_Received__c=String.valueof(resp);

if(resp!=null && resp.getStatusCode()==200 && String.isNotBlank(resp.getbody()))
{

Boolean isSuc =false;
dbl.Payment_Ping_Status__c ='GFT Conformation Ping Success';
dbl.Response_Received__c=String.valueof(resp)+'.Response Body..'+String.valueOf(resp.getbody());
map<string,object> respmsge= (map<string,object>)JSON.deserializeUntyped(resp.getBody());
isSuc = respmsge.containsKey('IsSuccess')?Boolean.valueOf(respmsge.get('IsSuccess')):false;
String tinval =respmsge.containskey('tin')?string.ValueOf(respmsge.get('tin')):'';

if(isSuc)
{
dbl.X0_PG_Reference_ID__c = true;
ClosePopup =true;
lstordrItm[0].Order_Item_Reference_No__c=tinval;
lstordrItm[0].status__c='TR_COMPLETED_PO_COMPLETED';
lstordrItm[0].Service_Provider_Reference_No__c = pnrvalue;
lstordrItm[0].Service_Provider_Reference_PNR_No__c = pnrvalue.left(244);
lstordrItm[0].Transaction_Status__c = 'Booked';
update lstordrItm;
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Conformation has completed successfully.Please note tin number-'+tinval));

}
else
{
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Conformation has failed.Please retry..');
ApexPages.addMessage(myMsg);
}

}
else
{
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Recievd Invalid Response From Server.Please retry..'));
dbl.Payment_Ping_Status__c ='GFT Conformation Ping Failed';
dbl.Exception_Description__c = String.valueOf(resp.getBody());
}
}
catch(Exception e)
{
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'An Error Occured..'+String.valueOf(e)));
dbl.Exception_Description__c = String.valueOf(e);
system.debug('resp=>'+String.valueOf(e));
}
insert dbl;
return null;
}*/
    public List<SelectOption> getCallOptions() {
        List<SelectOption> Options = new List<SelectOption>();
        Options.add(new SelectOption('','-None-'));
        Options.add(new SelectOption('Working','Working'));
        Options.add(new SelectOption('Engaged','Engaged'));
        Options.add(new SelectOption('Not Reachable','Not Reachable'));
        Options.add(new SelectOption('Not Answered','Not Answered'));
        Options.add(new SelectOption('Switched Off','Switched Off'));
        return Options;
    }
    public PageReference wrongBPnumber()
    {
        
        if(mobileNo=='' || commnts==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter mobileNo/Comments'));
            
        }else{
            
            list<BPNumberRequestWrapper> bpWrapperList = new list<BPNumberRequestWrapper>();
            String bpId = boList.isEmpty()?'':String.isBlank(boList[0].Boarding_Point_ID__c)?'':boList[0].Boarding_Point_ID__c;
            for(Order_Items__c oi :lstordrItm)
                bpWrapperList.add(new BPNumberRequestWrapper(oi.Service_Provider_Id__c, oi.Service_Provider_Name__c,bpId,oi.Agent_IP__c,oi.Boarding_Point__c,'0',selCallopt,mobileno,commnts));  
            
            String bpJson=json.serialize(bpWrapperList); 
            System.debug('bpJson-->'+bpJson);
            // API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            // APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='BPNumber'];
            Group BDQ=[select id from Group where type='Queue' AND developername='BD_Queue']; 
            Group BDintlQ=[select id from Group where type='Queue' AND developername='bdsupport_international'];
            Group ISEqueue=[select id from Group where type='Queue' AND developername='ISE_queue'];

            /* Http h= new Http();
        	HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
           	req = HttpRequestUtil.populateHeaders(req);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(APIMData.Endpoint__c);
            req.setMethod('POST');
            req.setBody(bpJson);            
            res=h.send(req);
            System.debug('Response-->'+res.getBody());
            String respString =res.getbody();
            System.debug('respString ..'+respString);
            system.debug('containsIgnoreCase==>>'+respString.containsIgnoreCase('"Duplicate')); */
            try{
                // if(res!=null && res.getStatusCode()==200 && String.isNotBlank(respString)){
                case c=new case();
                c.Description=commnts;
                c.Issue_Type__c='I need help to board my Bus';
                c.Issue_Sub_Category__c ='Issue with BO contact number';
                c.Origin='InBound Call';
                    
                    
                If('Working'.equalsIgnoreCase(selCallopt))
                {
                 	c.Closed_By_Agent_Role__c='Inbound';
                    c.Closed_By_Agent__c =UserInfo.getUsername();
                    c.status ='Closed';
                }
                else
                {
                	if(string.isNotBlank(string.valueof(lstordrItm[0].Business_Unit__c))){
                    	c.Business_Unit_ct__c='REDBUS_'+lstordrItm[0].Business_Unit__c.split('_')[1];
                        if(OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Country__c != null){
                        	if(OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Country__c == 'Singapore' || OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Country__c == 'Malaysia'){
                            	c.OwnerId=BDintlQ.id;                           
                            }
                            else{
                            	c.ownerid=BDQ.id;                            
                           	}                            
                       	}
                   	}
                        
                    c.Assigned_to_BD__c=System.now();
                    c.Assigned_By__c= UserInfo.getUserID();
                    c.Assigned_to_BD_OwnerName__c=UserInfo.getUsername();
                        
                    if(c.Business_Unit_ct__c=='REDBUS_ID'){
                    	c.status ='Escalated to ISE';
                        c.OwnerId=ISEqueue.id;
                 	}else{
                       	c.status = 'Escalated to BD';
                   	}
                        
              	}
                c.transaction_id__c=lstordrItm[0].id;
                c.Phone_No_ct__c=mobileno;
                if (string.isNotBlank(lstordrItm[0].Agent_IP__c)){
                	c.BP_Contact_Number__c =lstordrItm[0].Agent_IP__c;
               	}
                if(string.isNotBlank(string.valueof(lstordrItm[0].Business_Unit__c)))
                {
                	c.Business_Unit_ct__c=lstordrItm[0].Business_Unit__c;
                    c.country__c=OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Country__c;
                    c.Business_Type__c=OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Business_Type__c;
                }
                insert c;
                ApexPages.Message myMsg;
                if (c.Id != null) {
	                String caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :c.Id].CaseNumber;
                	myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your qeury is noted and case is created :'+ caseNumber);
                }
                else {
                   	myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Case insertion failed.');

                }
				ApexPages.addMessage(myMsg);
                /* if(respString.containsIgnoreCase('"Duplicate') || respString.containsIgnoreCase('"Success')){
                        
              		myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,respString);
                	system.debug('myMsg==>>'+myMsg);
                	ClosePopup =true;
                        
               	}else
                	myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,respString);
                    
            	ApexPages.addMessage(myMsg);
                    
                }
                else
                {
                	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,respString+'.Please retry..'); 
                    ApexPages.addMessage(myMsg);
                } */
                
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,''+e));
            }
            
        }  
        return null;
    }
    
    public void sendSMS(){
        
        if(mobileNo=='' || description==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter mobileNo/Description'));
            
        }else{
            http ht=new http();
            Httprequest req=new httprequest();
            httpresponse resp=new httpresponse();
            string fromatedDescription='{"Description":"'+description+'"}';          
            RequestWrapper.SendNotificationWrapper smsJ=new RequestWrapper.SendNotificationWrapper(mobileNo,fromatedDescription,'General_Query_SMS','',true);
            String smsJsonBody=JSON.serialize(smsJ);
            req.setHeader('Channel_Name','WEB_DIRECT');
            req.setHeader('Content-Type','application/json');
            req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
            req.setHeader('Country_Name', 'IND'); 
            req.setHeader('BusinessUnit', 'BUS');  
            req.setHeader('Language', 'en');             
            req.setMethod('POST');
            API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'];
            req.setEndpoint(APIMData.Endpoint__c);
            req.setBody(smsJsonBody);
            try{
                resp = ht.send(req);
                System.debug('resp-->'+resp.getbody());
                case c=new case();
                if(resp!=null){
                    c.Description=description;
                    c.Issue_Type__c='SMS';
                    c.Origin='InBound Call';
                    c.status='Closed';
                    c.transaction_id__c=lstordrItm[0].id;
                    c.Phone_No_ct__c=mobileno;
                    insert c;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'SMS sent successfully'));
                    ClosePopup =true;
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SMS Failed to send, Please try again!!'));
                }
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SMS Failed to send, Please try again!!'+e));
            }
        }
    }
    
    public void callToBo()
    {
        user uObj=[select id,Phone,MobilePhone,CZentrix_Agent_Id__c from user where id=:UserInfo.getUserID()];
        
        if(String.isBlank(mobileNo) || String.isBlank(uObj.CZentrix_Agent_Id__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'BO Mobile Number Is Missing Or Agent Id Is Not Configured In C-Zentrix'));
        }
        
        else
        { 
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SinfinyCall'];
            
            string jsonBody;
            
            RequestWrapper.BOCallWrapper boWrap=new RequestWrapper.BOCallWrapper(mobileNo,uObj.MobilePhone,cObj,uObj.CZentrix_Agent_Id__c);
            String boCallerJson=json.serialize(boWrap); 
            System.debug('boCallerJson-->'+boCallerJson);
            HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req); 
            req.setMethod('POST');
            req.setBody(boCallerJson);
            req.setEndpoint(APIMData.Endpoint__c);  
            CZentrix_Info__c cInfObj=new CZentrix_Info__c();
            cInfObj.Call_Type__c='BO Call';
            try{          
                res=h.send(req); 
                if(res!=null && String.isNotBlank(res.getbody()))
                {
                    map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
                    System.debug('resObj-->'+resObj);
                    System.debug('status-->'+boolean.valueof(resObj.get('status')));
                    if(resObj.containsKey('status') && boolean.valueof(resObj.get('status'))==true)
                    {
                        System.debug('resp-->'+res.getbody());
                        cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                        cInfObj.Case__c=cObj.id;
                        cInfObj.Agent_Phone_Number__c=uObj.MobilePhone;
                        cInfObj.Campaign_Name__c='SIT Calling';
                        cInfObj.BO_Phone_Number__c=mobileNo;
                        cInfObj.Operator_Id__c=cObj.Service_Provider_Id__c;
                        cInfObj.Operator_Name__c=cObj.Bus_Operator_Name__c;
                        cInfObj.TIN__c=cObj.TIN_No__c;
                        cInfObj.Message__c='Success';
                        cInfObj.Agent_ID__c = String.valueOf(uObj.CZentrix_Agent_Id__c);                   
                        insert cInfObj;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Call will connect soon'));
                    } 
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Received Invalid Status From API, Please try again'));                    
                }                
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Response from API, Please try again'));                
            } 
            
            catch(Exception e){        
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error Occered, Please try again!!'));
            }               
        }
    }
    
    
    public object B2BBusCancellationInitiation(){
        string recId = ApexPages.currentPage().getParameters().get('recId');
        lstordrItm = new list<Order_Items__c>();
        lstordrItm =[select id,Boarding_Time__c,Inventory_Type__c,recordtypeid,RecordType.Name,Guid__c,Mobile__c,Transaction_Status__c,Service_Provider_Id__c,Service_Provider_Name__c,Boarding_Point__c,Agent_IP__c,Service_Provider_Reference_PNR_No__c,Service_Provider_Reference_No__c,status__c,Order_Item_Reference_No__c,Business_Unit__c,Order_Id__c,Cancellation_Policy__c,Route_Id__c,DOI_DOJ__c,Seat_No__c,No_of_seats__c from Order_Items__c where id=:recId];
        
        API_EndPoints__mdt APIMData= [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='B2BBusCancellation'];   
        user uObj=[select id,Phone,MobilePhone,email from user where id=:UserInfo.getUserID()];
        string jsonBody='{"tin":"'+lstordrItm[0].Order_Item_Reference_No__c+'","agentId":"'+uObj.email+'"}';  
        OAuthGeneric oauthObj=new OAuthGeneric(); 
        dbLogBC=new DBLog_Summary__c();     
        Http h= new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(APIMData.Endpoint__c);
        req.setMethod('POST');
        req.setBody(jsonBody);    
        string oauthParams=oauthObj.sign(req,lstordrItm[0].Inventory_Type__c);        
        string endPoint=APIMData.Endpoint__c+'?'+oauthParams;
        req.setEndpoint(endPoint);  
        dbLogBC.Type__c='B2B-Bus Cancellation';
        dbLogBC.Request_Data__c = string.valueof(req)+'..Body..'+String.valueOf(jsonBody);
        dbLogBC.EndPoint__c = String.valueOf(req.getEndpoint());
        Continuation con = new Continuation(120);         
        con.continuationMethod='GetB2BBusCancellationResponse';
        this.busCReq= con.addHttpRequest(req); 
        return con;
        
    }
    
    public object GetB2BBusCancellationResponse(){
        try{
            HttpResponse response=new HttpResponse();
            response= Continuation.getResponse(this.busCReq);
            this.busCResp= response.getBody();     
            dbLogBC.CallOut_Status__c = string.valueOf(response.getStatus());                
            dbLogBC.Response_Received__c=this.busCResp;
            dbLogBC.CallOut_Status_Code__c = string.valueOf(response.getStatusCode());    
            map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(this.busCResp);
            if(resObj!=null && string.valueof(resObj.get('status'))=='Initiated'){
                string recId = ApexPages.currentPage().getParameters().get('recId');
                Case caseObj = new Case();
                caseObj.Issue_Type__c = 'Bus Cancellation';
                caseObj.Issue_Sub_Category__c = 'Initiate Bus Cancellation';
                caseObj.Status = 'Initiated';
                caseObj.Origin = caseOrigin;
                caseObj.Transaction_ID__c = recId ;
                caseObj.SS_DOJ__c=lstordrItm[0].Boarding_Time__c;
                caseObj.Country__c='India';
                caseObj.Business_Type__c='Domestic-Bus';
                caseObj.recordtypeid= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
                System.debug('cObj.ParentId..'+cObj.ParentId);
                caseObj.ParentId = cObj.ParentId;
                caseObj.Type='B2B';
                caseObj.Partner__c='Amazon';
                try{
                    insert caseObj;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Bus Cancellation case has been created successfully.'));
                }catch(Exception e){
                    dbLogBC.Exception_Description__c=string.valueOf(e);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Case Insert Failed. Error->'+e));            
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Request Failed. Error->'+this.busCResp));            
            }
        }catch(Exception e){
            dbLogBC.Exception_Description__c=string.valueOf(e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong! Exception->'+e));            
        }
        insert  dbLogBC;
        return null;
    } 
    
    
    public void markPaymentCompelted(){
        system.debug('--selectedPGid--'+selectedPGid);
        if(pgRefId==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter PG Reference Id'));
            
        }else{
            Group payUpdQu=[select id from Group where type='Queue' AND developername='Payment_Update_Queue']; 
            Group intlpayUpdQu=[select id from Group where type='Queue' AND developername='Intl_Payment_Update_Queue']; 
            Group RedbusComUpdQu=[select id from Group where type='Queue' AND developername='Redbus_Com_Queue']; 
            
            case c=new case();
            c.Issue_Type__c='Payment done and ticket not given';
            c.Origin='InBound Call';
            c.Issue_Sub_Category__c='Mark Payment As Completed';
            c.status='Open';
            system.debug('---pay--');
            try{
                system.debug('paymntItemlst--'+paymntItemlst[0].Order_Item_Name__c);
                c.transaction_id__c=string.isBlank(paymntItemlst[0].Order_Item_Name__c)?null:paymntItemlst[0].Order_Item_Name__c;
                c.PG_Ttransaction_Id__c=pgRefId;
                c.Payment_Item_UUID__c=string.isNotBlank(paymntItemlst[0].Guid__c)?paymntItemlst[0].Guid__c:'';
                c.All_Payment_Online_UUIDs__c=allPaymnetOnlineUUIds;
                c.PG_Id__c=selectedPGid;
                c.Business_Unit_ct__c =string.isNotBlank(paymntItemlst[0].Order_Item_Name__r.Business_Unit__c)?paymntItemlst[0].Order_Item_Name__r.Business_Unit__c:'';
                
                if(string.isNotBlank(c.Business_Unit_ct__c)){
                    if('REDBUS_COM'.equalsIgnoreCase(c.Business_Unit_ct__c)){  
                        c.country__c=OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Country__c;
                        c.Business_Type__c=OrderItemTransactionResource__c.getValues(c.Business_Unit_ct__c).Case_Business_Type__c;
                    }else{
                        String conBusUnit = 'REDBUS_'+paymntItemlst[0].Order_Item_Name__r.Business_Unit__c.split('_')[1];
                        c.country__c=OrderItemTransactionResource__c.getValues(conBusUnit ).Case_Country__c;
                        c.Business_Type__c=OrderItemTransactionResource__c.getValues(conBusUnit ).Case_Business_Type__c;
                    }
                } 
                
                if('India'.equalsIgnoreCase(c.country__c)){
                    c.ownerid=payUpdQu.id;
                }else if('REDBUS_COM'.equalsIgnoreCase(c.Business_Unit_ct__c)){
                    c.ownerid=RedbusComUpdQu.id;
                }else{
                    c.ownerid=intlpayUpdQu.id;
                }
                
                
                insert c;   
                String csNum = [SELECT id,caseNumber FROM Case WHERE Id =:c.id].caseNumber;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Case has been created successfully.Case Number is -'+csNum));
                ClosePopup =true;
            }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Case Creation Has Failed.Error Details->'+e));            
            }
        }
        
    }   
    
    public class BPNumberRequestWrapper{
        public string Operatorid;
        public string Operatorname;
        public string Bpid;
        public string Bpnumber;
        public string Bpname;
        public string status;
        public string calstatus;
        public string custBpNo;
        public string custComments;
        public BPNumberRequestWrapper(string Operatorid,string Operatorname,string Bpid,string Bpnumber,string Bpname,string status,string calsts ,string mobile,string cmnts){
            this.Operatorid=Operatorid;
            this.Operatorname=Operatorname;
            this.Bpid=Bpid;
            this.Bpnumber=Bpnumber;
            this.Bpname=Bpname;
            this.status=status;
            this.calstatus = calsts;
            this.custBpNo = mobile; 
            this.custComments =cmnts;
            
        }               
    }
}