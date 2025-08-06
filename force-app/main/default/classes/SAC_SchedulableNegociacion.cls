/***********************************************************************
 * Name: SAC_SchedulableNegociacion
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Clase que mediante los pendingProcess (framework schedulable) comprueba si las reclamaciones llevan en estado negociación más de 45 días.
 * Si llevan más de 45 días, crea una alerta.
 * Esta clase se lanza mediante el registro de pending process que se crea al cambiar de estado la reclamación y ponerla en negociación (se lanza para que lo revise
 * a los 45 días).
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US418231         CS             05/09/2022   Creación
 * 1.1            --             Raúl Santos      25/09/24     Modirficación: alertas para la negociación de SPV
*************************************************************************/
public without sharing class SAC_SchedulableNegociacion extends CBK_SCH_Queueable_Abstract{
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> LstInfoPp = this.lstInfoProcess;
        work(LstInfoPp);
    }

    @TestVisible
    private void work(List<CBK_SCH_PendingProcess__c> LstInfoPp) {

        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Id recTypeReclamacionSPV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();

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
                                SAC_PretensionPrincipal__r.OwnerId, SAC_Reclamacion__r.OwnerId, SEG_Subestado__c
                                FROM Case 
                                WHERE (RecordTypeId = :recTypeReclamacion OR RecordTypeId = :recTypePretension OR RecordTypeId = :recTypeReclamacionSPV) AND Id IN :setIdsCasos];

        //Nos quedamos con las ids de las reclamaciones que están en negociación ya que si ya han salido de ese estado, no tendremos que hacer nada. Añadida la negociación de SPV
        for (Case caso : listaCasos) {
            if ((caso.RecordTypeId == recTypeReclamacion && caso.Status == 'SAC_007') || (caso.RecordTypeId == recTypeReclamacionSPV && caso.SEG_Subestado__c == 'Negociacion')) {
                setIdsParaHistorial.add(caso.Id);
                mapaCasos.put(caso.Id, caso);
            }
        }

        //Si alguna de las reclamaciones está en negociación, se busca su historico para comprobar si lleva 45 días allí
        if (!setIdsParaHistorial.isEmpty()) {List<CaseHistory> historial = [SELECT id, NewValue, OldValue, CreatedDate, CaseId FROM CaseHistory WHERE CaseId IN :setIdsParaHistorial AND (Field = 'Status' OR Field = 'SEG_Subestado__c') ORDER BY CreatedDate DESC]; /*setIdsCasos*/Map<Id, List<CaseHistory>> mapaCasoHistory = new Map<Id, List<CaseHistory>>();if (!historial.isEmpty()) {for (CaseHistory recPretHistory : historial) {if (mapaCasoHistory.containsKey(recPretHistory.CaseId)) {mapaCasoHistory.get(recPretHistory.CaseId).add(recPretHistory);} else {List<CaseHistory> listaHistoria = new List<CaseHistory>();listaHistoria.add(recPretHistory);mapaCasoHistory.put(recPretHistory.CaseId, listaHistoria);}}      Map<Id, CaseHistory> mapaCasoHistoriaFinal = new Map<Id, CaseHistory>();for (Id ideCaso : mapaCasoHistory.keySet()) {for (CaseHistory historia : mapaCasoHistory.get(ideCaso)) {if (mapaCasoHistoriaFinal.containsKey(ideCaso)) {if (mapaCasoHistoriaFinal.get(ideCaso).CreatedDate < historia.CreatedDate) {mapaCasoHistoriaFinal.put(ideCaso, historia);}} else {mapaCasoHistoriaFinal.put(ideCaso, historia);}}}for (Id ideCaso : mapaCasoHistoriaFinal.keySet()) {if (mapaCasoHistoriaFinal.get(ideCaso).CreatedDate.date().daysBetween(system.today()) >= 45 && mapaCasos.get(ideCaso).RecordTypeId != recTypeReclamacionSPV) {               if (mapaCasos.get(ideCaso).RecordTypeId == recTypeReclamacion) {                 SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(ideCaso,'SAC_019','La reclamación ' + mapaCasos.get(ideCaso).CaseNumber + ', que está en Negociación, lleva 45 días sin evidencia de contacto exitoso con el reclamante. ' +                                                     'Valore el cierre del proceso de negociación o resolución de la reclamación para no incumplir con el SLA.', mapaCasos.get(ideCaso).OwnerId, '', '', '');                                             wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ideCaso;            if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Let' && String.isNotBlank(mapaCasos.get(ideCaso).SAC_PretensionPrincipal__r.OwnerId)) {                  wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).SAC_PretensionPrincipal__r.OwnerId;           } else if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Ges' && String.isNotBlank(mapaCasos.get(ideCaso).OwnerId)) {               wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).OwnerId;         }      listaWrapperAlerta.add(wrapAlerta);} else if (mapaCasos.get(ideCaso).RecordTypeId == recTypePretension) {SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(mapaCasos.get(ideCaso).SAC_Reclamacion__c,'SAC_019', 'La pretensión ' + mapaCasos.get(ideCaso).CaseNumber + ', que está en Negociación, lleva 45 días sin evidencia de contacto exitoso con el reclamante. ' +     'Valore el cierre del proceso de negociación o resolución de la pretensión para no incumplir con el SLA.', mapaCasos.get(ideCaso).OwnerId, ideCaso,'',''); wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ideCaso;if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Ges' && String.isNotBlank(mapaCasos.get(ideCaso).SAC_Reclamacion__r.OwnerId)) {wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).SAC_Reclamacion__r.OwnerId;}  else if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Let' && String.isNotBlank(mapaCasos.get(ideCaso).OwnerId)) { wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).OwnerId;}listaWrapperAlerta.add(wrapAlerta);}}else if(mapaCasos.get(ideCaso).RecordTypeId == recTypeReclamacionSPV && mapaCasoHistoriaFinal.get(ideCaso).CreatedDate.date().daysBetween(system.today()) >= 7){SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(ideCaso,'SPV_015','La reclamación ' + mapaCasos.get(ideCaso).CaseNumber + ', que está en Negociación, lleva 7 días sin evidencia de contacto exitoso con el reclamante. ' +'Valore el cierre del proceso de negociación de la reclamación para no incumplir con el SLA.', mapaCasos.get(ideCaso).OwnerId, '', '', '');wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ideCaso;wrapAlerta.proyecto = 'SPV';if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Let' && String.isNotBlank(mapaCasos.get(ideCaso).SAC_PretensionPrincipal__r.OwnerId)) {   wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).SAC_PretensionPrincipal__r.OwnerId;   } else if (String.isNotBlank(mapaCasos.get(ideCaso).CC_SuppliedUser__c) && mapaCasos.get(ideCaso).CC_SuppliedUser__c == 'Ges' && String.isNotBlank(mapaCasos.get(ideCaso).OwnerId)) {   wrapAlerta.idUsuarioDestinatario = mapaCasos.get(ideCaso).OwnerId;  }   listaWrapperAlerta.add(wrapAlerta); }   }   }   if (!listaWrapperAlerta.isEmpty()) {    SAC_Alertas.generarAlertas(listaWrapperAlerta); }   }   }}