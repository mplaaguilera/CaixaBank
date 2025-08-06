public class AM_Metodos_EmailServices {

    public static String referenciaCorreo(Messaging.InboundEmail email) {
        //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes.ApexPages
        String referencia = null;
        String cuerpoCorreo = null;
        
        //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
        if (email.HtmlBody != null) {
            cuerpoCorreo = email.HtmlBody;
        }else if (email.plainTextBody != null) {
            cuerpoCorreo = email.plainTextBody;
        }
        if(cuerpoCorreo != null) {
            referencia = calculoReferenciaCorreo(cuerpoCorreo);
        }
        return referencia;
    }

    public static String referenciaCorreo(EmailMessage email) {
        //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes.ApexPages
        String referencia = null;
        String cuerpoCorreo = null;
        
        //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
        if (email.HtmlBody != null) {
            cuerpoCorreo = email.HtmlBody;
        } else if (email.TextBody != null) {
            cuerpoCorreo = email.TextBody;
        }
        if(cuerpoCorreo != null) {
            referencia = calculoReferenciaCorreo(cuerpoCorreo);
        }
        return referencia;
    }

    //referencia = (referencia).replaceAll('[^a-zA-Z0-9\\s+]', '');

    //Tercer metodo al que le pasamos el cuerpo del correo donde devuelve la referencia, entonces llamamos al metodo de referencia correo e insertamos la corrección

    public static String calculoReferenciaCorreo (String cuerpoCorreo){
        //
        String referencia = cuerpoCorreo.substringBetween('#@', '#');
        
        if(referencia != null && referencia != ''){
            referencia = (referencia).replaceAll('[^a-zA-Z0-9\\s+]', '');
        }      
        return referencia;

    }

    public static void respuestaTrasladoColaborador(Messaging.InboundEmail email, Id whatIdTarea, String myPlainText, String emailDestino) {
        
        //Encontramos caso según whatId de la tarea
        Case caso = [SELECT Status, Subject, CC_Canal_Procedencia__c, Origin, CC_Autoasignado_Coordinador__c, CC_Situacion_Caso__c, CC_Cola_Procedencia__c, ContactId
                        FROM Case WHERE Id = :whatIdTarea];

        //Cambio de estado del caso
        if (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Cerrado' || caso.Status == 'Pendiente Interno') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.Status = 'Activo';
            caso.OS_Aviso_Propietario__c = true; //para el aviso de nuevos correos.

            //Añadido desde trigger AM_EmailMessage_AI_TRHan.respuestaTrasladoColaborador
            caso.CC_Situacion_Caso__c = 'Respuesta colaborador';
            if (caso.CC_Cola_Procedencia__c != null) {
                //Se devuelve el caso a la cola de procedencia
                // caso.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c].Id;  //Comentado pendiente de si es necesario
            }

            update caso;
          
        }
          
            //Gestión adjuntos
            AM_Email_GestionAdjuntos.gestionAdjuntos(email, caso, myPlainText, emailDestino);
        
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(whatIdTarea, 'Traslado Colaborador', null, null);

    }

    public static void respuestaSolicitudInfo(Messaging.InboundEmail email, Id whatIdTarea, String myPlainText, String emailDestino) {
        
        //Encontramos caso según whatId de la tarea
        Case caso = [SELECT Id, Status, CC_Canal_Procedencia__c, ContactId, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c, CC_Situacion_Caso__c
                        FROM Case WHERE Id = :whatIdTarea];
        
        //Actualizar caso según estado actual
        if (caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Interno') { 
            caso.Status = 'Activo';
            caso.OS_Aviso_Propietario__c = true; //para el aviso de nuevos correos.
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();

            //Añadimos desde trigger AM_EmailMessage_AI_TRHan.respuestaSolicitudInfo
            caso.CC_Situacion_Caso__c = 'Respuesta cliente';

                //Si la propiedad del caso no está fijada a un coordinador, se devuelve el caso a la cola para
                //que lo pueda atender cualquier agente, no solo el propietario previo a la solicitud
            if (!caso.CC_Autoasignado_Coordinador__c && caso.CC_Cola_Procedencia__c != null) {
               // caso.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c].Id;  // Comentado pendiente de si es necesario o no
            }
            //
            
            update caso;

        } else if (caso.Status == 'Cerrado') {
            //Para solicitudes info se reabre el caso aunque se hubiera cerrado
            AM_Case.reapertura(caso.Id);
        }

        //Gestión adjuntos
        AM_Email_GestionAdjuntos.gestionAdjuntos(email, caso, myPlainText, emailDestino);

        //Cierre de la actividad de envío del traslado a grupo colaborador
        CC_Activity.finalizarActividadCaso(whatIdTarea, 'Solicitud Información', null, null);
    }
/*
    public static void respuestaRemitirColaborador(Messaging.InboundEmail email, Id WhatIdTarea, String myPlainText, String emailDestino) {

        //Encontramos caso según whatId de la tarea
        Case caso = [SELECT ContactId, Status, CC_Canal_Procedencia__c FROM Case WHERE Id = :WhatIdTarea];
        
        //Cambio de estado del caso
        if (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Cerrado' || caso.Status == 'Pendiente Interno') {
            caso.Status = 'Activo';
            update caso;
        }
    
        //Gestión adjuntos
        AM_Email_GestionAdjuntos.gestionAdjuntos(email, caso, myPlainText, emailDestino);

        //Cierre de la actividad de envío del traslado a grupo colaborador
        CC_Activity.finalizarActividadCaso(WhatIdTarea, 'Remitir Colaborador', null, null);
    }*/

    public static void respuestaCliente(Messaging.InboundEmail email, Id WhatIdTarea, String myPlainText, String emailDestino) {
        
        //Cuando un cliente responde a un email enviado desde la operativa reponder a cliente se envía un email automático
        //Encontramos caso según whatId de la tarea
        Case caso = [SELECT RecordTypeId, Status, CC_Numero_Documento__c, CC_Idioma__c, AccountId, ContactId, CC_Canal_Procedencia__c,
                        CC_Cola_Procedencia__c FROM Case WHERE Id = :WhatIdTarea];

        //Estado
        if (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Cerrado' || caso.Status == 'Pendiente Interno') {
            //Para respuestas de cliente se reabre el caso aunque se hubiera cerrado
            AM_Case.reapertura(caso.Id);
        }

        // REVISAR TRIGGER AM_EmailMessage_AI_TRHan.respuestaCliente  >> reasignación de owner y String htmlBody >>> ¿Lo incluimos?
        
        //Gestión adjuntos
        AM_Email_GestionAdjuntos.gestionAdjuntos(email, caso, myPlainText, emailDestino);
    }
}