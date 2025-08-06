public with sharing class OS_Milestone_Caso_Manual {

    @InvocableMethod
    public static void informarMilestoneCasoManual(List<Id> idCasos) {
        Id entitlementId = [SELECT Id, Name FROM Entitlement WHERE Name = 'Entitlement COPS' LIMIT 1].Id;
        List<Case> casos = [SELECT Id, EntitlementId, OS_Completar_Milestones__c, OS_SLA_Completado__c FROM Case WHERE Id IN :idCasos];

        if (entitlementId != null) {
            System.debug('');
            for (Case caso : casos) {
                caso.EntitlementId = entitlementId;
                caso.OS_Completar_Milestones__c = false;

            }
            update casos;
            completarMilestones(casos, idCasos);
        }  
    }

    public static void completarMilestones(List<Case> casos, List<Id> idCasos) {
        //Completa los milestones abiertos de los casos indicados
        List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate, CaseId FROM CaseMilestone WHERE CaseId IN :idCasos AND CompletionDate = null];
        if (!milestonesEnCurso.isEmpty()) {
            milestonesEnCurso[0].CompletionDate = System.now();
            for (Case caso : casos) {
                caso.OS_SLA_Completado__c = 'Completed';
            }        
            update casos;
            update milestonesEnCurso;
        }
    }

}