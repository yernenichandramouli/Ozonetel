/*global class caseEmailServiceHandler implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
          return result;
      }
  }
  */
  
 
global class caseUpdateEmailServiceHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail( Messaging.InboundEmail email, Messaging.InboundEnvelope env ) {
   
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();         
        String myPlainText = email.plainTextBody;
           
        try {
        
        String emailSubject = email.subject;
          EmailMessage emailMessage = new EmailMessage(); 
            
            if(string.isNotBlank(emailSubject) &&  emailSubject.contains('caseNumber:')){
               system.debug('--contais--');  
               system.debug('--no--'+emailSubject.substringAfter('caseNumber:'));  
              string CaseNumberExtract = emailSubject.substringAfter('caseNumber:'); 
              list<Case> csLst = [select id,status,ownerId,Flow_Type__c from Case where CaseNumber =:CaseNumberExtract]; 
              Set<String> setTATEnabledGeos = new Set<String>{'Approved For Bus Cancellation','Rejected For Bus Cancellation','Department Revert'};

              if(!csLst.isEmpty() && !setTATEnabledGeos.contains(csLst[0].status)){
                  csLst[0].status ='BO revert';
                  csLst[0].ownerId=System.Label.L2_Support_Queue_Id;
                update csLst[0];
                emailMessage.ParentId = csLst[0].Id;

               }
               
                //emailMessage.RelatedToId = csLst[0].Id

            }
            
            
           
            emailMessage.Status = '0'; // email is New
            emailMessage.FromAddress = email.FromAddress;
            if ( email.toAddresses.size() > 0 )
                emailMessage.ToAddress = String.join( email.toAddresses, ';' );
                
            if ( email.ccAddresses != null && email.ccAddresses.size() > 0 )
                emailMessage.CcAddress = String.join( email.ccAddresses, ';');
            emailMessage.FromName = email.FromName; // from name  
            emailMessage.Subject = email.Subject; // email subject  
            emailMessage.TextBody = myPlainText; // email body  
            insert emailMessage; // insert    
                
            result.success = true;       
            
        } catch ( Exception e ) {
        
            System.debug( 'Error is:' + e.getMessage() );   
            result.success = false;     
            
        }        
        return result;
        
    }
    
}