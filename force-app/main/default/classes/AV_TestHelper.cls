/**********************************************************************************************************************
 Name:    AV_TestHelper
 Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase que crea datos para el testing del resto de clases
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY              AUTHOR              DATE                Description
	1.0         AV_TestHelper           David Rufo          09/05/2020          Init version
	1.1         AV_TestHelper           Carolina Alonso     21/05/2020          Add new methods
	1.2         AV_TestHelper           Carolina Alonso     03/06/2020          Add new method createOpportunityWithEmpleado
	1.3         AV_TestHelper           Carolina Alonso     15/06/2020          Add new method createCustomerWithComment
	1.4         AV_TestHelper           Carolina Alonso     01/07/2020          Add new method createOpportunityIniciativaWithEmpleado
	1.5         AV_TestHelper           Esperanza Conde     10/07/2020          Add new method createCustomerCompany
	1.6         AV_TestHelper           Carolina Alonso     28/08/2020          Add new method createTareaOtherExternalID
	1.7         AV_TestHelper           Carolina Alonso     02/09/2020          Add new method createTareaExternalId, createEventExternalId
	1.8         AV_TestHelper           Carolina Alonso     02/10/2020          Add new method createEventWithOpp, createTareaWithOpp
	1.9         AV_TestHelper           Carolina Alonso     22/10/2020          Modify method createEmployee to enter random CC_Matricula (unique field)
	1.10        AV_TestHelper           Carolina Alonso     26/10/2020          Modify method createTareaExternalId to replace the RT 'AV_Muro' by the RT 'AV_Otros'
	1.11        AV_TestHelper           Víctor Santiago     05/02/2021          Add new methods: createCustomerWithEAPGestor, createTareaExternalIdWithCustomer, createPricebook2, createTareaExternalIdCustomStatusWithCustomer, createOpportunityCustomStageNameWithEmpleado
	1.12        AV_TestHelper           Víctor Santiago     08/02/2021          Modified createOpportunityCustomStageNameWithEmpleado to createOpportunityCustomStageNamExtIdWithEmpleado, added parameter externalId. Created methods createEventConClienteEAPGestor
	1.13        AV_TestHelper           David Rufo          11/02/2020          New method to insert permission set to the users for testing
	1.14        AV_TestHelper           Víctor Santiago     25/02/2021          Added new method createManagementHistory
	1.15        AV_TestHelper           Sandra Gómez        26/08/2021          Fix Opp product
	1.16        AV_TestHelper           Sandra Gómez        20/10/2021          change method createSales
	1.17        AV_TestHelper           Víctor Santiago     21/06/2022          create createCustomerSinInsert, createTareaOportunidad
	1.18        AV_TestHelper           Patricia Solano     07/10/2022          create createTaskTest
	1.20        AV_TestHelper           Patricia Solano     19/10/2022          create createSalesSinInsert
	1.21        AV_TestHelper           Vladislav Lityagin  14/11/2022          create createTareaExternalIdWithCustomerSinInsert
	2.0         AV_TestHelper           Sandra Gómez        22/11/2022          Add new method createTareaExternalIdSinInsert, createEventExternalIdSinInsert
	2.1        	AV_TestHelper           Patricia Solano     13/01/2023          Modified method createUser to add role an profile
	2.2			AV_TestHelper			Sandra Gómez		20/01/2023			Add createOpportunityWithProduct, createOpportunityWithProductSinInsert, createCustomerWithNumpersonSinInsert, createProductSinInsert and createProduct with external
	2.3			AV_TestHelper			Vladislav Lityagin	31/01/2023			Add createOpportunityWithEmpleadoSinInsert2 and createOpportunityIniciativaWithChecktPrioritySinInsert2
	2.4			AV_TestHelper			Patricia Solano  	08/02/2023			Add createEmployeeAgroReferentSinInsert to create contact with responsability agro referent and createCustomerCompanySinInsert
	2.3			AV_TestHelper			Vladislav Lityagin	17/02/2023			Add createLeadSinInsert and createLeadOpportunitySinInsert
    2.4         AV_TestHelper           Oscar Moreno        23/02/2023          Add createEventConClienteEAPGestorSinInsert, createTareaExternalIdCustomStatusWithCustomerSinInsert
	2.5			AV_TestHelper			Sandra Gómez		16/08/2023			Add createEmployeeSinInsert2 with matricula and OwnerId 
	2.6			AV_TestHelper			Sandra Gómez		21/09/2023			Add createTareaWithRT,createProductSinInsert(with rt) and createTareaWithRTSinInsert and createManagementHistoryWithOwner
	2.7         AV_TestHelper           Oscar Moreno        16/10/2023          Add createRepresentante method to create contact with RecordType CC_Representante
	2.8			AV_TestHelper			Gonzalo Ávila 		25/10/2023			Add createPFExperienceSinInsert and createPFClienteSinInsert
	2.9			AV_TestHelper			Luis Fernández		19/12/2023			Add createExperienciaNegocioSinInsert
***********************************************************************************************************************/
@isTest
public with sharing class AV_TestHelper {

	private static final String MATRICULA_SAMPLE = 'U0009003';
	
	public static Integer getRandomValueMatricula(){
		return Math.round(Math.random()*100000);
	}

	public static Integer getRandomValue(){
		return Math.round(Math.random()*1000);
	}

	public static String getEmail(){
		Integer rand = getRandomValue();
		Integer rand2 = getRandomValue();
		return 'test' + rand + '@test.env' + rand2 + '.es';
	}

	public static void activateLogger(){
		AV_ByPass__c byPass = new AV_ByPass__c(
				LogDebug__c=true,
				LogError__c=true,
				LogInfo__c=true,
				LogWarn__c=true
		);
		insert byPass;
	}

	public static User createUser(String labelProfile){
		if (String.isBlank(labelProfile)){
			labelProfile = 'AV_Usuario_CaixaBank';
		}
		String role = 'AV_SistematicaComercial';
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = getEmail();
		Profile p = (Profile)result.get(0);
		User u = new User(
				Alias = 'tsAlias',
				Email = 'test@test.dev',
				EmailEncodingKey = 'UTF-8',
				LastName = 'testLastName',
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es',
				TimeZoneSidKey = 'Europe/Berlin',
				AV_NumeroOficinaEmpresa__c = '001-03044',
				ProfileId = p.Id,
				UserName = username,
				AV_ExternalID__c = MATRICULA_SAMPLE,
				IsActive = true
			);
		insert u;
		return u;
	}
	
	public static User createUser(String labelProfile, String matricula){
		if (String.isBlank(labelProfile)){
			labelProfile = 'AV_Usuario_CaixaBank';
		}
		if (String.isBlank(matricula)){
			matricula = MATRICULA_SAMPLE;
		}
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = getEmail();
		Profile p = (Profile)result.get(0);
		User u = new User(
				Alias = 'tsAlias',
				Email = 'test@test.dev',
				EmailEncodingKey = 'UTF-8',
				LastName = 'testLastName',
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es',
				TimeZoneSidKey = 'Europe/Berlin',
				AV_NumeroOficinaEmpresa__c = '001-03044',
				ProfileId = p.Id,
				UserName = username,
				AV_ExternalID__c = matricula
			);
		insert u;
		return u;
	}

	public static User createUser(String labelProfile, String matricula, String role){
		if (String.isBlank(labelProfile)){
			labelProfile = 'AV_Usuario_CaixaBank';
		}
		if (String.isBlank(matricula)){
			matricula = MATRICULA_SAMPLE;
		}
		UserRole rol;
		if (role != null) {
			rol=[Select Id from UserRole where DeveloperName =:role limit 1];
		}
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = getEmail();
		Profile p = (Profile)result.get(0);
		User u = new User();
		u.Alias = 'tsAlias';
		u.Email = 'test@test.dev';
		u.EmailEncodingKey = 'UTF-8';
		u.LastName = 'testLastName';
		u.LanguageLocaleKey = 'es';
		u.LocaleSidKey = 'es';
		u.TimeZoneSidKey = 'Europe/Berlin';
		u.AV_NumeroOficinaEmpresa__c = '001-03044';
		u.ProfileId = p.Id;
		if (rol != null) {
			u.UserRoleId = rol.Id;
		}
		u.UserName = username;
		u.AV_ExternalID__c = matricula;
		insert u;
		return u;
	}
	
	public static User createUserSinInsert(String labelProfile, String matricula, String role){
		if (String.isBlank(labelProfile)){
			labelProfile = 'AV_Usuario_CaixaBank';
		}
		if (String.isBlank(matricula)){
			matricula = MATRICULA_SAMPLE;
		}
		UserRole rol;
		if (role != null) {
			rol=[Select Id from UserRole where DeveloperName =:role limit 1];
		}
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = getEmail();
		Profile p = (Profile)result.get(0);
		User u = new User();
		u.Alias = 'tsAlias';
		u.Email = 'test@test.dev';
		u.EmailEncodingKey = 'UTF-8';
		u.LastName = 'testLastName';
		u.LanguageLocaleKey = 'es';
		u.LocaleSidKey = 'es';
		u.TimeZoneSidKey = 'Europe/Berlin';
		u.AV_NumeroOficinaEmpresa__c = '001-03044';
		u.ProfileId = p.Id;
        u.AV_Funcion__c = 'Gestor';
		if (rol != null) {
			u.UserRoleId = rol.Id;
		}
		u.UserName = username;
		u.AV_ExternalID__c = matricula;
        u.EmployeeNumber = matricula;
		return u;
	}
	
	public static User createUserSinInsert(String labelProfile, String matricula){
		if (String.isBlank(labelProfile)){
			labelProfile = 'AV_Usuario_CaixaBank';
		}
		if (String.isBlank(matricula)){
			matricula = MATRICULA_SAMPLE;
		}
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = getEmail();
		Profile p = (Profile)result.get(0);
		User u = new User(
				Alias = 'tsAlias',
				Email = 'test@test.dev',
				EmailEncodingKey = 'UTF-8',
				LastName = 'testLastName',
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es',
				TimeZoneSidKey = 'Europe/Berlin',
				AV_NumeroOficinaEmpresa__c = '001-03044',
				ProfileId = p.Id,
				UserName = username,
				AV_ExternalID__c = matricula
			);
		return u;
	}
	
	public static void insertPermissionSet(String userId, String psLabel){

		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :psLabel];
		insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
	}

	public static Account createCustomer(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA',
				CC_Numero_Documento__c = '9446386T'
            	// AV_Confidencial__c = false
			);
		insert acc;
		return acc;
	}
	
	public static Account createCustomer2(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '1234',
				AV_Negocio__c = 'BPA',
				CC_Numero_Documento__c = '12345678A'
			);
		insert acc;
		return acc;
	}
	
	public static Account createConfidencialCustomer(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA',
				AV_Confidencial__c = true
			);
		insert acc;
		return acc;
	}
	
	public static Account createConfidencialCustomerSinInsert(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA',
				AV_Confidencial__c = true
			);
		return acc;
	}

	public static Account createCustomerWithNumperson(String numper){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = numper,
				AV_Negocio__c = 'BPA'
			);
		insert acc;
		return acc;
	}

	public static Account createCustomerWithNumpersonSinInsert(String numper){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = numper,
				AV_Negocio__c = 'BPA'
			);
		return acc;
	}
	
	public static Account createCustomerWithBusiness(String business){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		String numper = String.valueOf(getRandomValue());
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = numper
			);
		if (String.isNotBlank(business)){
			acc.AV_Negocio__c = business;
		}
		insert acc;
		return acc;
	}
	
	public static Account createCustomerCompany(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
		Account acc = new Account(
				Name = 'FirstName LastName',
				RecordTypeId = rt.Id
			);
		insert acc;
		return acc;
	}

	public static Account createCustomerCompanySinInsert(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
		Account acc = new Account(
				Name = 'FirstName LastName',
				RecordTypeId = rt.Id
			);
		return acc;
	}
	
	public static Account createCustomerWithComment(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA',
				Description = 'Este cliente de prueba esta siendo testeado'
			);
		insert acc;
		return acc;
	}

	public static Account createCustomerWithEAPGestor(Contact gestor) {
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA'
			);
		if (gestor != null) {
			acc.AV_EAPGestor__c = gestor.Id;
		}
		insert acc;
		return acc;
	}

	public static Account createCaixaCenter(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
		Account centroCaixa = new Account();
		centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
		centroCaixa.CC_Numero_Oficina_Empresa__c = '00615';
		centroCaixa.CC_Numero_Oficina__c = '00615';
		centroCaixa.RecordTypeId = rt.Id;
		insert centroCaixa;
		return centroCaixa;
	}
	
	public static Account createCaixaCenterSinInsert(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
		Account centroCaixa = new Account();
		centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
		centroCaixa.CC_Numero_Oficina_Empresa__c = '00615';
		centroCaixa.CC_Numero_Oficina__c = '00615';
		centroCaixa.RecordTypeId = rt.Id;
		return centroCaixa;
	}

	public static Account createCustomerSinInsert() {
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA',
				CC_Numero_Documento__c = '9446386T'
			);
		return acc;
	}

	public static Contact createEmployee(Account center, User user){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.EMPLOYEE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
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
	
	public static Contact createEmployee(Account center, User user, String matricula){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.EMPLOYEE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = matricula;
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

	public static Contact createEmployeeAgroReferentSinInsert(Account center, User user, String agroResponsability){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.EMPLOYEE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
		if (center!=null){
			employee.AccountId = center.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
		}
		if (agroResponsability!= null && agroResponsability.equals('Referente Agro')){
			employee.AV_Responsabilidad__c = 'Referente Agro';
		}
		return employee;
	}
	
	public static Contact createRepresentante(Account center, User user, String matricula){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.REPRESENTANTE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = matricula;
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
	
	public static Contact createRepresentante(Account center, User user){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT,AV_AppConstants.CONTACT_REPRESENT_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_CargoRepresentante__c = 'Prueba';
		employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
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

	public static Contact createRepresentanteOtros(Account center, User user, String matricula){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.REPRESENTANTE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = 'OTROS';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = matricula;
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
	
	public static Account createCustomerOTROS(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
		Account acc = new Account(
				Name = 'OTROS',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '000000000'
			);
		insert acc;
		return acc;
	}
	
	public static Contact createEmployeeSinInsert(Account center, User user){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.EMPLOYEE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
		if (center!=null){
			employee.AccountId = center.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
		}
		return employee;
	}
    
    public static Contact createEmployeeSinInsert2(Account center, User user, RecordType rt){
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
		if (center!=null){
			employee.AccountId = center.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
		}
		return employee;
	}
    
    public static Contact createEmployeeSinInsert2(Account center, User user, RecordType rt, String matricula, User userOwner){
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
        if (matricula != null){
            employee.CC_Matricula__c = matricula;
        }else {
            employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
        }
		if (center!=null){
			employee.AccountId = center.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
            if (userOwner != null) {
                employee.OwnerId = userOwner.Id;
            } else {
                employee.OwnerId = user.Id;
            }
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
            if (userOwner != null) {
                employee.OwnerId = userOwner.Id;
            } else {
                employee.OwnerId = UserInfo.getUserId();
            }
		}
		return employee;
	}

	public static Contact createEmployeeSinInsert(Account center, User user, String matricula){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.EMPLOYEE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = matricula;
		if (center!=null){
			employee.AccountId = center.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
		}
		return employee;
	}

  /*  public static AV_Goal__c createGoal(String nameGoal, Integer dataProduction, Contact employee){
		AV_Goal__c goal = new AV_Goal__c();
		goal.Name = nameGoal;
		goal.AV_Empleado__c = employee.Id;
		goal.AV_FechaCalculo__c = Date.TODAY();
		goal.AV_Produccion__c = dataProduction;
		insert goal;
		return goal;
	}*/

	public static AV_ProductExperience__c createPFExperience(){
		AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
		prodExp.AV_ExternalID__c = 'BPA004_50003';
		insert prodExp;
		return prodExp;
	}

	public static Product2 createProduct(Product2 product, String level){
		Product2 prod = new Product2();
		prod.Name = 'Product: ' + getRandomValue();
		prod.AV_Nivel__c = level;
		if(String.isNotBlank(level) && level == '1'){
			prod.AV_ExternalID__c = '50000';
		} else if(String.isNotBlank(level) && level == '10'){
			prod.AV_ExternalID__c = '50001';
		} else if(String.isNotBlank(level) && level == '20'){
			prod.AV_ExternalID__c = '50002';
		} else {
			prod.AV_ExternalID__c = '50003';
		}
		
		if (product!=null){
			prod.AV_NombrePF__c = product.Id;
		}
		prod.AV_Profesional__c = false;
		prod.AV_Activo__c = true;
		insert prod;
		return prod;
	}

	public static Product2 createProduct(Product2 product, String level,String externalID){
		Product2 prod = new Product2();
		prod.Name = 'Product: ' + getRandomValue();
		prod.AV_Nivel__c = level;
		if (externalID != null) {
			prod.AV_ExternalID__c = externalID;
		}else if(String.isNotBlank(level) && level == '1'){
			prod.AV_ExternalID__c = '50000';
		} else if(String.isNotBlank(level) && level == '10'){
			prod.AV_ExternalID__c = '50001';
		} else if(String.isNotBlank(level) && level == '20'){
			prod.AV_ExternalID__c = '50002';
		} else {
			prod.AV_ExternalID__c = '50003';
		}
		
		if (product!=null){
			prod.AV_NombrePF__c = product.Id;
		}
		prod.AV_Profesional__c = false;
		prod.AV_Activo__c = true;
		insert prod;
		return prod;
	}

	public static Product2 createProductSinInsert(Product2 product, String level,String externalID){
		Product2 prod = new Product2();
		prod.Name = 'Product: ' + getRandomValue();
		prod.AV_Nivel__c = level;
		if (externalID != null) {
			prod.AV_ExternalID__c = externalID;
		}else if(String.isNotBlank(level) && level == '1'){
			prod.AV_ExternalID__c = '50000';
		} else if(String.isNotBlank(level) && level == '10'){
			prod.AV_ExternalID__c = '50001';
		} else if(String.isNotBlank(level) && level == '20'){
			prod.AV_ExternalID__c = '50002';
		} else {
			prod.AV_ExternalID__c = '50003';
		}
		
		if (product!=null){
			prod.AV_NombrePF__c = product.Id;
		}
		prod.AV_Profesional__c = false;
		prod.AV_Activo__c = true;
		return prod;
	}

	public static Product2 createProductSinInsert(Product2 product, String level,String externalID,RecordType rt){
		Product2 prod = new Product2();
		prod.Name = 'Product: ' + getRandomValue();
		prod.AV_Nivel__c = level;
		prod.RecordTypeId = rt.Id;
		if (externalID != null) {
			prod.AV_ExternalID__c = externalID;
		}else if(String.isNotBlank(level) && level == '1'){
			prod.AV_ExternalID__c = '50000';
		} else if(String.isNotBlank(level) && level == '10'){
			prod.AV_ExternalID__c = '50001';
		} else if(String.isNotBlank(level) && level == '20'){
			prod.AV_ExternalID__c = '50002';
		} else {
			prod.AV_ExternalID__c = '50003';
		}
		
		if (product!=null){
			prod.AV_NombrePF__c = product.Id;
		}
		prod.AV_Profesional__c = false;
		prod.AV_Activo__c = true;
		return prod;
	}
	
	public static Product2 createProduct2(Product2 product, String externalID){
		Product2 prod = new Product2();
		prod.Name = 'Product: ' + getRandomValue();
		
		if(externalID == null){
			prod.AV_ExternalID__c = '50000';
		}else{
			prod.AV_ExternalID__c = externalID; 
		}
		
		if (product!=null){
			prod.AV_NombrePF__c = product.Id;
		}
		prod.AV_Profesional__c = false;
		prod.AV_Activo__c = true;
		insert prod;
		return prod;
	}

	public static AV_Sales__c createSales(Account customer, Product2 prod){
		AV_Sales__c sales = new AV_Sales__c();
		sales.AV_Cliente__c = customer.Id;
		sales.AV_Producto__c = prod.Id;
		sales.AV_ClaseVenta__c = 'V';
		sales.AV_TipoVenta__c = '010';
		sales.AV_FechaVenta__c = system.today();
		insert sales;
		return sales;
	}

	public static AV_Sales__c createSales(Account customer, Product2 prod, String rt, Account centro, String claseVenta,String externalID, Date fechaVenta,Contact gestor,Integer importe){
		AV_Sales__c sales = new AV_Sales__c();
		sales.Name='Venta Prueba';
		sales.AV_Cliente__c = customer.Id;
		if (rt != null) {
			sales.RecordTypeId = rt;
		}
		if (centro != null) {
			sales.AV_CentroVenta__c=centro.Id;
		}
		sales.AV_Producto__c = prod.Id;
		if (claseVenta!= null) {
			sales.AV_ClaseVenta__c = claseVenta;
		} else {
			sales.AV_ClaseVenta__c = 'V';
		}
		if (externalID != null) {
			sales.AV_ExternalID__c = externalID;
		}
		sales.AV_TipoVenta__c = '010';
		sales.AV_FechaAlta__c = system.today();
		if(fechaVenta != null) {
			sales.AV_FechaVenta__c =fechaVenta;
		}else {
			sales.AV_FechaVenta__c = system.today();
		}
		if (importe!=null) {
			sales.AV_Importe__c=importe;
		}
		sales.AV_Margen1__c=110;
		sales.AV_Canal__c='110';
		if (gestor != null) {
			sales.AV_GestorAsignadoVenta__c=gestor.Id;
		}
		insert sales;
		return sales;
	}

	public static AV_Sales__c createSalesSinInsert(Account customer, Product2 prod, String rt, Account centro, String claseVenta,String externalID, Date fechaVenta,Contact gestor){
		AV_Sales__c sales = new AV_Sales__c();
		sales.Name='Venta Prueba';
		sales.AV_Cliente__c = customer.Id;
		if (rt != null) {
			sales.RecordTypeId = rt;
		}
		if (centro != null) {
			sales.AV_CentroVenta__c=centro.Id;
		}
		sales.AV_Producto__c = prod.Id;
		if (claseVenta!= null) {
			sales.AV_ClaseVenta__c = claseVenta;
		} else {
			sales.AV_ClaseVenta__c = 'V';
		}
		if (externalID != null) {
			sales.AV_ExternalID__c = externalID;
		}
		sales.AV_TipoVenta__c = '010';
		sales.AV_FechaAlta__c = system.today();
		if(fechaVenta != null) {
			sales.AV_FechaVenta__c =fechaVenta;
		}else {
			sales.AV_FechaVenta__c = system.today();
		}
		sales.AV_Importe__c=15698;
		sales.AV_Margen1__c=110;
		sales.AV_Canal__c='110';
		if (gestor != null) {
			sales.AV_GestorAsignadoVenta__c=gestor.Id;
		}
		return sales;
	}

	public static AV_Sales__c createSalesSinInsert(Account customer, Product2 prod){
		AV_Sales__c sales = new AV_Sales__c();
		sales.AV_Cliente__c = customer.Id;
		sales.AV_Producto__c = prod.Id;
		sales.AV_ClaseVenta__c = 'V';
		sales.AV_FechaVenta__c = system.today();
		sales.AV_TipoVenta__c = '010';
		return sales;
	}
   
	public static AV_Sales__c createSalesWithDate(Account customer, Product2 prod,Date dtTime){
		AV_Sales__c sales = new AV_Sales__c();
		sales.AV_FechaVenta__c= dtTime;
		sales.AV_Cliente__c = customer.Id;
		sales.AV_Producto__c = prod.Id;
		sales.AV_ClaseVenta__c = 'V';
		sales.AV_TipoVenta__c = '010';
		insert sales;
		return sales;
	}   

	public static Event createEvent(User user, Datetime activityDate, Account acc){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = acc.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.AV_Tipo__c = 'CTO';
		event.StartDateTime = activityDate;
		event.AV_CodigoGestorAsignado__c = 'U01XYZ02';
		event.EndDateTime = activityDate.addMinutes(60);
		event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		insert event;
		return event;
	}

	public static Event createEventVideocCall(User user, Datetime activityDate, Account acc){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = acc.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.AV_Tipo__c = 'VLD';
		event.StartDateTime = activityDate;
		event.EndDateTime = activityDate.addMinutes(60);
		event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		insert event;
		return event;
	}

	public static Event createEventConCliente(User user, Datetime activityDate, Account customer){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = customer.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.StartDateTime =activityDate;
		event.EndDateTime =activityDate.addMinutes(60);
		event.AV_Tipo__c = 'CTO';
		event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP; 
		insert event;
		return event;
	}

	public static Event createEventConClienteEAPGestor(User user, Datetime activityDate, Account customer, String gestor){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = customer.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.StartDateTime =activityDate;
		event.EndDateTime =activityDate.addMinutes(60);
		event.AV_Tipo__c = 'CTO';
		event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		event.AV_CodigoGestorAsignado__c = gestor;
		insert event;
		return event;
	}
    
    public static Event createEventConClienteEAPGestorSinInsert(User user, Datetime activityDate, Account customer, String gestor){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = customer.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.StartDateTime =activityDate;
		event.EndDateTime =activityDate.addMinutes(60);
		event.AV_Tipo__c = 'CTO';
		event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		event.AV_CodigoGestorAsignado__c = gestor;
		
		return event;
	}
	
	public static Event createEventConClienteRecurrente(User user, Account customer){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT);
		Event event = new Event();
		event.Subject = 'Test Event 001-A';
		event.WhatId = customer.Id;
		event.RecordTypeId = rt.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		event.DurationInMinutes = 60;
		event.ActivityDateTime = System.now();
		event.IsRecurrence = true;
		event.RecurrenceStartDateTime = System.now();
		event.RecurrenceEndDateOnly = System.today()+2;
		event.RecurrenceType = 'RecursEveryWeekday';
		event.RecurrenceDayofWeekMask = 1;
		event.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		
		insert event;
		return event;
	}

	public static Opportunity createOpportunity(Account acc){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_PF__c = prodPF.Id;
        opp.AV_OrigenApp__c = 'AV_BackReport';
		insert opp;
		return opp;
	}

	public static Opportunity createOpportunity(Account acc, Date fechacierre){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = fechacierre;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}
	
	public static Opportunity createOpportunityWithEmpleado(Account acc, Contact empleado){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = '00000001';
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'Potencial';
		opp.AV_FechaModificacion__c = system.today();
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
        opp.AV_OrigenApp__c = 'AV_BackReport';
		insert opp;
		return opp;
	}

	public static Opportunity createOpportunityWithProduct(Account acc, Contact empleado, Product2 prodPF, String externalID,Date fechaMod,String status){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPPROPUESTA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		if (externalID!= null) {
			opp.AV_ExternalID__c = externalID;
		} else {
			opp.AV_ExternalID__c = '00000001';
		}
		opp.Name = 'Alerta Comercial';
		if (status != null) {
			opp.StageName = status;
		}else {
			opp.StageName = 'Potencial';
		}
		if (fechaMod!= null) {
			opp.AV_FechaModificacion__c = fechaMod;
		}
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}

	public static Opportunity createOpportunityWithProductSinInsert(Account acc, Contact empleado, Product2 prodPF, String externalID,Date fechaMod,String status){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPPROPUESTA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		if (externalID!= null) {
			opp.AV_ExternalID__c = externalID;
		} else {
			opp.AV_ExternalID__c = '00000001';
		}
		opp.Name = 'Alerta Comercial';
		if (status != null) {
			opp.StageName = status;
		}else {
			opp.StageName = 'Potencial';
		}
		if (fechaMod!= null) {
			opp.AV_FechaModificacion__c = fechaMod;
		}
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
		return opp;
	}
	
	public static Opportunity createOpportunityWithEmpleadoSinInsert(Account acc, Contact empleado){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = '00000001';
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'Potencial';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
		return opp;
	}
    
    public static Opportunity createOpportunityWithEmpleadoSinInsert2(Account acc, Contact empleado, Product2 prodPF, RecordType rt, String externalId, Id ownerId){
		//RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = externalId;
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'Potencial';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
        opp.OwnerId = ownerId;
		return opp;
	}

	public static Opportunity createOpportunityCustomStageNameExtIdWithEmpleado(Account acc, Contact empleado, String customStageName, String externalId){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = externalId;
		opp.Name = 'Alerta Comercial';
		opp.StageName = customStageName;
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}

	public static Opportunity createOpportunityWithContract(Account acc, User owner){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = '00000001';
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'Potencial';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.OwnerId = owner.Id;
		opp.AV_ModificacionTelefonica__c = true;
		opp.AV_Contrato__c = '999999999';
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}

	public static Opportunity createOpportunityIniciativaWithEmpleado(Account acc, Contact empleado){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = '00000001';
		opp.Name = 'Opp Iniciativa';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_FechaProximoRecordatorio__c = System.today();
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}
	
	public static Opportunity createOpportunityIniciativaWithChecktPriority(Account acc, Contact empleado, String externalProduct, String externalID){
		//Product2 prodPF = AV_TestHelper.createProduct2(null, externalProduct);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AV_IncludeInPrioritizingCustomers__c =  true;
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = externalID;
		opp.Name = 'Opp Iniciativa';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_FechaProximoRecordatorio__c = System.today();
		//opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}
	
	public static Opportunity createOpportunityIniciativaWithChecktPrioritySinInsert(Account acc, Contact empleado, String externalProduct, String externalID){
		Product2 prodPF = AV_TestHelper.createProduct2(null, externalProduct);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AV_IncludeInPrioritizingCustomers__c =  true;
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = externalID;
		opp.Name = 'Opp Iniciativa';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_FechaProximoRecordatorio__c = System.today();
		opp.AV_PF__c = prodPF.Id;
		return opp;
	}
    
	public static Opportunity createOpportunityIniciativaWithChecktPrioritySinInsert2(Account acc, Contact empleado, Product2 prodPF, RecordType rt, String externalID, Id ownerId){
		//Product2 prodPF = AV_TestHelper.createProduct2(null, externalProduct);
		//RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AV_IncludeInPrioritizingCustomers__c =  true;
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = externalID;
		opp.Name = 'Opp Iniciativa';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_FechaProximoRecordatorio__c = System.today();
		opp.AV_PF__c = prodPF.Id;
        opp.OwnerId = ownerId;
		return opp;
	}

	public static Opportunity createOpportunityIniciativaWithEmpleadoWithoutExternalId(Account acc, Contact empleado){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.Name = 'Opp Iniciativa';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_FechaProximoRecordatorio__c = System.today();
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}
	
	public static Opportunity createOpportunityIniciativaWithEmpleadoWithoutExternalIdSinFechaCierre(Account acc, Contact empleado){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.Name = 'Opp Iniciativa';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_FechaProximoRecordatorio__c = System.today();
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}

	public static Task createTarea(User user){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}       
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928374';
		
		tarea.RecordTypeId = rt.Id;
		insert tarea;
		return tarea;
	}

	public static Task createTarea(User user, Date fechavencimiento){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}       
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928374';
		tarea.ActivityDate=fechavencimiento;
		tarea.RecordTypeId = rt.Id;
		insert tarea;
		return tarea;
	}

	public static AV_CustomActivityOpportunity__c createTareaOportunidad(Opportunity opp, String idCabeceraTarea){
		AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
		tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
		tareaOpp.AV_Opportunity__c = opp.Id;
		tareaOpp.AV_Task__c = idCabeceraTarea;
		insert tareaOpp;
		return tareaOpp;
	}
	
	public static AV_CustomActivityOpportunity__c createTareaOportunidadSinInsert(Opportunity opp, String idCabeceraTarea){
		AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
		tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
		tareaOpp.AV_Opportunity__c = opp.Id;
		tareaOpp.AV_Task__c = idCabeceraTarea;
		return tareaOpp;
	}

	public static AV_CustomActivityOpportunity__c createTareaOportunidad(Opportunity opp, Task t) {
		AV_HeaderCustomActivity__c hca = [SELECT Id FROM AV_HeaderCustomActivity__c WHERE AV_ExternalId__c = :t.AV_ExternalID__c LIMIT 1];
		AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
		tareaOpp.Name = 'Llamada Saliente - Alerta Comercial 2';
		tareaOpp.AV_Opportunity__c = opp.Id;
		tareaOpp.AV_Task__c = hca.Id;
		tareaOpp.AV_ActivityDate__c = t.ActivityDate;
		tareaOpp.AV_Status__c = t.Status;
		insert tareaOpp;
		return tareaOpp;
	}
	
	public static AV_CustomActivityOpportunity__c createTareaOportunidadExt(Opportunity opp, String extHeaderTask){
		AV_HeaderCustomActivity__c hca = [SELECT Id FROM AV_HeaderCustomActivity__c WHERE AV_ExternalId__c = :extHeaderTask LIMIT 1];
		return createTareaOportunidad(opp, hca.Id);
	}

	public static AV_CustomActivityOpportunity__c createTareaOportunidadMain(Opportunity opp, String idCabeceraTarea){
		AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
		tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
		tareaOpp.AV_Opportunity__c = opp.Id;
		tareaOpp.AV_Task__c = idCabeceraTarea;
		tareaOpp.AV_IsMain__c = true;
		insert tareaOpp;
		return tareaOpp;
	}

	public static AV_CustomActivityOpportunity__c createTareaOportunidadMainSinInsert(Opportunity opp, String IdHeaderTask){
		AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
		tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
		tareaOpp.AV_Opportunity__c = opp.Id;
		tareaOpp.AV_Task__c = IdHeaderTask;
		tareaOpp.AV_IsMain__c = true;
		return tareaOpp;
	}

	public static AV_ExperienceBusiness__c createExperienciaNegocio(){
		AV_ExperienceBusiness__c exp = new AV_ExperienceBusiness__c();
		exp.AV_Negocio__c = 'BPA';
		exp.AV_Activo__c = true;
		exp.AV_Orden__c = 1;
		exp.AV_MyBox__c = true;
		exp.AV_CodigoTipoExperiencia__c = '001';
		exp.AV_DescTipoExperiencia__c = 'Día a día';
		exp.AV_ExternalID__c = 'BPA001';
		insert exp;
		return exp;
	}
	public static AV_ExperienceBusiness__c createExperienciaNegocioSinInsert(){
		AV_ExperienceBusiness__c exp = new AV_ExperienceBusiness__c();
		exp.AV_Negocio__c = 'BPA';
		exp.AV_Activo__c = true;
		exp.AV_Orden__c = 1;
		exp.AV_MyBox__c = true;
		exp.AV_CodigoTipoExperiencia__c = '001';
		exp.AV_DescTipoExperiencia__c = 'Día a día';
		exp.AV_ExternalID__c = 'BPA001';
		return exp;
	}
	
	public static AV_ProductClient__c createPFCliente(){
		AV_ProductClient__c prodCliente = new AV_ProductClient__c();
		RecordType rt = AV_AppUtilities.getRecordType('AV_ProductClient__c', 'AV_ProductoFichaCliente');
		prodCliente.RecordTypeId = rt.Id;
		prodCliente.AV_Activo__c = true;
		prodCliente.AV_TenenciaProducto__c = '1';
		prodCliente.AV_Potencialidad__c = 'S';
		insert prodCliente;
		return prodCliente;
	}

	public static AV_ProductClient__c createPFClienteSinInsert(){
		AV_ProductClient__c prodCliente = new AV_ProductClient__c();
		RecordType rt = AV_AppUtilities.getRecordType('AV_ProductClient__c', 'AV_ProductoFichaCliente');
		prodCliente.RecordTypeId = rt.Id;
		prodCliente.AV_Activo__c = true;
		prodCliente.AV_TenenciaProducto__c = '1';
		prodCliente.AV_Potencialidad__c = 'S';
		return prodCliente;
	}

public static AV_ProductExperience__c createPFExperienceSinInsert(){
		AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
		prodExp.AV_ExternalID__c = 'BPA004_50003';
		return prodExp;
	}
	
	public static Task createTareaOtherExternalID(User user){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}       
		tarea.Status = 'Pendiente no localizado';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928363';
		tarea.RecordTypeId = rt.Id;
		tarea.ActivityDate = System.today()-3;
		insert tarea;
		return tarea;
	}
	
	public static Task createTareaExternalId(User user, String externalId){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}       
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		insert tarea;
		return tarea;
	}

	public static Task createTareaExternalIdSinInsert(User user, String externalId){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}       
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		return tarea;
	}

	public static Task createTareaExternalIdWithCustomer(User user, String externalId, Account acc){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		insert tarea;
		return tarea;
	}
	
	public static Task createTareaExternalIdWithCustomerSinInsert(User user, String externalId, Account acc){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		//insert tarea;
		return tarea;
	}

	public static Task createTareaExternalIdCustomStatusWithCustomer(User user, String externalId, Account acc, String customStatus){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = customStatus;
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		insert tarea;
		return tarea;
	}

	public static Task createTareaWithRTSinInsert(User user, String externalId, Account acc, RecordType rt){
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		return tarea;
	}

	public static Task createTareaWithRT(User user, String externalId, Account acc, RecordType rt){
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		insert tarea;
		return tarea;
	}
    
    public static Task createTareaExternalIdCustomStatusWithCustomerSinInsert(User user, String externalId, Account acc, String customStatus){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = customStatus;
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}       
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		
		return tarea;
	}
	
	public static Event createEventExternalId(User user, Datetime activityDate, String externalId, Account acc){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		if(String.isNotBlank(externalId)){
			event.AV_ExternalID__c = externalId;
		}
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.WhatId = acc.Id;
		insert event;
		return event;
	}

	public static Event createEventExternalIdSinInsert(User user, Datetime activityDate, String externalId, Account acc){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		if(String.isNotBlank(externalId)){
			event.AV_ExternalID__c = externalId;
		}
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.WhatId = acc.Id;
		return event;
	}
	
	public static Opportunity createOpportunityExternalId(Account acc, Contact empleado, String externalId){
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		if(String.isNotBlank(externalId)){
			opp.AV_ExternalID__c = externalId;
		}
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}
	
	public static Event createEventWithOpp(User user, Datetime activityDate, Opportunity opp, Account acc){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);

		Event event = new Event();
		event.Subject = 'Call';
		event.whatId = acc.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.AV_AssociatedOpportunityId__c = opp.Id;
		event.AV_Tipo__c = 'CTO';
		event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		insert event;
		return event;
	}

	public static Task createTareaWithOpp(Opportunity opp){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		tarea.OwnerId = UserInfo.getUserId();       
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		tarea.RecordTypeId = rt.Id;
		tarea.AV_AssociatedOpportunityId__c = opp.Id;
        tarea.AV_ExternalID__c = '12345';
		insert tarea;
		return tarea;
	}
	
	public static Opportunity createOpportunityIniciativaWithProduct(Account acc, Contact empleado, String externalId, Product2 producto){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.AV_ExternalID__c = externalId;
		opp.Name = 'Opp Iniciativa';
		opp.StageName = 'Potencial';
		if (producto != null) {
			opp.AV_PF__c = producto.Id;
		}else {
			Product2 prodPF = AV_TestHelper.createProduct(null,null);
			opp.AV_PF__c = prodPF.Id;
		}
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_FechaProximoRecordatorio__c = System.today();
		return opp;
	}

	public static AV_Book__c createPurse(String externalId){
		AV_Book__c book  = new AV_Book__c();
		book.AV_ExternalID__c = externalId;
		book.AV_Activa__c = 'S';
		insert book;
		return book;
	}

	public static AV_BookManagementMember__c createBookManagement(Contact empleado, AV_Book__c bk){
		AV_BookManagementMember__c bookMemb  = new AV_BookManagementMember__c();
		bookMemb.AV_EmpleadoGestor__c = empleado.Id;
		bookMemb.AV_Cartera__c = bk.Id;
		insert bookMemb;
		return bookMemb;
	}

	public static AV_BookMember__c createBookMember(Account cliente, AV_Book__c bk){
		AV_BookMember__c bookm  = new AV_BookMember__c();
		bookm.AV_Cliente__c = cliente.Id;
		bookm.AV_Cartera__c = bk.Id;
		bookm.AV_CarteraPrincipal__c = true;
		bookm.AV_Activa__c = 'S';
		insert bookm;
		return bookm;
	}

	public static Pricebook2 createPricebook2() {
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		return pb;
	}

	public static AV_ManagementHistory__c createManagementHistory(Task tarea, Date fecha, Datetime hora) {
		AV_ManagementHistory__c historial = new AV_ManagementHistory__c (
			AV_ActivityId__c = tarea.id, 
			AV_Comment__c = 'Prueba historial de gestion',
			AV_Status__c = 'Gestionada positiva',
			AV_Date__c = fecha,
			AV_Reminder__c = hora
		);

		insert historial;
		return historial;
	}

	public static AV_ManagementHistory__c createManagementHistoryWithOwner(Task tarea, Date fecha, Datetime hora, User us) {
		AV_ManagementHistory__c historial = new AV_ManagementHistory__c (
			OwnerId = us.Id,
			AV_ActivityId__c = tarea.id, 
			AV_Comment__c = 'Prueba historial de gestion',
			AV_Status__c = 'Gestionada positiva',
			AV_Date__c = fecha,
			AV_Reminder__c = hora
		);

		insert historial;
		return historial;
	}
	
	public static void createForbiddenWords(){
		List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
		CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
		listDummyWords.add(word);
		CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
		listDummyWords.add(word2);
		Database.insert(listDummyWords, false);
	}

	public static Campaign createCampaign(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
		Id rtEventoMember = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			EV_ExternalId__c = '234567890',
			RecordTypeId = rtEvento,
			StartDate = Date.today(),
			EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(19, 30, 00, 00),
			EV_ChatEvento__c = true,
			EV_URLDelEventoVirtual__c = 'test.prueba.com',
			EV_URLImagenVideo__c = 'test.prueba.com',
			EV_URLChatVirtual__c = 'test.prueba.com',
			EV_NumeroDePlazas__c = 100,
			EV_Cartera__c = 'BPA',
			CampaignMemberRecordTypeId = rtEventoMember


		); 
		
		insert campVirtual;
		
		return campVirtual;
	}


	public static CampaignMember createCampaignMemberContact(){
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		CampaignMember campMember = new CampaignMember();
		campMember.ContactId = createContactAux('Test Contact').Id;
		campMember.CampaignId = createCampaign().Id;
		campMember.EV_ExternalId__c = '123456789';
		campMember.status = 'Pendiente';
		insert campMember;
		
		return campMember;
	}

	public static Contact createContactAux(String lastName){
		Contact contactAux;
		if(lastName != null){
			contactAux = new Contact(LastName = lastName, CC_Numero_Documento__c = '48133877Y', CC_Sexo__c = 'V');
		}else{
			contactAux = new Contact(LastName = 'TestContact', CC_Numero_Documento__c = '48133877Y', CC_Sexo__c = 'V');
		}
		
		insert contactAux;
		
		return contactAux;
	}

	public static Centro_Objetivo__c createCentroObjetivo(){
		Centro_Objetivo__c centroAux = new Centro_Objetivo__c();
		centroAux.EV_Centro__c= createCaixaCenter().Id;
		centroAux.EV_Campaign__c= createCampaign().Id;
		insert centroAux;
		return centroAux;
	}
	
	public static Lead createLead(){
		RecordType rt = AV_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');
		Lead le = new Lead();
		le.LastName= 'Last name 1';
		le.FirstName= 'First name 1';
		le.RecordTypeId=rt.Id;
		le.AV_Birthdate__c=Date.newInstance(1968, 12, 9);
		le.AV_IssuingCountry__c='ESP';
		le.AV_CustomerId__c='00000000Z';
		le.AV_CustomerType__c='1';
		le.AV_Requester__c=true;
		le.AV_IsClient__c=false;
		le.AV_PhonePrefix__c='34';
		le.AV_Country__c='ESP';
		le.MobilePhone='000000000';
		insert le;
		return le;
	}
    
    public static Lead createLeadSinInsert(RecordType rt){
		//RecordType rt = AV_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');
		Lead le = new Lead();
		le.LastName= 'Last name 1';
		le.FirstName= 'First name 1';
		le.RecordTypeId=rt.Id;
		le.AV_Birthdate__c=Date.newInstance(1968, 12, 9);
		le.AV_IssuingCountry__c='ESP';
		le.AV_CustomerId__c='00000000Z';
		le.AV_CustomerType__c='1';
		le.AV_Requester__c=true;
		le.AV_IsClient__c=false;
		le.AV_PhonePrefix__c='34';
		le.AV_Country__c='ESP';
		le.MobilePhone='666354876';
		return le;
	}
    
	
	public static AV_LeadOpportunity__c createLeadOpportunity(Lead le){
		RecordType rt = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', 'AV_PlataformasHipotecarias');
		AV_LeadOpportunity__c leadopp = new AV_LeadOpportunity__c();
		leadopp.AV_CustomerOfferId__c = '0000000';
		leadopp.AV_ExternalId__c = '00dds0df';
		leadopp.AV_PrescriberId__c = 'RASTREATOR COMPARADOR CORREDURIA DE SEGUROS';
		leadopp.AV_Status__c='Nuevo';
		leadopp.AV_StatusLeadOpp__c = 'Potencial';
		leadopp.AV_Lead__c=le.Id;
		leadopp.AV_DueDate__c=Date.newInstance(2070, 01, 01);
		insert leadopp;
		return leadopp;
	}
    
    public static AV_LeadOpportunity__c createLeadOpportunitySinInsert(Lead le, RecordType rt){
		//RecordType rt = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', 'AV_PlataformasHipotecarias');
		AV_LeadOpportunity__c leadopp = new AV_LeadOpportunity__c();
		leadopp.AV_CustomerOfferId__c = '0000000';
		leadopp.AV_ExternalId__c = '00dds0df';
		leadopp.AV_PrescriberId__c = 'RASTREATOR COMPARADOR CORREDURIA DE SEGUROS';
		leadopp.AV_Status__c='Nuevo';
		leadopp.AV_StatusLeadOpp__c = 'Potencial';
		leadopp.AV_Lead__c=le.Id;
		leadopp.AV_DueDate__c=Date.newInstance(2070, 01, 01);
		return leadopp;
	}
	
	public static AV_LeadOpportunity__c createRejectedLeadOpportunitySinInsert(Lead le){
		RecordType rt = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', 'AV_PlataformasHipotecarias');
		AV_LeadOpportunity__c leadopp = new AV_LeadOpportunity__c();
		leadopp.AV_CustomerOfferId__c = '0000000';
		leadopp.AV_ExternalId__c = '00dds0df';
		leadopp.AV_PrescriberId__c = 'RASTREATOR COMPARADOR CORREDURIA DE SEGUROS';
		leadopp.AV_Status__c='02';
		leadopp.AV_Lead__c=le.Id;
		return leadopp;
	}
	public static User createUserSinGestorSinInsert(String name){
		profile pfl = [SELECT id FROM profile where name = 'API Only' LIMIT 1];
		String username = getEmail();
		String matricula = MATRICULA_SAMPLE;
		User u = new User(
				Alias = 'AV-TF9',
				Email = 'singestor@test.dev',
				EmailEncodingKey = 'UTF-8',
				LastName = Name,
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es',
				TimeZoneSidKey = 'Europe/Berlin',
				AV_NumeroOficinaEmpresa__c = '001-03044',
				ProfileId = pfl.Id,
				UserName = username,
				AV_ExternalID__c = matricula
			);
		return u;
	}

	public static void insertNeededPermissions(User u){
		List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();

		Set<String> SetPermiss = new Set<String>{
			AV_AppConstants.PS_GESTORESCRITURA,
			AV_AppConstants.PS_GESTORTABS,
			AV_AppConstants.PS_GESTOROPERATIVA,
			AV_AppConstants.PS_GESTOROPERATIVAESCRITURA,
			AV_AppConstants.PS_CUSTOMERINTOUCH, 
			AV_AppConstants.PS_CAMBIO_GESTOR_PROCESOS,
			AV_AppConstants.PS_ORGANIZADOREVENTOS
			
		};

		Set<String> SetPermissGroup = new Set<String>{
			AV_AppConstants.PS_EXTERNO, 
			AV_AppConstants.PS_GESTOR,
			AV_AppConstants.PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS};

		List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name =:SetPermiss];

		List<PermissionSetGroupComponent> unitaryPs = [SELECT Id, PermissionSetGroupId,
			PermissionSetId, PermissionSet.Name from PermissionSetGroupComponent 
			WHERE PermissionSetGroup.DeveloperName  IN :SetPermissGroup];

		for(PermissionSetGroupComponent psgc : unitaryPs){
			if(!perSet.contains(new PermissionSet(Id = psgc.PermissionSetId))){

				perSet.add(new PermissionSet(Id = psgc.PermissionSetId));
			}
		}
		for(PermissionSet ps: perSet){
			PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
			permissionSetList.add(pa);
		}
		insert permissionSetList;	
	}

	public static void insertNeededPermissions2(User u){
		List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();

		Set<String> SetPermiss = new Set<String>{
			AV_AppConstants.PS_GESTORESCRITURA,
			AV_AppConstants.PS_GESTORTABS,
			AV_AppConstants.PS_GESTOROPERATIVA,
			AV_AppConstants.PS_GESTOROPERATIVAESCRITURA,
			AV_AppConstants.PS_CUSTOMERINTOUCH, 
			AV_AppConstants.PS_CAMBIO_GESTOR_PROCESOS
			
		};

		Set<String> SetPermissGroup = new Set<String>{
			AV_AppConstants.PS_EXTERNO, 
			AV_AppConstants.PS_GESTOR,
			AV_AppConstants.PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS};

		List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name =:SetPermiss];

		List<PermissionSetGroupComponent> unitaryPs = [SELECT Id, PermissionSetGroupId,
			PermissionSetId, PermissionSet.Name from PermissionSetGroupComponent 
			WHERE PermissionSetGroup.DeveloperName  IN :SetPermissGroup];

		for(PermissionSetGroupComponent psgc : unitaryPs){
			if(!perSet.contains(new PermissionSet(Id = psgc.PermissionSetId))){

				perSet.add(new PermissionSet(Id = psgc.PermissionSetId));
			}
		}
		for(PermissionSet ps: perSet){
			PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
			permissionSetList.add(pa);
		}
		insert permissionSetList;	
	}
}