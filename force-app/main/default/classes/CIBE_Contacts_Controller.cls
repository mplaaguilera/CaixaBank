/*
Name:	  CIBE_Contacts_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for cibe_Contactos
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0                         Alex Campos         27/10/2022      Init Version
    1.1         US645471        Bea                 4/07/2023       Added method hasPermission
*/
public with sharing class CIBE_Contacts_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> getRecords(String recordId) {
        List<Contact> contacts = new List<Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible()) {
            contacts = [SELECT Id, FirstName, LastName, CIBE_Cargo__c, toLabel(CC_Idioma__c), Email, Phone, Fax, Description, 
                        CIBE_Confidencial__c, CIBE_ContactoInfoComercial__c, RecordType.DeveloperName, CIBE_Carrec__c, CIBE_FechaVencimiento__c 
                        FROM Contact WHERE AccountId = :recordId AND RecordType.DeveloperName IN  ('CIBE_ContactoComercial','CIBE_Apoderado')];
        }
    
        List<Wrapper> listReturn = new List<Wrapper>();
        List<Wrapper> listReturnAux = new List<Wrapper>();
        if(!contacts.isEmpty()) {
            Map<String, List<Wrapper>> mapOrderContact = new Map<String, List<Wrapper>>();

            for(Contact c : contacts) {
                Wrapper wrap = new Wrapper();
                wrap.id = c.Id;
                wrap.name = String.isNotBlank(c.FirstName) || String.isNotBlank(c.LastName) ? c.FirstName + ' ' + c.LastName : ' ';
                wrap.rol = c.CIBE_Cargo__c; 
                wrap.language = c.CC_Idioma__c;
                wrap.email = c.Email;
                wrap.phone = c.Phone;
                wrap.fax = c.Fax;
                wrap.description = c.Description;
                wrap.showContactRecord = '/' + c.Id;
                wrap.apoderado = c.RecordType.DeveloperName == 'CIBE_Apoderado' && c.CIBE_Carrec__c != '00016' && (c.CIBE_FechaVencimiento__c >= System.today() || c.CIBE_FechaVencimiento__c == null);
                //wrap.confidencial = c.CIBE_Confidencial__c;
                //wrap.contactoInfoComercial = c.CIBE_ContactoInfoComercial__c;
                wrap.cargadoManualmente = c.RecordType.DeveloperName == 'CIBE_ContactoComercial';

                listReturn.add(wrap);
                listReturn.sort();
            }
        }

        return listReturn;
    }

    @AuraEnabled(cacheable = true) 
    public static String getRecordType() {
        return Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();
    }
    
    public class Wrapper implements Comparable{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        // @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public String rol {get;set;}
        @AuraEnabled public String language {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String phone {get;set;}
        @AuraEnabled public String fax {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String showContactRecord {get;set;}
        //@AuraEnabled public Boolean confidencial {get;set;}
        //@AuraEnabled public Boolean contactoInfoComercial{get;set;}
        @AuraEnabled public Boolean apoderado{get;set;}
        @AuraEnabled public Boolean cargadoManualmente{get;set;}

        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            
            // Cast argument to OpportunityWrapper
            Wrapper other = (Wrapper)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            
            if (this.name > other.name) {
                returnValue = 1;
            } else if (this.name < other.name) {
                returnValue = -1;
            } else if ((this.name == null) && (other.name != null)){
                returnValue = -1;
            } else if ((this.name != null) && (other.name == null)){
                returnValue = 1;
            }

            return returnValue;       
        }
    }

    @AuraEnabled(cacheable = true) 
    public static boolean hasPermission() {
        List<User> users = new List<User>();
        if(User.SObjectType.getDescribe().isAccessible()) {
            users = [SELECT Id, AV_TipoGestor__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        }

        if (!users.isEmpty()) {
            List<PermissionSetAssignment> psa = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'CIBE_OperativaEMP' LIMIT 1];   
            
            if (!psa.isEmpty()) {
                return (users[0].AV_TipoGestor__c == 'Tec. Ges. Act.' && psa[0].PermissionSet.Name == 'CIBE_OperativaEMP');
            }
                
        }
        return false;
    }

}