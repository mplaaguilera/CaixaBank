@isTest
public with sharing class SPV_LCMP_ReclamacionesVinculadas_Test {
    private static Set<String> objetos = new Set<String>{'Case','CBK_CaseToCaseRelationship__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSIONSPV = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONSAC = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPECASORELACIONADOSPV = mapRTsObjects.get('CBK_CaseToCaseRelationship__c').get('SPV_CasoRelacionado').getRecordTypeId();


    @TestSetup
    static void makeData(){

        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            SPV_DatabaseDML.insertDML(usuarioGeneral, true);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SPV_DatabaseDML.insertDML(permiSetAssiAdmin, true);
        }
        Test.stopTest();

        //Accounts
        List <Account> listaCuentas = SAC_TestDataFactory.crearCuentas(2);
        listaCuentas[0].Name = 'Cuenta A';
        listaCuentas[0].Phone = '123456789';
        listaCuentas[0].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[0].billingStreet  = 'Calle Mayor 55';
        listaCuentas[0].BillingCountry = 'España';
        listaCuentas[0].CC_Numero_Documento__c = '66666666C';

        listaCuentas[1].Name = 'Cuenta B';
        listaCuentas[1].Phone = '123456789';
        listaCuentas[1].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[1].billingStreet  = 'Calle Mayor 55';
        listaCuentas[1].BillingCountry = 'España';
        listaCuentas[1].CC_Numero_Documento__c = '12345678C';
        SPV_DatabaseDML.insertListDML(listaCuentas, true);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Otros');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_TipoConsumidor__c', 'No');
        camposRecl2.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl2.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2); //Reclamacion SAC
        
        //Reclamaciones
        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(casoReclamacion);
        reclamaciones.add(casoReclamacion2);
        SPV_DatabaseDML.insertListDML(reclamaciones, true);

        //Reclamacion
        Map<String, Object> camposRec3 = new Map<String, Object>();
        camposRec3.put('Subject', 'TestRec3');
        camposRec3.put('Origin', 'Otros');
        camposRec3.put('Status', 'SAC_001');
        camposRec3.put('SAC_TipoConsumidor__c', 'No');
        camposRec3.put('SAC_Naturaleza__c', 'SAC_004');
        camposRec3.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRec3);
        SPV_DatabaseDML.insertDML(casoReclamacion3, true);


        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'testPret');
        camposPret.put('Origin', 'Otros');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret); //Pretension SAC

        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'testPret2');
        camposPret2.put('Origin', 'Otros');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret2.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension2 = SPV_TestDataFactory.crearCaso('Pretension',camposPret2); //Pretension SPV

        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'testPret3');
        camposPret3.put('Origin', 'Otros');
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        camposPret3.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension3 = SPV_TestDataFactory.crearCaso('Pretension',camposPret3); //Pretension SPV
        
        //Pretensiones
        List<Case> pretensiones = new List<Case>();
        pretensiones.add(casoPretension);
        pretensiones.add(casoPretension2);
        pretensiones.add(casoPretension3);
        SPV_DatabaseDML.insertListDML(pretensiones, true);

        //Producto pretension
        List<SAC_ProductCase__c> productos = new List<SAC_ProductCase__c>();
        SAC_ProductCase__c producto  = new SAC_ProductCase__c();
        producto.SAC_Pretension__c = casoPretension.Id;
        producto.SAC_Descripcion__c = 'Descripcion test';
        producto.N_Contrato__c = '111111';
        productos.add(producto);
        SAC_ProductCase__c producto2  = new SAC_ProductCase__c();
        producto2.SAC_Pretension__c = casoPretension2.Id;
        producto2.SAC_Descripcion__c = 'Descripcion test2';
        producto2.N_Contrato__c = '222222';
        productos.add(producto2);
        SPV_DatabaseDML.insertListDML(productos, true);

        //Caso vinculado
        CBK_CaseToCaseRelationship__c casoVinculado = new CBK_CaseToCaseRelationship__c();
        casoVinculado.SPV_CasoPadre__c = casoReclamacion3.Id;
        casoVinculado.SPV_CasoVinculado__c = casoReclamacion.Id;
        casoVinculado.RecordTypeId = RECTYPECASORELACIONADOSPV;
        SPV_DatabaseDML.insertDML(casoVinculado, true);

        //Reclamante
        List<SAC_CaseReclamante__c> reclamantes = new List<SAC_CaseReclamante__c>();
        SAC_CaseReclamante__c reclamante1 = new SAC_CaseReclamante__c();
        reclamante1.put('OwnerId', usuarioGeneral.Id);
        reclamante1.put('SAC_Account__c', listaCuentas[0].Id);
        reclamante1.put('SAC_Case__c', casoReclamacion.Id);
        reclamante1.put('SAC_ReclamantePrincipal__c', true);
        SAC_CaseReclamante__c reclamante2 = new SAC_CaseReclamante__c();
        reclamante2.put('OwnerId', usuarioGeneral.Id);
        reclamante2.put('SAC_Account__c', listaCuentas[0].Id);
        reclamante2.put('SAC_Case__c', casoReclamacion2.Id);
        reclamante2.put('SAC_ReclamantePrincipal__c', false);
        SAC_CaseReclamante__c reclamante3 = new SAC_CaseReclamante__c();
        reclamante3.put('OwnerId', usuarioGeneral.Id);
        reclamante3.put('SAC_Account__c', listaCuentas[1].Id);
        reclamante3.put('SAC_Case__c', casoReclamacion2.Id);
        reclamante3.put('SAC_ReclamantePrincipal__c', false);

        reclamantes.add(reclamante1);
        reclamantes.add(reclamante2);
        reclamantes.add(reclamante3);
        SPV_DatabaseDML.insertListDML(reclamantes, true);
    }

    @isTest
    static void getReclamacionesMismoReclamanteTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];

        List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper> listResultado = new List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper>();

        System.runAs(usuario1){
            Test.startTest();
            listResultado = SPV_LCMP_ReclamacionesVinculadas.getReclamacionesMismoReclamante(reclamacion.Id, 'SAC');
            Test.stopTest();
        }

        Assert.areNotEqual(null, listResultado, 'No se han recuperado reclamaciones con el mismo reclamante');
    }

    @isTest
    static void vincularReclamacion_TEST_SAC() {
        User u = [SELECT Id FROM User WHERE Username='useradmintest0@test.com.testSetup' LIMIT 1];
        Case recSPV = [SELECT Id FROM Case WHERE Subject='TestRec'  LIMIT 1];
        Case recSAC = [SELECT Id, RecordTypeId FROM Case WHERE Subject='TestRec2' LIMIT 1];

        // Asegurar RT SAC
        Id rtCaseSAC = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName='SAC_Reclamacion' LIMIT 1].Id;
        if (recSAC.RecordTypeId != rtCaseSAC) update new Case(Id=recSAC.Id, RecordTypeId=rtCaseSAC);

        // RecordType correcto de CBK_Case_Extension__c
        Id rtExt = [SELECT Id FROM RecordType WHERE SObjectType='CBK_Case_Extension__c' AND DeveloperName='SPV_ReclamacionCaseExt' LIMIT 1].Id;

        insert new CBK_Case_Extension__c(RecordTypeId = rtExt, Case_Id__c = recSAC.Id, SPV_TieneCasosVinculados__c = false);

        System.runAs(u){
            Test.startTest();
            SPV_LCMP_ReclamacionesVinculadas.vincularReclamacion(recSAC.Id, recSPV.Id);
            Test.stopTest();
        }

        List<CBK_CaseToCaseRelationship__c> listCasosVinculados = [SELECT Id FROM CBK_CaseToCaseRelationship__c WHERE SPV_CasoPadre__c = :recSPV.Id AND SPV_CasoVinculado__c = :recSAC.Id];
        Assert.areEqual(false, listCasosVinculados.isEmpty(), 'No se ha vinculado la reclamación correctamente');
    }

    @isTest
    static void vincularReclamacion_TEST_SPV() {
        User u = [SELECT Id FROM User WHERE Username='useradmintest0@test.com.testSetup' LIMIT 1];
        Case recSPV = [SELECT Id, RecordTypeId FROM Case WHERE Subject='TestRec'  LIMIT 1];
        Case recSAC = [SELECT Id FROM Case WHERE Subject='TestRec2' LIMIT 1];

        // --- Aseguramos que el caso vinculado es de RT SPV ---
        Id rtCaseSPV = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName='SPV_Reclamacion' LIMIT 1].Id;
        if (recSPV.RecordTypeId != rtCaseSPV) {
            update new Case(Id = recSPV.Id, RecordTypeId = rtCaseSPV);
        }

        // --- RecordType correcto de la extensión ---
        Id rtExt = [SELECT Id FROM RecordType WHERE SObjectType='CBK_Case_Extension__c' AND DeveloperName='SPV_ReclamacionCaseExt' LIMIT 1].Id;

        // Extensión del caso VINCULADO (SPV) con flag en false -> activará la rama SPV
        insert new CBK_Case_Extension__c(RecordTypeId = rtExt, Case_Id__c = recSPV.Id, SPV_TieneCasosVinculados__c = false);

        // Extensión del caso ACTUAL (SAC) para que el método lo encuentre en su query
        insert new CBK_Case_Extension__c(RecordTypeId = rtExt, Case_Id__c = recSAC.Id, SPV_TieneCasosVinculados__c = false);

        System.runAs(u){
            Test.startTest();
            // Ahora: idCasoVinculado = recSPV, idCasoActual = recSAC
            SPV_LCMP_ReclamacionesVinculadas.vincularReclamacion(recSPV.Id, recSAC.Id);
            Test.stopTest();
        }

        // --- Assert estilo original ---
        List<CBK_CaseToCaseRelationship__c> listCasosVinculados = [SELECT Id FROM CBK_CaseToCaseRelationship__c WHERE SPV_CasoPadre__c = :recSAC.Id AND SPV_CasoVinculado__c = :recSPV.Id];
        Assert.areEqual(false, listCasosVinculados.isEmpty(), 'No se ha vinculado la reclamación SPV correctamente');
    }



    @isTest
    static void desvincularReclamacionTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacionSPV = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec3'];
        Case reclamacionSPV2 = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];

        System.runAs(usuario1){
            Test.startTest();
            SPV_LCMP_ReclamacionesVinculadas.desvincularReclamacion(reclamacionSPV2.Id ,reclamacionSPV.Id);

            List<CBK_CaseToCaseRelationship__c> listCasosVinculados = [SELECT Id FROM CBK_CaseToCaseRelationship__c WHERE SPV_CasoPadre__c =: reclamacionSPV.Id AND SPV_CasoVinculado__c = :reclamacionSPV2.Id LIMIT 1];
            Assert.areEqual(true, listCasosVinculados.isEmpty(), 'No se ha vinculado la reclamacion correctamente');
            Test.stopTest();
        }
    }

    @isTest
    static void comprobarPermisosVinculacionTest2(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Case reclamacionSPV = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];
        Boolean permisos = false;

        System.runAs(usuario1){
            Test.startTest();
            permisos = SPV_LCMP_ReclamacionesVinculadas.comprobarPermisosVinculacion(reclamacionSPV.Id);
            Test.stopTest();
        }
        Assert.areEqual(false, permisos, 'No se ha desvinculado la reclamacion correctamente');
    }

    @isTest
    static void getReclamacionVinculadaTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id FROM Case WHERE Subject = 'TestRec'];
        List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper> listResultado = new List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper>();

        System.runAs(usuario1){
            Test.startTest();
            listResultado = SPV_LCMP_ReclamacionesVinculadas.getReclamacionesVinculadas(reclamacion.Id);
            Test.stopTest();
        }

        Assert.areNotEqual(null, listResultado, 'No se han recuperado reclamaciones con el mismo reclamante');
    }}