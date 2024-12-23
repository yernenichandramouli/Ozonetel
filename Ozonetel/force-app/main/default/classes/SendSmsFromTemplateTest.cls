@isTest(SeeAllData=true)
public class SendSmsFromTemplateTest {
    
    public static testMethod void sendSMSTest(){
        
        case c= new case();
        c.Phone_No_ct__c='1234567890';
        insert c;    
        SendSmsFromTemplate.getMobileNumber(c.id);
        SendSmsFromTemplate.SearchTemplates('NEFT_SMS','SMS');
        string messageContent =[SELECT Message_Content__c FROM SMS_Template__mdt where DeveloperName LIKE :'NEFT_SMS' ].Message_Content__c;  
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        SendSmsFromTemplate.sendSMS(c.id,messageContent,c.Phone_No_ct__c,'SMS');
        test.stopTest();
    }
      public static testMethod void sendWatsupTest(){
               /* test.startTest();

        MessagingChannel mc=new MessagingChannel();
        mc.DeveloperName='mc1234';
        insert mc;
        test.stopTest();*/
        case c= new case();
        c.Phone_No_ct__c='1234567890';
        insert c;    
  
        SendSmsFromTemplate.getMobileNumber(c.id);
        SendSmsFromTemplate.SearchTemplates('NEFT_SMS','SMS');
        string messageContent =[SELECT Message_Content__c FROM SMS_Template__mdt where DeveloperName LIKE :'NEFT_SMS' ].Message_Content__c;  
        
        
        List<MessagingChannel> channel = [Select ID, DeveloperName, MessagingPlatformKey From MessagingChannel LIMIT 1];
          if(!channel.isEmpty()){
        Id channelId = channel[0].Id;
                
        Whatsapp_Notifications__c wnObj=new Whatsapp_Notifications__c();
        string custWANum='whatsapp:+'+ c.Phone_No_ct__c;
        wnObj.Customer_Phone_No__c= c.Phone_No_ct__c;
        wnObj.Template_Name__c='Test';
        wnObj.Message_Content__c=messageContent;
                
        MessagingEndUser objMsgUser = new MessagingEndUser();
        objMsgUser.MessagingChannelId = channelId;
        objMsgUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
        objMsgUser.MessageType = 'WhatsApp';//For SMS Channel
        objMsgUser.MessagingPlatformKey = 'whatsapp:+'+c.Phone_No_ct__c;
        objMsgUser.Name = 'whatsapp:+'+c.Phone_No_ct__c;
        insert objMsgUser; 
        wnObj.Messaging_User__c=objMsgUser.id;
        insert wnObj;
        }
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        SendSmsFromTemplate.sendSMS(c.id,messageContent,c.Phone_No_ct__c,'Whatsapp');
        test.stopTest();
    }
}