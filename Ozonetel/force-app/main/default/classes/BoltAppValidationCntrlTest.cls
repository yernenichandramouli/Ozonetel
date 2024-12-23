@isTest
public class BoltAppValidationCntrlTest{
    @testsetup
    static void createCase(){
        case c=new case();
        c.Status='Open';
        c.Issue_Sub_Category__c ='My boarding or dropping point was changed by the bus operator';
        c.issue_type__c='I have a problem with bus service';
        c.TIN_No__c='tn4567890';
        c.Trip_Id_ct__c='4567890';
        c.Order_UUId__c='854567876678';
        c.Total_Fare_Value__c=10;
        c.Service_Providerr_Id__c='123456';
        c.SS_DOJ__c=system.now();
        c.Service_Id__c='123456';
        insert c;
      } 
    
    static testMethod void caseTest()
    {
       Test.startTest();
        case cObj=[select issue_type__c,Issue_Sub_Category__c,id from case limit 1];
        list<case> cslst=BoltAppValidationCntrl.getCases(cObj.id);
        string seljson ='[{"value":"Yes","key":"1"},{"value":"No","key":"2"},{"value":"Not Verified","key":"3"},{"value":"Frequent Traveller","key":"7"},{"value":"No","key":"8"},{"value":"No","key":"9"}]';
        string cmntsJson ='[{"value":"test","key":"1"},{"value":"test1","key":"2"},{"value":"test3","key":"3"},{"value":"redd","key":"7"},{"value":"est2","key":"8"},{"value":"teees","key":"9"}]';
        list<Bolt_Validation_Question__mdt> vldaMdt=BoltAppValidationCntrl.getBoltValidationLevels(cObj.id);
        string comments=BoltAppValidationCntrl.InsertComments(cObj.id,'stafName','stafNo','comments');
        string refund=BoltAppValidationCntrl.getMaxRefundAmountApi(cObj.id);
       BoltAppValidationCntrl.getDriverDetails(cObj.id);
       string finalstatus=BoltAppValidationCntrl.updateRecordwithBoltValidationStatus(cObj.id,'fail');
       list<casecomment> cmlst=BoltAppValidationCntrl.getCaseCommentsList(cObj.id);
               string boltValues=BoltAppValidationCntrl.InsertQuestionValuesComments(cObj.id,seljson,cmntsJson,'amount');
        test.stopTest();
        
    }   
    
 }