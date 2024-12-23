@isTest
public class AttachmentTriggerHandlerTest{
    static testMethod void TestTicketGenerated()
    {
        Test.startTest();
        
        Payment_Items__c p=new Payment_Items__c();
        p.Order_ID__c='12345';
        p.Payment_System__c='ONLINE';
        p.Creation_Time__c=System.today();
        insert p;
        
        case c=new case();
        c.AmountD__c='12.321';
        c.Bank_Name__c='bni';
        c.Issue_Type__c='DBT';
        c.Trip_Id_ct__c='12345';        
        insert c;   
        string json='{"isTicketGenrated":true,"isGFT":false,"IsvoucherExpired":false,"concludeResponse":"http://m.redbus.id/Confirm?tin=IDN3826899206\u0026ChannelName=MOBILE_WEB"}  ';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        attachment a=new attachment();
        a.name='DBTBulkConfirmFile';
        a.contenttype='csv';
        a.parentId = system.label.DBTRecord;
        blob bb=blob.valueOf('bni_,12321_,'+System.today()+'_,sdfds_,dfsd_,\nbni_,12321_,'+System.today()+'_,dfds_,sdfds_,\n23432_,DFew_,'+System.today()+'_,dsfwe_,sdfwe_,\n');
        
        a.body=bb;
        //a.body=blob.valueOf('QkFOSyBOQU1FXyxDUkVESVRfLENyZWF0ZWQgRGF0ZV8sQW1vdW50IENyZWRpdGVkIERhdGUgXyxERVNDUklQVElPTl8NCmJjYV8sMzEyMDFfLDIwMTktMDItMTUsMTUvMDIvMTkgMTEuNDQuMDlfXyxBVE1MVFJCQ0EgN1oxWUMgMDAwMDA1OTI1IDAyMDYwMTAwODk1ODMwXw0KQlJJQmFua18sIjEsNDksNDk3LjAwXyIsMjAxOS0wMi0xNSwxNS8wMi8xOSAxMS40NC4xMF9fLEFUTSAgRFdJIEhBQlNBUkkgV1UgVE8gUFQgSUJJQk8gR1JPVVAgSV8NCmJuaV8sMjc4MjAwXywyMDE5LTAyLTE2LDE1LzAyLzE5IDExLjQ0LjExX18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KbWFuZGVyaV8sMjQzMjI0M18sMjAxOS0wMi0xNywxNS8wMi8xOSAxMS40NC4xMl9fLEFUTSAgRFdJIEhBQlNBUkkgV1UgVE8gUFQgSUJJQk8gR1JPVVAgSV8NCmJuaV8sMzEyMDBfLDIwMTktMDItMTgsMTUvMDIvMTkgMTEuNDQuMTNfXyxBVE0gIERXSSBIQUJTQVJJIFdVIFRPIFBUIElCSUJPIEdST1VQIElfDQpiY2FfLCIzMyw2MDBfIiwyMDE5LTAyLTE5LDE1LzAyLzE5IDExLjQ0LjE0X18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KbWFuZGlyaV8sIjIwMiw0MDFfIiwyMDE5LTAyLTIwLDE1LzAyLzE5IDExLjQ0LjE1X18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KbWFuZGlyaV8sIjIwMiw0MDJfIiwyMDE5LTAyLTIxLDE1LzAyLzE5IDExLjQ0LjE2X18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KYm5pXywiMjAyLDQwM18iLDIwMTktMDItMjEsMTUvMDIvMTkgMTEuNDQuMTdfXyxBVE0gIERXSSBIQUJTQVJJIFdVIFRPIFBUIElCSUJPIEdST1VQIElfDQo');
        insert a;
        
        Test.stopTest();
    }
    
    static testMethod void TestVoucherExpired()
    {
        Test.startTest();
        
        Payment_Items__c p=new Payment_Items__c();
        p.Order_ID__c='12345';
        p.Payment_System__c='ONLINE';
        p.Creation_Time__c=System.today();
        insert p;
        
        case c=new case();
        c.AmountD__c='12.321';
        c.Bank_Name__c='bni';
        c.Issue_Type__c='DBT';
        c.Trip_Id_ct__c='12345';        
        insert c;   
        string json='{"isTicketGenrated":false,"isGFT":false,"IsvoucherExpired":true,"concludeResponse":"http://m.redbus.id/Confirm?tin=IDN3826899206\u0026ChannelName=MOBILE_WEB"}  ';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        attachment a=new attachment();
        a.name='DBTBulkConfirmFile';
        a.contenttype='csv';
        a.parentId = system.label.DBTRecord;
        blob bb=blob.valueOf('bni_,12321_,'+System.today()+'_,sdfds_,dfsd_,\nbni_,12321_,'+System.today()+'_,dfds_,sdfds_,\n23432_,DFew_,'+System.today()+'_,dsfwe_,sdfwe_,\n');
        a.body=bb;
        insert a;
        
        Test.stopTest();
    }
    static testMethod void TestGFT()
    {
        Test.startTest();
        
        Payment_Items__c p=new Payment_Items__c();
        p.Order_ID__c='12345';
        p.Payment_System__c='ONLINE';
        p.Creation_Time__c=System.today();
        insert p;
        
        case c=new case();
        c.AmountD__c='12.321';
        c.Bank_Name__c='bni';
        c.Issue_Type__c='DBT';
        c.Trip_Id_ct__c='12345';        
        insert c;   
        string json='{"isTicketGenrated":false,"isGFT":true,"IsvoucherExpired":false,"concludeResponse":"http://m.redbus.id/Confirm?tin=IDN3826899206\u0026ChannelName=MOBILE_WEB"}  ';
        Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
        
        attachment a=new attachment();
        a.name='DBTBulkConfirmFile';
        a.contenttype='csv';
        a.parentId = system.label.DBTRecord;
        // blob bb=blob.valueOf('QkFOSyBOQU1FXyxDUkVESVRfLENyZWF0ZWQgRGF0ZV8sQW1vdW50IENyZWRpdGVkIERhdGUgXyxERVNDUklQVElPTl8NCmJjYV8sMzEyMDFfLDIwMTktMDItMTUsMTUvMDIvMTkgMTEuNDQuMDlfXyxBVE1MVFJCQ0EgN1oxWUMgMDAwMDA1OTI1IDAyMDYwMTAwODk1ODMwXw0KQlJJQmFua18sIjEsNDksNDk3LjAwXyIsMjAxOS0wMi0xNSwxNS8wMi8xOSAxMS40NC4xMF9fLEFUTSAgRFdJIEhBQlNBUkkgV1UgVE8gUFQgSUJJQk8gR1JPVVAgSV8NCmJuaV8sMjc4MjAwXywyMDE5LTAyLTE2LDE1LzAyLzE5IDExLjQ0LjExX18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KbWFuZGVyaV8sMjQzMjI0M18sMjAxOS0wMi0xNywxNS8wMi8xOSAxMS40NC4xMl9fLEFUTSAgRFdJIEhBQlNBUkkgV1UgVE8gUFQgSUJJQk8gR1JPVVAgSV8NCmJuaV8sMzEyMDBfLDIwMTktMDItMTgsMTUvMDIvMTkgMTEuNDQuMTNfXyxBVE0gIERXSSBIQUJTQVJJIFdVIFRPIFBUIElCSUJPIEdST1VQIElfDQpiY2FfLCIzMyw2MDBfIiwyMDE5LTAyLTE5LDE1LzAyLzE5IDExLjQ0LjE0X18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KbWFuZGlyaV8sIjIwMiw0MDFfIiwyMDE5LTAyLTIwLDE1LzAyLzE5IDExLjQ0LjE1X18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KbWFuZGlyaV8sIjIwMiw0MDJfIiwyMDE5LTAyLTIxLDE1LzAyLzE5IDExLjQ0LjE2X18sQVRNICBEV0kgSEFCU0FSSSBXVSBUTyBQVCBJQklCTyBHUk9VUCBJXw0KYm5pXywiMjAyLDQwM18iLDIwMTktMDItMjEsMTUvMDIvMTkgMTEuNDQuMTdfXyxBVE0gIERXSSBIQUJTQVJJIFdVIFRPIFBUIElCSUJPIEdST1VQIElfDQo');
        // blob bb=blob.valueOf('23r3_,12321_,'+System.today()+'_,sdfds_,dfsd_,\n2343_,343_,'+System.today()+'_,dfds_,sdfds_,\n23432_,DFew_,'+System.today()+'_,dsfwe_,sdfwe_,\n');
        blob bb=blob.valueOf('bni_,12321_,'+System.today()+'_,sdfds_,dfsd_,\nbni_,12321_,'+System.today()+'_,dfds_,sdfds_,\n23432_,DFew_,'+System.today()+'_,dsfwe_,sdfwe_,\n');
        a.body=bb;
        insert a;        
        Test.stopTest();
    }
    
}