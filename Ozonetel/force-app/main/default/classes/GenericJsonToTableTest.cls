@isTest
public class GenericJsonToTableTest {
@isTest
    public static void GenericJsonToTabletest(){
	Order_Items__c ord = new Order_Items__c();
    ord.Assurance_Service__c ='[{"amountPaidByCustomer":20.0,"serviceName":"BUS_CANCELLATION_PROTECTION","refundCategory":"PERCENT","refund":"50","fundedBy":"REDBUS","cancellationPolicy":null},{"amountPaidByCustomer":10.0,"serviceName":"TICKET_CANCELLATION_PROTECTION","refundCategory":null,"refund":null,"fundedBy":"REDBUS","cancellationPolicy":"0:8:100:0;8:14:50:0;14:24:25:0;24:-1:1:0"}]';
	insert ord;
    GenericJsonToTable.getJson(ord.id);
    GenericJsonToTable.jsonColumns(ord.Assurance_Service__c);
    GenericJsonToTable.jsonToMap(ord.Assurance_Service__c);
    }
}