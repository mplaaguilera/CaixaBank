/**********************************************************************************************************************
Name: CIBE_AddTeamCXBController_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class test for CIBE_AddTeamCXBController 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY			AUTHOR				DATE            Description
1.0         US638991			Lucía		    	17/10/2023      Init version
***********************************************************************************************************************/

@IsTest
public with sharing class CIBE_AddTeamCXBController_Test {

    @TestSetup
    static void setUp(){
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);

        System.runAs(usuario){
            AV_Book__c cartera =  CIBE_TestHelper.createPurse('00001EAP111');
           
            Contact contacto = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            AV_BookManagementMember__c bMM =  CIBE_TestHelper.createBookManagement(contacto, cartera);
            Account acc = new Account(
                    Name = 'Test Name Cartera',
                    RecordTypeId = rt.Id,
                    AV_Negocio__c = 'BPA',
                    OwnerId = usuario.Id
                );
            insert acc;

            CIBE_TestHelper.createBookMember(acc, cartera);

        }
    }


    @IsTest
    static void getCarteraTest(){

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];

        System.runAs(usuario){
            List<AV_BookManagementMember__c> carteraUsuario = CIBE_AddTeamCXBController.getCartera(usuario.Id);
            System.assert(!carteraUsuario.isEmpty());
            
        }
    }

    @IsTest
    static void insertCXBTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND CreatedDate = Today AND createdbyId = :UserInfo.getUserId()];


        List<Account> acc = [SELECT Id, OwnerId, Name FROM Account WHERE CreatedDate = Today AND createdbyId = :usuario.Id AND Name = 'Test Name Cartera' LIMIT 1];
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Contact contactoTest = CIBE_TestHelper.createEmployee(acc[0], usrTest);

        Contact contacto = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];


        System.runAs(usuario){
            System.assert(!acc.isEmpty());
            List<AV_BookManagementMember__c> cartera = [SELECT Id, AV_Cartera__r.AV_ExternalID__c FROM AV_BookManagementMember__c WHERE AV_EmpleadoGestor__c = :contacto.Id];
            List<String> carteras = new List<String>();

            for (AV_BookManagementMember__c c : cartera) {
                carteras.add(c.AV_Cartera__r.AV_ExternalID__c);
            }
            CIBE_AddTeamCXBController.insertCXB(usrTest.Id, carteras);
            System.assert(usrTest.Id != null);
            System.assert(!cartera.isEmpty());
        }

        Test.stopTest();
    }
   
}