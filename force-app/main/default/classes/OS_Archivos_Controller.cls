public with sharing class OS_Archivos_Controller {
    
        @AuraEnabled(cacheable = true)
        public static List<Archivo> recuperarCampos (Id caseId, String campo, String orden, List<String> filtroExt) {
            /*Set<String> filtroExt = new Set<String>();
            for (String extension : filtros) {
                filtroExt.add(extension);
            }*/
            List<Archivo> archivos = new List<Archivo>();
        
            switch on campo {
                when 'ultimaModificacion' {
                    campo = 'ContentDocument.LastModifiedDate';
                }
                when 'urlTitulo' {
                    campo = 'ContentDocument.Title';
                }
                when 'urlOrigen' {
                    campo = 'LinkedEntity.name';
                }
                when 'tamano' {
                    campo = 'ContentDocument.ContentSize';
                }
                when 'remitente' {
                    campo = 'FromAddress';
                }
                when else {
                    campo = 'ContentDocument.Owner.Name';
                }
                
            }
            Map<Id,List<Id>> mapEmailCdl = new Map<Id,List<Id>>();
            Case casoAdjuntos = [SELECT Id, Subject, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
            
            if (campo != 'FromAddress') {
                Map<Id,Boolean> mapEmailMessageIncoming= new Map<Id,Boolean>();
                Map<Id,String> mapEmailMessageRemitente= new Map<Id,String>();
                
                List<EmailMessage> listaEmailMessage = [SELECT Subject, Id, Incoming, FromAddress FROM EmailMessage WHERE ParentId = :caseId];
                
                for (EmailMessage email : listaEmailMessage) {
                    mapEmailMessageIncoming.put(email.Id,  email.Incoming);
                    mapEmailMessageRemitente.put(email.Id,  String.valueOf(email.FromAddress));
                    mapEmailCdl.put(email.Id, new List<Id>());
                }
                
                
                Set<Id> linkedEntityIds = new Set<Id>();
                for (Id idEmailMessage : mapEmailMessageIncoming.keySet()) {
                    linkedEntityIds.add(idEmailMessage);
                    
                }
                
                if (!linkedEntityIds.isEmpty()){
                    if (Database.query('SELECT LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityIds ORDER BY ' +  String.escapeSingleQuotes(campo) + ' ' + String.escapeSingleQuotes(orden) ).isEmpty()){
                        linkedEntityIds.clear();
                        //Si el caso tiene correos, pero los correos no tienen adjuntos
                    }
                }
                linkedEntityIds.add(caseId);
                String query = '';
                if (filtroExt.contains('all')) {
                    query = 'SELECT Id, LinkedEntity.Type, LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityIds ORDER BY ' + String.escapeSingleQuotes(campo)  + ' ' + String.escapeSingleQuotes(orden) ;
                } else {
                    query = 'SELECT Id, LinkedEntity.Type, LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityIds AND ContentDocument.FileExtension IN :filtroExt ORDER BY ' + String.escapeSingleQuotes(campo) + ' ' + String.escapeSingleQuotes(orden) ;
                }
                
                
                
                Map<String,ContentDocumentLink> mapContentDocumentLink = new Map<String,ContentDocumentLink>();
                
                List<ContentDocumentLink> listaArchivos =  Database.query(query);
                List<ContentDocumentLink> listaArchivosSinDuplicados =  new List<ContentDocumentLink>();
                List<Id> listaArchivosEliminar =  new List<Id>();
                List<Id> listaNuevaEmails =  new List<Id>();
    
                
                //Para evitar adjuntos duplicados
                if (!listaArchivos.isEmpty()) {
                    for (ContentDocumentLink cdl : listaArchivos) {
                        if (!mapContentDocumentLink.containsKey(cdl.ContentDocumentId)) {
                            mapContentDocumentLink.put(cdl.ContentDocumentId,cdl);
                        } else {
                            if (String.valueOf(mapContentDocumentLink.get(cdl.ContentDocumentId).LinkedEntityId.getSObjectType()) == 'Case') {
                                mapContentDocumentLink.remove(cdl.ContentDocumentId);
                                mapContentDocumentLink.put(cdl.ContentDocumentId,cdl);
                            }                        
                        }
                                    
                    }
    
                    for (String cdl : mapContentDocumentLink.keySet()) {
                        listaArchivosSinDuplicados.add(mapContentDocumentLink.get(cdl));
                    }
                    
                    for (ContentDocumentLink file : listaArchivosSinDuplicados) {
                        Archivo archivo = new Archivo();
                        archivo.Id = file.ContentDocumentId;
                        archivo.titulo = file.ContentDocument.Title;
                        archivo.urlTitulo = '/'+file.ContentDocumentId;
                        archivo.propietario = file.ContentDocument.Owner.Name;
                        archivo.urlPropietario = '/'+file.ContentDocument.OwnerId;
                        archivo.tamano = String.valueOf(file.ContentDocument.ContentSize)+'B';
                        archivo.ultimaModificacion = file.ContentDocument.LastModifiedDate.format('dd/MM/YYYY HH:mm');
                        
                        
                        if (linkedEntityIds.size() == 1) {
                            archivo.origen = casoAdjuntos.CaseNumber;
                            archivo.iconoOrigen = 'standard:email_chatter';
                            archivo.remitente = '[Sin remitente]';
                            archivo.urlOrigen = '/'+caseId;
                        } else {
                            if (String.valueOf(file.linkedEntityId.getSobjectType()) == 'Case') {
                                archivo.origen = casoAdjuntos.CaseNumber;
                                archivo.remitente = '[Sin remitente]';
                                archivo.urlOrigen = '/'+caseId;
                                archivo.iconoOrigen = 'standard:email_chatter';
                            } else {
                                archivo.origen =  file.LinkedEntity.name;
                                archivo.remitente = mapEmailMessageRemitente.get(file.LinkedEntityId);
                                archivo.urlOrigen = '/'+file.LinkedEntityId;
                                if (mapEmailMessageIncoming.get(file.LinkedEntityId)) {
                                    archivo.iconoOrigen = 'standard:email_chatter';
                                } else {
                                    archivo.iconoOrigen = 'standard:email';
                                }
                            }
                        }
                        archivo.ext = file.ContentDocument.FileExtension.toUpperCase();
                        
                        switch on file.ContentDocument.FileExtension {
                            when 'png','jpg', 'gif', 'bmp' {
                                archivo.iconoArchivo = 'doctype:image';
                            }
                            when 'pdf' {
                                archivo.iconoArchivo = 'doctype:pdf';
                            }
                            when 'doc', 'docx', 'txt' {
                                archivo.iconoArchivo = 'doctype:word';
                            }
                            when 'ppt', 'pptx' {
                                archivo.iconoArchivo = 'doctype:ppt';
                            }
                            when 'xlsx', 'xls' {
                                archivo.iconoArchivo = 'doctype:excel';
                            }
                            when 'zip', 'rar' {
                                archivo.iconoArchivo = 'doctype:zip';
                            }
                            when 'csv' {
                                archivo.iconoArchivo = 'doctype:csv';
                            }
                            when else {
                                archivo.iconoArchivo = 'doctype:unknown';
                            }
                            
                        }
                        archivos.add(archivo);
                    }   
                }
            
            } else {
                
                List<Case> listCasos = Database.query('Select Id, casenumber, subject, (Select id, subject From emailmessages) from Case where id = :caseId ');
                Set<Id> setIdsEmailMessage = new Set<Id>();
                Set<Id> setIdsCasos = new Set<Id>();
                for (Case caso : listCasos) {
                    for (EmailMessage em : caso.emailmessages){
                        setIdsEmailMessage.add(em.Id);
                    }
                    setIdsCasos.add(caso.Id);
                }
                Set<Id> setIdsCdl = new Set<Id>();
                List<EmailMessage> listaEmailmessageCdl = new List<EmailMessage>();
                if (filtroExt.contains('all')) {
                    listaEmailmessageCdl = Database.query('Select Id, subject, fromaddress, Incoming, (Select LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title From ContentdocumentLinks) FROM EmailMessage WHERE Id IN :setIdsEmailMessage ORDER BY ' + String.escapeSingleQuotes(campo) + ' '+String.escapeSingleQuotes(orden));
                } else {
                    listaEmailmessageCdl = Database.query('Select Id, subject, fromaddress, Incoming, (Select LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title From ContentdocumentLinks WHERE ContentDocument.FileExtension IN :filtroExt) FROM EmailMessage WHERE Id IN :setIdsEmailMessage ORDER BY ' + String.escapeSingleQuotes(campo)  + ' '+String.escapeSingleQuotes(orden));
                }
                Map<Integer,List<SObject>> mapOrden= new Map<Integer,List<SObject>>();
                
                if (orden == 'desc') {
                    for	(EmailMessage em : listaEmailmessageCdl ) {
                        for (ContentDocumentLink file : em.ContentDocumentLinks) {
                            if (!setIdsCdl.contains(file.ContentDocumentId)) {                
                                
                                setIdsCdl.add(file.ContentDocumentId);
                                
                                Archivo archivo = new Archivo();
                                archivo.Id = file.ContentDocumentId;
                                archivo.titulo = file.ContentDocument.Title;
                                archivo.urlTitulo = '/'+file.ContentDocumentId;
                                archivo.propietario = file.ContentDocument.Owner.Name;
                                archivo.urlPropietario = '/'+file.ContentDocument.OwnerId;
                                archivo.tamano = String.valueOf(file.ContentDocument.ContentSize)+'B';
                                archivo.ultimaModificacion = file.ContentDocument.LastModifiedDate.format('dd/MM/YYYY HH:mm');
                                archivo.remitente = em.fromaddress;
                                archivo.urlOrigen = '/'+em.Id;
                                archivo.origen = em.Subject;
                                
                                if (em.Incoming) {
                                    archivo.iconoOrigen = 'standard:email_chatter';
                                } else {
                                    archivo.iconoOrigen = 'standard:email';
                                }
                                
                                archivo.ext = file.ContentDocument.FileExtension.toUpperCase();
                                
                                switch on file.ContentDocument.FileExtension {
                                    when 'png','jpg', 'gif', 'bmp' {
                                        archivo.iconoArchivo = 'doctype:image';
                                    }
                                    when 'pdf' {
                                        archivo.iconoArchivo = 'doctype:pdf';
                                    }
                                    when 'doc', 'docx', 'txt' {
                                        archivo.iconoArchivo = 'doctype:word';
                                    }
                                    when 'ppt', 'pptx' {
                                        archivo.iconoArchivo = 'doctype:ppt';
                                    }
                                    when 'xlsx', 'xls' {
                                        archivo.iconoArchivo = 'doctype:excel';
                                    }
                                    when 'zip', 'rar' {
                                        archivo.iconoArchivo = 'doctype:zip';
                                    }
                                    when 'csv' {
                                        archivo.iconoArchivo = 'doctype:csv';
                                    }
                                    when else {
                                        archivo.iconoArchivo = 'doctype:unknown';
                                    }
                                }
                                archivos.add(archivo);
                            }
                        }
                    }
                    //for adjuntos caso
                    List<Case> listaCasosCdl = new List<Case>();
                    if (filtroExt.contains('all')) {
                        listaCasosCdl = Database.query('Select Id, Subject,  (Select LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title From ContentdocumentLinks WHERE ContentDocumentId NOT IN :setIdsCdl) FROM Case WHERE Id = :caseId');
                    } else {
                        listaCasosCdl = Database.query('Select Id, Subject,  (Select LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title From ContentdocumentLinks WHERE ContentDocumentId NOT IN :setIdsCdl AND ContentDocument.FileExtension IN IN :filtroExt) FROM Case WHERE Id = :caseId');
                    }
                    for	(Case caso : listaCasosCdl ) {
                        for (ContentDocumentLink file : caso.ContentDocumentLinks) {  
                            Archivo archivo = new Archivo();
                            archivo.Id = file.ContentDocumentId;
                            archivo.titulo = file.ContentDocument.Title;
                            archivo.urlTitulo = '/'+file.ContentDocumentId;
                            archivo.propietario = file.ContentDocument.Owner.Name;
                            archivo.urlPropietario = '/'+file.ContentDocument.OwnerId;
                            archivo.tamano = String.valueOf(file.ContentDocument.ContentSize)+'B';
                            archivo.ultimaModificacion = file.ContentDocument.LastModifiedDate.format('dd/MM/YYYY HH:mm');
                            archivo.remitente = '[Sin remitente]';
                            archivo.urlOrigen = '/'+casoAdjuntos.Id;
                            archivo.origen = casoAdjuntos.CaseNumber;
                            archivo.iconoOrigen = 'standard:email_chatter';
                            
                            
                            archivo.ext = file.ContentDocument.FileExtension.toUpperCase();
                            
                            switch on file.ContentDocument.FileExtension {
                                when 'png','jpg', 'gif', 'bmp' {
                                    archivo.iconoArchivo = 'doctype:image';
                                }
                                when 'pdf' {
                                    archivo.iconoArchivo = 'doctype:pdf';
                                }
                                when 'doc', 'docx', 'txt' {
                                    archivo.iconoArchivo = 'doctype:word';
                                }
                                when 'ppt', 'pptx' {
                                    archivo.iconoArchivo = 'doctype:ppt';
                                }
                                when 'xlsx', 'xls' {
                                    archivo.iconoArchivo = 'doctype:excel';
                                }
                                when 'zip', 'rar' {
                                    archivo.iconoArchivo = 'doctype:zip';
                                }
                                when 'csv' {
                                    archivo.iconoArchivo = 'doctype:csv';
                                }
                                when else {
                                    archivo.iconoArchivo = 'doctype:unknown';
                                }
                                
                            }
                            archivos.add(archivo);
                        }
                    }
                } else {
                    for	(EmailMessage em : listaEmailmessageCdl ) {
                        for (ContentDocumentLink file : em.ContentDocumentLinks) {                  
                            setIdsCdl.add(file.ContentDocumentId);
                        }
                    }
                    
                    //for adjuntos caso
                    List<Case> listaCasosCdl = new List<Case>();
                    if (filtroExt.contains('all')) {
                        listaCasosCdl = Database.query('Select Id, Subject,  (Select LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title From ContentdocumentLinks WHERE ContentDocumentId NOT IN :setIdsCdl) FROM Case WHERE Id = :caseId');
                    } else {
                        listaCasosCdl = Database.query('Select Id, Subject,  (Select LinkedEntityId, ContentDocumentId, ContentDocument.OwnerId, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate,  ContentDocument.ContentSize, LinkedEntity.name, ContentDocument.FileExtension, ContentDocument.Title From ContentdocumentLinks WHERE ContentDocumentId NOT IN :setIdsCdl AND ContentDocument.FileExtension IN :filtroExt ) FROM Case WHERE Id = :caseId');
                    }
                    for	(Case caso : listaCasosCdl ) {
                        for (ContentDocumentLink file : caso.ContentDocumentLinks) {  
                            Archivo archivo = new Archivo();
                            archivo.Id = file.ContentDocumentId;
                            archivo.titulo = file.ContentDocument.Title;
                            archivo.urlTitulo = '/'+file.ContentDocumentId;
                            archivo.propietario = file.ContentDocument.Owner.Name;
                            archivo.urlPropietario = '/'+file.ContentDocument.OwnerId;
                            archivo.tamano = String.valueOf(file.ContentDocument.ContentSize)+'B';
                            archivo.ultimaModificacion = file.ContentDocument.LastModifiedDate.format('dd/MM/YYYY HH:mm');
                            archivo.remitente = '[Sin remitente]';
                            archivo.urlOrigen = '/'+casoAdjuntos.Id;
                            archivo.origen = casoAdjuntos.CaseNumber;
                            archivo.iconoOrigen = 'standard:email_chatter';
                            
                            
                            archivo.ext = file.ContentDocument.FileExtension.toUpperCase();
                            
                            switch on file.ContentDocument.FileExtension {
                                when 'png','jpg', 'gif', 'bmp' {
                                    archivo.iconoArchivo = 'doctype:image';
                                }
                                when 'pdf' {
                                    archivo.iconoArchivo = 'doctype:pdf';
                                }
                                when 'doc', 'docx', 'txt' {
                                    archivo.iconoArchivo = 'doctype:word';
                                }
                                when 'ppt', 'pptx' {
                                    archivo.iconoArchivo = 'doctype:ppt';
                                }
                                when 'xlsx', 'xls' {
                                    archivo.iconoArchivo = 'doctype:excel';
                                }
                                when 'zip', 'rar' {
                                    archivo.iconoArchivo = 'doctype:zip';
                                }
                                when 'csv' {
                                    archivo.iconoArchivo = 'doctype:csv';
                                }
                                when else {
                                    archivo.iconoArchivo = 'doctype:unknown';
                                }
                                
                            }
                            archivos.add(archivo);
                            
                        }
                    }
                    setIdsCdl.clear();
                    //for adjuntos email
                    for	(EmailMessage em : listaEmailmessageCdl ) {
                        for (ContentDocumentLink file : em.ContentDocumentLinks) {                  
                            if (!setIdsCdl.contains(file.ContentDocumentId)) {                
                                setIdsCdl.add(file.ContentDocumentId);
                                
                                Archivo archivo = new Archivo();
                                archivo.Id = file.ContentDocumentId;
                                archivo.titulo = file.ContentDocument.Title;
                                archivo.urlTitulo = '/'+file.ContentDocumentId;
                                archivo.propietario = file.ContentDocument.Owner.Name;
                                archivo.urlPropietario = '/'+file.ContentDocument.OwnerId;
                                archivo.tamano = String.valueOf(file.ContentDocument.ContentSize)+'B';
                                archivo.ultimaModificacion = file.ContentDocument.LastModifiedDate.format('dd/MM/YYYY HH:mm');
                                archivo.remitente = em.fromaddress;
                                archivo.urlOrigen = '/'+em.Id;
                                archivo.origen = em.Subject;
                                
                                if (em.Incoming) {
                                    archivo.iconoOrigen = 'standard:email_chatter';
                                } else {
                                    archivo.iconoOrigen = 'standard:email';
                                }
                                
                                archivo.ext = file.ContentDocument.FileExtension.toUpperCase();
                                
                                switch on file.ContentDocument.FileExtension {
                                    when 'png','jpg', 'gif', 'bmp' {
                                        archivo.iconoArchivo = 'doctype:image';
                                    }
                                    when 'pdf' {
                                        archivo.iconoArchivo = 'doctype:pdf';
                                    }
                                    when 'doc', 'docx', 'txt' {
                                        archivo.iconoArchivo = 'doctype:word';
                                    }
                                    when 'ppt', 'pptx' {
                                        archivo.iconoArchivo = 'doctype:ppt';
                                    }
                                    when 'xlsx', 'xls' {
                                        archivo.iconoArchivo = 'doctype:excel';
                                    }
                                    when 'zip', 'rar' {
                                        archivo.iconoArchivo = 'doctype:zip';
                                    }
                                    when 'csv' {
                                        archivo.iconoArchivo = 'doctype:csv';
                                    }
                                    when else {
                                        archivo.iconoArchivo = 'doctype:unknown';
                                    }
                                    
                                }
                                archivos.add(archivo);
                            }
                        }
                    }
                }   
            }
            return archivos;
        }
        
        public class Archivo {
            @AuraEnabled public Id id{get;set;}
            @AuraEnabled public String titulo{get;set;}
            @AuraEnabled public String iconoArchivo{get;set;}
            @AuraEnabled public String propietario{get;set;}
            @AuraEnabled public String ultimaModificacion{get;set;}
            @AuraEnabled public String tamano{get;set;}
            @AuraEnabled public String origen{get;set;}
            @AuraEnabled public String iconoOrigen{get;set;}
            @AuraEnabled public String urlOrigen{get;set;}
            @AuraEnabled public String urlTitulo{get;set;}
            @AuraEnabled public String urlPropietario{get;set;}
            @AuraEnabled public String ext{get;set;}
            @AuraEnabled public String remitente{get;set;}
        }
    }