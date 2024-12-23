@isTest
private class FeedbackInsertSchedulerTest{
    public static testMethod void  testfeedbackInsert() 
    {
        Test.StartTest();
        Live_Chat_Monitor__c lvechatmontr = new Live_Chat_Monitor__c();
        lvechatmontr.Rating__c='good';
        lvechatmontr.Channel__c='web';
        lvechatmontr.Chat_Session_Key__c='9765323456789';
        lvechatmontr.Submited_DateTime__c=system.now();
        insert lvechatmontr;
          
        LiveChatVisitor lveVstr= new LiveChatVisitor();
        insert lveVstr;
        
        case cs = new case();
        cs.status='Closed';
        insert cs;
        
        /*Case_Feedback__c cf = new Case_Feedback__c();
        cf.rating__c='good';
        cf.Case_Name__c=cs.id;
        insert cf;*/
        
        LiveChatTranscript lvechatTrans = new LiveChatTranscript();
        lvechatTrans.Rating__c=lvechatmontr.Rating__c;
        lvechatTrans.Channel__c=lvechatmontr.Channel__c;
        lvechatTrans.Submited_DateTime__c=system.now();
        lvechatTrans.ChatKey= lvechatmontr.Chat_Session_Key__c;
        lvechatTrans.CaseId=cs.id;
        
        lvechatTrans.LiveChatVisitorid=lveVstr.id;
        insert lvechatTrans;
        
        Case_Feedback__c cf = new Case_Feedback__c();
        cf.rating__c='good';
        cf.Case_Name__c=lvechatTrans.CaseId;
        insert cf;
        
        FeedbackInsertScheduler bpSch= new FeedbackInsertScheduler();
        String sche ='0 0 22 * * ? *';
        system.schedule('Test', sche, bpSch);
        Test.StopTest();
     }
    
      
 }