@isTest
public with sharing class OS_CaseTriggerHelper_Test {
    
    @testSetup
    static void data(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
        usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Id recordTypeOficina = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account oficinaGestora = new Account(RecordTypeId = recordTypeOficina, Name = 'Cuenta oficina gestora', CC_Tipo_Centro__c = 'OF',  CC_Email__c = 'test@test.com', CC_Numero_Oficina__c = '00001');
        insert oficinaGestora;

        Account cuenta3 = new Account();
        cuenta3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta3.Name = 'Parent Gerencia Comercial';
        insert cuenta3;
        
        Account cuenta2 = new Account();
        cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta2.Name = 'Gerencia Comercial';
        cuenta2.ParentId = cuenta3.Id;
        insert cuenta2;

        Account cuenta1 = new Account();
        cuenta1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta1.Name = 'cuenta1';
        cuenta1.CC_Gerencia_Comercial__c = cuenta2.Id;
        insert cuenta1;

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        cuenta.LastName = 'asd';
        insert cuenta;

        Account empleado = new Account();
        empleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        empleado.Name = 'Cuenta Prueba Empleado';
        empleado.CC_OficinaGestoraId__c = oficinaGestora.Id;
        empleado.CC_Numero_Oficina__c = '00001';
        insert empleado;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta3.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuenta2.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuenta1.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuenta.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);

        AccountShare acshare5 = new AccountShare();
        acshare5.AccountId = empleado.Id;
        acshare5.UserOrGroupId = usuarioOperador.Id;
        acshare5.AccountAccessLevel = 'Edit';
        acshare5.OpportunityAccessLevel = 'Edit';
        acshare5.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare5);

        AccountShare acshare6 = new AccountShare();
        acshare6.AccountId = oficinaGestora.Id;
        acshare6.UserOrGroupId = usuarioOperador.Id;
        acshare6.AccountAccessLevel = 'Edit';
        acshare6.OpportunityAccessLevel = 'Edit';
        acshare6.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare6);
        insert totalPermisos;

        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        contacto.Email = 'asdasdasd@gmail.com';
        insert contacto;

        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        caracteristica.Name = 'Campa Prueba';
        caracteristica.CC_Descripcion__c = 'Decripcion Prueba';
        insert caracteristica;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'Valoración positiva';
        mcc.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mcc.OS_Departamento__c = 'UAC';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Cajero';
        mcc.OwnerId = usuarioOperador.Id;
        insert mcc;

        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'Valoración positiva';
        mcc1.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        mcc1.OwnerId = usuarioOperador.Id;
        insert mcc1;

        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        mcc2.OwnerId = usuarioOperador.Id;
        insert mcc2;

        CC_MCC__c mcc3 = new CC_MCC__c();
        mcc3.RecordTypeId = recordCau;
        mcc3.Name = 'Valoración positiva';
        mcc3.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mcc3.CC_Motivo__c = mcc2.Id;
        mcc3.CC_Codigo_Externo__c = 'CA-000001';
        mcc3.OwnerId = usuarioOperador.Id;
        insert mcc3;

        CC_MCC__c mcc4 = new CC_MCC__c();
        mcc4.RecordTypeId = recordSol;
        mcc4.Name = 'Valoración positiva';
        mcc4.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mcc4.CC_Causa__c = mcc3.Id;
        mcc4.CC_Codigo_Externo__c = 'SO-000001';
        mcc4.OwnerId = usuarioOperador.Id;
        insert mcc4;
        

        List<Group> queuesLst = new List<Group>();
        Group newQueue = new Group();
        newQueue.Type = 'Queue';
        newQueue.DeveloperName = 'Queue_MST';
        newQueue.Name = 'Queue_MST';
        queuesLst.add(newQueue);
        newQueue = new Group();
        newQueue.Type = 'Queue';
        newQueue.DeveloperName = 'Queue_DXC';
        newQueue.Name = 'Queue_DXC';
        queuesLst.add(newQueue);
        insert queuesLst;

        // Se usa runAs para evitar un error MIXED_DML_OPERATION al insertar los QueueSobject
        List<User> sysAdminUser = [SELECT Id FROM User WHERE Profile.name LIKE 'System Administrator' AND IsActive=true];
        if (!sysAdminUser.isEmpty()) {
            System.runAs(sysAdminUser[0]) {
                List<QueueSobject> queueSobjectLst = new List<QueueSobject>();
                QueueSobject newQueueSobject;
                for (Group queue : queuesLst) {
                    newQueueSobject = new QueueSobject();
                    newQueueSobject.SobjectType = 'Case';
                    newQueueSobject.QueueId = queue.Id;
                    queueSobjectLst.add(newQueueSobject);
                }
                insert queueSobjectLst;
            }
        }
    }
    
    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountPersonAccountBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
                
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Origin = 'Agenda de Riesgos';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.CC_Tipo_Contacto__c = 'Otros';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.Description = 'Prueba Oliver9';
            caso.CC_Detalles_Consulta__c = 'prueba oliver9';
            caso.CC_Detalles_Solucion__c = 'prueba oliver9';

            Test.startTest();   
            insert caso;
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
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];

        Case caso = new Case();
        caso.Origin = 'Agenda de Riesgos';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Otros';
        caso.RecordTypeId = rtCaso;
        caso.Subject = 'pruebaAccount';
        caso.Description = 'Prueba Oliver8';
        caso.CC_Detalles_Consulta__c = 'prueba oliver8';
        caso.CC_Detalles_Solucion__c = 'prueba oliver8';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        System.runAs (usuarioOperador) {
            Test.startTest(); 
            caso.OwnerId = usuarioOperador.Id;  
            caso.AccountId = cuenta.Id;
            update caso;
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
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
            
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Origin = 'Agenda de Riesgos';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.CC_Tipo_Contacto__c = 'Otros';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_IdentCliente__c ='1';
            caso.Description = 'Prueba Oliver7';
            caso.CC_Detalles_Consulta__c = 'prueba oliver7';
            caso.CC_Detalles_Solucion__c = 'prueba oliver7';

            Test.startTest();   
            insert caso;
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
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Email__c = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '45655665P';
        update cuenta;
        
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Origin = 'Agenda de Riesgos';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.CC_Tipo_Contacto__c = 'Otros';
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_IdentCliente__c ='1';
            caso.RecordTypeId = rtCliente;
            caso.Description = 'Prueba Oliver6';
            caso.CC_Detalles_Consulta__c = 'prueba oliver6';
            caso.CC_Detalles_Solucion__c = 'prueba oliver6';

            Test.startTest();   
            insert caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, ContactId,CC_MailTelfNotif__c,CC_Numero_Documento__c,CC_DAN__c,CC_DG__c FROM Case WHERE subject = 'pruebaAccount'];
            
            
            System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, cuenta.CC_Email__c,'El numero de telefono no coinide' );
            System.AssertEquals(casoActualizado.CC_Numero_Documento__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
        }
   	}


    /**
     * Actualiza el contacto o lo genera.*/
    
    @isTest
    private static void testCcCaseModificarAccountIdentificarClienteAlfBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c,CC_NumPerso__c,CC_Numero_Documento__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Email__c = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '45655665P';
        update cuenta;

        Case caso = new Case();
        caso.Origin= 'Email';
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = rtCliente;
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono Efectivo';
        caso.AccountId = cuenta.Id;
        caso.Description = 'Prueba Oliver5';
        caso.CC_Detalles_Consulta__c = 'prueba oliver5';
        caso.CC_Detalles_Solucion__c = 'prueba oliver5';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.OwnerId = usuarioOperador.Id;
            caso.CC_IdentCliente__c ='1';
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, ContactId,CC_MailTelfNotif__c,CC_Numero_Documento__c,CC_NumPerso__c FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, cuenta.CC_Email__c,'El numero de telefono no coinide' );
            System.AssertEquals(casoActualizado.CC_Numero_Documento__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
        }
   	}

    /**
     * Actualiza el contacto o lo genera.*/
    
    @isTest
    private static void testCc_Case_Modificar_AccountIdentificarCambioClienteAlfBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_Email__c, CC_OficinaGestoraId__c,CC_NumPerso__c,CC_Numero_Documento__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Email__c = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '45655665P';
        update cuenta;

        Case caso = new Case();
        caso.Origin= 'Email';
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = rtCliente;
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono Efectivo';
        caso.Description = 'Prueba Oliver4';
        caso.CC_Detalles_Consulta__c = 'prueba oliver4';
        caso.CC_Detalles_Solucion__c = 'prueba oliver4';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.OwnerId = usuarioOperador.Id;
            caso.AccountId = cuenta.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, ContactId,CC_MailTelfNotif__c,CC_Numero_Documento__c,CC_NumPerso__c FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, cuenta.CC_Email__c,'El numero de telefono no coinide' );
            System.AssertEquals(casoActualizado.CC_Numero_Documento__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
            System.AssertEquals(casoActualizado.CC_NumPerso__c, cuenta.CC_Numero_Documento__c,'Los numeros del DNI no coinciden' );
        }
   	}     


    /**
     * Actualiza el contacto o lo genera.*/

    @isTest
    private static void testCc_Case_Modificar_AccountBlanqueoAccountBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id,PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
    
        Case caso = new Case();
        caso.Origin = 'Agenda de Riesgos';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Otros';
        caso.RecordTypeId = rtCliente;
        caso.CC_MailTelfNotif__c = 'mailnotif@mail.com';
        caso.CC_Numero_Documento__c = '45655665P';
        caso.CC_NumPerso__c = '12';
        caso.Subject = 'pruebaAccount';
        caso.AccountId = cuenta.Id;
        caso.Description = 'Prueba Oliver1';
        caso.CC_Detalles_Consulta__c = 'prueba oliver1';
        caso.CC_Detalles_Solucion__c = 'prueba oliver1';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) {
            Test.startTest();  
            caso.OwnerId = usuarioOperador.Id; 
            caso.AccountId = null;
            update caso;
            Test.stopTest();

            case casoActualizado = [SELECT Id, ContactId, CC_MailTelfNotif__c, CC_Numero_Documento__c, CC_NumPerso__c FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, null,'Los datos del contacto no coinciden' );
            System.AssertEquals(casoActualizado.CC_Numero_Documento__c, null,'Los datos del contacto no coinciden' );
            System.AssertEquals(casoActualizado.CC_NumPerso__c, null,'Los datos del contacto no coinciden' );
        }
    }

    //CC_Gestion_Caso 
    @isTest
    public static void creacionCasoBI(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];

        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Origin = 'Agenda de Riesgos';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.CC_Tipo_Contacto__c = 'Otros';
            caso.RecordTypeId = rtEmpleado;
            caso.CC_MailTelfNotif__c = 'mailnotif@mail.com';
            caso.CC_Numero_Documento__c = '45655665P';
            caso.CC_NumPerso__c = '12';
            caso.Subject = 'pruebaAccount';
            caso.AccountId = empleado.Id;
            caso.Description = 'Prueba Oliver1';
            caso.CC_Detalles_Consulta__c = 'prueba oliver1';
            caso.CC_Detalles_Solucion__c = 'prueba oliver1';

            Test.startTest();
            insert caso;
            Test.stopTest();

            Case casoActualizado = [SELECT CC_Tramo_TRZ__c, CC_CanalNotifCli__c, CC_Canal_Respuesta__c FROM Case WHERE Id = :caso.Id LIMIT 1];
            
            System.assertEquals('Recibida - En evaluacion', casoActualizado.CC_Tramo_TRZ__c, 'El tramo TRZ no se ha actualizado correctamente');
            System.assertEquals('Email', casoActualizado.CC_CanalNotifCli__c, 'El canal de notificación no se ha actualizado correctamente');
            System.assertEquals(caso.Origin, casoActualizado.CC_Canal_Respuesta__c, 'El canal de respuesta no se ha actualizado correctamente');
        }
    }
        
    //CC_Gestion_Caso
    @isTest
    private static void seInformaCanalRespuestaBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_Canal_Respuesta_Modificar__c = 'Email';
            caso.Origin = 'Agenda de Riesgos';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.CC_Tipo_Contacto__c = 'Otros';
            caso.Description = 'Prueba Oliver3';
            caso.CC_Detalles_Consulta__c = 'prueba oliver3';
            caso.CC_Detalles_Solucion__c = 'prueba oliver3';

            Test.startTest();   
            insert caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Canal_Respuesta__c, CC_Canal_Respuesta_Modificar__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(casoActualizado.CC_Canal_Respuesta__c, casoActualizado.CC_Canal_Respuesta_Modificar__c,'Los datos no coinciden' );
        }
    } 

    //CC_Gestion_Caso
    @isTest
    private static void seInformaCanalRespuestaBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_Canal_Respuesta_Modificar__c = 'Phone';
        caso.Origin = 'Agenda de Riesgos';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Otros';
        caso.Description = 'Prueba Oliver10';
        caso.CC_Detalles_Consulta__c = 'prueba oliver10';
        caso.CC_Detalles_Solucion__c = 'prueba oliver10';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
            
        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.OwnerId = usuarioOperador.Id;
            caso.CC_Canal_Respuesta_Modificar__c = 'Email';
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Canal_Respuesta__c, CC_Canal_Respuesta_Modificar__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(casoActualizado.CC_Canal_Respuesta__c, casoActualizado.CC_Canal_Respuesta_Modificar__c,'Los datos no coinciden' );
        }
    } 

    //CC_Gestion_Caso
    @isTest
    private static void actualizarAgrupadorAU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];

        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.Origin = 'Agenda de Riesgos';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.CC_Tipo_Contacto__c = 'Otros';
            caso.Description = 'Prueba Oliver11';
            caso.CC_Detalles_Consulta__c = 'prueba oliver11';
            caso.CC_Detalles_Solucion__c = 'prueba olive11';

            Test.startTest();   
            insert caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Agrupador_Id__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(casoActualizado.CC_Agrupador_Id__c, caso.CC_Agrupador_Id__c,'Los datos no coinciden' );
        }
    }


    //CC_Gestion_Caso
    @isTest
    private static void empleadoCuentaBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId, CC_Numero_Oficina__c FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE Name = 'Parent Gerencia Comercial'];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta3.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_Oficina_Afectada_Lookup__c = caso.AccountId;
        caso.CC_Oficina__c = caso.AccountId;
        caso.Origin = 'Agenda de Riesgos';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Otros';
        caso.Description = 'Prueba Oliver12';
        caso.CC_Detalles_Consulta__c = 'prueba oliver12';
        caso.CC_Detalles_Solucion__c = 'prueba oliver12';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
                
        System.runAs (usuarioOperador) {
            Test.startTest();  
            caso.OwnerId = usuarioOperador.Id; 
            caso.AccountId = cuenta.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Oficina_afectada__c, CC_Oficina__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(casoActualizado.CC_Oficina_afectada__c, cuenta.CC_Numero_Oficina__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void asociaActivoAU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA' AND LastName = 'asd' LIMIT 1];
        Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_Cliente' AND Name = 'cuenta1' LIMIT 1];

        Asset casoAsset = new Asset();
        casoAsset.Name = 'Pablo';
        casoAsset.AccountId = cuenta3.Id;
        insert casoAsset;

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.Subject = 'pruebaAccount3';
        caso.AssetId = null;
        caso.Origin = 'Agenda de Riesgos';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Otros';
        caso.Description = 'Prueba Oliver13';
        caso.CC_Detalles_Consulta__c = 'prueba oliver13';
        caso.CC_Detalles_Solucion__c = 'prueba oliver13';
        caso.OwnerId = usuarioOperador.Id; 
        insert caso;

        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.AssetId = casoAsset.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Oficina__c, ContactId FROM Case WHERE subject = 'pruebaAccount3'];
            
            System.AssertEquals(casoActualizado.CC_Oficina__c, cuenta3.Id,'Los datos no coinciden' );
        }
    }


    //CC_Gestion_Caso
    @isTest
    private static void tematicaInformadoBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
        

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_Codigo_Externo_Tematica__c = null;
        caso.CC_MCC_Tematica__c = null;
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver14';
        caso.CC_Detalles_Consulta__c = 'prueba oliver14';
        caso.CC_Detalles_Solucion__c = 'prueba oliver14';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) { 
            Test.startTest();
            caso.OwnerId = usuarioOperador.Id;
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Tematica__c,CC_Tematica__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(mccTematica.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Tematica__c,'Los datos no coinciden' );
            System.AssertEquals(mccTematica.Name, casoActualizado.CC_Tematica__c,'Los datos no coinciden' );
        }
    }

    @isTest
    private static void tematicaInformadoBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
    
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_Codigo_Externo_Tematica__c = null;
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.Origin = 'Email';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.Description = 'Prueba Oliver15';
            caso.CC_Detalles_Consulta__c = 'prueba oliver15';
            caso.CC_Detalles_Solucion__c = 'prueba oliver15';

            Test.startTest();
            insert caso;
            Test.stopTest();

            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Tematica__c,CC_Tematica__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(mccTematica.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Tematica__c,'Los datos no coinciden' );
            System.AssertEquals(mccTematica.Name, casoActualizado.CC_Tematica__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void productoInformadoBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
        
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_Codigo_Externo_Producto__c = null;
        caso.CC_MCC_ProdServ__c = null;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver16';
        caso.CC_Detalles_Consulta__c = 'prueba oliver16';
        caso.CC_Detalles_Solucion__c = 'prueba oliver16';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
            
        System.runAs (usuarioOperador) {
            Test.startTest();  
            caso.OwnerId = usuarioOperador.Id; 
            caso.CC_MCC_ProdServ__c = mccProducto.Id; 
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Producto__c,CC_Producto_Servicio__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(mccProducto.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Producto__c,'Los datos no coinciden' );
            System.AssertEquals(mccProducto.Name, casoActualizado.CC_Producto_Servicio__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void productoInformadoBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
                    
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_Codigo_Externo_Producto__c = null;
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.Origin = 'Email';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.Description = 'Prueba Oliver17';
            caso.CC_Detalles_Consulta__c = 'prueba oliver17';
            caso.CC_Detalles_Solucion__c = 'prueba oliver17';

            Test.startTest();   
            insert caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Producto__c,CC_Producto_Servicio__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            
            System.AssertEquals(mccProducto.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Producto__c,'Los datos no coinciden' );
            System.AssertEquals(mccProducto.Name, casoActualizado.CC_Producto_Servicio__c,'Los datos no coinciden' );
        }
    }
    
    //CC_Gestion_Caso
    @isTest
    private static void motivoInformadoBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccMotivo = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Motivo' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_Codigo_Externo_Motivo__c = null;
        caso.CC_MCC_Motivo__c = null;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver18';
        caso.CC_Detalles_Consulta__c = 'prueba oliver18';
        caso.CC_Detalles_Solucion__c = 'prueba oliver18';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.OwnerId = usuarioOperador.Id; 
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Motivo__c,CC_Motivo__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(mccMotivo.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Motivo__c,'Los datos no coinciden' );
            System.AssertEquals(mccMotivo.Name, casoActualizado.CC_Motivo__c,'Los datos no coinciden' );
        }
    }

    @isTest
    private static void motivoInformadoBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccMotivo = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Motivo' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.Origin = 'Email';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.Description = 'Prueba Oliver19';
            caso.CC_Detalles_Consulta__c = 'prueba oliver19';
            caso.CC_Detalles_Solucion__c = 'prueba oliver19';

            Test.startTest();
            insert caso;
            Test.stopTest();

            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Motivo__c,CC_Motivo__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(mccMotivo.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Motivo__c,'Los datos no coinciden' );
            System.AssertEquals(mccMotivo.Name, casoActualizado.CC_Motivo__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void causaInformadoBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];
        
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_Codigo_Externo_Causa__c = null;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            caso.Origin = 'Email';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.Description = 'Prueba Oliver20';
            caso.CC_Detalles_Consulta__c = 'prueba oliver20';
            caso.CC_Detalles_Solucion__c = 'prueba oliver20';

            Test.startTest();   
            insert caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Causa__c,CC_Causa__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            
            System.AssertEquals(mccCausa.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Causa__c,'Los datos no coinciden' );
            System.AssertEquals(mccCausa.Name, casoActualizado.CC_Causa__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void causaInformadoBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'asd'];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];
        
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Causa__c = null;
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver21';
        caso.CC_Detalles_Consulta__c = 'prueba oliver21';
        caso.CC_Detalles_Solucion__c = 'prueba oliver21';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) {
            Test.startTest();
            caso.OwnerId = usuarioOperador.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            update caso;
            Test.stopTest();

            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Causa__c,CC_Causa__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(mccCausa.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Causa__c,'Los datos no coinciden' );
            System.AssertEquals(mccCausa.Name, casoActualizado.CC_Causa__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void solucionInformadoBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];
                
        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_Codigo_Externo_Causa__c = null;
            caso.CC_MCC_Solucion__c = mccSolucion.Id;
            caso.Origin = 'Email';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.Description = 'Prueba Oliver22';
            caso.CC_Detalles_Consulta__c = 'prueba oliver22';
            caso.CC_Detalles_Solucion__c = 'prueba oliver22';

            Test.startTest();   
            insert caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id,CC_Solucion__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
            
            System.AssertEquals(mccSolucion.Name, casoActualizado.CC_Solucion__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void solucionInformadoBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'asd'];
        CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Solucion__c = null;
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver23';
        caso.CC_Detalles_Consulta__c = 'prueba oliver23';
        caso.CC_Detalles_Solucion__c = 'prueba oliver23';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            caso.OwnerId = usuarioOperador.Id;
            caso.CC_MCC_Solucion__c = mccSolucion.Id;
            update caso;
            Test.stopTest();

            case casoActualizado = [SELECT Id,CC_Solucion__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(mccSolucion.Name, casoActualizado.CC_Solucion__c,'Los datos no coinciden' );
        }
    }

    ///CC_Gestion_Caso
    @isTest
    private static void actualizarColaProcedenciaBU() { 
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Group grupo = [SELECT Id, DeveloperName FROM Group WHERE Name = 'Queue_DXC'];
                    
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.Subject = 'pruebaAccount1';
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver24';
        caso.CC_Detalles_Consulta__c = 'prueba oliver24';
        caso.CC_Detalles_Solucion__c = 'prueba oliver24';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = grupo.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
                    
        System.runAs (usuarioAdmin) {
            Test.startTest();   
            caso.OwnerId = grupo.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Cola_Procedencia__c , ContactId FROM Case WHERE subject = 'pruebaAccount1'];
            
            System.AssertEquals(grupo.DeveloperName, casoActualizado.CC_Cola_Procedencia__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void informarOficinaAfectadaDetalleBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName LIKE 'CC_%' LIMIT 1];
        
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta3.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Case caso = new Case();
        caso.AccountId = null;
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.Subject = 'pruebaAccount2';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver25';
        caso.CC_Detalles_Consulta__c = 'prueba oliver25';
        caso.CC_Detalles_Solucion__c = 'prueba oliver25';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.CC_Oficina__c = cuenta3.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,CC_Oficina__c, ContactId FROM Case WHERE subject = 'pruebaAccount2' LIMIT 1];
            System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, casoActualizado.CC_Oficina__c,'Los datos no coinciden' );
        }
    }


    //CC_Gestion_Caso
    @isTest
    private static void informarOficinaAfectadaBI() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName LIKE 'CC_%' LIMIT 1];

        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.CC_Oficina__c = cuenta.Id;
            caso.AccountId = cuenta.Id;
            caso.Origin = 'Email';
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.Subject = 'pruebaAccount';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
            caso.Description = 'Prueba Oliver26';
            caso.CC_Detalles_Consulta__c = 'prueba oliver26';
            caso.CC_Detalles_Solucion__c = 'prueba oliver26';

            Test.startTest();   
            insert caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,AccountId, ContactId FROM Case WHERE subject = 'pruebaAccount' LIMIT 1];
            Account cuentaTest = [SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

            System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, cuentaTest.CC_OficinaGestoraId__c,'Los datos no coinciden' );
        }
    }

    //CC_Gestion_Caso
    @isTest
    private static void informarOficinaAfectadaBU() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName  LIKE 'CC_%' LIMIT 1];
        Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName  LIKE 'CC_%' LIMIT 1];
        
        Case caso = new Case();
        caso.CC_Oficina__c = cuenta.Id;
        caso.AccountId = cuenta.Id;
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.Subject = 'pruebaAccount';
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c ='Otros';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.Description = 'Prueba Oliver27';
        caso.CC_Detalles_Consulta__c = 'prueba oliver27';
        caso.CC_Detalles_Solucion__c = 'prueba oliver27';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.OwnerId = usuarioOperador.Id;
            caso.AccountId = cuenta3.Id;
            update caso;
            Test.stopTest();
            
            case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,AccountId, ContactId FROM Case WHERE subject = 'pruebaAccount' LIMIT 1];
            Account cuentaTest = [SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

            System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, cuentaTest.CC_OficinaGestoraId__c,'Los datos no coinciden' );
        }
    }

    @isTest
    private static void informarCentroManipulador() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.Name = 'Grupo Trabajo Prueba';
        grupoColaborador.OS_GrupoTrabajo__c = 'Grupo Trabajo Prueba';
        grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        insert grupoColaborador;

        OS_Cartera__c centroManipulador = new OS_Cartera__c(); 
        centroManipulador.Name = 'centro manipulador test oliver';
        centroManipulador.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OS_Cartera__c', 'OS_Centro_Manipulador');
        centroManipulador.OS_GrupoTrabajo__r = grupoColaborador;
        insert centroManipulador;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account prueba';
        cuenta.OS_Centro_Manipulador__c = centroManipulador.Id; 
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.CC_Oficina__c = cuenta.Id;
            caso.AccountId = cuenta.Id;
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.Subject = 'pruebaAccount2';
            caso.Origin = 'Email';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Buzón Efectivo COPS';
            caso.Description = 'Prueba Oliver28';
            caso.CC_Detalles_Consulta__c = 'prueba oliver28';
            caso.CC_Detalles_Solucion__c = 'prueba oliver28';
            caso.OS_ViaClasificacion__c = 'Por defecto';
            caso.OS_ReglaUtilizada__c = null;

            Test.startTest();   
            insert caso;
            Test.stopTest();
                        
            Case casoActualizado = [SELECT Id, OS_Centro_Manipulador__c, AccountId FROM Case WHERE subject = 'pruebaAccount2' LIMIT 1];
            Account cuentaTest = [SELECT Id, OS_Centro_Manipulador__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

            System.assertEquals(casoActualizado.OS_Centro_Manipulador__c, cuentaTest.OS_Centro_Manipulador__c,'Los datos no coinciden' );
        }
    }

    /*@isTest
    private static void acuseReciboValijaDigital() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account prueba';
        cuenta.CC_Email__c = 'destino.email@prueba.com';
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.CC_Oficina__c = cuenta.Id;
            caso.AccountId = cuenta.Id;
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.Subject = 'pruebaValijaDigital';
            caso.Origin = 'Valija digital';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Valija digital';
            caso.Description = 'Prueba';
            caso.OS_Referencia_Valija__c = '14092023-00000000001';

            Test.startTest();   
            List<EmailMessage> emBefore = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
            insert caso;
            List<EmailMessage> emAfter = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
            System.assertNotEquals(emBefore.size(), emAfter.size(), 'El acuse no se ha enviado.' );
            Test.stopTest();
        }
    }*/
}