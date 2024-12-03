/**********************************************************************************************************************
Name:	  SIR_LCMP_LinkOperativoController
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC sir_lwc_LinksOperativo
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Atmira           	29/07/2022		Init version

***********************************************************************************************************************/
public with sharing class SIR_LCMP_LinksOperativoController {
    static final String NUMPERSO = '{numperso}';
    static final String FIRSTNAME = '{firstname}';
    static final String LASTNAME = '{lastname}';
    static final String NAME = '{firstname}%20{lastname}';
    static final String NIF = '{nif}';
    static final String TYPEPERSO = '{tipoPersona}';
    static final String PARTICULAR = 'CC_ClientePA';
    static final String EMPRESA = 'CC_Cliente';
    static final String ID = '{ID}';

    public class LinksOperativos {
        @AuraEnabled
        public String url;
        @AuraEnabled
		public String label;
	}

    @AuraEnabled
    public static List <LinksOperativos> getLinks(String seccion, String customerId, String urlOrg) {
        
        String methodName = 'getLinks';
        List<LinksOperativos> listLinkDynamics = new List<LinksOperativos>();
        Account customer = [SELECT Id, AV_NumPerso__c, recordtype.developername, FirstName, LastName, Name, CC_Numero_Documento__c FROM Account WHERE Id = :customerId LIMIT 1];  
        
        seccion = '%' + seccion + '%';

        List<SIR_LinksOperativosMCS__mdt> listLinksTF9 = [SELECT Id, SIR_Url2__c, SIR_Orden__c, SIR_Externo__c, Label 
                                                            FROM SIR_LinksOperativosMCS__mdt
                                                            WHERE SIR_Activo__c =: true
                                                            AND SIR_Seccion__c LIKE: seccion
                                                            ORDER BY SIR_Orden__c ASC];

        if(listLinksTF9 != null && !listLinksTF9.isEmpty()){
            for(SIR_LinksOperativosMCS__mdt linkTF9 : listLinksTF9){
                if(String.isNotBlank(linkTF9.SIR_Url2__c) && linkTF9.SIR_Externo__c){
                    LinksOperativos linkDynamic = new LinksOperativos();
                    String urlDynamic1 = linkTF9.SIR_Url2__c.replace(NUMPERSO, customer.AV_NumPerso__c);
                    String urlDynamic2;
                    String urlDynamic3;
                    if(customer.recordtype.developername == PARTICULAR){
                        urlDynamic2 = urlDynamic1.replace(FIRSTNAME, customer.FirstName);
                        urlDynamic3 = urlDynamic2.replace(LASTNAME, customer.LastName);
                    }else if(customer.recordtype.developername == EMPRESA){
                        urlDynamic3 = urlDynamic1.replace(NAME, customer.Name);
                    }
                    String urlDynamic4;
                    if(customer.recordtype.developername == PARTICULAR){
                        urlDynamic4 = urlDynamic3.replace(TYPEPERSO, 'F');
                    }else if(customer.recordtype.developername == EMPRESA){
                        urlDynamic4 = urlDynamic3.replace(TYPEPERSO, 'J');
                    } 
                    String urlDynamic5;
                    if(!String.isBlank(customer.CC_Numero_Documento__c)){
                        urlDynamic5 = urlDynamic4.replace(NIF, customer.CC_Numero_Documento__c);
                    }else{
                        urlDynamic5 = urlDynamic4.replace(NIF, '');
                    }
                    
                    linkDynamic.url = urlDynamic5.replaceAll( '\\s+', '%20');               
                    linkDynamic.label = linkTF9.Label; 
                    listLinkDynamics.add(linkDynamic);

                }else if(String.isNotBlank(linkTF9.SIR_Url2__c) && linkTF9.SIR_Externo__c == false){
                    LinksOperativos linkDynamic = new LinksOperativos();
                    String urlDynamic1 = linkTF9.SIR_Url2__c.replace(ID, customer.Id);

                    linkDynamic.url = urlDynamic1;
                    linkDynamic.label = linkTF9.Label; 
                    listLinkDynamics.add(linkDynamic);
                }
            }
        }

        return listLinkDynamics; 
    }

    /*@AuraEnabled
	public static String getIdFilterObject(String recordId, String objectApiName, String objectFilter, String filterField) {
		String filterSObjectID = '';
		if(String.isNotBlank(recordId) && String.isNotBlank(objectApiName) && String.isNotBlank(filterField)) {
			//List<SObject> filterNameList = new AV_Query(objectApiName).selectFields(filterField).addConditionEq('Id', recordId).run();
			
            List<SObject> filterNameList = [SELECT filterField FROM objectApiName WHERE Id =:recordId];
			if(filterNameList.size() > 0){
				SObject interact = filterNameList.get(0);
				filterSObjectID = (String) interact.get(filterField);
			}
		}
		return filterSObjectID;
	}*/
}