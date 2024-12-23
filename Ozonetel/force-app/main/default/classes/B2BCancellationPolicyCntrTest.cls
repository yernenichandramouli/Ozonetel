/**
 * (c) 2017 RedBus
 *
 * Name           : B2BCancellationPolicyCntrTest
 * Created Date   : 16 Aug 2019
 * Created By     : Mahendra k
 * Purpose        : Test class for B2BCancellationPolicyCntr class
 *
 **/
 
@isTest
public class B2BCancellationPolicyCntrTest{

  static testMethod void testcanclPolicy()
    {
    Order_Items__c  orIt= new Order_Items__c();
    orIt.Primary_Boarding_Point_Time__c =system.today();
    orIt.Seatadditionaldetails__c='[{"fare":"4.23","ladiesSeat":"true","malesSeat":"false","operatorServiceCharge":"0.00","seatName":"11","serviceTax":"4.00","status":"Booked","refundAmount":null,"passenger":{"address":null,"age":"43","email":"nilika.haldar@redbus.com","gender":"MALE","mobile":"8884580492","name":"test","primary":"true","singleLadies":"false","title":"Mr"}},{"fare":"4.23","ladiesSeat":"false","malesSeat":"false","operatorServiceCharge":"0.00","seatName":"12","serviceTax":"3.00","status":"Cancelled","refundAmount":"18.0","passenger":{"address":"Hyderabad","age":"23","email":"nilllikka.haldar@redbus.com","gender":"MALE","mobile":"9502105715","name":"testa","primary":"true","singleLadies":"true","title":"Mrr"}}]';
    orIt.Cancellation_Policy__c = '0:12:100:0;12:-1:10:0';
    orIt.First_Boarding_Point_Time__c=System.now();
    insert orIt;
    Test.startTest();
    B2BCancellationPolicyCntr cancl = new B2BCancellationPolicyCntr(new ApexPages.StandardController(orIt));
    cancl.fetchCanclPolicyDetails();
    B2BCancellationPolicyCntr.InventoryWrapper inv=new B2BCancellationPolicyCntr.InventoryWrapper();
    inv.fare='23';
    inv.ladiesSeat='1';
    inv.malesSeat='1';
    inv.operatorServiceCharge='1';
    inv.serviceTax='1';
    inv.seatName='1';
    inv.ladiesSeat ='1';
    inv.status ='open';
    inv.refundAmount='123';
    B2BCancellationPolicyCntr.passenger ps = new B2BCancellationPolicyCntr.passenger ();
    ps.age='12';
    ps.email ='test@gmail.com';
    ps.gender ='male';
    ps.idType ='12112';
    ps.mobile ='123456778';
    ps.name ='test';
    ps.primary ='test';
    ps.singleLadies ='12';
    ps.title ='12';
    Test.stopTest();
    }
    
    static testMethod void testcanclPolicyerror()
    {
    Order_Items__c  orIt= new Order_Items__c();
    orIt.Primary_Boarding_Point_Time__c =system.today();
    orIt.Seatadditionaldetails__c='[{"fare":"4.23","ladiesSeat":"true","malesSeat":"false","operatorServiceCharge":"0.00","seatName":"11","serviceTax":"4.00","status":"Booked","refundAmount":null,"passenger":{"address":null,"age":"43","email":"nilika.haldar@redbus.com","gender":"MALE","mobile":"8884580492","name":"test","primary":"true","singleLadies":"false","title":"Mr"}},{"fare":"4.23","ladiesSeat":"false","malesSeat":"false","operatorServiceCharge":"0.00","seatName":"12","serviceTax":"3.00","status":"Cancelled","refundAmount":"18.0","passenger":{"address":"Hyderabad","age":"23","email":"nilllikka.haldar@redbus.com","gender":"MALE","mobile":"9502105715","name":"testa","primary":"true","singleLadies":"true","title":"Mrr"}}]';
    orIt.Cancellation_Policy__c = '0:-1:-1:-1;';
    orIt.Service_Start_Time__c=System.now();
    insert orIt;
    Test.startTest();
    B2BCancellationPolicyCntr cancl1 = new B2BCancellationPolicyCntr(new ApexPages.StandardController(orIt));
    cancl1.fetchCanclPolicyDetails();
    Test.stopTest();
    }

    static testMethod void railsTravelInfoTest()
    {
    Order_Items__c  orIt= new Order_Items__c();
    orIt.Primary_Boarding_Point_Time__c =system.today();
    orIt.Traveller_Details__c='[{"name":"1","isPartiallyCancellable":false,"customerPriceBreakUp":[],"custInfo":null,"VendorStatus":null,"QRBarCode":null,"travellerDetails":{"title":"Ms.","seniorCitizenApplicable":false,"passengerICardFlag":false,"nationality":"IN","name":"Nilika","gender":"F","foodPreference":"NA","berthPreference":"NA","age":22},"passengerNetFare":145.0,"currentSeatDetails":{"currentStatusIndex":1,"currentStatus":"CNF","currentCoachId":"S3","currentBerthNo":"34","currentBerthCode":"MB","currentBerthChoice":"NC"},"bookingSeatDetails":{"bookingStatusIndex":1,"bookingStatus":"CNF","bookingCoachId":"S3","bookingBerthNo":"34","bookingBerthCode":"MB","bookingBerthChoice":"NC"}},{"name":"2","isPartiallyCancellable":false,"customerPriceBreakUp":[],"custInfo":null,"VendorStatus":null,"QRBarCode":null,"travellerDetails":{"title":"Mr.","seniorCitizenApplicable":false,"passengerICardFlag":false,"nationality":"IN","name":"nilika sf","gender":"M","foodPreference":"NA","berthPreference":"NA","age":33},"passengerNetFare":145.0,"currentSeatDetails":{"currentStatusIndex":1,"currentStatus":"CNF","currentCoachId":"S3","currentBerthNo":"35","currentBerthCode":"UB","currentBerthChoice":"NC"},"bookingSeatDetails":{"bookingStatusIndex":1,"bookingStatus":"CNF","bookingCoachId":"S3","bookingBerthNo":"35","bookingBerthCode":"UB","bookingBerthChoice":"NC"}},{"name":"3","isPartiallyCancellable":false,"customerPriceBreakUp":[],"custInfo":null,"VendorStatus":null,"QRBarCode":null,"travellerDetails":{"title":"Ms.","seniorCitizenApplicable":false,"passengerICardFlag":false,"nationality":"IN","name":"sf nilika","gender":"F","foodPreference":"NA","berthPreference":"NA","age":44},"passengerNetFare":145.0,"currentSeatDetails":{"currentStatusIndex":1,"currentStatus":"CNF","currentCoachId":"S3","currentBerthNo":"37","currentBerthCode":"MB","currentBerthChoice":"NC"},"bookingSeatDetails":{"bookingStatusIndex":1,"bookingStatus":"CNF","bookingCoachId":"S3","bookingBerthNo":"37","bookingBerthCode":"MB","bookingBerthChoice":"NC"}},{"name":"4","isPartiallyCancellable":false,"customerPriceBreakUp":[],"custInfo":null,"VendorStatus":null,"QRBarCode":null,"travellerDetails":{"title":"Ms.","seniorCitizenApplicable":false,"passengerICardFlag":false,"nationality":"IN","name":"nilika one","gender":"F","foodPreference":"NA","berthPreference":"NA","age":25},"passengerNetFare":145.0,"currentSeatDetails":{"currentStatusIndex":1,"currentStatus":"CNF","currentCoachId":"S3","currentBerthNo":"38","currentBerthCode":"UB","currentBerthChoice":"NC"},"bookingSeatDetails":{"bookingStatusIndex":1,"bookingStatus":"CNF","bookingCoachId":"S3","bookingBerthNo":"38","bookingBerthCode":"UB","bookingBerthChoice":"NC"}},{"name":"5","isPartiallyCancellable":false,"customerPriceBreakUp":[],"custInfo":null,"VendorStatus":null,"QRBarCode":null,"travellerDetails":{"title":"Mr.","seniorCitizenApplicable":false,"passengerICardFlag":false,"nationality":"IN","name":"nilika h","gender":"M","foodPreference":"NA","berthPreference":"LB","age":33},"passengerNetFare":145.0,"currentSeatDetails":{"currentStatusIndex":1,"currentStatus":"CNF","currentCoachId":"S3","currentBerthNo":"40","currentBerthCode":"SU","currentBerthChoice":"LB"},"bookingSeatDetails":{"bookingStatusIndex":1,"bookingStatus":"CNF","bookingCoachId":"S3","bookingBerthNo":"40","bookingBerthCode":"SU","bookingBerthChoice":"LB"}}]';
    orIt.Cancellation_Policy__c = '0:-1:-1:-1;';
    orIt.Service_Start_Time__c=System.now();
    orIt.Item_Type__c='RAILS';
    insert orIt;
    B2BCancellationPolicyCntr.travellerDetails travellerDetailswrapper= new B2BCancellationPolicyCntr.travellerDetails();
    travellerDetailswrapper.title='Test';
    travellerDetailswrapper.seniorCitizenApplicable='Test';
    travellerDetailswrapper.passengerICardFlag='Test';
    travellerDetailswrapper.nationality='Test';
    travellerDetailswrapper.name='Test';
    travellerDetailswrapper.gender='Test';
    travellerDetailswrapper.foodPreference='Test';
    travellerDetailswrapper.berthPreference='Test';
    travellerDetailswrapper.age='Test';
    B2BCancellationPolicyCntr.bookingSeatDetails bookingSeatDetailswrapper= new B2BCancellationPolicyCntr.bookingSeatDetails();
    bookingSeatDetailswrapper.bookingStatusIndex='Test';
    bookingSeatDetailswrapper.bookingStatus='Test';
    bookingSeatDetailswrapper.bookingCoachId='Test';
    bookingSeatDetailswrapper.bookingBerthNo='Test';
    bookingSeatDetailswrapper.bookingBerthCode='Test';
    bookingSeatDetailswrapper.bookingBerthChoice='Test';
    B2BCancellationPolicyCntr.currentSeatDetails currentSeatDetailswrapper= new B2BCancellationPolicyCntr.currentSeatDetails();
    currentSeatDetailswrapper.currentStatusIndex='Test';
    currentSeatDetailswrapper.currentStatus='Test';
    currentSeatDetailswrapper.currentCoachId='Test';
    currentSeatDetailswrapper.currentBerthNo='Test';
    currentSeatDetailswrapper.currentBerthCode='Test';
    currentSeatDetailswrapper.currentBerthChoice='Test';
    B2BCancellationPolicyCntr.railsWrapper finalwrapper= new B2BCancellationPolicyCntr.railsWrapper();
    finalwrapper.passengerNetFare='Test';
    finalwrapper.travellerDetails=travellerDetailswrapper;
    finalwrapper.currentSeatDetails=currentSeatDetailswrapper;
    finalwrapper.bookingSeatDetails=bookingSeatDetailswrapper;
    Test.startTest();
    B2BCancellationPolicyCntr cancl1 = new B2BCancellationPolicyCntr(new ApexPages.StandardController(orIt));
    cancl1.fetchCanclPolicyDetails();
    Test.stopTest();
    }
}