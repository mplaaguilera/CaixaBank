/*****************************************************************
    Name: SIRE_cls_WS_listaDocumentoEETest
    Copyright © 2021 CaixaBank

    Proposito: Clase Test de la clase controladora SIRE_cls_WS_listaDocumentoEE                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         07/11/2023     	  Created    

*****************************************************************/
@isTest
public with sharing class SIRE_cls_WS_listaDocumentoEETest {

    @testSetup 
    static void makeData() {
        SIR_TestDataFactory.CrearIntegrationSetting('listaDocumentoEE');
    }
    
    @isTest
    public static void listDocumentsOK() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Test.setMock(HttpCalloutMock.class, new SIRE_cls_WS_listaDocumentoEEMock()); 
            Test.startTest();
            List<Object> responseOK = SIRE_cls_WS_listaDocumentoEE.listaDocumentoEE('200');            
            Test.stopTest();
            System.assertEquals('OK', (String)responseOK.get(0), 'SIRE_cls_WS_listaDocumentoEETest.listDocumentsOK no devuelve la respuesta OK esperada');            
        }
    }
     @isTest
    public static void listDocumentsKO() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Test.setMock(HttpCalloutMock.class, new SIRE_cls_WS_listaDocumentoEEMock()); 
            Test.startTest();
            List<Object> responseOK = SIRE_cls_WS_listaDocumentoEE.listaDocumentoEE('500');            
            Test.stopTest();
            System.assertEquals('KO', (String)responseOK.get(0), 'SIRE_cls_WS_listaDocumentoEETest.listDocumentsKO no devuelve la respuesta KO esperada');            
        }
    }
}