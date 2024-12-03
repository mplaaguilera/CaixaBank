@isTest
public with sharing class CC_Notificacion_Volumen_Test {
    
    @isTest
    public static void test() {

        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        agrupador.CC_Id_Maximo__c = 'INC0000';
        agrupador.CC_Evento__c = true;
        agrupador.CC_Publica__c = true;
        insert agrupador;

        CC_Notificacion_Volumen__c notificacion1 = new CC_Notificacion_Volumen__c();
        notificacion1.CC_Agrupador_Id__c = agrupador.Id;
        notificacion1.CC_Mensaje__c = 'Notificación de volumen Test 1';
        notificacion1.CC_Estado__c = 'Enviada';
        notificacion1.CC_Tipo__c = 'Notificación';
        notificacion1.CC_Llamadas_Atendidas__c = 5;
        notificacion1.CC_Llamadas_Atendidas_Parcial__c = 1;
        notificacion1.CC_Llamadas_Abandonadas__c = 3;
        notificacion1.CC_Llamadas_Abandonadas_Parcial__c = 0;
        insert notificacion1;
        DateTime dt = system.now().addDays(-1);
		test.setCreatedDate(notificacion1.id, dt);
        
        CC_Notificacion_Volumen__c notificacion2 = new CC_Notificacion_Volumen__c();
        notificacion2.CC_Agrupador_Id__c = agrupador.Id;
        notificacion2.CC_Mensaje__c = 'Notificación de volumen Test 2';
        notificacion2.CC_Estado__c = 'Enviada';
        notificacion2.CC_Tipo__c = 'Notificación';
        notificacion2.CC_Llamadas_Atendidas__c = 8;
        notificacion2.CC_Llamadas_Atendidas_Parcial__c = 3;
        notificacion2.CC_Llamadas_Abandonadas__c = 3;
        notificacion2.CC_Llamadas_Abandonadas_Parcial__c = 0;
        insert notificacion2;
		DateTime dt2 = system.now();
		test.setCreatedDate(notificacion2.id, dt2);
        
        CC_Notificacion_Volumen__c notificacion3 = new CC_Notificacion_Volumen__c();
        notificacion3.CC_Agrupador_Id__c = agrupador.Id;
        notificacion3.CC_Mensaje__c = 'Notificación de volumen Test 3';
        notificacion3.CC_Estado__c = 'Envío pendiente';
        notificacion3.CC_Tipo__c = 'Notificación';
        notificacion3.CC_Llamadas_Atendidas__c = 8;
        notificacion3.CC_Llamadas_Atendidas_Parcial__c = 3;
        notificacion3.CC_Llamadas_Abandonadas__c = 3;
        notificacion3.CC_Llamadas_Abandonadas_Parcial__c = 0;
        insert notificacion3;
		
        Test.startTest();
        CC_Notificacion_Volumen__c ultimaNotificacion = CC_Notificacion_Volumen.ultimaNotificacion(agrupador.Id);
        test.stopTest();

        System.assertEquals(notificacion2.Id, ultimaNotificacion.Id);
    }
}