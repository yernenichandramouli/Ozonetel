@isTest
public class ExceptionalRefundProcessSchedulerTest {
    @isTest static void ApproveCase(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        orIt.Date_Of_Service__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        orIt.Email_Copy__c ='test@mail.com';
        insert orIt;
        
        GlobalSetting__c gs = new GlobalSetting__c();
        gs.Name='test';
        gs.Allow_Collectible_From_BO_Case__c=true;
        insert gs;
        //cs.Other fiels values


        list<case> caselist=new list<Case>();
        Case cs = new Case();
        cs.Issue_Type__c ='Exceptional Refund';
        cs.Issue_Sub_Category__c='Instant refund - Collectible from BO';
        cs.Refund_Type__c='Instant resolution - BO Accepted';
        cs.status='Approved For Exceptional Refund';
        cs.Approved_By__c='Test';
        cs.Category__c = 'Other Issue';
        cs.transaction_id__c = orIt.Id;
        insert cs;
       
       Test.setCreatedDate(cs.Id, DateTime.newInstance(2023,10,10));
        caselist.add(cs);

        Test.startTest();
        string json='{ "status": "SUCCESS", "error_message": "", "error_code": 0, "data": { "orderUuid": "5aaa2016e00df0055722993401010100", "orderItemUuid": "48aefbf3e030f0055722993401020100", "orderItemId": 13230982928261017, "orderId": 13229782750789809, "approval": "SUCCESS", "operatorContribution": { "currencyType": "INR", "amount": 163.91 } } }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ExceptionalRefundProcessBatchScheduler sh1 = new ExceptionalRefundProcessBatchScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
}