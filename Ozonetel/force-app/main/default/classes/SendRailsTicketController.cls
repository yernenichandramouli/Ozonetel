/*
* Name           : SendRailsTicketController
* Created Date   : 04 JULY 2022
* Created By     : VR Sudarshan 
* Purpose        : Option to send e-ticket/m-ticket to the user on demand.
* Test class     : SendRailsTicketControllerTest
* Jira Id        : CRM-1174
*/
public with sharing class SendRailsTicketController {
    
    @Auraenabled(cacheable=false)
    public static string SendTicketDetails(string ordItemId,string otherPhoneno,boolean isOtherPhone,string otherEmail,boolean isOtherEmail){
        system.debug('::: ordItemId ::: '+ordItemId+'--mobile--'+otherPhoneno+'---mail--'+otherEmail+'--isOtherPhone--'+isOtherPhone+'--isOtherEmail--'+isOtherEmail);
        List<Order_Items__c> ordIt=new List<Order_Items__c>();
        ordIt =[SELECT Id, Guid__c,Transaction_Status__c,Mobile__c,Email__c,Item_Type__c FROM Order_Items__c WHERE Item_Type__c = 'RAILS' AND Transaction_Status__c ='Booked' AND id=:ordItemId];
        system.debug('::: ordIt ::: '+ordIt);
        if(!ordIt.isEmpty() && ordIt[0].Guid__c != null){
            try{
                string transEmailId= ordIt[0].Email__c;
                string transPhone= ordIt[0].Mobile__c.right(10);
                
                 String finalPhone;
                 String finalEmail;
                    
                if(isOtherPhone){
                    finalPhone = String.isNotBlank(otherPhoneno)?otherPhoneno:String.isNotBlank(transPhone)?transPhone:'';
                }
                
                if(isOtherEmail){
                   finalEmail = String.isNotBlank(otherEmail)?otherEmail:String.isNotBlank(transEmailId)?transEmailId:'';
                }
                
                if(!isOtherPhone&&!isOtherEmail){
                  finalPhone=transPhone;
                  finalEmail=transEmailId;
                  
                }
                system.debug('---finalPhone-'+finalPhone+'--finalEmail--'+finalEmail);
   
                DBLog_Summary__c dbl = new DBLog_Summary__c();
                dbl.type__c ='Send Rails Ticket';
                dbl.Payment_Transaction_Name__c =ordIt[0].Id;
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                string endPoint=[SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='RailsTicketsNotificationAPI'].Endpoint__c+ordIt[0].Guid__c+'&mobileNo='+finalPhone+'&emailId='+finalEmail;
                system.debug(':: EndPoint ::: '+endPoint);
                http ht=new http();
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint(endPoint);
                httpReq = HttpRequestUtil.populateRailPNRHeaders(httpReq);
                httpReq.setMethod('GET');
                dbl.Request_Data__c = '--EndPoint--'+endPoint+'-Headers-os--'+httpReq.getHeader('os')+'-Headers-Content-Type--'+httpReq.getHeader('Content-Type')+'-Headers-appversion--'+httpReq.getHeader('appversion')+'-Headers-AppVersionCode--'+httpReq.getHeader('AppVersionCode')+'-Headers-DeviceId--'+httpReq.getHeader('DeviceId')+'-Headers-regid--'+httpReq.getHeader('regid')+ '-Headers-AuthToken--'+httpReq.getHeader('AuthToken')+'-Headers-OSVersion--'+httpReq.getHeader('OSVersion')+ '-Headers-Country--'+httpReq.getHeader('Country')+'-Headers-Country_Name--'+httpReq.getHeader('Country_Name')+ '-Headers-BusinessUnit--'+httpReq.getHeader('BusinessUnit')+ '-Headers-Channel_Name--'+httpReq.getHeader('Channel_Name')+ '-Headers-auth_key--'+httpReq.getHeader('auth_key')+ '-Headers-Accept--'+httpReq.getHeader('Accept')+ '-Headers-SelectedCurrency--'+httpReq.getHeader('SelectedCurrency')+ '-Headers-Currency--'+httpReq.getHeader('Currency')+ '-Headers-PigeonDID--'+httpReq.getHeader('PigeonDID');
                dbl.EndPoint__c = endPoint;
                HttpResponse res = ht.send(httpReq);
                string resBody=res.getBody();
                dbl.Response_Received__c = String.valueOf(res+'...Body..'+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                if(res!=null && res.getStatus()=='OK' && res.getStatusCode()==200){
                    string notifiedThrough='';
                    map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(res.getBody());
                    for(string key :  resMap.keySet()){
                        if(resMap.get(key)==true){
                            notifiedThrough += ' & '+String.valueOf(key);
                        }
                    }
                    return 'Ticket detail has been sent successfully.';
                }else{
                    return 'No API Response';
                }
                
            }
            catch(Exception e){
                return 'Apex Error occured.';
            }
        }
        return 'Not Booked or Cannot send Ticket to this Transaction';
    }
    
}