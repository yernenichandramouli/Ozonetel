@RestResource(urlMapping='/redBus/Attachment/*')
global without sharing class API_Attachment
{
    @HttpPost
    global static response doPost()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string channel=req.headers.get('channel');
        
        response resp = new response();
        try{
            CaseInformation data = new CaseInformation();
            data = (CaseInformation)JSON.deserialize(req.requestBody.toString(),CaseInformation.class);
            list<attachment> attachmentToInsert = new list<attachment>();
            list<case> csUpList=new list<case>();
            if(data.attachments!=null && data.attachments.size()>0 ){ 
                system.debug('dataattachments-->>'+data.attachments.size());
                if(channel=='SelfHelp' || channel=='RB+'){
                    list<case> csList=new list<case>();
                    set<string> csNums=new set<string>();
                    for (Attach  att :data.attachments){
                        csNums.add(att.csNum);
                    }               
                    csList=[select id,casenumber,Attachment_URLs__c,Service_Provider_Id__c from case where casenumber in:csNums];
                    Map<string,string> csRecMap=new Map<string,string>();
                    Map<string,case> csObjMap=new Map<string,case>();
                    for(case c:csList){
                        csRecMap.put(c.casenumber,c.id);
                        csObjMap.put(c.casenumber,c);
                    } 
                    
                    for(Attach  att :data.attachments){
                        attachmentToInsert.add( new Attachment(parentId = csRecMap.get(att.csNum), name = att.name, ContentType = att.ContentType,Body= EncodingUtil.base64Decode(att.body)));                
                        attWrapper at=new attWrapper();
                        at.attName=att.name;                       
                        at.caseid=integer.valueOf(att.csNum);
                        at.base64_string=att.body;
                        if(att.ContentType.contains('/'))
                        at.file_extension= att.ContentType.SubStringafter('/').toLowerCase();
                        else
                        at.file_extension= att.ContentType.toLowerCase();
                        if(csObjMap.get(att.csNum).Service_Provider_Id__c!=null)
                        at.opid=integer.valueOf(csObjMap.get(att.csNum).Service_Provider_Id__c);
                        at.created_epoch=System.now().getTime()/1000; 
                        at.fileSize=att.fileSize;
                        string jsP=JSON.serialize(at);
                        jsP=JSON.serialize(jsP);
                        system.debug('jsp-->'+jsp);
                        API_EndPoints__mdt amdt=[SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='AttachmentsToS3'];
                        HttpResponse htresp = new HttpResponse();
                        Map<String, String> omsHeaders= new Map<String, String>();
                        omsHeaders.put('Content-Type','application/json');
                        htresp = HTTPUtil.sendGenericHTTPRequest(amdt.Endpoint__c,'POST',jsp,omsHeaders,100000,'AgentAvailabilityCheck');
                        string jsBody=htresp.getBody();
                        System.debug('jsBody-->'+jsBody);
                        string mockResp='{ "setStatus": true, "setUrl": "http://10.5.10.104:8081/rpwapp/v1/sf/image/15926/321/BO-123/16443160490.jpg", "created_epoch": 16443160490, "file_name": "BO-123" }';
                        map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(jsBody);
                        
                        if(resObj!=null && resObj.get('setStatus')==true){
                            case cObj=new case();
                            cObj.id=csRecMap.get(att.csNum);                                                      
                            if(string.isBlank(csObjMap.get(att.csNum).Attachment_URLs__c))
                                cObj.Attachment_URLs__c='['+jsBody+']';
                            else
                                cObj.Attachment_URLs__c=csObjMap.get(att.csNum).Attachment_URLs__c.removeend(']')+','+jsBody+']';
                            csUpList.add(cObj);
                        }
                    }
                    
                }else{
                    for (Attach  att :data.attachments) 
                        attachmentToInsert.add( new Attachment(parentId = system.label.DBTRecord, name = att.name, ContentType = att.ContentType,Body= EncodingUtil.base64Decode(att.body)));                
                }
                
            }    
            if(!csUpList.isEmpty())
                update csUpList;  
            insert  attachmentToInsert;  
            resp.message='Successfully uploaded';
        }catch(Exception e){
            resp.message='Unscuusesfull';
            resp.errorDescription=string.valueOf(e);
        }
        
        return resp;
    }
    
    global class CaseInformation
    {
        Public  list<Attach> attachments;        
    }      
    public class Attach {
        String Body;
        String ContentType;
        String Name;
        String csNum;
        integer fileSize;
    }
    global class response
    {       
        string message;
        string errorDescription;        
    }  
    
    public class attWrapper{    
        public string attName;
        public integer opid;
        public integer caseid;
        public string base64_string;
        public long created_epoch;
        public string file_extension;
        public integer fileSize;    
    }   
}