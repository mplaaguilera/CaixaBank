@isTest
public with sharing class AM_CaseTriggerHelper_Test {
    
    @testSetup
    static void data(){
              
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

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
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Cajero';
        insert mcc;

        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'Valoración positiva';
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
        System.debug('queues: '+queuesLst);
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
        
    	Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];

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

    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountPersonAccountBU() {
        
    	Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];

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

    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountIdentificarClienteAlfBI() {
        
    	Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
        
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

    /**
     * Actualiza el contacto o lo genera.
    */
    @isTest
    private static void testCcCaseModificarAccountIdentificarClienteAlfExtensionBI() {
        
        Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
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


    /**
     * Actualiza el contacto o lo genera.*/
    
    @isTest
    private static void testCcCaseModificarAccountIdentificarClienteAlfBU() {
        
    	Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c,CC_NumPerso__c,CC_Numero_Documento__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Numero_Documento__c = '45655665P';
        Database.Update(cuenta);

        Case caso = new Case();
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = rtCliente;
        caso.CC_Canal_Procedencia__c = 'Buzón Valores';
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


    /**
     * Actualiza el contacto o lo genera.*/
    
     @isTest
        private static void identificarCambioClienteAlfBU() {
        
    	Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id, PersonContactId, CC_OficinaGestoraId__c,CC_NumPerso__c,CC_Numero_Documento__c FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA'];
        cuenta.CC_NumPerso__c = '12';
        cuenta.CC_Numero_Documento__c = '45655665P';
        Database.Update(cuenta);

        Case caso = new Case();
        caso.Subject = 'pruebaAccount';
        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = rtCliente;
        caso.CC_Canal_Procedencia__c = 'Buzón Valores';
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


    /**
     * Actualiza el contacto o lo genera.*/
    
     @isTest
        private static void blanqueoAccountBU() {

        Id rtCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id,PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
       
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

        //CC_Gestion_Caso 
        
       @isTest
       public static void creacionCasoBI()
       {
           Id rtEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
           Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Test' limit 1];
           List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];
           Case caso = new Case();
           caso.AccountId = empleado.Id;
           caso.ContactId = contacto.Id;
           caso.OwnerId = ownerLst[0].Id;
           caso.Status = 'Activo';
           caso.CC_Idioma__c = 'es';
           caso.Subject = 'Prueba';
           caso.CC_Tipo_Cliente__c = 'Cliente';
           caso.Origin = 'Email';
           caso.CC_Tipo_Contacto__c = 'Consulta';
           caso.CC_Canal_Procedencia__c = 'Buzón Valores';
           caso.RecordTypeId = rtEmpleado;

           Test.startTest();
           Database.insert(caso);
           Test.stopTest();

           Case casoActualizado = [SELECT CC_Tramo_TRZ__c, CC_CanalNotifCli__c, CC_Canal_Respuesta__c FROM Case WHERE Id = :caso.Id LIMIT 1];
           
           System.assertEquals('Recibida - En evaluacion', casoActualizado.CC_Tramo_TRZ__c, 'El tramo TRZ no se ha actualizado correctamente');
           System.assertEquals('Email', casoActualizado.CC_CanalNotifCli__c, 'El canal de notificación no se ha actualizado correctamente');
           System.assertEquals(caso.Origin, casoActualizado.CC_Canal_Respuesta__c, 'El canal de respuesta no se ha actualizado correctamente');
       }

       //CC_Gestion_Caso
       @isTest
       private static void creacionCasoPropuestasBI() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
   
           Case caso = new Case();
           caso.Origin = 'Propuestas de mejora';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta.Id;
           caso.Subject = 'pruebaAccount';
           caso.Description = 'Hola';
                    
           Test.startTest();   
           Database.insert(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Descripcion_Problematica__c, CC_Titulo_Propuesta__c, Description, Subject, ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(casoActualizado.CC_Descripcion_Problematica__c, casoActualizado.Description,'Los datos del contacto no coinciden' );
           System.AssertEquals(casoActualizado.CC_Titulo_Propuesta__c, casoActualizado.Subject,'Los datos del contacto no coinciden' );
          }  
       
       //CC_Gestion_Caso
       @isTest
       private static void seInformaCanalRespuestaBI() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
   
           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta.Id;
           caso.Subject = 'pruebaAccount';
           caso.CC_Canal_Respuesta_Modificar__c = 'Email';
                    
           Test.startTest();   
           Database.insert(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Canal_Respuesta__c, CC_Canal_Respuesta_Modificar__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(casoActualizado.CC_Canal_Respuesta__c, casoActualizado.CC_Canal_Respuesta_Modificar__c,'Los datos no coinciden' );
           
          } 

       //CC_Gestion_Caso
       @isTest
       private static void seInformaCanalRespuestaBU() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
   
           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta.Id;
           caso.Subject = 'pruebaAccount';
           caso.CC_Canal_Respuesta_Modificar__c = 'Phone';
           Database.insert(caso);
                    
           Test.startTest();   
           caso.CC_Canal_Respuesta_Modificar__c = 'Email';
           Database.update(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Canal_Respuesta__c, CC_Canal_Respuesta_Modificar__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(casoActualizado.CC_Canal_Respuesta__c, casoActualizado.CC_Canal_Respuesta_Modificar__c,'Los datos no coinciden' );
           
           
          } 

       //CC_Gestion_Caso
       @isTest
       private static void actualizarAgrupadorAU() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
   
           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta.Id;
           caso.Subject = 'pruebaAccount';
           
           Test.startTest();   
           Database.insert(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Agrupador_Id__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(casoActualizado.CC_Agrupador_Id__c, caso.CC_Agrupador_Id__c,'Los datos no coinciden' );
           
          }


       //CC_Gestion_Caso
       @isTest
       private static void empleadoCuentaBU() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId, CC_Numero_Oficina__c FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
           Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE Name = 'Parent Gerencia Comercial'];
   
           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta3.Id;
           caso.Subject = 'pruebaAccount';
           caso.CC_Oficina_Afectada_Lookup__c = caso.AccountId;
           caso.CC_Oficina__c = caso.AccountId;
           Database.insert(caso);
                    
           Test.startTest();   
           caso.AccountId = cuenta.Id;
           Database.update(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Oficina_afectada__c, CC_Oficina__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(casoActualizado.CC_Oficina_afectada__c, cuenta.CC_Numero_Oficina__c,'Los datos no coinciden' );
           
          }

          //CC_Gestion_Caso
       @isTest
       private static void asociaActivoAU() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA' LIMIT 1];
           Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_Cliente' LIMIT 1];
   
           Asset casoAsset = new Asset();
           casoAsset.Name = 'Pablo';
           casoAsset.AccountId = cuenta3.Id;
           Database.insert(casoAsset);

           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.Subject = 'pruebaAccount';
           caso.AssetId = null;
           Database.insert(caso);

           Test.startTest();   
           caso.AssetId = casoAsset.Id;
           Database.update(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Oficina__c, ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(casoActualizado.CC_Oficina__c, cuenta3.Id,'Los datos no coinciden' );
           
          }


           //CC_Gestion_Caso
         @isTest
           private static void tematicaInformadoBU() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
           CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
           

           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta.Id;
           caso.Subject = 'pruebaAccount';
           caso.CC_Codigo_Externo_Tematica__c = null;
           caso.CC_MCC_Tematica__c = null;
           Database.insert(caso);

                    
           Test.startTest();
           caso.CC_MCC_Tematica__c = mccTematica.Id;
           Database.update(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Codigo_Externo_Tematica__c,CC_Tematica__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           
           System.AssertEquals(mccTematica.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Tematica__c,'Los datos no coinciden' );
           System.AssertEquals(mccTematica.Name, casoActualizado.CC_Tematica__c,'Los datos no coinciden' );
           
          }

          @isTest
            private static void tematicaInformadoBI() {

            Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
            Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
            CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_Codigo_Externo_Tematica__c = null;
            caso.CC_MCC_Tematica__c = mccTematica.Id;
        
            Test.startTest();
            Database.insert (caso);
            Test.stopTest();

            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Tematica__c,CC_Tematica__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(mccTematica.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Tematica__c,'Los datos no coinciden' );
            System.AssertEquals(mccTematica.Name, casoActualizado.CC_Tematica__c,'Los datos no coinciden' );
        }


           //CC_Gestion_Caso
         @isTest
           private static void productoInformadoBU() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
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
           Database.insert(caso);
                    
           Test.startTest();   
           caso.CC_MCC_ProdServ__c = mccProducto.Id; 
           Database.Update(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Codigo_Externo_Producto__c,CC_Producto_Servicio__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           
           System.AssertEquals(mccProducto.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Producto__c,'Los datos no coinciden' );
           System.AssertEquals(mccProducto.Name, casoActualizado.CC_Producto_Servicio__c,'Los datos no coinciden' );
           
          }

           //CC_Gestion_Caso
         @isTest
         private static void productoInformadoBI() {
         
         Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
         Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
         CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
         CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
         

         Case caso = new Case();
         caso.Status = 'Activo';
         caso.RecordTypeId = rtCaso;
         caso.AccountId = cuenta.Id;
         caso.Subject = 'pruebaAccount';
         caso.CC_Codigo_Externo_Producto__c = null;
         caso.CC_MCC_Tematica__c = mccTematica.Id;
         caso.CC_MCC_ProdServ__c = mccProducto.Id;
                  
         Test.startTest();   
         Database.insert(caso);
         Test.stopTest();
         
         case casoActualizado = [SELECT Id, CC_Codigo_Externo_Producto__c,CC_Producto_Servicio__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
         
         
         System.AssertEquals(mccProducto.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Producto__c,'Los datos no coinciden' );
         System.AssertEquals(mccProducto.Name, casoActualizado.CC_Producto_Servicio__c,'Los datos no coinciden' );
         
        }
          

          //CC_Gestion_Caso
       @isTest
       private static void motivoInformadoBU() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
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
           Database.insert(caso);
                    
           Test.startTest();   
           caso.CC_MCC_Motivo__c = mccMotivo.Id;
           Database.update(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Codigo_Externo_Motivo__c,CC_Motivo__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(mccMotivo.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Motivo__c,'Los datos no coinciden' );
           System.AssertEquals(mccMotivo.Name, casoActualizado.CC_Motivo__c,'Los datos no coinciden' );
           
          }

          @isTest
            private static void motivoInformadoBI() {
            Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
            Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
            CC_MCC__c mccMotivo = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Motivo' LIMIT 1];
            CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
            CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.AccountId = cuenta.Id;
            caso.Subject = 'pruebaAccount';
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
        
            Test.startTest();
            insert caso;
            Test.stopTest();

            case casoActualizado = [SELECT Id, CC_Codigo_Externo_Motivo__c,CC_Motivo__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

            System.AssertEquals(mccMotivo.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Motivo__c,'Los datos no coinciden' );
            System.AssertEquals(mccMotivo.Name, casoActualizado.CC_Motivo__c,'Los datos no coinciden' );
    }

        //CC_Gestion_Caso
       @isTest
       private static void causaInformadoBI() {
           
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
           CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];
           

           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta.Id;
           caso.Subject = 'pruebaAccount';
           caso.CC_Codigo_Externo_Causa__c = null;
           caso.CC_MCC_Causa__c = mccCausa.Id;

                    
           Test.startTest();   
           Database.insert(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Codigo_Externo_Causa__c,CC_Causa__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           
           System.AssertEquals(mccCausa.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Causa__c,'Los datos no coinciden' );
           System.AssertEquals(mccCausa.Name, casoActualizado.CC_Causa__c,'Los datos no coinciden' );
           
          }

          //CC_Gestion_Caso
    @isTest
    private static void causaInformadoBU() {
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'asd'];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];
        
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Subject = 'pruebaAccount';
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Causa__c = null;
        insert caso;

        Test.startTest();
        caso.CC_MCC_Causa__c = mccCausa.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Causa__c,CC_Causa__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

        System.AssertEquals(mccCausa.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Causa__c,'Los datos no coinciden' );
        System.AssertEquals(mccCausa.Name, casoActualizado.CC_Causa__c,'Los datos no coinciden' );
    }

          //CC_Gestion_Caso
       @isTest
       private static void solucionInformadoBI() {
           
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
           CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];
           

           Case caso = new Case();
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.AccountId = cuenta.Id;
           caso.Subject = 'pruebaAccount';
           caso.CC_Codigo_Externo_Causa__c = null;
           caso.CC_MCC_Solucion__c = mccSolucion.Id;

                    
           Test.startTest();   
           Database.insert(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id,CC_Solucion__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(mccSolucion.Name, casoActualizado.CC_Solucion__c,'Los datos no coinciden' );
           
          }

            //CC_Gestion_Caso
    @isTest
    private static void solucionInformadoBU() {
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
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
        insert caso;
        
        Test.startTest();
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id,CC_Solucion__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];

        System.AssertEquals(mccSolucion.Name, casoActualizado.CC_Solucion__c,'Los datos no coinciden' );
    }

           //CC_Gestion_Caso
       @isTest
       private static void actualizarColaProcedenciaBU() { 
           Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
           Group grupo = [SELECT Id, DeveloperName FROM Group WHERE Name = 'Queue_DXC'];
           List<User> sysAdminUser = [SELECT Id FROM User WHERE Profile.name LIKE 'System Administrator' AND IsActive=true]; 
           System.runAs(sysAdminUser[0]){
                      
           Case caso = new Case();
           caso.Origin = 'Email';
           caso.Status = 'Activo';
           caso.RecordTypeId = rtCaso;
           caso.Subject = 'pruebaAccount';
           Database.insert(caso);
                    
           Test.startTest();   
           caso.OwnerId = grupo.Id;
           Database.update(caso);
           Test.stopTest();
           
           case casoActualizado = [SELECT Id, CC_Cola_Procedencia__c , ContactId FROM Case WHERE subject = 'pruebaAccount'];
           
           System.AssertEquals(grupo.DeveloperName, casoActualizado.CC_Cola_Procedencia__c,'Los datos no coinciden' );
           }
          }

//CC_Gestion_Caso
@isTest
private static void informarOficinaAfectadaDetalleBU() {
    
    Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
    Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName LIKE 'CC_%' LIMIT 1];
    Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName LIKE 'CC_%' LIMIT 1];
    
    Case caso = new Case();
    caso.AccountId = null;
    caso.Origin = 'Email';
    caso.Status = 'Activo';
    caso.RecordTypeId = rtCaso;
    caso.Subject = 'pruebaAccount';
    
    Database.insert(caso);
             
    Test.startTest();   
    caso.CC_Oficina__c = cuenta3.Id;
    Database.update(caso);
    Test.stopTest();
    
    case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,CC_Oficina__c, ContactId FROM Case WHERE subject = 'pruebaAccount' LIMIT 1];
    System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, casoActualizado.CC_Oficina__c,'Los datos no coinciden' );
   }


   //CC_Gestion_Caso
@isTest
private static void informarOficinaAfectadaBI() {
    
    Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
    Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName LIKE 'CC_%' LIMIT 1];
    
    Case caso = new Case();
    caso.CC_Oficina__c = cuenta.Id;
    caso.AccountId = cuenta.Id;
    caso.Origin = 'Email';
    caso.Status = 'Activo';
    caso.RecordTypeId = rtCaso;
    caso.Subject = 'pruebaAccount';

    Test.startTest();   
    Database.insert(caso);
    Test.stopTest();
    
    case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,AccountId, ContactId FROM Case WHERE subject = 'pruebaAccount' LIMIT 1];
    Account cuentaTest = [SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

    System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, cuentaTest.CC_OficinaGestoraId__c,'Los datos no coinciden' );

   }

   //CC_Gestion_Caso
@isTest
private static void informarOficinaAfectadaBU() {
    
    Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
    Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName  LIKE 'CC_%' LIMIT 1];
    Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName  LIKE 'CC_%' LIMIT 1];
    
    Case caso = new Case();
    caso.CC_Oficina__c = cuenta.Id;
    caso.AccountId = cuenta.Id;
    caso.Origin = 'Email';
    caso.Status = 'Activo';
    caso.RecordTypeId = rtCaso;
    caso.Subject = 'pruebaAccount';
    Database.insert(caso);

    Test.startTest();   
    caso.AccountId = cuenta3.Id;
    Database.update(caso);
    Test.stopTest();
    
    case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,AccountId, ContactId FROM Case WHERE subject = 'pruebaAccount' LIMIT 1];
    Account cuentaTest = [SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

    System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, cuentaTest.CC_OficinaGestoraId__c,'Los datos no coinciden' );

}
    }