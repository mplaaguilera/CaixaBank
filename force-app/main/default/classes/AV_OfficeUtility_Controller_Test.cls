/**********************************************************************************************************************
Name:	  AV_OfficeUtility_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "AV_OfficeUtility_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
    1.0			US377920   		        Víctor Santiago 	24/05/2022		Init version
    1.1         FIX                     Oscar Moreno        31/01/2023      
    1.2         US486147                Patricia Solano     07/02/2023      Add method getPermissionOfficesAgroCededTest and 
                                                                            getPermissionOfficesAgroAssignerTest  
***********************************************************************************************************************/
@isTest
public with sharing class AV_OfficeUtility_Controller_Test {
    
    @TestSetup
	static void setup() {
       Profile profile = [SELECT Id FROM Profile WHERE Name = :AV_AppConstants.AV_PROFILE LIMIT 1];
       User usrGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
       User usrCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];

		User u1 = new User(
            Alias = 'u1',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
           ProfileId = profile.Id,
            UserName = 'testu1@test.dev',
            AV_ExternalID__c = 'U0009003',
            IsActive = true,
           AV_Funcion__c = 'DT',
           AV_OriginalOfficeNumber__c = '00615/fakeSessionId'
        );
      
		User u2 = new User(
            Alias = 'u2',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
           ProfileId = profile.Id,
            UserName = 'testu2@test.dev',
            AV_ExternalID__c = 'U0009004',
            IsActive = true,
           AV_Funcion__c = 'Gestor',
           AV_OriginalOfficeNumber__c = '00803/fakeSessionId'
        );
       
		User u3 = new User(
            Alias = 'u3',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
           ProfileId = profile.Id,
            UserName = 'testu3@test.dev',
            AV_ExternalID__c = 'U0009005',
            IsActive = true,
            AV_Funcion__c = 'DC',
            AV_OriginalOfficeNumber__c = '00803/fakeSessionId'
        );

       User u4 = new User(
           Alias = 'u4',
           Email = 'test@test.dev',
           EmailEncodingKey = 'UTF-8',
           LastName = 'testLastName',
           LanguageLocaleKey = 'es',
           LocaleSidKey = 'es',
           TimeZoneSidKey = 'Europe/Berlin',
           AV_NumeroOficinaEmpresa__c = '00615',
           ProfileId = profile.Id,
           UserName = 'testu4@test.dev',
           AV_ExternalID__c = 'U0009006',
           IsActive = true,
           AV_Funcion__c = 'DAN',
           AV_OriginalOfficeNumber__c = '00803/fakeSessionId'
       );

       User u5 = new User(
           Alias = 'u5',
           Email = 'test@test.dev',
           EmailEncodingKey = 'UTF-8',
           LastName = 'testLastName',
           LanguageLocaleKey = 'es',
           LocaleSidKey = 'es',
           TimeZoneSidKey = 'Europe/Berlin',
           AV_NumeroOficinaEmpresa__c = '00615',
           ProfileId = profile.Id,
           UserName = 'testu5@test.dev',
           AV_ExternalID__c = 'U0009007',
           IsActive = true,
           AV_Funcion__c = 'Oficina',
           AV_OriginalOfficeNumber__c = '00803/fakeSessionId'
       );

        User u6 = new User(
           Alias = 'u6',
           Email = 'test@test.dev',
           EmailEncodingKey = 'UTF-8',
           LastName = 'testLastName',
           LanguageLocaleKey = 'es',
           LocaleSidKey = 'es',
           TimeZoneSidKey = 'Europe/Berlin',
           AV_NumeroOficinaEmpresa__c = '00615',
           ProfileId = profile.Id,
           UserName = 'testu6@test.dev',
           AV_ExternalID__c = 'U0009008',
           IsActive = true,
           AV_Funcion__c = 'Gestor',
           AV_OriginalOfficeNumber__c = '00803/fakeSessionId'
       );

       System.runAs(usrGcF){
           insert new List<User>{u1,u2,u3,u4,u5,u6};
        }
        AV_TestHelper.insertNeededPermissions(u1);
        AV_TestHelper.insertNeededPermissions(u2);
        AV_TestHelper.insertNeededPermissions(u3);
        AV_TestHelper.insertNeededPermissions(u4);
        AV_TestHelper.insertNeededPermissions(u5);
        AV_TestHelper.insertNeededPermissions(u6);

       Account center = AV_TestHelper.createCaixaCenterSinInsert(); //00615
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
        Account center2 = new Account(
            Name = '00803 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00803',
            CC_Numero_Oficina__c = '00803',
            RecordTypeId = rt.Id
        );

       Account center3 = new Account(
           Name = '00804 TEST CENTER',
           CC_Numero_Oficina_Empresa__c = '00804',
           CC_Numero_Oficina__c = '00804',
           RecordTypeId = rt.Id
            );

        Account center4 = new Account(
            Name = '00805 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00805',
            CC_Numero_Oficina__c = '00805',
            RecordTypeId = rt.Id
            );

       System.runAs(usrCli){
           insert new List<Account>{center,center2,center3,center4};
           center3.AV_CentroSuperior__c = center.Id;
           center.AV_CentroSuperior__c = center2.Id;
           center4.AV_CentroSuperior__c= center3.Id;
           update new List<Account>{center,center3,center4};
    }

        List<AV_ChangeOfficeCode__mdt> employeeCodes = [
			SELECT DeveloperName, AV_CodFuncion__c
                    FROM AV_ChangeOfficeCode__mdt
		];
    }

    @isTest
    public static void getAllOfficesTestDAN(){
        User u1 = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009006'];
        User usrGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        String valorStringId= String.valueOf(u1.Id);
        System.runAs(usrGcf) {
            Contact c1 = AV_TestHelper.createEmployeeSinInsert(null,u1);
            c1.AV_CodFuncion__c='50147679';
            insert c1;
        }
        Map<String,String> userMap = new Map<String,String>();
        userMap.put('Id',valorStringId);
        userMap.put('Name', u1.Name);
        userMap.put('Funcion', u1.AV_Funcion__c);
        userMap.put('NumeroOficina',u1.AV_NumeroOficinaEmpresa__c);
        userMap.put('OriginalNumber', u1.AV_OriginalOfficeNumber__c);
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(), null);
    }

    @isTest
    public static void getAllOfficesTestDC(){
        User u1 = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009005'];
        User usrGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        String valorStringId= String.valueOf(u1.Id);
        System.runAs(usrGcf) {
            Contact c1 = AV_TestHelper.createEmployeeSinInsert(null,u1);
            c1.AV_CodFuncion__c='50147679';
            insert c1;
        }
        Map<String,String> userMap = new Map<String,String>();
        userMap.put('Id',valorStringId);
        userMap.put('Name', u1.Name);
        userMap.put('Funcion', u1.AV_Funcion__c);
        userMap.put('NumeroOficina',u1.AV_NumeroOficinaEmpresa__c);
        userMap.put('OriginalNumber', u1.AV_OriginalOfficeNumber__c);
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(), null);
    }

    @isTest
    public static void getAllOfficesTestDT(){
        User u1 = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009003'];
        User usrGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        String valorStringId= String.valueOf(u1.Id);
        System.runAs(usrGcf) {
            Contact c1 = AV_TestHelper.createEmployeeSinInsert(null,u1);
            c1.AV_CodFuncion__c='50147679';
            insert c1;
        }
        Map<String,String> userMap = new Map<String,String>();
        userMap.put('Id',valorStringId);
        userMap.put('Name', u1.Name);
        userMap.put('Funcion', u1.AV_Funcion__c);
        userMap.put('NumeroOficina',u1.AV_NumeroOficinaEmpresa__c);
        userMap.put('OriginalNumber', u1.AV_OriginalOfficeNumber__c);
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(), null);
    }

    @isTest
    public static void getAllOfficesTestGestorMultiCentro(){
        User u1 = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009004'];
        User usrGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        List<AV_ChangeOfficeCode__mdt> employeeCodes = [
			SELECT DeveloperName, AV_CodFuncion__c
			FROM AV_ChangeOfficeCode__mdt
		];
        String valorStringId= String.valueOf(u1.Id);
        System.runAs(usrGcf) {
            Contact c1 = AV_TestHelper.createEmployeeSinInsert(null,u1);
            c1.AV_CodFuncion__c= AV_OfficeUtility_Controller.getSpecialEmployeeCode(employeeCodes, 'AV_GestionDeClientesII');
            insert c1;
        }
        Map<String,String> userMap = new Map<String,String>();
        userMap.put('Id',valorStringId);
        userMap.put('Name', u1.Name);
        userMap.put('Funcion', u1.AV_Funcion__c);
        userMap.put('NumeroOficina',u1.AV_NumeroOficinaEmpresa__c);
        userMap.put('OriginalNumber', u1.AV_OriginalOfficeNumber__c);
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(), null);
    }

    @isTest
    public static void getAllOfficesTestGestorRegular(){
        User u1= [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009004'];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        String valorStringId= String.valueOf(u1.Id);
        Map<String,String> userMap = new Map<String,String>();
        System.runAs(u1) {
            userMap.put('Id',valorStringId);
            userMap.put('Name', u1.Name);
            userMap.put('Funcion', u1.AV_Funcion__c);
            userMap.put('NumeroOficina',u1.AV_NumeroOficinaEmpresa__c);
            userMap.put('OriginalNumber', u1.AV_OriginalOfficeNumber__c);
        }
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(), null);
    }

    @isTest
    public static void getAllOfficesTestGestorEspecial(){
        User u1 = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009004'];
        User usrGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        List<AV_ChangeOfficeCode__mdt> employeeCodes = [
			SELECT DeveloperName, AV_CodFuncion__c
			FROM AV_ChangeOfficeCode__mdt
		];
        String valorStringId= String.valueOf(u1.Id);
        System.runAs(usrGcf) {
            Contact c1 = AV_TestHelper.createEmployeeSinInsert(null,u1);
            String notEspecialCode;
            String especialCode = AV_OfficeUtility_Controller.getSpecialEmployeeCode(employeeCodes, 'AV_GestionDeClientesII');
            for(AV_ChangeOfficeCode__mdt code :employeeCodes){
                if(!code.AV_CodFuncion__c.equals(especialCode)){
                    notEspecialCode = code.AV_CodFuncion__c;
                    break;
                }
            }
            c1.AV_CodFuncion__c= notEspecialCode;
    
            insert c1;
        }
        Map<String,String> userMap = new Map<String,String>();
        userMap.put('Id',valorStringId);
        userMap.put('Name', u1.Name);
        userMap.put('Funcion', u1.AV_Funcion__c);
        userMap.put('NumeroOficina',u1.AV_NumeroOficinaEmpresa__c);
        userMap.put('OriginalNumber', u1.AV_OriginalOfficeNumber__c);
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(), null);
    }

    @isTest 
    private static void getPermissionOfficesTest(){
        User assigner = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009004'];
        User cedido = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009007'];
        Contact assignerCNT = AV_TestHelper.createEmployee(null, assigner);
        Contact cedidoCNT = AV_TestHelper.createEmployee(null,cedido);
        Account oficina = [SELECT Id FROM Account WHERE  CC_Numero_Oficina_Empresa__c = '00805'];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        AV_OfficePermission__c permiso = new AV_OfficePermission__c();
        permiso.AV_Assigner__c = assigner.Id;
        permiso.AV_ContactoUsuarioCedido__c = cedidoCNT.Id;
        permiso.AV_InicioPermiso__c = System.today();
        permiso.AV_FinalPermiso__c = System.today().addDays(2);
        permiso.AV_GestorPermiso__c = assignerCNT.Id;
        permiso.AV_OficinaCedida__c = oficina.Id;
        permiso.AV_UsuarioCedido__c = cedido.Id;
        insert permiso;
        String valorStringId = cedido.id;
        Map<String,String> userMap = new Map<String,String>();
        System.runAs(cedido) {
            userMap.put('Id',valorStringId);
            userMap.put('Name', cedido.Name);
            userMap.put('Funcion', cedido.AV_Funcion__c);
            userMap.put('NumeroOficina',cedido.AV_NumeroOficinaEmpresa__c);
            userMap.put('OriginalNumber', cedido.AV_OriginalOfficeNumber__c);
        }
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(),'error');
    }

    @isTest
    public static void getAllOfficesTestOficina(){
        User u1 = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009007'];
        User usrGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        String valorStringId= String.valueOf(u1.Id);
        System.runAs(usrGcf) {
            Contact c1 = AV_TestHelper.createEmployeeSinInsert(null,u1);
            c1.AV_CodFuncion__c='50147679';
            insert c1;
        }
        Map<String,String> userMap = new Map<String,String>();
        userMap.put('Id',valorStringId);
        userMap.put('Name', u1.Name);
        userMap.put('Funcion', u1.AV_Funcion__c);
        userMap.put('NumeroOficina',u1.AV_NumeroOficinaEmpresa__c);
        userMap.put('OriginalNumber', u1.AV_OriginalOfficeNumber__c);
        Test.startTest();
        AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assertNotEquals( AV_OfficeUtility_Controller.getAllOffices(userMap), null);
    }
    
    @isTest
    public static void isNewSessionTest() {
        Boolean res;
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009004'];
        Test.startTest();
        System.runAs(user) {
            res = AV_OfficeUtility_Controller.isNewSession();
        }
        Test.stopTest();
        System.assert(res != null, 'New session');
    }

    @isTest
    public static void updateUserOfficeTest() {
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009004'];
        Test.startTest();
        System.runAs(user){
        String res = AV_OfficeUtility_Controller.updateUserOffice('00803');
        }
        User uRetrieve = [SELECT AV_NumeroOficinaEmpresa__C FROM User WHERE Id = :user.Id];
        Test.stopTest();
        System.assertEquals('00803', uRetrieve.AV_NumeroOficinaEmpresa__c, 'Update failed');
    }

    @isTest
    public static void updateUserOfficeUpdateFailTest() {
        String res;
        User user = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '00615' AND AV_Funcion__c = 'Gestor' LIMIT 1];
        String tooLongString = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
        Test.startTest();
        System.runAs(user) {
            res = AV_OfficeUtility_Controller.updateUserOffice(tooLongString);
        }
        Test.stopTest();
        System.assertEquals('KO', res, 'Update done');
    }

    @isTest
    public static void getCurrentOfficeTest() {
        String res;
        User user = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '00615' AND AV_Funcion__c = 'DT'];
        Test.startTest();
        System.runAs(user) {
            res = AV_OfficeUtility_Controller.getCurrentOffice();
        }
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(res), 'No data retrieved');
    }

    @isTest
    public static void getOriginalOfficeTest() {
        String res;
        User user = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '00615' AND AV_Funcion__c = 'DC'];
        Test.startTest();
        System.runAs(user) {
            res = AV_OfficeUtility_Controller.getOriginalOffice();
        }
        Test.stopTest();
        System.assertEquals(false, String.isBlank(res), 'User does not have original office');
    }

    @isTest
    public static void isNewSessionOldOfficeTest() {
        Boolean res;
        User user = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '00615' AND AV_Funcion__c = 'DC'];
        Test.startTest();
        System.runAs(user) {
            res = AV_OfficeUtility_Controller.isNewSession();
        }
        Test.stopTest();
        System.assertEquals(true, res, 'New session');
    }
    
    /**
	 * Validates permissions to the assigner user with agro referent and ceded user with AV_CodFuncion__c
	 */
    @isTest 
    private static void getPermissionOfficesAgroAssignerTest(){
        User assigner = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009004'];
        User cedido = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009008'];
        List<AV_ChangeOfficeCode__mdt> employeeCodes = [
			SELECT DeveloperName, AV_CodFuncion__c
			FROM AV_ChangeOfficeCode__mdt
		];
        Contact assignedAgro = AV_TestHelper.createEmployeeAgroReferentSinInsert(null, assigner, 'Referente Agro');
        Contact cededAlternate = AV_TestHelper.createEmployeeAgroReferentSinInsert(null, cedido, null);
        cededAlternate.AV_CodFuncion__c = AV_OfficeUtility_Controller.getSpecialEmployeeCode(employeeCodes, 'AV_ApoderadoEquipoSuplente');
        insert new List<Contact>{assignedAgro,cededAlternate};
        Account oficina = [SELECT Id FROM Account WHERE  CC_Numero_Oficina_Empresa__c = '00805'];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        AV_OfficePermission__c permiso = new AV_OfficePermission__c();
        permiso.AV_Assigner__c = assigner.Id;
        permiso.AV_ContactoUsuarioCedido__c = cededAlternate.Id;
        permiso.AV_InicioPermiso__c = System.today();
        permiso.AV_FinalPermiso__c = System.today().addDays(2);
        permiso.AV_GestorPermiso__c = assignedAgro.Id;
        permiso.AV_OficinaCedida__c = oficina.Id;
        permiso.AV_UsuarioCedido__c = cedido.Id;
        insert permiso;
        String valorStringId = cedido.id;
        Map<String,String> userMap = new Map<String,String>();
        System.runAs(cedido) {
            userMap.put('Id',valorStringId);
            userMap.put('Name', cedido.Name);
            userMap.put('Funcion', cedido.AV_Funcion__c);
            userMap.put('NumeroOficina',cedido.AV_NumeroOficinaEmpresa__c);
            userMap.put('OriginalNumber', cedido.AV_OriginalOfficeNumber__c);
        }
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(),'error');
    }

    /**
	 * Validates permissions to the assigner user with AV_CodFuncion__c and ceded user with agro referent
	 */
    @isTest 
    private static void getPermissionOfficesCodFunctionTest(){
        User assigner = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009004'];
        User cedido = [SELECT id,Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_OriginalOfficeNumber__c FROM User WHERE AV_ExternalID__c = 'U0009008'];
        List<AV_ChangeOfficeCode__mdt> employeeCodes = [
			SELECT DeveloperName, AV_CodFuncion__c
			FROM AV_ChangeOfficeCode__mdt
		];
        Contact assignedAgro = AV_TestHelper.createEmployeeAgroReferentSinInsert(null, assigner, null);
        assignedAgro.AV_CodFuncion__c = AV_OfficeUtility_Controller.getSpecialEmployeeCode(employeeCodes, 'AV_ApoderadoEquipoSuplente');
        Contact cededAlternate = AV_TestHelper.createEmployeeAgroReferentSinInsert(null, cedido, 'Referente Agro');
        insert new List<Contact>{assignedAgro,cededAlternate};
        Account oficina = [SELECT Id FROM Account WHERE  CC_Numero_Oficina_Empresa__c = '00805'];
        List<AV_OfficeUtility_Controller.UserData> result = new List<AV_OfficeUtility_Controller.UserData>();
        AV_OfficePermission__c permiso = new AV_OfficePermission__c();
        permiso.AV_Assigner__c = assigner.Id;
        permiso.AV_ContactoUsuarioCedido__c = cededAlternate.Id;
        permiso.AV_InicioPermiso__c = System.today();
        permiso.AV_FinalPermiso__c = System.today().addDays(2);
        permiso.AV_GestorPermiso__c = assignedAgro.Id;
        permiso.AV_OficinaCedida__c = oficina.Id;
        permiso.AV_UsuarioCedido__c = cedido.Id;
        insert permiso;
        String valorStringId = cedido.id;
        Map<String,String> userMap = new Map<String,String>();
        System.runAs(cedido) {
            userMap.put('Id',valorStringId);
            userMap.put('Name', cedido.Name);
            userMap.put('Funcion', cedido.AV_Funcion__c);
            userMap.put('NumeroOficina',cedido.AV_NumeroOficinaEmpresa__c);
            userMap.put('OriginalNumber', cedido.AV_OriginalOfficeNumber__c);
        }
        Test.startTest();
        result = AV_OfficeUtility_Controller.getAllOffices(userMap);
        Test.stopTest();
        System.assert(!result.isEmpty(),'error');
    }
}