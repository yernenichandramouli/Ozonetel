@isTest
public class SeatImageApprovalControllerTest{
    
    public static testMethod void TestImageApproval()
    {
        Test.startTest();
        SeatImageApprovalController i=new SeatImageApprovalController ();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ImageApprovalController.ImageApprovalWrapper iw=new  ImageApprovalController.ImageApprovalWrapper();
        iw.ImageURL='testURL';
        iw.Status='Approved';
        iw.Imagetag='Front';
        iw.BusType='AC Sleeper';
        iw.BusTypeId='1234';
        iw.imCheck=true;
        
        
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');  
        
        //Test.setContinuationResponse(i.busOperatorIdsResp, response);
        i.selectedBusOperatorId='';
        i.opPickEnable=true;
        i.opTxtEnable=true;
        i.busOperatorIdsResp='test';
        i.typedBusOperatorId='AC';
        i.AllBusOperatorIds2();
        i.AllBusOperatorIdsResponse();
        i.GetImages();
        i.GetFilterImages();
        i.status='Approved';
        i.UpdateStatus();
        i.GetImagesResponse();
        List<SelectOption> selOpts= i.BusTypeNames;
        
        Test.stopTest();
    }
     public static testMethod void TestImageApproval2()
    {
        Test.startTest();
        SeatImageApprovalController i=new SeatImageApprovalController ();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ImageApprovalController.ImageApprovalWrapper iw=new  ImageApprovalController.ImageApprovalWrapper();
        iw.ImageURL='testURL';
        iw.Status='Approved';
        iw.Imagetag='Front';
        iw.BusType='AC Sleeper';
        iw.BusTypeId='1234';
        iw.imCheck=true;
        
        
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');  
        
        //Test.setContinuationResponse(i.busOperatorIdsResp, response);
        i.selectedBusOperatorId='';
        i.typedBusOperatorId='';
        i.opPickEnable=true;
        i.opTxtEnable=true;
        i.busOperatorIdsResp='test';
        i.AllBusOperatorIds2();
        i.AllBusOperatorIdsResponse();
        i.GetImages();
        i.GetFilterImages();
        i.status='Approved';
        i.UpdateStatus();
        i.GetImagesResponse();
        List<SelectOption> selOpts= i.BusTypeNames;
        
        Test.stopTest();
    }
    
    public static testMethod void TestImageApproval23()
    {
        Test.startTest();
        SeatImageApprovalController i=new SeatImageApprovalController ();
        string json='{"StatusMessage":"Only SMS sent successfully","IsEmailSent":false,"IsSMSSent":true,"EmailRespId":"","SMSRespId":"Campaign of 1 numbers Submitted successfully.","Data":null}';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        ImageApprovalController.ImageApprovalWrapper iw=new  ImageApprovalController.ImageApprovalWrapper();
        iw.ImageURL='testURL';
        iw.Status='Approved';
        iw.Imagetag='Front';
        iw.BusType='AC Sleeper';
        iw.BusTypeId='1234';
        iw.imCheck=true;
        
      
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');  
        
        //Test.setContinuationResponse(i.busOperatorIdsResp, response);
        i.selectedBusOperatorId='';
        i.typedBusOperatorId='';
        i.opPickEnable=true;
        i.opTxtEnable=true;
        i.busOperatorIdsResp='test';
        i.AllBusOperatorIds2();
        i.AllBusOperatorIdsResponse();
        i.GetImages();
        i.GetFilterImages();
        i.status='New';
        i.UpdateStatus();
        i.GetImagesResponse();
        List<SelectOption> selOpts= i.BusTypeNames;
        
        Test.stopTest();
    }
    
}