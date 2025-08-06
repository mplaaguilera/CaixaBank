/**
 * @description       : 
 * @author            : Moisés Cano
 * @group             : 
 * @last modified on  : 03-21-2023
 * @last modified by  : Moisés Cano
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   03-18-2022   Adrian Mariscal   Initial Version
 * 1.1   04-12-2022   Victor Manuel     Cierre automatico no afecta a casos en tercer nivel al solicitar informacion
**/
public with sharing class HDT_Cierre_Automatico_Methods {
    
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

        
        System.debug(recordTypeId);


        if(!String.isBlank(nombreMotivo) && !String.isBlank(recordTypeId)){
        mcc = [SELECT CC_Plazo__c FROM CC_MCC__c WHERE Name = :nombreMotivo AND RecordTypeId = :recordTypeId LIMIT 1];
        }

        //sacamos si el ID es de cliente o empleado
        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
 
        //sacamos el plazo de tiempo a esperar
        String plazoLOV;
    
        if(mcc != null || mcc.CC_Plazo__c == null){        
            plazoLOV = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE Name = 'Plazo genérico empleados' LIMIT 1].CC_Valor__c;
            
        }
        
        //Calculamos a partir del plazo recuperado cual será el plazo a schedular
        Decimal plazoCalc;
        if (mcc.CC_Plazo__c != null) {
            plazoCalc = mcc.CC_Plazo__c;
        } else {
            plazoCalc = Decimal.valueOf(plazoLOV);
        }
        System.debug('plazoCalc1::: '+plazoCalc);
        //Obtenemos el dia de hoy
        //Datetime tiempoFinPlazo = Datetime.newInstance(2019, 12, 31,1,0,0); //fin de año el 3 fiesta y pongo el martes
        Datetime tiempoFinPlazo = (Datetime)System.now();  
        //Date tiempoFinPlazo = Date.newInstance(2020, 12, 20); //este viernes y tiene quer salir el 16 lunes
        Datetime tiempoInicio;

        //Si es un empleado entramos aqui
        if(caso.RecordTypeId == recordTypeEmpleado){

            system.debug('plazoCalc: '+plazoCalc);
            String diasPlazo = String.valueOf(plazoCalc/24);
            system.debug('diasPlazo: '+diasPlazo);
            tiempoFinPlazo = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos(diasPlazo);
            system.debug('tiempoFinPlazo: '+tiempoFinPlazo);
            
        }else{
            tiempoInicio = Datetime.valueOf(System.now());

            System.debug('plazoCalc2::: '+plazoCalc);
            tiempoFinPlazo = tiempoInicio.addHours(Integer.valueOf(plazoCalc));

        }
        
        return tiempoFinPlazo;
    }


    @InvocableMethod(label='Cierre Autom. Sol. Inf.' description='Cierre Autom. Sol. Inf.')
    public static void sendMailSolicitudInf(List<Id> listCasoId) {
        
        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        /*Id recordTypeCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordTypeEmpleadoCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();*/
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<Case> casosAct = new List<Case>();
        List<Case> oCasosAdmin = new List<Case>();
        List<Task> tasksCrear = new List<Task>();

        Set<Id> setIdCasos = new Set<Id>();
        for (Id casoId : listCasoId) {
            setIdCasos.add(casoId);
        }
                
        List<Case> listCases = [SELECT RecordTypeId, ContactId, Contact.Email, CC_Tipo_Cliente__c, CC_Idioma__c, CC_Buzon_Salida__c,
                                CC_Detalles_Consulta__c, CC_Detalles_Solucion__c
                                FROM Case WHERE Id IN :setIdCasos AND CC_En_Tercer_Nivel__c != TRUE];

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
                /*else if (caso.CC_Idioma__c == 'es' && caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Castellano formal') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.CC_Idioma__c == 'ca' && caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Catalán formal') {
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.CC_Idioma__c == 'en' && caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Inglés') {
                    mapaCasosPlantillas.put(caso.Id, template);*/
                } else if(caso.RecordTypeId == recordTypeEmpleado && template.Name == 'AutoCierreSolDoc Oficina - CAS'){
                    mapaCasosPlantillas.put(caso.Id, template);
                }/* else if (caso.RecordTypeId == recordTypeCliente && template.Name == 'Segunda comunicación - Castellano formal'){
                    mapaCasosPlantillas.put(caso.Id, template);
                } else if (caso.RecordTypeId == recordTypeEmpleadoCSIBankia && template.Name == 'AutoCierreSolDoc Oficina - CSI Bankia'){
                    mapaCasosPlantillas.put(caso.Id, template);
                }   */
            }
            
        }

        //Recorremos el listado de casos para enviar el mail y actualizar el caso y crear las actividades

        List<OrgWideEmailAddress> orgWides = [select id, DisplayName, Address FROM OrgWideEmailAddress];
        for (Case c : listCases) {
            // Cerramos la actividad abierta de Sol. Inf.
            HDT_Activity.finalizarActividadCaso(c.Id, 'Solicitud información', 'Cierre automático', 'Cierre automático Solicitud Información');
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
           
            //Messaging.sendEmail(new Messaging.SingleEmailmessage[] {mail});
            allmsg.add(mail);
            //Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg, false);
            
            // Admin mode
            Case casoAdmin = new Case();
            casoAdmin.Id = c.Id;
            casoAdmin.CC_Admin__c = true;
            
            if(c.RecordTypeId == recordTypeEmpleado){
                if (String.isEmpty(c.CC_Detalles_Consulta__c)){
                	casoAdmin.CC_Detalles_Consulta__c = 'Cierre automático por falta de respuesta del empleado.';
                }
                if (String.isEmpty(c.CC_Detalles_Solucion__c)){
                	casoAdmin.CC_Detalles_Solucion__c = 'Cierre automático por falta de respuesta del empleado.';
                }
            }/*else if(c.RecordTypeId == recordTypeCliente){
                if (String.isEmpty(c.CC_Detalles_Consulta__c)){
                	casoAdmin.CC_Detalles_Consulta__c = 'Cierre automático por falta de respuesta del cliente.';
                }
                if (String.isEmpty(c.CC_Detalles_Solucion__c)){
                	casoAdmin.CC_Detalles_Solucion__c = 'Cierre automático por falta de respuesta del cliente.';
                }
            }*/
            oCasosAdmin.add(casoAdmin);
            
            
            // Preparamos la actualización del caso
            Case caso = new Case();
            caso.Id = c.Id;
            caso.CC_Fecha_Cierre_SolInf__c = null;
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
            //task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
            tasksCrear.add(task);
        }
        //DataBase Update para la lista de Casos.
        Database.SaveResult[] resultsCaseAdmin = Database.update(oCasosAdmin, false);
        //Enviamos todos los mensajes
        Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg, false);
        //DataBase Update para la lista de Casos.
        Database.SaveResult[] resultsCase = Database.update(casosAct, false);
        //DataBase Insert para la lista de Tareas.
        //Database.SaveResult[] resultsTask = Database.insert(TasksCrear, false);
        
        Database.SaveResult[] resultsTask =  HDT_Activity.crearActividades(tasksCrear, false);

    }

}