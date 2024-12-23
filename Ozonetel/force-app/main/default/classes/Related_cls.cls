public class Related_cls 
{
    public string Accid{get;set;}
    public Account acc{get;set;}
    public list<Order_Items__c> Traslst{get;set;}
    public Related_cls(ApexPages.StandardController controller)
    {
        Accid=ApexPages.CurrentPage().getParameters().get('Id');
        acc=new Account();
        if(String.isNotBlank(Accid)){
        acc=[select id,Name from Account where id=:Accid];
        Traslst=new list<Order_Items__c>();
       //Traslst=[select id,Name,status__c, Order_Id__c, Source__c, Corrected_Date_of_Issue__c, Corrected_Date_of_Journey__c, Boarding_Time__c, Date_Of_Service__c, Boarding_Point__c,Dropping_Point__c,Transaction_Status__c,Destination__c,Customer_Name__c,Primary_Contact_Customer__c,  Amount_Recieved_Value__c, Total_Fare__c, Date_Of_Purchase__c,Service_Provider_Name__c,Total_Fare_Currency__c, Order_Item_Reference_No__c, Total_Fare_Value__c from Order_Items__c where Customer_Name__c=:Accid OR Primary_Contact_Customer__c=:Accid];
         
        if(!String.IsBlank(Accid))
        {
            String allFields = '';
            allFields = fetchAllFields.getFields('Order_Items__c');
            String query='Select '+allFields+' FROM Order_Items__c Where Customer_Name__c =:accId OR Primary_Contact_Customer__c=:accId';
            Traslst=DataBase.Query(query);
        }
       }
     } 

}