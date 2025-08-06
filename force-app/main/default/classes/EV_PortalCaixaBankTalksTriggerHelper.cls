/**********************************************************************************************************************
 Name:  EV_PortalCaixaBankTalksTriggerHelper
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Trigger Helper del objeto EV_PortalCaixaBankTalks__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION	USER_STORY		AUTHOR				DATE			Description
  1.0		US633077		Mamen Arias			06/09/2023		Init version
  1.1		US854993		Carolina Lopez		10/04/2024		Add method transferDateVisibility.
***********************************************************************************************************************/
public without sharing class EV_PortalCaixaBankTalksTriggerHelper {
	/**
	* @description  update portal visibility with related event information
	* @param listNews    List to EV_PortalCaixaBankTalks__c
	*/
	public static void transferDateVisibility(List<EV_PortalCaixaBankTalks__c> listNews){
		EV_LogDebug.printLogDebug('transferDateVisibility ',String.valueof(listNews));
		List<EV_PortalCaixaBankTalks__c> listPortal = new List<EV_PortalCaixaBankTalks__c>();
    	List<EV_PortalCaixaBankTalks__c> listPortalToUpdate = new List<EV_PortalCaixaBankTalks__c>();

		if(Schema.sObjectType.EV_PortalCaixaBankTalks__c.isAccessible()){
			listPortal = [SELECT Id, Name, EV_Evento__c, EV_Evento__r.EV_Fechadespublicacion__c, EV_Orden__c, EV_Posicionamiento__c, EV_Fechadespublicacion__c 
				FROM EV_PortalCaixaBankTalks__c WHERE id IN:listNews AND EV_Posicionamiento__c != '008' AND EV_Evento__r.EV_Fechadespublicacion__c!= null];
		}
		if(!listPortal.isEmpty()){
			for(EV_PortalCaixaBankTalks__c ptl : listPortal){
				ptl.EV_Fechadespublicacion__c = ptl.EV_Evento__r.EV_Fechadespublicacion__c;
				listPortalToUpdate.add(ptl);
			}
			EV_LogDebug.printLogDebug('@@listPortalToUpdate ',String.valueof(listPortalToUpdate));
			if(!listPortalToUpdate.isEmpty()){
				Database.SaveResult[] updateResults = Database.update(listPortalToUpdate, false);
                for(Database.SaveResult result : updateResults){
                    if(!result.isSuccess()){
                        for(Database.Error error : result.getErrors()){
                            EV_LogDebug.printLogDebug('@@Error al actualizar ',String.valueof(error.getMessage()));
                        }
                    }
                }
			}
		}
	}

	public static void checkExist(List<EV_PortalCaixaBankTalks__c> listNews){

		Map<String,EV_PortalCaixaBankTalks__c> oldDestacado = new Map<String,EV_PortalCaixaBankTalks__c>();
		Map<Id,EV_PortalCaixaBankTalks__c> allDestacado = new Map<Id,EV_PortalCaixaBankTalks__c>();
		Map<Id,EV_PortalCaixaBankTalks__c> allUltimos = new Map<Id,EV_PortalCaixaBankTalks__c>();
		Map<String,EV_PortalCaixaBankTalks__c> oldUltimos = new Map<String,EV_PortalCaixaBankTalks__c>();
		List<EV_PortalCaixaBankTalks__c> oldPortalDelete = new List<EV_PortalCaixaBankTalks__c>();

		for(List<EV_PortalCaixaBankTalks__c>  portalD : [SELECT Id, EV_Posicionamiento__c, EV_Evento__c , EV_Orden__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c = '001' AND EV_Orden__c != null ORDER BY Ev_Orden__c ASC]){
			for(EV_PortalCaixaBankTalks__c porD : portalD){
				if(oldDestacado != null){
					oldDestacado.put(porD.EV_Orden__c, porD);
					allDestacado.put(porD.EV_Evento__c, porD);
				}
			}
		}
		
		//se añade la condicion de que el orden no sea null porque si no peta con nullpointer.
		for(List<EV_PortalCaixaBankTalks__c>  portalU : [SELECT Id, EV_Posicionamiento__c, EV_Evento__c, EV_Orden__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c = '004' AND EV_Orden__c != null ORDER BY Ev_Orden__c ASC]){
			for(EV_PortalCaixaBankTalks__c porU : portalU){
				if(oldUltimos != null){
					oldUltimos.put(porU.EV_Orden__c, porU);
					allUltimos.put(porU.EV_Evento__c, porU);
				}
			}
		}
		
		for(EV_PortalCaixaBankTalks__c portalnew : listNews){
			EV_LogDebug.printLogDebug('@@portalnew ', String.valueOf(portalnew));
			
			if (portalnew.EV_Orden__c == null && portalnew.EV_Posicionamiento__c == '001'){ //se añade este if para que no pete al intentar introducir un registro de portal con este campo a null
				portalNew.addError('Debe seleccionar un valor para el campo Orden.');
			} else if(portalnew.EV_Posicionamiento__c == '001' && integer.valueof(portalnew.EV_Orden__c) == 10){
				EV_PortalCaixaBankTalks__c oldPortal = oldDestacado.get(portalnew.EV_Orden__c);
				if(oldPortal != null && oldPortal.EV_Orden__c == '10'){
					oldPortalDelete.add(oldPortal);
				} 
			}
			
			if (portalnew.EV_Orden__c == null && portalnew.EV_Posicionamiento__c == '004'){ //se añade este if para que no pete al intentar introducir un registro de portal con este campo a null
				portalNew.addError('Debe seleccionar un valor para el campo Orden.');
				
			} else if(portalnew.EV_Posicionamiento__c == '004' && integer.valueof(portalnew.EV_Orden__c) == 10){
				EV_PortalCaixaBankTalks__c oldPortal = oldUltimos.get(portalnew.EV_Orden__c);
				if(oldPortal != null && integer.valueof(oldPortal.EV_Orden__c) == 10){
					oldPortalDelete.add(oldPortal);
				} 
			}
			EV_LogDebug.printLogDebug('@@size Delete ', String.valueOf(oldPortalDelete.size()));
			EV_LogDebug.printLogDebug('oldPortalDelete ', String.valueOf(oldPortalDelete));

			//DESTACADO HOME
			if(portalnew.EV_Posicionamiento__c == '001' && oldPortalDelete.size() <= 0){
				EV_PortalCaixaBankTalks__c oldPortal = allDestacado.get(portalnew.EV_evento__c);
				EV_PortalCaixaBankTalks__c oldPortalExist = oldDestacado.get(portalnew.EV_Orden__c);
				EV_LogDebug.printLogDebug('@@oldPortal ', String.valueOf(oldPortal));

				//Comprobamos duplicidad
				if(oldPortal != null && oldPortal.EV_Posicionamiento__c == '001'){
					portalNew.addError('Ya existe un objeto portal "Destacado home" en el evento');
				}else if(oldPortalExist != null){
					for(EV_PortalCaixaBankTalks__c oPortal : oldDestacado.values()){
						EV_LogDebug.printLogDebug('@@oPortal values ', String.valueOf(oPortal));
						Integer orden = null;
						orden = integer.valueof(oPortal.EV_Orden__c);
						if(integer.valueof(oPortal.EV_Orden__c) < 10 && integer.valueof(oPortal.EV_Orden__c) >= integer.valueof(portalnew.EV_Orden__c) ){
							EV_LogDebug.printLogDebug('@@oPortal.EV_Orden__c ', String.valueOf(oPortal.EV_Orden__c));
							orden = integer.valueof(oPortal.EV_Orden__c) +1;
							oPortal.EV_Orden__c = String.valueOf(orden);
						}else if(integer.valueof(oPortal.EV_Orden__c) >= 10){
							EV_LogDebug.printLogDebug('@@entro en remove ', String.valueOf(oPortal.EV_Evento__c));
							oldPortalDelete.add(oldDestacado.remove(oPortal.EV_Orden__c));
							EV_LogDebug.printLogDebug('@@remove ', String.valueOf(oldPortalDelete));
						}
					}
				}
			}
			
			
			//ULTIMOS AÑADIDOS
			if(portalnew.EV_Posicionamiento__c == '004' && oldPortalDelete.size() <= 0){
				EV_PortalCaixaBankTalks__c oldPortal = allUltimos.get(portalnew.EV_evento__c);
				EV_PortalCaixaBankTalks__c oldPortalExist = oldUltimos.get(portalnew.EV_Orden__c);
				EV_LogDebug.printLogDebug('@@oldPortal Ultimo añadido ', String.valueOf(oldPortal));

				//Comprobamos duplicidad
				if(oldPortal != null && oldPortal.EV_Posicionamiento__c == '004'){
					portalNew.addError('Ya existe un objeto portal "Ultimos añadidos" en el evento');
				}else if(oldPortalExist != null){
					for(EV_PortalCaixaBankTalks__c oPortal : oldUltimos.values()){
						EV_LogDebug.printLogDebug('@@oPortal values ', String.valueOf(oPortal));
						Integer orden = null;
						orden = integer.valueof(oPortal.EV_Orden__c);
						if(integer.valueof(oPortal.EV_Orden__c) < 10 && integer.valueof(oPortal.EV_Orden__c) >= integer.valueof(portalnew.EV_Orden__c) ){
							EV_LogDebug.printLogDebug('@@oPortal.EV_Orden__c ', String.valueOf(oPortal.EV_Orden__c));
							orden = integer.valueof(oPortal.EV_Orden__c) +1;
							oPortal.EV_Orden__c = String.valueOf(orden);
						}else if(integer.valueof(oPortal.EV_Orden__c) >= 10){
							EV_LogDebug.printLogDebug('@@entro en remove ', String.valueOf(oPortal.EV_Evento__c));
							oldPortalDelete.add(oldUltimos.remove(oPortal.EV_Orden__c));
							EV_LogDebug.printLogDebug('@@remove ', String.valueOf(oldPortalDelete));
						}
					}
				}
			}
		}
		EV_LogDebug.printLogDebug('@@update values oldDestacado ', String.valueOf(oldDestacado.values()));
		update oldDestacado.values();
		
		EV_LogDebug.printLogDebug('@@update values oldUltimos ', String.valueOf(oldUltimos.values()));
		update oldUltimos.values();

		delete oldPortalDelete;
	}
}