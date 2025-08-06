@isTest
public class CSBD_Event_BI_TRHan_Test {

    @isTest
    private static void insertarEventoFirma() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

            Test.startTest();
            Event evento = new Event();
            evento.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CSBD_Firma_Cliente').getRecordTypeId();
            evento.WhatId = oportunidad.Id;
            evento.Subject = 'Firma - ' + oportunidad.Name;
            evento.StartDateTime = System.now();
            evento.EndDateTime = System.now().addHours(1);
            evento.CSBD_Evento_Estado__c = 'Pendiente';
            insert evento;
            Test.stopTest();

            System.assertEquals(
                oportunidad.Id, [SELECT WhatId FROM Event WHERE Id = :evento.Id].WhatId,
                'El evento no se ha creado correctamente'
            );
        }
    }
}