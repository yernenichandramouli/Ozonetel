@isTest
public class PaymentStatusUpdonCasecrt_Test
{
   Public static testMethod void method()
    {
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
               
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.status__c='CREATED';
        ori.Date_Of_Service__c=System.Now();
        ori.Creation_Time__c=System.Now();
        ori.Transaction_Source__c = 'MOBILEAPP';
        ori.Item_Type__c = 'HOTEL';
        ori.Business_Unit__c = 'REDBUS_IN';
        Insert ori;
        
        WFT_GFT__c w = new WFT_GFT__c();
        w.Transaction_Name__c = ori.id;
        
        
        Payment_Items__c p = new Payment_Items__c();
        p.Name = '12345';
        p.Payment_System__c = 'online';
        p.Order_Item_Name__c = ori.id;
        p.ID__c = '12345';
        insert p;
        
        WFT_GFT_Payment__c wp = new WFT_GFT_Payment__c();
        wp.Payment_Items_Name__c = p.id;
        wp.ID__c = '12345';
        
        insert wp;
                
        String rid  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Green Failed Transaction (GFT)').getRecordTypeId();

        Case c = new Case();
        c.Status = 'Open';
        c.Transaction_ID__c = ori.id;
        c.RecordTypeid = rid;
        insert c;
        
        OrderItemTransactionResource__c o = new OrderItemTransactionResource__c();
        o.Name = 'MOBILEAPP';
        o.Auth_Key__c = '487a342c-92f1-41ae-81fa-aaa5120f6bb3';
        o.Channel_Name__c = 'MOBILE_APP';
        //o.UTC_time_difference_in_min__c = ;
        insert o;
        
        OrderItemTransactionResource__c o1 = new OrderItemTransactionResource__c();
        o1.Name = 'REDBUS_IN';
        o1.Auth_Key__c = 'IND';
        o1.Channel_Name__c = '';
        o1.UTC_time_difference_in_min__c = 0;
        insert o1;
        
        OrderItemTransactionResource__c o2 = new OrderItemTransactionResource__c();
        o2.Name = 'HOTEL';
        o2.Auth_Key__c = 'HOTEL';
        o2.Channel_Name__c = '';
        //o2.UTC_time_difference_in_min__c = -150 ;
        insert o2;
        
        Payment_API_endpoint__c pp = new Payment_API_endpoint__c();
        pp.Name = 'End Point';
        pp.End_Point__c = 'test';
        insert pp;
        
        Set<String> tripids = new Set<String>();
        List<WFT_GFT__c> listoi = new List<WFT_GFT__c>();
        List<Case> listcs = new List<Case>();
        tripids.add(String.valueOf(ori.id).substring(0, 15));
        listoi.add(w);
        listcs.add(c);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        PaymentStatusUpdonCasecrt pa = new PaymentStatusUpdonCasecrt();
        PaymentStatusUpdonCasecrt.PaymentStatus(tripids,listoi);
        Test.stopTest();
        insert w;
        
    }
}