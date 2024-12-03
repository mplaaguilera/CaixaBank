/**
 * @description Clase especial para llevar a cabo actualizaciones sobre los casos de Valija.
 * Permite evitar la creación de sharing rules para realizar una actualización mínima de campos del caso.
 */
public without sharing class SEG_wsValijaCasosComunesNoSharing {

    /**
     * @description Método para actualizar los datos de un caso, dentro del proceso Queueable de traslado a Colaborador.
     * @param caseObject Objeto case que se va a actualizar
     */
    public static void actualizarCaseQueueable (Case caseObject)
    {
        if (caseObject != null)
        {
            update caseObject;
        }
    }

    /**
     * @description Método para actualizar los datos de los ficheros enviados a Valija, dentro del proceso Queueable de traslado a Colaborador.
     * El usuario ya no tiene asignado el caso y puede no tener acceso en escritura.
     */
    public static void actualizarFilesQueueable (List<ContentVersion> listFiles)
    {
        if (listFiles != null && !listFiles.isEmpty())
        {
            update listFiles;
        }
    }

    /**
     * @description Método para recuperar la información de un caso en los procesos de Valija.
     * @param identificadorCaso Identificador del caso
     * @param lockCase Marca para bloquear el registro del caso.
     * @return Objeto con los datos del caso residente en Salesforce.
     */
    public static Case recuperarInformacionCaso (String identificadorCaso, Boolean lockCase)
    {
        Case casoEncontrado;

        if (String.isNotBlank(identificadorCaso))
        {
            if (lockCase == null || !lockCase)
            {
                List<Case> listadoCasos = [SELECT Id, OS_Referencia_Valija__c, SEG_RecepcionFicherosPaqueteria__c, SEG_EstadoTrasladoValija__c, AccountId, ContactId, SEG_Organizacion__c, 
                                            SEG_Zona__c, CC_Idioma__c, SEG_Fecha_valor__c, Status, SEG_Subestado__c, SEG_Resultado__c, Origin, SEG_RefSalienteValija__c, SEG_creacionPAK__c,
                                            SEG_N_operaciones_del_caso__c, CC_MCC_Motivo__c,SEG_N_operaciones_CSO__c
                                            FROM Case
                                            WHERE Id = :identificadorCaso
                                            AND RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')];
                if (!listadoCasos.isEmpty())
                {
                    casoEncontrado = listadoCasos[0];
                }
            }else{
                List<Case> listadoCasos = [SELECT Id, OS_Referencia_Valija__c, SEG_RecepcionFicherosPaqueteria__c, SEG_EstadoTrasladoValija__c, AccountId, ContactId, SEG_Organizacion__c, 
                                            SEG_Zona__c, CC_Idioma__c, SEG_Fecha_valor__c, Status, SEG_Subestado__c, SEG_Resultado__c, Origin, SEG_RefSalienteValija__c, SEG_creacionPAK__c,
                                            SEG_N_operaciones_del_caso__c, CC_MCC_Motivo__c,SEG_N_operaciones_CSO__c
                                            FROM Case
                                            WHERE Id = :identificadorCaso
                                            AND RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')
                                            FOR UPDATE];
                if (!listadoCasos.isEmpty())
                {
                    casoEncontrado = listadoCasos[0];
                }
            }
        }

        return casoEncontrado;
    }
}