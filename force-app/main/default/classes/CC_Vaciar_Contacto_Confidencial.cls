public with sharing class CC_Vaciar_Contacto_Confidencial {        
    @InvocableMethod
    public static void borrarDatos(List<Id> idsContactos){
        Set<Id> idsContactosSet = new Set<Id> (idsContactos);                       
        
        if (idsContactosSet.size() > 0) {
            borrarDatosFuture(idsContactosSet);
        }            
    }
    
    public static void borrarDatosFuture(Set<Id> idsContactos){  
        // Blanquear contactos
        List<Contact> listaContactos = [SELECT RecordType.Name, CC_FechaNac__c, CC_Sexo__c, Email, FirstName, LastName, AccountId, Birthdate,
        CC_CuentaFacebook__c, CC_CuentaTwitter__c, CC_EmpleadoGestorId__c, CC_Identificador_CBKNow__c, CC_Idioma__c, CC_OficinaGestoraId__c, CC_Segmento__c, CC_SubSegmento__c,
        AV_DescFuncion__c, MailingCity, MailingCountry, MailingGeocodeAccuracy, MailingLatitude, MailingLongitude, MailingPostalCode, MailingState, MailingStreet, Salutation                                        
        FROM Contact WHERE Id IN : idsContactos];
        Set<Id> setIdCuentas = new Set<Id>();
        
        if(listaContactos.size() == 0){
            listaContactos = [SELECT RecordType.Name, CC_FechaNac__c, CC_Sexo__c, Email, FirstName, LastName, AccountId, Birthdate,
            CC_CuentaFacebook__c, CC_CuentaTwitter__c, CC_EmpleadoGestorId__c, CC_Identificador_CBKNow__c, CC_Idioma__c, CC_OficinaGestoraId__c, CC_Segmento__c, CC_SubSegmento__c,
            AV_DescFuncion__c, MailingCity, MailingCountry, MailingGeocodeAccuracy, MailingLatitude, MailingLongitude, MailingPostalCode, MailingState, MailingStreet, Salutation                                        
            FROM Contact WHERE AccountId IN :idsContactos];          
        }
        
        // Blanquear contacto
        List<Contact> ContUpd = new List<Contact>();
        if(listaContactos.size() > 0){            
            for(Contact contacto : listaContactos){
                contacto.FirstName = '';
                contacto.LastName = 'CONFIDENCIAL';
                contacto.CC_FechaNac__c = null;
                contacto.Email= '';
                contacto.CC_Idioma__c = null;
                contacto.Fax = null;
                contacto.Birthdate = null;
                contacto.CC_Sexo__c = null;
                contacto.CC_CuentaFacebook__c = null;
                contacto.CC_CuentaTwitter__c = null;
                contacto.CC_EmpleadoGestorId__c = null;
                contacto.CC_Identificador_CBKNow__c = null;
                contacto.CC_Idioma__c = null;
                contacto.CC_OficinaGestoraId__c = null;
                contacto.CC_Segmento__c = null;
                contacto.CC_SubSegmento__c = null;
                contacto.AV_DescFuncion__c = null;
                contacto.MailingCity = null;
                contacto.MailingCountry = null;
                contacto.MailingGeocodeAccuracy = null;
                contacto.MailingLatitude = null;
                contacto.MailingLongitude = null;
                contacto.MailingPostalCode = null;
                contacto.MailingState = null;
                contacto.MailingStreet = null;
                contacto.Salutation = null;         
                contacto.CC_FechaNac__c = null;                
                contacto.CC_FechaDefuncion__c = null;                
                
                ContUpd.add(contacto);
                
                // Añadir id de la cuenta al Set setIdCuentas          
                setIdCuentas.add(contacto.AccountId);
            }
            if (ContUpd.size()>0) {
                Database.update(ContUpd, false);
            }
        }
        
        
        
        // Blanquear accounts
        List<Id> listAccountPA = new List<Id> ();
        List<Account> accounts = [SELECT RecordTypeId, CC_Email__c, Name, FirstName, LastName, BillingAddress, BillingStreet, BillingPostalCode, BillingCity, BillingState,  BillingCountry                                  
        FROM Account WHERE Id IN : setIdCuentas];
        if(accounts.size() > 0){
            Id recordTypeIdCliente = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Id recordTypeIdPersonAccountPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
            
            List<Account> AccUpdate = new List<Account>();
            for(Account account : accounts){
                if(account.RecordTypeId == recordTypeIdCliente){
                    account.Name = 'CONFIDENCIAL';
                    account.CC_Email__c = '';
                    account.CC_Segmento__c = null;
                    account.CC_SubSegmento__c = null;
                    account.CC_Grupo_Colaborador__c = null;
                    account.CC_TipoPersona__c = null;
                    account.CC_TipoDocumento__c = null;
                    account.CC_IncapacitadoLegal__c = false;
                    account.CC_MenorEmancipado__c = false;
                    account.CC_Gestor_InTouch__c = null;
                    account.Type = null;
                    account.CC_Centro_Gestor_InTouch__c = null;
                    account.CC_Centro_Integrador__c = null;                      
                    account.CC_Senal_Comercial_Imaginbank__c = false;
                    account.CC_OficinaGestoraId__c = null;
                    account.CC_Numero_Oficina__c = null;
                    account.CC_EmpleadoGestorId__c = null;
                    
                } else if (account.RecordTypeId == recordTypeIdPersonAccountPA){
                    listAccountPA.add(account.Id);                   
                }                 
                account.BillingStreet  = '';
                account.BillingPostalCode  = '';
                account.BillingCity = '';
                account.BillingState = '';
                account.BillingCountry = '';
                account.ShippingCity  = '';
                account.ShippingCountry  = '';
                account.ShippingGeocodeAccuracy = '';
                account.ShippingLatitude = null;
                account.ShippingLongitude = null;
                account.ShippingPostalCode = '';
                account.ShippingState = '';
                account.ShippingStreet = '';
                
                AccUpdate.add(account);
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
        }
        
        
        
        // Blanquear accounts PA
        List<Account> accountsPA = [SELECT BillingAddress FROM Account WHERE Id IN : listAccountPA];
        List<Account> PAUpdate = new List<Account>();
        if(accountsPA.size() > 0){            
            for(Account accountPA : accountsPA){
                accountPA.FirstName = '';
                accountPA.LastName = 'CONFIDENCIAL';
                accountPA.Fax = null;
                accountPA.CC_FechaDefuncion__pc = null;
                accountPA.CC_FechaNac__pc = null;
                accountPA.CC_MenorEmancipado__c = false;
                accountPA.BillingStreet  = '';
                accountPA.BillingPostalCode  = '';
                accountPA.BillingCity = '';
                accountPA.BillingState = '';
                accountPA.BillingCountry = '';
                accountPA.ShippingCity = null;
                accountPA.ShippingGeocodeAccuracy  = null;
                accountPA.ShippingLatitude = null;
                accountPA.ShippingLongitude = null;
                accountPA.ShippingPostalCode = null;
                accountPA.ShippingState = null;
                accountPA.ShippingStreet = null;
                accountPA.AV_DescFuncion__pc = null;
                accountPA.CC_CargoRepresentante__pc = null;
                accountPA.CC_Centro_Gestor_InTouch__c = null;
                accountPA.CC_Centro_Integrador__c = null;
                accountPA.CC_Email__c = null;
                accountPA.CC_Sexo__pc = null;
                accountPA.CC_Idioma__pc = null;
                accountPA.CC_Idioma_Oficina__c = null;
                accountPA.CC_Segmento__c = null;
                accountPA.CC_Segmento__pc = null;
                accountPA.CC_SubSegmento__c = null;
                accountPA.CC_SubSegmento__pc = null;
                accountPA.CC_Gestor_InTouch__c = null;
                accountPA.CC_OficinaGestoraId__c = null;
                accountPA.CC_OficinaGestoraId__pc = null;
                accountPA.CC_EmpleadoGestorId__c = null;
                accountPA.CC_EmpleadoGestorId__pc = null;
                accountPA.CC_Name_ComAutonoma__c = null;
                accountPA.CC_CuentaFacebook__pc = null;
                accountPA.CC_CuentaTwitter__pc = null;
                PAUpdate.add(accountPA);
            }
            if (PAUpdate.size()>0) {
                Database.update(PAUpdate, false);
            }
        } 
    }
    
    public static void crearClienteConfidencial(Set<Id> idsContactos){  
        // Blanquear contactos
        List<Contact> listaContactos = [SELECT RecordTypeId, RecordType.Name, CC_NumPerso__c, CC_FechaNac__c, CC_Sexo__c, Email, FirstName, LastName, AccountId, Birthdate,
        CC_CuentaFacebook__c, CC_CuentaTwitter__c, CC_EmpleadoGestorId__c, CC_Identificador_CBKNow__c, CC_Idioma__c, CC_OficinaGestoraId__c, CC_Segmento__c, CC_SubSegmento__c,
        AV_DescFuncion__c, MailingCity, MailingCountry, MailingGeocodeAccuracy, MailingLatitude, MailingLongitude, MailingPostalCode, MailingState, MailingStreet, Salutation                                        
        FROM Contact WHERE Id IN : idsContactos];
        Set<Id> setIdCuentas = new Set<Id>();
        
        if(listaContactos.size() == 0){
            listaContactos = [SELECT RecordTypeId, RecordType.Name,CC_Numero_Documento__c, CC_NumPerso__c, CC_FechaNac__c, CC_Sexo__c, Email, FirstName, LastName, AccountId, Birthdate,
            CC_CuentaFacebook__c, CC_CuentaTwitter__c, CC_EmpleadoGestorId__c, CC_Identificador_CBKNow__c, CC_Idioma__c, CC_OficinaGestoraId__c, CC_Segmento__c, CC_SubSegmento__c,
            AV_DescFuncion__c, MailingCity, MailingCountry, MailingGeocodeAccuracy, MailingLatitude, MailingLongitude, MailingPostalCode, MailingState, MailingStreet, Salutation                                        
            FROM Contact WHERE AccountId IN :idsContactos];          
        }
        
        // Blanquear contacto
        List<Contact> ContUpd = new List<Contact>();
        List<Contact> ContInsert = new List<Contact>();
        if(listaContactos.size() > 0){            
            for(Contact contacto : listaContactos){
                
                Contact contactoNuevo = new Contact();
                contactoNuevo.LastName = 'CONFIDENCIAL';
                contactoNuevo.CC_NumPerso__c = contacto.CC_NumPerso__c;
                contactoNuevo.CC_Numero_Documento__c = contacto.CC_Numero_Documento__c;
                contactoNuevo.CC_Confidencial__c = true;
                contactoNuevo.RecordTypeId = contacto.RecordTypeId;
                contacto.CC_NumPerso__c = null;
                
                ContUpd.add(contacto);
                
                ContInsert.add(contactoNuevo);
                // Añadir id de la cuenta al Set setIdCuentas          
                setIdCuentas.add(contacto.AccountId);
            }
            if (ContUpd.size()>0) {
                Database.update(ContUpd, false);
            }
            
            if (ContInsert.size()>0) {
                Database.insert(ContInsert, false);
            }
            
        }
        
        
        
        // Blanquear accounts
        List<Id> listAccountPA = new List<Id> ();
        List<Account> accounts = [SELECT RecordTypeId,CC_NumPerso__c,CC_Numero_Documento__c, CC_Email__c, Name, FirstName, LastName, BillingAddress, BillingStreet, BillingPostalCode, BillingCity, BillingState,  BillingCountry                                  
        FROM Account WHERE Id IN : setIdCuentas];
        if(accounts.size() > 0){
            Id recordTypeIdCliente = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Id recordTypeIdPersonAccountPA = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
            
            List<Account> AccUpdate = new List<Account>();
            List<Account> AccInsert = new List<Account>();
            for(Account account : accounts){
                if(account.RecordTypeId == recordTypeIdCliente){
                    Account cuentaNueva = new Account();
                    cuentaNueva.Name = 'CONFIDENCIAL';
                    cuentaNueva.CC_NumPerso__c = account.CC_NumPerso__c;
                    cuentaNueva.CC_Numero_Documento__c = account.CC_Numero_Documento__c;
                    cuentaNueva.CC_Confidencial__c = true;
                    cuentaNueva.RecordTypeId = account.RecordTypeId;
                    account.CC_NumPerso__c = null;
                    AccInsert.add(cuentaNueva);
                    
                } else if (account.RecordTypeId == recordTypeIdPersonAccountPA){
                    listAccountPA.add(account.Id);                   
                }
                
                AccUpdate.add(account);
                
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
            if (AccInsert.size()>0) {
                Database.insert(AccInsert, false);
            }
        }
        
        
        
        // Blanquear accounts PA
        List<Account> accountsPA = [SELECT RecordTypeId, BillingAddress, CC_NumPerso__c, CC_NumPerso__pc, CC_Numero_Documento__pc, CC_Numero_Documento__c FROM Account WHERE Id IN : listAccountPA];
        List<Account> PAUpdate = new List<Account>();
        List<Account> PAUInsert = new List<Account>();
        if(accountsPA.size() > 0){            
            for(Account accountPA : accountsPA){
                Account cuentaNuevaPA = new Account();
                cuentaNuevaPA.LastName = 'CONFIDENCIAL';
                cuentaNuevaPA.CC_NumPerso__c = accountPA.CC_NumPerso__c;
                cuentaNuevaPA.CC_NumPerso__pc = accountPA.CC_NumPerso__pc;
                cuentaNuevaPA.CC_Numero_Documento__c = accountPA.CC_Numero_Documento__c;
                cuentaNuevaPA.CC_Numero_Documento__pc = accountPA.CC_Numero_Documento__pc;
                cuentaNuevaPA.CC_Confidencial__c = true;
                cuentaNuevaPA.RecordTypeId = accountPA.RecordTypeId;
                accountPA.CC_NumPerso__c = null;
                accountPA.CC_NumPerso__pc = null;
                PAUInsert.add(cuentaNuevaPA);
            
                PAUpdate.add(accountPA);
            }
            if (PAUpdate.size()>0) {
                Database.update(PAUpdate, false);
            }
            if (PAUInsert.size()>0) {
                Database.insert(PAUInsert, false);
            }
        }
        
        
    }
    
    
    
    
}