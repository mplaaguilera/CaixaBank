@isTest
public class CSBD_GestorOportunidad_TRHan_Test {
    @TestSetup
    private static void altaDatosPrueba() {
        User userAdmin = CSBD_Usuarios.usuarioAdministrador();
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert listaPrecios;
        
        List<Group> colaPrestamos = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CSBD_Prestamos_I'];
        
        if(colaPrestamos.isEmpty()) {
            Group nuevaColaPrestamos = new Group(Name='Now In Sales - Préstamos I', DeveloperName = 'CSBD_Prestamos_I', Type='Queue');
        	insert nuevaColaPrestamos;
        }

        CC_Lista_Valores__c reglaAsignacion = new CC_Lista_Valores__c();
        reglaAsignacion.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_asignacion_oportunidad').getRecordTypeId();
        reglaAsignacion.Name = 'Oportunidades - Préstamos I';
        reglaAsignacion.CSBD_Cola_Oportunidad__c = 'CSBD_Prestamos_I';
        reglaAsignacion.CSBD_Tipo_de_oportunidad__c = 'Préstamo';
        reglaAsignacion.CC_Orden__c = 1;
        reglaAsignacion.CC_Activa__c = true;
        insert reglaAsignacion;
        
        CC_Lista_Valores__c reglaAsignacion2 = new CC_Lista_Valores__c();
        reglaAsignacion2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_asignacion_oportunidad').getRecordTypeId();
        reglaAsignacion2.Name = 'Oportunidades - Hipotecas';
        reglaAsignacion2.CSBD_Cola_Oportunidad__c = 'CSBD_Hipotecas';
        reglaAsignacion2.CSBD_Tipo_de_oportunidad__c = 'CMB;CMN;Hipoteca';
        reglaAsignacion2.CC_Orden__c = 3;
        reglaAsignacion2.CC_Activa__c = true;
        insert reglaAsignacion2;
        
        List<CSBD_Criterios_asignacion_oportunidad__mdt> criterios = [SELECT Id, CSBD_Cola_Asignada__c, CSBD_Criterio_1__c, CSBD_Criterio_2__c FROM CSBD_Criterios_asignacion_oportunidad__mdt];

    }

    private static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        cuenta.Phone = '666666666';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.Phone = '666666666';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        contacto.CSBD_Limite_Prestamos_Oficinas__c = 20000;
        insert contacto;

        return cuenta;
    }
	
    @isTest
    private static void gestorOportunidadInsert() {
        Account cuenta = crearCuentaContacto('53456777P');
        User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        System.runAs (userAdmin) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
            CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, 'Pendiente de asignar');
            Test.stopTest();

            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

            System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad[0].OwnerId);
            System.assertEquals('Activo', gestorOportunidad[0].CSBD_Estado__c);
        }
    }

    @isTest
    private static void gestorOportunidadUpdate() {
        Account cuenta = crearCuentaContacto('53456777P');
        User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        System.runAs (userAdmin) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
            CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, 'Fuera horario comercial');
            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
            gestorOportunidad[0].CSBD_Estado__c = 'Pendiente de asignar';
            Update gestorOportunidad;
            Test.stopTest();

            List<CSBD_Gestor_Oportunidad__c> gestorOportunidadActualizado = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

            System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidadActualizado[0].OwnerId);
            System.assertEquals('Activo', gestorOportunidadActualizado[0].CSBD_Estado__c);
        }
    }

    @isTest
    private static void gestorOportunidadInsert2() {
        Account cuenta = crearCuentaContacto('53456777P');
        User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba2');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        System.runAs (userAdmin) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
            CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, '');

            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c, CSBD_Oportunidad__c, CSBD_Hora_inicio_contacto__c, CSBD_Hora_fin_contacto__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

            System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad[0].OwnerId);
            System.assertEquals('Activo', gestorOportunidad[0].CSBD_Estado__c);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void gestorOportunidadSincronizar() {
        Account cuenta = crearCuentaContacto('53456777P');
        User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba3');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        System.runAs (userAdmin) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
            CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, '');

            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c, CSBD_Oportunidad__c, CSBD_Hora_inicio_contacto__c, CSBD_Hora_fin_contacto__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

            CSBD_GestorOportunidad.sincronizarGestorOportunidad(new List<Opportunity>{oportunidad}, gestorOportunidad, '');

            System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad[0].OwnerId);
            Test.stopTest();
        }
    }

    @isTest
    private static void gestorOportunidadDesactivar() {
        Account cuenta = crearCuentaContacto('53456777P');
        User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba4');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        System.runAs (userAdmin) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
            CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, '');
            CSBD_GestorOportunidad.desactivarGestorOportunidad(oportunidad.Id);

            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c, CSBD_Oportunidad__c, CSBD_Hora_inicio_contacto__c, CSBD_Hora_fin_contacto__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

            System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad[0].OwnerId);
            Test.stopTest();
        }
    }

    @isTest
    private static void gestorOportunidadActivar() {
        Account cuenta = crearCuentaContacto('53456777P');
        User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
        
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba4');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Cuentas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        System.runAs (userAdmin) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
            CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad});
            CSBD_GestorOportunidad.activarGestorOportunidad(oportunidad.Id);

            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c, CSBD_Oportunidad__c, CSBD_Hora_inicio_contacto__c, CSBD_Hora_fin_contacto__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

            System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad[0].OwnerId);
            Test.stopTest();
        }
    }
    
         @isTest
    private static void gestorOportunidadPrioridad() {
        Account cuenta = crearCuentaContacto('53456777P');
        User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba5');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Horario_Contacto__c', 'Mañana');
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        campos.put('CSBD_Familia_Producto__c', 'Hipotecas');
        campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank'); 
        campos.put('CSBD_Importe_Producto_Principal__c', 200);
        
        System.runAs (userAdmin) {
            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
            CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad});
            CSBD_GestorOportunidad.activarGestorOportunidad(oportunidad.Id);

            List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c, CSBD_Oportunidad__c, CSBD_Hora_inicio_contacto__c, CSBD_Hora_fin_contacto__c, CSBD_OC_Prioridad__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

            System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Hipotecas' LIMIT 1].Id, gestorOportunidad[0].OwnerId);
			System.assertNotEquals(gestorOportunidad[0].CSBD_OC_Prioridad__c, null);
            Test.stopTest();
        }
    }
}