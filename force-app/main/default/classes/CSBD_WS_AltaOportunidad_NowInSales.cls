public with sharing class CSBD_WS_AltaOportunidad_NowInSales {

	public static Boolean oportunidadWS = false;

	public static Map<String, Object> altaOportunidad_NowInSales(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud, CSBD_WS_AltaOportunidad_Input.Solicitud inputSolicitudOriginal, CSBD_WS_AltaOportunidad_Output.Respuesta respuesta, List<CSBD_Campos_blacklist__mdt> camposComprobarMetadato, List<Opportunity> prestamosFiltrados) {
		Map<String, Object> respuestaAltaOportunidadNowInSales = new Map<String, Object>();
		List<Opportunity> oportunidadesCreadas = new List<Opportunity>();

		Boolean rechazadoBlacklist = false;
		Boolean rechazadoLeadExiste = false;
		String  leadExistenteOpp = '';
		//Valores por defecto de la respuesta para la solicitud actual
		respuesta.referencia_usuario = solicitud.referencia_usuario;
		respuesta.resultado = 'OK';
		respuesta.codigoError = '';
		respuesta.detalleError = '';

		if (solicitud.tipoSolicitud == 'desistimientoPrestamo') {
			List<Opportunity> prestamos = new List<Opportunity>();
			//Rechazo de la oportunidad de préstamo ya existente (no crea nueva oportunidad)
			for (Opportunity prestamoFiltrado : prestamosFiltrados) {
				if (solicitud.numsolicitud == prestamoFiltrado.CSBD_Now_Presolicitud__c) {
					prestamos.add(prestamoFiltrado);
				}
			}

			if (prestamos.size() == 1 && !prestamos[0].IsClosed) {
				CSBD_Opportunity.cerrarOportunidad(prestamos[0].Id, 'Perdida', 'Desistido por cliente desde Now');
				CSBD_Activity.crearActividad(prestamos[0].Id, 'Desistimiento cliente', 'Completed', 'Desistimiento cliente', 'Motivo indicado: \n\n' + solicitud.descripMotivo);
				respuesta.opportunityId = prestamos[0].Id;
				respuesta.opportunityNumero = prestamos[0].CSBD_Identificador__c;
				if (prestamos[0].CSBD_Alta_omnichannel__c) {
					CSBD_GestorOportunidad.desactivarGestorOportunidad(prestamos[0].Id);
				}
			} else {
				respuesta.resultado = 'KO';
				String detalleError = 'No es posible completar el desistimiento del préstamo ya que ';
				if (prestamos.size() > 1) {
					respuesta.detalleError = detalleError + 'hay más de una oportunidad con la misma referencia indicada';
				} else if (prestamos.size() < 1) {
					respuesta.detalleError = detalleError + 'no se encuentra una oportunidad con la referencia indicada';
				} else if (prestamos[0].IsClosed) { //prestamos.size == 1
					respuesta.detalleError = detalleError + 'éste ya se había completado previamente';
				}
			}
			//break; //(for)
		} else if (!tiposSolicitudAdmitidos().contains(solicitud.tipoSolicitud)) {
			//tipoSolicitud no contemplado, se responde con un error
			respuesta.resultado = 'KO';
			respuesta.detalleError = 'Tipo de solicitud no reconocida: ' + solicitud.tipoSolicitud;
		} else {
			comprobarSiCmbEsCmn(solicitud);
			Map<String, Object> campos = new Map<String, Object>(); //Campos con los que se inserta la oportunidad

			String recordTypeDeveloperName = CSBD_WS_AltaOportunidad_Campos.informarCamposOportunidad(solicitud, campos, respuesta);

			//Comprobación de pertenencia a la Blacklist
			//Listado de campos a validar que son susceptibles de blacklist
			Map<String, String> labelAPINameCamposBlacklistMap = new Map<String, String>();
			for (CSBD_Campos_blacklist__mdt campoMetadato: camposComprobarMetadato) {
				labelAPINameCamposBlacklistMap.put(campoMetadato.MasterLabel, campoMetadato.CSBD_Campo_API_Name__c);
			}
			//Recupero los valores de la oportunidad para los campos que pueden ser susceptibles de blacklist
			Set<String> valoresCamposBlacklist = new Set<String>();
			for (String camposComprobar : labelAPINameCamposBlacklistMap.values()) {
				if (campos.containsKey(camposComprobar)) {
					valoresCamposBlacklist.add(String.valueOf(campos.get(camposComprobar)));
				}
			}
			//Recupero los valores de la lista de valores que sean iguales a los valores de la blacklist
			String estadoInicial = 'Nueva';
			String etapaVentasInicial = 'Solicitud';
			String resolucionInicial = '';
			for (CC_Lista_Valores__c listaValores : CC_Listas_Valores.LookupValuesSet('CSBD: Blacklist', valoresCamposBlacklist)) {
				String valor = labelAPINameCamposBlacklistMap.get(listaValores.CC_Valor__c);
				Object campoSolicitud;
				if (campos.containsKey(valor)) {
					campoSolicitud = campos.get(valor);
					if (listaValores.Name == campoSolicitud) {
						estadoInicial = 'Rechazada';
						etapaVentasInicial = 'Rechazada';
						resolucionInicial = 'Pertenece a la blacklist';
						rechazadoBlacklist = true;
						break;
					}
				}
			}
			Boolean cmnDerivacionPorCorreo = false;
			Boolean cmnDerivacionComdataPorWS = false;

			//US Facilitea: Verificar para hipotecas, cmn y cmb, sólo si el origen es faciliteacasa
			List<String> tiposSolicitudChequear = CSBD_IdentificarOppsPHDSettingManager.getInstance().getSolicitudWSAltaOppList();
			List<String> origenesChequear = CSBD_IdentificarOppsPHDSettingManager.getInstance().getOrigenList();
			Boolean origenChequear = String.isNotBlank((String)campos.get('CSBD_Now_Origen__c')) && origenesChequear.contains((String)campos.get('CSBD_Now_Origen__c'));
			if(tiposSolicitudChequear.contains(solicitud.tipoSolicitud) && origenChequear){
				List<String> numDocumentos = new List<String>();
				if(String.isNotBlank(solicitud.nif)){
					numDocumentos.add(solicitud.nif);
				}
				if(String.isNotBlank(solicitud.nif1Tit)){
					numDocumentos.add(solicitud.nif1Tit);
				}
				if(String.isNotBlank(solicitud.nif2Tit)){
					numDocumentos.add(solicitud.nif2Tit);
				}
				if(!numDocumentos.isEmpty()){
					Map<String, Object> resultadoChequeo = CSBD_DetectarOportunidadesSimilares.getInstance(numDocumentos, '', (String)campos.get('CSBD_Now_Origen__c')).buscarOportunidadSimilares();
					//el numDocumente en algunos casos pueden ser dos? titular 1 y titular 2
					if(resultadoChequeo.containsKey('existLead') && (Boolean)resultadoChequeo.get('existLead') == true){
						estadoInicial = 'Rechazada';
						etapaVentasInicial = 'Rechazada';
						resolucionInicial = 'Lead existente con origen: ' + (resultadoChequeo.get('origenLead') != null ? resultadoChequeo.get('origenLead') : 'N/I');
						rechazadoLeadExiste = true;
						leadExistenteOpp = (String)resultadoChequeo.get('opportunityName');
					}
				}
			}
			//END US Facilitea


			//Solo se ejecuta si no se ha rechazado en la blacklist
			if (!rechazadoBlacklist && !rechazadoLeadExiste) {
				//Calcular si aplica lógica específica según tipo de solicitud
				if (solicitud.tipoSolicitud == 'cmn') {
					if (solicitud?.buzonCajeros == true) {
						if (CSBD_MetodosComunes.externalizarCmnPorCorreo(solicitud?.tipoCampanya)) {
							//Crear la oportunidad rechazada con resolución "Externalizada" y externalizar CMN por correo
							estadoInicial = 'Rechazada';
							etapaVentasInicial = 'Rechazada';
							resolucionInicial = 'Externalizada';
							cmnDerivacionPorCorreo = true;
						} else if (!CSBD_MetodosComunes.redirigirCmnCajeosAAltaOportunidad(solicitud?.tipoCampanya)) {
							//Si no se redirige a la lógica de AltaOportunidad no se realizan acciones ni se crea oportunidad
							respuesta.resultado = 'OK';
							respuesta.codigoError = '';
							respuesta.detalleError = '';
							respuesta.opportunityId = '';
							respuesta.opportunityNumero = '';
							//break; //Se gestiona la siguiente solicitud de la lista
						} else {
							//Si se redirige a la lógica de AltaOportunidad se procede sin acciones específicas
							CSBD_MetodosComunes.traducirTipoCampanyaAProductoProceso(solicitud);
						}
					}
					if (CSBD_MetodosComunes.externalizarCmnComdata(solicitud.idProducto)) {
						//Crear la oportunidad rechazada con resolución "Externalizada" y externalizar CMN a Comdata por WS
						estadoInicial = 'Rechazada';
						etapaVentasInicial = 'Rechazada';
						resolucionInicial = 'Externalizada';
						cmnDerivacionComdataPorWS = true;
					}
				} else if (solicitud.tipoSolicitud == 'cmb') {
					estadoInicial = 'Pendiente Cita';
				}
			}

			//Creación de la oportunidad
			campos.put('CSBD_Resolucion__c', campos.containsKey('CSBD_Resolucion__c') ? campos.get('CSBD_Resolucion__c') : resolucionInicial);
			campos.put('CSBD_Estado__c', campos.containsKey('CSBD_Estado__c') ? campos.get('CSBD_Estado__c') : estadoInicial);
			campos.put('StageName', campos.containsKey('CSBD_Estado__c') && campos.get('CSBD_Estado__c') == 'Rechazada' ? campos.get('CSBD_Estado__c') : etapaVentasInicial);
			campos.putAll(desagruparAtributoOrigen(solicitud.origen));

			if (oportunidadWS) {
				campos.put('CSBD_SistemaOrigen__c', 'WS');
			}

			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad(recordTypeDeveloperName, campos);

			//Creación de la tarea de tipo "Solicitud recibida"
			String cuerpoTarea = JSON.serializePretty(inputSolicitudOriginal, true);
			CSBD_Activity.crearActividad(oportunidad.Id, 'Solicitud recibida', 'Completed', 'Solicitud recibida', cuerpoTarea.left(30000));

			if(rechazadoLeadExiste){
				CSBD_Activity.crearActividad(oportunidad.Id, 'Rechazada Lead existente', 'Completed', 'Rechazada Lead existente', resolucionInicial + '\n\nOportunidad encontrada: ' + leadExistenteOpp);
			}

			//Respuesta del servicio
			respuesta.opportunityId = oportunidad.Id;

			//Solo se ejecuta si no se ha rechazado en la blacklist
			if (!rechazadoBlacklist && !rechazadoLeadExiste) {
				//Añadimos a lista para ejecutar lógica asíncrona
				oportunidadesCreadas.add(oportunidad);

				//Lógica adicional específica según tipo de solicitud
				if (solicitud.tipoSolicitud == 'cmn') {
					if (cmnDerivacionPorCorreo) {
						String asuntoTarea;
						//Envío de correo y creación de tarea de la oportunidad
						if (CSBD_MetodosComunes.enviarCorreoCmn(oportunidad.Id)) {
							//Envío de correo OK
							asuntoTarea = 'Externalización de CMN por correo';
						} else {
							//Envío de correo KO
							asuntoTarea = 'Externalización de CMN por correo (ERROR)';
						}
						CSBD_Activity.crearActividad(oportunidad.Id, asuntoTarea, 'Completed', asuntoTarea, null);
					} else if (cmnDerivacionComdataPorWS) {
						//Envío a Comdata por WS y creación de la tarea de la oportunidad
						CSBD_CMN_Comdata.Input inputWsComdata = new CSBD_CMN_Comdata.Input();
						inputWsComdata.recordId = oportunidad.Id;
						inputWsComdata.producto = solicitud.idProducto;
						inputWsComdata.nif = solicitud.nif;
						inputWsComdata.nombre = solicitud.nombre;
						inputWsComdata.apellido_1 = solicitud.apellidos;
						inputWsComdata.apellido_2 = solicitud.apellidos_2;
						inputWsComdata.telefono = solicitud.telefono;
						inputWsComdata.proceso = solicitud.proceso;
						inputWsComdata.origen = solicitud.origen;
						CSBD_CMN_Comdata.enviarCMNComdata(inputWsComdata); //future
					}
				} else if (solicitud.tipoSolicitud == 'cmb') {
					Datetime startDateTime = calcularHoraCMB(solicitud);
					//llamar a CSBD_Opportunity.programarCita
					CSBD_Opportunity.programarCita(oportunidad.Id, true, null, startDateTime);
				}
			}
		}

		respuestaAltaOportunidadNowInSales.put('oportunidadesCreadas', oportunidadesCreadas);
		respuestaAltaOportunidadNowInSales.put('respuesta', respuesta);

		return respuestaAltaOportunidadNowInSales;
	}

	public static Datetime calcularHoraCMB(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud) {
		Datetime startDateTime;
		Time horaActual = CBK_UtilsDate.nowSYS().time();
		Date fechaActual = CBK_UtilsDate.nowSYS().date();
		Time horaIniCita = Time.newInstance(Integer.valueOf(solicitud.horaIni), Integer.valueOf(solicitud.minIni), 0, 0);
		Time horaFinCita = Time.newInstance(Integer.valueOf(solicitud.horaFin), Integer.valueOf(solicitud.minFin), 0, 0);

		//horaIniCita > horaActual ---- reprogramada::: fechaHoy - horaIniCita
		if (horaIniCita > horaActual) {
			startDateTime = DateTime.newInstance(fechaActual, horaIniCita);
		}
		//horaIniCita <= horaActual <= horaFinCita --- reprogramada::: fechaHoy - horaActual
		else if(horaIniCita <= horaActual && horaActual <= horaFinCita){
			startDateTime = DateTime.newInstance(fechaActual, horaActual);
		}
		//horaActual > horaFinCita --- reprogramada:::: fechaMañana --- horaIniCita
		else if(horaActual > horaFinCita){
			startDateTime = DateTime.newInstance(fechaActual.addDays(1), horaIniCita);
		}
		return startDateTime;
	}

	@future(callout=true)
	public static void ejecutarLogicaAsincrona(String inputJson) {
		List<Id> ids = ((InputLogicaAsincrona)JSON.deserialize(inputJson, InputLogicaAsincrona.class)).idOportunidades;

		//Acciones de la lógica asíncrona (todas capturan excepción para que en caso
		//de error en una de ellas no se haga rollback de toda la lógica asíncrona)
		try {
			CSBD_CMN.rechazarOportunidadesRobotPortal(ids);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try {
			CSBD_SIR.actualizarDatosRiesgoClientesOportunidades(ids, true);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try {
			CSBD_Control_Duplicados.controlDuplicados(ids);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try {
			CSBD_Hipoteca.automatismosHipotecas(ids);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try {
			CSBD_Desistimiento.automatismosDesistimientos(ids);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try {
			CSBD_Denegacion_Automatica_Oportunidades.denegacionAutomaticaOportunidades(ids);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try {
			altaOmnichannel(ids);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try {
			insertarOportunidadesHijas(ids);
		} catch (Exception e) {
			CBK_Log.error(e);
		}
		try{
			//CSBD_InfobipController.sendInfobipMessage(JSON.serialize(new CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona(oportunidadesCreadas)))
			CSBD_InfobipController.sendInfobipMessage(inputJson);
		}catch(Exception e){
			CBK_Log.error('CSBD_Infobip_Call_Future', e);
		}
	}

	public class InputLogicaAsincrona {
		//Necesaria para mandar los datos serializados al método future
		public List<Id> idOportunidades {get;set;}
		public InputLogicaAsincrona(List<Opportunity> oportunidades) {
			this.idOportunidades = CC_MetodosUtiles.listaCampo(oportunidades, 'Id', false);
		}
	}

	private static void altaOmnichannel(List<Id> idOportunidades) {
		List<String> nombreRecordTypesOmnichannel = CC_MetodosUtiles.listaCampo(
			[SELECT Name FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor'
				AND CC_Lista__r.Name = 'CSBD: Motor de asignación - Tipos de oportunidad que se asignan'
				AND CC_Activa__c = true], 'Name'
		);

		List<Opportunity> oportunidades = [SELECT Name, CSBD_Empresa_Proveedora__c, CSBD_Idioma_Solicitud__c, RecordtypeId, CSBD_Turno_Contacto__c, CSBD_Familia_Producto__c, CSBD_Skill__c,
											CSBD_Horario_Contacto__c, CSBD_OC_Canal_Entrada__c, CSBD_OC_Prioridad__c, RecordType.Name, CSBD_Producto__c
											FROM Opportunity WHERE Id = :idOportunidades AND RecordType.Name = :nombreRecordTypesOmnichannel AND IsClosed = FALSE];
		if (!oportunidades.isEmpty()) {
			//Registro del objeto CSBD_Gestor_Oportunidad__c que enrutará la oportunidad via omnichannel - en principio solo habrá una, ya que no llega más de una solicitud simultáneamente
			CSBD_GestorOportunidad.insertarGestorOportunidad(oportunidades);
		}
	}

	public static void insertarOportunidadesHijas(List<Id> idOportunidades) {
		List<Opportunity> oportunidadesCreadas = [SELECT RecordType.Name, AV_Producto__c, AV_FechaModificacion__c, AccountId, RecordTypeId, Name, Description, StageName, Probability, CloseDate, OwnerId, CSBD_Circuito_Contratacion_Online__c,
			CSBD_Contact__c, CSBD_Diferencial_Limite__c, CSBD_Email_Solicitud__c, CSBD_Empresa_Proveedora_Logo__c, CSBD_Empresa_Proveedora__c, CSBD_Estado__c, CSBD_Estado_Tracking__c, CSBD_Idioma_Solicitud__c,
			CSBD_Importe_Producto_Principal__c, CSBD_Limite_Compra_Estrella__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c,
			CSBD_Motivo_Pendiente_Interno__c, CSBD_Now_Boton__c, CSBD_Now_Codigo_Producto_Formato__c, CSBD_Now_Canal_Peticion__c, CSBD_Now_Id_Producto__c, CSBD_Skill__c, CSBD_Prioridad_Tracking__c,
			CSBD_Resolucion__c, CSBD_Scoring_Riesgo__c, CSBD_Subestado_Tracking__c, CSBD_Telefono_Solicitud__c, CSBD_Codigo_Estado_Tracking__c, CSBD_Now_Apellido1__c, CSBD_Now_Apellido2__c,
			CSBD_Now_Apellidos1_1Tit__c, CSBD_Now_Apellidos1_2Tit__c, CSBD_Now_Apellidos2_1Tit__c, CSBD_Now_Apellidos2_2Tit__c, CSBD_Now_Canal__c, CSBD_Now_CodProducto__c, CSBD_Now_DescripMotivo__c,
			CSBD_Now_Descripcion__c, CSBD_Now_DirVivienda__c, CSBD_Now_EmailGestor__c, CSBD_Now_EmailOficinaLO__c, CSBD_Now_EstatCivil2Tit__c, CSBD_Now_Finalidad__c, CSBD_Now_Hora__c, CSBD_Now_Horario2Tit__c,
			CSBD_Now_Id_Tarjeta__c, CSBD_Now_Importe__c, CSBD_Now_NIF1Tit__c, CSBD_Now_NIF2Tit__c, CSBD_Now_NIFSolicitante__c, CSBD_Now_NIF__c, CSBD_Now_NUMPERSO__c, CSBD_Now_Nacionalidad2Tit__c,
			CSBD_Now_Nombre1Tit__c, CSBD_Now_Nombre2Tit__c, CSBD_Now_NombreCompleto__c, CSBD_Now_NombreProducto__c, CSBD_Now_NombreSolicitante__c, CSBD_Now_Nombre__c, CSBD_Now_Nomina2Tit__c, CSBD_Now_Num_Oficina__c,
			CSBD_Now_Numsolicitud__c, CSBD_Now_Origen__c, CSBD_Now_Pais_Residencia2Tit__c, CSBD_Now_Plazo__c, CSBD_Now_Pobl2Tit__c, CSBD_Now_PoblVivienda__c, CSBD_Now_Presolicitud__c, CSBD_Now_Resultado__c,
			CSBD_Now_Subproducto_1__c, CSBD_Now_ValorVivienda__c, CSBD_Now_Vehiculo__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Contact_Escala_Maestra__c, CSBD_Contact_Heavy_Digital__c,
			CSBD_Dif_Importe_Preconcedido__c, CSBD_PushTopic_Estado__c, CSBD_RecordType_DeveloperName__c, CSBD_Canal__c, CSBD_Con_Duplicados__c, CSBD_Dejar_Pendiente_Cliente__c, CSBD_Dispone_Importe_Preconcedido__c,
			CSBD_Familia_Producto__c, CSBD_Fecha_Cita__c, CSBD_Horario_Contacto__c, CSBD_Importe_Disponible_Contacto__c, CSBD_Now_Campanya__c, CSBD_Now_Codigo_Producto__c, CSBD_Now_Contrato__c,
			CSBD_Now_DiaPeticion__c, CSBD_Now_FechaContratacion__c, CSBD_Now_USUCLO__c, CSBD_OficinaLO__c, CSBD_Producto__c, CSBD_Programar_Propietario_Id__c, CSBD_Reactivada_Respuesta_Recibida__c,
			CSBD_Resolucion_QuickAction_Cerrar__c, CSBD_Resumen__c, CSBD_StageName_QuickAction_Cerrar__c, CSBD_Turno_Contacto__c, CSBD_Vehiculo_Renting__c, CSBD_Fecha_ultimacita__c, CSBD_Fecha_Firma__c,
			CSBD_Created_date_time__c, CSBD_Detalle_producto__c, CSBD_Comentarios_cliente__c, CSBD_Cliente_Internacional__c
			FROM Opportunity WHERE Id IN :idOportunidades AND IsClosed = FALSE];

		List<CC_Lista_Valores__c> productosOportunidadCreacion = [SELECT CC_Valor2__c, CC_Valor__c, Name, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
																	WHERE CC_Lista__r.Name = 'CSBD: Acciones comerciales oportunidad'
																	AND CC_Valor_SFDC__c = :CC_MetodosUtiles.listaCampo(oportunidadesCreadas, 'RecordType.Name')
																	AND CC_Activa__c = true AND CSBD_Alta_creacion__c = true];
		if (!productosOportunidadCreacion.isEmpty()) {
			Map<String, List<CC_Lista_Valores__c>> tipoOportunidadValores = new Map<String, List<CC_Lista_Valores__c>>();
			for (CC_Lista_Valores__c valorLista: productosOportunidadCreacion) {
				if (!tipoOportunidadValores.containsKey(valorLista.CC_Valor_SFDC__c)) {
					tipoOportunidadValores.put(valorLista.CC_Valor_SFDC__c, new List<CC_Lista_Valores__c>());
				}
				tipoOportunidadValores.get(valorLista.CC_Valor_SFDC__c).add(valorLista);
			}
			List<Opportunity> oportunidadesHijasInsert = new List<Opportunity>();
			for (Opportunity oportunidad : oportunidadesCreadas) {
				if (tipoOportunidadValores.containsKey(oportunidad.RecordType.Name)) {
					for (CC_Lista_Valores__c valorLista : tipoOportunidadValores.get(oportunidad.RecordType.Name)) {
						oportunidadesHijasInsert.add(CSBD_ProductoOportunidadHija.nuevaOportunidadHija(oportunidad, oportunidad.StageName, valorLista, CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Accion_Comercial'), ''));
					}
				}
			}
			insert oportunidadesHijasInsert;
		}
	}

	private static void comprobarSiCmbEsCmn(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud) {
		if (solicitud.tipoSolicitud == 'cmb') {
			Time horaIniCita = Time.newInstance(Integer.valueOf(solicitud.horaIni), Integer.valueOf(solicitud.minIni), 0, 0);
			Time horaFinCita = Time.newInstance(Integer.valueOf(solicitud.horaFin), Integer.valueOf(solicitud.minFin), 0, 0);
			Time horaActual = CBK_UtilsDate.nowSYS().time();
			if (horaIniCita <= horaActual && horaActual <= horaFinCita) {
				solicitud.tipoSolicitud = 'cmn';
			}
		}
	}

	private static List<String> tiposSolicitudAdmitidos() {
		return new List<String>{
			'prestamo', 'prestamoPJ', 'hipoteca', 'hipotecaPlataforma', 'renting', 'tpv', 'compraEstrella', 'cmn',
			'cmb', 'desistimiento', 'desistimiento PAI', 'proAutomatica', 'soporteDigital', 'mac', 'macCentralita', 'cmbHipotecas'
		};
	}

	private static Map<String, Object> desagruparAtributoOrigen(String origen) {
		Map<String, Object> camposOrigen = new Map<String, Object>();

		if (String.isNotBlank(origen)) {
			//Ejemplo de valor recibido: 'f_mi_e_psh_p_na_tc_121_m_na_nc_marzo' (separador puede ser '_' o ':')
			Pattern pattern = Pattern.compile('f_.*_e_.*_p_.*_tc_.*_m_.*_nc_.*|f:.*:e:.*:p:.*:tc:.*:m:.*:nc:.*');
			if (pattern.matcher(origen).matches()) {
				Map<String, Map<String, String>> conversiones = new Map<String, Map<String, String>>{
					'CSBD_Now_Origen_Fuente__c' => new Map<String, String>{
						'org' => 'Orgánico', 'mi' => 'Medios internos',
						'me' => 'Medios externos', '*por defecto*' => 'Introduce el origen'
					},
					'CSBD_Now_Origen_Entorno__c' => new Map<String, String>{
						'app' => 'Now app', 'web' => 'Now web', 'por' => 'Portal', 'eml' => 'Email',
						'atm' => 'ATM', 'psh' => 'Push', 'na' => 'N/A', '*por defecto*' => 'Introduce el origen'
					},
					'CSBD_Now_Origen_Pagina__c' => new Map<String, String>{
						'info' => 'Informativa', 'distrib' => 'Distribuidora', 'catalog' => 'Catálogo',
						'ventaj' => 'Ventajas', 'terrat' => 'Terrat', 'home' => 'Home', 'sh' => 'Subhome',
						'emb' => 'Embebida', 'nat' => 'Nativa', 'na' => 'N/A'
					},
					'CSBD_Now_Origen_Tipo_Campanya__c' => new Map<String, String>{
						'121' => '1-to-1', 'Customer Journey' => 'cj', 'Google' => 'gad',
						'Social' => 'pso', 'Programática' => 'prg', 'na' => 'N/A'
					},
					'CSBD_Now_Origen_Medio__c' => new Map<String, String>{
						'stv' => 'Startview', 'ban' => 'Banner', 'adb' => 'Adball', 'str' => 'Story',
						'popup' => 'Popup', 'eml' => 'Email', 'psh' => 'Push', 'atm' => 'ATM', 'sem' => 'SEM',
						'gdn' => 'Display', 'dis' => 'Discovery', 'ytb' => 'YouTube', 'pso' => 'Social',
						'ttd' => 'The Trade Desk', 'amz' => 'Amazon', 'atw' => 'Twitch', 'na' => 'N/A',
						'*por defecto*' => 'Introduce el origen'
					},
					'CSBD_Now_Origen_Nombre_Campanya__c' => new Map<String, String>{
						'na' => 'N/A'
					}
				};

				Map<String, String> codigosRecibidos = new Map<String, String>{
					'CSBD_Now_Origen_Fuente__c' => extraerCodigoOrigen(origen, 'f_', '_e_'),
					'CSBD_Now_Origen_Entorno__c' => extraerCodigoOrigen(origen, '_e_', '_p_'),
					'CSBD_Now_Origen_Pagina__c' => extraerCodigoOrigen(origen, '_p_', '_tc_'),
					'CSBD_Now_Origen_Tipo_Campanya__c' => extraerCodigoOrigen(origen, '_tc_', '_m_'),
					'CSBD_Now_Origen_Medio__c' => extraerCodigoOrigen(origen, '_m_', '_nc_'),
					'CSBD_Now_Origen_Nombre_Campanya__c' => extraerCodigoOrigen(origen, '_nc_', null)
				};

				for (String nombreCampo : codigosRecibidos.keySet()) {
					Map<String, String> conversion = conversiones.get(nombreCampo);
					if (conversion.containsKey(codigosRecibidos.get(nombreCampo))) {
						camposOrigen.put(nombreCampo, conversion.get(codigosRecibidos.get(nombreCampo)));
					} else if (conversion.containsKey('*por defecto*')) {
						camposOrigen.put(nombreCampo, conversion.get('*por defecto*'));
					} else {
						camposOrigen.put(nombreCampo, codigosRecibidos.get(nombreCampo));
					}
				}
			}
		}
		return camposOrigen;
	}

	private static String extraerCodigoOrigen(String origen, String desde, String hasta) {
		String c = origen.mid(1, 1); //Caracter delimitador ('_' o ':')
		if (String.isNotBlank(hasta)) {
			return origen.substringBetween(desde.replaceAll('_', c), hasta.replaceAll('_', c));
		} else {
			return origen.substringAfterLast(desde.replaceAll('_', c));
		}
	}
}