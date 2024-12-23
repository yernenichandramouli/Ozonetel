@isTest
public class RoundRobinBusHireBatchTest
{
    Static testMethod void leadtest()
    {
     
        UserInfo.getUserId();
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 40;
        usrDt.Assigned_Cases_Count__c=10;
        usrDt.User__c=uId;
        usrDt.Team__c='Bus Hire';
        usrDt.Group__c='Group 2'; 
        insert usrDt;
       
         Profile p = [SELECT Id FROM Profile WHERE Name='BusHire Call Team']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='bushirecallteam@redbustest.com',Group__c='Group 1');
            insert u;
        
        list<Lead> Ledlist = new list<Lead>();
        Lead ld = new Lead();
        ld.Status = 'In progress';
        ld.LastName='MAHI';
        ld.OwnerId = u.id;
      //  ld.OwnerId =[Select id from Group where type='Queue' AND developername='Bus_Hire_Queue'].id;
        System.debug('ld -->'+ld .ownerid);
        Ledlist.add(ld );
        insert Ledlist;
        Lead ld1 =[SELECT id,Owner_Group__c,name,status,ownerId,Minutes_Left_For_CallBack__c FROM Lead WHERE id =:Ledlist[0].id];
        ld1.ownerid = u.id;
        update ld1;
        System.debug('ld.1.'+ld1);
        Test.startTest();
        RoundRobinBusHireBatch rodR = new RoundRobinBusHireBatch();
        //  DataBase.executeBatch(rodR);

        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
   
}