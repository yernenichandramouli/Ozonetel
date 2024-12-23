public inherited sharing class  CSVfileController {

    @AuraEnabled
    public static list<BP_Verification__c> readCSVFile(Id idContentDocument){
        list<BP_Verification__c> lstBPVInsert = new list<BP_Verification__c>();
        if(idContentDocument != null) {
            
            //getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
           
            //split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            for(Integer i = 1; i < lstCSVLines.size(); i++){
                list<String> csvRowData = lstCSVLines[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                list<String> conlist = csvRowData[1].split('/');
                System.debug('==conlist===> '+conlist+'---size--'+conlist.size());
                for(string s:conlist){
                BP_Verification__c objBPV = new BP_Verification__c();
                objBPV.BP_Name__c = csvRowData[0]; 
                objBPV.BP_Contact_No__c =s;
                objBPV.Source__c = csvRowData[2];
                objBPV.Destination__c = csvRowData[3];
                objBPV.Service_Provider_Name__c = csvRowData[4];
                objBPV.Service_Provider_Id__c = csvRowData[5];
                objBPV.BO_Region__c = csvRowData[6]; 
                objBPV.BP_Address__c =csvRowData[7];
                objBPV.BP_Id__c = csvRowData[8];
                objBPV.Integration__c = csvRowData[9];
                objBPV.Landmark__c = csvRowData[10];
                objBPV.Primo_Enabled__c = boolean.valueof(csvRowData[11]);
                objBPV.RB_Location_Id__c = csvRowData[12]; 
                objBPV.Route_Id__c = csvRowData[13];
                objBPV.ServiceID__c  = csvRowData[14];
                objBPV.Type__c = csvRowData[15];
                objBPV.Vendor_BP_name__c = csvRowData[16];
                lstBPVInsert.add(objBPV);
                system.debug('==lstBPVInsert=='+lstBPVInsert);
                }
            }

            try{    
                if(!lstBPVInsert.isEmpty()) {
                     database.insert(lstBPVInsert);
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
        }
        return lstBPVInsert;    
    }
}