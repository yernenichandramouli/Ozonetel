/*
* Name           : API_CaseComments
* Created Date   : 07 Feb 2018
* Created By     : Veeramanikanta R
* Purpose        : API for return cases with casecomments based on mobile number, caseNumber & Bo Id
* Test class     : API_CaseCommentsTest
*/
@RestResource(urlMapping='/redBus/CaseComments/*')
global without sharing class API_CaseComments
{   
    global static string mobileNo;
    global List<String> rpwClosedRefundTab;
    global List<String> rpwIRRefundTab;
    global static boolean channelRB=false;
    global static Set<String> rpwIRRefundTab = new Set<String>(System.label.RpwIRRefundTab.split(';'));
    global static set<string> splitBoids= new set<string>();
    global static list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
    // list<RPW_BO_ids__mdt> rpwMetaData = [SELECT Id, Bolt_Bo_ids__c,DeveloperName, MasterLabel FROM RPW_BO_ids__mdt WHERE DeveloperName='Bolt_Bo_Ids' LIMIT 1];
    @HttpGet
    global static List<caseRecords> getCaseComments()
    {                           
        RestRequest request = RestContext.request;
        mobileNo= request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String caseNo= RestContext.request.params.get('caseNo');
        String country=RestContext.request.params.get('country');
        String boId=RestContext.request.params.get('boId');
        String pnr=RestContext.request.params.get('pnr');
        
        list<String> internalIssueTypes= new list<String>();          
        internalIssueTypes.addAll(System.Label.Internal_IssueTypes.split(','));
        string channel=request.headers.get('channel');
        Set<String> SkipInternalBusnsType = new Set<String>(System.label.Internal_Business_Type.split(','));

        System.debug('mobileNo..'+mobileNo+'..caseNo'+caseNo+'..country'+country+'..boId'+boId+'..channel'+channel);
        List<caseRecords> crList=new List<caseRecords>();
        List<case> caseList;
        if(!'RB+'.equalsIgnoreCase(channel)){
            
            if(mobileNo!='' && mobileNo.length()==10 && (country=='India'||country==''|| country==null)){
                System.debug('mobileNo-->'+mobileNo);
                string formatedMobileNo;
                string apMobileNo='91'+mobileNo;
                System.debug('mobileNo len-->'+mobileNo.length());
                formatedMobileNo= '(' + mobileNo.substring(0, 3) + ') ' + mobileNo.substring(3, 6) + '-' + mobileNo.substring(6, 10);
                
                System.debug('formatedMobileNo-->'+formatedMobileNo);
                list<string> mobileNos=new list<string>();
                mobileNos.add(mobileNo);
                mobileNos.add(formatedMobileNo);
                mobileNos.add(apMobileNo);
                System.debug('mobileNos-->'+mobileNos);
                
            caseList=[select Amenities__c,Type, Max_Refund_Amount__c, Inventory_Type__c, Other_Issue__c, Service_Provider_Id__c,ParentId,Operator_Id__c,Selected_Issues__c,Case_Category__c,Refund_Type__c,Attachment_URLs__c,Business_Type__c,id,My_Desk_Id__c,Details_of_Complaint_ctp__c,Bus_Operator_Namee__c,ZM_Name__c,Related_Case_Details__c,Details_of_Service_ctp__c,Call_Recording_URLs__c,Transaction_ID__c,Refund_Amount__c,Order_UUId__c,BO_Agreed_RB__c,PNR_No__c,Parent.Refund_status__c,Refund_status__c,BO_Agreed_for_Refund__c,Bus_Type__c,No_of_SeatsF__c,origin,RR_SLA_Priority__c,Country__c,All_Previous_Status_Dates__c,First_Closure__c,TAT_Value__c,Closure_Delay__c,redCare_Status__c,redCare_Amount_Credited__c,redCare_Amount__c,Closed_By__c,Expected_Closure_Time__c,ClosedDate,Trip_Id_ct__c,Transaction_UUID__c,createddate,Source__c,Destination__c,Date_of_Journey__c,Total_Ticket_Amount__c,lastmodifieddate,status,notes__c,casenumber,toLabel(Issue_Type__c),Description,toLabel(Issue_Sub_Category__c),TIN_No__c,Account.Phone_10_Digits__c,Phone_No_ct__c,Booking_Mobile_No__c,Customer_Name__c,Booking_User_Name__c,TAT_Notifier_Email__c,HFT__c,(select commentbody,createddate from casecomments order by createddate asc) from case where ParentId=null and issue_type__c not in:internalIssueTypes AND Business_Type__c not in:SkipInternalBusnsType AND (Account.PersonMobilePhone in :mobileNos or Account.Phone_10_Digits__c in :mobileNos or Phone_No_ct__c in :mobileNos or Booking_Mobile_No__c in:mobileNos or Customer_Phone_Number__c in: mobileNos) AND Country__c=:country AND CreatedDate = LAST_N_DAYS:30 AND Type!='B2B'  order by lastmodifieddate desc];
            }else if(country!='India' && (caseNo==null || caseNo=='')){
                caseList=[select Amenities__c,Type, Max_Refund_Amount__c, Inventory_Type__c, Other_Issue__c, Service_Provider_Id__c,ParentId,Operator_Id__c,Selected_Issues__c,Case_Category__c,Refund_Type__c,Attachment_URLs__c,Business_Type__c,id,My_Desk_Id__c,Details_of_Complaint_ctp__c,Bus_Operator_Namee__c,ZM_Name__c,Related_Case_Details__c,Details_of_Service_ctp__c,Call_Recording_URLs__c,Transaction_ID__c,Refund_Amount__c,BO_Agreed_RB__c,Order_UUId__c,Parent.Refund_status__c,Refund_status__c,BO_Agreed_for_Refund__c,PNR_No__c,Bus_Type__c,No_of_SeatsF__c,origin,RR_SLA_Priority__c,Country__c,All_Previous_Status_Dates__c,First_Closure__c,TAT_Value__c,Closure_Delay__c,redCare_Status__c,redCare_Amount_Credited__c,redCare_Amount__c,Closed_By__c,Expected_Closure_Time__c,ClosedDate,Trip_Id_ct__c,Transaction_UUID__c,createddate,Source__c,Destination__c,Date_of_Journey__c,Total_Ticket_Amount__c,lastmodifieddate,status,notes__c,casenumber,toLabel(Issue_Type__c),Description,toLabel(Issue_Sub_Category__c),TIN_No__c,Account.Phone_10_Digits__c,Phone_No_ct__c,Booking_Mobile_No__c,Customer_Name__c,Booking_User_Name__c,TAT_Notifier_Email__c,HFT__c,(select commentbody,createddate from casecomments order by createddate asc) from case where ParentId=null and issue_type__c not in:internalIssueTypes AND  Business_Type__c not in:SkipInternalBusnsType AND (Account.PersonMobilePhone =:mobileNo or Phone_No_ct__c =:mobileNo or Booking_Mobile_No__c =:mobileNo) AND Country__c=:country AND CreatedDate = LAST_N_DAYS:30 AND Type!='B2B'  order by lastmodifieddate desc];
            }
            else if (caseNo!='' || caseNo!=null){
                caseList=[select Amenities__c,Type, Max_Refund_Amount__c, Inventory_Type__c, Other_Issue__c, Service_Provider_Id__c,ParentId,Operator_Id__c,Selected_Issues__c,Case_Category__c,Refund_Type__c,Attachment_URLs__c,Business_Type__c,id,My_Desk_Id__c,Details_of_Complaint_ctp__c,Bus_Operator_Namee__c,ZM_Name__c,Related_Case_Details__c,Details_of_Service_ctp__c,Call_Recording_URLs__c,Transaction_ID__c,Refund_Amount__c,Order_UUId__c,BO_Agreed_RB__c,Parent.Refund_status__c,Refund_status__c,BO_Agreed_for_Refund__c,origin,PNR_No__c,Bus_Type__c,No_of_SeatsF__c,RR_SLA_Priority__c,Country__c,All_Previous_Status_Dates__c,First_Closure__c,TAT_Value__c,Closure_Delay__c,redCare_Status__c,redCare_Amount_Credited__c,redCare_Amount__c,Closed_By__c,Expected_Closure_Time__c,ClosedDate,Trip_Id_ct__c,Transaction_UUID__c,createddate,Source__c,Destination__c,Date_of_Journey__c,Total_Ticket_Amount__c,lastmodifieddate,status,notes__c,casenumber,toLabel(Issue_Type__c),Description,toLabel(Issue_Sub_Category__c),TIN_No__c,Account.Phone_10_Digits__c,Phone_No_ct__c,Booking_Mobile_No__c,Customer_Name__c,Booking_User_Name__c,TAT_Notifier_Email__c,HFT__c,(select commentbody,createddate from casecomments order by createddate asc) from case where ParentId=null and issue_type__c not in:internalIssueTypes AND Business_Type__c not in:SkipInternalBusnsType AND casenumber=:caseNo  order by lastmodifieddate desc];               
            } 
            
            System.debug('caseList-->'+caseList);
            list<case> cL=new list<case>();
            list<casecomment> ccList=new list<casecomment>();
            for(case c:caseList){
                list<caseComments> ccWr=new list<caseComments>();  
                GuidedResolution gdResol= new GuidedResolution();
                list<string> caseBody=new list<string>();
                caseRecords cr;     
                gdResol.einsteinRecommendation='';
                gdResol.guidedTemplate='';
                gdResol.boComment='';
                gdResol.channelname='';
                for(caseComment ccm:c.casecomments){ 
                    caseComments ccW=new caseComments();
                    System.debug('coomm-->'+ccm.commentbody);     
                    if(string.isNotBlank(ccm.commentbody) && (ccm.commentbody.startswith('(STC)') || ccm.commentbody.startswith('(CEV)'))){  
                        ccW.createdtime=string.valueof(ccm.createddate);
                        if(ccm.commentbody.startswith('(CEV)')){
                            ccW.comment=ccm.commentbody.removeStart('(CEV)');
                            ccW.custComment=true;
                        }else{
                            ccW.comment=ccm.commentbody.removeStart('(STC)');
                            ccW.custComment=false;
                        }
                        ccWr.add(ccW);
                    }
                }
                cr=new caseRecords(c,ccWr,gdResol,null);
                crList.add(cr);
            }
            System.debug('crList-->'+JSON.serialize(crList));
        }else if(boId!=null && channel=='RB+'){   
            system.debug('===entered RB+==');        
             boolean channelRB=true;
            List<DataDeletionSetup__mdt> ddList=new List<DataDeletionSetup__mdt>();
            Map<String,Issue_Based_TAT__mdt> mapIssueToEinsteinReco= new Map<string,Issue_Based_TAT__mdt>();
            Map<String,Issue_Based_TAT__mdt> mapIssueToGRtemplate= new Map<string,Issue_Based_TAT__mdt>();
            Map<String,Issue_Based_TAT__mdt> mapIssueToboComments= new Map<string,Issue_Based_TAT__mdt>();
            Map<String,String>  mapQueries = new Map<String,String>();
            for(DataDeletionSetup__mdt dd:[SELECT Id,DeveloperName,QueryDetails__c FROM DataDeletionSetup__mdt where DeveloperName IN('RedProwin','RedProwinPNR','RedProwinPNRCaNum')])
            {
                mapQueries.put(dd.DeveloperName,dd.QueryDetails__c);
            }
            
            
            if(string.isNotBlank(pnr)){
                caseList= DataBase.query(string.valueOf(mapQueries.get('RedProwinPNR')));  
                if(caseList.isEmpty())
                    caseList= DataBase.query(string.valueOf(mapQueries.get('RedProwinPNRCaNum')));  
                
            }else{    
                if(boId!=null){
                    caseList= DataBase.query(string.valueOf(mapQueries.get('RedProwin')));
                }
                
                
            }
            
            for(Issue_Based_TAT__mdt issueGuResol : [SELECT toLabel(Issue_Type__c),toLabel(Issue_Sub_Category__c),boComment__c,Guided_Resolution_Template__c,Einstein_Reco__c from Issue_Based_TAT__mdt where Einstein_Reco__c!=null])
            {
                system.debug('==issueGuResol=='+issueGuResol);
                if(string.isNotblank(issueGuResol.Einstein_Reco__c)){
                    mapIssueToEinsteinReco.put(issueGuResol.Issue_Type__c+issueGuResol.Issue_Sub_Category__c,issueGuResol);
                    mapIssueToGRtemplate.put(issueGuResol.Issue_Type__c+issueGuResol.Issue_Sub_Category__c,issueGuResol); 
                    mapIssueToboComments.put(issueGuResol.Issue_Type__c+issueGuResol.Issue_Sub_Category__c,issueGuResol);
                }
            }
            
            Map<string,string> mapSelectedIssues=new Map<string,string>();
            for(Case_Issues__mdt ci:[select id,masterlabel,Issue__c,issue_no__c from Case_Issues__mdt]){
                mapSelectedIssues.put(string.valueOf(ci.issue_no__c),ci.Issue__c);             
            }
            // Need to exclide for rpw
            //for (Integer i = caseList.size() - 1; i >= 0; i--) {
               //if((caseList[i].Channel_ct__c =='MMT'|| caseList[i].Channel_ct__c =='GOIBIBO') && (caseList[i].Case_Category__c!='Instant resolution-BOLT' ||(caseList[i].Case_Category__c=='Instant resolution-BOLT' && caseList[i].Refund_Type__c!='Instant resolution - BO contest Rejected' && !rpwIRRefundTab.contains(caseList[i].Refund_Type__c)))){
               //     system.debug('::: RemovedCaseNumber= '+caseList[i].CaseNumber);
               //     caseList.remove(i);
               // }
           // }

            for(case c:caseList){
                
                list<caseComments> ccWr=new list<caseComments>();  
                GuidedResolution gdResol= new GuidedResolution();
                list<string> caseBody=new list<string>(); 
                String strIssueSubIssue = c.Issue_Type__c+c.Issue_Sub_Category__c;
                system.debug('=strIssueSubIssue='+strIssueSubIssue);
                
                string einsteinRecommendation='';
                string guidedTemplate='';
                string boComments='';
                string channelname='RB+';
                if(string.isNotBlank(c.Issue_Type__c)&&string.isNotBlank(c.Issue_Sub_Category__c)){
                    system.debug('==120=='+c.Issue_Type__c+'==Issue_Sub_Category__c=='+c.Issue_Sub_Category__c);
                    if(mapIssueToEinsteinReco.containsKey(c.Issue_Type__c+c.Issue_Sub_Category__c) && mapIssueToGRtemplate.containsKey(c.Issue_Type__c+c.Issue_Sub_Category__c)){
                        gdResol.einsteinRecommendation=mapIssueToEinsteinReco.get(strIssueSubIssue).Einstein_Reco__c;
                        gdResol.guidedTemplate=mapIssueToGRtemplate.get(strIssueSubIssue).Guided_Resolution_Template__c;
                        gdResol.boComment=mapIssueToboComments.get(strIssueSubIssue).boComment__c;
                        gdResol.channelname='RB+';
                    }
                    
                }
                        gdResol.channelname='RB+';
                selectedIssues siObj=new selectedIssues();
                if(string.isNotBlank(c.Selected_Issues__c)){
                    List<string> caseIssuesLs=new List<string>();
                    caseIssuesLs=c.Selected_Issues__c.split(',');
                    string selVal='';
                    for(string selObj:caseIssuesLs){
                        if(selVal=='')
                            selVal= mapSelectedIssues.get(selObj);
                        else
                            selVal=selVal+','+ mapSelectedIssues.get(selObj);
                    }
                    if (selVal != null) {
                        selVal = selVal.removeEnd(',');
                    }

                    siObj.selIssue=selVal;
                }
                
                caseRecords cr;     
                for(caseComment ccm:c.casecomments){ 
                    // if(string.isNotBlank(ccm.commentbody) && (ccm.commentbody.startswith('(CEV)') || ccm.commentbody.startswith('(RTB)') || ccm.commentbody.startswith('BO Reply->'))){
                    if(string.isNotBlank(ccm.commentbody)){
                        caseComments ccW=new caseComments();
                        ccW.createdtime=string.valueof(ccm.createddate);
                        ccW.comment=ccm.commentbody;
                        ccWr.add(ccW);
                    }
                } 
                System.debug('::: c::: '+c+' ::::: ccWr :::::' +ccWr+ '::: gdResol ::::' +gdResol+ '::: siObj ::::' +siObj);
                cr=new caseRecords(c,ccWr,gdResol,siObj);
                crList.add(cr);
            }              
        }
        return crList;
        
    }   
    
    
    global class caseRecords{
        public String caseNumber;
        public string phoneNo;
        public string issueType;
        public string subIssueType;
        public string description;
        public string tin;
        public string status;
        public string notes;
        public string source;
        public string destination;
        public string ticketAmount;
        public string doj;
        public string createdDateTime;
        public string lastModifiedTime;
        public List<casecomments> caseComment;
        public string tripId;
        public string orderItemUUId;
        public string orderUUId;
        public string tatValue;
        public string expectedClosureTime;
        public string closureTime;
        public string closedBy;
        public boolean reOpen;
        public string currentDateTime;
        public string firstClosure;
        public string statusHistory;
        public boolean tatcrossed;
        public RedCare redCare=new RedCare();
        public boolean excepRefund;
        public string pnr;
        public string custName;
        public string busType;
        public decimal noOfSeats;     
        public string boAgreed;
        public string expRefundStatus;
        public decimal expRefAmount;
        public string custEmailId;
        public string hft;
        public string myDeskId;
        public string csRecordingURL;
        Public string attchURLs;
        public string amenities;
        public GuidedResolution guidedResolution;
        public SelectedIssues selIssues;
        public string bookingId;
        public string vendorName;
        public string zmName;
        public string vendorResol;
        public string sopResol;
        public string relatedCaseDetails;
        public string instantRefund;
        public boolean instantRefundFeature;
        public string caseTabStatus;
        public string boId;
        public string caseType;
        public string channelName;
        public string multipleSubIssues;
        public string giMmtmaxRefundAmount;
        public Boolean isBolt;

        public caseRecords(Case cs,list<caseComments> ccWr,GuidedResolution gdRes,selectedIssues siObj){
            Set<String> rpwClosedRefundTab = new Set<String>(System.label.rpwClosedRefundTab.split(';'));
            // Set<String> rpwIRRefundTab = new Set<String>(System.label.RpwIRRefundTab.split(';'));
            System.debug('::: cs::: '+cs+' ::::: ccWr :::::' +ccWr+ '::: gdRes ::::' +gdRes+ '::: siObj ::::' +siObj);
            // Case Count Logic CRM-1250
            if(cs.Case_Category__c == 'Instant resolution-BOLT'){
                if(cs.status == 'Open' || cs.status =='Re-Open' || (cs.Refund_Type__c=='Outlier case' && cs.status != 'Closed') ||(cs.status == 'Escalated to BD' && !rpwIRRefundTab.contains(cs.Refund_Type__c) && cs.Refund_Type__c!='Instant resolution - redBus Delight')){
                    caseTabStatus='Open';
                }else if(cs.status != 'Open' && cs.status !='Re-Open' && rpwIRRefundTab.contains(cs.Refund_Type__c)){
                    caseTabStatus='Instant Refund';
                }else{
                    caseTabStatus='Closed';
                }
            }else{
                if(cs.status=='Closed'){
                    caseTabStatus='closed';
                }else{
                    caseTabStatus='Open';
                }
            }
            //
            redCare.amountCredited=cs.redCare_Amount_Credited__c;            
            redCare.closureDelay=string.valueOf(cs.Closure_Delay__c);
            redCare.amountperhour=cs.redCare_Amount__c;            
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            // currentDateTime=System.now().format('yyyy-mm-dd HH:mm:ss');
            if(cs.Phone_No_ct__c!='' || cs.Phone_No_ct__c!=null)
                phoneNo=cs.Phone_No_ct__c;
            else if(cs.Booking_Mobile_No__c!='' || cs.Booking_Mobile_No__c!=null)
                phoneNo=cs.Booking_Mobile_No__c;
            else 
                phoneNo=cs.Account.Phone_10_Digits__c;
            
            if(phoneNo!='' && phoneNo!=null)
                phoneNo= phoneNo.replaceAll('\\D','');
            currentDateTime=string.valueof(Datetime.now());
            if(cs.First_Closure__c!=null){
                firstClosure=string.valueof(cs.First_Closure__c);
            }
            caseNumber=cs.caseNumber;
            statusHistory=cs.All_Previous_Status_Dates__c;
            issueType=cs.Issue_Type__c;
            giMmtmaxRefundAmount = String.valueOf(cs.Max_Refund_Amount__c);
            subIssueType=cs.Issue_Sub_Category__c;
            if(cs.origin=='Complaint Tracker')
                description=cs.description;
            tin=cs.TIN_No__c;
            boId=cs.Service_Provider_Id__c;
            Set<String> instantRefundBoIds = new Set<String>(rpwMetaData[0].Bolt_Bo_ids__c.split(','));
            if(instantRefundBoIds.contains(boId)){
                isBolt = true;
            }else{
                isBolt = false;
            }
            status = cs.status;
            notes= cs.notes__c;
            source=cs.Source__c;
            destination=cs.Destination__c;
            ticketAmount=cs.Total_Ticket_Amount__c;
            if(cs.Date_of_Journey__c!=null){
                datetime dojCn=cs.Date_of_Journey__c;
                doj=string.valueof(dojCn);
                if(cs.transaction_id__c!=null && dojCn<system.now())
                    excepRefund=true;
            }
            caseComment=ccWr;
            guidedResolution=gdRes;
            selIssues=siObj;
            createddateTime=string.valueof(cs.createddate);
            lastModifiedTime=string.valueof(cs.lastmodifieddate);
            tripId = cs.Trip_Id_ct__c;
            orderItemUUId = cs.Transaction_UUID__c;
            if(cs.Country__c=='India'){
                tatValue=string.valueof(cs.TAT_Value__c);
            }else{
                tatValue=null;
            }
            if(cs.Expected_Closure_Time__c!=null){
                expectedClosureTime=string.valueof(cs.Expected_Closure_Time__c);
            }
            if(cs.ClosedDate!=null){
                closureTime=string.valueof(cs.ClosedDate);
            }
            closedBy=cs.Closed_By__c;
            tatcrossed = (cs.TAT_Value__c>0 && cs.RR_SLA_Priority__c==1)?true:false;
            Set<String> issueTypes = new Set<String>();
            Set<String> subIssueTypes = new Set<String>();
            issueTypes.addAll(System.Label.IssueTypes_SH.split(','));
            subIssueTypes.addAll(System.Label.SubIssueTypes_SH.split(','));
            if(issueTypes.contains(cs.Issue_Type__c) || subIssueTypes.contains(cs.Issue_Sub_Category__c ))
                reOpen=true;
            else
                reOpen=false;
            
            pnr=cs.PNR_No__c;    
            busType=cs.Bus_Type__c;
            noOfSeats=cs.No_of_SeatsF__c;          
            boAgreed=cs.BO_Agreed_RB__c;
            expRefundStatus=cs.Refund_status__c;
            orderUUId=cs.Order_UUId__c;
            expRefAmount=cs.Refund_Amount__c;
            custName=cs.Booking_User_Name__c;            
            custEmailId=cs.TAT_Notifier_Email__c;
            hft=cs.HFT__c;
            myDeskId=cs.My_Desk_Id__c;
            csRecordingURL=cs.Call_Recording_URLs__c;  
            attchURLs=Cs.Attachment_URLs__c;
            amenities=cs.Amenities__c;
            bookingId=cs.TIN_No__c;
            vendorResol=cs.Details_of_Complaint_ctp__c;
            sopResol=cs.Details_of_Service_ctp__c;
            zmName=cs.ZM_Name__c;
            caseType = cs.Type;
            channelName = cs.Inventory_Type__c;
            multipleSubIssues = cs.Other_Issue__c;
            vendorName=cs.Bus_Operator_Namee__c;
            relatedCaseDetails=cs.Related_Case_Details__c;
            instantRefund=(cs.Case_Category__c=='Instant resolution-BOLT' && cs.Refund_Type__c=='Outlier case')?null:cs.Refund_Type__c;
            system.debug('---gdRes.channelname---'+gdRes.channelname);
           if(gdRes.channelname=='RB+' && cs.Case_Category__c == 'Instant resolution-BOLT'){
                instantRefundFeature=true;
             }else{
                 instantRefundFeature=false;
             }  
               
           
           
            
        }  
    }    
    public class caseComments{
        public string comment;
        public string createdTime;
        public boolean custComment;
    }
    public class RedCare{
        public boolean rce=false;
        public decimal amountCredited;
        public string rcStaus;
        public string closureDelay;
        public decimal amountperhour;
    } 
    
    public class GuidedResolution{
        public string einsteinRecommendation;
        public string guidedTemplate;
        public string boComment;
        public string channelname;
    } 
    public class selectedIssues{
        public string selIssue;
    }
    
  
}