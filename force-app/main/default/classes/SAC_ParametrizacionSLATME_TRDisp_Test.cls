@isTest
public with sharing class SAC_ParametrizacionSLATME_TRDisp_Test {
    private static Id RECTYPE_TME = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_TME').getRecordTypeId();
    
 	@TestSetup
    static void setup(){
        User usuario;
        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        System.runAs(usuarioAdmin) {
            List<User> usuariosGenerales = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
            usuariosGenerales[0].Username = 'Name12345@test.com';            
            usuario = usuariosGenerales[0];
            Database.insert(usuariosGenerales);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }
}
    
    @isTest
    static void beforeInsert(){
        //SAC_ParametrizacionSLATME__c
        List<SAC_ParametrizacionSLATME__c> listaParametrizacionSLATME = new List<SAC_ParametrizacionSLATME__c>();

        SAC_ParametrizacionSLATME__c registro = new SAC_ParametrizacionSLATME__c();
        registro.RecordTypeId = RECTYPE_TME;
        registro.SAC_CanalProcedencia__c = 'Castilla la Mancha';
        registro.Name = 'Test';
        registro.SAC_Duracion__c = 12;
        listaParametrizacionSLATME.add(registro);

        SAC_DatabaseDML.insertListDML(listaParametrizacionSLATME, false);
        
        SAC_ParametrizacionSLATME__c result = [SELECT Id, SAC_CanalProcedencia__c FROM SAC_ParametrizacionSLATME__c WHERE RecordTypeId = :RECTYPE_TME AND Name = 'Test' AND SAC_CanalProcedencia__c = 'Castilla la Mancha' LIMIT 1];
        Assert.areNotEqual(null, result, 'No se ha añadido el registro correctamente.');
    }
    
    @isTest
    static void beforeUpdate(){
        //SAC_ParametrizacionSLATME__c
        List<SAC_ParametrizacionSLATME__c> listaParametrizacionSLATME = new List<SAC_ParametrizacionSLATME__c>();

        SAC_ParametrizacionSLATME__c registro = new SAC_ParametrizacionSLATME__c();
        registro.RecordTypeId = RECTYPE_TME;
        registro.SAC_CanalProcedencia__c = 'Castilla la Mancha';
        registro.Name = 'Test';
        registro.SAC_Duracion__c = 12;
        listaParametrizacionSLATME.add(registro);

        SAC_DatabaseDML.insertListDML(listaParametrizacionSLATME, false);
        
        //Se cambia un valor para actualizar la entrada
        registro.SAC_CanalProcedencia__c = 'Junta Andalucia';
        SAC_DatabaseDML.updateListDML(listaParametrizacionSLATME, false);
        
        SAC_ParametrizacionSLATME__c result = [SELECT Id, SAC_CanalProcedencia__c FROM SAC_ParametrizacionSLATME__c WHERE RecordTypeId = :RECTYPE_TME AND Name = 'Test' AND SAC_CanalProcedencia__c = 'Junta Andalucia' LIMIT 1];
        Assert.areNotEqual(null, result, 'No se ha actualizado el registro correctamente.');
    }
}