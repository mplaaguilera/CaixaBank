@isTest
public with sharing class CSBD_EmailMessage_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Account cliente = crearCuentaContacto('46979396X');

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cliente.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

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
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.isActive = true;
        plantilla.Name = 'Prestamos Hipotecarios CLIENTE - CAST';
        plantilla.DeveloperName = 'CSBD_Test_' + System.now().getTime();
        plantilla.TemplateType = 'text';
        plantilla.FolderId = usuarioGestor.Id;
        System.runAs(usuarioGestor) {
            insert plantilla;
        }
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
        insert contacto;

        return cuenta;
    }

    private static Opportunity crearOportunidadPrestamo(Account cuenta) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('CSBD_Estado__c', 'Activa');
        campos.put('StageName', 'Solicitud');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    @isTest
    public static void vincularCorreoAOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        Opportunity prestamo = crearOportunidadPrestamo(cuenta);
        prestamo.OwnerId = usuarioGestor.Id;
        update prestamo;

        System.runAs ( usuarioGestor ) {
            EmailMessage correo = new EmailMessage();
            correo.CC_Aplicacion__c = 'CSBD';
            correo.Incoming = true;
            correo.FromAddress = 'from@test.org';
            correo.ToAddress = 'to@test.org';
            correo.Subject = 'asunto correo entrante';
            correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            insert correo;

            Test.startTest();
            CSBD_EmailMessage.vincularCorreoAOportunidad(correo.Id, prestamo.Id);
            Test.stopTest();

            /*  System.assertEquals(
                    prestamo.Id,
                    [SELECT CSBD_Oportunidad_Id__c FROM EmailMessage WHERE Id = :correo.Id].CSBD_Oportunidad_Id__c,
                    'El correo no se ha vinculado a la oportunidad'
                ); */
            
            //El correo origen se elimina
            EmailMessage[] emailOriginal = [SELECT Id FROM EmailMessage WHERE Id=:correo.Id];
            System.assert(emailOriginal.size()==0);
            
            //Se clona el email
            EmailMessage emailClonado = [SELECT Id FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: prestamo.Id AND Subject=:correo.Subject];
            System.assert(emailClonado<>null);
            
            //La oportunidad se reactiva
            prestamo = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :prestamo.Id];
            System.assertEquals('Activa', prestamo.CSBD_Estado__c);
        }
    }

    @isTest
    public static void historicoCorreosOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        Opportunity prestamo = crearOportunidadPrestamo(cuenta);

        EmailMessage correoEntrante = new EmailMessage();
        correoEntrante.Status = '3';
        correoEntrante.CC_Aplicacion__c = 'CSBD';
        correoEntrante.RelatedToId = prestamo.Id;
        correoEntrante.CSBD_Oportunidad_Id__c = prestamo.Id;
        correoEntrante.Incoming = true;
        correoEntrante.FromAddress = 'from@test.org';
        correoEntrante.ToAddress = 'to@test.org';
        correoEntrante.Subject = 'asunto correo entrante';
        correoEntrante.HtmlBody = 'zipi';
        correoEntrante.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correoEntrante;

        EmailMessage correoSaliente = new EmailMessage();
        correoSaliente.Status = '3';
        correoSaliente.CC_Aplicacion__c = 'CSBD';
        correoSaliente.RelatedToId = prestamo.Id;
        correoSaliente.CSBD_Oportunidad_Id__c = prestamo.Id;
        correoSaliente.Incoming = false;
        correoSaliente.FromAddress = 'from@test.org';
        correoSaliente.ToAddress = 'to@test.org';
        correoSaliente.Subject = 'asunto correo saliente';
        correoSaliente.HtmlBody = 'zape';
        insert correoSaliente;

        System.runAs ( usuarioGestor ) {
            Test.startTest();
            String historicoCorreosOportunidad = CSBD_EmailMessage.historicoCorreosOportunidad(prestamo.Id);
            Test.stopTest();

            System.assert(historicoCorreosOportunidad.contains(correoEntrante.HtmlBody), 'El histórico no contiene el cuerpo del corroe entrante');
            System.assert(historicoCorreosOportunidad.contains(correoSaliente.HtmlBody), 'El histórico no contiene el cuerpo del corroe saliente');
        }
    }

    @isTest
    public static void plantillaOperativaId() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        String operativa = 'Solicitud de documentación hipoteca';

        System.runAs ( usuarioGestor) {
            Test.startTest();
            Id idPlantilla = CSBD_EmailMessage.plantillaOperativaId(operativa, '');
            Test.stopTest();

            String nombrePlantilla = [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt
                                        WHERE MasterLabel = :operativa AND CSBD_Idioma__c = 'Castellano' LIMIT 1].CSBD_Nombre_Plantilla__c;
            System.assertEquals(
                [SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1].Id,
                idPlantilla,
                'Id de plantilla incorrecto'
            );
        }
    }

    @isTest
    public static void plantillaOperativaNombre() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        String operativa = 'Solicitud de documentación hipoteca';

        System.runAs ( usuarioGestor ) {
            Test.startTest();
            String nombrePlantilla = CSBD_EmailMessage.plantillaOperativaNombre(operativa, '');
            Test.stopTest();

            System.assertEquals(
                [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt
                    WHERE MasterLabel = :operativa AND CSBD_Idioma__c = 'Castellano' LIMIT 1].CSBD_Nombre_Plantilla__c,
                nombrePlantilla,
                'Nombre de plantilla incorrecto'
            );
        }
    }

    @isTest
    public static void descartarCorreosNoCsbd() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        List<EmailMessage> correos = new List<EmailMessage>();

        EmailMessage correoEntranteCsbd = new EmailMessage();
        correoEntranteCsbd.Incoming = true;
        correoEntranteCsbd.CC_Aplicacion__c = 'CSBD';
        correoEntranteCsbd.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        correos.add(correoEntranteCsbd);

        EmailMessage correoSalienteCsbd = new EmailMessage();
        correoSalienteCsbd.Incoming = false;
        correoSalienteCsbd.FromAddress = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName LIKE 'CSBD - %' OR DisplayName LIKE 'Now In Sales - %'LIMIT 1].Address;
        correos.add(correoSalienteCsbd);

        EmailMessage correoEntranteNoCsbd = new EmailMessage();
        correoEntranteCsbd.Incoming = true;
        correos.add(correoEntranteNoCsbd);

        EmailMessage correoSalienteNoCsbd = new EmailMessage();
        correoSalienteNoCsbd.Incoming = false;
        correos.add(correoSalienteNoCsbd);

        insert correos;

        System.runAs ( usuarioGestor ) {
            Test.startTest();
            List<EmailMessage> correosCsbd = CSBD_EmailMessage.descartarCorreosNoCsbd(correos);
            Test.stopTest();

            System.assertEquals(2, correosCsbd.size(), 'Número incorrecto de correos Csbd en la lista proporcionada');
        }
    }

    @isTest
    public static void validarRemitente() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '46979396X'];

        EmailMessage correo = new EmailMessage();
        correo.CC_Aplicacion__c = 'CSBD';
        correo.Incoming = false;
        correo.FromAddress = 'from@test.org';
        correo.ToAddress = 'to@test.org';
        correo.Subject = 'asunto correo entrante';

        Opportunity prestamo = crearOportunidadPrestamo(cuenta);
        correo.RelatedToId = prestamo.Id;

        List<EmailMessage> listaCorreos = new List<EmailMessage>();
        listaCorreos.add(correo);
        
        System.runAs(usuarioGestor) {
            Test.startTest();
            Database.SaveResult result = Database.insert(listaCorreos[0], false);
            Test.stopTest();

            System.assert(result.getErrors()[0].getMessage().contains('El buzón de salida indicado no es apto para el envío de correos.'));
        }
    }
}