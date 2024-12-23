trigger AttachmentTrigger on Attachment (after insert) {
    List<Attachment> attList=new List<Attachment>();
    set<id> attIds=new set<id>();
    for(Attachment att:Trigger.new){
        if(att.Name==system.label.DBTAttachment){
            attList.add(att);
            attIds.add(att.id);
        }
    }
    if(!attIds.isEmpty()){
        AttachmentTriggerHandler.DBTConfirmations(attIds);
    }
}