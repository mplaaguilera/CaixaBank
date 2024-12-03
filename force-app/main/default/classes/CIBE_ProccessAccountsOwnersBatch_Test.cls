/**********************************************************************************************************************
 Name:      CIBE_ProccessAccountsOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase CIBE_ProccessAccountsOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY		AUTHOR			DATE                Description
   	1.0           US639303        	Bea   			31/07/2023          Init version

***********************************************************************************************************************/
@isTest
private class CIBE_ProccessAccountsOwnersBatch_Test {
	
	@TestSetup
	static void setup() {
       	
        System.runAs(new User(Id = UserInfo.getUserId())) {
			
            User usrTest1 = CIBE_TestHelper.createUser('CIBE_Gestor');
			usrTest1.AV_ExternalID__c = 'U0009003';
			update usrTest1;
			User usrTest2 = CIBE_TestHelper.createUser('CIBE_Gestor');
			usrTest2.AV_ExternalID__c = 'U0009004';
			update usrTest2;

            Contact empleado = new Contact();
            empleado.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            empleado.LastName = 'Prueba 1';
            empleado.Phone = '987456321';
          //  empleado.AccountId = acc.Id;
			empleado.CC_Matricula__c = 'U0009003';
			empleado.AV_UsuarioAsociado__c = usrTest1.Id;
			empleado.AV_DescFuncion__c = 'EMPLEADO';
            insert empleado;

			//Account acc = CIBE_TestHelper.createCustomerWithEAPGestor(empleado);
			List<Account> accounts = new List<Account>();
        	RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_Cliente');
			for (Integer i=0;i<10;i++) {
				Account acc = new Account(
						// FirstName = 'FirstName' + i,
						// LastName = 'LastName' + i,
						Name = 'Name' + i,
						RecordTypeId = rt.Id,
						AV_NumPerso__c = '123' + i,
						AV_Negocio__c = 'BPA',
						AV_EAPGestor__c = empleado.Id,
						OwnerId = usrTest1.Id
					);
				accounts.add(acc);
			}
			insert accounts;
        
        	empleado.AV_UsuarioAsociado__c = usrTest2.Id;
        	update empleado;
        }
	}

	/**
	 * Execute the Batch class (CIBE_ProccessAccountsOwnersBatch) 
	 */
	@isTest
	static void executeProccessAccountsOwnersBatch() {
		System.runAs(new User(Id = UserInfo.getUserId())) {
			User usrTest2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009004' limit 1];
			Set<String> setUserIds = new Set<String>{usrTest2.Id};

			CIBE_ProccessAccountsOwnersBatch b = new CIBE_ProccessAccountsOwnersBatch('300', setUserIds);
			
			Test.startTest();	
			Database.executeBatch(b);
			Test.stopTest();
			
			List<Account> listData = [SELECT id, OwnerId FROM Account];
			for (Account acc : listData) {
				System.assertEquals(usrTest2.id, acc.OwnerId);
			}
		}	
	}
}