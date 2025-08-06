/*****************************************************************
 * Name: CSBD_ObtenerLabelIdioma_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear el componente CSBD_ObtenerLabelIdioma
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       05/08/24     Creación
*****************************************************************/
/**
 * @description     clase de test para el componente CSBD_ObtenerLabelIdioma
 */
@isTest
public with sharing class CSBD_ObtenerLabelIdioma_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral = CSBD_Usuarios.usuarioGestor(); //la funcion ya hace el insert

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name IN ('CSBD_PromptUser')];
        PermissionSet permiSet1 = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet1.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //opportunity con cliente con idioma
            Account clienteES = new Account();
            clienteES.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            clienteES.Name = 'clienteES';
            clienteES.Phone = '666666666';
            clienteES.AV_Idioma__c = '002';
            Database.insert(clienteES);

            Map<String, Object> camposOppl = new Map<String, Object>();
            camposOppl.put('AccountId', clienteES.id);
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOppl); //la funcion ya hace el insert

            //opportunity con cliente sin idioma
            Account clienteNoIdioma = new Account();
            clienteNoIdioma.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            clienteNoIdioma.Name = 'clienteNoIdioma';
            clienteNoIdioma.Phone = '999999999';
            clienteNoIdioma.AV_Idioma__c = null;
            Database.insert(clienteNoIdioma);

            Map<String, Object> camposOpp2 = new Map<String, Object>();
            camposOpp2.put('AccountId', clienteNoIdioma.id);
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOpp2); //la funcion ya hace el insert

            //opportunity sin cliente
            CSBD_Opportunity.crearOportunidad('CSBD_CMB'); //la funcion ya hace el insert
        }
    }

    @isTest
    static void oppConClienteEIdioma() {
        Account acc = [SELECT Id, AV_Idioma__c FROM Account WHERE AV_Idioma__c = '002'];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :acc.id];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ObtenerLabelIdioma.Request> listLabelIdiomaReq = new List<CSBD_ObtenerLabelIdioma.Request>();
        CSBD_ObtenerLabelIdioma.Request labelIdiomaReq = new CSBD_ObtenerLabelIdioma.Request();
        labelIdiomaReq.objectToSummarize = opp;
        listLabelIdiomaReq.add(labelIdiomaReq);

        List<CSBD_ObtenerLabelIdioma.Response> listLabelIdiomaResponses = new List<CSBD_ObtenerLabelIdioma.Response>();

        System.runAs(usuario){
            Test.startTest();
            listLabelIdiomaResponses = CSBD_ObtenerLabelIdioma.obtenerLabelIdioma(listLabelIdiomaReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'Castellano';
        System.assertEquals(resultadoEsperado, listLabelIdiomaResponses[0].Prompt,'El idioma no se obtiene correctamente');
    }

    @isTest
    static void oppConClienteSinIdioma() {
        Account acc = [SELECT Id, AV_Idioma__c FROM Account WHERE AV_Idioma__c = null];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :acc.id];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ObtenerLabelIdioma.Request> listLabelIdiomaReq = new List<CSBD_ObtenerLabelIdioma.Request>();
        CSBD_ObtenerLabelIdioma.Request labelIdiomaReq = new CSBD_ObtenerLabelIdioma.Request();
        labelIdiomaReq.objectToSummarize = opp;
        listLabelIdiomaReq.add(labelIdiomaReq);

        List<CSBD_ObtenerLabelIdioma.Response> listLabelIdiomaResponses = new List<CSBD_ObtenerLabelIdioma.Response>();

        System.runAs(usuario){
            Test.startTest();
            listLabelIdiomaResponses = CSBD_ObtenerLabelIdioma.obtenerLabelIdioma(listLabelIdiomaReq);
            Test.stopTest();
        }

        String resultadoEsperado = '[Provide:{IDIOMA}]';
        System.assertEquals(resultadoEsperado, listLabelIdiomaResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void oppSinCliente() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = null];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ObtenerLabelIdioma.Request> listLabelIdiomaReq = new List<CSBD_ObtenerLabelIdioma.Request>();
        CSBD_ObtenerLabelIdioma.Request labelIdiomaReq = new CSBD_ObtenerLabelIdioma.Request();
        labelIdiomaReq.objectToSummarize = opp;
        listLabelIdiomaReq.add(labelIdiomaReq);

        List<CSBD_ObtenerLabelIdioma.Response> listLabelIdiomaResponses = new List<CSBD_ObtenerLabelIdioma.Response>();

        System.runAs(usuario){
            Test.startTest();
            listLabelIdiomaResponses = CSBD_ObtenerLabelIdioma.obtenerLabelIdioma(listLabelIdiomaReq);
            Test.stopTest();
        }

        String resultadoEsperado = '[Provide:{CLIENTE}]';
        System.assertEquals(resultadoEsperado, listLabelIdiomaResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void forzarException() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        List<CSBD_ObtenerLabelIdioma.Request> listLabelIdiomaReq = new List<CSBD_ObtenerLabelIdioma.Request>();

        List<CSBD_ObtenerLabelIdioma.Response> listLabelIdiomaResponses = new List<CSBD_ObtenerLabelIdioma.Response>();
        ListException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                listLabelIdiomaResponses = CSBD_ObtenerLabelIdioma.obtenerLabelIdioma(listLabelIdiomaReq);
            }
            catch(ListException listExc){
                exc = listExc;
            }
            Test.stopTest();
        }

        System.assertEquals(new List<CSBD_ObtenerLabelIdioma.Response>(), listLabelIdiomaResponses,'El error no se ha capturado correctamente');
    }
}