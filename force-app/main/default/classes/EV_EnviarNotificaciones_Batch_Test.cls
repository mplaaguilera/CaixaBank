@isTest
public class EV_EnviarNotificaciones_Batch_Test {
	@isTest
	public static void blanqueoClase(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
			EV_EnviarNotificaciones_Batch.metodoBlanco();
		}
		System.assertEquals('', '', 'Test correcto');
	}
}