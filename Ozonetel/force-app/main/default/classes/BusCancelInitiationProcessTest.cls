/**
 * (c) 2017 RedBus
 *
 * Name           : BusCancelInitiationProcessTest
 * Created Date   : 29 Jan 2017
 * Created By     : Sreenivas M
 * Purpose        : Test class for BusCancelInitiationProcess class
 *
 **/
 
@isTest
public class BusCancelInitiationProcessTest{
    
    @isTest Static void method1(){
        
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        
        BusCancelInitiationProcess bcip=new BusCancelInitiationProcess();
        List<String> reqBody=new List<String>{'TJD954779847_Initiated_2016-12-12 18:30:00Z_9137917_2016-12-13 07:28:10Z'};
        BusCancelInitiationProcess.busCancellationInsert(reqBody);
    }
}