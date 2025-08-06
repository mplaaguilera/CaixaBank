/*
Name:	  CIBE_Apoderados_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for CIBE_Apoderados
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0                         Mikel Lezama        28/11/2022      Init Version
*/
public with sharing class CIBE_Apoderados_Controller {


    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> getRecords(String recordId) {
        List<Contact> contacts = new List<Contact>();
        String cargo = '';
        if(Contact.SObjectType.getDescribe().isAccessible()) {
            contacts = [SELECT Id, Name, CC_Numero_Documento__c, toLabel(CIBE_Carrec__c), CIBE_DatosdeEscritura1__c, CIBE_DatosdeEscritura2__c, CIBE_DatosdeEscritura3__c, CIBE_FechaVencimiento__c 
                        FROM Contact 
                        WHERE   Recordtype.DeveloperName =: CIBE_AppConstants.CONTACT_APODERADO_RT
                                AND AccountId = :recordId
                                AND CIBE_Carrec__c != '00016'
                                AND (CIBE_FechaVencimiento__c >= TODAY OR CIBE_FechaVencimiento__c = NULL) ];
        }        
        List<Wrapper> listReturn = new List<Wrapper>();
        if(!contacts.isEmpty()) {
            for(Contact c : contacts) {
                String esc = '';
                if (String.isNotBlank(c.CIBE_DatosdeEscritura1__c)) {
                    esc += c.CIBE_DatosdeEscritura1__c + ' ';
                }
                if (String.isNotBlank(c.CIBE_DatosdeEscritura2__c)) {
                    esc += c.CIBE_DatosdeEscritura2__c + ' ';
                }
                if (String.isNotBlank(c.CIBE_DatosdeEscritura3__c)) {
                    esc += c.CIBE_DatosdeEscritura3__c;
                }

                Wrapper wrap = new Wrapper();
                wrap.id = c.Id;
                wrap.name = c.Name;
                wrap.identificador = c.CC_Numero_Documento__c;
                cargo = c.CIBE_Carrec__c?.toLowerCase().capitalize();
                wrap.rol = cargo; 
                wrap.escritura = esc;
                wrap.vencimiento = c.CIBE_FechaVencimiento__c;
                wrap.showContactRecord = '/' + c.Id;
                listReturn.add(wrap);
            }
        }
        return listReturn;
    }

    @AuraEnabled(cacheable = true) 
    public static String getRecordType() {
        return Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.CONTACT_APODERADO_RT).getRecordTypeId();
    }
    
    public class Wrapper{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String identificador {get;set;}
        @AuraEnabled public String rol {get;set;}
        @AuraEnabled public String escritura {get;set;}
        @AuraEnabled public Date vencimiento {get;set;}
        @AuraEnabled public String showContactRecord {get;set;}
    }

}