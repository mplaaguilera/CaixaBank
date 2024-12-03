/**********************************************************************************************************************
Name:	  cibe_GruposComercialesController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "cibe_GruposComerciales"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY       AUTHOR			DATE			Description
1.0			US408904         Jose Maria     20/09/2022		Init Version
1.1			US461300		 Alex Campos	03/11/2022		Ordenacion por cartera y alfabeticamente
1.2			US561277		 Lucía Muñoz	14/04/2023		Optimización quitando el bookIcon y hasPurse
1.3			US561277		 Alex Campos	05/05/2023		Arreglo de bugs casuisticas especiales

***********************************************************************************************************************/
public with sharing class CIBE_GruposComerciales_Controller {
    
    /**
     * Obtiene la lista de clientes del Grupo Gomercial y su matriz
     * @param recordId campo Id del Grupo Comercial
     */
    @AuraEnabled(cacheable=true)
    public static CommercialGroupInfo getClients(String recordId, String application) {
        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        Boolean aux = false;
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.Id.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__Account__c.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__RelatedAccount__c.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.CIBE_Matriz__c.isAccessible()) {
            relations = [SELECT Id,
                                FinServ__Account__c,
                                FinServ__Account__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__c,
                                FinServ__RelatedAccount__r.Id,
                                FinServ__RelatedAccount__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__c,
                                FinServ__RelatedAccount__r.AV_PctRar__c,
                                FinServ__RelatedAccount__r.CIBE_Facturacion__c,
                                FinServ__RelatedAccount__r.AV_AhorroEInversion__c,
                                FinServ__RelatedAccount__r.AV_Rentabilidad__c,
                                FinServ__RelatedAccount__r.CIBE_RARGrupo__c,
                                FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c,
                                FinServ__RelatedAccount__r.CIBE_LEXAprobado__c,
                                FinServ__RelatedAccount__r.AV_Financiacion__c,
                                FinServ__RelatedAccount__r.CIBE_Source__c,
                                CIBE_Matriz__c,
                         		CIBE_GrupoInterlocutor__c
                        FROM FinServ__AccountAccountRelation__c 
                        WHERE   RecordType.DeveloperName = 'CIBE_GrupoComercial' 
                                AND FinServ__Role__r.Name = 'Parent'
                                AND FinServ__RelatedAccount__c != null
                                AND FinServ__Account__c = :recordId
                                AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoComercial'
                                AND AV_ToDelete__c = false];
        }

        List<Id> bookClients = new List<Id>();
        if(application == 'CIBE_MisClientesCIB') {
            bookClients = getBookClients();
        }

        List<String> matriz = new List<String>();
        List<String> clientIds = new List<String>();
        List<Entry> clients = new List<Entry>();
        for(FinServ__AccountAccountRelation__c relation : relations) {
            if(relation.CIBE_Matriz__c) {
                matriz.add(relation.FinServ__RelatedAccount__c);
            }
            clientIds.add(relation.FinServ__RelatedAccount__c);

            Entry e = new Entry();
            e.id = relation.FinServ__RelatedAccount__r.Id;
            e.accountName = relation.FinServ__RelatedAccount__r.Name;
            e.showRecord = '/' + relation.FinServ__RelatedAccount__r.Id;
            if(relation.FinServ__RelatedAccount__r.RecordType.DeveloperName == 'CC_Cliente') {
                e.isGrupo = false;
                e.facturacion = relation.FinServ__RelatedAccount__r.CIBE_Facturacion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.CIBE_Facturacion__c.round(RoundingMode.HALF_UP)).format() : '';
                if(String.isNotBlank(relation.FinServ__RelatedAccount__r.AV_Interlocutor__r.Name)){
                    e.interlocutor = relation.FinServ__RelatedAccount__r.AV_Interlocutor__r.Name;
                    e.interlocutorLink = '/' +  relation.FinServ__RelatedAccount__r.AV_Interlocutor__c;
                }
                
                //e.rol =  relation.CIBE_GrupoInterlocutor__c ? 'Interlocutor':'Miembro';
                if(!relation.CIBE_GrupoInterlocutor__c){
                    e.rol = 'Miembro';
                }else{
                    aux = true;
                    e.rol = 'Interlocutor';
                }
                system.debug('e.interlocutor');
                system.debug(e.interlocutor);
                system.debug('CIBE_GrupoInterlocutor__c');
                system.debug(relation.CIBE_GrupoInterlocutor__c);
                
                e.rar = relation.FinServ__RelatedAccount__r.AV_PctRar__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.AV_PctRar__c) + ' %' : '';
                e.rarGrupo = relation.FinServ__RelatedAccount__r.CIBE_RARGrupo__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_RARGrupo__c) + ' %' : '';
                e.lexDisponible = relation.FinServ__RelatedAccount__r.CIBE_LEXAprobado__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.CIBE_LEXAprobado__c.round(RoundingMode.HALF_UP)).format() : '';
                e.lexFechaVigencia = relation.FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c) : '';
                e.pasivo = relation.FinServ__RelatedAccount__r.AV_AhorroEInversion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_AhorroEInversion__c.round(RoundingMode.HALF_UP)).format() : '';
                e.activo = relation.FinServ__RelatedAccount__r.AV_Financiacion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_Financiacion__c.round(RoundingMode.HALF_UP)).format() : '';
                e.rentabilidad = relation.FinServ__RelatedAccount__r.AV_Rentabilidad__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_Rentabilidad__c.round(RoundingMode.HALF_UP)).format() : '';
                e.source = relation.FinServ__RelatedAccount__r.CIBE_Source__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_Source__c): '';
                if(bookClients.contains(relation.FinServ__RelatedAccount__c)) {
                    e.bookIcon = 'utility:user';
                    e.hasPurse = true;
                }
            } else if(relation.FinServ__RelatedAccount__r.RecordType.DeveloperName == 'CIBE_GrupoComercial') {
                e.isGrupo = true;
                e.hasPurse = false;
                e.children = new List<Entry>();
            } else {
                e.isGrupo = false;
                e.hasPurse = false;
            }
            clients.add(e);
        }
        clients.sort();

        if(clientIds.isEmpty()) {
            throw new IllegalArgumentException('El grupo comercial no tiene ningún cliente.');
        }
        if(!aux){
            for(Entry en: clients){
                en.rol = 'Interlocutor';
            }
        }

        return new CommercialGroupInfo(
            !matriz.isEmpty() ? matriz.iterator().next() : '',
            clientIds,
            clients
        );
    }

    /**
     * Obtiene la estructura shadow del Grupo Economico con los clientes del Grupo Comercial
     * @param recordId campo Id de la matriz del Grupo Gomercial
     * @param tipoGrupo tipo de la estructura del Grupo Economico
     */
    @AuraEnabled(cacheable=true)
    public static List<EconomicGroupEntry> getEconomicGroupList(String recordId, String groupType) {
        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        if(String.isNotBlank(recordId) && FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()) {
            relations = [SELECT Id,
                                FinServ__Account__c,
                                FinServ__Account__r.Name
                        FROM FinServ__AccountAccountRelation__c 
                        WHERE   RecordType.DeveloperName = 'CIBE_GrupoEconomico' 
                                AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoEconomico'
                                AND FinServ__RelatedAccount__c = :recordId
                                AND FinServ__Role__r.Name = 'Parent'
                                AND CIBE_TipoGrupo__c =: groupType
                                AND AV_ToDelete__c = false
                        /**ORDER BY FinServ__RelatedAccount__r.RecordType.DeveloperName ASC*/];
        }

        List<EconomicGroupEntry> entries = new List<EconomicGroupEntry>();
        for(FinServ__AccountAccountRelation__c relation : relations) {
            EconomicGroupEntry ege = new EconomicGroupEntry();
            ege.label = relation.FinServ__Account__r.Name;
            ege.value = relation.FinServ__Account__c;
            entries.add(ege);
        }
        
        if(entries.isEmpty()) {
            EconomicGroupEntry ege = new EconomicGroupEntry();
            ege.label = '';
            ege.value = '';
            entries.add(ege);
            //throw new IllegalArgumentException('La matriz del grupo comercial no pertenece a ningun grupo económico del tipo seleccionado.');
        }

        return entries;
    }

    /**
     * Obtiene la estructura shadow del Grupo Economico con los clientes del Grupo Comercial
     * @param recordId campo Id del Grupo Economico principal
     * @param groupType tipo de la estructura del Grupo Economico
     * @param clientIds lista de los ids de los clientes
     */
    @AuraEnabled(cacheable=true)
    public static CommercialGroupInfo getShadow(String recordId, String groupType, List<String> clientIds, String application, List<Entry> clients) {
        List<Id> bookClients = new List<Id>();
        Boolean aux = false;
        if(application == 'CIBE_MisClientesCIB') {
            bookClients = getBookClients();
        }
        System.debug('mapa: '+clients);
        Map<Id,String> mapRol = new Map<Id,String>();
        if(clients!=null){
            for(Entry cli : clients) {
                mapRol.put(cli.id, cli.rol);
            }
            /*for(String ide : mapRol.keySet()) {
                if(mapRol.get(ide).equals('Interlocutor')){
                    system.debug('@@ide '+ide);
                    system.debug('@@mapRol.get(ide) '+mapRol.get(ide));

                    aux = true;
                    break;
                }
            }*/
        }
        List<Entry> entries = new List<Entry>();
        List<String> expanded = new List<String>();
        if(String.isNotBlank(recordId) && String.isNotBlank(groupType)) {
            entries = getShadowRecursive(recordId, groupType, clientIds, bookClients, new List<Entry>(), expanded, mapRol);
        }

        List<Entry> cleared = new List<Entry>();
        for(Entry e : entries) {
            if(hasClients(e)) {
                /*if(aux || mapRol.containsKey(e.id)){ 
                    system.debug('@@e aux'+e);
                    //e.rol = 'Interlocutor';
                }else */
                if(mapRol!=null && mapRol.containsKey(e.id)){
                    system.debug('@@e NOT aux: '+e);
                    e.rol = mapRol.get(e.id);
                }
                cleared.add(e);
            }
        }
        cleared.sort();


        return new CommercialGroupInfo(
            recordId,
            expanded,
            cleared
        );
    }

    private static boolean hasClients(Entry node) {
        if(node.isGrupo && (node.children == null || node.children.isEmpty())) {
            return false;
        }

        if(!node.isGrupo) {
            return true;
        }

        boolean hasClient = false;
        List<Entry> cleared = new List<Entry>();
        for(Entry e : node.children) {
            if(hasClients(e)) {
                cleared.add(e);
                hasClient = true;
            } else {
                e = null;
            }
        }
        cleared.sort();
        node.children = cleared;
        return hasClient;
    }

    private static List<Entry> getShadowRecursive(String recordId, String groupType, List<String> clientIds, List<Id> bookClients, List<Entry> entries, List<String> expanded, Map<Id,String> mapRol) {
        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        Boolean aux = false;
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()) {
            relations = [SELECT Id,
                                FinServ__RelatedAccount__c,
                                FinServ__RelatedAccount__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__c,
                                FinServ__RelatedAccount__r.AV_PctRar__c,
                                FinServ__RelatedAccount__r.CIBE_Facturacion__c,
                                FinServ__RelatedAccount__r.AV_Rentabilidad__c,
                                FinServ__RelatedAccount__r.CIBE_RARGrupo__c,
                                FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c,
                                FinServ__RelatedAccount__r.CIBE_LEXAprobado__c,
                                FinServ__RelatedAccount__r.AV_AhorroEInversion__c,
                                FinServ__RelatedAccount__r.AV_Financiacion__c
                               /* CIBE_GrupoInterlocutor__c */
                        FROM FinServ__AccountAccountRelation__c 
                        WHERE   RecordType.DeveloperName = 'CIBE_GrupoEconomico'
                                AND FinServ__Account__c = :recordId
                                AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoEconomico'
                                AND (FinServ__RelatedAccount__c IN :clientIds OR FinServ__RelatedAccount__r.RecordType.DeveloperName = 'CIBE_GrupoEconomico')
                                AND FinServ__Role__r.Name = 'Parent'
                                AND CIBE_TipoGrupo__c =: groupType
                                AND AV_ToDelete__c = false];
        }

        for(FinServ__AccountAccountRelation__c relation : relations) {
            Entry e = getEntry(relation, bookClients,mapRol);
            entries.add(e);
            if(relation.FinServ__RelatedAccount__r.RecordType.DeveloperName == 'CIBE_GrupoEconomico') {
                expanded.add(e.id);
                getShadowRecursive(relation.FinServ__RelatedAccount__c, groupType, clientIds, bookClients, e.children, expanded,mapRol);
            }
        }
        entries.sort();
        return entries;
    }

    private static Entry getEntry(FinServ__AccountAccountRelation__c relation, List<Id> bookClients, Map<Id,String> mapRol) {
        Entry e = new Entry();
        e.id = relation.FinServ__RelatedAccount__r.Id;
        e.accountName = relation.FinServ__RelatedAccount__r.Name;
        e.showRecord = '/' + relation.FinServ__RelatedAccount__r.Id;
        if(relation.FinServ__RelatedAccount__r.RecordType.DeveloperName == 'CC_Cliente') {
            e.isGrupo = false;
            e.facturacion = relation.FinServ__RelatedAccount__r.CIBE_Facturacion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.CIBE_Facturacion__c.round(RoundingMode.HALF_UP)).format() : '';
            if(String.isNotBlank(relation.FinServ__RelatedAccount__r.AV_Interlocutor__r.Name)){
                e.interlocutor = relation.FinServ__RelatedAccount__r.AV_Interlocutor__r.Name;
            }
            if(mapRol!=null && mapRol.containsKey(e.id)){
                e.rol =  mapRol.get(e.id);
            }else{e.rol = '';}
            e.rar = relation.FinServ__RelatedAccount__r.AV_PctRar__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.AV_PctRar__c) + ' %' : '';
            e.rarGrupo = relation.FinServ__RelatedAccount__r.CIBE_RARGrupo__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_RARGrupo__c) + ' %' : '';
            e.lexDisponible = relation.FinServ__RelatedAccount__r.CIBE_LEXAprobado__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.CIBE_LEXAprobado__c.round(RoundingMode.HALF_UP)).format() : '';
            e.lexFechaVigencia = relation.FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c != null ? String.valueOf(relation.FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c) : '';
            e.pasivo = relation.FinServ__RelatedAccount__r.AV_AhorroEInversion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_AhorroEInversion__c.round(RoundingMode.HALF_UP)).format() : '';
            e.activo = relation.FinServ__RelatedAccount__r.AV_Financiacion__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_Financiacion__c.round(RoundingMode.HALF_UP)).format() : '';
            e.rentabilidad = relation.FinServ__RelatedAccount__r.AV_Rentabilidad__c != null ? Integer.valueOf(relation.FinServ__RelatedAccount__r.AV_Rentabilidad__c.round(RoundingMode.HALF_UP)).format() : '';
            if(bookClients.contains(relation.FinServ__RelatedAccount__r.Id)) {
                e.bookIcon = 'utility:user';
                e.hasPurse = true;
            }
        } else if(relation.FinServ__RelatedAccount__r.RecordType.DeveloperName == 'CIBE_GrupoEconomico') {
            e.isGrupo = true;
            e.hasPurse = false;
            e.children = new List<Entry>();
        } else {
            e.isGrupo = false;
            e.hasPurse = false;
        }
        return e;
    }
    /**
     * Obtiene la estructura shadow del Grupo Economico con los clientes del Grupo Comercial
     * @param recordId campo Id de un cliente
     */
    @AuraEnabled(cacheable=true)
    public static List<EconomicGroup> getEconomicInfo(String recordId){
        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.Id.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__Account__c.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.CIBE_TipoGrupo__c.isAccessible()) {
            relations = [SELECT Id, 
                                FinServ__Account__c,
                                FinServ__Account__r.Name, 
                                toLabel(CIBE_TipoGrupo__c)
                         FROM FinServ__AccountAccountRelation__c 
                         WHERE  RecordType.DeveloperName = 'CIBE_GrupoEconomico' 
                                AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoEconomico' 
                                AND FinServ__Role__r.Name = 'Parent' 
                                AND FinServ__RelatedAccount__c = :recordId
                                AND AV_ToDelete__c = false];
        }
    
        Map<Id, EconomicGroup> groups = new Map<Id, EconomicGroup>();
        for(FinServ__AccountAccountRelation__c accRelation : relations){
            if(!groups.containsKey(accRelation.FinServ__Account__c)) {
                EconomicGroup grp = new EconomicGroup();
                grp.id = accRelation.FinServ__Account__c;
                grp.name = accRelation.FinServ__Account__r.Name;
                grp.tipos = new List<String>{ accRelation.CIBE_TipoGrupo__c };
                grp.link = '/' + accRelation.FinServ__Account__c;
                groups.put(accRelation.FinServ__Account__c, grp);
            } else {
                groups.get(accRelation.FinServ__Account__c).tipos.add(accRelation.CIBE_TipoGrupo__c);
            }
        }
        return groups.values();
    }

    private static List<Id> getBookClients() {
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Contact.fields.Id.isAccessible()){
            mapContact = new Map<Id, Contact>([SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() AND RecordType.DeveloperName = 'CC_Empleado']);  
        } 
		
        List<AV_BookManagementMember__c> listBookManager = new List<AV_BookManagementMember__c>();
        if(!mapContact.isEmpty() && AV_BookManagementMember__c.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AV_BookManagementMember__c.fields.Id.isAccessible() 
            && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_Cartera__c.isAccessible()){                
            listBookManager = [SELECT Id, AV_Cartera__c FROM AV_BookManagementMember__c WHERE AV_CarteraActiva__c='S' and recordtype.DeveloperName='AV_CarteraGestor' and AV_EmpleadoGestor__c =: mapContact.keySet()];
        }
        
        Set<Id> listCarteraId = new Set<Id>();	
        for(AV_BookManagementMember__c bookManage : listBookManager){
            listCarteraId.add(bookManage.AV_Cartera__c);
        }

        List<AV_BookMember__c> listBookMember = new List<AV_BookMember__c>();
        Set<Id> listClienteId = new Set<Id>();
        if(!listCarteraId.isEmpty() && AV_BookMember__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.AV_BookMember__c.fields.Id.isAccessible()
            && Schema.SObjectType.AV_BookMember__c.fields.AV_Cartera__c.isAccessible()
            && Schema.SObjectType.AV_BookMember__c.fields.AV_Cliente__c.isAccessible()){                
            listBookMember = [SELECT Id, AV_Cartera__c, AV_Cliente__c FROM AV_BookMember__c WHERE AV_Cartera__c =: listCarteraId];
        }

        for(AV_BookMember__c bookMember : listBookMember){
            listClienteId.add(bookMember.AV_Cliente__c);
        }

        return new List<Id>(listClienteId);
    }

    public class Entry implements Comparable {
        @AuraEnabled public Boolean isGrupo {get;set;}
        @AuraEnabled public List<Entry> children {get;set;}
        @AuraEnabled public String showRecord {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String rol {get;set;} //rol
        @AuraEnabled public String interlocutor {get;set;}
        @AuraEnabled public String interlocutorLink {get;set;}
        @AuraEnabled public String rar {get;set;}
        @AuraEnabled public String rarGrupo {get;set;}
        @AuraEnabled public String lexDisponible {get;set;}
        @AuraEnabled public String lexFechaVigencia {get;set;}
        @AuraEnabled public String facturacion{get;set;}
        @AuraEnabled public String pasivo {get;set;}
        @AuraEnabled public String activo {get;set;}
        @AuraEnabled public String rentabilidad {get;set;}
        @AuraEnabled public String bookIcon {get;set;}
        @AuraEnabled public Boolean hasPurse {get;set;}
        @AuraEnabled public String source {get;set;}

        public Entry() {
             this.bookIcon = 'utility:noicon';
             this.hasPurse = false;
        }
        
        public Integer compareTo(Object compareTo) {
            Entry other = (Entry)compareTo;
            
            Integer returnValue = 0;
            if(this.isGrupo && !other.isGrupo) {
                return -1;
            } else if(!this.isGrupo && other.isGrupo) {
                return 1;
            } else {
                if(this.hasPurse && !other.hasPurse) {
                     return -1;
                } else if((this.hasPurse && other.hasPurse) || (!this.hasPurse && !other.hasPurse)) {
                    if (this.accountName > other.accountName) {
                        returnValue = 1;
                    } else if (this.accountName < other.accountName) {
                        returnValue = -1;
                    } else if ((this.accountName == null) && (other.accountName != null)){
                        returnValue = -1;
                    } else if ((this.accountName != null) && (other.accountName == null)){
                        returnValue = 1;
                    }
                } else if(!this.hasPurse && other.hasPurse) {
                    return 1;
                }
            }
            return returnValue;       
        }
    }

    public class EconomicGroupEntry {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }

    public class EconomicGroup {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public List<String> tipos {get;set;}
        @AuraEnabled public String link {get;set;}
    }

    public class CommercialGroupInfo {
        @AuraEnabled public String matrix {get;set;}
        @AuraEnabled public List<String> clientIds {get;set;}
        @AuraEnabled public List<Entry> clients {get;set;}

        public CommercialGroupInfo(String matrix, List<String> clientIds, List<Entry> clients) {
            this.matrix = matrix;
            this.clientIds = clientIds;
            this.clients = clients;
        }
    }

}