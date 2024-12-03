/**********************************************************************************************************************
Name:	  CIBE_CustomPicklistController_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_CustomPicklistController"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	    AUTHOR		   	    DATE				Description
	1.0			US542103	    Lucía Muñoz		    02/03/2023			Init version
	1.1			US616749		Bea					28/06/2023			Add method of test getEmpleadosTest 

***********************************************************************************************************************/
@IsTest
public with sharing class CIBE_CustomPicklistController_Test {

    @TestSetup
    static void setup(){

        string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
		string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
		string rtJerarquia = Schema.getGlobalDescribe().get('CIBE_Hierarchy__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CIBE_Employee').getRecordTypeId();


		CIBE_TestInitialSetup.setupInitialDataEMP();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

		Group userGroup2 = [SELECT Id  FROM Group WHERE Group.DeveloperName = 'CIBE_EditHierarchy' LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())) {

		CBK_PicklistValues__c pick = new CBK_PicklistValues__c();
		pick.RecordTypeId = rtIdPick;
		pick.Name = 'Field Picklist';
		pick.CBK_Object__c = 'Object';
		pick.OwnerId = u.Id;
		insert pick;

        CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
        pickVal.RecordTypeId = rtIdPickVal;
        pickVal.CBK_Picklist__c = pick.Id;
        pickVal.Name = 'Opcion1';
        pickVal.CBK_HasDependency__c = true;
        pickVal.CBK_Dependencies__c = 'Valor1';
		pickVal.OwnerId = u.Id;
        insert pickVal;


        CBK_PicklistValues__c pickVal2 = new CBK_PicklistValues__c();
		pickVal2.RecordTypeId = rtIdPickVal;
		pickVal2.CBK_Picklist__c = pick.Id;
		pickVal2.Name = 'Opcion2';
		pickVal2.CBK_HasDependency__c = true;
		pickVal2.CBK_Dependencies__c = 'Valor2';
		pickVal2.OwnerId = u.Id;
		insert pickVal2;


        CBK_PicklistValues__c pickVal3 = new CBK_PicklistValues__c();
		pickVal3.RecordTypeId = rtIdPickVal;
		pickVal3.Name = 'Opcion3';
		pickVal3.CBK_HasDependency__c = true;
		pickVal3.CBK_Dependencies__c = 'Opcion4';
		pickVal3.OwnerId = u.Id;
		pickVal3.CBK_Object__c = 'Object';
		pickVal3.CBK_Picklist__c = pick.Id;
		insert pickVal3;

		CBK_PicklistValues__c pickVal4 = new CBK_PicklistValues__c();
		pickVal4.RecordTypeId = rtIdPickVal;
		pickVal4.CBK_Picklist__c = pick.Id;
		pickVal4.Name = 'Opcion4';
		pickVal4.CBK_HasDependency__c = true;
		pickVal4.CBK_Dependencies__c = 'Opcion3';
		pickVal4.OwnerId = u.Id;
		pickVal4.CBK_Object__c = 'Object';
		pickVal4.CBK_ParentId__c = pickVal3.CBK_Picklist__c;
		insert pickVal4;

		ID rtCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EMPLOYEE_RT).getRecordTypeId();
		Contact empleado = new Contact();
		empleado.RecordTypeId = rtCon;
		empleado.FirstName = 'Empleado';
		empleado.LastName = 'empleado';
		empleado.CC_Idioma__c = 'es';
		empleado.AV_UsuarioAsociado__c = u.Id;
		empleado.OwnerId = u.Id;
		insert empleado;
		
		CIBE_Hierarchy__c jerarquia = new CIBE_Hierarchy__c();
		jerarquia.CIBE_Negocios__c = pickVal.Id;
		jerarquia.CIBE_RedesSegmentos__c = pickVal2.Id;
		jerarquia.CIBE_SectoresPaises__c = pickVal3.Id;
		jerarquia.CIBE_CentrosCarteras__c = pickVal4.Id;
		jerarquia.CIBE_Contact__c = empleado.Id;
		jerarquia.OwnerId = u.Id;
		insert jerarquia;


		GroupMember GM = new GroupMember();
		GM.GroupId = userGroup2.Id ;
		GM.UserOrGroupId = u.Id;
		insert GM;	

		
    }


    }
    
    @isTest
    public static void picklistValuesTest(){
        
		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_CustomPicklistController.PicklistItems> listValues = CIBE_CustomPicklistController.picklistValues('Field Picklist','Object');
            System.assert(!listValues.isEmpty());
            Test.stopTest();
        }
    }

    @isTest
    public static void picklistValuesDependencyTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_CustomPicklistController.PicklistItems> listValues = CIBE_CustomPicklistController.picklistValuesDependency('Field Picklist', 'Opcion3' ,'Object');
            System.assert(!listValues.isEmpty());
            Test.stopTest();
        }
    }

	@isTest
    public static void insertHierarchyTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario) {
            Test.startTest();
			List<CIBE_Hierarchy__c> listaInsert = [SELECT Id, CIBE_Negocios__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c, CIBE_CentrosCarteras__c, CIBE_Contact__c FROM CIBE_Hierarchy__c LIMIT 1];
			List<CIBE_Hierarchy__c> listValues = CIBE_CustomPicklistController.insertHierarchy(listaInsert);
			System.assert(!listValues.isEmpty());
            Test.stopTest();
        }
    }

	@isTest
    public static void deleteHierarchyTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario) {
			List<CIBE_Hierarchy__c> listaInsert = [SELECT Id, CIBE_Negocios__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c, CIBE_CentrosCarteras__c, CIBE_Contact__c FROM CIBE_Hierarchy__c LIMIT 1];
			CIBE_DeleteHierarchy.deleteHierarchy(listaInsert);
			List<CIBE_Hierarchy__c> result = [SELECT Id FROM CIBE_Hierarchy__c WHERE Id =: listaInsert[0].Id];
			System.assertEquals(0, result.size());
        }
    }

	@isTest
    public static void isEditableTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario) {

			
			Test.startTest();
			Boolean	edita = CIBE_CustomPicklistController.isEditable();
			System.assertEquals(true, edita);
            Test.stopTest();
		}
    }
	
	@isTest
    public static void getHierarchiesTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario) {
            Test.startTest();
			List<CIBE_Hierarchy__c> hierarchies = [SELECT Id, CIBE_Contact__c FROM CIBE_Hierarchy__c LIMIT 1];
			CIBE_CustomPicklistController.getHierarchies(hierarchies[0].CIBE_Contact__c, true);
			System.assertEquals(1, hierarchies.size());
            Test.stopTest();
        }
    }


    @isTest
     static void getDependenciesTest(){
		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
		string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();

        CBK_PicklistValues__c pick = new CBK_PicklistValues__c();
		pick.RecordTypeId = rtIdPick;
		pick.Name = 'Field Picklist';
		pick.CBK_Object__c = 'Object';
		insert pick;

        CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
		pickVal.RecordTypeId = rtIdPickVal;
		pickVal.CBK_Picklist__c = pick.Id;
		pickVal.Name = 'Opcion4';
        pickVal.CBK_Project__c = 'CIBE';
		pickVal.CBK_HasDependency__c = true;
		pickVal.CBK_Dependencies__c = 'Valor2';
        insert new List<CBK_PicklistValues__c>{pickVal};

        

        Test.startTest();
        System.runAs(usuario) {
        
            Map<String, List<String>> result = CIBE_CustomPicklistController.getDependencie('Field Picklist');

            Map<String, List<String>> expected = new Map<String, List<String>>{
                'Opcion4' => new List<String>{'Valor2'}
            };
            System.assertEquals(expected, result);
        Test.stopTest();

        }
     }

	 @isTest
	 public static void getEmpleadosTest(){
		 User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		 System.runAs(usuario) {
			 Test.startTest();
			 List<Contact> empleados =  [SELECT Id, CIBE_Manager__c FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' LIMIT 1];
			 CIBE_CustomPicklistController.getEmpleados(empleados[0].Id);
			 System.assertEquals(1, empleados.size());
			 Test.stopTest();
		 }
	 }

}