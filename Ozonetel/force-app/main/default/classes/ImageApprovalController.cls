public class ImageApprovalController {   
    public string selectedBusOperatorId{get;set;}
    public string typedBusOperatorId{get;set;}
    public string busTypeId{get;set;}
    public List<ImageApprovalWrapper> respWrapperList{get;set;}
    public list<string> operatorIdsList{get;set;}
    public string selectedBusType{get;set;}
    public string status{get;set;}
    public list<ImageApprovalWrapper> imWrapList{get;set;}
    public string GenericAPIEndpoint;
    public string GenericAPIEndpoint2;
    public API_EndPoints__mdt APIMData;
    public API_EndPoints__mdt APIMData2;
    public string genericJson;
    public string region{get;set;}
    public list<selectOption> BusOperatorIds{get;set;}
    private String returnedContinuationId ;
    public string busOperatorIdsResp{get;set;}
    public string getImagesResp{get;set;}
    public boolean imageBlock{get;set;}
    public set<string> allStatuses{get;set;}
    public map<string,integer> statusCount{get;set;}
    public boolean opPickEnable{get;set;}
    public boolean opTxtEnable{get;set;}
    public boolean opBusTypeNames{get;set;}
    
    public ImageApprovalController (){
        opBusTypeNames=false;
        statusCount=new map<string,integer>();
        respWrapperList=new list<ImageApprovalWrapper>();
        operatorIdsList=new list<string>();
        imWrapList=new list<ImageApprovalWrapper>(); 
        APIMData=new API_EndPoints__mdt();
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='GenericRBPlus'];     
        GenericAPIEndpoint=APIMData.Endpoint__c;
        APIMData2=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI2'];     
        GenericAPIEndpoint2=APIMData2.Endpoint__c;  
        allStatuses=new set<string>();
        BusOperatorIds=new list<selectOption>();
        // opEnable=true;
    }
    
    public object AllBusOperatorIds2(){
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RBPlusGetOperatorIds'];
        //string endPoint='http://54.169.159.213:90/api/BusImage/GetUnmoderatedOperatorsInfo?isInternationalOperator=false';
        string endPoint=APIMData.Endpoint__c+region;
        // genericJson='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":""}';
        genericJson='{"CountryCode":"'+region+'"}';
        Continuation con = new Continuation(60);
        con.continuationMethod='AllBusOperatorIdsResponse';
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req = HttpRequestUtil.populateHeaders(req);            
        req.setMethod('POST');            
        req.setEndpoint(GenericAPIEndpoint);
        req.setBody(genericJson);
        resp = ht.send(req );
        busOperatorIdsResp= con.addHttpRequest(req);
        return con;
    }
    
    public object AllBusOperatorIdsResponse() {
        
        HttpResponse resp= new HttpResponse(); 
        try{
            resp=Continuation.getResponse(busOperatorIdsResp);
            
            string json;
            if(!Test.isRunningTest()){
                json=resp.getbody();
            }else{
                json='{"4449":"Kallada Travels G4","15933":"Neeta Tours and Travels","9211":"Konduskar Travels Pvt. Ltd."}';
            }
            System.debug('json-->'+json);
            Map<string,string> ms=new map<string,string>();
            ms = (Map<string,string>)System.JSON.deserialize(json,Map<string,string>.class);
            // System.debug('ms-->'+ms.values());
            integer count=0;
            List<selectOption> options=new List<selectOption>();
            BusOperatorIds.clear();
            BusOperatorIds.add(new selectOption('--None--','--None--'));
            for(string s:ms.keyset()){
                if(count<999){
                    BusOperatorIds.add(new selectOption(s,ms.get(s)+'-'+s));
                    count++;
                }
            } 
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured, Please try again'));
        }               
        return null;
    }
    
    public object GetImages(){
        System.debug('calling get images');
        busTypeId='1098';
        selectedBusType='1098';
        opBusTypeNames=false;
        
        System.debug('selectedBusOperatorId-->'+selectedBusOperatorId+'<--typedBusOperatorId-->'+typedBusOperatorId);
        if((selectedBusOperatorId=='' ||selectedBusOperatorId=='--None--') && typedBusOperatorId!='' ){
            opTxtEnable=false;
            opPickEnable=true;
            selectedBusOperatorId=typedBusOperatorId;
        }else if((selectedBusOperatorId=='' ||selectedBusOperatorId=='--None--') && typedBusOperatorId==''){
            opTxtEnable=false;
            opPickEnable=false;
        }else if((selectedBusOperatorId!=''||selectedBusOperatorId!='--None--') && typedBusOperatorId==''){
            opTxtEnable=true;
            opPickEnable=false;
        }      
        
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RBPlusGetImages'];        
        //string endpointT='http://54.169.159.213:8085/api/BusImage/GetBusImageUrls/15926?IsInternationalOperator=false';
        // string endpointT='http://54.169.159.213:8085/api/BusImage/GetBusImageUrls/'+selectedBusOperatorId+'?IsInternationalOperator=false';
        string endpointT;
        if(region=='IND'){
            endpointT=APIMData.Endpoint__c+selectedBusOperatorId+'?IsInternationalOperator=false';
        }else{
            endpointT=APIMData.Endpoint__c+selectedBusOperatorId+'?IsInternationalOperator=true';
        }
        
        genericJson='{"action":"GET","body":"","endPoint":"'+endpointT+'","headers":""}';
        System.debug('g json-->'+genericJson);
        Continuation con = new Continuation(60);
        try{
            con.continuationMethod='GetImagesResponse';
            
            Http ht = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            req = HttpRequestUtil.populateHeaders(req);     
            req.setMethod('POST');      
            // API_EndPoints__mdt APIMData2=new API_EndPoints__mdt();
            // APIMData2=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_CMAPI'];     
            // string GenericAPIEndpoint2=APIMData2.Endpoint__c;  
            req.setEndpoint(GenericAPIEndpoint2);
            req.setBody(genericJson);
            getImagesResp= con.addHttpRequest(req);       
            return con;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured, Please try again'));
            return null;
        }
    }
    
    public object GetImagesResponse(){
        try{
            string json='[{ "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_1.png", "Status": "New", "ImageTag": "SEATS", "BusTypeId":"1098", "BusType":"Test 1234" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_2.png", "Status": "APPROVED", "ImageTag": "SIDE", "BusTypeId":"3214", "BusType":"Test 3214" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_3.png", "Status": "APPROVED", "ImageTag": "GANGWAY", "BusTypeId":"321", "BusType":"Test 456" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_4.png", "Status": "APPROVED", "ImageTag": "FRONT", "BusTypeId":"321", "BusType":"Test 654" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_5.png", "Status": "APPROVED", "ImageTag": "FRONT", "BusTypeId":"789", "BusType":"Test 789" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_6.png", "Status": "APPROVED", "ImageTag": "GANGWAY", "BusTypeId":"987", "BusType":"Test 987" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_7.png", "Status": "NEW", "ImageTag": "SIDE", "BusTypeId":"001", "BusType":"Test 001" } ]';
            if(Test.isRunningTest()){
                respWrapperList= (list<ImageApprovalWrapper>)System.JSON.deserialize(json,List<ImageApprovalWrapper>.class);  
            }
            HttpResponse resp= Continuation.getResponse(getImagesResp);
            system.debug('<<<resp'+resp);
            system.debug('<<<res body'+ resp.getBody());
            // string json='[{ "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_1.png", "Status": "APPROVED", "ImageTag": "SEATS", "BusTypeId":"123", "BusType":"Test 123" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_2.png", "Status": "APPROVED", "ImageTag": "SIDE", "BusTypeId":"321", "BusTypeName":"Test 321" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_3.png", "Status": "APPROVED", "ImageTag": "GANGWAY", "BusTypeId":"321", "BusTypeName":"Test 456" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_4.png", "Status": "APPROVED", "ImageTag": "FRONT", "BusTypeId":"321", "BusTypeName":"Test 654" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_5.png", "Status": "APPROVED", "ImageTag": "FRONT", "BusTypeId":"789", "BusTypeName":"Test 789" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_6.png", "Status": "APPROVED", "ImageTag": "GANGWAY", "BusTypeId":"987", "BusTypeName":"Test 987" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_7.png", "Status": "NEW", "ImageTag": "SIDE", "BusTypeId":"001", "BusTypeName":"Test 001" } ]';
            if(!Test.isRunningTest()){
                json=resp.getBody();
            }
            //System.debug('resp url-->'+resp.getBody());
            respWrapperList= (list<ImageApprovalWrapper>)System.JSON.deserialize(json,List<ImageApprovalWrapper>.class);
            system.debug('<<<respWrapperList'+respWrapperList);
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured, Please try again'));
        }         
        return null;
    }
    public set<string> ssOptions{get;set;}
    public string newItems{get;set;}
    
    public List<selectOption> BusTypeNames{
        get {
            set<selectOption> options = new set<selectOption>();
            ssOptions=new set<string>();
            try{
                integer count=0;
                newItems='';
                for (ImageApprovalWrapper c: respWrapperList){
                    if(c.Status=='New'){
                        ssOptions.add(c.BusTypeId);
                        newItems=newItems+c.BusType;
                    }
                    //   <optgroup label="c.BusType" style="background:#eaeaea;"></optgroup>
                    // SelectOption groupr = new SelectOption('1', '<optgroup label="Group 1" style="background:#eaeaea;"></optgroup>');
                    //  groupr.setEscapeItem(false);
                    if(c.BusType=='New'){
                        SelectOption entry = new SelectOption(c.BusTypeId,'<option value="' + c.BusType + '" style="font-weight:bold;color:red;">' + c.BusType + '</option>'); 
                        entry.setEscapeItem(false);
                        options.add(entry);
                    }
                    //options.add(groupr);
                    string busTypeName=c.BusType;
                    list<string> busT=new list<string>();
                    /* if(busT.contains(c.BusTypeId)  && (!busT.contains(c.BusTypeId) && c.Status=='New')){
options.add(new SelectOption(c.BusTypeId,c.BusType+'-New'));
busT.add(c.BusTypeId);
}
*/
                    //  options.add(new SelectOption(c.BusTypeId,c.BusType));
                    // options.add(new SelectOption(c.BusTypeId,'<option value="' + c.BusType + '" style="font-weight:bold;color:red;">' + c.BusType + '</option>'));
                    string ssN;
                    
                    if(!ssOptions.contains(c.BusTypeId) || c.BusType!='New'){
                        options.add(new SelectOption('--None--','--None--'));
                        if(c.Status=='New'){
                            ssN=c.BusType;
                            options.add(new SelectOption(c.BusTypeId,c.BusType+'-New'));
                            ssOptions.add(c.BusTypeId);
                            options.remove(new SelectOption(c.BusTypeId,c.BusType));
                        }else if(!ssOptions.contains(c.BusTypeId)){
                            
                            options.add(new SelectOption(c.BusTypeId,c.BusType));
                        }                    
                        
                    }
                    
                    //if(options.contains(options)){}
                }            
                System.debug('options-->'+options);
                list<selectoption> op=new list<selectOption>();
                op.addall(options);
                for(selectoption s:options){
                    
                }
                
                return op;
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured, Please try again'));  
                return null;         
            }            
            
        }
        set;
    }
    
    public void GetFilterImages(){
        imageBlock=true;
        System.debug('calling---');
        imWrapList.clear();
        allStatuses.clear();
        statusCount.clear();
        System.debug('selectedBusType-->'+selectedBusType);
        integer count=0;
        system.debug('<<<'+respWrapperList);
        system.debug('<<<<<'+selectedBusType);
        if(Test.isRunningTest()){
            string json='[{ "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_1.png", "Status": "New", "ImageTag": "SEATS", "BusTypeId":"1098", "BusType":"Test 1234" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_2.png", "Status": "APPROVED", "ImageTag": "SIDE", "BusTypeId":"3214", "BusType":"Test 3214" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_3.png", "Status": "APPROVED", "ImageTag": "GANGWAY", "BusTypeId":"321", "BusType":"Test 456" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_4.png", "Status": "APPROVED", "ImageTag": "FRONT", "BusTypeId":"321", "BusType":"Test 654" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_5.png", "Status": "APPROVED", "ImageTag": "FRONT", "BusTypeId":"789", "BusType":"Test 789" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_6.png", "Status": "APPROVED", "ImageTag": "GANGWAY", "BusTypeId":"987", "BusType":"Test 987" }, { "ImageURL": "https://s3-ap-southeast-1.amazonaws.com/rbplus/BusImage/Domestic/8277_1098_7.png", "Status": "NEW", "ImageTag": "SIDE", "BusTypeId":"001", "BusType":"Test 001" } ]';
            respWrapperList= (list<ImageApprovalWrapper>)System.JSON.deserialize(json,List<ImageApprovalWrapper>.class);  
        }
        
        for(ImageApprovalWrapper i:respWrapperList){
            system.debug('<<<<<'+selectedBusType+',,,'+i.BusTypeId);
            System.debug('ii-->'+i);
            if(selectedBusType==i.BusTypeId){                  
                if(statusCount.containsKey(i.status)){                   
                    statusCount.put(i.status,statusCount.get(i.status)+1);
                }else{
                    count=1;
                    statusCount.put(i.status,count);
                }
                System.debug('statusCount-->'+statusCount);
                allStatuses.add(i.status);                
                imWrapList.add(i);
            }            
        }
        System.debug('imWrapList--->'+imWrapList);
    }
    
    public void UpdateStatus(){
        
        /*  if(status=='--None--' || status==''){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select the status'));
}else{*/
        String selImages;
        String selApprImages;
        String selRejImages;
        string rejectReason;
        for(ImageApprovalWrapper s:imWrapList ){
            System.debug('sele-->'+s);
            string imageId=s.ImageURL;
            
            List<string> imageList=new List<string>();
            List<string> extList=new List<string>();
            imageList = imageId.split('/');
            imageId=imageList[imageList.size()-1];
            System.debug('imageId G-->'+imageId);
            extList=imageId.split('\\.');  
            System.debug('extList->'+extList);
            imageId=extList[0];
            /* System.debug('ss-->'+fs[fs.size()-1]);
if(region=='IND'){
imageId=imageList
imageId=imageId.SubStringafter('/Domestic/');
}else{
imageId=imageId.SubStringafter('/International/');
}
imageId=imageId.substringbefore('.');*/
            
            if(s.selType=='Approve'){
                selApprImages=selApprImages+','+imageId;
            }
            
            if(s.selType=='Reject'){
                selRejImages=selRejImages+','+imageId;
                if(s.RejectedReason =='Others'){
                    rejectReason=rejectReason+',"'+imageId+'":"'+s.oreason+'"' ;
                }
                else
                    rejectReason=rejectReason+',"'+imageId+'":"'+s.RejectedReason+'"' ;
            } 
            
            system.debug('ss-->'+imageId);
            /*   if(s.imCheck && (selImages=='' || selImages==null)){
selImages=imageId;
}else if(s.imCheck && selImages!=''){
selImages=selImages+','+imageId;
}*/
        }
        
        
        if(string.isNotBlank(selApprImages))
            selApprImages=selApprImages.replace('null,','');
        if(string.isNotBlank(selRejImages))
            selRejImages=selRejImages.replace('null,','');
        if(string.isNotBlank(rejectReason))
            rejectReason=rejectReason.replace('null,','');  
        string jsBody;
        System.debug('selApprImages->'+selApprImages);
        System.debug('selRejImages->'+selRejImages);
        if(selApprImages==null && selRejImages!=null){
            jsBody='{"REJECTED":"'+selRejImages+'"}';
        }else if(selApprImages!=null && selRejImages==null){
            jsBody='{"APPROVED":"'+selApprImages+'"}';
        }else{
            jsBody='{"APPROVED":"'+selApprImages+'", "REJECTED":"'+selRejImages+'"}';
        }
        // jsBody='{"APPROVED":"'+selApprImages+'", "REJECTED":"'+selRejImages+'"}';
        //string jsBody='{"APPROVED":"'+selApprImages+'", "REJECTED":"'+selRejImages+'"}';
        jsBody=JSON.serialize(jsBody);
        boolean isIntl;          
        APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RBPlusImageApproval'];
        string endPoint=APIMData.Endpoint__c+'CountryCode='+region+'&opId='+selectedBusOperatorId+'&busTypeID='+selectedBusType;
        genericJson='{"action":"PUT","body":'+jsBody+',"endPoint":"'+endPoint+'","headers":""}';
        System.debug('genericJson-->'+genericJson);
        DBLog_Summary__c dbl=new DBLog_Summary__c();
        dbl.Type__c='Image Approval';
        
        
        Http ht = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        req = HttpRequestUtil.populateHeaders(req);      
        req.setMethod('POST');        
        req.setEndpoint(GenericAPIEndpoint2);
        req.setBody(genericJson);
        System.debug('req-->'+req+'req body-->'+req.getbody());
        dbl.Request_Data__c=req.getbody();
        resp =ht.send(req);
        dbl.Response_Received__c=resp.getbody();
        System.debug('resp--9>'+resp.getbody());
        string subResponse=resp.getbody();
        if(Test.isRunningTest()){
            subResponse='true';
        }
        if(subResponse=='true'){
            if(string.isNotBlank(rejectReason)){
                jsBody='{'+rejectReason+'}';
                jsBody=JSON.serialize(jsBody);
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RB_Plus_Reject_Reason'];
                endPoint=APIMData.Endpoint__c+'?opId='+selectedBusOperatorId+'&busTypeID='+selectedBusType+'&countryCode='+region;
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Type','application/json');
                headers.put('Accept', 'application/json');
                list<HttpRequestWrappersUtil.GenericHeadersWrapper> hlist=new list<HttpRequestWrappersUtil.GenericHeadersWrapper>();
                for(string o:headers.keyset()){
                    hlist.add(new HttpRequestWrappersUtil.GenericHeadersWrapper(o,headers.get(o))); 
                }
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson);   
                genericJson='{"action":"PUT","body":'+jsBody+',"endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                System.debug('genericJson-->'+genericJson);
                ht = new Http();
                req = new HttpRequest();
                resp = new HttpResponse();
                req = HttpRequestUtil.populateHeaders(req);      
                req.setMethod('POST');        
                req.setEndpoint(GenericAPIEndpoint2);
                req.setBody(genericJson);
                System.debug('req-->'+req+'req body-->'+req.getbody());
                resp =ht.send(req);
                subResponse=resp.getbody();    
                System.debug('resp-->'+resp.getbody());
            }                
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='RBPlusGetOperatorIds'];
            //string endPoint='http://54.169.159.213:90/api/BusImage/GetUnmoderatedOperatorsInfo?isInternationalOperator=false';
            string endPoint2=APIMData.Endpoint__c+region;
            genericJson='{"action":"GET","body":"","endPoint":"'+endPoint2+'","headers":""}';
            //   Continuation con = new Continuation(60);
            //  con.continuationMethod='AllBusOperatorIdsResponse';
            Http ht2 = new Http();
            HttpRequest req2 = new HttpRequest();
            HttpResponse resp2 = new HttpResponse();
            req2 = HttpRequestUtil.populateHeaders(req2);            
            req2.setMethod('POST');            
            req2.setEndpoint(GenericAPIEndpoint2);
            req2.setBody(genericJson);
            resp2 = ht.send(req2 );   
            string json=resp2.getbody();
            if(Test.isRunningTest()){
                json='{"4449":"Kallada Travels G4","15933":"Neeta Tours and Travels","9211":"Konduskar Travels Pvt. Ltd."}';
            }
            
            System.debug('json-->'+json);
            Map<string,string> ms=new map<string,string>();
            ms = (Map<string,string>)System.JSON.deserialize(json,Map<string,string>.class);
            // System.debug('ms-->'+ms.values());
            integer count=0;
            List<selectOption> options=new List<selectOption>();
            BusOperatorIds.clear();
            BusOperatorIds.add(new selectOption('--None--','--None--'));
            for(string s:ms.keyset()){
                if(count<999){
                    BusOperatorIds.add(new selectOption(s,ms.get(s)+'-'+s));
                    count++;
                }
            }    
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Images are updated Successfully. Operator id->'+selectedBusOperatorId));
            dbl.Orders_Process_Status__c='Success';
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Update Failed!! Please try again/contact Admin'));
            dbl.Orders_Process_Status__c='Failed';
        }
        // selectedBusOperatorId='';
        // selectedBusType='';
        status='';
        // region='';
        //    BusOperatorIds.clear();
        // BusTypeNames=new  List<selectOption>();
        // BusTypeNames.clear();
        typedBusOperatorId='';
        imageBlock=false;
        opPickEnable=false;
        //opBusTypeNames=true;
        insert dbl;
        System.debug('returnedContinuationId -->'+returnedContinuationId );
        
        //}       
    }   
    public class ImageApprovalWrapper{
        public string ImageURL{get;set;}
        public string Status{get;set;}
        public string ImageTag{get;set;}
        public string BusTypeId{get;set;}
        public string BusType{get;set;}
        public boolean imCheck{get;set;}
        public string selType{get;set;}
        public string RejectedReason{get;set;}
        public string Oreason{get;set;}
        
    }
}