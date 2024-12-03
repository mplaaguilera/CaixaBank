/**********************************************************************************************************************
 Name:      CIBE_CXBTeamNewOpportunityController
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for CIBE_CXBTeamNewOpportunity LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Alicia		    	09/02/2023      Init version
	1.1      US379981				Lucía		    	24/04/2023      Add method getAccountTeamMember
	1.2      PPM100455545			Lucía		    	19/09/2024      Add method getContact
	1.3      FIX20241386			Lucía		    	30/10/2024      Update method getContact

***********************************************************************************************************************/
public with sharing class CIBE_CXBTeamNewOpportunityController {

	private final static Integer MAX_RESULTS 	= 10;

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm, String EAPGestor) {
		String methodName = 'search';
		
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<Contact>> searchResults = new List<List<Contact>>();
		
		if(!String.isBlank(searchTerm)){
			searchTerm += '*';
			searchResults= [FIND :searchTerm IN All FIELDS RETURNING
			Contact(Id, Name, CC_Matricula__c WHERE AV_UsuarioAsociado__c !=null AND RecordType.DeveloperName = 'CC_Empleado' AND Id != :EAPGestor AND AV_UsuarioAsociado__r.IsActive = : true) LIMIT :MAX_RESULTS];
		}

		List<String> listIds = new List<String>();
        if(!searchResults.isEmpty()) {
            Contact[] listContact = (List<Contact>) searchResults[0];
			if(!listContact.isEmpty()){
				for (Contact c : listContact) {
					results.add(new AV_LookupSearchResult(c.Id, 'Contact', 'standard:contact', c.Name, 'Matricula • ' + c.CC_Matricula__c));
					listIds.add(c.Id);
				}
			}
            results.sort();
        }
		return results;
	}

	@AuraEnabled(cacheable=true)
	public static List<ContactoWrapper> getMembers(List<String> listIdContact) {
		List<Contact> contacts = new List<Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Contact.fields.Id.isAccessible() 
            && Schema.SObjectType.Contact.fields.Name.isAccessible()
            && Schema.SObjectType.Contact.fields.CC_Nombre_Oficina__c.isAccessible()
            && Schema.SObjectType.Contact.fields.AV_DescFuncion__c.isAccessible()
            && Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
            ) {
            contacts = [SELECT Id, Name, AV_UsuarioAsociado__c, CC_Nombre_Oficina__c, AV_DescFuncion__c FROM Contact WHERE Id IN: listIdContact AND RecordType.DeveloperName = 'CC_Empleado'];
        }
		
		List<ContactoWrapper> returns = new List<ContactoWrapper>();
		for(Contact c : contacts) {
			ContactoWrapper wrap = new ContactoWrapper();
			wrap.id = c.Id;
			wrap.nombre = c.Name;
			wrap.user = c.AV_UsuarioAsociado__c;
			wrap.centro = c.CC_Nombre_Oficina__c;
			wrap.funcion = c.AV_DescFuncion__c;
			wrap.permiso = CIBE_AppConstants.ACC_EDIT;
			wrap.role = CIBE_AppConstants.PARTICIPANTE;
			returns.add(wrap);
		}
		return returns;
	}

	@AuraEnabled(cacheable=true)
	public static Map<Id,Contact> getAccountTeamMember(String recordId, String EAPGestor){
		List<AccountTeamMember> listAccMembers = new List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {
            listAccMembers = [SELECT Id, AccountId, UserId, User.Name, TeamMemberRole, CIBE_IsAutomatic__c FROM AccountTeamMember WHERE AccountId=:recordId AND User.IsActive =: true ];
        }

		Map<Id, Contact> mapContact = new Map<Id, Contact>();

		if(!listAccMembers.isEmpty()){
            List<Id> listUserId=new List<Id>();
            for(AccountTeamMember accMember : listAccMembers){
                listUserId.add(accMember.UserId);
            }
		
			if(!listUserId.isEmpty() && Contact.SObjectType.getDescribe().isAccessible() 
				&& Schema.SObjectType.Contact.fields.Id.isAccessible() 
				&& Schema.SObjectType.Contact.fields.Name.isAccessible()
				&& Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
				&& Schema.SObjectType.Contact.fields.CC_Numero_Oficina__c.isAccessible() 
				&& Schema.SObjectType.Contact.fields.AV_DescFuncion__c.isAccessible()
				&& Schema.SObjectType.Contact.fields.AV_Responsabilidad__c.isAccessible()){
				mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c FROM Contact WHERE AV_UsuarioAsociado__c = :listUserId AND RecordType.DeveloperName = 'CC_Empleado' AND Id != :EAPGestor]);

			}
		}

	
		return mapContact;

	}



	@AuraEnabled(cacheable=true)
	public static Map<Id,Contact> getContact(String pais){
		Map<Id, Contact> mapContact = new Map<Id, Contact>();
		Set<Id> contacto = new Set<Id>();
		Map<String, String> values = new Map<String, String>();
		List<String> record = new List<String>();
		
		List<String> lstString = pais.split(';');
		if(!lstString.isEmpty()){
			List<CIBE_PaisJerarquia__mdt> paisJerarquia = [SELECT Id, CIBE_Country__c, CIBE_Value__c  from CIBE_PaisJerarquia__mdt WHERE CIBE_Country__c IN :lstString];
			if(!paisJerarquia.isEmpty()){
				for (CIBE_PaisJerarquia__mdt valuePJ : paisJerarquia) {
					values.put(valuePJ.CIBE_Country__c, valuePJ.CIBE_Value__c);
				}			
			}


			if(values != null){
				for (String paisV : lstString) {
					for (String mapPaisV : values.keySet()){
						if(paisV == mapPaisV){
							record.add(values.get(mapPaisV));
						}
					}
				}
			}
		}



		if(record != null){
			List<CIBE_Hierarchy__c> jerarquia = [SELECT Id, CIBE_Contact__c FROM CIBE_Hierarchy__c WHERE CIBE_SectoresPaises__r.Name = :record OR CIBE_CentrosCarteras__r.Name = :record];

			if(!jerarquia.isEmpty()){
				for (CIBE_Hierarchy__c cont : jerarquia) {
					contacto.add(cont.CIBE_Contact__c);
				}

				mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c FROM Contact WHERE Id IN :contacto]);
			}

		}

		return mapContact;

	}


	public class ContactoWrapper {
		@AuraEnabled 
		public String id {get;set;}

        @AuraEnabled 
		public String nombre {get;set;}

		@AuraEnabled
		public String user {get;set;}

        @AuraEnabled 
		public String centro {get;set;}

        @AuraEnabled 
		public String funcion {get;set;}

        @AuraEnabled
		public String permiso {get;set;}
		
        @AuraEnabled
		public String role {get;set;}
	}

}