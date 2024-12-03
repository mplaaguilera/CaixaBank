public with sharing class GRR_Compartir_Casos_Controller {
 
    @AuraEnabled(cacheable=true)
    public static List<CaseTeamMember> getCaseTeamMembers(Id caseId) {
        return [
            SELECT Id, TeamRoleId, TeamRole.Name, MemberId, Member.Name, ParentId
            FROM CaseTeamMember
            WHERE ParentId = :caseId
        ];
    }
 
    @AuraEnabled(cacheable=true)
    public static List<GroupMember> getUsuarios() {
        return [
            SELECT UserOrGroupId, UserOrGroup.Name 
            FROM GroupMember 
            WHERE Group.Type='Regular' AND Group.DeveloperName = 'GRR_Grupo_Compartir_Usuarios'
            WITH SECURITY_ENFORCED
        ];
    }
 
    @AuraEnabled(cacheable=true)
    public static List<CaseTeamRole> getCaseTeamRoles() {
        return[SELECT Id, Name FROM CaseTeamRole WHERE Name LIKE 'GRR_%' WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static List<String> compartirUsuarioCaso(List<Map<String, String>> records, String caseId) {
        List<CaseTeamMember> lstCaseteamMembersInsert = new List<CaseTeamMember>(); 
        List<String> lstNombresUsuariosCompartir = new List<String>();

        for (Map<String, String> record : records) {
            CaseTeamMember member = new CaseTeamMember();
            member.ParentId = caseId; 
            member.MemberId = record.get('UsuarioId');
            member.TeamRoleId = record.get('RoleId');

            lstCaseteamMembersInsert.add(member);
            lstNombresUsuariosCompartir.add(record.get('Usuario'));
        }

        if(!lstCaseteamMembersInsert.isEmpty() && Schema.sObjectType.CaseTeamMember.isCreateable()){
            insert lstCaseteamMembersInsert;
        }

        return lstNombresUsuariosCompartir;
    }

    @AuraEnabled
    public static List<String> eliminarUsuarioCaso(List<Map<String, String>> records, String caseId) {
        List<CaseTeamMember> lstCaseTeamMembersDelete = new List<CaseTeamMember>(); 
        List<String> lstNombresUsuariosEliminar = new List<String>();
        Set<Id> idsUsuarios = new Set<Id>();

        for (Map<String, String> record : records) {
            if(String.isNotBlank(record.get('UsuarioId')) && String.isNotBlank(record.get('Usuario'))){
                idsUsuarios.add(record.get('UsuarioId'));
                lstNombresUsuariosEliminar.add(record.get('Usuario'));
            }
        }
            
        for (CaseTeamMember member : [SELECT Id FROM CaseTeamMember WHERE MemberId IN :idsUsuarios AND ParentId = :caseId WITH SECURITY_ENFORCED]) {
            lstCaseTeamMembersDelete.add(member);
        }

        if(!lstCaseTeamMembersDelete.isEmpty() && Schema.sObjectType.CaseTeamMember.isDeletable()){
            delete lstCaseTeamMembersDelete;
        }

        return lstNombresUsuariosEliminar;
    }
}