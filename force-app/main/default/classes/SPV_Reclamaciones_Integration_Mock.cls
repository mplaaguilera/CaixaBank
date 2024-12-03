@isTest
global with sharing class SPV_Reclamaciones_Integration_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        String sRespuesta = '';
        sRespuesta = sRespuesta + '<?xml version="1.0"?>';
        sRespuesta = sRespuesta + '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:atr="https://extcaastb1.lacaixa.es/AttReclamacionesBusquedaReclamac/v1/BusquedaReclamac142/busquedaReclam/">';
        sRespuesta = sRespuesta + '<soapenv:Header/>';
        sRespuesta = sRespuesta + '<soapenv:Body>';
        sRespuesta = sRespuesta + '<return>';
        sRespuesta = sRespuesta + '<BeanBodyBusquedaReclamOut>';
        sRespuesta = sRespuesta + '<listaResultado>';
        sRespuesta = sRespuesta + '<expedienteReclamacion>EXP123</expedienteReclamacion>';
        sRespuesta = sRespuesta + '<estado>En proceso</estado>';
        sRespuesta = sRespuesta + '<usuario>User123</usuario>';
        sRespuesta = sRespuesta + '<nombreUsuario>Juan Perez</nombreUsuario>';
        sRespuesta = sRespuesta + '<orgProcedencia>Org X</orgProcedencia>';
        sRespuesta = sRespuesta + '<grupo>Grupo 1</grupo>';
        sRespuesta = sRespuesta + '<prodReclamN1>Prod1</prodReclamN1>';
        sRespuesta = sRespuesta + '<motivoReclamN1>Motivo 1</motivoReclamN1>';
        sRespuesta = sRespuesta + '<numDocReclamante>12345678X</numDocReclamante>';
        sRespuesta = sRespuesta + '<nomReclamante>Juan Perez</nomReclamante>';
        sRespuesta = sRespuesta + '<idReclamacion>REC123</idReclamacion>';
        sRespuesta = sRespuesta + '<prodReclamaN2>Prod2</prodReclamaN2>';
        sRespuesta = sRespuesta + '<prodReclamaN3>Prod3</prodReclamaN3>';
        sRespuesta = sRespuesta + '<motivoReclamN2>Motivo 2</motivoReclamN2>';
        sRespuesta = sRespuesta + '<tieneRectificacion>N</tieneRectificacion>';
        sRespuesta = sRespuesta + '<empresaProcede>Empresa XYZ</empresaProcede>';
        sRespuesta = sRespuesta + '<migrada>S</migrada>';
        sRespuesta = sRespuesta + '<activa>S</activa>';
        sRespuesta = sRespuesta + '<fechaRecepcion>20231121</fechaRecepcion>';
        sRespuesta = sRespuesta + '<fechaVencimiento>20231201</fechaVencimiento>';
        sRespuesta = sRespuesta + '<descProdReclamN1>Descripción Producto 1</descProdReclamN1>';
        sRespuesta = sRespuesta + '<descProdReclamN2>Descripción Producto 2</descProdReclamN2>';
        sRespuesta = sRespuesta + '<descProdReclamN3>Descripción Producto 3</descProdReclamN3>';
        sRespuesta = sRespuesta + '<descMotivoReclamN1>Descripción Motivo 1</descMotivoReclamN1>';
        sRespuesta = sRespuesta + '<descMotivoReclamN2>Descripción Motivo 2</descMotivoReclamN2>';
        sRespuesta = sRespuesta + '<pdteResp>N</pdteResp>';
        sRespuesta = sRespuesta + '<pdteRevisarResp>S</pdteRevisarResp>';
        sRespuesta = sRespuesta + '<idTipo>TIPO123</idTipo>';
        sRespuesta = sRespuesta + '<reclActiva>S</reclActiva>';
        sRespuesta = sRespuesta + '<esProrroga>N</esProrroga>';
        sRespuesta = sRespuesta + '</listaResultado>';
        sRespuesta = sRespuesta + '</BeanBodyBusquedaReclamOut>';
        sRespuesta = sRespuesta + '</return>';
        sRespuesta = sRespuesta + '</soapenv:Body>';
        sRespuesta = sRespuesta + '</soapenv:Envelope>';
        
        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
    
    /*
        sRespuesta = sRespuesta + '<tipoReclamacion>Producto</tipoReclamacion>';
        sRespuesta = sRespuesta + '<fechaRecepcion>20231121</fechaRecepcion>';
        sRespuesta = sRespuesta + '<esProrroga>N</esProrroga>';
        sRespuesta = sRespuesta + '<fechaVencimiento>20231201</fechaVencimiento>';
        sRespuesta = sRespuesta + '<prodReclamN1>Prod1</prodReclamN1>';
        sRespuesta = sRespuesta + '<prodReclamN2>Prod2</prodReclamN2>';
        sRespuesta = sRespuesta + '<prodReclamN3>Prod3</prodReclamN3>';
        sRespuesta = sRespuesta + '<motivoReclamN1>Motivo 1</motivoReclamN1>';
        sRespuesta = sRespuesta + '<motivoReclamN2>Motivo 2</motivoReclamN2>';
        sRespuesta = sRespuesta + '<oficinaReclamada>Oficina Central</oficinaReclamada>';
        sRespuesta = sRespuesta + '<empresaReclamacion>Empresa XYZ</empresaReclamacion>';
        sRespuesta = sRespuesta + '<idInstancia>INST123</idInstancia>';
        sRespuesta = sRespuesta + '<listaReclamante>';
        sRespuesta = sRespuesta + '<nomReclamante>Juan Perez</nomReclamante>';
        sRespuesta = sRespuesta + '<tipoDocReclamanteN>DNI</tipoDocReclamanteN>';
        sRespuesta = sRespuesta + '<numDocReclamanteN>12345678X</numDocReclamanteN>';
        sRespuesta = sRespuesta + '<reclamanteDomicilioFiscal>Calle Falsa 123, Madrid</reclamanteDomicilioFiscal>';
        sRespuesta = sRespuesta + '</listaReclamante>';
        sRespuesta = sRespuesta + '<letradoAsignado>Letrado 1</letradoAsignado>';
        sRespuesta = sRespuesta + '<resultado>Pendiente</resultado>';
        sRespuesta = sRespuesta + '<faseActual>Fase 1</faseActual>';
        sRespuesta = sRespuesta + '<descFaseActual>En proceso</descFaseActual>';
        sRespuesta = sRespuesta + '<idOrganismo>ORG123</idOrganismo>';
        sRespuesta = sRespuesta + '<expediente>EXP123</expediente>';
        sRespuesta = sRespuesta + '<usuario>User123</usuario>';
        sRespuesta = sRespuesta + '<nomUsuario>Juan Perez</nomUsuario>';
        sRespuesta = sRespuesta + '<fechaVencProrroga>20231205</fechaVencProrroga>';
        sRespuesta = sRespuesta + '<esNueva>Y</esNueva>';
        sRespuesta = sRespuesta + '<beanRespuesta>';
        sRespuesta = sRespuesta + '<fechaAlta>20231121</fechaAlta>';
        sRespuesta = sRespuesta + '<grupo>Grupo 1</grupo>';
        sRespuesta = sRespuesta + '<idReclamacion>REC123</idReclamacion>';
        sRespuesta = sRespuesta + '<idRespuesta>RESP456</idRespuesta>';
        sRespuesta = sRespuesta + '<usuarioAlta>UsuarioTest</usuarioAlta>';
        sRespuesta = sRespuesta + '</beanRespuesta>';
        sRespuesta = sRespuesta + '<idReclamacion>REC123</idReclamacion>';
        sRespuesta = sRespuesta + '<resolucionPrevia>Resolucion X</resolucionPrevia>';
        sRespuesta = sRespuesta + '<grupo>Grupo 1</grupo>';
        sRespuesta = sRespuesta + '<tieneRectificacion>N</tieneRectificacion>';
        sRespuesta = sRespuesta + '<fechaIniRegulador>20231101</fechaIniRegulador>';
        sRespuesta = sRespuesta + '<fechaAlta>20231121</fechaAlta>';
        */
}