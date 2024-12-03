@isTest
public with sharing class CC_Caracteristica_Carga_Test {

    public static testMethod void testInsertFile() {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Fichero',
            PathOnClient = 'fichero.txt',
            VersionData = Blob.valueOf('test'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        List<ContentDocument> contentDocumentList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title = 'Fichero'];
        System.assertEquals(1, contentDocumentList.size());
    }

    public static testMethod void testDeleteFile() {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Fichero',
            PathOnClient = 'fichero.txt',
            VersionData = Blob.valueOf('test'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
		ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Title = 'Fichero' LIMIT 1];

        CC_Caracteristica_Carga.deleteFile(contentDocument.Id);

        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Title = 'Fichero'];
        System.assertEquals(0, contentDocumentList.size());
    }

    public static testMethod void testLoadFileEmpleados() {
        Id empleadoCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        CC_Caracteristica__c caracteristicaEmpleado = new CC_Caracteristica__c(
            RecordTypeId = empleadoCaracteristicaRecordTypeId,
            Name = 'Caracteristica Empleado',
            CC_Fecha_vigencia_inicio__c = Datetime.now(),
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'test'
        );
        insert caracteristicaEmpleado;

        Account cuenta = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente',
            CC_Numero_Documento__c = '44445555X'
        );
        insert cuenta;

        Contact empleado = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            LastName = 'apellido',
            AccountId = cuenta.Id,
            CC_Idioma__c = 'es',
            CC_Matricula__c = 'U0145000'
        );
        insert empleado;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Fichero Empleados',
            PathOnClient = 'fichero_empleados.txt',
            VersionData = Blob.valueOf( 'U0145000\n'+
                                        'U0123458\n'+
                                        'nulo'),
            IsMajorVersion = true
        );

        insert contentVersionInsert;
        ContentDocument ficheroEmpleados = [SELECT Id FROM ContentDocument WHERE Title = 'Fichero Empleados'];

        String logUrl = CC_Caracteristica_Carga.loadFile(caracteristicaEmpleado.Id, ficheroEmpleados.Id);

        List<CC_Caracteristica_Detalle__c> detalles = [SELECT Id, CC_Identificador_Formula__c From CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__c =: caracteristicaEmpleado.Id];
        System.assertEquals(1, detalles.size());
        System.assertEquals('U0145000', detalles[0].CC_Identificador_Formula__c);
        System.assertEquals('http', logUrl.substring(0,4));
    }

    public static testMethod void testLoadFileClientesContactos() {
        Id clienteContactoCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Contacto').getRecordTypeId();
        Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id clienteContactoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        CC_Caracteristica__c caracteristicaClienteContacto = new CC_Caracteristica__c(
            RecordTypeId = clienteContactoCaracteristicaRecordTypeId,
            Name = 'Caracteristica Cliente Contacto',
            CC_Fecha_vigencia_inicio__c = Datetime.now(),
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'test'
        );
        insert caracteristicaClienteContacto;

        Account cuenta = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente',
            CC_Numero_Documento__c = '44445555X'
        );
        insert cuenta;

        Contact empleado = new Contact(
            RecordTypeId = clienteContactoRecordTypeId,
            LastName = 'apellido',
            AccountId = cuenta.Id,
            CC_Idioma__c = 'es',
            CC_Numero_Documento__c = '00000000T'
        );
        insert empleado;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Fichero Clientes Contactos',
            PathOnClient = 'fichero_clientes_contactos.txt',
            VersionData = Blob.valueOf( '00000000T\n'+
                                        '00000001R\n'+
                                        'nulo'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        ContentDocument ficheroClientesContactos = [SELECT Id FROM ContentDocument WHERE Title = 'Fichero Clientes Contactos'];

        String logUrl = CC_Caracteristica_Carga.loadFile(caracteristicaClienteContacto.Id, ficheroClientesContactos.Id);

        List<CC_Caracteristica_Detalle__c> detalles = [SELECT Id From CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__c =: caracteristicaClienteContacto.Id];
        System.assertEquals(2, detalles.size());
        System.assertEquals('http', logUrl.substring(0,4));
    }

    public static testMethod void testLoadFileClientesCuentas() {
        Id clienteCuentaCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId();
        Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Cliente_Cuenta Test',
            RecordTypeId = clienteCuentaCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;

        Account cuenta = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente Test 1',
            CC_Numero_Documento__c = '00000000T'
        );
        insert cuenta;

		CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Identificador__c = '00000001R'
        );
        insert detalle;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf( '00000000T\n'+
                                        '00000001R\n'+
                                       	'44445555X\n'+
                                        'nulo'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        ContentDocument document = [SELECT Id FROM ContentDocument WHERE Title = 'Test'];

        String logUrl = CC_Caracteristica_Carga.loadFile(caracteristica.Id, document.Id);

        List<CC_Caracteristica_Detalle__c> detalles = [SELECT Id From CC_Caracteristica_Detalle__c WHERE CC_Identificador__c != :detalle.CC_Identificador__c];
        System.assertEquals(2, detalles.size());
        System.assertEquals('http', logUrl.substring(0,4));
    }

    public static testMethod void testLoadFileCentros() {
        Id centroCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId();
        Id centroRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = centroCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf( '11111-001\n'+
                                        '22222-001\n'+
                                        '33333-001\n'+
                                        'nulo'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        Account cuenta = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Numero_Oficina_Empresa__c = '11111-001'
        );
        insert cuenta;

		CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Identificador__c = '22222-001'
        );
        insert detalle;

        ContentDocument document = [SELECT Id FROM ContentDocument WHERE Title = 'Test'];

        String logUrl = CC_Caracteristica_Carga.loadFile(caracteristica.Id, document.Id);

        List<CC_Caracteristica_Detalle__c> detalles = [SELECT Id, CC_Identificador_Formula__c From CC_Caracteristica_Detalle__c WHERE CC_Identificador__c != :detalle.CC_Identificador__c];
        System.assertEquals(1, detalles.size());
        System.assertEquals('11111-001', detalles[0].CC_Identificador_Formula__c);
        System.assertEquals('http', logUrl.substring(0,4));
    }

    public static testMethod void testLoadFileCentros2() {
        Id centroCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId();
        Id centroRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = centroCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf( '11111-001\n'+
                                        '22222-001\n'+
                                        '33333-001\n'+
                                        'nulo'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        Account cuenta = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Numero_Oficina_Empresa__c = '11111-001'
        );
        insert cuenta;

		CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Centro_CaixaBank__c = cuenta.Id
        );
        insert detalle;

        ContentDocument document = [SELECT Id FROM ContentDocument WHERE Title = 'Test'];

        String logUrl = CC_Caracteristica_Carga.loadFile(caracteristica.Id, document.Id);

        List<CC_Caracteristica_Detalle__c> detalles = [SELECT Id, CC_Identificador_Formula__c From CC_Caracteristica_Detalle__c WHERE Id != :detalle.Id];
    }

    public static testMethod void testLoadFileCuentas2() {
        Id clienteCuentaCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId();
        Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Cliente_Cuenta Test',
            RecordTypeId = clienteCuentaCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;

        Account cuenta = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente Test 1',
            CC_Numero_Documento__c = '00000000T'
        );
        insert cuenta;

		CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Cuenta__c = cuenta.Id
        );
        insert detalle;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf( '00000000T\n'+
                                        '00000001R\n'+
                                       	'44445555X\n'+
                                        'nulo'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        ContentDocument document = [SELECT Id FROM ContentDocument WHERE Title = 'Test'];

        String logUrl = CC_Caracteristica_Carga.loadFile(caracteristica.Id, document.Id);
    }

    public static testMethod void testLoadFileEmpleado2() {
        Id clienteCuentaCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId();
        Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();


        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Cliente_Cuenta Test',
            RecordTypeId = clienteCuentaCaracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;

        Account cuenta = new Account(
        	RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta Cliente Test 1',
            CC_Numero_Documento__c = '00000000T'
        );
        insert cuenta;

        Contact empleado = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            LastName = 'apellido',
            AccountId = cuenta.Id,
            CC_Idioma__c = 'es',
            CC_Matricula__c = 'U0193932'
        );
        insert empleado;

		CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Empleado__c = empleado.Id
        );
        insert detalle;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf( '00000000T\n'+
                                        '00000001R\n'+
                                       	'44445555X\n'+
                                        'nulo'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;

        ContentDocument document = [SELECT Id FROM ContentDocument WHERE Title = 'Test'];

        String logUrl = CC_Caracteristica_Carga.loadFile(caracteristica.Id, document.Id);
    }
}