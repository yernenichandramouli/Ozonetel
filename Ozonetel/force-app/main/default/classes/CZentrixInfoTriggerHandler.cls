/**
* (c) 2017 RedBus
*
* Name           : CZentrixInfoTriggerHandler
* Created Date   : 06 Jun 2017
* Created By     : Sreenivas M
* Purpose        : Handler class for CZentrixInfoTrigger to link C-Zentrix Info to Account
* Test class     : CZentrixInfoTriggerTest
*
**/

Public class CZentrixInfoTriggerHandler
{
    
    public static void LeadActions(list<CZentrix_Info__c> lsCzen){
        set<id> ldIds=new set<id>();
        for(CZentrix_Info__c  cz : lsCzen)
        { 
            if(cz.Lead__c!=null){
                ldIds.add(cz.Lead__c);
            }
        }
        list<lead> ldList=new list<lead>();
        for(Lead ld:[select id,Lead_Traverse__c,Calls_After_Conversions__c,Calls_Before_Conversion__c from lead where id in:ldIds and Calls_After_Conversions__c!=null and Calls_Before_Conversion__c!=null]){
            if(string.isNotBlank(ld.Lead_Traverse__c) && ld.Lead_Traverse__c.contains('Converted')){
                ld.Calls_After_Conversions__c=ld.Calls_After_Conversions__c+1;
            }else{
                ld.Calls_Before_Conversion__c=ld.Calls_Before_Conversion__c+1;
            }
            ldList.add(ld);
        }
        
        if(!ldList.isEmpty()){
            update ldList;
        }
    }
    @future
    public static void linkCZentrixtoAccount(String trigNew)
    {
        /*   List<CZentrix_Info__c> TrigerNw= (List<CZentrix_Info__c>)Json.deserialize(trigNew,List<CZentrix_Info__c>.class);

Set<String> setPhnums = new Set<String>();

for(CZentrix_Info__c  cz : TrigerNw)
{
if(cz.Customer_Ph_No__c!=null && String.isNotBlank(cz.Campaign_Name__c) && 'redBus_Inbound'.equalsIgnoreCase(cz.Campaign_Name__c))
{
setPhnums.add(String.valueOf(cz.Customer_Ph_No__c).right(10));
} 
}

Map<String,String> mapPhtoAccId = new Map<String,String>();
For(Account acc : [Select Id,PersonMobilePhone,Phone_10_Digits__c from Account where Phone_10_Digits__c In :setPhnums])
{
if(String.isNotBlank(acc.Phone_10_Digits__c))
mapPhtoAccId.put(acc.Phone_10_Digits__c.right(10),acc.Id);         
}

System.debug('---mapPhtoAccId---'+mapPhtoAccId);


for(CZentrix_Info__c  czi :TrigerNw)
{
System.debug('---czi ---'+czi );
if(czi.Customer_Ph_No__c!=null && mapPhtoAccId.containsKey(czi.Customer_Ph_No__c.right(10)))
{
System.debug('---Befoe czi ---'+czi.Account_Name__c );
czi.Account_Name__c = mapPhtoAccId.get(czi.Customer_Ph_No__c.right(10));
System.debug('---After czi ---'+czi.Account_Name__c );
}
}

update TrigerNw;
*/
    }
}