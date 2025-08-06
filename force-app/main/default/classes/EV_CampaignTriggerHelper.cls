/**********************************************************************************************************************
 Name:   EV_CampaignTriggerHelper
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Before Insert sobre el objeto Campaign
-----------------------------------------------------------------------------------------------------------------------
Historial
------------------
  VERSION    USER_STORY      	AUTHOR        		DATE        		Description
  1.0                          	Eric Vázquez    	23/03/2021      	Init version
  1.1         	US388331        Daniel Rodriguez    22/06/2022          Modify method changestatus and create methods createRecordSchProcess and dmloperations
  1.2         	US120478        Daniel Rodriguez    10/07/2022          Add Ev_centroPromotor to method fillCarteraParent
  1.3							Daniel Rodriguez	20/01/2023			Modify error validateEventToTranslations, updateCarteraPO. Add Method cambioStatusEncursoFinalizado to EV_Campaign_BU_TRHan. Modify validatePublicForEvent to all Traducciones, setCampaignMemberRecordTypeId to EV_Campaign_BI_TRHan
																		Add generarIdSeguro, generarTraduccionesEventoHijo, createCriteriosPO, crearCampaignEstados to EV_Campaign_AI_TRHan
  1.4		  	Fix IOP ex	  	Daniel Rodriguez 	20/02/2023			Modify method changeStatus, create method creationJobProgram, deleteJobProgram to Fix IOP
  1.5			US555430		Daniel Rodriguez 	14/03/2023			delete method changeStatus, creationJobProgram, deleteJobProgram. Create method creationSchedule, CampaignSortable, createJob
  1.6			US567177		Daniel Rodriguez 	12/04/2023			Modify method creationSchedule include status publico validado
  1.7 			US587001		Daniel Rodriguez	23/05/2023			Create method surveyActive
  1.8			US586998		Daniel Rodriguez	15/06/2023			Create method updateRollUpEventChangeStatus 
  1.9			US585725		Carolina Lopez 		25/08/2023			Modify method fillCarteraParent
  2.0		    US585725		Daniel Rodriguez	29/08/2023			Modify optimized method newFlowAC, creationSchedule, evaluateJob, validateEventToTranslations, fillPlaceOfCelebration, fillCarteraParent, validatePublicForEvent, cambioStatusEncursoFinalizado, generarTraduccionesEventoHijo, crearCampaignEstados, setCampaignMemberRecordTypeId
																		surveyActive and created call method to getIdsRTN
  2.1			US624265		Daniel Rodriguez	26/09/2023          Modify method newFlowAC, creationSchedule, evaluateJob, validateEventToTranslations, fillPlaceOfCelebration, fillCarteraParent, validatePublicForEvent, cambioStatusEncursoFinalizado, setCampaignMemberRecordTypeId
																		surveyActive, sharecampaign, updateRollUpEventChangeStatus to add new RT EV_FestivalesYexperiencias in methods
  2.2           DE75856         Daniel Rodriguez    04/10/2023          Remove method creationSchedule, evaluateJob to new class EV_CreateScheduleChangeStatus whith whithout sharing                                   
  2.3           DE75856         Carolina Lopez      05/10/2023          Modify method sharingCampaignApex
  2.4           US585725        Mamen Arias         06/10/2023          Modify method crearCampaignEstados adding spanish language to CM label
  2.5           DE88146         Carolina Lopez      28/11/2023          Modify error condition in method validateEventToTranslations. 
  2.6           US854993        Carolina Lopez      09/04/2024          Create method visiblePortalInformation.
  2.7           FIX             Carolina Lopez      07/05/2024          Delete WITH SECURITY_ENFORCED.
  2.8           TechSummit      Carolina Lopez      14/05/2024          Add new RecordType TechSummit (EV_CampTechSummitFisico,EV_CampTechSummitVirtual, EV_CampTechSummitHibrido) in all methods new architecture, create method setTechSummitCampaign.
  2.9           FIX             Carolina Lopez      12/07/2024          Modify logic method updateRollUpEventChangeStatus.
  3.0           IN1191612       Manuel Ramos        15/07/2024          Modify method generarTraduccionesEventoHijo.
  ***********************************************************************************************************************/
public with sharing class EV_CampaignTriggerHelper {
	static final String EV_PLACE_OF_CELEBRATION = 'Online';
    static final String ALTA_MASIVA = 'Alta masiva';
	static List<Id> jobDelete = null;
    private static EV_Utilities.SearchRT rtFisico 		= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventoFisico);
	private static EV_Utilities.SearchRT rtVirtual		= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventoVirtual);
    private static EV_Utilities.SearchRT rtHibrido		= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventoHibrido);
    private static EV_Utilities.SearchRT rtAccionista	= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_EventosAccionistas);
    private static EV_Utilities.SearchRT rtCatVirtual	= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CatalogoEventoVirtual);
    private static EV_Utilities.SearchRT rtCatFisico	= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CatalogoEventoFisico);
    private static EV_Utilities.SearchRT rtCatHibrido	= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CatalogoEventoHibrido);
    private static EV_Utilities.SearchRT rtFestivalesEx	= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_FestivalesYexperiencias);
    private static EV_Utilities.SearchRT rtFisicoTech   = new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CampTechSummitFisico);
    private static EV_Utilities.SearchRT rtVirtualTech	= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CampTechSummitVirtual);
    private static EV_Utilities.SearchRT rtHibridoTech	= new EV_Utilities.SearchRT(EV_Utilities.OBJECT_NAME_CAMPAIGN, Label.EV_CampTechSummitHibrido);
	private static Set<Id> setRtFisico					= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtFisico});
	private static Set<Id> setRtVirtual					= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtVirtual});
    private static Set<Id> setRtHibrido					= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtHibrido});
    private static Set<Id> setRtAccionista				= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtAccionista});
    private static Set<Id> setRtCatFisico				= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtCatFisico});
    private static Set<Id> setRtCatVirtual				= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtCatVirtual});
    private static Set<Id> setRtCatHibrido				= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtCatHibrido});
    private static Set<Id> setRtFestivales				= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtFestivalesEx});
    private static Set<Id> setRtFisicoTech			    = getIdsRTN(new Set<EV_Utilities.SearchRT>{rtFisicoTech});
    private static Set<Id> setRtVirtualTech				= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtVirtualTech});
    private static Set<Id> setRtHibridoTech				= getIdsRTN(new Set<EV_Utilities.SearchRT>{rtHibridoTech});
    private static Id rtEventoVirtual                   = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventoVirtual).getRecordTypeId();
    private static Id rtEventoHibrido                   = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventoHibrido).getRecordTypeId();
    private static Id rtEventoAccionista                = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventosAccionistas).getRecordTypeId();
    private static Id rtFestivales                      = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_FestivalesYexperiencias).getRecordTypeId();
    private static Id rtEventoFisico                    = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventoFisico).getRecordTypeId();
    private static Id rtEventoCatVirtual                = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_CatalogoEventoVirtual).getRecordTypeId();
    private static Id rtEventoCatFisico                 = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_CatalogoEventoFisico).getRecordTypeId();
    private static Id rtEventoCatHibrido                = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_CatalogoEventoHibrido).getRecordTypeId();
    private static Id rtEventoFisicoTechSummit         = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_CampTechSummitFisico).getRecordTypeId();
    private static Id rtEventoVirtualTechSummit         = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_CampTechSummitVirtual).getRecordTypeId();
    private static Id rtEventoHibridoTechSummit         = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_CampTechSummitHibrido).getRecordTypeId();

  
	/**
	* @description       Get the ID's of the RT's requested by param
	* @param setRT      List of the RT
	*/
	public static Set<Id> getIdsRT(Set<String> setRT){
	  return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
    
    	/**
	 * @description		 	NEW Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRTN(Set<EV_Utilities.SearchRT> setRT){
		return EV_Utilities.getRecordTypeIdsInSet(setRT);
	}
  
	public String checkSum { get; set; }
  
	/**
	* @description       New flow for creativities
	* @param listNews    List to Campaign
	*/
	public static void newFlowAC(Map<Id, Campaign> mapNewCampaign, Map<Id, Campaign> mapOldCampaign){
        EV_LogDebug.printLogDebug('newFlowAC ',String.valueof(mapNewCampaign) + ' '+ String.valueof(mapOldCampaign));
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        setIdsRts.addAll(setRTCatFisico);
        setIdsRts.addAll(setRTCatVirtual);
        setIdsRts.addAll(setRTCatHibrido);
        setIdsRts.addAll(setRtFestivales);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        Set<String> campignStatusConfirmed = new Set<String>{'009'};
            
            for(Campaign c : mapNewCampaign.values()){
                
                if((setIdsRts).contains(c.RecordTypeId) && campignStatusConfirmed.contains(c.Status) && mapNewCampaign.get(c.Id).Status != mapOldCampaign.get(c.Id).Status){
                    c.EV_FlujoPruebas__c = '001';
                }
            }
	}


	/**
	* @description  update visibility information
	* @param listNews    List to Campaign
    * @param mapOldCampaign Map to old Campaign
	*/
    public static void visiblePortalInformation(List<Campaign> listNews,Map<Id, Campaign> mapOldCampaign){
        EV_LogDebug.printLogDebug('visiblePortalInformation ',String.valueof(listNews) + ' '+ String.valueof(mapOldCampaign));
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        setIdsRts.addAll(setRtFestivales);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        List<EV_PortalCaixaBankTalks__c> lstPortal = new List<EV_PortalCaixaBankTalks__c>();
        Map<Id, List<EV_PortalCaixaBankTalks__c>> campaignIdToPortalsMap = new Map<Id, List<EV_PortalCaixaBankTalks__c>>();
        List<EV_PortalCaixaBankTalks__c> lstToUpdate = new List<EV_PortalCaixaBankTalks__c>();

        if(Schema.sObjectType.EV_PortalCaixaBankTalks__c.isAccessible()){
            lstPortal = [SELECT id, name, EV_Posicionamiento__c, EV_Fechadespublicacion__c, EV_Evento__r.RecordTypeId 
                FROM EV_PortalCaixaBankTalks__c WHERE EV_Evento__c IN:listNews AND EV_Evento__r.RecordTypeId IN:setIdsRts AND EV_Posicionamiento__c != '008'];

            for (EV_PortalCaixaBankTalks__c evtPortal : lstPortal) {
                if (!campaignIdToPortalsMap.containsKey(evtPortal.EV_Evento__c)) {
                    campaignIdToPortalsMap.put(evtPortal.EV_Evento__c, new List<EV_PortalCaixaBankTalks__c>());
                }
                campaignIdToPortalsMap.get(evtPortal.EV_Evento__c).add(evtPortal);
            }
        }
        EV_LogDebug.printLogDebug('@@campaignIdToPortalsMap ',String.valueof(campaignIdToPortalsMap));

        if(!lstPortal.isEmpty()){
            if(mapOldCampaign != null || !mapOldCampaign.isEmpty()){
                for (Campaign newCampaign : listNews) {
                    if (newCampaign.EV_Fechadespublicacion__c != null && newCampaign.EV_Fechadespublicacion__c != mapOldCampaign.get(newCampaign.Id).EV_Fechadespublicacion__c && campaignIdToPortalsMap.containsKey(newCampaign.Id)) {
                        for (EV_PortalCaixaBankTalks__c portal : campaignIdToPortalsMap.get(newCampaign.Id)) {
                            portal.EV_Fechadespublicacion__c = newCampaign.EV_Fechadespublicacion__c;
                            lstToUpdate.add(portal);
                        }
                    }
                }
                EV_LogDebug.printLogDebug('@@lstToUpdate ',String.valueof(lstToUpdate));
            }
            if(!lstToUpdate.isEmpty()){
                Database.SaveResult[] updateResults = Database.update(lstToUpdate, false);
                for(Database.SaveResult result : updateResults){
                    if(!result.isSuccess()){
                        for(Database.Error error : result.getErrors()){
                            EV_LogDebug.printLogDebug('@@Error al actualizar ',String.valueof(error.getMessage()));
                        }
                    }
                }
            }
        }
    }


				
	/**
	* @description       Validate translation for campaign
	* @param listNews    List to Campaign
	*/
	public static void validateEventToTranslations(List<Campaign> listNews,Map<Id, Campaign> oldMapCampaign){
        EV_LogDebug.printLogDebug('validateEventToTranslations ',String.valueof(listNews) + ' '+ String.valueof(oldMapCampaign));
        List<EV_TraduccionDeEvento__c> listTranslationEvent = new List<EV_TraduccionDeEvento__c>();
        Map<String, List<EV_TraduccionDeEvento__c>> mapTranslations = new Map<String, List<EV_TraduccionDeEvento__c>>();
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTCatVirtual);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTCatHibrido);
        setIdsRts.addAll(setRtFestivales);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        Set<String> setIdsCampaign = new Set<String>();
        Set<String> campignStatusConfirmed = new Set<String>{'009'};
            
            for(Campaign campNew : listNews){
                //Comprobación para no entrar en metodo si no es necesario
                if(campignStatusConfirmed.contains(campNew.Status) && oldMapCampaign.get(campNew.Id).Status != campNew.Status && (setIdsRts).contains(campNew.RecordTypeId)){
                    setIdsCampaign.add(campNew.Id);
                }           
            }
        EV_LogDebug.printLogDebug('validateEventToTranslations setIdsCampaign',String.valueof(setIdsCampaign));
        if(setIdsCampaign!=null){
            listTranslationEvent = [SELECT Id, EV_Evento__c, EV_URLImagenEsperaStreaming__c, EV_URLVideoTeaser__c,EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c 
                                    FROM EV_TraduccionDeEvento__c 
                                    WHERE EV_Evento__c in :setIdsCampaign];
            if(!listTranslationEvent.isEmpty() && listTranslationEvent!=null){
                for(EV_TraduccionDeEvento__c traduct : listTranslationEvent){
                    if(!mapTranslations.containsKey(traduct.EV_Evento__c)){
                        mapTranslations.put(traduct.EV_Evento__c, new List<EV_TraduccionDeEvento__c>{traduct});
                    }else{
                        mapTranslations.get(traduct.EV_Evento__c).add(traduct);
                    }
                    
                } 
            }         
        }	
        if(mapTranslations!=null && !mapTranslations.isEmpty()){    
            for(Campaign c : listNews){
                List<EV_TraduccionDeEvento__c> trad = mapTranslations.get(c.id);
                for(EV_TraduccionDeEvento__c t : trad){
                    if(c.recordtypeId == rtFestivales && campignStatusConfirmed.contains(c.Status) && oldMapCampaign.get(c.Id).Status != c.Status && 
                    ((t.EV_BeAgroBankMIC__c==null && t.EV_BancaNegocios__c==null && t.EV_BancaPremier__c ==null &&
                     t.EV_BancaPrivada__c == null && t.EV_BancaRetail__c == null && t.EV_CodigoBeAgroBankMIC__c == null &&
                     t.EV_CodigoBancaNegocios__c == null && t.EV_CodigoBancaPremier__c == null &&
                     t.EV_CodigoBancaPrivada__c == null && t.EV_CodigoBancaRetail__c == null) 
                    || (t.EV_TextoCTANL__c == null && t.EV_URLCTALanding__c == null && t.EV_TextoCTALanding__c == null))){
                        c.addError('Necesitas informar el espacio Festivales y otras experiencias de las traducciones');
                    }
                    if(c.recordtypeId != rtFestivales && campignStatusConfirmed.contains(c.Status) && oldMapCampaign.get(c.Id).Status != c.Status && (c.EV_URLDelEventoVirtual__c==null || t.EV_URLImagenEsperaStreaming__c==null)){
                        c.addError('Necesitas informar la URL del evento virtual y la URL del Streaming');
                    }
                    if(c.recordtypeId != rtFestivales && campignStatusConfirmed.contains(c.Status) && oldMapCampaign.get(c.Id).Status != c.Status && (((c.EV_URLImagenVideo__c!=null && t.EV_URLVideoTeaser__c==null)) || (c.EV_URLImagenVideo__c==null && t.EV_URLVideoTeaser__c!=null))){
                        c.addError('Necesitas informar la URL de imagen video y la URL del video teaser');
                    } 
                }
            }
        }
	}
  
	/**
	* @description       New flow for creativities
	* @param listNews    List to Campaign
	*/
	public static void fillPlaceOfCelebration(List<Campaign> listNews){
        EV_LogDebug.printLogDebug('fillPlaceOfCelebration ',String.valueof(listNews));
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTCatVirtual);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRtVirtualTech);
        
        for(Campaign c : listNews){
            if((setIdsRts).contains(c.RecordTypeId)){
                c.EV_LugarDeCelebracion__c = EV_PLACE_OF_CELEBRATION;
            }
        }
	}
  
	public static void fillCarteraParent(List<Campaign> listNews) {
        EV_LogDebug.printLogDebug('fillCarteraParent ',String.valueof(listNews));
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTCatFisico);
        setIdsRts.addAll(setRTCatVirtual);
        setIdsRts.addAll(setRTCatHibrido);
        setIdsRts.addAll(setRtFestivales);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        List<Campaign> updateCampaign = new List<Campaign>();
        List<Campaign> lstCamp = [SELECT id, ParentId, EV_Cartera__c,EV_CentroPromotor__c, EV_Categoria__c, Parent.EV_Cartera__c, Parent.EV_CentroPromotor__c, Parent.EV_Categoria__c,  RecordTypeId  FROM Campaign Where Id IN: listNews AND ParentId != null AND RecordTypeId IN:setIdsRts];
        if(!lstCamp.isEmpty()){
            for (Campaign c : lstCamp) {
                if(c.EV_Cartera__c != c.parent.EV_Cartera__c || c.EV_CentroPromotor__c != c.parent.EV_CentroPromotor__c || c.EV_Categoria__c != c.parent.EV_Categoria__c){
                       c.EV_Cartera__c = c.Parent.EV_Cartera__c;
                       c.EV_CentroPromotor__c = c.parent.EV_CentroPromotor__c;
                       c.EV_Categoria__c = c.parent.EV_Categoria__c;
                       updateCampaign.add(c);
                   }
            }
        }
        if(!updateCampaign.isEmpty() && Schema.sObjectType.Campaign.isUpdateable()){
            update updateCampaign;
        }                                                      
	}
  
	/**
	* @description       New flow for creativities
	* @param listNews    List to Campaign
	*/
	public static void validatePublicForEvent(Map<Id, Campaign> newMapCampaign, Map<Id, Campaign> oldMapCampaign){
        EV_LogDebug.printLogDebug('validatePublicForEvent ',String.valueof(newMapCampaign) + ' '+ String.valueof(oldMapCampaign));
        List<EV_TraduccionDeEvento__c> listTranslationEvent = new List<EV_TraduccionDeEvento__c>();
        Map<String, List<EV_TraduccionDeEvento__c>> mapTranslations = new Map<String, List<EV_TraduccionDeEvento__c>>();
        Set<String> campignStatusPublicValidate = new Set<String>{'008'};
        Set<String> flowValidateTest = new Set<String>{'003'};
        Set<String> flowSolicitudTest = new Set<String>{'001'};
        Set<String> flowNotValidateTest = new Set<String>{'004', '005'};
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        setIdsRts.addAll(setRtFestivales);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        Set<String> setIdsCampaign = new Set<String>();
        
        for(Campaign c : newMapCampaign.values()){
            //Comprobación para no entrar en metodo si no es necesario
            if(oldMapCampaign.get(c.Id).Status != newMapCampaign.get(c.Id).Status && (setIdsRts).contains(c.RecordTypeId)){
                setIdsCampaign.add(c.Id);
            }           
        }
        EV_LogDebug.printLogDebug('validatePublicForEvent setIdsCampaign',String.valueof(setIdsCampaign));
        
        if(setIdsCampaign!=null){
            listTranslationEvent = [SELECT Id, EV_Evento__c, LastModifiedDate FROM EV_TraduccionDeEvento__c where EV_Evento__c in :setIdsCampaign];
        }
        if(listTranslationEvent!=null && !listTranslationEvent.isEmpty()){
            for(EV_TraduccionDeEvento__c traduct : listTranslationEvent){
                if(!mapTranslations.containsKey(traduct.EV_Evento__c)){
                    mapTranslations.put(traduct.EV_Evento__c, new List<EV_TraduccionDeEvento__c>{traduct});
                }else{
                    mapTranslations.get(traduct.EV_Evento__c).add(traduct);
                }
            }
        }       
        
        if (mapTranslations != null && !mapTranslations.isEmpty()) { 
            for(Campaign c : newMapCampaign.values()){
                List<EV_TraduccionDeEvento__c> trad = mapTranslations.get(c.id);
                if(trad != null){
                    for(EV_TraduccionDeEvento__c t : trad){
                        if(campignStatusPublicValidate.contains(c.Status) && !flowValidateTest.contains(c.EV_FlujoPruebas__c) && oldMapCampaign.get(c.Id).LastModifiedDate > t.LastModifiedDate){
                            c.addError('Para pasar a Publico validado debes tener el flujo de pruebas en Pruebas validadas');
                        } 
                        if(oldMapCampaign.get(c.Id).EV_FlujoPruebas__c != newMapCampaign.get(c.Id).EV_FlujoPruebas__c && flowSolicitudTest.contains(c.EV_FlujoPruebas__c)&& flowNotValidateTest.contains(oldMapCampaign.get(c.Id).EV_FlujoPruebas__c) && c.LastModifiedDate > t.LastModifiedDate){
                            c.addError('Se debe modificar las traducciones para volver a solicitar pruebas');
                        }
                    }
                }
            }
        }
	}
  
	public static void shareCampaign(List<Campaign> listNews, Map<Id, Campaign> mapOldObj){
		EV_LogDebug.printLogDebug('shareCampaign ',String.valueof(listNews) + ' '+ String.valueof(mapOldObj));
	  Map<Id,List<String>> campaignCentros = new Map<Id,List<String>>();
	  if(!System.isFuture() && !System.isBatch()){
		boolean isUpdate = false;
		//Check the new data
		if(mapOldObj == null || mapOldObj.isEmpty()){
		  for(Campaign c : listNews){
			 List<String> centros = new List<String>();
			 if(!String.isEmpty(c.EV_CentroOrganizador__c)){centros.add(c.EV_CentroOrganizador__c);}
			 if(!String.isEmpty(c.EV_CentroPromotor__c)) {centros.add(c.EV_CentroPromotor__c);}
			 if(!String.isEmpty(c.EV_CentroAdminstrador__c)) {centros.add(c.EV_CentroAdminstrador__c);}
			 if(!centros.isEmpty()) {campaignCentros.put(c.Id, centros);}
		  }
		}else{
		  for(Campaign c : listNews){
			List<String> centros = new List<String>();
			if(!String.isEmpty(c.EV_CentroOrganizador__c) && c.EV_CentroOrganizador__c != mapOldObj.get(c.Id).EV_CentroOrganizador__c){
			  centros.add(c.EV_CentroOrganizador__c);
			} 
			if(!String.isEmpty(c.EV_CentroPromotor__c) && c.EV_CentroPromotor__c != mapOldObj.get(c.Id).EV_CentroPromotor__c){
			  centros.add(c.EV_CentroPromotor__c);
			} 
			if(!String.isEmpty(c.EV_CentroAdminstrador__c) && c.EV_CentroAdminstrador__c != mapOldObj.get(c.Id).EV_CentroAdminstrador__c){
			  centros.add(c.EV_CentroAdminstrador__c);
			}
			if(!centros.isEmpty()) {campaignCentros.put(c.Id, centros);}                    
		   }
  
		  isUpdate = true;
		}
			EV_LogDebug.printLogDebug('shareCampaign campaignCentros',String.valueof(campaignCentros));
		if(campaignCentros!=null && !campaignCentros.isEmpty()){
		  sharingCampaignApex(JSON.serialize(campaignCentros));
		}
		
	  }
		
	}
	//CAMBIADO Y COMPRODA EL AV_QUERY POR SELECT
	public static void updateCarteraPO(List<Campaign> listNews, Map<Id, Campaign> mapOldObj){
		EV_LogDebug.printLogDebug('updateCarteraPO ',String.valueof(listNews) + ' '+ String.valueof(mapOldObj));
	  Set<String> campsIds = new Set<String>();
	  for (Campaign camp : listNews) {
		if (camp.EV_Cartera__c != mapOldObj.get(camp.Id).EV_Cartera__c){
		  campsIds.add(camp.Id);
		}
	  }
		EV_LogDebug.printLogDebug('updateCarteraPO campsIds',String.valueof(campsIds));
		//Añadido para no entra si no es necesario
		if(campsIds != null && !campsIds.isEmpty()){
	  List<EV_CriterioPublicoObjetivo__c> listCPOToProcess = [SELECT EV_Evento__c, EV_Activo__c, EV_ValorCriterio__c, EV_LabelCriterio__c FROM EV_CriterioPublicoObjetivo__c 
								  WHERE EV_VariablePublicoObjetivo__r.EV_VariableAdobeCampaign__c = :'Recipient.Client.ClientBusiness' 
								  AND EV_Evento__c in :campsIds LIMIT 200];
	  Map<ID, Campaign> mapCamps = new Map<ID, Campaign>([SELECT Id, toLabel(EV_Cartera__c)FROM Campaign where Id in :campsIds]);
	  for (Campaign  camp : listNews) {
		for (EV_CriterioPublicoObjetivo__c cpo : listCPOToProcess) {
					EV_LogDebug.printLogDebug('CPO', String.valueOf(cpo));
		  if(cpo.EV_Evento__c == camp.Id){
			cpo.EV_Activo__c= true;
			cpo.EV_ValorCriterio__c = camp.EV_Cartera__c;                   
			cpo.EV_LabelCriterio__c = mapCamps.get(camp.Id).EV_Cartera__c;  
		  }               
		}
	  }
	  if (listCPOToProcess != null && !listCPOToProcess.isEmpty() && Schema.sObjectType.EV_CriterioPublicoObjetivo__c.isUpdateable()) {
		Database.update(listCPOToProcess, false);          
	  }
	}
	}
  
	@future
	private static void sharingCampaignApex(String jsonCentros){
		EV_LogDebug.printLogDebug('sharingCampaignApex ',String.valueof(jsonCentros));
		Map<String, List<String>> campaignCentros = (Map<String, List<String>>)JSON.deserialize(jsonCentros, Map<String, List<String>>.class);
		Set<String> centros = new Set<String>();
		List<Contact> cons = new List<Contact>(); 
		for(String c : campaignCentros.keySet()){
			centros.addAll(campaignCentros.get(c));
		}
		if (centros != null && !centros.isEmpty()) {
			cons = [SELECT Id, CC_Matricula__c, AccountId, AV_UsuarioAsociado__c FROM Contact where AccountId in :centros AND 
			RecordType.DeveloperName = 'CC_Empleado' AND (CC_Matricula__c != null AND (not(CC_Matricula__c like '%INVALID%'))) AND 
			Account.CC_Numero_Oficina__c != null AND AV_UsuarioAsociado__c != null];   

			if (cons != null && !cons.isEmpty()) {
				Map<Id, List<String>> mapCons = new Map<Id, List<String>>();
				for(Contact contactos : cons){
					if (!mapCons.containsKey(contactos.AccountId)) {
						mapCons.put(contactos.AccountId, new List<String>{contactos.AV_UsuarioAsociado__c});
					}else{
						mapCons.get(contactos.AccountId).add(contactos.AV_UsuarioAsociado__c);
					}
				}
				Map<String, Set<String>> campaignEmployees= new Map<String, Set<String>>();
				for(String camp : campaignCentros.keySet()){

					for (String centroAccountId : campaignCentros.get(camp)) {
						for (String usuario : mapCons.get(centroAccountId)) {
							if(!campaignEmployees.containsKey(camp)){
								campaignEmployees.put(camp, new Set<String>{usuario});
							}else{
								campaignEmployees.get(camp).add(usuario);
							}
						}
					}
				}

				List<CampaignShare> lstShare = new List<CampaignShare>();
				for(String campaignId : campaignEmployees.keySet()){
					for (Id usuarioAsociado : campaignEmployees.get(campaignId)) {
						CampaignShare cS = new CampaignShare();
						cS.CampaignId = campaignId;                  
						cS.UserOrGroupId = usuarioAsociado;
						cS.CampaignAccessLevel = 'Edit';
						lstShare.add(cS); 
					}  
				}
				if(lstShare != null && !lstShare.isEmpty()){
					Database.SaveResult[] result = Database.insert(lstShare, false);
					for(Database.SaveResult datos : result){
						if(!datos.isSuccess()){
							EV_LogDebug.printLogDebug('Error al insertar CampaignShare: ', String.valueof(datos));
						}
					}
				}
			}
	   	}
	}

	@InvocableMethod(label='CalculoSharing')
	public static List<String> calculoSharing(List<String> recId){
		EV_LogDebug.printLogDebug('calculoSharing ',String.valueof(recId));
	  Map<Id,List<String>> campaignCentros = new Map<Id,List<String>>();
	  Campaign camp =  [SELECT Id, EV_CentroAdminstrador__c, EV_CentroOrganizador__c, EV_CentroPromotor__c FROM Campaign where Id = :recId[0]];        
	  if(camp!=null){
		List<String> listCentro = new List<String>();
		if(!String.isEmpty(camp.EV_CentroOrganizador__c)){
		  listCentro.add(camp.EV_CentroOrganizador__c);
		} 
		if(!String.isEmpty(camp.EV_CentroPromotor__c) ){
		  listCentro.add(camp.EV_CentroPromotor__c);
		} 
		if(!String.isEmpty(camp.EV_CentroAdminstrador__c) ){
		  listCentro.add(camp.EV_CentroAdminstrador__c);
		}
		campaignCentros.put(camp.Id, listCentro);
		sharingCampaignApex(JSON.serialize(campaignCentros));
	  }
  
	  return new List<String>{'OK'};
	}

	public static void cambioStatusEncursoFinalizado(List<Campaign> listNewObj, Map<Id, Campaign> mapOldObj) {
		EV_LogDebug.printLogDebug('cambioStatusEncursoFinalizado ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        Set<Id> setIdsRts = new Set<Id>();
		setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        setIdsRts.addAll(setRtFestivales);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);

        for(Campaign camp : listNewObj){
            
            if(camp.StartDate != null && camp.EV_HoraInicio__c != null && camp.EV_HoraFin__c != null && (setIdsRts).contains(camp.RecordTypeId)){
                Campaign oldCamp = mapOldObj != null && mapOldObj.containsKey(camp.Id) ? mapOldObj.get(camp.Id) : null;
                if (oldCamp == null || camp.StartDate != oldCamp.StartDate || camp.EV_HoraInicio__c != oldCamp.EV_HoraInicio__c || camp.EV_HoraFin__c != oldCamp.EV_HoraFin__c) {
                    camp.EV_DiaHora_evento__c = DateTime.newInstance(camp.StartDate, camp.EV_HoraInicio__c);
					camp.EV_FechaHoraFin__c = DateTime.newInstance(camp.StartDate, camp.EV_HoraFin__c);
                }
            }
        }
    }


	@future
    public static void generarIdSeguro(Set<Id> recordIds) {
		EV_LogDebug.printLogDebug('generarIdSeguro ',String.valueof(recordIds));
        List<Campaign> lstAux = new List<Campaign>();
        for(Campaign camp : [Select Id, CreatedDate, Name from Campaign where Id in : recordIds]){
            camp.EV_ExternalID__c = EV_Utilities.generateSecureId(camp.Id + String.valueOf(camp.CreatedDate) + camp.Name).replace('%','').replace('&','');
            lstAux.add(camp);

        }
        update lstAux;
    }

    public static void generarTraduccionesEventoHijo(List<Campaign> listNewObj) {
        EV_LogDebug.printLogDebug('generarTraduccionesEventoHijo ',String.valueof(listNewObj));
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        
        Map<Id, List<EV_TraduccionDeEvento__c>> mapTraducciones = new Map<Id, List<EV_TraduccionDeEvento__c>>();
        Map<Id, List<Id>> mapTraduccionesHijo = new Map<Id,List<Id>>();
        List<EV_TraduccionDeEvento__c> lstTraduccionesInsert = new List<EV_TraduccionDeEvento__c>();
        Set<Id> parentCampaigns = new Set<Id>();
        for(Campaign camp : listNewObj){
            if(camp.ParentId != null && setIdsRts.contains(camp.RecordtypeId)){
                parentCampaigns.add(camp.ParentId);
                if (!mapTraduccionesHijo.containsKey(camp.ParentId)) {
                    mapTraduccionesHijo.put(camp.ParentId, new List<Id>());
                }
                mapTraduccionesHijo.get(camp.ParentId).add(camp.id);
            }
        }
        
        if(!parentCampaigns.isEmpty()){
            Map<Id, List<EV_TraduccionDeEvento__c>> mapTraduccionesParent = new Map<Id, List<EV_TraduccionDeEvento__c>>();
            
            List<EV_TraduccionDeEvento__c> traducciones = [select EV_AntetituloCategoria__c, Name,EV_Descripcion__c, EV_Evento__c, EV_Idioma__c, EV_ImagenCabecera__c, EV_SinopsisInvitacion__c,EV_URLDeImagen__c, EV_URLImagenInvitacion__c, EV_URLVideoTeaser__c, EV_Claim__c, EV_TextoBoton__c, EV_TextoDebajoBoton__c, 
                                                  EV_TextoDescriptivoBoton__c, EV_TextoOnClick__c, EV_URLImagenCarrusel__c, EV_URLImagenGrande__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLNegocioPromotor__c, EV_URLLogoPie__c, 
                                                  EV_TituloVideoTeaser__c, EV_DescripcionVideoTeaser__c from EV_TraduccionDeEvento__c where EV_Evento__c in : parentCampaigns];
            
            for(EV_TraduccionDeEvento__c trad : traducciones){
                if (mapTraduccionesHijo.containsKey(trad.EV_Evento__c)) {
                    List<Id> idsHijos = mapTraduccionesHijo.get(trad.EV_Evento__c);
                    for(Id ids : idsHijos){
                        EV_TraduccionDeEvento__c traduccion = trad.clone();
                        traduccion.EV_Evento__c = ids;
                        traduccion.Name = trad.Name;
                        lstTraduccionesInsert.add(traduccion);
                    }
                    
                }
            }                                         
            if(Schema.sObjectType.EV_TraduccionDeEvento__c.isCreateable()){
                insert lstTraduccionesInsert;
            }
        }
    }

    public static void createCriteriosPO(List<Campaign> listNewObj) {
		EV_LogDebug.printLogDebug('createCriteriosPO ',String.valueof(listNewObj));

        List<Campaign> listChildCamps = new List<Campaign>();
        List<Campaign> listCamps = new List<Campaign>();
        Set<String> setParentCamps = new Set<String>();
        Set<String> setCamps = new Set<String>();

        for(Campaign camp : listNewObj) {
            setCamps.add(camp.Id);
            if(camp.RecordTypeId == rtEventoVirtual || camp.RecordTypeId == rtEventoFisico || camp.RecordTypeId == rtEventoHibrido || camp.RecordTypeId == rtFestivales || camp.RecordTypeId == rtEventoFisicoTechSummit ||  camp.RecordTypeId == rtEventoVirtualTechSummit  ||  camp.RecordTypeId == rtEventoHibridoTechSummit ) {
                if(camp.ParentId != null) {
                    listChildCamps.add(camp);
                    setParentCamps.add(camp.ParentId);
                } else {
                    listCamps.add(camp);
                }
            } else if(camp.RecordTypeId == rtEventoCatVirtual || camp.RecordTypeId == rtEventoCatHibrido || camp.RecordTypeId == rtEventoCatFisico ) {
                listCamps.add(camp);
            }
        }

        List<EV_CriterioPublicoObjetivo__c> listCPOToProcess = new List<EV_CriterioPublicoObjetivo__c>();
        Map<ID, Campaign> mapCamps = new Map<ID, Campaign>([SELECT Id, toLabel(EV_Cartera__c)FROM Campaign where Id in :setCamps]);
        if(!listChildCamps.isEmpty()) {
            List<EV_CriterioPublicoObjetivo__c> listParentCPO = [SELECT Id, Name, EV_Evento__c, EV_VariablePublicoObjetivo__c, EV_EditableValorCriterio__c, EV_Activo__c, EV_TipoCriterio__c, EV_ValorCriterio__c, EV_LabelCriterio__c FROM EV_CriterioPublicoObjetivo__c where EV_Evento__c in :setParentCamps];

            Map<String, List<EV_CriterioPublicoObjetivo__c>> mapCPO = new Map<String, List<EV_CriterioPublicoObjetivo__c>>();                            
            if(!listParentCPO.isEmpty()) {
                for(EV_CriterioPublicoObjetivo__c cpo :listParentCPO) {
                    if(!mapCPO.containsKey(cpo.EV_Evento__c)) {
                        mapCPO.put(cpo.EV_Evento__c, new List<EV_CriterioPublicoObjetivo__c>{cpo});
                    } else {
                        mapCPO.get(cpo.EV_Evento__c).add(cpo);
                    }
                }
            }
            if(!listParentCPO.isEmpty()) {
                for(Campaign capmToProcess : listChildCamps) {
                    for(EV_CriterioPublicoObjetivo__c parentCPO : mapCPO.get(capmToProcess.ParentId)) {
                        EV_CriterioPublicoObjetivo__c cpo = new EV_CriterioPublicoObjetivo__c();
                        cpo.EV_Evento__c = capmToProcess.Id;
                        cpo.EV_Activo__c = parentCPO.EV_Activo__c;
                        cpo.EV_TipoCriterio__c = parentCPO.EV_TipoCriterio__c;
                        //Añadimos valor
                        cpo.EV_ValorCriterio__c = parentCPO.EV_ValorCriterio__c;
                        cpo.EV_LabelCriterio__c = parentCPO.EV_LabelCriterio__c;
                        cpo.EV_VariablePublicoObjetivo__c = parentCPO.EV_VariablePublicoObjetivo__c;
                        listCPOToProcess.add(cpo);
                    }
                }
            }
        }

        if(!listCamps.isEmpty()) {
            List<EV_VariablePublicoOjetivo__c> listVarsPO =[SELECT Id, EV_VariableAdobeCampaign__c FROM EV_VariablePublicoOjetivo__c];
            for(Campaign capmToProcess : listCamps) {
                for(EV_VariablePublicoOjetivo__c varPO : listVarsPO) {
                    EV_CriterioPublicoObjetivo__c cpo = new EV_CriterioPublicoObjetivo__c();
                    cpo.EV_Evento__c = capmToProcess.Id;
                    cpo.EV_Activo__c = false;
                   
                    if(varPO.EV_VariableAdobeCampaign__c == 'Idioma' || varPO.EV_VariableAdobeCampaign__c == 'Channel'){
						cpo.EV_TipoCriterio__c = 'Obligatorio';
					}else{
                        cpo.EV_TipoCriterio__c = 'Opcional'; 
                    }
                    if (varPO.EV_VariableAdobeCampaign__c == 'Recipient.Client.ClientBusiness') {
                        cpo.EV_ValorCriterio__c = capmToProcess.EV_Cartera__c;
                        
                        cpo.EV_LabelCriterio__c = mapCamps.get(capmToProcess.Id).EV_Cartera__c;
                        cpo.EV_Activo__c = true;
                    }
                    cpo.EV_VariablePublicoObjetivo__c = varPO.Id;
                    listCPOToProcess.add(cpo);
                }
            }
        }

        if(!listCPOToProcess.isEmpty() && Schema.sObjectType.EV_CriterioPublicoObjetivo__c.isCreateable()) {
            Database.insert(listCPOToProcess, false);
        }
    }
    
    public static void crearCampaignEstados(List<Campaign> newCampaigns) {
		EV_LogDebug.printLogDebug('crearCampaignEstados ',String.valueof(newCampaigns));
        List<CampaignMemberStatus> statusToAdd = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> statusToUpdate = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> statusToDelete = new List<CampaignMemberStatus>(); 
        List<Campaign> procesCamp = new List<Campaign>();
        Set<String> defaultLabels = new Set<String>();
        
        for(Campaign campaignObj : newCampaigns){
            if(campaignObj.EV_NewArchitecture__c == false){
                procesCamp.add(campaignObj);
            }
        }
        if(!procesCamp.isEmpty()){
            for(CampaignMemberStatus memberStatus : [SELECT Id, CampaignId, Label, 
                                                     SortOrder, IsDefault, HasResponded 
                                                     FROM CampaignMemberStatus
                                                     WHERE CampaignId IN :procesCamp])
            {
                statusToDelete.add(memberStatus);
            }
             for(CampaignMemberStatus cms : statusToDelete){
                 if(cms.Label == 'Sent' || cms.Label == 'Enviado'){
                     cms.Label = 'Pendiente';
                 }if(cms.Label == 'Responded' || cms.Label == 'Respondida'){
                     cms.Label = 'Registro confirmado';
                 }
             }
            
            Map<String, EV_CampaignStatus__mdt> statusCampaigns = new Map<String,EV_CampaignStatus__mdt>();
            for(EV_CampaignStatus__mdt status : [SELECT DeveloperName, Label, Orden__c, Por_defecto__c, Respondido__c FROM EV_CampaignStatus__mdt ORDER BY Orden__c ASC]){
                statusCampaigns.put(status.developerName, status);               
                
            
            }
            
            for(Campaign campaignObj : newCampaigns){
                if(campaignObj.EV_NewArchitecture__c == false){
                    Id campaignId = campaignObj.Id;
                    for(EV_CampaignStatus__mdt cv : statusCampaigns.values()){
                        if((cv.Label != 'Pendiente' && cv.Label != 'Registro confirmado') /*|| test.isRunningTest()*/){
                            statusToAdd.add(new CampaignMemberStatus(
                                        CampaignId = campaignId, 
                                        Label = cv.Label, 
                                        SortOrder = Integer.valueOf(cv.Orden__c),
                                        IsDefault = cv.Por_defecto__c, 
                                        HasResponded = cv.Respondido__c)); 
                        }
                    }
                }
            }
            statusToAdd.addAll(statusToDelete);
            EV_LogDebug.printLogDebug('statusToAdd ',String.valueof(statusToAdd));
            if(!statusToAdd.isEmpty() && Schema.sObjectType.CampaignMemberStatus.isCreateable() && Schema.sObjectType.CampaignMemberStatus.isUpdateable()){
                upsert statusToAdd;
            }
        }

    }


	public static void setCampaignMemberRecordTypeId(List<Campaign> listNewObj){
		EV_LogDebug.printLogDebug('setCampaignMemberRecordTypeId ',String.valueof(listNewObj));
        Set<Id> setIdsRts = new Set<Id>();
		setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        Id rtEventoMiembro = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
        for(Campaign camp : listNewObj){
            if(setIdsRts.contains(camp.RecordtypeId) && camp.EV_NewArchitecture__c == false){
                camp.CampaignMemberRecordTypeId = rtEventoMiembro;
            }
        }
    }

    /**
	* @description   include techSummit in new campaigns.
	* @param List<Campaign> listNewObj   List to New Campaign
	*/
	public static void setTechSummitCampaign(List<Campaign> listNewObj){
		EV_LogDebug.printLogDebug('setTechSummitCampaign ',String.valueof(listNewObj));
        Set<Id> setIdsRts = new Set<Id>();
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);
        for(Campaign camp : listNewObj){
            if(setIdsRts.contains(camp.RecordtypeId) && camp.EV_NewArchitecture__c == true){
                camp.EV_TechSummit__c = true;
            }
        }
    }

    /**
	* @description       Check active survey
	* @param List<Campaign> listNewObj           List to New Campaign
	* @param Map<Id, Campaign> mapNewCampaign    Map to New Campaign
	* @param Map<Id, Campaign> mapOldCampaign    Map to Old Campaign
	*/
	public static void surveyActive(List<Campaign> listNewObj, Map<Id, Campaign> mapNewCampaign, Map<Id, Campaign> mapOldCampaign){
		EV_LogDebug.printLogDebug('surveyActive ',String.valueof(listNewObj) + ' ' +String.valueof(mapNewCampaign) + ' '+ String.valueof(mapOldCampaign));
	  	Set<Id> setIdsRts = new Set<Id>();
		setIdsRts.addAll(setRTFisico);
        setIdsRts.addAll(setRTVirtual);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTCatVirtual);
        setIdsRts.addAll(setRTCatFisico);
        setIdsRts.addAll(setRTHibrido);
        setIdsRts.addAll(setRTAccionista);
        setIdsRts.addAll(setRtFestivales);
        setIdsRts.addAll(setRtFisicoTech);
        setIdsRts.addAll(setRtVirtualTech);
        setIdsRts.addAll(setRtHibridoTech);

        Map<Id,Survey> surveyActive = new Map<Id,Survey>([Select id from Survey  where ActiveVersion.SurveyStatus = 'Active']);
	  
        for(Campaign c : listNewObj){
            Campaign oldCamp = mapOldCampaign != null && mapOldCampaign.containsKey(c.Id) ? mapOldCampaign.get(c.Id) : null;
            Campaign newCamp = mapNewCampaign != null && mapNewCampaign.containsKey(c.Id) ? mapNewCampaign.get(c.Id) : null;
            if((setIdsRts).contains(c.RecordTypeId)&& c.EV_Encuesta__c!= null){
                if (Trigger.isBefore && !surveyActive.containsKey(c.EV_Encuesta__c)) {
                    c.addError(Label.EV_EncuestaInactiva);
                }else if(newCamp != null && oldCamp != null && newCamp.EV_Encuesta__c != oldCamp.EV_Encuesta__c && !surveyActive.containsKey(newCamp.EV_Encuesta__c)){
                    c.addError(Label.EV_EncuestaInactiva);
                }
            }
        }
    }
    
	 /**
	* @description       Count number of Campaign Member C in Campaign
	* @param List<Campaign> listNewObj           List to New Campaign
	* @param Map<Id, Campaign> mapNewCampaign    Map to New Campaign
	* @param Map<Id, Campaign> mapOldCampaign    Map to Old Campaign
	*/
	public static void updateRollUpEventChangeStatus(List<Campaign> listNewObj, Map<Id, Campaign> mapOldCampaign){
		EV_LogDebug.printLogDebug('updateRollUpEventFinish ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldCampaign));

        Map<Id,Integer> aggAsisVir = new Map<Id,Integer>();
        Map<Id,Integer> aggInscriVir = new Map<Id,Integer>();
        Map<Id,Integer> aggTotal = new Map<Id,Integer>();
        Map<Id,Integer> aggTotalAsis = new Map<Id,Integer>();
		List<String> setCampaign = new List<String>();
        Map<Id,Campaign> campaignUpdate = new Map<Id,Campaign>();
		for(Campaign c : listNewObj){
			if(c.EV_NewArchitecture__c == true && mapOldCampaign != null && mapOldCampaign.get(c.id).status != c.status && c.status == '005' ){
				setCampaign.add(c.id);
			}
		}
        EV_LogDebug.printLogDebug('setCampaign ',String.valueof(setCampaign));
        if(!setCampaign.isEmpty()){
            List<AggregateResult> agrr = [SELECT count(id) t, EV_Status__c,  EV_CampaignId__c, EV_FormatoDeAsistencias__c, EV_Empresa__c FROM EV_CampaignMemberC__c where EV_CampaignId__c in : setCampaign GROUP BY EV_CampaignId__c, EV_Status__c, EV_FormatoDeAsistencias__c, EV_Empresa__c];
            
            EV_LogDebug.printLogDebug('ids Campaign rollup ',String.valueof(agrr));
            for(AggregateResult arr : agrr){
                String idC = (String)arr.get('EV_CampaignId__c');
                if(aggAsisVir.containsKey(idC)){
                    if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' && (Boolean)arr.get('EV_Empresa__c') == false && ((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                        Integer asis = aggAsisVir.get(idC);
                        Integer totalAsis = (Integer)arr.get('t') + asis;
                        aggAsisVir.put(idC, totalAsis);
                    }
                }else{
                        if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' &&  (Boolean)arr.get('EV_Empresa__c') == false && ((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                            Integer totalAsis = (Integer)arr.get('t');
                            aggAsisVir.put(idC, totalAsis); 
                        }  
                }if(aggInscriVir.containsKey(idC)){
                    if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' && (Boolean)arr.get('EV_Empresa__c') == false  && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Asistió en diferido' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                        Integer inscri = aggInscriVir.get(idC);
                        Integer totalInscri = (Integer)arr.get('t') + inscri;
                        aggInscriVir.put(idC, totalInscri);
                    }
                }else{
                    if((String)arr.get('EV_FormatoDeAsistencias__c') == '002' && (Boolean)arr.get('EV_Empresa__c') == false  && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Asistió en diferido' || (String)arr.get('EV_Status__c') == 'Registro confirmado' || (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                        Integer totalInscri = (Integer)arr.get('t');
                        aggInscriVir.put(idC, totalInscri);
                    }
                }if(aggTotal.containsKey(idC)){  
                        Integer count = aggTotal.get(idC);
                        Integer total = (Integer)arr.get('t') + count;
                        aggTotal.put(idC, total);
                }else{
                        Integer total = (Integer)arr.get('t');
                        aggTotal.put(idC, total);
                    
                }if(aggTotalAsis.containsKey(idC)){
                    if(((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta' ||  (String)arr.get('EV_Status__c') == 'Asistió en diferido') && (Boolean)arr.get('EV_Empresa__c') == false){
                        Integer count = aggTotalAsis.get(idC);
                        Integer total = (Integer)arr.get('t') + count;
                        aggTotalAsis.put(idC, total);
                    }
                }else{
                    if(((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta' ||  (String)arr.get('EV_Status__c') == 'Asistió en diferido') && (Boolean)arr.get('EV_Empresa__c') == false){
                        Integer total = (Integer)arr.get('t');
                        aggTotalAsis.put(idC, total);
                    }
                }
            }
        
            EV_LogDebug.printLogDebug('aggAsisVir ',String.valueof(aggAsisVir) + ' ' +aggAsisVir.values() );
            EV_LogDebug.printLogDebug('aggInscriVir ',String.valueof(aggInscriVir) + ' ' +aggInscriVir.values() );
            EV_LogDebug.printLogDebug('aggTotal ',String.valueof(aggTotal) +' ' + aggTotal.values() );
            EV_LogDebug.printLogDebug('aggTotalAsis ',String.valueof(aggTotalAsis) +' ' + aggTotalAsis.values() );
    
            for(Campaign c: listNewObj){
                Campaign camp = new Campaign();
                Integer asisVirtu = aggAsisVir.get(c.Id);
                Integer inscVirtu = aggInscriVir.get(c.Id);
                Integer total = aggTotal.get(c.Id);
                Integer totalAsis = aggTotalAsis.get(c.Id);
                camp.Id = c.Id;
                if(asisVirtu != null){
                    camp.EV_AsistentesVirtualesC__c = asisVirtu;
                }else{
                    camp.EV_AsistentesVirtualesC__c = 0;
                }if(inscVirtu != null){
                    camp.EV_InscritosVirtualesC__c = inscVirtu;
                }else{
                    camp.EV_InscritosVirtualesC__c = 0;
                }if(total != null){
                    camp.EV_Total_MiembrosC__c = total;
                }else{
                    camp.EV_Total_MiembrosC__c = 0;  
                }if(totalAsis != null){
                    camp.EV_TotalAsistentesC__c = totalAsis;
                }else{
                    camp.EV_TotalAsistentesC__c = 0;  
                }
                
                if(!campaignUpdate.containsKey(camp.id)){
                    campaignUpdate.put(camp.id, camp);
                }else{
                    campaignUpdate.put(camp.id, camp);
                }
            }
            EV_LogDebug.printLogDebug('campaignUpdate ',String.valueof(campaignUpdate));
            Database.update(campaignUpdate.values(), false);
        }
    }     
}