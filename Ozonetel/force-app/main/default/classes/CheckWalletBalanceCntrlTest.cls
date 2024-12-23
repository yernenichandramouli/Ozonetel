/**
 * (c) 2017 RedBus
 *
 * Name           : CheckWalletBalanceCntrlTest
 * Created Date   : 07 Nov 2017
 * Created By     : Sreenivas M 
 * Purpose        : Test class for CheckWalletBalanceCntrl
 *
 **/
 
@isTest 
public class CheckWalletBalanceCntrlTest
{
      static testMethod void testCallout(){
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        Apexpages.currentpage().getparameters().put('emailId','test@redbus.com');
        Apexpages.currentpage().getparameters().put('phone','9184876772');
        
        CheckWalletBalanceCntrl cntrl=new CheckWalletBalanceCntrl();
        CheckWalletBalanceCntrl.Status cntrlStatus=new CheckWalletBalanceCntrl.status();
        CheckWalletBalanceCntrl.WalletBalanceResponse wrps = new CheckWalletBalanceCntrl.WalletBalanceResponse();
        cntrl.userId='4567';
        cntrl.acPhone='4567';
        cntrlStatus.code=456;
        cntrlStatus.statusCode=456;
        cntrlStatus.statusCode=456;
        cntrlStatus.error='tesr';
        cntrlStatus.statusMessage='error';
        cntrlStatus.type='test';
        cntrl.fetchWalletBalance();
        
    }
}