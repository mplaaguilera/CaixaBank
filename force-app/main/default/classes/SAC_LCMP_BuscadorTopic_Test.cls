/*****************************************************************
 * Name: SAC_LCMP_BuscadorTopic_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase sAC_BuscadorTopic
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US300439         Marcela Neira        10/12/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	18/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_LCMP_BuscadorTopic_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC_General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test1Rec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('OwnerId', usuarioGeneral.id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);

        Topic topic = new Topic(Name = 'SACTopic1');
        SAC_DatabaseDML.insertDML(topic, false);

        Topic topic2 = new Topic(Name = 'SACTopic2');
        SAC_DatabaseDML.insertDML(topic2, false);

        TopicAssignment topicAssig = new TopicAssignment(TopicId=topic.Id, EntityId=casoReclamacion.Id);
        SAC_DatabaseDML.insertDML(topicAssig, false);

        SAC_MaestroTemas__c maestroT= new SAC_MaestroTemas__c(Name = 'SACTopic1', SAC_OrdenPrelacion__c = 1);
        maestroT.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_Temas').getRecordTypeId();
        SAC_DatabaseDML.insertDML(maestroT, false);

        SAC_MaestroTemas__c maestroT2= new SAC_MaestroTemas__c(Name = 'SACTopic2', SAC_OrdenPrelacion__c = 2);
        maestroT2.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_Temas').getRecordTypeId();
        SAC_DatabaseDML.insertDML(maestroT2, false);
    }

    @istest
    static void cargarDatosTest() {
        SAC_LCMP_BuscadorTopic.TopicsWrapper  tw;
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            tw = SAC_LCMP_BuscadorTopic.cargarDatos(usuario.id, caso.id);
        }
        Test.stopTest();

        Assert.areNotEqual(Null, tw, 'No ha devuelto los datos');
    }

    @istest
    static void getResultadosTest() {

        List<SAC_MaestroTemas__c> maestroTemas;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            maestroTemas = SAC_LCMP_BuscadorTopic.getResultados('Topic', caso.Id);
        }
        Test.stopTest();

        Assert.areNotEqual(null, maestroTemas, 'No se han obtenido resultados');
    }

    @istest
    static void newTopicTest() {

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Boolean insertado;
        Test.startTest();
        System.runAs(usuario) {
            insertado = SAC_LCMP_BuscadorTopic.newTopic('topic', caso.Id);
        }
        Test.stopTest();

        Assert.areEqual(false, insertado, 'No se ha podido crear el Topic');
    }

    @istest
    static void deleteTopicACaseTest() { 
        Boolean error = false;
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        Topic topic =[SELECT id FROM Topic WHERE Name = 'SACTopic1'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            try {
                SAC_LCMP_BuscadorTopic.deleteTopicACase(topic.id, caso.id);
            } catch (Exception e) {
                error = true;
            }
        }        
        Test.stopTest();

        Assert.areEqual(false, error, 'No se ha podido eliminar el Topic');
    }

    @istest
    static void setTopicACaseTest() {
        Boolean error = false;
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        Topic topic =[SELECT id, Name FROM Topic WHERE Name = 'SACTopic2'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            Test.startTest();            
            try {
                SAC_LCMP_BuscadorTopic.setTopicACase(caso.id, topic.Name);
            } catch (Exception e) {
                error = true;
            }  
            Test.stopTest();
        }
        Assert.areEqual(false, error, 'No se ha podido asignar el Topic');
    }

    @istest
    static void setTopicACaseTest2() {
        Boolean error = false;
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            Test.startTest();            
            try {
                SAC_LCMP_BuscadorTopic.setTopicACase(caso.id, 'SACTopic1');
            } catch (Exception e) {
                error = true;
            }  
            Test.stopTest();
        }
        Assert.areEqual(false, error, 'No se ha podido asignar el Topic');
    }

    @istest
    static void cargarEstadoTest() {
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caseEstado;
        
        System.runAs(usuario){
            Test.startTest();            
            caseEstado = SAC_LCMP_BuscadorTopic.cargarEstado(caso.id);
            Test.stopTest();
        }
        Assert.areNotEqual(null, caseEstado.Status, 'No se ha podido recuperar el estado de la reclamacion');
    }
}