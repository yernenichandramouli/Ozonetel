@isTest
public class UpdateObjectInfoTest {
     public static testMethod void TestCaseUpdate()
    {
         Test.startTest(); 
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bus Cancellation').getRecordTypeId();
        cs.Status ='Open';
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();
        insert cs;
        Site_Helper__c s=new Site_Helper__c();
        s.case_Id__c=cs.id;
        s.Assigned_By__c=cs.OwnerId;
        insert s;
        list<user> usrLs=new list<user>();
        usrLs=[select id,username,isactive from user where id=: s.Assigned_By__c]; 
      
         Test.stopTest(); 
        
    }

  public static testMethod void TestCase1()
    {
        Test.startTest(); 
        case cs=new case();
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();   
        insert cs;    
        Site_Helper__c s=new Site_Helper__c();
        s.Assigned_By__c='BP verfiication';
        s.Flow_Type__c='DR_Queue';
        s.case_Id__c=cs.id;
        insert s;
        Test.stopTest(); 
        
    }

public static testMethod void TestCase2()
    {
        Test.startTest(); 
        case cs=new case();
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();   
        insert cs;    
        Site_Helper__c s=new Site_Helper__c();
        s.Assigned_By__c='YourBus';
        s.Flow_Type__c='IR_Queue';
        
        s.case_Id__c=cs.id;
        insert s;
        Test.stopTest(); 
        
    }
    
    public static testMethod void TestCase3()
    {
        Test.startTest(); 
        case cs=new case();
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();   
        insert cs;    
        Site_Helper__c s=new Site_Helper__c();
        s.Assigned_By__c='Invalid BP Queue';
        s.Flow_Type__c='IR_Queue';
        
        s.case_Id__c=cs.id;
        insert s;
        Test.stopTest(); 
        
    }
     public static testMethod void TestCase4()
    {
        Test.startTest(); 
        case cs=new case();
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();   
        insert cs;    
        Site_Helper__c s=new Site_Helper__c();
        s.Assigned_By__c='';
        s.Flow_Type__c='IR_Queue';
        
        s.case_Id__c=cs.id;
        insert s;
        Test.stopTest(); 
        
    }
    
     public static testMethod void TestCase5()
    {
        Test.startTest(); 
        case cs=new case();
        cs.Origin = 'Inbound Call';
        cs.Issue_Type__c ='General Query';
        cs.BD_Location__c='Banglore';
        cs.Ownerid = UserInfo.getUserId();   
        insert cs;    
        Site_Helper__c s=new Site_Helper__c();
        s.Assigned_By__c='';
        s.Flow_Type__c='';
        
        s.case_Id__c=cs.id;
        insert s;
        Test.stopTest(); 
        
    }
    
}