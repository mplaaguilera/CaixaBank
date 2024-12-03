@isTest
public with sharing class CSBD_Hipoteca_Test {
    @testSetup
    public static void altaDatosPrueba() {
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        insert valorPrestamo;

        CC_Lista_Valores__c valorTpv = new CC_Lista_Valores__c();
        valorTpv.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorTpv.CC_Lista__c = listaValores.Id;
        valorTpv.Name = 'TPV';
        valorTpv.CC_Valor__c = '5';
        insert valorTpv;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'Standard Price Book';
        insert listaPrecios;

        Pricebook2 listaPreciosCsbd = new Pricebook2();+
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert listaPreciosCsbd;

        List<EmailTemplate> plantillas = new List<EmailTemplate>();

        EmailTemplate plantilla1 = new EmailTemplate();
        plantilla1.isActive = true;
        plantilla1.Name = 'Prestamos Hipotecarios CLIENTE - CAT';
        plantilla1.DeveloperName = 'CSBD_Test1_' + System.now().getTime();
        plantilla1.TemplateType = 'text';
        plantilla1.FolderId = UserInfo.getUserId();
        plantillas.add(plantilla1);

        EmailTemplate plantilla2 = new EmailTemplate();
        plantilla2.isActive = true;
        plantilla2.Name = 'Prestamos Hipotecarios CLIENTE - CAST';
        plantilla2.DeveloperName = 'CSBD_Test2_' + System.now().getTime();
        plantilla2.TemplateType = 'text';
        plantilla2.FolderId = UserInfo.getUserId();
        plantillas.add(plantilla2);

        EmailTemplate plantilla3 = new EmailTemplate();
        plantilla3.isActive = true;
        plantilla3.Name = 'Prestamos Hipotecarios OFI - CAST';
        plantilla3.DeveloperName = 'CSBD_Test3_' + System.now().getTime();
        plantilla3.TemplateType = 'text';
        plantilla3.FolderId = UserInfo.getUserId();
        plantillas.add(plantilla3);

        EmailTemplate plantilla4 = new EmailTemplate();
        plantilla4.isActive = true;
        plantilla4.Name = 'Prestamos Hipotecarios OFI - CAT';
        plantilla4.DeveloperName = 'CSBD_Test4_' + System.now().getTime();
        plantilla4.TemplateType = 'text';
        plantilla4.FolderId = UserInfo.getUserId();
        plantillas.add(plantilla4);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert plantillas;
        }
    }

    public static Account crearCuentaContacto(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }

    public static Account crearCuentaOficina(String nif) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        cuenta.CC_Email__c = 'test@test.com';
        cuenta.CC_Numero_Oficina__c = '00044';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Cargo__c = 'DIRECCION';
        contacto.CC_Inactivo__c = false;
        insert contacto;

        return cuenta;
    }

    public static Opportunity crearOportunidadHipoteca(Account cuenta, Account oficina) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Now_Num_Oficina__c', 00044);
        return CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
    }

    @isTest
    private static void hipotecaAutomatismoOportunidad() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Account cuenta = crearCuentaContacto('12345678N');
            Account oficina = crearCuentaOficina('12345678M');

            Opportunity oportunidad = crearOportunidadHipoteca(cuenta, oficina);

            Test.startTest();
            CSBD_Hipoteca.automatismosHipotecas(new List<Id>{oportunidad.Id});
            Test.stopTest();

            System.assert([SELECT Count() FROM EmailMessage WHERE RelatedToId = :oportunidad.Id] > 0, 'Correo no enviado');
        }
    }

    @isTest
    public static void informarCampoPrioridad() {
		System.runAs(CSBD_Usuarios.usuarioGestor()) {
            Account cuentaTitular = new Account();
            cuentaTitular.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            cuentaTitular.Name = 'Titular Test';
            insert cuentaTitular;

            Contact titular = new Contact();
            titular.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            titular.AccountId = cuentaTitular.Id;
            titular.FirstName = 'Titular Test';
            titular.LastName = 'Titular Test';
            insert titular;

            Map<String, Object> campos = new Map<String, Object>{
                'CSBD_PrecioInmueble__c' => 100000,
                'Amount' => 80000,
                'CSBD_Now_Plazo__c' => 120,
                'CSBD_TIN_Inicial__c' => 0.75,
                'CSBD_ContactoTitular1__c' => titular.Id,
                'CSBD_Datos_Calculo_DTI__c' => '{"metadata": {"version": "3"}, "porcentajeGastosConstitucion": 0, "ahorro": 0, "primerTitular": {}, "deuda": {}}'
            };
            Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
            Test.startTest();
            CSBD_Hipoteca.informarCampoPrioridad(new List<Opportunity>{hipoteca}, new Map<Id, Contact>());
            Test.stopTest();

            //System.assert(!retorno.isEmpty(), 'El retorno debe contener datos');
        }
    }
}