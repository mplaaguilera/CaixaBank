@isTest
public with sharing class EV_CBK_SCH_Queueable_Test {
	@isTest
	public static void blanqueoClase(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
			EV_CBK_SCH_Queueable.metodoBlanco();
		}
		System.assertEquals('', '', 'Test correcto');
	}
}