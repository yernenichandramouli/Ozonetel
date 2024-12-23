@isTest
public class BPQueryReportTest {
    static testMethod void testBPQueryReport(){
        Order_Items__c o=new Order_Items__c();
        o.Name='Test';
        o.Service_Provider_Id__c ='Test';
        insert o;
        
        case c=new case();       
        c.Issue_Type__c='NEFT Refund';
        c.type='B2B';
        c.Status='Open';
        c.Issue_Sub_Category__c='Boarding / Dropping point changed';
        insert c; 
        
        BPQueryReport b=new BPQueryReport();
        b.fromDate=System.today()-3;
        b.toDate=System.today();
        b.countRecords();
        b.exportToExcel();
        
    }
    
}