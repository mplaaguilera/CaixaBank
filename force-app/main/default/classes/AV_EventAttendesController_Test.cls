/**********************************************************************************************************************
Name:	  AV_EventAttendesController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: AV_EventAttendesController testing class
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			US336957/Test  Luis Fernández	   	01/09/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_EventAttendesController_Test {
    
 @TestSetup
 static void setup(){
    AV_TestHelper.createUser('AV_Usuario_CaixaBank');
    User u = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','99999');
    insert u;
 }


 @isTest
 public static void searchUserTest(){
    Test.startTest();
    User u1 = [SELECT ID,name FROM USER WHERE alias = 'tsAlias' LIMIT 1];
    List<String> selectIds = new List<String>();
    User u2 = [SELECT ID,name FROM USER WHERE AV_ExternalID__c = '99999' LIMIT 1];
    Id [] fixedSOSL = new Id [1];
    fixedSOSL[0] = u2.id;
    Test.setFixedSearchResults(fixedSOSL);
    List<AV_LookupSearchResult> testList1 = AV_EventAttendesController.searchUser('99999',selectIds);
    System.debug('query rara -> '+testList1);
    selectIds.add(u1.id);
    List<AV_LookupSearchResult> testList2 = AV_EventAttendesController.searchUser(u2.name,selectIds);
    Test.stopTest();
    System.assert(!testList1.isEmpty());
    System.assert(!testList2.isEmpty());
 }
@isTest
 public static void getUserEmployeeTest(){

    Test.startTest();
    User u1 = [SELECT ID FROM USER WHERE alias = 'tsAlias' LIMIT 1];
    User userTest = AV_EventAttendesController.getUserEmployee(u1.Id);
    Test.stopTest();
    System.debug('que devuelve? '+ userTest);
    System.assert(userTest != null);
 }
}