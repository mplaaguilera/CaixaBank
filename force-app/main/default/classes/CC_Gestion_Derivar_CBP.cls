public with sharing class CC_Gestion_Derivar_CBP {

    @AuraEnabled
    public static void emailResponderClienteCBP(Case caso, String grupoCol, String nombrePlantilla, Map<String, String> parametrizacionesMensaje, String nameOWA){
        
        List<Case> casos = [SELECT Id, Subject, ContactId, AccountId, OwnerId FROM Case WHERE Id = :caso.Id LIMIT 1];

        List<String> grupos = new List<String>{grupoCol};
        Map<String, List<String>> emailGrupoCol = CC_Gestion_Derivar_Emails_Auto.sendEmailGrupoCol(grupos);
        if(emailGrupoCol == null || emailGrupoCol.isEmpty()) {
            throw new AuraHandledException('No se encontraron emails para el grupo colaborador.');
        }
        
        /*CC_Gestion_Derivar_Emails_Auto.createEmail(
            casos[0],
            emailGrupoCol,
            null,
            null,
            nombrePlantilla,
            grupoCol,
            parametrizacionesMensaje,
            nameOWA
        );*/
    }
}