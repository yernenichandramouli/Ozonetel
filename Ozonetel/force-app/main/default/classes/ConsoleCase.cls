public with sharing class ConsoleCase {
public Id caseId{get;set;}
    public Id accId{get;set;}
    public ConsoleCase(ApexPages.StandardController controller) {
                          Account acc1= (Account)controller.getRecord();
        accId=acc1.Id;
        System.debug(':::account id'+acc1);
        Case cas;
        if(accId!=null){
        try{
         cas= [Select Id,AccountId from Case where isClosed=false and (AccountId=:acc1.Id  OR Customer_Name__c=:acc1.Id) Order by CreatedDate Desc Limit 1];
        }Catch(Exception e){
            System.debug('error occured due to no open cases'+e);
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Welcome to Case'));
        }
        if(cas!=null) {
            caseId=cas.Id;
        }
        }
    }

    
    public ConsoleCase(){
        
    }
    
    public PageReference getOpenCase(){
       
        if(caseId!=null) 
       {
           return New PageReference('/'+caseId);
       }
        else if(accId!=null){
       return New PageReference('/apex/caseCreationPage?accId='+accId);
        }
        return null;
    }
    
     
    
}