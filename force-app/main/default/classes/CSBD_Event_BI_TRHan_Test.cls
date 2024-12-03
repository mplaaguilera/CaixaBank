@isTest
public with sharing class CSBD_Event_BI_TRHan_Test {
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

        return evento;
    }

    @isTest
    public static void insertarEventoFirma() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];

        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidad.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs ( usuarioGestor ) {
            oportunidad.OwnerId = usuarioGestor.Id;
            update oportunidad;
            
            Test.startTest();
            Event evento = crearEventoFirma(oportunidad);
            insert evento;
            Test.stopTest();

            Event nuevoEvento = new Event();
            nuevoEvento = [SELECT Id, StartDateTime, WhatId FROM Event WHERE Id =: evento.Id];

            Opportunity oportunidadActualizada = new Opportunity();
            oportunidadActualizada = [SELECT Id, CSBD_Fecha_Firma__c FROM Opportunity WHERE Id =: oportunidad.Id];
            
            System.assertEquals(nuevoEvento.WhatId, oportunidadActualizada.Id, 'El evento no se ha creado correctamente');
        }
    }
}