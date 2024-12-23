public class fetchAllFields
{
    public Static String getFields(String ObjectAPI)
    {
        String FiedNames = '';
        SObjectType objectType = Schema.getGlobalDescribe().get(ObjectAPI);
        Schema.DescribeSObjectResult ob = objectType.getDescribe();
         if(ob==Null)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,'Invalid sObject Type'));
         }
         Map<String , Schema.SObjectField> mapFieldList = ob.fields.getMap();  

         for(Schema.SObjectField field : mapFieldList.values())  
         {  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
             
                FiedNames+= field +',';
            
         }
         if(FiedNames.endsWith(','))
         {
            //FiedNames= FiedNames.substring(0,FiedNames.length()-1);
            FiedNames= FiedNames.removeEnd(',');
         }
         return FiedNames;
    }
}