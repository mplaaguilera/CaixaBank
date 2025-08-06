public without sharing class SEG_Case {

    private class DefaultException extends Exception {}

	public static void tomarPropiedad(List<Id> idCasos) {

		List<Case> casos = new List<Case>();
		for (Id idCaso : idCasos) {
			Case caso = new Case(Id = idCaso);
			caso.OwnerId = UserInfo.getUserId();
			caso.Status = 'Activo';
			caso.SEG_Subestado__c = 'En curso';
			casos.add(caso);
		}
		try {
			update casos;
		} catch (Exception e) {
			throw new DefaultException(e.getMessage());
		}

		//VFR 11/21 - Toast excepciones
		//Evaluar que las excepciones siguen aplicando
		Map<String, Object> retornoExcepciones = SEG_ExcepcionesHandler.calcularExcepcionesCasosYContratos(2, idCasos, false, null);
		Map<Id, List<SEG_Excepciones__c>> mapExcepciones = (Map<Id, List<SEG_Excepciones__c>>)retornoExcepciones.get('EXCEPCIONES');
		//List<SEG_Excepciones__c> lstExcepciones = mapExcepciones.get(caseId);

		List<Id> lstIdsExcepciones = new List<Id>();
		for (Id idCaso : idCasos) {
			List<SEG_Excepciones__c> lstExcepciones = mapExcepciones.get(idCaso);
			if (lstExcepciones != null) {
				for (SEG_Excepciones__c e : lstExcepciones) {
					lstIdsExcepciones.add(e.id);
				}
			}
		}
		
		//Excepciones del caso y comparar
		Id recordText = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
		List<SEG_Excepciones_Caso__c> lstExCase = new List<SEG_Excepciones_Caso__c>();
		for (SEG_Excepciones_Caso__c exc : [SELECT SEG_PopUp__c, SEG_Excepciones__c
											FROM SEG_Excepciones_Caso__c WHERE SEG_Case__c IN :idCasos
											AND SEG_Excepciones__r.RecordTypeId = :recordText
											AND SEG_Excepciones__r.SEG_Activa__c = TRUE]) {
			if (lstIdsExcepciones != null && lstIdsExcepciones.contains(exc.SEG_Excepciones__c)) {
				exc.SEG_PopUp__c = String.valueOfGmt(Datetime.now());
				lstExCase.add(exc);
			}
		}
		update lstExCase;
	}


	public static void rechazar(List<Id> idCasos) {
		try {
			SEG_Case_BU_TRHan.procesado = true;
            SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
            SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');
			List<SEG_ClasificacionRapida__c> crNoProced = [SELECT id, Name FROM SEG_ClasificacionRapida__c WHERE Name = 'No procede'];
		
			List<Case> casos = new List<Case>();
			if (!crNoProced.isEmpty()){
				for (Id idCaso : idCasos) {
					Case caso = new Case(Id = idCaso);
					caso.OwnerId = UserInfo.getUserId();
					caso.Status = 'Descartado';
					caso.SEG_Subestado__c = 'Rechazada';
					caso.SEG_ClasificacionRapida__c = crNoProced[0].id;
					casos.add(caso);
				}
			}
			update casos;
		} catch (Exception e) {
			throw new DefaultException(e.getMessage());
		}
	}

	public static void cambiarOwner(List<Id> idCasos, String userId){
		List<Case> casos = new List<Case>();
		for (Id idCaso : idCasos) {
			Case caso = new Case(Id = idCaso);
			caso.OwnerId = userId;
			caso.Status = 'Activo';
			caso.SEG_Subestado__c = 'En curso';
			casos.add(caso);
		}

		try {
			update casos;
		} catch (Exception e) {
			throw new DefaultException(e.getMessage());
		}
	}

	public static RespuestaCompleja cambiarGrupoMasivo(List<Id> idCasos, String grupoId){
		RespuestaCompleja respuestaCambio = new RespuestaCompleja();
		CC_Grupo_Colaborador__c grupoIndicado = new CC_Grupo_Colaborador__c();
		List<Case> casosIndicados = new List<Case>();
		List<Case> casosUpdate = new List<Case>();
		if(grupoId != null){
			grupoIndicado = [SELECT id, SEG_Organizacion__c, SEG_Zona__c FROM CC_Grupo_Colaborador__c WHERE Id =: grupoId];
		}
		if(grupoIndicado == null || grupoIndicado.SEG_Organizacion__c == null || grupoIndicado.SEG_Zona__c == null){
			respuestaCambio.nombreMsg = 'Error en el grupo indicado';
			respuestaCambio.datosMsg = 'El grupo indicado no existe o no tiene la organización y la zona rellenados.';
			return respuestaCambio;
		}

		if(idCasos != null && !idCasos.isEmpty()){
			casosIndicados = [SELECT id, CaseNumber, SEG_Organizacion__c, SEG_Zona__c FROM Case WHERE Id IN: idCasos];
		}

		if(casosIndicados != null && !casosIndicados.isEmpty()){
			String casosConErrores = '';
			for (Case casoIndicado : casosIndicados) {
				if(casoIndicado.SEG_Organizacion__c == null || casoIndicado.SEG_Zona__c == null || !grupoIndicado.SEG_Organizacion__c.contains(casoIndicado.SEG_Organizacion__c) || !grupoIndicado.SEG_Zona__c.contains(casoIndicado.SEG_Zona__c)) {
					casosConErrores = casosConErrores + ' ' + casoIndicado.CaseNumber;
				} else {
					Case casoUpdt = new Case(Id = casoIndicado.Id);
					casoUpdt.SEG_Grupo__c = grupoId;
					casosUpdate.add(casoUpdt);
				}
			}
			if (!casosUpdate.isEmpty()) {
				try {
					update casosUpdate;
				} catch (Exception e) {
					throw new DefaultException(e.getMessage());
				}
			}

			if(casosConErrores != ''){
				respuestaCambio.nombreMsg = 'Error al actualizar algunos casos';
				respuestaCambio.datosMsg = 'Los casos indicados no coinciden en Org y Zona con el grupo: ' + casosConErrores;
			}
		}
		return respuestaCambio;
	}

	public static void cerrarCasoMasivo(List<Id> idCasos){
		List<Case> casos = new List<Case>();
		for (Id idCaso : idCasos) {
			Case caso = new Case(Id = idCaso);
			caso.Status = 'Cerrado';
			casos.add(caso);
		}

		try {
			update casos;
		} catch (Exception e) {
			throw new DefaultException(e.getMessage());
		}
	}

	public class RespuestaCompleja {
    	@AuraEnabled public String nombreMsg {get; set; }
    	@AuraEnabled public String datosMsg{ get; set; }  
	}

}