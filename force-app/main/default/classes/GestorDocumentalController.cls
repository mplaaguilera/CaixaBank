public with sharing class GestorDocumentalController {
  @AuraEnabled
    public static void generaDocumento(String recordId, String docId,String idioma, String sexo, String cambioficina, String faltaentrega, String espera, 
    Boolean contactocliente, Boolean allinone, Boolean irrespetuoso, String fraude, String movimientoCuenta, Boolean usuarioNow, String cuentaminombre,
    String respuestacliente, String contestarrespuestacliente, String bloqueoretencionsaldo, Boolean solicitudcancelacionseguro, Boolean solicitudtestamentaria,
    String solicitud, String solicitudDocumentacion, String informaciondocumentacionadicional, String helloletter, String codigoprestamo, Date fechafinalcalculo,
    Boolean cuadroamortizacion, Boolean partedocumentacion, Boolean documentacionadicional, Boolean documentacionnolocalizada,
    String detalleinformacionenviar, Map<String, Boolean> camposBoleanos,  Map<String, String> camposTexto
    ) {  
        if (docId != null && docId != ''){
            CC_Gestor_Documental__c genDoc = new CC_Gestor_Documental__c();
            genDoc.Id = docId;
            genDoc.CC_Case__c = recordId;
            genDoc.CC_Idioma__c = idioma;
            genDoc.CC_Sexo__c = sexo;
            genDoc.CC_Cambio_Oficina__c = cambioficina;
            genDoc.CC_Intervencion_Fuerzas_Seguridad__c = camposBoleanos.get('intervencionFuerzasSeguridad');
            genDoc.CC_Falta_Entrega__c = faltaentrega;
            genDoc.CC_Contacto_Cliente__c = contactocliente;
            genDoc.CC_Tiempo_Espera__c = espera;
            genDoc.CC_Tono_Irrespetuoso__c = irrespetuoso;
            genDoc.CC_All_In_One__c = allinone;
            genDoc.CC_Fraude__c = fraude;
            genDoc.CC_Movimiento_En_Cuenta__c = movimientoCuenta;
            genDoc.CC_Usuario_Now__c = usuarioNow;
            genDoc.CC_Cuenta_A_Mi_Nombre__c = cuentaminombre;
            genDoc.CC_Respuesta_Cliente__c = respuestacliente;            
            genDoc.CC_Bloqueo_Retencion_Saldo__c = bloqueoretencionsaldo;
            genDoc.CC_Solicitud_Cancelacion_Seguro__c = solicitudcancelacionseguro;
            genDoc.CC_Solicitud_Testamentaria__c = solicitudtestamentaria;
            genDoc.CC_Contestar_Respuesta_Cliente__c = contestarrespuestacliente;            
            genDoc.CC_Solicitud__c = solicitud;
            genDoc.CC_Solicitud_Documentacion__c = solicitudDocumentacion;
            genDoc.CC_Informacion_Documentacion_Adicional__c = informaciondocumentacionadicional;
            genDoc.CC_Hello_Letter__c = helloletter;
            genDoc.CC_Codigo_Prestamo__c = codigoprestamo;
            genDoc.CC_Fecha_Final_Calculo__c = fechafinalcalculo;
            genDoc.CC_Cuadro_Amortizacion__c = cuadroamortizacion;
            genDoc.CC_Parte_Documentacion__c = partedocumentacion;
            genDoc.CC_Documentacion_Adicional__c = documentacionadicional;
            genDoc.CC_Documentacion_No_Localizada__c = documentacionnolocalizada;    
            genDoc.CC_Detalle_Informacion_Enviar__c = detalleinformacionenviar;  
            genDoc.CC_Documentacion_No_Localizada_Cliente__c = camposBoleanos.get('documentacionnolocalizadacliente');
            genDoc.CC_Tasacion_Inmueble_Hipotecado__c = camposBoleanos.get('tasacioninmueblehipotecado');
            genDoc.CC_Prestamo_Titulizado__c = camposBoleanos.get('prestamotitulizado');
            genDoc.CC_Prestamo_Vendido_Tercero__c = camposBoleanos.get('prestamovendidotercero');
            genDoc.CC_Solicitud_Facturas_Gastos__c = camposBoleanos.get('solicitudfacturasgastos');
            genDoc.CC_Contrato_Tarjeta_Cliente__c = camposBoleanos.get('contratotarjetacliente');
            genDoc.CC_Extractos_Liquidacion__c = camposBoleanos.get('extractosliquidacion');
            genDoc.CC_Copia_Parcial_Escritura__c = camposBoleanos.get('copiaparcialescritura');
            genDoc.CC_No_Localiza_Contrato_Cuenta__c = camposBoleanos.get('nolocalizacontratocuenta');
            genDoc.CC_Queja_Cobro_Tarifa_Telefonica__c = camposBoleanos.get('quejacobrotarifatelefonica');
            genDoc.CC_Solicitud_Info_Prestamo__c = camposBoleanos.get('solicitudinfoprestamo');
            genDoc.CC_Queja_Limpieza__c = camposBoleanos.get('quejalimpieza');
            genDoc.CC_Cierre_Recinto_Cajero__c = camposBoleanos.get('cierrerecintocajero');
            genDoc.CC_Queja_Persona_Sin_Hogar__c = camposBoleanos.get('quejapersonasinhogar');
            genDoc.CC_Solicitud_Informacion_Requisitos__c = camposBoleanos.get('solicitudinformacionrequisitos');
            genDoc.CC_Solicitud_Informacion_Aportar__c = camposBoleanos.get('solicitudinformacionaportar');
            genDoc.CC_Informacion_Condiciones_Financiacion__c = camposBoleanos.get('informacioncondicionesfinanciacion');
            genDoc.CC_Ofrecio_Soluciones_Refinanciacion__c = camposBoleanos.get('ofreciosolucionesrefinanciacion');
            genDoc.CC_Solicitud_Cancelacion_Contratos__c = camposBoleanos.get('solicitudcancelacioncontratos');

            genDoc.CC_Indicar_Gastos__c = camposTexto.get('indicargastos');

            update genDoc;
            System.debug(camposBoleanos.get('solicitudcancelacioncontratos'));

        } else {
            CC_Gestor_Documental__c genDoc = new CC_Gestor_Documental__c();
            genDoc.CC_Idioma__c = idioma;
            genDoc.CC_Case__c = recordId;
            genDoc.CC_Sexo__c = sexo;
            genDoc.CC_Cambio_Oficina__c = cambioficina;
            genDoc.CC_Falta_Entrega__c = faltaentrega;
            genDoc.CC_Intervencion_Fuerzas_Seguridad__c = camposBoleanos.get('intervencionFuerzasSeguridad');
            genDoc.CC_Contacto_Cliente__c = contactocliente;
            genDoc.CC_Tiempo_Espera__c = espera;
            genDoc.CC_Tono_Irrespetuoso__c = irrespetuoso;
            genDoc.CC_All_In_One__c = allinone;
            genDoc.CC_Fraude__c = fraude;
            genDoc.CC_Movimiento_En_Cuenta__c = movimientoCuenta;
            genDoc.CC_Usuario_Now__c = usuarioNow;
            genDoc.CC_Cuenta_A_Mi_Nombre__c = cuentaminombre;
            genDoc.CC_Respuesta_Cliente__c = respuestacliente;
            genDoc.CC_Bloqueo_Retencion_Saldo__c = bloqueoretencionsaldo;
            genDoc.CC_Solicitud_Cancelacion_Seguro__c = solicitudcancelacionseguro;
            genDoc.CC_Solicitud_Testamentaria__c = solicitudtestamentaria;
            genDoc.CC_Contestar_Respuesta_Cliente__c = contestarrespuestacliente;
            genDoc.CC_Solicitud__c = solicitud;
            genDoc.CC_Solicitud_Documentacion__c = solicitudDocumentacion;
            genDoc.CC_Informacion_Documentacion_Adicional__c = informaciondocumentacionadicional;
            genDoc.CC_Hello_Letter__c = helloletter;
            genDoc.CC_Codigo_Prestamo__c = codigoprestamo;
            genDoc.CC_Fecha_Final_Calculo__c = fechafinalcalculo;
            genDoc.CC_Cuadro_Amortizacion__c = cuadroamortizacion;
            genDoc.CC_Parte_Documentacion__c = partedocumentacion;
            genDoc.CC_Documentacion_Adicional__c = documentacionadicional;
            genDoc.CC_Documentacion_No_Localizada__c = documentacionnolocalizada;
            genDoc.CC_Detalle_Informacion_Enviar__c = detalleinformacionenviar;   
            genDoc.CC_Documentacion_No_Localizada_Cliente__c = camposBoleanos.get('documentacionnolocalizadacliente');
            genDoc.CC_Tasacion_Inmueble_Hipotecado__c = camposBoleanos.get('tasacioninmueblehipotecado');
            genDoc.CC_Prestamo_Titulizado__c = camposBoleanos.get('prestamotitulizado');
            genDoc.CC_Prestamo_Vendido_Tercero__c = camposBoleanos.get('prestamovendidotercero');
            genDoc.CC_Solicitud_Facturas_Gastos__c = camposBoleanos.get('solicitudfacturasgastos');
            genDoc.CC_Contrato_Tarjeta_Cliente__c = camposBoleanos.get('contratotarjetacliente');
            genDoc.CC_Extractos_Liquidacion__c = camposBoleanos.get('extractosliquidacion');
            genDoc.CC_Copia_Parcial_Escritura__c = camposBoleanos.get('copiaparcialescritura');
            genDoc.CC_No_Localiza_Contrato_Cuenta__c = camposBoleanos.get('nolocalizacontratocuenta');
            genDoc.CC_Queja_Cobro_Tarifa_Telefonica__c = camposBoleanos.get('quejacobrotarifatelefonica');
            genDoc.CC_Solicitud_Info_Prestamo__c = camposBoleanos.get('solicitudinfoprestamo');
            genDoc.CC_Queja_Limpieza__c = camposBoleanos.get('quejalimpieza');
            genDoc.CC_Cierre_Recinto_Cajero__c = camposBoleanos.get('cierrerecintocajero');
            genDoc.CC_Queja_Persona_Sin_Hogar__c = camposBoleanos.get('quejapersonasinhogar');
            genDoc.CC_Solicitud_Informacion_Requisitos__c = camposBoleanos.get('solicitudinformacionrequisitos');
            genDoc.CC_Solicitud_Informacion_Aportar__c = camposBoleanos.get('solicitudinformacionaportar');
            genDoc.CC_Informacion_Condiciones_Financiacion__c = camposBoleanos.get('informacioncondicionesfinanciacion');
            genDoc.CC_Ofrecio_Soluciones_Refinanciacion__c = camposBoleanos.get('ofreciosolucionesrefinanciacion');
            genDoc.CC_Solicitud_Cancelacion_Contratos__c = camposBoleanos.get('solicitudcancelacioncontratos');
            genDoc.CC_Indicar_Gastos__c = camposTexto.get('indicargastos');

            insert genDoc;

            Case oCaso = new Case();
            oCaso.Id = recordId;
            oCaso.CC_Gestor_Documental__c = genDoc.Id;
            update oCaso;
        }
    }

    @AuraEnabled
    public static List<SDOC__SDTemplate__c> obtenerPlantillas(String ids){
		List<String> res = ids.split(',');

        List<SDOC__SDTemplate__c> plantillaSDOC = [SELECT Id, Name, SDOC__Language__c FROM SDOC__SDTemplate__c WHERE Id IN :res];
        
        return plantillaSDOC;
    }

    /*
     *Método para recuperar valores configurados en LOV.
     */
	@AuraEnabled
    public static List<String> obtenerCamposPlantilla(List<String> plantillas){
        Map<String, String> oData = new Map<String, String>();
		String[] camposList = new List<String>();
        String oListData = '';

        if (plantillas == null)
            return camposList;

        if (plantillas.isEmpty())
            return camposList;

        List<CC_Lista_Valores__c> oLista = [SELECT Id, Name, RecordTypeId, CC_Activa__c, CC_Campos_SDocs__c, CC_Lista__r.Name 
                            FROM CC_Lista_Valores__c 
                            WHERE CC_Lista__r.Name = 'Plantillas SDocs' AND Name IN :plantillas AND CC_Activa__c = true];
        
        if(!oLista.isEmpty()){
            for (CC_Lista_Valores__c oVal : oLista){
                if (oData.get(oVal.Name) == null){
                    oData.put(oVal.Name, oVal.CC_Campos_SDocs__c);
                    if (oListData == ''){
                        oListData = oVal.CC_Campos_SDocs__c;
                    } else {
                        oListData = oListData + ';' + oVal.CC_Campos_SDocs__c;
                    }
                    camposList = oListData?.split(';');
                }
        	}
        }		

        return camposList;
    }
    
    
}