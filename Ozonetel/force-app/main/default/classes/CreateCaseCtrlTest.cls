@isTest
public class CreateCaseCtrlTest {

@isTest
    public static void testCreateCaseCtrl(){
       Order_Items__c oi=new Order_Items__c();
        oi.name='Transaction-123';
        oi.Order_Item_Reference_No__c='12345';
        oi.Business_Unit__c = 'REDBUS_IN';
        oi.Transaction_Status__c ='Cancelled';
        oi.Primary_Boarding_Point_Time__c = DateTime.now();
        insert oi;
     case cs = new case();
    cs.Issue_Type__c = 'Bus Cancellation';
    cs.Status = 'Initiated';
    cs.Does_Customer_Require_CallBack__c=true;
    cs.Call_Back_Time__c='1';
    cs.Transaction_ID__c = oi.id;    
    CreateCaseCtrl.CreateCase(cs);
    CreateCaseCtrl.DuplicateCheck(cs.Transaction_ID__c);
    }
}