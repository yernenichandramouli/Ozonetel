@istest
class RouteIdupdateSchedularTest{

   static testmethod void test() {
   Test.startTest();

        Order_Items__c  orIt= new Order_Items__c();
        orIt.name = '9837321711';
        orIt.ID__c = '9837321711';
        orIt.additional_details__c = 'test';
        orIt.created_by__c = 'test';
        orIt.creation_time__c = system.now();
        orIt.transaction_source__c = 'RB:MOBILEWEB#droidapp';
        orIt.amount_recieved_currency__c = 'INR';
        orIt.Order_Item_Reference_No__c= 'TIN6473553';
        orIt.business_unit__c = 'REDBUS_IN';
        orIt.date_of_service__c = system.now();
        orIt.Mobile__c = '432133445566';
        orIt.Service_Provider_Name__c = 'Orange';
        insert orIt;
     
     Bus_Order_Item_Details__c bo = new Bus_Order_Item_Details__c();
     bo.Name = '170011';
     bo.route_id__c ='23623';
     bo.Order_Item_Name__c = orIt.id;
     insert bo;
     
     RouteIdupdateSchedular p= new RouteIdupdateSchedular();
     String sch = '0 0 8 13 2 ?';
     system.schedule('One Time Pro', sch, p);
    // RouteIdonTransactionUpdateBatch  b = new RouteIdonTransactionUpdateBatch(); 
    // DataBase.BatchableContext bc;
  //   b.execute(bc,new list<>);
   Test.stopTest();
   
   System.debug('route...'+[select id,route_id__c from order_items__c where id=:orIt.id].route_id__c);
   
      //System.assertEquals('23623',[select id,route_id__c from order_items__c where id=:orIt.id].route_id__c);
   }
 }