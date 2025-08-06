public with sharing class CC_Gestion_Derivar_Mecanismo_Firma {    
    @AuraEnabled
    public static void crearCasoMecanismoFirma(String recordId) {
        if(recordId != null) {
            Case casoOrigen = [SELECT CaseNumber, ContactId, AccountId, OwnerId, RecordTypeId, Status, Origin, Subject, Description, CC_Canal_Contacto__c, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Cliente__c, CC_Canal_Operativo__c, CC_Canal_Respuesta__c, CC_CasoRelacionado__c, CC_Cola_Procedencia__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, CC_MCC_Causa__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Solucion__c, CC_MCC_Tematica__c, CC_Tipo_Contacto__c, CC_Canal_Resolucion__c, CC_CierreAutomaticoCSBD__c, CC_DevolucionCSBD__c FROM Case WHERE Id = :recordId LIMIT 1];
            List<CBK_Case_Extension__c> extensionOrigen = [SELECT Id, CC_Risk_Restricted__c,CC_Risk_Denied__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :recordId LIMIT 1];
            List<Task> tareasOrigen = [SELECT RecordTypeId, Type, Subject, Description, Status, Priority, CC_Tipo_Cierre__c, OwnerId, CC_Nombre_Empresa__c, ActivityDate, WhatId, WhoId, CC_Procesos_Aceptados__c FROM Task WHERE WhatId = :casoOrigen.Id];
            List<EmailMessage> emailsOrigen = [SELECT MessageDate, CC_Procedencia__c, CC_Grupo_Colab__c, CC_Interno__c, CC_Segunda_Oficina__c, Status, CC_Plantilla__c, FromAddress, FromName, ToAddress, Subject, HtmlBody, TextBody FROM EmailMessage WHERE ParentId = :casoOrigen.Id];
            CBK_Case_Extension__c extension;
            Case nuevoCaso;
            List<Task> nuevasTareas = new List<Task>();
            List<EmailMessage> nuevosEmailMessages = new List<EmailMessage>();
            Boolean circuitoCasoNuevo = CC_Settings__c.getValues('CC_MecanismoFirmaCircuitoCaso').CC_Activa__c;
                try{
                    if(circuitoCasoNuevo){
                        nuevoCaso = casoOrigen.clone(false, true);
                        nuevoCaso.CC_CasoRelacionado__c = casoOrigen.Id;
                        nuevoCaso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Videollamada_Enrollment_Caixabank_Sign' LIMIT 1].Id;
                        nuevoCaso.Subject = 'Mecanismo de firma';

                        insert nuevoCaso;

                        extension = new CBK_Case_Extension__c();
                        extension.Case_Id__c = nuevoCaso.Id;
                        extension.CC_MecanismoFirma__c = true;
                        extension.CC_Risk_Restricted__c = extensionOrigen[0].CC_Risk_Restricted__c;
                        extension.CC_Risk_Denied__c = extensionOrigen[0].CC_Risk_Denied__c;
                        //extension.RecordTypeId = extensionOrigen[0].RecordTypeId;

                        insert extension;

                        nuevoCaso.CBK_Case_Extension_Id__c = extension.Id;

                        update nuevoCaso;

                        for (Task tarea : tareasOrigen) {
                            Task nuevaTarea = tarea.clone(false, false);
                            nuevaTarea.WhatId = nuevoCaso.Id;
                            nuevasTareas.add(nuevaTarea);
                        }

                        for (EmailMessage em : emailsOrigen) {
                            EmailMessage nuevoEmail = em.clone(false, false);
                            nuevoEmail.ParentId = nuevoCaso.Id;
                            nuevosEmailMessages.add(nuevoEmail);
                        }

                        if (!nuevasTareas.isEmpty()) {
                            insert nuevasTareas;
                        }

                        if (!nuevosEmailMessages.isEmpty()) {
                            insert nuevosEmailMessages;
                        }
                        
                        if(nuevoCaso.Id != null) {
                            // casoOrigen.Status = 'Cerrado';
                            casoOrigen.CC_CierreAutomaticoCSBD__c = true;
                            casoOrigen.CC_CasoRelacionado__c = nuevoCaso.Id;

                            // casoOrigen.CC_DevolucionCSBD__c = true; // Este campo ahora indica el flag de documentación
                            update casoOrigen;

                            //Con esta actividad vemos si el caso es duplicado
                            CC_Activity.crearActividadMecanismoFirma(casoOrigen, casoOrigen.OwnerId);
                        }  
                    }else{
                        CC_Activity.crearActividadMecanismoFirma(casoOrigen, casoOrigen.OwnerId);                    

                        casoOrigen.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Videollamada_Enrollment_Caixabank_Sign' LIMIT 1].Id;
                        List<CBK_Case_Extension__c> caseExtension = [ SELECT Id, CC_MecanismoFirma__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :casoOrigen.Id LIMIT 1];
                        if (!caseExtension.isEmpty()) {
                            // Reutilizar y actualizar
                            caseExtension[0].CC_MecanismoFirma__c = true;
                            update caseExtension;
                        } else {
                            // Crear nuevo
                            extension = new CBK_Case_Extension__c(
                                Case_Id__c = casoOrigen.Id,
                                CC_MecanismoFirma__c = true,
                                CC_Risk_Restricted__c = extensionOrigen[0].CC_Risk_Restricted__c,
                                CC_Risk_Denied__c = extensionOrigen[0].CC_Risk_Denied__c
                                //RecordTypeId = extensionOrigen[0].RecordTypeId
                            );
                            insert extension;

                            casoOrigen.CBK_Case_Extension_Id__c = extension.Id;
                        }

                        update casoOrigen;

                    }

                }catch(Exception ex) {
                    CBK_Log.error('CC_Gestion_Derivar_Mecanismo_Firma insert/update caso', ex.getMessage());
                }
            } else {
                CC_CustomException.throwCustomException('Error en el proceso de creación/actualización de caso, no se recibió ningún id de caso');
            }
    }
    /*
    @AuraEnabled
    public static Boolean elegirCircuitoMecanismoFirma(String recordId) {
        Case caso = [SELECT Id, Subject FROM Case WHERE Id = :recordId LIMIT 1];
        CC_Settings__c configuracion = CC_Settings__c.getValues('CC_MecanismoFirmaCircuitos');
        String circuitoExtranjero = configuracion.CC_Configuracion_1__c;
        String circuitoCodigoFirma = configuracion.CC_Configuracion_2__c;
        Boolean retorno;

        if (caso.Subject ==circuitoExtranjero) {
            //Se va por circuito extranjero
            retorno = true;
        }else if(caso.Subject ==circuitoCodigoFirma) {
            //Se va por circuito codigo firma
            retorno = false;
        }
        return retorno;
    }*/

    @AuraEnabled
    public static Boolean comprobarCasoCreadoMecanismoFirma(String recordId) {
        List<Task> tareas = [SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Mecanismo de firma' LIMIT 1];
        Boolean retorno;
        if(!tareas.isEmpty()) {
            //El caso ya ha sido creado porque tiene una tarea de tipo 'Mecanismo de firma'
            retorno = true;
        } else {
            //El caso no ha sido creado porque no tiene una tarea de tipo 'Mecanismo de firma'
            retorno = false;
        }

        return retorno;
    }

    @AuraEnabled
    public static Boolean recuperarArgos(String recordId) {
            List<Task> tareasArgos = [SELECT Id, CC_Detalles_Solucion__c, CC_Solicitud_Informacion__c  FROM Task WHERE Type = 'Argos' AND WhatId= :recordId ORDER BY CreatedDate DESC LIMIT 1];
            Case caso = [SELECT Id, AccountId, ContactId FROM Case WHERE Id = :recordId LIMIT 1];
            Boolean argos;
            
            if (tareasArgos.isEmpty()) {
                argos = false; 
            }else{
                // Extraer AccountId y ContactId de CC_Detalles_Solucion__c
                String detallesSolucion = tareasArgos[0].CC_Detalles_Solucion__c;
                Boolean idsCoinciden = false;
                if (String.isNotBlank(detallesSolucion) && detallesSolucion.contains('-')) {
                    List<String> partes = detallesSolucion.split('-');
                    if (partes.size() == 2) {
                        String accountIdDetalle = partes[0].trim();
                        String contactIdDetalle = partes[1].trim();
                        if (accountIdDetalle == caso.AccountId.toString() && contactIdDetalle == caso.ContactId.toString() ) {
                            idsCoinciden = true;
                        }
                    }
                }

                if(tareasArgos[0].CC_Solicitud_Informacion__c  && idsCoinciden){
                    argos= true;
                }else{
                    argos= false;
                }
            }
            return argos;
    }

}