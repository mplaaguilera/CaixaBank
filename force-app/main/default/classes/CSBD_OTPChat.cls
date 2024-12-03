/**********************************************************************************************************************
 Name:	  CSBD_OTPChat
 Copyright © 2022 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase instanciada en el Web Service para la creación de un código OTP en la llamada previo al chat de Live Agent
            y para crear la relación con el cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0			App CSBD			Esperanza Conde		28/01/2022			Init version
***********************************************************************************************************************/
public with sharing class CSBD_OTPChat {

    private static Id recordTypeChatId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
    public static final String HTTP_STATUS_OK 						= '200';
    public static final String HTTP_STATUS_SERVER_ERROR 			= '500';
    public static final String HTTP_STATUS_NOT_FOUND 				= '404';
    public static final String HTTP_STATUS_BAD_REQUEST				= '400';

    public class OTPResponse{
        public String status;
        public String keyOTP; 
        public String errorOTP;
    }

    /**
	 * Devuelve un OTP asociado al cliente.
	 * @param numPerso  NumPerso relacionado al cliente
	 */
    public static void getOPT() {

        OTPResponse otpResponse = new OTPResponse();
        String numPerso = '';
        //GET RECORD       
        CC_TrazaInt__c oTraza; 
        
        Object requestObject = JSON.deserialize(RestContext.request.requestBody.toString(), CSBD_WRAPPER_ConsultaOTP.class);
        CSBD_WRAPPER_ConsultaOTP consulta = (CSBD_WRAPPER_ConsultaOTP)requestObject;
        CC_InterfaceSettings__mdt recuperaLog = obtenerParametrosIntegracion('CSBD_OTP_Chat');

        if (recuperaLog.CC_TrazaActiva__c || Test.isRunningTest()) {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'CSBD_OTP_Chat';
            oTraza.CC_FechaInicio__c = datetime.now();
        }

        if(consulta != null && consulta.consultaWrapper != Null && consulta.consultaWrapper.NUMPERSO != null){
            numPerso = consulta.consultaWrapper.NUMPERSO;
        }
        if(numPerso != Null && numPerso != ''){

            String numPersoAux = CSBD_AppUtilities.formatearNumperso(numPerso);
            //Encontrar el cliente relacionado con el numPerso mandado desde NOW
            List<Contact> lstContacto = [Select AccountId from Contact where CC_NumPerso__c = :numPersoAux];
            if(!lstContacto.isEmpty()){
                
                Contact contacto =  lstContacto.get(0);

                List<Account> lstCliente =[Select Id, PersonContactId from Account where Id = :contacto.AccountId];
                if(!lstCliente.isEmpty()){
    
                    Account cliente = lstCliente.get(0);
                    
                    otpResponse = generateOTP(cliente);
                    if(otpResponse.keyOTP != null){
                        Opportunity oportunidad = createOppChat(consulta, otpResponse.keyOTP, cliente);
                        createOTPGenerado(otpResponse.keyOTP, cliente.Id, oportunidad.Id);
                        otpResponse.status = 'OK';
                        RestContext.response.statusCode   = Integer.valueOf(HTTP_STATUS_OK);
                    }else{
                        otpResponse.status = 'KO';
                        RestContext.response.statusCode   = Integer.valueOf(HTTP_STATUS_SERVER_ERROR);
                    }
    
                    RestContext.response.addHeader('Content-Type','application/json');
                    String jsonResponse = JSON.serialize(otpResponse);
                    RestContext.response.responseBody = Blob.valueOf(jsonResponse);
    
                }else{
                    RestContext.response.addHeader('Content-Type','application/json');
                    otpResponse.status = 'KO';
                    RestContext.response.statusCode = Integer.valueof(HTTP_STATUS_NOT_FOUND);
                    otpResponse.errorOTP = 'No se encuentra el cliente relacionado al numperso: '+numPerso;
                    RestContext.response.responseBody       = Blob.valueOf(JSON.serialize(otpResponse));
    
                }
            }else{
                RestContext.response.addHeader('Content-Type','application/json');
                otpResponse.status = 'KO';
                RestContext.response.statusCode = Integer.valueof(HTTP_STATUS_NOT_FOUND);
                otpResponse.errorOTP = 'No se encuentra el contacto relacionado al numperso: '+numPerso;
                RestContext.response.responseBody       = Blob.valueOf(JSON.serialize(otpResponse));

            }

            
            
        }else{
            RestContext.response.addHeader('Content-Type','application/json');
            otpResponse.status = 'KO';
            RestContext.response.statusCode = Integer.valueof(HTTP_STATUS_BAD_REQUEST);
            otpResponse.errorOTP = 'El numperso del contacto es obligatorio.';
            RestContext.response.responseBody       = Blob.valueOf(JSON.serialize(otpResponse));
        }

        if ((recuperaLog.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null){
            oTraza.CC_FechaFin__c = datetime.now();

            if (otpResponse.status != 'OK'){
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error petición.';
                oTraza.CC_DetalleError__c = otpResponse.errorOTP;
            } else{
                oTraza.CC_FinOK__c = true;
                oTraza.CC_Identificador__c = otpResponse.keyOTP;
            }

            Database.insert(oTraza);
        }

    }

    /**
	 * Crea un OTP y se la asocia al contacto.
	 * @param contacto  contacto obtenido con el numPerso enviado por NOW
	 */
    public static OTPResponse generateOTP(Account cliente) {

        OTPResponse response = new OTPResponse();
         
        String resultString = '';
        String otpAux = generateRandomString(9);
        String idCliente = cliente.Id;
        String otp = otpAux+idCliente.subString(9,18);
        response.keyOTP = otp;
        return response;
    }

    /**
	 * Crea un string random.
	 * @param len  longitud del string deseado
	 */
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    /**
	 * Crear la oportunidad relaciona a ese OTP.
	 * @param consulta  Body con los datos de la oportunidad
	 */
	public static Opportunity createOppChat(CSBD_WRAPPER_ConsultaOTP consulta, String otpKey, Account cliente){

        String methodName = 'createOppChat';
        List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        Map<String, String> mapIdioma = new Map<String, String>{'es' => 'Castellano', 'ca' => 'Catalán', 'en' => 'Inglés'};

        //Recuperamos los productos relacionados al código de producto enviado por NOW
        if(consulta.consultaWrapper.NOMBREPRODUCTO != Null){
            opp.CSBD_Now_Codigo_Producto__c = consulta.consultaWrapper.NOMBREPRODUCTO;

            List<CC_Lista_Valores__c> lstValorProducto = [Select Id, Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c, CSBD_Valor4__c from CC_Lista_Valores__c
                                                    where RecordType.DeveloperName = 'CC_Valor' and CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto'
                                                    and Name = :opp.CSBD_Now_Codigo_Producto__c and CC_Activa__c = true];


            if(!lstValorProducto.isEmpty()){

                CC_Lista_Valores__c valorProducto = lstValorProducto.get(0);

                if(valorProducto.CC_Valor_SFDC__c != null){
                    opp.CSBD_Empresa_Proveedora__c = valorProducto.CC_Valor_SFDC__c;    
                }else{
                    opp.CSBD_Empresa_Proveedora__c = 'CaixaBank';
                }
                
                opp.CSBD_Familia_Producto__c = valorProducto.CC_Valor__c;
                opp.CSBD_Producto__c = valorProducto.CC_Valor2__c;
                opp.CSBD_Skill__c = valorProducto.CSBD_Valor4__c;  
                

                if(consulta.consultaWrapper.DETALLEPRODUCTO != Null){
                    opp.CSBD_Detalle_producto__c = consulta.consultaWrapper.DETALLEPRODUCTO;

                }
            }
        }
        //Recuperamos los horarios relacionados al código de producto enviado por NOW
        if(consulta.consultaWrapper.HORARIOCONTACTO != Null){

            String codHorario = consulta.consultaWrapper.HORARIOCONTACTO;
            List<CC_Lista_Valores__c> lstValorHorario = [Select Id, Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c, CSBD_Valor4__c from CC_Lista_Valores__c
                                                            where RecordType.DeveloperName = 'CC_Valor' and CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Turno'
                                                            and Name = :codHorario and CC_Activa__c = true and CC_Lista__r.CC_Activa__c = true];

            if(!lstValorHorario.isEmpty()){
                CC_Lista_Valores__c valorHorario = lstValorHorario.get(0);
                opp.CSBD_Horario_Contacto__c = valorHorario.CC_Valor2__c;
                opp.CSBD_Horario_Contacto_IWD__c = valorHorario.CC_Valor_SFDC__c;
                opp.CSBD_Turno_Contacto__c = valorHorario.CC_Valor__c;
            }
        }

        //Recuperamos el account y el contacto 
        opp.ContactId = cliente.PersonContactId; 
        opp.CSBD_Contact__c = cliente.PersonContactId;
        opp.AccountId = cliente.Id;
        opp.RecordTypeId = recordTypeChatId;
        opp.Name = 'Chat CSBD';
        opp.StageName = 'Solicitud';
        opp.CSBD_Estado__c = 'Nueva';
        opp.CSBD_Resolucion__c = '';
        //Recuperamos el usuario genérico para que tengas permisos de visibilidad los gestores sobre la opp
        Id opportunityOwner = [SELECT Id FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%'].Id;
        opp.OwnerId = opportunityOwner; 
        opp.CSBD_Email_Solicitud__c = consulta.consultaWrapper.EMAILCLIENTE;
        opp.CSBD_Now_Apellido1__c = consulta.consultaWrapper.APELLIDO1;
        opp.CSBD_Now_Apellido2__c = consulta.consultaWrapper.APELLIDO2;
        opp.CSBD_Now_NIF__c = consulta.consultaWrapper.NIFSOLICITANTE;
        opp.CSBD_Now_Nombre__c = consulta.consultaWrapper.NOMBRESOLICITANTE;
        opp.CSBD_Telefono_Solicitud__c = consulta.consultaWrapper.TELEFONOCLIENTE;
        opp.CSBD_Now_NUMPERSO__c = CSBD_AppUtilities.formatearNumperso(consulta.consultaWrapper.NUMPERSO);
        opp.CSBD_Idioma_Solicitud__c = mapIdioma.get(consulta.consultaWrapper.IDIOMA);
        opp.CSBD_Canal__c = consulta.consultaWrapper.CANAL;
        opp.CSBD_Now_Origen__c = consulta.consultaWrapper.ORIGEN;

        Database.insert(opp);

        return opp;
        
	}

    /**
	 * Crear el OTP Generado.
	 * @param keyOTP  Código OTP generado
     * @param accountId  Cliente relacionado al OTP
     * @param opportunityId  Oportunidad relacionada al OTP
	 */
	public static void createOTPGenerado(String keyOTP, String accountId, String opportunityId){

        Id rtChatId = Schema.SObjectType.CBK_OTP_Generado__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();

        CBK_OTP_Generado__c otp = new CBK_OTP_Generado__c();
   
        //Recuperamos el account y el contacto 
        otp.CBK_Codigo_OTP__c = keyOTP; 
        otp.CBK_Fecha_Codigo_OTP__c = DateTime.NOW().addHours(1);
        otp.CBK_Oportunidad__c = opportunityId;
        Database.insert(otp);

        
	}

    @TestVisible
    private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
        List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c, CC_TrazaActiva__c
                                                                FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true LIMIT 1];
        if (!parametrosInterfaz.isEmpty()) {
            return parametrosInterfaz[0];
        } else {
            return null;
        }
    }

}