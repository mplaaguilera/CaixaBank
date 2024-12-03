/*****************************************************************
 * Name: SAC_MCC_AI_TRHan_Test
 * Copyright © 2021  CaixaBank
 *  
 * Proposito: Test para la clase SAC_MCC_AI_TRHan
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US515086  	   Sergio Martín        07/02/23     Creación
 * 1.1            US643756         Jose Carlos Blanco  	04/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_MCC_AI_TRHan_Test {
    @TestSetup
    static void makeData(){
        String mccTematicaRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        String mccProdServRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        String mccMotivoRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();


        CC_MCC__c mccTematica = new CC_MCC__c(Name='Tematica', CC_Codigo_Externo__c='a', RecordTypeId=mccTematicaRecordTypeId, CC_Tipo_Cliente__c='Empleado');

        CC_MCC__c mccProdServ = new CC_MCC__c(Name='ProdServ',CC_Tematica__c = mccTematica.id , CC_Codigo_Externo__c='b', RecordTypeId=mccProdServRecordTypeId, CC_Tipo_Cliente__c='Cliente');

        CC_MCC__c mccMotivo = new CC_MCC__c(Name='Motivo',CC_Producto_Servicio__c = mccProdServ.id, CC_Codigo_Externo__c='c', RecordTypeId=mccMotivoRecordTypeId, CC_Tipo_Cliente__c='Cliente');

        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        listaMCCs.add(mccTematica);
        listaMCCs.add(mccProdServ);
        listaMCCs.add(mccMotivo);
        Database.insert(listaMCCs);

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            Database.insert(usuarioGeneral);
        }
    }

    @isTest
    static void asignacionParametrizacionSLATME_Test() { 
        String recordTypeIdMCCDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        Id rtMaestro = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_Maestro').getRecordTypeId();

        CC_MCC__c mccMotivo = [SELECT id FROM CC_Mcc__c WHERE CC_Codigo_Externo__c='c' LIMIT 1];
        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Banca Electrónica', CC_Codigo_Externo__c='d', RecordTypeId=recordTypeIdMCCDetalle, CC_Tipo_Cliente__c='SAC');

        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
		PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);

        PermissionSet ps2 = [select id from PermissionSet where PermissionSet.Label ='SAC_Administrador'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuario.id);
        Database.insert(psa2);
        
        System.runAs(usuario) {
            SAC_ParametrizacionSLATME__c parametrizacion1 = new SAC_ParametrizacionSLATME__c (Name = 'Test Regulatorio Junta Andalucía', SAC_Duracion__c = 10 , SAC_CanalProcedencia__c = 'Junta Andalucia', RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion2 = new SAC_ParametrizacionSLATME__c (Name = 'Test Letrado Junta Andalucía', SAC_Duracion__c = 5 , SAC_CanalProcedencia__c = 'Junta Andalucia', RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion3 = new SAC_ParametrizacionSLATME__c (Name = 'TestAlta Junta Andalucía', SAC_Duracion__c = 1 , SAC_CanalProcedencia__c = 'Junta Andalucia', RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion4 = new SAC_ParametrizacionSLATME__c (Name = 'Test Regulatorio', SAC_Duracion__c = 30 , RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion5 = new SAC_ParametrizacionSLATME__c (Name = 'Test Alta', SAC_Duracion__c = 1 , RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion6 = new SAC_ParametrizacionSLATME__c (Name = 'Test Letrado', SAC_Duracion__c = 15 , RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion7 = new SAC_ParametrizacionSLATME__c (Name = 'Test Regulatorio Castilla La Mancha', SAC_Duracion__c = 10 , SAC_CanalProcedencia__c = 'Castilla La Mancha', RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion8 = new SAC_ParametrizacionSLATME__c (Name = 'Test Letrado Castilla La Mancha', SAC_Duracion__c = 5 , SAC_CanalProcedencia__c = 'Castilla La Mancha', RecordTypeId = rtMaestro);
            SAC_ParametrizacionSLATME__c parametrizacion9 = new SAC_ParametrizacionSLATME__c (Name = 'Test Alta Castilla La Mancha', SAC_Duracion__c = 1 , SAC_CanalProcedencia__c = 'Castilla La Mancha', RecordTypeId = rtMaestro);
            
            List<SAC_ParametrizacionSLATME__c> listaParametrizaciones = new List<SAC_ParametrizacionSLATME__c>();
            listaParametrizaciones.add(parametrizacion1);
            listaParametrizaciones.add(parametrizacion2);
            listaParametrizaciones.add(parametrizacion3);
            listaParametrizaciones.add(parametrizacion4);
            listaParametrizaciones.add(parametrizacion5);
            listaParametrizaciones.add(parametrizacion6);
            listaParametrizaciones.add(parametrizacion7);
            listaParametrizaciones.add(parametrizacion8);
            listaParametrizaciones.add(parametrizacion9);
            Database.insert(listaParametrizaciones);

            Database.insert(mccDetalle);
            Database.update(mccDetalle);
        }   
        Test.stopTest();

        List<SAC_ParametrizacionSLATME__c> lstParametrizaciones = [SELECT Id, name, SAC_Duracion__c, SAC_CanalProcedencia__c FROM SAC_ParametrizacionSLATME__c WHERE RecordType.id =: rtMaestro];
        
        // Se comprueban si se han insertado las 9 parametrizaciones con Record Type "Maestro"
        List<SAC_ParametrizacionSLATME__c> parametrizacionesInsertadas = [SELECT id FROM SAC_ParametrizacionSLATME__c WHERE SAC_MCC__c =: mccDetalle.id];
        System.assertEquals(lstParametrizaciones.size(), parametrizacionesInsertadas.size(), 'No se han insertado todas la parametrizaciones.');      
    }
}