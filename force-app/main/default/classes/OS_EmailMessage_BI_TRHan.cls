public with sharing class OS_EmailMessage_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }
    
    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) { 
        //List<EmailMessage> newList = filtrarEmailMessageNoOS(listNewObj);
        List<EmailMessage> newList = filtrarEmailMessageCaso(listNewObj);
        validarCorreo(newList);
        if (!CSBD_Bypass_Trigger.isBypassed('OS_EmailMessage_BI_TRHan_ValidarDestinatario')) {
            validarDestinatariosCorreo(newList);
        }
        informarCamposEnvioTrasladoRemitidoAutomatico(newList);
        informarInterno(newList);
    }
    private static List<EmailMessage> filtrarEmailMessageCaso(List<EmailMessage> correos) {
        List<EmailMessage> correosCops = new List<EmailMessage>();
        for (EmailMessage correo : correos) {
            if (String.valueOf(correo.ParentId?.getSobjectType()) == 'Case') {
                correosCops.add(correo);
            } 
            else if (String.valueOf(correo.RelatedToId?.getSobjectType()) == 'Case') {
                correosCops.add(correo);
            }
        }
        return correosCops;
    }
        
    private void validarCorreo(List<EmailMessage> listNewObj) {
        Map<Id,String> mapIdCorreoGrupo = new Map<Id,String>();
        for (EmailMessage correo : listNewObj) {
            mapIdCorreoGrupo.put(correo.Id,correo.CC_Grupo_Colab__c);
        }

        for (EmailMessage correo : listNewObj) {
            //Validación del valor del campo Grupo colaborador
            if (!correo.Incoming && (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador')) {
                if (correo.CC_Grupo_Colab__c == '' || mapIdCorreoGrupo.get(correo.Id) == null) {
                    correo.addError('El grupo colaborador indicado (' + correo.CC_Grupo_Colab__c + ') no existe.', false);
                }                
            }
        }
    }

    private void informarInterno(List<EmailMessage> listNewObj) {
        //DIFERENCIAS ENTRE UN CORREO QUE ACABA DE ENTRAR Y UNO QUE SE ENVIA DE RECLAMACION:
        // 
        // El primer correo nunca tendra y el de las reclamaciones tiene la tarea de traslado abierta.
        // Incomming -> Uno entra (true) y otro sale (false)
        // messageidentifier el primero siempre tiene este campo blank

        for (EmailMessage correo : listNewObj) {
            if (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador' || (correo.CC_Procedencia__c == null && !correo.Incoming && correo.ActivityId != null && correo.MessageIdentifier != null)) { 
                correo.CC_Interno__c = true;
            }
        }
    }

    private void informarCamposEnvioTrasladoRemitidoAutomatico(List<EmailMessage> listNewObj) {
        
        //Casos con traslado a colaborador automático - Informamos los campos CC_Procedencia__c y CC_Grupo_Colab__c
        // Añadimos la condición caso.CC_Ultima_Interaccion__c == 'Traslado pendiente' (se informa en el OS_Case) 
        //caso.CBK_Traslado_Remitido__c = null para que no se vuelva a informar este campo en el resto de emails

        Map<Id,EmailMessage> mapCorreoCaso = new Map<Id,EmailMessage>();
        for (EmailMessage correo : listNewObj) {
            if(!correo.Incoming) {
                mapCorreoCaso.put(correo.ParentId, correo);
            }
        }
        if(!mapCorreoCaso.isEmpty()) {
            List<Case> casos = [SELECT Status, OS_Cerrado_Operativa__c, CC_Grupo_Colaborador__c, CBK_Traslado_Remitido__c, CC_Ultima_Interaccion__c FROM Case WHERE Id IN :mapCorreoCaso.keySet() 
                                    AND CC_Ultima_Interaccion__c = 'Traslado pendiente' AND (CBK_Traslado_Remitido__c = 'Traslado' OR CBK_Traslado_Remitido__c = 'Remitido')];

            for (Case caso : casos) {
                if (caso.CBK_Traslado_Remitido__c == 'Traslado') {
                    mapCorreoCaso.get(caso.Id).CC_Procedencia__c = 'Traslado Colaborador';
                    mapCorreoCaso.get(caso.Id).CC_Grupo_Colab__c = caso.CC_Grupo_Colaborador__c;
                } else if (caso.CBK_Traslado_Remitido__c == 'Remitido') {
                    mapCorreoCaso.get(caso.Id).CC_Procedencia__c = 'Remitir Colaborador';
                    mapCorreoCaso.get(caso.Id).CC_Grupo_Colab__c = caso.CC_Grupo_Colaborador__c;
                }
                caso.CBK_Traslado_Remitido__c = null;   
            }
            if(!casos.isEmpty()) {
                Update casos;
            }
        }
    }

    private static void validarDestinatariosCorreo(List<EmailMessage> listNewObj) {

        //Lista de emails salientes
        Set<Id> casosEmailMessage = new Set<Id>();
        for(EmailMessage correo: listNewObj) {
            if(!correo.Incoming) {
                casosEmailMessage.add(correo.ParentId);
            }
        }
        //Evaluamos solo si hay emails salientes
        if(!casosEmailMessage.isEmpty()) {
            //Departamentos para los que hay que validar los correos salientes
            List<CC_Lista_Valores__c> departamentosValidar = [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'COPS: Departamentos validar destinatarios correo saliente' AND CC_Activa__c = true];
            Set<String> departamentosValidarSet = new Set<String>();
            for(CC_Lista_Valores__c departamento: departamentosValidar) {
                departamentosValidarSet.add(departamento.Name);
            }
            
            //Histórico de correos relacionados con el caso
            List<EmailMessage> historicoCorreos = [SELECT Id, FromAddress, ToAddress, CcAddress, BccAddress, ParentId, Parent.OS_Departamento__c, Parent.AccountId FROM EmailMessage WHERE ParentId = :casosEmailMessage];
            Map<Id, List<EmailMessage>> casoIdListaCorreosMap = new Map<Id, List<EmailMessage>>();
            for(EmailMessage correoHistorico: historicoCorreos) {
                if(!casoIdListaCorreosMap.containsKey(correoHistorico.ParentId)) {
                    casoIdListaCorreosMap.put(correoHistorico.ParentId, new List<EmailMessage>());
                }
                List<EmailMessage> correosCasoList = casoIdListaCorreosMap.get(correoHistorico.ParentId);
                correosCasoList.add(correoHistorico);            
            }

            Map<EmailMessage, Set<String>> correoDireccionesValidarMap = new Map<EmailMessage, Set<String>>();
            Set<String> direccionesCorreoRevisar = new Set<String>();
            Map<Id, Id> casoAccountMap = new Map<Id, Id>();
            //Comprobamos si los destinatarios salientes están entre los receptores del histórico de emails
            for(EmailMessage correo: listNewObj) {
                if(!correo.Incoming) {
                    if(casoIdListaCorreosMap.containsKey(correo.ParentId)) {
                        List<EmailMessage> correosHistoricoCaso = casoIdListaCorreosMap.get(correo.ParentId);
                        //Comprobamos que el departamento del caso esté en el listado de casos para los que se deben comprobar los destinatarios (el departamento del caso de cualquier correo será el mismo que el del caso del correo que iteramos)
                        if(departamentosValidarSet.contains(correosHistoricoCaso[0].Parent.OS_Departamento__c)) {
                            //Listado de direcciones de email contenidas en el histórico de correos del caso
                            //Quitamos los espacios con .replaceAll( '\\s+', '')
                            Set<String> direccionesCorreosHistoricos = new Set<String>();
                            for(EmailMessage correoHistorico: correosHistoricoCaso) {
                                direccionesCorreosHistoricos.add(correoHistorico.FromAddress);
                                if(correoHistorico.ToAddress != null) direccionesCorreosHistoricos.addAll(correoHistorico.ToAddress.replaceAll( '\\s+', '').split(';'));
                                if(correoHistorico.CcAddress != null) direccionesCorreosHistoricos.addAll(correoHistorico.CcAddress.replaceAll( '\\s+', '').split(';'));
                                if(correoHistorico.BccAddress != null) direccionesCorreosHistoricos.addAll(correoHistorico.BccAddress.replaceAll( '\\s+', '').split(';'));
                            }
                            //Listado de direcciones contenidas en el email saliente
                            //Quitamos los espacios con .replaceAll( '\\s+', '')
                            Set<String> direccionesCorreoSaliente = new Set<String>();
                            if(correo.ToAddress != null) direccionesCorreoSaliente.addAll(correo.ToAddress.replaceAll( '\\s+', '').split(',')); //En AI separado por ";"
                            if(correo.CcAddress != null) direccionesCorreoSaliente.addAll(correo.CcAddress.replaceAll( '\\s+', '').split(',')); //En AI separado por ";"
                            if(correo.BccAddress != null) direccionesCorreoSaliente.addAll(correo.BccAddress.replaceAll( '\\s+', '').split(',')); //En AI separado por ";"

                            for(String direccionSaliente: direccionesCorreoSaliente) {
                                if(!direccionesCorreosHistoricos.contains(direccionSaliente)) {
                                    //Caso-AccountId
                                    casoAccountMap.put(correosHistoricoCaso[0].ParentId, correosHistoricoCaso[0].Parent.AccountId);
                                    //Lista de direcciones de correo electrónicas no válidas inicialmente por cada correo
                                    direccionesCorreoRevisar.add(direccionSaliente);
                                    if(!correoDireccionesValidarMap.containsKey(correo)) {
                                        correoDireccionesValidarMap.put(correo, new Set<String>());
                                    }
                                    Set<String> direccionesCorreoRevisarAux = correoDireccionesValidarMap.get(correo);
                                    direccionesCorreoRevisarAux.add(direccionSaliente);
                                }
                            }
                        }
                    }
                }
            }
            //Evaluamos las direcciones que no han pasado el primer filtro
            if(!correoDireccionesValidarMap.keySet().isEmpty()) {
                //Set de dominios de los correos a validar
                Set<String> dominiosRevisar = new Set<String>();
                for(String direccionRevisar: direccionesCorreoRevisar) {
                    dominiosRevisar.add('@' + direccionRevisar.substringAfter('@'));
                }
                List<CC_Administracion_Lista_Blanca__c> dominiosAdmitidos = [SELECT Name FROM CC_Administracion_Lista_Blanca__c WHERE CBK_Negocio__c = 'COPS' AND CC_Canal_Contacto__c = :'Email' AND CC_Activo__c = true AND Name = :dominiosRevisar];
                //Dominios admitidos de la lista de valores
                Set<String> dominiosAdmitidosSet = new Set<String>();
                for(CC_Administracion_Lista_Blanca__c dominioLista: dominiosAdmitidos) {
                    dominiosAdmitidosSet.add(dominioLista.Name);
                }

                //Contactos de tipo colaborador y buzón acceptados, o relacionados con la cuenta del caso
                List<Contact> contactosValidos = [SELECT Email, AccountId, Recordtype.DeveloperName FROM Contact WHERE (Recordtype.DeveloperName = 'OS_Buzon_Contact' OR Recordtype.DeveloperName = 'CC_Colaborador' OR AccountId = :casoAccountMap.values()) AND Email = :direccionesCorreoRevisar];
                //Contactos tipo colaborador o buzón
                Set<String> direccionesBuzonesColaboradores = new Set<String>();
                //Contactos relacionados con la cuenta del caso aceptados
                Map<Id, Set<String>> accountIdDireccionesContactos = new Map<Id, Set<String>>();
                for(Contact contacto: contactosValidos) {
                    if(contacto.Recordtype.DeveloperName == 'OS_Buzon_Contact' || contacto.Recordtype.DeveloperName == 'CC_Colaborador') {
                        direccionesBuzonesColaboradores.add(contacto.Email);
                    }
                    if(!accountIdDireccionesContactos.containsKey(contacto.AccountId)) {
                        accountIdDireccionesContactos.put(contacto.AccountId, new Set<String>());
                    }
                    Set<String> direccionesContacto = accountIdDireccionesContactos.get(contacto.AccountId);
                    direccionesContacto.add(contacto.Email);
                }
                
                //Evaluamos las direcciones salientes restantes
                for(EmailMessage correo: correoDireccionesValidarMap.keySet()) {
                    String mensajeErrorFinal = '';
                    Boolean correoApto = true;
                    Set<String> correosInvalidos = new Set<String>();
                    //Listado de direcciones contenidas en el email salient
                    Set<String> direccionesSegundaRevision = correoDireccionesValidarMap.get(correo);
                    for(String direccionCorreo: direccionesSegundaRevision) {
                        String mensajeError = 'La dirección de correo '+ direccionCorreo + ' no es válida: ';
                        //Revisamos buzones y colaboradores
                        if(direccionesBuzonesColaboradores.contains(direccionCorreo)) {
                            correoApto = true;
                        }
                        else {
                            correoApto = false;
                            mensajeError += 'No está entre los contactos de tipo buzón COPS y colaborador dados de alta. ';
                            
                            //Revisamos dominios
                            String dominioDireccionCorreo = '@' + direccionCorreo.substringAfter('@');
                            if(dominiosAdmitidosSet.contains(dominioDireccionCorreo)) {
                                correoApto = true;
                            }
                            else {
                                correoApto = false;
                                mensajeError += 'No está entre los dominios admitidos. ';

                                //Revisamos contactos de la cuenta del caso
                                //Sacamos la cuenta del caso
                                if(casoAccountMap.containsKey(correo.ParentId)) {
                                    Id cuentaCorreoId = casoAccountMap.get(correo.ParentId);
                                    //Revisamos si la cuenta tiene contactos con los emails indicados
                                    if(accountIdDireccionesContactos.containsKey(cuentaCorreoId)) {
                                        Set<String> direccionesContactosCuenta = accountIdDireccionesContactos.get(cuentaCorreoId);
                                        if(direccionesContactosCuenta.contains(direccionCorreo)) {                                
                                            correoApto = true; 
                                        }
                                        else {
                                            correoApto = false; 
                                            mensajeError += 'No está entre los contactos relacionados con la cuenta del caso. ';
                                        }
                                    }
                                    //Si no hay contactos para la cuenta que coincidan con el email buscado
                                    else {
                                        correoApto = false;
                                        mensajeError += 'No está entre los contactos relacionados con la cuenta del caso. ';
                                    }
                                }
                            }
                        }
                        if(!correoApto) {
                            correosInvalidos.add(direccionCorreo);
                            mensajeErrorFinal += mensajeError;
                        }
                    }
                    if(!correosInvalidos.isEmpty()) {
                        correo.addError(mensajeErrorFinal);
                    }
                }
            }
        }
    }
    /*private static List<EmailMessage> filtrarEmailMessageNoOS(List<EmailMessage> correos) {
        List<EmailMessage> correosCops = new List<EmailMessage>();
        Set<Id> idsPadre = new Set<Id>();
        for (EmailMessage correo : correos) {
            if (String.isNotBlank(correo.ParentId)) {
                idsPadre.add(correo.ParentId);
            } else if (String.isNotBlank(correo.RelatedToId)) {
                idsPadre.add(correo.RelatedToId);
            }
        }
        if (!idsPadre.isEmpty()) {
            Map<Id, EmailMessage> mapaCorreos = new Map<Id, EmailMessage>();
            for (EmailMessage correo : correos) {
                mapaCorreos.put(correo.Id, correo);
            }
            Set<Id> idCasosCops = new Set<Id>();
            for (Case casoCops : [SELECT Id FROM Case WHERE Id IN :idsPadre AND RecordType.DeveloperName LIKE 'OS_%']) {
                idCasosCops.add(casoCops.Id);
            }
            for (EmailMessage correo : correos) { 
                if (idCasosCops.contains(correo.ParentId) || idCasosCops.contains(correo.RelatedToId)) {
                    correosCops.add(mapaCorreos.get(correo.Id));
                }   
            }
        }
        return correosCops;
    }*/
}