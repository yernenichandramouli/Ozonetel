public class PG_Credentialscntrl{

 @AuraEnabled(cacheable=true)
    public static  list<ResponseData> getPGdetails(string ordItemId){
        
        list<ResponseData> respData =new list<ResponseData>();

        list<PG_Credentials__mdt> boltQueslevelTAT = new list<PG_Credentials__mdt>();
        
        List<Order_Items__c> oLs=new List<Order_Items__c>();
        oLs=[select id,Order_Item_Reference_No__c,Payment_Details__c,Order_Id__c from Order_Items__c where id=:ordItemId];
         String tripId='';
        if(!oLs.isEmpty()){
         
           tripId = String.isNotBlank(oLs[0].Order_Item_Reference_No__c)?oLs[0].Order_Item_Reference_No__c:String.isNotBlank(oLs[0].Order_Id__c)?oLs[0].Order_Id__c:'';
            system.debug('---ols---'+oLs[0].Payment_Details__c);
         string PaymentGatewayName='';
         
            Map<string,object> payMap=(Map<string,object>)JSON.deserializeUntyped(oLs[0].Payment_Details__c);
           
            List<Object> payList=(List<Object>)PayMap.get('paymentItemList');
            System.debug('payList-->'+payList);
            for(object payObj:payList){
                map<string,object> pm=(map<string,object>)payObj;
                if(pm.get('paymentSystem')=='ONLINE'){
                 system.debug('--pgType--'+pm.get('pgType'));
                 if(pm.get('pgName')!=null &&  pm.get('pgName')!=''){
                   PaymentGatewayName=string.valueof(pm.get('pgName'));
                 }
                 system.debug('--pgName--'+pm.get('pgName'));
                }
              }  
              
       list<PG_Credentials__mdt> pgCredentialsMdt=[SELECT PG_Url__c,PG_Name__c from PG_Credentials__mdt where PG_Url__c!=null and DeveloperName =:PaymentGatewayName];
       
        if(!pgCredentialsMdt.isEmpty()){
          
           respData.add(new ResponseData(tripId,pgCredentialsMdt[0].PG_Name__c,pgCredentialsMdt[0].PG_Url__c,0,''));   
           system.debug('---true---'+respData); 
           return respData;
        }else{
           respData.add(new ResponseData(tripId,'','',0,'No link'));  
           system.debug('---else---'+respData);  
           return respData;
        }
         
        }else{
          respData.add(new ResponseData(tripId,'','',0,'No transcation'));  
          system.debug('---no trans---'+respData);  
          return respData;
        }
    }
    
    
    public class ResponseData
    {
        @AuraEnabled
        public string tin { get; set; }
        @AuraEnabled
        public string pgName { get; set; }
        @AuraEnabled
        public string pgLink { get; set; }
        @AuraEnabled
        public integer count { get; set; }
        @AuraEnabled
        public string ErrorMsg { get; set; }
        
        public ResponseData(string tinNo,string pgName,string pgLink,integer count,string errorMsg)
        {
            this.tin = tinNo;
            this.pgName = pgName;
            this.pgLink = pgLink;
            this.count=count;
            this.ErrorMsg = errorMsg;  
            
        }
    }

      @AuraEnabled
    public static string dblogToCapturedata(string transactionId,string pgurl,string pgCount,string pgName){
      system.debug('<<<<<<<<'+transactionId+'>>>pgurl>>>>'+pgurl);
    if(string.isNotblank(transactionId) && string.isNotBlank(pgurl)){
      id userId =UserInfo.getUserid();
      
      list<DBLog_Summary__c> dbLst = [select id,Type__c,OwnerId,Case_Number__c,PG_link_count__c from DBLog_Summary__c where Type__c= 'Open PG link' and OwnerId=:userId and  Case_Number__c=:transactionId];
      system.debug('---'+dbLst.size());

      list<DBLog_Summary__c> finalDblog =new list<DBLog_Summary__c>();
      DBLog_Summary__c  dbl =new DBLog_Summary__c();
      dbl.Type__c='Open PG link';
      dbl.Payment_Request_Sent_Data__c=pgName;
      dbl.Payment_Request_Response_Data__c=pgurl;
      dbl.Case_Number__c=transactionId;

    if(!dbLst.isEmpty()){
      system.debug('---iff=====');
      dbl.PG_link_count__c=dbLst[0].PG_link_count__c + integer.valueOF(pgCount);
      dbl.id= dbLst[0].id;
      finalDblog.add(dbl);
      update finalDblog;
      return 'success';
    }else{
      system.debug('---else=====');
      dbl.PG_link_count__c=integer.valueOF(pgCount);
      finalDblog.add(dbl);
      insert finalDblog;
      return 'success';
    }
    
     
    }

    return 'fail';
    
  }
}