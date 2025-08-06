public with sharing class SPV_Utils {
    /*
    @description Método para recuperar los record types de un mapa de objetos.
    @param mapObjetos -> Mapa de objetos a obtener los recordTypes.
    @return Mapa con la configuración de de recordTypes obtenidos.
    */
    public static Map<String,Map<String,Schema.RecordTypeInfo>> getRecordTypesObjects(Set<String> setObjetos) {
        
        Map<String,Map<String,Schema.RecordTypeInfo>> mapObjectRT = new Map<String,Map<String,Schema.RecordTypeInfo>>();
        for(String objeto : setObjetos){
            if (String.isNotBlank(objeto) && !mapObjectRT.containsKey(objeto)){
                switch on objeto {
                    when 'Case' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_MCC__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_Grupo_Colaborador__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'CC_Grupo_Colaborador_Contact__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Grupo_Colaborador_Contact__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_Accion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_Interaccion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SPV_Formulario__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_MaestroAccionesReclamacion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_TMECaso__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_MaestroTemas__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_ImagenDocumento__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_ImagenDocumento__c .getRecordTypeInfosByDeveloperName());
                    }
                    when 'CBK_Case_Extension__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CBK_Case_Extension__c .getRecordTypeInfosByDeveloperName());
                    }
                    when 'Account' {
                        mapObjectRT.put(objeto, Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName());
                    }
					when 'CBK_CaseToCaseRelationship__c' {
                        mapObjectRT.put(objeto, Schema.SobjectType.CBK_CaseToCaseRelationship__c.getRecordTypeInfosByDeveloperName());
                    }
                }
            }
        }
        return mapObjectRT;
    }

    /**
    Creación del ThreadId
    */
    public static String creacionThreadID(String id){
        String threadId;

        threadId = ('ref:_'+ UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + id + ':ref');

        return threadId;
    }

    /**
	 * Método para comprobar en los envios de emails manuales que las direcciones de envio sean válidad (no se encuentren activas en la blackList)
	 */
    public static String comprobarEmailsBlackList(List<SAC_MaestroTemas__c> emailsBlackList, String para, String copia, String copiaOculta) {

        String emails = para + ';' + copia + ';' + copiaOculta;
        List<String> listaEmails = emails.split(';');

		//Si vienen una misma direccion en el para y en el cc o coo, almaceno solo una vez esa direccion
		Set<String> setEmails = new Set<String>();
        for (String email : listaEmails) {
            setEmails.add(email.trim());
        }

		//Iteramos para recuperar los correos únicos de la blackList
        Set<String> emailsNoValidosSet = new Set<String>();
        for (SAC_MaestroTemas__c emailNoValido : emailsBlackList) {
            emailsNoValidosSet.add(emailNoValido.Name);
        }

		//Iterar sobre cada correo electrónico en setEmails y verificar si está presente en la lista de correos electrónicos de la lista negra
        String emailsNoValidosEncontrados = '';
        for (String email : setEmails) { //listaEmails
            if (emailsNoValidosSet.contains(email.trim())) {
				//Si el email está en la lista negra, lo añadimos al string 'emailsNoValidosEncontrados' para devolverlo y mostrarlo por pantalla
                if (emailsNoValidosEncontrados != '') {
                    emailsNoValidosEncontrados += ', ';
                }
                emailsNoValidosEncontrados += email;
            }
        }

		//Devolver una cadena que informa los correos que están en la lista negra y coinciden con los pasados por parámetros
        return emailsNoValidosEncontrados;
    }

    /**
	 * Método para comprobar en los envios de emails automáticos que las direcciones de envio sean válidad (no se encuentren activas en la blackList)
	 */
    public static List<String> comprobarEmailsBlackListAuto(List<SAC_MaestroTemas__c> emailsBlackList, List<String> listEmailsEnviar) {

		//Iteramos para recuperar los correos únicos de la blackList
		Set<String> emailsNoValidosSet = new Set<String>();
		for (SAC_MaestroTemas__c emailNoValido : emailsBlackList) {
			emailsNoValidosSet.add(emailNoValido.Name);
		}

		//Crear una nueva lista para almacenar correos electrónicos válidos
		List<String> filteredEmails = new List<String>();

		//Iterar sobre cada correo electrónico en listEmailsEnviar y verificar si está presente en la lista de correos electrónicos de la lista negra
		if(!listEmailsEnviar.isEmpty()){
			for (String email : listEmailsEnviar) {
				//Si el email no pertenece a la blackList, le añadimos como valido a la lista filteredEmails
				if (!emailsNoValidosSet.contains(email.trim())) {
					filteredEmails.add(email);
				}
			}
		}		
		
		//Devolver la lista de correos electrónicos válidos
		return filteredEmails;
    }

    @AuraEnabled(cacheable=true)  
    public static List<RecordType> obtenerRecordTypes(){
        
        List<String> nombresObjetos = new List<String>{'Case', 'SAC_Interaccion__c', 'CBK_Case_Extension__c'};
        List<String> nombresRT = new List<String>{'SPV_Reclamacion', 'SPV_Escalado', 'SPV_ReclamacionCaseExt'};
        List<RecordType> listaRecordTypes = new List<RecordType>();

        listaRecordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType IN :nombresObjetos AND DeveloperName IN :nombresRT];
        
        return listaRecordTypes;
    }

    /**
	 * @description Raúl Santos - 08/04/2025 - Método para cambiar las imágenes inline privadas a URLs públicas
	 * @param emailBody Cuerpo del mensaje
	 * @return Nuevo cuerpo del mensaje con las imágenes inline en formato público.
	 */
	public static String gestionarImagenesInlineRedactarMail(String emailBody) {

		String cuerpoEmailParseado = emailBody;
		try{
			if (String.isNotBlank(emailBody)) {
				// Pattern patronURLs = Pattern.compile('<img src=\\"https:\\/\\/caixabankcc([a-zA-Z0-9-=?&;%]|\\.|\\\\|:|\\/)+\\">');		
				Pattern patronURLs = Pattern.compile('<img src=\\"https:\\/\\/caixabankcc([a-zA-Z0-9-=?&;%]|\\.|\\\\|:|\\/)+\\" alt=\\"[^\\"]*\\"\\>');

				// Pattern patronURLconDominio = Pattern.compile('<img src="(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/download\\/068[A-Za-z0-9]{12,15}">');
				Pattern patronURLconDominio = Pattern.compile('<img src="(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/download\\/068[A-Za-z0-9]{12,15}" alt="[^"]*">');

				// Pattern patronURLchatter = Pattern.compile('<img src="https:\\/\\/(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/renditionDownload.{0,200}">');
				Pattern patronURLchatter = Pattern.compile('<img src="https:\\/\\/(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/renditionDownload.{0,200}" alt="[^"]*">');

				//Expresión regular para buscar el ID del ContentVersion de la URL.
				Pattern patronCV = Pattern.compile('\\/068[a-zA-Z0-9]+\\?');
				Pattern patronCVDominio = Pattern.compile('\\/068[a-zA-Z0-9]+');
				Pattern patronChatter = Pattern.compile('068[a-zA-Z0-9]{12}');
				
				//Preparar mapa de URLs de reemplazo.
				Map<String,String> mapaReemplazoUrls = new Map<String,String>();
				Set<String> setContentVersions = new Set<String>();
                String orgId = UserInfo.getOrganizationId();
                orgId = orgId.substring(0,orgId.length()-3);

				//Parsear el correo saliente.
				//URL normal
				parsearCorreo(emailBody, patronURLs, patronCV, mapaReemplazoUrls, setContentVersions, 'url');
				//URL dominio
				parsearCorreo(emailBody, patronURLconDominio, patronCVDominio, mapaReemplazoUrls, setContentVersions, 'dominio');
				//URL chatter
				parsearCorreo(emailBody, patronURLchatter, patronChatter, mapaReemplazoUrls, setContentVersions, 'chatter');

				//Mapa final por cada fichero con su URL pública.
				Map<String,String> mapaFilePublicURL = new Map<String,String>();

				//Recuperar todos los links públicos, tanto los existentes como los generados en la transacción.
				if (!setContentVersions.isEmpty()) {
					List<ContentAsset> lstContentAsset = new List<ContentAsset>();
					List<ContentVersion> lstContentVersion = new List<ContentVersion>();

					List<ContentVersion> contestLimpios = new List<ContentVersion>();
					List<ContentVersion> lstVersion = [SELECT Id, ContentDocumentId, ContentDocument.ContentAssetId, ContentDocument.ContentAsset.DeveloperName  FROM ContentVersion WHERE Id IN :setContentVersions];
					Map<String, List<ContentVersion>> mapContentRepetidos = juntarRepeticiones(lstVersion);

					for (String idContentVersion : mapContentRepetidos.keySet()) {
						if (mapContentRepetidos.get(idContentVersion).size() == 1) {
							contestLimpios.add(mapContentRepetidos.get(idContentVersion)[0]);
						}
					}

					Map<String, Id> mapAssetDocument = new Map<String, Id>();
					Map<String, String> mapAssetContentVer = new Map<String, String>();
					
					for(ContentVersion contentVersion : contestLimpios){
						if(contentVersion.ContentDocumentId != null){
							String developerNameFinal;
							String idConVer = String.valueOf(contentVersion.Id);
							if (contentVersion.ContentDocument.ContentAssetId == null ) {
								String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
								developerNameFinal = 'SPV_' + contentVersion.id + randomUuid;
								ContentAsset assetId = new ContentAsset();
								assetId.DeveloperName = developerNameFinal;
								assetId.IsVisibleByExternalUsers = true;
								assetId.MasterLabel = developerNameFinal;
								lstContentVersion.add(contentVersion);
								lstContentAsset.add(assetId);
								mapAssetContentVer.put(developerNameFinal,idConVer.substring(0,idConVer.length()-3));
								mapAssetDocument.put(developerNameFinal, contentVersion.ContentDocumentId);
							} else if(contentVersion.ContentDocument.ContentAsset.DeveloperName != null){
								developerNameFinal = contentVersion.ContentDocument.ContentAsset.DeveloperName;
								mapaFilePublicURL.put(idConVer.substring(0,idConVer.length()-3),'https://'+ DomainCreator.getContentHostname() + '/file-asset-public/' + developerNameFinal + '?oid=' + orgId);
							}
						}
					}

					if(!lstContentAsset.isEmpty()){
						List<Database.SaveResult> resultadoInsercion = Database.insert(lstContentAsset,false);
						for (Database.SaveResult resInser : resultadoInsercion) {
							if (!resInser.isSuccess()) {
								for(Database.Error err : resInser.getErrors()){
									CBK_log.debug('SPV_Utils: Error en la inserción de ContentAsset: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
								}
							}
						}

						List<ContentDocument> lstContentDocument = new List<ContentDocument>();

						for (ContentAsset asset : lstContentAsset) {
							if (asset.Id != null) {
								mapaFilePublicURL.put(mapAssetContentVer.get(asset.DeveloperName),'https://'+ DomainCreator.getContentHostname() + '/file-asset-public/' + asset.DeveloperName + '?oid=' + orgId);
								ContentDocument cntDocument = new ContentDocument();
								cntDocument.Id = mapAssetDocument.get(asset.DeveloperName);
								cntDocument.ContentAssetId = asset.Id;
								lstContentDocument.add(cntDocument);
							}
						}

						if(!lstContentDocument.isEmpty()){
							List<Database.SaveResult> resultadoUpdate = Database.update(lstContentDocument,false);
							for (Database.SaveResult resUpdt : resultadoUpdate) {
								if (!resUpdt.isSuccess()) {
									for(Database.Error err : resUpdt.getErrors()){
										CBK_log.debug('SPV_Utils: Error en la actualización de ContentDocument: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
									}
								}
							}
						}

						//Actualizar el ContentVersion para que tenga el valor SPV_BloqueoTotalVisibilidad__c=true
						if(!lstVersion.isEmpty()){
							List<Database.SaveResult> resultadoCVUpdate = Database.update(lstVersion,false);
							for (Database.SaveResult resUpdt : resultadoCVUpdate) {
								if (!resUpdt.isSuccess()) {
									for(Database.Error err : resUpdt.getErrors()){
										CBK_log.debug('SPV_Utils: Error en la actualización de ContentVersion: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
									}
								}
							}
						}
					}
				}

				//Reemplazar el contenido del email con los links públicos.
				for (String urlPrivadaCorreo : mapaReemplazoUrls.keySet()) {
					String ficheroURL;
					String altURL = '';
					String nuevaURL;

					if (mapaReemplazoUrls.containsKey(urlPrivadaCorreo)) {
						ficheroURL = mapaReemplazoUrls.get(urlPrivadaCorreo);

						if(urlPrivadaCorreo.contains('alt')){
							Integer inicioAlt = urlPrivadaCorreo.indexOf('alt="') + 5;
							Integer finAlt = urlPrivadaCorreo.indexOf('"', inicioAlt);
							altURL = urlPrivadaCorreo.substring(inicioAlt, finAlt);
						}
						
					}
					if (!String.isBlank(ficheroURL) && mapaFilePublicURL.containsKey(ficheroURL)) {
						nuevaURL = mapaFilePublicURL.get(ficheroURL);
					}
					if (!String.isBlank(nuevaURL) && String.isNotBlank(nuevaURL)) {
						if(altURL != ''){
							emailBody = emailBody.replace(urlPrivadaCorreo, '<img src="' + nuevaURL + '" alt="' + altURL + '">');
						}else{
							emailBody = emailBody.replace(urlPrivadaCorreo, '<img src="' + nuevaURL + '">');
						}
					}
				}

				cuerpoEmailParseado = emailBody;
			}
		}catch (Exception e){
			// Registramos error, pero no se impide la operativa del usuario.
			CBK_Log.error(e);
			cuerpoEmailParseado = emailBody;
		}

		return cuerpoEmailParseado;
	}

	/**
	 * @description Devuelve el id de los CV a tratar
	*/
	private static Map<String, List<ContentVersion>> juntarRepeticiones (List<ContentVersion> listContent){

		Map<String, List<ContentVersion>> mapContentRepetidos = new Map<String, List<ContentVersion>>();
		for (ContentVersion contentVersion : listContent) {
			String idString = String.valueOf(contentVersion.Id);
			List<ContentVersion> lstContent = new List<ContentVersion>();
			if (mapContentRepetidos.containsKey(idString.left(15))) {
				lstContent = mapContentRepetidos.get(idString.left(15));
				lstContent.add(contentVersion);
				mapContentRepetidos.put(idString.left(15),lstContent);
			} else {
				lstContent.add(contentVersion);
				mapContentRepetidos.put(idString.left(15),lstContent);
			}

			contentVersion.SAC_BloqueoTotalVisibilidad__c = true;
		}
		return mapContentRepetidos;
	}

	/**
	 * @description Método obtener la id del CV de la imagen inline
	*/
	private static void parsearCorreo(String emailBody, Pattern patronURL, Pattern patronCV, Map<String,String> mapaReemplazoUrls, Set<String> setContentVersions, String tipo){

		Matcher matcherCorreo = patronURL.matcher(emailBody);

		while (matcherCorreo.find()) {
			String urlImagen = matcherCorreo.group();

			//Comprobar que no sea una URL pública.
			//No ha de contener los valores que se generan como URL de descarga: /sfc/dist/version/download, oid=, ids=, &d=
			Boolean urlPublica = false;
			if (tipo != 'chatter' && urlImagen.contains('/sfc/dist/version/download') && urlImagen.contains('oid=') && urlImagen.contains('ids=') && urlImagen.contains('&d=')){
				urlPublica = true;
			}

			//Assets públicos.
			if (urlImagen.contains('/file-asset-public') && urlImagen.contains('oid=')){
				urlPublica = true;
			}
			if (!urlPublica){
				//Parsear la url privada para encontrar el Identificador del fichero.
				Matcher matcherCV = patronCV.matcher(urlImagen);

				if (matcherCV.find()) {							
					String fileId = matcherCV.group();
					
					if(tipo == 'url'){
						fileId = fileId.substring(1,fileId.length()-1);
					}else if(tipo == 'dominio'){
						fileId = fileId.substring(1,fileId.length()-3);
					}else if(tipo == 'chatter'){
						fileId = fileId.substring(0,fileId.length());
					}
					
					mapaReemplazoUrls.put(urlImagen, fileId);
					setContentVersions.add(fileId);
				}
			}
		}
	}

	/**
	 * @description Método que inserta o elimina el permission set pasado como parámetro
	 */
	public static void procesarPermisionSet(Boolean esInsertar, String userId, String psName) {

		if(esInsertar){
			List<PermissionSetAssignment> listPermisosUser = [SELECT PermissionSetId, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = :psName LIMIT 1];

			if(listPermisosUser.isEmpty()){
				//Asignamos al usuario el PS SPV_SystemAdmin para poder saltarse las validaciones
				PermissionSet psSaltarValidaciones = [SELECT id FROM PermissionSet WHERE PermissionSet.Name = :psName LIMIT 1];

				PermissionSetAssignment assigmentSaltoValidacion = new PermissionSetAssignment (PermissionSetId = psSaltarValidaciones.id, AssigneeId = userId); 
				SPV_DatabaseDML.insertDML(assigmentSaltoValidacion, true);
			}
        }else{
            //Quitamos al usuario el PS SPV_SystemAdmin
            List<PermissionSetAssignment> listPermisosUser = [SELECT PermissionSetId, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = :psName LIMIT 1];

			if(!listPermisosUser.isEmpty()){
				SPV_DatabaseDML.deleteListDML(listPermisosUser, true);
			}
        }
	}	

	/***********************************************************************************************
     * Proposito: Comprobar si el usuario tiene el CustomPermission byPass para saltarse las
     * validaciones de campos
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1208220      Álex Polo       15/04/2025      Creación 
     ***********************************************************************************************/
    public static Boolean comprobarTieneBypass(){

        Boolean tieneByPass = false;

        //Se obtienen los Ps que el usuario tiene asignados para ver si alguno de ellos tiene el CustomPermission ByPass
        Set<Id> psAsignados = new Map<Id, PermissionSet>([
            SELECT Id FROM PermissionSet
            WHERE Id IN (
                SELECT PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
            )
        ]).keySet();

        if(!psAsignados.isEmpty()){
            List<CustomPermission> customPermisos = [
                SELECT DeveloperName FROM CustomPermission
                WHERE Id IN (
                    SELECT SetupEntityId
                    FROM SetupEntityAccess
                    WHERE SetupEntityType = 'CustomPermission'
                    AND ParentId IN :psAsignados
                ) AND DeveloperName = 'SPV_BypassValidationRules'
            ];
    
            if (!customPermisos.isEmpty()) {
                tieneByPass = true;
            }
        }
        return tieneByPass;
    }


	/***********************************************************************************************
     * Proposito: Calcular el tiempo que hay entre la fecha y la medianoche
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR            DATE         Description
     * 1.0             			    Sergio Martín      09/05/2025      Creación 
     ***********************************************************************************************/
	public static Integer minutosHastaMedianoche(DateTime fecha) {
        // Calcula la fecha de medianoche del día actual
        DateTime medianoche = DateTime.newInstance(fecha.year(), fecha.month(), fecha.day(), 23, 59, 59);
        // Calcula la diferencia en minutos entre la fecha dada y medianoche
        Long diferenciaMinutos = (medianoche.getTime() - fecha.getTime()) / (1000 * 60);
        // Convierte la diferencia en minutos a un valor absoluto
        diferenciaMinutos = Math.abs(diferenciaMinutos);
        return Integer.valueOf(diferenciaMinutos);
    }
}