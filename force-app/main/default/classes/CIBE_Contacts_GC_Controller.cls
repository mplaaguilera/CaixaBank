public without sharing class CIBE_Contacts_GC_Controller {
	// Recuperar los contactos de las cuentas
    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getContactsGroup(String accId, Integer offSet){
        //offSet = offSet+10;
        List<ContactWrapper> wrapperList = new List<ContactWrapper>();
        ContactWrapper contWrapper;
        Set<String> accountIds = new Set<String>();
        List<FinServ__AccountAccountRelation__c> accRelList = [SELECT id, FinServ__Account__c, FinServ__Account__r.name, FinServ__RelatedAccount__c,
                                                              FinServ__RelatedAccount__r.name, FinServ__Role__r.name, CIBE_Matriz__c 
                                                              FROM FinServ__AccountAccountRelation__c
                                                              WHERE FinServ__Role__r.name = 'Parent' AND FinServ__Account__c = :accId
                                                              AND Recordtype.developername = 'CIBE_GrupoComercial' AND AV_ToDelete__c = false
                                                              ORDER BY Finserv__Account__c];
        
        
        
        for(FinServ__AccountAccountRelation__c acc: accRelList){
            accountIds.add(acc.FinServ__RelatedAccount__c);
        }
        
        List<Recordtype> contactRTs = new List<Recordtype>{AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT),
            												AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_APODERADO_RT)};

        List<AggregateResult> accContactList = [SELECT ContactId 
                                                       FROM AccountContactRelation 
                                                       WHERE AccountId IN :accountIds AND Contact.RecordtypeId IN :contactRTs
                                                       GROUP BY ContactId
                                               		   LIMIT 10 OFFSET :offSet];
        Set<String> contactIds = new Set<String>();
        for(AggregateResult accContact:accContactList){
            contactIds.add((String) accContact.get('contactId'));
        }
        
        List<Contact> contactList = [SELECT Id, Salutation, FirstName, LastName, accountId, account.name, 
                                                       CIBE_Cargo__c, email, phone, CC_Idioma__c, CIBE_Confidencial__c,
                                                       CIBE_ContactoinfoComercial__c, Description, Recordtype.developername
                                                       FROM Contact where Id IN :contactIds];
        
        for(Contact cont: contactList){
             wrapperList.add(fillContactWrapper(cont));
        }
        return wrapperList;
    }
    
    
    // Añadir contactos al grupo y  los participantes
	@AuraEnabled
    public static void createGroupAndContact(String accId, List<Contact> contacto){
        Id currentUser = UserInfo.getUserId();
        List<FinServ__AccountAccountRelation__c> accRelList = [SELECT id, FinServ__Account__c, FinServ__Account__r.name, FinServ__RelatedAccount__c,
                                                              FinServ__RelatedAccount__r.name, FinServ__Role__r.name, CIBE_Matriz__c, FinServ__RelatedAccount__r.AV_Confidencial__c,
                                                               FinServ__RelatedAccount__r.OwnerId
                                                              FROM FinServ__AccountAccountRelation__c
                                                              WHERE FinServ__Role__r.name = 'Parent' AND FinServ__Account__c = :accId
                                                              AND FinServ__RelatedAccount__r.Recordtype.developername != 'CC_ClientePA'
                                                              AND Recordtype.developername = 'CIBE_GrupoComercial' AND AV_ToDelete__c = false
                                                              AND FinServ__RelatedAccount__c != :contacto[0].AccountId];
        Set<String> accountIds = new Set<String>();

        if(Contact.SObjectType.getDescribe().isCreateable()){
            if(!contacto.isEmpty() && contacto != null){
                //Database.insert(contacto, false);
				insert contacto;

                AccountContactRelation accountContactAux = new AccountContactRelation();
                List<AccountContactRelation> accContListToInsert = new List<AccountContactRelation>();
                
                for(FinServ__AccountAccountRelation__c accAcc: accRelList){
                    accountIds.add(accAcc.FinServ__RelatedAccount__c);
                }
                
                List<AccountTeamMember> accTeamList = [SELECT ID, UserId, accountId FROM AccountTeamMember WHERE AccountId IN :accountIds];
                Map<String, Set<String>> accTeamMap = new Map<String, Set<String>>();
                for(AccountTeamMember accTeam: accTeamList){
                    if(!accTeamMap.containsKey(accTeam.accountId)){
                        accTeamMap.put(accTeam.accountId, new Set<String>{accTeam.userId});
                    }
                    else if(accTeamMap.containsKey(accTeam.accountId)){
                        accTeamMap.get(accTeam.accountId).add(accTeam.userId);
                    }
                }
                
                
                for(FinServ__AccountAccountRelation__c accAcc: accRelList){
                    if(accAcc.FinServ__RelatedAccount__r.ownerId == currentUser || accTeamMap.containsKey(accAcc.FinServ__RelatedAccount__c) &&
                       accTeamMap.get(accAcc.FinServ__RelatedAccount__c).contains(currentUser) || accAcc.FinServ__RelatedAccount__r.AV_Confidencial__c == false){
                        accountContactAux = new AccountContactRelation(accountId = accAcc.FinServ__RelatedAccount__c, contactId = contacto[0].Id);
                        accContListToInsert.add(accountContactAux);
                    }
                }
                if(!accContListToInsert.isEmpty() && !Test.isRunningTest()){
                    insert accContListToInsert;
                }
                            
            }
        }
    }
    
    // Añadir contactos al grupo y  los participantes
	@AuraEnabled(cacheable=false)
    public static void createOnlyGroup(String accId, String contactId){
        Id currentUser = UserInfo.getUserId();
        Set<String> accountIds = new Set<String>();

        Set<String> clientes = new Set<String>();
        Set<String> contactoExistente  = new Set<String>();
        
        List<FinServ__AccountAccountRelation__c> accRelList = [SELECT id, FinServ__Account__c, FinServ__Account__r.name, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.OwnerId, FinServ__RelatedAccount__r.AV_Confidencial__c,
                                                              FinServ__RelatedAccount__r.name, FinServ__Role__r.name, CIBE_Matriz__c 
                                                              FROM FinServ__AccountAccountRelation__c
                                                              WHERE FinServ__Role__r.name = 'Parent' AND FinServ__Account__c = :accId
                                                              AND Recordtype.developername = 'CIBE_GrupoComercial' AND AV_ToDelete__c = false];
        
        for(FinServ__AccountAccountRelation__c accAcc: accRelList){
                    accountIds.add(accAcc.FinServ__RelatedAccount__c);
        }

                                                            
        if(contactId != null){
            AccountContactRelation accountContactAux = new AccountContactRelation();
            List<AccountContactRelation> accContListToInsert = new List<AccountContactRelation>();
            for(FinServ__AccountAccountRelation__c accAcc: accRelList){
                clientes.add(accAcc.FinServ__RelatedAccount__c);
            }
            
            List<AccountTeamMember> accTeamList = [SELECT ID, UserId, accountId FROM AccountTeamMember WHERE AccountId IN :clientes];
            Map<String, Set<String>> accTeamMap = new Map<String, Set<String>>();
            for(AccountTeamMember accTeam: accTeamList){
                if(!accTeamMap.containsKey(accTeam.accountId)){
                    accTeamMap.put(accTeam.accountId, new Set<String>{accTeam.userId});
                }
                else if(accTeamMap.containsKey(accTeam.accountId)){
                    accTeamMap.get(accTeam.accountId).add(accTeam.userId);
                }
            }

            List<AccountContactRelation> contactos = [SELECT Id, AccountId, Contact.FirstName, Contact.LastName, Contact.CIBE_Cargo__c, toLabel(Contact.CC_Idioma__c), Contact.Email, Contact.Phone, Contact.Fax, Contact.Description, 
            Contact.CIBE_Confidencial__c, Contact.CIBE_ContactoInfoComercial__c, Contact.RecordType.DeveloperName, Contact.CIBE_Carrec__c, Contact.CIBE_FechaVencimiento__c 
            FROM AccountContactRelation WHERE AccountId IN :clientes AND ContactId = :contactId AND Contact.RecordType.DeveloperName IN  ('CIBE_ContactoComercial','CIBE_Apoderado')];

            if(!contactos.isEmpty()){
                for (AccountContactRelation c : contactos) {
                    contactoExistente.add(c.AccountId);
                }

               
                
                
                for(FinServ__AccountAccountRelation__c accAcc: accRelList){
					if(!contactoExistente.contains(accAcc.FinServ__RelatedAccount__c) && (accAcc.FinServ__RelatedAccount__r.ownerId == currentUser || accTeamMap.containsKey(accAcc.FinServ__RelatedAccount__c) &&
                       accTeamMap.get(accAcc.FinServ__RelatedAccount__c).contains(currentUser) || accAcc.FinServ__RelatedAccount__r.AV_Confidencial__c == false)){
                           accountContactAux = new AccountContactRelation(accountId = accAcc.FinServ__RelatedAccount__c, contactId = contactId);
                           accContListToInsert.add(accountContactAux);
                       }
            	}

            }else{

                for(FinServ__AccountAccountRelation__c accAcc: accRelList){
                    if(accAcc.FinServ__RelatedAccount__r.ownerId == currentUser || accTeamMap.containsKey(accAcc.FinServ__RelatedAccount__c) &&
                       accTeamMap.get(accAcc.FinServ__RelatedAccount__c).contains(currentUser) || accAcc.FinServ__RelatedAccount__r.AV_Confidencial__c == false){
                            accountContactAux = new AccountContactRelation(accountId = accAcc.FinServ__RelatedAccount__c, contactId = contactId);
                            accContListToInsert.add(accountContactAux);
                       }
                }
            }

            if(!accContListToInsert.isEmpty()){
                insert accContListToInsert;
            }
                    
        }
    }
    
    //Metodo para devolver el cibe_matriz para crear el contacto
    @AuraEnabled(cacheable=true)
    public static String getMatriz(String accId){
        String matriz = '';
        List<FinServ__AccountAccountRelation__c> accRelList = [SELECT id, FinServ__Account__c, FinServ__Account__r.name, FinServ__RelatedAccount__c,
                                                              FinServ__RelatedAccount__r.name, FinServ__Role__r.name, CIBE_Matriz__c 
                                                              FROM FinServ__AccountAccountRelation__c
                                                              WHERE FinServ__Role__r.name = 'Parent' AND FinServ__Account__c = :accId
                                                              AND FinServ__RelatedAccount__r.Recordtype.developername != 'CC_ClientePA'
                                                              AND Recordtype.developername = 'CIBE_GrupoComercial' AND AV_ToDelete__c = false];
        for(FinServ__AccountAccountRelation__c acc: accRelList){
            matriz = matriz != '' ? matriz : acc.FinServ__RelatedAccount__c;
            if(acc.CIBE_Matriz__c){
                matriz = acc.FinServ__RelatedAccount__c;
                break;
            }
        }
        
        return matriz;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean showAddMemberButton(String recordId){
        Set<String> clienteId =  new Set<String>();

        List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.Id.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__Account__c.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__RelatedAccount__c.isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.CIBE_Matriz__c.isAccessible()) {
            relations = [SELECT Id,
                                FinServ__Account__c,
                                FinServ__Account__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__c,
                                FinServ__RelatedAccount__r.Id,
                                FinServ__RelatedAccount__r.RecordType.DeveloperName,
                                FinServ__RelatedAccount__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__r.Name,
                                FinServ__RelatedAccount__r.AV_Interlocutor__c,
                                FinServ__RelatedAccount__r.AV_PctRar__c,
                                FinServ__RelatedAccount__r.CIBE_Facturacion__c,
                                FinServ__RelatedAccount__r.AV_AhorroEInversion__c,
                                FinServ__RelatedAccount__r.AV_Rentabilidad__c,
                                FinServ__RelatedAccount__r.CIBE_RARGrupo__c,
                                FinServ__RelatedAccount__r.CIBE_LEXFechaFinVigencia__c,
                                FinServ__RelatedAccount__r.CIBE_LEXAprobado__c,
                                FinServ__RelatedAccount__r.AV_Financiacion__c,
                                CIBE_Matriz__c
                        FROM FinServ__AccountAccountRelation__c 
                        WHERE   RecordType.DeveloperName = 'CIBE_GrupoComercial' 
                                AND FinServ__Role__r.Name = 'Parent'
                                AND FinServ__RelatedAccount__c != null
                         		AND FinServ__RelatedAccount__r.Recordtype.developername != 'CC_ClientePA'
                                AND FinServ__Account__c = :recordId
                                AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoComercial'
                                AND AV_ToDelete__c = false];
        }
        if(!relations.isEmpty()){
            for (FinServ__AccountAccountRelation__c clientes : relations) {
                clienteId.add(clientes.FinServ__RelatedAccount__c);
            }
        }

       

         List<AccountTeamMember> teamMembers = new  List<AccountTeamMember>();
        if(AccountTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
            && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()) {
                teamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId IN :clienteId AND UserId = :UserInfo.getUserId()];
        } else {
            throw new IllegalArgumentException('showAddMemberButton - El usuario no tiene permisos para acceder a los miembros.');
        }

        return !teamMembers.isEmpty();
    }
    
    @AuraEnabled
    public static void deleteContactFromAccount(String recordId, String contactId){
        List<AccountContactRelation> accContList = [SELECT Id, accountId, isDirect, contactId 
                                                    FROM AccountContactRelation
                                                    WHERE ContactId = :contactId AND AccountId = :recordId];

		List<AccountContactRelation> accContListOfAccount = [SELECT Id, accountId, isDirect, contactId 
                                                    FROM AccountContactRelation
                                                    WHERE AccountId = :recordId];
        
        List<AccountContactRelation> accContListOfContact = [SELECT Id, accountId, isDirect, contactId 
                                                    FROM AccountContactRelation
                                                    WHERE contactId = :contactId];
        
        List<AccountContactRelation> accContactListToDelete = new List<AccountContactRelation>();
        Contact contactToUpdate = null;
        Boolean updateContact = false;
        if(accContList.size() == 1 && accContList[0].isDirect && accContListOfContact.size() == 1){
           delete new Contact(id = contactId);
        }
        else if(!accContListOfAccount.isEmpty()){
            for(AccountContactRelation accCont: accContListOfContact){
                if(contactToUpdate == null && accCont.accountId != recordId && !accCont.isDirect){
                    contactToUpdate = new Contact(Id = contactId, accountId = accCont.accountId);
                }
                if(!accCont.isDirect && accCont.contactId == contactId && accCont.accountId == recordId){
                    accContactListToDelete.add(new AccountContactRelation(Id = accCont.Id));
                }else if(accCont.isDirect && accCont.contactId == contactId && accCont.accountId == recordId){
                    accContactListToDelete.add(new AccountContactRelation(Id = accCont.Id));
                    updateContact = true;
                }
            }
            
            if(updateContact){
                update contactToUpdate;
            }
            
            //accContactListToDelete.add(new AccountContactRelation(Id = accContList[0].Id));
            
            if(!accContactListToDelete.isEmpty()){
                delete accContactListToDelete;
            }
        }
    }
    
    
    @AuraEnabled
    public static void deleteContactFromGroup(String recordId, String contactId){
        
        List<FinServ__AccountAccountRelation__c> accAccList = [SELECT Id, FinServ__RelatedAccount__c, CIBE_Matriz__c, FinServ__Account__c 
                                                               FROM FinServ__AccountAccountRelation__c 
                                                               WHERE  FinServ__RelatedAccount__c IN (SELECT accountId FROM AccountContactRelation Where contactId =: contactId)
                                                               AND Recordtype.developername = 'CIBE_GrupoComercial'];
       
        Set<String> accountIds = new Set<String>();
        String otherAccGroup = '';
        for(FinServ__AccountAccountRelation__c accAcc : accAccList){
            if(accAcc.FinServ__Account__c == recordId){
            	accountIds.add(accAcc.FinServ__RelatedAccount__c);
            }
            else{
                otherAccGroup = accAcc.FinServ__Account__c;
            }
        }
        
         List<AccountContactRelation> accContList = [SELECT Id, accountId, contactId, isDirect 
                                                    FROM AccountContactRelation
                                                    WHERE AccountId IN :accountIds and ContactId =:contactId];
        
        
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactsToDelete = new List<Contact>();
        List<AccountContactRelation> accContListToDelete = new List<AccountContactRelation>();
        for(AccountContactRelation accCon : accContList){
            if(accCon.isDirect && otherAccGroup != ''){
                
                contacts.add(new Contact(Id = accCon.ContactId, accountId = getMatriz(otherAccGroup)));
                accContListToDelete.add(accCon);
            }
            else if(accCon.isDirect && otherAccGroup == ''){
                contactsToDelete.add(new Contact(Id = accCon.ContactId));
            }
            else{
                accContListToDelete.add(accCon);
            }
        }
        
        if(!contacts.isEmpty()){
            update contacts;
        }
                                     
        if(!contactsToDelete.isEmpty()){
            delete contactsToDelete; 
        }
        
        if(!accContList.isEmpty() && contactsToDelete.isEmpty()){	
        	delete accContListToDelete;
        }
            
        /*List<AccountContactRelation> accContListAfterDelete = [SELECT Id, accountId 
                                                    FROM AccountContactRelation
                                                    WHERE ContactId = :contactId];
        
        if(accContListAfterDelete.isEmpty()){
            delete new Contact(Id = contactId);
        }*/
        
        
    }
    
    
/**
	public static Contact fillContactWithContactWrapper(ContactWrapper wrap){
        Contact cont = new Contact();
        cont.Salutation = wrap.salutation;
        cont.FirstName = wrap.firstName;
        cont.lastName = wrap.lastname;
        cont.accountId = wrap.accountId ;
        cont.accountId = wrap.accountName;
        cont.CIBE_Cargo__c = wrap.position;
        cont.Email = wrap.email;
        cont.Phone = wrap.phone;
        cont.CC_Idioma__c = wrap.language;
        cont.CIBE_Confidencial__c = wrap.confidential;
        cont.CIBE_ContactoInfoComercial__c = wrap.accept;      
        cont.Description = wrap.description;
        return cont;
    }
*/
    
    public static ContactWrapper fillContactWrapper(Contact cont){
        ContactWrapper wrap = new ContactWrapper();
        wrap.id			= cont.id;
        wrap.salutation = cont.Salutation;
        wrap.firstName	= cont.FirstName;
        wrap.lastname	= cont.lastName;
        wrap.name 		= cont.FirstName == null ? cont.lastName : cont.FirstName  + ' ' + cont.lastName;
        wrap.accountId	= cont.accountId;
        wrap.accountName	= cont.accountId;
        wrap.position	= cont.CIBE_Cargo__c;
        wrap.email		= cont.Email;
        wrap.phone		= cont.Phone;
        wrap.language	= cont.CC_Idioma__c;
        wrap.confidential = cont.CIBE_Confidencial__c;
        wrap.accept		= cont.CIBE_ContactoInfoComercial__c;
        wrap.description = cont.Description;
        wrap.apoderado   = cont.Recordtype.Developername == CIBE_AppConstants.CONTACT_APODERADO_RT;
        wrap.showContactRecord = '/' + cont.id;
        return wrap;
    }
    
    public class ContactWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String salutation;
		@AuraEnabled public String firstName;
		@AuraEnabled public String lastName;
        @AuraEnabled public String name;
		@AuraEnabled public String accountId;
        @AuraEnabled public String accountName;
		@AuraEnabled public String position;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String language;
        @AuraEnabled public Boolean confidential;
        @AuraEnabled public Boolean accept;
        @AuraEnabled public String description;
        @AuraEnabled public Boolean apoderado;
        @AuraEnabled public String showContactRecord;
	}
}