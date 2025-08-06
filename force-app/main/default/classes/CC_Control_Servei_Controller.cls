public with sharing class CC_Control_Servei_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> init(Id idAgrupador, Datetime fechaInicio, Datetime fechaFin) {
        Map<String, Object> retorno = new Map<String, Object>();
        Boolean permiso = ![SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId()
                            AND PermissionSet.Name = 'CC_Control_Servei' LIMIT 1].isEmpty();
        retorno.put('permiso', permiso);

        if (permiso) {
            String nombrePlantilla = 'Plantilla_incidencia_masiva_comunicacion_informativa_afectados';
            retorno.put('htmlPlantilla', [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = :nombrePlantilla].HtmlValue);
            retorno.put('casos', getCasos(idAgrupador, fechaInicio, fechaFin, false));
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getCasos(Id idAgrupador, Datetime fechaInicio, Datetime fechaFin, Boolean busquedaFechas) {
        fechaInicio = fechaInicio != null ? fechaInicio : System.now().addYears(-3);
        fechaFin = fechaFin != null ? fechaFin : System.now();

        if(busquedaFechas) {
            return [SELECT Subject, CaseNumber, FORMAT(CreatedDate), Contact.Email, RecordType.Name FROM Case
            WHERE CC_Agrupador_Id__c = :idAgrupador AND RecordType.DeveloperName IN ('CC_Empleado', 'HDT_Empleado')
            AND  CreatedDate > :fechaInicio AND CreatedDate < :fechaFin ORDER BY CreatedDate ASC LIMIT 500];
        } else {
            return [SELECT Subject, CaseNumber, FORMAT(CreatedDate), Contact.Email, RecordType.Name FROM Case
            WHERE CC_Agrupador_Id__c = :idAgrupador AND RecordType.DeveloperName IN ('CC_Empleado', 'HDT_Empleado')
            ORDER BY CreatedDate ASC LIMIT 500];
        }
    }

    @AuraEnabled
    public static void enviarComunicacion(String plantilla, List<Case> casos) {
        plantilla = gestionarImagenesInlineRedactarMail(plantilla);
        Id idBuzonSalida = getBuzonSalidaId();
        if (idBuzonSalida == null) {
            throw new AuraHandledException('El buzón de salida "CC_Control_Servei" no está configurado');
        }
        List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> listaCorreosInsert = new List<EmailMessage>();
        EmailTemplate plantillaSalesforce = [SELECT Subject, Id FROM EmailTemplate WHERE DeveloperName = 'Plantilla_incidencia_masiva_comunicacion_informativa_afectados' LIMIT 1];

        
        for (Case caso : casos) {
            if (caso.Contact.Email != null) {
                Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                correo.setHtmlBody(plantilla);
                correo.setSaveAsActivity(true);
                correo.setWhatId(caso.Id);
                correo.setTargetObjectId(caso.contactId);
                correo.Subject = plantillaSalesforce.Subject;
                correo.setToAddresses(new List<String>{caso.Contact.Email});
                correo.setOrgWideEmailAddressId(idBuzonSalida);
                correos.add(correo);

            }
        }
        if (!correos.isEmpty()) {
            if (!Test.isRunningTest()){
            Messaging.sendEmail(correos, false);
            }else{
              EmailMessage correoOrigen = new EmailMessage();
                correoOrigen.Subject = 'Prueba de envío de correo';     
                correoOrigen.CC_Procedencia__c = 'Responder Cliente';
                correoOrigen.FromAddress = 'prueba@ibm.com';
                correoOrigen.ToAddress = 'prueba@ibm.com';
                correoOrigen.Incoming = true;
                correoOrigen.ParentId = casos[0].Id;
                correoOrigen.RelatedToId = casos[0].Id;
                correoOrigen.Headers = '[{"value": "","name": "X-SFDC-Original-RCPT"}]';
                correoOrigen.HtmlBody = 'Cuerpo<br/>';
                insert correoOrigen;
            }
        }
    }

    private static Id getBuzonSalidaId() {
        String buzonDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                WHERE Label = 'CC_Control_Servei' AND CC_Activo__c = TRUE LIMIT 1]?.CC_Direccion_Correo__c;
        return [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefecto LIMIT 1]?.Id;
    }
    /**
	 * @description Método para cambiar las imágenes inline privadas a URLs públicas
	 * @param caseId Identificador del caso
	 * @param cuerpoMail Cuerpo del mensaje
	 * @return Nuevo cuerpo del mensaje con las imágenes inline en formato público.
	 */

    @AuraEnabled(cacheable=false)
		public static String gestionarImagenesInlineRedactarMail(String emailBody) {
			String cuerpoEmailParseado = emailBody;
			try{
				if (String.isNotBlank(emailBody)) {
					// Pattern patronURLs = Pattern.compile('<img src=\\"https:\\/\\/caixabankcc([a-zA-Z0-9-=?&;%]|\\.|\\\\|:|\\/)+\\">');		
					Pattern patronURLs = Pattern.compile('<img src=\\"https:\\/\\/caixabankcc([a-zA-Z0-9-=?&;%]|\\.|\\\\|:|\\/)+\\" alt=\\"[^\\"]*\\"\\>');
					Pattern patronURLconDominio = Pattern.compile('<img src="(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/download\\/068[A-Za-z0-9]{12,15}" alt="[^"]*">');
					//Pattern patronURLchatter = Pattern.compile('<img\\s+src=\\"(https://[^\\"]*/sfc/servlet\\.shepherd/version/download/068[A-Za-z0-9]{12,15}[^\\"]*)\\"');	
					Pattern patronURLchatter = Pattern.compile('<img src="https:\\/\\/(.{0,100})?\\/sfc\\/servlet\\.shepherd\\/version\\/renditionDownload.{0,200}" alt="[^"]*">');
					Pattern patronURLchatterDos = Pattern.compile('<img\\s+src=\\"(https://[^\\"]*/sfc/servlet\\.shepherd/version/download/068[A-Za-z0-9]{12,15}[^\\"]*)\\">');	

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
					parsearCorreo(emailBody, patronURLchatterDos, patronChatter, mapaReemplazoUrls, setContentVersions, 'chatter');
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
									developerNameFinal = 'CC_' + contentVersion.id + randomUuid;
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
										CBK_log.debug('CC_Control_Servei_Controller: Error en la inserción de ContentAsset: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
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
											CBK_log.debug('CC_Control_Servei_Controller: Error en la actualización de ContentDocument: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
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
            
	}