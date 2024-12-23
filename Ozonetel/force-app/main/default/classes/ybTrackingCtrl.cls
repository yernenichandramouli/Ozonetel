/*
* Name           : ybTrackingCtrl
* Created Date   : 2024-FEB-20
* Created By     : VR Sudarshan 
* Purpose        : Controller to get the your bus live tracking details.
* Test class     : ybTrackingCtrlTest
* Jira Id        : CRM-1676
*/
public class ybTrackingCtrl {

    @AuraEnabled
    public static bpDetailsWrapperToReturn fetchBpDpDetails(string transactionID){
        System.debug(':: Transaction Id '+transactionID);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='YB - Get BpDp Details';
        dbl.User_Id__c = UserInfo.getUserName();
        bpDetailsWrapperToReturn returnWrapper = New bpDetailsWrapperToReturn();
        returnWrapper.hideArrivalPatterns = false;
        returnWrapper.isError = false;
        List<Order_Items__c> transactionList = [SELECT Id, Order_Item_Reference_No__c, Corrected_Date_of_Journey__c, RecordType.Name  FROM Order_Items__c WHERE Id =:transactionId AND RecordType.Name in('Bus Booking','B2B Bus Booking') LIMIT 1];
        dbl.Payment_Transaction_Name__c =transactionList[0].Id;
        System.debug('::: transactionId ::: ' +String.valueOf(transactionList[0].Corrected_Date_of_Journey__c.date()));

        if(!transactionList.isEmpty()){
            DateTime dojDate = transactionList[0].Corrected_Date_of_Journey__c;
            string  finalDoj= dojDate.format('YYYY-MM-dd');
            String busType = String.valueOf(transactionList[0].RecordType.Name)=='Bus Booking'?'B2C':'B2B';
            returnWrapper.busType = busType;
            string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='YB_GetBpDp_Details'].Endpoint__c;
            if(dojDate<System.today()){
                endpoint = endpoint + 'tin='+transactionList[0].Order_Item_Reference_No__c+'&customertype='+busType+'&doj='+finalDoj;
            }else{
                endpoint = endpoint + 'tin='+transactionList[0].Order_Item_Reference_No__c+'&customertype='+busType;
            }
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            HttpResponse res = new HttpResponse();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(120000);
            dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+' -- Request --'+req;
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            try{
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string resBody=res.getBody(); 
                // resBody='{"msg":"","data":{"vehicle_no":"GJ03BT4","traveler_name":"Dhanveer Tours and Travels Pvt.Ltd.","route":"Rajkot (Gujarat)-Jamnagar","doj":"2024-06-12","driver_details":"08264717786","bp_contact":"7405344447, 7405344449","dp_conatct":"","tracking_type":"Full Tracking","redbus_tarcking_link":"https://b.redbus.com/q2PpL5ece","yourbus_tracking_link":"http://s.yourbus.in/ME9","bp_name":"Bigbajar","bp_sta":"17:10:00","bp_ata":"","bp_address":"Big Bazar (150FT Ring Road","bp_street_view_link":"https://v.redbus.com/mi6uQ89d1","bp_address_link":"https://www.google.com/maps/dir/?api=1\u0026destination=22.280243,70.775835","dp_name":"Indira Marg","dp_sta":"19:00:00","dp_ata":"","dp_address":"Dhanveer Travels, Near Sat Rasta M.P Shah College gate","dp_street_view_link":"https://v.redbus.com/VRa2Z16fb","dp_address_link":"https://www.google.com/maps/dir/?api=1\u0026destination=22.473291,70.065825","yb_enabled":1,"service_no":"NTATRAJKOT-JAMNAGAR-0430PM","is_pick_up_bp":1,"service_bps":{"19186994":"Bigbajar, 17:10","19186995":"Dhanveer Travels,150Ft Ring Road, Indira Circle, Nr. Telephone Exchange, 17:15","19187014":"Madhapar Chokdi, 17:30"}}}'; 
                System.debug(':: resBody = '+resBody);
                
                map<string,object> tickDetails = (map<string,object>)JSON.deserializeUntyped(resBody);
                System.debug(':: tickDetails = '+tickDetails);
                system.debug('Message..'+tickDetails.get('msg'));
                // if(tickDetails.KeySet().contains('msg') && (tickDetails.get('msg')==null || tickDetails.get('msg')=='') && tickDetails.get('data')!=null){
                if(res.getStatusCode() == 200 && res.getStatus()=='OK' && String.isNotBlank(resBody)){    
                    system.debug('passenger list..'+tickDetails.get('data'));
                    system.debug('Message..'+tickDetails.get('msg'));
                    data dataWrapper = New data();
                    dataWrapper = (data)JSON.deserialize(JSON.serialize(tickDetails.get('data')),data.class);
                    system.debug('dataWrapper..'+dataWrapper.service_bps);
                    returnWrapper.data = dataWrapper;
                    if(dataWrapper.service_bps!=null){
                        Map<String,String> tempMap = New Map<String,String>();
                        Map<String, String> tempMapPlace = new Map<String, String>();
                        Map<String, String> tempDatePlace = new Map<String, String>();
                        tempMap = dataWrapper.service_bps;
                        for (String key : tempmap.keySet()) {
                            String[] parts = tempmap.get(key).split(',\\s*');
                            if (parts.size() == 2) {
                                tempMapPlace.put(key, parts[0]);
                                tempDatePlace.put(key, parts[1]);
                            }
                        }
                        returnWrapper.bpIdAndNames = tempMapPlace;
                        returnWrapper.bpIdAndTime = tempDatePlace;
                        returnWrapper.isError = false;
                        return returnWrapper;
                    }else{
                        returnWrapper.arrivalPatternsError = true;
                        returnWrapper.hideArrivalPatterns = true;
                        returnWrapper.errorMessage = 'Service BPIds are null';
                        return returnWrapper;
                    }
                }else if((String)tickDetails.get('msg')!=null){
                    returnWrapper.isError = true;
                    returnWrapper.errorMessage = (String)tickDetails.get('msg');
                    return returnWrapper;
                }
            }catch(Exception e){
                System.debug(':: Exception occured '+e.getLineNumber());
                returnWrapper.isError = true;
                returnWrapper.errorMessage = e.getMessage() +e.getLineNumber();
                return returnWrapper;
            }
        }
        returnWrapper.isError = true;
        returnWrapper.errorMessage = 'Transaction Not Found '+transactionID;
        return returnWrapper;
    }

    @AuraEnabled
    public static string Getarrivalpatterns(string transactionId, string boardingPointId) {
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='YB - Get Arrival Patterns';
        dbl.User_Id__c = UserInfo.getUserName();
        System.debug('::: transactionId ::: ' +transactionId);
        System.debug('::: boardingPointId ::: ' +boardingPointId);
        List<Order_Items__c> transactionList = [SELECT Id, Service_Provider_Id__c, ServiceID__c, Boarding_Point_Id__c FROM Order_Items__c WHERE Id =:transactionId LIMIT 1];
        string jsonCM='{"rbOperatorId": '+transactionList[0].Service_Provider_Id__c+',"serviceId":'+transactionList[0].ServiceID__c+',"rbBpId":'+boardingPointId+'}';
        //string jsonCM= '{"rbOperatorId": "16027", "serviceId": "55", "rbBpId": "1732964"}';
        dbl.Payment_Transaction_Name__c =transactionList[0].Id;
        System.debug('jsonCM-->'+jsonCM);
        try{
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setHeader('country','IND');
            req.setHeader('channel_name','android');
            req.setHeader('os','web');
            req.setHeader('Content-Type','application/json');
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='YBArrivalTrends_API'].Endpoint__c);
            // req.setEndpoint('https://reports.yourbus.in:3333/liveTracking/arrivalTrends');
            req.setBody(jsonCM);
            res = http.send(req);
            dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Content-Type--'+req.getHeader('Content-Type')+'-Headers-country--'+req.getHeader('country')+'-Headers-Accept-Language--'+req.getHeader('Accept-Language')+'-Headers-channel_name--'+req.getHeader('channel_name')+'-Headers-os--'+req.getHeader('os')+' -- Request Body --'+req.getBody();
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
            dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            insert dbl;
            string resBody=res.getBody();
            System.debug('res body--->'+res.getBody());
            return resBody;
        }catch(Exception e){
            dbl.Exception_Description__c=string.valueOf(e);
            insert dbl;
            System.debug('An exception occurred: ' + e.getMessage());
            return String.valueOf(e.getMessage());
        }
    }

    @AuraEnabled
    public static yourbusTrackingResponse getYourBusTrackingLink(string transactionId){
        yourbusTrackingResponse returnWrapper = New yourbusTrackingResponse();
        // returnWrapper.isError = false;
        // returnWrapper.urlToShow = 'https://reports.yourbus.in/ci/crmdash?op_id=19983&doj=2024-8-24&service_id=SCH298B387E';
        returnWrapper.isError = true;
        returnWrapper.errorMessage ='Tracking not not available for this bus';
        List<Order_Items__c> transactionList = [SELECT Id, Inventory_Type__c, Date_of_Boarding_Time__c,Service_Provider_Id__c,ServiceID__c  FROM Order_Items__c WHERE Id =:transactionId AND RecordType.Name in('Bus Booking','B2B Bus Booking') AND Date_of_Boarding_Time__c <=TODAY AND Transaction_Status__c='Booked' AND Order_Item_Reference_No__c!=Null AND Service_Provider_Id__c!=Null AND Date_of_Boarding_Time__c!=Null AND ServiceID__c!=Null LIMIT 1];
        if(!transactionList.isEmpty()){
            string url;
            String doj=transactionList[0].Date_of_Boarding_Time__c.year()+'-'+transactionList[0].Date_of_Boarding_Time__c.month()+'-'+transactionList[0].Date_of_Boarding_Time__c.day();
            if(transactionList[0].Inventory_Type__c=='GOIBIBO' || transactionList[0].Inventory_Type__c=='MMT'){
                string serviceId =GetTransactionDetails.fetchYbTrackingLink(transactionList[0].Id);
                url = 'https://reports.yourbus.in/ci/crmdash?op_id='+transactionList[0].Service_Provider_Id__c+'&doj='+doj+'&service_id='+serviceId;
            }else{
                url = 'https://reports.yourbus.in/ci/crmdash?op_id='+transactionList[0].Service_Provider_Id__c+'&doj='+doj+'&service_id='+transactionList[0].ServiceID__c;
            }
            returnWrapper.isError = false;
            returnWrapper.urlToShow = url;
        }
        return returnWrapper;
    }

    public class yourbusTrackingResponse{
        @AuraEnabled
        public boolean isError { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }
        @AuraEnabled
        public String urlToShow { get; set; }
    }

    public class data{
        @AuraEnabled
        public string vehicle_no { get; set; }
        @AuraEnabled
        public string traveler_name { get; set; }
        @AuraEnabled
        public string route { get; set; }
        @AuraEnabled
        public string doj { get; set; }
        @AuraEnabled
        public string driver_details { get; set; }
        @AuraEnabled
        public string bp_contact { get; set; }
        @AuraEnabled
        public string dp_conatct { get; set; }
        @AuraEnabled
        public string tracking_type { get; set; }
        @AuraEnabled
        public string redbus_tarcking_link { get; set; }
        @AuraEnabled
        public string yourbus_tracking_link { get; set; }
        @AuraEnabled
        public string bp_name { get; set; }
        @AuraEnabled
        public string bp_sta { get; set; }
        @AuraEnabled
        public string bp_ata { get; set; }
        @AuraEnabled
        public string bp_address { get; set; }
        @AuraEnabled
        public string bp_street_view_link { get; set; }
        @AuraEnabled
        public string bp_address_link { get; set; }
        @AuraEnabled
        public string dp_name { get; set; }
        @AuraEnabled
        public string dp_sta { get; set; }
        @AuraEnabled
        public string dp_ata { get; set; }
        @AuraEnabled
        public string dp_address { get; set; }
        @AuraEnabled
        public string dp_street_view_link { get; set; }
        @AuraEnabled
        public string dp_address_link { get; set; }
        @AuraEnabled
        public Integer yb_enabled { get; set; }
        @AuraEnabled
        public string service_no { get; set; }
        @AuraEnabled
        public Map<String, String> service_bps { get; set; }
        @AuraEnabled
        public Integer is_pick_up_bp { get; set; }
    }

    public class bpDetailsWrapperToReturn
    {
        @AuraEnabled
        public string msg { get; set; }
        @AuraEnabled
        public string busType { get; set; }
        @AuraEnabled
        public Data data { get; set; }
        @AuraEnabled
        public Boolean isError { get; set; }
        @AuraEnabled
        public Boolean hideArrivalPatterns { get; set; }
        @AuraEnabled
        public Boolean arrivalPatternsError { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }
        @AuraEnabled
        public Map<String, String> bpIdAndNames { get; set; }
        @AuraEnabled
        public Map<String, String> bpIdAndTime { get; set; }
    }
}