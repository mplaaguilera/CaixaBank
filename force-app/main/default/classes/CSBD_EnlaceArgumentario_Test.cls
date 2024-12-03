/*****************************************************************
 * Name: CSBD_EnlaceArgumentario_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear el componente CSBD_EnlaceArgumentario
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       05/08/24     Creación
*****************************************************************/
/**
 * @description     clase de test para el componente CSBD_EnlaceArgumentario
 */
@isTest
public with sharing class CSBD_EnlaceArgumentario_Test {
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
            //opportunity con articulo de producto
            Map<String, Object> camposOppl = new Map<String, Object>();
            camposOppl.put('CSBD_Producto__c', 'MyBox Vida');
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOppl); //la funcion ya hace el insert

            //opportunity sin articulo de producto
            Map<String, Object> camposOpp2 = new Map<String, Object>();
            camposOpp2.put('CSBD_Producto__c', 'Deposito Bonificado');
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOpp2); //la funcion ya hace el insert

            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lista.CC_Activa__c = true;
            lista.Name = 'CSBD: Enlaces de soporte digital';
            Database.insert(lista);
            CC_Lista_Valores__c valores = new CC_Lista_Valores__c();
            valores.CC_Lista__c = lista.id;
            valores.Name = 'MyBox Vida';
            valores.CSBD_Soporte_Digital_Argumentario__c = 'enlace';
            Database.insert(valores);
        }
    }

    @isTest
    static void productoOppConEnlace() {
        Opportunity opp = [SELECT Id, CSBD_Producto__c, CSBD_Now_Origen__c FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida']; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_EnlaceArgumentario.Request> listEnlaceProdReq = new List<CSBD_EnlaceArgumentario.Request>();
        CSBD_EnlaceArgumentario.Request enlaceProdReq = new CSBD_EnlaceArgumentario.Request();
        enlaceProdReq.objectToSummarize = opp;
        listEnlaceProdReq.add(enlaceProdReq);

        List<CSBD_EnlaceArgumentario.Response> listEnlacesResponses = new List<CSBD_EnlaceArgumentario.Response>();

        System.runAs(usuario){
            Test.startTest();
            listEnlacesResponses = CSBD_EnlaceArgumentario.buscarEnlaces(listEnlaceProdReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'Enlace de argumentario de MyBox Vida:/nenlace/n';
        System.assertEquals(resultadoEsperado, listEnlacesResponses[0].Prompt,'El enlace no se obtiene correctamente');
    }

    @isTest
    static void productoOppSinEnlace() {
        Opportunity opp = [SELECT Id, CSBD_Producto__c, CSBD_Now_Origen__c FROM Opportunity WHERE CSBD_Producto__c = 'Deposito Bonificado']; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_EnlaceArgumentario.Request> listEnlaceProdReq = new List<CSBD_EnlaceArgumentario.Request>();
        CSBD_EnlaceArgumentario.Request enlaceProdReq = new CSBD_EnlaceArgumentario.Request();
        enlaceProdReq.objectToSummarize = opp;
        listEnlaceProdReq.add(enlaceProdReq);

        List<CSBD_EnlaceArgumentario.Response> listEnlacesResponses = new List<CSBD_EnlaceArgumentario.Response>();

        System.runAs(usuario){
            Test.startTest();
            listEnlacesResponses = CSBD_EnlaceArgumentario.buscarEnlaces(listEnlaceProdReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'No se han encontrado enlaces relacionados con ese producto.';
        System.assertEquals(resultadoEsperado, listEnlacesResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void forzarException() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        List<CSBD_EnlaceArgumentario.Request> listEnlaceProdReq = new List<CSBD_EnlaceArgumentario.Request>();

        List<CSBD_EnlaceArgumentario.Response> listEnlacesResponses = new List<CSBD_EnlaceArgumentario.Response>();
        ListException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                listEnlacesResponses = CSBD_EnlaceArgumentario.buscarEnlaces(listEnlaceProdReq);
            }
            catch(ListException listExc){
                exc = listExc;
            }
            Test.stopTest();
        }

        System.assertEquals(new List<CSBD_EnlaceArgumentario.Response>(), listEnlacesResponses,'El error no se ha capturado correctamente');
    }
}