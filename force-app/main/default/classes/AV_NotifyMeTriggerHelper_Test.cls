/**********************************************************************************************************************
Name:	  AV_NotifyMeTriggerHelper_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Testing class "AV_NotifyMeTriggerHelper"
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Esperanza Conde 	    15/12/2020		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_NotifyMeTriggerHelper_Test {
    
    @TestSetup
    static void setup(){
        
        
		String labelProfile = 'System administrator';
        User usuario = AV_TestHelper.createUser(labelProfile);

        RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado');

        Contact empleado  = new Contact();
		empleado.LastName = 'Empleado';
		empleado.FirstName = 'Diana';
		empleado.Email = 'empleado@emailcaixa.com';
		empleado.CC_Idioma__c = 'es';
		empleado.RecordTypeId = rt.Id;
		empleado.CC_Matricula__c = 'U0009044';
		empleado.AV_UsuarioAsociado__c = usuario.Id;
		insert empleado;
 
    }
	
    @isTest
	private static void validateForbiddenWordsTest() {
		
        RecordType rt = AV_AppUtilities.getRecordType('AV_NotifyMe__c', 'AV_NotifyMe');
        AV_NotifyMe__c notifyMe = new AV_NotifyMe__c();
        notifyMe.RecordTypeId = rt.Id;
        notifyMe.AV_Status__c = 'AV_Pendiente';
        notifyMe.AV_ExternalId__c = '1000001';
        notifyMe.AV_Subject__c = 'Otros';
        insert notifyMe;

        Contact c = [Select id, AV_UsuarioAsociado__c from Contact Where AV_UsuarioAsociado__c != null];
        
		Test.startTest();
        notifyMe.AV_Employee__c = c.Id;
		update notifyMe;
        
		// AV_NotifyMe__c notifyMeUpdate = (AV_NotifyMe__c)new AV_Query('AV_NotifyMe__c')
        // .selectFields('OwnerId')
        // .addConditionEq('AV_ExternalID__c', '1000001')
        // .fetch();
        AV_NotifyMe__c notifyMeUpdate = [SELECT OwnerID FROM AV_NotifyMe__c WHERE AV_ExternalID__c = '1000001' LIMIT 1];
        Test.stopTest();
            
		System.assertEquals(c.AV_UsuarioAsociado__c, notifyMeUpdate.OwnerId);
        
    }
    
}