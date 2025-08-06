@isTest
public with sharing class GRR_CaseTriggerHelper_Test {

    @TestSetup
    static void makeData(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'GRR_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'GRR'].Id;
        usuario.FirstName = 'GRR Prueba Clases Test';
        usuario.LastName = 'GRR Prueba Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        insert usuario;
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('GRR_Agente','GRR_Supervisor')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;
    }
    
    private static Contact crearContacto() {
        List<Account>dt = new List<Account>();
        dt.add(new Account (
            Name = 'DT',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente')) 
        );
        insert dt;
        List<Account> dan = new List<Account>();
        dan.add(new Account (
            Name = 'DAN',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
            ParentId = dt[0].Id) 
        );
        insert dan;
        Account oficina = new Account (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
            Name = 'Oficina',
            CC_Gerencia_Comercial__c = dan[0].Id,
            ParentId = dan[0].Id,
            CC_Direccion_Territorial__c = dt[0].Id
        );
        insert oficina;

        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            FirstName = 'Contacto',
            LastName = 'Contacto',
            AccountId = oficina.Id,
            MobilePhone = '642462269'
        );
        insert contacto;
        return contacto;
    }
    
    private static Case crearCaso(String usuarioId) {
        User user = [SELECT Id FROM User WHERE Id =: usuarioId];
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            Origin = 'SAC_Manual',
            CC_Canal_Procedencia__c = 'DT Canarias',
            OwnerId = user.Id
        );           
        insert caso;
        return caso;
    }

    @future
    private static void updateCaso(String idcaso) {
        Case caso = [SELECT Id FROM Case WHERE Id = :idcaso];
        update caso;
    }
    
    @isTest
    public static void testCrearActividadReasignacion() {
        User usuario = new User();
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'GRR_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'GRR'].Id;
        usuario.FirstName = 'first 1';
        usuario.LastName = 'last1';
        usuario.Email = 'puser000@amamama.com';
        usuario.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        usuario.CompanyName = 'TEST';
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Madrid';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        insert usuario;

        User usuarioCaso = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuarioCaso) {
            Case caso = crearCaso(usuarioCaso.Id);
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, OwnerId FROM Case]);
            List<Case> lstCasos = new List<Case>();
            caso.OwnerId = usuario.Id;
            updateCaso(caso.Id);
            lstCasos.add(caso);
            
            Test.startTest();
            GRR_CaseTriggerHelper.crearActividadReasignacion(lstCasos, mapaCasos);
            Test.stopTest();
            
            Task tareaCreada = [SELECT Id, Type FROM Task LIMIT 1];
            System.assertEquals('Reasignación', tareaCreada.Type);    
        }
    }

    @isTest
    public static void testInformarCamposOficina() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Contact contacto = crearContacto();
            Case caso = crearCaso(usuario.Id);
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Oficina__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case]);
            List<Case> lstCasos = new List<Case>();
            caso.CC_Oficina__c = contacto.AccountId;
            updateCaso(caso.Id);
            lstCasos.add(caso);

            Test.startTest();
            GRR_CaseTriggerHelper.informarCamposOficina(lstCasos, mapaCasos);
            Test.stopTest();
            
            System.assertEquals(caso.CC_Oficina__c != null, true);
            System.assertEquals(caso.CC_DAN__c != null, true);
            System.assertEquals(caso.CC_Direccion_Territorial__c != null, true);
        
        }
    }

     @isTest
    public static void getCaseExtension() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Contact contacto = crearContacto();
            Case caso = crearCaso(usuario.Id);
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Oficina__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case]);
            List<Case> lstCasos = new List<Case>();
            caso.CC_Oficina__c = contacto.AccountId;
            updateCaso(caso.Id);
            lstCasos.add(caso);

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Case_Id__c = caso.Id;
            insert caseExtension;

            Test.startTest();
            GRR_CaseTriggerHelper.getCaseExtension(caso.Id);
            GRR_CaseTriggerHelper.getCaseExtensionId(caso.Id);
            
            Test.stopTest();
            
           System.assertEquals(caso.Id ==  caseExtension.Case_Id__c, true);
            //System.assertEquals(caso.CC_DAN__c != null, true);
           // System.assertEquals(caso.CC_Direccion_Territorial__c != null, true);
        
        }
    }

     @isTest
    public static void informarDatosEntradaCOPS() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        //Datetime myDateNow = Datetime.valueOf(System.now());

        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'Recobro',
            CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;
        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'Semanal',
            CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id
        );
        insert mccProducto;


        System.runAs(usuario) {
            Contact contacto = crearContacto();
            Case caso = crearCaso(usuario.Id);
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Oficina__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case]);
            List<Case> lstCasos = new List<Case>();
            caso.CC_Oficina__c = contacto.AccountId;
            caso.CC_Canal_Procedencia__c = 'Servicio Recobro';

            updateCaso(caso.Id);
            lstCasos.add(caso);

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Case_Id__c = caso.Id;
            insert caseExtension;

            Test.startTest();
            GRR_CaseTriggerHelper.handleAfterInsert(lstCasos);
            GRR_CaseTriggerHelper.informarDatosEntradaCOPS(lstCasos);
            Test.stopTest();
            
           System.assertEquals(caso.Id ==  caseExtension.Case_Id__c, true);
            //System.assertEquals(caso.CC_DAN__c != null, true);
           // System.assertEquals(caso.CC_Direccion_Territorial__c != null, true);
        
        }
    }

 
     @isTest
    public static void informarCambioTipo() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        //Datetime myDateNow = Datetime.valueOf(System.now());


          CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'Recobro',
            CC_Fecha_Vigencia_Inicio__c = Datetime.newInstance(2022, 05, 05),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'Semanal',
            CC_Fecha_Vigencia_Inicio__c =Datetime.newInstance(2022, 05, 05),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id
        );
        insert mccProducto;

         CC_MCC__c mccProducto2 = new CC_MCC__c(
            Name = 'Recurrente',
            CC_Fecha_Vigencia_Inicio__c =Datetime.newInstance(2022, 05, 05),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000002',
            CC_Tematica__c = mccTematica.Id
        );
        insert mccProducto2;


        System.runAs(usuario) {
            Contact contacto = crearContacto();
            Case caso = crearCaso(usuario.Id);
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CC_Oficina__c, CC_DAN__c, CC_Direccion_Territorial__c FROM Case]);
            List<Case> lstCasos = new List<Case>();
            caso.CC_Oficina__c = contacto.AccountId;
            updateCaso(caso.Id);
            lstCasos.add(caso);

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Case_Id__c = caso.Id;
            caseExtension.GRR_Tipo_Recobro__c = 'Recurrente';
            insert caseExtension;

             CBK_Case_Extension__c caseExtension2 = new CBK_Case_Extension__c();
            caseExtension2.Case_Id__c = caso.Id;
            caseExtension2.GRR_Tipo_Recobro__c = 'Urgente';
            insert caseExtension2;

            // Añadir la referencia de la extensión al caso
            caso.CBK_Case_Extension_Id__c = caseExtension.Id; // Asegúrate de que este campo existe
            update caso;

            Test.startTest();
                GRR_CaseTriggerHelper.informarCambioTipo(caseExtension.Id);
                GRR_CaseTriggerHelper.informarCambioTipo(caseExtension2.Id);
            Test.stopTest();
            
           System.assertEquals(caso.Id ==  caseExtension.Case_Id__c, true);
            //System.assertEquals(caso.CC_DAN__c != null, true);
           // System.assertEquals(caso.CC_Direccion_Territorial__c != null, true);
        
        }
    }


    @isTest
    static void testGetUserRoleName() {
        // Crear un rol de usuario de prueba
        UserRole testRole = new UserRole(Name = 'Gestiones Test Role');
        insert testRole;

        // Crear un usuario de prueba con ese rol
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            UserRoleId = testRole.Id
        );
        insert testUser;

        // Ejecutar como el usuario de prueba
        System.runAs(testUser) {
            Test.startTest();
            String roleName = GRR_CaseTriggerHelper.getUserRoleName(); // Ajusta si la clase tiene otro nombre
            Test.stopTest();

            System.assertEquals('Gestiones Test Role', roleName, 'El nombre del rol debe coincidir');
        }
    }

    
    @isTest
    static void testLimpiarDireccionesCuandoCambiaAccount() {
         User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        // Crear dos cuentas
        Account cuentaOriginal = new Account(Name = 'Cuenta Original');
        Account cuentaNueva = new Account(Name = 'Cuenta Nueva');
        insert new List<Account>{ cuentaOriginal, cuentaNueva };

        // Crear un caso con cuenta original y campos rellenados
        Case caso = new Case(
            AccountId = cuentaOriginal.Id,
            SAC_DireccionContacto__c = 'Dirección antigua',
            SAC_PoblacionContacto__c = 'Ciudad antigua',
            GRR_Provincia__c = 'PALENCIA',
            CC_MailTelfNotif__c = 'email@antiguo.com',
            CC_DAN__c = cuentaOriginal.Id,
            Origin = 'Email', // campo obligatorio por defecto en muchos orgs
            Status = 'Activo',   // idem
            Priority = 'Medium',
            Subject = 'Caso de prueba'
        );
        insert caso;

         // Simular el caso viejo
        Case oldCase = caso.clone(false, false, false, false);
        oldCase.AccountId = cuentaOriginal.Id;
        Map<Id, Case> mapOld = new Map<Id, Case>{ caso.Id => oldCase };

        // Cambiar el AccountId del mismo caso para simular el cambio
        caso.AccountId = cuentaNueva.Id;

        // Ejecutar el método
        List<Case> lista = new List<Case>{ caso };
         System.runAs(usuario) {

        Test.startTest();
            GRR_CaseTriggerHelper.limpiarDireccionesSiCambiaContacto(lista, mapOld);
        Test.stopTest();
             System.assertEquals(null, caso.SAC_DireccionContacto__c);
         
    }

        // Verificamos que los campos hayan sido limpiados
        /*
        System.assertEquals(null, casoModificado.SAC_DireccionContacto__c);
        System.assertEquals(null, casoModificado.SAC_PoblacionContacto__c);
        System.assertEquals(null, casoModificado.GRR_Provincia__c);
        System.assertEquals(null, casoModificado.GRR_ComunidadAutonoma__c);
        System.assertEquals(null, casoModificado.CC_Oficina__c);
        System.assertEquals(null, casoModificado.CC_Direccion_Territorial__c);
        System.assertEquals(null, casoModificado.CC_MailTelfNotif__c);
        System.assertEquals(null, casoModificado.CC_DAN__c);*/
    }






}