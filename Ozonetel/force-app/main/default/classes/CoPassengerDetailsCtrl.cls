/**
 * (c) 2023 RedBus
 *
 * Name           : CoPassengerDetailsCtrl
 * Created Date   : 22 JUL 2023
 * Jira Id        : CRM - 1364
 * Created By     : VR Sudarshan
 * Purpose        : Controller to fetch co passeger Details for Domestic and International.
 * Test class     : CoPassengerDetailsCtrlTest
 *
 **/
public class CoPassengerDetailsCtrl {

    @AuraEnabled(cacheable=false)
    public static List<JsonBodyWrapper> GetCoPassengerDetails(string ordItemId){
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        List<JsonBodyWrapper> rturnWrapperList = New List<JsonBodyWrapper>();
        try {
            ordIt=[select id,Date_Of_Service__c,Boarding_Time__c,Dropping_Time__c,Primary_Boarding_Point_Time__c,ServiceID__c,Business_Unit__c,Order_Item_Reference_No__c,Service_Provider_Id__c,Route_Id__c,Country__c from Order_Items__c where id=:ordItemId];
            if(!ordIt.isEmpty()){
                DateTime boardingPointEpoch = Datetime.newInstance(ordIt[0].Primary_Boarding_Point_Time__c.date(),Time.newInstance(00, 00, 00, 00));
                DateTime droppingPointEpoch = Datetime.newInstance(ordIt[0].Primary_Boarding_Point_Time__c.date(),Time.newInstance(23, 59, 59, 0));
                system.debug(':::: boardingPointEpoch = '+boardingPointEpoch);
                system.debug(':::: droppingPointEpoch = '+droppingPointEpoch);
                long strEpoch = getUTCDateTime(boardingPointEpoch).getTime()/1000;
                System.debug('utc time '+getUTCDateTime(boardingPointEpoch));
                long endEpoch=droppingPointEpoch.getTime()/1000;
                string BusUnit = 'REDBUS_'+ordIt[0].Business_Unit__c.split('_')[1];
                Country_Codes__c ccObj= Country_Codes__c.getValues(BusUnit);  
                string ounit=ccObj.ou__c;  
                String endpoint;
                if(BusUnit=='REDBUS_IN'){
                    endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='CoPassengerDetails'].Endpoint__c+'&serviceid='+ordIt[0].ServiceID__c+'&operatorid='+ordIt[0].Service_Provider_Id__c+'&startepocsec='+strEpoch+'&endepocsec='+endEpoch+'&ou='+ounit;

                }else{
                    endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='CoPassengerDetailsIntl'].Endpoint__c+'&serviceid='+ordIt[0].ServiceID__c+'&operatorid='+ordIt[0].Service_Provider_Id__c+'&startepocsec='+strEpoch+'&endepocsec='+endEpoch+'&ou='+ounit;
                }
                HttpResponse res = new HttpResponse();
                Map<String, String> omsHeaders= new Map<String, String>();
                omsHeaders.put('Content-Type','application/json');
                res = HTTPUtil.sendGenericHTTPRequest(endpoint,'GET','""',omsHeaders,100000,'Get Co-Pass Details');
                string responseBody = res.getBody();
                // string responseBody = '{"status":"SUCCESS","errors":[],"data":[{"tin":"TS6Y43146742","status":"CONFIRMED","phone":"919492433004","orderItemId":"13485424331028881","orderId":"13485396968565849","name":"giridharachary k","email":"giridharacharykandepu@gmail.com","droppingPoint":"Vishl Megamart","boardingPoint":"TIN Factory (Pickup Bus)","droppingTime":"2023-11-25 15:45:00","boardingTime":"2023-11-25 15:40:00"},{"tin":"TS6Y42791476","status":"CONFIRMED","phone":"917996296474","orderItemId":"13485537272482650","orderId":"13485537272468002","name":"I Venu Kumar","email":"lapuram@gmail.com","droppingPoint":"Vishl Megamart","boardingPoint":"East end Circle","droppingTime":"2023-11-24 12:45:00","boardingTime":"2023-11-24 13:40:00"},{"tin":"TS7265808970","status":"CONFIRMED","phone":"918884292420","orderItemId":"13487096326548577","orderId":"13487096326542137","name":"Samrat","email":"intruder5525@gmail.com","droppingPoint":"Vishl Megamart","boardingPoint":"Hebbal Esteem Mall","droppingTime":"2023-11-24 07:45:00","boardingTime":"2023-11-24 01:40:00"},{"tin":"TS7341571777","status":"CONFIRMED","phone":"919739174659","orderItemId":"13487667304146627","orderId":"13487667304134547","name":"Vinay","email":"vinayshettit@gmail.com","droppingPoint":"Vishl Megamart","boardingPoint":"TIN Factory (Pickup Bus)","droppingTime":"2023-11-24 02:45:00","boardingTime":"2023-11-24 01:43:00"},{"tin":"TS7377803357","status":"CONFIRMED","phone":"919959536002","orderItemId":"13487742680675273","orderId":"13487742680652684","name":"Hemanth","email":"hemanthkoti@gmail.com","droppingPoint":"Thirumalagiri","boardingPoint":"Marathahalli,Near HDFC Bank,beside kalanikethan towards silk board.","droppingTime":"2023-11-24 05:45:00","boardingTime":"2023-11-24 06:43:00"},{"tin":"TS7549895546","status":"CONFIRMED","phone":"919347935695","orderItemId":"13489202791378468","orderId":"13489202791364804","name":"Pooja JJ","email":"jjpooja4@gmail.com","droppingPoint":"Siddipet","boardingPoint":"Domlur - Below Domlur Bridge (Pickup Bus)","droppingTime":"2023-11-24 06:45:00","boardingTime":"2023-11-24 07:43:00"},{"tin":"TS7658115411","status":"CONFIRMED","phone":"919108648793","orderItemId":"13489601381522729","orderId":"13489261288679835","name":"Anuradha chintala","email":"anuchintala8@gmail.com","droppingPoint":"Jubilee Bus Station JBS","boardingPoint":"Jaya Nagar - Near R V Nursing Collage","droppingTime":"2023-11-24 06:45:00","boardingTime":"2023-11-24 07:43:00"},{"tin":"TS7758968254","status":"CONFIRMED","phone":"918179620889","orderItemId":"13490325664658865","orderId":"13490325664650505","name":"Saiyed Zeeshan Ahmed","email":"1999zee@gmail.com","droppingPoint":"Jubilee Bus Station JBS","boardingPoint":"HSR Layout - Towards Silk Board","droppingTime":"2023-11-24 06:45:00","boardingTime":"2023-11-24 07:43:00"},{"tin":"TS7722799823","status":"CONFIRMED","phone":"919663684747","orderItemId":"13490430632842457","orderId":"13490430632824130","name":"GAYATHRI MAHESH","email":"gayathri.b69@gmail.com","droppingPoint":"Siddipet","boardingPoint":"Jaya Nagar - Near R V Nursing Collage","droppingTime":"2023-11-24 06:45:00","boardingTime":"2023-11-24 07:43:00"},{"tin":"TS7773991980","status":"CONFIRMED","phone":"919964641759","orderItemId":"13490462972863467","orderId":"13490462972848851","name":"Anikethan","email":"anikethans1998@gmail.com","droppingPoint":"Vishl Megamart","boardingPoint":"Anand Rao Circle","droppingTime":"2023-11-24 06:45:00","boardingTime":"2023-11-24 07:43:00"}]}';
                if(res.getBody()!='null' && res.getStatusCode()==200 && String.isNotBlank(responseBody)){
                    genericApiResponseData respWrap = New genericApiResponseData();
                    respWrap = (genericApiResponseData)JSON.deserialize(responseBody,genericApiResponseData.class);
                    if(!respWrap.data.isEmpty()){
                        List<string> orderIdList = New List<string>();
                        for(JsonBodyWrapper respData: respWrap.data){
                            orderIdList.add(respData.tin);
                        }
                        List<Order_Items__c> orderItemList = [SELECT Id, Order_Item_Reference_No__c FROM  Order_Items__c WHERE Order_Item_Reference_No__c in :orderIdList];
                        Map<string,Id> newMap = New Map<string,Id>();
                        for(Order_Items__c orIt : orderItemList){
                            newMap.put(orIt.Order_Item_Reference_No__c,orIt.Id);
                        }

                        for(JsonBodyWrapper respData: respWrap.data){
                            JsonBodyWrapper jsBodyWrap = New JsonBodyWrapper();
                            jsBodyWrap.tin = respData.tin;
                            jsBodyWrap.status = respData.status;
                            jsBodyWrap.orderItemId = respData.orderItemId;
                            jsBodyWrap.orderId = respData.orderId;
                            jsBodyWrap.name = respData.name;
                            jsBodyWrap.email = respData.email;
                            jsBodyWrap.phone = respData.phone;
                            jsBodyWrap.droppingPoint = respData.droppingPoint;
                            jsBodyWrap.boardingPoint = respData.boardingPoint;
                            jsBodyWrap.droppingTime = respData.droppingTime;
                            jsBodyWrap.boardingTime = respData.boardingTime;
                            jsBodyWrap.transactionId = newMap.containsKey(respData.tin)?newMap.get(respData.tin): null;
                            rturnWrapperList.add(jsBodyWrap);
                        }
                    }
                }
                System.debug('::: rturnWrapperList = '+rturnWrapperList);
                return rturnWrapperList;
            }else{
                return rturnWrapperList;
            }
        } catch (Exception e) {
            System.debug('::: Exception occured at Line '+e.getMessage());
            return rturnWrapperList;
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<PassengerTicket> GetB2BCoPassengerDetails(string ordItemId){
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        List<PassengerTicket> rturnWrapperList = New List<PassengerTicket>();
        try {
            ordIt=[select id,Route_Id__c,Date_Of_Service__c, Order_Item_Reference_No__c from Order_Items__c where id=:ordItemId];
            if(!ordIt.isEmpty()){
                Datetime LastModifiedDateTime = ordIt[0].Date_Of_Service__c; 
                System.debug( 'LastModifiedDateTime is ' + LastModifiedDateTime ); 
                Date ModifiedDate = LastModifiedDateTime.Date();
                System.debug( 'ModifiedDate is ' + String.valueOf(ModifiedDate));

                String endpoint;
                endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='B2BCoPassengerDetails'].Endpoint__c+ordIt[0].Route_Id__c+'&doj='+String.valueOf(ModifiedDate);
                System.debug('::: Endpoint = '+endpoint);
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req.setTimeout(120000);              
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                res = http.send(req);  
                string responseBody = res.getBody();
                // string responseBody = '{"passengerTickets":[{"iSServiceIdIGDoj":2122502247580075491,"tin":"D8QKCPFP","pnr":"D8QKCPFP","source":"Kolar","destination":"Hisar","seats":["1"],"boardingPoint":"Kolar","boardingPointId":188606,"boardingTime":1110,"fare":55.50,"bookedByAccount":20820329,"bookedBy":"whatsapp feature testing","account":20820329,"accountName":"whatsapp feature testing","passengerName":"test_automation_passenger_name","mobile":"8909876543","bookingType":"STANDARD","bookingTime":"2023-12-27T15:19:30.000+0530","bookingAgent":"whatsapp feature testing","altArranged":false,"altInformed":false,"salesChannel":"api","travels":"Virtual_travels","dropLocation":"Hyderabad","dropLocationId":189153,"dropLocationTime":930,"agentServiceCharge":0.00,"ticketId":40510202,"itineraryLegId":40538746,"operator":10011111,"doj":"2024-01-11T00:00:00.000+0530","phoneReservation":false,"postPonedTicket":false},{"iSServiceIdIGDoj":2122502247580075491,"tin":"D896B4S5","pnr":"D896B4S5","source":"Kolar","destination":"Hisar","seats":["2"],"boardingPoint":"Kolar","boardingPointId":188606,"boardingTime":1110,"fare":55.50,"bookedByAccount":20820329,"bookedBy":"whatsapp feature testing","account":20820329,"accountName":"whatsapp feature testing","passengerName":"test_automation_passenger_name","mobile":"8909876543","bookingType":"STANDARD","bookingTime":"2023-12-27T15:44:48.000+0530","bookingAgent":"whatsapp feature testing","altArranged":false,"altInformed":false,"salesChannel":"api","travels":"Virtual_travels","dropLocation":"Hisar Bus Stop","dropLocationId":189153,"dropLocationTime":930,"agentServiceCharge":0.00,"ticketId":40510214,"itineraryLegId":40538759,"operator":10011111,"doj":"2024-01-11T00:00:00.000+0530","phoneReservation":false,"postPonedTicket":false}]}';
                system.debug(':::: responseBody = '+responseBody);
                DblogforQuickActionLwcCtrl.dblogCaptureMethod('B2B Co Passenger Details',String.valueOf(req.getEndpoint()),ordIt[0].Order_Item_Reference_No__c,String.valueOf(req),responseBody,'','');
                // if(String.isNotBlank(responseBody)){
                if(res.getBody()!='null' && res.getStatusCode()==200 && String.isNotBlank(responseBody)){
                    genericB2BApiResponseData respWrap = New genericB2BApiResponseData();
                    respWrap = (genericB2BApiResponseData)JSON.deserialize(responseBody,genericB2BApiResponseData.class);
                    system.debug(':::: respWrap = '+respWrap.passengerTickets);
                    if(!respWrap.passengerTickets.isEmpty()){
                        List<string> orderIdList = New List<string>();
                        for(PassengerTicket respData: respWrap.passengerTickets){
                            orderIdList.add(respData.tin);
                        }
                        List<Order_Items__c> orderItemList = [SELECT Id, Order_Item_Reference_No__c FROM  Order_Items__c WHERE Order_Item_Reference_No__c in :orderIdList];
                        Map<string,Id> newMap = New Map<string,Id>();
                        for(Order_Items__c orIt : orderItemList){
                            newMap.put(orIt.Order_Item_Reference_No__c,orIt.Id);
                        }
                        for(PassengerTicket respData: respWrap.passengerTickets){
                            PassengerTicket jsBodyWrap = New PassengerTicket();
                            jsBodyWrap.tin = respData.tin;
                            jsBodyWrap.boardingPoint = respData.boardingPoint;
                            jsBodyWrap.dropLocation = respData.dropLocation;
                            string doj = string.valueof(respData.doj.replace('T',' '));
                            DateTime dt = DateTime.valueOf(doj);
                            String formattedDateTime = dt.format('yyyy-MM-dd HH:mm:ss');
                            jsBodyWrap.doj =formattedDateTime;
                            Integer boardingTimeToBeAdded = respData.boardingTime+330;
                            system.debug(':::: boardingTimeToBeAdded = '+boardingTimeToBeAdded);
                            jsBodyWrap.convertedBoardingPoint = Datetime.valueOf(formattedDateTime).addMinutes(boardingTimeToBeAdded);
                            // jsBodyWrap.convertedBoardingPoint = Datetime.valueOf(jsBodyWrap.convertedBoardingPoint).addMinutes(330);
                            jsBodyWrap.dropLocationTime = respData.dropLocationTime;
                            Integer droppingTimeToBeAdded = respData.dropLocationTime+330;
                            system.debug(':::: boardingTimeToBeAdded = '+boardingTimeToBeAdded);
                            jsBodyWrap.convertedDroppingPoint = Datetime.valueOf(formattedDateTime).addMinutes(droppingTimeToBeAdded);
                            jsBodyWrap.mobile = respData.mobile;
                             string bookedByAccountVal = string.valueof(respData.bookedByAccount);
                             if(String.isNotBlank(bookedByAccountVal)){
                               map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(system.label.B2B_Transaction_Account);
                               if(resObj.containsKey(bookedByAccountVal)){
                                   jsBodyWrap.InventoryType=string.valueOf(resObj.get(bookedByAccountVal));
                               } else{
                                   jsBodyWrap.InventoryType='Other Partner';
                               }   
                            }
                        //     jsBodyWrap.email = respData.email;
                        //     jsBodyWrap.phone = respData.phone;
                        //     jsBodyWrap.droppingPoint = respData.droppingPoint;
                        //     jsBodyWrap.boardingPoint = respData.boardingPoint;
                        //     jsBodyWrap.droppingTime = respData.droppingTime;
                        //     jsBodyWrap.boardingTime = respData.boardingTime;
                            jsBodyWrap.transactionId = newMap.containsKey(respData.tin)?newMap.get(respData.tin): null;
                            system.debug(':::: transactionId = '+jsBodyWrap.transactionId);
                            rturnWrapperList.add(jsBodyWrap);
                        }
                    }
                }
                System.debug('::: rturnWrapperList = '+rturnWrapperList);
                return rturnWrapperList;
            }else{
                return rturnWrapperList;
            }
        } catch (Exception e) {
            System.debug('::: Exception occured at Line '+e.getMessage());
            return rturnWrapperList;
        }
    }

    public static DateTime getUTCDateTime(DateTime dt){
        Datetime GMTDate = Datetime.newInstanceGmt(dt.year(), dt.month(),dt.day(), dt.hour(), dt.minute(), dt.second());
        return GMTDate;
    }

    
    public class JsonBodyWrapper
    {
        @AuraEnabled
        public Id transactionId { get; set; }
        @AuraEnabled
        public string tin { get; set; }
        @AuraEnabled
        public string status { get; set; }
        @AuraEnabled
        public string phone { get; set; }
        @AuraEnabled
        public string orderItemId { get; set; }
        @AuraEnabled
        public string orderId { get; set; }
        @AuraEnabled
        public string name { get; set; }
        @AuraEnabled
        public string email { get; set; }
        @AuraEnabled
        public string droppingPoint { get; set; }
        @AuraEnabled
        public string boardingPoint { get; set; }
        @AuraEnabled
        public string droppingTime { get; set; }
        @AuraEnabled
        public string boardingTime { get; set; }
    }

    public class genericApiResponseData
    {
        @AuraEnabled
        public string status { get; set; }
        @AuraEnabled
        public List<JsonBodyWrapper> data { get; set; }
    }

    public class PassengerTicket
    {
        @AuraEnabled
        public Id transactionId { get; set; }
        @AuraEnabled
        public Long iSServiceIdIGDoj { get; set; }
        @AuraEnabled
        public string tin { get; set; }
        @AuraEnabled
        public string pnr { get; set; }
        @AuraEnabled
        public string source { get; set; }
        @AuraEnabled
        public string destination { get; set; }
        @AuraEnabled
        public List<string> seats { get; set; }
        @AuraEnabled
        public string boardingPoint { get; set; }
        @AuraEnabled
        public Integer boardingPointId { get; set; }
        @AuraEnabled
        public Integer boardingTime { get; set; }
        @AuraEnabled
        public double fare { get; set; }
        @AuraEnabled
        public Integer bookedByAccount { get; set; }
        @AuraEnabled
        public string bookedBy { get; set; }
        @AuraEnabled
        public Integer account { get; set; }
        @AuraEnabled
        public string accountName { get; set; }
        @AuraEnabled
        public string passengerName { get; set; }
        @AuraEnabled
        public string mobile { get; set; }
        @AuraEnabled
        public string comments { get; set; }
        @AuraEnabled
        public string bookingType { get; set; }
        @AuraEnabled
        public DateTime bookingTime { get; set; }
        @AuraEnabled
        public string bookingAgent { get; set; }
        @AuraEnabled
        public boolean altArranged { get; set; }
        @AuraEnabled
        public boolean altInformed { get; set; }
        @AuraEnabled
        public string salesChannel { get; set; }
        @AuraEnabled
        public Integer bookingUser { get; set; }
        @AuraEnabled
        public string travels { get; set; }
        @AuraEnabled
        public string dropLocation { get; set; }
        @AuraEnabled
        public Integer dropLocationId { get; set; }
        @AuraEnabled
        public Integer dropLocationTime { get; set; }
        @AuraEnabled
        public double agentServiceCharge { get; set; }
        @AuraEnabled
        public Integer ticketId { get; set; }
        @AuraEnabled
        public Integer itineraryLegId { get; set; }
        @AuraEnabled
        public Integer operator { get; set; }
        @AuraEnabled
        public string doj { get; set; }
        @AuraEnabled
        public boolean postPonedTicket { get; set; }
        @AuraEnabled
        public boolean phoneReservation { get; set; }
        @AuraEnabled
        public Datetime convertedBoardingPoint { get; set; }
        @AuraEnabled
        public Datetime convertedDroppingPoint { get; set; }
         @AuraEnabled
        public string InventoryType{ get; set; }
    }

    public class genericB2BApiResponseData
    {
        @AuraEnabled
        public string status { get; set; }
        @AuraEnabled
        public List<PassengerTicket> passengerTickets { get; set; }
    }
}