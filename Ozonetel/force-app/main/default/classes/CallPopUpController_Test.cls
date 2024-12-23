@isTest
public class CallPopUpController_Test
{
    static testMethod void callPopup()
    {
        Test.startTest();
        list<call_details__c > cldtlslst = new list<call_details__c >();
        User objUser = [SELECT Id, Name,username,CZentrix_Agent_Id__c FROM User 
        WHERE Id = :UserInfo.getUserId()];
        
        call_details__c cldtls = new call_details__c ();
        cldtls.Name='test';
        cldtls.Mobile_Number__c='test';
        cldtls.Menu_Options__c='test';
        cldtls.Language__c='test';
        cldtls.Trip_Id__c ='test';
        cldtls.Agent_Id__c=objUser.username;
        cldtlslst.add(cldtls);
        insert cldtlslst;
        
        CallPopUpController callpop= new CallPopUpController();
        callpop.searchOrder();
        
        CallPopUpControllerLtng ltng = new CallPopUpControllerLtng();
        ltng.searchOrder();
        CallPopUpControllerLtng.getRedirectionUrl('test');
        CallPopUpControllerLtng.fetchLatestCallDet(cldtlslst[0].id);
        
        Test.stopTest();
       } 
    }