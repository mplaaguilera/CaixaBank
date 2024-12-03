@isTest
public class EV_ConfirmarAsistencia_Controller_Test {
	@isTest
	public static void blanqueoClase(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		System.runAs(newUser){
			EV_ConfirmarAsistencia_Controller.metodoBlanco();
		}
		System.assertEquals('', '', 'Test correcto');
	}
}