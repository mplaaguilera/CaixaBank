@isTest
public with sharing class CSBD_TestDataFactory {

    public static User usuarioGestor() {
        User gestor = new User();
        // System.runAs(new User(Id = UserInfo.getUserId())) {
            gestor.FirstName = 'GestorCSBD';
            gestor.LastName = '1';
            gestor.IsActive = true;
            gestor.Alias = 'Gestor';
            gestor.Email = 'usuario_test@test.com';
            gestor.EmailEncodingKey = 'ISO-8859-1';
            gestor.LanguageLocaleKey = 'es';
            gestor.LocaleSidKey = 'es_ES';
            gestor.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
            gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
            gestor.TimeZoneSidKey = 'Europe/Madrid';
            gestor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            insert gestor;

            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor' LIMIT 1];
            if (permissionSet != null) {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permissionSet.Id;
                nuevoPermiso.AssigneeId = gestor.Id;
                insert nuevoPermiso;
            }
        // }
        asignarPublicGroup('CSBD_Empleados', gestor.Id);
        permisosUsuarioGenerico();
        return gestor;
    }

    private static void asignarPublicGroup(String nombreGroup, Id idUsuario) {
        // System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember miembroGrupo = new GroupMember();
            miembroGrupo.GroupId = [SELECT Id FROM Group WHERE DeveloperName = :nombreGroup].Id;
            miembroGrupo.UserOrGroupId = idUsuario;
            insert miembroGrupo;
        // }
    }

    private static void permisosUsuarioGenerico() {
        Id idUsuarioGenerico = [SELECT Id FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%' AND IsActive = TRUE LIMIT 1]?.Id;
        if (idUsuarioGenerico != null) {
            asignarPublicGroup('CSBD_Empleados', idUsuarioGenerico);
        }
    }

    public static Account crearCuenta(Map<String, Object> campos) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta Test';
        cuenta.CC_Numero_Documento__c = '12345678Z';
        for (String nombreCampo : campos.keySet()) {
            cuenta.put(nombreCampo, campos.get(nombreCampo));
        }
        insert cuenta;

        AccountShare cuentaShare = new AccountShare();
        cuentaShare.AccountId = cuenta.Id;
        cuentaShare.UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        cuentaShare.AccountAccessLevel = 'Edit';
        cuentaShare.OpportunityAccessLevel = 'Edit';
        cuentaShare.CaseAccessLevel = 'Edit';
        insert cuentaShare;

        return cuenta;
    }

    public static List<Account> crearCuenta(List<Map<String, Object>> camposCuentas) {
        List<Account> cuentas = new List<Account>();
        for (Map<String, Object> camposCuenta : camposCuentas) {
            Account cuenta = new Account();
            cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuenta.Name = 'Cuenta Test';
            cuenta.CC_Numero_Documento__c = '12345678Z';
            for (String nombreCampo : camposCuenta.keySet()) {
                cuenta.put(nombreCampo, camposCuenta.get(nombreCampo));
            }
            cuentas.add(cuenta);
        }
        insert cuentas;

        Id idGroup = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        List<AccountShare> cuentaShares = new List<AccountShare>();
        for (Account cuenta : cuentas) {
            AccountShare cuentaShare = new AccountShare();
            cuentaShare.AccountId = cuenta.Id;
            cuentaShare.UserOrGroupId = idGroup;
            cuentaShare.AccountAccessLevel = 'Edit';
            cuentaShare.OpportunityAccessLevel = 'Edit';
            cuentaShare.CaseAccessLevel = 'Edit';
            cuentaShares.add(cuentaShare);
        }
        insert cuentaShares;

        return cuentas;
    }

    public static Account crearCuenta() {
        return crearCuenta(new Map<String, Object>());
    }

    public static Contact crearContacto(Map<String, Object> campos) {
        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.FirstName = 'Contacto Test';
        contacto.LastName = 'Contacto Test';
        contacto.CC_Numero_Documento__c = '12345678Z';
        for (String nombreCampo : campos.keySet()) {
            contacto.put(nombreCampo, campos.get(nombreCampo));
        }
        insert contacto;

        ContactShare contactoShare = new ContactShare();
        contactoShare.ContactId = contacto.Id;
        contactoShare.UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        contactoShare.ContactAccessLevel = 'Edit';
        insert contactoShare;

        return contacto;
    }

    public static List<Contact> crearContacto(List<Map<String, Object>> camposContactos) {
        List<Contact> contactos = new List<Contact>();
        for (Map<String, Object> camposContacto : camposContactos) {
            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.FirstName = 'Contacto Test';
            contacto.LastName = 'Contacto Test';
            contacto.CC_Numero_Documento__c = '12345678Z';
            for (String nombreCampo : camposContacto.keySet()) {
                contacto.put(nombreCampo, camposContacto.get(nombreCampo));
            }
            contactos.add(contacto);
        }
        insert contactos;

        Id idGroup = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        List<ContactShare> contactoShares = new List<ContactShare>();
        for (Contact contacto : contactos) {
            ContactShare contactoShare = new ContactShare();
            contactoShare.ContactId = contacto.Id;
            contactoShare.UserOrGroupId = idGroup;
            contactoShare.ContactAccessLevel = 'Edit';
            contactoShares.add(contactoShare);
        }
        insert contactoShares;

        return contactos;
    }

    public static Contact crearContacto(Id idCuenta) {
        return crearContacto(new Map<String, Object>{'AccountId' => idCuenta});
    }

    public static Contact crearContacto() {
        return crearContacto(new Map<String, Object>());
    }

    public static Map<String, SObject> crearCuentaContacto(String nif, Map<String, Object> campos) {
        //Cuenta
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;

        AccountShare cuentaShare = new AccountShare();
        cuentaShare.AccountId = cuenta.Id;
        cuentaShare.UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        cuentaShare.AccountAccessLevel = 'Edit';
        cuentaShare.OpportunityAccessLevel = 'Edit';
        cuentaShare.CaseAccessLevel = 'Edit';
        insert cuentaShare;

        //Contacto
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        for (String nombreCampo : campos.keySet()) {
            contacto.put(nombreCampo, campos.get(nombreCampo));
        }
        insert contacto;

        ContactShare contactoShare = new ContactShare();
        contactoShare.ContactId = contacto.Id;
        contactoShare.UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        contactoShare.ContactAccessLevel = 'Edit';
        insert contactoShare;

        return new Map<String, SObject>{'cuenta' => cuenta, 'contacto' => contacto};
    }

    public static Map<String, SObject> crearCuentaContacto(String nif) {
        return crearCuentaContacto(nif, new Map<String, Object>());
    }
}