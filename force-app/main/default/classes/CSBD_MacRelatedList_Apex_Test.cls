@isTest
private class CSBD_MacRelatedList_Apex_Test {

	@isTest
	private static void getOtrasLlamadas() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{
                'CSBD_Now_Origen__c' => 'Asistencia Comercial Centralita',
                'CSBD_Telefono_Solicitud__c' => '650123123'
            });

			CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{
                'CSBD_Now_Origen__c' => 'Otro origen',
                'CSBD_Telefono_Solicitud__c' => '650123123'
            });

			Test.startTest();
            List<Opportunity> otrasLlamadas = CSBD_MacRelatedListApex.getOtrasLlamadas('650123123');
			Test.stopTest();

			System.assertEquals(1, otrasLlamadas.size(), 'Debería haber solo otra oportunidad AC con el mismo número');
		}
	}

	@isTest
	private static void crearTareaVinculacion() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity oppCentralita = CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{
                'CSBD_Now_Origen__c' => 'Asistencia Comercial Centralita',
                'CSBD_Telefono_Solicitud__c' => '650123123'
            });

			Opportunity oppPadre = CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{
                'CSBD_Now_Origen__c' => 'Otro origen',
                'CSBD_Telefono_Solicitud__c' => '650123123'
            });

            String identificadorPadre = [SELECT CSBD_Identificador__c FROM Opportunity WHERE Id = :oppPadre.Id].CSBD_Identificador__c;

			Test.startTest();
            CSBD_MacRelatedListApex.crearTareaVinculacion(oppCentralita.Id, identificadorPadre);
			Test.stopTest();

            List<Task> tareasVinculacion = [SELECT Id FROM Task WHERE WhatId = :oppCentralita.Id AND Type = 'Vinculación a oportunidad padre' LIMIT 2];
			System.assertEquals(1, tareasVinculacion.size(), 'Debería haberse creado 1 tarea de tipo "Vinculación a oportunidad padre"');
		}
	}
}
