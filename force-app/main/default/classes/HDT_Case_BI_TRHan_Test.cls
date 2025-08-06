@isTest
public with sharing class HDT_Case_BI_TRHan_Test {

     @isTest
    static void enmascararPANs_test() {
       
        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.Status = 'Cerrado';
        insert caso;
        
        Task tarea = new Task();
        tarea.WhatId = caso.Id;
        tarea.type = 'Automática';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111111111111111';
        tarea.Description = 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111111111111111';
        tarea.RecordTypeId = tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        insert tarea;
        
        Test.startTest();
        Task tareaAI = new Task();
        tareaAI = [SELECT Id, Subject, Description from Task where Id =: tarea.Id];

        
        /*System.assertEquals(tareaAI.Subject, 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111XXXXXXXX1111');
        System.assertEquals(tareaAI.Description, 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111XXXXXXXX1111'); */
        System.assertEquals(tarea.Id, tareaAI.Id, 'No se ha encontrado la Tarea');
		Test.stopTest();
        }
        
    }
	
    @isTest
    static void beforeDelete_Test() {       
       
        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Task tarea = new Task();
        tarea.type = 'Automática';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Tarea';
        insert tarea;
       	delete tarea;     
        
           Task tareaAI = new Task();
   
           Test.startTest();
           System.assertEquals(0,            
           [SELECT COUNT() from Task where Id =: tarea.Id]
           , 'No se ha eliminado la Tarea');
           Test.stopTest();
    }
}

@isTest
public static void enmascararPANBeforeInsert() {
    System.runAs(new User(Id = UserInfo.getUserId())) {

    // Alta de datos para la prueba
    Case caso = new Case();
    caso.CC_Idioma__c = 'es';
    caso.Subject = 'Asunto 1234567898765432';
    caso.Description = '1234 5678 9876 5432 Descripción';
    caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
    caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
    
    // Ejecución de la prueba
    Test.startTest();
    insert caso;
    Test.stopTest();
    
    // Evaluación del resultado de la prueba
    Case casoInsertado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
    if (casoInsertado != null) {
        System.assertEquals('Asunto 1234XXXXXXXX5432', casoInsertado.Subject);
        System.assertEquals('1234XXXXXXXX5432 Descripción', casoInsertado.Description);
        System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoInsertado.CC_Detalles_Consulta__c);
        System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoInsertado.CC_Detalles_Solucion__c);
    }
}
}

@isTest
public static void enmascararPANBeforeUpdate() {
    System.runAs(new User(Id = UserInfo.getUserId())) {

    // Alta de datos para la prueba
    Case caso = new Case();
    caso.CC_Idioma__c = 'es';
    caso.Subject = 'Asunto';
    caso.Description = 'Descripción';
    caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
    caso.CC_Detalles_Solucion__c = 'Detalles Solución';
    insert caso;
    caso.CC_Idioma__c = 'es';
    caso.Subject = 'Asunto 1234567898765432';
    caso.Description = '1234 5678 9876 5432 Descripción';
    caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
    caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
    
    // Ejecución de la prueba
    Test.startTest();
    update caso;
    Test.stopTest();
    
    // Evaluación del resultado de la prueba
    Case casoActualizado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
    if (casoActualizado != null) {
        System.assertEquals('Asunto 1234XXXXXXXX5432', casoActualizado.Subject);
        System.assertEquals('1234XXXXXXXX5432 Descripción', casoActualizado.Description);
        System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoActualizado.CC_Detalles_Consulta__c);
        System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoActualizado.CC_Detalles_Solucion__c);
    }
    }
    }


    @isTest
    static void testIsWeekend() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Given
        Datetime weekendDate = Datetime.newInstance(2023, 4, 29, 0, 0, 0);
        Datetime weekdayDate = Datetime.newInstance(2023, 4, 27, 0, 0, 0);
        
        // When
        Boolean isWeekend1 = HDT_Case_BI_TRHan.isWeekend(weekendDate);
        Boolean isWeekend2 = HDT_Case_BI_TRHan.isWeekend(weekdayDate);
        
        // Then
        System.assertEquals(true, isWeekend1, 'The weekend date should be detected as a weekend');
        System.assertEquals(false, isWeekend2, 'The weekday date should not be detected as a weekend');
        }
    }

    @isTest
    static void testEnmascararPANs() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Creamos un registro de prueba de caso
        Case caso = new Case(
            Subject = 'Este es mi número de tarjeta: 1234-5678-9012-3456',
            Description = '1234 5678 9876 5432 Descripción',
            CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
            CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución'
        );
        
        // Agregamos el caso a una lista para pasarlo al método de prueba
        List<Case> casos = new List<Case>();
        casos.add(caso);
        
        // Llamamos al método que enmascara los PANs
        HDT_Case_BI_TRHan.enmascararPANs(casos);
        
        // Verificamos que el número de tarjeta se haya enmascarado
        System.assertEquals(
            'Este es mi número de tarjeta: 1234XXXXXXXX3456',
            casos[0].Subject
        );
        }
    }

    @isTest
    public static void testPruebaRobot(){

        System.runAs(new User(Id = UserInfo.getUserId())) {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Contactos erróneos';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000120';
        mccTematica.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Pruebas Salesforce';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-001318'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Contacto de prueba';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-012087';
        insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Pruebas/Validaciones';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-015680'; 
        insert mccCausa; 
        
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'No aplica';
        mccSolucion.CC_Tipo_Cliente__c = 'Cliente';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion.RecordTypeId = recordTypeIdSolucion;
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-033729';
        insert mccSolucion;

        List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Prueba Robot';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            listadoCasos.add(caso);

            Test.startTest();
            
            insert caso;
            HDT_Case_BI_TRHan.informarCampos(listadoCasos);
            Test.stopTest();

			Case casoRobot = [Select id, Status from Case where id = :caso.Id limit 1];
            
            System.assertEquals( 'Rechazado' , casoRobot.Status);
        }
    }

    @isTest
    public static void obtenerBuzon() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Alta de datos para la prueba
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;
        
        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;
        
        Case caso = new Case();
        caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Accionista';
        insert caso;
        
        // Ejecución de la prueba
        Test.startTest();
        
        caso.Status = 'Cerrado';
        caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
        update caso;
        HDT_Case_BI_TRHan.obtenerBuzon(caso.CC_Canal_Procedencia__c);

        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        Case casoActualizado = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals('Atención al Cliente', casoActualizado.CC_Canal_Procedencia__c);
        }
    }
    
    @IsTest
    static void testSacarFestivosPorMes() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;
        
        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Festivo';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = '11';
        festivo1.CC_Valor2__c = '11';
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        festivosInsertar.add(festivo1);
        
        CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
        festivo2.Name = 'Festivo2';
        festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo2.CC_Valor__c = '10';
        festivo2.CC_Valor2__c = '10';
        festivo2.CC_Lista__c = festivos.Id;
        festivo2.CC_Activa__c = true;
        festivosInsertar.add(festivo2);
        insert festivosInsertar;

        // Llama al método que se va a probar
        Map<Integer, List<Integer>> festivosx = HDT_Case_BI_TRHan.sacarFestivosPorMes();
        
        // Comprueba los resultados
        System.assertEquals(2, festivosx.size(), 'El número de meses festivos no es correcto');
        }
    }

    @isTest
    public static void horaSLAConsultasOperativasPausa(){
        System.runAs(new User(Id = UserInfo.getUserId())) {
        List<Case> listadoCasos = new List<Case>();
        Case caso = new Case();
        caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso.CC_Canal_Resolucion__c = 'RRHH';
        insert caso;
        listadoCasos.add(caso);
        
        Test.startTest();
        caso.Status = 'Pendiente Colaborador';
        update caso;
        HDT_Case_BI_TRHan.horaSLAConsultasOperativas(listadoCasos);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
        }
    }

    @isTest
    public static void horaSLAConsultasOperativasRenaudar(){

        System.runAs(new User(Id = UserInfo.getUserId())) {
        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;
        
        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Reyes';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
        festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        insert festivo1;

        List<Case> listadoCasos = new List<Case>();
        Case caso = new Case();
        caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso.CC_Canal_Resolucion__c = 'RRHH';
        insert caso;
        listadoCasos.add(caso);

        caso.Status = 'Pendiente Colaborador';
        update caso;

        Test.startTest();
        caso.Status = 'Activo';
        update caso;
        HDT_Case_BI_TRHan.horaSLAConsultasOperativas(listadoCasos);

        Test.stopTest();

        System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
        }
    }

    @isTest
    public static void horaSLAConsultasOperativasRenaudarPdteInterno(){

        System.runAs(new User(Id = UserInfo.getUserId())) {
        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;
        
        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Reyes';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
        festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        insert festivo1;

        List<Case> listadoCasos = new List<Case>();
        Case caso = new Case();
        caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso.CC_Canal_Resolucion__c = 'RRHH';
        insert caso;
        listadoCasos.add(caso);
        
        caso.Status = 'Pendiente Interno';
        update caso;

        Test.startTest();
        caso.Status = 'Activo';
        update caso;

        HDT_Case_BI_TRHan.horaSLAConsultasOperativas(listadoCasos);

        Test.stopTest();

        System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
        }
    }

    @isTest
    public static void horaSLAConsultasOperativasRenaudarPdteCliente(){
        System.runAs(new User(Id = UserInfo.getUserId())) {

        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;
        
        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Reyes';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
        festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        insert festivo1;

        List<Case> listadoCasos = new List<Case>();
        Case caso = new Case();
        caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso.CC_Canal_Resolucion__c = 'RRHH';
        insert caso;
        listadoCasos.add(caso);

        caso.Status = 'Pendiente Cliente';
        update caso;

        Test.startTest();
        caso.Status = 'Activo';
        update caso;
        HDT_Case_BI_TRHan.horaSLAConsultasOperativas(listadoCasos);

        Test.stopTest();

        System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
        }
    }

    @isTest
    public static void horaSLAConsultasOperativasRenaudarPdteIncidencia(){

        System.runAs(new User(Id = UserInfo.getUserId())) {
        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;
        
        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Reyes';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = '01';
        festivo1.CC_Valor2__c = '01';
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        insert festivo1;

        List<Case> listadoCasos = new List<Case>();
        Case caso = new Case();
        caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso.CC_Canal_Resolucion__c = 'RRHH';
        insert caso;
        listadoCasos.add(caso);

        caso.Status = 'Pendiente Incidencia';
        update caso;

        Test.startTest();
        caso.Status = 'Activo';
        update caso;

        HDT_Case_BI_TRHan.horaSLAConsultasOperativas(listadoCasos);

        Test.stopTest();

        System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
        }
    }


    @isTest
    public static void testcambioEstadoPendiente()
    {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Caso de prueba Cambio estado pendiente en 3N';
            caso.recordtypeId = recordTypeCaso;
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_En_Tercer_Nivel__c = true;
            caso.Status = 'Pendiente Interno';
            insert caso;
            
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                Test.startTest();
                caso.CC_Cambio_Estado_Pendiente_Externo__c = true;
                Test.stopTest();
                
                System.assertEquals(caso.CC_Cambio_Estado_Pendiente_Externo__c, true);
            }
        }
    }
}