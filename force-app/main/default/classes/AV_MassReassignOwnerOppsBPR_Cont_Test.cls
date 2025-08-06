/**********************************************************************************************************************
Name:	  AV_MassReassignOwnerOppsBPR_Cont_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "AV_MassReassignOwnerOppsBPR_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
    1.0			US692335			   Elisabeth R.		    16/10/2023		Init version
    1.1         Fix                    Elisabeth R.         11/09/2023      Added assignTest method  
***********************************************************************************************************************/
@isTest
public with sharing class AV_MassReassignOwnerOppsBPR_Cont_Test {
      
    @TestSetup
	static void setup(){
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        AV_TestHelper.activateLogger();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
        User usrOtraOficina = new User(
            AV_ExternalID__c = 'U0009826',
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '12345',
            ProfileId = p.Id,
            UserName = 'test@test.dev.devsfc01',
            IsActive = true
        );
        //insert usrOtraOficina;
        User usrTestApiOnly = AV_TestHelper.createUserSinInsert('API Only', null);
        User usrMiOficina = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank', null);
        usrMiOficina.AV_NumeroOficinaEmpresa__c = '13297'; //used in searchTestMiOficina
        insert new List<User>{usrOtraOficina, usrMiOficina, usrTestApiOnly};

		Account accTest = AV_TestHelper.createCustomerSinInsert();
		Account cenTest = AV_TestHelper.createCaixaCenterSinInsert();
        insert new List<Account>{accTest, cenTest};
		Contact conTest = AV_TestHelper.createEmployeeSinInsert(cenTest, usrOtraOficina);
        Contact conTest2 = AV_TestHelper.createEmployeeSinInsert(cenTest,usrMiOficina);
        insert new List<Contact>{conTest,conTest2};
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		      
		
	} 
    
	@isTest
	public static void getBaseDataOppsNullTest() {

        AV_MassReassignOwnerOppsBPR_Controller.ObjectList ol = new AV_MassReassignOwnerOppsBPR_Controller.ObjectList();
        String clientFilter = null;
        String subjectFilter = null;
        String origenFilter = 'AV_Iniciativa';
        String statusFilter = null;
        Date dueDate2Filter = null;
        Date dueDateFilter = null;
        List<String> employeeFilter = new List<String>();
        String[] filterList = null;
        Date fechaGestionFilter = null;
        Date fechaCierreFilter = null;
        String myBoxFilter = null;
        Boolean preconceivedFilter = null;
        String targetAutoFilter = null;
        String office = null;
        String potencial = null;
        Date fechaModif = null;
        List<String> indicadoresCli = new List<String>();
        String page = '1'; //needed for pagination
        List<User> usuario  = [Select Id,ProfileId From User LIMIT 3];
        Set<String> userIDs = new Set<String>();
        for(User u :usuario){
            userIDs.add(u.id);
        }
        employeeFilter.addAll(userIDs);
        
 		Test.startTest();   
        ol = AV_MassReassignOwnerOppsBPR_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
       	System.assertEquals(true,ol.recordList.isEmpty(), 'getBaseDataOppsNullTest');
         ol = AV_MassReassignOwnerOppsBPR_Controller.getBaseData(clientFilter, subjectFilter, 'all', statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
        Test.stopTest();
    }

    /**
     * Made to improve coverage
     */
    @isTest
	public static void getBaseDataOppsDatosTest() {
        Account a = [SELECT Id FROM Account LIMIT 1];
        AV_MassReassignOwnerOppsBPR_Controller.ObjectList ol = new AV_MassReassignOwnerOppsBPR_Controller.ObjectList();
        String objectName='Opportunity';
        String clientFilter = a.Id;
        String subjectFilter = 'Opp Iniciativa';
        String origenFilter = 'AV_Iniciativa';
        String statusFilter = 'En gestión/insistir';
        Date dueDate2Filter = null;
        Date dueDateFilter = null;
        String[] filterList = null;
        List<String> employeeFilter = new List<String>();
        Date fechaGestionFilter = System.today();
        Date fechaCierreFilter = System.today();
        String myBoxFilter = null;
        Boolean preconceivedFilter = null;
        String targetAutoFilter = null;
        String office = '123';
        String potencial = null;
        Date fechaModif = null;
        List<String> indicadoresCli = new List<String>();
        String page = '1'; //needed for pagination
        Test.startTest();
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'Empleado' LIMIT 1];
        
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        employeeFilter.add(usuGcf.Id);
        
        System.RunAs(usuGcf){
            Product2 prodPF = AV_TestHelper.createProduct(null,null);
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = a.Id;
            opp.AV_ExternalID__c = '00000001';
            opp.Name = 'Opp Iniciativa';
            opp.StageName = 'En gestión/insistir';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today();
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
            opp.AV_FechaProximoRecordatorio__c = System.today();
            opp.AV_Center__c = '123';
		    opp.AV_PF__c = prodPF.Id;
            insert opp;
        }
        ol = AV_MassReassignOwnerOppsBPR_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
        System.assertEquals(true, ol!=null, 'getBaseDataOppsDatosTest');
        Test.stopTest();
    } 

    
   

  
    @isTest
    public static void gcfUserInGetBaseData() {
        String gcfId = (String) [SELECT Id FROM USER WHERE Alias = 'AV-TF9' LIMIT 1].Id;
        AV_MassReassignOwnerOppsBPR_Controller.ObjectList ol = new AV_MassReassignOwnerOppsBPR_Controller.ObjectList();
        String objectName='Task';
        String clientFilter = null;
        String subjectFilter = null;
        String origenFilter = 'AV_Iniciativa';
        String statusFilter = null;
        Date dueDate2Filter = null;
        Date dueDateFilter = null;
        String[] filterList = null;
        List<String> employeeFilter = new List<String>();
        employeeFilter.add(gcfId);
        Date fechaGestionFilter = null;
        Date fechaCierreFilter = null;
        String myBoxFilter = null;
        Boolean preconceivedFilter = null;
        String targetAutoFilter = null;
        String office = null;
        String potencial = null;
        Date fechaModif = null;
        List<String> indicadoresCli = new List<String>();

        String page = '1'; //needed for pagination
        Test.startTest();
        ol = AV_MassReassignOwnerOppsBPR_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
        System.assertEquals(true, ol.recordList.isEmpty(), 'gcfUserInGetBaseData');
        Test.stopTest();
    }
  
    
     @isTest
	public static void assignTest() {
           
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        
        String objectName='Opportunity';
        User usuario  = [Select Id From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        
        Contact cont = [SELECT Id from Contact where AV_UsuarioAsociado__c =: usuario.Id limit 1];
        
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Account a = [SELECT Id FROM Account LIMIT 1];

         System.RunAs(usuGcf){
            Product2 prodPF = AV_TestHelper.createProduct(null,null);
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = a.Id;
            opp.AV_ExternalID__c = '00000001';
            opp.Name = 'Opp Iniciativa';
            opp.StageName = 'En gestión/insistir';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today();
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa';
            opp.AV_FechaProximoRecordatorio__c = System.today();
            opp.AV_Center__c = '123';
		    opp.AV_PF__c = prodPF.Id;
            insert opp;
        }
        
        Opportunity oppToUpdate = [SELECT Id FROM Opportunity WHERE AV_ExternalID__c = '00000001'];
        
        List<String> oppIdsList = new List<String>();
        oppIdsList.add(oppToUpdate.Id);

        Test.startTest();
        System.runAs(userPass) {

        	String oppsSize =  AV_MassReassignOwnerOppsBPR_Controller.assign(objectName, cont.Id , oppIdsList);

        System.assertEquals('1', oppsSize);
        }
       	Test.stopTest();
    }
  
}