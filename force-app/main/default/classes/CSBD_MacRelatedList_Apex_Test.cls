@isTest
private class CSBD_MacRelatedList_Apex_Test {

	@testSetup
	private static void setupTestData() {
		CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c(
			RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId(),
			Name = 'CSBD: Configuración de rellamadas'
		);
		insert listaValores;

		insert new List<CC_Lista_Valores__c>{
			new CC_Lista_Valores__c(
				RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId(),
				CC_Lista__c = listaValores.Id,
				Name = 'Permitir vincular a llamadas abiertas con antigüedad de hasta N días',
				CC_Valor__c = '21'
			),
			new CC_Lista_Valores__c(
				RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId(),
				CC_Lista__c = listaValores.Id,
				Name = 'Permitir vincular a llamadas cerradas con antigüedad de hasta N días',
				CC_Valor__c = '2'
			)
		};
	}

	@isTest
	private static void getOtrasLlamadas() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{
                'CSBD_Now_Origen__c' => 'Asistencia Comercial Centralita',
                'CSBD_Telefono_Solicitud__c' => '650123123',
                'CSBD_Motivo_MAC__c' => 'motivo de prueba'
            });

			CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{
                'CSBD_Now_Origen__c' => 'Otro origen',
                'CSBD_Telefono_Solicitud__c' => '650123123',
                'CSBD_Motivo_MAC__c' => 'motivo de prueba'
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
                'CSBD_Telefono_Solicitud__c' => '650123123',
                'CSBD_Motivo_MAC__c' => 'motivo de prueba'
            });

			Opportunity oppPadre = CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{
                'CSBD_Now_Origen__c' => 'Otro origen',
                'CSBD_Telefono_Solicitud__c' => '650123123',
                'CSBD_Motivo_MAC__c' => 'motivo de prueba'
            });

            String identificadorPadre = [SELECT CSBD_Identificador__c FROM Opportunity WHERE Id = :oppPadre.Id].CSBD_Identificador__c;

			Test.startTest();
            CSBD_MacRelatedListApex.crearTareaVinculacion(oppCentralita.Id, identificadorPadre);
			Test.stopTest();

            Integer numtareasVinculacion = [SELECT COUNT() FROM Task WHERE WhatId = :oppCentralita.Id AND Type = 'Vinculación a oportunidad padre' LIMIT 2];
			System.assertEquals(1, numtareasVinculacion, 'Debería haberse creado 1 tarea de tipo "Vinculación a oportunidad padre"');
		}
	}
}