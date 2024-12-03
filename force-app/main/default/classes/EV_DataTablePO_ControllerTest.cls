@isTest
public with sharing class EV_DataTablePO_ControllerTest {
    @TestSetup
	static void makeData(){
        User user = EV_TestHelper.createUser('EV_Eventos');
        List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
        Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
        for(EV_MappingCriterioPO__mdt mc: listMC){
            mapMC.put(mc.label, mc);
        }
        EV_TestHelper.createCaixaCenter();
		Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
        List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
        List<EV_CriterioPublicoObjetivo__c> poTest = EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
        EV_CriterioPublicoObjetivoAdobeCampaign__c poAdobeTest = EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
        EV_CustomOptions__c customOptions = EV_TestHelper.createCustomOptions();
	}

    @isTest
	public static void getRecordsPOTest() {
        //Set<String> setFieldsCampaign = new Set<String>{'Id'};
        List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];

        //Set<String> setFieldsPO = new Set<String>{'Id', 'EV_EditableValorCriterio__c', 'EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c', 'EV_VariablePublicoObjetivo__c','EV_Activo__c', 'EV_VariablePublicoObjetivo__r.Name', 'EV_TipoCriterio__c', 'EV_ValorCriterio__c'};
        List<EV_CriterioPublicoObjetivo__c> listPO = [SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                        EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                        FROM EV_CriterioPublicoObjetivo__c LIMIT 1];
        

        Test.startTest();
        EV_DataTablePO_Controller.getRecordsPO(listCampaign[0].Id);
        Test.stopTest();
    }

    @isTest
	public static void getRecordsPOActiveTest() {
        //Set<String> setFieldsCampaign = new Set<String>{'Id'};
        List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];

        //Set<String> setFieldsPO = new Set<String>{'Id', 'EV_EditableValorCriterio__c', 'EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c', 'EV_VariablePublicoObjetivo__c','EV_Activo__c', 'EV_VariablePublicoObjetivo__r.Name', 'EV_TipoCriterio__c', 'EV_ValorCriterio__c'};
        List<EV_CriterioPublicoObjetivo__c> listPO = [SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                        EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                        FROM EV_CriterioPublicoObjetivo__c LIMIT 1];

        Test.startTest();
        EV_DataTablePO_Controller.getRecordsPOActive(listCampaign[0].Id);
        Test.stopTest();
    }

    @isTest
	public static void updateRecordsPOTest() {
        //Set<String> setFieldsPO = new Set<String>{'Id', 'EV_EditableValorCriterio__c', 'EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c', 'EV_VariablePublicoObjetivo__c','EV_Activo__c', 'EV_VariablePublicoObjetivo__r.Name', 'EV_TipoCriterio__c', 'EV_ValorCriterio__c'};
        List<EV_CriterioPublicoObjetivo__c> listPO =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                        EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                        FROM EV_CriterioPublicoObjetivo__c LIMIT 1];
        List<String> isValuesMultipicklist = new List<String>{'1', '2'};
        List<String> isLabelsMultipicklist = new List<String>{'Catalán', 'Castellano'};

        Test.startTest();
        EV_DataTablePO_Controller.updateRecordsPO(listPO[0].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,false);
        Test.stopTest();
    
    }
    
     @isTest
	public static void updateRecordsPOChildTest() {
        //Set<String> setFieldsPO = new Set<String>{'Id', 'EV_EditableValorCriterio__c', 'EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c', 'EV_VariablePublicoObjetivo__c','EV_Activo__c', 'EV_VariablePublicoObjetivo__r.Name', 'EV_TipoCriterio__c', 'EV_ValorCriterio__c'};
        List<EV_CriterioPublicoObjetivo__c> listPO =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                        EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                        FROM EV_CriterioPublicoObjetivo__c LIMIT 1];
        List<String> isValuesMultipicklist = new List<String>{'1', '2'};
        List<String> isLabelsMultipicklist = new List<String>{'Catalán', 'Castellano'};

        Test.startTest();
        EV_DataTablePO_Controller.updateRecordsPO(listPO[0].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,true);
        Test.stopTest();
        List<EV_CriterioPublicoObjetivo__c> listPO2 =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                        EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                        FROM EV_CriterioPublicoObjetivo__c LIMIT 1];
        system.assertEquals(listPO2.size(), 1);
    
    }
     @isTest
	public static void updateRecordsPOChild2Test() {
        List<EV_CriterioPublicoObjetivo__c> listPO =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                        EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                        FROM EV_CriterioPublicoObjetivo__c LIMIT 10];
        List<String> isValuesMultipicklist = new List<String>{'1', '2'};
        List<String> isLabelsMultipicklist = new List<String>{'Catalán', 'Castellano'};

        Test.startTest();
        EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Obligatorio', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,true);
        EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,true);
        EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, true, false, false,true);
        EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, false, true,true);
        EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,false);
        EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, true, false, false,false);
        EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, false, true,false);
        Test.stopTest();
        List<EV_CriterioPublicoObjetivo__c> listPO2 =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                        EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                        FROM EV_CriterioPublicoObjetivo__c LIMIT 1];
        system.assertEquals(listPO2.size(), 1);
    
    }
    
    @isTest
	public static void testGetCentroPromotor() {
        List<Campaign> listC =[SELECT Id, EV_CentroPromotor__c from campaign limit 1];
		List<Account> ac =  [SELECT Id, Name, CC_Numero_Oficina__c FROM Account limit 1];
        listC[0].EV_CentroPromotor__c = ac[0].id;
        update listC;
        Test.startTest();
        EV_DataTablePO_Controller.getCentroPromotor(listC[0].id);
        Test.stopTest();
      	List<Campaign> listC2 =[SELECT Id from campaign limit 1];
        system.assertEquals(listC2.size(), 1);
    
    }

    @isTest
    public static void callAPIVolumenPOTest(){
        Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        
        Map<String, EV_MappingCriterioPO__mdt> mapPO = new Map<String, EV_MappingCriterioPO__mdt>();

        //Set<String> setFieldsCampaign = new Set<String>{'Id', 'EV_EstadoVolumenPublicoObjetivo__c'};
        List<Campaign> listCampaign = [SELECT Id, EV_EstadoVolumenPublicoObjetivo__c FROM Campaign LIMIT 1];

        //Set<String> setFieldsVariableAdobe = new Set<String>{'Id', 'Name', 'EV_VariableAdobeCampaign__c'};
        List<EV_VariablePublicoOjetivo__c> listVariableAdobe = [SELECT Id, Name, EV_VariableAdobeCampaign__c FROM EV_VariablePublicoOjetivo__c LIMIT 1 ];

        //Set<String> setFieldsPOAdobe = new Set<String>{'Id', 'EV_EditableValorCriterio__c', 'EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c', 'EV_VariablePublicoObjetivo__c','EV_Activo__c', 'EV_VariablePublicoObjetivo__r.Name', 'EV_TipoCriterio__c', 'EV_ValorCriterio__c'};
        List<EV_CriterioPublicoObjetivo__c> listPOAdobe =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, 
                                                            EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c 
                                                            FROM EV_CriterioPublicoObjetivo__c LIMIT 1];

        //Set<String> setFieldsMapPO = new Set<String>{'Label', 'EV_FieldName__c'};
        List<EV_MappingCriterioPO__mdt> listMapCriterioPO = [SELECT Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt LIMIT 1];

        for(EV_MappingCriterioPO__mdt mCriterioPO: listMapCriterioPO){
            mapPO.put(mCriterioPO.Label, mCriterioPO);
        }

        Test.startTest();
        EV_DataTablePO_Controller.callAPIVolumenPO(listCampaign[0].Id);
        Test.stopTest();
    }
    
  

    @isTest
    public static void callAPIConfirmationPOTest(){
        Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
        //Set<String> setFieldsCampaign = new Set<String>{'Id'};
        List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];

        Test.startTest();
        EV_DataTablePO_Controller.callAPIConfirmationPO(listCampaign[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void retrieveStatusPOCampaign(){
        //Set<String> setFieldsCampaign = new Set<String>{'Id', 'EV_EstadoVolumenPublicoObjetivo__c'};
        List<Campaign> listCampaign = [SELECT Id, EV_EstadoVolumenPublicoObjetivo__c FROM Campaign LIMIT 1];

        Test.startTest();
        EV_DataTablePO_Controller.retrieveStatusPOCampaign(listCampaign[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void getTypeOfEventTest(){
        //Set<String> setFieldsCampaign = new Set<String>{'Id', 'RecordType.Name'};
        List<Campaign> listCampaign =[SELECT Id, RecordType.Name FROM Campaign LIMIT 1];

        Test.startTest();
        EV_DataTablePO_Controller.getTypeOfEvent(listCampaign[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void searchLookupTest(){
        Test.startTest();
        EV_DataTablePO_Controller.searchLookup('Account', 'Name', 'Name', 'Empresa 1');
        Test.stopTest();
    }

    @isTest
    public static void getPicklistValuesTest(){
        //Set<String> setFieldsCustomOptions = new Set<String>{'Name', 'EV_PicklistName__c', 'EV_Value__c'};
        List<EV_CustomOptions__c> listCustomOptions = [SELECT Name, EV_PicklistName__c, EV_Value__c FROM EV_CustomOptions__c LIMIT 1];

        Test.startTest();
        EV_DataTablePO_Controller.getPicklistValues();
        Test.stopTest();
    }
    @isTest
    public static void getParentCampaign(){
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1]; 
        List<Campaign> listCampaign = new List<Campaign>();
        System.runAs(user){
        listCampaign =[SELECT Id, RecordType.Name FROM Campaign LIMIT 1];

        Test.startTest();
        	EV_DataTablePO_Controller.getParent(listCampaign[0].Id);
        Test.stopTest();
        }
        system.assertEquals(listCampaign.size(), 1);
    }
    
    @isTest
    public static void callAPIVolumenPO2Test(){
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1]; 
        List<Campaign> listCampaign = new List<Campaign>();
        EV_TestHelper.createChildCampaignVirtual();
        System.runAs(user){
        Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());

        Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
        listCampaign = [SELECT Id, EV_EstadoVolumenPublicoObjetivo__c FROM Campaign where recordtypeid = :rtEvento LIMIT 1];
        List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt];
        Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
        for(EV_MappingCriterioPO__mdt mc: listMC){
            mapMC.put(mc.label, mc);
        }
       
        List<EV_VariablePublicoOjetivo__c> listVariablePO = new List<EV_VariablePublicoOjetivo__c>();
		for(EV_MappingCriterioPO__mdt wrapper: mapMC.values()) {
			EV_VariablePublicoOjetivo__c variablePO = new EV_VariablePublicoOjetivo__c();
			variablePO.Name = wrapper.Label;
			variablePO.EV_CategoriaVariable__c = 'Intereses';
			variablePO.EV_TipoVariable__c = 'Boolean';
			variablePO.EV_VariableAdobeCampaign__c = wrapper.Label;
			listVariablePO.add(variablePO);
		}
		insert listVariablePO;
		List<EV_CriterioPublicoObjetivo__c> lstCriterioPublicoObjetivo = new List<EV_CriterioPublicoObjetivo__c>();
		for(EV_VariablePublicoOjetivo__c varPO: listVariablePO){
			EV_CriterioPublicoObjetivo__c criterioPO = new EV_CriterioPublicoObjetivo__c();

			criterioPO.EV_Evento__c = listCampaign[0].Id;
			criterioPO.EV_Activo__c = true;
			
			criterioPO.EV_VariablePublicoObjetivo__c = varPO.Id;
			lstCriterioPublicoObjetivo.add(criterioPO);
		}
		
		insert lstCriterioPublicoObjetivo;

        
        Test.startTest();
        	EV_DataTablePO_Controller.callAPIVolumenPO(listCampaign[0].Id);
        Test.stopTest();
        }
        
        system.assertEquals(listCampaign.size(), 1);
    }
}