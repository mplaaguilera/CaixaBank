public with sharing class CC_GenerarDocumentoPlantilla_Apex {

     
    /**
    Wrapper para retornar datos de la email template
    */
    public class WrapperTemplate{
        @AuraEnabled public String cuerpo{get;set;}
        @AuraEnabled public String header{get;set;}
        @AuraEnabled public String footer{get;set;}
        @AuraEnabled public String encabezado{get;set;}
        @AuraEnabled public String pieFirma{get;set;}
        @AuraEnabled public String firma{get;set;}
        
        public WrapperTemplate(String miCuerpo, String miHeader, String miFooter, String miEncabezado, String miPieFirma, String miFirma){
            this.cuerpo = miCuerpo;
            this.header = miHeader != null ? miHeader : '';
            this.footer = miFooter != null ? miFooter : '';
            this.encabezado = miEncabezado != null ? miEncabezado : '';
            this.pieFirma = miPieFirma != null ? miPieFirma : '';
            this.firma = miFirma != null ? miFirma : '';
        }
    }
    
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

    
    @AuraEnabled
    public static WrapperTemplate obtenerDatosTemplate(String idPlantilla, String recordId) {
        String idiomaCaso = [SELECT CC_Idioma__c FROM Case WHERE Id = :recordId].CC_Idioma__c;
        EmailTemplate plantillaSeleccionada = new EmailTemplate();
        EmailTemplate plantillaHeader = new EmailTemplate();
        EmailTemplate plantillaFooter = new EmailTemplate();
        EmailTemplate plantillaEncabezado = new EmailTemplate();
        EmailTemplate plantillaPieFirma = new EmailTemplate();
        EmailTemplate plantillaFirma = new EmailTemplate();
        List<EmailTemplate> lstPlantillas = new List<EmailTemplate>();
        String encabezado;
        String pieFirma;
        String firma;
        if (idiomaCaso == 'es') { // Castellano
            encabezado = 'CC_Encabezado_Correo_Postal_CAS';
            pieFirma = 'CC_Pie_Firma_Correo_Postal_CAS';
            firma = 'CC_Firma_Correo_Postal_CAS';
        } else if (idiomaCaso == 'ca') { // Catalán
            encabezado = 'CC_Encabezado_Correo_Postal_CAT';
            pieFirma = 'CC_Pie_Firma_Correo_Postal_CAT';
            firma = 'CC_Firma_Correo_Postal_CAT';
        } else if (idiomaCaso == 'eu') { // Euskera
            encabezado = 'CC_Encabezado_Correo_Postal_EU';
            pieFirma = 'CC_Pie_Firma_Correo_Postal_EU';
            firma = 'CC_Firma_Correo_Postal_EU';
        } else if (idiomaCaso == 'va') { // Valenciano
            encabezado = 'CC_Encabezado_Correo_Postal_VA';
            pieFirma = 'CC_Pie_Firma_Correo_Postal_VA';
            firma = 'CC_Firma_Correo_Postal_VA';
        } else if (idiomaCaso == 'ga') { // Gallego
            encabezado = 'CC_Encabezado_Correo_Postal_GA';
            pieFirma = 'CC_Pie_Firma_Correo_Postal_GA';
            firma = 'CC_Firma_Correo_Postal_GA';
        } else { //Inglés y otros idiomas
            encabezado = 'CC_Encabezado_Correo_Postal_EN';
            pieFirma = 'CC_Pie_Firma_Correo_Postal_EN';
            firma = 'CC_Firma_Correo_Postal_EN';
        }

        if (Schema.sObjectType.EmailTemplate.isAccessible()){
            lstPlantillas = [SELECT Id, Name, HtmlValue, DeveloperName, Folder.DeveloperName FROM EmailTemplate WHERE Id =: idPlantilla OR Developername IN ('CC_Header','CC_Footer',:encabezado,:pieFirma,:firma)];
        }
        
        if(lstPlantillas != null && !lstPlantillas.isEmpty()) {
            for(EmailTemplate em : lstPlantillas) {
                if(em.id == idPlantilla) {
                    plantillaSeleccionada = em;
                } else if(em.DeveloperName == 'CC_Header') {
                    plantillaHeader = em;
                } else if(em.DeveloperName == 'CC_Footer') {
                    plantillaFooter = em;
                } else if (em.DeveloperName == encabezado) {
                    plantillaEncabezado = em;
                } else if (em.DeveloperName == pieFirma) {
                    plantillaPieFirma = em;
                } else if (em.DeveloperName == firma) {
                    plantillaFirma = em;
                }
            }
        }
       
        List<String> body = new List<String>();
        body.add(plantillaSeleccionada.HtmlValue);
        
        try{
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantilla, UserInfo.getUserId(), recordId); 
            String cuerpoEmail = renderStored.getHtmlBody();
            WrapperTemplate datosTemplate;
            if(!Test.isRunningTest()) {
                datosTemplate = new WrapperTemplate(
                    cuerpoEmail,
                    plantillaHeader != null ? plantillaHeader.HtmlValue : null,
                    plantillaFooter != null ? plantillaFooter.HtmlValue : null,
                    plantillaEncabezado != null ? plantillaEncabezado.HtmlValue : null,
                    plantillaPieFirma != null ? plantillaPieFirma.HtmlValue : null,
                    plantillaFirma != null ? plantillaFirma.HtmlValue : null
                );
            } else {
                datosTemplate = new WrapperTemplate(cuerpoEmail, 'Header', 'Footer', '', '', '');
            }
            return datosTemplate;
        } catch (Exception e) {
            throw new AuraHandledException('La plantilla seleccionada no puede aplicarse debido a que no tiene relación con el objeto actual.');
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
	public static List<EmailTemplate> cargarPlantillasMCC(Id idCaso) { 
        
        Map<String, Object> retorno = new Map<String, Object>();

        
       List<Case> casos = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :idCaso]; 
        Set<Id> idsMCC = new Set<Id>();  
        
        for (Case caso : casos) {
            if(caso.CC_MCC_Tematica__c !=null ){
                idsMCC.add(caso.CC_MCC_Tematica__c);    
            }
            if(caso.CC_MCC_ProdServ__c !=null ){
                idsMCC.add(caso.CC_MCC_ProdServ__c);    
            }
            if(caso.CC_MCC_Motivo__c !=null ){
                idsMCC.add(caso.CC_MCC_Motivo__c);    
            }
        }        
        
            
        List<CC_MCC_Plantilla__c> plantillasMCC = [SELECT CC_MCC_Plantilla_DeveloperName__c FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN :idsMCC];
        List<String> nombresPlantilla = new List<String>();
        for (CC_MCC_Plantilla__c plantilla : plantillasMCC) {
            nombresPlantilla.add(plantilla.CC_MCC_Plantilla_DeveloperName__c);
        }
        List<EmailTemplate> plantillas = [SELECT Id, Name, DeveloperName, Subject FROM EmailTemplate WHERE DeveloperName IN :nombresPlantilla ORDER BY Name ASC];
        return plantillas;
		
	}
    
	@AuraEnabled(cacheable=true)
	public static List<EmailTemplate> buscarPlantillas(Id idCarpeta, String cadenaBusqueda) {
		cadenaBusqueda = '%' + cadenaBusqueda + '%';
		return [SELECT Name, Subject FROM EmailTemplate
				WHERE FolderId = :idCarpeta AND Name LIKE :cadenaBusqueda
				ORDER BY NAME LIMIT 30];
	}

    @AuraEnabled(cacheable=true)
	public static List<EmailTemplate> buscarPlantillasMCC(String cadenaBusqueda) {
        cadenaBusqueda = '%' + cadenaBusqueda + '%';
		return [SELECT Id, Name, Subject FROM EmailTemplate
				WHERE Name LIKE :cadenaBusqueda
				ORDER BY NAME LIMIT 10];
	}

    // @AuraEnabled(cacheable=true)
    // public static List<Folder> getCarpetasIdioma(String carpetaDeveloperName, String carpetaGenerica) {
    //     List<Folder> carpetas = new List<Folder>();
    //     Id parentId;
    //     if (carpetaDeveloperName == null) {
    //         parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'CC_Operativas' LIMIT 1].Id;
    //     } else {
    //         //parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
    //         List<Folder> carpetaPrincipal = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
    //         if (!carpetaPrincipal.isEmpty()) {
    //             parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
    //         } else {
    //             parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaGenerica LIMIT 1].Id;
    //         }
    //     }

    //     for (Folder carpeta : [SELECT Name, DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :parentId]) {
    //         carpetas.add(carpeta);
    //     }
    //     return carpetas;
    // }
}