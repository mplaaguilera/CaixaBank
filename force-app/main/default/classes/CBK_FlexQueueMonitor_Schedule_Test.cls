/**********************************************************************************************************************
 Name:	  CBK_FlexQueueMonitor_Schedule_Test
 Copyright © 2021  CaixaBank
***********************************************************************************************************************
Proposito: Clase de test del FW de monitorización de la cola Flex (procesos batch).
***********************************************************************************************************************
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	26/06/2021			Init version
***********************************************************************************************************************/

@isTest
public class CBK_FlexQueueMonitor_Schedule_Test {

    /**
    * @description Método de test para validar la asignación de sumatorio en la inner class CBK_FlexQueueMonitor_Schedule.aggregateProyect
    * @author   fzaragoza | 28/06/2021 
    **/
    @isTest static void testSumatorio() {
        CBK_FlexQueueMonitor_Schedule.aggregateProyect agregado = new CBK_FlexQueueMonitor_Schedule.aggregateProyect(0,'PRF');
        agregado.addSumatorio(5);
        system.AssertEquals(5,agregado.sumatorioBatches,'No coincide el valor esperado con el devuelto.');
    }

    /**
    * @description Método de test para validar el envío de email
    * @author   fzaragoza | 28/06/2021 
    **/
    @isTest static void testNotificacionProyecto() {
        List<OrgWideEmailAddress> owea = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress LIMIT 1];
        List <CBK_FlexQueueMonitorSetting__c> lstCSFlexQueueMonitor = new List <CBK_FlexQueueMonitorSetting__c>();
        CBK_FlexQueueMonitorSetting__c registroGeneralAlto = new  CBK_FlexQueueMonitorSetting__c();
        registroGeneralAlto.Name = 'General';
        registroGeneralAlto.CBK_Aplicacion__c ='General';
        registroGeneralAlto.CBK_PrefijoAplicacion__c ='GRL';
        registroGeneralAlto.CBK_Activo__c =true;
        registroGeneralAlto.CBK_Umbral__c =90;
        registroGeneralAlto.CBK_MinsIntervaloNotif__c =15;
        registroGeneralAlto.CBK_RemitenteCorreo__c =owea[0].Address;
        registroGeneralAlto.CBK_DestinatarioCorreoTo__c ='test@test.com';
        registroGeneralAlto.CBK_DestinatarioCorreoCC__c ='';
        registroGeneralAlto.CBK_DestinatarioCorreoCCO__c ='';
        lstCSFlexQueueMonitor.add(registroGeneralAlto);
        CBK_FlexQueueMonitorSetting__c registroTestBajo = new  CBK_FlexQueueMonitorSetting__c();
        registroTestBajo.Name = 'Test';
        registroTestBajo.CBK_Aplicacion__c ='Test';
        registroTestBajo.CBK_PrefijoAplicacion__c ='TST';
        registroTestBajo.CBK_Activo__c =true;
        registroTestBajo.CBK_Umbral__c =30;
        registroTestBajo.CBK_MinsIntervaloNotif__c = 15;
        registroTestBajo.CBK_RemitenteCorreo__c =owea[0].Address;
        registroTestBajo.CBK_DestinatarioCorreoTo__c ='test@test.com';
        registroTestBajo.CBK_DestinatarioCorreoCC__c ='test@test.com';
        registroTestBajo.CBK_DestinatarioCorreoCCO__c ='test@test.com';
        lstCSFlexQueueMonitor.add(registroTestBajo);
        insert lstCSFlexQueueMonitor;

        Test.startTest();
        SchedulableContext sc = null;
        CBK_FlexQueueMonitor_Schedule fqmSched = new CBK_FlexQueueMonitor_Schedule();
        fqmSched.execute(sc);
        Integer emailsEnviados = Limits.getEmailInvocations();
        Test.stopTest();
        //Se comenta el assert para evitar errores en instancias donde por email deliverability no se permita el envío de emails
        //system.assertEquals(1, emailsEnviados, 'No coincide los emails enviados con los esperados');
    }
    /**
    * @description Método de test para validar el envío de email
    * @author   fzaragoza | 28/06/2021 
    **/
    @isTest static void testNotificacionGeneral() {
        List<OrgWideEmailAddress> owea = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress LIMIT 1];
        List <CBK_FlexQueueMonitorSetting__c> lstCSFlexQueueMonitor = new List <CBK_FlexQueueMonitorSetting__c>();
        CBK_FlexQueueMonitorSetting__c registroGeneralBajo = new  CBK_FlexQueueMonitorSetting__c();
        registroGeneralBajo.Name = 'General';
        registroGeneralBajo.CBK_Aplicacion__c ='General';
        registroGeneralBajo.CBK_PrefijoAplicacion__c ='GRL';
        registroGeneralBajo.CBK_Activo__c =true;
        registroGeneralBajo.CBK_Umbral__c =30;
        registroGeneralBajo.CBK_MinsIntervaloNotif__c =15;
        registroGeneralBajo.CBK_RemitenteCorreo__c =owea[0].Address;
        registroGeneralBajo.CBK_DestinatarioCorreoTo__c ='test@test.com';
        registroGeneralBajo.CBK_DestinatarioCorreoCC__c ='';
        registroGeneralBajo.CBK_DestinatarioCorreoCCO__c ='';
        lstCSFlexQueueMonitor.add(registroGeneralBajo);
        CBK_FlexQueueMonitorSetting__c registroTestAlto = new  CBK_FlexQueueMonitorSetting__c();
        registroTestAlto.Name = 'Test';
        registroTestAlto.CBK_Aplicacion__c ='Test';
        registroTestAlto.CBK_PrefijoAplicacion__c ='TST';
        registroTestAlto.CBK_Activo__c =true;
        registroTestAlto.CBK_Umbral__c =90;
        registroTestAlto.CBK_MinsIntervaloNotif__c = 15;
        registroTestAlto.CBK_RemitenteCorreo__c =owea[0].Address;
        registroTestAlto.CBK_DestinatarioCorreoTo__c ='test@test.com';
        registroTestAlto.CBK_DestinatarioCorreoCC__c ='test@test.com';
        registroTestAlto.CBK_DestinatarioCorreoCCO__c ='test@test.com';
        lstCSFlexQueueMonitor.add(registroTestAlto);
        insert lstCSFlexQueueMonitor;

        Test.startTest();
        SchedulableContext sc = null;
        CBK_FlexQueueMonitor_Schedule fqmSched = new CBK_FlexQueueMonitor_Schedule();
        fqmSched.execute(sc);
        Integer emailsEnviados = Limits.getEmailInvocations();
        Test.stopTest();
        //Se comenta el assert para evitar errores en instancias donde por email deliverability no se permita el envío de emails
        //system.assertEquals(1, emailsEnviados, 'No coincide los emails enviados con los esperados');
    }
    /**
    * @description Método de test para validar el no envío de emailsi no se ha cumplido el intervalo minimo
    * @author   fzaragoza | 28/06/2021 
    **/
    @isTest static void testIntervaloMinimoNotificacionGeneral() {
        List<OrgWideEmailAddress> owea = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress LIMIT 1];
        List <CBK_FlexQueueMonitorSetting__c> lstCSFlexQueueMonitor = new List <CBK_FlexQueueMonitorSetting__c>();
        CBK_FlexQueueMonitorSetting__c registroGeneralBajo = new  CBK_FlexQueueMonitorSetting__c();
        registroGeneralBajo.Name = 'General';
        registroGeneralBajo.CBK_Aplicacion__c ='General';
        registroGeneralBajo.CBK_PrefijoAplicacion__c ='GRL';
        registroGeneralBajo.CBK_Activo__c =true;
        registroGeneralBajo.CBK_Umbral__c =30;
        registroGeneralBajo.CBK_MinsIntervaloNotif__c =15;
        registroGeneralBajo.CBK_RemitenteCorreo__c =owea[0].Address;
        registroGeneralBajo.CBK_DestinatarioCorreoTo__c ='test@test.com';
        registroGeneralBajo.CBK_DestinatarioCorreoCC__c ='';
        registroGeneralBajo.CBK_DestinatarioCorreoCCO__c ='';
        lstCSFlexQueueMonitor.add(registroGeneralBajo);
        CBK_FlexQueueMonitorSetting__c registroTestAlto = new  CBK_FlexQueueMonitorSetting__c();
        registroTestAlto.Name = 'Test';
        registroTestAlto.CBK_Aplicacion__c ='Test';
        registroTestAlto.CBK_PrefijoAplicacion__c ='TST';
        registroTestAlto.CBK_Activo__c =true;
        registroTestAlto.CBK_Umbral__c =90;
        registroTestAlto.CBK_MinsIntervaloNotif__c = 15;
        registroTestAlto.CBK_RemitenteCorreo__c =owea[0].Address;
        registroTestAlto.CBK_DestinatarioCorreoTo__c ='test@test.com';
        registroTestAlto.CBK_DestinatarioCorreoCC__c ='test@test.com';
        registroTestAlto.CBK_DestinatarioCorreoCCO__c ='test@test.com';
        lstCSFlexQueueMonitor.add(registroTestAlto);
        insert lstCSFlexQueueMonitor;

        CBK_FlexQueueMonitor__c registroPrevio = new CBK_FlexQueueMonitor__c();
        registroPrevio.CBK_Aplicacion__c = 'General';
        registroPrevio.CBK_PrefijoAplicacion__c = 'GRL';
        registroPrevio.CBK_HoldingBatches__c = 90;
        registroPrevio.CBK_PorcentajeConsumoUmbral__c = 150;
        registroPrevio.CBK_NotificacionNecesaria__c = true;
        registroPrevio.CBK_NotificacionRealizada__c = true;
        insert registroPrevio;
        
        Test.startTest();
        SchedulableContext sc = null;
        CBK_FlexQueueMonitor_Schedule fqmSched = new CBK_FlexQueueMonitor_Schedule();
        fqmSched.execute(sc);
        Integer emailsEnviados = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(0, emailsEnviados, 'No coincide los emails enviados con los esperados');
    }
}