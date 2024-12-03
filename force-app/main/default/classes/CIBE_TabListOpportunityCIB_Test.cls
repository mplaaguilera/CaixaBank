/**********************************************************************************************************************
Name:	  CIBE_TabListOpportunityCIB_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de cobertura para class CIBE_TabListOpportunityCIB_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE			Description
	1.0			US461563    	Lucía	  	    16/03/2023		Init version 

***********************************************************************************************************************/

@isTest
public with sharing class CIBE_TabListOpportunityCIB_Test {
    
    @TestSetup
    public static void setup() {
        string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
        string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
        string rtContact = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        string rtJerarquia = Schema.getGlobalDescribe().get('CIBE_Hierarchy__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CIBE_Employee').getRecordTypeId();

        CIBE_TestInitialSetup.setupInitialDataCIB();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Contact contacto = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001'];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account cliente = CIBE_TestHelper.createCustomer();
    
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
            pickVal2.Name = 'Opcion2';
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
            
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            //creamos la oportunidad
            Opportunity opp = new Opportunity();
            opp.CIBE_Fechaaprobacionprecio__c = Date.newInstance(2023, 02, 03);
            opp.AccountId = cliente.Id;
            opp.Name = 'Alerta Comercial';
            opp.StageName = 'En curso';
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
            opp.CIBE_ESG__c = false;
            opp.CIBE_ECAs__c = true;
            opp.CIBE_AlgunaOperRAR__c = true;
            opp.CIBE_DictamenALM__c = false;
            opp.CIBE_Visto__c = 'IG';
            opp.CIBE_Nivel__c = '';
            opp.CIBE_Sindicaciones__c = false;
            opp.CIBE_Observaciones__c = '';
            opp.CIBE_VigenciaOferta__c = null;
            opp.OwnerId = usuario.Id;
            opp.AV_FechaAlta__c = System.today() - 5;
            insert opp;
        }
    }
    
    @isTest
    public static void getOpportunityTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Date fecha = Date.newInstance(2023, 02, 03);
            Date fechaDesde = null;
            Date fechaHasta = null;

            List<CIBE_TabListOpportunityCIB_Controller.OpportunityWrapper> wrapperList = CIBE_TabListOpportunityCIB_Controller.getOpportunity(0, fecha, fechaDesde, fechaHasta);
            System.assert(!wrapperList.isEmpty());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void exportTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Date fecha = Date.newInstance(2023, 02, 03);
            Date fechaDesde = null;
            Date fechaHasta = null;

            List<String> csv = CIBE_TabListOpportunityCIB_Controller.exportOpportunities();
            System.assert(!csv.isEmpty());
        }
        Test.stopTest();
    }
}