@isTest
public with sharing class SAC_LCMP_EmailRedaccion_Test {
    
    @TestSetup
    static void makeData(){
        
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];  
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);    
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposReclamacion = new Map<String, Object>();
            camposReclamacion.put('Subject', 'TestRec');
            camposReclamacion.put('Status', 'SAC_001');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclamacion);
            SAC_DatabaseDML.insertDML(reclamacion, false);  
            //Database.insert(reclamacion);

            // Plantilla
            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'SAC_Redaccion',
                DeveloperName = 'SAC_Testeo',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = UserInfo.getUserId()
            );
            SAC_DatabaseDML.insertDML(validEmailTemplate, false);
            //Database.insert(validEmailTemplate); 
        }
    }

    @isTest
    static void obtenerDatosEmailTest(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_LCMP_EmailRedaccion.DatosEmailWrapper resultado;
        EmailTemplate validEmailTemplate = [SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_Redaccion' LIMIT 1]; 
        System.debug('La recla ' + reclamacion);
        System.debug('template ' + validEmailTemplate);
        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_EmailRedaccion.obtenerDatosEmail(reclamacion.Id);
            Test.stopTest();
        }
        System.assertEquals(resultado.caso.Id, reclamacion.Id, 'La ejecución de la clase wrapper ha fallado.' );
    }
}