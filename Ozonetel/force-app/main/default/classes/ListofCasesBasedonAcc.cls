public with sharing class ListofCasesBasedonAcc 
{
    public List<Case> listofCases{get;set;}
    public ListofCasesBasedonAcc(ApexPages.StandardController controller)
    {
        String accId=ApexPages.CurrentPage().getParameters().get('id');
        if(!String.IsBlank(accId))
        {
            String allFields = '';
            allFields = fetchAllFields.getFields('Case');
            String query='Select '+allFields+' FROM Case Where AccountId =:accId OR Customer_Name__c =:accId';
            listofCases=DataBase.Query(query);
        }
    }
   
}