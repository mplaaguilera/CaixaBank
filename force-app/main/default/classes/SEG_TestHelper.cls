@isTest
public without sharing class SEG_TestHelper {
    
    public static User createUser(String uniqueIdentifier){    
        Profile prof = [select id from profile where name LIKE '%marketing%'];
        User userA = new User();
        userA.firstName = uniqueIdentifier+'test1';
        userA.lastName = uniqueIdentifier+'test2';
        userA.profileId = prof.id;
        userA.SEG_Tipo_usuario_SEG__c='BO';
        userA.username = uniqueIdentifier+'test@testsegmentos.com';
        userA.email = uniqueIdentifier+'test@testsegmentos.com';
        userA.EmailEncodingKey = 'UTF-8';
        userA.LanguageLocaleKey = 'es';
		userA.LocaleSidKey = 'es';
		userA.TimeZoneSidKey = 'Europe/Berlin';
        userA.Alias = uniqueIdentifier+'seg';
        insert userA;
        return userA;
    }
    
    public static CC_Grupo_Colaborador__c createGrupoColaborador(String uniqueIdentifier,String Negocio,String Tipologia){    
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColaboradorA  = new CC_Grupo_Colaborador__c();
        grupoColaboradorA.RecordTypeId = recordTypeGrupoColaborador;
        grupoColaboradorA.name=uniqueIdentifier;
        grupoColaboradorA.OS_Negocio__c = Negocio;
        grupoColaboradorA.SEG_Tipologia__c=Tipologia;
        insert grupoColaboradorA;
        return grupoColaboradorA;
    }
    
    public static CC_Grupo_Colaborador_Contact__c createColaborador(CC_Grupo_Colaborador__c grupoColaborador ,String Tipo_acceso, User usr){    
        CC_Grupo_Colaborador_Contact__c colaboradorA = new CC_Grupo_Colaborador_Contact__c();
        colaboradorA.CC_Usuario__c = usr.id;
        colaboradorA.CC_Grupo_Colaborador__c=grupoColaborador.Id;
        colaboradorA.SEG_TipodeAcceso__c=Tipo_acceso;
        insert colaboradorA;
        return colaboradorA;
    }
    @future
    public static void createCaseTeamTemplate(String nameCaseTeamTemplate, id idCaseTeamTemplate)
    {
        CaseTeamTemplate equipoCaso = new CaseTeamTemplate();
        equipoCaso.Name = nameCaseTeamTemplate;
        equipoCaso.Description = idCaseTeamTemplate;
        insert equipoCaso;
        
    }
    
    public static Account createCustomer(){
		//RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_Cliente');
		id rt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

		Account acc = new Account(
				Name = 'EMPRESA SEGMENTOS',
				RecordTypeId = rt,
            	SEG_DominioMail__c = 'gmail.com',
				SEG_Organizacion__c = 'Banca Corporativa',
				SEG_Zona__c = 'Corporativa',
				BillingStreet = 'Street Test',
				BillingPostalCode = '08950',
				BillingCity ='Barcelona',
				BillingState = 'Barcelona',
				BillingCountry = 'ES'
			);
		insert acc;
		return acc;
    }
    public static SEG_Buzon__mdt createBuzon() {
        SEG_Buzon__mdt buzon = new SEG_Buzon__mdt();
        buzon.SEG_Email_SF__c='tiha.invalidad@invalid.com';
        buzon.SEG_Zona__c = 'Corporativa';
        buzon.SEG_Organizacion__c = 'Banca Corporativa';
		buzon.SEG_Correo_de_procedencia__c = 'tiha.invalidad@invalid.com';
        return buzon;
    }
    public static Case createCase1(){
        Case caso = new Case(
                SEG_SemillaId__C = '#@SEG:1611676158418#',
                SEG_Zona__c ='Corporativa',
                SEG_Organizacion__C='Banca Corporativa'
			);
        insert caso;
        return caso;
    }
    public static Case createCase2(){
        Case caso = new Case(
                SEG_SemillaId__C = '#@SEG:1610540342877#',
                SEG_Zona__c ='Corporativa',
                SEG_Organizacion__C='Banca Corporativa'
			);
        insert caso;
        return caso;
    }
    
    public static Contact createCustomerContact(String AccountID,string email)
    {
        Contact contacto = new Contact(
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            FirstName = 'Contacto Cliente',
            LastName = 'Test',
            AccountId = AccountID,
            CC_Idioma__c = 'es',
            Email = email,
            CC_Numero_Documento__c = '00000000T'
        );    
        insert contacto;
        return contacto;
    }
    
    public static Account createCaixaCenter(){
        //RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_CentroCaixaBank');
        id rt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		Account centroCaixa = new Account();
		centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
		centroCaixa.CC_Numero_Oficina_Empresa__c = '00615';
		centroCaixa.CC_Numero_Oficina__c = '00615';
		centroCaixa.RecordTypeId = rt;
		insert centroCaixa;
		return centroCaixa;
	}
    public static Contact createEmployee(Account center, User user,String email){
        //RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado');
        id rt = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		Contact employee = new Contact();
		employee.RecordTypeId = rt;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		//employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		//employee.CC_Matricula__c = MATRICULA_SAMPLE;
		if (center!=null){
			employee.AccountId = center.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
		}
		insert employee;
		return employee;
	}

}