/**********************************************************************************************************************
Name:	  CIBE_GruposEconomicos_Controller_Test
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para el controlador CIBE_GruposEconomicos_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial  
-----------------------------------------------------------------------------------------------------------------------
VERSION		USER_STORY		AUTHOR				DATE				Description
1.0			App FSC			Mikel Lezama		29/09/2022			Test Class 
1.1			App FSC			Alex Campos			24/10/2022			Corrección getParents recursividad 

***********************************************************************************************************************/
@isTest
public class CIBE_GruposEconomicos_Controller_Test {
    
    @testSetup
    public static void testSetup() {
        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
        String rtAccountCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();

        Account accTest = CIBE_TestHelper.createCustomer();
        Contact conTest = CIBE_TestHelper.createEmployee(accTest, null);
        

        Account acc = new Account(
            Name = 'Prueba',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            AV_EAPGestor__r = conTest

        );
        insert acc;
        
        Account acc2 = new Account(
            Name = 'Prueba 2',
            RecordtypeId = rtAccountCliente,
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            AV_EAPGestor__r = conTest
        );
        insert acc2;

        Account accWithOutRelation= new Account(
            Name = 'Prueba sin Relacion',
            RecordtypeId = rtAccount,
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1)
        );
        insert accWithOutRelation;

        
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
      
        FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
            Name = 'Parent',
            FinServ__InverseRole__c = 'Cliente'
        );
        insert role;

        FinServ__AccountAccountRelation__c accR = new FinServ__AccountAccountRelation__c(
            RecordtypeId = rtAccountRelation, 
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            FinServ__Account__c = acc.id,
            FinServ__RelatedAccount__c = accTest.id,
            FinServ__Role__c = role.id,
            CIBE_TipoGrupo__c = '110'
        );
        insert accR;
        
        FinServ__AccountAccountRelation__c accR2 = new FinServ__AccountAccountRelation__c(
            RecordtypeId = rtAccountRelation, 
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            FinServ__Account__c = acc.id,
            FinServ__RelatedAccount__c = acc2.id,
            FinServ__Role__c = role.id,
            CIBE_TipoGrupo__c = '110'
        );
        insert accR2; 
    }
    
    @isTest
    public static void getDataTest() {
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account prueba = [SELECT Id FROM Account WHERE Name = 'Prueba'];
        Account prueba2 = [SELECT Id FROM Account WHERE Name = 'Prueba 2'];
        List<CIBE_GruposEconomicos_Controller.Entry> listEntry = new  List<CIBE_GruposEconomicos_Controller.Entry>();
        List<CIBE_GruposEconomicos_Controller.Entry> listEntry2 = new List<CIBE_GruposEconomicos_Controller.Entry>();
        Test.StartTest();
        listEntry = CIBE_GruposEconomicos_Controller.getData(prueba.Id, '110');
        listEntry2 = CIBE_GruposEconomicos_Controller.getData(prueba2.Id, '110');
        Test.StopTest();

        System.assert(!listEntry.isEmpty());
        System.assert(listEntry2.isEmpty());
        
    }

   
    @isTest
    public static void getParentsDataTest() {
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account prueba2 = [SELECT Id FROM Account WHERE Name = 'Prueba 2'];
        List<List<CIBE_GruposEconomicos_Controller.Breadcrumb>> breadCrumbs = new  List<List<CIBE_GruposEconomicos_Controller.Breadcrumb>>();
        List<List<CIBE_GruposEconomicos_Controller.Breadcrumb>> breadCrumbs2 = new  List<List<CIBE_GruposEconomicos_Controller.Breadcrumb>>();
        Test.StartTest();
        breadCrumbs = CIBE_GruposEconomicos_Controller.getParentsData(prueba2.Id, '110', 0, null);
        breadCrumbs2 =  CIBE_GruposEconomicos_Controller.getParentsData(prueba2.Id, '110', 0, breadCrumbs);  
        Test.StopTest();
        System.debug('breadCrumbs  -->' + breadCrumbs2);
        System.debug('breadCrumbs2  -->' + breadCrumbs2);
        System.assert(breadCrumbs.isEmpty());
        System.assert(breadCrumbs2.isEmpty());
    }

    @isTest
    public static void getParentsDataTestWithEmptyAccount() {
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account prueba2 = [SELECT Id FROM Account WHERE Name = 'Prueba sin Relacion'];
        List<List<CIBE_GruposEconomicos_Controller.Breadcrumb>> breadCrumbs = new  List<List<CIBE_GruposEconomicos_Controller.Breadcrumb>>();

        Test.StartTest();
        breadCrumbs = CIBE_GruposEconomicos_Controller.getParentsData(prueba2.Id, '110', 0, null);
        Test.StopTest();
        System.debug('breadCrumbs  -->' + breadCrumbs);
        System.assert(breadCrumbs.isEmpty());
    }
}