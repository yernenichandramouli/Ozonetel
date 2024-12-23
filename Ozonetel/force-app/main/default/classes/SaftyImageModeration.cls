public class SaftyImageModeration {
    
    @AuraEnabled
    public static map<string,string> GetBOIds(string country){
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];     
        string GenericAPIEndpoint=APIMData.Endpoint__c;
        System.debug('--method call--');
        
        string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Safty_Plus_Image_Moderation'].Endpoint__c;
        endpoint = endpoint+'/api/SafetyPlusImage/GetUnmoderatedOperatorsInfo?countryCode='+country;
        system.debug('endpoint-->'+endpoint);
        //string endpoint ='http://api-rbplus-prod.redbus.in/api/SafetyPlusImage/GetUnmoderatedOperatorsInfo?countryCode=IND'; 
        string  genericJson='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":""}';
        
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req = HttpRequestUtil.populateHeaders(req);            
        req.setMethod('POST');            
        req.setEndpoint(GenericAPIEndpoint);
        req.setBody(genericJson);
        try
        {
            resp = ht.send(req );
            system.debug('--res--'+resp+'--body--'+resp.getBody());
            Map<string,string> boIds = (Map<string,string>)JSON.deserialize(resp.getBody(), Map<string,string>.class);
            system.debug('boIds'+boIds);
            return boIds; 
            
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);            
        }
        return null;
    }
    @AuraEnabled
    public static List<ImageDetailsWrapper> getImages(string boId){
        
        API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];     
        string GenericAPIEndpoint=APIMData.Endpoint__c;
        
        string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Safty_Plus_Image_Moderation'].Endpoint__c;
        endpoint =endpoint+'/api/SafetyPlusImage/GetSafetyPlusImageUrls/'+boId+'?IsInternationalOperator=false';           
        
        system.debug('endpoint-->'+endpoint);
        string  genericJson='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":""}';
        
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req = HttpRequestUtil.populateHeaders(req);            
        req.setMethod('POST');            
        req.setEndpoint(GenericAPIEndpoint);
        req.setBody(genericJson);
        try
        {
            res = ht.send(req );
            system.debug('--res--'+res+'--body--'+res.getBody());
            
            system.debug('<<res.getBody'+res.getBody());
            List<ImageDetailsWrapper> imageDetails = (List<ImageDetailsWrapper>)system.JSON.deserialize(res.getbody(), List<ImageDetailsWrapper>.class); 
            system.debug('<<imageDetails'+imageDetails.size()+'<<imageDeta'+imageDetails[0]+'<<'+imageDetails);
            return imageDetails;              
            
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);            
        }
        return null;
    }
    @AuraEnabled
    public static string UpdateImageInformation( string boId, string country, string bustypeId, List<string> approveIds, String rejectIds1) {  
        system.debug('rejectIds1'+rejectIds1);

        map<string,string> rejectIds=new map<string,string>();
        List<rejectImageWrapper> rejectList = (List<rejectImageWrapper>)JSON.deserialize(rejectIds1, List<rejectImageWrapper>.class);
        system.debug('<<<rejectList'+rejectList);
        for(rejectImageWrapper rej:rejectList){
            rejectIds.put(rej.value,rej.label);
        }
        
        system.debug('<<<rejectIds'+rejectIds);
        system.debug('<<<'+rejectIds.keyset());
        system.debug('<<<'+rejectIds.size()+'>><<'+rejectIds.values());
        try
        {
            system.debug('<<<approve ids:'+approveIds +'<<< reject ids:'+rejectIds);
            string rejectData = '';
            string approveData = '';
            string reasonsData='';
            if(approveIds!=null && !approveIds.isEmpty()){
                for(string apId : approveIds){
                    if(apid != ''){
                        if(approveData == '')
                            approveData = apId;
                        else
                            approveData = approveData+','+apId;          
                    }
                }              
            }
            if(rejectIds!=null && !rejectIds.isEmpty()){
                for(String reId : rejectIds.keyset()){
                    if(reId !=''){
                        if(rejectData == ''){
                            reasonsData ='"'+reId+'":"'+rejectIds.get(reId)+'"' ;                            
                            rejectData = reId;
                        }
                        else{
                            reasonsData = reasonsData+',"'+reId+'":"'+rejectIds.get(reId)+'"';  
                            system.debug('<<<reasonsData1'+reasonsData);
                            rejectData = rejectData+','+reId;
                        }                                                
                    }                    
                }
            }
            system.debug('approveData:'+approveData+'<<<rejectData:'+rejectData+'<<<reasonsData'+reasonsData);            

            API_EndPoints__mdt APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];     
            string GenericAPIEndpoint=APIMData.Endpoint__c;
            
            string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Safty_Plus_Image_Moderation'].Endpoint__c;
            endpoint =endpoint+'/api/SafetyPlusImage/UpdateSafetyPlusImageInformation?opId='+boId+'&busTypeID='+bustypeId+'&countryCode='+country;           
            
            system.debug('endpoint-->'+endpoint);
            string body = '{"APPROVED":"'+approveData+'", "REJECTED":"'+rejectData+'"}';
            system.debug('--<<Body'+body);
            body=JSON.serialize(body);
            system.debug('--<<Body'+body);
            string  genericJson='{"action":"PUT","body":'+body+',"endPoint":"'+endPoint+'","headers":""}';            
            Http ht = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            req = HttpRequestUtil.populateHeaders(req);            
            req.setMethod('POST');
            system.debug('GenericAPIEndpoint'+GenericAPIEndpoint);            
            req.setEndpoint(GenericAPIEndpoint);
            req.setBody(genericJson);
            resp = ht.send(req );
            system.debug('<<<StatusCode 1:'+resp.getStatusCode());
            system.debug('<<<response'+resp.getBody());
            if(resp.getStatusCode() == 200){
                system.debug('<<<reasonsData:'+reasonsData);
                if(reasonsData != ''){
                    endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Safty_Image_Reject'].Endpoint__c;
                    endpoint = endpoint +'?opId='+boId+'&busTypeID='+bustypeId+'&countryCode='+country;
                    body = '{'+reasonsData+'}';
                    system.debug('<<<reasonsData'+reasonsData);
                    body=JSON.serialize(body);
                    system.debug('<<<body'+body);
                    genericJson='{"action":"PUT","body":'+body+',"endPoint":"'+endPoint+'","headers":""}';
                    ht = new Http();
                    req = new HttpRequest();
                    resp = new HttpResponse();
                    req = HttpRequestUtil.populateHeaders(req);            
                    req.setMethod('POST');
                    system.debug('GenericAPIEndpoint'+GenericAPIEndpoint);            
                    req.setEndpoint(GenericAPIEndpoint);
                    req.setBody(genericJson);
                    system.debug('<<<genericJson'+genericJson);
                    system.debug('req:'+req);
                    resp = ht.send(req );
		            system.debug('<<<response2'+resp.getBody());
                    system.debug('<<<StatusCode2:'+resp.getStatusCode());
                    if(resp.getStatusCode() == 200){
                        return 'success';
                    }
                    else {
                        System.debug(resp.getBody());
                    }
                    return 'success';
                }
                else{
                    return 'success';
                }                
            }
            else {
                System.debug(resp.getBody());
            }
        }
        catch(Exception e)
        {
            System.debug('Error..'+e);            
        }  

        return null;
    }
    public class ImageDetailsWrapper{
        @AuraEnabled
        public string ImageURL{get;set;}
        @AuraEnabled
        public string Status{get;set;}
        @AuraEnabled
        public string ImageTag{get;set;} 
        @AuraEnabled
        public string ImageId{get;set;}
        @AuraEnabled
        public string BusTypeId{get;set;}
        @AuraEnabled
        public string BusType{get;set;}
        @AuraEnabled
        public string selType{get;set;}
        @AuraEnabled
        public boolean isReject{get;set;}
        @AuraEnabled
        Public boolean isOthers{get;set;}
        @AuraEnabled
        Public string RejectedReason{get; set;}
    } 
    
    public class rejectImageWrapper{
        @AuraEnabled
        public string value{get;set;}
        @AuraEnabled
        public string label{get;set;}
        
    }
}