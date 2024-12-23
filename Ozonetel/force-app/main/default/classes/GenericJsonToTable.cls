public class GenericJsonToTable {

    public static string recId{get; set;}
    public GenericJsonToTable(ApexPages.StandardController sc) {
        system.debug('<<sc.getRecord().id'+sc.getRecord().id);
        recId = sc.getRecord().id;
    }
    
    @AuraEnabled(Cacheable=true)
    public static string getJson(string ordId){
        Order_Items__c ord=[select Assurance_Service__c from Order_Items__c where id =: ordId]; 
 	    if(ord.Assurance_Service__c != Null && ord.Assurance_Service__c != '')         
        return ord.Assurance_Service__c;
        else
            return 'error';
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<object> jsonToMap( string jsdata){
        //        Map<String, Object> results =(Map<String, Object>)JSON.deserializeUntyped(jsdata);
        //        set<string> res=results.keyset();
        //        list<string> resList=new List<string>();
        //        resList.addAll(res);        
        //        string keyVal=resList[0];
        //        List<Object> lstCustomers = (List<Object>)results.get(keyVal);
        List<Object> lstdata = (List<Object>)JSON.deserializeUntyped(jsdata); 
        system.debug('<<'+lstdata);
        return lstdata;
    }   
    
    @AuraEnabled(Cacheable=true)
    public static string jsonColumns(string jsdata){
        system.debug('<<jsdata'+jsdata);
        List<string> colList=new List<string>();
        //        Map<String, Object> results =(Map<String, Object>)JSON.deserializeUntyped(jsdata);
        //        set<string> res=results.keyset();
        //        list<string> resList=new List<string>();
        //        resList.addAll(res);
        //        string keyVal=resList[0];
        //        List<Object> lstCustomers = (List<Object>)results.get(keyVal);	
        
        set<String> setcol=new set<string>();
        List<Object> lstdata = (List<Object>)JSON.deserializeUntyped(jsdata); 				
        Integer i=0;
        for (Object sData : lstdata) {
            Map<String, Object> dataAttributes = (Map<String, Object>)sData;
            for (String attributeName : dataAttributes.keyset()) {
                setcol.add(attributeName);
            }
        }
        JSONGenerator jsongen = JSON.createGenerator(true);
        jsongen.writeStartArray();
        for(String str :setcol){
            jsongen.writeStartObject();
            jsongen.writeStringField('label',str );
            jsongen.writeStringField('fieldName', str);
            if(str=='amountPaidByCustomer'){
                jsongen.writeStringField('type','number');
            }
            jsongen.writeEndObject();
        }
        jsongen.writeEndArray();
        string coljson = jsongen.getAsString();
        return coljson;
    }   
}