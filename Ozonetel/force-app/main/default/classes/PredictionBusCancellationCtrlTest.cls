@isTest
public class PredictionBusCancellationCtrlTest
{
    /*
Name:createOrder
Description: Creates Order Item data (Other methods can utilize) 
*/    
    @testsetup
    static void createOrder(){
        List<Order_Items__c> orderList = new List<Order_Items__c>();        
        for(Integer i = 0 ; i<2 ; i++) {
            orderList.add(new Order_Items__c(Order_Item_Reference_No__c='TM6C61913368',name = 'testLName'+i , Service_Provider_Id__c = 'Salesforce',email__c='mani.renus@gmail.com',Mobile__c='9491322718',Business_Unit__c='REDBUS_ID',Date_Of_Service__c=System.today()));
        } 
        insert orderList ;
        orderList[1].Order_Item_Reference_No__c='TM6C61913369';
        update orderList;
        
        Case cs = new Case();
        cs.Status ='Open';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='Bus Operator Service';
        cs.tin_no__c='TM6C61913368';
        cs.transaction_id__c=orderList[0].id;
        cs.PD_DOJ__c=System.today();
        cs.BusC_PD_Time__c='16';
        insert cs;
        System.debug('case n1-->'+cs);
    }
    
    public static testMethod void Test_Success()
    {
        Test.startTest();
        PredictionBusCancellationCtrl  p=new PredictionBusCancellationCtrl();
        string mJson='[{"tin":"TM5N62346289"},{"tin":"TM5R49721669"},{"tin":"TM5W91090115"},{"tin":"TM5J37938592"},{"tin":"TM5E61773593"},{"tin":"TM5X99580184"},{"tin":"TM5W15116204"},{"tin":"TM5H48294107"}]';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mjson));
        Order_Items__c tObj=[select id from Order_Items__c limit 1];  
        case cObj=[select id,caseNumber from case limit 1];
        System.debug('case nu-->'+cObj.casenumber);
        p.selectedtin='TM6C61913369';    
        p.selectedtin='TM6C61913360';
        p.caseId=cObj.caseNumber;
        p.doj=System.today();
        p.tintime='16';
        p.status='Initiated';
        p.bophone='9491322718';
        p.boAgentName='Mani A';
        PredictionBusCancellationCtrl.Response pr=new PredictionBusCancellationCtrl.Response();
        p.search();
        p.resWrapper[0].isSelected=true;
        p.caseUpdate();
        Test.stopTest(); 
    }
    
    public static testMethod void Test_Success2()
    {
        PredictionBusCancellationCtrl p=new PredictionBusCancellationCtrl();
        string mJson='{ "status": true, "Message": "Call sent successfully!", "id": "c2c_5afbe64dd9cae811" }';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mjson));
        p.selectedtin='TM6C61913369';
        p.boPhoneNo='9491322718';
        Order_Items__c tObj=[select id from Order_Items__c limit 1];  
        Case cs = new Case();
        // cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Status ='Open';
        cs.Issue_Type__c ='Bus Operator Service';
        cs.Issue_Sub_Category__c ='Alternate bus not arranged'; 
        cs.transaction_id__c=tObj.id;
        insert cs;
        case cObj=[select id,casenumber from case where id=:cs.id LIMIT 1];
        p.caseId=cObj.casenumber;
        System.debug('case Number-->'+cObj.casenumber);
        Test.startTest();
        System.debug('case Number2-->'+p.caseId);
        p.connectCall();
        Test.stopTest();
    }
}