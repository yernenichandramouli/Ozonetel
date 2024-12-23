@isTest
public class fetchCallDetailsCtrlTest {
    @isTest static void testMethod1(){
        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.OrderUuid__c = '6df4532506def0dgrdfgfd067bf1fe8602010200';
        insert orIt;

        call_details__c c=new call_details__c ();
        c.PredictedOrderUuid__c ='6df4532506def0dgrdfgfd067bf1fe8602010200';
        insert c;

        fetchCallDetailsCtrl.getRelatedCallDetails(orIt.Id);
    }
}