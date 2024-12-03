@isTest
public with sharing class CSBD_ProductoOportunidadHija_Test {
    @TestSetup
    static void data(){
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        Account cuenta = crearCuentaContacto('12345678N');
        User userPrueba = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = userPrueba.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        RecordType  listaValoresRT = [SELECT Id  FROM RecordType  WHERE DeveloperName   = 'CC_Lista_Valores'];
        CC_Lista_Valores__c listaValoresPrueba = new CC_Lista_Valores__c();
        listaValoresPrueba.Name = 'CSBD: Acciones comerciales oportunidad';
        listaValoresPrueba.CC_Activa__c = true;
        listaValoresPrueba.RecordTypeId = listaValoresRT.Id;
        insert listaValoresPrueba;

        CC_Lista_Valores__c listaValoresPrueba1 = new CC_Lista_Valores__c();
        listaValoresPrueba1.Name = 'Valores test';
        listaValoresPrueba1.CC_Valor2__c='Fondos';
        listaValoresPrueba1.CC_Valor__c='Seguros';
        listaValoresPrueba1.CC_Lista__c = listaValoresPrueba.Id;
        listaValoresPrueba1.CC_Valor_SFDC__c = 'Hipoteca';
        listaValoresPrueba1.CC_Activa__c = true;
        insert listaValoresPrueba1;

        CC_Lista_Valores__c listaValoresPrueba2 = new CC_Lista_Valores__c();
        listaValoresPrueba2.Name = 'Valores test 2';
        listaValoresPrueba2.CC_Valor2__c='MyBox Auto';
        listaValoresPrueba2.CC_Valor__c='Hipotecas';
        listaValoresPrueba2.CC_Lista__c = listaValoresPrueba.Id;
        listaValoresPrueba2.CC_Valor_SFDC__c = 'Hipoteca';
        listaValoresPrueba2.CC_Activa__c = true;
        insert listaValoresPrueba2;
    }

    public static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }
    @isTest
    private static void crearOportunidadesHijasTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        
        Opportunity oportunidadTest = new Opportunity();
        oportunidadTest.Name='test';
        oportunidadTest.stageName='Solicitud';
        oportunidadTest.AccountId=cuenta1.Id;
        oportunidadTest.OwnerId=usuarioGestor.Id;
        insert oportunidadTest;
        
        Opportunity oportunidadTest1 = new Opportunity();
        oportunidadTest1.Name='test';
        oportunidadTest1.stageName='Rechazada';
        oportunidadTest1.AccountId=cuenta1.Id;
        oportunidadTest1.OwnerId=usuarioGestor.Id;
        insert oportunidadTest1;
        
        Opportunity oportunidadTest2 = new Opportunity();
        oportunidadTest2.Name='test';
        oportunidadTest2.stageName='Formalizada';
        oportunidadTest2.AccountId=cuenta1.Id;
        oportunidadTest2.OwnerId=usuarioGestor.Id;
        insert oportunidadTest2;
        
        List<String> productos = new List<String>{'MyBox Auto','Fondos'};
        
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_ProductoOportunidadHija.crearOportunidadesHijas(productos, oportunidadTest.StageName, oportunidadTest.Id,'Hipoteca', '');
            CSBD_ProductoOportunidadHija.crearOportunidadesHijas(productos, oportunidadTest1.StageName, oportunidadTest1.Id,'Hipoteca', 'Duplicada');
            CSBD_ProductoOportunidadHija.crearOportunidadesHijas(productos, oportunidadTest2.StageName, oportunidadTest2.Id,'Hipoteca', 'Duplicada');
            List<Opportunity> oportunidadesHijas=[SELECT id,OwnerId,CSBD_Estado__c FROM Opportunity WHERE CSBD_Parent_Id__c = :oportunidadTest.Id];
            Opportunity oportunidad1 = [SELECT Id, OwnerId, CSBD_Estado__c FROM Opportunity WHERE CSBD_Parent_Id__c = :oportunidadTest1.Id LIMIT 1];
            List<Task> tareaCierre = [SELECT Id FROM Task WHERE WhatId = :oportunidad1.Id AND Subject = :oportunidad1.CSBD_Estado__c];  
            system.assert(oportunidadesHijas.isEmpty()==false, 'No se han creado oportunidades hijas');
            system.assert(tareaCierre.isEmpty()==false, 'No se ha creado tarea de cierre');
            Test.stopTest();
        }
    }

    @isTest
    private static void cerrarOportunidadesHijasTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        
        Opportunity oportunidadTest = new Opportunity();
        oportunidadTest.Name='test';
        oportunidadTest.stageName='Solicitud';
        oportunidadTest.AccountId=cuenta1.Id;
        oportunidadTest.OwnerId=usuarioGestor.Id;
        insert oportunidadTest;
        
        List<String> productos = new List<String>{'MyBox Auto','Fondos'};
        CSBD_ProductoOportunidadHija.crearOportunidadesHijas(productos, oportunidadTest.StageName, oportunidadTest.Id,'Hipoteca', '');
        
        List<Opportunity> oportunidadPadre =[SELECT Id, OwnerId, CSBD_Estado__c, StageName, CSBD_Resolucion__c FROM Opportunity WHERE Id = :oportunidadTest.Id];
        Map<Id, Opportunity> idOportunidad = new Map<Id, Opportunity>();
        for(Opportunity oportunidad: oportunidadPadre) {
            idOportunidad.put(oportunidad.Id, oportunidad);
        }
        CSBD_Opportunity.cerrarOportunidad(oportunidadTest.Id, 'Rechazada', 'No aplica');

        
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_ProductoOportunidadHija.cerrarOportunidadesHijas(idOportunidad);
            List<Opportunity> oportunidadesHijas=[SELECT Id FROM Opportunity WHERE CSBD_Parent_Id__c = :oportunidadTest.Id AND StageName = 'Rechazada' AND CSBD_Resolucion__c = 'No aplica' ];
            System.assert(oportunidadesHijas.isEmpty()==false, 'No se han cerrado oportunidades hijas');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void obtenerProductosTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        
        System.runAs (usuarioGestor) {
            Test.startTest();
            List<CC_Lista_Valores__c> listaValores= CSBD_ProductoOportunidadHija.obtenerProductos('Hipoteca');
            system.assert(listaValores.isEmpty()==false, 'No hay productos disponibles');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void obtenerOportunidadesHijasTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N']; 
        RecordType  accionComercialRT = [SELECT Id  FROM RecordType  WHERE DeveloperName   = 'CSBD_Accion_Comercial'];
          
        Opportunity oportunidadTest = new Opportunity();
        oportunidadTest.Name='test';
        oportunidadTest.stageName='Solicitud';
        oportunidadTest.AccountId=cuenta1.Id;
        oportunidadTest.OwnerId=usuarioGestor.Id;
        insert oportunidadTest;
        
        Opportunity oportunidadTest1 = new Opportunity();
        oportunidadTest1.Name='test';
        oportunidadTest1.stageName='Solicitud';
        oportunidadTest1.CSBD_Parent_Id__c=oportunidadTest.Id;
        oportunidadTest1.AccountId=cuenta1.Id;
        oportunidadTest1.RecordTypeId= accionComercialRT.Id;
        oportunidadTest1.OwnerId=usuarioGestor.Id;
        insert oportunidadTest1;
        
        System.runAs (usuarioGestor) {
            Test.startTest();
            List<Opportunity> oportunidadesHijas= CSBD_ProductoOportunidadHija.obtenerOportunidadesHijas(oportunidadTest.Id);
            system.assert(oportunidadesHijas.isEmpty()==false, 'No hay oportunidades hijas');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void obtenerOportunidadesHijasAbiertasTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        RecordType  accionComercialRT = [SELECT Id  FROM RecordType  WHERE DeveloperName   = 'CSBD_Accion_Comercial'];
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        
        Opportunity oportunidadTest = new Opportunity();
        oportunidadTest.Name='test';
        oportunidadTest.stageName='Solicitud';
        oportunidadTest.OwnerId = usuarioGestor.Id;
        insert oportunidadTest;
        
        Opportunity oportunidadTest1 = new Opportunity();
        oportunidadTest1.Name='test';
        oportunidadTest1.stageName='Solicitud';
        oportunidadTest1.CSBD_Parent_Id__c=oportunidadTest.Id;
        oportunidadTest1.RecordtypeId = accionComercialRT.Id;
        oportunidadTest1.AccountId=cuenta1.Id;
        oportunidadTest1.OwnerId = usuarioGestor.Id;
        insert oportunidadTest1;
        
        Opportunity oportunidadTest2 = new Opportunity();
        oportunidadTest2.Name='test';
        oportunidadTest2.stageName='Rechazada';
        oportunidadTest2.CSBD_Parent_Id__c=oportunidadTest1.Id;
        oportunidadTest2.RecordtypeId = accionComercialRT.Id;
        oportunidadTest2.AccountId=cuenta1.Id;
        oportunidadTest2.OwnerId = usuarioGestor.Id;
        insert oportunidadTest2;
        
        System.runAs (usuarioGestor) {
            Test.startTest();
            Boolean oportunidadesHijasAbiertas= CSBD_ProductoOportunidadHija.obtenerOportunidadesHijasAbiertas(oportunidadTest.Id);
            Boolean oportunidadesHijasAbiertas2= CSBD_ProductoOportunidadHija.obtenerOportunidadesHijasAbiertas(oportunidadTest1.Id);
            system.assert(oportunidadesHijasAbiertas==true, 'No hay oportunidades hijas abiertas');
            system.assert(oportunidadesHijasAbiertas2==false, 'Hay oportunidades hijas abiertas');
            Test.stopTest();
        }
    }
   
    @isTest
    private static void crearTareaCambioEmpresaProveedoraTest() {
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        Opportunity oportunidadTest = new Opportunity();
        oportunidadTest.Name='test';
        oportunidadTest.stageName='Solicitud';
        oportunidadTest.CSBD_Empresa_Proveedora__c='CaixaBank';
        oportunidadTest.AccountId=cuenta1.Id;
        oportunidadTest.OwnerId=usuarioGestor.Id;
        insert oportunidadTest;
        
    	System.runAs (usuarioGestor) {
            Test.startTest();
            oportunidadTest.CSBD_Empresa_Proveedora__c='imaginBank';
            update oportunidadTest;
            List<Task> tarea = [SELECT Subject,Description FROM Task  WHERE WhatId= : oportunidadTest.Id and Subject = 'Cambio empresa proveedora'];
            System.assertEquals(tarea.isEmpty(),false, 'No se ha creado la tarea de Cambio empresa proveedora');
            Test.stopTest();
        }
    }
    
    @isTest
    private static void actualizarPropietarioOportunidadesHijasTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        RecordType  accionComercialRT = [SELECT Id  FROM RecordType  WHERE DeveloperName   = 'CSBD_Accion_Comercial'];
        Map<Id, Opportunity> mapaOportunidades= new Map<Id, Opportunity>();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usuarioGestor2 = CSBD_Usuarios.usuarioGestor();
        
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta1.Id;
        acshare.UserOrGroupId = usuarioGestor2.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        Opportunity oportunidadTest = new Opportunity();
        oportunidadTest.Name='test';
        oportunidadTest.stageName='Solicitud';
        oportunidadTest.OwnerId = usuarioGestor.id;
        oportunidadTest.AccountId=cuenta1.Id;
        insert oportunidadTest;
        mapaOportunidades.put(oportunidadTest.Id, oportunidadTest);
        
        Opportunity oportunidadTest1 = new Opportunity();
        oportunidadTest1.Name='test';
        oportunidadTest1.stageName='Solicitud';
        oportunidadTest1.CSBD_Parent_Id__c=oportunidadTest.Id;
        oportunidadTest1.RecordtypeId = accionComercialRT.Id;
        oportunidadTest1.AccountId=cuenta1.Id;
        insert oportunidadTest1;
       
        System.runAs (usuarioGestor2) {
            Test.startTest();
            oportunidadTest.OwnerId= usuarioGestor2.Id;
            update oportunidadTest;
            Opportunity opp= [SELECT Id, OwnerId, CSBD_Parent_Id__c FROM Opportunity 
                                                                WHERE CSBD_Parent_Id__c = :oportunidadTest.Id AND Recordtype.DeveloperName = 'CSBD_Accion_Comercial' AND IsClosed = false];
            
            System.assertEquals(oportunidadTest.OwnerId,opp.OwnerId, 'No se ha sincronizado el propietario de la oportunidad padre con el de las hijas');
            Test.stopTest();
       }
    } 
}