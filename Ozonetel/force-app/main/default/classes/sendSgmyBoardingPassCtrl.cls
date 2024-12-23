/*
* Name           : sendSgmyBoardingPassCtrl
* Created Date   : 15 APR 2024
* Created By     : VR Sudarshan 
* Purpose        : Controller to generate boarding passes for Singapore and Malaysia.
* Test class     : sendSgmyBoardingPassCtrlTest
* Jira Id        : CRM-1649
*/

public with sharing class sendSgmyBoardingPassCtrl {

    @Auraenabled(cacheable=false)
    public static returnWrapper invokeBpardingPassApi(string ordItemId, string EmailId){
        System.debug(':: ordItemId Id '+ordItemId);
        returnWrapper retWrap = New returnWrapper();
        List<Order_Items__c> transactionList = [SELECT Id, Order_Item_Reference_No__c, Payment_Currency__c,Bpass_Status__c,Bus_Pass_Vendor_Status__c FROM Order_Items__c WHERE Id =:ordItemId AND Business_Unit__c in('REDBUS_SG','REDBUS_MY') LIMIT 1];
        if(!transactionList.isEmpty()){

            //Boarding pass not opted
            if(String.isBlank(transactionList[0].Bpass_Status__c)){
                retWrap.isError = true;
                retWrap.errorMessageToShow = 'Customer not opted for Boarding pass, hence can not be sent.';
                return retWrap;
            }

            //Boarding pass pending
            if(String.isNotBlank(transactionList[0].Bus_Pass_Vendor_Status__c) && transactionList[0].Bus_Pass_Vendor_Status__c=='PENDING'){
                retWrap.isError = true;
                retWrap.errorMessageToShow = 'Boarding pass not generated, will be sent 1 hour prior journey';
                return retWrap;
            }

            //Boarding pass failed
            if(String.isNotBlank(transactionList[0].Bus_Pass_Vendor_Status__c) && transactionList[0].Bus_Pass_Vendor_Status__c=='FAILED'){
                retWrap.isError = true;
                retWrap.errorMessageToShow = 'Boarding pass not generated.';
                return retWrap;
            }

            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.type__c ='SGMY Boarding Pass';
            dbl.Payment_Transaction_Name__c =transactionList[0].Id;
            string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='sgmyBoardingPass'].Endpoint__c;
            endpoint = endpoint +transactionList[0].Order_Item_Reference_No__c+'?EmailId='+EmailId;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('content-type','application/json');
            req.setHeader('Channel_Name','SFA');
            req.setHeader('auth_key','a8d87a36-3fdc-4207-bf94-18b2afe24f6b');
            if(transactionList[0].Payment_Currency__c =='MYR'){
                req.setHeader('Country_Name','MYS');
                req.setHeader('SelectedCurrency','MYR');
            }else{
                req.setHeader('Country_Name','SGP');
                req.setHeader('SelectedCurrency','SGD');
            }
            req.setHeader('BusinessUnit','BUS');

            HttpResponse res = new HttpResponse();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(120000);
            dbl.Request_Data__c = '--EndPoint--'+req.getEndpoint()+': Headers Info: Channel_Name :SFA,auth_key :a8d87a36-3fdc-4207-bf94-18b2afe24f6b,BusinessUnit :BUS'+'---Country_Name--'+req.getHeader('Country_Name')+'---SelectedCurrency--'+req.getHeader('SelectedCurrency');
            dbl.EndPoint__c = String.valueOf(req.getEndpoint());
            try{
                res = http.send(req);
                dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                insert dbl;
                string resBody=res.getBody(); 
                System.debug(':: resBody = '+resBody);
                if(res.getStatusCode() == 200 && res.getStatus()=='OK' && String.isNotBlank(resBody)){
                    retWrap = (returnWrapper)JSON.deserialize(resBody,returnWrapper.class);
                    System.debug('::: retWrap = '+retWrap);
                    return retWrap;
                }else{
                    retWrap.isError = true;
                    retWrap.errorMessageToShow = 'Something went wrong. Please contact system administrator.';
                    return retWrap;
                }
            }catch(Exception e){
                dbl.Exception_Description__c =string.valueof(e);
                insert dbl;
                retWrap.isError = true;
                retWrap.errorMessageToShow = e.getMessage() +e.getLineNumber();
                return retWrap;
            }
        }else{
            retWrap.isError = true;
            retWrap.errorMessageToShow = 'Invalid Transaction';
            return retWrap;
        }
    }

    public class returnWrapper
    {
        @AuraEnabled
        public Boolean boardingPassGenerated { get; set; }
        @AuraEnabled
        public Boolean emailSent { get; set; }
        @AuraEnabled
        public Boolean isError { get; set; }
        @AuraEnabled
        public String errorMessageToShow { get; set; }
    }
}