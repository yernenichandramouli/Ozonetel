/**
* @File Name : OmniSupervisorDashboardControllerTest.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : October 24, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 24, 2024 |   | Initial Version
**/

@isTest
private class OmniSupervisorDashboardControllerTest {
	@isTest
	static void testGetTotAgentsLoggedInOmni() {
		Test.startTest();
        	OmniSupervisorDashboardController.getTotChatAgentsLoggedInSF('');
			OmniSupervisorDashboardController.getTotAgentsLoggedInOmni('');
			OmniSupervisorDashboardController.getTotOnlineAgents('');
			OmniSupervisorDashboardController.getTotBreakAwayAgents('');
			OmniSupervisorDashboardController.getTotOfflineAgents('');
			OmniSupervisorDashboardController.getWaitingChats('');
			OmniSupervisorDashboardController.getOngoingChats('');
        Test.stopTest();
	}
}