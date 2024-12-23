@isTest
public class DBTTriggerTest
{
    static testMethod void test()
    {
    Test.starttest();
    case c=new case();
    c.amountD__c='200.987';
    c.bank_name__c='bni';
    insert c;
    case cObj=[select id from case where id=:c.id];
    DBT__c d=new DBT__c();
    d.case__c=cObj.id;
    d.status__c='GFT';
    insert d;
    Test.stoptest();
    }
    
    static testMethod void test1()
    {
    Test.starttest();
    list<DBT__c> dbtlst = new list<DBT__c>();
    string json='[{"Id":"a0m0p0000004Tto","IsProcessed":true,"MatchedOrderID":"ac71d5c2-e9c2-4159-b042-8acc7d4129e7","ConcludeResponse":"https://redbus.id?tin=ID785764776467","ErrorMetaInfo":null}]';        
   
     DBT__c db = new DBT__c();
     db.Status__c='No Case Found';
     db.Bank_Name__c='sbi';
     db.Formatted_Amount__c='12345';
     db.Description__c='test';
     dbtlst.add(db);
     insert dbtlst;
     DBTTriggerHandler.dbtAfterInsert(dbtlst);
     
    Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json)); 
     DBT__c dbb = new DBT__c();
     db.id='a0m0p0000004Tto';
     dbb.Matched_OrderID__c='c7f90fea-c80e-4eea-8f44-ca5c5902669e';
     dbb.Error_Code__c='null';
     dbb.Error_Message__c='';
     insert dbb;
    
    DBTFuzzyQueueable.ErrorMetaInfo errinfo = new DBTFuzzyQueueable.ErrorMetaInfo();
    errinfo.ErrorCode='123345';
    errinfo.ErrorMsg='234567';
    DBTFuzzyQueueable.DBTresponse dbtres = new DBTFuzzyQueueable.DBTresponse(); 
    dbtres.MatchedOrderID='1233456';
    dbtres.ConcludeResponse='34567';
    Test.stoptest();
    }
   static testMethod void errorCode()
    {
    Test.starttest();
     list<DBT__c> dbtlst = new list<DBT__c>();
     DBT__c db = new DBT__c();
     db.Status__c='No Case Found';
     db.Bank_Name__c='sbi';
     db.Formatted_Amount__c='12345';
     db.Description__c='test';
     dbtlst.add(db);
     insert dbtlst;
     DBTTriggerHandler.dbtAfterInsert(dbtlst);
      string json1='[{"Id":"a0m0p0000004Tto","IsProcessed":false,"MatchedOrderID":"ac71d5c2-e9c2-4159-b042-8acc7d4129e7","ConcludeResponse":"https://redbus.id?tin=ID785764776467","ErrorMetaInfo":null}]';
      Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json1)); 
     Test.stoptest();
     }
}