/*
* Name           : CreateCaseController
* Created Date   : 8 June 2017
* Created By     : Veeramanikanta R
* Purpose        : Create Case from Account level 
* Test class     : CreateCaseControllerTest
*/
public class CreateCaseController{
    
    public case cObj{get;set;}
    public Account accObj{get;set;}
    public createCaseController(){
        cObj=new case();
        accObj=new Account();
        Id recId=Apexpages.currentpage().getparameters().get('Id');
        accObj=[select id,name,PersonEmail,PersonMobilePhone from Account where id=:recId];
        user u=[SELECT id,name,Country,Business_Type__c from User WHERE Id=:UserInfo.getUserId()];
        cObj.Country__c=u.Country;
        cObj.Business_Type__c=u.Business_Type__c;
        
    }
    
    public pagereference save(){
        
        cObj.Customer_Name__c=accObj.id;
        cObj.Booking_Email_ID__c=accObj.PersonEmail;
        cObj.Booking_Mobile_No__c=accObj.PersonMobilePhone;
        
        try{
            insert cObj;
             return new PageReference('/'+cObj.Id);
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,''+e));
            return null;            
        }
       
    }
    
}