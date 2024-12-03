@isTest
public with sharing class CSBD_Event_BU_TRHan_Test {
    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        
        Account cuenta = crearCuentaContacto('46979396X');

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
    }
    
    private static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        cuenta.Phone = '666666666';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.Phone = '666666666';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }

    public static Opportunity crearOportunidadPrestamo(Account cuenta) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);

        return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    public static Event crearEventoFirma(Opportunity oportunidad) {
        Event evento = new Event();
        evento.RecordTypeId = evento.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'CSBD_Firma_Cliente');
        evento.WhatId = oportunidad.Id;
        evento.Subject = 'Firma - ' + oportunidad.Name;
        evento.StartDateTime = System.now();
        evento.EndDateTime = System.now().addHours(1);
        evento.CSBD_Evento_Estado__c = 'Pendiente';
        evento.OwnerId = userinfo.getUserId();

        insert evento;

        return evento;
    }

    @isTest
    public static void actualizarFechaCitaCliente() {
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];

        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);

        Id idPropietario = null;
        Datetime startDateTime = system.now();

        System.runAs (CSBD_Usuarios.usuarioAdministrador()) {          
            Test.startTest();
            Event evento = CSBD_Opportunity.programarCita(oportunidad.Id, false, false, idPropietario, startDateTime);
            evento.StartDateTime = System.now().addHours(3);
            evento.EndDateTime = System.now().addHours(4);
            update evento;
            Test.stopTest();

            Event nuevoEvento = new Event();
            nuevoEvento = [SELECT Id, StartDateTime FROM Event WHERE Id =: evento.Id];
            CBK_SCH_PendingProcess__c pendingProcessCita = new CBK_SCH_PendingProcess__c();
            pendingProcessCita = [SELECT Id, Schedule_Time__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c =: oportunidad.Id];

            System.assertEquals(nuevoEvento.StartDateTime, pendingProcessCita.Schedule_Time__c, 'La fecha del registro CBK no coincide con la fecha de la última cita');

            Opportunity oportunidadActualizada = new Opportunity();
            oportunidadActualizada = [SELECT Id, CSBD_Fecha_Cita__c FROM Opportunity WHERE Id =: oportunidad.Id];
            
            System.assertEquals(nuevoEvento.StartDateTime, oportunidadActualizada.CSBD_Fecha_Cita__c, 'La fecha registrada en la oportunidad no coincide con la fecha de la última cita');
        }
    }

    @isTest
    public static void actualizarFechaFirmaCliente() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];

        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);
        oportunidad.OwnerId = usuarioGestor.Id;
        update oportunidad;

        Event evento = crearEventoFirma(oportunidad);

        System.runAs (usuarioGestor) {
            Test.startTest();
            evento.StartDateTime = System.now().addHours(3);
            evento.EndDateTime = System.now().addHours(4);
            update evento;
            Test.stopTest();

            Event nuevoEvento = new Event();
            nuevoEvento = [SELECT Id, StartDateTime FROM Event WHERE Id =: evento.Id];

            Opportunity oportunidadActualizada = new Opportunity();
            oportunidadActualizada = [SELECT Id, CSBD_Fecha_Firma__c FROM Opportunity WHERE Id =: oportunidad.Id];
            System.debug('Hora del evento: ' + nuevoEvento.StartDateTime + ' vs Hora en la Oportunidad: ' + oportunidadActualizada.CSBD_Fecha_Firma__c);
            System.assertEquals(nuevoEvento.StartDateTime, oportunidadActualizada.CSBD_Fecha_Firma__c, 'La fecha registrada en la oportunidad no coincide con la fecha de la última cita');
        }
    }
}//Subirlo y comprobarlo