/**********************************************************************************************************************
 Name:	  AV_EnmascaramientoEmpresaBatch_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de test para AV_EnmascaramientoEmpresaBatch.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde   13/07/2020			Test version

***********************************************************************************************************************/
@isTest
public class AV_EnmascaramientoEmpresaBatch_Test {

	/**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
        Account clienteEmpresa = AV_TestHelper.createCustomerCompany();


	}

    /**
	 * Execute the Batch class (AV_EnmascaramientoEmpresaBatch) 
	 */
	@isTest
	static void executeEnmascaramientoEmpresaBatch() {
 		
        Id rtId = AV_AppUtilities.getRecordType('Account', 'CC_Cliente').Id;
        List<Account> clienteToUpdateList = new List<Account>();
        List<Account> clientes = [Select Description from Account where RecordtypeId = :rtId limit 1];
        
        if(!clientes.isEmpty()){
            for(Account cliente :clientes){
                cliente.Description = 'Test enmascaramiento';
                clienteToUpdateList.add(cliente);
            }
        }

        update clienteToUpdateList;

        Test.startTest();	
		
        AV_EnmascaramientoEmpresaBatch obj = new AV_EnmascaramientoEmpresaBatch('50000');
        DataBase.executeBatch(obj);
        Test.stopTest();
        
        List<Account> clienteRetrieveList = [Select Description, Phone, Name from Account where RecordtypeId = :rtId limit 1];
        
        if(!clienteRetrieveList.isEmpty()){
            Account clienteRetrieve = clienteRetrieveList.get(0);
            system.assertEquals('XXXX XXXXXXXXXXXXXXX', clienteRetrieve.Description);
            system.assert(clienteRetrieve.Phone.substring(0, 1) == '9');   

        }
	}
	
}