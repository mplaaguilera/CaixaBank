/*
Name:	  CIBE_CXBVisualizacionGC_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for CIBE_CXBVisualizacionGC and reporting LWCs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        Mikel Lezama    	07/10/2022		Init version
	1.1			    	        Alex Campos    	    21/11/2022		Without Sharing For Adding Users
    1.2                         Bea y Ali           24/11/2022      Modify 'createTeamMember()' 
    1.3                         Ali                 10/05/2023      Create 'getUserRole()', 'updateTeamMember()', 'deleteTeamMember()' and edit 'getRecords()'
    1.4         US567788        Ali                 26/10/2023      Modificar el campo responsabilidad para getRecodsCIB()
*/
public without sharing class CIBE_CXBVisualizacionGC_Controller {
    
    private final static Integer MAX_RESULTS 	= 10;

    public static List<Wrapper> getRecodsCIB(Integer offSet, List<String> recordIds){
        List<Wrapper> listReturn = new List<Wrapper>();
        List<AccountTeamMember> listAccMembers;

        if(AccountTeamMember.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {
                
            listAccMembers = [SELECT Id, AccountId, UserId, TeamMemberRole, CIBE_IsAutomatic__c, User.CIBE_Centro__c
                                FROM AccountTeamMember 
                                WHERE AccountId=:recordIds];
            }
            
    
        if(!listAccMembers.isEmpty()){
            List<Id> listUserId = new List<Id>();
            Map<Id, AccountTeamMember> userToMember = new Map<Id, AccountTeamMember>();

            for(AccountTeamMember accMember : listAccMembers){
                listUserId.add(accMember.UserId);
                if(userToMember.containsKey(accMember.UserId) && accMember.CIBE_IsAutomatic__c || !userToMember.containsKey(accMember.UserId)){
                    userToMember.put(accMember.UserId, accMember);
                }
            }

            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            if(!listUserId.isEmpty() && Contact.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.Contact.fields.Id.isAccessible() 
                && Schema.SObjectType.Contact.fields.Name.isAccessible()
                && Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
                && Schema.SObjectType.Contact.fields.CC_Numero_Oficina__c.isAccessible() 
                && Schema.SObjectType.Contact.fields.AV_DescFuncion__c.isAccessible()
                && Schema.SObjectType.Contact.fields.AV_Responsabilidad__c.isAccessible()){

                    mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c, CIBE_EmpleadoCIB__c,
                                                        account.name, CIBE_UnidadOrganizativa__c
                                                        FROM Contact 
                                                        WHERE AV_UsuarioAsociado__c = :listUserId AND RecordType.DeveloperName =: CIBE_AppConstants.EMPLOYEE_RT 
                                                        ORDER BY CIBE_EmpleadoCIB__c DESC, AV_UsuarioAsociado__r.Name ASC
                                                        LIMIT 10 OFFSET :offSet]);
                
            }
            List<AV_BookManagementMember__c> mapBookManager = new List<AV_BookManagementMember__c>();
            if(!mapContact.isEmpty() && AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.Id.isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_CarteraName__c.isAccessible()
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_EmpleadoGestor__c.isAccessible()){
                    mapBookManager = [SELECT Id, AV_CarteraName__c , AV_EmpleadoGestor__c 
                                        FROM AV_BookManagementMember__c 
                                        WHERE AV_EmpleadoGestor__c =: mapContact.keySet() AND AV_CarteraActiva__c = 'S'];
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

            for(Contact c : mapContact.values()){
                if(userToMember.containsKey(c.AV_UsuarioAsociado__c)) {
                    Wrapper wrap = new Wrapper();
                    wrap.id = userToMember.get(c.AV_UsuarioAsociado__c).Id;
                    wrap.nombre = c.Name;
                    wrap.userId = c.AV_UsuarioAsociado__c;
                    wrap.centro = c.CC_Numero_Oficina__c;
                    wrap.empleado = c.AV_DescFuncion__c ;
                    wrap.cartera = contactToBook.containsKey(c.Id) ? String.join(contactToBook.get(c.Id),', ') : '';
                    wrap.error = false;
                    wrap.msgerror = 'OK';
                    wrap.showContactRecord = '/' + c.Id;
                    wrap.automatic = userToMember.get(c.AV_UsuarioAsociado__c).CIBE_IsAutomatic__c;
                    wrap.rol = userToMember.get(c.AV_UsuarioAsociado__c).TeamMemberRole;
                    wrap.responsabilidad = (String.isNotBlank(c.CIBE_UnidadOrganizativa__c)) ? c.CIBE_UnidadOrganizativa__c : userToMember.get(c.AV_UsuarioAsociado__c).User.CIBE_Centro__c;
                    wrap.empleadoCIB = c.CIBE_EmpleadoCIB__c;
                    listReturn.add(wrap);
                }
            }
        }
        return listReturn;
    }

    public static List<Wrapper> getRecodsEMP(Integer offSet, List<String> recordIds){
        
        List<Wrapper> listReturn = new List<Wrapper>();
        List<AccountTeamMember> listAccMembers;
        offSet = offSet+10;
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {

                listAccMembers = [SELECT Id, AccountId, UserId, TeamMemberRole, CIBE_IsAutomatic__c 
                                    FROM AccountTeamMember 
                                    WHERE AccountId=:recordIds 
                                    ];
        }
    
        if(!listAccMembers.isEmpty()){
            List<Id> listUserId = new List<Id>();
            Map<Id, AccountTeamMember> userToMember = new Map<Id, AccountTeamMember>();

            for(AccountTeamMember accMember : listAccMembers){
                listUserId.add(accMember.UserId);
                if(!userToMember.containsKey(accMember.UserId)){
                    userToMember.put(accMember.UserId, accMember);
                } else if(userToMember.containsKey(accMember.UserId) && accMember.CIBE_IsAutomatic__c){
                    userToMember.get(accMember.UserId).CIBE_IsAutomatic__c = true ;
                }
            }

            Map<Id, Contact> mapContact = new Map<Id, Contact>();
            if(!listUserId.isEmpty() && Contact.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.Contact.fields.Id.isAccessible() 
                && Schema.SObjectType.Contact.fields.Name.isAccessible()
                && Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
                && Schema.SObjectType.Contact.fields.CC_Numero_Oficina__c.isAccessible() 
                && Schema.SObjectType.Contact.fields.AV_DescFuncion__c.isAccessible()
                && Schema.SObjectType.Contact.fields.AV_Responsabilidad__c.isAccessible()){
                
                    mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c, CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c,
                                                        account.name 
                                                    FROM Contact 
                                                    WHERE AV_UsuarioAsociado__c = :listUserId AND RecordType.DeveloperName =: CIBE_AppConstants.EMPLOYEE_RT]);
            }

            List<AV_BookManagementMember__c> mapBookManager = new List<AV_BookManagementMember__c>();
            if(!mapContact.isEmpty() && AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.Id.isAccessible() 
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_CarteraName__c.isAccessible()
                && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_EmpleadoGestor__c.isAccessible()){
                mapBookManager = [SELECT Id, AV_CarteraName__c , AV_EmpleadoGestor__c 
                                    FROM AV_BookManagementMember__c 
                                    WHERE AV_EmpleadoGestor__c =: mapContact.keySet() AND AV_CarteraActiva__c = 'S'];
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

            for(Contact c : mapContact.values()){
                if(userToMember.containsKey(c.AV_UsuarioAsociado__c) && listReturn.size() < offSet) {
                    Wrapper wrap = new Wrapper();
                    wrap.id = userToMember.get(c.AV_UsuarioAsociado__c).Id;
                    wrap.nombre = c.Name;
                    wrap.userId = c.AV_UsuarioAsociado__c;
                    wrap.centro = c.CC_Numero_Oficina__c;
                    wrap.empleado = c.AV_DescFuncion__c ;
                    wrap.cartera = contactToBook.containsKey(c.Id) ? String.join(contactToBook.get(c.Id),', ') : '';
                    wrap.error = false;
                    wrap.msgerror = 'OK';
                    wrap.showContactRecord = '/' + c.Id;
                    wrap.automatic = userToMember.get(c.AV_UsuarioAsociado__c).CIBE_IsAutomatic__c;  
                    wrap.rol = userToMember.get(c.AV_UsuarioAsociado__c).TeamMemberRole;
                    wrap.responsabilidad = c.account.name;
                    listReturn.add(wrap);
                }
            }
            
            listReturn.sort();
        }
        return listReturn;
    }

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> getRecords(Integer offSet, List<String> recordIds, Boolean isCIB) {
        
        List<Wrapper> listReturn = new List<Wrapper>();

        if(isCIB){
            listReturn = getRecodsCIB(offSet, recordIds);
        }
        else{
            listReturn = getRecodsEMP(offSet, recordIds);
        }
        return listReturn;
    }

    @AuraEnabled(cacheable = true) 
    public static String getUserRole(String userId) {

        List<User> userRole = new List<User>();
        if(User.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.User.fields.Id.isAccessible()) {
                userRole = [SELECT Id, UserRole.Name FROM User WHERE Id =:userId ];
        }
        String userRoleName;
        if(!userRole.isEmpty()){
            for(User user : userRole){
                userRoleName = user.UserRole.Name;
            }
        }
        return userRoleName;
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
                    User(Id, Name, AV_ExternalID__c, CIBE_Centro__c WHERE Id NOT IN :selectedIds and IsActive=true and Profile.Name =: CIBE_AppConstants.CIBE_GESTOR)
                LIMIT :MAX_RESULTS
            ];
        } else {
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    User(Id, Name, AV_ExternalID__c, CIBE_Centro__c WHERE IsActive=true and Profile.Name =: CIBE_AppConstants.CIBE_GESTOR )
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
    public static Boolean showAddMemberButton(List<String> accountIds){
        List<AccountTeamMember> teamMembers = new  List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()) {
                teamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :accountIds AND UserId = :UserInfo.getUserId()];
        } else {
            throw new IllegalArgumentException('showAddMemberButton - El usuario no tiene permisos para acceder a los miembros.');
        }

        return !teamMembers.isEmpty();
    }

    @AuraEnabled
    public static void createTeamMember(List<String> accountIds, String userId, String rol) {
        if(String.isBlank(rol)) {
            throw new IllegalArgumentException('Error');
        }

        Map<String,AccountTeamMember> teamMembers = new   Map<String,AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                for(AccountTeamMember act : [SELECT AccountId, TeamMemberRole, Id  FROM AccountTeamMember WHERE AccountId = :accountIds AND UserId = :userId]){
                    teamMembers.put(act.AccountId, act);
                }
        } else {
            throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para acceder a los miembros.');
        }

        if(rol == CIBE_AppConstants.GESTOR_PRINCIPAL || rol == CIBE_AppConstants.CONTACTO_CAIXABANK_RETAIL) {
            for (String accId : teamMembers.keySet()){
                teamMembers.get(accId).TeamMemberRole = rol;
            }

            List<AccountTeamMember> gestoresPrincipales = new List<AccountTeamMember>();
            if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
                && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                    for(AccountTeamMember act : [SELECT AccountId, TeamMemberRole, Id  FROM AccountTeamMember WHERE AccountId = :accountIds AND UserId != :userId AND TeamMemberRole = :rol]){
                        act.TeamMemberRole = CIBE_AppConstants.PARTICIPANTE;
                        gestoresPrincipales.add(act); 
                    }

                    if(AccountTeamMember.SObjectType.getDescribe().isUpdateable() 
                        && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
                        && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                            update gestoresPrincipales;
                            update teamMembers.values();
                    }
            } else {
                throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para acceder a los miembros.');
            }
        }

        List<AccountTeamMember> toInsert = new List<AccountTeamMember>();
        for (String accId : accountIds) {
            if(teamMembers.isEmpty() || (!teamMembers.isEmpty() && !teamMembers.containsKey(accId))){
                AccountTeamMember teamMember = new AccountTeamMember();
                teamMember.AccountId = accId;
                teamMember.UserId = userId;
                teamMember.TeamMemberRole = rol;
                teamMember.AccountAccessLevel = CIBE_AppConstants.EDIT;
                teamMember.OpportunityAccessLevel = CIBE_AppConstants.NONE;
                teamMember.CaseAccessLevel = CIBE_AppConstants.READ;
                teamMember.ContactAccessLevel = CIBE_AppConstants.EDIT;
                teamMember.CIBE_IsAutomatic__c = false;
                toInsert.add(teamMember);
            }
        }

        if(AccountTeamMember.SObjectType.getDescribe().isCreateable() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.OpportunityAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CaseAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {
                insert toInsert;
        } else {
            throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para insertar el miembro.');
        }
    }

    @AuraEnabled
    public static void updateTeamMember(String memberId, List<String> accountIds, String rol, String userId) {

        List<AccountTeamMember> changeTMRoles = new  List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && rol != 'Participante') {
                // changeTMRoles -> los accTMs con un account expecificos y un role diferente a Participante expecifico tb
                changeTMRoles = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accountIds AND TeamMemberRole = :rol AND UserId != :memberId];
        } else {
            throw new IllegalArgumentException('updateTeamMember - El usuario no tiene permisos para acceder a los AccountTeamMember.');
        }

        if(AccountTeamMember.SObjectType.getDescribe().isUpdateable() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()) {
                List<AccountTeamMember> updateAccTeamMember = new List<AccountTeamMember>();
                updateAccTeamMember = [SELECT Id,UserId FROM AccountTeamMember WHERE UserId = :userId AND AccountId IN :accountIds];
                for(AccountTeamMember aTM : updateAccTeamMember) {               
                    aTM.TeamMemberRole = rol;
                }
                update updateAccTeamMember;
            

            if(AccountTeamMember.SObjectType.getDescribe().isUpdateable() 
                && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
                && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
                && !changeTMRoles.isEmpty()) {
                    for(AccountTeamMember aTM : changeTMRoles) {
                        aTM.TeamMemberRole = 'Participante';
                    }
                    update changeTMRoles;
            }
        } else {
            throw new IllegalArgumentException('updateTeamMember - El usuario no tiene permisos para actualizar el miembro.');
        }
    }

    @AuraEnabled
    public static void deleteTeamMember(String userId, List<String> accountIds) {

        if(AccountTeamMember.SObjectType.getDescribe().isDeletable() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()) {

                List<AccountTeamMember> deleteAccTeamMember = new List<AccountTeamMember>();
                deleteAccTeamMember = [SELECT Id,UserId FROM AccountTeamMember WHERE UserId = :userId AND AccountId IN :accountIds];
                if(deleteAccTeamMember.size() > 0){
                    delete deleteAccTeamMember;
                }
        } else {           
            throw new IllegalArgumentException('deleteTeamMember - El usuario no tiene permisos para eliminar el miembro.');
        }
    }

    public class Wrapper implements Comparable{

        @AuraEnabled
        public String id {get;set;}

        @AuraEnabled
        public String nombre {get;set;}

        @AuraEnabled
        public String userId {get;set;}

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
        public Boolean automatic {get;set;}

        @AuraEnabled
        public String rol {get;set;}

        @AuraEnabled
        public String responsabilidad {get;set;}

        @AuraEnabled
        public Boolean empleadoCIB {get;set;}

        public Wrapper() {
            this.automatic = false;
        }

        public Integer compareTo(Object compareTo) {
            Wrapper other = (Wrapper)compareTo;
            
            Integer returnValue = 0;
            if(this.automatic && !other.automatic) {
                return -1;
            } else if(!this.automatic && other.automatic) {
                return 1;
            } 
            else {
                if (this.nombre > other.nombre) {
                    returnValue = 1;
                } else if (this.nombre < other.nombre) {
                    returnValue = -1;
                } else if ((this.nombre == null) && (other.nombre != null)){
                    returnValue = -1;
                } else if ((this.nombre != null) && (other.nombre == null)){
                    returnValue = 1;
                }
            }
            return returnValue;       
        }
    }
    
}