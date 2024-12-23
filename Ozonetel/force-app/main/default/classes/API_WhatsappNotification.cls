@RestResource(urlMapping='/redBus/sendWhatsappNotification/*')
global without sharing class API_WhatsappNotification
{
    
    @HttpPost
    global static Response doPost()
    {        
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c ='Whatsapp Notification';
        Response resp = new Response();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try
        {
            system.debug('-----------request data serialized debug--------'+req.requestBody.toString());
            dbl.Request_Data__c = String.valueOf(req.requestBody.toString());
            
            if(String.isNotBlank(String.valueOf(req.requestBody.toString())))
            {
                string jsBody;
                jsBody=req.requestBody.toString();
                map<string,object> reqMap = (map<string,object>)JSON.deserializeUntyped(jsBody);        
                object msgObj=reqMap.get('MessageDetails');
                System.debug('ss-->'+JSON.serializePretty(msgObj));
                map<string,object> msgMap = (map<string,object>)JSON.deserializeUntyped(JSON.serializePretty(msgObj));
                system.debug('updateDetails2-->'+msgMap.get('DataJsonStr'));
                string msgMapStr=string.valueOf(msgMap.get('DataJsonStr'));
                system.debug('msgMapStr--->'+msgMapStr);
                map<string,object> updateDetails = (map<string,object>)JSON.deserializeUntyped(msgMapStr);
                string countryName;
                countryName = String.isNotBlank(String.valueOf(msgMap.get('countryName')))?String.valueOf(msgMap.get('countryName')):'MYS';
                Set<String> setString = new Set<String>{'STRING','PICKLIST','MULTIPICKLIST','EMAIL','TEXTAREA','PHONE','ENCRYPTEDSTRING'};
                    Map<String,String> fieldMapper = new Map<String,String>();
                Whatsapp_Notifications__c wnObj=new Whatsapp_Notifications__c();
                for(Update_Mapper__mdt mapper : [Select MasterLabel,reqName__c,DeveloperName,Field_API_Name__c,Object_API_Name__c,isActive__c,Usage__c from Update_Mapper__mdt WHERE isActive__c=true AND Object_API_Name__c='Whatsapp_Notifications__c'])
                    fieldMapper.put(mapper.reqName__c,mapper.Field_API_Name__c);
                
                string custWANum='whatsapp:+'+(String)updateDetails.get('WhatsAppNumber');
                wnObj.Customer_Phone_No__c='+'+(String)updateDetails.get('WhatsAppNumber');
                wnObj.Template_Name__c=String.valueOf(msgMap.get('TemplateName'));
                wnObj.Country__c=countryName;
                List<MessagingEndUser> msgUserList=new List<MessagingEndUser>();
                map<string,object> resObj = new map<string,object>();
                //
                List<String> enhancedTemplatesList = new List<String>();
                enhancedTemplatesList.addAll(System.Label.enhancedMessagingTemplates.split(','));
                if(enhancedTemplatesList.contains(String.valueOf(msgMap.get('TemplateName')))){
                    resObj=(map<string,object>)JSON.deserializeUntyped(system.label.WAEnhancedMessagingChannel);
                }else{
                    resObj= (map<string,object>)JSON.deserializeUntyped(system.label.WAMessagingChannel);
                }
                //
                system.debug('::: resObj ::: '+resObj);
                string getChannel=string.valueOf(resObj.get(wnObj.Country__c));
                system.debug('::: getChannel ::: '+getChannel);
                msgUserList=[select id, MessagingConsentStatus from MessagingEndUser where MessagingPlatformKey=:custWANum AND MessagingChannel.DeveloperName=:getChannel];
                if(msgUserList.isEmpty()){
                List<MessagingChannel> msgChannel=new List<MessagingChannel>();
                    msgChannel=[select id,DeveloperName from MessagingChannel where DeveloperName=:getChannel];
                    MessagingEndUser objMsgUser = new MessagingEndUser();
                    objMsgUser.MessagingChannelId = msgChannel[0].id;
                    objMsgUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
                    objMsgUser.MessageType = 'WhatsApp';//For SMS Channel
                    objMsgUser.MessagingPlatformKey = 'whatsapp:+'+(String)updateDetails.get('WhatsAppNumber');
                    objMsgUser.Name = 'whatsapp:+'+(String)updateDetails.get('WhatsAppNumber');
                    Database.saveResult insertResult = Database.insert(objMsgUser,false);
                    if(insertResult.isSuccess()){
                        wnObj.Messaging_User__c=objMsgUser.id;
                    }
                    if(!insertResult.isSuccess()){
                    try{
                        if('DUPLICATE_VALUE'.equals(string.valueof(insertResult.getErrors()[0].getStatusCode()))){
                            string DuplicateId = string.valueof(insertResult.getErrors()[0].getMessage().right(15));
                            system.debug(':: DuplicateId ::: '+DuplicateId);
                            wnObj.Messaging_User__c=DuplicateId;
                            dbl.Exception_Description__c = string.valueof(insertResult.getErrors()[0].getStatusCode());
                        }
                    }catch(Exception e){
                            dbl.Exception_Description__c = string.valueof(e.getMessage());
                    }
                        
                    }
                }else{
                    if(msgUserList[0].MessagingConsentStatus=='OptedOut'){
                        msgUserList[0].MessagingConsentStatus='ImplicitlyOptedIn';
                        update msgUserList[0];
                    }
                    wnObj.Messaging_User__c=msgUserList[0].id;
                }
                
                
                for(String lb :fieldMapper.keySet())
                {
                    if(updateDetails.containsKey(lb) && lb=='PassDSCount'){
                        Integer discountValue = (Integer)updateDetails.get(lb);
                        wnObj.put(fieldMapper.get(lb),discountValue.format());
                    }
                    else if(updateDetails.containsKey(lb) && String.isNotBlank((String)updateDetails.get(lb))) 
                    {
                        String fValue = (String)updateDetails.get(lb);
                        String fType = String.valueOf(Schema.getGlobalDescribe().get('Whatsapp_Notifications__c').getDescribe().fields.getMap().get(fieldMapper.get(lb)).getDescribe().getType());
                        
                        if('INTEGER'.equalsIgnoreCase(fType))
                            wnObj.put(fieldMapper.get(lb),Integer.valueOf(fValue));
                        else if('DOUBLE'.equalsIgnoreCase(fType) || 'CURRENCY'.equalsIgnoreCase(fType))
                            wnObj.put(fieldMapper.get(lb),Double.valueOf(fValue));
                        else if(setString.contains(fType))
                            wnObj.put(fieldMapper.get(lb),String.valueOf(fValue));
                        else if('BOOLEAN'.equalsIgnoreCase(fType))
                            wnObj.put(fieldMapper.get(lb),Boolean.valueOf(fValue));
                        else
                        {
                            
                        }
                    }
                    
                }
                Database.saveResult updateResult = Database.insert(wnObj,false);
                if(updateResult!=null)
                {
                    if(updateResult.isSuccess())
                    {
                        res.statuscode = 200;
                        resp.isSuccess = 'true';
                        // resp.caseNum = caseNum;
                        resp.error ='';
                        resp.errorDescription ='';
                    }
                    else
                    {
                        res.statuscode = 417;
                        resp.isSuccess = 'false';
                        // resp.caseNum = caseNum;
                        resp.error ='Update Has Failed';
                        resp.errorDescription =string.valueof(updateResult.getErrors());
                    }
                }
                
            }
            else
            {
                res.statuscode = 400;
                resp.isSuccess = 'false';
                //resp.caseNum = caseNum;
                resp.error ='Invalid Input Received';
                resp.errorDescription ='Something wrong with Request/Coming as blank in Request';
                
            }
        } Catch(Exception e)
        {
            res.statuscode = 400;
            resp.isSuccess = 'false';
            resp.error ='Unable To Process The Request.';
            dbl.Complaint_Tracker_Error__c =string.valueof(e);
            resp.errorDescription =string.valueof(e);
        }  
        dbl.Response_Received__c=string.valueOf(resp);
        insert dbl;
        return resp;       
    }
    
    global class response
    {
        string caseNum;
        String isSuccess;
        string error;
        String errorDescription;
        public response(){}
    }  
}