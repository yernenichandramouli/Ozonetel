@isTest
public class LogoutEventTriggerTest {
    static testMethod void logoutMethos()
    {
    
       User u = new User();
       u.Email = 'test@tste.com';
       u.Username = 'test@tstetstete.com';
       u.MobilePhone = '1234567890';
       u.CommunityNickname = 'testssf';
       Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
       p.PermissionsCustomizeApplication  = True;
       u.ProfileId = p.id;
       u.LastName = 'test';
       u.Alias = 'tstsfsf';
       u.TimeZoneSidKey = 'Asia/Kolkata';
       u.LocaleSidKey = 'en_US';
       u.LanguageLocaleKey = 'en_US';
       u.EmailEncodingKey = 'UTF-8';
       u.IsActive = True;
       insert u;
        
       User_Details__c ud = new User_Details__c();
       ud.User__c = u.id;
       ud.Last_Login_Time__c= System.now();
       insert ud;
       
       Test.startTest();
       User u1 = [SELECT Id,  UserName FROM User WHERE Id =:u.id];
       LogoutEventStream event = new LogoutEventStream();
       event.UserName = u1.UserName;
       EventBus.publish(event);
       Test.stopTest(); 
   }
    
}