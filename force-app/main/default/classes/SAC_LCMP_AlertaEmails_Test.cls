@isTest
public with sharing class SAC_LCMP_AlertaEmails_Test {
    @TestSetup
    static void makeData(){
        // User
        List<User> listaUsuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        SAC_DatabaseDML.insertListDML(listaUsuarios, false);
        //Database.insert(listaUsuarios);

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = listaUsuarios[0].id);
        SAC_DatabaseDML.insertDML(psa, false);
        //Database.insert(psa);

        System.runAs(listaUsuarios[0]) {
            // Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRecl');
            
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion, false);
            //Database.insert(reclamacion);

            // Alerta
            List<SAC_Alerta__c> listaAlertas = SAC_TestDataFactory.crearAlerta(1, reclamacion.Id);
            SAC_DatabaseDML.insertListDML(listaAlertas, false);
            //Database.insert(listaAlertas);

            EmailMessage em  = new EmailMessage();
            em.relatedtoId = listaAlertas[0].Id;
            em.SAC_Alerta__c = listaAlertas[0].Id;
            em.Subject = 'emTest';
            SAC_DatabaseDML.insertDML(em, false);
            //Database.insert(em);
        }
    }

    @isTest
    static void getEmailMessagesByAlertaIdTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecl' LIMIT 1];
        List<EmailMessage> listaEM = new List<EmailMessage>();

        System.runAs(usuario) {
            listaEM = SAC_LCMP_AlertaEmails.getEmailMessagesByAlertaId(reclamacion.Id);
        }

        System.assertEquals(!listaEM.isEmpty(), true, 'No se han recuperado los emails');
    }
}