@isTest
public with sharing class SACH_Llamada_Test {

    @TestSetup
    public static void testSetup() {
        CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c ();
        servicioGenesys.Name = 'Servicio SACH Test';
        servicioGenesys.CC_Codigo__c = 'SACH_PRUEBAS';
        servicioGenesys.CC_Tipo__c = 'Servicio';
        servicioGenesys.CC_Tipo_Cliente__c = 'Cliente';
        servicioGenesys.CBK_Negocio__c = 'SACH';
        servicioGenesys.CC_VDN__c = '1332';
        servicioGenesys.RecordTypeId = Schema.getGlobalDescribe().get('CC_Servicio_Genesys__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
        insert servicioGenesys;
    }

    @isTest
    public static void registrarLlamadaEntranteTest() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '1218';
        input.extension = '1118';
        input.connId = '12345678';
        input.ani = '666666666';
        input.dnis = '666666666';
        input.servicio = 'SACH_PRUEBAS';
        input.asunto = 'Asunto llamada';
        input.numPerso = '432423';
        input.idioma = 'Castellano';
        input.datos = 'Datos';
        //input.casoId = 
        //input.salesforceParentId = 

        Case caso =  SACH_Llamada.registrarLlamadaEntrante(input);
        CC_Llamada__c llamada = new CC_Llamada__c();
        List<Task> tarea = [SELECT Id, CC_Llamada_Id__c FROM Task 
                                WHERE WhatId = :caso.Id AND CC_Llamada_Id__c != null AND RecordType.DeveloperName = 'SACH_Task' AND Status = 'Open' 
                                ORDER BY CreatedDate DESC LIMIT 1];
        if(!tarea.isEmpty()) {
            llamada = [SELECT Id FROM CC_Llamada__c WHERE Id =: tarea[0].CC_Llamada_Id__c];              
        }
        System.assertEquals(llamada != null, true, 'No se ha regitrado la llamada');
    }
    
    @isTest
    public static void registrarLlamadaSalienteTest() {

        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso.Status = 'Activo';
        insert caso;

        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '1218';
        input.extension = '1118';
        input.connId = '12345678';
        input.ani = '666666666';
        input.dnis = '666666666';
        input.servicio = 'SACH_PRUEBAS';
        input.asunto = 'Asunto llamada';
        input.numPerso = '432423';
        input.idioma = 'Castellano';
        input.datos = 'Datos';
        input.casoId = caso.Id;
        //input.salesforceParentId = 
        //input.llamadaId = '4323242';
        CC_Llamada__c llamada = SACH_Llamada.registrarLlamadaSaliente(input);

        CC_Llamada_Input input2 = new CC_Llamada_Input();
        input2.usuario = '1218';
        input2.extension = '1118';
        input2.connId = '12345678';
        input2.ani = '666666666';
        input2.dnis = '666666666';
        input2.servicio = 'SACH_PRUEBAS';
        input2.asunto = 'Asunto llamada';
        input2.numPerso = '432423';
        input2.idioma = 'Castellano';
        input2.datos = 'Datos';
        input2.casoId = caso.Id;
        //input.salesforceParentId = 
        input2.llamadaId = llamada.Id;

        Task actividad = new Task();

        actividad.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        actividad.CC_Llamada_Id__c = llamada.Id;
        actividad.Status = 'Open';

        insert actividad;

        CC_Llamada__c llamadaSaliente = SACH_Llamada.registrarLlamadaSaliente(input2);

        System.assertEquals(llamadaSaliente != null, true, 'No se ha regitrado la llamada saliente');
    }
    
    @isTest
    public static void finalizarLlamadaTest() {

        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso.Status = 'Activo';
        insert caso;

        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '1218';
        input.extension = '1118';
        input.connId = '12345678';
        input.ani = '666666666';
        input.dnis = '666666666';
        input.servicio = 'SACH_PRUEBAS';
        input.asunto = 'Asunto llamada';
        input.numPerso = '432423';
        input.idioma = 'Castellano';
        input.datos = 'Datos';
        input.casoId = caso.Id;
        //input.salesforceParentId = 
        //input.llamadaId = '4323242';
        CC_Llamada__c llamada = SACH_Llamada.registrarLlamadaSaliente(input);

        CC_Llamada_Input input2 = new CC_Llamada_Input();
        input2.usuario = '1218';
        input2.extension = '1118';
        input2.connId = '12345678';
        input2.ani = '666666666';
        input2.dnis = '666666666';
        input2.servicio = 'SACH_PRUEBAS';
        input2.asunto = 'Asunto llamada';
        input2.numPerso = '432423';
        input2.idioma = 'Castellano';
        input2.datos = 'Datos';
        input2.casoId = caso.Id;
        //input.salesforceParentId = 
        input2.llamadaId = llamada.Id;

        Task actividad = new Task();

        actividad.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        actividad.CC_Llamada_Id__c = llamada.Id;
        actividad.Status = 'Open';

        insert actividad;

        SACH_Llamada.finalizarLlamada(input2, 'Llamada finalizada');

        Task actividadFinal = [SELECT id, Status FROM Task LIMIT 1];

        System.assertEquals(actividadFinal.Status, 'Completed', 'No se ha modificado la actividad');
    }
}