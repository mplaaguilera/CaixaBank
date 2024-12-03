/*****************************************************************
 * Name: SAC_LCMP_InformacionCualitativa_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_InformacionCualitativa
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US313245         Marcela Neira        25/01/22     Creación
 * 1.1            US593664         Jose Carlos Blanco  	09/05/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_InformacionCualitativa_Test {
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        //RECLAMACION
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test1Rec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case caso1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(caso1);

        //Topic
        Topic topic = new Topic(Name = 'SACTopic1');
        Database.insert(topic);
        Topic topic2 = new Topic(Name = 'SACTopic2');
        Database.insert(topic2);

        TopicAssignment topicAssig = new TopicAssignment(TopicId=topic.Id, EntityId=caso1.Id);
        Database.insert(topicAssig);

        SAC_MaestroTemas__c maestroT = SAC_TestDataFactory.crearMaestroTemas(1, 'SAC_InformacionCualitativa')[0];
        Database.insert(maestroT);

    }
    @istest
    static void cargarDatosTest() {
        
        Map<String,List<SAC_LCMP_InformacionCualitativa.WrapperInfoCuali>> tw;
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Test.startTest();
        System.runAs(usuario) {
            tw = SAC_LCMP_InformacionCualitativa.cargarDatosOCS(usuario.id, caso.id);
        }
        Test.stopTest();

        System.assertNotEquals(Null, tw, 'No ha devuelto los datos');
    }
    @istest
    static void setTopicACaseTest() {
        List<String> listaTopicParaCase = new List<String>{'SACTopic', 'SACTopic3'};
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
		List<TopicAssignment> taCaso;
        Test.startTest();
        System.runAs(usuario) {
        	SAC_LCMP_InformacionCualitativa.setTopicACase(caso.id, listaTopicParaCase);
        
        	taCaso = [SELECT id FROM TopicAssignment WHERE EntityId =: caso.id];
        }
        Test.stopTest();

        System.assertEquals(listaTopicParaCase.size() + 1, taCaso.size(), 'No se han asignado los temas al caso');
    }
}