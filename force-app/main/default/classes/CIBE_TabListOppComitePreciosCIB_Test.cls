/**********************************************************************************************************************
Name:	  CIBE_TabListOppComitePreciosCIB_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de cobertura para class CIBE_TabListOppComitePreciosCIBContr
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE			Description
	1.0			US52277         Ali 		    17/10/2023	    Init version
    1.1			US850814    	Lucía	  	    05/06/2024		Errores QC
    1.2			PPM100538662    Lucía	  	    22/10/2024		New methods getOptionsHierarchyTestm, getDocumentOppTest

***********************************************************************************************************************/

@isTest
public with sharing class CIBE_TabListOppComitePreciosCIB_Test {
    
    @TestSetup
    public static void setup() {
        string rtIdPickVal = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
        string rtIdPick = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
        string rtContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        string rtJerarquia = Schema.SObjectType.CIBE_Hierarchy__c.getRecordTypeInfosByDeveloperName().get('CIBE_Employee').getRecordTypeId();

        CIBE_TestInitialSetup.setupInitialDataCIB();
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        Contact contacto = [SELECT Id, av_usuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U0000001'];
        
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
            opp.CIBE_Visto__c = 'SI';
            opp.CIBE_Nivel__c = '';
            opp.CIBE_Sindicaciones__c = false;
            opp.CIBE_SyndicationTeamOpinion__c = 'NO';
            opp.CIBE_Observaciones__c = '';
            opp.CIBE_VigenciaOferta__c = null;
            opp.OwnerId = contacto.av_usuarioAsociado__c;
            opp.AV_FechaAlta__c = System.today() - 5;
            opp.AV_Gestor__c = contacto.Id;
            opp.CIBE_ApprovalType__c = 'Price comittee';
            insert opp;

            ContentVersion contentVersion = new ContentVersion(
            Title = 'a picture',
            PathOnClient = 'Pic.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
            insert contentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

			//create ContentDocumentLink record
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.LinkedEntityId = opp.Id;
			cdl.ContentDocumentId = documents[0].Id;
			cdl.ShareType = 'V';
			cdl.Visibility = 'AllUsers';
			insert cdl;




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
            CIBE_Hierarchy__c hier = [SELECT Id,CIBE_Negocios__c,CIBE_RedesSegmentos__c,CIBE_SectoresPaises__c,CIBE_CentrosCarteras__c,CIBE_Contact__c FROM CIBE_Hierarchy__c WHERE CIBE_Contact__r.AV_UsuarioAsociado__c = :usuario.Id LIMIT 1];
            List<CIBE_TabListOppComitePreciosCIBContr.OpportunityWrapper> wrapperList = CIBE_TabListOppComitePreciosCIBContr.getOpportunity(0, fecha, fechaDesde, fechaHasta,hier.CIBE_Negocios__c,hier.CIBE_RedesSegmentos__c,hier.CIBE_SectoresPaises__c,hier.CIBE_CentrosCarteras__c,0,100000, null, null, null);
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
            CIBE_Hierarchy__c hier = [SELECT Id,CIBE_Negocios__c,CIBE_RedesSegmentos__c,CIBE_SectoresPaises__c,CIBE_CentrosCarteras__c,CIBE_Contact__c FROM CIBE_Hierarchy__c WHERE CIBE_Contact__r.AV_UsuarioAsociado__c = :usuario.Id LIMIT 1];

            List<String> csv = CIBE_TabListOppComitePreciosCIBContr.exportOpportunities(fecha, fechaDesde, fechaHasta,hier.CIBE_Negocios__c,hier.CIBE_RedesSegmentos__c,hier.CIBE_SectoresPaises__c,hier.CIBE_CentrosCarteras__c,0,100000, null, null, null);

            System.assert(!csv.isEmpty());
        }
        Test.stopTest();
    }

    @isTest
	public static void getTipoAprobacionTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_TabListOppComitePreciosCIBContr.OptionsField> listValues = CIBE_TabListOppComitePreciosCIBContr.getTipoAprobacion();
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
	public static void getSectorTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_TabListOppComitePreciosCIBContr.OptionsField> listValues = CIBE_TabListOppComitePreciosCIBContr.getSector('Field Picklist', 'Opcion1');
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
	public static void getCarteraTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            Id sector = [SELECT Id FROM CBK_PicklistValues__c WHERE Name = 'Opcion1'].Id;
            List<CIBE_TabListOppComitePreciosCIBContr.OptionsField> listValues = CIBE_TabListOppComitePreciosCIBContr.getCartera(sector, 'Field Picklist');
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
	public static void getOptionsHierarchyTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_TabListOppComitePreciosCIBContr.OptionsField> listValues = CIBE_TabListOppComitePreciosCIBContr.getOptionsHierarchy();
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
	public static void getDocumentOppTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial'];
            List<CIBE_TabListOppComitePreciosCIBContr.DocumentsField> listValues = CIBE_TabListOppComitePreciosCIBContr.getDocumentOpp(opp.Id);
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

}