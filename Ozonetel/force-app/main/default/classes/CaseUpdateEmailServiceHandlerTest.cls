@isTest
private class CaseUpdateEmailServiceHandlerTest {
    
    @isTest
    static void testHandleInboundEmail() {
    
        // Create a test inbound email
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        // Set email properties (to, cc, subject, body, etc.) for testing
      email.subject = 'First Email - caseNumber:23097433';
      email.fromAddress = 'someaddress@email.com';
      email.plainTextBody = 'email body\n2225256325\nTitle';
      email.fromName = 'Test Candidate';
      email.toAddresses = new List<String>{'test@example.com'};  
      email.ccAddresses = new List<String>{'cc@example.com'}; // Set the ccAddresses for testing
    
        // Create a test inbound envelope
         Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'user@acme.com';
        
        // Create a test instance of the handler
        caseUpdateEmailServiceHandler handler = new caseUpdateEmailServiceHandler();
         handler.handleInboundEmail(email, env);
        // Start the test
        Test.startTest();

        // Call the handleInboundEmail method
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        // Perform assertions based on the expected behavior of your code
        // Add more assertions as needed

        // End the test
        Test.stopTest();
    }
}