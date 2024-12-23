/**
 * (c) 2018 RedBus
 *
 * Name           : API_UpdateCase
 * Created Date   : 25 May 2018
 * Created By     : Sreenivas M
 * Purpose        : API to create bus cancellation cases from RB+ and SeatSeller
 *
 **/
 
@RestResource(urlMapping='/redBus/updateCase/*')
global without sharing class API_UpdateCase
{
   
    @HttpPost
    global static Response doPost()
    {
        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c ='Update Case Deatils';
        Response resp = new Response();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try
        {
            system.debug('-----------request data serialized debug--------'+req.requestBody.toString());
            dbl.Request_Data__c = String.valueOf(req.requestBody.toString());
            
            if(String.isNotBlank(String.valueOf(req.requestBody.toString())))
            {
              
               map<string,object> updateDetails = (map<string,object>)JSON.deserializeUntyped(req.requestBody.toString());
               
               String caseNum =updateDetails.containsKey('caseNumber')?(String)updateDetails.get('caseNumber'):'';
               if(String.isNotBlank(caseNum))
               {
                  Set<String> setString = new Set<String>{'STRING','PICKLIST','MULTIPICKLIST','EMAIL','TEXTAREA','PHONE','ENCRYPTEDSTRING'};
                  Case cs = new Case();
                  Case updateCase = new Case();
                
                  cs =[Select id,Channel_ct__c,status from Case Where CaseNumber=:caseNum LIMIT 1 FOR UPDATE];
                  
                  if('Simplify360'.equalsIgnoreCase(cs.Channel_ct__c) && cs.status!='Closed'){
                        res.statuscode = 400;
                        resp.isSuccess = 'false';
                        resp.caseNum = caseNum;
                        resp.error ='Invalid Input Received';
                        resp.errorDescription ='Case is not in Closed status';
                        
                        return resp;
                  } 
                                 
                  updateCase.Id = cs.id;
                  
                  Map<String,String> fieldMapper = new Map<String,String>();
                  
                  for(Update_Mapper__mdt mapper : [Select MasterLabel,DeveloperName,Field_API_Name__c,Object_API_Name__c,isActive__c,Usage__c from Update_Mapper__mdt WHERE isActive__c=true AND Object_API_Name__c='Case' AND Usage__c='NEFT'])
                       fieldMapper.put(mapper.MasterLabel,mapper.Field_API_Name__c);
                            
                    for(String lb :fieldMapper.keySet())
                    {
                        if(updateDetails.containsKey(lb) && String.isNotBlank((String)updateDetails.get(lb))) 
                        {
                            String fValue = (String)updateDetails.get(lb);
                            String fType = String.valueOf(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(fieldMapper.get(lb)).getDescribe().getType());
                            
                            if('INTEGER'.equalsIgnoreCase(fType))
                                updateCase.put(fieldMapper.get(lb),Integer.valueOf(fValue));
                            else if('DOUBLE'.equalsIgnoreCase(fType) || 'CURRENCY'.equalsIgnoreCase(fType))
                                updateCase.put(fieldMapper.get(lb),Double.valueOf(fValue));
                            else if(setString.contains(fType))
                                updateCase.put(fieldMapper.get(lb),String.valueOf(fValue));
                            else if('BOOLEAN'.equalsIgnoreCase(fType))
                                updateCase.put(fieldMapper.get(lb),Boolean.valueOf(fValue));
                            else
                            {
                                
                            }
                        }

                    }
                    
                    Database.saveResult updateResult = Database.update(updateCase,false);
                    if(updateResult!=null)
                    {
                        if(updateResult.isSuccess())
                        {
                            res.statuscode = 200;
                            resp.isSuccess = 'true';
                            resp.caseNum = caseNum;
                            resp.error ='';
                            resp.errorDescription ='';
                        }
                        else
                        {
                            res.statuscode = 417;
                            resp.isSuccess = 'false';
                            resp.caseNum = caseNum;
                            resp.error ='Update Has Failed';
                            resp.errorDescription =string.valueof(updateResult.getErrors());
                        }
                    }
               }
               else
               {
                 res.statuscode = 400;
                 resp.isSuccess = 'false';
                 resp.caseNum = caseNum;
                 resp.error ='Invalid Input Received';
                 resp.errorDescription ='Case Number is Missing/Coming as Blank in Request';
                 
               }
            }
        }
        Catch(Exception e)
        {
            res.statuscode = 400;
            resp.isSuccess = 'false';
            resp.error ='Unable To Process The Request.';
            resp.errorDescription =string.valueof(e);
        }
        dbl.Response_Received__c = String.valueOf(resp);
        insert dbl;
        return resp;
    }
   
    global class response
    {
        string caseNum;
        String isSuccess;
        string error;
        String errorDescription;
        public response()
        {


        }
    }
}