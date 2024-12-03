@isTest
public with sharing class CC_Notificacion_Test {

    @isTest
    public static void testPublicarToast() {
        //No hay assert porque no aplica probar la publicación del Toast
        List<String> mensajes = new List<String>();
        mensajes.add('mensaje1');
        mensajes.add('mensaje2');
        CC_Notificacion.publicarToast(mensajes, 'info');
    }

    @isTest
    public static void testPublicarToastAviso() {
        //No hay assert porque no aplica probar la publicación del Toast
        List<String> mensajes = new List<String>();
        mensajes.add('mensaje1');
        mensajes.add('mensaje2');
        CC_Notificacion.publicarToastAviso(mensajes);
    }

    @isTest
    public static void testPublicarToastInfo() {
        //No hay assert porque no aplica probar la publicación del Toast
        List<String> mensajes = new List<String>();
        mensajes.add('mensaje1');
        mensajes.add('mensaje2');
        CC_Notificacion.publicarToastInfo(mensajes);
    }
    
    /*
    @isTest
    public static void testEnviarNotificaciones() {

        User usuario = new User();
        usuario.Username = 'testNotificacion@ibm.com';
        usuario.LastName = 'Test';
        usuario.Email = 'testNotificacion@ibm.com';
        usuario.Alias = 'Test';
        usuario.TimeZoneSidKey = 'America/Los_Angeles';
        usuario.LocaleSidKey = 'en_US';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usuario.LanguageLocaleKey = 'en_US';
        insert usuario;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        CC_Notificacion.CC_Custom_Notification notificacion = new CC_Notificacion.CC_Custom_Notification();
        List<Id> idsDestinatarios = new List<Id>();
        idsDestinatarios.add(usuario.Id);
        notificacion.idsDestinatarios = idsDestinatarios;
        notificacion.idTipoNotificacion = '0ML6E0000008OK6WAM';
        notificacion.titulo = 'Título';
        notificacion.cuerpo = 'Cuerpo';
        notificacion.idRegistro = caso.Id;

        List<CC_Notificacion.CC_Custom_Notification> notificaciones = new List<CC_Notificacion.CC_Custom_Notification>();
        notificaciones.add(notificacion);
        CC_Notificacion.enviarNotificaciones(notificaciones);
    }
    */

    @isTest
    public static void testPublicarToastInfo1Mensaje() {
        //No hay assert porque no aplica probar la publicación del Toast
        Test.startTest();
        CC_Notificacion.publicarToastInfo('mensaje');
        Test.stopTest();
    }

    @isTest
    public static void testPublicarToastAviso1Mensaje() {
        //No hay assert porque no aplica probar la publicación del Toast
        Test.startTest();
        CC_Notificacion.publicarToastAviso('mensaje');
        Test.stopTest();
    }

    @isTest
    public static void testPublicarToastAvisoAgrupador() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Id recordTypeCasoCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id sRecordTypeIncidencia = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'ES';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordTypeIncidencia;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Estado__c = 'Activo';
        oAgr.CC_Publica__c = true;
        insert oAgr;

        Case oCaso = new Case();
        oCaso.Subject = 'Test Agrupador Toast';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.ContactId = contacto.Id;
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeCasoCliente;
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        insert oCaso;

        //No hay assert porque no aplica probar la publicación del Toast
        List<CC_Notificacion.AgrupadorMensajeInfo> agrupadorInfoList = new List<CC_Notificacion.AgrupadorMensajeInfo>();
        CC_Notificacion.AgrupadorMensajeInfo agrupadorInfo = new CC_Notificacion.AgrupadorMensajeInfo();
        agrupadorInfo.idAgrupador = oAgr.Id;
        agrupadorInfo.mensaje = 'Se ha generado un nueva incidencia pública: GRP-00000001 - Test Agrupador Toast';
        agrupadorInfoList.add(agrupadorInfo);

        Test.startTest();
        CC_Notificacion.publicarToastAviso(agrupadorInfoList);
        Test.stopTest();
    }

    @isTest
    public static void testPublicarToastError() {
        //No hay assert porque no aplica probar la publicación del Toast
        List<String> mensajes = new List<String>();
        mensajes.add('mensaje1');
        mensajes.add('mensaje2');

        Test.startTest();
        CC_Notificacion.publicarToastError(mensajes);
        Test.stopTest();
    }

    @isTest
    public static void testPublicarToastInfo1Error() {
        //No hay assert porque no aplica probar la publicación del Toast
        Test.startTest();
        CC_Notificacion.publicarToastError('mensaje');
        Test.stopTest();
    }

    @isTest
    public static void testPublicarToastExito() {
        //No hay assert porque no aplica probar la publicación del Toast
        Test.startTest();
        CC_Notificacion.publicarToastExito('mensaje');
        Test.stopTest();
    }
    
}