/**********************************************************************************************************************
Name:	 CIBE_LinkOperativoController
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC CIBE_LinkOperativo
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Alicia       	    25/05/2023		Init version

***********************************************************************************************************************/
public with sharing class CIBE_LinkOperativoController {
    
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
        String empContacto = [SELECT AV_ExternalID__c FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1].AV_ExternalID__c;
        empContacto = String.isNotBlank(empContacto) ? empContacto.removeStart('U01') : '';

        Map<Id, CIBE_Section__mdt> mapSection = null;
        if(setting.contains(',')){
            String[] settingSplited = setting.split(',');
            Set<String> setSettings = new Set<String>{settingSplited[0],settingSplited[1]};
            mapSection = new Map<Id, CIBE_Section__mdt>([SELECT Id, Label, CIBE_Collapse__c, CIBE_Collumns__c, CIBE_Title__c, CIBE_Order__c FROM CIBE_Section__mdt where CIBE_Active__c=true and CIBE_Setting__c =:setSettings ORDER BY CIBE_Order__c ASC]);
        }else{
            mapSection = new Map<Id, CIBE_Section__mdt>([SELECT Id, Label, CIBE_Collapse__c, CIBE_Collumns__c, CIBE_Title__c, CIBE_Order__c FROM CIBE_Section__mdt where CIBE_Active__c=true and CIBE_Setting__c=: setting ORDER BY CIBE_Order__c ASC]);    
        }
        
        List<CIBE_Section_Link__mdt> listSectionsLinks = [SELECT id, CIBE_Link_Reference__c, CIBE_Section_Reference__c FROM CIBE_Section_Link__mdt where CIBE_Section_Reference__c =:mapSection.keySet() and CIBE_Link_Reference__r.CIBE_Active__c = true];

		Set<Id> listSections = new Set<Id>();        
        for(CIBE_Section_Link__mdt sectionLink : listSectionsLinks){
            listSections.add(sectionLink.CIBE_Link_Reference__c);
        }
        
        Map<Id, CIBE_Link__mdt> mapLinks =new Map<Id, CIBE_Link__mdt>([SELECT id, CIBE_Order__c, CIBE_Parameters__c,  CIBE_Title__c,CIBE_URL__c  FROM CIBE_Link__mdt where Id=:listSections and CIBE_Active__c = true ORDER BY CIBE_Order__c ASC]);
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
        RecordType rtName = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id =: ((String)obj.get('RecordTypeId')) LIMIT 1];

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
                lkData.url = generateURL(mapLinks.get(linkData).CIBE_Title__c, mapLinks.get(linkData).CIBE_URL__c, mapLinks.get(linkData).CIBE_Parameters__c, filterObject, customerId, rtName,empContacto);
                lkData.label = linkTranslations.containsKey(mapLinks.get(linkData).CIBE_Title__c) && String.isNotBlank(linkTranslations.get(mapLinks.get(linkData).CIBE_Title__c)) ? linkTranslations.get(mapLinks.get(linkData).CIBE_Title__c) : mapLinks.get(linkData).CIBE_Title__c;
                sect.links.add(lkData);
            }
            listSectionsReturn.add(sect);
        }
        listSectionsReturn.sort();
        return listSectionsReturn; 
    }

    /**
     * Generate URL with dynamic parameters from JSON configuration
     */
    private static String generateURL(String title, String url, String parameters, String filterObject, String filterId, RecordType rtName,String empContacto){
        String methodName = 'generateURL';
        Obj wrapper = (Obj) System.JSON.deserialize(parameters, Obj.class);
        AV_LogDebug.printLogDebug(methodName, 'Parameters: ' + parameters);
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

            Lead l = [SELECT Id, AV_numperso__c FROM Lead WHERE Id=:lo.AV_Lead__c];
            Account acc = [SELECT Id, FirstName, LastName, AV_NumPerso__c, CC_Numero_Documento__c FROM Account WHERE Id=:l.AV_numperso__c];
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
        url = url.replaceAll( '\\s+', '%20'); 
        return url;
    }
    
    /**
	 * Retrieves the link and label from fields AV_PEA__c and AV_PEA2__c
	 */
	@AuraEnabled
	public static LinksOperativos getOppLinkPEA(String id,String objApiName,String peaF) {

        String methodName = 'getObjectLinkPEA2';
        String pea= null;
		String pea2 = null;
		List<Opportunity> opp = new List<Opportunity>();
		List<Task> tsk = new List<Task>();
		List<Event> evt = new List<Event>();
        LinksOperativos loPEA = new LinksOperativos();  
        LinksOperativos loPEA2 = new LinksOperativos();

        if(peaF.contains('AV_PEA__c')){
            // if(objApiName.equals('Opportunity')){
            //     opp = [SELECT Id, AV_PEA__c,Name FROM Opportunity WHERE Id = :id limit 1];
            //     if (opp != null) {
            //         pea=opp[0].AV_PEA__c;                   
            //     }
            // }else
            if(objApiName.equals('Task')){
                tsk = [SELECT Id, AV_PEA__c FROM Task WHERE Id = :id LIMIT 1];
                if (tsk != null) {
                    pea= tsk[0].AV_PEA__c;                   
                }
            }
            // else if(objApiName.equals('Event')) {
            //     evt = [SELECT Id, AV_PEA__c FROM Event WHERE Id = :id limit 1];
            //     if (evt != null) {
            //         pea= evt[0].AV_PEA__c;                    
            //     }
            // }
        }else if(peaF.contains('AV_PEA2__c')){
            // if(objApiName.equals('Opportunity')){
            //     opp = [SELECT Id, AV_PEA2__c,Name FROM Opportunity WHERE Id = :id limit 1];
            //     if (opp != null) {
            //         pea2=opp[0].AV_PEA2__c;                 
            //     }
            // }else 
            if(objApiName.equals('Task')){
                tsk = [SELECT Id, AV_PEA2__c FROM Task WHERE Id = :id LIMIT 1];
                if (tsk != null) {
                    pea2= tsk[0].AV_PEA2__c;
                }
            }
        }

        if ((opp != null || tsk != null || evt != null) && ( pea2 != null || pea != null)) {
			String parteFija = [SELECT AV_URL__c FROM AV_ParteFijaPEA__mdt WHERE DeveloperName='AV_Header_PEA_Link' LIMIT 1].AV_URL__c;
            if(pea!=null){
                String[] peaInfo = pea.split('\\{\\|}');  // splits by {|} 
                loPEA.url = String.isNotBlank(peaInfo[1]) ? parteFija+''+peaInfo[1] : '';
                loPEA.label = String.isNotBlank(peaInfo[0])  ? peaInfo[0] : '';
            }if(pea2!=null){
                String[] pea2Info = pea2.split('\\{\\|}');  // splits by {|}
                loPEA2.url = String.isNotBlank(pea2Info[1]) ? parteFija+''+pea2Info[1] : '';
                loPEA2.label = String.isNotBlank(pea2Info[0])  ? pea2Info[0] : '';
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