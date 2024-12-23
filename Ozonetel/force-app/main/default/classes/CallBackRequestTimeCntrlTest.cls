@isTest
private class CallBackRequestTimeCntrlTest {
    @isTest 
    static void testMethod1() {
    
        List<String> valList = new List<String>{'todayTab', 'expiredTab', 'futureTab', ''};
        Test.startTest();
        
        for (String ele : valList) {
            
            CallBackRequestTimeCntrl.getCallBackReqCases(ele);
        }
        Test.stopTest();
    }
}