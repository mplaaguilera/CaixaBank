@isTest
public class CSBD_EmailMessage_Vincular_Test {

    @TestSetup
    private static void testSetup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

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
        
        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'Standard Price Book';
        insert listaPrecios;
    }

    @isTest
    public static void obtenerCorreosNoVinculados() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        String direccionBuzonCaixaBank = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - CaixaBank'].Address;
        String direccionBuzonImaginBank = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - ImaginBank'].Address;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        EmailMessage correo1 = new EmailMessage();
        correo1.CC_Aplicacion__c = 'CSBD';
        correo1.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correo1.MessageDate = System.now().addDays(-1);
        correo1.Incoming = true;
        correo1.ToAddress = direccionBuzonCaixaBank;
        correo1.CC_Interno__c = false;
        correo1.Subject = 'Correo entrante 1 Test';
        correo1.HtmlBody = '<b>Correo</b> <i>entrante</i>';
        correo1.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correo1;

        EmailMessage correo2 = new EmailMessage();
        correo2.CC_Aplicacion__c = 'CSBD';
        correo2.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correo2.MessageDate = System.now().addDays(-2);
        correo2.Incoming = true;
        correo2.ToAddress = direccionBuzonCaixaBank;
        correo2.CC_Interno__c = false;
        correo2.Subject = 'Correo entrante 2 Test';
        correo2.HtmlBody = '<b>Correo</b> <i>entrante</i>';
        correo2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correo2;

        EmailMessage correo3 = new EmailMessage();
        correo3.CC_Aplicacion__c = 'CSBD';
        correo3.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correo3.MessageDate = System.now().addDays(-1);
        correo3.Incoming = true;
        correo3.ToAddress = direccionBuzonImaginBank;
        correo3.CC_Interno__c = false;
        correo3.Subject = 'Correo entrante 3 Test';
        correo3.HtmlBody = '<b>Correo</b> <i>entrante</i>';
        correo3.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correo3;

        //Ejecución de la prueba
        System.runAs ( usuarioGestor ) {
            Test.startTest();
            List<EmailMessage> correosCaixaBank = CSBD_EmailMessage_Vincular_Controller.obtenerCorreosNoVinculados('CaixaBank');
            List<EmailMessage> correosImaginBank = CSBD_EmailMessage_Vincular_Controller.obtenerCorreosNoVinculados('ImaginBank');
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals(2, correosCaixaBank.size());
            System.assertEquals(1, correosImaginBank.size());
        }
    }

    @isTest
    public static void vincularCorreoAOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'CSBD Price Book';
        pb.Description = 'CSBD Price Book';
        pb.IsActive = true;
        insert pb;
        
        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Perdida';
        oportunidad.CSBD_Estado__c = 'Cerrada';
        insert oportunidad;

        oportunidad = [SELECT CSBD_Identificador__c, CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];

        OpportunityShare oppshare = new OpportunityShare();
        oppshare.UserOrGroupId = usuarioGestor.Id;
        oppshare.OpportunityId = oportunidad.Id;
        oppshare.OpportunityAccessLevel = 'Edit';
        insert oppshare;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        EmailMessage correo = new EmailMessage();
        correo.CC_Aplicacion__c = 'CSBD';
        correo.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correo.MessageDate = System.now().addDays(-1);
        correo.CSBD_Oportunidad_Id__c = oportunidad.Id;
        correo.Incoming = true;
        correo.ToAddress = 'solicitud.documentacion@bancadigital.caixabank.com';
        correo.CC_Interno__c = false;
        correo.Subject = 'Correo entrante Test';
        correo.HtmlBody = '<b>Correo</b> <i>entrante</i>';
        correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correo;

        //Ejecución de la prueba
        System.runAs ( usuarioGestor ) {
            Test.startTest();
            CSBD_EmailMessage_Vincular_Controller.vincularCorreoAOportunidadNumero(correo.Id, oportunidad.CSBD_Identificador__c); 
            Test.stopTest();
            
            //El correo origen se elimina
            EmailMessage[] emailOriginal = [SELECT Id FROM EmailMessage WHERE Id = :correo.Id];
            System.assert(emailOriginal.size() == 0);
            
            //Se clona el email
            EmailMessage emailClonado = [SELECT Id FROM EmailMessage WHERE CSBD_Oportunidad_Id__c = :oportunidad.Id AND Subject = :correo.Subject];
            System.assert(emailClonado != null);
            
            //La oportunidad se reactiva
            oportunidad = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals('Activa', oportunidad.CSBD_Estado__c);
        }
        
/*
		correo = [SELECT CSBD_Oportunidad_Id__c, RelatedToId FROM EmailMessage WHERE Id = :correo.Id LIMIT 1];
        oportunidad = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];
        //Evaluación del resultado de la prueba
        System.assertEquals(oportunidad.Id, correo.CSBD_Oportunidad_Id__c);
        //System.assertEquals(oportunidad.Id, correo.RelatedToId);
        System.assertEquals('Activa', oportunidad.CSBD_Estado__c);

*/
    }

    @isTest
    public static void rechazarCorreo() {
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        //Alta de datos para la prueba
        EmailMessage correo1 = new EmailMessage();
        correo1.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correo1.MessageDate = System.now().addDays(-1);
        correo1.Incoming = true;
        correo1.ToAddress = 'solicitud.documentacion@bancadigital.caixabank.com';
        correo1.CC_Interno__c = false;
        correo1.Subject = 'Correo entrante Test';
        correo1.HtmlBody = '<b>Correo</b> <i>entrante</i>';
        correo1.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correo1;

        EmailMessage correo2 = new EmailMessage();
        correo2.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
        correo2.MessageDate = System.now().addDays(-1);
        correo2.Incoming = true;
        correo2.ToAddress = 'solicitud.documentacion@bancadigital.caixabank.com';
        correo2.CC_Interno__c = false;
        correo2.Subject = 'Correo entrante Test';
        correo2.HtmlBody = '<b>Correo</b> <i>entrante</i>';
        correo2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correo2;

        List<Id> idsCorreos = new List<Id>();
        idsCorreos.add(correo1.Id);
        idsCorreos.add(correo2.Id);

        //Ejecución de la prueba
        System.runAs ( CSBD_Usuarios.usuarioAdministrador() ) {
            Test.startTest();
            CSBD_EmailMessage_Vincular_Controller.rechazarCorreo(idsCorreos);
            Test.stopTest();

            correo1 = [SELECT CC_Rechazado__c FROM EmailMessage WHERE Id = :correo1.Id];
            correo2 = [SELECT CC_Rechazado__c FROM EmailMessage WHERE Id = :correo2.Id];

            //Evaluación del resultado de la prueba
            System.assertEquals(true, correo1.CC_Rechazado__c);
            System.assertEquals(true, correo2.CC_Rechazado__c);
        }
    }

    @isTest
    public static void obtenerOportunidades() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta Test';
        cuenta.CC_Numero_Documento__c = '46979396X';
        insert cuenta;

        Contact contacto = new Contact();
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Nombre Test';
        contacto.LastName = 'Apellido Test';
        contacto.Phone = '612345678';
        contacto.Email = 'direccion@de.correo';
        insert contacto;

        Pricebook2 pb = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
        insert pb;
        
        Opportunity oportunidadCaixaBankConCorreo = new Opportunity();
        oportunidadCaixaBankConCorreo.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidadCaixaBankConCorreo.CSBD_Empresa_Proveedora__c = 'CaixaBank';
        oportunidadCaixaBankConCorreo.Name = 'Opportunity Test';
        oportunidadCaixaBankConCorreo.StageName = 'Solicitud';
        oportunidadCaixaBankConCorreo.CSBD_Estado__c = 'Cerrada';
        oportunidadCaixaBankConCorreo.CSBD_Email_Solicitud__c = 'direccion@de.correo';
        insert oportunidadCaixaBankConCorreo;

        Opportunity oportunidadCaixaBankSinCorreo = new Opportunity();
        oportunidadCaixaBankSinCorreo.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidadCaixaBankSinCorreo.CSBD_Empresa_Proveedora__c = 'CaixaBank';
        oportunidadCaixaBankSinCorreo.Name = 'Opportunity Test';
        oportunidadCaixaBankSinCorreo.StageName = 'Solicitud';
        oportunidadCaixaBankSinCorreo.CSBD_Estado__c = 'Cerrada';
        oportunidadCaixaBankSinCorreo.AccountId = cuenta.Id;
        oportunidadCaixaBankSinCorreo.CSBD_Contact__c = contacto.Id;
        insert oportunidadCaixaBankSinCorreo;

        Opportunity oportunidadImaginBankConCorreo = new Opportunity();
        oportunidadImaginBankConCorreo.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidadImaginBankConCorreo.CSBD_Empresa_Proveedora__c = 'imaginBank';
        oportunidadImaginBankConCorreo.Name = 'Opportunity Test';
        oportunidadImaginBankConCorreo.StageName = 'Solicitud';
        oportunidadImaginBankConCorreo.CSBD_Estado__c = 'Cerrada';
        oportunidadImaginBankConCorreo.CSBD_Email_Solicitud__c = 'direccion@de.correo';
        insert oportunidadImaginBankConCorreo;

        //Ejecución de la prueba
        System.runAs ( usuarioGestor ) {
            Test.startTest();
            List<Opportunity> oportunidadesCaixaBank = CSBD_EmailMessage_Vincular_Controller.obtenerOportunidades('CaixaBank', 'direccion@de.correo');
            List<Opportunity> oportunidadesImaginBank = CSBD_EmailMessage_Vincular_Controller.obtenerOportunidades('imaginBank', 'direccion@de.correo');
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals(2, oportunidadesCaixaBank.size());
            System.assertEquals(1, oportunidadesImaginBank.size());
        }
    }
}