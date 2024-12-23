@isTest
public class CancellationPolicyCntrlTest {
    
    @isTest
    static void testFetchCanclPolicyDetails() {
        // Create test data
        Order_Items__c testOrderItem = new Order_Items__c(
            Business_Unit__c = 'REDBUS_COM',
            Guid__c = 'testGuid',
            Amount_Recieved_Currency__c = 'USD'
        );
        insert testOrderItem;

        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String json2='{"ReschedulePolicyMsg":"Policy is Available"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json2));
        
        // Set the current page parameters
        Test.setCurrentPageReference(new PageReference('/apex/testPage'));
        ApexPages.currentPage().getParameters().put('id', testOrderItem.Id);
        ApexPages.currentPage().getParameters().put('guId', testOrderItem.Guid__c);
        ApexPages.currentPage().getParameters().put('busnsUnit', testOrderItem.Business_Unit__c);

        // Call the method to be tested
        Test.startTest();
        CancellationPolicyCntrl.recId=testOrderItem.id;
        CancellationPolicyCntrl.fetchCanclPolicyDetails();
        Test.stopTest();

    }

    @isTest
    static void testIsCancellable() {
        // Create test data
        Order_Items__c testOrderItem = new Order_Items__c(
             Business_Unit__c = 'REDBUS_COM',
             Guid__c = 'testGuid',
            Amount_Recieved_Currency__c = 'USD'
        );
        insert testOrderItem;

        CancellationPolicyCntrl.CancellationPolicyResponse cp = new CancellationPolicyCntrl.CancellationPolicyResponse();
        CancellationPolicyCntrl.Cancelpolicylist listcp = new CancellationPolicyCntrl.Cancelpolicylist();
        
         listcp.Charges='567';
        listcp.CurrentSlot=false;
        listcp.Percentage='567';
        listcp.Duration='567';
        listcp.ZCafepercent='test';
        listcp.ZCafeCharge='0';
        listcp.RefundableAmount='10';
        listcp.ChargeAssociated='t344';
        listcp.IsZCafeApplicable=false;
        cp.IsPartialCancellationAllowed=false;
        cp.IsZcafeApplied=false;
        cp.ZcafeSponsoredByRedbus=false;
        cp.BookedViaTcp=false;
        cp.ZcafePolicy='456';
        cp.ZcafeDuration=23456;
        
        // Set up mock HTTP response
        String json='';
        String json2='{"ReschedulePolicyMsg":"Policy is Available"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json2));
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        PageReference pageRef = Page.CancellationPolicyPage;
        Test.setCurrentPage(pageRef);


        // Instantiate the controller with a StandardController instance
         ApexPages.StandardController stdController = new ApexPages.StandardController(testOrderItem);
         CancellationPolicyCntrl controller = new  CancellationPolicyCntrl(stdController);

        Test.startTest();
                CancellationPolicyCntrl.recId=testOrderItem.id;
        CancellationPolicyCntrl.IsCancellable();
        Test.stopTest();

    }
    
      @isTest
    static void testIsCancellableFail() {
        // Create test data
        Order_Items__c testOrderItem = new Order_Items__c(
             Business_Unit__c = 'REDBUS_IND',
             Guid__c = 'testGuid',
            Amount_Recieved_Currency__c = 'INR'
        );
        insert testOrderItem;

        // Set up mock HTTP response
        String json='';
        String json2='{"ReschedulePolicyMsg":"Policy is Available"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json2));
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        PageReference pageRef = Page.CancellationPolicyPage;
        Test.setCurrentPage(pageRef);


        // Instantiate the controller with a StandardController instance
         ApexPages.StandardController stdController = new ApexPages.StandardController(testOrderItem);
         CancellationPolicyCntrl controller = new  CancellationPolicyCntrl(stdController);

        Test.startTest();
                CancellationPolicyCntrl.recId=testOrderItem.id;
        CancellationPolicyCntrl.IsCancellable();
        Test.stopTest();

    }

    // Mock HTTP callout response generator class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"cancelpolicylist":[{"RefundableAmount":"10","chargeAssociated":"No","duration":"2","percentage":"20","ZCafepercent":"30","ZCafeCharge":"15","isZCafeApplicable":true,"currentSlot":true,"charges":"20"}],"isPartialCancellationAllowed":true,"isZcafeApplied":true,"zcafeDuration":2,"zcafeSponsoredByrighBUS":true,"zcafePolicy":"Test policy","bookedViaTCP":true}');
            res.setStatusCode(200);
            return res;
        }
    }
}