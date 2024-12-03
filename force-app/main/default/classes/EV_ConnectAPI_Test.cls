/**********************************************************************************************************************
Name:	  EV_ConnectAPI_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description Clase test EV_ConnectAPI
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE				Description
1.0			US785364		Daniel Rodriguez  	14/12/2023			Init version
***********************************************************************************************************************/
@isTest
public class EV_ConnectAPI_Test {
    @isTest
    public static void connectApiTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        Map<String, Object> input = new Map<String, Object>{
            '1' => 'value1',
            '2' => 'value2'
                };
                    
        Test.startTest();
        System.runAs(newUser){		 
            Test.setMock(HttpCalloutMock.class, new EV_ConnectApi_Mock(200));
            Boolean mappingExistsAlready = false; // Puedes ajustar según tus necesidades de prueba
            EV_ConnectAPI conAPI = new EV_ConnectAPI();
		
            EV_ConnectAPI.Response result = conAPI.updateNamedCredential(input, mappingExistsAlready);
            System.assertEquals( result.statusCode, '200','OK');
            
        }
        
        Test.stopTest();
    }
}