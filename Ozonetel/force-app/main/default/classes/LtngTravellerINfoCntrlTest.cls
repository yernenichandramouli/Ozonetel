/**
* (c) 2017 RedBus
*
* Name           : LtngTravellerInfoCntrlTest
* Created Date   : 30 Jun 2020
* Created By     : Saikrup
* Purpose        : Test class for lTNGTravellerInfoCntrl
*
**/

@isTest    
public class LtngTravellerINfoCntrlTest {
    @isTest static void fetTravelInforTest(){
        
        OrderItemTransactionResource__c oritran = new OrderItemTransactionResource__c();
        oritran.Case_Country__c='peru';
        oritran.Name = 'REDBUS_SG';
        oritran.Auth_Key__c = 'SGP';
        oritran.Channel_Name__c = 'MOBILE_APP';
        oritran.Case_Business_Type__c='REDBUS_SG';
        oritran.Default_Currency__c='SGD';
        insert oritran;
        
        Order_Items__c oi = new Order_Items__c();
        oi.Order_Item_Reference_No__c = '123456';
        oi.Business_Unit__c=oritran.Case_Business_Type__c;
        insert oi;
        
        Test.StartTest(); 
        PageReference pageRef = Page.LtngTravellerINfo; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(oi.Id));
        Test.setCurrentPage(pageRef);

        String endPoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='TicketDetails'].Endpoint__c;
        LtngTravellerInfoCntrl cntrl=new LtngTravellerInfoCntrl();
        LtngTravellerInfoCntrl.emialId='test@gmail.com';
        LtngTravellerInfoCntrl.phoneNo='09876543';
        LtngTravellerInfoCntrl.TravellerWarpper wrps = new LtngTravellerInfoCntrl.TravellerWarpper();
        String jsondata ='{"ticketsInfo":[{"TicketNo":"TTAH89984690","PassengerDetails":[{"Name":"test two","Age":"33","Gender":"FEMALE","GenderAcronym":"F","Title":"","SeatNumber":"L2","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null,"PassportExpiry":null,"isPartiallyCancellable":false,"customerPriceBreakUp":[{"componentName":"BASIC_FARE","value":160,"refundableValue":160},{"componentName":"SERVICE_TAX","value":8,"refundableValue":8}]},{"Name":"test one","Age":"22","Gender":"MALE","GenderAcronym":"M","Title":"","SeatNumber":"L1","pnr":null,"Nationality":null,"DOB":null,"IdProofType":null,"ProofId":null,"PassportExpiry":null,"isPartiallyCancellable":false,"customerPriceBreakUp":[{"componentName":"BASIC_FARE","value":160,"refundableValue":160},{"componentName":"SERVICE_TAX","value":8,"refundableValue":8}]}],"EmailId":"nilika.haldar@redbus.com","MobileNo":"918884580492"}]}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsondata));
        LtngTravellerInfoCntrl.getPassangerDetails();
        Test.StopTest();
    }
}