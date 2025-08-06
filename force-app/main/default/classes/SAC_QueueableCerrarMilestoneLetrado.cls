/*****************************************************************************************
 * Name: SAC_QueueableCerrarMilestoneLetrado
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Updatea los milestone del caso cerrándolos cuando se pasa de alta a baja
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0             DE101079     Sergio Martín     05/09/2024       Creación
*****************************************************************************************/
public with sharing class SAC_QueueableCerrarMilestoneLetrado implements Queueable{

    private static final String BRACKET_LEFT        = '(';
    private static final String BRACKET_RIGHT       = ') ';
    private static final String BRACKET_RIGHT_ERROR = ') Error: ';

    List<Case> listaReclamaciones;

    public SAC_QueueableCerrarMilestoneLetrado(List<Case> listaReclamacionesC) {
        listaReclamaciones = listaReclamacionesC;
    }

    public void execute(QueueableContext context) {
        System.debug('Entra en execute');
        List<Id> listaIdsCase = new List<Id>();
        for (Case caso : listaReclamaciones) {
            listaIdsCase.add(caso.Id);
        }

        List<CaseMilestone> listamilestones = [SELECT caseid, startdate, IsCompleted, CompletionDate FROM CaseMilestone WHERE CaseId IN :listaIdsCase];

        for (CaseMilestone milestone : listamilestones) {
            milestone.CompletionDate = system.now();
        }

        String methodName = 'execute';

        Database.SaveResult[] srList = Database.update(listamilestones, false);
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) { print(LoggingLevel.ERROR, methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage(), true); print(LoggingLevel.ERROR, methodName, '----ERR fields: ' + err.getFields(), true); }
            }
        }
    }

    @TestVisible
    private static void print(LoggingLevel level, String methodName, String msg, boolean isError){
        if (msg!=null && msg.length()<6000000) {
            String msgError = BRACKET_LEFT + methodName + (isError ? BRACKET_RIGHT_ERROR : BRACKET_RIGHT) + msg;
            CBK_Log.error(msgError);
        }
    }
}