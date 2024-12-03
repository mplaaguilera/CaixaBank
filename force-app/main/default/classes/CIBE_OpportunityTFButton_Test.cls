/**********************************************************************************************************************
 Name:	  CIBE_OpportunityTFButton_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				               DATE				Description
   1.0			Data access		   Jose Maria Fernandez Rodero      2/12/2022		Init version
   1.1			US609773		      Lucía Muñoz                      19/06/2022		Quitar el (seeAlData = true) de los metodos y ponerle el system.runAs
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_OpportunityTFButton_Test {

   @TestSetup
   static void makeData(){
      CIBE_TestInitialSetup.setupInitialDataCIB();
      User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

      System.runAs(new User(Id = UserInfo.getUserId())){

         Account accApoderado = new Account();
            accApoderado.Name = 'Test Account';
            accApoderado.AV_NumPerso__c = '123456789';
            accApoderado.OwnerId = u.Id;
         insert accApoderado;

      }
   }
   
   @isTest
   private static void testGetUrl(){

      User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
      System.runAs(usuario){
         String url = '';
         Account accApoderado = [SELECT Id, AV_NumPerso__c FROM Account WHERE Name = 'Test Account'];
         CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CIBE_Boton_TF');
         String urlTesting = result.CIBE_URL__C.replace('{numperso}', accApoderado.AV_NumPerso__c).replace('{nif}', '');
         Test.startTest();
         url = CIBE_OpportunityTFButton.getUrl(accApoderado.Id);
         Test.stopTest();
         System.assertEquals(urlTesting, url);
      }
   }

   @isTest
   private static void testGetUrlWrongId(){
      User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
      System.runAs(usuario){
         String url = '';
         Account accApoderado = [SELECT Id, AV_NumPerso__c FROM Account WHERE Name = 'Test Account'];

         CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CIBE_Boton_TF');
         String urlTesting = result.CIBE_URL__C.replace('{numperso}', accApoderado.AV_NumPerso__c).replace('{nif}', '');

      Test.startTest();
         url = CIBE_OpportunityTFButton.getUrl('000000006');
      Test.stopTest();
      System.assertNotEquals(urlTesting, url);
      }
     
   }



}