public with sharing class CC_MCC_Buscador_Controller_Backup {

	@AuraEnabled(cacheable=true)
	public static List<sObject> querySalesforceRecord(String queryString) {
		return Database.query(queryString);
	}

	@AuraEnabled
	public static Boolean actualizarCaso(Id idCaso, Id idMotivo) {
        Boolean casoActualizado = true;

        Boolean habilitar = CC_Permisos_Tercer_Nivel__c.getInstance().CC_Bloquear__c;
        if (habilitar == true) {
            casoActualizado = false;
        } else {
            Case casoOld = [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso LIMIT 1];

            CC_MCC__c mcc = [SELECT Name, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.Name
								FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Motivo' AND Id = :idMotivo LIMIT 1];

			Case caso = new Case(Id = idCaso);
            caso.CC_MCC_Tematica__c = mcc.CC_Producto_Servicio__r.CC_Tematica__r.Id;
            caso.CC_MCC_ProdServ__c = mcc.CC_Producto_Servicio__r.Id;
            caso.CC_MCC_Motivo__c = mcc.Id;
            caso.CC_MCC_Causa__c = null;
            caso.CC_MCC_Solucion__c = null;
            update caso;

			CC_Case.crearActividadRetipificacion(caso.Id, casoOld.CC_MCC_Tematica__r.Name, casoOld.CC_MCC_ProdServ__r.Name, casoOld.CC_MCC_Motivo__r.Name);
        }
        return casoActualizado;
	}

	@AuraEnabled(cacheable=true)
	public static Case getTipificacion(Id idCaso) {
		return [SELECT  CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso];
	}

    @AuraEnabled(cacheable=true)
    public static Case datosCaso(String recordId) {
        return [SELECT CC_Canal_Procedencia__c, Status, CC_En_Tercer_Nivel__c, RecordType.Name, CC_Tipo_Cliente__c, CC_MCC_Tematica__r.Name,
                CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :recordId];
    }

    @AuraEnabled
    public static Boolean getEsPropietarioCaso(String sIdCaso) {
        //CHEMA: Rescatamos el id de usuario y lo comparamos con el del usuario asignado al caso, si no es el mismo
        //devolvemos error por no ser propietario
        return CC_busqueda_alf_controller.getEsPropietarioCaso(sIdCaso);
    }
}