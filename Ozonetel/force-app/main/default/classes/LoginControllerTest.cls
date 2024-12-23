@isTest
public class LoginControllerTest
{
   public static testMethod void TestLoginSuccess()
    {
         Test.startTest(); 
        LoginController lg=new LoginController();
        lg.username='BD_Agent';
        lg.password='123456';
        Site_Users__c s=new Site_Users__c();
        s.name='BD_Agent';
        s.Password__c='123456';
        s.Type__c='Agent';
        s.Location__c='Banglore';
        s.Session_Id__c='1234';
        insert s;
        lg.signIn();
        lg.button='cps';
        lg.changePassword();
        lg.updatePassword();
         Test.stopTest(); 
    }
    
    public static testMethod void TestLoginFail()
    {
        Test.startTest(); 
        LoginController lg=new LoginController();
        lg.username='BD_Agent';
        lg.password='123Test';
        Site_Users__c s=new Site_Users__c();
        s.name='BD_Agent';
        s.Password__c='';
        s.Type__c='Agent';
        s.Location__c='Banglore';
        s.Session_Id__c='1234';
        insert s;
        lg.signIn();
         lg.button='sIns';
        lg.changePassword();
        lg.updatePassword();
        Test.stopTest(); 
    }
     public static testMethod void TestChangePassword()
    {
         LoginController lg=new LoginController();
        lg.password='';
        lg.newPassword='';
        lg.newPassword2='';
        lg.updatePassword();
        lg.newPassword='1234';
        lg.newPassword2='4321';
        lg.updatePassword();
    }
}