@isTest
public class BpDpImagesCntrlTest{
    
    public static testMethod void bpdpImageCities()
    {
        Test.startTest();
        BpDpImagesCntrl bpdpimg = new BpDpImagesCntrl();
        bpdpimg.GetStatusVal();
        bpdpimg.region='IND';
        Continuation conti = (Continuation)bpdpimg.fetchAllCities();
        HttpResponse response = new HttpResponse();
        string  responseBody='[{"cityname":"Ahmedabad","cityid":551},{"cityname":"Bangalore","cityid":122},{"cityname":"Bangalorere","cityid":122},{"cityname":"Coimbatore","cityid":141},{"cityname":"Hyderabad","cityid":124},{"cityname":"Jaipur","cityid":807},{"cityname":"Mumbai","cityid":462},{"cityname":"Pune","cityid":130}]';  
        response.setBody(responseBody);
        Test.setContinuationResponse(bpdpimg.cityIdsResp, response);
        Object result = Test.invokeContinuationMethod(bpdpimg, conti);
        bpdpimg.region='';
        Test.stopTest();
    }
    
    public static testMethod void bpdpImagebpid()
    {
        Test.startTest();
        BpDpImagesCntrl bpdpimg = new BpDpImagesCntrl();
        bpdpimg.selectedCityid='122';
        bpdpimg.selectedOperatorid='122';
        bpdpimg.selectedBpId='123';
        Continuation conti = (Continuation)bpdpimg.fetchCityRelatedBpIds();
        HttpResponse response = new HttpResponse();
        string  responseBody='[{"countryCode":"IND","bpid":34771,"operatorid":400,"cityid":122,"operatorname":"SR Tours and Travels","bpname":"Anand Rao Circle"},{"countryCode":"IND","bpid":34925,"operatorid":1164,"cityid":122,"operatorname":"Manish Travels","bpname":"Domlur"}]';
        response.setBody(responseBody);
        Test.setContinuationResponse(bpdpimg.BpIdsResp, response);
        Object result = Test.invokeContinuationMethod(bpdpimg, conti);
        bpdpimg.selectedOperatorid='122';
        bpdpimg.fetchBpNames();
        Test.stopTest();
    }
    public static testMethod void bpdpImage()
    {
        Test.startTest();
        BpDpImagesCntrl bpdpimg = new BpDpImagesCntrl();
        bpdpimg.BpImageUpdateResp='test';
        bpdpimg.selectedOperatorid='400';
        bpdpimg.selectedBpId='34771';
        Continuation conti = (Continuation)bpdpimg.fetchBpImages();
        HttpResponse response = new HttpResponse();
        string  responseBody='[{"approvalstatus":0,"imgright":"bharat petroleum","cityname":"Bangalore","daynight":"DAY","cityid":122,"bpname":"Madiwala","operatorid":400,"countryCode":"IND","bpid":421673,"imgleft":"madiwala police station","side":"OPPOSITE","image":"https://rbbpimages.s3-ap-southeast-1.amazonaws.com/4x3/a1608e1f1a754d82e41f44ea1eda48855085454e79ba5b0fc883677bc948b2ee.jpeg","operatorname":"SR Tours and Travels","id":707},{"approvalstatus":0,"imgright":"bharat petroleum","cityname":"Bangalore","daynight":"DAY","cityid":122,"bpname":"Madiwala","operatorid":400,"countryCode":"IND","bpid":421673,"imgleft":"madiwala police station","side":"OPPOSITE","image":"https://rbbpimages.s3-ap-southeast-1.amazonaws.com/4x3/a1608e1f1a754d82e41f44ea1eda48855085454e79ba5b0fc883677bc948b2ee.jpeg","operatorname":"SR Tours and Travels","id":706}]';
        response.setBody(responseBody);
        Test.setContinuationResponse(bpdpimg.BpImageResp, response);
        Object result = Test.invokeContinuationMethod(bpdpimg, conti);
       BpDpImagesCntrl.ImageUpdateRequestWrapper imgupd= new BpDpImagesCntrl.ImageUpdateRequestWrapper(); 
        imgupd.id='1122';
        imgupd.imgleft ='right';
        imgupd.imgright ='left';
        imgupd.side ='test';
        imgupd.daynight ='night';
        imgupd.approvalstatus =2;
        imgupd.approvedby ='test';
        Test.stopTest();
    }
   public static testMethod void bpdpImageUpdateTest()
    {
        Test.startTest();
        
        BpDpImagesCntrl.ImageUpdateRequestWrapper imgupd= new BpDpImagesCntrl.ImageUpdateRequestWrapper(); 
        imgupd.id='1122';
        imgupd.imgleft ='right';
        imgupd.imgright ='left';
        imgupd.side ='test';
        imgupd.daynight ='night';
        imgupd.approvalstatus =2;
        imgupd.approvedby ='test';
        
        BpDpImagesCntrl.GetBpImages gtbpImg = new BpDpImagesCntrl.GetBpImages();
        gtbpImg.image ='bad';
        gtbpImg.bpname ='vrl';
        gtbpImg.bpid =2;
        gtbpImg.side ='test';
        gtbpImg.imgright ='test';
        gtbpImg.cityid =2;
        gtbpImg.approvalstatus =2;
        gtbpImg.id =32222;
        gtbpImg.operatorid=3;
        gtbpImg.daynight='night';
        gtbpImg.cityname  ='test';
        gtbpImg.imgleft='right';
        
        BpDpImagesCntrl.GetBpids gtbpid= new BpDpImagesCntrl.GetBpids();
        gtbpid.cityid=322;
        BpDpImagesCntrl.DisplayImageWrapper imagwrap= new BpDpImagesCntrl.DisplayImageWrapper(gtbpImg);
        imagwrap.selStatus='0';
        BpDpImagesCntrl bpdpimg = new BpDpImagesCntrl();
        bpdpimg.UpdateBpImageStatus();
     
        /*Continuation conti = (Continuation)bpdpimg .UpdateBpImageStatus();
        HttpResponse response = new HttpResponse();
        string  responseBody='Success';
        response.setBody(responseBody);
        Test.setContinuationResponse(bpdpimg .BpImageUpdateResp, response);
        Object result = Test.invokeContinuationMethod(bpdpimg, conti);*/
        Test.stopTest();
    }
    
    public static testMethod void bpdpImageCitiesFail()
    {
        Test.startTest();
        BpDpImagesCntrl bpdpimg = new BpDpImagesCntrl();
        bpdpimg.GetStatusVal();
        bpdpimg.region='IND';
        Continuation conti = (Continuation)bpdpimg.fetchAllCities();
        HttpResponse response = new HttpResponse();
        string  responseBody='';  
        response.setBody(responseBody);
        Test.setContinuationResponse(bpdpimg.cityIdsResp, response);
        Object result = Test.invokeContinuationMethod(bpdpimg, conti);
        bpdpimg.region='';
        Test.stopTest();
    }
    public static testMethod void bpdpImagebpidFail()
    {
        Test.startTest();
        BpDpImagesCntrl bpdpimg = new BpDpImagesCntrl();
        bpdpimg.selectedCityid='122';
        bpdpimg.selectedOperatorid='122';
        bpdpimg.selectedBpId='123';
        Continuation conti = (Continuation)bpdpimg.fetchCityRelatedBpIds();
        HttpResponse response = new HttpResponse();
        string  responseBody='';
        response.setBody(responseBody);
        Test.setContinuationResponse(bpdpimg.BpIdsResp, response);
        Object result = Test.invokeContinuationMethod(bpdpimg, conti);
        bpdpimg.selectedOperatorid='122';
        bpdpimg.fetchBpNames();
        Test.stopTest();
    }
    public static testMethod void bpdpImagefail()
    {
        Test.startTest();
        BpDpImagesCntrl bpdpimg = new BpDpImagesCntrl();
        bpdpimg.BpImageUpdateResp='test';
        bpdpimg.selectedOperatorid='400';
        bpdpimg.selectedBpId='34771';
        Continuation conti = (Continuation)bpdpimg.fetchBpImages();
        HttpResponse response = new HttpResponse();
        string  responseBody='';
        response.setBody(responseBody);
        Test.setContinuationResponse(bpdpimg.BpImageResp, response);
        Object result = Test.invokeContinuationMethod(bpdpimg, conti);
        Test.stopTest();
    }
 }