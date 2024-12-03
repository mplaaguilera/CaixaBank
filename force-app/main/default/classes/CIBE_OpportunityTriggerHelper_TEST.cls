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

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_OpportunityTriggerHelper_TEST {
    
    private static final String ERROR_MESSAGE			= Label.AV_deleteToOpp;
    private static final String ERROR_MESSAGE_CONTACT	= Label.CIBE_ErrorContact;
    
    /***********************************************************************************************************/
    @TestSetup
    static void setup(){ 

        CIBE_TestInitialSetup.setupInitialDataCIB();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        //Run As ByPass Non Setup Object
        System.runAs(new User(Id = UserInfo.getUserId())){
        Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' AND ownerId =: u.id];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account accTest = new Account(
                Name = 'Test Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '000',
                AV_Negocio__c = 'CIB',
                AV_EAPGestor__c = c.Id
            );
        insert accTest;

        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);

        RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Opportunity opp = new Opportunity();
            opp.AccountId = accTest.Id;
            opp.Name = 'Test Alerta Comercial 1';
            opp.StageName = 'Potencial';
            opp.RecordTypeId = rtOpp.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.OwnerId = u.Id;
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




        }
    
    }
    /***********************************************************************************************************/
    @isTest
    private static void fillFieldsFromOppTEST() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
    
		System.runAs(usuario){
            Test.startTest();    
            List<Opportunity> listOpp=[Select Id, StageName, CIBE_LastStageModifiedDate__c from Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id];
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
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        
		System.runAs(usuario){
            Test.startTest();    
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

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

		System.runAs(usuario){
            Test.startTest();    
                List<Opportunity> listOpp=[Select Id, StageName, CIBE_LastStageModifiedDate__c from Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id];
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
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
		//System.runAs(usuario){

        System.runAs(new User(Id = UserInfo.getUserId())) {
			//Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_ALTAOPP','OK'));
            Test.startTest();
                //Account acc = [SELECT Id FROM Account LIMIT 1];
                //system.assert(acc != null);
                
                //Contact employee = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' and CC_Matricula__c != null LIMIT 1];
                //system.assert(employee != null);
                
                Opportunity opp = [SELECT Id, OwnerId, AccountId, AV_ModificacionTelefonica__c, AV_Contrato__c FROM Opportunity WHERE RecordType.DeveloperName IN :lstRT Limit 1];
                System.assert(opp != null);

                Account acc = [SELECT Id FROM Account WHERE id=:opp.AccountId LIMIT 1];
                system.assert(acc != null);
                Task tsk = CIBE_TestHelper.createTareaExternalIdWithCustomer(usuario, 'XXX-0001', acc);

                //AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidadExt(opp, tsk.AV_ExternalId__c);
                
                try{
                    Database.delete(opp);
                }catch(Exception e){
                    Boolean expectedExceptionThrown = e.getMessage().contains(ERROR_MESSAGE) ? true : false;

                    System.AssertEquals(expectedExceptionThrown, true);
                } 
            Test.stopTest();
        }
    }
    
    /***********************************************************************************************************/

    @isTest
    private static void calculateCurrencyTEST() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

		System.runAs(usuario){
            CIBE_Divisas__c divisa =  new CIBE_Divisas__c();
            divisa.CIBE_DivisaBase__c ='166' ;
            divisa.CIBE_CodigoDivisa__c = 'ESP';
            divisa.CIBE_NombreDivisa__c = 'PESETA';
            divisa.CIBE_FechaTipoCambio__c = System.Today();            
            insert divisa;
            
            Test.startTest();    
                List<Opportunity> listOpp=[Select Id,CIBE_Divisa__c, CIBE_AmountDivisa__c,CIBE_BalanceDivisa__c,CIBE_ComisionesDivisa__c,CIBE_ImpactoDIvisaBalanceCierreAnio__c,CIBE_ImpactoDivisaComisionesCierreAnio__c from Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id];
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
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
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
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
    
		System.runAs(usuario){
            List<Opportunity> listOpp = [SELECT Id, AccountId, OwnerId FROM Opportunity WHERE RecordType.DeveloperName Like 'CIBE_%' AND OwnerId =:usuario.id LIMIT 1];
            CIBE_OpportunityTriggerHelper.addRelationshipManager(listOpp);
            System.assert(listOpp != null);
        }
    }

    /***********************************************************************************************************/

    @isTest 
    public static void validarUpdateGCF(){
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            User userGcf = CIBE_TestHelper.loginUser('API Only', null, '001234', new List<String>{'CIBE_OperativaCIB', 'CIBE_OperativaEMP', 'CIBE_Integracion'});
        }
        
        Test.startTest();
        User userGcf =  [SELECT ID FROM USER WHERE AV_ExternalID__c = '001234' AND Profile.Name = 'API Only' and isActive = true LIMIT 1];
            Opportunity testOppo = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c 
            FROM OPPORTUNITY LIMIT 1];	
            testOppo.AV_ToDelete__c = false;
            testOppo.StageName = AV_AppConstants.OPP_STATUS_NOAPTO;
            testOppo.AV_ExternalID__c = '12344321';
            testOppo.AV_OrigenApp__c = 'AV_SalesforceReport';
            testOppo.OwnerId = userGcf.Id;
            update testOppo;	

            Opportunity oppoAntes = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c 
            FROM Opportunity WHERE AV_ToDelete__c = FALSE AND StageName != 'Potencial' AND StageName != 'Vencida' LIMIT 1];

            System.runAs(userGcf){
                oppoAntes.AV_ToDelete__c = true;
                oppoAntes.AV_Comentarios__c = 'Comentario update';
                oppoAntes.AV_FechaProximoRecordatorio__c = System.today().addDays(2);
                oppoAntes.StageName = AV_AppConstants.OPP_STATUS_CERRPOST;
                oppoAntes.AV_FechaModificacion__c = System.today().addDays(1);
                oppoAntes.AV_Center__c = '999099';
                Database.update(oppoAntes);
            }

        Test.stopTest();

        Opportunity oppoAU = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c FROM Opportunity WHERE id = :oppoAntes.Id LIMIT 1];
        System.assert(!oppoAU.AV_ToDelete__c);
        System.assertEquals(testOppo.StageName, oppoAU.StageName);
        System.assertEquals(testOppo.AV_Comentarios__c, oppoAU.AV_Comentarios__c);
        System.assertEquals(testOppo.AV_Center__c, oppoAU.AV_Center__c);
    }

    /***********************************************************************************************************/

    @isTest 
    public static void stateOpportunityTest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        
        System.runAs(u) {

            Test.startTest();
            List<Opportunity> listNews = [SELECT Id, CIBE_PriceApprove__c, CIBE_ApprovalRisk__c, Name, StageName FROM Opportunity  WHERE OwnerId = :u.Id];
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
        
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

        List<Opportunity> opps = new List<Opportunity>();
        Test.startTest();

        Account accTest = [SELECT Id FROM Account WHERE Name = 'Test Name' AND createdbyId = :UserInfo.getUserId() AND RecordType.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT And AV_NumPerso__c = '000' ];

        List<sObject> result = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor' LIMIT 1];
        Profile p = (Profile)result.get(0);
        Integer rand = Math.round(Math.random()*1000);
        Integer rand2 = Math.round(Math.random()*1000);
        User usrTest = new User(
            Alias = 'Test002',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '1111111',
            ProfileId = p.Id,
            UserName = 'test' + rand + '@test.env' + rand2 + '.es',
            IsActive = true
        );
        insert usrTest;

        Contact conTest = CIBE_TestHelper.createEmployee(accTest, usrTest);

        System.runAs(usuario){
            opps = [SELECT Id, OwnerId, CIBE_OpportunityTeam__c FROM Opportunity WHERE Name = 'Test Alerta Comercial 1' AND OwnerId = :usuario.Id];
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

    
    @isTest 
    public static void createTaskTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        
        List<Opportunity> opps = new List<Opportunity>();

        Test.startTest();
        System.runAs(usuario){
            
            opps = [SELECT Id, OwnerId, CIBE_OpportunityTeam__c, AccountId FROM Opportunity WHERE Name = 'Test Alerta Comercial 1' AND OwnerId = :usuario.Id];
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


    @isTest
    public static void insertOppTMTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
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
        book.AV_TipoCartera__c = 'INT';
        book.OwnerId = usuario.Id;
        insert book;
        AV_BookMember__c bookm  = new AV_BookMember__c();
            bookm.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA_CLIENTE, CIBE_AppConstants.CARTERA_CLIENTE).Id;
            bookm.AV_Cliente__c = accTest.Id;
            bookm.AV_Cartera__c = book.Id;
            bookm.AV_CarteraPrincipal__c = true;
        insert bookm;
        AV_BookManagementMember__c bookManagementMember =  CIBE_TestHelper.createBookManagement(c, book);

        RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Opportunity opp = new Opportunity();
            opp.AccountId = accTest.Id;
            opp.Name = 'Test Alerta Comercial 2';
            opp.StageName = 'Potencial';
            opp.RecordTypeId = rtOpp.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.OwnerId = usuario.Id;
            opp.AV_Gestor__c = c.Id;
            opp.CIBE_PriceApprove__c = 'Pendiente aprobación';
            opp.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
        insert opp;   


        System.runAs(usuario){
            List<Opportunity> oppList = [SELECT Id, OwnerId, CIBE_OpportunityTeam__c, AccountId, Name FROM Opportunity WHERE Name = 'Test Alerta Comercial 2' AND OwnerId = :usuario.Id];
            System.assert(!oppList.isEmpty());
            List <OpportunityTeamMember> oppTM = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :oppList[0].Id];
            System.assert(!oppTM.isEmpty());
        }
        Test.stoptest();    

    }

}