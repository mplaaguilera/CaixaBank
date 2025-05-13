@isTest
public class CSBD_EmailMessage_Vincular_Test {

    @TestSetup
    private static void testSetup() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

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

            Pricebook2 listaPreciosEstandar = new Pricebook2();
            listaPreciosEstandar.Name = 'Standard Price Book';
            Pricebook2 listaPreciosCsbd = new Pricebook2();
            listaPreciosCsbd.Name = 'CSBD Price Book';
            listaPreciosCsbd.Description = 'CSBD Price Book';
            listaPreciosCsbd.IsActive = true;
            insert new List<Pricebook2>{listaPreciosEstandar, listaPreciosCsbd};
        }
    }

    @isTest
    private static void obtenerCorreosNoVinculados() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            String direccionBuzonCaixaBank = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - CaixaBank'].Address;
            String direccionBuzonImaginBank = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - ImaginBank'].Address;

            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

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
            insert new List<EmailMessage>{correo1, correo2, correo3};

            //Ejecución de la prueba
            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Test.startTest();
                List<EmailMessage> correosCaixaBank = CSBD_EmailMessage_Vincular_Controller.obtenerCorreosNoVinculados('CaixaBank');
                List<EmailMessage> correosImaginBank = CSBD_EmailMessage_Vincular_Controller.obtenerCorreosNoVinculados('ImaginBank');
                Test.stopTest();

                //Evaluación del resultado de la prueba
                System.assertEquals(2, correosCaixaBank.size(), 'Deberían haber 2 correos no vinculados a oportunidades de CaixaBank');
                System.assertEquals(1, correosImaginBank.size(), 'Debería haber 1 correo no vinculado a oportunidades de ImaginBank');
            }
        }
    }

    @isTest
    private static void vincularCorreoAOportunidad() {

        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                'Name' => 'Opportunity Test',
                'StageName' => 'Perdida',
                'CSBD_Estado__c' => 'Cerrada'
            });
            oportunidad = [SELECT CSBD_Identificador__c, CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];

            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

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

            Test.startTest();
            CSBD_EmailMessage_Vincular_Controller.vincularCorreoAOportunidadNumero(correo.Id, oportunidad.CSBD_Identificador__c);
            Test.stopTest();

            //El correo origen se elimina
            System.assert([SELECT Id FROM EmailMessage WHERE Id = :correo.Id].isEmpty(), 'El correo origen debería haberse eliminado');

            //Se clona el email
            EmailMessage emailClonado = [SELECT Id FROM EmailMessage WHERE CSBD_Oportunidad_Id__c = :oportunidad.Id AND Subject = :correo.Subject];
            System.assert(emailClonado != null, 'El correo clonado debería haberse creado');

            //La oportunidad se reactiva
            oportunidad = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals('Activa', oportunidad.CSBD_Estado__c, 'La oportunidad debería haberse reactivado');
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
    private static void rechazarCorreo() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

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
            EmailMessage correo2 = new EmailMessage();
            correo2.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
            correo2.MessageDate = System.now().addDays(-1);
            correo2.Incoming = true;
            correo2.ToAddress = 'solicitud.documentacion@bancadigital.caixabank.com';
            correo2.CC_Interno__c = false;
            correo2.Subject = 'Correo entrante Test';
            correo2.HtmlBody = '<b>Correo</b> <i>entrante</i>';
            correo2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            insert new List<EmailMessage>{correo1, correo2};

            Test.startTest();
            CSBD_EmailMessage_Vincular_Controller.rechazarCorreo(new List<Id>{correo1.Id, correo2.Id});
            Test.stopTest();

            correo1 = [SELECT CC_Rechazado__c FROM EmailMessage WHERE Id = :correo1.Id];
            correo2 = [SELECT CC_Rechazado__c FROM EmailMessage WHERE Id = :correo2.Id];

            //Evaluación del resultado de la prueba
            System.assert(correo1.CC_Rechazado__c, 'El correo 1 debería haberse marcado como rechazado');
            System.assert(correo2.CC_Rechazado__c, 'El correo 2 debería haberse marcado como rechazado');
        }
    }

    @isTest
    private static void obtenerOportunidades() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Map<String, Object> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('46979396X', new Map<String, Object>{
                'FirstName' => 'Nombre Test',
                'LastName' => 'Apellido Test',
                'Phone' => '612345678',
                'Email' => 'direccion@de.correo'
            });
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto = (Contact)cuentaContacto.get('contacto');

            CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new List<Map<String, Object>>{
                new Map<String, Object>{
                    'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
                    'CSBD_Estado__c' => 'Cerrada',
                    'CSBD_Email_Solicitud__c' => 'direccion@de.correo'
                },
                new Map<String, Object>{
                    'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
                    'CSBD_Estado__c' => 'Cerrada',
                    'AccountId' => cuenta.Id,
                    'CSBD_Contact__c' => contacto.Id
                },
                new Map<String, Object>{
                    'CSBD_Empresa_Proveedora__c' => 'imaginBank',
                    'CSBD_Estado__c' => 'Cerrada',
                    'AccountId' => cuenta.Id,
                    'CSBD_Contact__c' => contacto.Id
                }
            });

            Test.startTest();
            List<Opportunity> oportunidadesCaixaBank = CSBD_EmailMessage_Vincular_Controller.obtenerOportunidades('CaixaBank', 'direccion@de.correo');
            List<Opportunity> oportunidadesImaginBank = CSBD_EmailMessage_Vincular_Controller.obtenerOportunidades('imaginBank', 'direccion@de.correo');
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals(2, oportunidadesCaixaBank.size(), 'Deberían haber 2 oportunidades de CaixaBank');
            System.assertEquals(1, oportunidadesImaginBank.size(), 'Debería haber 1 oportunidad de imaginBank');
        }
    }
}