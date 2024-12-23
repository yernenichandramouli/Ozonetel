/**
 * (c) 2017 RedBus
 *
 * Name           : LntngTravellerInfoCntrl
 * Created Date   : 25 Oct 2017
 * Created By     : Sreenivas M
 * Purpose        : Class to Fetch Passagner details based on Tin
 *
 **/
public class LtngTravellerInfoCntrl {
    
    public static string emialId{get;set;}
    public static string phoneNo{get;set;}
    public static list<TravellerWarpper> listTravellers{get;set;}
    public static string tinNo{get;set;}
    public static string busUnit{get;set;}
    public static boolean isConnectedService {get;set;}
    
    public LtngTravellerInfoCntrl()
    {
      string tid = ApexPages.currentPage().getParameters().get('id');
      if(tId!=null){
        Order_Items__c ordItem = [Select Order_Item_Reference_No__c,Rb_User_ID__c,Umbrella_TIN__c,Business_Unit__c,Package_Id__c,Order_Id__c,Transaction_Source__c from Order_Items__c Where id=:tId limit 1];
        tinNo=ordItem.Order_Item_Reference_No__c;
        busUnit=ordItem.Business_Unit__c;
        isConnectedService = String.isNotBlank(ordItem.Umbrella_TIN__c)?true:false;
      }
        listTravellers = new list<TravellerWarpper>();
    }
    public static void getPassangerDetails()
    {
       //String tin = ApexPages.currentPage().getParameters().get('id');
       //String busiUnit = ApexPages.currentPage().getParameters().get('Bu');
       
       String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketDetails'].Endpoint__c;
       
       if(String.isNotBlank(tinNo))
       {
           Order_Items__c ordItem = [Select Business_Unit__c,Guid__c,Order_Id__c,Amount_Recieved_Currency__c,Order_Item_Reference_No__c from Order_Items__c Where Order_Item_Reference_No__c=:tinNo limit 1];
           string comCurrency=ordItem.Amount_Recieved_Currency__c;

            http ht=new http(); 
            HttpRequest httpReq= new HttpRequest();
            httpReq.setEndpoint(endPoint+tinNo);
            httpReq = HttpRequestUtil.populateHeaders(httpReq);
            httpReq.setMethod('GET');
            httpReq.setHeader('Channel_Name','SFA');
            httpReq.setHeader('auth_key','a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
            
            if(!OrderItemTransactionResource__c.getAll().containsKey(busUnit))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This Business Unit Is Not Available In Salesforce.Please Contact SF Admin!'));
            }
            else
            {
                
              if('REDBUS_COM'.equalsIgnoreCase(busUnit)){
                httpReq.setHeader('Country_Name','RDC');
                httpReq.setHeader('SelectedCurrency',comCurrency);
                httpReq.setHeader('Currency',comCurrency);
                }else{
                 httpReq.setHeader('Country_Name',OrderItemTransactionResource__c.getValues(busUnit).Auth_Key__c);
                 httpReq.setHeader('SelectedCurrency',OrderItemTransactionResource__c.getValues(busUnit).Default_Currency__c);
                }
         
                if(string.isNotBlank(busUnit) &&!busUnit.startsWith('REDBUS_'))
                {
                    httpReq.setHeader('Operator',busUnit.split('_')[0]);
                }
                
                              
                try
                {
                   HttpResponse res = ht.send(httpReq);
                   System.debug('Response...'+res);
                   // string resBody ='{"TicketNo":"TKAB33611108","PnrNo":"64577575","OrderId":"12043208655389570","Name":"Tressa","PassengerDetails":[{"Name":"Tressa","Age":"45","Gender":"FEMALE","Title":"","SeatNumber":"L2","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"sherlyn","Age":"28","Gender":"FEMALE","Title":"","SeatNumber":"L1","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"Mary","Age":"48","Gender":"FEMALE","Title":"","SeatNumber":"L4","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"marilyn","Age":"17","Gender":"FEMALE","Title":"","SeatNumber":"L3","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"angela","Age":"13","Gender":"FEMALE","Title":"","SeatNumber":"U","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null}],"EmailId":"sherlynrodricks.sr@gmail.com","MobileNo":"919920996064","Source":"Goa","Destination":"Mumbai","SourceId":"210","Discount":0,"DestinationId":"462","JourneyDate":"2017-10-31T20:30","TravelsName":" Neeta Travels (Laxmi Travellers)","BusType":"A/C Seater/Sleeper (2+1)","NoofSeats":"5","SeatNos":"L2,L1,L4,L3,U","TicketFare":{"currencyType":"INR","amount":5325},"ReportingTime":"2017-10-31T20:15","BPDetails":{"Id":1712347,"Location":"Mapusa,Inside Taxi Stand,","Address":"Inside Taxi Stand, Mapusa","Landmark":"Mapusa,Inside Taxi Stand,","ContactNo":"8652222816,8691033363","time":"08:30 PM","ReportingTime":"2017-10-31T20:15:00","LatLang":"15.589951,73.810197","DateTimeValue":"2017-10-31T20:30"},"DPDetails":{"Id":105412,"Location":"Malad-(E) pushpa park","Address":"Malad-[E], Near Pushpa Park, W.E.Express Highway","Landmark":"Malad-(E) pushpa park","ContactNo":"02228944040,02228952323,02228902666","time":"11:20 AM","ReportingTime":null,"LatLang":"19.188535,72.858397","DateTimeValue":"2017-11-01T11:20:00"},"Notes":null,"FirstBoardingTime":"2017-10-31T20:30","TicketStatus":"CONFIRMED","CancellationPolicy":"0:4:100:0;4:8:85:0;8:12:75:0;12:24:65:0;24:48:50:0;48:60:25:0;60:-1:10:0","RouteId":"9167404","OperatorId":"3620","IsMTicket":true,"tripId":"","AdviceTips":["Remember to carry water bottle.","Remember to carry blanket","Remember to fully charge your phone before journey. There is no charging facility on bus."],"TravelDuration":"14.50","Weather":null,"IsGPSEnabled":true,"YBServiceId":"25999","YBOperatorId":"NET","InventoryType":"","isCancellablePostJourney":false,"IsMimenabled":false,"driverDetails":null,"Country":"IND","PrimaryBoardingTime":"2017-10-31T19:00","BOContact":"8652222820","isOTGEnable":false,"vDepTime":"1140","IDType":null,"IDNumber":null,"TransactionCharge":75,"TransactionId":"12043208655406234","InsuranceCharges":0,"TotalAmountPaid":5325,"AmountReceived":5325,"SalesChannel":"WEBDIRECT","isPartialCancellationAllowed":"False","isPhoneBookingSpecial":"0","FareAdjustment":250,"FirstBoardingTimeInMin":1230,"DateOfIssue":"14/09/2017","Zcafe":null,"customerPriceBreakUp":[{"componentName":"BASIC_FARE","value":5000,"refundableValue":5000},{"componentName":"BUS_OPERATOR_GST","value":250,"refundableValue":250}],"bookingCustomerDetails":{"name":"Tressa","title":"","email":"sherlynrodricks.sr@gmail.com","mobileNo":"919920996064","rbUserId":-1}}';
                   string resBody=res.getBody();
                    System.debug('resBody...'+resBody);
                    if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                    {
                        map<string,object> tickDetails = (map<string,object>)JSON.deserializeUntyped(resBody);
                        List<Object> ticketsInfo = (List<Object>)tickDetails.get('ticketsInfo');
                        Map<String, Object> selectedTicket = null;

                        System.debug(':::: ticketsInfo = '+ticketsInfo);

                        if (ticketsInfo != null && !ticketsInfo.isEmpty() && isConnectedService) {
                            // Iterate through each ticket
                            for (Object ticketObj : ticketsInfo) {
                                // Cast the ticket object to a Map
                                Map<String, Object> ticket = (Map<String, Object>)ticketObj;
                                
                                // Check if the TicketNo matches
                                if (ticket.get('TicketNo') == tinNo) {
                                    selectedTicket = ticket;
                                    emialId = selectedTicket.KeySet().contains('EmailId')?(String)selectedTicket.get('EmailId'):'';
                                    phoneNo = selectedTicket.KeySet().contains('MobileNo')?(String)selectedTicket.get('MobileNo'):'';
                                    if(selectedTicket.KeySet().contains('PassengerDetails') && selectedTicket.get('PassengerDetails')!=null){
                                        system.debug('passenger list..'+selectedTicket.get('PassengerDetails'));
                                        listTravellers = (list<TravellerWarpper>)JSON.deserialize(JSON.serialize(selectedTicket.get('PassengerDetails')),list<TravellerWarpper>.class);
                                        system.debug('listTravellers list..'+listTravellers+'Ema..'+emialId +phoneNo ); 
                                    }
                                    System.debug(':::: selectedTicket = '+selectedTicket);
                                    break;
                                }
                            }
                        }else{
                            emialId = tickDetails.KeySet().contains('EmailId')?(String)tickDetails.get('EmailId'):'';
                            phoneNo = tickDetails.KeySet().contains('MobileNo')?(String)tickDetails.get('MobileNo'):'';
                            if(tickDetails.KeySet().contains('PassengerDetails') && tickDetails.get('PassengerDetails')!=null)
                            {
                                system.debug('passenger list..'+tickDetails.get('PassengerDetails'));
                                listTravellers = (list<TravellerWarpper>)JSON.deserialize(JSON.serialize(tickDetails.get('PassengerDetails')),list<TravellerWarpper>.class);
                                system.debug('listTravellers list..'+listTravellers+'Ema..'+emialId +phoneNo ); 
                            }
                        }
                    }
                }
                Catch(Exception e)
                {
                    System.debug('Traveller Info error..'+e);
                }
            }
        }
    }

    public class TravellerWarpper
    {
        public string Name{get;set;}
        public string  Age{get;set;}
        public string Gender{get;set;}
        public string Title{get;set;}
        public string SeatNumber{get;set;}
        public string pnr{get;set;}
        public string Nationality{get;set;}
        public string DOB{get;set;}
        public string IdProofType{get;set;}
        public string ProofId{get;set;}
        
        public TravellerWarpper()
        {
            system.debug('ttt'+Name+Age+Gender+Title+SeatNumber+pnr+Nationality+DOB+IdProofType+ProofId);
        }
    }
    
}