public with sharing class CSBD_CitaGestorController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> obtenerConfiguraciones(Boolean esPool) {

        CSBD_CitaGestorSetting__c setting = CSBD_CitaGestorSetting__c.getInstance();
        System.debug('setting: ' + setting);
        if (setting == null) {
            throw new AuraHandledException('No se ha encontrado el custom setting de cita gestor');
        }

        System.debug('esPool: ' + esPool);


        String tipoCitaDefault = '43';
        Map<String, Object> tiposCita = new Map<String, Object>();

        String tiposCitaJson = esPool ? setting.CSBD_TipoCita_Lego__c : setting.CSBD_TiposCita_AVE__c;
        if (String.isNotBlank(tiposCitaJson)) {
            tiposCita = (Map<String, Object>)JSON.deserializeUntyped(tiposCitaJson);

            // Obtener el primer key del mapa de tiposCita
            if (!tiposCita.isEmpty()) {
                tipoCitaDefault = tiposCita.keySet().iterator().next();
            }
        }
        //Oficinas que no admiten cita presencial
        String oficinasNoPresenciales = setting.CSBD_OficinasNoPresenciales_AVE__c;

        return new Map<String, Object>{'tipoCitaDefault' => tipoCitaDefault, 'tiposCita' => tiposCita, 'oficinasNoPresenciales' => oficinasNoPresenciales};
    }

    @AuraEnabled
    public static Map<String, Object> obtenerDisponibilidad(String recordId, Boolean esPool, String tipoCitaDefault) {
        List<Opportunity> opp = [
            SELECT
                Account.AV_EAPGestor__r.AV_Pool__c,
                Account.AV_EAPGestor__r.CC_Matricula__c,
                Account.AV_EAPGestor__r.Account.CC_Numero_Oficina__c,
                Account.AV_OfficeManager__r.CC_Numero_Oficina__c,
                Account.AV_NumPerso__c
            FROM Opportunity
            WHERE Id = :recordId
            AND AccountId != null
            AND Account.AV_EAPGestor__c != null
        ];

        Map<String, Object> respuesta = new Map<String, Object>();

        if(opp.isEmpty()){
            respuesta.put('result', 'KO');
            respuesta.put('errorMessage', 'La Oportunidad tiene que estar asociada a un Account con un Gestor asignado');
            return respuesta;
        }

       /* String matriculaGestor = opp[0].Account.AV_EAPGestor__r.CC_Matricula__c;
        if (String.isBlank(matriculaGestor)) {
			throw new AuraHandledException('El gestor de la cuenta no tiene especificada la matrícula');
		}
        //else
        if (!matriculaGestor.startsWith('U01')) {
            matriculaGestor = 'U01' + matriculaGestor;
        }
        Boolean esPool = CSBD_MetodosComunes.comprobarGestor(matriculaGestor);*/


        Map<String, Object> params = new Map<String, Object>();

        if (esPool) {
            //Cita LEGO
            String oficina = CSBD_MetodosComunes.obtenerCentroPool(opp[0]);

            if(String.isBlank(oficina)){
                //throw new AuraHandledException('No se ha encontrado la oficina para el gestor');
                respuesta.put('result', 'KO');
                respuesta.put('errorMessage', 'No se ha encontrado la oficina del cliente');
                return respuesta;
            }

            Map<String, Object> disponibilidad = obtenerDisponibilidadLEGO(oficina, null);
            respuesta.putAll(disponibilidad);
            respuesta.put('oficina', oficina);
        } else {
            //Cita AVE
            //Caracterizar cliente para determinar el gestor
            if(String.isBlank(opp[0].Account.AV_NumPerso__c)){
                respuesta.put('result', 'KO');
                respuesta.put('errorMessage', 'No se ha encontrado el Numper del cliente');
                return respuesta;
            }
            params.put('numperso', opp[0].Account.AV_NumPerso__c);
            //params.put('numperso', '13550');
            Map<String, Object> respuestaCaracterizaCliente = CSBD_WS_AVECaracterizaCliente.caracterizaCliente(params);

            if(respuestaCaracterizaCliente.get('result') == 'OK'){
                CSBD_WS_AVECaracterizaCliente.RespuestaClienteDigital datosCliente = (CSBD_WS_AVECaracterizaCliente.RespuestaClienteDigital) respuestaCaracterizaCliente.get('datosCliente');
                String matriculaGestorAVE = datosCliente.empleado1;
                if(String.isBlank(matriculaGestorAVE)){
                    respuesta.put('result', 'KO');
                    respuesta.put('errorMessage', 'La integracion AVE de caracterizar cliente no ha devuelto gestor para el cliente');
                    return respuesta;
                }

                Map<String, Object> disponibilidad = obtenerDisponibilidadAVE(matriculaGestorAVE, tipoCitaDefault, opp[0].Account.AV_NumPerso__c);
                respuesta.putAll(disponibilidad);
                respuesta.put('matricula', 'U01' + matriculaGestorAVE.leftPad(5, '0'));
            } else {
                respuesta.put('result', 'KO');
                respuesta.put('errorMessage', respuestaCaracterizaCliente.get('errorMessage'));
            }

            //CBK_HttpServiceIntegration.registroTrazaIntegracion();
        }

        return respuesta;
    }

    @AuraEnabled
    public static Map<String, Object> obtenerDisponibilidadLEGO(String oficina, String fecha){

        Map<String, Object> respuesta = new Map<String, Object>();
        Map<String, Object> params = new Map<String, Object>();

        //Pasar la fecha actual o la que se determine por la UI
        if(String.isBlank(fecha)){
            fecha = CBK_UtilsDate.nowDT().format('yyyy-MM-dd');
        }
        params.put('numOficina', oficina);
        params.put('fecha', fecha);

        Map<String, Object> respuestaLegoDisponibilidad = CSBD_WS_LegoDisponibilidad.obtenerDisponibilidadesOficina(params);
        if(respuestaLegoDisponibilidad.get('result') == 'OK'){
            respuesta.put('result', 'OK');
            respuesta.put('disponibilidadPorFecha', transformarRespuestaDisponibilidad(respuestaLegoDisponibilidad, true));
        } else {
            respuesta.put('result', 'KO');
            respuesta.put('errorMessage', respuestaLegoDisponibilidad.get('errorMessage'));
        }

        return respuesta;
    }

    @AuraEnabled
    public static Map<String, Object> obtenerDisponibilidadAVE(String matriculaGestorAVE, String tipoCita, String numPerso){

        Map<String, Object> respuesta = new Map<String, Object>();
        Map<String, Object> params = new Map<String, Object>();

        CSBD_CitaGestorSetting__c setting = CSBD_CitaGestorSetting__c.getInstance();
        if(setting == null){
            throw new AuraHandledException('No se ha encontrado el custom setting de cita gestor');
        }

        // Quitar el prefijo U01 si existe
        if(String.isNotBlank(matriculaGestorAVE) && matriculaGestorAVE.startsWith('U01')){
            matriculaGestorAVE = matriculaGestorAVE.substring(3);
        }

        //Obtener disponibilidad
        params.put('daysFrom',  setting.CSBD_DiasDesde_AVE__c != null ? Integer.valueOf(setting.CSBD_DiasDesde_AVE__c) : 0);
        params.put('daysTo', setting.CSBD_DiasHasta_AVE__c != null ? Integer.valueOf(setting.CSBD_DiasHasta_AVE__c) : 30);
        params.put('employeeId', matriculaGestorAVE);
        params.put('eventType', tipoCita);
        params.put('numperso', numPerso);

        Map<String, Object> respuestaAveDisponibilidad = CSBD_WS_AVEDisponibilidad.obtenerDisponibilidadesGestor(params);
        if(respuestaAveDisponibilidad.get('result') == 'OK'){
            respuesta.put('result', 'OK');
            respuesta.put('disponibilidadPorFecha', transformarRespuestaDisponibilidad(respuestaAveDisponibilidad, false));
            respuesta.putAll(procesarInformacionGestor(respuestaAveDisponibilidad));
        } else {
            respuesta.put('result', 'KO');
            respuesta.put('errorMessage', respuestaAveDisponibilidad.get('errorMessage'));
        }

        CBK_HttpServiceIntegration.registroTrazaIntegracion();
        return respuesta;
    }

    @AuraEnabled
    public static Map<String, Object> altaCitaGestorLEGO(Map<String, Object> params){
        Map<String, Object> respuesta = CSBD_WS_LegoAltaCita.altaCita(params);

        if(respuesta.get('result') == 'OK'){
            //Crear Tarea
            CSBD_Activity.crearActividad(
                (String)params.get('recordId'),
                'Cita en la oficina',
                'Completed',
                'Cita en la oficina ' + params.get('numOficina'),
                'Se ha creado la cita en la oficina ' + params.get('numOficina') + ' con los siguientes datos: ' + '\n' +
                    'Fecha: ' + params.get('fechaSeleccionada') + '\n' +
                    'Hora: ' + params.get('franjaSeleccionada') + '\n' +
                    'Asunto: ' + params.get('asunto') + '\n' +
                    'Tipo de cita: ' + params.get('tipoCita')
            );
        }
        return respuesta;
    }

    @AuraEnabled
    public static Map<String, Object> altaCitaGestorAVE(Map<String, Object> params){

        Map<String, Object> respuesta = CSBD_WS_AVEAltaCita.altaCitaGestor(params);
        if(respuesta.get('result') == 'OK'){
            //Crear Tarea
            String gestorMatricula = params.get('gestorMatricula') != null ? (String)params.get('gestorMatricula') : '';
            CSBD_Activity.crearActividad(
                (String)params.get('recordId'),
                'Cita con el gestor',
                'Completed',
                'Cita con gestor AVE',
                'Se ha creado la cita con el gestor ' + gestorMatricula + ' con los siguientes datos: ' + '\n' +
                    'Fecha: ' + params.get('fecContacto') + '\n' +
                    'Hora: ' + params.get('horaIni') + '\n' +
                    'Asunto: ' + params.get('asunto') + '\n' +
                    'Tipo de cita: ' + params.get('medio') + '\n' +
                    'Oficina: ' + params.get('centroEx')
            );
        }
        return respuesta;
    }

    private static Map<String, List<Map<String, Object>>> transformarRespuestaDisponibilidad(Map<String, Object> respuesta, Boolean esPool) {
        Map<String, List<Map<String, Object>>> disponibilidadPorFecha = new Map<String, List<Map<String, Object>>>();

        if(esPool) {
            // Transformar respuesta LEGO
            List<CSBD_WS_LegoDisponibilidad.DisponibilidadWrapper> horariosDisponibles =
                (List<CSBD_WS_LegoDisponibilidad.DisponibilidadWrapper>) respuesta.get('horariosDisponibles');

            for(CSBD_WS_LegoDisponibilidad.DisponibilidadWrapper disponibilidad : horariosDisponibles) {
                List<Map<String, Object>> slotsPorFecha = new List<Map<String, Object>>();

                for(CSBD_WS_LegoDisponibilidad.SlotWrapper slot : disponibilidad.slots) {
                    if(slot.isAvailable) {
                        Map<String, Object> slotInfo = new Map<String, Object>{
                            'horaInicio' => slot.starTimeSlot,
                            'horaFin' => slot.endTimeSlot,
                            'plazasDisponibles' => slot.numberPlacesAvailable,
                            'plazasTotales' => slot.numberPlaces
                        };
                        slotsPorFecha.add(slotInfo);
                    }
                }

                if(!slotsPorFecha.isEmpty()) {
                    disponibilidadPorFecha.put(disponibilidad.slotDate, slotsPorFecha);
                }
            }
        } else {
            // Transformar respuesta AVE
            CSBD_WS_AVEDisponibilidad.RespuestaAvailabilitiesGestor availabilitiesGestor =
                (CSBD_WS_AVEDisponibilidad.RespuestaAvailabilitiesGestor) respuesta.get('horariosDisponibles');

            for(CSBD_WS_AVEDisponibilidad.Availability disponibilidad : availabilitiesGestor.availabilities) {
                // Si la fecha ya existe en el mapa, obtenemos la lista existente, si no, creamos una nueva
                List<Map<String, Object>> slotsPorFecha = disponibilidadPorFecha.containsKey(disponibilidad.dateAvailable)
                    ? disponibilidadPorFecha.get(disponibilidad.dateAvailable)
                    : new List<Map<String, Object>>();

                // Convertir las horas de inicio y fin a minutos para facilitar el cálculo
                Integer horaInicioMinutos = convertirHoraAMinutos(disponibilidad.startTime);
                Integer horaFinMinutos = convertirHoraAMinutos(disponibilidad.endTime);

                // Generar slots de 30 minutos
                for(Integer tiempo = horaInicioMinutos; tiempo < horaFinMinutos; tiempo += 30) {
                    Map<String, Object> slotInfo = new Map<String, Object>{
                        'horaInicio' => convertirMinutosAHora(tiempo),
                        'horaFin' => convertirMinutosAHora(tiempo + 30),
                        'plazasDisponibles' => 1,
                        'plazasTotales' => 1
                    };
                    slotsPorFecha.add(slotInfo);
                }

                // Actualizamos el mapa con la lista actualizada de slots
                disponibilidadPorFecha.put(disponibilidad.dateAvailable, slotsPorFecha);
            }
        }

        return disponibilidadPorFecha;
    }

    private static Integer convertirHoraAMinutos(String hora) {
        List<String> partes = hora.split(':');
        return Integer.valueOf(partes[0]) * 60 + Integer.valueOf(partes[1]);
    }

    private static String convertirMinutosAHora(Integer minutos) {
        Integer horas = minutos / 60;
        Integer minutosRestantes = minutos - (horas * 60);
        return String.format('{0}:{1}', new List<String>{
            String.valueOf(horas).leftPad(2, '0'),
            String.valueOf(minutosRestantes).leftPad(2, '0')
        });
    }

    private static Map<String, Object> procesarInformacionGestor(Map<String, Object> respuestaAVEDisponibilidad) {
        String name = '';
        String lastname = '';
        String gestorAVEOficina = '';
        Map<String, Object> result = new Map<String, Object>();


        CSBD_WS_AVEDisponibilidad.RespuestaAvailabilitiesGestor availabilitiesGestor =
            (CSBD_WS_AVEDisponibilidad.RespuestaAvailabilitiesGestor) respuestaAVEDisponibilidad.get('horariosDisponibles');
        if (!availabilitiesGestor.availabilities.isEmpty()) {
            CSBD_WS_AVEDisponibilidad.Availability primerGestor = availabilitiesGestor.availabilities[0];
            name = primerGestor.name != null ? primerGestor.name : '';
            String surname = primerGestor.surname != null ? primerGestor.surname : '';
            String secondSurname = primerGestor.secondSurname != null ? primerGestor.secondSurname : '';
            lastname = String.isNotBlank(secondSurname) ? surname + ' ' + secondSurname : surname;
            gestorAVEOficina = primerGestor.branchId != null ? primerGestor.branchId : '';
        }

        result.put('name', name);
        result.put('lastname', lastname);
        result.put('gestorAVEOficina', gestorAVEOficina);
        //result.put('gestorAVEOficina', '3223');
        return result;
    }

}