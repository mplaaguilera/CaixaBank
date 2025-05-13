public without sharing class HDT_Case_Axiliar_Masivas {

    public static List<EmailMessage> hasRecentEmail(String emailType,DateTime limiteMinutos) {
        // Consulta para verificar correos recientes
        List<EmailMessage> recentEmails = [
            SELECT Id 
            FROM EmailMessage 
            WHERE SAC_EnvioRedaccion__c = :emailType 
            AND CreatedDate >= :limiteMinutos LIMIT 1
        ];

         // Devolver la lista de correos recientes
        return recentEmails;
    }

}