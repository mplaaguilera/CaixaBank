public  with sharing class CC_Borrado_Datos_Leads {
	@InvocableMethod
    public static void borrarDatos(List<Id> idsCasos){
        Set<Id> idsCasosSet = new Set<Id> (idsCasos);
        List<Task> tareas = new List<Task> ();
        
        Set<Id> idsLlamadas = new Set<Id>();	
        // A partir del id del caso buscar las tareas y comprobar si tienen asignada una llamada
			for(Task oTask : [SELECT Id, Subject, CC_Llamada_Id__c, WhatId, LastModifiedDate, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c !=NULL AND WhatId IN :idsCasosSet ORDER BY CreatedDate DESC LIMIT 1]){
                if(!String.isBlank(oTask.CC_Tipo_Cierre__c)){
                    String tipoCierre = oTask.CC_Tipo_Cierre__c; 
                	tipoCierre = tipoCierre.toLowerCase();
                    
                	if(tipoCierre.contains('llamada finalizada')){
                    	idsLlamadas.add(oTask.CC_Llamada_Id__c);
                		tareas.add(oTask);
                	}           
                }                     
        }

        // Buscamos las llamadas y validamos que tengan el Servicio Genesys Informado
        List<Id> idsLlamadasLimpiar = new List<Id> ();		
        if(idsLlamadas.size() > 0){
            for(CC_Llamada__c llamada : [SELECT Id, CC_Servicio_Genesys__r.CC_Codigo__c FROM CC_Llamada__c WHERE Id IN :idsLlamadas]){
                if(!String.isBlank(llamada.CC_Servicio_Genesys__r.CC_Codigo__c) && llamada.CC_Servicio_Genesys__r.CC_Codigo__c == 'IMAGIN_LEADS'){
                    idsLlamadasLimpiar.add(llamada.Id);
                }
        	}
        }
        
        Set<Id> idsCasosBlanquear = new Set<Id> ();
        if(idsLlamadasLimpiar.size() > 0){            
            // Saber que caso se tienen que blanquear
            for(Integer i = 0; i < tareas.size(); i++){
                for(Integer x = 0; x < idsLlamadasLimpiar.size(); x++){
                    if(tareas[i].CC_Llamada_Id__c == idsLlamadasLimpiar[x]){
                        idsCasosBlanquear.add(tareas[i].WhatId);
                    }
                }
            }
        }
        
        if (idsCasosBlanquear.size() > 0) {
        	borrarDatosFuture(idsCasosBlanquear);
        }
        
    }
    
    public static void borrarDatosFuture(Set<Id> idsCasos){  
        Set<Id> contactosId = new Set<Id> ();
        Set<Id> accountsId = new Set<Id> ();
        List<Id> listAccountPA = new List<Id> ();

        // Actualizar casos
       	List<Case> casos = [SELECT ContactId, AccountId, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id IN : idsCasos];
       	for(Case caso : casos){
            if(!String.isBlank(caso.ContactId)){
                contactosId.add(caso.ContactId);
            }
            if(!String.isBlank(caso.AccountId)){
                accountsId.add(caso.AccountId);
            }
            caso.CC_Detalles_Consulta__c = 'Datos protegidos por GDPR';
            caso.CC_Detalles_Solucion__c = 'Datos protegidos por GDPR';
       	}
    	update casos;
        
        // Blanquear accounts
        List<Account> accounts = [SELECT RecordTypeId, CC_Numero_Documento__c, CC_Email__c, Name, FirstName, LastName, CC_NumPerso__c, Phone, BillingAddress, BillingStreet, BillingPostalCode, BillingCity, BillingState,  BillingCountry FROM Account WHERE Id IN : accountsId];
        if(accounts.size() > 0){
            Id recordTypeIdCentro = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Id recordTypeIdCliente = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Id recordTypeIdGenerico = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();
            Id recordTypeIdPersonAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Id recordTypeIdPersonAccountPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
             
           	List<Account> AccUpdate = new List<Account>();
            for(Account account : accounts){
                if(String.isBlank(account.CC_NumPerso__c)){
                    if(account.RecordTypeId == recordTypeIdCliente || account.RecordTypeId == recordTypeIdGenerico){
                        account.CC_NumPerso__c = '';
                        account.Name = 'Imagin Lead';
                        account.CC_Email__c = '';
                        account.Phone = '';	
                    } else if (account.RecordTypeId == recordTypeIdPersonAccount || account.RecordTypeId == recordTypeIdPersonAccountPA){
                        listAccountPA.add(account.Id);                   
                    }                 
                    account.BillingStreet  = '';
                    account.BillingPostalCode  = '';
                    account.BillingCity = '';
                    account.BillingState = '';
                    account.BillingCountry = '';
                    account.CC_Numero_Documento__c = '';
                    AccUpdate.add(account);
                }
            }
                
            //Quitar de la lista els accounts de PA
            for(Integer i = 0; i < accounts.size(); i++) {
                for(Integer x = 0; x < listAccountPA.size(); x++){
                    if(accounts.size() > 0){
                        if(accounts[i].Id == listAccountPA[x]) {
                            accounts.remove(i);
                        }
                    }
                }
            }
            if (AccUpdate.size()>0) {
                Database.update(AccUpdate, false);
            }
            //update accounts;
        }
              
        // Blanquear contactos
        List<Contact> contactos = [SELECT RecordType.Name, CC_FechaNac__c, CC_NumPerso__c, CC_Sexo__c, Email, FirstName, LastName, Phone, CC_Numero_Documento__c FROM Contact WHERE Id IN : contactosId];
        List<Contact> ContUpd = new List<Contact>();
        if(contactos.size() > 0){            
            for(Contact contacto : contactos){
                if(String.isBlank(contacto.CC_NumPerso__c)){
                    contacto.FirstName = '';
                    contacto.LastName = 'Imagin Lead';
                    contacto.CC_FechaNac__c = null;
                    contacto.CC_NumPerso__c = '';
                    contacto.Phone = '';		
                    contacto.Email= '';
                    contacto.CC_Sexo__c = null;
                    contacto.CC_Numero_Documento__c = '';
                    ContUpd.add(contacto);
                }
            }
            if (ContUpd.size()>0) {
                Database.update(ContUpd, false);
            }
            //update contactos;
        }
        
        // Blanquear accounts PA
        List<Account> accountsPA = [SELECT CC_NumPerso__c, CC_NumPerso__pc, AV_NumPerso__c, BillingAddress, CC_Numero_Documento__c, CC_Numero_Documento__pc FROM Account WHERE Id IN : listAccountPA];
        List<Account> PAUpdate = new List<Account>();
        if(accountsPA.size() > 0){            
            for(Account accountPA : accountsPA){
                if(String.isBlank(accountPA.CC_NumPerso__c) || String.isBlank(accountPA.CC_NumPerso__pc)){
                    accountPA.CC_NumPerso__c = '';
                    accountPA.CC_Numero_Documento__pc = '';
                    accountPA.CC_Numero_Documento__c = '';
                    accountPA.BillingStreet  = '';
                    accountPA.BillingPostalCode  = '';
                    accountPA.BillingCity = '';
                    accountPA.BillingState = '';
                    accountPA.BillingCountry = '';
                    PAUpdate.add(accountPA);
                }                 		                
            }
            if (PAUpdate.size()>0) {
                Database.update(PAUpdate, false);
            }
            //update accountsPA;
        }
        
    }
    
}