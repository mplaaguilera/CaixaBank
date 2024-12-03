@isTest
public class OS_WS_AltaCasoValija_Queueable_Test {

    @TestSetup
    static void cargaDeDatos(){
        User operador = OS_Usuarios.usuarioOperador();

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        }

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto01';
        contacto.LastName = 'Contacto01';
        contacto.CC_NumPerso__c = '25345561';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'correo@prueba.com';
        insert contacto;

        CC_MCC__c tematica = new CC_MCC__c();
		tematica.Name = 'tematica cops test';
        tematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        tematica.CC_Fecha_Vigencia_Inicio__c = System.now();
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Tematica');
        tematica.CC_Codigo_Externo__c = 'TEC-000001';
        tematica.OS_Departamento__c = 'UAC';
        tematica.OS_Horario__C= businessHoursId;
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'producto cops test';
        producto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto.CC_Fecha_Vigencia_Inicio__c = System.now();
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert producto;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'motivo cops test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = System.now();
        motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Motivo');
        motivo.CC_Tematica__c = tematica.Id;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject = 'Caso OS_AltaCasoValija_Test';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
    }

    @isTest 
    static void testAltaCasoValijaQueueable() {
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();
        
        // Preparar los datos para el envío del correo electrónico
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_AltaCasoValija_Test'];
        caso.OwnerId = usuarioAdmin.Id;
        caso.Status = 'Pendiente Cliente';
        update caso;

        
        
        Map<String, Integer> reintentos = new Map<String, Integer>();
        //Id idMapa = '111';
        reintentos.put('17022230022032000005', 0);

        
        OS_WS_AltaCasoValija.Input input = new OS_WS_AltaCasoValija.Input();
        OS_WS_AltaCasoValija.Input inputMock = OS_WS_AltaCasoValija.generarMockCOPS(input);
        // Crear el WrapperValoresEmail
        OS_WS_AltaCasoValija.WrapperValores parametrosJob = new OS_WS_AltaCasoValija.WrapperValores();
        parametrosJob.input = inputMock;
        parametrosJob.reintentosMap = reintentos;
        
        
        OS_WS_AltaCasoValija_Queueable queueableValija = new OS_WS_AltaCasoValija_Queueable(parametrosJob);

        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
        .addId(caso.Id)
        
        .addString('testValija')
        
        .build(); 
        Id id;
        Test.startTest();
            System.runAs(usuarioAdmin){
                try {
                    id= System.enqueueJob(queueableValija, options);
                } catch (DuplicateMessageException ex) {
                    //Exception is thrown if there is already an enqueued job with the same signature
                    CBK_Log.error(ex);
                }
        }
        
        Test.stopTest();
        //Case c = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        List<AsyncApexJob> jobs=[SELECT Id , Status FROM AsyncApexJob WHERE Id=:id];
        System.assertNotEquals(true, jobs.isEmpty());
        //System.assertEquals(1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id]);
    }
}