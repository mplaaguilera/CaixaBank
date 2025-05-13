public with sharing class SEG_WS_Contactos_SOE {
        public static Contactos_SOE obtencionListaContactosSOE(String contractId, String caseNumber) {

            Contactos_SOE resultContactosSOE = new Contactos_SOE();
    
            CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
            oTraza.Name = 'SEG_Contactos_SOE';
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_Identificador__c = caseNumber;
            oTraza.CC_FinOK__c = true;
    
            // Custom Setting
            String intSetting = 'SEG_Contactos_SOE';
    
            try {
                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
    
                CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.body = null;
                requestWrp.intSetting = intSetting;
                requestWrp.method = 'GET';
                requestWrp.mHeaders = mHeaders;
                requestWrp.mUriParams = null;
                requestWrp.mQueryParams = null;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);
                request.setEndpoint(request.getEndpoint() + contractId);
                oTraza.CC_MensajeEntrada__c = String.valueOf(request.getEndpoint() + contractId);
                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);
    
                if (response != null && response.getStatusCode() == 200) {
                    oTraza.CC_MensajeSalida__c = response.getBody();

                    //String jsonSimulado = '{"contractId": "9380690014140","soeDate": "2018-04-20","aliasSo": "PAO - Operacion 14140 sucu PRUEBA","borrowerName": "Martín Martinez Fernandez","borrowerId": "35050332B","employeeId": "U0113843","originatorName": "BERTA GUADALUPE EGAÑA FERNANDEZ","segmentCode": "00001","segmentName": "CIB","areaCode": "300","areaName": "O.R Internacional","sectorCode": "112","sectorName": "Energía","groupCode": "00902","groupName": "Energía","soeSituationCode": "00300","soeSituationName": "Activa","milestonesMonitoringSituationCode": "00001","milestonesMonitoringSituationName": "","operationCode": "00002","operationCodeName": "","milestonesMonitoringAlias": "Prueba","contactList": [{"email": "contacto1@example.com","name": "Guillem","surname": "Torres","phone": "+34612963435","address": "","notificationB": 0},{"email": "contacto2@example.com","name": "Ana","surname": "Garcia","phone": "+34612345678","address": "Calle Falsa 123","notificationB": 1}]}';

                    Datos_Contacto resultado = (Datos_Contacto)System.JSON.deserialize(response.getBody(), Datos_Contacto.class);
                    resultContactosSOE.responseContactoSOE = resultado;
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = true;
    
                } else {
                    //Traza - Error con la conexión al ws
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = 'Error comunicaciones.';
                    oTraza.CC_DetalleError__c = response.getStatusCode() + ':' + response?.getBody();
                    resultContactosSOE.error = response?.getBody();
                }
            } catch (Exception e) {
                //Traza - Error de Apex
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = e.getMessage();
                resultContactosSOE.error = e.getMessage();
            }
    
            insert oTraza;
    
            return resultContactosSOE;
        }
    
        public class Contactos_SOE {
            @AuraEnabled public String error;
            @AuraEnabled public Datos_Contacto responseContactoSOE;
        }
    
        public class Datos_Contacto{
            @AuraEnabled public String contractId; // '9380690014140'
            @AuraEnabled public String soeDate; // '2018-04-20'
            @AuraEnabled public String aliasSo; // 'PAO - Operacion 14140 sucu PRUEBA'
            @AuraEnabled public String borrowerName; // 'Martín Martinez Fernandez'
            @AuraEnabled public String borrowerId; // '35050332B'
            @AuraEnabled public String employeeId; // 'U0113843'
            @AuraEnabled public String originatorName; // 'BERTA GUADALUPE EGAÑA FERNANDEZ'
            @AuraEnabled public String segmentCode; // '00001'
            @AuraEnabled public String segmentName; // 'CIB'
            @AuraEnabled public String areaCode; // '300'
            @AuraEnabled public String areaName; // 'O.R Internacional'
            @AuraEnabled public String sectorCode; // '112'
            @AuraEnabled public String sectorName; // 'Energía'
            @AuraEnabled public String groupCode; // '00902'
            @AuraEnabled public String groupName; // 'Energía'
            @AuraEnabled public String soeSituationCode; // '00300'
            @AuraEnabled public String soeSituationName; // 'Activa'
            @AuraEnabled public String milestonesMonitoringSituationCode; // '00001'
            @AuraEnabled public String milestonesMonitoringSituationName; // ''
            @AuraEnabled public String operationCode; // '00002'
            @AuraEnabled public String operationCodeName; // ''
            @AuraEnabled public String milestonesMonitoringAlias; // 'Prueba'
            @AuraEnabled public List<Contacto> contactList; // Lista de Contactos
        }
    
        public class Contacto{
            @AuraEnabled public String email; // 'g******or@prueba.es'
            @AuraEnabled public String name; // 'Guillem'
            @AuraEnabled public String surname; // 'Torres'
            @AuraEnabled public String phone; // '+34612963435'
            @AuraEnabled public String address; // ''
            @AuraEnabled public Integer notificationB; // 0
        }
}