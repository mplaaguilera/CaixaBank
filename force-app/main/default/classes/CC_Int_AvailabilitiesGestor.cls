public with sharing class CC_Int_AvailabilitiesGestor {
    public class RespuestaAvailabilitiesGestor{
        public Availability[] availabilities;
        public StatusResp StatusResponse;

        public RespuestaAvailabilitiesGestor() {
            this.availabilities = new List<Availability>();
        }
    }
    public class Availability {
        public String employeeId;	
        public String dateAvailable; //DISTINTO
        public String startTime;
        public String endTime;
        public String branchId;
        public String isManager;
        public String isBackup;
        public String name;
        public String surname;
        public String secondSurname;
        public String branchName;
        public String telework;
    }
    public class StatusResp {
        public String statusCode;
        public String statusMessage;
    }

    public static Map<String, Object> obtenerDisponibilidadesGestor(String recordId, String employeeId, String gestorElegidoId, String eventType) {
        Map<String, Object> respuestaDisponibilidades = new Map<String, Object>();
        Set<String> employeeIdGestorBackup = new Set<String>();

        Map<Date, Set<Time>> fechasHorasMap = new Map<Date, Set<Time>>();
        Datetime fechaIni = Datetime.now();
        Datetime fechaFin = Datetime.now().addDays(30);
        String startDate = fechaIni.format('yyyy-MM-dd');
        String endDate = fechaFin.format('yyyy-MM-dd');
        String device = 'CC';
        Integer duracionEventType = 30;
        String numperso;
        Decimal numpersoDecimal;
        String endpoint;
        String statusCode;
        String entrada;
        String error;
        String salida;
        Boolean finOk = false;
        
        Case[] caso = [SELECT Account.CC_Numperso__c FROM Case WHERE Id =: recordId];
        if(!caso.isEmpty()) {
            numperso = caso[0].Account.CC_Numperso__c;
            numpersoDecimal = Decimal.valueOf(numperso);
        
            CC_InterfaceSettings__mdt configAvailabilitieslMdt = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_AvailabilitiesGestor');
            
            String endpointParametrizado = configAvailabilitieslMdt.CC_EndPoint__c;
            endpointParametrizado += '?employeeId=' + employeeId;
            endpointParametrizado += '&startDate=' + startDate;
            endpointParametrizado += '&endDate=' + endDate;
            endpointParametrizado += '&device=' + device;
            endpointParametrizado += '&eventType=' + eventType; 

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointParametrizado);
            req.setClientCertificateName(configAvailabilitieslMdt.CC_Certificado__c);
            req.setMethod(configAvailabilitieslMdt.CC_TipoPeticion__c);
            req.setHeader('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(numpersoDecimal));
            endpoint = String.valueOf(req.getEndpoint()).right(94);
            entrada = 'CC_Numperso__c : ' + numpersoDecimal + ' Hexa: ' + CC_MetodosUtiles.decimalToHex(numpersoDecimal);

            Http http = new Http();
            HTTPResponse respuesta = http.send(req);
            statusCode = String.valueOf(respuesta.getStatusCode());
            salida = String.valueOf(respuesta.getBody());
            if(String.isNotBlank(respuesta.getBody()) && respuesta.getStatusCode() == 200){
                //remplazamos la label "date" de la respuesta del JSON por "dateAvailable" ya que la palabra "date" está reservada
                String bodyRespuesta = respuesta.getBody().replace('"date"', '"dateAvailable"');
                RespuestaAvailabilitiesGestor availabilitiesGestor = (RespuestaAvailabilitiesGestor) System.JSON.deserialize(bodyRespuesta, RespuestaAvailabilitiesGestor.class);
                
                Map<String, Set<String>> fechasHorasStringMap = new Map<String, Set<String>>();

                for(Availability disponibilidad: availabilitiesGestor.availabilities) {
                    if(disponibilidad.employeeId == gestorElegidoId) {
                        if(!fechasHorasStringMap.containsKey(disponibilidad.dateAvailable)) {
                            fechasHorasStringMap.put(disponibilidad.dateAvailable, new Set<String>());
                        }
                        String horaIniFin = disponibilidad.startTime + ':' + disponibilidad.endTime;
                        Set<String> horasSet = fechasHorasStringMap.get(disponibilidad.dateAvailable);
                        horasSet.add(horaIniFin);
                    }
                    if(disponibilidad.employeeId != employeeId) {
                        employeeIdGestorBackup.add(disponibilidad.employeeId);
                    }
                }
                for(String fechaDispo: fechasHorasStringMap.keySet()) {
                    Date fechaCita = Date.valueOf(fechaDispo);

                    if(!fechasHorasMap.containsKey(fechaCita)) {
                        fechasHorasMap.put(fechaCita, new Set<Time>());
                    }
                    Set<Time> horasTramoSet = fechasHorasMap.get(fechaCita);
                    
                    Set<String> horasString = fechasHorasStringMap.get(fechaDispo);
                    for(String horaDispo: horasString) {
                        String[] timeSplit = horaDispo.split(':');
                        Time timeIni = Time.newInstance(Integer.valueOf(timeSplit[0]),
                                                        Integer.valueOf(timeSplit[1]),
                                                        0,                            
                                                        0);    
                        Time timeFin = Time.newInstance(Integer.valueOf(timeSplit[2]),
                                                        Integer.valueOf(timeSplit[3]),
                                                        0,                            
                                                        0);  
                        while(timeIni < timeFin){
                            horasTramoSet.add(timeIni);
                            timeIni = timeIni.addMinutes(duracionEventType);
                        }
                    }
                }
                finOk = true;
            }
            else{
                error = 'El proceso de consulta de disponibilidades ha funcionado pero no se ha obtenido una respuesta válida.';
                finOk = false;
                throw new DefaultException('El proceso de consulta de disponibilidades ha funcionado pero no se ha obtenido una respuesta válida. Por favor, vuelva a intentarlo o póngase en contacto con su administrador. ');
            }
            System.debug('CC_Int_AvailabilitiesGestor - Respuesta status code: '+respuesta.getStatusCode());
            System.debug('CC_Int_AvailabilitiesGestor - Respuesta body: '+respuesta.getBody());
        }
        respuestaDisponibilidades.put('fechasHorasMap', fechasHorasMap);
        respuestaDisponibilidades.put('employeeIdGestorBackup', employeeIdGestorBackup);

        CC_TrazaInt__c traza = CC_TrazaInt.generarTraza('CC_Int_AvailabilitiesGestor', endpoint, statusCode, entrada, error, salida, finOK);
        if(traza != null){
            insert traza;
        }
        system.debug('VMLS mapa respuestaDisponibilidades ' + respuestaDisponibilidades);
        system.debug('VMLS mapa respuestaDisponibilidades ' + respuestaDisponibilidades.tostring());
        return respuestaDisponibilidades;
    }
    public static List<OT_Picklist.Item> obtenerGestoresBackup(String recordId, String employeeId, String gestorElegidoId, String eventType) {
        
        List<OT_Picklist.Item> gestoresBackup = new List<OT_Picklist.Item>();
        Map<String, Object> respuestaDisponibilidades = obtenerDisponibilidadesGestor(recordId, employeeId, gestorElegidoId, eventType);
        Set<String> employeeIdGestorBackup = (Set<String>)respuestaDisponibilidades.get('employeeIdGestorBackup');
        Set<String> matriculasGestorBackup = new Set<String>();

        for(String employeeIdBackup: employeeIdGestorBackup) {
            String matriculaGestor = 'U01'+employeeIdBackup;
            matriculasGestorBackup.add(matriculaGestor);
        }
        
        User[] gestoresBackupCliente = [SELECT Id, Name, AV_ExternalID__c FROM User WHERE AV_ExternalID__c =: matriculasGestorBackup];

        for(User gestorBackup: gestoresBackupCliente) {
            String employeeIdGestor = gestorBackup.AV_ExternalID__c.substringAfter('U01');
            String nombreGestor = gestorBackup.Name;
            OT_Picklist.Item gestorItem = new OT_Picklist.Item(employeeIdGestor,nombreGestor);
            gestoresBackup.add(gestorItem);
        }
        return gestoresBackup;
    }

    public static List<OT_Picklist.Item> obtenerFechasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType) {
        
        Map<String, Object> respuestaDisponibilidades = obtenerDisponibilidadesGestor(recordId, employeeId, gestorElegidoId, eventType);
        Map<Date, Set<Time>> fechasHorasMap = (Map<Date, Set<Time>>)respuestaDisponibilidades.get('fechasHorasMap');
        
        List<OT_Picklist.Item> fechasDisponibilidadGestor = new List<OT_Picklist.Item>();

        for(Date fechaDisponibilidad: fechasHorasMap.keySet()){
            String fechaDisponiblidadString = String.valueOf(fechaDisponibilidad);
            Datetime fechaFormatoLecturaDateTime = fechaDisponibilidad;
            String fechaFormatoLecturaString = fechaFormatoLecturaDateTime.format('EEEE, d MMMM y');
            fechaFormatoLecturaString = traducirFechaDisponibilidad(fechaFormatoLecturaString);

            OT_Picklist.Item fechaDispoItem = new OT_Picklist.Item(fechaDisponiblidadString,fechaFormatoLecturaString);
            fechasDisponibilidadGestor.add(fechaDispoItem);
        }
        return fechasDisponibilidadGestor;
    }

    public static List<OT_Picklist.Item> obtenerHorasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType, String fechaElegida) {
        Map<String, Object> respuestaDisponibilidades = obtenerDisponibilidadesGestor(recordId, employeeId, gestorElegidoId, eventType);
        Map<Date, Set<Time>> fechasHorasMap = (Map<Date, Set<Time>>)respuestaDisponibilidades.get('fechasHorasMap');

        List<OT_Picklist.Item> horasDisponibilidadGestor = new List<OT_Picklist.Item>();
        Set<Time> horasSet = new Set<Time>();
        system.debug('VMLS fechasHorasMap ' + fechasHorasMap);
        system.debug('VMLS fechasHorasMap ' + fechasHorasMap.tostring());

        for(Date fechaDisponibilidad: fechasHorasMap.keySet()){
            Date fechaDisponibilidadElegida = Date.valueOf(fechaElegida);
            if(fechasHorasMap.containsKey(fechaDisponibilidadElegida) && fechaDisponibilidad == fechaDisponibilidadElegida){
                horasSet = fechasHorasMap.get(fechaDisponibilidadElegida);
                for(Time horaDisponible: horasSet) {
                    Datetime fechaFormatoLecturaDateTime = DateTime.newInstance(fechaDisponibilidadElegida, horaDisponible);
                    String horaFormatoLecturaString = fechaFormatoLecturaDateTime.format('HH:mm');

                    OT_Picklist.Item fechaDispoItem = new OT_Picklist.Item(horaFormatoLecturaString,horaFormatoLecturaString);
                    horasDisponibilidadGestor.add(fechaDispoItem);
                }
            }
        }
        return horasDisponibilidadGestor;
    }

    public static String traducirFechaDisponibilidad(String fechaFormatoLecturaString) {
        Map<String, String> traduccionesCastellano = new Map<String, String>{
            'Monday' => 'Lunes', 'Tuesday' => 'Martes', 'Wednesday' => 'Miércoles', 'Thursday' => 'Jueves',
            'Friday' => 'Viernes', 'Saturday' => 'Sábado', 'Sunday' => 'Domingo',
            'January' => 'enero', 'February' => 'febrero', 'March' => 'marzo', 'Abril' => 'abril',
            'Mayo' => 'mayo', 'June' => 'junio', 'July' => 'julio', 'August' => 'agosto',
            'September' => 'Septiembre', 'October' => 'octubre', 'November' => 'noviembre', 'December' => 'diciembre' 
        };
        for(String traduccion: traduccionesCastellano.keySet()) {
            fechaFormatoLecturaString = fechaFormatoLecturaString.replace(traduccion, traduccionesCastellano.get(traduccion));
        }
        return fechaFormatoLecturaString;
    }
    private class DefaultException extends Exception {}
}