/*
* Name           : CallPopUpController
* Created Date   : 14 May 2019
* Created By     : Veeramanikanta R
* Purpose        : Show customer's account, Case and Trnsaction details
* Test class     : 
*/
public class CallPopUpController{
    public string mobile;
    public List<Account> accList{get;set;}
    public List<case> csList{get;set;}
    public List<order_items__c> ordList{get;set;}
    public List<call_details__c> cdList{get;set;}
    public boolean cdBlk{get;set;}
    public string ordId{get;set;}
    public string region{get;set;}
    public string redirectUrl{get;set;}
    public string countryCode{get;set;}
    public boolean showOrders{get;set;}
    public List<IVR_Menu_Options__mdt> ivrOptions{get;set;}
    public map<string,string> ivrMap;
    public string ivrValues{get;set;}
    public list<task> tsList{get;set;}
    public map<string,task> tsMap{get;set;}
    public string hft{get;set;}
    
    // public Map<IVR_Menu_Options__mdt> ivrMap{get;set;}
    public CallPopUpController(){
        System.debug('calling here--');
        ivrMap=new Map<string,string>();
        tsMap=new Map<string,task>();
      
        for(IVR_Menu_Options__mdt iv:[select id,DeveloperName,Menu_Number__c,Menu_Value__c from IVR_Menu_Options__mdt]){
            ivrMap.put(iv.Menu_Number__c,iv.Menu_Value__c);
        }
        
        tsList=new List<task>();
        accList=new List<Account>();
        csList=new List<case>();
        ordList=new List<order_items__c>();
        string mobileNo=ApexPages.currentPage().getParameters().get('mobile');
     
        
        cdList=[select id,Name,Agent_Id__c,Menu_Options__c,Mobile_Number__c,Language__c,Trip_Id__c,OrderUuid__c from call_details__c where Agent_Id__c=:UserInfo.getUserName() order by createddate desc limit 1];
        
        if(!cdList.isEmpty()){
            cdBlk=true;
            string cdMobileNo=cdList[0].Mobile_Number__c;
            
            csList=[select id,casenumber,Transaction_id__r.Name,Issue_type__c,Issue_Sub_Category__c,Date_Of_Journey_New__c,TIN_No__c,Total_Ticket_Amount__c,Service_Provider_Name__c,Source__c,Destination__c,createddate from case where Phone_No_ct__c=:cdMobileNo or Booking_Mobile_No__c=:cdMobileNo or Signed_in_User_Mobile__c=:cdMobileNo limit 5];
            
            accList=[select id,name,PersonMobilePhone,User_Id__c,Signed_in_User__c,PersonEmail,Phone_10_Digits__c from account where Phone_10_Digits__c=:cdMobileNo limit 2];
            
            List<string> caseIds=new List<string>();
            for(case c:csList){
              caseIds.add(c.casenumber);
            }
            
            for(task t:[select id,case_number__c,rating__c from task where case_number__c in:caseIds]){
               tsMap.put(t.case_number__c,t);
            }
            
            ivrValues='';
            if(cdList[0].Menu_Options__c!=null){
                for(string s:cdList[0].Menu_Options__c.split(',')){
                    ivrValues=ivrValues+ivrMap.get(s)+' -> ';
                }
                ivrValues=ivrValues.removeEnd(' -> ');
            }
            
            if(cdList[0].OrderUuid__c!=null)
            {
                showOrders=false;
                ordId=cdList[0].OrderUuid__c;
                ordList =[Select id,name,Primary_Proof_Name__c,Mobile__c,Order_Id__c,Order_Item_Reference_No__c,Transaction_Status__c,Source_Destination__c,Service_Provider_Info__r.name,Seat_No__c,hft__c from order_items__c where OrderUuid__c=:ordId];            
                if(!ordList.isEmpty()){
                   hft=ordList[0].hft__c;
                }
            }
            else{
                showOrders=true;
                ordList=[select id,name,Primary_Proof_Name__c,Customer_Name__r.PersonMobilePhone,Order_Id__c,Order_Item_Reference_No__c,Transaction_Status__c,Source_Destination__c,Service_Provider_Info__r.name,Seat_No__c  from order_items__c where Mobile__c=:cdMobileNo or Customer_Name__r.PersonMobilePhone=:cdMobileNo or Customer_Name__r.Phone_10_Digits__c=:cdMobileNo limit 1];
            }
        }  
    }
    
    public PageReference searchOrder()
    {
        System.debug('.started..'+ordId);
        List<Orders__c> order = new List<Orders__c>();
        List<Order_Items__c> OrdItemLs=new List<Order_Items__c>();
        OrdItemLs=[select id,Order_Id__c,Guid__c,hft__c from Order_Items__c where OrderUuid__c=:ordId OR Order_Id__c=:ordId];
        redirectUrl ='/_ui/search/ui/UnifiedSearchResults?initialViewMode=summary&searchAll=true&str='+ordId;
        System.debug('redirectUrl -->'+redirectUrl);
        if(OrdItemLs.isEmpty())
        {
            string body = '{"orderId":"'+ordId+'","emailId":"","phone":"","caller":"IVR Ameyo PopUp"}';
            System.debug('..body...'+body+'..'+region);
            countryCode = String.isBlank(region)?'IND':'IND'.equalsIgnoreCase(region)?region:'INTL';
            SyncAPICntrl.asyncProcess(body,countryCode);
            redirectUrl ='/apex/SyncPollingPage?id='+ordId; 
        }
        return null;  
    }
}