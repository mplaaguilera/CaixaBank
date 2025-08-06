/**********************************************************************************************************************
Name:	  AV_GCF_Integration
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Conexión con la API de Apoderados de GCF
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY							    AUTHOR			  	DATE			Description
1.0			US408052                            	Patricia Solano     16/08/2022		Init version
1.1			US435107                            	Patricia Solano     29/08/2022		Api Apoderados V2
***********************************************************************************************************************/
public with sharing class AV_GCF_Integration {

    /**
	* @description Clase para la lista de representantes de Bastanteo
	*/
    public class ListaRepreItem {
        public String carrec;
        public String datosEscritura;
        public Decimal dvtopod;
        public Decimal empresa;
        public Decimal fechaVencimiento;
        public String formatAct;
        public String indAccion;
        public String indCaducidad;
        public String indFirmaDig;
        public String nif;
        public String nombre;
        public Decimal numperso;
        public String ticketFirma;
        public String tipoFirma;
        public String tipoFirmaAnt;
        private String[] carrec_type_info = new String[]{'carrec','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] datosEscritura_type_info = new String[]{'datosEscritura','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] dvtopod_type_info = new String[]{'dvtopod','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] empresa_type_info = new String[]{'empresa','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] fechaVencimiento_type_info = new String[]{'fechaVencimiento','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] formatAct_type_info = new String[]{'formatAct','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] indAccion_type_info = new String[]{'indAccion','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] indCaducidad_type_info = new String[]{'indCaducidad','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] indFirmaDig_type_info = new String[]{'indFirmaDig','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] nif_type_info = new String[]{'nif','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] nombre_type_info = new String[]{'nombre','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] numperso_type_info = new String[]{'numperso','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] ticketFirma_type_info = new String[]{'ticketFirma','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] tipoFirma_type_info = new String[]{'tipoFirma','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] tipoFirmaAnt_type_info = new String[]{'tipoFirmaAnt','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/','false','false'};
        private String[] field_order_type_info = new String[]{'carrec','datosEscritura','dvtopod','empresa','fechaVencimiento','formatAct','indAccion','indCaducidad','indFirmaDig','nif','nombre','numperso','ticketFirma','tipoFirma','tipoFirmaAnt'};
    }

    /**
	* @description	Clase para preparar retorno del Servicio Web de Bastanteo
	*/
    public class Outextconslistarepre {
        public String contador;
        public ListaRepreItem[] listaRepre;
        private String[] contador_type_info = new String[]{'contador','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] listaRepre_type_info = new String[]{'listaRepre','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/','false','false'};
        private String[] field_order_type_info = new String[]{'contador','listaRepre'};
    }

    /**
	* @description	Clase para el tipo de puerto de Bastanteo
	*/
    public class BastanteoPortTypePort {
        public String endpoint_x = 'http://extcaasp27.lacaixa.es:9701/BastanteoGestionBastanteo/v3/Bastanteo/consListaRepre';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/', 'AV_GCF_Integration'};
        public Outextconslistarepre ConsListaRepre(Inextconslistarepre externalInputTO) {
            ConsListaRepre request_x = new ConsListaRepre();
            request_x.externalInputTO = externalInputTO;
            ConsListaRepreResponse response_x;
            Map<String, ConsListaRepreResponse> response_map_x = new Map<String, ConsListaRepreResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',
              'ConsListaRepre',
              'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',
              'ConsListaRepreResponse',
              'AV_GCF_Integration.ConsListaRepreResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
    }

    /**
	* @description	Clase para la lista de representantes de Bastanteo
	*/
    public class Inextconslistarepre {
        public Decimal empresa;
        public String invocadoPor;
        public Decimal numperso;
        public String opcionAut;
        private String[] empresa_type_info = new String[]{'empresa','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] invocadoPor_type_info = new String[]{'invocadoPor','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] numperso_type_info = new String[]{'numperso','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] opcionAut_type_info = new String[]{'opcionAut','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/','false','false'};
        private String[] field_order_type_info = new String[]{'empresa','invocadoPor','numperso','opcionAut'};
    }

    /**
	* @description	Clase para la lista externa de representantes de Bastanteo
	*/
    public class ConsListaRepre {
        public Inextconslistarepre externalInputTO;
        private String[] externalInputTO_type_info = new String[]{'externalInputTO','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/','false','false'};
        private String[] field_order_type_info = new String[]{'externalInputTO'};
    }
    
    /**
	* @description	Clase para la respuesta de la lista externa de representantes de Bastanteo
	*/
    public class ConsListaRepreResponse {
        public Outextconslistarepre return_x;
        private String[] return_x_type_info = new String[]{'return','http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://bastanteo.bastanteogestionbastanteo.mca.si.absis.lacaixa.es/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }

    /**
	 * @description	Método para recuperar configuración integración con Body petición
	 * @param sInterfaz
	 */
    public static CC_InterfaceSettings__mdt getInterfazConfigBody(String sInterfaz) {
        List<CC_InterfaceSettings__mdt> oConfig = [SELECT CC_Certificado__c, CC_EndPoint__c, CC_TimeOut__c, CC_TipoPeticion__c, CC_CharSet__c, CC_ContentType__c, CC_HttpRequest__c, CC_SoapAction__c, CC_Body__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c, CC_ALF_CliConf__c, CC_CliConfiErr__c FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz AND CC_Activa__c = true];
        if (oConfig.size() == 1 && oConfig[0] != null) {
            return oConfig[0];
        } else {
            return null;
        }
    }

    /**
	 * @description	Método para la llamada WSDL a Alfabético para obtener los representantes de personas jurídicas
	 * @param oConfig
     * @param sIdCliente
     * @param sIdOrig
	 */
    public static Map<String,Object> getAP2WSDL_ALF_Representantes_Juridico (CC_InterfaceSettings__mdt oConfig, String sIdCliente, String sIdOrig) {
        Map<String,Object> oMap = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';

        Outextconslistarepre oRetorno;

        // Preparar consulta de representantes.
        Inextconslistarepre oIn = new Inextconslistarepre();
        oIn.empresa = 1;
        oIn.invocadoPor = 'EPC';
        oIn.numperso = Decimal.valueOf(sIdCliente);
        oIn.opcionAut = 'LI';

        // Gestión trazas.
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()) {
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'ALF_REP_JURIDICO_AP2WSDL';
            oTraza.CC_Identificador__c = sIdCliente;
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_IdOrigen__c = sIdOrig;

            if (oConfig.CC_TrazaEntrada__c) {
                oTraza.CC_MensajeEntrada__c = String.valueOf(oIn);
            }
        }

        try {
            BastanteoPortTypePort oWS = new BastanteoPortTypePort();
            
            //if (!Test.isRunningTest()) {
                oWS.clientCertName_x = oConfig.CC_Certificado__c;

                oWS.timeout_x = Integer.valueOf(oConfig.CC_TimeOut__c);
                oWS.endpoint_x = oConfig.CC_EndPoint__c;
    
                oRetorno = oWS.ConsListaRepre(oIn);
            //}
            
        } catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Finalizar traza.
        if ( (oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null) {
            oTraza.CC_FechaFin__c = datetime.now();

            if ((oConfig.CC_TrazaSalida__c || Test.isRunningTest()) && oRetorno != null) {
                oTraza.CC_MensajeSalida__c = String.valueOf(oRetorno);
            }

            if (sDescError != '') {
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            } else {
                oTraza.CC_FinOK__c = true;
            }
        }

        // Preparar retorno.
        if (oTraza != null) {
            oMap.put('TRAZA', oTraza);
        }
        oMap.put('RETORNO', oRetorno);

        return oMap;
    }

    /**
    * @description Función para separar el nombre completo. De utilidad en el futuro para los contactos de una empresa
    * @param sNomCompleto
    */
    public static List<String> getNombreSeparado (String sNomCompleto)
    {
        String sNombre = '';
        String sApellido1 = '';
        String sApellido2 = '';
        List<String> oNomCompleto = new List<String>();

        if (sNomCompleto != '') {
            List<String> oNomAux = sNomCompleto.split('\\s+');

            if (oNomAux.size()>=3) {
                sApellido2 = oNomAux[oNomAux.size()-1];
                sApellido1 = oNomAux[oNomAux.size()-2];
                for (Integer i=0; i<oNomAux.size()-2; i++)
                {
                    sNombre = sNombre + ' ' + oNomAux[i];
                }
            } else {
                if (oNomAux.size() == 2) {
                    sNombre = oNomAux[0];
                    sApellido1 = oNomAux[1];
                } else {
                    sApellido1 = sNomCompleto;
                }
            }
        }

        oNomCompleto.add(sNombre.trim());
        oNomCompleto.add(sApellido1.trim());
        oNomCompleto.add(sApellido2.trim());

        return oNomCompleto;
    }

     /**
	 * @description	Método para convertir la respuesta de representantes jurídicos de ALF a contactos
	 * @param sIdPersona
     * @param oRepresentantesALF
	 */
    private static List<Contact> getRepresentantesLegalesContactoJuridico (String sIdPersona, Outextconslistarepre oRepresentantesALF) {
        List<Contact> oRepresentantesRes = new List<Contact>();

        if (oRepresentantesALF == null) {
            return oRepresentantesRes;
        }

        if (oRepresentantesALF.listaRepre == null) {
            return oRepresentantesRes;
        }

        if (oRepresentantesALF.listaRepre.isEmpty()) {
            return oRepresentantesRes;
        }

        if (String.isBlank(sIdPersona)) {
            return oRepresentantesRes;
        }

        for (ListaRepreItem oRepresentante : oRepresentantesALF.listaRepre) {

            String sNIF = '';
            String sNombreCompleto = '';
            String sNumPerso = sIdPersona;
            String sNumPersoContacto = '';
            String sCaducado = 'N';
            String sFirmaDigital = 'N';
            String sCargo = '';
            String sObservaciones = '';
            String sRelacion = 'Apoderado'; // Siempre es apoderado en esta integración.

            if (String.isNotBlank(oRepresentante.nif)) {
                sNIF = oRepresentante.nif.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.nombre)) {
                sNombreCompleto = oRepresentante.nombre.trim().unescapeHtml4();
            }

            if (oRepresentante.numperso != null) {
                sNumPersoContacto = String.valueOf(oRepresentante.numperso);
            }

            if (String.isNotBlank(oRepresentante.indCaducidad)) {
                sCaducado = oRepresentante.indCaducidad.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.indFirmaDig)) {
                sFirmaDigital = oRepresentante.indFirmaDig.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.carrec)) {
                sCargo = oRepresentante.carrec.trim().unescapeHtml4();
            }

            if (String.isNotBlank(oRepresentante.datosEscritura)) {
                sObservaciones = oRepresentante.datosEscritura.trim().unescapeHtml4();
            }

            // Gestión datos obligatorios representante
            if (sNIF != '' && sNombreCompleto != '' && sNumPerso != '') {
                // Descomposición del nombre completo.
                String sNombre = '';
                String sApellido1 = '';
                String sApellido2 = '';

                List<String> oDataNom = getNombreSeparado (sNombreCompleto);
                if (oDataNom.size() == 3) {
                    sNombre = oDataNom[0];
                    sApellido1 = oDataNom[1];
                    sApellido2 = oDataNom[2];
                } else {
                    // Tratamiento valor obligatorio.
                    sApellido1 = sNombreCompleto;
                }

                Contact oNuevoRepresentante = new Contact();
                oNuevoRepresentante.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
                oNuevoRepresentante.FirstName = sNombre;
                oNuevoRepresentante.LastName = sApellido1 + ' ' + sApellido2;
                oNuevoRepresentante.CC_CuentaRepresentada__r = new Account(CC_NumPerso__c = sNumPerso);
                oNuevoRepresentante.CC_NumPerso__c = sNumPerso + '_' + sNIF;
                oNuevoRepresentante.CC_NumPersoAsoc__c = sNumPersoContacto;
                oNuevoRepresentante.CC_Numero_Documento__c = sNIF;
				oNuevoRepresentante.CC_CargoRepresentante__c = sCargo.left(40);
				oNuevoRepresentante.CC_TipoRepresentante__c = sRelacion;
				oNuevoRepresentante.CC_Observaciones__c = sObservaciones.left(500);
				oNuevoRepresentante.Account = new Account(CC_NumPerso__c = sNumPerso);
                
                if (sFirmaDigital == 'S') {
                    oNuevoRepresentante.CC_FirmaDigitalizada__c = true;
                } else {
                    oNuevoRepresentante.CC_FirmaDigitalizada__c = false;
                }

                if (sCaducado == 'S') {
                    oNuevoRepresentante.CC_Inactivo__c = true;
                } else {
                    oNuevoRepresentante.CC_Inactivo__c = false;
                }

                oRepresentantesRes.add(oNuevoRepresentante);
            }
        }
        return oRepresentantesRes;
    }

    /**
	* @description	Método para recuperar los datos de representantes de un cliente jurídico
	* @param sIDToIdent
    * @param sIdOrig
	*/
    public static Map<String,Object> getDataALFWS_RepresentantesJuridicos (String sIDToIdent, String sIdOrig) {
        Map<String,Object> oObj = new Map<String,Object>();
        CC_TrazaInt__c oTraza;
        List<Contact> oRepresentantes = new List<Contact>();

        if (sIDToIdent != '') {
            String sInterfaz = 'AV_ApiApoderado';

            // Recuperar configuración Alfabético.
            CC_InterfaceSettings__mdt oConfig = getInterfazConfigBody(sInterfaz);

            if (oConfig != null) {
                // Preparar retorno del Servicio Web.
                Outextconslistarepre oRes;

                // No hay llamada HTTP implementada. Todo es Apex2WSDL.
                Boolean bHttpRequest = oConfig.CC_HttpRequest__c;

                // Llamada vía AP2WSDL.
                Map<String,Object> oRetInt = getAP2WSDL_ALF_Representantes_Juridico(oConfig, sIDToIdent, sIdOrig);

                if (oRetInt.get('RETORNO') != null) {
                    oRes = (Outextconslistarepre)oRetInt.get('RETORNO');
                }
                
                if (oRetInt.get('TRAZA') != null) {
                    oTraza = (CC_TrazaInt__c)oRetInt.get('TRAZA');
                }

                // Recuperar la lista de representantes de las cuentas jurídicas y convertir a lista de contactos.
                oRepresentantes = getRepresentantesLegalesContactoJuridico(sIDToIdent, oRes);
                
                if (oRepresentantes != null && (!oRepresentantes.isEmpty())) {
                    oObj.put('REPR_JURIDICO', oRepresentantes);
                }

                // Incorporar la traza.
                if (oTraza != null) {
                    oObj.put('TRAZA', oTraza);
                }
            }
        }
        return oObj;
    }
}