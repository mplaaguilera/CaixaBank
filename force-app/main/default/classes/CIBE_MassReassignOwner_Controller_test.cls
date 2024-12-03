/**********************************************************************************************************************
Name:	  CIBE_MassReassignOwner_Controller_test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "CIBE_MassReassignOwner_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
    1.0         Home Custom             Luis Martínez     	09/01/2023      Init version
	2.0			US532487				Jose Maria			15/03/2023		Jerarquia CIB desde cartera cliente
	3.0			US571827				Jose Maria			23/03/2023		Nuevos campos Redes,Negocios,Sectores.
	4.0									Jose Maria			20/04/2023		Auto cálculo de jerarquía
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_MassReassignOwner_Controller_test {
    
    @TestSetup
	static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGes = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        Account cenTest = new Account();
        //List<Account> lstAcc = new List<Account>();
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
		string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
		string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
		string rtJerarquia = Schema.getGlobalDescribe().get('CIBE_Hierarchy__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CIBE_Employee').getRecordTypeId();
        
        
    System.runAs(new User(Id = UserInfo.getUserId())) {
        
        CBK_PicklistValues__c pick = new CBK_PicklistValues__c();
        pick.RecordTypeId = rtIdPick;
        pick.Name = 'Field Picklist';
        pick.CBK_Object__c = 'Object';
        insert pick;
        
        CBK_PicklistValues__c pick2 = new CBK_PicklistValues__c();
        pick2.RecordTypeId = rtIdPick;
        pick2.Name = 'Negocios';
        pick2.CBK_Object__c = 'Contact';
        pick2.CBK_Dependencies__c = 'Valor2;Opcion4;Opcion3';
        insert pick2;

        CBK_PicklistValues__c pick3 = new CBK_PicklistValues__c();
        pick3.RecordTypeId = rtIdPick;
        pick3.Name = 'Redes-Segmentos';
        pick3.CBK_Object__c = 'Contact';
        pick3.CBK_Dependencies__c = 'Valor2;Opcion4;Opcion3';
        insert pick3;

        CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
        pickVal.RecordTypeId = rtIdPickVal;
        pickVal.CBK_Picklist__c = pick.Id;
        pickVal.Name = 'Opcion1';
        pickVal.CBK_HasDependency__c = true;
        pickVal.CBK_Dependencies__c = 'Valor1';
        pickVal.CBK_ParentId__c = pick.Id;
        insert pickVal;

        
        CBK_PicklistValues__c pickVal2 = new CBK_PicklistValues__c();
        pickVal2.RecordTypeId = rtIdPickVal;
        pickVal2.CBK_Picklist__c = pick.Id;
        pickVal2.Name = 'Opcion2';
        pickVal2.CBK_HasDependency__c = true;
        pickVal2.CBK_Dependencies__c = 'Valor12';
        insert pickVal2;

        CBK_PicklistValues__c pickVal3 = new CBK_PicklistValues__c();
        pickVal3.RecordTypeId = rtIdPickVal;
        pickVal3.CBK_Picklist__c = pick2.Id;
        pickVal3.Name = 'Opcion3';
        pickVal3.CBK_HasDependency__c = true;
        pickVal3.CBK_Dependencies__c = 'Valor2;Negocios';
        insert pickVal3;

        CBK_PicklistValues__c pickVal4 = new CBK_PicklistValues__c();
        pickVal4.RecordTypeId = rtIdPickVal;
        pickVal4.CBK_Picklist__c = pick2.Id;
        pickVal4.Name = 'Opcion4';
        pickVal4.CBK_HasDependency__c = true;
        pickVal4.CBK_Dependencies__c = 'Valor2;Negocios';
        insert pickVal4;

        CBK_PicklistValues__c pickVal5 = new CBK_PicklistValues__c();
        pickVal5.RecordTypeId = rtIdPickVal;
        pickVal5.CBK_Picklist__c = pick2.Id;
        pickVal5.Name = 'Opcion5';
        pickVal5.CBK_Project__c = 'CIBE';
        pickVal5.CBK_HasDependency__c = true;
        pickVal5.CBK_ParentId__c = pick.Id;
        pickVal5.CBK_Dependencies__c = 'Valor2;Negocios';
        insert new List<CBK_PicklistValues__c>{pickVal5};
        
        CBK_PicklistValues__c pickVal6 = new CBK_PicklistValues__c();
        pickVal6.RecordTypeId = rtIdPickVal;
        pickVal6.CBK_Picklist__c = pick3.Id;
        pickVal6.Name = 'Valor2';
        pickVal6.CBK_Project__c = 'CIBE';
        pickVal6.CBK_HasDependency__c = true;
        pickVal6.CBK_Dependencies__c = 'Valor4';
        insert new List<CBK_PicklistValues__c>{pickVal6};
        
            
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];

        ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        List<Account> lstCen = new List <Account>();
            cenTest.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
            cenTest.CC_Numero_Oficina_Empresa__c = '00615';
            cenTest.CC_Numero_Oficina__c = '00615';
            cenTest.RecordTypeId = recordTypeCentro;
            cenTest.OwnerId = usuarioGe.Id;
        lstCen.add(cenTest);
        Account center2 = new Account(
            Name = '00803 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00803',
            CC_Numero_Oficina__c = '00803',
            RecordTypeId = recordTypeCentro,
            AV_CentroSuperior__c = cenTest.Id,
            CIBE_SectoresPaises__c = 'Energy',
            ownerId = usuarioGe.Id
        );
        lstCen.add(center2);
        insert lstCen;

        center2.AV_CentroSuperior__c = lstCen[0].Id;
        update center2;
        
        ID rtCon = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EMPLOYEE_RT).getRecordTypeId();
        Contact empleado = new Contact();
            empleado.RecordTypeId = rtCon;
            empleado.FirstName = 'Empleado 1';
            empleado.LastName = '1';
            empleado.CC_Idioma__c = 'es';
            empleado.CC_Matricula__c = usuarioGe.AV_ExternalId__c;
            empleado.CIBE_Sector__c = '001';
            empleado.CIBE_Cartera__c = '001';
            empleado.AccountId = lstCen[0].Id;
            empleado.AV_UsuarioAsociado__c = usuarioGe.Id;
            empleado.OwnerId = usuarioGe.Id;
        insert empleado;
        
        CIBE_Hierarchy__c jerarquia = new CIBE_Hierarchy__c();
            jerarquia.CIBE_Negocios__c = pickVal.Id;
            jerarquia.CIBE_RedesSegmentos__c = pickVal2.Id;
            jerarquia.CIBE_SectoresPaises__c = pickVal3.Id;
            jerarquia.CIBE_CentrosCarteras__c = pickVal4.Id;
            jerarquia.CIBE_Contact__c = empleado.Id;
            jerarquia.RecordTypeId = rtJerarquia;
        insert jerarquia;
            
        }

        System.runAs(usrGes) {
            ID rtCli = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.ACCOUNT_CLIENTE_RT).getRecordTypeId();
            ID rtConId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EMPLOYEE_RT).getRecordTypeId();
            List <Contact> conTest = [SELECT id FROM Contact WHERE RecordTypeId=:rtConId AND CC_Matricula__c ='U0009003' LIMIT 1];
            Account acc = new Account(
                Name = 'Test Name',
                RecordTypeId = rtCli,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'BPA',
                AV_EAPGestor__c = conTest[0].Id,
                ownerId = usrGes.Id
            );
            Account acc2 = new Account(
                Name = 'Test Name2',
                RecordTypeId = rtCli,
                AV_NumPerso__c = '1234',
                AV_Negocio__c = 'BPA',
                AV_EAPGestor__c = conTest[0].Id,
                ownerId = usrGes.Id
            );
            List<Account> lstCli = new List<Account>{acc,acc2};
            insert lstCli;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Task tsk = CIBE_TestHelper.createTareaOtherExternalID(usrGes);
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Boolean aux = false;
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT).getRecordTypeId();
            List<Task> tarea = [Select Id, OwnerId, owner.name, AccountId, WhatId From Task limit 10];
            RecordType rtCli2 = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            List <Account> acc2 = [Select Id, owner.Name From Account Where recordTypeId =:rtCli2.Id AND AV_NumPerso__c='123' limit 1];

            if(!tarea.isEmpty()){
                if(!tarea[0].OwnerId.equals(usrGes.Id)){
                    tarea[0].OwnerId = usrGes.Id;
                    aux= true;
                }
                if(!acc2.isEmpty() && (tarea[0].AccountId == null ||(tarea[0].AccountId !=null && !tarea[0].AccountId.equals(acc2[0].Id)))){
                    tarea[0].WhatId = acc2[0].Id;
                    aux = true;
                }
            }
            if(aux){update tarea;}
        }
    }

	@isTest
	public static void getBaseDataTaskDatosTest() {
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];

        System.runAs(usuarioG) {
            Test.startTest();
            CIBE_MassReassignOwner_Controller.ObjectList ol = new CIBE_MassReassignOwner_Controller.ObjectList();
            String[] statusFilter = new String[]{'Open'};
            String page = '1'; //needed for pagination
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT).getRecordTypeId();
            List<Task> tsk = [Select Id, accountId From Task WHERE AV_ExternalID__c = '01928363' AND recordTypeId =:taskRecordTypeId limit 1];
        
            String[] employeeFilter = new String[]{usuarioG.Id};
            CIBE_MassReassignOwner_Controller.ObjectList listTasks =  CIBE_MassReassignOwner_Controller.getBaseData(tsk[0].accountId, null, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, statusFilter, null, null, employeeFilter, page, '00939');
            System.assertEquals(false, !listTasks.isEmpty(), 'getBaseDataOppsDatosTest');
            CIBE_MassReassignOwner_Controller.ObjectList listTasks2 =  CIBE_MassReassignOwner_Controller.getBaseData(tsk[0].accountId, null, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, statusFilter, null, null, employeeFilter, page, null);
            System.assertEquals(false, !listTasks2.isEmpty(), 'getBaseDataOppsDatosTest');
            CIBE_MassReassignOwner_Controller.ObjectList listTasks3 =  CIBE_MassReassignOwner_Controller.getBaseData(tsk[0].accountId, null, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, statusFilter, null, null, employeeFilter, page, 'Alicante');
            System.assertEquals(false, !listTasks3.isEmpty(), 'getBaseDataOppsDatosTest'); 
            Test.stopTest();
        }
    }   
    
    @isTest
	public static void getBaseDataCIBTest() {
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            Test.startTest();
                CIBE_MassReassignOwner_Controller.ObjectList ol = new CIBE_MassReassignOwner_Controller.ObjectList();
                String[] statusFilter = new String[]{'Open'};
                String page = '1'; 
                Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT).getRecordTypeId();
                List<Task> tsk = [Select Id, accountId From Task WHERE AV_ExternalID__c = '01928363' AND recordTypeId =:taskRecordTypeId limit 1];
                String[] employeeFilter = new String[]{usuarioG.Id};
                CIBE_MassReassignOwner_Controller.ObjectList listTasks =  CIBE_MassReassignOwner_Controller.getBaseDataCIB(tsk[0].accountId, null, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, statusFilter, null, null, employeeFilter, page);
            Test.stopTest();
            System.assertEquals(false, !listTasks.isEmpty(), 'getBaseDataOppsDatosTest');
        }
    }   
    
    @isTest
	public static void picklistValuesTest() {
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            Test.startTest();
                List<CIBE_MassReassignOwner_Controller.PicklistItems> listValues = CIBE_MassReassignOwner_Controller.picklistValues('Negocios','Contact');
            Test.stopTest();         
            System.assert(!listValues.isEmpty());
        }
    }   
    
    @isTest
	public static void picklistValuesDependencyTest() {
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            Test.startTest();
                List<CBK_PicklistValues__c> listPicklist = [SELECT id, name FROM CBK_PicklistValues__c WHERE Name = 'Opcion4'];
                List<CIBE_MassReassignOwner_Controller.PicklistItems> listValues = CIBE_MassReassignOwner_Controller.picklistValuesDependency('Negocios',listPicklist[0].id,'Contact');
            Test.stopTest();         
            System.assert(!listValues.isEmpty());
        }
    }   
    
    @isTest
	public static void getAllvaluesByFieldTest() {
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
            string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
            List<CBK_PicklistValues__c> listPicklist = [SELECT id, name FROM CBK_PicklistValues__c WHERE recordTypeId = :rtIdPick AND Name = 'Field Picklist' AND CBK_Object__c ='Object' limit 1];
            List<CBK_PicklistValues__c> cbkPicklist = [SELECT id, name FROM CBK_PicklistValues__c WHERE recordTypeId = :rtIdPickVal AND Name ='Opcion1' AND CBK_Picklist__c =: listPicklist[0].Id limit 1];
            CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
                pickVal.RecordTypeId = rtIdPickVal;
                pickVal.CBK_Picklist__c = cbkPicklist[0].Id;
                pickVal.Name = 'Field Picklist child';
                pickVal.CBK_Project__c = 'CIBE';
                pickVal.CBK_HasDependency__c = false;
                pickVal.CBK_ParentId__c = listPicklist[0].Id;
                pickVal.CBK_Dependencies__c = '';
            insert pickVal;
            Test.startTest();
                List<CBK_PicklistValues__c> listValues = CIBE_MassReassignOwner_Controller.getAllvaluesByField('Field Picklist');
            Test.stopTest();         
            System.assert(!listValues.isEmpty());
        }
    }
    
    @isTest
	public static void getEmployeesCIBTest() {
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            Test.startTest();
                List<CIBE_MassReassignOwner_Controller.OptionsEmployee> listValues = CIBE_MassReassignOwner_Controller.getEmployeesCIB('', '', '', '', true);
            Test.stopTest();         
            System.assert(!listValues.isEmpty());
        }
    }   
    
	@isTest
	private static void getEmployeesTest() {
        List<CIBE_MassReassignOwner_Controller.optionsEmployee> employees = new List<CIBE_MassReassignOwner_Controller.optionsEmployee>();
        List<CIBE_MassReassignOwner_Controller.optionsEmployee> employees2 = new List<CIBE_MassReassignOwner_Controller.optionsEmployee>();
        List<CIBE_MassReassignOwner_Controller.optionsEmployee> employees3 = new List<CIBE_MassReassignOwner_Controller.optionsEmployee>();

        String ofi = '00615';
        String ofi2 = '00615{|}08161{|}Alerta Comercial CIB';
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            employees= CIBE_MassReassignOwner_Controller.getEmployees(ofi);
            System.assert(!employees.isEmpty());
            employees2= CIBE_MassReassignOwner_Controller.getEmployees(ofi2);  
            System.assert(!employees2.isEmpty());
            
        }
	}
    
    @isTest
	public static void searchTestMiOficina() {
		String searchTerm = 'test';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        List<Profile> p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank' LIMIT 1];
        UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = 'CIBE_CIBEmpresas' LIMIT 1];
        User usrOtraOficina = new User(
            UserRoleId = ur.Id,
            AV_ExternalID__c = 'U0009826',
            Alias = 'otototo',
            Email = 'ottest@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '13297',//12345
            ProfileId = p[0].Id,
            UserName = 'test@test.dev.devsfc01',
            IsActive = true,
            AV_Funcion__c = 'Gestor'
        );

        System.runAs(usuarioG) {
            User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = usuarioG.Id;
            lista.add(usuarioG.Id);
            lista.add(emp.Id);
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            listSearch = CIBE_MassReassignOwner_Controller.search(searchTerm, lista, true);
            System.assertEquals(true, listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
	}


    @isTest
	public static void searchTestOtraOficina() {
		String searchTerm = 'test';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            User empOtraOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c != '13297' LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = null;
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
                listSearch = CIBE_MassReassignOwner_Controller.search(searchTerm, lista, false);
                System.assertEquals(true, listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
	}
    
    @isTest
	public static void assignTaskTest () {
		List<List<SObject>> searchResults = new List<List<SObject>>();
        String objectName='Task';	
        String result = null;
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT).getRecordTypeId();
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        List<Task> listTask2 =[Select Id, OwnerId From Task WHERE RecordTypeId =:taskRecordTypeId limit 1];
        
        System.runAs(usuarioG) {
            Id taskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT).getRecordTypeId();
            List<Task> listTask =[Select Id From Task WHERE RecordTypeId =:taskRecordType limit 1];

            Test.startTest();
                result = CIBE_MassReassignOwner_Controller.assign(objectName, usuarioG.Id, listTask2);
            Test.stopTest();
            System.assertEquals(result,'1');
        }
    }
    
    @isTest
	public static void searchAccountTest(){
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            Test.startTest();
                List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
                List<String> lista = new List<String>();
                Set<String> setLabelsRts = new Set<String>{CIBE_AppConstants.ACCOUNT_CLIENTE_RT,'CC_ClientePA'}; 
                Set<Id> setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRts);

                List<Account> acc = [Select Id, Name From Account WHERE RecordTypeId IN :setIdsRts AND (AV_NumPerso__c = '1234' OR AV_NumPerso__c = '123') LIMIT 2];
                Id[] fixedSearchResults = new Id[1];
                fixedSearchResults[0] = acc.get(0).Id;

                Test.setFixedSearchResults(fixedSearchResults);
                    results = CIBE_MassReassignOwner_Controller.searchAccount(acc.get(0).Name,lista);
                    results = CIBE_MassReassignOwner_Controller.searchAccount(acc.get(0).Name,new List<String>{acc.get(1).Id});
            Test.stopTest();
            System.assert(!results.isEmpty());
        }
	}
    
    @isTest
    public static void nameContactAssignTest() {
        User usuarioG = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            Test.startTest();
                String resul= CIBE_MassReassignOwner_Controller.nameContactAssign(usuarioG.Id);
            Test.stopTest();
            System.assertNotEquals(null,resul);
        }
    }

    @isTest
    public static void getInferiorCenterIdsTest() {
        Set<Id> res = new Set<Id>();
        Test.startTest();
        User usuarioG = [SELECT Id, name, AV_NumeroOficinaEmpresa__c, AV_Funcion__c  FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];

        usuarioG.AV_NumeroOficinaEmpresa__c = '00615';
        usuarioG.AV_Funcion__c = 'DAN';
        update usuarioG;
        
        
        System.runAs(usuarioG) {
            res = CIBE_MassReassignOwner_Controller.getInferiorCenterIds();
        }
        
        Test.stopTest();
        System.assertEquals(false, res.isEmpty(), 'No ids retrieved');
    }

    @isTest
    public static void searchOfficeTest1() {
        List<AV_LookupSearchResult> res = new List<AV_LookupSearchResult>();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        User usuarioG = [SELECT Id, name, AV_NumeroOficinaEmpresa__c, AV_Funcion__c  FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];

        Account a = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00615' AND RecordTypeId = :rt.Id LIMIT 1];
        Account center2 = [SELECT Id,name,AV_CentroSuperior__c, RecordTypeId, CC_Numero_Oficina_Empresa__c FROM Account WHERE CC_Numero_Oficina__c = '00803'AND RecordTypeId = :rt.Id LIMIT 1];
        usuarioG.AV_NumeroOficinaEmpresa__c = '00615';
        usuarioG.AV_Funcion__c = 'DAN';
        update usuarioG;

        Id[] fixedSearchResults = new Id[]{center2.Id};
        // SOSL queries need fixed results in order to retrieve data
        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        // Director
        System.runAs(usuarioG) {
            res = CIBE_MassReassignOwner_Controller.searchOffice('00803', new List<String>{a.Id});
        }
        Test.stopTest();
        System.assert(!res.isEmpty());
    }
    @isTest
    public static void searchOfficeTest2() {
        List<AV_LookupSearchResult> res = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        User usuarioG = [SELECT Id, name, AV_NumeroOficinaEmpresa__c, AV_Funcion__c  FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00615' AND RecordTypeId = :rt.Id LIMIT 1];
        Account center2 = [SELECT Id,name,AV_CentroSuperior__c, RecordTypeId, CC_Numero_Oficina_Empresa__c FROM Account WHERE CC_Numero_Oficina__c = '00803'AND RecordTypeId = :rt.Id LIMIT 1];
        usuarioG.AV_NumeroOficinaEmpresa__c = '00615';
        usuarioG.AV_Funcion__c = 'Gestor';
        update usuarioG;

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = center2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        // Gestor
        System.runAs(usuarioG) {
            res = CIBE_MassReassignOwner_Controller.searchOffice('00804', lista);
        }
        Test.stopTest();
        System.assert(!res.isEmpty());
        
    }

    @isTest
    public static void searchOfficeTest3() {
        List<AV_LookupSearchResult> res = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        User usuarioG = [SELECT Id, name, AV_NumeroOficinaEmpresa__c, AV_Funcion__c  FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00615' AND RecordTypeId = :rt.Id LIMIT 1];
        Account center2 = [SELECT Id,name,AV_CentroSuperior__c, RecordTypeId, CC_Numero_Oficina_Empresa__c FROM Account WHERE CC_Numero_Oficina__c = '00803'AND RecordTypeId = :rt.Id LIMIT 1];
        usuarioG.AV_NumeroOficinaEmpresa__c = '00615';
        usuarioG.AV_Funcion__c = 'SSCC';
        update usuarioG;

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = center2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.startTest();
        Test.setFixedSearchResults(fixedSearchResults);
        // SSCC
        System.runAs(usuarioG) {
            res = CIBE_MassReassignOwner_Controller.searchOffice('00804', lista);
        }
        Test.stopTest();
        System.assert(!res.isEmpty());
        
    }
    
    @isTest
    public static void getCenterIdsTest() {
        List<Id> res = new List<Id>();
        User usuarioG = [SELECT Id, name, AV_NumeroOficinaEmpresa__c  FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];

        System.runAs(usuarioG) {
            ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            List<Account> accs = [SELECT Id FROM Account where recordTypeId =:recordTypeCentro];
            Test.startTest();
                res = CIBE_MassReassignOwner_Controller.getCenterIds(accs);
            Test.stopTest();
            System.assertEquals(false, res.isEmpty(),'No ids returned');
        }
    }
    
    @isTest
    public static void picklistValuesUserLoginTest() {
        List<Id> res = new List<Id>();
        User usuarioG = [SELECT Id, name, AV_NumeroOficinaEmpresa__c  FROM User WHERE profile.name = 'CIBE_Gestor' AND Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009003' AND CreatedDate = TODAY AND createdById =:UserInfo.getUserId()  LIMIT 1];
        System.runAs(usuarioG) {
            Test.startTest();
            CIBE_MassReassignOwner_Controller.PicklistHierarchy listHierarchy= CIBE_MassReassignOwner_Controller.picklistValuesUserLogin(usuarioG.Id);
            Test.stopTest();
            System.assertEquals(true, listHierarchy.idNegocio!=null, 'No ids returned');
            System.assertEquals(true, listHierarchy.idRedes!=null, 'No ids returned');
            System.assertEquals(true, listHierarchy.idSector!=null, 'No ids returned');
            System.assertEquals(true, listHierarchy.idCentro!=null, 'No ids returned');
        }
    }

}