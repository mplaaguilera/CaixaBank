public with sharing class CIBE_CallReportVFControllerCIB2 {

     // Mapeo de íconos
    Map<String, String> mapIcon = new Map<String, String>{
        'A' => 'alta-icon',
        'MA' => 'mediaAlta-icon',
        'M' => 'media-icon',
        'MB' => 'mediaBaja-icon',
        'B' => 'baja-icon',
        'MOR' => 'morosos-icon',
        'IN' => 'inactivos-icon',
        'P' => 'financiacionProyecto-icon'
    };

    public List<CIBE_SegmentoRentabilidadController.OptionsField> values;

    
    private static Set<Id> attorneyAttendeeRTs = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_APODERADO_RT)
        });

    private static Set<Id> contactsAttendeeRTs = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT)
        });

    private static Set<Id> employeeAttendeeRTs = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT)
        });

    public String recordId { get; set; }
    public List<Event> accountEvent { get; set; }
    public EventWrapper eventWrapper { get; set; }
    public List<Account> accounts { get; set; }
    public List<Event> events { get; set; }
    public Boolean grupoRelativa { get; set; }
    public Boolean grupoAbsoluta { get; set; }
    public Boolean empresaRelativa { get; set; }
    public Boolean empresaAbsoluta { get; set; }
    public String empresaAbsolutaClass { get; set; }
    public String empresaRelativaClass { get; set; }
    public String grupoAbsolutaClass { get; set; }
    public String grupoRelativaClass { get; set; }
    public String absolutaEmpresa{ get; set; }
    public String absolutaGrupo{ get; set; }
    public String relativaGrupo{ get; set; }
    public String relativaEmpresa{ get; set; }

    public CIBE_CallReportVFControllerCIB2() {
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        accountEvent = new List<Event>();

        if (String.isNotBlank(recordId)) {
            accountEvent = [SELECT AccountId, Account.AV_EAPGestor__c FROM Event WHERE Id =:recordId LIMIT 1];
        }

        if (accountEvent != null) {
            accounts = new List<Account>();
            events = new List<Event>();
            grupoRelativa = false;
            grupoAbsoluta = false;
            empresaRelativa = false;
            empresaAbsoluta = false;
            empresaAbsolutaClass = '';
            empresaRelativaClass = '';
            grupoAbsolutaClass = '';
            grupoRelativaClass = '';
            absolutaEmpresa = '';
            absolutaGrupo = '';
            relativaGrupo = '';
            relativaEmpresa = '';

            values = CIBE_SegmentoRentabilidadController.getValues();
            processAccountData();
            fetchData();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No recordId provided.'));
        }
    }

    // Método para procesar los datos de la cuenta
    public void processAccountData() {
        List<CIBE_SegmentoRentabilidadController.Entry> accountEntries = CIBE_SegmentoRentabilidadController.getAccount(accountEvent[0].AccountId);
        for (CIBE_SegmentoRentabilidadController.Entry element : accountEntries) {
            updateState('absolutaEmpresa', 'empresaAbsoluta', element, 'empresaAbsolutaClass');
            updateState('relativaEmpresa', 'empresaRelativa', element, 'empresaRelativaClass');
            updateState('absolutaGrupo', 'grupoAbsoluta', element, 'grupoAbsolutaClass');
            updateState('relativaGrupo', 'grupoRelativa', element, 'grupoRelativaClass');
        }
    }

    public void updateState(String value, String flag, CIBE_SegmentoRentabilidadController.Entry element, String states) {
        String elementValue;

        if (value == 'absolutaEmpresa') {
            elementValue = element.absolutaEmpresa;
        } else if (value == 'relativaEmpresa') {
            elementValue = element.relativaEmpresa;
        } else if (value == 'absolutaGrupo') {
            elementValue = element.absolutaGrupo;
        } else if (value == 'relativaGrupo') {
            elementValue = element.relativaGrupo;
        }

        if (elementValue != null && values != null) {
            for (CIBE_SegmentoRentabilidadController.OptionsField e : values) {
                if (e.value == elementValue) {
                    setValue(value, e.label); 
                    setFlag(flag, true);
                    setValue(states, mapIcon.get(elementValue));
                }
            }
        }
    }

    // Métodos auxiliares para configurar valores y flags
    public void setValue(String key, String value) {
        if (key == 'absolutaEmpresa') absolutaEmpresa = value;
        else if (key == 'relativaEmpresa') relativaEmpresa = value;
        else if (key == 'absolutaGrupo') absolutaGrupo = value;
        else if (key == 'relativaGrupo') relativaGrupo = value;
        else if (key == 'empresaAbsolutaClass') empresaAbsolutaClass = value;
        else if (key == 'empresaRelativaClass') empresaRelativaClass = value;
        else if (key == 'grupoAbsolutaClass') grupoAbsolutaClass = value;
        else if (key == 'grupoRelativaClass') grupoRelativaClass = value;
    }
    
    public void setFlag(String key, Boolean value) {
        if (key == 'empresaRelativa') empresaRelativa = value;
        else if (key == 'empresaAbsoluta') empresaAbsoluta = value;
        else if (key == 'grupoAbsoluta') grupoAbsoluta = value;
        else if (key == 'grupoRelativa') grupoRelativa = value;
    }

    private void fetchData() {
        List<Event> events = new List<Event>();
        if(Event.SObjectType.getDescribe().isAccessible()) {
            events = [SELECT Id, AV_Task__c, Subject, TOLABEL(AV_Tipo__c), ActivityDate, TOLABEL(FinServ__Regarding__c), FinServ__Objectives__c,
             StartDateTime, EndDateTime, Location, WhatId, OwnerId, Owner.Name FROM Event WHERE Id = :recordId];
        }

        if(!events.isEmpty()) {
            Event ev = events.get(0);
            eventWrapper = new EventWrapper();
            eventWrapper.subject = ev.FinServ__Objectives__c != null ? ev.FinServ__Regarding__c  + ' - ' + ev.FinServ__Objectives__c : ev.FinServ__Regarding__c;
            eventWrapper.location = ev.Location;
            eventWrapper.type = ev.AV_Tipo__c;
            eventWrapper.owner = ev.Owner.Name;
            eventWrapper.clientAttendees        = new List<CIBE_RelaccionadoCita__c>();
            eventWrapper.caixabankAttendees     = new List<CIBE_RelaccionadoCita__c>();
            eventWrapper.notRegisteredAttendees = new List<CIBE_RelaccionadoCita__c>();
            eventWrapper.relatedProducts        = new List<CIBE_RelaccionadoCita__c>();
            
            DateTime now = ev.StartDateTime != null ? ev.StartDateTime : System.now();

            String preposition = ' / ';

            switch on (UserInfo.getLanguage()) {
                when 'es' {
                    preposition = ' de ';
                }
                when 'en_US' {
                    preposition = ' of ';
                }
            }

            eventWrapper.activityDate = now.day() + preposition + CIBE_AppUtilities.getMonthName(now.month(), UserInfo.getLanguage()) + preposition + now.year();
            
            String title = 'Customer Call Report ' + now.day() + '-' + now.month() + '-' + now.year();
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + title + '.pdf');

            List<CBK_Activity_Extension__c> activityExtensions = new List<CBK_Activity_Extension__c>();
            if(String.isNotBlank(ev.Id) && CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible()) {
                activityExtensions = [SELECT Id, CIBE_ConclusionesCita__c, CIBE_Country__c, CIBE_ComentarioCita__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :ev.Id];
            }
            if(!activityExtensions.isEmpty()){
                if(activityExtensions[0].CIBE_ConclusionesCita__c!=null){
                    eventWrapper.conclusions= (activityExtensions[0].CIBE_ConclusionesCita__c.split('\n'));
                }
                if(activityExtensions[0].CIBE_ComentarioCita__c!=null){
                    eventWrapper.comments = (activityExtensions[0].CIBE_ComentarioCita__c.split('\n'));
                }
                if(activityExtensions[0].CIBE_Country__c!=null){
                    eventWrapper.pais = (activityExtensions[0].CIBE_Country__c);
                }
            }

            //Recuperamos los asistentes relaccionados
            for(CIBE_RelaccionadoCita__c asistentes : [SELECT Id,  CIBE_Contacto__c, CIBE_Contacto__r.name, CIBE_Email__c, CIBE_TipoAsistente__c
                FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :ev.AV_Task__c AND CIBE_TipoAsistente__c != null]){
                if(asistentes.CIBE_TipoAsistente__c == 'Asistentes clientes'){
                    eventWrapper.clientAttendees.add(asistentes);
                }else if(asistentes.CIBE_TipoAsistente__c == 'Asistentes Caixabank'){
                    eventWrapper.caixabankAttendees.add(asistentes);
                }else if(asistentes.CIBE_TipoAsistente__c == 'Asistentes sin registrar'){
                    eventWrapper.notRegisteredAttendees.add(asistentes);
                }                     
            } 

            //Recuperamos los productos relaccionados
            for(CIBE_RelaccionadoCita__c productos : [SELECT Id,  CIBE_Producto__c, CIBE_Producto__r.name, CIBE_Comentario__c
                FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :ev.AV_Task__c AND CIBE_Producto__c != null]){
                
                    eventWrapper.relatedProducts.add(productos);
            
            } 

            List<Contact> owners = new List<Contact>();
            if(Contact.SObjectType.getDescribe().isAccessible()) {
                owners = [SELECT Id, Account.CC_Numero_Oficina__c, Account.BillingAddress FROM Contact WHERE AV_UsuarioAsociado__c = :ev.OwnerId];
            }

            if(!owners.isEmpty()) {
                eventWrapper.center = owners.get(0).Account.CC_Numero_Oficina__c;

                Address address = owners.get(0).Account.BillingAddress;
                String formattedAddress = '';
                if(address != null) {
                    formattedAddress = address.getStreet();
                    if(String.isNotBlank(formattedAddress)) {
                        formattedAddress += (String.isNotBlank(address.getPostalCode()) ? ', ' + address.getPostalCode() : '');
                        formattedAddress += (String.isNotBlank(address.getCity()) ? ', ' + address.getCity() : '');
                        formattedAddress += (String.isNotBlank(address.getState()) ? ', ' + address.getState() : '');
                        formattedAddress += (String.isNotBlank(address.getCountry()) ? ', ' + address.getCountry() : '');
                    }
                }
                eventWrapper.centerAddress = formattedAddress;
            }
            
            if(String.isNotBlank(ev.WhatId) && Account.SObjectType.getDescribe().isAccessible()) {
                accounts = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE Id = :ev.WhatId];
            }

            if(String.isNotBlank(ev.WhatId) && Account.SObjectType.getDescribe().isAccessible()) {
                events = [SELECT Id, Subject FROM Event WHERE Id = :recordId];
            }

            if(accountEvent[0].Account.AV_EAPGestor__c != null){
                List<CIBE_Hierarchy__c> hierarchycb = new List<CIBE_Hierarchy__c>();
                hierarchycb = [SELECT Id, CIBE_SectoresPaises__c, CIBE_SectoresPaises__r.Name, CIBE_Contact__c fROM CIBE_Hierarchy__c WHERE CIBE_Contact__c =:accountEvent[0].Account.AV_EAPGestor__c LIMIT 1];
                if(!hierarchycb.isEmpty() && hierarchycb[0].CIBE_SectoresPaises__c !=null && hierarchycb[0].CIBE_SectoresPaises__r.Name!=null){
                    eventWrapper.sector = (hierarchycb[0].CIBE_SectoresPaises__r.Name);
                }
            }
        }
    }

    public class EventWrapper {
        public String subject { get; set; }
        public String country { get; set; }
        public String location { get; set; }
        public String pais {get; set;}
        public String sector {get; set;}
        public String center { get; set; }
        public String type { get; set; }
        public List<String> conclusions { get; set; }
        public String owner { get; set; }
        public String centerAddress { get; set; }
        public List<String>  comments { get; set; }
        public String activityDate { get; set; }
        public List<CIBE_RelaccionadoCita__c> clientAttendees { get; set; }
        public List<CIBE_RelaccionadoCita__c> caixabankAttendees { get; set; }
        public List<CIBE_RelaccionadoCita__c> notRegisteredAttendees { get; set; }
        public List<CIBE_RelaccionadoCita__c> relatedProducts { get; set; }
    }
}