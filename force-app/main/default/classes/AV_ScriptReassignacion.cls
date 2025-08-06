public with sharing class AV_ScriptReassignacion implements Queueable{
    List<PermissionSetAssignment> psToDelete = new List<PermissionSetAssignment>();
    Integer maxSize = 800;
    List<Id> oldUserAnalytics = new List<Id>();
    PermissionSetGroup gestorPSG = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'AV_Gestor'];
    Integer iteraciones = 0;
    List<User> usersToReassignAux = new List<User>();
    
    public AV_ScriptReassignacion() {
        this.psToDelete = [SELECT id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroup.DeveloperName = 'AV_Lectura_y_Analytics' LIMIT :maxSize];
    }
    public AV_ScriptReassignacion( List<Id> oldUserAnalytics) {
        this.psToDelete = [SELECT id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroup.DeveloperName = 'AV_Lectura_y_Analytics' LIMIT :maxSize];
        this.oldUserAnalytics.addAll(oldUserAnalytics);
        }
    public AV_ScriptReassignacion(List<User> usersToReassignAux){
        this.usersToReassignAux = usersToReassignAux;
    }

        public void execute(QueueableContext qc){

        List<PermissionSetAssignment> aux = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> listToReassign = new List<PermissionSetAssignment>();
        List<Id> oldUserAnalyticsAux = new List<Id>();
        if(Test.isRunningTest()){
            psToDelete = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroup.DeveloperName = 'AV_Lectura_y_Analytics' AND Assignee.Alias = 'tsAlias'];
        }
            if(!psToDelete.isEmpty()){
                for(Integer i=0; i<maxSize;i++){
                    if(!psToDelete.isEmpty()){
                        PermissionSetAssignment input = psToDelete.remove(0);
                        oldUserAnalyticsAux.add(input.AssigneeId);
                        aux.add(input);
                        PermissionSetAssignment reAssignPsg = new PermissionSetAssignment();
                        reAssignPsg.PermissionSetGroupId = gestorPSG.Id;
                        reAssignPsg.AssigneeId = input.AssigneeId;
                        listToReassign.add(reAssignPsg);
                    }else{
                        break;
                    }
                }
            }
            if(!aux.isEmpty()){
                Database.delete(aux);
                Database.insert(listToReassign,false);
                if(!Test.isRunningTest()){
                    System.enqueueJob(new AV_ScriptReassignacion(oldUserAnalyticsAux));
                }
            }else{
                if(usersToReassignAux.isEmpty()){
                    usersToReassignAux = 
                    [SELECT Id,Email,AV_Funcion__c,IsActive,AV_ExternalId__c,AV_DeactiveAutoPS__c FROM User
                    WHERE (UserRole.DeveloperName = 'AV_SistematicaComercial' 
                    AND IsActive = true
                    AND AV_ProfileName__c = 'AV_Usuario_CaixaBank')
                    OR Id In :oldUserAnalyticsAux 
                    ORDER BY Name ];   
                }
                List<User> auxUser = new List<User>();
                maxSize = 100;
                if(!usersToReassignAux.isEmpty()){
                    for(Integer i=0;i<maxSize;i++){
                        if(!usersToReassignAux.isEmpty()){
                            auxUser.add(usersToReassignAux.remove(0));
                        }else{
                            break;
                        }
                    }
                }
                if(!auxUser.isEmpty()){
                    AV_UserTriggerHelper.permissionUser(auxUser);
                    if(!usersToReassignAux.isEmpty()){
                        if(!Test.isRunningTest()){
                            System.enqueueJob(new AV_ScriptReassignacion(usersToReassignAux));
                        }
                    }else{
                        System.debug('Reasignación finalizada');
                    }
                }
            }

        }
    
}