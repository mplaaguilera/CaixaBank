/*****************************************************************
 * Name: SPV_LCMP_SeccionesInfoCualitativa
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SPV_LCMP_SeccionesInfoCualitativa
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US313245        Álex Polo          04/02/25     
*****************************************************************/
@isTest
public with sharing class SPV_LCMP_SeccionesInfoCualitativa_Test {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //Rt para el maestro de temas que es la información cualitativa en SPV
    private static final Id recTypeInfoCualitativa = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_InformacionCualitativa').getRecordTypeId();

    @TestSetup
    static void makeData(){
        
        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SPV General
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];     
            SPV_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SPV_DatabaseDML.insertDML(permiSetAssi, false);
        }


        //RECLAMACION
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test1Rec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case caso1 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SPV_DatabaseDML.insertDML(caso1, false);

        //Topic
        Topic topic = new Topic(Name = 'SPVTopic1');
        SPV_DatabaseDML.insertDML(topic, false);
        Topic topic2 = new Topic(Name = 'SPVTopic2');
        SPV_DatabaseDML.insertDML(topic2, false);

        TopicAssignment topicAssig = new TopicAssignment(TopicId=topic.Id, EntityId=caso1.Id);
        SPV_DatabaseDML.insertDML(topicAssig, false);

        SAC_MaestroTemas__c maestroT = new SAC_MaestroTemas__c();
        maestroT.Name = 'SPVTopic1';
        maestroT.RecordTypeId = recTypeInfoCualitativa;
        maestroT.SAC_Seccion__c = 'Test maestro InforCual';
        SPV_DatabaseDML.insertDML(maestroT, false);
    }

    @istest
    static void cargarDatosTest() {
        
        Map<String,List<SPV_LCMP_SeccionesInfoCualitativa.WrapperInfoCuali>> tw;
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];
        
        Test.startTest();
        System.runAs(usuario) {
            tw = SPV_LCMP_SeccionesInfoCualitativa.getSeccionesYInfoCualitativa(usuario.id, caso.id);
        }
        Test.stopTest();

        System.assertNotEquals(Null, tw, 'No ha devuelto los datos');
    }

    @istest
    static void setTopicACaseTest() {
        List<String> listaTopicParaCase = new List<String>{'SPVTopic', 'SPVTopic3'};
        Case caso= [SELECT id, OwnerId  FROM Case WHERE Subject = 'Test1Rec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];
        
        Test.startTest();
        System.runAs(usuario) {
        	SPV_LCMP_SeccionesInfoCualitativa.setTopicACase(caso.id, listaTopicParaCase);
        
        }
        Test.stopTest();

        System.assertNotEquals(0,[SELECT Count() FROM TopicAssignment WHERE EntityId =: caso.id], 'No se han asignado los temas al caso');
    }


}