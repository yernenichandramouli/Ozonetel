/*
* Name           : API_CaseCommentInsert
* Created Date   : 12 July 2018
* Created By     : Veeramanikanta R
* Purpose        : API to insert case comment
* Test class     : API_CaseCommentInsertTest
*/
@RestResource(urlMapping='/redBus/CaseCommentInsert/*')
global without sharing class API_CaseCommentInsert
{
    @HttpPost
    global static ResponseWrapper CaseCommentsInsert()
    {
        RestRequest req = RestContext.request;       
        RestResponse res = RestContext.response;
        ResponseWrapper resp=new ResponseWrapper();
        try{
            string channel=req.headers.get('channel'); 
            string js='{"caseId":"1234","caseComment":"Test Comment"}';
            System.debug('res s-->'+req.requestBody.toString());
            caseCommentsWrapper  cd= (caseCommentsWrapper)JSON.deserialize(req.requestBody.toString(),caseCommentsWrapper.class);   
            if(String.isBlank(cd.comment) && String.isBlank(cd.attachmentURLs)){
                res.statuscode = 400;
                resp.caseId=cd.caseId;
                resp.message='Comment as well as attachment can not be empty';
                return resp;
            }
            List<case> csList=new List<case>(); 
            Set<String> issueTypes = new Set<String>();
            Set<String> issueTypesToSkip = new Set<String>();
            issueTypesToSkip.addAll(System.Label.issueTypes_To_skip_for_RPW_automation.split(','));
            Set<String> subIssueTypes = new Set<String>();
            issueTypes.addAll(System.Label.IssueTypes_SH.split(','));
            subIssueTypes.addAll(System.Label.SubIssueTypes_SH.split(','));
            
            csList=[select id,casenumber,My_Desk_Id__c,Transaction_ID__r.RecordType.Name,ownerid,origin,status,Issue_Type__c,Issue_Sub_Category__c,Re_Opened_By__c,Re_Open_Time__c,BO_Agreed_for_Refund__c,Refund_Amount__c,BO_Agreed_RB__c,Trip_Id_ct__c,TIN_No__c,Description,Transaction_ID__c,Booking_Email_ID__c,ParentId,Business_Unit_ct__c,Business_Type__c,country__c,Price_Paid_Currency_ctp__c,BO_Action__c,First_BO_Action__c,Assigned_By__c,Attachment_URLs__c,SH_Attachment_URLs__c,Refund_Type__c from case where casenumber =:cd.caseId limit 1];
            if(!csList.isEmpty()){
                casecomment cc=new casecomment();
                cc.parentid=csList[0].id;
                List<case> createExceptionalRefundCaseList = New List<case>();
                if(channel=='RB+'){                    
                    cc.commentbody='BO Reply->'+cd.comment;
                    list<user> usLst=new list<user>(); 
                    usLst=[select id,username,Profile.name from user where id=:csList[0].ownerid];  
                    if(!usLst.isEmpty() && usLst[0].Profile.name.contains('InBound')){                
                    Id sitQueueId = [Select id from Group where type='Queue' AND developername='SIT_Cases_Queue'].id;                    
                    csList[0].ownerid=sitQueueId;
                    }else if(string.isNotBlank(csList[0].Assigned_By__c)){
                       list<user> usrLs=new list<user>();
                       usrLs=[select id,username,isactive from user where id=:csList[0].Assigned_By__c]; 
                       if(!usrLs.isEmpty() && usrLs[0].isactive)
                          csList[0].ownerid=csList[0].Assigned_By__c;                    
                    }
                    if(csList[0].Transaction_ID__r.RecordType.Name =='Bus Booking'){
                        csList[0].Max_Refund_Amount__c = cd.maxRefundAmount;
                    }
                    
                    if(csList[0].status!='Closed')
                       csList[0].status='BO Replied';
                    
                    if(string.isNotBlank(cd.boAgreed))
                       csList[0].BO_Agreed_RB__c=cd.boAgreed;
                    if(string.isNotBlank(cd.refundType))
                       csList[0].Refund_Type__c=cd.refundType;
                    if(csList[0].BO_Action__c==null ||csList[0].BO_Action__c== 0){
                        csList[0].BO_Action__c=1;
                        csList[0].First_BO_Action__c=system.now();
                    }else{
                        csList[0].BO_Action__c=csList[0].BO_Action__c+1;
                    }
                    if(cd.excepRefAmount!=null && cd.processExcepRef!=null && cd.processExcepRef){
                        //csList[0].status='Approved For Exceptional Refund';
                        csList[0].BO_Agreed_for_Refund__c=true;
                        csList[0].Refund_Amount__c=cd.excepRefAmount;
                        csList[0].Refund_status__c='Pending';   
                        List<case> csExp=new list<case>();
                        csExp=[select id,casenumber from case where Issue_Type__c = 'Exceptional Refund' and status='Closed' and status='Approved For Exceptional Refund'  and Transaction_ID__c=:csList[0].Transaction_ID__c ];
                        if(!csExp.isEmpty()){
                            res.statuscode = 400;
                            resp.caseId=cd.caseId;
                            resp.message='Exceptional Refund Case aleady exist for this case';
                        }else{
                            list<case> csCk=new list<case>();
                            csCk=[select id,casenumber from case where Issue_Type__c = 'Exceptional Refund' and status='Rejected For Exceptional Refund' and Transaction_ID__c=:csList[0].Transaction_ID__c ];
                            if(!csCk.isEmpty()){
                                csCk[0].Refund_status__c='Pending';
                                csCk[0].status= 'Open';
                                csCk[0].Refund_Amount__c = csList[0].Refund_Amount__c;
                                update csCk;
                            }      
                        }      
                    }

                    // CRM - 1778 
                    if(!issueTypesToSkip.contains(csList[0].Issue_Type__c) && cd.previouscaseTabStatus=='Open' && (csList[0].Transaction_ID__r.RecordType.Name =='Bus Booking' || (csList[0].Transaction_ID__r.RecordType.Name =='B2B Bus Booking' && string.isNotBlank(csList[0].My_Desk_Id__c)))){
                        createExceptionalRefundCaseList.add(csList[0]);
                    }
                    insert cc;
                    update csList;
                    if(!createExceptionalRefundCaseList.isEmpty()){
                        rpwAutomationCasesCtrl.CreateExceptionalRefundCase(createExceptionalRefundCaseList[0].Id);
                    }
                }else{
                    if(String.isBlank(cd.comment)) {
                        cc.commentbody = 'System Comment -> Attachments without any comments were shared by the user.';
                    }
                    else {
                        cc.commentbody=cd.comment;
                    }
                    resp.caseOldStatus=csList[0].status;
                    
                    if(csList[0].status=='Closed' && (issueTypes.contains(csList[0].Issue_Type__c) || subIssueTypes.contains(csList[0].Issue_Sub_Category__c ))){
                        csList[0].status='Re-Open';
                        csList[0].Re_Opened_By__c='Re-Opened from SH-Comment';
                        csList[0].Re_Open_Time__c=System.now();
                    }else if(csList[0].status=='Waiting for Customer'){
                        csList[0].status='Customer Revert';
                    }
                    if(string.isNotBlank(cd.attachmentURLs)){
                        List<String> lstAttach = cd.attachmentURLs.split(',');
                        String url=lstAttach[0];
                        lstAttach.remove(0);
                        if(lstAttach.size() > 0){
                                for(String attch:lstAttach) {
                                    url = url +' , '+attch;
                                }
                            }
                        if(string.isNotBlank(csList[0].SH_Attachment_URLs__c)){
                            system.debug('the previous url is=='+csList[0].SH_Attachment_URLs__c);
                            csList[0].SH_Attachment_URLs__c=csList[0].SH_Attachment_URLs__c+' , '+url ;
                            system.debug('the new url is=='+csList[0].SH_Attachment_URLs__c);
                        }
                        else{
                            csList[0].SH_Attachment_URLs__c=url;
                            system.debug('the new url is=='+csList[0].SH_Attachment_URLs__c);
                        }
                    }
                    list<attachment> attachmentToInsert = new list<attachment>();
                        if(cd.attachments!=null && cd.attachments.size()>0 ){ 
                                    system.debug('dataattachments-->>'+cd.attachments.size());
                                    for (Attach  att :cd.attachments)                                   
                                        attachmentToInsert.add( new Attachment(parentId = csList[0].id, name = att.name, ContentType = att.ContentType,Body= EncodingUtil.base64Decode(att.body)));                                   
                                    }    
                                insert  attachmentToInsert;  
                                System.debug('attachmentToInsert:'+attachmentToInsert);
                    update csList;
                    Database.saveResult insertResult = Database.insert(cc,false);
                }
                
                case csLatestObj=[select id,casenumber,status from case where casenumber=:cd.caseId limit 1];
                res.statuscode = 200;
                resp.caseId=csLatestObj.casenumber;
                resp.caseCurrentStatus=csLatestObj.status;
                resp.message='Success';  
            }else{
                res.statuscode = 400;
                resp.caseId=cd.caseId;
                resp.message='Case is not available';
            }  
        } catch(Exception e){
            res.statuscode = 417;              
            resp.message='Failed-->'+string.valueof(e);
        } 
        return resp;
    }
    global class caseCommentsWrapper{
        public string comment;
        public string caseId;
        public decimal excepRefAmount;
        public string boAgreed;
        public boolean processExcepRef;
        public list<Attach> attachments;
        public string attachmentURLs;
        public string refundType;
        public decimal maxRefundAmount;
        public string previouscaseTabStatus;
    }
    global class ResponseWrapper{
        public string caseId;
        public string caseCurrentStatus;       
        public string caseOldStatus;
        public string message;
        
    }   
    global class Attach {
        String Body;
        String ContentType;
        String Name;
        String Type;
    }
}