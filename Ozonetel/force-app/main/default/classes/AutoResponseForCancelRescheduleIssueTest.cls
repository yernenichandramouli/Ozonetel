@isTest
public class AutoResponseForCancelRescheduleIssueTest
{
    static testMethod void reSchduleIssues()
    {
        Date curntdt =system.today(); 
        list<case> cslst= new list<case>();
        Case cs = new Case();
        cs.issue_type__c='Ticket Cancellation';
        cs.Issue_Sub_Category__c='I am not able to cancel my ticket';
        cs.Booking_Email_ID__c='test.s@redbus.com';
        cs.Origin='Complaint Tracker';
        cs.TIN_No__c='TN5347079882';
        cslst.add(cs);
        insert cslst;
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        test.starttest();
        AutoResponseForCancelRescheduleIssues Resch= new AutoResponseForCancelRescheduleIssues();
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, Resch);
        Test.stopTest();
    }
    
    static testMethod void reSchduleIssuesMethod2()
    {
        Date curntdt =system.today(); 
        list<case> cslst= new list<case>();
        Case cs = new Case();
        cs.issue_type__c='Ticket Cancellation';
        cs.Issue_Sub_Category__c='I am not able to cancel my ticket';
        cs.Booking_Email_ID__c='test.s@redbus.com';
        cs.Origin='Complaint Tracker';
        cs.TIN_No__c='TN5347079882';
        cslst.add(cs);
        insert cslst;
        
        
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout()); 
        
        AutoResponseForCancelRescheduleIssues Resch= new AutoResponseForCancelRescheduleIssues();
        
        Id orgEmailId = [select id, Address, DisplayName from OrgWideEmailAddress where Address ='noreply_feedback@redbus.in' limit 1].id;    
        //Resch.prepareEmailBody(cslst[0],'Cancellation_Policy_Expired',orgEmailId,'test');
        String sche = '0 0 0 ? * * *';
        system.schedule('Test', sche, Resch);
        test.starttest();
        Resch.execute(null,cslst);
        Test.stopTest();
    }
    static testMethod void reSchduleIssuesMethod3()
    {
        Date curntdt =system.today(); 
        list<case> cslst= new list<case>();
        Case cs = new Case();
        cs.issue_type__c='Ticket Cancellation';
        cs.Issue_Sub_Category__c='I am not able to cancel my ticket';
        cs.Booking_Email_ID__c='test.s@redbus.com';
        cs.Origin='Complaint Tracker';
        cs.TIN_No__c='TN5347079882';
        cslst.add(cs);
        insert cslst;
        
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='5663'; 
        o.Guid__c ='b8a7cd72ad20f00585344c3002020500';
        insert o;
        list<CancellationPolicyCntrl.Cancelpolicylist> cpc=new list<CancellationPolicyCntrl.Cancelpolicylist>();
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
        cpc.add(listcp);
        
        //string json1='[{"Charges":"567","CurrentSlot":false,"Percentage":"567","Duration":"567","ZCafepercent":"test","RefundableAmount":"10","IsZCafeApplicable":false}]';
        

        
        case c=[select id,casenumber,issue_type__c,Issue_Sub_Category__c,Booking_Email_ID__c,Origin,TIN_No__c,OrderItem_Uuid__c from case where id=:cslst[0].id];
        system.debug('<<<c'+c.casenumber);
        
        string json='{"cancelpolicylist":[{"Charges":"567","CurrentSlot":false,"Percentage":"567","Duration":"567","ZCafepercent":"test","RefundableAmount":"10","IsZCafeApplicable":false}],"isPartialCancellationAllowed":true,"isZcafeApplied":true,"zcafeDuration":12,"zcafeSponsoredByRedbus":true,"zcafePolicy":"test","bookedViaTCP":false}';

        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        test.starttest();
        
        
        AutoResponseForCancelRescheduleIssues Resch= new AutoResponseForCancelRescheduleIssues();
        Id orgEmailId = [select id, Address, DisplayName from OrgWideEmailAddress where Address ='noreply_feedback@redbus.in' limit 1].id; 
        system.debug('<<<<cslist'+cslst[0]+'<<<org'+orgEmailId+'<<label'+System.Label.PartialCanNotAllowedSTC+'<<<'+cslst[0].casenumber);
        Resch.prepareEmailBody(c,'Cancellation_Policy_Expired',orgEmailId,System.Label.PartialCanNotAllowedSTC);
        Test.stopTest();
    }
    
    
    
    
}