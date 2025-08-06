/**********************************************************************************************************************
Name:	  AV_CallAssignment_Controller_Test
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para AV_CallAssignment_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.1			-	          Ali / Bea         08/08/2024           Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_CallAssignment_Controller_Test {
    @testSetup
	static void testSetup() {

        UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = 'AV_SistematicaComercial' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank' LIMIT 1];
        Profile pSa = [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name = 'Administrador del Sistema' LIMIT 1];
        String externalId = 'U0000001';
        String externalIdSA = 'U0000000';
        String numOficina = '00001';
        List<User> lstUser = new List<User> ();

        User userSA = new User(
            ProfileId = pSa.Id,
            UserRoleId = ur.Id,
            UserName = externalIdSA + 'U0000000@test.dev',
            LastName = externalIdSA + '_LastName',
            Alias = externalIdSA.abbreviate(8),
            Email = externalIdSA + '@test.dev.sa',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-' + numOficina,
            AV_ExternalID__c = externalIdSA
        );

        lstUser.add(userSA);

        User user = new User(
            ProfileId = p.Id,
            UserRoleId = ur.Id,
            UserName = externalId + '@test.dev',
            LastName = externalId + '_LastName',
            Alias = externalId.abbreviate(8),
            Email = externalId + '@test.dev',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-' + numOficina,
            AV_ExternalID__c = externalId
        );
        lstUser.add(user);

        insert lstUser;

        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Set<String> setPermiss = new Set<String>{'AV_RainbowCTI'};
        List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name =:setPermiss];
        for(PermissionSet ps: perSet){
            PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);
            permissionSetList.add(pa);
        }            
        insert permissionSetList;  
    }


    @isTest
    public static void getCallInfoTest(){
        User user = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U0000001'];

        RecordType rtAcc = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rtAcc.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = user.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        RecordType rt = AV_AppUtilities.getRecordType('CC_Llamada__c', 'AV_CallLog');
        String strDateTime = '2024-06-26 10:56:44';
        DateTime dtValue = DateTime.valueOf(strDateTime);

        CC_Llamada__c llamada = new CC_Llamada__c(
            CC_Fecha_Inicio__c = dtValue,
            OB_Telefono__c = '690310038',
            AV_Duration__c = '22',
            CC_Tipo__c = 'Entrante',
            AV_State__c = 'Perdida',
            AV_Account__c = acc.Id,
            AV_ExternalID__c = '67655614869031003820240626095111',
            OwnerId = user.Id,
            RecordTypeId = rt.Id);
            
        insert llamada;
        System.runAs(user){
            Test.startTest();
                AV_CallAssignment_Controller.CallInfoWrapper result = AV_CallAssignment_Controller.getCallInfo(llamada.Id);
                String callUpdate = AV_CallAssignment_Controller.updateCall(llamada.Id, acc.Id);
                String callUptError = AV_CallAssignment_Controller.updateCall('nonexistentId', 'nonexistentAccountId');
                Test.stopTest();
                
                System.assertNotEquals(null, result);
                System.assertEquals('true', callUpdate);
                System.assertEquals('error', callUptError);
        }
    }

}