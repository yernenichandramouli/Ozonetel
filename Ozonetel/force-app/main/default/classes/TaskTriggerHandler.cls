public class TaskTriggerHandler{
    public static void CaseLink(set<string> caseNos,list<task> taskList){
        list<task> tList=new list<task>();
        Map<string,case> caseMap=new Map<string,case>();
        List<case> cList=[select id,casenumber from case where casenumber in:caseNos];
        
        for(case c:cList){
            caseMap.put(c.casenumber,c);
        }
        for(task t:taskList){
            string caseId=t.Description;            
            if(caseMap!=null && caseMap.get(caseId)!=null){
                t.Case_Number__c=caseMap.get(caseId).id;
            }
        }
    }
    
    public static void InboundCallsPush(list<task> TriggerNewLs){
        List<Call_Details__c> cdList=new List<Call_Details__c>();
        set<string> ssUniqueIds=new set<string>();
        for(task ts:TriggerNewLs){
           if(!ssUniqueIds.contains(ts.CrtObjectId__c)){            
            Call_Details__c cd=new Call_Details__c();
            cd.Name=ts.CrtObjectId__c;
            cd.subject__c=ts.subject;
            cd.DispositionType__c=ts.Disposition_Type__c;
            cd.SubDispositionType__c=ts.Sub_Disposition_Type__c;
            cd.Call_Unique_Id__c=ts.CrtObjectId__c;
            cd.Case__c=ts.Case_Number__c;                       
            cd.Created_Time_Value__c=ts.Created_Time_Value__c;
            cd.Comments__c=ts.Description;
            cd.recordingurl__c=ts.recording_url__c;
            cdList.add(cd);  
            ssUniqueIds.add(ts.CrtObjectId__c);
            }               
        }     
        
        if(!cdList.isEmpty()){

            Database.UpsertResult[] upsertResult =Database.upsert(cdList,Call_Details__c.Call_Unique_Id__c,false);
            List<DBLog_Summary__c> dbList=new List<DBLog_Summary__c>();
            for(Integer i=0;i<upsertResult.size();i++){
               if(!upsertResult [i].isSuccess()){
                  system.debug(upsertResult [i]. getErrors());
                   DBLog_Summary__c dbl = new DBLog_Summary__c();
                   dbl.User_Id__c=string.valueOf(cdList[i].Call_Unique_Id__c);
                   dbl.Type__c = 'IVR Inbound Calls Push';
                   dbl.Exception_Description__c=string.valueOf(upsertResult[i].getErrors());
                   dbList.add(dbl);
               }
            }
            if(!dbList.isEmpty()){
                  insert dbList;
            }             
                          
        }
    }
    
  /*  public static void taskUpdate(list<task> TriggerNewLs,set<string> crIds){
        
        Map<string,task> tsMap=new Map<string,task>();
        list<task> tDupList=new list<task>();
        
        for(task t:[select id,CrtObjectId__c,Actual_Talk_Time__c,Agent_ID__c,Agent_Name__c,Call_Duration__c,Call_Remarks__c,Call_Status__c,Call_Type__c,Campaign_Name__c,Channel__c,Cust_Category__c,Cust_Disposition__c,Customer_Name__c,Customer_Ph_No__c,
                    Date_Time__c,DID_Number__c,Disconnected_By__c,Final_Call_Status__c,Hold_Num_Times__c,Hold_Time__c,IVRS_Path__c,List_Name__c,Monitor_File_Name__c,Monitor_File_Path__c,Phone_Type__c,
                    Queue_Time_Secs__c,Redial_Flag__c,Session_ID__c,Skills__c,Transferred_From__c,Transferred_To__c,Wait_Time__c,Wrapped_By__c,Wrapup_Time__c,Case_Number__c,Rating__c from task where CrtObjectId__c in:crIds and createdby.name='CX User']){
                        tsMap.put(t.CrtObjectId__c,t);
                    }
        
        for(task tis:TriggerNewLs){
            if(tsMap!=null && tsMap.get(tis.CrtObjectId__c)!=null){
                task tDt=new task();
                tDt=tsMap.get(tis.CrtObjectId__c);
                tDt.duplicate__c=TRUE;
                
                tis.Actual_Talk_Time__c=tDt.Actual_Talk_Time__c;
                tis.Agent_ID__c=tDt.Agent_ID__c;
                tis.Agent_Name__c=tDt.Agent_Name__c;
                tis.Call_Duration__c=tDt.Call_Duration__c;
                tis.Call_Remarks__c=tDt.Call_Remarks__c;
                tis.Call_Status__c=tDt.Call_Status__c;
                tis.Call_Type__c=tDt.Call_Type__c;
                tis.Campaign_Name__c=tDt.Campaign_Name__c;
                tis.Channel__c=tDt.Channel__c;
                tis.Cust_Category__c=tDt.Cust_Category__c;
                tis.Cust_Disposition__c=tDt.Cust_Disposition__c;
                tis.Customer_Name__c=tDt.Customer_Name__c;
                tis.Customer_Ph_No__c=tDt.Customer_Ph_No__c;
                tis.Date_Time__c=tDt.Date_Time__c; 
                tis.DID_Number__c=tDT.DID_Number__c;
                tis.Disconnected_By__c=tDT.Disconnected_By__c;
                tis.Final_Call_Status__c=tDT.Final_Call_Status__c;
                tis.Hold_Num_Times__c=tDT.Hold_Num_Times__c;
                tis.Hold_Time__c=tDT.Hold_Time__c;
                tis.IVRS_Path__c=tDT.IVRS_Path__c;
                tis.List_Name__c=tDT.List_Name__c;
                tis.Monitor_File_Name__c=tDT.Monitor_File_Name__c;
                tis.Monitor_File_Path__c=tDT.Monitor_File_Path__c;
                tis.Phone_Type__c=tDT.Phone_Type__c;
                tis.Queue_Time_Secs__c=tDT.Queue_Time_Secs__c;
                tis.Redial_Flag__c=tDT.Redial_Flag__c;
                tis.Session_ID__c=tDT.Session_ID__c;
                tis.Skills__c=tDT.Skills__c;
                tis.Transferred_From__c=tDT.Transferred_From__c;
                tis.Transferred_To__c=tDT.Transferred_To__c;
                tis.Wait_Time__c=tDT.Wait_Time__c;
                tis.Wrapped_By__c=tDT.Wrapped_By__c;
                tis.Wrapup_Time__c=tDT.Wrapup_Time__c;
                tis.Case_Number__c=tDT.Case_Number__c;
                tis.Rating__c = tDT.Rating__c;
                
                tDupList.add(tDt);
            }
        }        
        
        if(!tDupList.isEmpty()){
            update tDupList;
        }       
    }   */
}