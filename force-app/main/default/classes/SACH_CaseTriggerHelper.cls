public with sharing class SACH_CaseTriggerHelper {

    /* Vamos a filtrar por operativa que hemos seleccionado desde el MCC para clasificar el caso*/
    public static void validarOperativaPromor(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        //List<Case> casosSACH = new List<Case>();
        String nombreSolucion = '';
        String nombreSolucionAnterior = '';
        Case caso;

        Id sachCaseTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        Id rtsolucionCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
        List<CC_MCC__c> mccSolucion = [SELECT Id,Name from CC_MCC__c WHERE RecordTypeId = :rtsolucionCaso AND CC_Tipo_Cliente__c = 'Cliente (SACH)' AND CC_Activo__c = true];

        
        Datetime fecha ;
        fecha = date.today().addDays(25);  
        
        /*
        //Para pruebas
        Datetime fecha = Datetime.now();
        fecha = fecha.addMinutes(2);*/

        for (Case caso1 : lstCasos) {
                // Para cada caso vamos a buscar que Solucion tiene el caso
                // Iterar sobre la lista original y filtrar por el ID de la solucion
                for(CC_MCC__c mcc1 : mccSolucion) {
                    if(mcc1.Id == caso1.CC_MCC_Solucion__c) {
                        nombreSolucion = mcc1.Name;
                    }
                }

                for(CC_MCC__c mcc : mccSolucion) {
                    if(mcc.Id == mapOldObj.get(caso1.Id).CC_MCC_Solucion__c) {
                        nombreSolucionAnterior = mcc.Name;
                    }
                }
                caso = caso1;
        }

            String cuerpoPlantilla = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = 'SACH_Remitir' LIMIT 1].HtmlValue;
            // Solo entramos cuando se este realizando un cambio en la solución del caso.
            // Si es la misma solucion o no se ha modificado no se entra
            if ((nombreSolucion != nombreSolucionAnterior) || (nombreSolucionAnterior == null) || (nombreSolucionAnterior == '')) {
                
                SACH_Parametros__c parametro705 = SACH_Parametros__c.getInstance('Solucion_705');
                String solucion705 = parametro705.SACH_Parametro_1__c;

                if (nombreSolucion == solucion705) {

                    // Caso 1 : 705 : Paralización Solicitud de subasta
                    // ReAbrir actividad traslado colaborador antigua
                    reabrirTareaTrasladoColab(caso);
                    caso.Status = 'Pendiente Colaborador';
                  
                    //Añadimos una tarea al framework para que se comprueben si han pasado 25 dias para reabrirlo
                    //Cambio de PB a FW - Ejecución de citas pendientes: Inserto registros en CBK_SCH_PendingProcess__c para programar acciones
                    //Programar cita en CSBD_Fecha_Cita__c
                    CBK_SCH_PendingProcess__c pendingProcessCita = new CBK_SCH_PendingProcess__c();
                    pendingProcessCita.RecordId__c = caso.Id;
                    pendingProcessCita.Schedule_Time__c = fecha;
                    pendingProcessCita.ClassName__c = 'CBK_SCH_CSBD_ScheduleReaperturaCaso';
                    insert pendingProcessCita;

                }

                SACH_Parametros__c parametro715 = SACH_Parametros__c.getInstance('Solucion_715');
                String solucion715 = parametro715.SACH_Parametro_1__c;
                if (nombreSolucion == solucion715) {
                    
                    // Verifica si el campo ContactId está vacío o no
                    if (String.isBlank(caso.ContactId)) {
                        caso.addError('El caso que esta intentando actualizar no tiene un contacto asociado. Rellene el contacto asociado al caso.', false);
                    } else {
                       
                        // Caso 1 : 715 : Suspension actuaciones por instruccion
                        // 1.- Pasar el estado del caso a 'Pendiente colaborador'

                        //Preparamos el envio del correo, lstCasos
                        Id rtTareaSACH = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Task').getRecordTypeId();
                        String apiNamePlantillas = 'SACH_Remitir';
                        List <Case> casosTraslado = new List <Case>();
                        List <Id> contactCasoId = new List <Id>();
                        
                        if(!lstCasos.isEmpty()){

                            //Recogemos las plantillas de correo ordenadas alfabeticamente (0: Catalan, 1: Castellano)
                            List <EmailTemplate> plantillas = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE : apiNamePlantillas ORDER BY DeveloperName];

                            //Se obtiene de CC_Buzones_Por_Defecto__mdt la lista de buzones de salida válidos
                            List<String> buzonesSalidaValidos = new List<String>();
                            List <OrgWideEmailAddress> remitentesId = new List <OrgWideEmailAddress>();
                            for (SACH_Correo__mdt buzonPorDefecto : [SELECT SACH_Email__c FROM SACH_Correo__mdt LIMIT 1]) {
                                buzonesSalidaValidos.add(buzonPorDefecto.SACH_Email__c);
                            }
                            if(!buzonesSalidaValidos.isEmpty()){
                                remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: buzonesSalidaValidos[0]) ORDER BY Address];
                            }

                            //Recogemos el Email del Owner del caso para enviarle traslado a colaborador
                            String ownerEmail = null;
                            // Obtener el ID del propietario (Owner) del caso
                            Id ownerId = [SELECT OwnerId FROM Case WHERE Id = :caso.Id].OwnerId;
                            
                            // Verificar si se encontró el propietario del caso
                            if (ownerId != null) {
                                // Obtener el email del propietario del caso
                                User owner = [SELECT Email FROM User WHERE Id = :ownerId LIMIT 1];
                                ownerEmail = owner.Email;
                            }

                            //Si no hay ninguna task de acuse de recibo asignada al caso y al contacto, se envía el correo y se crea la task de Acuse de recibo
                            //caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente();
                            //SACH_Case_Operativa.prepararCaso(caso.Id, plantillas[0].Id, true, 'Traslado Colaborador');
                            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);
                           
                            //for(Case casoNuevo : lstCasos){
                                String textoSemilla = '<br/><br/><span style="font-family: \'Arial\'; font-size: 12px; color: gray;">';
                                textoSemilla += 'Por favor, mantenga la siguiente referencia al responder a este correo electrónico: #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
                                textoSemilla += '</span>';
                                //String cuerpoPlantillaCaso = cuerpoPlantilla + textoSemilla;
                                String cuerpoPlantillaCaso = cuerpoPlantilla + textoSemilla;
                                String asunto =  caso.SACH_NIF_Cuenta__c + ' - ' +  caso.SACH_Nombre_Cuenta__c;



                                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                                    mail.setHtmlBody(cuerpoPlantillaCaso);
                                    mail.setSubject(asunto);
                                    mail.setWhatId(caso.Id);
                                    mail.setOrgWideEmailAddressId(remitentesId[0].Id);
                                   //mail.setTemplateId(plantillas[0].Id);
                                    mail.setTargetObjectId(caso.ContactId);
                                    mail.setTreatTargetObjectAsRecipient(false);
                                    String[] toAddresses = new String[] {ownerEmail};
                                    mail.setToAddresses(toAddresses);
                                    mail.setSaveAsActivity(true);
                                    
                                    allmsg.add(mail);

                                    try {
                                        // Enviar el correo electrónico y manejar errores si los hay
                                        Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);

                                        //Actualizamos el caso a Pendiente Colaborador
                                        caso.Status = 'Pendiente Colaborador';
                                        // Crear Tarea
                                        //Creamos la tarea de Traslado a colaborador
                                        Task task = new Task();
                                        task.ActivityDate = System.today();
                                        task.Subject = 'Traslado Colaborador';  //// PENDIENTE DE HABLAR CON GUSTAVO
                                        task.Type = 'Traslado Colaborador';
                                        task.Status = 'Open';
                                        task.WhatId = caso.Id;
                                        task.WhoId = caso.ContactId;
                                        task.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
                                        task.RecordtypeId = rtTareaSACH;
                                        //listaTareas.add(task);
                                        insert task;

                                    } catch (Exception e) {
                                        CBK_Log.error(e, 'Error en el envio de email');
                                    }
                            }
                    }
                }
            }
        //}
    }

    public static void reabrirTareaTrasladoColab(Case caso) {
        List<Task> listaTareasCerradas = new List<Task>();

        //Verificamos si ya existe alguna tarea de traslado Colaborador abierta para el Caso
        List<Task> tareasTrasladoAbiertas = [SELECT Id FROM Task
                                                WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' AND IsClosed = FALSE WITH SECURITY_ENFORCED LIMIT 1];

        //Si existe no es necesario hacer nada. Si no existe se busca la cerrada más reciente para reabrirla
        if (tareasTrasladoAbiertas.isEmpty()) {
            listaTareasCerradas = [SELECT Id FROM Task
                                                WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' AND IsClosed = TRUE WITH SECURITY_ENFORCED
                                                ORDER BY CreatedDate DESC LIMIT 1];
            if (!listaTareasCerradas.isEmpty()) {
                
                listaTareasCerradas[0].Status = 'Open';
                update listaTareasCerradas;
            }else {
                caso.addError('El caso que esta intentando actualizar no tiene una tarea Traslado Colaborador Asociada. Debe existir una anteriormente.', false);
       
            }
        }
    }


    public static List<Case> filtrarCasosSACH(List<Case> lstCasos) {

        List<Case> casosSACH = new List<Case>();
        Id sachCaseTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == sachCaseTypeId) {
                casosSACH.add(caso);
            }
        }
        
        return casosSACH;
    }

    public static void crearTareaDeCerrar(List<Case> lstCasos, Map<Id, Case> mapCaseOld) {

        List<Case> lstCasosSACH = new List<Case>();
        List<Task> lstTareasSACH = new List<Task>();

        for (Case caso : lstCasos) {
            if (caso.Status != mapCaseOld.get(caso.Id).Status && caso.Status == 'Cerrado') {
                lstCasosSACH.add(caso);
            }
        }

        for(Case casoSACH : lstCasosSACH){
            Map<String, Object> camposTarea = new Map<String, Object>();
            camposTarea.put('Type', 'Cerrado');
            camposTarea.put('Subject', 'Cerrado');
            camposTarea.put('ActivityDate', System.today());
            camposTarea.put('Status', 'Completed');
            camposTarea.put('WhatId', casoSACH.Id);
            camposTarea.put('CC_Fecha_Inicio__c', System.now());
            camposTarea.put('CC_Detalles_Consulta__c', casoSACH.CC_Detalles_Consulta__c != null ? casoSACH.CC_Detalles_Consulta__c.left(255) : null);
            camposTarea.put('CC_Detalles_Solucion__c', casoSACH.CC_Detalles_Solucion__c != null ? casoSACH.CC_Detalles_Solucion__c.left(255) : null);
            Task tarea = SACH_Activity.crearTarea('SACH_Task', camposTarea);
            lstTareasSACH.add(tarea);
        }

        if(!lstTareasSACH.isEmpty()){
            SACH_Activity.crearlstTareas(lstTareasSACH);
        }
        
    }

    public static void crearTareaDeReasignacion(List<Case> lstCasos, Map<Id, Case> mapCaseOld) {

        List<Case> lstCasosSACH = new List<Case>();
        List<Task> lstTareasSACH = new List<Task>();

        for (Case caso : lstCasos) {
            if (caso.OwnerId != mapCaseOld.get(caso.Id).OwnerId) {
                lstCasosSACH.add(caso);
            }
        }

        for(Case casoSACH : lstCasosSACH){
            Map<String, Object> camposTarea = new Map<String, Object>();
            camposTarea.put('WhatId', casoSACH.Id);
            camposTarea.put('Type', 'Reasignación');
            camposTarea.put('Subject', 'Reasignación del caso');
            camposTarea.put('ActivityDate', System.today());
            camposTarea.put('Status', 'Completed');
            camposTarea.put('CC_Fecha_Inicio__c', System.now());

            Task tarea = SACH_Activity.crearTarea('SACH_Task', camposTarea);
            lstTareasSACH.add(tarea);
        }

        if(!lstTareasSACH.isEmpty()){
            SACH_Activity.crearlstTareas(lstTareasSACH);
        }
        
    }
    
    // Metodo creado por traspaso de process builder CC_Creacion_Caso a trigger
    public static void comprobacionContactoAI(List<Case> lstCasos) {
        List<Id> casosSinContacto = new List<Id>();
        for (Case caso : lstCasos) {
            if(caso.ContactId != null){
                casosSinContacto.add(caso.Id);
            }
        }

        if (!casosSinContacto.isEmpty()) {
            CC_Caracteristica.RelacionarCaso(casosSinContacto);
        }
    }

    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void personAccountBI(List<Case> lstCasos) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :setIdCuentas AND RecordType.DeveloperName = 'CC_ClientePA']);

            for (Case caso : casosAlf) {
                if (mapAccount.containsKey(caso.AccountId)) {
                    caso.ContactId = mapAccount.get(caso.AccountId).PersonContactId;
                }
            }
        }
    }
    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void personAccountBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :setIdCuentas AND RecordType.DeveloperName = 'CC_ClientePA']);

            for (Case caso : casosAlf) {
                if (mapAccount.containsKey(caso.AccountId)) {
                    caso.ContactId = mapAccount.get(caso.AccountId).PersonContactId;
                }
            }
        }
    } 
    
    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void identificarClienteAlfBI(List<Case> lstCasos) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.CC_IdentCliente__c != '0') {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, true);
        }
    }

    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void identificarClienteAlfBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            //caso.CC_IdentCliente__c != '0' no existe en el PB, añadido para contuniar la lógica del BI
            if (caso.AccountId != null && mapOldObj.get(caso.Id).CC_IdentCliente__c != caso.CC_IdentCliente__c && caso.CC_IdentCliente__c != '0') {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, true);
        }
    }

    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void identificarCambioClienteAlfBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, false);
        }
    }
    
    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    private static void alfAux(List<Case> lstCasos, Set<Id> setIdCuentas, Boolean cambioDocumen) {
        Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, CC_Email__c, CC_NumPerso__c, CC_Numero_Documento__c, CC_OficinaGestoraId__c, CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c,
        CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId FROM Account WHERE Id IN :setIdCuentas]);
        
        for (Case caso : lstCasos) {
            if (mapAccount.containsKey(caso.AccountId)) {
                if(cambioDocumen || (!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web')){
                    caso.CC_MailTelfNotif__c = mapAccount.get(caso.AccountId).CC_NumPerso__c;
                    caso.CC_Numero_Documento__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    if(!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web'){
                        caso.CC_NumPerso__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    }
                }
 
            }
        }
    }

    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void blanqueoAccountBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId == null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                caso.CC_MailTelfNotif__c = null;
                caso.CC_Numero_Documento__c = null;
                caso.CC_NumPerso__c = null;
            }
        }
    }

    public static void noIdentificaClienteBU(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        for(Case caso: listNewObj) {
            if(caso.CC_No_Identificado__c && ((caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.AccountId != null) || (caso.ContactId != mapOldObj.get(caso.Id).ContactId && caso.ContactId != null))) {
                caso.CC_No_Identificado__c = false;
            }
        }
    }

}