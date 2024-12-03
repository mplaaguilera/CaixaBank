public class OS_NoCliente_Borrar_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        Id rtId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Datetime fechaNoCliente = Datetime.now();
        
        List<OS_NoCliente_Borrar__mdt> lstNoCliente = new List<OS_NoCliente_Borrar__mdt>([SELECT OS_NumeroDias__c FROM OS_NoCliente_Borrar__mdt WHERE DeveloperName = 'OS_Dias']);
        
        if(lstNoCliente.size() > 0)
        {
        	fechaNoCliente.addDays(-60); 
        }
        return Database.getQueryLocator([SELECT id FROM Case where RecordTypeId = :rtId AND Status = 'Cerrado' AND CC_Tipo_Cliente__c = 'No Cliente' AND ClosedDate < :fechaNoCliente]); 
    }
    
    public void execute(Database.BatchableContext bc, List<Case> records) { 
        
        List<Id> lstCaseIds = new List<Id>();
        List<Id> lstLlamadaIds = new List<Id>();
        
        for(Case caso : records) 
        {
            caso.OS_Email__c = null;
            caso.OS_Remitente_Inicial__c = null; 
            caso.CC_Numero_Documento__c = null;
            caso.Description = 'No cliente: Información borrada';
            caso.Subject = 'No cliente: Información borrada';
            caso.OS_Titular__c = 'No cliente: Información borrada';
            caso.OS_Telefono__c = 'No cliente: Información borrada';
            caso.CC_Detalles_Consulta__c = 'No cliente: Información borrada';
            caso.CC_Detalles_Solucion__c = 'No cliente: Información borrada';
            
            lstCaseIds.add(caso.Id);           
        }
        
        if(lstCaseIds.size() > 0) 
        {
            //Actividades de llamada y llamadas relacionadas
            List<Task> lstPhoneTasks = new List<Task>([SELECT id, CC_Llamada_Id__c FROM Task WHERE WhatId IN :lstCaseIds AND 
                                                       (Type = 'Llamada saliente' OR Type = 'Llamada entrante' OR Type = 'Llamada transferida' OR Type = 'Consulta')]);
            
            for(Task t : lstPhoneTasks)
            {
                if(t.CC_Llamada_Id__c != null)
                {
                	lstLlamadaIds.add(t.CC_Llamada_Id__c);  
                }
            }
            
            List<CC_Llamada__c> lstLlamadas = new List<CC_Llamada__c>([SELECT id FROM CC_Llamada__c WHERE Id IN :lstLlamadaIds]);
            
            system.debug('lstPhoneTasks ' + lstPhoneTasks);
            system.debug('lstLlamadas ' + lstLlamadas);
            delete lstPhoneTasks;
            delete lstLlamadas;
            
            //Actividades de correo relacionadas
            List<Task> lstEmailTasks = new List<Task>([SELECT id FROM Task WHERE WhatId IN :lstCaseIds 
                                                       AND (Type = 'Correo - Entrada' OR Type = 'Acuse de recibo' OR Type = 'Remitir Colaborador' OR Type = 'Responder a cliente' 
                                                            OR Type = 'Solicitud Información' OR Type = 'Traslado Colaborador' OR (Type = 'Automática' AND TaskSubtype = 'Email'))]);
            system.debug('lstEmailTasks ' + lstEmailTasks);
            delete lstEmailTasks; 
            
            //Emails relacionados 
            List<EmailMessage> lstEmessage = new List<EmailMessage>([SELECT id FROM EmailMessage WHERE RelatedToId IN :lstCaseIds]);
            delete lstEmessage;
            
            //Adjuntos relacionados 
            List<ContentDocumentLink> lstContentDoc = new List<ContentDocumentLink>([SELECT id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :lstCaseIds]);
			delete lstContentDoc;            
        }
         
        //Campos del caso
        update records;
        
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Done');
    } 

}