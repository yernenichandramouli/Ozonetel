@isTest
public class API_BOCaseDetailsTest
{
    static testMethod void GetBOCasesCountTest()
    {
        Test.startTest();
        Order_Items__c o=new Order_Items__c();
        o.name='Test';
        o.Service_Provider_Id__c='5663'; 
        insert o;
        
        Case c=new Case();
        c.SS_Route_Id__c='8404193';
        c.Transaction_ID__c=o.id;
        c.Issue_Type__c='Bus Operator Service';    
        c.Country__c='India';  
        c.issue_type__c='Bus Operator Service';
        insert c;  
        API_BOCaseDetails.GetBOCasesCount();
        Test.stopTest();
    }
    
}