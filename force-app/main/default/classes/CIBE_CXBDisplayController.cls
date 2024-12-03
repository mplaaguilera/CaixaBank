/*
Name:	  CIBE_CXBDisplayController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for cibe_CXBVisualizacion and reporting LWCs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        Jose Maria Perez 	10/08/2022		Init version
    1.1                         Alex Campos         14/09/2022      Added Add Member Button
    1.2                         Bea y Ali           24/11/2022      Move 'createTeamMember()' and 'updateTeamMember()' to 'CIBE_CXBDisplayControllerDelete'
    1.3         US580860        Lucía               11/05/2023      Modificación del metodo getRecords para que devuelva las carteras activas.
	1.4         US567788        Ali                 26/10/2023      Se añade el metodo getRecordsCIB() para mostrar el campo responsabilidad de una manera u otra dependiendo si es CIB o EMP.
*/
public with sharing class CIBE_CXBDisplayController {
  
    private final static Integer MAX_RESULTS 	= 10;

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> getRecords(String recordId) {
        List<Wrapper> listReturn=new List<Wrapper>();
        
        List<AccountTeamMember> listAccMembers;
        List<Account> gestor = new List<Account>();
        Set<Id> gId = new Set<Id>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {
            listAccMembers = [SELECT Id, AccountId, UserId, TeamMemberRole, CIBE_IsAutomatic__c FROM AccountTeamMember WHERE AccountId=:recordId ];
            gestor = [SELECT Id, AV_EAPGestor__c FROM Account WHERE Id =: recordId];
        }

        if(!gestor.isEmpty()){
            for(Account gestorId : gestor){
                gId.add(gestorId.AV_EAPGestor__c);
            }
        }
    
        if(!listAccMembers.isEmpty()){
            List<Id> listUserId=new List<Id>();
            for(AccountTeamMember accMember : listAccMembers){
                listUserId.add(accMember.UserId);
            }

            Map<Id, AccountTeamMember> userToMember = new Map<Id, AccountTeamMember>();
            for(AccountTeamMember accMember : listAccMembers){ 
                userToMember.put(accMember.UserId, accMember);
            }
            
            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            if(!listUserId.isEmpty() && Contact.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.Contact.fields.Id.isAccessible() 
                && Schema.SObjectType.Contact.fields.Name.isAccessible()
                && Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
                && Schema.SObjectType.Contact.fields.CC_Numero_Oficina__c.isAccessible() 
                && Schema.SObjectType.Contact.fields.AV_DescFuncion__c.isAccessible()
                && Schema.SObjectType.Contact.fields.AV_Responsabilidad__c.isAccessible()){
                mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c, account.Name FROM Contact WHERE AV_UsuarioAsociado__c = :listUserId AND RecordType.DeveloperName = 'CC_Empleado']);
            }

            List<AV_BookManagementMember__c> mapBookManager = new List<AV_BookManagementMember__c>();
            if(!mapContact.isEmpty() && AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.Id.isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_CarteraName__c.isAccessible()
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_EmpleadoGestor__c.isAccessible()){
                mapBookManager = [SELECT Id, AV_CarteraName__c , AV_EmpleadoGestor__c FROM AV_BookManagementMember__c WHERE AV_EmpleadoGestor__c IN : gId AND AV_CarteraActiva__c = 'S'];
            }

            Map<Id, List<String>> contactToBook = new Map<Id, List<String>>();
            if(!mapBookManager.isEmpty()) {
                for(AV_BookManagementMember__c bookManagement : mapBookManager) {
                    if(!contactToBook.containsKey(bookManagement.AV_EmpleadoGestor__c)) {
                        contactToBook.put(bookManagement.AV_EmpleadoGestor__c, new List<String>());
                    }
                    if(!contactToBook.get(bookManagement.AV_EmpleadoGestor__c).contains(bookManagement.AV_CarteraName__c)) {
                        contactToBook.get(bookManagement.AV_EmpleadoGestor__c).add(bookManagement.AV_CarteraName__c);
                    }
                }
            }

            User usr = [SELECT ID, UserRole.name FROM USER WHERE Id = :UserInfo.getUserId() Limit 1];

            for(Contact c : mapContact.values()){
                if(userToMember.containsKey(c.AV_UsuarioAsociado__c)) {
                    Wrapper wrap = new Wrapper();
                    wrap.id = userToMember.get(c.AV_UsuarioAsociado__c).Id;
                    wrap.nombre = c.Name;
                    wrap.centro = c.CC_Numero_Oficina__c;
                    wrap.empleado = c.AV_DescFuncion__c ;
                    wrap.cartera = contactToBook.containsKey(c.Id) ? String.join(contactToBook.get(c.Id),', ') : '';
                    wrap.error = false;
                    wrap.msgerror = 'OK';
                    wrap.showContactRecord = '/' + c.Id;
                    wrap.rol = userToMember.get(c.AV_UsuarioAsociado__c).TeamMemberRole;
                    wrap.automatic = userToMember.get(c.AV_UsuarioAsociado__c).CIBE_IsAutomatic__c;
                    wrap.responsabilidad = usr.UserRole.name.containsIgnoreCase('Emp')? c.AV_Responsabilidad__c : c.account.Name;
                    listReturn.add(wrap);
                }
            }
        }
        return listReturn;
    }

	@AuraEnabled(cacheable = true)
    public static List<Wrapper> getRecordsCIB(String recordId) {
        List<Wrapper> listReturn=new List<Wrapper>();
        
        List<AccountTeamMember> listAccMembers;
        List<Account> gestor = new List<Account>();
        Set<Id> gId = new Set<Id>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {
            listAccMembers = [SELECT Id, AccountId, UserId, TeamMemberRole, CIBE_IsAutomatic__c,  User.CIBE_Centro__c 
                                FROM AccountTeamMember 
                                WHERE AccountId=:recordId ];
            gestor = [SELECT Id, AV_EAPGestor__c FROM Account WHERE Id =: recordId];
        }

        if(!gestor.isEmpty()){
            for(Account gestorId : gestor){
                gId.add(gestorId.AV_EAPGestor__c);
            }
        }
    
        if(!listAccMembers.isEmpty()){
            List<Id> listUserId=new List<Id>();
            for(AccountTeamMember accMember : listAccMembers){
                listUserId.add(accMember.UserId);
            }

            Map<Id, AccountTeamMember> userToMember = new Map<Id, AccountTeamMember>();
            for(AccountTeamMember accMember : listAccMembers){ 
                userToMember.put(accMember.UserId, accMember);
            }
            
            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            if(!listUserId.isEmpty() && Contact.SObjectType.getDescribe().isAccessible()){
                mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c, account.Name, CIBE_UnidadOrganizativa__c  FROM Contact WHERE AV_UsuarioAsociado__c = :listUserId AND RecordType.DeveloperName = 'CC_Empleado']);
            }

            List<AV_BookManagementMember__c> mapBookManager = new List<AV_BookManagementMember__c>();
            if(!mapContact.isEmpty() && AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.Id.isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_CarteraName__c.isAccessible()
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_EmpleadoGestor__c.isAccessible()){
                mapBookManager = [SELECT Id, AV_CarteraName__c , AV_EmpleadoGestor__c FROM AV_BookManagementMember__c WHERE AV_EmpleadoGestor__c IN : gId AND AV_CarteraActiva__c = 'S'];
            }

            Map<Id, List<String>> contactToBook = new Map<Id, List<String>>();
            if(!mapBookManager.isEmpty()) {
                for(AV_BookManagementMember__c bookManagement : mapBookManager) {
                    if(!contactToBook.containsKey(bookManagement.AV_EmpleadoGestor__c)) {
                        contactToBook.put(bookManagement.AV_EmpleadoGestor__c, new List<String>());
                    }
                    if(!contactToBook.get(bookManagement.AV_EmpleadoGestor__c).contains(bookManagement.AV_CarteraName__c)) {
                        contactToBook.get(bookManagement.AV_EmpleadoGestor__c).add(bookManagement.AV_CarteraName__c);
                    }
                }
            }

            User usr = [SELECT ID, UserRole.name FROM USER WHERE Id = :UserInfo.getUserId() Limit 1];

            for(Contact c : mapContact.values()){
                if(userToMember.containsKey(c.AV_UsuarioAsociado__c)) {
                    Wrapper wrap = new Wrapper();
                    wrap.id = userToMember.get(c.AV_UsuarioAsociado__c).Id;
                    wrap.nombre = c.Name;
                    wrap.centro = c.CC_Numero_Oficina__c;
                    wrap.empleado = c.AV_DescFuncion__c ;
                    wrap.cartera = contactToBook.containsKey(c.Id) ? String.join(contactToBook.get(c.Id),', ') : '';
                    wrap.error = false;
                    wrap.msgerror = 'OK';
                    wrap.showContactRecord = '/' + c.Id;
                    wrap.rol = userToMember.get(c.AV_UsuarioAsociado__c).TeamMemberRole;
                    wrap.automatic = userToMember.get(c.AV_UsuarioAsociado__c).CIBE_IsAutomatic__c;
                    wrap.responsabilidad = (String.isNotBlank(c.CIBE_UnidadOrganizativa__c)) ? c.CIBE_UnidadOrganizativa__c : userToMember.get(c.AV_UsuarioAsociado__c).User.CIBE_Centro__c;
                    listReturn.add(wrap);
                }
            }
        }
        return listReturn;
    }

	@AuraEnabled(cacheable = true)
	public static List<AV_LookupSearchResult> searchUser(String searchTerm, List<String> selectedIds) { 
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_ExternalID__c, CIBE_Centro__c WHERE Id NOT IN :selectedIds and IsActive=true and Profile.Name='CIBE_Gestor')
				LIMIT :MAX_RESULTS
			];
		} else {
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_ExternalID__c, CIBE_Centro__c WHERE IsActive=true and Profile.Name='CIBE_Gestor')
				LIMIT :MAX_RESULTS
			];
		}
		String userIcon = 'standard:user';
		List<User> listUser = (List<User>) searchResults[0];
		for (User u : listUser) {
			results.add(
				new AV_LookupSearchResult(
					u.Id,
					'User',
					userIcon,
					u.Name,
					'Centro • ' + u.CIBE_Centro__c
				)
			);
		}
		results.sort();

		return results;
	}

    @AuraEnabled(cacheable = true)
    public static Boolean showAddMemberButton(String accountId){
        List<AccountTeamMember> teamMembers = new  List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()) {
                teamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :accountId AND UserId = :UserInfo.getUserId()];
        } else {
            throw new IllegalArgumentException('showAddMemberButton - El usuario no tiene permisos para acceder a los miembros.');
        }

        return !teamMembers.isEmpty();
    }
    
    @AuraEnabled(cacheable = true)
    public static Boolean showAddMemberGC(String recordId){
        List<FinServ__AccountAccountRelation__c> accountAccountRelation = new  List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.Id.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__RelatedAccount__c.isAccessible()) {
                accountAccountRelation = [SELECT Id FROM FinServ__AccountAccountRelation__c WHERE RecordType.DeveloperName = 'CIBE_GrupoComercial' AND FinServ__Role__r.Name = 'Parent' AND FinServ__RelatedAccount__c =:recordId];
        } else {
            throw new IllegalArgumentException('showAddMemberGC - El usuario no tiene permisos para acceder a los grupos comerciales.');
        }

        return !accountAccountRelation.isEmpty();
    }

    public class Wrapper{

        @AuraEnabled
        public String id {get;set;}

        @AuraEnabled
        public String nombre {get;set;}

        @AuraEnabled
        public String centro {get;set;}

        @AuraEnabled
        public String empleado {get;set;}

        @AuraEnabled
        public String cartera {get;set;}

        @AuraEnabled
        public Boolean error {get;set;}

        @AuraEnabled
        public String msgerror {get;set;}

        @AuraEnabled
        public String showContactRecord {get;set;}

        @AuraEnabled
        public String rol {get;set;}

        @AuraEnabled
        public Boolean automatic {get;set;}
        
        @AuraEnabled
        public String responsabilidad {get;set;}
    }

    @AuraEnabled(cacheable=true) 
	public static String getAppDefinition() {

        UserAppInfo userAppInfo;
        AppDefinition appDefinition;
	    if(Schema.sObjectType.UserAppInfo.isAccessible() && Schema.sObjectType.AppDefinition.isAccessible()){
            userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
            appDefinition = [SELECT DurableId, DeveloperName FROM AppDefinition WHERE DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
        }
        return appDefinition.DeveloperName;
    }
}