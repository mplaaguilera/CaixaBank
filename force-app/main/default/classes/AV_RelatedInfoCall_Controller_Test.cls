/**********************************************************************************************************************
Name:	  AV_RelatedInfoCall_Controller_Test
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_RelatedInfoCall_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Ali / Bea		    19/06/2024		Init version
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class AV_RelatedInfoCall_Controller_Test {

    
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
            PermissionSetAssignment pa2 = new PermissionSetAssignment(AssigneeId = userSA.Id, PermissionSetId = ps.Id);
            permissionSetList.add(pa2);
        }            
        insert permissionSetList;  
    }
    /***********************************************************************************************************/

    @isTest
    private static void getFieldsTest() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        User userSA = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];

        System.runAs(userGestor){
        RecordType rtAcc = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rtAcc.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = userGestor.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        RecordType rtLlamada = AV_AppUtilities.getRecordType('CC_Llamada__c', 'AV_CallLog');
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
            RecordTypeId = rtLlamada.Id);
    
        insert llamada;

        CC_Llamada__c llamada2 = new CC_Llamada__c(
            CC_Fecha_Inicio__c = dtValue,
            OB_Telefono__c = '690310038',
            AV_Duration__c = '22',
            CC_Tipo__c = 'Entrante',
            AV_State__c = 'Perdida',
            AV_Account__c = acc.Id,
            AV_ExternalID__c = '67655614869031003820240626095112',
            RecordTypeId = rtLlamada.Id);
    
        insert llamada2;

        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		tarea.OwnerId = userGestor.Id;
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928374';
		tarea.RecordTypeId = rt.Id;
        tarea.CC_Llamada_Id__c = llamada.Id;
        tarea.WhatId = acc.Id;
        tarea.Description = 'Description01';
		insert tarea;

        RecordType rtEvent = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
        
        Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = acc.Id;
		event.OwnerId = userGestor.Id;

		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rtEvent.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = dtValue;
		event.AV_Tipo__c = 'CTO';
		event.StartDateTime = dtValue;
		event.AV_CodigoGestorAsignado__c = 'U01XYZ02';
		event.EndDateTime = dtValue.addMinutes(60);
		event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
        event.CC_Llamada_Id__c = llamada2.Id;
        event.Description = 'Description01';
		insert event;
        
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

        Test.startTest();

        List<AV_RelatedInfoCall_Controller.Wrapper> listWrapperTask= AV_RelatedInfoCall_Controller.getFields(tarea.CC_Llamada_Id__c);
        List<AV_RelatedInfoCall_Controller.Wrapper> listWrapperEvent= AV_RelatedInfoCall_Controller.getFields(event.CC_Llamada_Id__c);
        System.assert(!listWrapperTask.isEmpty(), 'La lista debe tener un elemento');
        System.assert(!listWrapperEvent.isEmpty(), 'La lista debe tener un elemento');
        }
        Test.stopTest();  
    }
    /***********************************************************************************************************/

    @isTest
    private static void getActivityUrlTest() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        RecordType rtAcc = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rtAcc.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = userGestor.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		tarea.OwnerId = userGestor.Id;
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928374';
		tarea.RecordTypeId = rt.Id;
		insert tarea;

        Test.startTest();
        System.runAs(userGestor){
        String url = AV_RelatedInfoCall_Controller.getActivityUrl(tarea.id,'Task');
        System.assert(String.isNotBlank(url), 'La URL debe estar completa');
        }
        Test.stopTest();  
    }
}