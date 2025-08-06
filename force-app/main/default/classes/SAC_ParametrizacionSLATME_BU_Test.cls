@isTest
public with sharing class SAC_ParametrizacionSLATME_BU_Test {
   
    @TestSetup
    static void makeData(){
        
        User usuario;
        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);
        

        System.runAs(usuarioAdmin) {
            List<User> usuariosGenerales = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
            usuariosGenerales[0].Username = 'Name12345@test.com';            
            usuario = usuariosGenerales[0];
            
            SAC_DatabaseDML.insertListDML(usuariosGenerales, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;

            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        //Record Types MCC
        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        
        //Record Types SAC_ParametrizacionSLATME__c
        Id recTypeTme = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_TME').getRecordTypeId();

        //MCCs
        List<CC_MCC__c> listaMCCsTematica = new List<CC_MCC__c>();
        List<CC_MCC__c> listaMCCsProductoServicio = new List<CC_MCC__c>();
        List<CC_MCC__c> listaMCCsMotivo = new List<CC_MCC__c>();
        List<CC_MCC__c> listaMCCsDetalle= new List<CC_MCC__c>();

        //Insertar MCCs Temática
        CC_MCC__c mccTematica = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Avales',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Codigo_Externo__c = 'TEST-0101'
        );
        listaMCCsTematica.add(mccTematica);


        SAC_DatabaseDML.insertListDML(listaMCCsTematica, false);


        //Insertar MCCs Prooducto Servicio
        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica.id);
        listaMCCsProductoServicio.add(mccProdServ1);


        SAC_DatabaseDML.insertListDML(listaMCCsProductoServicio, false);


        //Insertar MCCs Motivo
        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102');
        listaMCCsMotivo.add(mccMotivo1);


        SAC_DatabaseDML.insertListDML(listaMCCsMotivo, false);



        //Insertar MCCs Detalle
        CC_MCC__c mccDetalle1 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id);
        listaMCCsDetalle.add(mccDetalle1);


        SAC_DatabaseDML.insertListDML(listaMCCsDetalle, false);



        //SAC_ParametrizacionSLATME__c
        List<SAC_ParametrizacionSLATME__c> listaParametrizacionSLATME = new List<SAC_ParametrizacionSLATME__c>();

        SAC_ParametrizacionSLATME__c registro = new SAC_ParametrizacionSLATME__c();
        registro.RecordTypeId = recTypeTme;
        registro.SAC_MCC__c = mccDetalle1.Id;
        registro.SAC_CanalProcedencia__c = 'Castilla la Mancha';
        registro.Name = 'Test';
        registro.SAC_Duracion__c = 12;
        listaParametrizacionSLATME.add(registro);

        SAC_DatabaseDML.insertListDML(listaParametrizacionSLATME, false);


        Test.stopTest();
    }


    @isTest
    static void comprobarTMEDuplicadoUpdateTest(){

        Id recTypeTme = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_TME').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        SAC_ParametrizacionSLATME__c parametrizacion = [SELECT Id, SAC_DuplicadoMCCProcedenciaEstado__c, RecordTypeId, SAC_MCC__c, SAC_CanalProcedencia__c, SAC_Estados__c, Name FROM SAC_ParametrizacionSLATME__c WHERE RecordTypeId = :recTypeTme AND Name = 'Test' LIMIT 1];

        Test.startTest();

        System.runAs(usuario){
            List<SAC_ParametrizacionSLATME__c> listaUpdate = new List<SAC_ParametrizacionSLATME__c>();

            parametrizacion.SAC_Estados__c  = 'SAC_001;SAC_002;SAC_003;SAC_004;SAC_006;SAC_007;SPV_ENVIO;SPV_ENVIOCOMPLEMENTARIA;SPV_RECEPCIONRESOLUCION;SPV_ANALISISCOMPLEMENTARIAORGANISMO;SPV_ANALISISDECISION;SPV_RECTIFICACION;SPV_ENVIORECTIFICACION';
            parametrizacion.SAC_CanalProcedencia__c = 'Junta Andalucia';
            listaUpdate.add(parametrizacion);

            SAC_DatabaseDML.updateListDML(listaUpdate, false);

        }

        SAC_ParametrizacionSLATME__c result = [SELECT Id,SAC_DuplicadoMCCProcedenciaEstado__c FROM SAC_ParametrizacionSLATME__c WHERE RecordTypeId = :recTypeTme AND Name = 'Test' LIMIT 1];
        Assert.areNotEqual(null, result.SAC_DuplicadoMCCProcedenciaEstado__c, 'No se ha añadido el registro correctamente.');

        Test.stopTest();
    }

}