@isTest
public class CSBD_Opportunity_Test {

    @testSetup
    public static void altaDatosPrueba() {
        /*
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
            User usuarioResponsable = CSBD_TestDataFactory.usuarioResponsable();
        }
        */

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CSBD_TestDataFactory.crearCuentaContacto('12345678Z');

            //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
            CC_Lista_Valores__c lovDiasCierre = new CC_Lista_Valores__c();
            lovDiasCierre.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            lovDiasCierre.Name = 'CSBD: Días cierre oportunidad por defecto';
            insert lovDiasCierre;

            Id idRecordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
            valorPrestamo.RecordTypeId = idRecordTypeValor;
            valorPrestamo.CC_Lista__c = lovDiasCierre.Id;
            valorPrestamo.Name = 'Préstamo';
            valorPrestamo.CC_Valor__c = '1';
            CC_Lista_Valores__c valorTpv = new CC_Lista_Valores__c();
            valorTpv.RecordTypeId = idRecordTypeValor;
            valorTpv.CC_Lista__c = lovDiasCierre.Id;
            valorTpv.Name = 'TPV';
            valorTpv.CC_Valor__c = '5';
            insert new List<CC_Lista_Valores__c>{valorPrestamo, valorTpv};

            Pricebook2 listaPrecios = new Pricebook2(Name = 'Standard Price Book');
            Pricebook2 listaPreciosCsbd = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true);
            insert new List<Pricebook2>{listaPrecios, listaPreciosCsbd};
        }
    }

    public static Opportunity crearOportunidadPrestamo(Account cuenta) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Telefono_Solicitud__c', '632999999');
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
    }

    @isTest
    public static void actualizarPropietarioOmnichannel() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Contact contacto = [SELECT AccountId, Account.CC_Numero_Documento__c
                                FROM Contact WHERE Account.CC_Numero_Documento__c = '12345678Z'];
            Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                'CSBD_Estado__c' => 'Pendiente Cliente',
                'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c,
                'CSBD_Telefono_Solicitud__c' => '632999999'
            });

            Test.startTest();
            CSBD_Opportunity.actualizarPropietarioOportunidadOmnichannel(new Map<Id, Id>{prestamo.Id => usuarioGestor.Id});
            Test.stopTest();

            System.assertEquals(usuarioGestor.Id, [SELECT OwnerId FROM Opportunity WHERE Id = :prestamo.Id].OwnerId, 'No se ha actualizado el propietario de la oportunidad');
        }
    }

    @isTest
    private static void altaBajaOmnichannelOportunidad() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        Account cuenta = [SELECT Name FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
		System.runAs (usuarioGestor) {
            Opportunity oportunidad = new Opportunity();
            oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad.Name = 'Opportunity Test';
            oportunidad.StageName = 'Formalizada';
            oportunidad.CSBD_Resolucion__c = 'Tarjeta crédito';
            oportunidad.Loss_Reason__c = 'Tarjeta crédito';
            oportunidad.CSBD_Estado__c = 'Cerrada';
            oportunidad.AccountId = cuenta.Id;
            //oportunidad.CSBD_Alta_omnichannel__c = false;
            insert oportunidad;

            /*Opportunity oportunidad2 = new Opportunity();
            oportunidad2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad2.Name = 'Opportunity Test2';
            oportunidad2.StageName = 'Solicitud';
            oportunidad2.CSBD_Estado__c = 'Pendiente Cliente';
            oportunidad2.AccountId = cuenta.Id;
            oportunidad2.CSBD_Alta_omnichannel__c = true;
            insert oportunidad2;*/

            Set<Id> todasLasIdsDePrueba = new Set<Id>();
            todasLasIdsDePrueba.add(oportunidad.Id);
            //todasLasIdsDePrueba.add(oportunidad2.Id);


            Test.startTest();
            CSBD_Opportunity.indicarAltaBajaOmnichannelOportunidad(todasLasIdsDePrueba);
            Test.stopTest();

            Opportunity laOportunidadInsertada = [SELECT Id, CSBD_Alta_omnichannel__c FROM Opportunity WHERE Id = :oportunidad.Id];
            //Opportunity laOportunidadInsertada2 = [SELECT Id, CSBD_Alta_omnichannel__c FROM Opportunity WHERE Id = :oportunidad2.Id];

            System.assertEquals(true, laOportunidadInsertada.CSBD_Alta_omnichannel__c, 'No ha sido dada de alta la opp');
            //System.assertEquals(false, laOportunidadInsertada2.CSBD_Alta_omnichannel__c);
        }
    }

    @isTest
    private static void historicoCorreosOportunidad() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'CSBD_%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

            Opportunity oportunidad = crearOportunidadPrestamo(cuenta);

            String cuerpoCorreoEntrante = '<b>Correo</b> <i>entrante</i>';
            EmailMessage correoEntrante = new EmailMessage();
            correoEntrante.CC_Aplicacion__c = 'CSBD';
            correoEntrante.Status = '0'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
            correoEntrante.MessageDate = System.now().addDays(-1);
            correoEntrante.CSBD_Oportunidad_Id__c = oportunidad.Id;
            correoEntrante.RelatedToId = oportunidad.Id;
            //correoEntrante.ActivityId = actividadCorreoEntrante.Id;
            correoEntrante.Incoming = true;
            correoEntrante.CC_Interno__c = false;
            correoEntrante.CcAddress = 'correoprueba@gmail.com';
            correoEntrante.Subject = 'Correo entrante Test';
            correoEntrante.HtmlBody = cuerpoCorreoEntrante;
            correoEntrante.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            insert correoEntrante;

            String cuerpoCorreoSaliente = '<b>Correo</b> <i>saliente</i>';
            EmailMessage correoSaliente = new EmailMessage();
            correoSaliente.CC_Aplicacion__c = 'CSBD';
            correoSaliente.Status = '3'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
            correoSaliente.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName LIKE 'CSBD%' LIMIT 1].CC_Direccion_Correo__c;
            correoSaliente.MessageDate = System.now();
            correoSaliente.CSBD_Oportunidad_Id__c = oportunidad.Id;
            correoSaliente.RelatedToId = oportunidad.Id;
            //correoSaliente.ActivityId = actividadCorreoSaliente.Id;
            correoSaliente.Incoming = false;
            correoSaliente.CC_Interno__c = false;
            correoSaliente.CcAddress = 'correoprueba@gmail.com';
            correoSaliente.Subject = 'Correo saliente Test';
            correoSaliente.HtmlBody = cuerpoCorreoSaliente;
            insert correoSaliente;
            // Hacemos un update con la misma información para asegurar el valor de CSBD_Oportunidad_Id__c
            // Un trigger ejecuta CSBD_Oportunidad_Id__c = RelatedTo, pero no podemos informar el RelatedTo a mano
            update correoSaliente;

            Test.startTest();
            String historicoCorreos = CSBD_Opportunity.historicoCorreosOportunidad(oportunidad.Id);
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assert(historicoCorreos.contains(cuerpoCorreoEntrante) && historicoCorreos.contains(cuerpoCorreoSaliente), 'No contiene el correo');
        }
    }

    @isTest
    private static void obtenerReferenciaCorreoTest() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs(usuarioGestor) {
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
        Opportunity oportunidad = crearOportunidadPrestamo(cuenta);
            Test.startTest();
            System.assert(
                CSBD_Opportunity.obtenerReferenciaCorreo(oportunidad.Id).length() == 17,
                'La referencia del correo debe tener una longitud de 17 caracteres'
            );
            Test.stopTest();
        }
    }


    @isTest
    public static void cerrarOportunidadTest() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            lista.Name = 'CSBD: Traspaso Imagin - Destinatarios';
            insert lista;
            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor.CC_Lista__c = lista.Id;
            valor.Name = 'CMB';
            valor.CC_Valor__c = 'mailprueba@gmail.com';
            insert valor;

            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

            System.runAs(usuarioGestor) {
                EmailTemplate plantilla = new EmailTemplate();
                plantilla.FolderId = usuarioGestor.Id;
                plantilla.isActive = true;
                plantilla.Name = 'CSBD Traspaso CMB Imagin';
                plantilla.DeveloperName = 'CSBD_Traspaso_CMB_Imagin';
                plantilla.TemplateType = 'Text';
                plantilla.Subject = 'Test Subject';
                plantilla.HtmlValue = 'Body Subject';
                insert plantilla;

                Contact contacto = [SELECT AccountId, Account.CC_Numero_Documento__c, Account.Name
                                    FROM Contact WHERE Account.CC_Numero_Documento__c = '12345678Z' LIMIT 1];

                List<Opportunity> prestamos = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'Name' => 'oportunidad de prueba',
                        'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                        'CSBD_Telefono_Solicitud__c' => '632999999',
                        'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c
                    },
                    new Map<String, Object>{
                        'Name' => 'oportunidad de prueba',
                        'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                        'CSBD_Telefono_Solicitud__c' => '632999999',
                        'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c
                    },
                    new Map<String, Object>{
                        'Name' => 'oportunidad de prueba',
                        'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                        'CSBD_Telefono_Solicitud__c' => '632999999',
                        'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c
                    },
                    new Map<String, Object>{
                        'Name' => 'oportunidad de prueba',
                        'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                        'CSBD_Telefono_Solicitud__c' => '632999999',
                        'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c
                    }
                });

                Opportunity oportunidadFormalizada = prestamos[0];
                Opportunity oportunidadPerdida = prestamos[1];
                Opportunity oportunidadRechazada = prestamos[2];
                Opportunity oportunidadPendienteCliente = prestamos[3];
                Opportunity oportunidadFormalizadaFinal = CSBD_Opportunity.crearOportunidad('CSBD_Desistimiento', new Map<String, Object>{
                    'Name' => 'oportunidad de prueba',
                    'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id,
                    'CSBD_Telefono_Solicitud__c' => '632999999',
                    'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c,
                    'CSBD_Alta_omnichannel__c' => true,
                    'CSBD_Empresa_Proveedora__c' => 'imaginBank',
                    'CSBD_Resolucion__c' => 'Traspasada a Imagin'
                });

                Test.startTest();
                oportunidadFormalizada = CSBD_Opportunity.cerrarOportunidad(oportunidadFormalizada.Id, 'Formalizada', 'Tarjeta crédito');
                oportunidadPerdida = CSBD_Opportunity.cerrarOportunidad(oportunidadPerdida.Id, 'Perdida', 'No localizado');
                oportunidadRechazada = CSBD_Opportunity.cerrarOportunidad(oportunidadRechazada.Id, 'Rechazada', 'Duplicada');
                oportunidadFormalizadaFinal = CSBD_Opportunity.cerrarOportunidad(oportunidadFormalizadaFinal.Id, 'Formalizada', 'Traspasada a Imagin');
                oportunidadPendienteCliente = CSBD_Opportunity.cerrarOportunidad(oportunidadPendienteCliente.Id, 'Formalizada', 'Pendiente Cliente');
                Test.stopTest();

                Date hoy = System.today();
                System.assertEquals('Formalizada', oportunidadFormalizada.StageName, 'No se cumple');
                System.assertEquals('Cerrada', oportunidadFormalizada.CSBD_Estado__c, 'No se cumple');
                System.assertEquals('Tarjeta crédito', oportunidadFormalizada.CSBD_Resolucion__c, 'No se cumple');
                System.assertEquals(hoy, oportunidadFormalizada.CloseDate, 'No se cumple');

                System.assertEquals('Perdida', oportunidadPerdida.StageName, 'No se cumple');
                System.assertEquals('Cerrada', oportunidadPerdida.CSBD_Estado__c, 'No se cumple');
                System.assertEquals('No localizado', oportunidadPerdida.CSBD_Resolucion__c, 'No se cumple');
                System.assertEquals('No localizado', oportunidadPerdida.Loss_Reason__c, 'No se cumple');
                System.assertEquals(hoy, oportunidadPerdida.CloseDate, 'No se cumple');

                System.assertEquals('Rechazada', oportunidadRechazada.StageName, 'No se cumple');
                System.assertEquals('Rechazada', oportunidadRechazada.CSBD_Estado__c, 'No se cumple');
                System.assertEquals('Duplicada', oportunidadRechazada.CSBD_Resolucion__c, 'No se cumple');
                System.assertEquals('Duplicada', oportunidadRechazada.Loss_Reason__c, 'No se cumple');
                System.assertEquals(hoy, oportunidadRechazada.CloseDate, 'No se cumple');

                System.assertEquals('Formalizada', oportunidadFormalizadaFinal.StageName, 'No se cumple');
                System.assertEquals('Cerrada', oportunidadFormalizadaFinal.CSBD_Estado__c, 'No se cumple');
                System.assertEquals('Traspasada a Imagin', oportunidadFormalizadaFinal.CSBD_Resolucion__c, 'No se cumple');
                System.assertEquals(hoy, oportunidadFormalizadaFinal.CloseDate, 'No se cumple');
                System.assertEquals('imaginBank', oportunidadFormalizadaFinal.CSBD_Empresa_Proveedora__c, 'No se cumple');

                System.assertEquals('Formalizada', oportunidadPendienteCliente.StageName,'No se cumple');
                System.assertEquals('Cerrada', oportunidadPendienteCliente.CSBD_Estado__c, 'No se cumple');
                System.assertEquals('Pendiente Cliente', oportunidadPendienteCliente.CSBD_Resolucion__c, 'No se cumple');
                System.assertEquals(hoy, oportunidadPendienteCliente.CloseDate, 'No se cumple');
            }
        }
    }

    @isTest
    public static void pendienteInterno() {
        User usuarioGestor;
        Account cuenta;
        Opportunity oportunidad;

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
            cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
        }

        System.runAs(usuarioGestor) {
            oportunidad = crearOportunidadPrestamo(cuenta);
            oportunidad.OwnerId = usuarioGestor.Id;
            update oportunidad;

            String motivoPendienteInterno;
            for (Schema.DescribeSobjectResult resultado : Schema.describeSObjects(new List<String>{'Opportunity'})) {
                for (Schema.PicklistEntry picklistEntry : resultado.fields.getMap().get('CSBD_Motivo_Pendiente_Interno__c').getDescribe().getPicklistValues()) {
                    if (picklistEntry.isActive()) {
                        motivoPendienteInterno = picklistEntry.getValue();
                        break;
                    }
                }
            }

            Test.startTest();
            CSBD_Opportunity.pendienteInterno(oportunidad.id, motivoPendienteInterno);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad.Id];

            System.assertEquals('Pendiente Interno', oportunidad.CSBD_Estado__c, 'No se cumple');
        }
    }

    @isTest
    public static void reactivarOportunidad() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Account cuenta = [SELECT Name FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

            List<Opportunity> listaOportunidades = new List<Opportunity>();
            Opportunity oportunidad = new Opportunity();
            oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad.Name = 'Opportunity Test';
            oportunidad.StageName = 'Formalizada';
            oportunidad.CSBD_Resolucion__c = 'Tarjeta crédito';
            oportunidad.Loss_Reason__c = 'Tarjeta crédito';
            oportunidad.CSBD_Estado__c = 'Cerrada';
            oportunidad.AccountId = cuenta.Id;
            oportunidad.OwnerId = usuarioGestor.Id;
            listaOportunidades.add(oportunidad);

            Opportunity oportunidad2 = new Opportunity();
            oportunidad2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad2.Name = 'Opportunity Test';
            oportunidad2.StageName = 'Formalizada';
            oportunidad2.CSBD_Resolucion__c = 'Tarjeta crédito';
            oportunidad2.Loss_Reason__c = 'Tarjeta crédito';
            oportunidad2.CSBD_Estado__c = 'Cerrada';
            oportunidad2.AccountId = cuenta.Id;
            oportunidad2.CSBD_Ultima_Etapa_Ventas__c = 'Cerrada';
            oportunidad2.OwnerId = usuarioGestor.Id;
            listaOportunidades.add(oportunidad2);

            Pricebook2 pb = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
            insert pb;

            Opportunity oportunidad3 = new Opportunity();
            oportunidad3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad3.Name = 'Opportunity Test';
            oportunidad3.StageName = 'Formalizada';
            oportunidad3.CSBD_Resolucion__c = 'Tarjeta crédito';
            oportunidad3.Loss_Reason__c = 'Tarjeta crédito';
            oportunidad3.CSBD_Estado__c = 'Cerrada';
            oportunidad3.AccountId = cuenta.Id;
            oportunidad3.Pricebook2Id = pb.Id;
            oportunidad3.OwnerId = usuarioGestor.Id;
            listaOportunidades.add(oportunidad3);

            Opportunity oportunidadHija = new Opportunity();
            oportunidadHija.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidadHija.Name = 'Opportunity Test';
            oportunidadHija.StageName = 'Rechazada';
            oportunidadHija.CSBD_Resolucion__c = 'Dupicada';
            oportunidadHija.Loss_Reason__c = 'Dupicada';
            oportunidadHija.CSBD_Estado__c = 'Rechazada';
            oportunidadHija.AccountId = cuenta.Id;
            oportunidadHija.OwnerId = usuarioGestor.Id;
            oportunidadHija.CSBD_Parent_Id__c = oportunidad3.Id;
            listaOportunidades.add(oportunidadHija);
            insert listaOportunidades;

            Test.startTest();
            oportunidad = CSBD_Opportunity.reactivarOportunidad(oportunidad.Id, 'Solicitud');
            oportunidad2 = CSBD_Opportunity.reactivarOportunidad(oportunidad2.Id, true);
            oportunidad3 = CSBD_Opportunity.reactivarOportunidad(oportunidad3.Id);
            oportunidadHija = CSBD_Opportunity.reactivarOportunidad(oportunidadHija.Id);
            Test.stopTest();

            oportunidad = [SELECT StageName, CSBD_Resolucion__c, CSBD_Estado__c, Loss_Reason__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals('Solicitud', oportunidad.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidad.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidad.CSBD_Resolucion__c,'No se cumple');
            System.assertEquals(null, oportunidad.Loss_Reason__c, 'No se cumple');

            oportunidad2 = [SELECT StageName, CSBD_Resolucion__c, CSBD_Estado__c, Loss_Reason__c FROM Opportunity WHERE Id = :oportunidad2.Id];
            System.assertEquals('Cerrada', oportunidad2.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidad2.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidad2.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(null, oportunidad2.Loss_Reason__c, 'No se cumple');

            oportunidad3 = [SELECT StageName, CSBD_Resolucion__c, CSBD_Estado__c, Loss_Reason__c FROM Opportunity WHERE Id = :oportunidad3.Id];
            System.assertEquals('Solicitud', oportunidad3.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidad3.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidad3.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(null, oportunidad3.Loss_Reason__c,'No se cumple');

            oportunidadHija = [SELECT StageName, CSBD_Resolucion__c, CSBD_Estado__c, Loss_Reason__c FROM Opportunity WHERE Id = :oportunidadHija.Id];
            System.assertEquals('Solicitud', oportunidadHija.StageName, 'No se cumple');
            System.assertEquals('Activa', oportunidadHija.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadHija.CSBD_Resolucion__c, 'No se cumple');
            System.assertEquals(null, oportunidadHija.Loss_Reason__c,'No se cumple');
        }
    }

    @isTest
    public static void oportunidadEnPendienteCliente(){
        User usuarioAdmin = CSBD_TestDataFactory.usuarioAdministrador();

        System.runAs (usuarioAdmin) {
            Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

            Opportunity oportunidad = new Opportunity();
            oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad.Name = 'Opportunity Test';
            oportunidad.StageName = 'Formalizada';
            oportunidad.CSBD_Estado__c = 'Activa';
            oportunidad.CSBD_Dejar_Pendiente_Cliente__c = true;
            oportunidad.AccountId = cuenta.Id;
            oportunidad.OwnerId = usuarioAdmin.Id;
            insert oportunidad;

            Map<Id, Id> mapaOportunidadesCorreosPendCliente = new Map<Id, Id>();
            mapaOportunidadesCorreosPendCliente.put(oportunidad.Id, oportunidad.Id);

            Test.startTest();
            CSBD_Opportunity.oportunidadPendienteCliente(mapaOportunidadesCorreosPendCliente);
            Test.stopTest();

            Opportunity laOportunidadInsertada = [SELECT CSBD_Estado__c, CSBD_Reactivada_Respuesta_Recibida__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals('Pendiente Cliente', laOportunidadInsertada.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(false, laOportunidadInsertada.CSBD_Reactivada_Respuesta_Recibida__c, 'No se cumple');
        }
    }

    @isTest
    public static void findePendienteCliente(){
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

            Opportunity oportunidad = new Opportunity();
            oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad.Name = 'Opportunity Test';
            oportunidad.StageName = 'Formalizada';
            oportunidad.CSBD_Estado__c = 'Pendiente Cliente';
            oportunidad.CSBD_Reactivada_Respuesta_Recibida__c = false;
            oportunidad.AccountId = cuenta.Id;
            oportunidad.OwnerId = usuarioGestor.Id;
            insert oportunidad;

            Test.startTest();
            CSBD_Opportunity.oportunidadFinPendienteCliente(oportunidad.Id);
            Test.stopTest();

            Opportunity laOportunidadInsertada = [SELECT CSBD_Estado__c, CSBD_Reactivada_Respuesta_Recibida__c FROM Opportunity WHERE Id = :oportunidad.Id];
            System.assertEquals(laOportunidadInsertada.CSBD_Estado__c,'Activa', 'No se cumple');
            System.assertEquals(true, laOportunidadInsertada.CSBD_Reactivada_Respuesta_Recibida__c, 'No se cumple');
        }
    }

    @isTest
    public static void prepararOportunidadParaEnvioCorreo() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

            //Ejecución de la prueba
            EmailTemplate plantilla = new EmailTemplate();
            plantilla.FolderId = usuarioGestor.Id;
            plantilla.isActive = true;
            plantilla.Name = 'Test Plantilla';
            plantilla.DeveloperName = 'plantillaDeveloperName';
            plantilla.TemplateType = 'Text';
            plantilla.Subject = 'Test Subject';
            plantilla.HtmlValue = 'Body Subject';
            System.runAs (usuarioGestor) {
                insert plantilla;
            }

            Opportunity oportunidad = crearOportunidadPrestamo(cuenta);
            oportunidad.OwnerId = usuarioGestor.Id;
            update oportunidad;

            Test.startTest();
            EmailTemplate resultadoPlantilla = CSBD_Opportunity.prepararOportunidadParaEnvioCorreo(oportunidad.Id, 'plantillaDeveloperName', true, false);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Plantilla_Correo__c, CSBD_Referencia_Correo_Saliente__c
                            FROM Opportunity WHERE Id = :oportunidad.Id];
            //Evaluación del resultado de la prueba
            System.assert(oportunidad.CSBD_Plantilla_Correo__c == 'plantillaDeveloperName', 'No se cumple');
            System.assert(oportunidad.CSBD_Referencia_Correo_Saliente__c != null, 'No se cumple');
            System.assertEquals(plantilla.Subject, resultadoPlantilla.Subject, 'No se cumple');
            System.assert(resultadoPlantilla.HtmlValue.contains(plantilla.HtmlValue), 'No se cumple');
            // System.assertEquals(plantilla.HtmlValue, resultadoPlantilla.HtmlValue); MCG:: Reemplazo por assert anterior: Si añado semilla no pueden ser iguales
        }
    }

    @isTest
    private static void crearOportunidad() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
            listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
            listaValores.CC_Activa__c = true;
            insert listaValores;

            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor.CC_Lista__c = listaValores.Id;
            valor.Name = 'TPV';
            valor.CC_Valor__c = '5';
            listaValores.CC_Activa__c = true;
            insert valor;

            Map<String, Object> fields = new Map<String, Object>();
            String recordTypeDeveloperName;
            recordTypeDeveloperName = 'CSBD_TPV';
            fields.put('Name', 'temp trigger');
            //fields.put('CSBD_Now_Referencia_Usuario__c', 'Ref. User');
            fields.put('CSBD_Now_Apellido1__c', 'Apellido1');
            fields.put('CSBD_Now_Apellido2__c', 'Apellido1');
            //fields.put('CSBD_Now_EmailCliente__c', 'test@test.com');
            fields.put('CSBD_Email_Solicitud__c', 'test@test.com');
            //fields.put('CSBD_Now_TelOficina__c', '555666333');
            fields.put('CSBD_Now_Num_Oficina__c', Integer.valueOf('1234'));
            //fields.put('CSBD_Now_NUMPERSO__c', '2544588');
            fields.put('CSBD_Now_EmailGestor__c', 'gestor@test.com');
            fields.put('CSBD_Now_Nombre__c', 'NombrePrueba');
            //fields.put('CSBD_Now_HorarioContacto__c', 'Mañana');
            //fields.put('CSBD_Now_TipoIdentificador__c', 'Identificador');
            //fields.put('CSBD_Now_Identificador__c', 'ID-001');
            //fields.put('CSBD_Now_ImporteSolicitado__c', Integer.valueOf('20750'));
            //fields.put('CSBD_Now_TelefonoCliente__c', '936596688');
            fields.put('CSBD_Telefono_Solicitud__c', '936596688');
            //fields.put('CSBD_Now_ImporteDisponible__c', Integer.valueOf('10258'));
            fields.put('StageName', 'Solicitud');

            Test.startTest();
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad(recordTypeDeveloperName, fields);
            Test.stopTest();

            System.assert(oportunidad.Name == 'temp trigger', 'Falla el Name');
            System.assert(oportunidad.CSBD_Now_Apellido1__c == 'Apellido1', 'Falla el apellido 1');
            System.assert(oportunidad.CSBD_Now_Apellido2__c == 'Apellido1', 'Falla el apellido 2');
            System.assert(oportunidad.CSBD_Email_Solicitud__c == 'test@test.com', 'Falla el email');
            System.assert(oportunidad.CSBD_Now_EmailGestor__c == 'gestor@test.com', 'Falla el email gestor');
            System.assert(oportunidad.CSBD_Now_Nombre__c == 'NombrePrueba', 'Falla el Nombre Now');
            System.assert(oportunidad.CSBD_Telefono_Solicitud__c == '936596688', 'Falla el teléfono');
            System.assert(oportunidad.StageName == 'Solicitud', 'Falla la etapa');
        }
    }

    private static Opportunity oportunidadCita(Id ownerId) {
        Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
        oportunidad.Name = 'Opportunity Test';
        oportunidad.StageName = 'Solicitud';
        oportunidad.AccountId = cuenta.Id;
        oportunidad.OwnerId = ownerId;

        insert oportunidad;

        return oportunidad;
    }

    @isTest
    private static void programarCita() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        Datetime startDateTime = system.now();
        System.runAs (usuarioGestor) {
            Opportunity oportunidad = oportunidadCita(usuarioGestor.Id);

            Test.startTest();
            CSBD_Opportunity.programarCita(oportunidad.id, false, false, oportunidad.ownerId, startDateTime);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Estado__c, CSBD_Motivo_Pendiente_Interno__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Event[] evento = [SELECT Id, CC_Detalles_Consulta__c FROM Event WHERE WhatId=:oportunidad.id];

            System.assertEquals('Pendiente Cita', oportunidad.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('No Contactado', oportunidad.CSBD_Motivo_Pendiente_Interno__c, 'No se cumple');
            System.assertEquals('No Contactado', evento[0].CC_Detalles_Consulta__c, 'No se cumple');
            System.assert(!evento.isEmpty(), 'No se cumple');
        }
    }

    @isTest
    private static void programarCitaSinIdDePropietario() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Opportunity oportunidad = oportunidadCita(usuarioGestor.Id);
            oportunidad.OwnerId = usuarioGestor.Id;
            update oportunidad;

            Id idPropietario = null;
            Datetime startDateTime = system.now();

            Test.startTest();
            CSBD_Opportunity.programarCita(oportunidad.id, false, false, idPropietario,startDateTime);
            Test.stopTest();

            oportunidad = [SELECT CSBD_Estado__c, CSBD_Motivo_Pendiente_Interno__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Event[] evento = [SELECT Id, CC_Detalles_Consulta__c FROM Event WHERE WhatId=:oportunidad.id];

            System.assertEquals('Pendiente Cita', oportunidad.CSBD_Estado__c, 'No se cumple');
            System.assertEquals('No Contactado', oportunidad.CSBD_Motivo_Pendiente_Interno__c, 'No se cumple');
            System.assertEquals('No Contactado', evento[0].CC_Detalles_Consulta__c, 'No se cumple');
            System.assert(!evento.isEmpty(), 'No se cumple');
        }
    }

    @isTest
    public static void finalizarCita() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Account cuenta = [SELECT Id, Name FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

            Opportunity oportunidad = oportunidadCita(usuarioGestor.Id);
            oportunidad.CSBD_Asignacion_Auto_Pendiente__c = true;
            update oportunidad;

            List<CSBD_Opportunity.FinalizarClienteInput> listaFinalizaciones = new List<CSBD_Opportunity.FinalizarClienteInput>();
            CSBD_Opportunity.FinalizarClienteInput finalizacion= new CSBD_Opportunity.FinalizarClienteInput();
            finalizacion.nuevoEstado = 'Completado';
            finalizacion.motivoCancelado = '';
            finalizacion.idOportunidad = oportunidad.id;
            listaFinalizaciones.add(finalizacion);

            Event e = new Event(
                Subject = 'Finalizar cita Oliver',
                OwnerId = usuarioGestor.Id,
                AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
                RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CSBD_Cita_Cliente').getRecordTypeId(),
                EndDateTime = System.now().addMinutes(60),
                // DurationInMinutes= null,
                ActivityDateTime = System.now(),
                StartDateTime = System.now(),
                WhatId = oportunidad.id,
                CSBD_Evento_Estado__c = 'Pendiente'
            );
            insert e;

            Opportunity oportunidad2 = new Opportunity();
            oportunidad2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
            oportunidad2.Name = 'Opportunity Test';
            oportunidad2.StageName = 'Solicitud';
            oportunidad2.AccountId = cuenta.Id;
            oportunidad2.OwnerId = usuarioGestor.Id;
            insert oportunidad2;

            oportunidad2.CSBD_Asignacion_Auto_Pendiente__c = false;
            update oportunidad2;

            CSBD_GestorOportunidad.activarGestorOportunidad(oportunidad2.Id);

            List<CSBD_Opportunity.FinalizarClienteInput> listaFinalizaciones2 = new List<CSBD_Opportunity.FinalizarClienteInput>();
            CSBD_Opportunity.FinalizarClienteInput finalizacion2= new CSBD_Opportunity.FinalizarClienteInput();
            finalizacion2.nuevoEstado = 'Cancelado';
            finalizacion2.motivoCancelado = 'Canceladisimo';
            finalizacion2.idOportunidad = oportunidad2.id;
            listaFinalizaciones2.add(finalizacion2);

            Event e2 = new Event(
                Subject = 'Finalizar cita Oliver2',
                OwnerId = usuarioGestor.Id,
                AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
                RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CSBD_Cita_Cliente').getRecordTypeId(),
                EndDateTime = System.now().addMinutes(60),
                // DurationInMinutes= null,
                ActivityDateTime = System.now(),
                StartDateTime = System.now(),
                WhatId = oportunidad2.id,
                CSBD_Evento_Estado__c = 'Pendiente'
            );
            insert e2;

            Test.startTest();
            CSBD_Opportunity.finalizarCita(listaFinalizaciones);
            CSBD_Opportunity.finalizarCita(listaFinalizaciones2, false);
            Test.stopTest();

            Opportunity oportunidadQuery = [SELECT CSBD_Estado__c, CSBD_Fecha_Cita__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Fecha_ultimacita__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Opportunity oportunidadQuery2 = [SELECT CSBD_Estado__c, CSBD_Fecha_Cita__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Fecha_ultimacita__c,OwnerId FROM Opportunity WHERE Id = :oportunidad2.Id];
            Event evento = [SELECT CSBD_Evento_Estado__c, CC_Tipo_Cierre__c FROM Event WHERE WhatId=:oportunidad.id LIMIT 1];
            Event evento2 = [SELECT CSBD_Evento_Estado__c, CC_Tipo_Cierre__c FROM Event WHERE WhatId=:oportunidad2.id LIMIT 1];
            List<CSBD_Gestor_Oportunidad__c> gestoresOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c, CSBD_Oportunidad__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =:oportunidadQuery2.Id];

            System.assertEquals(System.now().date(), oportunidadQuery.CSBD_Fecha_ultimacita__c.date(), 'No se cumple');
            System.assertEquals(System.now().hourGmt(), Integer.valueOf(oportunidadQuery.CSBD_Fecha_ultimacita__c.hourGmt()), 'No se cumple');
            System.assertEquals('Activa', oportunidadQuery.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadQuery.CSBD_Fecha_Cita__c, 'No se cumple');
            System.assertEquals(false, oportunidadQuery.CSBD_Asignacion_Auto_Pendiente__c, 'No se cumple');

            System.assertEquals('Activa', oportunidadQuery2.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadQuery2.CSBD_Fecha_Cita__c, 'No se cumple');
            System.assertEquals(false, oportunidadQuery2.CSBD_Asignacion_Auto_Pendiente__c, 'No se cumple');

            System.assertEquals('Completado',evento.CC_Tipo_Cierre__c, 'No se cumple');
            System.assertEquals('Completado',evento.CSBD_Evento_Estado__c, 'No se cumple');
            System.assertEquals('Canceladisimo',evento2.CC_Tipo_Cierre__c, 'No se cumple');
            System.assertEquals('Cancelado',evento2.CSBD_Evento_Estado__c, 'No se cumple');
        }
    }

    @isTest
    public static void finalizarCita2() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Opportunity oportunidad = oportunidadCita(usuarioGestor.Id);
			Datetime fechaActual = System.now();
            Event e = new Event(
                Subject = 'Finalizar cita Oliver2',
                OwnerId = usuarioGestor.Id,
                AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
                RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CSBD_Cita_Cliente').getRecordTypeId(),
                EndDateTime = System.now().addMinutes(60),
                // DurationInMinutes= null,
                ActivityDateTime = fechaActual,
                StartDateTime = fechaActual,
                WhatId = oportunidad.id,
                CSBD_Evento_Estado__c = 'Pendiente'
            );
            insert e;

            Test.startTest();
            CSBD_Opportunity.finalizarCita(oportunidad.Id,'Completado', null, false);
            Test.stopTest();

            Opportunity oportunidadQuery = [SELECT CSBD_Estado__c, CSBD_Fecha_Cita__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Fecha_ultimacita__c FROM Opportunity WHERE Id = :oportunidad.Id];
            Event evento = [SELECT CSBD_Evento_Estado__c, CC_Tipo_Cierre__c FROM Event WHERE WhatId=:oportunidad.id LIMIT 1];

            System.assertEquals('Activa', oportunidadQuery.CSBD_Estado__c, 'No se cumple');
            System.assertEquals(null, oportunidadQuery.CSBD_Fecha_Cita__c, 'No se cumple');
            System.assertEquals(false, oportunidadQuery.CSBD_Asignacion_Auto_Pendiente__c, 'No se cumple');

            System.assertEquals('Completado',evento.CC_Tipo_Cierre__c, 'No se cumple');
            System.assertEquals('Completado',evento.CSBD_Evento_Estado__c, 'No se cumple');
        }
    }

    @isTest
    public static void actualizarEstadoOportunidadTest() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Map<String, Object> fields = new Map<String, Object>();
            fields.put('CSBD_Now_Apellido1__c', 'Apellido1');
            fields.put('CSBD_Now_Apellido2__c', 'Apellido1');
            fields.put('CSBD_Email_Solicitud__c', 'test@test.com');
            fields.put('CSBD_Now_Num_Oficina__c', Integer.valueOf('1234'));
            fields.put('CSBD_Now_EmailGestor__c', 'gestor@test.com');
            fields.put('CSBD_Now_Nombre__c', 'NombrePrueba');
            fields.put('CSBD_Telefono_Solicitud__c', '936596688');
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_TPV', fields);

            Test.startTest();
            oportunidad.CSBD_Estado__c = 'Pendiente Cita';
            oportunidad.StageName = 'Gestión';
            oportunidad.OwnerId = usuarioGestor.Id;
            update oportunidad;
            Test.stopTest();

            System.assert(oportunidad.CSBD_Now_Apellido1__c == 'Apellido1', 'Falla el apellido 1');
            System.assert(oportunidad.CSBD_Now_Apellido2__c == 'Apellido1', 'Falla el apellido 2');
            System.assert(oportunidad.CSBD_Email_Solicitud__c == 'test@test.com', 'Falla el email');
            System.assert(oportunidad.CSBD_Now_EmailGestor__c == 'gestor@test.com', 'Falla el email gestor');
            System.assert(oportunidad.CSBD_Now_Nombre__c == 'NombrePrueba', 'Falla el Nombre Now');
            System.assert(oportunidad.CSBD_Telefono_Solicitud__c == '936596688', 'Falla el teléfono');
            System.assert(oportunidad.CSBD_Estado__c == 'Pendiente Cita', 'Falla el estado');
        }

    }

    @isTest
    private static void duplicarOportunidad() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs(usuarioGestor) {
            Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
            Opportunity oportunidadFormalizada = crearOportunidadPrestamo(cuenta);

            Test.startTest();
            Opportunity oppDuplicada = CSBD_Opportunity.duplicarOportunidad(oportunidadFormalizada, 'CSBD_Prestamo', 'CaixaBank');
            Test.stopTest();

            oppDuplicada = [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :oppDuplicada.Id];

            System.assertEquals(oportunidadFormalizada.Id, oppDuplicada.CSBD_Parent_Id__c, 'No se cumple');
        }
    }

    @isTest
    public static void controlDuplicados() {
        Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Opportunity oportunidad1 = crearOportunidadPrestamo(cuenta);
            Opportunity oportunidad2 = crearOportunidadPrestamo(cuenta);

            Test.startTest();
            CSBD_Control_Duplicados.controlDuplicados(new List<Id>{oportunidad2.Id});
            Test.stopTest();

            System.assertEquals('Rechazada', [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad1.Id].CSBD_Estado__c, 'La oportunidad 1 debería haberse rechazado por duplicada.');
            System.assertEquals('Nueva', [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :oportunidad2.Id].CSBD_Estado__c, 'El estado de la oportunidad 2 debería ser "Nueva".');
        }
    }

    @isTest
    public static void intouchEnviarEmail() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs (usuarioGestor) {
            Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
            Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];

            Map<String, Object> campos = new Map<String, Object>();
            campos.put('AccountId', cuenta.Id);
            campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
            campos.put('CSBD_Email_Solicitud__c', 'test1@test.com');
            campos.put('CSBD_Telefono_Solicitud__c', '666666667');
            campos.put('CSBD_Empresa_Proveedora__c', 'inTouch');
            campos.put('CSBD_Contact__c',contacto.Id);
            campos.put('Amount',1);
            Opportunity cMB = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);

            cMB.OwnerId = usuarioGestor.Id;
            update cMB;

            Test.startTest();
            cMB.CSBD_Estado__c = 'Cerrada';
            cMB.StageName = 'Formalizada';
            update cMB;
            Test.stopTest();

            System.Assert([SELECT Count() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: cMB.Id]>0, 'No se ha enviado ningún email');
        }
    }


    @isTest
    public static void agendarFirmaTest() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs ( usuarioGestor ) {
            Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
            Opportunity prestamo = crearOportunidadPrestamo(cuenta);
            prestamo.OwnerId = usuarioGestor.Id;
            update prestamo;
            datetime fecha = System.now();

            Test.startTest();
            Event nuevoEvento = CSBD_Opportunity.agendarFirma(prestamo.id, true, fecha);
            Opportunity prestamoActualizado = [SELECT Id, CSBD_Fecha_Firma__c, CSBD_Firma_segura__c from Opportunity where Id =:prestamo.id];
            System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, fecha, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, true, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals([SELECT Id FROM Event WHERE Id = :nuevoEvento.Id].isEmpty(), false, 'No se ha creado el evento correctamente');
            Test.stopTest();
        }
    }

      @isTest
    public static void cancelarFirmaTest() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs ( usuarioGestor ) {
            Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
            Opportunity prestamo = crearOportunidadPrestamo(cuenta);
            prestamo.OwnerId = usuarioGestor.Id;
            update prestamo;
            datetime fecha = System.now();

            Test.startTest();
            Event nuevoEvento1 = CSBD_Opportunity_Operativas_Controller.agendarFirmaApex(prestamo.id, true, fecha);
            Event nuevoEvento = CSBD_Opportunity.cancelarFirma(prestamo.id);
            Opportunity prestamoActualizado = [SELECT Id, CSBD_Fecha_Firma__c, CSBD_Firma_segura__c from Opportunity where Id =:prestamo.id];
            System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, null, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, false, 'No se ha actualizado la oportunidad correctamente');
            System.assertEquals([SELECT Id,CSBD_Evento_Estado__c FROM Event WHERE Id = :nuevoEvento.Id][0].CSBD_Evento_Estado__c, 'Cancelado', 'No se ha actualizado el evento correctamente');
            Test.stopTest();
        }
    }

    @isTest
    private static void convertirOportunidadTest() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

        System.runAs ( usuarioGestor ) {
            Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678Z'];
            Opportunity oportunidadFormalizada = crearOportunidadPrestamo(cuenta);

            Test.startTest();
            Opportunity oppTrasladada = CSBD_Opportunity.convertirOportunidad(oportunidadFormalizada, 'CSBD_Prestamo');
            Test.stopTest();

            oppTrasladada = [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :oppTrasladada.Id];

            System.assertEquals(oportunidadFormalizada.Id, oppTrasladada.CSBD_Parent_Id__c, 'No se cumple');
        }
    }
}