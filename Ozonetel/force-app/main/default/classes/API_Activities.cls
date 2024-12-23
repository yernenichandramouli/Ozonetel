/*
* Name           : API_Activities
* Created Date   : 28 Feb 2019
* Created By     : Veeramanikanta R
* Purpose        : API for to store all activiteis information
* Test class     : API_ActivitiesTest
*/
@RestResource(urlMapping='/redBus/Activities/*')
global without sharing class API_Activities
{   
    static list<string> actOrderItemsIds= new list<string>();
    static list<string> orderIds=new list<string>();
    static list<DB_Log__c> DBLog = new list<DB_Log__c>();
    static list<string> orderItemFailedPro = new list<string>();
    static Set<String> setSuccessOritems=new set<String>();
    static Datetime received = system.now();

    @HttpPost
    global static Response LoadActivities()
    { 
        Response resp=new Response();        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug('-----------data--------'+req.requestBody.toString());
        String jsonBody=req.requestBody.toString();
        Map<String,String> fieldMapper = new Map<String,String>();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        Map<String,String> mapActUuidToTransId= new Map<String,String>();
        Map<String,String> mapTransUuidToSfId = new Map<String,String>();
        
        try{
            
            for(Update_Mapper__mdt mapper : [Select MasterLabel,reqName__c,DeveloperName,Field_API_Name__c,Object_API_Name__c,isActive__c,Usage__c from Update_Mapper__mdt WHERE isActive__c=true AND Object_API_Name__c='Activities__c' AND Usage__c='Activities'])
                fieldMapper.put(mapper.reqName__c,mapper.Field_API_Name__c);
            
         
            map<string,object> activitiesMap = (map<string,object>)JSON.deserializeUntyped(jsonBody);
            list<object> orderItemsList = (list<object>)activitiesMap.get('activities');
            List<Activities__c> oList=new List<Activities__c>();
            Set<String> setString = new Set<String>{'STRING','PICKLIST','MULTIPICKLIST','EMAIL','TEXTAREA','PHONE','ENCRYPTEDSTRING'};
            List<Order_Items__c> listOrderItems = new List<Order_Items__c>();
            Set<String> setOrderItemIds = new Set<String>();
            
            for(object obj:orderItemsList)
            {
                    Activities__c act = new Activities__c();
                   
                    map<string,object> orIt = (map<string,object>)(obj);
                  
                    string activityId=string.valueof(orIt.get('id'));
                    string orderId=string.valueOf(orIt.get('orderId'));
                                        
                    string tempS;
                    
                    for(String lb :fieldMapper.keySet())
                    {
                        tempS=string.valueOf(orIt.get(lb));
                                                
                        if(orIt.containsKey(lb) && String.isNotBlank(tempS)) 
                        {
                            
                            String fValue=tempS;
                            String fType = String.valueOf(Schema.getGlobalDescribe().get('Activities__c').getDescribe().fields.getMap().get(fieldMapper.get(lb)).getDescribe().getType());
                          
                            
                            if('INTEGER'.equalsIgnoreCase(fType))
                                act.put(fieldMapper.get(lb),Integer.valueOf(fValue));
                            else if('DOUBLE'.equalsIgnoreCase(fType) || 'CURRENCY'.equalsIgnoreCase(fType))
                                act.put(fieldMapper.get(lb),Double.valueOf(fValue));
                            else if(setString.contains(fType))
                                act.put(fieldMapper.get(lb),String.valueOf(fValue));
                            else if('BOOLEAN'.equalsIgnoreCase(fType))
                                act.put(fieldMapper.get(lb),Boolean.valueOf(fValue));
                            else if('DATE'.equalsIgnoreCase(fType))
                                act.put(fieldMapper.get(lb),Date.valueOf(fValue));
                            else if('DATETIME'.equalsIgnoreCase(fType)){                            
                                if(fValue.contains('T'))
                                {                                     
                                    fValue=string.valueOf(datetime.valueof(fValue.replace('T',' ')));
                                }
                                act.put(fieldMapper.get(lb),DateTime.valueOf(fValue));
                            }
                            /*
                            else if('REFERENCE'.equalsIgnoreCase(fType) && 'orderItem'.equalsIgnoreCase(lb) && String.isNotBlank(fValue))
                            {
                                System.debug('inside the reference..'+fType+'..'+lb+'..'+fValue);
                                Order_Items__c trans = new Order_Items__c();
                                trans.Id__c = fValue;                                
                                act.Order_Item__r = trans;
                                mapActUuidToTransUuid.put(activityId,fValue);
                                
                                System.debug('Activity with tran...before--'+act);
                                System.debug('Activity with tran...after--'+act.Order_Item__r); 
                                
                                if(!setOrderItemIds.contains(fValue))
                                {
                                    listOrderItems.add(trans);
                                    setOrderItemIds.add(fValue);
                                }
                            }*/
                            else
                            {
                                
                            }
                        }                    
                    }
                    
                    if(String.isNotBlank(act.Order_Item_id__c))
                    {
                        mapActUuidToTransId.put(activityId,act.Order_Item_id__c);
                    }
                    actOrderItemsIds.add(activityId);   
                    orderIds.add(orderId);                    
                    oList.add(act);
             }
            if(!oList.isEmpty())
            {               
                
                if(!mapActUuidToTransId.isEmpty())
                {
                    list<Order_Items__c> listFinalTrans = new List<Order_Items__c>();
                    for(String tranId :mapActUuidToTransId.values())
                    {
                        Order_Items__c trans = new Order_Items__c();
                        trans.Name = tranId;
                        trans.Id__c = tranId;
                        listFinalTrans.add(trans);
                    }   
                    Database.UpsertResult[] ItemUpsertResult = Database.upsert(listFinalTrans,Order_Items__c.ID__c,false);
                    
                    for(Order_Items__c trn : [SELECT id,ID__c from Order_Items__c WHERE ID__C IN :mapActUuidToTransId.values()])
                    {
                        mapTransUuidToSfId.put(trn.ID__c,trn.id);
                    }
                }
               
                List<Activities__c> listFinalAct = new List<Activities__c>();
                for(Activities__c actObj : oList)
                {
                    if(mapActUuidToTransId.containsKey(actObj.id__c) && mapTransUuidToSfId.containsKey(mapActUuidToTransId.get(actObj.id__c)))
                    {
                        actObj.Order_Item__c = ID.valueOf(mapTransUuidToSfId.get(mapActUuidToTransId.get(actObj.id__c)));
                    }
                    listFinalAct.add(actObj);
                     
                }
                Database.UpsertResult[] upsertResult = Database.upsert(oList,Activities__c.ID__c,false);
                
                list<string> successOrdersList=new list<string>();
                list<string> failedOrdersList=new list<string>();
                list<string> SuccessList = new list<string>();
                list<string> FailedList = new list<string>();
                list<string> FailedDesscList = new list<string>();
                for(Integer i=0;i<upsertResult.size();i++)
                {
                    
                    if (upsertResult.get(i).isSuccess())
                    {
                        SuccessList.add(actOrderItemsIds[i]);
                        successOrdersList.add(orderIds[i]);
                    }
                    else if(!upsertResult.get(i).isSuccess())
                    {
                        DB_Log__c DB = new DB_Log__c();                       
                        DB.Object_Name__c = 'Activities';
                        DB.Lock_type__c = 'Activity Data process';
                        DB.ID__c = string.valueof(actOrderItemsIds[i]);     
                        DB.Error_Description__c = string.valueof(upsertResult.get(i).getErrors());
                        if(DB.Error_Description__c.Contains('getStatusCode=INVALID_FIELD'))
                        {
                            DB.Locked_record__c = false;
                        }
                        DBLog.add(DB);
                        FailedList.add(actOrderItemsIds[i]);
                        failedOrdersList.add(orderIds[i]);
                        FailedDesscList.add(string.valueof(upsertResult.get(i).getErrors()));
                        orderItemFailedPro.add(JSON.Serialize(actOrderItemsIds[i]));
                    }
                }
                resp.orderItemsSuccess = SuccessList;
                resp.orderItemsSuccessCount = SuccessList.size();
                resp.orderItemsFailed = FailedList;
                resp.orderItemsFailedCount = FailedList.size();
                resp.orderItemsFailDescription = FailedDesscList;
                if(actOrderItemsIds.size()==SuccessList.size())
                {
                    resp.orderItemsProcessStatus = 'Success';
                }
                else if(actOrderItemsIds.size()==FailedList.size())
                {
                    resp.orderItemsProcessStatus = 'Fail';
                }
                else
                {
                    resp.orderItemsProcessStatus = 'Partial';
                }                
                setSuccessOritems.addAll(SuccessList);  
                dbl.redBus_SentAt__c = string.valueof(activitiesMap.get('sentAt'));
                dbl.SentAt__c = received;  
                dbl.Type__c='Activity Booking';             
                dbl.Order_Items_Success__c = string.join(SuccessList,',');
                dbl.Orders_Success__c=string.join(successOrdersList,',');
                dbl.Orders_Failed__c=string.join(failedOrdersList,',');
                dbl.Order_Items_Success_Count__c = SuccessList.size();
                dbl.Order_Items_Failed__c = string.join(FailedList,',');
                dbl.Order_Items_Failed_Count__c = FailedList.size();
                if( !string.isBlank(string.valueof(string.join(FailedDesscList,','))) && string.valueof(string.join(FailedDesscList,',')).length()>25000)
                {
                    dbl.Order_Items_Fail_Description__c = string.valueof(string.join(FailedDesscList,',')).substring(0,24000);
                }
                else
                {
                    dbl.Order_Items_Fail_Description__c = string.join(FailedDesscList,',');
                }                
                dbl.Order_Items_Process_Status__c = resp.orderItemsProcessStatus;
            }
             database.insert(dbl);
             string DBLoagID;
             if(!string.isBlank(string.valueof(dbl.id)))
            {
                DBLoagID = dbl.id;
                if(!DBLog.isEmpty())
                {
                    for(integer i=0; i<DBLog.size(); i++)
                    {
                        DBLog[i].DBLog_Summary__c = dbl.id;
                    }
                    database.insert(DBLog);
                }
                Attachment att = new Attachment();
                att.name = 'Activity Data';
                att.Body = blob.valueof(req.requestBody.toString());
                att.ParentId = dbl.id;
                database.insert(att);
            }                      
        }catch(Exception e){
            resp = new response();
            resp.exceptionDescription = string.valueof(e);
            resp.exceptionTableName = 'Order Items-Activities';
            //resp.exceptionId = ProcessExceptionId;
        }
        return resp;
    }   
    
    global class Response{
        string exceptionDescription;
        string exceptionTableName;
        string exceptionId;
        list<string> orderItemsSuccess;
        integer orderItemsSuccessCount;
        list<string> orderItemsFailed;
        integer orderItemsFailedCount;
        list<string> orderItemsFailDescription;
        string orderItemsProcessStatus;        
    }                     
}