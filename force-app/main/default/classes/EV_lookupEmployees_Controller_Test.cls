/*********************************************************************************************************************
 Name:  EV_lookupEmployees_Controller_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para controlador EV_lookupEmployees_Controller, se encarga realizar una búsqueda de contactos.
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION        USER_STORY         AUTHOR              DATE         Description
 * 1.0            US680535           Carolina Lopez      24/08/2023   Init Version   
 * 1.1            US704873           Carolina Lopez      13/09/2023   Add Method testGetCentrosHierarchy
 * 1.2            ALTA_MASIVA        Carolina Lopez      17/01/2024   Modify TestSetup included CC_Matricula__c.
***********************************************************************************************************************/
@IsTest
public class EV_lookupEmployees_Controller_Test {
    
    @TestSetup
    static void setup(){
        Contact contacto = new Contact();
        Account cuenta = new Account();
        String nombre = '29698 - RISCOS_CDR RECUPERACIONS';
        List<Contact> result = new List<Contact>();
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser) {
            cuenta = EV_TestHelper.createCaixaCenterAltaMasiva(nombre);
            contacto = EV_TestHelper.createEmployee(cuenta);
            contacto.AV_JobLevels__c = '120';
            contacto.CC_Matricula__c = 'U0686956';
            contacto.AV_UsuarioAsociado__c = newUser.Id;
            update contacto;            
        }
    }

    @isTest
    static void testGetCentrosHierarchyDirect() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> lstDatos = new List<String>();
        List<Contact> lstContact = new List<Contact>();
        List<Account> lstAccount = new List<Account>();
        Test.startTest();
        System.runAs(newUser){
            Account cuenta = [Select id from Account where AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c = '001-09016' limit 1];
            Id [] fixedSearchResults= new Id[1];
       		fixedSearchResults[0] = cuenta.id;
       		Test.setFixedSearchResults(fixedSearchResults);
            lstAccount = EV_lookupEmployees_Controller.getCentrosHierarchy();
            for(Account xDato : lstAccount){
                lstDatos.add(xDato.id);
            }
            lstContact = EV_lookupEmployees_Controller.getDirectGestContactIds(lstDatos, true, false);
            System.assertEquals(1, lstContact.size());     
        }
        Test.stopTest();     
    }
    
    @isTest
    static void testSearchEmployees() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
 		List<Contact> result = new List<Contact>();
        Test.startTest();
        System.runAs(newUser){
            Contact cont = [Select id, Name, AV_JobLevels__c from contact WHERE AV_JobLevels__c = '120' limit 1];
            Id [] fixedSearchResults= new Id[1];
       		fixedSearchResults[0] = cont.id;
       		Test.setFixedSearchResults(fixedSearchResults);
        	result = EV_lookupEmployees_Controller.searchEmployees('Emp');
            System.assertEquals(1, result.size());     
        }
        Test.stopTest();     
    }

    @isTest
    static void testSearchNoResults() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<Contact> result = new List<Contact>();
        Test.startTest();
        System.runAs(newUser){
           result = EV_lookupEmployees_Controller.searchEmployees('n');
           System.assertEquals(null, result);
        }
        Test.stopTest();
    }
}