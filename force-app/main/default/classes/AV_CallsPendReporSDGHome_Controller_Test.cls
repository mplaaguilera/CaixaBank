/**********************************************************************************************************************
Name:	  AV_CallsPendReporSDGHome_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para AV_CallsPendReporSDGHome_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.1			-	          Bea y Ali  	    08/08/2024		  	Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_CallsPendReporSDGHome_Controller_Test {
    
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
    public static void getRecordsTest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U0000001'];

        RecordType rtAcc = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        
        List <Account> listAcc = new List <Account>();

        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rtAcc.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = u.Id;
        acc.CC_Email__c = 'test@test.com';

        listAcc.add(acc);

        Account acc2 = new Account();
        acc2.Name = 'Prueba2';
        acc2.RecordTypeId = rtAcc.Id;
        acc2.Phone = '34682134591';
        acc2.AV_NumPerso__c = '1234';
        acc2.AV_Negocio__c = 'BPA';
        acc2.CC_Numero_Documento__c = '94463856T';
        acc2.OwnerId = u.Id;
        acc2.CC_Email__c = 'test2@test.com';

        listAcc.add(acc2);

        Account acc3 = new Account();
        acc3.Name = 'Test3';
        acc3.RecordTypeId = rtAcc.Id;
        acc3.Phone = '34914088791';
        acc3.AV_NumPerso__c = '12345';
        acc3.AV_Negocio__c = 'BPA';
        acc3.CC_Numero_Documento__c = '9446387T';
        acc3.OwnerId = u.Id;
        acc3.CC_Email__c = 'test3@test.com';

        listAcc.add(acc3);

        insert listAcc;

        RecordType rt = AV_AppUtilities.getRecordType('CC_Llamada__c', 'AV_CallLog');
        DateTime dtValue = System.now();
        List <CC_Llamada__c> listCalls = new List <CC_Llamada__c>();

        CC_Llamada__c llamada1 = new CC_Llamada__c(
            CC_Fecha_Inicio__c = dtValue,
            OwnerId = u.Id,
            OB_Telefono__c = '682134590',
            AV_Duration__c = '22',
            CC_Tipo__c = 'Entrante',
            AV_State__c = 'Pendiente',
            AV_Account__c = acc.Id,
            AV_ExternalID__c = '67655614869031003820240626095111',
            RecordTypeId = rt.Id);
        
        listCalls.add(llamada1);
        
        CC_Llamada__c llamada2 = new CC_Llamada__c(
            CC_Fecha_Inicio__c = dtValue,
            OwnerId = u.Id,
            OB_Telefono__c = '682134591',
            AV_Duration__c = '22',
            CC_Tipo__c = 'Entrante',
            AV_State__c = 'Pendiente',
            AV_Account__c = acc.Id,
            AV_ExternalID__c = '67655614869031003820240626095112',
            RecordTypeId = rt.Id);
        
        listCalls.add(llamada2);

        insert listCalls;

        System.runAs(u){
            Test.startTest();
            List <AV_CallsPendReporSDGHome_Controller.Wrapper> listResponse = AV_CallsPendReporSDGHome_Controller.getCalls();
            Test.stopTest();
            System.assertNotEquals(0, listResponse.size(), 'La lista debe estar rellena');
        }
    }

    @isTest
    public static void getUserPermissionsTest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U0000001'];

        System.runAs(u){
            Test.startTest();
            
            List<String> permissionSetNames = AV_CallsPendReporSDGHome_Controller.getUserPermissions();
            Test.stopTest();
            System.assertEquals(true, permissionSetNames.contains('AV_RainbowCTI'));
        }
    }

    @isTest
    public static void discardCallsTest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U0000001'];

        RecordType rtAcc = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rtAcc.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = u.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        RecordType rt = AV_AppUtilities.getRecordType('CC_Llamada__c', 'AV_CallLog');
        DateTime dtValue = System.now();
        List <String> callIdList = new List <String>();

        CC_Llamada__c llamada = new CC_Llamada__c(
            CC_Fecha_Inicio__c = dtValue,
            OwnerId = u.Id,
            OB_Telefono__c = '682134590',
            AV_Duration__c = '22',
            CC_Tipo__c = 'Entrante',
            AV_State__c = 'Perdida',
            AV_Account__c = acc.Id,
            AV_ExternalID__c = '67655614869031003820240626095111',
            RecordTypeId = rt.Id);
        
        
        insert llamada;

        callIdList.add(llamada.Id);

        System.runAs(u){
            Test.startTest();
            AV_CallsPendReporSDGHome_Controller.discardCalls(callIdList);
            List <CC_Llamada__c> listState = [SELECT Id, AV_State__c FROM CC_Llamada__c WHERE Id = :llamada.Id];
            String state = listState[0].AV_State__c;
            Test.stopTest();
            System.assertEquals('Descartada', state);
        }
    }
}