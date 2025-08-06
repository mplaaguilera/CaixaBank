public with sharing class CC_Gestion_Derivar_Col_Vulnerable {
    @AuraEnabled
    public static Map<String, Object> crearTareaColectivosVulnerables(String recordId, String asunto, String fechaActividad, Boolean crearTareaCitaGestor, Id oficinaDestino, Boolean enviarTareaOficinaCliente, Contact gestorSeleccionadoBuscador, Boolean otpDerivar, String comentarios) {

        Case caso = [SELECT Id, Subject, Account.AV_EAPGestor__r.AV_Pool__c, OwnerId, ContactId, Contact.AccountId, 
        Account.AV_EAPGestor__r.OwnerId, Account.AV_EAPGestor__r.CC_Numero_Oficina__c, Account.AV_OfficeManager__c, Origin,
        CBK_Case_Extension_Id__c
        FROM Case 
        WHERE Id = :recordId 
        LIMIT 1];
      
       Map<String, Object> retorno = new Map<String, Object>();
       Map<String, Object> datos = new Map<String, Object>();
       datos.put('recordId', recordId);
       datos.put('asunto', asunto);
       datos.put('fechaActividad', fechaActividad);
       datos.put('crearTareaCitaGestor', crearTareaCitaGestor);
       datos.put('oficinaDestino', oficinaDestino);
       datos.put('enviarTareaOficinaCliente', enviarTareaOficinaCliente);
       datos.put('gestorSeleccionadoBuscador', gestorSeleccionadoBuscador);
       datos.put('otpDerivar', otpDerivar);
       datos.put('comentarios', comentarios);

       CC_Gestion_Derivar_Tarea gestionDerivarTarea = new CC_Gestion_Derivar_Tarea(datos);
       retorno = gestionDerivarTarea.crearTarea();

       return retorno;
    }

    @AuraEnabled
    public static void emailRemitirColaboradorColectivoVulnerable(Case caso, String grupoCol, String nombrePlantilla, Map<String, String> parametrizacionesMensaje, String nameOWA){
        
        List<Case> casos = [SELECT Id, Subject, ContactId, AccountId, OwnerId FROM Case WHERE Id = :caso.Id LIMIT 1];

        List<String> grupos = new List<String>{grupoCol};
        String[] emailGrupoCol = CC_Gestion_Derivar_Emails_Auto.sendEmailGrupoCol(grupos);
        if(emailGrupoCol == null || emailGrupoCol.isEmpty()) {
            throw new AuraHandledException('No se encontraron emails para el grupo colaborador.');
        }
        
        CC_Gestion_Derivar_Emails_Auto.createEmail(
            casos[0],
            emailGrupoCol,
            null,
            null,
            nombrePlantilla,
            grupoCol,
            parametrizacionesMensaje,
            nameOWA
            
        );
    }

}