/**********************************************************************************************************************
 Name:	EV_TraduccionEventosTriggerHelper
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar del trigger de Traduccion de Evento
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Mamen Arias 		28/11/2022			Init version
	1.1			US585725			Daniel Rodriguez	31/08/2023			Remove for duplicate

***********************************************************************************************************************/
public with sharing class EV_TraduccionDeEventoTriggerHelper {

	public static void checkDuplicado(List<EV_TraduccionDeEvento__c> listNews, Map<Id, EV_TraduccionDeEvento__c> mapOlds) {
        EV_LogDebug.printLogDebug('checkDuplicado ',String.valueof(listNews) + ' '+ String.valueof(mapOlds));
		Set<Id> campaignIds = new Set<Id>();
		Map<String,List<String>> traduIdiomaOld = new Map<String,List<String>>();
		Map<String,List<String>> traduIdiomaNew = new Map<String,List<String>>();

        //Guardamos Ids de las campañas
        for (EV_TraduccionDeEvento__c newTrad : listNews){
            campaignIds.add(newTrad.EV_Evento__c);
            if(!traduIdiomaNew.containsKey(newTrad.EV_Evento__c)){
                traduIdiomaNew.put(newTrad.EV_Evento__c,new List<String>{newTrad.EV_Idioma__c});
            }else{
                if (traduIdiomaNew.get(newTrad.EV_Evento__c).contains(newTrad.EV_Idioma__c)){
                    newTrad.addError('Ya existe una traducción con ese idioma. Es necesario eliminar la anterior para crear una nueva.');
                } else {
                    traduIdiomaNew.get(newTrad.EV_Evento__c).add(newTrad.EV_Idioma__c);
                }
            }
        }

		//Buscamos las traducciones de las campañas y las asignamos al mapa
		for (List<EV_TraduccionDeEvento__c> traducciones : [SELECT Id, EV_Idioma__c, EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Evento__c IN :campaignIds]){
			for (EV_TraduccionDeEvento__c oldT : traducciones){
					if(!traduIdiomaOld.containsKey(oldT.EV_Evento__c)){
						traduIdiomaOld.put(oldT.EV_Evento__c,new List<String>{oldT.EV_Idioma__c});
					}else{
						if (traduIdiomaOld.get(oldT.EV_Evento__c).contains(oldT.EV_Idioma__c)){
							oldT.addError('Ya existe una traducción con ese idioma. Es necesario eliminar la anterior para crear una nueva.');
						} else {
							traduIdiomaOld.get(oldT.EV_Evento__c).add(oldT.EV_Idioma__c);
						}
					}
			}
		}

		//Comparamos que el idioma no exista y si estamos modificando este campo o no en un update
		for (EV_TraduccionDeEvento__c t : listNews){
				List<String> traduccion = traduIdiomaOld.get(t.EV_Evento__c);
				if (traduccion != null){
					for(String tr : traduccion){
						if (mapOlds != null && t.EV_Idioma__c == tr && mapOlds.get(t.Id).EV_Idioma__c != t.EV_Idioma__c){
								t.addError('Ya existe una traducción con ese idioma. Es necesario eliminar la anterior para crear una nueva.');
						} else if(mapOlds == null && t.EV_Idioma__c == tr) {
								t.addError('Ya existe una traducción con ese idioma. Es necesario eliminar la anterior para crear una nueva.');
						}
					}
				}
		}
	}
}