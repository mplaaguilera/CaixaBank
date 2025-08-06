/*
Name:	  CIBE_CXBDisplayController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for cibe_CXBVisualizacion and reporting LWCs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
    1.1                         Alex Campos         14/09/2022      Init Version
    1.2                         Bea y Ali           24/11/2022      Create 'createTeamMember()' and 'updateTeamMember()'
*/
public without sharing class CIBE_CXBDisplayControllerDelete {
    
    @AuraEnabled
    public static void createTeamMember(String accountId, String userId, String teamMemberRole) {
        List<AccountTeamMember> teamMembers = new  List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                teamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accountId AND UserId = :userId];
        } else {
            throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para acceder a los miembros.');
        }

        List<AccountTeamMember> changeTMRoles = new  List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && teamMemberRole != 'Participante') {
                changeTMRoles = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accountId AND TeamMemberRole = :teamMemberRole];
        }

        if(!teamMembers.isEmpty()) {
            throw new IllegalArgumentException('El miembro ya existe en este cliente.');
        }

        AccountTeamMember teamMember = new AccountTeamMember();
        teamMember.AccountId = accountId;
        teamMember.UserId = userId;
        teamMember.TeamMemberRole = teamMemberRole;
        teamMember.AccountAccessLevel = CIBE_AppConstants.EDIT;
        teamMember.OpportunityAccessLevel = CIBE_AppConstants.NONE;
        teamMember.CaseAccessLevel = CIBE_AppConstants.READ;
        teamMember.ContactAccessLevel = CIBE_AppConstants.EDIT;
        teamMember.CIBE_IsAutomatic__c = false;

        if(AccountTeamMember.SObjectType.getDescribe().isCreateable() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.OpportunityAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CaseAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()) {
                insert teamMember;

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
            throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para insertar el miembro.');
        }
    }

    @AuraEnabled
    public static void updateTeamMember(String memberId, String accountId, String teamMemberRole) {
        List<AccountTeamMember> changeTMRoles = new  List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && teamMemberRole != 'Participante') {
                changeTMRoles = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accountId AND TeamMemberRole = :teamMemberRole];
        }

        if(AccountTeamMember.SObjectType.getDescribe().isUpdateable() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
            update new AccountTeamMember(
                Id = memberId,
                TeamMemberRole = teamMemberRole
            );

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
    public static void deleteTeamMember(String memberId) {
        if(AccountTeamMember.SObjectType.getDescribe().isDeletable() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()) {
            delete new AccountTeamMember(
                Id = memberId
            );
        } else {           
            throw new IllegalArgumentException('deleteTeamMember - El usuario no tiene permisos para eliminar el miembro.');
        }
    }


    @future
    public static void createTeamMemberCartera(List<String> clientes, String userId) {
        List<AccountTeamMember> teamMembers = new  List<AccountTeamMember>();
        List<AccountTeamMember> toInsert = new List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
                teamMembers = [SELECT Id, TeamMemberRole, AccountId FROM AccountTeamMember WHERE AccountId IN :clientes AND UserId = :userId];
        } else {
            throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para acceder a los miembros.');
        }

        if(!teamMembers.isEmpty()) {
            for (String c : clientes) {
               for (AccountTeamMember accTM : teamMembers) {
                if(!c.contains(accTM.AccountId)){
                    toInsert.add(
                        new AccountTeamMember(
                            AccountId = c,
                            UserId = userId,
                            TeamMemberRole = 'Participante',
                            AccountAccessLevel = CIBE_AppConstants.EDIT,
                            OpportunityAccessLevel = CIBE_AppConstants.NONE,
                            CaseAccessLevel = CIBE_AppConstants.READ,
                            ContactAccessLevel = CIBE_AppConstants.EDIT,
                            CIBE_IsAutomatic__c = false
                        ));
                }
               }
            }
        }else if(teamMembers.isEmpty()) {
            for (String accountId : clientes) {
                toInsert.add(
                    new AccountTeamMember(
                        AccountId = accountId,
                        UserId = userId,
                        TeamMemberRole = 'Participante',
                        AccountAccessLevel = CIBE_AppConstants.EDIT,
                        OpportunityAccessLevel = CIBE_AppConstants.NONE,
                        CaseAccessLevel = CIBE_AppConstants.READ,
                        ContactAccessLevel = CIBE_AppConstants.EDIT,
                        CIBE_IsAutomatic__c = false
                    ));
            }
        }


        if(AccountTeamMember.SObjectType.getDescribe().isCreateable() 
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.OpportunityAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CaseAccessLevel.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.CIBE_IsAutomatic__c.isAccessible()){
            
                Database.SaveResult[] updates = Database.insert(toInsert, false);
                
                boolean hasError = false;
                List<Object> objs = new List<Object>();
                Map<String, String> msjs = new Map<String, String>();
                for (Integer i = 0; i < toInsert.size(); i++) {
                    Database.SaveResult dr = updates[i];
                    if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                        msjs.put(toInsert[i].AccountId, ((String)dr.getErrors()[0].getMessage()));
                        objs.add(toInsert[i]);
                        hasError = true;
                    }
                }

                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }

            } else {
                throw new IllegalArgumentException('createTeamMember - El usuario no tiene permisos para insertar el miembro.');
            }

		

    }

}