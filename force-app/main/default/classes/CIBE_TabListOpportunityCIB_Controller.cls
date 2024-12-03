/**********************************************************************************************************************
 Name:	  CIBE_TabListOpportunityCIB_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componente Cibe_TabListOpportunityCIB
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE		    Description
	1.0			US461563        Luis		    13/03/2023	    Init version
	1.1			US461563        Alex Campos		13/03/2023	    Init version
    1.2         US506957        Ali             03/08/2023      Añadir campo confidencial
    1.3         US682142        ALi             25/07/2023      Añadido el campo Linea
*/
public with sharing class CIBE_TabListOpportunityCIB_Controller {

    private static List<String> stages = new List<String>{'En curso', 'CIBE_Pendiente_firma'};
    private static List<String> stagesExportCerr = new List<String>{/*'En curso', 'CIBE_Pendiente_firma',*/ 'CIBE_Cerrado positivo', 'Cerrado negativo'};

    private static Set<Id> recordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIACIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTACIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONCIB_RT)
        });

    @AuraEnabled(cacheable = true) 
    public static List<OpportunityWrapper> getOpportunity(Integer offSet, Date fecha, Date desde, Date hasta) {
        offSet = offSet <= 2000 ? offset : 2000;
        
        String query = 'SELECT Id, Name, AccountId, Account.Name, Account.CC_Numero_Documento__c, CIBE_GrupoComercial__c, CIBE_GrupoComercial__r.Name, AV_FechaAlta__c, ' +
                'Account.CIBE_GrupoEconomico__c, CIBE_Familia__c, CIBE_Familia__r.Name, AV_PF__c, AV_PF__r.Name, CIBE_AmountDivisa__c, CIBE_Divisa__c, CIBE_AmountEuro__c, CIBE_BalanceDivisa__c, ' +
                'CIBE_ComisionesDivisa__c, CIBE_Balance__c, CIBE_Comisiones__c, TOLABEL(CIBE_TipoOperacion__c), TOLABEL(CIBE_ProbabilidadExito__c), TOLABEL(StageName), TOLABEL(CIBE_CerradoNegativo__c), ' +
                'CloseDate, CIBE_DiasUltimaGestion__c, OwnerId, Owner.Name, AV_EmpleadoAlta__c, AV_EmpleadoAlta__r.Name, CIBE_ESG__c, CIBE_ECAs__c, CIBE_AlgunaOperRAR__c, CIBE_DictamenALM__c, CIBE_Visto__c, ' +
                'CIBE_Nivel__c, CIBE_Sindicaciones__c, CIBE_Observaciones__c, CIBE_VigenciaOferta__c, CIBE_Fechaaprobacionprecio__c, ' +
                'AV_Gestor__c, AV_Gestor__r.Name, Account.AV_EAPGestor__c, Account.AV_EAPGestor__r.Name, CIBE_ApproveDate__c, AV_ClienteConfidencial__c, CIBE_Linea__c ' +
                'FROM Opportunity ' +
                'WHERE RecordTypeId IN :recordTypes ' + 
                'AND StageName IN :stages ' +
                'AND CreatedDate >= LAST_N_MONTHS:24 ';
                

        if(fecha != null){
            query += ' AND CIBE_Fechaaprobacionprecio__c = :fecha';
        }

        if(desde != null){
            query += ' AND CIBE_Fechaaprobacionprecio__c >= :desde';
        }

        if(hasta != null){
            query += ' AND CIBE_Fechaaprobacionprecio__c <= :hasta';
        }

        query += ' ORDER BY CloseDate ASC LIMIT 10 OFFSET :offSet';

        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));

        Map<Id, HierarchyWrapper> mapHier = getHierarchies();
        Map<Id, List<String>> clienteToGestores = getGestorInternational(listOpp);

        List<OpportunityWrapper> listOppWrapp = new List<OpportunityWrapper>();
        for(Opportunity op: listOpp) {
            OpportunityWrapper oppWrapp = new OpportunityWrapper();
            if(mapHier.containsKey(op.AV_Gestor__c)) {
                HierarchyWrapper hw = mapHier.get(op.AV_Gestor__c);
                oppWrapp.negocios = String.join((Iterable<String>)hw.negocios, ', ');
                oppWrapp.centrosCarteras = String.join((Iterable<String>)hw.centrosCarteras, ', ');
                oppWrapp.redesSegmentos = String.join((Iterable<String>)hw.redesSegmentos, ', ');
                oppWrapp.sectoresPaises = String.join((Iterable<String>)hw.sectoresPaises, ', ');
            }
            if(mapHier.containsKey(op.Account.AV_EAPGestor__c)) {
                HierarchyWrapper hw = mapHier.get(op.Account.AV_EAPGestor__c);
                oppWrapp.eapGestorCentroCartera = String.join((Iterable<String>)hw.centrosCarteras, ', ');
            }
            oppWrapp.negocios = String.isNotBlank(oppWrapp.negocios) ? oppWrapp.negocios: '';
            oppWrapp.centrosCarteras = String.isNotBlank(oppWrapp.centrosCarteras) ? oppWrapp.centrosCarteras: '';
            oppWrapp.redesSegmentos = String.isNotBlank(oppWrapp.redesSegmentos) ? oppWrapp.redesSegmentos: '';
            oppWrapp.sectoresPaises = String.isNotBlank(oppWrapp.sectoresPaises) ? oppWrapp.sectoresPaises: '';
            oppWrapp.iden = String.isNotBlank(op.Id) ? op.Id : '';
            oppWrapp.name = String.isNotBlank(op.name) ? op.name : '';
            oppWrapp.accountId = String.isNotBlank(op.AccountId) ? op.AccountId : null;
            oppWrapp.accountName = String.isNotBlank(op.Account.Name) ? op.Account.Name : '';
            oppWrapp.accountCif = String.isNotBlank(op.Account.CC_Numero_Documento__c) ? op.Account.CC_Numero_Documento__c : '';
            oppWrapp.grupoComercialId = String.isNotBlank(op.CIBE_GrupoComercial__c) ? op.CIBE_GrupoComercial__c : null;
            oppWrapp.grupoComercialName = String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name : '';
            oppWrapp.grupoEconomico = String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c : '';
            oppWrapp.familiaId = String.isNotBlank(op.CIBE_Familia__c) ? op.CIBE_Familia__c : null;
            oppWrapp.familiaName = String.isNotBlank(op.CIBE_Familia__r.Name) ? op.CIBE_Familia__r.Name : '';
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
            oppWrapp.probabilidadExito = String.isNotBlank(op.CIBE_ProbabilidadExito__c) ? op.CIBE_ProbabilidadExito__c : '';
            oppWrapp.stageName = String.isNotBlank(op.StageName) ? op.StageName : '';
            oppWrapp.cerradoNegativo = String.isNotBlank(op.CIBE_CerradoNegativo__c) ? op.CIBE_CerradoNegativo__c : '';
            oppWrapp.closeDate = op.CloseDate;
            oppWrapp.diasUltimaGestion = op.CIBE_DiasUltimaGestion__c != null ? String.valueOf(op.CIBE_DiasUltimaGestion__c) : '';
            oppWrapp.ownerId = String.isNotBlank(op.OwnerId) ? op.OwnerId : null;
            oppWrapp.ownerName = String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '';
            oppWrapp.firstOwnerId = String.isNotBlank(op.AV_EmpleadoAlta__c) ? op.AV_EmpleadoAlta__c : null;
            oppWrapp.firstOwnerName = String.isNotBlank(op.AV_EmpleadoAlta__r.Name) ? op.AV_EmpleadoAlta__r.Name : '';
            oppWrapp.esg = op.CIBE_ESG__c;
            oppWrapp.ecas = op.CIBE_ECAs__c;
            oppWrapp.algunOperRar = op.CIBE_AlgunaOperRAR__c;
            oppWrapp.dictamenAlm = op.CIBE_DictamenALM__c;
            oppWrapp.visto = String.isNotBlank(op.CIBE_Visto__c) ? op.CIBE_Visto__c : '';
            oppWrapp.nivel = String.isNotBlank(op.CIBE_Nivel__c) ? op.CIBE_Nivel__c : '';
            oppWrapp.sindicaciones = op.CIBE_Sindicaciones__c;
            oppWrapp.observaciones = String.isNotBlank(op.CIBE_Observaciones__c) ? op.CIBE_Observaciones__c : '';
            oppWrapp.vigenciaOferta = String.isNotBlank(op.CIBE_VigenciaOferta__c) ? op.CIBE_VigenciaOferta__c : '';
            oppWrapp.gestorInternacional = clienteToGestores.containsKey(op.AccountId) ? String.join(clienteToGestores.get(op.AccountId), ', ') : '';
            oppWrapp.fechaComiteRiesgo = op.CIBE_ApproveDate__c;
            oppWrapp.fechaAprobacionPrecio = op.CIBE_Fechaaprobacionprecio__c;
            oppWrapp.avGestor = String.isNotBlank(op.AV_Gestor__c) ? op.AV_Gestor__c : null;
            oppWrapp.avGestorName = String.isNotBlank(op.AV_Gestor__r.Name) ? op.AV_Gestor__r.Name : '';
            oppWrapp.eapGestorName = String.isNotBlank(op.Account.AV_EAPGestor__r.Name) ? op.Account.AV_EAPGestor__r.Name : ''; 
            oppWrapp.fechaAlta = op.AV_FechaAlta__c;
            oppWrapp.confidencial = op.AV_ClienteConfidencial__c; 
            oppWrapp.linea = op.CIBE_Linea__c; 
            listOppWrapp.add(oppWrapp);
        }
        
        return listOppWrapp;
    }

    @AuraEnabled
    public static List<String> exportOpportunities() {
        String fechaMdt = CIBE_TranslateConfiguration__mdt.getInstance('CIBE_FechaQueryListado').CIBE_Value__c; 
        Date fechaTrad = Date.valueOf(fechaMdt);
        String query = 'SELECT Id, Name, AccountId, Account.Name, Account.CC_Numero_Documento__c, CIBE_GrupoComercial__c, CIBE_GrupoComercial__r.Name, AV_FechaAlta__c, ' +
                'Account.CIBE_GrupoEconomico__c, AV_PF__c, CIBE_Familia__c, CIBE_Familia__r.Name, AV_PF__r.Name, CIBE_AmountDivisa__c, CIBE_Divisa__c, CIBE_AmountEuro__c, CIBE_BalanceDivisa__c, ' +
                'CIBE_ComisionesDivisa__c, CIBE_Balance__c, CIBE_Comisiones__c, TOLABEL(CIBE_TipoOperacion__c), TOLABEL(CIBE_ProbabilidadExito__c), TOLABEL(StageName), TOLABEL(CIBE_CerradoNegativo__c), ' +
                'CloseDate, CIBE_DiasUltimaGestion__c, OwnerId, Owner.Name, AV_EmpleadoAlta__c, AV_EmpleadoAlta__r.Name, CIBE_ESG__c, CIBE_ECAs__c, CIBE_AlgunaOperRAR__c, CIBE_DictamenALM__c, CIBE_Visto__c, ' +
                'CIBE_Nivel__c, CIBE_Sindicaciones__c, CIBE_Observaciones__c, CIBE_VigenciaOferta__c, CIBE_Fechaaprobacionprecio__c, ' +
                'AV_Gestor__c, AV_Gestor__r.Name, Account.AV_EAPGestor__c, Account.AV_EAPGestor__r.Name, CIBE_ApproveDate__c, AV_ClienteConfidencial__c, CIBE_Linea__c ' +
                'FROM Opportunity ' +
                'WHERE RecordTypeId IN :recordTypes ' + 
                'AND ((StageName IN :stages )' +
                'OR (StageName IN :stagesExportCerr AND AV_ExternalID__c = null AND CloseDate >= :fechaTrad))'+
                'ORDER BY CloseDate ASC';

        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));

        Map<Id, HierarchyWrapper> mapHier = getHierarchies();
        Map<Id, List<String>> clienteToGestores = getGestorInternational(listOpp);

        List<String> opportunities = new List<String>();
        for(Opportunity op: listOpp) {
            String opp = '';
            opp += (String.isNotBlank(op.Account.Name) ? op.Account.Name.replaceAll(';', '.')  : '') + ';';
            opp += (String.isNotBlank(op.Account.CC_Numero_Documento__c) ? op.Account.CC_Numero_Documento__c : '') + ';';
            opp += (String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c : '') + ';';
            opp += (String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name.replaceAll(';', '.')  : '') + ';';
            opp += (String.isNotBlank(op.name) ? op.name.replaceAll(';', '.')  : '') + ';';
            opp += (String.isNotBlank(op.CIBE_Familia__r.Name) ? op.CIBE_Familia__r.Name : '') + ';';
            opp += (String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '') + ';';
            opp += (op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '') + ';';
            opp += (op.CIBE_AmountEuro__c != null ? Integer.valueOf(op.CIBE_AmountEuro__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_Balance__c != null ? Integer.valueOf(op.CIBE_Balance__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_Comisiones__c != null ? Integer.valueOf(op.CIBE_Comisiones__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '') + ';';
            opp += (String.isNotBlank(op.CIBE_ProbabilidadExito__c) ? op.CIBE_ProbabilidadExito__c : '') + ';';
            opp += (String.isNotBlank(op.StageName) ? op.StageName : '') + ';';
            opp += (String.isNotBlank(op.CIBE_CerradoNegativo__c) ? op.CIBE_CerradoNegativo__c : '') + ';';
            opp += (op.CloseDate != null ? String.valueOf(op.CloseDate) : '') + ';';
            opp += (op.CIBE_DiasUltimaGestion__c != null ? String.valueOf(op.CIBE_DiasUltimaGestion__c) : '') + ';';
            opp += (op.AV_FechaAlta__c != null ? String.valueOf(op.AV_FechaAlta__c) : '') + ';';
            opp += (String.isNotBlank(op.AV_EmpleadoAlta__r.Name) ? op.AV_EmpleadoAlta__r.Name : '') + ';';
            opp += (String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '') + ';';

            if(mapHier.containsKey(op.AV_Gestor__c)) {
                HierarchyWrapper hw = mapHier.get(op.AV_Gestor__c);
                opp += (String.join((Iterable<String>)hw.centrosCarteras, ', ')) + ';'; 
                opp += (String.join((Iterable<String>)hw.sectoresPaises, ', ')) + ';'; 
                opp += (String.join((Iterable<String>)hw.redesSegmentos, ', ')) + ';';
                opp += (String.join((Iterable<String>)hw.negocios, ', ')) + ';'; 
            } else {
                opp += ';;;;';
            }

            opp += (String.isNotBlank(op.Account.AV_EAPGestor__r.Name) ? op.Account.AV_EAPGestor__r.Name : '') + ';'; 

            if(mapHier.containsKey(op.Account.AV_EAPGestor__c)) {
                HierarchyWrapper hw = mapHier.get(op.Account.AV_EAPGestor__c);
                opp += (String.join((Iterable<String>) hw.centrosCarteras, ', ')) + ';';
            } else {
                opp += ';';
            }

            opp += clienteToGestores.containsKey(op.AccountId) ? String.join(clienteToGestores.get(op.AccountId), ', ') +';' : ';';
            opp += (op.CIBE_ApproveDate__c != null ? String.valueOf(op.CIBE_ApproveDate__c) : '') + ';';
            opp += (op.CIBE_Fechaaprobacionprecio__c != null ? String.valueOf(op.CIBE_Fechaaprobacionprecio__c) : '') + ';';
            opp += (op.CIBE_ESG__c ? 'true' : '') + ';';
            opp += (op.CIBE_ECAs__c ? 'true' : '') + ';'; 
            opp += (op.CIBE_AlgunaOperRAR__c ? 'true' : '') + ';'; 
            opp += (op.CIBE_DictamenALM__c ? 'true' : '') + ';';  
            opp += (String.isNotBlank(op.CIBE_Visto__c) ? op.CIBE_Visto__c : '') + ';';
            opp += (String.isNotBlank(op.CIBE_Nivel__c) ? op.CIBE_Nivel__c : '') + ';'; 
            opp += (op.CIBE_Sindicaciones__c ? 'true' : '') + ';';  
            opp += (String.isNotBlank(op.CIBE_Observaciones__c) ? op.CIBE_Observaciones__c.replaceAll(';', '.')  : '') + ';'; 
            opp += (String.isNotBlank(op.CIBE_VigenciaOferta__c) ? op.CIBE_VigenciaOferta__c : '') + ';';
            opp += (op.AV_ClienteConfidencial__c ? 'true' : '') + ';';  
            opp += (op.CIBE_Linea__c ? 'true' : '') + ';';  
            opp += '\n';
            opportunities.add(opp);
        }
        return opportunities;
    }

    private static Map<Id, HierarchyWrapper> getHierarchies() {
        Map<Id, HierarchyWrapper> mapHier = new Map<Id, HierarchyWrapper>();
        if(CIBE_hierarchy__c.SObjectType.getDescribe().isAccessible()) {
            for(CIBE_Hierarchy__c hier :    [SELECT CIBE_Contact__c, 
                                                    CIBE_Contact__r.Name, 
                                                    CIBE_Negocios__r.Name, 
                                                    CIBE_CentrosCarteras__r.Name,
                                                    CIBE_RedesSegmentos__r.Name, 
                                                    CIBE_SectoresPaises__r.Name 
                                            FROM CIBE_hierarchy__c 
                                            WHERE   CIBE_Contact__c != null 
                                                    AND CIBE_Negocios__c != null 
                                                    AND Recordtype.Developername = 'CIBE_Employee']) {
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
        return mapHier;
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
        @AuraEnabled public String familiaId {get;set;}
        @AuraEnabled public String familiaName {get;set;}
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
        @AuraEnabled public String probabilidadExito {get;set;}
        @AuraEnabled public String stageName {get;set;}
        @AuraEnabled public String cerradoNegativo {get;set;}
        @AuraEnabled public Date closeDate {get;set;}
        @AuraEnabled public String diasUltimaGestion {get;set;}
        @AuraEnabled public String ownerId {get;set;}
        @AuraEnabled public String ownerName {get;set;}
        @AuraEnabled public String firstOwnerId {get;set;}
        @AuraEnabled public String firstOwnerName {get;set;}
        @AuraEnabled public boolean esg {get;set;}
        @AuraEnabled public boolean ecas {get;set;}
        @AuraEnabled public boolean algunOperRar {get;set;}
        @AuraEnabled public boolean dictamenAlm {get;set;}
        @AuraEnabled public String visto {get;set;}
        @AuraEnabled public String nivel {get;set;}
        @AuraEnabled public boolean sindicaciones {get;set;}
        @AuraEnabled public String observaciones {get;set;}
        @AuraEnabled public String vigenciaOferta {get;set;}
        @AuraEnabled public String gestorInternacional {get;set;}
        @AuraEnabled public Date fechaComiteRiesgo {get;set;}
        @AuraEnabled public Date fechaAprobacionPrecio {get;set;}
        @AuraEnabled public String avGestor {get;set;}
        @AuraEnabled public String avGestorName {get;set;}
        @AuraEnabled public String eapGestorName {get;set;}
        @AuraEnabled public String eapGestorCentroCartera {get;set;}
        @AuraEnabled public Date fechaAlta {get;set;}
        @AuraEnabled public boolean confidencial {get;set;}
        @AuraEnabled public boolean linea {get;set;}
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
}