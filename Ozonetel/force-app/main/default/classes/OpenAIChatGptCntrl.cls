public class OpenAIChatGptCntrl{
    
 
    //openai/chat/completions  - new api
   @future(callout=true)
    public static void GetChatSummarize(string recorId)
    {
     
        List<Live_Chat_Monitor__c> chatMonitorLst= [select id,User_First_Message_Time__c,Issue_Type__c,Issue_Sub_Category__c,AgentFirstMessage__c,Word_Count__c,Agent_First_Message_Time__c,AgentLastMessage__c,Agent_Last_Reply__c,UserFirstMessage__c,User_Last_Message__c,User_Last_Reply__c,Full_Transcript__c,Chat_Summarize__c,Name,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where (Chat_Session_Key__c=:recorId or id=:recorId) FOR UPDATE];                 
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        dbl.Type__c ='Chat Summarization GPT';
        http ht=new http(); 
        HttpRequest httpReq= new HttpRequest(); 
        
         string issueTypes =System.label.gptIssueTypes;
         string subIssueTypes =System.label.gptSubIssueTypes;
         
         List<String> issueTypeList = issueTypes.split(',');
         List<String> subIssueTypeList =subIssueTypes.split(',');
        
        // Convert the dynamic lists into formatted strings
         String issueTypeListStr = buildListString(issueTypeList);
        String subIssueTypeListStr = buildListString(subIssueTypeList);
        
        String finalIssueType = '';
    String finalSubIssueType = '';
    
        if(!chatMonitorLst.isEmpty()){
            List<LiveChatTranscript> chatTranscriptToUpdate = New List<LiveChatTranscript>();
            List<LiveChatTranscript> lct = [select id,Agent_First_Msg__c,Agent_First_Message_Time__c,Agent_Last_Reply__c,User_First_Message__c,User_First_Message_Time__c,Agent_Last_Msg__c,Customer_First_Msg__c,customer_Last_Msg__c,User_Last_Message__c,User_Last_Reply__c,Chat_Session_Key__c,Chat_Summarize__c, Predicted_Sub_Issue_Type__c from LiveChatTranscript where ChatKey =:chatMonitorLst[0].Chat_Session_Key__c];
            
            string chatTrans = chatMonitorLst[0].Full_Transcript__c;
            List<String> words = chatTrans.split('\\s+');
            
            Integer wordCount = words.size();
            
            string chatPrompt =System.label.ChatSummarizePrompt;
            
            integer wordCountLabel =integer.Valueof(System.label.ChatSummarizeWordCount);
            
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData = [SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Chat_Summarize_Completions_API'];
            chatMonitorLst[0].Word_Count__c=wordCount;
            if(APIMData.EnableLog__c && wordCount > wordCountLabel){
                
                Integer maxSumCount;
                String cleanedString =removeTimestamp(chatMonitorLst[0].Full_Transcript__c);
                
                
                //cleanedString = cleanedString.replaceAll('<br>', '');
                
                //fullChatBdy = chatPrompt+'\n'+'\n'+'CX:[Summarize the users primary concern, including any provided phone number or specific number.]'+'\n'+'A: [Summarize the agents actions, mentioning any provided phone number or specific number]'+'\n'+'R: [Summarize the resolution and include any provided phone number or specific number. Ensure the resolution is conclusive and ends appropriately.]'+'\n'+'\n'+'Ensure that each section strictly adheres to this format and contains all mentioned details from the chat.'+'\n'+'\n'+'Chat Start:'+'\n'+'\n'+cleanedString;
                
              /*  String fullChatBdy = 
                    'Summarize the following chat between the user and the agent. Ensure the summary strictly follows the exact format below, retaining every detail such as dates, times, phone numbers, amounts, or complaint numbers exactly as stated in the chat. Do not add extra text, create additional resolutions, or alter the structure.'
                    + '\n\n'
                    + 'Format:'
                    + '\n'
                    + 'CX: [Briefly summarize the user\'s primary issue, including any specific details like phone numbers, complaint numbers, dates, or amounts provided.]'
                    + '\n'
                    + 'A: [Summarize the agent\'s actions with all included phone numbers, complaint numbers, dates, or amounts.]'
                    + '\n'
                    + 'R: [Summarize the final resolution, with all details included exactly, ending the response conclusively.]'
                    + '\n\n'
                    + 'Ensure that each section strictly adheres to this structure and includes every detail. Begin with "Chat Start:" and continue directly with the chat.'
                    + '\n\n'
                    + 'Chat Start:\n\n'
                    + cleanedString;*/
                
                 String fullChatBdy = 
            'Summarize the following chat between the user and the agent. Ensure the summary strictly follows the exact format below, retaining every detail such as dates, times, phone numbers, amounts, or complaint numbers exactly as stated in the chat. Do not add extra text, create additional resolutions, or alter the structure.\n\n' +
            'Format:\n' +
            'CX: [Briefly summarize the user\'s primary issue, including any specific details like phone numbers, complaint numbers, dates, or amounts provided.]\n' +
            'A: [Summarize the agent\'s actions with all included phone numbers, complaint numbers, dates, or amounts.]\n' +
            'R: [Summarize the final resolution, with all details included exactly, ending the response conclusively.]\n\n' +
            'After completing the summarization, categorize the conversation into an issue type and sub-issue type based on the following lists:\n\n' +
            'IssueType List:\n' +
            issueTypeListStr + '\n\n' +
            'SubIssueType List:\n' +
            subIssueTypeListStr + '\n\n' +
            'Use the format below for categorization:\n' +
            'IssueType: [Select one issue type from the IssueType list.]\n' +
            'SubIssueType: [Select one sub-issue type from the SubIssueType list.]\n\n' +
            'Example:\n\n' +
            'Chat Start:\n' +
            'Agent: Hello! This is Alex from redBus. How can I assist you today?\n' +
            'User: I want to cancel my ticket.\n' +
            'Agent: Please confirm the cancellation request for your ticket.\n' +
            'Output:\n' +
            'CX: User wants to cancel their ticket.\n' +
            'A: Agent confirms the cancellation request.\n' +
            'R: Cancellation request completed.\n' +
            'IssueType: "Ticket Cancellation"\n' +
            'SubIssueType: "User Requested Ticket Cancellation"\n\n' +
            'Ensure that the IssueType and SubIssueType accurately represent the conversation. Do not include additional text or provide explanations outside this format.\n\n' +
            'Chat Start:\n\n' +
            cleanedString;
                
                
                double result = wordCount * 0.25;  
                integer roundedResult = (integer) Math.round(result);  // Step 2: Round to the nearest integer and Step 3: Convert to int
                maxSumCount = Integer.valueOf(roundedResult);   
                maxSumCount = Math.round(maxSumCount);          
                
                
                dbl.Request_Data__c =fullChatBdy ;
                
                system.debug('>>>fullChatBdy>>'+fullChatBdy);
                
                OpenAIRequestWrapper body = new OpenAIRequestWrapper();
                body.request.messages[0].content = fullChatBdy; 
                
                String cxSection = 'CX: Not Available.';
                String aSection = 'A: Not Available.';
                String rSection = 'R: Not Available.';
                
                system.debug('>>>Json body>>'+JSON.serialize(body));
                httpReq.setEndpoint(APIMData.Endpoint__c+'chat/'+'completions');
                httpReq.setMethod('POST');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setHeader('api-key', 'Xt-6XKpoE[3lf|GYG&8ofXQ#');
                httpReq.setBody(JSON.serialize(body));
                system.debug('=Reqbody=='+httpReq.getBody());
                ChatGPTResponseWrapper  responseWrapper = new ChatGPTResponseWrapper();
                
                
                try{     
                    //string predictedSubIssueType = fetchpredictedSubIssueType(String.valueOf(chatMonitorLst[0].Id));
                    if(!lct.isEmpty()){
                        
                        lct[0].Agent_First_Msg__c =chatMonitorLst[0].AgentFirstMessage__c;
                        lct[0].Agent_First_Message_Time__c=chatMonitorLst[0].Agent_First_Message_Time__c;
                        lct[0].Agent_Last_Msg__c =chatMonitorLst[0].AgentLastMessage__c;
                        lct[0].Agent_Last_Reply__c =chatMonitorLst[0].Agent_Last_Reply__c;
                        lct[0].Customer_First_Msg__c =chatMonitorLst[0].UserFirstMessage__c;
                        lct[0].User_First_Message_Time__c =chatMonitorLst[0].User_First_Message_Time__c;
                        lct[0].customer_Last_Msg__c =chatMonitorLst[0].User_Last_Message__c;
                        lct[0].User_Last_Reply__c =chatMonitorLst[0].User_Last_Reply__c;
                        
                       // lct[0].Predicted_Sub_Issue_Type__c = predictedSubIssueType;
                        
                    }
                    
                    HttpResponse res = ht.send(httpReq);
                    string resBody=res.getBody();
                    system.debug('===isRes=='+res.getBody());
                    dbl.Payment_Request_Sent_Data__c=string.valueof(httpReq.getbody());
                    dbl.Payment_Request_Response_Data__c=resBody;
                    dbl.Case_Number__c = chatMonitorLst[0].Chat_Session_Key__c;
                    dbl.EndPoint__c=APIMData.Endpoint__c+'completions';
                    dbl.CallOut_Status_Code__c=String.valueOf(res.getstatuscode()+'--status--'+res.getstatus()+'--wordCount--'+wordCount+'>>maxSumCount>>'+maxSumCount);
                    if(res.getstatus()=='OK'&&res.getstatuscode()==200 && String.isNotBlank(resBody))
                    {
                        String sanitizedResponse = resBody.replace('\n', '\\n').replace('\r', '\\r');
                        
                        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(sanitizedResponse);
                        
                        if (parsedResponse.containsKey('response')) {
                            Map<String, Object> responseMap = (Map<String, Object>) parsedResponse.get('response');
                            
                            if (responseMap.containsKey('openAIResponse')) {
                                Map<String, Object> openAIResponse = (Map<String, Object>) responseMap.get('openAIResponse');
                                
                                if (openAIResponse.containsKey('choices')) {
                                    List<Object> choices = (List<Object>) openAIResponse.get('choices');
                                    
                                    if (!choices.isEmpty()) {
                                        Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
                                        
                                        if (firstChoice.containsKey('message')) {
                                            Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
                                            
                                            if (message.containsKey('content')) {
                                                String content = (String) message.get('content');
                                                
                                                // Split content by new lines to find "CX:", "A:", and "R:" sections
                                                List<String> lines = content.split('\\n');
                                                for (String line : lines) {
                                                    if (line.startsWith('CX:')) {
                                                        cxSection = line;
                                                    } else if (line.startsWith('A:')) {
                                                        aSection = line;
                                                    } else if (line.startsWith('R:')) {
                                                        rSection = line;
                                                    }
                                                    
                                                    if (line.startsWith('IssueType:')) {
                                                         finalIssueType = line.replace('IssueType:', '').trim();
                                                    } else if (line.startsWith('SubIssueType:')) {
                                                        finalSubIssueType = line.replace('SubIssueType:', '').trim();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Combine sections in the desired format
                        string finalSummaryResponse= cxSection+'\n'+aSection+'\n'+rSection;
                        system.debug('>>>final>>'+finalSummaryResponse);
                        chatMonitorLst[0].Chat_Summarize__c=finalSummaryResponse;
                          chatMonitorLst[0].Issue_Type__c =finalIssueType;
                          chatMonitorLst[0].Issue_Sub_Category__c =finalSubIssueType;
                        if(!lct.isEmpty()){
                            lct[0].Chat_Summarize__c=finalSummaryResponse;
                           
                        }
                         dbl.Issue_Type__c =finalIssueType;
                         dbl.Issue_Sub_Category__c =finalSubIssueType;
                        dbl.Response_Received__c=finalSummaryResponse;
                        
                      
                    }else{
                        
                     dbl.Response_Received__c= String.valueOf(res.getstatuscode());
                    }
                    
                }catch(Exception e){
                    dbl.Response_Received__c= String.valueOf(e);
                }
                insert dbl; 
                update lct;     
                update chatMonitorLst;
            }
        }
    }
    
    
    
      @AuraEnabled
    public static Map<String, String> handleChatEnd(Id recordId) {
    system.debug('>>>>>>>>>>>>>>>>>>');
            list<LiveChatTranscript> lct = [select Chat_Session_Key__c from LiveChatTranscript where id =:recordId];

       // GetChatSummarize(lct[0]. Chat_Session_Key__c);
       List<Live_Chat_Monitor__c> chatMonitorLst= [select id,Issue_Type__c,Issue_Sub_Category__c,Chat_Summarize__c from Live_Chat_Monitor__c where Chat_Session_Key__c=:lct[0].Chat_Session_Key__c FOR UPDATE];                 

system.debug('>>>>>>>'+chatMonitorLst[0].Chat_Summarize__c);
        Map<String, String> caseData = new Map<String, String>();
        caseData.put('channel', 'Chat');
        caseData.put('summary', chatMonitorLst[0].Chat_Summarize__c);
        caseData.put('status', 'Open');
        caseData.put('issue', chatMonitorLst[0].Issue_Type__c);
        caseData.put('subIssue', chatMonitorLst[0].Issue_Sub_Category__c);
        return caseData;
    }

    @AuraEnabled
    public static String createCaseRecord(String channel, String summary, String status, String issue, String subIssue) {
        // Create a new case record
        Case newCase = new Case();
        newCase.Subject = summary;
        newCase.Description = 'Channel: ' + channel + '\nIssue: ' + issue + '\nSubIssue: ' + subIssue;
        newCase.Status = status;
        
        // Optionally set other fields as needed
        newCase.Priority = 'Medium'; // Default value, can be changed
        
        try {
            insert newCase;
            return newCase.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating case: ' + e.getMessage());
        }
    }
    
     @AuraEnabled
    public static void createNewCase(String subject, String summary, String status, String issue, String resolution) {
        // Create a new case record
        Case newCase = new Case();
        newCase.Subject = subject;
        newCase.Description = summary;
        newCase.Status = status;
        newCase.Origin = 'Chat';
       // newCase.Resolution = resolution;
        
        insert newCase;
    }
    
    public static String removeTimestamp(String input) {
        // This regex pattern matches the timestamp format (YYYY-MM-DD HH:MM:SS)
        String regexPattern = '\\(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\)';
        return input.replaceAll(regexPattern, '\n').trim();
    }
    
   
    
    // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
    public class Request
    {
        public string prompt { get; set; }
        public integer temperature { get; set; }
        public integer max_tokens { get; set; }
    }
    
    public class chatRequest
    {
        public string username { get; set; }
        public string password { get; set; }
        public integer api { get; set; }
        public string model { get; set; }
        public Request request { get; set; }
    }
    
    // Response body 
    
    public class Choice
    {
        public string text { get; set; }
        public integer index { get; set; }
        public string finish_reason { get; set; }
    }
    
    public class OpenAIResponse
    {
        public string id { get; set; }
        //public string object { get; set; }
        public Integer created { get; set; }
        public string model { get; set; }
        public List<Choice> choices { get; set; }
        public Usage usage { get; set; }
    }
    
    public class Response
    {
        public OpenAIResponse openAIResponse { get; set; }
        public integer StatusCode { get; set; }
        public boolean isAuthenticated { get; set; }
    }
    
    public class ChatGPTResponseWrapper
    {
        public string status { get; set; }
        public Response response { get; set; }
    }
    
    public class Usage
    {
        public integer prompt_tokens { get; set; }
        public integer completion_tokens { get; set; }
        public integer total_tokens { get; set; }
    }
    
    
    public static string fetchpredictedSubIssueType(string recorId){
        List<Live_Chat_Monitor__c> chatMonitorLst= [select id,Full_Transcript__c,Chat_Summarize__c,Name,Full_Chat_Transcript__c,Full_Chat__c,Chat_Session_Key__c from Live_Chat_Monitor__c where id=:recorId FOR UPDATE];                
        List<DBLog_Summary__c> dbLogListToInsert = new List<DBLog_Summary__c>();
        http ht=new http();
        HttpRequest httpReq= new HttpRequest();
        Integer numAttempts = 3; // Maximum number of retry attempts
        Integer delayMillis = 5000; // Delay in milliseconds between attempts
        if(!chatMonitorLst.isEmpty()){
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Chat_Summarize_Completions_API'];
            
            List<Message> promptList = New List<Message>();
            Message prompt1 = New Message();
            prompt1.role='system';
            prompt1.content = String.valueOf(chatMonitorLst[0].Full_Transcript__c)+' YOUR JOB IS TO SELECT THE BEST MATCHING ISSUES FROM OUR SYSTEM';
            promptList.add(prompt1);
            Message prompt2 = New Message();
            prompt2.role='user';
            // prompt2.content = 'In redbus, user and agent had the following conversation: '+String.valueOf(chatMonitorLst[0].Full_Transcript__c)+'\n Please use above conversation and find the best match strictly from the following list of issues:\n 0. Add on service\n1. Apsrtc-Manual Refunds\n2. Booking Related Issue\n3. Bus Cancellation\n4. Call Back\n5. Call Drop\n6. Cancellation Issues\n7. Confirmation issue\n8. Counter Refund - Bus cancel\n9. Cyber Crime\n10. General Query\n11. I am facing issues with live tracking\n12. Customer Care Service\n13. I faced some technical issue with redBus app/website\n14. I felt unsafe during the journey\n15. I didn\'t receive offer benefits for this transaction\n16. Bus Operator Service\n17. Refund\n18. I need booking confirmation email and SMS\n19. I need help to board my bus\n20. Offers and Promotions\n21. Referral\n22. Wallet\n23. Ticket cancellation\n24. Booking Issues\n25. Invoice\n26. Insurance\n27. My bus broke down or delayed\n28. Need help to make a new bus ticket booking\n29. New vehicle- GPS details needed\n30. Offer issue\n31. Other Business Inquiries\n32. Outbound Call\n33. Payment done and ticket not given\n34. Payment issues\n35. Reschedule Issue\n36. Ticket Queries\n37. UGC Rating\n \n and return the best matching result from the \n    list of issues strictly in the following format only: {\'IssueMatch\':\'My bus broke down or delayed\'} and do not add any additional information in the final response';
            prompt2.content = 'In redbus, user and agent had the following conversation: '+String.valueOf(chatMonitorLst[0].Full_Transcript__c)+'\n Please use the conversation above and find the best match strictly from the following list of issues. If no match is found, set the issue type value as "others":\n0 Alternative provided was not acceptable - travelled \n1 Offer code not working \n2 I am unable to track the bus - tracking link not received \n3 I am unable to track the bus - tracking link not working \n4 I did not get the promised amenities like AC, blanket etc \n5 I did not travel - please cancel & return my money \n6 I erroneously entered wrong information while booking \n7 Rude staff behavior \n8 I have not received my cashback \n9 Need Boarding Point address/contact number \n10 I need information other than BP/DP locations and time \n11 I need the Bus number & Driver number \n12 I need to know departure and/or arrival times \n13 I want to cancel my ticket \n14 I want to cancel my ticket partially \n15 I want to change my BP and DP \n16 I want to know my refund status \n17 I want to reschedule my booking \n18 Bus operator did not allow to board the bus \n19 Bus type changed \n20 Booked seat not allotted \n21 I would like to know if booking is confirmed / Bus Services are O \n22 I would like to know more about redBus offers \n23 I would like to know the luggage policy \n24 Change in booking details like mail/mobile no/name \n25 Initiate Bus Cancellation \n26 Issue with BO contact number \n27 Boarding / Dropping point changed \n28 Ticket booked for incorrect date of journey \n29 My bus broke down \n30 My bus didn\'t show up \n31 My bus met with an accident \n32 Bus delayed \n33 My journey took longer than expected \n34 My journey was rescheduled by the bus operator \n35 No alternative was arranged \n36 Poor bus quality \n37 Ticket cancelled without customer\'s knowledge \n38 Trip Rewards \n39 Where is my refund\n \n and return the best matching result from the \n    list of issues strictly in the following format only: {\'IssueMatch\':\'Poor bus quality\'} and do not add any additional information in the final response';
            promptList.add(prompt2);
            RequestData promptMessage = New RequestData();
            promptMessage.messages = promptList;
            
            IssuePredectionWrapper requestWrapper = New IssuePredectionWrapper();
            requestWrapper.username='sa_ugc';
            requestWrapper.password='redBus@365';
            requestWrapper.api=1;
            requestWrapper.model='gpt-3.5-turbo';
            requestWrapper.request = promptMessage;
            
            system.debug('requestBody= '+requestWrapper);
            system.debug('serializeRequestBody= '+JSON.serialize(requestWrapper));
            Request req = new Request();
            httpReq.setEndpoint(APIMData.Endpoint__c+'chat/completions');
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('api-key', 'Xt-6XKpoE[3lf|GYG&8ofXQ#');
            httpReq.setBody(JSON.serialize(requestWrapper));
            system.debug('HTTPRequestBody = '+httpReq.getBody());
            while (numAttempts > 0) {
                DBLog_Summary__c dbl = New DBLog_Summary__c();
                dbl.type__c = 'GPT Issue Predection '+numAttempts;
                dbl.Request_Data__c = string.valueof(httpReq)+requestWrapper;
                dbl.EndPoint__c = String.valueOf(httpReq.getEndpoint());
                System.debug('numAttempts = '+numAttempts);
                try{
                    HttpResponse res = ht.send(httpReq);
                    string resBody=res.getBody();
                    dbl.Response_Received__c = String.valueOf(res+'Response Body = '+res.getBody());
                    dbl.CallOut_Status__c = string.valueOf(res.getStatus());
                    dbl.CallOut_Status_Code__c = string.valueOf(res.getStatusCode());
                    dbLogListToInsert.add(dbl);
                    system.debug('resBody = '+res.getBody());
                    IssuePredectionResponseWrapper responseData = new IssuePredectionResponseWrapper();    
                    responseData=(IssuePredectionResponseWrapper)JSON.deserialize(res.getBody(), IssuePredectionResponseWrapper.class);
                    System.debug('myDeserializedClass = '+responseData);
                    string messageReceived = String.valueOf(responseData.response.openAIResponse.choices[0].message.content);
                    messageReceived = messageReceived.replaceAll('\\{\'(.*?)\': \'(.*?)\'\\}', '{"$1": "$2"}');
                    System.debug('messageReceived = '+messageReceived);
                    Map<String, String> issueTypeMap = (Map<String, String>)JSON.deserialize(messageReceived, Map<String, String>.class);
                    String issueMatchValue = issueTypeMap.get('IssueMatch');
                    System.debug('IssueMatch: ' + issueMatchValue);
                    // if(dbLogListToInsert.size()>0){
                    //     Database.insert(dbLogListToInsert);
                    // }
                    if(res.getStatus()=='OK' && res.getStatusCode()==200 && String.isNotBlank(resBody)){
                        // if(dbLogListToInsert.size()>0){
                        //     Database.insert(dbLogListToInsert);
                        // }
                        return issueMatchValue;
                    }
                    // if(dbLogListToInsert.size()>0){
                    //     Database.insert(dbLogListToInsert);
                    // }
                    numAttempts --;
                }catch(Exception e){
                    dbl.Exception_Description__c=string.valueOf(e.getMessage());
                    dbLogListToInsert.add(dbl);
                    // if(dbLogListToInsert.size()>0){
                    //     Database.insert(dbLogListToInsert);
                    // }
                    numAttempts --;
                }
            }
            return null;
        }
        return null;
    }
    
    
   Public static String buildListString(List<String> items) {
        String listString = '';
        for (String item : items) {
            listString += '- ' + item + '\n';
        }
        return listString;
    }
    
    public class Message{
        public string role { get; set; }
        public string content { get; set; }
    }
    
    public class RequestData{
        public List<Message> messages { get; set; }
    }
    
    public class IssuePredectionWrapper{
        public string username { get; set; }
        public string password { get; set; }
        public Integer api { get; set; }
        public string model { get; set; }
        public RequestData request { get; set; }
    }
    
    // IssuePredectionResponseWrapper myDeserializedClass = JsonConvert.DeserializeObject<IssuePredectionResponseWrapper>(myJsonResponse);
    
    public class Choice1
    {
        public Integer index { get; set; }
        public string finish_reason { get; set; }
        public Message message { get; set; }
    }
    
    public class OpenAIResponse1
    {
        public string id { get; set; }
        public Integer created { get; set; }
        public string model { get; set; }
        public List<Choice1> choices { get; set; }
        public Usage1 usage { get; set; }
    }
    
    public class Response1
    {
        public OpenAIResponse1 openAIResponse { get; set; }
        public Integer StatusCode { get; set; }
        public Boolean isAuthenticated { get; set; }
    }
    
    public class IssuePredectionResponseWrapper
    {
        public string status { get; set; }
        public Response1 response { get; set; }
    }
    
    public class Usage1
    {
        public Integer prompt_tokens { get; set; }
        public Integer completion_tokens { get; set; }
        public Integer total_tokens { get; set; }
    }
    
    // Main class for OpenAI request
    public class OpenAIRequestWrapper {
        public String username { get; set; }
        public String password { get; set; }
        public Integer api { get; set; }
        public RequestWrapper request { get; set; }
        
        public OpenAIRequestWrapper() {
            this.username = 'sa_ugc';
            this.password = 'redBus@365';
            this.api = 1;
            this.request = new RequestWrapper();
        }
    }
    
    // Separate class for RequestWrapper
    public class RequestWrapper {
        public List<MessageWrapper> messages { get; set; }
        
        public RequestWrapper() {
            this.messages = new List<MessageWrapper>();
            this.messages.add(new MessageWrapper());
        }
    }
    
    // Separate class for MessageWrapper
    public class MessageWrapper {
        public String role { get; set; }
        public String content { get; set; }
        
        public MessageWrapper() {
            this.role = 'system';
            this.content = '';
        }
    }
    
}