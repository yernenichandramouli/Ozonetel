/*
* Name           : sendSgmyActvtyNotificationCtrl
* Created Date   : 13 OCT 2023
* Created By     : VR Sudarshan 
* Purpose        : To send ticket notification for SGMY activites.
* Test class     : sendSgmyActvtyNotificationCtrlTest
* Jira Id        : CRM-1502
*/

public class sendSgmyActvtyNotificationCtrl {
    
    @AuraEnabled
    public static responseWrapper sendNotification(string activityId, string mobileNumber, string emailId, string notifyThrough){
        responseWrapper retruenWrapperData = new responseWrapper();
        string s = '--activityId = '+activityId+'--mobileNumber = '+mobileNumber+'--emailId = '+emailId+'--notifyThrough = '+notifyThrough;
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.type__c ='Send SGMY Actitvity Notification';
        List<Activities__c> activityList = [SELECT ID, OrderUuid__c,Purchase_Item_Currency__c,Business_Unit__c FROM Activities__c WHERE Id=:activityId LIMIT 1];
        if(string.isNotBlank(activityList[0].OrderUuid__c)){
            string businessUnit = activityList[0].Business_Unit__c;
            string countryCode='MYS';
            if(businessUnit.contains('_SG')){
                countryCode='SGP';
            }
            try{
                Http http = new Http();
                HttpResponse res = new HttpResponse();
                HttpRequest req = new HttpRequest();
                req = HttpRequestUtil.populatesgmySendNotification(req);
                req.setHeader('SelectedCurrency',activityList[0].Purchase_Item_Currency__c);
                req.setHeader('Currency',activityList[0].Purchase_Item_Currency__c);
                req.setHeader('Country_Name',countryCode);
                req.setMethod('GET');
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SGMY_Activity_Notification_Api'];
                // string endPoint=APIMData.Endpoint__c+'6df4532506def0067bf1fe8602010200?flag='+notifyThrough+'&ContactNo='+mobileNumber+'&EmailId='+emailId;
                string endPoint=APIMData.Endpoint__c+activityList[0].OrderUuid__c+'?flag='+notifyThrough+'&ContactNo='+mobileNumber+'&EmailId='+emailId;
                system.debug(':: Endpoint '+endpoint);
                req.setEndpoint(endPoint);
                dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+'-Headers-Language--'+req.getHeader('Language')+'-Headers-DeviceName--'+req.getHeader('DeviceName')+'-Headers-appversion--'+req.getHeader('appversion')+'-Headers-Channel_Name--'+req.getHeader('Channel_Name')+'-Headers-auth_key--'+req.getHeader('auth_key')+'-Headers-os--'+req.getHeader('os')+'-Headers-DeviceId--'+req.getHeader('DeviceId')+'-Headers-AppVersionCode--'+req.getHeader('AppVersionCode')+'-Headers-BusinessUnit--'+req.getHeader('BusinessUnit')+'-Headers-Accept--'+req.getHeader('Accept')+'-Headers-Content-Type--'+req.getHeader('Content-Type')+'-Headers-AuthToken--'+req.getHeader('AuthToken')+'-Headers-SelectedCurrency--'+req.getHeader('SelectedCurrency')+'-Headers-Src_Country--'+req.getHeader('Src_Country')+'-Headers-Currency--'+req.getHeader('Currency')+'-Headers-Country_Name--'+req.getHeader('Country_Name')+'-Headers-Country--'+req.getHeader('Country')+' -- Request Body --'+req.getBody();
                dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                // insert dbl;
                string responseValue = res.getBody();
                responseWrapper responseData = new responseWrapper();    
                responseData=(responseWrapper)JSON.deserialize(res.getBody(), responseWrapper.class);
                if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                    System.debug('::: responseData = '+responseData.statusMessage);
                    retruenWrapperData.statusMessage = responseData.statusMessage;
                    retruenWrapperData.isError = false;
                    insert dbl;
                    return retruenWrapperData;
                }else if(String.isNotBlank(responseValue)){ 
                    System.debug('::: responseData = '+responseData.DetailedMessage);
                    retruenWrapperData.DetailedMessage = responseData.DetailedMessage;
                    retruenWrapperData.isError = true;
                    insert dbl;
                    return retruenWrapperData;
                }else{
                    retruenWrapperData.DetailedMessage = 'Something went wrong, please contact your system administrator.';
                    retruenWrapperData.isError = true;
                    insert dbl;
                    return retruenWrapperData;
                }
            }catch(Exception e){
                dbl.Exception_Description__c=string.valueOf(e);
                insert dbl;
                retruenWrapperData.DetailedMessage = 'Exception occured, please contact your system administrator.';
                retruenWrapperData.isError = true;
                return retruenWrapperData;
            }

        }
        retruenWrapperData.DetailedMessage = 'Invalid OrderId, please contact your system administrator.';
        retruenWrapperData.isError = true;
        return retruenWrapperData;
    }

    public class responseWrapper{
        @AuraEnabled
        public string statusMessage { get; set; }
        @AuraEnabled
        public boolean isEmailSent { get; set; }
        @AuraEnabled
        public boolean isWhatsAppSent { get; set; }
        @AuraEnabled
        public string emailRespId { get; set; }
        @AuraEnabled
        public boolean isSMSSent { get; set; }
        @AuraEnabled
        public string DetailedMessage { get; set; }
        @AuraEnabled
        public boolean isError { get; set; }
    }
}