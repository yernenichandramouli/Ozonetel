/**
 * (c) 2019 RedBus
 *
 * Name           : API_AgentStatusUpdate
 * Created Date   : 18 Jan 2019
 * Created By     : Sreenivas M
 * Purpose        : API to update the agent's C-Zentrix status in Salesforce
 *
 **/
 
@RestResource(urlMapping='/redBus/v1/AgentStatusUpdate')
global without sharing class API_AgentStatusUpdate
{
   
    @HttpPost
    global static Boolean updateAgentStatus()
    {
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c ='Status Change in C-Zentrix';
        Boolean isUpdated =false;
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try
        {
            system.debug('-----------request data serialized debug--------'+req.requestBody.toString());
            dbl.Request_Data__c = String.valueOf(req.requestBody.toString());
            
            if(String.isNotBlank(String.valueOf(req.requestBody.toString())))
            {
                map<string,object> updateDetails = (map<string,object>)JSON.deserializeUntyped(req.requestBody.toString());
                String agentId =updateDetails.containsKey('agentId')?(String)updateDetails.get('agentId'):'';
                   
                if(String.isNotBlank(agentId))
                {
                system.debug('agentId-->>'+agentId);
                        List<User_Details__c> listUserDetails = new List<User_Details__c>();
                       

                        listUserDetails = [Select id,AgentStatus__c,UserId__c from User_Details__c Where C_Zentrix_Id__c=:agentId AND CreatedDate=Today];
                        
                        if(!listUserDetails.isEmpty())
                        {
                            listUserDetails[0].AgentStatus__c = updateDetails.containsKey('agentStatus')?(String)updateDetails.get('agentStatus'):'';
                            listUserDetails[0].CZ_Status_Updated_Hour__c = DateTime.now().hour();
                            if('ready'.equalsIgnoreCase(listUserDetails[0].AgentStatus__c) || 'UnPaused'.equalsIgnoreCase(listUserDetails[0].AgentStatus__c) || 'Progressive'.equalsIgnoreCase(listUserDetails[0].AgentStatus__c))
                            {
                                listUserDetails[0].Next_Call_Time__c = System.now().addMinutes(1);
                                LeadAssignment ldAss = new LeadAssignment();
                                ldAss.LeadRouting(listUserDetails[0].UserId__c,'Agent Status Change');
                                
                            }
                            
                            else
                                listUserDetails[0].Next_Call_Time__c = null;
                            
                            if(listUserDetails[0].AgentStatus__c=='Logoff'){
                               list<lead> ldList=new list<lead>();
                               ldList=[select id,ownerid from lead where ownerid=:listUserDetails[0].UserId__c];
                               Id busComQueue= [Select id from Group where type='Queue' AND developername='BusHire_Common_Pool'].id;
                               Id busHireQueue= [Select id from Group where type='Queue' AND developername='Bus_Hire_Queue'].id;
                               list<lead> ldUpList=new list<lead>();
                               for(lead l:ldList)
                               {
                                  l.ownerid='New'.equalsIgnoreCase(l.status)?busHireQueue:busComQueue;  
                                  ldUpList.add(l);
                               }
                               
                               if(!ldUpList.isEmpty()){
                                    Database.saveResult[] leadUpdateResult = Database.update(ldUplist,false);
                               }                              
                               listUserDetails[0].Assigned_Cases_Count__c=listUserDetails[0].Assigned_Cases_Count__c-ldList.size();
                            }
                            
                            Database.saveResult updateResult = Database.update(listUserDetails[0],false);
                            
                            if(updateResult!=null)
                            {
                                if(updateResult.isSuccess())
                                {
                                    res.statuscode = 200;
                                    isUpdated =true;
                                }
                            }
                        
                            else
                            {
                                res.statuscode = 417;
                                isUpdated =false;
                                dbl.Exception_Description__c =string.valueof(updateResult.getErrors());
                            }
                        }
                    
                }
            
                else
                {
                     res.statuscode = 400;
                     isUpdated = false;
                }
            
            }
        }
        
        Catch(Exception e)
        {
            res.statuscode = 400;
            isUpdated = false;
            dbl.Exception_Description__c = String.valueOf(e);
        }
        
        dbl.Response_Received__c = String.valueOf(isUpdated);
        insert dbl;
        return isUpdated;
    }
   
 }