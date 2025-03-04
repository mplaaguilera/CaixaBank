@isTest
public with sharing class CSBD_TestDataFactory {

    // Variable estática para evitar llamadas repetidas a permisosUsuarioGenerico
    private static Boolean permisosUsuarioGenericoAsignados = false;

    public static List<User> usuarioGestor(List<Map<String, Object>> campos) {
        Id idRolCsbd = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
        Id idPerfilGestor = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
        List<User> gestores = new List<User>();
        for (Integer i = 0; i < campos.size(); i++) {
            Map<String, Object> camposGestor = campos[i];
            User gestor = new User();
            gestor.FirstName = 'GestorCSBD';
            gestor.LastName = 'Gestor' + i;
            gestor.IsActive = true;
            gestor.Alias = 'Gestor';
            gestor.Email = 'usuario_test@test.com';
            gestor.EmailEncodingKey = 'ISO-8859-1';
            gestor.LanguageLocaleKey = 'es';
            gestor.LocaleSidKey = 'es_ES';
            gestor.UserRoleId = idRolCsbd;
            gestor.ProfileId = idPerfilGestor;
            gestor.TimeZoneSidKey = 'Europe/Madrid';
            gestor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '_' + i + '@test.com';
            for (String campoGestor : camposGestor.keySet()) {
                gestor.put(campoGestor, camposGestor.get(campoGestor));
            }
            gestores.add(gestor);
        }
        insert gestores;

        Id idPsGestor = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor' LIMIT 1].Id;
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (User gestor : gestores) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = idPsGestor;
            psa.AssigneeId = gestor.Id;
            permissionSetAssignments.add(psa);
        }
        insert permissionSetAssignments;

        List<GroupMember> groupMembers = new List<GroupMember>();
        for (Group grupo : [SELECT Id FROM Group WHERE DeveloperName IN ('CSBD_Empleados', 'CSBD_General')]) {
            for (User gestor : gestores) {
                GroupMember groupMember = new GroupMember();
                groupMember.GroupId = grupo.Id;
                groupMember.UserOrGroupId = gestor.Id;
                groupMembers.add(groupMember);
            }
        }
        insert groupMembers;

        if (!permisosUsuarioGenericoAsignados) {
            permisosUsuarioGenerico();
            permisosUsuarioGenericoAsignados = true;
        }

        return gestores;
    }

    public static User usuarioGestor(Map<String, Object> campos) {
        return usuarioGestor(new List<Map<String, Object>>{campos})[0];
    }

    public static User usuarioGestor() {
        return usuarioGestor(new Map<String, Object>());
    }

    public static User usuarioResponsable() {
        User responsable = usuarioGestor();

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Responsable' LIMIT 1].Id;
        psa.AssigneeId = responsable.Id;
        insert psa;

        return responsable;
    }

    public static User usuarioAdministrador() {
        User admin = new User();
        admin.FirstName = 'AdminCSBD';
        admin.LastName = '1';
        admin.IsActive = true;
        admin.Alias = 'Admin';
        admin.Email = 'usuario_test@test.com';
        admin.EmailEncodingKey = 'ISO-8859-1';
        admin.LanguageLocaleKey = 'es';
        admin.LocaleSidKey = 'es_ES';
        admin.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
        admin.ProfileId = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Administrador del sistema') LIMIT 1].Id;
        admin.TimeZoneSidKey = 'Europe/Madrid';
        admin.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        insert admin;

        Group grp = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Administrador' LIMIT 1];
        insert new GroupMember(GroupId = grp.Id, UserOrGroupId = admin.Id);

        List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name LIKE 'CSBD%' AND Type != 'Group']) {
            PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
            nuevoPermiso.PermissionSetId = ps.Id;
            nuevoPermiso.AssigneeId = admin.Id;
            nuevosPermisos.add(nuevoPermiso);
        }
        insert nuevosPermisos;

        if (!permisosUsuarioGenericoAsignados) {
            permisosUsuarioGenerico();
            permisosUsuarioGenericoAsignados = true;
        }

        return admin;
    }

    private static void asignarPublicGroup(String nombreGroup, Id idUsuario) {
        GroupMember miembroGrupo = new GroupMember();
        miembroGrupo.GroupId = [SELECT Id FROM Group WHERE DeveloperName = :nombreGroup].Id;
        miembroGrupo.UserOrGroupId = idUsuario;
        insert miembroGrupo;
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
            cuenta.Phone = '123456789';
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
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        cuenta.Phone = '123456789';
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
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
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

    public static Map<String, SObject> crearEmpleadoOficina(String numeroOficina, Map<String, Object> campos) {
        //Oficina
        Account oficina = new Account();
        oficina.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        oficina.Name = 'Oficina Test';
        oficina.CC_Numero_Empresa__c = '001';
        oficina.CC_Numero_Oficina__c = numeroOficina;
        oficina.CC_Numero_Oficina_Empresa__c = '001-' + numeroOficina;
        oficina.CC_Email__c = 'oficina@test.com';
        oficina.Phone = '123456789';
        insert oficina;

        AccountShare oficinaShare = new AccountShare();
        oficinaShare.AccountId = oficina.Id;
        oficinaShare.UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        oficinaShare.AccountAccessLevel = 'Edit';
        oficinaShare.OpportunityAccessLevel = 'Edit';
        oficinaShare.CaseAccessLevel = 'Edit';
        insert oficinaShare;

        //Empleado
        Contact empleado = new Contact();
        empleado.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        empleado.AccountId = oficina.Id;
        empleado.CC_Cargo__c = 'DIRECCION';
        empleado.FirstName = 'Nombre';
        empleado.LastName = 'Apellido';
        empleado.CC_Matricula__c = oficina.CC_Numero_Oficina__c + '000000';
        empleado.Email = 'test@test.com';
        for (String nombreCampo : campos.keySet()) {
            empleado.put(nombreCampo, campos.get(nombreCampo));
        }
        insert empleado;

        ContactShare empleadoShare = new ContactShare();
        empleadoShare.ContactId = empleado.Id;
        empleadoShare.UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Empleados' LIMIT 1].Id;
        empleadoShare.ContactAccessLevel = 'Edit';
        insert empleadoShare;

        return new Map<String, SObject>{'oficina' => oficina, 'empleado' => empleado};
    }

    public static Map<String, SObject> crearEmpleadoOficina(String numeroOficina) {
        return crearEmpleadoOficina(numeroOficina, new Map<String, Object>());
    }

    public static Map<String, SObject> crearEmpleadoOficina() {
        return crearEmpleadoOficina('00001', new Map<String, Object>());
    }
}