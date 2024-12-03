/**********************************************************************************************************************
Name:	  AV_LinkOperativoController
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_LinkOperativo
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Esperanza Conde 	24/09/2020		Init version
1.1			Init    		Esperanza Conde 	15/10/2020		Order by AV_Orden__c
1.2         US128324        Esperanza Conde     26/10/2020      Dynamic url
1.3         US132967        Jashanpreet         10/11/2020      Changed AV_LinkOperativoTF9__mdt query 
1.4		    AV_Query IT	    Daniel Rodríguez	04/02/2022	    Change AV_Query to SOQL for User and Account
1.5			US340409 		Daniel Rodríguez 	22/03/2022		Add new method getLinksLeadOpps
1.6			CIBE			Jose María Perez	25/05/2022		Logical Change to automate using Metadata
1.7         US388344        Luis Fernández      10/07/2022      Modified getUrl and GetLinks 
1.8			US449813 		Vladislav Lityagin	05/10/2022		Modified generateUrl
1.9         US618631        Beatriz Ruiz        18/10/2023      Modified getLinks for adding new field CIBE_URL_Long__c
2.0         Fix PMD Errors  Humberto Vilchez    23/10/2023      Add WITH SECURITY_ENFORCED to queries
2.1         US587375        Oscar Moreno        03/11/2023      Modify getLinks method. links are sorted based on PS AV_PrivateBanking and AV_CarteraPOT__c field
2.2			US701075        Lucia Muñoz      	02/02/2024		Modify getOppLinkPEA method
2.3         Fix             Sandra Gómez        06/05/2024      Modify method getLinks if hasCustomPermission2 continue lista operativa
2.4         FIX05090942     Ángel Medina        05/09/2024       Modify method getLinks to solve error List has no rows for assignment to Sobject
***********************************************************************************************************************/
public with sharing class AV_LinkOperativoController {
    
    public class LinksOperativos {
		@AuraEnabled
		public String url;
		@AuraEnabled
		public String label;
	}

    //Estructura de datos que se devuelve al componente para representar un link
    public class LinkData{
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public String label{get;set;}
    } 

    //Estructura de datos que se devuelve al componente para representacion una seccion de links
        public class Section implements Comparable{
            @AuraEnabled
            public String columns{get;set;}
            @AuraEnabled
            public String collapse{get;set;}
            @AuraEnabled
            public String title{get;set;}
            @AuraEnabled
            public String name{get;set;}
            @AuraEnabled
            public List<LinkData> links{get;set;}
            @AuraEnabled
            public Decimal order{get;set;}
            public Integer compareTo(Object compareTo) {
                
                Section compareToOppy = (Section)compareTo;
                
                Integer returnValue = 0;
                if (this.order > compareToOppy.order) {
                    returnValue = 1;
                } else if (this.order < compareToOppy.order) {
                    returnValue = -1;
                } else if ((this.order == null) && (compareToOppy.order != null)){
                    returnValue = -1;
                } else if ((this.order != null) && (compareToOppy.order == null)){
                    returnValue = 1;
                }        
                return returnValue;       
            }
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
    
    /**
     * Comparable for ordering links inside sections
     */
    public class ReferenceWrapper implements Comparable {
		String reference{get;set;}
        Decimal order{get;set;}
		
        public ReferenceWrapper(String reference, Decimal order) {
            this.reference = reference;
            this.order = order;
        }   
        
        public Integer compareTo(Object compareTo) {
            ReferenceWrapper compareToOppy = (ReferenceWrapper)compareTo;
            
            Integer returnValue = 0;
            if (this.order > compareToOppy.order) {
                returnValue = 1;
            } else if (this.order < compareToOppy.order) {
                returnValue = -1;
            } else if ((this.order == null) && (compareToOppy.order != null)){
                returnValue = -1;
            } else if ((this.order != null) && (compareToOppy.order == null)){
                returnValue = 1;
            }        
            return returnValue;       
        }
    }
    
    /**
     * 
     * Estructura los links desde la configuracion del metadata para poder representarlos en el front.
     * 
     * @seccion: API Name del objeto al que pertenece la flexi en la que está el componente
     * @filterObject: API Name del objeto sobre el que buscar los parametros
     * @customerId: Id del objeto sobre el que se quiere filtrar
     * @parentId: Id del objeto que se está viendo en Salesforce
     * @setting: Setting configurada en la flexi
     */
    @AuraEnabled(cacheable=true)
    public static List<Section> getLinks(String seccion, String filterObject, String customerId, String parentId, String setting) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_PrivateBanking');
        Boolean hasCustomPermission2 = FeatureManagement.checkPermission('AV_LinkListaOperativa');
        String empContacto = [SELECT AV_ExternalID__c FROM USER WHERE Id = :UserInfo.getUserId()  WITH SECURITY_ENFORCED LIMIT 1].AV_ExternalID__c;
        empContacto = String.isNotBlank(empContacto) ? empContacto.removeStart('U01') : '';
        Boolean hasCarteraPotField = false;
        
        if(seccion == AV_AppConstants.OBJECT_NAME_ACCOUNT){
           if(!String.isBlank(parentId)){
               Account acc = [SELECT Id,AV_CarteraPOT__c FROM Account WHERE Id =: parentId LIMIT 1];
               hasCarteraPotField = acc.AV_CarteraPOT__c;
            }
        }

        Map<Id, CIBE_Section__mdt> mapSection = new Map<Id, CIBE_Section__mdt>([SELECT Id, Label, CIBE_Collapse__c, CIBE_Collumns__c, CIBE_Title__c, CIBE_Order__c FROM CIBE_Section__mdt where CIBE_Active__c=true and CIBE_Setting__c=: setting WITH SECURITY_ENFORCED ORDER BY CIBE_Order__c ASC]);    

        List<CIBE_Section_Link__mdt> listSectionsLinks = [SELECT id,Label, CIBE_Link_Reference__c, CIBE_Section_Reference__c FROM CIBE_Section_Link__mdt where CIBE_Section_Reference__c =:mapSection.keySet() and CIBE_Link_Reference__r.CIBE_Active__c = true WITH SECURITY_ENFORCED];

		Set<Id> listSections = new Set<Id>(); 
        
        for(CIBE_Section_Link__mdt sectionLink : listSectionsLinks){
            listSections.add(sectionLink.CIBE_Link_Reference__c);
        }
      

        Map<Id, CIBE_Link__mdt> mapLinks =new Map<Id, CIBE_Link__mdt>([SELECT id, CIBE_Order__c, CIBE_Parameters__c,  CIBE_Title__c,CIBE_URL__c, CIBE_URL_Long__c  FROM CIBE_Link__mdt where Id=:listSections and CIBE_Active__c = true WITH SECURITY_ENFORCED ORDER BY CIBE_Order__c ASC]);
        Map<Id, List<ReferenceWrapper>> mapSectionLink = new Map<Id, List<ReferenceWrapper>>();
       

        for(CIBE_Section_Link__mdt sectionLink : listSectionsLinks){
            if(!mapSectionLink.containsKey(sectionLink.CIBE_Section_Reference__c)){
                mapSectionLink.put(sectionLink.CIBE_Section_Reference__c, new List<ReferenceWrapper>());
            }
            mapSectionLink.get(sectionLink.CIBE_Section_Reference__c).add(
                new ReferenceWrapper(sectionLink.CIBE_Link_Reference__c, mapLinks.get(sectionLink.CIBE_Link_Reference__c).CIBE_Order__c)
                );
        }
 
        for(List<ReferenceWrapper> sets : mapSectionLink.values()) {
            sets.sort();
        }
        List<Section> listSectionsReturn= new  List<Section>();
       
        sObject obj = Database.query('SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName FROM ' + String.escapeSingleQuotes(filterObject) + ' WHERE Id = :customerId LIMIT 1');
        RecordType rtName = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id =: ((String)obj.get('RecordTypeId')) WITH SECURITY_ENFORCED LIMIT 1];

        List<String> translationSectionNames = new List<String>();
        for(Id key : mapSectionLink.keySet()) {
            translationSectionNames.add(String.isNotBlank(mapSection.get(key).CIBE_Title__c) ? mapSection.get(key).CIBE_Title__c : null);
        }
        
        List<String> translationLinkNames = new List<String>();
        for(CIBE_Link__mdt link : mapLinks.values()) {
            translationLinkNames.add(String.isNotBlank(link.CIBE_Title__c) ? link.CIBE_Title__c : null);
        }

        Map<String, String> sectionTranslations = CIBE_TranslationUtilities.getInstance().addTranslationNames(translationSectionNames).queryTranslations().getTranslations();
        Map<String, String> linkTranslations = CIBE_TranslationUtilities.getInstance().addTranslationNames(translationLinkNames).queryTranslations().getTranslations();

        for(Id key :mapSectionLink.keySet()) {
            Section sect=new Section();
            sect.columns = 'slds-col slds-p-bottom_small slds-size_1-of-' + String.valueOf(((Integer) mapSection.get(key).CIBE_Collumns__c));
            sect.collapse = mapSection.get(key).CIBE_Collapse__c ? mapSection.get(key).CIBE_Title__c : '';
            sect.title = sectionTranslations.containsKey(mapSection.get(key).CIBE_Title__c) && String.isNotBlank(sectionTranslations.get(mapSection.get(key).CIBE_Title__c)) ? sectionTranslations.get(mapSection.get(key).CIBE_Title__c) : mapSection.get(key).CIBE_Title__c;
            sect.name = String.isNotBlank(mapSection.get(key).CIBE_Title__c) ? mapSection.get(key).CIBE_Title__c : '-';
            sect.links = new List<LinkData>();
            sect.order = mapSection.get(key).CIBE_Order__c;
            
            
            for(ReferenceWrapper rw : mapSectionLink.get(key)){
                Id linkData = rw.reference;
                LinkData lkData= new LinkData();
                
                String tipoURL = String.isBlank(mapLinks.get(linkData).CIBE_URL_Long__c) ? mapLinks.get(linkData).CIBE_URL__c: mapLinks.get(linkData).CIBE_URL_Long__c;
                if(mapLinks.get(linkData).CIBE_Title__c.equals('Mis Clientes')){
                    lkData.url = '/';
                }else{
                    lkData.url = generateURL(mapLinks.get(linkData).CIBE_Title__c, tipoURL, mapLinks.get(linkData).CIBE_Parameters__c, filterObject, customerId, rtName,empContacto,setting);              
                 
                }
                lkData.label = linkTranslations.containsKey(mapLinks.get(linkData).CIBE_Title__c) && String.isNotBlank(linkTranslations.get(mapLinks.get(linkData).CIBE_Title__c)) ? linkTranslations.get(mapLinks.get(linkData).CIBE_Title__c) : mapLinks.get(linkData).CIBE_Title__c;
                // the user doesn´t have AV_PrivateBanking PS
                if (!hasCustomPermission) {
                    if (lkData.label != Label.AV_Acceso_Ficha_POT) {
                        sect.links.add(lkData);
                    }
                }
                
                // the user has AV_PrivateBanking PS 
                else {
                    if(lkData != null && lkData.label != null){
                        if (lkData.label == Label.AV_Expte_Premier_Privada || (lkData.label == Label.AV_Acceso_Ficha_POT)) {
                            if (lkData.label == Label.AV_Expte_Premier_Privada) {
                                sect.links.add(0,lkData);
                            } 
                            if (lkData.label == Label.AV_Acceso_Ficha_POT && hasCarteraPotField) {
                                sect.links.add(lkData);
                            }
                        } else {
                            sect.links.add(lkData);
                        }            
                    }
                }
            }
            listSectionsReturn.add(sect);
        }
        listSectionsReturn.sort();
        return listSectionsReturn; 
        
    }

    /**
     * 
     * Estructura los links desde la configuracion del metadata para poder representarlos en el front.
     * 
     * @seccion: API Name del objeto al que pertenece la flexi en la que está el componente
     * @filterObject: API Name del objeto sobre el que buscar los parametros
     * @customerId: Id del objeto sobre el que se quiere filtrar
     * @setting: Setting configurada en la flexi
     */
    @AuraEnabled
    public static LinkData getCaixaBankURL(String filterObject, String customerId,String setting) {
        String empContact = [SELECT AV_ExternalID__c FROM USER WHERE Id = :UserInfo.getUserId()  WITH SECURITY_ENFORCED LIMIT 1].AV_ExternalID__c;
        empContact = String.isNotBlank(empContact) ? empContact.removeStart('U01') : '';
        sObject obj = Database.query('SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName FROM ' + String.escapeSingleQuotes(filterObject) + ' WHERE Id = :customerId LIMIT 1');
        RecordType rtName = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id =: ((String)obj.get('RecordTypeId')) WITH SECURITY_ENFORCED LIMIT 1];
    
        CIBE_Link__mdt caixaBankNowLink = [SELECT CIBE_Title__c, CIBE_URL__c, CIBE_URL_Long__c, CIBE_Parameters__c FROM CIBE_Link__mdt WHERE DeveloperName = 'CaixaBankNow' LIMIT 1];
    
        String tipoURL = String.isBlank(caixaBankNowLink.CIBE_URL_Long__c) ? caixaBankNowLink.CIBE_URL__c : caixaBankNowLink.CIBE_URL_Long__c;
        LinkData caixaBankNowLinkData = new LinkData();
        caixaBankNowLinkData.url = generateURL(caixaBankNowLink.CIBE_Title__c, tipoURL, caixaBankNowLink.CIBE_Parameters__c, filterObject, customerId, rtName, empContact, setting);
    
        return caixaBankNowLinkData;
    }

    /**
     * Generate URL with dynamic parameters from JSON configuration
     */
    private static String generateURL(String title, String url, String parameters, String filterObject, String filterId, RecordType rtName,String empContacto, String setting){
        String methodName = 'generateURL';
        Obj wrapper = (Obj) System.JSON.deserialize(parameters, Obj.class);
        AV_LogDebug.printLogDebug(methodName, 'Parameters:' + parameters);
        Map<String, String> mapParams =  new Map<String, String>();
        Map<String, String> mapStaticParams =  new Map<String, String>();
        String queryFields='Id ';
        for(RType rt : wrapper.recordTypes) {
            if(String.isBlank(rt.recordType) || (String.isNotBlank(rt.recordType) && rt.recordType.equals(rtName.developername))){
                if(rt.params != null){
                    for(String key : rt.params.keySet()) {
                        mapParams.put(key, rt.params.get(key));
                        queryFields += ',' + rt.params.get(key);
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
        }    

        AV_LogDebug.printLogDebug(methodName, 'mapParams: ' + mapParams);
        AV_LogDebug.printLogDebug(methodName, 'mapStaticParams: ' + mapStaticParams);

        SObject result = null;

        if(queryFields.contains('AV_Lead__')){
            String query = 'SELECT '+queryFields;
            query += ' FROM ' + filterObject;
            query += ' WHERE Id = :filterId';
            AV_LeadOpportunity__c lo = Database.query(query);

            Lead l = [SELECT Id, AV_numperso__c FROM Lead WHERE Id=:lo.AV_Lead__c WITH SECURITY_ENFORCED];
            Account acc = [SELECT Id, FirstName, LastName, AV_NumPerso__c, CC_Numero_Documento__c FROM Account WHERE Id=:l.AV_numperso__c WITH SECURITY_ENFORCED];
            result = lo;
            for(String key : mapParams.keySet()){
                if(mapParams.get(key).contains('Lead__r')){
                    String keyString = (String) mapParams.get(key);
                    String field = keyString.substringAfter('.').substringAfter('.');
                    if(url.contains('{'+key+'}') && (String)acc.get(field)!=null){
                        url = url.replace('{'+key+'}', (String)acc.get(field));
                    }
                }else{
                    if(url.contains('{'+key+'}') && (String)acc.get(mapParams.get(key))!=null){
                        url = url.replace('{'+key+'}', (String)acc.get(mapParams.get(key)));
                    }
                }
            }

            for(String key : mapStaticParams.keySet()){
                if(url.contains('{'+key+'}')){
                    url = url.replace('{'+key+'}', mapStaticParams.get(key));
                }
            }
        }else{
            String soqlQuery = 'SELECT '+queryFields;
            soqlQuery += ' FROM ' + filterObject;
            soqlQuery += ' WHERE Id = :filterId';
            result = Database.query(soqlQuery);
            for(String key : mapParams.keySet()){
                if(url.contains('{'+key+'}') && (String)result.get(mapParams.get(key))!=null){
                    url = url.replace('{'+key+'}', (String)result.get(mapParams.get(key)));
                }
            }
            
            for(String key : mapStaticParams.keySet()){
                if(url.contains('{'+key+'}')){
                    url = url.replace('{'+key+'}', mapStaticParams.get(key));
                }
            }
        }
        if(setting.equals('AV0001')){
            url = url.replaceAll( '\\s+', '%20'); 
        }else if(setting.equals('AV0002')){
            url = url.replaceAll('nombre%3D', 'nombreCliente=');
            url = url.replaceAll( '\\s+', '+');
        }
        return url;
        
    }

    

    /**
	 * Retrieves the link and label from fields AV_PEA__c and AV_PEA2__c
	 */
	@AuraEnabled
	public static LinksOperativos getOppLinkPEA(String id,String objApiName,String peaF) {

        String methodName = 'getObjectLinkPEA2';
        String parteFija = null;
        String pea= null;
		String pea2 = null;
		List<Opportunity> opp = new List<Opportunity>();
		List<Task> tsk = new List<Task>();
		List<Event> evt = new List<Event>();
        LinksOperativos loPEA = new LinksOperativos();  
        LinksOperativos loPEA2 = new LinksOperativos();


        if(peaF.contains('AV_PEA__c')){
            if(objApiName.equals('Opportunity')){
                opp = [SELECT Id, AV_PEA__c,Name FROM Opportunity WHERE Id = :id WITH SECURITY_ENFORCED limit 1];
                if (opp != null) {
                    pea=opp[0].AV_PEA__c;        
                }
            }else if(objApiName.equals('Task')){
                tsk = [SELECT Id, AV_PEA__c FROM Task WHERE Id = :id WITH SECURITY_ENFORCED limit 1];
                if (tsk != null) {
                    pea= tsk[0].AV_PEA__c;                   
                }
            }else if(objApiName.equals('Event')) {
                evt = [SELECT Id, AV_PEA__c FROM Event WHERE Id = :id WITH SECURITY_ENFORCED limit 1];
                if (evt != null) {
                    pea= evt[0].AV_PEA__c;                    
                }
            }
        }else if(peaF.contains('AV_PEA2__c')){
            if(objApiName.equals('Opportunity')){
                opp = [SELECT Id, AV_PEA2__c,Name FROM Opportunity WHERE Id = :id WITH SECURITY_ENFORCED limit 1];
                if (opp != null) {
                    pea2=opp[0].AV_PEA2__c;                 
                }
            }else if(objApiName.equals('Task')){
                tsk = [SELECT Id, AV_PEA2__c FROM Task WHERE Id = :id WITH SECURITY_ENFORCED limit 1];
                if (tsk != null) {
                    pea2= tsk[0].AV_PEA2__c;
                }
            }
        }

        

        if ((opp != null || tsk != null || evt != null) && ( pea2 != null || pea != null)) {
			parteFija =  [SELECT AV_URL__c FROM AV_ParteFijaPEA__mdt where DeveloperName='AV_Header_PEA_Link'  LIMIT 1].AV_URL__c; //no soporta getInstance
            if(pea!=null && pea.startsWith('01') ){


                String[] peaInfo = pea.split('\\{\\|}');  // splits by {|} 
                loPEA.url = (peaInfo != null && peaInfo.size() == 3) ? (String.isNotBlank(peaInfo[2])  && parteFija != null ? parteFija + ''+ peaInfo[2] : '') : '';
                loPEA.label = (peaInfo != null && peaInfo.size() == 3) ? (String.isNotBlank(peaInfo [1]) ? peaInfo [1] : '') : '';

            }else if (pea!=null && pea.startsWith('02')){
                
                String[] peaInfo = pea.split('\\{\\|}');  // splits by {|} 
                loPEA.url = (peaInfo != null && peaInfo.size() == 3) ? (String.isNotBlank(peaInfo [2]) ?  peaInfo [2] : '') : '';
                loPEA.label = (peaInfo != null && peaInfo.size() == 3) ? (String.isNotBlank(peaInfo [1]) ? peaInfo [1] : '') : '';

            }else if(pea2!=null && pea2.startsWith('01')){

                String[] pea2Info = pea2.split('\\{\\|}');  // splits by {|}
                loPEA2.url = (pea2Info != null && pea2Info.size() == 3) ? (String.isNotBlank(pea2Info [2]) && parteFija != null ? parteFija + ''+ pea2Info [2] : '') : '';
                loPEA2.label = (pea2Info != null && pea2Info.size() == 3) ? (String.isNotBlank(pea2Info [1]) ? pea2Info [1] : '') : '';

            }else if(pea2!=null && pea2.startsWith('02')){

                String[] pea2Info = pea2.split('\\{\\|}');  // splits by {|} 
                loPEA2.url = (pea2Info != null && pea2Info.size() == 3) ? (String.isNotBlank(pea2Info [2]) ?  pea2Info [2] : '') : '';
                loPEA2.label = (pea2Info != null && pea2Info.size() == 3) ? (String.isNotBlank(pea2Info [1]) ? pea2Info [1] : '') : '';

            }else{
                if(pea!=null){
                    String[] peaInfo = pea.split('\\{\\|}');  // splits by {|} 
                    loPEA.url = (peaInfo != null && peaInfo.size() == 2) ? (String.isNotBlank(peaInfo [1]) && parteFija != null ? parteFija + ''+ peaInfo [1] : '') : '';
                    loPEA.label = (peaInfo != null && peaInfo.size() == 2) ? (String.isNotBlank(peaInfo [0]) ? peaInfo [0] : '') : '';
                }
                
    
                if(pea2!=null){
                    String[] pea2Info = pea2.split('\\{\\|}');  // splits by {|}
                    loPEA2.url = (pea2Info != null && pea2Info.size() == 2) ? (String.isNotBlank(pea2Info [1]) && parteFija != null ? parteFija + ''+ pea2Info [1] : '') : '';
                    loPEA2.label = (pea2Info != null && pea2Info.size() == 2) ? (String.isNotBlank(pea2Info [0]) ? pea2Info [0] : '') : '';
                }
            }
		}
        if(loPEA2.url != null || loPEA2.label != null) {
			AV_LogDebug.printLogDebug(methodName, 'Links dynamics:: ' + loPEA2);
			return loPEA2; 
		}else if(loPEA.url != null || loPEA.label != null){
			return loPEA;
		}else{
            return null;
        }
	}

   

    
}