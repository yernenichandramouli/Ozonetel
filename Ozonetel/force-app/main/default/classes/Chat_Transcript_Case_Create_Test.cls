/*@isTest
public class Chat_Transcript_Case_Create_Test {
    
    Static TestMethod void method()
    {
        Account acc = new Account();
        acc.Name='SampleName';
        acc.Phone='9584561234';
        acc.Email__c='Sample@gmail.com';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        acc.RecordTypeId = recordTypeId;
        Insert acc;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Customer_Name__c=acc.Id;
        ori.Order_Item_Reference_No__c='123';
        Insert ori;
        

        Live_Chat_Monitor__c lvechatmontr = new Live_Chat_Monitor__c();
        lvechatmontr.Rating__c='good';
        lvechatmontr.Channel__c='web';
        lvechatmontr.Chat_Session_Key__c='9765323456789';
        lvechatmontr.Submited_DateTime__c=system.now();
        insert lvechatmontr;
          
        LiveChatVisitor lveVstr= new LiveChatVisitor();
        insert lveVstr;
        
        
        LiveChatTranscript lvechatTrans = new LiveChatTranscript();
        lvechatTrans.Rating__c=lvechatmontr.Rating__c;
        lvechatTrans.Channel__c=lvechatmontr.Channel__c;
        lvechatTrans.Submited_DateTime__c=system.now();
        lvechatTrans.ChatKey= lvechatmontr.Chat_Session_Key__c;
        lvechatTrans.Tin_Number__c='123';
        lvechatTrans.LiveChatVisitorid=lveVstr.id;
        insert lvechatTrans;
        

        Case cs = new Case();
        cs.Email_Id_ct__c='Sample@gmail.com';
        cs.Phone_No_ct__c='9584561234';
        cs.OwnerId=UserInfo.getUserId();
        cs.Transaction_ID__c=ori.Id;
        cs.Does_Customer_Require_CallBack__c=true;
        cs.Call_Back_Time__c='1';
        Insert cs;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',lvechatTrans.Id);
        Chat_transcript_case_create cls = new Chat_transcript_case_create();
        cls.saveMethod();
        cls.showPopup();
        Test.StopTest();

    }
    Static TestMethod void method2()
    {
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        Insert ori; 
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('tId',ori.Id);
        Chat_transcript_case_create cls = new Chat_transcript_case_create();
        cls.showPopup();
        cls.closePopup();
        cls.cancel();
    }
}*/

@isTest
public class Chat_Transcript_Case_Create_Test {
    
    Static TestMethod void method()
    {
        Account acc = new Account();
        acc.Name='SampleName';
        acc.Phone='9584561234';
        acc.Email__c='Sample@gmail.com';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        acc.RecordTypeId = recordTypeId;
        Insert acc;
        
        Orders__c orde=new Orders__c();
        orde.Guid__c='564654';
        insert orde;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Customer_Name__c=acc.Id;
        ori.Order_Item_Reference_No__c='123';
        ori.RecordTypeId=Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();
        ori.Order_Name__c=orde.id;

        Insert ori;
    Order_Items__c o=[select id,Order_Uuid__c from Order_Items__c where id =:ori.id];
    system.debug('<<<o'+o);        

        Live_Chat_Monitor__c lvechatmontr = new Live_Chat_Monitor__c();
        lvechatmontr.Rating__c='good';
        lvechatmontr.Channel__c='web';
        lvechatmontr.Chat_Session_Key__c='9765323456789';
        lvechatmontr.Submited_DateTime__c=system.now();
        insert lvechatmontr;
          
        LiveChatVisitor lveVstr= new LiveChatVisitor();
        insert lveVstr;
        
        
        LiveChatTranscript lvechatTrans = new LiveChatTranscript();
        lvechatTrans.Rating__c=lvechatmontr.Rating__c;
        lvechatTrans.Channel__c=lvechatmontr.Channel__c;
        lvechatTrans.Submited_DateTime__c=system.now();
        lvechatTrans.ChatKey= lvechatmontr.Chat_Session_Key__c;
       lvechatTrans.Tin_Number__c='123';
        lvechatTrans.Order_Uuid__c='564654';
        lvechatTrans.status='InProgress';
        
        
        lvechatTrans.LiveChatVisitorid=lveVstr.id;
        insert lvechatTrans;
        
        Case cs = new Case();
        cs.Email_Id_ct__c='Sample@gmail.com';
        cs.Phone_No_ct__c='9584561234';
        cs.OwnerId=UserInfo.getUserId();
        cs.Transaction_ID__c=ori.Id;
        cs.Does_Customer_Require_CallBack__c=true;
        cs.Call_Back_Time__c='1';
        Insert cs;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',lvechatTrans.Id);
        Chat_transcript_case_create cls = new Chat_transcript_case_create();
        cls.saveMethod();
        cls.showPopup();
        Test.StopTest();
    }
    Static TestMethod void method2()
    {
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        Insert ori; 
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('tId',ori.Id);
        Chat_transcript_case_create cls = new Chat_transcript_case_create();
        cls.showPopup();
        cls.closePopup();
        cls.cancel();
    }
    
     Static TestMethod void method3()
    {
        Account acc = new Account();
        acc.Name='SampleName';
        acc.Phone='9584561234';
        acc.Email__c='Sample@gmail.com';
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business Accounts').getRecordTypeId();
        acc.RecordTypeId = recordTypeId;
        Insert acc;
        
        Orders__c orde=new Orders__c();
        orde.Guid__c='564654';
        insert orde;
        
        Order_Items__c ori = new Order_Items__c();
        ori.Name='SampleName';
        ori.Customer_Name__c=acc.Id;
        ori.Order_Item_Reference_No__c='123';
        ori.RecordTypeId=Schema.SObjectType.Order_Items__c.getRecordTypeInfosByName().get('B2B Bus Booking').getRecordTypeId();
        ori.Order_Name__c=orde.id;

        Insert ori;
    Order_Items__c o=[select id,Order_Uuid__c from Order_Items__c where id =:ori.id];
    system.debug('<<<o'+o);        

        Live_Chat_Monitor__c lvechatmontr = new Live_Chat_Monitor__c();
        lvechatmontr.Rating__c='good';
        lvechatmontr.Channel__c='web';
        lvechatmontr.Chat_Session_Key__c='9765323456789';
        lvechatmontr.Submited_DateTime__c=system.now();
        insert lvechatmontr;
          
        LiveChatVisitor lveVstr= new LiveChatVisitor();
        insert lveVstr;
        
        
        LiveChatTranscript lvechatTrans = new LiveChatTranscript();
        lvechatTrans.Rating__c=lvechatmontr.Rating__c;
        lvechatTrans.Channel__c=lvechatmontr.Channel__c;
        lvechatTrans.Submited_DateTime__c=system.now();
        lvechatTrans.ChatKey= lvechatmontr.Chat_Session_Key__c;
       lvechatTrans.Tin_Number__c='123';
        lvechatTrans.Order_Uuid__c='564654';
        lvechatTrans.status='InProgress';
        lvechatTrans.TCode__c='Test123';
        
        
        lvechatTrans.LiveChatVisitorid=lveVstr.id;
        insert lvechatTrans;
        lead ld=new lead();
        ld.lastname='test';
        ld.Status='New';
        ld.Remarks__c='test';
        ld.TCode__c='Test123';
        insert ld;
        
        Case cs = new Case();
        cs.Email_Id_ct__c='Sample@gmail.com';
        cs.Phone_No_ct__c='9584561234';
        cs.OwnerId=UserInfo.getUserId();
        cs.Transaction_ID__c=ori.Id;
        cs.Does_Customer_Require_CallBack__c=true;
        cs.Call_Back_Time__c='1';
        Insert cs;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('Id',lvechatTrans.Id);
        Chat_transcript_case_create cls = new Chat_transcript_case_create();
        cls.saveMethod();
        cls.showPopup();
        Test.StopTest();
    }
}