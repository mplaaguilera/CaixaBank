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
@IsTest private with sharing class CBK_RecyclePermissionsBatch_Test {

    /**
    * @description Método de setup de datos para los test 
    * @author fzaragoza | 02-05-2022 
    **/
    @testSetup static void setup() {
        List<PermissionSetAssignment> listPSs = new List<PermissionSetAssignment>();
        List<PermissionSetLicenseAssign> listPSLs = new List<PermissionSetLicenseAssign>();

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

        List <PermissionSetLicense> listPSL = [SELECT Id,DeveloperName FROM PermissionSetLicense WHERE Status = 'Active' ORDER BY ID DESC LIMIT 2];
        List <PermissionSet> listPS = [SELECT Id, Name FROM PermissionSet WHERE PermissionSetGroupId = null and iscustom = true and IsOwnedByProfile = false AND LicenseId = null ORDER BY ID DESC LIMIT 4];
        List <PermissionSet> listPSG = [SELECT Id, Name, PermissionSetGroup.DeveloperName FROM PermissionSet WHERE PermissionSetGroupId != null and iscustom = true and IsOwnedByProfile = false AND LicenseId = null AND PermissionSetGroup.Status = 'Updated' ORDER BY ID DESC LIMIT 4];
        
        List<PermissionSetAssignment> listPSGAsig = new List<PermissionSetAssignment>();
        listPSGAsig.add(new PermissionSetAssignment(PermissionSetId = listPSG[1].Id, AssigneeId = us.Id));
        listPSGAsig.add(new PermissionSetAssignment(PermissionSetId = listPSG[2].Id, AssigneeId = us.Id));
        insert listPSGAsig;
        
        listPSLs.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = listPSL[0].Id, AssigneeId = us.Id));
        listPSs.add(new PermissionSetAssignment(PermissionSetId = listPS[0].Id, AssigneeId = us.Id));
        listPSs.add(new PermissionSetAssignment(PermissionSetId = listPS[2].Id, AssigneeId = us.Id));
        //listPSs.add(new PermissionSetAssignment(PermissionSetId = listPSG[1].Id, AssigneeId = us.Id));
        //listPSs.add(new PermissionSetAssignment(PermissionSetId = listPSG[2].Id, AssigneeId = us.Id));

        insert listPSs;
        insert listPSLs;
    }

	/**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 03/05/2022 
    **/
    @IsTest static void  testBatch() {
        User us = [SELECT Id,LastLoginDate FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.setCreatedDate(us.Id, DateTime.newInstance(2012,12,12));
        Test.StartTest();
        CBK_RecyclePermissionsBatch batch = new CBK_RecyclePermissionsBatch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
}