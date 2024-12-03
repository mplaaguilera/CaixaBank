/*
* @description: SAC_PrestamoRelacionSchedulableTest test class for SAC_PrestamoRelacionSchedulable
* @author: iria.alvarez.novoa@ibm.com
* @date: october 2024
*/
@isTest
public class SAC_PrestamoRelacionSchedulableTest {
    @testSetup
    static void setupData() {
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        // Grupo colaborador
        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoColaboradorTest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
        grupos.add(grupoColaborador);
        insert grupos;
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
    }
    @isTest
    static void testExecute() {
        User usuario = [SELECT Id FROM User WHERE Username = 'userSACgeneral01@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            SAC_PrestamoRelacionSchedulable sched = new SAC_PrestamoRelacionSchedulable();
            sched.execute(null);
            
            Test.stopTest();
            List<SAC_Prestamo__c> prestamoList = [SELECT Id, SAC_Id_cuenta_actual__c, SAC_Codigo_Contrato__c FROM SAC_Prestamo__c];
            System.assertEquals(false, !prestamoList.isEmpty(), 'No se encontraron préstamos después de ejecutar el schedulable.');
        }
    }
}