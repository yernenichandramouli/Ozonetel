/*
* Name           : BDevQueueController
* Created Date   : 17 Oct 2017
* Created By     : Veeramanikanta R
* Purpose        : Implementing BD Workflow on SF Sites
* Test class     : BDevQueueControllerTest
*/

public class BDevQueueController{
    
    public case cObj{get;set;}
    public string status{get;set;}
    public string caseId{get;set;}
    public string description{get;set;}
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
  
    // public map<string,string> queueIds{get;set;}
    
    
    
    public Attachment getobjAttachment(){
        objAttachment= new Attachment();
        return objAttachment;   
            
    }
    
    public BDevQueueController (){
        ccList=new list<CaseComment>();
        acList=new list<case>();
        showPopup=false;
        showPB=false;
        showCC=false;
        isExistingBPnumber=false;
        hidetext=false;
        cList=new List<case>();
        cObj=new case();   
        queueIds=new list<string>();     
        //BDCases();
    }
    
    public PageReference BDCases(){
        sObj=new site_users__c();
        String checksum= ApexPages.currentPage().getParameters().get('session');
        String id = ApexPages.currentPage().getParameters().get('id');
        System.debug('id-->'+id);
        
        try{
            if (checksum!=null && id!=null) {
                sObj = [select id,name,Session_Id__c,location__c,Type__c from Site_Users__c where Session_Id__c =:checksum and id =:id limit 1];  
                if(sObj!=null){
                    System.debug('sObj type'+sObj.Type__c);
                    copyId=sObj.id;
                    sObj.Session_Id__c=null;
                    update sObj;
                    copyCheck=sObj.Session_Id__c;
                    System.debug('bd location-->'+cObj.BD_Location2__c);
                    //cList=[select casenumber,description,id,BD_Location__c,status,issue_type__c  from case limit 10 ];
                    datetime yesterdayTime=System.now().adddays(-1);
                    /*    if(sObj.Type__c=='Agent')
cList=[select casenumber,Assigned_by__c,Date_Of_Journey_New__c,TIN__c,Total_Ticket_Amount__c,Service_Provider_Id__c,Service_Provider_Name__c,Route_Id__c,Destination__c,Source__c,LastModifiedByid,Booking_Email_ID__c,description,id,BD_Location__c,status,issue_type__c,PNR_No__c,Assigned_to_BD__c,Boarding_Point__c,Age__c,First_Owner__c from case where  BD_Location__c =:sObj.location__c AND status !='Closed' AND status !='Escalated to BD' AND First_Owner__c=:queueName AND Assigned_to_BD__c >: yesterdayTime ORDER BY CreatedDate DESC];
else if(sObj.Type__c=='Manager')      
cList=[select casenumber,Assigned_by__c,Date_Of_Journey_New__c,TIN__c,Total_Ticket_Amount__c,Service_Provider_Id__c,Service_Provider_Name__c,Route_Id__c,Destination__c,Source__c,LastModifiedByid,Booking_Email_ID__c,description,id,BD_Location__c,status,issue_type__c,Assigned_to_BD__c,PNR_No__c,Boarding_Point__c,Age__c,First_Owner__c from case where BD_Location__c !='' AND status !='Closed' AND status !='Escalated to BD'AND First_Owner__c=:queueName AND Assigned_to_BD__c <: yesterdayTime ORDER BY CreatedDate DESC];
*/
                    System.debug('cl-->'+cList);
                }else{
                    return this.Userlogout();
                }
                
            }
            
            else
            {
                return this.Userlogout();
            } 
        }catch(Exception e){
            // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Something went wrong! Event i don\'t know what heppend here'));
            // return null;
            return this.Userlogout();
        } 
        return null;
        //  cList=[select casenumber,description,id,BD_Location__c,status,issue_type__c  from case where  BD_Location__c =:cObj.BD_Location__c ];
    }
    
    public void getCases(){
        queueIds=new list<string>();
        System.debug('calling m-->'+queueName);
        Map<String,BD_TAT__mdt> mapBDTAT= new Map<string,BD_TAT__mdt>();
        for(BD_TAT__mdt issueTAT : [SELECT level_1__c,MasterLabel,Issue_Types__c from BD_TAT__mdt ])
        {
            mapBDTAT.put(issueTAT.MasterLabel,issueTAT);
        }     
        System.debug('mapBDTAT-->'+mapBDTAT);
        System.debug('Queue Name-->'+queueName);
        System.debug('queueIds b-->'+queueIds);
        datetime yesterdayTime=System.now();
        datetime currentTime=System.now();
        string queryS;
        string queryCount;
        cList=new List<case>();
        cList.clear();
        System.debug('soloc-->'+sObj.location__c);
        string bdLocation=sObj.location__c;
        if(sObj.Type__c=='Agent'){
            queryS='select casenumber,Assigned_by__c,isExisting_BPnumber__c,Phone_No_ct__c,BP_Contact_Number__c,Issue_Sub_Category__c,Date_Of_Journey_New__c,TIN__c,Total_Ticket_Amount__c,Service_Provider_Id__c,Service_Provider_Name__c,Route_Id__c,Destination__c,Source__c,LastModifiedByid,Booking_Email_ID__c,description,id,BD_Location2__c,BD_Location__c,status,issue_type__c,PNR_No__c,Assigned_to_BD__c,Boarding_Point__c,Age__c,First_Assigned_Owner_Id__c,Origin,PNR__c,AmountD__c,Operator_Id__c,SourceT__c,DestinationT__c,SS_DOJ__c,TIN_No__c from case where  (BD_Location2__c =:bdLocation OR BD_Location__c=:bdLocation) AND status =\'Escalated to BD\' AND (Resolved_By__c=null or Resolved_By__c=\'\' or Resolved_By__c=\'Agent\') AND Assigned_to_BD__c >: yesterdayTime';
            queryCount='select count() from case where  (BD_Location2__c =:bdLocation OR BD_Location__c=:bdLocation) AND status =\'Escalated to BD\' AND (Resolved_By__c=null or Resolved_By__c=\'\' or Resolved_By__c=\'Agent\') AND Assigned_to_BD__c >: yesterdayTime';
        }else if(sObj.Type__c=='Manager'){    
            queryS='select casenumber,Assigned_by__c,isExisting_BPnumber__c,Phone_No_ct__c,BP_Contact_Number__c,Issue_Sub_Category__c,Date_Of_Journey_New__c,TIN__c,Total_Ticket_Amount__c,Service_Provider_Id__c,Service_Provider_Name__c,Route_Id__c,Destination__c,Source__c,LastModifiedByid,Booking_Email_ID__c,description,id,BD_Location2__c,BD_Location__c,status,issue_type__c,PNR_No__c,Assigned_to_BD__c,Boarding_Point__c,Age__c,First_Assigned_Owner_Id__c,Origin,PNR__c,AmountD__c,Operator_Id__c,SourceT__c,DestinationT__c,SS_DOJ__c,TIN_No__c from case where  (BD_Location2__c =:bdLocation OR BD_Location__c=:bdLocation) AND status =\'Escalated to BD\' AND (Assigned_to_BD__c <: yesterdayTime OR Resolved_By__c=\'Manager\') ';
            queryCount='select count() from case where  (BD_Location2__c =:bdLocation OR BD_Location__c=:bdLocation) AND status =\'Escalated to BD\' AND (Assigned_to_BD__c <: yesterdayTime OR Resolved_By__c=\'Manager\')';
        }
        
        try{
            string issueTypes;
            agentBDCasesCount=0;
            list<string> issueTypesLS=new list<string>();
            if(queueName=='Social Media / Escalated Care'){          
                System.debug('time-->'+-integer.valueof(mapBDTAT.get('Social Media/Escalated Care').Level_1__c));              
                yesterdayTime=currentTime.addhours(-integer.valueof(mapBDTAT.get('Social Media/Escalated Care').Level_1__c));
                queryS=queryS+' AND (origin=\'Facebook\' OR origin=\'Twitter\') ORDER BY CreatedDate DESC limit 150';
                queryCount= queryCount+' AND (origin=\'Facebook\' OR origin=\'Twitter\')';
                agentBDCasesCount=Database.countquery(queryCount);
                cList = DataBase.query(queryS);
            }          
            else if(queueName=='SPOC'){
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('SPOC(Bus Cancellation)').Level_1__c));
                issueTypes=mapBDTAT.get('SPOC(Bus Cancellation)').Issue_Types__c;                               
                issueTypesLS=issueTypes.split(',');
                System.debug('isstt-->'+issueTypesLS);
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ORDER BY CreatedDate DESC limit 150';  
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                agentBDCasesCount=Database.countquery(queryCount);
                System.debug('queryS-->'+queryS);
                cList = DataBase.query(queryS);                
            }else if(queueName=='SIT/ HF Team'){
                System.debug('sit es-->'+mapBDTAT.get('SIT/HF Team').Level_1__c);
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('SIT/HF Team').Level_1__c));
                issueTypes=mapBDTAT.get('SIT/HF Team').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');
               // issueTypesLS.add(issueTypes);
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ORDER BY CreatedDate DESC limit 150';
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                agentBDCasesCount=Database.countquery(queryCount);
                System.debug('sit query s-->'+queryS);
                cList = DataBase.query(queryS);                
            }else if(queueName=='Others'){
                System.debug('sit es-->'+mapBDTAT.get('Others').Level_1__c);
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('Others').Level_1__c));
                issueTypes=mapBDTAT.get('Others').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');                               
                queryS=queryS+' AND (origin!=\'Facebook\' OR origin!=\'Twitter\') AND Issue_Type__c NOT IN:issueTypesLS ORDER BY CreatedDate DESC limit 150';
               // queryS=queryS+' AND origin!=\'Facebook\' AND origin!=\'Twitter\' AND Issue_Type__c!=\'Bus Operator Service\' AND Issue_Type__c!=\'Bus Cancellation\' ORDER BY CreatedDate DESC';
                System.debug('sit query s-->'+queryS);
                queryCount= queryCount+' AND (origin!=\'Facebook\' OR origin!=\'Twitter\')  AND Issue_Type__c NOT IN:issueTypesLS';
                agentBDCasesCount=Database.countquery(queryCount);
                cList = DataBase.query(queryS);                
            }else if(queueName=='Invalid BP number'){
             System.debug('sit es-->'+mapBDTAT.get('Invalid BP number').Level_1__c);
                yesterdayTime=System.now().addhours(-integer.valueof(mapBDTAT.get('Invalid BP number').Level_1__c));
                issueTypes=mapBDTAT.get('Invalid BP number').Issue_Types__c;
                issueTypesLS=issueTypes.split(',');
                queryS=queryS+' AND Issue_Type__c IN:issueTypesLS ORDER BY CreatedDate DESC limit 150';
                queryCount= queryCount+' AND Issue_Type__c IN:issueTypesLS';
                agentBDCasesCount=Database.countquery(queryCount);
                System.debug('sit query s-->'+queryS);
                cList = DataBase.query(queryS);   
            }         
            System.debug('cList-->'+cList);
            System.debug('yes time-->'+yesterdayTime);
            
            
            /*  if(sObj.Type__c=='Agent')
cList=[select casenumber,Assigned_by__c,Date_Of_Journey_New__c,TIN__c,Total_Ticket_Amount__c,Service_Provider_Id__c,Service_Provider_Name__c,Route_Id__c,Destination__c,Source__c,LastModifiedByid,Booking_Email_ID__c,description,id,BD_Location2__c,BD_Location__c,status,issue_type__c,PNR_No__c,Assigned_to_BD__c,Boarding_Point__c,Age__c,First_Assigned_Owner_Id__c from case where  (BD_Location2__c =:sObj.location__c OR BD_Location__c=:sObj.location__c) AND status ='Escalated to BD' AND First_Assigned_Owner_Id__c in:queueIds AND Assigned_to_BD__c >: yesterdayTime AND (Resolved_By__c=null or Resolved_By__c='' or Resolved_By__c='Agent')  ORDER BY CreatedDate DESC];
else if(sObj.Type__c=='Manager')      
cList=[select casenumber,Assigned_by__c,Date_Of_Journey_New__c,TIN__c,Total_Ticket_Amount__c,Service_Provider_Id__c,Service_Provider_Name__c,Route_Id__c,Destination__c,Source__c,LastModifiedByid,Booking_Email_ID__c,description,id,BD_Location2__c,BD_Location__c,status,issue_type__c,Assigned_to_BD__c,PNR_No__c,Boarding_Point__c,Age__c,First_Assigned_Owner_Id__c from case where (BD_Location2__c =:sObj.location__c OR BD_Location__c=:sObj.location__c) AND status ='Escalated to BD' AND First_Assigned_Owner_Id__c in :queueIds AND (Assigned_to_BD__c <: yesterdayTime OR Resolved_By__c='Manager') ORDER BY CreatedDate DESC];
*/         
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
            }else
            {                           
            showPB=false;
            System.debug('caseNumber-->'+caseId);        
            site_helper__c s=new site_helper__c();
            s.case_id__c=caseId;
            s.description__c=status;
            s.Assigned_By__c=assignedById;
            s.BD_User__c=sObj.name +'-'+sObj.Type__c+'-'+sObj.location__c;
            Group g=[Select Id from Group where name='Social Media Queue' limit 1];  
            Group busRefQ=[select id from Group where type='Queue' AND developername='Bus_Cancellation_Auto_Refund_Queue']; 
            Group hqBDQ=[select id from Group where type='Queue' AND developername='HQ_Bus_Dev_Queue']; 
            try{
                case cObj=[select id,isAgeing_Refund_Success__c,Issue_Type__c,isExisting_BPnumber__c,Correct_BP_Number__c,isAgening_Refund_Processed__c,All_Previous_Status_Dates__c from case where id=:caseId];

               if(correctBPnumber =='' && isExistingBPnumber==False && 'I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c)){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter correct BP number or check isExistingBPnumber correct'));
               }
                
                if(queueName=='Social Media / Escalated Care'){
                    s.Assigned_By__c=g.id;
                }
                if(sButton=='SaveAndClose'){
                    s.status__c='Department Revert';
                    if(!'I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c) && cObj.isAgening_Refund_Processed__c && cObj.isAgeing_Refund_Success__c && !cObj.All_Previous_Status_Dates__c.contains('Refunded By Ageing Scheduler')){
                        s.Assigned_By__c= busRefQ.id;
                    }else if(!'I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c)) {
                        s.Assigned_By__c=assignedById; 
                      }
                      
                    if('I need help to board my bus'.equalsIgnoreCase(cObj.Issue_Type__c)&& isExistingBPnumber)
                    {
                    
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
                        s.Assigned_By__c= hqBDQ.id;
                        
                    }
                    
                }
                
                if(sObj.Type__c=='Agent')
                    s.Resolved_By__c='Agent';
                else if(sObj.Type__c=='Manager')
                    s.Resolved_By__c='Manager';
                
                  insert s;
                  system.debug('--isExistingBPnumber --'+isExistingBPnumber+'--sOjname-'+sObj.name+'--descr--'+description);
                        
               CaseComment cc=new CaseComment();
                cc.CommentBody=sObj.name +'-'+sObj.location__c+'->'+ description;
                //cc.CommentBody=description;           
                
                cc.parentid=cObj.id;
                insert cc;
                
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
}