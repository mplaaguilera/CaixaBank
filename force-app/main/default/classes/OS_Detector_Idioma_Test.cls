@isTest
public with sharing class OS_Detector_Idioma_Test implements HttpCalloutMock{
    
    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Test.setMock(HttpCalloutMock.class, new OS_Detector_Idioma_Test());   
        
        List<BusinessHours> horario = [SELECT Id FROM BusinessHours WHERE Name = 'cops' LIMIT 1];

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuenta;        

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto01';
        contacto.LastName = 'Contacto01';
        contacto.CC_NumPerso__c = '25345561';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'correo@prueba.com';
        insert contacto;

        CC_MCC__c tematica = new CC_MCC__c();
		tematica.Name = 'tematica cops test';
        tematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        tematica.OS_Departamento__c = 'BOS';
        tematica.OS_Horario__c = horario[0].id;
        tematica.CC_Fecha_Vigencia_Inicio__c = System.now();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Codigo_Externo__c = 'TEC-000001';
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'producto cops test';
        producto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto.CC_Fecha_Vigencia_Inicio__c = System.now();
        producto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert producto;
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'motivo cops test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = System.now();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = tematica.Id;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject = 'Caso OS_EmailService_Test';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
    }
    
    public HTTPResponse respond(HTTPRequest req) 
    {   
                String sFakeRespuesta = '';
        sFakeRespuesta = sFakeRespuesta + '{';
        sFakeRespuesta = sFakeRespuesta + '"cat":0.000,';
        sFakeRespuesta = sFakeRespuesta + '"eng":"1.000",';
        sFakeRespuesta = sFakeRespuesta + '"esp":"0.000",';
        sFakeRespuesta = sFakeRespuesta + '"language":"eng"';
        sFakeRespuesta = sFakeRespuesta + '}';
         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta); 
        res.setStatusCode(200);
        return res;
    }
        
    @istest
    public static void getIdioma() 
    {             
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new OS_Detector_Idioma_Test());   
            
        Case caso = [SELECT Id,CC_Canal_Procedencia__c FROM Case WHERE Subject = 'Caso OS_EmailService_Test' LIMIT 1];

        String buzon =[SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c =:caso.CC_Canal_Procedencia__c LIMIT 1][0].CC_Direccion_Correo__c;
        
        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        List<Id> lstCasos = new List<Id>();
        lstCasos.add(caso.Id);
            
        String cuerpoEmail = 'Hello this is a request from cops';
        System.runAs (usuarioOperador) {     
            Test.startTest();
            OS_Detector_Idioma.setIdiomaCaso(lstCasos, 'correo@prueba.com', buzon, 'Buzón UAFE', cuerpoEmail, true);         
            Test.stopTest();
        
            Case resultCaso = [SELECT CC_Idioma__c FROM Case WHERE id = :caso.Id];
            System.assertEquals(resultCaso.CC_Idioma__c, 'en','Comprobamos el idioma.');
        }
    }
    
    
    @istest
    public static void getError() 
    {             
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT CaseNumber, OwnerId,CC_Canal_Procedencia__c FROM Case WHERE Subject = 'Caso OS_EmailService_Test' LIMIT 1];

        String buzon =[SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c =:caso.CC_Canal_Procedencia__c LIMIT 1][0].CC_Direccion_Correo__c;
        
        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        List<Id> lstCasos = new List<Id>();
        lstCasos.add(caso.id);
        
        String cuerpoEmail = 'Bon dia això és una consulta cops';   
        System.runAs (usuarioOperador) {       
            Test.startTest();
                OS_Detector_Idioma.setIdiomaCaso(lstCasos, 'correo@prueba.com', buzon, 'Buzón UAFE', cuerpoEmail, true);
            Test.stopTest();  

            Case resultCaso = [SELECT CC_Idioma__c FROM Case WHERE id = :caso.id];
            System.assertEquals(resultCaso.CC_Idioma__c, 'es','Comprobamos el idioma.');
        }
    }
}