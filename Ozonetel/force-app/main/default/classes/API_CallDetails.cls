/*
* Name           : API_CallDetails
* Created Date   : 07 Feb 2018
* Created By     : Veeramanikanta R
* Purpose        : API for return cases with casecomments based on mobile number
* Test class     : 
*/
@RestResource(urlMapping='/redBus/CallDetails/*')
global without sharing class API_CallDetails
{
    @HttpPost
    global static string callCapture()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string jsonBody='{"id":"c2c_5ac1ce3562a7d995","callfrom":"7263946106","callto":"434234234","start_time":"1522656283","end_time":"1522656289","duration":"4","billsec":"4","status1":"ANSWER","status2":"ANSWER","recording":"","location":"circle","provider":"network","ringtime":"4","Tin":"TM3456457567","OperatiorId":"Bitla","OperatorName":" Bitla"}';
        //map<string,object> callObjMap= (map<string,object>)JSON.deserializeUntyped(req.requestBody.toString());
        //map<string,object> callObjMap= (map<string,object>)JSON.deserializeUntyped(jsonBody);
        //string s= string.valueof(callObjMap.get('id'));
         ResponseWrapper  respObj=new ResponseWrapper();
         respObj= (ResponseWrapper)System.JSON.deserialize(req.requestBody.toString(),ResponseWrapper.class);
         System.debug('resp -->'+respObj);
         System.debug('resp obj-->'+respObj.id);
         CZentrix_Info__c cInfObj=new CZentrix_Info__c();         
          cInfObj.CustUniqueId__c=respObj.id;        
          cInfObj.Call_Duration__c=respObj.call_duration;                  
          cInfObj.Call_Status__c=respObj.call_status;
          cInfObj.location__c=respObj.location;         
          cInfObj.Provider__c=respObj.provider ;
          cInfObj.Hold_Time__c=respObj.ringtime ;
         if(respObj.start_time!='')
          cInfObj.call_start_date_time__c=DateTime.valueof(respObj.start_time);
        if(respObj.end_time!='')
          cInfObj.Call_End_Time__c=DateTime.valueof(respObj.end_time);
          cInfObj.Recording__c=respObj.monitor_file_name;
          cInfObj.RingTime__c=respObj.ringtime;
          
           Database.upsert(cInfObj,CZentrix_Info__c.CustUniqueId__c,false);

     return 'SUCCESS';
    }   
    
    global class ResponseWrapper{
       public string id ;
       public string callfrom ;
       public string callto ;
       public string agent ;
       public string start_time ;
       public string end_time ;
       public string call_duration;
       public string billsec ;
       public string call_status;
       public string monitor_file_name;
       public string location ;
       public string provider ;
       public string ringtime ; 
       public string Tin ;
       public string BoId ;
       public string BoName ; 
    }
                               
}