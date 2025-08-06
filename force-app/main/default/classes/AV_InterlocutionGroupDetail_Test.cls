/**********************************************************************************************************************
Name:	  AV_InterlocutionGroupDetail_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de AV_InterlocutionGroupDetails_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.0			US352009	  Elisabeth R  	    26/01/2023		  	Init version
                
***********************************************************************************************************************/
@isTest
public with sharing class AV_InterlocutionGroupDetail_Test {
    @TestSetup
    static void setup(){
        User usrGFC = [SELECT Id,Name FROM User WHERE Alias = 'AV-TF9' LIMIT 1];
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User usrTest;
        
        Account member1 = new Account();
        Account member2 = new Account();

        System.runAs(usrCli){
            List<Account> membersList = new List<Account>();
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
             
            member1.FirstName = 'FirstName1';
            member1.LastName = 'LastName1';
            member1.RecordTypeId = rt.Id;
            member1.AV_NumPerso__c = '123';
            member1.AV_Negocio__c = 'BPA';
            member1.CC_Numero_Documento__c = '9446381T';    
            membersList.add(member1);    
                
            member2.FirstName = 'FirstName2';
            member2.LastName = 'LastName2';
            member2.RecordTypeId = rt.Id;
            member2.AV_NumPerso__c = '1234';
            member2.AV_Negocio__c = 'BPA';
            member2.CC_Numero_Documento__c = '9446384T';
            membersList.add(member2); 
            
            insert membersList;
       
        }

        System.runAs(usrGFC){
            usrTest = AV_TestHelper.createUser(null,'U01543678','AV_SistematicaComercial');
            List<AV_GrupoInterlocucion__c> intGroupList = new List<AV_GrupoInterlocucion__c>();
            AV_GrupoInterlocucion__C grp = new AV_GrupoInterlocucion__c();
            grp.Name = 'GrupoTest';
            grp.AV_Numper__c = member1.id;
            grp.AV_IsInterlocutor__c = false;
            intGroupList.add(grp);
            
            AV_GrupoInterlocucion__C grp2 = new AV_GrupoInterlocucion__c();
            grp2.Name = 'GrupoTest';
            grp2.AV_Numper__c = member2.id;
            grp2.AV_IsInterlocutor__c = true;
            intGroupList.add(grp2);

            insert intGroupList;
        }

       
    }

    @isTest 
    public static void retrieveGroupsTest(){
        
        List<AV_GrupoInterlocucion__c> grp = [SELECT Id FROM AV_GrupoInterlocucion__C WHERE Name = 'GrupoTest'];
        Test.startTest();

        List<AV_GrupoInterlocucion__c> interlocutionGroupList = new List<AV_GrupoInterlocucion__c>();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01543678'];
        System.runAs(u){
        interlocutionGroupList = AV_InterlocutionGroupDetails_Controller.getInterlocutionGroup(grp[1].Id);
        }
        Test.stopTest();

        System.assertEquals(interlocutionGroupList.size(), 2);
    }
}