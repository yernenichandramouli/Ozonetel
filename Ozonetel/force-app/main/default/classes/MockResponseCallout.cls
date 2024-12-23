/**
 * (c) 2017 RedBus
 *
 * Name           : MockResponseCallout
 * Created Date   : 04 Jan 2017
 * Created By     : Sreenivas M
 * Purpose        : MockResponse class for Bus Cancellation,Walllet History and Wallet Cashback status.
 *
 **/
 
@isTest
global class MockResponseCallout implements HttpCalloutMock{
  global HTTPResponse respond(HTTPRequest req) {
       
       HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');   
       res.setStatusCode(200);
       res.setStatus('OK');
       
       Map<String,String> mapAPis = new Map<String,String>();
       for(API_EndPoints__mdt api :[SELECT Endpoint__c, DeveloperName from API_EndPoints__mdt])
       {
           mapAPIs.put(api.DeveloperName,api.Endpoint__c);
       
       }
       
       System.debug('Endpoint..'+req.getEndpoint()+'..'+mapAPIs);
       
       if(req.getEndpoint().contains(mapAPIs.get('BusCancellation')))
       {
            // Create a fake response
            System.assertEquals('POST', req.getMethod());
                       
            if(req.getEndpoint().contains('Update'))         
                res.setBody('[{"tin":"TJCN774445","status":"Approved For Bus Cancellation","IsSucess":true,"notes":null,"routeId": 2222233},{"tin":"TJCN4444446","status":"Approved For Bus Cancellation","IsSucess":true,"notes":null,"routeId": 2222233},{"tin":"TIN6473553","status":"Approved For Bus Cancellation","IsSucess":true,"notes":null,"routeId": 2222233}]');
            else
               res.setBody('[{"tin": "TJCN774445","status": "INITIATED","IsSucess": true,"notes": null}]');
       }
       
       if(req.getEndpoint().contains(mapAPIs.get('WalletHistory')))
       {
          System.assertEquals('GET', req.getMethod());
          res.setBody('[{"TransactionDate": "2016-12-21 10:07:31","TransactionMode": "CONVERTED_REFUND","TransactionType": "CREDIT","Amount": "63.5","ExprationDate": null,"OfferName": null,"AmountUsed": null,"OpeningBalance": "56","ClosingBalance": "119.5","SalesChannel": "WEBDIRECT","ReferenceNo": null}]');
                
       }
       
       if(req.getEndpoint().contains(mapAPIs.get('WalletCashBack')))
       {
          System.assertEquals('GET', req.getMethod());         
          res.setBody('[{"Type": "LOYALTY","Amount": 11,"Status": "INITIATED","OfferCode": "CASHBACK_3_NORTH","TIN": "TJ8B45762624"}]');
               
       }
       
       System.debug('Req endpoint..'+req.getEndpoint()+'...trips..'+mapAPIs.get('UserTrips'));
       
       if(req.getEndpoint().contains(mapAPIs.get('UserTrips')))
       {
          System.assertEquals('GET', req.getMethod());         
          res.setBody('[{"tin":"TK3Q44669","transactionNo":157867740,"cartId":128733832,"status":0,"dateOfJourney":"28FEB","source":"Jamnagar","destination":"Rajkot","travels":"Ashwamegh Travels Agency","pnr":"55205486","seats":"6,4","userId":"912852","emailId":"poornima.j@redbus.in","phone":"919167523229","creationDate":"2017-02-21T10:44:25"},{"tin":null,"transactionNo":157279657,"cartId":128150415,"status":0,"dateOfJourney":"28FEB","source":"Jamnagar","destination":"Rajkot","travels":"Royal Comfort Express L L P","pnr":null,"seats":"Q","userId":"912852","emailId":"poornima.j@redbus.in","phone":"919167523229","creationDate":"2017-02-16T16:55:29"}]');  
       }
       
      if(req.getEndpoint().contains(mapAPIs.get('NEFTWalletDebit')))
       {
            
            System.assertEquals('POST', req.getMethod());                       
            res.setBody('{"tin" :[ "TJ3487453434", "TJ3487434" ], "statusMessage" : "SUCCESS", "statusCode" : "200" }');
       }
       
       if(req.getEndpoint().contains(mapAPIs.get('NewUserGFT')))
       {
            System.assertEquals('POST', req.getMethod());                       
            res.setBody('[{ "mobile": "917411796876","email": "sadsa@asdasd.com","isNewUser": true}]');
       }
       
        if(req.getEndpoint().contains(mapAPIs.get('LatestTransStatus')))
       {
            
            System.assertEquals('POST', req.getMethod());                       
            res.setBody('{"5E786D6F5405F0055BE4CE5801010100":{"items":{"5e8477ad5405f0055be4ce5801020100":"TENTATIVE_SUCCESSFUL"},"payments":{"5e8efc6e5405f0055be4ce5802030100":"COMPLETED"}}}');
       }
       
       if(req.getEndpoint().contains(mapAPIs.get('Wallet_Balance_Check')))
       {
            System.assertEquals('POST', req.getMethod());                       
            res.setBody('{"Data":{"totalBalance":6995.59,"offerBalance":0.0,"coreBalance":6995.59,"offers":[]},"IsWalletCreated":false,"NewToken":null,"WalletId":null,"Status":{"code":0,"statusCode":200,"error":"Balance successfully fetched.","statusMessage":"SUCCESS","type":null},"ResponseMessage":"Success"}');
       
       }
       
       if(!req.getEndpoint().contains('Cancel') && req.getEndpoint().contains(mapAPIs.get('TicketDetails')))
       {
          System.assertEquals('GET', req.getMethod());
          res.setBody('{"TicketNo":"TKAB33611108","PnrNo":"64577575","OrderId":"12043208655389570","Name":"Tressa","PassengerDetails":[{"Name":"Tressa","Age":"45","Gender":"FEMALE","Title":"","SeatNumber":"L2","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"sherlyn","Age":"28","Gender":"FEMALE","Title":"","SeatNumber":"L1","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"Mary","Age":"48","Gender":"FEMALE","Title":"","SeatNumber":"L4","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"marilyn","Age":"17","Gender":"FEMALE","Title":"","SeatNumber":"L3","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null},{"Name":"angela","Age":"13","Gender":"FEMALE","Title":"","SeatNumber":"U","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null}],"EmailId":"sherlynrodricks.sr@gmail.com","MobileNo":"919920996064","Source":"Goa","Destination":"Mumbai","SourceId":"210","Discount":0,"DestinationId":"462","JourneyDate":"2017-10-31T20:30","TravelsName":" Neeta Travels (Laxmi Travellers)","BusType":"A/C Seater/Sleeper (2+1)","NoofSeats":"5","SeatNos":"L2,L1,L4,L3,U","TicketFare":{"currencyType":"INR","amount":5325},"ReportingTime":"2017-10-31T20:15","BPDetails":{"Id":1712347,"Location":"Mapusa,Inside Taxi Stand,","Address":"Inside Taxi Stand, Mapusa","Landmark":"Mapusa,Inside Taxi Stand,","ContactNo":"8652222816,8691033363","time":"08:30 PM","ReportingTime":"2017-10-31T20:15:00","LatLang":"15.589951,73.810197","DateTimeValue":"2017-10-31T20:30"},"DPDetails":{"Id":105412,"Location":"Malad-(E) pushpa park","Address":"Malad-[E], Near Pushpa Park, W.E.Express Highway","Landmark":"Malad-(E) pushpa park","ContactNo":"02228944040,02228952323,02228902666","time":"11:20 AM","ReportingTime":null,"LatLang":"19.188535,72.858397","DateTimeValue":"2017-11-01T11:20:00"},"Notes":null,"FirstBoardingTime":"2017-10-31T20:30","TicketStatus":"CONFIRMED","CancellationPolicy":"0:4:100:0;4:8:85:0;8:12:75:0;12:24:65:0;24:48:50:0;48:60:25:0;60:-1:10:0","RouteId":"9167404","OperatorId":"3620","IsMTicket":true,"tripId":"","AdviceTips":["Remember to carry water bottle.","Remember to carry blanket","Remember to fully charge your phone before journey. There is no charging facility on bus."],"TravelDuration":"14.50","Weather":null,"IsGPSEnabled":true,"YBServiceId":"25999","YBOperatorId":"NET","InventoryType":"","isCancellablePostJourney":false,"IsMimenabled":false,"driverDetails":null,"Country":"IND","PrimaryBoardingTime":"2017-10-31T19:00","BOContact":"8652222820","isOTGEnable":false,"vDepTime":"1140","IDType":null,"IDNumber":null,"TransactionCharge":75,"TransactionId":"12043208655406234","InsuranceCharges":0,"TotalAmountPaid":5325,"AmountReceived":5325,"SalesChannel":"WEBDIRECT","isPartialCancellationAllowed":"False","isPhoneBookingSpecial":"0","FareAdjustment":250,"FirstBoardingTimeInMin":1230,"DateOfIssue":"14/09/2017","Zcafe":null,"customerPriceBreakUp":[{"componentName":"BASIC_FARE","value":5000,"refundableValue":5000},{"componentName":"BUS_OPERATOR_GST","value":250,"refundableValue":250}],"bookingCustomerDetails":{"name":"Tressa","title":"","email":"sherlynrodricks.sr@gmail.com","mobileNo":"919920996064","rbUserId":-1}}');
                
       }
       
        if(req.getEndpoint().contains(mapAPIs.get('ForceCancelAPI')))
       {
          System.assertEquals('POST', req.getMethod());
          res.setBody('{"status":"SUCCESS","data":{"oldOperatorCancellationStatus":"OPERATOR_CANCELLATION_INITIATED","newOperatorCancellationStatus":"OPERATOR_CANCELLATION_FAILED","OrderItemUuid":"e2fbba5b61f1f005e2483f9f01020100"},"errors":[]}');
                
       }
       
     /*   if(req.getEndpoint().contains(mapAPIs.get('ExceptionalRefund')))
       {
          System.assertEquals('POST', req.getMethod());
          res.setBody('{"status":"SUCCESS","error_message":null,"error_code":null,"errors":[],"data":{"oldOperatorCancellationStatus":null,"newOperatorCancellationStatus":null,"OrderItemUuid":"b6c54a165f0bf005e2483f9f02020100"}}');
                
       }
       */
       
        if(req.getEndpoint().contains(mapAPIs.get('TicketCancellation')))
       {
          System.assertEquals('POST', req.getMethod());
          res.setBody('{"NewTicket":null,"Message":"OPERATOR_CANCELLATION_SUCCESS","Status":true,"RefundAmount":2831.0,"CancellationCharges":298.0,"IsRefundSuccess":true,"NeftRefundSupported":false,"OrderId":"12119726521442641","SalesChannel":"RB:MOBILEWEB#droidapp","BusinessUnit":"REDBUS_IN","Country":"IND","SelectedLanguage":"en"}');
                
       }
        if(req.getEndpoint().contains(mapAPIs.get('RefundBreakup')))
       {
          System.assertEquals('POST', req.getMethod());
          res.setBody('{"status":200,"errorMessage":null,"successMessage":"SUCCESS","response":{"status":"SUCCESS","errors":[],"data":[{"totalFare":102,"tin":"TM7417450783","seatWiseRefundables":[{"seatName":"F5","seatFare":100,"refundAmount":90,"cancellationCharge":10,"priceBreakUp":[{"value":100,"type":null,"refundableValue":90,"isCancellationPolicyApplicable":true,"componentName":"BASIC_FARE"}],"componentName":null}],"refundFor":"CANCELLATION","refundAmount":90,"otherRefundables":[{"value":2,"refundableValue":0,"componentName":"transactionCharge"}],"itemUuid":"769b12f86df7f005e2483f9f02020100","discount":0,"cancellationPercent":"10","cancellationCharges":10}]}}');
                
       }
       
       if(req.getEndpoint().contains(mapAPIs.get('MaxRefundableAPI')))
       {
          System.assertEquals('GET', req.getMethod());
          res.setBody('200');
                
       }
       
       if(req.getEndpoint().contains('api/Transaction/v3/CancelPolicy'))
       {
          System.assertEquals('GET', req.getMethod());
          res.setBody('{"cancelpolicy":[{"chargeAssociated":"Rs. 888.5","duration":"After 03:05 PM  on 1st Jun","RefundAmount":"Rs. 0.0","percentage":"100%"},{"chargeAssociated":"Rs. 355.4","duration":"Between 08:05 AM on 1st Jun - 03:05 PM on 1st Jun","RefundAmount":"Rs. 533.1","percentage":"40%"}],"zecafepolicy":"Free cancellation is not allowed for this Ticket","IsPartialCancellation":true}');
       }
       
       if(req.getEndpoint().contains('redbus.com/api/Ticket/v1/IsCancellable'))
       {
          System.assertEquals('POST', req.getMethod());
          res.setBody('{"Code":"400.56","Message":"Cancellation Failed","DetailedMessage":"Sorry! As per the policy of Pallavi Madhya Pradesh Parivahan Travels cancellation is not allowed after 03 Apr 03:40 (24 number of hours before primary boarding time). Please contact the bus operator at 0734-2512851,6264600374 directly for any further queries. Cancellation policy is completely controlled by bus operator"}');
       }
       
       if(req.getEndpoint().contains(mapAPIs.get('SinfinyCall')))
       {
           System.assertEquals('POST', req.getMethod());
          res.setBody('{ "status": true, "Message": "Call sent successfully!", "id": "c2c_5afbe64dd9cae811" }');
                
       }
     
      /* if(req.getEndpoint().contains('https://cmapi.redbus.com/api/User/v1/Generic'))  //  //mapAPIs.get('Generic_CMAPI')
       {
           //System.assertEquals('PUT', req.getMethod());
           //res.setBody('{"response":{"transaction_id":"","response_code":"1","status":"SUCCESS","agent_detail":{"campaign_name":"BusHire_Final","agent_id":"","agentstate":"FREE"},"reason":""}}');
           res.setBody('response:{"status":200}');     
       }*/
       
      //Added here
      if(req.getEndpoint().contains('capipp.redbus.com/api/ShortRoutesBus/v3/Routes/'))
       {
            System.assertEquals('POST', req.getMethod());
            res.setBody('response:{"status":200,"bpList":{"locationId": 66510,"locationName": "Andheri East","BpAddress": "Sir Mathuradas Vasanji Rd, Ajit Nagar, Bhim Nagar, Andheri East, Mumbai, Maharashtra 400059"},{"locationId": 66515,"locationName": "Bandra East","BpAddress": "Sir Mathuradas Vasanji Rd, Ajit Nagar, Bhim Nagar, Andheri East, Mumbai, Maharashtra 400059"}}');                

       }     
      if(req.getEndpoint().contains('capi.redbus.com/api/ShortRoutesBus/v3/ShortRoutesBpDp/'))
       {
            System.assertEquals('GET', req.getMethod());
            res.setBody('{"bpList": [{"locationId": 66510,"locationName": "Andheri East","BpAddress": "Andheri (E) -Hanuman Road Bus Stop","lat": 19.115491,"lon": 72.872695,"isPopular": false},{"locationId": 66515,"locationName": "Bandra East","BpAddress": "Bandra (E) Kalanagar Bridge","lat": 19.060533,"lon": 72.849348,"isPopular": false},{"locationId": 66545,"locationName": "Borivali East","BpAddress": "Borivali (E) - Purple Metrolink Office,National Park Bridge Ending","lat": 19.224061,"lon": 72.866647,"isPopular": false}]}');
       }       
       if(req.getEndpoint().contains('capi.redbus.com/api/Ticket/v1/Notification/'))
       {
          System.assertEquals('GET', req.getMethod());
          res.setBody('{"statusMessage": "Notification sent successfully","isEmailSent": true,"isSMSSent": true,"isWhatsAppSent": false,"emailRespId": null,"SMSRespId": null,"WhatsRespId": null,"Data": null}');
                
       }
      
         if(req.getEndpoint().contains(mapAPIs.get('SSBusCancellation')))
       {
          System.assertEquals('POST', req.getMethod());
          res.setBody('[{"tin":"D4UZ22Ymk5","responseCode":"200","responseMessage":"SUCCESS"}]');
                
       }
      
      if(req.getEndpoint().contains('/cmapi.redbus.com/api/Bus/v2/Cancel/update')){
            System.assertEquals('POST', req.getMethod());
            res.setBody('response:{"status":200}');                              
            System.assertEquals('POST', req.getMethod());
            res.setBody('response:{"status":400}');                              

      }
      
      
      // Added for coverage
      if(req.getEndpoint().contains('//cmapi.redbus.com/api/Transaction/v1/BPNumber/Insert')){
            System.assertEquals('POST', req.getMethod());
            res.setBody('response:{"status":200}');                              
      }

      if(req.getEndpoint().contains('/cmapi.redbus.com/api/Bus/v2/Cancel/Insert')){
            System.assertEquals('POST', req.getMethod());
            res.setBody('response:{"status":200}');                              
      }

      if(req.getEndpoint().contains('capi.redbus.com/api/Ticket/v1/') && !req.getEndpoint().contains('Notification') && !req.getEndpoint().contains('IsCancellable')){
          res.setBody('{"customerPriceBreakUp": [{"componentName": "BASIC_FARE","value": 728.0},{"componentName": "SERVICE_TAX","value": 36.0},{"componentName": "INSURANCE_CHARGES","value": 15.0}]}'); 
      }  
      if(req.getEndpoint().contains('reports.yourbus.in/ci/getDriverDetails')){
          res.setBody('{"status": true,"message": "success","data": {"operatorName":"Ramu Travels","vehicle": "NL01B1846","driverMobile": "9894163164","driverName": "MOHAN","driverMobile2": "","driverName2": "","helperMobile": "","helperName": ""}}');
      }  
      if(req.getEndpoint().contains('http://10.5.20.176:8000/v2/cancelOrder/')){
          res.setBody('{"status":"SUCCESS","errors":[],"data":{"zeroCancApplied":false,"status":"CANCELLATION_COMPLET","serviceProviderId":"123456","refundAmount":{"currencyType":"PEN","amount":1100.0},"pnr":"TestPNR123","orderItemRefNumber":"PEP9J82414444","orderItemId":12783279536210433,"operatorCancellationStatus":"OPERATOR_CANCELLATION_SUCCESS","cnr":"test12345678","clientIp":"","cancellationCharges":{"currencyType":"PEN","amount":0.0},"backToSource":true}}');
 
      }	
      System.debug('Mock response..'+res);  
      
      //Added for AutoresponseForcancelRescheudule
      if(req.getEndpoint().contains('https://capi.redbus.com/api/Bus/v1/GetCancelPolicyForTicket')){
		System.assertEquals('GET', req.getMethod());
          res.setBody('{ "status":200, "Message": "Call sent successfully!", "id": "c2c_5afbe64dd9cae811" }');
                                       
      }
      if(req.getEndpoint().contains('https://capi.redbus.com/api/Ticket/v2/IsCancellable')){
		System.assertEquals('POST', req.getMethod());
		res.setBody('{ "status": "OK","toCityName":"","fromCityName":"","dateOfJourney":"","travelsName":"","busType":"","boardingTime":"","arrivalTime":"","boardingPoint":"","duration":"","paymentMode":"","cardNumber":"","cardType":"","totalAmountPaid":"398.0","insuranceCharges":"","serviceTax":"","GST":"","cashCouponValue":0}'); 
      }
      //added for addonlistview
      
      if(req.getEndpoint().contains('https://capipp.redbus.com/api/Ticket/v1/IsCancellable')){
		System.assertEquals('POST', req.getMethod());
          res.setBody('{"status": "OK","addons":[{"totalFare":398,"refundableAmount":398,"itemUuid":"0ad1d9b29619f0055722993402020101","itemType":"ACTIVITY","itemName":"NA","currency":"INR","isAddOnCancellable":true,"errorMsg":null}]}') ;
      }
      if(req.getEndpoint().contains('https://capipp.redbus.com/api/Ticket/v1/Cancel')){
		System.assertEquals('POST', req.getMethod());
          res.setBody('{"status": "OK","RefundAmount":99.99,"CancellationCharges":0.0}') ;
      }
      if(req.getEndpoint().contains('https://bhapi.redbus.in/v1/notification/customer/rating')){
		System.assertEquals('GET', req.getMethod());
		res.setBody('200');
      }
      if(req.getEndpoint().contains('https://bhapi.redbus.in/v1/notification/operator/quote/whatsapp')){
		System.assertEquals('GET', req.getMethod());
		 res.setBody('{"Error": "DOJ_PASSED","Response": null,"Status": {"StatusCode": 200,"StatusMsg": "OK" }}');
      }
      
    return res;
   }
}