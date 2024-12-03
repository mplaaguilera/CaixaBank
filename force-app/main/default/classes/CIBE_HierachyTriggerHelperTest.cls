/**********************************************************************************************************************
Name:	  CIBE_HierachyTriggerHelperTest
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_HierachyTriggerHelper" 
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE				Description
1.0		    US717285	    María Burguillo		30/10/2023			Init version Opp 
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/

@isTest
public class CIBE_HierachyTriggerHelperTest {
    @TestSetup
    static void setup(){ 

        CIBE_TestInitialSetup.setupInitialDataCIB();

        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' ];
        //Run As ByPass Non Setup Object
        System.runAs(new User(Id = UserInfo.getUserId())){
        Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' AND ownerId =: u.id];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account accTest = new Account(
                Name = 'Test Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '000',
                AV_Negocio__c = 'CIB',
                AV_EAPGestor__c = c.Id
            );
        insert accTest;
        

         // Crear registros de prueba

        ID rtHy = Schema.SObjectType.CIBE_Hierarchy__c.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT).getRecordTypeId();
        string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
		string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
		
        CBK_PicklistValues__c pick = new CBK_PicklistValues__c();
		pick.RecordTypeId = rtIdPick;
		pick.Name = 'Field Picklist';
		pick.CBK_Object__c = 'Object';
		pick.OwnerId = u.Id;
		insert pick;

        CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
        pickVal.RecordTypeId = rtIdPickVal;
        pickVal.CBK_Picklist__c = pick.Id;
        pickVal.Name = 'Institutional Banking';
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


		

        List<CIBE_Hierarchy__c> listNews = new List<CIBE_Hierarchy__c>();

        CIBE_Hierarchy__c hier1 = new CIBE_Hierarchy__c();
        hier1.RecordTypeId = rtHy;
        hier1.CIBE_Negocios__c = pickVal.Id;
		hier1.CIBE_Contact__c = c.Id;
		hier1.OwnerId = u.Id;
        listNews.add(hier1);

       
        CIBE_Hierarchy__c hier2 = new CIBE_Hierarchy__c();
        hier2.RecordTypeId = rtHy;
        hier2.CIBE_Negocios__c = pickVal2.Id;
		hier2.CIBE_Contact__c = c.Id;
		hier2.OwnerId = u.Id;
        listNews.add(hier2);

        insert listNews;
        
        
    }
}
            
        @isTest
        static void testInsertBusinessUser() {
            User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' ];

            System.runAs(u){
            ID rtHy = Schema.SObjectType.CIBE_Hierarchy__c.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT).getRecordTypeId();
            List <CIBE_Hierarchy__c> listhier=[SELECT Id , CIBE_Negocios__r.Name , CIBE_Negocios__c, CIBE_Contact__r.AV_UsuarioAsociado__c  FROM CIBE_Hierarchy__c WHERE RecordTypeId =: rtHy AND OwnerId=:u.Id];
            
            // Ejecutar el método a probar
            Test.startTest();
            CIBE_HierachyTriggerHelper.insertBusinessUser(listhier);
            CIBE_HierachyTriggerHelper.insertBusinessUser(new List<CIBE_Hierarchy__c>{listhier[1],listhier[0]});
            Test.stopTest();
            
            // // Verificar el resultado
            List<User> listUser = [SELECT Id, CIBE_Negocio__c FROM User WHERE  AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' ];
            System.assertEquals('Restringido', listUser[0].CIBE_Negocio__c);
            }
        }

        @isTest
        static void testDeleteBusinessUser() {
            
            User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' ];

           
                ID rtHy = Schema.SObjectType.CIBE_Hierarchy__c.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT).getRecordTypeId();
                List <CIBE_Hierarchy__c> listhier=[SELECT Id , CIBE_Negocios__r.Name , CIBE_Negocios__c, CIBE_Contact__r.AV_UsuarioAsociado__c  FROM CIBE_Hierarchy__c WHERE RecordTypeId =: rtHy AND OwnerId=:usuario.Id];
                             
                system.runAs(usuario){
                    Test.startTest();
                    delete listhier;   
                    listhier=[SELECT Id , CIBE_Negocios__r.Name , CIBE_Negocios__c, CIBE_Contact__r.AV_UsuarioAsociado__c  FROM CIBE_Hierarchy__c WHERE RecordTypeId =: rtHy AND OwnerId=:usuario.Id];           
                    Test.stopTest();
                }
                system.assertEquals(listhier.isEmpty(), true);
                
            
           
        }
        @isTest
        static void testUpdateBusinessUser() {
            
            User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' ];

           
                ID rtHy = Schema.SObjectType.CIBE_Hierarchy__c.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT).getRecordTypeId();
               
                List <CIBE_Hierarchy__c> listhier=[SELECT Id , CIBE_Negocios__r.Name , CIBE_Negocios__c, CIBE_Contact__r.AV_UsuarioAsociado__c  FROM CIBE_Hierarchy__c WHERE CIBE_Negocios__r.Name = 'Institutional Banking'];
                             
                List <CBK_PicklistValues__c> listneg=[SELECT Id FROM CBK_PicklistValues__c WHERE Name='Opcion2'];

                system.runAs(usuario){
                    listhier[0].CIBE_Negocios__c=listneg[0].id;
                    Test.startTest();
                    Update listhier;              
                    Test.stopTest();
                }
                system.assertEquals(listhier[0].CIBE_Negocios__c , listneg[0].id);
            
           
        }

           
        }