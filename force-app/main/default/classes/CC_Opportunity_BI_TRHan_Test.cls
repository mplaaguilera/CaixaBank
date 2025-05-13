@isTest
public with sharing class CC_Opportunity_BI_TRHan_Test {
    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
		usuarioGestor.Department = 'Prueba departamento';
		update usuarioGestor;

        CSBD_TestDataFactory.crearCuentaContacto('46979396X');
        CSBD_TestDataFactory.crearCuentaContacto('46979397L');
        CSBD_TestDataFactory.crearCuentaContacto('12345678N');

        /*List<AccountShare> totalPermisos = new List<AccountShare>();
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
        insert totalPermisos;*/
        
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
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = nif;
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = numeroAleatorioString +'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        return cuenta;
    }
    
    @isTest
    public static void inicializarOportunidadTest() {
        User usuarioGestor = [SELECT Id, Department FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];
        Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta1.Id];

        System.runAs (usuarioGestor) {
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('AccountId', cuenta1.Id);
            campos.put('CSBD_Now_NIF__c', cuenta1.CC_Numero_Documento__c);
            campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
            campos.put('CSBD_Telefono_Solicitud__c', '666666667');
            campos.put('CSBD_Empresa_Proveedora__c', 'inTouch');
            campos.put('CSBD_Contact__c',contacto1.Id);
            campos.put('Amount',1);
            campos.put('CSBD_Producto__c','Hipoteca');
            Opportunity CMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);    

            List<Product2> prod = [SELECT Id from Product2 where Name = 'Auto'];
			List<Opportunity> opp = [SELECT CSBD_Equipo__c,AV_PF__c from Opportunity where id =:CMB.Id];
      
            System.AssertEquals(opp[0].CSBD_Equipo__c, usuarioGestor.Department);
            System.AssertEquals(opp[0].AV_PF__c, prod[0].Id);
        }
    }
    
    @isTest
    public static void informarCampoPrioridad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
  
        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
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

            Map<String, Object> hipoteca = new Map<String, Object>();
            hipoteca.put('AccountId', cuenta.Id);
            hipoteca.put('CSBD_ContactoTitular1__c', contacto.Id);
            hipoteca.put('CSBD_Tasacion__c', 1000);
            hipoteca.put('CSBD_Urgencia__c', 'Si');
            hipoteca.put('CSBD_UsoVivienda2__c', 'Primera residencia');
            hipoteca.put('Amount', 100000);
            hipoteca.put('CSBD_AportacionInicial__c', 20000);
            hipoteca.put('CSBD_TipoOperacion2__c', 'Compra de vivienda');
            hipoteca.put('CSBD_PrecioInmueble__c', 200000);
            hipoteca.put('CSBD_Datos_Calculo_DTI__c', json);
            hipoteca.put('CSBD_Now_Plazo__c', 120);

       		CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', hipoteca);

            List<Opportunity> oppHipoteca = [SELECT CSBD_OC_Prioridad__c FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_Hipoteca' AND IsClosed = FALSE];
            Test.stopTest();

            System.assertEquals('13', oppHipoteca[0].CSBD_OC_Prioridad__c, 'Error');

        }
    }

    @isTest
    public static void actualizarIdOportunidadEnCase() {
        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Case caso = new Case(
            Description = 'casoTest',
            Subject = 'casoTest',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuenta.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')
        );
        insert caso;

        System.runAs (usuarioGestor) {
            List <case> casos = new list <case>();
            Map<String, Object> hipoteca = new Map<String, Object>();
            Test.startTest();
            hipoteca.put('CSBD_CasoOrigen__c', caso.Id);
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_MAC', hipoteca);
            Test.stopTest();
            List<Opportunity> oppHipoteca = [SELECT CSBD_CasoOrigen__c FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_MAC' AND IsClosed = FALSE];
            casos = [SELECT Id, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'casoTest' LIMIT 1];
            System.assertNotEquals(null, casos[0].CBK_Case_Extension_Id__c, 'Error');

        }
    }
}