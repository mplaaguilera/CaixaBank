public with sharing class AM_EmailMessage_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }
    
    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        List<EmailMessage> newList = filtrarEmailMessageNoAM(listNewObj);
        validarCorreo(newList);
        validarDestinatariosCorreo(newList);
        informarOperativaEmail(newList);
        informarOperativa(newList);
        informarInterno(newList);
    }
        
    private void validarCorreo(List<EmailMessage> listNewObj) {
        for (EmailMessage correo : listNewObj) {
          
            //Validación del valor del campo Grupo colaborador
            if (!correo.Incoming && (correo.CC_Procedencia__c == 'Traslado Colaborador' || correo.CC_Procedencia__c == 'Remitir Colaborador')) {
                if (correo.CC_Grupo_Colab__c == '' || [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c].size() == 0) {
                    correo.addError('El grupo colaborador indicado (' + correo.CC_Grupo_Colab__c + ') no existe.', false);
                }                
            }
            
        }
    }

    private static void validarDestinatariosCorreo(List<EmailMessage> listNewObj){
        //Lista de emails salientes
        List<EmailMessage> correosSalientes = new List<EmailMessage>();
        Set<Id> idCorreosSalientes = new Set<Id>();
        for(EmailMessage correo: listNewObj) {
            if(!correo.Incoming) {
                correosSalientes.add(correo);
                idCorreosSalientes.add(correo.ParentId);
            }
        }
        Map<Id, Case> mapaCorreoIdRT = new Map<Id, Case>([SELECT Id, RecordTypeId, CC_Canal_Procedencia__c FROM Case WHERE Id IN :idCorreosSalientes]);

        if(!correosSalientes.isEmpty()){
            Map<EmailMessage, Set<String>> mapaDireccionesCorreosEmpleado = new Map<EmailMessage, Set<String>>();
            Map<EmailMessage, Set<String>> mapaDireccionesCorreosCliente = new Map<EmailMessage, Set<String>>();
            Id rtCasoEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
            Id rtCasoCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

            for(EmailMessage correo : correosSalientes){
                if(mapaCorreoIdRT.get(correo.ParentId).RecordTypeId == rtCasoEmpleado && 
                (mapaCorreoIdRT.get(correo.ParentId).CC_Canal_Procedencia__c == 'Buzón Carteras' || mapaCorreoIdRT.get(correo.ParentId).CC_Canal_Procedencia__c == 'Buzón Fondos')){
                    Set<String> direccionesCasoEmpleado = new Set<String>();
                    if(correo.ToAddress != null) direccionesCasoEmpleado.addAll(correo.ToAddress.replaceAll( '\\s+', '').replaceAll( ';', ',').toLowercase().split(',')); 
                    if(correo.CcAddress != null) direccionesCasoEmpleado.addAll(correo.CcAddress.replaceAll( '\\s+', '').replaceAll( ';', ',').toLowercase().split(',')); 
                    if(correo.BccAddress != null) direccionesCasoEmpleado.addAll(correo.BccAddress.replaceAll( '\\s+', '').replaceAll( ';', ',').toLowercase().split(','));
                    mapaDireccionesCorreosEmpleado.put(correo, direccionesCasoEmpleado);

                } else if (mapaCorreoIdRT.get(correo.ParentId).RecordTypeId == rtCasoCliente && 
                (mapaCorreoIdRT.get(correo.ParentId).CC_Canal_Procedencia__c == 'Buzón Carteras' || mapaCorreoIdRT.get(correo.ParentId).CC_Canal_Procedencia__c == 'Buzón Fondos')){
                    Set<String> direccionesCasoCliente = new Set<String>();
                    if(correo.ToAddress != null) direccionesCasoCliente.addAll(correo.ToAddress.replaceAll( '\\s+', '').replaceAll( ';', ',').toLowercase().split(',')); 
                    if(correo.CcAddress != null) direccionesCasoCliente.addAll(correo.CcAddress.replaceAll( '\\s+', '').replaceAll( ';', ',').toLowercase().split(',')); 
                    if(correo.BccAddress != null) direccionesCasoCliente.addAll(correo.BccAddress.replaceAll( '\\s+', '').replaceAll( ';', ',').toLowercase().split(','));
                    mapaDireccionesCorreosCliente.put(correo, direccionesCasoCliente);
                 
                }
            }

            Id rtContactEmpleado  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Id rtContactColaborador  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            Id rtContactCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Id rtContactClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

            if(!mapaDireccionesCorreosEmpleado.keySet().isEmpty()){
                Set<String> valoresMapaDireccCorreosEmp = new Set<String>();
                for(Set<String> listaDirecciones : mapaDireccionesCorreosEmpleado.values()){
                    valoresMapaDireccCorreosEmp.addAll(listaDirecciones);
                }
                List<Contact> listaContactosEmpleado = [SELECT Id, Email FROM Contact WHERE 
                                                    (RecordTypeId = :rtContactEmpleado OR RecordTypeId = :rtContactColaborador) 
                                                    AND Email IN : valoresMapaDireccCorreosEmp]; 
                List<String> listaEmailsContactosEmpleado = new List<String>();              
                if(!listaContactosEmpleado.isEmpty()){
                    for(Contact contacto : listaContactosEmpleado){
                        listaEmailsContactosEmpleado.add(contacto.Email);
                    }
                }
                
                String mensajeError = '';
                for(EmailMessage correoEmpleado : mapaDireccionesCorreosEmpleado.keySet()){
                    if(mapaDireccionesCorreosEmpleado.containsKey(correoEmpleado)){
                        Set<String> direcciones = mapaDireccionesCorreosEmpleado.get(correoEmpleado);
                        String direccionesNoValidas = '';
                        Integer count = 0;
                        for(String direccion : direcciones){
                            if(!listaEmailsContactosEmpleado.contains(direccion) && count < 1){
                                direccionesNoValidas += direccion;
                                count+=1;
                            }
                            else if(!listaEmailsContactosEmpleado.contains(direccion) && count >= 1){
                                direccionesNoValidas += ', ' + direccion;
                                count+=1;
                            }   
                        }
                        if(!String.isEmpty(direccionesNoValidas)){
                            correoEmpleado.addError('Un caso de tipo empleado sólo admite destinatarios dados de alta como contactos de tipo: Empleado y Colaborador. Las direcciones no válidas son: ' + direccionesNoValidas);
                        }
                    }
                }
                
            }
            if(!mapaDireccionesCorreosCliente.keySet().isEmpty()){
                Set<String> valoresMapaDireccCorreosCli = new Set<String>();
                for(Set<String> listaDirecciones : mapaDireccionesCorreosCliente.values()){
                    valoresMapaDireccCorreosCli.addAll(listaDirecciones);
                }
                List<Contact> listaContactosCliente = [SELECT Id, Email FROM Contact WHERE 
                                                    (RecordTypeId = :rtContactEmpleado OR RecordTypeId = :rtContactColaborador OR RecordTypeId = :rtContactCliente) 
                                                    AND Email IN :valoresMapaDireccCorreosCli];
                List<Account> listaAccountClientePA = [SELECT Id,CC_Email__c FROM Account WHERE RecordTypeId = :rtContactClientePA AND CC_Email__C IN :valoresMapaDireccCorreosCli];
                                
                List<String> listaEmailsContactosCliente = new List<String>();
                if(!listaContactosCliente.isEmpty()){  
                    for(Contact contacto : listaContactosCliente){
                        listaEmailsContactosCliente.add(contacto.Email);
                    }
                }
                if(!listaAccountClientePA.isEmpty()){  
                    for(Account accountPA : listaAccountClientePA){
                        listaEmailsContactosCliente.add(accountPA.CC_Email__c);
                    }
                }

                String mensajeErrorCliente = '';
                for(EmailMessage correoCliente : mapaDireccionesCorreosCliente.keySet()){
                    Set<String> direcciones = mapaDireccionesCorreosCliente.get(correoCliente);
                    String direccionesNoValidas = '';
                    Integer count = 0;
                    for(String direccion : direcciones){
                        if(!listaEmailsContactosCliente.contains(direccion) && count < 1){
                            direccionesNoValidas += direccion;
                            count+=1;
                        }
                        else if(!listaEmailsContactosCliente.contains(direccion) && count >= 1){
                            direccionesNoValidas += ', ' + direccion;
                            count+=1;
                        }   
                    }
                    if(!String.isEmpty(direccionesNoValidas)){
                        correoCliente.addError('Un caso de tipo cliente sólo admite destinatarios dados de alta como contactos de tipo: Cliente, Empleado y Colaborador. Las direcciones no válidas son: ' + direccionesNoValidas);
                    }
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

    private static void informarOperativaEmail(List<EmailMessage> listNewObj) {
        List<Id> idCasos = new List<Id>();

        for (EmailMessage correo : listNewObj) {
            if (!correo.Incoming) {
                idCasos.add(correo.ParentId);
            }
        }
        Map<Id, Case> casos = new Map<Id, Case>([SELECT Id, CC_Ultima_Operativa_Correo__c, CC_Grupo_Colaborador__c FROM Case WHERE Id IN :idCasos AND CC_Ultima_Operativa_Correo__c != null]);
        
        for(EmailMessage email : listNewObj){
            if(casos.containsKey(email.ParentId) && email.CC_Procedencia__c == null){
                if(casos.get(email.ParentId).CC_Ultima_Operativa_Correo__c == 'solicitar'){
                    email.CC_Procedencia__c = 'Solicitud Información';
                }
                if(casos.get(email.ParentId).CC_Ultima_Operativa_Correo__c == 'responderCliente'){
                    email.CC_Procedencia__c = 'Responder Cliente';
                }
                if(casos.get(email.ParentId).CC_Ultima_Operativa_Correo__c == 'trasladar'){
                    email.CC_Procedencia__c = 'Traslado Colaborador';
                    email.CC_Grupo_Colab__c = casos.get(email.ParentId).CC_Grupo_Colaborador__c;
                }
            }
        }
    }

    private static void informarOperativa(List<EmailMessage> listNewObj) {
        List<String> referencias = new List<String>();
        List<Id> idsCasos = new List<Id>();
        List<EmailMessage> nuevoListadoCorreos = new List<EmailMessage>();
        for (EmailMessage correo : listNewObj) {
            String referencia = AM_Metodos_EmailServices.referenciaCorreo(correo);
            if (referencia != null && correo.Incoming) {
                idsCasos.add(correo.ParentId);
                referencias.add(referencia);
                nuevoListadoCorreos.add(correo);
            }
        }
        if (!referencias.isEmpty()){
            List<Task> tareasOrigen = [SELECT Type, WhatId FROM Task WHERE WhatId IN :idsCasos AND CC_Referencia_Correo_Saliente__c IN :referencias WITH SECURITY_ENFORCED];
            Map<Id, String> mapaTipoTareaDelCorreo = new Map<Id, String>();
            for (Task tarea : tareasOrigen) {
                mapaTipoTareaDelCorreo.put(tarea.WhatId, tarea.Type);
            }
            
            for (EmailMessage correo : nuevoListadoCorreos) {
                if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Traslado Colaborador') {
                    //Respuesta entrante de grupo colaborador
                    correo.CC_Procedencia__c = 'Traslado Colaborador';
                    correo.CC_Interno__c = true;
                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Solicitud Información') {
                    //Respuesta entrante de solicitud de información de cliente
                    correo.CC_Procedencia__c = 'Solicitud Información';
                    correo.CC_Interno__c = false;
                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Remitir Colaborador') {
                    //Respuesta entrante de remisión del caso a grupo colaborador
                    correo.CC_Procedencia__c = 'Remitir Colaborador';
                    correo.CC_Interno__c = true;
                }
            }
        }
    }

    
    private List<EmailMessage> filtrarEmailMessageNoAM(List<EmailMessage> listNewObj){
        List<EmailMessage> newList= new List<EmailMessage>();
        for (EmailMessage emailMessage : listNewObj) {
            if (emailMessage.ParentId != null && OT_Proyectos.registroProyecto(emailMessage.ParentId) == 'AM') {
                newList.add(emailMessage);
            }          
        }
        return newList;
    }
}