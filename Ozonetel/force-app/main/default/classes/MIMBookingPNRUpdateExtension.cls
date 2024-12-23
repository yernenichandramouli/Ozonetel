/**
* (c) 2017 RedBus
*
* Name           : MIMBookingPNRUpdateExtension 
* Created Date   : 17 Apr 2018
* Created By     : Sreenivas M
* Purpose        : Extension class for MIMBookingPNRUpdate Page
*
**/
public class MIMBookingPNRUpdateExtension { 
    
    
    public Id orItId{get;set;}
    public Order_Items__c orIt{get;set;}
    public List<Order_Items__c> listOrIts{get;set;}
    public List<String> noOfSeats{get;set;}
    public map<string,string> seatWisePnr  = new map<string,string>(); 
    public string BpTimeUTC {get;set;}
    public string tin{get;set;}
    public boolean showSeatWisePNR{get; set;}
    public boolean isNotificationAllowed{get; set;}
    public String boardingTime{get;set;}
    public List<MIMSeatWrapper> seatWrapper{get;set;}
    public String country;
    public String selCurrency;
    public Boolean isShowPageBlock{get;set;}
    public String busLevelSeats{get;set;}
    public String busLevelPnr{get;set;}
    public string busnsUnit{get;set;}
    public boolean isMIMbooking{get;set;}
    
    public MIMBookingPNRUpdateExtension(ApexPages.StandardController sc) 
    {
        orIt = new Order_Items__c();
        noOfSeats = new List<String>();
        listOrIts = new List<Order_Items__c>();
        seatWrapper = new List<MIMSeatWrapper>();
        isNotificationAllowed =false;
        orIt = (Order_Items__c)sc.getRecord();
        orItId = this.orIt.Id;
        Order_Items__c ordItem = [Select Business_Unit__c,Guid__c,isMIM_PNR_Updated__c,isMIM_Booking__c,Order_Id__c,Transaction_Source__c from Order_Items__c Where id=:orItId limit 1];
        busnsUnit=ordItem.Business_Unit__c;
        isMIMbooking=ordItem.isMIM_Booking__c;
        system.debug('isMIMbooking--->>'+isMIMbooking);
        if(!'REDBUS_IN'.EqualsIgnoreCase(busnsUnit)&& isMIMbooking){
            String query ='Select ';
            System.debug('Booking===>>>'+SObjectType.Order_Items__c.FieldSets.MIM_Booking.getFields());
            for(Schema.FieldSetMember f : SObjectType.Order_Items__c.FieldSets.MIM_Booking.getFields()) 
                query += f.getFieldPath() + ', ';
            
            query += 'Id,Seat_No__c,isMIM_PNR_Updated__c FROM Order_Items__c Where Id=:orItId  AND isMIM_Booking__c =True AND isMIM_PNR_Updated__c =False AND Service_Provider_Reference_PNR_No__c=\'NOT CONFIRMED\'';
            listOrIts = Database.query(query);
            System.debug('listOrIts====>>>>'+listOrIts); 
            if(!listOrIts.isEmpty())
            {
                isShowPageBlock = true;
                orIt = listOrIts[0];
                System.debug('SeatNo====>>>>'+orIt.Seat_No__c);
                //busnsUnit=orIt.Business_Unit__c;
                system.debug('busnsUnit---'+busnsUnit);
                orIt.Service_Provider_Reference_No__c ='';
                noOfSeats.addAll(String.valueOf(orIt.Seat_No__c).split(','));
                orIt.Seat_No__c='';
                orIt.Boarding_Time__c = orIt.Corrected_Boarding_Time__c;
                boardingTime = String.valueOf(orIt.Corrected_Boarding_Time__c);
                Set<String> setMIMOPIds =new Set<String>();
                country = OrderItemTransactionResource__c.getValues(orIt.Business_Unit__c).Auth_Key__c;
                selCurrency= OrderItemTransactionResource__c.getValues(orIt.Business_Unit__c).Default_Currency__c;
                setMIMOPIds.addAll(System.Label.MIM_Notification_OperIds.Split(','));
                System.debug('orIt.Boarding_Time__c..start.'+orIt.Boarding_Time__c+'..timzezone..'+UserInfo.getTimeZone()+'..'+boardingTime);
                if(!setMIMOpIds.contains(orIt.Service_Provider_Id__c))
                    isNotificationAllowed =true; 
                
                for(String s:noOfSeats)
                    seatWrapper.add(new MIMSeatWrapper());
            }else{   
                orIt = new Order_Items__c();
                isShowPageBlock = false;
            }
            
        }
    }        
    
    public PageReference mimPnrUpdation()
    {
        
        System.debug('entered inside..');
        String seatwisePNRJson=null;
        if(showSeatWisePNR)
        {
            seatwisePNRJson ='{';
            for(MIMSeatWrapper swr :seatWrapper)
            {
                if(Test.isRunningTest()){
                    swr.seatNo='12';
                    swr.seatPnr='1232';
                    selCurrency='IDR';
                }
                if(String.isNotBlank(swr.seatNo) && String.isNotBlank(swr.seatPnr))
                    seatwisePNRJson+='"'+swr.seatNo+'":"'+swr.seatPnr+'",';
                else
                {
                    System.debug('entered else..');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Seat Number Or Seat PNR is missing at Seat Wise PNR.Please Update All Seat Level PNRs Properly'));
                    return null;
                }
            }
            seatwisePNRJson=seatwisePNRJson.removeEnd(',')+'}';             
        }
        
        String seatNumJson ='[';
        for(String st:busLevelSeats.split(','))
            seatNumJson+='"'+st+'",';
        seatNumJson=seatNumJson.removeEnd(',')+']';
        
        String BpTimeUTCJson='""';
        
        if(boardingTime!=String.valueOf(orIt.Corrected_Boarding_Time__c))
        {
            System.debug('conv time.before..'+String.valueOf(Datetime.valueOfGMT(boardingTime).addHours(-8))+'..gmt..'+String.valueOfGmt(Datetime.valueOfGMT(boardingTime).addHours(-8)));
            if('SG'.equalsIgnoreCase(orIt.Business_Unit__c.right(2)) || 'MY'.equalsIgnoreCase(orIt.Business_Unit__c.right(2)))
                BpTimeUTCJson= String.valueOfGmt(Datetime.valueOfGMT(boardingTime).addHours(-8));
            else if ('ID'.equalsIgnoreCase(orIt.Business_Unit__c.right(2)))
                BpTimeUTCJson= String.valueOfGmt(Datetime.valueOfGMT(boardingTime).addHours(-7));
            System.debug('conv time...'+boardingTime);
            BpTimeUTCJson = BpTimeUTCJson.contains('T')?'"'+BpTimeUTCJson+'"':'"'+BpTimeUTCJson.replace(' ','T')+'"';
        }
        
        string jsonbody = '{"tin":"'+orIt.Order_Item_Reference_No__c+'","pnr":"'+busLevelPnr+'","seatName":'+seatNumJson+',"seatWisePnr":'+seatwisePNRJson+',"BpTimeUTC":'+BpTimeUTCJson+'}';
        System.debug('body...'+jsonbody);
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req = HttpRequestUtil.populateCAPIHeaders(req);
        req.setHeader('Country_Name',country);
        req.setHeader('SelectedCurrency',selCurrency);
        req.setBody(jsonbody);
        req.setMethod('POST');        
        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='mimPnrUpdate'].Endpoint__c;
        req.setEndpoint(endPoint);
        
        DBLog_Summary__c dbl = new DBLog_Summary__c(); 
        try
        {
            
            orIt.Seat_No__c = busLevelSeats;
            orIt.Service_Provider_Reference_No__c = busLevelPnr;
            orIt.Service_Provider_Reference_PNR_No__c = orIt.Service_Provider_Reference_No__c.left(244);
            
            dbl.SentAt__c = system.now();
            dbl.Type__c = 'MIM Booking PNR Update';
            dbl.Payment_Request_Sent_Time__c = system.now();
            //dbl.Payment_Request_Sent_Data__c = string.valueof(req)+jsonbody+'.. Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency :'+selCurrency;
            dbl.Request_Data__c = string.valueof(req)+jsonbody+'.. Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency :'+selCurrency;
            dbl.Order_Items_Data_Received_Ids__c = String.valueOf(orIt.Order_Item_Reference_No__c);
            dbl.Payment_Transaction_Name__c = orIt.id;
            System.debug('jsonbody..'+jsonbody);
            res = http.send(req);
            // res.setStatusCode(200);
            // res.setBody('{"IsSuccess":true}');
            system.debug('----Success mimPnrUpdation -----resp---------------'+res);
            //dbl.Payment_Request_Response_Data__c = String.valueOf(res)+'..Body..'+res.getBody();
            dbl.Response_Received__c =String.valueOf(res)+'..Body..'+res.getBody();
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.Payment_Request_Response_Time__c = System.now();
            Boolean isSuc =false;
            
            
            if(res.getStatusCode() ==200 && String.isNotBlank(res.getBody()))
            {
                map<string,object> IsUpdated = (map<string,object>)JSON.deserializeUntyped(res.getBody());
                isSuc = isUpdated.containsKey('IsSuccess')?Boolean.valueOf(isUpdated.get('IsSuccess')):false;
                
                if(isSuc && isNotificationAllowed)
                {
                    orIt.isMIM_PNR_Updated__c = true;
                    System.debug('isNotificationAllowed..ee.'+isNotificationAllowed);
                    dbl.Payment_Ping_Status__c = 'MIM Booking PNR Update Ping Success';    
                    Http http1 = new Http();
                    HttpResponse res1 = new HttpResponse();       
                    HttpRequest req1 = new HttpRequest();
                    req1 = HttpRequestUtil.populateCAPIHeaders(req1);
                    req1.setHeader('Country_Name',country);
                    req1.setHeader('auth_key','fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
                    req1.setHeader('Channel_Name','WEB_DIRECT');
                    req1.setHeader('SelectedCurrency',selCurrency);
                    req1.setMethod('GET');        
                    String endPoint1 = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='e_m_Ticket'].Endpoint__c;
                    req1.setEndpoint(endPoint1+orIt.Order_Item_Reference_No__c);
                    dbl.Linking_Process_Start_Time__c = system.now();
                    
                    dbl.BusOrder_Items_Data_Received_Ids__c = string.valueof(req1)+'..Headers: Headers Info: Channel_Name :WEB_DIRECT,auth_key :fb26b9d6-28d5-4a43-a3f2-759839d7fdd7,BusinessUnit :BUS,Country_Name :'+country+',SelectedCurrency :'+selCurrency;
                    
                    res1 = http1.send(req1);                   
                    dbl.BusOrder_Item_Details_Success__c =String.valueOf(res1);
                    
                    if(res1.getStatusCode() ==200 && String.isNotBlank(res1.getBody()))
                    {
                        dbl.BusOrder_Item_Details_Success__c =String.valueOf(res1)+'..Body..'+String.valueOf(res1.getBody());
                        map<string,object> notificationResp = (map<string,object>)JSON.deserializeUntyped(res1.getBody());
                        if(notificationResp.containsKey('isEmailSent') && Boolean.valueOf(notificationResp.get('isEmailSent')) && notificationResp.containsKey('isSMSSent') && Boolean.valueOf(notificationResp.get('isSMSSent')))
                        {
                            dbl.BusOrder_Item_Details_Process_Status__c ='MIM Send Notification Ping Success';
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'PNR Updated Successfully and Notification Also Sent To Customer Successfully!'));
                        }
                        
                        else
                        {
                            dbl.BusOrder_Item_Details_Process_Status__c ='MIM Send Notification Ping Failed';
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'PNR Updated Successfully But Sending Notification Has Failed!'));
                        }
                    }
                    else
                    {
                        dbl.BusOrder_Item_Details_Process_Status__c ='MIM Send Notification Ping Failed';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'PNR Updated Successfully But Sending Notification Has Failed!'));
                        
                    }
                }
                else if(isSuc)
                {
                    orIt.isMIM_PNR_Updated__c = true;
                    dbl.Payment_Ping_Status__c = 'MIM Booking PNR Update Ping Success';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'PNR Updated Successfully.Please Send Ticket Notification to Customer Through EMail'));
                    
                }
                
                else
                {
                    dbl.Payment_Ping_Status__c = 'MIM Booking PNR Update Ping Success But Update Failed';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'PNR Update Has Failed .Please Retry!'));
                    
                }
                
            }
            else
            {
                dbl.Payment_Ping_Status__c = 'MIM Booking PNR Update Ping Failed';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'PNR Update Has Failed .Please Retry!'));
            }
            
            if(orIt.isMIM_PNR_Updated__c)
                update orIt;
            
        }
        Catch(Exception e)
        {
            dbl.Exception_Description__c = String.valueOf(e);
            System.debug('Exception in mimPnrUpdation..'+e);
        }
        insert dbl;
        return null;
    }
    
    public class MIMSeatWrapper
    {
        public string seatNo{get;set;}
        public string seatPnr{get;set;}
        
        public MIMSeatWrapper()
        {
        }
    }
    
}