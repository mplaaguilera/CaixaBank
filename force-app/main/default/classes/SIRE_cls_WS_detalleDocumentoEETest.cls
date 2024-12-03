/*****************************************************************
    Name: SIRE_cls_WS_detalleDocumentoEETest
    Copyright © 2021 CaixaBank

    Proposito: Clase Test de la clase controladora SIRE_cls_WS_detalleDocumentoEE                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         07/11/2023     	  Created    

*****************************************************************/
@isTest
public with sharing class SIRE_cls_WS_detalleDocumentoEETest {

    @testSetup 
    static void makeData() {
        SIR_TestDataFactory.CrearIntegrationSetting('detalleDocumentoEE');
    }
    
    @isTest
    public static void detalleDocumentsOK() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){

            //SET MOCK
            Test.startTest();		
            HttpResponse resp = new HttpResponse();        
            resp.setBody('{\"status": "OK"}');		
            resp.setStatusCode(200);
            resp.setStatus('OK');
            SIRE_cls_WS_detalleDocumentoEEMock vMock = new SIRE_cls_WS_detalleDocumentoEEMock(resp);
            Test.setMock(HttpCalloutMock.class, vMock);

            List<Object> response = SIRE_cls_WS_detalleDocumentoEE.detalleDocumentoEE(200);                    
            Test.stopTest();
            System.assertEquals('OK', (String)response.get(0), 'SIRE_cls_WS_detalleDocumentoEETest.detalleDocumentsOK no devuelve la respuesta OK esperada');            
        }
    }

    @isTest
    public static void detalleDocumentsKO() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){

            //SET MOCK
            Test.startTest();		
            HttpResponse resp = new HttpResponse();        
            resp.setBody('{\"status": "KO"}');		
            resp.setStatusCode(500);
            resp.setStatus('KO');
            SIRE_cls_WS_detalleDocumentoEEMock vMock = new SIRE_cls_WS_detalleDocumentoEEMock(resp);
            Test.setMock(HttpCalloutMock.class, vMock);

            List<Object> response = SIRE_cls_WS_detalleDocumentoEE.detalleDocumentoEE(200);                    
            Test.stopTest();
            System.assertEquals('KO', (String)response.get(0), 'SIRE_cls_WS_detalleDocumentoEETest.detalleDocumentsKO no devuelve la respuesta KO esperada');            
        }
    }

}