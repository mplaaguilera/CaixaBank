/**********************************************************************************************************************
 Name:	  EV_ImportMassEvent_Controller
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controller para la creación masiva de eventos
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION	USER_STORY	AUTHOR				DATE			Description
 * 1.0		US585725	Carolina Lopez		25/07/2023   	Init Version
 * 1.1		US704873	Mamen Arias			06/09/2023		Add control errors with FWK CBK_Log	
 * 1.2 		US704873	Carolina Lopez		08/09/2023		Add Custom Label EV_AltaMasivaSize
 * 1.3		US704873    Carolina Lopez		28/09/2023		Add methods generarTraduccionesEventoHijo, shareCampaign, sharingCampaignApex
 * 1.4		US704873    Carolina Lopez		09/10/2023		Modify methods sharingCampaignApex, generarTraduccionesEventoHijo, saveRecords.
***********************************************************************************************************************/
public without sharing class EV_ImportMassEvent_Controller {

private static Id rtC = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_CatalogoEventoFisico').getRecordTypeId();
private static Id rtV = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_CatalogoEventoVirtual').getRecordTypeId();
private static Id rtH = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_CatalogoEventoHibrido').getRecordTypeId();
private static Id rtEvtV = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
private static Id rtEvtF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
private static Id rtEvtH = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoHibrido').getRecordTypeId();

 @AuraEnabled
 public static Campaign getCampaign(String recordId) {

  Campaign cmp = [SELECT id, Name, Status, StartDate, EV_HoraInicio__c, EV_HoraFin__c, EV_LugarDeCelebracion__c, 
    EV_CentroPromotor__c, EV_Provincia__c, EV_CentroPromotor__r.BillingCity, 
    EV_CentroPromotor__r.BillingStreet, EV_CentroPromotor__r.BillingPostalCode, EV_CentroPromotor__r.name, EV_CentroAdminstrador__c, EV_ProgramaDeEventos__c, Type, EV_Categoria__c, EV_Cartera__c,
    EV_Description__c, EV_Encuesta__c, EV_LogoPie__c, recordtypeId, 
    (SELECT EV_Centro__c, EV_Campaign__c FROM Centros_Objetivo__r) FROM Campaign
     WHERE id = :recordId];

  return cmp;
 } 

 @AuraEnabled
 public static boolean getTraducciones(String recordId) {

    Boolean hasSpanishTranslation = false;
    Boolean hasCatalanTranslation = false;
    Boolean hasSurvey = false;
    List<EV_TraduccionDeEvento__c> traducciones = [SELECT id, EV_Evento__c,EV_Idioma__c, EV_Evento__r.EV_Encuesta__c FROM EV_TraduccionDeEvento__c WHERE EV_Evento__c= :recordId];
    for(EV_TraduccionDeEvento__c trad : traducciones){
	if(trad.EV_Idioma__c == '001'){
	    hasCatalanTranslation = true;
	}   
	else if(trad.EV_Idioma__c == '002'){
	    hasSpanishTranslation = true;
	}
	if(!String.isEmpty(trad.EV_Evento__r.EV_Encuesta__c)){
	    hasSurvey = true;
	}
    }
    if(hasSpanishTranslation && hasCatalanTranslation && hasSurvey){
		return true;
    }else{
		return false;
    }
 }
 @AuraEnabled
 public static String getProvinceValue(String provincia) {
    Map<String, String> provinciaToCorrespondingValue = new Map<String, String> {
	'A CORUÑA' => 'LA CORUÑA',
	'ALAVA' => 'ÁLAVA',
	'ALBACETE' => 'ALBACETE',
	'ALICANTE' => 'ALICANTE',
	'ALMERIA' => 'ALMERÍA',
	'ASTURIAS' => 'ASTURIAS',
	'AVILA' => 'ÁVILA',
	'BADAJOZ' => 'BADAJOZ',
	'BARCELONA' => 'BARCELONA',
	'BURGOS' => 'BURGOS',
	'CACERES' => 'CÁCERES',
	'CADIZ' => 'CÁDIZ',
	'CANTABRIA' => 'CANTABRIA',
	'CASTELLON' => 'CASTELLÓN',
	'CEUTA' => 'CEUTA',
	'CIUDAD REAL' => 'CIUDAD REAL',
	'CORDOBA' => 'CÓRDOBA',
	'CUENCA' => 'CUENCA',
	'GIRONA' => 'GERONA',
	'GRANADA' => 'GRANADA',
	'GUADALAJARA' => 'GUADALAJARA',
	'GUIPUZCOA' => 'GUIPÚZCOA',
	'HUELVA' => 'HUELVA',
	'HUESCA' => 'HUESCA',
	'ILLES BALEARS' => 'BALEARES',
	'JAEN' => 'JAÉN',
	'LA RIOJA' => 'LA RIOJA',
	'LAS PALMAS' => 'LAS PALMAS',
	'LEON' => 'LEÓN',
	'LLEIDA' => 'LÉRIDA',
	'LUGO' => 'LUGO',
	'MADRID' => 'MADRID',
	'MALAGA' => 'MÁLAGA',
	'MELILLA' => 'MELILLA',
	'MURCIA' => 'MURCIA',
	'NAVARRA' => 'NAVARRA',
	'OURENSE' => 'ORENSE',
	'PALENCIA' => 'PALENCIA',
	'PONTEVEDRA' => 'PONTEVEDRA',
	'SALAMANCA' => 'SALAMANCA',
	'SANTA CRUZ DE TENERIFE' => 'SANTA CRUZ DE TENERIFE',
	'SEGOVIA' => 'SEGOVIA',
	'SEVILLA' => 'SEVILLA',
	'SORIA' => 'SORIA',
	'TARRAGONA' => 'TARRAGONA',
	'TERUEL' => 'TERUEL',
	'TOLEDO' => 'TOLEDO',
	'VALENCIA' => 'VALENCIA',
	'VALLADOLID' => 'VALLADOLID',
	'VIZCAYA' => 'VIZCAYA',
	'ZAMORA' => 'ZAMORA',
	'ZARAGOZA' => 'ZARAGOZA'
    };

    return provinciaToCorrespondingValue.get(provincia);
}

	@AuraEnabled(cacheable= true)
    public static Integer mtBatchAltaMasiva() {
		EV_Bypass__c batch = EV_Bypass__c.getOrgDefaults();
		return Integer.valueOf(batch.EV_BatchAltaMasiva__c);
    }

	@AuraEnabled
	public static List<Campaign> createCamp(List<Contact> lstContact, Campaign camp, Integer numSe, Integer aforo, String estado, String name){
		EV_LogDebug.printLogDebug('createCamp ',String.valueof(lstContact.size())+ ' lstContact '+ String.valueof(lstContact));
		final String ALTA_MASIVA = 'Alta masiva';
		final String EV_PLACE_OF_CELEBRATION = 'Online';
		List<Campaign> campaignsToInsert = new List<Campaign>(); 

		if(!lstContact.isEmpty()){
			for (Integer i = 0; i < lstContact.size(); i++) {
				Contact contacto = lstContact[i];
				Campaign campana = camp;
			
				for(Integer x = 0; x < numSe; x ++){
					Integer ses = x +1;
					String concatName = name + ' - ' +  (contacto.Account.CC_Numero_Oficina__c != null ? contacto.Account.CC_Numero_Oficina__c : contacto.CC_Numero_Oficina__c) + ' - ' + contacto.CC_Matricula__c + (numSe > 1 ? ' Sesión ' + ses  : '');
					Campaign newCampaign = new Campaign();
					newCampaign.Name = concatName;
					newCampaign.EV_NewArchitecture__c = true;
					newCampaign.EV_Origen__c = ALTA_MASIVA;
					if(newCampaign.status == '009'){
						newCampaign.EV_FlujoPruebas__c = '001';
					}
					if(campana.RecordtypeId == rtC){
						newCampaign.EV_Aforo_espacio_fisico__c = aforo;
						newCampaign.RecordtypeId = rtEvtF;
					}else if(campana.RecordtypeId == rtV){
						newCampaign.EV_NumeroDePlazas__c = 5000;
						newCampaign.RecordtypeId = rtEvtV;
					}else if(campana.RecordtypeId == rtH){
						newCampaign.EV_NumeroDePlazas__c = 5000;
						newCampaign.EV_Aforo_espacio_fisico__c = aforo;
						newCampaign.RecordtypeId = rtEvtH;
					}
					newCampaign.Status = estado;
					newCampaign.StartDate = Date.newInstance(2020, 01, 01);
					newCampaign.EV_HoraInicio__c = Time.newInstance(00, 00, 00, 00);
					newCampaign.EV_HoraFin__c = Time.newInstance(00, 15, 00, 00);
					if(campana.RecordtypeId == rtC || campana.RecordtypeId == rtH){
						newCampaign.EV_LugarDeCelebracion__c = contacto.Account.name;
						newCampaign.EV_Provincia__c = getProvinceValue(contacto.Account.BillingCity);
						newCampaign.EV_Street__c = contacto.Account.BillingStreet;
						newCampaign.EV_CP__c = contacto.Account.BillingPostalCode;
						newCampaign.EV_City__c = contacto.Account.BillingCity;                   
						newCampaign.EV_AddressNumber__c = contacto.Account.BillingStreet != null ? String.valueOf(contacto.Account.BillingStreet.Split(',')) : '';
					}else if(campana.RecordtypeId == rtV || campana.RecordtypeId == rtEvtV){
						newCampaign.EV_LugarDeCelebracion__c = EV_PLACE_OF_CELEBRATION;
					}
					newCampaign.EV_DiaHora_evento__c = DateTime.newInstance(newCampaign.StartDate, newCampaign.EV_HoraInicio__c);
					newCampaign.EV_FechaHoraFin__c = DateTime.newInstance(newCampaign.StartDate, newCampaign.EV_HoraFin__c);
					newCampaign.EV_CentroPromotor__c = campana.EV_CentroPromotor__c;
					newCampaign.EV_CentroAdminstrador__c = campana.EV_CentroAdminstrador__c;
					newCampaign.EV_CentroOrganizador__c = contacto.AccountId;
					newCampaign.EV_ProgramaDeEventos__c = campana.EV_ProgramaDeEventos__c;
					newCampaign.Type = campana.Type;
					newCampaign.EV_Categoria__c = campana.EV_Categoria__c;
					newCampaign.EV_Cartera__c = campana.EV_Cartera__c;
					newCampaign.EV_Description__c = campana.EV_Description__c;
					newCampaign.EV_Encuesta__c = campana.EV_Encuesta__c;
					newCampaign.EV_LogoPie__c = campana.EV_LogoPie__c;
					newCampaign.EV_Notification__c = '001';
					newCampaign.EV_FlujoPruebas__c = '003';
					newCampaign.ParentId = campana.Id;
					if(contacto.AV_UsuarioAsociado__c != null){
						newCampaign.OwnerId = contacto.AV_UsuarioAsociado__c; 
					}
				
					campaignsToInsert.add(newCampaign);
				}
			}
			EV_LogDebug.printLogDebug('campaignsToInsert ',String.valueof(campaignsToInsert.size()));
		}
		return campaignsToInsert;
	}

	@AuraEnabled
	public static void generarTraduccionesEventoHijo(List<Id> idsHijos, Id cmpParent) {
        EV_LogDebug.printLogDebug('generarTraduccionesEventoHijo ',String.valueof(idsHijos)+ ' cmpParent' + String.valueof(cmpParent));
        if(cmpParent != null && !idsHijos.isEmpty()){
            List<EV_TraduccionDeEvento__c> traducciones = [select EV_AntetituloCategoria__c, Name,EV_Descripcion__c, EV_Evento__c, EV_Idioma__c, EV_ImagenCabecera__c, EV_SinopsisInvitacion__c,EV_URLDeImagen__c, EV_URLImagenInvitacion__c, EV_URLVideoTeaser__c, EV_Claim__c, EV_TextoBoton__c, EV_TextoDebajoBoton__c, 
                                                  EV_TextoDescriptivoBoton__c, EV_TextoOnClick__c, EV_URLImagenCarrusel__c, EV_URLImagenGrande__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLNegocioPromotor__c, EV_URLLogoPie__c, 
                                                  EV_TituloVideoTeaser__c, EV_DescripcionVideoTeaser__c from EV_TraduccionDeEvento__c where EV_Evento__c = :cmpParent];
        
            if(!traducciones.isEmpty()){
                List<EV_TraduccionDeEvento__c> lstTraduccionesInsert = new List<EV_TraduccionDeEvento__c>();
                for(EV_TraduccionDeEvento__c trad : traducciones){
                    for(Id ids : idsHijos){
                        EV_TraduccionDeEvento__c traduccion = trad.clone();
                        traduccion.EV_Evento__c = ids;
                        traduccion.Name = trad.Name;
                        lstTraduccionesInsert.add(traduccion);
                    }
                }
                insert lstTraduccionesInsert;
            }
        }
    }

	@AuraEnabled
	public static List<Id> centros(Campaign camp){
		Set<Id> centrosAdd = new Set<Id>();
		for( Centro_Objetivo__c lstCentro : [SELECT EV_Centro__c, EV_Campaign__c, EV_Campaign__r.EV_CentroPromotor__c FROM Centro_Objetivo__c WHERE EV_Campaign__c =: camp.id]){
			centrosAdd.add(lstCentro.EV_Centro__c);
		}
		return new List<Id>(centrosAdd);
	}

	@AuraEnabled
	public static void shareCampaign(List<Campaign> listNews){
	EV_LogDebug.printLogDebug('shareCampaign ',String.valueof(listNews));
	  Map<Id,List<String>> campaignCentros = new Map<Id,List<String>>();
		if(!listNews.isEmpty()){
		  for(Campaign c : listNews){
			 List<String> centros = new List<String>();
			 if(!String.isEmpty(c.EV_CentroOrganizador__c)){centros.add(c.EV_CentroOrganizador__c);}
			 if(!String.isEmpty(c.EV_CentroPromotor__c)) {centros.add(c.EV_CentroPromotor__c);}
			 if(!String.isEmpty(c.EV_CentroAdminstrador__c)) {centros.add(c.EV_CentroAdminstrador__c);}
			 if(!centros.isEmpty()) {campaignCentros.put(c.Id, centros);}
		  }
		}
		EV_LogDebug.printLogDebug('shareCampaign campaignCentros',String.valueof(campaignCentros));
		if(!campaignCentros.isEmpty()){
		  sharingCampaignApex(JSON.serialize(campaignCentros));
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
                        if (mapCons.containsKey(centroAccountId)) {
						for (String usuario : mapCons.get(centroAccountId)) {
							if(!campaignEmployees.containsKey(camp)){
								campaignEmployees.put(camp, new Set<String>{usuario});
							}else{
								campaignEmployees.get(camp).add(usuario);
							}
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

	@AuraEnabled
	public static Integer saveRecords(List<Campaign> listCampaign, List<Id> centrosAdd, Campaign campPadre){
		EV_LogDebug.printLogDebug('saveRecords ',String.valueof(listCampaign) + ' campPadre ' + String.valueof(campPadre) +  ' centrosAdd ' + String.valueof(centrosAdd));
		Integer resultado = 0;

		if (!listCampaign.isEmpty()) {
			List<Centro_Objetivo__c> centroObj = new List<Centro_Objetivo__c>();
			Integer exito = 1;
			Integer err = 0;

			Database.SaveResult[] saveResults = Database.insert(listCampaign, false);
			Map<String, String> msgError = new Map<String, String>();
			Set<Id> idCmpInsert = new Set<Id>();
			List<Id> campInsertados = new List<Id>();
			List<Campaign> lstCampCreate = new List<Campaign>();
			for (Database.SaveResult result : saveResults) {
				if (result.isSuccess()) {
					campInsertados.add(result.getId());
					for(Id valor :centrosAdd){
						idCmpInsert.add(result.getId());

						Centro_Objetivo__c customObject = new Centro_Objetivo__c(
						EV_Centro__c = valor, 
						EV_Campaign__c = result.getId()
						);
						centroObj.add(customObject);
					}
					resultado = exito++; 
				} 
				else {
					for (Database.Error error : result.getErrors()) {
						EV_LogDebug.printLogDebug('Error al insertar registro: ',String.valueof(error.getMessage()));
						msgError.put(String.valueof(error.getStatusCode()), error.getMessage());
					}
					resultado = err++; 
				}
			}
			if(!campInsertados.isEmpty()){
				EV_LogDebug.printLogDebug('saveRecordsgenerarTraduccionesEventoHijo ',String.valueof(campInsertados) + ' campPadre ' + String.valueof(campPadre.Id));
				generarTraduccionesEventoHijo(campInsertados, campPadre.Id);
			}

			List<Campaign> lstShareC = new List<Campaign> ();
			for(List<Campaign> campInsert : [Select id, EV_CentroOrganizador__c, EV_CentroPromotor__c, EV_CentroAdminstrador__c  from Campaign where id in :idCmpInsert and EV_CentroOrganizador__c != null]){
				for(Campaign cmp :campInsert){
					Centro_Objetivo__c customObject = new Centro_Objetivo__c(
					EV_Centro__c = cmp.EV_CentroOrganizador__c, 
					EV_Campaign__c = cmp.id
					);
					centroObj.add(customObject);
					lstShareC.add(cmp);
				}
			}
			if(!lstShareC.isEmpty()){
				shareCampaign(lstShareC);
			}
		
			EV_LogDebug.printLogDebug('Centros Objetivos size: ',String.valueof(centroObj.size()));
			if (!centroObj.isEmpty()) {
				Database.SaveResult[] customObjectSaveResults = Database.insert(centroObj, false);
				for (Database.SaveResult result : customObjectSaveResults) {
					if (!result.isSuccess()) {
						for (Database.Error error : result.getErrors()) {
							EV_LogDebug.printLogDebug('Error al insertar registro: ',String.valueof(error.getMessage()));
							msgError.put(String.valueof(error.getStatusCode()), error.getMessage());
						}
					}
				}
				if (!msgError.isEmpty()){
					CBK_Log.error(msgError);
				}
			}
		}
		return resultado;
	}
}