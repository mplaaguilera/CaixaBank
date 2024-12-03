@isTest
public with sharing class SEG_wsRoboticsIdentContacto_Test {
    @testSetup
    static void datosIniciales ()
    { 
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        Id grColSegmentosId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        cuentaSEG1.SEG_Organizacion__c = 'Banca Corporativa';
        cuentaSEG1.SEG_Zona__c = 'Corporativa';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        // Crear canal de comunicación.
        List<CC_Canal_Com__c> canales = new List<CC_Canal_Com__c>();
		CC_Canal_Com__c canal1 = new CC_Canal_Com__c();
        canal1.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canal1.CC_CuentaId__c = cuentaSEG1.Id;
        canal1.CC_ContactoId__c = contactoSEG1.Id;
        canal1.CC_Email__c = 'test1@test.es';
        canales.add(canal1);
        
		CC_Canal_Com__c canal2 = new CC_Canal_Com__c();
        canal2.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canal2.CC_CuentaId__c = cuentaSEG1.Id;
        canal2.CC_ContactoId__c = contactoSEG1.Id;
        canal2.CC_Email__c = 'test2@test.es';
        canales.add(canal2);
        
        insert canales;
        
        // Crear oficina para la búsqueda.
        Account oficinaSEG1 = new Account();
        oficinaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        oficinaSEG1.Name = 'Oficina 00001';
        oficinaSEG1.CC_Numero_Oficina_Empresa__c = '001-00001';
        oficinaSEG1.SEG_Organizacion__c = 'Banca Corporativa';
        oficinaSEG1.SEG_Zona__c = 'Corporativa';
        insert oficinaSEG1;
        
        // Empleado.
        Contact empleado1 = new Contact();
        empleado1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        empleado1.LastName = 'Contacto SEG 1';
        empleado1.AccountId = oficinaSEG1.Id;
        empleado1.Email = 'test@test.com';
        insert empleado1;
        
        // Crear canal de comunicación.
        List<CC_Canal_Com__c> canalesOficina = new List<CC_Canal_Com__c>();
		CC_Canal_Com__c canalEmpleado1 = new CC_Canal_Com__c();
        canalEmpleado1.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canalEmpleado1.CC_CuentaId__c = oficinaSEG1.Id;
        canalEmpleado1.CC_ContactoId__c = empleado1.Id;
        canalEmpleado1.CC_Email__c = 'test1@test.es';
        canalesOficina.add(canalEmpleado1);
        
		CC_Canal_Com__c canalEmpleado2 = new CC_Canal_Com__c();
        canalEmpleado2.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canalEmpleado2.CC_CuentaId__c = oficinaSEG1.Id;
        canalEmpleado2.CC_ContactoId__c = empleado1.Id;
        canalEmpleado2.CC_Email__c = 'test2@test.es';
        canalesOficina.add(canalEmpleado2);
        
        insert canalesOficina;
    }
    
    @isTest
    public static void getContactosCuenta()
    {        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/';
        req.httpMethod = 'GET';
        req.params.put('zona','Corporativa');
        req.params.put('cif','11111111H');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        
        	SEG_wsRoboticsIdentificacionContacto.SEG_WS_IdentContacto_GetOutput resultado = SEG_wsRoboticsIdentificacionContacto.getContactos();

        Test.stopTest();

		System.assert(resultado.resultado == 'OK');
        System.assert(resultado.codigo == '0000');
    }
    
    @isTest
    public static void getContactosOficina()
    {        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/';
        req.httpMethod = 'GET';
        req.params.put('zona','Corporativa');
        req.params.put('cif','00001');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        
        	SEG_wsRoboticsIdentificacionContacto.SEG_WS_IdentContacto_GetOutput resultado = SEG_wsRoboticsIdentificacionContacto.getContactos();

        Test.stopTest();

        System.assert(resultado.resultado == 'OK');
        System.assert(resultado.codigo == '0000');
    }
    
    @isTest
    public static void getContactosKO()
    {        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/ERROR';
        req.httpMethod = 'GET';
        req.params.put('zona','Corporativa');
        req.params.put('cif','00001');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        
        	SEG_wsRoboticsIdentificacionContacto.SEG_WS_IdentContacto_GetOutput resultado = SEG_wsRoboticsIdentificacionContacto.getContactos();
        
        	req.requestURI = '/v1/segRoboticsCases/';
        	req.params.remove('zona');
        	SEG_wsRoboticsIdentificacionContacto.SEG_WS_IdentContacto_GetOutput resultado2 = SEG_wsRoboticsIdentificacionContacto.getContactos();

        Test.stopTest();

        System.assert(resultado.resultado != 'OK');
        System.assert(resultado.codigo != '0000');
    }
}