@isTest
public class LeadAssignmentTest
{
    public static testMethod void TestAssignment()
    {
        Test.startTest();
        id loggedInUserId=UserInfo.getUserId();
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c from user where id=:userInfo.getuserid()];
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        ud.First_Login_Time__c=System.now();
        ud.Team__c='Bus Hire';
        insert ud;
        LeadAssignment l=new LeadAssignment();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='RnR';
        
        ld.Call_back_request_time__c=System.now().addminutes(-1190);
        Id busComQueue= [Select id from Group where type='Queue' AND developername='BusHire_Common_Pool'].id;
        ld.ownerId=busComQueue;
        ld.RnR_Call_Time__c=system.now().addMinutes(-1130);
        ld.lead_group__c='Group 2';
        ld.Previous_Owner__c=ud.user__r.username;
        insert ld;
        
        System.debug('ld-->'+ld.owner.name);
        System.debug('rnr-->'+ld.RnR_Call_Time__c);
        System.debug('status-->'+ld.status);
        
        l.LeadRouting(loggedInUserId,'test'); 
        ld.status='Reopened';
        update ld;
        l.LeadRouting(loggedInUserId,'test'); 
        user uObj=[select id,username,Group__c,Primary__c,Secondary__c,CZentrix_Agent_Id__c from user where id=:loggedInUserId];
        uObj.Group__c='Group 1';
        update uObj;
        l.LeadRouting(loggedInUserId,'test');
        Test.stopTest();
    } 
    
    static testMethod void LeadAssignmentTest(){
        Test.startTest();
        id loggedInUserId=UserInfo.getUserId();
        user usr=new user();
        usr=[select id,CZentrix_Agent_Id__c from user where id=:userInfo.getuserid()];
        User_Details__c ud=new User_Details__c();
        ud.user__c=usr.id;
        ud.First_Login_Time__c=System.now();
        ud.Team__c='Bus Hire';
        insert ud;
        LeadAssignment l=new LeadAssignment();
        lead ld=new lead();
        ld.lastname='Test Name';
        ld.status='RnR';
        
        ld.Call_back_request_time__c=System.now().addminutes(-1190);
        Id busComQueue= [Select id from Group where type='Queue' AND developername='BusHire_Common_Pool'].id;
        ld.ownerId=busComQueue;
        ld.RnR_Call_Time__c=system.now().addMinutes(-1130);
        ld.lead_group__c='Group 2';
        ld.Previous_Owner__c=ud.user__r.username;
        insert ld;


        LeadAssignment temp = New LeadAssignment();
        temp.LeadRouting(loggedInUserId,'test'); 
        temp.LeadAssignment(ld,'Dialer');
        Test.stopTest();
    }
}