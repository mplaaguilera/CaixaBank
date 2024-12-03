/**********************************************************************************************************************
Name:	  AV_CustomCommentsHistory_Controller_Test
Copyright © 2024  CaixaBank
=======================================================================================================================
Proposito: Clase de test para AV_CustomCommentsHistory_Controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Text Class		Gonzalo Ávila  	    31/01/2024		Init version

***********************************************************************************************************************/
@isTest
public class AV_CustomCommentsHistory_Controller_Test {
    
    @TestSetup
	static void setup(){
       
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
        
        
        Account acc = AV_TestHelper.createCustomer();
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);


        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name IN :new List<String>{ 'AV_GestorOperativa', 'AV_CustomMetadata' }];
        for(PermissionSet ps : perSet) {
            permissionSetList.add(
                new PermissionSetAssignment(
                    AssigneeId = userGestor.Id, 
                    PermissionSetId = ps.Id
                ));
            }
            if(!permissionSetList.isEmpty()) {
                insert permissionSetList;
            }
            
        }

	}

    @isTest
    public static void getComments(){
        User userGestor = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        AV_CustomCommentsHistory_Controller.DataResponse response = new  AV_CustomCommentsHistory_Controller.DataResponse();

        Test.startTest();
        System.runAs(userGestor){
            List<Opportunity> listOpp = [SELECT ID FROM OPPORTUNITY LIMIT 1];     
            Opportunity opp = listOpp.get(0);            
            response = AV_CustomCommentsHistory_Controller.getRecords(opp.Id);
        }
       Test.stopTest();        
       System.assertEquals(1, response.data.size());
    }
}