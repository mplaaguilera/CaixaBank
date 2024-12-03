/**********************************************************************************************************************
Name: CIBE_ClientesPriorizadosController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controller del lwc cibe_ClientesPriorizados
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US588247    		        Lucia Muñoz         30/08/2023           Init version
***********************************************************************************************************************/




// ((1 AND (3 OR 4)) OR (5 AND (6 OR 8) AND 7)) AND 2 AND 9 AND 10


public with sharing class CIBE_ClientesPriorizadosController {

    private final static Integer MAX_RESULTS 	= 10;

    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getData(Filters filterResults, List<Id> selectedIds, String clickFilter){

        Set<Id> accountsId = new Set<Id>();
        List<Wrapper> listReturn = new List<Wrapper>();

        List<String> r1EMP = new List<String> {CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT};
        List<String> r5EMP = new List<String> {CIBE_AppConstants.TASK_OTROS_EMP_RT };
        List<String> r10EMP = new List<String>  {CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT, CIBE_AppConstants.TASK_OTROS_EMP_RT };

        List<String> r1CIB = new List<String> {CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, CIBE_AppConstants.TASK_ONBOARDING_CIB_RT};
        List<String> r5CIB = new List<String> {CIBE_AppConstants.TASK_OTROS_CIB_RT };
        List<String> r10CIB = new List<String>  {CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, CIBE_AppConstants.TASK_ONBOARDING_CIB_RT, CIBE_AppConstants.TASK_OTROS_CIB_RT };



        List<String> statusList = new List<String>{'Open','Pendiente no localizado'};
        String app = 'AV_SalesforceTaskOpp';
        String recordTypeGC = 'CIBE_GrupoComercial';


        Date today = System.today();
        Date fechaLimite = today.addDays(180);
        Date fechaLimite2 = today.addDays(7);

        String owner = String.valueOf(UserInfo.getUserId());
        String parent = 'Parent';


        List<Task> tasks = new List<Task>();
        List<FinServ__AccountAccountRelation__c> grupoComercial = new List<FinServ__AccountAccountRelation__c>();
        String subjectFilter;
        String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;

        String query = 'SELECT Id, AV_Origen__c, AccountId,  Account.Name, Subject, ActivityDate, Account.CIBE_LEXAprobado__c, Account.AV_LastContactDate__c, TOLABEL(Account.AV_AttentionModel__c) FROM Task';

        if(roleUser == 'EMP'){

            query = query + ' WHERE  ((RecordType.DeveloperName IN :r1EMP AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)) OR (RecordType.DeveloperName IN :r5EMP AND (ActivityDate = NEXT_N_DAYS:7 OR ActivityDate = TODAY) AND AV_OrigenApp__c = :app)) AND Status IN :statusList AND AV_ToDelete__c = false AND RecordType.DeveloperName IN :r10EMP AND OwnerId = :owner';     

        }else if(roleUser == 'CIB'){

            query = query +  ' WHERE ((RecordType.DeveloperName IN :r1CIB AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)) OR (RecordType.DeveloperName IN :r5CIB AND (ActivityDate = NEXT_N_DAYS:7 OR ActivityDate = TODAY) AND AV_OrigenApp__c = :app)) AND Status IN :statusList AND AV_ToDelete__c = false AND RecordType.DeveloperName IN :r10CIB AND OwnerId = :owner';     

        }

        List<Task> prueba = Database.query(query);        

        if(filterResults != null &&  filterResults.subjectFilterValue != null){
            subjectFilter =  filterResults.subjectFilterValue ;
            query = query + ' AND Subject LIKE \'%'+String.escapeSingleQuotes(subjectFilter)+'%\'';
        }
                
        if(clickFilter != null && clickFilter != ''){
            /*String a = clickFilter.substring(1, clickFilter.length() -1); 
            query = query + ' AND RecordType.Name = :a';*/
            query = query + ' AND RecordType.DeveloperName = :clickFilter';


        }

        List<Task> listOfTask = Database.query(query);

        for(Task t : listOfTask){
            accountsId.add(t.AccountId);
        }
    
        String aux = null;
        String auxName = null;
        Map<Id, FinServ__AccountAccountRelation__c> mapGrupoComercial = new Map<Id, FinServ__AccountAccountRelation__c>();

        String gruposQuery = 'SELECT FinServ__RelatedAccount__c, Id, FinServ__Account__c,FinServ__Account__r.Name FROM FinServ__AccountAccountRelation__c WHERE FinServ__RelatedAccount__c IN :accountsId AND RecordType.DeveloperName = :recordTypeGC AND FinServ__Role__r.Name = :parent AND IsDeleted = false ';
        
        gruposQuery = String.escapeSingleQuotes(gruposQuery);

        if(!selectedIds.isEmpty()){
            gruposQuery = gruposQuery + ' AND FinServ__Account__c IN :selectedIds';
        }
       
        gruposQuery = String.escapeSingleQuotes(gruposQuery);

        List<FinServ__AccountAccountRelation__c> listOfGC = Database.query(gruposQuery);


        for(FinServ__AccountAccountRelation__c fs :listOfGC){
            mapGrupoComercial.put(fs.FinServ__RelatedAccount__c, fs);
        }


            for(Task t : listOfTask) {
                if(mapGrupoComercial.containsKey(t.AccountId) ){
                    aux = mapGrupoComercial.get(t.AccountId).FinServ__Account__c;
                    auxName = mapGrupoComercial.get(t.AccountId).FinServ__Account__r.Name;
                }
    
                aux = aux != null ? aux : '';

                if((!selectedIds.isEmpty() && aux != '') || (selectedIds.isEmpty()) ){
                    listReturn.add(
                        new Wrapper(
                        t.AV_Origen__c,
                        auxName,
                        aux,
                        t.Account.Name,
                        t.AccountId,
                        t.Subject,
                        t.Id,
                        t.ActivityDate,
                        t.Account.CIBE_LEXAprobado__c != null ? Integer.valueOf(t.Account.CIBE_LEXAprobado__c.round(RoundingMode.HALF_UP)).format() + ' €': '',
                        t.Account.AV_LastContactDate__c ,
                        t.Account.AV_AttentionModel__c
                    ));
                }
                aux = null;
            }
        
        return listReturn;
    }

    @AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchGrupoComercial(String searchTerm) {

		String methodName = 'search';
		
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<Account>> searchResults = new List<List<Account>>();

        List<Account> listAccount = new List<Account>();

		if(!String.isBlank(searchTerm)){
			searchTerm += '*';
			searchResults= [FIND :searchTerm IN All FIELDS RETURNING
			Account(Id, Name, RecordType.DeveloperName, AV_InterlocName__c WHERE RecordType.DeveloperName = 'CIBE_GrupoComercial') LIMIT :MAX_RESULTS];
		}

		List<String> listIds = new List<String>();
        if(!searchResults.isEmpty()) {
            if(Test.isRunningTest() && searchResults[0].isEmpty()){
                listAccount = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'CIBE_GrupoComercial' AND AV_InterlocName__c = 'Grupo Comercial Test'];
            }else{
                listAccount = (List<Account>) searchResults[0];
            }
           
			if(!listAccount.isEmpty()){
				for (Account c : listAccount) {
					results.add(new AV_LookupSearchResult(c.Id, 'Account', 'standard:account', c.Name, ''));
					listIds.add(c.Id);
				}
			}
            results.sort();
        }
		return results;
	}




    public class Wrapper{

        @AuraEnabled 
        public String origen {get;set;}

        @AuraEnabled 
        public String grupoComercial {get;set;}

        @AuraEnabled 
        public String grupoComercialId {get;set;}

        @AuraEnabled 
        public String cliente {get;set;}
        
        @AuraEnabled 
        public String clienteId {get;set;}

        @AuraEnabled 
        public String asunto {get;set;}

        @AuraEnabled 
        public String asuntoId {get;set;}

        @AuraEnabled 
        public Datetime fechaVencimiento {get;set;}

        @AuraEnabled 
        public String lexDisponible {get;set;}

        @AuraEnabled 
        public Datetime contacto {get;set;}

        @AuraEnabled 
        public String modelo {get;set;}
        
        public Wrapper(String origen, String grupoComercial, String grupoComercialId,  String cliente, String clienteId, String asunto, String asuntoId, Datetime fechaVencimiento, String lexDisponible, Datetime contacto, String modelo) {
            this.origen = origen;
            this.grupoComercial =  grupoComercial;
            this.grupoComercialId =  grupoComercialId != '' ? '/' + grupoComercialId : '';
            this.cliente =  cliente;
            this.clienteId =  clienteId != null ? '/' + clienteId : '' ;
            this.asunto =  asunto != null ? asunto : ' ';
            this.asuntoId = asuntoId != '' ? '/' + asuntoId : '';
            this.fechaVencimiento = fechaVencimiento;
            this.lexDisponible = lexDisponible;
            this.contacto = contacto;
            this.modelo = modelo;

        }
    }


    public class Filters {
        @AuraEnabled
        public String subjectFilterValue {get; set;}
    }
}