@isTest
public class SEG_Contratos_AI_TRHan_Test {

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

        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        insert contrato1;
    }

    @isTest
    static void testMainEntry() {
        // Crea datos de prueba 
        List<SEG_Contratos__c> newRecords = new List<SEG_Contratos__c>();
        List<SEG_Contratos__c> oldRecords = new List<SEG_Contratos__c>();
        Map<Id, SEG_Contratos__c> recordsMap = new Map<Id, SEG_Contratos__c>();

        // Inserta registros de prueba en newList y recordsMap
        SEG_Contratos__c contract1 = [SELECT Id, SEG_SR_Seguimiento__c, SEG_NombreCliente__c FROM SEG_Contratos__c WHERE Name = 'Number1'];
        newRecords.add(contract1);
        recordsMap.put(contract1.Id, contract1);

        // Inicializa los parámetros de la clase de manejo de desencadenadores 
        CC_TriggerParameters tp = new CC_TriggerParameters();
        tp.newList = newRecords;

        // Crea una instancia de la clase a probar
        SEG_Contratos_BU_TRHan triggerHandler = new SEG_Contratos_BU_TRHan();

        // Ejecuta el método mainEntry de la clase (la clase a probar)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            triggerHandler.mainEntry(tp);
            Test.stopTest();
        }

        // Verificar que la lista newList se actualice correctamente después de la ejecución del método
        SEG_Contratos__c contratoActualizado = [SELECT Id, SEG_Estado__c FROM SEG_Contratos__c WHERE Name = 'Number1'];
        System.assertEquals('No firmado', contratoActualizado.SEG_Estado__c, 'El campo SEG_Estado__c no se actualizó correctamente en el primer registro de newList');  
    }
}