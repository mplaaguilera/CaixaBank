/*
*********************************************************************************************************************
 Name:      CIBE_ListadoOportunidadesMisClientesCIB
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for CIBE_ListadoOportunidadesMisClientesCIB LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY			AUTHOR				DATE        Description
	1.0      US380297			Luis Martínez		06/04/2023  Init version
***********************************************************************************************************************/
public with sharing class CIBE_ListadoOportunidadesMisClientesCIB {

    private static final String HIERARCHY_EMPLOYEE_RT  = CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT;
    private static final String USER_LOG = UserInfo.getUserId() ;

    /**
     * Metodo para recuperar los OTM en base a la jerarquia definida en los parametros de entrada.
     */
	@AuraEnabled(cacheable=true)
    public static List<OptionsParticipes> getOpportunityTeams(Boolean isMisClientes, String [] redesSegmentos, String [] sectoresPaises, String [] centrosCarteras ){
        List<OptionsParticipes> participes = new List<OptionsParticipes>();
        List<CIBE_hierarchy__c> lstJerarquia = new List<CIBE_hierarchy__c>();
        Set<String> setLabelsRts = new Set<String>{CIBE_AppConstants.OPP_ACCIONCIB_RT,CIBE_AppConstants.OPP_SUGERENCIACIB_RT,CIBE_AppConstants.OPP_ALERTACIB_RT,CIBE_AppConstants.OPP_INICIATIVACIB_RT};
        Set<Id> setIdsUser = new Set<Id>();

        String queryOT = 'SELECT  CIBE_Contact__r.AV_UsuarioAsociado__c FROM CIBE_hierarchy__c ' + 
            'WHERE CIBE_Contact__c != null AND CIBE_Contact__r.AV_UsuarioAsociado__c!= null AND CIBE_Negocios__c != null AND Recordtype.developername = :HIERARCHY_EMPLOYEE_RT ';
        if(!centrosCarteras.isEmpty()){queryOT +=' AND CIBE_CentrosCarteras__c IN :centrosCarteras';}
        if(!redesSegmentos.isEmpty()){queryOT +=' AND CIBE_RedesSegmentos__c IN :redesSegmentos';}
        if(!sectoresPaises.isEmpty()){queryOT +=' AND CIBE_SectoresPaises__c IN :sectoresPaises';}
        lstJerarquia = Database.query(String.escapeSingleQuotes(queryOT));

        for(CIBE_Hierarchy__c hier : lstJerarquia) { 
            if(!setIdsUser.contains(hier.CIBE_Contact__r.AV_UsuarioAsociado__c)){
                setIdsUser.add(hier.CIBE_Contact__r.AV_UsuarioAsociado__c);
            }
        }

        if(isMisClientes != null && !isMisClientes && !setIdsUser.isEmpty()){
            Set<Id> oppsTeamsM = new Set<Id> ();
            for (OpportunityTeamMember otm : [SELECT UserId, Name  FROM OpportunityTeamMember
                                                WHERE UserId !=:UserInfo.getUserId() AND  UserId IN :setIdsUser AND Opportunity.RecordType.DeveloperName IN :setLabelsRts
                                                ORDER BY Name]) {
                if(!oppsTeamsM.contains(otm.UserId)){
                    oppsTeamsM.add(otm.UserId);
                    participes.add(new OptionsParticipes((String)otm.get('UserId'),(String)otm.get('Name')));
                }
            }
        }
        return participes;
    }

    /**
     * Metodo para recuperar la Industra en base a la jerarquia definida en los parametros de entrada.
     */
	@AuraEnabled(cacheable=true)
    public static List<OptionsIndustrias> getIndustriaInter( String [] redesSegmentos){
        List<OptionsIndustrias> industrias = new List<OptionsIndustrias>();
        Set<String> setNegocio = new Set<String>{'Corporate Banking España'};
        String dependencias;
        List<String> setCentros = new List<String>();
        if(redesSegmentos.size()>0 && (redesSegmentos.contains('Sucursales') || redesSegmentos.contains('ORS'))){
            for(CBK_PicklistValues__c  pick: [select Id, Name, CBK_Dependencies__c FROM CBK_PicklistValues__c  WHERE Name IN: setNegocio ]){
                dependencias = pick.CBK_Dependencies__c;
            }
            setCentros = dependencias.split(';');
            for(CBK_PicklistValues__c  pick: [select Id, Name FROM CBK_PicklistValues__c  WHERE name IN: setCentros ]){
                industrias.add(new OptionsIndustrias((String)pick.get('Id'),(String)pick.get('Name')));                }
        }
        return industrias;		
    }

    /**
     * Metodo para recuperar los paises en base a la jerarquia definida en los parametros de entrada.
     */
	@AuraEnabled(cacheable=true)
    public static List<OptionsIndustrias> getPaises( ){
        List<OptionsIndustrias> lstPaises = new List<OptionsIndustrias>();
        for( Schema.PicklistEntry pickListVal : Opportunity.CIBE_Pais__c.getDescribe().getPicklistValues()){
            lstPaises.add(new OptionsIndustrias(pickListVal.getValue(),pickListVal.getLabel()));                
        }
        return lstPaises;	
    }
    
    /**
     * Metodo para recuperar la jerarquia del usuario loguado.
     */
	@AuraEnabled(cacheable=true)
    public static List<CIBE_hierarchy__c> getMyHierarchy(){
        List<CIBE_hierarchy__c> lstHier = new List<CIBE_hierarchy__c>();
        List<Contact> lstMiCont = new List<Contact>();
        lstMiCont       =   [SELECT id FROM Contact WHERE AV_UsuarioAsociado__c =: UserInfo.getUserId() AND Recordtype.DeveloperName =: CIBE_AppConstants.EMPLOYEE_RT];
        if(!lstMiCont.isEmpty()){
            lstHier         =   [SELECT  CIBE_Contact__c, CIBE_Negocios__r.Name,CIBE_CentrosCarteras__r.Name,CIBE_RedesSegmentos__r.Name, CIBE_SectoresPaises__r.Name
            FROM CIBE_hierarchy__c 
            WHERE CIBE_Contact__c =:lstMiCont[0].Id  AND Recordtype.developername = : HIERARCHY_EMPLOYEE_RT];
        }
        return lstHier;		
    }

    /**
     * Metodo para recuperar las carteras en las que está el cliente.
     */
    public static List<Id> getCartera(){
        List<Id> lstCartera = new List<Id>();
        Set<Id> setCartera = new Set<Id>();
        Map<String, AccountTeamMember> lstAccTeamM = new Map<String, AccountTeamMember>();
        if(Schema.AccountTeamMember.SObjectType.getDescribe().isAccessible()){
            for(AccountTeamMember accTeamM : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE UserId = :UserInfo.getUserId()]) {
                if(accTeamM.AccountId != null){
                    setCartera.add(accTeamM.AccountId);
                }
            }
        }
        if(!setCartera.isEmpty()){
			if (Schema.AV_BookMember__c.SObjectType.getDescribe().isAccessible()) {
				for (AV_BookMember__c bookM : [SELECT Id, AV_Cliente__c, AV_Cartera__c, AV_Cartera__r.AV_TipoCartera__c FROM AV_BookMember__c WHERE AV_Cliente__c = :setCartera]) {
                    if(bookM.AV_Cliente__c != null && !lstCartera.contains(bookM.AV_Cliente__c) ){
                        lstCartera.add(bookM.AV_Cliente__c);
                    }					
				}
            }
        }

        if (Schema.AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible()) {
            for (AV_BookManagementMember__c bookMM : [SELECT Id, AV_Cartera__c,AV_Cartera__r.AV_Centro__c FROM AV_BookManagementMember__c WHERE AV_EmpleadoGestor__r.AV_UsuarioAsociado__c =: UserInfo.getUserId()]) {
                if(bookMM.AV_Cartera__r?.AV_Centro__c != null && !lstCartera.contains(bookMM.AV_Cartera__r.AV_Centro__c) ){
                    lstCartera.add(bookMM.AV_Cartera__r.AV_Centro__c);
                }						
            }
        }

        return lstCartera;	
    }

    /**
     * Metodo para recuperar la jerarquia definida en los parametros de entrada.
     */
	@AuraEnabled(cacheable=true)
    public static List<CIBE_hierarchy__c> getExternalHierarchy(List<String> redesFilter,List<String> centrosFilter, List<String> sectoresFilter, List<String> industriaFilter){
        List<CIBE_hierarchy__c> lstHier = new List<CIBE_hierarchy__c>();
        List<Id> lstHierId = new List<Id>();
        String queryHier = 'SELECT CIBE_Contact__c FROM CIBE_hierarchy__c WHERE Recordtype.developername = :HIERARCHY_EMPLOYEE_RT ';
        if(!redesFilter.isEmpty()){
            queryHier += ' AND CIBE_RedesSegmentos__c IN :redesFilter';
        }
        if(!sectoresFilter.isEmpty()){
            queryHier += ' AND CIBE_SectoresPaises__c IN :sectoresFilter';
            if(!centrosFilter.isEmpty()){
                queryHier += ' AND CIBE_CentrosCarteras__c IN :centrosFilter ';
            }
        }
        lstHier = Database.query(String.escapeSingleQuotes(queryHier));
        for(CIBE_hierarchy__c hier: lstHier){
            if(!lstHierId.contains(hier.CIBE_Contact__c)){
                lstHierId.add(hier.CIBE_Contact__c);
            }
        }
        if(!industriaFilter.isEmpty()){
            List<CIBE_hierarchy__c> lstHierIndustria =  [SELECT  CIBE_Contact__c  FROM CIBE_hierarchy__c 
            WHERE CIBE_Contact__c =:lstHierId AND CIBE_SectoresPaises__c IN :industriaFilter  AND Recordtype.developername = : HIERARCHY_EMPLOYEE_RT];
            lstHierId.clear();
            for(CIBE_hierarchy__c hier: lstHierIndustria){
                if(!lstHierId.contains(hier.CIBE_Contact__c)){
                    lstHierId.add(hier.CIBE_Contact__c);
                }
            }
        }
        lstHier    =  [SELECT  CIBE_Contact__c, CIBE_Negocios__r.Name,CIBE_CentrosCarteras__r.Name,CIBE_RedesSegmentos__r.Name, CIBE_SectoresPaises__r.Name
                            FROM CIBE_hierarchy__c 
                            WHERE CIBE_Contact__c =:lstHierId   AND Recordtype.developername = : HIERARCHY_EMPLOYEE_RT];
            return lstHier;
		
    }

/**
 * Metodo para buscar las oportunidades acorde a los parámetros
 * parms: redesFilter, sectoresFilter, centrosFilter, participeFilter, statusFilter, paisFilter, fechaCierreFilter, industriaFilter, isMisClientes, isESG,offset
 * return:
 */
@AuraEnabled
    public static List<OpportunityWrapper> getOppsFilter(String [] redesFilter, String [] sectoresFilter, String [] centrosFilter, String [] participeFilter, String [] statusFilter, String [] paisFilter, 
    Date [] fechaCierreFilter, String [] industriaFilter, Boolean isMisClientes, Boolean isESG, Integer offset) {
        String methodName = 'getOppsFilter';
        offSet = offSet <= 2000 ? offset : 2000;
        //RT
        List<String> lstLabelsRts = new List<String>{CIBE_AppConstants.OPP_ACCIONCIB_RT,CIBE_AppConstants.OPP_SUGERENCIACIB_RT,CIBE_AppConstants.OPP_ALERTACIB_RT,CIBE_AppConstants.OPP_INICIATIVACIB_RT};
        //OTM
        List<OpportunityTeamMember> listaOtm = new List<OpportunityTeamMember>();
        List<Id> setIdsOP = new List<Id>();
        if(participeFilter!=null && !participeFilter.isEmpty() ){
            listaOtm  = [Select OpportunityId from OpportunityTeamMember WHERE user.id IN:participeFilter];
            if(!listaOtm.isEmpty()) {
                for(OpportunityTeamMember otm: listaOtm){
                    setIdsOP.add(otm.OpportunityId);
                }
            }
        }
        //Hier
        Map<Id, HierarchyWrapper> mapHier = getHierarchies(isMisClientes,redesFilter,centrosFilter,sectoresFilter,industriaFilter);
        List<Id> setContact = new List<Id>();
        List<Id> lstCartera = new List<Id>();
        if(!mapHier.isEmpty()){setContact.addAll(mapHier.keySet());}
        if(isMisClientes) {
            lstCartera = getCartera();
        }
        String query = getQueryFiltred (participeFilter, statusFilter, paisFilter, fechaCierreFilter, industriaFilter, isMisClientes, isESG,setContact,setIdsOP);
        query += ' ORDER BY CloseDate ASC LIMIT 10  OFFSET :offset';
        query = query.replaceAll('[{}]', '');

        List<Opportunity> lista = Database.query(String.escapeSingleQuotes(query));

        // Mapeo de jerarquia query en base a si se puede filtrar por los campos para filtrar por menos opportunidades
        List<OpportunityWrapper> listOppWrapp = new List<OpportunityWrapper>();
        if(!lista.isEmpty()){
            for(Opportunity op: lista) {
                OpportunityWrapper oppWrapp = new OpportunityWrapper();
                if(mapHier.containsKey(op.AV_Gestor__c)) {
                    HierarchyWrapper hw = mapHier.get(op.AV_Gestor__c);
                    oppWrapp.negocios = String.join((Iterable<String>)hw.negocios, ', ');
                    oppWrapp.centrosCarteras = String.join((Iterable<String>)hw.centrosCarteras, ', ');
                    oppWrapp.redesSegmentos = String.join((Iterable<String>)hw.redesSegmentos, ', ');
                    oppWrapp.sectoresPaises = String.join((Iterable<String>)hw.sectoresPaises, ', ');
                }
                if(redesFilter.isEmpty() ||( !redesFilter.isEmpty() &&  String.isNotBlank(oppWrapp.redesSegmentos) )){
                    oppWrapp.negocios = String.isNotBlank(oppWrapp.negocios) ? oppWrapp.negocios: '';
                    oppWrapp.centrosCarteras = String.isNotBlank(oppWrapp.centrosCarteras) ? oppWrapp.centrosCarteras: '';
                    oppWrapp.redesSegmentos = String.isNotBlank(oppWrapp.redesSegmentos) ? oppWrapp.redesSegmentos: '';
                    oppWrapp.sectoresPaises = String.isNotBlank(oppWrapp.sectoresPaises) ? oppWrapp.sectoresPaises: '';
                    oppWrapp.iden = String.isNotBlank(op.Id) ? op.Id : '';
                    oppWrapp.name = String.isNotBlank(op.name) ? op.name : '';
                    oppWrapp.accountId = String.isNotBlank(op.AccountId) ? op.AccountId : null;
                    oppWrapp.accountName = String.isNotBlank(op.Account.Name) ? op.Account.Name : '';
                    oppWrapp.grupoComercialId = String.isNotBlank(op.CIBE_GrupoComercial__c) ? op.CIBE_GrupoComercial__c : null;
                    oppWrapp.grupoComercialName = String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name : '';
                    oppWrapp.grupoEconomico = String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c : '';
                    oppWrapp.pFId = String.isNotBlank(op.AV_PF__c) ? op.AV_PF__c : null;
                    oppWrapp.pFName = String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '';
                    oppWrapp.amountDivisa = op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.divisa = String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '';
                    oppWrapp.amountEuro = op.CIBE_AmountEuro__c != null ? Integer.valueOf(op.CIBE_AmountEuro__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.balanceDivisa = op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.comisionesDivisa = op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.balance = op.CIBE_Balance__c != null ? Integer.valueOf(op.CIBE_Balance__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.comisiones = op.CIBE_Comisiones__c != null ? Integer.valueOf(op.CIBE_Comisiones__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.tipoOperaciones = String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '';
                    oppWrapp.stageName = String.isNotBlank(op.StageName) ? op.StageName : '';
                    oppWrapp.closeDate = op.CloseDate;
                    oppWrapp.diasUltimaGestion = op.CIBE_DiasUltimaGestion__c != null ? String.valueOf(op.CIBE_DiasUltimaGestion__c) : '';
                    oppWrapp.ownerId = String.isNotBlank(op.OwnerId) ? op.OwnerId : '';
                    oppWrapp.ownerName = String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '';
                    oppWrapp.eapGestorName = String.isNotBlank(op.Account.AV_EAPGestor__r.Name) ? op.Account.AV_EAPGestor__r.Name : ''; 
                    listOppWrapp.add(oppWrapp);
                }
            }
        }
        return listOppWrapp;
    }

    private static Map<Id, HierarchyWrapper> getHierarchies(Boolean isMisClientes, List<String> redesFilter, List<String> centrosFilter, List<String> sectoresFilter, List<String> industriaFilter) {
        // Mapeo de jerarquia query en base a si se puede filtrar por los campos para filtrar por menos opportunidades
        Map<Id, HierarchyWrapper> mapHier = new Map<Id, HierarchyWrapper>();
        List<CIBE_hierarchy__c> lstHier = new List<CIBE_hierarchy__c>();
        if(isMisClientes && !redesFilter.isEmpty() ){
            lstHier = getMyHierarchy();
        }else if(!isMisClientes){
            lstHier = getExternalHierarchy(redesFilter,centrosFilter,sectoresFilter,industriaFilter);
        }
        if(!lstHier.isEmpty()){
            for(CIBE_Hierarchy__c hier :lstHier) {
                if(!mapHier.containsKey(hier.CIBE_Contact__c)) {
                    mapHier.put(
                        hier.CIBE_Contact__c,
                        new HierarchyWrapper(
                            hier.CIBE_Negocios__r.Name, 
                            hier.CIBE_CentrosCarteras__r.Name,
                            hier.CIBE_RedesSegmentos__r.Name, 
                            hier.CIBE_SectoresPaises__r.Name
                        )
                    );
                } else if(mapHier.containsKey(hier.CIBE_Contact__c)) {
                    HierarchyWrapper hw = mapHier.get(hier.CIBE_Contact__c);
                    if(String.isNotBlank(hier.CIBE_Negocios__r.Name)) {
                        hw.negocios.add(hier.CIBE_Negocios__r.Name);
                    }
                    if(String.isNotBlank(hier.CIBE_CentrosCarteras__r.Name)) {
                        hw.centrosCarteras.add(hier.CIBE_CentrosCarteras__r.Name);
                    }
                    if(String.isNotBlank(hier.CIBE_RedesSegmentos__r.Name)) {
                        hw.redesSegmentos.add(hier.CIBE_RedesSegmentos__r.Name);
                    }
                    if(String.isNotBlank(hier.CIBE_SectoresPaises__r.Name)) {
                        hw.sectoresPaises.add(hier.CIBE_SectoresPaises__r.Name);
                    }
                }
            }
        }
        return mapHier;
    }

    public static String getQueryFiltred (String [] participeFilter, String [] statusFilter, String [] paisFilter, Date [] fechaCierreFilter, String [] industriaFilter, Boolean isMisClientes, Boolean isESG, String [] setContact,String [] setIdsOP) {
        //RT
        List<String> lstLabelsRts = new List<String>{CIBE_AppConstants.OPP_ACCIONCIB_RT,CIBE_AppConstants.OPP_SUGERENCIACIB_RT,CIBE_AppConstants.OPP_ALERTACIB_RT,CIBE_AppConstants.OPP_INICIATIVACIB_RT};
        List<Id> lstCartera = new List<Id>();
        Set<String> setOppFields = new Set<String>{'Id', 'Name', 'AV_PF__c', 'AV_PF__r.Name','CIBE_Balance__c','Amount','CIBE_Comisiones__c', 'CIBE_Divisa__c', 'CIBE_AmountDivisa__c',
                                                    'AV_Gestor__c', 'RecordTypeId', 'RecordType.Name', 'CIBE_GrupoComercial__c','CIBE_GrupoComercial__r.Name', 'Account.CIBE_GrupoEconomico__c', 
                                                    'CloseDate', 'CIBE_TipoOperacion__c','Account.Name', 'Owner.Name', 'OwnerId', 'AccountId','CIBE_BalanceDivisa__c',
                                                    'CIBE_DiasUltimaGestion__c', 'Account.AV_EAPGestor__c', 'Account.AV_EAPGestor__r.Name','CIBE_AmountEuro__c','CIBE_ComisionesDivisa__c'};
        String query;
        String toLabelFields = 'TOLABEL(StageName)';
        query = 'SELECT ' + String.join(new List<String>(setOppFields), ',') + ', ' + toLabelFields + ' FROM Opportunity WHERE CloseDate >= LAST_N_MONTHS:24 AND RecordType.DeveloperName IN : lstLabelsRts AND CIBE_ESG__c =:isESG';
        if(!fechaCierreFilter.isEmpty()){
            query += ' AND ( ';
            for(Date fcierre: fechaCierreFilter){
                query += ' CloseDate  = '+ String.valueOf(fcierre).remove(' 00:00:00') +' OR ';
            }
            query = query.removeEndIgnoreCase(' OR ');
            query += ' )';
        }
        if(!statusFilter.isEmpty() ){
            query +=  ' AND StageName  IN :statusFilter ';
        }
        if(isMisClientes) {
            lstCartera = getCartera();
        }else{
            query += ' AND OwnerId != : USER_LOG';
        }
        if(!lstCartera.isEmpty() && lstCartera != null){
            query += ' AND AccountId IN : lstCartera';
        }else  if(setIdsOP !=null && !setIdsOP.isEmpty()) {
            query +=  ' AND ( ID  IN :setIdsOP OR OwnerId  IN :participeFilter )';
        }
        if(!paisFilter.isEmpty()) {
            query +=  ' AND CIBE_Pais__c  IN :paisFilter';
        }
        if(!setContact.isEmpty() && setContact!=null){
            query +=  ' AND AV_Gestor__c  IN :setContact';
        }
        return query;
}

    @AuraEnabled
    public static List<String> exportOpportunities (String [] redesFilter, String [] sectoresFilter, String [] centrosFilter, String [] participeFilter, String [] statusFilter, String [] paisFilter, 
    Date [] fechaCierreFilter, String [] industriaFilter, Boolean isMisClientes, Boolean isESG) {
        List<String> lstLabelsRts = new List<String>{CIBE_AppConstants.OPP_ACCIONCIB_RT,CIBE_AppConstants.OPP_SUGERENCIACIB_RT,CIBE_AppConstants.OPP_ALERTACIB_RT,CIBE_AppConstants.OPP_INICIATIVACIB_RT};
        Map<Id, HierarchyWrapper> mapHier = getHierarchies(isMisClientes,redesFilter,centrosFilter,sectoresFilter,industriaFilter);
        List<Id> setContact = new List<Id>();
        if(!mapHier.isEmpty()){setContact.addAll(mapHier.keySet());}
        //OTM
        List<OpportunityTeamMember> listaOtm = new List<OpportunityTeamMember>();
        List<Id> setIdsOP = new List<Id>();
        List<Id> lstCartera = new List<Id>();
        if(isMisClientes) {
            lstCartera = getCartera();
        }
        if(participeFilter!=null && !participeFilter.isEmpty() ){
            listaOtm  = [Select OpportunityId from OpportunityTeamMember WHERE user.id IN:participeFilter];
            if(!listaOtm.isEmpty()) {
                for(OpportunityTeamMember otm: listaOtm){
                    setIdsOP.add(otm.OpportunityId);
                }
            }
        }
        String query = getQueryFiltred (participeFilter, statusFilter, paisFilter, fechaCierreFilter, industriaFilter, isMisClientes, isESG,setContact,setIdsOP);
        query += ' ORDER BY CloseDate';
        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));
        List<String> opportunities = new List<String>();
        if(!listOpp.isEmpty()){
            for(Opportunity op: listOpp) {
                String opp = '';
                opp += (String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name.replaceAll(';', '.')  : '') + ';';
                opp += (String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c : '') + ';';
                opp += (String.isNotBlank(op.Account.Name) ? op.Account.Name.replaceAll(';', '.')  : '') + ';';
                opp += (String.isNotBlank(op.name) ? op.name.replaceAll(';', '.')  : '') + ';';
                opp += (String.isNotBlank(op.StageName) ? op.StageName : '') + ';';
                opp += (op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '') + ';';
                opp += (op.CloseDate != null ? String.valueOf(op.CloseDate) : '') + ';';
                opp += (String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '') + ';';
                opp += (String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '') + ';';
                opp += (op.CIBE_AmountEuro__c != null ? Integer.valueOf(op.CIBE_AmountEuro__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_Balance__c != null ? Integer.valueOf(op.CIBE_Balance__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_Comisiones__c != null ? Integer.valueOf(op.CIBE_Comisiones__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_DiasUltimaGestion__c != null ? String.valueOf(op.CIBE_DiasUltimaGestion__c) : '') + ';';
                opp += (String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '') + ';';
                if(mapHier.containsKey(op.AV_Gestor__c)) {
                    HierarchyWrapper hw = mapHier.get(op.AV_Gestor__c);
                    opp += (String.join((Iterable<String>)hw.negocios, ', ')) + ';'; 
                    opp += (String.join((Iterable<String>)hw.redesSegmentos, ', ')) + ';';
                    opp += (String.join((Iterable<String>)hw.sectoresPaises, ', ')) + ';'; 
                    opp += (String.join((Iterable<String>)hw.centrosCarteras, ', ')) + ';'; 
                } else {
                    opp += ';;;;';
                }
                    opp += (String.isNotBlank(op.Account.AV_EAPGestor__r.Name) ? op.Account.AV_EAPGestor__r.Name : '') + ';'; 
                    opp += '\n'; 
                    opportunities.add(opp);
            }
        }
        return opportunities;
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
    @AuraEnabled public String grupoComercialId {get;set;}
    @AuraEnabled public String grupoComercialName {get;set;}
    @AuraEnabled public String grupoEconomico {get;set;}
    @AuraEnabled public String pFId {get;set;}
    @AuraEnabled public String pFName {get;set;}
    @AuraEnabled public String amountDivisa {get;set;}
    @AuraEnabled public String divisa {get;set;}
    @AuraEnabled public String amountEuro {get;set;} //currency (18, 0)*
    @AuraEnabled public String balanceDivisa {get;set;}
    @AuraEnabled public String comisionesDivisa {get;set;}
    @AuraEnabled public String balance {get;set;} //currency (16, 0)
    @AuraEnabled public String comisiones {get;set;} //currency (16, 0)
    @AuraEnabled public String tipoOperaciones {get;set;}
    @AuraEnabled public String stageName {get;set;}
    @AuraEnabled public Date closeDate {get;set;}
    @AuraEnabled public String diasUltimaGestion {get;set;} //double (18, 0)*
    @AuraEnabled public String ownerId {get;set;}
    @AuraEnabled public String ownerName {get;set;}
    @AuraEnabled public String eapGestorName {get;set;}
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

public class OptionsParticipes  {
    @AuraEnabled 
    public String value;
    @AuraEnabled 
    public String label;
    public OptionsParticipes(String value, String label){
        this.label = label;
        this.value = value;		
    }
}

public class OptionsIndustrias  {
    @AuraEnabled public String value;
    @AuraEnabled public String label;

    public OptionsIndustrias(String value, String label){
        this.label = label;
        this.value = value;		
    }
}
}