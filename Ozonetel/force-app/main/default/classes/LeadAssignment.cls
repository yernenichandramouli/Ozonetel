/*
* Name           : LeadAssignment
* Created Date   : 29 Oct 2019
* Created By     : Veeramanikanta R
* Purpose        : Lead assignment 
* Test class     : LeadAssingmnetTest
*/
public class LeadAssignment{
    public list<Lead> listLeads;
    public Id loggedInUserId ; 
    public user uObj;
    public boolean assignmentCall;
    public string loggedInUsername;
    public datetime currentLocalTime;
    public decimal ownerBufferTime;
    public decimal regionBufferTime;
    public string userRegions;
    public list<User_Details__c> listUserDet;

    
    public void LeadRouting(string userId,string path){ 
        currentLocalTime=System.now();
        listUserDet = new List<User_Details__c>();
        BusinessHours bh = [SELECT Id FROM BusinessHours Where IsActive=True AND Name='BusHireCallingHours'];
        Boolean isWithin= BusinessHours.isWithin(bh.id, currentLocalTime);
        if(isWithin){
        uObj=[select id,username,Group__c,Primary__c,Secondary__c,CZentrix_Agent_Id__c from user where id=:userId and isactive=true limit 1]; 
        listUserDet = [SELECT UserId__c,Last_5_Lead_Ids__c,is_Error_Occurred__c,Error_Description__c ,User__r.Phone,Last_Call_Start_Time__c,C_Zentrix_Id__c,Last_Call_End_Time__c,Next_Call_Time__c,User__r.username,User__r.CZentrix_Agent_Id__c,AgentStatus__c from User_Details__c where User__c=:UserInfo.getUserID() AND CreatedDate=Today];

        System.debug('uObj-->'+uObj+'--'+uObj.Primary__c);
        userRegions=uObj.Primary__c+','+uObj.Secondary__c;
        assignmentCall=false;
        ownerBufferTime=decimal.valueof(System.Label.OwnerBufferTime);  
        regionBufferTime=decimal.valueof(System.Label.RegionBufferTime);      
        datetime currentTime=System.now();
        string assignQuery=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='AssignLeadsCheck'].query__c;
        listLeads= (List<lead>)Database.query(assignQuery);
        string region;
        string primRegion=uObj.Primary__c;
        string secRegion=uObj.Secondary__c;
        loggedInUsername=uObj.username;
        //listLeads.size()<=2 && 
        if(listLeads.size()<=2 && uObj.Group__c=='Group 1'){
            listLeads=[select id,status,DOJStart__c,Agent_Mobile__c,Channel__c,Name,NextCallDate__c,owner.name,phone,Call_back_request_time__c,Call_Ended__c,Duration_of_DOJ__c,CB__c,New_Latest_DOJ__c,Priority__c,Previous_Owner__c from lead where status!='Dead lead' limit 2];
            if(!listLeads.isEmpty()){
                GroupQuery(primRegion,secRegion,path); 
            }
            
        }else if(listLeads.size()<=2 && uObj.Group__c=='Group 2'){
            listLeads=[select id,status,DOJStart__c,Agent_Mobile__c,Channel__c,Name,NextCallDate__c,owner.name,phone,Call_back_request_time__c,Call_Ended__c,Duration_of_DOJ__c,CB__c,New_Latest_DOJ__c,Priority__c,Previous_Owner__c,Lead_Group__c from lead where status!='Dead lead' and Lead_Group__c='Group 2' limit 2];
            if(!listLeads.isEmpty()){
                Group2Query(path);
            }
        }else{
           if(ApexPages.currentPage() != null){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'You already having 2 leads in queue'));  
           }
            if(!listUserDet.isEmpty()){
            listUserDet[0].is_Error_Occurred__c = true;
            listUserDet[0].Error_Description__c = 'You already having 2 leads in queue';
            update listUserDet;
            BusHireDialerErrorResetCntrl.resetError(String.valueOf(listUserDet[0].id)); 
            }           
        }
        System.debug('listLeads->'+listLeads);
        }else{
         if(ApexPages.currentPage() != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Non business hours!! Leads does not assign at this moment!!'));           
          }
        }
    }
    
    
    public void GroupQuery(string primRegion,string secRegion,string path){
        datetime currentTime=System.now();
        System.debug('assignmentCall1->'+assignmentCall);
        string leadGroup='Group 1';
        
        /*1. Hot Leads Assignment*/  
        string leadQuery = [SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='LeadGenericQuery'].query__c;
        string queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1Hot'].query__c;
        listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
        for(lead l:listLeads){
           if(!assignmentCall && (l.Previous_Owner__c==uObj.username || (l.Call_Back_Time_In_Mins__c >ownerBufferTime && l.Call_Back_Time_In_Mins__c <regionBufferTime && l.region__c.contains(userRegions)) || l.Call_Back_Time_In_Mins__c >regionBufferTime ) ){                              
                assignmentCall=LeadAssignment(l,path);                 
            }
        }           
        
        /*2. Call Back Leads Assignment */
        if(!assignmentCall){
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1CallBack'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            
            for(Lead l:listLeads){
                if(!assignmentCall && (l.Previous_Owner__c==uObj.username || (l.Call_Back_Time_In_Mins__c >ownerBufferTime && l.Call_Back_Time_In_Mins__c <regionBufferTime && l.region__c.contains(userRegions)) || l.Call_Back_Time_In_Mins__c >regionBufferTime ) ){                              
                   assignmentCall=LeadAssignment(l,path);                 
                }
            }                    
        }
        
        /*3. New Leads Assignment */
        if(!assignmentCall){ 
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1New'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP2'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP3'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP4'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP5'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP6'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP7'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP8'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP9'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP10'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(listLeads.isEmpty()){
                queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewP11'].query__c;
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            
            /*else{   
                queryCond=queryCond.replaceAll('and Creation_Time_in_Mins__c<120', '');
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }  */
            if(!listLeads.isEmpty()){
                assignmentCall=LeadAssignment(listLeads[0],path);    
            }
        }
        
        /*4. New RnR Leads Assignment */
        if(!assignmentCall){ 
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1NewRnR'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            
            if(!listLeads.isEmpty()){
                assignmentCall=LeadAssignment(listLeads[0],path);    
            }
        }
        
        /*5. Re-Open Leads Assignment */
        if(!assignmentCall){ 
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1ReOpen'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
           
            for(Lead l:listLeads){
              if(!assignmentCall && (l.Previous_Owner__c==uObj.username || (l.Call_Back_Time_In_Mins__c >ownerBufferTime && l.Call_Back_Time_In_Mins__c <regionBufferTime && l.region__c.contains(userRegions)) || l.Call_Back_Time_In_Mins__c >regionBufferTime ) ){                              
                   assignmentCall=LeadAssignment(l,path);                 
                }
            }      
        }
        
        /*6. Followup Leads Assignment */
        if(!assignmentCall){ 
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group1Followup'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            if(listLeads.isEmpty()){
                queryCond=queryCond.replaceAll('and (Region__c=:primRegion or Region__c=:secRegion)', '');
                listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            }
            if(!listLeads.isEmpty()){
                assignmentCall=LeadAssignment(listLeads[0],path);    
            }
        }
        
        if(!assignmentCall){ 
         if(ApexPages.currentPage() != null){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'As of now there are no leads are availabel to assign to you')); 
         }
        }
    }
    
    public void Group2Query(string path){
        
        datetime currentTime=System.now();
        System.debug('assignmentCall1->'+assignmentCall);
        string leadQuery = [SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='LeadGenericQuery'].query__c;
        string queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group2Hot'].query__c;
        queryCond=queryCond.replaceAll('and Region__c=:region', '');
        listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
        string leadGroup='Group 2';

        /*1. GFT Cases Assignment*/  
        if(!assignmentCall){
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group2GFTLeads'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            if(!listLeads.isEmpty()){
                assignmentCall=LeadAssignment(listLeads[0],path);    
            }
        }
        
        /*2. Hot Leads Assignment*/             
        for(lead l:listLeads){
            if(!assignmentCall && l.Call_back_request_time__c!=null && (l.Previous_Owner__c==uObj.username || l.Call_Back_Time_In_Mins__c >ownerBufferTime)){               
                assignmentCall=LeadAssignment(l,path);                  
            }
        }    
        
        /*3. Call Back Leads Assignment */
        if(!assignmentCall){
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group2CallBack'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            for(Lead l:listLeads){
                if(!assignmentCall && l.Call_back_request_time__c!=null && (l.Previous_Owner__c==uObj.username || l.Call_Back_Time_In_Mins__c >ownerBufferTime)){               
                    assignmentCall=LeadAssignment(l,path);                  
                }
            }                    
        }
        
        /*4. Followup Leads Assignment */
        if(!assignmentCall){ 
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group2Followup'].query__c;
            queryCond=queryCond.replaceAll('and Region__c=:region', '');
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            if(!listLeads.isEmpty()){
                assignmentCall=LeadAssignment(listLeads[0],path);    
            }
        }
        
        /*5. In Progress Leads Assignment */
        if(!assignmentCall){ 
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group2In_progress'].query__c;
            queryCond=queryCond.replaceAll('and Region__c=:region', '');
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond); 
            if(!listLeads.isEmpty()){
                assignmentCall=LeadAssignment(listLeads[0],path);    
            }
        }
        
        
        /*6. RnR Leads Assignment */
        if(!assignmentCall){            
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group2RnR'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);           
            if(!listLeads.isEmpty()){
                assignmentCall=LeadAssignment(listLeads[0],path);    
            }
        }
      
        /*7. Re-Open Leads Assignment */
        if(!assignmentCall){ 
            queryCond=[SELECT Query__c FROM BusHire_Assignment__mdt WHERE DeveloperName ='Group2ReOpen'].query__c;
            listLeads= (List<lead>)Database.query(leadQuery+' '+queryCond);
            for(Lead l:listLeads){
                if(!assignmentCall && (l.Previous_Owner__c==uObj.username || l.Call_Back_Time_In_Mins__c >ownerBufferTime)){               
                    assignmentCall=LeadAssignment(l,path);                  
                }
            }      
        }   
    }
    
    public boolean LeadAssignment(Lead ld,string path){
        
        Lead led=new Lead();
        led.id=ld.id;
        led.OwnerId =uObj.id;  
        led.Assigned_To__c=uObj.username;
        if(ld.Skip_Validation__c)
            led.Skip_Validation__c=false;
        else
            led.Skip_Validation__c=true; 
        
        User_Details__c ud = new User_Details__c();
        try{
            ud=[SELECT Id,Name,User__c,User__r.Id,User__r.username,First_Login_Time__c, Last_Login_Time__c, Open_Cases_Count__c, Assigned_Cases_Count__c, Team__c, Daily_Assignment_Limit__c, Today_Assignment_Limit__c, Pending_Assignment_Count__c, Assignment_Percentage__c, Assignment_Release_Time__c FROM User_Details__c WHERE First_Login_Time__c=Today AND Team__c='Bus Hire' AND User__r.Id=:uObj.id limit 1];
            ud.Assigned_Cases_Count__c = ud.Assigned_Cases_Count__c+1;
            if(string.isNotBlank(ld.Assignment_Log__c)){
                led.Assignment_Log__c=System.now().addMinutes(330)+'@'+ud.User__r.username+'|'+ld.Assignment_Log__c;
            }else{
                led.Assignment_Log__c=System.now().addMinutes(330)+'@'+ud.User__r.username;  
            }
            update led;
            update ud;
            return true;
        } catch(Exception e){
          if(ApexPages.currentPage() != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Something went wrong!'+e));
            }
            return null;
        }   
    }
}