@isTest
public class OB_WS_AltaLlamada_Test {

    @TestSetup
    static void testSetup() {

        //Oficina
        Account oficina = new Account();
        oficina.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        oficina.CC_Tipo_Centro__c = 'OF';
        oficina.Name = 'test centro';
        oficina.CC_Numero_Empresa__c = '001';
        oficina.CC_Numero_Oficina__c = '09999';
        oficina.CC_Numero_Oficina_Empresa__c = '001-09999';
        oficina.CC_Idioma_Oficina__c = '001';
        oficina.CC_Email__c = 'prueba@test.com';
        oficina.CC_Inactivo__c = false;
        insert oficina;

        //Lista de valores para conversión de idioma
        CC_Lista_Valores__c lovIdioma = new CC_Lista_Valores__c();
        lovIdioma.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovIdioma.CC_Activa__c = true;
        lovIdioma.Name = 'Outbound: Conversión del atributo "Idioma"'; 
        insert lovIdioma;

        CC_Lista_Valores__c lovIdiomaCat = new CC_Lista_Valores__c();
        lovIdiomaCat.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lovIdiomaCat.CC_Activa__c = true;
        lovIdiomaCat.CC_Lista__c = lovIdioma.Id;
        lovIdiomaCat.Name = '020';
        lovIdiomaCat.CC_Valor__c = 'ca';
        lovIdiomaCat.CC_Valor2__c = 'Catalán';
        insert lovIdiomaCat;

        //Usuario
        User usuario = new User();
        usuario.Username = 'usergeneral2@test.com';
        usuario.Email = 'maria@test.com';
        usuario.LastName = 'usuario Test';
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OB_Usuario_CaixaBank'].Id;
        usuario.Alias = 'maria';
        usuario.TimeZoneSidKey = 'GMT';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'en_US';
        usuario.isActive = true;       
        insert usuario;

        //Plataforma
        OB_Parametrizacion__c plataforma = new OB_Parametrizacion__c();
        plataforma.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Plataforma');
        plataforma.Name = 'Plataforma test';
        plataforma.OB_Codigo_Externo__c = 'Plataforma1';
        plataforma.OB_Centro_Gestor__c = '12345';
        plataforma.OB_Activo__c = true;
        insert plataforma;

        //Campaña APC Multi-mes
        OB_Parametrizacion__c campanyaAPC = new OB_Parametrizacion__c();
        campanyaAPC.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Campanya');
        campanyaAPC.OB_Activo__c = true;
        campanyaAPC.Name = 'Campaña APC';
        campanyaAPC.OB_Codigo_Externo__c = 'APC';
        campanyaAPC.OB_Multimes__c = true;
        insert campanyaAPC;

        //Campaña APC02
        OB_Parametrizacion__c campanyaAPC02 = new OB_Parametrizacion__c();
        campanyaAPC02.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Campanya');
        campanyaAPC02.OB_Activo__c = true;
        campanyaAPC02.Name = 'Campaña APC02';
        campanyaAPC02.OB_Codigo_Externo__c = 'APC02';
        campanyaAPC02.OB_Multimes__c = false;
        insert campanyaAPC02;

        //Familia de producto
        OB_Parametrizacion__c familiaProducto = new OB_Parametrizacion__c();
        familiaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
        familiaProducto.Name = 'Familia Producto Test';
        familiaProducto.OB_Activo__c = true;
        familiaProducto.OB_Formato_Codigo_Contrato__c = '9999.999.999999999';
        insert familiaProducto;

        //Producto
        OB_Parametrizacion__c producto = new OB_Parametrizacion__c();
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
        producto.Name = 'Producto Test';
        producto.OB_Activo__c = true;
        producto.OB_Parametrizacion_Padre__c = familiaProducto.Id;
        producto.OB_Codigo_Externo__c = '12345';
        insert producto;

        //Agrupador de plantillas
        OB_Parametrizacion__c agrupadorPlantillas = new OB_Parametrizacion__c();
        agrupadorPlantillas.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Agrupador_Plantillas');
        agrupadorPlantillas.Name = 'PRÉSTAMOS CON VISITA';
        agrupadorPlantillas.OB_Activo__c = true;
        agrupadorPlantillas.OB_Email__c = true;
        agrupadorPlantillas.OB_SMS__c = true;
        agrupadorPlantillas.OB_Plantilla_Email_Defecto__c = 'plantilla';
        agrupadorPlantillas.OB_Plantilla_SMS_Defecto__c = 'plantilla';
        insert agrupadorPlantillas;

        //Relacion Campaña - Producto
        OB_Parametrizacion__c relacionCampanyaProducto = new OB_Parametrizacion__c();
        relacionCampanyaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto');
        relacionCampanyaProducto.OB_Parametrizacion_Padre__c = campanyaAPC02.Id;
        relacionCampanyaProducto.OB_Parametrizacion_Relacionada__c = producto.Id;
        relacionCampanyaProducto.OB_Tipo_Validacion__c = 'BackOffice';
        relacionCampanyaProducto.OB_Agrupador_Plantillas__c = agrupadorPlantillas.Id;
        insert relacionCampanyaProducto;

        //Resultado de cierre
        OB_Parametrizacion__c resultadoCierrePositivo = new OB_Parametrizacion__c();
        resultadoCierrePositivo.Name = 'POSITIVO';
        resultadoCierrePositivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Resultado_Cierre');
        resultadoCierrePositivo.OB_Activo__c = true;
        resultadoCierrePositivo.OB_Tipo_contratacion__c = 'ALTA';
        resultadoCierrePositivo.OB_Tipo_Cierre__c = 'POSITIVO';

        OB_Parametrizacion__c resultadoCierreNegativo = new OB_Parametrizacion__c();
        resultadoCierreNegativo.Name = 'NEGATIVO';
        resultadoCierreNegativo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Resultado_Cierre');
        resultadoCierreNegativo.OB_Activo__c = true;
        resultadoCierreNegativo.OB_Tipo_contratacion__c = 'ALTA';
        resultadoCierreNegativo.OB_Tipo_Cierre__c = 'NEGATIVO';

        insert new List<OB_Parametrizacion__c>{resultadoCierrePositivo, resultadoCierreNegativo};

        //Plantilla de correo/sms
        EmailTemplate plantillaCorreoSms = new EmailTemplate();
        plantillaCorreoSms.isActive = true;
        plantillaCorreoSms.Name = 'plantilla';
        plantillaCorreoSms.DeveloperName = 'OB_Test_' + System.now().getTime();
        plantillaCorreoSms.TemplateType = 'text';
        plantillaCorreoSms.FolderId = UserInfo.getUserId();
        plantillaCorreoSms.HtmlValue = 'cuerpo de la plantilla';
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert plantillaCorreoSms;
        }
    }

	@isTest
    public static void altaLlamadaOutboundAlta() {

        String contenido = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><RequestDoAlta>';
        contenido += '<IdPeticion>007402F41535B22C54011</IdPeticion>';
        contenido += '<TipoMovimiento>Alta</TipoMovimiento>';
        contenido += '<NumPerso>0040399420</NumPerso>';
        contenido += '<NifCliente>18208757W</NifCliente>';
        contenido += '<NombreCliente>JOSE JAVIER</NombreCliente>';
        contenido += '<Apellido1Cliente>OYARZABAL</Apellido1Cliente>';
        contenido += '<Apellido2Cliente>ARRATIBEL</Apellido2Cliente>';
        contenido += '<Idioma>020</Idioma>';
        contenido += '<CentroGestor>11111</CentroGestor>';
        contenido += '<UsuarioGestor>U1915010</UsuarioGestor>';
        contenido += '<ConnId>007402F41535B22C</ConnId>';
        contenido += '<Extension>6915004</Extension>';
        contenido += '<FechaLlamada>20200227</FechaLlamada>';
        contenido += '<HoraLlamada>15:00:10</HoraLlamada>';
        contenido += '<EnviarEmail>N</EnviarEmail>';
        contenido += '<OficinaEmail>05209</OficinaEmail>';
        contenido += '<EnviarSMS>N</EnviarSMS>';
        contenido += '<ResultadoNivel2>4</ResultadoNivel2>';
        contenido += '<DatosAdicionales></DatosAdicionales>';
        contenido += '<Agente>1915010</Agente>';
        contenido += '<Plataforma>Plataforma1</Plataforma>';
        contenido += '<CodigoCampana>APC02</CodigoCampana>';
        contenido += '<CodigoProducto>12345</CodigoProducto>';
        contenido += '<ResultadoCierre>POSITIVO</ResultadoCierre>';
        contenido += '<TelefonoSR>666777888</TelefonoSR>';
        contenido += '<EmailSR>test@test.com</EmailSR>';
        contenido += '</RequestDoAlta>';

        //Petición
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();             
        request.requestUri = '/services/apexrest/AltaLlamadaOutbound';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'text/xml');
        request.requestBody = Blob.valueOf(contenido);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        OB_WS_AltaLlamada.altaLlamadaOutbound();

        /*
        OB_WS_AltaLlamada_Output.Respuesta output = OB_WS_AltaLlamada.altaLlamadaOutbound();
        System.assertEquals('OK', output.resultado, 'Ha habido algun error: ' + output.detalleError);
        System.assertNotEquals('', output.llamadaId, 'No se ha creado la llamada.' + output.detalleError);
        idLlamadasSet.add(output.llamadaId);

        System.assertNotEquals('', [SELECT Type, WhatId FROM Task WHERE WhatId IN :idLlamadasSet AND Type = 'JSON - Entrante'].Type);
        */

        Test.stopTest();
	}

	@isTest
    public static void altaLlamadaOutboundAltaKo() {

        String contenido = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><RequestDoAlta>';
        contenido += '<IdPeticion>007402F41535B22C54011</IdPeticion>';
        contenido += '<TipoMovimiento>Alta</TipoMovimiento>';
        contenido += '<NumPerso>0040399420</NumPerso>';
        contenido += '<NifCliente>18208757W</NifCliente>';
        contenido += '<NombreCliente>JOSE JAVIER</NombreCliente>';
        contenido += '<Apellido1Cliente>OYARZABAL</Apellido1Cliente>';
        contenido += '<Apellido2Cliente>ARRATIBEL</Apellido2Cliente>';
        contenido += '<Idioma>020</Idioma>';
        contenido += '<CentroGestor>11111</CentroGestor>';
        contenido += '<UsuarioGestor>U1915010</UsuarioGestor>';
        contenido += '<ConnId>007402F41535B22C</ConnId>';
        contenido += '<Extension>6915004</Extension>';
        contenido += '<FechaLlamada>20200227</FechaLlamada>';
        contenido += '<HoraLlamada>15:00:10</HoraLlamada>';
        contenido += '<EnviarEmail>N</EnviarEmail>';
        contenido += '<OficinaEmail>05209</OficinaEmail>';
        contenido += '<EnviarSMS>N</EnviarSMS>';
        contenido += '<ResultadoNivel2>4</ResultadoNivel2>';
        contenido += '<DatosAdicionales></DatosAdicionales>';
        contenido += '<Agente>1915010</Agente>';
        contenido += '<Plataforma>Plataforma1 KO</Plataforma>';
        contenido += '<CodigoCampana>APC02</CodigoCampana>';
        contenido += '<CodigoProducto>12345</CodigoProducto>';
        contenido += '<ResultadoCierre>POSITIVO</ResultadoCierre>';
        contenido += '</RequestDoAlta>';

        //Petición
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();             
        request.requestUri = '/services/apexrest/AltaLlamadaOutbound';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'text/xml');
        request.requestBody = Blob.valueOf(contenido);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        OB_WS_AltaLlamada.altaLlamadaOutbound();

        /*
        OB_WS_AltaLlamada_Output.Respuesta output = OB_WS_AltaLlamada.altaLlamadaOutbound();
        System.assertEquals('OK', output.resultado, 'Ha habido algun error: ' + output.detalleError);
        System.assertNotEquals('', output.llamadaId, 'No se ha creado la llamada.' + output.detalleError);
        idLlamadasSet.add(output.llamadaId);

        System.assertNotEquals('', [SELECT Type, WhatId FROM Task WHERE WhatId IN :idLlamadasSet AND Type = 'JSON - Entrante'].Type);
        */

        Test.stopTest();
	}

    @isTest
    public static void altaLlamadaOutboundCierre() {

        String contenido = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><RequestDoAlta>';
        contenido += '<IdPeticion>007402F41535B22C54011</IdPeticion>';
        contenido += '<TipoMovimiento>Cierre</TipoMovimiento>';
        contenido += '<NumPerso>0040399420</NumPerso>';
        contenido += '<NifCliente>18208757W</NifCliente>';
        contenido += '<NombreCliente>JOSE JAVIER</NombreCliente>';
        contenido += '<Apellido1Cliente>OYARZABAL</Apellido1Cliente>';
        contenido += '<Apellido2Cliente>ARRATIBEL</Apellido2Cliente>';
        contenido += '<Idioma>020</Idioma>';
        contenido += '<CentroGestor>11111</CentroGestor>';
        contenido += '<UsuarioGestor>U1915010</UsuarioGestor>';
        contenido += '<ResultadoCierre>POSITIVO</ResultadoCierre>';
        contenido += '<ConnId>007402F41535B22C</ConnId>';
        contenido += '<Extension>6915004</Extension>';
        contenido += '<FechaLlamada>20200227</FechaLlamada>';
        contenido += '<HoraLlamada>15:00:10</HoraLlamada>';
        contenido += '<EnviarEmail>Y</EnviarEmail>';
        contenido += '<OficinaEmail>09999</OficinaEmail>';
        contenido += '<TelefonoSMS>666777888</TelefonoSMS>';
        contenido += '<EnviarSMS>Y</EnviarSMS>';
        contenido += '<ResultadoNivel2>4</ResultadoNivel2>';
        contenido += '<DatosAdicionales>da</DatosAdicionales>';
        contenido += '<Agente>1915010</Agente>';
        contenido += '<Plataforma>Plataforma1</Plataforma>';
        contenido += '<CodigoCampana>APC02</CodigoCampana>';
        contenido += '<CodigoProducto>12345</CodigoProducto>';
        contenido += '<CodContrato>9999.999.999999999</CodContrato>';
        contenido += '<FechaVisita>20211027</FechaVisita>';
        contenido += '<ImporteOfrecido>0005434.345</ImporteOfrecido>';
        contenido += '<ImporteFormalizar>0005434.345</ImporteFormalizar>';
        contenido += '</RequestDoAlta>';

        //Petición
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/AltaLlamadaOutbound/altaLlamadaOutbound';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'text/html');
        request.requestBody = Blob.valueOf(contenido);
        RestContext.request = request;

        Test.startTest();

        OB_WS_AltaLlamada.altaLlamadaOutbound();

        /*
        OB_WS_AltaLlamada_Output.Respuesta output = OB_WS_AltaLlamada.altaLlamadaOutbound();
        System.assertEquals('OK', output.resultado, 'Ha habido algun error: ' + output.detalleError);
        System.assertNotEquals('', output.llamadaId, 'No se ha creado la llamada.' + output.detalleError);
        idLlamadasSet.add(output.llamadaId);

        System.assertNotEquals('', [SELECT Type, WhatId FROM Task WHERE WhatId IN :idLlamadasSet AND Type = 'JSON - Entrante'].Type);
        */

        Test.stopTest();
	}

    @isTest
    public static void altaLlamadaOutboundCierreKo() {

        String contenido = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><RequestDoAlta>';
        contenido += '<IdPeticion>007402F41535B22C54011</IdPeticion>';
        contenido += '<TipoMovimiento>Cierre</TipoMovimiento>';
        contenido += '<NumPerso>0040399420</NumPerso>';
        contenido += '<NifCliente>18208757W</NifCliente>';
        contenido += '<NombreCliente>JOSE JAVIER</NombreCliente>';
        contenido += '<Apellido1Cliente>OYARZABAL</Apellido1Cliente>';
        contenido += '<Apellido2Cliente>ARRATIBEL</Apellido2Cliente>';
        contenido += '<Idioma>020</Idioma>';
        contenido += '<CentroGestor>11111</CentroGestor>';
        contenido += '<UsuarioGestor>U1915010</UsuarioGestor>';
        contenido += '<ResultadoCierre>POSITIVO</ResultadoCierre>';
        contenido += '<ConnId>007402F41535B22C</ConnId>';
        contenido += '<Extension>6915004</Extension>';
        contenido += '<FechaLlamada>202002b7</FechaLlamada>';
        contenido += '<HoraLlamada>15:00:10</HoraLlamada>';
        contenido += '<EnviarEmail>Y</EnviarEmail>';
        contenido += '<OficinaEmail>09999</OficinaEmail>';
        contenido += '<TelefonoSMS>666777888</TelefonoSMS>';
        contenido += '<EnviarSMS>Y</EnviarSMS>';
        contenido += '<ResultadoNivel2>4</ResultadoNivel2>';
        contenido += '<DatosAdicionales></DatosAdicionales>';
        contenido += '<Agente>1915010</Agente>';
        contenido += '<Plataforma>Plataforma1</Plataforma>';
        contenido += '<CodigoCampana>APC02</CodigoCampana>';
        contenido += '<CodigoProducto>12345</CodigoProducto>';
        contenido += '<CodContrato>9999.999.999999999</CodContrato>';
        contenido += '<FechaVisita>20211027</FechaVisita>';
        contenido += '<ImporteOfrecido>0005434.345</ImporteOfrecido>';
        contenido += '<ImporteFormalizar>0005434.345</ImporteFormalizar>';
        contenido += '</RequestDoAlta>';

        //Petición
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/AltaLlamadaOutbound/altaLlamadaOutbound';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'text/html');
        request.requestBody = Blob.valueOf(contenido);
        RestContext.request = request;

        Test.startTest();

        OB_WS_AltaLlamada.altaLlamadaOutbound();

        /*
        OB_WS_AltaLlamada_Output.Respuesta output = OB_WS_AltaLlamada.altaLlamadaOutbound();
        System.assertEquals('OK', output.resultado, 'Ha habido algun error: ' + output.detalleError);
        System.assertNotEquals('', output.llamadaId, 'No se ha creado la llamada.' + output.detalleError);
        idLlamadasSet.add(output.llamadaId);

        System.assertNotEquals('', [SELECT Type, WhatId FROM Task WHERE WhatId IN :idLlamadasSet AND Type = 'JSON - Entrante'].Type);
        */

        Test.stopTest();
	}

    @isTest
    public static void altaLlamadaOutboundAltaCierre() {

        String contenido = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><RequestDoAlta>';
        contenido += '<IdPeticion>007402F41535B22C54011</IdPeticion>';
        contenido += '<NumeroSR>L-NoExiste</NumeroSR>';
        contenido += '<TipoMovimiento>Cierre</TipoMovimiento>';
        contenido += '<NumPerso>0040399420</NumPerso>';
        contenido += '<NifCliente>18208757W</NifCliente>';
        contenido += '<NombreCliente>JOSE JAVIER</NombreCliente>';
        contenido += '<Apellido1Cliente>OYARZABAL</Apellido1Cliente>';
        contenido += '<Apellido2Cliente>ARRATIBEL</Apellido2Cliente>';
        contenido += '<Idioma>020</Idioma>';
        contenido += '<CentroGestor>11111</CentroGestor>';
        contenido += '<UsuarioGestor>U1915010</UsuarioGestor>';
        contenido += '<ResultadoCierre>NEGATIVO</ResultadoCierre>';
        contenido += '<ConnId>007402F41535B22C</ConnId>';
        contenido += '<Extension>6915004</Extension>';
        contenido += '<FechaLlamada>20200227</FechaLlamada>';
        contenido += '<HoraLlamada>15:00:10</HoraLlamada>';
        contenido += '<EnviarEmail>Y</EnviarEmail>';
        contenido += '<OficinaEmail>09999</OficinaEmail>';
        contenido += '<TelefonoSMS>666777888</TelefonoSMS>';
        contenido += '<EnviarSMS>Y</EnviarSMS>';
        contenido += '<ResultadoNivel2>4</ResultadoNivel2>';
        contenido += '<DatosAdicionales>da</DatosAdicionales>';
        contenido += '<Agente>1915010</Agente>';
        contenido += '<Plataforma>Plataforma1</Plataforma>';
        contenido += '<CodigoCampana>APC02</CodigoCampana>';
        contenido += '<CodigoProducto>12345</CodigoProducto>';
        contenido += '<CodContrato>9999.999.999999999</CodContrato>';
        contenido += '<FechaVisita>20211027</FechaVisita>';
        contenido += '<ImporteOfrecido>0005434.345</ImporteOfrecido>';
        contenido += '<ImporteFormalizar>0005434.345</ImporteFormalizar>';
        contenido += '</RequestDoAlta>';

        //Petición
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/AltaLlamadaOutbound/altaLlamadaOutbound';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'text/html');
        request.requestBody = Blob.valueOf(contenido);
        RestContext.request = request;

        Test.startTest();

        OB_WS_AltaLlamada.altaLlamadaOutbound();

        /*
        OB_WS_AltaLlamada_Output.Respuesta output = OB_WS_AltaLlamada.altaLlamadaOutbound();
        System.assertEquals('OK', output.resultado, 'Ha habido algun error: ' + output.detalleError);
        System.assertNotEquals('', output.llamadaId, 'No se ha creado la llamada.' + output.detalleError);
        idLlamadasSet.add(output.llamadaId);

        System.assertNotEquals('', [SELECT Type, WhatId FROM Task WHERE WhatId IN :idLlamadasSet AND Type = 'JSON - Entrante'].Type);
        */

        Test.stopTest();
	}
}