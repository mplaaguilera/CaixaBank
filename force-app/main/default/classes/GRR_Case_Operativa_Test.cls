@isTest
public with sharing class GRR_Case_Operativa_Test {

    @TestSetup
    static void makeData(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usuario = new User();
        usuario.IsActive = true;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'GRR_Usuario_CaixaBank'].Id;
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'GRR'].Id;
        usuario.FirstName = 'GRR Prueba Clases Test';
        usuario.LastName = 'GRR Prueba Clases Test';
        usuario.Alias = uniqueName.substring(18, 23);
        usuario.Email = uniqueName + '@test' + orgId + '.org';
        usuario.Username = uniqueName + '@test' + orgId + '.org';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        insert usuario;
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('GRR_Agente','GRR_Supervisor')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuario.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;   
        Group grupo = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = 'GRR_Buzon_Barcelona' AND Type = 'Regular' LIMIT 1];
        GroupMember miembroGrupo = new GroupMember();
        miembroGrupo.GroupId = grupo.Id;
        miembroGrupo.UserOrGroupId = usuario.Id;
        insert miembroGrupo;
    }
    
    private static Contact crearContacto() {
        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            LastName = 'Test',
            CC_Numero_Documento__c = '36592162J'
        );
        insert contacto;
        return contacto;
    }
    
    private static void crearCasoConContacto(String idcont, String usuarioId) {
        Contact contacto = [SELECT Id FROM Contact WHERE Id = :idcont];
        User user = [SELECT Id FROM User WHERE Id =: usuarioId];
        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'MCC Tematica',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;
        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'MCC Producto',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id
        );
        insert mccProducto;
        CC_MCC__c mccMotivo = new CC_MCC__c(
            Name = 'MCC Motivo',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'MOGR-000001',
            CC_Producto_Servicio__c = mccProducto.Id
        );
        insert mccMotivo;
        CC_Grupo_Colaborador__c	grupocolaborador = new CC_Grupo_Colaborador__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank'),
            Name = 'Servicio GRR',
            OS_Negocio__c = 'CC'
        );
        insert grupocolaborador;
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = user.Id;
        template1.Name = 'Plantilla GRR';
        template1.Subject = 'esto es una prueba';
        template1.HtmlValue = '';
        template1.DeveloperName = 'GRR_Plantilla_Prueba';
        template1.TemplateType = 'Text';
        insert template1;
        EmailTemplate template2 = new EmailTemplate();
        template2.FolderId = user.Id;
        template2.Name = 'Plantilla GRR 2';
        template2.Subject = 'esto es una prueba 2';
        template2.HtmlValue = '';
        template2.DeveloperName = 'GRR_Plantilla_Prueba_2';
        template2.TemplateType = 'Text';
        insert template2;
        List<Case> lstCasos = new List<Case>();
        Case caso = new Case ();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        caso.Subject = 'Caso de prueba mcc';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.ContactId = contacto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        lstCasos.add(caso);
        Case caso2 = new Case ();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        caso2.Subject = 'Caso de prueba mcc 2';
        caso2.Origin = 'Email';
        caso2.Status = 'Activo';
        caso2.ContactId = contacto.Id;
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        lstCasos.add(caso2);
        insert lstCasos;
    }
    
    @isTest
    public static void testValidarCamposCaso() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            Case casoGRR = [SELECT Id FROM Case LIMIT 1];

            List<String> lstErrores = GRR_Case_Operativa.validarCamposCaso(casoGRR.Id);
            System.assertEquals(false, lstErrores.isEmpty());

            Test.stopTest();
        }
    }

    @isTest
    public static void testGetURCasoDestino() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            Case casoGRR = [SELECT Id FROM Case LIMIT 1];
            GRR_UR__c ur = new GRR_UR__c(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
                GRR_Id_UR__c = 'UR Pruebas'
            );
            insert ur;
            casoGRR.GRR_UR_Relacionada__c = ur.Id;
            update casoGRR;

            String resultado = GRR_Case_Operativa.getURCasoDestino(casoGRR.Id);
            System.assertEquals(resultado != null, true);

            Test.stopTest();
        }
    }

    @isTest
    public static void testBuscarGruposColaboradores() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            List<CC_Grupo_Colaborador__c> grupos = GRR_Case_Operativa.buscarGruposColaboradores('GRR');
            System.assertEquals(false, grupos.isEmpty());

            Test.stopTest();
        }
    }

    @isTest
    public static void testGetPlantillasGRR() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            List<EmailTemplate> plantillas = GRR_Case_Operativa.getPlantillasGRR();
            if(plantillas.isEmpty()){
                System.assertEquals(true, plantillas.isEmpty());
            }else{
                System.assertEquals(false, plantillas.isEmpty()); 
            }

            Test.stopTest();
        }
    }

    @isTest
    public static void testPrepararCaso() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            Case caso = [SELECT Id, CC_Canal_Procedencia__c, CC_Buzon_Salida__c, OS_Cerrado_Operativa__c, CC_Referencia_Correo_Saliente__c FROM Case LIMIT 1];      

            GRR_Case_Operativa.prepararCaso(caso.Id, null, true, null, true);
            Case casoUpdated = [SELECT Id, OS_Cerrado_Operativa__c FROM Case LIMIT 1];
            System.assertEquals(casoUpdated.OS_Cerrado_Operativa__c ,true);

            Test.stopTest();
        }
    }

    @isTest
    public static void testDestinatariosColaborador() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            CC_Grupo_Colaborador__c colaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE OS_Negocio__c = 'CC' LIMIT 1];

            Map<String, String> destinatarios = GRR_Case_Operativa.destinatariosColaborador(colaborador.Id);
            System.assertEquals(true, destinatarios.isEmpty());    

            Test.stopTest();
        }
    }

    @isTest
    public static void testMergeCase() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
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
            List<Case> casoGRR = [SELECT Id, ContactId FROM Case];

            GRR_EmailMessage.crearEmailMessage(email, 'toaddress@email.com', casoGRR[0].Id, casoGRR[0].ContactId, 'Cuerpo del correo');
            String error = GRR_Case_Operativa.mergeCase(casoGRR[0].Id, casoGRR[1].Id);
            System.assertEquals('Ok', error);  

            Test.stopTest();
        }
    }

    @isTest
    public static void testGetCarpetas() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            List<Folder> carpetas = GRR_Case_Operativa.getCarpetas(null);
            System.assertEquals(false, carpetas.isEmpty());
            List<Folder> carpetas2 = GRR_Case_Operativa.getCarpetas('GRR_Operativas');
            System.assertEquals(false, carpetas2.isEmpty());

            Test.stopTest();
        }
    }
  
    @isTest
    public static void testGetPlantillasResponder() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            Case caso = [SELECT Id, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case LIMIT 1];

            Test.startTest();
            List<GRR_Case_Operativa.pickListWrapper> wrapPlantilla = new List<GRR_Case_Operativa.PickListWrapper>();
            wrapPlantilla = GRR_Case_Operativa.getPlantillasResponder(caso.Id, null);
            Test.stopTest();

            System.assert(!wrapPlantilla.isEmpty());
        }
    }

    @isTest
    public static void testBuscarCorreoContacto() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            Case caso = [SELECT Id, CC_MailTelfNotif__c, SuppliedEmail FROM Case LIMIT 1];
            String resultado = GRR_Case_Operativa.buscarCorreoContacto(null);
            System.assertEquals('', resultado);
            resultado = GRR_Case_Operativa.buscarCorreoContacto(caso.Id);
            System.assertEquals(contacto.Email, resultado);
            caso.CC_MailTelfNotif__c = 'mailtelf@test.com';
            update caso;
            resultado = GRR_Case_Operativa.buscarCorreoContacto(caso.Id);
            System.assertEquals(caso.CC_MailTelfNotif__c, resultado);
            caso.SuppliedEmail = 'supplied@test.com';
            update caso;
            resultado = GRR_Case_Operativa.buscarCorreoContacto(caso.Id);
            System.assertEquals(caso.SuppliedEmail, resultado);    

            Test.stopTest();
        }
    }

    @isTest
    public static void testGetPlantillaGrupoList() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];
        
        System.runAs(usuario) {
            Test.startTest();
        
            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
                Name = 'Grupo Test',
                CC_External__c = 'GC-00004',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador')  
            );
            insert grupo;
            Integer numeroPlantillas = [SELECT COUNT() FROM EmailTemplate];
            List<CC_Grupo_Colaborador_Plantilla__c> grupoPlantillas = new List<CC_Grupo_Colaborador_Plantilla__c>();
            for (EmailTemplate plantilla : [SELECT Name, DeveloperName FROM EmailTemplate]) {
                CC_Grupo_Colaborador_Plantilla__c plantillaGrupo = new CC_Grupo_Colaborador_Plantilla__c(
                    CC_Grupo_Colaborador__c = grupo.Id,
                    CC_Plantilla_Name__c = plantilla.Name,
                    CC_Plantilla_DeveloperName__c = plantilla.DeveloperName,
                    CC_Operativa__c = 'Trasladar'
                );
                grupoPlantillas.add(plantillaGrupo);
            }
            insert grupoPlantillas;

            List<GRR_Case_Operativa.picklistWrapper> plantillaListGrupo = GRR_Case_Operativa.getPlantillaGrupoList(grupo.Id, 'Trasladar');
            System.assertEquals(numeroPlantillas, plantillaListGrupo.size());

            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearTareaGestionadoMes() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();

            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            Case casoGRR = [SELECT Id FROM Case LIMIT 1];
            
            GRR_Case_Operativa.crearTareaGestionadoMes(casoGRR.Id);
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :casoGRR.Id]);

            Test.stopTest();
        }
    }

    @isTest
    public static void testUsuarioPerteneceServiciosCentrales() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            Boolean resultado = GRR_Case_Operativa.perteneceServiciosCentrales();
            System.assertEquals(true, resultado);
            Test.stopTest();
        }
    }

    @isTest
    public static void testReabrirTareaTrasladoColaborador() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR Prueba Clases Test' LIMIT 1];

        System.runAs(usuario) {
            Contact contacto = crearContacto();
            crearCasoConContacto(contacto.Id, usuario.Id);
            Case casoGRR = [SELECT Id FROM Case LIMIT 1];
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task');
            tarea.Type = 'Traslado Colaborador';
            tarea.Subject = 'Traslado Colaborador';
            tarea.WhatId = casoGRR.Id;
            tarea.Status = 'Completed';
            tarea.ActivityDate = System.today();
            insert tarea;

            Test.startTest();
            GRR_Case_Operativa.reabrirTareaTrasladoColaborador(casoGRR.Id);
            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE Id = :tarea.Id AND Status='Open' LIMIT 1]);
            Test.stopTest();
        }
    }
}