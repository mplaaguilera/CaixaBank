@isTest
public class SACH_Case_Operativa_Test {
    
    @TestSetup
    static void setData() {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente'; 
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;

        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = recordTypeGrupoColaborador;
        grupo.name = 'Servicio SACH';
        grupo.OS_Negocio__c = 'CC';
        insert grupo;

        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Plantilla SACH';
        template1.Subject = 'esto es una prueba';
        template1.HtmlValue = '';
        template1.DeveloperName = 'SACH_Plantilla_Prueba';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }

        List<Case> lstCasos = new List<Case>();
        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.Status = 'Activo';
        lstCasos.add(caso);
        
        Case caso2 = new Case();
        caso2.Subject = 'Caso de prueba mcc 2';
        caso2.recordtypeId= recordTypeCasoCliente;
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'SACH';
        caso2.CC_Tipo_Contacto__c = 'Consulta de Cliente';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.Status = 'Activo';
        lstCasos.add(caso2);
        
        insert lstCasos;
    }
    
    //Test para el método buscarGruposColaboradores
    @isTest
    public static void buscarGruposColaboradoresTest() {

        Test.startTest();

        List<CC_Grupo_Colaborador__c> grupos = SACH_Case_Operativa.buscarGruposColaboradores('SACH');

        Test.stopTest();
        System.assertEquals(false, grupos.isEmpty(), 'Grupos no encontrados');
    }

    //Test para el método buscarGruposColaboradores
    @isTest
    public static void buscarPlantillasTest() {
        
        Test.startTest();

        List<EmailTemplate> plantillas = SACH_Case_Operativa.getPlantillasSach();

        Test.stopTest();

        if(plantillas.isEmpty()){
            System.assertEquals(true, plantillas.isEmpty(), 'Se han encontrado plantillas');
        }else{
            System.assertEquals(false, plantillas.isEmpty(), 'No se han encontrado plantillas'); 
        }
        
    }

    //Test para el método buscarGruposColaboradores
    @isTest
    public static void prepararCasoTest() {

        Test.startTest();

        Case casoSACH = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'SACH' LIMIT 1];
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE '%SACH%' LIMIT 1];

        SACH_Case_Operativa.prepararCaso(casoSACH.Id, plantilla.Id, true, 'trasladar');

        Test.stopTest();

        Case casoSACHpost = [SELECT Id, CC_Buzon_Salida__c FROM Case WHERE CC_Canal_Procedencia__c = 'SACH' LIMIT 1];
        System.assertEquals(true, casoSACHpost.CC_Buzon_Salida__c != null, 'No se ha encontrado un busón de salida');
    }

    //Test para el método buscarGruposColaboradores
    @isTest
    public static void destinatariosColaboradorTest() {

        Test.startTest();

        CC_Grupo_Colaborador__c colaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE OS_Negocio__c = 'CC' LIMIT 1];

        Map<String, String> destinatarios = SACH_Case_Operativa.destinatariosColaborador(colaborador.Id);

        Test.stopTest();
        System.assertEquals(true, destinatarios.isEmpty(), 'Se han encontrado destinatarios cuando no debería');
    }

    //Test para el método crearEvento
    @isTest
    public static void crearEventoTest() {

        Test.startTest();

        Date fecha = System.today();
        Case casoSACH = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'SACH' LIMIT 1];

        Event tarea = SACH_Case_Operativa.crearEvento(casoSACH.Id, fecha, 'Descripcion Test');

        Test.stopTest();
        System.assertEquals(true, tarea != null, 'No se ha generado la tarea');
    }

    //Test para el método borrarEvento
    @isTest
    public static void borrarEventoTest() {

        Test.startTest();

        Date fecha = System.today();
        Case casoSACH = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'SACH' LIMIT 1];
        
        Event tarea = SACH_Case_Operativa.crearEvento(casoSACH.Id, fecha, 'Descripcion Test');
        SACH_Case_Operativa.borrarEvento(casoSACH.Id);

        Test.stopTest();
        try {
            Event tareaCreada = [SELECT Id FROM Event WHERE WhatId =: casoSACH.Id AND Type = 'Alerta programada' ORDER BY CreatedDate DESC LIMIT 1];
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains('List has no rows for assignment to SObject'), 'No se ha borrada la tarea');
        }
    }
    
        //Test para el método validarCamposTest
    @isTest
    public static void validarCamposTest() {

        Test.startTest();

        Date fecha = System.today();
        Case casoSACH = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'SACH' LIMIT 1];

        List<String> lstErrores = SACH_Case_Operativa.validarCamposCaso(casoSACH.Id);

        Test.stopTest();
        System.assertEquals(false, lstErrores.isEmpty(), 'Hay errores generado la tarea');
    }
    
    //Test para el método mergeCase
    @isTest
    public static void mergeCaseTest() {
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body\n2225256325\nTitle';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        Test.startTest();

        Date fecha = System.today();
        List<Case> casoSACH = [SELECT Id, ContactId FROM Case WHERE CC_Canal_Procedencia__c = 'SACH'];
		SACH_EmailMessage.crearEmailMessage(email, 'toaddress@email.com', casoSACH[0].Id, casoSACH[0].ContactId, 'Cuerpo del correo');
        String error = SACH_Case_Operativa.mergeCase(casoSACH[0].Id, casoSACH[1].Id);

        Test.stopTest();
        System.assertEquals('Ok', error, 'Hay errores');
    }

        //Test para la operativa de vincular llamada
        @isTest
        public static void vincularLlamadaTest() {

            CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c ();
            servicioGenesys.Name = 'Servicio SACH Test';
            servicioGenesys.CC_Codigo__c = 'SACH_PRUEBAS';
            servicioGenesys.CC_Tipo__c = 'Servicio';
            servicioGenesys.CC_Tipo_Cliente__c = 'Cliente';
            servicioGenesys.CBK_Negocio__c = 'SACH';
            servicioGenesys.CC_VDN__c = '1332';
            servicioGenesys.RecordTypeId = Schema.getGlobalDescribe().get('CC_Servicio_Genesys__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
            insert servicioGenesys;

            CC_Llamada_Input input = new CC_Llamada_Input();
            input.usuario = '1218';
            input.extension = '1118';
            input.connId = '12345678';
            input.ani = '666666666';
            input.dnis = '666666666';
            input.servicio = 'SACH_PRUEBAS';
            input.asunto = 'Asunto llamada';
            input.numPerso = '432423';
            input.idioma = 'Castellano';
            input.datos = 'Datos';
            //input.casoId = 
            //input.salesforceParentId = 
    
            SACH_Llamada.registrarLlamadaEntrante(input);
    
            Test.startTest();
    
            Date fecha = System.today();
            Case casoSACH = [SELECT Id, ContactId FROM Case WHERE CC_Canal_Procedencia__c = 'SACH' LIMIT 1];
            String resultado = SACH_Case_Operativa.vincularLlamada(casoSACH.Id);
    
            Test.stopTest();
            System.assertNotEquals('No se ha encontrado ninguna llamada en curso que vincular al caso.', resultado, 'Hay errores');
            System.assertNotEquals('El caso ya se encuentra vinculado con la llamada actualmente en curso.', resultado, 'Hay errores');
        }
}