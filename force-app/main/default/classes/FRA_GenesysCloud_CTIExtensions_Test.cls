@isTest
public with sharing class FRA_GenesysCloud_CTIExtensions_Test {

    @isTest
    public static void testOnClickToDial() {
		
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c();
            servicio.Name = 'SERVICIO FRAUDE PRUEBA';
        	servicio.CC_Codigo__c = 'HUB_SERVICIO_FRAUDE';
        	servicio.KIN_Cola_Id_GC__c = 'q1';
            servicio.CC_VDN__c = '4444444';
        	servicio.CC_Canal_Procedencia__c ='Teléfono FRAUDE CaixaBankNow';
        	insert servicio;
            
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c='Teléfono FRAUDE CaixaBankNow';
            insert caso;
            Map<String, Object> input1 = new Map<String, Object>{'object' => 'Case', 'objectId' => caso.Id};

            Map<String, Object> input2 = new Map<String, Object>{'object' => 'Account'};

            Test.startTest();
            FRA_GenesysCloud_CTIExtensions ctiExtensions = new FRA_GenesysCloud_CTIExtensions();
            String retorno1 = ctiExtensions.onClickToDial(JSON.serialize(input1));
            String retorno2 = ctiExtensions.onClickToDial(JSON.serialize(input2));
            Test.stopTest();

            Map<String, Object> clickToDialData = (Map<String, Object>)JSON.deserializeUntyped(retorno1);
            System.assert(clickToDialData.containsKey('attributes'), 'Deberían haberse añadido custom attributes a la respuesta.');
            System.assertEquals('', retorno2, 'El retorno debería ser un String vacío al ser no ser object ni "Case".');
        }
    }
}