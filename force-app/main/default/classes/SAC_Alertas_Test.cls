@isTest
public with sharing class SAC_Alertas_Test {
    @TestSetup
    static void makeData(){
     
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);       
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false); 
            //Database.insert(permiSetAssi);
        }

        //Reclamaciones
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false); 
        //Database.insert(reclamacion);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestPret');
        camposPret.put('SAC_Reclamacion__c', reclamacion.id);
        
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(pretension, false); 
        //Database.insert(pretension);

        //Contactos
        List<Contact> contactos = SAC_TestDataFactory.crearContacto(2,null);
        contactos[0].recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();
        contactos[0].FirstName = 'SAC';
        contactos[0].LastName = 'EXTERNOS';
        contactos[0].Email = 'externos@sac.caixabank.com';
        
        contactos[1].recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();
        contactos[1].FirstName = 'Rene';
        contactos[1].LastName = 'Descartes';
        contactos[1].Email = 'Descartes@existo.com';
        SAC_DatabaseDML.insertListDML(contactos, false); 
        //Database.insert(contactos);
        
        //Grupos
        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        grupoColaborador.SAC_PermiteConsultas__c = true;
        grupoColaborador.SAC_Externo__c = true;
        grupoColaborador.SAC_Email__c = 'test@email.com';
        grupoColaborador.SAC_Email2__c = 'test@email.com';
        grupoColaborador.SAC_Email3__c = 'test@email.com';
        SAC_DatabaseDML.insertDML(grupoColaborador, false); 
        //Database.insert(grupoColaborador);

        //Interaccion Consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Reclamacion__c', reclamacion.id);
        camposCons.put('SAC_GrupoColaborador__c', grupoColaborador.id);
        camposCons.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        SAC_DatabaseDML.insertDML(consulta, false); 
        //Database.insert(consulta);

        /*SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccionn(1,reclamacion.id,grupoColaborador.id)[0];
        consulta.SAC_Estado__c = 'SAC_PendienteRespuesta';
        Database.insert(consulta);*/
        
        //Tarea
        SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1,reclamacion,false)[0];
        //tarea.OwnerId = usuarioGeneral2.Id;
        SAC_DatabaseDML.insertDML(tarea, false); 
        //Database.insert(tarea);
    }

    @isTest
    static void generarAlertasTest() {
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(reclamacion.Id,
                                                            'SAC_019',
                                                            'mensaje test',
                                                            reclamacion.OwnerId,
                                                            '',
                                                            '',
                                                            '');
        listaWrapperAlerta.add(wrapAlerta);

        Test.startTest();
        System.runAs(usuario){
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
        Test.stopTest();

        System.assertNotEquals(null, wrapAlerta, 'No se ha podido pasar por la generación de alerta');
    }
    
    @isTest
    static void alertaEnviarEmailsTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		Case pretension = [SELECT Id, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId FROM Case WHERE Subject = 'TestPret'];
        SAC_Accion__c tarea = [SELECT ID FROM SAC_Accion__c LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT ID, SAC_Reclamacion__c FROM SAC_Interaccion__c LIMIT 1];
        
        Map<Id, Group> mapaColas = new Map<Id, Group>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        List<String> listaEmailsExt = new List<String>();
        listaEmailsExt.add('testsac@testsaC.testsac1');
        listaEmailsExt.add('testsac@testsaC.testsac2');
        list<string> listaEmailsInt = new list<string>();
        listaEmailsInt.add('descartes@existo.com');
        //Alerta 1 sin lista emails
        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                            'SAC_019',
                                                            'mensaje test',
                                                            pretension.SAC_Reclamacion__r.OwnerId,
                                                            '',
                                                            '',
                                                            '');
        listaWrapperAlerta.add(wrapAlerta);

        //Alerta 2 con lista emails
        SAC_WrapperAlerta wrapAlerta2 = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                            'SAC_019',
                                                            'mensaje test',
                                                            pretension.SAC_Reclamacion__r.OwnerId,
                                                            '',
                                                            '',
                                                            '');
                                                            wrapAlerta2.listaEmailsGrupo = listaEmailsInt;
        listaWrapperAlerta.add(wrapAlerta2);
        
         //Alerta 3 con lista emails
        SAC_WrapperAlerta wrapAlerta3 = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                            'SAC_ConsultaPdteRespuesta24int',
                                                            '',
                                                            '',
                                                            '',
                                                            '',
                                                            consulta.id);
                                                            wrapAlerta3.listaEmailsGrupo = listaEmailsInt;
        listaWrapperAlerta.add(wrapAlerta3);
        
         //Alerta 4 con lista emails
        SAC_WrapperAlerta wrapAlerta4 = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                            'SAC_013',
                                                            'mensaje test',
                                                            '',
                                                            pretension.id,
                                                            '',
                                                            '');
                                                            wrapAlerta4.listaEmailsGrupo = listaEmailsExt;
        listaWrapperAlerta.add(wrapAlerta4);
        
         //Alerta 5 con lista emails
        SAC_WrapperAlerta wrapAlerta5 = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                            'SAC_004',
                                                            'mensaje test',
                                                            '',
                                                            '',
                                                            tarea.id,
                                                            '');
                                                            wrapAlerta5.listaEmailsGrupo = listaEmailsExt;
        listaWrapperAlerta.add(wrapAlerta5);

        Test.startTest();
        System.runAs(usuario){
            Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro = SAC_Alertas.buscarMaestros(listaWrapperAlerta);
            SAC_Alertas.alertaEnviarEmails(listaWrapperAlerta, mapaTipoMaestro, mapaColas);
            SAC_Alertas.generarAlertas(listaWrapperAlerta);

            System.assertNotEquals(null, mapaTipoMaestro, 'No se ha recuperado la info del maestro de tipologías para mandar email');    
        }
        Test.stopTest();  
    }
}