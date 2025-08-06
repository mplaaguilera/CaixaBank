/*
* @description: SAC_Genial_ErrorProcesoIABatchTest for SAC_Genial_ErrorProcesoIABatch
* @author: iria.alvarez.novoa@ibm.com
* @date: june 2025
*/
@isTest
public class SAC_Genial_ErrorProcesoIABatchTest {

    @testSetup
    static void setupData() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        // User
        User usuarioGeneral = new User();
        usuarioGeneral.Username = 'userSACgeneral01@test.com';
        usuarioGeneral.Email = 'email@test.com';
        usuarioGeneral.LastName = 'usuarioGeneral Test';
        usuarioGeneral.ProfileId = profileId;
        usuarioGeneral.Alias = 'alias';
        usuarioGeneral.TimeZoneSidKey = 'GMT';
        usuarioGeneral.LocaleSidKey = 'es_ES';
        usuarioGeneral.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneral.LanguageLocaleKey = 'en_US';
        usuarioGeneral.isActive = true;
        usuarioGeneral.userRole = uRole; 
        insert usuarioGeneral;
        // Reclamación
        Case reclamacion = new Case();
        reclamacion.Subject = 'ReclamacionTest';
        reclamacion.Status = 'SAC_001';
        reclamacion.SAC_GenialEstado__c = 'SAC_001';
        reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
        reclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        reclamacion.OwnerId = usuarioGeneral.Id;
        reclamacion.SAC_FechaRecepcion__c = CBK_UtilsDate.nowDT();
        reclamacion.CC_Idioma__c = 'es';
        insert reclamacion; 
    }
    
    	@isTest
    static void checkList(){
        // El campo LastModifiedDate no se puede modificar, por lo que la query devolverá empty list. Entramos directamente al execute.
       	User usuario = [SELECT  Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        List<Case> caseList = [SELECT Id, SAC_GenialEstado__c FROM Case WHERE SAC_GenialEstado__c = 'SAC_001'];
        System.runAs(usuario){
            SAC_Genial_ErrorProcesoIABatch btch = new SAC_Genial_ErrorProcesoIABatch();
            Test.startTest();
            btch.execute(null, caseList);
            Test.stopTest();
        }
        // Asserts
        List<Case> result = [SELECT Id, SAC_GenialEstado__c FROM Case WHERE SAC_GenialEstado__c = 'SAC_008'];
        System.assertEquals(result.isEmpty(), false, 'No se han actualizado correctamente');
    }
    
	@isTest
    static void checkEmptyList(){
        // El campo LastModifiedDate no se puede modificar, por lo que la query devolverá empty list
       	User usuario = [SELECT  Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        List<Case> caseList = [SELECT Id, SAC_GenialEstado__c FROM Case WHERE SAC_GenialEstado__c = 'SAC_001'];
        System.runAs(usuario){
            SAC_Genial_ErrorProcesoIABatch btch = new SAC_Genial_ErrorProcesoIABatch();
            Test.startTest();
            Database.executeBatch(btch, 1);
            Test.stopTest();
        }
        // Asserts
        List<Case> result = [SELECT Id, SAC_GenialEstado__c FROM Case WHERE SAC_GenialEstado__c = 'SAC_008'];
        System.assertEquals(result.isEmpty(), true, 'Se han encontrado registros');
    }
}