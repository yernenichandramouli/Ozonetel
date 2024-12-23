trigger ContentVersionTrigger on ContentVersion (after insert) {
    for(ContentVersion cd:Trigger.new){   
        if(string.isNotBlank(cd.title) && cd.title.startswith('SFAgentFromChat')){
            System.debug('title2-->'+cd.title);
            ContentVersionTriggerHandler.sendToS3(cd.Id);
        }
    }
}