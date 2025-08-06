/*****************************************************************
 * Name: SPV_CaseExtensionHelper_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito_ Test de los Triggers de Case Extension
 * 
****************************************************************/
@isTest
public with sharing class SPV_CaseExtensionHelper_Test {
    private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //Record Type de Case Extension para SPV
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();

    //Record Type de Case 
    private static final Id RECTYPEPRETENSIONCASE = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();

    @TestSetup
    static void makeData(){
        
        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        List<User> listUsuarios;
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
        //Reclamacion
        List<Case> listaReclamaciones = new List<Case>();

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
        listaCuentas.add(cuentaPrimera);
        SPV_DatabaseDML.insertDML(cuentaPrimera, true);

        //Cases
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRecCrearRec1');
        camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');
        //Campos añadidos para poder pasar a análisis:
        camposReclamacion.put('contactId', contacto.Id);
        camposReclamacion.put('SAC_FechaRecepcion__c', CBK_UtilsDate.nowSYS());
        camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('SPV_NumExpediente__c', '123');
        camposReclamacion.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[0].Id);
        camposReclamacion.put('SPV_FechaIniRegulador__c', date.today());
        camposReclamacion.put('SAC_EntidadProductora__c', 'Bankia');
        camposReclamacion.put('AccountId', listaCuentas[4].Id);
        camposReclamacion.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposReclamacion.put('SAC_FechaVencimientoSLA__c',  CBK_UtilsDate.nowSYS());
        camposReclamacion.put('SAC_Entidad_Afectada__c', 'SAC_008');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);


        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec1');
        camposRecl.put('AccountId', listaCuentas[4].Id);
        camposRecl.put('CC_Idioma__c', 'es');
        camposRecl.put('OwnerId', listUsuarios[0].id);
        //Campos añadidos para pasar a análisis:
        camposRecl.put('contactId', contacto.Id);
        camposRecl.put('SAC_FechaRecepcion__c', CBK_UtilsDate.nowSYS());
        camposRecl.put('SPV_Organismo__c', 'SPV_CNMV');
        camposRecl.put('SPV_NumExpediente__c', '123');
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[0].Id);
        camposRecl.put('SPV_FechaIniRegulador__c', date.today());
        camposRecl.put('SAC_EntidadProductora__c', 'Bankia');
        camposRecl.put('AccountId', listaCuentas[4].Id);
        camposRecl.put('SAC_Importe_Tipo__c', 'Sin importe');
        camposRecl.put('SAC_FechaVencimientoSLA__c',  CBK_UtilsDate.nowSYS());
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_008');

        Case reclamacion1Repre = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);

        listaReclamaciones.add(reclamacion1Repre);
        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        //Oficinas afectadas
        List<SAC_ImagenDocumento__c> listaOficinasAfectadas = new List<SAC_ImagenDocumento__c>();

        SAC_ImagenDocumento__c objIntermedio1 = new SAC_ImagenDocumento__c();
        objIntermedio1.SAC_Caso__c = casoReclamacion.Id;
        objIntermedio1.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        listaOficinasAfectadas.add(objIntermedio1);
      
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
        camposPret.put('SAC_ResumenManual__c', 'Test');
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');

        Case casoPretension1 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension1);

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
    static void filtrarCasosSPVTest(){

        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        List<CBK_Case_Extension__c> listaResult = new List<CBK_Case_Extension__c>();
        Integer numeroCasos;
        System.runAs(usuario){

            Test.startTest();
            List<CBK_Case_Extension__c> listaCasosExtAdd = new List<CBK_Case_Extension__c>();
            CBK_Case_Extension__c caseExt1 = new CBK_Case_Extension__c();
            CBK_Case_Extension__c caseExt2 = new CBK_Case_Extension__c();
            CBK_Case_Extension__c caseExt3 = new CBK_Case_Extension__c();

            caseExt1.RecordTypeId = RECTYPERECLAMACIONEXTENSION;
            caseExt2.RecordTypeId = RECTYPEPRETENSIONCASE;
            caseExt3.RecordTypeId = RECTYPERECLAMACIONEXTENSION;

            listaCasosExtAdd.add(caseExt1);
            listaCasosExtAdd.add(caseExt2);
            listaCasosExtAdd.add(caseExt3);

            listaResult = SPV_CaseExtensionHelper.filtrarCasosSPV(listaCasosExtAdd);
            numeroCasos = listaResult.size();
            Test.stopTest();

        }

        Assert.areEqual(numeroCasos, 2, 'No se han filtrado los casos correctamente');
    }
    
    @isTest
    static void actualizarCamposTest(){

        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, AccountId FROM Case WHERE SPV_NumExpediente__c = '123' LIMIT 1];
        CBK_Case_Extension__c caseExt = [SELECT Id, OwnerId, SPV_MotivoProrroga__c, SPV_ObservacionesProrroga__c, SPV_MotivoAnulacionProrroga__c, SPV_ObservacionesAnulacionProrroga__c, SPV_MotivoDevolucionEnvio__c,
                                           SPV_ObservacionesDevolucionLetradoEnvio__c, SPV_MotivoDevolucionComplementaria__c, SPV_ObservacionDevolucionComplementarias__c, SPV_MotivoDevolucionRectificacion__c, 
                                           SPV_ObservacionDevolucionRectificacion__c, SPV_FechaEnvioOrganismoRectificacion__c, SPV_FechaPteRespuestaOrganismo__c, SPV_FechaAnulacionProrroga__c
                                           FROM CBK_Case_Extension__c WHERE Case_Id__c =: reclamacion.Id LIMIT 1];
        caseExt.SPV_MotivoProrroga__c = 'SPV_001';
        caseExt.SPV_ObservacionesProrroga__c = 'Test 1';
        caseExt.SPV_MotivoAnulacionProrroga__c = 'SPV_001';
        caseExt.SPV_ObservacionesAnulacionProrroga__c = 'Test 1';
        caseExt.SPV_MotivoDevolucionEnvio__c = 'SPV_001';
        caseExt.SPV_ObservacionesDevolucionLetradoEnvio__c = 'Test 1';
        caseExt.SPV_MotivoDevolucionComplementaria__c = 'SPV_001';
        caseExt.SPV_ObservacionDevolucionComplementarias__c = 'Test 1';
        caseExt.SPV_MotivoDevolucionRectificacion__c = 'SPV_001';
        caseExt.SPV_ObservacionDevolucionRectificacion__c = 'Test 1';
        caseExt.SPV_FechaEnvioOrganismoRectificacion__c = CBK_UtilsDate.todayDT();
        caseExt.SPV_FechaPteRespuestaOrganismo__c = CBK_UtilsDate.todayDT();
        caseExt.SPV_FechaAnulacionProrroga__c = CBK_UtilsDate.todayDT();
        List<CBK_Case_Extension__c> listaResult = new List<CBK_Case_Extension__c>();

        System.runAs(usuario){
            
            Test.startTest();
            SPV_DatabaseDML.updateDML(caseExt, true);
            Test.stopTest();
            List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId =: reclamacion.Id];
            Assert.areEqual(feedItems.isEmpty(), false, 'No se han registrado actividades');
            
        }
    }
}