/**********************************************************************************************************************
 Name:	  CBK_PermissionUtils_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_PermissionUtils_Test del framework de reciclaje de permisos.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	28/04/2022			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_PermissionUtils_Test {

    /**
    * @description Método de setup de datos para los test 
    * @author fzaragoza | 28-04-2022 
    **/
    @testSetup static void setup() {

        User us = new User(
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
        insert us;
    }

    /**
    * @description  Método de test para validar la invocación de la funcionalidad de recuperación de PermissionSetAssignment
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testRetrievePermissionSetAssignments() {
        List<PermissionSetAssignment> retrievePermissionSetAssignments = CBK_PermissionUtils.retrievePermissionSetAssignments();
        System.assertNotEquals(retrievePermissionSetAssignments, null,'Se esperaba recuperar el listado inicializado de PermissionSetAssignment');
    }


    /**
    * @description Método de test para validar la invocación de la funcionalidad de recuperación de PermissionSetLicenseAssign
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testRetrievePermissionSetLicenseAssignments() {
        List<PermissionSetLicenseAssign> retrievePermissionSetLicenseAssignments = CBK_PermissionUtils.retrievePermissionSetLicenseAssignments();
        System.assertNotEquals(retrievePermissionSetLicenseAssignments, null,'Se esperaba recuperar el listado inicializado de PermissionSetAssignment');
    }
    /**
    * @description  Método de test para validar la invocación de la funcionalidad de recuperación de la configuración de permisos a monitorizar
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testRetrieveConfigPermission() {
        List<CBK_PermissionRecycleSettings__mdt> retrieveConfigPermission = CBK_PermissionUtils.retrieveConfigPermission();
        System.assertNotEquals(retrieveConfigPermission, null,'Se esperaba recuperar el listado inicializado de PermissionSetAssignment');
        System.assertNotEquals(retrieveConfigPermission.size(), 0,'Se esperaba recuperar entradas en el listado de configuración de permisos a monitorizar');
    }

    /**
    * @description  Método de test para validar la invocación de la funcionalidad de recuperación de PermissionSets correspondientes a PermissionSetGroups
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testGetMapPermissionSetsForGroupsByGroup() {
        Map<String,PermissionSet> getMapPermissionSetsForGroupsByGroup = CBK_PermissionUtils.getMapPermissionSetsForGroupsByGroup();
        System.assertNotEquals(getMapPermissionSetsForGroupsByGroup, null,'Se esperaba recuperar el listado inicializado de PermissionSet por grupo');
    }

    /**
    * @description  Método de test para validar la invocación de la funcionalidad de recuperación de PermissionSets
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testGetMapPermissionSets() {
        Map<String,PermissionSet> getMapPermissionSets = CBK_PermissionUtils.getMapPermissionSets();
        system.debug('>>>getMapPermissionSets: '+getMapPermissionSets);
        System.assertNotEquals(getMapPermissionSets, null,'Se esperaba recuperar el listado inicializado de PermissionSets');
    }

    /**
    * @description  Método de test para validar la invocación de la funcionalidad de recuperación de PermissionSetLicense
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testGetMapPermissionSetLicenses() {
        Map<String,PermissionSetLicense> getMapPermissionSetLicenses = CBK_PermissionUtils.getMapPermissionSetLicenses();
        System.assertNotEquals(getMapPermissionSetLicenses, null,'Se esperaba recuperar el listado inicializado de PermissionSetsLicenses');
    }

    /**
    * @description  Método de test para validar la funcionalidad de borrado de PermissionSets 
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testRecyclePermissionSets() {
        //User us = [SELECT Id FROM User WHERE UserType= 'Standard' AND ID!=:System.UserInfo.getUserId() AND IsActive = true AND UserRoleId != null LIMIT 1];
        User us = [SELECT Id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE PermissionSetGroupId = null and iscustom = true and IsOwnedByProfile = false AND LicenseId = null LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = us.Id);
        insert psa;
        List<Id> listIds = new List<Id>();
        listIds.add(psa.id);
        CBK_PermissionUtils.recyclePermissionSets(listIds);
        List<PermissionSet> restante = [SELECT Id, Name FROM PermissionSet WHERE id=:psa.Id];
        System.assertEquals(restante.size(), 0,'No coincide el número de registros esperados');
    }

    /**
    * @description  Método de test para validar la funcionalidad de borrado de PermissionSetLicenses
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testRecyclePermissionSetLicenses() {
        User us = [SELECT Id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        PermissionSetLicense psl = [SELECT Id FROM PermissionSetLicense WHERE Status = 'Active' LIMIT 1];
        PermissionSetLicenseAssign  psla = new PermissionSetLicenseAssign (PermissionSetLicenseId  = psl.Id, AssigneeId = us.Id);
        insert psla;
        List<Id> listIds = new List<Id>();
        listIds.add(psla.id);
        CBK_PermissionUtils.recyclePermissionSetLicenses(listIds);
        List<PermissionSetLicenseAssign> restante = [SELECT Id FROM PermissionSetLicenseAssign WHERE id=:psla.Id];
        System.assertEquals(restante.size(), 0,'No coincide el número de registros esperados');
    }

    /**
    * @description  Método de test para validar la funcionalidad de desactivación de usuarios
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testDeactivateUsers() {
        User us = [SELECT Id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        List<Id> listIds = new List<Id>();
        listIds.add(us.id);
        CBK_PermissionUtils.deactivateUsers(listIds);
        User userDeact = [SELECT Id,IsActive FROM User WHERE id=:us.Id];
        System.assertEquals(userDeact.IsActive, false,'No coincide el estado del usuario con el esperado');
    }


    /**
    * @description  Método de test para validar la funcionalidad de de permissionsets
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testCreatePermissionSetAssignments() {
        List<PermissionSetAssignment> listPSs = new List<PermissionSetAssignment>();
        User us = [SELECT Id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE PermissionSetGroupId = null and iscustom = true and IsOwnedByProfile = false AND LicenseId = null LIMIT 1];
        listPSs.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = us.Id));
        CBK_PermissionUtils.createPermissionSetAssignments(listPSs);
        List<PermissionSetAssignment> listInsertedPSs = [SELECT Id FROM PermissionSetAssignment  WHERE PermissionSetId=:ps.Id AND AssigneeId = :us.Id];
        System.assertEquals(listInsertedPSs.size(), 1,'No coincide el resultado recuperado con el valor esperado');
    }


        /**
    * @description  Método de test para validar la funcionalidad de de permissionsets
    * @author fzaragoza | 28-04-2022 
    **/
    @IsTest static void testCreatePermissionSetLicenseAssigns() {
        List<PermissionSetLicenseAssign> listPSLs = new List<PermissionSetLicenseAssign>();
        User us = [SELECT Id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        PermissionSetLicense psl = [SELECT Id FROM PermissionSetLicense WHERE Status = 'Active' LIMIT 1];
        listPSLs.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = psl.Id, AssigneeId = us.Id));
        CBK_PermissionUtils.createPermissionSetLicenseAssigns(listPSLs);
        List<PermissionSetLicenseAssign> listInsertedPSLs = [SELECT Id FROM PermissionSetLicenseAssign  WHERE PermissionSetLicenseId=:psl.Id AND AssigneeId = :us.Id];
        System.assertEquals(listInsertedPSLs.size(), 1,'No coincide el resultado recuperado con el valor esperado');
    }
    
    /**
    * @description  Método de test para validar la funcionalidad de de usuarios excluidos
    * @author fzaragoza | 31-05-2022 
    **/
    @IsTest static void testExcludedPermissionSetLicenseUsers() {
        Set<Id> getUsersExcludedPermissionSet = CBK_PermissionUtils.retrieveExcludedUsers();
        System.assertNotEquals(getUsersExcludedPermissionSet, null,'Se esperaba recuperar el listado inicializado de usuarios excluidos');
    }
}