@IsTest
public class CSBD_HttpMockWSCita implements HttpCalloutMock {
    private Integer statusCode;
    private String status;
    private Boolean multipleCallout;
    private String tipoIntegracion;
    private String tipoRespuesta;
    
    public CSBD_HttpMockWSCita(Map<String, Object> params) {
        this.statusCode = (Integer) params.get('statusCode');
        this.status = (String) params.get('status');
        this.tipoIntegracion = (String) params.get('tipoIntegracion');
        this.tipoRespuesta = (String) params.get('tipoRespuesta');
        //this.body = getResponseBody((String) params.get('tipoIntegracion'), (String) params.get('tipoRespuesta'));
        this.multipleCallout = (Boolean) params.get('multipleCallout');
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setStatus(status);
        System.debug('multipleCallout: ' + multipleCallout);
        System.debug('tipoIntegracion: ' + tipoIntegracion);
        System.debug('tipoRespuesta: ' + tipoRespuesta);
        System.debug('statusCode: ' + statusCode);
        System.debug('status: ' + status);
        System.debug('endpoint: ' + req.getEndpoint());
    
        if(multipleCallout){
            String endpoint = req.getEndpoint();
            if(endpoint.contains('caracteriza')){
                res.setBody(getResponseAVECaracterizaOK());
            }else{
                res.setBody(getResponseAVEDisponibilidadOK());
            }
        }else{
            res.setBody(getResponseBody(tipoIntegracion, tipoRespuesta));
        }
        return res;            
    }

    private String getResponseBody(String tipoIntegracion, String tipoRespuesta) {
        switch on tipoIntegracion {
            when 'CSBD_AVE_Disponibilidad' {
                return tipoRespuesta == 'OK' ? getResponseAVEDisponibilidadOK() : getResponseAVEDisponibilidadKO();
            }
            when 'CSBD_AVE_AltaCita' {
                return tipoRespuesta == 'OK' ? getResponseAVEAltaCitaOK() : getResponseAVEAltaCitaKO();
            }
            when 'CSBD_AVE_Caracteriza' {
                return tipoRespuesta == 'OK' ? getResponseAVECaracterizaOK() : getResponseAVECaracterizaKO();
            }
            when 'CSBD_Lego_Disponibilidad' {
                return tipoRespuesta == 'OK' ? getResponseLegoDisponibilidadOK() : getResponseLegoDisponibilidadKO();
            }
            when 'CSBD_Lego_AltaCita' { 
                return tipoRespuesta == 'OK' ? getResponseLegoAltaCitaOK() : getResponseLegoAltaCitaKO();
            }
            when else {
                return '{"result":"KO","mensaje":"Tipo de integración no válido"}';
            }
        }
    }
    

    private String getResponseAVECaracterizaOK() {
        return '{' +
            '"empleado1":57434,' +
            '"gestorOEAP1":"E",' +
            '"oficina1":2371,' +
            '"clienteDigital":"N",' +
            '"muroAbierto":"N",' +
            '"resultado":"OK",' +
            '"pilotoAppNow1":"S",' +
            '"indSexo1":"H"' +
        '}';
    }

    private String getResponseAVECaracterizaKO() {
        return '{"clienteDigital":"N","muroAbierto":"N","resultado":"OK"}';
    }

    private String getResponseAVEDisponibilidadOK() {
        return '{' +            
            '"StatusResponse": { "statusMessage": "OK", "statusCode": "200" },' +
            '"availabilities": [' +
                '{' +
                    '"telework": "N",' +
                    '"surname": "GUARC",' +
                    '"startTime": "09:00",' +
                    '"secondSurname": "PALLARES",' +
                    '"name": "ROBERTO PEDRO",' +
                    '"isManager": "true",' +
                    '"isBackup": "false",' +
                    '"endTime": "14:00",' +
                    '"employeeId": "29197",' +
                    '"dateAvailable": "2025-05-21",' +
                    '"branchName": "STORE SARDENYA",' +
                    '"branchId": "3022"' +
                '},' +
                '{' +
                    '"telework": "N",' +
                    '"surname": "GUARC",' +
                    '"startTime": "15:30",' +
                    '"secondSurname": "PALLARES",' +
                    '"name": "ROBERTO PEDRO",' +
                    '"isManager": "true",' +
                    '"isBackup": "false",' +
                    '"endTime": "18:00",' +
                    '"employeeId": "29197",' +
                    '"dateAvailable": "2025-05-21",' +
                    '"branchName": "STORE SARDENYA",' +
                    '"branchId": "3022"' +
                '}' +
            ']' +           
        '}';
    }

    private String getResponseAVEDisponibilidadKO() {
        return '{"result":"KO","mensaje":"Tipo de integración no válido"}';
    }

    private String getResponseAVEAltaCitaOK() {
        return '{' +
            '"resultat": "OK",' +
            '"empleCont": 57434,' +
            '"numCont": 500000067,' +
            '"txtError": "OK"' +
        '}';
    }

    private String getResponseAVEAltaCitaKO() {
        return '{' +
            '"resultat": "KO",' +
            '"txtError": "Error al agendar la cita"' +
        '}';
    }

    private String getResponseLegoDisponibilidadOK() {
        return 
        '[' +
            '{' +
                '"Slots":[' +
                    '{' +
                        '"starTimeSlot":"09:00",' +
                        '"endTimeSlot":"09:30",' +
                        '"numberPlaces":2,' +
                        '"numberPlacesAvailable":1,' +
                        '"isAvailable":true' +
                    '},' +
                    '{' +
                        '"starTimeSlot":"09:30",' +
                        '"endTimeSlot":"10:00",' +
                        '"numberPlaces":2,' +
                        '"numberPlacesAvailable":2,' +
                        '"isAvailable":true' +
                    '}' +                    
                '],' +
                '"currentWaitTime":0,' +
                '"slotDate":"2025-06-02"' +
            '}' +
        ']';
    }

    private String getResponseLegoDisponibilidadKO() {
        return '{"result":"KO","mensaje":"Tipo de integración no válido"}';
    }


    private String getResponseLegoAltaCitaOK() {
        return '{"appointmentId":"0000000500003050"}';
    }

    private String getResponseLegoAltaCitaKO() {
        return '{"detail":"altaReserva - Ya existe una reserva anterior del cliente en el centro ","stackTrace":[],"type":"customerRelationshipManagement/invalid-appointment","status":400}';
    }
}