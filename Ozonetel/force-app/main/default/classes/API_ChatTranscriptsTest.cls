@isTest
public class API_ChatTranscriptsTest
{
    
    
    public static testMethod void SuccessTest()
    {
        Test.startTest();
        
        LiveChatVisitor lv=new LiveChatVisitor();
        insert lv;
        
        LiveChatTranscript lcv =new LiveChatTranscript();
        lcv.EndTime=Datetime.newInstance(2023, 7, 29, 0, 0, 0);
        lcv.ChatKey='123456';
        lcv.LiveChatVisitorId=lv.id;
        insert lcv;
        
        datetime dt = Datetime.newInstance(2023, 7, 26, 0, 0, 0);
        Long epochDate = dt.getTime()/1000;
        
        dateTime endDt =Datetime.now().adddays(1);
        Long epochendate = endDt.getTime()/1000;
        
        string epcS = string.valueof(epochDate);
        system.debug('>>>epcS>>>>'+epcS);
        
        string epcEnd = string.valueof(epochendate);
        
        string reqEndpoint='/services/apexrest/redBus/getChatTranscripts?startFrom='+epochDate+'&endTo='+epochendate;
        system.debug('--reqEndpoint--'+reqEndpoint);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = reqEndpoint;
        req.httpMethod = 'GET';//HTTP Request Type
        req.addParameter('startFrom', epcS);
        req.addParameter('endTo', epcEnd);
        RestContext.request = req;
        RestContext.response= res;       
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        API_ChatTranscripts.getChatTranscripts();
        
        Test.stopTest();
    }    
    
}