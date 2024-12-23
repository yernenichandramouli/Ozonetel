@isTest
public class OpenAIChatGptCntrlTest{
    public static testMethod void chatSummarizeTest(){
        Test.startTest();
        Live_Chat_Monitor__c chatMontr = new Live_Chat_Monitor__c();
        chatMontr.rating__c ='';
        chatMontr.Chat_Session_Key__c='bf8e65bb-0648-4ba8-8e72-96fe15050d87';
        chatMontr.Full_Transcript__c='CX :User is unable to use superhit coupon and Red100 coupon.User is unable to use superhit coupon and Red100 coupon.User is unable to use superhit coupon and Red100 coupon.'+'A: User is unable to use superhit coupon and Red100 coupon.'+'R: User is unable to use superhit coupon and Red100 coupon.User is unable to use superhit coupon and ';
        chatMontr.Full_Chat__c=removeTimestamp('test');
        insert chatMontr;
        
        LiveChatVisitor lv=new LiveChatVisitor();
        insert lv;
        
        LiveChatTranscript lcv =new LiveChatTranscript();
        lcv.EndTime=Datetime.newInstance(2023, 7, 29, 0, 0, 0);
        lcv.ChatKey=chatMontr.Chat_Session_Key__c;
        lcv.LiveChatVisitorId=lv.id;
        insert lcv;
        
        String summary = 'CX: This is a complete sentence. Incomplete sentence\n' +
                         'A: Agent will assist you further.\n' +
                         'R: The issue is still unresolved. Contact support\n' +
                         'CX: Another customer issue description.\n' +
                         'A: Agent response.\n' +
                         'R: Resolution completed.';

        string mockResp='{"status":"SUCCESS","response":{"openAIResponse":{"id":"cmpl-8KQjOqlJ9MTKZJrer3tMYfASR7PC4","object":"text_completion","created":1699880006,"model":"gpt-35-turbo","choices":[{"text":" Customer:Hi, I want to book a bus from Bangalore to Chennai.(2023-10-10 18:31:51) Agent:Sure, please tell me the date of travel.(2023-10-10 18:32:10) Customer:Tomorrow(2023-10-10 18:32:20) Agent:Okay, let me check the availability.(2023-10-10 18:32:30) Agent:Sorry, there are no buses available for tomorrow.(2023-10-10 18:32:40) Customer:","index":0,"finish_reason":"length"}],"usage":{"prompt_tokens":77,"completion_tokens":120,"total_tokens":197}},"StatusCode":200,"isAuthenticated":true}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        OpenAIChatGptCntrl.GetChatSummarize(chatMontr.id);   
        //String cxvvContent = OpenAIChatGptCntrl.extractAndCleanSection(summary, 'CX:');
        Test.stopTest();
    }

    public static testMethod void fetchpredictedSubIssueTypeTest(){
        Test.startTest();
        Live_Chat_Monitor__c chatMontr = new Live_Chat_Monitor__c();
        chatMontr.rating__c ='';
        chatMontr.Chat_Session_Key__c='bf8e65bb-0648-4ba8-8e72-96fe15050d87';
        chatMontr.Full_Transcript__c='Agent:Hello!This is p kalyani and I am here to help you.User:Hi ,User:I booked bus from Thanjavur to Coimbatore ,Agent:Sure, I will check the information for you.User:I am at boarding point now ,Agent:Let me check your ticket details quickly, please stay connected.Agent:May I know is your ticket from Thanjavur to Coimbatore on 11/14/2023 7:41 PM ?User:Yes ,User:Could you please help me to get contact number ,Agent:I am sorry to inform you that the bus details for this bus have to be collected from the inquiry counter since your booking is with a government operator';
          chatMontr.Full_Chat__c=removeTimestamp('test');
        insert chatMontr;
        
        LiveChatVisitor lv=new LiveChatVisitor();
        insert lv;
        
        LiveChatTranscript lcv =new LiveChatTranscript();
        lcv.EndTime=Datetime.newInstance(2023, 7, 29, 0, 0, 0);
        lcv.ChatKey=chatMontr.Chat_Session_Key__c;
        lcv.LiveChatVisitorId=lv.id;
        
        insert lcv;
        
        string mockResp='{"status":"SUCCESS","response":{"openAIResponse":{"id":"chatcmpl-8KkNLqQ75wLlvsOa6cmp9AYvfwOpJ","object":"chat.completion","created":1699955519,"model":"gpt-35-turbo","choices":[{"index":0,"finish_reason":"stop","message":{"role":"assistant","content":"{\u0027IssueMatch\u0027: \u0027I have a problem with bus service\u0027}"}}],"usage":{"prompt_tokens":2019,"completion_tokens":13,"total_tokens":2032}},"StatusCode":200,"isAuthenticated":true}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        OpenAIChatGptCntrl.fetchpredictedSubIssueType(chatMontr.id);   
        OpenAIChatGptCntrl.OpenAIResponse1 rs = new OpenAIChatGptCntrl.OpenAIResponse1();
        rs.id ='23456';
        rs.created=123456;
        rs.model='test';
        OpenAIChatGptCntrl.Usage1 us = new OpenAIChatGptCntrl.Usage1();
        us.prompt_tokens =567;
        us.completion_tokens=345678;
        us.total_tokens=56789;
        Test.stopTest();
    }
    
        public static String removeTimestamp(String input) {
        // This regex pattern matches the timestamp format (YYYY-MM-DD HH:MM:SS)
        String regexPattern = '\\(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\)';
        return input.replaceAll(regexPattern, '\n').trim();
    }
    
    public static testMethod void chatSummarizeTestnew(){
        Test.startTest();
        Live_Chat_Monitor__c chatMontr = new Live_Chat_Monitor__c();
        chatMontr.rating__c ='';
        chatMontr.Chat_Session_Key__c='bf8e65bb-0648-4ba8-8e72-96fe15050d87';
        chatMontr.Full_Transcript__c='CX :User is unable to use superhit coupon and Red100 coupon.User is unable to use superhit coupon and Red100 coupon.User is unable to use superhit coupon and Red100 coupon.'+'A: User is unable to use superhit coupon and Red100 coupon.'+'R: User is unable to use superhit coupon and Red100 coupon.User is unable to use superhit coupon and ';
        chatMontr.Full_Chat__c=removeTimestamp('test');
        insert chatMontr;
        
        LiveChatVisitor lv=new LiveChatVisitor();
        insert lv;
        
        LiveChatTranscript lcv =new LiveChatTranscript();
        lcv.EndTime=Datetime.newInstance(2023, 7, 29, 0, 0, 0);
        lcv.ChatKey=chatMontr.Chat_Session_Key__c;
        lcv.LiveChatVisitorId=lv.id;
        insert lcv;
        
        String summary = 'CX: This is a complete sentence. Incomplete sentence\n' +
                         'A: Agent will assist you further.\n' +
                         'R: The issue is still unresolved. Contact support\n' +
                         'CX: Another customer issue description.\n' +
                         'A: Agent response.\n' +
                         'R: Resolution completed.';

        string mockResp='{"status":"SUCCESS","response":{"openAIResponse":{"choices":[{"content_filter_results":{"hate":{"filtered":false,"severity":"safe"},"self_harm":{"filtered":false,"severity":"safe"},"sexual":{"filtered":false,"severity":"safe"},"violence":{"filtered":false,"severity":"safe"}},"finish_reason":"stop","index":0,"message":{"content":"CX: The user informs the agent that the bus is delayed and not safe to take. They request for the booking to be canceled and prefer to go by taxi instead.\nA: The agent asks for confirmation of the booking ID TTBN61741941 with the date of journey 24/10/2024.\nR: The agent escalates the issue to the relevant department and assures the user that they will be contacted within 48 hours. The user requests an immediate refund, but the agent explains that they are currently unable to process it. The operator requests the user to take the journey as the bus will arrive soon.","role":"assistant"}}],"created":1729854323,"id":"chatcmpl-AMCQ7pEjKTT7aRpn3al0uR7fHjOHT","model":"gpt-35-turbo","object":"chat.completion","prompt_filter_results":[{"prompt_index":0,"content_filter_results":{}}],"usage":{"completion_tokens":125,"prompt_tokens":647,"total_tokens":772}},"StatusCode":200,"isAuthenticated":true}}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', mockResp));
        OpenAIChatGptCntrl.GetChatSummarize(chatMontr.id);   
        //String cxvvContent = OpenAIChatGptCntrl.extractAndCleanSection(summary, 'CX:');
        Test.stopTest();
    }
}