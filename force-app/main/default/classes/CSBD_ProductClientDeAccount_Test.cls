/*****************************************************************
 * Name: CSBD_ProductClientDeAccount_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear el componente CSBD_ProductClientDeAccount
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       05/08/24     Creación
*****************************************************************/
/**
 * @description     clase de test para el componente CSBD_ProductClientDeAccount
 */
@isTest
public with sharing class CSBD_ProductClientDeAccount_Test {
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
            //opportunity 1 con cliente 1
            Account cliente1 = new Account();
            cliente1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cliente1.Name = 'cliente1';
            cliente1.Phone = '666666666';
            Database.insert(cliente1);

            Map<String, Object> camposOppl = new Map<String, Object>();
            camposOppl.put('AccountId', cliente1.id);
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOppl); //la funcion ya hace el insert

            //opportunity 2 con cliente 2
            Account cliente2 = new Account();
            cliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cliente2.Name = 'cliente2';
            cliente2.Phone = '999999999';
            cliente2.AV_Idioma__c = null;
            Database.insert(cliente2);

            Map<String, Object> camposOpp2 = new Map<String, Object>();
            camposOpp2.put('AccountId', cliente2.id);
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOpp2); //la funcion ya hace el insert

            //opportunity sin cliente
            CSBD_Opportunity.crearOportunidad('CSBD_CMB'); //la funcion ya hace el insert

            AV_ProductClient__c prodClient = new AV_ProductClient__c();
            prodClient.AV_Cliente__c = cliente1.id;
            prodClient.AV_TenenciaProducto__c = '2';
            Database.insert(prodClient);
        }
    }

    @isTest
    static void clienteConProdClient() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'cliente1'];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :acc.id]; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ProductClientDeAccount.Request> listProdClientReq = new List<CSBD_ProductClientDeAccount.Request>();
        CSBD_ProductClientDeAccount.Request prodClientReq = new CSBD_ProductClientDeAccount.Request();
        prodClientReq.objectToSummarize = opp;
        listProdClientReq.add(prodClientReq);

        List<CSBD_ProductClientDeAccount.Response> listProdClientResponses = new List<CSBD_ProductClientDeAccount.Response>();

        System.runAs(usuario){
            Test.startTest();
            listProdClientResponses = CSBD_ProductClientDeAccount.buscarProductClient(listProdClientReq);
            Test.stopTest();
        }

        String resultadoEsperado = '{"productos":[{"tenenciaProducto":"Tiene Producto","nombreProducto":null,"myBox":"No"}]}';
        System.assertEquals(resultadoEsperado, listProdClientResponses[0].Prompt,'El AV_ProductClient__c no se obtiene correctamente');
    }

    @isTest
    static void clienteSinProdClient() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'cliente2'];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :acc.id]; 

        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ProductClientDeAccount.Request> listProdClientReq = new List<CSBD_ProductClientDeAccount.Request>();
        CSBD_ProductClientDeAccount.Request prodClientReq = new CSBD_ProductClientDeAccount.Request();
        prodClientReq.objectToSummarize = opp;
        listProdClientReq.add(prodClientReq);

        List<CSBD_ProductClientDeAccount.Response> listProdClientResponses = new List<CSBD_ProductClientDeAccount.Response>();

        System.runAs(usuario){
            Test.startTest();
            listProdClientResponses = CSBD_ProductClientDeAccount.buscarProductClient(listProdClientReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'No se han encontrado productos relacionados con el cliente.';
        System.assertEquals(resultadoEsperado, listProdClientResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void oppSinCliente() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = null]; 

        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_ProductClientDeAccount.Request> listProdClientReq = new List<CSBD_ProductClientDeAccount.Request>();
        CSBD_ProductClientDeAccount.Request prodClientReq = new CSBD_ProductClientDeAccount.Request();
        prodClientReq.objectToSummarize = opp;
        listProdClientReq.add(prodClientReq);

        List<CSBD_ProductClientDeAccount.Response> listProdClientResponses = new List<CSBD_ProductClientDeAccount.Response>();

        System.runAs(usuario){
            Test.startTest();
            listProdClientResponses = CSBD_ProductClientDeAccount.buscarProductClient(listProdClientReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'No hay un Account en la oportunidad.';
        System.assertEquals(resultadoEsperado, listProdClientResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void forzarException() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        List<CSBD_ProductClientDeAccount.Request> listProdClientReq = new List<CSBD_ProductClientDeAccount.Request>();

        List<CSBD_ProductClientDeAccount.Response> listProdClientResponses = new List<CSBD_ProductClientDeAccount.Response>();
        ListException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                listProdClientResponses = CSBD_ProductClientDeAccount.buscarProductClient(listProdClientReq);
            }
            catch(ListException listExc){
                exc = listExc;
            }
            Test.stopTest();
        }

        System.assertEquals(new List<CSBD_ProductClientDeAccount.Response>(), listProdClientResponses,'El error no se ha capturado correctamente');
    }
}