/**********************************************************************************************************************
 Name:	  CIBE_HierachyTriggerHelper
 Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de CIBE_Hierarchy__c para CIBE
------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US717285		Luis Martinez		26/10/2023			Init version Opp 
------------------------------------------------------------------------------------------------
***********************************************************************************************************************/
public with sharing class CIBE_HierachyTriggerHelper {
    
        /**
         * @description		 	Check the record types
         * @param listNews  	list of new records
         */
        public static List<CIBE_Hierarchy__c> checkGeneralRT(List<CIBE_Hierarchy__c> listNews){
            List<CIBE_Hierarchy__c> listData = new List<CIBE_Hierarchy__c>();
            Id hierEmplRT = Schema.SObjectType.CIBE_Hierarchy__c.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT).getRecordTypeId();
            Set<Id> setRtCliente 	= new Set<Id>{hierEmplRT};

            for(CIBE_Hierarchy__c dataNew : listNews){
                if((setRtCliente).contains(dataNew.RecordTypeId)){
                    listData.add(dataNew);
                }
            }
            return listData;
        }

	/**
	 * @description     Updates the customer's related user business
	 * @param listNews  list of new account records
	 */

    public static void insertBusinessUser(List<CIBE_Hierarchy__c> listNews) {
        Set<Id> setIdCont = new Set<Id>();
        List<Contact> listCont = new List<Contact>();
        List<User> listUser = new List<User>();
        Map<Id, String> mapHier = new Map<Id, String>();
        List<String> lstValueNeg = CIBE_DataMapping__mdt.getInstance('CIBE_NegocioUs').CIBE_Value__c.split(',');
        List<CIBE_Hierarchy__c> listHierUp = checkAllBussines(listNews);

        if(!listHierUp.isEmpty() && User.sObjectType.getDescribe().isUpdateable()){
            for(CIBE_Hierarchy__c hier :listHierUp) {
                system.debug('hier: '+hier);
                if(!mapHier.containsKey(hier.CIBE_Contact__r.AV_UsuarioAsociado__c) && String.isNotBlank(hier.CIBE_Negocios__r.Name)) {
                    if(lstValueNeg.Contains(hier.CIBE_Negocios__r.Name)){
                        mapHier.put(hier.CIBE_Contact__r.AV_UsuarioAsociado__c, CIBE_AppConstants.NEGOCIO_RESTRINGIDO);
                    }else{
                        mapHier.put(hier.CIBE_Contact__r.AV_UsuarioAsociado__c, CIBE_AppConstants.NEGOCIO_TOTAL);
                    }
                } else if(String.isNotBlank(hier.CIBE_Negocios__r.Name)) {
                    if(lstValueNeg.Contains(hier.CIBE_Negocios__r.Name) && mapHier.get(hier.CIBE_Contact__r.AV_UsuarioAsociado__c).equalsIgnoreCase(CIBE_AppConstants.NEGOCIO_TOTAL)){
                        mapHier.put(hier.CIBE_Contact__r.AV_UsuarioAsociado__c,CIBE_AppConstants.NEGOCIO_RESTRINGIDO);
                    }           
                }
            }
            
            for(Id us : mapHier.KeySet()){
                system.debug('us: '+us);
                User usuario = new User();
                usuario.Id = us;
                usuario.CIBE_Negocio__c = mapHier.get(us);
                listUser.add(usuario);
            }
            system.debug('listUser: '+listUser);
            Database.Update(listUser,false);
        }

    }

    /**
	 * @description     Updates the customer's related user business on delete
	 * @param listNews  list of new account records
	 */

    public static void deleteBusinessUser(List<CIBE_Hierarchy__c> listNews) {
        system.debug('ENTRA Metodo upsertBusinessUser');
        Set<Id> setIdUsRes = new Set<Id>();
        Set<Id> setIdUsTotal = new Set<Id>();

        List<User> listUser = new List<User>();
        Map<Id, CIBE_Hierarchy__c> mapUser = new Map<Id, CIBE_Hierarchy__c>();
        List<String> lstValueNeg = CIBE_DataMapping__mdt.getInstance('CIBE_NegocioUs').CIBE_Value__c.split(',');
        Map<Id, String> mapHierFin = new Map<Id, String>();

        if(!listNews.isEmpty() && User.sObjectType.getDescribe().isUpdateable()){                                   
            List<CIBE_Hierarchy__c> listContinuan = [SELECT Id, CIBE_Contact__r.AV_UsuarioAsociado__c, CIBE_Negocios__r.Name
                                                    FROM CIBE_Hierarchy__c 
                                                    WHERE CIBE_Contact__c =: listNews[0].CIBE_Contact__c
                                                    AND Id !=: listNews[0].Id];
            system.debug('Mapa Actualizar: '+mapUser);

            if(!listContinuan.isEmpty()){
                for(CIBE_Hierarchy__c hierC :listContinuan) {
                    if(lstValueNeg.Contains(hierC.CIBE_Negocios__r.Name)){
                        setIdUsRes.add(hierC.CIBE_Contact__r.AV_UsuarioAsociado__c);
                    }
                    setIdUsTotal.add(hierC.CIBE_Contact__r.AV_UsuarioAsociado__c);
                }
                for(Id us : setIdUsTotal){
                    User usuario = new User();
                    usuario.Id = us;
                    if(setIdUsRes.Contains(us)){
                        usuario.CIBE_Negocio__c = CIBE_AppConstants.NEGOCIO_RESTRINGIDO;
                    }else{
                        usuario.CIBE_Negocio__c = CIBE_AppConstants.NEGOCIO_TOTAL;
                    }
                    listUser.add(usuario);
                }
            }else{
                List<CIBE_Hierarchy__c> listVacio = [SELECT Id, CIBE_Contact__r.AV_UsuarioAsociado__c FROM CIBE_Hierarchy__c  WHERE Id =: listNews[0].Id];
                User usuario = new User();
                usuario.Id = listVacio[0].CIBE_Contact__r.AV_UsuarioAsociado__c;
                usuario.CIBE_Negocio__c = '';
                listUser.add(usuario);
            }

            Database.Update(listUser,false);
        }
    }

        /**
         * @description		 	Check the record types
         * @param listNews  	list of new records
         */
        public static List<CIBE_Hierarchy__c> checkAllBussines(List<CIBE_Hierarchy__c> listNews){
            List<CIBE_Hierarchy__c> listReturn = new List<CIBE_Hierarchy__c>();
            Set<Id> setIdCont = new Set<Id>();
            List<Contact> listCont = new List<Contact>();

            for(CIBE_Hierarchy__c hi: listNews){
                system.debug('hi: '+hi);
                if(hi.CIBE_Contact__c!=null){
                    setIdCont.add(hi.CIBE_Contact__c);
                }
            }
            system.debug('setIdCont: '+setIdCont);
    
            if(!setIdCont.isEmpty()){
                listCont = [SELECT id, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.CIBE_Negocio__c FROM Contact WHERE id IN:setIdCont];
            }
    
            listReturn = [SELECT id, CIBE_Contact__c, CIBE_Contact__r.AV_UsuarioAsociado__c, CIBE_Negocios__r.Name
                                                    FROM CIBE_Hierarchy__c WHERE Id IN:listNews OR CIBE_Contact__c IN :listCont];
            system.debug('Lista Actualizar: '+listReturn);
            return listReturn;
        }

}