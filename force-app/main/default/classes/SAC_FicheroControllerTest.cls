/*
* @description: SAC_FicheroController test class
* @author: iria.alvarez-novoa@ibm.com
* @date: august 2024
*/
@isTest
public class SAC_FicheroControllerTest {
    
    @testSetup
    static void setupData() {
        Id cops = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        // Account
        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        cuenta.CC_Tipo_Centro__c = 'DT';
        cuenta.CC_NumPerso__c = '123456789';
        Database.insert(cuenta);
        // Grupo colaborador
        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoColaboradorTest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
        grupos.add(grupoColaborador);
        Database.insert(grupos);
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
        usuarioGeneral.SAC_GruposPerteneciente__c = grupoColaborador.id;
        usuarioGeneral.isActive = true;
        usuarioGeneral.userRole = uRole; 
        insert usuarioGeneral;
        // Reclamación
        Case caso = new Case();
        caso.Subject = 'ReclamacionTest';
        caso.Status = 'Alta';
        caso.SAC_StatusAuxiliar__c = caso.Status;
        caso.SEG_Grupo__c = grupoColaborador.id;
        caso.AccountId = cuenta.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        caso.OwnerId = usuarioGeneral.Id;
        insert caso;
        // Ficheros
        SAC_Reclamacion_Hipotecaria__c testFichero1 = new SAC_Reclamacion_Hipotecaria__c(
            SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'SAC_Reclamacion_Hipotecaria__c' LIMIT 1].Id,
           	SAC_Codigo_Contrato__c = '000001', SAC_CNAE__c = 'CNAE TEST', SAC_Empleado__c = false,
            SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today()
        );
        SAC_Reclamacion_Hipotecaria__c testFichero2 = new SAC_Reclamacion_Hipotecaria__c(
            SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'SAC_Reclamacion_Hipotecaria__c' LIMIT 1].Id,
            SAC_Codigo_Contrato__c = '000001', SAC_CNAE__c = 'CNAE 99 PERSONAS FISICAS - CNAE No Standard', SAC_Empleado__c = true,
            SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today()
        );
        SAC_Reclamacion_Hipotecaria__c testFichero3 = new SAC_Reclamacion_Hipotecaria__c(
            SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'SAC_Reclamacion_Hipotecaria__c' LIMIT 1].Id,
            SAC_Codigo_Contrato__c = '000001', SAC_CNAE__c = 'CNAE 99 PERSONAS FISICAS - CNAE No Standard', SAC_Empleado__c = false,
            SAC_Provincia_centro_gestor__c = 'Barcelona', SAC_Fecha_cancelacion_real_prestamo__c = System.today()
        );
        SAC_Reclamacion_Hipotecaria__c testFichero4 = new SAC_Reclamacion_Hipotecaria__c(
            SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'SAC_Reclamacion_Hipotecaria__c' LIMIT 1].Id,
            SAC_Codigo_Contrato__c = '000001', SAC_CNAE__c = 'CNAE 99 PERSONAS FISICAS - CNAE No Standard', SAC_Empleado__c = false,
            SAC_Provincia_centro_gestor__c = 'Navarra', SAC_Fecha_cancelacion_real_prestamo__c = System.today()
        );
        SAC_Reclamacion_Hipotecaria__c testFichero5 = new SAC_Reclamacion_Hipotecaria__c(
            SAC_Id_persona_en_Origen__c = cuenta.CC_NumPerso__c,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'SAC_Reclamacion_Hipotecaria__c' LIMIT 1].Id,
            SAC_Codigo_Contrato__c = '000001', SAC_CNAE__c = 'CNAE 99 PERSONAS FISICAS - CNAE No Standard', SAC_Empleado__c = false,
            SAC_Provincia_centro_gestor__c = 'Madrid', SAC_Fecha_cancelacion_real_prestamo__c = System.today()
        );
        insert new List<SAC_Reclamacion_Hipotecaria__c>{testFichero1, testFichero2, testFichero3, testFichero4, testFichero5};
    }

    @isTest
    static void testGetFicherosByAccountIdWithAccount() {
        // Get Reclamación, User and Ficheros
        Case testCase = [SELECT Id FROM Case WHERE AccountId != null LIMIT 1];
        User usuario = [SELECT  Id FROM User WHERE USERNAME = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        Map<String, List<SAC_FicheroController.FicheroWrapper>> result = new  Map<String, List<SAC_FicheroController.FicheroWrapper>>();
        System.runAs(usuario){
            Test.startTest();
             result = SAC_FicheroController.getFicherosByAccountId(testCase.Id);
             //SAC_FicheroController.rejectReclamacion(testCase.Id);
             SAC_FicheroController.getRecStatus(testCase.Id);
            Test.stopTest();
        }
     

        // Asserts
        System.assert(result.size() > 0, 'El resultado debería contener entradas.');
        System.assertEquals(5, result.values()[0].size(), 'Debería haber 5 ficheros en el resultado.');
    }
}