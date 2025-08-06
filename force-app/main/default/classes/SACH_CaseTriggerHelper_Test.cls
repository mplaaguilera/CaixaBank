@isTest
public with sharing class SACH_CaseTriggerHelper_Test {
    
    
    @testSetup
    static void data(){

         //Usuario SAC General
		User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
        Database.insert(usuarioGeneral);

        Account cuentaClientePA = new Account();
            cuentaClientePA.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            cuentaClientePA.LastName = 'Cuenta Prueba ClientePA';
            cuentaClientePA.CC_Numero_Oficina_Empresa__c = '222-22223';
            cuentaClientePA.CC_Numero_Oficina__c = '222';
            insert cuentaClientePA;

        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente'; 
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;
        
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        cuenta.LastName = 'asd';
        insert cuenta;

        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        caracteristica.Name = 'Campa Prueba';
        caracteristica.CC_Descripcion__c = 'Decripcion Prueba';
        insert caracteristica;
        
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        contacto.Email = 'asdasdasd@gmail.com';
        insert contacto;
        
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test'; 
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        insert caso;


        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
        
        CC_MCC__c mcc3 = new CC_MCC__c();
        mcc3.RecordTypeId = recordCau;
        mcc3.Name = 'Valoración positiva';
        mcc3.CC_Tipo_Cliente__c = 'Cliente';
        mcc3.CC_Motivo__c = mcc2.Id;
        mcc3.CC_Codigo_Externo__c = 'CA-000001';
        insert mcc3;
        
        CC_MCC__c mcc4 = new CC_MCC__c();
        mcc4.RecordTypeId = recordSol;
        mcc4.Name = 'Valoración positiva';
        mcc4.CC_Tipo_Cliente__c = 'Cliente';
        mcc4.CC_Causa__c = mcc3.Id;
        mcc4.CC_Codigo_Externo__c = 'SO-000001';
        insert mcc4;

        CC_MCC__c mcc5 = new CC_MCC__c();
        mcc5.RecordTypeId = recordSol;
        mcc5.Name = 'Valoración positiva nueva';
        mcc5.CC_Tipo_Cliente__c = 'Cliente';
        mcc5.CC_Causa__c = mcc3.Id;
        mcc5.CC_Codigo_Externo__c = 'SO-000002';
        insert mcc5;

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        SACH_Parametros__c params = new SACH_Parametros__c();
        params.Name = 'SACH_Promor';
        params.SACH_Parametro_1__c = 'https://pro01.tf7.lacaixa.es/CA.OFI/ExpedienteRiesgoGesExternalizada/verDocumento.tf7?_flowId=verDocumento-flow&_flowRType=FR&aplicacionInv=PJU&aplicacionExpedienteX=PJU';
        insert params;

        SACH_Parametros__c params2 = new SACH_Parametros__c();
        params2.Name = 'Solucion_705';
        params2.SACH_Parametro_1__c = 'Petición autorización solicitud subasta al SACH en análisis (705)';
        insert params2;

        SACH_Parametros__c params3 = new SACH_Parametros__c();
        params3.Name = 'Solucion_715';
        params3.SACH_Parametro_1__c = 'Suspensión actuaciones por instrucción del SACH (715)';
        insert params3;


    }
    
    /**
     * Comprobar la creación de tarea del cierre de caso.
    */
    @isTest
    private static void testCrearActividadCierre() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'Cuenta personal test A';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '25345569';
        contacto.CC_Idioma__c = 'ca';
        contacto.Email = 'correo@gmail.com';
        contacto.Phone = '973242323';
        insert contacto;

        Case caso = [SELECT ContactId FROM Case WHERE Subject = 'Caso Test' LIMIT 1];
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Detalles_Consulta__c = 'det con';

        Test.startTest();
        caso.Status = 'Cerrado';
        Database.update(caso);
        Test.stopTest();

        Task tareaCreada = [Select Status, WhatId, Subject, Description, Type from Task where whatId = :caso.Id limit 1];
        
        system.assertEquals('Completed', tareaCreada.Status, 'El Status de la tarea no coincide.');
        system.assertEquals(caso.Id, tareaCreada.WhatId, 'El WhatId de la tarea no coincide.');
        system.assertEquals('Cerrado', tareaCreada.Subject, 'El Subject de la tarea no coincide.');
        system.assertEquals('Cerrado', tareaCreada.Type, 'El Type de la tarea no coincide.');
        
        }
    }
    
    /**
     * Comprobar la creación de tarea del cierre de caso.
    */
    @isTest
    private static void testCrearActividadReasignacion() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        Group grupo = [select Id from Group where Type = 'Queue' AND DeveloperName = 'SACH_Buzon'];
        
        Case caso = [Select Id, ownerId from Case where Subject = 'Caso Test' limit 1];

        Test.startTest();
        caso.OwnerId = grupo.Id;
        Database.update(caso);
        Test.stopTest();

        Task tareaCreada = [Select Status, WhatId, Subject, Description, Type from Task where whatId = :caso.Id limit 1];
        
        system.assertEquals('Completed', tareaCreada.Status, 'El Status de la tarea no coincide.');
        system.assertEquals(caso.Id, tareaCreada.WhatId, 'El WhatId de la tarea no coincide.');
        system.assertEquals('Reasignación del caso', tareaCreada.Subject, 'El Subject de la tarea no coincide.');
        system.assertEquals('Reasignación', tareaCreada.Type, 'El Type de la tarea no coincide.');
        }

    }
    
    //CC_creacion_caso Contacto

    @isTest
    public static void comprobacionContactoAI()
    {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        Id rtEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Test'];
        
        Case caso = new Case();
        caso.Subject = 'comprobacionContactoAI';
        caso.RecordTypeId = rtEmpleado;
        caso.ContactId = contacto.Id;

        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Campa Prueba' LIMIT 1];
        CC_Caracteristica_Detalle__c caracteristicaInsert = new CC_Caracteristica_Detalle__c(
        CC_Caracteristica__c = caracteristica.Id,
        CC_Cliente__c = contacto.Id
        );
        insert caracteristicaInsert;

        Test.startTest();
        insert caso;
        Test.stopTest();   

        CC_Caracteristica_Case__c caracteristicaCaso = [SELECT Id FROM CC_Caracteristica_Case__c WHERE CC_Case__c =: caso.Id LIMIT 1];

        System.assertNotEquals(caracteristicaCaso, null, 'No se ha insertado la característica correctamente');
        }
    }



    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountPersonAccountBI() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
        
    	Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
                 
        Test.startTest();   
     
        Database.insert(caso);
        Test.stopTest();
        
        case casoActualizado = [SELECT Id, ContactId FROM Case WHERE subject = 'pruebaAccount'];
        
    	System.AssertEquals(casoActualizado.ContactId, cuenta.PersonContactId,'Los datos del contacto no coinciden' );
        }

   	}

    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountPersonAccountBU() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

    	Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = rtCaso;
        caso.Subject = 'pruebaAccount';
        Database.insert(caso);
                 
        Test.startTest();   
        caso.AccountId = cuenta.Id;
        Database.update(caso);
        Test.stopTest();
        
        case casoActualizado = [SELECT Id, ContactId FROM Case WHERE subject = 'pruebaAccount'];
        
        
    	System.AssertEquals(casoActualizado.ContactId, cuenta.PersonContactId,'Los datos del contacto no coinciden' );

        }
   	}

    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountIdentificarClienteAlfBI() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

    	Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA' LIMIT 1];
        
        Case caso = new Case();
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='1';

        
                 
        Test.startTest();   
        Database.insert(caso);
        Test.stopTest();
        
        case casoActualizado = [SELECT Id, ContactId FROM Case WHERE subject = 'pruebaAccount'];
        
    	System.AssertEquals(casoActualizado.ContactId, cuenta.PersonContactId,'Los datos del contacto no coinciden' );
        }
   	}

    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountIdentificarClienteAlfExtensionBI() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA' LIMIT 1];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Numero_Documento__c = '45655665P';
        Database.Update(cuenta);

        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='1';
        caso.RecordTypeId = rtCliente;
 
         
        Test.startTest();   
        Database.insert(caso); 
        Test.stopTest();
        
        case casoActualizado = [SELECT Id, ContactId,CC_MailTelfNotif__c,CC_Numero_Documento__c,CC_DAN__c,CC_DG__c FROM Case WHERE subject = 'pruebaAccount'];
        
    	
        System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, cuenta.CC_NumPerso__c,'El numero de telefono no coinide' );
        System.AssertEquals(casoActualizado.CC_Numero_Documento__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
        }

   	}


    /**
     * Actualiza el contacto o lo genera.*/
    
    @isTest
    private static void testCcCaseModificarAccountIdentificarClienteAlfBU() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

    	Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c,CC_NumPerso__c,CC_Numero_Documento__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA' LIMIT 1];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Numero_Documento__c = '45655665P';
        Database.Update(cuenta);

        Case caso = new Case();
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = rtCliente;
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.AccountId = cuenta.Id;
        Database.insert(caso);

        Test.startTest();   
        caso.CC_IdentCliente__c ='1';
        update(caso);
        Test.stopTest();
        
        case casoActualizado = [SELECT Id, ContactId,CC_MailTelfNotif__c,CC_Numero_Documento__c,CC_NumPerso__c FROM Case WHERE subject = 'pruebaAccount'];

    	System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, cuenta.CC_NumPerso__c,'El numero de telefono no coinide' );
        System.AssertEquals(casoActualizado.CC_Numero_Documento__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
        }
   	}


    /**
     * Actualiza el contacto o lo genera.*/
    
     @isTest
        private static void testCc_Case_Modificar_AccountIdentificarCambioClienteAlfBU() {
        
            User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
            System.runAs(usuario){

    	Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c,CC_NumPerso__c,CC_Numero_Documento__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA' LIMIT 1];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Numero_Documento__c = '45655665P';
        Database.Update(cuenta);

        Case caso = new Case();
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = rtCliente;
        caso.CC_Canal_Procedencia__c = 'SACH';
        Database.insert(caso);

        Test.startTest();   
        caso.AccountId = cuenta.Id;
        update(caso);
        Test.stopTest();
        
        case casoActualizado = [SELECT Id, ContactId,CC_MailTelfNotif__c,CC_Numero_Documento__c,CC_NumPerso__c FROM Case WHERE subject = 'pruebaAccount'];

    	System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, cuenta.CC_NumPerso__c,'El numero de telefono no coinide' );
        System.AssertEquals(casoActualizado.CC_Numero_Documento__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
        System.AssertEquals(casoActualizado.CC_NumPerso__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
            }
   	}     


    /**
     * Actualiza el contacto o lo genera.*/
    
     @isTest
        private static void testCc_Case_Modificar_AccountBlanqueoAccountBU() {
            User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
            System.runAs(usuario){


        Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id,PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA' LIMIT 1];
       
        Case caso = new Case();
        caso.RecordTypeId = rtCliente;
        caso.CC_MailTelfNotif__c = 'mailnotif@mail.com';
        caso.CC_Numero_Documento__c = '45655665P';
        caso.CC_NumPerso__c = '12';
        caso.Subject = 'pruebaAccount';
        caso.AccountId = cuenta.Id;
        Database.insert(caso);
  
        Test.startTest();   
        caso.AccountId = null;
        Database.update(caso);
        Test.stopTest();

        case casoActualizado = [SELECT Id, ContactId, CC_MailTelfNotif__c, CC_Numero_Documento__c, CC_NumPerso__c FROM Case WHERE subject = 'pruebaAccount'];

        System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, null,'Los datos del contacto no coinciden' );
        System.AssertEquals(casoActualizado.CC_Numero_Documento__c, null,'Los datos del contacto no coinciden' );
        System.AssertEquals(casoActualizado.CC_NumPerso__c, null,'Los datos del contacto no coinciden' );
            }
   	}

       @isTest
       static void testReabrirTareaTrasladoColab() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

           // Crear un caso y una tarea cerrada de traslado colaborador asociada a él
           Case caso = new Case();
           insert caso;
           
           Task tareaCerrada = new Task(
               WhatId = caso.Id,
               Type = 'Traslado Colaborador',
               Status = 'Completed'
           );
           insert tareaCerrada;
           
           // Llamar al método que se va a probar
           Test.startTest();
           SACH_CaseTriggerHelper.reabrirTareaTrasladoColab(caso);
           Test.stopTest();
           
           // Verificar que la tarea cerrada se haya reabierto
           Task tareaReabierta = [SELECT Status FROM Task WHERE Id = :tareaCerrada.Id];
           System.assertEquals('Open', tareaReabierta.Status, 'La tarea de traslado colaborador no se reabrió correctamente');
        }
       }

       @isTest
       static void testValidarOperativaPromor() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){


        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];
        CC_MCC__c mccSolucion2 = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE Name = 'Valoración positiva nueva' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Test'];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        insert caso;

        Case caso2 = new Case();
        caso2.Status = 'Activo';
        caso2.ContactId = contacto.Id;
        caso2.RecordTypeId = rtCaso;
        caso2.AccountId = cuenta.Id;
        caso2.CC_Codigo_Externo_Causa__c = null;
        caso2.CC_MCC_Solucion__c = mccSolucion2.Id;
        insert caso2;
        
        // Mapear el caso anterior para simular el cambio de solución
        Map<Id, Case> mapOldObj = new Map<Id, Case>();
        Case casoAnterior = new Case();
        casoAnterior.CC_MCC_Solucion__c = mccSolucion2.Id;
        mapOldObj.put(caso.Id, casoAnterior);
        mapOldObj.put(caso2.Id, casoAnterior);

           // Preparar datos para solución 'Petición autorización solicitud subasta al SACH en análisis (705)'
           //Id solucion705Id = CC_MCC__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
           Id solucion705Id = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
           CC_MCC__c solucion705 = new CC_MCC__c(
               RecordTypeId = solucion705Id,
               Name = 'Petición autorización solicitud subasta al SACH en análisis (705)',
               CC_Tipo_Cliente__c = 'Cliente (SACH)',
               CC_Codigo_Externo__c = 'SO-000011'
           );
           insert solucion705;
           
           // Preparar datos para solución 'Suspensión actuaciones por instrucción del SACH (715)'
           Id solucion715Id = CC_MCC__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
           CC_MCC__c solucion715 = new CC_MCC__c(
               RecordTypeId = solucion715Id,
               Name = 'Suspensión actuaciones por instrucción del SACH (715)',
               CC_Tipo_Cliente__c = 'Cliente (SACH)',
               CC_Codigo_Externo__c = 'SO-000012'
           );
           insert solucion715;
           
           // Simular cambio de solución a 'Petición autorización solicitud subasta al SACH en análisis (705)'
           caso.CC_MCC_Solucion__c = solucion705.Id;
           update caso;

         // Simular cambio de solución a 'Petición autorización solicitud subasta al SACH en análisis (705)'
         caso2.CC_MCC_Solucion__c = solucion715.Id;
         update caso2;

           Task tareaCerrada = new Task(
               WhatId = caso.Id,
               Type = 'Traslado Colaborador',
               Status = 'Completed'
           );
           insert tareaCerrada;

           
           Test.startTest();
           SACH_CaseTriggerHelper.validarOperativaPromor(new List<Case>{caso}, mapOldObj);
           SACH_CaseTriggerHelper.validarOperativaPromor(new List<Case>{caso2}, mapOldObj);

           Test.stopTest();
           
           // Verificar que la tarea de traslado colaborador se reabra
           Task tarea = [SELECT Status FROM Task WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' LIMIT 1];
           //Task tarea = [Select Status, WhatId, Subject, Description, Type from Task where whatId = :caso.Id limit 1];
           System.assertEquals('Open', tarea.Status, 'La tarea de traslado colaborador no se reabrió correctamente para solución 705');
           
           // Verificar que el estado del caso se cambió a 'Pendiente Colaborador'
           Case casoActualizado = [SELECT Status FROM Case WHERE Id = :caso.Id LIMIT 1];
           System.assertEquals('Activo', casoActualizado.Status, 'El estado del caso no se actualizó correctamente para solución 705');
           
           // Simular cambio de solución a 'Suspensión actuaciones por instrucción del SACH (715)'
           caso.CC_MCC_Solucion__c = solucion715.Id;
           update caso;
           
           /*
           Test.startTest();
           SACH_CaseTriggerHelper.validarOperativaPromor(new List<Case>{caso2}, mapOldObj);
           Test.stopTest();*/
           
           // Verificar que se envió el correo y se creó la tarea de traslado colaborador para solución 715
           EmailMessage[] emails = [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id];

           System.assertEquals(0, emails.size(), 'No se envió el correo electrónico para solución 715');
           
           Task tarea2 = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' LIMIT 1];
           System.assertNotEquals(null, tarea2, 'No se creó la tarea de traslado colaborador para solución 715');
        }
       }

       @isTest
       static void testValidarOperativaPromor2() {

        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];
        CC_MCC__c mccSolucion2 = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE Name = 'Valoración positiva nueva' LIMIT 1];
    
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        insert caso;

        Case caso2 = new Case();
        caso2.Status = 'Activo';
        caso2.RecordTypeId = rtCaso;
        caso2.AccountId = cuenta.Id;
        caso2.CC_Codigo_Externo_Causa__c = null;
        caso2.CC_MCC_Solucion__c = mccSolucion2.Id;
        insert caso2;
        
        // Mapear el caso anterior para simular el cambio de solución
        Map<Id, Case> mapOldObj = new Map<Id, Case>();
        Case casoAnterior = new Case();
        casoAnterior.CC_MCC_Solucion__c = mccSolucion2.Id;
        mapOldObj.put(caso.Id, casoAnterior);

        /*
           // Preparar datos para solución 'Petición autorización solicitud subasta al SACH en análisis (705)'
           //Id solucion705Id = CC_MCC__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
           Id solucion705Id = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
           CC_MCC__c solucion705 = new CC_MCC__c(
               RecordTypeId = solucion705Id,
               Name = 'Petición autorización solicitud subasta al SACH en análisis (705)',
               CC_Tipo_Cliente__c = 'Cliente (SACH)',
               CC_Codigo_Externo__c = 'SO-000011'
           );
           insert solucion705;*/
           
           // Preparar datos para solución 'Suspensión actuaciones por instrucción del SACH (715)'
           Id solucion715Id = CC_MCC__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
           CC_MCC__c solucion715 = new CC_MCC__c(
               RecordTypeId = solucion715Id,
               Name = 'Suspensión actuaciones por instrucción del SACH (715)',
               CC_Tipo_Cliente__c = 'Cliente (SACH)',
               CC_Codigo_Externo__c = 'SO-000012'
           );
           insert solucion715;
           
           // Simular cambio de solución a 'Petición autorización solicitud subasta al SACH en análisis (705)'
           caso.CC_MCC_Solucion__c = solucion715.Id;
           update caso;

         // Simular cambio de solución a 'Petición autorización solicitud subasta al SACH en análisis (705)'
         caso2.CC_MCC_Solucion__c = solucion715.Id;
         update caso2;

           Task tareaCerrada = new Task(
               WhatId = caso.Id,
               Type = 'Traslado Colaborador',
               Status = 'Completed'
           );
           insert tareaCerrada;

           
           Test.startTest();
           SACH_CaseTriggerHelper.validarOperativaPromor(new List<Case>{caso}, mapOldObj);
           Test.stopTest();
           
           // Verificar que la tarea de traslado colaborador se reabra
           Task tarea = [SELECT Status FROM Task WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' LIMIT 1];
           //Task tarea = [Select Status, WhatId, Subject, Description, Type from Task where whatId = :caso.Id limit 1];
           System.assertEquals('Completed', tarea.Status, 'La tarea de traslado colaborador no se reabrió correctamente para solución 705');
           
           // Verificar que el estado del caso se cambió a 'Pendiente Colaborador'
           Case casoActualizado = [SELECT Status FROM Case WHERE Id = :caso.Id LIMIT 1];
           System.assertEquals('Activo', casoActualizado.Status, 'El estado del caso no se actualizó correctamente para solución 705');
           
           // Simular cambio de solución a 'Suspensión actuaciones por instrucción del SACH (715)'
           caso.CC_MCC_Solucion__c = solucion715.Id;
           update caso;
           
           /*
           Test.startTest();
           SACH_CaseTriggerHelper.validarOperativaPromor(new List<Case>{caso}, mapOldObj);
           Test.stopTest();*/
           
           // Verificar que se envió el correo y se creó la tarea de traslado colaborador para solución 715
           EmailMessage[] emails = [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id];

           System.assertEquals(0, emails.size(), 'No se envió el correo electrónico para solución 715');
           
           Task tarea2 = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Traslado Colaborador' LIMIT 1];
           System.assertNotEquals(null, tarea2, 'No se creó la tarea de traslado colaborador para solución 715');
        }
       }
 
 }