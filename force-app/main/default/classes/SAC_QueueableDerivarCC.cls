public without sharing class SAC_QueueableDerivarCC implements Queueable{
    
    List<Case> lstCases;
    String idReclamacion;
    
    public SAC_QueueableDerivarCC(String idCasoDisparador, List<Case> listaCasosCCInbound) {
        lstCases = listaCasosCCInbound;
		idReclamacion = idCasoDisparador;
    }
    
    public void execute(QueueableContext context) {
        
        List<SObject> listadoAuxiliarRegistro = new List<SObject>();
        
        if(!lstCases.isEmpty()){
            Database.insert(lstCases); 
        } 
        
        //Obtencion de Cartas Postales y archivos adjuntos
        List<ContentDocumentLink> cdlist = [SELECT id, LinkedEntityId, ContentDocumentID FROM ContentDocumentLink WHERE LinkedEntityId =: idReclamacion];
        Set<Id> fileId = new Set<Id>();
        for(ContentDocumentLink cl:cdlist){
        	fileId.add(cl.ContentDocumentId);
        }
        List<ContentVersion> adjuntosParaCC = [SELECT Id, Title, VersionData, PathOnClient, SAC_StringRedaccion_fileupload__c FROM ContentVersion WHERE ContentDocumentId IN: fileId];
        
        
        if(!adjuntosParaCC.isEmpty()){
            List<ContentVersion> lstContent = adjuntosParaCC;
            for(ContentVersion cv: lstContent){
                ContentVersion cvCopy = new ContentVersion(
                    Title= cv.Title, 
                    PathOnClient = cv.PathOnClient,
                    VersionData = cv.VersionData,
                    FirstPublishLocationId = lstCases.get(0).Id,
                    SAC_StringRedaccion_fileupload__c = cv.SAC_StringRedaccion_fileupload__c
                );
                listadoAuxiliarRegistro.add(cvCopy);
            }
        } 
        
         //Obtencion de Emails del cliente
         List<EmailMessage> emailsParaCC = [SELECT Status, Incoming, MessageDate, FromAddress, SAC_EnvioRedaccion__c, SAC_IDAdjuntos__c, FromName, CcAddress, Subject, HtmlBody, ToAddress, ValidatedFromAddress, BccAddress FROM EmailMessage WHERE ParentId =: idReclamacion];
           
        if(!emailsParaCC.isEmpty()){
            for(EmailMessage em : emailsParaCC){
                EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                emailMsg.ToAddress = em.ToAddress;
                emailMsg.Subject = em.Subject;
                emailMsg.HtmlBody = em.HtmlBody;
                emailMsg.MessageDate = em.MessageDate;
                emailMsg.Status = em.Status;
                emailMsg.FromAddress = em.FromAddress;
                emailMsg.SAC_EnvioRedaccion__c = em.SAC_EnvioRedaccion__c;
                emailMsg.SAC_IDAdjuntos__c = em.SAC_IDAdjuntos__c;
                emailMsg.CcAddress = em.CcAddress;
                emailMsg.BccAddress = em.BccAddress;
                emailMsg.FromName = em.FromName;
                emailMsg.ParentId = lstCases.get(0).Id;
                emailMsg.Incoming = em.Incoming;
                listadoAuxiliarRegistro.add(emailMsg);
            }
        } 
        
        if(!Test.isRunningTest()){
            Database.insert(listadoAuxiliarRegistro);
        }
        
    }
}