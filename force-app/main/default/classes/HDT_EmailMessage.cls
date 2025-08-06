public with sharing class HDT_EmailMessage {

    public static EmailMessage crearEmailMessage(Messaging.InboundEmail email, String toAddress, Id idCaso, Id contactId, String htmlBody) {
        
        //Creamos la tarea para que quede registro
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        tarea.Type = 'Correo - Entrada';
        tarea.TaskSubtype = 'Email';
        tarea.Subject = email.subject.left(255);
        tarea.ActivityDate = System.today();
        tarea.Status = 'Completed';
        //tarea.Description = body.left(32000);
        tarea.WhatId = idCaso;
        tarea.WhoId = contactId;
        insert tarea;

        //Creamos un EmailMessage para guardar el correo que acaban de enviar y asociarlo al caso
        EmailMessage correo = new EmailMessage();
        correo.Subject = email.Subject;
        correo.Status = '1';
        if (email.ccAddresses != null) {
            correo.CcAddress = String.join(email.ccAddresses, ',');
        }
        correo.FromAddress = email.fromAddress;
        correo.FromName = email.fromName;
        correo.Headers = JSON.serialize(email.headers);
        correo.Incoming = true;
        correo.MessageDate = DateTime.now();
        correo.ParentId = idCaso;

        //Trazabilidad Emailservice petición coe
        correo.MessageIdentifier = email.messageId;
        correo.CBK_sfdcMessageId__c = email.messageId?.left(255);
        correo.ThreadIdentifier = email.inReplyTo;

        if (!Test.isRunningTest()) {
            correo.ToAddress = string.join(email.toAddresses,',');
        } else {
            correo.ToAddress = toAddress;
        }

        if (String.isNotBlank(htmlBody)) {
            correo.HtmlBody = htmlBody.left(32000);
        } else {
            correo.TextBody = email.plainTextBody.left(32000);
            correo.HtmlBody = null;
        }
        insert correo;
        return correo;
    }
}