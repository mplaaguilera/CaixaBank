/**********************************************************************************************************************
Name:	  AV_ClientCommentsController_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_ClientCommentsController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Sandra Gómez	   	    18/01/2021		Init version
1.1			US147315	   Sandra Gómez			15/03/2021		change Account location
1.2		    AV_Query IT	   Daniel Rodríguez	    04/02/2022	    Change AV_Query to SOQL for User and Account
1.3         US673516       Elisabeth R.         02/10/2023      Changed setup method to add comment history record
1.4         PPM100353686   Oscar Moreno         22/10/2024      Modify setup method
***********************************************************************************************************************/
@isTest
public with sharing class AV_ClientCommentsController_Test {
	@TestSetup
	static void setup() {
        User userGcf = [SELECT Id,AV_ExternalId__c FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        
        Account acc;
        Account centro;
        
        System.runAs(userGcf){
            User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            AV_TestHelper.insertNeededPermissions(userGestor);
            centro= AV_TestHelper.createCaixaCenterSinInsert();
            centro.OwnerId = userGestor.Id;
            
            Date activityDate = Date.today();
            acc = AV_TestHelper.createCustomerSinInsert();
            insert new List<Account>{centro,acc};
            Contact cont = AV_TestHelper.createEmployee(centro,userGestor,userGestor.AV_ExternalID__c);
            Event evento = AV_TestHelper.createEventExternalIdSinInsert(userGestor,activityDate,'U01545454',acc);
            evento.description ='Prueba comntario 1';
            insert evento;
            Task tarea= AV_TestHelper.createTareaExternalIdSinInsert(userGcf,'U01545454');
            tarea.description ='Prueba comentario 2';
            tarea.ActivityDate = Date.today();
            tarea.WhatId = acc.id;
            tarea.Status = 'Gestionada positiva';
            insert tarea;
            Test.startTest();
            Opportunity opp = AV_TestHelper.createOpportunity(acc);
            AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
			commHist.OwnerId = userGcf.Id;
			commHist.AV_ModificationDate__c = Date.today();
			commHist.AV_NewComment__c = opp.AV_Comentarios__c;
			commHist.AV_OpportunityStatus__c = opp.StageName;
            commHist.AV_Event__c =(String)evento.Id;
            commHist.AV_Task__c = (String)tarea.Id;
			commHist.AV_Opportunity__c = opp.Id;
			insert commHist;
            Test.stopTest();
            List<Case> lstCase = new List<Case> ();
            string rtId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
            Case caso = new Case();
            caso.Origin = 'phone';
            caso.Description = 'test1';
            caso.RecordTypeId = rtId;
            caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
            caso.CC_Tipo_Contacto__c = 'Asesoramiento';
            caso.AccountId= acc.Id;
            lstCase.add(caso);
            insert lstCase;
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        
           
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c();
            proceso.Name ='proceso test';
            proceso.OwnerId = userGestor.Id;
            proceso.SIR_DeudaTotal__c = 20;
            proceso.SIREC__SIREC_fld_fechaSituacion__c = Date.today();
            proceso.SIREC__SIREC_fld_motivosBaja__c = 'PROCESO';
            proceso.SIREC__SIREC_fld_fechaBaja__c = Date.today();
            proceso.SIREC__SIREC_fld_cliente__c = acc.id;
            proceso.SIR_fld_Situacion_SF__c ='SF_INIGEST';
            proceso.SIREC__SIREC_fld_fechaInicio__c = Date.today();
            RecordType rtt = AV_AppUtilities.getRecordType('SIREC__SIREC_obj_proceso__c', 'SIREC_rt_Anticipacion');
            proceso.RecordTypeId = rtt.Id;
            insert proceso;

            SIREC__SIREC_obj_acciones__c accion = new SIREC__SIREC_obj_acciones__c();
            accion.SIREC__SIREC_fld_proceso__c = proceso.id;
            accion.SIREC__SIREC_fld_fechaContacto__c= System.today();
            accion.SIR_FechaCompromisoPago__c = System.today();
            accion.SIREC__SIREC_fld_tipo__c = '12';
            accion.SIREC__SIREC_fld_accion__c = '02';
            insert accion;
            
        }

        
	}
    
	@isTest
	public static void validateGetClientComments() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
		List<Account> acc = [Select Id From Account WHERE RecordType.DeveloperName ='CC_ClientePA' limit 1];
		System.runAs(userGcf){ 
            	Test.startTest();
                Map<String,List<AV_ClientCommentsController.CommentItem>> lista = AV_ClientCommentsController.getClientComments(acc[0].id, null);
                Test.stopTest();
            	System.assertNotEquals(lista,null);
        }
	}
    
	@isTest
	public static void validateGetClientComments2() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		List<Account> acc = [Select Id From Account WHERE RecordType.DeveloperName ='CC_ClientePA' limit 1];
		System.runAs(userGcf){ 
            	Test.startTest();
                Map<String,List<AV_ClientCommentsController.CommentItem>> lista2 = AV_ClientCommentsController.getClientComments(acc[0].id, 'Llamada Saliente');
                Test.stopTest();
            	System.assertNotEquals(lista2,null);
        }
	}
}