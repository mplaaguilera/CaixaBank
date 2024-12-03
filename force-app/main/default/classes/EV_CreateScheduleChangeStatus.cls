/**********************************************************************************************************************
Name:   EV_CreateScheduleChangeStatus
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Creacion de schedule para cambiar el estado de la camapaña sin sharing
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION    USER_STORY       AUTHOR              DATE              Description
1.0        DE75856          Daniel Rodriguez    04/10/2023        Init version
1.1        DE86361          Carolina Lopez      06/02/2024        Modify method createJob include call CBK_ChangeStatus_EV__e.
1.2        IN1146345        Carolina Lopez      08/04/2024        Include recordType of Festivales in the query logic.
1.3        TechSummit       Carolina Lopez      21/05/2024        Include RecordType of TechSummit.
***********************************************************************************************************************/
public without sharing class EV_CreateScheduleChangeStatus {
    static final String EV_PLACE_OF_CELEBRATION = 'Online';
    static final String ALTA_MASIVA = 'Alta masiva';
    static List<Id> jobDelete = null;
    private static EV_Utilities.SearchRT rtFisico     = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventoFisico);
    private static EV_Utilities.SearchRT rtFestival     = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_FestivalesYexperiencias);
    private static EV_Utilities.SearchRT rtVirtual    = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventoVirtual);
    private static EV_Utilities.SearchRT rtHibrido    = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventoHibrido);
    private static EV_Utilities.SearchRT rtAccionista  = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventosAccionistas);
    private static EV_Utilities.SearchRT rtCatVirtual  = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CatalogoEventoVirtual);
    private static EV_Utilities.SearchRT rtCatFisico  = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CatalogoEventoFisico);
    private static EV_Utilities.SearchRT rtCatHibrido  = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CatalogoEventoHibrido);
    private static EV_Utilities.SearchRT rtFisicoTech   = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CampTechSummitFisico);
    private static EV_Utilities.SearchRT rtVirtualTech   = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CampTechSummitVirtual);
    private static EV_Utilities.SearchRT rtHibridoTech    = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CampTechSummitHibrido);
    private static Set<Id> setRtFisico          = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtFisico});
    private static Set<Id> setRtFestival         = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtFestival});
    private static Set<Id> setRtVirtual          = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtVirtual});
    private static Set<Id> setRtHibrido          = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtHibrido});
    private static Set<Id> setRtAccionista        = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtAccionista});
    private static Set<Id> setRtCatFisico        = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtCatFisico});
    private static Set<Id> setRtCatVirtual        = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtCatVirtual});
    private static Set<Id> setRtCatHibrido        = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtCatHibrido});
    private static Set<Id> setRtFisicoTech          = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtFisicoTech});
    private static Set<Id> setRtVirtualTech          = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtVirtualTech});
    private static Set<Id> setRtHibridoTech         = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtHibridoTech});
    
         /**
   * @description       NEW Get the ID's of the RT's requested by param
   * @param setRT      List of the RT
   */
  public static Set<Id> getIdsRTN(Set<EV_Utilities.SearchRT> setRT){
    return EV_Utilities.getRecordTypeIdsInSet(setRT);
  }
    
        /**
    * @description       Creation schedule changestatus
    * @param listNews    New Campaign
    * @param oldMapCampaign Old Campaign
    */
    public static void creationSchedule(List<Campaign> listNews,Map<Id, Campaign> oldMapCampaign) {
        if(EV_Bypass__c.getOrgDefaults() != null && EV_Bypass__c.getOrgDefaults().EV_ChangeStatus__c == true){
            return;
        }
        
        EV_LogDebug.printLogDebug('creationSchedule', 'creationSchedule');
        
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        setIdsRts.addAll(setRtFestival);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        Set<String> setStatusEntry= new Set<String>{Label.EV_Invitaciones_Enviadas, Label.EV_Apunto_Empezar, Label.EV_En_Curso, Label.EV_Finalizado, Label.EV_Publico_Validado};
            
            List<Campaign> listCampaign = new List<Campaign>();
        for(Campaign c : listNews) {
            if((setIdsRts).contains(c.RecordTypeId) && ((oldMapCampaign != null && c.Status != oldMapCampaign.get(c.Id).Status && setStatusEntry.contains(c.Status)) || (oldMapCampaign != null && (c.EV_DiaHora_evento__c != oldMapCampaign.get(c.Id).EV_DiaHora_evento__c || c.EV_FechaHoraFin__c != oldMapCampaign.get(c.Id).EV_FechaHoraFin__c)) && setStatusEntry.contains(c.Status))){
                listCampaign.add(c);
            }
        }
        
        if(!listCampaign.isEmpty()) {
            evaluateJob();
        }
    }
    
    public static void evaluateJob() {
        EV_LogDebug.printLogDebug('evaluateJob', 'evaluateJob');
        
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        setIdsRts.addAll(setRtFestival);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);

        Set<String> setStatusToStart = new Set<String>{Label.EV_Invitaciones_Enviadas, Label.EV_Apunto_Empezar};
            
            List<Campaign> iEChange = [  SELECT Id, EV_DiaHora_eventoAE__c, EV_DiaHora_evento__c, EV_FechaHoraFin__c, Status
                                       FROM Campaign 
                                       WHERE   RecordtypeId in :setIdsRts 
                                       AND (
                                           (Status = :Label.EV_Apunto_Empezar AND EV_DiaHora_evento__c >= :Datetime.now())
                                           OR
                                           (Status = :Label.EV_Invitaciones_Enviadas AND ((EV_DiaHora_eventoAE__c <= :Datetime.now() AND EV_DiaHora_evento__c >= :Datetime.now()) OR EV_DiaHora_eventoAE__c >= :Datetime.now()))
                                           OR
                                           (Status = :Label.EV_Publico_Validado AND EV_FechaHoraFin__c <= :Datetime.now())
                                       )];
        
        List<Campaign> finishChange = [  SELECT Id, EV_DiaHora_eventoAE__c, EV_DiaHora_evento__c, EV_FechaHoraFin__c, Status
                                       FROM Campaign 
                                       WHERE EV_FechaHoraFin__c >= :Datetime.now() AND RecordtypeId in :setIdsRts AND Status = :Label.EV_En_Curso ORDER BY EV_FechaHoraFin__c ASC LIMIT 1];
        
        
        Campaign camp = null;
        if(!iEChange.isEmpty()) {
            List<CampaignSortable> sortable = new List<CampaignSortable>();
            for(Campaign c : iEChange) {
                EV_LogDebug.printLogDebug('campaña', c.Id + ' ' + c.Status + ' ' + c.EV_DiaHora_eventoAE__c + ' ' + c.EV_DiaHora_evento__c + ' ' + c.EV_FechaHoraFin__c);
                
                sortable.add(new CampaignSortable(c));
            }
            sortable.sort();
            camp = sortable.get(0).campaign;
        }
        
        for(Campaign c : finishChange) {
            EV_LogDebug.printLogDebug('campaña fin', c.Id + ' ' + c.Status + ' ' + c.EV_DiaHora_eventoAE__c + ' ' + c.EV_DiaHora_evento__c + ' ' + c.EV_FechaHoraFin__c);
        }
        
        Datetime fechaProxEje = null;
        if(camp != null) {
            if(camp.Status == Label.EV_Invitaciones_Enviadas) {
                if((camp.EV_DiaHora_eventoAE__c <= Datetime.now() && camp.EV_DiaHora_evento__c >= Datetime.now())) {
                    fechaProxEje = Datetime.now().addMinutes(+1);
                } else if(camp.EV_DiaHora_eventoAE__c > Datetime.now()) {
                    fechaProxEje = camp.EV_DiaHora_eventoAE__c;
                }
            } else if(camp.Status == Label.EV_Apunto_Empezar && camp.EV_DiaHora_evento__c > Datetime.now()) {
                fechaProxEje = camp.EV_DiaHora_evento__c;
            }else if(camp.Status == Label.EV_Publico_Validado && camp.EV_FechaHoraFin__c <= Datetime.now()){
                fechaProxEje = Datetime.now().addMinutes(+1);
            }
        }
        
        if(!finishChange.isEmpty()) {
            if((fechaProxEje == null && finishChange[0].EV_FechaHoraFin__c > Datetime.now()) || (fechaProxEje != null && finishChange[0].EV_FechaHoraFin__c < fechaProxEje)) {
                fechaProxEje = finishChange[0].EV_FechaHoraFin__c;
            }
        }
        
        EV_LogDebug.printLogDebug('fechaProxEje', String.valueOf(fechaProxEje));
        
        if(fechaProxEje != null) {
            createJob(fechaProxEje);
        }
    }
    
    public class CampaignSortable implements Comparable {
        
        public Campaign campaign;
        
        public CampaignSortable(Campaign campaign) {
            this.campaign = campaign;
        }
        
        public Integer compareTo(Object compareTo) {
            CampaignSortable other = (CampaignSortable)compareTo;
            
            if(this.campaign.Status == Label.EV_Invitaciones_Enviadas && other.campaign.Status == Label.EV_Invitaciones_Enviadas) {
                if(this.campaign.EV_DiaHora_eventoAE__c < other.campaign.EV_DiaHora_eventoAE__c) {
                    return -1;
                } else {
                    return 1;
                }
            } else if(this.campaign.Status == Label.EV_Invitaciones_Enviadas && other.campaign.Status == Label.EV_Apunto_Empezar) {
                if(this.campaign.EV_DiaHora_eventoAE__c < other.campaign.EV_DiaHora_evento__c) {
                    return -1;
                } else {
                    return 1;
                }
            } else if(this.campaign.Status == Label.EV_Apunto_Empezar && other.campaign.Status == Label.EV_Invitaciones_Enviadas) {
                if(this.campaign.EV_DiaHora_evento__c < other.campaign.EV_DiaHora_eventoAE__c) {
                    return -1;
                } else {
                    return 1;
                }
            } else if(this.campaign.Status == Label.EV_Apunto_Empezar && other.campaign.Status == Label.EV_Apunto_Empezar) {
                if(this.campaign.EV_DiaHora_evento__c < other.campaign.EV_DiaHora_evento__c) {
                    return -1;
                } else {
                    return 1;
                }
            } 
            
            return 0;
        }
        
    }
    
    /**
* @description     Create job
* @param jobName      name of job
*/
    public static void createJob(DateTime fechaProxEje) {
        EV_LogDebug.printLogDebug('@@EV_CreateScheduleChangeStatus ', 'createJob');
        String schedule = '0 ' + fechaProxEje.minute() + ' ' + fechaProxEje.hour() + ' ' + fechaProxEje.day() + ' ' + fechaProxEje.month() + ' ?' + ' ' + fechaProxEje.year();
        EV_ChangeStatus__e eventsche = new EV_ChangeStatus__e(
                EV_ScheduledTime__c = schedule,
                EV_ExecutionDate__c = fechaProxEje
            );
        Database.SaveResult sr = EventBus.publish(eventsche);
        if (!sr.isSuccess()) {
            for(Database.Error err : sr.getErrors()) {
                EV_LogDebug.printLogDebug('Error returned: ' , err.getMessage());
            }
        }
    }
}