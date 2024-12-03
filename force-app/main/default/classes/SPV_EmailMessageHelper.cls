public with sharing class SPV_EmailMessageHelper {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    
    /*********************************************************************
     * Proposito: Procesa los emails para copiar los datos en el campo
     * Pregunta del objeto interaccion.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US945746     Raúl Santos     23/07/24         Creación
    *********************************************************************/    
    
    public static void pegarInteraccionMessage(List<EmailMessage> mensajes){
        Map<Id,String> mapaEmail = new Map<Id, String>();
        Map<Id,String> emailSubject = new Map<Id,String>();
               
        for (EmailMessage emailCopy : mensajes) {
            mapaEmail.put(emailCopy.relatedToId,emailCopy.HtmlBody);  
            emailSubject.put(emailCopy.relatedToId, emailCopy.Subject);
        } 

        if(!mapaEmail.isEmpty() && Schema.sObjectType.SAC_Interaccion__c.isAccessible()){
            List<SAC_Interaccion__c> listaConsultas = [SELECT id,OwnerId,SAC_Pregunta__c,SAC_Estado__c, SAC_Titulo__c FROM SAC_Interaccion__c WHERE Id in : mapaEmail.keySet() AND SAC_GrupoColaborador__r.SAC_Externo__c = true];

            if(!listaConsultas.isEmpty()){

                for (SAC_Interaccion__c interaccion : listaConsultas){
                    interaccion.SAC_Estado__c = 'SAC_PendienteRespuesta';
    
                    if (String.isBlank(interaccion.SAC_Titulo__c)) {
                        interaccion.SAC_Titulo__c = emailSubject.get(interaccion.id);
                    }
    
                    if (String.isBlank(interaccion.SAC_Pregunta__c) && mapaEmail.containsKey(interaccion.id) && String.isNotBlank(mapaEmail.get(interaccion.id))) {
                        interaccion.SAC_Pregunta__c = mapaEmail.get(interaccion.id).left(32000).stripHtmlTags();
                    }
                }
                SPV_DatabaseDML.updateListDML(listaConsultas, true);
            }
        }
    }  
}