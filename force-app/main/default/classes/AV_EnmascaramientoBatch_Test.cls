/**********************************************************************************************************************
 Name:	  AV_EnmascaramientoBatch_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de test para AV_EnmascaramientoBatch.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde   09/07/2020			Test version

***********************************************************************************************************************/
@isTest
public class AV_EnmascaramientoBatch_Test {

	/**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
        Account clienteParticular = AV_TestHelper.createCustomer();

	}
	/**
	 * Execute the Batch class (AV_EnmascaramientoBatch) 
	 */
	@isTest
	static void executeEnmascaramientoBatch() {
 		
        Id rtId = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA').Id;
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
		
        AV_EnmascaramientoBatch obj = new AV_EnmascaramientoBatch('50000');
        DataBase.executeBatch(obj);
        Test.stopTest();
        
        List<Account> clienteRetrieveList = [Select PersonMobilePhone, CC_Numero_Documento__pc, Description, PersonBirthdate,
                                                PersonEmail, FirstName, LastName from Account where RecordtypeId = :rtId limit 1];
        
        if(!clienteRetrieveList.isEmpty()){
            Account clienteRetrieve = clienteRetrieveList.get(0);
            system.assertEquals('XXXX XXXXXXXXXXXXXXX', clienteRetrieve.Description);
            system.assert(clienteRetrieve.PersonMobilePhone.substring(0, 1) == '6');   
			Boolean result;
            String zipRegex = '[0-9]{8}[A-Z]{1}';
            Pattern myPattern = Pattern.compile(zipRegex);
            Matcher myMatcher = myPattern.matcher(clienteRetrieve.CC_Numero_Documento__pc);
            result = myMatcher.matches();
            system.assert(result == true);
        }
	}
	
}