public with sharing class CSBD_MetodosComunes {

    public static Boolean externalizarCmnComdata(String idProducto) {
        return ([SELECT Count() FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: CMN - Productos gestionados externamente'
                AND Name = :idProducto AND CC_Valor__c = 'Comdata' AND CC_Activa__c = true] > 0);
    }

    public static Boolean externalizarCmnPorCorreo(String codigoCampanya) {
        return ([SELECT Count() FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se externalizan por correo'
            AND CC_Valor__c = :codigoCampanya AND CC_Activa__c = true] > 0);
    }

    public static Boolean redirigirCmnCajeosAAltaOportunidad(String codigoCampanya) {
        return ([SELECT Count() FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se reenvían a AltaOportunidad'
            AND CC_Valor__c = :codigoCampanya AND CC_Activa__c = true] > 0);
    }

    public static void traducirTipoCampanyaAProductoProceso(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud) {
        if (solicitud?.tipoCampanya != null) {
            List<CC_Lista_Valores__c> traduccionesTipoCampanyaAProducto = [SELECT CC_Valor__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
                                                                            WHERE CC_Lista__r.Name = 'CSBD: Entrada CMN Cajeros - Relación CodigoCampanya a idProducto AltaOportunidad'
                                                                            AND Name = :solicitud.tipoCampanya AND CC_Activa__c = true LIMIT 1];
            if (!traduccionesTipoCampanyaAProducto.isEmpty()) {
                solicitud.idProducto = traduccionesTipoCampanyaAProducto[0].CC_Valor__c;
                solicitud.proceso = traduccionesTipoCampanyaAProducto[0].CC_Valor__c;
            }
        }
    }

    public static Boolean enviarCorreoCmn(Id idOportunidad) {
        Boolean envioOK = false;

        List<String> destinatarios = new List<String>();
        for (CC_Lista_Valores__c valor : [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Activa__c = true
                                            AND CC_Lista__r.Name = 'CSBD: Entrada CMN Cajeros - Destinatarios de la externalización por correo']) {
            destinatarios.add(valor.CC_Valor__c);
        }

        List<CC_Parametros__mdt> parametroMail = [SELECT Valor_Texto__c FROM CC_Parametros__mdt WHERE DeveloperName = 'CSBD_Plantilla_RS8_CMN'
                                                    AND Nombre__c = 'CSBD_Plantilla_RS8_CMN' AND CC_Activo__c = true];

        if (!parametroMail.isEmpty() && !destinatarios.isEmpty()) {
            Messaging.SendEmailResult resultadoEnvioCorreo = enviarCorreo(idOportunidad, 'CSBD - CaixaBank Informa', parametroMail[0].Valor_Texto__c, destinatarios);
            if (resultadoEnvioCorreo != null && resultadoEnvioCorreo.isSuccess()) {
                envioOK = true;
            }
        }
        return envioOK;
    }

    public static Boolean esFlujoVidaCaixa(String nombreProducto) {
        return [SELECT Count() FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: Desistimientos - Productos gestionados externamente'
                AND Name = :nombreProducto AND CC_Activa__c = true] > 0;
    }

    public static Messaging.SendEmailResult enviarCorreoDesistimientoVidaCaixa(Id idOportunidad, String codigoProducto) {
        List<CC_Lista_Valores__c> valores = [SELECT CC_Valor__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
                                                WHERE CC_Lista__r.Name = 'CSBD_RS8_EMAIL_DESIS'
                                                AND Name = :codigoProducto AND CC_Activa__c = TRUE LIMIT 1];
        if (valores.size() == 1) {
            return enviarCorreo(idOportunidad, 'CSBD - CaixaBank Informa', valores[0].CC_Valor_SFDC__c, new List<String>{valores[0].CC_Valor__c});
        } else {
            return null;
        }
    }

    public static Account correoIdiomaOficina(Id idOficina) {
        List<Account> oficinas = [SELECT CC_Email__c, CC_Idioma_Oficina__c FROM Account WHERE Id = :idOficina];
        return !oficinas.isEmpty() ? oficinas[0] : null;
    }

    public static Messaging.SendEmailResult enviarCorreo(Id whatId, String nombreBuzonSalida, String nombrePlantilla, List<String> destinatarios, Boolean buscarPorEmpresa) {
        if (String.isBlank(nombreBuzonSalida) || String.isBlank(nombrePlantilla)) {
            return null;
        } else {
            Id idBuzonSalida;
            if (buscarPorEmpresa) {
                //el nombreBuzonSalida es el nombre de la empresa proveedora
                idBuzonSalida = obtenerIdBuzonSalida(nombreBuzonSalida);
            } else {
                //el nombreBuzonSalida es el nombre del buzon de salida
                idBuzonSalida = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :nombreBuzonSalida].Id;
            }
            if (idBuzonSalida == null) {
                return null;
            }
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            correo.setToAddresses(destinatarios);
            correo.setTemplateId([SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1].Id);
            List<Opportunity> contactoOportunidad = [SELECT CSBD_Contact__c FROM Opportunity WHERE Id =: whatId LIMIT 1];
            Id contactId;
            if(!contactoOportunidad.isEmpty() && contactoOportunidad[0].CSBD_Contact__c != null) {
                contactId = contactoOportunidad[0].CSBD_Contact__c;
            }
            else {
                contactId = [SELECT Id FROM Contact WHERE Email != NULL LIMIT 1].Id;
            }
            correo.setTargetObjectId(contactId);
            correo.setSaveAsActivity(true);
            correo.setTreatTargetObjectAsRecipient(false);
            correo.setWhatId(whatId);
            correo.setOrgWideEmailAddressId(idBuzonSalida);
            List<Messaging.SendEmailResult> resultadoEnvios = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
            return resultadoEnvios[0];
        }
    }

    public static Messaging.SendEmailResult enviarCorreo(Id whatId, String nombreBuzonSalida, String nombrePlantilla, List<String> destinatarios) {
        return enviarCorreo(whatId, nombreBuzonSalida, nombrePlantilla, destinatarios, false);
    }

    public static Messaging.SingleEmailMessage enviarCorreoReturnCorreo(Messaging.SingleEmailMessage correo, Id whatId, Id contactId, Id idBuzonSalida, String idPlantilla, List<String> destinatarios) {
        correo.setToAddresses(destinatarios);
        correo.setTemplateId(idPlantilla);
        correo.setTargetObjectId(contactId ?? [SELECT Id FROM Contact LIMIT 1].Id);
        correo.setSaveAsActivity(true);
        correo.setTreatTargetObjectAsRecipient(false);
        correo.setWhatId(whatId);
        correo.setOrgWideEmailAddressId(idBuzonSalida);
        return correo;
    }

    public static String buscarCentro(Opportunity oportunidad, String numeroGestor){
		String centro = '';
    Boolean gestorPool = false; 
		if(!String.isBlank(numeroGestor)){        
			if(comprobarGestor(numeroGestor)){
				centro = obtenerCentroPool(oportunidad);
			}else{
				centro = obtenerCentroNoPool(oportunidad);
			}
		}else{
			centro = obtenerCentroNoPool(oportunidad);
		}    
		return centro;
	}

	public static String obtenerCentroPool(Opportunity oportunidad){
		String centro = 
		oportunidad.Account.AV_OfficeManager__r.CC_Numero_Oficina__c != null ? 
		oportunidad.Account.AV_OfficeManager__r.CC_Numero_Oficina__c  : 
		getCentroGenerico();
		return centro;
	}

	public static String obtenerCentroNoPool(Opportunity oportunidad){
		String centro = 
		oportunidad.Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c != null ? 
		oportunidad.Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c  : 
		oportunidad.Account.AV_OficinaPrincipal__r?.CC_Numero_Oficina__c;
		return centro;
	}

    public static String getCentroGenerico(){
        String centroDefault = '';
        List<CC_Lista_Valores__c> centrosDefault = [
            SELECT CC_Activa__c, CC_Valor__c, Name 
            FROM CC_Lista_Valores__c 
            WHERE RecordType.DeveloperName = 'CC_Valor'
            AND CC_Lista__r.Name = 'Gestion Oficinas del Pool' 
            AND Name = 'Centro Genérico'
        ];

        if(!centrosDefault.isEmpty()){
            centroDefault = centrosDefault[0].CC_Valor__c;
        }
        return centroDefault;       
    }

	public static Boolean comprobarGestor(String numeroGestor){
		Boolean esGestorPool = false; 
		try{
            //buscar si el gestor es de un pool
            List<AV_MultiEmployees__mdt> gestoresPool = [ 
                SELECT AV_Alias__c
                FROM AV_MultiEmployees__mdt 
                ORDER BY AV_Alias__c
            ];
            for(AV_MultiEmployees__mdt gestor : gestoresPool){
                String aliasU01 = 'U01' + gestor.AV_Alias__c;
                if(aliasU01 == numeroGestor){
                    esGestorPool = true;
                    break;
                }
            }
	
		}catch(Exception e){
			CBK_Log.error('Error al comprobar si la matrícula es de un gestor del Pool: ' + e.getMessage());
		}
        return esGestorPool;
	}

    public static Id obtenerIdBuzonSalida(String empresaProveedora) {
        return obtenerIdBuzonSalida(empresaProveedora, null);
    }

    public static String obtenerIdBuzonSalida(String empresaProveedora, String familiaProducto) {
        CSBD_Remitente_Enviar_Correo__c config = CSBD_Remitente_Enviar_Correo__c.getInstance();
        if(config != null){
            String address = 
                familiaProducto != null && familiaProducto == 'Alta digital de menores' ? config.CSBD_Buzon_Alta_digital_de_menores__c : 
                empresaProveedora == 'imaginBank' ? config.CSBD_Buzon_ImaginBank__c : config.CSBD_Buzon_CaixaBank__c;
            return [SELECT Id FROM OrgWideEmailAddress WHERE Address = :address]?.Id;            
        } 
        return null;
    }
}