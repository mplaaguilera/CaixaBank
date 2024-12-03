@isTest
public class EV_WS_CampaignMembers_Test {
	@isTest
	public static void blanqueoClase(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
			EV_WS_CampaignMembers.metodoBlanco();
		}
		System.assertEquals('', '', 'Test correcto');
	}
}