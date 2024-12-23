@isTest
public class RoundRobinBusHireBatchRegionTest
{
    Static testMethod void leadtest()
    {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='BusHire Call Team']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bushirecallteam@redbustest.com',Group__c='Group 1',Primary__c='Hyderabad Circle',Secondary__c='Chennai Circle');
        insert u;
        
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 40;
        usrDt.Assigned_Cases_Count__c=10;
        // usrDt.User__c=uId;
        usrDt.User__c=u.id;
        usrDt.Team__c='Bus Hire';
        usrDt.Group__c='Group 1'; 
        
        insert usrDt;
        
        
        
        list<Lead> Ledlist = new list<Lead>();
        Lead ld = new Lead();
        ld.Status = 'New';
        ld.LastName='MAHI';
        ld.OwnerId = u.id;
        ld.SrcCityName__c='Hyderabad';
        ld.DestCityName__c='Vishakhapatman';
        ld.DOJStart__c=System.today().adddays(1);
        ld.NumberOfQuotes__c=2;
        ld.IsMobileVerified__c=true;
        
        ld.OwnerId =[Select id from Group where type='Queue' AND developername='Bus_Hire_Queue'].id;
        System.debug('ld -->'+ld .ownerid);
        Ledlist.add(ld );
        insert Ledlist;
        Lead ld1 =[SELECT id,Owner_Group__c,name,status,ownerId,Minutes_Left_For_CallBack__c FROM Lead WHERE id =:Ledlist[0].id];
        ld1.ownerid = u.id;
        //  update ld1;
        System.debug('ld.1.'+ld1);
        Test.startTest();
        RoundRobinBusHireBatchRegion rodR = new RoundRobinBusHireBatchRegion();
        //  DataBase.executeBatch(rodR);
        
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
    Static testMethod void leadtest2()
    {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='BusHire Call Team']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bushirecallteam@redbustest.com',Group__c='Group 1',Primary__c='Chennai Circle',Secondary__c='Hyderabad Circle');
        insert u;
        
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 40;
        usrDt.Assigned_Cases_Count__c=10;
        // usrDt.User__c=uId;
        usrDt.User__c=u.id;
        usrDt.Team__c='Bus Hire';
        usrDt.Group__c='Group 1'; 
        
        insert usrDt;
        
        
        
        list<Lead> Ledlist = new list<Lead>();
        Lead ld = new Lead();
        ld.Status = 'New';
        ld.LastName='MAHI';
        ld.OwnerId = u.id;
        ld.SrcCityName__c='Hyderabad';
        ld.DestCityName__c='Vishakhapatman';
        ld.DOJStart__c=System.today().adddays(1);
        ld.NumberOfQuotes__c=2;
        ld.IsMobileVerified__c=true;
        
        ld.OwnerId =[Select id from Group where type='Queue' AND developername='Bus_Hire_Queue'].id;
        System.debug('ld -->'+ld .ownerid);
        Ledlist.add(ld );
        insert Ledlist;
        Lead ld1 =[SELECT id,Owner_Group__c,name,status,ownerId,Minutes_Left_For_CallBack__c FROM Lead WHERE id =:Ledlist[0].id];
        ld1.ownerid = u.id;
        //  update ld1;
        System.debug('ld.1.'+ld1);
        Test.startTest();
        RoundRobinBusHireBatchRegion rodR = new RoundRobinBusHireBatchRegion();
        //  DataBase.executeBatch(rodR);
        
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
    Static testMethod void leadtest3()
    {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='BusHire Call Team']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bushirecallteam@redbustest.com',Group__c='Group 1',Primary__c='Hyderabad Circle',Secondary__c='Chennai Circle');
        insert u;
        
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 5;
        usrDt.Assigned_Cases_Count__c=5;
        usrDt.Buffer_Assigned_Count__c=0;
        usrDt.Buffer_Limit__c=10;
        
        // usrDt.User__c=uId;
        usrDt.User__c=u.id;
        usrDt.Team__c='Bus Hire';
        usrDt.Group__c='Group 1'; 
        
        insert usrDt;
        
        
        
        list<Lead> Ledlist = new list<Lead>();
        Lead ld = new Lead();
        ld.Status = 'New';
        ld.LastName='MAHI';
        ld.OwnerId = u.id;
        ld.SrcCityName__c='Hyderabad';
        ld.DestCityName__c='Vishakhapatman';
        ld.DOJStart__c=System.today().adddays(1);
        ld.NumberOfQuotes__c=2;
        ld.IsMobileVerified__c=true;
        
        ld.OwnerId =[Select id from Group where type='Queue' AND developername='Bus_Hire_Queue'].id;
        System.debug('ld -->'+ld .ownerid);
        Ledlist.add(ld );
        insert Ledlist;
        Lead ld1 =[SELECT id,Owner_Group__c,name,status,ownerId,Minutes_Left_For_CallBack__c FROM Lead WHERE id =:Ledlist[0].id];
        ld1.ownerid = u.id;
        //  update ld1;
        System.debug('ld.1.'+ld1);
        //  Test.stopTest();
        //  Test.startTest();
        RoundRobinBusHireBatchRegion rodR = new RoundRobinBusHireBatchRegion();
        //  DataBase.executeBatch(rodR);
        
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
    Static testMethod void leadtest4()
    {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='BusHire Call Team']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='bushirecallteam@redbustest.com',Group__c='Group 1',Primary__c='Chennai Circle',Secondary__c='Hyderabad Circle');
        insert u;
        
        id uId=UserInfo.getUserId();
        DateTime cuTime = System.Now();     
        User_Details__c  usrDt =new  User_Details__c ();
        usrDt.First_Login_Time__c=System.Now();
        usrDt.Last_Login_Time__c=System.Now();
        usrDt.Today_Assignment_Limit__c = 5;
        usrDt.Assigned_Cases_Count__c=5;
        usrDt.Buffer_Assigned_Count__c=0;
        usrDt.Buffer_Limit__c=10;
        
        // usrDt.User__c=uId;
        usrDt.User__c=u.id;
        usrDt.Team__c='Bus Hire';
        usrDt.Group__c='Group 1'; 
        
        insert usrDt;
        list<Lead> Ledlist = new list<Lead>();
        Lead ld = new Lead();
        ld.Status = 'New';
        ld.LastName='MAHI';
        ld.OwnerId = u.id;
        ld.SrcCityName__c='Hyderabad';
        ld.DestCityName__c='Vishakhapatman';
        ld.DOJStart__c=System.today().adddays(1);
        ld.NumberOfQuotes__c=2;
        ld.IsMobileVerified__c=true;
        
        ld.OwnerId =[Select id from Group where type='Queue' AND developername='Bus_Hire_Queue'].id;
        System.debug('ld -->'+ld .ownerid);
        Ledlist.add(ld );
        insert Ledlist;
        Lead ld1 =[SELECT id,Owner_Group__c,name,status,ownerId,Minutes_Left_For_CallBack__c FROM Lead WHERE id =:Ledlist[0].id];
        ld1.ownerid = u.id;
        //  update ld1;
        System.debug('ld.1.'+ld1);
        //  Test.stopTest();
        //  Test.startTest();
        RoundRobinBusHireBatchRegion rodR = new RoundRobinBusHireBatchRegion();
        //  DataBase.executeBatch(rodR);
        
        String cronExp ='0 00 1 3 * ?';
        System.schedule('RoundRobin', cronExp,rodR);
        Test.stopTest();
    }
    
}