/*****************************************************************
 * Name: CSBD_OtrasOportunidadesSubset_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear el componente CSBD_OtrasOportunidadesSubset
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       05/08/24     Creación
*****************************************************************/
/**
 * @description     clase de test para el componente CSBD_OtrasOportunidadesSubset
 */
@isTest
public with sharing class CSBD_OtrasOportunidadesSubset_Test {
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
            
            //opportunity 2 con cliente 1
            Map<String, Object> camposOpp2 = new Map<String, Object>();
            camposOpp2.put('AccountId', cliente1.id);
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOpp2); //la funcion ya hace el insert

            //opportunity 3 con cliente 2
            Account cliente2 = new Account();
            cliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cliente2.Name = 'cliente2';
            cliente2.Phone = '999999999';
            cliente2.AV_Idioma__c = null;
            Database.insert(cliente2);

            Map<String, Object> camposOpp3 = new Map<String, Object>();
            camposOpp3.put('AccountId', cliente2.id);
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOpp3); //la funcion ya hace el insert

            //opportunity sin cliente
            CSBD_Opportunity.crearOportunidad('CSBD_CMB'); //la funcion ya hace el insert
        }
    }

    @isTest
    static void clienteOppConOtrasOpp() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'cliente1'];
        List<Opportunity> opps = [SELECT Id, AccountId, Name, StageName, CloseDate, CSBD_Producto__c, Amount
                                    FROM Opportunity WHERE AccountId = :acc.id]; 
        //habra 2, cualquiera sirve para el test
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_OtrasOportunidadesSubset.Request> listOtrasOppReq = new List<CSBD_OtrasOportunidadesSubset.Request>();
        CSBD_OtrasOportunidadesSubset.Request otrasOppReq = new CSBD_OtrasOportunidadesSubset.Request();
        otrasOppReq.objectToSummarize = opps[0];
        listOtrasOppReq.add(otrasOppReq);

        List<CSBD_OtrasOportunidadesSubset.Response> listOtrasOppResponses = new List<CSBD_OtrasOportunidadesSubset.Response>();

        System.runAs(usuario){
            Test.startTest();
            listOtrasOppResponses = CSBD_OtrasOportunidadesSubset.buscarOportunidades(listOtrasOppReq);
            Test.stopTest();
        }

        // CSBD_OtrasOportunidadesSubset.DatosOportunidad otraOp = JSON.deserialize(listOtrasOppResponses[0].Prompt, CSBD_OtrasOportunidadesSubset.DatosOportunidad);
        // Datetime d = opps[1].CloseDate;
        // String dt = String.valueOf(d.dateGmt())+' '+String.valueOf(d.timeGmt());
        // String resultadoEsperado = '{"oportunidades":[{"producto":'+ opps[1].CSBD_Producto__c + ',"nombre":"'+ opps[1].Name + '","fechaCierre":"'+ dt +'","etapa":"'+opps[1].StageName+'","amount":'+ opps[1].Amount+'}]}';
        System.assertEquals(1, listOtrasOppResponses.size(),'La otra oportunidad no se obtiene correctamente');
    }

    @isTest
    static void clienteOppSinOtrasOpp() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'cliente2'];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :acc.id];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_OtrasOportunidadesSubset.Request> listOtrasOppReq = new List<CSBD_OtrasOportunidadesSubset.Request>();
        CSBD_OtrasOportunidadesSubset.Request otrasOppReq = new CSBD_OtrasOportunidadesSubset.Request();
        otrasOppReq.objectToSummarize = opp;
        listOtrasOppReq.add(otrasOppReq);

        List<CSBD_OtrasOportunidadesSubset.Response> listOtrasOppResponses = new List<CSBD_OtrasOportunidadesSubset.Response>();

        System.runAs(usuario){
            Test.startTest();
            listOtrasOppResponses = CSBD_OtrasOportunidadesSubset.buscarOportunidades(listOtrasOppReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'No se han encontrado otras oportunidades del cliente.';
        System.assertEquals(resultadoEsperado, listOtrasOppResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void oppSinCliente() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = null];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        List<CSBD_OtrasOportunidadesSubset.Request> listOtrasOppReq = new List<CSBD_OtrasOportunidadesSubset.Request>();
        CSBD_OtrasOportunidadesSubset.Request otrasOppReq = new CSBD_OtrasOportunidadesSubset.Request();
        otrasOppReq.objectToSummarize = opp;
        listOtrasOppReq.add(otrasOppReq);

        List<CSBD_OtrasOportunidadesSubset.Response> listOtrasOppResponses = new List<CSBD_OtrasOportunidadesSubset.Response>();

        System.runAs(usuario){
            Test.startTest();
            listOtrasOppResponses = CSBD_OtrasOportunidadesSubset.buscarOportunidades(listOtrasOppReq);
            Test.stopTest();
        }

        String resultadoEsperado = 'No hay un Account en la oportunidad.';
        System.assertEquals(resultadoEsperado, listOtrasOppResponses[0].Prompt,'El mensaje obtenido no es el esperado');
    }

    @isTest
    static void forzarException() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        List<CSBD_OtrasOportunidadesSubset.Request> listOtrasOppReq = new List<CSBD_OtrasOportunidadesSubset.Request>();

        List<CSBD_OtrasOportunidadesSubset.Response> listOtrasOppResponses = new List<CSBD_OtrasOportunidadesSubset.Response>();
        ListException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                listOtrasOppResponses = CSBD_OtrasOportunidadesSubset.buscarOportunidades(listOtrasOppReq);
            }
            catch(ListException listExc){
                exc = listExc;
            }
            Test.stopTest();
        }

        System.assertEquals(new List<CSBD_OtrasOportunidadesSubset.Response>(), listOtrasOppResponses,'El error no se ha capturado correctamente');
    }
}