@isTest
public class NPSBusDetractorControllerTest
{
    @testsetup
    static void createCase(){
        case c=new case();
        c.SS_DOJ__c=System.today();
        c.Nps_Response_Date__c=System.today();
        c.Status='Open';
        c.Origin ='NPS Busses';
        c.issue_type__c='Refund';
        insert c;
    }
    public static testMethod void TestNPS_Success()
    {
        Test.startTest();
        case cObj=[select id from case limit 1];
        NPSBusDetractorController npsObj=new NPSBusDetractorController();
        npsObj.selCsId=cObj.id;
        npsObj.doj=System.today();
        npsObj.comment='Test Comment';
        npsObj.requestId='420';
        String jsonBody='{"url":"Test"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        npsObj.caseUpdate();
        npsObj.search();
        Test.stopTest();
        
    }
    public static testmethod void Submitdate(){ 
    Test.startTest();
     case cObj=[select id from case limit 1]; 
     NPSBusDetractorController npsObj=new NPSBusDetractorController();
        npsObj.selCsId=cObj.id;
        npsObj.submitdate=System.today();
        npsObj.comment='Test Comment';
        npsObj.requestId='420';
        String jsonBody='{"url":"Test"}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', jsonBody));
        npsObj.caseUpdate();
        npsObj.search();
        Test.stopTest();
    }
}