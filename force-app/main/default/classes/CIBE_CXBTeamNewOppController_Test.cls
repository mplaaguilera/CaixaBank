/**********************************************************************************************************************
Name:      CIBE_CXBTeamNewOppController_TestCIBE_CXBTeamNewOppController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_CXBTeamNewOpportunityController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Alicia     		09/02/2023      Init version
    1.1      US379981				Lucía     		04/05/2023      Add getAccountTeamMemberTest method
    1.2      PPM100455545			Lucía     		20/09/2024      Add getContactTest method


***********************************************************************************************************************/
@isTest
public class CIBE_CXBTeamNewOppController_Test {
    @TestSetup
	static void setup(){
        RecordType rtIdPickVal = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_PICKLISTVALUE, CIBE_AppConstants.PICKLIST_VALUE_RT);
        RecordType rtIdPick = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_PICKLISTVALUE, CIBE_AppConstants.PICKLIST_RT);

        CIBE_TestInitialSetup.setupInitialDataEMP();
        User user = [SELECT Id, AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U0000001'];
        User user1 = CIBE_TestHelper.createUser(null, null);

        System.runAs(user) {

            Account accCenter = [SELECT Id FROM Account WHERE Name = '00001 - CENTER'];
            ID rtCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EMPLOYEE_RT).getRecordTypeId();
            Contact empleado = [SELECT Id FROM Contact WHERE FirstName = 'Employee'];

            Account accCliente = CIBE_TestHelper.createCustomer();
            accCliente.ownerId = user.Id;
            accCliente.AV_EAPGestor__c = empleado.Id;
            update accCliente;

            AccountTeamMember accTM = new AccountTeamMember();
                accTM.AccountId = accCliente.Id;
                accTM.UserId = user1.Id;
            insert accTM;


        CBK_PicklistValues__c pick = new CBK_PicklistValues__c();
		pick.RecordTypeId = rtIdPick.Id;
		pick.Name = 'Field Picklist';
		pick.CBK_Object__c = 'Object';
		pick.OwnerId = user.Id;
		insert pick;

        CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
        pickVal.RecordTypeId = rtIdPickVal.Id;
        pickVal.CBK_Picklist__c = pick.Id;
        pickVal.Name = 'Opcion1';
        pickVal.CBK_HasDependency__c = true;
        pickVal.CBK_Dependencies__c = 'Valor1';
		pickVal.OwnerId = user.Id;
        insert pickVal;


        CBK_PicklistValues__c pickVal2 = new CBK_PicklistValues__c();
		pickVal2.RecordTypeId = rtIdPickVal.Id;
		pickVal2.CBK_Picklist__c = pick.Id;
		pickVal2.Name = 'Opcion2';
		pickVal2.CBK_HasDependency__c = true;
		pickVal2.CBK_Dependencies__c = 'Valor2';
		pickVal2.OwnerId = user.Id;
		insert pickVal2;


        CBK_PicklistValues__c pickVal3 = new CBK_PicklistValues__c();
		pickVal3.RecordTypeId = rtIdPickVal.Id;
		pickVal3.Name = 'Opcion3';
		pickVal3.CBK_HasDependency__c = true;
		pickVal3.CBK_Dependencies__c = 'Opcion4';
		pickVal3.OwnerId = user.Id;
		pickVal3.CBK_Object__c = 'Object';
		pickVal3.CBK_Picklist__c = pick.Id;
		insert pickVal3;

		CBK_PicklistValues__c pickVal4 = new CBK_PicklistValues__c();
		pickVal4.RecordTypeId = rtIdPickVal.Id;
		pickVal4.CBK_Picklist__c = pick.Id;
		pickVal4.Name = 'IFI';
		pickVal4.CBK_HasDependency__c = true;
		pickVal4.CBK_Dependencies__c = 'Opcion3';
		pickVal4.OwnerId = user.Id;
		pickVal4.CBK_Object__c = 'Object';
		pickVal4.CBK_ParentId__c = pickVal3.CBK_Picklist__c;
		insert pickVal4;
		
		CIBE_Hierarchy__c jerarquia = new CIBE_Hierarchy__c();
		jerarquia.CIBE_Negocios__c = pickVal.Id;
		jerarquia.CIBE_RedesSegmentos__c = pickVal2.Id;
		jerarquia.CIBE_SectoresPaises__c = pickVal3.Id;
		jerarquia.CIBE_CentrosCarteras__c = pickVal4.Id;
		jerarquia.CIBE_Contact__c = empleado.Id;
		jerarquia.OwnerId = user.Id;
		insert jerarquia;

        }
    }
        
    @isTest
    public static void searchTest(){

        User usuarioGe = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Contact contactEAP = [SELECT Id FROM Contact WHERE FirstName = 'Employee' LIMIT 1];

        System.runAs(usuarioGe){     
            Test.startTest();
            List<Task> taskId = [SELECT id From Task LIMIT 10];
            List<String> selectedIds = new List<String>();     
            String searchTerm= 'CIBE_';    
            for(Task auxId : taskId){
                selectedIds.add(auxId.id);
            }       
            List<AV_LookupSearchResult> results = CIBE_CXBTeamNewOpportunityController.search(searchTerm, contactEAP.Id);
            Test.stopTest();
            System.assertNotEquals(null, results);
        }
    }

    @isTest
    public static void getMembersTest(){
        User usuarioGe = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuarioGe) {

            List<Contact> contactIds = [SELECT id From Contact LIMIT 10];
            List<String> selectedIds = new List<String>();
                for(Contact auxId : contactIds){
                    selectedIds.add(auxId.id);
                }         

            CIBE_CXBTeamNewOpportunityController.getMembers(selectedIds);
            
            System.assertNotEquals(null, selectedIds);
        }
    }

    @isTest
    public static void getAccountTeamMemberTest(){

        User usuarioGe = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.StartTest();
        System.runAs(usuarioGe){

            Map<Id, Contact> mapContact = new Map<Id, Contact>();
           
            Account acc = [SELECT Id, AV_EAPGestor__c FROM Account WHERE Name = 'Name' AND AV_NumPerso__c = '123' AND AV_Negocio__c = 'CIB' LIMIT 1];
            AccountTeamMember acTM = [SELECT Id, UserId FROM AccountTeamMember LIMIT 1]; 
            mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c FROM Contact WHERE FirstName = 'Employee' LIMIT 1]);

            CIBE_CXBTeamNewOpportunityController.getAccountTeamMember(acc.Id, acc.AV_EAPGestor__c);

            System.assertEquals(1, mapContact.size());
        }
        Test.stopTest();

    }

    @isTest
    public static void getContactTest(){

        User usuarioGe = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.StartTest();
        System.runAs(usuarioGe){
            Map<Id, Contact> mapContact = CIBE_CXBTeamNewOpportunityController.getContact('Jamaica');
            System.assert(!mapContact.isEmpty());
        }
        Test.stopTest();

    }

}