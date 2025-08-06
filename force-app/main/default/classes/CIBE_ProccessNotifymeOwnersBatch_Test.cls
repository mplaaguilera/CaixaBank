/**********************************************************************************************************************
 Name:      CIBE_ProccessNotifymeOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase CIBE_ProccessNotifymeOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        	USER_STORY       AUTHOR         DATE               Description
   	1.0            	App FSC          Bea        	28/01/2021         Init version

***********************************************************************************************************************/
@isTest
private class CIBE_ProccessNotifymeOwnersBatch_Test {
	
    /**
	 * Create 1 Notifyme with the field AV_Employee__c and OwnerId.
	 */
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
			empleado.CC_Matricula__c = 'U0009003';
			empleado.AV_UsuarioAsociado__c = usrTest1.Id;
			empleado.AV_DescFuncion__c = 'EMPLEADO';
            insert empleado;

			RecordType rt = AV_AppUtilities.getRecordType('AV_NotifyMe__c', 'AV_NotifyMe');
			AV_NotifyMe__c noti = new AV_NotifyMe__c();
			noti.AV_Subject__c = 'Notify Me';
			noti.AV_Status__c = 'AV_Pendiente';
			noti.RecordTypeId = rt.Id;
			noti.AV_Description__c = 'Nueva Notificación tipo NotifyMe';
			noti.AV_Employee__c = empleado.Id;
			noti.OwnerId = usrTest1.Id;
			insert noti;
		}
	}  
	/**
	 * Execute the Batch class (CIBE_ProccessNotifymeOwnersBatch)
	 */
	@isTest
	static void executeProccessNotifymeOwnersBatch() {
		
		System.runAs(new User(Id = UserInfo.getUserId())) {
			User usrTest2 = [SELECT Id FROM User where AV_ExternalID__c = 'U0009004'];
			usrTest2.IsActive = false;
			update usrTest2;

			Set<String> setUserIds = new Set<String>{usrTest2.Id};
			
			Test.startTest();
			Contact empleado1 = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U0009003'];
			empleado1.AV_UsuarioAsociado__c = usrTest2.Id;
			update empleado1;
			usrTest2.IsActive = true;
			update usrTest2;
			CIBE_ProccessNotifymeOwnersBatch b = new CIBE_ProccessNotifymeOwnersBatch('300', setUserIds);
			Database.executeBatch(b);
			Test.stopTest();



			List<AV_NotifyMe__c> listNotifyme = [SELECT id, OwnerId FROM AV_NotifyMe__c];
			for (AV_NotifyMe__c nm : listNotifyme) {
				System.assertNotEquals(nm.OwnerId,usrTest2.Id);
			}
		}
	}
}