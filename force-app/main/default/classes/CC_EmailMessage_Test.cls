@isTest
public with sharing class CC_EmailMessage_Test {

    @isTest
    private static void testGenerarReferenciaCorreoSaliente() {
        //La referencia tiene en el formato 'YYYYMMDDHHmmss'
        Test.startTest();
        String nuevaReferencia = CC_EmailMessage.generarReferenciaCorreoSaliente();
        Test.stopTest();

        //Evaluar resultado de la prueba
        
        System.assertEquals(DateTime.now().format('YYYYMMDDHHmmss').length(), nuevaReferencia.length());
    }

    @isTest
    private static void testGenerarReferenciaCorreoSaliente2() {
        //La referencia tiene en el formato 'YYYYMMDDHHmmsscaseNumber'
        String caseNumber = '00123456';
        Test.startTest();
        String nuevaReferencia = CC_EmailMessage.generarReferenciaCorreoSaliente(caseNumber);
        Test.stopTest();

        //Evaluar resultado de la prueba
        System.assertEquals(DateTime.now().format('YYYYMMDDHHmmss').length() + caseNumber.length(), nuevaReferencia.length());
    }
        
    @isTest
    private static void obtenerBuzonesSalida() {
   
        Test.startTest();
        Map<String, Id> mapBuzones = CC_EmailMessage.obtenerBuzonesSalida();
        Test.stopTest();

        //Evaluar resultado de la prueba
        System.assert(!mapBuzones.isEmpty());
    }
    
    @isTest
    private static void testReferenciaCorreo() {
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        Task actividadCorreo = new Task();
        actividadCorreo.WhatId = caso.Id;
        insert actividadCorreo;

        EmailMessage correo = new EmailMessage();
        correo.ParentId = caso.Id;
        correo.ActivityId = actividadCorreo.Id;
        correo.Incoming = true;
        correo.CC_Interno__c = false;
        correo.MessageDate = System.now();
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.ToAddress = 'to@test.com';
        correo.Subject = 'Correo Test';
        correo.HtmlBody = 'Correo Test\n#@' + CC_EmailMessage.generarReferenciaCorreoSaliente() + '#\nFin';
        insert correo;

        test.startTest();
        //Ejecución de la prueba
        String nuevaReferencia = CC_EmailMessage.generarReferenciaCorreoSaliente();
        test.stopTest();

        //Evaluar resultado de la prueba
        System.assert(nuevaReferencia != null);
    }

    
}