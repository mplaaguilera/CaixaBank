/*****************************************************************
 Name:  SIR_cls_WS_SIRECTest
 Copyright © 2021  CaixaBank

Proposito:   Clase Test de la clase controladora SIR_cls_WS_SIREC                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US271097         Atmira         03/10/2022     	  Created    

*****************************************************************/

@isTest
public with sharing class SIR_cls_WS_SIRECTest {
    @testSetup static void setupMethod(){
        SIR_TestDataFactory.CrearIntegrationSetting('destino');
    }
    @isTest
    public static void llamarTest() {
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_SIRECMock()); 
        Test.startTest();
        Map<String, Object> mapRequestOK = new Map<String, Object>();
        mapRequestOK.put('requestValue', 'respuestaCorrecta');
        
        Map<String, Object> mapRequestKO = new Map<String, Object>();
        mapRequestKO.put('requestValue', 'respuestaInCorrecta');
        
        List<Object> responseOK = SIR_cls_WS_SIREC.llamar(Json.serializePretty(mapRequestOK), 'destino', 'POST');
        List<Object> responseKO = SIR_cls_WS_SIREC.llamar(Json.serializePretty(mapRequestKO), 'destino', 'POST');
        Test.stopTest();
        System.assertEquals('OK', (String)responseOK.get(0), 'SIR_cls_WS_SIRECTest.llamarTest no devuelve la respuesta OK esperada');
        System.assertEquals('KO', (String)responseKO.get(0), 'SIR_cls_WS_SIRECTest.llamarTest no devuelve la respuesta KO esperada');
    }

    @isTest
    public static void llamarTestError() {
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_SIRECMock()); 
        Test.startTest();
        
        Map<String, Object> mapRequestKO = new Map<String, Object>();
        mapRequestKO.put('requestValue', 'error');
        
        List<Object> responseKO = SIR_cls_WS_SIREC.llamar(Json.serializePretty(mapRequestKO), 'destino', 'POST');
        Test.stopTest();
        System.assertEquals('KO', (String)responseKO.get(0), 'SIR_cls_WS_SIRECTest.llamarTest no ha saltado la excepción');
    }
}