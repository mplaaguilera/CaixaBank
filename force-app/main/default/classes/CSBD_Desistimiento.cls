public with sharing class CSBD_Desistimiento {

    public static List<Opportunity> cerrarDesistimiento(List<Id> idDesistimientos) {
        List<Opportunity> desistimientos = getDesistimientos(idDesistimientos);
        for (Opportunity desistimiento : desistimientos) {
            if (desistimiento.CSBD_Now_Resultado__c != 'OK') {
                //Envío de correo a cliente
                if (String.isBlank(desistimiento.CSBD_Email_Solicitud__c)) {
                    CSBD_Activity.crearActividad(
                        desistimiento.Id,
                        'Error notificando resultado de desistimiento a cliente',
                        'Completed',
                        'Error notificando resultado de desistimiento a cliente',
                        'No se dispone de la dirección de correo del cliente.'
                    );
                } else {
                    String nombrePlantillaCorreo = nombrePlantillaCorreo('Cliente', desistimiento);
                    if (String.isNotBlank(nombrePlantillaCorreo)) {
                        Messaging.SendEmailResult resultadoEnvioCorreo = CSBD_MetodosComunes.enviarCorreo(
                            desistimiento.Id, 
                            desistimiento.CSBD_Empresa_Proveedora__c, 
                            nombrePlantillaCorreo,
                            new List<String>{desistimiento.CSBD_Email_Solicitud__c},
                            true //para buscar buzon por empresa proveedora
                        );
                        if (resultadoEnvioCorreo == null || !resultadoEnvioCorreo.isSuccess()) {
                            CSBD_Activity.crearActividad(desistimiento.Id,
                                'Error notificando resultado de desistimiento a cliente',
                                'Completed',
                                'Error notificando resultado de desistimiento a cliente',
                                resultadoEnvioCorreo != null ? resultadoEnvioCorreo.getErrors()[0].getMessage() : null
                            );
                        }
                    }
                }
            }

            //Envío de correo a oficina (solo si se ha concedido el desistimiento)
            if (desistimiento.StageName == 'Formalizada') {
                //Envío de correo a oficina
                Boolean enviarCorreoOficina = true;
                String destinatario;
                if (String.isNotBlank(desistimiento.CSBD_OficinaLO__r.CC_Email__c)) {
                    destinatario = desistimiento.CSBD_OficinaLO__r.CC_Email__c;
                } else if (String.isNotBlank(desistimiento.Account.CC_OficinaGestoraId__r.CC_Email__c)) {
                    destinatario = desistimiento.Account.CC_OficinaGestoraId__r.CC_Email__c;
                } else {
                    enviarCorreoOficina = false;
                    CSBD_Activity.crearActividad(
                        desistimiento.Id,
                        'Error notificando desistimiento a oficina',
                        'Completed',
                        'Error notificando desistimiento a oficina',
                        'No se dispone de la dirección de correo de la oficina.');
                }
                
                if (enviarCorreoOficina) {
                    String nombrePlantillaCorreo = nombrePlantillaCorreo('Oficina', desistimiento);
                    if (String.isNotBlank(nombrePlantillaCorreo)) {
                        Messaging.SendEmailResult resultadoEnvioCorreo = CSBD_MetodosComunes.enviarCorreo(
                            desistimiento.Id, 
                            'CSBD - CaixaBank Informa',
                            nombrePlantillaCorreo,
                            new List<String>{destinatario}
                        );
                        if (resultadoEnvioCorreo == null || !resultadoEnvioCorreo.isSuccess()) {
                            CSBD_Activity.crearActividad(
                                desistimiento.Id,
                                'Error notificando desistimiento a oficina',
                                'Completed',
                                'Error notificando desistimiento a oficina',
                                resultadoEnvioCorreo != null ? resultadoEnvioCorreo.getErrors()[0].getMessage() : null
                            );
                        }
                    }
                }
            }
        }
        return desistimientos;
    }

    public static void automatismosDesistimientos(List<Id> idOportunidades) {
        List<Opportunity> oportunidades = [SELECT RecordType.DeveloperName, IsClosed, CSBD_Now_Codigo_Producto__c,
                                            CSBD_OficinaLO__c, CSBD_Now_Resultado__c, CSBD_Now_Descripcion__c
                                            FROM Opportunity WHERE Id IN :idOportunidades];
        
        for (Opportunity desistimiento : descartarNoDesistimientos(oportunidades)) {
            if (desistimiento.RecordType.DeveloperName == 'CSBD_Desistimiento') {
                if (CSBD_MetodosComunes.esFlujoVidaCaixa(desistimiento.CSBD_Now_Codigo_Producto__c)) {
                    //Si es VidaCaixa, externalizar por correo
                    Messaging.SendEmailResult resultadoEnvioCorreo = CSBD_MetodosComunes.enviarCorreoDesistimientoVidaCaixa(desistimiento.Id, desistimiento.CSBD_Now_Codigo_Producto__c);
                    if (resultadoEnvioCorreo != null && resultadoEnvioCorreo.isSuccess()) {
                        CSBD_Opportunity.cerrarOportunidad(desistimiento.Id, 'Rechazada', 'Derivación de desistimiento VidaCaixa');
                    } else {
                        //Error en el envío del mail. Dejar como pendiente la gestión de la oportunidad.
                        CSBD_Activity.crearActividad(
                            desistimiento.Id,
                            'Desistimiento - Gestión',
                            'Open',
                            'Error externalizando desistimiento VidaCaixa',
                            resultadoEnvioCorreo.getErrors()[0].getMessage()
                        );
                    }
                }
            } else if (desistimiento.RecordType.DeveloperName == 'CSBD_DesistimientoPAI'
            && desistimiento.CSBD_Now_Resultado__c == 'OK' && String.isNotBlank(desistimiento.CSBD_OficinaLO__c)) {
                CSBD_Opportunity.cerrarOportunidad(desistimiento.Id, 'Formalizada', 'Desistimiento realizado');
            }
        }
    }

    private static String nombrePlantillaCorreo(String tipo, Opportunity desistimiento) {
        String idioma = 'Castellano';
        if (tipo == 'Cliente') {
            idioma = desistimiento.CSBD_Idioma_Solicitud__c;
        } else if (String.isNotBlank(desistimiento.CSBD_OficinaLO__r.CC_Email__c)) {
            idioma = desistimiento.CSBD_OficinaLO__r.CC_Idioma_Oficina__c;
            idioma = idioma == '001' ? 'Catalán' : 'Castellano';
        } else if (String.isNotBlank(desistimiento.Account.CC_OficinaGestoraId__r.CC_Email__c)) {
            idioma = desistimiento.Account.CC_OficinaGestoraId__r.CC_Idioma_Oficina__c;
            idioma = idioma == '001' ? 'Catalán' : 'Castellano';
        }

        //Se busca plantilla específica para la resolución del desistimieno actual
        String prefijoRecordType = '';
        if (desistimiento.RecordType.DeveloperName == 'CSBD_DesistimientoPAI') {
            prefijoRecordType = 'PAI.';
        }
        String clave = prefijoRecordType + desistimiento.StageName + '.' + desistimiento.CSBD_Resolucion__c + '.' + tipo + '.' + idioma;
        String nombrePlantilla = CC_Listas_Valores.LookupValue('CSBD: Plantillas para cierre de desistimientos', clave);

        if (String.isNotBlank(nombrePlantilla)) {
            return nombrePlantilla;
        } else {
            //Si no se ha encontrado se busca plantilla genérica para cualquier resolución
            clave = prefijoRecordType + desistimiento.StageName + '.*.' + tipo + '.' + idioma;
            return CC_Listas_Valores.LookupValue('CSBD: Plantillas para cierre de desistimientos', clave);
        }
    } 

    private static List<Opportunity> getDesistimientos(List<Id> idDesistimientos) {
        return [SELECT RecordType.DeveloperName, CSBD_Empresa_Proveedora__c, StageName,
                CSBD_Resolucion__c, CSBD_Idioma_Solicitud__c, CSBD_Email_Solicitud__c, CSBD_Now_Resultado__c,
                Account.CC_OficinaGestoraId__r.CC_Email__c, Account.CC_OficinaGestoraId__r.CC_Idioma_Oficina__c,
                CSBD_OficinaLO__r.CC_Email__c, CSBD_OficinaLO__r.CC_Idioma_Oficina__c
                FROM Opportunity WHERE Id IN :idDesistimientos AND StageName != 'Rechazada' AND CSBD_Resolucion__c != 'Redirigido'
                AND RecordType.DeveloperName IN ('CSBD_Desistimiento', 'CSBD_DesistimientoPAI')];
    }

    private static List<Opportunity> descartarNoDesistimientos(List<Opportunity> oportunidades) {
        //Descarta oportunidades que no sean desistimientos y oportunidades ya cerradas o rechazadas
        List<String> recordTypesDesistimientos = new List<String>{'CSBD_Desistimiento', 'CSBD_DesistimientoPAI'};
        List<Opportunity> retorno = new List<Opportunity>();
        for (Opportunity oportunidad : oportunidades) {
            if (recordTypesDesistimientos.contains(oportunidad.RecordType.DeveloperName) && !oportunidad.IsClosed) {
                retorno.add(oportunidad);
            }
        }
        return retorno;
    }
}