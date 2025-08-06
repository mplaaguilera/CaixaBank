@isTest
public class SEG_ActivarUsuarios_Controller_Test {

	@testSetup
	static void datosIniciales()
	{
		List<User> lstUser = new List<User> ();
		String today = Date.today().format();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'groupcso', Email = 'standarduser@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@testorg' + today + '.com');
		lstUser.add(u);

		User u1 = new User(Alias = 'stand34', Email = 'nogroupcso@testorg.com',
		                   EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                   LocaleSidKey = 'en_US', ProfileId = p.Id,
		                   TimeZoneSidKey = 'America/Los_Angeles', UserName = 'nogroupcso@testorg' + today + '.com');
		lstUser.add(u1);

		User u2 = new User(Alias = 'activegr', Email = 'activegr@testorg.com',
		                   EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                   LocaleSidKey = 'en_US', ProfileId = p.Id,
		                   TimeZoneSidKey = 'America/Los_Angeles', UserName = 'activegr@testorg' + today + '.com');
		lstUser.add(u2);
		insert lstUser;
		SEG_GruposCSO__c grupoCSO = new SEG_GruposCSO__c();
		grupoCSO.Name = 'Grupo Test';
		grupoCSO.SEG_ActivoCSO__c = true;
		insert grupoCSO;

		List<SEG_UsuariosCSO__c> lstUsuario = new List<SEG_UsuariosCSO__c> ();
		SEG_UsuariosCSO__c userCSO = new SEG_UsuariosCSO__c();
		userCSO.SEG_ActivoCSO__c = true;
		userCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		userCSO.SEG_Usuario__c = UserInfo.getUserId();
		lstUsuario.add(userCSO);

		userCSO = new SEG_UsuariosCSO__c();
		userCSO.SEG_ActivoCSO__c = false;
		userCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		userCSO.SEG_Usuario__c = u.Id;
		lstUsuario.add(userCSO);

		userCSO = new SEG_UsuariosCSO__c();
		userCSO.SEG_ActivoCSO__c = false;
		userCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		userCSO.SEG_Usuario__c = u2.Id;
		lstUsuario.add(userCSO);
		insert lstUsuario;
	}
	@isTest
	public static void test_ActivarTodosUsers()
	{
		List<Id> lstRecords = new List<Id>();
		List<SEG_UsuariosCSO__c> lstUsuarios = [Select Id From SEG_UsuariosCSO__c];
		for(SEG_UsuariosCSO__c uCSO :  lstUsuarios)
		{
			lstRecords.add(uCSO.Id);
		}
		SEG_ActivarUsuarios_Controller.activarUsuariosCSO(lstRecords);
		lstUsuarios = [Select Id From SEG_UsuariosCSO__c WHERE SEG_ActivoCSO__c = true];
		System.assertEquals(3,lstUsuarios.size());
	}
}