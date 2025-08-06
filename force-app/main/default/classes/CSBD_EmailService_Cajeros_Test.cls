@isTest
public with sharing class CSBD_EmailService_Cajeros_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();

        Id idRecordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'Standard Price Book';
        Pricebook2 listaPreciosCsbd = new Pricebook2();
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert new List<Pricebook2>{listaPrecios, listaPreciosCsbd};

        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valorHipoteca = new CC_Lista_Valores__c();
        valorHipoteca.RecordTypeId = idRecordTypeValor;
        valorHipoteca.CC_Lista__c = listaValores.Id;
        valorHipoteca.Name = 'Hipoteca';
        valorHipoteca.CC_Valor__c = '1';
        valores.add(valorHipoteca);
        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = idRecordTypeValor;
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        valores.add(valorPrestamo);
        CC_Lista_Valores__c valorRenting = new CC_Lista_Valores__c();
        valorRenting.RecordTypeId = idRecordTypeValor;
        valorRenting.CC_Lista__c = listaValores.Id;
        valorRenting.Name = 'Renting';
        valorRenting.CC_Valor__c = '1';
        valores.add(valorRenting);
        CC_Lista_Valores__c valorCompraEstrella = new CC_Lista_Valores__c();
        valorCompraEstrella.RecordTypeId = idRecordTypeValor;
        valorCompraEstrella.CC_Lista__c = listaValores.Id;
        valorCompraEstrella.Name = 'Wivai';
        valorCompraEstrella.CC_Valor__c = '1';
        valores.add(valorCompraEstrella);
        CC_Lista_Valores__c valorCMN = new CC_Lista_Valores__c();
        valorCMN.RecordTypeId = idRecordTypeValor;
        valorCMN.CC_Lista__c = listaValores.Id;
        valorCMN.Name = 'CMN';
        valorCMN.CC_Valor__c = '1';
        valores.add(valorCMN);
        CC_Lista_Valores__c valorCMB = new CC_Lista_Valores__c();
        valorCMB.RecordTypeId = idRecordTypeValor;
        valorCMB.CC_Lista__c = listaValores.Id;
        valorCMB.Name = 'CMB';
        valorCMB.CC_Valor__c = '1';
        valores.add(valorCMB);
        CC_Lista_Valores__c valorTPV = new CC_Lista_Valores__c();
        valorTPV.Name = 'TPV';
        valorTPV.RecordTypeId = idRecordTypeValor;
        valorTPV.CC_Lista__c = listaValores.Id;
        valorTPV.CC_Valor__c = '1';
        valores.add(valorTPV);
        CC_Lista_Valores__c valorDES = new CC_Lista_Valores__c();
        valorDES.Name = 'Desistimiento';
        valorDES.RecordTypeId = idRecordTypeValor;
        valorDES.CC_Lista__c = listaValores.Id;
        valorDES.CC_Valor__c = '1';
        valores.add(valorDES);
        CC_Lista_Valores__c valorDESPAI = new CC_Lista_Valores__c();
        valorDESPAI.Name = 'Desistimiento PAI';
        valorDESPAI.RecordTypeId = idRecordTypeValor;
        valorDESPAI.CC_Lista__c = listaValores.Id;
        valorDESPAI.CC_Valor__c = '1';
        valores.add(valorDESPAI);
        insert valores;

        List<CC_Lista_Valores__c> listaValoresCMN = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c listaCmnReenviaAltaOportunidad = new CC_Lista_Valores__c();
        listaCmnReenviaAltaOportunidad.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaCmnReenviaAltaOportunidad.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se reenvían a AltaOportunidad';
        listaCmnReenviaAltaOportunidad.CC_Activa__c = true;
        insert listaCmnReenviaAltaOportunidad;

        CC_Lista_Valores__c listaCmnReenviaAltaOportunidadValor1 = new CC_Lista_Valores__c();
        listaCmnReenviaAltaOportunidadValor1.RecordTypeId = idRecordTypeValor;
        listaCmnReenviaAltaOportunidadValor1.CC_Lista__c = listaCmnReenviaAltaOportunidad.Id;
        listaCmnReenviaAltaOportunidadValor1.Name = 'TIPO_CAMPAÑA';
        listaCmnReenviaAltaOportunidadValor1.CC_Valor__c = '351';
        listaCmnReenviaAltaOportunidadValor1.CC_Orden__c = 1;
        listaCmnReenviaAltaOportunidadValor1.CC_Activa__c = true;
        listaValoresCMN.add(listaCmnReenviaAltaOportunidadValor1);

        CC_Lista_Valores__c listaCmnExternalizarPorCorreo = new CC_Lista_Valores__c();
        listaCmnExternalizarPorCorreo.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaCmnExternalizarPorCorreo.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se externalizan por correo';
        listaCmnExternalizarPorCorreo.CC_Activa__c = true;
        insert listaCmnExternalizarPorCorreo;

        CC_Lista_Valores__c listaCmnExternalizarPorCorreoValor1 = new CC_Lista_Valores__c();
        listaCmnExternalizarPorCorreoValor1.RecordTypeId = idRecordTypeValor;
        listaCmnExternalizarPorCorreoValor1.CC_Lista__c = listaCmnExternalizarPorCorreo.Id;
        listaCmnExternalizarPorCorreoValor1.Name = 'TIPO_CAMPAÑA';
        listaCmnExternalizarPorCorreoValor1.CC_Valor__c = '400';
        listaCmnExternalizarPorCorreoValor1.CC_Orden__c = 1;
        listaCmnExternalizarPorCorreoValor1.CC_Activa__c = true;
        listaValoresCMN.add(listaCmnExternalizarPorCorreoValor1);

        CC_Lista_Valores__c listaCmnExternalizarPorCorreoDestinatarios = new CC_Lista_Valores__c();
        listaCmnExternalizarPorCorreoDestinatarios.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaCmnExternalizarPorCorreoDestinatarios.Name = 'CSBD: Entrada CMN Cajeros - Destinatarios de la externalización por correo';
        listaCmnExternalizarPorCorreoDestinatarios.CC_Activa__c = true;
        insert listaCmnExternalizarPorCorreoDestinatarios;

        CC_Lista_Valores__c listaCmnExternalizarPorCorreoDestinatariosValor1 = new CC_Lista_Valores__c();
        listaCmnExternalizarPorCorreoDestinatariosValor1.RecordTypeId = idRecordTypeValor;
        listaCmnExternalizarPorCorreoDestinatariosValor1.CC_Lista__c = listaCmnExternalizarPorCorreoDestinatarios.Id;
        listaCmnExternalizarPorCorreoDestinatariosValor1.Name = 'DESTINATARIO1';
        listaCmnExternalizarPorCorreoDestinatariosValor1.CC_Valor__c = 'correo@de.prueba';
        listaCmnExternalizarPorCorreoDestinatariosValor1.CC_Activa__c = true;
        listaValoresCMN.add(listaCmnExternalizarPorCorreoDestinatariosValor1);

        EmailTemplate plantillaCorreoCmn = new EmailTemplate();
        plantillaCorreoCmn.isActive = true;
        plantillaCorreoCmn.Name = 'CSBD - Externalización de CMN por correo';
        plantillaCorreoCmn.DeveloperName = 'CSBD_Test_' + System.now().getTime();
        plantillaCorreoCmn.TemplateType = 'text';
        plantillaCorreoCmn.FolderId = usuarioGestor.Id;
        System.runAs (usuarioGestor) {
            insert plantillaCorreoCmn;
        }

        CC_Lista_Valores__c vidaCaixa = new CC_Lista_Valores__c();
        vidaCaixa.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        vidaCaixa.Name = 'CSBD: Desistimientos - Productos gestionados externamente';
        vidaCaixa.CC_Activa__c = true;
        insert vidaCaixa;

        CC_Lista_Valores__c valor3VidaCaixa = new CC_Lista_Valores__c();
        valor3VidaCaixa.RecordTypeId = idRecordTypeValor;
        valor3VidaCaixa.CC_Lista__c = vidaCaixa.Id;
        valor3VidaCaixa.Name = 'Cancelación retos Imagin';
        valor3VidaCaixa.CC_Valor__c = '';
        valor3VidaCaixa.CC_Orden__c = 1;
        valor3VidaCaixa.CC_Activa__c = true;
        listaValoresCMN.add(valor3VidaCaixa);

        insert listaValoresCMN;

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'Cuenta Test';
        cuenta.CC_Numero_Documento__c = '46979396X';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Nombre Test';
        contacto.LastName = 'Apellido Test';
        contacto.Phone = '612345678';
        contacto.Email = 'direccion@de.correo';
        contacto.CC_NumPerso__c = '23733117';
        insert contacto;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
    }

    @isTest
    public static void correoCmnExternalizarPorCorreo() {
        String cuerpoCorreo = '[TipoEnvio]\nC\n[CodigoCampanya]\n400\n[NombreProducto]\nPROVES\n[TipoCampanya]\n400\n[NumPersona]\n23733117\n[NIF/CIF]\n44862512T\n[NombrePersona]\nNOTOCAR\n';
        cuerpoCorreo += '[Apellido1_pers_contacto]\nTARJETAS\n[Apellido2_pers_contacto]\nESTAMPADAS\n[Idioma]\n002\n[Sexo]\n[CodigoEmpleadoASF]\n[CodigoOficinaAdmin]\n09712\n';
        cuerpoCorreo += '[TelefonoAlf]\n677123456\n[EmailAlf]\nALF@PROVES.ES\n[TelefonoContacto]\n649774318\n[EmailContacto]\nPROVES@PROVES.ES\n[HorarioContacto]\nMATI\n\n';
        cuerpoCorreo += '[CanalContacto]\nSCX\n[DiaPeticion]\n14-01-2021\n[HoraPeticion]\n16:22\n[Comentarios]\n[OficinaCajero]\n09712\n[Num.Tarjeta]\n4548039368313036\n[Leyenda]\n';

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario.body = Blob.valueOf('my binary text');
        adjuntoBinario.fileName = 'textfileone.txt';
        adjuntoBinario.mimeTypeSubType = 'text/plain';

		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail correoCmnExternalizarCorreo = new Messaging.InboundEmail();
        correoCmnExternalizarCorreo.fromAddress = 'direccioRemitente@de.correo';
        correoCmnExternalizarCorreo.toAddresses = new List<String>{'direccionPara@de.correo'};
        correoCmnExternalizarCorreo.subject = 'Correo Test';
        correoCmnExternalizarCorreo.plainTextBody = cuerpoCorreo;
        correoCmnExternalizarCorreo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario};
        correoCmnExternalizarCorreo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'direccioRemitente@de.correo';
        env.toAddress = 'direccionPara@de.correo';

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        //Ejecución de la prueba
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Test.startTest();
            CSBD_EmailService_Cajeros emailServiceCajeros = new CSBD_EmailService_Cajeros();
            Messaging.InboundEmailResult resultado = emailServiceCajeros.handleInboundEmail(correoCmnExternalizarCorreo, env);
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals(true, resultado.success, 'Error en el alta de la oportunidad');
            List<Opportunity> oportunidades = [SELECT StageName, CSBD_Estado__c, CSBD_Resolucion__c FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_CMN' LIMIT 1];
            System.assert(!oportunidades.isEmpty(), 'No se ha creado la oportunidad de CMN recibida');
            System.assertEquals('Rechazada', oportunidades[0].StageName, 'La oportunidad debe crearse con etapa de ventas "Rechazada"');
            System.assertEquals('Rechazada', oportunidades[0].CSBD_Estado__c, 'La oportunidad debe crearse en estado "Rechazada"');
            System.assertEquals('Externalizada', oportunidades[0].CSBD_Resolucion__c, 'La oportunidad debe crearse con resolución "Externalizada"');

            List<Task> tareas = [SELECT Id FROM Task WHERE WhatId = :oportunidades[0].Id AND Subject LIKE 'Externalización%' LIMIT 1];
            System.assert(!tareas.isEmpty(), 'La oportunidad debe tener una tarea que refleje la externalización por correo');
        }
    }

    @isTest
    public static void correoCmnLogicaAltaOportunidad() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Messaging.InboundEmail correoCmnAltaOportunidad = new Messaging.InboundEmail();
        correoCmnAltaOportunidad.fromAddress = 'direccioRemitente@de.correo';
        correoCmnAltaOportunidad.toAddresses = new List<String>{'direccionPara@de.correo'};
        correoCmnAltaOportunidad.ccAddresses = new List<String>{'direccionPara@de.correo'};
        correoCmnAltaOportunidad.subject = 'Correo Test';
        String cuerpoCorreo = '[TipoEnvio]\nC\n[CodigoCampanya]\n351\n[NombreProducto]\nPROVES\n[TipoCampanya]\n351\n[NumPersona]\n23733117\n[NIF/CIF]\n44862512T\n[NombrePersona]\nNOTOCAR\n';
        cuerpoCorreo += '[Apellido1_pers_contacto]\nTARJETAS\n[Apellido2_pers_contacto]\nESTAMPADAS\n[Idioma]\n002\n[Sexo]\n[CodigoEmpleadoASF]\n[CodigoOficinaAdmin]\n09712\n';
        cuerpoCorreo += '[TelefonoAlf]\n677123456\n[EmailAlf]\nALF@PROVES.ES\n[TelefonoContacto]\n649774318\n[EmailContacto]\nPROVES@PROVES.ES\n[HorarioContacto]\nMATI\n\n';
        cuerpoCorreo += '[CanalContacto]\nSCX\n[DiaPeticion]\n14-01-2021\n[HoraPeticion]\n16:22\n[Comentarios]\n[OficinaCajero]\n09712\n[Num.Tarjeta]\n4548039368313036\n[Leyenda]\n';
        correoCmnAltaOportunidad.plainTextBody = cuerpoCorreo;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'direccioRemitente@de.correo';
        env.toAddress = 'direccionPara@de.correo';

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario.body = Blob.valueOf('my binary text');
        adjuntoBinario.fileName = 'textfileone.txt';
        adjuntoBinario.mimeTypeSubType = 'text/plain';
        correoCmnAltaOportunidad.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario};

		Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'text/plain';
        correoCmnAltaOportunidad.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        Messaging.InboundEmail correoCmnAltaOportunidad2 = new Messaging.InboundEmail();
        correoCmnAltaOportunidad2.fromAddress = 'correo@prueba';
        correoCmnAltaOportunidad2.toAddresses = new List<String>{'correo@prueba'};
        correoCmnAltaOportunidad2.ccAddresses = new List<String>{'correo@prueba'};
        correoCmnAltaOportunidad2.subject = 'Correo Test';
        String cuerpoCorreo2 = '[TipoEnvio]\nC\n[CodigoCampanya]\n351\n[NombreProducto]\nPROVES\n[TipoCampanya]\n351\n[NumPersona]\n23733117\n[NIF/CIF]\n44862512T\n[NombrePersona]\nNOTOCAR\n';
        cuerpoCorreo2 += '[Apellido1_pers_contacto]\nTARJETAS\n[Apellido2_pers_contacto]\nESTAMPADAS\n[Idioma]\n002\n[Sexo]\n[CodigoEmpleadoASF]\n[CodigoOficinaAdmin]\n09712\n';
        cuerpoCorreo2 += '[TelefonoAlf]\n677123456\n[EmailAlf]\nALF@PROVES.ES\n[TelefonoContacto]\n649774318\n[EmailContacto]\nPROVES@PROVES.ES\n[HorarioContacto]\nMATI\n\n';
        cuerpoCorreo2 += '[CanalContacto]\nSCX\n[DiaPeticion]\n14-01-2021\n[HoraPeticion]\n16:22\n[Comentarios]\n[OficinaCajero]\n09712\n[Num.Tarjeta]\n4548039368313036\n[Leyenda]\n';
        correoCmnAltaOportunidad2.plainTextBody = cuerpoCorreo2;

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = Blob.valueOf('my binary text');
        adjuntoBinario2.fileName = 'textfileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        correoCmnAltaOportunidad2.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario2};

		Messaging.InboundEmail.TextAttachment adjuntoTexto2 = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto2.body = 'my attachment text';
        adjuntoTexto2.fileName = 'textfiletwo3.txt';
        adjuntoTexto2.mimeTypeSubType = 'text/plain';
        correoCmnAltaOportunidad2.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto2};


        //Ejecución de la prueba
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_EmailService_Cajeros emailServiceCajeros = new CSBD_EmailService_Cajeros();
            CSBD_EmailService_Cajeros emailServiceCajeros2 = new CSBD_EmailService_Cajeros();
            Messaging.InboundEmailResult resultado = emailServiceCajeros.handleInboundEmail(correoCmnAltaOportunidad, env);
            Messaging.InboundEmailResult resultado2 = emailServiceCajeros2.handleInboundEmail(correoCmnAltaOportunidad2, env);
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals(true, resultado.success, 'Error en el alta de la oportunidad');
            List<Opportunity> oportunidades = [SELECT StageName, CSBD_Estado__c, CSBD_Resolucion__c FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_CMN'];
            System.assert(oportunidades.size() > 0, 'No se ha creado la oportunidad de CMN recibida');
            EmailMessage mailCreado = [SELECT Id FROM EmailMessage WHERE CSBD_Oportunidad_Id__c = :oportunidades[0].Id];

            System.assertEquals(null, resultado2, 'Comprobamos que no se crea el mensaje de salida.');

            CBK_Log__c respuestaLogBuena = [SELECT Log_Level__c, CBK_sfdcType__c, CBK_sfdcCaseId__c, CBK_sfdcMessageId__c, CBK_sfdcResultDetail__c from CBK_Log__c WHERE CBK_sfdcResultStatus__c = 'OK' AND OwnerId = :usuarioGestor.Id];
            System.assertEquals(oportunidades[0].Id, respuestaLogBuena.CBK_sfdcCaseId__c, 'Comprobamos que la oportunidad esta relacionada con la creada.');
            System.assertEquals(mailCreado.Id, respuestaLogBuena.CBK_sfdcMessageId__c, 'Comprobamos que el emailmessage id no es null.');
            System.assertEquals('Resultado', respuestaLogBuena.CBK_sfdcType__c, 'Comprobamos que el tipo es resultado.');
            System.assertEquals('Envio correcto', respuestaLogBuena.CBK_sfdcResultDetail__c, 'Comprobamos que el detail es envio correcto.');
            System.assertEquals('INFO', respuestaLogBuena.Log_Level__c, 'Comprobamos que el nivel es info.');

            //CBK_Log__c respuestaLogMala = [SELECT CBK_sfdcResultDetail__c from CBK_Log__c WHERE CBK_sfdcResultStatus__c = 'KO' AND OwnerId = :usuarioGestor.Id];
            //System.assertNotEquals('Envio correcto', respuestaLogMala.CBK_sfdcResultDetail__c, 'Comprobamos que el detail no es envio correcto.');
        }
    }

    /*
    @isTest
    public static void correoCmnDescartar() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Messaging.InboundEmail correoCmnDescartar = new Messaging.InboundEmail();
        correoCmnDescartar.fromAddress = 'direccioRemitente@de.correo';
        correoCmnDescartar.toAddresses = new List<String>{'direccionPara@de.correo'};
        correoCmnDescartar.subject = 'Correo Test';
        String cuerpoCorreo = '[TipoEnvio]\nC\n[CodigoCampanya]\nA\n[NombreProducto]\nPROVES\n[TipoCampanya]\nA\n[NumPersona]\n23733117\n[NIF/CIF]\n44862512T\n[NombrePersona]\nNOTOCAR\n';
        cuerpoCorreo += '[Apellido1_pers_contacto]\nTARJETAS\n[Apellido2_pers_contacto]\nESTAMPADAS\n[Idioma]\n002\n[Sexo]\n[CodigoEmpleadoASF]\n[CodigoOficinaAdmin]\n09712\n';
        cuerpoCorreo += '[TelefonoAlf]\n677123456\n[EmailAlf]\nALF@PROVES.ES\n[TelefonoContacto]\n649774318\n[EmailContacto]\nPROVES@PROVES.ES\n[HorarioContacto]\nMATI\n\n';
        cuerpoCorreo += '[CanalContacto]\nSCX\n[DiaPeticion]\n14-01-2021\n[HoraPeticion]\n16:22\n[Comentarios]\n[OficinaCajero]\n09712\n[Num.Tarjeta]\n4548039368313036\n[Leyenda]\n';
        correoCmnDescartar.htmlBody = cuerpoCorreo;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'direccioRemitente@de.correo';
        env.toAddress = 'direccionPara@de.correo';

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario.body = Blob.valueOf('my binary text');
        adjuntoBinario.fileName = 'textfileone.txt';
        adjuntoBinario.mimeTypeSubType = 'text/plain';
        correoCmnDescartar.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario};

        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'text/plain';
        correoCmnDescartar.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        //Ejecución de la prueba
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_EmailService_Cajeros emailServiceCajeros = new CSBD_EmailService_Cajeros();
            Messaging.InboundEmailResult resultado = emailServiceCajeros.handleInboundEmail(correoCmnDescartar, env);
            Test.stopTest();

            //Evaluación del resultado de la prueba
            System.assertEquals(true, resultado.success, 'Error en el alta de la oportunidad');
            List<Opportunity> oportunidades = [SELECT StageName, CSBD_Estado__c, CSBD_Resolucion__c FROM Opportunity WHERE RecordType.DeveloperName = 'CSBD_CMN'];
            System.assert(oportunidades.size() == 0, 'El CodigoCampanya del correo de prueba no debe crear ninguna oportunidad');
        }
    }
    */

    private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
        List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c
                                                                FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true LIMIT 1];
        if (!parametrosInterfaz.isEmpty()) {
            return parametrosInterfaz[0];
        } else {
            return null;
        }
    }
}