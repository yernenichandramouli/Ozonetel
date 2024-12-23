/*
* Name           : CallController
* Created Date   : 26 Oct 2018
* Created By     : Veeramanikanta R
* Purpose        : Used for calling functionality 
* Test class     : CallControllerTest
*/

public class CallController {

public boolean showCallPopup{get;set;}
public string mobileno{get;set;}
public lead leadObj{get;set;}
public boolean callButton{get;set;}

/*public CallController(){
showCallPopup=true;
leadObj=[select id,lastname,Phone from lead where id=:Apexpages.currentpage().getparameters().get('id')];
mobileno=leadObj.Phone;
}*/
public CallController(ApexPages.StandardController controller){
showCallPopup=true;
leadObj=[select id,lastname,Phone from lead where id=:Apexpages.currentpage().getparameters().get('id')];
mobileno=leadObj.Phone;
callButton=false;
}

public void call(){
mobileno=leadObj.Phone;
user uObj=[select id,Phone,MobilePhone,CZentrix_Agent_Id__c from user where id=:UserInfo.getUserID()];
        
        if(String.isBlank(mobileNo) || String.isBlank(uObj.CZentrix_Agent_Id__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Customer mobile number is missing [OR] CzenX Agent id is not configured at user level'));
        }
        
        else
        { 
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='SinfinyCall'];
            
            string jsonBody;
           callWrapper cw=new callWrapper(uobj.phone,mobileno,uObj.CZentrix_Agent_Id__c,leadObj.id);
           string cwJson=json.serialize(cw);
           HTTP h = new HTTP();
            HttpRequest req= new HttpRequest();
            HTTPResponse res=new HTTPResponse();        
            req = HttpRequestUtil.populateHeaders(req); 
            req.setMethod('POST');
            req.setBody(cwJson);
            req.setEndpoint(APIMData.Endpoint__c);  
            CZentrix_Info__c cInfObj=new CZentrix_Info__c();
            cInfObj.Call_Type__c='BusHire Call';
            try{        
                res=h.send(req); 
                if(res!=null && String.isNotBlank(res.getbody()))
                {
                    map<string,object> resObj= (map<string,object>)JSON.deserializeUntyped(res.getbody());
                    System.debug('resObj-->'+resObj);
                    System.debug('status-->'+boolean.valueof(resObj.get('status')));
                    if(resObj.containsKey('status') && boolean.valueof(resObj.get('status'))==true)
                    {
                        System.debug('resp-->'+res.getbody());
                        cInfObj.CustUniqueId__c=string.valueof(resObj.get('id'));
                        cInfObj.Lead__c=leadObj.id;
                        cInfObj.Agent_Phone_Number__c=uObj.MobilePhone;
                        cInfObj.Campaign_Name__c='BusHire Calling';
                        cInfObj.BO_Phone_Number__c=mobileNo;                        
                        cInfObj.Message__c='Success';
                        cInfObj.Agent_ID__c = String.valueOf(uObj.CZentrix_Agent_Id__c);                   
                        insert cInfObj;
                        callButton=true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Call will connect soon'));
                    } 
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Received Invalid Status From API, Please try again'));                    
                }                
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No Response from API, Please try again'));                
            } 
            
            catch(Exception e){        
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error Occered, Please try again!!'));
            } 
            
                        
        }

}


public class callWrapper{
 public string agentId;
 public string leadId;
 public string caller;
 public string receiver;
 public string campaignName='BusHire'; 
 public callWrapper(string caller,string receiver,string agentid,string leadId){
    this.leadId=leadId;
    this.caller=caller;
    this.receiver=receiver;
    this.agentId=agentId;
 }
}
}