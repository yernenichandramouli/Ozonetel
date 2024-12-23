public class CallDetailsTriggerHandler{    
    public static void OrderSync(string tripId){
        List<Order_Items__c> OrdItemLs=new List<Order_Items__c>();
        OrdItemLs=[select id,Order_Id__c,OrderUuid__c from Order_Items__c where OrderUuid__c=:tripId OR Order_Id__c=:tripId];

        if(OrdItemLs.isEmpty())
        {
            string region;
            string body = '{"orderId":"'+tripId+'","emailId":"","phone":"","caller":"IVR Ameyo"}';
            string  countryCode = String.isBlank(region)?'IND':'IND'.equalsIgnoreCase(region)?region:'INTL';
            SyncAPICntrl.asyncProcess(body,countryCode);
        }      
    }
}