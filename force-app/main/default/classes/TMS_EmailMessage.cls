public with sharing class TMS_EmailMessage {

    public static EmailMessage crearEmailMessage(Messaging.InboundEmail email, String toAddress, Id idCaso, Id contactId, String htmlBody) {
        //Creamos un EmailMessage para guardar el correo que acaban de enviar y asociarlo al caso
        EmailMessage correo = new EmailMessage();
        correo.Subject = email.Subject;
        correo.Status = '1';
        if (email.ccAddresses != null) {
            correo.CcAddress = String.join(email.ccAddresses, ',');
        }
        correo.FromAddress = email.fromAddress;
        correo.FromName = email.fromName;
        correo.Headers = JSON.serialize(email.headers)?.left(31999);
        correo.Incoming = true;
        correo.MessageDate = DateTime.now();
        correo.ParentId = idCaso;
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
        correo.MessageIdentifier = email.messageId;
        correo.CBK_sfdcMessageId__c = email.messageId?.left(255);
        correo.ThreadIdentifier = email.inReplyTo;
        
        insert correo;
        return correo;
    }
}