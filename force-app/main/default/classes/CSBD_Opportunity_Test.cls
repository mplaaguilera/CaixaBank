@isTest
public class CSBD_Opportunity_Test {

    @testSetup
    public static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        User usuarioResponsable = CSBD_Usuarios.usuarioResponsable();

        //Account cuenta = crearCuentaContacto('12345678N');

        CSBD_TestDataFactory.crearCuentaContacto('12345678N');

        /*
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuenta.Id;
        acshare2.UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        insert acshare2;
        */

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        insert valorPrestamo;

        CC_Lista_Valores__c valorTpv = new CC_Lista_Valores__c();
        valorTpv.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorTpv.CC_Lista__c = listaValores.Id;
        valorTpv.Name = 'TPV';
        valorTpv.CC_Valor__c = '5';
        insert valorTpv;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'Standard Price Book';
        insert listaPrecios;

        Pricebook2 pb = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert pb;
    }

    /*
    public static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }
    */

    public static Opportunity crearOportunidadPrestamo(Account cuenta) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Nueva');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Telefono_Solicitud__c', '632999999');
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);

        return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    public static Opportunity crearOportunidadTest(Account cuenta) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Rechazada');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Alta_omnichannel__c', true);
        campos.put('CSBD_Empresa_Proveedora__c', 'imaginBank');
        campos.put('CSBD_Resolucion__c', 'Traspasada a Imagin');
        campos.put('RecordTypeId', Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Desistimiento').getRecordTypeId());

        return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    public static Opportunity crearOportunidadPendienteCli(Account cuenta) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba 2');
        campos.put('CSBD_Estado__c', 'Pendiente Cliente');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('RecordTypeId', Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId());

        return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    public static Integer diasFechaCierre(Id recordTypeId) {
        String recordType = CC_MetodosUtiles.getRecordTypeNameFromId('Opportunity', recordTypeId);
        Integer dias;
        try {
            dias = Integer.valueOf(CC_Listas_Valores.lookupValue('CSBD: Días cierre oportunidad por defecto', recordType));
            return dias;
        } catch (Exception e) {
            return 3;
        }
    }

    private static Opportunity getOpportunity(Id idOpportunity) {
        return [SELECT StageName, CSBD_Resolucion__c, CloseDate, CSBD_Estado__c, Loss_Reason__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Empresa_Proveedora__c, CSBD_Importe_Producto_Principal__c, HasOpportunityLineItem
                FROM Opportunity WHERE Id = :idOpportunity];
    }

    @isTest
    public static void crearOportunidadSinCampos() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs (usuarioGestor) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');
            Test.stopTest();

            Id oportunidadRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo');
            Opportunity oportunidadInsertada = [SELECT Name, StageName, CloseDate, CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals('Nueva', oportunidadInsertada.CSBD_Estado__c, 'No se cumple el estado');
            System.assertEquals('Solicitud', oportunidadInsertada.StageName, 'No se cumple el StageName');
            System.assertEquals(System.today().addDays(diasFechaCierre(oportunidadRecordType)), oportunidadInsertada.CloseDate, 'No se cumple el closed date');
        }
    }

    @isTest
    public static void actualizarPropietarioOmnichannel() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Solicitud';
        oportunidad.CSBD_Estado__c = 'Pendiente Cliente';
        oportunidad.AccountId = cuenta.Id;
        insert oportunidad;

        Map<Id, Id> oportunidadIdOwnerId = new Map<Id, Id>();
        oportunidadIdOwnerId.put(oportunidad.Id, usuarioGestor.Id);

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.actualizarPropietarioOportunidadOmnichannel(oportunidadIdOwnerId);
            Test.stopTest();

            Opportunity laOportunidadInsertada = [SELECT OwnerId, Id FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals(usuarioGestor.Id, laOportunidadInsertada.OwnerId, 'No se Cumple el Owner');
        }
    }

    @isTest
    private static void AltaBajaOmnichannelOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Formalizada';
        oportunidad.CSBD_Resolucion__c = 'Tarjeta crédito';
        oportunidad.Loss_Reason__c = 'Tarjeta crédito';
        oportunidad.CSBD_Estado__c = 'Cerrada';
        oportunidad.AccountId = cuenta.Id;
        //oportunidad.CSBD_Alta_omnichannel__c = false;
        insert oportunidad;

        /*Opportunity oportunidad2 = new Opportunity();
        oportunidad2.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad2.Name = 'Opportunity Test2';
        oportunidad2.StageName = 'Solicitud';
        oportunidad2.CSBD_Estado__c = 'Pendiente Cliente';
        oportunidad2.AccountId = cuenta.Id;
        oportunidad2.CSBD_Alta_omnichannel__c = true;
        insert oportunidad2;*/

        Set<Id> todasLasIdsDePrueba = new Set<Id>();
        todasLasIdsDePrueba.add(oportunidad.Id);
        //todasLasIdsDePrueba.add(oportunidad2.Id);

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.indicarAltaBajaOmnichannelOportunidad(todasLasIdsDePrueba);
            Test.stopTest();

            Opportunity laOportunidadInsertada = [SELECT Id, CSBD_Alta_omnichannel__c FROM Opportunity WHERE Id = :oportunidad.Id];
            //Opportunity laOportunidadInsertada2 = [SELECT Id, CSBD_Alta_omnichannel__c FROM Opportunity WHERE Id = :oportunidad2.Id];

            System.assertEquals(true, laOportunidadInsertada.CSBD_Alta_omnichannel__c, 'No ha sido dada de alta la opp');
            //System.assertEquals(false, laOportunidadInsertada2.CSBD_Alta_omnichannel__c);
        }
    }

    @isTest
    private static void historicoCorreosOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);

        String cuerpoCorreoEntrante = '<b>Correo</b> <i>entrante</i>';
        EmailMessage correoEntrante = new EmailMessage();
        correoEntrante.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correoEntrante.MessageDate = System.now().addDays(-1);
        correoEntrante.CSBD_Oportunidad_Id__c = oportunidad.Id;
        correoEntrante.RelatedToId = oportunidad.Id;
        //correoEntrante.ActivityId = actividadCorreoEntrante.Id;
        correoEntrante.Incoming = true;
        correoEntrante.CC_Interno__c = false;
        correoEntrante.CcAddress = 'correoprueba@gmail.com';
        correoEntrante.Subject = 'Correo entrante Test';
        correoEntrante.HtmlBody = cuerpoCorreoEntrante;
        correoEntrante.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correoEntrante;

        String cuerpoCorreoSaliente = '<b>Correo</b> <i>saliente</i>';
        EmailMessage correoSaliente = new EmailMessage();
        correoSaliente.Status = '3'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correoSaliente.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSaliente.MessageDate = System.now();
        correoSaliente.CSBD_Oportunidad_Id__c = oportunidad.Id;
        correoSaliente.RelatedToId = oportunidad.Id;
        //correoSaliente.ActivityId = actividadCorreoSaliente.Id;
        correoSaliente.Incoming = false;
        correoSaliente.CC_Interno__c = false;
        correoSaliente.CcAddress = 'correoprueba@gmail.com';
        correoSaliente.Subject = 'Correo saliente Test';
        correoSaliente.HtmlBody = cuerpoCorreoSaliente;
        insert correoSaliente;
        // Hacemos un update con la misma información para asegurar el valor de CSBD_Oportunidad_Id__c
        // Un trigger ejecuta CSBD_Oportunidad_Id__c = RelatedTo, pero no podemos informar el RelatedTo a mano
        update correoSaliente;

        System.runAs (usuarioGestor) {
            Test.startTest();
            String historicoCorreos = CSBD_Opportunity.historicoCorreosOportunidad(oportunidad.Id);
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assert(historicoCorreos.contains(cuerpoCorreoEntrante) && historicoCorreos.contains(cuerpoCorreoSaliente), 'No contiene el correo');
        }
    }

    @isTest
    private static void obtenerReferenciaCorreo() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);
        System.runAs (usuarioGestor) {
            Test.startTest();
            System.assert(
                CSBD_Opportunity.obtenerReferenciaCorreo(oportunidad.Id).length() == 17,
                'La referencia del correo debe tener una longitud de 17 caracteres'
            );
            Test.stopTest();
        }
    }


    @isTest
    public static void cerrarOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.FolderId = usuarioGestor.Id;
        plantilla.isActive = true;
        plantilla.Name = 'CSBD Traspaso CMB Imagin';
        plantilla.DeveloperName = 'CSBD_Traspaso_CMB_Imagin';
        plantilla.TemplateType = 'Text';
        plantilla.Subject = 'Test Subject';
        plantilla.HtmlValue = 'Body Subject';
        System.runAs (usuarioGestor) {
            insert plantilla;
        }

        Opportunity oportunidadFormalizada = crearOportunidadPrestamo(cuenta);
        oportunidadFormalizada.Amount=1;
        Opportunity oportunidadPerdida = crearOportunidadPrestamo(cuenta);
        Opportunity oportunidadRechazada = crearOportunidadPrestamo(cuenta);
        Opportunity oportunidadFormalizadaFinal = crearOportunidadTest(cuenta);
        oportunidadFormalizadaFinal.Amount=1;
        Opportunity oportunidadPendienteCliente = crearOportunidadPendienteCli(cuenta);
        oportunidadPendienteCliente.Amount = 1;

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidadPendienteCliente.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        Task tarea = new Task();
        tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CSBD_Task');
        tarea.WhatId = oportunidadPendienteCliente.Id;
        tarea.Type = 'Pendiente Cliente';
        tarea.Status = 'Open';
        tarea.Subject = 'Prueba Oliver';
        tarea.Description = 'Esto es una prueba real';
        tarea.ActivityDate = System.today();
        insert tarea;

        List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
        CC_Lista_Valores__c a1 = new CC_Lista_Valores__c();
        a1.Name = 'CSBD: Traspaso Imagin - Destinatarios';
        a1.CC_Activa__c = true;
        a1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert a1;
        CC_Lista_Valores__c a2 = new CC_Lista_Valores__c();
        a2.CC_Activa__c = true;
        a2.CC_Lista__c = a1.Id;
        a2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        a2.Name = 'CMB';
        a2.CC_Valor__c = 'mailprueba@gmail.com';
        insert a2;



        List<Opportunity> listaOportunidades = new List<Opportunity>();
        oportunidadFormalizada.OwnerId = usuarioGestor.Id;
        oportunidadPerdida.OwnerId = usuarioGestor.Id;
        oportunidadRechazada.OwnerId = usuarioGestor.Id;
        oportunidadFormalizadaFinal.OwnerId = usuarioGestor.Id;
        oportunidadPendienteCliente.OwnerId = usuarioGestor.Id;

        listaOportunidades.add(oportunidadFormalizada);
        listaOportunidades.add(oportunidadPerdida);
        listaOportunidades.add(oportunidadRechazada);
        listaOportunidades.add(oportunidadFormalizadaFinal);
        listaOportunidades.add(oportunidadPendienteCliente);
        update listaOportunidades;

        //Ejecución de la prueba
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.cerrarOportunidad(oportunidadFormalizada.Id, 'Formalizada', 'Tarjeta crédito');
            CSBD_Opportunity.cerrarOportunidad(oportunidadPerdida.Id, 'Perdida', 'No localizado');
            CSBD_Opportunity.cerrarOportunidad(oportunidadRechazada.Id, 'Rechazada', 'Duplicada');
            CSBD_Opportunity.cerrarOportunidad(oportunidadFormalizadaFinal.Id, 'Formalizada', 'Traspasada a Imagin');
            CSBD_Opportunity.cerrarOportunidad(oportunidadPendienteCliente.Id, 'Formalizada', 'Pendiente Cliente');
            Test.stopTest();

            oportunidadFormalizada = getOpportunity(oportunidadFormalizada.Id);
            oportunidadPerdida = getOpportunity(oportunidadPerdida.Id);
            oportunidadRechazada = getOpportunity(oportunidadRechazada.Id);
            oportunidadFormalizadaFinal = getOpportunity(oportunidadFormalizadaFinal.Id);
            oportunidadPendienteCliente = getOpportunity(oportunidadPendienteCliente.Id);
            Task laTareaInsertada = [SELECT Status, CC_Fecha_Fin__c, Type FROM Task WHERE Subject = 'Prueba Oliver' LIMIT 1];

            CC_Lista_Valores__c lalistaInsertada = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = :a1.Name AND Name = :a2.Name AND CC_Activa__c = TRUE LIMIT 1];

            //Evaluación del resultado de la prueba
            System.assertEquals('Formalizada', oportunidadFormalizada.StageName, 'No se cumple');
            System.assertEquals('Cerrada', oportunidadFormalizada.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('Tarjeta crédito', oportunidadFormalizada.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(System.today(), oportunidadFormalizada.CloseDate, 'No se cumple');

            System.assertEquals('Perdida', oportunidadPerdida.StageName, 'No se cumple');
            System.assertEquals('Cerrada', oportunidadPerdida.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('No localizado', oportunidadPerdida.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals('No localizado', oportunidadPerdida.Loss_Reason__c, 'No se cumple');
            System.assertEquals(System.today(), oportunidadPerdida.CloseDate, 'No se cumple');

            System.assertEquals('Rechazada', oportunidadRechazada.StageName, 'No se cumple');
            System.assertEquals('Rechazada', oportunidadRechazada.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('Duplicada', oportunidadRechazada.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals('Duplicada', oportunidadRechazada.Loss_Reason__c, 'No se cumple');
            System.assertEquals(System.today(), oportunidadRechazada.CloseDate, 'No se cumple');

            System.assertEquals('Formalizada', oportunidadFormalizadaFinal.StageName, 'No se cumple');
            System.assertEquals('Cerrada', oportunidadFormalizadaFinal.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('Traspasada a Imagin', oportunidadFormalizadaFinal.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(System.today(), oportunidadFormalizadaFinal.CloseDate, 'No se cumple');
            System.assertEquals('imaginBank', oportunidadFormalizadaFinal.CSBD_Empresa_Proveedora__c, 'No se cumple');

            System.assertEquals('Formalizada', oportunidadPendienteCliente.StageName,'No se cumple');
            System.assertEquals('Cerrada', oportunidadPendienteCliente.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('Pendiente Cliente', oportunidadPendienteCliente.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(System.today(), oportunidadPendienteCliente.CloseDate, 'No se cumple');
            System.assertEquals('Completed', laTareaInsertada.Status, 'No se cumple');
            System.assertEquals(System.now().date(), laTareaInsertada.CC_Fecha_Fin__c.date(), 'No se cumple');
            System.assertEquals(System.now().hourGmt(), Integer.valueOf(laTareaInsertada.CC_Fecha_Fin__c.hourGmt()), 'No se cumple');

            System.assertEquals(a2.CC_Valor__c, lalistaInsertada.CC_Valor__c, 'No se cumple');

        }
    }

    @isTest
    public static void pendienteInterno() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);
        oportunidad.OwnerId = usuarioGestor.Id;
        update oportunidad;

        String motivoPendienteInterno;
        for (Schema.DescribeSobjectResult resultado : Schema.describeSObjects(new List<String>{'Opportunity'})) {
            for (Schema.PicklistEntry picklistEntry : resultado.fields.getMap().get('CSBD_Motivo_Pendiente_Interno__c').getDescribe().getPicklistValues()) {
                if (picklistEntry.isActive()) {
                    motivoPendienteInterno = picklistEntry.getValue();
                    break;
                }
            }
        }

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.pendienteInterno(oportunidad.id, motivoPendienteInterno);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];

            System.assertEquals('Pendiente Interno', oportunidad.CSBD_Estado__c, 'No se cumple');
        }
    }

    @isTest
    public static void reactivarOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        List<Opportunity> listaOportunidades = new List<Opportunity>();
        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Formalizada';
        oportunidad.CSBD_Resolucion__c = 'Tarjeta crédito';
        oportunidad.Loss_Reason__c = 'Tarjeta crédito';
        oportunidad.CSBD_Estado__c = 'Cerrada';
        oportunidad.AccountId = cuenta.Id;
        oportunidad.OwnerId = usuarioGestor.Id;
        listaOportunidades.add(oportunidad);

        Opportunity oportunidad2 = new Opportunity();
        oportunidad2.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad2.Name = 'Opportunity Test';
        oportunidad2.StageName = 'Formalizada';
        oportunidad2.CSBD_Resolucion__c = 'Tarjeta crédito';
        oportunidad2.Loss_Reason__c = 'Tarjeta crédito';
        oportunidad2.CSBD_Estado__c = 'Cerrada';
        oportunidad2.AccountId = cuenta.Id;
        oportunidad2.CSBD_Ultima_Etapa_Ventas__c = 'Cerrada';
        oportunidad2.OwnerId = usuarioGestor.Id;
        listaOportunidades.add(oportunidad2);

        Pricebook2 pb = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert pb;

        Opportunity oportunidad3 = new Opportunity();
        oportunidad3.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad3.Name = 'Opportunity Test';
        oportunidad3.StageName = 'Formalizada';
        oportunidad3.CSBD_Resolucion__c = 'Tarjeta crédito';
        oportunidad3.Loss_Reason__c = 'Tarjeta crédito';
        oportunidad3.CSBD_Estado__c = 'Cerrada';
        oportunidad3.AccountId = cuenta.Id;
        oportunidad3.Pricebook2Id = pb.Id;
        oportunidad3.OwnerId = usuarioGestor.Id;
        listaOportunidades.add(oportunidad3);

        Opportunity oportunidadHija = new Opportunity();
        oportunidadHija.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidadHija.Name = 'Opportunity Test';
        oportunidadHija.StageName = 'Rechazada';
        oportunidadHija.CSBD_Resolucion__c = 'Dupicada';
        oportunidadHija.Loss_Reason__c = 'Dupicada';
        oportunidadHija.CSBD_Estado__c = 'Rechazada';
        oportunidadHija.AccountId = cuenta.Id;
        oportunidadHija.OwnerId = usuarioGestor.Id;
        oportunidadHija.CSBD_Parent_Id__c = oportunidad3.Id;
        listaOportunidades.add(oportunidadHija);
        insert listaOportunidades;

        //Ejecución de la prueba
        System.runAs (usuarioGestor) {
            Test.startTest();
            oportunidad = CSBD_Opportunity.reactivarOportunidad(oportunidad.Id, 'Solicitud');
            oportunidad2 = CSBD_Opportunity.reactivarOportunidad(oportunidad2.Id, true);
            oportunidad3 = CSBD_Opportunity.reactivarOportunidad(oportunidad3.Id);
            oportunidadHija = CSBD_Opportunity.reactivarOportunidad(oportunidadHija.Id);
            Test.stopTest();

            oportunidad = getOpportunity(oportunidad.Id);
            oportunidad2 = getOpportunity(oportunidad2.Id);
            oportunidad3 = getOpportunity(oportunidad3.Id);
            oportunidadHija = getOpportunity(oportunidadHija.Id);

            //Evaluación del resultado de la prueba
            System.assertEquals('Solicitud', oportunidad.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidad.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidad.CSBD_Resolucion__c,'No se cumple');
            System.assertEquals(null, oportunidad.Loss_Reason__c, 'No se cumple');

            System.assertEquals('Cerrada', oportunidad2.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidad2.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidad2.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(null, oportunidad2.Loss_Reason__c, 'No se cumple');

            System.assertEquals('Solicitud', oportunidad3.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidad3.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidad3.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(null, oportunidad3.Loss_Reason__c,'No se cumple');

            System.assertEquals('Solicitud', oportunidadHija.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidadHija.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadHija.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(null, oportunidadHija.Loss_Reason__c,'No se cumple');
        }
    }

    @isTest
    public static void oportunidadEnPendienteCliente(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Formalizada';
        oportunidad.CSBD_Estado__c = 'Activa';
        oportunidad.CSBD_Dejar_Pendiente_Cliente__c = true;
        oportunidad.AccountId = cuenta.Id;
        oportunidad.OwnerId = usuarioGestor.Id;
        insert oportunidad;

        Map<Id, Id> mapaOportunidadesCorreosPendCliente = new Map<Id, Id>();
        mapaOportunidadesCorreosPendCliente.put(oportunidad.Id, oportunidad.Id);

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.oportunidadPendienteCliente(mapaOportunidadesCorreosPendCliente);
            Test.stopTest();

            Opportunity laOportunidadInsertada = [SELECT CSBD_Estado__c, CSBD_Reactivada_Respuesta_Recibida__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals('Pendiente Cliente', laOportunidadInsertada.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(false, laOportunidadInsertada.CSBD_Reactivada_Respuesta_Recibida__c, 'No se cumple');
        }
    }

    @isTest
    public static void findePendienteCliente(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Formalizada';
        oportunidad.CSBD_Estado__c = 'Pendiente Cliente';
        oportunidad.CSBD_Reactivada_Respuesta_Recibida__c = false;
        oportunidad.AccountId = cuenta.Id;
        oportunidad.OwnerId = usuarioGestor.Id;
        insert oportunidad;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.oportunidadFinPendienteCliente(oportunidad.Id);
            Test.stopTest();

            Opportunity laOportunidadInsertada = [SELECT CSBD_Estado__c, CSBD_Reactivada_Respuesta_Recibida__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals(laOportunidadInsertada.CSBD_Estado__c,'Activa', 'No se cumple');
            System.assertEquals(true, laOportunidadInsertada.CSBD_Reactivada_Respuesta_Recibida__c, 'No se cumple');
        }
    }

    @isTest
    public static void prepararOportunidadParaEnvioCorreo() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        //Ejecución de la prueba
        EmailTemplate plantilla = new EmailTemplate();
        plantilla.FolderId = usuarioGestor.Id;
        plantilla.isActive = true;
        plantilla.Name = 'Test Plantilla';
        plantilla.DeveloperName = 'plantillaDeveloperName';
        plantilla.TemplateType = 'Text';
        plantilla.Subject = 'Test Subject';
        plantilla.HtmlValue = 'Body Subject';
        System.runAs (usuarioGestor) {
            insert plantilla;
        }

        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);
        oportunidad.OwnerId = usuarioGestor.Id;
        update oportunidad;

        System.runAs (usuarioGestor) {
            Test.startTest();
            EmailTemplate resultadoPlantilla = CSBD_Opportunity.prepararOportunidadParaEnvioCorreo(oportunidad.Id, 'plantillaDeveloperName', true, false);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Plantilla_Correo__c, CSBD_Referencia_Correo_Saliente__c
                            FROM Opportunity WHERE Id = :oportunidad.Id];
            //Evaluación del resultado de la prueba
            System.assert(oportunidad.CSBD_Plantilla_Correo__c == 'plantillaDeveloperName', 'No se cumple');
            System.assert(oportunidad.CSBD_Referencia_Correo_Saliente__c != null, 'No se cumple');
            System.assertEquals(plantilla.Subject, resultadoPlantilla.Subject, 'No se cumple');
            System.assert(resultadoPlantilla.HtmlValue.contains(plantilla.HtmlValue), 'No se cumple');
            // System.assertEquals(plantilla.HtmlValue, resultadoPlantilla.HtmlValue); MCG:: Reemplazo por assert anterior: Si añado semilla no pueden ser iguales
        }
    }

    @isTest
    private static void crearOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'TPV';
        valor.CC_Valor__c = '5';
        listaValores.CC_Activa__c = true;
        insert valor;

        Map<String, Object> fields = new Map<String, Object>();
        String recordTypeDeveloperName;
        recordTypeDeveloperName = 'CSBD_TPV';
        fields.put('Name', 'temp trigger');
        //fields.put('CSBD_Now_Referencia_Usuario__c', 'Ref. User');
        fields.put('CSBD_Now_Apellido1__c', 'Apellido1');
        fields.put('CSBD_Now_Apellido2__c', 'Apellido1');
        //fields.put('CSBD_Now_EmailCliente__c', 'test@test.com');
        fields.put('CSBD_Email_Solicitud__c', 'test@test.com');
        //fields.put('CSBD_Now_TelOficina__c', '555666333');
        fields.put('CSBD_Now_Num_Oficina__c', Integer.valueOf('1234'));
        //fields.put('CSBD_Now_NUMPERSO__c', '2544588');
        fields.put('CSBD_Now_EmailGestor__c', 'gestor@test.com');
        fields.put('CSBD_Now_Nombre__c', 'NombrePrueba');
        //fields.put('CSBD_Now_HorarioContacto__c', 'Mañana');
        //fields.put('CSBD_Now_TipoIdentificador__c', 'Identificador');
        //fields.put('CSBD_Now_Identificador__c', 'ID-001');
        //fields.put('CSBD_Now_ImporteSolicitado__c', Integer.valueOf('20750'));
        //fields.put('CSBD_Now_TelefonoCliente__c', '936596688');
        fields.put('CSBD_Telefono_Solicitud__c', '936596688');
        //fields.put('CSBD_Now_ImporteDisponible__c', Integer.valueOf('10258'));
        fields.put('StageName', 'Solicitud');

        System.runAs (usuarioGestor) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad(recordTypeDeveloperName, fields);
            Test.stopTest();

            System.assert(oportunidad.Name == 'temp trigger', 'Falla el Name');
            System.assert(oportunidad.CSBD_Now_Apellido1__c == 'Apellido1', 'Falla el apellido 1');
            System.assert(oportunidad.CSBD_Now_Apellido2__c == 'Apellido1', 'Falla el apellido 2');
            System.assert(oportunidad.CSBD_Email_Solicitud__c == 'test@test.com', 'Falla el email');
            System.assert(oportunidad.CSBD_Now_EmailGestor__c == 'gestor@test.com', 'Falla el email gestor');
            System.assert(oportunidad.CSBD_Now_Nombre__c == 'NombrePrueba', 'Falla el Nombre Now');
            System.assert(oportunidad.CSBD_Telefono_Solicitud__c == '936596688', 'Falla el teléfono');
            System.assert(oportunidad.StageName == 'Solicitud', 'Falla la etapa');
        }
    }

    private static Opportunity oportunidadCita() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Solicitud';
        oportunidad.AccountId = cuenta.Id;
        oportunidad.OwnerId = usuarioGestor.Id;

        insert oportunidad;

        return oportunidad;
    }

    @isTest
    private static void programarCita() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Opportunity oportunidad = oportunidadCita();

        Datetime startDateTime = system.now();

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.programarCita(oportunidad.id, false, false, oportunidad.ownerId, startDateTime);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Estado__c, CSBD_Motivo_Pendiente_Interno__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Event[] evento = [SELECT Id, CC_Detalles_Consulta__c FROM Event WHERE WhatId=:oportunidad.id];

            System.assertEquals('Pendiente Cita', oportunidad.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('No Contactado', oportunidad.CSBD_Motivo_Pendiente_Interno__c, 'No se cumple');
            System.assertEquals('No Contactado', evento[0].CC_Detalles_Consulta__c, 'No se cumple');
            System.assert(!evento.isEmpty(), 'No se cumple');
        }
    }

    @isTest
    private static void programarCitaSinIdDePropietario() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Opportunity oportunidad = oportunidadCita();
        oportunidad.OwnerId = usuarioGestor.Id;
        update oportunidad;

        Id idPropietario = null;
        Datetime startDateTime = system.now();

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.programarCita(oportunidad.id, false, false, idPropietario,startDateTime);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Estado__c, CSBD_Motivo_Pendiente_Interno__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Event[] evento = [SELECT Id, CC_Detalles_Consulta__c FROM Event WHERE WhatId=:oportunidad.id];

            System.assertEquals('Pendiente Cita', oportunidad.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('No Contactado', oportunidad.CSBD_Motivo_Pendiente_Interno__c, 'No se cumple');
            System.assertEquals('No Contactado', evento[0].CC_Detalles_Consulta__c, 'No se cumple');
            System.assert(!evento.isEmpty(), 'No se cumple');
        }
    }

    @isTest
    public static void finalizarCita() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad = oportunidadCita();
        oportunidad.CSBD_Asignacion_Auto_Pendiente__c = true;
        update oportunidad;

        List<CSBD_Opportunity.FinalizarClienteInput> listaFinalizaciones = new List<CSBD_Opportunity.FinalizarClienteInput>();
        CSBD_Opportunity.FinalizarClienteInput finalizacion= new CSBD_Opportunity.FinalizarClienteInput();
        finalizacion.nuevoEstado = 'Completado';
        finalizacion.motivoCancelado = '';
        finalizacion.idOportunidad = oportunidad.id;
        listaFinalizaciones.add(finalizacion);

        Event e = new Event(
            Subject = 'Finalizar cita Oliver',
            OwnerId = usuarioGestor.Id,
            AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
            RecordTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Cita_Cliente').getRecordTypeId(),
            EndDateTime = System.now().addMinutes(60),
            DurationInMinutes= null,
            ActivityDateTime = System.today(),
            StartDateTime = System.today(),
            WhatId = oportunidad.id,
            CSBD_Evento_Estado__c = 'Pendiente'
        );
        insert e;

        Opportunity oportunidad2 = new Opportunity();
        oportunidad2.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad2.Name = 'Opportunity Test';
        oportunidad2.StageName = 'Solicitud';
        oportunidad2.AccountId = cuenta.Id;
        oportunidad2.OwnerId = usuarioGestor.Id;
        insert oportunidad2;

        oportunidad2.CSBD_Asignacion_Auto_Pendiente__c = false;
        update oportunidad2;

        List<CSBD_Opportunity.FinalizarClienteInput> listaFinalizaciones2 = new List<CSBD_Opportunity.FinalizarClienteInput>();
        CSBD_Opportunity.FinalizarClienteInput finalizacion2= new CSBD_Opportunity.FinalizarClienteInput();
        finalizacion2.nuevoEstado = 'Cancelado';
        finalizacion2.motivoCancelado = 'Canceladisimo';
        finalizacion2.idOportunidad = oportunidad2.id;
        listaFinalizaciones2.add(finalizacion2);

        Event e2 = new Event(
            Subject = 'Finalizar cita Oliver2',
            OwnerId = usuarioGestor.Id,
            AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
            RecordTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Cita_Cliente').getRecordTypeId(),
            EndDateTime = System.now().addMinutes(60),
            DurationInMinutes= null,
            ActivityDateTime = System.today(),
            StartDateTime = System.today(),
            WhatId = oportunidad2.id,
            CSBD_Evento_Estado__c = 'Pendiente'
        );
        insert e2;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.finalizarCita(listaFinalizaciones);
            CSBD_Opportunity.finalizarCita(listaFinalizaciones2, false);
            Test.stopTest();

            Opportunity oportunidadQuery = [SELECT CSBD_Estado__c, CSBD_Fecha_Cita__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Fecha_ultimacita__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Opportunity oportunidadQuery2 = [SELECT CSBD_Estado__c, CSBD_Fecha_Cita__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Fecha_ultimacita__c FROM Opportunity WHERE Id = :oportunidad2.Id];
            Event evento = [SELECT CSBD_Evento_Estado__c, CC_Tipo_Cierre__c FROM Event WHERE WhatId=:oportunidad.id LIMIT 1];
            Event evento2 = [SELECT CSBD_Evento_Estado__c, CC_Tipo_Cierre__c FROM Event WHERE WhatId=:oportunidad2.id LIMIT 1];

            System.assertEquals(System.now().date(), oportunidadQuery.CSBD_Fecha_ultimacita__c.date(), 'No se cumple');
            System.assertEquals(System.now().hourGmt(), Integer.valueOf(oportunidadQuery.CSBD_Fecha_ultimacita__c.hourGmt()), 'No se cumple');
            System.assertEquals('Activa', oportunidadQuery.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadQuery.CSBD_Fecha_Cita__c, 'No se cumple');
            System.assertEquals(false, oportunidadQuery.CSBD_Asignacion_Auto_Pendiente__c, 'No se cumple');

            System.assertEquals('Activa', oportunidadQuery2.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadQuery2.CSBD_Fecha_Cita__c, 'No se cumple');
            System.assertEquals(false, oportunidadQuery2.CSBD_Asignacion_Auto_Pendiente__c, 'No se cumple');

            System.assertEquals('Completado',evento.CC_Tipo_Cierre__c, 'No se cumple');
            System.assertEquals('Completado',evento.CSBD_Evento_Estado__c, 'No se cumple');
            System.assertEquals('Canceladisimo',evento2.CC_Tipo_Cierre__c, 'No se cumple');
            System.assertEquals('Cancelado',evento2.CSBD_Evento_Estado__c, 'No se cumple');
        }
    }

    @isTest
    public static void finalizarCita2() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Opportunity oportunidad = oportunidadCita();

        Event e = new Event(
            Subject = 'Finalizar cita Oliver2',
            OwnerId = usuarioGestor.Id,
            AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
            RecordTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Cita_Cliente').getRecordTypeId(),
            EndDateTime = System.now().addMinutes(60),
            DurationInMinutes= null,
            ActivityDateTime = System.today(),
            StartDateTime = System.today(),
            WhatId = oportunidad.id,
            CSBD_Evento_Estado__c = 'Pendiente'
        );
        insert e;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_Opportunity.finalizarCita(oportunidad.Id,'Completado', null, false);
            Test.stopTest();

            Opportunity oportunidadQuery = [SELECT CSBD_Estado__c, CSBD_Fecha_Cita__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Fecha_ultimacita__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Event evento = [SELECT CSBD_Evento_Estado__c, CC_Tipo_Cierre__c FROM Event WHERE WhatId=:oportunidad.id LIMIT 1];

            System.assertEquals('Activa', oportunidadQuery.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadQuery.CSBD_Fecha_Cita__c, 'No se cumple');
            System.assertEquals(false, oportunidadQuery.CSBD_Asignacion_Auto_Pendiente__c, 'No se cumple');

            System.assertEquals('Completado',evento.CC_Tipo_Cierre__c, 'No se cumple');
            System.assertEquals('Completado',evento.CSBD_Evento_Estado__c, 'No se cumple');
        }
    }

    @isTest
    public static void actualizarEstadoOportunidad_Test() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Map<String, Object> fields = new Map<String, Object>();
        fields.put('CSBD_Now_Apellido1__c', 'Apellido1');
        fields.put('CSBD_Now_Apellido2__c', 'Apellido1');
        fields.put('CSBD_Email_Solicitud__c', 'test@test.com');
        fields.put('CSBD_Now_Num_Oficina__c', Integer.valueOf('1234'));
        fields.put('CSBD_Now_EmailGestor__c', 'gestor@test.com');
        fields.put('CSBD_Now_Nombre__c', 'NombrePrueba');
        fields.put('CSBD_Telefono_Solicitud__c', '936596688');
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_TPV', fields);

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidad.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs (usuarioGestor) {
            Test.startTest();
            oportunidad.CSBD_Estado__c = 'Pendiente Cita';
            oportunidad.StageName = 'Gestión';
            oportunidad.OwnerId = usuarioGestor.Id;
            update oportunidad;
            Test.stopTest();

            System.assert(oportunidad.CSBD_Now_Apellido1__c == 'Apellido1', 'Falla el apellido 1');
            System.assert(oportunidad.CSBD_Now_Apellido2__c == 'Apellido1', 'Falla el apellido 2');
            System.assert(oportunidad.CSBD_Email_Solicitud__c == 'test@test.com', 'Falla el email');
            System.assert(oportunidad.CSBD_Now_EmailGestor__c == 'gestor@test.com', 'Falla el email gestor');
            System.assert(oportunidad.CSBD_Now_Nombre__c == 'NombrePrueba', 'Falla el Nombre Now');
            System.assert(oportunidad.CSBD_Telefono_Solicitud__c == '936596688', 'Falla el teléfono');
            System.assert(oportunidad.CSBD_Estado__c == 'Pendiente Cita', 'Falla el estado');
        }

    }

    @isTest
    private static void duplicarOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Opportunity oportunidadFormalizada = crearOportunidadPrestamo(cuenta);

        System.runAs (usuarioGestor) {
            Test.startTest();
            Opportunity oppDuplicada = CSBD_Opportunity.duplicarOportunidad(oportunidadFormalizada, 'CSBD_Prestamo', 'CaixaBank');
            Test.stopTest();

            oppDuplicada = [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :oppDuplicada.Id];

            System.assertEquals(oportunidadFormalizada.Id, oppDuplicada.CSBD_Parent_Id__c);
        }
    }

    @isTest
    public static void controlDuplicados() {
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

        Opportunity oportunidad1 = crearOportunidadPrestamo(cuenta);
        Opportunity oportunidad2 = crearOportunidadPrestamo(cuenta);

        List<Id> listaIds = new List<Id>();
        listaIds.add(oportunidad2.Id);

        System.runAs (CSBD_Usuarios.usuarioAdministrador()) {
            Test.startTest();
            CSBD_Control_Duplicados.controlDuplicados(listaIds);
            Test.stopTest();

            oportunidad1 = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad1.Id];
            oportunidad2 = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad2.Id];

            System.assertEquals('Rechazada', oportunidad1.CSBD_Estado__c, 'La oportunidad 1 debería haberse rechazado por duplicada.');
            System.assertEquals('Nueva', oportunidad2.CSBD_Estado__c, 'El estado de la oportunidad 2 debería ser "Nueva".');
        }
    }

    @isTest
    public static void intouchEnviarEmail() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666667');
        campos.put('CSBD_Empresa_Proveedora__c', 'inTouch');
        campos.put('CSBD_Contact__c',contacto.Id);
        campos.put('Amount',1);
        Opportunity cMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);

        cMB.OwnerId = usuarioGestor.Id;
        update cMB;

        System.runAs (usuarioGestor) {
            Test.startTest();
            cMB.CSBD_Estado__c = 'Cerrada';
            cMB.StageName = 'Formalizada';
            update cMB;
            Test.stopTest();

            System.Assert([SELECT Count() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: cMB.Id]>0, 'No se ha enviado ningún email');
        }
    }


      @isTest
    public static void agendarFirmaTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Opportunity prestamo = crearOportunidadPrestamo(cuenta);
        prestamo.OwnerId = usuarioGestor.Id;
        update prestamo;
        datetime fecha = System.now();

        System.runAs ( usuarioGestor ) {
            Test.startTest();
            Event nuevoEvento = CSBD_Opportunity.agendarFirma(prestamo.id, true, fecha);
            Opportunity prestamoActualizado = [SELECT Id, CSBD_Fecha_Firma__c, CSBD_Firma_segura__c from Opportunity where Id =:prestamo.id];
            System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, fecha, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, true, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals([SELECT Id FROM Event WHERE Id = :nuevoEvento.Id].isEmpty(), false, 'No se ha creado el evento correctamente');
            Test.stopTest();
        }
    }

      @isTest
    public static void cancelarFirmaTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Opportunity prestamo = crearOportunidadPrestamo(cuenta);
        prestamo.OwnerId = usuarioGestor.Id;
        update prestamo;
        datetime fecha = System.now();

        System.runAs ( usuarioGestor ) {
            Test.startTest();
            Event nuevoEvento1 = CSBD_Opportunity_Operativas_Controller.agendarFirmaApex(prestamo.id, true, fecha);
            Event nuevoEvento = CSBD_Opportunity.cancelarFirma(prestamo.id);
            Opportunity prestamoActualizado = [SELECT Id, CSBD_Fecha_Firma__c, CSBD_Firma_segura__c from Opportunity where Id =:prestamo.id];
            System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, null, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, false, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals([SELECT Id,CSBD_Evento_Estado__c FROM Event WHERE Id = :nuevoEvento.Id][0].CSBD_Evento_Estado__c, 'Cancelado', 'No se ha actualizado el evento correctamente');
            Test.stopTest();
        }
    }

    @isTest
    private static void convertirOportunidadTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Opportunity oportunidadFormalizada = crearOportunidadPrestamo(cuenta);

        System.runAs (usuarioGestor) {
            Test.startTest();
            Opportunity oppTrasladada = CSBD_Opportunity.convertirOportunidad(oportunidadFormalizada, 'CSBD_Prestamo');
            Test.stopTest();

            oppTrasladada = [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :oppTrasladada.Id];

            System.assertEquals(oportunidadFormalizada.Id, oppTrasladada.CSBD_Parent_Id__c, 'No se cumple');
        }
    }
}