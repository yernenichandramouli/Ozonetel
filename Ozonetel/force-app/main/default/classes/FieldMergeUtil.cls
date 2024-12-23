/**
 * (c) 2023 RedBus
 *
 * Name           : FieldMergeUtil
 * Created Date   : 31 JUL 2023
 * Created By     : VR Sudarshan
 * Purpose        : Genric class to merge the field values in a string based on the field api names
 * Test class     : FieldMergeUtilTest
 *
 **/
public class FieldMergeUtil {

    // Set default start and end patterns
    public static final String DEFAULT_START_PATTERN = '{!';
    public static final String DEFAULT_END_PATTERN = '}';

    // @description Generate the string with the replaced values. Takes the record Id and executes the query as needed
    // @return Returns the string with all merge fields replaced with values
    @AuraEnabled
    public static String replaceMergeFieldsWithValues (String stringToMerge, String recordId) {
        String objectName = ((Id) recordId).getSObjectType().getDescribe().getName();
        SObject theRecord = getRecord2 (DEFAULT_START_PATTERN, DEFAULT_END_PATTERN, stringToMerge, objectName, recordId);
        return replaceMergeFieldsWithValues2(DEFAULT_START_PATTERN, DEFAULT_END_PATTERN, stringToMerge, theRecord);
    }

    // @description Generate the string with the replaced values
    // @return Returns the string with all merge fields replaced with values
    @AuraEnabled
    public static String replaceMergeFieldsWithValues2 (String startPattern, String endPattern, String stringToMerge, SObject theRecord) {
        if (String.isBlank(stringToMerge)) {
            return stringToMerge;
        }
        // The matcher which returns the matched fields from the given string
        Matcher theMatcher = thePattern(startPattern, endPattern).matcher(stringToMerge);
        while (theMatcher.find()) {
            String mergeField = theMatcher.group(1).trim();
            // Support getting parent fields for the object
            List<String> objectsAndField = mergeField.split('\\.');
            SObject theRecordForData = theRecord;
            // If there is a relationship
            if (objectsAndField.size() > 1) {
                for (Integer i = 0; i < objectsAndField.size() - 1; i++) {
                    if (theRecordForData != null) {
                        theRecordForData = theRecordForData.getSObject(objectsAndField[i]);
                    }
                }
                objectsAndField = new List<String>{objectsAndField[objectsAndField.size()-1]};
            }

            String mergeValue = '';

            // Process if the source record isn't null
            if (theRecordForData != null) {
                try {
                    mergeValue = String.valueOf(theRecordForData.get(objectsAndField[0]));
                    if(mergeValue==null){
                        mergeValue = '{!'+mergeField+'}';
                    }
                }
                catch (Exception ex) {
                    system.debug('### Error processing merge field "' + mergeField + '": ' + ex.getMessage() + '\n\n' + ex.getStackTraceString());
                    mergeValue = '{!'+mergeField+'}';
                }
            }
            mergeValue = mergeValue == null ? '' : mergeValue;
            stringToMerge = stringToMerge.replace(startPattern + mergeField + endPattern, mergeValue);
        }
        return stringToMerge;
    }


    // The Pattern used for all merging. This is the {{ Field__c }} syntax.---.You can replace this with your own merge sync (eg. <? Field__c ?> or {!Field__c}.---.Start pattern '{{ ' will be converted to '\\{\\{\\s'.---.Capturing group will be added '([^ + First Char of End Pattern + ]*)'.----.End pattern ' }}' will be converted to '\\s\\}\\}'
    @AuraEnabled
    public static Pattern thePattern(String startPattern, String endPattern) {
        if (String.isBlank(startPattern.trim()) || String.isBlank(endPattern.trim())) {
            throw new FieldMergeUtilException('Start and End pattern required!');
        }
        String theRegex = '';
        for (String character : startPattern.split('')) {
            theRegex += character == ' ' ? '' : '\\' + character;
        }
        theRegex += '([^'+ endPattern.trim().left(1) +'}]*)';
        for (String character : endPattern.split('')) {
            theRegex += character == ' ' ? '' : '\\' + character;
        }
        theRegex = theRegex.replace(' ', '\\s');
        return Pattern.compile(theRegex);
    }

    // @description Do a dynamic SOQL query to get the record and required fields for the merging
    @AuraEnabled
    public static SObject getRecord (String stringToMerge, String recordId) {
        String objectName = ((Id) recordId).getSObjectType().getDescribe().getName();
        return getRecord2 (DEFAULT_START_PATTERN, DEFAULT_END_PATTERN, stringToMerge, objectName, recordId);
    }


    // @description Do a dynamic SOQL query to get the record and required fields for the merging
    @AuraEnabled
    public static SObject getRecord2 (String startPattern, String endPattern, String stringToMerge, String objectName, String recordId) {
        Set<String> fieldsForQuery = new Set<String>();
        Matcher theMatcher = thePattern(startPattern, endPattern).matcher(stringToMerge);
        while (theMatcher.find()) {
            String mergeField = theMatcher.group(1).trim();
            if (fieldIsValid(objectName, mergeField)) {
                fieldsForQuery.add(mergeField);
            }
        }
        // Build the query. The set of fields needs to be converted to a list to use String.join()
        String theQuery = 'SELECT ' + String.join(new List<String>(fieldsForQuery), ',');
        theQuery += ' FROM ' + objectName;
        theQuery += ' WHERE Id = \'' +  recordId + '\'';
        return Database.query(theQuery);
    }

    // @description Return true if the field is a valid field
    @AuraEnabled
    public static Boolean fieldIsValid (String objectName, String mergeField) {
        Boolean fieldIsValid = true;
        List<String> objectsAndField = mergeField.split('\\.');
        if (objectsAndField.size() == 1) {
            fieldIsValid = objectNameToFieldsMap(objectName).get(objectName).containsKey(mergeField);
        }
        else {
            String currentObjectName = objectName;
            for (Integer i = 0; i < objectsAndField.size(); i++) {
                String currentFieldName = objectsAndField[i];
                if (i == (objectsAndField.size() - 1)) {
                    fieldIsValid = objectNameToFieldsMap(currentObjectName).get(currentObjectName).containsKey(currentFieldName);
                }
                else {
                    if (currentFieldName.endsWith('__r')) {
                        currentFieldName = currentFieldName.replace('__r','__c');
                    }
                    else {
                        currentFieldName += 'Id';
                    }
                    fieldIsValid = objectNameToFieldsMap(currentObjectName).get(currentObjectName).containsKey(currentFieldName);
                    if (fieldIsValid) {
                        try {
                            Schema.DescribeFieldResult fieldDescribe = objectNameToFieldsMap(currentObjectName).get(currentObjectName).get(currentFieldName).getDescribe();
                            if (fieldDescribe.isNamePointing()) {
                                return true;
                            }
                            else {
                                currentObjectName = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                            }
                        }
                        catch (Exception ex) {
                            system.debug(
                                'Could not get object name for lookup field ' + 
                                currentObjectName + '.' + currentFieldName + ': ' + 
                                ex.getMessage() + '\n\n' + ex.getStackTraceString()
                            );

                            return false;
                        }
                    }
                    else {
                        return fieldIsValid;
                    }
                }
            }
        }
        return fieldIsValid;
    }

    // @description Build a map of Object API name to set of API fields. Used to determine if fields exist before executing the query
    public static Map<String, Map<String, Schema.SObjectField>> objectNameToFieldsMap;
    public static Map<String, Map<String, Schema.SObjectField>> objectNameToFieldsMap (String objectName) {

        if (objectNameToFieldsMap == null) {
            objectNameToFieldsMap = new Map<String, Map<String, Schema.SObjectField>>();
        }
        if (!objectNameToFieldsMap.containsKey(objectName)) {
            objectNameToFieldsMap.put(
                objectName,
                Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap()
            );
        }

        return objectNameToFieldsMap;
    }

    // Custom Exceptions
    public class FieldMergeUtilException extends Exception {}
    
}




// String myTemplate = 'Hey {!t}, your email address is {!Email_Id_ct__c} and account name is {!CaseNumber}';

// String myResult = FieldMergeUtil.replaceMergeFieldsWithValues (
//   myTemplate, 
//   '5000p000002bUU9' // The record ID
// );

// system.debug(myResult);