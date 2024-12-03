public without sharing class HDT_Case_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        Id idRecordTypeHdt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
		List<Case> listNewObjCC = new List<Case>();
		Map<Id, Case> mapNewObjCC = new Map<Id, Case>();
		for (Case caso : listNewObj) {
			if (caso.RecordTypeId == idRecordTypeHdt) {
				listNewObjCC.add(caso);
				mapNewObjCC.put(caso.Id, caso);
			}
		}

        if (!listNewObjCC.isEmpty()) {
            validarReaperturaCaso(mapOldObj, listNewObjCC);
            enmascararPANs(mapOldObj, listNewObjCC); // Se enmascaran los PANs de tarjeta de crédito en caso de detectarse
            encryptPANs(mapOldObj, listNewObjCC); // Se encripta el campo PAN en hexadecimal
            validarCierreCaso(mapOldObj, listNewObjCC);
            actualizarBuzonSalida(listNewObjCC, mapOldObj);
            agrupadoresInactivos(mapOldObj, listNewObjCC);
            asignacionTRZ(mapOldObj, listNewObjCC);
            horasSLATraslado(mapOldObj, listNewObjCC);
            cambioPendinteCliente(mapOldObj, listNewObjCC);
            cambioPendienteColaborador(mapOldObj, listNewObjCC);
            cambioPendienteIncidencia(mapOldObj, listNewObjCC);
            cambioPendienteInterno(mapOldObj, listNewObjCC);
            AuditCaseDetails(mapOldObj, listNewObjCC);
            calculateStateTimes(mapOldObj, listNewObjCC);
            HDT_CaseTriggerHelper.accionesBeforeUpdate(listNewObjCC, mapNewObj, mapOldObj);
            HDT_CaseTriggerHelper.caseGestionado(listNewObjCC, mapOldObj);
        }
    }

    private void enmascararPANs(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        for (Case caso : listNewObj) {
            // Se establece un patrón para el PAN
            String panRegex = '[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}';
            Pattern myPattern = Pattern.compile(panRegex);
            // Campo "Asunto"
            if (!String.isEmpty(caso.Subject) && caso.Subject != mapOldObj.get(caso.Id).Subject) {
                Integer lognitudCampo = caso.Subject.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.Subject);

                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexIncio;
                    if (caso.Subject.indexOf(asuntoMatcher.group()) != null) {
                        indexIncio = caso.Subject.indexOf(asuntoMatcher.group());
                    } else {
                        indexIncio = 0;
                    }
                    
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    Integer resta = 0;

                    if (lognitudCampo != caso.Subject.length()) {
                        resta = lognitudCampo - caso.Subject.length();
                        indexIncio = indexIncio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.Subject.length();

                    }

                    Boolean caracterDelante = false;
                    if(indexIncio -1 > 0){
                        caracterDelante = (indexIncio == 0) ? false : caso.Subject.split('').get(indexIncio-1).isNumeric();
                    }
                    Boolean caracterDetras = (indexFinal == caso.Subject.length()) ? false : caso.Subject.split('').get(indexFinal).isNumeric();

                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.Subject = caso.Subject.replace(asuntoMatcher.group(), encryptedPan);
                }
            }

            // Campo "Descripción"
            if (!String.isEmpty(caso.Description) && caso.Description != mapOldObj.get(caso.Id).Description) {
                Integer lognitudCampo = caso.Description.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.Description);

                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexInicio;
                    if (caso.Description.indexOf(asuntoMatcher.group()) != null) {
                        indexInicio = caso.Description.indexOf(asuntoMatcher.group());
                    } else {
                        indexInicio = 0;
                    }
                    Integer indexFinal = indexInicio + asuntoMatcher.group().length();
                    Integer resta = 0;

                    if (lognitudCampo != caso.Description.length()) {
                        resta = lognitudCampo - caso.Description.length();
                        indexInicio = indexInicio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.Description.length();

                    }

                    Boolean caracterDelante = false;
                    if (indexInicio -1 > 0) {
                        if (indexInicio == 0) {
                            caracterDelante = false;
                        } else {
                            caracterDelante = caso.Description.split('').get(indexInicio-1).isNumeric();
                        }
                    }
                    Boolean caracterDetras = (indexFinal == caso.Description.length()) ? false : caso.Description.split('').get(indexFinal).isNumeric();

                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.Description = caso.Description.replace(asuntoMatcher.group(), encryptedPan);
                }
            }

            // Campo "Detalle Consulta"
            if (!String.isEmpty(caso.CC_Detalles_Consulta__c) && caso.CC_Detalles_Consulta__c != mapOldObj.get(caso.Id).CC_Detalles_Consulta__c) {
                Integer lognitudCampo = caso.CC_Detalles_Consulta__c.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.CC_Detalles_Consulta__c);

                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexIncio = caso.CC_Detalles_Consulta__c.indexOf(asuntoMatcher.group()) != null ? caso.CC_Detalles_Consulta__c.indexOf(asuntoMatcher.group()): 0;
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    Integer resta = 0;

                    if (lognitudCampo != caso.CC_Detalles_Consulta__c.length()) {
                        resta = lognitudCampo - caso.CC_Detalles_Consulta__c.length();
                        indexIncio = indexIncio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.CC_Detalles_Consulta__c.length();

                    }
                    Boolean caracterDelante = false;
                    if(indexIncio -1 > 0){
                        caracterDelante = (indexIncio == 0) ? false : caso.CC_Detalles_Consulta__c.split('').get(indexIncio-1).isNumeric();
                    }
                    Boolean caracterDetras = (indexFinal == caso.CC_Detalles_Consulta__c.length()) ? false : caso.CC_Detalles_Consulta__c.split('').get(indexFinal).isNumeric();

                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.CC_Detalles_Consulta__c = caso.CC_Detalles_Consulta__c.replace(asuntoMatcher.group(), encryptedPan);
                }
            }

            // Campo "Detalle Solución"
            if (!String.isEmpty(caso.CC_Detalles_Solucion__c) && caso.CC_Detalles_Solucion__c != mapOldObj.get(caso.Id).CC_Detalles_Solucion__c) {
                Integer lognitudCampo = caso.CC_Detalles_Solucion__c.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.CC_Detalles_Solucion__c);

                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexIncio = caso.CC_Detalles_Solucion__c.indexOf(asuntoMatcher.group()) != null ? caso.CC_Detalles_Solucion__c.indexOf(asuntoMatcher.group()): 0;
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    Integer resta = 0;

                    if (lognitudCampo != caso.CC_Detalles_Solucion__c.length()) {
                        resta = lognitudCampo - caso.CC_Detalles_Solucion__c.length();
                        indexIncio = indexIncio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.CC_Detalles_Solucion__c.length();

                    }
                    Boolean caracterDelante = false;
                    if(indexIncio -1 > 0){
                        caracterDelante = (indexIncio == 0) ? false : caso.CC_Detalles_Solucion__c.split('').get(indexIncio-1).isNumeric();
                    }
                    Boolean caracterDetras = (indexFinal == caso.CC_Detalles_Solucion__c.length()) ? false : caso.CC_Detalles_Solucion__c.split('').get(indexFinal).isNumeric();

                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.CC_Detalles_Solucion__c = caso.CC_Detalles_Solucion__c.replace(asuntoMatcher.group(), encryptedPan);
                }
            }

        }
    }

    //Funcion para desencryptar el campo PAN, recibe el campo PAN encoded a b64 y crypted
    public static String decryptPANs(String b64coded) {
        List<CC_CryptoMetadata__mdt> cryptoValues = [SELECT CC_Key__c, CC_Vector__c FROM CC_CryptoMetadata__mdt LIMIT 1];
        Blob vector = null;
        Blob key = null;
        if(!cryptoValues.isEmpty()){
            vector = Blob.valueOf(cryptoValues[0].CC_Vector__c);
            key = EncodingUtil.base64decode(cryptoValues[0].CC_Key__c);
        }
        Blob b = EncodingUtil.base64decode(b64coded);
        Blob noCrypto = Crypto.decrypt('AES256', key, vector, b);

        return noCrypto.toString();
    }

    //Funcion para encryptar el campo PAN en AES256
    private void encryptPANs(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        if (!listNewObj.isEmpty()) {
            List<CC_CryptoMetadata__mdt> cryptoValues = [SELECT CC_Key__c, CC_Vector__c FROM CC_CryptoMetadata__mdt LIMIT 1];
            Blob vector = null;
            Blob key = null;
            if (!cryptoValues.isEmpty()){
                vector = Blob.valueOf(cryptoValues[0].CC_Vector__c);
                key = EncodingUtil.base64decode(cryptoValues[0].CC_Key__c);
            }

            for (Case caso : listNewObj) {
                if (caso.CC_PAN__c != mapOldObj.get(caso.Id).CC_PAN__c && !caso.CC_PAN_Encriptado__c) {
                    Blob data = Blob.valueOf(caso.CC_PAN__c);
                    Blob encrypted = Crypto.encrypt('AES256', key, vector, data);
                    String encryptedString = EncodingUtil.base64encode(encrypted);

                    caso.CC_PAN__c = encryptedString;
                    caso.CC_PAN_Encriptado__c = true;
                }

                if (caso.CC_Digitos_Tarjeta__c != mapOldObj.get(caso.Id).CC_Digitos_Tarjeta__c && !caso.CC_DigitosTarjeta_Encriptado__c) {
                    String encryptedPan = caso.CC_Digitos_Tarjeta__c.replaceAll('[^0-9]', '');
                    caso.CC_Digitos_Tarjeta__c = CC_MetodosUtiles.decimalToHex(decimal.valueOf(encryptedPan));
                    caso.CC_DigitosTarjeta_Encriptado__c = true;
                }
            }
        }
    }

    @Testvisible
    private static void cambioPendinteCliente(Map<Id, Case> mapOldObj, List<Case> listNewObj){
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).Status != 'Pendiente Cliente' && caso.Status == 'Pendiente Cliente' ){
                caso.CC_Inicio_Pendiente_Cliente__c = Datetime.now();
            } else if (mapOldObj.get(caso.Id).Status == 'Pendiente Cliente' && caso.Status == 'Activo' && mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Cliente__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                Datetime ahora = DateTime.now();
                caso.CC_Fin_Pendiente_Cliente__c = ahora;
                caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Cliente__c.getTime() != null ? mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Cliente__c.getTime()):mapOldObj.get(caso.Id).CC_Contador_Pendientes__c;
            }
        }
    }

    @Testvisible
    private static void cambioPendienteColaborador(Map<Id, Case> mapOldObj, List<Case> listNewObj){
        for (Case caso : listNewObj){
            if (mapOldObj.get(caso.Id).Status != 'Pendiente Colaborador' && caso.Status == 'Pendiente Colaborador' ){
                caso.CC_Inicio_Pendiente_Colaborador__c = DateTime.now();
            } else if (mapOldObj.get(caso.Id).Status == 'Pendiente Colaborador' && caso.Status == 'Activo' && mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Colaborador__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                Datetime ahora = DateTime.now();
                caso.CC_Fin_Pendiente_Colaborador__c = ahora;
                caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Colaborador__c.getTime());
            }
        }
    }

    @Testvisible
    private static void cambioPendienteIncidencia(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).Status != 'Pendiente Incidencia' && caso.Status == 'Pendiente Incidencia' ){
                caso.CC_Inicio_Pendiente_Incidencia__c = DateTime.now();
            }
            else if (mapOldObj.get(caso.Id).Status == 'Pendiente Incidencia' && caso.Status == 'Activo' && mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Incidencia__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                Datetime ahora = DateTime.now();
                caso.CC_Fin_Pendiente_Incidencia__c = ahora;
                caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Incidencia__c.getTime());
            }
        }
    }

    @Testvisible
    private static void cambioPendienteInterno(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).Status != 'Pendiente Interno' && caso.Status == 'Pendiente Interno' ){
                caso.CC_Inicio_Pendiente_Interno__c = DateTime.now();
            } else if (mapOldObj.get(caso.Id).Status == 'Pendiente Interno' && caso.Status == 'Activo' && mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Interno__c != null && mapOldObj.get(caso.Id).CC_Contador_Pendientes__c !=null){
                Datetime ahora = DateTime.now();
                caso.CC_Fin_Pendiente_Interno__c = ahora;
                caso.CC_Contador_Pendientes__c = mapOldObj.get(caso.Id).CC_Contador_Pendientes__c + (ahora.getTime() - mapOldObj.get(caso.Id).CC_Inicio_Pendiente_Interno__c.getTime());
            }
        }
    }

    private void horasSLATraslado(Map<Id, Case> mapOldObj, List<Case> listNewObj){
        Map <Id, Case> casosCambiar = new Map <Id, Case>();
        Map <Id, Datetime> casosFecha = new Map <Id, Datetime>();

        for (Case caso : listNewObj){
            String[] pendienteStatus = new String[]{'Pendiente Colaborador', 'Pendiente Interno', 'Pendiente Incidencia'};
            Set<String> pendienteStatusSet = new Set<String>(pendienteStatus);
        
            if (mapOldObj.get(caso.Id).Status == 'Activo' && pendienteStatusSet.contains(caso.Status) && (caso.Origin == 'Chat' || caso.Origin == 'Phone')){
                casosCambiar.put(caso.Id, caso);
                casosFecha.put(caso.Id, caso.Status == 'Pendiente Colaborador' ? caso.CC_Fecha_Traslado_Colaborador__c : DateTime.now());
            }
        }

        if (!casosCambiar.isEmpty()){
            Map<String, Map<String, List<Time>>> horariosPorCanalProcedencia = horariosPorCanalProcedencia();
            Map<Integer, List<Integer>> festivosPorMesMap = sacarFestivosPorMes();
            
            for (Case caso : casosCambiar.values()){
                if (caso.CC_Horas_Hasta_Traslado__c == null || caso.CC_Horas_Hasta_Traslado__c == 0){
                    caso.CC_Horas_Hasta_Traslado__c = calcularSLA(caso, horariosPorCanalProcedencia.get(caso.CC_Canal_Procedencia__c), casosFecha.get(caso.Id), festivosPorMesMap);
                }
            }
        }
        
    }

    @Testvisible
    private static Double calcularSLA (Case caso, Map<String, List <Time>> horario, Datetime fechaTraslado, Map<Integer, List<Integer>> festivos){
        Datetime fechaCreacion = caso.CreatedDate;
        Double horasPasadas = 0;

        if(fechaTraslado != null && fechaCreacion !=null){
            //Trabajan 24/7
            if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente' || (caso.Origin == 'Chat') || (horario == null)){
                //No se pueden restar campos tipo dateTime, por lo que hay que pasarlo a ms y después a horas para restarlo
                horasPasadas =  restarHoras(fechaTraslado, fechaCreacion);
                if (caso.CC_Inicio_Pendiente_Cliente__c != null && caso.CC_Fin_Pendiente_Cliente__c != null){
                    horasPasadas = horasPasadas - restarHoras(caso.CC_Fin_Pendiente_Cliente__c, caso.CC_Inicio_Pendiente_Cliente__c);
                }
            }
            else{
                Double horasTrabajoViernes;
                Double horasTrabajoNormal;
                if (horario.size() > 1){

                    horasTrabajoViernes = restarHoras(horario.get('V').get(1), horario.get('V').get(0));
                    horasTrabajoNormal = restarHoras(horario.get('L-J').get(1), horario.get('L-J').get(0));
                }
                else{
                    horasTrabajoNormal = restarHoras(horario.get('L-V').get(1), horario.get('L-V').get(0));
                }

                if (!fechaCreacion.isSameDay(fechaTraslado)){
                    Datetime diaSemanaBucle = fechaCreacion.date();
                    //Horas que cuentan del primer día, si no se ha trasladado el mismo día que se hace el traslado
                    if (fechaCreacion.time() >= horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada') && fechaCreacion.time() <= horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida')){

                        if (caso.CC_Inicio_Pendiente_Cliente__c != null && fechaCreacion.isSameDay(caso.CC_Inicio_Pendiente_Cliente__c)) { // Si ha habido una petición de información
                            horasPasadas = horasPasadas + restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), fechaCreacion.time());
                            if (caso.CC_Fin_Pendiente_Cliente__c != null && fechaCreacion.isSameDay(caso.CC_Fin_Pendiente_Cliente__c)) {
                                if (caso.CC_Fin_Pendiente_Cliente__c.time() <= horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida')) {  // Si se ha recibido la peticion de cliente en horario laboral
                                    horasPasadas = horasPasadas + restarHoras(horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida'), caso.CC_Fin_Pendiente_Cliente__c.time());
                                }
                            }
                        }
                        else{
                            //Si no ha habido una petición de información
                            horasPasadas = horasPasadas + restarHoras(horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida'), fechaCreacion.time());

                        }
                    }
                    else{
                        if (fechaCreacion.time() < horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada')){     //El caso se ha creado antes de que entraran a trabajar
                            if (caso.CC_Inicio_Pendiente_Cliente__c != null && fechaCreacion.isSameDay(caso.CC_Inicio_Pendiente_Cliente__c)) { // Si ha habido una petición de información
                                horasPasadas = horasPasadas + restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                            }
                            else{
                                horasPasadas = horasPasadas + restarHoras(horarioDiaTurno(horario, fechaCreacion.format('u'), 'Salida'), horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                            }
                        }

                    }
                    Integer i = 1;
                    
                    while (!diaSemanaBucle.addDays(i).format('u').equals(fechaTraslado.format('u'))) {
                        Boolean solicitudInformacionAtendida = false;
                        DateTime currentDay = diaSemanaBucle.addDays(i);
                        String currentDayFormat = currentDay.format('u');
                        DateTime inicioPendienteCliente = caso.CC_Inicio_Pendiente_Cliente__c;
                        DateTime finPendienteCliente = caso.CC_Fin_Pendiente_Cliente__c;
                    
                        if (!isFestive(currentDay, festivos) && !isWeekend(currentDay)) {
                            if (inicioPendienteCliente != null && currentDay.isSameDay(inicioPendienteCliente)) {
                                horasPasadas += solicitudInformacionAtendida ? 0 : restarHoras(inicioPendienteCliente.time(), horarioDiaTurno(horario, currentDayFormat, 'Entrada'));
                                solicitudInformacionAtendida = true;
                            }
                    
                            if (finPendienteCliente != null && currentDay.isSameDay(finPendienteCliente)) {
                                if (finPendienteCliente.time() < horarioDiaTurno(horario, currentDayFormat, 'Entrada')) {
                                    horasPasadas += Integer.valueOf(currentDayFormat) == 5 ? horasTrabajoViernes : horasTrabajoNormal;
                                } else if (finPendienteCliente.time() <= horarioDiaTurno(horario, currentDayFormat, 'Salida')) {
                                    horasPasadas += restarHoras(horarioDiaTurno(horario, currentDayFormat, 'Salida'), finPendienteCliente.time());
                                }
                                solicitudInformacionAtendida = true;
                            }
                    
                            if (!solicitudInformacionAtendida) {
                                horasPasadas += Integer.valueOf(currentDayFormat) == 5 ? horasTrabajoViernes : horasTrabajoNormal;
                            }
                        }
                        i++;
                    }

                    if (caso.CC_Fin_Pendiente_Cliente__c != null && fechaCreacion.addDays(i).isSameDay(caso.CC_Fin_Pendiente_Cliente__c)){ //Si el día de traslado ha sido el mismo día que se ha recibido la información
                        if (caso.CC_Fin_Pendiente_Cliente__c.time() < horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada')){  //Si se recibe la información cuando no está trabajando
                            horasPasadas = horasPasadas + restarHoras(fechaTraslado.time(), horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada'));
                        }
                        else{
                            horasPasadas = horasPasadas + restarHoras(fechaTraslado.time(), caso.CC_Fin_Pendiente_Cliente__c.time());
                        }
                        if (fechaCreacion.addDays(i).isSameDay(caso.CC_Inicio_Pendiente_Cliente__c)){ //Si la solicitud de información se ha hecho el mismo día que el traslado
                            horasPasadas = horasPasadas + restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), horarioDiaTurno(horario, fechaCreacion.addDays(i).format('u'), 'Entrada'));
                        }
                    }
                    else{
                        horasPasadas = horasPasadas + restarHoras(fechaTraslado.time(), horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                    }
                }

                if (fechaCreacion.time() >= horarioDiaTurno(horario, fechaTraslado.format('u'), 'Entrada') && fechaCreacion.time() <= horarioDiaTurno(horario, fechaTraslado.format('u'), 'Salida')) {
                    horasPasadas += (caso.CC_Inicio_Pendiente_Cliente__c != null && caso.CC_Fin_Pendiente_Cliente__c != null) ? restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), fechaCreacion.time()) + restarHoras(fechaTraslado.time(), caso.CC_Fin_Pendiente_Cliente__c.time()) : restarHoras(fechaTraslado.time(), fechaCreacion.time());
                } else {
                    horasPasadas += (caso.CC_Inicio_Pendiente_Cliente__c != null && caso.CC_Fin_Pendiente_Cliente__c != null) ? restarHoras(caso.CC_Inicio_Pendiente_Cliente__c.time(), horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada')) + restarHoras(fechaTraslado.time(), caso.CC_Fin_Pendiente_Cliente__c.time()) : restarHoras(fechaTraslado.time(), horarioDiaTurno(horario, fechaCreacion.format('u'), 'Entrada'));
                }
            }
        }

        return horasPasadas;
    }


    @Testvisible
    private static Time horarioDiaTurno(Map<String, List<Time>> horario, String diaSemana, String entradaOsalida) {
        Integer dia = Integer.valueOf(diaSemana);
        Integer index = (dia == 5) ? (entradaOsalida == 'Entrada' ? 0 : 1) : (entradaOsalida == 'Entrada' ? 0 : 1);
        String key = (dia == 5) ? (horario.size() > 1 ? 'V' : 'L-V') : (horario.size() > 1 ? 'L-J' : 'L-V');
        return horario.get(key).get(index);
    }

    @Testvisible
    //Método para saber si el día que se pasa por parámetro con la lista de valores pasada por parámetro es festivo o no
    private static Boolean isFestive (Datetime fecha, Map <Integer, List <Integer>> listaFestivos){
        Boolean isFestivo = false;
        if (!listaFestivos.isEmpty()) {
            Integer mes = fecha.month();
            Integer dia = fecha.day();
            if (listaFestivos != null && mes >= 1 && dia >= 1 && listaFestivos.get(mes)!=null){
                isFestivo = listaFestivos.get(mes).contains(dia);
            }
        }

        return (isFestivo);
    }

    @Testvisible
    //Método para saber si la fecha que se le pasa por parámetro es fin de semana
    private static Boolean isWeekend (Datetime fecha){
        Boolean isWeekend = false;
        Integer diaSemana = Integer.valueOf(fecha.format('u'));
        isWeekend = (diaSemana > 5);

        return (isWeekend);
    }

    //Método para restar horas
    //hora1:minuto1 - hora2:minuto2
    @Testvisible
    private static Double restarHoras (DateTime fecha1, DateTime fecha2){
        Double horaResultadoResta = 0;

        Long msegRestados = 0;
        if (fecha1 >= fecha2){
            msegRestados = fecha1.getTime() - fecha2.getTime();

        }
        else{
            msegRestados = fecha2.getTime() - fecha1.getTime();
        }
        horaResultadoResta = (Double)msegRestados/(1000L*60L*60L);


        return (horaResultadoResta);
    }

    @Testvisible
    private static Double restarHoras (Time fecha1, Time fecha2){
        Datetime fechaA = Datetime.newInstance(Date.today(), fecha1);

        Datetime fechaB = Datetime.newInstance(Date.today(), fecha2);

        Double horaResultadoResta = restarHoras(fechaA, fechaB);

        return (horaResultadoResta);
    }

    @Testvisible
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

    @Testvisible
    //Metodo para sacar el horario de toda la semana a partir de una Lista de valores
    private static Map<String, Map<String, List <Time>>> horariosPorCanalProcedencia (){
        List <CC_Lista_Valores__c> listaHorarios = new List < CC_Lista_Valores__c>();
        Map<String, Map<String, List <Time>>> horarioPorCanalProcedenciaMap = new Map<String, Map<String, List <Time>>> ();

        listaHorarios = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Calendario_servicios' AND CC_Activa__c = true ORDER BY CC_Valor__c];

        Integer i = 0;
        String nombre = '';

        if (!listaHorarios.isEmpty()){
            while (i < listaHorarios.size()){
                nombre = listaHorarios.get(i).Name;
                Map<String, List <Time>> horarioSemanaCanalProcedencia = new Map<String, List <Time>>();
                while (i < listaHorarios.size() && nombre == listaHorarios.get(i).Name){
                    //Sacar horas y ponerlas en formato Time horariosDiaList -> List<Time> -> 8:30:0:0; 20:30:0:0
                    List<Time> horariosDiaList = new List<Time>();
                    horariosDiaList = pasarHorasListaValores(listaHorarios.get(i));
                    horarioSemanaCanalProcedencia.put(listaHorarios.get(i).CC_Valor_SFDC__c, horariosDiaList);
                    i++;
                }
                if (!horarioSemanaCanalProcedencia.isEmpty()){
                    horarioPorCanalProcedenciaMap.put(nombre, horarioSemanaCanalProcedencia);
                }
            }
        }


        return horarioPorCanalProcedenciaMap;
    }
    
    //Metodo para pasar de String a Time desde una lista de valores
    private static List<Time> pasarHorasListaValores (CC_Lista_Valores__c listaHorarios){
        List<Time> horarioDia = new List<Time>();

        //Hacemos el split por si la hora de entrada o de salida es del formato 8:30 o 8'30
        if (listaHorarios != null){
            List<String> splitEntrada = listaHorarios.CC_Valor__c.splitByCharacterType();
            List<String> splitSalida = listaHorarios.CC_Valor2__c.splitByCharacterType();
            Integer minutos = 0;
            if (splitEntrada.size() > 1) {
                minutos = Integer.valueOf(splitEntrada.get(splitEntrada.size()-1));
            }
            Time hora = Time.newInstance(Integer.valueOf(splitEntrada.get(0)), minutos, 0, 0);
            horarioDia.add(hora);
            minutos = 0;
            if (splitSalida.size() > 1) {
                minutos = Integer.valueOf(splitSalida.get(splitSalida.size()-1));
            }
            hora = Time.newInstance(Integer.valueOf(splitSalida.get(0)), minutos, 0, 0);
            horarioDia.add(hora);
        }

        return horarioDia;
    }

    @TestVisible
    private static void validarReaperturaCaso(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        for (Case caso : listNewObj) {
            Case oldCaso = mapOldObj.get(caso.Id); // Obtener el estado anterior del caso actual
            if (!FeatureManagement.checkPermission('HDT_ReactivarCaso3Dias') && oldCaso.IsClosed && HDT_CaseTriggerHelper.hanPasadoTresDiasDesdeCierre(oldCaso)) {
                caso.addError('No es posible reactivar el caso, ya que han pasado más de 3 días desde su cierre.');
            }
        }
    }

    @TestVisible
    private static void validarCierreCaso(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        if (!listNewObj.isEmpty()) {
            String profileName;
            List<Profile> profiles = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            if (!profiles.isEmpty()) { //El perfil del usuario Automated Process no es visible
                profileName = profiles[0].Name;
            }

            Map<Id, Case> casoIdCaso = new Map<Id, Case>();
            for (Case caso : listNewObj) {
                if (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado') {
                    if (!Test.isRunningTest() && !System.isBatch()
                    && profileName != null && profileName != 'CC_Integración' && profileName.startsWith('CC')
                    && (mapOldObj.get(caso.Id).CC_Cerrado_Operativa__c == caso.CC_Cerrado_Operativa__c)
                    && (mapOldObj.get(caso.Id).CC_Fecha_Cierre_SolInf__c == caso.CC_Fecha_Cierre_SolInf__c)) {
                        caso.addError('Debe usar el botón \'Guardar y Cerrar\' o la operativa correspondiente');
                    } else {
                        casoIdCaso.put(caso.Id, caso);
                    }
                }
            }

            if (!casoIdCaso.isEmpty()) {
                //Buscamos los tipos de actividad excluidos de la validación
                List<String> actividadesExcluidas = new List<String>();
                for (CC_Actividad_Cerrar_Caso__mdt actividad : [SELECT MasterLabel FROM CC_Actividad_Cerrar_Caso__mdt]) {
                    actividadesExcluidas.add(actividad.MasterLabel);
                }

                //Damos error para los casos con actividades abiertas (no excluidas)
                List<Task> actividades = [SELECT WhatId, Type, Status, Subject, CC_Tipo_Cierre__c FROM Task WHERE WhatId IN :casoIdCaso.keySet()
                AND Type NOT IN :actividadesExcluidas];

                Id recordType3N = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Tercer_Nivel').getRecordTypeId();
                List<CC_Grupo_Colaborador__c> listaGruposColaboradores = [SELECT Name, RecordTypeId FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :recordType3N AND Name <> NULL];

                //Mirar si el caso tiene tarea completada de reasignación con un grupo de 3N
                Set<Id> setCasos3N = new Set<Id>();
                if(!actividades.isEmpty()){
                    for(Task tarea : actividades){
                        String nombreGrupo = tarea.Subject;
                        if(nombreGrupo != null){
                            for(CC_Grupo_Colaborador__c grupo : listaGruposColaboradores){
                                if(tarea?.Status == 'Completed' && nombreGrupo?.contains(grupo.Name) && tarea?.Type == 'Reasignación'){
                                    setCasos3N.add(tarea.WhatId);
                                }
                            }
                        }
                    }
                }

                //Cerrar Actividad 3N en caso que este abierta
                List<Task> cerrarTareas = new List<Task>();
                if (!setCasos3N.isEmpty() && !actividades.isEmpty()) {
                    for (Id idCaso : setCasos3N) {
                        for (Task tarea : actividades) {
                            if(idCaso == tarea.WhatId && tarea.Status == 'Open' && tarea.Type == 'Traslado Tercer Nivel'){
                                tarea.Status = 'Completed';
                                tarea.CC_Tipo_Cierre__c = 'Resuelto por 3N';
                                cerrarTareas.add(tarea);
                            }
                        }
                    }
                }
                update cerrarTareas;

                for (Task actividad : actividades) {
                    if (actividad.Status == 'Open') {
                        casoIdCaso.get(actividad.WhatId).addError('Existen actividades pendientes que deben completarse antes de cerrar el caso.');
                    }
                }
            }
        }
    }

    private void actualizarBuzonSalida(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        for (Case caso : listNewObj) {
            if (caso.CC_Canal_Procedencia__c != mapOldObj.get(caso.Id).CC_Canal_Procedencia__c
            || caso.CC_Idioma__c != mapOldObj.get(caso.Id).CC_Idioma__c) {
                //El canal de procedencia o el idioma han cambiado, se actualiza el buz�n de salida del caso
                caso.CC_Buzon_Salida__c = obtenerBuzon(caso.CC_Canal_Procedencia__c, caso.CC_Idioma__c);
            }
        }
    }

   
    @Testvisible
    private static String obtenerBuzon(String canalProcedencia, String idioma) {
		idioma = idioma == 'ca' ? 'Català' : idioma == 'en' ? 'Inglés' : 'Castellano';

        List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                        WHERE CC_Canal_Procedencia__c = :canalProcedencia AND CC_Idioma__c = :idioma];
        if (buzones.isEmpty()) { //Si no se ha encontrado  ningún buzón se usa el por defecto en el idioma del caso
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                        WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = :idioma AND CC_Activo__c = TRUE];
        }
        if (buzones.isEmpty()) { //Si no se ha encontrado  ningún buzón se usa el por defecto en castellano
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                        WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = TRUE];
        }
        return !buzones.isEmpty() ? buzones[0].CC_Direccion_Correo__c : null;
    }

    @Testvisible
    private static void agrupadoresInactivos(Map<Id, Case> mapOldObj, List<Case> listNewObj) {

        if (!listNewObj.isEmpty()) {
            Map<Id, List<Case>> casoIdCaso = new Map<Id, List<Case>>();
            Set<Id> idsAgrupadores = new Set<Id>();
            List<Case> idsCasos = new List<Case>();
            Set<Id> setIdsCasos = new Set<Id>();
            Map<Id, Case> agrupadorCaso = new Map<Id, Case>();
            Map<Id, List<Case>> mapIdCaseURL = new Map<Id, List<Case>>();

            for (Case caso : listNewObj) {
                if ((mapOldObj.get(caso.Id).CC_Agrupador_Id__c != caso.CC_Agrupador_Id__c) || (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado') ) {
                    idsAgrupadores.add(caso.CC_Agrupador_Id__c);

                    if(casoIdCaso.containsKey(caso.CC_Agrupador_Id__c)) {
                        List<Case> listCasos = casoIdCaso.get(caso.CC_Agrupador_Id__c);
                        listCasos.add(caso);
                        casoIdCaso.put(caso.CC_Agrupador_Id__c, listCasos);
                    } else {
                        casoIdCaso.put(caso.CC_Agrupador_Id__c, new List<Case> { caso });
                    }

                    if(mapIdCaseURL.containsKey(caso.CC_Agrupador_Id__c)) {
                        List<Case> listCasos = mapIdCaseURL.get(caso.CC_Agrupador_Id__c);
                        listCasos.add(caso);
                        mapIdCaseURL.put(caso.CC_Agrupador_Id__c, listCasos);
                    } else {
                        mapIdCaseURL.put(caso.CC_Agrupador_Id__c, new List<Case> { caso });
                    }
                }
            }

            if (!idsAgrupadores.isEmpty()) {
                for (CC_Agrupador__c agrupador : [SELECT CC_Estado__c, RecordTypeId, RecordType.DeveloperName FROM CC_Agrupador__c WHERE ID IN :idsAgrupadores]) {
                    for (Case caso : casoIdCaso.get(agrupador.Id)) {
                        if (agrupador != null && caso != null && caso.Status != 'Cerrado'
                        && (agrupador.CC_Estado__c == null || agrupador.CC_Estado__c == 'Cerrado' || agrupador.CC_Estado__c == 'Rechazado')) {
                            caso.addError('Solo se pueden asociar agrupadores activos.');
                        } else if (caso.Status == 'Cerrado' && mapOldObj.get(caso.Id).Status != 'Cerrado'
                        && caso.RecordTypeId != null && Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName().startsWith('HDT_Empleado')
                        && caso.CC_URL_Encuesta_3N__c == null && agrupador.RecordType.DeveloperName == 'CC_Incidencia' && mapIdCaseURL.get(agrupador.Id) != null) {
                            idsCasos.add(caso);
                            setIdsCasos.add(caso.Id);
                        }
                    }
                }
            }

            if (!idsCasos.isEmpty()) {
                generarURLLimeSurvey(idsCasos, setIdsCasos); //Generar la encuesta de empleados
                //generarURL(idsCasos);
            }
        }
    }

    @Testvisible
    private static void generarURLLimeSurvey(List<Case> listNewObj, Set<Id> setIdsCasos){
        //Crear un nuevo Custom Setting para las encuestas de 3Nivel solo de HDT
        //Obtenemos el custom setting de HDT Parametros para obtener el Id y la URL de la encuesta (Configuracion_1: Id Encuesta, Configuracion_2: URL)
        List<HDT_Parametros__c> linkEncuestaEmpleado3N = [SELECT HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_3N'];
        List<HDT_Parametros__c> linkEncuestaEmpleado3NEDG = [SELECT HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_3N_EDG'];

        List<CC_Lista_Valores__c> listaCanalResolucion = [SELECT Name,CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Valor__c = 'EDG' AND CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];
        
		Set<String> canalesResolucionEDG = new Set<String>();
        for (CC_Lista_Valores__c resolucion : listaCanalResolucion) {
            if(resolucion.CC_Activa__c){
                canalesResolucionEDG.add(resolucion.Name);
            }
        }

        List<CC_Lista_Valores__c> listaCanalResolucion2 = [SELECT Name,CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Valor__c = 'No EDG' AND CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];
        
		Set<String> canalesResolucion = new Set<String>();
        for (CC_Lista_Valores__c resolucion2 : listaCanalResolucion2) {
            if(resolucion2.CC_Activa__c){
                canalesResolucion.add(resolucion2.Name);
            }
        }

        //Añadimos los canales de resolución a una lista para luego comprobar que es uno de los que aplica
        //Set<String> canalesResolucion = new Set<String>{'Incidencias Técnicas', 'Servicios Centrales', 'SmartPhones'};


         //Traigo la base del link LimeSurvey para usar con Empleado
        //List<CC_Envio_Encuesta__c> linkEncuestaEmpleado = [SELECT CC_Link_LimeSurvey__c, CC_Id_Encuesta__c FROM CC_Envio_Encuesta__c WHERE Name = 'CC_URL_Encuesta'];
        Map<Id, Case> mapInfoCasos = new Map<Id, Case>([SELECT Origin, CaseNumber, CC_Idioma__c, CC_URL_Encuesta_3N__c,CC_Matricula_Empleado__c, CC_MCC_Tematica__r.name, CC_MCC_Tematica__r.CC_idCognitivo__c, CC_MCC_Tematica__c FROM Case WHERE Id IN :setIdsCasos]);

        for(Case caso :listNewObj){
            if(mapInfoCasos.get(caso.Id) != null && caso.CC_Idioma__c != null && caso.CC_Matricula_Empleado__c != null && caso.CC_MCC_Tematica__c != null && mapInfoCasos.get(caso.Id).CC_MCC_Tematica__r.name != null && !linkEncuestaEmpleado3N.isEmpty()){
                if(caso.Origin != 'Chat'){                    
                    //Para casos de teléfono
                    /*
                    //Caso en el canal de procedencia SI ES uno de las edgs
                    if(canalesResolucionEDG.contains(caso.CC_Canal_Resolucion__c)){ 
                        caso.CC_URL_Encuesta_3N__c = (String)linkEncuestaEmpleado3NEDG[0].HDT_Configuracion_2__c+'sid='+linkEncuestaEmpleado3NEDG[0].HDT_Configuracion_1__c+'&lang='+caso.CC_Idioma__c+'&empresa='+caso.CC_Canal_Resolucion__c+
                        '&userid='+caso.CC_Matricula_Empleado__c+'&ticketid='+caso.CaseNumber+'&idet='+caso.CC_MCC_Tematica__c+'&et='+ mapInfoCasos.get(caso.Id).CC_MCC_Tematica__r.name.replace(' ', '_')+'&newtest=Y';
                    }*/

                    if (canalesResolucionEDG.contains(caso.CC_Canal_Resolucion__c)) {
                        caso.CC_URL_Encuesta_3N__c = HDT_CaseTriggerHelper.generarUrlEncuesta(
                            (String)linkEncuestaEmpleado3NEDG[0].HDT_Configuracion_2__c,
                            (String)linkEncuestaEmpleado3NEDG[0].HDT_Configuracion_1__c,
                            caso.CC_Idioma__c,
                            caso.CC_Canal_Resolucion__c,
                            caso.CC_Matricula_Empleado__c,
                            caso.CaseNumber,
                            caso.CC_MCC_Tematica__c,
                            mapInfoCasos.get(caso.Id).CC_MCC_Tematica__r.name
                        );
                    }
                    
                    /*
                    if(canalesResolucion.contains(caso.CC_Canal_Resolucion__c)){         
                        caso.CC_URL_Encuesta_3N__c = (String)linkEncuestaEmpleado3N[0].HDT_Configuracion_2__c+'sid='+linkEncuestaEmpleado3N[0].HDT_Configuracion_1__c+'&lang='+
                        caso.CC_Idioma__c+'&userid='+caso.CC_Matricula_Empleado__c+'&ticketid='+caso.CaseNumber+'&idet='+caso.CC_MCC_Tematica__c+'&et='+ mapInfoCasos.get(caso.Id).CC_MCC_Tematica__r.name.replace(' ', '_')+'&newtest=Y';    
                    }*/

                    if (canalesResolucion.contains(caso.CC_Canal_Resolucion__c)) {         
                        caso.CC_URL_Encuesta_3N__c = HDT_CaseTriggerHelper.generarUrlEncuesta(
                            (String)linkEncuestaEmpleado3N[0].HDT_Configuracion_2__c,
                            (String)linkEncuestaEmpleado3N[0].HDT_Configuracion_1__c,
                            caso.CC_Idioma__c,
                            null, // No se usa 'empresa' en esta condición
                            caso.CC_Matricula_Empleado__c,
                            caso.CaseNumber,
                            caso.CC_MCC_Tematica__c,
                            mapInfoCasos.get(caso.Id).CC_MCC_Tematica__r.name
                        );    
                    }         
                }else if(caso.Origin == 'Chat'){
                    caso.CC_URL_Encuesta_3N__c = HDT_CaseTriggerHelper.generarUrlEncuesta(
                        linkEncuestaEmpleado3N[0].HDT_Configuracion_2__c,
                        (String)linkEncuestaEmpleado3N[0].HDT_Configuracion_1__c,
                        caso.CC_Idioma__c,
                        null, // No se usa 'empresa' para Chat
                        caso.CC_Matricula_Empleado__c,
                        caso.CaseNumber,
                        caso.CC_MCC_Tematica__c,
                        mapInfoCasos.get(caso.Id).CC_MCC_Tematica__r.name
                    );               
                 }
            }
        }
    }


    @Testvisible
    private static CC_MCC__c encontrarMCCPorId (List<CC_MCC__C> lista, Id id) {
        for (CC_MCC__c mcc : lista) {
            if (mcc.id == id) {
                return mcc;
            }
        }
        return null;
    }

    @Testvisible
    //Funcion para generar registros de Trazabilidad
    private static void asignacionTRZ(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<Id> casosAsignacion = new List<Id>();
        List<Id> casosResolucion = new List<Id>();
        List<Id> casosCierre = new List<Id>();

        for (Case caso : listNewObj) {
            //Asignacion del caso
            if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.CC_Fecha_Reapertura__c == null && caso.CC_Fecha_Limite_Resolucion__c != null) {
                caso.CC_Tramo_TRZ__c = 'Asignada - En gestion';
                casosAsignacion.add(caso.Id);
            }
            //Resolucion y Cierre
            if (caso.Status == 'Cerrado' && mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.CC_Fecha_Limite_Resolucion__c != null) {
                caso.CC_Tramo_TRZ__c = 'Cerrada';
                casosResolucion.add(caso.Id);
                casosCierre.add(caso.Id);
            } else if (caso.Status == 'Rechazado' && mapOldObj.get(caso.Id).Status != 'Rechazado' && caso.CC_Fecha_Limite_Resolucion__c != null) { //Rechazo
                caso.CC_Tramo_TRZ__c = 'Cerrada';
                casosCierre.add(caso.Id);
            }
        }

        if (!casosAsignacion.isEmpty()) {
            CC_Trazabilidad_Methods.altaPaso('Asignacion', '', casosAsignacion);
        }
        if (!casosResolucion.isEmpty()) {
            CC_Trazabilidad_Methods.altaPaso('Resolucion', '', casosResolucion);
        }
        if (!casosCierre.isEmpty()) {
            CC_Trazabilidad_Methods.altaPaso('Cierre',     '', casosCierre);
        }
    }

    // Desarrollo para la implementación de Historial de modificación de casos
    // Desarrollado por Moisés Cano Ortiz
    // Fecha : 09/10/2023
    @Testvisible
    private static void AuditCaseDetails(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<CBK_CaseHistory__c> caseHistoryRecords = new List<CBK_CaseHistory__c>();
        Schema.DescribeFieldResult fieldDescribe;
        for (Case newCase : listNewObj) {
            Case oldCase = mapOldObj.get(newCase.Id);
            for (Schema.FieldSetMember field : SObjectType.Case.FieldSets.HDT_CaseHistory.getFields()) {
                String fieldName = field.getFieldPath();
                fieldDescribe = Case.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe();
                String fieldLabel = fieldDescribe.getLabel();

                if (newCase.get(fieldName) != oldCase.get(fieldName)) {
                    CBK_CaseHistory__c caseHistoryRecord = new CBK_CaseHistory__c();
                    caseHistoryRecord.CBK_IsDeleted__c = false;
                    caseHistoryRecord.CBK_CaseId__c = newCase.Id;
                    caseHistoryRecord.CBK_CreatedDate__c = Date.today();
                    caseHistoryRecord.CBK_Field__c = fieldLabel;
                    caseHistoryRecord.CBK_DataType__c = String.valueOf(field.getType());
                    caseHistoryRecord.CBK_OldValue__c = String.valueOf(oldCase.get(fieldName));
                    caseHistoryRecord.CBK_NewValue__c = String.valueOf(newCase.get(fieldName));
                    caseHistoryRecords.add(caseHistoryRecord);
                }
            }
        }
        if (!caseHistoryRecords.isEmpty()) {
            insert caseHistoryRecords;
        }
    }

    public static void calculateStateTimes(Map<Id, Case> mapOldCases, List<Case> listNewCases) {

        String businessHoursName = 'HDT_Empleados_TMR';
        // Obtener el ID de la Business Hour 'Empleados'
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = :businessHoursName LIMIT 1];
        Id businessHoursId = bh.Id;

        // Recopilar todos los IDs de los nuevos casos
        Set<Id> caseIds = new Set<Id>();
        for (Case newCase : listNewCases) {
            caseIds.add(newCase.Id);
        }

        // Obtener el historial de estado de todos los casos en una sola consulta
        Map<Id, CaseHistory> caseHistoryMap = new Map<Id, CaseHistory>();
        if (!caseIds.isEmpty()) {
            List<CaseHistory> historyList = [
                SELECT CaseId, CreatedDate, Field, OldValue, NewValue
                FROM CaseHistory 
                WHERE CaseId IN :caseIds AND Field = 'Status'
                ORDER BY CreatedDate DESC
            ];
            for (CaseHistory history : historyList) {
                if (!caseHistoryMap.containsKey(history.CaseId)) {
                    caseHistoryMap.put(history.CaseId, history);
                }
            }
        }

        // Iterar sobre cada caso en la lista de nuevos casos
        for (Case newCase : listNewCases) {
            Case oldCase = mapOldCases.get(newCase.Id); 
            if (oldCase.Status != newCase.Status ) {
                Long activeTimeMs = (newCase.CC_Tiempo_Nivel_1__c != 0 ? (newCase.CC_Tiempo_Nivel_1__c * 60000).longValue() : 0);
                Long pendingClientTimeMs = (newCase.CC_Tiempo_Nivel_2__c != 0 ? (newCase.CC_Tiempo_Nivel_2__c * 60000).longValue() : 0);
                Long pendingIncidentTimeMs = (newCase.CC_Tiempo_Nivel_3__c != 0 ? (newCase.CC_Tiempo_Nivel_3__c * 60000).longValue() : 0);
                Long pendingReviewTimeMs = (newCase.CC_Tiempo_Empleado__c != 0 ? (newCase.CC_Tiempo_Empleado__c * 60000).longValue() : 0);
                DateTime stateChangeTime = DateTime.now();

                /*
                 // Obtener los cambios de estado del historial del caso
                List<CaseHistory> historyList = [SELECT CreatedDate, Field, OldValue, NewValue 
                FROM CaseHistory 
                WHERE CaseId = :newCase.Id AND Field = 'Status'
                ORDER BY CreatedDate DESC limit 1];*/

                // Obtener el historial del caso desde el mapa
                CaseHistory history = caseHistoryMap.get(newCase.Id);

                // Si la lista de historia está vacía, continuar con la lógica pero sin basarse en los datos de historia
                if (history != null) {

                    // Asegurarse de que se usa una fecha de inicio válida
                    //DateTime startTime = oldCase.LastModifiedDate != null ? oldCase.LastModifiedDate : DateTime.now();
                    DateTime startTime = history.CreatedDate != null ? history.CreatedDate : DateTime.now();
                    // Calcular tiempo efectivo en milisegundos para el estado anterior
                    Long milliseconds = BusinessHours.diff(businessHoursId, startTime, stateChangeTime);

                    if (milliseconds != null) {
                        if (oldCase.Status == 'Activo') {
                            activeTimeMs += milliseconds;
                        } else if (oldCase.Status == 'Pendiente Cliente') {
                            pendingClientTimeMs += milliseconds;
                        } else if (oldCase.Status == 'Pendiente Incidencia') {
                            pendingIncidentTimeMs += milliseconds;
                        } else if (oldCase.Status == 'Pendiente Revisión') {
                            pendingReviewTimeMs += milliseconds;
                        }
                    }

                    // Convertir los tiempos acumulados de milisegundos a minutos antes de guardarlos
                    newCase.CC_Tiempo_Nivel_1__c  = activeTimeMs / 60000;
                    newCase.CC_Tiempo_Nivel_2__c  = pendingClientTimeMs / 60000;
                    newCase.CC_Tiempo_Nivel_3__c  = pendingIncidentTimeMs / 60000;
                    newCase.CC_Tiempo_Empleado__c = pendingReviewTimeMs / 60000;
                }else {
                    // Convertir tiempos almacenados en minutos a milisegundos para acumulación precisa
                    Long activeTimeMsAct = (oldCase.CC_Tiempo_Nivel_1__c != 0 ? (oldCase.CC_Tiempo_Nivel_1__c * 60000).longValue() : 0);
                    //Solo lo ejecutamos una vez cuando cambiamos a un estado diferente al Activo
                    if ((activeTimeMsAct == 0) && (oldCase.Status == 'Activo')) {
                            // Asegurarse de que se usa una fecha de inicio válida
                            DateTime inicioTiempo = oldCase.CreatedDate != null ? oldCase.CreatedDate : DateTime.now();
                            // Si es el primer cambio de estado, calcular el tiempo desde la creación hasta este primer cambio
                            Long millisecondsa = BusinessHours.diff(businessHoursId, inicioTiempo, stateChangeTime);
                            if (millisecondsa != 0) {
                            newCase.CC_Tiempo_Nivel_1__c = millisecondsa  / 60000;
                            }
                    }
                }
            }else {
                continue;
            }
        }

    }

}