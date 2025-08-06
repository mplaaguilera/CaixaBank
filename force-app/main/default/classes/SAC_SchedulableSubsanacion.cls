/***********************************************************************
 * Name: SAC_SchedulableSubsanacion
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Clase que mediante los pendingProcess (framework schedulable) comprueba si las reclamaciones llevan en estado subsanación más de 10 días.
 * Si llevan más de 10 días, crea una alerta.
 * Esta clase se lanza mediante el registro de pending process que se crea al cambiar de estado la reclamación y ponerla en subsanación (se lanza para que lo revise
 * a los 10 días).
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US418231         CS             06/09/2022   Creación
*************************************************************************/
public without sharing class SAC_SchedulableSubsanacion extends CBK_SCH_Queueable_Abstract{
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> LstInfoPp = this.lstInfoProcess;
        work(LstInfoPp);
    }

    @TestVisible
    private void work(List<CBK_SCH_PendingProcess__c> LstInfoPp) {
        //System.debug('SAC_SchedulableSubsanacion - LstInfoPp - Input list: ' + JSON.serialize(LstInfoPp));

        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        Set<Id> setIdsCasos = new Set<Id>();
        Set<Id> setIdsParaHistorial = new Set<Id>();
        Map<Id, Case> mapaCasos = new Map<Id, Case>();

        //Recorrer los pending process para sacar las ids de las reclamaciones y asi poder recuperarlas
        for (CBK_SCH_PendingProcess__c pendingProcessRec : LstInfoPp) {
            setIdsCasos.add(pendingProcessRec.recordId__c);
        }

        //Recuperar las reclamaciones
        List<Case> listaCasos = [SELECT Id, OwnerId, Status, RecordTypeId, CaseNumber, SAC_Reclamacion__c, CC_SuppliedUser__c,
                                SAC_PretensionPrincipal__r.OwnerId, SAC_Reclamacion__r.OwnerId
                                FROM Case 
                                WHERE (RecordTypeId = :recTypeReclamacion OR RecordTypeId = :recTypePretension) AND Id IN :setIdsCasos];

        //Nos quedamos con las ids de las reclamaciones que están en subsanación ya que si ya han salido de ese estado, no tendremos que hacer nada
        for (Case caso : listaCasos) {
            if (caso.Status == 'SAC_006') {
                setIdsParaHistorial.add(caso.Id);
                mapaCasos.put(caso.Id, caso);
            }
        }//Si alguna de las reclamaciones está en subsanación, se busca su historico para comprobar si lleva 10 días allí
        if (!setIdsParaHistorial.isEmpty()) {            List<CaseHistory> historial = [SELECT id, NewValue, OldValue, CreatedDate, CaseId FROM CaseHistory WHERE CaseId IN :setIdsCasos AND Field = 'Status' ORDER BY CreatedDate DESC];                                    Map<Id, List<CaseHistory>> mapaCasoHistory = new Map<Id, List<CaseHistory>>();          if (!historial.isEmpty()) {                for (CaseHistory recPretHistory : historial) {                                        if (mapaCasoHistory.containsKey(recPretHistory.CaseId)) {                       mapaCasoHistory.get(recPretHistory.CaseId).add(recPretHistory);                    } else {                         List<CaseHistory> listaHistoria = new List<CaseHistory>();                        listaHistoria.add(recPretHistory);                        mapaCasoHistory.put(recPretHistory.CaseId, listaHistoria);                    }                }                                Map<Id, CaseHistory> mapaCasoHistoriaFinal = new Map<Id, CaseHistory>();                for (Id ideCaso : mapaCasoHistory.keySet()) {                    for (CaseHistory historia : mapaCasoHistory.get(ideCaso)) {                        if (mapaCasoHistoriaFinal.containsKey(ideCaso)) {                            if (mapaCasoHistoriaFinal.get(ideCaso).CreatedDate < historia.CreatedDate) {                                mapaCasoHistoriaFinal.put(ideCaso, historia);                            }                        } else {                            mapaCasoHistoriaFinal.put(ideCaso, historia);                        }                    }                }                                for (Id ideCaso : mapaCasoHistoriaFinal.keySet()) {                                          if (mapaCasoHistoriaFinal.get(ideCaso).CreatedDate.date().daysBetween(system.today()) >= 10) {                        if (mapaCasos.get(ideCaso).RecordTypeId == recTypeReclamacion) {                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(ideCaso,                                                                                'SAC_020',                                                                                'La reclamación ' + mapaCasos.get(ideCaso).CaseNumber + ', lleva 10 días en estado de subsanación. Por favor revisela.',                                                                                mapaCasos.get(ideCaso).OwnerId,                                                                                '',                                                                                '',                                                                                '');                                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ideCaso;                                                        if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Let' && String.isNotBlank(mapaCasos.get(ideCaso).SAC_PretensionPrincipal__r.OwnerId)) {                                wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).SAC_PretensionPrincipal__r.OwnerId;                            } else if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Ges' && String.isNotBlank(mapaCasos.get(ideCaso).OwnerId)) {                               wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).OwnerId;                            }                                                      listaWrapperAlerta.add(wrapAlerta);                    } else if (mapaCasos.get(ideCaso).RecordTypeId == recTypePretension) {                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(mapaCasos.get(ideCaso).SAC_Reclamacion__c,                                                                                'SAC_020',                                                                                'La pretensión ' + mapaCasos.get(ideCaso).CaseNumber + ', lleva 10 días en estado de subsanación. Por favor revisela.',                                                                                mapaCasos.get(ideCaso).OwnerId,                                                                                ideCaso,                                                                                '',                                                                                '');                                                                               wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ideCaso;                                                        if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Ges' && String.isNotBlank(mapaCasos.get(ideCaso).SAC_Reclamacion__r.OwnerId)) {                               wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).SAC_Reclamacion__r.OwnerId;                            }  else if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Let' && String.isNotBlank(mapaCasos.get(ideCaso).OwnerId)) {                                wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).OwnerId;                            }                                                      listaWrapperAlerta.add(wrapAlerta);                         }                    }                }            }                        if (!listaWrapperAlerta.isEmpty()) {        SAC_Alertas.generarAlertas(listaWrapperAlerta);            }        }    }}