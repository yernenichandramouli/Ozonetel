@isTest
private class ReRatingLinkForProjectBoltCasesCtrlTest {
    @isTest static void testRefundMethod(){
        Service_Provider__c sp=new Service_Provider__c();
        sp.Location__c='Karnataka';
        sp.Operator_Id__c='3538';
        insert sp;

        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.Service_Provider_Id__c='3538';
        orIt.Service_Provider_Info__c=sp.id;
        orIt.business_unit__c = 'REDBUS_IN';
        insert orIt;

        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Closed';
        cs.Case_Category__c='Instant resolution-BOLT';
        cs.isReratingLink_Sent__c=false;
        cs.Refund_Type__c='Instant resolution with refund';
        insert cs;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        string query='';
        ReRatingLinkForProjectBoltCasesScheduler  busCan= new ReRatingLinkForProjectBoltCasesScheduler();
        String sch = '0 0 8 13 2 ?';
        system.schedule('AgeingRefund', sch,busCan);
        Test.stopTest();
    }
}