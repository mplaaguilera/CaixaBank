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

*/
public with sharing class CIBE_TabListOppComitePreciosCIBContr {

    private static List<String> stages = new List<String>{'En curso', 'CIBE_Pendiente_firma', 'Potencial'};
    
    private static List<String> stagesExportCerr = new List<String>{/*'En curso', 'CIBE_Pendiente_firma',*/ 'CIBE_Cerrado positivo', 'Cerrado negativo'};
    
    private static Set<Id> recordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT)
        });
    private static String createdDate = CIBE_DataMapping__mdt.getInstance('CIBE_CreatedDateOppCIB').CIBE_Value__c;
    private static DateTime fechaActual = System.now();
    private static List<String> partes = createdDate.split(':'); 
    private static Integer mesesAtras = Integer.valueOf(partes[1]); 
    private static DateTime fechaCalculada = fechaActual.addMonths(-mesesAtras);

    @AuraEnabled(cacheable = true) 
    public static List<OpportunityWrapper> getOpportunity(Integer offSet, Date fecha, Date desde, Date hasta) {
        offSet = offSet <= 2000 ? offset : 2000;

        String query = 'SELECT Id, CIBE_Fechaaprobacionprecio__c, OwnerId, Owner.Name, CIBE_Pais__c, AccountId, Account.Name, Account.CC_Numero_Documento__c, '+
                'Account.CIBE_GrupoEconomico__c, CIBE_GrupoComercial__c, CIBE_GrupoComercial__r.Name, Name, ' +
                'Account.CIBE_Rating_PD__c, CIBE_RARSeveridad__c, CIBE_AmountDivisa__c, CIBE_Divisa__c,  ' +
                'CIBE_RARPlazoMeses__c, CIBE_RARPlazoFecha__c, TOLABEL(CIBE_TipoOperacion__c), AV_PF__c, AV_PF__r.Name, ' +
                'CIBE_RARIndiceReferencia__c, CIBE_RARInteresDiferencial__c,  CIBE_RARConjunto__c, ' +
                'CIBE_RAROperacionRar__c, CIBE_RARPost__c, CIBE_ComisionSaldoMedio__c, CIBE_RARComisionApertura__c, ' +
                'CIBE_RARGarantias__c, CIBE_VAOperacion__c, CIBE_RARMargenDiario__c, CIBE_RARComision12meses__c, CloseDate, ' + 
                'CIBE_BalanceDivisa__c, CIBE_ImpactoDivisaComisionesCierreAnio__c, CIBE_ComisionesDivisa__c, CIBE_Impacto_Comisiones_Cierre_Anio__c, ' +
                'AV_ClienteConfidencial__c, CIBE_ECAs__c, CIBE_AlgunaOperRAR__c, CIBE_VigenciaOferta__c, CIBE_DictamenALM__c, ' +
                'CIBE_Visto__c, CIBE_Nivel__c, CIBE_Sindicaciones__c, CIBE_Observaciones__c, CIBE_Linea__c ' +
                'FROM Opportunity ' +
                'WHERE RecordTypeId IN :recordTypes ' + 
                'AND StageName IN :stages ' +
                'AND CreatedDate >= :fechaCalculada';
                
        if(fecha != null){
            query += ' AND CIBE_Fechaaprobacionprecio__c = :fecha';
        }

        if(desde != null){
            query += ' AND CIBE_Fechaaprobacionprecio__c >= :desde';
        }

        if(hasta != null){
            query += ' AND CIBE_Fechaaprobacionprecio__c <= :hasta';
        }

        query += ' ORDER BY CloseDate ASC LIMIT 20 OFFSET :offSet';

        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));

        // Map<Id, HierarchyWrapper> mapHier = getHierarchies();
        Map<Id, List<String>> clienteToGestores = getGestorInternational(listOpp);

        List<OpportunityWrapper> listOppWrapp = new List<OpportunityWrapper>();
        for(Opportunity op: listOpp) {
            OpportunityWrapper oppWrapp = new OpportunityWrapper();
            oppWrapp.iden = String.isNotBlank(op.Id) ? op.Id : '';
            oppWrapp.fechaAprobacionPrecio = op.CIBE_Fechaaprobacionprecio__c;
            oppWrapp.ownerId = String.isNotBlank(op.OwnerId) ? op.OwnerId : null;
            oppWrapp.ownerName = String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '';
            oppWrapp.pais = String.isNotBlank(op.CIBE_Pais__c) ? op.CIBE_Pais__c : '';
            oppWrapp.accountId = String.isNotBlank(op.AccountId) ? op.AccountId : null;
            oppWrapp.accountName = String.isNotBlank(op.Account.Name) ? op.Account.Name : '';
            oppWrapp.accountCif = String.isNotBlank(op.Account.CC_Numero_Documento__c) ? op.Account.CC_Numero_Documento__c : '';
            oppWrapp.grupoEconomico = String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c : '';
            oppWrapp.grupoComercialId = String.isNotBlank(op.CIBE_GrupoComercial__c) ? op.CIBE_GrupoComercial__c : null;
            oppWrapp.grupoComercialName = String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name : '';
            oppWrapp.name = String.isNotBlank(op.Name) ? op.Name : '';
            oppWrapp.rating = String.isNotBlank(op.Account.CIBE_Rating_PD__c) ? op.Account.CIBE_Rating_PD__c : '';
            oppWrapp.RARSeveridad = op.CIBE_RARSeveridad__c != null ? Integer.valueOf(op.CIBE_RARSeveridad__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.amountDivisa = op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
            oppWrapp.divisa = String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '';
            oppWrapp.RARPlazoVidaMediaMeses = op.CIBE_RARPlazoMeses__c != null ? Integer.valueOf(op.CIBE_RARPlazoMeses__c.round(RoundingMode.HALF_UP)).format() : '';
            oppWrapp.RARPlazoVidaMediaFecha = op.CIBE_RARPlazoFecha__c;
            oppWrapp.tipoOperaciones = String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '';
            oppWrapp.pFId = String.isNotBlank(op.AV_PF__c) ? op.AV_PF__c : null;
            oppWrapp.pFName = String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '';
            oppWrapp.RARIndiceReferencia = op.CIBE_RARIndiceReferencia__c != null ? Integer.valueOf(op.CIBE_RARIndiceReferencia__c.round(RoundingMode.HALF_UP)).format() : '';
            oppWrapp.RARInteresDiferencial = op.CIBE_RARInteresDiferencial__c != null ? Integer.valueOf(op.CIBE_RARInteresDiferencial__c.round(RoundingMode.HALF_UP)).format() : '';
            
            oppWrapp.RARConjunto = op.CIBE_RARConjunto__c != null ? op.CIBE_RARConjunto__c.setScale(2, RoundingMode.HALF_UP).format() : '';      
            oppWrapp.RAROperacionRar = op.CIBE_RAROperacionRar__c != null ? op.CIBE_RAROperacionRar__c.setScale(2, RoundingMode.HALF_UP).format() : '';   
            oppWrapp.RARPost = op.CIBE_RARPost__c != null ? op.CIBE_RARPost__c.setScale(2, RoundingMode.HALF_UP).format() : '';
                    oppWrapp.comisionSaldoMedio = op.CIBE_ComisionSaldoMedio__c != null ? Integer.valueOf(op.CIBE_ComisionSaldoMedio__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.RARComisionApertura = op.CIBE_RARComisionApertura__c != null ? Integer.valueOf(op.CIBE_RARComisionApertura__c.round(RoundingMode.HALF_UP)).format() : '';
            oppWrapp.RARGarantias = op.CIBE_RARGarantias__c;
                    oppWrapp.VAOperacion = op.CIBE_VAOperacion__c != null ? Integer.valueOf(op.CIBE_VAOperacion__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.RARMargenDiario = op.CIBE_RARMargenDiario__c != null ? Integer.valueOf(op.CIBE_RARMargenDiario__c.round(RoundingMode.HALF_UP)).format() : '';
            oppWrapp.RARComision12meses = op.CIBE_RARComision12meses__c != null ? Integer.valueOf(op.CIBE_RARComision12meses__c.round(RoundingMode.HALF_UP)).format() : '';
            oppWrapp.closeDate = op.CloseDate;
                    oppWrapp.balanceDivisa = op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.impactoDivisaComisionesCierreAnio = op.CIBE_ImpactoDivisaComisionesCierreAnio__c != null ? Integer.valueOf(op.CIBE_ImpactoDivisaComisionesCierreAnio__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.comisionesDivisa = op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
                    oppWrapp.impactoComisionesCierreAnio = op.CIBE_Impacto_Comisiones_Cierre_Anio__c != null ? Integer.valueOf(op.CIBE_Impacto_Comisiones_Cierre_Anio__c.round(RoundingMode.HALF_UP)).format() : '';
            oppWrapp.confidencial = op.AV_ClienteConfidencial__c; 
            oppWrapp.ecas = op.CIBE_ECAs__c;
            oppWrapp.algunaOperacionRAR = op.CIBE_AlgunaOperRAR__c;
            oppWrapp.vigenciaOferta = String.isNotBlank(op.CIBE_VigenciaOferta__c) ? op.CIBE_VigenciaOferta__c : '';
            oppWrapp.dictamenALM = op.CIBE_DictamenALM__c;
            oppWrapp.visto = String.isNotBlank(op.CIBE_Visto__c) ? op.CIBE_Visto__c : '';
            oppWrapp.nivel = String.isNotBlank(op.CIBE_Nivel__c) ? op.CIBE_Nivel__c : '';
            oppWrapp.sindicaciones = op.CIBE_Sindicaciones__c;
            oppWrapp.observaciones = String.isNotBlank(op.CIBE_Observaciones__c) ? op.CIBE_Observaciones__c : '';
            oppWrapp.linea = op.CIBE_Linea__c; 
            listOppWrapp.add(oppWrapp);
        }
        
        return listOppWrapp;
    }

    @AuraEnabled
    public static List<String> exportOpportunities() {
        String query = 'SELECT Id, CIBE_Fechaaprobacionprecio__c, OwnerId, Owner.Name, CIBE_Pais__c, AccountId, Account.Name, Account.CC_Numero_Documento__c, '+
                'Account.CIBE_GrupoEconomico__c, CIBE_GrupoComercial__c, CIBE_GrupoComercial__r.Name, Name, ' +
                'Account.CIBE_Rating_PD__c, CIBE_RARSeveridad__c, CIBE_AmountDivisa__c, CIBE_Divisa__c, ' +
                'CIBE_RARPlazoMeses__c, CIBE_RARPlazoFecha__c, TOLABEL(CIBE_TipoOperacion__c), AV_PF__c, AV_PF__r.Name, ' +
                'CIBE_RARIndiceReferencia__c, CIBE_RARInteresDiferencial__c, CIBE_RARConjunto__c, ' +
                'CIBE_RAROperacionRar__c, CIBE_RARPost__c, CIBE_ComisionSaldoMedio__c, CIBE_RARComisionApertura__c, ' +
                'CIBE_RARGarantias__c, CIBE_VAOperacion__c, CIBE_RARMargenDiario__c, CIBE_RARComision12meses__c, CloseDate, ' + 
                'CIBE_BalanceDivisa__c, CIBE_ImpactoDivisaComisionesCierreAnio__c, CIBE_ComisionesDivisa__c, CIBE_Impacto_Comisiones_Cierre_Anio__c, ' +
                'AV_ClienteConfidencial__c, CIBE_ECAs__c, CIBE_AlgunaOperRAR__c, CIBE_VigenciaOferta__c, CIBE_DictamenALM__c, ' +
                'CIBE_Visto__c, CIBE_Nivel__c, CIBE_Sindicaciones__c, CIBE_Observaciones__c, CIBE_Linea__c ' +

                'FROM Opportunity ' +
                'WHERE RecordTypeId IN :recordTypes ' + 
                'AND StageName IN :stages ' +
                'AND CreatedDate >= :fechaCalculada';

        List<Opportunity> listOpp = Database.query(String.escapeSingleQuotes(query));

        Map<Id, List<String>> clienteToGestores = getGestorInternational(listOpp);

        List<String> opportunities = new List<String>();
        for(Opportunity op: listOpp) {
            String opp = '';
            opp += (String.isNotBlank(op.Account.Name) ? op.Account.Name.replaceAll(';', '.')  : '') + ';';
            opp += (String.isNotBlank(op.Account.CC_Numero_Documento__c) ? op.Account.CC_Numero_Documento__c : '') + ';';
            opp += (String.isNotBlank(op.Account.CIBE_GrupoEconomico__c) ? op.Account.CIBE_GrupoEconomico__c : '') + ';';
            opp += (String.isNotBlank(op.CIBE_GrupoComercial__r.Name) ? op.CIBE_GrupoComercial__r.Name.replaceAll(';', '.')  : '') + ';';
            opp += (String.isNotBlank(op.name) ? op.name.replaceAll(';', '.')  : '') + ';';
            opp += (op.CIBE_Fechaaprobacionprecio__c != null ? String.valueOf(op.CIBE_Fechaaprobacionprecio__c) : '') + ';';
            opp += (String.isNotBlank(op.Owner.Name) ? op.Owner.Name : '') + ';';
            opp += (String.isNotBlank(op.CIBE_Pais__c) ? op.CIBE_Pais__c : '') + ';';
            opp += (String.isNotBlank(op.Account.CIBE_Rating_PD__c) ? op.Account.CIBE_Rating_PD__c : '') + ';';
            opp += (op.CIBE_RARSeveridad__c != null ? Integer.valueOf(op.CIBE_RARSeveridad__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_AmountDivisa__c != null ? Integer.valueOf(op.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (String.isNotBlank(op.CIBE_Divisa__c) ? op.CIBE_Divisa__c : '') + ';';
            opp += (op.CIBE_RARPlazoMeses__c != null ? Integer.valueOf(op.CIBE_RARPlazoMeses__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_RARPlazoFecha__c != null ? String.valueOf(op.CIBE_RARPlazoFecha__c) : '') + ';';
            opp += (String.isNotBlank(op.CIBE_TipoOperacion__c) ? op.CIBE_TipoOperacion__c : '') + ';';
            opp += (String.isNotBlank(op.AV_PF__r.Name) ? op.AV_PF__r.Name : '') + ';';
            opp += (op.CIBE_RARIndiceReferencia__c != null ? Integer.valueOf(op.CIBE_RARIndiceReferencia__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_RARInteresDiferencial__c != null ? Integer.valueOf(op.CIBE_RARInteresDiferencial__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
                opp += (op.CIBE_RARConjunto__c != null ? op.CIBE_RARConjunto__c.setScale(2, RoundingMode.HALF_UP).format() : '') + ';';
                opp += (op.CIBE_RAROperacionRar__c != null ? op.CIBE_RAROperacionRar__c.setScale(2, RoundingMode.HALF_UP).format() : '') + ';';
                opp += (op.CIBE_RARPost__c != null ? op.CIBE_RARPost__c.setScale(2, RoundingMode.HALF_UP).format() : '') + ';';
            opp += (op.CIBE_ComisionSaldoMedio__c != null ? Integer.valueOf(op.CIBE_ComisionSaldoMedio__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_RARComisionApertura__c != null ? Integer.valueOf(op.CIBE_RARComisionApertura__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_RARGarantias__c != null ? String.valueOf(op.CIBE_RARGarantias__c) : '') + ';';
            opp += (op.CIBE_VAOperacion__c != null ? Integer.valueOf(op.CIBE_VAOperacion__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_RARMargenDiario__c != null ? Integer.valueOf(op.CIBE_RARMargenDiario__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_RARComision12meses__c != null ? Integer.valueOf(op.CIBE_RARComision12meses__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CloseDate != null ? String.valueOf(op.CloseDate) : '') + ';';
            opp += (op.CIBE_BalanceDivisa__c != null ? Integer.valueOf(op.CIBE_BalanceDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_ImpactoDivisaComisionesCierreAnio__c != null ? Integer.valueOf(op.CIBE_ImpactoDivisaComisionesCierreAnio__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_ComisionesDivisa__c != null ? Integer.valueOf(op.CIBE_ComisionesDivisa__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.CIBE_Impacto_Comisiones_Cierre_Anio__c != null ? Integer.valueOf(op.CIBE_Impacto_Comisiones_Cierre_Anio__c.round(RoundingMode.HALF_UP)).format() : '') + ';';
            opp += (op.AV_ClienteConfidencial__c ? 'true' : '') + ';';  
            opp += (op.CIBE_ECAs__c ? 'true' : '') + ';'; 
            opp += (op.CIBE_AlgunaOperRAR__c ? 'true' : '') + ';'; 
            opp += (String.isNotBlank(op.CIBE_VigenciaOferta__c) ? op.CIBE_VigenciaOferta__c : '') + ';';
            opp += (op.CIBE_DictamenALM__c ? 'true' : '') + ';';  
            opp += (String.isNotBlank(op.CIBE_Visto__c) ? op.CIBE_Visto__c : '') + ';';
            opp += (String.isNotBlank(op.CIBE_Nivel__c) ? op.CIBE_Nivel__c : '') + ';'; 
            opp += (op.CIBE_Sindicaciones__c ? 'true' : '') + ';';  
            opp += (String.isNotBlank(op.CIBE_Observaciones__c) ? op.CIBE_Observaciones__c.replaceAll(';', '.')  : '') + ';'; 
            opp += (op.CIBE_Linea__c ? 'true' : '') + ';';  
            opp += '\n';
            opportunities.add(opp);            
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
        @AuraEnabled public boolean dictamenALM {get;set;}
        @AuraEnabled public String visto {get;set;}
        @AuraEnabled public String nivel {get;set;}
        @AuraEnabled public boolean sindicaciones {get;set;}
        @AuraEnabled public String observaciones {get;set;}
        @AuraEnabled public String vigenciaOferta {get;set;}
        @AuraEnabled public Date fechaAprobacionPrecio {get;set;}
        @AuraEnabled public boolean confidencial {get;set;}
        @AuraEnabled public boolean linea {get;set;}
        @AuraEnabled public String pais {get;set;}
        @AuraEnabled public String rating {get;set;}
        @AuraEnabled public String RARSeveridad {get;set;}
        @AuraEnabled public String RARPlazoVidaMediaMeses {get;set;}
        @AuraEnabled public String RARIndiceReferencia {get;set;}
        @AuraEnabled public String RARInteresDiferencial {get;set;}
        @AuraEnabled public Date RARPlazoVidaMediaFecha {get;set;}
        @AuraEnabled public String RARPost {get;set;}
        @AuraEnabled public String comisionSaldoMedio {get;set;}
        @AuraEnabled public String RARComisionApertura {get;set;}
        @AuraEnabled public String RARGarantias {get;set;}
        @AuraEnabled public String impactoDivisaComisionesCierreAnio {get;set;}
        @AuraEnabled public String impactoComisionesCierreAnio {get;set;}
        @AuraEnabled public String RARConjunto {get;set;}
        @AuraEnabled public String RAROperacionRar {get;set;}
        @AuraEnabled public String VAOperacion {get;set;}
        @AuraEnabled public String RARMargenDiario {get;set;}
        @AuraEnabled public String RARComision12meses {get;set;}
	}

}