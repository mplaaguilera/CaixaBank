/**********************************************************************************************************************
 Name:	  EV_DataTablePO_ControllerTest
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description Clase de test para el datatable de Publico objetivo.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR								DATE				Description
	1.0			US785364            Carolina Lopez   				    21/12/2023 			Modify all the logic of the methods, remove testSetup, include runAs, seealldata.
    1.1         Fix                 Carolina Lopez                      21/05/2024          Create getTypeOfEventTestTechSummit and modify methods to remove additional permission in callAPIConfirmationPOTest, callAPIVolumenPO2Test.
***********************************************************************************************************************/
@isTest
public with sharing class EV_DataTablePO_ControllerTest {
    @isTest
	public static void getRecordsPOTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<EV_DataTablePO_Controller.DataPO> lstPO = new List<EV_DataTablePO_Controller.DataPO>();

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            List<EV_CriterioPublicoObjetivo__c> poTest = EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_CriterioPublicoObjetivoAdobeCampaign__c poAdobeTest = EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_CustomOptions__c customOptions = EV_TestHelper.createCustomOptions();

            List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
            lstPO = EV_DataTablePO_Controller.getRecordsPO(listCampaign[0].Id);
        }
        System.assert(lstPO != null, 'Cantidad PO.');
        Test.stopTest();
    }

    @isTest
	public static void getRecordsPOActiveTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<EV_DataTablePO_Controller.DataPO> lstPO = new List<EV_DataTablePO_Controller.DataPO>();

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
            lstPO = EV_DataTablePO_Controller.getRecordsPOActive(listCampaign[0].Id);
        }
        System.assert(lstPO != null, 'Cantidad PO ACTIVO.');
        Test.stopTest();
    }

    @isTest
	public static void updateRecordsPOTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<EV_CriterioPublicoObjetivo__c> lstCP = new List<EV_CriterioPublicoObjetivo__c>();

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<EV_CriterioPublicoObjetivo__c> listPO =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c FROM EV_CriterioPublicoObjetivo__c LIMIT 1];
            List<String> isValuesMultipicklist = new List<String>{'1', '2'};
            List<String> isLabelsMultipicklist = new List<String>{'Catalán', 'Castellano'};

            EV_DataTablePO_Controller.updateRecordsPO(listPO[0].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,false);
 
            lstCP =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c FROM EV_CriterioPublicoObjetivo__c where id =:listPO[0].Id AND  EV_ValorCriterio__c = '1' LIMIT 1];
        }
        System.assert(lstCP != null, 'UPDATE PO.');
        Test.stopTest();
    }
    
    @isTest
	public static void updateRecordsPOChildTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<EV_CriterioPublicoObjetivo__c> lstCP = new List<EV_CriterioPublicoObjetivo__c>();

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<EV_CriterioPublicoObjetivo__c> listPO =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c FROM EV_CriterioPublicoObjetivo__c LIMIT 1];
            List<String> isValuesMultipicklist = new List<String>{'1', '2'};
            List<String> isLabelsMultipicklist = new List<String>{'Catalán', 'Castellano'};

            EV_DataTablePO_Controller.updateRecordsPO(listPO[0].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,true);
 
            lstCP =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c FROM EV_CriterioPublicoObjetivo__c where id =:listPO[0].Id AND  EV_ValorCriterio__c = '1' LIMIT 1];
        }
        System.assert(lstCP != null, 'UPDATE POChild.');
        Test.stopTest();
    }

     @isTest
	public static void updateRecordsPOChild2Test() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<EV_CriterioPublicoObjetivo__c> lstCP = new List<EV_CriterioPublicoObjetivo__c>();

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<EV_CriterioPublicoObjetivo__c> listPO =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c FROM EV_CriterioPublicoObjetivo__c LIMIT 10];
            List<String> isValuesMultipicklist = new List<String>{'1', '2'};
            List<String> isLabelsMultipicklist = new List<String>{'Catalán', 'Castellano'};

            EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Obligatorio', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,true);
            EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,true);
            EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, true, false, false,true);
            EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, false, true,true);
            EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, true, false,false);
            EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, true, false, false,false);
            EV_DataTablePO_Controller.updateRecordsPO(listPO[3].Id, true, 'Opcional', '1', '1', 'Masculino', isValuesMultipicklist, isLabelsMultipicklist, false, false, true,false);

            lstCP =[SELECT Id, EV_EditableValorCriterio__c, EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c, EV_VariablePublicoObjetivo__c,EV_Activo__c, EV_VariablePublicoObjetivo__r.Name, EV_TipoCriterio__c, EV_ValorCriterio__c FROM EV_CriterioPublicoObjetivo__c where id =:listPO[0].Id AND  EV_ValorCriterio__c = '1' LIMIT 1];
        }
        System.assert(lstCP != null, 'UPDATE POChild2.');
        Test.stopTest();
    }
    
    @isTest
	public static void testGetCentroPromotor() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<Campaign> listC2 = new List<Campaign>();

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            EV_TestHelper.createCaixaCenter();
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<Campaign> listC =[SELECT Id, EV_CentroPromotor__c from campaign limit 1];
            List<Account> ac =  [SELECT Id, Name, CC_Numero_Oficina__c FROM Account limit 1];
            listC[0].EV_CentroPromotor__c = ac[0].id;
            update listC;

            EV_DataTablePO_Controller.getCentroPromotor(listC[0].id);
            listC2 =[SELECT Id from campaign where EV_CentroPromotor__c =: ac[0].id limit 1];
        }
        System.assert(listC2 != null, 'Centro promotor Update.');
        Test.stopTest();
    }

    @isTest (SeeAllData=true)
    public static void callAPIConfirmationPOTest(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        String retorno;

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            Test.setMock(HttpCalloutMock.class, new EV_ConnectApi_Mock(200));
            List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 1];
            retorno = EV_DataTablePO_Controller.callAPIConfirmationPO(listCampaign[0].Id);
        }
        System.assert(retorno == 'OK', 'Confirmación en la llamada.');
        Test.stopTest();
    }

    @isTest
    public static void retrieveStatusPOCampaign(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        String retorno;

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            campTest.EV_EstadoVolumenPublicoObjetivo__c = '002';
            update campTest;
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<Campaign> listCampaign = [SELECT Id, EV_EstadoVolumenPublicoObjetivo__c FROM Campaign LIMIT 1];
            retorno = EV_DataTablePO_Controller.retrieveStatusPOCampaign(listCampaign[0].Id);
        }
        System.assert(retorno != null, 'Retorno de estadoPO.');
        Test.stopTest();
    }

    @isTest
    public static void getTypeOfEventTest(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        boolean retorno;

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createParentCampaignVirtual();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<Campaign> listCampaign =[SELECT Id, RecordType.Name FROM Campaign LIMIT 1];
            retorno = EV_DataTablePO_Controller.getTypeOfEvent(listCampaign[0].Id);
        }
        System.assert(retorno == false, 'Generado Catálogo Virtual.');
        Test.stopTest();
    }

    @isTest
    public static void getTypeOfEventTestTechSummit(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        boolean retorno;

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            Campaign campTest = EV_TestHelper.createChildCampaignVirtualCMCustomTechSummit();
            List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
            EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
            EV_TestHelper.createCriterioPOAdobeCampaign(campTest.Id);
            EV_TestHelper.createCustomOptions();

            List<Campaign> listCampaign =[SELECT Id, RecordType.Name FROM Campaign LIMIT 1];
            retorno = EV_DataTablePO_Controller.getTypeOfEvent(listCampaign[0].Id);
        }
        System.assert(retorno == true, 'Generado Virtual TechSummit.');
        Test.stopTest();
    }

    @isTest
    public static void searchLookupTest(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<EV_DataTablePO_Controller.SObjectQueryResult> lstReturnResult = new List<EV_DataTablePO_Controller.SObjectQueryResult>();

        System.runAs(newUser){  
            EV_TestHelper.createCaixaCenter();
            lstReturnResult = EV_DataTablePO_Controller.searchLookup('Account', 'Name', 'Name', 'Empresa 1');
        }
        System.assert(lstReturnResult != null, 'Encontrado centro Caixabank.');
        Test.stopTest();
    }

    @isTest
    public static void getPicklistValuesTest(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        List<EV_CustomOptions__c> lstCOPT = new List<EV_CustomOptions__c>();

        System.runAs(newUser){  
            EV_TestHelper.createCustomOptions();
            List<EV_CustomOptions__c> listCustomOptions = [SELECT Name, EV_PicklistName__c, EV_Value__c FROM EV_CustomOptions__c LIMIT 1];
            lstCOPT = EV_DataTablePO_Controller.getPicklistValues();
        }
        System.assert(lstCOPT != null, 'Custom Options.');
        Test.stopTest();
    }
    @isTest
    public static void getParentCampaign(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        boolean retorno;

        System.runAs(newUser){  
            EV_TestHelper.createParentCampaignVirtual();
            List<Campaign> listCampaign = [SELECT Id, RecordType.Name FROM Campaign LIMIT 1];
        	retorno = EV_DataTablePO_Controller.getParent(listCampaign[0].Id);
        }
        System.assert(retorno == false, 'Generado  sin ParentCampaign.');
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void callAPIVolumenPO2Test(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest(); 
        String retorno;

        System.runAs(newUser){  
            List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt ORDER BY Label DESC];
            Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
            for(EV_MappingCriterioPO__mdt mc: listMC){
                mapMC.put(mc.label, mc);
            }
            EV_TestHelper.createParentCampaignVirtual();
            List<Campaign> listCampaign = [SELECT Id, EV_EstadoVolumenPublicoObjetivo__c FROM Campaign LIMIT 1];
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

            Test.setMock(HttpCalloutMock.class, new EV_ConnectApi_Mock(200));
            retorno = EV_DataTablePO_Controller.callAPIVolumenPO(listCampaign[0].Id);
        }
        System.assert(retorno != null, 'callAPI PO2.');
        Test.stopTest();
    }
}