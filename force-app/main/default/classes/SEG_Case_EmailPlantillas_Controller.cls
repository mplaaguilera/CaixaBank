public with sharing class SEG_Case_EmailPlantillas_Controller {

	@AuraEnabled(cacheable=true)
	static public String recuperarUser() {
		return UserInfo.getUserId();
	}

	@AuraEnabled(cacheable=true)
    public static Contact getNombreEmailContacto(Id idContacto) {
        List<Contact> contactos = [SELECT Name, Email 
									FROM Contact WHERE Id = :idContacto];
		if (contactos.isEmpty()) {
			return null;
		} else {
			return contactos[0];
		}
    }

	@AuraEnabled(cacheable=true)
	public static Map<Id, SEG_Plantilla__c> buscadorPlantilla(String searchKey, String idCase, String idioma) {
		Case caso = [SELECT SEG_Organizacion__c 
                     FROM Case WHERE id = :idCase];
		String name =  '%' + searchKey + '%';
		if (searchKey == '') {
			return null;
		} else {
			Map<Id, SEG_Plantilla__c> mapPlantillas = new Map<Id, SEG_Plantilla__c>(
				[SELECT Name, SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c ,SEG_PlantillaGalegoID__c, SEG_PlantillaInglesID__c
					FROM SEG_Plantilla__c WHERE Name LIKE :name 
                 	AND SEG_Organizacion__c includes (:caso.SEG_Organizacion__c) AND SEG_Activa__c = TRUE
					ORDER BY CreatedDate DESC]
			);

			//Remove plantillas que no esten en el idioma seleccionado
			if (idioma == 'en') {
				for (SEG_Plantilla__c plantilla : mapPlantillas.values()) 
                {
					if (plantilla.SEG_PlantillaInglesID__c == null) {
						mapPlantillas.remove(plantilla.id);
					}
				}
			} else if (idioma == 'es') {
				for (SEG_Plantilla__c plantilla : mapPlantillas.values()) 
                {
					if (plantilla.SEG_PlantillaCastellanoID__c == null) {
						mapPlantillas.remove(plantilla.id);
					}
				}
			} else if (idioma == 'ca') {
				for (SEG_Plantilla__c plantilla : mapPlantillas.values()) 
                {
					if (plantilla.SEG_PlantillaCatalanID__c == null) {
						mapPlantillas.remove(plantilla.id);
					}
				}
			} else if (idioma == 'eu') {
				for (SEG_Plantilla__c plantilla : mapPlantillas.values()) 
                {
					if (plantilla.SEG_PlantillaEuskeraID__c == null) {
						mapPlantillas.remove(plantilla.id);
					}
				}
			} else if (idioma == 'ga') {
				for (SEG_Plantilla__c plantilla : mapPlantillas.values()) 
                {
					if (plantilla.SEG_PlantillaGalegoID__c == null) {
						mapPlantillas.remove(plantilla.id);
					}
				}
			}
			return mapPlantillas;
		}
	}

	@AuraEnabled(cacheable=true)
	static public Map<Id, SEG_Plantilla__c> getPlantillas(String contactId, String idioma, String caseId) {

		Case caso = [SELECT AccountId, ContactId, SEG_Organizacion__c, SEG_Zona__c,
						SEG_Numero_de_centro__c, SEG_Grupo__c, SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c
						FROM Case WHERE id = :caseId];

		Map<Id, SEG_Plantilla__c> mapPlantillas = new Map<Id, SEG_Plantilla__c>();
		Map<Id, Id> mapPlantillasAux = new Map<Id, Id>();

		
		//Paso 1: filtramos plantillas por organización y zona
		for (SEG_Plantilla__c seg_plantilla : [SELECT Name, SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c, SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c,
												SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c, SEG_PlantillaInglesID__c, SEG_TipoOperativa__c
												FROM SEG_Plantilla__c WHERE SEG_Activa__c = true
												AND SEG_Organizacion__c includes(:caso.SEG_Organizacion__c) 
												AND SEG_Zona__c includes (:caso.SEG_Zona__c)]) 
		{
			mapPlantillas.put(seg_plantilla.id, seg_plantilla);
		}

		if (!mapPlantillas.isEmpty()) {
			//Paso 2: Recuperamos los centros de la plantilla. En caso de no tener ninguno la plantilla sigue siendo válida
			//Si tuviera centros pero no casa con el centro del caso, haríamos remove del mapPlantillas
			Map<Id, SEG_ExcepcionesCentro__c> detallesCentros = new Map<Id, SEG_ExcepcionesCentro__c>(
				[SELECT SEG_Plantilla__c, SEG_CentroEmpresa__c 
					FROM SEG_ExcepcionesCentro__c WHERE SEG_Plantilla__c IN :mapPlantillas.keySet() 
					AND SEG_CentroEmpresa__c = :caso.SEG_Numero_de_centro__c]
			);

			if (!detallesCentros.isEmpty()) {
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id>();
				for (SEG_ExcepcionesCentro__c detalle : detallesCentros.values()) {
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
					mapPlantillasAux.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}

				for (Id plantillaID : mapPlantillas.keySet()) {
					if (!auxMapIdPlantillas.containsKey(plantillaID)) {mapPlantillas.remove(plantillaID);
					}
				}
			} else {
				for (SEG_ExcepcionesCentro__c excepcionCentro : [SELECT SEG_Plantilla__c, SEG_CentroEmpresa__c FROM SEG_ExcepcionesCentro__c
																	WHERE SEG_Plantilla__c IN :mapPlantillas.keySet()]) 
				{
					if (mapPlantillas.containsKey(excepcionCentro.SEG_Plantilla__c)) {
						mapPlantillas.remove(excepcionCentro.SEG_Plantilla__c);
					}
				}
			}

			Map<Id, SEG_ExcepcionesGrupo__c> detallesGrupos = new Map<Id, SEG_ExcepcionesGrupo__c>(
				[SELECT SEG_Plantilla__c, SEG_GrupoTrabajoTexto__c 
					FROM SEG_ExcepcionesGrupo__c WHERE SEG_Plantilla__c IN :mapPlantillas.keySet() 
					AND SEG_GrupoTrabajoTexto__c = :caso.SEG_Grupo__c]
			);

			if(!detallesGrupos.isEmpty()) {
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id>();
				for (SEG_ExcepcionesGrupo__c detalle : detallesGrupos.values())	{
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
					mapPlantillasAux.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}

				for (Id plantillaID : mapPlantillas.keySet()) {
					if (!auxMapIdPlantillas.containsKey(plantillaID)) {mapPlantillas.remove(plantillaID);
					}
				}
			} else {
				for (SEG_ExcepcionesGrupo__c excepcionGrupo : [SELECT SEG_Plantilla__c, SEG_GrupoTrabajoTexto__c FROM SEG_ExcepcionesGrupo__c
																WHERE SEG_Plantilla__c IN :mapPlantillas.keySet()]) {
					if (mapPlantillas.containsKey(excepcionGrupo.SEG_Plantilla__c)) {mapPlantillas.remove(excepcionGrupo.SEG_Plantilla__c);
					}
				}
			}

			//Paso 4: nos queda buscar por empresa y grupo de empresas. Si hay grupo de empresas informado se ignora la empresa. Adecuar
			Map<Id, SEG_ExcepcionesGrupoEmpresa__c> detallesGruposEmpresa = new Map<Id, SEG_ExcepcionesGrupoEmpresa__c>(
				[SELECT SEG_Plantilla__c, SEG_GrupoEmpresa__c FROM SEG_ExcepcionesGrupoEmpresa__c
					WHERE SEG_Plantilla__c IN :mapPlantillas.keySet() 
					AND SEG_GrupoEmpresa__c  = :caso.SEG_Grupo_Empresa__c]
			);

			if (detallesGruposEmpresa.isEmpty()) {
				Map<Id, SEG_ExcepcionesEmpresa__c> detallesEmpresa = new Map<Id, SEG_ExcepcionesEmpresa__c>(
					[SELECT SEG_Plantilla__c, SEG_Empresa__c FROM SEG_ExcepcionesEmpresa__c
						WHERE SEG_Plantilla__c IN :mapPlantillas.keySet() 
						AND SEG_Empresa__c = :caso.AccountId]
				);

				//comprobamos empresas
				if (!detallesEmpresa.isEmpty()) {
					Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id>();
					for (SEG_ExcepcionesEmpresa__c detalle : detallesEmpresa.values()) {
						auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
						mapPlantillasAux.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
					}

					for (Id plantillaID : mapPlantillas.keySet()) {
						if (!auxMapIdPlantillas.containsKey(plantillaID)) {mapPlantillas.remove(plantillaID);
						}
					}
				} else {
					for (SEG_ExcepcionesEmpresa__c excepcionEmpresa : [SELECT SEG_Plantilla__c, SEG_Empresa__c FROM SEG_ExcepcionesEmpresa__c
																		WHERE SEG_Plantilla__c IN :mapPlantillas.keySet()]) {
						if (mapPlantillas.containsKey(excepcionEmpresa.SEG_Plantilla__c)) {mapPlantillas.remove(excepcionEmpresa.SEG_Plantilla__c);
						}
					}
				}
			} else {
				//comprobamos grupos de empresas
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id>();
				for (SEG_ExcepcionesGrupoEmpresa__c detalle : detallesGruposEmpresa.values()) {
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
					mapPlantillasAux.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}

				for (Id plantillaID : mapPlantillas.keySet()) {
					if (!auxMapIdPlantillas.containsKey(plantillaID)) {mapPlantillas.remove(plantillaID);
					}
				}
			}

			//Paso 5: busqueda por clasificación rápida
			Map<Id, SEG_ExcepcionesCR__c> detallesCR = new Map<Id, SEG_ExcepcionesCR__c>(
				[SELECT SEG_Plantilla__c, SEG_ClasificacionRapida__c 
					FROM SEG_ExcepcionesCR__c WHERE SEG_Plantilla__c IN :mapPlantillas.keySet() 
					AND SEG_ClasificacionRapida__c = :caso.SEG_ClasificacionRapida__c]
			);

			if (!detallesCR.isEmpty()) {
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id>();
				for (SEG_ExcepcionesCR__c detalle : detallesCR.values()) {
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
					mapPlantillasAux.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}

				for (Id plantillaID : mapPlantillas.keySet()) {
					if (!auxMapIdPlantillas.containsKey(plantillaID)) {mapPlantillas.remove(plantillaID);
					}
				}
			} else {
				//en este caso deberemos buscar las CR y quitar del map todas las que existan
				for (SEG_ExcepcionesCR__c excepcionCR : [SELECT SEG_Plantilla__c, SEG_ClasificacionRapida__c FROM SEG_ExcepcionesCR__c 
															WHERE SEG_Plantilla__c IN :mapPlantillas.keySet()]) {
					if (mapPlantillas.containsKey(excepcionCR.SEG_Plantilla__c)) {mapPlantillas.remove(excepcionCR.SEG_Plantilla__c);
					}
				}
			}
		}
		
		/*
		Marc Pla, 28 nov 2021: Código anterior tenía una lógica de búsqueda
		de plantillas distinta para contactos de tipo colaborador
		
		else if (contact.RecordTypeId == rtColaborador) {
			List<String> idsPlantilla = new List<String>();
			CC_Grupo_Colaborador_Contact__c grupoCol;

			//Se busca el grupo del contact
			if (contact != null) {
				List<CC_Grupo_Colaborador_Contact__c> gruposCol = [SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c
																	WHERE CC_Contacto__c = :contact.id LIMIT 1];
				if (!gruposCol.isEmpty()) {
					for (CC_Grupo_Colaborador_Plantilla__c gP : [SELECT SEG_Plantilla__c FROM CC_Grupo_Colaborador_Plantilla__c
																	WHERE CC_Grupo_Colaborador__c = :gruposCol[0].CC_Grupo_Colaborador__c]) {
						idsPlantilla.add(gP.SEG_Plantilla__c);
					}

					if (!idsPlantilla.isEmpty()) {
						for (SEG_Plantilla__c p : [SELECT Name, SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c,
													SEG_PlantillaGalegoID__c, SEG_PlantillaInglesID__c FROM SEG_Plantilla__c
													WHERE Id IN :idsPlantilla AND SEG_TipoOperativa__c = 'Acuse de recibo']) {
							mapPlantillas.put(p.id, p);
						}
					}
				}
			}
		}
		*/

		//Remove plantillas que no esten en el idioma seleccionado
		if (idioma == 'en') {
			for (SEG_Plantilla__c plantilla : mapPlantillas.values()) {
				if (plantilla.SEG_PlantillaInglesID__c == null) {mapPlantillas.remove(plantilla.id);
				}
			}
		} else if (idioma == 'es') {
			for (SEG_Plantilla__c plantilla : mapPlantillas.values()) {
				if (plantilla.SEG_PlantillaCastellanoID__c == null) {mapPlantillas.remove(plantilla.id);
				}
			}
		} else if (idioma == 'ca') {
			for (SEG_Plantilla__c plantilla : mapPlantillas.values()) {
				if (plantilla.SEG_PlantillaCatalanID__c == null) {mapPlantillas.remove(plantilla.id);
				}
			}
		} else if (idioma == 'eu') {
			for (SEG_Plantilla__c plantilla : mapPlantillas.values()) {
				if (plantilla.SEG_PlantillaEuskeraID__c == null) {mapPlantillas.remove(plantilla.id);
				}
			}
		} else if (idioma == 'ga') {
			for (SEG_Plantilla__c plantilla : mapPlantillas.values()) {
				if (plantilla.SEG_PlantillaGalegoID__c == null) {mapPlantillas.remove(plantilla.id);
				}
			}
		}
		return mapPlantillas;
	}

	//Sacar datos del destinatario
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getDatosDestinatarioNuevo(Id recordId) {
			Map<String,String> datosDestinatario = new Map<String, String>();
		if (recordId != null){
			if ((recordId).getSObjectType() == Schema.getGlobalDescribe().get('AccountContactRelation')) {
				AccountContactRelation acr = [SELECT Contact.Name, Contact.Email 
											  FROM AccountContactRelation WHERE Id = :recordId];
				if (acr.Contact.Email == null) {
					datosDestinatario.put(acr.Contact.Name, 'Sin correo');
				} else {
					datosDestinatario.put(acr.Contact.Name, acr.Contact.Email);
				}
			} else if ((recordId).getSObjectType() == Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c')) {
				CC_Grupo_Colaborador__c g = [SELECT Name, CC_Cuenta__r.CC_Email__c 
											 FROM CC_Grupo_Colaborador__c WHERE id = :recordId];
				datosDestinatario.put(g.Name, g.CC_Cuenta__r.CC_Email__c);
				if (datosDestinatario.get(g.Name) == null) {
					datosDestinatario.put(g.Name, 'Sin correo');
				}
			}
		}
		
		return datosDestinatario;
	}

	@AuraEnabled(cacheable=true)
	public static List<CC_Grupo_Colaborador_Contact__c> colaboradoresParaPlant(Id idGrupo) {
		return [SELECT CC_Nombre__c, CC_Email__c , CC_Grupo_Colaborador__c, CC_Para_CC__c
				FROM CC_Grupo_Colaborador_Contact__c  WHERE CC_Grupo_Colaborador__c = :idGrupo];
	}

	@AuraEnabled(cacheable=true)
	public static List<CC_Canal_Com__c> canalComunicacionParaPlant(Id idCliente) {
		//TODO: controlar si idcliente viene vacío devolver null o lista vacia
		return [SELECT CC_ContactName__c, CC_Email__c, SEG_ParaCC__c 
                FROM CC_Canal_Com__c  WHERE CC_ContactoId__c = :idCliente];
	}
}