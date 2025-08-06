@RestResource(urlMapping='/AltaOportunidad/*')
global with sharing class CSBD_WS_AltaOportunidad {
	public static String respuestaLog = '';

	private static List<CSBD_IdentificacionImagin__c> identificacionImagin = [SELECT CSBD_AplicarLogica__c FROM CSBD_IdentificacionImagin__c LIMIT 1];
	//Método principal de la integración
	@HttpPost
	global static CSBD_WS_AltaOportunidad_Output altaOportunidad() {
		RestRequest req = RestContext.request;
		String requestString = req.requestBody.toString();
		CSBD_WS_AltaOportunidad_Input input = (CSBD_WS_AltaOportunidad_Input)JSON.deserializeStrict(requestString, CSBD_WS_AltaOportunidad_Input.class);
		return gestionEntradaOportunidad(input, 'WS', requestString);
	}
	public static CSBD_WS_AltaOportunidad_Output gestionEntradaOportunidad(CSBD_WS_AltaOportunidad_Input input, String origen) {
		return gestionEntradaOportunidad(input, origen, null);
	}

	//Método con la gestión de oportunidades, para separar el servicio web del Apex Email Service.
	public static CSBD_WS_AltaOportunidad_Output gestionEntradaOportunidad(CSBD_WS_AltaOportunidad_Input input, String origen, String requestString) {
		CSBD_WS_AltaOportunidad_NowInSales.oportunidadWS = origen == 'WS' ? true : false;
		List<Opportunity> oportunidadesCreadas = new List<Opportunity>();
		CSBD_WS_AltaOportunidad_Output retorno = new CSBD_WS_AltaOportunidad_Output();
		Set<String> idsNumSolicitud = new Set<String>();
		List<Opportunity> prestamosFiltrados = new List<Opportunity>();
		Set<String> productosOportunidadSet = new Set<String>();
		Set<String> productosImagin = new Set<String>();
		Map<String, Map<String, CC_Lista_Valores__c>> empresaProductoValor= new Map<String, Map<String, CC_Lista_Valores__c>>();
		Set<String> tiposOportunidad = new Set<String>();
		Set<String> nombresHorariosListaValores = new Set<String>();
		Map<String, List<CC_Lista_Valores__c>> empresaHorario = new Map<String, List<CC_Lista_Valores__c>>();
		Map<String, BusinessHours> nombreHorario = new Map<String, BusinessHours>();
		String centro;


		for (CSBD_WS_AltaOportunidad_Input.Solicitud solicitud : input.solicitudes) {

			if (solicitud.numsolicitud == null) {
				solicitud.numsolicitud = 'String auto: ' + String.valueOf((Math.random() * 10000000));
			}
			if (solicitud.tipoSolicitud == 'desistimientoPrestamo') {
				idsNumSolicitud.add(solicitud.numsolicitud);
			}
			if (String.isNotBlank(solicitud.idProducto)) {
				productosOportunidadSet.add(solicitud.idProducto);
			}
			else if (String.isNotBlank(solicitud.nombreProducto)) {
				productosOportunidadSet.add(solicitud.nombreProducto);
			}
		}

		//Cuando llega un desistimientoPrestamo buscamos la oportunidad existente para cerrarla
		if (!idsNumSolicitud.isEmpty()) {
			prestamosFiltrados = [SELECT CSBD_Identificador__c, IsClosed, CSBD_Alta_omnichannel__c, CSBD_Now_Presolicitud__c FROM Opportunity
													WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo')
													AND CSBD_Now_Presolicitud__c IN :idsNumSolicitud];
		}
		if (!productosOportunidadSet.isEmpty()) {
			//Listado de productos y horarios que deben trasladarse
			for (CC_Lista_Valores__c valorLista: [SELECT Name, CSBD_Aplica_horario__c, CSBD_Empresa_proveedora__c, CSBD_Tipo_regla__c, RecordType.DeveloperName, CSBD_Hora_inicio_turno__c, CSBD_Hora_fin_turno__c, CSBD_Centro__c FROM CC_Lista_Valores__c
													WHERE
														(RecordType.DeveloperName = 'CC_Valor' AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto'
														AND Name = :productosOportunidadSet AND CC_Activa__c = TRUE AND CC_Valor_SFDC__c = 'imaginBank')
													OR
														(Recordtype.DeveloperName = 'CSBD_Regla_traspaso_oportunidad' AND CC_Activa__c = true AND CC_Fecha_Vigencia_Inicio__c < :CBK_UtilsDate.nowSYS()  AND CC_Fecha_Vigencia_Fin__c > :CBK_UtilsDate.nowSYS()
														AND ((Name = :productosOportunidadSet AND CSBD_Tipo_regla__c = 'Producto') OR CSBD_Tipo_regla__c = 'Horario' OR CSBD_Tipo_regla__c = 'Tipo oportunidad')) ]) {

				//Listado de productos para evaluar si la oportunidad entrante es imaginBank o CaixaBank
				if (valorLista.RecordType.DeveloperName == 'CC_Valor') {
					productosImagin.add(valorLista.Name);
				}
				//Productos que aplican para la redirección
				if (valorLista.CSBD_Tipo_regla__c == 'Producto') {
					if (!empresaProductoValor.containsKey(valorLista.CSBD_Empresa_proveedora__c)) {
						empresaProductoValor.put(valorLista.CSBD_Empresa_proveedora__c, new Map<String, CC_Lista_Valores__c>());
					}
					empresaProductoValor.get(valorLista.CSBD_Empresa_proveedora__c).put(valorLista.Name, valorLista);
				}
				//Tipos de oportunidad que aplican para la redirección
				if (valorLista.CSBD_Tipo_regla__c == 'Tipo oportunidad') {
					tiposOportunidad.add(valorLista.Name);
				}
				//Horarios que aplican para la redirección
				if (valorLista.CSBD_Tipo_regla__c == 'Horario') {
					if (!empresaHorario.containsKey(valorLista.CSBD_Empresa_Proveedora__c)) {
						empresaHorario.put(valorLista.CSBD_Empresa_Proveedora__c, new List<CC_Lista_Valores__c>());
					}
					empresaHorario.get(valorLista.CSBD_Empresa_Proveedora__c).add(valorLista);
					nombresHorariosListaValores.add(valorLista.Name);
				}
			}
			//Horarios que aplican
			for (BusinessHours horario: [SELECT Id, Name FROM BusinessHours WHERE Name = :nombresHorariosListaValores]) {
				nombreHorario.put(horario.Name, horario);
			}
		}

		List<CSBD_Campos_blacklist__mdt> camposComprobarMetadato = [SELECT MasterLabel, CSBD_Campo_API_Name__c FROM CSBD_Campos_blacklist__mdt];
		List<CC_TrazaInt__c> trazasLista = new List<CC_TrazaInt__c>();


		for (CSBD_WS_AltaOportunidad_Input.Solicitud solicitud : input.solicitudes) {
			//Para cada solicitud
			CSBD_WS_AltaOportunidad_Input.Solicitud inputSolicitudOriginal = solicitud; //Para la descripción de la tarea si se crea oportunidad
			CSBD_WS_AltaOportunidad_Output.Respuesta respuesta = new CSBD_WS_AltaOportunidad_Output.Respuesta();
			Boolean finOK = false;


			try {
				Boolean oportunidadNowInSales = true;
				String empresaProveedora = 'Now In Sales';
				Boolean aplicaHorario = false;

				respuestaLog += 'Tipo oportunidad: ' + solicitud.tipoSolicitud + '. ';
				respuestaLog += 'Fecha entrada: ' + CBK_UtilsDate.nowSYS().date()+ '. ';
				respuestaLog += 'Hora entrada: ' + CBK_UtilsDate.nowSYS().time()+ '. ';

				//Lógica Oportunidad Now In Sales vs traslado a Mis Clientes AV_CreateOpportunityCallMe
				//El tipo de oportunidad está dado de alta, si no nunca se trasladará
				if (tiposOportunidad.contains(solicitud.tipoSolicitud)) {

					//Unificamos el valor de producto, dependiendo del tipo de solicitud llega en un valor u otro
					String producto = '';

					if (String.isNotBlank(solicitud.idProducto)) {
						producto = solicitud.idProducto;
					}
					else if (String.isNotBlank(solicitud.nombreProducto)) {
						producto = solicitud.nombreProducto;
					}

					respuestaLog += 'Producto oportunidad: ' + producto + '. ';
					
					//Obtener los accountsIds pertenecientes a cada oportunidad mediante el método identificarCliente.
					//Creación de un mapa relacionando el numsolicitud de la futura oportunidad con su accountId.
					
					Map<String, Object> datosCliente = new  Map<String, Object>();
					if(String.isBlank(solicitud.indInTouch)){
						datosCliente = CSBD_WS_AltaOportunidad_Campos.identificarCliente(solicitud, datosCliente, respuesta);
					}

					//Solo se comprueba la lógica de traspasar si indInTouch == 'S' 
					if (solicitud.indInTouch == 'S' || (datosCliente.containsKey('AV_IndicadoresClientes__c') && datosCliente.get('AV_IndicadoresClientes__c').toString().contains('8'))) {

						//¿Es empresa imagin?  -- el producto está dado de alta en la lista de valores -- no tenemos en cuenta indInTouch = S/N
						if (oportunidadNowInSales) {
							//Evaluamos producto si es imagin o caixa
							if (!productosImagin.isEmpty() && productosImagin.contains(producto) && ((!identificacionImagin.isEmpty() && identificacionImagin[0].CSBD_AplicarLogica__c == false) || (datosCliente.containsKey('AV_IndicadoresClientes__c') && datosCliente.get('AV_IndicadoresClientes__c').toString().contains('11')))) {
								oportunidadNowInSales = false;
								empresaProveedora = 'imaginBank';
							}
						}
						//Si no es imagin y se cumple indInTouch == 'S' --> Es cliente intouch
						if (oportunidadNowInSales && (solicitud.indInTouch == 'S' || (datosCliente.containsKey('AV_IndicadoresClientes__c') && datosCliente.get('AV_IndicadoresClientes__c').toString().contains('8')))) {
							oportunidadNowInSales = false;
							empresaProveedora = 'inTouch';
						}

						respuestaLog += 'Empresa identificada: ' + empresaProveedora + '. ';

						//OportunidadNowInSales == false --> Pertenece a inTouch o imaginBank
						//Evaluamos producto
						if (!oportunidadNowInSales) {
							//Lo devolvemos a true para evaluar si se cumple la nueva condición
							oportunidadNowInSales = true;
							if (empresaProductoValor.containsKey(empresaProveedora)) {
								Map<String, CC_Lista_Valores__c> productoValor = empresaProductoValor.get(empresaProveedora);
								if (productoValor.containsKey(producto)) {
									oportunidadNowInSales = false;
									centro = String.isNotBlank(productoValor.get(producto).CSBD_Centro__c) ? productoValor.get(producto).CSBD_Centro__c : empresaProveedora;
									aplicaHorario = productoValor.get(producto).CSBD_Aplica_horario__c;
								}
							}
							respuestaLog += '¿Encuentra producto? ' + !oportunidadNowInSales + '. ';
							if (!oportunidadNowInSales) {
								respuestaLog += '¿Aplica horario? ' + aplicaHorario + '. ';
								respuestaLog += 'Centro: ' + centro + '. ';
							}
						}

						//OportunidadNowInSales == false --> Pertenece a inTouch o imaginBank
						//aplicaHorario == true ---> lo evaluamos
						if (!oportunidadNowInSales && aplicaHorario) {
							//Lo devolvemos a true para evaluar si se cumple la nueva condición
							oportunidadNowInSales = true;
							Datetime fechaEfectiva = CBK_UtilsDate.nowSYS();
							if (solicitud.tipoSolicitud == 'cmb') {
								fechaEfectiva = CSBD_WS_AltaOportunidad_NowInSales.calcularHoraCMB(solicitud);
							}
							if (empresaHorario.containsKey(empresaProveedora)) {
								//Sacar business hours que aplican
								String nombreHorarioLista = '';
								for (CC_Lista_Valores__c valorHorario: empresaHorario.get(empresaProveedora)) {
									if (valorHorario.CSBD_Hora_inicio_turno__c <= fechaEfectiva.time() && fechaEfectiva.time() <= valorHorario.CSBD_Hora_fin_turno__c) {
										nombreHorarioLista = valorHorario.Name;
									}
								}
								if (String.isNotBlank(nombreHorarioLista) && nombreHorario.containsKey(nombreHorarioLista)) {
									Businesshours horarioVigente = nombreHorario.get(nombreHorarioLista);

									if (BusinessHours.isWithin(horarioVigente.Id, fechaEfectiva)) {
										oportunidadNowInSales = false;
									}
								}
							}
							respuestaLog += '¿Está dentro de horario? ' + !oportunidadNowInSales + '. ';
							respuestaLog += 'Fecha asignación: ' + fechaEfectiva.date() + '. ';
							respuestaLog += 'Hora asignación: ' + fechaEfectiva.time() + '. ';
						}
					}
				}
				else {
					respuestaLog += 'Tipo de solicitud ' + solicitud.tipoSolicitud + ' no dado de alta para traslado. ';
				}


				solicitud.numsolicitud = solicitud.numsolicitud.contains('String auto:') ? '' : solicitud.numsolicitud; //limpiamos el campo numsolicitud si nos venía vacío en un principio para dejarlo igual.

				respuestaLog += '¿Es una oportunidad Now In Sales? ' + oportunidadNowInSales + '. ';


				//Lógica finalizada, creo la oportunidad en la aplicación que corresponda
				if (!oportunidadNowInSales) {
					//Llamada a altaOportunidad Mis Clientes
					AV_CreateOpportunityCallMe.statusResponse statusResponseAV = AV_CreateOpportunityCallMe.createOpp(requestString,centro);

					System.debug('statusResponseAV: ' + statusResponseAV);

					if (Boolean.valueOf(statusResponseAV.isSuccess)) {
						finOK = true;
					respuesta.resultado = 'OK Traspasada: ' + empresaProveedora;
					respuesta.opportunityId = statusResponseAV.idOpp;
					respuesta.detalleError = statusResponseAV.errorMessage;
					respuestaLog += '¿Se ha creado la oportunidad en la aplicación Mis Clientes? ' + statusResponseAV.isSuccess;
					} else {
						finOK = false;
						respuesta.resultado = 'KO';
						respuesta.codigoError = 'KO';
						respuesta.detalleError = statusResponseAV.errorMessage;
					}

				} else {
					//Llamada altaOportunidad Now In Sales
					Map<String, Object> retornoAlta = CSBD_WS_AltaOportunidad_NowInSales.altaOportunidad_NowInSales(solicitud, inputSolicitudOriginal, respuesta, camposComprobarMetadato, prestamosFiltrados);
					respuesta = (CSBD_WS_AltaOportunidad_Output.Respuesta)retornoAlta.get('respuesta');
					oportunidadesCreadas = (List<Opportunity>)retornoAlta.get('oportunidadesCreadas');
					finOK = true;
				}
			} catch (Exception e) {
				//Error en la solicitud actual
				respuesta.resultado = 'KO';
				respuesta.codigoError = String.valueOf(e.getCause());
				respuesta.detalleError = 'tipoSolicitud: ' + solicitud.tipoSolicitud + ' - ExceptionType: ' + e.getTypeName() + ' - ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.');
				finOK = false;
				CBK_Log.error(e);
			} finally {
				//Se añade resultado a la respuesta
				respuesta.detalleOportunidad = respuestaLog;

				System.debug('respuestaLog::: '+respuestaLog);

				//Dejar trazabilidad del log
				String detalleError = '';
				if (String.isNotBlank(respuesta.codigoError)) {
					detalleError += 'Código error: ' + respuesta.codigoError + '. ';
				}
				if (String.isNotBlank(respuesta.detalleError)) {
					detalleError += 'Detalle error: ' + respuesta.detalleError;

				}
				if (CC_TrazaInt.trazaActiva('CSBD_WS_AltaOportunidad')) {
					CC_TrazaInt__c traza = CC_TrazaInt.generarTraza('CSBD_WS_AltaOportunidad', respuesta.opportunityId, respuesta.resultado, respuesta.detalleOportunidad, detalleError, requestString, finOK);
					trazasLista.add(traza);
				}

				retorno.add(respuesta);
			}
		}

		Insert trazasLista;

		//Now In Sales: Lógica a ejecutar asíncronamente después de que el servicio responda
		if (!oportunidadesCreadas.isEmpty()) {
			CSBD_WS_AltaOportunidad_NowInSales.ejecutarLogicaAsincrona(JSON.serialize(new CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona(oportunidadesCreadas)));
			//Envio de mensaje RCS
			//CSBD_InfobipController.sendInfobipMessage(JSON.serialize(new CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona(oportunidadesCreadas)));
		}

		informarIdentificadoresRespuesta(retorno);
		return retorno;
	}

	private static void informarIdentificadoresRespuesta(CSBD_WS_AltaOportunidad_Output respuestas) {
		List<Id> idOportunidades = new List<Id>();
		for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : respuestas.respuestas) {
			if (String.isNotBlank(respuesta?.opportunityId)) {
				idOportunidades.add(respuesta.opportunityId);
			}
		}
		if (!idOportunidades.isEmpty()) {
			Map<Id, Opportunity> oportunidades = new Map<Id, Opportunity>([SELECT CSBD_Identificador__c FROM Opportunity
																			WHERE Id IN :idOportunidades]);
			for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : respuestas.respuestas) {
				if (String.isBlank(respuesta.opportunityNumero)) {
					respuesta.opportunityNumero = oportunidades.get(respuesta.opportunityId)?.CSBD_Identificador__c;
				}
			}
		}
	}

    public static Map<String, Object> altaOportunidadMac(Id idCaso) {
        CSBD_AltaOportunidadMac__e evento = new CSBD_AltaOportunidadMac__e();
        evento.CSBD_CaseId__c = idCaso;
        Database.SaveResult resultado = EventBus.publish(evento);
        Map<String, Object> retorno = new Map<String, Object>();
        retorno.put('success', resultado.isSuccess());
        retorno.put('errorMessage', resultado.isSuccess() ? null : resultado.getErrors()[0].getMessage());
        return retorno;
    }

	public static void altaOportunidadMacEvento(Id recordId) {
		Case casoOrigen = [SELECT AccountId, Account.AV_IndicadoresClientes__c, ContactId, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name
							FROM Case WHERE Id = :recordId];

		String claveProducto = '';
		if (String.isNotBlank(casoOrigen.CC_MCC_Tematica__r.Name)) {
			claveProducto += casoOrigen.CC_MCC_Tematica__r.Name;
			if (String.isNotBlank(casoOrigen.CC_MCC_ProdServ__r.Name)) {
				claveProducto += '.' + casoOrigen.CC_MCC_ProdServ__r.Name;
			}
		}

		CSBD_WS_AltaOportunidad_Input.Solicitud inputSolicitud = new CSBD_WS_AltaOportunidad_Input.Solicitud();
		inputSolicitud.tipoSolicitud = 'mac';
		inputSolicitud.casoOrigen = recordId;
		inputSolicitud.nombreProducto = claveProducto;
		inputSolicitud.accountId = casoOrigen.AccountId;
		inputSolicitud.contactId = casoOrigen.ContactId;
		inputSolicitud.motivo = casoOrigen.CC_MCC_Motivo__r.Name;
		inputSolicitud.indicadoresCliente = casoOrigen.Account.AV_IndicadoresClientes__c;

		CSBD_WS_AltaOportunidad_Input input = new CSBD_WS_AltaOportunidad_Input();
		input.solicitudes.add(inputSolicitud);
		CSBD_WS_AltaOportunidad_Output.Respuesta outputRespuesta = gestionEntradaOportunidad(input, 'MAC').respuestas[0];

		System.debug('referencia_usuario: ' + outputRespuesta.referencia_usuario);
		System.debug('resultado: ' + outputRespuesta.resultado);
		System.debug('codigoError: ' + outputRespuesta.codigoError);
		System.debug('detalleError: ' + outputRespuesta.detalleError);
		System.debug('opportunityId: ' + outputRespuesta.opportunityId);
		System.debug('opportunityNumero: ' + outputRespuesta.opportunityNumero);
		System.debug('detalleOportunidad: ' + outputRespuesta.detalleOportunidad);

    }
}