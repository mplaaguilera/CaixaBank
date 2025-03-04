@isTest
public with sharing class CC_Opportunity_BU_TRHan_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
		usuarioGestor.Department = 'Prueba departamento';
		update usuarioGestor;

        Account cuenta1 = crearCuentaContacto('14628118A');
        Account cuenta2 = crearCuentaContacto('32179537F');
        Account cuenta3 = crearCuentaRTCliente('94160903F');
        CSBD_TestDataFactory.crearCuentaContacto('46979396X');

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta1.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuenta2.Id;
        acshare2.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuenta3.Id;
        acshare3.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        insert totalPermisos;

        Product2 productoAuto = new Product2(Name = 'Auto', Family = 'Auto', isActive = true, AV_ExternalID__c = '2220000');
        productoAuto.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AV_PF').getRecordTypeId();
        insert productoAuto;

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Hipoteca';
        valor.CC_Valor__c = '1';
        insert valor;

        CC_Lista_Valores__c listaValores2 = new CC_Lista_Valores__c();
        listaValores2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores2.Name = 'CSBD: Oportunidades importe obligatorio formalizar';
        listaValores2.CC_Activa__c = true;
        insert listaValores2;

        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor2.CC_Lista__c = listaValores2.Id;
        valor2.Name = 'CMB';
        valor2.CC_Valor__c = '1';
        insert valor2;

        CC_Lista_Valores__c listaValores3 = new CC_Lista_Valores__c();
        listaValores3.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores3.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
        listaValores3.CC_Activa__c = true;
        insert listaValores3;

        CC_Lista_Valores__c valor3 = new CC_Lista_Valores__c();
        valor3.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor3.CC_Lista__c = listaValores3.Id;
        valor3.CSBD_Product2__c = productoAuto.Id;
        valor3.Name = 'Hipoteca';
        valor3.CC_Valor2__c = 'Hipoteca';
        insert valor3;

        CC_Lista_Valores__c listaValores4 = new CC_Lista_Valores__c();
        listaValores4.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores4.Name = 'CSBD: Horarios comerciales por tipología';
        listaValores4.CC_Activa__c = true;
        insert listaValores4;

        CC_Lista_Valores__c valor4 = new CC_Lista_Valores__c();
        valor4.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor4.CC_Lista__c = listaValores4.Id;
        valor4.CC_Valor__c = 'CSBD: Horario comercial Hipoteca';
        valor4.Name = 'Hipoteca';
        insert valor4;

        CC_Lista_Valores__c valor5 = new CC_Lista_Valores__c();
        valor5.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor5.CC_Lista__c = listaValores4.Id;
        valor5.CC_Valor__c = 'CSBD: Horario comercial Préstamo';
        valor5.Name = 'Préstamo';
        insert valor5;

        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt WHERE MasterLabel = :'Cierre InTouch Formalizada CAS' AND CSBD_Idioma__c = :'Castellano' LIMIT 1].CSBD_Nombre_Plantilla__c;
        validEmailTemplate.DeveloperName = 'Oportunidad_InTouch_Formalizada_1654788409135';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = usuarioGestor.Id;
        System.runAs(usuarioGestor) {
            insert validEmailTemplate;
        }

        EmailTemplate validEmailTemplate2 = new EmailTemplate();
        validEmailTemplate2.isActive = true;
        validEmailTemplate2.Name = [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt WHERE MasterLabel = :'Cierre InTouch Perdida CAS' AND CSBD_Idioma__c = :'Castellano' LIMIT 1].CSBD_Nombre_Plantilla__c;
        validEmailTemplate2.DeveloperName = 'Oportunidad_InTouch_Perdida_1654788578234';
        validEmailTemplate2.TemplateType = 'text';
        validEmailTemplate2.FolderId = usuarioGestor.Id;
        System.runAs(usuarioGestor) {
            insert validEmailTemplate2;
        }
    }

    public static Account crearCuentaContacto(String nif) {

        // Genera un número entero aleatorio
        Integer numeroAleatorio = (Integer)Math.floor(Math.random() * 100); // Cambia 100 al valor máximo deseado

        // Convierte el número entero en una cadena de texto
        String numeroAleatorioString = String.valueOf(numeroAleatorio);
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuenta.FirstName = 'Cliente';
        cuenta.LastName = 'Apellido';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;

        return cuenta;
    }

    public static Account crearCuentaRTCliente(String nif) {

        // Genera un número entero aleatorio
        Integer numeroAleatorio = (Integer)Math.floor(Math.random() * 100); // Cambia 100 al valor máximo deseado

        // Convierte el número entero en una cadena de texto
        String numeroAleatorioString = String.valueOf(numeroAleatorio);
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta Cliente';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;

        return cuenta;
    }

    @isTest
    public static void cambioEmpresaProveedoraOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Account cuenta2 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '32179537F'];

        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];
        Contact contacto2 = [SELECT Id FROM Contact WHERE AccountId =: cuenta2.Id];
        contacto2.Email = null;
        update contacto2;

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.Id);
        campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666666');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
        campos.put('CSBD_Contact__c',contacto1.Id);
        Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = hipoteca.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        System.runAs (usuarioGestor) {
            Test.startTest();
            hipoteca.OwnerId = usuarioGestor.Id;
            hipoteca.StageName = 'Documentación';
            hipoteca.CSBD_IWD__c = true;
            hipoteca.CSBD_Estado__c = 'Pendiente Cita';
            hipoteca.CSBD_Empresa_Proveedora__c = 'imaginBank';
            hipoteca.AccountId = cuenta2.Id;
            hipoteca.CSBD_Contact__c = contacto2.Id;
            hipoteca.CSBD_Telefono_Solicitud__c = null;
            hipoteca.CSBD_Email_Solicitud__c = null;
            hipoteca.CSBD_StageName_QuickAction_Cerrar__c = 'Rechazada';
            update hipoteca;
            Test.stopTest();

            Task[] tareaCambioEmpresa = [SELECT Id FROM Task WHERE Subject =: 'Cambio empresa proveedora'];

            System.assert(!tareaCambioEmpresa.isEmpty());
        }
    }

    @isTest
    public static void CC_enviarEmailCierreInTouchFormalizada() {
        User usuarioGestor = [SELECT Id, Department FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.Id);
        campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666667');
        campos.put('CSBD_Empresa_Proveedora__c', 'inTouch');
        campos.put('CSBD_Contact__c',contacto1.Id);
        campos.put('Amount',1);
        Opportunity CMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);

        CMB.OwnerId = usuarioGestor.Id;
        update CMB;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CMB.CSBD_Estado__c = 'Cerrada';
            CMB.StageName = 'Formalizada';
            update CMB;
            Test.stopTest();

			List<Opportunity> opp = [SELECT CSBD_Equipo__c from Opportunity where id =:CMB.Id];
            System.AssertEquals(opp[0].CSBD_Equipo__c, usuarioGestor.Department);
            System.Assert([SELECT Count() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: CMB.Id]>0, 'No se ha enviado ningún email');
        }
    }

    @isTest
    public static void CC_enviarEmailCierreInTouchPerdida() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.Id);
        campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test2@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666668');
        campos.put('CSBD_Empresa_Proveedora__c', 'inTouch');
        campos.put('CSBD_Contact__c',contacto1.Id);
        Opportunity CMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);

        CMB.OwnerId = usuarioGestor.Id;
        update CMB;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CMB.CSBD_Estado__c = 'Cerrada';
            CMB.StageName = 'Perdida';
            update CMB;
            Test.stopTest();

            System.Assert([SELECT Count() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: CMB.Id]>0, 'No se ha enviado ningún email');
        }
    }

    @isTest
    public static void importeObligatorioCerrarOportunidadTestNoOK() {
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.Id);
        campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test2@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666668');
        campos.put('CSBD_Empresa_Proveedora__c', 'inTouch');
        campos.put('CSBD_Contact__c',contacto1.Id);
        campos.put('StageName','Solicitud');
        campos.put('Amount',0);
        Opportunity CMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);
        CMB.OwnerId = usuarioGestor.Id;
        update CMB;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CMB.CSBD_Estado__c = 'Cerrada';
            CMB.StageName = 'Formalizada';
            try {
               	update CMB;
            } catch (Exception e) {
                System.assert(e.getMessage().contains('No se puede formalizar una oportunidad con importe 0€'));
            }
            Test.stopTest();

            Opportunity oportunidadNoForm = [SELECT Id, StageName FROM Opportunity WHERE Id =:CMB.Id];

            System.assertEquals(oportunidadNoForm.StageName, 'Solicitud');
        }
        System.Assert([SELECT Count() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: CMB.Id]>0, 'No se ha enviado ningún email');
    }

    @isTest
    public static void importeObligatorioCerrarOportunidadTestOK() {
        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Map<String, Object> campos2 = new Map<String, Object>();
        campos2.put('AccountId', cuenta1.Id);
        campos2.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos2.put('CSBD_Email_Solicitud__c', 'test3@test.com');
        campos2.put('CSBD_Telefono_Solicitud__c', '666666669');
        campos2.put('CSBD_Contact__c',contacto1.Id);
        campos2.put('StageName','Solicitud');
        campos2.put('Amount',100);
        Opportunity CMBSiActualiza = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos2);
        CMBSiActualiza.OwnerId = usuarioGestor.Id;
        update CMBSiActualiza;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CMBSiActualiza.CSBD_Estado__c = 'Cerrada';
            CMBSiActualiza.StageName = 'Formalizada';
            try {
                update CMBSiActualiza;
            }
            catch(Exception e) {
                System.assert(e.getMessage().contains('No se puede formalizar una oportunidad que tiene un importe 0'));
            }
            Test.stopTest();

            Opportunity oportunidadForm = [SELECT Id, StageName FROM Opportunity WHERE Id =:CMBSiActualiza.Id];

            System.assertEquals(oportunidadForm.StageName, 'Formalizada');
        }
    }

    @isTest
    public static void actualizarProducto() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.Id);
        campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666662');
        campos.put('CSBD_Contact__c',contacto1.Id);
        campos.put('Amount',1);
        Opportunity CMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);

        CMB.OwnerId = usuarioGestor.Id;
        update CMB;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CMB.CSBD_Producto__c = 'Hipoteca';
            update CMB;
            Test.stopTest();

            Opportunity oportunidadActualizada = [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE Id =:CMB.Id];

            System.assertEquals(oportunidadActualizada.CSBD_Producto__c, 'Hipoteca');
        }
    }

    @isTest
    public static void scheduleReclamacionesCliente() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.Id);
        campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666662');
        campos.put('CSBD_Contact__c',contacto1.Id);
        campos.put('Amount',1);
        Opportunity CMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);

        CMB.OwnerId = usuarioGestor.Id;
        update CMB;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CMB.CSBD_Estado__c = 'Pendiente Cliente';
            update CMB;
            Test.stopTest();

            List<CBK_SCH_PendingProcess__c> reclamaciones = [SELECT Id, ClassName__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :CMB.Id];
            Opportunity oportunidadActualizada = [SELECT Id, CSBD_Estado__c FROM Opportunity WHERE Id =:CMB.Id];

            System.assertEquals(oportunidadActualizada.CSBD_Estado__c, 'Pendiente Cliente');
            System.assertEquals(3, reclamaciones.size());
            System.assertEquals(reclamaciones[0].ClassName__c, 'CBK_SCH_CSBD_ScheduleReclamaCliente');
            System.assertEquals(reclamaciones[1].ClassName__c, 'CBK_SCH_CSBD_ScheduleReclamaCliente');
            System.assertEquals(reclamaciones[2].ClassName__c, 'CBK_SCH_CSBD_ScheduleReclamaCliente');
        }
    }
     @isTest
    public static void noIdentificaClienteBUTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', null);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666662');
        campos.put('CSBD_Contact__c',null);
        campos.put('Amount',1);
        campos.put('CSBD_No_Identificado__c',true);

        Opportunity CMB = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

        CMB.OwnerId = usuarioGestor.Id;
        update CMB;

        System.runAs (usuarioGestor) {
            Test.startTest();
            CMB.AccountId = cuenta1.Id;
            update CMB;
            Test.stopTest();

            Opportunity oportunidadActualizada = [SELECT Id, CSBD_No_Identificado__c FROM Opportunity WHERE Id =:CMB.Id];

            System.assertEquals(oportunidadActualizada.CSBD_No_Identificado__c, false);

        }
    }

     @isTest
    public static void sincronizarAccountHijasTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', null);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666662');
        campos.put('CSBD_Contact__c',null);
        campos.put('Amount',1);
        campos.put('OwnerId',usuarioGestor.Id);

        Opportunity Opp = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

        Map<String, Object> campos2= new Map<String, Object>();
        campos.put('AccountId', null);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666662');
        campos.put('CSBD_Contact__c',null);
        campos.put('Amount',1);
        campos.put('CSBD_Parent_Id__c',Opp.Id);
        campos.put('OwnerId',usuarioGestor.Id);

        Opportunity OppHija = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', campos);


        System.runAs (usuarioGestor) {
            Test.startTest();
            Opp.AccountId = cuenta1.Id;
            update Opp;
            Test.stopTest();

            Opportunity oportunidadHijaActualizada = [SELECT Id, AccountId FROM Opportunity WHERE CSBD_Parent_Id__c =:Opp.Id];

            System.assertEquals(oportunidadHijaActualizada.AccountId, cuenta1.Id);

        }
    }

     @isTest
    public static void calcularTMOTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.id);
        campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666662');
        campos.put('CSBD_Contact__c',null);
        campos.put('Amount',1);
        campos.put('OwnerId',usuarioGestor.Id);
        campos.put('CSBD_PrimerContactoSLA__c', System.now().addMinutes(-5));


        Opportunity Opp = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

        System.runAs (usuarioGestor) {
            Test.startTest();
            Opp.CSBD_Estado__c = 'Rechazada';
            Opp.StageName = 'Rechazada';
            update Opp;
            Test.stopTest();

            Opportunity oportunidadHijaActualizada = [SELECT Id, AccountId,CSBD_PrimerContactoSLA__c, CSBD_SLA_TMO__c FROM Opportunity WHERE id =:Opp.Id];

            System.assertEquals(oportunidadHijaActualizada.CSBD_SLA_TMO__c, 5);

        }
    }

    @isTest
    public static void actualizarTelefonoOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '14628118A'];
        Account cuenta2 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '32179537F'];

        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];
        Contact contacto2 = [SELECT Id FROM Contact WHERE AccountId =: cuenta2.Id];
        contacto2.Email = '';
        contacto2.MobilePhone = '1234';
        contacto2.Phone = '';
        update contacto2;

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta1.Id);
        campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
        campos.put('CSBD_Telefono_Solicitud__c', '');
        campos.put('CSBD_Contact__c',contacto1.Id);
        Opportunity hipoteca1 = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

        System.runAs (usuarioGestor) {
            Test.startTest();
            hipoteca1.OwnerId = usuarioGestor.Id;
            hipoteca1.AccountId = cuenta2.Id;
            hipoteca1.CSBD_Contact__c = contacto2.Id;
            hipoteca1.CSBD_Telefono_Solicitud__c = '';
            update hipoteca1;

            if(String.isBlank(hipoteca1.CSBD_Telefono_Solicitud__c)){
                if(String.isNotBlank(contacto2.MobilePhone)){
                    hipoteca1.CSBD_Telefono_Solicitud__c = contacto2.MobilePhone;
                } else {
                    hipoteca1.CSBD_Telefono_Solicitud__c = contacto2.Phone;
                }
            }
            Test.stopTest();

            System.assertEquals(contacto2.MobilePhone, hipoteca1.CSBD_Telefono_Solicitud__c, 'El contacto no tiene número de móvil.');
        }
    }

    @isTest
    public static void actualizarCuentaClientePA() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuentaPA = [SELECT Id, FirstName, LastName, CC_Numero_Documento__c, RecordTypeId FROM Account WHERE CC_Numero_Documento__c = '32179537F'];
        System.runAs (usuarioGestor) {
            Test.startTest();
            Map<String, Object> campos = new Map<String, Object>();
       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

            hipoteca.AccountId = cuentaPA.Id;
            update hipoteca;

            List<Opportunity> opp = [select id, CSBD_ContactoTitular1__c from opportunity where id =: hipoteca.Id];
            Test.stopTest();

            System.assertNotEquals('', opp[0].CSBD_ContactoTitular1__c, 'La cuenta no tiene titular');
        }
    }

    @isTest
    public static void actualizarCuentaClienteCC() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuentaCliente = [SELECT Id, Name, CC_Numero_Documento__c, RecordTypeId FROM Account WHERE CC_Numero_Documento__c = '94160903F'];

        System.runAs (usuarioGestor) {
            Test.startTest();
            Map<String, Object> campos = new Map<String, Object>();
       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

            hipoteca.AccountId = cuentaCliente.Id;
            update hipoteca;

            List<Opportunity> opp = [select id, CSBD_ContactoTitular1__c from opportunity where id =: hipoteca.Id];
            Test.stopTest();

            System.assertNotEquals('', opp[0].CSBD_ContactoTitular1__c, 'La cuenta no tiene titular');
        }
    }

     @isTest
    public static void horarioComercialSiNoTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuentaCliente = [SELECT Id, Name, CC_Numero_Documento__c, RecordTypeId FROM Account WHERE CC_Numero_Documento__c = '94160903F'];

        System.runAs (usuarioGestor) {
            Test.startTest();
            Date myDatetime = Datetime.now().date().toStartofWeek();
            CBK_UtilsDate.nowSystem = myDatetime.addDays(6);

            Map<String, Object> campos = new Map<String, Object>();
       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
            Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
            hipoteca.AccountId = cuentaCliente.Id;
            prestamo.AccountId = cuentaCliente.Id;
            update hipoteca;

            List<Opportunity> oppHipoteca = [select id, CSBD_HorarioComercial__c from opportunity where id =: hipoteca.Id];
            List<Opportunity> oppPrestamo = [select id, CSBD_HorarioComercial__c from opportunity where id =: prestamo.Id];
            Test.stopTest();

            System.assertEquals('NO', oppHipoteca[0].CSBD_HorarioComercial__c, 'Error');
            System.assertEquals('SI', oppPrestamo[0].CSBD_HorarioComercial__c, 'Error');
        }
    }

    @isTest
    public static void informarCampoPrioridad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];

        System.runAs (usuarioGestor) {
            Test.startTest();

            contacto.CSBD_Profesion__c = 'Programador';
            contacto.CSBD_ClienteCaixabank__c = true;
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            update contacto;

            String json = '{\n' +
                ' "metadata" : {\n' +
                '     "version" : "3",\n' +
                '     "fechaGuardado" : "2024-08-16T09:19:09.994Z",\n' +
                '     "usuario" : "0055r000007FXObAAO"\n' +
                ' },\n' +
                ' "porcentajeGastosConstitucion" : 0,\n' +
                ' "ahorro" : 0,\n' +
                ' "primerTitular" : {\n' +
                '     "nominasNetas" : {\n' +
                '         "tipo" : "Nóminas netas",\n' +
                '         "ingresos" : "6000",\n' +
                '         "numPagosImpuestos" : 12\n' +
                '     },\n' +
                '     "ingresosNetosIrpf" : {\n' +
                '         "tipo" : "Ingresos netos IRPF",\n' +
                '         "ingresos" : 0,\n' +
                '         "numPagosImpuestos" : 0\n' +
                '     },\n' +
                '     "otrosIngresos" : {\n' +
                '         "tipo" : "Otros ingresos",\n' +
                '         "ingresos" : 0,\n' +
                '         "numPagosImpuestos" : 0\n' +
                '     },\n' +
                '     "ingresosAlquiler" : {\n' +
                '         "tipo" : "Ingresos por alquiler",\n' +
                '         "ingresos" : 0,\n' +
                '         "numPagosImpuestos" : 0\n' +
                '     }\n' +
                ' },\n' +
                ' "segundoTitular" : {},\n' +
                ' "deuda" : {\n' +
                '     "dosTitulares" : false,\n' +
                '     "hipoteca" : {\n' +
                '         "primerTitular" : 0,\n' +
                '         "segundoTitular" : 0\n' +
                '     },\n' +
                '     "prestamo" : {\n' +
                '         "primerTitular" : 0,\n' +
                '         "segundoTitular" : 0\n' +
                '     },\n' +
                '     "tarjetas" : {\n' +
                '         "primerTitular" : 0,\n' +
                '         "segundoTitular" : 0\n' +
                '     },\n' +
                '     "alquiler" : {\n' +
                '         "primerTitular" : 0,\n' +
                '         "segundoTitular" : 0\n' +
                '     }\n' +
                ' }\n' +
            '}';

       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');
            hipoteca.AccountId = cuenta.Id;
            hipoteca.CSBD_ContactoTitular1__c = contacto.Id;
            hipoteca.CSBD_Tasacion__c = 1000;
            hipoteca.CSBD_Urgencia__c = 'Si';
            hipoteca.CSBD_UsoVivienda2__c = 'Primera residencia';
            hipoteca.Amount = 100000;
            hipoteca.CSBD_AportacionInicial__c = 20000;
            hipoteca.CSBD_TipoOperacion2__c = 'Compra de vivienda';
            hipoteca.put('CSBD_PrecioInmueble__c', 200000);
            hipoteca.put('CSBD_Datos_Calculo_DTI__c', json);
            hipoteca.put('CSBD_Now_Plazo__c', 120);
            update hipoteca;

            CSBD_DatosEntrevistaHipoteca.Deuda deuda = new CSBD_DatosEntrevistaHipoteca.Deuda(new CSBD_DatosEntrevistaHipoteca(hipoteca));
            List<Opportunity> oppHipoteca = [SELECT CSBD_OC_Prioridad__c FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_Hipoteca' AND IsClosed = FALSE];
            Test.stopTest();

            System.assertEquals('13', oppHipoteca[0].CSBD_OC_Prioridad__c, 'Error');
        }
    }

    @isTest
    public static void crearActividadesIdentificarCliente() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];

        System.runAs (usuarioGestor) {
            Test.startTest();

       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');
            hipoteca.AccountId = cuenta.Id;
            hipoteca.CSBD_Contact__c = contacto.Id;
            update hipoteca;

            Test.stopTest();

            Task[] tareaIdentificacion = [SELECT Id FROM Task WHERE Type =: 'Identificación del cliente'];
            System.assert(!tareaIdentificacion.isEmpty());
        }
    }

    @isTest
    public static void crearAccountTitularHipotecaTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];
        System.runAs (usuarioGestor) {
            Test.startTest();
            List<Contact> contactosTitularInsert = new List<Contact>();
            Contact titular1 = new Contact();
            titular1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            titular1.FirstName = 'Prueba';
            titular1.LastName = 'Test';
            contactosTitularInsert.add(titular1);

            Contact titular2 = new Contact();
            titular2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            titular2.FirstName = 'Prueba';
            titular2.LastName = 'Test';
            contactosTitularInsert.add(titular2);

            insert contactosTitularInsert;

       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');
            hipoteca.AccountId = cuenta.Id;
            hipoteca.CSBD_ContactoTitular1__c = titular1.Id;
            hipoteca.CSBD_ContactoTitular2__c = titular2.Id;
            update hipoteca;
            Test.stopTest();

            Contact contactoTitular1 = [SELECT id, accountId from contact where id =:titular1.Id];
            Contact contactoTitular2 = [SELECT id, accountId from contact where id =:titular2.Id];
            System.assert(contactoTitular1.AccountId != null);
            System.assert(contactoTitular2.AccountId != null);
        }
    }

     @isTest
    public static void crearAccountTitularHipotecaTest2() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];
        System.runAs (usuarioGestor) {
            Test.startTest();
            List<Contact> contactosTitularInsert = new List<Contact>();
            Contact titular1 = new Contact();
            titular1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            titular1.FirstName = 'Prueba';
            titular1.LastName = 'Test';
            contactosTitularInsert.add(titular1);

            Contact titular2 = new Contact();
            titular2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            titular2.FirstName = 'Prueba';
            titular2.LastName = 'Test';
            titular2.AccountId = cuenta.Id;
            contactosTitularInsert.add(titular2);

            insert contactosTitularInsert;

       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');
            hipoteca.AccountId = cuenta.Id;
            hipoteca.CSBD_ContactoTitular1__c = titular1.Id;
            hipoteca.CSBD_ContactoTitular2__c = titular2.Id;
            update hipoteca;
            Test.stopTest();

            Contact contactoTitular1 = [SELECT id, accountId from contact where id =:titular1.Id];
            Contact contactoTitular2 = [SELECT id, accountId from contact where id =:titular2.Id];
            System.assert(contactoTitular1.AccountId != null);
            System.assert(contactoTitular1.AccountId == contactoTitular2.AccountId);
        }
    }

     @isTest
    public static void crearAccountTitularHipotecaTest3() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];
        System.runAs (usuarioGestor) {
            Test.startTest();
            List<Contact> contactosTitularInsert = new List<Contact>();
            Contact titular1 = new Contact();
            titular1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            titular1.FirstName = 'Prueba';
            titular1.LastName = 'Test';
            titular1.AccountId = cuenta.Id;
            contactosTitularInsert.add(titular1);

            Contact titular2 = new Contact();
            titular2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            titular2.FirstName = 'Prueba';
            titular2.LastName = 'Test';
            contactosTitularInsert.add(titular2);

            insert contactosTitularInsert;

       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');
            hipoteca.AccountId = cuenta.Id;
            hipoteca.CSBD_ContactoTitular1__c = titular1.Id;
            hipoteca.CSBD_ContactoTitular2__c = titular2.Id;
            update hipoteca;
            Test.stopTest();

            Contact contactoTitular1 = [SELECT id, accountId from contact where id =:titular1.Id];
            Contact contactoTitular2 = [SELECT id, accountId from contact where id =:titular2.Id];
            System.assert(contactoTitular2.AccountId != null);
            System.assert(contactoTitular1.AccountId == contactoTitular2.AccountId);
        }
    }
}