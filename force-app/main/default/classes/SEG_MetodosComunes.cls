public with sharing class SEG_MetodosComunes {

	/**
	* @description   Método para recuperar los parámetros de un área / proceso de segmentos.
	* @param sArea -> Área del parámetro.
	* @return mapa con los parámetros recuperados.
	*/
	static public Map<String, SEG_Parametros__mdt> recuperarParametrosProceso(String sArea) {
		Map<String, SEG_Parametros__mdt> mapParametros = new Map<String, SEG_Parametros__mdt> ();
		List<SEG_Parametros__mdt> listadoParametros = [SELECT Id, DeveloperName, MasterLabel, SEG_AreaProceso__c, SEG_Valor__c
		FROM SEG_Parametros__mdt
		WHERE SEG_AreaProceso__c = :sArea
		];
		if (!listadoParametros.isEmpty()) {
			for (SEG_Parametros__mdt parametro : listadoParametros) {
				mapParametros.put(parametro.DeveloperName, parametro);
			}
		}
		return mapParametros;
	}


	//@description devolver a la cola cumplida la fecha de planificación
	static public void devolverSegBO(Id caseId) {
		Case caso = [SELECT OwnerId, Status, SEG_Subestado__c FROM Case WHERE id = :caseId LIMIT 1];
		List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];

		if (colasBO.size() == 1)
		{
			caso.OwnerId = colasBO[0].id;
			caso.Status = 'Activo';
			caso.SEG_Subestado__c = 'Pendiente asignación de propietario';
		}

		update caso;
	}

	//@description devolver a la cola cumplida la fecha de planificación (aplicado para Listas)
	static public void devolverSegBOList(Set<Id> lstCaseId) {

		List<Case> lstCaso = [SELECT OwnerId, Status, SEG_Subestado__c FROM Case WHERE id IN :lstCaseId];

		List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];
		List<Case> lstUpdCase = new List<Case> ();
		if (colasBO.size() == 1)
		{
			for (Case cs : lstCaso) {
				cs.OwnerId = colasBO[0].id;
				cs.Status = 'Activo';
				cs.SEG_Subestado__c = 'Pendiente asignación de propietario';
				lstUpdCase.add(cs);
			}
		}
		if (lstUpdCase.size() > 0) {
			update lstUpdCase;
		}
	}

	//JAV Método para invocar desde PB
	//@description devolver a la cola cumplida la fecha de planificación (aplicado para Listas)
	@InvocableMethod
	static public void devolverSegBOListPB(List<Id> idCasos) {
		Id idColaSegBo = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1].Id;
		List<Case> casos = [SELECT Status FROM Case WHERE Id IN :idCasos];
		for (Case caso : casos) {
			if (caso.Status == 'Planificado') {
				caso.OwnerId = idColaSegBo;
				caso.Status = 'Activo';
				caso.SEG_Subestado__c = 'Por Fecha Planificación';
			}
		}
		update casos;
	}

	static public Map<String,String> asignarGrupoCaso(String detalle, String motivo, String prodServ, String tematica, String accountId, String zona, String organizacion, boolean bAutomatico) {
		return asignarGrupoCaso(detalle, motivo, prodServ, tematica, accountId, zona, organizacion, bAutomatico, null);
	}

	static public Map<String,String> asignarGrupoCaso(String detalle, String motivo, String prodServ, String tematica, String accountId, String zona, String organizacion, boolean bAutomatico, Id idCaso) {

		Map<String,String> retorno = new Map<String,String>();
		retorno.put('grupoCol','');
		retorno.put('mantenerGrupo','N');
		retorno.put('error','0');
		retorno.put('detalle','');

		//boolean grupoAsignado = false;
		//boolean bDetalle = true;
		//boolean bMotivo = true;
		//boolean bProdServ = true;
		//boolean bTematica = true;
		//String grupoCol = '';
		//Set para guardar los ids MCC
		Set<String> idsMcc = new Set<String> ();

		//Account asiganda al caso
		/*Account accCase;
		if (String.isNotBlank(accountId))
		{
			List<Account> listadoDatosCuenta = [SELECT SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Empleado_gestor_Segmentos__c, AV_EAPGestor__c,
												SEG_GestorOperativaNacional__c, SEG_GestorOperativaInternacional__c, SEG_GestorFinEstructurada__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c
												FROM Account WHERE id = :accountId];
			if (!listadoDatosCuenta.isEmpty())
			{
				accCase = listadoDatosCuenta[0];
			}
		}*/

		//Account asiganda al caso
		/*Account accCase = [SELECT SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Empleado_gestor_Segmentos__c, AV_EAPGestor__c,
		SEG_GestorOperativaNacional__c, SEG_GestorOperativaInternacional__c, SEG_GestorFinEstructurada__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c
		FROM Account WHERE id = :accountId];*/

		if (detalle != null) {
			idsMcc.add(detalle);
		}
		if (motivo != null) {
			idsMcc.add(motivo);
		}
		if (prodServ != null) {
			idsMcc.add(prodServ);
		}
		if (tematica != null) {
			idsMcc.add(tematica);
		}

		Map<id, CC_MCC_Grupo_Colaborador__c> mapMCCs = new Map<id, CC_MCC_Grupo_Colaborador__c>(
			[SELECT CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.RecordType.DeveloperName, CC_MCC__c,
				SEG_Zona__c, SEG_Organizacion__c, CC_Grupo_Colaborador__r.SEG_Tipologia__c, CC_Grupo_Colaborador__r.Name, SEG_Prioridad__c, SEG_Grupo_respuesta__c
				FROM CC_MCC_Grupo_Colaborador__c
				WHERE CC_MCC__c IN :idsMcc AND CC_Grupo_Colaborador__c != null
				ORDER BY SEG_Prioridad__c ASC]);
		

		// Código optimizado. La SOQL devuelve los registros priorizados.
		for (ID claveGrupoColaborador : mapMCCs.keySet())
		{
			CC_MCC_Grupo_Colaborador__c mccGrupoRel = mapMCCs.get(claveGrupoColaborador);

			if (idCaso == null) {
				retorno = recuperarGrupo(mccGrupoRel, accountId, zona, organizacion, bAutomatico);
			} else {
				retorno = recuperarGrupo(mccGrupoRel, accountId, zona, organizacion, bAutomatico, idCaso);
			}

			if (retorno.get('error') != '0' || String.isNotBlank(retorno.get('grupoCol')) || retorno.get('mantenerGrupo') == 'Y')
			{
				break;
			}

			/*
			// Buscamos la primera coincidencia del grupo.
			if (idCaso == null) {
				grupoCol = recuperarGrupo(mccGrupoRel, accountId, zona, organizacion);
			} else {
				grupoCol = recuperarGrupo(mccGrupoRel, accountId, zona, organizacion, idCaso);
			}

			if (String.isNotBlank(grupoCol))
			{
				// Puede devolver el valor <ERROR-Grupo automático sin cuenta informada>, debido a que se intenta asignar a un grupo automático y no hay cuenta informada.
				break;
			}
			*/
		}
		return retorno;
	}

    /**
     *  @description Recuperar si el grupo del caso es un colaborador externo en base a la parametrización del MCC.
     *  @param organizacion -> Organización del caso.
     *  @param zona -> Zona del caso.
     *  @param grupo -> Identificador del grupo del caso.
     *  @param mccsCaso -> MCC de clasificación del caso.
	 *  @param accountId -> Cuenta asociada.
	 *  @param caseId -> Caso asociado.
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda y validación.
     */
    public static Map<String,String> recuperarColaboradorExterno (String organizacion, String zona, String grupo, Set<String> mccsCaso, String accountId, boolean bAutomatico, Id caseId)
    {
        Map<String,String> resultado = new Map<String,String>();
        resultado.put('error','0');
        resultado.put('esExterno', 'N');
        resultado.put('cierreCaso','N');
		resultado.put('nombreGrupoExterno','');

        List<CC_MCC_Grupo_Colaborador__c> gcolab = new List<CC_MCC_Grupo_Colaborador__c>(
            [SELECT Id, CC_MCC__c,SEG_Organizacion__c,SEG_Zona__c,SEG_Grupo_respuesta__c,CC_Grupo_Colaborador__c,
            CC_Grupo_Colaborador__r.RecordType.DeveloperName, SEG_Prioridad__c, SEG_Grupo_respuesta__r.Name, SEG_Grupo_respuesta__r.RecordType.DeveloperName,
            CC_Grupo_Colaborador__r.SEG_CierreAutomaticoSR__c, CC_Grupo_Colaborador__r.SEG_TipoColaboradorWS__c, SEG_OperativaValija__c, CC_Grupo_Colaborador__r.Name
            FROM CC_MCC_Grupo_Colaborador__c 
            WHERE CC_MCC__c in :mccsCaso 
            AND (SEG_Organizacion__c=:organizacion OR SEG_Organizacion__c='Todas') 
            AND (SEG_Zona__c=:zona OR SEG_Zona__c='Todas') and CC_Grupo_Colaborador__c=:grupo
            ORDER BY SEG_Prioridad__c ASC
            LIMIT 1]);
        
        if(gcolab.size() > 0)
        {
            if(gcolab[0].CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'CC_Grupo_Colaborador')
            {
				String tipoGrupoRespuesta = gcolab[0].SEG_Grupo_respuesta__r?.RecordType?.DeveloperName;
                String grupoRespuesta = gcolab[0].SEG_Grupo_respuesta__c;
                String grupoRespuestaName = gcolab[0].SEG_Grupo_respuesta__r?.Name;
                Boolean bCierreCaso = false;

                resultado.put('esExterno', 'Y');
                resultado.put('grupoRespuesta', grupoRespuesta);
				resultado.put('nombreGrupoExterno',gcolab[0].CC_Grupo_Colaborador__r?.Name);

				// Calcular si es un grupo colaborador de tipo WebService.
				String tipoColaboradorWS = gcolab[0].CC_Grupo_Colaborador__r.SEG_TipoColaboradorWS__c;
				tipoColaboradorWS = (String.isBlank(tipoColaboradorWS)) ? 'N' : tipoColaboradorWS;
				resultado.put('tipoColaboradorWS',tipoColaboradorWS);
				resultado.put('operacionValija',gcolab[0].SEG_OperativaValija__c);

                // Gestionar el cierre del caso, según la parametrización del grupo colaborador.
                bCierreCaso = (gcolab[0].CC_Grupo_Colaborador__r?.SEG_CierreAutomaticoSR__c != null) ? gcolab[0].CC_Grupo_Colaborador__r.SEG_CierreAutomaticoSR__c : false;

                // Migración del código de autoasignación SEG_Case_Operativas_Controller.
                // Revisar el grupo de respuesta, que no contenga '*'

				if (String.isNotBlank(tipoGrupoRespuesta) && tipoGrupoRespuesta == 'SEG_GrupoAutomaticoSegmentos')
				{
					//String nuevoGrupoRespuesta = calcularGrupoAutomatico (grupoRespuestaName, '', accountId, bAutomatico, caseId);
					String nuevoGrupoRespuesta = '';
					Map<String,String> retornoGrupoAuto = calcularGrupoAutomatico (grupoRespuestaName, '', accountId, bAutomatico, caseId);
					if (retornoGrupoAuto.get('error') != '0')
					{
						String nuevoCodigoError = retornoGrupoAuto.get('error');
						resultado.put('error',nuevoCodigoError);
						nuevoGrupoRespuesta = (nuevoCodigoError != '5') ? retornoGrupoAuto.get('grupoCol') : '';
						//resultado.put('error','1');
						//nuevoGrupoRespuesta = '';
					}else if (retornoGrupoAuto.get('mantenerGrupo') == 'Y'){
						nuevoGrupoRespuesta = '';
					}else{
						nuevoGrupoRespuesta = retornoGrupoAuto.get('grupoCol');
					}					

					/*
					// ERROR-Grupo automático sin cuenta informada
					if (String.isNotBlank(nuevoGrupoRespuesta) && nuevoGrupoRespuesta.contains('ERROR-'))
					{
						resultado.put('error','1');
						nuevoGrupoRespuesta = '';
					}

					// MANTENER_GRUPO. Grupo automático que envía correo sin cambiar el grupo.
					if (String.isNotBlank(nuevoGrupoRespuesta) && nuevoGrupoRespuesta.contains('MANTENER_GRUPO'))
					{
						nuevoGrupoRespuesta = '';
					}
					*/

					resultado.put('grupoRespuesta', nuevoGrupoRespuesta);
				}

                // Estado inicial en el que quedará el caso.
				String subestadoCaso = 'En colaborador';
				subestadoCaso = (tipoColaboradorWS == 'VALIJA') ? 'En canal Valija' : subestadoCaso;

                resultado.put('nuevoEstadoCaso','Pendiente');
                resultado.put('nuevoSubEstadoCaso', subestadoCaso);

                if (bCierreCaso)
                {
                    // El caso se cerrará después de crearlo.
                    resultado.put('cierreCaso','Y');
                    resultado.put('estadoCierre','Cerrado');
                    resultado.put('subestadoCierre', 'Envío cierre Colaborador');
                }
            }
        }
        return resultado;
    }

	/**
	 * @description Método para calcular el grupo respuesta en colaboradores automáticos.
	 * @param mccGrupoRel
	 * @param accCase
	 * @param caseId
	 * @return
	 */
	static public Map<String,String> calcularGrupoAutomatico (String nombreGrupo, String grupoRespuestaId, String accountId, boolean bAutomatico, Id caseId)
	{
		Map<String,String> retornoGrupoAuto = new Map<String,String>();
		retornoGrupoAuto.put('grupoCol','');
		retornoGrupoAuto.put('mantenerGrupo','N');
		retornoGrupoAuto.put('error','0');
		retornoGrupoAuto.put('detalle','');
		
		String grupoCol = '';
		Boolean isGroup = false;
		Boolean grupoAutoEnvioCorreo = false;
		
		//Grupos automáticos
		Id idGrupoAuto;
		Id idGrupoRespuesta;
		Id idGestor;
		
		//Account asiganda al caso
		Account cuenta;
		String numeroOficinaGestora = '';
		Boolean priorizacionSegmentos = false;

		ID recordTypeCentroCBK = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		List<Case> caseSR = [SELECT SEG_Organizacion__c, SEG_Zona__c, SEG_Centro_Identificado__c FROM Case WHERE id = :caseId LIMIT 1];

		if (String.isNotBlank(accountId)) {
			List<Account> cuentas = [SELECT SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Empleado_gestor_Segmentos__c, AV_EAPGestor__c,
			SEG_GestorOperativaNacional__c, SEG_GestorOperativaInternacional__c, SEG_GestorFinEstructurada__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c, RecordTypeId,
			SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, CC_Numero_Oficina__c
			FROM Account WHERE Id = :accountId];
			if (!cuentas.isEmpty()) {
				cuenta = cuentas[0];
				ID recordTypeCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
				ID recordTypeClienteSEG = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
				//ID recordTypeClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
				
				if (cuenta.RecordTypeId == recordTypeCliente || cuenta.RecordTypeId == recordTypeClienteSEG) {
					// Clientes
					priorizacionSegmentos = (cuenta.SEG_Prioridad_Carterizacion_Segmentos__c != null) ? cuenta.SEG_Prioridad_Carterizacion_Segmentos__c : false;
					priorizacionSegmentos = (cuenta.RecordTypeId == recordTypeClienteSEG) ? false : priorizacionSegmentos;
					//priorizacionSegmentos = (cuenta.RecordTypeId == recordTypeClientePA) ? false : priorizacionSegmentos;
					if (priorizacionSegmentos)
					{
						numeroOficinaGestora = cuenta?.SEG_Oficina_Gestora_Segmentos__r?.CC_Numero_Oficina__c;
					}else{
						numeroOficinaGestora = cuenta?.AV_OficinaPrincipal__r?.CC_Numero_Oficina__c;
					}
				}else {
					// Centros.
					numeroOficinaGestora = cuenta?.CC_Numero_Oficina__c;
				}

				if (numeroOficinaGestora == null) {
					numeroOficinaGestora = caseSR[0]?.SEG_Centro_Identificado__c;
				}
			}
		}
		
		// CONTROL DE GRUPOS AUTOMÁTICOS, SIN CUENTA INFORMADA.
		if (cuenta != null)
		{		
			grupoAutoEnvioCorreo = nombreGrupo.startsWith('Envío correo ');
			if (nombreGrupo.endsWith('*')) {
				String grupoC = nombreGrupo.replace('*', ' ') + numeroOficinaGestora;
				List<CC_Grupo_Colaborador__c> oGrupo = new List<CC_Grupo_Colaborador__c>([SELECT id, SEG_Organizacion__c, SEG_Zona__c FROM CC_Grupo_Colaborador__c WHERE Name = :grupoC]);
				if (oGrupo.size() == 1) {
					isGroup = true;
					if(oGrupo[0].SEG_Organizacion__c.contains(caseSR[0].SEG_Organizacion__c) && oGrupo[0].SEG_Zona__c.contains(caseSR[0].SEG_Zona__c))
					{
						idGrupoAuto = oGrupo[0].id;
					}else {
						if(bAutomatico){
							List<SEG_Buzon__mdt> buzonMCC = [SELECT SEG_Grupo_MCC__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = :caseSR[0].SEG_Organizacion__c AND SEG_Zona__c = :caseSR[0].SEG_Zona__c];
							if(buzonMCC.size() > 0){
								List<CC_Grupo_Colaborador__c> grupoMCC = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = :buzonMCC[0].SEG_Grupo_MCC__c];
								if(grupoMCC.size() > 0){
									idGrupoAuto = grupoMCC[0].id; 
								}
							}
						}else {
							retornoGrupoAuto.put('error','6');
							retornoGrupoAuto.put('detalle','ERROR-Org/Zona del centro no coincide');
						}
					}
				}else {
					retornoGrupoAuto.put('error','3');
					retornoGrupoAuto.put('detalle','ERROR-Cuenta sin número de centro informado');
				}

			} else {

				if(cuenta.RecordTypeId != recordTypeCentroCBK)
				{
					if (nombreGrupo.endsWith('Gestor Comercial')) {
						if (priorizacionSegmentos) {
							if (!grupoAutoEnvioCorreo) {
								List<SEG_Gestor_Grupo__c> gestorSeg = [SELECT SEG_EmpleadoGestor__c, SEG_GrupoOperativa__c FROM SEG_Gestor_Grupo__c
								WHERE SEG_EmpleadoGestor__c = :cuenta.SEG_Empleado_gestor_Segmentos__c AND SEG_EmpleadoGestor__c != null];
								if (!gestorSeg.isEmpty()) {
									idGrupoAuto = gestorSeg[0].SEG_GrupoOperativa__c;
									isGroup = true;
								}else {
									retornoGrupoAuto.put('error','2');
									retornoGrupoAuto.put('detalle','ERROR-Grupo automático sin gestor informado');
								}
							} else {
								idGestor = cuenta.SEG_Empleado_gestor_Segmentos__c;
							}
						} else {
							if (!grupoAutoEnvioCorreo) {
								List<SEG_Gestor_Grupo__c> empGestor = [SELECT SEG_EmpleadoGestor__c, SEG_GrupoOperativa__c FROM SEG_Gestor_Grupo__c
								WHERE SEG_EmpleadoGestor__c = :cuenta.AV_EAPGestor__c AND SEG_EmpleadoGestor__c != null];
								if (!empGestor.isEmpty()) {
									idGrupoAuto = empGestor[0].SEG_GrupoOperativa__c;
									isGroup = true;
								}else {
									retornoGrupoAuto.put('error','2');
									retornoGrupoAuto.put('detalle','ERROR-Grupo automático sin gestor informado');
								}
							} else {
								idGestor = cuenta.AV_EAPGestor__c;
							}
						}
					} else if (nombreGrupo.endsWith('Gestor Operativa Nacional')) {
						if (!grupoAutoEnvioCorreo) {
							List<SEG_Gestor_Grupo__c> opNacional = [SELECT SEG_EmpleadoGestor__c, SEG_GrupoOperativa__c FROM SEG_Gestor_Grupo__c
							WHERE SEG_EmpleadoGestor__c = :cuenta.SEG_GestorOperativaNacional__c AND SEG_EmpleadoGestor__c != null];
							if (!opNacional.isEmpty()) {
								idGrupoAuto = opNacional[0].SEG_GrupoOperativa__c;
								isGroup = true;
							}else {
								retornoGrupoAuto.put('error','2');
								retornoGrupoAuto.put('detalle','ERROR-Grupo automático sin gestor informado');
							}
						} else {
							idGestor = cuenta.SEG_GestorOperativaNacional__c;
						}
					} else if (nombreGrupo.endsWith('Gestor Operativa Internacional')) {
						if (!grupoAutoEnvioCorreo) {
							List<SEG_Gestor_Grupo__c> opInternacional = [SELECT SEG_EmpleadoGestor__c, SEG_GrupoOperativa__c FROM SEG_Gestor_Grupo__c
							WHERE SEG_EmpleadoGestor__c = :cuenta.SEG_GestorOperativaInternacional__c AND SEG_EmpleadoGestor__c != null];
							if (!opInternacional.isEmpty()) {
								idGrupoAuto = opInternacional[0].SEG_GrupoOperativa__c;
								isGroup = true;
							}else {
								retornoGrupoAuto.put('error','2');
								retornoGrupoAuto.put('detalle','ERROR-Grupo automático sin gestor informado');
							}
						} else {
							idGestor = cuenta.SEG_GestorOperativaInternacional__c;
						}
					} else if (nombreGrupo.endsWith('Gestor Financiación Estructurada')) {
						if (!grupoAutoEnvioCorreo) {
							List<SEG_Gestor_Grupo__c> finEstructurada = [SELECT SEG_EmpleadoGestor__c, SEG_GrupoOperativa__c FROM SEG_Gestor_Grupo__c
							WHERE SEG_EmpleadoGestor__c = :cuenta.SEG_GestorFinEstructurada__c AND SEG_EmpleadoGestor__c != null];
							if (!finEstructurada.isEmpty()) {
								idGrupoAuto = finEstructurada[0].SEG_GrupoOperativa__c;
								isGroup = true;
							}else {
								retornoGrupoAuto.put('error','2');
								retornoGrupoAuto.put('detalle','ERROR-Grupo automático sin gestor informado');
							}
						} else {
							idGestor = cuenta.SEG_GestorFinEstructurada__c;
						}
					}
				}else{
					retornoGrupoAuto.put('error','4');
					retornoGrupoAuto.put('detalle','ERROR-Centro Caixabank');		
				}
			}
			if (grupoAutoEnvioCorreo) {
				if(idGestor != null){
					//Evío de correo
					enviarCorreoGrupoAutomaticoEnvioCorreo(caseId, idGestor);
					retornoGrupoAuto.put('detalle','grupoAutoEnvioCorreo');
					//Grupo de trabajo del caso pasa a ser el grupo de trabajo del grup auto para esa clasificación
					if (String.isNotBlank(grupoRespuestaId)) {
						grupoCol = grupoRespuestaId;
					}else{
						grupoCol = 'MANTENER_GRUPO';
					}
				} else {
					retornoGrupoAuto.put('error','7');
					retornoGrupoAuto.put('detalle','ERROR-Grupo automático sin gestor informado');
				}
			} else {
				grupoCol = idGrupoAuto;
			}
		}else {
			retornoGrupoAuto.put('error','1');
			retornoGrupoAuto.put('detalle','ERROR-Grupo automático sin cuenta informada');
		}
		
		//Asignación de grupo standard 
		if(!isGroup && !grupoAutoEnvioCorreo)
		{
			if(caseId != null) 
			{			
				List<CC_Grupo_Colaborador__c> grupoEstandar = [SELECT id FROM CC_Grupo_Colaborador__c WHERE SEG_Grupo_Estandar__c = true
				AND SEG_Organizacion__c includes (:caseSR[0].SEG_Organizacion__c) AND SEG_Zona__c includes (:caseSR[0].SEG_Zona__c) LIMIT 1];
							
				if(!grupoEstandar.isEmpty())
				{ 
					grupoCol = grupoEstandar[0].id;
				}
				else {				
					retornoGrupoAuto.put('error','5');
					retornoGrupoAuto.put('detalle','ERROR-No se ha encontrado un grupo standard');	
				}			
			}
		}
		
		// Preparar retorno.
		retornoGrupoAuto.put('grupoCol',(grupoCol == 'MANTENER_GRUPO') ? '' : grupoCol);
		retornoGrupoAuto.put('mantenerGrupo',(grupoCol == 'MANTENER_GRUPO') ? 'Y' : 'N');

		//return grupoCol;
		return retornoGrupoAuto;
	}

	static public Map<String,String> recuperarGrupo(CC_MCC_Grupo_Colaborador__c mccGrupoRel, String accountId, String zona, String organizacion, boolean bAutomatico) {
		return recuperarGrupo(mccGrupoRel, accountId, zona, organizacion, bAutomatico, null);
	}

	//Método que retorna el id del grupo colaborador
	static public Map<String,String> recuperarGrupo(CC_MCC_Grupo_Colaborador__c mccGrupoRel, String accountId, String zona, String organizacion, boolean bAutomatico, Id idCaso) {

		Map<String,String> retorno = new Map<String,String>();
		retorno.put('grupoCol','');
		retorno.put('mantenerGrupo','N');
		retorno.put('error','0');
		retorno.put('detalle','');

		// Nueva versión de cálculo del grupo colaborador por organización y zona.
		if (mccGrupoRel.CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'SEG_GrupoOperativoSegmentos' || mccGrupoRel.CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'CC_Grupo_Colaborador')
		{
			// La gestión de grupos operativos y grupos de colaborador es la misma.
			if (mccGrupoRel.SEG_Zona__c == zona && mccGrupoRel.SEG_Organizacion__c == organizacion || mccGrupoRel.SEG_Zona__c == 'Todas' && mccGrupoRel.SEG_Organizacion__c == organizacion
				|| mccGrupoRel.SEG_Zona__c == 'Todas' && mccGrupoRel.SEG_Organizacion__c == 'Todas') {
				String grupoCol = mccGrupoRel.CC_Grupo_Colaborador__c;
				retorno.put('grupoCol',grupoCol);
			}
		}else if (mccGrupoRel.CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'SEG_GrupoAutomaticoSegmentos') {
			// Gestión de grupos automáticos.
			if (mccGrupoRel.SEG_Zona__c == zona && mccGrupoRel.SEG_Organizacion__c == organizacion || mccGrupoRel.SEG_Zona__c == 'Todas' && mccGrupoRel.SEG_Organizacion__c == organizacion
				|| mccGrupoRel.SEG_Zona__c == 'Todas' && mccGrupoRel.SEG_Organizacion__c == 'Todas') {
				//grupoCol = calcularGrupoAutomatico(mccGrupoRel.CC_Grupo_Colaborador__r.Name, mccGrupoRel.SEG_Grupo_respuesta__c, accountId, bAutomatico, idCaso);
				retorno = calcularGrupoAutomatico (mccGrupoRel.CC_Grupo_Colaborador__r.Name, mccGrupoRel.SEG_Grupo_respuesta__c, accountId, bAutomatico, idCaso);	
			}
		}
		return retorno;
	}

	/**
	* @description   Método para recuperar el valor de un parámetro de segmentos.
	* @param sParametro -> Parámetro a recuperar
	* @return Valor del parámetro.
	*/
	static public String recuperarParametrosValor(String sParametro) {
		String sValor = '';
		List<SEG_Parametros__mdt> listadoParametros = [SELECT Id, DeveloperName, MasterLabel, SEG_AreaProceso__c, SEG_Valor__c
		FROM SEG_Parametros__mdt
		WHERE DeveloperName = :sParametro
		];
		if (!listadoParametros.isEmpty())
		{
			sValor = listadoParametros[0].SEG_Valor__c;
		}

		return sValor;
	}

	/**
	*  @description Función que devuelve la Lista negra entera en formato MAP<Email, Email>. Key y Value repetido a efectos de poder usar containsKey
	*  @param listEmail --> listado de emails a comprobar
	*  @return Map<String, String>
	*/
	static public Map<String, String> recuperaListaNegra(List<String> listEmail)
	{
		Map<String, String> emailsListaNegra = new Map<String, String> ();

		if (listEmail.size() > 0)
		{
			String[] filters = new String[] { };
			for (string email1 : listEmail)
			{
				filters.add(email1);
				//like :'%'+fromAddress.split('@').get(1)+'%'
				if (email1 != null && String.isNotBlank(email1.split('@').get(1)))
				{
					filters.add('%' + email1.split('@').get(1));
				}
			}

			for (SEG_ListaNegra__c listaNegra :[SELECT Id, SEG_Email__c, SEG_Inactivo__c from SEG_ListaNegra__c where SEG_Inactivo__c = false and SEG_Email__c like :filters]){
				emailsListaNegra.put(listaNegra.SEG_Email__c, listaNegra.SEG_Email__c);
			}
		}

		return emailsListaNegra;
	}

	/**
	*  @description Función para registrar errores dml.
	*  @param errores -> Listado con los errores DML.
	*/
	static public void registrarErrorDML(List<Database.Error> listaErrores, SObject objetoAsociado)
	{
		List<String> mensajesError = new List<String> ();
		for (Database.Error error : listaErrores)
		{
			mensajesError.add(error.getStatusCode() + ' - ' + error.getMessage());
		}
		mensajesError.add('Objeto -> ' + JSON.serializePretty(objetoAsociado, true));
		DmlException excepcion = new DMLException(String.join(mensajesError, ', '));
		CBK_Log.error(excepcion);
	}

	/**
	* @description método para determinar la plantilla para el envío de emails devuelve un mapa de plantillas
	* @param caso -> Caso al cual hacemos referencia para recoger la plantilla
	* @param operativa --> Literal para poder filtrar por el tipo de operativa en plantilla
	*/

	static public Map<Id, SEG_Plantilla__c> determinarPlantillaExclusiva(Case caso, String operativa){
		Map<Id, SEG_Plantilla__c> mapPlantillas;
		//Paso 1: filtramos plantillas por organización y zona
		if(operativa == 'Reclamaciones'){
				mapPlantillas = new Map<Id, SEG_Plantilla__c>([SELECT id, SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c,
															SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c,
															SEG_PlantillaInglesID__c, SEG_TipoOperativa__c, Reclamaciones__c, SEG_Resultado__c FROM SEG_Plantilla__c
															WHERE SEG_TipoOperativa__c = 'Reclamaciones' AND Reclamaciones__c IN('1ª Reclamación', '2ª Reclamación', '3ª Reclamación', 'Reclamaciones Agotadas')
															AND SEG_Activa__c = true]);
		}else{
			if (caso.SEG_Resultado__c != null) {
				mapPlantillas = new Map<Id, SEG_Plantilla__c> ([SELECT id, SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c, SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c, SEG_PlantillaInglesID__c, SEG_TipoOperativa__c, SEG_Resultado__c from SEG_Plantilla__c where SEG_TipoOperativa__c = :operativa and SEG_Resultado__c = :caso.SEG_Resultado__c and SEG_Activa__c = true and SEG_Organizacion__c includes(:caso.SEG_Organizacion__c) and SEG_Zona__c includes(:caso.SEG_Zona__c)]);
			} else {
				mapPlantillas = new Map<Id, SEG_Plantilla__c> ([SELECT id, SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c, SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c, SEG_PlantillaInglesID__c, SEG_TipoOperativa__c from SEG_Plantilla__c where SEG_TipoOperativa__c = :operativa and SEG_Activa__c = true and SEG_Organizacion__c includes(:caso.SEG_Organizacion__c) and SEG_Zona__c includes(:caso.SEG_Zona__c)]);
			}
		}
		
		if (mapPlantillas.size() > 0){
			//Paso 2: recuperamos los centros de la plantilla. En caso de no tener ninguno la plantilla sigue siendo válida. Si tuviera centros pero no casa con el centro del caso, haríamos remove del mapPlantillas
			Map<Id, SEG_ExcepcionesCentro__c> detallesCentros = new Map<Id, SEG_ExcepcionesCentro__c> ([SELECT id, SEG_Plantilla__c, SEG_CentroEmpresa__c from SEG_ExcepcionesCentro__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_CentroEmpresa__c = :caso.SEG_Numero_de_centro__c]);
			if (detallesCentros.size() > 0){
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesCentro__c detalle : detallesCentros.values()){
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}
				for (Id plantillaID : mapPlantillas.keyset()){
					if (!auxMapIdPlantillas.containsKey(plantillaID)){
						mapPlantillas.remove(plantillaID);
					}
				}
			}
			if (detallesCentros.size() == 0){
				for (SEG_ExcepcionesCentro__c excepcionCentro :[SELECT id, SEG_Plantilla__c, SEG_CentroEmpresa__c from SEG_ExcepcionesCentro__c where SEG_Plantilla__c in :mapPlantillas.keyset()]){
					if (mapPlantillas.containsKey(excepcionCentro.SEG_Plantilla__c)){
						mapPlantillas.remove(excepcionCentro.SEG_Plantilla__c);
					}
				}
			}

			Map<Id, SEG_ExcepcionesGrupo__c> detallesGrupos = new Map<Id, SEG_ExcepcionesGrupo__c> ([SELECT id, SEG_Plantilla__c, SEG_GrupoTrabajoTexto__c from SEG_ExcepcionesGrupo__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_GrupoTrabajoTexto__c = :caso.SEG_Grupo__c]);
			if (detallesGrupos.size() > 0){
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesGrupo__c detalle : detallesGrupos.values()){
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}

				for (Id plantillaID : mapPlantillas.keyset()){
					if (!auxMapIdPlantillas.containsKey(plantillaID)){mapPlantillas.remove(plantillaID);
					}
				}
			}
			if (detallesGrupos.size() == 0){
				for (SEG_ExcepcionesGrupo__c excepcionGrupo :[SELECT id, SEG_Plantilla__c, SEG_GrupoTrabajoTexto__c from SEG_ExcepcionesGrupo__c where SEG_Plantilla__c in :mapPlantillas.keyset()]){
					if (mapPlantillas.containsKey(excepcionGrupo.SEG_Plantilla__c)){mapPlantillas.remove(excepcionGrupo.SEG_Plantilla__c);
					}
				}
			}

			//Paso 4: nos queda buscar por empresa y grupo de empresas. Si hay grupo de empresas informado se ignora la empresa. Adecuar
			Map<Id, SEG_ExcepcionesGrupoEmpresa__c> detallesGruposEmpresa = new Map<Id, SEG_ExcepcionesGrupoEmpresa__c> ([SELECT id, SEG_Plantilla__c, SEG_GrupoEmpresa__c from SEG_ExcepcionesGrupoEmpresa__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_GrupoEmpresa__c = :caso.SEG_Grupo_Empresa__c]);

			if (detallesGruposEmpresa.size() == 0){
				Map<Id, SEG_ExcepcionesEmpresa__c> detallesEmpresa = new Map<Id, SEG_ExcepcionesEmpresa__c> ([SELECT id, SEG_Plantilla__c, SEG_Empresa__c from SEG_ExcepcionesEmpresa__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_Empresa__c = :caso.AccountId]);
				//comprobamos empresas
				if (detallesEmpresa.size() > 0){
					Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
					for (SEG_ExcepcionesEmpresa__c detalle : detallesEmpresa.values()){
						auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
					}
					for (Id plantillaID : mapPlantillas.keyset()){
						if (!auxMapIdPlantillas.containsKey(plantillaID)){mapPlantillas.remove(plantillaID);
						}
					}
				}
				if (detallesEmpresa.size() == 0){
					for (SEG_ExcepcionesEmpresa__c excepcionEmpresa :[SELECT id, SEG_Plantilla__c, SEG_Empresa__c from SEG_ExcepcionesEmpresa__c where SEG_Plantilla__c in :mapPlantillas.keyset()]){
						if (mapPlantillas.containsKey(excepcionEmpresa.SEG_Plantilla__c)){mapPlantillas.remove(excepcionEmpresa.SEG_Plantilla__c);
						}
					}
				}
			}
			else {
				//comprobamos grupos de empresas
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesGrupoEmpresa__c detalle : detallesGruposEmpresa.values()){
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}
				for (Id plantillaID : mapPlantillas.keyset()){
					if (!auxMapIdPlantillas.containsKey(plantillaID)){
						mapPlantillas.remove(plantillaID);
					}
				}
			}

			//Paso 5: busqueda por clasificación rápida
			//List<SEG_ExcepcionesCR__c> detallesCR = new List<SEG_ExcepcionesCR__c>([SELECT id,SEG_Plantilla__c,SEG_ClasificacionRapida__c from SEG_ExcepcionesCR__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_ClasificacionRapida__c=:caso.SEG_ClasificacionRapida__c]);
			Map<Id, SEG_ExcepcionesCR__c> detallesCR = new Map<Id, SEG_ExcepcionesCR__c> ([SELECT id, SEG_Plantilla__c, SEG_ClasificacionRapida__c from SEG_ExcepcionesCR__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_ClasificacionRapida__c = :caso.SEG_ClasificacionRapida__c]);
			if (detallesCR.size() > 0){
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesCR__c detalle : detallesCR.values()){
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}
				for (Id plantillaID : mapPlantillas.keyset()){
					if (!auxMapIdPlantillas.containsKey(plantillaID)){mapPlantillas.remove(plantillaID);
					}
				}
			}
			if (detallesCR.size() == 0){
				//en este caso deberemos buscar las CR y quitar del map todas las que existan
				for (SEG_ExcepcionesCR__c excepcionCR :[SELECT id, SEG_Plantilla__c, SEG_ClasificacionRapida__c from SEG_ExcepcionesCR__c where SEG_Plantilla__c in :mapPlantillas.keyset()]){
					if (mapPlantillas.containsKey(excepcionCR.SEG_Plantilla__c)){mapPlantillas.remove(excepcionCR.SEG_Plantilla__c);
					}
				}
			}
		}

		return mapPlantillas;
	}

	public static Map<String,String> enviarEmailAutomatico(Id grupoDestinoId, id grupoOrigenId, id casoId)
	{
		Boolean bOk = true;
		Map<String,String> retornoEnvioMail = new Map<String,String>();
		retornoEnvioMail.put('error','0');
		retornoEnvioMail.put('detalle','');

		// Validar datos obligatorios de entrada.
		if (grupoDestinoId == null || casoId == null)
		{
			retornoEnvioMail.put('error','1');
			retornoEnvioMail.put('detalle','No están disponibles los datos del grupo destino ni del caso para realizar el envío automático del email de asignación.');
			return retornoEnvioMail;
		}

		try{

			// Variables para el proceso de envío de email.
			String asuntoMail = '';
			String subject = '';
			String htmlEmail = '';
			String htmlFirma = '';
			String htmlMailsAnteriores = '';

			// Recuperar los datos del caso.
			Case caso;
			List<Case> listaCasos = [SELECT id, SEG_Organizacion__c, SEG_Zona__c,AccountId, CaseNumber FROM Case WHERE id = :casoId];
			if (!listaCasos.isEmpty())
			{
				caso = listaCasos[0];
			}else{
				bOk = false;
				retornoEnvioMail.put('error','2');
				retornoEnvioMail.put('detalle','No se ha podido obtener los datos del caso <' + casoId + '>');
			}

			// Recuperar los buzones salientes para el caso.
			String owaSalienteId = '';
			if (bOk)
			{
				Map<String,String> mapaBuzonesOrgZona = SEG_MetodosComunes.recuperarOWASegmentos();
				String claveBuzon = caso.SEG_Organizacion__c + '##' + caso.SEG_Zona__c;
				owaSalienteId = String.isNotBlank(mapaBuzonesOrgZona.get(claveBuzon)) ? mapaBuzonesOrgZona.get(claveBuzon) : mapaBuzonesOrgZona.get('Por defecto##Por defecto');

				if (String.isBlank(owaSalienteId))
				{
					bOk = false;
					retornoEnvioMail.put('error','3');
					retornoEnvioMail.put('detalle','No se ha podido obtener el buzón remitente para el traslado del caso.');
				}
			}

			// Recuperar la plantilla de firma.
			if (bOk)
			{
				List<CC_Grupo_Colaborador_Plantilla__c> listPlantillasFirmas = [SELECT id, SEG_Plantilla__c, SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, CC_Operativa__c FROM CC_Grupo_Colaborador_Plantilla__c WHERE CC_Grupo_Colaborador__c = :grupoDestinoId and SEG_Plantilla__r.SEG_TipoOperativa__c = 'Firma'];
				if (listPlantillasFirmas.size() == 1)
				{
					if (String.isNotBlank(listPlantillasFirmas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c))
					{
						Messaging.SingleEmailMessage firma = Messaging.renderStoredEmailTemplate(listPlantillasFirmas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, UserInfo.getUserId(), caso.Id);
						htmlFirma = firma.getHtmlBody();
					}
				}
			}

			// Recuperar la plantilla de envío a colaborador.
			if (bOk)
			{
				List<CC_Grupo_Colaborador_Plantilla__c> listColabPlantillas = [SELECT id, SEG_Plantilla__c, SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, CC_Operativa__c FROM CC_Grupo_Colaborador_Plantilla__c WHERE CC_Grupo_Colaborador__c = :grupoDestinoId];	
				if (listColabPlantillas.size() > 0){
					if (String.isNotBlank(listColabPlantillas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c))
					{
						Messaging.SingleEmailMessage messageAux = Messaging.renderStoredEmailTemplate(listColabPlantillas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, UserInfo.getUserId(), caso.Id);
						htmlEmail = messageAux.getHtmlBody();
						asuntoMail = messageAux.getSubject();
						if(string.isNotBlank(asuntoMail) && !asuntoMail.contains(caso.caseNumber)){   
							subject = asuntoMail;
							subject = (caso.caseNumber +' - ' + subject);
						}
						else{
							subject = asuntoMail;
						}
					}
					//depende de la operativa, enviamos email o bien, concatenamos y enviamos:
					if (listColabPlantillas[0].CC_Operativa__c == 'Remitir'){
						for (EmailMessage emailfromCase : [SELECT id, TextBody,HtmlBody, ToAddress, ValidatedFromAddress, RelatedToId FROM EmailMessage WHERE RelatedToId = :casoId ORDER BY CreatedDate DESC]){
							//if (String.isBlank(htmlMailsAnteriores)){
							//	htmlMailsAnteriores = '_________________________________________ <br>';
							//}
							//else {
								htmlMailsAnteriores = htmlMailsAnteriores + '_________________________________________ <br>';
								htmlMailsAnteriores = htmlMailsAnteriores + ' De: ' + emailfromCase.ValidatedFromAddress + '<br>';
								htmlMailsAnteriores = htmlMailsAnteriores + ' A: ' + emailfromCase.ToAddress + '<br>';
								htmlMailsAnteriores = htmlMailsAnteriores + emailfromCase.HtmlBody + '<br>';
								htmlMailsAnteriores = htmlMailsAnteriores + '_________________________________________ <br>';
							//}
						}
						htmlMailsAnteriores = (String.isNotBlank(htmlMailsAnteriores) && htmlMailsAnteriores.length() > 32000) ? htmlMailsAnteriores.left(32000) : htmlMailsAnteriores;
					}
				}else{
					// Error, plantilla no definida.
					bOk = false;
					retornoEnvioMail.put('error','4');
					retornoEnvioMail.put('detalle','El grupo colaborador <' + grupoDestinoId + '> no tiene configurada correctamente la plantilla de traslado.');
				}
			}

			// Recuperar los destinatarios del grupo de colaborador.
			List<String> listPara = new List<String> ();
			List<String> listCC = new List<String> ();
			List<String> listCCO = new List<String> ();
			if (bOk)
			{
				List<CC_Grupo_Colaborador_Contact__c> grupoColaboradorExterno = [SELECT Id, CC_Nombre__c, CC_Email__c,CC_Contacto__c, CC_Grupo_Colaborador__c, CC_Para_CC__c 
																				FROM CC_Grupo_Colaborador_Contact__c 
																				WHERE CC_Grupo_Colaborador__c = :grupoDestinoId];

				//Buscar los canales de comunicación vinculados con el grupo
				List<String> contactEmails = new List<String>();
				Map<String,String> idContCase = new map<String,String>();


				for (CC_Grupo_Colaborador_Contact__c colab : grupoColaboradorExterno) {
					if (colab.CC_Para_CC__c == 'Para') {
						contactEmails.add(colab.CC_Contacto__c);
					}
				}
				for (String contacto : contactEmails){
					idContCase.put(contacto, caso.AccountId);
				}

				Map<String,Map<String,Set<String>>> destinatariosCorreo = getDestinatariosContactos(idContCase);
				Map<String,Set<String>> contactosDestinoMail = new Map<String,Set<String>>();
				for (String contactoID : contactEmails) {
					if(destinatariosCorreo.containsKey(contactoID)){
						if(!contactosDestinoMail.containsKey('Para')){
							contactosDestinoMail.put('Para', destinatariosCorreo.get(contactoID).get('Para'));
						}
						else{
							contactosDestinoMail.get('Para').addall(destinatariosCorreo.get(contactoID).get('Para'));
						}
						if(!contactosDestinoMail.containsKey('CC')){
							contactosDestinoMail.put('CC', destinatariosCorreo.get(contactoID).get('CC'));
						}
						else{
							contactosDestinoMail.get('CC').addall(destinatariosCorreo.get(contactoID).get('CC'));
						}
						if(!contactosDestinoMail.containsKey('CCO')){
							contactosDestinoMail.put('CCO', destinatariosCorreo.get(contactoID).get('CCO'));
						}  
						else{
							contactosDestinoMail.get('CCO').addall(destinatariosCorreo.get(contactoID).get('CCO'));
						}
					}
				}
				// Calcular las direcciones del para, cc y cco
				if (contactosDestinoMail != null){
					for (String direccion : contactosDestinoMail.get('Para'))
                    {
						listPara.add(direccion);
					}
					for (String direccion : contactosDestinoMail.get('CC')){
						listCC.add(direccion);
					}
					for (String direccion : contactosDestinoMail.get('CCO')){
						listCCO.add(direccion);
					}
				}

				for (CC_Grupo_Colaborador_Contact__c gcolab : grupoColaboradorExterno){
					if (gcolab.CC_Para_CC__c == 'Para' && String.isNotBlank(gcolab.CC_Email__c)){
						listPara.add(gcolab.CC_Email__c);
					}
					if (gcolab.CC_Para_CC__c == 'CC'){
						listCC.add(gcolab.CC_Email__c);
					}
				}

				//Eliminar duplicados de los receptores.
				set<String> setPara = new set<String>();
				set<String> setCC= new set<String>();
				set<String> setCCO = new set<String>();
				setpara.addAll(listPara);
				setCC.addAll(listCC);
				setCCO.addAll(listCCO);
				listPara.clear();
				listCC.clear();
				listCCO.clear();
				listPara.addall(setPara);
				listCC.addall(setCC);
				listCCO.addall(setCCO);
			}

			// Comprobar los destinatarios, que tenga como mínimo uno informado.
			if (bOk && listPara.isEmpty() && listCC.isEmpty() && listCCO.isEmpty())
			{
				bOk = false;
				retornoEnvioMail.put('error','5');
				retornoEnvioMail.put('detalle','El grupo colaborador <' + grupoDestinoId + '> no tiene configurado ningún destinatario de correo.');
			}

			//Obtener adjuntos
			List<Id> listadoContentVersion = new List<Id>();
			List<String> listadoContentDocument = new List<String>();
			for (ContentDocumentLink linkFile : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, 
													ContentDocument.FileExtension, ContentDocument.Title,
													ContentDocument.CreatedDate, ContentDocument.ContentSize
													FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id])
			{
				if (linkFile.ContentDocument.FileExtension <> 'snote') {
					listadoContentVersion.add(linkFile.ContentDocument.LatestPublishedVersionId);
					listadoContentDocument.add(linkFile.ContentDocumentId);
				}
			}

			// Enviar el correo saliente.
			if (bOk)
			{
				// Preparar el envío.
				String contenidoEmailFinal = htmlEmail;
				contenidoEmailFinal = (String.isNotBlank(htmlFirma)) ? contenidoEmailFinal + '</br></br>' + htmlFirma : contenidoEmailFinal;
				contenidoEmailFinal = (String.isNotBlank(htmlMailsAnteriores)) ? contenidoEmailFinal + '</br>' + htmlMailsAnteriores : contenidoEmailFinal;

				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
				message.setToAddresses(listPara);
				message.setCcAddresses(listCC);
				message.setBccAddresses(listCCO);
				message.setOrgWideEmailAddressId(owaSalienteId);
				message.setUseSignature(false);
				message.setBccSender(false);
				message.setSaveAsActivity(true);
				message.setSubject(subject);
				message.setHtmlBody(contenidoEmailFinal);
				message.setWhatId(caso.Id);
				

				if (!listadoContentVersion.isEmpty()) {
					message.setEntityAttachments(listadoContentVersion);
				}

				if (!test.isRunningTest()){
					Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
					Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

					// Gestionar los errores del envío.
					Boolean envioCorrecto = true;
					for (Messaging.SendEmailResult statusMail : results) {
						if (!statusMail.isSuccess()) {
							envioCorrecto = false;
							Messaging.SendEmailError[] errorMail = statusMail.getErrors();
							bOk = false;
							retornoEnvioMail.put('error','6');
							retornoEnvioMail.put('detalle','Error en el envío de correo de traslado. Detalle: ' + String.valueOf(errorMail));
						}
					}

					if (envioCorrecto) {
						String remitenteMail = '';
						for (OrgWideEmailAddress owea : [SELECT Id, Address FROM OrgWideEmailAddress WHERE Id = :owaSalienteId]) {
							remitenteMail = owea.Address;
							if (String.isNotBlank(remitenteMail)) {
								break;
							}
						}

						List<EmailMessage> listaMailsEnviados = [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id AND Incoming = FALSE AND Subject = :subject AND FromAddress = :remitenteMail ORDER BY MessageDate DESC LIMIT 1];
						if (!listaMailsEnviados.isEmpty() && listadoContentDocument?.isEmpty() == false) {
							listaMailsEnviados[0].SEG_HasAnexo__c = (!listadoContentDocument?.isEmpty() == true) ? true : false;
							Update listaMailsEnviados[0];
						}
					}
				}
			}
		}catch (Exception e){
			retornoEnvioMail.put('error','99');
			retornoEnvioMail.put('detalle','Error no esperado durante el traslado del caso a un colaborador externo. Detalle: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')');
			CBK_Log.error(e);
		}

		return retornoEnvioMail;
	}

	/*OLD, Vamos a quitar el future.
	@future
	public static void enviarEmailAutomatico(Id grupoDestinoId, id grupoOrigenId, id casoId){
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
		Messaging.SingleEmailMessage firma;
		String emailHTML;
		String firmaHTML;
		string stringSaliente;
		Case caso = new Case();
		caso = [select id, SEG_Organizacion__c, SEG_Zona__c from Case where id = :casoId];
		List<SEG_Buzon__mdt> datosBuzon = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = :caso.SEG_Organizacion__c and SEG_Zona__c = :caso.SEG_Zona__c LIMIT 1];
		List<SEG_Buzon__mdt> datosBuzonDefault = new List<SEG_Buzon__mdt>();

		OrgWideEmailAddress[] owea;
		if (datosBuzon.size() > 0){
			owea = [select Id from OrgWideEmailAddress where Address = :datosBuzon[0].SEG_Correo_de_procedencia__c];
		}
		else{
			if (!Test.isRunningTest()){
				datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' and SEG_Zona__c = 'Por defecto' AND DeveloperName = 'Buz_n_por_defecto' LIMIT 1];
				owea = [select Id from OrgWideEmailAddress where Address = :datosBuzonDefault[0].SEG_Correo_de_procedencia__c];
			}
			else{
				datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' and SEG_Zona__c = 'Por defecto' AND DeveloperName = 'BUZON_TEST' LIMIT 1];
				owea = [select Id from OrgWideEmailAddress where Address = :datosBuzonDefault[0].SEG_Correo_de_procedencia__c];
			}
		}

		List<CC_Grupo_Colaborador_Plantilla__c> listPlantillasFirmas = new List<CC_Grupo_Colaborador_Plantilla__c> ();
		listPlantillasFirmas = [SELECT id, SEG_Plantilla__c, SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, CC_Operativa__c from CC_Grupo_Colaborador_Plantilla__c where CC_Grupo_Colaborador__c = :grupoDestinoId and SEG_Plantilla__r.SEG_TipoOperativa__c = 'Firma'];

		List<CC_Grupo_Colaborador_Plantilla__c> listColabPlantillas = new List<CC_Grupo_Colaborador_Plantilla__c> ();
		//listColabPlantillas=[SELECT id,SEG_Plantilla__c,SEG_Plantilla__r.SEG_PlantillaCastellanoID__c from CC_Grupo_Colaborador_Plantilla__c where CC_Grupo_Colaborador__c=:grupoDestinoId and CC_Operativa__c='Trasladar'];
		listColabPlantillas = [SELECT id, SEG_Plantilla__c, SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, CC_Operativa__c from CC_Grupo_Colaborador_Plantilla__c where CC_Grupo_Colaborador__c = :grupoDestinoId];

		if (listColabPlantillas.size() > 0){
			if (String.isNotBlank(listColabPlantillas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c))
			{
				Messaging.SingleEmailMessage messageAux = Messaging.renderStoredEmailTemplate(listColabPlantillas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, UserInfo.getUserId(), caso.Id);
				emailHTML = messageAux.getHtmlBody();
			}
			if (listPlantillasFirmas.size() == 1)
			{
				if (String.isNotBlank(listPlantillasFirmas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c))
				{
					firma = Messaging.renderStoredEmailTemplate(listPlantillasFirmas[0].SEG_Plantilla__r.SEG_PlantillaCastellanoID__c, UserInfo.getUserId(), caso.Id);
					firmaHTML = firma.getHtmlBody();
				}
			}
			String concatEmails;
			//depende de la operativa, enviamos email o bien, concatenamos y enviamos:
			if (listColabPlantillas[0].CC_Operativa__c == 'Remitir'){
				List<EmailMessage> listEmailsFromCase = new List<EmailMessage> ();

				listEmailsFromCase = [select id, TextBody, ToAddress, ValidatedFromAddress, RelatedToId from EmailMessage where RelatedToId = :casoId];
				if (listEmailsFromCase.size() > 0){
					for (EmailMessage emailfromCase : listEmailsFromCase){
						if (String.isBlank(concatEmails)){
							concatEmails = '_________________________________________ <br>';
						}
						else {
							concatEmails = concatEmails + ' De: ' + emailfromCase.ValidatedFromAddress + '<br>';
							concatEmails = concatEmails + ' A: ' + emailfromCase.ToAddress + '<br>';
							concatEmails = concatEmails + emailfromCase.TextBody + '<br>';
							concatEmails = concatEmails + '_________________________________________ <br>';
						}
					}
					if (concatEmails.length() > 32000){
						concatEmails = concatEmails.left(32000);
					}
				}
			}

			//SELECT Id, CC_Nombre__c,CC_Email__c ,CC_Grupo_Colaborador__c,CC_Para_CC__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c = :idGrupo
			List<CC_Grupo_Colaborador_Contact__c> grupoColaboradorExterno = new List<CC_Grupo_Colaborador_Contact__c> ();
			grupoColaboradorExterno = [SELECT Id, CC_Nombre__c, CC_Email__c,CC_Contacto__c, CC_Grupo_Colaborador__c, CC_Para_CC__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c = :grupoDestinoId];
			List<String> listPara = new List<String> ();
			List<String> listCC = new List<String> ();
			List<String> listCCO = new List<String> ();

			//Buscar los canales de comunicación vinculados con el grupo
			List<String> contactEmails = new List<String>();
			Map<String,String> idContCase = new map<String,String>();
			for (CC_Grupo_Colaborador_Contact__c colab : grupoColaboradorExterno) {
				if (colab.CC_Para_CC__c == 'Para') {
					contactEmails.add(colab.CC_Contacto__c);
				}
			}
			for (String contacto : contactEmails){
				idContCase.put(contacto, casoId);
			}

			Map<String,Map<String,Set<String>>> destinatariosCorreo = getDestinatariosContactos(idContCase);
			Map<String,Set<String>> contactosDestinoMail = new Map<String,Set<String>>();
			for (String contactoID : contactEmails) {
				if(destinatariosCorreo.containsKey(contactoID)){
					if(!contactosDestinoMail.containsKey('Para')){
						contactosDestinoMail.put('Para', destinatariosCorreo.get(contactoID).get('Para'));
					}
					else{
						contactosDestinoMail.get('Para').addall(destinatariosCorreo.get(contactoID).get('Para'));
					}
					if(!contactosDestinoMail.containsKey('CC')){
						contactosDestinoMail.put('CC', destinatariosCorreo.get(contactoID).get('CC'));
					}
					else{
						contactosDestinoMail.get('CC').addall(destinatariosCorreo.get(contactoID).get('CC'));
					}
					if(!contactosDestinoMail.containsKey('CCO')){
						contactosDestinoMail.put('CCO', destinatariosCorreo.get(contactoID).get('CCO'));
					}  
					else{
						contactosDestinoMail.get('CCO').addall(destinatariosCorreo.get(contactoID).get('CCO'));
					}
				}
			}
			// Calcular las direcciones del para, cc y cco
			if (contactosDestinoMail != null){
				for (String direccion : contactosDestinoMail.get('Para')){
					listPara.add(direccion);
				}
				for (String direccion : contactosDestinoMail.get('CC')){
					listCC.add(direccion);
				}
				for (String direccion : contactosDestinoMail.get('CCO')){
					listCCO.add(direccion);
				}
			}

			for (CC_Grupo_Colaborador_Contact__c gcolab : grupoColaboradorExterno){
				if (gcolab.CC_Para_CC__c == 'Para' && String.isNotBlank(gcolab.CC_Email__c)){
					listPara.add(gcolab.CC_Email__c);
				}
				if (gcolab.CC_Para_CC__c == 'CC'){
					listCC.add(gcolab.CC_Email__c);
				}
			}
			if (firmaHTML != null){
				stringSaliente = emailHTML + '</br></br>' + firmaHTML;
			}
			else{
				stringSaliente = emailHTML;
			}

			if (String.isNotBlank(concatEmails)){
				stringSaliente = stringSaliente + '<br>' + concatEmails;
			}

			//Eliminar duplicados de los receptores.
			set<String> setPara = new set<String>();
			set<String> setCC= new set<String>();
			set<String> setCCO = new set<String>();
			setpara.addAll(listPara);
			setCC.addAll(listCC);
			setCCO.addAll(listCCO);
			listPara.clear();
			listCC.clear();
			listCCO.clear();
			listPara.addall(setPara);
			listCC.addall(setCC);
			listCCO.addall(setCCO);

			message.setToAddresses(listPara);
			message.setCcAddresses(listCC);
			message.setBccAddresses(listCCO);
			message.setOrgWideEmailAddressId(owea.get(0).Id);
			message.setUseSignature(false);
			message.setBccSender(false);
			message.setSaveAsActivity(false);
			message.setHtmlBody(stringSaliente);
			message.setWhatId(caso.Id);
			if (!test.isRunningTest()){
				Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
				Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
			}
		}
	}
	FIN OLD.*/

	/**
	* @description método para determinar la plantilla para el envío de emails devuelve un mapa de plantillas
	* @param casosSeg -> Listado ID Caso al cual hacemos referencia para recoger la plantilla
	* @param mapNewObj -> Mapa Id/caso con el que comparamos que el caso no se encuentra en la lista negra
	* @param operativa --> Literal para poder filtrar por el tipo de operativa en plantilla
	*/

	static public void enviarCorreoContratos(String plantillaIdioma, String caseId, Contact contacto, List<SEG_Contratos__c> lstContr, List<Messaging.EmailFileAttachment> attachments, Map<String,String> mapaBuzonesOrgZona)
	{
		if (String.isNotBlank(contacto.Email))
		{
			// Determinar el OWA de envío.
			String claveBuzon = 'N/A';
			if (lstContr != null && !lstContr.isEmpty())
			{
				// Nos quedamos con los datos del primer contrato, obtenemos la Org y Zona del caso vinculado de seguimiento.
				SEG_Contratos__c primerContrato = lstContr[0];
				claveBuzon = primerContrato?.SEG_SR_Seguimiento__r?.SEG_Organizacion__c + '##' + primerContrato?.SEG_SR_Seguimiento__r?.SEG_Zona__c;
			}
			String owaSalienteId = String.isNotBlank(mapaBuzonesOrgZona.get(claveBuzon)) ? mapaBuzonesOrgZona.get(claveBuzon) : mapaBuzonesOrgZona.get('Por defecto##Por defecto');

			List<String> address = new List<String> ();
			address.add(contacto.Email);
			Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(plantillaIdioma, contacto.Id, caseId);
			String body = message.htmlbody;
			String[] aBody = body ?.split('</tr>', 2);

			if (aBody.size() == 2) {
				String tableRowsHtml = '';
				for (SEG_Contratos__c c : lstContr) {
					tableRowsHtml += '<tr><td>' + (String.isNotBlank(c.Name) ? c.Name : '') + '</td><td>' + (c.SEG_Fecha_Contrato__c != null ? c.SEG_Fecha_Contrato__c.format() : '')
					+ '</td><td>' + (String.isNotBlank(c.SEG_Descripcion__c) ? c.SEG_Descripcion__c : '') + '</td></tr>';
				}
				body = aBody[0] + '</tr>' + tableRowsHtml + aBody[1];
			}
			if (attachments != null && attachments.size() > 0) {
				message.setFileAttachments(attachments);
			}
			message.setTargetObjectId(contacto.id);
			message.setToAddresses(address);
			//message.setSenderDisplayName('Segmentos CaixaBank - TO CHANGE');
			//message.setReplyTo('test@test.com');
			message.setOrgWideEmailAddressId(owaSalienteId);
			message.setUseSignature(false);
			message.setBccSender(false);
			message.setSaveAsActivity(true);
			message.setWhatId(caseId);
			message.setHtmlBody(body);

			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);


		}
	}
	
	static public Map<String,String> enviarCorreoAcuse(String plantillaIdioma, String caseId, Contact contacto) {

		String body;
		OrgWideEmailAddress[] owea;
		Boolean bOk = true;
		Map<String,String> retornoEnvioMail = new Map<String,String>();
		retornoEnvioMail.put('error','0');
		retornoEnvioMail.put('detalle','');

		// Validar datos obligatorios de entrada.
		if (plantillaIdioma == null || caseId == null || contacto == null)
		{
			retornoEnvioMail.put('error','1');
			retornoEnvioMail.put('detalle','No están disponibles los datos de caso y contacto para el envío del email de acuse.');
			return retornoEnvioMail;
		}

		try{

			List<String> address = new List<String> ();
		address.add(contacto.Email);
		Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(plantillaIdioma, contacto.Id, caseId);

			// ReplyTo según org-zona 20-05
			List<Case> detallesCaso = new List<Case>([SELECT ID, AccountId, SEG_SemillaId__c, SEG_N_case_y_subject__c, SEG_Organizacion__c, SEG_Zona__c, SEG_Grupo__c, SEG_Grupo_colaborador_Externo__c, SEG_Colaborador_externo_Segmentos__c, Status, SEG_Subestado__c, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case where id = :caseId]);
			
			if(detallesCaso.isEmpty())
			{
				bOk = false;
				retornoEnvioMail.put('error','2');
				retornoEnvioMail.put('detalle','No se ha podido obtener los datos del caso <' + caseId + '>');
			}

			if(bOk)
			{
				String mensajeSemilla = '<br><br><br>' + 'NO BORRAR EL IDENTIFICADOR:<br>' + detallesCaso[0].SEG_SemillaId__c + '<br><br><br>' + '------------------------------------------------------------------------------<br>';
				body = message.htmlbody + mensajeSemilla;

				List<SEG_Buzon__mdt> datosBuzon = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = :detallesCaso[0].SEG_Organizacion__c and SEG_Zona__c = :detallesCaso[0].SEG_Zona__c LIMIT 1];

				if (!datosBuzon.isEmpty()) {
					owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :datosBuzon[0].SEG_Correo_de_procedencia__c];
				} else {
					List<SEG_Buzon__mdt> datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' and SEG_Zona__c = 'Por defecto' LIMIT 1];
					if(!datosBuzonDefault.isEmpty())
					{
						owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :datosBuzonDefault[0].SEG_Correo_de_procedencia__c];
					}
					else 
					{
						bOk = false;
						retornoEnvioMail.put('error','3');
						retornoEnvioMail.put('detalle','No se ha podido obtener un buzón de salida para el envío de correo.');
					}
				}
			}
			if(bOk)
			{
				//enviar correo original en AR
		String concatEmails;
		List<EmailMessage> listEmailsFromCase = new List<EmailMessage> ();

		listEmailsFromCase = [SELECT TextBody, HtmlBody, ToAddress, ValidatedFromAddress, RelatedToId from EmailMessage where RelatedToId = :caseId];
		if (listEmailsFromCase.size() > 0)
		{
			for (EmailMessage emailfromCase : listEmailsFromCase)
			{
				if (String.isBlank(concatEmails))
				{
					concatEmails = '_________________________________________ <br>';
					concatEmails = concatEmails + '<br>'+ emailfromCase.HtmlBody + '<br>';
					concatEmails = concatEmails + '_________________________________________ <br>';

				}
				else {
					concatEmails = concatEmails + emailfromCase.HtmlBody + '<br>';
					concatEmails = concatEmails + '_________________________________________ <br>';
				}
			}
			if (concatEmails.length() > 32000)
			{
				concatEmails = concatEmails.left(32000);
			}
		}

		body = body + concatEmails;

		message.setSubject(detallesCaso[0].SEG_N_case_y_subject__c);
		message.setTargetObjectId(contacto.id);
		message.setToAddresses(address);
		//message.setSenderDisplayName('Segmentos CaixaBank - TO CHANGE');
		//message.setReplyTo('test@test.com');
		if (test.isRunningTest())
		{
			message.setSenderDisplayName('Segmentos CaixaBank - TO CHANGE');
			message.setReplyTo('test@test.com');
		}
		else {
			message.setOrgWideEmailAddressId(owea.get(0).Id);
		}
		message.setUseSignature(false);
		message.setBccSender(false);
		message.setSaveAsActivity(true);
		message.setWhatId(caseId);
		message.setHtmlBody(body);

		//Check NO ENVIAR AR
		Boolean car = false;
		Boolean ar = false;
		Boolean are = false;
		List<Account> cuenta = [SELECT id, SEG_EnviarAcuse__c, SEG_No_enviar_Acuse_Recibo_Empresa__c FROM Account WHERE id = :detallesCaso[0].AccountId LIMIT 1];
		List<Contact> cont= [SELECT SEG_No_enviar_Acuse_Recibo__c FROM Contact WHERE Id = :contacto.Id LIMIT 1];
		if (!cont.isEmpty()){
			car = cont[0].SEG_No_enviar_Acuse_Recibo__c;
		}
		if (!cuenta.isEmpty()){
			ar = cuenta[0].SEG_EnviarAcuse__c;
			are = cuenta[0].SEG_No_Enviar_Acuse_Recibo_Empresa__c;
		}

		if(!car && !are){
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			// Gestionar los errores del envío.
			for (Messaging.SendEmailResult statusMail : results) {
				if (!statusMail.isSuccess()) {
					Messaging.SendEmailError[] errorMail = statusMail.getErrors();
					bOk = false;
					retornoEnvioMail.put('error','4');
					retornoEnvioMail.put('detalle','Error en el envío de correo de acuse. Detalle: ' + String.valueOf(errorMail));
				}
			}
		}
	}
}catch (Exception e){
	retornoEnvioMail.put('error','99');
	retornoEnvioMail.put('detalle','Error no esperado durante el envío de correo del nuevo caso. Detalle: ' + e.getMessage());
	CBK_Log.error(e);
}

return retornoEnvioMail;
}

public class AttatchmentsWrapper {
	public Map<Id, List<Messaging.EmailFileAttachment>> attachmentMap { get; set; }
	public ContentVersion contentVersData { get; set; }

	public attatchmentsWrapper(Map<Id, List<Messaging.EmailFileAttachment>> attachmentMapWrap, ContentVersion contentVersDataWrap){
		attachmentMap = attachmentMapWrap;
		contentVersData = contentVersDataWrap;
	}
}

static public Map<Id, List<ContentVersion>> getAttachmentsFromObject(Set<Id> setObjIds, string sFilter) {

	Map<String, String> mapExtensionContentType = new Map<String, String> {
		'pdf' => 'application/pdf'
	};
	Map<Id, Id> mapDocumIdObjectId = new Map<Id, Id> ();
	Map<Id, List<Messaging.EmailFileAttachment>> mapObjectIdAttachments = new Map<Id, List<Messaging.EmailFileAttachment>> ();
	List<ContentVersion> contentVersDataList = new List<ContentVersion>();
	List<attatchmentsWrapper> attachList = new List<attatchmentsWrapper>();
	Map <id, List<ContentVersion>> mapaContratoContentVers = new Map <id, List<ContentVersion>>();
	
	try {
		List<ContentDocumentLink> lstContentDocum = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setObjIds];
		for (ContentDocumentLink cdl : lstContentDocum) {
			mapDocumIdObjectId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
		}
		Set<Id> setDocumentId = mapDocumIdObjectId.KeySet();
		/*String query = 'SELECT Id, Title, VersionData, FileExtension, ContentDocumentId, SEG_Firmado__c ' +
		'FROM ContentVersion WHERE ContentDocumentId IN: setDocumentId ';

		if (String.isNotEmpty(sFilter)) {
			String.escapeSingleQuotes(query);
			query = query + sFilter;
		}*/
		List<ContentVersion> lstContentVersion  = [SELECT Id, Title, FileExtension, ContentDocumentId, SEG_Firmado__c FROM ContentVersion WHERE ContentDocumentId IN: setDocumentId AND SEG_Firmado__c = false];
		/*List<ContentVersion> lstContentVersion = Database.query(query);*/

		//contentVersDataList.addAll(lstContentVersion);
		

		for (ContentVersion contenido :lstContentVersion){
			if (mapDocumIdObjectId.containsKey(contenido.ContentDocumentId)){
				if (mapaContratoContentVers.containskey(mapDocumIdObjectId.get(contenido.ContentDocumentId))){
					mapaContratoContentVers.get(mapDocumIdObjectId.get(contenido.ContentDocumentId)).add(contenido);	
				}
				else{
					List<ContentVersion> contenidos = new List<ContentVersion>();
					contenidos.add(contenido);
					mapaContratoContentVers.put(mapDocumIdObjectId.get(contenido.ContentDocumentId), contenidos);
				}
			}
		}

		/*for (ContentVersion file : lstContentVersion) {
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setFileName(file.Title + '.' + file.FileExtension);
			efa.setBody(file.VersionData);
			if (mapExtensionContentType.containsKey(file.FileExtension)) {
				efa.setContentType(mapExtensionContentType.get(file.FileExtension));
			}
			objectId = mapDocumIdObjectId.get(file.ContentDocumentId);
			if (mapObjectIdAttachments.containsKey(objectId)) {
				mapObjectIdAttachments.get(objectId).add(efa);
				attatchmentsWrapper attach = new attatchmentsWrapper(mapObjectIdAttachments, file);
				attachList.add(attach);
			}
			else {
				mapObjectIdAttachments.put(objectId, new List<Messaging.EmailFileAttachment> { efa });
				attatchmentsWrapper attach = new attatchmentsWrapper(mapObjectIdAttachments, file);
				attachList.add(attach);
			}
		}*/

	} 
	catch(Exception ex) {
		CBK_Log.error(ex);
	}
	
	return mapaContratoContentVers;
}

	static public Map<Id, SEG_Plantilla__c> determinarPlantillaContrato(String caseId, String operativa, String reclamacion) {

		Case caso = [SELECT AccountId, Status, SEG_Organizacion__c, SEG_Zona__c, SEG_Numero_de_centro__c, SEG_Grupo__c, SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c FROM Case WHERE id = :caseId LIMIT 1];
		Map<Id, SEG_Plantilla__c> mapPlantillas;

		mapPlantillas = new Map<Id, SEG_Plantilla__c> ([SELECT id, SEG_Organizacion__c, SEG_Zona__c, SEG_Activa__c, SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c,
		SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c, SEG_PlantillaInglesID__c, SEG_TipoOperativa__c, Reclamaciones__c from SEG_Plantilla__c
		where SEG_TipoOperativa__c = :operativa and Reclamaciones__c = :reclamacion and SEG_Activa__c = true and SEG_Organizacion__c includes(:caso.SEG_Organizacion__c) and SEG_Zona__c includes(:caso.SEG_Zona__c)]);


		if (!mapPlantillas.isEmpty()) {
			//Paso 2: recuperamos los centros de la plantilla. En caso de no tener ninguno la plantilla sigue siendo válida. Si tuviera centros pero no casa con el centro del caso, haríamos remove del mapPlantillas
			Map<Id, SEG_ExcepcionesCentro__c> detallesCentros = new Map<Id, SEG_ExcepcionesCentro__c> ([SELECT id, SEG_Plantilla__c, SEG_CentroEmpresa__c
			from SEG_ExcepcionesCentro__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_CentroEmpresa__c = :caso.SEG_Numero_de_centro__c]);
			if (!detallesCentros.isEmpty()) {
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesCentro__c detalle : detallesCentros.values()) {
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}
				for (Id plantillaID : mapPlantillas.keySet()) {
					if (!auxMapIdPlantillas.containsKey(plantillaID)) {
						mapPlantillas.remove(plantillaID);
					}
				}
			}
			if (detallesCentros.size() == 0)
			{
				for (SEG_ExcepcionesCentro__c excepcionCentro :[SELECT id, SEG_Plantilla__c, SEG_CentroEmpresa__c from SEG_ExcepcionesCentro__c where SEG_Plantilla__c in :mapPlantillas.keyset()])
				{
					if (mapPlantillas.containsKey(excepcionCentro.SEG_Plantilla__c))
					{
						mapPlantillas.remove(excepcionCentro.SEG_Plantilla__c);
					}
				}
			}
			Map<Id, SEG_ExcepcionesGrupo__c> detallesGrupos = new Map<Id, SEG_ExcepcionesGrupo__c> ([SELECT id, SEG_Plantilla__c, SEG_GrupoTrabajoTexto__c from SEG_ExcepcionesGrupo__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_GrupoTrabajoTexto__c = :caso.SEG_Grupo__c]);
			if (detallesGrupos.size() > 0)
			{
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesGrupo__c detalle : detallesGrupos.values())
				{
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}

				for (Id plantillaID : mapPlantillas.keyset())
				{
					if (!auxMapIdPlantillas.containsKey(plantillaID))
					{
						mapPlantillas.remove(plantillaID);

					}
				}
			}
			if (detallesGrupos.size() == 0)
			{
				for (SEG_ExcepcionesGrupo__c excepcionGrupo :[SELECT id, SEG_Plantilla__c, SEG_GrupoTrabajoTexto__c from SEG_ExcepcionesGrupo__c where SEG_Plantilla__c in :mapPlantillas.keyset()])
				{
					if (mapPlantillas.containsKey(excepcionGrupo.SEG_Plantilla__c))
					{
						mapPlantillas.remove(excepcionGrupo.SEG_Plantilla__c);
					}
				}
			}


			//Paso 4: nos queda buscar por empresa y grupo de empresas. Si hay grupo de empresas informado se ignora la empresa. Adecuar
			Map<Id, SEG_ExcepcionesGrupoEmpresa__c> detallesGruposEmpresa = new Map<Id, SEG_ExcepcionesGrupoEmpresa__c> ([SELECT id, SEG_Plantilla__c, SEG_GrupoEmpresa__c from SEG_ExcepcionesGrupoEmpresa__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_GrupoEmpresa__c = :caso.SEG_Grupo_Empresa__c]);

			if (detallesGruposEmpresa.size() == 0)
			{
				Map<Id, SEG_ExcepcionesEmpresa__c> detallesEmpresa = new Map<Id, SEG_ExcepcionesEmpresa__c> ([SELECT id, SEG_Plantilla__c, SEG_Empresa__c from SEG_ExcepcionesEmpresa__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_Empresa__c = :caso.AccountId]);
				//comprobamos empresas
				if (detallesEmpresa.size() > 0)
				{
					Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
					for (SEG_ExcepcionesEmpresa__c detalle : detallesEmpresa.values())
					{
						auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
					}
					for (Id plantillaID : mapPlantillas.keyset())
					{
						if (!auxMapIdPlantillas.containsKey(plantillaID))
						{
							mapPlantillas.remove(plantillaID);

						}
					}
				}
				if (detallesEmpresa.size() == 0)
				{
					for (SEG_ExcepcionesEmpresa__c excepcionEmpresa :[SELECT id, SEG_Plantilla__c, SEG_Empresa__c from SEG_ExcepcionesEmpresa__c where SEG_Plantilla__c in :mapPlantillas.keyset()])
					{
						if (mapPlantillas.containsKey(excepcionEmpresa.SEG_Plantilla__c))
						{
							mapPlantillas.remove(excepcionEmpresa.SEG_Plantilla__c);
						}
					}
				}
			}
			else {
				//comprobamos grupos de empresas
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesGrupoEmpresa__c detalle : detallesGruposEmpresa.values())
				{
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}
				for (Id plantillaID : mapPlantillas.keyset())
				{
					if (!auxMapIdPlantillas.containsKey(plantillaID))
					{
						mapPlantillas.remove(plantillaID);

					}
				}
			}
			//Paso 5: busqueda por clasificación rápida
			//List<SEG_ExcepcionesCR__c> detallesCR = new List<SEG_ExcepcionesCR__c>([SELECT id,SEG_Plantilla__c,SEG_ClasificacionRapida__c from SEG_ExcepcionesCR__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_ClasificacionRapida__c=:caso.SEG_ClasificacionRapida__c]);
			Map<Id, SEG_ExcepcionesCR__c> detallesCR = new Map<Id, SEG_ExcepcionesCR__c> ([SELECT id, SEG_Plantilla__c, SEG_ClasificacionRapida__c from SEG_ExcepcionesCR__c where SEG_Plantilla__c in :mapPlantillas.keyset() and SEG_ClasificacionRapida__c = :caso.SEG_ClasificacionRapida__c]);
			if (detallesCR.size() > 0)
			{
				Map<Id, Id> auxMapIdPlantillas = new Map<Id, Id> ();
				for (SEG_ExcepcionesCR__c detalle : detallesCR.values())
				{
					auxMapIdPlantillas.put(detalle.SEG_Plantilla__c, detalle.SEG_Plantilla__c);
				}
				for (Id plantillaID : mapPlantillas.keyset())
				{
					if (!auxMapIdPlantillas.containsKey(plantillaID))
					{
						mapPlantillas.remove(plantillaID);

					}
				}
			}
			if (detallesCR.size() == 0)
			{
				//en este caso deberemos buscar las CR y quitar del map todas las que existan
				for (SEG_ExcepcionesCR__c excepcionCR :[SELECT id, SEG_Plantilla__c, SEG_ClasificacionRapida__c from SEG_ExcepcionesCR__c where SEG_Plantilla__c in :mapPlantillas.keyset()])
				{
					if (mapPlantillas.containsKey(excepcionCR.SEG_Plantilla__c))
					{
						mapPlantillas.remove(excepcionCR.SEG_Plantilla__c);
					}
				}
			}
		}
		return mapPlantillas;
	}

	static public void enviarCorreo(List<Id> casosSEG, Map<Id, Case> mapNewObj, String operativa)
	{
		List<String> emails = new List<String>();
		for (Id casoId : casosSEG) {
			if (String.isNotBlank(mapNewObj.get(casoId).ContactEmail)) {
				emails.add(mapNewObj.get(casoId).ContactEmail);
			}
		}

		Map<String, String> emailsListaNegra = SEG_MetodosComunes.recuperaListaNegra(emails);
		List<SEG_Buzon__mdt> buzones = [SELECT id, SEG_Correo_de_procedencia__c,SEG_Organizacion__c,SEG_Zona__c FROM SEG_Buzon__mdt];
		List<OrgWideEmailAddress> owas = [SELECT Id,Address FROM OrgWideEmailAddress];
		Map<String, OrgWideEmailAddress> mapaOwas = new Map<String, OrgWideEmailAddress>();
		for(OrgWideEmailAddress direcciones : owas){
			mapaOwas.put(direcciones.Address, direcciones);
		}
		String owea;

		for (Id casoId : casosSEG) {
		//if (operativa != 'Acuse de correo reciclado') {
			if ((!emailsListaNegra.containsKey(mapNewObj.get(casoId).ContactEmail)
			&& !emailsListaNegra.containsKey('@' + mapNewObj.get(casoId).ContactEmail.split('@').get(1))
			&& (mapNewObj.get(casoId).SEG_Estado_Contacto__c != 'Pendiente de verificación' || operativa != 'Acuse de correo reciclado')
			&& mapNewObj.get(casoId).SEG_No_AR_Account__c == false
			&& mapNewObj.get(casoId).SEG_No_AR_Contact__c == false)
			|| Test.isRunningTest()) 
			{
				Map<Id, SEG_Plantilla__c> mapPlantilla = new Map<Id, SEG_Plantilla__c> ();
				mapPlantilla = SEG_MetodosComunes.determinarPlantillaExclusiva(mapNewObj.get(casoId), operativa);

				if (mapPlantilla.size() == 1 || Test.isRunningTest()) {
					SEG_Plantilla__c plantillaFinal;
					String plantillaIdioma;

					for (SEG_Plantilla__c plantilla : mapPlantilla.values()) {
						plantillaFinal = plantilla;
						if (mapNewObj.get(casoId).SEG_Idioma__c == 'es') {
							plantillaIdioma = plantillaFinal.SEG_PlantillaCastellanoID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'ca') {
							plantillaIdioma = plantillaFinal.SEG_PlantillaCatalanID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'en') {
							plantillaIdioma = plantillaFinal.SEG_PlantillaInglesID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'eu') {
							plantillaIdioma = plantillaFinal.SEG_PlantillaEuskeraID__c;
						} else if (mapNewObj.get(casoId).SEG_Idioma__c == 'ga') {
							plantillaIdioma = plantillaFinal.SEG_PlantillaGalegoID__c;
						}
					}
					if (String.isNotBlank(plantillaIdioma)) {
						for(SEG_Buzon__mdt buzon : buzones){
							if (buzon.SEG_Organizacion__c == mapNewObj.get(casoId).SEG_Organizacion__c && buzon.SEG_Zona__c == mapNewObj.get(casoId).SEG_Zona__c){
								if(mapaOwas.containsKey(buzon.SEG_Correo_de_procedencia__c)){
									owea = mapaOwas.get(buzon.SEG_Correo_de_procedencia__c).id;
								}
							}
						}
						if (owea == null){
							for(SEG_Buzon__mdt buzon : buzones){
								if (buzon.SEG_Organizacion__c == 'Por defecto' && buzon.SEG_Zona__c == 'Por defecto'){
									if(mapaOwas.containsKey(buzon.SEG_Correo_de_procedencia__c)){
										owea = mapaOwas.get(buzon.SEG_Correo_de_procedencia__c).id;
									}
								}
							}
						}
						
						/*List<SEG_Buzon__mdt> datosBuzon = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = :mapNewObj.get(casoId).SEG_Organizacion__c and SEG_Zona__c = :mapNewObj.get(casoId).SEG_Zona__c LIMIT 1];

						OrgWideEmailAddress[] owea;
						if (datosBuzon.size() > 0) {
							owea = [select Id from OrgWideEmailAddress where Address = :datosBuzon[0].SEG_Correo_de_procedencia__c];
						} else {
							List<SEG_Buzon__mdt> datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' and SEG_Zona__c = 'Por defecto' LIMIT 1];
							owea = [select Id from OrgWideEmailAddress where Address = :datosBuzonDefault[0].SEG_Correo_de_procedencia__c];
						}*/

						//EmailMessage emailEnviado = [SELECT Incoming, SEG_HasAnexo__c, HtmlBody FROM EmailMessage WHERE ParentId = :casoId ORDER BY MessageDate desc limit 1];
                        
						Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(plantillaIdioma, mapNewObj.get(casoId).ContactId, casoId);
                        String mensajeSemilla = '<br><br><br>NO BORRAR EL IDENTIFICADOR:<br>' + mapNewObj.get(casoId).SEG_SemillaId__c + '<br><br><br>';
                        String body = email.htmlbody + mensajeSemilla;
						String subject;
						String asuntoMail = email?.subject;
						if(string.isNotBlank(asuntoMail) && !asuntoMail.contains(mapNewObj.get(casoId).caseNumber)){   
							subject = asuntoMail;
							subject = (mapNewObj.get(casoId).caseNumber +' - ' + subject);
						}
						else{
							subject = mapNewObj.get(casoId).SEG_N_case_y_subject__c;
						}

						Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
						message.setTargetObjectId(mapNewObj.get(casoId).ContactId);
						//message.setOrgWideEmailAddressId(owea.get(0).Id);
						message.setOrgWideEmailAddressId(owea);
						message.setUseSignature(false);
						message.setBccSender(false); 
						message.setSaveAsActivity(true);
						message.setSubject(subject);
						//EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where Id = :plantillaIdioma];

						//VFR 17/12 - Solo se usa la operativa de acuse de recibo reciclado. /////////////////////////
						//if (operativa != 'Acuse de correo reciclado') {
							message.setHtmlBody(body);
							message.setWhatId(casoId); //This is important for the merge fields in template to work
						//}
						Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
						Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
					}
				}
			}
			/* VFR 17/12 - Solo se usa la operativa de acuse de recibo reciclado. /////////////////////////
			}
			//Para casos reciclado, envio de AR, se envía el correo sin buscar plantilla porque no podemos incluir la nueva Semilla en plantilla
			
			else {
				List<SEG_Buzon__mdt> datosBuzon = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = :mapNewObj.get(casoId).SEG_Organizacion__c and SEG_Zona__c = :mapNewObj.get(casoId).SEG_Zona__c LIMIT 1];

				OrgWideEmailAddress[] owea;
				if (datosBuzon.size() > 0) {
					owea = [select Id from OrgWideEmailAddress where Address = :datosBuzon[0].SEG_Correo_de_procedencia__c];
				} else {
					List<SEG_Buzon__mdt> datosBuzonDefault = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' and SEG_Zona__c = 'Por defecto' LIMIT 1];
					owea = [select Id from OrgWideEmailAddress where Address = :datosBuzonDefault[0].SEG_Correo_de_procedencia__c];
				}

				EmailMessage emailEnviado = [SELECT Incoming, SEG_HasAnexo__c, HtmlBody FROM EmailMessage WHERE ParentId = :casoId ORDER BY MessageDate DESC LIMIT 1];


				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.setTargetObjectId(mapNewObj.get(casoId).ContactId);
				message.setOrgWideEmailAddressId(owea.get(0).Id);
				message.setUseSignature(false);
				message.setBccSender(false);
				message.setSaveAsActivity(true);

				EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName like '%Acuse%' Limit 1];
				message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, mapNewObj.get(casoId).ContactId, mapNewObj.get(casoId).Id);
				message.setSubject('Caso reciclado # ' + mapNewObj.get(casoId).SEG_N_case_y_subject__c);
				message.setOrgWideEmailAddressId(owea.get(0).Id);
				if (mapNewObj.get(casoId).SEG_Idioma__c == 'es')
				{
					message.setHtmlBody('Le informamos que hemos recepcionado su email y hemos abierto nuevo caso con número :<b> ' + mapNewObj.get(casoId).SEG_N_case_y_subject__c + ' </b>ha sido creado.<p>' +
					'\n#@SEG:' + mapNewObj.get(casoId).SEG_SemillaId__c + '#\n');

				}
				if (mapNewObj.get(casoId).SEG_Idioma__c == 'ca')
				{
					message.setHtmlBody('Informem que hem recepcionat el seu email i hem obert un nou cas amb el número :<b> ' + mapNewObj.get(casoId).SEG_N_case_y_subject__c + ' </b>ha sigut creat.<p>' +
					'\n#@SEG:' + mapNewObj.get(casoId).SEG_SemillaId__c + '#\n');

				}
				if (mapNewObj.get(casoId).SEG_Idioma__c == 'en')
				{
					message.setHtmlBody('Your new case:<b> ' + mapNewObj.get(casoId).SEG_N_case_y_subject__c + ' </b>has been created.<p>' +
					'\n#@SEG:' + mapNewObj.get(casoId).SEG_SemillaId__c + '#\n');

				}
				if (mapNewObj.get(casoId).SEG_Idioma__c == 'eu')
				{
					message.setHtmlBody('Your new case:<b> ' + mapNewObj.get(casoId).SEG_N_case_y_subject__c + ' </b>has been created.<p>' +
					'\n#@SEG:' + mapNewObj.get(casoId).SEG_SemillaId__c + '#\n');

				}
				if (mapNewObj.get(casoId).SEG_Idioma__c == 'ga')
				{
					message.setHtmlBody('Your new case:<b> ' + mapNewObj.get(casoId).SEG_N_case_y_subject__c + ' </b>has been created.<p>' +
					'\n#@SEG:' + mapNewObj.get(casoId).SEG_SemillaId__c + '#\n');
				}
				Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
				Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
			}*/
		}
	} 

	/**
	* @description Método para iniciar gestión de trazas de integraciones de Segmentos.
	*/
	public static CC_TrazaInt__c inicioTraza (String interfaz, String origen, String identificador, String mensajeEntrada)
	{
		CC_TrazaInt__c trazaInt;

		CC_InterfaceSettings__mdt configTrazas = CC_MetodosUtiles.getInterfazConfig (interfaz);
		if (configTrazas != null && configTrazas.CC_TrazaActiva__c || Test.isRunningTest())
		{
			trazaInt = new CC_TrazaInt__c();
			trazaInt.CC_FechaInicio__c = System.now();
			trazaInt.Name = interfaz;
			trazaInt.CC_IdOrigen__c = origen.left(20);
			trazaInt.CC_Identificador__c = identificador;
			trazaInt.CC_MensajeEntrada__c = mensajeEntrada;
		}

		return trazaInt;
	}

	/**
	* @description Método para finalizar una traza con resultado OK.
	*/
	public static CC_TrazaInt__c finTraza(CC_TrazaInt__c traza, String mensajeSalida) {

		//Finalización de traza en curso con resultado OK
		if (traza != null) {
			traza.CC_FechaFin__c = System.now();
			traza.CC_FinOK__c = true;
			traza.CC_MensajeSalida__c = mensajeSalida;
			insert traza;
		}
		return traza;
	}

	/**
	* @description Método para finalizar una traza con resultado KO.
	*/
	public static CC_TrazaInt__c finTraza(CC_TrazaInt__c traza, String mensajeSalida, String tipoError, String detalleError) {

		//Finalización de traza en curso con resultado KO
		if (traza != null) {
			traza.CC_FechaFin__c = System.now();
			traza.CC_FinOK__c = false;
			traza.CC_MensajeSalida__c = mensajeSalida;
			traza.CC_TipoError__c = tipoError;
			traza.CC_DetalleError__c = detalleError;
			insert traza;
		}
		return traza;
	}

	/**
	* @description Método para finalizar una traza con resultado KO.
	*/
	public static CC_TrazaInt__c finTrazaNoInsert(CC_TrazaInt__c traza, String mensajeSalida, Boolean finOk, String tipoError, String detalleError) {

		//Finalización de traza en curso con resultado KO
		if (traza != null) {
			traza.CC_FechaFin__c = System.now();
			traza.CC_FinOK__c = finOk;
			traza.CC_MensajeSalida__c = mensajeSalida;
			traza.CC_TipoError__c = tipoError;
			traza.CC_DetalleError__c = detalleError;
		}
		return traza;
	}

	private static Messaging.SendEmailResult enviarCorreoGrupoAutomaticoEnvioCorreo(Id idCaso, Id idGestor) {
		List<String>listaAnexos = new List<String>();
		List<String>listadoAttachments = new List<String>();
		Messaging.SendEmailResult resultado;
		Boolean plantillaOk = false;

		if (idCaso == null || idGestor == null)
		{
			return null;
		}

		Case caso = [SELECT SEG_Organizacion__c, SEG_Zona__c, SEG_Idioma__c, AccountId, Account.AV_Idioma__c, ContactId, Contact.CC_Idioma__c
						FROM Case WHERE Id = :idCaso];

		String owaSalienteId = '';
		Map<String,String> mapaBuzonesOrgZona = SEG_MetodosComunes.recuperarOWASegmentos();
		String claveBuzon = caso.SEG_Organizacion__c + '##' + caso.SEG_Zona__c;
		owaSalienteId = String.isNotBlank(mapaBuzonesOrgZona.get(claveBuzon)) ? mapaBuzonesOrgZona.get(claveBuzon) : mapaBuzonesOrgZona.get('Por defecto##Por defecto');

		/*
		String direccionBuzonSalida = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt
										WHERE SEG_Organizacion__c = :caso.SEG_Organizacion__c AND SEG_Zona__c = :caso.SEG_Zona__c
										LIMIT 1]?.SEG_Correo_de_procedencia__c;
		*/
		Map<String, List<String>> destinatariosGestor = getDestinatariosGestor(idGestor, caso.AccountId);
		Map<Id, List<SEG_Plantilla__c>> configuracionesPlantilla = SEG_PlantillasHandler.determinarPlantillas(new List<Case>{caso}, 'Envío automático gestor');
		if (!configuracionesPlantilla.isEmpty()) {
			Id idPlantilla = getIdPlantillaIdioma(configuracionesPlantilla.get(idCaso)[0], caso);
			if (String.isNotBlank(idPlantilla)) {
				plantillaOk = true;

				Contact contacto = [SELECT Email FROM Contact WHERE Email != NULL LIMIT 1];
				Messaging.SingleEmailMessage correo = Messaging.renderStoredEmailTemplate(idPlantilla, contacto.Id, idCaso);
				String body = correo.htmlbody;

				List<EmailMessage> primeraComunicacion = [SELECT HtmlBody FROM EmailMessage WHERE RelatedToId = :idCaso AND Incoming = true ORDER BY CreatedDate ASC];
				if(primeraComunicacion.size() > 0)
				{
					body = body + '<br>_________________________________________<br><br>' + primeraComunicacion[0].htmlBody;
				}

				for(ContentDocumentLink anex : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :idCaso])
				{
					listaAnexos.add(anex.ContentDocumentId);
				}
				if(!listaAnexos.isEmpty())
				{
					listadoAttachments = SEG_redactarEmail_Controller.getAttachments(listaAnexos);
				}
				if (!listadoAttachments.isEmpty())
				{
					correo.setEntityAttachments(listadoAttachments);
				}
				
				correo.setOrgWideEmailAddressId(owaSalienteId);
				correo.setWhatId(idCaso);
				correo.setSaveAsActivity(true);
				//correo.setTargetObjectId([SELECT Email FROM Contact WHERE Email != NULL LIMIT 1].Id);
				correo.setTargetObjectId(contacto.id);
				correo.setTreatTargetObjectAsRecipient(false);
				correo.setToAddresses(destinatariosGestor.get('Para'));
				correo.setCcAddresses(destinatariosGestor.get('CC'));
				correo.setBccAddresses(destinatariosGestor.get('CCO'));
				correo.setHtmlBody(body);
				//correo.setTemplateId(idPlantilla);
				correo.setUseSignature(false);
				resultado = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo})[0];
			}
		}
		if (!test.isRunningTest()){
			if (resultado.isSuccess()) {
				EmailMessage emailEnviado = [SELECT Id FROM EmailMessage WHERE ParentId = :idCaso AND Incoming = FALSE
											ORDER BY MessageDate DESC LIMIT 1];
				if(listaAnexos.size() > 0){
					if (listaAnexos[0] != '0') {
						emailEnviado.SEG_HasAnexo__c = true;
					}
				}
				update emailEnviado;
			}
		}

		if (!plantillaOk) {
			postChatter(idCaso, false, 'No se ha podido enviar el correo, no se encuentra la plantilla.');
		}
		return resultado;
	}

	public static Map<String, List<String>> getDestinatariosGestor(Id idGestor, Id idCuenta) {
		Set<String> listaPara = new Set<String>();
		Set<String> listaCc = new Set<String>();
		Set<String> listaCco = new Set<String>();

		List<Contact> correoPrincipalGestor = [SELECT Email FROM Contact WHERE Id = :idGestor LIMIT 1];
		if (!correoPrincipalGestor.isEmpty() && correoPrincipalGestor[0].email != null) {
			listaPara.add(correoPrincipalGestor[0].Email);
		}

		for (CC_Canal_Com__c canalComunicacion : [SELECT CC_Email__c, SEG_ParaCC__c FROM CC_Canal_Com__c
													WHERE RecordType.DeveloperName = 'CC_Email' AND CC_ContactoId__c = :idGestor
													AND CC_Email__c != NULL AND (CC_CuentaId__c = :idCuenta OR CC_CuentaId__c = NULL)]) {
			if (canalComunicacion.SEG_ParaCC__c == 'Para') {
				listaPara.add(canalComunicacion.CC_Email__c);
			} if (canalComunicacion.SEG_ParaCC__c == 'CC') {
				listaCc.add(canalComunicacion.CC_Email__c);
			} if (canalComunicacion.SEG_ParaCC__c == 'CCO') {
				listaCco.add(canalComunicacion.CC_Email__c);
			}
		}
		return new Map<String, List<String>>{
			'Para' => new List<String>(listaPara),
			'CC' => new List<String>(listaCc),
			'CCO' => new List<String>(listaCco)
		};
	}

	private static void postChatter(Id idCaso, Boolean isRichText, String body) {
		FeedItem post = new FeedItem();
		post.ParentId = idCaso;
		post.isRichText = isRichText;
		post.Body = body;
		insert post;
	}

	@TestVisible private static Id getIdPlantillaIdioma(SEG_Plantilla__c configuracionPlantilla, Case caso) {
		if (String.isNotBlank(caso.SEG_Idioma__c)) {
			if (caso.SEG_Idioma__c == 'ga') {
				return configuracionPlantilla.SEG_PlantillaGalegoID__c;
			} else if (caso.SEG_Idioma__c == 'ca') {
				return configuracionPlantilla.SEG_PlantillaCatalanID__c;
			} else if (caso.SEG_Idioma__c == 'en') {
				return configuracionPlantilla.SEG_PlantillaInglesID__c;
			} else if (caso.SEG_Idioma__c == 'eu') {
				return configuracionPlantilla.SEG_PlantillaEuskeraID__c;
			}
		} else if (String.isNotBlank(caso.Contact.CC_Idioma__c)) {
			if (caso.Contact.CC_Idioma__c == 'ga') {
				return configuracionPlantilla.SEG_PlantillaGalegoID__c;
			} else if (caso.Contact.CC_Idioma__c == 'ca') {
				return configuracionPlantilla.SEG_PlantillaCatalanID__c;
			} else if (caso.Contact.CC_Idioma__c == 'en') {
				return configuracionPlantilla.SEG_PlantillaInglesID__c;
			} else if (caso.Contact.CC_Idioma__c == 'eu') {
				return configuracionPlantilla.SEG_PlantillaEuskeraID__c;
			}
		} else if (String.isNotBlank(caso.Account.AV_Idioma__c)) {
			if (caso.Account.AV_Idioma__c == '004') {
				return configuracionPlantilla.SEG_PlantillaGalegoID__c;
			} else if (caso.Account.AV_Idioma__c == '001') {
				return configuracionPlantilla.SEG_PlantillaCatalanID__c;
			} else if (caso.Account.AV_Idioma__c == '010') {
				return configuracionPlantilla.SEG_PlantillaInglesID__c;
			} else if (caso.Account.AV_Idioma__c == '003') {
				return configuracionPlantilla.SEG_PlantillaEuskeraID__c;
			}
		}
		return configuracionPlantilla.SEG_PlantillaCastellanoID__c;
	}

	/**
	 * @description Método bulkificado para recuperar los correos de un contacto y cuenta.
	 * @param mapaContactosCuenta Identificadores de contacto y cuenta a obtener los emails de comunicación.
	 * @return Mapa con los datos obtenidos por cada uno de los contactos.
	 */
	public static Map<String,Map<String,Set<String>>> getDestinatariosContactos (Map<String,String> mapaContactosCuenta)
	{
		Set<Id> listadoClientesIds = new Set<Id>();
		Map<String,Map<String,Set<String>>> retornoDestinatarios = new Map<String,Map<String,Set<String>>>();

		if (mapaContactosCuenta == null || mapaContactosCuenta.isEmpty())
		{
			return retornoDestinatarios;
		}

		// Recuperar todos los datos de los contactos.
		for (Contact contacto : [SELECT Id, Email FROM Contact WHERE Id IN :mapaContactosCuenta.keySet()])
		{
			// Inicializar la estructura de los contactos.
			String claveMapaResultado = contacto.Id;
			//String cuentaId = String.isNotBlank(mapaContactosCuenta.get(contacto.Id)) ? '_' + mapaContactosCuenta.get(contacto.Id) : '';
			//claveMapaResultado = claveMapaResultado + cuentaId;

			if (String.isNotBlank(mapaContactosCuenta.get(claveMapaResultado)))
			{
				listadoClientesIds.add(mapaContactosCuenta.get(claveMapaResultado));
			}

			Set<String> listaPara = new Set<String>();
			Set<String> listaCc = new Set<String>();
			Set<String> listaCco = new Set<String>();

			if (String.isNotBlank(contacto.Email))
			{
				listaPara.add(contacto.Email);
			}

			Map<String,Set<String>> datosContacto = new Map<String,Set<String>>();
			datosContacto.put('Para', listaPara);
			datosContacto.put('CC', listaCc);
			datosContacto.put('CCO', listaCco);

			retornoDestinatarios.put(claveMapaResultado, datosContacto);
		}

		// Buscar todos los canales de comunicación.
		for (CC_Canal_Com__c canalComunicacion : [SELECT Id, CC_Email__c, SEG_ParaCC__c, CC_ContactoId__c, CC_CuentaId__c FROM CC_Canal_Com__c
													WHERE RecordType.DeveloperName = 'CC_Email' AND CC_ContactoId__c IN :mapaContactosCuenta.keySet()
													AND CC_Email__c != NULL AND (CC_CuentaId__c IN :listadoClientesIds OR CC_CuentaId__c = NULL)])
		{
			String nuevoPara = (canalComunicacion.SEG_ParaCC__c == 'Para') ? canalComunicacion.CC_Email__c : '';
			String nuevoCC = (canalComunicacion.SEG_ParaCC__c == 'CC') ? canalComunicacion.CC_Email__c : '';
			String nuevoCCO = (canalComunicacion.SEG_ParaCC__c == 'CCO') ? canalComunicacion.CC_Email__c : '';

			String claveMapaResultado = canalComunicacion.CC_ContactoId__c;
			String cuentaId = mapaContactosCuenta.get(claveMapaResultado);
			String cuentaCanal = canalComunicacion.CC_CuentaId__c;
			
			// Añadir a la estructura de retorno si cumple las condiciones.
			if (cuentaId == cuentaCanal || String.isBlank(cuentaCanal))
			{
				Map<String,Set<String>> datosContacto = retornoDestinatarios.get(claveMapaResultado);
				
				if (String.isNotBlank(nuevoPara))
				{
					datosContacto?.get('Para')?.add(nuevoPara);
				}

				if (String.isNotBlank(nuevoCC))
				{
					datosContacto?.get('CC')?.add(nuevoCC);
				}

				if (String.isNotBlank(nuevoCCO))
				{
					datosContacto?.get('CCO')?.add(nuevoCCO);
				}
			}
		}

		return retornoDestinatarios;
	}

	/**
	 * 
	 */
	public static Map<String,String> recuperarOWASegmentos ()
	{
		// Preparar los datos del mail saliente. Modo Bulk.
		Map<String,String> mapaBuzones = new Map<String,String>();
		for (SEG_Buzon__mdt datosBuzon : [SELECT DeveloperName, SEG_Correo_de_procedencia__c, SEG_Organizacion__c, SEG_Zona__c  FROM SEG_Buzon__mdt])
		{
			String claveMap = datosBuzon.SEG_Organizacion__c + '##' + datosBuzon.SEG_Zona__c;
			if (String.isNotBlank(datosBuzon.SEG_Correo_de_procedencia__c) && datosBuzon.DeveloperName != 'BUZON_TEST')
			{
				mapaBuzones.put(claveMap, datosBuzon.SEG_Correo_de_procedencia__c);
			}
		}

		// Buscar los identificadores de OWEA.
		Map<String,String> relacionOWEA = new Map<String,String>();
		for (OrgWideEmailAddress owea : [select Id, Address from OrgWideEmailAddress where Address = :mapaBuzones.values()])
		{
			relacionOWEA.put(owea.Address, owea.Id);
		}

		// Preparar retorno del método.
		Map<String,String> retornoOWA = new Map<String,String>();
		for (String claveMail : mapaBuzones.keySet())
		{
			String correoOrigen = mapaBuzones.get(claveMail);
			String owaId = relacionOWEA.get(correoOrigen);

			retornoOWA.put(claveMail, owaId);
		}

		return retornoOWA;
	}

	/**
	 * @description Limpieza de correos de multiples buzones de segmentos sobre un correo entrante.
	 * @param listadoCorreos
	 * @return Listado de correos parseados.
	 */
	public static List<String> depuracionCorreosBuzonSegmentos (List<String> listadoCorreos, List<String> caseEmail){
		if (listadoCorreos != null && !listadoCorreos.isEmpty() && caseEmail != null && !caseEmail.isEmpty()){
			for(String email : caseEmail){
				listadoCorreos = depuracionCorreosBuzonSegmentos(listadoCorreos, email);
			}
		}
	   return listadoCorreos;
	}

	/**
	 * @description Limpieza de correos de buzones de segmentos sobre un correo entrante.
	 * @param listadoCorreos
	 * @return Listado de correos parseados.
	 */
	public static List<String> depuracionCorreosBuzonSegmentos (List<String> listadoCorreos, String caseEmail){
		List<String> retornoCorreos = new List<String>();

		if (listadoCorreos == null || listadoCorreos.isEmpty()){
			return retornoCorreos;
		}

		Set<String> buzonSegmentos = new Set<String>();
		for (SEG_Buzon__mdt datosBuzon : [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Correo_de_procedencia__c =:caseEmail]){
			if (String.isNotBlank(datosBuzon.SEG_Correo_de_procedencia__c)){
				buzonSegmentos.add(datosBuzon.SEG_Correo_de_procedencia__c);
			}
		}

		Boolean firstMail = true;
		for (String correo : listadoCorreos){
			String correoAux = (String.isNotBlank(correo)) ? correo.trim() : '';
			if (String.isNotBlank(correoAux) && !buzonSegmentos.contains(correoAux)){
				correoAux = (firstMail) ? correoAux : ' ' + correoAux;
				retornoCorreos.add(correoAux );
			}
		}

		return retornoCorreos;
	}/*
	public static List<String> depuracionCorreosBuzonSegmentos (List<String> listadoCorreos)
	{
		List<String> retornoCorreos = new List<String>();
		if (listadoCorreos == null || listadoCorreos.isEmpty()){return retornoCorreos;
		}
		Set<String> buzonSegmentos = new Set<String>();
		for (SEG_Buzon__mdt datosBuzon : [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt])
		{
			if (String.isNotBlank(datosBuzon.SEG_Correo_de_procedencia__c))
			{
				buzonSegmentos.add(datosBuzon.SEG_Correo_de_procedencia__c);
			}
		}
		Boolean firstMail = true;
		for (String correo : listadoCorreos)
		{
			String correoAux = (String.isNotBlank(correo)) ? correo.trim() : '';
			if (String.isNotBlank(correoAux) && !buzonSegmentos.contains(correoAux))
			{
				correoAux = (firstMail) ? correoAux : ' ' + correoAux;
				retornoCorreos.add(correoAux );
			}
		}
		return retornoCorreos;
	}*/
	
	/**
	 * @description Recuperar el grupo SEG_BO definido en la plataforma.
	 * @return Identificador del grupo BO.
	 */
	public static Id recuperarGrupoBO ()
	{
		List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];
		Id grupoBO = colasBO[0].Id; // Si no está configurado, provocaremos un error.
		return grupoBO;
	}
}