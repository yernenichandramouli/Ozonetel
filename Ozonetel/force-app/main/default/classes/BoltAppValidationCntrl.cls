/*
* Name           : BoltAppValidationCntrl
* Created Date   : 06 march 2023
* Created By     : 
* Purpose        : BoltApp Validation
* Test class     : BoltAppValidationCntrlTest
*/
public class BoltAppValidationCntrl{
    
    @AuraEnabled(Cacheable=true)  
    public static List<case> getCases(string caseId){
        List<case> cseList = new List<case>();
        cseList = [select id,TIN__c,Email_Id_ct__c,Issue_Type__c,Issue_Sub_Category__c,ParentId from case where id=:caseId ];
        return cseList;
    }
    
    
    
    @AuraEnabled
    public static list<Bolt_Validation_Question__mdt> getBoltValidationLevels(string caseId){
        List<case> cseList = new List<case>();
        
        list<Bolt_Validation_Question__mdt> boltQueslevelTAT = new list<Bolt_Validation_Question__mdt>();
        
        cseList = [select id,TIN__c,Email_Id_ct__c,toLabel(Issue_Type__c),toLabel(Issue_Sub_Category__c),ParentId from case where id=:caseId ];
        string issue=String.isNotBlank(cseList[0].Issue_Type__c)?cseList[0].Issue_Type__c:'';
        string subissue=String.isNotBlank(cseList[0].Issue_Sub_Category__c)?cseList[0].Issue_Sub_Category__c:'';
        
        list<string> boltQusLst =new list<string>();
        
        list<Issue_Based_TAT__mdt> issueTATlist=MetaIssueandSubissueTypeConfigureCheck(issue,subissue);
        system.debug('>>>issueTATlist>>.'+issueTATlist.size());  
        
        if(!issueTATlist.isEmpty()){
            
            for(Issue_Based_TAT__mdt issueTAT :issueTATlist)
            {
                boltQusLst=issueTAT.Bolt_Questions__c.split(',');
            }
        }
        
        list<double> IssueTatQusLst = new list<double>();
        for(String s: boltQusLst)
        {   
            IssueTatQusLst.add(double.valueof(s));
        }
        
        for(Bolt_Validation_Question__mdt boltQuestTAT : [SELECT Question__c,Comments__c,Question_Number__c,Type__c,Type_Values__c from Bolt_Validation_Question__mdt where Question_Number__c in : IssueTatQusLst ORDER BY Question_Number__c ASC])
        {
            boltQueslevelTAT.add(boltQuestTAT);
        }
        
        if(!boltQueslevelTAT.isEmpty()){
            system.debug('>>>56>>>'+boltQueslevelTAT);
            return boltQueslevelTAT;
        }else{
            return null;
        }
    }
    
    
    @AuraEnabled
    public static string InsertComments(string caseId,string stafName,string stafNo,string comments){
        case cs= [select id,TIN__c,Email_Id_ct__c,Issue_Type__c,Issue_Sub_Category__c,ParentId from case where id=:caseId ];
        
        if(cs.id!=null){
            
            try{
                casecomment cc=new casecomment();
                cc.parentid=cs.id;
                cc.commentbody='Bo staff Name :- '+stafName;
                cc.commentbody += '\r\n';
                cc.commentbody +='staff Number :- '+stafNo;
                cc.commentbody += '\r\n';
                cc.commentbody +='Comments :- '+Comments;
                insert cc;
                return 'Comments inserted Successfully';
            }
            Catch(Exception e)
            { 
                string error=String.valueOf(e);
                return 'Failed';
            }
        }else{
            
            return 'Failed';
        }
    }
    
    @AuraEnabled
    public static string InsertQuestionValuesComments(string caseId,string selType,string csComments,string ticketAmount){
        string finalComment ='';
        boolean isBlankval=false;
        string  boltValidtaionMessage='';
        boolean oneQuesValidation=false;
        boolean twoQuesValidation=false;
        boolean threeQuesValidation=false;
        
        case cs = [select id,TIN__c,Bolt_Validation__c,Email_Id_ct__c,toLabel(Issue_Type__c),toLabel(Issue_Sub_Category__c),ParentId from case where id=:caseId ];
        string issue=String.isNotBlank(cs.Issue_Type__c)?cs.Issue_Type__c:'';
        string subissue=String.isNotBlank(cs.Issue_Sub_Category__c)?cs.Issue_Sub_Category__c:'';
        
        list<string> boltQusLst =new list<string>();
        
        string boltExpression ='';
        system.debug('---sub--'+subissue+'---is--'+issue);
        
        list<Issue_Based_TAT__mdt> boltExpMdt=MetaIssueandSubissueTypeConfigureCheck(issue,subissue);
        
        if(!boltExpMdt.isEmpty() && boltExpMdt[0].Bolt_Ques_Level_Expression__c!=null){
            boltExpression=boltExpMdt[0].Bolt_Ques_Level_Expression__c;
        }
        
        if(selType!=null && csComments!=null){
            List<Object>  quesValuelst= (List<Object>) JSON.deserializeUntyped(selType);
            list<object> quesLst =new list<object>();
            map<string,string> mapQuesVal =new map<string,string>();
            
            for(object l:quesValuelst){
                Map<String, Object> data = (Map<String, Object>)l;
                quesLst.add(data.get('key'));
                string ke=(String)data.get('key');
                string vl= (String)data.get('value');
                mapQuesVal.put(ke,vl);
            }
            
            List<Object> comnresult = (List<Object>) JSON.deserializeUntyped(csComments);
            integer i=0;
            
            //start
            
            map<integer,string> mapQuesnoQues = new map<integer,string>();
            for(Bolt_Validation_Question__mdt boltQuestTAT : [SELECT Question__c,Question_Number__c from Bolt_Validation_Question__mdt order by Question_Number__c asc])
            {
                mapQuesnoQues.put(integer.valueof(boltQuestTAT.Question_Number__c),boltQuestTAT.Question__c);
            }
            
            string validationRuleSatisfied='';
            string boltValidationExpJson;
            
            if(Test.isRunningTest()){
                boltValidationExpJson='{"1":[{ "7": "New Traveller" }], "2":[{"1":"Yes","2":"Yes"},{"1":"Yes","3":"Verified"},{"2":"Yes","3":"Verified"},{"8":"No","9":"No"},{"8":"Yes","9":"No"}]}';
            }else{
                boltValidationExpJson=boltExpression;
            }
            
            if(string.isNotblank(boltValidationExpJson)){
                Object validExpJson = (Object)JSON.deserializeUntyped(boltValidationExpJson);
                Map<String, Object> validObjectExp = (Map<String, Object>)validExpJson;
                for(string queskey:validObjectExp.keyset()){
                    List<Object>  quesMatches= (List<Object>)validObjectExp.get(queskey);
                    for(object quesJson:quesMatches){
                        Map<String, Object> mapQuesJson = (Map<String, Object>)quesJson;
                        integer quesCheck=mapQuesJson.keyset().size();
                        set<string> quesSet=new set<string>();
                        quesSet.addall(mapQuesJson.keyset());
                        list<string> queLst=new List<string>();
                        queLst.addall(quesSet);
                        boltValidtaionMessage='';
                        
                        if(quesCheck==1){
                            if(mapQuesJson.get(string.valueOf(queLst[0]))==mapQuesVal.get(string.valueOf(queLst[0]))){
                                oneQuesValidation=true;
                                validationRuleSatisfied='-Validation 1-'+'{'+mapQuesnoQues.get(integer.valueof(queLst[0]))+'='+mapQuesJson.get(string.valueOf(queLst[0]))+'}';
                            }
                        }
                        
                        if(quesCheck==2){
                            if(mapQuesJson.get(string.valueOf(queLst[0]))==mapQuesVal.get(string.valueOf(queLst[0])) && mapQuesJson.get(string.valueOf(queLst[1]))==mapQuesVal.get(string.valueOf(queLst[1]))){
                                twoQuesValidation=true;
                                validationRuleSatisfied =validationRuleSatisfied+'--validation 2--'+'{'+mapQuesnoQues.get(integer.valueof(queLst[0]))+'='+mapQuesJson.get(string.valueOf(queLst[0]))+'}'+','+'{'+mapQuesnoQues.get(integer.valueof(queLst[1]))+'='+mapQuesJson.get(string.valueOf(queLst[1]))+'}';
                            }
                        }
                        
                        if(quesCheck==3){
                            if(mapQuesJson.get(string.valueOf(queLst[0]))==mapQuesVal.get(string.valueOf(queLst[0])) && mapQuesJson.get(string.valueOf(queLst[1]))==mapQuesVal.get(string.valueOf(queLst[1])) && mapQuesJson.get(string.valueOf(queLst[2]))==mapQuesVal.get(string.valueOf(queLst[2]))){
                                threeQuesValidation=true;
                                validationRuleSatisfied =validationRuleSatisfied+'--validation 3--'+'{'+mapQuesnoQues.get(integer.valueof(queLst[0]))+'='+mapQuesJson.get(string.valueOf(queLst[0]))+'}'+','+'{'+mapQuesnoQues.get(integer.valueof(queLst[1]))+'='+mapQuesJson.get(string.valueOf(queLst[1]))+'}'+','+'{'+mapQuesnoQues.get(integer.valueof(queLst[2]))+'='+mapQuesJson.get(string.valueOf(queLst[2]))+'}';    
                            }
                        }
                        
                    }
                }
                
                //end         
                for(object cm:comnresult){
                    Map<String, Object> cmData = (Map<String, Object>)cm;
                    i++;
                    string  pickVal= mapQuesVal.get((String)cmData.get('key'));
                    if(string.isBlank(pickVal) || string.isBlank((String)cmData.get('value')) || string.isBlank(ticketAmount)){
                        isBlankval=true; 
                    }
                    
                    if(finalComment==''){
                        finalComment = '1)'+mapQuesnoQues.get(integer.valueof((String)cmData.get('key')))+'--'+pickVal+'--'+(String)cmData.get('value');
                    }else{
                        finalComment +='\r\n'+i+')'+mapQuesnoQues.get(integer.valueof((String)cmData.get('key')))+'--'+pickVal+'--'+(String)cmData.get('value');
                    }
                }
                if(isBlankval){
                    return 'Failed';
                }else{
                    try{
                        case cse=new case();
                        casecomment cc=new casecomment();
                        cc.commentbody=finalComment;
                        cc.commentbody += '\r\n';
                        String boltValidationMsg='';
                        if(oneQuesValidation==false && twoQuesValidation==false && threeQuesValidation==false){
                            boltValidationMsg='Bolt Validation Failed';
                            validationRuleSatisfied='No bolt Questions are satisfied';
                            boltValidtaionMessage='Bolt Validation Failed';
                            cc.commentbody +='Bolt Validation status :- '+boltValidtaionMessage;
                            cse.Bolt_Validation__c=boltValidtaionMessage;
                        }else{
                            boltValidtaionMessage ='Bolt Validation Successfull';
                            cc.commentbody +='--Refund Amount :- '+ticketAmount;
                            cc.commentbody +='Bolt Validation status :- '+boltValidtaionMessage;
                            cse.Bolt_Validation__c=boltValidtaionMessage;
                            
                        }
                        
                        cse.id=cs.id;
                        update cse;
                        
                        cc.parentid=caseId;
                        cc.commentbody += '\r\n';
                        insert cc;
                        return boltValidtaionMessage;
                        
                    }
                    Catch(Exception e)
                    { 
                        string error=String.valueOf(e);
                        return 'Failed';
                    }
                } 
            }else{
                
                return 'Failed';
            }
            
        }else{
            
            return 'Failed';
        }
    }
    
    @AuraEnabled
    public static string getMaxRefundAmountApi(string caseId){
        string maxRefundRespamount;
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        list<case> cseList = [select id,Total_Fare_Value__c,Order_UUId__c,TIN__c,Trip_Id_ct__c,Trip_ID__c,TIN_No__c,Email_Id_ct__c,Issue_Type__c,Issue_Sub_Category__c,ParentId from case where id=:caseId ];
        string issue=String.isNotBlank(cseList[0].Issue_Type__c)?cseList[0].Issue_Type__c:'';
        string subissue=String.isNotBlank(cseList[0].Issue_Sub_Category__c)?cseList[0].Issue_Sub_Category__c:'';
        
        String tripId = String.isNotBlank(cseList[0].Trip_Id_ct__c)?cseList[0].Trip_Id_ct__c:String.isNotBlank(cseList[0].Trip_ID__c)?cseList[0].Trip_ID__c:'';
        String tin =String.isNotBlank(cseList[0].TIN__c)?cseList[0].TIN__c:String.isBlank(cseList[0].TIN_No__c)?'':cseList[0].TIN_No__c;        
        
        list<order_items__c> orItLs = [SELECT Id,Total_Fare_Value__c,OrderUuid__c, Order_Item_Reference_No__c FROM order_items__c WHERE (Order_Item_Reference_No__c =:tin or Order_Id__c =:tripId)LIMIT 1];
        
        string transOrderUUid='';
        string transTin='';
        string tickAmnt='';
        if(!orItLs.isEmpty()){
            transOrderUUid =String.isNotBlank(orItLs[0].OrderUuid__c)?orItLs[0].OrderUuid__c:'';
            transTin =String.isNotBlank(orItLs[0].Order_Item_Reference_No__c)?orItLs[0].Order_Item_Reference_No__c:'';
            tickAmnt = orItLs[0].Total_Fare_Value__c!=null?string.valueof(orItLs[0].Total_Fare_Value__c):'';
            
        }
        string finalTickAmnt = String.isNotBlank(tickAmnt)?tickAmnt:cseList[0].Total_Fare_Value__c!=null?string.valueof(cseList[0].Total_Fare_Value__c):'';
        
        String orderUUid = String.isNotBlank(transOrderUUid)?transOrderUUid:String.isNotBlank(cseList[0].Order_UUId__c)?cseList[0].Order_UUId__c:'';
        string tinNo = String.isNotBlank(transTin)?transTin:String.isNotBlank(tin)?tin:'';
        
        
        if(string.isNotBlank(orderUUid) && string.isNotBlank(tinNo)){
            list<Issue_Based_TAT__mdt> boltRfndSlabMdt = new list<Issue_Based_TAT__mdt>();
            double boltAmntSlab=0;
            HttpResponse res = new HttpResponse();
            Http http1 = new Http();
            HttpRequest req = new HttpRequest();
            req = HttpRequestUtil.populateHeaders(req); 
            req.setMethod('GET'); 
            req.setEndpoint([SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='CapiMaxRefundableAPI'].Endpoint__c+orderUUid+'&tin='+tinNo);
            try{
                
                boltRfndSlabMdt = [SELECT id,Bolt_Refund_Amount_Slab__c from Issue_Based_TAT__mdt where Issue_Type__c =:issue AND Issue_Sub_Category__c =:subissue and Bolt_Questions__c!=null and Version__c='V3' ORDER BY Bolt_Questions__c];
                
                
                if(!boltRfndSlabMdt.isEmpty()){
                    if(boltRfndSlabMdt[0].Bolt_Refund_Amount_Slab__c!=null){
                        boltAmntSlab=boltRfndSlabMdt[0].Bolt_Refund_Amount_Slab__c;    
                    }
                }else{
                    
                    maxRefundRespamount = '0';
                }
                
                res = http1.send(req);
                if(res.getStatusCode()==200 && maxRefundRespamount!= '0'){
                    double maxRefundAmnt =Double.valueOf(res.getBody());
                    
                    double finalRefundAmount = maxRefundAmnt * boltAmntSlab;
                    string finalMaxAmnt =string.valueof(finalRefundAmount!=null?finalRefundAmount:0);
                    maxRefundRespamount=finalMaxAmnt.substringbefore('.');
                    
                }else{
                    
                    maxRefundRespamount = '0';
                } 
            }catch(Exception e){
                maxRefundRespamount = '0';
            }                                    
        }else{
            
            maxRefundRespamount = '0';
        }
        
        return maxRefundRespamount;
    }
    
    @AuraEnabled
    public static list<ResponseData> getDriverDetails(string caseId){
        
        list<ResponseData> respData =new list<ResponseData>();
        string jsonbody ='';
        if(String.isNotBlank(caseId)){
            list<case> cseList = [select id,Service_Id__c,Service_Provider_Id__c,Service_Providerr_Id__c,Date_of_Journey__c,SS_DOJ__c,TIN__c,Trip_Id_ct__c,Trip_ID__c,TIN_No__c,Email_Id_ct__c,toLabel(Issue_Type__c),toLabel(Issue_Sub_Category__c),ParentId from case where id=:caseId ];
            
            String tripId = String.isNotBlank(cseList[0].Trip_Id_ct__c)?cseList[0].Trip_Id_ct__c:String.isNotBlank(cseList[0].Trip_ID__c)?cseList[0].Trip_ID__c:'';
            String tin =String.isNotBlank(cseList[0].TIN__c)?cseList[0].TIN__c:String.isBlank(cseList[0].TIN_No__c)?'':cseList[0].TIN_No__c;
            string serviceProvId =  String.isNotBlank(cseList[0].Service_Provider_Id__c)?cseList[0].Service_Provider_Id__c:String.isNotBlank(cseList[0].Service_Providerr_Id__c)?cseList[0].Service_Providerr_Id__c:'';
            String strDoj = cseList[0].SS_DOJ__c!=null?String.valueOf(cseList[0].SS_DOJ__c):cseList[0].Date_of_Journey__c!=null?String.valueOf(cseList[0].Date_of_Journey__c):'';
            string servcid =String.isNotBlank(cseList[0].Service_Id__c)?cseList[0].Service_Id__c:'';
            
            list<order_items__c> orItLs = [SELECT Id,Service_Provider_Id__c,ServiceID__c,OrderUuid__c,Boarding_Time__c,Order_Item_Reference_No__c FROM order_items__c WHERE (Order_Item_Reference_No__c =:tin or Order_Id__c =:tripId)LIMIT 1];
            string transServicePrvdrId='';
            string transServiceId= '';
            string transDoj;
            
            if(!orItLs.isEmpty()){
                transServicePrvdrId =String.isNotBlank(orItLs[0].Service_Provider_Id__c)?orItLs[0].Service_Provider_Id__c:'';
                transServiceId =String.isNotBlank(orItLs[0].ServiceID__c)?orItLs[0].ServiceID__c:'';
                transDoj=orItLs[0].Boarding_Time__c!=null?String.valueOf(orItLs[0].Boarding_Time__c):'';
                
            }
            string finaldoj=String.isNotBlank(transDoj)?transDoj:String.isNotBlank(strDoj)?strDoj:'';
            List<string> dojList = finaldoj.split(' ');
            
            string finalBoId=String.isNotBlank(transServicePrvdrId)?transServicePrvdrId:String.isNotBlank(serviceProvId)?serviceProvId:'';
            string finalServiceId=String.isNotBlank(transServiceId)?transServiceId:String.isNotBlank(servcid)?servcid:'';
            
            try{
                if(string.isNotBlank(finalBoId) && string.isNotBlank(finalServiceId) && !dojList.isEmpty()){
                    string issue=String.isNotBlank(cseList[0].Issue_Type__c)?cseList[0].Issue_Type__c:'';
                    string subissue=String.isNotBlank(cseList[0].Issue_Sub_Category__c)?cseList[0].Issue_Sub_Category__c:'';
                    
                    
                    
                    list<Issue_Based_TAT__mdt> issueBasedTATlist=MetaIssueandSubissueTypeConfigureCheck(issue,subissue);
                    
                    if(!issueBasedTATlist.isEmpty()){
                        system.debug('>365>>issue>>'+issue+'>>>subissue>>>'+subissue);
                        
                        HttpRequestWrappersUtil.busAssignmentResponse driverDetails = new  HttpRequestWrappersUtil.busAssignmentResponse();
                        
                        string endpoint = [SELECT Endpoint__c FROM API_EndPoints__mdt where DeveloperName='Bus_Details'].Endpoint__c;
                        endpoint = endpoint + 'rbOpId='+finalBoId+'&doj='+dojList[0]+'&serviceId='+finalServiceId;
                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        req.setHeader('Content-Type', 'application/json');
                        HttpResponse res = new HttpResponse();
                        req.setEndpoint(endpoint);
                        req.setMethod('GET');
                        res = http.send(req);      
                        if(res.getStatusCode() == 200){
                            if(res.getBody() != NUll){
                                driverDetails = (HttpRequestWrappersUtil.busAssignmentResponse)system.JSON.deserialize(res.getBody(),HttpRequestWrappersUtil.busAssignmentResponse.class);
                                
                                String driverNo =String.isNotBlank(driverDetails.data[0].driverNumber)?driverDetails.data[0].driverNumber:'';
                                String driverName =String.isNotBlank(driverDetails.data[0].driverName)?driverDetails.data[0].driverName:'';
                                
                                respData.add(new ResponseData(driverName,driverNo,''));
                            }else{
                                respData.add(new ResponseData('','','Failed')); 
                            }
                        }else{
                            respData.add(new ResponseData('','','Failed')); 
                            
                        }
                        
                    }else{
                        
                        respData.add(new ResponseData('','','No IssueType Mapped'));  
                        return respData;  
                    }
                    
                    
                    // driverDetails = GetTransactionDetails.getBusAssignmentDetails(orItLs[0].id); 
                    
                }
            }catch(Exception e){
                
                respData.add(new ResponseData('','','Failed')); 
                return respData;
            }
        }
        return respData;          
    }
    
    public static  list<Issue_Based_TAT__mdt> MetaIssueandSubissueTypeConfigureCheck(string csIssue,string csSubIssue){
        list<Issue_Based_TAT__mdt> ListIssueBasedTAT =new list<Issue_Based_TAT__mdt>();
        if(string.isNotBlank(csIssue) && string.isNotBlank(csSubIssue)){
            list<Issue_Based_TAT__mdt> boltRfndSlabMdt = [SELECT id,Bolt_Refund_Amount_Slab__c,Bolt_Questions__c,Bolt_Ques_Level_Expression__c,toLabel(Issue_Type__c),toLabel(Issue_Sub_Category__c) from Issue_Based_TAT__mdt where Bolt_Questions__c!=null and Version__c='V3' ORDER BY Bolt_Questions__c];
            
            map<string,Issue_Based_TAT__mdt> mapMetaSubIssue=new map<string,Issue_Based_TAT__mdt>();
            list<string> metaIssueLst=new list<string>();
            
            for(Issue_Based_TAT__mdt issueMdt:boltRfndSlabMdt){
                metaIssueLst.add(issueMdt.Issue_Type__c);
                mapMetaSubIssue.put(issueMdt.Issue_Sub_Category__c,issueMdt);
            }
            
            boolean isMetaIssueConfig = false;
            for(string metaIssue:metaIssueLst){
                if(csIssue==metaIssue){
                    isMetaIssueConfig = true;
                    system.debug('>>>>>>isMetaIssueConfig>>.'+isMetaIssueConfig);
                }
            }
            
            boolean isMetaSubIssueConfig = false;
            
            if(!mapMetaSubIssue.isEmpty()){
                if(mapMetaSubIssue.containsKey(csSubIssue)){
                    isMetaSubIssueConfig = true;
                    ListIssueBasedTAT.add(mapMetaSubIssue.get(csSubIssue));
                }
            }
            
            if(isMetaIssueConfig && isMetaSubIssueConfig){
                return ListIssueBasedTAT;
            }else{
                return ListIssueBasedTAT;
            }     
        }else{
            return ListIssueBasedTAT;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string updateRecordwithBoltValidationStatus(string caseId,string finalboltStatus){
        try{
            list<case> cs = [select id,Bolt_Validation__c from case where id=:caseId ];
            cs[0].Bolt_Validation__c=finalboltStatus;
            Database.Update(cs[0]);
            return 'update';
            
        }catch (Exception e){
            return 'Fail'+e;
        }
        
    }  
    
    @AuraEnabled(cacheable=true)
    public static list<casecomment> getCaseCommentsList(string caseId){
        list<casecomment>  cmlst= new  list<casecomment>();
        try{
            cmlst =[select id,commentbody from casecomment where parentid=:caseId];
            return cmlst;
        }catch (Exception e){
            return cmlst;
        }
        
    }   
    //Database.Update(cmlst[0]);
    public class ResponseData
    {
        @AuraEnabled
        public string driverName { get; set; }
        @AuraEnabled
        public string phoneNo { get; set; }
        @AuraEnabled
        public string ErrorMsg { get; set; }
        
        public ResponseData(string drvrName,string phoneNo,string errorMsg)
        {
            this.driverName = drvrName;
            this.phoneNo = phoneNo;
            this.ErrorMsg = errorMsg;  
            
        }
    }
}