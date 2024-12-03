public without sharing class SAC_Utils {
    
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
                    when 'Account' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName());
                    }
                    when 'Contact' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName());
                    }
                    when 'Task' {
                        mapObjectRT.put(objeto,Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName());
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
                    when 'SAC_Alerta__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Alerta__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_Antecedentes__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_AdjuntoAntecedente__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_AdjuntoAntecedente__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_DocumentoEnvio__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_DocumentoEnvio__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_Interaccion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_MaestroAccionesReclamacion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_MaestroTemas__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_Marca_Case__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_Marca_Case__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_ParametrizacionSLATME__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_ParametrizacionEscalado__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_ParametrizacionEscalado__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_PlantillaRedaccion__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_CaseReclamante__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_CaseReclamante__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_TiempoEstados__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_TiempoEstados__c.getRecordTypeInfosByDeveloperName());
                    }
                    when 'SAC_TMECaso__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName());
                    }
					when 'SEG_Auditoria__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName());
                    }
					when 'SAC_ImagenDocumento__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.SAC_ImagenDocumento__c.getRecordTypeInfosByDeveloperName());
                    }
					when 'CC_Caracteristica__c' {
                        mapObjectRT.put(objeto,Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName());
                    }
                    when else {
                        mapObjectRT.put(objeto,Schema.getGlobalDescribe().get(objeto).getDescribe().getRecordTypeInfosByDeveloperName());
                    }
                }
            }
        }
        return mapObjectRT;
    }
    
    /**
    Wrapper para retornar datos de las reglas de clasificación
    */
    public class WrapperReglaClasificacion{
        public Id id{get; set;}
        public String estado{get; set;}
        public String motivoRechazo{get; set;}
		public String motivoDescarte{get; set;}
    }
    

    /*
    Recuperar configuración integración CUSTOM METADATO con Body petición.
    */
    static public CC_InterfaceSettings__mdt getInterfazConfigBody(String sInterfaz) {
        List<CC_InterfaceSettings__mdt> oConfig = [SELECT CC_Certificado__c, CC_EndPoint__c, CC_Body__c, CC_TimeOut__c, CC_TipoPeticion__c, CC_Activa__c, CC_ContentType__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz AND CC_Activa__c = true];
        if (oConfig.size() == 1 && oConfig[0] != null) {
            return oConfig[0];
        } else {
            return null;
        }
    }

    /**
    Convert the long number to hexadecimal number
    */
    public static String convertToHexadecimal(Long num){
        integer rem;
        String str2='';
        String[] hex=new String[]{'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
        while(num>0){
            rem=(integer)Math.mod(num, 16);
            str2=hex[rem]+str2;
            num=num/16;
        }
        return str2;
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
    Método para insertar trazas
    */
    @future(callout=true)
	public static void insertTrazas(String jsonTrazas){

        if(jsonTrazas != null){
        	List<CC_TrazaInt__c> lstTrazas = (List<CC_TrazaInt__c>)Json.deserialize(jsonTrazas,List<CC_TrazaInt__c>.class);
			SAC_DatabaseDML.insertListDML(lstTrazas, false);
        }
        
    }

	/**
    Método para updatear casos
    */
    @future(callout=true)
	public static void updateCase(String jsonCase){

        if(jsonCase != null){
        	List<Case> lstCase = (List<Case>)Json.deserialize(jsonCase,List<Case>.class);
			SAC_DatabaseDML.updateListDML(lstCase, false);
        }
        
    }

	/**
    Método para updatear interaccion
    */
    @future(callout=true)
	public static void updateInteraccion(String jsonInteraccion){
        if(jsonInteraccion != null){
        	List<SAC_Interaccion__c> lstInteraccion = (List<SAC_Interaccion__c>)Json.deserialize(jsonInteraccion,List<SAC_Interaccion__c>.class);
			List<SAC_Interaccion__c> lstInteraccionUpdate = new List<SAC_Interaccion__c>();

			for(SAC_Interaccion__c interaccion : lstInteraccion){
                if(interaccion.SAC_Respuesta__c.length() > 32767){
					String texto = interaccion.SAC_Respuesta__c;
					interaccion.SAC_Respuesta__c = texto.left(32767);
					lstInteraccionUpdate.add(interaccion);
				}else{
					lstInteraccionUpdate.add(interaccion);
				}
            }
			SAC_DatabaseDML.updateListDML(lstInteraccionUpdate, false);
        }
    }

	/**
    Método para updatear alertas
    */
    @future(callout=true)
	public static void updateAlerta(String jsonAccion){

        if(jsonAccion != null){
        	List<SAC_Accion__c> lstAccion = (List<SAC_Accion__c>)Json.deserialize(jsonAccion,List<SAC_Accion__c>.class);
			SAC_DatabaseDML.updateListDML(lstAccion, false);
        }
        
    }

	/**
    Método para recuperar el developer name de un record type mediante la Id
    */
	public static String getRecordTypeDevNameById(String objectName, Id strRecordTypeId){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getDeveloperName();
    }

	/** Métodos EmailService */
    /**
    Método para determinar la clasificación rápida que se debe asignar al caso cuando entra por email 
    */
    public static WrapperReglaClasificacion determinarCR(String fromAddress, List<String> toAddresses, List<String> ccAddresses, String subject, String body, String recordTypeId)
	{
		//en base a los datos del correo  se busca la regla de clasificación pertinente
        WrapperReglaClasificacion wrapRCRetornar = new WrapperReglaClasificacion();
		String remitenteUC = fromAddress.toUpperCase();
		String asuntoUC = subject.toUpperCase();
		String cuerpoUC = body.toUpperCase();
		String destinatariosUC = toAddresses?.toString().toUpperCase();
		String destinatariosCcUc = ccAddresses?.toString().toUpperCase();
		// Map<Id,id> clasificacionRapidaMap = new Map<id,id>();
		// Map<Id,id> clasificacionRapidaMapV2 = new Map<id,id>();
		// List<Id> clasificacionRapida = new List<Id> ();
		// //JAV ELIMINAR CR DUPLICADAS
		// List<Id> crSinDUPlst = new List<Id> ();
		// Set<Id> crIdset = new Set<Id>();

		//V2: Con MAP de Regla de clasificación y lista de multivalor
		Map<Id, Id> reglasClasificacionIds = new Map<Id, Id> ();
        Map<Id, List<SEG_Multivalor__c>> mapaRCMVEncontrados = new Map<Id, List<SEG_Multivalor__c>> ();
        Map<Id, List<SEG_Multivalor__c>> mapaRCMVTotal = new Map<Id, List<SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorRemitentesIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorAsuntosIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorCuerposIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		// Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioCCIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, WrapperReglaClasificacion> mapaRCWrapper = new Map<Id, WrapperReglaClasificacion> ();
        //mapas exclusiones
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorRemitentesExcluir= new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorAsuntosExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorCuerposExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioCCExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
		//Recuperar el developerName del recordTypeId
		String targetCR = getRecordTypeDevNameById('Case', recordTypeId);

		for (SEG_Multivalor__c obj :[SELECT id, SEG_Reglas_Clasificacion__c, SEG_TipodeValor__c, SEG_Valor__c, SEG_ReglaInactiva__c, SEG_Reglas_Clasificacion__r.OS_Logica_Multivalor__c,
                                    SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.OS_EstadoCaso__c, SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.SAC_MotivoRechazo__c,
									SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.SAC_MotivoDescarte__c
                                    FROM SEG_Multivalor__c 
                                    WHERE SEG_ReglaInactiva__c = false AND SEG_CRInactiva__c = false AND SEG_Reglas_Clasificacion__c <> '' AND SEG_Reglas_Clasificacion__r.CBK_Negocio__c = 'SAC' 
									AND SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.SAC_Target__c = :targetCR
                                    ORDER BY SEG_Reglas_Clasificacion__r.OS_OrdenEjecucion__c ASC])
		{
            //Añadir regla de clasificacion a mapa con id regla de clasificación y valor wrapper con los valores de la regla que necesitemos (para evitar querys a reglas de clasificación y clasificación rapida)
            WrapperReglaClasificacion wrapRC = new WrapperReglaClasificacion();
            wrapRC.id = obj.SEG_Reglas_Clasificacion__c;
            if (String.isNotBlank(obj.SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.OS_EstadoCaso__c)) {
                wrapRC.estado = obj.SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.OS_EstadoCaso__c;    
            }
            if (String.isNotBlank(obj.SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.SAC_MotivoRechazo__c)) {
                wrapRC.motivoRechazo = obj.SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.SAC_MotivoRechazo__c;
            }
			if (String.isNotBlank(obj.SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.SAC_MotivoDescarte__c)) {
				wrapRC.motivoDescarte = obj.SEG_Reglas_Clasificacion__r.SEG_ClasificacionRapida__r.SAC_MotivoDescarte__c;
			}
            mapaRCWrapper.put(obj.SEG_Reglas_Clasificacion__c, wrapRC);
            //Añadir multivalor al mapa de multivalores totales por cada regla de clasificacion (sin añadir las exclusiones)
            if (!obj.SEG_TipodeValor__c.contains('excluir')) {
                if (mapaRCMVTotal.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    mapaRCMVTotal.get(obj.SEG_Reglas_Clasificacion__c).add(obj);
                } else {
                    List<SEG_Multivalor__c> listaMultivalores = new List<SEG_Multivalor__c>();
                    listaMultivalores.add(obj);
                    mapaRCMVTotal.put(obj.SEG_Reglas_Clasificacion__c, listaMultivalores);
                }
            }
            
			if (obj.SEG_TipodeValor__c == 'Remitente' && String.isNotBlank(obj.SEG_Valor__c))
			{
				reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);
				if (maplistOfMultivalorRemitentesIncluir.size() == 0 || (!maplistOfMultivalorRemitentesIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorRemitentesIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorRemitentesIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorRemitentesIncluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorRemitentesIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			else if (obj.SEG_TipodeValor__c == 'Asunto' && String.isNotBlank(obj.SEG_Valor__c)) {
				reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);
				if (maplistOfMultivalorAsuntosIncluir.size() == 0 || (!maplistOfMultivalorAsuntosIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorAsuntosIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorAsuntosIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorAsuntosIncluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorAsuntosIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			else if (obj.SEG_TipodeValor__c == 'Cuerpo' && String.isNotBlank(obj.SEG_Valor__c)) {
				reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);
				if (maplistOfMultivalorCuerposIncluir.size() == 0 || (!maplistOfMultivalorCuerposIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorCuerposIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorCuerposIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorCuerposIncluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorCuerposIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			// Desarrollo a futuro. NO INCLUIR
			else if (obj.SEG_TipodeValor__c == 'Destinatario' && String.isNotBlank(obj.SEG_Valor__c)){
				reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);
				if (maplistOfMultivalorDestinatarioIncluir.size() == 0 || (!maplistOfMultivalorDestinatarioIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorDestinatarioIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorDestinatarioIncluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			else if (obj.SEG_TipodeValor__c == 'Destinatario CC' && String.isNotBlank(obj.SEG_Valor__c)){
				reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);
				if (maplistOfMultivalorDestinatarioCCIncluir.size() == 0 || (!maplistOfMultivalorDestinatarioCCIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioCCIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorDestinatarioCCIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))
				{
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorDestinatarioCCIncluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioCCIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
            //Exclusiones
            else if (obj.SEG_TipodeValor__c == 'Remitente a excluir' && String.isNotBlank(obj.SEG_Valor__c)){
				if (maplistOfMultivalorRemitentesExcluir.size() == 0 || (!maplistOfMultivalorRemitentesExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c))){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorRemitentesExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorRemitentesExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c)){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorRemitentesExcluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorRemitentesExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			else if (obj.SEG_TipodeValor__c == 'Asunto a excluir' && String.isNotBlank(obj.SEG_Valor__c)){
				if (maplistOfMultivalorAsuntosExcluir.size() == 0 || (!maplistOfMultivalorAsuntosExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c))){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorAsuntosExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorAsuntosExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c)){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorAsuntosExcluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorAsuntosExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			else if (obj.SEG_TipodeValor__c == 'Cuerpo a excluir' && String.isNotBlank(obj.SEG_Valor__c)){
				if (maplistOfMultivalorCuerposExcluir.size() == 0 || (!maplistOfMultivalorCuerposExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c))){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorCuerposExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorCuerposExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c)){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorCuerposExcluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorCuerposExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			else if (obj.SEG_TipodeValor__c == 'Destinatario a excluir' && String.isNotBlank(obj.SEG_Valor__c)){
				if (maplistOfMultivalorDestinatarioExcluir.size() == 0 || (!maplistOfMultivalorDestinatarioExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c))){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorDestinatarioExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c)){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorDestinatarioExcluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
			else if (obj.SEG_TipodeValor__c == 'Destinatario CC a excluir' && String.isNotBlank(obj.SEG_Valor__c)){
				if (maplistOfMultivalorDestinatarioCCExcluir.size() == 0 || (!maplistOfMultivalorRemitentesExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c))){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioCCExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
				else if (maplistOfMultivalorDestinatarioCCExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c)){
					Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
					listMV = maplistOfMultivalorDestinatarioCCExcluir.get(obj.SEG_Reglas_Clasificacion__c);
					listMV.put(obj.SEG_Valor__c, obj);
					maplistOfMultivalorDestinatarioCCExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
				}
			}
		}

		//V2: Comparamos los Asuntos Cuerpos y Remitentes
		for (Id target : reglasClasificacionIds.values())
		{
			//por cada iteración instanciamos Listas de Remitentes, Asuntos y Cuerpos
			Map<String, SEG_Multivalor__c> listRemitentes = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listAsuntos = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listCuerpos = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listDestinatarios = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listDestinatariosCC = new Map<String, SEG_Multivalor__c> ();
            //mapas excluir
            Map<String, SEG_Multivalor__c> listRemitentesExcluir = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listAsuntosExcluir = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listCuerposExcluir = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listDestinatariosExcluir = new Map<String, SEG_Multivalor__c> ();
			Map<String, SEG_Multivalor__c> listDestinatariosCCExcluir = new Map<String, SEG_Multivalor__c> ();

			if (maplistOfMultivalorRemitentesIncluir.containsKey(target)){
				listRemitentes = maplistOfMultivalorRemitentesIncluir.get(target);			
			}
			if (maplistOfMultivalorAsuntosIncluir.containsKey(target)){
				listAsuntos = maplistOfMultivalorAsuntosIncluir.get(target);
			}
			if (maplistOfMultivalorCuerposIncluir.containsKey(target)){
				listCuerpos = maplistOfMultivalorCuerposIncluir.get(target);
			}
			if (maplistOfMultivalorDestinatarioIncluir.containsKey(target)){
				listDestinatarios = maplistOfMultivalorDestinatarioIncluir.get(target);
			}
			if (maplistOfMultivalorDestinatarioCCIncluir.containsKey(target)){
				listDestinatariosCC = maplistOfMultivalorDestinatarioCCIncluir.get(target);
			}
			if (maplistOfMultivalorRemitentesExcluir.containsKey(target)){
				listRemitentesExcluir = maplistOfMultivalorRemitentesExcluir.get(target);			
			}
			if (maplistOfMultivalorAsuntosExcluir.containsKey(target)){
				listAsuntosExcluir = maplistOfMultivalorAsuntosExcluir.get(target);
			}
			if (maplistOfMultivalorCuerposExcluir.containsKey(target)){
				listCuerposExcluir = maplistOfMultivalorCuerposExcluir.get(target);
			}
			if (maplistOfMultivalorDestinatarioExcluir.containsKey(target)){
				listDestinatariosExcluir = maplistOfMultivalorDestinatarioExcluir.get(target);
			}
			if (maplistOfMultivalorDestinatarioCCExcluir.containsKey(target)){
				listDestinatariosCCExcluir= maplistOfMultivalorDestinatarioCCExcluir.get(target);
			}

			//TODO: FALTA EL *
			//posibles valores--> 0: no configurado | 1:configurado y encontrado | 2.configurado y no encontrado
			//Exclusiones
			integer exclusion = 0;

            integer totalEncontrados = 0;

			for (String valor : listRemitentes.KeySet())
			{
				if (remitenteUC.contains(valor.toUpperCase()) || valor == '*') {
                    //Rellenar mapa con los multivalores que se estan encontrando con key regla de clasificación padre
                    mapaRCMVEncontrados = rellenarMapaMVEncontrados(mapaRCMVEncontrados, listRemitentes.get(valor));
					totalEncontrados++;
				}
				
			}
			for (String valor : listAsuntos.KeySet())
			{
				if (asuntoUC.contains(valor.toUpperCase()) || valor == '*') {
                    //Rellenar mapa con los multivalores que se estan encontrando con key regla de clasificación padre
                    mapaRCMVEncontrados = rellenarMapaMVEncontrados(mapaRCMVEncontrados, listAsuntos.get(valor));
					totalEncontrados++;
				}
			}
			for (String valor : listCuerpos.KeySet())
			{
				if (cuerpoUC.contains(valor.toUpperCase()) || valor == '*') {
                    //Rellenar mapa con los multivalores que se estan encontrando con key regla de clasificación padre
                    mapaRCMVEncontrados = rellenarMapaMVEncontrados(mapaRCMVEncontrados, listCuerpos.get(valor));
					totalEncontrados++;
				}
			}
			for (String valor : listDestinatarios.KeySet())
			{
				if ( destinatariosUc != null){
					if (destinatariosUC.contains(valor.toUpperCase()) || valor == '*') {
                        //Rellenar mapa con los multivalores que se estan encontrando con key regla de clasificación padre
                        mapaRCMVEncontrados = rellenarMapaMVEncontrados(mapaRCMVEncontrados, listDestinatarios.get(valor));
						totalEncontrados++;
					}
				}
			}
			for (String valor : listDestinatariosCC.KeySet())
			{
				if ( destinatariosCcUc != null){
					if (destinatariosCcUc.contains(valor.toUpperCase()) || valor == '*') {
                        //Rellenar mapa con los multivalores que se estan encontrando con key regla de clasificación padre
                        mapaRCMVEncontrados = rellenarMapaMVEncontrados(mapaRCMVEncontrados, listDestinatariosCC.get(valor));
						totalEncontrados++;
					}
				}
			}

            //Exclusiones
            for (String valor : listAsuntosExcluir.KeySet()){
				if (asuntoUC.contains(valor.toUpperCase())) {
					exclusion = 1;
					break;
				}
			}
			for (String valor : listCuerposExcluir.KeySet()){
				if (cuerpoUC.contains(valor.toUpperCase())) {
					exclusion = 1;
					break;
				}
			}
			for (String valor : listRemitentesExcluir.KeySet()){
				if (remitenteUC.contains(valor.toUpperCase())) {
					exclusion = 1;
					break;
				}
			}
			for (String valor : listDestinatariosExcluir.KeySet()){
				if (destinatariosUC != null ){
					if (destinatariosUC.contains(valor.toUpperCase())){
						exclusion = 1;
						break;
					}
				}
			}
			for (String valor : listDestinatariosCCExcluir.KeySet()){
				if (destinatariosCcUc != null ){
					if (destinatariosCcUc.contains(valor.toUpperCase())){
						exclusion = 1;
						break;
					}
				}
			}

            /*
            SAC
            Las reglas estan ordenadas por orden de ejecución.
            Si la regla tiene en el campo lógica de ejecución un OR, significa que es la regla que nos quedamos (ya que se cumple por lo menos uno de sus valores).
            Si la regla tiene en el campo lógica de ejecución un AND, significa que hay que comprobar que se cumplan todos los multivalores de esa regla.
            */
            //Si el mapa de multivalores que se cumplen tiene una logica de OR, significa que esta es la regla que queremos que se cumpla (si no contiene una explusión)
            if (mapaRCWrapper.containsKey(target) && mapaRCMVEncontrados.containsKey(target) && mapaRCMVEncontrados.get(target)[0].SEG_Reglas_Clasificacion__r.OS_Logica_Multivalor__c == 'OR' && exclusion != 1) {
                wrapRCRetornar = mapaRCWrapper.get(target);
            //Si el mapa de multivalores que se cumplen tiene una logica de AND, y es igual que el de multivalores en total, significa que se cumplen todos y por tanto esta es la regla que queremos que se cumpla
            } else if (mapaRCWrapper.containsKey(target) && mapaRCMVEncontrados.containsKey(target) && mapaRCMVEncontrados.get(target)[0].SEG_Reglas_Clasificacion__r.OS_Logica_Multivalor__c == 'AND'
                       && totalEncontrados == mapaRCMVTotal.get(target).size() && exclusion != 1) {
                wrapRCRetornar = mapaRCWrapper.get(target);
            }
            //Si la lista a retornar ya contiene la regla de clasificación que queremos que se cumpla, salimos del bucle
            if (String.isNotBlank(wrapRCRetornar.id)) {
                break;
            }
		}

        return wrapRCRetornar;
	}
    
    /**
    Método para rellenar mapa con multivalores por cada regla de clasificación 
    */
    private static Map<Id, List<SEG_Multivalor__c>> rellenarMapaMVEncontrados(Map<Id, List<SEG_Multivalor__c>> mapaRCMVEncontrados, SEG_Multivalor__c multiValor) {
        //Rellenar mapa con los multivalores que se estan encontrando con key regla de clasificación padre
        if (mapaRCMVEncontrados.containsKey(multiValor.SEG_Reglas_Clasificacion__c)) {
            mapaRCMVEncontrados.get(multiValor.SEG_Reglas_Clasificacion__c).add(multiValor);
        } else {
            List<SEG_Multivalor__c> listaMVEncontrados = new List<SEG_Multivalor__c>();
            listaMVEncontrados.add(multiValor);
            mapaRCMVEncontrados.put(multiValor.SEG_Reglas_Clasificacion__c, listaMVEncontrados);
        }

        return mapaRCMVEncontrados;
    }

	/**
	 * Método para recuperar el custom setting del email entrante
	 */
    public static SAC_EmailService__c comprobarCustomSettings(Messaging.InboundEmail email, String recordTypeDeveloperName) {
        //Obtenemos la parametrización correspondiente a este caso del Custom Metadata Type correspondiente
        List<SAC_EmailService__c> customSetting = SAC_EmailService__c.getAll().values();
        SAC_EmailService__c parametrizacion;
        for(SAC_EmailService__c paramAux : customSetting){
            if(((email.ccAddresses != null && email.ccAddresses.contains(paramAux.SAC_EmailEntrante__c)) || (email.toAddresses != null && email.toAddresses.contains(paramAux.SAC_EmailEntrante__c)))
                && String.isNotBlank(paramAux.SAC_RecordTypeDeveloperName__c) && paramAux.SAC_RecordTypeDeveloperName__c == recordTypeDeveloperName){
                parametrizacion = paramAux;
            }
            else{
                for(Messaging.InboundEmail.Header header : email.headers){
                    if(header.value.contains(paramAux.SAC_EmailEntrante__c) && String.isNotBlank(paramAux.SAC_RecordTypeDeveloperName__c) && paramAux.SAC_RecordTypeDeveloperName__c == recordTypeDeveloperName){
                        parametrizacion = parametrizacion;
                    }
                }
            }
        }

        return parametrizacion;
    }

	/**
	 * Método para asignar los valores que debe llevar el caso a crear cuando entra un email
	 */
	public static Case prepararCasosNuevos(SAC_EmailService__c parametrizacion, Map<String, Id> mapaGruposIds, Messaging.InboundEmail email, QueueSobject cola, String recordTypeId) {

		Case casoNuevo = new Case();
        if (parametrizacion != null && String.isNotBlank(parametrizacion.SAC_Naturaleza__c)) {
            casoNuevo.SAC_Naturaleza__c = parametrizacion.SAC_Naturaleza__c;
        }
        if(parametrizacion != null && String.isNotBlank(parametrizacion.SAC_GroupName__c) && mapaGruposIds.containsKey(parametrizacion.SAC_GroupName__c)){
            casoNuevo.SEG_Grupo__c = mapaGruposIds.get(parametrizacion.SAC_GroupName__c);
        }
        //Se pone el record type introducido por parametro de primeras, por si en el custom setting no estuviera relleno
        casoNuevo.RecordTypeId = recordTypeId;
        if(parametrizacion != null && String.isNotBlank(parametrizacion.SAC_RecordTypeDeveloperName__c)){
			casoNuevo.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(parametrizacion.SAC_RecordTypeDeveloperName__c).getRecordTypeId();
        }
		//Añadido US777526 (identificar si la reclamación es money to pay)
		if(parametrizacion != null && parametrizacion.SAC_M2P__c){
			casoNuevo.SAC_M2P__c = true;
        }
		//Fin añadido US777526
        //Subject recortado y sin etiquetas html
        String subjectRecortado = '';
        if (String.isNotBlank(email.subject)) {
            subjectRecortado = email.subject.left(255).stripHtmlTags();
        }
        casoNuevo.Priority = 'Medium';
        casoNuevo.Origin = 'Email';
        casoNuevo.SuppliedEmail = email.fromAddress;

		if(!email.toAddresses.isEmpty()){
			String direccionesToEmailStr = '';
			Boolean variasDirecciones = false;

			for(String direccion : email.toAddresses){

				if(!variasDirecciones){
					direccionesToEmailStr = direccion;
					variasDirecciones = true;
				}else{
					direccionesToEmailStr = direccionesToEmailStr + ';' + direccion; 
				}
			}
			casoNuevo.SAC_EmailTo__c = direccionesToEmailStr;
		}

		if(email.ccAddresses != null){
			String direccionesCCEmailStr = '';
			Boolean variasDirecciones = false;

			for(String direccion : email.ccAddresses){

				if(!variasDirecciones){
					direccionesCCEmailStr = direccion;
					variasDirecciones = true;
				}else{
					direccionesCCEmailStr = direccionesCCEmailStr + ';' + direccion; 
				}
			}
			casoNuevo.SAC_EmailCC__c = direccionesCCEmailStr;
		}

        if (String.isNotBlank(subjectRecortado)) {
            casoNuevo.Subject = subjectRecortado;
        }

        if(email.htmlBody != null){ 
            casoNuevo.Description = email.htmlBody.left(32000).stripHtmlTags();
        }else if(email.plainTextBody != null){ 
            casoNuevo.Description = email.plainTextBody.left(32000);
        }

        if (cola != null) {
            casoNuevo.OwnerId = cola.QueueId;
        }
        
        return casoNuevo;
    }

	/**
	 * Método para recuperar la fecha original del mensaje entrante
	 */
    public static Datetime recuperarFechaEmail(Messaging.InboundEmail email) {

		String fechaEmail = '';
        Datetime emailDate;
       
		// Recuperar la fecha en la que se envió el email
		for(Messaging.InboundEmail.Header header : email.headers){
			if (header.name == 'Date') {
				fechaEmail = header.value;
			}
		}

		// Separar la cadena en sus componentes, formato que se recoge la fecha -> Ejemplo: Wed, 13 Sep 2023 08:43:40 +0000
		List<String> parts = fechaEmail.split(' ');  

		if (parts.size() >= 5) {
			// Mapear el mes a su equivalente numérico
			Map<String, String> monthMap = new Map<String, String>{
				'Jan' => '01', 'Feb' => '02', 'Mar' => '03', 'Apr' => '04', 'May' => '05', 'Jun' => '06',
				'Jul' => '07', 'Aug' => '08', 'Sep' => '09', 'Oct' => '10', 'Nov' => '11', 'Dec' => '12'
			};
		
			// Explicación -> parts[1] = dia, parts[2] mes, parts[3] año, parts[4] hora(global), timeParts[0] hora, timeParts[1] minutos, timeParts[2] segundo
			String[] timeParts = parts[4].split(':');
		
			// Convertir la fecha en un objeto Datetime
			try {
				emailDate = Datetime.newInstanceGmt(Integer.valueOf(parts[3]), Integer.valueOf(monthMap.get(parts[2])), Integer.valueOf(parts[1]), Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), Integer.valueOf(timeParts[2]));
			} catch (Exception e) {
				CBK_Log.error('Error al convertir la fecha: ' + e.getMessage());
			}
		}else{
			emailDate = System.now();
		}

        return emailDate;
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

	/**
	 * Método para comprobar en los envios de emails automáticos de las alertas (SAC_WrapperAlerta) que las direcciones de envio sean válidad (no se encuentren activas en la blackList)
	 */
	public static List<Messaging.SingleEmailMessage> comprobarEmailsBlackListIds(List<SAC_MaestroTemas__c> emailsBlackList, Map<String, User> mapUsuarios, List<Messaging.SingleEmailMessage> listEM) {

		//Crear una nueva lista para almacenar correos electrónicos válidos
		List<Messaging.SingleEmailMessage> listaSEMFiltrada = new List<Messaging.SingleEmailMessage>();

		//Iteramos para recuperar los correos únicos de la blackList
		Set<String> emailsNoValidosSet = new Set<String>();
		for (SAC_MaestroTemas__c emailNoValido : emailsBlackList) {
			emailsNoValidosSet.add(emailNoValido.Name);
		}

		for(Messaging.SingleEmailMessage email : listEM){
			//Si mapUsuarios no esta vacio, y mapaUsuarios contiene el id del toAddress
			if(!mapUsuarios.isEmpty() && mapUsuarios.containsKey(String.valueOf(email.toAddresses[0]))){
				//Comrpobamos si el email asociado al id del usuario es valido
				if(!emailsNoValidosSet.contains(mapUsuarios.get(String.valueOf(email.toAddresses[0])).Email)){
					listaSEMFiltrada.add(email);
				}
			}else{
				//Si mapUsuarios esta vacio, y mapaUsuarios no contiene el id del toAddress, el toAddresses viene con una lista de emails. Comprobamos si son todos validos, invalidos, o algunos validos y otros invalidos
				List<String> filteredEmails = new List<String>();

				for (String direccionEmail : email.toAddresses) {
					//Si el email no pertenece a la blackList, le añadimos como valido a la lista filteredEmails
					if (!emailsNoValidosSet.contains(direccionEmail)) {
						filteredEmails.add(direccionEmail);
					}
				}

				//Si tras filtrar hay emails válidos para el envio, modificamos el toAdresses asignando los emails validos y añadimos el EM a la lista filtrada
				if(!filteredEmails.isEmpty()){
					email.toAddresses = filteredEmails;
					listaSEMFiltrada.add(email);
				}
			}
		}	
		
		//Devolver la lista de correos electrónicos válidos
		return listaSEMFiltrada;
    }


	/**
	 * Método para calcular el tiempo que se tiene que restar al tiempo total del SLA regulatorio por la parada de subsanación
	 */
    public static Integer calcularTiempoParadaSubsanacion(Case caso, Integer tiempoTotal) {
        if(caso.SAC_TiempoParadaSubsanacion__c != null) {
            tiempoTotal = tiempoTotal + (Integer.ValueOf(caso.SAC_TiempoParadaSubsanacion__c) * 1440);
		}
		return tiempoTotal;
	}
}