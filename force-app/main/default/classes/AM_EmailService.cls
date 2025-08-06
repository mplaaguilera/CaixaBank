public without sharing class AM_EmailService implements Messaging.InboundEmailHandler {

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try{
            CBK_log.auditemail(email);

            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            // Email body
            String body = '';
            if (String.isNotBlank(email.plainTextBody)) {
                body = email.plainTextBody.left(131072);
            } else if (String.isNotBlank(email.htmlBody)) {
                body = email.htmlBody.stripHtmlTags().left(131072);
            } 
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = AM_Metodos_EmailServices.referenciaCorreo(email);

            List<Task> tareaOrigen = new List<Task>();
            if (String.isNotBlank(referencia)) {
                //El correo es una respuesta a un correo saliente previo, se busca dicho correo
                tareaOrigen = [SELECT WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia
                                AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task') LIMIT 1];
            }
            
            //Si se ha encontrado el correo previo, el correo entrante actual se vincula a su caso
            if (!tareaOrigen.isEmpty()) {
                if (tareaOrigen[0].Type == 'Traslado Colaborador') {
                    //Respuesta entrante de grupo colaborador
                    AM_Metodos_EmailServices.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, body, envelope.toAddress);
                } else if (tareaOrigen[0].Type == 'Solicitud Información') {
                    //Respuesta entrante de solicitud de información de cliente
                    AM_Metodos_EmailServices.respuestaSolicitudInfo(email, tareaOrigen[0].WhatId, body, envelope.toAddress);
                } /*else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                    //Respuesta entrante de remisión del caso a grupo colaborador
                    AM_Metodos_EmailServices.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, body, envelope.toAddress);
                }*/ else if (tareaOrigen[0].Type == 'Responder a cliente') {
                    //Respuesta entrante de respuesta de cliente
                    AM_Metodos_EmailServices.respuestaCliente(email, tareaOrigen[0].WhatId, body, envelope.toAddress);
                }

            } else {
                //El correo ha llegado sin referencia o ésta no apunta a ninguna tarea --> Se crea nuevo caso

                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Boolean recordTypeEmpleado = false;
                Id accountId = null;
                Id contactId = null;

                Map<Account, List<Contact>> mapaCuentasContactos = AM_Identificacion_Auto.identificarCliente('Email', email.fromAddress); // Duplicamos "OS_Identificacion_Auto" para CAM para incluir colaboradores
                //El formato del resultado de la identificación automática es <Account, List<Contact>>
                if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values()[0].size() == 1) {
                    Contact contactoIdentificado = mapaCuentasContactos.values()[0][0];
                    accountId = contactoIdentificado.AccountId;
                    contactId = contactoIdentificado.Id;
                    recordTypeEmpleado = contactoIdentificado.RecordType.DeveloperName == 'CC_Empleado' || contactoIdentificado.RecordType.DeveloperName == 'OS_Buzon_Contact' || contactoIdentificado.RecordType.DeveloperName == 'CC_Colaborador';
                }

                List<AM_Correos_Buzones_Entrada__mdt> correoDependencia = [SELECT AM_Email_Redireccion_Buzon__c, AM_Cola_Procedencia__c, AM_Canal_Procedencia__c, AM_Record_type_DeveloperName_por_defecto__c
                                                            FROM AM_Correos_Buzones_Entrada__mdt WHERE AM_Email_Redireccion_Buzon__c = :envelope.toAddress LIMIT 1];

                if (!correoDependencia.isEmpty() && !mapaCuentasContactos.isEmpty()){
                    if ((correoDependencia[0].AM_Canal_Procedencia__c == 'Buzón Fondos'
                    || correoDependencia[0].AM_Canal_Procedencia__c == 'Buzón Carteras')
                    && (mapaCuentasContactos.size() > 1 || mapaCuentasContactos.values()[0].size() > 1)){

                        List<String> empleadosRT = new List<String>{'CC_Empleado', 'OS_Buzon_Contact', 'CC_Colaborador'};
                        List<Contact> allContactos = new List<Contact>();
                        List<Contact> contactosEmpleado = new List<Contact>();

                        for(List<Contact> contactos : mapaCuentasContactos.values()){
                            allContactos.addAll(contactos);
                        }
                        for(Contact contactoIndividual : allContactos){
                            if(empleadosRT.contains(contactoIndividual.RecordType.DeveloperName)){
                                contactosEmpleado.add(contactoIndividual);
                            }
                        }
                        if(contactosEmpleado.size() == 1){
                            accountId = contactosEmpleado[0].AccountId;
                            contactId = contactosEmpleado[0].Id;
                            recordTypeEmpleado = true;
                        }

                }
                }
                
                // Creación de Caso
                Case caso = new Case();
                if (recordTypeEmpleado) {
                    caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Empleado');
                } else {
                    caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Cliente');
                }
                caso.Origin = 'Email';
                caso.Subject = email.Subject;
                if (String.isNotBlank(email.plainTextBody)) {
                    caso.Description = email.plainTextBody.left(32000);
                } else if (String.isNotBlank(email.htmlBody)) {
                    caso.Description  = email.htmlBody.stripHtmlTags().left(32000);
                } 
                caso.AccountId = accountId;
                caso.ContactId = contactId;
                caso.CC_MailTelfNotif__c = email.fromAddress;
                caso.OS_Remitente_Inicial__c = email.fromAddress; 
            
                //Identificamos si el remitente está considerado "SNAD"
                List<AM_Correos_SNAD__mdt> correosSnad = [SELECT AM_Correos_SNAD__c FROM AM_Correos_SNAD__mdt WHERE AM_Correos_SNAD__c = :email.fromAddress LIMIT 1];

                if (!correosSnad.isEmpty()) { caso.AM_Caso_Origen_SNAD__c = true; 
                }
                
                //Buscamos en el custom medatada la cola equivalente a la dirección de email al que se ha dirigido el correo (filtramos por la dirección de email que genera salesforce, no la del buzón original)
                if (!correoDependencia.isEmpty()) {

                    caso.CC_Canal_Procedencia__c = correoDependencia[0].AM_Canal_Procedencia__c;
                    
                    List<Group> colas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :correoDependencia[0].AM_Cola_Procedencia__c];
                    if (!colas.isEmpty()) {
                        caso.OwnerId = colas[0].Id;
                    }
                    //SOBREESCRIBIMOS recordType con recordType por defecto si existe (si no ha encontrado contacto). Si no existe RT por defecto, se pondrá AM_Empleado
                    if(correoDependencia[0].AM_Record_type_DeveloperName_por_defecto__c != null && contactId == null){
                        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', correoDependencia[0].AM_Record_type_DeveloperName_por_defecto__c);
                    }
                }

                insert caso;

                // Gestión adjuntos
                AM_Email_GestionAdjuntos.gestionAdjuntos(email, caso, body, envelope.toAddress);

                result.success = true;
            }
            return result;
        }
        catch (Exception e){
            CBK_EmailExceptions_TRHan.handledEmailServiceException(e, email);
            throw e;
        }
    }   
}