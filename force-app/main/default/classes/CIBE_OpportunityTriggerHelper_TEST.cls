/**********************************************************************************************************************
Name:	  CIBE_OpportunityTriggerHelper_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_OpportunityTriggerHelper" 
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Jose Maria			09/06/2022		Init version
2.0			Test Class		Jose Maria 			17/10/2022		Mejora de cobertura y Test
3.0			Test Class		Jose Maria			21/12/2022		Cobertura metodo Divisa 
4.0         Test Class      Alicia              31/01/2023      Cobertura método Gestor Principal
5.0         Test Class      Lucia Muñoz         13/02/2023      Cobertura método newAtributtesOpp
6.0        	IT     			Lucía Muñoz         11/07/2023		Eliminar los metodos newAtributtesOppTest, newAtributtesOppTest2, newAtributtesOppTest3 y newAtributtesOppTest4 
7.0			US616750		Lucia Muñoz 	    27/07/2023		setOpportunityUsersTest
8.0         US643353      	Ali y Bea	       	21/09/2023      insertOppTMTest
9.0         US717936        Bea                 04/12/2023      Added method updateStageNameTest
10.0	    US732988        Ali                 05/12/2023      Test para los métodos: createCommentsHistory(), updateCommentsHistory() y deleteCommentsHistory()
11.0     	US889424		Lucía	  	        20/06/2024	    Added method updateCommentsHistoryTest, updateCommentsHistory2Test


-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_OpportunityTriggerHelper_TEST {
    
    private static final String ERROR_MESSAGE			= Label.AV_deleteToOpp;
    private static final String ERROR_MESSAGE_CONTACT	= Label.CIBE_ErrorContact;
    private static final String ERROR_MESSAGE_STAGENAME	= Label.CIBE_CambioEstadoNoPermitido;

    
    /***********************************************************************************************************/
    @TestSetup
    static void setup(){ 
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);

        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor','U0000009');
        List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name IN :ps];
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        for(PermissionSet ps1 : perSet) {
            permissionSetList.add(
                new PermissionSetAssignment(
                    AssigneeId = usrTest.Id, 
                    PermissionSetId = ps1.Id
            ));
        }

        if(!permissionSetList.isEmpty()) {
            insert permissionSetList;
        }
        

        System.runAs(usrSetup){

            Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' AND ownerId =: managerUser.id];
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account accTest = new Account(
                    Name = 'Test Name',
                    RecordTypeId = rt.Id,
                    AV_NumPerso__c = '000',
                    AV_Negocio__c = 'CIB',
                    AV_EAPGestor__c = c.Id
                );
            insert accTest;
            Contact conTest = CIBE_TestHelper.createEmployee(accTest, usrTest,'U0000009');

            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
                opp.AccountId = accTest.Id;
                opp.Name = 'Test Alerta Comercial 0';
                opp.StageName = 'Potencial';
                opp.RecordTypeId = rtOpp.Id;
                opp.CloseDate = System.today() + 5;
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
                opp.OwnerId = managerUser.Id;
                opp.AV_Gestor__c = c.Id;
                opp.AV_IncludeInPrioritizingCustomers__c = true;
                opp.AV_FechaProximoRecordatorio__c = system.today() + 1;
                opp.AV_PF__c = prodPF.Id;
                opp.CIBE_PriceApprove__c = 'Pendiente aprobación';
                opp.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
                opp.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
            insert opp;   
            AV_CustomActivityOpportunity__c cao = new AV_CustomActivityOpportunity__c ();
            cao.AV_Opportunity__c = opp.id;
            cao.AV_Stage__c = 'Potencial';
            insert cao;

            Test.startTest();

    //CREACIÓN DE OPORTUNIDADES VENCIDAS
            RecordType rtOppEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Date yesterday = Date.today().addDays(-1);
            Opportunity opp1 = new Opportunity();
                opp1.AccountId = accTest.Id;
                opp1.Name = 'Test Alerta Comercial 1';
                opp1.StageName = 'CIBE_Vencido';
                opp1.RecordTypeId = rtOppEMP.Id;
                opp1.CloseDate = System.today();
                opp1.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 1';
                opp1.OwnerId = managerUser.Id;
                opp1.AV_Gestor__c = c.Id;
                opp1.AV_IncludeInPrioritizingCustomers__c = true;
                opp1.AV_PF__c = prodPF.Id;
                opp1.CIBE_PriceApprove__c = 'Pendiente aprobación';
                opp1.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
                opp1.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';

            Opportunity opp2 = new Opportunity();
                opp2.AccountId = accTest.Id;
                opp2.Name = 'Test Alerta Comercial 2';
                opp2.StageName = 'CIBE_Vencido';
                opp2.RecordTypeId = rtOppEMP.Id;
                opp2.CloseDate = System.today();
                opp2.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 2';
                opp2.OwnerId = managerUser.Id;
                opp2.AV_Gestor__c = c.Id;
                opp2.AV_IncludeInPrioritizingCustomers__c = true;
                opp2.AV_PF__c = prodPF.Id;
                opp2.CIBE_PriceApprove__c = 'Pendiente aprobación';
                opp2.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
                opp2.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';

            Opportunity opp3 = new Opportunity();
                opp3.AccountId = accTest.Id;
                opp3.Name = 'Test Alerta Comercial 3';
                opp3.StageName = 'CIBE_Vencido';
                opp3.RecordTypeId = rtOppEMP.Id;
                opp3.CloseDate = System.today();
                opp3.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 3';
                opp3.OwnerId = managerUser.Id;
                opp3.AV_Gestor__c = c.Id;
                opp3.AV_IncludeInPrioritizingCustomers__c = true;
                opp3.AV_PF__c = prodPF.Id;
                opp3.CIBE_PriceApprove__c = 'Pendiente aprobación';
                opp3.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
                opp3.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
                
            Opportunity opp4 = new Opportunity();
            opp4.AccountId = accTest.Id;
            opp4.Name = 'Test Alerta Comercial 4';
            opp4.StageName = 'En curso';
            opp4.RecordTypeId = rtOppEMP.Id;
            opp4.CloseDate = System.today();
            opp4.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 4';
            opp4.OwnerId = managerUser.Id;
            opp4.AV_Gestor__c = c.Id;
            opp4.AV_IncludeInPrioritizingCustomers__c = true;
            opp4.AV_PF__c = prodPF.Id;
            opp4.CIBE_PriceApprove__c = 'Pendiente aprobación';
            opp4.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
            opp4.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';    
            List <Opportunity> listOppVencidas = new List <Opportunity>{opp1,opp2,opp3, opp4};

            insert listOppVencidas;

            DateTime activityDate = Date.today();
            RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            Event event = new Event();
            event.Subject = 'Call prueba test 12';
            event.WhatId = accTest.Id;
            event.AV_Tipo__c = 'VLD';
            event.OwnerId = managerUser.Id;
            
            
            String externalId = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = true,
                OwnerId = managerUser.Id
            );
            insert acthead;
            
            String randomExternalId = String.valueof((Math.random() * 10000000));
            event.AV_ExternalID__c = randomExternalId;
            event.RecordTypeId = rtEvent.Id;
            event.DurationInMinutes= 60;
            event.AV_Task__c=acthead.id;
            event.ActivityDateTime = activityDate;
            event.StartDateTime = activityDate;
            event.EndDateTime = activityDate.addMinutes(60);
            event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            event.Description = 'Prueba';
            insert event;

            RecordType rtTsk = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
            //Task tsk = CIBE_TestHelper.createTareaOrigenApp(managerUser, rtTsk);

            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente';
            tarea.OwnerId = managerUser.Id;
            tarea.Status = 'Pendiente no localizado';
            tarea.Priority = 'Normal';

            String externalId2 = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead2 = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId2,
                AV_ToDelete__c = true,
                OwnerId = managerUser.Id
            );
            insert acthead2;

            tarea.AV_OrigenApp__c = ' ';
            tarea.AV_ExternalID__c = '01928363';
            tarea.RecordTypeId = rtTsk.Id;
            tarea.ActivityDate = System.today()-1;
            tarea.AV_ToDelete__c = false;
            tarea.AV_Task__c = acthead.id;
            insert tarea;

            List<AV_CustomActivityOpportunity__c> lstCAO = new List<AV_CustomActivityOpportunity__c>();
            AV_CustomActivityOpportunity__c tareaOpp = new AV_CustomActivityOpportunity__c();
            tareaOpp.Name = 'Llamada Saliente - Alerta Comercial Test opp1';
            tareaOpp.AV_Opportunity__c = opp1.Id;
            tareaOpp.AV_Task__c = event.AV_Task__c;
            lstCAO.add(tareaOpp);
    
            AV_CustomActivityOpportunity__c tareaOpp2 = new AV_CustomActivityOpportunity__c();
            tareaOpp2.Name = 'Llamada Saliente - Alerta Comercial Test tsk1';
            tareaOpp2.AV_Opportunity__c = opp1.Id;
            tareaOpp2.AV_Task__c = tarea.AV_Task__c;
    
            lstCAO.add(tareaOpp2);
            insert lstCAO;
            
            Test.stopTest();
        }
    
    }
    /***********************************************************************************************************/
    @isTest
    private static void fillFieldsFromOppTEST() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
    
		System.runAs(usuario){
            Test.startTest(); 
            CIBE_TestHelper.createCustomerSinCliente();   
            List<Opportunity> listOpp=[Select Id, StageName, CIBE_LastStageModifiedDate__c from Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id AND Name = 'Test Alerta Comercial 0'];
            System.assert(listOpp != null);
                if(!listOpp.isEmpty()){
                    update listOpp;
                }
            Test.stopTest();
        }
    }
    /***********************************************************************************************************/
    @isTest
    private static void asignEstadoValueTEST() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        
		System.runAs(usuario){
            Test.startTest();  
            CIBE_TestHelper.createCustomerSinCliente();  
            List<Opportunity> listOpp=[Select Id, StageName, CIBE_LastStageModifiedDate__c from Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id];
            System.assert(listOpp != null);
                for(Opportunity opp:listOpp){ 
                    opp.StageName='En curso';
                }
                
                if(!listOpp.isEmpty()){
                    update listOpp;
                }
            Test.stopTest();
        }
    }
    /***********************************************************************************************************/
    @isTest
    private static void asignAltaValuesTEST() {

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

		System.runAs(usuario){
            Test.startTest();    
                List<Opportunity> listOpp=[SELECT Id, StageName, CIBE_LastStageModifiedDate__c from Opportunity WHERE RecordType.DeveloperName LIKE 'CIBE_%' AND OwnerId =:usuario.id AND Name = 'Test Alerta Comercial 0'];
                System.assert(listOpp != null);
    
                for(Opportunity opp:listOpp){ 
                    System.assertEquals(opp.StageName, 'Potencial');
                    opp.StageName='En curso';
                }
                
                if(!listOpp.isEmpty()){
                    update listOpp;
                }
            Test.stopTest();
        }
    }
    
    /***********************************************************************************************************/
    @isTest
    private static void validateDeleteOpportunityTEST() {
        List<String> lstRT = new List<String>{CIBE_AppConstants.OPP_INICIATIVACIB_RT,CIBE_AppConstants.OPP_INICIATIVAEMP_RT};
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        System.runAs(usuario) {
			Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_ALTAOPP','OK'));
            Test.startTest();
                Opportunity opp = [SELECT Id, OwnerId, AccountId, AV_ModificacionTelefonica__c, AV_Contrato__c FROM Opportunity WHERE RecordType.DeveloperName IN :lstRT AND Name = 'Test Alerta Comercial 0' LIMIT 1];
                System.assert(opp != null);

                Account acc = [SELECT Id FROM Account WHERE id=:opp.AccountId LIMIT 1];
                system.assert(acc != null);
                Task tsk = CIBE_TestHelper.createTareaExternalIdWithCustomer(usuario, 'U0000001', acc);

                AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidadExt(opp, tsk.AV_ExternalId__c);

                Boolean expectedExceptionThrown = false;

                try{
                    delete(opp);
                }catch(Exception e){
                    expectedExceptionThrown = true;
                    System.AssertNotEquals(null, e);
                }
                if(!expectedExceptionThrown){
                    Opportunity opp2 = [SELECT Id, OwnerId, AccountId, AV_ModificacionTelefonica__c, AV_Contrato__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
                    System.assert(opp2 == null);
                }
            Test.stopTest();
        }
    }
    
    /***********************************************************************************************************/

    @isTest
    private static void calculateCurrencyTEST() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

		System.runAs(usuario){
            Test.startTest();
            CIBE_Divisas__c divisa =  new CIBE_Divisas__c();
            divisa.CIBE_DivisaBase__c ='166' ;
            divisa.CIBE_CodigoDivisa__c = 'ESP';
            divisa.CIBE_NombreDivisa__c = 'PESETA';
            divisa.CIBE_FechaTipoCambio__c = System.Today();            
            insert divisa;
            
            
                                List<Opportunity> listOpp=[Select Id,CIBE_Divisa__c, CIBE_AmountDivisa__c,CIBE_BalanceDivisa__c,CIBE_ComisionesDivisa__c,CIBE_ImpactoDIvisaBalanceCierreAnio__c,CIBE_ImpactoDivisaComisionesCierreAnio__c from Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id AND Name = 'Test Alerta Comercial 0'];
                System.assert(listOpp != null);
            
                for(Opportunity opp:listOpp){ 
                    opp.CIBE_Divisa__c='ESP';
                    opp.CIBE_AmountDivisa__c=166;
                    opp.CIBE_BalanceDivisa__c=166;
                    opp.CIBE_ComisionesDivisa__c=166;
                    opp.CIBE_ImpactoDIvisaBalanceCierreAnio__c=166;
                    opp.CIBE_ImpactoDivisaComisionesCierreAnio__c=166;         
                }
                update listOpp;
            Test.stopTest();
        }
    }
    
    /***********************************************************************************************************/
    @isTest
    private static void checkCloseDateTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        System.runAs(usrSetup) {
			List<Opportunity> listOpp = [SELECT Id, CloseDate, StageName FROM Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id];
            for (Opportunity opp : listOpp){
                opp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI;
            }
            Test.startTest();    
                update listOpp;
                List<Opportunity> listOpp2 = [SELECT Id, CloseDate, StageName FROM Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id];
                System.assert(listOpp2 != null);
            Test.stopTest();
        }
    }
    
    /***********************************************************************************************************/
    
    @isTest
    private static void addRelationshipManagerTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
    
		System.runAs(usuario){
            Test.startTest();  
            List<Opportunity> listOpp = [SELECT Id, AccountId, OwnerId FROM Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id LIMIT 1];
            Set<Id> setIds = new Set<Id>();
            List<OpportunityTeamMember> newOppTMs = new List<OpportunityTeamMember>();
            OpportunityTeamMember newOppTM = new OpportunityTeamMember();
            newOppTM.OpportunityId = listOpp[0].Id;
            newOppTM.UserId = listOpp[0].OwnerId;
            newOppTM.TeamMemberRole = CIBE_AppConstants.PARTICIPANTE;
            newOppTM.OpportunityAccessLevel = 'Edit';
            newOppTMs.add(newOppTM);
            setIds.add(listOpp[0].OwnerId);
            CIBE_OpportunityTriggerHelper.addRelationshipManager(listOpp,newOppTMs,setIds);
            System.assert(listOpp != null);
            Test.stopTest();
        }

    }

    /***********************************************************************************************************/

    @isTest 
    public static void validarUpdateGCF(){
        
        Test.startTest();
        User userGcf =  [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        Opportunity oppoAntes = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c 
            FROM Opportunity WHERE Name = 'Test Alerta Comercial 0' LIMIT 1];

            System.runAs(userGcf){
                oppoAntes.AV_ToDelete__c = true;
                oppoAntes.AV_Comentarios__c = 'Comentario update';
                oppoAntes.AV_FechaProximoRecordatorio__c = System.today().addDays(2);
                oppoAntes.StageName = AV_AppConstants.OPP_STATUS_CERRPOST;
                oppoAntes.AV_FechaModificacion__c = System.today().addDays(1);
                oppoAntes.AV_Center__c = '999099';
                update(oppoAntes);
            }

        Test.stopTest();
        Opportunity oppUpdateGCF = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c FROM Opportunity WHERE id = :oppoAntes.Id LIMIT 1];

        System.assert(oppUpdateGCF.AV_ToDelete__c == true);
        System.assertEquals(AV_AppConstants.OPP_STATUS_CERRPOST, oppUpdateGCF.StageName);
        System.assertEquals('Comentario update', oppUpdateGCF.AV_Comentarios__c);
        System.assertEquals('999099', oppUpdateGCF.AV_Center__c);
    }

    /***********************************************************************************************************/

    @isTest 
    public static void stateOpportunityTest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        
        System.runAs(u) {

            Test.startTest();
                        List<Opportunity> listNews = [SELECT Id, CIBE_PriceApprove__c, CIBE_ApprovalRisk__c, Name, StageName FROM Opportunity  WHERE Name = 'Test Alerta Comercial 0'];
            System.assert(listNews != null);

            for (Opportunity opp : listNews){
                opp.CIBE_PriceApprove__c = 'No requiere';
                opp.CIBE_ApprovalRisk__c = 'No requiere';
            }
            
            update listNews;
            List<Opportunity> listNews2 = [SELECT Id, CIBE_PriceApprove__c, CIBE_ApprovalRisk__c, Name, StageName FROM Opportunity  WHERE Id = :listNews[0].Id];
            System.assert(listNews2[0].StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA);
            Test.stopTest();
        }
    }

    /***********************************************************************************************************/

    @isTest 
    public static void setOpportunityUsersTest(){
        
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        List<Opportunity> opps = new List<Opportunity>();
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Test Name'];
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000009' LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            opps = [SELECT Id, OwnerId, CIBE_OpportunityTeam__c FROM Opportunity WHERE Name = 'Test Alerta Comercial 0' AND OwnerId = :usuario.Id];
            opps[0].OwnerId = usrTest.Id;
            update opps;
        }

        System.runAs(usrTest){
            List<Opportunity> oppList2 = [SELECT Id, CIBE_OpportunityTeam__c, CIBE_OpportunityTeamMember__c, OwnerId  FROM Opportunity WHERE Id = :opps[0].Id];

            System.assert(oppList2[0].CIBE_OpportunityTeam__c != null);
            System.assertEquals(true, oppList2[0].CIBE_OpportunityTeamMember__c);
            System.assert(oppList2[0].CIBE_OpportunityTeam__c.contains(usrTest.Id));
        }
        Test.stoptest();        
        
    }

    /***********************************************************************************************************/    
    @isTest 
    public static void updateRelaSobjSinClientTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        List<Opportunity> opps = new List<Opportunity>();
        RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);

        Test.startTest();
        System.runAs(usuario){
            string idOpp;
            Account sinCliente = CIBE_TestHelper.createCustomerSinCliente();
            RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp2 = new Opportunity();
            opp2.AccountId = sinCliente.Id;
            opp2.Name = 'Test Alerta Comercial 4';
            opp2.StageName = 'Pendiente';
            opp2.RecordTypeId = rtOpp.Id;
            opp2.CloseDate = System.today();
            opp2.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 4';
            opp2.OwnerId = usuario.Id;
            opp2.AV_IncludeInPrioritizingCustomers__c = true;
            opp2.CIBE_PriceApprove__c = 'Pendiente aprobación';
            opp2.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
            opp2.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
            insert opp2;

            Task task = new Task();
            task.Subject = 'Prueba test insert';
            task.WhatId = sinCliente.Id;
            task.recordtypeid = rtTask.id;
            task.ownerid= usuario.id;
            task.Description = 'Prueba test insert';
            task.AV_CodigoGestorAsignado__c = '123456';
            task.Status = CIBE_AppConstants.TASK_STATUS_PENDIENTE;
            task.ActivityDate = System.now().Date();
            task.AV_AssociatedOpportunityId__c='1234';
            task.AV_ExternalID__c = 'Task-#1234567891011';
            insert task;

            AV_HeaderCustomActivity__c hca = [SELECT id,AV_ExternalID__c, IDTask__c FROM AV_HeaderCustomActivity__c LIMIT 1 ];

            AV_CustomActivityOpportunity__c cao = new AV_CustomActivityOpportunity__c ();
            cao.AV_Opportunity__c = idOpp;
            cao.AV_Stage__c = 'Potencial';
            cao.AV_Task__c = hca.id;
            insert cao;

            RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account accTest = [SELECT Id  FROM Account WHERE Name = 'Test Name' AND RecordTypeId =: rtAcc.Id LIMIT 1];
            opp2.AccountId = accTest.Id;
            update opp2;
            List<Task> taskList = [SELECT Id, AV_ExternalID__c,accountId FROM TASK WHERE id=:task.Id limit 1];
            System.assert(!taskList.isEmpty());
        }
        Test.stoptest();  
        
    }

/***********************************************************************************************************/    
    @isTest 
    public static void createTaskTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        List<Opportunity> opps = new List<Opportunity>();

        Test.startTest();
        System.runAs(usuario){
            
            opps = [SELECT Id, OwnerId, CIBE_OpportunityTeam__c, AccountId FROM Opportunity WHERE Name = 'Test Alerta Comercial 0' AND OwnerId = :usuario.Id];
            opps[0].AV_IncludeInPrioritizingCustomers__c = false;
            update opps;
            opps[0].AV_FechaProximoRecordatorio__c = system.today() + 3;
            opps[0].AV_IncludeInPrioritizingCustomers__c = true;
            update opps;
            String taskExternalId = 'Opp-' + opps[0].Id;
            List<Task> taskList = [SELECT Id, AV_ExternalID__c FROM TASK limit 1];

            System.assert(!taskList.isEmpty());
        }
        Test.stoptest();    
        
    }

/***********************************************************************************************************/
    @isTest
    public static void insertOppTMTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);

        Test.startTest();

        Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' AND ownerId =: usuario.id];
        Account accTest = new Account(
            Name = 'Test Name Account',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '001',
            AV_Negocio__c = 'CIB',
            AV_EAPGestor__c = c.Id
        );
        insert accTest;

        AV_Book__c book  = new AV_Book__c();
        book.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA, CIBE_AppConstants.CARTERA).Id;
        book.AV_ExternalID__c = '00002EAP002';
        book.AV_Activa__c = 'S';
        book.AV_TipoCartera__c = 'ETR';
        book.OwnerId = usuario.Id;
        book.AV_ToDelete__c = false;
        insert book;
        AV_BookMember__c bookm  = new AV_BookMember__c();
            bookm.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA_CLIENTE, CIBE_AppConstants.CARTERA_CLIENTE).Id;
            bookm.AV_Cliente__c = accTest.Id;
            bookm.AV_Cartera__c = book.Id;
            bookm.AV_CarteraPrincipal__c = true;
            bookm.AV_ToDelete__c = false;
        insert bookm;
        AV_BookManagementMember__c bookManagementMember =  CIBE_TestHelper.createBookManagement(c, book);


        System.runAs(usuario){
            RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = accTest.Id;
                opp.Name = 'Test Alerta Comercial 5';
                opp.StageName = 'Potencial';
                opp.RecordTypeId = rtOpp.Id;
                opp.CloseDate = System.today() + 5;
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
                opp.OwnerId = usuario.Id;
                opp.AV_Gestor__c = c.Id;
                opp.CIBE_PriceApprove__c = 'Pendiente aprobación';
                opp.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
            insert opp;   
            List<Opportunity> oppList = [SELECT Id, OwnerId, CIBE_OpportunityTeam__c, AccountId, Name FROM Opportunity WHERE Name = 'Test Alerta Comercial 5' AND OwnerId = :usuario.Id LIMIT 1] ;
            System.assert(!oppList.isEmpty());
            List <OpportunityTeamMember> oppTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :oppList[0].Id];
            System.assert(!oppTM.isEmpty());

        }
        Test.stoptest();    
    }

/***********************************************************************************************************/
@isTest
    public static void updateStageNameTest(){
        
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();

        System.runAs(usuarioG){
            List <Opportunity> listOppsNewsVencidas = [SELECT Id, CloseDate, StageName FROM Opportunity WHERE StageName = 'CIBE_Vencido' LIMIT 3];
            listOppsNewsVencidas[0].CloseDate = System.today() + 1;
            listOppsNewsVencidas[1].StageName =  'CIBE_Cerrado positivo';
            listOppsNewsVencidas[1].CIBE_Visto__c = 'NO';
            update listOppsNewsVencidas;

            List <Opportunity> listOppsNews = [SELECT Id, CloseDate, StageName FROM Opportunity WHERE Id IN :listOppsNewsVencidas LIMIT 3];
            System.assertEquals('En curso', listOppsNews[0].StageName);
            System.assertEquals(Date.today(), listOppsNews[1].CloseDate);
            
            listOppsNewsVencidas[2].StageName =  'Potencial';

            
            try{
                update(listOppsNews[2]);
            }catch(Exception e){
                Boolean expectedExceptionThrown = e.getMessage().contains(ERROR_MESSAGE_STAGENAME) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
        }
        Test.stoptest(); 
    }

    /***********************************************************************************************************/
    @isTest
    public static void commentsHistoryTest(){
        User userG =  [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Opportunity opp4 = [SELECT Id,AV_Comentarios__c, RecordTypeId FROM Opportunity WHERE Name = 'Test Alerta Comercial 4' LIMIT 1];
        AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
			commHist.OwnerId = userG.Id;
			commHist.AV_ModificationDate__c = Date.today();
			commHist.AV_Opportunity__c = opp4.Id;
			insert commHist;

        Test.startTest();
        System.runAs(userG){
            opp4.AV_Comentarios__c = 'Cambiar comentario 01';
            Database.update(opp4);
        }
        
        AV_CommentsHistory__c cm =[SELECT ID,AV_NewComment__c,AV_Opportunity__c FROM AV_CommentsHistory__c WHERE AV_Opportunity__c = :opp4.Id  LIMIT 1];
        System.assertNotEquals(cm.AV_NewComment__c,'Cambiar comentario 01');
        
        List<Opportunity> deletedOpportunityList = new List<Opportunity>{opp4};
        CIBE_OpportunityTriggerHelper.deleteCommentsHistory(deletedOpportunityList);
        List<AV_CommentsHistory__c> afterDeleteList = [SELECT Id FROM AV_CommentsHistory__c WHERE Id = :cm.Id];
        System.assertEquals(0, afterDeleteList.size(), 'The AV_CommentsHistory__c record should be deleted');
        Test.stopTest();
    }  


    /***********************************************************************************************************/
    @isTest
    public static void deleteRelationsTest(){
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();

        System.runAs(usuarioG){
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account accTest = new Account(
                Name = 'Test Name 2',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '021',
                AV_Negocio__c = 'EMP'
            );
            insert accTest;
            RecordType rtOppEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Event evento = CIBE_TestHelper.createEvent(usuarioG, System.today(), accTest);
            Opportunity opp1 = [SELECT Id,AV_Comentarios__c, RecordTypeId FROM Opportunity WHERE Name = 'Test Alerta Comercial 1' LIMIT 1];

            CIBE_TestHelper.createTareaOportunidad(opp1, evento.AV_Task__c);
            List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp1.Id];
            System.assert(!relacionado.isEmpty());
            delete opp1;
            List<AV_CustomActivityOpportunity__c> relacionado2 = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp1.Id];
            System.assert(relacionado2.isEmpty());
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Alerta Comercial 1'];
            System.assert(opp.isEmpty());

        }
        Test.stoptest(); 
    }  


    /***********************************************************************************************************/
    @isTest
    public static void saveFieldsFromOppTest(){
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();
        System.runAs(usuarioG){
            Id contactUser = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuarioG.Id].Id;
            Opportunity opp1 = [SELECT Id,AV_Comentarios__c, RecordTypeId FROM Opportunity WHERE Name = 'Test Alerta Comercial 4' LIMIT 1];
            update opp1;
            List<Opportunity> opp = [SELECT Id, AV_EmpleadoModificacion__c FROM Opportunity WHERE Name = 'Test Alerta Comercial 4'];
            System.assertEquals(contactUser, opp[0].AV_EmpleadoModificacion__c);
        }
        Test.stoptest(); 
    }  

    /***********************************************************************************************************/

    @isTest
    public static void updateCommentsHistoryTest(){
        User userG =  [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Name'];
        Opportunity oppSet = [SELECT Id,AV_Comentarios__c FROM Opportunity WHERE Name = 'Test Alerta Comercial 1'];
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<AV_CustomActivityOpportunity__c> lstCAO = new List<AV_CustomActivityOpportunity__c>();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
        Event event = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Call prueba test 12'];
        Task tsk = [SELECT Id,  AV_Task__c FROM Task WHERE Subject = 'Llamada Saliente'];

        Test.startTest();
        System.runAs(userG){
                oppSet.AV_Comentarios__c = 'test';
                lstOpp.add(oppSet);
                update lstOpp;
        }        
        Test.stopTest();
        List<AV_CommentsHistory__c> commt = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Opportunity__c = :oppSet.Id ];
        System.assert(!commt.isEmpty());

    }
    
    @isTest
    public static void updateCommentsHistory2Test(){
        User userG =  [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Name'];
        Test.startTest();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = rt.Id;
        opp.AccountId = acc.Id;
        opp.Name = 'Alerta Comercial Test opp 2';
        opp.StageName = 'En curso';
        opp.CloseDate = System.today() + 5;
        opp.ownerId = userG.Id;
        insert opp;

        Event event = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Call prueba test 12'];
        AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
        tareaOpp.Name = 'Llamada Saliente - Alerta Comercial Test opp2';
        tareaOpp.AV_Opportunity__c = opp.Id;
        tareaOpp.AV_Task__c = event.AV_Task__c;
        insert tareaOpp;

        Task tsk = [SELECT Id, AV_ExternalId__c, AV_Task__c FROM Task WHERE Subject = 'Llamada Saliente'];
        AV_CustomActivityOpportunity__c tareaOpp2 = new AV_CustomActivityOpportunity__c();
        tareaOpp2.Name = 'Llamada Saliente - Alerta Comercial Test tsk2';
        tareaOpp2.AV_Opportunity__c = opp.Id;
        tareaOpp2.AV_Task__c = tsk.AV_Task__c;
        insert tareaOpp2;
        System.runAs(userG){
            opp.StageName = 'CIBE_Pendiente_Firma';
            update opp;
            List<AV_CommentsHistory__c> commt = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Event__c = :event.AV_Task__c];
            System.assert(!commt.isEmpty());
            List<AV_CommentsHistory__c> commt2 = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Task__c = :tsk.AV_Task__c];
            System.assert(!commt2.isEmpty());
        }        
        Test.stopTest();
    }  
    
}