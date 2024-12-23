@isTest
public class CSVfileControllerTest {  

public static String str = 'BASE STATION,SENSOR ID,STATUS,SENSOR MODEL,test,test1,test2,test3,test4,test5,test6,test7,test7,test8,test9,test10,test11,test12  \n' + 'Leeds,1,Enabled ,R8,test,t,m,k,k,i,n,true,n,m,v,v,v \n' + 'Glasgow Central,2,Enabled,R8,test1,t,m,k,k,l,n,n,n,m,v,v,v';
    
    
    @isTest
    public static void testcsv(){
    
     test.startTest();       
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =Blob.valueOf(str);
        insert cv;     
        
        ContentVersion conv = [Select ContentDocumentId From ContentVersion Where Id =:cv.id];
        list<BP_Verification__c> bplist = new list<BP_Verification__c>  ();
        
        BP_Verification__c newbp = new BP_Verification__c (BP_Name__c = 'leads', BP_Contact_No__c = '1', Source__c = 'Enabled', Destination__c = 'r8',Service_Provider_Name__c ='test',Service_Provider_Id__c ='t',BO_Region__c ='m',BP_Address__c ='k',BP_Id__c ='k',Integration__c ='i',Landmark__c ='n',Primo_Enabled__c =true,RB_Location_Id__c ='n',Route_Id__c ='m',ServiceID__c ='v',Type__c ='v',Vendor_BP_name__c ='v');
        insert newbp;
        
        list<BP_Verification__c> ressult =CSVfileController.readCSVFile(conv.ContentDocumentId);
    
     test.stopTest();
        
    }
    
    
    
}