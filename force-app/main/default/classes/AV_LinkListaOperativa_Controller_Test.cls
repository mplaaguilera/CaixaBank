/**********************************************************************************************************************
Name:	  AV_LinkListaOperativa_Controller_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Unit test to AV_LinkListaOperativa_Controller 
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Gonzalo Ávila 	    12/03/2024		Init version
***********************************************************************************************************************/
@isTest
public class AV_LinkListaOperativa_Controller_Test {
    @TestSetup
	static void setup() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(usuario) {
            
			Account customerTest = AV_TestHelper.createCustomer();
            User u = AV_TestHelper.createUser('AV_Usuario_CaixaBank', null, 'AV_SistematicaComercial');
			AV_TestHelper.insertNeededPermissions(u);
            
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
        }
	}

    @isTest
    public static void testGetLinks(){
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        
        Account customer= [SELECT id FROM Account WHERE AV_NumPerso__c = '123'];
        
        Test.startTest();
        System.runAs(us1){
            List<AV_LinkListaOperativa_Controller.LinkData> listData = AV_LinkListaOperativa_Controller.getLinks('Account', customer.Id, 'AV0001');
        System.assert(!listData.isEmpty());
        Test.stopTest();
        }
    }
}