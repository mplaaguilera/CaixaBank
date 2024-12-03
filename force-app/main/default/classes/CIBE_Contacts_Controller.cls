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
    1.2			US606366		Lucía Muñoz 		06/11/2023	    Add method of test getDuplicado, contactosDuplicados, insertContact, insertAccounContactRelation

*/
public with sharing class CIBE_Contacts_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> getRecords(String recordId) {
        List<Wrapper> listReturn = new List<Wrapper>();
        List<Wrapper> listReturnAux = new List<Wrapper>();
        if( Schema.SObjectType.AccountContactRelation.fields.AccountId.isAccessible() &&
            Schema.SObjectType.AccountContactRelation.fields.ContactId.isAccessible()) {

            List<AccountContactRelation > contacts = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.CIBE_Cargo__c, toLabel(Contact.CC_Idioma__c), Contact.Email, Contact.Phone, Contact.Fax, Contact.Description, 
                        Contact.CIBE_Confidencial__c, Contact.CIBE_ContactoInfoComercial__c, Contact.RecordType.DeveloperName, Contact.CIBE_Carrec__c, Contact.CIBE_FechaVencimiento__c, Contact.AccountId
                        FROM AccountContactRelation WHERE AccountId = :recordId AND Contact.RecordType.DeveloperName IN  ('CIBE_ContactoComercial','CIBE_Apoderado')];

            if(!contacts.isEmpty()) {
                Map<String, List<Wrapper>> mapOrderContact = new Map<String, List<Wrapper>>();

                for(AccountContactRelation c : contacts) {
                    Wrapper wrap = new Wrapper();
                    wrap.id = c.Contact.Id;
                    if(String.isNotBlank(c.Contact.FirstName) && String.isNotBlank(c.Contact.LastName)){
                        wrap.name =  c.Contact.FirstName + ' ' + c.Contact.LastName;
                    }else if(String.isBlank(c.Contact.FirstName) && String.isNotBlank(c.Contact.LastName)){
                        wrap.name =  ' ' + c.Contact.LastName;
                    }
                    //String.isNotBlank(c.Contact.FirstName) && String.isNotBlank(c.Contact.LastName)  ? c.Contact.FirstName + ' ' + c.Contact.LastName : ' ';
                    wrap.rol = c.Contact.CIBE_Cargo__c; 
                    wrap.language = c.Contact.CC_Idioma__c;
                    wrap.email = c.Contact.Email;
                    wrap.phone = c.Contact.Phone;
                    wrap.fax = c.Contact.Fax;
                    wrap.description = c.Contact.Description;
                    wrap.showContactRecord = '/' + c.Contact.Id;
                    wrap.apoderado = c.Contact.RecordType.DeveloperName == 'CIBE_Apoderado' && c.Contact.CIBE_Carrec__c != '00016' && (c.Contact.CIBE_FechaVencimiento__c >= System.today() || c.Contact.CIBE_FechaVencimiento__c == null) && c.Contact.AccountId == recordId ;
                    //wrap.confidencial = c.CIBE_Confidencial__c;
                    //wrap.contactoInfoComercial = c.CIBE_ContactoInfoComercial__c;
                    wrap.cargadoManualmente = c.Contact.RecordType.DeveloperName == 'CIBE_ContactoComercial';

                    listReturn.add(wrap);
                    listReturn.sort();
                }
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
        List<User> users  = [SELECT Id, AV_TipoGestor__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        if (!users.isEmpty()) {
            List<PermissionSetAssignment> psa = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'CIBE_OperativaEMP' LIMIT 1];   
            
            if (!psa.isEmpty()) {
                return (users[0].AV_TipoGestor__c == 'Tec. Ges. Act.' && psa[0].PermissionSet.Name == 'CIBE_OperativaEMP');
            }
                
        }
        return false;
    }

    @AuraEnabled
    public static Boolean getDuplicado(String email, String telefono){

        Boolean esDuplicado = false;
        List<Contact> contactos =  new List<Contact>();
        
        if(telefono == null || telefono == ''){
            contactos  = [SELECT Id, Name, Email, Phone, CIBE_Cargo__c
            FROM Contact 
            WHERE (RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT OR RecordType.DeveloperName = : CIBE_AppConstants.CONTACT_APODERADO_RT) AND (Email = :email)];
        }else if(email == null || email == ''){
            contactos  = [SELECT Id, Name, Email, Phone, CIBE_Cargo__c
            FROM Contact 
            WHERE (RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT OR RecordType.DeveloperName = : CIBE_AppConstants.CONTACT_APODERADO_RT) AND (Phone = :telefono)];
        }else if(telefono != '' && email != ''){
            contactos  = [SELECT Id, Name, Email, Phone, CIBE_Cargo__c
                        FROM Contact 
                        WHERE (RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT OR RecordType.DeveloperName = : CIBE_AppConstants.CONTACT_APODERADO_RT) AND (Email = :email OR Phone = :telefono)];
        }
        if(!contactos.isEmpty()){
            esDuplicado = true;
        }    

        return esDuplicado;
    }

    @AuraEnabled
    public static List<Contact> contactosDuplicados(String email, String telefono){
        List<Contact> cDuplicado =  new List<Contact>();
        
        if(telefono == null || telefono == ''){
            cDuplicado  = [SELECT Id, Name, Email, Phone, CIBE_Cargo__c
            FROM Contact 
            WHERE (RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT OR RecordType.DeveloperName = : CIBE_AppConstants.CONTACT_APODERADO_RT) AND (Email = :email)];
        }else if(email == null || email == ''){
            cDuplicado  = [SELECT Id, Name, Email, Phone, CIBE_Cargo__c
            FROM Contact 
            WHERE (RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT OR RecordType.DeveloperName = : CIBE_AppConstants.CONTACT_APODERADO_RT) AND (Phone = :telefono)];
        }else if(telefono != '' && email != ''){
            cDuplicado  = [SELECT Id, Name, Email, Phone, CIBE_Cargo__c
                        FROM Contact 
                        WHERE (RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT OR RecordType.DeveloperName = : CIBE_AppConstants.CONTACT_APODERADO_RT) AND (Email = :email OR Phone = :telefono)];
        }
        return cDuplicado;
    }

    @AuraEnabled
    public static void insertContact(List<Contact> lista){
        if(!lista.isEmpty() && Schema.sObjectType.Contact.isCreateable()) {
            boolean hasError = false;
			List<Object> objs = new List<Object>();
			Map<String, String> msjs = new Map<String, String>();
            Database.SaveResult[] lsr = Database.insert(lista, false);
            for (Integer i = 0; i < lsr.size(); i++) {
                if(!lsr[i].isSuccess() && !lsr[i].getErrors().isEmpty()) {
                    msjs.put(lista[i].Name, ((String)lsr[i].getErrors()[0].getMessage()));
                    objs.add(lista[i]);
                    hasError = true;
                }
            }
            if(hasError) {
                CBK_Log.error(msjs, objs);
                throw new IllegalArgumentException(Label.CIBE_ErrorInsertarContacto);
            }
        }
    }

    @AuraEnabled
    public static void insertAccounContactRelation(List<AccountContactRelation> lista, String recordId, String contactId){

        List<AccountContactRelation> c = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.CIBE_Cargo__c, toLabel(Contact.CC_Idioma__c), Contact.Email, Contact.Phone, Contact.Fax, Contact.Description, 
                            Contact.CIBE_Confidencial__c, Contact.CIBE_ContactoInfoComercial__c, Contact.RecordType.DeveloperName, Contact.CIBE_Carrec__c, Contact.CIBE_FechaVencimiento__c 
                            FROM AccountContactRelation WHERE AccountId = :recordId AND ContactId = :contactId AND Contact.RecordType.DeveloperName IN  ('CIBE_ContactoComercial','CIBE_Apoderado')];

        if(!c.isEmpty()){
            for (AccountContactRelation aCR : c) {
                if(c.contains(aCR)){
                    throw new IllegalArgumentException(Label.CIBE_ExisteContacto);
                }
            }
        }
        if( lista != null && !lista.isEmpty()){
            Database.insert(lista, false);
        }
    }

}