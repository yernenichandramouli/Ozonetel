@isTest
public class MassBusCancellationBatchTest
{
    public static testMethod void MassExceptionalRefundTest()
    {
            Mass_BusCancellation__c o=new Mass_BusCancellation__c();
            o.TIN_No__c='TN345678';
            o.Cancellation_Reason__c='SF_Mass_BusCancellation '; 
            o.Email__c='test@gmail.com';
            o.Mobile_No__c='987654321';
            o.Country__c='India';
            insert o;
            
            string json='0';
            string query='';
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
            MassBusCancellationBatch  busCan= new MassBusCancellationBatch();
            String sch = '0 0 8 13 2 ?';
            system.schedule('massBuscancl', sch,busCan);
            Test.stopTest();
        }
        
    public static testMethod void methodTest()
    {
            Mass_BusCancellation__c o=new Mass_BusCancellation__c();
            o.TIN_No__c='TN345678';
            o.Cancellation_Reason__c='SF_Mass_BusCancellation '; 
            o.Email__c='test@gmail.com';
            o.Mobile_No__c='987654321';
            o.Country__c='Singapore';
            insert o;
            
            string json='0';
            string query='';
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
            MassBusCancellationBatch  busCan= new MassBusCancellationBatch();
            String sch = '0 0 8 13 2 ?';
            system.schedule('massBuscancl', sch,busCan);
            Test.stopTest();
        }
        
    public static testMethod void methodTest1()
    {
            Mass_BusCancellation__c o=new Mass_BusCancellation__c();
            o.TIN_No__c='TN345678';
            o.Cancellation_Reason__c='SF_Mass_BusCancellation '; 
            o.Email__c='test@gmail.com';
            o.Mobile_No__c='987654321';
            o.Country__c='Colombia';
            insert o;
            
            string json='{"Code":"400.25","Message":"Cancellation_Failed","DetailedMessage":"This ticket has already been cancelled"}';
            string query='';
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(417, 'OK', json));
            MassBusCancellationBatch  busCan= new MassBusCancellationBatch();
            String sch = '0 0 8 13 2 ?';
            system.schedule('massBuscancl', sch,busCan);
            Test.stopTest();
        }
        
    }