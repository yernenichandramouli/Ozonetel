public class CallBackRecordsController {
public list<Call_Back_Records__c> cbList{get;set;}

public CallBackRecordsController(){
String UserID = UserInfo.getUserId();
cbList=new list<Call_Back_Records__c>();
user u=[select id,CZentrix_Agent_Id__c,username from user where id=:UserInfo.getUserId()];
cbList=[select id,name,agent_id__c,Call_Back_Time__c,CB_Status__c from Call_Back_Records__c where agent_id__c=:u.username and CB_Status__c!='Closed' order by Call_Back_Time__c asc];
}

}