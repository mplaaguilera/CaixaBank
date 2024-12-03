@isTest
public with sharing class CC_Notificacion_Volumen_Crear_Test {

    @isTest
    public static void testInicializarVolumenes() {

        //Comprueba que se retornan las llamadas de la última actualización en estado "Enviada"

        //Preparación de los datos de prueba
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        agrupador.CC_Id_Maximo__c = 'INC1234';
        insert agrupador;

        CC_Notificacion_Volumen__c notificacion1 = new CC_Notificacion_Volumen__c();
        notificacion1.CC_Agrupador_Id__c = agrupador.Id;
        notificacion1.CC_Tipo__c = 'Notificación';
        notificacion1.CC_Estado__c = 'Enviada';
        notificacion1.CC_Mensaje__c = 'Actualización de volumen 1 Test';
        notificacion1.CC_Llamadas_Atendidas__c = 10;
        notificacion1.CC_Llamadas_Atendidas_Parcial__c = 0;
        notificacion1.CC_Llamadas_Abandonadas__c = 5;
        notificacion1.CC_Llamadas_Abandonadas_Parcial__c = 0;
        insert notificacion1;

        CC_Notificacion_Volumen__c notificacion2 = new CC_Notificacion_Volumen__c();
        notificacion2.CC_Agrupador_Id__c = agrupador.Id;
        notificacion2.CC_Tipo__c = 'Notificación';
        notificacion2.CC_Estado__c = 'Envío pendiente';  //No debe afectar la fecha devuelta
        notificacion2.CC_Mensaje__c = 'Actualización de volumen 2 Test';
        notificacion2.CC_Llamadas_Atendidas__c = 12;
        notificacion2.CC_Llamadas_Atendidas_Parcial__c = 2;
        notificacion2.CC_Llamadas_Abandonadas__c = 6;
        notificacion2.CC_Llamadas_Abandonadas_Parcial__c = 1;
        insert notificacion2;

        Integer numeroCasos = 15;
        List<Case> nuevosCasos = new List<Case>();
        for (Integer i = 1; i <= numeroCasos; i++) {
            Case nuevoCaso = new Case();
            nuevoCaso.Subject = 'Caso ' + i + ' de ' + numeroCasos + ' Test';
            nuevoCaso.CC_Agrupador_Id__c = agrupador.Id;
            nuevosCasos.add(nuevoCaso);
        }
        insert nuevosCasos;

        //Ejecución de la prueba
        Test.startTest();
        Map<String, Integer> volumenes = CC_Notificacion_Volumen_Crear_Controller.inicializarVolumenes(agrupador.Id);
        Test.stopTest();

        //Evaluar resultado de la prueba
        System.assertEquals(numeroCasos, volumenes.get('llamadasAtendidas'));
        System.assertEquals(numeroCasos - notificacion1.CC_Llamadas_Atendidas__c, volumenes.get('llamadasAtendidasParcial'));
        System.assertEquals(notificacion1.CC_Llamadas_Abandonadas__c, volumenes.get('llamadasAbandonadasAnterior'));
    }

    @isTest
    public static void testFechaUltimaNotificacion() {
        
        //Comprueba que se retorna la fecha de la última actualización en estado "Enviada"
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        agrupador.CC_Id_Maximo__c = 'INC1234';
        insert agrupador;

        CC_Notificacion_Volumen__c notificacion1 = new CC_Notificacion_Volumen__c();
        notificacion1.CC_Agrupador_Id__c = agrupador.Id;
        notificacion1.CC_Tipo__c = 'Notificación';
        notificacion1.CC_Estado__c = 'Enviada';
        notificacion1.CC_Mensaje__c = 'Actualización de volumen 1 Test';
        notificacion1.CC_Llamadas_Atendidas__c = 10;
        notificacion1.CC_Llamadas_Atendidas_Parcial__c = 0;
        notificacion1.CC_Llamadas_Abandonadas__c = 5;
        notificacion1.CC_Llamadas_Abandonadas_Parcial__c = 0;
        insert notificacion1;

        CC_Notificacion_Volumen__c notificacion2 = new CC_Notificacion_Volumen__c();
        notificacion2.CC_Agrupador_Id__c = agrupador.Id;
        notificacion2.CC_Tipo__c = 'Notificación';
        notificacion2.CC_Estado__c = 'Enviada';
        notificacion2.CC_Mensaje__c = 'Actualización de volumen 2 Test';
        notificacion2.CC_Llamadas_Atendidas__c = 12;
        notificacion2.CC_Llamadas_Atendidas_Parcial__c = 2;
        notificacion2.CC_Llamadas_Abandonadas__c = 6;
        notificacion2.CC_Llamadas_Abandonadas_Parcial__c = 1;
        insert notificacion2;

        CC_Notificacion_Volumen__c notificacion3 = new CC_Notificacion_Volumen__c();
        notificacion3.CC_Agrupador_Id__c = agrupador.Id;
        notificacion3.CC_Tipo__c = 'Notificación';
        notificacion3.CC_Estado__c = 'Envío pendiente'; //No debe afectar la fecha devuelta
        notificacion3.CC_Mensaje__c = 'Actualización de volumen 3 Test';
        notificacion3.CC_Llamadas_Atendidas__c = 15;
        notificacion3.CC_Llamadas_Atendidas_Parcial__c = 3;
        notificacion3.CC_Llamadas_Abandonadas__c = 6;
        notificacion3.CC_Llamadas_Abandonadas_Parcial__c = 0;
        insert notificacion3;

        Test.startTest();
        String fechaUltimaNotificacion = CC_Notificacion_Volumen_Crear_Controller.fechaUltimaNotificacion(agrupador.Id);
        Test.stopTest();

        notificacion2 = [SELECT LastModifiedDate FROM CC_Notificacion_Volumen__c WHERE Id = :notificacion2.Id];
        System.assertEquals(String.valueOfGmt(notificacion2.LastModifiedDate), fechaUltimaNotificacion);
    }
}