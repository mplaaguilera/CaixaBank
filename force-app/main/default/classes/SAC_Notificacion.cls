/*****************************************************************
 * Name: SAC_Notificacion
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Poder lanzar el Process Builder con el cambio del
 *            valor del picklist Milestone Completado del objeto 
 *            Case
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US219258        Marcela Neira     17/06/21      Creación Clase
 * 
 * 1.1              NaN          Luis Mesa Garcia   16/09/21      Modificación
 *                               Carlos Solis Caño
 *
 *  Proposito nuevo: Modificar la clase para que en vez de llamar 
 * al process builder realice las emisiones de notificaciones 
 * desde trigger, para evitar problemas con metodos con la 
 * etiqueta @future
 *  
 * 
*****************************************************************/
public without sharing class SAC_Notificacion {

    private static Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    private static Id recTypeEscaladoNV3 = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
    // Get the Id for our custom notification type
    private static CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                                FROM CustomNotificationType 
                                                                WHERE DeveloperName='SAC_EscaladoAtendido'];

    public static void comprobar(List<Case> listaCasos, List<Case> listaCasosSelect, Group cola){
        
        //Set<Id> idesCasosAlta = new Set<Id>(); US458927 eliminar notificaciones de SLA ALTA
        Set<Id> ides48Letrado = new Set<Id>();
        Set<Id> ides48Regulatorio = new Set<Id>();
        Set<Id> ides24Letrado = new Set<Id>();
        Set<Id> ides24Regulatorio = new Set<Id>(); 
        Map<Id, Case> mapaCasosSelect = new Map<Id, Case>(listaCasosSelect);

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        for(Case caso: listaCasos){

            //US458927 eliminar notificaciones de SLA ALTA
            /*if(caso.OS_SLA_Completado__c == 'SLAAltaEntitlement' && caso.recordTypeId==recTypeReclamacion){
                idesCasosAlta.add(caso.id);
                //Preparación de la alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.id, 
                                                                    'SAC_007', 
                                                                    'Ha superado el SLA de alta de la reclamación ' + caso.CaseNumber + '. Revisar la reclamación ' + caso.CaseNumber,
                                                                    caso.OwnerId,
                                                                    '',
                                                                    '',
                                                                    '');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

            }else */
            if(caso.OS_SLA_Completado__c == '48LetradoEntitlement' && caso.recordTypeId==recTypePretension){
                ides48Letrado.add(caso.id);
                //Preparación de la alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.SAC_Reclamacion__c,'SAC_SLALetrado48','Quedan 48 Horas para cumplir el SLA de la pretensión ' + caso.CaseNumber + '. Revisar la pretensión ' + caso.CaseNumber,caso.OwnerId,caso.Id,'','');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

            }else if(caso.OS_SLA_Completado__c == '24LetradoEntitlement' && caso.recordTypeId==recTypePretension){
                ides24Letrado.add(caso.id);
                //Preparación de la alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.SAC_Reclamacion__c,'SAC_SLALetrado24','SLA Letrado excedido. El SLA de la pretensión ' + caso.CaseNumber + ' ha sido excedido',caso.OwnerId,caso.Id,'','');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

                //Si es hay una pret principal con letrado, se manda al letrado
            }else if(caso.OS_SLA_Completado__c == '48RegulatorioEntitlement' && caso.recordTypeId==recTypeReclamacion && mapaCasosSelect.containsKey(caso.SAC_PretensionPrincipal__c)){
                ides48Regulatorio.add(caso.id);
                //Preparación de la alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,'SAC_SLARegulatorio48','Quedan 48 horas para cumplir el SLA Regulatorio de la reclamación ' + caso.CaseNumber + '. Revisar la Reclamación ' + caso.CaseNumber,mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).OwnerId,'','','');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                if (mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).OwnerId == cola.Id && String.isNotBlank(mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).SEG_Grupo__r.SAC_Email__c)) {
                    wrapAlerta.listaEmailsGrupo.add(mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).SEG_Grupo__r.SAC_Email__c);
                }
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

                //Si es NO hay una pret principal con letrado, se manda al gestor
            }else if(caso.OS_SLA_Completado__c == '48RegulatorioEntitlement' && caso.recordTypeId==recTypeReclamacion && !mapaCasosSelect.containsKey(caso.SAC_PretensionPrincipal__c) && mapaCasosSelect.containsKey(caso.Id)){
                ides48Regulatorio.add(caso.id);
                //Preparación de la alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                    'SAC_SLARegulatorio48',
                                                                    'Quedan 48 horas para cumplir el SLA Regulatorio de la reclamación ' + caso.CaseNumber + '. Revisar la Reclamación ' + caso.CaseNumber,
                                                                    caso.OwnerId,
                                                                    '',
                                                                    '',
                                                                    '');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                if (mapaCasosSelect.get(caso.Id).OwnerId == cola.Id && String.isNotBlank(mapaCasosSelect.get(caso.Id).SEG_Grupo__r.SAC_Email__c)) {
                    wrapAlerta.listaEmailsGrupo.add(mapaCasosSelect.get(caso.Id).SEG_Grupo__r.SAC_Email__c);
                }
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

                //Si es hay una pret principal con letrado, se manda al letrado
            }else if(caso.OS_SLA_Completado__c == '24RegulatorioEntitlement' && caso.recordTypeId==recTypeReclamacion && mapaCasosSelect.containsKey(caso.SAC_PretensionPrincipal__c)){
                ides24Regulatorio.add(caso.id);
                //Preparación de la alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,'SAC_SLARegulatorio24','SLA Regulatorio Excedido. Revisar la Reclamación ' + caso.CaseNumber + ', el SLA de la reclamación ha sido excedido',mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).OwnerId,'','','');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                if (mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).OwnerId == cola.Id && String.isNotBlank(mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).SEG_Grupo__r.SAC_Email__c)) {
                    wrapAlerta.listaEmailsGrupo.add(mapaCasosSelect.get(caso.SAC_PretensionPrincipal__c).SEG_Grupo__r.SAC_Email__c);
                }
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

                //Si es NO hay una pret principal con letrado, se manda al gestor
            }else if(caso.OS_SLA_Completado__c == '24RegulatorioEntitlement' && caso.recordTypeId==recTypeReclamacion && !mapaCasosSelect.containsKey(caso.SAC_PretensionPrincipal__c) && mapaCasosSelect.containsKey(caso.Id)){
                ides24Regulatorio.add(caso.id);
                //Preparación de la alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                    'SAC_SLARegulatorio24',
                                                                    'SLA Regulatorio Excedido. Revisar la Reclamación ' + caso.CaseNumber + ', el SLA de la reclamación ha sido excedido',
                                                                    caso.OwnerId,
                                                                    '',
                                                                    '',
                                                                    '');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                if (mapaCasosSelect.get(caso.Id).OwnerId == cola.Id && String.isNotBlank(mapaCasosSelect.get(caso.Id).SEG_Grupo__r.SAC_Email__c)) {
                    wrapAlerta.listaEmailsGrupo.add(mapaCasosSelect.get(caso.Id).SEG_Grupo__r.SAC_Email__c);
                }
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);
            }
            caso.OS_SLA_Completado__c = '';
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /*public static void enviarNotificaciones(String recipientId, String targetId, String titulo, String contenidoMensaje, CustomNotificationType notificationType) {
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(titulo);
        notification.setBody(contenidoMensaje);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);

        // Actually send the notification
        Set<String> setRecipientId = new Set<String>();
        setRecipientId.add(recipientId);
        try {
            notification.send(setRecipientId);
        }
        catch (Exception e) {
            
        }
    }*/

    /*****************************************************************
     * Proposito: Llama al metodo para mandar notificaciones cuando el estado del caso
     * cambia a 'Derivado'. Notifica a el letrado de que su reclamación padre a
     * pasado a estado Derivado y la pretensión hija a estado Baja.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271730         Carlos Solis   24/09/21     Creación
    *****************************************************************/
    public static void derivacion(Map<Id, Case> mapaReclamaciones, List<Case> listaCasosSelect, Map<Id, Case> mapaDatosCasosActualizar){
        List<Case> listaPretensionesHijas = new List<Case>();        
        Set<Case> casosNotificar = new Set<Case>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        for (Case caso : listaCasosSelect) {
            if (caso.RecordTypeId == recTypePretension && mapaReclamaciones.containsKey(caso.SAC_Reclamacion__c)) {
                listaPretensionesHijas.add(caso);
            }
        }

        if (!listaPretensionesHijas.isEmpty()) {
            for (Case caso : listaPretensionesHijas) {
                if (mapaReclamaciones.containsKey(caso.SAC_Reclamacion__c)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.SAC_Reclamacion__c,
                                                                        'SAC_008',
                                                                        'Se ha derivado la reclamación ' + mapaReclamaciones.get(caso.SAC_Reclamacion__c).CaseNumber +
                                                                        '. La pretensión ' + caso.CaseNumber + ' ha pasado a estado "Baja"',
                                                                        caso.OwnerId,
                                                                        caso.Id,
                                                                        '',
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.SAC_Reclamacion__c;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);

                    /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                    enviarNotificacion(caso.OwnerId,
                                        caso.Id, 
                                        'Se ha derivado la reclamación ' + mapaReclamaciones.get(caso.SAC_Reclamacion__c).CaseNumber,
                                        'La pretensión ' + caso.CaseNumber + ' ha pasado a estado "Baja"');*/
                    /*caso.SAC_NotificacionSinLeer__c = true;
                    caso.OS_Alerta_Fecha__c = system.now();
                    casosNotificar.add(caso);*/

                }
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }

        /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
        if(!casosNotificar.isEmpty()){
            for (Case caso : casosNotificar) {
                if(mapaDatosCasosActualizar.containsKey(caso.id)){
                    mapaDatosCasosActualizar.get(caso.id).SAC_NotificacionSinLeer__c = caso.SAC_NotificacionSinLeer__c;
                    mapaDatosCasosActualizar.get(caso.id).OS_Alerta_Fecha__c = caso.OS_Alerta_Fecha__c;
                }else if (!mapaDatosCasosActualizar.containsKey(caso.id)){
                    mapaDatosCasosActualizar.put(caso.id, caso);
                }
            }
        }*/
    }

    /*****************************************************************
     * Proposito: Mandar notificaciones a los letrados de las pretensiones cuando cambia el gestor de la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271705         Carlos Solis   01/10/21     Creación
    *****************************************************************/
    /*public static void notificarCambioOwner(Map<Id, Case> mapaReclamaciones, List<Case> listaSelect, Map<Id, Case> mapaDatosCasosActualizar) {
        List<Case> listaPretensionesNotificar = new List<Case>();
        Set<Case> casosNotificar = new Set<Case>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        //Si el caso es una pretension hija de una reclamación a la que le ha cambiado el OwnerId (filtrado en el trigger), lo añado a una lista
        for (Case caso : listaSelect) {
            if (caso.RecordTypeId == recTypePretension && String.isNotBlank(caso.SAC_Reclamacion__c) && mapaReclamaciones.containsKey(caso.SAC_Reclamacion__c)) {
                listaPretensionesNotificar.add(caso);
            }
        }

        if (!listaPretensionesNotificar.isEmpty()) {
            //Mapa para no repetir notificaciones por cada pretensión de la reclamación (el letrado es el mismo en todas las pretensiones)
            Map<Id, Case> mapaPretConMismoOwner = new Map<Id, Case>();
            for (Case pret : listaPretensionesNotificar) {
                if (!mapaPretConMismoOwner.containsKey(pret.SAC_Reclamacion__c)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(mapaReclamaciones.get(pret.SAC_Reclamacion__c).Id,
                                                                        'SAC_009',
                                                                        'La reclamación ' + mapaReclamaciones.get(pret.SAC_Reclamacion__c).caseNumber + 
                                                                        ' ha sido asignada a otro gestor',
                                                                        pret.OwnerId,
                                                                        '',
                                                                        '',
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + mapaReclamaciones.get(pret.SAC_Reclamacion__c).Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);

                    mapaPretConMismoOwner.put(pret.SAC_Reclamacion__c, pret);
                }
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }*/
    
    /*****************************************************************
     * Proposito: Mandar notificaciones al gestor de la reclamación cuando cambia de redacción a ejecución
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271705         Carlos Solis   04/10/21     Creación
     * 1.1            US458927         Carlos Solis   05/10/22     Se añade una alerta también para el letrado
    *****************************************************************/
    public static void notificarEjecucion(Map<Id, Case> mapaReclamaciones, List<Case> listaCasosSelect) {
        //Filtrar las pretensiones principales de las reclamaciones para poder guardarlas posteriormente en un mapa
        Map<Id, Id> mapaIdsPretsPrincipales = new Map<Id, Id>();
        for (Case reclamacion : mapaReclamaciones.values()) {
            mapaIdsPretsPrincipales.put(reclamacion.SAC_PretensionPrincipal__c, reclamacion.SAC_PretensionPrincipal__c);
        }
        
        //Guardar las pretensiones principales en su mapa
        Map<Id, Case> mapaPretsPrincipales = new Map<Id, Case>();
        for (Case casoSelect : listaCasosSelect) {
            if (mapaIdsPretsPrincipales.containsKey(casoSelect.Id)) {
                mapaPretsPrincipales.put(casoSelect.Id, casoSelect);
            }
        }

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
         
        for (Case caso : mapaReclamaciones.values()) {
            //Alerta para el gestor
            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                'SAC_010',
                                                                'El letrado ha enviado la resolución de la reclamación ' + caso.CaseNumber + 
                                                                ' al reclamante y ha activado la fase de ejecución la cual se debe controlar para cumplir con la fecha máxima informada al reclamante.',
                                                                caso.OwnerId,
                                                                '',
                                                                '',
                                                                '');
                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
            //Añadirla a la lista para posteriormente llamar al método
            listaWrapperAlerta.add(wrapAlerta);

            if(mapaPretsPrincipales.get(caso.SAC_PretensionPrincipal__c) != null){
                //Alerta para el letrado
                SAC_WrapperAlerta wrapAlertaLetrado = new SAC_WrapperAlerta(caso.Id,
                                                                    'SAC_010',
                                                                    'El letrado ha enviado la resolución de la reclamación ' + caso.CaseNumber + 
                                                                    ' al reclamante y ha activado la fase de ejecución la cual se debe controlar para cumplir con la fecha máxima informada al reclamante.',
                                                                    mapaPretsPrincipales.get(caso.SAC_PretensionPrincipal__c).OwnerId,
                                                                    '',
                                                                    '',
                                                                    '');
                                                                    wrapAlertaLetrado.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlertaLetrado);
                
                /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                enviarNotificacion(caso.OwnerId,
                                    caso.Id,
                                    'Ejecución activa',
                                    'El letrado ha enviado la resolución de la reclamación ' + caso.CaseNumber + ' al reclamante y ha activado la fase de ejecución la cual se debe controlar para cumplir con la fecha máxima informada al reclamante.');*/
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /*****************************************************************
     * Proposito: Mandar notificaciones al gestor de la reclamación cuando cambia de análisis a alta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271705         Carlos Solis   04/10/21     Creación
    *****************************************************************/
    public static void  notificarVolverAlta(List<Case> listaReclamaciones) {
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
         
        for (Case caso : listaReclamaciones) {
            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                'SAC_011',
                                                                'Devolución letrado a gestor. ' + 
                                                                'Se ha devuelto la reclamación ' + caso.CaseNumber + ' a estado de alta. Debe volver a revisar la reclamación.',
                                                                caso.OwnerId,
                                                                '',
                                                                '',
                                                                '');
                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
            //Añadirla a la lista para posteriormente llamar al método
            listaWrapperAlerta.add(wrapAlerta);

            /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
            enviarNotificacion(caso.OwnerId,
            caso.Id,
            'Devolución letrado a gestor',
            'Se ha devuelto la reclamación ' + caso.CaseNumber + ' a estado de alta. Debe volver a revisar la reclamación.');*/
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    
    /*****************************************************************
     * Proposito: Mandar notificaciones al gestor y al letrado cuando el gestor/letrado solicita una consulta a un equipo colaborador
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271705         Carlos Solis   05/10/21     Creación
     * 1.1            US458927         CS             04/10/22     Comentado ya que no se quiere utilizar por ahora
    *****************************************************************/
    /*public static void notificarConsulta(List<Case> listaRecYPret, List<SAC_Interaccion__c> listaConsultas) { //Se llama desde el SAC_Interaccion_AI_TRHan
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();
        Map<Id, Case> mapaPretensionesInformadas = new Map<Id, Case>();
        List<Case> listaPretensiones = new List<Case>();
        Set<Case> casosNotificar = new Set<Case>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        Map<Id, List<SAC_Interaccion__c>> mapaRecConsulta = new Map<Id, List<SAC_Interaccion__c>>();

        for (Case caso : listaRecYPret) {
            if (caso.RecordTypeId == recTypeReclamacion) {
                mapaReclamaciones.put(caso.Id, caso);
            }
            if (caso.RecordTypeId == recTypePretension) {
                listaPretensiones.add(caso);
            }
        }

        //Montar mapa con las consultas que tiene cada reclamación
        for (SAC_Interaccion__c consulta : listaConsultas) {
            if (mapaRecConsulta.containsKey(consulta.SAC_Reclamacion__c)) {
                mapaRecConsulta.get(consulta.SAC_Reclamacion__c).add(consulta);
            } else {
                List<SAC_Interaccion__c> listaConsult = new List<SAC_Interaccion__c>();
                listaConsult.add(consulta);
                mapaRecConsulta.put(consulta.SAC_Reclamacion__c, listaConsult);
            }
        }

        for (Case caso : mapaReclamaciones.values()) {
            //Recorrer todas las consultas que hayan entrado de esta reclamación para poder informar cada consulta en el registro de la alerta
            if (mapaRecConsulta.containsKey(caso.Id)) {
                for (SAC_Interaccion__c consulta : mapaRecConsulta.get(caso.Id)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                        'SAC_012',
                                                                        'Se ha realizado una consulta a un colaborador en la reclamación ' + caso.CaseNumber + '.',
                                                                        caso.OwnerId,
                                                                        '',
                                                                        '',
                                                                        consulta.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + consulta.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
            }
        }

        for (Case caso : listaPretensiones) {
            if (mapaReclamaciones.containsKey(caso.SAC_Reclamacion__c) && mapaReclamaciones.get(caso.SAC_Reclamacion__c).OwnerId != caso.OwnerId && !mapaPretensionesInformadas.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaRecConsulta.containsKey(caso.SAC_Reclamacion__c)) {
                    for (SAC_Interaccion__c consulta : mapaRecConsulta.get(caso.SAC_Reclamacion__c)) {
                        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.SAC_Reclamacion__c,
                                                                            'SAC_012',
                                                                            'Se ha realizado una consulta a un colaborador en la reclamación ' + mapaReclamaciones.get(caso.SAC_Reclamacion__c).CaseNumber + '.',
                                                                            caso.OwnerId,
                                                                            '',
                                                                            '',
                                                                            consulta.Id);
                                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + consulta.Id;
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                }
                //Informo que esta reclamación ya tiene la notificación en su letrado (todas las pretensiones tienen el mismo letrado)
                mapaPretensionesInformadas.put(caso.SAC_Reclamacion__c, caso);
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }*/

    /*****************************************************************
     * Proposito: Mandar notificaciones al gestor y el letrado cuando llega una nueva reclamación a SF y se vincula a una anterior viva.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271705         Carlos Solis   05/10/21     Creación
    *****************************************************************/ 
    public static void notificarCasoCreadoVinculado(List<Case> listaCasosSelect, List<Case> listNewReclamaciones, List<Id> listaIdsCuentas) {
        Map<Id, Case> mapaReclamacionesNotificar = new Map<Id, Case>();
        Map<Id, Case> mapaPretensionesNotificar = new Map<Id, Case>();
        List<Case> listaPretensiones = new List<Case>();
        List<Case> listaNewRecConAccount = new List<Case>();
        List<Id> listaIdsReclamaciones = new List<Id>();
        Map<Id, Case> mapaCasosNotificar = new Map<Id, Case>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        //Monto un mapa con las Ids de las cuentas que vienen informadas al crear los casos
        Map<Id, Id> mapaIdsCuentas = new Map<Id, Id>(); 
        for (Id idCuenta : listaIdsCuentas) {
            mapaIdsCuentas.put(idCuenta, idCuenta);
        }

        //Guardo en el mapa mapaReclamacionesNotificar los casos que sean reclamaciones, que tengan una cuenta que ha entrado en algun caso nuevo y que sigan abiertos
        //Los guardo tambien en una lista de Ids para buscar sus pretensiones hijas
        for (Case caso : listaCasosSelect) {
            if (caso.RecordTypeId == recTypeReclamacion && mapaIdsCuentas.containsKey(caso.AccountId) && !caso.isClosed) {
                mapaReclamacionesNotificar.put(caso.Id, caso);
                listaIdsReclamaciones.add(caso.Id);
            }
        }

        //Busco las pretensiones hijas
        listaPretensiones = [SELECT Id, CaseNumber, RecordTypeId, SAC_Reclamacion__c, OwnerId, AccountId FROM Case WHERE SAC_Reclamacion__c IN :listaIdsReclamaciones];

        //De las pretensiones que he guardado en una lista, recojo las que son hijas de las reclamaciones que he guardado anteriormente en mapaReclamacionesNotificar
        for (Case caso : listaPretensiones) {
            if (mapaReclamacionesNotificar.containsKey(caso.SAC_Reclamacion__c)) {
                mapaPretensionesNotificar.put(caso.SAC_Reclamacion__c, caso); //Con poner una de las pretensiones basta, ya que todas las pretensiones tienen el mismo owner
            }
        }

        //De las reclamaciones que vienen por el trigger, me guardo las que tengan un AccountId
        for (Case caso : listNewReclamaciones) {
            if (String.isNotBlank(caso.AccountId)) {
                listaNewRecConAccount.add(caso);
            }
        }

        //Mapa para ver cuantas reclamaciones nuevas vienen por cada accountId
        Map<Id, List<Case>> mapaNewRecConAccount = new Map<Id, List<Case>>();
        for (Case caso : listaNewRecConAccount) {
            if (!mapaNewRecConAccount.containsKey(caso.AccountId)) {
                List<Case> lista = new List<Case>();
                lista.add(caso);
                mapaNewRecConAccount.put(caso.AccountId, lista);
            } else {
                mapaNewRecConAccount.get(caso.AccountId).add(caso);
            }
        }

        //Para cada reclamacion, compruebo cuantas reclamaciones nuevas han entrado y mando notificación por cada una de ellas
        //Además, manda notificación al Owner de las pretensiones de la reclamación
        Map<Id, Map<Id, Id>> mapaAccountOwnerInformado = new Map<Id, Map<Id, Id>>();
        Map<Id, Id> mapaOwnerAux = new Map<Id, Id>(); //Mapa de apoyo para el mapaAccountOwnerInformado
        for (Case caso : mapaReclamacionesNotificar.values()) {
            if (!mapaAccountOwnerInformado.containsKey(caso.AccountId)) {
                Map<Id, Id> mapaOwners = new Map<Id, Id>();
                mapaAccountOwnerInformado.put(caso.AccountId, mapaOwners);
            }
            for (Case casoMapa : mapaNewRecConAccount.get(caso.AccountId)) {
                if (casoMapa.OwnerId == caso.OwnerId && mapaNewRecConAccount.containsKey(caso.AccountId) && mapaAccountOwnerInformado.containsKey(caso.AccountId) && !mapaAccountOwnerInformado.get(caso.AccountId).containsKey(caso.OwnerId)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoMapa.Id,
                                                                        'SAC_005',
                                                                        'Se ha recibido una nueva reclamación que parece que tiene relación con la suya. Se le ha asignado a usted para su revisión y visión global del caso. ' +
                                                                        'Reclamacion número ' + casoMapa.CaseNumber,
                                                                        caso.OwnerId,
                                                                        '',
                                                                        '',
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoMapa.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                    
                    /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                    enviarNotificacion(caso.OwnerId,
                    casoMapa.Id,
                    'Reclamación vinculada',
                    'Se ha recibido una nueva reclamación que parece que tiene relación con la suya. Se han vinculado ambas reclamaciones para su revisión y visión global del caso. ' +
                    'Reclamacion número ' + casoMapa.CaseNumber);*/
                    //Guardo el owner que recibe la notificación en un mapa para despues pasarlo al mapa mapaAccountOwnerInformado
                   /* Case cs = new Case();
		            cs.Id = casoMapa.Id;
                    cs.SAC_NotificacionSinLeer__c = true;
                    cs.OS_Alerta_Fecha__c = system.now();
                    mapaCasosNotificar.put(casoMapa.Id, cs);*/
                    mapaOwnerAux.put(caso.OwnerId, caso.OwnerId);
                }
                //US458927 eliminar notificacion al letrado
                /*if (mapaPretensionesNotificar.containsKey(caso.Id) && !mapaAccountOwnerInformado.get(caso.AccountId).containsKey(mapaPretensionesNotificar.get(caso.Id).OwnerId)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoMapa.Id,
                                                                        'SAC_005',
                                                                        'Se ha recibido una nueva reclamación que parece que tiene relación con la suya. Se le ha asignado al gestor para su revisión y visión global del caso. ' +
                                                                        'Reclamacion número ' + casoMapa.CaseNumber,
                                                                        mapaPretensionesNotificar.get(caso.Id).OwnerId,
                                                                        '',
                                                                        '',
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoMapa.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);

                    mapaOwnerAux.put(mapaPretensionesNotificar.get(caso.Id).OwnerId, mapaPretensionesNotificar.get(caso.Id).OwnerId);
                }*/
            }
            //Pongo los owners que he recogido en el 'mapaOwnerAux' en la posición de este account id en el mapa 'mapaAccountOwnerInformado'
            //Así evito que se repitan notificaciones a owners que ya han sido informados sobre casos nuevos con ese AccountId
            mapaAccountOwnerInformado.get(caso.AccountId).putAll(mapaOwnerAux);
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }

        /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
        if(!mapaCasosNotificar.isEmpty()){ 
            update mapaCasosNotificar.values();
        }*/
    }

    /*****************************************************************
     * Proposito: Mandar notificaciones a los letrados(pretensión) de la reclamación padre en la que se encuentra el escalado.
     * La notificación se manda cuando un escalado pasa a estar respondido. 
     * Nota desarrolo : Notifica a los owners de las pretensiones aunque sean distintos
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219272         Carlos Solis   20/07/21     Creación
     * 1.1            US271693         Carlos Solis   25/10/21     Modificación (El enlace al que te lleva la notificación al hacer clic ahora es el registro del escalado)
    *****************************************************************/
    public static void notificarEscaladoAtendido(List<SAC_Interaccion__c> listNew, Map<Id, SAC_Interaccion__c> mapOld) {
        Set<Case> casosNotificar = new Set<Case>();
        List<Id> listaIds = new List<Id>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        //Mapa Id reclamación, lista de escalados
        Map<Id, List<SAC_Interaccion__c>> mapaReclamacionEscalados = new Map<Id, List<SAC_Interaccion__c>>();
        for (SAC_Interaccion__c escalado : listNew) {
            if (mapOld.containsKey(escalado.Id) && escalado.SAC_Estado__c != mapOld.get(escalado.Id).SAC_Estado__c && escalado.SAC_Estado__c == 'SAC_Atendida') {
                if (!mapaReclamacionEscalados.containsKey(escalado.SAC_CasoEscalado__c)) {
                    List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
                    listaEscalados.add(escalado);
                    mapaReclamacionEscalados.put(escalado.SAC_CasoEscalado__c, listaEscalados);
                } else {
                    mapaReclamacionEscalados.get(escalado.SAC_CasoEscalado__c).add(escalado);
                }
                listaIds.add(escalado.SAC_CasoEscalado__c);
            }
        }

        if (!listaIds.isEmpty()) {
            List<Case> listaPretensionesInteracciones = [SELECT Id, SAC_Reclamacion__c, OwnerId, SAC_Reclamacion__r.CaseNumber, SAC_Reclamacion__r.SAC_CasoEspecial__c 
                                                        FROM Case 
                                                        WHERE RecordTypeId = :recTypePretension
                                                        AND SAC_Reclamacion__c IN :listaIds];

            if (!listaPretensionesInteracciones.isEmpty()) {
                //Mapa con key -> Id reclamación, value -> mapa con owners.
                //En él se almacenará, por cada reclamación, que owners de esa familia de casos ya han sido notificados.
                Map<Id, Map<Id, Id>> mapaReclamacionOwners = new Map<Id, Map<Id, Id>>();
                for (Case pretension : listaPretensionesInteracciones) {

                    //Si la reclamacion padre es de presidencia y el recordtype del escalado es de nivel 3, no se debe mandar notificación ya que la mandará al owner del escalado nivel 2 (se manda en el controlador del componente)
                    if (pretension.SAC_Reclamacion__r.SAC_CasoEspecial__c == 'SAC_Presidencia' && mapaReclamacionEscalados.containsKey(pretension.SAC_Reclamacion__c)) {
                        for (Integer i = 0; i < mapaReclamacionEscalados.get(pretension.SAC_Reclamacion__c).size(); i++) {
                            if (mapaReclamacionEscalados.get(pretension.SAC_Reclamacion__c)[i].RecordTypeId == recTypeEscaladoNV3) {
                                mapaReclamacionEscalados.get(pretension.SAC_Reclamacion__c).remove(i);
                            }
                        }
                    }

                    //Si no se ha informado ningún owner en la familia de la reclamación a la que pertenece esta pretensión, creo la posición de la reclamacion padre e inicializo en mapa en el que
                    //iré añadiendo los owners que se hayan notificado en dicha familia de casos.
                    if (!mapaReclamacionOwners.containsKey(pretension.SAC_Reclamacion__c) && mapaReclamacionEscalados.containsKey(pretension.SAC_Reclamacion__c)) {
                        Map<Id, Id> mapaOwners = new Map<Id, Id>();
                        mapaReclamacionOwners.put(pretension.SAC_Reclamacion__c, mapaOwners);
                        for (SAC_Interaccion__c escalado : mapaReclamacionEscalados.get(pretension.SAC_Reclamacion__c)) {
                            //mando notificacion
                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                                                'SAC_EscaladoAtendidoLetrPret',
                                                                                'El escalado ' + escalado.Name + ' de la reclamación ' + pretension.SAC_Reclamacion__r.CaseNumber + ' ha sido atendido. Ya puede revisarlo.',
                                                                                pretension.OwnerId,
                                                                                pretension.Id,
                                                                                '',
                                                                                escalado.Id);
                                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                            //Añadirla a la lista para posteriormente llamar al método
                            listaWrapperAlerta.add(wrapAlerta);

                            /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                            enviarNotificacion(pretension.OwnerId,
                            escalado.Id,
                            'Escalado atendido',
                            'El escalado ' + escalado.Name + ' de la reclamación ' + pretension.SAC_Reclamacion__r.CaseNumber + ' ha sido atendido. Ya puede revisarlo.');*/
                            /*pretension.SAC_NotificacionSinLeer__c = true;
                            pretension.OS_Alerta_Fecha__c = system.now();
                            casosNotificar.add(pretension);*/
                        }
                        //añado owner al mapa de mapas para que no se le vuelvan a notificar escalados de la misma familia de casos
                        mapaReclamacionOwners.get(pretension.SAC_Reclamacion__c).put(pretension.OwnerId, pretension.OwnerId);
                    }
                    //Si el owner no está informado en el mapaReclamacionOwners en la familia de esta reclamación, se le notifica
                    if(mapaReclamacionOwners.containsKey(pretension.SAC_Reclamacion__c) && !mapaReclamacionOwners.get(pretension.SAC_Reclamacion__c).containsKey(pretension.OwnerId) && mapaReclamacionEscalados.containsKey(pretension.SAC_Reclamacion__c)) {
                        for (SAC_Interaccion__c escalado : mapaReclamacionEscalados.get(pretension.SAC_Reclamacion__c)) {
                            //mando notificacion
                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                                                'SAC_EscaladoAtendidoLetrPret',
                                                                                'El escalado ' + escalado.Name + ' de la reclamación ' + pretension.SAC_Reclamacion__r.CaseNumber + ' ha sido atendido. Ya puede revisarlo.',
                                                                                pretension.OwnerId,
                                                                                pretension.Id,
                                                                                '',
                                                                                escalado.Id);
                                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                            //Añadirla a la lista para posteriormente llamar al método
                            listaWrapperAlerta.add(wrapAlerta);

                            /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                            enviarNotificacion(pretension.OwnerId,
                            escalado.Id,
                            'Escalado atendido',
                            'El escalado ' + escalado.Name + ' de la reclamación ' + pretension.SAC_Reclamacion__r.CaseNumber + ' ha sido atendido. Ya puede revisarlo.');*/
                            /*pretension.SAC_NotificacionSinLeer__c = true;
                            pretension.OS_Alerta_Fecha__c = system.now();
                            casosNotificar.add(pretension);*/
                        }
                        //añado owner al mapa de mapas para que no se le vuelvan a notificar escalados de la misma familia de casos
                        mapaReclamacionOwners.get(pretension.SAC_Reclamacion__c).put(pretension.OwnerId, pretension.OwnerId);
                    }
                }

                //Si tenemos alertas que enviar, se llama al método que las envía
                if (!listaWrapperAlerta.isEmpty()) {
                    SAC_Alertas.generarAlertas(listaWrapperAlerta);
                }
            }

            /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
            if(!casosNotificar.isEmpty()){
                List<Case> casosUpdatear = new List<Case>(casosNotificar);
                update casosUpdatear;
            }*/
        }
    }

    /*****************************************************************
     * Proposito: Cuando se cambia el owner de una reclamación, una pretensión o una consulta,
     * se manda una notificación al antiguo owner avisandole del cambio
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271730         Carlos Solis   24/09/21     Creación
    *****************************************************************/ 
    public static void notiAntiguoPropietario(List<Case> listNewCase, Map<Id, Case> mapOldCase, Group cola) {
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        for (Case caso : listNewCase) {
            if (mapOldCase.containsKey(caso.Id) && caso.OwnerId != cola.Id && mapOldCase.get(caso.Id).OwnerId != cola.Id) {
                if (caso.RecordTypeId == recTypeReclamacion) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                        'SAC_NuevoPropietarioCaso',
                                                                        'El caso ' + caso.CaseNumber + ' ha cambiado de propietario',
                                                                        mapOldCase.get(caso.Id).OwnerId,
                                                                        '',
                                                                        '',
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                } else if (caso.RecordTypeId == recTypePretension) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.SAC_Reclamacion__c,'SAC_NuevoPropietarioCaso','El caso ' + caso.CaseNumber + ' ha cambiado de propietario',mapOldCase.get(caso.Id).OwnerId,caso.Id,'','');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                } else {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,'SAC_NuevoPropietarioCaso','El caso ' + caso.CaseNumber + ' ha cambiado de propietario',mapOldCase.get(caso.Id).OwnerId,'','','');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                

                /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                enviarNotificacion(mapOldCase.get(caso.Id).OwnerId,
                                    caso.Id,
                                    'Cambio de propietario en el caso ' + caso.CaseNumber,
                                    'El caso ' + caso.CaseNumber + ' ha cambiado de propietario');*/
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /*****************************************************************
     * Proposito: Manda alerta al gestor o al letrado cuando se ha finalizado una tarea.
     * Si la tarea es de pretensión, la manda al letrado. Si la tarea es de reclamación,
     * la manda al gestor.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         Carlos Solis   30/08/22     Creación
    *****************************************************************/
    public static void notificarTareasFinalizadas(List<SAC_Accion__c> listaTareasCompletadas, List<Case> listaCasosSelect, Group cola) {
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        List<SAC_Accion__c> listaAccionesReclamacion = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaAccionesPretension = new List<SAC_Accion__c>();
        List<Id> listaIdsRecPretPadres = new List<Id>();
        List<Case> listaRecPretPadres = new List<Case>();
        Map<Id, Case> mapaCasosSelect = new Map<Id, Case>(listaCasosSelect);

        for (SAC_Accion__c tarea : listaTareasCompletadas) {
            //Si el campo SAC_Pretension__c está vacío, es una tarea de reclamación
            if (String.isBlank(tarea.SAC_Pretension__c)) {
                listaAccionesReclamacion.add(tarea);        
                listaIdsRecPretPadres.add(tarea.SAC_Reclamacion__c);
            } else { //De lo contrario, es una tarea de pretensión
                listaAccionesPretension.add(tarea);
                listaIdsRecPretPadres.add(tarea.SAC_Pretension__c);
            }
        }

        if (!listaIdsRecPretPadres.isEmpty()) {
            listaRecPretPadres = [SELECT Id, OwnerId FROM Case
                                    WHERE (RecordTypeId = :recTypeReclamacion OR RecordTypeId = :recTypePretension)
                                    AND Id IN :listaIdsRecPretPadres];
        }

        //Si la query nos ha dado resultados, convertimos la lista en mapa y procedemos a preparar las alertas
        if (!listaRecPretPadres.isEmpty()) {
            Map<Id, Case> mapaRecPretPadres = new Map<Id, Case>(listaRecPretPadres);

            //Si tenemos tareas de reclamación, preparamos las alertas para informar al gestor
            if (!listaAccionesReclamacion.isEmpty()) {
                for (SAC_Accion__c tarea : listaAccionesReclamacion) {
                    if (mapaRecPretPadres.containsKey(tarea.SAC_Reclamacion__c)) {
                        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                            'SAC_004',
                                                                            'La tarea ' + tarea.Name + ' ha sido finalizada. Ya puede revisarla.',
                                                                            mapaRecPretPadres.get(tarea.SAC_Reclamacion__c).OwnerId,
                                                                            '',
                                                                            tarea.Id,
                                                                            '');
                                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                        //Si la reclamación padre de la tarea está en pendiente de asignar, le añadimos el email del grupo de la reclamación a la alerta (si no está vacío)
                        if (mapaCasosSelect.containsKey(tarea.SAC_Reclamacion__c) && mapaCasosSelect.get(tarea.SAC_Reclamacion__c).OwnerId == cola.Id && String.isNotBlank(mapaCasosSelect.get(tarea.SAC_Reclamacion__c).SEG_Grupo__r.SAC_Email__c)) {
                            wrapAlerta.listaEmailsGrupo.add(mapaCasosSelect.get(tarea.SAC_Reclamacion__c).SEG_Grupo__r.SAC_Email__c);
                        }
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                    
                }
            }

            //Si tenemos tareas de pretensión, preparamos las alertas para informar al letrado
            if (!listaAccionesPretension.isEmpty()) {
                for (SAC_Accion__c tarea : listaAccionesPretension) {
                    if (mapaRecPretPadres.containsKey(tarea.SAC_Pretension__c)) {
                        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,'SAC_004','La tarea ' + tarea.Name + ' ha sido finalizada. Ya puede revisarla.',mapaRecPretPadres.get(tarea.SAC_Pretension__c).OwnerId,tarea.SAC_Pretension__c,tarea.Id,'');
                                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                        //Si la pretensión padre de la tarea está en pendiente de asignar, le añadimos el email del grupo de la pretensión a la alerta (si no está vacío)
                        if (mapaCasosSelect.containsKey(tarea.SAC_Pretension__c) && mapaCasosSelect.get(tarea.SAC_Pretension__c).ownerId == cola.Id && String.isNotBlank(mapaCasosSelect.get(tarea.SAC_Pretension__c).SEG_Grupo__r.SAC_Email__c)) {
                            wrapAlerta.listaEmailsGrupo.add(mapaCasosSelect.get(tarea.SAC_Pretension__c).SEG_Grupo__r.SAC_Email__c);
                        }
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                    
                }
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /*****************************************************************
     * Proposito: Manda alerta al gestor cuando se responde una consulta (interacción)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         CS             21/09/22     Creación
    *****************************************************************/
    public static void alertaConsultaRespondida(List<SAC_Interaccion__c> listNewInteraccion) {
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        //Recorrer las consultas respondidas y preparar una alerta para cada una
        for (SAC_Interaccion__c consulta : listNewInteraccion) {
            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(consulta.SAC_Reclamacion__c,
                                                                'SAC_022',
                                                                'La consulta ' + consulta.Name + ' ha sido respondida. Ya puede revisarla.',
                                                                consulta.CreatedById,
                                                                '',
                                                                '',
                                                                consulta.Id);
                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + consulta.Id;
            //Añadirla a la lista para posteriormente llamar al método
            listaWrapperAlerta.add(wrapAlerta);
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /*****************************************************************
     * Proposito: Mandar notificaciones personalizadas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US271730         Carlos Solis   24/09/21     Creación
    *****************************************************************/
    public static void enviarNotificacion(String recipientId, String targetId, String titulo, String contenidoMensaje) {
        Boolean hayError = false;
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(titulo);
        notification.setBody(contenidoMensaje);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);

        // Actually send the notification
        Set<String> setRecipientId = new Set<String>();
        setRecipientId.add(recipientId);
        try {
            notification.send(setRecipientId);
        }
        catch (Exception e) {
            hayError = true;
        }
    }  
}