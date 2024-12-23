trigger EmailMessageTrigger on EmailMessage (after insert) {

   List<EmailMessage> emList=new List<EmailMessage>();
  for(EmailMessage em:Trigger.new){
     emList.add(em);
   }
   
   if(!emList.isEmpty())
   EmailMessageTriggerHandler.captureEmailMessages(emList);

}