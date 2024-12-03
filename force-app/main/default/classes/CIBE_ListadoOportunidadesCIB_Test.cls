/**********************************************************************************************************************
Name:	  CIBE_ListadoOportunidadesCIB_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de cobertura para class CIBE_TabListOpportunityCIB_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE			Description
	1.0			US547699    	Luis	  	    20/04/2023		Init version 

***********************************************************************************************************************/

@IsTest
public with sharing class CIBE_ListadoOportunidadesCIB_Test {
    @TestSetup
	static void setup(){

        string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
        string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
        string rtContact = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        string rtJerarquia = Schema.getGlobalDescribe().get('CIBE_Hierarchy__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CIBE_Employee').getRecordTypeId();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGes;
        Contact contGes;
        System.runAs(new User(Id = UserInfo.getUserId())){
            usrGes = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
            contGes = CIBE_TestHelper.createEmployee(null, usrGes, 'U0009003');
        }
        Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);

        CBK_PicklistValues__c pick = new CBK_PicklistValues__c();
		pick.RecordTypeId = rtIdPick;
		pick.Name = 'Field Picklist';
		pick.CBK_Object__c = 'Object';
		insert pick;

        CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
		pickVal.RecordTypeId = rtIdPickVal;
		pickVal.CBK_Picklist__c = pick.Id;
		pickVal.Name = 'Opcion1';
		pickVal.CBK_HasDependency__c = true;
		pickVal.CBK_Dependencies__c = 'Valor1';
		insert pickVal;
        
        CBK_PicklistValues__c pickVal2 = new CBK_PicklistValues__c();
		pickVal2.RecordTypeId = rtIdPickVal;
		pickVal2.CBK_Picklist__c = pick.Id;
		pickVal2.Name = 'Sucursales';
		pickVal2.CBK_HasDependency__c = true;
		pickVal2.CBK_Dependencies__c = 'Valor12';
		insert pickVal2;

        CBK_PicklistValues__c pickVal3 = new CBK_PicklistValues__c();
		pickVal3.RecordTypeId = rtIdPickVal;
		pickVal3.CBK_Picklist__c = pick.Id;
		pickVal3.Name = 'Opcion3';
		pickVal3.CBK_HasDependency__c = true;
		pickVal3.CBK_Dependencies__c = 'Valor2';
		insert pickVal3;

        CBK_PicklistValues__c pickVal4 = new CBK_PicklistValues__c();
		pickVal4.RecordTypeId = rtIdPickVal;
		pickVal4.CBK_Picklist__c = pick.Id;
		pickVal4.Name = 'Opcion4';
		pickVal4.CBK_HasDependency__c = true;
		pickVal4.CBK_Dependencies__c = 'Valor22';
		insert pickVal4;
        
        CBK_PicklistValues__c pickVal5 = new CBK_PicklistValues__c();
		pickVal5.RecordTypeId = rtIdPickVal;
		pickVal5.CBK_Picklist__c = pick.Id;
		pickVal5.Name = 'Opcion5';
		pickVal5.CBK_HasDependency__c = true;
		pickVal5.CBK_Dependencies__c = 'Valor12';
		insert pickVal5;

        CBK_PicklistValues__c pickVal6 = new CBK_PicklistValues__c();
		pickVal6.RecordTypeId = rtIdPickVal;
		pickVal6.CBK_Picklist__c = pick.Id;
		pickVal6.Name = 'Opcion6';
		pickVal6.CBK_HasDependency__c = true;
		pickVal6.CBK_Dependencies__c = 'Valor2';
		insert pickVal6;

        CBK_PicklistValues__c pickVal7 = new CBK_PicklistValues__c();
		pickVal7.RecordTypeId = rtIdPickVal;
		pickVal7.CBK_Picklist__c = pick.Id;
		pickVal7.Name = 'Opcion7';
		pickVal7.CBK_HasDependency__c = true;
		pickVal7.CBK_Dependencies__c = 'Valor22';
		insert pickVal7;
        
        CBK_PicklistValues__c pickVal8 = new CBK_PicklistValues__c();
		pickVal8.RecordTypeId = rtIdPickVal;
		pickVal8.CBK_Picklist__c = pick.Id;
		pickVal8.Name = 'Opcion8';
		pickVal8.CBK_HasDependency__c = true;
		pickVal8.CBK_Dependencies__c = 'Valor22';
		insert pickVal8;

        Contact contacto = new Contact();
		contacto.LastName = 'Test';
		contacto.CC_Matricula__c = 'U0122222';
        contacto.RecordTypeId = rtContact;
        contacto.AV_UsuarioAsociado__c = usrGes.Id;
		insert contacto;

        //creamos la oportunidad
        List <Opportunity> lstOpps = new List <Opportunity>();
        Opportunity opp = new Opportunity();
            opp.ownerId = UserInfo.getUserId();
            opp.CIBE_Fechaaprobacionprecio__c = Date.newInstance(2023, 02, 03);
            opp.AccountId = centro.Id;
            opp.Name = 'Alerta Comercial';
            opp.StageName = 'Potencial';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_PF__c = prodPF.Id;
            opp.CIBE_AmountDivisa__c = 2;
            opp.CIBE_Divisa__c = 'USD';
            opp.CIBE_BalanceDivisa__c = 342.874;
            opp.CIBE_ComisionesDivisa__c = 323;
            opp.CIBE_Balance__c = 342.874;
            opp.CIBE_Comisiones__c = 323.248;
            opp.CIBE_TipoOperacion__c = 'Nueva';
            opp.CIBE_ProbabilidadExito__c = 'Alta';
            opp.CIBE_CerradoNegativo__c = 'Anulada';
            opp.CIBE_Pais__c = 'España';
            opp.AV_Gestor__c = contacto.Id;
        lstOpps.add(opp);

        Opportunity opp2 = new Opportunity();
            opp2.ownerId = usrGes.Id;
            opp2.CIBE_Fechaaprobacionprecio__c = Date.newInstance(2023, 02, 03);
            opp2.AccountId = centro.Id;
            opp2.Name = 'Alerta Comercial';
            opp2.StageName = 'Potencial';
            opp2.RecordTypeId = rt.Id;
            opp2.CloseDate = System.today() + 5;
            opp2.CIBE_AmountDivisa__c = 2;
            opp2.CIBE_Divisa__c = 'USD';
            opp2.CIBE_BalanceDivisa__c = 342.874;
            opp2.CIBE_ComisionesDivisa__c = 323;
            opp2.CIBE_Balance__c = 342.874;
            opp2.CIBE_Comisiones__c = 323.248;
            opp2.CIBE_TipoOperacion__c = 'Nueva';
            opp2.CIBE_ProbabilidadExito__c = 'Alta';
            opp2.CIBE_CerradoNegativo__c = 'Anulada';
            opp2.CIBE_Pais__c = 'España';
            opp2.AV_Gestor__c = contacto.Id;
        lstOpps.add(opp2);
        insert lstOpps;

        //Account Team Member
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.UserId = usrGes.Id;
        accTM.AccountId = centro.Id;
        insert accTM;

        //AV_Book__c
        AV_Book__c purseTest = CIBE_TestHelper.createPurse('50071');
        purseTest.AV_Negocio__c = 'CIB';
        update purseTest;
        //AV_BookManagementMember__c
        AV_BookManagementMember__c bookAssigmentTest = CIBE_TestHelper.createBookManagement(contGes, purseTest);
        //AV_BookMember__c
        AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(centro, purseTest);

        //jerarquia
        CIBE_Hierarchy__c jerarquia = new CIBE_Hierarchy__c();
        jerarquia.CIBE_Negocios__c = pickVal.Id;
        jerarquia.CIBE_RedesSegmentos__c = pickVal2.Id;
        jerarquia.CIBE_SectoresPaises__c = pickVal3.Id;
        jerarquia.CIBE_CentrosCarteras__c = pickVal4.Id;
        jerarquia.CIBE_Contact__c = contacto.Id;
        jerarquia.RecordTypeId = rtJerarquia;
        insert jerarquia;
        
        CIBE_Hierarchy__c jerarquia2 = new CIBE_Hierarchy__c();
        jerarquia2.CIBE_Negocios__c = pickVal5.Id;
        jerarquia2.CIBE_RedesSegmentos__c = pickVal6.Id;
        jerarquia2.CIBE_SectoresPaises__c = pickVal7.Id;
        jerarquia2.CIBE_CentrosCarteras__c = pickVal8.Id;
        jerarquia2.CIBE_Contact__c = contacto.Id;
        jerarquia2.RecordTypeId = rtJerarquia;
        insert jerarquia2;
    }

    @isTest
	public static void getOpportunityTeamsTest() {
        User usuarioG = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        List <CIBE_ListadoOportunidadesMisClientesCIB.OptionsParticipes> lstPar = new List <CIBE_ListadoOportunidadesMisClientesCIB.OptionsParticipes> ();
        List <String> segmentos = new List<String>();
        List <String> sectores = new List<String>();
        List <String> centros = new List<String>();
        System.runAs(usuarioG) {
            Test.startTest();
                for(CIBE_hierarchy__c jer : [SELECT  CIBE_CentrosCarteras__c, CIBE_RedesSegmentos__c,CIBE_SectoresPaises__c FROM CIBE_hierarchy__c WHERE CIBE_Negocios__c != null AND Recordtype.developername = 'CIBE_Employee' ]){
                    segmentos.add(jer.CIBE_RedesSegmentos__c);
                    sectores.add(jer.CIBE_SectoresPaises__c);
                    centros.add(jer.CIBE_CentrosCarteras__c);
                }
                lstPar =  CIBE_ListadoOportunidadesMisClientesCIB.getOpportunityTeams(false, segmentos, sectores, centros);
            Test.stopTest();
            System.assertEquals(false, !lstPar.isEmpty(), 'getOpportunityTeamsTest');
        }
    }  

    @isTest
	public static void getPaisesTest() {
        User usuarioG = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        List<CIBE_ListadoOportunidadesMisClientesCIB.OptionsIndustrias> lstPaises = new List<CIBE_ListadoOportunidadesMisClientesCIB.OptionsIndustrias>();

        System.runAs(usuarioG) {
            Test.startTest();
                lstPaises =  CIBE_ListadoOportunidadesMisClientesCIB.getPaises();
            Test.stopTest();
            System.assertEquals(false, lstPaises.isEmpty(), 'getPaisesTest sin pais');
        }
    }
    
    @isTest
	public static void getIndustriaInterTest() {
        User usuarioG = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        List<CIBE_ListadoOportunidadesMisClientesCIB.OptionsIndustrias> listInter = new List<CIBE_ListadoOportunidadesMisClientesCIB.OptionsIndustrias>();
        System.runAs(usuarioG) {
            Test.startTest();
                List <String> segmentos = new List<String>();
                for(CIBE_hierarchy__c jer : [SELECT CIBE_RedesSegmentos__c FROM CIBE_hierarchy__c WHERE CIBE_Negocios__c != null AND Recordtype.developername = 'CIBE_Employee']){
                    segmentos.add(jer.CIBE_RedesSegmentos__c);
                }
                listInter =  CIBE_ListadoOportunidadesMisClientesCIB.getIndustriaInter(segmentos);
            Test.stopTest();
            System.assertEquals(false, !listInter.isEmpty(), 'getIndustriaInterTest');
        }
    }  

    @isTest
	public static void getBaseDataTest() {
        User usuarioG = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        User userGesN = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c != 'U0009003' LIMIT 1];

        List<CIBE_ListadoOportunidadesMisClientesCIB.OpportunityWrapper> listOppWrapp = new List<CIBE_ListadoOportunidadesMisClientesCIB.OpportunityWrapper>();
        System.runAs(usuarioG) {
            List <String> segmentos = new List<String>();
            List <String> sectores = new List<String>();
            List <String> centros = new List<String>();
            List <String> usuarioAsoc = new List<String>();
            List <String> pais = new List<String>();
            List <String> etapa = new List<String>();
            List <Date> fecha = new List<Date>();
            Test.startTest();
                for(CIBE_hierarchy__c jer : [SELECT  CIBE_CentrosCarteras__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c, CIBE_Contact__r.AV_UsuarioAsociado__c FROM CIBE_hierarchy__c WHERE CIBE_Negocios__c != null AND Recordtype.developername = 'CIBE_Employee' ]){
                    segmentos.add(jer.CIBE_RedesSegmentos__c);
                    sectores.add(jer.CIBE_SectoresPaises__c);
                    centros.add(jer.CIBE_CentrosCarteras__c);
                    usuarioAsoc.add(jer.CIBE_Contact__r.AV_UsuarioAsociado__c);
                }
                Account ac =  CIBE_TestHelper.createConfidencialCustomer();
                Account acc = CIBE_TestHelper.createCustomerSinCliente();
                List<Opportunity> lstOpp =  [SELECT id, OwnerId, Owner.Name, CIBE_Pais__c, closeDate, CIBE_ESG__c, stageName, AccountId
                FROM Opportunity 
                WHERE Recordtype.DeveloperName =:CIBE_AppConstants.OPP_INICIATIVACIB_RT AND stageName ='Potencial' AND CIBE_Pais__c ='España' Limit 10 ];
                if(!lstOpp.isEmpty()){
                    for(Opportunity opp: lstOpp){
                        pais.add(opp.CIBE_Pais__c);
                        etapa.add(opp.stageName);
                        fecha.add(opp.closeDate);
                        if(opp.OwnerId == usuarioG.Id && usuarioG.Id!=null ){
                            opp.OwnerId = userGesN.Id;
                            opp.AccountId = ac.Id;
                        }
                    }
                    update lstOpp;
                }
                listOppWrapp =  CIBE_ListadoOportunidadesMisClientesCIB.getOppsFilter(segmentos,sectores,centros,usuarioAsoc, etapa, pais, fecha, sectores, false, false,0);
            Test.stopTest();
            System.assertEquals(false, !listOppWrapp.isEmpty(), 'getBaseDataTest');
        }
    }  

    @isTest
	public static void exportOpportunitiesTest() {
        User usuarioG = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        List <String> listOppWrapp = new List<String>();
        List <String> segmentos = new List<String>();
        List <String> sectores = new List<String>();
        List <String> centros = new List<String>();
        List <String> usuarioAsoc = new List<String>();
        List <String> pais = new List<String>();
        List <String> etapa = new List<String>();
        List <Date> fecha = new List<Date>();
        System.runAs(usuarioG) {
            Test.startTest();
                List<CIBE_hierarchy__c> lstJer =  [SELECT  CIBE_CentrosCarteras__c, CIBE_RedesSegmentos__c,CIBE_SectoresPaises__c, CIBE_Contact__r.AV_UsuarioAsociado__c FROM CIBE_hierarchy__c WHERE CIBE_Negocios__c != null AND Recordtype.developername = 'CIBE_Employee' ];
                List<Opportunity> lstOpp =  [SELECT id, OwnerId, CIBE_Pais__c, closeDate, CIBE_ESG__c, stageName FROM Opportunity WHERE Recordtype.DeveloperName =:CIBE_AppConstants.OPP_INICIATIVACIB_RT AND stageName ='Potencial' AND CIBE_Pais__c ='España' Limit 10 ];
                if(!lstOpp.isEmpty()){
                    for(Opportunity opp: lstOpp){
                        pais.add(opp.CIBE_Pais__c);
                        etapa.add(opp.stageName);
                        fecha.add(opp.closeDate);
                    }
                }
                listOppWrapp =  CIBE_ListadoOportunidadesMisClientesCIB.exportOpportunities(segmentos,sectores,centros,usuarioAsoc, etapa, pais, fecha, sectores, true, lstOpp[0].CIBE_ESG__c);
            Test.stopTest();
            System.assertEquals(true, !listOppWrapp.isEmpty(), 'exportOpportunitiesTest');
        }
    }

    @isTest
	public static void getBaseDataTest2() {
        User usuarioG = [SELECT Id, name FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        List<CIBE_ListadoOportunidadesMisClientesCIB.OpportunityWrapper> listOppWrapp = new List<CIBE_ListadoOportunidadesMisClientesCIB.OpportunityWrapper>();
        List <String> segmentos = new List<String>();
        List <String> sectores = new List<String>();
        List <String> centros = new List<String>();
        List <String> usuarioAsoc = new List<String>();
        List <String> pais = new List<String>();
        List <String> etapa = new List<String>();
        List <Date> fecha = new List<Date>();
        System.runAs(usuarioG) {
            Test.startTest();
                List<CIBE_hierarchy__c> lstJer =  [SELECT  CIBE_CentrosCarteras__c, CIBE_RedesSegmentos__c,CIBE_SectoresPaises__c, CIBE_Contact__r.AV_UsuarioAsociado__c FROM CIBE_hierarchy__c WHERE CIBE_Negocios__c != null AND Recordtype.developername = 'CIBE_Employee' ];
                List<Opportunity> lstOpp =  [SELECT id, OwnerId, CIBE_Pais__c, closeDate, CIBE_ESG__c, stageName FROM Opportunity WHERE Recordtype.DeveloperName =:CIBE_AppConstants.OPP_INICIATIVACIB_RT AND stageName ='Potencial' AND CIBE_Pais__c ='España' Limit 10 ];
                if(!lstOpp.isEmpty()){
                    for(Opportunity opp: lstOpp){
                        pais.add(opp.CIBE_Pais__c);
                        etapa.add(opp.stageName);
                        fecha.add(opp.closeDate);
                    }
                }
                listOppWrapp =  CIBE_ListadoOportunidadesMisClientesCIB.getOppsFilter(segmentos,sectores,centros,usuarioAsoc, etapa, pais, fecha, sectores, true, lstOpp[0].CIBE_ESG__c,0);
            Test.stopTest();
            System.assertEquals(true, !listOppWrapp.isEmpty(), 'getBaseDataOppsDatosTest');
        }
    }    
}