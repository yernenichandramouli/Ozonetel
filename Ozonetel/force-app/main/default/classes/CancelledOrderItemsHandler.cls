/**
*
* Name           : CancelledOrderItemsHandler 
* Created Date   : 05 Sep 2017
* Created By     : Veeramanikanta
* Purpose        : Create a case and assign it to Force Cancellation Queue
* Test class     : CancelledOrderItemsTest
*
**/
public class CancelledOrderItemsHandler{
   
    public static void createCase(List<Cancelled_Order_Items__c> newItems,Map<Id,Cancelled_Order_Items__c> TriggerOldMap){
       
        Group g=[Select Id from Group where name='Force Cancellation Queue' limit 1];
        String statusString= Label.Force_Cancellation_Status;
        set<string> statusValues=new set<string>();
        for(string s:statusString.split(',')){
            statusValues.add(s);
        }
        set<id> tIds=new set<id>();
        for(Cancelled_Order_Items__c c:newItems){
           tIds.add(c.Order_Item_Name__c);
        }
        Map<id,Order_Items__c> tMap=new Map<id,Order_Items__c>([select id,seat_no__c,Business_Unit__c,Operator_Cancellation_Charges__c,(Select id,Refunded_Amount__c,Refund_Amount__c from Refund_Order_Items__r) from Order_Items__c where id in: tIds]);
        Map<id,id> mapCases = new Map<id,id>();
        string busnUnit;
        
        for(Case c : [Select id,Cancellation_ID__c,Business_Unit_ct__c from case where Issue_Type__c='Force Cancellation' and Status!='Closed' AND Cancellation_ID__c IN :newItems])
        {
            mapCases.put(c.Cancellation_ID__c,c.id);
           
        }
       
        List<case> caseList=new List<case>();
        list<CaseComment> listCommToInsert=new list<CaseComment>();
        for(Cancelled_Order_Items__c c:newItems){
            if(c.Order_Item_Name__c!=null && statusValues.contains(c.Operator_Cancellation_Status__c)){
                
                case cObj=new case();
                if(mapCases.containsKey(c.id))
                  cObj.id = mapCases.get(c.id);
                  
                cObj.Transaction_ID__c=c.Order_Item_Name__c;
                cObj.subject='Force Cancellation';
                cObj.status='Open';
                cObj.Issue_Type__c='Force Cancellation';
                cObj.Cancellation_ID__c=c.id;
                cObj.FC_Cancelled_Seats__c=c.Seates_to_be_cancelled__c;
                cObj.origin ='Salesforce System';
                RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'case' AND Name = 'Inbound Call'];
                cObj.RecordTypeId = rt.Id;

                if(tMap.containskey(c.Order_Item_Name__c))
                {
                    List<String> canSeats = new List<String>();
                    List<String> totSeats = new List<String>();
                    
                    busnUnit=tMap.get(c.Order_Item_Name__c).Business_Unit__c;
                    
                    if(string.isNotblank(busnUnit)){
                        cObj.country__c=OrderItemTransactionResource__c.getValues(busnUnit).Case_Country__c;
                        cObj.Business_Type__c=OrderItemTransactionResource__c.getValues(busnUnit).Case_Business_Type__c;
                    }            
                
                    
                    if(String.isNotBlank(c.Seates_to_be_cancelled__c))
                        canSeats=c.Seates_to_be_cancelled__c.split(',');  
                        
                    if(String.isNotBlank(tMap.get(c.Order_Item_Name__c).seat_no__c))             
                        totSeats = tMap.get(c.Order_Item_Name__c).seat_no__c.split(',');
                    
                    if(canSeats.size()==totSeats.size())
                         cObj.FC_Cancellation_Type__c='Full Cancellation';
                    else
                         cObj.FC_Cancellation_Type__c='Partial Cancellation';
                         
                    System.debug('tMap...'+tMap+'--ref--'+tMap.get(c.Order_Item_Name__c).Refund_Order_Items__r);
                    
                   
                    if(!tMap.get(c.Order_Item_Name__c).Refund_Order_Items__r.isEmpty())
                    {
                       Decimal toatlRefundAmount=0.0;
                       string refundamount='';
                       for(Refund_Order_Items__c roi :tMap.get(c.Order_Item_Name__c).Refund_Order_Items__r)
                       {
                           toatlRefundAmount = toatlRefundAmount+roi.Refunded_Amount__c;
                           refundamount=roi.Refund_Amount__c;
                           
                       }
                       toatlRefundAmount= toatlRefundAmount.setScale(2);
                       cObj.FC_Refunded_Amount__c = toatlRefundAmount;
                       
                       cObj.RefundOrderItem_Amount__c=string.valueof(refundamount);
                     
                    }
                 
                   
                }
                
                if(!Test.isRunningTest())
                    cObj.ownerid=g.id;
                caseList.add(cObj);
               
            }  
           
            //This is to close the case automatically after omega retry success
            else if(Trigger.isUpdate && UserInfo.getUserName().contains('integration@redbus.com') && 'OPERATOR_CANCELLATION_INITIATED'.equalsIgnoreCase(triggerOldMap.get(c.Id).Operator_Cancellation_Status__c) && 'OPERATOR_CANCELLATION_SUCCESS'.equalsIgnoreCase(c.Operator_Cancellation_Status__c) && tMap.containskey(c.Order_Item_Name__c) && tMap.get(c.Order_Item_Name__c).Operator_Cancellation_Charges__c!=null && mapCases.containsKey(c.id))
            {
                  case cObj=new case();
                  CaseComment comm = new CaseComment();
                  cObj.id = mapCases.get(c.id);
                  cObj.Force_Cancellation_Charges__c=c.Operator_Cancellation_Charges__c;
                  cObj.Force_Cancellation_Status__c='Operator Accepted';
                  cObj.status='closed';
                  cObj.Closed_By__c = 'Omega Retry';
                  cObj.Closed_By_Agent__c = 'Omega Retry';
                  cObj.Closed_By_Agent_Role__c = 'Omega Retry';
                  comm.commentbody ='Salesforce System - Ticket Has been Closed By Omega Retry Mechanisim';
                  comm.parentId = cObj.id;
                  listCommToInsert.add(comm);
                  caseList.add(cObj);
            
                   if(!Test.isRunningTest())
                    cObj.ownerid=g.id;
              }
           }
           
        if(!listCommToInsert.isEmpty()){
         insert listCommToInsert;
        }
        
        if(!caseList.isEmpty()){
            upsert caseList;
        }
        
    }
    
}