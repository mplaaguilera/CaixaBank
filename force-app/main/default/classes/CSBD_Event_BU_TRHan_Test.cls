@isTest
public class CSBD_Event_BU_TRHan_Test {

    @isTest
    private static void actualizarFechaCitaCliente() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Map<String, Object> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('46979396X', new Map<String, Object>{
                'LastName' => 'test@test.com',
                'Phone' => '666666666',
                'Email' => 'test@test.com',
                'FirstName' => 'Nombre',
                'LastName' => 'Apellido'
            });
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto = (Contact)cuentaContacto.get('contacto');

            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
            System.runAs(usuarioGestor) {
                Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                    'CSBD_Estado__c' => 'Activa',
                    'AccountId' => cuenta.Id,
                    'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c
                });

                Datetime startDateTime = System.now();

                Test.startTest();
                Event evento = CSBD_Opportunity.programarCita(oportunidad.Id, false, false, null, startDateTime);

                oportunidad.OwnerId = usuarioGestor.Id;
                update oportunidad;

                evento.StartDateTime = System.now().addHours(3);
                evento.EndDateTime = System.now().addHours(4);
                update evento;
                Test.stopTest();

                Event nuevoEvento = new Event();
                nuevoEvento = [SELECT StartDateTime FROM Event WHERE Id = :evento.Id];
                CBK_SCH_PendingProcess__c pendingProcessCita = new CBK_SCH_PendingProcess__c();
                pendingProcessCita = [SELECT Schedule_Time__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :oportunidad.Id];

                System.assertEquals(nuevoEvento.StartDateTime, pendingProcessCita.Schedule_Time__c, 'La fecha del registro CBK no coincide con la fecha de la última cita');

                Opportunity oportunidadActualizada = [SELECT CSBD_Fecha_Cita__c FROM Opportunity WHERE Id =: oportunidad.Id];

                System.assertEquals(nuevoEvento.StartDateTime, oportunidadActualizada.CSBD_Fecha_Cita__c, 'La fecha registrada en la oportunidad no coincide con la fecha de la última cita');
            }
        }
    }

    @isTest
    private static void actualizarFechaFirmaCliente() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Map<String, Object> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('46979396X', new Map<String, Object>{
                'LastName' => 'test@test.com',
                'Phone' => '666666666',
                'Email' => 'test@test.com',
                'FirstName' => 'Nombre',
                'LastName' => 'Apellido'
            });
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto = (Contact)cuentaContacto.get('contacto');

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                    'AccountId' => cuenta.Id,
                    'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c
                });

                Event evento = new Event();
                evento.RecordTypeId = evento.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'CSBD_Firma_Cliente');
                evento.WhatId = oportunidad.Id;
                evento.Subject = 'Firma - ' + oportunidad.Name;
                evento.StartDateTime = System.now();
                evento.EndDateTime = System.now().addHours(1);
                evento.CSBD_Evento_Estado__c = 'Pendiente';
                evento.OwnerId = userinfo.getUserId();
                insert evento;

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
    }
}