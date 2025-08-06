global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {

    /* Inicializa los campos de los borradores de correos electrónicos generados mediante quick
    actions de tipo "Enviar correo". Se invoca al estar configurado en Setup --> Support Settings */

    global EmailPublisherLoader() {} //Empty constructor
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    //The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        //Se almacenan los parámetros de invocación de la quick action en la variable parametrosQuickAction
        QuickAction.SendEmailQuickActionDefaults parametrosQuickAction = null;
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults
                && defaults.get(j).getTargetSObject().getSObjectType() == EmailMessage.sObjectType) {
                parametrosQuickAction = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                break;
            }
        }
        

        if (parametrosQuickAction != null) {
            parametrosQuickAction.setIgnoreTemplateSubject(false); //Se usará el asunto de la plantilla y no el del hilo
            EmailMessage correo = (EmailMessage)parametrosQuickAction.getTargetSObject();
            switch on parametrosQuickAction.getActionName() {
                when 'Case.HDT_Email_Colaborador' {

                    //Inicialización de borrador de correo para HDT
                    //Pese al nombre se refiere a cualquier operativa de correo y no solo a la de colaboradores
                    correo.ReplyToEmailMessageId = null;
                    inicializarCuerpoCorreo(correo, parametrosQuickAction, 'HDT');
                }
                when 'Case.Email_Colaborador' {
                    //Inicialización de borrador de correo para CC
                    //Pese al nombre se refiere a cualquier operativa de correo y no solo a la de colaboradores
                    correo.ReplyToEmailMessageId = null;
                    inicializarCuerpoCorreo(correo, parametrosQuickAction, 'CC');
                }
                when 'Case.OS_Enviar_Correo' {
                    //Inicialización de borrador de correo para COPS
                    correo.ReplyToEmailMessageId = null;
                    inicializarCuerpoCorreo(correo, parametrosQuickAction, 'COPS');
                }
                when 'Case.AM_Enviar_Correo' {
                    //Inicialización de borrador de correo para CAM
                    correo.ReplyToEmailMessageId = null;
                    inicializarCuerpoCorreo(correo, parametrosQuickAction, 'CAM');
                }
                when 'Case.SACH_Enviar_Correo' {
                    //Inicialización de borrador de correo para CAM
                    correo.ReplyToEmailMessageId = null;
                    inicializarCuerpoCorreo(correo, parametrosQuickAction, 'SACH');
                }
                when 'Case.TMS_Email' {
                    //Inicialización de borrador de correo para CAM
                    correo.ReplyToEmailMessageId = null;
                    inicializarCuerpoCorreo(correo, parametrosQuickAction, 'TMS');
                }
                when 'Case.GRR_Enviar_Correo' {
                    //Inicialización de borrador de correo para GRR
                    correo.ReplyToEmailMessageId = null;
                    inicializarCuerpoCorreo(correo, parametrosQuickAction, 'GRR');
                }
            }
        }
    }

    private static void inicializarCuerpoCorreo(EmailMessage correo, QuickAction.SendEmailQuickActionDefaults parametrosQuickAction, String negocio) {
        //Se recuperan las plantillas a utilizar
        //Si la plantilla tiene un replacement custom desde el Case Extension, se debe incluir el campo en la query. 
        Case caso = [SELECT CC_Email_Cabecera__c, CC_Email_Pie__c, CC_MCC_Plantilla__c, CC_Referencia_Correo_Saliente__c, OS_Email_Seleccionado__c, CC_URL_Encuesta_3N__c, CC_Ultima_Operativa_Correo__c, CC_Idioma__c,
        CBK_Case_Extension_Id__r.CC_ID_cliente__c,
        CBK_Case_Extension_Id__r.CC_Nombre_Comercio__c,
        CBK_Case_Extension_Id__r.CC_Fecha_De_Compra__c
        FROM Case WHERE Id = :parametrosQuickAction.getContextId()];

        //Plantilla de cabecera
        String textoPlantillaCabecera = '';
        List<EmailTemplate> plantillasCabecera = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = :caso.CC_Email_Cabecera__c];
        if (!plantillasCabecera.isEmpty() && plantillasCabecera[0].HtmlValue != null) {
            textoPlantillaCabecera = plantillasCabecera[0].HtmlValue;
            textoPlantillaCabecera = textoPlantillaCabecera.replaceAll('</body>','');
            textoPlantillaCabecera = textoPlantillaCabecera.replaceAll('<br />','');
            textoPlantillaCabecera = textoPlantillaCabecera.replaceAll('</head>','');
            textoPlantillaCabecera = textoPlantillaCabecera.replaceAll('</html>','');
            textoPlantillaCabecera = textoPlantillaCabecera.replaceAll('&nbsp;','');
        }

        //Plantilla de pie
        String textoPlantillaPie = '';
        List<EmailTemplate> plantillasPie = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = :caso.CC_Email_Pie__c];
        if (!plantillasPie.isEmpty() && plantillasPie[0].HtmlValue != null) {
            textoPlantillaPie = plantillasPie[0].HtmlValue;
            textoPlantillaPie = textoPlantillaPie.replaceAll('<body>','');
            textoPlantillaPie = textoPlantillaPie.replaceAll('<head>','');
            textoPlantillaPie = textoPlantillaPie.replaceAll('<body style="height: auto; min-height: auto;">','');
            textoPlantillaPie = textoPlantillaPie.replaceAll('<html>','');
            textoPlantillaPie = textoPlantillaPie.replaceAll('<title>','');
            textoPlantillaPie = textoPlantillaPie.replaceAll('</title>','');
        }

        //Plantilla de cuerpo
        String textoPlantillaCuerpo = '';
        String operativa = null;
        String tratamiento = '';
        String idioma = 'es';
        List<EmailTemplate> plantillasCuerpo = [SELECT Subject, DeveloperName, HtmlValue, FolderId
                                                FROM EmailTemplate WHERE Id = :caso.CC_MCC_Plantilla__c];
        if (!plantillasCuerpo.isEmpty()) {
            if (plantillasCuerpo[0].HtmlValue != null) {
                textoPlantillaCuerpo = plantillasCuerpo[0].HtmlValue;
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('<html>','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('<body style="height: auto; min-height: auto;">','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('<body>','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('<head>','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('</body>','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('</head>','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('</html>','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('<title>','');
                textoPlantillaCuerpo = textoPlantillaCuerpo.replaceAll('</title>','');              
            }

            Map<String, String> retorno = new Map<String, String>();
            retorno = datosPlantilla(plantillasCuerpo[0]); //La operativa se deduce a partir de la plantilla de cuerpo
            operativa = retorno.get('operativa');
            idioma = retorno.get('idioma');
            tratamiento = retorno.get('tratamiento');
            correo.Subject = plantillasCuerpo[0].Subject;
        }
        
        if (operativa == null && caso.CC_Referencia_Correo_Saliente__c == null) {
            throw new OtherException('No se permiten enviar correos que no se originen de una operativa.');
        }

        if(negocio == 'CC'){    
            //Replacement custom desde Apex para campos de case extension
            textoPlantillaCuerpo = reemplazarCamposCaseExtension(textoPlantillaCuerpo, caso.CBK_Case_Extension_Id__r);
        }
        //Se concatenan las plantillas
        String textoCuerpo = textoPlantillaCabecera + textoPlantillaCuerpo + textoPlantillaPie;
       
        //En función de la operativa recupera el histórico de correos para añadirlo al final del correo
        String historicoCorreos = '';
        if (negocio == 'CC'|| negocio == 'SACH' || negocio == 'HDT' || negocio == 'TMS' || negocio == 'GRR') {
            
            try {
                if (operativa != null) {
                    if (operativa == 'Responder a cliente') {
                        //El histórico contendrá solamente el correo entrante inicial del cliente
                        historicoCorreos = CC_Case.correoInicialCliente(caso.Id);
                    } else if (operativa == 'Trasladar a colaborador' || operativa == 'Remitir a colaborador' || operativa == 'Enviar correo') {
                        //El histórico contendrá solamente los correos intercambiados entre Colaboradores para el negocio GRR. Para el resto, contendrá todos los correos.
                        historicoCorreos = (negocio == 'GRR') ? GRR_Case.historicoCorreosSinCliente(caso.Id) : CC_Case.historicoCorreosCliente(caso.Id, true);

                        //El histórico contendrá todos los correos
                        //historicoCorreos = CC_Case.historicoCorreosCliente(caso.Id, true);
                    } else {
                        //Resto de operativas (por ejemplo solicitud de información)
                        //El histórico contendrá solamente las comunicaciones con cliente
                        historicoCorreos = CC_Case.historicoCorreosCliente(caso.Id, false);
                    }
                }
            } catch(Exception e) {
                throw new OtherException('Error recopilando histórico de correos para el caso ' + parametrosQuickAction.getContextId());
            }
        } else {
            //Para COPS el hitòrico es diferente //Implementacion Nerea Febrero 2021
            //En función de si hay un correo seleccionado
            try {
                if (caso.OS_Email_Seleccionado__c != null) {
                    historicoCorreos = historicoCorreoSeleccionado(caso.Id, caso.OS_Email_Seleccionado__c);
                } else {
                    if (operativa != null) {
                        if (operativa == 'Trasladar a colaborador' || operativa == 'Remitir a colaborador') {
                            //El histórico contendrá todos los correos
                            historicoCorreos = CC_Case.historicoCorreosClienteCops(caso.Id, true);
                        } else {
                            //Resto de operativas (por ejemplo solicitud de información y responder Cliente)
                            //El histórico contendrá solamente las comunicaciones con cliente
                            historicoCorreos = CC_Case.historicoCorreosClienteCops(caso.Id, false);
                        }
                    }
                }
            } catch(Exception e) {
                throw new OtherException('Error recopilando histórico de correos para el caso ' + parametrosQuickAction.getContextId());
            }
        }
        
        //Se añade referencia externa (posteriormente en CC_EmailMessage_AI_TRHan se buscará dicha
        //referencia en los correos entrantes para identificar el correo origen y por lo tanto la operativa

        if (negocio == 'CC' || negocio == 'SACH' || negocio == 'HDT' || negocio == 'TMS' || negocio == 'GRR') {

            List<CC_Texto_MultiIdioma__mdt> frasesSemilla = new List<CC_Texto_MultiIdioma__mdt>();

            if (operativa == 'Trasladar a colaborador' || (operativa == 'Remitir a colaborador' && negocio == 'SACH') || (operativa == 'Remitir a colaborador' && negocio == 'GRR')) {
                frasesSemilla = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'CC_Semilla_Traslado_Colaborador_ESP' LIMIT 1];
            }else if (operativa == 'Solicitud de información') {
                String nombreMetadataSolInfo = idioma == 'en' ? 'CC_Semilla_Solicitud_Info' : 'CC_Semilla_Solicitud_Info_';
                frasesSemilla = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt
                                WHERE CC_Nombre__c = :(nombreMetadataSolInfo + tratamiento) AND CC_Idioma__c = :idioma LIMIT 1];
            } else if (operativa == 'Responder a cliente') {
                String nombreMetadataResponder = idioma == 'en' ? 'CC_Semilla_Responder' : 'CC_Semilla_Responder_';
                frasesSemilla = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt
                                WHERE CC_Nombre__c = :(nombreMetadataResponder + tratamiento) AND CC_Idioma__c = :idioma LIMIT 1];
            }

            textoCuerpo += '<br/><br/><font color="gray">';
            if (!frasesSemilla.isEmpty()) {
                textoCuerpo += frasesSemilla[0].CC_Texto__c + ' #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
            } else if (frasesSemilla.isEmpty() && operativa != 'Remitir a colaborador' && operativa != 'Responder a cliente') {
                textoCuerpo += 'Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
            } else if (frasesSemilla.isEmpty() && operativa == 'Responder a cliente') {
                textoCuerpo += 'Por favor, no responder a este correo electrónico: #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
            }
            textoCuerpo += '</font>';
        } else if (negocio == 'COPS' || negocio == 'CAM') {
            //Si es la primera vez que se hace un Responder a cliente que cierra el caso en COPS, se envía una encuesta
            if(caso.CC_URL_Encuesta_3N__c != null && negocio == 'COPS' && caso.CC_Ultima_Operativa_Correo__c == 'Cerrado con encuesta'){
                List<EmailTemplate> plantillaEncuesta = new List<EmailTemplate>();
                if(caso.CC_Idioma__c == 'es'){
                    plantillaEncuesta = [SELECT HtmlValue
                                                FROM EmailTemplate WHERE Name = 'Responder a cliente - enviar encuesta'];
                } else if (caso.CC_Idioma__c == 'ca'){
                    plantillaEncuesta = [SELECT HtmlValue
                                                FROM EmailTemplate WHERE Name = 'Respondre al client - enviar enquesta'];
                }
                if(!plantillaEncuesta.isEmpty()){
                    String textoEncuestaCuerpo = '';
                    textoEncuestaCuerpo = plantillaEncuesta[0].HtmlValue;
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('<html>','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('<body style="height: auto; min-height: auto;">','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('<body>','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('<head>','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('</body>','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('</head>','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('</html>','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('<title>','');
                    textoEncuestaCuerpo = textoEncuestaCuerpo.replaceAll('</title>','');

                    textoCuerpo = textoEncuestaCuerpo + textoCuerpo;
                }
                
            }
            //Para COPS y CAM la frase previa es siempre la misma
            textoCuerpo += '<br/><br/><font color="gray">';
            textoCuerpo += 'Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
            textoCuerpo += '</font>';
        }

        String textoTotal = '';

        //Se concatena el histórico de correos al cuerpo del correo
        if (textoCuerpo != '' && textoCuerpo != null && historicoCorreos != '' && historicoCorreos != null) {

            textoTotal = textoCuerpo + '<br/>__________<br/><br/>' + historicoCorreos;

            if (textoTotal.length() >= 131072) {
                textoTotal = textoTotal.substring(0, 131072);
            }
            correo.HTMLBody = textoTotal;

        } else {

            textoTotal = textoCuerpo + historicoCorreos;

            if (textoTotal.length() >= 131072) {
                textoTotal = textoTotal.substring(0, 131072);
        }
            correo.HTMLBody = textoTotal;
        }

        List<ContentDocumentLink> lstContentDocumentlink = [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId = :caso.CC_MCC_Plantilla__c];
        //    0691j000002bNH7AAM

        if(!lstContentDocumentlink.isEmpty()){
        	ContentDocumentLink newCdl = lstContentDocumentlink.get(0).clone();
            newCdl.LinkedEntityId = Correo.Id;   
        }
        
                    
    }

    private static Map<String, String> datosPlantilla(EmailTemplate plantilla) {
        /* La operativa se puede deducir de la jerarquía de carpetas en la que se encuentra la plantilla. Ejemplo para operativas CC:

        TIPO PLANTILLA              JERARQUÍA CARPETAS
        Traslado a colaborador      Operativas > Trasladar a colaborador > Castellano > PLANTILLA
        Remitir a colaborador       Operativas > Remitir a colaborador > Castellano
        Solicitud de información    Operativas > Solicitud de información > Idioma (Castellano/Catalán/Inglés) > Tratamiento (Formal/Informal)
        Responder a cliente         Operativas > Responder a cliente > Idioma (Castellano/Catalán/Inglés) > Tratamiento (Formal/Informal)
        ---
        * NOTA: Para idioma inglés no aplica subcarpeta de tratamiento.

        Como en función de la operativa la carpeta que la define no siempre está a la misma distancia de
        la plantilla, se concatenan en una cadena los nombres de las carpetas de los 3 últimos niveles de la
        jerarquía y se busca en dicha cadena el nombre de la operativa. */

        try {
            Folder carpeta = [SELECT Name, ParentId FROM Folder WHERE Id = :plantilla.FolderId LIMIT 1];
            String jerarquiaCarpetas = carpeta.Name;
            
            if(carpeta.ParentId != null){
                carpeta = [SELECT Name, ParentId FROM Folder WHERE Id = :carpeta.ParentId LIMIT 1];
                jerarquiaCarpetas = carpeta.Name + '-' + jerarquiaCarpetas;
            }

            if(carpeta.ParentId != null){
                carpeta = [SELECT Name, ParentId FROM Folder WHERE Id = :carpeta.ParentId LIMIT 1];
                jerarquiaCarpetas = carpeta.Name + '-' + jerarquiaCarpetas;
            }

            String operativa = null;
            if (jerarquiaCarpetas.contains('Trasladar a colaborador')) {
                operativa = 'Trasladar a colaborador';
            } else if (jerarquiaCarpetas.contains('Remitir a colaborador')) {
                operativa = 'Remitir a colaborador';
            } else if (jerarquiaCarpetas.contains('Solicitud de información')) {
                operativa = 'Solicitud de información';
            } else if (jerarquiaCarpetas.contains('Responder a cliente')) {
                operativa = 'Responder a cliente';
            } else if (jerarquiaCarpetas.contains('Enviar correo')) {
                operativa = 'Enviar correo';
            }


            String idioma = null;
            if (jerarquiaCarpetas.contains('Catalán')) {
                idioma = 'ca';
            } else if (jerarquiaCarpetas.contains('Inglés')) {
                idioma = 'en';
            } else {
                idioma = 'es';
            }

            String tratamiento = null;
            if (jerarquiaCarpetas.contains('Informal')) {
                tratamiento = 'Tu';
            } else if (jerarquiaCarpetas.contains('Genérico')) {
                tratamiento = '';
            } else {
                tratamiento = 'Usted';
            }

            Map<String, String> retorno = new Map<String, String>();
            retorno.put('operativa', operativa);
            retorno.put('idioma', idioma);
            retorno.put('tratamiento', tratamiento);
            return retorno;
        } catch (Exception e) {
            throw new OtherException('Error recuperando la jerarquía de carpetas para la plantilla "' + plantilla.DeveloperName + '"');
        }
    }

    public static String historicoCorreoSeleccionado(Id idCaso, Id idCorreoSeleccionado) {
        String resultado = '';
        List<EmailMessage> correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody, TextBody FROM EmailMessage
        WHERE ParentId = :idCaso AND Id = :idCorreoSeleccionado];
        
        if (!correos.isEmpty()) {
            for (EmailMessage correo : correos) {
                if (correo.HtmlBody != '' && correo.HtmlBody != null) {
                    resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
                    resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
                    resultado += 'Para: ' + correo.ToAddress + '<br/>';
                    if (correo.CcAddress != null) resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
                    resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + correo.HtmlBody;
                    
                } else if (correo.TextBody != '' && correo.TextBody != null) {
                    String nuevoTextoPlano = '';
                    for (String s : correo.TextBody.split('\\n')) {
                        nuevoTextoPlano += s + '<br/>';
                    }
                    resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
                    resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
                    resultado += 'Para: ' + correo.ToAddress + '<br/>';
                    if (correo.CcAddress != null) resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
                    resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + nuevoTextoPlano;
                    
                }
            }
        }
        return resultado;
    }

    private static String formatearFecha(Datetime fecha) {
        List<String> diasEN = new List<String>{'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
        List<String> diasES = new List<String>{'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'};

        List<String> mesesEN = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
        List<String> mesesES = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};

        String retorno = diasES.get(diasEN.indexOf(fecha.format('EEE'))) + ', ' + fecha.day() + ' de ';
        retorno += mesesES.get(mesesEN.indexOf(fecha.format('MMM'))) + ' de ' + fecha.year() + ' ' + fecha.format('HH:mm');

        return retorno;
    }

    /**
     * @description Método que reemplaza dinámicamente los campos de CBK_Case_Extension en el texto de la plantilla
     * @param textoPlantilla El texto de la plantilla donde se realizarán los reemplazos
     * @param caseExtension El registro de CBK_Case_Extension del que se obtendrán los valores
     * @return String El texto con los reemplazos realizados
     */
    private static String reemplazarCamposCaseExtension(String textoPlantilla, CBK_Case_Extension__c caseExtension) {
        if (textoPlantilla == null || caseExtension == null) {
            return textoPlantilla;
        }
        
        String resultado = textoPlantilla;
        
        // Obtener el mapa de campos del objeto para verificar tipos
        Map<String, Schema.SObjectField> fieldMap = CBK_Case_Extension__c.SObjectType.getDescribe().fields.getMap();
        
        // Buscar patrones [[[CBK_Case_Extension_Id__r.XXXX]]] en el texto
        Pattern pattern = Pattern.compile('\\[\\[\\[CBK_Case_Extension_Id__r\\.([^\\]]+)\\]\\]\\]');
        Matcher matcher = pattern.matcher(textoPlantilla);
        
        while (matcher.find()) {
            String campo = matcher.group(1);
            String valor = '';
            
            try {
                Object valorCampo = caseExtension.get(campo);
                if (valorCampo != null) {
                    // Verificar si el campo es de tipo Date
                    if (fieldMap.containsKey(campo) && fieldMap.get(campo).getDescribe().getType() == Schema.DisplayType.DATE) {
                        Date fecha = (Date)valorCampo;
                        DateTime fechaTime = DateTime.newInstance(fecha.year(), fecha.month(), fecha.day());
                        valor = fechaTime.format('dd/MM/yyyy');
                    } else {
                        valor = String.valueOf(valorCampo);
                    }
                }
            } catch(Exception e) {
                // Si hay algún error al obtener el valor del campo, se deja vacío
                valor = '';
            }
            
            // Reemplazar el patrón con el valor del campo
            resultado = resultado.replace('[[[CBK_Case_Extension_Id__r.' + campo + ']]]', valor);
        }
        
        return resultado;
    }
}