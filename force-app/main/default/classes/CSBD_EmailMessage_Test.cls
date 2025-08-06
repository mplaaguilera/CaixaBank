@isTest
public class CSBD_EmailMessage_Test {

    @TestSetup
    private static void altaDatosPrueba() {
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
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            EmailServicesAddress address = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
            Contact contacto = (Contact)CSBD_TestDataFactory.crearCuentaContacto('46979396X').get('contacto');

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                    'CSBD_Estado__c' => 'Activa', 'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id
                });

                EmailMessage correo = new EmailMessage();
                correo.CC_Aplicacion__c = 'CSBD';
                correo.Incoming = true;
                correo.FromAddress = 'from@test.org';
                correo.ToAddress = 'to@test.org';
                correo.Subject = 'asunto correo entrante';
                correo.Headers = '[{"value": "' + address.LocalPart + '@' + address.EmailDomainName + '","name": "X-SFDC-Original-RCPT"}]';
                insert correo;

                Test.startTest();
                CSBD_EmailMessage.vincularCorreoAOportunidad(correo.Id, prestamo.Id);
                Test.stopTest();

                System.assert([SELECT COUNT() FROM EmailMessage WHERE Id = :correo.Id] == 0, 'El correo origen no se ha eliminado');
                System.assert([SELECT COUNT() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: prestamo.Id AND Subject = :correo.Subject] != 0, 'El correo clonado no se ha creado');
                System.assertEquals('Activa', [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :prestamo.Id].CSBD_Estado__c, 'La oportunidad no se ha reactivado');
            }
        }
    }

    @isTest
    public static void historicoCorreosOportunidad() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            EmailServicesAddress address = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
            Contact contacto = (Contact)CSBD_TestDataFactory.crearCuentaContacto('46979396X').get('contacto');

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                    'CSBD_Estado__c' => 'Activa', 'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id
                });

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
                correoEntrante.Headers = '[{"value": "' + address + '","name": "X-SFDC-Original-RCPT"}]';
                insert correoEntrante;

                EmailMessage correoSaliente = new EmailMessage();
                correoSaliente.Status = '3';
                correoSaliente.CC_Aplicacion__c = 'CSBD';
                correoSaliente.RelatedToId = prestamo.Id;
                correoSaliente.CSBD_Oportunidad_Id__c = prestamo.Id;
                correoSaliente.Incoming = false;
                correoSaliente.FromAddress = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName LIKE 'CSBD%' LIMIT 1].Address;
                correoSaliente.ToAddress = 'to@test.org';
                correoSaliente.Subject = 'asunto correo saliente';
                correoSaliente.HtmlBody = 'zape';
                insert correoSaliente;

                Test.startTest();
                String historicoCorreosOportunidad = CSBD_EmailMessage.historicoCorreosOportunidad(prestamo.Id);
                Test.stopTest();

                System.assert(historicoCorreosOportunidad.contains(correoEntrante.HtmlBody), 'El histórico no contiene el cuerpo del corroe entrante');
                System.assert(historicoCorreosOportunidad.contains(correoSaliente.HtmlBody), 'El histórico no contiene el cuerpo del corroe saliente');
            }
        }
    }

    @isTest
    public static void plantillaOperativaId() {
        String operativa = 'Solicitud de documentación hipoteca';

        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Id idPlantilla = CSBD_EmailMessage.plantillaOperativaId(operativa, '');
            Test.stopTest();

            CSBD_Plantillas_Correo__mdt cfgPlantilla = [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt
                                                        WHERE MasterLabel = :operativa AND CSBD_Idioma__c = 'Castellano' LIMIT 1];
            System.assertEquals(
                [SELECT Id FROM EmailTemplate WHERE Name = :cfgPlantilla.CSBD_Nombre_Plantilla__c LIMIT 1].Id,
                idPlantilla, 'Id de plantilla incorrecto'
            );
        }
    }

    @isTest
    public static void plantillaOperativaNombre() {
        String operativa = 'Solicitud de documentación hipoteca';

        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            String nombrePlantilla = CSBD_EmailMessage.plantillaOperativaNombre(operativa, '');
            Test.stopTest();

            CSBD_Plantillas_Correo__mdt cfgPlantilla = [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt
                                                        WHERE MasterLabel = :operativa AND CSBD_Idioma__c = 'Castellano' LIMIT 1];
            System.assertEquals(cfgPlantilla.CSBD_Nombre_Plantilla__c, nombrePlantilla, 'Nombre de plantilla incorrecto');
        }
    }

    @isTest
    public static void descartarCorreosNoCsbd() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            EmailServicesAddress address = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];

            EmailMessage entranteCsbd = new EmailMessage();
            entranteCsbd.Incoming = true;
            entranteCsbd.CC_Aplicacion__c = 'CSBD';
            entranteCsbd.Headers = '[{"value": "' + address.LocalPart + '@' + address.EmailDomainName + '","name": "X-SFDC-Original-RCPT"}]';
            EmailMessage salienteCsbd = new EmailMessage();
            salienteCsbd.Incoming = false;
            salienteCsbd.FromAddress = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName LIKE 'CSBD - %' OR DisplayName LIKE 'Now In Sales - %'LIMIT 1].Address;
            EmailMessage entranteNoCsbd = new EmailMessage();
            entranteNoCsbd.Incoming = true;
            EmailMessage salienteNoCsbd = new EmailMessage();
            salienteNoCsbd.Incoming = false;

            Test.startTest();
            List<EmailMessage> correosCsbd = CSBD_EmailMessage.descartarCorreosNoCsbd(new List<EmailMessage>{entranteCsbd, salienteCsbd, entranteNoCsbd, salienteNoCsbd});
            Test.stopTest();

            System.assertEquals(2, correosCsbd.size(), 'Número incorrecto de correos Csbd');
        }
    }
}