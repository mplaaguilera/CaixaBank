public with sharing class SEG_WS_Lista_SOE {
    public static Lista_SOE obtencionListaSOE(String nombreAcreditada, String nif, String numeroSOE) {

        Lista_SOE listaSOE = new Lista_SOE();
        Comunicacion_SOE datosEnvio = new Comunicacion_SOE();

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'SEG_Lista_SOE';
        oTraza.CC_FechaInicio__c = datetime.now();
       // oTraza.CC_Identificador__c = caseNumber;
        oTraza.CC_FinOK__c = true;

        if(nombreAcreditada == null && nif == null && numeroSOE == null){
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = 'Comunicación no iniciada';
            oTraza.CC_DetalleError__c = 'Alguno de los datos obligatorios no han sido rellenados.';
            listaSOE.error = 'No se han rellenado los datos obligatorios';
        } else {
            if(nombreAcreditada != null){
                datosEnvio.borrowerName = nombreAcreditada;
            }
            if(!String.IsBlank(nif)){
                datosEnvio.borrowerId = nif;
            }
            
            if(!String.IsBlank(numeroSOE)){
                //Código especifico para SOE
                String codigoSOE = '938069';
                Integer total = numeroSOE.length() + codigoSOE.length();
                
                for(Integer i = 0 ; i < 13 - total ; i++){
                    codigoSOE += '0';
                }
                datosEnvio.contractId = codigoSOE + numeroSOE; 
            }
            String jsonSOE = JSON.serialize(datosEnvio);
            oTraza.CC_MensajeEntrada__c = String.valueOf(jsonSOE);

            // Custom Setting
            String intSetting = 'SEG_LST_SOE';

            try {
                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                
                CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.body = jsonSOE;
                requestWrp.intSetting = intSetting;
                requestWrp.method = 'GET';
                requestWrp.mHeaders = mHeaders;
                requestWrp.mUriParams = null;
                requestWrp.mQueryParams = null;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);
                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);

                if (response != null && response.getStatusCode() == 200) {
                    oTraza.CC_MensajeSalida__c = response.getBody();
                    //String jsonSimulado = '{"hasMore":true,"datos":[{"contractId":"9380690006454","soeDate":"2025-01-13","aliasSoe":"ELIOR","borrowerName":"ELIOR","borrowerId":"TB3540867","employeeId":"U0144972","originatorName":"YagoGómezPonce","segmentCode":"00001","segmentName":"CIB","areaCode":"100","areaName":"Financ.CorporativayAdquisiciones","sectorCode":"101","sectorName":"Corporativos","groupCode":"00999","groupName":"Noaplica","soeSituationCode":"00900","soeSituationName":"Baja"},{"contractId":"9380690006435","soeDate":"2016-01-13","aliasSoe":"ELIOR","borrowerName":"ELIOR","borrowerId":"TB3540867","employeeId":"U0144972","originatorName":"Test Originator","segmentCode":"00001","segmentName":"CIB","areaCode":"100","areaName":"Financ.CorporativayAdquisiciones","sectorCode":"101","sectorName":"Corporativos","groupCode":"00999","groupName":"Grupo test","soeSituationCode":"00900","soeSituationName":"Alta"}]}';

                    Datos_SOE resultadoSOE = (Datos_SOE)System.JSON.deserialize(response.getBody(), Datos_SOE.class);
                    listaSOE.responseSOE = resultadoSOE;
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = true;
                } else {
                    //Traza - Error con la conexión al ws
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = 'Error comunicaciones.';
                    oTraza.CC_DetalleError__c = response.getStatusCode() + ':' + response.getBody();
                    listaSOE.error = 'No se ha podido establecer comunicación con el servicio';
                }
            } catch (Exception e) {
                //Traza - Error de Apex
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = e.getMessage();
                listaSOE.error = e.getMessage();
            }
        }

        insert oTraza;

        return listaSOE;
    }

    public class Lista_SOE {
        @AuraEnabled public String error;
        @AuraEnabled public Datos_SOE responseSOE;
    }

    public class Datos_SOE { //aquí es en qué campos nos los envían ellos
        @AuraEnabled public Boolean hasMore;
        @AuraEnabled public List<Datos> datos;
    }

    public class Comunicacion_SOE { //aquí se ponen los campos con los nombres que pidan ellos
        String borrowerName = ''; // Nombre acreditada 
        String borrowerId = ''; // 9999999999999 NIF
        String contractId = ''; // ID SOE
        String aliasOperation = ''; // ELIOR
        String situationSOE = ''; // 00300
    }

    public class Datos{
        @AuraEnabled public String contractId; // '9380690006435'
        @AuraEnabled public String soeDate; // '2016-01-13'
        @AuraEnabled public String aliasSoe; // 'ELIOR'
        @AuraEnabled public String borrowerName; // 'ELIOR'
        @AuraEnabled public String borrowerId; // 'TB3540867'
        @AuraEnabled public String employeeId; // 'U0144972'
        @AuraEnabled public String originatorName; // 'Yago Gómez Ponce'
        @AuraEnabled public String segmentCode; // '00001'
        @AuraEnabled public String segmentName; // 'CIB'
        @AuraEnabled public String areaCode; // '100'
        @AuraEnabled public String areaName; // 'Financ. Corporativa y Adquisiciones'
        @AuraEnabled public String sectorCode; // '101'
        @AuraEnabled public String sectorName; // 'Corporativos'
        @AuraEnabled public String groupCode; // '00999'
        @AuraEnabled public String groupName; // 'No aplica'
        @AuraEnabled public String soeSituationCode; // '00900'
        @AuraEnabled public String soeSituationName; // 'Baja'
    }     
}