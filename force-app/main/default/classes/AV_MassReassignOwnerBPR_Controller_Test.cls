/**********************************************************************************************************************
Name:	  AV_MassReassignOwnerBPR_Controller_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "AV_MassReassignOwnerBPR_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
   	1.0			US692335			    Elisabeth R.		16/10/2023		Init version
    1.1         Fix                     Elisabeth R.        11/09/2023      Added assignTest method  

***********************************************************************************************************************/
@isTest
public with sharing class AV_MassReassignOwnerBPR_Controller_Test {
  
    @TestSetup
	static void setup(){
        
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        AV_TestHelper.activateLogger();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        
        
        List<User> usersList = new List<User>();
        User usrOtraOficina = new User(
            AV_ExternalID__c = 'U0009826',
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',//12345
            ProfileId = p.Id,
            UserName = 'test@test.dev.devsfc01',
            IsActive = true,
            AV_Funcion__c = 'DT'
        );
        User usrMiOficina;
        System.runAs(userGcf){
            usersList.add(usrOtraOficina);
            usrMiOficina = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','');
            usrMiOficina.AV_NumeroOficinaEmpresa__c = '13297'; //used in searchTestMiOficina
            usersList.add(usrMiOficina);
            Account accTest = AV_TestHelper.createCustomer(); 
            User usrTestApiOnly = AV_TestHelper.createUserSinInsert('API Only','');
            usersList.add(usrTestApiOnly);
            insert usersList;
         
            Account cenTest = AV_TestHelper.createCaixaCenter();
            Contact conTest = AV_TestHelper.createEmployeeSinInsert(cenTest, usrOtraOficina);
            Contact usrMiOtraOfincaCnt = AV_TestHelper.createEmployeeSinInsert(cenTest,usrMiOficina);
            insert new List<Contact>{conTest,usrMiOtraOfincaCnt};

        
        }

	}   
  
	@isTest
	public static void getBaseDataTaskDatosTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User usuario  = [Select Id, AV_NumeroOficinaEmpresa__c From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        Test.startTest();
    
        AV_TestHelper.insertNeededPermissions(usuario);
        AV_MassReassignOwnerBPR_Controller.ObjectList listTasks;
        Task tsk = new Task();
        
        System.runAs(usuario){
            AV_MassReassignOwnerBPR_Controller.ObjectList ol = new AV_MassReassignOwnerBPR_Controller.ObjectList();
            String objectName='Task';
            String[] statusFilter = new String[]{'Open'};
            String page = '1'; //needed for pagination
            tsk = AV_TestHelper.createTarea(usuario);
            tsk.OwnerId = usuario.Id;
            String[] employeeFilter = new String[]{usuario.Id};
            List<Task> listTask = [SELECT AV_CenterRtIndex__c, OwnerId FROM Task WHERE Id = :tsk.id];
            listTasks =  AV_MassReassignOwnerBPR_Controller.getBaseData(objectName, null, null, 'Iniciativa Gestor/a', statusFilter, null, null, employeeFilter, null, null, null, page, null, null, null, usuario.AV_NumeroOficinaEmpresa__c);
        }
        Test.stopTest();
        System.assertEquals(true, !listTasks.isEmpty(), 'getBaseDataOppsDatosTest');
    }   


    @isTest
    public static void gcfUserOnlyInGetBaseData() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){

        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Iniciativa Gestor/a').getRecordTypeId();

        User gcf = [SELECT ID FROM USER WHERE ALIAS = 'AV-TF9' LIMIT 1];
        String gcfId = (String) gcf.Id;
        AV_MassReassignOwnerBPR_Controller.ObjectList ol = new AV_MassReassignOwnerBPR_Controller.ObjectList();
        String objectName='Task';
        Account acc = AV_TestHelper.createCustomerSinInsert();
        Account center = AV_TestHelper.createCaixaCenterSinInsert();
        center.CC_Numero_Oficina__c = '93124';
        center.Name = 'centro test';
		center.CC_Numero_Oficina_Empresa__c = '001-93124';
        insert center;
        acc.AV_MyBox__c = 'S';
        acc.AV_IsPreconceived__c = false;
        acc.AV_TargetAuto__c = 'S';
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
        acc.FirstName = 'FirstName3';
		acc.LastName = 'LastName3';
		acc.RecordTypeId = rt.Id;
		acc.AV_NumPerso__c = '121';
		acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '1446382T';
        acc.AV_OficinaPrincipal__c= center.id;
        Database.insert(acc);
        Task tskToRetrieve = AV_TestHelper.createTarea(gcf);
        tskToRetrieve.AV_Center__c = '93124';
        tskToRetrieve.WhatId = acc.Id;
        tskToRetrieve.status = 'Open';
        tskToRetrieve.AV_CenterRtIndex__c = '93124-' + taskRecordTypeId;
        Database.update(tskToRetrieve);
        String page = '1'; //needed for pagination
        String[] employeeFilter = new String[]{gcfId};
        String[] statusFilter = new String[]{'Open'};
       	ol = AV_MassReassignOwnerBPR_Controller.getBaseData(objectName, null, null, 'Iniciativa Gestor/a', statusFilter, null, null, employeeFilter, null, null, null, page, 'S', false, 'S','93124');
        System.assertEquals(true, !ol.isEmpty(), 'gcfUserInGetBaseData');
        }
        Test.stopTest();
    }

    @isTest
    public static void gcfUserInGetBaseData() {

        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Iniciativa Gestor/a').getRecordTypeId();

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
        User usuario  = [Select Id From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        String gcfId = (String) [SELECT ID FROM USER WHERE ALIAS = 'AV-TF9' LIMIT 1].Id;
        AV_MassReassignOwnerBPR_Controller.ObjectList ol = new AV_MassReassignOwnerBPR_Controller.ObjectList();
        Task tskToRetrieve = AV_TestHelper.createTarea(userGcf);
        Account acc = AV_TestHelper.createCustomerSinInsert();
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
        acc.AV_IsPreconceived__c = true;
                acc.FirstName = 'FirstName1';
				acc.LastName = 'LastName1';
				acc.RecordTypeId = rt.Id;
				acc.AV_NumPerso__c = '122';
				acc.AV_Negocio__c = 'BPA';
            	acc.CC_Numero_Documento__c = '9446382T';
        Database.insert(acc);
        tskToRetrieve.AV_Center__c = '00123';
        tskToRetrieve.subject = 'Tarea';
        tskToRetrieve.activityDate = Date.today();
        tskToRetrieve.WhatId = acc.id;
        Database.update(tskToRetrieve);
        String objectName='Task';
        String page = '1'; //needed for pagination
        String[] employeeFilter = new String[]{gcfId,usuario.Id};
		String[] statusFilter = new String[]{'Open'};
       	ol = AV_MassReassignOwnerBPR_Controller.getBaseData(objectName, null, 'Tare', 'Iniciativa Gestor/a', statusFilter, Date.today().addDays(1), Date.today().addDays(-1), employeeFilter, null, null, null, page, 'N', true, 'N', '00120');
		Test.stopTest();
        System.assertEquals(false, !ol.isEmpty(), 'gcfUserInGetBaseData');
        }
    }
 
    @isTest
	public static void getBaseDataNotAssigned() {
           
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        AV_MassReassignOwnerBPR_Controller.ObjectList ol = new AV_MassReassignOwnerBPR_Controller.ObjectList();
        String objectName='Task';
        String[] statusFilter = new String[]{'Open'};
        User usuario  = [Select Id From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        String page = '1'; //needed for pagination
        Task tsk = AV_TestHelper.createTarea(usuario);
        String[] employeeFilter = new String[]{usuario.Id};
        Test.startTest();
        System.runAs(userPass) {

        	AV_MassReassignOwnerBPR_Controller.ObjectList listTasks =  AV_MassReassignOwnerBPR_Controller.getBaseData(objectName, null, null, 'notAssigned', statusFilter, null, null, employeeFilter, null, null, null, page, null, null, null, null);

        System.assertEquals(false, !listTasks.isEmpty(), 'getBaseDataNotAssigned');
        }
       	Test.stopTest();
    } 
    
    @isTest
	public static void assignTest() {
           
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        
        String objectName='Task';
        User usuario  = [Select Id From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        
        Contact cont = [SELECT Id from Contact where AV_UsuarioAsociado__c =: usuario.Id limit 1];
        
        Task tsk = AV_TestHelper.createTarea(userPass);
        List<String> taskIdsList = new List<String>();
        taskIdsList.add(tsk.Id);
        Test.startTest();
        System.runAs(userPass) {

        	String tasksSize =  AV_MassReassignOwnerBPR_Controller.assign(objectName, cont.Id , taskIdsList);

        System.assertEquals('1', tasksSize);
        }
       	Test.stopTest();
    }
    
}