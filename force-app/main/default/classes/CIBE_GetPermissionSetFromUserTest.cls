/**********************************************************************************************************************
 Name:	  CIBE_GetPermissionSetFromUserTest
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para la clase CIBE_GetPermissionSetFromUser
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	   AUTHOR		   		DATE			  Description
   1.0          App Utilities  Jose Maria           31/08/2022        Init version
***********************************************************************************************************************/
@isTest
public class CIBE_GetPermissionSetFromUserTest {
    
    @isTest
	public static void getUserPermissionSetTest() {
		User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_OperativaEMP'];
        insert new PermissionSetAssignment(AssigneeId = usrTest.Id, PermissionSetId = ps.Id);

        User usrTest2 = CIBE_TestHelper.createUser('CIBE_Gestor');
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_OperativaCIB'];
        insert new PermissionSetAssignment(AssigneeId = usrTest2.Id, PermissionSetId = ps2.Id);

        System.runAs(usrTest) {
            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'CIBE_MisClientesEMP' LIMIT 1];        
            UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = usrTest.Id, FormFactor = 'Small');
            insert app;
        
            List<String> permission = CIBE_GetPermissionSetFromUser.getUserPermissionSet();
            System.assertEquals('CIBE_OperativaEMP', permission.get(0));
        }

        System.runAs(usrTest2) {
            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'CIBE_MisClientesCIB' LIMIT 1];        
            UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = usrTest2.Id, FormFactor = 'Small');
            insert app;
        
            List<String> permission = CIBE_GetPermissionSetFromUser.getUserPermissionSet();
            System.assertEquals('CIBE_OperativaCIB', permission.get(0));
        }
    }
    
    
}