@isTest
public with sharing class CC_GenerarDocumentoPlantilla_Apex_Test {
    
    @testSetup
    private static void testSetup() {
        
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        
        
        User usuario = new User();
        usuario.LastName = 'Gestor CC Test';
        usuario.Alias = 'gestor';
        usuario.Email = 'gestorcc@caixabank.com.invalid';
        usuario.Username = 'gestorcc_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        usuario.ProfileId = profileId;
        usuario.UserRoleId = rolCC.Id;
        usuario.EmailEncodingkey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocalesIdKey = 'es';
        usuario.TimezonesIdKey = 'Europe/Madrid';
        insert usuario;
        
        PermissionSet psCC = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        insert new PermissionSetAssignment(PermissionSetId = psCC.id, AssigneeId = usuario.Id);
        
        EmailTemplate plantillaDocumento = new EmailTemplate();
        plantillaDocumento.DeveloperName = 'CC_Test_Generar_Doc_' + System.now().getTime();
        plantillaDocumento.Name = 'plantillaPdf';
        plantillaDocumento.TemplateType = 'custom';
        plantillaDocumento.FolderId = usuario.Id;
        plantillaDocumento.isActive = true;
        plantillaDocumento.Body = 'cuerpo';
        plantillaDocumento.HtmlValue = '<html><body>cuerpo</body></html>';
        System.runAs(usuario) {
            insert plantillaDocumento;
        }
        
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        
                User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = rolCC.Id;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;


        System.runAs(usuarioAdmin)
        {
        
        
        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test2',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test2',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test2',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Link__c = 'https://test.com',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;
        
        //Comprobamos en el caso de que haya alguna plantilla asociada
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Id = :plantillaDocumento.Id LIMIT 1];
        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = tematica.Id,
            CC_MCC_Plantilla_Name__c = plantilla.Name,
            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName
        );
        insert mccPlantilla;
        
        
            Case caso = new Case(
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
                Origin = 'Email',
                Status = 'Activo',
                CC_MCC_Tematica__c = tematica.Id,
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivo.Id,
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                OwnerId = usuario.Id,
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Canal_Procedencia__c = 'Formulario web',
                Subject = 'Prueba Gestor Documento',
                Description = 'Prueba'
            );
            insert caso;
            
            String recordId = caso.Id;
            String docId = '';
            String idioma = 'es';
            String sexo = '';
            String cambioficina = '';
            String faltaentrega = '';
            String espera = '';
            String respuestacliente = '';
            String contestarrespuestacliente = '';
            String bloqueoretencionsaldo = '';
            Boolean solicitudcancelacionseguro = false;
            Boolean solicitudtestamentaria = false;
            Boolean cuadroamortizacion = false;
            Boolean partedocumentacion = false;
            Boolean documentacionadicional = false;
            Boolean documentacionnolocalizada = false;
            Boolean usuarioNow = false;
            String detalleinformacionenviar = '';        
            String helloletter = '';
            String codigoprestamo = '';
            Date fechafinalcalculo =  Date.newInstance(2020, 2, 17);
            String cuentaminombre = '';
            String solicitud = '';
            String movimientoCuenta = '';
            Boolean contactocliente = false;
            Boolean irrespetuoso = false;
            String informaciondocumentacionadicional = '';
            String fraude = '';
            String solicitudDocumentacion = '';
            Boolean allinone = false;
            String indicargastos = 'contrato';
            
            Map<String, Boolean> camposBoleanos = new Map<String, Boolean>();
            Map<String, String> camposTexto = new Map<String, String>();
            camposBoleanos.put('documentacionnolocalizadacliente', false);
            camposBoleanos.put('tasacioninmueblehipotecado', false);
            camposBoleanos.put('prestamotitulizado', false);
            camposBoleanos.put('prestamovendidotercero', false);
            camposBoleanos.put('solicitudfacturasgastos', false);
            camposBoleanos.put('contratotarjetacliente', false);
            camposBoleanos.put('extractosliquidacion', false);
            camposBoleanos.put('copiaparcialescritura', false);
            camposBoleanos.put('nolocalizacontratocuenta', false); 
            camposBoleanos.put('quejacobrotarifatelefonica', false); 
            camposBoleanos.put('solicitudinfoprestamo', false); 
            camposBoleanos.put('quejalimpieza', false); 
            camposBoleanos.put('quejapersonasinhogar', false); 
            camposBoleanos.put('solicitudinformacionrequisitos', false); 
            camposBoleanos.put('solicitudinformacionaportar', false); 
            camposBoleanos.put('informacioncondicionesfinanciacion', false); 
            camposBoleanos.put('ofreciosolucionesrefinanciacion', false);  
            camposBoleanos.put('cierrerecintocajero', false); 
            camposBoleanos.put('solicitudcancelacioncontratos', false); 
            camposBoleanos.put('intervencionFuerzasSeguridad', false); 
            
            camposTexto.put('indicargastos', indicargastos);        
            
            
            //Caso sin gestor documental
            GestorDocumentalController.generaDocumento(recordId, docId, idioma, sexo, cambioficina, faltaentrega, espera, 
                                                       contactocliente, allinone, irrespetuoso, fraude, movimientoCuenta, usuarioNow, cuentaminombre,
                                                       respuestacliente, contestarrespuestacliente, bloqueoretencionsaldo, solicitudcancelacionseguro, solicitudtestamentaria,
                                                       solicitud, solicitudDocumentacion, informaciondocumentacionadicional, helloletter, codigoprestamo, fechafinalcalculo,
                                                       cuadroamortizacion, partedocumentacion, documentacionadicional, documentacionnolocalizada,
                                                       detalleinformacionenviar, camposBoleanos, camposTexto);      
            
            //Actualizar caso con gestor documental
            caso = [SELECT CC_Gestor_Documental__c FROM CASE WHERE Id = :caso.Id];
            docId = caso.CC_Gestor_Documental__c;
            
            GestorDocumentalController.generaDocumento(recordId, docId, idioma, sexo, cambioficina, faltaentrega, espera, 
                                                       contactocliente, allinone, irrespetuoso, fraude, movimientoCuenta, usuarioNow, cuentaminombre,
                                                       respuestacliente, contestarrespuestacliente, bloqueoretencionsaldo, solicitudcancelacionseguro, solicitudtestamentaria,
                                                       solicitud, solicitudDocumentacion, informaciondocumentacionadicional, helloletter, codigoprestamo, fechafinalcalculo,
                                                       cuadroamortizacion, partedocumentacion, documentacionadicional, documentacionnolocalizada,
                                                       detalleinformacionenviar, camposBoleanos, camposTexto);       
            
            
            
            
            
        }             
        
        
    }
    
    @isTest
    public static void verCarpetaInicial() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            Map<String, Object> retorno = CC_GenerarDocumentoPlantilla_Apex.verCarpetaInicial('carpetaDeveloperName');
            Test.stopTest();
            
            System.assertEquals(3, retorno.size(), 'El mapa retornado debería tener 3 claves');
        }
    }
    
    @isTest
    public static void verCarpeta() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            Map<String, Object> retorno = CC_GenerarDocumentoPlantilla_Apex.verCarpeta(usuario.id);
            Test.stopTest();
            
            System.assertEquals(3, retorno.size(), 'El mapa retornado debería tener 3 claves');
        }
    }
    
     @isTest
    public static void cargarPlantillasMCC() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
        System.runAs(usuario) {
            Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Prueba Gestor Documento' LIMIT 1];
            
            EmailTemplate plantillaPdf = [SELECT Id FROM EmailTemplate WHERE Name = 'plantillaPdf'];
            Test.startTest();
            List<EmailTemplate> plantillas = CC_GenerarDocumentoPlantilla_Apex.cargarPlantillasMCC(caso.Id);
            Test.stopTest();
            
            System.assert(plantillas.size()>0, true);
        }
    }
    
    
    
    
    @isTest
    public static void cuerpoPlantilla() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
        System.runAs(usuario) {
            Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Prueba Gestor Documento' LIMIT 1];
            
            EmailTemplate plantillaPdf = [SELECT Id FROM EmailTemplate WHERE Name = 'plantillaPdf'];
            Test.startTest();
            String cuerpoPlantilla = CC_GenerarDocumentoPlantilla_Apex.cuerpoPlantilla(plantillaPdf.Id, caso.Id);
            Test.stopTest();
            
            System.assertNotEquals(null, cuerpoPlantilla, 'cuerpoPlantilla should not be null');
        }
    }
    
    @isTest
    public static void buscarPlantillas() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            List<EmailTemplate> resultado = CC_GenerarDocumentoPlantilla_Apex.buscarPlantillas(usuario.id, 'cadena_búsqueda');
            Test.stopTest();
            
            System.assertNotEquals(null, resultado, 'resultado should not be null');
        }
    }
    
    @isTest
    static void obtenerDatosTemplateTest(){
        User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
       
        CC_GenerarDocumentoPlantilla_Apex.WrapperTemplate infoTemplate; 
        System.runAs(usuario) {
            //Map<String, Object> campos = new Map<String, Object>{'CSBD_GenerarDocumentoHtml__c' => '<p>hola&nbsp;OP-344833701 - 2</p>'};
            //Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
            Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Prueba Gestor Documento' LIMIT 1];
            
            EmailTemplate plantillaPdf = [SELECT Id FROM EmailTemplate WHERE Name = 'plantillaPdf'];
            Test.startTest();
            infoTemplate = CC_GenerarDocumentoPlantilla_Apex.obtenerDatosTemplate(plantillaPdf.Id, caso.Id);
            Test.stopTest();
            
            Assert.areNotEqual(null, infoTemplate, 'Ha fallado la obtención de datos de la plantilla');
        }
    }
    
    
}