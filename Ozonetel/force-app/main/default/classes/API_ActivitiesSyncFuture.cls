/*
* Name           : API_ActivitiesSyncFuture
* Created Date   : 28 July 2023
* Created By     : Sreenivas M
* Purpose        : API for to store all activities information
* Test class     : API_ActivitiesTest
*/
global without sharing class API_ActivitiesSyncFuture
{   
    @future(callout=false)
    global static void processActivities(String reqType,String jsonAddonBody)
    { 
        system.debug('-----------Req Body--------'+jsonAddonBody);
        Map<String,String> fieldMapper = new Map<String,String>();
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        Map<String,String> mapActIdOrderId= new Map<String,String>();
        
        try{
            
            for(Update_Mapper__mdt mapper : [Select MasterLabel,reqName__c,DeveloperName,Field_API_Name__c,Object_API_Name__c,isActive__c,Usage__c from Update_Mapper__mdt WHERE isActive__c=true AND Object_API_Name__c='Activities__c' AND Usage__c='Activities'])
                fieldMapper.put(mapper.reqName__c,mapper.Field_API_Name__c);
            
          //  list<object> listAddonsObj = (list<object>)JSON.deserializeStrict(jsonAddonBody,List<object>.class);

            map<string,object> activitiesMap = (map<string,object>)JSON.deserializeUntyped(jsonAddonBody);
            list<object> listAddons = (list<object>)activitiesMap.get('addonItems');
            List<Activities__c> listAddonToUpsert=new List<Activities__c>();
            Set<String> setString = new Set<String>{'STRING','PICKLIST','MULTIPICKLIST','EMAIL','TEXTAREA','PHONE','ENCRYPTEDSTRING'};
            map<string,Orders__c> mapexiOrders = new Map<string,Orders__c>();
            map<string,Order_Items__c> mapexiItems = new Map<string,Order_Items__c>();
            list<string> actOrderItemsIds= new list<string>();
                       
            for(object obj:listAddons)
            {
                    Activities__c act = new Activities__c();                   
                    map<string,object> orIt = (map<string,object>)(obj);
                    
                    string activityId=string.valueof(orIt.get('id'));
                    string orderId=string.valueOf(orIt.get('orderId'));
                                                            
                    for(String lb :fieldMapper.keySet())
                    {                      
                        if(orIt.containsKey(lb) && string.isNotBlank(string.valueOf(orIt.get(lb))))
                         {   
                            String fValue=string.valueOf(orIt.get(lb));
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
                          
                            else
                            {
                                
                            }
                            
                           }
                                          
                    }
                    
                    if((String.ValueOf(act.Business_Unit__c)=='REDBUS_PE' || String.ValueOf(act.Business_Unit__c)=='REDBUS_CO') && String.isNotBlank(act.Item_Type__c) && String.ValueOf(act.Item_Type__c)=='GENERIC_ITEM'){
                          act.RecordTypeId=Schema.getGlobalDescribe().get('Activities__c').getDescribe().getRecordTypeInfosByName().get('Cargo').getRecordTypeId();
                    }
                    
                    if( String.isNotBlank(act.Business_Unit__c) && (String.ValueOf(act.Business_Unit__c)=='REDBUS_ONDC' || String.ValueOf(act.Business_Unit__c)=='REDBUS_ONDC_METRO') && String.isNotBlank(act.Item_Type__c) && String.ValueOf(act.Item_Type__c)=='GENERIC_ITEM'){
                          act.RecordTypeId=Schema.getGlobalDescribe().get('Activities__c').getDescribe().getRecordTypeInfosByName().get('ONDC Metro').getRecordTypeId();
                    }

                    if((String.ValueOf(act.Business_Unit__c)=='REDBUS_SG' || String.ValueOf(act.Business_Unit__c)=='REDBUS_MY') && String.isNotBlank(act.Item_Type__c) && String.ValueOf(act.Item_Type__c)=='ACTIVITY'){
                        act.RecordTypeId=Schema.getGlobalDescribe().get('Activities__c').getDescribe().getRecordTypeInfosByName().get('SGMY Activites').getRecordTypeId();
                    }

                    if( String.isNotBlank(act.Business_Unit__c) && String.ValueOf(act.Business_Unit__c)=='REDBUS_ONDC_MOBILITY' && String.isNotBlank(act.Item_Type__c) && String.ValueOf(act.Item_Type__c)=='GENERIC_ITEM' && String.isNotBlank(act.Activity_Category__c) && String.ValueOf(act.Activity_Category__c)=='AUTO_TICKETING'){
                        act.RecordTypeId=Schema.getGlobalDescribe().get('Activities__c').getDescribe().getRecordTypeInfosByName().get('ONDC Mobility').getRecordTypeId();

                        if(test.isRunningTest()){
                            act.Additional_Details__c='{"bapId":"rb-ondc-auto.redbus.in","bapUri":"https://rb-ondc-auto.redbus.in","bppId":"api.beckn.juspay.in/dobpp/beckn/7f7896dd-787e-4a0b-8675-e9e6fe93bb8f","bppUri":"https://api.beckn.juspay.in/dobpp/beckn/7f7896dd-787e-4a0b-8675-e9e6fe93bb8f","city":"bangalore","ondcCity":"std:080","ondcOrderId":"4f220688-fd57-4b50-b161-2e89c071e615","ondcOrderStatus":"ACTIVE","ondcRideStatus":"RIDE_ASSIGNED","ondcTxnId":"7f681754-965c-4cf2-9d2c-208854bed08c","providerId":"api.beckn.juspay.in/dobpp/beckn/7f7896dd-787e-4a0b-8675-e9e6fe93bb8f","providerName":"Namma Yatri","rideDetails":{"driverContactNo":"9108168706","driverName":"NAYAZ PASHA","otp":"7396","vehicleCategory":"AUTO_RICKSHAW","vehicleMake":"","vehicleModel":"2023-04","vehicleRegistration":"KA05AM7738"},"rideEvents":{"RIDE_ASSIGNED":"2024-07-22T16:52:49"},"sessionId":"zo9n9z7134","ticketDetails":{"boardingPointDetails":{"address":{"addressLine1":"XHHC+442","addressLine2":"Kempegowda, Sevashrama, Bengaluru, Karnataka 560023, India"},"landMark":"XHHC+442, Kempegowda, Sevashrama, Bengaluru, Karnataka 560023, India","location":{"lat":12.97832,"lon":77.570137},"time":""},"droppingPointDetails":{"address":{"addressLine1":"XHHC+442","addressLine2":"Kempegowda, Sevashrama, Bengaluru, Karnataka 560023, India"},"landMark":"XHHC+442, Kempegowda, Sevashrama, Bengaluru, Karnataka 560023, India","location":{"lat":12.97832,"lon":77.570137}}},"vehicleCategory":"AUTO_RICKSHAW","vehicleVariant":"AUTO_RICKSHAW"}';
                        }
                        if(string.isNotBlank(act.Additional_Details__c)){
                            Map<string,object> additionalDetailsMap = (Map<string,object>)JSON.deserializeUntyped(act.Additional_Details__c);
                            if (additionalDetailsMap.containsKey('rideDetails')) {
                                Map<String, Object> rideDetails = (Map<String, Object>) additionalDetailsMap.get('rideDetails');
                                if (rideDetails.containsKey('driverContactNo')) {
                                    act.Driver_Contact_No__c = (String) rideDetails.get('driverContactNo');
                                }
                                if (rideDetails.containsKey('driverName')) {
                                    act.Driver_Name__c = (String) rideDetails.get('driverName');
                                }
                                if (rideDetails.containsKey('otp')) {
                                    act.Otp__c = (String) rideDetails.get('otp');
                                }
                                if (rideDetails.containsKey('vehicleCategory')) {
                                    act.Vehicle_Category__c = (String) rideDetails.get('vehicleCategory');
                                }
                                if (rideDetails.containsKey('vehicleMake')) {
                                    act.Vehicle_Company__c = (String) rideDetails.get('vehicleMake');
                                }
                                if (rideDetails.containsKey('vehicleModel')) {
                                    act.Vehicle_Model__c = (String) rideDetails.get('vehicleModel');
                                }
                                if (rideDetails.containsKey('vehicleRegistration')) {
                                    act.Vehicle_Registration__c = (String) rideDetails.get('vehicleRegistration');
                                }
                            }

                            if (additionalDetailsMap.containsKey('ticketDetails')) {
                                Map<String, Object> ticketDetails = (Map<String, Object>) additionalDetailsMap.get('ticketDetails');
                                if (ticketDetails.containsKey('boardingPointDetails')) {
                                    Map<String, Object> boardingPointDetails = (Map<String, Object>) ticketDetails.get('boardingPointDetails');
                                    if (boardingPointDetails.containsKey('landMark')) {
                                        act.Boarding_Point__c = (String) boardingPointDetails.get('landMark');
                                    }
                                }

                                if (ticketDetails.containsKey('droppingPointDetails')) {
                                    Map<String, Object> drpPointDetails = (Map<String, Object>) ticketDetails.get('droppingPointDetails');
                                    if (drpPointDetails.containsKey('landMark')) {
                                        act.Dropping_Point__c = (String) drpPointDetails.get('landMark');
                                    }
                                }
                            }
                        }
                    }

                    if(String.isNotBlank(act.Order_Id__c))
                    {
                        if(!mapexiOrders.containsKey(act.Order_Id__c))
                        {
                            Orders__c ord = new Orders__c(id__c = act.Order_Id__c,name=act.Order_Id__c);
                            mapexiOrders.put(act.Order_Id__c,ord);
                        }
                        act.Order__r = new Orders__c(id__c =  act.Order_Id__c);
                    }
                    if(String.isNotBlank(act.Order_Item_id__c))
                    {
                        if(!mapexiItems.containsKey(act.Order_Item_id__c))
                        {
                            Order_Items__c item = new Order_Items__c(id__c = act.Order_Item_id__c,name=act.Order_Item_id__c);
                            mapexiItems.put(act.Order_Item_id__c,item);
                        }
                        act.Order_Item__r = new Order_Items__c(ID__c = act.Order_Item_id__c);

                    }
                    actOrderItemsIds.add(activityId);   
                    mapActIdOrderId.put(activityId,orderId);                    
                    listAddonToUpsert.add(act);
            }
            
            if(!listAddonToUpsert.isEmpty())
            {               
                
                if(!mapexiOrders.isEmpty())
                    Database.UpsertResult[] ordersUpsertResult = Database.upsert(mapexiOrders.values(),Orders__c.ID__c,false);
                    
                if(!mapexiItems.isEmpty()) 
                    Database.UpsertResult[] ItemUpsertResult = Database.upsert(mapexiItems.values(),Order_Items__c.ID__c,false);
                               
                Database.UpsertResult[] upsertResult = Database.upsert(listAddonToUpsert,Activities__c.ID__c,false);
                
                set<string> orderSuccessList=new set<string>();
                set<string> orderFailedList=new set<string>();
                set<string> addonSuccessList = new set<string>();
                set<string> addonFailedList = new set<string>();
                list<string> FailedDesscList = new list<string>();
                list<DB_Log__c> DBLog = new List<DB_Log__c>();
                for(Integer i=0;i<upsertResult.size();i++)
                {
                    
                    if (upsertResult.get(i).isSuccess())
                    {
                        addonSuccessList.add(actOrderItemsIds[i]);
                        orderSuccessList.add(mapActIdOrderId.get(actOrderItemsIds[i]));
                    }
                    else
                    {
                        addonFailedList.add(actOrderItemsIds[i]);
                        orderFailedList.add(mapActIdOrderId.get(actOrderItemsIds[i]));
                        
                        DB_Log__c DB = new DB_Log__c();                       
                        DB.Object_Name__c = 'Activities';
                        DB.Lock_type__c = 'Activity Future Data process';
                        DB.ID__c = string.valueof(actOrderItemsIds[i]);     
                        DB.Error_Description__c = string.valueof(upsertResult.get(i).getErrors());
                        
                        if(String.isNotBlank(DB.Error_Description__c))
                             DB.Error_Status_Code__c = string.valueof(upsertResult.get(i).getErrors()[0].getStatusCode());
                        
                        if(DB.Error_Description__c.Contains('getStatusCode=INVALID_FIELD'))
                        {
                            DB.Locked_record__c = false;
                        }
                        DBLog.add(DB);
                    }
                }
                
                dbl.redBus_SentAt__c = string.valueof(System.now());
                dbl.SentAt__c = System.now();  
                dbl.Type__c='Activity Booking Future'; 
                
                dbl.Order_Items_Success__c = string.join(addonSuccessList,',');
                dbl.Order_Items_Success_Count__c = addonSuccessList.size();
                
                dbl.Order_Items_Failed__c = string.join(addonFailedList,',');
                dbl.Order_Items_Failed_Count__c = addonFailedList.size();
                
                dbl.Orders_Success__c=string.join(orderSuccessList,',');
                dbl.Orders_Failed__c=string.join(orderFailedList,',');
               
                database.insert(dbl);
            
                if(string.isNotBlank(string.valueof(dbl.id)))
                {
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
                    att.Body = blob.valueof(jsonAddonBody);
                    att.ParentId = dbl.id;
                    database.insert(att);
                }      
            }                
        }
        catch(Exception e){
            System.debug(':: Exception occured at '+e.getLineNumber()+' and the error message is = '+e.getMessage());
        }
    }   
                   
}