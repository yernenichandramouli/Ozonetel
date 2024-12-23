/*
* Name           : CallPopUpControllerLtng
* Created Date   : 03 June 2020
* Created By     : Sreenivas M
* Purpose        : Show customer's account, Case and Trnsaction details
* Test class     : 
*/
public class CallPopUpControllerLtng{
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
    public CallPopUpControllerLtng(){
        
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
        ordList=[select id,Order_Id__c,Guid__c,hft__c from Order_Items__c where OrderUuid__c=:ordId OR Order_Id__c=:ordId];
        redirectUrl ='/_ui/search/ui/UnifiedSearchResults?initialViewMode=summary&searchAll=true&str='+ordId;
        System.debug('redirectUrl -->'+redirectUrl);
        if(ordList.isEmpty())
        {
            string body = '{"orderId":"'+ordId+'","emailId":"","phone":"","caller":"IVR Ameyo PopUp"}';
            System.debug('..body...'+body+'..'+region);
            countryCode = String.isBlank(region)?'IND':'IND'.equalsIgnoreCase(region)?region:'INTL';
            SyncAPICntrl.asyncProcess(body,countryCode);
            redirectUrl ='/apex/SyncPollingPage?id='+ordId; 
        }
        return null;  
    }

    @AuraEnabled(cacheable=true)
    public static string getRedirectionUrl(String oId)
    {
        List<Order_Items__c> OrdItemLs=new List<Order_Items__c>();
        OrdItemLs=[select id,Order_Id__c,Guid__c,hft__c from Order_Items__c where OrderUuid__c=:oId OR Order_Id__c=:oId];
        String stringToEncode = '{"componentDef":"forceSearch:search","attributes":{"term":"'+ oId + '","scopeMap":{"type":"TOP_RESULTS"},"context":{"disableSpellCorrection":false,"SEARCH_ACTIVITY":{"term":"'+ oId + '"}}}}';
		String encodedStr = EncodingUtil.base64Encode(Blob.valueOf(stringToEncode));
		String redirectUrl='/one/one.app?source=aloha#'+encodedStr;
       
        if(OrdItemLs.isEmpty())
        {
            string body = '{"orderId":"'+oId+'","emailId":"","phone":"","caller":"IVR Ameyo PopUp"}';
            SyncAPICntrl.asyncProcess(body,'IND');
            redirectUrl ='/apex/SyncPollingPage?id='+oId; 
        }
        return redirectUrl;
      
    }

    @AuraEnabled(cacheable=true)    
    public static String fetchLatestCallDet(String clDetId){
      
    List<call_details__c> listCalDet = new List<Call_Details__c>();
    DetailsWrapper wr = new DetailsWrapper();  
    
    System.debug('Record Id....'+clDetId);
    if(String.isNotBlank(clDetId))
    {
        listCalDet=[select id,Name,Agent_Id__c,Menu_Options__c,Business_Unit__c,Mobile_Number__c,Language__c,Trip_Id__c,OrderUuid__c from call_details__c where id=:clDetId];

    }
    else {
               listCalDet=[select id,Name,Agent_Id__c,Business_Unit__c,Menu_Options__c,Mobile_Number__c,Language__c,Trip_Id__c,OrderUuid__c from call_details__c where Agent_Id__c=:UserInfo.getUserName() order by createddate desc limit 1];
 
    }
    if(listCalDet.isEmpty()) 
        return '';
    else{
            List<Case> lisCase = new List<Case>();
            List<Account> lisAcc = new List<Account>();
            List<Order_Items__c> listOrd = new List<Order_Items__c>();

            string cdMobileNo=listCalDet[0].Mobile_Number__c;
            
            lisCase=[select id,casenumber,Transaction_id__r.Name,Issue_type__c,Issue_Sub_Category__c,Date_Of_Journey_New__c,TIN_No__c,Total_Ticket_Amount__c,Service_Provider_Name__c,Source__c,Destination__c,createddate from case where Phone_No_ct__c=:cdMobileNo or Booking_Mobile_No__c=:cdMobileNo or Signed_in_User_Mobile__c=:cdMobileNo limit 5];
            
            lisAcc=[select id,name,PersonMobilePhone,User_Id__c,Signed_in_User__c,PersonEmail,Phone_10_Digits__c from account where Phone_10_Digits__c=:cdMobileNo limit 2];
                      
            String ivrPath='';
            if(String.isNotBlank(listCalDet[0].Business_Unit__c) && listCalDet[0].Business_Unit__c=='BUS'){
                wr.isBusTransaction = true;
            }else{
                wr.isBusTransaction = false;
            }
            if(String.isNotBlank(listCalDet[0].Menu_Options__c))
            {
                Map<string,string> ivrCustMap=new Map<string,string>();
                for(IVR_Menu_Options__mdt iv:[select id,DeveloperName,Menu_Number__c,Menu_Value__c from IVR_Menu_Options__mdt])
                    ivrCustMap.put(iv.Menu_Number__c,iv.Menu_Value__c);
                
                    for(string s:listCalDet[0].Menu_Options__c.split(',')){
                    ivrPath=ivrPath+ivrCustMap.get(s)+' -> ';
                }
                ivrPath=ivrPath.removeEnd(' -> ');
            }
            
            System.debug('Order uuid...'+listCalDet[0].OrderUuid__c);
            if(listCalDet[0].OrderUuid__c!=null)
                listOrd =[Select id,name,Primary_Proof_Name__c,Mobile__c,Order_Id__c,Order_Item_Reference_No__c,Transaction_Status__c,Source_Destination__c,Service_Provider_Info__r.name,Seat_No__c,hft__c from order_items__c where OrderUuid__c=:listCalDet[0].OrderUuid__c];            
            else{
                listOrd=[select id,name,Primary_Proof_Name__c,HFT__c,Customer_Name__r.PersonMobilePhone,Order_Id__c,Order_Item_Reference_No__c,Transaction_Status__c,Source_Destination__c,Service_Provider_Info__r.name,Seat_No__c  from order_items__c where Mobile__c=:cdMobileNo or Customer_Name__r.PersonMobilePhone=:cdMobileNo or Customer_Name__r.Phone_10_Digits__c=:cdMobileNo limit 1];
            }
           System.debug('listOrd....'+listOrd);
            wr.calDet = listCalDet[0];
            wr.listAcc = lisAcc;
            wr.listCase = lisCase;
            wr.listOrd = listOrd;
            wr.menOpt = ivrPath;
            wr.heroFetName = !listOrd.isEmpty()?String.isNotBlank(listOrd[0].hft__c)?listOrd[0].hft__c:'-':'-';

            return JSON.serialize(wr);
        } 
        
    }

    public class DetailsWrapper
    {
        @AuraEnabled public call_details__c calDet{get;set;}
        @AuraEnabled public List<Account> listAcc{get;set;}
        @AuraEnabled public List<Case> listCase{get;set;}
        @AuraEnabled public List<Order_items__c> listOrd{get;set;}
        @AuraEnabled public String menOpt{get;set;}
        @AuraEnabled public String heroFetName{get;set;}  
        @AuraEnabled public boolean isBusTransaction{get;set;}  
    }
}