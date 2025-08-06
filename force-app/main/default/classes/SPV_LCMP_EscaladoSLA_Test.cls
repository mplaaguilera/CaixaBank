/*****************************************************************
* Name: SPV_LCMP_EscaladoSLA
* Copyright © 2021  CaixaBank
* 
* Proposito: Testear la clase SPV_LCMP_EscaladoSLA
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR               DATE       Description 
* 1.0             US1208742       Sergio Martín    16/06/2025      Creación
*****************************************************************/
@isTest
public with sharing class SPV_LCMP_EscaladoSLA_Test {
    @TestSetup
    static void makeData(){
        List<User> listaUsers = SPV_TestDataFactory.crearUsuarioSPVGeneral(1);
        SPV_DatabaseDML.insertListDML(listaUsers, true);
        List<User> listaUsersAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        SPV_DatabaseDML.insertListDML(listaUsersAdmin, true);

        //Mapa campos
        Map<String, Object> camposObj = new Map<String, Object>();
        //Reclamacion
        Case recla = new Case();
        //Grupo
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();

        System.runAs(listaUsers[0]) {
            grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
            grupo.Name = 'grupotest';
            grupo.SAC_PermiteEscalado__c = true;
            grupo.OS_Negocio__c = 'SPV';
            grupo.SAC_DeveloperName__c = 'SPV_AJ';
            SPV_DatabaseDML.insertDML(grupo, true);

            CC_Grupo_Colaborador_Contact__c colabcontact = new CC_Grupo_Colaborador_Contact__c();
            colabcontact.CC_Usuario__c = listaUsers[0].Id;
            colabcontact.CC_Grupo_Colaborador__c = grupo.Id;
            SPV_DatabaseDML.insertDML(colabcontact, true);

            //Crear reclamacion
            camposObj.put('Subject', 'testrec1');
            recla = SPV_TestDataFactory.crearCaso('Reclamacion', camposObj);
            SPV_DatabaseDML.insertDML(recla, true);
        }

        system.runAs(listaUsersAdmin[0]) {
            //Cambiar owner de la reclamación
            recla.OwnerId = listaUsers[0].Id;
            SPV_DatabaseDML.updateDML(recla, true);
        }

        System.runAs(listaUsers[0]) {
            //Crear esacalado
            camposObj.clear();
            camposObj.put('SAC_CasoEscalado__c', recla.Id);
            camposObj.put('SAC_Titulo__c', 'testescalado1');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            camposObj.put('SPV_TipoAllanamiento__c', 'SPV_Parcial');
            camposObj.put('SPV_MotivoAllanamiento__c', 'Test');
            camposObj.put('SPV_AnalisisAllanamiento__c', 'Test');
            camposObj.put('SPV_VerificacionesLetrado__c', 'Test');
            camposObj.put('SAC_Propuesta__c', 'Test');
            camposObj.put('SPV_TipoActuacion__c', 'SPV_Pago');
            camposObj.put('SPV_Importe__c', 1);
            camposObj.put('SPV_Imputable__c', 'SPV_Entidad');
            camposObj.put('SPV_FechaPendienteRespuesta__c', CBK_UtilsDate.nowDT());
            SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
            SPV_DatabaseDML.insertDML(escalado, true);
        }
    }

    @isTest
    static void recuperarSLAEscaladoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        SPV_LCMP_EscaladoSLA.SLAWrapper wrapper;

        Test.startTest();
        System.runAs(usuario) {
            wrapper = SPV_LCMP_EscaladoSLA.recuperarSLAEscalado(escalado.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, wrapper.fechaFin, 'No se ha podido recuperar la fecha del SLA del escalado');
    }
}