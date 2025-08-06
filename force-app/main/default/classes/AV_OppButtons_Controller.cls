/**********************************************************************************************************************
Name:	  AV_OppButtons_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_OppButtons
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Gonzalo Ávila    	10/07/2024		Init version
1.1			Fix				Sandra Gómez		26/09/2024		Change method getEnlaces to replace good pea and created methods getOppToLinks and generateURL
***********************************************************************************************************************/
public with sharing class AV_OppButtons_Controller {
	public class InfoAyuda {
		@AuraEnabled
		public String pea;
		@AuraEnabled
		public String pea2;
		@AuraEnabled
		public String urlPEA;
		@AuraEnabled
		public String urlPEA2;
		@AuraEnabled
		public String labelPEA;
		@AuraEnabled
		public String labelPEA2;
	}

	@AuraEnabled
	public static String getArgumentario(String oppId) {
		Product2 product = AV_LinkArgumentario_Controller.getProductData(oppId);
		String url = product.AV_URLArgumentario__c;
		return url;
	}

	@AuraEnabled
	public static List<AV_Simulador__c> getEnlaces(String oppId) {
		List<AV_Simulador__c> filteredEnlaces = new List<AV_Simulador__c>();
		Map<String,AV_Simulador__c> filteredPeas = new Map<String,AV_Simulador__c>();
		List<String> filteredPeasId = new List<String>();
		List<Opportunity> opp = [SELECT AV_PF__c, AccountId FROM Opportunity WHERE Id = :oppId LIMIT 1];
		if (opp != null && !opp.isEmpty() && opp[0].AV_PF__c != null) {
			List<AV_Simulador__c> enlaces = [SELECT Id, Name, AV_URL__c, AV_PEA__c, AV_URL_PEA__c, AV_Color__c, AV_Orden__c, AV_Fecha_Inicio__c, AV_Fecha_fin__c FROM AV_Simulador__c WHERE AV_Producto__c = :opp[0].AV_PF__c WITH SECURITY_ENFORCED ORDER BY AV_Orden__c DESC];
			if (enlaces!= null && !enlaces.isEmpty()) {
				Date currentDate = Date.today();
				for (AV_Simulador__c enlace : enlaces) {
					if ((enlace.AV_Fecha_Inicio__c == null || enlace.AV_Fecha_Inicio__c <= currentDate) && (enlace.AV_Fecha_fin__c == null || enlace.AV_Fecha_fin__c >= currentDate)) {
						if (enlace.AV_URL_PEA__c != 'PEA') {
							filteredEnlaces.add(enlace);
						} else {
							filteredPeas.put(enlace.AV_PEA__c,enlace);
							filteredPeasId.add(enlace.AV_PEA__c);
						}
					}
				}
				if (filteredPeas != null && !filteredPeas.isEmpty()) {
					List<CIBE_Section_Link__mdt> listSectionsLinks = [SELECT id, Label, CIBE_Link_Reference__c, CIBE_Section_Reference__c FROM CIBE_Section_Link__mdt where CIBE_Section_Reference__r.CIBE_Setting__c = 'AV_0004' and CIBE_Link_Reference__r.CIBE_Active__c = true WITH SECURITY_ENFORCED];
					if (listSectionsLinks != null && !listSectionsLinks.isEmpty()) {
						List<String> listSections = new List<String>();
						for(CIBE_Section_Link__mdt sectionLink : listSectionsLinks) {
							listSections.add(sectionLink.CIBE_Link_Reference__c);
						}
						List<CIBE_Link__mdt> listLink = [SELECT id, CIBE_Order__c, CIBE_Parameters__c, CIBE_Title__c, CIBE_URL__c, CIBE_URL_Long__c  FROM CIBE_Link__mdt where Id IN :listSections and CIBE_Active__c = true WITH SECURITY_ENFORCED ORDER BY CIBE_Order__c ASC];
						Map<Id, CIBE_Link__mdt> links = new Map<Id, CIBE_Link__mdt>();
						if (listLink != null && !listLink.isEmpty()) {
							for (CIBE_Link__mdt linkMdt : listLink) {
								if ((linkMdt.CIBE_URL_Long__c!= null && filteredPeasId.contains(linkMdt.CIBE_URL_Long__c)) || (linkMdt.CIBE_URL__c != null && filteredPeasId.contains(linkMdt.CIBE_URL__c)))
								links.put(linkMdt.Id,linkMdt);
							}
						}
						if (links != null && !links.isEmpty()) {
							ResultAccOpp listsOppAcc = getOppToLinks(links,oppId,opp[0].AccountId);
							//revisar si esta en paramsStatic
							String empContacto = [SELECT AV_ExternalID__c FROM USER WHERE Id = :UserInfo.getUserId()  WITH SECURITY_ENFORCED LIMIT 1].AV_ExternalID__c;
        					empContacto = String.isNotBlank(empContacto) ? empContacto.removeStart('U01') : '';
							for (String linkData : links.keySet()) {
								if (String.isBlank(links.get(linkData).CIBE_URL_Long__c)) {
									filteredPeas.get(links.get(linkData).CIBE_URL__c).AV_PEA__c = generateURL(links.get(linkData).CIBE_URL__c, links.get(linkData).CIBE_Parameters__c,listsOppAcc.listOpp,listsOppAcc.listAcc,empContacto);
									filteredEnlaces.add(filteredPeas.get(links.get(linkData).CIBE_URL__c));
								} else {
									filteredPeas.get(links.get(linkData).CIBE_URL_Long__c).AV_PEA__c = generateURL(links.get(linkData).CIBE_URL_Long__c, links.get(linkData).CIBE_Parameters__c,listsOppAcc.listOpp,listsOppAcc.listAcc,empContacto);
									filteredEnlaces.add(filteredPeas.get(links.get(linkData).CIBE_URL_Long__c));
								}
							}
						}
					}
				}
			}
		}
		return filteredEnlaces; 
	}

	/**
     * Generate Opps to dynamic parameters from JSON configuration
     */
	private static ResultAccOpp getOppToLinks(Map<Id, CIBE_Link__mdt> links, String oppId, String accId) {
		String methodName = 'getOppToLinks';
		List<Opportunity> listOpp = new List<Opportunity>();
		List<Account> listAcc = new List<Account>();
		ResultAccOpp result = new ResultAccOpp();
		String queryFields='Id ';
		String queryFieldsAcc='Id ';

		for (String linkData: links.keySet()) {
			Obj wrapper = (Obj) System.JSON.deserialize(links.get(linkData).CIBE_Parameters__c, Obj.class);
			if (wrapper.sObj == 'Account') {
				for(RType rt : wrapper.recordTypes) {
					if(rt.params != null){
						for(String key : rt.params.keySet()) {
							if (!queryFieldsAcc.contains(rt.params.get(key))) {
								queryFieldsAcc += ',' + rt.params.get(key);
							}
						}
					}
				}
			} else {
				for(RType rt : wrapper.recordTypes) {
					if(rt.params != null){
						for(String key : rt.params.keySet()) {
							if (!queryFields.contains(rt.params.get(key))) {
								queryFields += ',' + rt.params.get(key);
							}
						}
					}
				}
			}
		}
		if (queryFieldsAcc != 'Id ') {
			String soqlQuery = 'SELECT '+queryFieldsAcc+' FROM Account WHERE Id = :accId';
			AV_LogDebug.printLogDebug(methodName, 'soqlQuery: ' + soqlQuery);
			listAcc = (List<Account>) Database.query(soqlQuery);
		}
		if (queryFields != 'Id ') {
			String soqlQuery2 = 'SELECT '+queryFields+' FROM Opportunity WHERE Id = :oppId';
			AV_LogDebug.printLogDebug(methodName, 'soqlQuery2: ' + soqlQuery2);
			listOpp = (List<Opportunity>) Database.query(soqlQuery2);
		}
		result.listAcc = listAcc;
		result.listOpp = listOpp;
		return result;
	}

	public class ResultAccOpp {
		@AuraEnabled
		public List<Account> listAcc;
		@AuraEnabled
		public List<Opportunity> listOpp;
	}

	/**
     * Generate URL with dynamic parameters from JSON configuration
     */
    private static String generateURL(String url, String parameters, List<Opportunity> resultOpp, List<Account> resultAcc, String empContacto){
        String methodName = 'generateURL';
        Obj wrapper = (Obj) System.JSON.deserialize(parameters, Obj.class);
        AV_LogDebug.printLogDebug(methodName, 'Parameters:' + parameters);
        Map<String, String> mapParams =  new Map<String, String>();
        Map<String, String> mapStaticParams =  new Map<String, String>();

        for(RType rt : wrapper.recordTypes) {
			if(rt.params != null){
				for(String key : rt.params.keySet()) {
					mapParams.put(key, rt.params.get(key));
				}
			}
			if(rt.staticParams != null){
				for(String key : rt.staticParams.keySet()) {
					if(key != 'empContacto'){
						mapStaticParams.put(key, rt.staticParams.get(key));
					}else{
						mapStaticParams.put(key, empContacto);
					}
				}
			}
        }
        AV_LogDebug.printLogDebug(methodName, 'mapParams: ' + mapParams);
        AV_LogDebug.printLogDebug(methodName, 'mapStaticParams: ' + mapStaticParams);
		if (wrapper.sObj == 'Account') {
			for(String key : mapParams.keySet()){
				if(url.contains('{'+key+'}') && (String)resultAcc[0].get(mapParams.get(key))!=null){
					url = url.replace('{'+key+'}', (String)resultAcc[0].get(mapParams.get(key)));
				}
			}
		} else {
			for(String key : mapParams.keySet()){
				if(url.contains('{'+key+'}') && (String)resultOpp[0].get(mapParams.get(key))!=null){
					url = url.replace('{'+key+'}', (String)resultOpp[0].get(mapParams.get(key)));
				}
			}
		}
		for(String key : mapStaticParams.keySet()){
			if(url.contains('{'+key+'}')){
				url = url.replace('{'+key+'}', mapStaticParams.get(key));
			}
		}
        return url;
    }

	/**
     * Estructura de datos utilizada en el JSON de configuracion de la URL
     */
    public class Obj {
        public String sObj;
        List<RType> recordTypes;
    }

    public class RType {
        String recordType;
        Map<String, String> params;
        Map<String, String> staticParams;
    }

	@AuraEnabled(cacheable = true)
	public static InfoAyuda getAyuda(String oppId, String objectApiName){
		InfoAyuda info = new InfoAyuda();
		Opportunity opp = [SELECT AV_PEA__c, AV_PEA2__c FROM Opportunity WHERE Id=: oppId WITH SECURITY_ENFORCED];
		if(opp.AV_PEA__c != null){
			AV_LinkOperativoController.LinksOperativos linkopPEA = AV_LinkOperativoController.getOppLinkPEA(oppId, objectApiName, 'AV_PEA__c');
			info.pea = 'AV_PEA__c';
			info.labelPEA = linkopPEA.label;
			info.urlPEA = linkopPEA.url;
		}
		if(opp.AV_PEA2__c != null){
			AV_LinkOperativoController.LinksOperativos linkopPEA2 = AV_LinkOperativoController.getOppLinkPEA(oppId, objectApiName, 'AV_PEA2__c');
			info.pea2 = 'AV_PEA2__c';
			info.labelPEA2 = linkopPEA2.label;
			info.urlPEA2 = linkopPEA2.url;
		}
		return info;
	}
}