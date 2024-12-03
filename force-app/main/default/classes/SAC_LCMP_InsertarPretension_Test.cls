@isTest
public with sharing class SAC_LCMP_InsertarPretension_Test {
    
    @TestSetup
    static void makeData() {

        User usuario;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            Database.insert(usuario);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        List<Case> listaReclamaciones = new List<Case>(); 
        //RECLAMACION
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_002');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposRecl2.put('OwnerId', usuario.Id);

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

        Database.insert(listaReclamaciones);


        List<Case> listaPretensiones = new List<Case>();
        //PRETENSION
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pret1');
        camposPret.put('OwnerId', usuario.Id);

        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(pretension);

        //PRETENSION 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret2.put('Status', casoReclamacion.Status);
        camposPret2.put('SAC_StatusAuxiliar__c', casoReclamacion.Status);
        camposPret2.put('Origin', casoReclamacion.Origin);
        camposPret2.put('SAC_TiempoSLARegulatorio__c', 30);
        camposPret2.put('SAC_TiempoSLALetradoAlta__c', 30);
        camposPret2.put('CC_No_Identificado__c', true);
        camposPret2.put('CC_IdentCliente__c', '0');
        camposPret2.put('OwnerId', usuario.id);

        Case nuevaPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
        listaPretensiones.add(nuevaPretension);

        Database.insert(listaPretensiones); 
        
        //MCCs
        String mccTematicaRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        String mccProdServRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        String mccMotivoRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        String mccDetalleRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        
        CC_MCC__c mccTematica = new CC_MCC__c(Name='Tematica', CC_Codigo_Externo__c='a', RecordTypeId=mccTematicaRecordTypeId, CC_Tipo_Cliente__c='SAC');
        Database.insert(mccTematica);

        CC_MCC__c mccProdServ = new CC_MCC__c(Name='ProdServ',CC_Tematica__c = mccTematica.id , CC_Codigo_Externo__c='b', RecordTypeId=mccProdServRecordTypeId, CC_Tipo_Cliente__c='SAC');
        Database.insert(mccProdServ);

        CC_MCC__c mccMotivo = new CC_MCC__c(Name='Motivo',CC_Producto_Servicio__c = mccProdServ.id, CC_Codigo_Externo__c='c', RecordTypeId=mccMotivoRecordTypeId, CC_Tipo_Cliente__c='SAC');
        Database.insert(mccMotivo);

        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Detalle',CC_Motivo__c = mccMotivo.id, CC_Codigo_Externo__c='d', RecordTypeId=mccDetalleRecordTypeId, CC_Tipo_Cliente__c='SAC');
        Database.insert(mccDetalle);
    }

    @isTest 
    static void tienePermisosTest() {
        Boolean respuesta=false;
        Case reclamacion = [SELECT id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.debug('reclamacion---->' + reclamacion);
        System.runAs(usuario){
            Test.startTest();
            respuesta = SAC_LCMP_InsertarPretension.tienePermisos(reclamacion.id);
            Test.stopTest();
        }
        System.assertEquals(true, respuesta, 'No tiene permisos para insertar una pretensión/consulta(Interacción).');  
    }
    
    @isTest 
    static void recuperarCasoTest() {
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Case respuesta;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            respuesta = SAC_LCMP_InsertarPretension.recuperarCaso(casoReclamacion.id);
            Test.stopTest();
        }
        System.assertEquals( casoReclamacion.Id, respuesta.Id, 'No se ha podido recuperar la información del caso.');  
    }
    
    @isTest
    static void insertarPretensionesAltaTest(){
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        CC_MCC__c mccsRepetido = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle' LIMIT 1];
        mccs.add(mccsRepetido);
        Boolean respuesta = false;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            respuesta = SAC_LCMP_InsertarPretension.insertarPretensiones(casoReclamacion.id, mccs);
            Test.stopTest();
        }
        System.assertEquals( true, respuesta, 'No se han insertado las pretensiones');
    }
    
    @isTest
    static void insertarPretensionesAnalisisTest(){
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        CC_MCC__c mccsRepetido = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle' LIMIT 1];
        mccs.add(mccsRepetido);
        Boolean respuesta = false;
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE subject = 'TestRec2' LIMIT 1];
        Case pretension = [SELECT Id, OwnerId FROM Case WHERE SuppliedCompany = 'pret1' LIMIT 1];
        String idRec = reclamacion.Id; 
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            reclamacion.SAC_PretensionPrincipal__c = pretension.Id;
            Database.update(reclamacion);
            respuesta = SAC_LCMP_InsertarPretension.insertarPretensiones(reclamacion.id, mccs);
            Test.stopTest();
        }
		System.assertEquals( true, respuesta, 'No se han insertado las pretensiones');        
    }
    
    @isTest
    static void initInsertarPretensionTest(){
        SAC_LCMP_InsertarPretension.WrapperPretension wp;
        Case casoReclamacion = [SELECT id, Status, Origin FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            wp = SAC_LCMP_InsertarPretension.initInsertarPretension(casoReclamacion.id);
            Test.stopTest();
        }
        System.assertEquals(wp.caso.id, casoReclamacion.id, ' no se ha devuelto el objeto wrapper');  
    }

    @isTest
    static void throwAuraHandledExceptionTest(){

        Boolean error = false;

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            try {
                SAC_LCMP_InsertarPretension.throwAuraHandledException('Mensaje de error');
            } catch (Exception e) {
                error = true;
            }
        }
        System.assertEquals(true, error, 'El error no ha saltado.');
    }

    @isTest
    static void insertarPretensionPrincipal(){
        Case casoReclamacion = [SELECT id, Status, Origin, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        List<CC_MCC__c> mccs = [SELECT id, Name FROM CC_MCC__c WHERE Name='Detalle'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_InsertarPretension.insertarPretensionPrincipal(casoReclamacion.id, mccs);
            Test.stopTest();
        }
        Case casoReclamacionAct = [SELECT id, Status, Origin, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Case pretension = [SELECT Id, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c =:casoReclamacion.id];
        System.assertEquals(pretension.id, casoReclamacionAct.SAC_PretensionPrincipal__c, 'No se ha insertado la pretensión como principal.');
        System.assertEquals(pretension.SAC_Reclamacion__c, casoReclamacionAct.id, 'No se ha insertado la pretensión como principal.');
    }
}