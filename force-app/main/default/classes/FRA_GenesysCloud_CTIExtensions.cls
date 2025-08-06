Global with sharing class FRA_GenesysCloud_CTIExtensions implements purecloud.CTIExtension.ClickToDial {
	public String onClickToDial(String data) {
		Map<String, Object> clickToDialData = (Map<String, Object>) JSON.deserializeUntyped(data);
		if (clickToDialData.get('object') != 'Case') {
			return '';
		} else {
			Map<String, Object> attributes = new Map<String, Object>();
			attributes.put('casoIdFRA', clickToDialData.get('objectId'));
            
			List<CC_Servicio_Genesys__c> servicios=FRA_Servicio_Genesys.obtenerInfoServicioGenesys(String.valueOf(clickToDialData.get('objectId')));
            if(!servicios.isEmpty()){
                if(String.isNotBlank(servicios[0].KIN_Cola_Id_GC__c)){
                	clickToDialData.put('queueId',servicios[0].KIN_Cola_Id_GC__c);
                    attributes.put('queueIdFRA',servicios[0].KIN_Cola_Id_GC__c);
                }
                if(String.isNotBlank(servicios[0].CC_Canal_Procedencia__c)){
                     attributes.put('procedenciaFRA',servicios[0].CC_Canal_Procedencia__c);
                }
            }
            clickToDialData.put('attributes', attributes);
			System.debug(clickToDialData);
			return JSON.serialize(clickToDialData);
		}
	}
}