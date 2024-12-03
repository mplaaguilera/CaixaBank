public with sharing class CSBD_GenerarDocumentoPlantilla_Apex {

	@AuraEnabled(cacheable=true)
	public static Map<String, Object> verCarpetaInicial(String carpetaDeveloperName) {
		Id idCarpeta;

		List<Folder> carpeta = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
		if (!carpeta.isEmpty()) {
			idCarpeta = carpeta[0].Id;
		} else if (Test.isRunningTest()) {
			idCarpeta = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].Id;
		}

		if (idCarpeta == null) {
			return null;
		} else {
			return verCarpeta(idCarpeta);
		}
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, Object> verCarpeta(Id idCarpeta) {
		Map<String, Object> retorno = new Map<String, Object>();
		retorno.put('carpeta', null);
		retorno.put('subcarpetas', new List<Folder>());
		retorno.put('plantillas', new List<EmailTemplate>());

		SObject carpeta;
		if (Test.isRunningTest()) {
			carpeta = [SELECT Name FROM User WHERE Id = :idCarpeta];
		} else {
			carpeta = [SELECT Name FROM Folder WHERE Id = :idCarpeta];
		}

		if (idCarpeta == null) {
			return retorno;
		} else {
			retorno.put('carpeta', carpeta);

			List<Folder> subcarpetas = [SELECT Name, ParentId FROM Folder WHERE ParentId = :idCarpeta ORDER BY Name ASC];
			retorno.put('subcarpetas', subcarpetas);

			List<EmailTemplate> plantillas = [SELECT Name, FolderId FROM EmailTemplate WHERE FolderId = :idCarpeta ORDER BY Name ASC];
			retorno.put('plantillas', plantillas);

			return retorno;
		}
	}

	@AuraEnabled(cacheable=true)
	public static String cuerpoPlantilla(Id idPlantilla, Id recordId) {
		try {
			Messaging.SingleEmailMessage correo = Messaging.renderStoredEmailTemplate(idPlantilla, UserInfo.getUserId(), recordId);
			return correo.getHtmlBody();
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<EmailTemplate> buscarPlantillas(Id idCarpeta, String cadenaBusqueda) {
		cadenaBusqueda = '%' + cadenaBusqueda + '%';
		return [SELECT Name, Subject FROM EmailTemplate
				WHERE FolderId = :idCarpeta AND Name LIKE :cadenaBusqueda
				ORDER BY NAME LIMIT 30];
	}
}