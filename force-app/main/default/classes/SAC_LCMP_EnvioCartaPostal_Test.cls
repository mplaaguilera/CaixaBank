@isTest
public with sharing class SAC_LCMP_EnvioCartaPostal_Test {

    @TestSetup
    static void makeData(){

        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);


        System.runAs(usuarioGeneral){ 

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('SAC_NombreContacto__c', 'cuentaTest');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
            Database.insert(reclamacion);
            
            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'testPret');
            camposPret.put('Status', 'SAC_001');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);

            Case pretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
            Database.insert(pretension);

            // Plantilla
            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'SAC_Redaccion',
                //DeveloperName = 'SAC_Test',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = UserInfo.getUserId()
            );
            Database.insert(validEmailTemplate); 
        }
    }

    @isTest
    static void getInfoPostalTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_LCMP_EnvioCartaPostal.WrappedInfo myInfo;
        System.runAs(usuarioGeneral){
            Test.startTest();
            myInfo = SAC_LCMP_EnvioCartaPostal.getInfoPostal(caso.Id);
            Test.stopTest();
        }
        System.assertNotEquals(null, myInfo, 'La obtención de datos postales ha fallado en la primera parte');
        System.assertEquals('cuentaTest', myInfo.nombreTitular, 'La obtención de datos postales ha fallado en la segunda parte');
    }   

    @isTest
    static void getInfoPostalPretensionTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_LCMP_EnvioCartaPostal.WrappedInfo myInfo;

        System.runAs(usuarioGeneral){
            Test.startTest();
            myInfo = SAC_LCMP_EnvioCartaPostal.getInfoPostal(caso.Id);
            Test.stopTest();
        }
        System.assertNotEquals(null, myInfo, 'La obtención de datos postales ha fallado en la primera parte');
        System.assertEquals('cuentaTest', myInfo.nombreTitular, 'La obtención de datos postales ha fallado en la segunda parte');
    }   
}