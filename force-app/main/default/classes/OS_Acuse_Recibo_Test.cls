@isTest
public with sharing class OS_Acuse_Recibo_Test {

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
        caso.CC_Canal_Procedencia__c = 'Buzón UAFE Express';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
        
        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'COPS: Acuse de recibo por Buzones';
        lista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lista.CC_Activa__c = true;
        insert lista;
        
        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valor.CC_Activa__c = true;
        valor.CC_Lista__c = lista.Id;
        valor.Name = caso.CC_Canal_Procedencia__c;
        insert valor;
    }
    
     @istest
    public static void enviarAcuse() 
    {             
       User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        Case caso = [SELECT CaseNumber, OwnerId, CC_Canal_Procedencia__c FROM Case WHERE Subject = 'Caso OS_EmailService_Test' LIMIT 1];
        
        OrgWideEmailAddress owea = [select Id, Address from OrgWideEmailAddress where DisplayName = 'Buzón UAFE Express' LIMIT 1];
        
        EmailServicesAddress direccion = [SELECT EmailDomainName, LocalPart from EmailServicesAddress WHERE DeveloperName='Buzon_UAFE_Express' LIMIT 1];
        
        String buzon =[SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c =:caso.CC_Canal_Procedencia__c LIMIT 1][0].CC_Direccion_Correo__c;
        
        EmailMessage correo = new EmailMessage();
        correo.Status = '0';
        correo.Subject = 'Test COPS';
        correo.FromAddress = 'correo@prueba.com';
        correo.ToAddress = direccion.LocalPart+'@'+direccion.EmailDomainName;
        correo.Incoming = true;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        insert correo;
        
        
        List<Id> lstCasos = new List<Id>();
        lstCasos.add(caso.id);
        
        String cuerpoEmail = 'Bon dia això és una consulta cops';   
        System.runAs (usuarioOperador) {       
            Test.startTest();
                OS_Detector_Idioma.setIdiomaCaso(lstCasos, 'correo@prueba.com', buzon, 'Buzón UAFE Express', cuerpoEmail, true);
            Test.stopTest();  

            System.assertEquals(2, [SELECT COUNT() FROM EmailMessage WHERE ParentId = :caso.id], 'Resultado erróneo acuses size');
        }
    }
    
    @istest
    public static void noEnviarAcuse() 
    {             
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        Case caso = [SELECT CaseNumber, OwnerId, CC_Canal_Procedencia__c FROM Case WHERE Subject = 'Caso OS_EmailService_Test' LIMIT 1];
        
        OrgWideEmailAddress owea = [select Id, Address from OrgWideEmailAddress where DisplayName = 'Buzón UAFE Express' LIMIT 1];
        
        EmailServicesAddress direccion = [SELECT EmailDomainName, LocalPart from EmailServicesAddress WHERE DeveloperName='Buzon_UAFE_Express' LIMIT 1];
        
        String buzon =[SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c =:caso.CC_Canal_Procedencia__c LIMIT 1][0].CC_Direccion_Correo__c;
        
        EmailMessage correo = new EmailMessage();
        correo.Status = '0';
        correo.Subject = 'Test COPS';
        correo.FromAddress = 'correo@prueba.com';
        correo.ToAddress = direccion.LocalPart+'@'+direccion.EmailDomainName;
        correo.Incoming = true;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        insert correo;
        
        CC_Lista_Valores__c valor = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = :caso.CC_Canal_Procedencia__c];
        valor.CC_Valor__c ='correo@prueba.com';
        update valor;
        
        
        List<Id> lstCasos = new List<Id>();
        lstCasos.add(caso.id);
        
        String cuerpoEmail = 'Bon dia això és una consulta cops';   
        System.runAs (usuarioOperador) {       
            Test.startTest();
                OS_Detector_Idioma.setIdiomaCaso(lstCasos, 'correo@prueba.com', buzon, 'Buzón UAFE Express', cuerpoEmail, true);
            Test.stopTest();  

            Integer resultCount = [SELECT COUNT() FROM EmailMessage WHERE ParentId = :caso.id AND FromAddress = :owea.Address];

            System.assertEquals(0, resultCount, 'Resultado erróneo acuses size');

            /* EmailMessage[] resultCaso = [SELECT ParentId,HtmlBody FROM EmailMessage WHERE ParentId = :caso.id AND FromAddress = :owea.Address];
        	
            System.assertEquals(0, resultCaso.size(),'Resultado erróneo acuses size'); */
        }
    }

}