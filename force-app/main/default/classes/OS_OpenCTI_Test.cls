@isTest
public with sharing class OS_OpenCTI_Test {

    @isTest
    public static void registrarLlamadaEntrante() {

        OS_Llamada.Input entrada = new OS_Llamada.Input();
        entrada.usuario = 'u0198991';
        entrada.connId = '01-1600086133.40853';
        entrada.ani = '650399855';
        entrada.dnis = '931221640';
        entrada.casoId = null;
        entrada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entrada.servicio = null;
        entrada.transfDestino = null;
        entrada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entrada);

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }
         
        Test.startTest();
        String output = OS_OpenCTI.registrarLlamadaEntrante(inputJson);
        Test.stopTest();

        system.assert(output != null, 'Comprobamos no hay mensaje de salida.');
    }
    
    @isTest
    public static void registrarLlamadaEntranteConError() {
        
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Account').getRecordTypeId();
        cuenta.Name = 'CUENTA BUZON COPS';
        insert cuenta;
        
        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        contacto.AccountId = cuenta.Id;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }

        OS_Llamada.Input entrada = new OS_Llamada.Input();
        entrada.usuario = 'u0198991';
        entrada.connId = '01-1711086133.40853';
        entrada.ani = '650399855';
        entrada.dnis = '931221640';
        entrada.casoId = null;
        entrada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entrada.servicio = null;
        entrada.transfDestino = null;
        entrada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entrada);

        Test.startTest();
        String output = OS_OpenCTI.registrarLlamadaEntrante(inputJson);
        Test.stopTest();
        
        System.assert(output != null, 'Comprobamos no hay output.');
    }

    @isTest
    public static void registrarLlamadaSaliente() {

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba cambiar cola Procedencia';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

        OS_Llamada.Input entrada = new OS_Llamada.Input();
        entrada.usuario = 'u0198991';
        entrada.connId = '01-1600086133.40853';
        entrada.ani = '650399855';
        entrada.dnis = '931221640';
        entrada.casoId = caso.Id;
        entrada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entrada.servicio = null;
        entrada.transfDestino = null;
        entrada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entrada);

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }

        Test.startTest();
        OS_OpenCTI.registrarLlamadaSaliente(inputJson);
        Test.stopTest();

        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE CC_DNIS__C =:entrada.dnis];
        System.assert(llamada != null, 'Comprobamos se crea la llamada.');

        Task tarea = [SELECT Id FROM Task WHERE WhatId = :caso.Id LIMIT 1];
        System.assert(tarea != null, 'Comprobamos se crea la llamada.');
    }

    @isTest
    public static void finalizarLlamada() {

        OS_Llamada.Input entrada = new OS_Llamada.Input();
        entrada.usuario = 'u0198991';
        entrada.connId = '01-1600086133.40853';
        entrada.ani = '650399855';
        entrada.dnis = '931221640';
        entrada.casoId = null;
        entrada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entrada.servicio = null;
        entrada.transfDestino = null;
        entrada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entrada);

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }

        Test.startTest();
        OS_OpenCTI.finalizarLlamada(inputJson);
        Test.stopTest();

        system.assertEquals(0, [SELECT COUNT() FROM CC_Llamada__c WHERE CC_DNIS__C = :entrada.dnis LIMIT 1], 'Comprobamos no se crea la llamada.');

    }

    @isTest
    public static void obtenerPrefijo() {

        OS_Llamada.Input entrada = new OS_Llamada.Input();
        entrada.usuario = 'u0198991';
        entrada.connId = '01-1600086133.40853';
        entrada.ani = '650399855';
        entrada.dnis = '931221640';
        entrada.casoId = null;
        entrada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entrada.servicio = null;
        entrada.transfDestino = null;
        entrada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entrada);

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }

        Test.startTest();
        String prefijo = OS_OpenCTI.obtenerPrefijo(inputJson);
        Test.stopTest();

        System.assert(prefijo != null, 'Comprobamos tenemos el prefijo.');
    }

    @isTest
    public static void registrarConsulta() {
        //Llamada entrante
        OS_Llamada.Input mensajeRegistrarLlamada = new OS_Llamada.Input();
        mensajeRegistrarLlamada.usuario = 'u0190345';
        mensajeRegistrarLlamada.connId = '01-1600086133.40853';
        mensajeRegistrarLlamada.ani = '666555777';
        mensajeRegistrarLlamada.dnis = '666555445';
        mensajeRegistrarLlamada.casoId = null;
        mensajeRegistrarLlamada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        mensajeRegistrarLlamada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
		//OS_Llamada.openCTI_registrarLlamadaEntrante(mensajeRegistrarLlamada);

        OS_Llamada.Input entradaRegistrarConsulta = new OS_Llamada.Input();
        entradaRegistrarConsulta.usuario = 'u0198991';
        entradaRegistrarConsulta.connId = '01-1600086133.40853';
        entradaRegistrarConsulta.ani = '650399855';
        entradaRegistrarConsulta.dnis = '931221640';
        entradaRegistrarConsulta.casoId = null;
        entradaRegistrarConsulta.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entradaRegistrarConsulta.servicio = null;
        entradaRegistrarConsulta.transfDestino = null;
        entradaRegistrarConsulta.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entradaRegistrarConsulta);

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }

        Test.startTest();
        String output = OS_OpenCTI.registrarConsulta(inputJson);
        Test.stopTest();

        System.assert(output != null, 'Comprobamos se crea el mensaje de salida.');
    }

    @isTest
    public static void finalizarConsulta() {

        OS_Llamada.Input entrada = new OS_Llamada.Input();
        entrada.usuario = 'u0198991';
        entrada.connId = '01-1600086133.40853';
        entrada.ani = '650399855';
        entrada.dnis = '931221640';
        entrada.casoId = null;
        entrada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entrada.servicio = null;
        entrada.transfDestino = null;
        entrada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entrada);

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }

        Test.startTest();
        String output = OS_OpenCTI.finalizarConsulta(inputJson);
        Test.stopTest();

        System.assert(output != null, 'Comprobamos se crea el mensaje de salida.');
    }
    
    @isTest
    public static void transferirLlamada() {

        OS_Llamada.Input entrada = new OS_Llamada.Input();
        entrada.usuario = 'u0198991';
        entrada.connId = '01-1777086133.40853';
        entrada.ani = '650399855';
        entrada.dnis = '931221640';
        entrada.casoId = null;
        entrada.nombreFicheroGrabacion = 'nombreFichero.mp3';
        entrada.servicio = null;
        entrada.transfDestino = '';
        entrada.multiParametros = 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro';
        String inputJson = JSON.serialize(entrada);

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert contacto;
        }

        Test.startTest();
        OS_OpenCTI.transferirLlamada(inputJson);
        Test.stopTest();

        system.assertEquals(0, [SELECT COUNT() FROM CC_Llamada__c WHERE CC_DNIS__C =:entrada.dnis], 'Comprobamos no se crea la llamada.');
    }
}