@isTest
public class MassExceptionalRefundBDBatchTest
{
    public static testMethod void MassExceptionalRefundTest()
    {
        
        Mass_Exceptional_Refund__c o=new Mass_Exceptional_Refund__c();
        o.Ticket_Amount__c='230';
        o.Exceptional_Refund_Amount__c='40'; 
        o.Parent_Case_Number__c='345689';
        o.Exceptional_Refund_Type__c='test';
        o.TIN_No__c='TN456789';
        
        insert o;
        
         Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.Order_Item_Reference_No__c= 'D4UZ22Ymk5';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.Route_Id__c= '4353';       
        orIt.date_of_service__c = Datetime.now().addDays(-2);
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        orIt.Service_Provider_Id__c ='2551211';
        orIt.Order_Id__c ='15425';
        orIt.Guid__c ='Test';
        insert orIt;
        
        Case cs = new Case();
        cs.transaction_id__c = orIt.Id;
        cs.Status ='Refunded By Ageing Scheduler';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='I have a problem with bus service';
        cs.Issue_Sub_Category__c ='The bus was of poor quality';
        cs.isAgening_Refund_Processed__c=false;
        cs.Type='B2C';
        insert cs;
        
        string json='0';
        string query='';
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
       /* MassExceptionalRefundBDBatch  busCan= new MassExceptionalRefundBDBatch();
        
        String sch = '0 0 8 13 2 ?';
        system.schedule('massBuscancl', sch,busCan);*/
        
        Test.stopTest();
        }
    }