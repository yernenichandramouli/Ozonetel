@isTest
public class TravelProtectInsuranceClsTest {
@isTest
    public static void TravelProtest(){
  Order_Items__c ord = new Order_Items__c();
    ord.Travel_Protection_Insurance__c ='[{"Insurance_Status":"CANCELLATION_SUCCESSFUL","Insurance_Amount":0.1,"Insurance_Provider_Name":"ProtectGroup","Insurance_Type":"CANCELLATION_PROTECTION","Insurance_IsInFunnel":true,"Insurance_Cancellation_Policy":"0:3:100:0;3:6:50:0;6:12:25:0;12:-1:10:0"}]';
  insert ord;
    TravelProtectInsuranceCls.getJson(ord.id);
    TravelProtectInsuranceCls.jsonColumns(ord.Travel_Protection_Insurance__c);
    TravelProtectInsuranceCls.jsonToMap(ord.Travel_Protection_Insurance__c);
    }
}