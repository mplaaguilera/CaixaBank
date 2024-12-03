public with sharing class CC_Cierre_Automatico_Methods {
    public static Datetime CC_Cierre_Automatico_SolicitudInformacion(Id caseId) {
        Case caso = [SELECT RecordTypeId, CC_MCC_Motivo__r.Name, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name,
        CC_Idioma__c, CC_Tipo_Cliente__c, ContactId, CC_Buzon_Salida__c FROM Case WHERE Id = :caseId];
        
        //Queries del MCC donde devuelve el plazo de la temática, producto/servicio o motivo, así como el templateName si existe
        CC_MCC__c mcc =  new CC_MCC__c();
        String nombreMotivo;
        String recordTypeId;
        if (caso.CC_MCC_Motivo__r.Name != null) {
            nombreMotivo = caso.CC_MCC_Motivo__r.Name;
            recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        } else if (caso.CC_MCC_ProdServ__r.Name != null && mcc.CC_Plazo__c == null) {
            nombreMotivo = caso.CC_MCC_ProdServ__r.Name;
            recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        } else if (caso.CC_MCC_Tematica__r.Name != null && mcc.CC_Plazo__c == null) {
            nombreMotivo = caso.CC_MCC_Tematica__r.Name;
            recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        }
        if(!String.isBlank(nombreMotivo) && !String.isBlank(recordTypeId)) {
            mcc = [SELECT CC_Plazo__c FROM CC_MCC__c WHERE Name = :nombreMotivo AND RecordTypeId = :recordTypeId LIMIT 1];
        }
        
        //sacamos si el ID es de cliente o empleado
        Id recordTypeCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id recordTypeEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        Id recordTypeEmpleadoCSIBankia = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
        Id recordTypeClienteCAM = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Cliente');
        Id recordTypeEmpleadoCAM = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Empleado');
        
        //sacamos el plazo de tiempo a esperar
        String plazoLOV;
        String nombrePlazo;
        if(mcc != null || mcc.CC_Plazo__c == null) {
            if (caso.RecordTypeId == recordTypeCliente) {
                nombrePlazo = 'Plazo Genérico';
            } else if(caso.RecordTypeId == recordTypeEmpleado || caso.RecordTypeId == recordTypeEmpleadoCSIBankia) {
                nombrePlazo = 'Plazo genérico empleados';
            } else if(caso.RecordTypeId == recordTypeClienteCAM) {
                nombrePlazo = 'Plazo Genérico CAM';
            } else if(caso.RecordTypeId == recordTypeEmpleadoCAM) {
                nombrePlazo = 'Plazo Genérico Empleados CAM';
            }
            if(!String.isBlank(nombrePlazo)) {
                plazoLOV = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name = :nombrePlazo LIMIT 1].CC_Valor__c;
            }
        }        
        
        //Calculamos a partir del plazo recuperado cual será el plazo a schedular
        Decimal plazoCalc;
        if (mcc.CC_Plazo__c != null) {
            plazoCalc = mcc.CC_Plazo__c;
        } else {
            plazoCalc = Decimal.valueOf(plazoLOV);
        }
        //Obtenemos el dia de hoy
        //Datetime tiempoFinPlazo = Datetime.newInstance(2019, 12, 31,1,0,0); //fin de año el 3 fiesta y pongo el martes
        Datetime tiempoFinPlazo = (Datetime)System.now();  
        //Date tiempoFinPlazo = Date.newInstance(2020, 12, 20); //este viernes y tiene quer salir el 16 lunes
        Datetime tiempoInicio;
        
        //Si es un empleado entramos aqui
        if(caso.RecordTypeId == recordTypeEmpleado || caso.RecordTypeId == recordTypeEmpleadoCSIBankia || caso.RecordTypeId == recordTypeEmpleadoCAM) {
            String diasPlazo = String.valueOf(plazoCalc/24);
            tiempoFinPlazo = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos(diasPlazo);
        }else {
            tiempoInicio = Datetime.valueOf(System.now());
            tiempoFinPlazo = tiempoInicio.addHours(Integer.valueOf(plazoCalc));
        }   
        
        //Una vez tenemos el el tiempo en el que cumple el plazo lo guardamos en el caso para luego controlar si hay respuesta
        /*Case caso = new Case();
        caso.Id = caseId;
        caso.CC_Fecha_Cierre_SolInf__c = tiempoFinPlazo;
        update caso;*/        
        return tiempoFinPlazo;
    }
    
    
    @InvocableMethod(label='Cierre Autom. Sol. Inf.' description='Cierre Autom. Sol. Inf.')
    public static void sendMailSolicitudInf(List<Id> ListCasoId) {
        
        Id recordTypeCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id recordTypeEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        Id recordTypeEmpleadoCSIBankia = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
        
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<Case> casosAct = new List<Case>();
        List<Case> oCasosAdmin = new List<Case>();
        List<Task> tasksCrear = new List<Task>();
        
        Set<Id> setIdCasos = new Set<Id>();
        for (Id casoId : ListCasoId) {
            setIdCasos.add(casoId);
        }
        
        List<Case> listCases = [SELECT RecordTypeId, ContactId, Contact.Email, CC_Tipo_Cliente__c, CC_Idioma__c, CC_Buzon_Salida__c,
        CC_Detalles_Consulta__c, CC_Detalles_Solucion__c
        FROM Case WHERE Id IN :setIdCasos AND (CC_En_Tercer_Nivel__c != TRUE OR (CC_En_Tercer_Nivel__c = TRUE AND 
                                                                                 (Case.CC_MCC_Tematica__r.Name Like '%Wivai%' OR Case.CC_MCC_Tematica__r.Name Like '%Facilitea%')))];
        
        List<EmailTemplate> emailTemplates = [SELECT Id, Name, HtmlValue 
        FROM EmailTemplate WHERE Name = 'AutoCierreSolDoc Oficina - CAS' OR Name = 'AutoCierreSolDoc Oficina - CAT' OR  Name = 'AutoCierreSolDoc Oficina - EN' 
        OR Name = 'AutoCierreSolDoc Oficina - CSI Bankia' OR Name = 'Segunda comunicación - Castellano formal' OR Name = 'Segunda comunicación - Catalán formal' OR Name = 'Segunda comunicación - Inglés'];
        
        Map<Id, EmailTemplate> mapaCasosPlantillas = new Map<Id, EmailTemplate>();
        for (Case caso : listCases) {
            for (EmailTemplate template : emailTemplates) {
                if (caso.CC_Idioma__c == 'es' && caso.RecordTypeId == recordTypeEmpleado && template.Name == 'AutoCierreSolDoc Oficina - CAS') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.CC_Idioma__c == 'ca'  && caso.RecordTypeId == recordTypeEmpleado && template.Name == 'AutoCierreSolDoc Oficina - CAT') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.CC_Idioma__c == 'en'  && caso.RecordTypeId == recordTypeEmpleado && template.Name == 'AutoCierreSolDoc Oficina - EN') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.CC_Idioma__c == 'es' && caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Castellano formal') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.CC_Idioma__c == 'ca' && caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Catalán formal') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.CC_Idioma__c == 'en' && caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Inglés') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if(caso.RecordTypeId == recordTypeEmpleado && template.Name == 'AutoCierreSolDoc Oficina - CAS'){
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Castellano formal'){
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.RecordTypeId == recordTypeEmpleadoCSIBankia && template.Name == 'AutoCierreSolDoc Oficina - CSI Bankia'){
                    mapaCasosPlantillas.put(caso.Id, template);
                }   
            }
        }
        
        /*
        EmailTemplate templateEmpleado = [SELECT HtmlValue FROM EmailTemplate WHERE Folder.DeveloperName = 'CC_Es_Ch_Solicitud_Informacion' 
        AND Name = 'Plantilla Empleado Cierre Solicitud Información'];
        */
        
        //Recorremos el listado de casos para enviar el mail y actualizar el caso y crear las actividades
        
        List<OrgWideEmailAddress> orgWides = [select id, DisplayName, Address FROM OrgWideEmailAddress];
        for (Case c : listCases) {
            // Cerramos la actividad abierta de Sol. Inf.
            CC_Activity.finalizarActividadCaso(c.Id, 'Solicitud información', 'Cierre automático', 'Cierre automático Solicitud Información');
            // Preparamos los mails que se van a enviar.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (!mapaCasosPlantillas.isEmpty()){
                mail.setTemplateId(mapaCasosPlantillas.get(c.Id).Id);
            }
            //mail.setHtmlBody(template.HtmlValue);
            mail.setSaveAsActivity(true);
            mail.setWhatId(c.Id);
            mail.setTargetObjectId(c.ContactId);
            String[] toAddresses = new String[] {c.Contact.Email};
            mail.setToAddresses(toAddresses);
            /*if (c.CC_Tipo_Cliente__c == 'Cliente'){
                mail.setSenderDisplayName('Atención Clientes CaixaBank');
            } else{
                mail.setSenderDisplayName('Atención Empleados CaixaBank');
            }*/
            // Recuperamos la OWA para el envío del cierre de la Sol. Info.
            for (OrgWideEmailAddress owa2 : orgWides) {
                if (owa2.Address == c.CC_Buzon_Salida__c) {
                    mail.setOrgWideEmailAddressId(owa2.id);
                }
            }           
            allmsg.add(mail);
            
            // Admin mode
            Case casoAdmin = new Case();
            casoAdmin.Id = c.Id;
            casoAdmin.CC_Admin__c = true;
            
            if(c.RecordTypeId == recordTypeEmpleado || c.RecordTypeId == recordTypeEmpleadoCSIBankia) {
                if (String.isEmpty(c.CC_Detalles_Consulta__c)) {
                    casoAdmin.CC_Detalles_Consulta__c = 'Cierre automático por falta de respuesta del empleado.';
                }
                if (String.isEmpty(c.CC_Detalles_Solucion__c)) {
                    casoAdmin.CC_Detalles_Solucion__c = 'Cierre automático por falta de respuesta del empleado.';
                }
            } else if(c.RecordTypeId == recordTypeCliente){
                if (String.isEmpty(c.CC_Detalles_Consulta__c)) {
                    casoAdmin.CC_Detalles_Consulta__c = 'Cierre automático por falta de respuesta del cliente.';
                }
                if (String.isEmpty(c.CC_Detalles_Solucion__c)) {
                    casoAdmin.CC_Detalles_Solucion__c = 'Cierre automático por falta de respuesta del cliente.';
                }
            }
            oCasosAdmin.add(casoAdmin);            
            
            // Preparamos la actualización del caso
            Case caso = new Case();
            caso.Id = c.Id;
            caso.CC_Fecha_Cierre_SolInf__c = null;
            caso.CC_NoRespondido__c = true;
            caso.status = 'Cerrado';
            casosAct.add(caso);
            
            // Crear Tarea de Cierre Automatico Solicitud Informacion
            Date todaysDate = system.today();
            //Datetime myDateNow = Datetime.valueOf(System.now());
            //Datetime newDate = myDateNow.addMinutes(5);
            Task task = new Task();
            task.ActivityDate = todaysDate;
            task.Subject = 'Cierre Automático Solicitud Información';
            task.Type = 'Cierre Automático';
            task.Status = 'Completed';
            //task.IsReminderSet = true;
            //task.ReminderDateTime = newDate;
            //task.Description = template; // Ver si se puede meter el template 
            task.WhatId = c.Id;
            //task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            tasksCrear.add(task);
        }
        //DataBase Update para la lista de Casos.
        Database.SaveResult[] resultsCaseAdmin = Database.update(oCasosAdmin, false);
        //Enviamos todos los mensajes
        Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg, false);
        //DataBase Update para la lista de Casos.
        Database.SaveResult[] resultsCase = Database.update(casosAct, false);
        Database.SaveResult[] resultsTask =  CC_Activity.crearActividades(tasksCrear, false);
    }
}