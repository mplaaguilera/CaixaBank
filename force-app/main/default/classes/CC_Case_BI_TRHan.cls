public with sharing class CC_Case_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
	}

	private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {
		//Obtención de RT CC_
		Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
		Set<Id> setIdsRt = New Set<Id>();

		for (Schema.RecordTypeInfo rt: lstRT){
			if ((rt.getDeveloperName().left(3)=='CC_')||(rt.getDeveloperName().left(3)=='AM_')) {
				setIdsRt.add(rt.getRecordTypeId());
			}
		}

		List<Case> listNewObjCC= New List<Case>();
		Map<Id, Case> mapNewObjCC = New Map<Id, Case>();
		for (Case tk: listNewObj){
			if(((setIdsRt).contains(tk.RecordTypeId))||(tk.RecordTypeId == null)){
				listNewObjCC.add(tk);
				mapNewObjCC.put(tk.Id,tk);
			}
		}

		if (listNewObjCC.size() != 0){
			CC_CaseTriggerHelper.modificarActivarCasoChat(listNewObjCC);
			enmascararPANs(listNewObjCC); //Se enmascaran los PANs de tarjeta de crédito en caso de haberlos
			encryptPANs(listNewObjCC); //Se encrypta el PAN en hexadecimal
			informarCampos(listNewObjCC);
			actualizarBuzonSalida(listNewObjCC);
			cambioEstadoPendiente(listNewObjCC);
			horaSLAConsultasOperativas(listNewObjCC);
			List<Id> idsCAM = obtenerIdsCAM(listNewObjCC);
			gestionEntitlementsCAM(listNewObjCC, idsCAM);
			CC_CaseTriggerHelper.routingEmailCasesAProveedor(listNewObjCC);
			CC_CaseTriggerHelper.caseGestionado(listNewObjCC, null, idsCAM);
			CC_CaseTriggerHelper.procedenciaEmailBI(listNewObjCC);
			CC_CaseTriggerHelper.casosFaxBI(listNewObjCC);
			CC_CaseTriggerHelper.casosSegunColaBI(listNewObjCC);
			CC_CaseTriggerHelper.personAccountBI(listNewObjCC);
			CC_CaseTriggerHelper.identificarClienteAlfBI(listNewObjCC);
			CC_CaseTriggerHelper.creacionCasoBI(listNewObjCC);
			CC_CaseTriggerHelper.contactoIncoherenteBI(listNewObjCC);
			CC_CaseTriggerHelper.creacionCasoPropuestasBI(listNewObjCC);
			CC_CaseTriggerHelper.seInformaCanalRespuestaBI(listNewObjCC);
			CC_CaseTriggerHelper.causaInformadoBI(listNewObjCC);
			CC_CaseTriggerHelper.solucionInformadoBI(listNewObjCC);
			CC_CaseTriggerHelper.tematicaInformadoBI(listNewObjCC);
			CC_CaseTriggerHelper.productoInformadoBI(listNewObjCC);
			CC_CaseTriggerHelper.motivoInformadoBI(listNewObjCC);
			CC_CaseTriggerHelper.informarOficinaAfectadaBI(listNewObjCC);
			CC_CaseTriggerHelper.cambioContactoEmpleadoBI(listNewObjCC, idsCAM);
		}
	}

	private void enmascararPANs(List<Case> listNewObj) {
		for (Case caso : listNewObj) {

			// Campo "Asunto"
			if (!String.isEmpty(caso.Subject)) {
				String sujeto = caso.Subject;
				caso.Subject = CC_CaseTriggerHelper.metodoMatcher(sujeto);
			}

			// Campo "Descripción"
			if (!String.isEmpty(caso.Description)) {
				String description = caso.Description;
				caso.Description = CC_CaseTriggerHelper.metodoMatcher(description);
			}

			// Campo "Detalle Consulta"
			if (!String.isEmpty(caso.CC_Detalles_Consulta__c)) {
				String detallesConsulta = caso.CC_Detalles_Consulta__c;
				caso.CC_Detalles_Consulta__c = CC_CaseTriggerHelper.metodoMatcher(detallesConsulta);
			}

			// Campo "Detalle Solución"
			if (!String.isEmpty(caso.CC_Detalles_Solucion__c)) {
				String detallesSolucion = caso.CC_Detalles_Solucion__c;
				caso.CC_Detalles_Solucion__c = CC_CaseTriggerHelper.metodoMatcher(detallesSolucion);
			}
		}
	}

	//Funcion para encryptar el campo PAN en AES256
    private void encryptPANs(List<Case> listNewObj) {
        List<CC_CryptoMetadata__mdt> cryptoValues = [SELECT CC_Key__c, CC_Vector__c FROM CC_CryptoMetadata__mdt LIMIT 1];
        Blob vector = null;
        Blob key = null;
        if(!cryptoValues.isEmpty()){
            vector = Blob.valueOf(cryptoValues[0].CC_Vector__c);
            key = EncodingUtil.base64decode(cryptoValues[0].CC_Key__c);
        }
        for (Case caso : listNewObj) {
            // Campo "PAN"
            if (!String.isEmpty(caso.CC_PAN__c) && caso.CC_PAN_Encriptado__c == false) {
                Blob data = Blob.valueOf(caso.CC_PAN__c);
                Blob encrypted = Crypto.encrypt('AES256', key, vector, data);
                String encryptedString = EncodingUtil.base64encode(encrypted);
                caso.CC_PAN__c = encryptedString;
                //Antigua Forma de Encriptar
                /*String encryptedPan = caso.CC_PAN__c.replaceAll('[^0-9]', '');
                caso.CC_PAN__c = CC_MetodosUtiles.decimalToHex(decimal.valueOf(encryptedPan));*/
                caso.CC_PAN_Encriptado__c = true;
            }

			if (!String.isEmpty(caso.CC_Digitos_Tarjeta__c) && caso.CC_DigitosTarjeta_Encriptado__c == false) {
				//Blob vector = Blob.valueOf('IV123');
/*				Blob key = Crypto.generateAesKey(128);
				Blob data = Blob.valueOf(caso.CC_Digitos_Tarjeta__c);
				//Blob encrypted = Crypto.encrypt('AES128', key, vector, data);
				Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, data);
                String encryptedString = EncodingUtil.base64encode(encrypted);
*/
				String encryptedPan = caso.CC_Digitos_Tarjeta__c.replaceAll('[^0-9]', '');
				caso.CC_Digitos_Tarjeta__c = CC_MetodosUtiles.decimalToHex(decimal.valueOf(encryptedPan));
				caso.CC_DigitosTarjeta_Encriptado__c = true;
			}
		}
	}

	private void informarCampos(List<Case> listNewObj) {

		Boolean Robot = false;
		for (Case caso : listNewObj) {
			//Se informa el canal de resolución con el valor del canal de procedencia
			if (caso.CC_Canal_Procedencia__c != 'Formulario Consultas Operativas') {
				caso.CC_Canal_Resolucion__c = caso.CC_Canal_Procedencia__c;
			}
			if(!Robot && !String.isBlank(caso.Subject)){
				if (caso.Subject.toUpperCase().contains('PRUEBA ROBOT')){
					Robot = true;
				}
			}
		}
		if (Robot) {
			List <CC_MCC__c> lstMcc = [SELECT Id, CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Canal_Operativo__c ,
			CC_Causa__c, CC_Causa__r.CC_Motivo__c, CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__c,
			CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c  from CC_MCC__c
			WHERE CC_Codigo_Externo__c = 'SO-033729'
			AND CC_Causa__r.CC_Codigo_Externo__c = 'CA-015680'
			AND CC_Causa__r.CC_Motivo__r.CC_Codigo_Externo__c = 'MO-012087'
			AND CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__r.CC_Codigo_Externo__c = 'PR-001318'
			AND CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c ='TE-000120'
			AND CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Canal_Operativo__c = 'Sin canal' ];
			if(!lstMcc.isEmpty()){
				for (Case caso : listNewObj) {
					if(!String.isBlank(caso.Subject)){
						if (caso.Subject.toUpperCase().contains('PRUEBA ROBOT')){
							caso.CC_Canal_Operativo__c = lstMcc[0].CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Canal_Operativo__c;
							caso.CC_MCC_Tematica__c = lstMCC[0].CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c;
							caso.CC_MCC_ProdServ__c = lstMCC[0].CC_Causa__r.CC_Motivo__r.CC_Producto_Servicio__c;
							caso.CC_MCC_Motivo__c = lstMCC[0].CC_Causa__r.CC_Motivo__c;
							caso.CC_MCC_Causa__c = lstMCC[0].CC_Causa__c;
							caso.CC_MCC_Solucion__c = lstMCC[0].Id;
							caso.CC_Tipo_Contacto__c = 'Consulta';
							caso.CC_Detalles_Consulta__c = 'Prueba';
							caso.Status = 'Rechazado';
						}
					}
				}
			}
		}
	}

	private void actualizarBuzonSalida(List<Case> listNewObj) {
		for (Case caso : listNewObj) {
			//Se actualiza el buzón de salida del caso
			caso.CC_Buzon_Salida__c = obtenerBuzon(caso.CC_Canal_Procedencia__c, caso.CC_Idioma__c);
		}
	}

	private String obtenerBuzon(String canalProcedencia, String idioma) {

		if (idioma == 'ca') {
			idioma = 'Català';
		} else if (idioma == 'en') {
			idioma = 'Inglés';
		} else {
			idioma = 'Castellano';
		}

		List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
													WHERE CC_Canal_Procedencia__c = :canalProcedencia
													AND CC_Idioma__c = :idioma];

		//Si no se ha encontrado  ningún buzón se usa el por defecto en el idioma del caso
		if (buzones.isEmpty() && canalProcedencia == 'Formulario Consultas Operativas') {
			buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
						WHERE  DeveloperName = 'CC_Buzon_Defecto_Empleados' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true];
        }
        if (buzones.isEmpty()){
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
						WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = :idioma
						AND CC_Activo__c = true];
        }

		//Si no se ha encontrado  ningún buzón se usa el por defecto en castellano
		if (buzones.isEmpty()) {
			buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
						WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano'
						AND CC_Activo__c = true];
		}

		if (!buzones.isEmpty()) {
			return buzones[0].CC_Direccion_Correo__c;
		} else {
			return null;
		}
	}

	private void gestionEntitlementsCAM(List<Case> listNewObj, List<Id> idsCAM) {
		List<Entitlement> entitlements = [SELECT Id, Name FROM Entitlement WHERE (Name = 'Buzón Carteras' OR Name='Buzón Fondos' OR Name='Buzón Valores' OR Name='Buzón SAC y corretaje')];

		for (Case caso : listNewObj) {
			if (idsCAM.contains(caso.Id) ) {

				//Informar Etitlement
				if (!entitlements.isEmpty()) {
					for(Entitlement ent: entitlements){
						if(ent.Name==caso.CC_Canal_Procedencia__c){
							caso.EntitlementId = ent.Id;
						}
					}
				}
				//Si el propietario es directamente un usuario  - informar fecha toma propiedad
				if(String.valueOf(caso.OwnerId).startsWith('005')){
				caso.AM_Fecha_ultima_toma_propiedad__c = System.now();
				}
			}
		}
	}

	private static List<Id> obtenerIdsCAM(List<Case> casos) {
		List<Id> idsCAM = new List<Id>();
		for (Case caso : casos) {
			if (caso.RecordTypeId != null
				&& Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName().startsWith('AM_')) {
					idsCAM.add(caso.Id);
			}
		}
		return idsCAM;
	}

	private void cambioEstadoPendiente(List<Case> listNewObj) {
		for (Case caso : listNewObj) {
			if(((caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Incidencia' || caso.Status == 'Pendiente Interno' || caso.Status == 'Pendiente Revisión')) || caso.Status == 'Pendiente Revisión')
			{
				caso.CC_Cambio_Estado_Pendiente__c = Date.today();
				if(caso.Status == 'Pendiente Interno')
				{
					caso.CC_Fecha_Traslado_3N__c = Datetime.now();
				}
			}
		}
	}

	private void horaSLAConsultasOperativas(List <Case> listNewObjCC){
		Boolean calcularSLA = false;
		List<Case> casosConsultasOperativas = new List<Case>();
		Map<Integer, List<Integer>> festivosPorMesMap = new  Map<Integer, List<Integer>>();

		for (Case caso : listNewObjCC) {
			if (caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas') {
				calcularSLA = true;
				casosConsultasOperativas.add(caso);
			}
		}
		if (calcularSLA) {

			Datetime ahora, slaAmarillo, slaRojo;
			festivosPorMesMap = sacarFestivosPorMes();
			Datetime fechaCreacion = System.now();
			if (!festivosPorMesMap.isEmpty()) {
				for (Case caso : casosConsultasOperativas) {
					ahora = fechaCreacion;

					//ENTRA UN CASO: 3 Posibilidades: festivo, finde y dia normal
					if(isWeekend(ahora) ||(festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day()))) {

						//sla amarillo
						do {


							ahora = ahora.addDays(1);
							if(!isWeekend(ahora) && (!festivosPorMesMap.containsKey(ahora.month()) || (festivosPorMesMap.containsKey(ahora.month())  && !festivosPorMesMap.get(ahora.month()).contains(ahora.day())))) {//si tras sumar ya no es finde ni festivo
								ahora = isWeekend(ahora.addHours(4)) || (festivosPorMesMap.containsKey(ahora.addHours(4).month()) && festivosPorMesMap.get(ahora.addHours(4).month()).contains(ahora.addHours(4).day())) ? ahora:ahora.addHours(4);
							}

						} while (isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));

						slaAmarillo = ahora;
						ahora = fechaCreacion;

						//sla Rojo
						do {

							ahora = ahora.addDays(1);
							if(!isWeekend(ahora) && (!festivosPorMesMap.containsKey(ahora.month()) || (festivosPorMesMap.containsKey(ahora.month())  && !festivosPorMesMap.get(ahora.month()).contains(ahora.day())))) {//si tras sumar ya no es finde ni festivo
								ahora = isWeekend(ahora.addDays(1)) || (festivosPorMesMap.containsKey(ahora.addDays(1).month()) && festivosPorMesMap.get(ahora.addDays(1).month()).contains(ahora.addDays(1).day())) ? ahora:ahora.addDays(1);
							}

						} while (isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));

						slaRojo = ahora;

					} else {
						ahora = (isWeekend(ahora.addHours(4)) || (festivosPorMesMap.containsKey(ahora.addHours(4).month()) && festivosPorMesMap.get(ahora.addHours(4).month()).contains(ahora.addHours(4).day()))) ? ahora:ahora.addHours(4);

						if (ahora == fechaCreacion) { //si la ahora sigue siendo igual que el createddate quiere decir que no lo ha sumado porque al sumar esas horas o bien es festivo o bien es finde
							ahora = ahora.addHours(4);
							do {

								ahora = Integer.valueOf(ahora.format('u')) == 6  ? ahora.addDays(2): ahora;
								ahora = Integer.valueOf(ahora.format('u')) == 7  ? ahora.addDays(1): ahora;
								ahora = (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())) ? ahora.addDays(1): ahora;

							} while (isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));
						}

						slaAmarillo = ahora;
						ahora = fechaCreacion;

						ahora = (isWeekend(ahora.addDays(1)) || (festivosPorMesMap.containsKey(ahora.addDays(1).month()) && festivosPorMesMap.get(ahora.addDays(1).month()).contains(ahora.addDays(1).day()))) ? ahora:ahora.addDays(1);
						if (ahora == fechaCreacion) { //si la ahora sigue siendo igual que el createddate quiere decir que no lo ha sumado porque al sumar esas horas o bien es festivo o bien es finde
							ahora = ahora.addDays(1);
							do {

								ahora = Integer.valueOf(ahora.format('u')) == 6  ? ahora.addDays(2): ahora;
								ahora = Integer.valueOf(ahora.format('u')) == 7  ? ahora.addDays(1): ahora;
								ahora = (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())) ? ahora.addDays(1): ahora;

							} while (isWeekend(ahora) || (festivosPorMesMap.containsKey(ahora.month()) && festivosPorMesMap.get(ahora.month()).contains(ahora.day())));
						}
						slaRojo = ahora;
					}
					caso.CC_FechasSLA__c = String.valueOf(slaAmarillo) + '-' +String.valueOf(slaRojo);
				}
			}
		}
	}

	//Metodo para obtener los festivos a partir de una lista de valores
	private static Map<Integer, List<Integer>> sacarFestivosPorMes (){
		List <CC_Lista_Valores__c> listaFestivos = new List < CC_Lista_Valores__c>();
		Map<Integer, List<Integer>> festivos = new Map<Integer, List<Integer>> ();

		listaFestivos = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Festivos nacionales' AND CC_Activa__c = true ORDER BY CC_Valor2__c];

		Integer mes = 0;
		Integer i = 0;
		if (!listaFestivos.isEmpty()){
			while (i < listaFestivos.size()){
				List <Integer> dias = new List <Integer>();

				while (i < listaFestivos.size() && mes == Integer.valueOf(listaFestivos[i].CC_Valor2__c)){
					dias.add(Integer.valueOf(listaFestivos[i].CC_Valor__c));
					i++;
				}
				if (dias.size() > 0){
					festivos.put(mes, dias);
				}
				mes ++;
			}
		}

		return festivos;
	}

	private static Boolean isWeekend (Datetime fecha){
		Boolean isWeekend = false;
		Integer diaSemana = Integer.valueOf(fecha.format('u'));
		isWeekend = (diaSemana > 5);

		return (isWeekend);
	}
  }