/**********************************************************************************************************************
 Name:    EV_SCHChangeStatus
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase encargada de cambiar los estados de las campañas
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION    USER_STORY      AUTHOR        DATE        Description
  1.0                           Daniel Rodriguez  23/01/2023      Init version
    1.1                             Daniel Rodriguez    08/03/2023          Modify method of creation and execute
    1.2      US567177        Daniel Rodriguez   12/04/2023        Modify method execute include status publico validado
  1.3         DE75856             Daniel Rodriguez    04/10/2023      Change class to whitout sharing and call evaluateJob from new class

***********************************************************************************************************************/

public without sharing class EV_SCHChangeStatus implements Schedulable {

    public void execute(SchedulableContext sc) {
        EV_LogDebug.printLogDebug('@@@EV_SCHChangeStatus ENTRA', String.valueof(sc));
        
        List<Campaign> cmp = new List<Campaign>();
        
        for(Campaign campaign : [   SELECT Id, EV_DiaHora_evento__c, EV_FechaHoraFin__c, EV_DiaHora_eventoAE__c, Status 
                                    FROM Campaign 
                                    WHERE Status = :Label.EV_Invitaciones_Enviadas AND EV_DiaHora_eventoAE__c <= :Datetime.now()
                                ] ) {

            EV_LogDebug.printLogDebug('@@@Invitaciones Enviadas', String.valueof(campaign));
            
            if(campaign.EV_FechaHoraFin__c <= Datetime.now()) {
                campaign.Status = Label.EV_Finalizado;
            } else {
                campaign.Status = Label.EV_Apunto_Empezar;
            }
            cmp.add(campaign);
        }

        for(Campaign campaign : [   SELECT Id, EV_DiaHora_evento__c, EV_FechaHoraFin__c, EV_DiaHora_eventoAE__c, Status
                                    FROM Campaign 
                                    WHERE Status = :Label.EV_Apunto_Empezar AND EV_DiaHora_evento__c <= :Datetime.now()
                                ] ) {

            EV_LogDebug.printLogDebug('@@@A punto de empezar', String.valueof(campaign));

            if(campaign.EV_FechaHoraFin__c <= Datetime.now()) {
                campaign.Status = Label.EV_Finalizado;
            } else {
                campaign.Status = Label.EV_En_Curso;
            }
            cmp.add(campaign);
        }

        for(Campaign campaign : [   SELECT Id, EV_DiaHora_evento__c, EV_FechaHoraFin__c, EV_DiaHora_eventoAE__c, Status
                                    FROM Campaign 
                                    WHERE Status = :Label.EV_En_Curso AND EV_FechaHoraFin__c <= :Datetime.now()
                                ] ) {

            EV_LogDebug.printLogDebug('@@@En Curso', String.valueof(campaign));

            campaign.Status = Label.EV_Finalizado;
            cmp.add(campaign);
        }
        for(Campaign campaign : [   SELECT Id, EV_DiaHora_evento__c, EV_FechaHoraFin__c, EV_DiaHora_eventoAE__c, Status
                                    FROM Campaign 
                                    WHERE Status = :Label.EV_Publico_Validado AND EV_FechaHoraFin__c <= :Datetime.now()
                                    ] ) {

            EV_LogDebug.printLogDebug('@@@Publico Validado', String.valueof(campaign));

            campaign.Status = Label.EV_Finalizado;
            cmp.add(campaign);
        }   

        EV_LogDebug.printLogDebug('@@@cmp',String.valueof(cmp));
        Database.SaveResult [] updateResult = Database.update(cmp, false);

        boolean hasError = false;
        Map<String, String> msjs = new Map<String, String>();
        List<Object> objs = new List<Object>();
        for (Integer i = 0; i < cmp.size(); i++) {
            Database.SaveResult sr = updateResult[i];
            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                msjs.put(cmp[i].Id, ((String)sr.getErrors()[0].getMessage()));
                objs.add(cmp[i]);
                hasError = true;
                EV_LogDebug.printLogDebug('EV_SCHChangeStatus ERROR', String.valueof(msjs));
            }
        }
        if(hasError) {
            CBK_Log.error(msjs, objs);
            EV_LogDebug.printLogDebug('EV_SCHChangeStatus ERROR', String.valueof(msjs));
            EV_CreateScheduleChangeStatus.evaluateJob();
        }
    }
}