@isTest
private class CustomMetadataUtilsTest {
    @isTest
    public static void configSetupTest() {
        string fullName ='Amenitie__mdt.Amenitie_Response';
        String label = 'Amenitie Response';

        string values ='{"Values__c ": "1=WIFI"}';

        Map<String, Object> deployedValue = (Map<String, Object>)JSON.deserializeUntyped(values);

        Test.startTest();
        CustomMetadataUtils.createCustomMetadata('Amenitie__mdt','Amenitie Response',deployedValue);
        Test.stopTest();
    }

    @isTest
    public static void configUpdateTest() {
        string fullName ='Amenitie__mdt.Amenitie_Response';
        String label = 'Amenitie Response';

        string values ='{"Values__c ": "1=WIFI"}';

        Map<String, Object> deployedValue = (Map<String, Object>)JSON.deserializeUntyped(values);

        Test.startTest();
        CustomMetadataUtils.updateCustomMetadata('Amenitie__mdt','Amenitie_Response', 'Amenitie Response',deployedValue);
        Test.stopTest();
    }
}