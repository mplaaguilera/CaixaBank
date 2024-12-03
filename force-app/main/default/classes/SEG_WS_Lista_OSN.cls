public with sharing class SEG_WS_Lista_OSN {
    public static Lista_OSN obtencionListaOSN(String estadoOSN, String numOSN, String numSOE, String numperso, String caseNumber) {

        Lista_OSN listOSN = new Lista_OSN();
        Comunicacion_OSN datosEnvio = new Comunicacion_OSN();

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'SEG_Lista_OSN';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_Identificador__c = caseNumber;
        oTraza.CC_FinOK__c = true;

        if(numOSN == null && numSOE == null){
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = 'Comunicación no iniciada';
            oTraza.CC_DetalleError__c = 'Alguno de los datos obligatorios no han sido rellenados.';
            listOSN.error = 'No se han rellenado los datos obligatorios';
        } else {
            if(!String.IsBlank(numOSN)){
                //Código especifico para OSN
                String codigoOSN = '934065';
                Integer total = numOSN.length() + codigoOSN.length();
                
                for(Integer i = 0 ; i < 13 - total ; i++){
                    codigoOSN += '0';
                }
                datosEnvio.contractId = codigoOSN + numOSN; 
            }

            if(!String.IsBlank(numSOE)){
                //Código especifico para SOE
                String codigoSOE = '938069';
                Integer total = numSOE.length() + codigoSOE.length();
                
                for(Integer i = 0 ; i < 13 - total ; i++){
                    codigoSOE += '0';
                }
                datosEnvio.contractSoeId = codigoSOE + numSOE; 
            }
            if(!String.IsBlank(estadoOSN) && estadoOSN != 'estadoVacio'){ datosEnvio.operationStatus = estadoOSN; }
            if(!String.IsBlank(numperso)){ datosEnvio.accreditedNumper = numperso; }

            String jsonToOSN = JSON.serialize(datosEnvio);
            oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToOSN);

            // Custom Setting
            String intSetting = 'SEG_LST_OSN';

            try {
                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(jsonToOSN, intSetting, 'POST', mHeaders);
                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);

                if (response != null && response.getStatusCode() == 200) {
                    oTraza.CC_MensajeSalida__c = response.getBody();
                    SyndicatedResponse resultadoOSN = (SyndicatedResponse)System.JSON.deserialize(response.getBody(), SyndicatedResponse.class);
                    listOSN.responseOSN = resultadoOSN;

                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = true;
                } else {
                    //Traza - Error con la conexión al ws
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = 'Error comunicaciones.';
                    oTraza.CC_DetalleError__c = response.getStatusCode() + ':' + response.getBody();
                    listOSN.error = response.getBody();
                }
            } catch (Exception e) {
                //Traza - Error de Apex
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = e.getMessage();
                listOSN.error = e.getMessage();
            }
        }

        insert oTraza;

        return listOSN;
    }

    public class Lista_OSN {
        @AuraEnabled public String error;
        @AuraEnabled public SyndicatedResponse responseOSN;
    }

    public class Comunicacion_OSN { //aquí se ponen los campos con los nombres que pidan ellos
        String contractId; // 9340651234567
        String contractSoeId; // 9999999999999
        String operationStatus; // CURRENT - CANCELLED - UNPAID
        String accreditedNumper; // 9999999999999
    }

    public class SyndicatedResponse {
        @AuraEnabled public Boolean hasMore;
        @AuraEnabled public List<SyndicatedItem> syndicatedList;
    }

    public class SyndicatedItem {
        @AuraEnabled public String syndicatedId; // Número de OSN - syndicatedId
        @AuraEnabled public String operationType; // Tipo operación
        @AuraEnabled public Decimal amountGranted; // Concedido - amountGranted
        @AuraEnabled public String ccy;
        @AuraEnabled public String dateFrom; // Fecha constitución
        @AuraEnabled public String status; // Estado OSN
        @AuraEnabled public String accreditedName; // Nombre acreditada
        @AuraEnabled public String contractSoeId; // Número SOE
        @AuraEnabled public String contractSoeArea; // Area
        @AuraEnabled public String originatorName; // Originador
    }
}