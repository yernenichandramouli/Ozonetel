trigger CampaignTrigger on Campaign (before update) {

CampaignTriggerHandler.BeforeUpdate(Trigger.new,Trigger.oldMap);


}