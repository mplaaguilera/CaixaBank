@IsTest
public class CC_Contact_BI_BU_TRHan_TEST {
    
    //Esta clase testea las siguientes dos clases
    //CC_Contact_BI_TRHan_TEST
    //CC_Contact_BU_TRHan_TEST

    @TestSetup
    public static void crearDatosPrueba() {
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        System.debug('uniqueUsername: ' + uniqueUserName);
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='AM_Responsable'];
        UserRole rol = [SELECT Id FROM UserRole WHERE Name = 'CAM'];

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = rol.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        
        insert u;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AM_PS_Responsable2'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

        System.runAs(u) {
            // The following code runs as user 'u'
            Account cuenta2 = new Account();
            cuenta2.Name = 'Cuenta02';
            cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            System.debug('Cuenta 2: ' + cuenta2);
            insert cuenta2; 
            
            Id empleadoContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Contact contacto1 = new Contact ();
            contacto1.recordtypeId = empleadoContactRT;
            contacto1.lastname = 'cnt1';
            contacto1.email = 'testCAM@test.com';
            contacto1.AccountId = cuenta2.Id;
            System.debug('Contacto 1: ' + contacto1);
            insert contacto1;

        }

        String uniqueUserNameCops = 'copsstandarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile pOs = [SELECT Id FROM Profile WHERE Name='OS_Responsable'];
        UserRole rolOs = [SELECT Id FROM UserRole WHERE Name = 'COPS'];

        User uOs = new User(Alias = 'standt', Email='copsstandarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingCops', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pOs.Id, UserRoleId = rolOs.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserNameCops);
        
        insert uOs;

        PermissionSet psOs = [SELECT Id FROM PermissionSet WHERE Name = 'OS_PS_Responsable'];
        insert new PermissionSetAssignment(AssigneeId = uOs.Id, PermissionSetId = psOs.Id);
        
        System.runAs(uOs) {
            // The following code runs as user 'u'
            Account cuenta3 = new Account();
            cuenta3.Name = 'Cuenta03';
            cuenta3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'OS_Buzon_Account');
            insert cuenta3; 
            
            Id empleadoContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId();
            Contact contacto2 = new Contact ();
            contacto2.recordtypeId = empleadoContactRT;
            contacto2.lastname = 'cnt1';
            contacto2.email = 'testCOPS@test.com';
            contacto2.AccountId = cuenta3.Id;
            insert contacto2;
	        AdminSettings__c adminSettings = new AdminSettings__c(
            Validaciones__c = true
        );
        insert adminSettings;
        }

    }
    
    @isTest
    static void avoidDuplicatesEmail_Test(){
    	
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuenta; 
        
        Id colaboradorContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = colaboradorContactRT;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = cuenta.Id;
        
        insert cnt1;
        
        Contact cnt2 = new Contact();
        cnt2.recordtypeId = colaboradorContactRT;
        cnt2.lastname = 'cnt2';
        cnt2.email = 'test@test.com';
        cnt2.AccountId = cuenta.Id;
        
        String nombreError;
        try{
            
            insert cnt2;
        } catch (Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un Colaborador con el mismo Email')?true:false;
			System.AssertEquals(expectedExceptionThrown, true);
            
        }
        
        Contact cnt3 = new Contact();
        cnt3.recordtypeId = colaboradorContactRT;
        cnt3.lastname = 'cnt2';
        cnt3.email = 'Atest@test.com';
        cnt3.AccountId = cuenta.Id;
        
        insert cnt3;
        AdminSettings__c adminSetting = [Select Validaciones__c from AdminSettings__c LIMIT 1];
        adminSetting.Validaciones__c = false;
        update adminSetting;
        cnt3.email = 'test@test.com';
        
        try{           
            update cnt3;
        } catch (Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un Colaborador con el mismo Email')?true:false;
			System.AssertEquals(expectedExceptionThrown, true);
            
        }
        
            
    }

    @isTest
    static void evitarDuplicadosCAM_Test(){

        System.debug('Contactos existentes: ' + [SELECT Id, Name, Email FROM Contact LIMIT 10]);

        User u = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com'];

        System.runAs(u) {
            // The following code runs as user 'u'

            Id empleado2ContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Contact contacto2 = new Contact ();
            contacto2.recordtypeId = empleado2ContactRT;
            contacto2.lastname = 'cnt2';
            contacto2.email = 'testCAM@test.com';

            List<Account> cuenta3 = [SELECT Id FROM Account WHERE Name = 'Cuenta02' LIMIT 2];

            System.debug('Las cuentas creadas son: ' + cuenta3);
            contacto2.AccountId = cuenta3[0].Id;

            System.debug('Los PS del current user son: ' + [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()]);

            try{           
                insert contacto2;
                System.debug('Contactos existentes: ' + [SELECT Id, Name, Email FROM Contact LIMIT 10]);

            } catch (Exception e){
                System.debug('El error que se captura es: ' + e.getMessage());
                Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un Contacto con el mismo Email.')?true:false;
                System.AssertEquals(true, expectedExceptionThrown);
            }
            

        }

    }
    
    @isTest
    static void evitarDuplicadosCOPS_Test(){


        User u = [SELECT Id FROM User WHERE Email = 'copsstandarduser@testorg.com'];

        System.runAs(u) {
            // The following code runs as user 'u'

            Id empleado2ContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId();
            Contact contacto2 = new Contact ();
            contacto2.recordtypeId = empleado2ContactRT;
            contacto2.lastname = 'cnt2';
            contacto2.email = 'testCOPS@test.com';
            
            Contact contacto3 = new Contact ();
            contacto3.recordtypeId = empleado2ContactRT;
            contacto3.lastname = 'cnt2';
            contacto3.email = 'testCOPS2@test.com';

            List<Account> cuenta3 = [SELECT Id FROM Account WHERE Name = 'Cuenta03' LIMIT 2];

            contacto2.AccountId = cuenta3[0].Id;
            
            contacto3.AccountId = cuenta3[0].Id;

            insert contacto3;
            

            try{           
                insert contacto2;
                System.debug('Insert Contactos existentes: ' + [SELECT Id, Name, Email FROM Contact LIMIT 10]);

            } catch (Exception e){
                System.debug('El error que se captura en el Insert es: ' + e.getMessage());
                Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un Contacto con el mismo Email.')?true:false;
                System.AssertEquals(true, expectedExceptionThrown);
            }
            

            contacto3.email = 'testCOPS@test.com';
            try{           
                update contacto3;
                System.debug('Update Contactos existentes: ' + [SELECT Id, Name, Email FROM Contact LIMIT 10]);

            } catch (Exception e){
                System.debug('El error que se captura en el update es: ' + e.getMessage());
                Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un Contacto con el mismo Email.')?true:false;
                System.AssertEquals(true, expectedExceptionThrown);
            }
        }

    }
    
      @isTest
    public static void informarCampoPrioridad() {
         User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        
       
        CSBD_TestDataFactory.crearCuentaContacto('78405562B');
        
        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '78405562B'];
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

       		Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');  
            hipoteca.AccountId = cuenta.Id;
            hipoteca.CSBD_ContactoTitular1__c = contacto.Id;
            hipoteca.CSBD_Tasacion__c = 1000;
            hipoteca.CSBD_Urgencia__c = 'Si';
            hipoteca.CSBD_UsoVivienda2__c = 'Primera residencia';
            hipoteca.Amount = 100000;
            hipoteca.CSBD_AportacionInicial__c = 20000;
            hipoteca.CSBD_TipoOperacion2__c = 'Compra de vivienda';
            hipoteca.put('CSBD_PrecioInmueble__c', 200000);
            hipoteca.put('CSBD_Datos_Calculo_DTI__c', json);
            hipoteca.put('CSBD_Now_Plazo__c', 120);
            update hipoteca;

            CSBD_DatosEntrevistaHipoteca.Deuda deuda = new CSBD_DatosEntrevistaHipoteca.Deuda(new CSBD_DatosEntrevistaHipoteca(hipoteca));
            List<Opportunity> oppHipoteca = [SELECT CSBD_OC_Prioridad__c FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_Hipoteca' AND IsClosed = FALSE];
            Test.stopTest();

            System.assertEquals('13', oppHipoteca[0].CSBD_OC_Prioridad__c, 'Error');
        }
    }
    @IsTest
    static void testContactoConfidencial() {
        User admin = CC_TestDataFactory.getUserAdmin();
        
        System.runAs(admin) {
            Test.startTest();
            // Crear contacto confidencial
            Contact contactoConf = new Contact(
                FirstName = 'Test',
                LastName = 'No Confidencial',
                Email = 'test@test.com',
                Phone = '123456789',
                MobilePhone = '987654321',
                CC_Confidencial__c = true,
                MailingStreet = 'Calle Test',
                MailingCity = 'Ciudad Test',
                MailingState = 'Estado Test',
                MailingCountry = 'País Test',
                MailingPostalCode = '12345',
                CC_Identificador_CBKNow__c = 'TEST123',
                CC_CuentaFacebook__c = 'facebook',
                CC_CuentaTwitter__c = 'twitter'
            );
            
           
            insert contactoConf;
            
            // Debug para verificar acceso a campos
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
            for(String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
                System.debug('Campo: ' + fieldName + ' - Accesible: ' + dfr.isAccessible());
            }

            Test.stopTest();
            
            // Verificar que los campos se vaciaron - Hacemos el query DESPUÉS del Test.stopTest()
            Contact contactoActualizado = [SELECT LastName, FirstName, Email, Phone, MobilePhone, 
                                         MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                                         CC_Identificador_CBKNow__c, CC_CuentaFacebook__c, CC_CuentaTwitter__c 
                                         FROM Contact WHERE Id = :contactoConf.Id];

            System.debug('Contacto actualizado COMPLETO: ' + contactoActualizado);
            // Verificamos cada campo individualmente para mejor debugging
            System.debug('FirstName: ' + contactoActualizado.FirstName);
            System.debug('LastName: ' + contactoActualizado.LastName);
            System.debug('Email: ' + contactoActualizado.Email);
            System.debug('Phone: ' + contactoActualizado.Phone);
            System.debug('MobilePhone: ' + contactoActualizado.MobilePhone);
            
            // Aserciones
            System.assertEquals('', contactoActualizado.FirstName, 'El nombre no es confidencial');
            System.assertEquals('CONFIDENCIAL', contactoActualizado.LastName, 'El apellido no es confidencial');
            System.assertEquals('', contactoActualizado.Email, 'El email no es confidencial');
            System.assertEquals('', contactoActualizado.Phone, 'El telefono no es confidencial');
            System.assertEquals('', contactoActualizado.MobilePhone, 'El movil no es confidencial');
            System.assertEquals(null, contactoActualizado.MailingStreet, 'La calle no es confidencial');
            System.assertEquals('', contactoActualizado.CC_Identificador_CBKNow__c, 'El identificador no es confidencial');
            System.assertEquals('', contactoActualizado.CC_CuentaFacebook__c, 'El facebook no es confidencial');
            System.assertEquals('', contactoActualizado.CC_CuentaTwitter__c, 'El twitter no es confidencial');
        }
    }
}