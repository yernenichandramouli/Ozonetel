/**
* (c) 2019 RedBus
*
* Name           : redBusCancellation
* Created Date   : 2 Feb 2017
* Created By     : Sreenivas M
* Purpose        : Controller class for redbusCancellation Page.
*
**/

public class redBusCancellation 
{
    public string orItemId;
    public Cancellation_Process_DB_Log__c CP {get; set;}
    string Channel_Name;
    string auth_key;
    string Country_Name;
    string SelectedCurrency;
    string BusinessUnit;
    Map<string,string> bodyValue;
    Map<string,string> headers;
    public list<SectionSeatNo> SeatAvailable {get; set;}
    public Order_Items__c orIt{get;set;}
    Map<String,RefundAPISettings__c> SyncSettings;
    string userName;
    public boolean forceAPICalled{get;set;}
    public boolean normalAPICalled{get;set;}
    public boolean hide1stButton{get;set;}
    public List<Cancellation_Process_DB_Log__c> existCPS{get;set;}
    
    public string Tot_amount_paid {get;set;}
    Public string Total_fare_Amount {get;set;}
    public string Insurance_charge {get;set;}
    public string Cancellation_charge {get; set;}
    public string Redbus_discount {get;set;}
    public string Operator_discount {get;set;}
    public string Refund_amount {get; set;}
    public boolean showBreakUp{get;set;}
    public string detailed_msg {get;set;}
    public boolean Is_non_refundable {get;set;}
    public string fareAmount{get;set;}
    public string refundAmount{get;set;}
    public string seatNo{get;set;}
    public boolean showPartialBreakup{get;set;}
    public double forceCancelRefundAmnt{get;set;}
    public string fcuDeniedReason{get;set;}
    public string selStatus{get;set;}
    public List<Cancelled_Order_Items__c> canOrdItem{get;set;}
    public Cancellation_Process_DB_Log__c cpsLog{get;set;}
    public String operCancellationStatus{get;set;}
    public Boolean showRefundBreakup{get;set;}
    public String refundDescription{get;set;}
    public Set<String> setCodes;
    public boolean refundCaseExists{get;set;}
    public String exceptionalRefundReason{get;set;}
    public Case csObj{get;set;}
    public String parentCase{get;set;}
    //public map<string, object> partialCancelSeatsAllow=(map<string,object>)IsCan.get('fullCancellationBreakUp');
    public list<object> partialCancelAllowedSeats{get;set;}
    public list<object> addonCancelAllowed{get;set;}
    public string primarySeatMsg{get;set;}
    public String country;
    public String selCurrency;
    public String wlOperName='';
    public list<addOnWrapper> addonList{get;set;}
    public decimal canRefundAmount{get;set;}
    public decimal addOnsRefund{get;set;}
    public string comCurrency{get;set;}
    public string PhysCancellationStatus{get;set;}
    public string selOptrStatus{get;set;}
    public string physCanclDeniedReason{get;set;}
    public string cnrVale{get;set;}
    public Boolean optrstatusPanel{get;set;}
    public double suggestedAmount{get;set;}
    Public string ZQPtin{get;set;}
    public Boolean isZQPrefundType{get;set;}
    public Set<String> instantRefundBoIds{get;set;} 
    public Boolean enableBolt{get;set;}
    public string tinNumber{get;set;}
    public string physCanclErrorMsg{get;set;}
    public boolean isPhysCanclErrorMsg {get ; set;}
    
    public redBusCancellation(ApexPages.StandardController controller) 
    {
        csObj = new Case();
        partialCancelAllowedSeats=new list<object>();
        showRefundBreakup = false;  
        refundCaseExists = false;   
        isZQPrefundType =false;      
        isPhysCanclErrorMsg = false;  
        //pWrapList=new list<PCWrapper>();
        cpsLog = new Cancellation_Process_DB_Log__c();
        orItemId = ApexPages.currentPage().getParameters().get('id'); 
        showBreakUp = false;        
        CP = new Cancellation_Process_DB_Log__c();
        CP.Max_Refundable_Amount__c=0;
        CP.FC_Refund_Amount__c = 0;
        CP.Full_Cancellation_Type__c ='Full Cancelllation';
        SeatAvailable = new list<SectionSeatNo>();
        orIt = new Order_Items__c();
        SyncSettings = RefundAPISettings__c.getAll();
        optrstatusPanel=false;
        list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
        instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
        
        if('Integration User'.equalsIgnoreCase(UserInfo.getName()) || 'Test User'.equalsIgnoreCase(UserInfo.getName()))
            userName = '('+UserInfo.getUserName()+')';
        
        else
            userName =UserInfo.getName()+'('+UserInfo.getUserName()+')';
        forceAPICalled = false;
        hide1stButton = false;
        normalAPICalled = false;
        setCodes  = new Set<String>();        
        setCodes.addAll(System.Label.IsTicketCancellableCodes.split(','));
        existCPS = new List<Cancellation_Process_DB_Log__c>();
        canOrdItem = new List<Cancelled_Order_Items__c>();  
        if(!string.isBlank(orItemId))
        {
            orIt = [select id, id__c,status__c,Total_Fare_Value__c,Boarding_Time__c,Umbrella_TIN__c,Connected_Items__c,Corrected_Date_of_Journey__c,Total_Fare_Currency__c,Route_Id__c,Service_Provider_Id__c,Source__c,Destination__c,Mobile__c,OrderUuid__c,Service_Provider_Reference_No__c,Amount_Recieved_Currency__c,Order_Id__c,Seat_No__c,Guid__c,Order_Name__r.Guid__c,Business_Unit__c,Transaction_Status__c,Order_Item_Reference_No__c,Item_Type__c, Email__c, Email_Copy__c,(SELECT Id,Refund_Reason__c from Refund_Order_Items__r) from Order_Items__c where id=:orItemId limit 1];
            if(!orIt.Business_Unit__c.startsWithIgnoreCase('REDBUS'))
                wlOperName = orIt.Business_Unit__c.split('_')[0];
            
            if(instantRefundBoIds.contains(orIt.Service_Provider_Id__c)){
                enableBolt=true;
            }else{
                enableBolt=false;
            }
            
            if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
                comCurrency=orIt.Amount_Recieved_Currency__c;
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
                }else {
                    selCurrency = comCurrency;
                }
                
                country=OrderItemTransactionResource__c.getValues(orIt.Business_Unit__c).Case_Country__c;
                if(!'USD'.equalsIgnoreCase(comCurrency) && busUnit!=''){
                    String conmBusUnit = 'REDBUS_'+busUnit.split('_')[1];
                    selCurrency= OrderItemTransactionResource__c.getValues(conmBusUnit).Default_Currency__c;
                }
            }else{
                
                string busnsUnit =orIt.Business_Unit__c;
                String comnBusUnit = 'REDBUS_'+busnsUnit.split('_')[1];
                country = OrderItemTransactionResource__c.getValues(comnBusUnit)!= null?OrderItemTransactionResource__c.getValues(comnBusUnit).Auth_Key__c:'';
                selCurrency= OrderItemTransactionResource__c.getValues(comnBusUnit).Default_Currency__c;
            }
            
            if('TR_CANCELLATION_INITIATED_PO_COMPLETED'.equalsIgnoreCase(orIt.status__c) && string.isNotBlank(orIt.Business_Unit__c) && (orIt.Business_Unit__c.endsWith('_CO') || orIt.Business_Unit__c.endsWith('_PE'))){
                hide1stButton = true;
                PhysCancellationStatus=orIt.status__c;
            }
            system.debug('--country--'+country+'--currency--'+selCurrency);
            
            for(Refund_Order_Items__c refOrIt: orIt.Refund_Order_Items__r)
            {
                exceptionalRefundReason = String.isBlank(refOrIt.Refund_Reason__c)?'':refOrIt.Refund_Reason__c;
            }
            
            tinNumber = orIt.Order_Item_Reference_No__c;
            if(string.isNotBlank(tinNumber))
            {
                List<Case> existCase = new List<Case>();                  
                String query = 'Select '+ System.Label.ExceRefundCheckQuery +' From CASE Where Issue_Type__c=\'Exceptional Refund\' AND Refund_status__c!=\'Exceptional Refund Approved\' AND Refund_status__c!=\'Exceptional Refund Rejected\' AND TIN_No__c=:tinNumber';
                existCase = Database.query(query);
                refundCaseExists = existCase.isEmpty()?false:true;
                
            }
            canOrdItem = [Select id,Operator_Cancellation_Status__c from Cancelled_Order_Items__c where Order_Item_Name__c=:orItemId and Operator_Cancellation_Status__c ='OPERATOR_CANCELLATION_INITIATED' limit 1];
            if(!canOrdItem.isEmpty())
                operCancellationStatus = canOrdItem[0].Operator_Cancellation_Status__c;
            for(Cancellation_Process_DB_Log__c cpg : [SELECT Id,FC_IsSuccess__c,NC_IsSuccess__c,Refund_Reason__c FROM Cancellation_Process_DB_Log__c WHERE Transaction_Name__c =: orItemId AND Type__c !='Addons Cancellation' AND (FC_IsSuccess__c = True OR NC_IsSuccess__c = True)])
            {
                existCPS.add(cpg);
                if(String.isBlank(exceptionalRefundReason) && cpg.FC_IsSuccess__c && String.isNotblank(cpg.Refund_Reason__c))
                    exceptionalRefundReason = cpg.Refund_Reason__c;
            }
            
        }
    }
    
    //from here
    public void getRefundAmount()
    {  
        if(!string.isBlank(orItemId))
        {
            DBLog_Summary__c dbLog=new DBLog_Summary__c();
            // if((string.isNotBlank(string.valueof(orIt.Order_Item_Reference_No__c))||'Coupon'.EqualsIgnoreCase(orIt.Item_Type__c)) && (string.isNotBlank(string.valueof(orIt.Email__c)) || string.isNotBlank(string.valueof(orIt.Email_Copy__c))))
            if((string.isNotBlank(string.valueof(orIt.Order_Item_Reference_No__c))||'Coupon'.EqualsIgnoreCase(orIt.Item_Type__c))&& (string.isNotBlank(string.valueof(orIt.Email__c)) || string.isNotBlank(string.valueof(orIt.Email_Copy__c)) || string.isNotBlank(string.valueof(orIt.Mobile__c))) )
            {
                bodyValue = new map<string,string>();
                bodyValue.put('tin',orIt.Order_Item_Reference_No__c);
                if(string.isNotBlank(orIt.Email__c))
                    bodyValue.put('email',string.valueof(orIt.Email__c));
                
                else if(string.isNotBlank(orIt.Email_Copy__c))
                    bodyValue.put('email',string.valueof(orIt.Email_Copy__c));
                // no email flow - start
                else
                    bodyValue.put('email','');
                if(string.isNotBlank(orIt.Mobile__c))
                    bodyValue.put('mobileno',string.valueof(orIt.Mobile__c));
                else
                    bodyValue.put('mobileno','');
                //no email flow - end
                if('Coupon'.EqualsIgnoreCase(orIt.Item_Type__c))
                {
                    bodyValue.put('isAddonCancellation',string.valueof(true));
                    bodyValue.put('tin',orIt.Order_Id__c);
                }
                dbLog.Type__c='redBusCancellation-getRefundAmount';
                dbLog.Payment_Transaction_Name__c =orIt.Id;
                
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req = HttpRequestUtil.populateCAPIHeaders(req);
                req.setHeader('Country_Name',country);
                req.setHeader('SelectedCurrency',selCurrency);
                
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IsTicketCancellableURLV2'].Endpoint__c);
                req.setMethod('POST');
                req.setBody(JSON.serialize(bodyValue));
                cp.IsCacellable_API_Request_Data__c = string.valueof(req)+'Body :'+JSON.serialize(bodyValue)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency:'+selCurrency;
                dbLog.Request_Data__c=string.valueof(req)+'Body :'+JSON.serialize(bodyValue)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency:'+selCurrency;
                dbLog.EndPoint__c = String.valueOf(req.getEndpoint());
                
                if(String.isNotBlank(wlOperName))
                {
                    req.setHeader('Operator',wlOperName);
                    cp.IsCacellable_API_Request_Data__c = cp.IsCacellable_API_Request_Data__c+',Operator:'+wlOperName;
                }
                
                try
                {
                    system.debug('<<<req'+req);
                    system.debug('body'+req.getBody());
                    res = http.send(req);                      
                    system.debug('print'+res);
                    string responseValue = res.getBody();
                    dbLog.Response_Received__c=res.getbody();
                    dbLog.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                    dbLog.CallOut_Status__c = string.valueOf(res.getStatus());
                    cp.IsCacellable_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;
                    if(string.isNotBlank(string.valueof(responseValue)))
                    {
                        map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                        if(IsCan.ContainsKey('fullCancellationBreakUp'))
                        {                      
                            showBreakUp = true;
                            showPartialBreakup=false;              
                            map<string, object> fullCancellationBreakUp=(map<string,object>)IsCan.get('fullCancellationBreakUp');
                            
                            List<object> lstfareWithSeat= (List<Object>)fullCancellationBreakUp.get('fareWithSeat');
                            
                            map<string, object> MapFarewithSeat= (map<string,object>)lstfareWithSeat[0];
                            
                            Map<String,Object> mapFare= (map<string,object>)MapFarewithSeat.get('fareresponse');
                            
                            Total_fare_Amount =string.valueof(IsCan.get('totalFare'));
                            Tot_amount_paid =string.valueof(mapFare.get('fare'));
                            Insurance_charge =string.valueof(mapFare.get('insuranceCharges'));
                            Cancellation_charge =string.valueof(mapFare.get('canCharge'));
                            Redbus_discount =string.valueof(mapFare.get('offerValue'));
                            Operator_discount =string.valueof(IsCan.get('operatorDiscount'));
                            Refund_amount =string.valueof(mapFare.get('refAmount'));
                            list<object> addonObjList=(list<object>)IsCan.get('items');
                            canRefundAmount=0;
                            addOnsRefund=0;
                            CP.Max_Refundable_Amount__c = decimal.valueof(Refund_amount);
                            canRefundAmount=canRefundAmount+CP.Max_Refundable_Amount__c;
                            for(object o:addonObjList){
                                Map<string,object> inObj=(Map<string,object>)o; 
                                if(string.valueOf(inObj.get('itemType')) !='Bus'){
                                    double refAmt=double.valueOf(inObj.get('refundAmount'));
                                    canRefundAmount=canRefundAmount+refAmt;
                                    addOnsRefund=addOnsRefund+refAmt;
                                }
                                
                                if(string.valueOf(inObj.get('itemType')) =='Bus'){
                                    List<Object> refundBreakUpList = (List<Object>)inObj.get('refundBreakUp');
                                    for (Object refundBreakUp : refundBreakUpList) {
                                        Map<String, Object> refundBreakUpMap = (Map<String, Object>)refundBreakUp;
                                        if((string)refundBreakUpMap.get('displayName') =='Insurance'){
                                            Insurance_charge = string.valueof(refundBreakUpMap.get('refundAmount')); 
                                        }else{
                                            Insurance_charge ='0';
                                        }
                                        
                                    }
                                }     
                            }
                        }
                        
                        CP.Transaction_Name__c = orItemId;
                        CP.IsTicket_CancellableAPI_Request__c = true;
                        
                        string msg = IsCan.KeySet().contains('message')?'message':IsCan.KeySet().contains('Message')?'Message':'';
                        
                        if(String.IsNotBlank(msg))
                        {  
                            if(string.isNotBlank(string.valueof(IsCan.get(msg))) && (string.valueof(IsCan.get(msg))=='Cancellation_Failed' || string.valueof(IsCan.get(msg))=='Cancellation Failed'|| string.valueof(IsCan.get(msg))=='This ticket cannot be cancelled'))
                            {
                                Is_non_refundable =true;
                                CP.Message__c = string.valueof(IsCan.get(msg));
                                CP.Message_Valid__c = true;
                                if(!string.isBlank(string.valueof(IsCan.get('Code'))))
                                {
                                    CP.Code__c = string.valueof(IsCan.get('Code'));
                                }
                                if(!string.isBlank(string.valueof(IsCan.get('DetailedMessage'))))
                                {
                                    CP.Detailed_Message__c = string.valueof(IsCan.get('DetailedMessage'));
                                    detailed_msg=string.valueof(IsCan.get('DetailedMessage'));
                                    
                                }
                            }
                        }
                        
                        database.upsert(CP);
                    }
                    
                    
                }
                catch(exception e)
                {
                    cp.IsCacellable_API_Request_Response__c = string.valueof(e);    
                    database.upsert(CP);
                    dbLog.Exception_Description__c = String.valueOf(e);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'IsCancellable API request Failed'));
                } 
            }
            
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Transaction TIN number or Booking Email Id not available'));
            insert dbLog;
        }
    }
    //Till Here   
    public void IsTicketCancellable()
    {
        Is_non_refundable =false;
        showBreakUp=false;
        showPartialBreakup=false;
        hide1stButton = True;
        if(!string.isBlank(orItemId))
        {
            DBLog_Summary__c dbLog=new DBLog_Summary__c();
            //            if((string.isNotBlank(string.valueof(orIt.Order_Item_Reference_No__c))||'Coupon'.EqualsIgnoreCase(orIt.Item_Type__c)) && (string.isNotBlank(string.valueof(orIt.Email__c)) || string.isNotBlank(string.valueof(orIt.Email_Copy__c))))
            if((string.isNotBlank(string.valueof(orIt.Order_Item_Reference_No__c))||'Coupon'.EqualsIgnoreCase(orIt.Item_Type__c))&& (string.isNotBlank(string.valueof(orIt.Email__c)) || string.isNotBlank(string.valueof(orIt.Email_Copy__c)) || string.isNotBlank(string.valueof(orIt.Mobile__c)) ))
            {
                bodyValue = new map<string,string>();
                bodyValue.put('tin',orIt.Order_Item_Reference_No__c);
                if(string.isNotBlank(orIt.Email__c))
                    bodyValue.put('email',string.valueof(orIt.Email__c));
                
                else if(string.isNotBlank(orIt.Email_Copy__c))
                    bodyValue.put('email',string.valueof(orIt.Email_Copy__c));
                //no email flow - start
                else
                    bodyValue.put('email','');
                if(string.isNotBlank(orIt.Mobile__c))
                    bodyValue.put('mobileno',string.valueof(orIt.Mobile__c));
                else
                    bodyValue.put('mobileno','');
                //no email flow - end
                if('Coupon'.EqualsIgnoreCase(orIt.Item_Type__c))
                {
                    bodyValue.put('isAddonCancellation',string.valueof(true));
                    bodyValue.put('tin',orIt.Order_Id__c); 
                }
                dbLog.Type__c='redBusCancellation-IsTicketCancellable';
                dbLog.Payment_Transaction_Name__c =orIt.Id;
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req = HttpRequestUtil.populateCAPIHeaders(req);
                req.setHeader('Country_Name',country);
                req.setHeader('SelectedCurrency',selCurrency); 
                
                
                req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='IsTicketCancellableURLV2'].Endpoint__c);
                req.setMethod('POST');
                system.debug('-------------------BODY------------'+JSON.serialize(bodyValue));
                req.setBody(JSON.serialize(bodyValue));
                cp.IsCacellable_API_Request_Data__c = string.valueof(req)+'Body :'+JSON.serialize(bodyValue)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency:'+selCurrency;
                dbLog.Request_Data__c= string.valueof(req)+'Body :'+JSON.serialize(bodyValue)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency:'+selCurrency;
                dbLog.EndPoint__c = String.valueOf(req.getEndpoint());
                if(String.isNotBlank(wlOperName))
                {
                    req.setHeader('Operator',wlOperName);
                    cp.IsCacellable_API_Request_Data__c = cp.IsCacellable_API_Request_Data__c+',Operator:'+wlOperName;
                }
                try
                {
                    system.debug('<<<req'+req);
                    system.debug('body'+req.getBody());                    
                    res = http.send(req);                      
                    string responseValue = res.getBody();
                    system.debug('responseValue'+responseValue);
                    cp.IsCacellable_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;
                    dbLog.Response_Received__c=string.valueof(res)+' Body : '+responseValue;
                    dbLog.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                    dbLog.CallOut_Status__c = string.valueOf(res.getStatus());
                    if(string.isNotBlank(string.valueof(responseValue)))
                    {
                        map<string,object> IsCan = (map<string,object>)JSON.deserializeUntyped(responseValue);
                        system.debug('>>>IsCan Response>>>'+IsCan);
                        
                        if(IsCan.containsKey('partialCancellationBreakUp') && (Map<String, Object>) IsCan.get('partialCancellationBreakUp')!=null){
                            Map<String, Object> partialCancellationBr = (Map<String, Object>) IsCan.get('partialCancellationBreakUp');
                            partialCancelAllowedSeats=(list<object>)partialCancellationBr.get('fareWithSeat');
                            System.debug('partialCancelAllowedSeats-->'+partialCancelAllowedSeats);
                        }
                        
                        if ((List<object>)IsCan.get('addons') != NULL ){
                            addonCancelAllowed=(list<object>)IsCan.get('addons');                            
                        }
                        system.debug('addonCancelAllowed-->'+addonCancelAllowed);
                        if(IsCan.ContainsKey('fullCancellationBreakUp'))
                        {                      
                            showPartialBreakup=false;  
                            showRefundBreakup=true;    
                            system.debug('--showRefundBreakup--'+showRefundBreakup);        
                            map<string, object> fullCancellationBreakUp=(map<string,object>)IsCan.get('fullCancellationBreakUp');
                            
                            list<object> itemList= (list<object>)IsCan.get('items');
                            system.debug('>>>itemList>>'+itemList);
                            List<object> lstfareWithSeat= (List<Object>)fullCancellationBreakUp.get('fareWithSeat');
                            List<object> addonfare= (List<Object>)fullCancellationBreakUp.get('fareWithSeat');
                            // map<string, object> MapFarewithSeat;
                            map<string, object> MapFarewithSeat= (map<string,object>)lstfareWithSeat[0];
                            if(String.isNotBlank(orIt.Umbrella_TIN__c)){
                                string connectedItems = orIt.Connected_Items__c;
                                Map<String, Integer> dataMap = (Map<String, Integer>) JSON.deserialize(connectedItems, Map<String, Integer>.class);
                                System.debug('::: dataMap = '+dataMap);
                                Integer indexValueToFetch = dataMap.get(orIt.Guid__c)-1;
                            
                                System.debug('::: indexValueToFetch = '+indexValueToFetch);
                                MapFarewithSeat= (map<string,object>)lstfareWithSeat[indexValueToFetch];
                                Map<String,Object> mapFare= (map<string,object>)MapFarewithSeat.get('fareresponse');   
                                Decimal fareValueDecimal = Decimal.valueOf(String.valueOf(mapFare.get('fare')));
                                Decimal fareValue2Decimal = Decimal.valueOf(String.valueOf(orIt.Total_Fare_Value__c));
                                if(fareValueDecimal == fareValue2Decimal){
                                    MapFarewithSeat= (map<string,object>)lstfareWithSeat[indexValueToFetch];
                                }else{
                                    MapFarewithSeat= (map<string,object>)lstfareWithSeat[indexValueToFetch - 1];
                                }
                                System.debug('::: MapFarewithSeat = '+MapFarewithSeat);
                            }
                            // else{
                            //     MapFarewithSeat= (map<string,object>)lstfareWithSeat[0];
                            // }
                            
                            Map<String,Object> mapFare= (map<string,object>)MapFarewithSeat.get('fareresponse');                           
                            addonList=new list<addOnWrapper>();
                            ////Start - Null pointer exception - correction 
                            list<object> addonObjList = new list<object>();
                            //END - Null pointer exception - correction
                            if ((list<object>)IsCan.get('items') != NULL){
                                addonObjList=(list<object>)IsCan.get('items');
                            }
                            canRefundAmount=0;
                            //Start - Null pointer exception - correction
                            if(addonObjList.size() > 0)
                            {                
                                //END - Null pointer exception - correction
                                for(object o:addonObjList){
                                    system.debug('entered for loop');
                                    Map<string,object> inObj=(Map<string,object>)o; 
                                    if(string.valueOf(inObj.get('itemType')) !='Bus'){
                                        addOnWrapper aw=new addOnWrapper();
                                        System.debug('total fare-->'+string.valueOf(inObj.get('totalFare')));
                                        aw.totalFare=string.valueOf(inObj.get('totalFare'));
                                        System.debug('total fare-->'+aw.totalFare);
                                        aw.refundableAmount=string.valueOf(inObj.get('refundAmount'));
                                        aw.isAddOnCancellable=string.valueOf(inObj.get('isAddOnCancellable'));
                                        aw.itemUuid=string.valueOf(inObj.get('itemUuid'));
                                        aw.itemName=string.valueOf(inObj.get('itemType'));
                                        canRefundAmount=canRefundAmount+decimal.valueOf(aw.refundableAmount);
                                        // aw.cancellationCharge=decimal.valueOf(aw.totalFare)-decimal.valueOf(aw.refundableAmount);
                                        addonList.add(aw);  
                                    }
                                    
                                    Set<String> setDisplayNames = new Set<String>(System.label.IsCancellableRefundBrDispNames.split(','));
                                    
                                    /*  if(string.valueOf(inObj.get('itemType'))=='Bus'){
List<Object> refundBreakUpList = (List<Object>)inObj.get('refundBreakUp');
for (Object refundBreakUp : refundBreakUpList) {
addOnWrapper aw=new addOnWrapper();
Map<String, Object> refundBreakUpMap = (Map<String, Object>)refundBreakUp;
if(!setDisplayNames.contains((string)refundBreakUpMap.get('displayName'))){
aw.totalFare= string.valueOf(refundBreakUpMap.get('amount'));
aw.itemName=string.valueOf(refundBreakUpMap.get('displayName'));
aw.refundableAmount=string.valueOf(refundBreakUpMap.get('refundAmount'));
canRefundAmount=canRefundAmount+decimal.valueOf(aw.refundableAmount);
addonList.add(aw);  
}
}
}

if(string.valueOf(inObj.get('itemType')) =='Bus'){
List<Object> refundBreakUpList = (List<Object>)inObj.get('refundBreakUp');
for (Object refundBreakUp : refundBreakUpList) {
Map<String, Object> refundBreakUpMap = (Map<String, Object>)refundBreakUp;
if((string)refundBreakUpMap.get('displayName') =='Base Fare'){
Tot_amount_paid = string.valueOf(refundBreakUpMap.get('amount'));
Refund_amount =string.valueof(refundBreakUpMap.get('refundAmount')); 
CP.Max_Refundable_Amount__c = decimal.valueof(Refund_amount);
canRefundAmount=canRefundAmount+CP.Max_Refundable_Amount__c;
}

if(string.isBlank(Tot_amount_paid) && string.isBlank(Refund_amount)){
Tot_amount_paid = string.valueOf(inObj.get('totalPaid'));
Refund_amount =string.valueof(inObj.get('refundAmount')); 
CP.Max_Refundable_Amount__c = decimal.valueof(Refund_amount);
canRefundAmount=canRefundAmount+CP.Max_Refundable_Amount__c;
}
}
}  */
                                }
                                //Start - Null pointer exception - correction                                
                            }
                            //END - Null pointer exception - correction
                            
                            System.debug('add list-->'+addonList);
                            
                            
                            Tot_amount_paid =string.valueof(mapFare.get('fare'));
                            Insurance_charge =string.valueof(mapFare.get('insuranceCharges'));
                            Refund_amount =string.valueof(mapFare.get('refAmount')); 
                            CP.Max_Refundable_Amount__c = decimal.valueof(Refund_amount);
                            canRefundAmount=canRefundAmount+CP.Max_Refundable_Amount__c;
                            Cancellation_charge =string.valueof(mapFare.get('canCharge'));
                            Redbus_discount =string.valueof(mapFare.get('offerValue'));
                            Operator_discount =string.valueof(IsCan.get('operatorDiscount'));
                            
                        }
                        
                        //CP.Max_Refundable_Amount__c = (Decimal)IsCan.get('refundAmount');
                        //showRefundBreakup=true;
                        //showPartialBreakup=false;  
                        
                        
                        CP.Transaction_Name__c = orItemId;
                        CP.IsTicket_CancellableAPI_Request__c = true;
                        system.debug('---------response-------'+IsCan.KeySet().contains('message')); 
                        string msg = IsCan.KeySet().contains('message')?'message':IsCan.KeySet().contains('Message')?'Message':'';
                        String code = IsCan.KeySet().contains('Code')?string.valueof(IsCan.get('Code')):'';
                        CP.isPartialCancellation__c = IsCan.KeySet().contains('isPartialCancellation')?boolean.valueof(IsCan.get('isPartialCancellation')):false;
                        CP.isTicketCancellable__c = IsCan.KeySet().contains('isTicketCancellable')?boolean.valueof(IsCan.get('isTicketCancellable')):false;
                        String detMessage = IsCan.KeySet().contains('DetailedMessage')?string.valueof(IsCan.get('DetailedMessage')):''; 
                        
                        if(!String.IsBlank(msg))
                        {
                            dateTime dojDate;
                            dateTime curntTime =System.now();
                            if(orIt.Boarding_Time__c!=null){
                                dojDate =orIt.Corrected_Date_of_Journey__c;
                            }
                            
                            if(!'Coupon'.equalsIgnoreCase(orIt.Item_Type__c) && string.isNotBlank(string.valueof(IsCan.get(msg))) && (string.valueof(IsCan.get(msg))=='Cancellation_Failed' || string.valueof(IsCan.get(msg))=='Cancellation Failed' || string.valueof(IsCan.get(msg))=='This ticket cannot be cancelled') && (setCodes.contains(code) || curntTime > dojDate))
                            {
                                
                                CP.Message__c = string.valueof(IsCan.get(msg));
                                CP.Message_Valid__c = true;
                                cp.Detailed_Message__c = detMessage;
                                CP.Code__c = code;
                                
                                HttpResponse res1 = new HttpResponse();
                                Http http1 = new Http();
                                HttpRequest req1 = new HttpRequest();
                                
                                if('_IN'.EqualsIgnoreCase(orIt.Business_Unit__c.right(3)))
                                {    
                                    req1 = HttpRequestUtil.populateHeaders(req1);  
                                    cp.MAX_API_Request_Data__c = string.valueof(req1)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,SelectedCurrency:INR,Country_Name :IND';
                                }else if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
                                    if('INR'.equalsIgnoreCase(comCurrency)){
                                        req1 = HttpRequestUtil.populateHeaders(req1); 
                                        req1.setHeader('Country_Name', 'IND');
                                    }else{
                                        req1 = HttpRequestUtil.populateHeaders(req1); 
                                        req1.setHeader('Country_Name', 'INTL');
                                    }
                                    cp.MAX_API_Request_Data__c = string.valueof(req1)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,SelectedCurrency:USD,Country_Name :RDC';
                                }
                                else 
                                {    
                                    req1 = HttpRequestUtil.populateHeaders(req1);  
                                    req1.setHeader('Country_Name', 'INTL');
                                    cp.MAX_API_Request_Data__c = string.valueof(req1)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,SelectedCurrency:INR,Country_Name :INTL';
                                    
                                }
                                
                                req1.setMethod('GET');
                                req1.setTimeout(120000);
                                req1.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='MaxRefundableAPI'].Endpoint__c+orIt.OrderUuid__c+'&tin='+orIt.Order_Item_Reference_No__c);
                                try
                                {
                                    res1 = http1.send(req1);                                        
                                    string maxRefundResp = res1.getBody();
                                    system.debug('---------maxRefundResp-------'+maxRefundResp);
                                    cp.MAX_API_Request_Response__c = string.valueof(res1)+' Body : '+maxRefundResp;    
                                    if(res1.getStatusCode()==200)
                                    {
                                        if(string.IsNotBlank(maxRefundResp))
                                        {
                                            CP.Max_Refundable_API__c = true;
                                            CP.Max_Refundable_Amount__c = double.valueof(maxRefundResp);
                                            if(CP.Max_Refundable_Amount__c<=0)
                                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Refundable Amount is 0(Zero) or Negative Value'));
                                        }
                                    }
                                    else
                                    {
                                        database.upsert(CP);
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,maxRefundResp));
                                    }
                                }
                                catch(exception e)
                                {
                                    cp.MAX_API_Request_Response__c = string.valueof(e); 
                                    system.debug('1st response '+string.valueof(e));
                                    database.upsert(CP);   
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Max Refundable Amount API ping failed'));
                                    
                                }
                                
                                
                            }
                            
                            else if(!'Coupon'.equalsIgnoreCase(orIt.Item_Type__c) && res.getStatusCode()==200 && string.isBlank(string.valueof(IsCan.get('message'))) && !CP.isTicketCancellable__c)
                            {
                                HttpResponse res1 = new HttpResponse();
                                Http http1 = new Http();
                                HttpRequest req1 = new HttpRequest();
                                
                                if('_IN'.EqualsIgnoreCase(orIt.Business_Unit__c.right(3)))
                                {    
                                    req1 = HttpRequestUtil.populateHeaders(req1);  
                                    cp.MAX_API_Request_Data__c = string.valueof(req1)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,SelectedCurrency:INR,Country_Name :IND';
                                }else if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
                                    if('INR'.equalsIgnoreCase(comCurrency)){
                                        req1 = HttpRequestUtil.populateHeaders(req1); 
                                        req1.setHeader('Country_Name', 'IND');
                                    }else{
                                        req1 = HttpRequestUtil.populateHeaders(req1); 
                                        req1.setHeader('Country_Name', 'INTL');
                                    }
                                    cp.MAX_API_Request_Data__c = string.valueof(req1)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,SelectedCurrency:USD,Country_Name :RDC';
                                }
                                else 
                                {    
                                    req1 = HttpRequestUtil.populateHeaders(req1);  
                                    req1.setHeader('Country_Name', 'INTL');
                                    cp.MAX_API_Request_Data__c = string.valueof(req1)+': Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,SelectedCurrency:INR,Country_Name :INTL';
                                    
                                }
                                
                                req1.setMethod('GET');
                                req1.setTimeout(120000);
                                req1.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='MaxRefundableAPI'].Endpoint__c+orIt.OrderUuid__c+'&tin='+orIt.Order_Item_Reference_No__c);
                                
                                try
                                {
                                    res1 = http1.send(req1);                                        
                                    string maxRefundResp = res1.getBody();
                                    cp.MAX_API_Request_Response__c = string.valueof(res1)+' Body : '+maxRefundResp;    
                                    if(res1.getStatusCode()==200)
                                    {
                                        if(string.IsNotBlank(maxRefundResp))
                                        {
                                            CP.Max_Refundable_API__c = true;
                                            CP.Max_Refundable_Amount__c = double.valueof(maxRefundResp);
                                            if(CP.Max_Refundable_Amount__c<=0)
                                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Refundable Amount is 0(Zero) or Negative Value'));
                                            
                                        }
                                    }
                                    else
                                    {
                                        database.upsert(CP);
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,maxRefundResp));
                                    }
                                }
                                catch(exception e)
                                {
                                    cp.MAX_API_Request_Response__c = string.valueof(e); 
                                    system.debug('2nd Response'+string.valueof(e));
                                    database.upsert(CP);   
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Max Refundable Amount API ping failed'));
                                    
                                }
                                
                            }
                            
                            else if(string.isNotBlank(string.valueof(IsCan.get(msg))) && ('Coupon'.equalsIgnoreCase(orIt.Item_Type__c) || !setCodes.contains(code)))
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,detMessage));        
                        }
                        database.upsert(CP);
                    }
                }
                catch(exception e)
                {
                    cp.IsCacellable_API_Request_Response__c = string.valueof(e);    
                    database.upsert(CP);
                    dbLog.Exception_Description__c = String.valueOf(e);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'IsCancellable API request Failed'));
                } 
                system.debug('response Test'+cp.IsCacellable_API_Request_Response__c);
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Transaction TIN number AND Booking Email Id not available'));
            }
            insert dbLog;
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'OrderItem is Missing'));
        }
    }
    
    public void normalCancelAPI()
    {
        normalAPICalled = True;
        if(!string.isBlank(orItemId))
        {
            bodyValue = new map<string,string>();
            bodyValue.put('ticketNo',orIt.Order_Item_Reference_No__c);
            system.debug('--NormalTin--'+orIt.Order_Item_Reference_No__c);
            if(string.isNotBlank(orIt.Email__c))
            {
                bodyValue.put('emailId',string.valueof(orIt.Email__c));
            }
            else if(string.isNotBlank(orIt.Email_Copy__c))
            {
                bodyValue.put('emailId',string.valueof(orIt.Email_Copy__c));
            }
            // no email flow - start            
            else    
                bodyValue.put('emailId','');
            if(string.isNotBlank(orIt.Mobile__c))
            {
                bodyValue.put('mobileno',string.valueof(orIt.Mobile__c));
            }
            else
                bodyValue.put('mobileno','');
            // no email flow - end 
            if('Coupon'.EqualsIgnoreCase(orIt.Item_Type__c) && string.isBlank(orIt.Order_Item_Reference_No__c))
            {
                bodyValue.put('isAddonCancellation','true');
                bodyValue.put('ticketNo',orIt.Order_Id__c);  
            }
            
            bodyValue.put('selectedRefundType','BACK_TO_SOURCE');
            bodyValue.put('cseName',userName);
            bodyValue.put('cancellationReason','REQUESTED_BY_USER');
            bodyValue.put('orderItemUuid',orIt.Guid__c);
            System.debug('CP.Full_Cancellation_Type__c..'+CP.Full_Cancellation_Type__c);
            
            if(CP.Full_Cancellation_Type__c=='Full Cancelllation' || CP.Partial_Cancellation_Type__c=='Full Cancelllation')
            {
                bodyValue.put('cancellationType','1');    
            }
            
            list<string> seatNos = new list<string>();
            if(CP.Full_Cancellation_Type__c=='Partial Cancellation')
            {
                bodyValue.put('cancellationType','2');
                
                for(SectionSeatNo seList: SeatAvailable)
                {
                    if(seList.isSelected==true)
                    {
                        seatNos.add(seList.SeatNO);
                    }
                }
                CP.Selected_Seat_Nos__c = string.join(seatNos,',');
                system.debug('--------CP.Selected_Seat_Nos__c------------'+CP.Selected_Seat_Nos__c);
            }
            if(!seatNos.isEmpty())
            {
                bodyValue.put('selectedSeat',string.join(seatNos,','));
            }
            else
            {
                bodyValue.put('selectedSeat','');
            }
            
            bodyValue.put('isForceCancellation','false');
            bodyValue.put('isBusCancelled','false');
            
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req = HttpRequestUtil.populateCAPIHeaders(req);
            req.setHeader('Country_Name',country);
            req.setHeader('SelectedCurrency',selCurrency); 
            req.setTimeout(120000);              
            req.setMethod('POST');
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketCancellation'].Endpoint__c);              
            cp.NC_API_Request_Data__c = string.valueof(req)+'Body :'+JSON.serialize(bodyValue)+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency:'+selCurrency;
            if(String.isNotBlank(wlOperName))
            {
                cp.NC_API_Request_Data__c = cp.NC_API_Request_Data__c+',Operator:'+wlOperName;
                req.setHeader('Operator',wlOperName);
            }
            req.setBody(JSON.serialize(bodyValue));
            
            try
            {
                res = http.send(req);                    
                string responseValue = res.getBody();                     
                cp.NC_API_Request_Response__c = string.valueof(res)+' Body : '+responseValue;
                
                if(res.getStatusCode()==200 && !string.isBlank(responseValue))
                {
                    APIResponse resp = new APIResponse();
                    cp.NC_API_Ping__c = true;
                    resp = (APIResponse)JSON.deserialize(responseValue,APIResponse.class);
                    system.debug('respone for normal can'+resp);
                    cp.NC_IsSuccess__c = Boolean.valueOf(resp.Status);
                    cp.NC_Refund_Amount__c = resp.RefundAmount;
                    cp.NC_Cancellation_Charges__c = resp.CancellationCharges;
                    
                    if(!string.isBlank(resp.Message))
                    {
                        cp.NC_Response_Message__c = string.valueof(resp.Message);
                    }
                    
                    if(!string.isBlank(resp.NewTicket))
                    {
                        cp.NC_New_Tin__c = string.valueof(resp.NewTicket);
                    }
                }
                else
                {
                    database.upsert(cp);    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Ticket Normal Cancellation API request Failed'));
                }
            }
            catch(exception e)
            {
                System.debug('Error in Normal Cancellation flow'+e);
                cp.NC_API_Request_Response__c = string.valueof(e);    
                database.upsert(cp);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Ticket Normal Cancellation API request Failed'));
            }
            
            database.upsert(cp); 
        }
    }
    
    
    public void seatSelection()
    {
        SeatAvailable = new list<SectionSeatNo>();
        list<string> parSeats=new list<string>();
        Integer counter = 0;
        System.debug('partialCancelAllowedSeats seat-->'+partialCancelAllowedSeats);
        for(object po:partialCancelAllowedSeats){
            Map<string,object> msObj=(Map<string,object>)po; 
            string seatNo=string.valueof(msObj.get('seatName')); 
            //string.valueof(msObj.get('isPartiallyCancellable'))=='true'
            if(counter ==0){
                primarySeatMsg='Primarcy Seat is not allowed to cancel, seat no->'+seatNo;
            }else{
                parSeats.add(seatNo);
            }                        
            counter++;
        }
        System.debug('parSeats-->'+parSeats);
        for(String seatNum : orIt.Seat_No__c.split(','))
        {
            SectionSeatNo ss = new SectionSeatNo();
            ss.SeatNO = seatNum;
            if(parSeats.contains(seatNum)){
                SeatAvailable.add(ss);
            }
        }
    }
    public class SectionSeatNo
    {
        Public boolean isSelected{get;set;}
        public String SeatNO{get;set;}
        public SectionSeatNO()
        {
            isSelected = false;
        }
    }
    
    public void selectRefundreason()
    {
        system.debug('>>>>>>>>>..selrefundReason>>>>');
        if('ZQP Incorrect Booking'.equalsIgnoreCase(cp.Refund_Reason__c) || 'ZQP Incorrect source-destination'.equalsIgnoreCase(cp.Refund_Reason__c) || 'ZQP Incorrect gender-nameChange'.equalsIgnoreCase(cp.Refund_Reason__c)){
            isZQPrefundType=true;
        }else{
            isZQPrefundType=false;   
        }
    }
    
    public pagereference updateOperCancellationStatus()
    {
        if(String.isBlank(selStatus) || String.isBlank(refundDescription))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Select the Operator Status And Fill The Case Comments'));
            return null; 
        }
        
        if('OPERATOR_CANCELLATION_FAILED'.equalsIgnoreCase(selStatus) && String.isBlank(fcuDeniedReason))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Select Operator Denied Reason'));
            return null;
        }
        
        if('OPERATOR_CANCELLATION_SUCCESS'.equalsIgnoreCase(selStatus) && forceCancelRefundAmnt<0.0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Operator Cancellation Charges Should be 0(Zero) or Greater than 0(Zero)'));
            return null;
        }
        String denReson = (String.isBlank(fcuDeniedReason) || '--None--'.equalsIgnoreCase(fcuDeniedReason))?'':fcuDeniedReason;  
        String jsonBody = '{"operatorCancellationStatus":"'+selStatus+'","operatorCancellationCharge":{"amount":'+forceCancelRefundAmnt+',"currencyType":"'+orIt.Amount_Recieved_Currency__c+'"},"cancellationStatusUpdatedBy":"'+userName+'","cancellationUpdateChannel":"SFA","orderItemUuid":"'+orIt.Guid__c+'","operatorCancellationDeniedReason":"'+denReson+'"}';
        
        http ht = new http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req = HttpRequestUtil.populateHeaders(req);
        cpsLog = new Cancellation_Process_DB_Log__c();
        
        if(orIt.Business_Unit__c.endsWithIgnoreCase('_IN'))        {    
            
            cpsLog.FCU_API_Request_Data__c = string.valueof(req)+'Body :'+jsonBody+' Headers: Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,Country_Name :IND,SelectedCurrency :INR,Currency:INR';
        }
        else
        {    
            req.setHeader('Country_Name', 'INTL');
            cpsLog.FCU_API_Request_Data__c = string.valueof(req)+'Body :'+jsonBody+' Headers: Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,Country_Name :INTL,SelectedCurrency :INR,Currency:INR';
            
        }
        
        req.setMethod('POST');
        
        cpsLog.FCU_Operator_New_Status__c = selStatus.toUpperCase();    
        req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='ForceCancelAPI'].Endpoint__c);
        req.setBody(jsonBody);
        cpsLog.Transaction_Name__c = orIt.id;
        
        try
        {
            
            cpsLog.FCU_Cancellattion_Charges__c= forceCancelRefundAmnt;
            if('Try Later'.equalsIgnoreCase(selStatus))
            {
                Case frcCase = [Select id,Force_Cancellation_Status__c,Force_Cancellation_Charges__c,FC_Denied_Reason__c from Case Where Issue_Type__c='Force Cancellation' AND Status='Open' AND Cancellation_ID__c=:canOrdItem[0].Id];
                frcCase.Force_Cancellation_Status__c = selStatus;
                update frcCase;
                cpsLog.FCU_Is_Success__c = true;
                cpsLog.FCU_API_Ping__c = true;
                operCancellationStatus = selStatus;
                
                CaseComment csComm = new CaseComment();
                csComm.ParentId = frcCase.id;
                csComm.commentBody = refundDescription;
                insert csComm;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Record Has Been Updated Successfully'));
            }
            
            else
            {
                res = ht.send(req);
                cpsLog.FCU_API_Response_Data__c = res+' Body: '+res.getBody();
                
                if(res.getStatusCode()==200 && res.getStatus()=='OK' && res.getBody()!=null)
                {
                    cpsLog.FCU_API_Ping__c = true;              
                    ExceptionalCanResponse forceCanResp = new ExceptionalCanResponse();
                    forceCanResp = (ExceptionalCanResponse)JSON.deserialize(res.getBody(),ExceptionalCanResponse.class);
                    if('SUCCESS'.equalsIgnoreCase(forceCanResp.status))
                    {
                        canOrdItem[0].Operator_Cancellation_Status__c = String.valueOf(forceCanResp.data.get('newOperatorCancellationStatus')).toUpperCase();
                        operCancellationStatus = canOrdItem[0].Operator_Cancellation_Status__c;
                        update canOrdItem;                  
                        cpsLog.FCU_Operator_New_Status__c = canOrdItem[0].Operator_Cancellation_Status__c;
                        cpsLog.FCU_Operator_Old_Status__c = String.valueOf(forceCanResp.data.get('oldOperatorCancellationStatus')).toUpperCase();
                        cpsLog.OrderItemUuid__c = String.valueOf(forceCanResp.data.get('OrderItemUuid'));
                        cpsLog.FCU_Denied_Reason__c = denReson;
                        cpsLog.FCU_Is_Success__c = true;
                        
                        Case frcCase = [Select id,Force_Cancellation_Status__c,Force_Cancellation_Charges__c,FC_Denied_Reason__c from Case Where Issue_Type__c='Force Cancellation' AND Status='Open' AND Cancellation_ID__c=:canOrdItem[0].Id];
                        frcCase.Force_Cancellation_Status__c = 'OPERATOR_CANCELLATION_SUCCESS'.equalsIgnoreCase(selStatus)?'Operator Accepted':'OPERATOR_CANCELLATION_FAILED'.equalsIgnoreCase(selStatus)?'Operator Denied':'';
                        frcCase.Force_Cancellation_Charges__c = forceCancelRefundAmnt;
                        frcCase.FC_Denied_Reason__c =denReson;
                        update frcCase;
                        
                        CaseComment csComm = new CaseComment();
                        csComm.ParentId = frcCase.id;
                        csComm.commentBody = refundDescription;
                        insert csComm;
                        
                    }
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Record Has Been Updated Successfully'));
                    
                }
                else
                {
                    System.debug('API request failed ...'+res+'..Body..'+res.getBody());
                    cpsLog.FCU_API_Ping__c = false;
                    cpsLog.FCU_Is_Success__c = false;
                    insert cpsLog;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Unbale Process the request at this moment.Please try later'));
                    return null;
                }
                
            }
        }
        Catch(Exception e)
        {
            System.debug('Exception in Force Cancellation update..'+e);
            cpsLog.Detailed_Message__c = String.valueOf(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error While Processing.Please retry...'+e));
            insert cpsLog;
            return null;
        }
        
        insert cpsLog;
        return null;
        
    }
    
    public pagereference submitForApproval()
    {
        System.debug(cp.FC_Refund_Amount__c+'..'+(cp.FC_Refund_Amount__c>cp.Max_Refundable_Amount__c)+'..'+cp.Max_Refundable_Amount__c);
        
        List<user> userInfo=[select id,Team__c from user where id=:userinfo.getuserid()];
        if(string.isBlank(userInfo[0].Team__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Team name is not configured at user level'));
            return null;
        }
        
        if(cp.FC_Refund_Amount__c<=0 || (cp.FC_Refund_Amount__c>cp.Max_Refundable_Amount__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Refund Amount should Greater than 0 and less than or equal to Max Refundable Amount..!!'));
            return null;
        }
        
        if(String.isBlank(refundDescription) || String.isBlank(parentCase))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please provide the Refund Description And Parent Case Number'));
            return null;
        }
        
        
        if(('ZQP Incorrect Booking'.equalsIgnoreCase(cp.Refund_Reason__c) || 'ZQP Incorrect source-destination'.equalsIgnoreCase(cp.Refund_Reason__c) || 'ZQP Incorrect gender-nameChange'.equalsIgnoreCase(cp.Refund_Reason__c))&& String.isBlank(ZQPtin))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please provide the Tin Number for ZQP Booking'));
            return null;
        }
        
        List<Case> listCases = new List<Case>();
        listCases =[Select id,Transaction_ID__c,Trip_Id_ct__c,is_ZQP__c,Refund_Type__c,Refund_Amount__c from Case where caseNumber=:parentCase];
        if(listCases.isEmpty() || (String.isNotBlank(listCases[0].Transaction_ID__c) && listCases[0].Transaction_ID__c!=orIt.id) || (String.isNotBlank(listCases[0].Trip_Id_ct__c) && listCases[0].Trip_Id_ct__c!=orIt.Order_Id__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please provide the valid Case Number'));
            return null;
        }  
        
        if(!listCases.isEmpty() && !listCases[0].is_ZQP__c && ('ZQP Incorrect Booking'.equalsIgnoreCase(cp.Refund_Reason__c) || 'ZQP Incorrect source-destination'.equalsIgnoreCase(cp.Refund_Reason__c) || 'ZQP Incorrect gender-nameChange'.equalsIgnoreCase(cp.Refund_Reason__c))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Customer is not eligible for ZQP refund as the transaction time is exceeded greater than 30mins'));
            return null;
        }
        
        list <case> listExpRefndCase = [Select id, status, createddate,Refund_status__c, Exceptional_Refund_Count__c, Transaction_ID__c, Trip_Id_ct__c from Case where Issue_Type__c = 'Exceptional Refund' AND Refund_status__c='Exceptional Refund Approved' and TIN_No__c=:tinNumber ORDER BY createddate DESC];
        
        Case cs = new Case();
        cs.Issue_Type__c = 'Exceptional Refund';        
        
        if (listExpRefndCase.size()==0) {
            cs.Exceptional_Refund_Count__c =1;
        } else if(!listExpRefndCase.isEmpty() && listExpRefndCase.size()==1 && listExpRefndCase[0].Exceptional_Refund_Count__c==null){
            cs.Exceptional_Refund_Count__c =2;
        }else if(!listExpRefndCase.isEmpty() && listExpRefndCase[0].Exceptional_Refund_Count__c!=null) {
            cs.Exceptional_Refund_Count__c =listExpRefndCase[0].Exceptional_Refund_Count__c + 1;
        }
        
        cs.Issue_Sub_Category__c = cp.Refund_Reason__c;
        cs.Trip_Id_ct__c = orIt.Order_Id__c;
        cs.TIN_No__c = orIt.Order_Item_Reference_No__c;
        cs.Refund_Amount__c = cp.FC_Refund_Amount__c;
        listCases[0].Refund_Amount__c = cp.FC_Refund_Amount__c;
        cs.Description =refundDescription;
        cs.Transaction_ID__c = orIt.id;
        cs.status= 'Open';
        cs.Booking_Email_ID__c = orIt.Email__c;
        cs.OwnerId = System.Label.ExceptionalRefundQueueId;
        cs.Origin='InBound Call';
        cs.Subject = 'Exceptional Refund- '+cp.Refund_Reason__c;
        cs.New_Tin__c=ZQPtin;
        cs.ParentId = listCases[0].id;
        cs.Business_Unit_ct__c = orIt.Business_Unit__c;
        cs.User_Level_Team__c = userInfo[0].Team__c;
        if(cs.Issue_Sub_Category__c=='Instant refund - Collectible from BO' && instantRefundBoIds.contains(orIt.Service_Provider_Id__c)){
            cs.Refund_Type__c='Instant resolution with refund';
            listCases[0].Refund_Type__c='Instant resolution with refund';
        }else if(instantRefundBoIds.contains(orIt.Service_Provider_Id__c) && cs.Issue_Sub_Category__c=='Instant refund - customer delight'){
            cs.Refund_Type__c='Instant resolution - redBus Delight';
            listCases[0].Refund_Type__c='Instant resolution - redBus Delight';
        }
        if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
            cs.country__c=OrderItemTransactionResource__c.getValues(orIt.Business_Unit__c).Case_Country__c;
            cs.Business_Type__c=OrderItemTransactionResource__c.getValues(orIt.Business_Unit__c).Case_Business_Type__c;
            cs.Price_Paid_Currency_ctp__c = orIt.Total_Fare_Currency__c;
        }else{
            String conBusUnit = 'REDBUS_'+orIt.Business_Unit__c.split('_')[1];
            cs.Business_Type__c=OrderItemTransactionResource__c.getValues(conBusUnit).Case_Business_Type__c;
            cs.country__c=OrderItemTransactionResource__c.getValues(conBusUnit).Case_Country__c;
            cs.Price_Paid_Currency_ctp__c = orIt.Total_Fare_Currency__c;
        }
        try
        {             
            insert cs;            
            update listCases[0];
            
            if(instantRefundBoIds.contains(orIt.Service_Provider_Id__c) && cs.Refund_Amount__c<= suggestedAmount){
                // ApproveExceptionalRefund aer=new ApproveExceptionalRefund();
                set<id> csIds=new set<id>();
                csIds.add(cs.id);
                ApproveExceptionalRefund.InitiateRefund(csIds);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request Has Submitted Succcessfully & Approved'));
                return null;
            }
            
            if(String.isNotBlank(Refund_amount) && (CP.Max_Refundable_Amount__c == decimal.valueof(Refund_amount)))
            {
                normalAPICalled = true;
            }
            else
                forceAPICalled =true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Request Has Submitted Succcessfully for Approval.Post Approval Refund Will Be Processed'));
            return null;
        }
        Catch(DMLException de)
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, de.getdmlMessage(0) );
            ApexPages.addMessage(msg);
            return null;
        }
        
        Catch(Exception e)
        {
            System.debug('Exception in case creation..'+e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed To Submit The Request.Please Re-try!!'));
            return null;          
        }
        
    }
    
    public void getSuggestedRefundAmount(){
        double maxRefAmount=cp.Max_Refundable_Amount__c;
        
        list<case> csParList=new list<case>();
        csParList=[select id,Issue_Type__c,Issue_Sub_Category__c from case where casenumber=:parentCase];
        System.debug('csParList--->'+csParList);
        suggestedAmount=0;
        if(!csParList.isEmpty()){
            List<Issue_Based_TAT__mdt> im=new List<Issue_Based_TAT__mdt>();
            im=[select id,Exceptional_Refund_Suggested_Amount_Per__c from Issue_Based_TAT__mdt where Issue_Type__c=:csParList[0].Issue_Type__c and Issue_Sub_Category__c=:csParList[0].Issue_Sub_Category__c and Version__c='V2' ];
            System.debug('im-->'+im);
            if(!im.isEmpty() && im[0].Exceptional_Refund_Suggested_Amount_Per__c!=null)
                suggestedAmount=(orIt.Total_Fare_Value__c/im[0].Exceptional_Refund_Suggested_Amount_Per__c);
            if(suggestedAmount>maxRefAmount){
                suggestedAmount=maxRefAmount;
            }else{
                suggestedAmount=suggestedAmount;
            }
            
        }   
        System.debug('suggestedAmount-->'+suggestedAmount);
    }
    
    public pagereference updateOpertPhysCancellationStatus()
    {
        system.debug('---vv--'+selOptrStatus);
        if(!'OPERATOR_CANCELLATION_FAILED'.equalsIgnoreCase(selOptrStatus) && !'OPERATOR_CANCELLATION_SUCCESS'.equalsIgnoreCase(selOptrStatus))
        {
            selOptrStatus=selOptrStatus;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Select the Operator Status'));
            return null; 
        }
        
        if('OPERATOR_CANCELLATION_FAILED'.equalsIgnoreCase(selOptrStatus) && String.isBlank(physCanclDeniedReason))
        {
            selOptrStatus=selOptrStatus;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Select Operator and Denied Reason'));
            return null;
        }
        
        if('OPERATOR_CANCELLATION_SUCCESS'.equalsIgnoreCase(selOptrStatus) && String.isBlank(cnrVale))
        {
            selOptrStatus=selOptrStatus;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please Select the Operator Status And Fill The CNR Value'));
            return null;
        }
        
        
        string busUnit;
        system.debug('<<<orIt.Business_Unit__c'+orIt.Business_Unit__c);
        if('REDBUS_COM'.equalsIgnoreCase(orIt.Business_Unit__c)){
            busUnit=orIt.Business_Unit__c;
        }else{
            busUnit = 'REDBUS_'+orIt.Business_Unit__c.split('_')[1];
        }
        string itemUuid=orIt.Guid__c;
        HttpResponse res = new HttpResponse();
        physCanclRequest  phReq = new physCanclRequest();
        phReq.orderItemReferenceNo = orIt.Order_Item_Reference_No__c;
        phReq.emailId=String.isNotBlank(orIt.Email__c)?orIt.Email__c:orIt.Email_Copy__c;
        if('OPERATOR_CANCELLATION_SUCCESS'.equalsIgnoreCase(selOptrStatus)){
            phReq.operatorCancellationStatus='OPERATOR_CANCELLATION_SUCCESS';
            phReq.status='SUCCESS';
            phReq.cancellationReason='Cancellation';
            phReq.cnr=cnrVale;
        }else{
            phReq.operatorCancellationStatus='OPERATOR_CANCELLATION_FAILED';
            phReq.cancellationReason=physCanclDeniedReason;
            phReq.status='FAILURE';
        }
        phReq.businessUnit=busUnit;
        phReq.channel='CRM';
        phReq.backToSource=true;
        phReq.pnr=orIt.Service_Provider_Reference_No__c;
        
        Map<String, String> phsCnclHeaders= new Map<String, String>();
        phsCnclHeaders.put('Content-Type','application/json');
        try{
            res=HTTPUtil.sendGenericHTTPRequest([SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PhysicalCancellation'].Endpoint__c+itemUuid,'PUT',json.serialize(json.serialize(phReq)),phsCnclHeaders,120000,'Physical Cancellation');
            system.debug('<<<endpoint'+[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PhysicalCancellation'].Endpoint__c);   
        } 
        Catch(Exception e)
        {
            system.debug('Error:'+e);
        }
        //string res='{"status":"SUCCESS","errors":[],"data":{"zeroCancApplied":false,"status":"CANCELLATION_COMPLETED","serviceProviderId":"123456","refundAmount":{"currencyType":"PEN","amount":1100.0},"pnr":"TestPNR123","orderItemRefNumber":"PEP9J82414444","orderItemId":12783279536210433,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","cnr":"test12345678","clientIp":"","cancellationCharges":{"currencyType":"PEN","amount":0.0},"backToSource":true}}';
        //string res ='{"status":"SUCCESS","errors":[],"data":{"status":"CANCELLATION_FAILURE","orderItemReferenceNo":"PEPA613619268"}}';
        string finalStatus;
        cpsLog = new Cancellation_Process_DB_Log__c();
        try
        {
            system.debug('<<<1'+res.getBody()+'<<<2'+res.getStatusCode()+'<<<3'+String.isNotBlank(res.getBody()));
            if(res.getBody()!='null' && res.getStatusCode()==200 && String.isNotBlank(res.getBody()))
            {
                system.debug('---resp--'+res+'---res body--'+res.getBody());
                map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                system.debug('<<resMap'+resMap);
                if(resMap.containsKey('status') && resMap.get('status')!=null && resMap.get('status')=='SUCCESS')
                {
                    cpsLog.FCU_Is_Success__c = true;
                    system.debug('---status resp--'+resMap.get('status'));
                    system.debug('----<<'+resMap.get('data'));  
                    map<String,Object> statusMap= (map<string,object>)resMap.get('data');
                    system.debug('---statusMap--'+statusMap);
                    finalStatus=string.valueof(statusMap.get('status'));
                    system.debug('---finalStatus--'+finalStatus);
                    string resPTin='';
                    resPTin=string.valueof(statusMap.get('orderItemRefNumber'));
                    if(string.isBlank(resPTin)){
                        resPTin=string.valueof(statusMap.get('orderItemReferenceNo'));
                    }
                    system.debug('---resPTin--'+resPTin);
                    list<Case> phyCase = [Select id,Issue_Type__c,status from Case Where Issue_Type__c='Physical Cancellation' and TIN_No__c=:resPTin];
                    case cs = new case();
                    CaseComment csComm = new CaseComment();
                    if('CANCELLATION_COMPLETED'.equalsIgnoreCase(finalStatus))
                    {
                        if(!phyCase.isEmpty()){
                            csComm.ParentId = phyCase[0].id;
                            csComm.commentBody = finalStatus+'-->BO Accepted Cancellation';
                            insert csComm;
                            cs.status='Closed';
                            cs.Description=finalStatus;
                            cs.Closed_By__c = 'SalesForce System';
                            cs.Closed_By_Agent__c =UserInfo.getUsername();
                            cs.id= phyCase[0].id;
                            update cs;
                        }else{
                            case css =new case();
                            Id queueId=[Select Id from Group where type='Queue' AND developername='Physical_Cancellation_Latam_Queue'].Id;
                            css.country__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Country__c;
                            css.Business_Type__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Business_Type__c;
                            css.Issue_Type__c='Physical Cancellation';
                            css.Issue_Sub_Category__c='Initiate Physical Cancellation';
                            css.origin = 'Salesforce System';
                            css.tin_no__c = orIt.Order_Item_Reference_No__c;
                            css.Transaction_ID__c =orIt.id;
                            css.Trip_Id_ct__c = orIt.Order_Id__c;
                            css.SS_Route_Id__c = orIt.Route_Id__c;
                            css.SourceT__c = orIt.Source__c;
                            css.DestinationT__c = orIt.Destination__c;
                            css.Customer_Email_ID__c = orIt.Email_Copy__c;
                            css.Customer_Phone_Number__c = orIt.Mobile__c;
                            css.Email_Id_ct__c = orIt.Email_Copy__c;
                            css.Phone_No_ct__c =orIt.Mobile__c;
                            css.ownerid=queueId;
                            insert css;
                            Case phCase = [Select id,Issue_Type__c,status from Case Where id=:css.id];
                            csComm.ParentId = phCase.id;
                            csComm.commentBody = finalStatus+'-->BO Accepted Cancellation';
                            insert csComm;
                            cs.status='Closed';
                            cs.Description=finalStatus;
                            cs.Closed_By__c = 'SalesForce System';
                            cs.Closed_By_Agent__c =UserInfo.getUsername();
                            cs.id=  phCase.id;
                            update cs;
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Ticket has been Cancelled Successfully'));
                        isPhysCanclErrorMsg = True;
                        
                        return null;
                    }else{
                        if(!phyCase.isEmpty() && 'Physical Cancellation'.equalsIgnoreCase(phyCase[0].Issue_Type__c)){
                            csComm.ParentId =  phyCase[0].id;
                            csComm.commentBody = finalStatus;
                            insert csComm;
                            cs.status='Closed';
                            cs.Description=finalStatus+'-->BO Rejected ticket cancellation';
                            cs.id=  phyCase[0].id;
                            update cs;
                            
                        }else{
                            case css =new case();
                            Id queueId=[Select Id from Group where type='Queue' AND developername='Physical_Cancellation_Latam_Queue'].Id;
                            css.country__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Country__c;
                            css.Business_Type__c=OrderItemTransactionResource__c.getValues(busUnit).Case_Business_Type__c;
                            css.Issue_Type__c='Physical Cancellation';
                            css.Issue_Sub_Category__c='Initiate Physical Cancellation';
                            css.origin = 'Salesforce System';
                            css.tin_no__c = orIt.Order_Item_Reference_No__c;
                            css.Transaction_ID__c =orIt.id;
                            css.Trip_Id_ct__c = orIt.Order_Id__c;
                            css.SS_Route_Id__c = orIt.Route_Id__c;
                            css.SourceT__c = orIt.Source__c;
                            css.DestinationT__c = orIt.Destination__c;
                            css.Customer_Email_ID__c = orIt.Email_Copy__c;
                            css.Customer_Phone_Number__c = orIt.Mobile__c;
                            css.Email_Id_ct__c = orIt.Email_Copy__c;
                            css.Phone_No_ct__c =orIt.Mobile__c;
                            css.ownerid=queueId;
                            insert css;
                            Case phCase = [Select id,Issue_Type__c,status from Case Where id=:css.id];
                            csComm.ParentId = phCase.id;
                            csComm.commentBody = finalStatus;
                            insert csComm;
                            cs.status='Closed';
                            cs.Description=finalStatus+'-->BO Rejected ticket cancellation';
                            cs.Closed_By__c = 'SalesForce System';
                            cs.Closed_By_Agent__c =UserInfo.getUsername();
                            cs.id=  phCase.id;
                            update css;
                            
                        }
                    }
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Operater has been deined Successfully'));
                    isPhysCanclErrorMsg =true;
                }else if (resMap.get('status')!=null && resMap.get('status')=='ERROR'){
                    isPhysCanclErrorMsg = True;
                    physCanclErrorMsg= string.Valueof(resMap.get('error_message'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Api Response Message :- '+physCanclErrorMsg));
                    
                }
                
            }else{
                cpsLog.FCU_Is_Success__c = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Unbale Process the request at this moment.Please try later'));
                isPhysCanclErrorMsg = True;
                isPhysCanclErrorMsg = True;
                insert cpsLog;
            }
        }
        Catch(Exception e)
        {
            System.debug('Exception in physical Cancellation update..'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error While Processing.Please retry...'+e));
            insert cpsLog;
            return null;
        }
        return null;
        
    }
    
    
    public class APIResponse
    {
        public string IsSuccess;
        public string ResponseMessage;     
        public string NewTin;        
        public string NewTicket;
        public string Message;
        public boolean Status; 
        public double RefundAmount;
        public double CancellationCharges;
        public boolean IsRefundSuccess;
        public boolean NeftRefundSupported;
        public string OrderId;
        public string SalesChannel; 
        public string BusinessUnit;
        public string Country;
        public string SelectedLanguage;
        
        public APIResponse()
        {
            
        }
    }
    
    
    Public class ExceptionalCanResponse
    {
        public String status{get;set;}
        public Map<String,String> data{get;set;}
        public Cls_errors[] errors;
    }
    
    public class Cls_errors
    {
        
    }
    
    public class addOnWrapper{
        public string totalFare{get;set;}
        public string refundableAmount{get;set;}
        public string isAddOnCancellable{get;set;}
        public string itemName{get;set;}
        public string itemUuid{get;set;}
        public decimal cancellationCharge{get;set;}
    }
    public class physCanclRequest    {
        public string orderItemReferenceNo { get; set; } 
        public string emailId { get; set; } 
        public string operatorCancellationStatus { get; set; } 
        public string status { get; set; } 
        public string cancellationReason { get; set; } 
        public string businessUnit { get; set; } 
        public string channel { get; set; } 
        public boolean backToSource { get; set; } 
        public string pnr { get; set; } 
        public string cnr { get; set; }
    }  
}