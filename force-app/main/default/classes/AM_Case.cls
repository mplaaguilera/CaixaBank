public with sharing class AM_Case {
    
    public static Case reapertura(Id idCaso) {
    
        //Reapertura caso por respuesta (el estado pasa a Activo y se registra el motivo de reapertura en una nueva actividad)
        Case caso = [SELECT Status FROM Case WHERE Id = :idCaso];
        if (caso.Status != 'Activo') {
            caso.Status = 'Activo';
            caso.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
            update caso;

            //Creamos tarea para registrar la reapertura del caso por la respuesta del cliente/colaborador
            Task tareaReapertura = new Task();
            tareaReapertura.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
            tareaReapertura.WhatId = idCaso;
            tareaReapertura.Type = 'Reapertura por respuesta de cliente';
            tareaReapertura.Status = 'Completed';
            tareaReapertura.Subject = 'Reapertura por respuesta de cliente';
            tareaReapertura.Description = 'Reapertura por respuesta de cliente';
            tareaReapertura.ActivityDate = System.today();
            tareaReapertura.CC_Fecha_Inicio__c = System.now();
            insert tareaReapertura;
        }
        return caso;
    }

    /**
     * @description método para cerrar el caso después de la operativa responderCliente
     */
    public static Case responderCerrar(Case caso){
        if (caso.Status == 'Activo') {
            caso.Status = 'Cerrado';
            caso.OS_Cerrado_Operativa__c = false;  // no está en entorno CAM aún // Pendiente de que esté añadido OS_Cerrado_Operativa__c = true EN OS_Case_Operativas_Controller (se llama en trigger AI)
        }
        return caso;
    }

    public static Case duplicarCaso(Case casoPadre) {

        try {
            //clonar caso
            Case casoHijo = casoPadre.clone(false, true, false, false);
            casoHijo.ParentId = casoPadre.Id;
            insert casoHijo;

            //clonar correos electrónicos
            List<EmailMessage> correosCrear = new List<EmailMessage>();
            for (EmailMessage correo : [SELECT Headers, Incoming, FromName, FromAddress, ValidatedFromAddress,
                                        ToAddress, CcAddress, Subject, TextBody, HtmlBody, Status, CC_Interno__c
                                        FROM EmailMessage WHERE ParentId = :casoPadre.Id]) {
                EmailMessage correoCopia = correo.clone(false, true, false, false);
                correoCopia.ParentId = casoHijo.Id;
                correoCopia.ValidatedFromAddress = null;
                
                correosCrear.add(correoCopia);
            }
System.debug('numerocorreos  ' + correosCrear.size());

            insert correosCrear;
            
            //clonar tareas
            List<Task> tareasCrear = new List<Task>();

            for (Task tarea : [SELECT RecordTypeId, OwnerId, Subject, Type, Status, Description, AccountId, ActivityDate,
                                    CompletedDateTime, CC_Grupo_Colaborador_Id__c, CC_Tipo_Cierre__c, CC_Fecha_Inicio__c,
                                    CC_Fecha_Fin__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, CC_Llamada_Id__c
                                FROM Task WHERE WhatId = :casoPadre.Id
                                AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task')]) {
                Task tareaCopia = tarea.clone(false, true, false, false);
                tareaCopia.CC_Referencia_Correo_Saliente__c = null;
                tareaCopia.WhatId = casoHijo.Id;
                tareasCrear.add(tareaCopia);
            }
            
            //nueva actividad de caso duplicado en el nuevo caso hijo 
            Task nuevaTarea = new Task();
            nuevaTarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
            nuevaTarea.WhatId = casoHijo.Id;
            nuevaTarea.Type = 'Duplicar caso';
            nuevaTarea.Subject = 'Duplicar caso';
            nuevaTarea.Status = 'Completed';
            nuevaTarea.ActivityDate = System.today();
            nuevaTarea.CC_Fecha_Inicio__c = System.now();
            nuevaTarea.CC_Fecha_Fin__c = System.now();
            nuevaTarea.Description = 'Caso principal: ' + casoPadre.CaseNumber;
            tareasCrear.add(nuevaTarea);

            insert tareasCrear;

            /* casoPadre.OS_Tiene_Casos_Relacionados__c = true;
            update casoPadre; */

            return casoHijo;

        } catch(Exception e) {
            System.debug('ee: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}