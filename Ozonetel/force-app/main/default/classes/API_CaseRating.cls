/*
* Name           : API_CaseRating
* Created Date   : 12 July 2018
* Created By     : Veeramanikanta R
* Purpose        : API to give rating for Case
* Test class     : API_CaseRatingTest
*/
@RestResource(urlMapping='/redBus/CaseRating/*')
global without sharing class API_CaseRating
{
    @HttpPost
    global static ResponseWrapper CaseRating()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper resp=new ResponseWrapper();
        try{
            string js='{"caseId":"1234","rating":"1"}';
            System.debug('res s-->'+req.requestBody.toString());
            caseCommentsWrapper  cd= (caseCommentsWrapper)JSON.deserialize(req.requestBody.toString(),caseCommentsWrapper.class);            
            if(String.isBlank(cd.rating)){
                res.statuscode = 400;
                resp.caseId=cd.caseId;
                resp.message='Rating can not be empty';
                return resp;
            }
            List<case> csList=new List<case>(); 
            csList=[select id,casenumber,status from case where casenumber =:cd.caseId];
            if(!csList.isEmpty()){
                List<Case_Feedback__c> cfList=[select id,Case_Name__c from Case_Feedback__c where Case_Name__c=:csList[0].id];
                if(csList[0].status!='Closed'){
                    res.statuscode = 200;
                    resp.caseId=cd.caseId;
                    resp.message='Case is not in Closed state';
                }
                else if(!cfList.isEmpty()){
                    res.statuscode = 200;
                    resp.caseId=cd.caseId;
                    resp.message='Rating is already available';
                }else{
                    Case_Feedback__c cf=new Case_Feedback__c();
                    cf.Rating__c=cd.rating;
                    cf.Case_Name__c =csList[0].id;
                    
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    cf.setOptions(dmo);
                    
                    Database.saveResult insertResult = Database.insert(cf,false);
                    res.statuscode = 200;
                    resp.caseId=csList[0].casenumber;
                    resp.message='Rating successfully submitted'; 
                }  
            }
            else{
                res.statuscode = 400;
                resp.caseId=cd.caseId;
                resp.message='Case is not available';
            }  
            
        }catch(Exception e){
            res.statuscode = 417;
            resp.message='Failed-->'+string.valueof(e);
        }
        return resp;
    }
    global class caseCommentsWrapper{
        public string rating;
        public string caseId;
    }
    global class ResponseWrapper{
        public string caseId;
        public string message;
    }
}