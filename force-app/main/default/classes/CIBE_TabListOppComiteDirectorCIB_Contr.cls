/**********************************************************************************************************************
 Name:	  CIBE_TabListOppComiteDirectorCIB_Contr
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componente cibe_TabListOppComiteDirectorCIB
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE		    Description
	1.0			US506957        Ali		        03/08/2023	    Init version
    1.3         US682142        ALi             25/07/2023      Añadido el campo Linea
    1.4         FIX             Luis            15/03/2024      Mejora rendimiento querys y proceso de mapeo de Jerarquia
    1.5			US850814    	Lucía	  	    05/06/2024		Añadir los campos CIBE_AbsoluteClientProfSeg__c, CIBE_AbsoluteGroupProfSeg__c, CIBE_RelativeClientProfSeg__c y CIBE_RelativeGroupProfSeg__c

*/
public with sharing class CIBE_TabListOppComiteDirectorCIB_Contr {

    private static List<String> stagesVivas = new List<String>{'En curso', 'CIBE_Pendiente_firma', 'Potencial'};
    private static List<String> stagesCerradas = new List<String>{'CIBE_Cerrado positivo', 'Cerrado negativo'};
    private static final String HIERARCHY_EMPLOYEE_RT  = CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT;

    private static Set<String> recordTypes = new Set<String>{
                                                            CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT,
                                                            CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIACIB_RT,
                                                            CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTACIB_RT,
                                                            CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONCIB_RT
                                                        };

    @AuraEnabled(cacheable = true) 
    public static List<OpportunityWrapper> getOpportunity(Integer offSet, String negocios, String redesSegmentos, String sectoresPaises,  String centrosCarteras, String comiteDirector ) {

        offSet = offSet <= 2000 ? offset : 2000;
        Set <Id> setContactHier = new Set<Id>();
        if(!String.IsBlank(negocios)){
            setContactHier = getHierarchies(negocios, redesSegmentos,sectoresPaises, centrosCarteras);
        }

        String query = 'SELECT Id, AccountId, CIBE_GrupoComercial__c,CIBE_GrupoComercial__r.Name, Account.Name, ' +
                'Name, TOLABEL(CIBE_TipoOperacion__c), AV_PF__c,AV_PF__r.Name, ' +
                'CIBE_AmountDivisa__c, CIBE_Divisa__c, CloseDate, AV_Gestor__c, ' +
                'CIBE_BalanceDivisa__c, CIBE_ComisionesDivisa__c, AV_ClienteConfidencial__c, ' +
                'TOLABEL(StageName), Owner.Name, CIBE_ComiteDirector__c, ownerId, ' +
                'CIBE_Pais__c, CIBE_RatingPD__c, CIBE_RAROperacionRar__c, CIBE_Sindicaciones__c, TOLABEL(Account.CIBE_AbsoluteClientProfSeg__c), TOLABEL(Account.CIBE_AbsoluteGroupProfSeg__c), ' +
                'TOLABEL(Account.CIBE_RelativeClientProfSeg__c), TOLABEL(Account.CIBE_RelativeGroupProfSeg__c) ' +
                'FROM Opportunity ' +
                'WHERE RecordType.DeveloperName IN :recordTypes ' + 
                'AND ( ' +
                        '(StageName IN :stagesVivas) ' +
                        'OR (StageName IN :stagesCerradas AND  CloseDate >= LAST_N_MONTHS:1 AND CloseDate < TODAY ) ' +
                ') ';
                if(!setContactHier.isEmpty()){
                    query += 'AND AV_Gestor__c IN : setContactHier ';
                }
                if(comiteDirector != 'todas' && comiteDirector != null){
                    Boolean comiteDirectorBool = Boolean.valueOf(comiteDirector);
                    query += 'AND CIBE_ComiteDirector__c = : comiteDirectorBool ';
                }
                query += 'AND CreatedDate >= LAST_N_MONTHS:24 ';
                query += ' ORDER BY CloseDate ASC LIMIT 10 OFFSET :offSet';

        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));
        List<OpportunityWrapper> listOppWrapp = new List<OpportunityWrapper>();

        for(Opportunity op: listOpp) {
            OpportunityWrapper oppWrapp = new OpportunityWrapper();
            if((!String.IsBlank(negocios) && !setContactHier.isEmpty() && setContactHier.contains(op.AV_Gestor__c)) ||
                (String.IsBlank(negocios) && setContactHier.isEmpty())) {
                    oppWrapp.iden = String.isNotBlank(op.Id) ? '/' +  op.Id : '';
                    oppWrapp.name = String.isNotBlank(op.name) ? op.name : '';
                    oppWrapp.accountId = String.isNotBlank(op.AccountId) ? '/' +  op.AccountId : null;
                    oppWrapp.accountName = String.isNotBlank(op.Account.Name) ? op.Account.Name : '';
                    oppWrapp.grupoComercialId = String.isNotBlank(op.CIBE_GrupoComercial__c) ? '/' +  op.CIBE_GrupoComercial__c : null;
                    oppWrapp.grupoComercialName = String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name : '';
                    oppWrapp.pFId = String.isNotBlank(op.AV_PF__c) ? '/' +  op.AV_PF__c : null;
                    oppWrapp.pFName = String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '';
                    oppWrapp.amountDivisa = op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.divisa = String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '';
                    oppWrapp.balanceDivisa = op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.comisionesDivisa = op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.tipoOperaciones = String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '';
                    oppWrapp.stageName = String.isNotBlank(op.StageName) ? op.StageName : '';
                    oppWrapp.closeDate = op.CloseDate;
                    oppWrapp.ownerId = String.isNotBlank(op.OwnerId) ? '/' +  op.OwnerId : null;
                    oppWrapp.ownerName = String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '';
                    oppWrapp.comiteDirector = op.CIBE_ComiteDirector__c;  
                    oppWrapp.pais = op.CIBE_Pais__c;
                    oppWrapp.rating = op.CIBE_RatingPD__c;
                    oppWrapp.rar = op.CIBE_RAROperacionRar__c != null ? op.CIBE_RAROperacionRar__c.setScale(2, RoundingMode.HALF_UP).format() : '';   
                    oppWrapp.sindicaciones = op.CIBE_Sindicaciones__c;
                    oppWrapp.confidencial = op.AV_ClienteConfidencial__c; 
                    oppWrapp.empresaAbsoluta = op.Account.CIBE_AbsoluteClientProfSeg__c;
                    oppWrapp.empresaRelativa = op.Account.CIBE_RelativeClientProfSeg__c;
                    oppWrapp.grupoAbsoluta = op.Account.CIBE_AbsoluteGroupProfSeg__c;
                    oppWrapp.grupoRelativa = op.Account.CIBE_RelativeGroupProfSeg__c;
                    listOppWrapp.add(oppWrapp);
            }
        }
        return listOppWrapp;
    }

    @AuraEnabled
    public static List<String> exportOpportunities( String negocios, String redesSegmentos, String sectoresPaises, String centrosCarteras, String comiteDirector ) {

        Set <Id> setContactHier = new Set<Id>();
        if(!String.IsBlank(negocios)){
            setContactHier = getHierarchies(negocios, redesSegmentos,sectoresPaises, centrosCarteras);
        }

        String query = 'SELECT Id, AccountId, CIBE_GrupoComercial__c,CIBE_GrupoComercial__r.Name, Account.Name, ' +
                'Name, TOLABEL(CIBE_TipoOperacion__c), AV_PF__c,AV_PF__r.Name, ' +
                'CIBE_AmountDivisa__c, CIBE_Divisa__c, CloseDate, AV_Gestor__c, ' +
                'CIBE_BalanceDivisa__c, CIBE_ComisionesDivisa__c, AV_ClienteConfidencial__c, ' +
                'TOLABEL(StageName), Owner.Name, CIBE_ComiteDirector__c, ownerId, ' +
                'CIBE_Pais__c, CIBE_RatingPD__c, CIBE_RAROperacionRar__c, CIBE_Sindicaciones__c ,  TOLABEL(Account.CIBE_AbsoluteClientProfSeg__c), TOLABEL(Account.CIBE_AbsoluteGroupProfSeg__c), ' +
                'TOLABEL(Account.CIBE_RelativeClientProfSeg__c), TOLABEL(Account.CIBE_RelativeGroupProfSeg__c)' +
                'FROM Opportunity ' +
                'WHERE RecordType.DeveloperName IN :recordTypes ' + 
                'AND ( ' +
                        '(StageName IN :stagesVivas) ' +
                        'OR (StageName IN :stagesCerradas AND  CloseDate >= LAST_N_MONTHS:1 AND CloseDate < TODAY ) ' +
                ') ';
                if(!setContactHier.isEmpty()){
                    query += 'AND AV_Gestor__c IN : setContactHier ';
                }
                if(comiteDirector != 'todas'){
                    Boolean comiteDirectorBool = Boolean.valueOf(comiteDirector);
                    query += 'AND CIBE_ComiteDirector__c = : comiteDirectorBool ';
                }
                query += 'AND CreatedDate >= LAST_N_MONTHS:24 ';
                query += 'ORDER BY CloseDate ASC';

        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));


        List<String> opportunities = new List<String>();
        for(Opportunity op: listOpp) {
            String opp = '';
            if((!String.IsBlank(negocios) && !setContactHier.isEmpty() && setContactHier.contains(op.AV_Gestor__c)) ||
                (String.IsBlank(negocios) && setContactHier.isEmpty())) {
                    opp += (op.CIBE_ComiteDirector__c ? 'true' : '') + ';';
                    opp += (String.isNotBlank(op.Account.Name) ? op.Account.Name.replaceAll(';', '.') : '') + ';';
                    opp += (String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name.replaceAll(';', '.') : '') + ';';
                    opp += (String.isNotBlank(op.name) ? op.name.replaceAll(';', '.')  : '') + ';';
                    opp += (String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '') + ';';
                    opp += (op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                    opp += (String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '') + ';';
                    opp += (String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '') + ';';
                    opp += (op.CloseDate != null ? String.valueOf(op.CloseDate) : '') + ';';
                    opp += (op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                    opp += (op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';   
                    opp += (String.isNotBlank(op.StageName) ? op.StageName : '') + ';';
                    opp += (String.isNotBlank(op.CIBE_Pais__c) ? op.CIBE_Pais__c : '') + ';';
                    opp += (String.isNotBlank(op.CIBE_RatingPD__c) ? op.CIBE_RatingPD__c : '') + ';';
                    opp += (op.CIBE_RAROperacionRar__c != null ? op.CIBE_RAROperacionRar__c.setScale(2, RoundingMode.HALF_UP).format() : '') + ';';
                    opp += (op.CIBE_Sindicaciones__c ? 'true' : '') + ';';
                    opp += (op.AV_ClienteConfidencial__c ? 'true' : '') + ';';  
                    opp += (String.isNotBlank(op.Account.CIBE_AbsoluteClientProfSeg__c) ? op.Account.CIBE_AbsoluteClientProfSeg__c : '') + ';';
                    opp += (String.isNotBlank(op.Account.CIBE_RelativeClientProfSeg__c) ? op.Account.CIBE_RelativeClientProfSeg__c : '') + ';';
                    opp += (String.isNotBlank(op.Account.CIBE_AbsoluteGroupProfSeg__c) ? op.Account.CIBE_AbsoluteGroupProfSeg__c : '') + ';';
                    opp += (String.isNotBlank(op.Account.CIBE_RelativeGroupProfSeg__c) ? op.Account.CIBE_RelativeGroupProfSeg__c : '') + ';';
                    opp += '\n';
                    opportunities.add(opp);
            }
        }
        return opportunities;
    }

    private static Set<Id> getHierarchies(String negocios, String redesSegmentos, String sectoresPaises, String centrosCarteras ) {

        Map<Id, HierarchyWrapper> mapHier = new Map<Id, HierarchyWrapper>();
        List<CIBE_hierarchy__c> lstHier = new List<CIBE_hierarchy__c>();
        Set<Id> setHierId = new Set<Id>();

        if(CIBE_hierarchy__c.SObjectType.getDescribe().isAccessible()) {
            String queryHier = 'SELECT CIBE_Contact__c '+
            ' FROM CIBE_hierarchy__c WHERE CIBE_Contact__c != null AND RecordType.DeveloperName = :HIERARCHY_EMPLOYEE_RT ';
            if(!String.isBlank(negocios)){
                queryHier += ' AND CIBE_Negocios__c =:negocios';
            }
            if(!String.isBlank(redesSegmentos)){
                queryHier += ' AND CIBE_RedesSegmentos__c = :redesSegmentos';
            }
            if(!String.isBlank(sectoresPaises)){
                queryHier += ' AND CIBE_SectoresPaises__c = :sectoresPaises';
            }
            if(!String.isBlank(centrosCarteras)){
                queryHier += ' AND CIBE_CentrosCarteras__c = :centrosCarteras ';
            }
            lstHier = Database.query(String.escapeSingleQuotes(queryHier));

            if(!lstHier.isEmpty()) {
                for(CIBE_Hierarchy__c hier : lstHier ) {
                    setHierId.add(hier.CIBE_Contact__c);
                }
            }
        }
        return setHierId;
    }

    public class OpportunityWrapper {
        @AuraEnabled public String negocios {get;set;}
        @AuraEnabled public String centrosCarteras {get;set;}
        @AuraEnabled public String redesSegmentos {get;set;}
		@AuraEnabled public String sectoresPaises {get;set;}
        @AuraEnabled public String iden {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String accountCif {get;set;}
        @AuraEnabled public String grupoComercialId {get;set;}
        @AuraEnabled public String grupoComercialName {get;set;}
        @AuraEnabled public String grupoEconomico {get;set;}
        @AuraEnabled public String pFId {get;set;}
        @AuraEnabled public String pFName {get;set;}
        @AuraEnabled public String amountDivisa {get;set;}
        @AuraEnabled public String divisa {get;set;}
        @AuraEnabled public String amountEuro {get;set;}
        @AuraEnabled public String balanceDivisa {get;set;}
        @AuraEnabled public String comisionesDivisa {get;set;}
        @AuraEnabled public String balance {get;set;}
        @AuraEnabled public String comisiones {get;set;}
        @AuraEnabled public String tipoOperaciones {get;set;}
        @AuraEnabled public String stageName {get;set;}
        @AuraEnabled public Date closeDate {get;set;}
        @AuraEnabled public String ownerId {get;set;}
        @AuraEnabled public String ownerName {get;set;}
        @AuraEnabled public boolean esg {get;set;}
        @AuraEnabled public Date fechaComiteRiesgo {get;set;}
        @AuraEnabled public Date fechaAprobacionPrecio {get;set;}
        @AuraEnabled public boolean comiteDirector {get;set;}
        @AuraEnabled public boolean confidencial {get;set;}
        @AuraEnabled public boolean linea {get;set;}
        @AuraEnabled public String pais {get;set;}
        @AuraEnabled public String rating {get;set;}
        @AuraEnabled public String rar {get;set;}
        @AuraEnabled public boolean sindicaciones {get;set;}
        @AuraEnabled public String empresaAbsoluta {get;set;}
        @AuraEnabled public String empresaRelativa {get;set;}
        @AuraEnabled public String grupoAbsoluta {get;set;}
        @AuraEnabled public String grupoRelativa {get;set;}
	}

    public class HierarchyWrapper {
        @AuraEnabled public Set<String> negocios {get;set;}
        @AuraEnabled public Set<String> centrosCarteras {get;set;}
        @AuraEnabled public Set<String> redesSegmentos {get;set;}
		@AuraEnabled public Set<String> sectoresPaises {get;set;}

        public HierarchyWrapper() {
            negocios = new Set<String>();
            centrosCarteras = new Set<String>();
            redesSegmentos = new Set<String>();
            sectoresPaises = new Set<String>();
        }

        public HierarchyWrapper(String negocios, String centrosCarteras, String redesSegmentos, String sectoresPaises) {
            this.negocios = new Set<String>{ negocios };
            this.centrosCarteras = new Set<String>{ centrosCarteras };
            this.redesSegmentos = new Set<String>{ redesSegmentos };
            this.sectoresPaises = new Set<String>{ sectoresPaises };
        }
    }

    @AuraEnabled(cacheable = true) 
    public static Integer countOpp(String negocios, String redesSegmentos, String sectoresPaises,  String centrosCarteras, String  comiteDirector) {
        
        Set <Id> setContactHier = new Set<Id>();
        if(!string.isBlank(negocios)){
            setContactHier = getHierarchies(negocios, redesSegmentos,sectoresPaises, centrosCarteras);
        }

        String query = 'SELECT COUNT(Id) total FROM Opportunity ' +
                'WHERE RecordType.Developername IN :recordTypes ' + 
                'AND ( ' +
                        '(StageName IN :stagesVivas) ' +
                        'OR (StageName IN :stagesCerradas AND  CloseDate >= LAST_N_MONTHS:1 AND CloseDate < TODAY ) ' +
                ') ';
                if(setContactHier != null && !setContactHier.isEmpty()){
                    query += 'AND AV_Gestor__c IN : setContactHier ';
                }
                if(comiteDirector != 'todas'){
                    Boolean comiteDirectorBool = Boolean.valueOf(comiteDirector);
                    query += 'AND CIBE_ComiteDirector__c = : comiteDirectorBool ';
                }
                query += 'AND CreatedDate >= LAST_N_MONTHS:24 ';

                List<AggregateResult> listResult = Database.query(String.escapeSingleQuotes(query));
                Integer totalPage = (Integer) listResult[0].get('total');

                if(!string.isBlank(negocios) && (setContactHier == null || setContactHier.isEmpty())){
                    totalPage = 1;
                }

        return totalPage;
    }

    @AuraEnabled(cacheable = true) 
    public static HierarchyWrapper getContactName(String userId) {
        List<Contact> listContact = new List<Contact>();
        if(Schema.SObjectType.Contact.fields.Id.isAccessible()) {
            listContact = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userId ];
        }
        String contactId;
        if(!listContact.isEmpty()){
            for(Contact contact : listContact){
                contactId = contact.Id;
            }
        }

        List<CIBE_hierarchy__c> lstHier = new List<CIBE_hierarchy__c>();
        if(CIBE_hierarchy__c.SObjectType.getDescribe().isAccessible()) {
            lstHier = [SELECT CIBE_Negocios__r.Name, CIBE_RedesSegmentos__r.Name, CIBE_SectoresPaises__r.Name, CIBE_CentrosCarteras__r.Name 
                            FROM CIBE_hierarchy__c WHERE CIBE_Contact__c != null AND RecordType.DeveloperName = : HIERARCHY_EMPLOYEE_RT AND CIBE_Contact__c = :contactId];
        }
        HierarchyWrapper newHier;
        if(!lstHier.isEmpty()) {
            for(CIBE_Hierarchy__c hier : lstHier ) {
                
                newHier = new HierarchyWrapper(
                            hier.CIBE_Negocios__r.Name, 
                            hier.CIBE_CentrosCarteras__r.Name,
                            hier.CIBE_RedesSegmentos__r.Name, 
                            hier.CIBE_SectoresPaises__r.Name
                        );
            }
        }
        return newHier;
    }

    @AuraEnabled(cacheable = true) 
    public static HierarchyWrapper getContactIds(String userId) {
        List<Contact> listContact = new List<Contact>();
        if(Schema.SObjectType.Contact.fields.Id.isAccessible()) {
            listContact = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userId ];
        }
        String contactId;
        if(!listContact.isEmpty()){
            for(Contact contact : listContact){
                contactId = contact.Id;
            }
        }

        List<CIBE_hierarchy__c> lstHier = new List<CIBE_hierarchy__c>();
        if(CIBE_hierarchy__c.SObjectType.getDescribe().isAccessible()) {
            lstHier = [SELECT CIBE_Negocios__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c, CIBE_CentrosCarteras__c 
                            FROM CIBE_hierarchy__c WHERE CIBE_Contact__c != null AND RecordType.DeveloperName = : HIERARCHY_EMPLOYEE_RT AND CIBE_Contact__c = :contactId];
        }
        HierarchyWrapper newHier;
        if(!lstHier.isEmpty()) {
            for(CIBE_Hierarchy__c hier : lstHier ) {
                
                newHier = new HierarchyWrapper(
                            hier.CIBE_Negocios__c, 
                            hier.CIBE_CentrosCarteras__c,
                            hier.CIBE_RedesSegmentos__c, 
                            hier.CIBE_SectoresPaises__c
                        );
            }
        }
        return newHier;
    }
}