/**********************************************************************************************************************
 Name:	  AV_ConfidentialBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para crear AccountTeamMembers.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY				AUTHOR				DATE				Description
	1.0			App FSC					Carolina Alonso		18/05/2020			Test version
	1.1			US245181				Sandra Gómez		16/12/2021			executeConfidentialBatch
	1.2			Batch confidencialidad  Patricia Solano	    29/09/2022			Test version modified data for AccountTeamMembers
***********************************************************************************************************************/
@isTest
public class AV_ConfidentialBatch_Test {

	/**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
		List<Account> centrosCaixa = new List<Account>();
		List<User> usuarios = new List<User>();
		List<Contact> contactos = new List<Contact>();
		List<Account> centrosCaixaUpdate = new List<Account>();

		Account centroSuperior3 = new Account();
		centroSuperior3.Name = '00618 STORE MARAGALL';
		centroSuperior3.CC_Numero_Oficina_Empresa__c = '00618';
		centroSuperior3.CC_Numero_Oficina__c = '00618';
		centroSuperior3.RecordTypeId = rt.Id;
		centrosCaixa.add(centroSuperior3);

		Account centroSuperior2 = new Account();
		centroSuperior2.Name = '00617 STORE DIAGONAL';
		centroSuperior2.CC_Numero_Oficina_Empresa__c = '00617';
		centroSuperior2.CC_Numero_Oficina__c = '00617';
		centroSuperior2.RecordTypeId = rt.Id;
		centrosCaixa.add(centroSuperior2);

		Account centroSuperior1 = new Account();
		centroSuperior1.Name = '00616 STORE BALMES';
		centroSuperior1.CC_Numero_Oficina_Empresa__c = '00616';
		centroSuperior1.CC_Numero_Oficina__c = '00616';
		centroSuperior1.RecordTypeId = rt.Id;
		centrosCaixa.add(centroSuperior1);
		
		Account centroCaixa = new Account();
		centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
		centroCaixa.CC_Numero_Oficina_Empresa__c = '00615';
		centroCaixa.CC_Numero_Oficina__c = '00615';
		centroCaixa.RecordTypeId = rt.Id;
		centrosCaixa.add(centroCaixa);

		Account clienteConfidencial = AV_TestHelper.createCustomerSinInsert();
		centrosCaixa.add(clienteConfidencial);
		insert centrosCaixa;

		User usuario1 = AV_TestHelper.createUserSinInsert(null, 'U0009001');
		usuarios.add(usuario1);

		User usuario2 = AV_TestHelper.createUserSinInsert(null, 'U0009002');
		usuarios.add(usuario2);

		User usuario3 = AV_TestHelper.createUserSinInsert(null, 'U0009003');
		usuarios.add(usuario3);

		User usuario4 = AV_TestHelper.createUserSinInsert(null, 'U0009004');
		usuarios.add(usuario4);

		User usuario5 = AV_TestHelper.createUserSinInsert(null, 'U0009005');
		usuarios.add(usuario5);
		insert usuarios;

		Contact contacto1 = AV_TestHelper.createEmployeeSinInsert(centroCaixa, usuario1, usuario1.AV_ExternalID__c);
		contactos.add(contacto1);

		Contact contacto2 = AV_TestHelper.createEmployeeSinInsert(centroCaixa, usuario2, usuario2.AV_ExternalID__c);
		contactos.add(contacto2);

		Contact contacto3 = AV_TestHelper.createEmployeeSinInsert(centroSuperior1, usuario3, usuario3.AV_ExternalID__c);
		contactos.add(contacto3);

		Contact contacto4 = AV_TestHelper.createEmployeeSinInsert(centroSuperior2, usuario4, usuario4.AV_ExternalID__c);
		contactos.add(contacto4);

		Contact contacto5 = AV_TestHelper.createEmployeeSinInsert(centroSuperior3, usuario5, usuario5.AV_ExternalID__c);
		contactos.add(contacto5);
		insert contactos; 

		centroSuperior3.AV_MatriculaResponsable1__c = contacto5.Id;
		centrosCaixaUpdate.add(centroSuperior3);

		centroSuperior2.AV_CentroSuperior__c = centroSuperior3.Id;
		centroSuperior2.AV_MatriculaResponsable1__c = contacto4.Id;
		centrosCaixaUpdate.add(centroSuperior2);

		centroSuperior1.AV_CentroSuperior__c = centroSuperior2.Id;
		centroSuperior1.AV_MatriculaResponsable1__c = contacto3.Id;
		centrosCaixaUpdate.add(centroSuperior1);

		centroCaixa.AV_CentroSuperior__c = centroSuperior1.Id;
		centroCaixa.AV_MatriculaResponsable1__c = contacto2.Id;
		centrosCaixaUpdate.add(centroCaixa);
		
		clienteConfidencial.AV_Confidencial__c = true;
		if (contacto1 != null) {
			clienteConfidencial.AV_EAPGestor__c = contacto1.Id;
		}
		clienteConfidencial.OwnerId = usuario1.Id;
		centrosCaixaUpdate.add(clienteConfidencial);
		update centrosCaixaUpdate;
	}

	/**
	 * Execute the Batch class (AV_ConfidentialBatch) 
	 */ 
	@isTest
	static void executeConfidentialBatch() {
		Test.startTest();
        Database.executeBatch(new AV_ConfidentialBatch());
		AV_LogDebug.printLogDebug('executeConfidentialBatch', 'CT: AV_ConfidentialBatch');
		Test.stopTest();
        AggregateResult[] countATM = [select COUNT(Id) from AccountTeamMember];
        System.assertNotEquals(0, Integer.valueOf(countATM[0].get('expr0')));
	}
}