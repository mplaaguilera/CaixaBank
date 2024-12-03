public with sharing class FRA_MCC_Buscador_Controller {

	@AuraEnabled(cacheable=true)
	public static List<sObject> querySalesforceRecord(Id objectId, String queryString, Integer numResultados) {
		CBK_log.debug('Inicio FRA_MCC_Buscador_Controller - querySalesforceRecord (objectId: ' + objectId + ', queryString: ' + queryString + ', numResultados: ' + numResultados + ')');
		CBK_log.debug('Fin FRA_MCC_Buscador_Controller - querySalesforceRecord');
		return Database.query(queryString);
	}

	@AuraEnabled
	public static Case actualizarCaso(Id recordId, Id idMotivo) {
		CBK_log.debug('Inicio FRA_MCC_Buscador_Controller - actualizarCaso (recordId: ' + recordId + ', idMotivo: ' + idMotivo + ')');
		//Actividad de retipificación con la clasificación anterior
		Case caso = [SELECT RecordTypeId, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name
		     		 FROM Case WHERE Id = :recordId];
		
		//Actualización del caso
		CC_MCC__c nuevaClasificacion = [SELECT Name, RecordType.DeveloperName, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.Name,
		 							           CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name, CC_Motivo__r.CC_Producto_Servicio__r.Name,
									           CC_Motivo__r.Name,CC_Tematica__r.Name
									  	FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Motivo' AND Id = :idMotivo];
		
		String cuerpoNuevo='Clasificación nueva:\n· Temática: '+ nuevaClasificacion.CC_Producto_Servicio__r.CC_Tematica__r.Name + '\n· Producto/Servicio: '+ nuevaClasificacion.CC_Producto_Servicio__r.Name + '\n· Motivo: '+ nuevaClasificacion.Name + '\n';
		crearActividadRetipificacion(caso.Id, caso.CC_MCC_Tematica__r.Name, caso.CC_MCC_ProdServ__r.Name, caso.CC_MCC_Motivo__r.Name,cuerpoNuevo);
		
		caso.CC_MCC_Tematica__c = nuevaClasificacion.CC_Producto_Servicio__r.CC_Tematica__r.Id;
		caso.CC_MCC_ProdServ__c = nuevaClasificacion.CC_Producto_Servicio__r.Id;
		caso.CC_MCC_Motivo__c = nuevaClasificacion.Id;	 
		caso.CC_MCC_Causa__c = null;
		caso.CC_MCC_Solucion__c = null; 
		      
		update caso;

		CBK_log.debug('Fin FRA_MCC_Buscador_Controller - actualizarCaso');
		return [SELECT CaseNumber, RecordType.Name, OwnerId, Status, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name
				FROM Case WHERE Id = :recordId];
	}

	@AuraEnabled(cacheable=true)
	public static Case getTipificacion(Id idCaso) {
		CBK_log.debug('Inicio FRA_MCC_Buscador_Controller - getTipificacion (idCaso: ' + idCaso + ')');
		CBK_log.debug('Fin FRA_MCC_Buscador_Controller - getTipificacion');
		return [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso];
	}

	public static void crearActividadRetipificacion(Id idCaso, String tematicaAnterior, String productoAnterior, String motivoAnterior,String cuerpoNuevo) {
		CBK_log.debug('Inicio FRA_MCC_Buscador_Controller - crearActividadRetipificacion (idCaso: ' + idCaso + ', tematicaAnterior: ' + tematicaAnterior +
					  ', productoAnterior: ' + productoAnterior + ', motivoAnterior: ' + motivoAnterior + ')');
		Case caso = [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso   LIMIT 1];
	  	if (motivoAnterior != null && motivoAnterior != '') {
			//Crear actividad
			String cuerpo = 'Se ha retipificado el caso.\n\n';
			cuerpo += 'Clasificación anterior:\n· Temática: '+ tematicaAnterior + '\n· Producto/Servicio: '+ productoAnterior + '\n· Motivo: '+ motivoAnterior + '\n\n';
			//cuerpo += 'Clasificación nueva:\n· Temática: '+ caso.CC_MCC_Tematica__r.Name + '\n· Producto/Servicio: '+ caso.CC_MCC_ProdServ__r.Name + '\n· Motivo: '+ caso.CC_MCC_Motivo__r.Name + '\n';
            cuerpo+=cuerpoNuevo;
			Task task = new Task();
			task.WhatId = idCaso;
			task.Status = 'Completed';
			task.ActivityDate = System.today();
			task.Subject = 'Reclasificación del caso';
			task.Type = 'Reclasificación';
			task.Description = cuerpo;
			task.RecordtypeId= CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
			insert task;
	  	}
		CBK_log.debug('Fin FRA_MCC_Buscador_Controller - crearActividadRetipificacion');
	}
}