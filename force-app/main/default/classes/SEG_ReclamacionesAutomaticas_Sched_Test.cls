@isTest
public class SEG_ReclamacionesAutomaticas_Sched_Test {

    @TestSetup
	public static void crearDatosPrueba() {

        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
		Id recordMotiv = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		Id recordProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
		Id accRecTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		Id contactRecord = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

		List<SObject> listadoTotal = new List<SObject> ();

        Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'Empresa segmentos';
		cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
		cuentaSEG1.CC_Numero_Documento__c = '11111111H';
		insert cuentaSEG1;

		// Crear contactos para cuentas SEG
		Contact contactoSEG1 = new Contact();
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contactoSEG1.LastName = 'Contacto SEG 1';
		contactoSEG1.AccountId = cuentaSEG1.Id;
		contactoSEG1.Email = 'test@test.com';
		insert contactoSEG1;

        // Crea un Case de prueba
        Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		caso.AccountId = cuentaSEG1.Id;
		caso.ContactId = contactoSEG1.Id;
		caso.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso.SEG_Idioma__c = 'es';
		caso.CC_AcuseRecibo__c = '1';
		caso.Status = 'Activo';
		caso.Subject = 'test 2';
        caso.SEG_N_operaciones_del_caso__c = 0;
        insert caso;

        
    }

    @isTest
    static void testReclamacionesAutomaticas() {

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			Test.startTest();
			SEG_ReclamacionesAutomaticas_Schedulable scheduler = new SEG_ReclamacionesAutomaticas_Schedulable();
			System.schedule('Test Reclamaciones', '0 0 1 1/1 * ? *', scheduler); // Programar el método para que se ejecute una vez
			Test.stopTest();
		}
		
		List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE CronJobDetail.Name = 'Test Reclamaciones'];
        System.assertEquals(1, cronTriggers.size(), 'Debe existir exactamente un trabajo programado para "Test Reclamaciones"');
    }
}