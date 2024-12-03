/**
@name SAC_WS_GGH_Callout_Test
@version 1.0
@date 25-01-2020.
@author Nicolás García Muñoz, IBM
@description Clase Test para la clase SAC_WS_GGH_Callout
*/
@IsTest
public with sharing class SAC_WS_GGH_Callout_Test {

    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }
        
    }
    
    /**@isTest
    public static void testProbarLlamadaAntecedentes(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csGGH = new CBK_IntegrationSetting__c();
        csGGH.Name = 'SAC_GGH_Callout';
        csGGH.NamedCredential__c = 'callout:API_GWT_PRE/tech/gdsusr/api/GGHAPI/AltaReclamacion';
        Database.insert(csGGH);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        SAC_WS_GGH_Callout_RP.GGHResponse elemento = new SAC_WS_GGH_Callout_RP.GGHResponse('idPretension', true, 'numContrato', 'cuentaAbono');
        elemento.getidPretension();
		elemento.getResult();
        elemento.gestError(); 
        elemento.getTipoGestion();

        SAC_WS_GGH_Callout_RQ.Reclamacion reclamacion = new SAC_WS_GGH_Callout_RQ.Reclamacion('idPretension', 'idTarea', 'dni_Reclamante1', 'impNotaria', 'impGestoria', 'impRegistro', 'impTasacion', 'contrato', 'ccAbono', 'observaciones');
        reclamacion.getIdPretension();
        reclamacion.getIdTarea();
        reclamacion.getDniReclamante();
        reclamacion.getImpNotaria();
        reclamacion.getImpRegistro();
        reclamacion.getImpTasacion();
        reclamacion.getCCabono();
        reclamacion.getContrato();
        reclamacion.getObservaciones();

        List<SAC_WS_GGH_Callout_RQ.Documentacion> lstDocumentacion = new List<SAC_WS_GGH_Callout_RQ.Documentacion>();
        SAC_WS_GGH_Callout_RQ.Documentacion doc = new SAC_WS_GGH_Callout_RQ.Documentacion('cont', 'nombre.pdf');
        lstDocumentacion.add(doc);

        doc.getContent();
        doc.getName();

        SAC_WS_GGH_Callout_RQ.GGHRequest request = new SAC_WS_GGH_Callout_RQ.GGHRequest('usuarioAlta', reclamacion, lstDocumentacion);

        SAC_WS_GGH_Callout_RP.GGHResponse response;
        Test.startTest();
        System.runAs(usuario){
            response = SAC_WS_GGH_Callout.sendRequest(request, 'SPV_General');
        }
        Test.stopTest();

        System.assertNotEquals(response, null, 'Hay un error en la ejecución');
    }*/

    @isTest
    public static void testProbarLlamadaAntecedentesError(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csGGH = new CBK_IntegrationSetting__c();
        csGGH.Name = 'SAC_GGH_Callout';
        csGGH.NamedCredential__c = 'callout:API_GWT_PRE/tech/gdsusr/api/GGHAPI/AltaReclamacion';
        Database.insert(csGGH);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(404, 'KO', null, null));

        SAC_WS_GGH_Callout_RQ.Reclamacion reclamacion = new SAC_WS_GGH_Callout_RQ.Reclamacion('idPretension', 'idTarea', 'dni_Reclamante1', 'impNotaria', 'impGestoria', 'impRegistro', 'impTasacion', 'contrato', 'ccAbono', 'observaciones');
        reclamacion.getIdPretension();
        reclamacion.getIdTarea();
        reclamacion.getDniReclamante();
        reclamacion.getImpNotaria();
        reclamacion.getImpRegistro();
        reclamacion.getImpTasacion();
        reclamacion.getCCabono();
        reclamacion.getContrato();
        reclamacion.getObservaciones();

        List<SAC_WS_GGH_Callout_RQ.Documentacion> lstDocumentacion = new List<SAC_WS_GGH_Callout_RQ.Documentacion>();
        SAC_WS_GGH_Callout_RQ.Documentacion doc = new SAC_WS_GGH_Callout_RQ.Documentacion('cont', 'nombre.pdf');
        lstDocumentacion.add(doc);
        
        SAC_WS_GGH_Callout_RQ.GGHRequest request = new SAC_WS_GGH_Callout_RQ.GGHRequest('usuarioAlta', reclamacion, lstDocumentacion);

        SAC_WS_GGH_Callout_RP.GGHResponse response;

        System.runAs(usuario){
            try{
                response = SAC_WS_GGH_Callout.sendRequest(request, 'SPV_General');
            }
            catch(Exception e){
                System.assertEquals(response, null, 'Hay un error en la ejecución');
            }
        }
    }
}