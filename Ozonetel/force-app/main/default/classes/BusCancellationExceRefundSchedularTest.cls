@istest
public class BusCancellationExceRefundSchedularTest {
  public static testMethod void test() {
    List<TempProcessing__c> lstTins = new List<TempProcessing__c>();
    TempProcessing__c temp = new TempProcessing__c();
    temp.name = 'test';
    temp.processed__c = false;
    lstTins.add(temp);

    TempProcessing__c temp1 = new TempProcessing__c();
    temp1.name = 'test';
    temp1.processed__c = false;
    lstTins.add(temp1);

    insert lstTins;

    Orders__c ord = new Orders__c();
    ord.Guid__c = '6ed4daa1a23ef005d93dc8e301010500';
    ord.name = 'test12';
    insert ord;

    List<Order_Items__c> listTins = new List<Order_Items__c>();
    Order_Items__c orIt = new Order_Items__c();
    orIt.OrderUuid__c = '1234567';
    orIt.Order_Name__c = ord.Id;
    orIt.name = '9837321711';
    orIt.ID__c = '9837321711';
    orIt.Refund_Status__c = 'REFUND_FAIL';
    orIt.Order_Item_Reference_No__c = lstTins[0].name;
    orIt.Guid__c = '12345354345345343';
    orIt.Email__c = 'test@test.com';
    listTins.add(orIt);

    insert listTins;

    Test.startTest();
    string json='28.8';
    Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
    BusCancellationExceRefundSchedular obj = new BusCancellationExceRefundSchedular();
    DataBase.executeBatch(obj);
    Test.stopTest();
  }
}