@isTest
public with sharing class OB_Parametrizacion_Triggers_Test {
    @TestSetup
    static void makeData(){
        User responsable = new User();
		responsable.LastName = 'Gestor OB Test';
		responsable.Alias = 'gestor';
		responsable.Email = 'gestorcsbd@caixabank.com.invalid';
		responsable.Username = 'gestorob_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
		responsable.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OB Responsable'].Id;
		responsable.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'OB_Generico'].Id;
		responsable.EmailEncodingkey = 'ISO-8859-1';
		responsable.LanguageLocaleKey = 'es';
		responsable.LocalesIdKey = 'es';
		responsable.TimezonesIdKey = 'Europe/Madrid';
		insert responsable;

        System.runAs(responsable) {
            PermissionSet psResponsableOB = [SELECT Id FROM PermissionSet WHERE Name = 'OB_Outbound_Responsable'];
            insert new PermissionSetAssignment(PermissionSetId = psResponsableOB.id, AssigneeId = responsable.Id);

            OB_Parametrizacion__c familia = new OB_Parametrizacion__c();
            familia.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
            familia.Name = 'familia producto test';
            insert familia;

            OB_Parametrizacion__c parametrizacion1 = new OB_Parametrizacion__c();
            parametrizacion1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            parametrizacion1.Name = 'Producto test 1';
            parametrizacion1.OB_Activo__c = true;
            parametrizacion1.OB_Codigo_Externo__c = '1234';
            parametrizacion1.OB_Parametrizacion_Padre__c = familia.Id;
            insert parametrizacion1;

            OB_Parametrizacion__c parametrizacion2 = new OB_Parametrizacion__c();
            parametrizacion2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            parametrizacion1.Name = 'Producto test 2';
            parametrizacion2.OB_Activo__c = false;
            parametrizacion2.OB_Codigo_Externo__c = '1234';
            parametrizacion2.OB_Parametrizacion_Padre__c = familia.Id;
            insert parametrizacion2;
        }
    }

    @isTest
    public static void biValidacionNombreUnico() {
        User usuarioResponsable = [SELECT Id FROM User WHERE LastName = 'Gestor OB Test' LIMIT 1];
        System.runAs(usuarioResponsable) {
            OB_Parametrizacion__c parametrizacionFamilia1 = new OB_Parametrizacion__c();
            parametrizacionFamilia1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
            parametrizacionFamilia1.Name = 'familia producto test 1';

            OB_Parametrizacion__c parametrizacionFamilia2 = new OB_Parametrizacion__c();
            parametrizacionFamilia2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
            parametrizacionFamilia2.Name = 'familia producto test 1';

            Test.startTest();
            insert parametrizacionFamilia1;
            try {
                insert parametrizacionFamilia2;
            } catch (Exception e) {
                System.assertEquals('System.DmlException', e.getTypeName(), 'Tipo incorrecto de excepción');
            }
            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE Name = 'familia producto test 1'], 'Se debería haber creado 1 solo registro');
        }
    }

    @isTest
    public static void biValidacionCodigoExternoActivoUnico() {
        User usuarioResponsable = [SELECT Id FROM User WHERE LastName = 'Gestor OB Test' LIMIT 1];
        System.runAs(usuarioResponsable) {
            List<OB_Parametrizacion__c> familia = [SELECT Id FROM OB_Parametrizacion__c WHERE Name = 'familia producto test' LIMIT 1];

            OB_Parametrizacion__c parametrizacion1 = new OB_Parametrizacion__c();
            parametrizacion1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            parametrizacion1.Name = 'Producto test 1';
            parametrizacion1.OB_Activo__c = true;
            parametrizacion1.OB_Codigo_Externo__c = '4321';
            parametrizacion1.OB_Parametrizacion_Padre__c = familia[0].Id;

            OB_Parametrizacion__c parametrizacion2 = new OB_Parametrizacion__c();
            parametrizacion2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            parametrizacion1.Name = 'Producto test 2';
            parametrizacion2.OB_Activo__c = false;
            parametrizacion2.OB_Codigo_Externo__c = '4321';
            parametrizacion2.OB_Parametrizacion_Padre__c = familia[0].Id;

            OB_Parametrizacion__c parametrizacion3 = new OB_Parametrizacion__c();
            parametrizacion3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            parametrizacion1.Name = 'Producto test 3';
            parametrizacion3.OB_Activo__c = true;
            parametrizacion3.OB_Codigo_Externo__c = '4321';
            parametrizacion3.OB_Parametrizacion_Padre__c = familia[0].Id;

            Test.startTest();
            insert parametrizacion1;
            try {
                insert parametrizacion2;
                insert parametrizacion3;
            } catch (Exception e) {
                System.assertEquals('System.DmlException', e.getTypeName(), 'Tipo incorrecto de excepción');
            }
            System.assertEquals(2, [SELECT Count() FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Producto' AND OB_Codigo_Externo__c = '4321'], 'Se debería haber creado solo 2 registros');
        }
    }

    @isTest
    public static void biNombreRelacionCampanyaProducto() {
        User usuarioResponsable = [SELECT Id FROM User WHERE LastName = 'Gestor OB Test' LIMIT 1];
        System.runAs(usuarioResponsable) {
            List<OB_Parametrizacion__c> familiaProducto = [SELECT Id FROM OB_Parametrizacion__c WHERE Name = 'familia producto test' LIMIT 1];

            OB_Parametrizacion__c campanya = new OB_Parametrizacion__c();
            campanya.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Campanya');
            campanya.Name = 'campaña test';
            campanya.OB_Codigo_Externo__c = '123456';
            insert campanya;

            OB_Parametrizacion__c producto = new OB_Parametrizacion__c();
            producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            producto.Name = 'producto test';
            producto.OB_Parametrizacion_Padre__c = familiaProducto[0].Id;
            producto.OB_Codigo_Externo__c = '5678';
            insert producto;

            OB_Parametrizacion__c relacionCampanyaProducto = new OB_Parametrizacion__c();
            relacionCampanyaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto');
            relacionCampanyaProducto.Name = 'temp';
            relacionCampanyaProducto.OB_Parametrizacion_Padre__c = campanya.Id;
            relacionCampanyaProducto.OB_Parametrizacion_Relacionada__c = producto.Id;
            relacionCampanyaProducto.OB_Tipo_Validacion__c = 'BackOffice';

            Test.startTest();
            insert relacionCampanyaProducto;
            Test.stopTest();

            System.assertEquals(
                campanya.Name + ' - ' + producto.Name,
                [SELECT Name FROM OB_Parametrizacion__c WHERE Id = :relacionCampanyaProducto.Id].Name,
                'Nombre del registro incorrecto debería actualizarse en el trigger  BI'
            );
        }
    }

    @isTest
    public static void biValidacionesRelacionCampanyaProducto() {
        User usuarioResponsable = [SELECT Id FROM User WHERE LastName = 'Gestor OB Test' LIMIT 1];
        System.runAs(usuarioResponsable) {
            OB_Parametrizacion__c campanya = new OB_Parametrizacion__c();
            campanya.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Campanya');
            campanya.Name = 'campaña test';
            campanya.OB_Codigo_Externo__c = '1234567';
            insert campanya;

            //Con envío a GDD
            OB_Parametrizacion__c familiaProductoConEnvioGdd = new OB_Parametrizacion__c();
            familiaProductoConEnvioGdd.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
            familiaProductoConEnvioGdd.Name = 'familia producto con envío a GDD test';
            familiaProductoConEnvioGdd.OB_Envio_GDD__c = true;
            familiaProductoConEnvioGdd.OB_Codigo_GDD__c = '123';
            familiaProductoConEnvioGdd.OB_Area_ALF__c = '456';
            familiaProductoConEnvioGdd.OB_Accion_Alta__c = '789';
            familiaProductoConEnvioGdd.OB_Formato_Codigo_Contrato__c = '9999.999.99999999';
            insert familiaProductoConEnvioGdd;

            OB_Parametrizacion__c productoConEnvioGdd = new OB_Parametrizacion__c();
            productoConEnvioGdd.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            productoConEnvioGdd.Name = 'producto con envío a GDD test';
            productoConEnvioGdd.OB_Parametrizacion_Padre__c = familiaProductoConEnvioGdd.Id;
            productoConEnvioGdd.OB_Codigo_Externo__c = '5678';
            insert productoConEnvioGdd;

            OB_Parametrizacion__c relacionCampanyaProductoConEnvioGdd = new OB_Parametrizacion__c();
            relacionCampanyaProductoConEnvioGdd.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto');
            relacionCampanyaProductoConEnvioGdd.Name = 'temp';  //Se sobreescribe al guardar
            relacionCampanyaProductoConEnvioGdd.OB_Parametrizacion_Padre__c = campanya.Id;
            relacionCampanyaProductoConEnvioGdd.OB_Parametrizacion_Relacionada__c = productoConEnvioGdd.Id;
            relacionCampanyaProductoConEnvioGdd.OB_Tipo_Validacion__c = 'BackOffice';
            relacionCampanyaProductoConEnvioGdd.OB_Envio_GDD__c = true;

            //Sin envío a GDD
            OB_Parametrizacion__c familiaProductoSinEnvioGdd = new OB_Parametrizacion__c();
            familiaProductoSinEnvioGdd.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
            familiaProductoSinEnvioGdd.Name = 'familia producto sin envío a GDD test';
            familiaProductoSinEnvioGdd.OB_Envio_GDD__c = false;
            insert familiaProductoSinEnvioGdd;

            OB_Parametrizacion__c productoSinEnvioGdd = new OB_Parametrizacion__c();
            productoSinEnvioGdd.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
            productoSinEnvioGdd.Name = 'producto sin envío a GDD test';
            productoSinEnvioGdd.OB_Parametrizacion_Padre__c = familiaProductoSinEnvioGdd.Id;
            productoSinEnvioGdd.OB_Codigo_Externo__c = '6789';
            insert productoSinEnvioGdd;

            OB_Parametrizacion__c relacionCampanyaProductoSinEnvioGdd = new OB_Parametrizacion__c();
            relacionCampanyaProductoSinEnvioGdd.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto');
            relacionCampanyaProductoSinEnvioGdd.Name = 'temp'; //Se sobreescribe al guardar
            relacionCampanyaProductoSinEnvioGdd.OB_Parametrizacion_Padre__c = campanya.Id;
            relacionCampanyaProductoSinEnvioGdd.OB_Parametrizacion_Relacionada__c = productoSinEnvioGdd.Id;
            relacionCampanyaProductoSinEnvioGdd.OB_Tipo_Validacion__c = 'BackOffice';
            relacionCampanyaProductoSinEnvioGdd.OB_Envio_GDD__c = true;

            Test.startTest();
            insert relacionCampanyaProductoConEnvioGdd;
            try {
                insert relacionCampanyaProductoSinEnvioGdd;
            } catch (Exception e) {
                System.assertEquals('System.DmlException', e.getTypeName(), 'Tipo incorrecto de excepción');
            }
            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Relacion_Campanya_Producto'], 'Se debería haber creado 1 solo registro');
        }
    }

    @isTest
    public static void buValidacionNombreUnico() {
        User usuarioResponsable = [SELECT Id FROM User WHERE LastName = 'Gestor OB Test' LIMIT 1];
        System.runAs(usuarioResponsable) {
            OB_Parametrizacion__c parametrizacion1 = new OB_Parametrizacion__c();
            parametrizacion1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
            parametrizacion1.Name = 'A';
            insert parametrizacion1;

            OB_Parametrizacion__c parametrizacion2 = new OB_Parametrizacion__c();
            parametrizacion2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
            parametrizacion2.Name = 'B';
            insert parametrizacion2;


            Test.startTest();
            parametrizacion2.Name = 'A';
            try {
                update parametrizacion2;
            } catch (Exception e) {
                System.assertEquals('System.DmlException', e.getTypeName(), 'Tipo incorrecto de excepción');
            }
            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE Name = 'A'], 'Debería existir 1 único registro con Name = "A"');
            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE Name = 'B'], 'Debería existir 1 único registro con Name = "B"');
        }
    }

    @isTest
    public static void buValidacionCodigoExternoActivoUnico() {
        User usuarioResponsable = [SELECT Id FROM User WHERE LastName = 'Gestor OB Test' LIMIT 1];
        System.runAs(usuarioResponsable) {        
            List<OB_Parametrizacion__c> parametrizacion2 = [SELECT OB_Activo__c FROM OB_Parametrizacion__c WHERE OB_Activo__c = true AND RecordType.DeveloperName = 'OB_Producto'];

            Test.startTest();
            parametrizacion2[0].OB_Activo__c = true;
            try {
                update parametrizacion2[0];
            } catch (Exception e) {
                System.assertEquals('System.DmlException', e.getTypeName(), 'Tipo incorrecto de excepción');
            }

            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE OB_Activo__c = true AND RecordType.DeveloperName = 'OB_Producto'], 'Debería existir 1 único registro con Activo = "True"');
            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE OB_Activo__c = false AND RecordType.DeveloperName = 'OB_Producto'], 'Debería existir 1 único registro con Activo = "False"');
            Test.stopTest();
        }
    }

    @isTest
    public static void buValidacionCodigoExternoUnico(){  
        User usuarioResponsable = [SELECT Id FROM User WHERE LastName = 'Gestor OB Test' LIMIT 1];
        System.runAs(usuarioResponsable) { 
            List<OB_Parametrizacion__c> parametrizaciones = [SELECT OB_Codigo_Externo__c FROM OB_Parametrizacion__c WHERE RecordType.DeveloperName = 'OB_Producto'];

            parametrizaciones[1].OB_Codigo_Externo__c = '12345';
            parametrizaciones[0].OB_Codigo_Externo__c = '12345';   
            
            Test.startTest();

            update parametrizaciones;

            Test.stopTest();

            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE OB_Activo__c = true AND OB_Codigo_Externo__c = '12345' AND RecordType.DeveloperName = 'OB_Producto'], 'Debería existir 1 único registro con Activo = "True" y código externo = "12345"');
            System.assertEquals(1, [SELECT Count() FROM OB_Parametrizacion__c WHERE OB_Activo__c = false AND OB_Codigo_Externo__c = '12345' AND RecordType.DeveloperName = 'OB_Producto'], 'Debería existir 1 único registro con Activo = "False" y código externo = "12345"');
        }
    }
}