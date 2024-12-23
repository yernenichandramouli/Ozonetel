@isTest
public class SafetyImageApprovalControllerTest{
    
    public static testMethod void TestImageApproval()
    {
        Test.startTest();
        SafetyImageApprovalController s=new SafetyImageApprovalController ();
        string json='[{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        date dt=system.today();
        SafetyImageApprovalController.getAllTransactions(dt);
        Test.stopTest();
     }
     public static testMethod void TestImageApproval2()
    {
        Test.startTest();
        SafetyImageApprovalController s=new SafetyImageApprovalController ();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        SafetyImageApprovalController.GetImages('UUID');
        Test.stopTest();
     }
     public static testMethod void TestImageApproval3()
    {
        Test.startTest();
        SafetyImageApprovalController s=new SafetyImageApprovalController ();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        SafetyImageApprovalController.updatestatus('Status');
        Test.stopTest();
     }
}