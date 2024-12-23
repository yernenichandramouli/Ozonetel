@isTest
public class sendSgmyBoardingPassCtrlTest {
    @isTest static void successTestMethod(){

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Payment_Currency__c ='MYR';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Business_Unit__c = 'REDBUS_MY';
        orIt.Bpass_Status__c ='CONFIRMED';
        orIt.Bus_Pass_Vendor_Status__c = 'SUCCESS';
        insert orIt;

        Test.startTest();
        string json='{"boardingPassGenerated":true,"emailSent":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        sendSgmyBoardingPassCtrl.invokeBpardingPassApi(orIt.Id,'test@gmail.com');
        Test.stopTest();
    }

    @isTest static void successSGPTestMethod(){

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Payment_Currency__c ='SGD';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Business_Unit__c = 'REDBUS_SG';
        insert orIt;

        Test.startTest();
        string json='{"boardingPassGenerated":true,"emailSent":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        sendSgmyBoardingPassCtrl.invokeBpardingPassApi(orIt.Id,'test@gmail.com');
        Test.stopTest();
    }

    @isTest static void failureTestMethod(){

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Payment_Currency__c ='MYR';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Business_Unit__c = 'REDBUS_MY';
        insert orIt;

        Test.startTest();
        string json='{"boardingPassGenerated":true,"emailSent":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'BAD', json));
        sendSgmyBoardingPassCtrl.invokeBpardingPassApi(orIt.Id,'test@gmail.com');
        Test.stopTest();
    }

    @isTest static void bpPendingTestMethod(){

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Payment_Currency__c ='MYR';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Business_Unit__c = 'REDBUS_MY';
        orIt.Bpass_Status__c ='CONFIRMED';
        orIt.Bus_Pass_Vendor_Status__c = 'PENDING';
        insert orIt;

        Test.startTest();
        string json='{"boardingPassGenerated":true,"emailSent":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'BAD', json));
        sendSgmyBoardingPassCtrl.invokeBpardingPassApi(orIt.Id,'test@gmail.com');
        Test.stopTest();
    }

    @isTest static void bpFailedTestMethod(){

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Payment_Currency__c ='MYR';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Business_Unit__c = 'REDBUS_MY';
        orIt.Bpass_Status__c ='CONFIRMED';
        orIt.Bus_Pass_Vendor_Status__c = 'FAILED';
        insert orIt;

        Test.startTest();
        string json='{"boardingPassGenerated":true,"emailSent":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'BAD', json));
        sendSgmyBoardingPassCtrl.invokeBpardingPassApi(orIt.Id,'test@gmail.com');
        Test.stopTest();
    }

    @isTest static void failureResponseTestMethod(){

        Order_Items__c  orIt= new Order_Items__c();
        orIt.Payment_Currency__c ='MYR';
        orIt.Order_Item_Reference_No__c = 'TIN6473553';
        orIt.Business_Unit__c = 'REDBUS_MY';
        orIt.Bpass_Status__c ='CONFIRMED';
        orIt.Bus_Pass_Vendor_Status__c = 'SUCCESS';
        insert orIt;

        Test.startTest();
        string json='{"boardingPassGenerated":true,"emailSent":true}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(400, 'BAD', json));
        sendSgmyBoardingPassCtrl.invokeBpardingPassApi(orIt.Id,'test@gmail.com');
        Test.stopTest();
    }
}