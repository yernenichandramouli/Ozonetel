@isTest
public class RefundOrderItemsTriggerHandleTest {
    @isTest
    public static void testHandler(){
        Order_Items__c ord = new Order_Items__c();
        ord.Total_Fare_Currency__c='INR'; 
        ord.Total_Fare_Value__c=100; 
        ord.Business_Unit__c ='REDBUS_ID';
        ord.Order_Id__c='asdf';
        insert ord;
        system.debug('ord id'+ord.id);
        
        
        case cs = new case();
        cs.Refund_Amount__c=10;
        cs.Refund_Status__c='processing';
        cs.Transaction_ID__c = ord.Id;  
        cs.Issue_Type__c='NEFT Refund';
        cs.PG_Ttransaction_Id__c='test';
        cs.Disbursal_Id__c='1234';
        cs.Trip_Id_ct__c='asdf345';
        cs.Status='Open';
        insert cs;
        
        case cse = new case();
        cse.Refund_Amount__c=10;
        cse.Refund_Status__c='processing';
        cse.Transaction_ID__c = ord.Id;  
        cse.Issue_Type__c='NEFT Refund';
        cse.PG_Ttransaction_Id__c='test';
        cse.Disbursal_Id__c='1234';
        cse.Trip_Id_ct__c='asdf';
        cse.Status='Open';
        insert cse;

        Refund_order_items__c Roi = new Refund_order_items__c();
        roi.Status__c='Open';
        roi.Auto_NEFT_Status__c ='DISBURSEMENT_SUCCESSFUL';
        roi.Disbursal_Status__c='Disbursal_Success';
        roi.Disbursal_ID__c='1234';
        roi.Order_Item_Name__c=ord.id;
        insert roi;
       
        
        roi.status__c='REFUND_SUCCESSFUL';
        roi.Auto_NEFT_Status__c ='DISBURSEMENT_SUCCESSFUL';
        roi.Disbursal_Status__c='Disbursal_Success';
        update roi;
        
        roi.status__c='fallback';
        roi.Auto_NEFT_Status__c ='XENDIT_DISBURSEMENT_NOT_SUPPORTED';
        roi.Disbursal_Status__c='DISBURSAL_COMPLETED';
        roi.Disbursal_ID__c='1234';
        roi.Order_Item_Name__c=ord.id;
        update roi;
        
        roi.status__c='fallback';
        roi.Auto_NEFT_Status__c ='XENDIT_DISBURSE_INITIATED';
        roi.Disbursal_Status__c='DISBURSAL_COMPLETED';
        roi.Disbursal_ID__c='1234';
        roi.Order_Item_Name__c=ord.id;

        update roi;
    }
     @isTest
    public static void testHandler2(){
        Order_Items__c ord = new Order_Items__c();
        ord.Total_Fare_Currency__c='INR'; 
        ord.Total_Fare_Value__c=100; 
        ord.Business_Unit__c ='REDBUS_ID';
        ord.Order_Id__c='asdf';
        insert ord;
        
        system.debug('ord id'+ord.id);
        case cs = new case();
        cs.Refund_Amount__c=10;
        cs.Refund_Status__c='processing';
        cs.Transaction_ID__c = ord.Id;  
        cs.Issue_Type__c='NEFT Refund';
        cs.PG_Ttransaction_Id__c='test';
        cs.Disbursal_Id__c='1234';
        cs.Trip_Id_ct__c='asdf';
        cs.Status='Open';
        cs.Disbursal_Status__c='FAILED_MAX_ATTEMPS_EXCEED';
        insert cs;
        Refund_order_items__c Roi = new Refund_order_items__c();
        roi.Status__c='Open';
        roi.Auto_NEFT_Status__c ='DISBURSEMENT_SUCCESSFUL';
        roi.Disbursal_Status__c='open';
        insert roi;
        roi.status__c='REFUND_SUCCESSFUL';
        roi.Auto_NEFT_Status__c ='DISBURSEMENT_SUCCESSFUL';
        roi.Disbursal_Status__c='FAILED_MAX_ATTEMPS_EXCEED';
        roi.Disbursal_ID__c='1234';
        update roi;
        set<string> ldIds = new set<string>();
        set<string> tins = new set<string>();
        map<string,Refund_Order_Items__c> mapRefundId = new map<string,Refund_Order_Items__c>(); 
        ldIds.add(roi.Disbursal_ID__c);
        tins.add(roi.Trip_ID__c);
        mapRefundId.put('asdf',roi);
        RefundOrderItemsTriggerHandler.DisbursalCaseUpadte(ldIds,tins,mapRefundId);
    }
     @isTest
    public static void testHandler3(){
        Order_Items__c ord = new Order_Items__c();
        ord.Total_Fare_Currency__c='INR'; 
        ord.Total_Fare_Value__c=100; 
        ord.Business_Unit__c ='REDBUS_ID';
        ord.Order_Id__c='asdf';
        insert ord;
        
        system.debug('ord id'+ord.id);
        case cs = new case();
        cs.Refund_Amount__c=10;
        cs.Refund_Status__c='processing';
        cs.Transaction_ID__c = ord.Id;  
        cs.Issue_Type__c='NEFT Refund';
        cs.PG_Ttransaction_Id__c='test';
        cs.Disbursal_Id__c='1234';
        cs.Trip_Id_ct__c='asdf';
        cs.Status='Open';
        cs.Disbursal_Status__c='Disbursal_Failed';
        insert cs;
        Refund_order_items__c Roi = new Refund_order_items__c();
        roi.Status__c='Open';
        roi.Auto_NEFT_Status__c ='Disbursal_Failed';
        roi.Disbursal_Status__c='open';
        insert roi;
        roi.status__c='Disbursal_Failed';
        roi.Auto_NEFT_Status__c ='DISBURSEMENT_SUCCESSFUL';
        roi.Disbursal_Status__c='Disbursal_Failed';
        roi.Disbursal_ID__c='1234';
        update roi;
        set<string> ldIds = new set<string>();
        set<string> tins = new set<string>();
        map<string,Refund_Order_Items__c> mapRefundId = new map<string,Refund_Order_Items__c>(); 
        ldIds.add(roi.Disbursal_ID__c);
        tins.add(roi.Trip_ID__c);
        mapRefundId.put('asdf',roi);
        RefundOrderItemsTriggerHandler.DisbursalCaseUpadte(ldIds,tins,mapRefundId);
    }

    @isTest
    public static void testHandler4(){
        Order_Items__c ord = new Order_Items__c();
        ord.Total_Fare_Currency__c='INR'; 
        ord.Total_Fare_Value__c=100; 
        ord.Business_Unit__c ='REDBUS_ID';
        ord.Order_Id__c='asdf';
        insert ord;
        
        system.debug('ord id'+ord.id);
        case cs = new case();
        cs.Refund_Amount__c=10;
        cs.Refund_Status__c='processing';
        cs.Transaction_ID__c = ord.Id;  
        cs.Issue_Type__c='NEFT Refund';
        cs.PG_Ttransaction_Id__c='test';
        cs.Disbursal_Id__c='1234';
        cs.Trip_Id_ct__c='asdf';
        cs.Status='Open';
        cs.Disbursal_Mode__c='MANUAL_NEFT';
        insert cs;
        Refund_order_items__c Roi = new Refund_order_items__c();
        roi.Status__c='Open';
        roi.Auto_NEFT_Status__c ='Disbursal_Failed';
        roi.Disbursal_Status__c='open';
        insert roi;
        roi.status__c='Disbursal_Failed';
        roi.Auto_NEFT_Status__c ='DISBURSEMENT_SUCCESSFUL';
        roi.Disbursal_Mode__c='MANUAL_NEFT';
        roi.Disbursal_ID__c='1234';
        update roi;
        set<string> ldIds = new set<string>();
        set<string> tins = new set<string>();
        map<string,Refund_Order_Items__c> mapRefundId = new map<string,Refund_Order_Items__c>(); 
        ldIds.add(roi.Disbursal_ID__c);
        tins.add(roi.Trip_ID__c);
        mapRefundId.put('asdf',roi);
        RefundOrderItemsTriggerHandler.DisbursalCaseUpadte(ldIds,tins,mapRefundId);
    }
}