/**********************************************************************************************************************
Name:	  CIBE_GruposEconomicos_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Mikel Lezama		28/09/2022		Init version
1.1			App FSC			Alex Campos			24/10/2022	    Corrección getParents recursividad 

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
public class CIBE_GruposEconomicos_Controller {
    
    @AuraEnabled(cacheable=true)
    public static List<Entry> getData(String recordId, String tipoGrupo) {
        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()) {
            relations = [SELECT Id,
                                FinServ__Account__c,
                                FinServ__Account__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__c,
                                FinServ__RelatedAccount__r.Id,
                                FinServ__RelatedAccount__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__r.Name,
                                FinServ__RelatedAccount__r.AV_AhorroEInversion__c,
                                FinServ__RelatedAccount__r.AV_PctRar__c,
                                FinServ__RelatedAccount__r.AV_Rentabilidad__c,  
                                FinServ__RelatedAccount__r.CIBE_Facturacion__c,                                                          
                                FinServ__RelatedAccount__r.AV_EAPGestor__c,
                                FinServ__RelatedAccount__r.AV_EAPGestor__r.Name,
                                FinServ__RelatedAccount__r.CIBE_RARGrupo__c,
                                FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c,
                                FinServ__RelatedAccount__r.CIBE_LEXAprobado__c,
                                FinServ__RelatedAccount__r.AV_Financiacion__c,
                                FinServ__RelatedAccount__r.CIBE_Source__c,
                                FinServ__Role__r.Name
                        FROM FinServ__AccountAccountRelation__c WHERE RecordType.DeveloperName = 'CIBE_GrupoEconomico' AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoEconomico' AND FinServ__Account__c = :recordId AND FinServ__Role__r.Name = 'Parent' AND CIBE_TipoGrupo__c =: tipoGrupo ORDER BY FinServ__RelatedAccount__r.RecordType.DeveloperName ASC];
        }

        List<Entry> entries = new List<Entry>();
        for(FinServ__AccountAccountRelation__c relation : relations) {
            Entry e = new Entry();
            e.id = relation.FinServ__RelatedAccount__r.Id;
            e.accountName = relation.FinServ__RelatedAccount__r.Name;
            e.showRecord = '/' + relation.FinServ__RelatedAccount__r.Id;
            if(relation.FinServ__RelatedAccount__r.RecordType.DeveloperName == 'CC_Cliente') {
                e.pasivo =relation.FinServ__RelatedAccount__r.AV_AhorroEInversion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_AhorroEInversion__c.round(RoundingMode.HALF_UP)).format() : '';
                e.activo = relation.FinServ__RelatedAccount__r.AV_Financiacion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_Financiacion__c.round(RoundingMode.HALF_UP)).format() : '';
                e.facturacion = relation.FinServ__RelatedAccount__r.CIBE_Facturacion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.CIBE_Facturacion__c.round(RoundingMode.HALF_UP)).format() : '';
                e.rar = relation.FinServ__RelatedAccount__r.AV_PctRar__c != null ? relation.FinServ__RelatedAccount__r.AV_PctRar__c + ' %' : '';
                e.rarGrupo = String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_RARGrupo__c)!= null ?  String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_RARGrupo__c) + ' %' : '';
                e.rentabilidad= relation.FinServ__RelatedAccount__r.AV_Rentabilidad__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_Rentabilidad__c).format() : '';
                e.lexDisponible= relation.FinServ__RelatedAccount__r.CIBE_LEXAprobado__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.CIBE_LEXAprobado__c.round(RoundingMode.HALF_UP)).format() : '';
                e.lexFechaViegencia= relation.FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c;
                e.gestorName= relation.FinServ__RelatedAccount__r.AV_EAPGestor__r.Name;
                e.source = relation.FinServ__RelatedAccount__r.CIBE_Source__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_Source__c): '';
                if(relation.FinServ__RelatedAccount__r.AV_EAPGestor__r.Id != null){
                    e.gestorNameLink= '/' + relation.FinServ__RelatedAccount__r.AV_EAPGestor__r.Id;
                }
            } else if(relation.FinServ__RelatedAccount__r.RecordType.DeveloperName == 'CIBE_GrupoEconomico') {
                e.isGrupo = true;
                e.children = new List<Entry>();
            }
            entries.add(e);
        }
        return entries;
    }

   	public static List<List<Breadcrumb>> parents = new List<List<Breadcrumb>>();
    
    @AuraEnabled(cacheable=true)
    public static List<List<Breadcrumb>> getParentsData(String recordId, String tipoGrupo, Integer positionToExpand, List<List<Breadcrumb>> parentStructure) {
        if(parentStructure != null && positionToExpand != null && positionToExpand < parentStructure.size() && parentStructure.get(positionToExpand) != null) {
            parents = parentStructure;
            List<Breadcrumb> selected = parentStructure.remove(positionToExpand);
            Breadcrumb bc = selected.remove(selected.size()-1);
            getParentsRecursively(bc.id, tipoGrupo, selected, true);
        } else {
            parents = new List<List<Breadcrumb>>();
            getParentsRecursively(recordId, tipoGrupo, new List<Breadcrumb>(), true);
        }
        System.debug(parents);
        return parents;
    }
    
    public static List<Breadcrumb> getParentsRecursively(String recordId, String tipoGrupo, List<Breadcrumb> names, boolean skip) {
        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()) {
            relations = [SELECT Id,
                                FinServ__Account__c,
                                FinServ__Account__r.Name,
                                FinServ__Account__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__c,
                                FinServ__RelatedAccount__r.Name
                        FROM FinServ__AccountAccountRelation__c WHERE RecordType.DeveloperName = 'CIBE_GrupoEconomico' AND FinServ__RelatedAccount__c = :recordId AND FinServ__Role__r.Name = 'Parent' AND CIBE_TipoGrupo__c =: tipoGrupo];
        }
        
        List<Breadcrumb> backup = new List<Breadcrumb>(names);
        if(!relations.isEmpty()) {
            if(relations.size() == 1 || skip) {
                for(FinServ__AccountAccountRelation__c relation : relations) {
                    Breadcrumb bc = new Breadcrumb();
                    bc.id = relation.FinServ__Account__c;
                    bc.label = relation.FinServ__Account__r.Name;
                    bc.url = '/' + relation.FinServ__Account__c;
                    bc.more = false;
                    names.add(bc);
                    names = getParentsRecursively(relation.FinServ__Account__c, tipoGrupo, new List<Breadcrumb>(names), false);
                    
                    if(relations.size() > 1) {
                        names = new List<Breadcrumb>(backup);
                    }
                }
            } else {
                Breadcrumb bc = new Breadcrumb();
                bc.id = recordId;
                bc.label = '. . .';
                bc.url = '. . .';
                bc.more = true;
                names.add(bc);
            	parents.add(names);
            }
        }
        
        if(relations.isEmpty()) {
            if(!names.isEmpty()){
            	parents.add(names);
            }
        }
        
        return names;
    }
    
    public class Breadcrumb {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String url {get;set;}
        @AuraEnabled public Boolean more {get;set;}
    }

    public class Entry {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String rar {get;set;}
        @AuraEnabled public String rarGrupo {get;set;}
        @AuraEnabled public String lexDisponible {get;set;}
        @AuraEnabled public Date lexFechaViegencia {get;set;}
        @AuraEnabled public String pasivo {get;set;}
        @AuraEnabled public String activo {get;set;}
        @AuraEnabled public String facturacion{get;set;}
        @AuraEnabled public String rentabilidad {get;set;}
        @AuraEnabled public String gestorName {get;set;}
        @AuraEnabled public String gestorNameLink {get;set;}
        @AuraEnabled public Boolean isGrupo {get;set;}
        @AuraEnabled public List<Entry> children {get;set;}
        @AuraEnabled public String showRecord {get;set;}
        @AuraEnabled public String source {get;set;}
    }

}