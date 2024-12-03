/**********************************************************************************************************************
 Name:	  CIBE_GruposComerciales_Controller_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para el controlador CIBE_GruposComerciales_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jose Maria			29/09/2022			Test Class
	1.1			US461300		Alex Campos	    03/11/2022		    Ordenacion por cartera y alfabeticamente
	1.2			US561277		Lucía Muñoz	    14/04/2023		    Implementacion de runAs y subida de cobertura
 	1.3         US567783        Luis Martínez       30/06/2023          Diferenciación Interlocutor/Miembro en el Rol
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_GruposComerciales_Controller_Test {

    @TestSetup
    static void setUp(){
        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        String rtAccountEco = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
		String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
		String rtAccountRelationEco = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
        String rtAccountGrupoComercial = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        User userAdmin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        
        System.runAs(userAdmin){
            List<Account> lstAccounts = new  List<Account>();
            Account acc = new Account(
                Name = 'Grupo Comercial',
                RecordtypeId = rtAccount,
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1), 
                OwnerId = usuario.Id
            );
            // insert acc;
            lstAccounts.add(acc);
            Account accEco = new Account(
                Name = 'Grupo Economico 1',
                RecordtypeId = rtAccountEco,
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                OwnerId = usuario.Id
            );
            // insert accEco;
            lstAccounts.add(accEco);
            
            Account accEco2 = new Account(
                Name = 'Grupo Economico 2',
                RecordtypeId = rtAccountEco,
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                OwnerId = usuario.Id
            );
            // insert accEco2;
            lstAccounts.add(accEco2);
    
            Account accTest = CIBE_TestHelper.createCustomer();
            accTest.OwnerId = usuario.Id;
            update accTest;
            // lstAccounts.add(accTest);
    
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account accTest2 = new Account(
                Name = 'Name 2',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '1232',
                AV_Negocio__c = 'CIB',
                AV_Interlocutor__c = accTest.Id,
                OwnerId = usuario.Id
            );
            // insert accTest2;
            lstAccounts.add(accTest2);
    
            Account accTest3 = new Account(
                Name = 'Name 3',
                RecordTypeId = rtAccountGrupoComercial,
                AV_NumPerso__c = '1111',
                AV_Negocio__c = 'CIB',
                AV_Interlocutor__c = accTest.Id,
                OwnerId = usuario.Id
            );
            // insert accTest3;
            lstAccounts.add(accTest3);
            Insert lstAccounts;
    
            Contact conTest = CIBE_TestHelper.createEmployee(accTest, usuario);
    
            FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
                Name = 'Parent',
                FinServ__InverseRole__c = 'Cliente',
                OwnerId = usuario.Id
            );
            insert role;
            
            FinServ__AccountAccountRelation__c accR = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = acc.id,
                FinServ__RelatedAccount__c = accTest.id,
                CIBE_Matriz__c = true,
                FinServ__Role__c = role.id,
                OwnerId = usuario.Id
            );
            FinServ__AccountAccountRelation__c accR2 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = acc.id,
                FinServ__RelatedAccount__c = accTest2.id,
                FinServ__Role__c = role.id,
                OwnerId = usuario.Id
            );
    
            FinServ__AccountAccountRelation__c accR6 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = acc.id,
                FinServ__RelatedAccount__c = accTest3.id,
                FinServ__Role__c = role.id,
                OwnerId = usuario.Id
            );
            insert new List<FinServ__AccountAccountRelation__c> {accR, accR2, accR6};
            
            FinServ__AccountAccountRelation__c accR3 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelationEco, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = accEco.Id,
                FinServ__RelatedAccount__c = accEco2.Id,
                FinServ__Role__c = role.Id,
                CIBE_TipoGrupo__c = '130',
                OwnerId = usuario.Id
            );
            
            FinServ__AccountAccountRelation__c accR4 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelationEco, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = accEco.Id,
                FinServ__RelatedAccount__c = accTest.Id,
                FinServ__Role__c = role.Id,
                CIBE_TipoGrupo__c = '130',
                OwnerId = usuario.Id
            );
            
            FinServ__AccountAccountRelation__c accR5 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelationEco, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = accEco2.Id,
                FinServ__RelatedAccount__c = accTest2.Id,
                FinServ__Role__c = role.Id,
                CIBE_TipoGrupo__c = '130',
                OwnerId = usuario.Id
            );
            insert new List<FinServ__AccountAccountRelation__c> {accR3, accR4, accR5};
            
            AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usuario, accTest);
            
            AV_Book__c book = CIBE_TestHelper.createPurse('04380EAP004');
            AV_BookManagementMember__c member = CIBE_TestHelper.createBookManagement(conTest, book);
        }
    }
          
     /**
	 * Execute the class getData
	 */
    @isTest
    public static void getDataTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        Test.startTest();
        System.runAs(usuario){
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Grupo Comercial'];
            Account accTest = [SELECT Id, Name FROM Account WHERE Name = 'Name'];
            Account accEco = [SELECT Id, Name FROM Account WHERE Name = 'Grupo Economico 1'];

            CIBE_GruposComerciales_Controller.CommercialGroupInfo groupInfo = CIBE_GruposComerciales_Controller.getClients(acc.Id, 'CIBE_MisClientesEMP');
            System.assert(groupInfo != null);
            System.assert(groupInfo.matrix != null);
            System.assert(groupInfo.clientIds != null);
            System.assert(groupInfo.clients != null);
     
            List<CIBE_GruposComerciales_Controller.EconomicGroupEntry> economicGroupEntries = CIBE_GruposComerciales_Controller.getEconomicGroupList(groupInfo.matrix, '130');
            System.assert(!economicGroupEntries.isEmpty());
            List<CIBE_GruposComerciales_Controller.EconomicGroupEntry> economicGroupEntries2 = CIBE_GruposComerciales_Controller.getEconomicGroupList(groupInfo.matrix, '110');
            System.assert(!economicGroupEntries2.isEmpty());

            CIBE_GruposComerciales_Controller.CommercialGroupInfo shadow = CIBE_GruposComerciales_Controller.getShadow(accEco.Id, '130', groupInfo.clientIds, 'CIBE_MisClientesEMP',groupInfo.clients);
            System.assert(shadow != null);
            System.assert(shadow.matrix != null);
            System.assert(shadow.clientIds != null);
            System.assert(shadow.clients != null);
            
            // List<CIBE_GruposComerciales_Controller.EconomicGroup> economicGroup = CIBE_GruposComerciales_Controller.getEconomicInfo(accTest.Id);
            // System.assert(!economicGroup.isEmpty());
        }
        Test.stopTest();
    }

    /**
	 * Execute the class getData
	 */
    @isTest
    public static void getEconomicGroupTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        Test.startTest();
        System.runAs(usuario){
            Account accTest = [SELECT Id, Name FROM Account WHERE Name = 'Name'];

            List<CIBE_GruposComerciales_Controller.EconomicGroup> economicGroup = CIBE_GruposComerciales_Controller.getEconomicInfo(accTest.Id);
            System.assert(!economicGroup.isEmpty());
        }
        Test.stopTest();
    }
}