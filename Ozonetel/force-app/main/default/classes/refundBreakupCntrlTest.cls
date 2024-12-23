/**
 * (c) 2018 RedBus
 *
 * Name           : refundBreakupCntrl
 * Created Date   : 18 jul 2018
 * Created By     : Mahendra K
 * Purpose        : Controller class for Refundbreakup  Page mahendra reddyy12345
 *
 **/
 
 @isTest
Public class refundBreakupCntrlTest
{
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
  test.startTest();
     Test.setMock(HttpCalloutMock.class, new MockResponseCallout ());
     Apexpages.currentpage().getparameters().put('Id',orIt.id);
    
        refundBreakupCntrl rfnd =new refundBreakupCntrl();
         rfnd.travelTime=12;
        rfnd.refund();
       
     refundBreakupCntrl.PriceBreakUp prcbk = new refundBreakupCntrl.PriceBreakUp();
         prcbk.value=87;
         prcbk.type='TEST';
         prcbk.refundableValue=87;
         prcbk.isCancellationPolicyApplicable=TRUE;
         prcbk.componentName='TEST';
         
     refundBreakupCntrl.SeatWiseRefundable serf = new  refundBreakupCntrl.SeatWiseRefundable();
          serf.seatName='test';
          serf.seatFare=342;
          serf.refundAmount=232;
          serf.cancellationCharge=230;
          List<refundBreakupCntrl.SeatWiseRefundable> seatrf = new List<refundBreakupCntrl.SeatWiseRefundable>();
          seatrf.add(serf);
     refundBreakupCntrl.OtherRefundable otrfnd = new refundBreakupCntrl.OtherRefundable ();
       otrfnd.value=23;
       otrfnd.refundableValue=789;
       otrfnd.componentName='test';
        list<refundBreakupCntrl.OtherRefundable> otherrf = new list<refundBreakupCntrl.OtherRefundable>();
        otherrf.add(otrfnd);
     refundBreakupCntrl.Datum dt = new refundBreakupCntrl.Datum();
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
        list<refundBreakupCntrl.Datum> datt =new  list<refundBreakupCntrl.Datum>();
        datt.add(dt);
    refundBreakupCntrl.Response rb = new refundBreakupCntrl.Response();
         rb.Status='process';
         rb.data=datt;
    refundBreakupCntrl.RootObject rbj = new refundBreakupCntrl.RootObject();
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
     refundBreakupCntrl rfnddd =new refundBreakupCntrl();
    rfnddd.refund();
     test.stopTest();
  
      
  }
}