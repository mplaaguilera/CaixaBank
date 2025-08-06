/*********************************************************************************************************************
 Name:  EV_ImportMassEvent_Controller_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para controlador EV_ImportMassEvent_Controller, se encarga realizar una búsqueda de la campaña actual,
además se realiza la carga de las campañas (virtuales, fisicas o hibridas) y los centros objetivo vinculados.
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION        USER_STORY         AUTHOR              DATE         Description
 * 1.0            US680535           Carolina Lopez      24/08/2023   Init Version
 * 1.1            US704873           Carolina Lopez      10/10/2023   Modify saveRecords method call.
***********************************************************************************************************************/
@isTest 
public class EV_ImportMassEvent_Controller_Test { 
    @isTest
    static void testGetCampaign() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Campaign result = new Campaign();
        Campaign c = new Campaign();
        System.runAs(newUser){          
            Account cuenta = EV_TestHelper.createCaixaCenter();
            c = EV_TestHelper.createParentCampaignVirtual();
            EV_TestHelper.createTraslationEvt(c);
            EV_TestHelper.createCentroObjetivo(cuenta,c);
        }
        Test.startTest();
		System.runAs(newUser){
            result = EV_ImportMassEvent_Controller.getCampaign(c.Id);
        }
        Test.stopTest();
         System.assertEquals(c.Name, result.Name);
    }

    @isTest
    static void testSaveRecordsVirtual() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<Campaign> insertedCampaigns = new List<Campaign>();
        List<Contact> lstContact = new List<Contact>();
        Campaign c = new Campaign();
        System.runAs(newUser){
            Account cuenta = EV_TestHelper.createCaixaCenter();
            cuenta.BillingPostalCode = '28029';
            cuenta.BillingStreet = 'calle Madrid,23';            
            update cuenta;
            Contact contacto = EV_TestHelper.createEmployee(null);
            contacto.AV_UsuarioAsociado__c = newUser.Id;
            update contacto; 
            c = EV_TestHelper.createParentCampaignFisica();
            c.EV_Provincia__c = 'BARCELONA';
            c.EV_Cartera__c= 'BPA';
            c.EV_CentroAdminstrador__c = cuenta.Id;
			c.EV_CentroPromotor__c= cuenta.Id;           
            c.EV_AddressNumber__c = '45805';
			c.EV_HoraInicio__c = Time.newInstance(14, 30, 00, 00);
			c.EV_HoraFin__c = Time.newInstance(15, 30, 00, 00);
            update c;                               
            EV_TestHelper.createTraslationEvt(c);
            EV_TestHelper.createCentroObjetivo(cuenta,c);
            lstContact.add(contacto);
        }
        Test.startTest();
		System.runAs(newUser){
            List<Campaign> lstCamp = EV_ImportMassEvent_Controller.createCamp(lstContact, c, 2, 5, '009', 'prueba1');
            List<id> centros = EV_ImportMassEvent_Controller.centros(c);
            EV_ImportMassEvent_Controller.saveRecords(lstCamp, centros, c);
            insertedCampaigns = [SELECT Id, Name FROM Campaign WHERE ParentId =:c.Id];
            EV_ImportMassEvent_Controller.mtBatchAltaMasiva();
        }
        Test.stopTest();
        System.assertEquals(2, insertedCampaigns.size(), 'Correcto');
    }

    @isTest
    static void testSaveRecordsFisico() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<Campaign> insertedCampaigns = new List<Campaign>();
        List<Contact> lstContact = new List<Contact>();
        Campaign c = new Campaign();
        System.runAs(newUser){
            Account cuenta = EV_TestHelper.createCaixaCenter();
            cuenta.BillingPostalCode = '28029';
            cuenta.BillingStreet = 'calle Madrid,23';            
            update cuenta;
            Contact contacto = EV_TestHelper.createEmployee(null);
            contacto.AV_UsuarioAsociado__c = newUser.Id;
            update contacto; 
            c = EV_TestHelper.createParentCampaignFisica();
            c.EV_Provincia__c = 'BARCELONA';
            c.EV_Cartera__c= 'BPA';
            c.EV_CentroAdminstrador__c = cuenta.Id;
			c.EV_CentroPromotor__c= cuenta.Id;           
            c.EV_AddressNumber__c = '45865';
			c.EV_HoraInicio__c = Time.newInstance(14, 30, 00, 00);
			c.EV_HoraFin__c = Time.newInstance(15, 30, 00, 00);
            update c;                               
            EV_TestHelper.createTraslationEvt(c);
            EV_TestHelper.createCentroObjetivo(cuenta,c);
            lstContact.add(contacto);
        }
        Test.startTest();
		System.runAs(newUser){
            List<Campaign> lstCamp = EV_ImportMassEvent_Controller.createCamp(lstContact, c, 2, 5, '009', 'prueba2');
            List<id> centros = EV_ImportMassEvent_Controller.centros(c);
            EV_ImportMassEvent_Controller.saveRecords(lstCamp, centros, c);
            insertedCampaigns = [SELECT Id, Name FROM Campaign WHERE ParentId =:c.Id];
        }
        Test.stopTest();
        System.assertEquals(2, insertedCampaigns.size(), 'Correcto');
    }   
    
    @isTest
    static void testSaveRecordsHibrido() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<Campaign> insertedCampaigns = new List<Campaign>();
        List<Contact> lstContact = new List<Contact>();
        Campaign c = new Campaign();
        System.runAs(newUser){
            Account cuenta = EV_TestHelper.createCaixaCenter();
            Contact contacto = EV_TestHelper.createEmployee(cuenta);
            contacto.AV_UsuarioAsociado__c = newUser.Id;
            update contacto;
            c = EV_TestHelper.createParentCampaignHibrido();
            c.EV_CentroAdminstrador__c = cuenta.Id;
			c.EV_CentroPromotor__c= cuenta.Id;
            c.Status = '009';
            update c;
            EV_TestHelper.createTraslationEvt(c);
            EV_TestHelper.createCentroObjetivo(cuenta,c);
            lstContact.add(contacto);
        }
        Test.startTest();
		System.runAs(newUser){
        	List<Campaign> lstCamp = EV_ImportMassEvent_Controller.createCamp(lstContact, c, 2, 5, '009', 'Prueba3');
            List<id> centros = EV_ImportMassEvent_Controller.centros(c);
            EV_ImportMassEvent_Controller.saveRecords(lstCamp, centros, c);
            insertedCampaigns = [SELECT Id, Name FROM Campaign WHERE ParentId =:c.Id];
        }
        Test.stopTest();
        System.assertEquals(2, insertedCampaigns.size(), 'Correcto');

    }
    
    @isTest (SeeAllData=true)
    static void testGetTraducciones() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Boolean check = false;
        Campaign c = new Campaign();
        System.runAs(newUser){
            List<Contact> lstContact = new List<Contact>();
            Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
            Account cuenta = EV_TestHelper.createCaixaCenter();
            Contact contacto = EV_TestHelper.createEmployee(cuenta);
            contacto.AV_UsuarioAsociado__c = newUser.Id;
            update contacto;
            c = EV_TestHelper.createParentCampaignHibrido();
            c.EV_CentroAdminstrador__c = cuenta.Id;
			c.EV_CentroPromotor__c= cuenta.Id;
            c.EV_Encuesta__c = surv.Id;
            update c;
            EV_TestHelper.createTraslationEvt(c);
            EV_TestHelper.createCentroObjetivo(cuenta,c);
            lstContact.add(contacto);
        }
        Test.startTest();
		System.runAs(newUser){
        	check = EV_ImportMassEvent_Controller.getTraducciones(c.id);
        }
        Test.stopTest();
        System.assertEquals(true, check, 'Correcto');
    }
    
    @isTest
    static void testGetTraduccionesError() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Boolean check = false;
        Campaign c = new Campaign();
        System.runAs(newUser){
            List<Contact> lstContact = new List<Contact>();
            Account cuenta = EV_TestHelper.createCaixaCenter();
            Contact contacto = EV_TestHelper.createEmployee(cuenta);
            contacto.AV_UsuarioAsociado__c = newUser.Id;
            update contacto;
            c = EV_TestHelper.createParentCampaignHibrido();
            c.EV_CentroAdminstrador__c = cuenta.Id;
			c.EV_CentroPromotor__c= cuenta.Id;
            update c;
            EV_TestHelper.createTraslationEvt(c);
            EV_TestHelper.createCentroObjetivo(cuenta,c);
            lstContact.add(contacto);
        }
        Test.startTest();
		System.runAs(newUser){
        	check = EV_ImportMassEvent_Controller.getTraducciones(c.id);
        }
        Test.stopTest();
        System.assertEquals(false, check, 'Error');
    }
}