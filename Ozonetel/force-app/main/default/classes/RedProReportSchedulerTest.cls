@isTest
public class RedProReportSchedulerTest
{
/*
public static testMethod void TestReportSC()
    {
       Test.startTest();
     //  RedProReportScheduler rs=new RedProReportScheduler ();
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
        RedProReportScheduler  redSch= new RedProReportScheduler ();
        String sche ='0 0 0 3 9 ? 2022';
        system.schedule('Test', sche, redSch);
        Test.stopTest();
       
    }
*/
public static testMethod void TestReport()
    {
       Test.startTest();
          RedProReport r=new RedProReport();
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
           RedProReportScheduler  redSch= new RedProReportScheduler ();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, redSch);
        
       Test.stopTest();
    }
    public static testMethod void TestReport_Closed()
    {
       Test.startTest();
          RedProReport r=new RedProReport();
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
        c.status='Closed';
        insert c;  
          RedProReportScheduler  redSch= new RedProReportScheduler ();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, redSch);
        
       Test.stopTest();
    }
    
     public static testMethod void TestReport_BO_Closed()
    {
       Test.startTest();
          RedProReport r=new RedProReport();
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
        c.status='Closed';
         c.BO_Action__c=1;
       //  c.BO_Agreed_RB__c='disagree';
        c.First_BO_Action__c=system.now();
        insert c;  
        case c2=new case();
        c2=c.clone(false,false,false,false);
        insert c2;
         RedProReportScheduler  redSch= new RedProReportScheduler ();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, redSch);
       Test.stopTest();
    }
    
     public static testMethod void TestReport_BO_Closed2()
    {
       Test.startTest();
          RedProReport r=new RedProReport();
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
        c.status='Open';
        c.BO_Agreed_RB__c='agree';
       
         c.BO_Action__c=1;
        insert c;  
         case c2=new case();
       // c2=c.clone(false,false,false,false);
        //insert c2;
         RedProReportScheduler  redSch= new RedProReportScheduler ();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, redSch);
       Test.stopTest();
    }
 
}