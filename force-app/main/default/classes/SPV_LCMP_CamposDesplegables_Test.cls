/*****************************************************************
 * Name: SPV_LCMP_CamposDesplegables_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de los métodos de la clase correspondiente
 * 
****************************************************************/ 
/**
 * @description     Test de los métodos de la clase correspondiente
 */

@isTest
public with sharing class SPV_LCMP_CamposDesplegables_Test {

@TestSetup
static void makeData(){
    Test.startTest();

    User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
    SPV_DatabaseDML.insertDML(usuarioAdmin, true);

    List<User> listUsuarios = new List<User>();
    //Grupo
    CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();



    System.runAs(usuarioAdmin){
        listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
        SPV_DatabaseDML.insertListDML(listUsuarios, true);
    }

    System.runAs(listUsuarios[0]) {
        grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
        grupo.Name = 'grupotest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.OS_Negocio__c = 'SPV';
        grupo.SAC_DeveloperName__c = 'SPV_AJ';
        SPV_DatabaseDML.insertDML(grupo, true);
        //Database.insert(grupo);

    }



    //Reclamaciones
    List<Case> listaReclamaciones = new List<Case>();
    Map<String, Object> camposReclamacion1 = new Map<String, Object>();
    camposReclamacion1.put('Subject', 'TestRecCrearRec1');
    camposReclamacion1.put('SPV_Organismo__c', 'SPV_BDE');
    camposReclamacion1.put('Status', 'SAC_002');
    camposReclamacion1.put('SEG_Subestado__c', 'Negociacion');
    camposReclamacion1.put('OwnerId', usuarioAdmin.Id);

    Case reclamacion1 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion1);
    listaReclamaciones.add(reclamacion1);

    SPV_DatabaseDML.insertListDML(listaReclamaciones, true);


    //Escalados
    Map<String, Object> camposObj = new Map<String, Object>();
    List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();

    camposObj.clear();

    camposObj.put('SAC_CasoEscalado__c', reclamacion1.Id);
    camposObj.put('SAC_Titulo__c', 'testescalado1');
    camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
    camposObj.put('SAC_MotivoEscalado__c', 'SPV_Allanamiento');
    camposObj.put('SPV_TipoAllanamiento__c', 'SPV_Parcial');
    camposObj.put('SPV_MotivoAllanamiento__c', 'Test');
    camposObj.put('SPV_AnalisisAllanamiento__c', 'Test');
    camposObj.put('SPV_VerificacionesLetrado__c', 'Test');
    camposObj.put('SAC_Propuesta__c', 'Test');
    camposObj.put('SPV_TipoActuacion__c', 'SPV_Pago');
    camposObj.put('SPV_Importe__c', 1);
    camposObj.put('SPV_Imputable__c', 'SPV_Entidad');

    SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
    listaEscalados.add(escalado);

    SPV_DatabaseDML.insertListDML(listaEscalados, true);

    //Formularios negociación
    List<SPV_Formulario__c> lstFormNegociacion = new List<SPV_Formulario__c>();

    SPV_Formulario__c formNegociacionPrevia = new SPV_Formulario__c();
    formNegociacionPrevia.recordTypeId = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_FormularioNegociacion').getRecordTypeId();
    formNegociacionPrevia.SPV_EstadoNegociacion__c = 'SAC_002';
    formNegociacionPrevia.SPV_NegociacionEnCurso__c = true;
    formNegociacionPrevia.SPV_FechaInicioNegociacion__c = System.now();
    formNegociacionPrevia.SPV_Caso__c = reclamacion1.Id;
    lstFormNegociacion.add(formNegociacionPrevia);


    SPV_Formulario__c formNegociacionPosterior = new SPV_Formulario__c();
    formNegociacionPosterior.recordTypeId = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_FormularioNegociacion').getRecordTypeId();
    formNegociacionPosterior.SPV_EstadoNegociacion__c = 'SPV_Rectificacion';
    formNegociacionPosterior.SPV_NegociacionEnCurso__c = true;
    formNegociacionPosterior.SPV_FechaInicioNegociacion__c = System.now();
    formNegociacionPosterior.SPV_Caso__c = reclamacion1.Id;
    lstFormNegociacion.add(formNegociacionPosterior);
    
    SPV_DatabaseDML.insertListDML(lstFormNegociacion, true); 
    
    Test.stopTest();
    }


    @isTest
    static void getEscaladosReclamacionTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        Test.startTest();

        SAC_Interaccion__c escaladoResult = new SAC_Interaccion__c();
        System.runAs(usuario){
            
            SPV_LCMP_CamposDesplegables.EscaladosReclamacionWrapper resultado = SPV_LCMP_CamposDesplegables.getEscaladosReclamacion(reclamacion.Id);
            escaladoResult = resultado.escaladoAllanamiento;
            
        }

        Assert.areEqual('SPV_Allanamiento', escaladoResult.SAC_MotivoEscalado__c, 'No se han recuperado los escalados de la reclamación.');
        Test.stopTest();
    }

    @isTest
    static void getNegociacionesReclamacionTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        Test.startTest();

        Boolean existeNegociacionPreviaInforme = false;
        System.runAs(usuario){
            
            SPV_LCMP_CamposDesplegables.NegociacionesReclamacionWrapper resultado = SPV_LCMP_CamposDesplegables.getNegociacionesReclamacion(reclamacion.Id);
            existeNegociacionPreviaInforme = resultado.existeNegociacionPreviaInforme;  
        }

        Assert.areEqual(true, existeNegociacionPreviaInforme, 'No se han recuperado las negociaciones de la reclamación.');
        Test.stopTest();
    }
}