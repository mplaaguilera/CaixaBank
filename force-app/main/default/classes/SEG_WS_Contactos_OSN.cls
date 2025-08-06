public with sharing class SEG_WS_Contactos_OSN {
    public static Contactos_OSN obtencionListaContactosOSN(String numperso, String caseNumber) {

        Contactos_OSN resultContactosOSN = new Contactos_OSN();
        Comunicacion_Contacto_OSN datosEnvio = new Comunicacion_Contacto_OSN();

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'SEG_Contactos_OSN';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_Identificador__c = caseNumber;
        oTraza.CC_MensajeEntrada__c = numperso;
        oTraza.CC_FinOK__c = true;

        // Custom Setting
        String intSetting = 'SEG_Contactos_OSN';

        try {
            // Crear HEADER
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            mHeaders.put('accreditedNumper', numperso);

            HttpRequest request = CBK_HttpServiceIntegration.getRequest(null, intSetting, 'GET', mHeaders);
            String endpoint = request.getEndpoint().replace('{contractId}', numperso);
            request.setEndpoint(endpoint);
            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);
            if (response != null && response.getStatusCode() == 200) {
                oTraza.CC_MensajeSalida__c = response.getBody();
                Datos_Contacto resultado = (Datos_Contacto)System.JSON.deserialize(response.getBody(), Datos_Contacto.class);
                resultContactosOSN.responseContactoOSN = resultado;
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = true;
            } else {
                //Traza - Error con la conexión al ws
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = response.getStatusCode() + ':' + response.getBody();
                resultContactosOSN.error = response.getBody();
            }
        } catch (Exception e) {
            //Traza - Error de Apex
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = 'Error comunicaciones.';
            oTraza.CC_DetalleError__c = e.getMessage();
            resultContactosOSN.error = e.getMessage();
        }

        insert oTraza;

        return resultContactosOSN;
    }

    public class Contactos_OSN {
        @AuraEnabled public String error;
        @AuraEnabled public Datos_Contacto responseContactoOSN;
    }

    public class Comunicacion_Contacto_OSN { //aquí se ponen los campos con los nombres que pidan ellos
        String accreditedNumper; // 9999999999999
    }

    public class Datos_Contacto{
        @AuraEnabled public Double syndicatedId;	//9340650010017
	    @AuraEnabled public String syndicatedReference;	//CAIXESBBOSN9340650010017
	    @AuraEnabled public String operationType;	//AGENT
        @AuraEnabled public String agentEntity;	//CAIXABANK S.A.
        @AuraEnabled public Decimal amountGranted;	//28000000 Se comenta la variable hasta que indiquen el campo de otra forma o lo reemplazemos nosotros
        @AuraEnabled public String ccy;	//EUR
        @AuraEnabled public String dateFrom;	//2023-08-11
        @AuraEnabled public String dateTo;	//2033-07-31
        @AuraEnabled public String status;	//CURRENT
        @AuraEnabled public String accreditedName;	//RESTAURANT HEREDIA MENDE
        @AuraEnabled public Double contractSoeId;	//9380690000110
        @AuraEnabled public String contractSoeArea;	//Structured Trade Finance
        @AuraEnabled public String originatorName;	//Nom Originador Caixa Ape1
        @AuraEnabled public List<Contacto> contactList; // Lista de Contactos
        //@AuraEnabled public Double amountGrantedDouble; // Variable double para evitar errores cuando recibimos numeros en potencias
        
    }

    public class Contacto{
        @AuraEnabled public String name; // Nombre del Contacto
        @AuraEnabled public String email; // Email del Contacto
        @AuraEnabled public String entityType; // Tipo de identidad del Contacto
        @AuraEnabled public String entityName; // Nombre de identidad del Contacto
    }
}