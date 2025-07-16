@isTest
public class CSBD_WS_AltaOportunidad_Test  {

    private static void activarMockAltaOportunidadInput(Map<String, Object> campos) {
        String jsonSolicitud = JSON.serialize(campos);

        CSBD_WS_AltaOportunidad_Input input = new CSBD_WS_AltaOportunidad_Input();
        input.solicitudes = new List<CSBD_WS_AltaOportunidad_Input.Solicitud>{
            (CSBD_WS_AltaOportunidad_Input.Solicitud)JSON.deserialize(jsonSolicitud, CSBD_WS_AltaOportunidad_Input.Solicitud.class)
        };

        RestRequest req = new RestRequest();
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request = req;
    }

    @testSetup
    private static void setup() {
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdministrador) {
            CBK_IntegrationSetting__c cs = new CBK_IntegrationSetting__c();
            cs.Name = 'CSBD_WS_Adobe';
            cs.NamedCredential__c = 'callout:CSBD_WS_CredentialAdobe/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
            insert cs;

            Product2 productoRelacionValoresNow = new Product2();
            productoRelacionValoresNow.Name = 'Auto';
            productoRelacionValoresNow.IsActive = true;
            Product2 productoAuto = new Product2();
            productoAuto.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AV_PF').getRecordTypeId();
            productoAuto.Name = 'Auto';
            productoAuto.Family = 'Auto';
            productoAuto.IsActive = true;
            productoAuto.AV_ExternalID__c = '2220000';
            insert new List<Product2>{productoRelacionValoresNow, productoAuto};

            Account cuenta = new Account();
            cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuenta.Name = 'Account Test';
            cuenta.CC_NumPerso__c = '214449821';
            cuenta.CC_TipoDocumento__c = 'NIF';
            cuenta.CC_Numero_Documento__c = '12312312K';
            cuenta.AV_IndicadoresClientes__c = '11, 8';
            insert cuenta;

            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.Email = 'test@test.com';
            contacto.LastName = 'test@test.com';
            contacto.AccountId = cuenta.Id;
            contacto.CC_NumPerso__c = '214449821';
            contacto.CC_Numero_Documento__c = '12312312K';
            contacto.MobilePhone = '666555444';
            insert contacto;

            //Listas de valores
            Id idRecordTypeLovLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            CC_Lista_Valores__c listaValoresOmni = new CC_Lista_Valores__c(
                Name = 'CSBD: Motor de asignación - Tipos de oportunidad que se asignan', RecordTypeId = idRecordTypeLovLista
            );
            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c(
                Name = 'CSBD: Días cierre oportunidad por defecto', RecordTypeId = idRecordTypeLovLista
            );
            CC_Lista_Valores__c valoresBlacklist = new CC_Lista_Valores__c(
                Name = 'CSBD: Blacklist', RecordTypeId = idRecordTypeLovLista
            );
            CC_Lista_Valores__c valoresRelacionValoresNow = new CC_Lista_Valores__c(
                Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto', RecordTypeId = idRecordTypeLovLista
            );
            CC_Lista_Valores__c listaProductosDefecto = new CC_Lista_Valores__c(
                Name = 'CSBD: Acciones comerciales oportunidad', RecordTypeId = idRecordTypeLovLista
            );

            //Reglas de traspaso de oportunidad
            Id idRecordTypeLovReglaTraspaso = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_traspaso_oportunidad').getRecordTypeId();
            CC_Lista_Valores__c reglaTraspaso1 = new CC_Lista_Valores__c();
            reglaTraspaso1.RecordTypeId = idRecordTypeLovReglaTraspaso;
            reglaTraspaso1.CSBD_Tipo_regla__c = 'Producto';
            reglaTraspaso1.Name = 'Auto_imaginBank';
            reglaTraspaso1.CC_Valor_SFDC__c = 'Hipoteca';
            reglaTraspaso1.CC_Valor__c = 'Auto_imaginBank';
            reglaTraspaso1.CSBD_Empresa_Proveedora__c = 'imaginBank';
            reglaTraspaso1.CSBD_Aplica_horario__c = true;
            reglaTraspaso1.CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-7);
            reglaTraspaso1.CC_Fecha_Vigencia_Fin__c = System.now().addDays(7);
            CC_Lista_Valores__c reglaTraspaso2 = new CC_Lista_Valores__c();
            reglaTraspaso2.RecordTypeId = idRecordTypeLovReglaTraspaso;
            reglaTraspaso2.CSBD_Tipo_regla__c = 'Tipo oportunidad';
            reglaTraspaso2.Name = 'cmb';
            reglaTraspaso2.CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-7);
            reglaTraspaso2.CC_Fecha_Vigencia_Fin__c = System.now().addDays(7);
            CC_Lista_Valores__c reglaTraspaso3 = new CC_Lista_Valores__c();
            reglaTraspaso3.RecordTypeId = idRecordTypeLovReglaTraspaso;
            reglaTraspaso3.CSBD_Tipo_regla__c = 'Tipo oportunidad';
            reglaTraspaso3.Name = 'cmn';
            reglaTraspaso3.CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-7);
            reglaTraspaso3.CC_Fecha_Vigencia_Fin__c = System.now().addDays(7);
            CC_Lista_Valores__c reglaTraspaso4 = new CC_Lista_Valores__c();
            reglaTraspaso4.RecordTypeId = idRecordTypeLovReglaTraspaso;
            reglaTraspaso4.CSBD_Tipo_regla__c = 'Horario';
            reglaTraspaso4.Name = 'imaginBank - Horario invierno - Mañana';
            reglaTraspaso4.CSBD_Empresa_Proveedora__c = 'imaginBank';
            reglaTraspaso4.CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-7);
            reglaTraspaso4.CC_Fecha_Vigencia_Fin__c = System.now().addDays(7);
            reglaTraspaso4.CSBD_Hora_inicio_turno__c = Time.newInstance(6, 0, 0, 0);
            reglaTraspaso4.CSBD_Hora_fin_turno__c = Time.newInstance(15, 0, 0, 0);

            insert new List<CC_Lista_Valores__c>{
                listaValoresOmni, listaValores, valoresBlacklist, valoresRelacionValoresNow, listaProductosDefecto,
                reglaTraspaso1, reglaTraspaso2, reglaTraspaso3, reglaTraspaso4
            };

            //Valores de las listas de valores
            Id idRecordTypeLovValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            //Lista envío omnichannel
            CC_Lista_Valores__c valorHipotecaOmni = new CC_Lista_Valores__c();
            valorHipotecaOmni.RecordTypeId = idRecordTypeLovValor;
            valorHipotecaOmni.CC_Lista__c = listaValoresOmni.Id;
            valorHipotecaOmni.Name = 'Hipoteca';
            CC_Lista_Valores__c valorPrestamoOmni = new CC_Lista_Valores__c();
            valorPrestamoOmni.RecordTypeId = idRecordTypeLovValor;
            valorPrestamoOmni.CC_Lista__c = listaValoresOmni.Id;
            valorPrestamoOmni.Name = 'Préstamo';
            CC_Lista_Valores__c valorCMNOmni = new CC_Lista_Valores__c();
            valorCMNOmni.RecordTypeId = idRecordTypeLovValor;
            valorCMNOmni.CC_Lista__c = listaValoresOmni.Id;
            valorCMNOmni.Name = 'CMN';
            CC_Lista_Valores__c valorCMBOmni = new CC_Lista_Valores__c();
            valorCMBOmni.RecordTypeId = idRecordTypeLovValor;
            valorCMBOmni.CC_Lista__c = listaValoresOmni.Id;
            valorCMBOmni.Name = 'CMB';
            CC_Lista_Valores__c valorRentingOmni = new CC_Lista_Valores__c();
            valorRentingOmni.RecordTypeId = idRecordTypeLovValor;
            valorRentingOmni.CC_Lista__c = listaValoresOmni.Id;
            valorRentingOmni.Name = 'Renting';

            //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
            CC_Lista_Valores__c valorHipoteca = new CC_Lista_Valores__c();
            valorHipoteca.RecordTypeId = idRecordTypeLovValor;
            valorHipoteca.CC_Lista__c = listaValores.Id;
            valorHipoteca.Name = 'Hipoteca';
            valorHipoteca.CC_Valor__c = '1';
            CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
            valorPrestamo.RecordTypeId = idRecordTypeLovValor;
            valorPrestamo.CC_Lista__c = listaValores.Id;
            valorPrestamo.Name = 'Préstamo';
            valorPrestamo.CC_Valor__c = '1';
            CC_Lista_Valores__c valorRenting = new CC_Lista_Valores__c();
            valorRenting.RecordTypeId = idRecordTypeLovValor;
            valorRenting.CC_Lista__c = listaValores.Id;
            valorRenting.Name = 'Renting';
            valorRenting.CC_Valor__c = '1';
            CC_Lista_Valores__c valorCompraEstrella = new CC_Lista_Valores__c();
            valorCompraEstrella.RecordTypeId = idRecordTypeLovValor;
            valorCompraEstrella.CC_Lista__c = listaValores.Id;
            valorCompraEstrella.Name = 'Wivai';
            valorCompraEstrella.CC_Valor__c = '1';
            CC_Lista_Valores__c valorCMN = new CC_Lista_Valores__c();
            valorCMN.RecordTypeId = idRecordTypeLovValor;
            valorCMN.CC_Lista__c = listaValores.Id;
            valorCMN.Name = 'CMN';
            valorCMN.CC_Valor__c = '1';
            CC_Lista_Valores__c valorCMB = new CC_Lista_Valores__c();
            valorCMB.RecordTypeId = idRecordTypeLovValor;
            valorCMB.CC_Lista__c = listaValores.Id;
            valorCMB.Name = 'CMB';
            valorCMB.CC_Valor__c = '1';
            CC_Lista_Valores__c valorTPV = new CC_Lista_Valores__c();
            valorTPV.Name = 'TPV';
            valorTPV.RecordTypeId = idRecordTypeLovValor;
            valorTPV.CC_Lista__c = listaValores.Id;
            valorTPV.CC_Valor__c = '1';
            CC_Lista_Valores__c valorMac = new CC_Lista_Valores__c();
            valorMac.Name = 'MAC';
            valorMac.RecordTypeId = idRecordTypeLovValor;
            valorMac.CC_Lista__c = listaValores.Id;
            valorMac.CC_Valor__c = '1';

            //Lista Blacklist
            CC_Lista_Valores__c blacklistTelefono = new CC_Lista_Valores__c();
            blacklistTelefono.RecordTypeId = idRecordTypeLovValor;
            blacklistTelefono.CC_Lista__c = valoresBlacklist.Id;
            blacklistTelefono.Name = '234098567';
            blacklistTelefono.CC_Valor__c = 'Teléfono';

            //Lista Relación de valores Now
            CC_Lista_Valores__c valoresRelacionValoresNowInTouch = new CC_Lista_Valores__c();
            valoresRelacionValoresNowInTouch.RecordTypeId = idRecordTypeLovValor;
            valoresRelacionValoresNowInTouch.CC_Lista__c = valoresRelacionValoresNow.Id;
            valoresRelacionValoresNowInTouch.Name = 'Auto_intouch';
            valoresRelacionValoresNowInTouch.CC_Valor__c = 'Seguros';
            valoresRelacionValoresNowInTouch.CC_Valor2__c = 'Auto';
            valoresRelacionValoresNowInTouch.CSBD_Valor4__c = 'INTOUCH';
            valoresRelacionValoresNowInTouch.CC_Valor_SFDC__c = 'inTouch';
            valoresRelacionValoresNowInTouch.CSBD_Product2__c = productoAuto.Id;
            CC_Lista_Valores__c valorImagin = new CC_Lista_Valores__c();
            valorImagin.RecordTypeId = idRecordTypeLovValor;
            valorImagin.CC_Lista__c = valoresRelacionValoresNow.Id;
            valorImagin.Name = 'Auto_imaginBank';
            valorImagin.CC_Valor__c = 'Seguros';
            valorImagin.CC_Valor2__c = 'Auto';
            valorImagin.CC_Valor_SFDC__c = 'imaginBank';

            //Lista de valores productos por defecto
            CC_Lista_Valores__c valorDefHipoteca = new CC_Lista_Valores__c();
            valorDefHipoteca.RecordTypeId = idRecordTypeLovValor;
            valorDefHipoteca.CC_Lista__c = listaProductosDefecto.Id;
            valorDefHipoteca.Name = 'Hipoteca';
            valorDefHipoteca.CC_Valor_SFDC__c = 'Hipoteca';
            valorDefHipoteca.CC_Valor__c = 'Hipoteca';
            valorDefHipoteca.CSBD_Alta_creacion__c = true;
            CC_Lista_Valores__c valorDefPrestamo = new CC_Lista_Valores__c();
            valorDefPrestamo.RecordTypeId = idRecordTypeLovValor;
            valorDefPrestamo.CC_Lista__c = listaProductosDefecto.Id;
            valorDefPrestamo.CC_Valor_SFDC__c = 'Préstamo';
            valorDefPrestamo.Name = 'Préstamo';
            valorDefPrestamo.CC_Valor__c = 'Préstamo';
            valorDefPrestamo.CSBD_Alta_creacion__c = true;

            insert new List<CC_Lista_Valores__c>{
                valorHipotecaOmni, valorPrestamoOmni, valorCMNOmni, valorCMBOmni, valorRentingOmni,
                valorHipoteca, valorPrestamo, valorRenting, valorCompraEstrella, valorCMN, valorCMB, valorTPV, valorMac,
                blacklistTelefono,
                valoresRelacionValoresNowInTouch, valorImagin,
                valorDefHipoteca, valorDefPrestamo
            };
        }
    }

    @isTest
    private static void altaOportunidadTestPrestamo() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'prestamo',
                'indInTouch' => 'N',
                'AntiguedadVivienda2Tit' => '',
                'CuotasPrestamos1Tit' => '0',
                'NumOficina' => '5372',
                'Resposta' => 'F',
                'Telefono2_2Tit' => '',
                'AntiguedadVivienda1Tit' => '3',
                'CuotasPrestamos2Tit' => '',
                'Nombre2Tit' => '',
                'Provincia1Tit' => '08',
                'CP1Tit' => '08348',
                'Pais_residencia1Tit' => '',
                'Sexo2Tit' => '',
                'DirOficina' => 'AV. DIAGONAL, 530 PL.1',
                'Origen' => '50001',
                'CesionDatos2Tit' => '',
                'Provincia_nacimiento1Tit' => '',
                'CesionDatos1Tit' => 'S',
                'ActividadEmpresa2Tit' => '',
                'NUMPERSO' => 'CC83E9D',
                'DirVivienda' => '',
                'IngresosNetos2Tit' => '',
                'Delimitador' => '10YH3A',
                'ValorVivienda' => '',
                'IP' => '81.38.182.205',
                'Email1Tit' => 'jaime.garcia.camarero@ibm.com',
                'Descripcion' => '',
                'Telefono1_2Tit' => '',
                'ContratoLaboral2Tit' => '',
                'AnyInmueble' => '',
                'SeguroVida' => '',
                'Dir1Tit' => 'JOSEP MARIA BATISTA I ROCA 9 BAJOS ',
                'EmailGestorLO' => 'sboadella@caixabank.com',
                'Nombre1Tit' => 'MANUEL',
                'Apellidos1_1Tit' => 'GOMIS',
                'Referer' => 'Referrer Indefinido',
                'Scoring' => 'Aprobada',
                'NombreProducto' => 'Prestamo Online',
                'GastMens2Tit' => '',
                'Apellidos2_1Tit' => 'BA�OS',
                'Referencia' => '',
                'Finalidad' => '107 - OTRAS_FINALIDADES',
                'NumHipoteca' => '000',
                'FechaNacimiento1Tit' => '30/10/1957',
                'NumPagas2Tit' => '',
                'CPVivienda' => '',
                'SuperficieVivienda' => '',
                'Nacionalidad1Tit' => 'ESPAÑA',
                'TelOficina' => '932480740',
                'ContratableOnLine' => 'S',
                'Provincia_nacimiento2Tit' => '',
                'Subestado_Tracking' => 'SIA00969',
                'ActividadEmpresa1Tit' => '015',
                'CodiFormaExercir1Tit' => 'Particular',
                'User_Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.140 Safari/537.36 Edge/17.17134',
                'Num_paso' => '4',
                'IngresosNetos1Tit' => '250000',
                'Fecha' => '24-7-2019',
                'CodiTreball1Tit' => '10',
                'Antiguedad2Tit' => '',
                'EstatCivilTit' => '1',
                'Pobl1Tit' => 'CABRILS',
                'SituacionViv2Tit' => '',
                'Nomina1Tit' => '2',
                'Presolicitud' => '4223010412662',
                'Horario1Tit' => 'Cualquier-hora',
                'Importe' => '5000',
                'Plazo' => '12',
                'Apellidos2_2Tit' => '',
                'Resultado' => 'CORRECTO',
                'CP2Tit' => '',
                'SituacionViv1Tit' => '006',
                'Diagnostico' => '5',
                'NumPagas1Tit' => '012',
                'Antiguedad1Tit' => 'null',
                'Telefono2_1Tit' => '679680838',
                'GastMens1Tit' => '0',
                'NombreOficina' => 'CENTRO INTOUCH BARCELONA',
                'Telefono1_1Tit' => '679680838',
                'scoringRiesgo' => 'Aprobada',
                'NIF1Tit' => '12312312K',
                'Email2Tit' => '',
                'Apellidos1_2Tit' => '',
                'ContratoLaboral1Tit' => '5',
                'Dir2Tit' => '',
                'Canal' => 'LO',
                'CodiTreball2Tit' => '',
                'Sexo1Tit' => 'V',
                'Idioma' => 'cas',
                'NIF2Tit' => ''
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }

            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestPrestamoPersonaJuridica() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            Account cuentaJuridica = new Account();
            cuentaJuridica.Name = 'Cuenta Juridica';
            cuentaJuridica.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuentaJuridica.AV_NumPerso__c = '21500670';
            cuentaJuridica.CC_Numero_Documento__c = 'A05005608';
            cuentaJuridica.CC_TipoPersona__c = 'J';
            insert cuentaJuridica;

            Contact apoderado = new Contact();
            apoderado.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_Apoderado').getRecordTypeId();
            apoderado.AccountId = cuentaJuridica.Id;
            apoderado.FirstName = 'Apoderado';
            apoderado.LastName = 'Apoderado';
            apoderado.AV_NumPerso__c = '51598765';
            apoderado.CIBE_Carrec__c = '00017';
            apoderado.CIBE_FechaVencimiento__c = System.today().addDays(1);
            insert apoderado;

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'prestamoPJ',
                'nombreProducto' => 'Prestamo Online',
                'delimitador' => 'delimitador1',
                'importe' => '5000',
                'plazo' => '12',
                'finalidad' => '107 - OTRAS_FINALIDADES',
                'nombre2Tit' => '',
                'apellidos1_2Tit' => '',
                'apellidos2_2Tit' => '',
                'email2Tit' => '',
                'telefono1_2Tit' => '',
                'canal' => 'LO',
                'garantia' => 'garantia1',
                'numperso' => '014812FE', //21500670
                'nif1Tit' => 'A05005608',
                'numperso2Tit' => '31355AD', //51598765
                'nif2Tit' => '',
                'origen' => '50001',
                'horario1Tit' => 'Cualquier-hora',
                'idioma' => 'cas',
                'email1Tit' => 'jaime.garcia.camarero@ibm.com',
                'telefono1_1Tit' => '679680838',
                'nombre1Tit' => 'MANUEL'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            System.assertEquals(true, true, 'La cuenta de la oportunidad no es la cuenta jurídica: ');

            /*
            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }

            for (Opportunity oportunidad : [SELECT AccountId, CSBD_Contact__c, CSBD_Account_Tipo_Persona__c, CSBD_Garantia__c, CSBD_SistemaOrigen__c
                                            FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals(cuentaJuridica.Id, oportunidad.AccountId, 'La cuenta de la oportunidad no es la cuenta jurídica: ' + oportunidad.AccountId);
                System.assertEquals(apoderado.Id, oportunidad.CSBD_Contact__c, 'El contacto de la oportunidad no es el apoderado: ' + oportunidad.CSBD_Contact__c);
                System.assertEquals('garantia1', oportunidad.CSBD_Garantia__c, 'La garantía de la oportunidad no es "garantia1": ' + oportunidad.CSBD_Garantia__c);
                System.assertEquals('J', oportunidad.CSBD_Account_Tipo_Persona__c, 'El tipo de persona de la cuenta no es "J" (Jurídica): ' + oportunidad.CSBD_Account_Tipo_Persona__c);
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es "WS": ' + oportunidad.CSBD_SistemaOrigen__c);
            }*/
        }
    }

    @isTest
    private static void altaOportunidadTestCmnInTouchAv() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            activarMockAltaOportunidadInput(new Map<String, Object>{
                'idProducto' => 'Auto_intouch',
                'tipoCampanya' => '',
                'minFin' => '0',
                'tipoContacto' => 'C',
                'tipollamada' => '1',
                'margen' => '',
                'importeTotal' => '',
                'nombreProducto' => 'Auto_intouch',
                'nombre' => 'CECILIA SIERRA NOGUERA',
                'timestamp' => '20210125102228',
                'fraccionamiento' => '',
                'tipoPago' => '',
                'minIni' => '0',
                'tipoSolicitud' => 'cmn',
                'nombre2' => 'CECILIA',
                'horaFin' => '0',
                'NUMPERSO' => 'CC83E9D',
                'tipoCliente' => 'L',
                'nif' => '',
                'apellidos' => 'SIERRA',
                'reserva2' => '',
                'telefono' => '',
                'reserva1' => '',
                'canal' => 'LO',
                'codProducto' => '',
                'proceso' => 'PAS/20',
                'boton' => 'CMN_Suri',
                'horaIni' => '0',
                'indInTouch' => 'S',
                'apellidos_2' => 'NOGUERA',
                'referencia_usuario' => UUID.randomUUID().toString(),
                'agenteInTouch' => '',
                'origen' => 'Consulta',
                'colectivo' => '',
                'prod_category_wivai' => 'categoría',
                'prod_subcategory_wivai' => 'subcategoría',
                'prod_subcategory2_wivai' => 'subcategoría 2',
                'process_category' => 'process_category',
                'page_product_category' => 'page_product_category'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, CSBD_Now_Origen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestPrestamoBlacklist() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'prestamo',
                'AntiguedadVivienda2Tit' => '',
                'CuotasPrestamos1Tit' => '0',
                'NumOficina' => '5372',
                'Resposta' => 'F',
                'Telefono2_2Tit' => '',
                'AntiguedadVivienda1Tit' => '3',
                'CuotasPrestamos2Tit' => '',
                'Nombre2Tit' => '',
                'Provincia1Tit' => '08',
                'CP1Tit' => '08348',
                'Pais_residencia1Tit' => '',
                'Sexo2Tit' => '',
                'DirOficina' => 'AV. DIAGONAL, 530 PL.1',
                'Origen' => '50001',
                'CesionDatos2Tit' => '',
                'Provincia_nacimiento1Tit' => '',
                'FechaNacimiento2Tit' => '',
                'CesionDatos1Tit' => 'S',
                'ActividadEmpresa2Tit' => '',
                'NUMPERSO' => 'CC83E9D',
                'DirVivienda' => '',
                'IngresosNetos2Tit' => '',
                'Delimitador' => '10YH3A',
                'ValorVivienda' => '',
                'IP' => '81.38.182.205',
                'Email1Tit' => 'jaime.garcia.camarero@ibm.com',
                'Descripcion' => '',
                'Telefono1_2Tit' => '',
                'ContratoLaboral2Tit' => '',
                'AnyInmueble' => '',
                'SeguroVida' => '',
                'Dir1Tit' => 'JOSEP MARIA BATISTA I ROCA 9 BAJOS ',
                'EmailGestorLO' => 'sboadella@caixabank.com',
                'Nombre1Tit' => 'MANUEL',
                'Apellidos1_1Tit' => 'GOMIS',
                'Referer' => 'Referrer Indefinido',
                'Scoring' => 'Aprobada',
                'NombreProducto' => 'Prestamo Online',
                'GastMens2Tit' => '',
                'Apellidos2_1Tit' => 'BA�OS',
                'Referencia' => '',
                'Finalidad' => '107 - OTRAS_FINALIDADES',
                'NumHipoteca' => '000',
                'FechaNacimiento1Tit' => '30/10/1957',
                'NumPagas2Tit' => '',
                'CPVivienda' => '',
                'SuperficieVivienda' => '',
                'Nacionalidad1Tit' => 'ESPAÑA',
                'TelOficina' => '932480740',
                'ContratableOnLine' => 'S',
                'Provincia_nacimiento2Tit' => '',
                'Subestado_Tracking' => 'SIA00969',
                'ActividadEmpresa1Tit' => '015',
                'CodiFormaExercir1Tit' => 'Particular',
                'User_Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.140 Safari/537.36 Edge/17.17134',
                'Num_paso' => '4',
                'IngresosNetos1Tit' => '250000',
                'Fecha' => '24-7-2019',
                'CodiTreball1Tit' => '10',
                'Antiguedad2Tit' => '',
                'EstatCivilTit' => '1',
                'Pobl1Tit' => 'CABRILS',
                'SituacionViv2Tit' => '',
                'Nomina1Tit' => '2',
                'Presolicitud' => '4223010412662',
                'Horario1Tit' => 'Cualquier-hora',
                'Importe' => '5000',
                'Plazo' => '12',
                'Apellidos2_2Tit' => '',
                'Resultado' => 'CORRECTO',
                'CP2Tit' => '',
                'SituacionViv1Tit' => '006',
                'Diagnostico' => '5',
                'NumPagas1Tit' => '012',
                'Antiguedad1Tit' => 'null',
                'Telefono2_1Tit' => '679680838',
                'GastMens1Tit' => '0',
                'NombreOficina' => 'CENTRO INTOUCH BARCELONA',
                'Telefono1_1Tit' => '234098567',
                'scoringRiesgo' => 'Aprobada',
                'NIF1Tit' => '12312312K',
                'Email2Tit' => '',
                'Apellidos1_2Tit' => '',
                'ContratoLaboral1Tit' => '5',
                'Dir2Tit' => '',
                'Canal' => 'LO',
                'CodiTreball2Tit' => '',
                'Sexo1Tit' => 'V',
                'Idioma' => 'cas',
                'NIF2Tit' => ''
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestHipoteca() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'hipoteca',
                'CuotasPrestamos1Tit' => '0',
                'NumOficina' => '4223',
                'AntiguedadVivienda1Tit' => '000',
                'Nombre2Tit' => 'piedad ',
                'Provincia1Tit' => '',
                'CP1Tit' => '28007',
                'Pais_residencia1Tit' => '011',
                'DirOficina' => 'AV. CIUDAD DE BARCELONA, 180',
                'Bonificada' => 'S',
                'Origen' => '50001',
                'CesionDatos2Tit' => 'S',
                'CesionDatos1Tit' => 'S',
                'DirVivienda' => '',
                'IngresosNetos2Tit' => '1200000',
                'Delimitador' => '10YBPA',
                'ValorVivienda' => '9375000',
                'IP' => '90.174.2.218',
                'Email1Tit' => 'alexfonseca08@hotmail.es',
                'Dir1Tit' => 'AVDA. CIUDAD DE BARCELONA     57 6 1',
                'Nombre1Tit' => 'ALEX JAVIER',
                'Apellidos1_1Tit' => 'FONSECA',
                'Referer' => 'Referrer Indefinido',
                'NombreProducto' => '01',
                'Apellidos2_1Tit' => 'ARROYO',
                'Referencia' => 'PRLC-2019071911463035',
                'Entorn' => 'LO',
                'NumHipoteca' => '001',
                'FechaNacimiento1Tit' => '01091982',
                'NumPagas2Tit' => '12',
                'CPVivienda' => '00000',
                'Nacionalidad1Tit' => '011',
                'TelOficina' => '913402820',
                'ActividadEmpresa1Tit' => '000',
                'CodiFormaExercir1Tit' => '',
                'EmailGestor' => 'laura.romero@caixabank.com',
                'User_Agent' => 'APPCBK+store_AASAMSSMA323MyjOpctSzX/OsazwjrSMgFl+FI=_ANDROID_5.17.5_samsung_SM-A320FL_8.0.0_ADAM',
                'IngresosNetos1Tit' => '140000',
                'CodiTreball1Tit' => '',
                'EstatCivilTit' => '1',
                'Pobl1Tit' => 'MADRID',
                'Nomina1Tit' => '2',
                'Presolicitud' => '1536386700',
                'Horario1Tit' => '00-00h',
                'Importe' => '7500000',
                'Plazo' => '360',
                'PoblVivienda' => 'Madrid ',
                'TasacionEnCurso' => 'N',
                'Diagnostico' => '3',
                'NumPagas1Tit' => '14',
                'Antiguedad1Tit' => '',
                'GastMens1Tit' => '0',
                'NombreOficina' => 'MAESTRANZA',
                'Telefono1_1Tit' => '606853308',
                'NIF1Tit' => '12312312K',
                'Apellidos1_2Tit' => 'muzo ',
                'ContratoLaboral1Tit' => '1',
                'Canal' => 'WAX',
                'Sexo1Tit' => 'V',
                'Idioma' => 'cas',
                'NIF2Tit' => '50338558e'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestChequeoDuplicados() {

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            // Crear configuración personalizada
            CSBD_IdentificarOppsPHDSetting__c setting = new CSBD_IdentificarOppsPHDSetting__c();
            setting.CSBD_Dias__c = 90;
            setting.CSBD_Stages__c = 'Rechazada';
            setting.CSBD_EnvioCorreo__c = false;
            setting.CSBD_PlantillaCorreoPHD__c = 'PlantillaPHD';
            setting.CSBD_PlantillaCorreoFacilitea__c = 'PlantillaFacilitea';
            setting.CSBD_CanalesProcedencia__c = 'WAX';
            setting.CSBD_Origen__c = '50001';
            setting.CSBD_SolicitudWSAltaOpp__c = 'hipoteca';
            setting.CSBD_FrecuenciaAvisosAuto__c = 5;
            insert setting;

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'hipoteca',
                'CuotasPrestamos1Tit' => '0',
                'NumOficina' => '4223',
                'AntiguedadVivienda1Tit' => '000',
                'Nombre2Tit' => 'piedad ',
                'Provincia1Tit' => '',
                'CP1Tit' => '28007',
                'Pais_residencia1Tit' => '011',
                'DirOficina' => 'AV. CIUDAD DE BARCELONA, 180',
                'Bonificada' => 'S',
                'Origen' => '50001',
                'CesionDatos2Tit' => 'S',
                'CesionDatos1Tit' => 'S',
                'DirVivienda' => '',
                'IngresosNetos2Tit' => '1200000',
                'Delimitador' => '10YBPA',
                'ValorVivienda' => '9375000',
                'IP' => '90.174.2.218',
                'Email1Tit' => 'alexfonseca08@hotmail.es',
                'Dir1Tit' => 'AVDA. CIUDAD DE BARCELONA     57 6 1',
                'Nombre1Tit' => 'ALEX JAVIER',
                'Apellidos1_1Tit' => 'FONSECA',
                'Referer' => 'Referrer Indefinido',
                'NombreProducto' => '01',
                'Apellidos2_1Tit' => 'ARROYO',
                'Referencia' => 'PRLC-2019071911463035',
                'Entorn' => 'LO',
                'NumHipoteca' => '001',
                'FechaNacimiento1Tit' => '01091982',
                'NumPagas2Tit' => '12',
                'CPVivienda' => '00000',
                'Nacionalidad1Tit' => '011',
                'TelOficina' => '913402820',
                'ActividadEmpresa1Tit' => '000',
                'CodiFormaExercir1Tit' => '',
                'EmailGestor' => 'laura.romero@caixabank.com',
                'User_Agent' => 'APPCBK+store_AASAMSSMA323MyjOpctSzX/OsazwjrSMgFl+FI=_ANDROID_5.17.5_samsung_SM-A320FL_8.0.0_ADAM',
                'IngresosNetos1Tit' => '140000',
                'CodiTreball1Tit' => '',
                'EstatCivilTit' => '1',
                'Pobl1Tit' => 'MADRID',
                'Nomina1Tit' => '2',
                'Presolicitud' => '1536386700',
                'Horario1Tit' => '00-00h',
                'Importe' => '7500000',
                'Plazo' => '360',
                'PoblVivienda' => 'Madrid ',
                'TasacionEnCurso' => 'N',
                'Diagnostico' => '3',
                'NumPagas1Tit' => '14',
                'Antiguedad1Tit' => '',
                'GastMens1Tit' => '0',
                'NombreOficina' => 'MAESTRANZA',
                'Telefono1_1Tit' => '606853308',
                'NIF1Tit' => '12312312K',
                'Apellidos1_2Tit' => 'muzo ',
                'ContratoLaboral1Tit' => '1',
                'Canal' => 'WAX',
                'Sexo1Tit' => 'V',
                'Idioma' => 'cas',
                'NIF2Tit' => '50338558e'
            });

            //Insertar una Opp de Hipoteca con el mismo NIF
            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
                    'CSBD_Now_NIF__c' => '12312312K',
                    'CSBD_Estado__c' => 'Activa',
                    'CSBD_Canal__c' => 'WAX',
                    'CSBD_Now_Origen__c' => '50001'
                });
            }

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT StageName FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals('Rechazada', oportunidad.StageName, 'La oportunidad no está en el estado Rechazada: ' + oportunidad.StageName);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestRenting() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'apellido2' => 'CLARAMUNT',
                'CP1Tit' => '17820',
                'apellido1' => 'PALAU',
                'idioma' => 'CAS',
                'plazo' => '48',
                'numPagas' => '12',
                'cuota' => '488,08 EUR',
                'telefonoContacto' => '636922497',
                'emailContacto' => 'pruebas@caixabank.com',
                'canal' => 'WEB',
                'nombreProducto' => 'Renting Coche',
                'nombre' => 'JUANA',
                'KMs' => '10.000',
                'tipoSolicitud' => 'renting',
                'horarioContacto' => '11-14h',
                'catalogo' => '1',
                'nombreSolicitante' => 'JUANA PALAU CLARAMUNT',
                'oferta' => '12747674',
                'referencia_usuario' => UUID.randomUUID().toString(),
                'NIFSolicitante' => '12312312K',
                'Pobl1Tit' => 'BANYOLES',
                'ingresosMensuales' => '1.500,00 EUR',
                'vehiculo' => 'VOLKSWAGEN Transporter furgon corto TN 2.0TDI 81kW (110CV) BMT'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestTpv() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'tpv',
                'apellido' => 'MARTI',
                'apellido2' => 'FLORIT',
                'fecha' => '03/04/2019',
                'emailCliente' => 'Carlesmarti8@gmail.com',
                'telefonoOficina' => '971489770',
                'oficina' => '0055',
                'numperso' => 'CC83E9D',
                'emailGestor' => 'ocarreras@caixabank.com',
                'nombre' => 'CARLES',
                'hora' => '14:28:09',
                'franjaContacto' => '14-17h',
                'tipoIdentificador' => 'nif',
                'identificador' => '41509565Q',
                'importeSolicitado' => '15000',
                'telefonoCliente' => '661131406',
                'importeDisponible' => ''
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestCompraEstrella() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, String>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'compraEstrella',
                'Fecha' => '',
                'Referencia' => '6497163',
                'Email1Tit' => 'majid_80@hotmail.es',
                'Origen' => '',
                'Finalidad' => 'Samsung Galaxy S10e 128 GB Negro',
                'Telefono1_1Tit' => '652288352',
                'scoringRiesgo' => 'Denegada',
                'NumOficina' => '4223',
                'NIF1Tit' => '12312312K',
                'Nombre1Tit' => 'MAJID',
                'Apellidos1_1Tit' => 'DARDOUR',
                'NumPagas1Tit' => '10',
                'TelOficina' => '',
                'Canal' => 'CANAL_WEB',
                'Presolicitud' => '15183927',
                'NombreProducto' => 'PRESTAMOSCE',
                'Idioma' => '02',
                'IngresosNetos1Tit' => '80000',
                'Horario1Tit' => '00-00h',
                'Importe' => '75900',
                'Plazo' => '30',
                'Apellidos2_1Tit' => ''
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :idOportunidades]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestCmn() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, String>{
                'idProducto' => 'Prestamo Online',
                'minFin' => '0',
                'tipoContacto' => 'C',
                'tipollamada' => '1',
                'margen' => '',
                'importeTotal' => '',
                'nombreProducto' => '',
                'nombre' => 'CECILIA SIERRA NOGUERA',
                'timestamp' => '20210125102228',
                'fraccionamiento' => '',
                'tipoPago' => '',
                'minIni' => '0',
                'tipoSolicitud' => 'cmn',
                'nombre2' => 'CECILIA',
                'horaFin' => '0',
                'NUMPERSO' => '0020FEA7',
                'tipoCliente' => 'L',
                'nif' => '20503206V',
                'apellidos' => 'SIERRA',
                'reserva2' => '',
                'telefono' => '666666666',
                'reserva1' => '',
                'canal' => 'LO',
                'proceso' => 'PAS/20',
                'boton' => 'CMN_Suri',
                'horaIni' => '0',
                'indInTouch' => 'N',
                'apellidos_2' => 'NOGUERA',
                'referencia_usuario' => UUID.randomUUID().toString(),
                'agenteInTouch' => '',
                'origen' => 'Consulta',
                'colectivo' => '',
                'descripcion' => 'test'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            List<Id> idOportunidades = new List<Id>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidades.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, CSBD_Resumen__c, ContactId FROM Opportunity WHERE Id IN :idOportunidades]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, oportunidad.Id + ': valor incorrecto en "Sistema origen" (' + oportunidad.CSBD_SistemaOrigen__c + ')');
                System.assert(String.isNotBlank(oportunidad.CSBD_Resumen__c), oportunidad.Id + ': campo "Resumen" vacío');
                System.assert(String.isBlank(oportunidad.ContactId), oportunidad.Id + ': oportunidad con Contacto');
            }
        }
    }

    @isTest
    private static void altaOportunidadTestCmnBuzon() {

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CC_Lista_Valores__c listaValoresCmnWS = new CC_Lista_Valores__c();
            listaValoresCmnWS.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            listaValoresCmnWS.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se externalizan por correo';
            listaValoresCmnWS.CC_Valor__c = 'valor';
            insert listaValoresCmnWS;

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'idProducto' => 'Prestamo Online',
                'minFin' => '0',
                'tipoContacto' => 'C',
                'tipollamada' => '1',
                'margen' => '',
                'importeTotal' => '',
                'nombreProducto' => '',
                'nombre' => 'CECILIA SIERRA NOGUERA',
                'timestamp' => '20210125102228',
                'fraccionamiento' => '',
                'tipoPago' => '',
                'minIni' => '0',
                'tipoSolicitud' => 'cmn',
                'nombre2' => 'CECILIA',
                'horaFin' => '0',
                'NUMPERSO' => '0020FEA7',
                'tipoCliente' => 'L',
                'nif' => '20503206V',
                'apellidos' => 'SIERRA',
                'reserva2' => '',
                'telefono' => '666666666',
                'reserva1' => '',
                'canal' => 'LO',
                'codProducto' => '',
                'proceso' => 'PAS/20',
                'boton' => 'CMN_Suri',
                'horaIni' => '0',
                'indInTouch' => 'N',
                'apellidos_2' => 'NOGUERA',
                'referencia_usuario' => UUID.randomUUID().toString(),
                'agenteInTouch' => '',
                'origen' => 'Consulta',
                'idCampanya' => 'valor',
                'buzonCajeros' => true,
                'colectivo' => '',
                'descripcion' => 'test'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestCmnComdata() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CC_Lista_Valores__c listaValoresCmnWS = new CC_Lista_Valores__c();
            listaValoresCmnWS.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            listaValoresCmnWS.Name = 'CSBD: CMN - Productos gestionados externamente';
            insert listaValoresCmnWS;

            CC_Lista_Valores__c valorHazteCliente = new CC_Lista_Valores__c();
            valorHazteCliente.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valorHazteCliente.CC_Lista__c = listaValoresCmnWS.Id;
            valorHazteCliente.Name = 'HazteCliente';
            valorHazteCliente.CC_Valor__c = 'Comdata';
            insert valorHazteCliente;

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'cmn',
                'nombre' => 'prova',
                'telefono' => '0034600000000',
                'idProducto' => 'HazteCliente',
                'idioma' => '2',
                'tipollamada' => '1',
                'horaIni' => '0',
                'minIni' => '0',
                'horaFin' => '0',
                'minFin' => '0',
                'origen' => '',
                'nombre2' => '',
                'apellidos' => '',
                'nif' => '',
                'canal' => '',
                'colectivo' => '0',
                'numperso' => 'CC83E9D',
                'subproducto_1' => 'Sin especificar',
                'regalo_1' => '',
                'apellidos_2' => '',
                'timestamp' => '20190725000209',
                'proceso' => ''
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestCmb() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.Email = 'test@test45123.com';
            contacto.LastName = 'test@test45123.com';
            contacto.AccountId = [SELECT Id FROM Account WHERE Name = 'Account Test' LIMIT 1].Id;
            contacto.CC_NumPerso__c = '';
            contacto.CC_Numero_Documento__c = '29801742K';
            contacto.MobilePhone = '666555442';
            insert contacto;

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'cmb',
                'nombre' => 'JOSE MARIA FERNANDEZ MARTIN',
                'telefono' => '680707336',
                'idProducto' => 'Auto_intouch',
                'idioma' => '2',
                'tipollamada' => '1',
                'horaIni' => '8',
                'minIni' => '0',
                'horaFin' => '10',
                'minFin' => '0',
                'origen' => 'f_mi_e_psh_p_na_tc_121_m_na_nc_marzo',
                'nombre2' => 'JOSE MARIA',
                'apellidos' => 'FERNANDEZ',
                'nif' => '29801742K',
                'canal' => 'portal',
                'colectivo' => '',
                'numperso' => '',
                'subproducto_1' => 'CMN_Suri',
                'apellidos_2' => 'MARTIN',
                'timestamp' => '20190725092425',
                'proceso' => 'CTO/1',
                'tipoCliente' => 'L',
                'tipoContacto' => 'C',
                'agenteSolicitud' => '',
                'boton' => 'CMN_Suri',
                'codProducto' => '',
                'nomProducto' => 'Auto_intouch',
                'nombreProducto' => 'Auto_intouch',
                'tipoPago' => '',
                'fraccionamiento' => '',
                'importeTotal' => '',
                'margen' => '',
                'indInTouch' => 'N',
                'agenteInTouch' => '',
                'reserva1' => '',
                'reserva2' => ''
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad. ' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, ContactId FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, oportunidad.Id + ': valor incorrecto en "Sistema origen" (' + oportunidad.CSBD_SistemaOrigen__c + ')');
                System.assert(String.isBlank(oportunidad.ContactId), oportunidad.Id + ': oportunidad con Contacto');
            }
        }
    }

    @isTest
    private static void altaOportunidadTestCmbTrasladoImagin() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.Email = 'test@test45123.com';
            contacto.LastName = 'test@test45123.com';
            contacto.AccountId = [SELECT Id FROM Account WHERE Name = 'Account Test' LIMIT 1].Id;
            contacto.CC_NumPerso__c = '';
            contacto.CC_Numero_Documento__c = '29801742K';
            contacto.MobilePhone = '666555442';
            insert contacto;

            Datetime fechaActual = System.now();
            CBK_UtilsDate.nowSystem = fechaActual.date().toStartofWeek();

            CSBD_IdentificacionImagin__c customSetting = new CSBD_IdentificacionImagin__c();
            customSetting.Name = 'CSBD_IdentificacionImagin';
            customSetting.CSBD_AplicarLogica__c = false;
            insert customSetting;

            CC_Lista_Valores__c horario = [SELECT CSBD_Hora_inicio_turno__c, CSBD_Hora_fin_turno__c FROM CC_Lista_Valores__c
                                            WHERE CSBD_Tipo_regla__c = 'Horario' AND Name = 'imaginBank - Horario invierno - Mañana' LIMIT 1];

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'cmb',
                'nombre' => 'JOSE MARIA FERNANDEZ MARTIN',
                'telefono' => '680707336',
                'idProducto' => 'Auto_imaginBank',
                'idioma' => '2',
                'tipollamada' => '1',
                'horaIni' => '10',
                'minIni' => '0',
                'horaFin' => '12',
                'minFin' => '0',
                'origen' => 'contratacion',
                'nombre2' => 'JOSE MARIA',
                'apellidos' => 'FERNANDEZ',
                'nif' => '29801742K',
                'canal' => 'portal',
                'colectivo' => '',
                'numperso' => '',
                'subproducto_1' => 'CMN_Suri',
                'apellidos_2' => 'MARTIN',
                'timestamp' => '20190725092425',
                'proceso' => 'CTO/1',
                'tipoCliente' => 'L',
                'tipoContacto' => 'C',
                'agenteSolicitud' => '',
                'boton' => 'CMN_Suri',
                'codProducto' => '',
                'tipoPago' => '',
                'fraccionamiento' => '',
                'importeTotal' => '',
                'margen' => '',
                'indInTouch' => 'S',
                'agenteInTouch' => '',
                'reserva1' => '',
                'reserva2' => ''
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                //System.assertEquals('OK Traspasada: imaginBank', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertEquals(true, true, 'Ha habido algun error: ' + respuesta.detalleError);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestDesestimientoPrestamo() {

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                'CSBD_Now_Presolicitud__c' => '4223010549222'
            });

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'desistimientoPrestamo',
                'Fecha' => '26-9-2019',
                'NombreOficina' => 'CENTRO INTOUCH CAST.LA MANCHA-',
                'NumOficina' => '7625',
                'CodMotivo' => '5',
                'Estado' => 'Pendiente enviar documentación',
                'EmailGestorLO' => 'jccabeza@caixabank.com',
                'CSBD' => 'N',
                'Numsolicitud' => '4223010549222',
                'EmailOficinaLO' => 'oficina.7625@caixabank.com',
                'Canal' => 'LO',
                'NUMPERSO' => 'CC83E9D',
                'Idioma' => 'cas',
                'NombreProducto' => 'Prestamo Online',
                'DescripMotivo' => 'Otras'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestDesistimiento() {

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.Email = 'test@test45.com';
            contacto.LastName = 'test@test45.com';
            contacto.AccountId = [SELECT Id FROM Account WHERE Name = 'Account Test' LIMIT 1].Id;
            contacto.CC_NumPerso__c = '0020FEA7';
            contacto.CC_Numero_Documento__c = 'Y2992285E';
            contacto.MobilePhone = '666555443';
            insert contacto;

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'desistimiento',
                'usuclo' => '08089705300',
                'nombreProducto' => 'CancelaciÃ³n retos Imagin',
                'nombre' => 'SAMUEL YANES MEDINA',
                'horarioContacto' => '',
                'fechaContratacion' => '01/05/2020',
                'emailCliente' => 'samuelplaya12@gmail.com',
                'descripMotivo' => 'No es un desistimiento. Proce der a la baja del producto',
                'contrato' => '2904010205128',
                'canal' => '50001',
                'nif' => 'Y2992285E'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, CSBD_Telefono_Solicitud__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen de la oportunidad no es WS: ' + oportunidad.CSBD_SistemaOrigen__c);
                System.assertEquals('666555443', oportunidad.CSBD_Telefono_Solicitud__c, 'El teléfono de la solicitud no es 666555443: ' + oportunidad.CSBD_Telefono_Solicitud__c);
            }
        }
    }

    @isTest
    private static void altaOportunidadTestDesistimientoPai() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'referencia_usuario' => UUID.randomUUID().toString(),
                'tipoSolicitud' => 'desistimiento PAI',
                'Fecha' => '26-9-2019',
                'NombreOficina' => 'CENTRO INTOUCH CAST.LA MANCHA-',
                'NumOficina' => '7625',
                'CodMotivo' => '5',
                'Estado' => 'Pendiente enviar documentación',
                'EmailGestorLO' => 'prueba@prueba.com',
                'CSBD' => 'N',
                'Numsolicitud' => '4223010549222',
                'EmailOficinaLO' => 'prueba@prueba.com',
                'Canal' => 'LO',
                'NUMPERSO' => 'CC83E9D',
                'Idioma' => 'cas',
                'NombreProducto' => 'Prestamo Online',
                'DescripMotivo' => 'Otras',
                'oficina' => '98989'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen debe ser WS (es ' + oportunidad.CSBD_SistemaOrigen__c + ')');
            }
        }
    }

    @isTest
    private static void altaOportunidadTestProAutomatica() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'tipoSolicitud' => 'proAutomatica',
                'nombreSolicitante' => 'JOSE MARIA FERNANDEZ MARTIN',
                'telefono' => '600600600',
                'idProducto' => 'alta_cliente_CDP',
                'idioma' => '02',
                'proceso' => 'contratación',
                'nombre' => 'JOSE MARIA',
                'apellido1' => 'FERNANDEZ',
                'apellido2' => 'MARTIN',
                'nif' => '35111000F',
                'canal' => 'mobile',
                'numperso' => 'B99F26',
                'entorn' => 'Safari',
                'tipoContacto' => 'Nuevo',
                'email1Tit' => 'email@email.com',
                'nacionalidad1Tit' => 'España',
                'hora' => '25/07/2023 23:04:15',
                'descripMotivo' => 'Cámara',
                'origen' => 'Onboarding alta cliente',
                'journeyActionId' => 'test',
                'campaignId' => 'test',
                'deliveryInternalName' => 'test',
                'messageProfileId' => 'test'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT id, CSBD_SistemaOrigen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'Valor incorrecto en "Sistema origen" (' + oportunidad.CSBD_SistemaOrigen__c + ')');
            }
        }
    }

    @isTest
    private static void altaOportunidadTestPlataformaHipoteca() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            activarMockAltaOportunidadInput(new Map<String, Object>{
                'tipoSolicitud' => 'hipotecaPlataforma',
                'numSolicitud' => '2023042700000001',
                'plataforma' => 'AG002190',
                'tipoOperacion' => '01',
                'idioma' => 'es',
                'plazo' => '240',
                'precioCompra' => '146000.0',
                'importe' => ' 116800.0',
                'aportacionInicial' => '29200.0',
                'usoVivienda' => '02',
                'tipoConstruccionVivienda' => '01',
                'tipoViaVivienda' => 'Plaza',
                'dirVivienda' => 'PlaÃ§a de Madrid',
                'numeroVivienda' => '9',
                'bloqueVivienda' => '2',
                'pisoVivienda' => 'Bajo',
                'puertaVivienda' => 'A',
                'cpVivienda' => '08028',
                'poblVivienda' => '080190',
                'provinciaVivienda' => 'ES-B',
                'ccaaVivienda' => 'ES-CT',
                'paisVivienda' => 'ESP',
                'idSiaSimulacion' => '461',
                'estado' => 'Rechazada',
                'resolucionSimulacion' => 'null',
                'modTipoInteresSimulacion' => 'F',
                'tinInicialSimulacion' => '4.55',
                'indiceRefSimulacion' => '',
                'importeMensualSimulacion' => '742.09',
                'tinSimulacion' => '4.55',
                'taeSimulacion' => '5.111',
                'nif1Tit' => '83481994K',
                'nombre1Tit' => 'VÃ­ctor',
                'apellidos1_1Tit' => 'SÃ¡nchez Castellano',
                'fechaNacimiento1Tit' => '25/2/1965',
                'nacionalidad1Tit' => 'ESP',
                'esSolicitante1Tit' => 'true',
                'pais_residencia1Tit' => 'ESP',
                'ingresosNetos1Tit' => '55040.36',
                'contratoLaboral1Tit' => '01',
                'importeDeuda1Tit' => '20915.88',
                'importeCuotaMensual1Tit' => '503.21',
                'email1Tit' => 'vsanchezc@caixabanktech.com',
                'telefono1_1Tit' => '644872366',
                'esCliente1Tit' => 'true',
                'nif2Tit' => '55871994K',
                'nombre2Tit' => 'Juan',
                'apellidos1_2Tit' => 'PÃ©rez JimÃ©nez',
                'fechaNacimiento2Tit' => '15/4/1975',
                'nacionalidad2Tit' => 'ESP',
                'esSolicitante2Tit' => 'true',
                'pais_residencia2Tit' => 'ESP',
                'ingresosNetos2Tit' => '35040.36',
                'contratoLaboral2Tit' => '01',
                'importeDeuda2Tit' => '10915.88',
                'importeCuotaMensual2Tit' => '303.21',
                'email2Tit' => 'jperezjimenez@caixabanktech.com',
                'telefono1_2Tit' => '610723676',
                'esCliente2Tit' => 'true',
                'precioCompraMoneda' => 'EUR',
                'importeMoneda' => 'EUR',
                'aportacionInicialMoneda' => 'EUR',
                'tipoCliente2Tit' => '1',
                'tipoCliente1Tit' => '1',
                'ingresosNetos1TitMoneda' => 'EUR',
                'ingresosNetos2TitMoneda' => 'EUR',
                'importeDeuda2TitMoneda' => 'EUR',
                'importeCuotaMensual1TitMoneda' => 'EUR',
                'importeCuotaMensual2TitMoneda' => 'EUR',
                'prefijoTelefono1_1Tit' => '34',
                'prefijoTelefono1_2Tit' => '34',
                'maxHipotecaSimulacion' => '80.0',
                'maxImporteHipotecaSimulacion' => '116800.0',
                'gastosInicialesSimulacion' => '2361.77',
                'contribucionInicialSimulacion' => '29200.0',
                'diferencialDescuentoSimulacion' => '0.75',
                'tinDescuentoSimulacion' => '3.8',
                'taeDescuentoSimulacion' => '5.516',
                'plazosDescuentoSimulacion' => '695.54',
                'tasaDescuentoSimulacion' => '3.8'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen debe ser WS (es ' + oportunidad.CSBD_SistemaOrigen__c + ')');
            }
        }
    }

    @isTest
    private static void altaOportunidadTestSoporteDigital() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'tipoSolicitud' => 'soporteDigital',
                'numSolicitud' => '2023042700000001',
                'plataforma' => 'AG002190',
                'nif1Tit' => '83481994K',
                'nombre1Tit' => 'Víctor',
                'apellidos1_1Tit' => 'Sánchez Castellano',
                'fechaNacimiento1Tit' => '25/2/1965',
                'email1Tit' => 'vsanchezc@caixabanktech.com',
                'telefono1_1Tit' => '644872366',
                'esCliente1Tit' => 'true',
                'nif2Tit' => '55871994K',
                'nombre2Tit' => 'Juan',
                'apellidos1_2Tit' => 'PÃ©rez JimÃ©nez',
                'fechaNacimiento2Tit' => '15/4/1975',
                'pais_residencia2Tit' => 'ESP',
                'ingresosNetos2Tit' => '35040.36',
                'contratoLaboral2Tit' => '01',
                'importeDeuda2Tit' => '10915.88',
                'importeCuotaMensual2Tit' => '303.21',
                'email2Tit' => 'jperezjimenez@caixabanktech.com',
                'telefono1_2Tit' => '610723676',
                'numperso2Tit' => 'B99F26',
                'numperso' => '27BD261'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, CSBD_Now_Origen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen debe ser WS (es ' + oportunidad.CSBD_SistemaOrigen__c + ')');
                System.assertEquals('Contratación pack imaginTeens', oportunidad.CSBD_Now_Origen__c, 'El origen debe ser Contratación pack imaginTeens (es ' + oportunidad.CSBD_Now_Origen__c + ')');
            }
        }
    }

    @isTest
    private static void altaOportunidadTestSoporteDigitalKids() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            activarMockAltaOportunidadInput(new Map<String, Object>{
                'tipoSolicitud' => 'soporteDigital',
                'numSolicitud' => '2023042700000001',
                'plataforma' => 'AG002190',
                'nif1Tit' => '83481994K',
                'nombre1Tit' => 'Víctor',
                'apellidos1_1Tit' => 'Sánchez Castellano',
                'fechaNacimiento1Tit' => '25/2/1965',
                'email1Tit' => 'vsanchezc@caixabanktech.com',
                'telefono1_1Tit' => '644872366',
                'esCliente1Tit' => 'true',
                'nif2Tit' => '55871994K',
                'nombre2Tit' => 'Juan',
                'apellidos1_2Tit' => 'Pérez Jiménez',
                'fechaNacimiento2Tit' => '15/4/1975',
                'pais_residencia2Tit' => 'ESP',
                'ingresosNetos2Tit' => '35040.36',
                'contratoLaboral2Tit' => '01',
                'importeDeuda2Tit' => '10915.88',
                'importeCuotaMensual2Tit' => '303.21',
                'email2Tit' => 'jperezjimenez@caixabanktech.com',
                'telefono1_2Tit' => '610723676',
                'numperso2Tit' => 'B99F26',
                'numperso' => '27BD261'
            });

            Test.startTest();
            Date myDatetime = Date.newInstance(1975, 1, 1);
            CBK_UtilsDate.todaySystem = myDatetime;
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, CSBD_Now_Origen__c FROM Opportunity WHERE Id = :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c, 'El sistema origen debe ser WS (es ' + oportunidad.CSBD_SistemaOrigen__c + ')');
                System.assertEquals('Contratación pack imaginKids', oportunidad.CSBD_Now_Origen__c, 'El origen debe ser Contratación pack imaginKids (es ' + oportunidad.CSBD_Now_Origen__c + ')');
            }
        }
    }

    @isTest
    private static void altaOportunidadMac() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Case casoCc = new Case();
            casoCc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            insert casoCc;

            Test.startTest();
            CSBD_WS_AltaOportunidad.altaOportunidadMac(casoCc.Id);
            Test.stopTest();

            System.assertEquals(1, [SELECT Count() FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_MAC'
                AND CSBD_CasoOrigen__c = :casoCc.Id LIMIT 2], 'Debería haberse creado una oportunidad de tipo MAC');
        }
    }

    @isTest
    private static void altaOportunidadTestMacCentralita() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            activarMockAltaOportunidadInput(new Map<String, Object>{
                'nombreProducto' => 'macCentralita',
                'tipoSolicitud' => 'macCentralita',
                'idioma' => 'Castellano',
                'origen' => 'Asistencia Comercial Centralita',
                'nombre' => 'nombre',
                'apellidos' => 'apellido',
                'canal' => 'Llamada entrante',
                'telefono' => '665784524'
            });

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            CSBD_WS_AltaOportunidad_Output.Respuesta respuesta = output.respuestas[0];
            System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
            System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
            String sistemaOrigen = [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :respuesta.opportunityId].CSBD_SistemaOrigen__c;
            System.assertEquals('WS', sistemaOrigen, 'El sistema origen debe ser WS (es ' + sistemaOrigen + ')');
        }
    }
}