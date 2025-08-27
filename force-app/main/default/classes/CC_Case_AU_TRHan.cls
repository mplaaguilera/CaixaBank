public without sharing class CC_Case_AU_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
	}
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        
        //Obtención RT de Cliente
		Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
		Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        
        List<Case> casesCC = new List<Case>();
        for(Case caso : listNewObj){
            if(caso.RecordTypeId == rtCliente || caso.RecordTypeId == rtEmpleado){
                casesCC.add(caso);   
            }
        }

        actualizarEstadisticasComunicacionInformativa(mapOldObj, casesCC);
        crearPlantillasAgrupadores(mapOldObj, casesCC);
        
		//aviso3NCSBD(mapOldObj, listNewObj);

        //Llamadas CAM
        List<Id> idsCAM = obtenerIdsCAM(listNewObj);
        //Recuperamos los casos de CC (Cliente/Empleado)
        List<Case> lstCasesCC = new List<Case>();
        for(Case caso : listNewObj){
            if(caso.RecordTypeId == rtCliente || caso.RecordTypeId == rtEmpleado){
                if((mapOldObj.get(caso.Id).CC_Facturado__c != caso.CC_Facturado__c) && (mapOldObj.get(caso.Id).CC_Facturado__c == true && caso.CC_Facturado__c == false) ||
                (mapOldObj.get(caso.Id).CC_Facturado__c == caso.CC_Facturado__c)){
                    lstCasesCC.add(caso);
                }
            }
        }

        if(!idsCAM.isEmpty()){
            crearActividadCierreCAM(mapOldObj, listNewObj, idsCAM);
            crearActividadReasignacionCAM(mapOldObj, listNewObj, idsCAM);
        }
    
        if(!lstCasesCC.isEmpty()){
            Map<Id, CC_MCC__c> mapMCC = CC_CaseTriggerHelper.obtencionMCCAplicacionesYServicios();
            CC_CaseTriggerHelper.calcularNumAgrupadores(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.crearActividadCierreCC(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.crearActividadReactivacionCC(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.crearActividadTraslado(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.desvinculacionAgrupadorAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.cambioPropietarioAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.cambioPropietarioActividades(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.getOficinaPersonAccount(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.estadoCerradoAU(lstCasesCC, mapOldObj);
            //CC_CaseTriggerHelper.revisarReclamacionesTwitterAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.cierreCasoAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.limpiarCasosLeadsAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.nuevoCasoPreventivaAU(lstCasesCC, mapOldObj, mapMCC);
            CC_CaseTriggerHelper.notificacionAgenteNoCiAU(lstCasesCC, mapOldObj, mapMCC);
            CC_CaseTriggerHelper.actualizarFechaLimiteAU(lstCasesCC);
            CC_CaseTriggerHelper.nuevoCasoACAU(lstCasesCC, mapOldObj, mapMCC);
            CC_CaseTriggerHelper.incrementoEnNumeroReclamacionesClienteAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.informarAltaGestorAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.informarCierreGestorAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.notificarEmailAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.enviarEncuestaAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.actualizarAgrupadorAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.asociaActivoAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.informarDireccionTerritorialAU(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.reaperturaNoValida(lstCasesCC, mapOldObj);
            CC_CaseTriggerHelper.crearOportunidadCierreCaso(lstCasesCC, mapOldObj);
            //CC_CaseTriggerHelper.cierreCasoHDT1N(lstCasesCC, mapOldObj);
        }

        if(!casesCC.isEmpty()){
            filtrarCasosAccountActualizada(casesCC, mapOldObj);
            CC_CaseTriggerHelper.crearActividadCobrowsing(casesCC, mapOldObj);
            CC_CaseTriggerHelper.devolucionCasosCCOHDT(casesCC, mapOldObj);
        }

        //envioCorreoConsultasOperativasAsignarPropietario(mapOldObj, listNewObj, idsCAM);
        envioCorreoConsultasOperativasTrasladoAsignacionPropietario(mapOldObj, casesCC, idsCAM);

        //Revision de update de Marcas Caso al cerrar el caso
        updateMarcaCasoCierreCaso(mapOldObj, mapNewObj, rtCliente);

        //Revision de campo CC_Tiene_Caracteristicas_Detalle__c en Cuenta y Contacto asociado al Caso
        revisarCaracteristicasDetalle(mapOldObj, mapNewObj, rtCliente);
        
    }

    private void revisarCaracteristicasDetalle(Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj, Id rtCliente) {
        Set<Id> idsContactos = new Set<Id>();
        Set<Id> idsCuentas = new Set<Id>();
         Map<Id,Contact> mapContactsToUpdateById = new Map<Id,Contact>();
        Map<Id,Account> mapAccountsToUpdateById = new Map<Id,Account>();
        for (Case caso : mapNewObj.values()) {
            if(caso.RecordTypeId == rtCliente){
                if (mapOldObj.get(caso.Id).ContactId != caso.ContactId) {
                    if (caso.ContactId != null) {
                        idsContactos.add(caso.ContactId);
                    }
                }
                if (mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                    if (caso.AccountId != null) {
                        idsCuentas.add(caso.AccountId);
                    }
                }
            }
        }
        if(!idsContactos.isEmpty() || !idsCuentas.isEmpty()){
            List<CC_Caracteristica_Detalle__c> lstCaracteristicaDetalle = [SELECT Id, CC_Caracteristica__c, CC_Caracteristica__r.CC_Activo__c,
                                                                            CC_Cliente__c, CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c, 
                                                                            CC_Empleado__c, CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                            CC_Cuenta__c, CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c,
                                                                            CC_Centro_CaixaBank__c , CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c
                                                                        FROM CC_Caracteristica_Detalle__c 
                                                                        WHERE CC_Caracteristica__r.CC_Activo__c = true 
                                                                        AND (
                                                                              CC_Cliente__c IN :idsContactos OR CC_Empleado__c IN :idsContactos OR 
                                                                               CC_Cuenta__c IN :idsCuentas OR CC_Centro_CaixaBank__c IN :idsCuentas)
                                                                        ];
            for(CC_Caracteristica_Detalle__c detalle : lstCaracteristicaDetalle) {
                //Control de que las nuevas cuentas o contactos tengan el campo CC_Tiene_Caracteristica_Detalle__c a true, sino los actualizo
                if (detalle.CC_Cliente__c != null && !detalle.CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c) {
                    Contact c = new Contact(Id = detalle.CC_Cliente__c);
                    c.CC_Tiene_Caracteristica_Detalle__c = true;
                    mapContactsToUpdateById.put(detalle.CC_Cliente__c,c);
                }
                if (detalle.CC_Empleado__c != null && !detalle.CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c) {
                    Contact c = new Contact(Id = detalle.CC_Empleado__c);
                    c.CC_Tiene_Caracteristica_Detalle__c = true;
                    mapContactsToUpdateById.put(detalle.CC_Empleado__c,c);
                }
                if (detalle.CC_Cuenta__c != null && !detalle.CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c) {
                    Account a = new Account(Id = detalle.CC_Cuenta__c);
                    a.CC_Tiene_Caracteristica_Detalle__c = true;
                    mapAccountsToUpdateById.put(detalle.CC_Cuenta__c,a);
                }
                if (detalle.CC_Centro_CaixaBank__c != null && !detalle.CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c) {
                    Account a = new Account(Id = detalle.CC_Centro_CaixaBank__c);
                    a.CC_Tiene_Caracteristica_Detalle__c = true;
                    mapAccountsToUpdateById.put(detalle.CC_Centro_CaixaBank__c,a);
                }
                if((detalle.CC_Cliente__c != null && idsContactos.contains(detalle.CC_Cliente__c)) || (detalle.CC_Empleado__c != null && idsContactos.contains(detalle.CC_Empleado__c))){
                    idsContactos.remove(detalle.CC_Cliente__c);
                }
                if((detalle.CC_Cuenta__c != null && idsCuentas.contains(detalle.CC_Cuenta__c)) || (detalle.CC_Centro_CaixaBank__c != null && idsCuentas.contains(detalle.CC_Centro_CaixaBank__c))){
                    idsCuentas.remove(detalle.CC_Cuenta__c);
                }
            }
            //Revisamos si quedan contactos o cuentas en los sets
            if(!idsContactos.isEmpty()) {
                List<Contact> lstContacts = [SELECT Id, CC_Tiene_Caracteristica_Detalle__c FROM Contact WHERE Id IN :idsContactos];
                for(Contact contact : lstContacts) {
                    if(contact.CC_Tiene_Caracteristica_Detalle__c) {
                        contact.CC_Tiene_Caracteristica_Detalle__c = false;
                        mapContactsToUpdateById.put(contact.Id, contact);
                    }
                }
            }
            if(!idsCuentas.isEmpty()) {
                List<Account> lstAccounts = [SELECT Id, CC_Tiene_Caracteristica_Detalle__c FROM Account WHERE Id IN :idsCuentas];
                for(Account account : lstAccounts) {
                    if(account.CC_Tiene_Caracteristica_Detalle__c) {
                        account.CC_Tiene_Caracteristica_Detalle__c = false;
                        mapAccountsToUpdateById.put(account.Id, account);
                    }
                }
            }
            // Actualizo los contactos y cuentas en caso de que haya alguna
            if(!mapContactsToUpdateById.isEmpty()) {
                update mapContactsToUpdateById.values();
            }
            if(!mapAccountsToUpdateById.isEmpty()) {
                update mapAccountsToUpdateById.values();
            }
        }

    }
    
    private void updateMarcaCasoCierreCaso(Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj, Id rtCliente){
        List<SAC_Marca_Case__c> lstMarcasCaseCierre = new List<SAC_Marca_Case__c>();
        List<Id> lstIdsCasosCerrados = new List<Id>();
        for (Case caso : mapNewObj.values()) {
            if (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado' && caso.RecordTypeId == rtCliente) {
                lstIdsCasosCerrados.add(caso.Id);
            }
        }
        if(!lstIdsCasosCerrados.isEmpty()){
            lstMarcasCaseCierre = [SELECT Id, SAC_Case__c, CC_Motivo_del_Caso__c FROM SAC_Marca_Case__c WHERE SAC_Case__c IN :lstIdsCasosCerrados];
            List<SAC_Marca_Case__c> lstMarcasCaseToUpdate = new List<SAC_Marca_Case__c>();
            for (SAC_Marca_Case__c marcaCaso : lstMarcasCaseCierre) {
                if(mapNewObj.containsKey(marcaCaso.SAC_Case__c) && marcaCaso.CC_Motivo_del_Caso__c == mapNewObj.get(marcaCaso.SAC_Case__c).CC_Motivo__c){
                    marcaCaso.CC_Caso_Cerrado__c = true;
                    lstMarcasCaseToUpdate.add(marcaCaso);
                }
            }
            if(!lstMarcasCaseToUpdate.isEmpty()){
                update lstMarcasCaseToUpdate;
            }
        }
    }

    private void crearActividadCierreCAM(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        List<Task> tareasCierre = new List<Task>();
        for (Case caso : listNewObj) {
            if (idsCAM.contains(caso.Id) && mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado') {
                Task tareaCierre = new Task();
                tareaCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
                tareaCierre.WhatId = caso.Id;
                tareaCierre.Type = 'Cerrado';
                tareaCierre.Subject = 'Cerrado';
                tareaCierre.ActivityDate = System.today();
                tareaCierre.CC_Fecha_Inicio__c = System.now();
                tareaCierre.CC_Detalles_Consulta__c = caso.CC_Detalles_Consulta__c != null ? caso.CC_Detalles_Consulta__c.left(255) : null;
                tareaCierre.CC_Detalles_Solucion__c = caso.CC_Detalles_Solucion__c != null ? caso.CC_Detalles_Solucion__c.left(255) : null;
                tareaCierre.Status = 'Completed';
                tareasCierre.add(tareaCierre);
            }
        }
        insert tareasCierre;
    }

    private void crearActividadReasignacionCAM(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {
        Boolean crearActividad = false;
        for (Case caso : listNewObj) {
            if ((idsCAM.contains(caso.Id) && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId) || Test.isRunningTest()) {
                crearActividad = true;
                break;
            }
        }
       
        if (crearActividad) {
            Map<Id, Case> casos = new Map<Id, Case>([SELECT Owner.Name FROM Case WHERE Id IN :idsCAM]);
            List<Task> tareasReasignacion = new List<Task>();
            for (Case caso : listNewObj) {
                if (idsCAM.contains(caso.Id) && mapOldObj.get(caso.Id).OwnerId !=null && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId) {
					ID oldCaseOwner = mapOldObj.get(caso.Id).OwnerId;
                	Case newCase = caso;
                    Task tareaCierre = new Task();
                    tareaCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
                    tareaCierre.WhatId = caso.Id;
                    tareaCierre.Type = 'Reasignación';
                    tareaCierre.Subject = 'Reasignación del caso a ' + casos.get(caso.Id).Owner.Name;
                    tareaCierre.ActivityDate = System.today();
                    tareaCierre.CC_Fecha_Inicio__c = System.now();
                    tareaCierre.Status = 'Completed';
                    tareasReasignacion.add(tareaCierre);
                }
            }
            insert tareasReasignacion;
        }
    }

    private void actualizarEstadisticasComunicacionInformativa(Map<Id, Case> mapOldObj, List<Case> casesCC) {
        Set<Id> idsComunicacionInformativa = new Set<Id>();
        Set<Id> idsComunicacionInformativaCampana = new Set<Id>();

        for (Case caso : casesCC) {
            Case casoAnterior = mapOldObj.get(caso.Id);
            if(caso.Status == 'Cerrado'){
                if (casoAnterior.CC_Comunicacion_Informativa__c != caso.CC_Comunicacion_Informativa__c) { //El caso se ha vinculado o desvinculado de una CI
                    if (casoAnterior.CC_Comunicacion_Informativa__c != null && caso.CC_Comunicacion_Informativa__c != null) { //El caso se ha desvinculado de una CI y se ha vinculado a otra
                        idsComunicacionInformativa.add(casoAnterior.CC_Comunicacion_Informativa__c);
                        idsComunicacionInformativa.add(caso.CC_Comunicacion_Informativa__c);
                    } else if (casoAnterior.CC_Comunicacion_Informativa__c != null && caso.CC_Comunicacion_Informativa__c == null) { //El caso se ha desvinculado de una CI y no se ha vinculado a otra
                        idsComunicacionInformativa.add(casoAnterior.CC_Comunicacion_Informativa__c);
                    } else if (casoAnterior.CC_Comunicacion_Informativa__c == null && caso.CC_Comunicacion_Informativa__c != null) { //El caso no tenía CI vinculada y se ha vinculado a una
                        idsComunicacionInformativa.add(caso.CC_Comunicacion_Informativa__c);
                    }
                }
                
                if (casoAnterior.CC_Comunicacion_Informativa_Campana__c != caso.CC_Comunicacion_Informativa_Campana__c) { //El caso se ha vinculado o desvinculado de una CI de Campaña
                    if (casoAnterior.CC_Comunicacion_Informativa_Campana__c != null && caso.CC_Comunicacion_Informativa_Campana__c != null) { //El caso se ha desvinculado de una CI de Campaña y se ha vinculado a otra
                        idsComunicacionInformativaCampana.add(casoAnterior.CC_Comunicacion_Informativa_Campana__c);
                        idsComunicacionInformativaCampana.add(caso.CC_Comunicacion_Informativa_Campana__c);
                    } else if (casoAnterior.CC_Comunicacion_Informativa_Campana__c != null && caso.CC_Comunicacion_Informativa_Campana__c == null) { // El caso se ha desvinculado de una CI de Campaña y no se ha vinculado a otra
                        idsComunicacionInformativaCampana.add(casoAnterior.CC_Comunicacion_Informativa_Campana__c);
                    } else if (casoAnterior.CC_Comunicacion_Informativa_Campana__c == null && caso.CC_Comunicacion_Informativa_Campana__c != null) { // El caso no tenía CI de Campaña vinculada y se ha vinculado a una
                        idsComunicacionInformativaCampana.add(caso.CC_Comunicacion_Informativa_Campana__c);
                    }
                }
            }
        }

        if (!idsComunicacionInformativa.isEmpty()) {
            CC_Comunicaciones_Informativas_Metodos.llamadaQueueableAsociarCasosAComunicacionInformativa(idsComunicacionInformativa);
        }
        if (!idsComunicacionInformativaCampana.isEmpty()) {
            CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativaCampana(idsComunicacionInformativaCampana);
        }
    }

    private void crearPlantillasAgrupadores(Map<Id, Case> mapOldObj, List<Case> casesCC) {
        Set<Id> idAgrupadores = new Set<Id>();
        for (Case newCaso : casesCC) {
            Case oldCaso = mapOldObj.get(newCaso.Id);
            // Si el caso está o ha estado pendiente de activo...
            if ((newCaso.CC_NotIncidencia__c == '1' || oldCaso.CC_NotIncidencia__c == '1') &&
                // y alguno de estos campos ha cambiado...
                (((newCaso.Status != 'Cerrado' || oldCaso.Status != 'Cerrado') && (newCaso.Status != 'Pendiente Revisión' || oldCaso.Status != 'Pendiente Revisión')) ||
                 (newCaso.CC_NotIncidencia__c != oldCaso.CC_NotIncidencia__c) ||
                 (newCaso.CC_Agrupador_Id__c  != oldCaso.CC_Agrupador_Id__c) ||
                 (newCaso.RecordTypeId        != oldCaso.RecordTypeId) ||
                 (newCaso.CC_CanalNotifCli__c != oldCaso.CC_CanalNotifCli__c) ||
                 (newCaso.CC_Idioma__c        != oldCaso.CC_Idioma__c)))
            {
                // actualizamos los agrupadores, el nuevo y el antiguo
                if (newCaso.CC_Agrupador_Id__c != null) {
                    idAgrupadores.add(newCaso.CC_Agrupador_Id__c);
                }
                if (oldCaso.CC_Agrupador_Id__c != null) {
                    idAgrupadores.add(oldCaso.CC_Agrupador_Id__c);
                }
            }
        }          
        if (idAgrupadores.size() > 0) {
            CC_Agrupador_Metodos.crearPlantillasNecesarias(idAgrupadores);
        }      
    }

    /*private void envioCorreoConsultasOperativasAsignarPropietario(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCAM) {

        List<Case> newListCase = new List<Case>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (Case caso : listNewObj) {
            if(!idsCAM.contains(caso.Id) && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' 
            && (mapOldObj.get(caso.Id).OwnerId.getsobjecttype() != User.SObjectType && caso.OwnerId.getsobjecttype() == User.SObjectType) && !caso.CC_Correo_Asignacion_Enviado__c){
                newListCase.add(caso);
            }
        }
        if (!newListCase.isEmpty()){
            List<CC_Buzones_Por_Defecto__mdt> buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                           WHERE CC_Canal_Procedencia__c = 'Formulario Consultas Operativas' AND CC_Activo__c = true];
            
            List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
            if (Test.isRunningTest()) { 
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName like 'Atención%' LIMIT 1];            
            } else {
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c];
            }
            if (!owa.isEmpty()) { 
            	//template 
                List<EmailTemplate> emailTemplates = [SELECT Id, Developername, subject, htmlvalue FROM EmailTemplate WHERE Developername IN ('CC_ConsultasOperativasCanalFormulario_Asignacion_CAS','CC_ConsultasOperativasCanalFormulario_Asignacion_CAT')];
                Map<String,String> templateSubjectPorIdioma = new Map<String,String>();
                Map<String,String> templateHTMLBodyPorIdioma = new Map<String,String>();
                if (!emailTemplates.isEmpty()){
                    for(EmailTemplate template : emailTemplates) {
    
                        if (template.DeveloperName.contains('_CAT')){
                            templateSubjectPorIdioma.put('ca', template.subject);
                            templateHTMLBodyPorIdioma.put('ca', template.htmlvalue);
                        }else {
                            templateSubjectPorIdioma.put('es', template.subject);
                            templateHTMLBodyPorIdioma.put('es', template.htmlvalue);
                        }
                    }
                
    
                    for (Case caso : newListCase) {
    
                        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                        correo.setOrgWideEmailAddressId(owa[0].Id);
                        correo.setToAddresses(new List<String>{caso.CC_MailTelfNotif__c});
                        correo.setTreatBodiesAsTemplate(true);
                        correo.setSubject(templateSubjectPorIdioma.get(caso.CC_Idioma__c));
                        correo.setHtmlBody(templateHTMLBodyPorIdioma.get(caso.CC_Idioma__c));
                        correo.setTreatTargetObjectAsRecipient(false);
                        correo.setWhatId(caso.Id);
                        correo.setSaveAsActivity(true);
                        allmsg.add(correo);
                        
    
    
                    }
                }
            }
                
        }
        //Enviamos todos los mensajes
        if (!allmsg.isEmpty()) {
            for (Messaging.SendEmailResult sr : Messaging.sendEmail(allmsg, false)) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
    }*/

    private void envioCorreoConsultasOperativasTrasladoAsignacionPropietario(Map<Id, Case> mapOldObj, List<Case> casesCC, List<Id> idsCAM) {
        //Envia correo de formulario consultas operativas, tras asignar el caso a un agente la primera vez o tras hacer una operativa de traslado a 3n o incidencia 
        List<Case> newListCase = new List<Case>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (Case casoNew : casesCC) {

            Case casoOld = mapOldObj.get(casoNew.Id);
            if (!idsCAM.contains(casoNew.Id) && casoNew.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas') { 
                if ((!casoOld.CC_En_Tercer_Nivel__c && casoNew.CC_En_Tercer_Nivel__c || casoOld.CC_Agrupador_Id__c == null && casoNew.CC_Agrupador_Id__c != null)
                || (casoOld.OwnerId.getsobjecttype() != User.SObjectType && casoNew.OwnerId.getsobjecttype() == User.SObjectType && !casoNew.CC_Correo_Asignacion_Enviado__c)) {
                    if (!casoOld.CC_En_Tercer_Nivel__c && casoNew.CC_En_Tercer_Nivel__c || casoOld.CC_Agrupador_Id__c == null && casoNew.CC_Agrupador_Id__c != null) {
                        newListCase.add(casoNew);
                    }
                }
            }
        }
        if (!newListCase.isEmpty()) {
			List<CC_Buzones_Por_Defecto__mdt> buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                                WHERE CC_Canal_Procedencia__c = 'Formulario Consultas Operativas' AND CC_Activo__c = true];
            List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();            
            if (Test.isRunningTest()) { 
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName like 'Atención%' LIMIT 1];            
            } else {
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c];
            }
            if (!owa.isEmpty()) { 

                
                //List<EmailTemplate> emailTemplates = [SELECT Id, Developername, subject, htmlvalue FROM EmailTemplate WHERE Developername IN ('CC_ConsultasOperativasCanalFormulario_Asignacion_CAS','CC_ConsultasOperativasCanalFormulario_Asignacion_CAT')];
            	//List<EmailTemplate> emailTemplates = [SELECT Id, Developername, subject, htmlvalue FROM EmailTemplate WHERE Developername IN ('CC_ConsultasOperativasCanalFormulario_Traslado_CAT','CC_ConsultasOperativasCanalFormulario_Traslado_CAS')];
            	
                List<EmailTemplate> emailTemplates = [SELECT Id, Developername, subject, htmlvalue FROM EmailTemplate WHERE Developername IN ('CC_ConsultasOperativasCanalFormulario_Traslado_CAT','CC_ConsultasOperativasCanalFormulario_Traslado_CAS','CC_ConsultasOperativasCanalFormulario_Asignacion_CAS','CC_ConsultasOperativasCanalFormulario_Asignacion_CAT')];
                
                
                Map<String,EmailTemplate> templatePorIdiomaTraslado = new Map<String,EmailTemplate>();
                Map<String,EmailTemplate> templatePorIdiomaAsignacion = new Map<String,EmailTemplate>();
                if (!emailTemplates.isEmpty()){
                    for(EmailTemplate template : emailTemplates) {
    
                        if (template.DeveloperName.contains('_CAT')){
                            if (template.DeveloperName.contains('Traslado')) {
                                templatePorIdiomaTraslado.put('ca', template);
                            } else{
                                templatePorIdiomaAsignacion.put('ca', template);
                            }
                        }else {
                            if (template.DeveloperName.contains('Traslado')) {
                                templatePorIdiomaTraslado.put('es', template);
                            } else{
                                templatePorIdiomaAsignacion.put('es', template);
                            }
                        }
                    }
                
    
                    for (Case caso : newListCase) {
                        EmailTemplate plantilla;
                        if (caso.CC_En_Tercer_Nivel__c || caso.CC_Agrupador_Id__c != null) {
                            plantilla = templatePorIdiomaTraslado.get(caso.CC_Idioma__c);
                        } else {
                            plantilla = templatePorIdiomaAsignacion.get(caso.CC_Idioma__c);
                        }
                        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                        correo.setOrgWideEmailAddressId(owa[0]?.Id);
                        correo.setToAddresses(new List<String>{caso.CC_MailTelfNotif__c});
                        correo.setTreatBodiesAsTemplate(true);
                        correo.setSubject(plantilla.Subject);
                        correo.setHtmlBody(plantilla.HtmlValue);
                        correo.setTreatTargetObjectAsRecipient(false);
                        correo.setWhatId(caso.Id);
                        correo.setSaveAsActivity(true);
                        allmsg.add(correo);
                        
                    }
                }
            }
            
        }
        //Enviamos todos los mensajes
        if (!allmsg.isEmpty()) {
            for (Messaging.SendEmailResult sr : Messaging.sendEmail(allmsg, false)) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
    }

	
   // AVISO 3N CSBD
 /*  private void aviso3NCSBD(Map<Id, Case> mapOldObj, List<Case> listNewObj, List<Id> idsCOPS) {
    //List<Messaging.CustomNotification> ListNotif = new List<Messaging.CustomNotification>();
    List<Group> idGroup = [SELECT Id FROM Group WHERE DeveloperName = 'Cola_3N_CSBD' LIMIT 1];
    List<CustomNotificationType> notificacionCaso = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'CC_Notificacion_Caso_CSBD'];

    if (!notificacionCaso.isEmpty() && !idGroup.isEmpty()) {
        //Obtener todos los usuarios del grupo Cola_3N_CSBD
        List<GroupMember> usuariosCola3NCSBD = [SELECT UserOrGroupId From GroupMember where GroupId = : idGroup[0].Id];

        if(!notificacionCaso.isEmpty()){
            for (Case caso : listNewObj) {
                if (!idsCOPS.contains(caso.Id) && mapOldObj.get(caso.Id).OwnerId != idGroup[0].Id && caso.OwnerId == idGroup[0].Id) {
                    for (GroupMember usuario : usuariosCola3NCSBD) {
                        CustomNotificationType type = notificacionCaso[0];
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setBody('Se ha asociado un nuevo caso al grupo de 3N de CSBD.');
                        notification.setTitle('Nuevo caso asociado. '+ caso.CaseNumber);
                        notification.setSenderId( usuario.UserOrGroupId );
                        notification.setNotificationTypeId(type.id);
                        notification.setTargetId(caso.Id); // target object id
                        notification.send(new Set<String> { usuario.UserOrGroupId });                            
                    }
                }
            }          
        }

    }

}
*/    
    

    private static List<Id> obtenerIdsCAM(List<Case> casos) {
        List<Id> idsCAM = new List<Id>();
        for (Case caso : casos) {
            if (caso.RecordTypeId != null //Necesario ya que en ocasiones el caso aún no tiene RT al hacer insert
                && Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName().startsWith('AM_')) {
                idsCAM.add(caso.Id);
            }
        }
        return idsCAM;
    }

    private static void filtrarCasosAccountActualizada(List<Case> lstCasos, Map<Id, Case> mapOldObj){
        //Elimina los casos sin account
        Map<Id,Case> casosUpdate = new Map<Id,Case>();
        for(Case caso : lstCasos){
            //Filtro por el primer update del account
            if(caso.accountId != null &&  mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).ContactId == null && caso.Origin == 'Phone'){
                casosUpdate.put(caso.Id,caso);
            }
        }
        if(!casosUpdate.isEmpty()){
            CC_CaseTriggerHelper.asignacionAccountTareaLlamada(casosUpdate);
        }
    }

}