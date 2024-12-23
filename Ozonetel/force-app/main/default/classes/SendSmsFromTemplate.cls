public class SendSmsFromTemplate {
    @AuraEnabled(Cacheable=true)
    public static List<string> getMobileNumber(string caseId){
        List<string> phoneNumList = new List<string>();
        if(caseId != null){
            List<case> cs =[ select id,Phone_No_ct__c, casenumber, Transaction_ID__c from case where id =: caseId];
            if(cs.size()>0){
                List<Order_Items__c> lstordrItm =[select id,Mobile__c from Order_Items__c where id=:cs[0].Transaction_ID__c];                
                if(cs[0].Phone_No_ct__c != null && cs[0].Phone_No_ct__c !='')
                    phoneNumList.add(cs[0].Phone_No_ct__c);
                if(lstordrItm.size()>0 && lstordrItm[0].Mobile__c != null && lstordrItm[0].Mobile__c != '' && lstordrItm[0].Mobile__c != cs[0].Phone_No_ct__c) 
                    phoneNumList.add(lstordrItm[0].Mobile__c);    
            }      
        }
        system.debug(phoneNumList);
        return phoneNumList;
    }   
    @AuraEnabled(Cacheable=true)
    public static List<SMS_Template__mdt> SearchTemplates(string template,string type){
        System.debug('temp-->'+template);
        System.debug('type-->'+type);
        set<string> tempSet=new set<string>();
        //where Issue_Type__c=:template 
        string tempName='%'+template+'%';
        if(string.isNotBlank(tempName)){
            list<SMS_Template__mdt> templateList=new list<SMS_Template__mdt>();  
            list<SMS_Template__mdt> retIsuList=new list<SMS_Template__mdt>();        
            templateList=[SELECT Id,DeveloperName,Message_Content__c,Type__c FROM SMS_Template__mdt where DeveloperName LIKE : tempName and Type__c=:type];  
            System.debug('templateList-->'+templateList);
            if(templateList.size()>0)
                return templateList;
            else
                return null;
        }else
            return null;
    }
    @AuraEnabled
    public static string sendSMS(string caseId, string msgContent, string mobileNum,string type){ 
        system.debug('<<<<case id'+ caseId+';message'+msgContent);
        if(caseId != null && msgContent!= null && msgContent!= '' && caseId !='' &&  mobileNum !=null && mobileNum !=''){
            List<case> cs =[select id, casenumber,Case_Business_Unit__c, Transaction_ID__c, Business_Type__c from case where id =: caseId];
            if(type=='SMS'){
                //  List<case> cs =[ select id, casenumber, Transaction_ID__c from case where id =: caseId];
                //  system.debug('<<<case list'+cs);
                //  if(cs.size()>0){
                // List<Order_Items__c> lstordrItm =[select id,Mobile__c from Order_Items__c where id=:cs[0].Transaction_ID__c];
                //system.debug('<<<oi List'+lstordrItm);
                //if(lstordrItm.size()>0){
                //    system.debug('lstordrItm[0].Mobile__c'+lstordrItm[0].Mobile__c);
                http ht=new http();
                Httprequest req=new httprequest();
                httpresponse resp=new httpresponse();
                string fromatedDescription='{"Description":"'+msgContent+'"}';          
                boolean tempUsed;
                req.setHeader('Channel_Name','WEB_DIRECT');
                req.setHeader('Content-Type','application/json');
                req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
                if(cs[0].Case_Business_Unit__c=='REDBUS_IN' || cs[0].Business_Type__c=='L1 Support'){
                    req.setHeader('Country_Name', 'IND'); 
                    tempUsed=true;
                }else if(cs[0].Case_Business_Unit__c=='REDBUS_MY'){
                    req.setHeader('Country_Name', 'MYS');
                    tempUsed=false;
                    fromatedDescription='';
                }else{
                    req.setHeader('Country_Name', 'SGP');
                    tempUsed=false;
                    fromatedDescription='';
                }
                RequestWrapper.SendNotificationWrapper smsJ=new RequestWrapper.SendNotificationWrapper(mobileNum,fromatedDescription,'General_Query_SMS',msgContent,tempUsed);
                String smsJsonBody=JSON.serialize(smsJ);
                req.setHeader('BusinessUnit', 'BUS');  
                req.setHeader('Language', 'en');             
                req.setMethod('POST');
                API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification_SMS'];
                req.setEndpoint(APIMData.Endpoint__c);
                req.setBody(smsJsonBody);
                system.debug('<<req'+req);
                DBLog_Summary__c dbLog = new DBLog_Summary__c(); 
                dbLog.Type__c='Send SMS From Case';
                dbLog.Request_Data__c = req.toString()+'<--req-->'+req+'<--Body-->'+smsJsonBody+'<--Headers-->Channel_Name'+req.getHeader('Channel_Name')+' auth_key'+req.getHeader('auth_key')+' Country_Name'+req.getHeader('Country_Name')+' Language'+req.getHeader('Language')+' BusinessUnit'+req.getHeader('BusinessUnit');
                
                try{
                    resp = ht.send(req);
                    system.debug('<<res'+resp);
                    dbLog.Response_Received__c =resp.getBody();
                    insert dbLog;
                    
                    System.debug('resp-->'+resp.getbody());
                    if(resp!=null){
                        casecomment cc= new casecomment();            
                        // List<case> cs =[ select id, casenumber, Transaction_ID__c from case where id =: caseId];
                        cc.parentid=cs[0].Id;
                        cc.CommentBody='SMS('+msgContent+') sent';
                        insert cc;
                        return('SMS sent successfully');
                    }else{
                        return('SMS Failed to send, Please try again!!');
                    }
                }catch(Exception e){
                    return('SMS Failed to send, Please try again!!'+e);
                }
                
                //}
                //else
                //    return('error with user mobile number');  
                //  }
            }else if(type=='Whatsapp'){
                Whatsapp_Notifications__c wnObj=new Whatsapp_Notifications__c();
                string custWANum='whatsapp:+'+mobileNum;
                wnObj.Customer_Phone_No__c=mobileNum;
                wnObj.Template_Name__c='Test';
                wnObj.Message_Content__c=msgContent;
                List<MessagingChannel> msgChannel=new List<MessagingChannel>();
                msgChannel=[select id,DeveloperName from MessagingChannel where DeveloperName=:System.Label.WAMessagingChannel];
                
                MessagingEndUser objMsgUser = new MessagingEndUser();
                if(!msgChannel.isEmpty()){
                    objMsgUser.MessagingChannelId = msgChannel[0].id;
                    
                    objMsgUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
                    objMsgUser.MessageType = 'WhatsApp';//For SMS Channel
                    objMsgUser.MessagingPlatformKey = 'whatsapp:+'+mobileNum;
                    objMsgUser.Name = 'whatsapp:+'+mobileNum;
                    insert objMsgUser; 
                }
                wnObj.Messaging_User__c=objMsgUser.id;
                if(!test.isRunningTest()){
                    insert wnObj;
                }
            }
        }
        else{
            if(msgContent== null || msgContent ==''){
                return('Please Enter Message');
            }
            if(mobileNum == null || mobileNum==''){
                return('Please Select Mobile Number');
            }       
        }
        return null;
    }
}