public with sharing class SPV_Reclamaciones_Integration{
    
    public static final String HEADER_CONTENT_TYPE 		= 'Content-Type';
    public static final String APPLICATION_JSON 		= 'application/json';
    private static final String SPV_GET_RECLAMACIONES   	= 'SPV_Get_Reclamaciones';
    private static final String SPV_UPDATE_RECLAMACIONES   	= 'SPV_Update_Reclamaciones';
    
    public class ReclamacionResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public List<ListaResultado> data;
    }
    
    public class ListaResultado {
        @AuraEnabled
        public String expedienteReclamacion;
        @AuraEnabled
        public String estado;
        @AuraEnabled
        public String usuario;
        @AuraEnabled
        public String nombreUsuario;
        @AuraEnabled
        public String orgProcedencia;
        @AuraEnabled
        public String grupo;
        @AuraEnabled
        public String prodReclamN1;
        @AuraEnabled
        public String motivoReclamN1;
        @AuraEnabled
        public String numDocReclamante;
        @AuraEnabled
        public String nomReclamante;
        @AuraEnabled
        public String idReclamacion;
        @AuraEnabled
        public String prodReclamaN2;	
        @AuraEnabled
        public String prodReclamaN3;
        @AuraEnabled
        public String motivoReclamN2;
        @AuraEnabled
        public String tieneRectificacion;
        @AuraEnabled
        public String empresaProcede;
        @AuraEnabled
        public String migrada;
        @AuraEnabled
        public String activa;
        @AuraEnabled
        public String fechaRecepcion; //20231121
        @AuraEnabled
        public String fechaVencimiento; //20231121
        @AuraEnabled
        public String descProdReclamN1;
        @AuraEnabled
        public String descProdReclamN2;
        @AuraEnabled
        public String descProdReclamN3;
        @AuraEnabled
        public String descMotivoReclamN1;
        @AuraEnabled
        public String descMotivoReclamN2;
        @AuraEnabled
        public String pdteResp;
        @AuraEnabled
        public String pdteRevisarResp;
        @AuraEnabled
        public String idTipo; 
        @AuraEnabled
        public String reclActiva; 
        @AuraEnabled
        public String esProrroga; 
    }
    
    /**
* @description Método para obtener el detalle de la reclamación.
*/
    @AuraEnabled
    public static ReclamacionResponse getReclamaciones(){
        
        ReclamacionResponse response = new ReclamacionResponse();
        CC_InterfaceSettings__mdt confInterfaz   = SAC_Utils.getInterfazConfigBody(SPV_GET_RECLAMACIONES);
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(HEADER_CONTENT_TYPE, confInterfaz.CC_ContentType__c);
        
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = confInterfaz.CC_Body__c;
        reqWap.intSetting = SPV_GET_RECLAMACIONES;
        reqWap.method = confInterfaz.CC_TipoPeticion__c;
        reqWap.mHeaders = mapHeader;
        
        HttpRequest request = new HttpRequest();
        if(!Test.isRunningTest()){
            request = CBK_HttpServiceIntegration.getRequest(reqWap);
        }
        
        String dataMockup = '';
        //if(Test.isRunningTest()){
        	dataMockup = createMock();
        //}
        System.debug('*dataMockup ' + dataMockup);
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.multiCallHttpService(request,'', SPV_GET_RECLAMACIONES);
        String statusCode = String.valueOf(resp.getStatusCode());
        if(statusCode.equalsIgnoreCase('200')){
            String xmlResponse = resp.getBody();
            System.debug('*XML ' + xmlResponse);
            // Parsear el XML
            Dom.Document doc = new Dom.Document();
            doc.load(xmlResponse);
            // Extraer los valores del XML
            Dom.XMLNode rootNode = doc.getRootElement();
            Dom.XMLNode bodyNode = rootNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode returnNode = bodyNode.getChildElement('return', null);
            Dom.XMLNode beanBodyNode = returnNode.getChildElement('BeanBodyBusquedaReclamOut', null);
            
            // Construir el objeto de respuesta
            List<ListaResultado> listaResultadoList = new List<ListaResultado>();
            // Loop en lista
            for (Dom.XMLNode listaResultadoNode : beanBodyNode.getChildElements()) {
                if (listaResultadoNode.getName() == 'listaResultado') {
                    ListaResultado listaResultado = new ListaResultado();
                    listaResultado.expedienteReclamacion = listaResultadoNode.getChildElement('expedienteReclamacion', null).getText();
                    listaResultado.estado = listaResultadoNode.getChildElement('estado', null).getText();
                    listaResultado.usuario = listaResultadoNode.getChildElement('usuario', null).getText();
                    listaResultado.nombreUsuario = listaResultadoNode.getChildElement('nombreUsuario', null).getText();
                    listaResultado.orgProcedencia = listaResultadoNode.getChildElement('orgProcedencia', null).getText();
                    listaResultado.grupo = listaResultadoNode.getChildElement('grupo', null).getText();
                    listaResultado.prodReclamN1 = listaResultadoNode.getChildElement('prodReclamN1', null).getText();
                    listaResultado.motivoReclamN1 = listaResultadoNode.getChildElement('motivoReclamN1', null).getText();
                    listaResultado.numDocReclamante = listaResultadoNode.getChildElement('numDocReclamante', null).getText();
                    listaResultado.nomReclamante = listaResultadoNode.getChildElement('nomReclamante', null).getText();
                    listaResultado.idReclamacion = listaResultadoNode.getChildElement('idReclamacion', null).getText();
                    listaResultado.prodReclamaN2 = listaResultadoNode.getChildElement('prodReclamaN2', null).getText();
                    listaResultado.prodReclamaN3 = listaResultadoNode.getChildElement('prodReclamaN3', null).getText();
                    listaResultado.motivoReclamN2 = listaResultadoNode.getChildElement('motivoReclamN2', null).getText();
                    listaResultado.tieneRectificacion = listaResultadoNode.getChildElement('tieneRectificacion', null).getText();
                    listaResultado.empresaProcede = listaResultadoNode.getChildElement('empresaProcede', null).getText();
                    listaResultado.migrada = listaResultadoNode.getChildElement('migrada', null).getText();
                    listaResultado.activa = listaResultadoNode.getChildElement('activa', null).getText();
                    listaResultado.fechaRecepcion = listaResultadoNode.getChildElement('fechaRecepcion', null).getText();
                    listaResultado.fechaVencimiento = listaResultadoNode.getChildElement('fechaVencimiento', null).getText();
                    listaResultado.descProdReclamN1 = listaResultadoNode.getChildElement('descProdReclamN1', null).getText();
                    listaResultado.descProdReclamN2 = listaResultadoNode.getChildElement('descProdReclamN2', null).getText();
                    listaResultado.descProdReclamN3 = listaResultadoNode.getChildElement('descProdReclamN3', null).getText();
                    listaResultado.descMotivoReclamN1 = listaResultadoNode.getChildElement('descMotivoReclamN1', null).getText();
                    listaResultado.descMotivoReclamN2 = listaResultadoNode.getChildElement('descMotivoReclamN2', null).getText();
                    listaResultado.pdteResp = listaResultadoNode.getChildElement('pdteResp', null).getText();
                    listaResultado.pdteRevisarResp = listaResultadoNode.getChildElement('pdteRevisarResp', null).getText();
                    listaResultado.idTipo = listaResultadoNode.getChildElement('idTipo', null).getText();
                    listaResultado.reclActiva = listaResultadoNode.getChildElement('reclActiva', null).getText();
                    listaResultado.esProrroga = listaResultadoNode.getChildElement('esProrroga', null).getText();
                    listaResultadoList.add(listaResultado);
                }
            }
            response.data = listaResultadoList;
            response.statusCode = '200';
            
            // Convertir JSON
            String jsonResponse = JSON.serialize(response);
            System.debug('*JSON ' + jsonResponse);
        }else{
            response.statusCode = statusCode;
            response.errorCode = 'Error en el servicio.';
            response.errorMessage = resp.getStatus(); 
        } 
        return response;    
    }
    
    @AuraEnabled
    public static ReclamacionResponse updateReclamaciones(){
        
        ReclamacionResponse response = new ReclamacionResponse();
        CC_InterfaceSettings__mdt confInterfaz   = SAC_Utils.getInterfazConfigBody(SPV_UPDATE_RECLAMACIONES);
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(HEADER_CONTENT_TYPE, confInterfaz.CC_ContentType__c);
        
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = confInterfaz.CC_Body__c;
        reqWap.intSetting = SPV_UPDATE_RECLAMACIONES;
        reqWap.method = confInterfaz.CC_TipoPeticion__c;
        reqWap.mHeaders = mapHeader;
        
        HttpRequest request = new HttpRequest();
        if(!Test.isRunningTest()){
            request = CBK_HttpServiceIntegration.getRequest(reqWap);
            // Endpoint
            String endpoint = request.getEndpoint();
            request.setEndpoint(endpoint);
        }
        
        String dataMockup = '';
        //if(Test.isRunningTest()){
        	dataMockup = createMock();
        //}
        System.debug('*dataMockup ' + dataMockup);
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.multiCallHttpService(request,'', SPV_UPDATE_RECLAMACIONES);
        String statusCode = String.valueOf(resp.getStatusCode());
        if(statusCode.equalsIgnoreCase('200')){
            String xmlResponse = resp.getBody();
            System.debug('*XML ' + xmlResponse);
            // Parsear el XML
            Dom.Document doc = new Dom.Document();
            doc.load(xmlResponse);
            // Extraer los valores del XML
            Dom.XMLNode rootNode = doc.getRootElement();
            Dom.XMLNode bodyNode = rootNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode returnNode = bodyNode.getChildElement('return', null);
            Dom.XMLNode beanBodyNode = returnNode.getChildElement('BeanBodyBusquedaReclamOut', null);
            
            // Construir el objeto de respuesta
            List<ListaResultado> listaResultadoList = new List<ListaResultado>();
            // Loop en lista
            for (Dom.XMLNode listaResultadoNode : beanBodyNode.getChildElements()) {
                if (listaResultadoNode.getName() == 'listaResultado') {
                    ListaResultado listaResultado = new ListaResultado();
                    listaResultado.expedienteReclamacion = listaResultadoNode.getChildElement('expedienteReclamacion', null).getText();
                    listaResultado.estado = listaResultadoNode.getChildElement('estado', null).getText();
                    listaResultado.usuario = listaResultadoNode.getChildElement('usuario', null).getText();
                    listaResultado.nombreUsuario = listaResultadoNode.getChildElement('nombreUsuario', null).getText();
                    listaResultado.orgProcedencia = listaResultadoNode.getChildElement('orgProcedencia', null).getText();
                    listaResultado.grupo = listaResultadoNode.getChildElement('grupo', null).getText();
                    listaResultado.prodReclamN1 = listaResultadoNode.getChildElement('prodReclamN1', null).getText();
                    listaResultado.motivoReclamN1 = listaResultadoNode.getChildElement('motivoReclamN1', null).getText();
                    listaResultado.numDocReclamante = listaResultadoNode.getChildElement('numDocReclamante', null).getText();
                    listaResultado.nomReclamante = listaResultadoNode.getChildElement('nomReclamante', null).getText();
                    listaResultado.idReclamacion = listaResultadoNode.getChildElement('idReclamacion', null).getText();
                    listaResultado.prodReclamaN2 = listaResultadoNode.getChildElement('prodReclamaN2', null).getText();
                    listaResultado.prodReclamaN3 = listaResultadoNode.getChildElement('prodReclamaN3', null).getText();
                    listaResultado.motivoReclamN2 = listaResultadoNode.getChildElement('motivoReclamN2', null).getText();
                    listaResultado.tieneRectificacion = listaResultadoNode.getChildElement('tieneRectificacion', null).getText();
                    listaResultado.empresaProcede = listaResultadoNode.getChildElement('empresaProcede', null).getText();
                    listaResultado.migrada = listaResultadoNode.getChildElement('migrada', null).getText();
                    listaResultado.activa = listaResultadoNode.getChildElement('activa', null).getText();
                    listaResultado.fechaRecepcion = listaResultadoNode.getChildElement('fechaRecepcion', null).getText();
                    listaResultado.fechaVencimiento = listaResultadoNode.getChildElement('fechaVencimiento', null).getText();
                    listaResultado.descProdReclamN1 = listaResultadoNode.getChildElement('descProdReclamN1', null).getText();
                    listaResultado.descProdReclamN2 = listaResultadoNode.getChildElement('descProdReclamN2', null).getText();
                    listaResultado.descProdReclamN3 = listaResultadoNode.getChildElement('descProdReclamN3', null).getText();
                    listaResultado.descMotivoReclamN1 = listaResultadoNode.getChildElement('descMotivoReclamN1', null).getText();
                    listaResultado.descMotivoReclamN2 = listaResultadoNode.getChildElement('descMotivoReclamN2', null).getText();
                    listaResultado.pdteResp = listaResultadoNode.getChildElement('pdteResp', null).getText();
                    listaResultado.pdteRevisarResp = listaResultadoNode.getChildElement('pdteRevisarResp', null).getText();
                    listaResultado.idTipo = listaResultadoNode.getChildElement('idTipo', null).getText();
                    listaResultado.reclActiva = listaResultadoNode.getChildElement('reclActiva', null).getText();
                    listaResultado.esProrroga = listaResultadoNode.getChildElement('esProrroga', null).getText();
                    listaResultadoList.add(listaResultado);
                }
            }
            response.data = listaResultadoList;
            response.statusCode = '200';
            
            // Convertir JSON
            String jsonResponse = JSON.serialize(response);
            System.debug('*JSON ' + jsonResponse);
        }else{
            response.statusCode = statusCode;
            response.errorCode = 'Error en el servicio.';
            response.errorMessage = resp.getStatus(); 
        } 
        return response;    
    }
    private static String createMock(){
        String dataMockup = '';
        dataMockup = dataMockup + '<?xml version="1.0"?>';
        dataMockup = dataMockup + '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:atr="https://extcaastb1.lacaixa.es/AttReclamacionesBusquedaReclamac/v1/BusquedaReclamac142/busquedaReclam/">';
        dataMockup = dataMockup + '<soapenv:Header/>';
        dataMockup = dataMockup + '<soapenv:Body>';
        dataMockup = dataMockup + '<return>';
        dataMockup = dataMockup + '<BeanBodyBusquedaReclamOut>';
        dataMockup = dataMockup + '<listaResultado>';
        dataMockup = dataMockup + '<expedienteReclamacion>EXP123450124A</expedienteReclamacion>';
        dataMockup = dataMockup + '<estado>En proceso</estado>';
        dataMockup = dataMockup + '<usuario>Usuario123</usuario>';
        dataMockup = dataMockup + '<nombreUsuario>Juan Perez</nombreUsuario>';
        dataMockup = dataMockup + '<orgProcedencia>Org 1</orgProcedencia>';
        dataMockup = dataMockup + '<grupo>Grupo 1</grupo>';
        dataMockup = dataMockup + '<prodReclamN1>Prod1</prodReclamN1>';
        dataMockup = dataMockup + '<motivoReclamN1>Motivo 1</motivoReclamN1>';
        dataMockup = dataMockup + '<numDocReclamante>12345678X</numDocReclamante>';
        dataMockup = dataMockup + '<nomReclamante>Juan Perez</nomReclamante>';
        dataMockup = dataMockup + '<idReclamacion>REC123</idReclamacion>';
        dataMockup = dataMockup + '<prodReclamaN2>Prod2</prodReclamaN2>';
        dataMockup = dataMockup + '<prodReclamaN3>Prod3</prodReclamaN3>';
        dataMockup = dataMockup + '<motivoReclamN2>Motivo 2</motivoReclamN2>';
        dataMockup = dataMockup + '<tieneRectificacion>N</tieneRectificacion>';
        dataMockup = dataMockup + '<empresaProcede>8</empresaProcede>';
        dataMockup = dataMockup + '<migrada>S</migrada>';
        dataMockup = dataMockup + '<activa>S</activa>';
        dataMockup = dataMockup + '<fechaRecepcion>20231121</fechaRecepcion>';
        dataMockup = dataMockup + '<fechaVencimiento>20231201</fechaVencimiento>';
        dataMockup = dataMockup + '<descProdReclamN1>Descripción Producto 1</descProdReclamN1>';
        dataMockup = dataMockup + '<descProdReclamN2>Descripción Producto 2</descProdReclamN2>';
        dataMockup = dataMockup + '<descProdReclamN3>Descripción Producto 3</descProdReclamN3>';
        dataMockup = dataMockup + '<descMotivoReclamN1>Descripción Motivo 1</descMotivoReclamN1>';
        dataMockup = dataMockup + '<descMotivoReclamN2>Descripción Motivo 2</descMotivoReclamN2>';
        dataMockup = dataMockup + '<pdteResp>N</pdteResp>';
        dataMockup = dataMockup + '<pdteRevisarResp>S</pdteRevisarResp>';
        dataMockup = dataMockup + '<idTipo>TIPO123</idTipo>';
        dataMockup = dataMockup + '<reclActiva>S</reclActiva>';
        dataMockup = dataMockup + '<esProrroga>N</esProrroga>';
        dataMockup = dataMockup + '</listaResultado>';
        
        dataMockup = dataMockup + '<listaResultado>';
        dataMockup = dataMockup + '<expedienteReclamacion>EXP777</expedienteReclamacion>';
        dataMockup = dataMockup + '<estado>En proceso</estado>';
        dataMockup = dataMockup + '<usuario>Usuario123</usuario>';
        dataMockup = dataMockup + '<nombreUsuario>Juan Perez</nombreUsuario>';
        dataMockup = dataMockup + '<orgProcedencia>Org 1</orgProcedencia>';
        dataMockup = dataMockup + '<grupo>Grupo 1</grupo>';
        dataMockup = dataMockup + '<prodReclamN1>Prod1</prodReclamN1>';
        dataMockup = dataMockup + '<motivoReclamN1>Motivo 1</motivoReclamN1>';
        dataMockup = dataMockup + '<numDocReclamante>12345678X</numDocReclamante>';
        dataMockup = dataMockup + '<nomReclamante>Juan Perez</nomReclamante>';
        dataMockup = dataMockup + '<idReclamacion>REC123</idReclamacion>';
        dataMockup = dataMockup + '<prodReclamaN2>Prod2</prodReclamaN2>';
        dataMockup = dataMockup + '<prodReclamaN3>Prod3</prodReclamaN3>';
        dataMockup = dataMockup + '<motivoReclamN2>Motivo 2</motivoReclamN2>';
        dataMockup = dataMockup + '<tieneRectificacion>N</tieneRectificacion>';
        dataMockup = dataMockup + '<empresaProcede>124</empresaProcede>';
        dataMockup = dataMockup + '<migrada>S</migrada>';
        dataMockup = dataMockup + '<activa>S</activa>';
        dataMockup = dataMockup + '<fechaRecepcion>20231121</fechaRecepcion>';
        dataMockup = dataMockup + '<fechaVencimiento>20231201</fechaVencimiento>';
        dataMockup = dataMockup + '<descProdReclamN1>Descripción Producto 1</descProdReclamN1>';
        dataMockup = dataMockup + '<descProdReclamN2>Descripción Producto 2</descProdReclamN2>';
        dataMockup = dataMockup + '<descProdReclamN3>Descripción Producto 3</descProdReclamN3>';
        dataMockup = dataMockup + '<descMotivoReclamN1>Descripción Motivo 1</descMotivoReclamN1>';
        dataMockup = dataMockup + '<descMotivoReclamN2>Descripción Motivo 2</descMotivoReclamN2>';
        dataMockup = dataMockup + '<pdteResp>N</pdteResp>';
        dataMockup = dataMockup + '<pdteRevisarResp>S</pdteRevisarResp>';
        dataMockup = dataMockup + '<idTipo>TIPO123</idTipo>';
        dataMockup = dataMockup + '<reclActiva>S</reclActiva>';
        dataMockup = dataMockup + '<esProrroga>N</esProrroga>';
        dataMockup = dataMockup + '</listaResultado>';
        
        dataMockup = dataMockup + '<listaResultado>';
        dataMockup = dataMockup + '<expedienteReclamacion>EXP7691</expedienteReclamacion>';
        dataMockup = dataMockup + '<estado>En proceso</estado>';
        dataMockup = dataMockup + '<usuario>Usuario123</usuario>';
        dataMockup = dataMockup + '<nombreUsuario>Juan Perez</nombreUsuario>';
        dataMockup = dataMockup + '<orgProcedencia>Org 1</orgProcedencia>';
        dataMockup = dataMockup + '<grupo>Grupo 1</grupo>';
        dataMockup = dataMockup + '<prodReclamN1>Prod1</prodReclamN1>';
        dataMockup = dataMockup + '<motivoReclamN1>Motivo 1</motivoReclamN1>';
        dataMockup = dataMockup + '<numDocReclamante>12345678X</numDocReclamante>';
        dataMockup = dataMockup + '<nomReclamante>Juan Perez</nomReclamante>';
        dataMockup = dataMockup + '<idReclamacion>REC123</idReclamacion>';
        dataMockup = dataMockup + '<prodReclamaN2>Prod2</prodReclamaN2>';
        dataMockup = dataMockup + '<prodReclamaN3>Prod3</prodReclamaN3>';
        dataMockup = dataMockup + '<motivoReclamN2>Motivo 2</motivoReclamN2>';
        dataMockup = dataMockup + '<tieneRectificacion>N</tieneRectificacion>';
        dataMockup = dataMockup + '<empresaProcede>8221</empresaProcede>';
        dataMockup = dataMockup + '<migrada>S</migrada>';
        dataMockup = dataMockup + '<activa>S</activa>';
        dataMockup = dataMockup + '<fechaRecepcion>20231121</fechaRecepcion>';
        dataMockup = dataMockup + '<fechaVencimiento>20231201</fechaVencimiento>';
        dataMockup = dataMockup + '<descProdReclamN1>Descripción Producto 1</descProdReclamN1>';
        dataMockup = dataMockup + '<descProdReclamN2>Descripción Producto 2</descProdReclamN2>';
        dataMockup = dataMockup + '<descProdReclamN3>Descripción Producto 3</descProdReclamN3>';
        dataMockup = dataMockup + '<descMotivoReclamN1>Descripción Motivo 1</descMotivoReclamN1>';
        dataMockup = dataMockup + '<descMotivoReclamN2>Descripción Motivo 2</descMotivoReclamN2>';
        dataMockup = dataMockup + '<pdteResp>N</pdteResp>';
        dataMockup = dataMockup + '<pdteRevisarResp>S</pdteRevisarResp>';
        dataMockup = dataMockup + '<idTipo>TIPO123</idTipo>';
        dataMockup = dataMockup + '<reclActiva>S</reclActiva>';
        dataMockup = dataMockup + '<esProrroga>N</esProrroga>';
        dataMockup = dataMockup + '</listaResultado>';
        
        dataMockup = dataMockup + '<listaResultado>';
        dataMockup = dataMockup + '<expedienteReclamacion>EXP7691</expedienteReclamacion>';
        dataMockup = dataMockup + '<estado>En proceso</estado>';
        dataMockup = dataMockup + '<usuario>Usuario123</usuario>';
        dataMockup = dataMockup + '<nombreUsuario>Juan Perez</nombreUsuario>';
        dataMockup = dataMockup + '<orgProcedencia>Org 1</orgProcedencia>';
        dataMockup = dataMockup + '<grupo>Grupo 1</grupo>';
        dataMockup = dataMockup + '<prodReclamN1>Prod1</prodReclamN1>';
        dataMockup = dataMockup + '<motivoReclamN1>Motivo 1</motivoReclamN1>';
        dataMockup = dataMockup + '<numDocReclamante>12345678X</numDocReclamante>';
        dataMockup = dataMockup + '<nomReclamante>Juan Perez</nomReclamante>';
        dataMockup = dataMockup + '<idReclamacion>REC123</idReclamacion>';
        dataMockup = dataMockup + '<prodReclamaN2>Prod2</prodReclamaN2>';
        dataMockup = dataMockup + '<prodReclamaN3>Prod3</prodReclamaN3>';
        dataMockup = dataMockup + '<motivoReclamN2>Motivo 2</motivoReclamN2>';
        dataMockup = dataMockup + '<tieneRectificacion>N</tieneRectificacion>';
        dataMockup = dataMockup + '<empresaProcede>8221</empresaProcede>';
        dataMockup = dataMockup + '<migrada>S</migrada>';
        dataMockup = dataMockup + '<activa>S</activa>';
        dataMockup = dataMockup + '<fechaRecepcion>20231121</fechaRecepcion>';
        dataMockup = dataMockup + '<fechaVencimiento>20231201</fechaVencimiento>';
        dataMockup = dataMockup + '<descProdReclamN1>Descripción Producto 1</descProdReclamN1>';
        dataMockup = dataMockup + '<descProdReclamN2>Descripción Producto 2</descProdReclamN2>';
        dataMockup = dataMockup + '<descProdReclamN3>Descripción Producto 3</descProdReclamN3>';
        dataMockup = dataMockup + '<descMotivoReclamN1>Descripción Motivo 1</descMotivoReclamN1>';
        dataMockup = dataMockup + '<descMotivoReclamN2>Descripción Motivo 2</descMotivoReclamN2>';
        dataMockup = dataMockup + '<pdteResp>N</pdteResp>';
        dataMockup = dataMockup + '<pdteRevisarResp>S</pdteRevisarResp>';
        dataMockup = dataMockup + '<idTipo>TIPO123</idTipo>';
        dataMockup = dataMockup + '<reclActiva>S</reclActiva>';
        dataMockup = dataMockup + '<esProrroga>N</esProrroga>';
        dataMockup = dataMockup + '</listaResultado>';
        
        dataMockup = dataMockup + '</BeanBodyBusquedaReclamOut>';
        dataMockup = dataMockup + '</return>';
        dataMockup = dataMockup + '</soapenv:Body>';
        dataMockup = dataMockup + '</soapenv:Envelope>';
        return dataMockup;
    }
    /**
	* @description Generate the response for the mockup data
	*/
    private static HTTPResponse getDataMockup(String dataMockup){
        
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf('200'));
        res.setStatus('OK');
        res.setBody(dataMockup);
        return res;
    }
    
   /**
    * @description Convertir en objeto el json de la response
    */
    /*private static Object getBodyResponse(String response, String clazzName){
    Object result = parseJsonToObject(response, clazzName);
    return result;
    }*/
    
    /**
    * @description Convertir en objeto el json de la response
    */
    /*private static Object parseJsonToObject(String jsonData, String jsonType){
    Type typeClass = Type.forName(jsonType);
    return System.JSON.deserializeStrict(jsonData, typeClass);
    }*/
}