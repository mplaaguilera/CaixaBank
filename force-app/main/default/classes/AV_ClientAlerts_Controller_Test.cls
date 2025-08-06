/**********************************************************************************************************************
Name:	  AV_ClientAlerts_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_ClientAlerts_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Álvaro López	   	   29/09/2020		Init version
1.1			Fix			   Sandra Gómez		   20/04/2022		Fix Date Refresh
1.2         US866754       Oscar Moreno        25/04/2024       Add  testGetJsonAlertas and testGetJsonAlertasWithEmptyList  method          
***********************************************************************************************************************/
@isTest
public with sharing class AV_ClientAlerts_Controller_Test {
    private static final String AV_USUARIO_CAIXABANK = 'AV_Usuario_CaixaBank';


    @TestSetup
    static void setup(){
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userGestor;
        System.runAs(userGcf){
            userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            insert userGestor;

            Account cliente2 = AV_TestHelper.createCustomerSinInsert();
            cliente2.OwnerId = userGestor.id;
            insert cliente2;

            Opportunity op = AV_TestHelper.createOpportunity(cliente2);

        }

    }

    
    

    @isTest
    private static void retrieveAlertsUpdatedTest(){
        String userId = '13550';

        Test.startTest();	
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_WARNINGDATA','OK'));	
        String currentJson = '[{"value":"Contrato marco","key":"17"},{"value":"Cliente con reclamaciones históricas","key":"25"},{"value":"Información de seguimiento","key":"11"},{"value":"Cobros pendientes","key":"4"},{"value":"Cliente con alertas de seguimiento","key":"10"}]';
        String response = AV_ClientAlerts_Controller.retrieveAlerts(userId, System.now(), currentJson);
        //String response2 =  AV_ClientAlerts_Controller.retrieveAlerts(userId, null, null);
        Test.stopTest();
		System.assertEquals('UPDATED', response);
    }

    @isTest
    private static void retrieveAlertsNullUserIDTest(){
        String userId = '13550';

        Test.startTest();	
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_WARNINGDATA','OK'));
        String response = AV_ClientAlerts_Controller.retrieveAlerts(null, null, null);
        Test.stopTest();
		System.assertEquals('ERROR', response);
    }
    

    @isTest
    static void testGetJsonAlertas() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
        
        Account cliente2 = [SELECT Id from Account LIMIT 1];
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        

        AV_ClientAlerts_Controller.Alerta alerta = new AV_ClientAlerts_Controller.Alerta();
        alerta.key = 'Test Key';
        alerta.value = 'Test Value';

        System.runAs(userGestor){  

            List<AV_ClientAlerts_Controller.Alerta> alertasList = new List<AV_ClientAlerts_Controller.Alerta>();
            alertasList.add(alerta);
            String jsonAlertas = JSON.serialize(alertasList);
            cliente2.AV_JSONAlertas__c = jsonAlertas;
            update cliente2;
            
        }


      
        Test.startTest();
        List<AV_ClientAlerts_Controller.Alerta> result = AV_ClientAlerts_Controller.getJsonAlertas(cliente2.Id, 'Account');
        List<AV_ClientAlerts_Controller.Alerta> result2 = AV_ClientAlerts_Controller.getJsonAlertas(op.Id, 'Opportunity');

        Test.stopTest();

      
        System.assertEquals(1, result.size(), 'Debe haber una alerta en la lista');
        AV_ClientAlerts_Controller.Alerta resultAlerta = result[0];
        System.assertEquals('Test Key', resultAlerta.key, 'La clave de la alerta debe ser Test Key');
        System.assertEquals('Test Value', resultAlerta.value, 'El valor de la alerta debe ser Test Value');
    }

    @isTest
    static void testGetJsonAlertasWithEmptyList() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];

        Account cliente2 = [SELECT Id from Account LIMIT 1];
        System.runAs(userGestor){  

            cliente2.AV_JSONAlertas__c = null;
            update cliente2;
            
        }

        

        
        Test.startTest();
        List<AV_ClientAlerts_Controller.Alerta> result = AV_ClientAlerts_Controller.getJsonAlertas(cliente2.Id, 'Account');
        Test.stopTest();

        
        System.assertEquals(0, result.size(), 'La lista de alertas debe estar vacía');
    }

}