@isTest
public class ActivityDetailsTest
{
 @testsetup
    static void createOrder(){
Activities__c a=new Activities__c();
a.name='Test1234';
a.Activity_uuid__c ='testuuid123';
insert a;        
        }
public static testMethod void TestActivity()
    {
        Test.startTest();
Activities__c aObj=new Activities__c();
aObj=[select id,name,Activity_uuid__c from Activities__c limit 1];
 ApexPages.StandardController sc = new ApexPages.StandardController(aObj);
       ActivityDetails actObj = new ActivityDetails(sc);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
ActivityDetails.getActivityDetails(aObj.Activity_uuid__c);

Test.stopTest();
}

public static testMethod void TestAddon()
    {
        Test.startTest();
Activities__c aObj=new Activities__c();
aObj=[select id,name,Activity_uuid__c from Activities__c limit 1];
 ApexPages.StandardController sc = new ApexPages.StandardController(aObj);
       ActivityDetails actObj = new ActivityDetails(sc);
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
ActivityDetails.getActivityAddOnDetails(aObj.Activity_uuid__c);

Test.stopTest();
}

}