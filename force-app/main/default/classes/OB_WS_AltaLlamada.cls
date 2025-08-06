@RestResource(urlMapping='/AltaLlamadaOutbound/*')
global with sharing class OB_WS_AltaLlamada {

    @HttpPost
    global static String altaLlamadaOutbound() {
        //Serializar XML de la solicitud
        Dom.Document entradaDoc = new Dom.Document();
        String xmlEntrada = RestContext.request.requestBody.toString();
        entradaDoc.load(xmlEntrada);
        return altaLlamadaOutbound(mapaCamposXmlEntrada(entradaDoc.getRootElement()), xmlEntrada);
    }

    public class Peticion {
        public Map<String, String> camposXml;
        public String xmlEntrada;
        public String resultado;
    }

    public static void altaLlamadaOutbound(List<Peticion> peticiones) {
        for (Peticion peticion : peticiones) {
            peticion.resultado = altaLlamadaOutbound(peticion.camposXml, peticion.xmlEntrada);
        }
    }

    public static String altaLlamadaOutbound(Map<String, String> camposXml, String xmlEntrada) {
        String mensajeEntrada = String.isNotBlank(xmlEntrada) ? xmlEntrada : JSON.serialize(camposXml);
        CC_TrazaInt__c traza = CC_TrazaInt.inicioTraza('OB_WS_AltaLlamada', 'Genesys', camposXml.get('IdPeticion'), mensajeEntrada);
        Map<String, String> respuesta = new Map<String, String>{'codigoError' => '', 'detalleError' => '', 'llamadaId' => ''};
        Set<String> mensajesError = new Set<String>(); //Acumula los errores a devolver
        Map<String, Object> camposLlamada = new Map<String, Object>();

        try {
            respuesta.put('IdPeticion', camposXml.get('IdPeticion'));

            //Lógica de alta o de cierre
            String tipoMovimiento = camposXml.get('TipoMovimiento');
            if (tipoMovimiento == 'Alta') {
                respuesta.put('llamadaId', alta(camposXml, mensajeEntrada, camposLlamada, mensajesError));
            } else if (tipoMovimiento == 'Cierre') {
                respuesta.put('llamadaId', cierre(camposXml, mensajeEntrada, camposLlamada, mensajesError));
            } else {
                mensajesError.add('TipoMovimiento debe ser "Alta" o "Cierre"');
            }
        } catch (Exception e) {
            respuesta.put('codigoError', e.getCause() != null ? String.valueOf(e.getCause()) : '');
            mensajesError.add('ExceptionType: ' + e.getTypeName() + ' - ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.'));
            CBK_Log.error(e);
        }

        String detalleError = detalleError(mensajesError);
        String xmlRespuesta = serializarRespuesta(respuesta, detalleError);
        if (mensajesError.isEmpty()) {
            //Fin traza OK
            CC_TrazaInt.finTraza(traza, xmlRespuesta);
        } else {
            //Fin traza KO
            CC_TrazaInt.finTraza(traza, xmlRespuesta, respuesta.get('codigoError'), detalleError);
        }
        return xmlRespuesta;
    }

    private static String alta(Map<String, String> camposXml, String mensajeEntrada, Map<String, Object> camposLlamada, Set<String> mensajesError) {

        String nombreLlamada = ''; //Retorno
        try {
            //NumeroSR
            if (String.isNotBlank(camposXml.get('NumeroSR')) && camposXml.get('TipoMovimiento') == 'Alta') {
                mensajesError.add('No aplica informar NumeroSR en Alta');
            }

            //CodigoCampana
            String codigoCampanya = camposXml.get('CodigoCampana');
            if (String.isBlank(codigoCampanya)) {
                mensajesError.add('CodigoCampana obligatorio');
            } else {
                //La Campaña debe corresponderse con un valor de Campaña activa (primero se busca una que no sea multimes
                //que coincida con el mismo código y si no se encuentra se busca una multimes a partir de los tres primeros
                //caracteres). En caso contrario se devuelve "CodigoCampana informado con un valor no coherente"
                Id idCampanya = null;
                for (OB_Parametrizacion__c campanya : [SELECT OB_Codigo_Externo__c, OB_Multimes__c FROM OB_Parametrizacion__c
                                                        WHERE RecordType.DeveloperName = 'OB_Campanya'
                                                        AND OB_Activo__c = TRUE ORDER BY OB_Multimes__c]) {
                    if (!campanya.OB_Multimes__c && campanya.OB_Codigo_Externo__c == codigoCampanya
                    || campanya.OB_Multimes__c && campanya.OB_Codigo_Externo__c == codigoCampanya.substring(0, 3)) {
                        idCampanya = campanya.Id;
                        break;
                    }
                }
                if (idCampanya == null) {
                    mensajesError.add('CodigoCampana informado con un valor no coherente');
                } else {
                    camposLlamada.put('OB_Campanya_Id__c', idCampanya);
                }
            }

            //CodigoProducto
            OB_Parametrizacion__c relacionCampanyaProducto = new OB_Parametrizacion__c();
            if (String.isBlank(camposXml.get('CodigoProducto'))) {
                mensajesError.add('CodigoProducto obligatorio');
            } else {
                //El Código de Producto debe corresponderse con un valor de Producto activo
                List<OB_Parametrizacion__c> productos = [SELECT Id FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Producto'
                                                            AND OB_Codigo_Externo__c = :camposXml.get('CodigoProducto') AND OB_Activo__c = TRUE LIMIT 1];
                if (productos.isEmpty()) {
                    mensajesError.add('CodigoProducto informado con un valor no coherente');
                } else {
                    //El Producto informado debe estar asociado a la Campaña informada.
                    List<OB_Parametrizacion__c> campanyasProductos = [SELECT OB_Tipo_Validacion__c FROM OB_Parametrizacion__c
                                                                        WHERE RecordType.DeveloperName = 'OB_Relacion_Campanya_Producto'
                                                                        AND OB_Parametrizacion_Padre__c = :String.valueOf(camposLlamada.get('OB_Campanya_Id__c'))
                                                                        AND OB_Parametrizacion_Relacionada__r.OB_Codigo_Externo__c = :camposXml.get('CodigoProducto') LIMIT 1];
                    if (campanyasProductos.isEmpty()) {
                        mensajesError.add('CodigoProducto no coherente con Campaña');
                    } else {
                        relacionCampanyaProducto = campanyasProductos[0];
                        camposLlamada.put('OB_Producto_Id__c', productos[0].Id);
                    }
                }
            }

            //NUMPERSO
            if (String.isBlank(camposXml.get('NumPerso'))) {
                mensajesError.add('NumPerso obligatorio');
            } else if (!camposXml.get('NumPerso').isNumeric()) {
                mensajesError.add('NUMPERSO debe ser numérico');
            } else {
                camposXml.put('NumPerso', camposXml.get('NumPerso').replaceFirst('^0+', ''));
                camposLlamada.put('CC_NumPerso__c', camposXml.get('NumPerso').left(15));
            }

            //NifCliente
            if (String.isBlank(camposXml.get('NifCliente'))) {
                mensajesError.add('NifCliente obligatorio');
            }

            //NombreCliente
            if (String.isBlank(camposXml.get('NombreCliente'))) {
                mensajesError.add('NombreCliente obligatorio');
            }

            //Apellido1Cliente
            if (String.isBlank(camposXml.get('Apellido1Cliente'))) {
                mensajesError.add('Apellido1Cliente obligatorio');
            }

            //TelefonoSR
            if (String.isNotBlank(camposXml.get('TelefonoSR')) && numeroTelefonoValido(camposXml.get('TelefonoSR'))) {
                camposLlamada.put('OB_Telefono__c', camposXml.get('TelefonoSR'));
            }

            //EmailSR
            if (String.isNotBlank(camposXml.get('EmailSR')) && direccionCorreoValida(camposXml.get('EmailSR'))) {
                camposLlamada.put('OB_Direccion_Correo__c', camposXml.get('EmailSR'));
            }

            //Idioma
            if (String.isBlank(camposXml.get('Idioma'))) {
                mensajesError.add('Idioma obligatorio');
            } else {
                String idioma = CC_Listas_Valores.lookupValue('Outbound: Conversión del atributo "Idioma"', camposXml.get('Idioma'));
                if (String.isBlank(idioma)) {
                    mensajesError.add('Idioma con valor no coherente');
                } else {
                    camposLlamada.put('CC_Idioma__c', idioma);
                }
            }

            //Plataforma
            OB_Parametrizacion__c plataforma = new OB_Parametrizacion__c();
            if (String.isBlank(camposXml.get('Plataforma'))) {
                mensajesError.add('Plataforma obligatorio');
            } else {
                List<OB_Parametrizacion__c> plataformas = [SELECT Name, OB_Centro_Gestor__c, OB_Usuario_Salesforce_Login__c
                                                            FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Plataforma'
                                                            AND OB_Activo__c = TRUE AND OB_Codigo_Externo__c = :camposXml.get('Plataforma') LIMIT 1];
                if (plataformas.isEmpty()) {
                    mensajesError.add('Plataforma informada con un valor no coherente');
                } else {
                    plataforma = plataformas[0];
                    camposLlamada.put('OB_Plataforma__c', plataforma.Name);
                }
            }

            //CentroGestor
            /*
            if (String.isNotBlank(camposXml.get('CentroGestor'))) {
                camposLlamada.put('OB_Centro_Gestor__c', camposXml.get('CentroGestor'));
            } else if (String.isNotBlank(plataforma.OB_Centro_Gestor__c)) {
                camposLlamada.put('OB_Centro_Gestor__c', plataforma.OB_Centro_Gestor__c);
            }
            */
            camposLlamada.put('OB_Centro_Gestor__c', plataforma.OB_Centro_Gestor__c);

            //UsuarioGestor
            if (String.isNotBlank(camposXml.get('UsuarioGestor'))) {
                camposLlamada.put('OB_Usuario_Gestor__c', camposXml.get('UsuarioGestor'));
            } else if (String.isNotBlank(plataforma.OB_Usuario_Salesforce_Login__c)) {
                camposLlamada.put('OB_Usuario_Gestor__c', plataforma.OB_Usuario_Salesforce_Login__c);
            }

            //Agente
            if (String.isBlank(camposXml.get('Agente'))) {
                mensajesError.add('Agente obligatorio');
            } else if (camposXml.get('Agente').length() > 7) {
                mensajesError.add('Agente debe contener hasta 7 caracteres');
            } else {
                camposLlamada.put('CC_Agente__c', camposXml.get('Agente'));
            }

            //ResultadoNivel2
            if (String.isNotBlank(camposXml.get('ResultadoNivel2'))) {
                camposLlamada.put('OB_Resultado_Nivel_2__c', camposXml.get('ResultadoNivel2').left(50));
            }

            //DatosAdicionales
            if (String.isNotBlank(camposXml.get('DatosAdicionales'))) {
                camposLlamada.put('OB_Datos_Adicionales__c', camposXml.get('DatosAdicionales').left(100));
            }

            //ConnId
            camposLlamada.put('CC_ConnId__c', camposXml.get('ConnId'));

            //Extension
            camposLlamada.put('CC_Extension__c', camposXml.get('Extension'));

            //FechaLlamada y HoraLlamada
            camposLlamada.put('CC_Fecha_Inicio__c', convertirFechaHora(camposXml.get('FechaLlamada'), camposXml.get('HoraLlamada')));

        } catch (Exception e) {
            mensajesError.add('ExceptionType: ' + e.getTypeName() + ' - ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.'));
            CBK_Log.error(e);

        } finally {
            //Identificación del cliente
            Contact contactoIdentificado = identificarCliente(camposXml);
            camposLlamada.put('CC_Cuenta__c', contactoIdentificado.AccountId);
            camposLlamada.put('CC_Contacto__c', contactoIdentificado.Id);

            if (!mensajesError.isEmpty()) {
                camposLlamada.put('OB_Estado__c', 'OB_Error');
                camposLlamada.put('OB_Descripcion_Error__c', String.join(new List<String>(mensajesError), '\n'));
            }

            //Creación de la llamada
            CC_Llamada__c llamada = OB_Llamada.crearLlamada('OB_Cliente', camposLlamada);

            //Creación de la tarea
            Map<String, Object> camposTareaAlta = new Map<String, Object>();
            camposTareaAlta.put('Type', 'Alta');
            camposTareaAlta.put('Subject', 'Alta');
            camposTareaAlta.put('Status', 'Completed');
            camposTareaAlta.put('Description', mensajeEntrada);
            OB_Activity.crearActividad(llamada.Id, camposTareaAlta);

            if (!mensajesError.isEmpty()) {
                Map<String, Object> camposTareaError = new Map<String, Object>();
                camposTareaError.put('Type', 'Error');
                camposTareaError.put('Subject', 'Error en Alta');
                camposTareaError.put('Status', 'Completed');
                camposTareaError.put('Description', String.join(new List<String>(mensajesError), '\n'));
                OB_Activity.crearActividad(llamada.Id, camposTareaError);
            }

            nombreLlamada = [SELECT Name FROM CC_Llamada__c WHERE Id = :llamada.Id].Name;
            camposXml.put('NumeroSR', nombreLlamada); //Por si el alta se llama dentro del cierre
        }
        return nombreLlamada;
    }

    private static String cierre(Map<String, String> camposXml, String mensajeEntrada, Map<String, Object> camposLlamada, Set<String> mensajesError) {

        CC_Llamada__c llamada = new CC_Llamada__c();
        String nombrePlantillaSms;
        String nombrePlantillaCorreo;

        try {
            camposLlamada.put('CC_Fecha_Fin__c', System.now());

            //NumeroSR
            if (String.isBlank(camposXml.get('NumeroSR'))) {
                alta(camposXml, mensajeEntrada, camposLlamada, mensajesError); //Se realiza el alta antes de continuar con el cierre
            }

            if (String.isNotBlank(camposXml.get('NumeroSR'))) {
                List<CC_Llamada__c> llamadas = [SELECT Name, OB_Campanya_Id__r.OB_Codigo_Externo__c, OB_Producto_Id__r.Name FROM CC_Llamada__c
                                                WHERE Name = :camposXml.get('NumeroSR') AND RecordType.DeveloperName = 'OB_Cliente'];
                if (llamadas.isEmpty()) {
                    alta(camposXml, mensajeEntrada, camposLlamada, mensajesError); //Se realiza el alta antes de continuar con el cierre
                    llamada = [SELECT Name, OB_Campanya_Id__r.OB_Codigo_Externo__c, OB_Producto_Id__r.Name FROM CC_Llamada__c
                                WHERE Name = :camposXml.get('NumeroSR') AND RecordType.DeveloperName = 'OB_Cliente'];
                } else {
                    llamada = llamadas[0];
                }
            }

            //ResultadoCierre
            OB_Parametrizacion__c resultadoCierre = new OB_Parametrizacion__c();
            if (String.isBlank(camposXml.get('ResultadoCierre'))) {
                mensajesError.add('ResultadoCierre obligatorio');
            } else {
                List<OB_Parametrizacion__c> resultadosCierre = [SELECT OB_Tipo_Cierre__c, OB_Tipo_Contratacion__c FROM OB_Parametrizacion__c WHERE OB_Activo__c = TRUE
                                                                AND RecordType.DeveloperName = 'OB_Resultado_Cierre' AND Name = :camposXml.get('ResultadoCierre')
                                                                AND OB_Tipo_Cierre__c IN ('POSITIVO', 'NEGATIVO') LIMIT 1];
                if (!resultadosCierre.isEmpty()) {
                    resultadoCierre = resultadosCierre[0];
                    camposLlamada.put('OB_Resultado_Cierre__c', resultadoCierre.Id);

                    if (resultadoCierre.OB_Tipo_Cierre__c == 'POSITIVO') {
                        camposLlamada.put('OB_Estado__c', 'OB_Pendiente_Grabacion');
                    } else if (resultadoCierre.OB_Tipo_Cierre__c == 'NEGATIVO') {
                        camposLlamada.put('OB_Estado__c', 'OB_Rechazada');
                    }
                } else {
                    mensajesError.add('ResultadoCierre asociado a valor no coherente');
                }
            }

            //CodigoCampana
            Id idCampanya = null;
            String codigoCampanya = camposXml.get('CodigoCampana');
            if (String.isBlank(codigoCampanya)) {
                mensajesError.add('CodigoCampana obligatorio');
            } else {
                //La Campaña debe corresponderse con un valor de Campaña activa (primero se busca una que no sea multimes
                //que coincida con el mismo código y si no se encuentra se busca una multimes a partir de los tres primeros
                //caracteres). En caso contrario se devuelve "CodigoCampana informado con un valor no coherente"
                for (OB_Parametrizacion__c campanya : [SELECT OB_Codigo_Externo__c, OB_Multimes__c FROM OB_Parametrizacion__c
                                                        WHERE RecordType.DeveloperName = 'OB_Campanya'
                                                        AND OB_Activo__c = TRUE ORDER BY OB_Multimes__c]) {
                    if (!campanya.OB_Multimes__c && campanya.OB_Codigo_Externo__c == codigoCampanya
                    || campanya.OB_Multimes__c && campanya.OB_Codigo_Externo__c == codigoCampanya.substring(0, 3)) {
                        idCampanya = campanya.Id;
                        break;
                    }
                }
                if (idCampanya == null) {
                    mensajesError.add('CodigoCampana informado con un valor no coherente');
                }
            }

            //CodigoProducto
            OB_Parametrizacion__c campanyaProducto;
            String formatoCodigoContrato;
            String codigoProducto = String.isNotBlank(camposXml.get('CodigoProducto')) ? camposXml.get('CodigoProducto') : llamada.OB_Producto_Id__r.OB_Codigo_Externo__c;
            List<OB_Parametrizacion__c> productos = [SELECT OB_Parametrizacion_Padre__r.OB_Formato_Codigo_Contrato__c FROM OB_Parametrizacion__c
                                                        WHERE RecordType.DeveloperName = 'OB_Producto' AND OB_Activo__c = TRUE AND OB_Codigo_Externo__c = :codigoProducto LIMIT 1];
            if (productos.isEmpty()) {
                mensajesError.add('CodigoProducto informado con un valor no coherente');
            } else {
                formatoCodigoContrato = productos[0].OB_Parametrizacion_Padre__r.OB_Formato_Codigo_Contrato__c;

                //Se valida que exista una relación Campaña - Producto (bien el Producto informado o el que había previamente en la SR)
                List<OB_Parametrizacion__c> campanyasProducto = [SELECT OB_Agrupador_Plantillas__c, OB_Agrupador_Plantillas__r.Name
                                                                    FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Relacion_Campanya_Producto'
                                                                    AND OB_Parametrizacion_Padre__c = :idCampanya
                                                                    AND OB_Parametrizacion_Relacionada__r.OB_Codigo_Externo__c = :codigoProducto LIMIT 1];
                if (!campanyasProducto.isEmpty()) {
                    campanyaProducto = campanyasProducto[0];
                } else {
                    mensajesError.add('La Campaña-Producto no permite ' + resultadoCierre.OB_Tipo_Contratacion__c);
                }
            }

            //CodContrato
            String codigoContrato = camposXml.get('CodContrato');
            if (String.isNotBlank(codigoContrato)) {
                if (String.isBlank(formatoCodigoContrato) || !codigoContratoValido(codigoContrato, formatoCodigoContrato)) {
                    mensajesError.add('CodContrato con formato incorrecto. El formato para esta familia de producto debe ser ' + formatoCodigoContrato);
                } else {
                    camposLlamada.put('OB_Codigo_Contrato__c', codigoContrato);
                    if (codigoContrato.containsOnly('0.')) {
                        camposLlamada.put('OB_No_Quiere_Telemarketing__c', true);
                        camposLlamada.put('OB_Estado__c', 'OB_Pendiente_Grabacion');
                    }
                }
            }

            //Agente
            if (String.isNotBlank(camposXml.get('Agente'))) {
                if (camposXml.get('Agente').length() <= 7) {
                    camposLlamada.put('CC_Agente__c', camposXml.get('Agente'));
                } else {
                    mensajesError.add('Agente debe contener hasta 7 caracteres');
                }
            }

            //ConnId
            if (String.isBlank(camposXml.get('ConnId'))) {
                mensajesError.add('ConnId obligatorio');
            } else {
                camposLlamada.put('CC_ConnId__c', camposXml.get('ConnId'));
            }

            //Extension
            if (String.isBlank(camposXml.get('Extension'))) {
                mensajesError.add('Extension obligatorio');
            } else {
                camposLlamada.put('CC_Extension__c', camposXml.get('Extension'));
            }

            //FechaLlamada y HoraLlamada
            camposLlamada.put('CC_Fecha_Inicio__c', convertirFechaHora(camposXml.get('FechaLlamada'), camposXml.get('HoraLlamada')));

            //ResultadoNivel2
            if (String.isNotBlank(camposXml.get('ResultadoNivel2'))) {
                camposLlamada.put('OB_Resultado_Nivel_2__c', camposXml.get('ResultadoNivel2').left(50));
            }

            //DatosAdicionales
            if (String.isNotBlank(camposXml.get('DatosAdicionales'))) {
                camposLlamada.put('OB_Datos_Adicionales__c', camposXml.get('DatosAdicionales').left(100));
            }

            //TelefonoSMS
            if (String.isBlank(camposXml.get('TelefonoSMS'))) {
                if (camposXml.get('EnviarSMS') == 'Y') {
                    mensajesError.add('TelefonoSMS obligatorio'); //Si no se envía SMS no es requerido
                }
            } else if (!numeroTelefonoValido(camposXml.get('TelefonoSMS'))) {
                mensajesError.add('TelefonosSMS informado con valor incoherente');
            } else {
                camposLlamada.put('OB_Telefono__c', camposXml.get('TelefonoSMS'));
            }

            //Agrupador de plantillas específica para visitas a oficina (se coge el agrupador del mismo producto pero con sufijo 'OF')
            if (camposLlamada.get('OB_Resultado_Nivel_2__c') == '100') { //100 indica visita a oficina
                List<OB_Parametrizacion__c> campanyasProductosAux = [SELECT OB_Agrupador_Plantillas__c, OB_Agrupador_Plantillas__r.Name
                                                                        FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Relacion_Campanya_Producto'
                                                                        AND OB_Agrupador_Plantillas__r.OB_Activo__c = TRUE
                                                                        AND OB_Parametrizacion_Padre__c = :idCampanya
                                                                        AND OB_Parametrizacion_Relacionada__r.OB_Codigo_Externo__c = :(codigoProducto + 'OF') LIMIT 1];
                if (!campanyasProductosAux.isEmpty()) {
                    campanyaProducto = campanyasProductosAux[0];
                }
            }

            //EnviarSMS
            if (camposXml.get('EnviarSMS') == 'Y' && camposLlamada.containsKey('OB_Telefono__c')) {
                if (String.isBlank(campanyaProducto.OB_Agrupador_Plantillas__c)) {
                    mensajesError.add('No existe plantilla SMS asociada para este Producto-Campaña');
                } else {
                    List<OB_Parametrizacion__c> agrupadoresPlantillas = [SELECT OB_Plantilla_SMS_Defecto__c FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Agrupador_Plantillas'
                                                                            AND Id = :campanyaProducto.OB_Agrupador_Plantillas__c AND OB_Activo__c = TRUE];
                    if (agrupadoresPlantillas.isEmpty()) {
                        mensajesError.add('No existe plantilla SMS asociada para este Producto-Campaña');
                    } else if (String.isBlank(agrupadoresPlantillas[0].OB_Plantilla_SMS_Defecto__c)) {
                        mensajesError.add('La Plantilla asociada no permite envío de SMS');
                    } else {
                        String idiomaPlantilla = CC_Listas_Valores.lookupValue('Outbound: Conversión del atributo "Idioma"', camposXml.get('Idioma'), 'CC_Valor2__c');
                        List<OB_Parametrizacion__c> plantillas = [SELECT OB_Plantilla__c FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Plantilla_Tipo_Idioma'
                                                                    AND OB_Parametrizacion_Padre__c = :agrupadoresPlantillas[0].Id AND OB_Tipo__c = 'SMS'
                                                                    AND OB_Idioma__c = :idiomaPlantilla AND OB_Idioma__c != NULL LIMIT 1];
                        if (!plantillas.isEmpty()) {
                            nombrePlantillaSms = plantillas[0].OB_Plantilla__c;
                        } else {
                            nombrePlantillaSms = agrupadoresPlantillas[0].OB_Plantilla_SMS_Defecto__c;
                        }
                    }
                }
            }

            //OficinaEmail
            if (String.isBlank(camposXml.get('OficinaEmail'))) {
                if (camposXml.get('EnviarEmail') == 'Y') {
                    mensajesError.add('OficinaEmail obligatorio'); //Si no se envía correo no es requerido
                }
            } else {
                String numeroOficina = String.valueOf(Integer.valueOf(camposXml.get('OficinaEmail'))).leftPad(5, '0');
                List<Account> oficinas = [SELECT CC_Email__c FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank'
                                            AND CC_Tipo_Centro__c = 'OF' AND CC_Numero_Oficina__c = :numeroOficina AND CC_Inactivo__c = FALSE LIMIT 1];
                if (!oficinas.isEmpty() && String.isNotBlank(oficinas[0].CC_Email__c)) {
                    camposLlamada.put('OB_Direccion_Correo__c', oficinas[0].CC_Email__c);
                } else if (camposXml.get('EnviarEmail') == 'Y') {
                    mensajesError.add('OficinaEmail informada con valor no coherente');
                }
            }

            //FechaVisita
            if ((camposXml.get('EnviarEmail') == 'Y' || camposXml.get('EnviarSMS') == 'Y') && String.isNotBlank(camposXml.get('FechaVisita'))) {
                camposLlamada.put('OB_Fecha_Visita__c', convertirFechaVisita(camposXml.get('FechaVisita')));
            }

            //EnviarEmail, FechaVisita, ImporteOfrecido, ImporteFormalizar
            if (camposXml.get('EnviarEmail') == 'Y' && camposLlamada.containsKey('OB_Direccion_Correo__c')) {
                if (String.isBlank(campanyaProducto.OB_Agrupador_Plantillas__c)) {
                    mensajesError.add('No existe plantilla Email asociada para este Producto-Campaña');
                } else {
                    //El agrupador de plantillas debe tener plantilla por defecto informada
                    List<OB_Parametrizacion__c> agrupadoresPlantillas = [SELECT OB_Plantilla_Email_Defecto__c FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Agrupador_Plantillas'
                                                                            AND Id = :campanyaProducto.OB_Agrupador_Plantillas__c AND OB_Activo__c = TRUE];
                    if (agrupadoresPlantillas.isEmpty()) {
                        mensajesError.add('No existe plantilla Email asociada para este Producto-Campaña');
                    } else if (String.isBlank(agrupadoresPlantillas[0].OB_Plantilla_Email_Defecto__c)) {
                        mensajesError.add('La Plantilla asociada no permite envío de Email');
                    } else {
                        String idiomaPlantilla = CC_Listas_Valores.lookupValue('Outbound: Conversión del atributo "Idioma"', camposXml.get('Idioma'), 'CC_Valor2__c');
                        List<OB_Parametrizacion__c> plantillas = [SELECT OB_Plantilla__c FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Plantilla_Tipo_Idioma'
                                                                    AND OB_Parametrizacion_Padre__c = :agrupadoresPlantillas[0].Id AND OB_Tipo__c = 'Correo electrónico'
                                                                    AND OB_Idioma__c = :idiomaPlantilla AND OB_Idioma__c != NULL LIMIT 1];
                        if (!plantillas.isEmpty()) {
                            nombrePlantillaCorreo = plantillas[0].OB_Plantilla__c;
                        } else {
                            nombrePlantillaCorreo = agrupadoresPlantillas[0].OB_Plantilla_Email_Defecto__c;
                        }
                    }
                }

                if (campanyaProducto.OB_Agrupador_Plantillas__r.Name == 'PRÉSTAMOS CON VISITA'
                || campanyaProducto.OB_Agrupador_Plantillas__r.Name == 'PRODUCTOS COMPRA ESTRELLA​') {
                    if (String.isBlank(camposXml.get('FechaVisita'))) {
                        mensajesError.add('FechaVisita obligatorio');
                    }

                    if (String.isBlank(camposXml.get('ImporteOfrecido'))) {
                        mensajesError.add('ImporteOfrecido obligatorio');
                    } else if (!Pattern.compile('^((\\d{7})(\\.\\d{3}))$').matcher(camposXml.get('ImporteOfrecido')).matches()) {
                        mensajesError.add('ImporteOfrecido no tiene formato 9999999.999');
                    } else {
                        camposLlamada.put('OB_Importe_Ofrecido__c', Decimal.valueOf(camposXml.get('ImporteOfrecido')));
                    }

                    if (campanyaProducto.OB_Agrupador_Plantillas__r.Name == 'PRÉSTAMOS CON VISITA') {
                        if (String.isBlank(camposXml.get('ImporteFormalizar'))) {
                            mensajesError.add('ImporteFormalizar obligatorio');
                        } else if (!Pattern.compile('^((\\d{7})(\\.\\d{3}))$').matcher(camposXml.get('ImporteFormalizar')).matches()) {
                            mensajesError.add('ImporteFormalizar no tiene formato 9999999.999');
                        } else {
                            camposLlamada.put('OB_Importe_Formalizar__c', Decimal.valueOf(camposXml.get('ImporteFormalizar')));
                        }
                    }
                }
            }
        } catch (Exception e) {
            mensajesError.add('ExceptionType: ' + e.getTypeName() + ' - ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.'));
            CBK_Log.error(e);
        } finally {
            if (mensajesError.isEmpty()) {
                //Update de la llamada
                for (String nombreCampo : camposLlamada.keySet()) {
                    llamada.put(nombreCampo, camposLlamada.get(nombreCampo));
                }
                update llamada;

                //Creación de la tarea
                Map<String, Object> camposTareaCierre = new Map<String, Object>();
                camposTareaCierre.put('Type', 'Cierre');
                camposTareaCierre.put('Subject', 'Cierre');
                camposTareaCierre.put('Status', 'Completed');
                camposTareaCierre.put('Description', mensajeEntrada);
                OB_Activity.crearActividad(llamada.Id, camposTareaCierre);

                //Envío del correo si aplica
                if (camposXml.get('EnviarEmail') == 'Y') {
                    OB_Llamada.enviarCorreo(new List<Id>{llamada.Id}, nombrePlantillaCorreo);
                }

                //Envío del SMS si aplica
                if (camposXml.get('EnviarSMS') == 'Y') {
                    OB_Llamada.enviarSms(new List<Id>{llamada.Id}, nombrePlantillaSms);
                }
            } else {
                //Update de la llamada con el detalle del error en el cierrre
                llamada.put('OB_Estado__c', 'OB_Error');
                llamada.put('OB_Descripcion_Error__c', String.join(new List<String>(mensajesError), '\n'));
                update llamada;

                //Creación de la tarea
                Map<String, Object> camposTareaError = new Map<String, Object>();
                camposTareaError.put('Type', 'Error');
                camposTareaError.put('Subject', 'Error en Cierre');
                camposTareaError.put('Status', 'Completed');
                camposTareaError.put('Description', String.join(new List<String>(mensajesError), '\n') + '\n\n\n' + mensajeEntrada);
                OB_Activity.crearActividad(llamada.Id, camposTareaError);
            }
        }
        return llamada?.Name == null ? '' : llamada.Name;
    }

    private static Date convertirFechaVisita(String fechaVisita) {
        //Formato esperado: fechaVisita -> 20211027
        Date fecha;
        try {
            fecha = Date.newInstance(
                Integer.valueOf(fechaVisita.substring(0, 4)),
                Integer.valueOf(fechaVisita.substring(4, 6)),
                Integer.valueOf(fechaVisita.substring(6, 8))
            );
        } catch (Exception e) {
            throw new DefaultException('FechaVisita no es una fecha válida según formato YYYYMMDD');
        }
        return fecha;
    }

    private static Datetime convertirFechaHora(String fechaLlamada, String horaLlamada) {
        //Formato esperado: fechaLlamada -> 20200227, horaLlamada -> 15:00:10
        Datetime fechaHora;
        try {
            fechaHora = Datetime.newInstance(
                Integer.valueOf(fechaLlamada.substring(0, 4)),
                Integer.valueOf(fechaLlamada.substring(4, 6)),
                Integer.valueOf(fechaLlamada.substring(6, 8)),
                Integer.valueOf(horaLlamada.substring(0, 2)),
                Integer.valueOf(horaLlamada.substring(3, 5)),
                Integer.valueOf(horaLlamada.substring(6, 8))
            );
        } catch (Exception e) {
            throw new DefaultException('FechaLlamada/HoraLlamada con valor incoherente');
        }
        return fechaHora;
    }

    public static Boolean codigoContratoValido(String codigoContrato, String formato) {
        Boolean codigoContratoValido = true;
        if (formato.length() != codigoContrato.length()) {
            codigoContratoValido = false;
        } else {
            List<String> bloquesCodigo = codigoContrato.splitByCharacterType();
            List<String> bloquesFormato = formato.splitByCharacterType();
            for (Integer i = 0; i < bloquesFormato.size(); i++) {
                if (bloquesFormato[i].length() != bloquesCodigo[i].length()
                || bloquesFormato[i].isNumeric() != bloquesCodigo[i].isNumeric()) {
                    codigoContratoValido = false;
                    break;
                }
            }
        }
        return codigoContratoValido;
    }

    private static Map<String, String> mapaCamposXmlEntrada(Dom.XmlNode nodoPadre) {
        Map<String, String> camposXml = new Map<String, String>();
        for (DOM.XmlNode nodoHijo : nodoPadre.getChildElements()) {
            camposXml.put(nodoHijo.getName(), nodoHijo.getText().normalizeSpace());
        }
        return camposXml;
    }

    private static String detalleError(Set<String> mensajesError) {
        String detalleError = '';
        List<String> mensajesErrorLista = new List<String>(mensajesError);
        for (Integer i = 0; i < mensajesErrorLista.size(); i++) {
            detalleError += (i + 1) + ': ' + mensajesErrorLista[i] + ', ';
        }
        return detalleError.removeEnd(', ');
    }

    private static String serializarRespuesta(Map<String, String> respuesta, String detalleError) {
        Dom.Document respuestaDoc = new Dom.Document();
        Dom.XmlNode nodoRespuesta = respuestaDoc.createRootElement('RequestDoAlta', null, null);
        nodoRespuesta.addChildElement('IdPeticion', null, null).addTextNode(respuesta.get('IdPeticion'));
        nodoRespuesta.addChildElement('resultado', null, null).addTextNode(String.isBlank(detalleError) ? 'OK' : 'KO');
        nodoRespuesta.addChildElement('llamadaId', null, null).addTextNode(respuesta.get('llamadaId'));
        nodoRespuesta.addChildElement('codigoError', null, null).addTextNode(respuesta.get('codigoError'));
        nodoRespuesta.addChildElement('detalleError', null, null).addTextNode(detalleError);
        return respuestaDoc.toXmlString();
    }

    private static Contact identificarCliente(Map<String, String> camposXml) {
        //Identificación contra BD de cuenta y contacto a partir del NUMPERSO
        Contact contacto = null;
        if (String.isNotBlank(camposXml.get('NumPerso'))) {
            List<Contact> contactos = [SELECT AccountId FROM Contact
                                        WHERE (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA')
                                        AND CC_NumPerso__c = :camposXml.get('NumPerso')];
            if (!contactos.isEmpty()) {
                contacto = contactos[0];
            } else {
                //Cliente no se ha podido identificar, se crea uno nuevo



                Account cuenta = new Account();
                cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
                cuenta.Name = (camposXml.get('NombreCliente') + ' ' + camposXml.get('Apellido1Cliente') + ' ' + camposXml.get('Apellido2Cliente')).normalizeSpace().toUpperCase();
                insert cuenta;

                contacto = new Contact();
                contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
                contacto.AccountId = cuenta.Id;
                contacto.CC_NumPerso__c = camposXml.get('NumPerso');
                contacto.CC_Numero_Documento__c = camposXml.get('NifCliente');
                contacto.FirstName = camposXml.get('NombreCliente').left(40);
                contacto.LastName = (camposXml.get('Apellido1Cliente') + ' ' + camposXml.get('Apellido2Cliente')).left(80).normalizeSpace().toUpperCase();
                contacto.CC_Idioma__c = 'Es';
                insert contacto;
            }
        }
        return contacto;
    }

    /*
    private static Boolean enviarCorreo(Id idLlamada, String direccionCorreo, String nombrePlantilla) {
        nombrePlantilla = 'Plantilla de correo por defecto Outbound'; //PENDIENTE
        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
        correo.setToAddresses(new List<String>{direccionCorreo});
        correo.setTemplateId([SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla].Id);
        correo.setTargetObjectId([SELECT Email FROM Contact WHERE Email != NULL LIMIT 1].Id);
        correo.setTreatTargetObjectAsRecipient(false);
        correo.setWhatId(idLlamada);
        correo.setSaveAsActivity(true);
        correo.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id); //PENDIENTE
        List<Messaging.SendEmailResult> resultadoEnvios = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
        return resultadoEnvios[0].isSuccess();
    }

    public static void enviarSms(Id idLlamada, String telefono, String nombrePlantilla) {
        nombrePlantilla = 'Plantilla de SMS por defecto Outbound'; //PENDIENTE
        String textoSms = [SELECT HtmlValue FROM EmailTemplate WHERE Name = :nombrePlantilla].HtmlValue.stripHtmlTags();
        CC_Push_SMS.enviarNotificacionPush(idLlamada, telefono, textoSms);
    }
    */

    private static Boolean direccionCorreoValida(String direccionCorreo) {
        Boolean retorno = true;
        if (String.isNotBlank(direccionCorreo)) {
            String regex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
            retorno = Pattern.compile(regex).matcher(direccionCorreo).matches();
        }
        return retorno;
    }

    private static Boolean numeroTelefonoValido(String numeroTelefono) {
        Boolean retorno = true;
        if (String.isNotBlank(numeroTelefono)) {
            retorno = Pattern.compile('^[^a-zA-Z]{9,12}+$').matcher(numeroTelefono.normalizeSpace().remove(' ')).matches();
        }
        return retorno;
    }

    private class DefaultException extends Exception {}
}