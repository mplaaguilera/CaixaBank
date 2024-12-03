@isTest
public class OS_Informar_DAN_DG_DT_Caso_Test {
    
    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }

    @isTest
    public static void informarCampos(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDelegacionGeneral.Id;
        insert cuentaTipoDAN;

        Account cuentaTipoOficina = new Account();
        cuentaTipoOficina.Name = 'Store Pruebas';
        cuentaTipoOficina.recordtypeId = cuentaRecordType;
        cuentaTipoOficina.CC_Email__c = 'oficina@test.com';
        cuentaTipoOficina.CC_Tipo_Centro__c = 'OF';
        cuentaTipoOficina.ParentId = cuentaTipoDAN.Id;
        insert cuentaTipoOficina;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuentaTipoOficina.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaTipoOficina.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertNotEquals(null,caso.CC_DG__c);
            System.assertNotEquals(null,caso.CC_DAN__c);
            System.assertNotEquals(null,caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCampos2(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDelegacionGeneral.Id;
        insert cuentaTipoDAN;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaTipoDAN.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertNotEquals(null,caso.CC_DG__c);
            System.assertNotEquals(null,caso.CC_DAN__c);
            System.assertNotEquals(null,caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCampos3(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaTipoDelegacionGeneral.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertEquals(null,caso.CC_DAN__c);
            System.assertNotEquals(null,caso.CC_DG__c);
            System.assertNotEquals(null,caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCampos4() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaTipoDireccionTerritorial.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
        
        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertEquals(null, caso.CC_DAN__c);
            System.assertEquals(null, caso.CC_DG__c);
            System.assertNotEquals(null, caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCampos5() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDelegacionGeneral.Id;
        insert cuentaTipoDAN;

        Account cuentaTipoOficina = new Account();
        cuentaTipoOficina.Name = 'Store Pruebas';
        cuentaTipoOficina.recordtypeId = cuentaRecordType;
        cuentaTipoOficina.CC_Email__c = 'oficina@test.com';
        cuentaTipoOficina.CC_Tipo_Centro__c = 'OF';
        cuentaTipoOficina.ParentId = cuentaTipoDAN.Id;
        insert cuentaTipoOficina;

        Account cuentaconOficinaAsociada = new Account();
        cuentaconOficinaAsociada.Name = 'Cuenta';
        cuentaconOficinaAsociada.recordtypeId = cuentaRecordType;
        cuentaconOficinaAsociada.CC_Email__c = 'oficinaasociada@test.com';
        cuentaconOficinaAsociada.ParentId = cuentaTipoOficina.Id;
        insert cuentaconOficinaAsociada;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuentaTipoOficina.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);

        AccountShare acshare5 = new AccountShare();
        acshare5.AccountId = cuentaconOficinaAsociada.Id;
        acshare5.UserOrGroupId = usuarioOperador.Id;
        acshare5.AccountAccessLevel = 'Edit';
        acshare5.OpportunityAccessLevel = 'Edit';
        acshare5.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare5);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaconOficinaAsociada.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertNotEquals(null,caso.CC_DAN__c);
            System.assertNotEquals(null,caso.CC_DG__c);
            System.assertNotEquals(null,caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCampos6() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDelegacionGeneral.Id;
        insert cuentaTipoDAN;

        Account cuentaTipoOficina = new Account();
        cuentaTipoOficina.Name = 'Store Pruebas';
        cuentaTipoOficina.recordtypeId = cuentaRecordType;
        cuentaTipoOficina.CC_Email__c = 'oficina@test.com';
        cuentaTipoOficina.CC_Tipo_Centro__c = 'OF';
        cuentaTipoOficina.ParentId = cuentaTipoDAN.Id;
        insert cuentaTipoOficina;

        Account cuentaconOficinaAsociada = new Account();
        cuentaconOficinaAsociada.Name = 'Cuenta';
        cuentaconOficinaAsociada.recordtypeId = cuentaRecordType;
        cuentaconOficinaAsociada.CC_Email__c = 'oficinaasociada@test.com';
        cuentaconOficinaAsociada.ParentId = cuentaTipoOficina.Id;
        insert cuentaconOficinaAsociada;

        Account cuentaconOficinaAsociada2N = new Account();
        cuentaconOficinaAsociada2N.Name = 'Cuenta';
        cuentaconOficinaAsociada2N.recordtypeId = cuentaRecordType;
        cuentaconOficinaAsociada2N.CC_Email__c = 'oficinaasociada2N@test.com';
        cuentaconOficinaAsociada2N.ParentId = cuentaconOficinaAsociada.Id;
        insert cuentaconOficinaAsociada2N;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuentaTipoOficina.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);

        AccountShare acshare5 = new AccountShare();
        acshare5.AccountId = cuentaconOficinaAsociada.Id;
        acshare5.UserOrGroupId = usuarioOperador.Id;
        acshare5.AccountAccessLevel = 'Edit';
        acshare5.OpportunityAccessLevel = 'Edit';
        acshare5.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare5);

        AccountShare acshare6 = new AccountShare();
        acshare6.AccountId = cuentaconOficinaAsociada2N.Id;
        acshare6.UserOrGroupId = usuarioOperador.Id;
        acshare6.AccountAccessLevel = 'Edit';
        acshare6.OpportunityAccessLevel = 'Edit';
        acshare6.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare6);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaconOficinaAsociada2N.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertNotEquals(null, caso.CC_DAN__c);
            System.assertNotEquals(null, caso.CC_DG__c);
            System.assertNotEquals(null, caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCamposCliente() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id cuentaClienteRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDelegacionGeneral.Id;
        insert cuentaTipoDAN;

        Account cuentaTipoOficina = new Account();
        cuentaTipoOficina.Name = 'Store Pruebas';
        cuentaTipoOficina.recordtypeId = cuentaRecordType;
        cuentaTipoOficina.CC_Email__c = 'oficina@test.com';
        cuentaTipoOficina.CC_Tipo_Centro__c = 'OF';
        cuentaTipoOficina.ParentId = cuentaTipoDAN.Id;
        insert cuentaTipoOficina;

        Account cuentaCliente = new Account();
        cuentaCliente.Name = 'Cuenta Cliente';
        cuentaCliente.RecordTypeId = cuentaClienteRecordType;
        cuentaCliente.CC_OficinaGestoraId__c = cuentaTipoDAN.Id;
        insert cuentaCliente;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuentaTipoOficina.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);

        AccountShare acshare5 = new AccountShare();
        acshare5.AccountId = cuentaCliente.Id;
        acshare5.UserOrGroupId = usuarioOperador.Id;
        acshare5.AccountAccessLevel = 'Edit';
        acshare5.OpportunityAccessLevel = 'Edit';
        acshare5.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare5);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaCliente.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertNotEquals(null,caso.CC_DG__c);
            System.assertNotEquals(null,caso.CC_DAN__c);
            System.assertNotEquals(null,caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCamposClienteDos() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id cuentaClienteRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDelegacionGeneral.Id;
        insert cuentaTipoDAN;

        Account cuentaTipoOficina = new Account();
        cuentaTipoOficina.Name = 'Store Pruebas';
        cuentaTipoOficina.recordtypeId = cuentaRecordType;
        cuentaTipoOficina.CC_Email__c = 'oficina@test.com';
        cuentaTipoOficina.CC_Tipo_Centro__c = 'OF';
        cuentaTipoOficina.ParentId = cuentaTipoDAN.Id;
        insert cuentaTipoOficina;

        Account cuentaCliente = new Account();
        cuentaCliente.Name = 'Cuenta Cliente';
        cuentaCliente.RecordTypeId = cuentaClienteRecordType;
        cuentaCliente.CC_OficinaGestoraId__c = cuentaTipoDelegacionGeneral.Id;
        insert cuentaCliente;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuentaTipoOficina.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);

        AccountShare acshare5 = new AccountShare();
        acshare5.AccountId = cuentaCliente.Id;
        acshare5.UserOrGroupId = usuarioOperador.Id;
        acshare5.AccountAccessLevel = 'Edit';
        acshare5.OpportunityAccessLevel = 'Edit';
        acshare5.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare5);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaCliente.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertNotEquals(null,caso.CC_DG__c);
            System.assertEquals(null,caso.CC_DAN__c);
            System.assertNotEquals(null,caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void informarCamposClienteTres() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id cuentaClienteRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDAN;

        Account cuentaTipoOficina = new Account();
        cuentaTipoOficina.Name = 'Store Pruebas';
        cuentaTipoOficina.recordtypeId = cuentaRecordType;
        cuentaTipoOficina.CC_Email__c = 'oficina@test.com';
        cuentaTipoOficina.CC_Tipo_Centro__c = 'OF';
        cuentaTipoOficina.ParentId = cuentaTipoDAN.Id;
        insert cuentaTipoOficina;

        Account cuentaCliente = new Account();
        cuentaCliente.Name = 'Cuenta Cliente';
        cuentaCliente.RecordTypeId = cuentaClienteRecordType;
        cuentaCliente.CC_OficinaGestoraId__c = cuentaTipoDireccionTerritorial.Id;
        insert cuentaCliente;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuentaTipoOficina.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);

        AccountShare acshare5 = new AccountShare();
        acshare5.AccountId = cuentaCliente.Id;
        acshare5.UserOrGroupId = usuarioOperador.Id;
        acshare5.AccountAccessLevel = 'Edit';
        acshare5.OpportunityAccessLevel = 'Edit';
        acshare5.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare5);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaCliente.Id;
        insert casoConOficina;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = casoConOficina.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            casoConOficina.OwnerId = usuarioOperador.Id;
            update casoConOficina;

            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            Test.stopTest();
            
            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertEquals(null,caso.CC_DG__c);
            System.assertEquals(null,caso.CC_DAN__c);
            System.assertNotEquals(null,caso.CC_Direccion_Territorial__c);
        }
    }

    @isTest
    public static void desinformarCampos() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id cuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id cuentaClienteRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Account cuentaTipoDireccionTerritorial = new Account();
        cuentaTipoDireccionTerritorial.Name = 'TERRITORIAL Pruebas';
        cuentaTipoDireccionTerritorial.recordtypeId = cuentaRecordType;
        cuentaTipoDireccionTerritorial.CC_Email__c = 'territorial@test.com';
        cuentaTipoDireccionTerritorial.CC_Tipo_Centro__c = 'DT';
        insert cuentaTipoDireccionTerritorial;

        Account cuentaTipoDelegacionGeneral = new Account();
        cuentaTipoDelegacionGeneral.Name = 'DC RED Pruebas';
        cuentaTipoDelegacionGeneral.recordtypeId = cuentaRecordType;
        cuentaTipoDelegacionGeneral.CC_Email__c = 'dg@test.com';
        cuentaTipoDelegacionGeneral.CC_Tipo_Centro__c = 'DG';
        cuentaTipoDelegacionGeneral.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDelegacionGeneral;

        Account cuentaTipoDAN = new Account();
        cuentaTipoDAN.Name = 'D.A.N. Pruebas';
        cuentaTipoDAN.recordtypeId = cuentaRecordType;
        cuentaTipoDAN.CC_Email__c = 'dan@test.com';
        cuentaTipoDAN.CC_Tipo_Centro__c = 'GC';
        cuentaTipoDAN.ParentId = cuentaTipoDireccionTerritorial.Id;
        insert cuentaTipoDAN;

        Account cuentaTipoOficina = new Account();
        cuentaTipoOficina.Name = 'Store Pruebas';
        cuentaTipoOficina.recordtypeId = cuentaRecordType;
        cuentaTipoOficina.CC_Email__c = 'oficina@test.com';
        cuentaTipoOficina.CC_Tipo_Centro__c = 'OF';
        cuentaTipoOficina.ParentId = cuentaTipoDAN.Id;
        insert cuentaTipoOficina;

        Account cuentaCliente = new Account();
        cuentaCliente.Name = 'Cuenta Cliente';
        cuentaCliente.RecordTypeId = cuentaClienteRecordType;
        cuentaCliente.CC_OficinaGestoraId__c = cuentaTipoOficina.Id;
        insert cuentaCliente;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuentaTipoDireccionTerritorial.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuentaTipoDelegacionGeneral.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);

        AccountShare acshare3 = new AccountShare();
        acshare3.AccountId = cuentaTipoDAN.Id;
        acshare3.UserOrGroupId = usuarioOperador.Id;
        acshare3.AccountAccessLevel = 'Edit';
        acshare3.OpportunityAccessLevel = 'Edit';
        acshare3.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare3);

        AccountShare acshare4 = new AccountShare();
        acshare4.AccountId = cuentaTipoOficina.Id;
        acshare4.UserOrGroupId = usuarioOperador.Id;
        acshare4.AccountAccessLevel = 'Edit';
        acshare4.OpportunityAccessLevel = 'Edit';
        acshare4.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare4);

        AccountShare acshare5 = new AccountShare();
        acshare5.AccountId = cuentaCliente.Id;
        acshare5.UserOrGroupId = usuarioOperador.Id;
        acshare5.AccountAccessLevel = 'Edit';
        acshare5.OpportunityAccessLevel = 'Edit';
        acshare5.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare5);
        insert totalPermisos;

        Case casoConOficina = new Case();
        casoConOficina.recordtypeId = recordTypeCaso;
        casoConOficina.Origin = 'Email';
        casoConOficina.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        casoConOficina.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        casoConOficina.Subject = 'Caso1';
        casoConOficina.Status = 'Activo';
        casoConOficina.AccountId = cuentaCliente.Id;
        casoConOficina.OwnerId = usuarioOperador.Id;
        insert casoConOficina;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            Set<Id> idsCasos = new Set<Id>();
            idsCasos.add(casoConOficina.Id);
            OS_Informar_DAN_DG_DT_Caso.informarCampos(idsCasos);
            casoConOficina.AccountId = null;
            update casoConOficina;
            Test.stopTest();

            Case caso = [SELECT Id, CC_DG__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case WHERE Id IN :idsCasos LIMIT 1];
            System.assertEquals(null, caso.CC_DG__c);
            System.assertEquals(null, caso.CC_DAN__c);
            System.assertEquals(null, caso.CC_Direccion_Territorial__c);
        }
    }
}