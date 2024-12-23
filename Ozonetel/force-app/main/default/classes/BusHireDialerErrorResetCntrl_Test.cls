@isTest
public class BusHireDialerErrorResetCntrl_Test
{
    Static testMethod void errortest()
    {
       User_Details__c  usrDt =new  User_Details__c ();
        usrDt.is_Error_Occurred__c=true;
        insert usrDt;
 
        Test.startTest();
        BusHireDialerErrorResetCntrl.resetError(String.valueOf(usrDt.id));
        Test.stopTest();
    }
}