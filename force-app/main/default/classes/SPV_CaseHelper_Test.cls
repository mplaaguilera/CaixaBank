/*****************************************************************
 * Name: SPV_CaseHelper_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de los triggers de case
 * 
****************************************************************/
/**
*   @description SPV_CaseHelper_Test
*/
@isTest
public with sharing class SPV_CaseHelper_Test {

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

        //Grupos colaboradores
        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List <CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoLetrado1 = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1)[0];
        grupoLetrado1.SAC_Email__c = 'testSPV@testemail.com.invalid';
        grupoLetrado1.SAC_DeveloperName__c = 'SPV_FYRLEGALLETRADO';
        gruposColaboradores.add(grupoLetrado1);

        CC_Grupo_Colaborador__c grupoLetrado2 = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1)[0];
        grupoLetrado2.SAC_Email__c = 'testSPV@testemail.com.invalid';
        grupoLetrado2.SAC_DeveloperName__c = 'SPV_INDRALETRADO';
        gruposColaboradores.add(grupoLetrado2);

        CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor.SAC_Email__c = 'testSPVgrestor@testemail.com.invalid';
        grupoGestor.Name = 'indraTestGrupo';
        grupoGestor.SAC_DeveloperName__c = 'SPV_DXC';
        gruposColaboradores.add(grupoGestor);

        CC_Grupo_Colaborador__c grupoGestor2 = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor2.SAC_Email__c = 'testSPVgrestor2@testemail.com.invalid';
        grupoGestor2.Name = 'indraTestGrupo';
        grupoGestor2.CC_Empresa__c = 'DXC';
        gruposColaboradores.add(grupoGestor2);

        CC_Grupo_Colaborador__c grupoGestor3 = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor3.SAC_Email__c = 'testSPVgrestor3@testemail.com.invalid';
        grupoGestor3.CC_Empresa__c = null;
        grupoGestor3.Name = 'indraTestGrupo';
        gruposColaboradores.add(grupoGestor3);

        SPV_DatabaseDML.insertListDML(gruposColaboradores, true);


        List <CC_MCC__c> listaMcc = new   List <CC_MCC__c> ();
        //MCC
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101',
        OwnerId = listUsuarios[0].id,
        SPV_BalanceoForzado__c = false);
        listaMcc.add(mccTematica1);


        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id,
        OwnerId = listUsuarios[0].id,
        SPV_BalanceoForzado__c = false);

        listaMcc.add(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102',
        OwnerId = listUsuarios[0].id,
        SPV_BalanceoForzado__c = false);
        listaMcc.add(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id,
        OwnerId = listUsuarios[0].id,
        SPV_BalanceoForzado__c = false);
        listaMcc.add(mccDetalle1);
        SPV_DatabaseDML.insertListDML(listaMcc, true);

        //Contacto para la reclamación
        Contact contacto  = new Contact();
        contacto.LastName = 'nombre';
       // contacto.AccountId= listaCuentas[0].Id;
        SPV_DatabaseDML.insertDML(contacto, true);

        
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
        Test.startTest();
        //Reclamacion
    
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion3 = new Map<String, Object>();
        camposReclamacion3.put('Subject', 'TestRecCrearRec3');
        camposReclamacion3.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion3.put('Status', 'SPV_AnalisisDecision');
        camposReclamacion3.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion3.put('SAC_StatusAuxiliar__c', 'SPV_AnalisisDecision');

        Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion3);
        listaReclamaciones.add(casoReclamacion3);

        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('SPV_Organismo__c', 'SPV_BDE');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_TipoConsumidor__c', 'No');
        camposRecl2.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl2.put('OwnerId', listUsuarios[0].Id);
        camposRecl2.put('SAC_GrupoLetrado__c', grupoGestor.Id);

        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2); //Reclamacion SAC
        listaReclamaciones.add(casoReclamacion4);

        Map<String, Object> camposReclamacion5 = new Map<String, Object>();
        camposReclamacion5.put('Subject', 'TestRecCrearRec5');
        camposReclamacion5.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion5.put('Status', 'SPV_AnalisisDecision');
        camposReclamacion5.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion5.put('SAC_StatusAuxiliar__c', 'SPV_AnalisisDecision');
        camposReclamacion5.put('SAC_Empresa__c', 'Temporal');
        camposReclamacion5.put('SEG_Grupo__c', grupoGestor2.Id);


        Case casoReclamacion5 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion5);
        listaReclamaciones.add(casoReclamacion5);


        Map<String, Object> camposReclamacion6 = new Map<String, Object>();
        camposReclamacion6.put('Subject', 'TestRecCrearRec6');
        camposReclamacion6.put('Status', 'SPV_AnalisisDecision');
        camposReclamacion6.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion6.put('SAC_StatusAuxiliar__c', 'SPV_AnalisisDecision');
        camposReclamacion6.put('SEG_Grupo__c', grupoGestor2.Id);


        Case casoReclamacion6 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion6);
        listaReclamaciones.add(casoReclamacion6);



        
        Account cuentaTercera = new Account();
        cuentaTercera.Name = 'Tercera';
        cuentaTercera.CC_Tipo_Centro__c = 'DT';
        listaCuentas.add(cuentaTercera);

        SPV_DatabaseDML.insertDML(cuentaTercera, true);
        Account cuentaSegunda = new Account();
        cuentaSegunda.Name = 'Segunda';
        cuentaSegunda.CC_Gerencia_Comercial__c = cuentaTercera.Id;
        cuentaSEGUNDA.parentId = cuentaTercera.Id;
        listaCuentas.add(cuentaSegunda);
        SPV_DatabaseDML.insertDML(cuentaSegunda, true);

        Account cuentaPrimera = new Account();
        cuentaPrimera.Name = 'Primera';
        cuentaPrimera.CC_OficinaGestoraId__c = cuentaSegunda.Id;
        cuentaPrimera.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();  
        //cuentaPrimera.AV_OficinaPrincipal__c = cuentaSegunda.Id;
        listaCuentas.add(cuentaPrimera);
        SPV_DatabaseDML.insertDML(cuentaPrimera, true);


   
        //Cases
     
       
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRecCrearRec1');
        camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');
        //camposReclamacion.put('AccountId', listaCuentas[0].Id);
        //Campos añadidos para poder pasar a análisis:
        camposReclamacion.put('contactId', contacto.Id);
        camposReclamacion.put('SAC_FechaRecepcion__c', System.now());
        camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('SPV_NumExpediente__c', '123');
        camposReclamacion.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[0].Id);
        camposReclamacion.put('SPV_FechaIniRegulador__c', date.today());
        //camposReclamacion.put('CC_Recipient_Oficina_Gestora__c', 'Cuenta SAC');
        camposReclamacion.put('SAC_EntidadProductora__c', 'Bankia');
        camposReclamacion.put('AccountId', listaCuentas[4].Id);
        camposReclamacion.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposReclamacion.put('SAC_FechaVencimientoSLA__c',  System.now());
        camposReclamacion.put('SAC_Entidad_Afectada__c', 'SAC_008');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);

        Map<String, Object> camposReclamacion2 = new Map<String, Object>();
        camposReclamacion2.put('Subject', 'TestRecCrearRec2');
        camposReclamacion2.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion2.put('Status', 'SAC_001');
        camposReclamacion2.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclamacion2.put('SAC_Entidad_Afectada__c', 'SAC_008');
        //Campos añadidos para poder pasar a análisis:
        camposReclamacion2.put('contactId', contacto.Id);
        camposReclamacion2.put('SAC_FechaRecepcion__c', System.now());
        camposReclamacion2.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion2.put('SPV_NumExpediente__c', '123');
        camposReclamacion2.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[0].Id);
        camposReclamacion2.put('SPV_FechaIniRegulador__c', date.today());
        //camposReclamacion2.put('CC_Recipient_Oficina_Gestora__c', 'Cuenta SAC');
        camposReclamacion2.put('SAC_EntidadProductora__c', 'Bankia');
        camposReclamacion2.put('AccountId', listaCuentas[4].Id);
        camposReclamacion2.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposReclamacion2.put('SAC_FechaVencimientoSLA__c',  System.now());

        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion2);
        listaReclamaciones.add(casoReclamacion2);

        Map<String, Object> camposReclamacionACerrar = new Map<String, Object>();
        camposReclamacionACerrar.put('Subject', 'TestRecCrearRecCerrar');
        camposReclamacionACerrar.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacionACerrar.put('Status', 'SPV_RecepcionResolucion');
        camposReclamacionACerrar.put('OwnerId', listUsuarios[0].Id);
        camposReclamacionACerrar.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclamacionACerrar.put('SAC_Entidad_Afectada__c', 'SAC_008');
        //Campos añadidos para poder pasar a análisis:
        camposReclamacionACerrar.put('contactId', contacto.Id);
        camposReclamacionACerrar.put('SAC_FechaRecepcion__c', System.now());
        camposReclamacionACerrar.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacionACerrar.put('SPV_NumExpediente__c', '123');
        camposReclamacionACerrar.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[0].Id);
        camposReclamacionACerrar.put('SPV_FechaIniRegulador__c', date.today());
        //camposReclamacion2.put('CC_Recipient_Oficina_Gestora__c', 'Cuenta SAC');
        camposReclamacionACerrar.put('SAC_EntidadProductora__c', 'Bankia');
        camposReclamacionACerrar.put('AccountId', listaCuentas[4].Id);
        camposReclamacionACerrar.put('SAC_Importe_Tipo__c', 'SIn cuantificar');
        camposReclamacionACerrar.put('SAC_FechaVencimientoSLA__c',  System.now());

        Case casoReclamacionACerrar = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacionACerrar);
        listaReclamaciones.add(casoReclamacionACerrar);

        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec1');
        camposRecl.put('AccountId', listaCuentas[4].Id);
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('OwnerId', listUsuarios[0].id);
        //Campos añadidos para pasar a análisis:
        camposRecl.put('contactId', contacto.Id);
        camposRecl.put('SAC_FechaRecepcion__c', System.now());
        camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
        camposRecl.put('SPV_NumExpediente__c', '123');
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[0].Id);
        camposRecl.put('SPV_FechaIniRegulador__c', date.today());
       // camposRecl.put('CC_Recipient_Oficina_Gestora__c', 'Cuenta SAC');
        camposRecl.put('SAC_EntidadProductora__c', 'Bankia');
        camposRecl.put('AccountId', listaCuentas[4].Id);
        camposRecl.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposRecl.put('SAC_FechaVencimientoSLA__c',  System.now());
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_008');

        Case reclamacion1Repre = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);

    
        Map<String, Object> camposRecla2 = new Map<String, Object>();
        camposRecla2.put('Subject', 'testRec2');
        camposRecla2.put('AccountId', listaCuentas[1].Id);
        camposRecla2.put('CC_Idioma__c', 'es');
        camposRecla2.put('OwnerId', listUsuarios[0].id);
        
        Case reclamacion2Repre = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl2);

     
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'testRec3');
        camposRecl3.put('CC_Idioma__c', 'es');
        camposRecl3.put('SAC_NombreRepresentante__c', 'nombreTest');
        camposRecl3.put('SAC_UsarDatos__c', true);
        camposRecl3.put('OwnerId', listUsuarios[0].id);
        
        Case reclamacion3Repre = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl3);

        //Reclamacion 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'testRec4');
        camposRecl4.put('CC_Idioma__c', 'es');
        camposRecl4.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl4.put('SAC_UsarDatos__c', true);
        camposRecl4.put('OwnerId', listUsuarios[0].id);
        
        Case reclamacion4Repre = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl4);

        //Reclamacion 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'testRec5');
        camposRecl5.put('AccountId', listaCuentas[0].Id);
        camposRecl5.put('CC_Idioma__c', 'es');
        camposRecl5.put('SAC_NombreRepresentante__c', 'nombreTest2');
        camposRecl5.put('SAC_UsarDatos__c', false);
        camposRecl5.put('OwnerId', listUsuarios[0].id);
        
        Case reclamacion5Repre = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl5);

        //List<Case> listaReclamaciones = new List<Case>();
        listaReclamaciones.add(reclamacion1Repre);
        listaReclamaciones.add(reclamacion2Repre);
        listaReclamaciones.add(reclamacion3Repre);
        listaReclamaciones.add(reclamacion4Repre);
        listaReclamaciones.add(reclamacion5Repre);
        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        
        

        
        //Oficinas afectadas
        List<SAC_ImagenDocumento__c> listaOficinasAfectadas = new List<SAC_ImagenDocumento__c>();

        SAC_ImagenDocumento__c objIntermedio1 = new SAC_ImagenDocumento__c();
        objIntermedio1.SAC_Caso__c = casoReclamacion.Id;
        objIntermedio1.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio1);

        SAC_ImagenDocumento__c objIntermedio2 = new SAC_ImagenDocumento__c();
        objIntermedio2.SAC_Caso__c = casoReclamacion2.Id;
        objIntermedio2.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio2);
      
        SAC_ImagenDocumento__c objIntermedio3 = new SAC_ImagenDocumento__c();
        objIntermedio3.SAC_Caso__c = reclamacion1Repre.Id;
        objIntermedio3.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio3);

        SPV_DatabaseDML.insertListDML(listaOficinasAfectadas, true);

        //Pretensiones
        List<Case> listaPretensiones = new List<Case>();
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaPretension1');
        camposPret.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret.put('OwnerId', listUsuarios[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');

        Case casoPretension1 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension1);

        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'pruebaPretension2');
        camposPret2.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret2.put('OwnerId', listUsuarios[0].Id);
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret2.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');


        Case casoPretension2 = SPV_TestDataFactory.crearCaso('Pretension',camposPret2);
        listaPretensiones.add(casoPretension2);

        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'pruebaPretension3');
        camposPret3.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret3.put('OwnerId', listUsuarios[0].Id);
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret3.put('SEG_Detalle__c', mccDetalle1.Id);
        camposPret3.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');

        Case casoPretension3 = SPV_TestDataFactory.crearCaso('Pretension',camposPret3);
        listaPretensiones.add(casoPretension3);

        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SuppliedCompany', 'pruebaPretension4');
        camposPret4.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret4.put('SAC_ResultadoNegociacion__c', 'Sin acuerdo');
        camposPret4.put('SAC_NegociacionFinalizada__c', true);
        camposPret4.put('OwnerId', listUsuarios[0].Id);
        camposPret4.put('Status', 'SAC_007');
        camposPret4.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        camposPret4.put('SEG_Detalle__c', mccDetalle1.Id);

        Case casoPretension4 = SPV_TestDataFactory.crearCaso('Pretension',camposPret4);
        listaPretensiones.add(casoPretension4);

        Map<String, Object> camposPret6 = new Map<String, Object>();
        camposPret6.put('SuppliedCompany', 'pruebaPretension6');
        camposPret6.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret6.put('OwnerId', listUsuarios[0].Id);
        camposPret6.put('Status', 'SAC_001');
        camposPret6.put('SAC_Reclamacion__c', casoReclamacion5.Id);
        camposPret6.put('SEG_Detalle__c', mccDetalle1.Id);
        camposPret6.put('SPV_IdPretension__c', null);

        Case casoPretension6 = SPV_TestDataFactory.crearCaso('Pretension',camposPret6); //Pretension
        listaPretensiones.add(casoPretension6);


        Map<String, Object> camposPret7 = new Map<String, Object>();
        camposPret7.put('SuppliedCompany', 'pruebaPretension7');
        camposPret7.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret7.put('OwnerId', listUsuarios[0].Id);
        camposPret7.put('Status', 'SAC_001');
        camposPret7.put('SAC_Reclamacion__c', casoReclamacion5.Id);
        camposPret7.put('SEG_Detalle__c', mccDetalle1.Id);
        camposPret7.put('SAC_EsPrincipal__c', true);

        Case casoPretension7 = SPV_TestDataFactory.crearCaso('Pretension',camposPret7); //Pretension 
        listaPretensiones.add(casoPretension7);


        Map<String, Object> camposPret8 = new Map<String, Object>();
        camposPret8.put('SuppliedCompany', 'pruebaPretension8');
        camposPret8.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret8.put('OwnerId', listUsuarios[0].Id);
        camposPret8.put('Status', 'SAC_001');
        camposPret8.put('SAC_Reclamacion__c', casoReclamacion6.Id);
        camposPret8.put('SEG_Detalle__c', mccDetalle1.Id);
        camposPret8.put('SAC_EsPrincipal__c', true);
        camposPret8.put('CC_Importe_Reclamado__c', 0);
        camposPret8.put('CC_Importe_Abonado__c', 0);
        camposPret8.put('SAC_Importe_Resuelto__c', 0);


        Case casoPretension8 = SPV_TestDataFactory.crearCaso('Pretension',camposPret8); //Pretension 
        listaPretensiones.add(casoPretension8);


        Map<String, Object> camposPret9 = new Map<String, Object>();
        camposPret9.put('SuppliedCompany', 'pruebaPretension9');
        camposPret9.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret9.put('OwnerId', listUsuarios[0].Id);
        camposPret9.put('Status', 'SAC_001');
        camposPret9.put('SAC_Reclamacion__c', casoReclamacion6.Id);
        camposPret9.put('SEG_Detalle__c', mccDetalle1.Id);
        camposPret9.put('SAC_EsPrincipal__c', true);
        camposPret9.put('CC_Importe_Reclamado__c', 50);
        camposPret9.put('CC_Importe_Abonado__c', 50);
        camposPret9.put('SAC_Importe_Resuelto__c', 50);


        Case casoPretension9 = SPV_TestDataFactory.crearCaso('Pretension',camposPret9); //Pretension
        listaPretensiones.add(casoPretension9);


        Map<String, Object> camposPret10 = new Map<String, Object>();
        camposPret10.put('SuppliedCompany', 'pruebaPretension10');
        camposPret10.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret10.put('OwnerId', listUsuarios[0].Id);
        camposPret10.put('Status', 'SAC_001');
        camposPret10.put('SAC_Reclamacion__c', reclamacion1Repre.Id);
        camposPret10.put('SEG_Detalle__c', mccDetalle1.Id);
        camposPret10.put('SAC_EsPrincipal__c', true);
        camposPret10.put('CC_Importe_Reclamado__c', 50);
        camposPret10.put('CC_Importe_Abonado__c', 50);
        camposPret10.put('SAC_Importe_Resuelto__c', 50);
        camposPret10.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');

        Case casoPretension10 = SPV_TestDataFactory.crearCaso('Pretension',camposPret10); //Pretension
        listaPretensiones.add(casoPretension10);

       

        SPV_DatabaseDML.insertListDML(listaPretensiones, true);
        Test.stopTest();

        SAC_Accion__C tarea = SPV_TestDataFactory.crearTareas(1, casoReclamacion, null)[0];
        SPV_DatabaseDML.insertDML(tarea, true);
       
        CC_MCC_Grupo_Colaborador__c mccGrupoColab = new CC_MCC_Grupo_Colaborador__c();
        mccGrupoColab.CC_Grupo_Colaborador__c = grupoLetrado1.Id;
        mccGrupoColab.CC_MCC__c = mccDetalle1.Id;
        mccGrupoColab.Name = 'Test1 Grupo Colaborador MCC1';
        mccGrupoColab.SAC_MaximoDeCasosDiarios__c = 100;
        mccGrupoColab.SAC_PorcentajeAsignacion__c = 100;
        mccGrupoColab.SPV_Tipo_Cliente__c = 'SPV';
        SPV_DatabaseDML.insertDML(mccGrupoColab, true);

        

    }

    @isTest
    static void actualizarOwnerPretensionesHermanasTest(){

        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT Id, OwnerId FROM Case WHERE SuppliedCompany = 'pruebaPretension8' LIMIT 1];
        

        System.runAs(usuario){
            pretension.OwnerId = usuario.Id;
            SPV_DatabaseDML.updateDML(pretension, true);

        }

        Case pretensionResult1 = [SELECT Id, OwnerId FROM Case WHERE SuppliedCompany = 'pruebaPretension8' LIMIT 1];
        Case pretensionResult2 = [SELECT Id, OwnerId FROM Case WHERE SuppliedCompany = 'pruebaPretension9' LIMIT 1];
        Case reclamacionResult = [SELECT Id, OwnerId, SAC_Letrado__c FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];

        Assert.areEqual(usuario.Id, pretensionResult1.OwnerId, 'No se ha cambiado el owner de las pretensiones 1.');
        Assert.areEqual(usuario.Id, pretensionResult2.OwnerId, 'No se ha cambiado el owner de las pretensiones 2.');
        Assert.areEqual(usuario.Name, reclamacionResult.SAC_Letrado__c, 'No se ha actualizado el campo SAC_Letrado__c en la reclamación.');

        Test.stopTest();
    }

    

    @isTest
    static void arrastrarReclamantePretensionTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId FROM Case WHERE Subject = 'testRec5' LIMIT 1];

        Test.startTest();

        System.runAs(usuario){
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'pruebaPretension100');
            camposPret.put('SPV_Organismo__c', 'SPV_Consumo');
            camposPret.put('OwnerId', usuario.Id);
            camposPret.put('Status', 'SAC_001');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
    
            Case casoPretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret); //Pretension
            SPV_DatabaseDML.insertDML(casoPretension, true);
        }

        Case resultado = [SELECT Id, AccountId FROM Case WHERE SuppliedCompany = 'pruebaPretension100' LIMIT 1];
        Assert.areNotEqual(resultado.AccountId, null, 'No se ha arrastrado el representante a la pretensión.');

        Test.stopTest();

    }

    @isTest
    static void rellenarFechasTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Test.startTest();

        List<Case> listaCaseAdd = new List<Case>();
        List<Case> listaCaseUpdate = new List<Case>();

        System.runAs(usuario){

            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'reclaAnalisis');
            camposRecl.put('CC_Idioma__c', 'es');
            camposRecl.put('OwnerId', usuario.id);
            camposRecl.put('Status', 'SPV_AnalisisDecision');
            camposRecl.put('SAC_FechaRecepcion__c', System.now());
            camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
            camposRecl.put('SPV_NumExpediente__c', 'exp12345');
            Case reclaAnalisis = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
            listaCaseAdd.add(reclaAnalisis);

            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'reclaEnvioOrganismos');
            camposRecl2.put('CC_Idioma__c', 'es');
            camposRecl2.put('OwnerId', usuario.id);
            camposRecl2.put('Status', 'SPV_EnvioOrganismos');
            camposRecl2.put('SAC_FechaRecepcion__c', System.now());
            camposRecl2.put('SPV_Organismo__c', 'SPV_CNMV');
            camposRecl2.put('SPV_NumExpediente__c', 'exp123456');
            Case reclaEnvioOrganismos = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
            listaCaseAdd.add(reclaEnvioOrganismos);

            SPV_DatabaseDML.insertListDML(listaCaseAdd, true);

            reclaAnalisis.Status = 'SPV_EnvioOrganismos';
            listaCaseUpdate.add(reclaAnalisis);
            reclaEnvioOrganismos.Status = 'SPV_PendienteRespuestaOrganismo';
            listaCaseUpdate.add(reclaEnvioOrganismos);

            SPV_DatabaseDML.updateListDML(listaCaseUpdate, true);

        }

        Case reclamacion1 = [SELECT Id, OwnerId, AccountId, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_FechaEnvioOrganismos__c, CBK_Case_Extension_Id__r.SPV_FechaPteRespuestaOrganismo__c  FROM Case WHERE Subject = 'reclaAnalisis' LIMIT 1];
        Case reclamacion2 = [SELECT Id, OwnerId, AccountId, CBK_Case_Extension_Id__r.SPV_FechaEnvioOrganismos__c, CBK_Case_Extension_Id__r.SPV_FechaPteRespuestaOrganismo__c FROM Case WHERE Subject = 'reclaEnvioOrganismos' LIMIT 1];
        Assert.areNotEqual(reclamacion1.CBK_Case_Extension_Id__r.SPV_FechaEnvioOrganismos__c, null, 'No se ha actualizado la fecha 1.');
        Assert.areNotEqual(reclamacion2.CBK_Case_Extension_Id__r.SPV_FechaPteRespuestaOrganismo__c, null, 'No se ha actualizado la fecha 2.');

        Test.stopTest();
    }

    @isTest
    static void actualizarDatosRepresentantePretensionesTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, OS_Email__c FROM Case WHERE Subject = 'testRec5' LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'pruebaPretension100');
            camposPret.put('SPV_Organismo__c', 'SPV_Consumo');
            camposPret.put('OwnerId', usuario.Id);
            camposPret.put('Status', 'SAC_001');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
    
            Case casoPretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret); //Pretension
            SPV_DatabaseDML.insertDML(casoPretension, true);

            reclamacion.OS_Email__c = 'prueba@gmail.com';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        Case resultado = [SELECT Id, AccountId, OS_Email__c FROM Case WHERE SuppliedCompany = 'pruebaPretension100' LIMIT 1];
        Assert.areEqual(resultado.OS_Email__c, 'prueba@gmail.com', 'No se ha arrastrado el representante a la pretensión.');

        Test.stopTest();



    }

    @isTest
    static void rellenarFechaRecepcionResolucionTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Test.startTest();

        List<Case> listaCaseAdd = new List<Case>();

        System.runAs(usuario){

            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'reclaAnalisis');
            camposRecl.put('CC_Idioma__c', 'es');
            camposRecl.put('OwnerId', usuario.id);
            camposRecl.put('Status', 'SPV_AnalisisDecision');
            camposRecl.put('SAC_FechaRecepcion__c', System.now());
            camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
            camposRecl.put('SPV_NumExpediente__c', 'exp12345');
            Case reclaAnalisis = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
            listaCaseAdd.add(reclaAnalisis);
            SPV_DatabaseDML.insertListDML(listaCaseAdd, true);

            reclaAnalisis.SAC_SentidoResolucion__c = 'SPV_FavorableEntidad';
            SPV_DatabaseDML.updateDML(reclaAnalisis, true);


        }

        Case reclamacionResultado = [SELECT Id, OwnerId, CBK_Case_Extension_Id__c, SPV_FechaRecepcionResolucion__c  FROM Case WHERE Subject = 'reclaAnalisis' LIMIT 1];
        Assert.areNotEqual(null, reclamacionResultado.SPV_FechaRecepcionResolucion__c, 'No se ha rellenado la fecha correctamente.');
        Test.stopTest();
    }

    @isTest
    static void cambiarOwnerReclamacion() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            User usuario2 = [SELECT Id FROM User WHERE Username = 'usertest1@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
            Case pretension = [SELECT id FROM Case WHERE SuppliedCompany = 'pruebaPretension1' LIMIT 1];

            reclamacion.OwnerId = usuario2.Id;
            SPV_DatabaseDML.updateDML(reclamacion, true);

            List<CaseShare> listCaseShare = [SELECT Id FROM CaseShare WHERE CaseId = :pretension.Id AND UserOrGroupId = :usuario2.Id];

            Assert.areNotEqual(listCaseShare, null, 'Ha fallado al crear el CaseShare al cambiar de owner la reclamación');
        }

        Test.stopTest();
    }


    @istest
    static void descartarPretensionesTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        
        Test.startTest();
        System.runAs(usuario){
            reclamacion.Status = 'Descartado';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        Case pretension = [SELECT Id, OwnerId, Status FROM Case WHERE SuppliedCompany = 'pruebaPretension1' LIMIT 1];
        Assert.areEqual(pretension.Status, 'Descartado', 'No se ha actualizado el estado de las pretensiones.');

        Test.stopTest();

    }

    @isTest
    static void calcularTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];
        Case pretension = [SELECT Id, CC_Importe_Reclamado__c, SAC_Quebranto__c,CC_Importe_Abonado__c,SAC_Importe_Resuelto__c FROM Case WHERE SuppliedCompany = 'pruebaPretension8' LIMIT 1];
        Test.startTest();
        
        System.runAs(usuario){
        SAC_Accion__c tarea = SPV_TestDataFactory.crearTareas(1,reclamacion,null)[0];
     //   tarea.SAC_ImporteResuelto__c = 100;
        tarea.SAC_ImporteAbonar__c = 100;
       // tarea.SAC_ImpResueltoInteresesLegales__c = 100;
        SPV_DatabaseDML.insertDML(tarea, true);


        pretension.CC_Importe_Abonado__c = 100;
      //  pretension.SAC_Importe_Resuelto__c=100;
        pretension.Status = 'SAC_001';
        pretension.SAC_StatusAuxiliar__c = 'SAC_001';
        SPV_DatabaseDML.updateDML(pretension, true);
  
        }

        Case reclamacionResult = [SELECT Id, OwnerId, CC_Importe_Abonado__c FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];
        Assert.areEqual(reclamacionResult.CC_Importe_Abonado__c, 250.00, 'No se ha cambiado el importe abonado');

    }


    @isTest
    static void actualizarIdPretensionTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, SPV_NumExpediente__c FROM Case WHERE Subject = 'TestRecCrearRec5' LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            reclamacion.SPV_NumExpediente__c = '123';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        Case pretension = [SELECT Id, SPV_IdPretension__c FROM Case WHERE SuppliedCompany = 'pruebaPretension6' LIMIT 1];
        Boolean correcto = false;

        if(String.valueOf(pretension.SPV_IdPretension__c).startsWith('123')){
            correcto = true;
        }else{
            correcto = false;
        }
        Assert.areEqual(true, correcto, 'No se ha actualizado el id de la pretensión correctamente');

        Test.stopTest();
    }


    @isTest
    static void cambiarOwnerPretension() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT id FROM Case WHERE SuppliedCompany = 'pruebaPretension1' LIMIT 1];
       
        Test.startTest();

        System.runAs(usuario) {
            User usuario2 = [SELECT Id FROM User WHERE Username = 'usertest1@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
            Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

            pretension.OwnerId = usuario2.Id;
            SPV_DatabaseDML.updateDML(pretension, true);

            List<CaseShare> listCaseShare = [SELECT Id FROM CaseShare WHERE CaseId = :reclamacion.Id AND UserOrGroupId = :usuario2.Id];

            Assert.areNotEqual(listCaseShare, null, 'Ha fallado al crear el CaseShare al cambiar de owner la pretensión');
        }

        Test.stopTest();
    }


    @isTest 
    static void asignarEmpresaReclamacionTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId,SAC_Empresa__c FROM Case WHERE Subject = 'TestRecCrearRec3' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name, CC_Empresa__c  FROM CC_Grupo_Colaborador__c WHERE SAC_Email__c = 'testSPVgrestor2@testemail.com.invalid' LIMIT 1]; 

        Test.startTest();

        System.runAs(usuario){
            reclamacion.SEG_Grupo__c = grupo.Id;
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

       

        Case reclamacion2 = [SELECT Id, OwnerId, SAC_Empresa__c FROM Case WHERE Subject = 'TestRecCrearRec3' LIMIT 1];

        Assert.areEqual(grupo.CC_Empresa__c, reclamacion2.SAC_Empresa__c, 'No se ha cambiado la empresa');
  
        Test.stopTest();
    }


    @isTest 
    static void asignarEmpresaReclamacionTest2(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId,SAC_Empresa__c FROM Case WHERE Subject = 'TestRecCrearRec5' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name, CC_Empresa__c  FROM CC_Grupo_Colaborador__c WHERE SAC_Email__c = 'testSPVgrestor3@testemail.com.invalid' LIMIT 1]; 

        Test.startTest();

        System.runAs(usuario){
            reclamacion.SEG_Grupo__c = grupo.Id;
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

    
        Case reclamacion2 = [SELECT Id, OwnerId, SAC_Empresa__c FROM Case WHERE Subject = 'TestRecCrearRec5' LIMIT 1];

        Assert.areEqual(grupo.CC_Empresa__c, reclamacion2.SAC_Empresa__c, 'No se ha cambiado la empresa');
        
        Test.stopTest();
    }


    
    @isTest
    static void validarCamposEntraAnalisisReclamacionTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'testRec1' LIMIT 1];
        Account cuenta = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Primera' LIMIT 1];


        Test.startTest();

        System.runAs(usuario){

            SAC_ImagenDocumento__c oficinaAfectada = new SAC_ImagenDocumento__c();
            oficinaAfectada.SAC_Caso__c = reclamacion.Id;
            oficinaAfectada.SPV_OficinaAfectada_Lookup__c = cuenta.Id;
            SPV_DatabaseDML.insertDML(oficinaAfectada, true);

            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        Case reclamacionResult = [SELECT Id, Status FROM Case WHERE Subject = 'testRec1' LIMIT 1];
        Assert.areEqual(reclamacionResult.Status, 'SPV_AnalisisDecision', 'No se ha pasado a análisis aunque se cumplen las validaciones');
        Test.stopTest();

    }

    @isTest
    static void addOficinaAfectadaTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'testRec3' LIMIT 1];
        Account oficina = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Primera' LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            reclamacion.CC_Oficina_Afectada_Lookup__c = oficina.Id;
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        List<SAC_ImagenDocumento__c> listaResult = [SELECT Id FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c = :reclamacion.Id LIMIT 1];
        Assert.areNotEqual(listaResult.isEmpty(), true, 'No se ha eliminado la oficina afectada.'); //No tiene que estar vacía porque se acaba de crear un registro de SAC_ImagenDocumento__c con la nueva oficina afectada añadida

        Test.stopTest();
    }

    @isTest 
    static void asignarDANyDTInsertTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Account cuenta = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Primera' LIMIT 1];
        Account cuentaSegunda = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Segunda' LIMIT 1];
        Account cuenta2 = [SELECT Id  FROM Account WHERE Name = 'Tercera' LIMIT 1];
       
        
        Test.startTest();

        System.runAs(usuario){
            cuenta.AV_OficinaPrincipal__c = cuentaSegunda.Id;
            SPV_DatabaseDML.updateDML(cuenta, true);

            Case reclamacion = new Case();
            reclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();  
            reclamacion.Subject = 'DAN';
            reclamacion.OwnerId = usuario.Id;
            reclamacion.AccountId = cuenta.Id;
          
            SPV_DatabaseDML.insertDML(reclamacion, true);
        }

    
        Case reclamacion2 = [SELECT Id, OwnerId, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Subject = 'DAN' LIMIT 1];

        Assert.areEqual(cuenta2.Id, reclamacion2.CC_DAN__c, 'No se ha cambiado el DAN');
        Assert.areEqual(cuenta2.Id, reclamacion2.CC_Direccion_Territorial__c, 'No se ha cambiado la Dirección Territorial');

        Test.stopTest();
    }


    @isTest 
    static void asignarDANyDTUpdateTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Account cuenta = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Primera' LIMIT 1];
        Account cuentaSegunda = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Segunda' LIMIT 1];
        Account cuenta2 = [SELECT Id  FROM Account WHERE Name = 'Tercera' LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];


        Test.startTest();

        System.runAs(usuario){
            cuenta.AV_OficinaPrincipal__c = cuentaSegunda.Id;
            SPV_DatabaseDML.updateDML(cuenta, true);

            reclamacion.AccountId = cuenta.Id;
           
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

    
        Case reclamacion2 = [SELECT Id, OwnerId, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];

        Assert.areEqual(cuenta2.Id, reclamacion2.CC_DAN__c, 'No se ha cambiado el DAN');
        Assert.areEqual(cuenta2.Id, reclamacion2.CC_Direccion_Territorial__c, 'No se ha cambiado la Dirección Territorial');

        Test.stopTest();
    }


    @isTest
    static void camposRepresentanteValidoTest() {
        List<Case> listaCasosSelect = [SELECT Id, Subject FROM Case WHERE Subject = 'testRec1' OR Subject = 'testRec2' OR Subject = 'testRec3' OR Subject = 'testRec5'];
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        Case caso1 = new Case();
        Case caso2 = new Case();
        Case caso3 = new Case();
        Case caso5 = new Case();

        for (Case caso : listaCasosSelect) {
            if (caso.Subject == 'testRec1') {
                caso1.Id = caso.Id;
            }
            if (caso.Subject == 'testRec2') {
                caso2.Id = caso.Id;
            }
            if (caso.Subject == 'testRec3') {
                caso3.Id = caso.Id;
            }
            if (caso.Subject == 'testRec5') {
                caso5.Id = caso.Id;
            }
        }

        System.runAs(usuario){
            caso1.SAC_NombreRepresentante__c = 'nombreTest';
            caso1.SAC_EmailRepresentante__c = 'test@test.test';
            caso1.SAC_DireccionRepresentante__c = 'direccionTest';
            caso1.SAC_CodigoPostalRepresentante__c = 'codigoPostalTest';
            caso1.SAC_PoblacionRepresentante__c = 'poblacionTest';
            caso1.SAC_ProvinciaRepresentante__c = 'provinciaTest';
            caso1.SAC_PaisRepresentante__c = 'paisTest';

            caso2.SAC_UsarDatos__c = true;

            caso3.SAC_NumeroDelDocumento__c = '666';


            caso5.SAC_NombreRepresentante__c = 'nombreTest';
            caso5.SAC_EmailRepresentante__c = 'test@test.test';
            caso5.SAC_DireccionRepresentante__c = 'direccionTest';
            caso5.SAC_CodigoPostalRepresentante__c = 'codigoPostalTest';
            caso5.SAC_PoblacionRepresentante__c = 'poblacionTest';
            caso5.SAC_ProvinciaRepresentante__c = 'provinciaTest';
            caso5.SAC_PaisRepresentante__c = 'paisTest';

            Test.startTest();
            List<Case> listaCasos = new List<Case>();
            listaCasos.add(caso1);
            listaCasos.add(caso2); //El caso 2 pasa por el if de cuando solo está activo el check SAC_UsarDatos__c
            listaCasos.add(caso3);
            listaCasos.add(caso5);
            SPV_DatabaseDML.updateListDML(listaCasos, true);

            Test.stopTest();
        }

        Case casoResult = [SELECT Id, OS_Email__c, SAC_DireccionPostalNotificacion__c, SAC_DireccionRepresentante__c FROM Case WHERE Subject = 'testRec1'];

        //system.assertEquals(caso1.SAC_EmailRepresentante__c, casoResult.OS_Email__c, 'No se ha podido arrastrar el SAC_EmailRepresentante__c a OS_Email__c');
        System.assertEquals(caso1.SAC_DireccionRepresentante__c, casoResult.SAC_DireccionRepresentante__c, 'No se ha podido arrastrar el SAC_DireccionPostal__c a SAC_DireccionPostalNotificacion__c');
    }



    @isTest
    static void usarDatosDeAlfTest() {
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        List<Case> listaCasosSelect = [SELECT Id, Subject, AccountId, OS_Email__c, CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'testRec3' OR Subject = 'testRec4'];
        Case caso3 = new Case();
        Case caso4 = new Case();
        List<Account> listaAccountsSelect = [SELECT Id, FirstName FROM Account WHERE FirstName = 'Target 0' OR FirstName = 'Target 1'];
        Account acc = new Account();
        Account acc2 = new Account();

        for (Case caso : listaCasosSelect) {
            if (caso.Subject == 'testRec3') {
                caso3.Id = caso.Id;
            }
            if (caso.Subject == 'testRec4') {
                caso4.Id = caso.Id;
            }
        }

        for (Account acco : listaAccountsSelect) {
            if (acco.FirstName == 'Target 0') {
                acc.Id = acco.Id;
            }
            if (acco.FirstName == 'Target 1') {
                acc2.Id = acco.Id;
            }
        }

        System.runAs(usuario){
            caso3.AccountId = acc2.Id;
            caso4.AccountId = acc.Id;

            Test.startTest();
            List<Case> listaCasos = new List<Case>();
            listaCasos.add(caso3);
            listaCasos.add(caso4);
            SPV_DatabaseDML.updateListDML(listaCasos, true);
            Test.stopTest();
        }
        Case caso3Result = [SELECT Id, OS_Email__c, CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'testRec3'];

        System.assertNotEquals(caso3.OS_Email__c, caso3Result.OS_Email__c, 'No se ha podido arrastrar el email del account a OS_Email__c');
        System.assertNotEquals(caso3.CC_Telefono_Contacto__c, caso3Result.CC_Telefono_Contacto__c, 'No se ha podido arrastrar el telefono del account a CC_Telefono_Contacto__c');
        System.assertNotEquals(caso3.SAC_DireccionPostalNotificacion__c, caso3Result.SAC_DireccionPostalNotificacion__c, 'No se ha podido arrastrar la dirección postal del account a SAC_DireccionPostalNotificacion__c');
    }





    /*@isTest 
    static void asignarDANyDTUpdateTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Account cuenta = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Primera' LIMIT 1];
        Account cuentaSegunda = [SELECT Id, CC_OficinaGestoraId__c  FROM Account WHERE Name = 'Segunda' LIMIT 1];
        Account cuenta2 = [SELECT Id  FROM Account WHERE Name = 'Tercera' LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];


        Test.startTest();

        System.runAs(usuario){
            cuenta.AV_OficinaPrincipal__c = cuentaSegunda.Id;
            Database.update(cuenta);

            reclamacion.AccountId = cuenta.Id;
            Database.update(reclamacion);
        }

    
        Case reclamacion2 = [SELECT Id, OwnerId, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];

        Assert.areEqual(cuenta2.Id, reclamacion2.CC_DAN__c, 'No se ha cambiado el DAN');
        Assert.areEqual(cuenta2.Id, reclamacion2.CC_Direccion_Territorial__c, 'No se ha cambiado la Dirección Territorial');

        Test.stopTest();
    }*/



    /*@isTest 
    static void asignarEmpresaReclamacionTest3(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name, CC_Empresa__c  FROM CC_Grupo_Colaborador__c WHERE SAC_Email__c = 'testSPVgrestor2@testemail.com.invalid' LIMIT 1]; 

        Test.startTest();

        System.runAs(usuario){
            List<Case> listaReclamaciones = new List<Case>();
            Case nuevoCaso = new Case();
            nuevoCaso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
            nuevoCaso.put('Subject','Prueba test');
            nuevoCaso.put('Status','SPV_AnalisisDecision' );
            nuevoCaso.put('SEG_Grupo__c',grupo.Id);
            listaReclamaciones.add(nuevoCaso);

            Case nuevoCaso2 = new Case();
            nuevoCaso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
            nuevoCaso2.put('Subject','Prueba test 2');
            nuevoCaso2.put('Status','SPV_AnalisisDecision' );
            listaReclamaciones.add(nuevoCaso2);

            Database.insert(listaReclamaciones);
        }

    
        Case reclamacion2 = [SELECT Id, OwnerId, SAC_Empresa__c FROM Case WHERE Subject = 'Prueba test' LIMIT 1];
        //Case reclamacion3 = [SELECT Id, OwnerId, SAC_Empresa__c FROM Case WHERE Subject = 'Prueba test 2' LIMIT 1];
     
   
        Assert.areEqual(grupo.CC_Empresa__c, reclamacion2.SAC_Empresa__c, 'No se ha cambiado la empresa');
       // Assert.areEqual(null, reclamacion3.SAC_Empresa__c, 'No se ha cambiado la empresa 2');
        Test.stopTest();
    }*/
    

    @isTest
    static void asignarFechaRecepcionReclamacionTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Test.startTest();

        System.runAs(usuario){

            List<Case> listaReclamaciones = new List<Case>();
            Case nuevoCaso = new Case();
            nuevoCaso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
            nuevoCaso.put('Subject', 'Prueba Test');
            nuevoCaso.put('Status','SPV_AnalisisDecision' );
            listaReclamaciones.add(nuevoCaso);

            SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        }

        Case reclamacion2 = [SELECT Id, SAC_FechaRecepcion__c,OwnerId FROM Case WHERE Subject = 'Prueba Test' LIMIT 1];
        Assert.areNotEqual(reclamacion2.SAC_FechaRecepcion__c, null, 'No se ha asignado la fecha de recepción');
        Assert.areNotEqual(reclamacion2.OwnerId, null, 'Bien');
       
       
        Test.stopTest();


    }

    @isTest
    static void actualizarEntidadProductoraTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        //Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec5' LIMIT 1];
        Case pretension = [SELECT Id, SAC_EntidadProductora__c FROM Case WHERE SuppliedCompany = 'pruebaPretension7' LIMIT 1];
        
        Test.startTest();

        System.runAs(usuario){
            pretension.SAC_EntidadProductora__c = 'Bankia';
            SPV_DatabaseDML.updateDML(pretension, true);
        }

        Case reclamacion2 = [SELECT Id, SAC_EntidadProductora__c FROM Case WHERE Subject = 'TestRecCrearRec5' LIMIT 1];
        Case pretension2 = [SELECT Id, SAC_EntidadProductora__c FROM Case WHERE SuppliedCompany = 'pruebaPretension7' LIMIT 1];

        Assert.areEqual(pretension2.SAC_EntidadProductora__c, 'Bankia', 'No se ha actualizado la pretension');
        Assert.areEqual(reclamacion2.SAC_EntidadProductora__c, pretension2.SAC_EntidadProductora__c, 'No se ha actualizado la reclamacion');
    }




    @isTest
    static void actualizarFechaRecepcionPretensiones(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId,SAC_FechaRecepcion__c FROM Case WHERE Subject = 'TestRecCrearRec5' LIMIT 1];
        
        Test.startTest();
        System.runAs(usuario){

            List<Case> listaCasosUpdate = new List<Case>();
            reclamacion.SAC_FechaRecepcion__c = System.now();
            listaCasosUpdate.add(reclamacion);
            SPV_DatabaseDML.updateListDML(listaCasosUpdate, true);
        }

      //  Case reclamacion2 = [SELECT Id, OwnerId,SAC_FechaRecepcion__c FROM Case WHERE Subject = 'TestRecCrearRec5' LIMIT 1];
        Case pretension = [SELECT Id, SAC_FechaRecepcion__c FROM Case WHERE SuppliedCompany = 'pruebaPretension6' LIMIT 1];

        Assert.areNotEqual(pretension.SAC_FechaRecepcion__c, null, 'No se ha actualizado la pretensión hija');
        Test.stopTest();

    }

    @isTest
    static void cambioEstadoRecAnalisisTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        Case reclamacion2 = [SELECT Id, OwnerId, SAC_EntidadProductora__c FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
        Case reclamacionSAC = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Case pret = [SELECT Id, OwnerId FROM Case WHERE SuppliedCompany = 'pruebaPretension1' LIMIT 1];

    
       
        Test.startTest();

        System.runAs(usuario) {

            reclamacion.Status = 'SPV_AnalisisDecision';
            reclamacion.SAC_StatusAuxiliar__c = 'SPV_AnalisisDecision';
            reclamacion.SAC_PretensionPrincipal__c = pret.Id;
            SPV_DatabaseDML.updateDML(reclamacion, true);
            Assert.areNotEqual('SAC_001', reclamacion.Status, 'Ha fallado el paso a analisis de la reclamacion');

            reclamacion2.Status = 'SPV_AnalisisDecision';
            reclamacion2.SAC_StatusAuxiliar__c = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion2, true);
            Assert.areNotEqual('SAC_001', reclamacion2.Status, 'Ha fallado el paso a analisis de la reclamacion');

            reclamacion2.Status = 'SAC_001';
            reclamacion2.SAC_StatusAuxiliar__c = 'SAC_001';
            reclamacion2.CC_CasoRelacionado__c = reclamacionSAC.Id;
            SPV_DatabaseDML.updateDML(reclamacion2, true);

            reclamacion2.Status = 'SPV_AnalisisDecision';
            reclamacion2.SAC_StatusAuxiliar__c = 'SPV_AnalisisDecision';
           
            SPV_DatabaseDML.updateDML(reclamacion2, true);
            Assert.areNotEqual('SAC_001', reclamacion2.Status, 'Ha fallado el paso a analisis de la reclamacion');
        }

        Test.stopTest();
    }

    @isTest
    static void validarCamposEntraCerradoReclamacionTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRecCerrar' LIMIT 1];
        Boolean saltaValidacion = false;
        Test.startTest();

        System.runAs(usuario) {

            try{
                reclamacion.Status = 'Cerrado';
                SPV_DatabaseDML.updateDML(reclamacion, true);
            }catch(Exception e){
                saltaValidacion = true;
            }


        }
        Case reclamacion2 = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRecCerrar' LIMIT 1];
        Assert.areEqual(true, saltaValidacion, 'No ha saltado ninguna validación');
        Test.stopTest();
    }

    @isTest
    static void validarCamposEntraRectificacionReclamacionTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRecCerrar' LIMIT 1];
        Boolean saltaValidacion = false;
        Test.startTest();

        System.runAs(usuario) {

            try{
                reclamacion.Status = 'SPV_Rectificacion';
                SPV_DatabaseDML.updateDML(reclamacion, true);
            }catch(Exception e){
                saltaValidacion = true;
            }


        }
        Case reclamacion2 = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRecCerrar' LIMIT 1];
        Assert.areEqual(true, saltaValidacion, 'No ha saltado ninguna validación');
        Test.stopTest();
    }

    @isTest
    static void validarCamposEntraEnvioReclamacionTest() {
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];
        Boolean saltaValidacion = false;
        

        System.runAs(usuario) {

            try{
                reclamacion.Status = 'SPV_Envio';
                SPV_DatabaseDML.updateDML(reclamacion, true);
            }catch(Exception e){
                saltaValidacion = true;
            }


        }
        Case reclamacion2 = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec6' LIMIT 1];
        Assert.areEqual(true, saltaValidacion, 'No ha saltado ninguna validación');
        Test.stopTest();
    }



    @isTest
    static void validarTipoImporteTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRecCerrar' LIMIT 1];
        Boolean saltaValidacion = false;
        Test.startTest();

        System.runAs(usuario) {
            reclamacion.SAC_Importe_Tipo__c = 'Sin importe';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }
        Case reclamacion2 = [SELECT Id, OwnerId, Status, SAC_Importe_Tipo__c FROM Case WHERE Subject = 'TestRecCrearRecCerrar' LIMIT 1];
        Assert.areEqual('Sin importe', reclamacion2.SAC_Importe_Tipo__c, 'Ha fallado el cambio de tipo importe');
        Test.stopTest();
    }

    @isTest
    static void cambioEstadoRecAnalisisTest2() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion2 = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
        Case reclamacionSAC = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE SAC_Email__c = 'testSPVgrestor@testemail.com.invalid' LIMIT 1];


       
        Test.startTest();

        System.runAs(usuario) {

            grupo.Name = 'fyrlegalTestSPV';
            SPV_DatabaseDML.updateDML(grupo, true);

            reclamacion2.CC_CasoRelacionado__c = reclamacionSAC.Id;
            SPV_DatabaseDML.updateDML(reclamacion2, true);

            reclamacion2.Status = 'SPV_AnalisisDecision';
            reclamacion2.SAC_StatusAuxiliar__c = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion2, true);
            Assert.areNotEqual('SAC_001', reclamacion2.Status, 'Ha fallado el paso a analisis de la reclamacion');
        }

        Test.stopTest();
    }


    @isTest
    static void comprobarResultadoNegociacionTest() {
        List <Case> pretensiones = new List <Case>();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pret1 = [SELECT Id FROM Case WHERE SuppliedCompany = 'pruebaPretension1' LIMIT 1];
        Case pret2 = [SELECT Id FROM Case WHERE SuppliedCompany = 'pruebaPretension2' LIMIT 1];

       
        Test.startTest();

        System.runAs(usuario) {

            pret1.SAC_ResultadoNegociacion__c = 'Sin acuerdo';
            pretensiones.add(pret1);
            pret2.SAC_ResultadoNegociacion__c = 'Sin respuesta';
            pretensiones.add(pret2);
            SPV_DatabaseDML.updateListDML(pretensiones, true);
        }

        Test.stopTest();
        Case reclamacion = [SELECT Id, SAC_ResultadoNegociacion__c FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        Assert.areEqual('Sin acuerdo', reclamacion.SAC_ResultadoNegociacion__c, 'No se completado correctamente el campo en la reclamacion');
    }

    @isTest
    static void cerrarReclamacionTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec3' LIMIT 1];
        Case reclamacionAct = new Case();
 
        Test.startTest();

        System.runAs(usuario) {
            reclamacionAct = SPV_CaseHelper.cerrarReclamacion(reclamacion);
        }

        Assert.areEqual('Cerrado', reclamacionAct.Status, 'No se ha cerrado la reclamacion');

        Test.stopTest();
    }

    @isTest
    static void asignarGrupoReclamacionTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        //Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec3' LIMIT 1];
 
        Test.startTest();
        //Reclamacion
        //List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'Testgrupoinsert');
        camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);

        System.runAs(usuario) {
            SPV_DatabaseDML.insertDML(casoReclamacion, true);
        }

        Case recResult = [SELECT Id, Status FROM Case WHERE Subject = 'Testgrupoinsert' LIMIT 1];
        Assert.areNotEqual(null, recResult, 'Ha fallado la asignación de grupo');

        Test.stopTest();
    }

    @isTest
    static void lanzarAlertasAnalisisAltaTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
 
        Test.startTest();

        System.runAs(usuario) {
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            reclamacion.Status = 'SAC_001';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        SAC_Alerta__c alerta = [SELECT Id FROM SAC_Alerta__c WHERE SAC_Reclamacion__c = :reclamacion.Id LIMIT 1];
        Assert.areNotEqual(null, alerta, 'No se ha generado la alerta');

        Test.stopTest();
    }

    @isTest
    static void lanzarAlertasAnalisisOrganismoTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
 
        Test.startTest();

        System.runAs(usuario) {
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            reclamacion.Status = 'SPV_EnvioOrganismos';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            reclamacion.Status = 'SPV_AnalisisDecision';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        SAC_Alerta__c alerta = [SELECT Id FROM SAC_Alerta__c WHERE SAC_Reclamacion__c = :reclamacion.Id LIMIT 1];
        Assert.areNotEqual(null, alerta, 'No se ha generado la alerta');

        Test.stopTest();
    }

    @isTest
    static void lanzarAlertasTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
        // List<CC_Grupo_Colaborador__c> grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'SPV_INDRALETRADO' OR SAC_DeveloperName__c = 'SPV_FYRLEGALLETRADO'];
 
        Test.startTest();

        System.runAs(usuario) {
            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            reclamacion.Status = 'SPV_AnalisisDecision';
            reclamacion.SPV_Complementaria_Entidad__c = true;
            // reclamacion.SAC_GrupoLetrado__c = grupo[0].Id;
            SPV_DatabaseDML.updateDML(reclamacion, true);
            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            reclamacion.Status = 'SPV_Rectificacion';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        SAC_Alerta__c alerta = [SELECT Id FROM SAC_Alerta__c WHERE SAC_Reclamacion__c = :reclamacion.Id LIMIT 1];
        Assert.areNotEqual(null, alerta, 'No se ha generado la alerta');

        Test.stopTest();
    }

    @isTest
    static void validarEntidadAfectadaReclamacionTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
 
        Test.startTest();

        System.runAs(usuario) {
            reclamacion.SAC_Entidad_Afectada__c = 'SAC_005';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        Case reclamacionFinal = [SELECT Id, SAC_Entidad_Afectada__c FROM Case WHERE Subject = 'TestRecCrearRec2' LIMIT 1];
        Assert.areNotEqual(null, reclamacionFinal.SAC_Entidad_Afectada__c , 'No se ha podido cambiar la entidad afectada de la reclamacion');

        Test.stopTest();
    }
}