@isTest
public with sharing class SPV_LCMP_ReclamacionesVinculadas_Test {
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSIONSPV = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONSAC = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();


    @TestSetup
    static void makeData(){

        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
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
        Database.insert(listaCuentas);

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
        Database.insert(reclamaciones);

        //Reclamacion
        Map<String, Object> camposRec3 = new Map<String, Object>();
        camposRec3.put('Subject', 'TestRec3');
        camposRec3.put('Origin', 'Otros');
        camposRec3.put('Status', 'SAC_001');
        camposRec3.put('SAC_TipoConsumidor__c', 'No');
        camposRec3.put('SAC_Naturaleza__c', 'SAC_004');
        camposRec3.put('OwnerId', usuarioGeneral.Id);
        camposRec3.put('CC_CasoRelacionado__c', casoReclamacion2.Id);

        Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRec3);
        Database.insert(casoReclamacion3);


        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'testPret');
        camposPret.put('Origin', 'Otros');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret); //Pretension SAC
        
        //Pretensiones
        List<Case> pretensiones = new List<Case>();
        pretensiones.add(casoPretension);
        Database.insert(pretensiones);


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
        Database.insert(reclamantes);
    }

    @isTest
    static void getReclamacionesMismoReclamanteTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];

        List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper> listResultado = new List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper>();

        System.runAs(usuario1){
            Test.startTest();
            listResultado = SPV_LCMP_ReclamacionesVinculadas.getReclamacionesMismoReclamante(reclamacion.Id);
            Test.stopTest();
        }

        Assert.areNotEqual(null, listResultado, 'No se han recuperado reclamaciones con el mismo reclamante');
    }

    @isTest
    static void vincularReclamacionTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacionSPV = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];
        Case reclamacionSAC = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec2'];

        System.runAs(usuario1){
            Test.startTest();
            SPV_LCMP_ReclamacionesVinculadas.vincularReclamacion(reclamacionSAC.Id, reclamacionSPV.Id);
            Test.stopTest();
        }

        Case reclamacionSPV2 = [SELECT id, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
        Assert.areNotEqual(null, reclamacionSPV2.CC_CasoRelacionado__c, 'No se ha vinculado la reclamacion correctamente');
    }

    @isTest
    static void desvincularReclamacionTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacionSPV = [SELECT id, Ownerid, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec3'];

        System.runAs(usuario1){
            Test.startTest();
            SPV_LCMP_ReclamacionesVinculadas.desvincularReclamacion(reclamacionSPV.Id);
            Test.stopTest();
        }

        Case reclamacionSPV2 = [SELECT id, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
        Assert.areEqual(null, reclamacionSPV2.CC_CasoRelacionado__c, 'No se ha desvinculado la reclamacion correctamente');
    }

    // @isTest
    // static void comprobarPermisosVinculacionTest(){

    //     User usuario2 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

    //     Case reclamacionSPV = [SELECT id, Ownerid, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
    //     Boolean permisos = false;

    //     System.runAs(usuario2){
    //         Test.startTest();
    //         permisos = SPV_LCMP_ReclamacionesVinculadas.comprobarPermisosVinculacion(reclamacionSPV.Id);
    //         Test.stopTest();
    //     }

    //     Case reclamacionSPV2 = [SELECT id, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
    //     Assert.areEqual(false, permisos, 'No se ha desvinculado la reclamacion correctamente');
    // }

    @isTest
    static void comprobarPermisosVinculacionTest2(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Case reclamacionSPV = [SELECT id, Ownerid, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
        Boolean permisos = false;

        List<Case> listaCasos = [SELECT Id, Status, OwnerId, RecordTypeId, SAC_Reclamacion__r.OwnerId, SAC_PretensionPrincipal__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACIONSPV 
                                        AND Id = :reclamacionSPV.Id) OR (RecordTypeId = :RECTYPEPRETENSIONSPV AND SAC_Reclamacion__c = :reclamacionSPV.Id)];

        System.runAs(usuario1){
            Test.startTest();
            permisos = SPV_LCMP_ReclamacionesVinculadas.comprobarPermisosVinculacion(reclamacionSPV.Id);
            Test.stopTest();
        }

        Case reclamacionSPV2 = [SELECT id, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec'];
        Assert.areEqual(false, permisos, 'No se ha desvinculado la reclamacion correctamente');
    }

    @isTest
    static void getReclamacionVinculadaTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, CC_CasoRelacionado__c FROM Case WHERE Subject = 'TestRec3'];
        List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper> listResultado = new List<SPV_LCMP_ReclamacionesVinculadas.ReclamacionWrapper>();

        System.runAs(usuario1){
            Test.startTest();
            listResultado = SPV_LCMP_ReclamacionesVinculadas.getReclamacionVinculada(reclamacion.CC_CasoRelacionado__c);
            Test.stopTest();
        }

        Assert.areNotEqual(null, listResultado, 'No se han recuperado reclamaciones con el mismo reclamante');
    }}