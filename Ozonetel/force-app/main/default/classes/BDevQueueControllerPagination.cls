/*
* Name           : BDevQueueControllerPagination
* Created Date   : 17 Oct 2017
* Created By     : Veeramanikanta R
* Purpose        : Implementing BD Workflow on SF Sites
* Test class     : BDevQueueControllerPaginationTest
*/

public class BDevQueueControllerPagination{
    
    public case cObj{get;set;}
    public string status{get;set;}
    public string caseId{get;set;}
    public string description{get;set;}
    public string imeiNumber{get;set;}
    public string gpsVendorName{get;set;}
    public boolean showPB{get;set;}
    public boolean showPopup{get;set;}
    public string assignedById{get;set;}
    Public attachment objAttachment;
    Public string attFile{get;set;}
    public List<case> cList{get;set;}
    public List<case> acList{get;set;}
    public string copyCheck;
    public string copyId;
    public Site_Users__c sObj{get;set;}
    public list<Attachment> attList{get;set;}
    public list<CaseComment> ccList{get;set;}
    public boolean showCC{get;set;}
    public string queueName{get;set;}
    public list<string> queueIds{get;set;}
    public string sButton{get;set;}
    public Boolean isExistingBPnumber{get;set;}
    public string correctBPnumber{get;set;}
    public boolean hidetext{get;set;}
    public integer agentBDCasesCount{get;set;}
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    public String sortDirection = 'ASC';
    public String sortExp = 'CreatedDate';
    public String sortFullExp ='';
    public boolean massBuscancl{get;set;}
    public static string busCncloperatorId{get;set;}
    public static string busCnclSource{get;set;}
    public static string busCnclDestination{get;set;}
    public static date busCnclDojstart{get;set;}
    public static date busCnclDojend{get;set;}
    public static list<ResponseDataWarpper> listRespData{get;set;}
    public static boolean showNoResult{get;set;}
    public static string cancellationType{get;set;}
    public static boolean showUpdateButton{get;set;}
    public static string buttonValue{get;set;}
    public static string CanclRespServiceID{get;set;}
    public static datetime CanclRespSdate{get;set;}
    public static datetime CanclRespEdate{get;set;}
    public static boolean resultFound{get;set;}
    public static String errorMessage{get;set;}
    public static list<string> lstRecords{get;set;}
    public static string busCanclEmailId{get;set;}
    Map<String,BD_TAT__mdt> mapBDTAT;   
    
    public Attachment getobjAttachment(){
        objAttachment= new Attachment();
        return objAttachment;   
        
    }
    
    public BDevQueueControllerPagination (){
        ccList=new list<CaseComment>();
        acList=new list<case>();
        showPopup=false;
        showPB=false;
        showCC=false;
        //resultFound=false;
        isExistingBPnumber=false;
        hidetext=false;
        massBuscancl=false;
        showUpdateButton=true;
        cList=new List<case>();
        cObj=new case();   
        queueIds=new list<string>();     
        size=10;
        mapBDTAT= new Map<string,BD_TAT__mdt>();
        for(BD_TAT__mdt issueTAT : [SELECT level_1__c,MasterLabel,Issue_Types__c from BD_TAT__mdt ])
        {
            mapBDTAT.put(issueTAT.MasterLabel,issueTAT);
        }     
        
        
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            System.debug('call to std..');
            if(setCon == null) 
            { 
                //   getCasesLatest();
                setCon = new ApexPages.StandardSetController(cList);
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
                System.debug('call to std..inside'+noOfRecords );
            }               
            return setCon;
        }
        set;
    }
    
    public PageReference BDCases()
    {
        sObj=new site_users__c();
        String checksum= ApexPages.currentPage().getParameters().get('session');
        String id = ApexPages.currentPage().getParameters().get('id');
        
        try{
            if (String.isNotBlank(checksum) && String.isNotBlank(id)) 
            {
                sObj = [select id,name,Session_Id__c,location__c,Type__c from Site_Users__c where Session_Id__c =:checksum and id =:id limit 1]; 
                
                if(sObj!=null){
                    copyId=sObj.id;
                    sObj.Session_Id__c=null;
                    update sObj;
                    copyCheck=sObj.Session_Id__c;
                    datetime yesterdayTime=System.now().adddays(-1);
                    
                }
                else
                {
                    return this.Userlogout();
                    
                }
            }
            
            else
                return this.Userlogout();
            
        }catch(Exception e){
            
            return this.Userlogout();
        } 
        return null;
    }
    
    
    public void getCases(){
        queueIds=new list<string>();
        datetime yesterdayTime=System.now();
        datetime currentTime=System.now();
        string queryS;
        string queryCount;
        cList=new List<case>();
        cList.clear();
        string bdLocation=sObj.location__c;
        String queryLimit = '0';
        showCC = false;
        showPB = false;
        ccList = new List<CaseComment>();
        
        if(sObj.Type__c=='Agent')
        {
            DataDeletionSetup__mdt dataDel = new DataDeletionSetup__mdt();
            dataDel = [SELECT QueryDetails__c,Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BDWorkflowAgent'];
            queryLimit = String.valueOf(dataDel.Duration__c);
            queryS = dataDel.QueryDetails__c;            
            queryCount = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BDWorkflowAgentCount'].QueryDetails__c;
        }
        
        else if(sObj.Type__c=='Manager')
        {    
            DataDeletionSetup__mdt dataDel = new DataDeletionSetup__mdt();
            dataDel = [SELECT QueryDetails__c,Duration__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BDWorkflowManager'];
            queryLimit = String.valueOf(dataDel.Duration__c);
            queryS = dataDel.QueryDetails__c;           
            queryCount = [SELECT QueryDetails__c FROM DataDeletionSetup__mdt WHERE DeveloperName ='BDWorkflowManagerCount'].QueryDetails__c;
            
        }
        
        try{
            string issueTypes;
            agentBDCasesCount=0;
            list<string> issueTypesLS=new list<string>();
            if(queueName=='Social Media / Escalated Care')
            {          
                yesterdayTime=currentTime.addhours(-integer.valueof(mapBDTAT.get('Social Media/Escalated Care').Level_1__c));
                queryS=queryS+' AND (origin=\'Facebook\' OR origin=\'Twitter\' OR origin=\'gimmt_sm@redbus.com\') ';
                queryCount= queryCount+' AND (origin=\'Facebook\' OR origin=\'Twitter\' OR origin=\'gimmt_sm@redbus.com\')';
                
            }          
            else if(queueName=='SPOC'){
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('SPOC(Bus Cancellation)').Level_1__c));
                issueTypes=mapBDTAT.get('SPOC(Bus Cancellation)').Issue_Types__c;                               
                issueTypesLS=issueTypes.split(',');               
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ';  
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                
            }else if(queueName=='SIT/ HF Team'){
                
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('SIT/HF Team').Level_1__c));
                issueTypes=mapBDTAT.get('SIT/HF Team').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');             
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ';
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                
            }else if(queueName=='Others'){
                
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('Others').Level_1__c));
                issueTypes=mapBDTAT.get('Others').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');                               
                queryS=queryS+' AND (origin!=\'Facebook\' OR origin!=\'Twitter\') AND Issue_Type__c NOT IN:issueTypesLS';
                queryCount= queryCount+' AND (origin!=\'Facebook\' OR origin!=\'Twitter\' OR origin!=\'gimmt_sm@redbus.com\')  AND Issue_Type__c NOT IN:issueTypesLS';
                
            }else if(queueName=='Invalid BP number'){
                
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('Invalid BP number').Level_1__c));
                issueTypes=mapBDTAT.get('Invalid BP number').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ';
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                
            }else if(queueName=='BP Verification Primo'){
                
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('BP Verification').Level_1__c));
                issueTypes=mapBDTAT.get('BP Verification').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ';
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                
            }
            else if(queueName=='YourBus'){
                
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('YourBus').Level_1__c));
                issueTypes=mapBDTAT.get('YourBus').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ';
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                
            }else if(queueName=='NonCallableBo'){
            
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('NonCallableBo').Level_1__c));
                issueTypes=mapBDTAT.get('NonCallableBo').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ';
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
            
            }
            
            if(String.isBlank(sortFullExp))      
                queryS = queryS+' ORDER BY CreatedDate DESC limit '+queryLimit;
            else
                queryS = queryS+ sortFullExp +queryLimit;
            
            agentBDCasesCount=Database.countquery(queryCount);
            System.debug('queryS...'+queryS);
            cList = DataBase.query(queryS);  
            //clist =[select casenumber,Assigned_by__c,isExisting_BPnumber__c,Phone_No_ct__c,BP_Contact_Number__c,Issue_Sub_Category__c,Date_Of_Journey_New__c,TIN__c,Total_Ticket_Amount__c,Service_Provider_Id__c,Service_Provider_Name__c,Route_Id__c,Destination__c,Source__c,LastModifiedByid,Booking_Email_ID__c,description,id,BD_Location2__c,BD_Location__c,status,issue_type__c,PNR_No__c,Assigned_to_BD__c,Boarding_Point__c,Age__c,First_Assigned_Owner_Id__c,Origin,PNR__c,AmountD__c,Operator_Id__c,SourceT__c,DestinationT__c,SS_DOJ__c,TIN_No__c from case limit 22];
            
            setCon = new ApexPages.StandardSetController(cList);
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
            cancel();
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong! Get cases failed, Exception->'+e));
            
        }
    }
    
    //make user log out
    public PageReference Userlogout() {
        System.debug('Logout');
        try {
            if (Copycheck!=null && Copyid!=null) {
                List<Site_Users__c> a = [select id,Session_Id__c from Site_Users__c where id =:Copyid limit 1];  
                if(!a.isEmpty()){
                    a[0].Session_Id__c=null;
                    update a;
                    Copycheck=null;
                }
            }
        }catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong!'));
            return null;
        }   
        PageReference newPage1 = new PageReference('/apex/LoginPage');
        newPage1.setRedirect(true);
        return newPage1;
        
    }
    
    
    public void Edit(){
        showPB=true;
        showPopup=true;
        description='';
        correctBPnumber ='';
        isExistingBPnumber=false;
        System.debug('ss->'+showPopup);
    }
    
    public void cancel(){
        showPB=false;
        showCC=false;
        System.debug('called cancel');
    }
    
    public void hide(){
        system.debug('--'+isExistingBPnumber);
        if(isExistingBPnumber){
            correctBPnumber='';
            hidetext=false;
        }
        else if(!isExistingBPnumber){
            hidetext=true;
        }
    }
    
    public void save(){
        if(description==''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter description'));          
        }else if(queueName=='YourBus' && imeiNumber==''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter IMEI Number'));
        }else if(queueName=='YourBus' && gpsVendorName==''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please GPS Vendor Name'));
        }else
        {                           
            showPB=false;
            System.debug('caseNumber-->'+caseId);        
            site_helper__c s=new site_helper__c();
            s.case_id__c=caseId;
            s.description__c=status;
            s.Assigned_By__c=assignedById;
            s.BD_User__c=sObj.name +'-'+sObj.Type__c+'-'+sObj.location__c;
            List<case> caseListToUpdate = New List<case>();
            Group g=[Select Id from Group where name='Social Media Queue' limit 1];  
            Group busRefQ=[select id from Group where type='Queue' AND developername='Bus_Cancellation_Auto_Refund_Queue']; 
            Group invalBPqu=[select id from Group where type='Queue' AND developername='Invalid_BP_Queue']; 
            Group hqBusDev=[select id from Group where type='Queue' AND developername='HQ_Bus_Dev_Queue'];  
            Group noncallableQueueId=[Select Id from Group where name='Non Callable Queue' limit 1];
            
            try{
                case cObj=[select id,BO_Type__c,isAgeing_Refund_Success__c,Flow_Type__c,IMEI_Number__c,GPS_Vendor_name__c,Issue_Type__c,RPW_Case__c,isExisting_BPnumber__c,Correct_BP_Number__c,BP_Verification__c,isAgening_Refund_Processed__c,All_Previous_Status_Dates__c from case where id=:caseId];
                
                if(correctBPnumber =='' && isExistingBPnumber==False && 'I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c)){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter correct BP number or check isExistingBPnumber correct'));
                }
                
                s.Flow_Type__c=cObj.Flow_Type__c;
                
                if(queueName=='Social Media / Escalated Care'){
                    s.Assigned_By__c=g.id;
                }
                if(queueName=='YourBus'){
                    cObj.IMEI_Number__c=imeiNumber;
                    cObj.GPS_Vendor_name__c=gpsVendorName;
                    caseListToUpdate.add(cObj);
                }
                
                 if(cObj.BO_Type__c=='Non Callable'){
                   s.Assigned_By__c='Non callble BD';
                  }
                    

                if(sButton=='SaveAndClose'){
                    s.status__c='Department Revert';
                    
                    if(!'I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c) && cObj.isAgening_Refund_Processed__c && cObj.isAgeing_Refund_Success__c && !cObj.All_Previous_Status_Dates__c.contains('Refunded By Ageing Scheduler')){
                        s.Assigned_By__c= busRefQ.id;
                    }else if(!'I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c)) {
                        s.Assigned_By__c=assignedById; 
                    }
                    
                    if(cObj.RPW_Case__c ==True){
                        //s.Assigned_By__c='RPW Queue';
                    }else if('I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c)&& isExistingBPnumber){
                        CaseComment ccc=new CaseComment();
                        ccc.CommentBody=sObj.name +'-'+sObj.location__c+'-->'+ description;
                        ccc.parentid=cObj.id;
                        insert ccc;
                        s.BP_Number__c=isExistingBPnumber;
                        s.Correct_BP_Number__c='';    
                        s.Status__c='Closed';  
                    }else if('I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c)&& !isExistingBPnumber){
                        s.description__c=status;
                        s.Correct_BP_Number__c=correctBPnumber;
                        s.BP_Number__c=false;
                        s.Assigned_By__c='Invalid BP Queue';
                        
                    }else if('BP Verification'.equalsIgnoreCase(cObj.Issue_Type__c)){
                        system.debug('==bpV=>>'+cObj.BP_Verification__c);
                        if(cObj.BP_Verification__c!=null){
                            BP_Verification__c bpv=[Select id,New_Correct_BP_No__c from BP_Verification__c where id=:cObj.BP_Verification__c];
                            bpv.New_Correct_BP_No__c =correctBPnumber;
                            update bpv;
                        }
                        s.description__c=status;
                        s.Correct_BP_Number__c=correctBPnumber;
                        s.Assigned_By__c='BP verfiication';
                    }else if('New vehicle- GPS details needed'.equalsIgnoreCase(cObj.Issue_Type__c)){
                        s.Assigned_By__c='YourBus';
                    }
                    
                    if(cObj.BO_Type__c=='Non Callable'){
                      s.Assigned_By__c='Non callble BD';
                    }
                    
                }
                
                if(sObj.Type__c=='Agent')
                    s.Resolved_By__c='Agent';
                else if(sObj.Type__c=='Manager')
                    s.Resolved_By__c='Manager';
                
                insert s;
                system.debug('--isExistingBPnumber --'+isExistingBPnumber+'--sOjname-'+sObj.name+'--descr--'+description);
                
                CaseComment cc=new CaseComment();
                if(queueName=='YourBus'){
                    cc.CommentBody=sObj.name +'-'+sObj.location__c+'->'+ description+'->'+imeiNumber+'->'+gpsVendorName;
                }else{
                    cc.CommentBody=sObj.name +'-'+sObj.location__c+'->'+ description;
                }
                //cc.CommentBody=description;           
                
                cc.parentid=cObj.id;
                insert cc;

                if(!caseListToUpdate.isEmpty()){
                    update caseListToUpdate;
                }
                
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong! Save Failed, Exception->'+e));
            }
            showComments();
        }
    }
    
    public void showComments(){        
        try{
            Edit();
            hidetext=true;
            showCC=true;
            //showPB=false;
            System.debug('caseId-->'+caseId);        
            ccList=[select id,commentbody,createddate from casecomment where parentid=:caseId ORDER BY CreatedDate DESC];
            attList=[select id,name from Attachment where parentid=:caseID];
            System.debug('ccList-->'+ccList);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong! Show comments failed, Exception->'+e));
            
        }
    }
    
    public void attachFile(){
        String cId= ApexPages.currentPage().getParameters().get('cId');
        Attachment a = new Attachment(parentId = cId, name=objAttachment.name, body = objAttachment.body);
        try{
            insert a;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'File '+objAttachment.name+' has been attached'));       
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Some error occured, Please check with Admin!! Error reported as -->'+e));       
        }
    }
    
    
    
    public PageReference refreshPageSize() {
        setCon.setPageSize(size);
        return null;
    }
    
    public List<Case> getCaseDetails() 
    {
        return (List<Case>) setCon.getRecords();
    }
    
    public void hideCommentsAction()
    {
        
        showCC = false;
        showPB = false;
        ccList = new List<CaseComment>();
        
    }
    //Added here 
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
            
        }
    }
    public void sortCondPrepare() {
        //build the full sort expression
        sortFullExp = ' ORDER BY '+sortExpression  + ' ' + sortDirection +' limit ' ;
        getCases();
    }
    
    public void buscanclPage(){
        massBuscancl=true;
        showUpdateButton=true;   
    }
    
    public static void ServiceDetailsCall(){
        
        if(string.isBlank(busCnclSource) && string.isBlank(busCnclDestination) && busCnclDojstart ==null && busCnclDojend ==null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please check data is missing in Source/Destination/DOJ Start/DOJ End'));
        }else{
            
            API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='ServiceDetailsAPI'];
            
            string oprtId=String.isNotBlank(busCncloperatorId)?busCncloperatorId:'';
                        
            datetime sDoj=busCnclDojstart;
            Long getepochSdoj = sDoj.getTime()/1000;
            
            datetime eDoj=busCnclDojend;
            Long getepochEdoj = eDoj.getTime()/1000;
            
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type','application/json');
            list<HeadersWrapper> hlist=new list<HeadersWrapper>();
            
            for(string o:headers.keyset()){               
                System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                hlist.add(new HeadersWrapper(o,headers.get(o))); 
            }
            
            String headerJson=json.serialize(hlist); 
            String headerJson2=json.serialize(headerJson);
            
            busCnclSource=busCnclSource.capitalize();
            busCnclDestination=busCnclDestination.capitalize();
            
            busCnclSource=busCnclSource.replace(' ', '%20');
            busCnclDestination=busCnclDestination.replace(' ', '%20');
            
            string endPoint=APIMData.Endpoint__c+'&sdojsec='+getepochSdoj+'&edojsec='+getepochEdoj+'&source='+busCnclSource+'&destination='+busCnclDestination+'&operatorId='+oprtId;
            
            string jsonBody='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
            
            system.debug('jsonBody-->>'+jsonBody);
            APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_Entangle'];

            HTTP h = new HTTP();
            HTTPRequest req= new  HTTPRequest();
            HTTPResponse resp=new HTTPResponse();
            req = HttpRequestUtil.populateHeaders(req);
            req.setMethod('POST');
            req.setBody(jsonBody);
            req.setEndpoint(APIMData.Endpoint__c);
            system.debug('reqbdy-->>'+req.getbody());
            DBLog_Summary__c dbl = new DBLog_Summary__c();
            dbl.Type__c = 'Mass Bus Cancellation servDtls';
            try{
                dbl.Request_Data__c=req.getbody();
                resp=h.send(req);
                system.debug('--respStatus-->>'+resp);
                system.debug('--resbdy-->>'+resp.getBody());
                dbl.Response_Received__c = String.valueOf(resp+'..Body..'+resp.getBody());
                if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && resp.getBody()!=null &&  String.isNotBlank(resp.getbody()))
                { 
                    showNoResult=true; 
                    //string respp ='{"status":{"type":"SUCCESS","description":"Operation successfully completed","code":"200"},"errors":[],"data":[{"ServiceID":"101","RouteID":161017,"JourneyDate":"2022-01-01","DateOfJourney":"2022-01-01 04:31:00","ConfirmTickets":15,"CancelTickets":1}]}';
                    map<string,object> resMap= (map<string,object>)JSON.deserializeUntyped(resp.getBody());
                    if(resMap.containsKey('error_code')){
                        errorMessage= string.valueof(resMap.get('error_message'));
                        resultFound=false;
                        showNoResult=true;
                        showUpdateButton=true;
                    }else{
                        if(resMap.containsKey('status')){
                            map<String,Object> statusMap= (map<string,object>)resMap.get('status');
                            system.debug('statusMap-->>'+statusMap);
                            if(string.valueof(statusMap.get('code'))=='200'){
                                showNoResult=true;
                                resultFound=true;
                                listRespData = (list<ResponseDataWarpper>)JSON.deserialize(JSON.serialize(resMap.get('data')),list<ResponseDataWarpper>.class); 
                                system.debug('ResponseDataWarpper-->>'+listRespData);
                                if(listRespData.isempty()){
                                    showUpdateButton=true;
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'No records found for this search criteria'));
                                    DataBase.insert(dbl,false);
                                }
                            }
                        }
                    }
                }else if(resp.getStatusCode()!=200 ){
                    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'API error---->'+resp.getStatus()));
                    DataBase.insert(dbl,false);
                    
                } else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'No response from APi -Body is empty-->'));
                    DataBase.insert(dbl,false);
                    
                }
                
            }Catch(Exception e)
            {
                dbl.Exception_Description__c = String.valueOf(e+'..Error Message..'+e.getMessage());  
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error While Processing.Please retry...'+e)); 
                DataBase.insert(dbl,false);
            }
            
            
            
        }
        
    }
    
    
    //passengerDetailsCall
    
    Public static void PassengerDetailsCall(){
        
        ServiceDetailsCall();
        //system.debug('+++++++++++++'+listRespData);
        DBLog_Summary__c dbl = new DBLog_Summary__c();
        if((string.isBlank(cancellationType) || cancellationType==null))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please check Cancellation Type '));
        }
        boolean emailValidate=true;
        if(string.isBlank(busCanclEmailId)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please check Email missing'));
            
        }else{
            
            String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(busCanclEmailId);
            if (!MyMatcher.matches()){
                emailValidate = false;
            }
            
            if(!emailValidate){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter valid Email id'));  
            }   
        }
        try{
            
            if(!listRespData.isEmpty() && string.isNotBlank(cancellationType))
            {
                
                dbl.Type__c = 'Mass Bus Cancellation PsngrDtls';
                dbl.Payment_Request_Response_Data__c =string.valueof(listRespData);
                
                for(ResponseDataWarpper cancRes:listRespData){
                    CanclRespServiceID=cancRes.ServiceID;
                    CanclRespSdate=date.valueof(cancRes.JourneyDate);
                    CanclRespEdate=datetime.valueof(cancRes.DateOfJourney);
                }
                
                API_EndPoints__mdt APIMData=new API_EndPoints__mdt();
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='PassengerDetailsAPI'];
                
                datetime endDoj= CanclRespSdate.addSeconds(86390);
                
                Long endEpochEdoj = endDoj.getTime()/1000;
                Long startEpochEdoj = CanclRespSdate.getTime()/1000;
                
                system.debug('==endEpochEdoj=='+endEpochEdoj+'---startEpochEdoj--'+startEpochEdoj);            
                
                Map<String, String> headers = new Map<String, String>();
                headers.put('Content-Type','text/csv');
                list<HeadersWrapper> hlist=new list<HeadersWrapper>();
                
                for(string o:headers.keyset()){               
                    System.debug('key-->'+o+''+'Value-->'+headers.get(o));
                    hlist.add(new HeadersWrapper(o,headers.get(o))); 
                }
                
                String headerJson=json.serialize(hlist); 
                String headerJson2=json.serialize(headerJson);
                
                //http://10.5.10.26:8000/v2/bulk/search?a=137&sdojsec=1655736000&edojsec=1655750400&serviceId=10011&status=all
                string endPoint=APIMData.Endpoint__c+'&sdojsec='+startEpochEdoj+'&edojsec='+endEpochEdoj+'&serviceId='+CanclRespServiceID+'&status='+cancellationType;
                system.debug('----Psg-endPoint--'+endPoint);
                
                string jsonBody='{"action":"GET","body":"","endPoint":"'+endPoint+'","headers":'+headerJson2+'}';
                
                system.debug('jsonBody-->>'+jsonBody);
                APIMData=[SELECT Endpoint__c,EnableLog__c FROM API_EndPoints__mdt where DeveloperName='Generic_capi_Entangle'];
                system.debug('endpoint-->>'+APIMData.Endpoint__c);
                HTTP h = new HTTP();
                HTTPRequest req= new  HTTPRequest();
                HTTPResponse resp=new HTTPResponse();
                req = HttpRequestUtil.populateHeaders(req);
                req.setMethod('POST');
                req.setBody(jsonBody);
                req.setEndpoint(APIMData.Endpoint__c);
                system.debug('reqbdy-->>'+req.getbody());
                
                dbl.Request_Data__c=req.getbody();
                
                resp=h.send(req);
                system.debug('Psgresp-->>'+resp);
                system.debug('Psgresbdy-->>'+resp.getBody());
                dbl.Response_Received__c=String.valueOf(resp+'..Body..'+resp.getBody());
                if(resp.getStatusCode()==200 && resp.getstatus()=='OK' && resp.getBody()!=null)
                {
                    string recievedResp=resp.getBody();
                    
                    /*list<Attachment> attachmentToInsert=new list<Attachment>();
attachmentToInsert.add( new Attachment(parentId ='5009H000001ohNm', name ='TestRec.csv', ContentType = 'csv',Body= blob.valueof(recievedResp)));                
insert attachmentToInsert;
system.debug('==attachmentToInsert=='+attachmentToInsert);*/
                    
                    string fileStr;
                    
                    for(string lstRecrds:recievedResp.split('\n')){
                        lstRecords=lstRecrds.split(',');
                        system.debug('--lstRecords---'+lstRecords);
                        //system.debug('==0 Final lstObj=='+lstRecords[0]);
                        
                        string fullName=lstRecords[0];
                        string emailId=lstRecords[1];
                        string  mobileNo=lstRecords[2];    
                        string custAmount=lstRecords[3];
                        string ticketStatus=lstRecords[4];
                        string source=lstRecords[5];
                        string destination=lstRecords[6];
                        string recordString = '"'+fullName+'","'+emailId+'","'+mobileNo+'","'+custAmount+'","'+ticketStatus+'","'+source+'","'+destination+'" \n';
                        fileStr=fileStr+recordString;
                        fileStr=fileStr.replaceAll('"','');
                        fileStr=fileStr.replaceAll('null','');
                        //system.debug('--fullName---'+fullName+'-------'+emailId+mobileNo+custAmount+ticketStatus+source+destination);
                        system.debug('--fileStr---'+fileStr);
                    }
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName('BusCanclDetails_Report.csv');
                    efa.setBody(Blob.valueOf(fileStr));
                    efa.setContentType('text/csv');
                    email.setSubject('Booking Details With Status Report');
                    List<String> toAddresses = new List<String>();
                    toAddresses.add(busCanclEmailId);
                    email.setToAddresses(toAddresses); 
                    email.setHtmlBody('Hi,<br/><br/>Please Find Booking  Details.. <br/><br/>Thanks,<br/>CRM Team');
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
                    if (results[0].success) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Email has been sent successfully'));
                        System.debug('-------The email was sent successfully.');
                    } else {
                        System.debug('----------The email failed to send: ' + results[0].errors[0].message);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'The email failed to send'));  
                    }  
                }else{
                    showNoResult=false;
                }  
                DataBase.insert(dbl,false);
            }else{
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error while fetching data.Please retry...'+listRespData)); 
            }   
        }Catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error While Processing.Please retry...'+e)); 
            DataBase.insert(dbl,false);
        }
        
    }
    
    public class ResponseDataWarpper
    {
        public string ServiceID { get; set; }
        public integer RouteID { get; set; }
        public string JourneyDate { get; set; }
        public string DateOfJourney { get; set; }
        public integer ConfirmTickets { get; set; }
        public integer CancelTickets { get; set; }
        public ResponseDataWarpper()
        {
            //system.debug('ttt'+ServiceID+RouteID+JourneyDate+DateOfJourney+ConfirmTickets+CancelTickets);
        }
    }
    
    public class HeadersWrapper
    {       
        public string key;
        public string value;
        public HeadersWrapper(string key,string value){
            this.key=key;
            this.value=value;
        }
    }
    
}