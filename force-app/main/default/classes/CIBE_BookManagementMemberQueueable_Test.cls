/**********************************************************************************************************************
 Name:	  CIBE_BookManagementMemberQueueable_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase CIBE_BookManagementMemberQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Alex Campos		    29/06/2023			Init version
	
***********************************************************************************************************************/
@isTest
public class CIBE_BookManagementMemberQueueable_Test {

    @TestSetup
	static void setup() {
        CIBE_TestInitialSetup.TestData dataSet = CIBE_TestInitialSetup.setupInitialDataEMP();
    	User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true limit 1];
        
        System.runAs(userCli) {
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            
            User us2 = AV_TestHelper.createUser(AV_AppConstants.AV_PROFILE, 'U01929239');
            
            AV_Book__c book = AV_TestHelper.createPurse('0102102');  
            
            AV_BookMember__c bookMember = AV_TestHelper.createBookMember(dataSet.centro, book);
                
            AV_BookManagementMember__c bookManagement = AV_TestHelper.createBookManagement(dataSet.empleado, book);    
        	
        
        }
    }

	@isTest
	public static void validateAccountQueueble() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		contact conta = AV_TestHelper.createContactAux('Contacto');        
        Contact empleado = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true limit 1];
        Account cuenta = [SELECT ID, AV_EAPGestor__c from account limit 1];
        cuenta.AV_EAPGestor__c = conta.Id;
        update cuenta;
		List<AV_BookManagementMember__c> bookManagementList = [SELECT Id, AV_Cartera__c, AV_EmpleadoGestor__c FROM AV_BookManagementMember__c];
        Map<String, String> empleadoUsuario = new Map<String, String>();
        empleadoUsuario.put(bookManagementList[0].AV_EmpleadoGestor__c, usuario.Id);
        System.runAs(userCli) {
            Test.startTest();
            //List<AV_BookManagementMember__c> carterasGestor, Map<String, String> empleadoUsuario
            CIBE_BookManagementMemberQueueable a1 = new CIBE_BookManagementMemberQueueable(bookManagementList, empleadoUsuario);
            System.enqueueJob(a1);         
            Test.stopTest();
            
            System.assertNotEquals(a1, null);
        }
	}
    
}