@isTest
public with sharing class SAC_LCMP_EmailRedaccion_Test {
    
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
            Map<String, Object> camposReclamacion = new Map<String, Object>();
            camposReclamacion.put('Subject', 'TestRec');
            camposReclamacion.put('Status', 'SAC_001');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclamacion);
            Database.insert(reclamacion);

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
    static void obtenerDatosEmail_Test(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_LCMP_EmailRedaccion.DatosEmailWrapper resultado;

        System.runAs(usuarioGeneral){
            Test.startTest();
            resultado = SAC_LCMP_EmailRedaccion.obtenerDatosEmail(reclamacion.Id);
            Test.stopTest();
        }
        System.assertEquals(resultado.caso.Id, reclamacion.Id, 'La ejecución de la clase wrapper ha fallado.' );
    }
}