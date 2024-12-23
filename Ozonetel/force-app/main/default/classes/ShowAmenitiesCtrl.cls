/**
 * (c) 2023 RedBus
 *
 * Name           : ShowAmenitiesCtrl
 * Created Date   : 10 OCT 2022
 * Created By     : VR Sudarshan
 * Jira Id        : CRM - 1420
 * Test class     : ShowAmenitiesCtrlTest
 *
 **/
public class ShowAmenitiesCtrl {

    @AuraEnabled
    public static map<string,string> fetchAmenities(string transactionId){
        System.debug('::: transactionId = '+transactionId);
        Map<string, string> mapToRetrun = New Map<string,string>();
        Map<string, string> amenitiesMap = New Map<string,string>();
        List<string> amentiesValues = New List<String>();
        if(String.isNotBlank(transactionId)){
            try {
                List<Amenitie__mdt> metaDataList = [SELECT Values__c FROM Amenitie__mdt WHERE DeveloperName='Amenitie_Response' LIMIT 1];
                Order_Items__c oritAminiteData = [SELECT Amenities__c FROM Order_Items__c WHERE Id=:transactionId LIMIT 1] ;
                if(String.isNotBlank(oritAminiteData.Amenities__c)){
                    amentiesValues = metaDataList[0].Values__c.split(';');
                    for (String amenity : amentiesValues){
                        List<String> parts = amenity.split('=');
                        if (parts.size() == 2) {
                            String key = parts[0];
                            String value = parts[1];
                            amenitiesMap.put(key, value);
                        }
                    }

                    List<string> oritAmenites = oritAminiteData.Amenities__c.split(',');
                    for(string s : oritAmenites){
                        if(amenitiesMap.containsKey(s)){
                            mapToRetrun.put(s, String.valueOf(amenitiesMap.get(s)));
                        }else{
                            mapToRetrun.put(s, 'No Data');
                        }
                    }
                }
                system.debug('::: Map to retrun '+mapToRetrun);
            } catch (Exception e) {
                mapToRetrun.put('Error',+e.getMessage());
            }
        }else{
            mapToRetrun.put('No Data ', 'No Data');
        }
        return mapToRetrun;
    }
}