public with sharing class CSBD_WS_AVEDisponibilidad {
    
    public class RespuestaAvailabilitiesGestor{
        public Availability[] availabilities;
        public StatusResp statusResponse;
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

    public static Map<String, Object> obtenerDisponibilidadesGestor(Map<String, Object> params) {
        Map<String, Object> respuestaDisponibilidades = new Map<String, Object>();
  
        //Obtener el custom setting de cita gestor
        CSBD_CitaGestorSetting__c setting = CSBD_CitaGestorSetting__c.getInstance();
        if(setting == null){
            respuestaDisponibilidades.put('result', 'KO');
            respuestaDisponibilidades.put('errorMessage', 'No se ha encontrado el custom setting de cita gestor');
            return respuestaDisponibilidades;
        }

        Integer daysFrom = (Integer)params.get('daysFrom');
        Integer daysTo = (Integer)params.get('daysTo');  
        String numperso = (String)params.get('numperso');
        String employeeId = (String)params.get('employeeId');
        String eventType = (String)params.get('eventType');

        Datetime fechaIni = CBK_UtilsDate.nowDT().addDays(daysFrom);
        Datetime fechaFin = fechaIni.addDays(daysTo);  
        String startDate = fechaIni.format('yyyy-MM-dd');
        String endDate = fechaFin.format('yyyy-MM-dd');
        String device = setting.CSBD_Device_AVE__c != null ? setting.CSBD_Device_AVE__c : 'CC';      
        
        if (String.isNotBlank(numperso)) {
            try {
                Decimal numpersoDecimal = Decimal.valueOf(numperso);
                Map<String, String> requestHeaders = new Map<String, String>();
                requestHeaders.put('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(numpersoDecimal));
                
                CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
                integracion.intSetting = 'CSBD_AVE_DisponibilidadCita';
                integracion.method = 'GET';
                integracion.mHeaders = requestHeaders;
                integracion.mQueryParams = new Map<String, String>{
                    'employeeId' => employeeId,
                    'startDate' => startDate,
                    'endDate' => endDate,
                    'device' => device,
                    'eventType' => eventType
                };

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
                HttpResponse response = CBK_HttpServiceIntegration.multiCallHttpService(request, 'CSBD_AVE_DisponibilidadCita', integracion.intSetting);
              
                if(String.isNotBlank(response.getBody()) && response.getStatusCode() == 200){
                    //remplazamos la label "date" de la respuesta del JSON por "dateAvailable" ya que la palabra "date" está reservada
                    String bodyRespuesta = response.getBody().replace('"date"', '"dateAvailable"');
                    RespuestaAvailabilitiesGestor availabilitiesGestor = (RespuestaAvailabilitiesGestor) System.JSON.deserialize(bodyRespuesta, RespuestaAvailabilitiesGestor.class);
                    respuestaDisponibilidades.put('horariosDisponibles', availabilitiesGestor);                    
                    respuestaDisponibilidades.put('result', 'OK');
                }else{
                    respuestaDisponibilidades.put('result', 'KO');
                    respuestaDisponibilidades.put('errorMessage', 'El sistema AVE ha devuelto un status de error');
                }
            } catch (Exception e) {
                CBK_Log.error(e);
                respuestaDisponibilidades.put('result', 'KO');
                respuestaDisponibilidades.put('errorMessage', 'Ha ocurrido un error interno: ' + e.getMessage());
            }
        }
        else{
            respuestaDisponibilidades.put('result', 'KO');
            respuestaDisponibilidades.put('errorMessage', 'No se ha encontrado el número de persona para el cliente');
        }
        
       // CBK_HttpServiceIntegration.registroTrazaIntegracion();
        
        return respuestaDisponibilidades;
    }
   
}