/**
* (c) 2017 RedBus
*
* Name           : RefundOrderItemsTriggerHandler
* Created Date   : 19 Oct 2017
* Created By     : Mahendra k
* Purpose        : Handler class for RefundOrderItemsTrigger
* Test class     : RefundOrderItemsTriggerHandleTest
*
**/

public class RefundOrderItemsTriggerHandler {
    public static boolean stopDisbursalCasesUpdate=true;

  public static void CaseDataUpdate(List<Refund_order_items__c> TriggerNew){
      List<caseComment> ccList = new List<caseComment>();
      system.debug('enetered method');
      set<string> refSuccesSet=new Set<string>();
      set<string> reffinanceSet=new set<string>();
      set<string> refPendingSet = new set<string>();
      set<string> refundSet = new set<string>();
      Map<string, DateTime> roIAutoNeftSuccess = new map<string, DateTime>(); 
      Map<string, String> roIAutoNeftValue = new map<string, string>();
      Set<string> disbursalIds=new Set<string>(); 
      Set<string> disbursalTrip=new Set<string>(); 
      map<string,Refund_Order_Items__c> mapdesbursId = new map<string,Refund_Order_Items__c>();
      map<string,Refund_Order_Items__c> mapRefund = new map<string,Refund_Order_Items__c>();
      for(Refund_order_items__c ref:TriggerNew){
          system.debug('entered for ');
          system.debug('<<<ref'+ref);
          if(string.isNotBlank(ref.Disbursal_Status__c) && (string.isNotBlank(ref.Disbursal_ID__c) || string.isNotblank(ref.Trip_ID__c)))
              {
                  if(string.isNotBlank(ref.Trip_ID__c))
                     disbursalTrip.add(ref.Trip_ID__c);
                  
                  if(string.isNotBlank(ref.Disbursal_ID__c))
                     disbursalIds.add(ref.Disbursal_ID__c);
                  mapRefund.put(ref.Trip_ID__c,ref);
                  mapdesbursId.put(ref.Disbursal_ID__c,ref);
                  system.debug('-----------'+disbursalIds);
              }else if('FAILED_MAX_ATTEMPS_EXCEED'.equalsIgnoreCase(ref.Disbursal_Status__c) && string.isNotBlank(ref.Trip_ID__c)){
                  disbursalTrip.add(ref.Trip_ID__c);
              }
              
              if(ref.Business_UnitF__c!='REDBUS_IN' && ('PG_REFUND_INITIATED'.equalsIgnoreCase(ref.Status__c) || 'REFUND_SUCCESSFUL'.equalsIgnoreCase(ref.Status__c))){ 
                 refundSet.add(ref.Trip_ID__c);
               }
              
          if(ref.Business_UnitF__c=='REDBUS_ID'){  
              
             if(string.isNotBlank(ref.Auto_NEFT_Status__c) && ref.Auto_NEFT_Status__c.equalsignorecase('XENDIT_DISBURSE_INITIATED')){
                  refPendingSet.add(ref.Trip_ID__c);
                  roIAutoNeftValue.put(ref.Trip_ID__c, ref.Auto_NEFT_Status__c);
                  system.debug('Pending List'+refPendingSet); 
              }
              else if(string.isNotBlank(ref.Auto_NEFT_Status__c) &&( ref.Auto_NEFT_Status__c.equalsignorecase('XENDIT_DISBURSEMENT_NOT_SUPPORTED') || ref.Auto_NEFT_Status__c.equalsignorecase('XENDIT_DISBURSEMENT_PAASERROR')||ref.Auto_NEFT_Status__c.equalsignorecase('RECIPIENT_ACCOUNT_NUMBER_ERROR') )){
                  reffinanceSet.add(ref.Trip_ID__c);
                  roIAutoNeftValue.put(ref.Trip_ID__c, ref.Auto_NEFT_Status__c);
              }
          }
      }
      if(disbursalTrip.size()>0 || disbursalIds.size()>0){
          List <case> caseList = [Select id,Issue_Type__c, Status,Trip_Id_ct__c,Disbursal_Mode__c,Disbursal_Id__c,Disbursal_Status__c FROM Case WHERE Issue_Type__c='NEFT Refund' and (Trip_Id_ct__c in :disbursalTrip and Disbursal_Id__c in:disbursalIds)];
          system.debug('case List--'+caseList);
          Id NoInputqueueId= [select Id from Group where Type = 'Queue' AND DeveloperNAME ='NEFT_no_input_queue'].id;
          for(case c:caselist){
              if(mapRefund.containsKey(c.Trip_Id_ct__c)){
              c.Disbursal_Status__c=mapRefund.get(c.Trip_Id_ct__c).Disbursal_Status__c;
              c.Disbursal_Mode__c= mapRefund.get(c.Trip_Id_ct__c).Disbursal_Mode__c;
              // c.Disbursal_Id__c = mapRefund.get(c.Trip_Id_ct__c).Disbursal_ID__c;
              if('FAILED_MAX_ATTEMPS_EXCEED'.equalsIgnoreCase(c.Disbursal_Status__c) || 'FAILED_MAX_ATTEMPTS_EXCEED'.equalsIgnoreCase(c.Disbursal_Status__c)){
               
                c.ownerId=NoInputqueueId;
              }
             }else if(mapdesbursId.containsKey(c.Disbursal_Id__c)){
              c.Trip_Id_ct__c=mapdesbursId.get(c.Disbursal_Id__c).Trip_ID__c;
              c.Disbursal_Status__c=mapdesbursId.get(c.Disbursal_Id__c).Disbursal_Status__c;
              c.Disbursal_Mode__c= mapdesbursId.get(c.Disbursal_Id__c).Disbursal_Mode__c;
              // c.Disbursal_Id__c = mapdesbursId.get(c.Disbursal_Id__c).Disbursal_ID__c;
              if('FAILED_MAX_ATTEMPS_EXCEED'.equalsIgnoreCase(c.Disbursal_Status__c) || 'FAILED_MAX_ATTEMPTS_EXCEED'.equalsIgnoreCase(c.Disbursal_Status__c)){
                c.ownerId=NoInputqueueId;
              }
             
             }
          }
          if(caseList.size()>0){
              update caselist;
          } 
         } 
         
        if(refundSet.size()>0){
           List <case> caseList = [Select id,Issue_Type__c,Business_Unit_ct__c,Case_Business_Unit__c,Status,origin,Trip_Id_ct__c, BypassVR__c FROM Case WHERE origin='Failed Transaction' and status in ('open','Awaiting for NEFT Details') and Business_Unit_ct__c!='REDBUS_IN' and Trip_Id_ct__c!='' and Trip_Id_ct__c in :refundSet];
           system.debug('case List'+caseList);
           for(case c:caselist){
              c.status='Closed';
              c.BypassVR__c= !c.BypassVR__c;
              c.Final_Ticket_Status__c='Refunded';
              CaseComment cc = new casecomment();
              cc.CommentBody='Case closed since the refund has been initiated'+'--->saleforce system';
              cc.ParentId=c.id;
              ccList.add(cc);
            }
           if(caseList.size()>0){
              update caselist;
           }   
       }   
      if(refSuccesSet.size()>0){
          List <case> caseList = [Select id,Issue_Type__c, Status, Trip_Id_ct__c, BypassVR__c FROM Case WHERE Issue_Type__c='NEFT Refund' and Trip_Id_ct__c in :refSuccesSet];
          system.debug('case List'+caseList);
          for(case c:caselist){
              c.status='Closed';
              c.BypassVR__c= !c.BypassVR__c;
              c.Auto_NEFT_Status__c = roIAutoNeftValue.get(c.Trip_Id_ct__c);   
              CaseComment cc = new casecomment();
              cc.CommentBody='Amount refunded via Xendit on '+ roIAutoNeftSuccess.get(c.Trip_Id_ct__c )+'.';
              cc.ParentId=c.id;
              ccList.add(cc);
          }
          if(caseList.size()>0){
              update caselist;
          }     
          
      }
      if(refPendingSet.size()>0){
          List <case> casePendingList = [Select id,Issue_Type__c, Status, Trip_Id_ct__c, BypassVR__c FROM Case WHERE Issue_Type__c='NEFT Refund' and Trip_Id_ct__c in :refPendingSet];
          for(case c:casePendingList){
              c.Auto_NEFT_Status__c = roIAutoNeftValue.get(c.Trip_Id_ct__c); 
          }
           if(casePendingList.size()>0){
              update casePendingList;
          }    
      }
      if(reffinanceSet.size()>0){
          Id queueId= [select Id from Group where Type = 'Queue' AND DeveloperNAME ='Finance'].id;
          List <case> casefinList = [Select id, Issue_Type__c,Auto_NEFT_Status__c,Trip_Id_ct__c,OwnerId FROM Case WHERE Issue_Type__c='NEFT Refund' and Trip_Id_ct__c in :reffinanceSet];
           system.debug('<<casefinList'+casefinList);
          for(case c:casefinList){
              c.ownerId=queueId;
              c.Auto_NEFT_Status__c = roIAutoNeftValue.get(c.Trip_Id_ct__c); 
              CaseComment cc = new casecomment();
              cc.CommentBody='Xendit disbursement failed. Finance to try manual refund processing.';
              cc.ParentId=c.id;
              ccList.add(cc);
              
          }
          if(casefinList.size()>0){
              update casefinList;
          }
          
      }
      if(ccList.size()>0){
          insert ccList; 
      }
      
      if(!disbursalIds.isEmpty()  && stopDisbursalCasesUpdate && !system.isFuture() && !System.isBatch())
      {
          stopDisbursalCasesUpdate = false;
          system.debug('-----dis----');
          DisbursalCaseUpadte(disbursalIds,disbursalTrip,mapRefund);
      }
  }
  
  public static void DisbursalCaseUpadte(set<string> ldIds,set<string> tins,map<string,Refund_Order_Items__c> mapRefundId)
  { 
     system.debug('----method----'+ldIds);
      
      list<case> upCselst = new list<case>();
      list<casecomment> ccList=new list<casecomment>();
      for(Case c : [Select id,status,Trip_Id_ct__c,TIN_No__c,BypassVR__c,Disbursal_Id__c,Business_Unit_ct__c from case where issue_type__c='NEFT Refund' and (Disbursal_Id__c IN :ldIds or Trip_Id_ct__c IN :tins) and Status IN ('Open','Refilled NEFT')])
          {
             system.debug('--disbursal case--'+c);
            
            if(mapRefundId.containsKey(c.Trip_Id_ct__c)){
                
            if(('XENDIT_DISBURSMENT'.equalsIgnoreCase(mapRefundId.get(c.Trip_Id_ct__c).Disbursal_Mode__c) && 'DISBURSEMENT_SUCCESSFUL'.equalsIgnoreCase(mapRefundId.get(c.Trip_Id_ct__c).Auto_NEFT_Status__c)) || 'Disbursal_Success'.equalsIgnoreCase(mapRefundId.get(c.Trip_Id_ct__c).Disbursal_Status__c) || 'DISBURSAL_COMPLETED'.equalsIgnoreCase(mapRefundId.get(c.Trip_Id_ct__c).Disbursal_Status__c))
             {
               system.debug('---success---');
               CaseComment cc=new CaseComment();
               cc.CommentBody='system update---Disbursal_Success';
               //c.Disbursal_Status__c='Disbursal_Success';
               cc.ParentId=c.id;
               c.BypassVR__c= !c.BypassVR__c;
               c.status='Closed';
                upCselst.add(c); 
                ccList.add(cc);
             }else if('Disbursal_Failed'.equalsIgnoreCase(mapRefundId.get(c.Trip_Id_ct__c).Disbursal_Status__c)){
               system.debug('---faill---');
               Id queueId= [select Id from Group where Type = 'Queue' AND DeveloperNAME ='Finance'].id;
               CaseComment cc=new CaseComment();
               cc.CommentBody='system update---Disbursal_Failed--Finance to try manual refund processing.';
               c.ownerid=queueId;  
               c.Disbursal_Status__c='Disbursal Failed';        
               cc.ParentId=c.id;
               upCselst.add(c);    
               ccList.add(cc);                
             }else if('MANUAL_NEFT'.equalsIgnoreCase(mapRefundId.get(c.Trip_Id_ct__c).Disbursal_Mode__c)){
               Id queueId= [select Id from Group where Type = 'Queue' AND DeveloperNAME ='Finance'].id;
               CaseComment cc=new CaseComment();
               cc.CommentBody='system update---MANUAL_NEFT--Finance to try manual refund processing.';
               c.ownerid=queueId;         
               cc.ParentId=c.id;
               upCselst.add(c);    
               ccList.add(cc);            
             }                       
          }
         
          system.debug('---upCselst---'+upCselst);
       }
       if(!upCselst.isEmpty()){
           insert ccList;
           update upCselst;
         }
  }    
}