@isTest
public class BusHireSendFeedbackEmailTest {
    Static testMethod void methodtoTest(){
        lead ld = new lead();
        ld.TCodeHash__c='test';
        ld.LastName='test';
        insert ld;
        ApexPages.StandardController con = new ApexPages.StandardController(ld);
        BusHireSendFeedbackEmail cls = new BusHireSendFeedbackEmail(con);
        BusHireSendFeedbackEmail.sendFeedbackEmail(ld.id);
        ld.status='Converted';
        update ld;
        Test.setMock(HttpCalloutMock.class, new MockResponsecallout());
        test.startTest();
        BusHireSendFeedbackEmail.sendFeedbackEmail(ld.id);
		ld.status='New';
        update ld;
        test.stopTest();
        BusHireSendFeedbackEmail.sendWhatsappMessage(ld.id);
    }
    Static testMethod void methodtoTest2(){
        lead ld = new lead();
        ld.TCodeHash__c='test';
        ld.LastName='test';
        insert ld;
        ApexPages.StandardController con = new ApexPages.StandardController(ld);
        BusHireSendFeedbackEmail cls = new BusHireSendFeedbackEmail(con);
        BusHireSendFeedbackEmail.sendFeedbackEmail(ld.id);
        ld.status='Converted';
        update ld;
        Test.setMock(HttpCalloutMock.class, new MockResponsecallout());
        test.startTest();
        BusHireSendFeedbackEmail.sendWhatsappMessage(ld.id);
        test.stopTest();
        
    }
    Static testMethod void methodtoTest3(){
        lead ld = new lead();
        ld.TCodeHash__c='test';
        ld.LastName='test';
        insert ld;
        ApexPages.StandardController con = new ApexPages.StandardController(ld);
        BusHireSendFeedbackEmail cls = new BusHireSendFeedbackEmail(con);
        BusHireSendFeedbackEmail.sendFeedbackEmail(ld.id);
        ld.status='Converted';
        update ld;
        test.startTest();
        BusHireSendFeedbackEmail.sendWhatsappMessage(ld.id);
        test.stopTest();
        
    }

}