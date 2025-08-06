public with sharing class CC_Contact_BI_TRHan extends CC_TriggerHandlerBase { 

    public override void mainEntry(CC_TriggerParameters tp) { 
        process((List<Contact>)tp.newList, (Map<Id, Contact>)tp.newMap);
	}
	
    private void process(List<Contact> listNewObj, Map<Id, Contact> mapNewObj) {

        //Comprobar si el contacto es confidencial
        vaciarContactoConfidencial(listNewObj);

        //Se comprueba si el usuario tiene PS de CAM
        
        if(FeatureManagement.checkPermission('AM_Responsable')){
            evitarDuplicadosCAM(listNewObj, mapNewObj);
        }
        if(FeatureManagement.checkPermission('OS_CP_Responsable')){
            evitarDuplicadosCOPS(listNewObj, mapNewObj);
        }

        
        if (listNewObj.isEmpty()) return;

        Id colaboradorContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        List <String> contactoEmail = new List <String>();
        for (Contact cnt : listNewObj) {
            if (cnt.recordtypeId == colaboradorContactRT){
                contactoEmail.add(cnt.email);
            }
        }
        
        if (contactoEmail.size() == 0) return;

        List <Contact> consulta = [SELECT Email, RecordTypeId FROM Contact WHERE Email IN :contactoEmail AND RecordTypeId = :colaboradorContactRT];
        List <String> consultaEmail = new List <String>();
        for(Contact cto : consulta){
            consultaEmail.add(cto.Email);
        }
        
        //Elimino emails duplicados. El objetivo es obtener una lista de Emails que se repiten
        Set<String> consultaEmailSet = new Set<String>();
		consultaEmailSet.addAll(consultaEmail);
        
        //Ahora busco cuáles de los nuevos contactos tienen alguno de los emails repetidos, y sobre esos, lanzo un error.
        for(Contact cnto : listNewObj) {
            for(String email : consultaEmailSet) {
                if (email == cnto.email) {
                    cnto.addError ('Ya existe un Colaborador con el mismo Email.');
                }
            }
        }

        //Comprobar si el contacto es confidencial
        vaciarContactoConfidencial(listNewObj);
    }

    private static void evitarDuplicadosCAM(List<Contact> newContacts, Map<Id, Contact> mapIdContacts){
        if (newContacts.isEmpty()) return;

        List<Contact> contactosNoEmpleado = new List<Contact>();
        Id empleadoRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id colaboradorRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Id clienteRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Set<Id> idCAM = new Set<Id> {empleadoRT, colaboradorRT, clienteRT};

        for(Contact contactoNoEmpleado : newContacts){
            if(contactoNoEmpleado.RecordTypeId != empleadoRT && String.isNotBlank(contactoNoEmpleado.Email)){
                contactosNoEmpleado.add(contactoNoEmpleado);
            }
        }

        if(contactosNoEmpleado.isEmpty()) return;

        Set<String> emails = new Set<String>();
        

        for(Contact contacto : contactosNoEmpleado){
            emails.add(contacto.Email);
        }
        if (emails.size() == 0) return;

        List <Contact> contactDuplicate = [SELECT Email, RecordTypeId FROM Contact WHERE Email IN :emails AND RecordTypeId IN :idCAM];
        Map<String, List<Id>> mapaEmailRT= new Map<String, List<Id>>();

        if(!contactDuplicate.isEmpty()){
            for(Contact contactoDupl : contactDuplicate){
                if(mapaEmailRT.containsKey(contactoDupl.Email)){
                    mapaEmailRT.get(contactoDupl.Email).add(contactoDupl.RecordTypeId);
                } else {
                    mapaEmailRT.put(contactoDupl.Email, new List<Id> {contactoDupl.RecordTypeId});
                }
            }
        }

        //Ahora busco cuáles de los nuevos contactos tienen alguno de los emails repetidos, y sobre esos, lanzo un error.
        for(Contact allContacts : contactosNoEmpleado){
            if(mapaEmailRT.keySet().contains(allContacts.Email)){
                if(allContacts.RecordTypeId == colaboradorRT && (mapaEmailRT.get(allContacts.Email).contains(empleadoRT) || mapaEmailRT.get(allContacts.Email).contains(colaboradorRT))){
                    allContacts.addError ('Ya existe un Contacto con el mismo Email.');
                } else if (allContacts.RecordTypeId == clienteRT && mapaEmailRT.get(allContacts.Email).contains(clienteRT)){
                    allContacts.addError ('Ya existe un Contacto con el mismo Email.');
                }
                
            }
        }
        
        
    } 
    private static void evitarDuplicadosCOPS(List<Contact> newContacts, Map<Id, Contact> mapIdContacts){
        if (newContacts.isEmpty()) return;

        Id buzonRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId();
        Set<Id> idCAM = new Set<Id> {buzonRT};

        Set<String> emails = new Set<String>();
        

        for(Contact contacto : newContacts){
            if(contacto.RecordTypeId == buzonRT && String.isNotBlank(contacto.Email))
            	emails.add(contacto.Email);
        }
        if (emails.size() == 0) return;

        List <Contact> contactDuplicate = [SELECT Email, RecordTypeId FROM Contact WHERE Email IN :emails AND RecordTypeId IN :idCAM];
        Map<String, List<Id>> mapaEmailRT= new Map<String, List<Id>>();

        if(!contactDuplicate.isEmpty()){
            for(Contact contactoDupl : contactDuplicate){
                if(mapaEmailRT.containsKey(contactoDupl.Email)){
                    mapaEmailRT.get(contactoDupl.Email).add(contactoDupl.RecordTypeId);
                } else {
                    mapaEmailRT.put(contactoDupl.Email, new List<Id> {contactoDupl.RecordTypeId});
                }
            }
        }

        //Ahora busco cuáles de los nuevos contactos tienen alguno de los emails repetidos, y sobre esos, lanzo un error.
        for(Contact allContacts : newContacts){
            if(mapaEmailRT.keySet().contains(allContacts.Email)){
                if(allContacts.RecordTypeId == buzonRT && (mapaEmailRT.get(allContacts.Email).contains(buzonRT))){
                    allContacts.addError ('Ya existe un Contacto con el mismo Email.');
                 
                }
                
            }
        }
        
        
    } 

    private void vaciarContactoConfidencial(List<Contact> contactos) {

		for (Contact contacto : contactos) {
			if (contacto.CC_Confidencial__c == true) {
				contacto.Birthdate = null;
				contacto.CC_CuentaFacebook__c = '';
				contacto.CC_CuentaTwitter__c = '';
				contacto.CC_EmpleadoGestorId__c = null;
				contacto.CC_FechaNac__c = null;
				contacto.CC_Identificador_CBKNow__c = '';
				contacto.CC_Idioma__c = null;
				contacto.CC_OficinaGestoraId__c = null;
				contacto.CC_Segmento__c = '';
				contacto.CC_Sexo__c = null;
				contacto.Email = '';
				contacto.FirstName = '';
				contacto.LastName = 'CONFIDENCIAL';
				contacto.MailingCity = null;
				contacto.MailingCountry = null;
				contacto.MailingPostalCode = null;
				contacto.MailingState = null;
				contacto.MailingStreet = null;
				contacto.MobilePhone = '';
				contacto.Phone = '';
				contacto.Salutation = null;

			}
		}
	}
        
}