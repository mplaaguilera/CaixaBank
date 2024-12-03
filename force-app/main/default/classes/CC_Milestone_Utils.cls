public with sharing class CC_Milestone_Utils {

    public static void completarMilestonesCaso(List<Id> caseIds, DateTime fechaFin) {  
        //Completa los milestones abiertos del tipo indicado (si no se indica todos)
        //para los casos indicados informando la fecha de finalización con el valor
        //del parámetro fechaFin (si no se indica es la fecha actual).

        List<CaseMilestone> cmsToUpdate = [SELECT completionDate FROM CaseMilestone
                                            WHERE caseId IN :caseIds AND completionDate = null];

        /* Podrían cerrarse solo los milestones de un tipo concreto
        List<CaseMilestone> cmsToUpdate = [select completionDate from CaseMilestone cm
                                            where caseId in :caseIds AND CM.MILESTONETYPE.NAME = :milestoneTypeName
                                              and completionDate = null]; */
        
        if (!cmsToUpdate.isEmpty()) {
            
            if (fechaFin == null) {
                fechaFin = System.now();
            }

            for (CaseMilestone cm : cmsToUpdate) {
                cm.completionDate = fechaFin;
            }

            update cmsToUpdate;
        }
    }
}