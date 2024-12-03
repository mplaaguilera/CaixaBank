/**********************************************************************************************************************
    Name:	  CIBE_TabListOppComitePreciosCIBController
    Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componente cibe_TabListOppComitePreciosCIB
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE		    Description
	1.0			US52277         Ali 		    17/10/2023	    Init version
    2.0			US807614        Luis Martínez   30/01/2024	    Cambios usabilidad
    2.1			US850814    	Lucía	  	    05/06/2024		Añadir los campos CIBE_AbsoluteClientProfSeg__c, CIBE_AbsoluteGroupProfSeg__c, CIBE_RelativeClientProfSeg__c y CIBE_RelativeGroupProfSeg__c
    2.2			IN1214117    	Lucía	  	    09/10/2024		Modificar el metodo exportOpportunities
    2.3			PPM100538662    Lucía	  	    22/10/2024		Modificar los metodos exportOpportunities, getOpportunity y nuevos metodos getDocumentOpp, getOptionsHierarchy



*/
public with sharing class CIBE_TabListOppComitePreciosCIBContr {

    private static List<String> stages = new List<String>{'En curso', 'CIBE_Pendiente_firma', 'Potencial'};
    private static List<String> stagesFechaPasado = new List<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO, CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA, CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL, CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI, CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA, CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO};
    private static final String HIERARCHY_EMPLOYEE_RT  = CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT;    
    private static Set<Id> recordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT)
        });
    private static String createdDate = CIBE_DataMapping__mdt.getInstance('CIBE_CreatedDateOppCIB').CIBE_Value__c;
    private static DateTime fechaActual = System.now();
    private static List<String> partes = createdDate.split(':'); 
    private static Integer mesesAtras = Integer.valueOf(partes[1]); 
    private static DateTime fechaCalculada = fechaActual.addMonths(-mesesAtras);

    public static String gestor = System.Label.CIBE_Gestor;
    private static String cliente = System.Label.CIBE_Cliente;


    @AuraEnabled(cacheable = true) 
    public static List<OpportunityWrapper> getOpportunity(Integer offSet, Date fecha, Date desde, Date hasta, String negocios, String redesSegmentos, String sectoresPaises, String centrosCarteras, Integer importeDesde, Integer importeHasta, String tipoAprobacion, String sector, String cartera) {
        offSet = offSet <= 2000 ? offset : 2000;
        Map<Id, HierarchyWrapper> mapHier = new Map<Id, HierarchyWrapper>();
        Map<Id, HierarchyWrapper> mapHierS = new Map<Id, HierarchyWrapper>();
        Map<Id, HierarchyWrapper> mapHierCartera = new Map<Id, HierarchyWrapper>();
        Set <Id> setContactHier = new Set<Id>();
        Set <Id> setContactHierS = new Set<Id>();
        Set <Id> setContactHierCartera = new Set<Id>();
        if(!String.IsBlank(negocios)){
            mapHier = getHierarchies(negocios, redesSegmentos,sectoresPaises, centrosCarteras);
            setContactHier = mapHier.KeySet();
        }

        if(!String.IsBlank(sector)){
            String negocioSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking Unit'].Id;
            String redesSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking España'].Id;
            mapHierS = getHierarchies(negocioSector, redesSector, sector, null);
            setContactHierS = mapHierS.KeySet();
        }

        if(!String.IsBlank(cartera) && !String.IsBlank(sector)){
            String negocioSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking Unit'].Id;
            String redesSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking España'].Id;
            mapHierCartera = getHierarchies(negocioSector, redesSector, sector, cartera);
            setContactHierCartera = mapHierCartera.KeySet();
        }
        String counQuery =  'SELECT COUNT(Id) total FROM Opportunity WHERE RecordTypeId IN :recordTypes AND CreatedDate >= :fechaCalculada ';
        String query = 'SELECT Id,  CIBE_RenewModificationAmount__c, CIBE_LastAmountVariation__c, CIBE_ApprovalType__c,  CIBE_Observacionesprecio__c, Account.AV_EAPGestor__c , Account.AV_EAPGestor__r.Name,   CIBE_Fechaaprobacionprecio__c, OwnerId, Owner.Name, CIBE_Pais__c, AccountId, Account.Name, Account.CC_Numero_Documento__c, '+
        'Account.CIBE_GrupoEconomico__c, CIBE_GrupoComercial__c, CIBE_GrupoComercial__r.Name, Name, ' +
        'Account.CIBE_Rating_PD__c, CIBE_RARSeveridad__c, CIBE_AmountDivisa__c, CIBE_Divisa__c, CIBE_AmountEuro__c, ' +
        'CIBE_RARPlazoMeses__c, CIBE_RARPlazoFecha__c, TOLABEL(CIBE_TipoOperacion__c), AV_PF__c, AV_PF__r.Name, ' +
        'CIBE_RARIndiceReferencia__c, CIBE_RARInteresDiferencial__c,  CIBE_RARConjunto__c, ' +
        'CIBE_RAROperacionRar__c, CIBE_RARPost__c, CIBE_ComisionSaldoMedio__c, CIBE_RARComisionApertura__c, ' +
        'CIBE_RARGarantias__c, CIBE_VAOperacion__c, CIBE_RARMargenDiario__c, CIBE_RARComision12meses__c, CloseDate, ' + 
        'CIBE_BalanceDivisa__c, CIBE_ImpactoDivisaComisionesCierreAnio__c, CIBE_ComisionesDivisa__c, CIBE_Impacto_Comisiones_Cierre_Anio__c, ' +
        'AV_ClienteConfidencial__c, CIBE_ECAs__c, CIBE_AlgunaOperRAR__c, CIBE_VigenciaOferta__c, CIBE_DicALM__c, ' +
        'CIBE_CreditPortAnalystReview__c, CIBE_Nivel__c, CIBE_Sindicaciones__c, CIBE_SyndicationTeamOpinion__c, CIBE_Observaciones__c, CIBE_Linea__c, AV_Gestor__c , TOLABEL(Account.CIBE_AbsoluteClientProfSeg__c), TOLABEL(Account.CIBE_AbsoluteGroupProfSeg__c), ' +
        'TOLABEL(Account.CIBE_RelativeClientProfSeg__c), TOLABEL(Account.CIBE_RelativeGroupProfSeg__c)' +
        'FROM Opportunity ' +
        'WHERE RecordTypeId IN :recordTypes ' + 
        'AND CreatedDate >= :fechaCalculada ';

        if(hasta != null){

            if(hasta < System.today() ){

                query += ' AND StageName IN :stagesFechaPasado ';
                counQuery +=  ' AND StageName IN :stagesFechaPasado ';
               
            }else {

                query += ' AND StageName IN :stages ';
                counQuery +=  ' AND StageName IN :stages ';
                
            }

            query += ' AND CIBE_Fechaaprobacionprecio__c <= :hasta ';
            counQuery +=  ' AND CIBE_Fechaaprobacionprecio__c <= :hasta ';
        }else {

            if(fecha != null){
                if(fecha < System.today() ){
                    query += ' AND StageName IN :stagesFechaPasado ';
                    counQuery +=  ' AND StageName IN :stagesFechaPasado ';
                }else {
                    query += ' AND StageName IN :stages ';
                    counQuery +=  ' AND StageName IN :stages ';
                }
        
                query += ' AND CIBE_Fechaaprobacionprecio__c = :fecha ';
                counQuery +=  ' AND CIBE_Fechaaprobacionprecio__c = :fecha ';
            }else{
                query += ' AND StageName IN :stages ';
                counQuery +=  ' AND StageName IN :stages ';
            }
        }

                if(!String.IsBlank(negocios) && !setContactHier.isEmpty()){
                    query += 'AND AV_Gestor__c IN : setContactHier ';
                    counQuery +=  'AND AV_Gestor__c IN : setContactHier ';
                }

                if(desde != null){
                    query += ' AND CIBE_Fechaaprobacionprecio__c >= :desde';
                    counQuery +=  ' AND CIBE_Fechaaprobacionprecio__c >= :desde';
                }

                if(importeDesde != null){
                    query += ' AND CIBE_AmountDivisa__c >= :importeDesde';
                    counQuery +=  ' AND CIBE_AmountDivisa__c >= :importeDesde';
                }

                if(importeHasta != null){
                    query += ' AND CIBE_AmountDivisa__c <= :importeHasta';
                    counQuery +=  ' AND CIBE_AmountDivisa__c <= :importeHasta';
                }   

                if(tipoAprobacion != null){
                    query += ' AND CIBE_ApprovalType__c = :tipoAprobacion';
                    counQuery += ' AND CIBE_ApprovalType__c = :tipoAprobacion';
                }

                if(!String.IsBlank(sector) ){
                    query += ' AND Account.AV_EAPGestor__c IN :setContactHierS ';
                    counQuery +=  ' AND Account.AV_EAPGestor__c IN :setContactHierS ';
                }

                if(!String.IsBlank(cartera) && !String.IsBlank(sector) ){
                    query += ' AND Account.AV_EAPGestor__c IN :setContactHierCartera ';
                    counQuery +=  ' AND Account.AV_EAPGestor__c IN :setContactHierCartera ';
                }
        query += ' ORDER BY CIBE_GrupoComercial__r.CIBE_GrupoComercial__c ASC NULLS LAST LIMIT 10 OFFSET :offSet';



        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));
        List<AggregateResult> nuOppd = Database.query(String.escapeSingleQuotes(counQuery));
        Integer totalPage = (Integer) nuOppd[0].get('total');

        List<OpportunityWrapper> listOppWrapp = new List<OpportunityWrapper>();

        if(!listOpp.isEmpty()){
            for(Opportunity op: listOpp) {
                OpportunityWrapper oppWrapp = new OpportunityWrapper();
                if((!String.IsBlank(negocios) && !setContactHier.isEmpty() && !mapHier.isEmpty() && mapHier.containsKey(op.AV_Gestor__c)) ||
                    (String.IsBlank(negocios) && setContactHier.isEmpty())) {
                    oppWrapp.iden = String.isNotBlank(op.Id) ? '/' +  op.Id : '';
                    oppWrapp.fechaAprobacionPrecio = op.CIBE_Fechaaprobacionprecio__c;
                    oppWrapp.ownerId = String.isNotBlank(op.OwnerId) ? '/' +  op.OwnerId : null;
                    oppWrapp.ownerName = String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '';
                    oppWrapp.pais = String.isNotBlank(op.CIBE_Pais__c) ? op.CIBE_Pais__c : '';
                    oppWrapp.accountId = String.isNotBlank(op.AccountId) ? '/' +  op.AccountId : null;
                    oppWrapp.accountName = String.isNotBlank(op.Account.Name) ? op.Account.Name : '';
                    oppWrapp.accountCif = String.isNotBlank(op.Account.CC_Numero_Documento__c) ? op.Account.CC_Numero_Documento__c : '';
                    oppWrapp.grupoEconomico = String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c : '';
                    oppWrapp.grupoComercialId = String.isNotBlank(op.CIBE_GrupoComercial__c) ? '/' +  op.CIBE_GrupoComercial__c : null;
                    oppWrapp.grupoComercialName = String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name : '';
                    oppWrapp.name = String.isNotBlank(op.Name) ? op.Name : '';
                    oppWrapp.rating = String.isNotBlank(op.Account.CIBE_Rating_PD__c) ? op.Account.CIBE_Rating_PD__c : '';
                    oppWrapp.rarSeveridad = op.CIBE_RARSeveridad__c != null ? Integer.valueOf(op.CIBE_RARSeveridad__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.amountDivisa = op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.divisa = String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '';
                    oppWrapp.amountEuros = op.CIBE_AmountEuro__c != null ? Integer.valueOf(op.CIBE_AmountEuro__c.round(RoundingMode.HALF_UP)).format() : '';
                    if(op.CIBE_RARPlazoMeses__c != null){
                        oppWrapp.rarPlazoVidaMediaMeses = op.CIBE_RARPlazoMeses__c != null ? getYear(op.CIBE_RARPlazoMeses__c).setScale(2, RoundingMode.HALF_UP).format() : '';
                    }
                    oppWrapp.tipoOperaciones = String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '';
                    oppWrapp.pFId = String.isNotBlank(op.AV_PF__c) ? '/' +  op.AV_PF__c : null;
                    oppWrapp.pFName = String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '';
                    oppWrapp.rarIndiceReferencia = op.CIBE_RARIndiceReferencia__c != null ? Integer.valueOf(op.CIBE_RARIndiceReferencia__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.rarInteresDiferencial = op.CIBE_RARInteresDiferencial__c != null ? op.CIBE_RARInteresDiferencial__c.setScale(2, RoundingMode.HALF_UP).format() : '';
                    oppWrapp.rarConjunto = op.CIBE_RARConjunto__c != null ? op.CIBE_RARConjunto__c.setScale(2, RoundingMode.HALF_UP).format() : '';      
                    oppWrapp.rarOperacionRar = op.CIBE_RAROperacionRar__c != null ? op.CIBE_RAROperacionRar__c.setScale(2, RoundingMode.HALF_UP).format() : '';   
                    oppWrapp.rarPost = op.CIBE_RARPost__c != null ? op.CIBE_RARPost__c.setScale(2, RoundingMode.HALF_UP).format() : '';
                    oppWrapp.comisionSaldoMedio = op.CIBE_ComisionSaldoMedio__c != null ? Integer.valueOf(op.CIBE_ComisionSaldoMedio__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.rarComisionApertura = op.CIBE_RARComisionApertura__c != null ? Integer.valueOf(op.CIBE_RARComisionApertura__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.rarGarantias = op.CIBE_RARGarantias__c;
                    oppWrapp.vaOperacion = op.CIBE_VAOperacion__c != null ? Integer.valueOf(op.CIBE_VAOperacion__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.rarMargenDiario = op.CIBE_RARMargenDiario__c != null ? Integer.valueOf(op.CIBE_RARMargenDiario__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.rarComision12meses = op.CIBE_RARComision12meses__c != null ? Integer.valueOf(op.CIBE_RARComision12meses__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.closeDate = op.CloseDate;
                    oppWrapp.balanceDivisa = op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.impactoDivisaComisionesCierreAnio = op.CIBE_ImpactoDivisaComisionesCierreAnio__c != null ? Integer.valueOf(op.CIBE_ImpactoDivisaComisionesCierreAnio__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.comisionesDivisa = op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.impactoComisionesCierreAnio = op.CIBE_Impacto_Comisiones_Cierre_Anio__c != null ? Integer.valueOf(op.CIBE_Impacto_Comisiones_Cierre_Anio__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.confidencial = op.AV_ClienteConfidencial__c; 
                    oppWrapp.ecas = op.CIBE_ECAs__c;
                    oppWrapp.algunaOperacionRAR = op.CIBE_AlgunaOperRAR__c;
                    oppWrapp.vigenciaOferta = String.isNotBlank(op.CIBE_VigenciaOferta__c) ? op.CIBE_VigenciaOferta__c : '';
                    oppWrapp.dictamenALM = op.CIBE_DicALM__c;
                    oppWrapp.analystReview = String.isNotBlank(op.CIBE_CreditPortAnalystReview__c) ? op.CIBE_CreditPortAnalystReview__c : '';
                    oppWrapp.nivel = String.isNotBlank(op.CIBE_Nivel__c) ? op.CIBE_Nivel__c : '';
                    oppWrapp.sindicaciones = op.CIBE_Sindicaciones__c;
                    oppWrapp.sindicacionesTeam = op.CIBE_SyndicationTeamOpinion__c;
                    oppWrapp.observaciones = String.isNotBlank(op.CIBE_Observaciones__c) ? op.CIBE_Observaciones__c : '';
                    oppWrapp.linea = op.CIBE_Linea__c;
                    oppWrapp.nOpps = totalPage; 
                    oppWrapp.empresaAbsoluta = op.Account.CIBE_AbsoluteClientProfSeg__c;
                    oppWrapp.empresaRelativa = op.Account.CIBE_RelativeClientProfSeg__c;
                    oppWrapp.grupoAbsoluta = op.Account.CIBE_AbsoluteGroupProfSeg__c;
                    oppWrapp.grupoRelativa = op.Account.CIBE_RelativeGroupProfSeg__c;
                    oppWrapp.observacionesPrecio = String.isNotBlank(op.CIBE_Observacionesprecio__c) ? op.CIBE_Observacionesprecio__c : '';
                    oppWrapp.gestorId = String.isNotBlank(op.Account.AV_EAPGestor__c) ? '/' +  op.Account.AV_EAPGestor__c : null;
                    oppWrapp.gestorName = String.isNotBlank(op.Account.AV_EAPGestor__r.Name) ? op.Account.AV_EAPGestor__r.Name : '';  
                    oppWrapp.destacadaIcon = 'utility:add';
                    oppWrapp.iconClass ='slds-button_icon'; 
                    oppWrapp.importeRenovacion = op.CIBE_RenewModificationAmount__c != null ? Integer.valueOf(op.CIBE_RenewModificationAmount__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.importeVariacion = op.CIBE_LastAmountVariation__c != null ? Integer.valueOf(op.CIBE_LastAmountVariation__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.fileIcon = 'utility:file';
                    listOppWrapp.add(oppWrapp);
                }
            }
        }
        


        return listOppWrapp;
    }

    @AuraEnabled
    public static List<String> exportOpportunities(Date fecha, Date desde, Date hasta, String negocios, String redesSegmentos, String sectoresPaises, String centrosCarteras, Integer importeDesde, Integer importeHasta, String tipoAprobacion, String sector, String cartera ) {
        Map<Id, HierarchyWrapper> mapHier = new Map<Id, HierarchyWrapper>();
        Map<Id, HierarchyWrapper> mapHierS = new Map<Id, HierarchyWrapper>();
        Map<Id, HierarchyWrapper> mapHierCartera = new Map<Id, HierarchyWrapper>();
        Set <Id> setContactHier = new Set<Id>();
        Set <Id> setContactHierS = new Set<Id>();
        Set <Id> setContactHierCartera = new Set<Id>();
        if(!String.IsBlank(negocios)){
            mapHier = getHierarchies(negocios, redesSegmentos,sectoresPaises, centrosCarteras);
            setContactHier = mapHier.KeySet();
        }

        if(!String.IsBlank(sector)){
            String negocioSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking Unit'].Id;
            String redesSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking España'].Id;
            mapHierS = getHierarchies(negocioSector, redesSector, sector, null);
            setContactHierS = mapHierS.KeySet();
        }

        if(!String.IsBlank(cartera) && !String.IsBlank(sector)){
            String negocioSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking Unit'].Id;
            String redesSector = [SELECT Id, Name FROM CBK_PicklistValues__c WHERE NAME = 'Corporate Banking España'].Id;
            mapHierCartera = getHierarchies(negocioSector, redesSector, sector, cartera);
            setContactHierCartera = mapHierCartera.KeySet();
        }

        String query = 'SELECT Id,  CIBE_RenewModificationAmount__c, CIBE_LastAmountVariation__c, CIBE_ApprovalType__c,  CIBE_Observacionesprecio__c, Account.AV_EAPGestor__c , Account.AV_EAPGestor__r.Name,   CIBE_Fechaaprobacionprecio__c, OwnerId, Owner.Name, CIBE_Pais__c, AccountId, Account.Name, Account.CC_Numero_Documento__c, '+
        'Account.CIBE_GrupoEconomico__c, CIBE_GrupoComercial__c, CIBE_GrupoComercial__r.Name, Name, ' +
        'Account.CIBE_Rating_PD__c, CIBE_RARSeveridad__c, CIBE_AmountDivisa__c, CIBE_Divisa__c, CIBE_AmountEuro__c, ' +
        'CIBE_RARPlazoMeses__c, CIBE_RARPlazoFecha__c, TOLABEL(CIBE_TipoOperacion__c), AV_PF__c, AV_PF__r.Name, ' +
        'CIBE_RARIndiceReferencia__c, CIBE_RARInteresDiferencial__c,  CIBE_RARConjunto__c, ' +
        'CIBE_RAROperacionRar__c, CIBE_RARPost__c, CIBE_ComisionSaldoMedio__c, CIBE_RARComisionApertura__c, ' +
        'CIBE_RARGarantias__c, CIBE_VAOperacion__c, CIBE_RARMargenDiario__c, CIBE_RARComision12meses__c, CloseDate, ' + 
        'CIBE_BalanceDivisa__c, CIBE_ImpactoDivisaComisionesCierreAnio__c, CIBE_ComisionesDivisa__c, CIBE_Impacto_Comisiones_Cierre_Anio__c, ' +
        'AV_ClienteConfidencial__c, CIBE_ECAs__c, CIBE_AlgunaOperRAR__c, CIBE_VigenciaOferta__c, CIBE_DicALM__c, ' +
        'CIBE_CreditPortAnalystReview__c, CIBE_Nivel__c, CIBE_Sindicaciones__c, CIBE_SyndicationTeamOpinion__c, CIBE_Observaciones__c, CIBE_Linea__c, AV_Gestor__c , TOLABEL(Account.CIBE_AbsoluteClientProfSeg__c), TOLABEL(Account.CIBE_AbsoluteGroupProfSeg__c), ' +
        'TOLABEL(Account.CIBE_RelativeClientProfSeg__c), TOLABEL(Account.CIBE_RelativeGroupProfSeg__c)' +
        'FROM Opportunity ' +
        'WHERE RecordTypeId IN :recordTypes ' + 
        'AND CreatedDate >= :fechaCalculada ';

        if(hasta != null){

            if(hasta < System.today() ){

                query += ' AND StageName IN :stagesFechaPasado ';
               
            }else {

                query += ' AND StageName IN :stages ';
                
            }

            query += ' AND CIBE_Fechaaprobacionprecio__c <= :hasta ';
        }else {

            if(fecha != null){

                if(fecha < System.today() ){
                    query += ' AND StageName IN :stagesFechaPasado ';
                }else {
                    query += ' AND StageName IN :stages ';
                }
        
                query += ' AND CIBE_Fechaaprobacionprecio__c = :fecha ';
            }else{
                query += ' AND StageName IN :stages ';
            }
        }

       
       
            if(!String.IsBlank(negocios) && !setContactHier.isEmpty()){
                query += 'AND AV_Gestor__c IN : setContactHier ';
            }
            query += ' AND CreatedDate >= :fechaCalculada ';

            if(desde != null){
                query += ' AND CIBE_Fechaaprobacionprecio__c >= :desde';
            }
           
            if(importeDesde != null){
                query += ' AND CIBE_AmountDivisa__c >= :importeDesde';
            }
            if(importeHasta != null){
                query += ' AND CIBE_AmountDivisa__c <= :importeHasta';
            }

            if(tipoAprobacion != null){
                query += ' AND CIBE_ApprovalType__c = :tipoAprobacion';
            }

            if(!String.IsBlank(sector) ){
                query += ' AND Account.AV_EAPGestor__c IN :setContactHierS ';
            }

            if(!String.IsBlank(cartera) && !String.IsBlank(sector) ){
                query += ' AND Account.AV_EAPGestor__c IN :setContactHierCartera ';
            }

            query += ' ORDER BY CIBE_GrupoComercial__r.CIBE_GrupoComercial__c ASC NULLS LAST';


        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));

        Map<Id, List<String>> clienteToGestores = getGestorInternational(listOpp);

        List<String> opportunities = new List<String>();

        for(Opportunity op: listOpp) {
            if((!String.IsBlank(negocios) && !setContactHier.isEmpty() && !mapHier.isEmpty() && mapHier.containsKey(op.AV_Gestor__c)) ||
            (String.IsBlank(negocios) && setContactHier.isEmpty())) {
                String opp = '';
                opp += (String.isNotBlank(op.Account.AV_EAPGestor__r.Name) ? op.Account.AV_EAPGestor__r.Name : '') + ';';
                opp += (String.isNotBlank(op.Account.Name) ? op.Account.Name.replaceAll(',', '.')  : '') + ';';
                opp += (String.isNotBlank(op.Account.CIBE_AbsoluteClientProfSeg__c) ? op.Account.CIBE_AbsoluteClientProfSeg__c : '') + ';';
                opp += (String.isNotBlank(op.Account.CIBE_RelativeClientProfSeg__c) ? op.Account.CIBE_RelativeClientProfSeg__c : '') + ';';
                opp += (String.isNotBlank(op.Account.CIBE_AbsoluteGroupProfSeg__c) ? op.Account.CIBE_AbsoluteGroupProfSeg__c : '') + ';';
                opp += (String.isNotBlank(op.Account.CIBE_RelativeGroupProfSeg__c) ? op.Account.CIBE_RelativeGroupProfSeg__c : '') + ';';
                opp += (op.AV_ClienteConfidencial__c ? 'true' : '') + ';';  
                opp += (String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c.replaceAll(',', '.').replaceAll('(\n|\r)', ' ') : '') + ';';
                opp += (String.isNotBlank(op.Account.CIBE_Rating_PD__c) ? op.Account.CIBE_Rating_PD__c.replaceAll(',', '.').replaceAll('(\n|\r)', ' ') : '') + ';';
                opp += (String.isNotBlank(op.name) ? op.name.replaceAll(',', '.')  : '') + ';';
                opp += (String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name.replaceAll(',', '.') : '') + ';';
                opp += (op.CIBE_AmountEuro__c != null ? Integer.valueOf(op.CIBE_AmountEuro__c.round(RoundingMode.HALF_UP)).format() : '') + ';';  
                opp += (op.CIBE_RARPlazoMeses__c != null ? getYear(op.CIBE_RARPlazoMeses__c).setScale(2, RoundingMode.HALF_UP).format().replaceAll(',', '.') : '') + ';';
                opp += (op.CIBE_RARGarantias__c != null ? String.valueOf(op.CIBE_RARGarantias__c).replaceAll(',', '.').replaceAll('(\n|\r)', ' ') : '') + ';';
                opp += (String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '') + ';';
                opp += (op.CIBE_RARMargenDiario__c != null ? Integer.valueOf(op.CIBE_RARMargenDiario__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_RARInteresDiferencial__c != null ? op.CIBE_RARInteresDiferencial__c.setScale(2, RoundingMode.HALF_UP).format().replaceAll(',', '.') : '') + ';';
                opp += (op.CIBE_RARComisionApertura__c != null ? Integer.valueOf(op.CIBE_RARComisionApertura__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_ComisionSaldoMedio__c != null ? Integer.valueOf(op.CIBE_ComisionSaldoMedio__c.round(RoundingMode.HALF_UP)).format().replaceAll(',', '.') : '') + ';';
                opp += (op.CIBE_RARConjunto__c != null ? op.CIBE_RARConjunto__c.setScale(2, RoundingMode.HALF_UP).format().replaceAll(',', '.') : '') + ';';
                opp += (op.CIBE_RAROperacionRar__c != null ? op.CIBE_RAROperacionRar__c.setScale(2, RoundingMode.HALF_UP).format().replaceAll(',', '.') : '') + ';';
                opp += (String.isNotBlank(op.CIBE_Observaciones__c) ? op.CIBE_Observaciones__c.replaceAll(',', '.').replaceAll('(\n|\r)', ' ')  : '') + ';'; 
                opp += (String.isNotBlank(op.CIBE_Observacionesprecio__c) ? op.CIBE_Observacionesprecio__c.replaceAll('(\n|\r)', ' ').replaceAll(',', '.')  : '') + ';'; 
                opp += (op.CIBE_RARPost__c != null ? op.CIBE_RARPost__c.setScale(2, RoundingMode.HALF_UP).format().replaceAll(',', '.') : '') + ';';
                opp += (String.isNotBlank(op.CIBE_Nivel__c) ? op.CIBE_Nivel__c : '').replaceAll(',', '.').replaceAll('(\n|\r)', ' ') + ';';
                opp += (String.isNotBlank(op.CIBE_CreditPortAnalystReview__c) ? op.CIBE_CreditPortAnalystReview__c : '') + ';';
                opp += (String.isNotBlank(op.CIBE_DicALM__c) ? op.CIBE_DicALM__c : '') + ';';
                opp += (op.CIBE_Sindicaciones__c ? 'true' : '') + ';';  
                opp += (String.isNotBlank(op.CIBE_SyndicationTeamOpinion__c) ? op.CIBE_SyndicationTeamOpinion__c : '') + ';';
                opp += (op.CIBE_ECAs__c ? 'true' : '') + ';'; 
                opp += (op.CIBE_AlgunaOperRAR__c ? 'true' : '') + ';'; 
                opp += (String.isNotBlank(op.CIBE_VigenciaOferta__c) ? op.CIBE_VigenciaOferta__c : '') + ';';
                opp += (String.isNotBlank(op.CIBE_Pais__c) ? op.CIBE_Pais__c  : '') + ';'; 
                opp += (op.CIBE_RARIndiceReferencia__c != null ? Integer.valueOf(op.CIBE_RARIndiceReferencia__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CloseDate != null ? String.valueOf(op.CloseDate) : '') + ';';
                opp += (op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_ImpactoDivisaComisionesCierreAnio__c != null ? Integer.valueOf(op.CIBE_ImpactoDivisaComisionesCierreAnio__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_Impacto_Comisiones_Cierre_Anio__c != null ? Integer.valueOf(op.CIBE_Impacto_Comisiones_Cierre_Anio__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name.replaceAll(',', '.').replaceAll('(\n|\r)', ' ')  : '') + ';';
                opp += (String.isNotBlank(op.Account.CC_Numero_Documento__c) ? op.Account.CC_Numero_Documento__c : '') + ';';
                opp += (op.CIBE_Fechaaprobacionprecio__c != null ? String.valueOf(op.CIBE_Fechaaprobacionprecio__c) : '') + ';';
                opp += (op.CIBE_VAOperacion__c != null ? Integer.valueOf(op.CIBE_VAOperacion__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_RARComision12meses__c != null ? Integer.valueOf(op.CIBE_RARComision12meses__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_Linea__c ? 'true' : '') + ';';
                opp += (op.CIBE_RARSeveridad__c != null ? Integer.valueOf(op.CIBE_RARSeveridad__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '') + ';';
                opp += (op.CIBE_RenewModificationAmount__c != null ? Integer.valueOf(op.CIBE_RenewModificationAmount__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_LastAmountVariation__c != null ? Integer.valueOf(op.CIBE_LastAmountVariation__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '') + ';';
                opp += '\n';
                opportunities.add(opp);
            }            
        }

        return opportunities;
    }

    private static Map<Id, List<String>> getGestorInternational(List<Opportunity> listOpp) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, List<String>> clienteToGestores = new Map<Id, List<String>>();
        for(Opportunity op: listOpp) {
            if(String.isNotBlank(op.AccountId)) {
                accountIds.add(op.AccountId);
                clienteToGestores.put(op.AccountId, new List<String>());
            }
        }

        if(!accountIds.isEmpty()) {
            List<AV_BookMember__c> bookMembers = new List<AV_BookMember__c>();
            if(AV_BookMember__c.SObjectType.getDescribe().isAccessible()) {
                bookMembers = [SELECT Id, AV_Cartera__c, AV_Cliente__c 
                                FROM AV_BookMember__c 
                                WHERE   AV_Cliente__c IN :accountIds 
                                        AND AV_Cartera__r.AV_Activa__c = 'S' 
                                        AND CIBE_NegocioCartera__c = 'INT'];
            }

            if(!bookMembers.isEmpty()) {
                Map<Id, List<AV_BookMember__c>> clienteToCartera = new Map<Id, List<AV_BookMember__c>>();
                Map<Id, List<AV_BookManagementMember__c>> carteraToGestor = new Map<Id, List<AV_BookManagementMember__c>>();
                for(AV_BookMember__c bookMember : bookMembers) {
                    if(String.isNotBlank(bookMember.AV_Cartera__c)) {
                        carteraToGestor.put(bookMember.AV_Cartera__c, new List<AV_BookManagementMember__c>());
                    }

                    if(String.isNotBlank(bookMember.AV_Cliente__c)) {
                        if(!clienteToCartera.containsKey(bookMember.AV_Cliente__c)) {
                            clienteToCartera.put(bookMember.AV_Cliente__c, new List<AV_BookMember__c>());
                        }
                        clienteToCartera.get(bookMember.AV_Cliente__c).add(bookMember);
                    }
                }

                List<AV_BookManagementMember__c> bookManagementMembers = new List<AV_BookManagementMember__c>();
                if(AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible()) {
                    bookManagementMembers = [SELECT Id, AV_Cartera__c, AV_EmpleadoGestor__r.Name 
                                                FROM AV_BookManagementMember__c 
                                                WHERE AV_Cartera__c IN :carteraToGestor.keySet()];
                }
                
                for(AV_BookManagementMember__c bookManagementMember : bookManagementMembers) {
                    if(carteraToGestor.containsKey(bookManagementMember.AV_Cartera__c)) {
                        carteraToGestor.get(bookManagementMember.AV_Cartera__c).add(bookManagementMember);
                    }
                }

                for(Id clienteId : clienteToCartera.keySet()) {
                    for(AV_BookMember__c bookMember : clienteToCartera.get(clienteId)) {
                        if(!clienteToGestores.containsKey(clienteId)) {
                            clienteToGestores.put(clienteId, new List<String>());
                        }

                        if(carteraToGestor.containsKey(bookMember.AV_Cartera__c)) {
                            for(AV_BookManagementMember__c bookManagementMember : carteraToGestor.get(bookMember.AV_Cartera__c)) {
                                clienteToGestores.get(clienteId).add(bookManagementMember.AV_EmpleadoGestor__r.Name);
                            }
                        }
                    }
                }
            }
        }
        return clienteToGestores;
    }

    private static Map<Id, HierarchyWrapper> getHierarchies(String negocios, String redesSegmentos, String sectoresPaises, String centrosCarteras ) {
        Map<Id, HierarchyWrapper> mapHier = new Map<Id, HierarchyWrapper>();
        List<CIBE_hierarchy__c> lstHier = new List<CIBE_hierarchy__c>();
        List<Id> lstHierId = new List<Id>();

        if(CIBE_hierarchy__c.SObjectType.getDescribe().isAccessible()) {
            String queryHier = 'SELECT CIBE_Contact__c '+
            ' FROM CIBE_hierarchy__c WHERE CIBE_Contact__c != null AND Recordtype.developername = :HIERARCHY_EMPLOYEE_RT ';
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
                    lstHierId.add(hier.CIBE_Contact__c);
                }
            }

            
            List<CIBE_hierarchy__c> lstHier2    =  [SELECT  CIBE_Contact__c, CIBE_Negocios__r.Name,CIBE_CentrosCarteras__r.Name,CIBE_RedesSegmentos__r.Name, CIBE_SectoresPaises__r.Name
                                                    FROM CIBE_hierarchy__c 
                                                    WHERE CIBE_Contact__c =:lstHierId   AND Recordtype.developername = : HIERARCHY_EMPLOYEE_RT];

            if(!lstHier2.isEmpty()) {
                for(CIBE_Hierarchy__c hier : lstHier2 ) {
                    if(!mapHier.containsKey(hier.CIBE_Contact__c)) {
                        mapHier.put(
                            hier.CIBE_Contact__c, 
                            new HierarchyWrapper(
                                hier.CIBE_Negocios__r.Name, 
                                hier.CIBE_CentrosCarteras__r.Name,
                                hier.CIBE_RedesSegmentos__r.Name, 
                                hier.CIBE_SectoresPaises__r.Name
                            ));
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
        }
        return mapHier;
    }

    public class OpportunityWrapper {
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
        @AuraEnabled public String balanceDivisa {get;set;}
        @AuraEnabled public String comisionesDivisa {get;set;}
        @AuraEnabled public String tipoOperaciones {get;set;}
        @AuraEnabled public Date closeDate {get;set;}
        @AuraEnabled public String ownerId {get;set;}
        @AuraEnabled public String ownerName {get;set;}
        @AuraEnabled public boolean ecas {get;set;}
        @AuraEnabled public boolean algunaOperacionRAR {get;set;}
        @AuraEnabled public String dictamenALM {get;set;}
        @AuraEnabled public String analystReview {get;set;}
        @AuraEnabled public String nivel {get;set;}
        @AuraEnabled public boolean sindicaciones {get;set;}
        @AuraEnabled public String sindicacionesTeam {get;set;}
        @AuraEnabled public String observaciones {get;set;}
        @AuraEnabled public String vigenciaOferta {get;set;}
        @AuraEnabled public Date fechaAprobacionPrecio {get;set;}
        @AuraEnabled public boolean confidencial {get;set;}
        @AuraEnabled public boolean linea {get;set;}
        @AuraEnabled public String pais {get;set;}
        @AuraEnabled public String rating {get;set;}
        @AuraEnabled public String rarSeveridad {get;set;}
        @AuraEnabled public String rarPlazoVidaMediaMeses {get;set;}
        @AuraEnabled public String rarIndiceReferencia {get;set;}
        @AuraEnabled public String rarInteresDiferencial {get;set;}
        @AuraEnabled public String rarPost {get;set;}
        @AuraEnabled public String comisionSaldoMedio {get;set;}
        @AuraEnabled public String rarComisionApertura {get;set;}
        @AuraEnabled public String rarGarantias {get;set;}
        @AuraEnabled public String impactoDivisaComisionesCierreAnio {get;set;}
        @AuraEnabled public String impactoComisionesCierreAnio {get;set;}
        @AuraEnabled public String rarConjunto {get;set;}
        @AuraEnabled public String rarOperacionRar {get;set;}
        @AuraEnabled public String vaOperacion {get;set;}
        @AuraEnabled public String rarMargenDiario {get;set;}
        @AuraEnabled public String rarComision12meses {get;set;}
        @AuraEnabled public String amountEuros {get;set;}
        @AuraEnabled public Integer nOpps {get;set;}
        @AuraEnabled public String empresaAbsoluta {get;set;}
        @AuraEnabled public String empresaRelativa {get;set;}
        @AuraEnabled public String grupoAbsoluta {get;set;}
        @AuraEnabled public String grupoRelativa {get;set;}
        @AuraEnabled public String observacionesPrecio {get;set;}
        @AuraEnabled public String gestorId {get;set;}
        @AuraEnabled public String gestorName {get;set;}
        @AuraEnabled
		public String destacadaIcon;
		@AuraEnabled
		public String iconClass;
        @AuraEnabled public String importeRenovacion {get;set;}
        @AuraEnabled public String importeVariacion {get;set;}
        @AuraEnabled
		public String fileIcon;


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

    public class OptionsField {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }

    public class DocumentsField {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Date createdDate {get;set;}
        @AuraEnabled
        public String id {get;set;}
    }


    public static Decimal getYear(Decimal meses){
        return meses / 12;
    }

    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getTipoAprobacion() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_ApprovalType__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            OptionsField opField= new OptionsField();
            opField.value=objPickList.getValue();
            opField.label=objPickList.getLabel();
            selectOptions.add(opField);
        }
        return selectOptions;
    }


    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getSector(String picklist, String name) {
        List<OptionsField> selectOptions = new List<OptionsField>();

        List<CBK_PicklistValues__c> pickObj = [SELECT Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name FROM CBK_PicklistValues__c where  Name = :name];

		if(!pickObj.isEmpty()){
			List<string> valuesName = new List<string> ();
			for (CBK_PicklistValues__c pv : pickObj) {
				if(pv.CBK_Dependencies__c !=null){
					valuesName.addAll(pv.CBK_Dependencies__c.split(';'));
				}
			}

			List<CBK_PicklistValues__c> pickObjDepend = [SELECT Id, Name, CBK_Picklist__r.Name FROM CBK_PicklistValues__c WHERE NAME IN :valuesName ORDER BY Name];

			for (CBK_PicklistValues__c pv : pickObjDepend) {
				OptionsField pickItem = new OptionsField();
				pickItem.label = pv.name;
				pickItem.value = pv.id;
				selectOptions.add(pickItem);
			}
		}
		return selectOptions;		
    }

    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getCartera(String sector, String picklist) {
        List<OptionsField> selectOptions = new List<OptionsField>();

        List<CBK_PicklistValues__c> pickObj = [SELECT Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name FROM CBK_PicklistValues__c where CBK_Picklist__r.Name = :picklist AND Id = :sector];

		if(!pickObj.isEmpty()){
			List<string> valuesName = new List<string> ();
			for (CBK_PicklistValues__c pv : pickObj) {
				if(pv.CBK_Dependencies__c !=null){
					valuesName.addAll(pv.CBK_Dependencies__c.split(';'));
				}
			}

			List<CBK_PicklistValues__c> pickObjDepend = [SELECT Id, Name, CBK_Picklist__r.Name FROM CBK_PicklistValues__c WHERE NAME IN :valuesName ORDER BY Name];

			for (CBK_PicklistValues__c pv : pickObjDepend) {
				OptionsField pickItem = new OptionsField();
				pickItem.label = pv.name;
				pickItem.value = pv.id;
				selectOptions.add(pickItem);
			}
		}
		return selectOptions;		
    }

    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getOptionsHierarchy() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_CreditPortAnalystReview__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            OptionsField opField= new OptionsField();
            opField.value=objPickList.getValue();
            opField.label=objPickList.getLabel();
            selectOptions.add(opField);
        }
        return selectOptions;
    }   

    @AuraEnabled
    public static List<DocumentsField> getDocumentOpp(String recordId){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :recordId];
        List<DocumentsField> documentOptions = new List<DocumentsField>();
        if(opp != null){
            List<ContentDocumentLink> document = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :opp.Id];
            if(!document.isEmpty()){
                for (ContentDocumentLink doc : document) {
                    DocumentsField docField = new DocumentsField();
                    docField.name = doc.ContentDocument.Title;
                    docField.createdDate = doc.ContentDocument.CreatedDate.date();
                    docField.id = '/sfc/servlet.shepherd/document/download/' + doc.ContentDocumentId + '?operationContext=S1';
                    documentOptions.add(docField);
                }
            
            }
        }
        return documentOptions;
        
    }


}