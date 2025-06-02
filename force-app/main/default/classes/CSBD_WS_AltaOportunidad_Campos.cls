public with sharing class CSBD_WS_AltaOportunidad_Campos {

	public static String informarCamposOportunidad(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud, Map<String, Object> campos, CSBD_WS_AltaOportunidad_Output.Respuesta respuesta) {

		String recordTypeDeveloperName = '';

		switch on solicitud.tipoSolicitud {
			//Préstamo
			when 'prestamo' {
				recordTypeDeveloperName = 'CSBD_Prestamo';

				campos.put('CSBD_Now_Num_Oficina__c', convertToIntegerOrDouble(solicitud.numOficina));
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_Now_NUMPERSO__c', hexToDec(solicitud.numperso));
				campos.put('CSBD_Now_NIF__c', solicitud.nif1Tit);
				campos.put('CSBD_Now_DirVivienda__c', solicitud.dirVivienda);
				campos.put('CSBD_Now_ValorVivienda__c', dividirPorCien(solicitud?.valorVivienda));
				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				campos.put('CSBD_Now_Descripcion__c', solicitud.descripcion.left(255));
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre1Tit);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos1_1Tit);
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellidos2_1Tit);
				campos.put('CSBD_Finalidad__c', solicitud.finalidad);
				campos.put('CSBD_Circuito_Contratacion_Online__c', convertToBoolean(solicitud.contratableOnLine));
				campos.put('CSBD_Subestado_Tracking__c', traducirSubestadoTracking(solicitud.subestado_Tracking));
				campos.put('CSBD_Now_EmailGestor__c', solicitud.emailGestor);
				campos.put('CSBD_Estado_Tracking__c', traducirEstadoTracking(solicitud.num_paso));
				campos.put('CSBD_Codigo_Estado_Tracking__c', convertToIntegerOrDouble(solicitud.num_paso));
				campos.put('CSBD_Prioridad_Tracking__c', convertToIntegerOrDouble(solicitud.diagnostico));
				campos.put('CSBD_Now_Presolicitud__c', solicitud.presolicitud);
				campos.put('CSBD_Now_Importe__c', convertToIntegerOrDouble(solicitud.importe));
				campos.put('Amount', convertToIntegerOrDouble(solicitud.importe));
				campos.put('CSBD_Now_Plazo__c', convertToIntegerOrDouble(solicitud.plazo));
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono1_1Tit);
				campos.put('CSBD_Scoring_Riesgo__c', solicitud.scoringRiesgo);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				informarHorario(solicitud?.horario1Tit, campos);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
			}

			when 'prestamoPJ' {
				recordTypeDeveloperName = 'CSBD_Prestamo';

				campos.put('CSBD_RecordType_DeveloperName__c', 'CSBD_Prestamo');
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_Now_NUMPERSO__c', CSBD_Utils.hexToDec(solicitud.numperso));
				campos.put('CSBD_Now_NIF__c', solicitud.nif1Tit);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre1Tit);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos1_1Tit);
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellidos2_1Tit);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono1_1Tit);
				campos.put('CSBD_Finalidad__c', solicitud.finalidad);
				campos.put('CSBD_Now_Importe__c', convertToIntegerOrDouble(solicitud.importe));
				campos.put('CSBD_Now_Plazo__c', convertToIntegerOrDouble(solicitud.plazo));
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Garantia__c', solicitud.garantia);
				campos.put('CSBD_Delimitador__c', solicitud.delimitador);
				informarHorario(solicitud?.horario1Tit, campos);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);

				/*
				"nombre2Tit": "",
				"a	pellidos1_2Tit": "",
				"apellidos2_2Tit": "",
				"email2Tit": "",
				"telefono1_2Tit": "",
				"numperso2Tit": "",
				"nif2Tit": "",
				*/
			}

			//Hipoteca
			when 'hipoteca' {
				//Alta titulares
				List<Contact> titulares = new List<Contact>();
				Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();

				Account cuentaTitulares = new Account();
				cuentaTitulares.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
				cuentaTitulares.Name = 'Cuenta titulares petición '+ solicitud.numSolicitud;
				insert cuentaTitulares;

				Contact titular1 = new Contact();
				titular1.AccountId = cuentaTitulares.id;
				titular1.RecordTypeId = recordTypeIdContact;
				titular1.CC_Numero_Documento__c = solicitud.nif1Tit;
				titular1.FirstName = solicitud.nombre1Tit;
				titular1.LastName = solicitud.apellidos1_1Tit + ' ' + solicitud.apellidos2_1Tit;
				if(comprobarNotNull(solicitud.fechaNacimiento1Tit) && Integer.valueOf(solicitud?.fechaNacimiento1Tit) != 0){
					String birthdate1Tit = solicitud?.fechaNacimiento1Tit.substring(0, 2) + '/' + solicitud?.fechaNacimiento1Tit.substring(2, 4) + '/'+solicitud?.fechaNacimiento1Tit.substring(4, 8);
					titular1.Birthdate = convertToDate(birthdate1Tit);
				}
				titular1.CBSD_Nacionalidad__c = solicitud.nacionalidad1Tit; //Código
				titular1.CSBD_PaisResidencia__c = solicitud.pais_residencia1Tit; //Código
				titular1.CSBD_IngresosAnuales__c  = dividirPorCien(solicitud?.ingresosNetos1Tit);
				titular1.CSBD_CuotasMensuales__c  = dividirPorCien(solicitud?.gastMens1Tit);
				titular1.CSBD_TipoContrato2__c = solicitud.contratoLaboral1Tit;
				titular1.Email = solicitud.email1Tit;
				titular1.Phone = solicitud.telefono1_1Tit;
				if(comprobarNotNull(solicitud.numPagas1Tit)) {
					titular1.CSBD_NumeroPagas__c = Integer.valueOf(solicitud?.numPagas1Tit);
				}
				titulares.add(titular1);

				if(solicitud.nif2Tit != '' && solicitud.nif2Tit != null && solicitud.nif2Tit != 'null'){
					Contact titular2 = new Contact();
					titular2.AccountId = cuentaTitulares.id;
					titular2.RecordTypeId = recordTypeIdContact;
					titular2.CC_Numero_Documento__c = solicitud.nif2Tit;
					titular2.FirstName = solicitud.nombre2Tit;
					titular2.LastName = solicitud.apellidos1_2Tit + ' ' + solicitud.apellidos2_2Tit;
					if(comprobarNotNull(solicitud.fechaNacimiento2Tit) && Integer.valueOf(solicitud?.fechaNacimiento2Tit) != 0) {
						String birthdate2Tit = solicitud?.fechaNacimiento2Tit.substring(0, 2) + '/' + solicitud?.fechaNacimiento2Tit.substring(2, 4) + '/'+solicitud?.fechaNacimiento2Tit.substring(4, 8);
						titular2.Birthdate = convertToDate(birthdate2Tit);
					}
					titular2.CBSD_Nacionalidad__c = solicitud.nacionalidad2Tit; //Código
					titular2.CSBD_PaisResidencia__c = solicitud.pais_residencia2Tit; //Código
					titular2.CSBD_IngresosAnuales__c  = dividirPorCien(solicitud?.ingresosNetos2Tit);
					titular2.CSBD_CuotasMensuales__c  = dividirPorCien(solicitud?.gastMens2Tit);
					titular2.CSBD_TipoContrato2__c = solicitud.contratoLaboral2Tit;
					titular2.Email = solicitud.email2Tit;
					titular2.Phone = solicitud.telefono1_2Tit;
					if(comprobarNotNull(solicitud.numPagas2Tit)) {
						titular2.CSBD_NumeroPagas__c = Integer.valueOf(solicitud?.numPagas2Tit);
					}

					titulares.add(titular2);
				}

				insert titulares;

				//Alta hipoteca
				recordTypeDeveloperName = 'CSBD_Hipoteca';
				campos.put('CSBD_Now_Num_Oficina__c', convertToIntegerOrDouble(solicitud.numOficina));
				campos.put('CSBD_Finalidad__c', solicitud.finalidad);
				campos.put('CSBD_Now_EmailGestor__c', solicitud.emailGestor);
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_Now_NUMPERSO__c', hexToDec(solicitud.numperso));
				campos.put('CSBD_Now_DirVivienda__c', solicitud.dirVivienda);
				campos.put('CSBD_Now_ValorVivienda__c', dividirPorCien(solicitud?.valorVivienda));
				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre1Tit);
				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombre1Tit);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos1_1Tit);
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellidos2_1Tit);
				campos.put('CSBD_Circuito_Contratacion_Online__c', convertToBoolean(solicitud.contratableOnLine));
				campos.put('CSBD_Subestado_Tracking__c', traducirSubestadoTracking(solicitud.subestado_Tracking));
				campos.put('CSBD_Estado_Tracking__c', traducirEstadoTracking(solicitud.num_paso));
				campos.put('CSBD_Codigo_Estado_Tracking__c', convertToIntegerOrDouble(solicitud.num_paso));
				campos.put('CSBD_Prioridad_Tracking__c', convertToIntegerOrDouble(solicitud.diagnostico));
				campos.put('CSBD_Now_Presolicitud__c', solicitud.presolicitud);
				Decimal importe = Decimal.valueOf(solicitud.importe).divide(100, 2, System.RoundingMode.UNNECESSARY);
				campos.put('CSBD_Now_Importe__c', importe);
				campos.put('Amount', importe);
				campos.put('CSBD_Now_Plazo__c', convertToIntegerOrDouble(solicitud.plazo));
				campos.put('CSBD_Now_PoblVivienda__c', solicitud.poblVivienda);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono1_1Tit);
				campos.put('CSBD_Scoring_Riesgo__c', solicitud.scoringRiesgo);
				campos.put('CSBD_Now_NIF__c', solicitud.nif1Tit);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_TipoBonificado__c', convertToDecimal(solicitud.scoring));
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_SituacionVivienda__c', solicitud.situacionVivienda);
				informarHorario(solicitud?.horario1Tit, campos);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);

				//Añadimos campos homogeneizar con PHD
				campos.put('CSBD_ContactoTitular1__c', titular1.id);
				campos.put('CSBD_ContactoTitular2__c', titulares.size() > 1 ? titulares[1].id : null);
				campos.put('CSBD_PrecioInmueble__c', dividirPorCien(solicitud?.valorVivienda));
				campos.put('CSBD_Municipio__c', solicitud.poblVivienda);
				campos.put('CSBD_CalleVivienda__c', solicitud.dirVivienda);
				campos.put('CSBD_CodigoPostal__c', solicitud.cpVivienda);
			}

			//Plataforma Hipotecaria Digital
			when 'hipotecaPlataforma' {
				//Alta titulares
				List<Contact> titulares = new List<Contact>();

				Account cuentaTitulares = new Account();
				cuentaTitulares.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
				cuentaTitulares.Name = 'Cuenta titulares petición ' + solicitud.numSolicitud;
				insert cuentaTitulares;

				Contact titular1 = new Contact();
				titular1.AccountId = cuentaTitulares.id;
				titular1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
				titular1.CC_Numero_Documento__c = solicitud.nif1Tit;
				titular1.FirstName = solicitud.nombre1Tit;
				titular1.LastName = solicitud.apellidos1_1Tit;
				titular1.Birthdate = convertToDate(solicitud.fechaNacimiento1Tit);
				titular1.CBSD_Nacionalidad__c = solicitud.nacionalidad1Tit;
				titular1.CSBD_EsSolicitante__c = solicitud.esSolicitante1Tit == 'true' ? true : false;
				titular1.CSBD_PaisResidencia__c = solicitud.pais_residencia1Tit;
				titular1.CSBD_ClienteCaixabank__c = solicitud.esCliente1Tit == 'true' ? true : false;
				titular1.CSBD_IngresosAnuales__c = convertToDecimal2(solicitud.ingresosNetos1Tit);
				titular1.CSBD_TipoContrato2__c = solicitud.contratoLaboral1Tit;
				titular1.CSBD_ImporteDeuda__c = convertToDecimal2(solicitud.importeDeuda1Tit);
				titular1.CSBD_CuotasMensuales__c = convertToDecimal2(solicitud.importeCuotaMensual1Tit);
				titular1.Email = solicitud.email1Tit;
				titular1.Phone = solicitud.prefijoTelefono1_1Tit + solicitud.telefono1_1Tit;
				titulares.add(titular1);

				if (solicitud.nif2Tit != '' && solicitud.nif2Tit != null && solicitud.nif2Tit != 'null') {
					Contact titular2 = new Contact();
					titular2.AccountId = cuentaTitulares.id;
					titular2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
					titular2.CC_Numero_Documento__c = solicitud.nif2Tit;
					titular2.FirstName = solicitud.nombre2Tit;
					titular2.LastName = solicitud.apellidos1_2Tit;
					titular2.Birthdate = convertToDate(solicitud.fechaNacimiento2Tit);
					titular2.CBSD_Nacionalidad__c = solicitud.nacionalidad2Tit;
					titular2.CSBD_EsSolicitante__c = solicitud.esSolicitante2Tit == 'true' ? true : false;
					titular2.CSBD_PaisResidencia__c = solicitud.pais_residencia2Tit;
					titular2.CSBD_ClienteCaixabank__c = solicitud.esCliente2Tit == 'true' ? true : false;
					titular2.CSBD_IngresosAnuales__c = convertToDecimal2(solicitud.ingresosNetos2Tit);
					titular2.CSBD_TipoContrato2__c = solicitud.contratoLaboral2Tit;
					titular2.CSBD_ImporteDeuda__c = convertToDecimal2(solicitud.importeDeuda2Tit);
					titular2.CSBD_CuotasMensuales__c = convertToDecimal2(solicitud.importeCuotaMensual2Tit);
					titular2.Email = solicitud.email2Tit;
					titular2.Phone = solicitud.prefijoTelefono1_2Tit + solicitud.telefono1_2Tit;
					titulares.add(titular2);
				}
				insert titulares;

				//Alta hipoteca
				recordTypeDeveloperName = 'CSBD_Hipoteca';

				campos.put('CSBD_ContactoTitular1__c', titular1.Id);
				campos.put('CSBD_ContactoTitular2__c', titulares.size() > 1 ? titulares[1].Id : null);
				campos.put('CSBD_NumPeticion__c', solicitud.numSolicitud);
				campos.put('CSBD_Now_Origen__c', solicitud.plataforma);
				campos.put('CSBD_Now_NUMPERSO__c', hexToDec(solicitud.numperso));
				campos.put('CSBD_TipoOperacion2__c', solicitud.tipoOperacion);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Now_Plazo__c', convertToIntegerOrDouble(solicitud.plazo));
				campos.put('CSBD_PrecioInmueble__c', convertToIntegerOrDouble2(solicitud.precioCompra));
				campos.put('Amount', convertToIntegerOrDouble2(solicitud.importe));
				campos.put('CSBD_AportacionInicial__c', convertToIntegerOrDouble2(solicitud.aportacionInicial));
				campos.put('CSBD_UsoVivienda2__c', solicitud.usoVivienda);
				campos.put('CSBD_TipoConstruccion2__c', solicitud.tipoConstruccionVivienda);
				campos.put('CSBD_TipoVia__c', solicitud.tipoViaVivienda);
				campos.put('CSBD_CalleVivienda__c', solicitud.dirVivienda);
				campos.put('CSBD_NumeroVivienda__c', solicitud.numeroVivienda);
				campos.put('CSBD_EscaleraVivienda__c', solicitud.bloqueVivienda);
				campos.put('CSBD_PisoVivienda__c', solicitud.pisoVivienda);
				campos.put('CSBD_PuertaVivienda__c', solicitud.puertaVivienda);
				campos.put('CSBD_CodigoPostal__c', solicitud.cpVivienda);
				campos.put('CSBD_Municipio__c', solicitud.poblVivienda);
				campos.put('CSBD_Provincia_2__c', solicitud.provinciaVivienda);
				campos.put('CSBD_Comunidad_Autonoma_2__c', solicitud.ccaaVivienda);
				campos.put('CSBD_Pais__c', solicitud.paisVivienda);
				campos.put('CSBD_NumSia__c', solicitud.idSiaSimulacion);
				campos.put('CSBD_TipoInteres2__c', solicitud.modTipoInteresSimulacion);
				campos.put('CSBD_IndiceReferencia__c', solicitud.indiceRefSimulacion); //no puede ir con null por la longitud
				campos.put('CSBD_TIN_Inicial__c', convertToDecimal2(solicitud.tinInicialSimulacion));
				campos.put('CSBD_PeriodoFijo__c', convertToIntegerOrDouble2(solicitud.periodoSimulacion));
				campos.put('CSBD_InteresVariable__c', convertToDecimal2(solicitud.tasaIntVarSimulacion));
				campos.put('CSBD_CuotaMensualHipoteca__c', convertToIntegerOrDouble2(solicitud.importeMensualSimulacion));
				campos.put('CSBD_TIN__c', convertToDecimal2(solicitud.tinSimulacion));
				campos.put('CSBD_TIN_bonificado__c', convertToDecimal2(solicitud.tinDescuentoSimulacion));
				campos.put('CSBD_TAE__c', convertToDecimal2(solicitud.taeSimulacion));
				campos.put('CSBD_TAE_bonificado__c', convertToDecimal2(solicitud.taeDescuentoSimulacion));
				campos.put('CSBD_Resolucion__c', solicitud.resolucionSimulacion);
				campos.put('CSBD_Estado__c', solicitud.estado);
				campos.put('CSBD_TipoDiferencial__c', convertToDecimal2(solicitud.diferencialSimulacion));
				campos.put('CSBD_InteresVariable__c', convertToDecimal2(solicitud.tasaIntVarSimulacion));
				informarEmpresaFamiliaProducto('productoPHD', campos);
				// campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
				// campos.put('CSBD_Familia_Producto__c', 'Hipoteca PHD');
				// campos.put('CSBD_Producto__c', 'Hipoteca Click My Home');
				campos.put('CSBD_Turno_Contacto__c', 'Cualquier hora');
				campos.put('CSBD_Canal__c', 'Plataformas Hipotecarias Digitales');
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.prefijoTelefono1_1Tit + solicitud.telefono1_1Tit);
				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				campos.put('CSBD_TipoBonificado__c', convertToDecimal(solicitud.scoring));
				campos.put('CSBD_OC_Canal_Entrada__c', 'Plataformas Hipotecarias');
				campos.put('CSBD_Gastos_iniciales_sim__c', convertToDecimal2(solicitud.gastosInicialesSimulacion));
				campos.put('CSBD_Aportacion_inicial_sim__c', convertToDecimal2(solicitud.contribucionInicialSimulacion));
				campos.put('CSBD_Tasa_Fija_sim__c', convertToDecimal2(solicitud.diferencialDescuentoSimulacion));
				campos.put('CSBD_Cuota_mensual_porcentaje__c', convertToDecimal2(solicitud.plazosDescuentoSimulacion));
				campos.put('CSBD_Porcentaje_descuento__c', convertToDecimal2(solicitud.tasaDescuentoSimulacion));
				campos.put('CSBD_Porcentaje_max_hipoteca_sim__c', convertToDecimal2(solicitud.maxHipotecaSimulacion));
				campos.put('CSBD_Importe_max_hipoteca_sim__c', convertToDecimal2(solicitud.maxImporteHipotecaSimulacion));
			}

			//Renting
			when 'renting' {
				recordTypeDeveloperName = 'CSBD_Renting';

				campos.put('CSBD_Now_Nombre__c', solicitud.nombreSolicitante);
				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombreSolicitante);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellido1);
				campos.put('CSBD_Email_Solicitud__c', solicitud.emailContacto);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefonoContacto);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_Plazo__c', convertToIntegerOrDouble(solicitud.plazo));
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellido2);
				campos.put('CSBD_Vehiculo_Renting__c', solicitud.vehiculo.left(100));
				campos.put('CSBD_Now_NIF__c', solicitud.nifSolicitante);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Detalle_producto__c', solicitud.subproducto_1);
				informarHorario(solicitud?.horarioContacto, campos);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
			}

			//TPV
			when 'tpv' {
				recordTypeDeveloperName = 'CSBD_TPV';

				campos.put('CSBD_Now_Apellido1__c', solicitud.apellido);
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellido2);
				campos.put('CSBD_Email_Solicitud__c', solicitud.emailCliente);
				campos.put('CSBD_Now_Num_Oficina__c', convertToIntegerOrDouble(solicitud.oficina));
				campos.put('CSBD_Now_NUMPERSO__c', hexToDec(solicitud.numperso));
				campos.put('CSBD_Now_EmailGestor__c', solicitud.emailGestor);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre);
				campos.put('CSBD_Now_Hora__c', convertToTime(solicitud.hora));
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefonoCliente);
				campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
			}

			//Wivai (antiguamente llamado Compra Estrella)
			when 'compraEstrella' {
				recordTypeDeveloperName = 'CSBD_Compra_Estrella';

				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_Finalidad__c', solicitud.finalidad);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono1_1Tit);
				campos.put('CSBD_Scoring_Riesgo__c', solicitud.scoringRiesgo);
				campos.put('CSBD_Now_Num_Oficina__c', convertToIntegerOrDouble(solicitud.numOficina));
				campos.put('CSBD_Now_NIF__c', solicitud.nif1Tit);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre1Tit);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos1_1Tit);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_Presolicitud__c', solicitud.presolicitud);
				Decimal importe = Decimal.valueOf(solicitud.importe).divide(100, 2, System.RoundingMode.UNNECESSARY);
				campos.put('CSBD_Now_Importe__c', importe);
				campos.put('Amount', importe);
				campos.put('CSBD_Now_Plazo__c', convertToIntegerOrDouble(solicitud.plazo));
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellidos2_1Tit);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				informarHorario(solicitud?.horario1Tit, campos);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
			}

			//CMN (Call Me Now)
			when 'cmn' {
				recordTypeDeveloperName = 'CSBD_CMN';

				campos.put('CSBD_Now_Nombre__c', solicitud.nombre2);
				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombre);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono);
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos);
				campos.put('CSBD_Now_NIF__c', solicitud.nif);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_NUMPERSO__c', solicitud?.buzonCajeros == true ? solicitud.numperso : hexToDec(solicitud.numperso));
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellidos_2);
				campos.put('CSBD_Now_Campanya__c', solicitud.idCampanya);
				campos.put('CSBD_Now_Num_Oficina__c', convertToIntegerOrDouble(solicitud.numOficina));
				campos.put('CSBD_Now_DiaPeticion__c', solicitud.diaPeticion);
				campos.put('CSBD_Now_Hora__c', convertToTime(solicitud.hora));
				campos.put('CSBD_Now_Boton__c', solicitud.boton);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Detalle_producto__c', solicitud.subproducto_1);
				campos.put('CSBD_Comentarios_cliente__c', solicitud.comentarios);
                campos.put('CSBD_Categoria__c', solicitud.prod_category_wivai);
                campos.put('CSBD_Subcategoria__c', solicitud.prod_subcategory_wivai);
                campos.put('CSBD_Subcategoria2__c', solicitud.prod_subcategory2_wivai);
				campos.put('CSBD_Proceso__c', solicitud.process_category);
				campos.put('CSBD_CategoriaProducto__c', solicitud.page_product_category);
				campos.put('CSBD_Clave_Producto__c', solicitud.page_product_name);
				informarEmpresaFamiliaProducto(solicitud?.idProducto, campos);
			}

			//CMB (Call Me Back)
			when 'cmb' {
				recordTypeDeveloperName = 'CSBD_CMB';

				campos.put('CSBD_Alta_omnichannel__c', true);
				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombre);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre2);
				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono);
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos);
				campos.put('CSBD_Now_NIF__c', solicitud.nif);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_NUMPERSO__c', hexToDec(solicitud.numperso));
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellidos_2);
				campos.put('CSBD_Now_Boton__c', solicitud.boton);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Detalle_producto__c', solicitud.subproducto_1);
				campos.put('CSBD_Comentarios_cliente__c', solicitud.comentarios);
                campos.put('CSBD_Categoria__c', solicitud.prod_category_wivai);
                campos.put('CSBD_Subcategoria__c', solicitud.prod_subcategory_wivai);
                campos.put('CSBD_Subcategoria2__c', solicitud.prod_subcategory2_wivai);
				campos.put('CSBD_Proceso__c', solicitud.process_category);
				campos.put('CSBD_CategoriaProducto__c', solicitud.page_product_category);
				campos.put('CSBD_Clave_Producto__c', solicitud.page_product_name);
				informarEmpresaFamiliaProducto(solicitud?.idProducto, campos);
				informarHorarioCMB(solicitud?.horaIni, solicitud?.minIni, solicitud?.horaFin, solicitud?.minFin, campos);
			}

			//Desistimiento
			when 'desistimiento' {
				recordTypeDeveloperName = 'CSBD_Desistimiento';

				campos.put('CSBD_Now_USUCLO__c', solicitud.usuclo);
				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombre);
				campos.put('CSBD_Now_FechaContratacion__c', convertToDate(solicitud.fechaContratacion));
				campos.put('CSBD_Email_Solicitud__c', solicitud.emailCliente);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono);
				campos.put('CSBD_Now_Descripcion__c', String.isNotBlank(solicitud.descripMotivo) ? solicitud.descripMotivo.left(255) : '');
				campos.put('CSBD_Now_Contrato__c', solicitud.contrato);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_NIF__c', solicitud.nif);
				campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
				informarHorario(solicitud?.horarioContacto, campos);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
			}

			//Desistimiento PAI
			when 'desistimiento PAI' {
				recordTypeDeveloperName = 'CSBD_DesistimientoPAI';

				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombre);
				campos.put('CSBD_Now_Resultado__c', solicitud.resultado);
				campos.put('CSBD_Now_Num_Oficina__c', convertToIntegerOrDouble(solicitud.oficina));
				campos.put('CSBD_Now_Contrato__c', solicitud.contrato);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono);
				campos.put('CSBD_Now_NIF__c', solicitud.nif);
				campos.put('CSBD_Now_USUCLO__c', solicitud.usuclo);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_Descripcion__c', String.isNotBlank(solicitud.descripMotivo) ? solicitud.descripMotivo.left(255) : '');
				campos.put('CSBD_Now_FechaContratacion__c', convertToDate(solicitud.fechaContratacion));
				campos.put('CSBD_Email_Solicitud__c', solicitud.emailCliente);
				campos.put('CSBD_OficinaLO__c', idOficina(solicitud?.oficina)?.Id);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
			}

			//PRO Automática
			when 'proAutomatica' {
				recordTypeDeveloperName = 'CSBD_PROAutomatica';

				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombreSolicitante);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono);
				campos.put('CSBD_Pantalla_Abandono__c', solicitud.proceso);
				campos.put('CSBD_Now_NUMPERSO__c', hexToDec(solicitud.numperso));
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellido1);
				campos.put('CSBD_Now_NIF__c', solicitud.nif);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_Apellido2__c', solicitud.apellido2);
				campos.put('CSBD_Dispositivo__c', solicitud.entorn);
				campos.put('CSBD_Tipo_contacto__c', solicitud.tipoContacto);
				campos.put('CSBD_Nacionalidad__c', solicitud.nacionalidad1Tit);
				campos.put('CSBD_Fecha_abandono__c', DateTime.newInstance(convertToDate(solicitud.hora.substring(0, 10)), convertToTime(solicitud.hora.substring(11))));
				campos.put('CSBD_Motivo_error__c', solicitud.descripMotivo);
				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_JourneyActionId__c', solicitud.journeyActionId?.left(255));
				campos.put('CSBD_CampaignId__c', solicitud.campaignId?.left(255));
				campos.put('CSBD_DeliveryInternalName__c', solicitud.deliveryInternalName?.left(255));
				campos.put('CSBD_MessageProfileId__c', solicitud.messageProfileId?.left(255));
				informarEmpresaFamiliaProducto(solicitud?.idProducto, campos);
			}

			// Soporte Digital
			when 'soporteDigital' {
				//Alta menor
				List<Contact> titulares = new List<Contact>();

				Account cuentaMenor = new Account();
				cuentaMenor.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
				cuentaMenor.Name = 'Cuenta menor petición ' + solicitud.numSolicitud;
				insert cuentaMenor;

				Contact menor = new Contact();
				menor.AccountId = cuentaMenor.id;
				menor.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_MenorEdad').getRecordTypeId();
				menor.CC_Numero_Documento__c = solicitud.nif1Tit;
				menor.FirstName = solicitud.nombre1Tit;
				menor.LastName = solicitud.apellidos1_1Tit;
				menor.Birthdate = convertToDate(solicitud.fechaNacimiento1Tit);
				menor.Email = solicitud.email1Tit;
				menor.Phone = solicitud.telefono1_1Tit;
				menor.CC_NumPersoAsoc__c = hexToDec(solicitud.numperso);
				insert menor;

				recordTypeDeveloperName = 'CSBD_Soporte_Digital';

				campos.put('CSBD_MenorEdad__c', menor.Id);
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre2Tit);
				campos.put('CSBD_Now_NombreCompleto__c', solicitud.nombre2Tit);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos1_2Tit);
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono1_2Tit);
				campos.put('CSBD_Email_Solicitud__c', solicitud.email2Tit);
				campos.put('CSBD_Now_NIF__c', solicitud.nif2Tit);
				campos.put('CSBD_Now_NUMPERSO__c', hexToDec(solicitud.identificador));
				if(CBK_UtilsDate.todaySYS().addYears(-12) < menor.Birthdate){
					campos.put('CSBD_Now_Origen__c', 'Contratación pack imaginKids');
				}else{
					campos.put('CSBD_Now_Origen__c', 'Contratación pack imaginTeens');
				}
				campos.put('CSBD_Canal__c', solicitud.canal);
				informarEmpresaFamiliaProducto('productoSoporteDigital', campos);
				// campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
				// campos.put('CSBD_Familia_Producto__c', 'Cuentas');
				// campos.put('CSBD_Producto__c', 'Cuenta menor');
			}

			when 'mac' {
				recordTypeDeveloperName = 'CSBD_MAC';
				campos.put('CSBD_CasoOrigen__c', solicitud.casoOrigen);
				campos.put('AccountId', solicitud.accountId);
				campos.put('CSBD_Contact__c', solicitud.contactId);
				campos.put('CSBD_Parent_Id__c', [SELECT Id FROM Opportunity WHERE CSBD_CasoOrigen__c = :solicitud.casoOrigen ORDER BY CreatedDate DESC LIMIT 1]?.Id);
				campos.put('CSBD_Motivo_MAC__c', [SELECT CC_MCC_Motivo__r.Name FROM Case WHERE Id = :solicitud.casoOrigen LIMIT 1]?.CC_MCC_Motivo__r?.Name);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
			}

			when 'macCentralita' {
				recordTypeDeveloperName = 'CSBD_MAC';
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre);
				campos.put('CSBD_Now_Apellido1__c', solicitud.apellidos);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
			}

			when 'cmbHipotecas' {
				recordTypeDeveloperName = 'CSBD_Hipoteca';
				campos.put('CSBD_Telefono_Solicitud__c', solicitud.telefono1_1Tit);
				campos.put('CSBD_Idioma_Solicitud__c', formatearIdioma(solicitud?.idioma, solicitud.canal));
				campos.put('CSBD_Now_Nombre__c', solicitud.nombre1Tit);
				campos.put('CSBD_Canal__c', solicitud.canal);
				campos.put('CSBD_Now_Origen__c', solicitud.origen);
				campos.put('CSBD_Email_Solicitud__c', solicitud.email1Tit);
				informarEmpresaFamiliaProducto(solicitud?.nombreProducto, campos);
				informarHorarioCMB(solicitud?.horaIni, solicitud?.minIni, solicitud?.horaFin, solicitud?.minFin, campos);
			}
		}

		informarDescripcion(solicitud, campos);

		if (solicitud.tipoSolicitud != 'prestamoPJ') {
			identificarCliente(solicitud, campos, respuesta);
		} else {
			identificarClientePj(solicitud, campos);
		}

		if (solicitud.tipoSolicitud == 'proAutomatica' && String.isBlank(String.valueOf(campos.get('CSBD_Contact__c')))) {
			campos.put('CSBD_No_Identificado__c', true);
		}

		String idContacto = String.valueOf(campos.get('CSBD_Contact__c'));

		if(!String.isBlank(idContacto)){
			List<Contact> contactosNumTel = [SELECT Phone, MobilePhone FROM Contact WHERE Id = :idContacto];
			if (String.isBlank(String.valueOf(campos.get('CSBD_Telefono_Solicitud__c'))) && !contactosNumTel.isEmpty()) {
				campos.put('CSBD_Telefono_Solicitud__c', (contactosNumTel[0].MobilePhone != null) ? contactosNumTel[0].MobilePhone : contactosNumTel[0].Phone);
			}
		}

		return recordTypeDeveloperName;
	}

	private static Map<String, String> tipoIdentificacionCliente(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud) {
		String tipoBusqueda;
		String valorBusqueda;

		switch on solicitud.tipoSolicitud {
			when 'prestamo', 'prestamoPJ' {
				if (String.isNotBlank(solicitud?.numperso)) {
					tipoBusqueda = 'NP'; //(NUMPERSO)
					valorBusqueda = hexToDec(solicitud.numperso);
				} else if (String.isNotBlank(solicitud?.nif1Tit)) {
					tipoBusqueda = 'DOC';
					valorBusqueda = solicitud.nif1Tit;
				}
			}
			when 'tpv' {
				if (String.isNotBlank(solicitud?.numperso)) {
					tipoBusqueda = 'NP'; //(NUMPERSO)
					valorBusqueda = hexToDec(solicitud.numperso);
				} else if (String.isNotBlank(solicitud?.identificador)) {
					tipoBusqueda = 'DOC';
					valorBusqueda = solicitud.identificador;
				}
			}
			when 'cmn', 'cmb' {
				List<String> condiciones = new List<String>();
				if (String.isNotBlank(solicitud?.numperso)) {
					condiciones.add(' AV_NumPerso__c = \'' + (solicitud?.buzonCajeros == true ? solicitud?.numperso : hexToDec(solicitud?.numperso))+ '\'');
				}

				if (String.isNotBlank(solicitud?.nif)) {
					condiciones.add(' CC_Numero_Documento__c = \'' + solicitud.nif + '\'');
				}

				if (String.isNotBlank(solicitud?.telefono)) {
					condiciones.add(' Phone = \'' + solicitud.telefono + '\' OR MobilePhone = \'' + solicitud.telefono + '\'');
				}
				valorBusqueda = String.join(condiciones, ' OR ');
				return new Map<String, String>{'valorBusqueda' => valorBusqueda};
			}
			when 'hipoteca', 'compraEstrella'{
				tipoBusqueda = 'DOC';
				valorBusqueda = solicitud?.nif1Tit;
			}
			when 'renting' {
				tipoBusqueda = 'DOC';
				valorBusqueda = solicitud?.nifSolicitante;
			}
			when 'desistimiento', 'desistimiento PAI' {
				tipoBusqueda = 'DOC';
				valorBusqueda = solicitud?.nif;
			}
			when 'proAutomatica', 'hipotecaPlataforma' {
				tipoBusqueda = 'NP';
				valorBusqueda = hexToDec(solicitud.numperso);
			}
			when 'soporteDigital' {
				tipoBusqueda = 'NP';
				valorBusqueda = hexToDec(solicitud.identificador);
			}
		}
		return new Map<String, String>{'tipoBusqueda' => tipoBusqueda, 'valorBusqueda' => valorBusqueda};
	}

	public static Map<String, Object> identificarCliente(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud, Map<String, Object> campos, CSBD_WS_AltaOportunidad_Output.Respuesta respuesta) {
		//Obtener cuenta y contacto a partir del NUMPERSO o NIF
		Map<String, String> tipoIdentificacion = tipoIdentificacionCliente(solicitud);
		if (!String.isEmpty(tipoIdentificacion.get('valorBusqueda'))) {
			List<Account> cuentas = new List<Account>();
			List<Contact> contactos = new List<Contact>();
			Boolean identificacionALF = identificacionAlfActiva();

			if (identificacionALF) {
				//Identificación contra ALF (ignora resultados con más de una cuenta)
				Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF(tipoIdentificacion.get('tipoBusqueda'), tipoIdentificacion.get('valorBusqueda'));
				cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
				if (cuentas.size() == 1) {
					if (mapaCuentasContactos.containsKey('CONTACTOS')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
						if (contactos.size() == 1) {
							campos.put('AccountId', cuentas[0].Id);
							campos.put('CSBD_Contact__c', contactos[0].Id);
						}
					} else {
						//Buscar la cuenta retornada por ALF solo tiene un contacto en Salesforce
						List<Contact> contactosCuenta = [SELECT Id, Phone, MobilePhone FROM Contact WHERE AccountId = :cuentas[0].Id];
						if (contactosCuenta.size() == 1) {
							campos.put('AccountId', cuentas[0].Id);
							campos.put('CSBD_Contact__c', contactosCuenta[0].Id);
						}
					}
				}
			}

			if (!identificacionALF || cuentas.isEmpty()) {
				//Identificación contra BD (también cuando identificación ALF sin resultados)
				if (tipoIdentificacion.get('tipoBusqueda') == 'NP') {
					contactos = [SELECT AccountId, Account.AV_IndicadoresClientes__c FROM Contact
							WHERE (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA')
							AND AV_NumPerso__c = :tipoIdentificacion.get('valorBusqueda')];
				} else if (tipoIdentificacion.get('tipoBusqueda') == 'DOC') {
					contactos = [SELECT AccountId, Account.AV_IndicadoresClientes__c FROM Contact
							WHERE (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA')
							AND CC_Numero_Documento__c = :tipoIdentificacion.get('valorBusqueda')];
				} else{
					contactos = Database.query('SELECT AccountId, Account.AV_IndicadoresClientes__c FROM Contact WHERE (RecordType.DeveloperName = \'CC_Cliente\' OR Account.RecordType.DeveloperName = \'CC_ClientePA\') AND ('
													+ tipoIdentificacion.get('valorBusqueda')  + ')',
												AccessLevel.USER_MODE);
				}

				if (contactos.size() == 1) {
					campos.put('AccountId', contactos[0].AccountId);
					campos.put('CSBD_Contact__c', contactos[0].Id);

					if(contactos[0].Account.AV_IndicadoresClientes__c != null) {
						return new Map<String, Object> {'AV_IndicadoresClientes__c' => contactos[0].Account.AV_IndicadoresClientes__c};
					}
				}
			}
		}

		if (solicitud.tipoSolicitud == 'hipoteca' && String.isNotBlank(solicitud.nif2Tit)) {
			List<Account> cuentas = new List<Account>();
			List<Contact> contactos = new List<Contact>();
			Boolean identificacionALF = identificacionAlfActiva();

			if (identificacionALF) {
				//Identificación contra ALF (ignora resultados con más de una cuenta)
				Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF('DOC', solicitud.nif2Tit);
				cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
				if (cuentas.size() == 1) {
					if (mapaCuentasContactos.containsKey('CONTACTOS')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
						if (contactos.size() == 1) {
							campos.put('CSBD_Contact_2__c', contactos[0].Id);
						}
					} else {
						//Buscar la cuenta retornada por ALF solo tiene un contacto en Salesforce
						List<Contact> contactosCuenta = [SELECT Id FROM Contact WHERE AccountId = :cuentas[0].Id];
						if (contactosCuenta.size() == 1) {
							campos.put('CSBD_Contact_2__c', contactosCuenta[0].Id);
						}
					}
				}
			}

			if (!identificacionALF || cuentas.isEmpty()) {
				//Identificación contra BD (también cuando identificación ALF sin resultados)
				contactos = [SELECT AccountId FROM Contact
								WHERE (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA')
								AND CC_Numero_Documento__c = :solicitud.nif2Tit];
				if (contactos.size() == 1) {
					campos.put('CSBD_Contact_2__c', contactos[0].Id);
				}
			}

		} else if (solicitud.tipoSolicitud == 'hipotecaPlataforma' && String.isNotBlank(solicitud.numperso2Tit)) {
			String numperso2TitDecimal = hexToDec(solicitud.numperso2Tit);

			List<Account> cuentas = new List<Account>();
			List<Contact> contactos = new List<Contact>();
			Boolean identificacionALF = identificacionAlfActiva();

			if (identificacionALF) {
				//Identificación contra ALF (ignora resultados con más de una cuenta)
				Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF('NP', numperso2TitDecimal);
				cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
				if (cuentas.size() == 1) {
					if (mapaCuentasContactos.containsKey('CONTACTOS')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
						if (contactos.size() == 1) {
							campos.put('CSBD_Contact_2__c', contactos[0].Id);
						}
					} else {
						//Buscar la cuenta retornada por ALF solo tiene un contacto en Salesforce
						List<Contact> contactosCuenta = [SELECT Id FROM Contact WHERE AccountId = :cuentas[0].Id];
						if (contactosCuenta.size() == 1) {
							campos.put('CSBD_Contact_2__c', contactosCuenta[0].Id);
						}
					}
				}
			}

			if (!identificacionALF || cuentas.isEmpty()) {
				//Identificación contra BD (también cuando identificación ALF sin resultados)
				contactos = [SELECT AccountId FROM Contact
								WHERE (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA')
								AND CC_NumPerso__c = :numperso2TitDecimal];
				if (contactos.size() == 1) {
					campos.put('CSBD_Contact_2__c', contactos[0].Id);
				}
			}
		}

		return campos;
	}

	public static Map<String, Object> identificarClientePj(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud, Map<String, Object> campos) {
		//Obtener cuenta y contacto a partir del NUMPERSO o NIF
		Map<String, String> tipoIdentificacion = tipoIdentificacionCliente(solicitud);
		if (!String.isEmpty(tipoIdentificacion.get('tipoBusqueda'))) {
			List<Account> empresas = new List<Account>();

			String tipoBusqueda = tipoIdentificacion.get('tipoBusqueda');
			String valorBusqueda = tipoIdentificacion.get('valorBusqueda');
			if (tipoBusqueda == 'NP') {
				empresas = [SELECT AV_IndicadoresClientes__c FROM Account WHERE RecordType.DeveloperName = 'CC_Cliente'
							AND AV_NumPerso__c = :valorBusqueda LIMIT 2];
			} else if (tipoBusqueda == 'DOC') {
				empresas = [SELECT AV_IndicadoresClientes__c FROM Account WHERE RecordType.DeveloperName = 'CC_Cliente'
							AND CC_Numero_Documento__c = :valorBusqueda LIMIT 2];
			}

			if (empresas.size() == 1) {
				Account empresa = empresas[0];
				campos.put('AccountId', empresa.Id);

				String apoderadoNumperso = CSBD_Utils.hexToDec(solicitud.numperso2Tit);
				if (String.isNotBlank(apoderadoNumperso)) {
					List<Contact> apoderados = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CIBE_Apoderado'
												AND CIBE_Carrec__c != '00016' AND AccountId = :empresa.Id AND AV_NumPerso__c = :apoderadoNumperso
												AND (CIBE_FechaVencimiento__c >= :System.today() OR CIBE_FechaVencimiento__c = NULL) LIMIT 2];
					if (apoderados.size() == 1) {
						Contact apoderado = apoderados[0];
						campos.put('CSBD_Contact__c', apoderado.Id);
					}
				}
			}
		}
		return campos;
	}

	private static Boolean comprobarNotNull(String valor) {
		if (valor != '' && valor != null && valor != 'null') {
			return true;
		} else {
			return false;
		}
	}

	private static Boolean convertToBoolean(String valor) {
		if (valor != '' && valor != null && valor != 'null') {
			return valor == 'S';
		} else {
			return false;
		}
	}

	private static Object convertToIntegerOrDouble(String var) {
		if (String.isBlank(var) || var == 'null') {
			return null;
		} else {
			var = var.substringBefore(' ').replace('.', '').replace(',', '.');
			try {
				return Integer.valueOf(var);
			} catch (TypeException te) {
				return Double.valueOf(var);
			}
		}
	}

	private static Object convertToIntegerOrDouble2(String var) {
		if (String.isBlank(var) || var == 'null') {
			return null;
		} else {
			try {
				return Integer.valueOf(var);
			} catch (TypeException te) {
				return Double.valueOf(var);
			}
		}
	}

	private static Decimal convertToDecimal(String var) {
		if (var != '' && var != null && var != 'null') {
			var = var.substringBefore(' ').replace('.', '').replace(',', '.');
			return Decimal.valueOf(var);
		} else {
			return null;
		}
	}

	 private static Decimal convertToDecimal2(String var) {
		if (var != '' && var != null && var != 'null') {
			return Decimal.valueOf(var);
		} else {
			return null;
		}
	}

	private static Date convertToDate(String var) {
		if (var != '' && var != null && var != 'null' && var != '00000000'  && var != '//') {
			return Date.parse(var);
		} else {
			return null;
		}
	}

	private static Date convertToDate(String var, String findVar, String replaceVar) {
		if (var != '' && var != null && var != 'null' && var != '00000000' && var != '//') {
			return Date.parse(var.replace(findVar, replaceVar));
		} else {
			return null;
		}
	}

	private static Time convertToTime(String var) {
		if (var != '' && var != null && var != 'null' && var.contains(':')) {
			List<String> parts = var.split(':', 3);
			List<Integer> integerList = new List<Integer>();
			for (String s : parts) {
				integerList.add(Integer.valueOf(s));
			}

			Time t;
			if (integerList.size() == 3) {
				t = Time.newInstance(integerList[0], integerList[1], integerList[2], 0);
			} else if (integerList.size() == 2) {
				t = Time.newInstance(integerList[0], integerList[1], 0, 0);
			}
			return t;
		} else {
			return null;
		}
	}

	private static Boolean direccionCorreoValida(String correo) {
		Boolean retorno = true;
		if (String.isNotBlank(correo)) {
			String regex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(correo);

			if (!matcher.matches()) {
				retorno = false;
			}
		}
		return retorno;
	}

	private static String hexToDec(String texto) {
		try {
			if (String.isBlank(texto)) {
				return '';
			} else {
				Double retorno = 0;

				Map<String, Integer> mapa = new Map<String, Integer>{
					'0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7,
					'8' => 8, '9' => 9, 'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14,
					'F' => 15, 'a' => 10, 'b' => 11, 'c' => 12, 'd' => 13, 'e' => 14, 'f' => 15
				};
				for (Integer i = 0; i < texto.length(); i++)  {
					retorno += (mapa.get(texto.substring(i, i + 1)) * Math.pow(16, texto.length() - (i + 1))) ;
				}

				//El numperso retornado puede tener un número diferente de 8 caracteres. Si tiene menos caracteres, no están guardados con 0 delante
				return String.valueOf(Integer.valueOf(retorno));
			}
		} catch (Exception e) {
			return null;
		}
	}

	private static Boolean identificacionAlfActiva() {
		Boolean retorno = false;
		if (!Test.isRunningTest()) {
			List<CSBD_Identificacion_ALF__mdt> mdt = [SELECT CSBD_Identificacion_ALF_Activa__c FROM CSBD_Identificacion_ALF__mdt LIMIT 1];

			if (!mdt.isEmpty() && mdt[0].CSBD_Identificacion_ALF_Activa__c) {
				retorno = true;
			}
		}
		return retorno;
	}

	private static String formatearIdioma(String idioma, String canal) {
		if(canal == 'portal'){
			switch on idioma {
				when '2', '02', 'CA', 'CAT', 'ca', 'cat', 'Català', 'Castellano' {
					return 'Catalán';
				}
				when '03', '04', '05', '13', '14', '15', '16', '17', '18', '19', '20',
						'21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
						'3', '4', '5', '99', 'ENG', 'eng', 'EN', 'en' {
					return 'Inglés';
				}
				when else {
					//'02', '06', '10', '11', '2', '6', 'CAS', 'ES', 'cas', 'es'
					return 'Castellano';
				}
			}
		} else {
			switch on idioma {
				when '1', '01', 'CA', 'CAT', 'ca', 'cat', 'Català', 'Castellano' {
					return 'Catalán';
				}
				when '03', '04', '05', '13', '14', '15', '16', '17', '18', '19', '20',
						'21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
						'3', '4', '5', '99', 'ENG', 'eng' {
					return 'Inglés';
				}
				when else {
					//'02', '06', '10', '11', '2', '6', 'CAS', 'ES', 'cas', 'es'
					return 'Castellano';
				}
			}
		}

	}

	private static String traducirEstadoTracking(String codigo) {
		List<CC_Lista_Valores__c> lov = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor'
											AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Estado tracking'
											AND Name = :codigo AND CC_Activa__c = TRUE LIMIT 1];
		if (!lov.isEmpty()) {
			return lov[0].CC_Valor__c;
		} else {
			return codigo;
		}
	}

	private static String traducirSubestadoTracking(String codigo) {
		List<CC_Lista_Valores__c> lov = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor'
											AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Sub-estado tracking'
											AND Name = :codigo AND CC_Activa__c = TRUE LIMIT 1];
		if (!lov.isEmpty()) {
			return lov[0].CC_Valor__c;
		} else {
			return codigo;
		}
	}

	private static void informarEmpresaFamiliaProducto(String codigoProducto, Map<String, Object> campos) {
		if (String.isNotBlank(codigoProducto)) {
			campos.put('CSBD_Now_Codigo_Producto__c', codigoProducto);
			List<CC_Lista_Valores__c> lov = [SELECT CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c, CSBD_Valor4__c, CSBD_Product2__c, CSBD_Producto_MIFID__c
												FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor'
												AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto'
												AND Name = :codigoProducto AND CC_Activa__c = TRUE LIMIT 1];
			if (!lov.isEmpty()) {
				campos.put('CSBD_Empresa_Proveedora__c', String.isNotBlank(lov[0].CC_Valor_SFDC__c) ? lov[0].CC_Valor_SFDC__c : 'CaixaBank');
				campos.put('CSBD_Familia_Producto__c', lov[0].CC_Valor__c);
				campos.put('CSBD_Producto__c', lov[0].CC_Valor2__c);
				campos.put('CSBD_Skill__c', lov[0].CSBD_Valor4__c);
				campos.put('AV_PF__c', lov[0].CSBD_Product2__c);
				campos.put('CSBD_Producto_MIFID__c', lov[0].CSBD_Producto_MIFID__c);

				/* List<Product2> productoPF = [SELECT Id FROM Product2 WHERE Name = :lov[0].CSBD_Valor5__c AND Recordtype.DeveloperName = 'AV_PF'];
				if(!productoPF.isEmpty()) {
					campos.put('AV_PF__c', productoPF[0].Id);
				}*/
			}
		}
	}

	private static void informarHorario(String horarioContacto, Map<String, Object> campos) {
		List<CC_Lista_Valores__c> listasValoresHorario = [SELECT CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
															WHERE CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Turno'
															AND CC_Lista__r.CC_Activa__c = TRUE AND CC_Activa__c = TRUE AND Name = :horarioContacto];
		if (listasValoresHorario.size() != 1) {
			campos.put('CSBD_Horario_Contacto__c', horarioContacto);
		} else {
			campos.put('CSBD_Horario_Contacto__c', listasValoresHorario[0].CC_Valor2__c);
			campos.put('CSBD_Horario_Contacto_IWD__c', listasValoresHorario[0].CC_Valor_SFDC__c);
			campos.put('CSBD_Turno_Contacto__c', listasValoresHorario[0].CC_Valor__c);
		}
	}

	private static void informarHorarioCMB(String horaInicial, String minInicial, String horaFinal, String minFinal, Map<String, Object> campos) {

		if(String.isNotBlank(horaInicial)){
			if(horaInicial.length() == 1){
				horaInicial = '0' + horaInicial;
			}
		} else {
			horaInicial = '00';
		}

		if(String.isNotBlank(minInicial)){
			if(minInicial.length() == 1){
				minInicial = '0' + minInicial;
			}
		} else {
			minInicial = '00';
		}

		if(String.isNotBlank(horaFinal)){
			if(horaFinal.length() == 1){
				horaFinal = '0' + horaFinal;
			}
		} else {
			horaFinal ='00';
		}

		if(String.isNotBlank(minFinal)){
			if(minFinal.length() == 1){
				minFinal = '0' + minFinal;
			}
		} else {
			minFinal = '00';
		}

		integer turnoHora = integer.valueof(horaInicial);
		integer turnoHoraFin = integer.valueof(horaFinal);

		if(turnoHora == 14 & turnoHoraFin == 15) {
			campos.put('CSBD_Turno_Contacto__c', 'Mañana');
		}
		else if(turnoHora >= 14){
			campos.put('CSBD_Turno_Contacto__c', 'Tarde');
		}else {
			campos.put('CSBD_Turno_Contacto__c', 'Mañana');
		}

		campos.put('CSBD_Horario_Contacto__c', horaInicial + ':' + minInicial + ' - ' + horaFinal + ':' + minFinal);
		campos.put('CSBD_Horario_Contacto_IWD__c', horaInicial);
	}


	private static void informarDescripcion(CSBD_WS_AltaOportunidad_Input.Solicitud solicitud, Map<String, Object> campos) {
		String resumen = '';

		switch on solicitud.tipoSolicitud {
			when 'prestamo' {
				resumen += 'Plazo: ' + solicitud?.plazo + '\n';
				resumen += String.isNotBlank(solicitud?.nif2Tit) ? 'NIF 2º titular: ' + solicitud.nif2Tit + '\n' : '';
				resumen += 'Número de pagas: ' + solicitud?.numPagas1Tit + ' (1º titular), ' + solicitud?.numPagas2Tit + ' (2º titular)\n';
				resumen += 'Ingresos netos: ' + dividirPorCienString(solicitud?.ingresosNetos1Tit) + ' (1º titular), ';
				resumen += dividirPorCienString(solicitud?.ingresosNetos2Tit) + ' (2º titular)\n';
				resumen += 'Gastos mensuales: ' + dividirPorCienString(solicitud?.gastMens1Tit) + ' (1º titular), ';
				resumen += dividirPorCienString(solicitud?.gastMens2Tit) + ' (2º titular)';
			}
			/*when 'hipoteca' {
				resumen += 'Plazo: ' + solicitud?.plazo + '\n';
				resumen += String.isNotBlank(solicitud?.nif2Tit) ? 'NIF 2º titular: ' + solicitud.nif2Tit + '\n' : '';
				resumen += 'Número de pagas: ' + solicitud?.numPagas1Tit + ' (1º titular), ' + solicitud?.numPagas2Tit + ' (2º titular)\n';
				resumen += 'Ingresos netos: ' + dividirPorCienString(solicitud?.ingresosNetos1Tit) + ' (1º titular), ';
				resumen += dividirPorCienString(solicitud?.ingresosNetos2Tit) + ' (2º titular)\n';
				resumen += 'Gastos mensuales: ' + dividirPorCienString(solicitud?.gastMens1Tit) + ' (1º titular), ';
				resumen += dividirPorCienString(solicitud?.gastMens2Tit) + ' (2º titular)\n';
				resumen += 'Valor de la vivienda: ' + dividirPorCienString(solicitud?.valorVivienda);
			}*/
			when 'renting' {
				resumen += 'Cuota: ' + solicitud?.cuota + '\n';
				resumen += 'Plazo: ' + solicitud?.plazo + '\n';
				resumen += 'Número de pagas: ' + solicitud?.numPagas + '\n';
				resumen += 'Ingresos mensuales: ' + solicitud?.ingresosMensuales + '\n';
				resumen += 'KMs: ' + (String.isNotBlank(solicitud?.kms) ? solicitud?.kms + 'km' : '');
			}
			when 'compraEstrella' {
				resumen += 'Importe: ' + campos.get('Amount') + '€\n';
				resumen += 'Plazo: ' + solicitud?.plazo + '\n';
				resumen += 'Número de pagas: ' + solicitud?.numPagas1Tit + '\n';
				resumen += 'Ingresos netos: ' + dividirPorCienString(solicitud?.ingresosNetos1Tit);
			}
			when 'desistimiento' {
				resumen += 'Motivo cliente: ' + solicitud?.descripMotivo + '\n';
				resumen += 'Contrato: ' + solicitud.contrato;
			}
			when 'desistimiento PAI' {
				resumen += 'Resultado: ' + solicitud?.resultado + '\n';
				resumen += 'Oficina: ' + solicitud?.oficina + '\n';
				resumen += 'Motivo cliente: ' + solicitud?.descripMotivo + '\n';
				resumen += 'Contrato: ' + solicitud.contrato;
			}
			when 'cmb', 'cmn' {
				resumen = (solicitud.descripcion ?? '').replace('; ', '\n').left(1000);
			}
		}
		campos.put('CSBD_Resumen__c', resumen);
	}

	private static Decimal dividirPorCien(String numero) {
		if (String.isBlank(numero)) {
			return null;
		} else {
			return Decimal.valueOf(numero).divide(100, 2, System.RoundingMode.UNNECESSARY);
		}
	}

	private static String dividirPorCienString(String numero) {
		String retorno = String.valueOf(dividirPorCien(numero));
		return String.isNotBlank(retorno) ? retorno + '€' : '';
	}

	private static Account idOficina(String numeroOficina) {
		Account retorno;
		String numeroOficinaEmpresa = '001-' + numeroOficina.leftPad(5, '0');
		List<Account> oficinas = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank'
									AND CC_Numero_Oficina_Empresa__c = :numeroOficinaEmpresa LIMIT 1];
		if (oficinas.size() == 1) {
			retorno = oficinas[0];
		}
		return retorno;
	}
}