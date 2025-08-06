/**********************************************************************************************************************
 Name:	  CBK_PublicGroupManageController_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_PublicGroupManageController del framework de asignación de grupos públicos.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	01/02/2022			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_PublicGroupManageController_Test {
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 14/06/2021 
    **/
    @testSetup static void setup() {
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'LastNameTest',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;

        List<CBK_GestoresPGOperativosJerarquicos__c> lstCS = new List<CBK_GestoresPGOperativosJerarquicos__c>();
        List<Group> lstGroups = [SELECT id, developername FROM group WHERE type = 'regular' LIMIT 5];
        List<user> lstUsers = [SELECT id,username FROM user WHERE UserType= 'Standard'  and username !=:UserInfo.getUsername() LIMIT 5];
        for (Group g: lstGroups){
            for (User u: lstUsers){
                lstCS.add(new CBK_GestoresPGOperativosJerarquicos__c(name=(g.developername+u.username).abbreviate(37)+'A',CBK_Username__c=u.username,CBK_PublicGroupDevName__c=g.developername, CBK_PGJerarquico__c=true));
                lstCS.add(new CBK_GestoresPGOperativosJerarquicos__c(name=(g.developername+u.username).abbreviate(37)+'B',CBK_Username__c=u.username,CBK_PublicGroupDevName__c=g.developername, CBK_PGJerarquico__c=false));
            }
            lstCS.add(new CBK_GestoresPGOperativosJerarquicos__c(name=(g.developername+UserInfo.getUserName()).abbreviate(37)+'C',CBK_Username__c=UserInfo.getUsername(),CBK_PublicGroupDevName__c=g.developername, CBK_PGJerarquico__c=true));
            lstCS.add(new CBK_GestoresPGOperativosJerarquicos__c(name=(g.developername+UserInfo.getUserName()).abbreviate(37)+'D',CBK_Username__c=UserInfo.getUsername(),CBK_PublicGroupDevName__c=g.developername, CBK_PGJerarquico__c=false));
        }
        insert lstCS;
    }
    /**
    * @description Método de test para validar la invocación de la funcionalidad de recuperación de grupos gestionados
    * @author   fzaragoza | 31/01/2022
    **/
    @IsTest static void testListGroups(){
        
        List<Group> lstGroups = [SELECT id, developername FROM group WHERE type = 'regular' LIMIT 5];
        List<user> lstUsers = [SELECT id,username FROM user WHERE UserType= 'Standard' LIMIT 5];
        List<GroupMember> lstGM = new List<GroupMember>();
        for (Group g: lstGroups){
            for (User u: lstUsers){
                lstGM.add(new GroupMember ( UserOrGroupId=u.ID,GroupId=g.Id));
            }
        }
        insert lstGM;



        List<Group> testGH = CBK_PublicGroupManageController.getPublicGroupList(true);
        List<Group> testGO = CBK_PublicGroupManageController.getPublicGroupList(false);
        System.AssertEquals(5,testGH.size(),'No corresponde el número de grupos recuperados con el número de grupos esperados.');
        System.AssertEquals(5,testGO.size(),'No corresponde el número de grupos recuperados con el número de grupos esperados.');
    }
    /* @description Método de test para validar la invocación de la funcionalidad de recuperación de usuarios gestionados
    * @author   fzaragoza | 31/01/2022
    **/
    @IsTest static void testListUser(){
        List<Group> lstGroups = [SELECT id, developername FROM group WHERE type = 'regular' LIMIT 5];
        List<user> lstUsers = [SELECT id,username FROM user WHERE UserType= 'Standard' LIMIT 5];
        List<GroupMember> lstGM = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :lstGroups];
        Set <Id> setIDGM = new Set <Id>();
        for (GroupMember gm: lstGM){
            if (String.ValueOf(gm.UserOrGroupId).startsWith('005')) {
                setIDGM.add(gm.UserOrGroupId);
            }
        }

        List<User> testUL = CBK_PublicGroupManageController.getManagedUserList();
        System.AssertEquals(setIDGM.size(),testUL.size(),'No corresponde el número de usuarios recuperados con el número de usuarios esperados.');
    }

    /**
    * @description Método de test para validar la invocación de la funcionalidad de asociación/desasociación de usuarios a grupos gestionados
    * @author   fzaragoza | 31/01/2022
    **/
    @IsTest static void testOperations(){
        List<Group> lstGroups = [SELECT id, developername FROM group WHERE type = 'regular' LIMIT 5];
        List<user> lstUsers = [SELECT id,username FROM user WHERE UserType= 'Standard' LIMIT 5];
        List<GroupMember> lstGM = new List<GroupMember>();
        for (Group g: lstGroups){
            for (User u: lstUsers){
                lstGM.add(new GroupMember ( UserOrGroupId=u.ID,GroupId=g.Id));
            }
        }
        insert lstGM;
        Group g = [SELECT id, developername FROM group WHERE type = 'regular' LIMIT 1 OFFSET 10];
        ID gmId = CBK_PublicGroupManageController.createUserGroupMembership(g.Id,UserInfo.getUserID());
        CBK_PublicGroupManageController.deleteUserGroupMembership(gmId);
    }


        /**
    * @description Método de test para validar la invocación de la funcionalidad de recuperar la matriz de asignaciones
    * @author   fzaragoza | 31/01/2022
    **/
    @IsTest static void testMatrix(){
        List<CBK_PublicGroupManageController.MatrixElement> matrix =  CBK_PublicGroupManageController.getPublicGroupMatrix();

        List<Group> testGO = CBK_PublicGroupManageController.getPublicGroupList(false);
        List<User> testUL = CBK_PublicGroupManageController.getManagedUserList();
        System.AssertEquals(matrix.size(),testGO.size()*testUL.size(),'No corresponde el tamaño de la matriz con el número de usuarios y grupos operativos recuperados.');

    }
    
}