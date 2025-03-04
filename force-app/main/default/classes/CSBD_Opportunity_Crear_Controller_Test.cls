@isTest
public class CSBD_Opportunity_Crear_Controller_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        CC_Lista_Valores__c listaValores2 = new CC_Lista_Valores__c();
        listaValores2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores2.Name = 'CSBD: Acciones comerciales oportunidad';
        insert new List<CC_Lista_Valores__c>{listaValores, listaValores2};

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor2.CC_Lista__c = listaValores2.Id;
        valor2.Name = 'Test1';
        valor2.CC_Valor__c = 'Hipotecas';
        valor2.CC_Valor_SFDC__c = 'Hipoteca';
        valor2.CC_Valor2__c = 'MyBox Home';
        valor2.CSBD_Alta_creacion__c = true;
        insert new List<CC_Lista_Valores__c>{valor, valor2};

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;
    }

    private static Opportunity crearOportunidadPrestamo(Account cuenta) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        if (cuenta != null) {
            campos.put('AccountId', cuenta.Id);
            campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
            campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        }
        return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    @isTest
    public static void diasFechaCierre() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Integer dias = CSBD_Opportunity_Crear_Controller.diasFechaCierre('Préstamo');
            Test.stopTest();

            System.assertEquals(1, dias, 'Fecha de cierre incorrecta');
        }
    }

    @isTest
    public static void crearActividad1() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Opportunity prestamo = crearOportunidadPrestamo(null);

            Test.startTest();
            CSBD_Opportunity_Crear_Controller.crearActividad(prestamo.Id);
            Test.stopTest();

            Integer numTareas = [SELECT Count() FROM Task WHERE WhatId = :prestamo.Id AND Type = 'Alta manual de oportunidad'];
            System.assertEquals(1, numTareas, 'No se ha creado la  tarea de alta manual');
        }
    }

    @isTest
    public static void crearActividad2() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            String tipoExcepcion;
            try {
                CSBD_Opportunity_Crear_Controller.crearActividad('a');
            } catch (Exception e) {
                tipoExcepcion = e.getTypeName();
                System.assertEquals('System.StringException', tipoExcepcion, 'Tipo incorrecto de excepción');
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void getRecordTypesCSBD() {
        Integer numeroRecordTypesCsbd = [SELECT Count() FROM RecordType
                                            WHERE SObjectType = 'Opportunity'
                                            AND RecordType.DeveloperName LIKE 'CSBD_%'
                                            AND RecordType.DeveloperName != 'CSBD_Compra_Estrella'];
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<OT_Picklist.Item> opcionesRecordTypesCsbd = CSBD_Opportunity_Crear_Controller.getRecordTypesCSBD();
            Test.stopTest();

            System.assertEquals(
                numeroRecordTypesCsbd,
                opcionesRecordTypesCsbd.size(),
                'No coincide el número de opciones con el número de record types de oportunidades CSBD'
            );
        }
    }

    @isTest
    public static void crearOppHijas() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Contact contacto = (Contact) CSBD_TestDataFactory.crearCuentaContacto('46979396X').get('contacto');

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Map<String, Object> campos = new Map<String, Object>();
                campos.put('Name', 'oportunidad de prueba');
                campos.put('CSBD_Estado__c', 'Activa');
                campos.put('StageName', 'Solicitud');
                campos.put('AccountId', contacto.AccountId);
                campos.put('CSBD_Contact__c', contacto.Id);
                campos.put('CSBD_Now_NIF__c', contacto.Account.CC_Numero_Documento__c);
                Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

                Test.startTest();
                CSBD_Opportunity_Crear_Controller.altaOportunidadesHijas(hipoteca.Id);
                Test.stopTest();
                Integer oppHijas = [SELECT Count() FROM Opportunity WHERE CSBD_Parent_Id__c = :hipoteca.Id];
                System.assertEquals(1, oppHijas, 'Número de oportunidades hijas incorrecto');
            }
        }
    }
}