/**********************************************************************************************************************
Name:	  CIBE_OpportunityComite
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para CIBE_OpportunityComite
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE			Description
    1.0			PPM100275631    Lucía	  	    31/07/2024		Init version
    1.1			PPM100538662s   Lucía	  	    22/10/2024		New methods getOpportunityTest, updateALMTest, updateALMTestError, updateLoanSyndicateSalesCheckBoxTest, updateALMCheckBoxTest,  updateChiefCheckBoxTest

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_OpportunityComite_Test {

    @TestSetup
    public static void setup() {
        string rtIdPickVal = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
        string rtIdPick = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
        string rtContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        string rtJerarquia = Schema.SObjectType.CIBE_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('CIBE_Employee').getRecordTypeId();

        CIBE_TestInitialSetup.setupInitialDataCIB();
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        Contact contacto = [SELECT Id, av_usuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U0000001'];

        Test.startTest();
        System.runAs(admin) {
            Account cliente = CIBE_TestHelper.createCustomerWithEAPGestor(contacto);
    
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

            CBK_PicklistValues__c pickValValor = new CBK_PicklistValues__c();
            pickValValor.RecordTypeId = rtIdPickVal;
            pickValValor.CBK_Picklist__c = pick.Id;
            pickValValor.Name = 'Valor1';
            pickValValor.CBK_HasDependency__c = false;
            insert pickValValor;

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
            //jerarquia
            CIBE_Hierarchy__c jerarquia = new CIBE_Hierarchy__c();
            jerarquia.CIBE_Negocios__c = pickVal.Id;
            jerarquia.CIBE_RedesSegmentos__c = pickValValor.Id;
            jerarquia.CIBE_SectoresPaises__c = pickVal3.Id;
            jerarquia.CIBE_CentrosCarteras__c = pickVal4.Id;
            jerarquia.CIBE_Contact__c = contacto.Id;
            jerarquia.RecordTypeId = rtJerarquia;
            insert jerarquia;
            
            
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            //creamos la oportunidad
            Opportunity opp = new Opportunity();
            opp.CIBE_Fechaaprobacionprecio__c = Date.newInstance(2023, 02, 03);
            opp.AccountId = cliente.Id;
            opp.Name = 'Alerta Comercial Test Jerarquia';
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
            opp.CIBE_Visto__c = 'SI';
            opp.CIBE_Nivel__c = '';
            opp.CIBE_Sindicaciones__c = false;
            opp.CIBE_SyndicationTeamOpinion__c = 'NO';
            opp.CIBE_Observaciones__c = '';
            opp.CIBE_VigenciaOferta__c = null;
            opp.OwnerId = contacto.av_usuarioAsociado__c;
            opp.AV_FechaAlta__c = System.today() - 5;
            opp.AV_Gestor__c = contacto.Id;
            opp.CIBE_LoanSyndicateSales__c = true;
            opp.CIBE_ALM__c = true;
            opp.CIBE_ChiefOperationsOfficer__c = true;
            insert opp;

            Opportunity oppCloseDateVencido = new Opportunity();
            oppCloseDateVencido.AccountId = cliente.Id;
            oppCloseDateVencido.Name = 'Alerta Comercial';
            oppCloseDateVencido.StageName = 'CIBE_Vencido';
            oppCloseDateVencido.RecordTypeId = rt.Id;
            oppCloseDateVencido.CloseDate = System.today() - 5;
            oppCloseDateVencido.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            insert oppCloseDateVencido;
        }
        Test.stopTest();
    }

    @isTest
    public static void updateCreditoPortfolioTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            List<String> recordId = new List<String>();
            if(opp != null){
                recordId.add(opp.Id);
            }
            String result = CIBE_OpportunityComite.updateCreditoPortfolio(recordId, 'SI', 'Opcion1', 'Valor1');
            System.assertEquals('OK', result);
        }
        Test.stopTest();
    }

    @isTest
    public static void updateEquipoSindicacionesTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            List<String> recordId = new List<String>();
            if(opp != null){
                recordId.add(opp.Id);
            }
            String result = CIBE_OpportunityComite.updateEquipoSindicaciones(recordId, 'SI', 'Opcion1', 'Valor1', false);
            System.assertEquals('OK', result);
        }
        Test.stopTest();
    }


    @isTest
    public static void updateCreditoPortfolioTestError(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial'];
            opp.StageName = 'En gestión/insistir';
            update opp;

            List<String> recordId = new List<String>();
            if(opp != null){
                recordId.add(opp.Id);
            }
            String result = CIBE_OpportunityComite.updateCreditoPortfolio(recordId, 'SI', 'Opcion1', 'Valor1');
            System.assertEquals('Introduzca una fecha de cierre no inferior desde la fecha actual o superior a 18 meses.', result);
        }
        Test.stopTest();
    }

    @isTest
    public static void updateEquipoSindicacionesTestError(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial'];
            opp.StageName = 'En gestión/insistir';
            update opp;
            List<String> recordId = new List<String>();
            if(opp != null){
                recordId.add(opp.Id);
            }
            String result = CIBE_OpportunityComite.updateEquipoSindicaciones(recordId, 'SI', 'Opcion1', 'Valor1', true);
            System.assertEquals('Introduzca una fecha de cierre no inferior desde la fecha actual o superior a 18 meses.', result);
        }
        Test.stopTest();
    }



    @isTest
    public static void getOpportunityTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial'];
            List<Opportunity> oppResult = CIBE_OpportunityComite.getOpportunity(opp.Id);
            System.assert(!oppResult.isEmpty());
        }
        Test.stopTest();
    }



    @isTest
    public static void updateALMTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            List<String> recordId = new List<String>();
            if(opp != null){
                recordId.add(opp.Id);
            }
            String result = CIBE_OpportunityComite.updateALM(recordId, 'SI', 'Test', 'Opcion1', 'Valor1', false);
            System.assertEquals('OK', result);
        }
        Test.stopTest();
    }


    @isTest
    public static void updateALMTestError(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial'];
            opp.StageName = 'En gestión/insistir';
            update opp;
            List<String> recordId = new List<String>();
            if(opp != null){
                recordId.add(opp.Id);
            }
            String result = CIBE_OpportunityComite.updateALM(recordId, 'SI', 'test', 'Opcion1', 'Valor1', true);
            System.assertEquals('Introduzca una fecha de cierre no inferior desde la fecha actual o superior a 18 meses.', result);
        }
        Test.stopTest();
    }

    @isTest
    public static void updateLoanSyndicateSalesCheckBoxTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id, CIBE_LoanSyndicateSales__c FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            String result = CIBE_OpportunityComite.updateLoanSyndicateSalesCheckBox(opp.Id, false);
            Opportunity oppUpdate = [SELECT Id, CIBE_LoanSyndicateSales__c FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            System.assertEquals(false, oppUpdate.CIBE_LoanSyndicateSales__c);
            System.assertEquals('OK', result);
        }
        Test.stopTest();
    }


    @isTest
    public static void updateALMCheckBoxTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id, CIBE_ALM__c FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];        
            String result = CIBE_OpportunityComite.updateALMCheckBox(opp.Id, false);
            Opportunity oppUpdate = [SELECT Id, CIBE_ALM__c FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            System.assertEquals(false, oppUpdate.CIBE_ALM__c);
        }
        Test.stopTest();
    }


    @isTest
    public static void updateChiefCheckBoxTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id, CIBE_ChiefOperationsOfficer__c FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            String result = CIBE_OpportunityComite.updateChiefCheckBox(opp.Id, false);
            Opportunity oppUpdate = [SELECT Id, CIBE_ChiefOperationsOfficer__c FROM Opportunity WHERE Name = 'Alerta Comercial Test Jerarquia'];
            System.assertEquals(false, oppUpdate.CIBE_ChiefOperationsOfficer__c);
        }
        Test.stopTest();
    }
    
}