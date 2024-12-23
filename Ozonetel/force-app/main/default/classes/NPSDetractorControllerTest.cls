@isTest
public class NPSDetractorControllerTest
{
    @testsetup
    static void createCase(){
        case c=new case();
        c.CheckIn_Date__c=System.today();
        c.Status='Open';
        c.Origin ='NPS Hotels';
        c.issue_type__c='Refund';
        insert c;
    }
    public static testMethod void TestNPS_Success()
    {
        Test.startTest();
        case cObj=[select id from case limit 1];
        NPSDetractorController npsObj=new NPSDetractorController();
        npsObj.selCsId=cObj.id;
        npsObj.fromDate =System.today();
        npsObj.toDate=System.today();
        npsObj.comment='Test Comment';
        npsObj.requestId='420';
        String jsonBody='{"url":"Test"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        npsObj.caseUpdate();
        npsObj.search();
        
        Test.stopTest();
        
    }  
    
}