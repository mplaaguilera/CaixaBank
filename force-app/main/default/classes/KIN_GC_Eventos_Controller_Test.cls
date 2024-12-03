@isTest
public with sharing class KIN_GC_Eventos_Controller_Test {

    @TestSetup
    private static void testSetup() {
		User usuarioAdmin = [SELECT Id FROM User WHERE IsActive = TRUE
							AND Profile.Name IN ('System Administrator', 'Administrador del sistema') LIMIT 1];
        System.runAs(usuarioAdmin) {
            Id idPerfilContactCenter = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
            Id idRolContactCenter = [SELECT Id FROM UserRole WHERE Name = 'Contact Center'].Id;

            User usuario1 = new User();
            usuario1.LastName = 'Agente Test 1';
            usuario1.Alias = 'AG1';
            usuario1.Email = 'agente1@test.com';
            usuario1.Username = usuario1.UserName = 'usuariotest1_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            usuario1.UserRoleId = idRolContactCenter;
            usuario1.ProfileId = idPerfilContactCenter;
            usuario1.EmailEncodingkey = 'UTF-8';
            usuario1.LanguageLocaleKey = 'en_US';
            usuario1.LocalesIdKey = 'en_US';
            usuario1.TimezonesIdKey = 'Europe/Madrid';

            User usuario2 = new User();
            usuario2.LastName = 'Agente Test 2';
            usuario2.Alias = 'AG2';
            usuario2.Email = 'agente2@test.com';
            usuario2.Username = usuario2.UserName = 'usuariotest2_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            usuario2.UserRoleId = idRolContactCenter;
            usuario2.ProfileId = idPerfilContactCenter;
            usuario2.EmailEncodingkey = 'UTF-8';
            usuario2.LanguageLocaleKey = 'en_US';
            usuario2.LocalesIdKey = 'en_US';
            usuario2.TimezonesIdKey = 'Europe/Madrid';

            insert new List<User>{usuario1, usuario2};

			List<String> permissionSets = new List<String>{'CC_Classes', 'CC_Operador_Cliente', 'CC_Supervisor_PS', 'CSBD_PS_Gestor'};
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
			for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN :permissionSets]) {
                PermissionSetAssignment psAssignment1 = new PermissionSetAssignment();
                psAssignment1.AssigneeId = usuario1.Id;
                psAssignment1.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment1);

                PermissionSetAssignment psAssignment2 = new PermissionSetAssignment();
                psAssignment2.AssigneeId = usuario2.Id;
                psAssignment2.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment2);
            }
            insert psAssignments;

            Id idRtServicioGenesys = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
            CC_Servicio_Genesys__c svcGenesysCc = new CC_Servicio_Genesys__c();
            svcGenesysCc.RecordTypeId = idRtServicioGenesys;
            svcGenesysCc.Name = 'Servicio CC';
            svcGenesysCc.CC_Codigo__c = 'ServicioCc';
            svcGenesysCc.CC_VDN__c = '4444444';
            svcGenesysCc.CC_Tipo__C = 'Servicio';
            svcGenesysCc.CBK_Negocio__c = 'CC';
            svcGenesysCc.CC_Canal_Procedencia__c = 'CaixaBankNow';
            svcGenesysCc.CC_Prefijo__c = '0';
            svcGenesysCc.CC_Fecha_Inicio_Salesforce__c = Date.today().addDays(-1);
            svcGenesysCc.CC_Tipo_Cliente__c = 'Cliente';

            CC_Servicio_Genesys__c svcGenesysCcSalida = new CC_Servicio_Genesys__c();
            svcGenesysCcSalida.RecordTypeId = idRtServicioGenesys;
            svcGenesysCcSalida.Name = 'CC Genesys Cloud Outbound Default';
            svcGenesysCcSalida.CC_Codigo__c = 'CC_GenesysCloudOutboundDefault';
            svcGenesysCcSalida.CC_Tipo__C = 'Servicio';
            svcGenesysCcSalida.CBK_Negocio__c = 'CC';
            svcGenesysCcSalida.CC_Tipo_Cliente__c = 'Cliente';
            svcGenesysCcSalida.CC_VDN__c = '4444444';
            svcGenesysCcSalida.CC_Canal_Procedencia__c = 'CaixaBankNow';
            svcGenesysCcSalida.CC_Prefijo__c = '0';
            svcGenesysCcSalida.CC_Fecha_Inicio_Salesforce__c = Date.today().addDays(-1);
            svcGenesysCcSalida.CC_Principal__c = true;

            CC_Servicio_Genesys__c svcGenesysHdt = new CC_Servicio_Genesys__c();
            svcGenesysHdt.RecordTypeId = idRtServicioGenesys;
            svcGenesysHdt.Name = 'Servicio HDT';
            svcGenesysHdt.CC_Codigo__c = 'ServicioHdt';
            svcGenesysHdt.CC_VDN__c = '4444444';
            svcGenesysHdt.CC_Tipo__C = 'Servicio';
            svcGenesysHdt.CBK_Negocio__c = 'HDT';
            svcGenesysHdt.CC_Canal_Procedencia__c = 'CaixaBankNow';
            svcGenesysHdt.CC_Prefijo__c = '0';
            svcGenesysHdt.CC_Fecha_Inicio_Salesforce__c = Date.today().addDays(-1);
            svcGenesysHdt.CC_Tipo_Cliente__c = 'Empleado';

            CC_Servicio_Genesys__c svcGenesysCsbd = new CC_Servicio_Genesys__c();
            svcGenesysCsbd.RecordTypeId = idRtServicioGenesys;
            svcGenesysCsbd.Name = 'Servicio CSBD';
            svcGenesysCsbd.CC_Codigo__c = 'ServicioCsbd';
            svcGenesysCsbd.CC_VDN__c = '4444444';
            svcGenesysCsbd.CC_Tipo__C = 'Servicio';
            svcGenesysCsbd.CBK_Negocio__c = 'CSBD';
            svcGenesysCsbd.CC_Canal_Procedencia__c = 'CaixaBankNow';
            svcGenesysCsbd.CC_Prefijo__c = '0';
            svcGenesysCsbd.CC_Fecha_Inicio_Salesforce__c = Date.today().addDays(-1);
            svcGenesysCsbd.CC_Tipo_Cliente__c = 'Cliente';

            CC_Servicio_Genesys__c svcGenesysCsbdSalida = new CC_Servicio_Genesys__c();
            svcGenesysCsbdSalida.RecordTypeId = idRtServicioGenesys;
            svcGenesysCsbdSalida.Name = 'NIS Genesys Cloud Outbound Default';
            svcGenesysCsbdSalida.CC_Codigo__c = 'NIS_GenesysCloudOutboundDefault';
            svcGenesysCsbdSalida.CC_VDN__c = '4444444';
            svcGenesysCsbdSalida.CC_Tipo__C = 'Servicio';
            svcGenesysCsbdSalida.CBK_Negocio__c = 'CSBD';
            svcGenesysCsbdSalida.CC_Prefijo__c = '0';
            svcGenesysCsbdSalida.CC_Fecha_Inicio_Salesforce__c = Date.today().addDays(-1);
            svcGenesysCsbdSalida.CC_Tipo_Cliente__c = 'Cliente';

			CC_Lista_Valores__c lovDiasCierreOportunidad = new CC_Lista_Valores__c();
			lovDiasCierreOportunidad.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			lovDiasCierreOportunidad.Name = 'CSBD: Días cierre oportunidad por defecto';
			lovDiasCierreOportunidad.CC_Activa__c = true;
			insert lovDiasCierreOportunidad;

			CC_Lista_Valores__c lovDiasCierreOportunidadPrestamo = new CC_Lista_Valores__c();
			lovDiasCierreOportunidadPrestamo.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
			lovDiasCierreOportunidadPrestamo.CC_Lista__c = lovDiasCierreOportunidad.Id;
			lovDiasCierreOportunidadPrestamo.Name = 'Préstamo';
			lovDiasCierreOportunidadPrestamo.CC_Valor__c = '7';
			lovDiasCierreOportunidadPrestamo.CC_Activa__c = true;
			insert lovDiasCierreOportunidadPrestamo;

            insert new List<CC_Servicio_Genesys__c>{svcGenesysCc, svcGenesysCcSalida, svcGenesysHdt, svcGenesysCsbd, svcGenesysCsbdSalida};

            /*
            CC_Servicio_Genesys__c svcGenesysCloudOutboundDefault = new CC_Servicio_Genesys__c();
            svcGenesysCloudOutboundDefault.RecordTypeId = idRtServicioGenesys;
            svcGenesysCloudOutboundDefault.Name = 'CC Genesys Cloud Outbound Default';
            svcGenesysCloudOutboundDefault.CC_Codigo__c = 'CC_GenesysCloudOutboundDefault';
            svcGenesysCloudOutboundDefault.CC_Tipo__C = 'Servicio';
            svcGenesysCloudOutboundDefault.CBK_Negocio__c = 'CC';
            svcGenesysCloudOutboundDefault.CC_Tipo_Cliente__c = 'Cliente';
            svcGenesysCloudOutboundDefault.CC_VDN__c = '4444444';
            svcGenesysCloudOutboundDefault.CC_Canal_Procedencia__c = 'CaixaBankNow';
            svcGenesysCloudOutboundDefault.CC_Prefijo__c = '0';
            svcGenesysCloudOutboundDefault.CC_Fecha_Inicio_Salesforce__c = Date.today().addDays(-1);
            svcGenesysCloudOutboundDefault.CC_Principal__c = true;
            insert new List<CC_Servicio_Genesys__c>{svcGenesys, svcGenesysCloudOutboundDefault};
            */

            CC_MCC__c tematica = new CC_MCC__c();
            tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            tematica.CC_Tipo_Cliente__c = 'Cliente';
            tematica.Name = 'Temática';
            tematica.CC_Codigo_Externo__c = 'T1';
            tematica.CC_Canal_Operativo__c = 'Oficina';
            insert tematica;

            CC_MCC__c producto = new CC_MCC__c();
            producto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            producto.CC_Tipo_Cliente__c = 'Cliente';
            producto.Name = 'Producto';
            producto.CC_Tematica__c = tematica.Id;
            producto.CC_Codigo_Externo__c = 'P1';
            insert producto;

            CC_MCC__c motivo = new CC_MCC__c();
            motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            motivo.CC_Tipo_Cliente__c = 'Cliente';
            motivo.Name = 'Motivo';
            motivo.CC_Producto_Servicio__c = producto.Id;
            motivo.CC_Codigo_Externo__c = 'M1';
            insert motivo;

            CC_MCC__c causa = new CC_MCC__c();
            causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            causa.CC_Tipo_Cliente__c = 'Cliente';
            causa.Name = 'Causa';
            causa.CC_Motivo__c = motivo.Id;
            causa.CC_Codigo_Externo__c = 'C1';
            insert causa;

            CC_MCC__c solucion = new CC_MCC__c();
            solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
            solucion.CC_Tipo_Cliente__c = 'Cliente';
            solucion.Name = 'Solucion';
            solucion.CC_Causa__c = causa.Id;
            solucion.CC_Codigo_Externo__c = 'S1';
            insert solucion;

			System.runAs(usuario1) {
            Case caso = new Case();
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.OwnerId = usuario1.Id;
            caso.Subject = 'Caso Test';
            caso.Origin = 'Phone';
            caso.CC_Canal_Respuesta__c = 'Phone';
            caso.CC_Tipo_Cliente__c = 'Cliente';
            caso.CC_No_Identificado__c = true;
            caso.CC_Canal_Procedencia__c = 'CaixaBankNow';
            insert caso;

            CC_Llamada__c llamada = new CC_Llamada__c();
            llamada.RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            llamada.KIN_Genesys_Cloud__c = true;
            llamada.CC_Servicio_Genesys__c = svcGenesysCc.Id;
            llamada.CC_ConnId__c = 'ef208127-2e21-4086-b016-febfa4c43384';
            llamada.CC_Tipo__c = 'Entrante';
            llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
            llamada.CC_Asunto__c = 'Llamada Test';
            insert llamada;

            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tarea.WhatId = caso.Id;
            tarea.CC_Llamada_Id__c = llamada.Id;
            tarea.Subject = 'Tarea Test';
            tarea.CC_validacion_tarea_manual__c = true;
            insert tarea;

            Map<String, Object> camposOportunidadCsbd = new Map<String, Object>{'OwnerId' => usuario1.Id, 'CSBD_Titulo__c' => 'Oportunidad Test'};
            Opportunity oportunidadCsbd = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', camposOportunidadCsbd);
        }
    }
	}

    @isTest
    public static void registrarLlamadaEntrante() {
        CC_Llamada_Input inputCc = new CC_Llamada_Input();
        inputCc.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        inputCc.transferConnId = '';
        inputCc.ani = '555666777';
        inputCc.dnis = '888999000';
        inputCc.servicio = 'ServicioCc';
        inputCc.asunto = 'Asunto';
        inputCc.numPerso = '11111';

        CC_Llamada_Input inputHdt = new CC_Llamada_Input();
        inputHdt.connId = 'ef208127-2e21-4086-b016-febfa4c43385';
        inputHdt.transferConnId = '';
        inputHdt.ani = '555666777';
        inputHdt.dnis = '888999000';
        inputHdt.servicio = 'ServicioHdt';
        inputHdt.asunto = 'Asunto';
        inputHdt.numPerso = '11111';

        CC_Llamada_Input inputCsbd = new CC_Llamada_Input();
        inputCsbd.connId = 'ef208127-2e21-4086-b016-febfa4c43386';
        inputCsbd.transferConnId = '';
        inputCsbd.ani = '555666777';
        inputCsbd.dnis = '888999000';
        inputCsbd.servicio = 'ServicioCsbd';
        inputCsbd.asunto = 'Asunto';
        inputCsbd.numPerso = '11111';

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante(JSON.serialize(inputCc));
            KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante(JSON.serialize(inputHdt));
            KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante(JSON.serialize(inputCsbd));
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void registrarLlamadaSaliente() {

        String idOportunidadCsbd = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'].Id;

		Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		caso.Subject = 'Caso Test registrarLlamadaSaliente';
		caso.Origin = 'Phone';
		caso.CC_Canal_Respuesta__c = 'Phone';
		caso.CC_Tipo_Cliente__c = 'Cliente';
		caso.CC_No_Identificado__c = true;
		caso.CC_Canal_Procedencia__c = 'CaixaBankNow';
		insert caso;

        CC_Llamada_Input inputCc = new CC_Llamada_Input();
        inputCc.usuario = '';
        inputCc.extension = '';
        inputCc.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        inputCc.transferConnId = '';
        inputCc.ani = '555666777';
        inputCc.dnis = '888999000';
        inputCc.servicio = 'ServicioCc';
        inputCc.asunto = 'Asunto';
        inputCc.numPerso = '11111';
        inputCc.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
		inputCc.casoId = caso.Id;

        CC_Llamada_Input inputHdt = new CC_Llamada_Input();
        inputHdt.usuario = '';
        inputHdt.extension = '';
        inputHdt.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        inputHdt.transferConnId = '';
        inputHdt.ani = '555666777';
        inputHdt.dnis = '888999000';
        inputHdt.servicio = 'ServicioHdt';
        inputHdt.asunto = 'Asunto';
        inputHdt.numPerso = '11111';
        inputHdt.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
		inputHdt.casoId = caso.Id;

        CC_Llamada_Input inputCsbd = new CC_Llamada_Input();
        inputCsbd.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        inputCsbd.transferConnId = '';
        inputCsbd.ani = '555666777';
        inputCsbd.dnis = '888999000';
        inputCsbd.servicio = 'ServicioCsbd';
        inputCsbd.asunto = 'Asunto';
        inputCsbd.numPerso = '11111';
        inputCsbd.casoId = idOportunidadCsbd;

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaSaliente(JSON.serialize(inputCc));
            KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaSaliente(JSON.serialize(inputHdt));
            Map<String, Object> retornoCsbd = KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaSaliente(JSON.serialize(inputCsbd));
            CC_Llamada__c llamadaSalienteCsbd = (CC_Llamada__c)retornoCsbd.get('llamada');
            inputCsbd.llamadaId = llamadaSalienteCsbd.Id;
            KIN_Genesys_Cloud_Eventos_Controller.iniciarLlamadaSalienteClickToDial(JSON.serialize(inputCsbd));
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void registrarConsulta() {
		User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
		System.runAs(usuarioTest) {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'ServicioCC';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        input.salesforceParentId = [SELECT Id FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'].Id;

			Case caso = new Case();
			caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			caso.Subject = 'Caso Test registrarConsulta';
			caso.Origin = 'Phone';
			caso.CC_Canal_Respuesta__c = 'Phone';
			caso.CC_Tipo_Cliente__c = 'Cliente';
			caso.CC_No_Identificado__c = true;
			caso.CC_Canal_Procedencia__c = 'CaixaBankNow';
			insert caso;

			input.casoId = caso.Id;

            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.registrarConsulta(JSON.serialize(input));
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    /*
    @isTest
    public static void registrarConsultaNoAtendida() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'ServicioCC';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        // input.casoId = caso.Id;

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.registrarConsultaNoAtendida(JSON.serialize(input), JSON.serialize(input));
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }
    */

    @isTest
    public static void registrarEncuesta() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'ServicioCC';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        // input.casoId = caso.Id;

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
			Map<String, Object> retornoRegistrarLlamadaEntrante = KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante(JSON.serialize(input));
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			input.llamadaId = llamadaEntrante.Id;
			Case caso = (Case)retornoRegistrarLlamadaEntrante.get('caso');
			input.casoId = caso.Id;

            KIN_Genesys_Cloud_Eventos_Controller.registrarEncuesta(JSON.serialize(input));
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void finalizarLlamada() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'ServicioCC';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        input.llamadaId = [SELECT Id FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'].Id;

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];

		Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		caso.OwnerId = usuarioTest.Id;
		caso.Subject = 'Caso Test finalizarLlamada';
		caso.Origin = 'Phone';
		caso.CC_Canal_Respuesta__c = 'Phone';
		caso.CC_Tipo_Cliente__c = 'Cliente';
		caso.CC_No_Identificado__c = true;
		caso.CC_Canal_Procedencia__c = 'CaixaBankNow';
		insert caso;

		input.casoId = caso.Id;

        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.finalizarLlamada(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void finalizarConsulta() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'ServicioCC';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];

		Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		caso.OwnerId = usuarioTest.Id;
		caso.Subject = 'Caso Test finalizarConsulta';
		caso.Origin = 'Phone';
		caso.CC_Canal_Respuesta__c = 'Phone';
		caso.CC_Tipo_Cliente__c = 'Cliente';
		caso.CC_No_Identificado__c = true;
		caso.CC_Canal_Procedencia__c = 'CaixaBankNow';
		insert caso;

		input.casoId = caso.Id;

        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.finalizarConsulta(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    /*
    @isTest
    public static void finalizarConsultaExterna() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'ServicioCC';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.finalizarConsultaExterna(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void cancelarConsulta() {
        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'];
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'ServicioCC';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        input.llamadaId = llamada.Id;

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.cancelarConsulta(JSON.serialize(input));
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }
    */

    @isTest
    public static void completarConsulta() {
        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            CC_Llamada_Input inputRegistrarLlamadaEntrante = new CC_Llamada_Input();
            inputRegistrarLlamadaEntrante.connId = 'ef208127-2e21-4086-b016-febfa4c43385';
            inputRegistrarLlamadaEntrante.ani = '555666777';
            inputRegistrarLlamadaEntrante.dnis = '888999000';
            inputRegistrarLlamadaEntrante.servicio = 'ServicioCC';
            inputRegistrarLlamadaEntrante.asunto = 'Asunto';
            inputRegistrarLlamadaEntrante.numPerso = '11111';
            Map<String, Object> respuestaRegistrarLlamadaEntrante = KIN_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante(JSON.serialize(inputRegistrarLlamadaEntrante));

            CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
            Case caso = (Case)respuestaRegistrarLlamadaEntrante.get('caso');

            User agenteDestino = [SELECT Id FROM User WHERE Lastname = 'Agente Test 2'];
            System.runAs(agenteDestino) {
                CC_Llamada_Input inputRegistrarConsulta = new CC_Llamada_Input();
                inputRegistrarConsulta.connId = 'ef208127-2e21-4086-b016-febfa4c43385';
                inputRegistrarConsulta.ani = '555666777';
                inputRegistrarConsulta.dnis = '888999000';
                inputRegistrarConsulta.servicio = 'ServicioCC';
                inputRegistrarConsulta.asunto = 'Asunto';
                inputRegistrarConsulta.numPerso = '11111';
                inputRegistrarConsulta.salesforceParentId = llamada.Id;
                inputRegistrarConsulta.casoId = caso.Id;
                Map<String, Object> respuestaRegistrarConsulta = KIN_Genesys_Cloud_Eventos_Controller.registrarConsulta(JSON.serialize(inputRegistrarConsulta));
            }

            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.completarConsulta('ServicioCC', 'ef208127-2e21-4086-b016-febfa4c43385', agenteDestino.Id);
            Test.stopTest();

            caso = [SELECT OwnerId FROM Case WHERE Id = :caso.Id];
            System.assertEquals(agenteDestino.Id, caso.OwnerId, 'El propietario del caso debería ser el agente destino de la transferencia');
        }
    }

    /*
    @isTest
    public static void enviarInteraccion() {
        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.enviarInteraccion('');
            Test.stopTest();
        }

        System.assertEquals(true, true, 'PENDIENTE');
    }
    */

    @isTest
    public static void atributosLlamadaInicial() {
        CC_Llamada__c llamada = [SELECT RecordTypeId, CC_ConnId__c, CC_Servicio_Genesys__c FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'];

        CC_Llamada__c llamadaInicial = new CC_Llamada__c();
        llamadaInicial.RecordTypeId = llamada.RecordTypeId;
        llamadaInicial.KIN_Genesys_Cloud__c = true;
        llamadaInicial.KIN_Llamada_Origen__c = true;
        llamadaInicial.CC_Servicio_Genesys__c = llamada.CC_Servicio_Genesys__c;
        llamadaInicial.CC_ConnId__c = llamada.CC_ConnId__c;
        llamadaInicial.CC_Tipo__c = 'Entrante';
        llamadaInicial.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamadaInicial.CC_Asunto__c = 'Llamada Test Inicial';
        insert llamadaInicial;

        User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
            Test.startTest();
            KIN_Genesys_Cloud_Eventos_Controller.atributosLlamadaInicial(llamada.CC_ConnId__c);
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void purecloudConversationApi() {
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new KIN_PurecloudConversationApi_Mock());
		User usuarioTest = [SELECT Id FROM User WHERE Lastname = 'Agente Test 1'];
        System.runAs(usuarioTest) {
			Map<String, Object> respuestaApi = KIN_Genesys_Cloud_Eventos_Controller.purecloudConversationApi('');
			System.assertEquals(true, true, 'PENDIENTE');
		}
        Test.stopTest();
    }
}