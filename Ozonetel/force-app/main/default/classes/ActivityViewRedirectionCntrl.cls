public class ActivityViewRedirectionCntrl{
public static Id recId{get;set;}

    public ActivityViewRedirectionCntrl(ApexPages.StandardController controller) {

        recId = controller.getId();
        System.debug('recId====>'+recId);
      
    }
    
 public pageReference checkAddonOrNot()
    {
     
     List<Activities__c> listAddons = new List<Activities__c>();
     listAddons = [Select id,Order_Item_Uuid__c,Order_Item_id__c from Activities__c Where id=:recId];
     PageReference myVFPage;
     if(!listAddons.isEmpty() && string.isNotBlank(listAddons[0].Order_Item_Uuid__c)){
     
        myVFPage = new PageReference('/apex/AddonsRecordViewPage?id='+recId);
        
      }
      else{
       myVFPage = new PageReference('/'+recId+'?nooverride=1');
       
      }
      myVFPage.setRedirect(true);
      return myVFPage;
      
     } 
}