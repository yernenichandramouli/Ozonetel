/**
 * (c) 2023 RedBus
 *
 * Name           : FetchAmenitiesController
 * Created Date   : 28 MAY 2023
 * Created By     : VR Sudarshan
 * Purpose        : Controller to fetch amenites values from omega.
 * JiraId         : CRM - 1420
 * Test class     : FetchAmenitiesControllerTest
 *
 **/
public class FetchAmenitiesController {

    @future(callout=true)
    public static void invokegetAllAmenitiesAPI() {
        // List<DBLog_Summary__c> dbLogListToUpdate = new List<DBLog_Summary__c>();
        // DBLog_Summary__c dbl = new DBLog_Summary__c();
        try{
            string GenericAPIEndpoint;
            API_EndPoints__mdt APIMData2 = new API_EndPoints__mdt();
            APIMData2=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];     
            GenericAPIEndpoint=APIMData2.Endpoint__c;
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='getAllAmenities'];
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization','Basic UkVEQlVTX1dFQkRJUkVDVDpXRFJvY2tzQDEyMw==');
            //dbl.type__c ='getAllAmenities';
            string endPoint=APIMData.Endpoint__c;
            list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
            for(string o:headers.keyset()){
                hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o)));
            } 
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson); 
            string genericJson='{"action":"GET","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
            System.debug('genericJson-->'+genericJson);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req = HttpRequestUtil.populateHeaders(req); 
            req.setMethod('POST');
            req.setEndpoint(GenericAPIEndpoint);
            req.setBody(genericJson);
            res = http.send(req);
            // dbl.Request_Data__c = string.valueof(req)+genericJson;
            // dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            // dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
            // dbl.CallOut_Status__c = string.valueOf(res.getStatus());
            // dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
            string responseValue = res.getBody();
            if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(responseValue)){
                List<amenitesResponseWrapper> amenites = New List<amenitesResponseWrapper>();
                amenites = (List<amenitesResponseWrapper>)JSON.deserialize(responseValue, List<amenitesResponseWrapper>.class);
                Map<string, string> responseMap = New Map<string,string>();
                string responseDataToUpdate = '';
                for(amenitesResponseWrapper re : amenites){
                    responseDataToUpdate = responseDataToUpdate + string.valueOf(re.Id)+'='+re.Display_Name+';';
                }
                if(string.isNotBlank(responseDataToUpdate)){
                    Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
                    metadataFieldValueMap.put('Values__c', responseDataToUpdate);
                    CustomMetadataUtils.updateCustomMetadata('Amenitie__mdt','Amenitie_Response', 'Amenitie Response',metadataFieldValueMap);
                }
                // dbLogListToUpdate.add(dbl);
            }

        }catch(Exception e){
            // dbl.Exception_Description__c=string.valueOf(e);
            // dbLogListToUpdate.add(dbl);
            System.debug('An exception occurred: ' + e.getLineNumber());
        }

        // if(!dbLogListToUpdate.isEmpty()){
        //     insert dbLogListToUpdate;
        // }
        
    }

    public  class amenitesResponseWrapper{       
        public integer Id { get; set; }
        public string Display_Name { get; set; }
    }
}