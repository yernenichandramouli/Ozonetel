/**
* (c) 2024 RedBus
*
* Name           : sendWhatAppCapiCtrl
* Created Date   : 16 Sep 2024
* Created By     : VR Sudarshan
* Purpose        : generic class to send an whatsApp message.
* Test Class     : sendWhatAppCapiCtrlTest 
* Jira Id        : CRM-1926
**/
public class sendWhatAppCapiCtrl {

    public static void sendWhatsAppMessage(Map<id,String> caseMap){
        // Check if map is empty or not
        if (!caseMap.isEmpty()) {
            List<DBLog_Summary__c> dbLogListToUpdate = new List<DBLog_Summary__c>();
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            try{
                Map<string,Karix_WhatsAppMessage__mdt> templateNameAndMergeField = New Map<string,Karix_WhatsAppMessage__mdt>();
                Map<String, String> caseJsnAPIMap = new Map<String, String> ();
                List<Karix_WhatsAppMessage__mdt> karixWhatsAppMsgList = [SELECT Id,Template_Name__c,Query__c, Merge_Fields__c FROM Karix_WhatsAppMessage__mdt WHERE Template_Name__c=:caseMap.values()];
                for(Karix_WhatsAppMessage__mdt k: karixWhatsAppMsgList){
                    templateNameAndMergeField.put(k.Template_Name__c, k);
                }
                for(Id caseId:caseMap.keySet()){
                    string templateToTrigger = caseMap.get(caseId);
                    string mergeFields;

                    // Fetch the merge fields that needs to be triggered.
                    if(templateNameAndMergeField.containsKey(templateToTrigger)){
                        mergeFields = templateNameAndMergeField.get(templateToTrigger).Merge_Fields__c;
                        List<String> pairs = mergeFields.split(', ');
                        for (String pair : pairs) {
                            List<String> keyValue = pair.split(' => ');
                            if (keyValue.size() == 2) {
                                caseJsnAPIMap.put(keyValue[0].trim(), keyValue[1].trim());
                            }
                        }
                    }

                    string query = templateNameAndMergeField.get(templateToTrigger).Query__c;
                    System.debug('SOQL Query: ' + query);

                    // Fetch the case record
                    Case caseRecord = Database.query(query);

                    if(String.isNotBlank(caseRecord.Booking_Mobile_No__c) || String.isNotBlank(caseRecord.Phone_No_ct__c) ){
                        dbl.Type__c = 'Karix WhatsApp -'+templateToTrigger;
                        dbl.Case_Number__c = caseRecord.CaseNumber;
                        // Create a map to store the fetched values
                        Map<String, String> dynamicValues = new Map<String, String>();

                        // Loop through the caseJsnAPIMap and populate the dynamicValues map
                        for (String key : caseJsnAPIMap.keySet()) {
                            String apiField = caseJsnAPIMap.get(key);

                            // Split the field by dot notation to handle relationships
                            List<String> fieldParts = apiField.split('\\.');

                            // Initialize value variable
                            String fieldValue = '';
                            Object ObjFieldValue;
                        
                            if (fieldParts.size() == 1) {
                                // Handle non-relationship fields
                                ObjFieldValue = caseRecord.get(fieldParts[0]);
                                fieldValue = String.valueOf(ObjFieldValue);
                            } else if (fieldParts.size() == 2) {
                                // Handle relationship fields
                                if (fieldParts[0] == 'Account') {
                                    fieldValue = (String)caseRecord.Account.get(fieldParts[1]);
                                }
                            
                                if (fieldParts[0] == 'Transaction_ID__r'){
                                    fieldValue = (String)caseRecord.Transaction_ID__r.get(fieldParts[1]);
                                }
                            }
                            // Store the value in the dynamicValues map with the key
                            dynamicValues.put(key, fieldValue);
                        }
                        // Build the JSON formatted description
                        String formattedDescription = '{';
                        List<String> jsonParts = new List<String>();
                        for (String jsonParam : caseJsnAPIMap.keySet()) {
                            String value = dynamicValues.get(jsonParam);
                            value = String.escapeSingleQuotes(value != null ? value : '');
                            jsonParts.add('"' + jsonParam + '":"' + value + '"');
                        }
                        formattedDescription += String.join(jsonParts, ',') + '}';
                        System.debug('formattedDescription: ' + formattedDescription);

                        // string mobile = '919591791734';
                        string mobile = String.isNotBlank(caseRecord.Booking_Mobile_No__c)?caseRecord.Booking_Mobile_No__c:caseRecord.Phone_No_ct__c;
                        if(mobile.length()==10){
                            mobile='91'+mobile;
                        }

                        Map<String, String> headers = new Map<String, String>();
                        headers.put('Content-Type','application/json');
                        headers.put('Channel_Name','MOBILE_WEB');
                        headers.put('Country_Name','IND');
                        headers.put('BusinessUnit','BUS');
                        headers.put('auth_key','2d00da61-5b39-4b2a-899f-016c2ae51319');
                        list<HeadersWrapper> hlist=new list<HeadersWrapper>();
                        for(string o:headers.keyset()){
                            System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                            hlist.add(new HeadersWrapper(o,headers.get(o))); 
                        }
                        String headerJson=json.serialize(hlist); 
                        String headerJson2=json.serialize(headerJson); 
                        API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                        System.debug('::: formattedDescription = '+formattedDescription);
                        ButtonData buttonData = new ButtonData();
                        if(templateToTrigger=='bus_cancellation_fraud_check'){
                            buttonData.InteractiveButtonTypeId = 1;

                            ButtonDetail detail = new ButtonDetail();
                            detail.type = 'url';
                            detail.index = '0';
                            detail.Payload = caseRecord.Ticket_Link__c;

                            buttonData.buttonDetail.add(detail);
                        }
                        SendNotificationWrapper sn=new SendNotificationWrapper(formattedDescription,mobile,templateToTrigger,buttonData);    
                        System.debug('jsonBody-->'+JSON.serialize(sn));
                        String jsonBody=JSON.serialize(sn);
                        String feds=JSON.serialize(jsonBody);
                        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Send_Notification'];
                        string jsonCM='{"action":"Post","body":'+feds+',"endPoint":"'+APIMData.Endpoint__c+'","headers":'+headerJson2+'}';
                        Http ht = new Http();
                        HttpRequest req = new HttpRequest();
                        HttpResponse resp = new HttpResponse();
                        req.setHeader('Channel_Name','WEB_DIRECT');
                        req.setHeader('Content-Type','application/json');
                        req.setHeader('auth_key', 'fb26b9d6-28d5-4a43-a3f2-759839d7fdd7');
                        req.setHeader('Country_Name', 'IND'); 
                        req.setHeader('BusinessUnit', 'BUS');  
                        req.setHeader('Language', 'en');             
                        req.setMethod('POST');
                        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];
                        req.setEndpoint(APIMData.Endpoint__c);
                        req.setBody(jsonCM);
                        resp = ht.send(req);
                        dbl.Request_Data__c = string.valueof(req)+'--Body = '+req.getBody();
                        dbl.EndPoint__c = String.valueOf(req.getEndpoint());
                        dbl.Response_Received__c = String.valueOf(resp+'Response Body = '+resp.getBody());
                        dbl.CallOut_Status__c = string.valueOf(resp.getStatus());
                        dbl.CallOut_Status_Code__c = string.valueOf(resp.getStatusCode());
                        System.debug('wp resp-->'+resp.getBody());
                        // dbLogListToUpdate.add(dbl);
                    }
                }
            }catch(Exception e){
                System.debug('::: Exception has occured at line no '+e.getLineNumber()+' with an error message of '+e.getMessage());
                dbl.Exception_Description__c=string.valueOf(e);
            }

            dbLogListToUpdate.add(dbl);
            
            if(!dbLogListToUpdate.isEmpty()){
                insert dbLogListToUpdate;
            }
        }
    }


    public class SendNotificationWrapper{
        public string data_params;
        public List<string> channels=new List<string>{'whatsapp'};
        public string name;
        public AttachmentDetails AttachmentDetails=new AttachmentDetails();
        public address address=new address();
        public MessageDetails MessageDetails=new MessageDetails();
        public ButtonData buttonData = new ButtonData();
        public SendNotificationWrapper(string description,string mobileNo,string templateName, ButtonData buttonData){
            this.address.whatsapp_number=mobileNo;
            this.MessageDetails.DataJsonStr=description;
            this.MessageDetails.TemplateName=templateName;
            this.buttonData = buttonData;
        }
    }

    public class ButtonData {
        public Integer InteractiveButtonTypeId;
        public List<ButtonDetail> buttonDetail = new List<ButtonDetail>(); // List of button details
    }

    public class ButtonDetail {
        public String type;
        public String index;
        public String Payload;
    }

    // The existing classes remain unchanged

    public class AttachmentDetails{}

    public class address{
        public string whatsapp_number;
        public string links;
    }
    public class MessageDetails{
        public string TemplateName;
        public string DataJsonStr;
        public integer DataComplexity=2;
        public string Language='en';
        public string tin;
    }

    public class HeadersWrapper{       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }

}