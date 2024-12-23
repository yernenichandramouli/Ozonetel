/**
 * (c) 2018 RedBus
 *
 * Name           : LtngRefundBreakupCntrlTest
 * Created Date   : 30 jun 2020
 * Created By     : Saikrupa
 * Purpose        : Controller class for Lightning Refundbreakup  Page 
 **/
@isTest
public class LtngRefundBreakupCntrlTest {
   static testMethod void refundresponesetest()
  {
 List<Order_Items__c> listOrItems = new List<Order_Items__c>();
    Order_Items__c orIt = new Order_Items__c();
    orIt.Order_Item_Reference_No__c = '';
    orIt.Email__c = 'Test@redbus.com';
    orIt.Business_Unit__c  = 'REDBUS_IN';
    orIt.Name= 'a0C5D000001EoqLUAS';
    orIt.Primary_Boarding_Point_Time__c= Date.parse('12/08/2018');
    orIt.Cancellation_Time__c=Date.parse('12/08/2018');
    insert orIt;
    Refund_Order_Items__c  RoI = new Refund_Order_Items__c();
    roi.Order_Item_Name__c=orIt.Id;
    insert roi;
  test.startTest();
     Test.setMock(HttpCalloutMock.class, new MockResponseCallout ());
     Apexpages.currentpage().getparameters().put('Id',orIt.id);
    
        LtngRefundBreakupCntrl rfnd =new LtngRefundBreakupCntrl();
         rfnd.travelTime=12;
        rfnd.refund();
       
     LtngRefundBreakupCntrl.PriceBreakUp prcbk = new LtngRefundBreakupCntrl.PriceBreakUp();
         prcbk.value=87;
         prcbk.type='TEST';
         prcbk.refundableValue=87;
         prcbk.isCancellationPolicyApplicable=TRUE;
         prcbk.componentName='TEST';
         
     LtngRefundBreakupCntrl.SeatWiseRefundable serf = new  LtngRefundBreakupCntrl.SeatWiseRefundable();
          serf.seatName='test';
          serf.seatFare=342;
          serf.refundAmount=232;
          serf.cancellationCharge=230;
          List<LtngRefundBreakupCntrl.SeatWiseRefundable> seatrf = new List<LtngRefundBreakupCntrl.SeatWiseRefundable>();
          seatrf.add(serf);
     LtngRefundBreakupCntrl.OtherRefundable otrfnd = new LtngRefundBreakupCntrl.OtherRefundable ();
       otrfnd.value=23;
       otrfnd.refundableValue=789;
       otrfnd.componentName='test';
        list<LtngRefundBreakupCntrl.OtherRefundable> otherrf = new list<LtngRefundBreakupCntrl.OtherRefundable>();
        otherrf.add(otrfnd);
     LtngRefundBreakupCntrl.Datum dt = new LtngRefundBreakupCntrl.Datum();
        dt.totalFare=234;
        dt.tin='5467980';
        dt.refundFor='cancel';
        dt.refundAmount=4356;
        dt.itemUuid='5467980';
        dt.discount=546;
        dt.cancellationPercent='5467980';
        dt.cancellationCharges=546;
        dt.otherRefundables=otherrf;
        dt.seatWiseRefundables=seatrf;
        list<LtngRefundBreakupCntrl.Datum> datt =new  list<LtngRefundBreakupCntrl.Datum>();
        datt.add(dt);
    LtngRefundBreakupCntrl.Response rb = new LtngRefundBreakupCntrl.Response();
         rb.Status='process';
         rb.data=datt;
    LtngRefundBreakupCntrl.RootObject rbj = new LtngRefundBreakupCntrl.RootObject();
         rbj.Status= 1234;
         rbj.successMessage='text';
         rbj.response=rb;
         rbj.errorMessage ='text';
         
  test.stopTest();
  }
    static testMethod void noresponsetest(){
        //List<Order_Items__c> listOrItems = new List<Order_Items__c>();
    Order_Items__c orItts = new Order_Items__c();
    orItts.Order_Item_Reference_No__c = '';
    orItts.Email__c = 'Test@redbus.com';
    orItts.Business_Unit__c  = 'REDBUS_IN';
    orItts.Name= 'a0C5D000001EoqLUAS';
    orItts.Primary_Boarding_Point_Time__c= Date.parse('12/08/18');
    orItts.Cancellation_Time__c=Date.parse('12/08/2018');
    
    insert orItts;
     test.startTest();
    Apexpages.currentpage().getparameters().put('Id',orItts.id);
    string jsonBody='{"status":404,"errorMessage":"Tin Not Found","successMessage":"ERROR","response":[]}';
    Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'OK', jsonBody));
     LtngRefundBreakupCntrl rfnddd =new LtngRefundBreakupCntrl();
    rfnddd.refund();
     test.stopTest();
  
      
  }

}