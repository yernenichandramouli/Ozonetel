/**
* (c) 2019 RedBus
*
* Name           : API_CallEndedDetails
* Created Date   : 18 Jan 2019
* Created By     : Sreenivas M
* Purpose        : API to update the call details after call has been disconnected
*
**/

@RestResource(urlMapping='/redBus/v1/CallEnded')
global without sharing class API_CallEndedDetails
{
    
    @HttpPost
    global static String callDetails()
    {
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c ='End Call Details';
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String resStatus = '';
        system.debug('resStatus -->'+resStatus );
        try
        {
            system.debug('-----------request data serialized debug--------'+req.requestBody.toString());
            dbl.Request_Data__c = String.valueOf(req.requestBody.toString());
            
            if(String.isNotBlank(String.valueOf(req.requestBody.toString())))
            {
                map<string,object> callDetails = (map<string,object>)JSON.deserializeUntyped(req.requestBody.toString());
                String custUniqId =(callDetails!=null && callDetails.containsKey('id'))?(String)callDetails.get('id'):'';
                system.debug('custUniqId-->>'+custUniqId);
                if(String.isNotBlank(custUniqId))
                {
                    
                    CZentrix_Info__c cInfObj=new CZentrix_Info__c();
                    cInfObj = [Select id,Lead__c,ownerid from CZentrix_Info__c Where CustUniqueId__c=:custUniqId];
                    cInfObj.CustUniqueId__c=custUniqId;   
                    cInfObj.Agent_ID__c = (String)callDetails.get('agentid');
                    cInfObj.Call_Status__c= (String)callDetails.get('call_status');
                    cInfObj.Update_Type__c = 'Real Time';
                    
                    system.debug('call status-->'+ cInfObj.Call_Status__c);
                    
                    if(String.isNotBlank((String)callDetails.get('start_time')))
                        cInfObj.call_start_date_time__c=DateTime.valueof((String)callDetails.get('start_time'));
                    
                    if(String.isNotBlank((String)callDetails.get('end_time')))
                        cInfObj.Call_End_Time__c=DateTime.valueof((String)callDetails.get('end_time'));
                    
                    
                    Lead ld = new Lead();
                    ld = [Select id,NextCallDate__c,Status,RnR_Unsuccessful_Attempts__c,Owner_Group__c,Call_Ended__c,Call_back_request_time__c,Lead_Group__c,First_Call_Dialled__c from Lead Where id=:cInfObj.Lead__c];
                    
                    Id busComQueue= [Select id from Group where type='Queue' AND developername='BusHire_Common_Pool'].id;
                    ld.ownerid=busComQueue;  
                    
                    System.debug('ld-->'+ld);
                    
                    if(ld.First_Call_Dialled__c==null)
                        ld.First_Call_Dialled__c= cInfObj.call_start_date_time__c;
                    
                    If(ld.Lead_Group__c=='Group 1'){
                        
                        if(!'answered'.equalsIgnoreCase(cInfObj.Call_Status__c) && ld.status!='Converted'){   
                            Datetime startDate = System.now();
                            Id businessHourId = [SELECT Id FROM BusinessHours Where IsActive=True AND Name='BusHireCallingHours'].id;
                            ld.RnR_Call_Time__c=BusinessHours.add(businessHourId, startDate,7200000);
                            
                            if(ld.RnR_Unsuccessful_Attempts__c==null){
                                ld.status='New RnR';
                            }
                            else
                            {
                                ld.status='RnR'; 
                                ld.RnR_Unsuccessful_Attempts__c = ld.RnR_Unsuccessful_Attempts__c==null?1:ld.RnR_Unsuccessful_Attempts__c+1;
                                ld.Lead_Group__c = 'Group 2';
                            }        
                            
                        }
                        else
                        {
                            if(ld.Call_back_request_time__c <System.now())
                                ld.Call_back_request_time__c =null;                        
                            
                            ld.Call_Ended__c=System.now();
                        }
                    }
                    
                    If(ld.Lead_Group__c=='Group 2'){
                        if('In progress'.equalsIgnoreCase(ld.status))
                        {
                            ld.NextCallDate__c= system.today().addDays(1);
                        }else if('RnR'.equalsIgnoreCase(ld.status))
                        {                   
                            Datetime startDate = System.now();
                            Id businessHourId = [SELECT Id FROM BusinessHours Where IsActive=True AND Name='BusHireCallingHours'].id;
                            if(ld.RnR_Unsuccessful_Attempts__c==1){
                                ld.RnR_Call_Time__c=BusinessHours.add(businessHourId, startDate, 7200000);
                            }else if(ld.RnR_Unsuccessful_Attempts__c==2){
                                ld.RnR_Call_Time__c=BusinessHours.add(businessHourId, startDate, 14400000);
                            }
                           // System.debug('target date on local time =' + ld.RnR_Call_Time__c.format('MM-dd-yyyy ') + ' '+ ld.RnR_Call_Time__c.format('h:mm a'));                                         
                        }
                        System.debug('cinfo status-->'+cInfObj.Call_Status__c);
                        if(!'answered'.equalsIgnoreCase(cInfObj.Call_Status__c)){                    
                            ld.RnR_Unsuccessful_Attempts__c = ld.RnR_Unsuccessful_Attempts__c==null?1:ld.RnR_Unsuccessful_Attempts__c+1;                         
                            if(ld.RnR_Unsuccessful_Attempts__c==3){
                                ld.Status ='Dead lead';
                                ld.Non_Conversion_Reason__c='Customer Unreachable';
                            }
                        }else{
                            if(ld.Call_back_request_time__c <System.now()){
                                ld.Call_back_request_time__c =null;                        
                            }
                            ld.Call_Ended__c=System.now();
                        }
                    }
                    System.debug('age id->'+cInfObj.Agent_ID__c);
                    User_Details__c ud = new User_Details__c();
                    ud = [SELECT id,Last_Call_Start_Time__c,Last_5_Lead_Ids__c,C_Zentrix_Id__c,Last_Call_End_Time__c,Next_Call_Time__c from User_Details__c where C_Zentrix_Id__c=:cInfObj.Agent_ID__c AND CreatedDate=Today];
                    
                    ud.Last_Call_Start_Time__c = cInfObj.call_start_date_time__c;
                    ud.Last_Call_End_Time__c = cInfObj.Call_End_Time__c;
                    ud.Next_Call_Time__c = System.now().addMinutes(1);
                    System.debug('before update..'+ud.Last_5_Lead_Ids__c);
                    
                    ud.Last_5_Lead_Ids__c = String.isBlank(ud.Last_5_Lead_Ids__c)?String.valueOf(ld.id):(String.valueOf(ld.id)+','+ud.Last_5_Lead_Ids__c).length()>94?(String.valueOf(ld.id)+','+ud.Last_5_Lead_Ids__c).left(94):String.valueOf(ld.id)+','+ud.Last_5_Lead_Ids__c;
                    
                    System.debug('After update..'+ud.Last_5_Lead_Ids__c);
                    Database.SaveResult leadUpdateResult = Database.update(ld,false);
                    Database.SaveResult UserDetUpdateResult = Database.update(ud,false);
                    Database.upsertResult updateResult = Database.upsert(cInfObj,CZentrix_Info__c.CustUniqueId__c,false);
                    LeadAssignment la=new LeadAssignment();
                    la.LeadRouting(cInfObj.ownerid,'api');
                    System.debug('leadUpdateResult ..'+leadUpdateResult.isSuccess());
                    System.debug('UserDetUpdateResultt ..'+UserDetUpdateResult.isSuccess()+'..'+UserDetUpdateResult.getErrors());
                    
                    if(updateResult!=null && updateResult.isSuccess())
                    {
                        res.statuscode = 200;
                        resStatus ='Call Details Updated Successfully';             
                    }
                    
                    else
                    {
                        res.statuscode = 417;
                        resStatus = 'Failed To Update Call Details';
                        dbl.Exception_Description__c =string.valueof(updateResult.getErrors());
                    }
                    
                }
                
                else
                {
                    res.statuscode = 400;
                    resStatus = 'Failed To Update Call Details.Received Invalid Input';
                }
                
            }
        }
        
        Catch(Exception e)
        {
            res.statuscode = 400;
            resStatus = 'Failed To Update Call Details';
            dbl.Exception_Description__c = String.valueOf(e);
        }
        
        dbl.Response_Received__c = resStatus;
        insert dbl;
        return resStatus;
    }
}