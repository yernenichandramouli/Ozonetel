@isTest
public class ChatMonitorControllerTest {
    Static TestMethod void method()
    {
/*
        ChatMonitorController.fetchUser();
        LiveChatTranscript lct = new LiveChatTranscript();
        livechatVisitor lcv = new livechatvisitor();
        insert lcv;
        lct.LiveChatVisitorId=lcv.id;
        lct.OperatorMessageCount=2;
        //lct.Chat_Session_Key__c='123';
        insert lct;
        system.debug('session key'+lct.Chat_Session_Key__c);
        string sessionkey='123';
        string content='hi';
        string name ='abc';
        ChatMonitorController.onAgentMsg(lct.id, content,name, system.now());
        ChatMonitorController.onChatEndMsg(lct.id);
        ChatMonitorController.onChatAccepted(lct.id);
        ChatMonitorController.onAgentMsg(lct.id, content,name, system.now());
        ChatMonitorController.onChatEndMsg(lct.id);
        ChatMonitorController.onUsermessageSent(lct.id,content,name, system.now());
*/
    }
    Static TestMethod void method2()
    {
/*        
        ChatMonitorController.fetchUser();
        LiveChatTranscript lct = new LiveChatTranscript();
        livechatVisitor lcv = new livechatvisitor();
        insert lcv;
        lct.LiveChatVisitorId=lcv.id;
        //lct.Chat_Session_Key__c='123';
        insert lct;
        system.debug('session key'+lct.Chat_Session_Key__c);
        string sessionkey='123';
        string content='hi';
        string name ='abc';
        ChatMonitorController.onChatEndMsg(lct.id);
        ChatMonitorController.onAgentMsg(lct.id, content,name,system.now());
        ChatMonitorController.onChatAccepted(lct.id);
        ChatMonitorController.onAgentMsg(lct.id, content,name,system.now());
        ChatMonitorController.onChatEndMsg(lct.id);
        ChatMonitorController.onUsermessageSent(lct.id,content,name,system.now());
*/
    }
    Static TestMethod void onAgentMsgTest()
    {
        ChatMonitorController.fetchUser();
        
        livechatVisitor lcv = new livechatvisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId=lcv.id;
        lct.OperatorMessageCount=2;
       // lct.Chat_Session_Key__c='123';
        insert lct;
        system.debug('session key'+lct.Chat_Session_Key__c);
        string sessionkey='123';
        string content='hi';
        string name ='abc';
       
        ChatMonitorController.onAgentMsg(lct.id, content,name, system.now());
        
        Live_Chat_Monitor__c lmc = new Live_Chat_Monitor__c();
        lmc.Action__c = 'Agent Replied';
       // lmc.Agent_Last_Message__c=content;
        lmc.Full_Chat_Transcript__c = lmc.Full_Chat_Transcript__c+'<br>('+system.now()+') Agent:'+content;
        lmc.Full_Chat__c = lmc.Full_Chat__c+'<br>('+system.now()+') Agent:'+content;
        lmc.Chat_Session_Key__c=lct.Chat_Session_Key__c;
        insert lmc;
        
        
        ChatMonitorController.onAgentMsg(lct.id, content,name, system.now());

    }
    Static TestMethod void onChatAcceptedTest()
    {
        ChatMonitorController.fetchUser();
        
        livechatVisitor lcv = new livechatvisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId=lcv.id;
        lct.OperatorMessageCount=2;
       // lct.Chat_Session_Key__c='123';
        insert lct;
        system.debug('session key'+lct.Chat_Session_Key__c);
      
        ChatMonitorController.onChatAccepted(lct.id);       
        Live_Chat_Monitor__c lmc = new Live_Chat_Monitor__c();
        lmc.Action__c = 'Chat Accepted';
        lmc.Chat_Session_Key__c=lct.Chat_Session_Key__c;
        insert lmc;
        ChatMonitorController.onChatAccepted(lct.id);

    }
    Static TestMethod void onChatEndMsgTest()
    {
        ChatMonitorController.fetchUser();
        
        livechatVisitor lcv = new livechatvisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId=lcv.id;
        lct.OperatorMessageCount=2;
       // lct.Chat_Session_Key__c='123';
        insert lct;
        system.debug('session key'+lct.Chat_Session_Key__c);
        string sessionkey='123';
        string content='hi';
        string name ='abc';
       
        ChatMonitorController.onChatEndMsg(lct.id);       
        Live_Chat_Monitor__c lmc = new Live_Chat_Monitor__c();
        lmc.Action__c = 'Chat Ended';
        lmc.Full_Transcript__c='Web test values';
        lmc.Chat_Session_Key__c=lct.Chat_Session_Key__c;
        insert lmc;
        ChatMonitorController.onChatEndMsg(lct.id);
    }
    Static TestMethod void onUsermessageSentTest()
    {
        ChatMonitorController.fetchUser();
        
        livechatVisitor lcv = new livechatvisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId=lcv.id;
        lct.OperatorMessageCount=2;
       // lct.Chat_Session_Key__c='123';
        insert lct;
        system.debug('session key'+lct.Chat_Session_Key__c);
        string sessionkey='123';
        string content='hi';
        string name ='abc';
       
        ChatMonitorController.onUsermessageSent(lct.id, content,name, system.now());
        
        Live_Chat_Monitor__c lmc = new Live_Chat_Monitor__c();
//        lmc.Action__c = 'Agent Replied';
        //lmc.Agent_Last_Message__c=content;
        lmc.Full_Chat_Transcript__c = lmc.Full_Chat_Transcript__c+'<br>('+system.now()+') Agent:'+content;
        lmc.Full_Chat__c = lmc.Full_Chat__c+'<br>('+system.now()+') Agent:'+content;
        lmc.Chat_Session_Key__c=lct.Chat_Session_Key__c;
        insert lmc;
        
        
        ChatMonitorController.onUsermessageSent(lct.id, content,name, system.now());

    }


}