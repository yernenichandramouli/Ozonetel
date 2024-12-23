@isTest
public class CZentrix_Info_Test
{
    static testMethod void CZentrix_Info_try()
    {
        String xmlBody_Info = '<Agent_ID>Agent_ID</Agent_ID><Agent_Name>Agent_Name</Agent_Name><Campaign_Name>Campaign_Name</Campaign_Name><Customer_Ph_No>9966775544</Customer_Ph_No><Date_Time></Date_Time><CallDuration>CallDuration</CallDuration><IVRSPath>IVRSPath</IVRSPath><Skills>Skills</Skills><ListName>ListName</ListName><CustomerName>CustomerName</CustomerName><QueueTime>10</QueueTime><CallType>CallType</CallType><OrientationType>OrientationType</OrientationType><CallStatus>CallStatus</CallStatus><RedialFlag>RedialFlag</RedialFlag><MonitorFilePath>MonitorFilePath</MonitorFilePath><MonitorFileName>MonitorFileName</MonitorFileName><CustDisposition>CustDisposition</CustDisposition><CustCategory>CustCategory</CustCategory><TransferredFrom>TransferredFrom</TransferredFrom><TransferredTo>TransferredTo</TransferredTo><SessionID>SessionID0001</SessionID><CallRemarks>CallRemarks</CallRemarks><WrapupTime>WrapupTime</WrapupTime><Channel>Channel</Channel><NextCallTime>NextCallTime</NextCallTime><DIDNumber>DIDNumber</DIDNumber><PhoneType>PhoneType</PhoneType><WaitTime>WaitTime</WaitTime><HoldTime>HoldTime</HoldTime><DisconnectedBy>DisconnectedBy</DisconnectedBy><HoldNumTimes>10</HoldNumTimes><WrappedBy>WrappedBy</WrappedBy><ActualTalkTime>ActualTalkTime</ActualTalkTime><FinalCallStatus>FinalCallStatus</FinalCallStatus>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_Info);
        req.addParameter('<lead>'+xmlBody_Info+'</lead>', '');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.StartTest();
        CZentrix_Info.doPost();
        Test.StopTest();
    }
    
    static testMethod void CZentrix_Info_Catch()
    {
        String xmlBody_Info = '<Agent_ID>Agent_ID</Agent_ID><Agent_Name>Agent_Name</Agent_Name><Campaign_Name>Campaign_Name</Campaign_Name><Customer_Ph_No>9966005544</Customer_Ph_No><Date_Time></Date_Time><CallDuration>CallDuration</CallDuration><IVRSPath>IVRSPath</IVRSPath><Skills>Skills</Skills><ListName>ListName</ListName><CustomerName>CustomerName</CustomerName><QueueTime>10</QueueTime><CallType>CallType</CallType><OrientationType>OrientationType</OrientationType><CallStatus>CallStatus</CallStatus><RedialFlag>RedialFlag</RedialFlag><MonitorFilePath>MonitorFilePath</MonitorFilePath><MonitorFileName>MonitorFileName</MonitorFileName><CustDisposition>CustDisposition</CustDisposition><CustCategory>CustCategory</CustCategory><TransferredFrom>TransferredFrom</TransferredFrom><TransferredTo>TransferredTo</TransferredTo><SessionID>SessionID0002</SessionID><CallRemarks>CallRemarks</CallRemarks><WrapupTime>WrapupTime</WrapupTime><Channel>Channel</Channel><NextCallTime>NextCallTime</NextCallTime><DIDNumber>DIDNumber</DIDNumber><PhoneType>PhoneType</PhoneType><WaitTime>WaitTime</WaitTime><HoldTime>HoldTime</HoldTime><DisconnectedBy>DisconnectedBy</DisconnectedBy><HoldNumTimes>10</HoldNumTimes><WrappedBy>WrappedBy</WrappedBy><ActualTalkTime>ActualTalkTime</ActualTalkTime><FinalCallStatus>FinalCallStatus</FinalCallStatus>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.Valueof(xmlBody_Info);
        req.addParameter('<lead>'+xmlBody_Info+'</lead>', '');
        
        //RestContext.request = req;
        //RestContext.response= res;
        
        Test.StartTest();
        CZentrix_Info.doPost();
        Test.StopTest();
    }
}