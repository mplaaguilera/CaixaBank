/*****************************************************************
 * Name: SPV_CaseHelper_Test2
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de los triggers de case
 * 
****************************************************************/
/**
*   @description SPV_CaseHelper_Test2
*/
@isTest
public with sharing class SPV_CaseHelper_Test2 {

    @TestSetup
    static void makeData(){
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, true);
        }

        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        Id recTypeCasoRelacionadoSPV = Schema.SObjectType.CBK_CaseToCaseRelationship__c.getRecordTypeInfosByDeveloperName().get('SPV_CasoRelacionado').getRecordTypeId();
        Id recTypeGrupoLetrado = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoLetrado').getRecordTypeId();



        Account cuenta = SPV_TestDataFactory.crearCuentas(1)[0];
        SPV_DatabaseDML.insertDML(cuenta, false);

        Entitlement entitlement = new Entitlement(
            name = 'EntitleTest',
            AccountId = cuenta.Id,
            SlaProcessId = [SELECT id, name FROM SlaProcess WHERE name = 'SPV_Process' ORDER BY versionNumber DESC limit 1].id
        );
        SPV_DatabaseDML.insertDML(entitlement, false);

        //Cuentas 
        List<Account> listaCuentas = SPV_TestDataFactory.crearCuentasNoClientePA(2);
        listaCuentas[0].PersonEmail = 'test@test.sactest';
        listaCuentas[0].BillingStreet = 'testStreet';
        listaCuentas[0].BillingPostalCode = '666';
        listaCuentas[0].BillingCity = 'testCity';
        listaCuentas[0].BillingState = 'tetState';
        listaCuentas[0].BillingCountry = 'testCountry';
        listaCuentas[0].Phone = '666666666';
        listaCuentas[0].PersonMobilePhone = '555555555';

        listaCuentas[1].PersonEmail = 'test@test.sactest';
        listaCuentas[1].BillingStreet = 'testStreet';
        listaCuentas[1].BillingPostalCode = '777';
        listaCuentas[1].BillingCity = 'testCity';
        listaCuentas[1].BillingState = 'tetState';
        listaCuentas[1].BillingCountry = 'testCountry';
        listaCuentas[1].PersonMobilePhone = '777777777';
        SPV_DatabaseDML.insertListDML(listaCuentas, true);

        //Grupos
		List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c> ();

		List <CC_Grupo_Colaborador__c> gruposLetrados = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',3);
		gruposLetrados[0].SAC_PorcentajeAsignacion__c = 100;
		gruposLetrados[0].SAC_MaximoCasosDiarios__c = 1;
		gruposLetrados[0].SAC_Sensible__c = true;
        gruposLetrados[0].SAC_DeveloperName__c = 'SPV_FYRLEGALLETRADO';
        gruposLetrados[0].recordTypeId = recTypeGrupoLetrado;
		listaGrupos.add(gruposLetrados[0]);

		gruposLetrados[1].SAC_PorcentajeAsignacion__c = 0;
		gruposLetrados[1].SAC_MaximoCasosDiarios__c = 1;
		gruposLetrados[1].SAC_Presidencia__c = true;
		listaGrupos.add(gruposLetrados[1]);

		gruposLetrados[2].SAC_PorcentajeAsignacion__c = 4;
		gruposLetrados[2].SAC_MaximoCasosDiarios__c = 1;
		listaGrupos.add(gruposLetrados[2]);

		SAC_DatabaseDML.insertListDML(listaGrupos, false); 



        //Contactos
        //Contacto para la reclamación
        Contact contacto  = new Contact();
        contacto.LastName = 'nombre';
        SPV_DatabaseDML.insertDML(contacto, true);


        //MCCs
        List<CC_MCC__c> listTematica = new List<CC_MCC__c>();
		CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		mccTematica.Name = 'Tematica1';
		mccTematica.CC_Tipo_Cliente__c = 'SAC';
		mccTematica.CC_Codigo_Externo__c = 'TE-0000051';
		mccTematica.SAC_ImporteDesdeMCC__c = 4000;
		mccTematica.SAC_ImporteHastaMCC__c = 5000;
		mccTematica.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
        listTematica.add(mccTematica);

		SPV_DatabaseDML.insertListDML(listTematica, false); 


		CC_MCC__c mccProducto = new CC_MCC__c();
		mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		mccProducto.Name = 'Producto1';
		mccProducto.CC_Tipo_Cliente__c = 'SAC';
		mccProducto.CC_Codigo_Externo__c = 'PR-0000051';
		mccProducto.CC_Tematica__c = mccTematica.id;
		mccProducto.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;

		SPV_DatabaseDML.insertDML(mccProducto, false);

        
		CC_MCC__c mccMotivo = new CC_MCC__c();
		mccMotivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		mccMotivo.Name = 'Motivo1';
		mccMotivo.CC_Tipo_Cliente__c = 'SAC';
		mccMotivo.CC_Codigo_Externo__c = 'MO-0000051';
		mccMotivo.CC_Producto_Servicio__c = mccProducto.id;
		mccMotivo.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
		SPV_DatabaseDML.insertDML(mccMotivo, false); 

        List<CC_MCC__c> detalles = new List<CC_MCC__c>();
		CC_MCC__c mccDetalle4 = new CC_MCC__c();
		mccDetalle4.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
		mccDetalle4.Name = 'Detalle4';
		mccDetalle4.CC_Tipo_Cliente__c = 'SAC';
		mccDetalle4.CC_Codigo_Externo__c = 'DE-0000057';
		mccDetalle4.SAC_EndToEnd__c = false;
		mccDetalle4.CC_Motivo__c = mccMotivo.id;
		mccDetalle4.SAC_GrupoColaborador__c = listaGrupos[1].Id;
		mccDetalle4.SAC_ImporteDesdeMCC__c = 1000;
		mccDetalle4.SAC_ImporteHastaMCC__c = 2000;
		mccDetalle4.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
		detalles.add(mccDetalle4);

        CC_MCC__c mccDetalle5 = new CC_MCC__c();
		mccDetalle5.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
		mccDetalle5.Name = 'Detalle5';
		mccDetalle5.CC_Tipo_Cliente__c = 'SAC';
		mccDetalle5.CC_Codigo_Externo__c = 'DE-0000057';
		mccDetalle5.SAC_EndToEnd__c = false;
		mccDetalle5.CC_Motivo__c = mccMotivo.id;
		mccDetalle5.SAC_GrupoColaborador__c = listaGrupos[1].Id;
		mccDetalle5.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
		detalles.add(mccDetalle5);
        SPV_DatabaseDML.insertListDML(detalles, false); 


        Test.StartTest();
        //Reclamaciones
        List<Case> listaReclamaciones = new List<Case>();
        //Reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl.put('SAC_UsarDatos__c', false);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SPV_FechaRecepcionResolucion__c', CBK_UtilsDate.todayDT());
        camposRecl.put('OwnerId', listUsuarios[0].id);

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //Reclamacion 2
        camposRecl.clear();
        camposRecl.put('Subject', 'TestRec2');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('SPV_Organismo__c', 'SPV_BDE');
        camposRecl.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl.put('SAC_UsarDatos__c', false);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SPV_FechaRecepcionResolucion__c', CBK_UtilsDate.todayDT());
        camposRecl.put('OwnerId', listUsuarios[0].id);
        camposRecl.put('contactId', contacto.Id);
        camposRecl.put('SAC_FechaRecepcion__c', CBK_UtilsDate.nowSYS());
        camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
        camposRecl.put('SPV_NumExpediente__c', '123');
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[1].Id);
        camposRecl.put('SPV_FechaIniRegulador__c', CBK_UtilsDate.todayDT());
        camposRecl.put('SAC_EntidadProductora__c', 'Bankia');
        camposRecl.put('AccountId', listaCuentas[1].Id);
        camposRecl.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposRecl.put('SAC_FechaVencimientoSLA__c',  CBK_UtilsDate.nowSYS());
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_008');
        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        listaReclamaciones.add(casoReclamacion2);


        //Reclamacion 3
        camposRecl.clear();
        camposRecl.put('Subject', 'TestRec3');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('SPV_Organismo__c', 'SPV_BDE');
        camposRecl.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl.put('SAC_UsarDatos__c', false);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SPV_FechaRecepcionResolucion__c', CBK_UtilsDate.todayDT());
        camposRecl.put('OwnerId', listUsuarios[0].id);
        camposRecl.put('contactId', contacto.Id);
        camposRecl.put('SAC_FechaRecepcion__c', CBK_UtilsDate.nowSYS());
        camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
        camposRecl.put('SPV_NumExpediente__c', '123');
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[1].Id);
        camposRecl.put('SPV_FechaIniRegulador__c', CBK_UtilsDate.todayDT());
        camposRecl.put('SAC_EntidadProductora__c', 'Bankia');
        camposRecl.put('AccountId', listaCuentas[1].Id);
        camposRecl.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposRecl.put('SAC_FechaVencimientoSLA__c',  CBK_UtilsDate.nowSYS());
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_008');
        camposRecl.put('CC_Importe_Reclamado__c', 1500);
        camposRecl.put('SAC_Importe_Tipo__c', 'Importe reclamado');
        Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        listaReclamaciones.add(casoReclamacion3);

        //Reclamacion 4
        camposRecl.clear();
        camposRecl.put('Subject', 'TestRec4');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('SPV_Organismo__c', 'SPV_BDE');
        camposRecl.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl.put('SAC_UsarDatos__c', false);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SPV_FechaRecepcionResolucion__c', CBK_UtilsDate.todayDT());
        camposRecl.put('OwnerId', listUsuarios[0].id);
        camposRecl.put('contactId', contacto.Id);
        camposRecl.put('SAC_FechaRecepcion__c', CBK_UtilsDate.nowSYS());
        camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
        camposRecl.put('SPV_NumExpediente__c', '123');
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[1].Id);
        camposRecl.put('SPV_FechaIniRegulador__c', CBK_UtilsDate.todayDT());
        camposRecl.put('SAC_EntidadProductora__c', 'Bankia');
        camposRecl.put('AccountId', listaCuentas[1].Id);
        camposRecl.put('SAC_FechaVencimientoSLA__c',  CBK_UtilsDate.nowSYS());
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_008');
        camposRecl.put('CC_Importe_Reclamado__c', 4500);
        camposRecl.put('SAC_Importe_Tipo__c', 'Importe reclamado');
        Case casoReclamacion4 = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        listaReclamaciones.add(casoReclamacion4);

        //Reclamacion 5
        camposRecl.clear();
        camposRecl.put('Subject', 'TestRec5');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('SPV_Organismo__c', 'SPV_BDE');
        camposRecl.put('SAC_NombreRepresentante__c', 'nombreTest5');
        camposRecl.put('SAC_UsarDatos__c', false);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SPV_FechaRecepcionResolucion__c', CBK_UtilsDate.todayDT());
        camposRecl.put('OwnerId', listUsuarios[0].id);
        camposRecl.put('contactId', contacto.Id);
        camposRecl.put('SAC_FechaRecepcion__c', CBK_UtilsDate.nowSYS());
        camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
        camposRecl.put('SPV_NumExpediente__c', '123');
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[1].Id);
        camposRecl.put('SPV_FechaIniRegulador__c', CBK_UtilsDate.todayDT());
        camposRecl.put('SAC_EntidadProductora__c', 'Bankia');
        camposRecl.put('AccountId', listaCuentas[1].Id);
        camposRecl.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposRecl.put('SAC_FechaVencimientoSLA__c',  CBK_UtilsDate.nowSYS());
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_008');
        Case casoReclamacion5 = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        listaReclamaciones.add(casoReclamacion5);


        //Reclamación SAC
        camposRecl.clear();
        camposRecl.put('Subject', 'TestRecSAC');
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('SAC_NombreRepresentante__c', 'nombreTestSAC');
        camposRecl.put('SAC_UsarDatos__c', false);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SPV_FechaRecepcionResolucion__c', CBK_UtilsDate.todayDT());
        camposRecl.put('OwnerId', listUsuarios[0].id);
        Case casoReclamacionSAC = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        listaReclamaciones.add(casoReclamacionSAC);

        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        //Pretensiones
        List<Case> listaPretensiones = new List<Case>();
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaPretension1');
        camposPret.put('SPV_Organismo__c', 'SPV_BDE');
        camposPret.put('OwnerId', listUsuarios[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret.put('SAC_ResumenManual__c', 'Test');
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');

        Case casoPretension1 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension1);

        camposPret.clear();
        camposPret.put('SuppliedCompany', 'pruebaPretension2');
        camposPret.put('SPV_Organismo__c', 'SPV_BDE');
        camposPret.put('OwnerId', listUsuarios[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        camposPret.put('SAC_ResumenManual__c', 'Test');
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');
		camposPret.put('SEG_Detalle__c', mccDetalle4.Id);
        Case casoPretension2 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension2);

        camposPret.clear();
        camposPret.put('SuppliedCompany', 'pruebaPretension3');
        camposPret.put('SPV_Organismo__c', 'SPV_BDE');
        camposPret.put('OwnerId', listUsuarios[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion4.Id);
        camposPret.put('SAC_ResumenManual__c', 'Test');
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');
		camposPret.put('SEG_Detalle__c', mccDetalle5.Id);
		camposPret.put('CC_MCC_Tematica__c', mccTematica.Id);
        camposPret.put('CC_MCC_ProdServ__c', mccProducto.Id);
		camposPret.put('CC_MCC_Motivo__c', mccMotivo.Id);
        Case casoPretension3 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension3);

        camposPret.clear();
        camposPret.put('SuppliedCompany', 'pruebaPretension4');
        camposPret.put('SPV_Organismo__c', 'SPV_BDE');
        camposPret.put('OwnerId', listUsuarios[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion5.Id);
        camposPret.put('SAC_ResumenManual__c', 'Test');
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');
		camposPret.put('SEG_Detalle__c', mccDetalle5.Id);
		camposPret.put('CC_MCC_Tematica__c', mccTematica.Id);
        camposPret.put('CC_MCC_ProdServ__c', mccProducto.Id);
		camposPret.put('CC_MCC_Motivo__c', mccMotivo.Id);
        Case casoPretension4 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension4);

        //Pretensión SAC
        camposPret.clear();
        camposPret.put('SuppliedCompany', 'pruebaPretensionSAC');
        camposPret.put('OwnerId', listUsuarios[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacionSAC.Id);
        camposPret.put('SAC_ResumenManual__c', 'Test');
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');
		camposPret.put('SEG_Detalle__c', mccDetalle5.Id);
		camposPret.put('CC_MCC_Tematica__c', mccTematica.Id);
        camposPret.put('CC_MCC_ProdServ__c', mccProducto.Id);
		camposPret.put('CC_MCC_Motivo__c', mccMotivo.Id);
        camposPret.put('SEG_Grupo__c', listaGrupos[0].Id);
        Case casoPretensionSAC = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretensionSAC);

        SPV_DatabaseDML.insertListDML(listaPretensiones, true);


        casoReclamacionSAC.SAC_PretensionPrincipal__c = casoPretensionSAC.Id;
        SPV_DatabaseDML.updateDML(casoReclamacionSAC, true);
        //Marcas
        List<SAC_MaestroTemas__c>  marcas = new List<SAC_MaestroTemas__c>();

        for(Integer i = 0; i<2; i++){
            SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c(
            Name = 'maestroAdjuntoTest' + i,
            RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SPV_Marcas').getRecordTypeId(),
            SAC_Seccion__c = 'Test maestro adjunto',
            SAC_OrdenPrelacion__c = i,
            SAC_GrupoLetrado__c = gruposLetrados[0].Id
            );
            marcas.add(maestroTema);
        }

		SPV_DatabaseDML.insertListDML(marcas, false);

        //Marca-Case
        List <SAC_Marca_Case__c> listMarcas = new List<SAC_Marca_Case__c>();
        SAC_Marca_Case__c marcaAsociada = new SAC_Marca_Case__c();
		marcaAsociada.SAC_Case__c = casoReclamacion2.Id;
		marcaAsociada.SAC_Marca__c = marcas[0].id;
		listMarcas.add(marcaAsociada);

		SAC_Marca_Case__c marcaAsociada2 = new SAC_Marca_Case__c();
		marcaAsociada2.SAC_Case__c = casoReclamacion2.Id;
		marcaAsociada2.SAC_Marca__c = marcas[1].id;
		listMarcas.add(marcaAsociada2);

		SPV_DatabaseDML.insertListDML(listMarcas, false);

        //Parametrizacion balanceo
        List<SAC_MaestroTemas__c> parametrizacion = new List<SAC_MaestroTemas__c>();
        SAC_MaestroTemas__c maestroTemaParametrizacion = new SAC_MaestroTemas__c(
        Name = 'CNMV',
        RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SPV_ParametrizacionOrganismo').getRecordTypeId(),
        SPV_Organismo__c = 'SPV_CNMV',
        SPV_PorcentajeAsignacion__c = 100,
        SAC_GrupoLetrado__c = gruposLetrados[0].Id
        );
        parametrizacion.add(maestroTemaParametrizacion);

		SPV_DatabaseDML.insertListDML(parametrizacion, false);

        //Oficinas afectadas
        List<SAC_ImagenDocumento__c> listaOficinasAfectadas = new List<SAC_ImagenDocumento__c>();
        SAC_ImagenDocumento__c objIntermedio1 = new SAC_ImagenDocumento__c();
        objIntermedio1.SAC_Caso__c = casoReclamacion2.Id;
        objIntermedio1.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio1);

        SAC_ImagenDocumento__c objIntermedio2 = new SAC_ImagenDocumento__c();
        objIntermedio2.SAC_Caso__c = casoReclamacion3.Id;
        objIntermedio2.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio2);

        SAC_ImagenDocumento__c objIntermedio3 = new SAC_ImagenDocumento__c();
        objIntermedio3.SAC_Caso__c = casoReclamacion4.Id;
        objIntermedio3.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio3);

        SAC_ImagenDocumento__c objIntermedio4 = new SAC_ImagenDocumento__c();
        objIntermedio4.SAC_Caso__c = casoReclamacion5.Id;
        objIntermedio4.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio4);

        SPV_DatabaseDML.insertListDML(listaOficinasAfectadas, true);


        //Relaciones Case to Case
        List<CBK_CaseToCaseRelationship__c> listCaseToCase = new List<CBK_CaseToCaseRelationship__c>();
        CBK_CaseToCaseRelationship__c caseToCase1 = new CBK_CaseToCaseRelationship__c();
        caseToCase1.SPV_CasoPadre__c = casoReclamacion5.Id;
        caseToCase1.SPV_CasoVinculado__c = casoReclamacionSAC.Id;
        caseToCase1.RecordTypeId = recTypeCasoRelacionadoSPV;
        listCaseToCase.add(caseToCase1);

        SPV_DatabaseDML.insertListDML(listCaseToCase, true);

        Test.stopTest();
    }

    private static User getOrCreateUserByProfile(String profileName) {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1];

        // Si ya hay un usuario activo con ese perfil, úsalo y evita DML
        List<User> us = [SELECT Id FROM User WHERE IsActive = true AND ProfileId = :p.Id LIMIT 1];
        if (!us.isEmpty()) return us[0];

        // Si no hay, crea uno nuevo con TODOS los campos obligatorios
        String uniq = String.valueOf(CBK_UtilsDate.nowDT().getTime());
        User u = new User(
            ProfileId = p.Id,
            Alias = ('u' + uniq).substring(0, 8),
            Email = 'u' + uniq + '@test.com',
            Username = 'u' + uniq + '@example.test', // único global
            LastName = 'Test',
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            CommunityNickname = 'nick' + uniq
        );
        insert u;
        return u;
    }




    @isTest
    static void balanceoPorAntecedenteTest(){
        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, Status FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
        System.runAs(usuario){
            reclamacion.SPV_Organismo__c = 'SPV_BDE';
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }
        Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'pruebaPretension4' Limit 1];
        System.assertNotEquals(pretension.SEG_Grupo__c, null, 'El balanceo no ha funcionado');
        Test.stopTest();
    }

    @isTest
    static void balanceoPorImporteTest(){
        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, Status FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        System.runAs(usuario){
            reclamacion.SPV_Organismo__c = 'SPV_BDE';
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }
        Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'pruebaPretension2' Limit 1];
        System.assertNotEquals(pretension.SEG_Grupo__c, null, 'El balanceo no ha funcionado');
        Test.stopTest();
    }

    @isTest
    static void balanceoPorImporteTest2(){
        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, Status FROM Case WHERE Subject = 'TestRec4' LIMIT 1];
        System.runAs(usuario){
            reclamacion.SPV_Organismo__c = 'SPV_BDE';
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }
        Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'pruebaPretension3' Limit 1];
        System.assertNotEquals(pretension.SEG_Grupo__c, null, 'El balanceo no ha funcionado');
        Test.stopTest();
    }

    @isTest
    static void balanceoMarcaTest(){
        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];

        System.runAs(usuario){
            reclamacion.SPV_Organismo__c = 'SPV_BDE';
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'pruebaPretension1' Limit 1];
        System.assertNotEquals(pretension.SEG_Grupo__c, null, 'El balanceo no ha funcionado');
        Test.stopTest();
    }

    @isTest
    static void balanceoPorGrupoTest(){
        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, Status FROM Case WHERE Subject = 'TestRec2' LIMIT 1];

        System.runAs(usuario){
            reclamacion.SPV_Organismo__c = 'SPV_CNMV';
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'pruebaPretension1' Limit 1];
        System.assertNotEquals(pretension.SEG_Grupo__c, null, 'El balanceo no ha funcionado');
        Test.stopTest();
    }

    @isTest
    static void completarSLAsTest(){
        Test.StartTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CaseMilestone resultadoSLAEnvio = new CaseMilestone();
        CaseMilestone resultadoSLARecepcionResolucion = new CaseMilestone();

        System.runAs(usuario){
            List<Case> listaCasosActualizar = new List<Case>();

            //Casos para testear completarSLAs
            reclamacion.Status = 'SPV_Envio';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_RecepcionResolucion';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.SAC_SentidoResolucion__c = 'SAC_005';
            reclamacion.Status = 'SPV_Rectificacion';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();
        
            resultadoSLAEnvio = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Envío Análisis y Decisión'];
            resultadoSLARecepcionResolucion = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Recepción Resolución'];
        }

        Assert.areNotEqual(resultadoSLAEnvio.CompletionDate, null, 'No se han completado los SLAs correctamente');
        Assert.areNotEqual(resultadoSLARecepcionResolucion.CompletionDate, null, 'No se han completado los SLAs correctamente');
        Test.stopTest();
    }

    @isTest
    static void completarSLAPlazoRegCompleOrganismoTest(){

        Test.StartTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CaseMilestone resultadoSLAPlazoRegCompleOrganismo = new CaseMilestone();
        System.runAs(usuario){

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Id = reclamacion.CBK_Case_Extension_Id__c;
            caseExtension.SPV_FechaVencimientoPlazoRegOrganismo__c = CBK_UtilsDate.todayDT();

            SPV_DatabaseDML.updateDML(caseExtension, true);
            List<Case> listaCasosActualizar = new List<Case>();

            //Casos para testear completarSLAs
            reclamacion.Status = 'SPV_EnvioComplementaria';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

        
            resultadoSLAPlazoRegCompleOrganismo = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Plazo Regulatorio Complementaria Organismo'];

        }
        Assert.areNotEqual(resultadoSLAPlazoRegCompleOrganismo.CompletionDate, null, 'No se han completado los SLAs correctamente');
        Test.stopTest();
    }

    @isTest
    static void completarSLACompleOrganismoLetradoTest(){

        Test.StartTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CaseMilestone resultadoSLACompleOrganismoLetrado = new CaseMilestone();
        System.runAs(usuario){

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Id = reclamacion.CBK_Case_Extension_Id__c;
            caseExtension.SPV_FechaVencimientoPlazoRegOrganismo__c = CBK_UtilsDate.todayDT();

            SPV_DatabaseDML.updateDML(caseExtension, true);
            List<Case> listaCasosActualizar = new List<Case>();

            //Casos para testear completarSLAs
            reclamacion.Status = 'SPV_AnalisisComplementariaOrganismo';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_EnvioComplementaria';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

        
            resultadoSLACompleOrganismoLetrado = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Complementaria Organismo Letrado'];

        }
        Assert.areNotEqual(resultadoSLACompleOrganismoLetrado.CompletionDate, null, 'No se han completado los SLAs correctamente');
        Test.stopTest();
    }



    @isTest
    static void completarSLAEnvioComplementariaTest(){

        Test.StartTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CaseMilestone resultadoSLAEnvioComplementaria = new CaseMilestone();
        System.runAs(usuario){

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Id = reclamacion.CBK_Case_Extension_Id__c;
            caseExtension.SPV_FechaVencimientoPlazoRegOrganismo__c = CBK_UtilsDate.todayDT();

            SPV_DatabaseDML.updateDML(caseExtension, true);
            List<Case> listaCasosActualizar = new List<Case>();

            //Casos para testear completarSLAs
            reclamacion.Status = 'SPV_EnvioComplementaria';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

        
            resultadoSLAEnvioComplementaria = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Envío Complementaria Organismo'];

        }
        Assert.areNotEqual(resultadoSLAEnvioComplementaria.CompletionDate, null, 'No se han completado los SLAs correctamente');
        Test.stopTest();
    }

    @isTest
    static void reabrirSLAsTest(){
        Test.StartTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CaseMilestone resultadoSLARecepcionResolucion = new CaseMilestone();

        System.runAs(usuario){
            List<Case> listaCasosActualizar = new List<Case>();

            //Casos para testear reabrirSLAs
            reclamacion.Status = 'SPV_RecepcionResolucion';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.SAC_SentidoResolucion__c = 'SAC_005';
            reclamacion.Status = 'SPV_Rectificacion';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_RecepcionResolucion';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();
        
            resultadoSLARecepcionResolucion = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Recepción Resolución'];
        }

        Assert.areEqual(resultadoSLARecepcionResolucion.CompletionDate, null, 'No se han reabierto los SLAs correctamente');
        Test.stopTest();
    }

    @isTest
    static void reabrirSLAsAlta(){
        Test.StartTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, contactId FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        CaseMilestone resultadoSLAAlta = new CaseMilestone();

        System.runAs(usuario){
            List<Case> listaCasosActualizar = new List<Case>();

            //Casos para testear reabrirSLAs
            reclamacion.Status = 'SPV_AnalisisDecision';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            //reclamacion.SAC_SentidoResolucion__c = 'SAC_001';
            reclamacion.Status = 'SAC_001';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            /*reclamacion.Status = 'SPV_AnalisisDecision';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();*/
        
            resultadoSLAAlta = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Alta'];
        }

        Assert.areEqual(resultadoSLAAlta.CompletionDate, null, 'No se han reabierto los SLAs correctamente');
        Test.stopTest();
    }

    @isTest
    static void reabrirSLACompleOrganismoLetrado(){

        Test.StartTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CaseMilestone resultadoSLACompleOrganismoLetrado = new CaseMilestone();
        System.runAs(usuario){

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Id = reclamacion.CBK_Case_Extension_Id__c;
            caseExtension.SPV_FechaVencimientoPlazoRegOrganismo__c = CBK_UtilsDate.todayDT();

            SPV_DatabaseDML.updateDML(caseExtension, true);
            List<Case> listaCasosActualizar = new List<Case>();

            //Casos para testear completarSLAs
            reclamacion.Status = 'SPV_AnalisisComplementariaOrganismo';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_EnvioComplementaria';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();

            reclamacion.Status = 'SPV_AnalisisComplementariaOrganismo';
            listaCasosActualizar.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
            listaCasosActualizar.clear();
        
            resultadoSLACompleOrganismoLetrado = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId = :reclamacion.Id AND MilestoneType.Name = 'SLA Complementaria Organismo Letrado'];

        }
        Assert.areEqual(resultadoSLACompleOrganismoLetrado.CompletionDate, null, 'No se han completado los SLAs correctamente');
        Test.stopTest();
    }


    @isTest
    static void rellenarFechaEntraRecepcionResolucionTest(){
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Case reclamacionResult = new Case();

        Test.startTest();
        System.runAs(usuario){
            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            reclamacion.Status = 'SPV_RecepcionResolucion';
            SPV_DatabaseDML.updateDML(reclamacion, true);

            reclamacionResult = [SELECT Id, CBK_Case_Extension_Id__r.SPV_FechaEntraRecepcionResolucion__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        }

        Assert.areNotEqual(reclamacionResult.CBK_Case_Extension_Id__r.SPV_FechaEntraRecepcionResolucion__c, null, 'No se ha rellenado la fecha de recepción de resolución correctamente');
        Test.stopTest();

    }



}