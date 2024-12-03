@IsTest
public class SEG_EmailService_Test{

    private static EmailServicesAddress headerValue = new EmailServicesAddress();
    
    @TestSetup
    public static void crearDatosPrueba() 
    {
        Test.startTest();
        Id recordTypeSeg = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        User thisUser;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
                UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
                thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                    emailencodingkey='UTF-8', lastname='Smith',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='testSEGBI@acme.com');
                insert thisUser;
                List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
                for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                    PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                    nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                    nuevoPermiso.AssigneeId = thisUser.id;
                    listPermissionSetAssignment.add(nuevoPermiso);
                }
                if (listPermissionSetAssignment.isEmpty()){
                    insert listPermissionSetAssignment;
                }
        }

        Account acc = SEG_TestHelper.createCustomer();
        list<case> lstCase = new list<Case>();
        
        //Case caso1 = SEG_TestHelper.createCase1();
        //Case caso2 = SEG_TestHelper.createCase2();
        Case caso1 = new Case(
                SEG_SemillaId__C = '#@SEG:1611676158418#',
                SEG_Zona__c ='Corporativa',
                SEG_Organizacion__C='Banca Corporativa',
            	Description = 'Descripción caso 1',
            	Subject = 'Subject caso 1',
                RecordTypeId = recordTypeSeg
			);
        lstCase.add(caso1);

        Case caso2 = new Case(
                SEG_SemillaId__C = '#@SEG:1610540342877#',
                SEG_Zona__c ='Corporativa',
                SEG_Organizacion__C='Banca Corporativa',
          		Description = 'Descripción caso 1',
            	Subject = 'Subject caso 2',
                RecordTypeId = recordTypeSeg
			);
        lstCase.add(caso2);
		insert lstCase;

        SEG_Buzon__mdt buzon = SEG_TestHelper.createBuzon();
        Contact cont = SEG_TestHelper.createCustomerContact(acc.Id,'jslasnd_TEST@gmail.com');

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11141211H';
        insert cuentaSEG1;

        Contact contacto = new Contact();
        contacto.email = 'jslasnd_TEST@gmail.com';
        contacto.LastName = 'Paco';
        contacto.AccountId = cuentaSEG1.Id;
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert contacto;

        Contact contacto2 = new Contact();
        contacto2.email = 'jslasnd_TEST@gmail.com';
        contacto2.LastName = 'PacoD';
        contacto2.AccountId = cuentaSEG1.Id;
        contacto2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        insert contacto2;

        CC_Canal_Com__c canal = new CC_Canal_Com__c();
        canal.RecordTypeId=Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canal.CC_ContactoId__c=cont.id;
        canal.CC_Email__c='invalida_canal_comunicacion@gmail.com';
        canal.SEG_ParaCC__c = 'Para';
        insert canal;
		Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		List<CC_Grupo_Colaborador__c> lstGrupoColaborador = new List<CC_Grupo_Colaborador__c> ();

		//Gestor Operativa Nacional
		CC_Grupo_Colaborador__c grupoGestorOperativaNacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaNacional.Name = 'Gestor Operativa Nacional';
		grupoGestorOperativaNacional.RecordTypeId = autoSegId;
		lstGrupoColaborador.add(grupoGestorOperativaNacional);

		//Gestor Operativa Internacional
		CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
		grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
		lstGrupoColaborador.add(grupoGestorOperativaInternacional);
		insert lstGrupoColaborador;

		Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
		Id recordTexto = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();

		List<SEG_Excepciones__c> lstEx = new List<SEG_Excepciones__c>();
		SEG_Excepciones__c excepcion = new SEG_Excepciones__c();
		excepcion.RecordTypeId = recordAsig;
		excepcion.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion.SEG_Zona__c = 'Corporativa';
		excepcion.SEG_Grupoasignado__c = grupoGestorOperativaInternacional.Id;
		lstEx.add(excepcion);

		SEG_Excepciones__c excepcion2 = new SEG_Excepciones__c();
		excepcion2.RecordTypeId = recordAsig;
		excepcion2.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion2.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion2.SEG_Zona__c = 'Corporativa';
		excepcion2.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion2);

		SEG_Excepciones__c excepcion3 = new SEG_Excepciones__c();
		excepcion3.RecordTypeId = recordTexto;
		excepcion3.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion3.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion3.SEG_Zona__c = 'Corporativa';
		excepcion3.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion3);

		insert lstEx;

		Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
		mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
		mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccTematica.RecordTypeId = recordTypeIdTematica;
		mccTematica.CC_Codigo_Externo__c = 'TE-000001';
		insert mccTematica;

		Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c mccProducto = new CC_MCC__c();
		mccProducto.Name = 'Producto1';
		mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
		mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccProducto.RecordTypeId = recordTypeIdProducto;
		mccProducto.CC_Tematica__c = mccTematica.Id;
		mccProducto.CC_Codigo_Externo__c = 'PR-000001';
		insert mccProducto;

		Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		CC_MCC__c mccMotivo = new CC_MCC__c();
		mccMotivo.Name = 'Motivo1';
		mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
		mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccMotivo.RecordTypeId = recordTypeIdMotivo;
		mccMotivo.CC_Tematica__c = mccTematica.Id;
		mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
		mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
		insert mccMotivo;

		Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
		CC_MCC__c mccDetalle = new CC_MCC__c();
		mccDetalle.Name = 'Detalle1';
		mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
		mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccDetalle.RecordTypeId = recordTypeIdDetalle;
		mccDetalle.CC_Tematica__c = mccTematica.Id;
		mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
		mccDetalle.CC_Motivo__c = mccMotivo.Id;
		mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
		insert mccDetalle;

		SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c();
		clasRapida.Name = 'CR1';
        clasRapida.CBK_Negocio__c = 'Segmentos';
        clasRapida.SEG_Inactiva__c = false;
		clasRapida.SEG_Tematica__c = mccTematica.Id;
		clasRapida.SEG_Producto__c = mccProducto.Id;
		clasRapida.SEG_Motivo__c = mccMotivo.Id;
		clasRapida.SEG_Detalle__c = mccDetalle.Id;
		insert clasRapida;

        List<Account> lstAccount = new List<Account>();
		Account centro = new Account();
		centro.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		centro.Name = 'Oficina 00001';

		centro.CC_Numero_Oficina_Empresa__c = '001-00001';
		//centro.SEG_Organizacion__c = 'Banca Corporativa';
		//centro.SEG_Zona__c = 'Corporativa';
		lstAccount.add(centro);

		Account grupoEmpresa = new Account();
		grupoEmpresa.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		grupoEmpresa.Name = 'Oficina 00003';
		grupoEmpresa.CC_Numero_Oficina_Empresa__c = '001-00003';
		//grupoEmpresa.SEG_Organizacion__c = 'Banca Corporativa';
		//grupoEmpresa.SEG_Zona__c = 'Corporativa';
		grupoEmpresa.CC_Numero_Documento__c = '33333333H';
		lstAccount.add(grupoEmpresa);

        Account cuentaident = new Account();
		cuentaident.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		cuentaident.Name = 'Oficina 12456';
		cuentaident.CC_Numero_Oficina_Empresa__c = '001-00098';
		//grupoEmpresa.SEG_Organizacion__c = 'Banca Corporativa';
		//grupoEmpresa.SEG_Zona__c = 'Corporativa';
		cuentaident.CC_Numero_Documento__c = 'Y24558798';
		lstAccount.add(cuentaident);

        Account cuentaident2 = new Account();
		cuentaident2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		cuentaident2.Name = 'Oficina 12484';
		cuentaident2.CC_Numero_Oficina_Empresa__c = '001-00453';
		//grupoEmpresa.SEG_Organizacion__c = 'Banca Corporativa';
		//grupoEmpresa.SEG_Zona__c = 'Corporativa';
		cuentaident2.CC_Numero_Documento__c = 'Y2455879M';
		lstAccount.add(cuentaident2);

		Account empresaSEG = new Account();
		empresaSEG.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		empresaSEG.Name = 'Empresa segmentos';
		empresaSEG.SEG_DominioMail__c = '@cuentaSEG';
		//empresaSEG.SEG_Organizacion__c = 'Banca Corporativa';
		//empresaSEG.SEG_Zona__c = 'Corporativa';
		empresaSEG.CC_Numero_Documento__c = '11111111H';
		empresaSEG.ParentId = grupoEmpresa.Id;
		empresaSEG.SEG_Oficina_Gestora_Segmentos__c = centro.Id;
		lstAccount.add(empresaSEG);
        insert lstAccount;

		//Excepciones       
		List<SEG_Excepciones_Centro__c> lstExCentro = new List<SEG_Excepciones_Centro__c>();
		SEG_Excepciones_Centro__c exCentro = new SEG_Excepciones_Centro__c();
		exCentro.SEG_Excepciones__c = excepcion.id;
		exCentro.SEG_CentroEmpresa__c = centro.id;
		exCentro.SEG_Activo__c = true;
		lstExCentro.add(exCentro);

		SEG_Excepciones_Centro__c exCentro3 = new SEG_Excepciones_Centro__c();
		exCentro3.SEG_Excepciones__c = excepcion3.id;
		exCentro3.SEG_CentroEmpresa__c = centro.id;
		exCentro3.SEG_Activo__c = true;
		lstExCentro.add(exCentro3);
		insert lstExCentro;

		List<SEG_Excepciones_Grupo_Empresa__c> lstExGrupoEmpresa = new List<SEG_Excepciones_Grupo_Empresa__c>();
		SEG_Excepciones_Grupo_Empresa__c exGrupoEmpresa = new SEG_Excepciones_Grupo_Empresa__c();
		exGrupoEmpresa.SEG_Excepciones__c = excepcion.id;
		exGrupoEmpresa.SEG_GrupoEmpresa__c = grupoEmpresa.id;
		exGrupoEmpresa.SEG_Activo__c = true;
		lstExGrupoEmpresa.add(exGrupoEmpresa);

		List<SEG_Excepciones_Empresa__c> lstExEmpresa = new List<SEG_Excepciones_Empresa__c>();
		SEG_Excepciones_Empresa__c exEmpresa = new SEG_Excepciones_Empresa__c();
		exEmpresa.SEG_Excepciones__c = excepcion.id;
		exEmpresa.Empresa__c = empresaSEG.id;
		exEmpresa.SEG_Activo__c = true;
		lstExEmpresa.add(exEmpresa);

		List<SEG_Excepciones_CR__c> lstExCR = new List<SEG_Excepciones_CR__c>();
		SEG_Excepciones_CR__c exCR = new SEG_Excepciones_CR__c();
		exCR.SEG_Excepciones__c = excepcion.id;
		exCR.SEG_ClasificacionRapida__c = clasRapida.id;
		exCR.SEG_Activo__c = true;
		lstExCR.add(exCR);

		// Crear contactos para cuentas SEG.
		Contact contactoSEG1 = new Contact();
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contactoSEG1.LastName = 'Contacto SEG 1';
		contactoSEG1.AccountId = empresaSEG.Id;
		contactoSEG1.Email = 'test@test.com';
		insert contactoSEG1;

		EmailTemplate emailEs = new EmailTemplate();
        emailEs.DeveloperName='Reclamacion_1_1616749645917';
        emailEs.Encoding = 'ISO-8859-1';
        emailEs.FolderId = thisUser.Id;
        emailEs.Subject = '[num_casos]';
        emailEs.IsActive = true;
        emailEs.Name = 'Reclamacion 1º';
        emailEs.TemplateType = 'custom';
        emailEs.TemplateStyle = 'none';
        emailEs.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
         System.runAs (thisUser) {
            insert emailEs;
        }

        SEG_Plantilla__c plantilla = new  SEG_Plantilla__c();
        plantilla.Name =  'Acuse de recibo';
        plantilla.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
        plantilla.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Instituciones Este';
        plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
        plantilla.SEG_Activa__c = true;
        plantilla.SEG_PlantillaCastellano__c='Firma BO';
        plantilla.SEG_PlantillaCatalan__c ='Firma CAT'; 
        plantilla.SEG_PlantillaIngles__c = 'Firma IN';
        plantilla.SEG_PlantillaEuskera__c = 'Firma EUSK';
        plantilla.SEG_PlantillaGalego__c = 'Firma GAL';
        plantilla.SEG_PlantillaCastellanoID__c = emailEs.Id;
        insert plantilla;

        headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        Test.stopTest();
    }
   
    @IsTest
    public static void identificarCIF(){
       
        
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        String texto = 'N3633607A';
        System.runAs (usuarioTest) {
            Test.startTest();
                    String result = SEG_EmailService.identificarCIF(texto);
            Test.stopTest();
             System.assertEquals(result,texto,'Se ha encontrado el NIF');
        }
    }

    @IsTest
    public static void nuevoHtml(){
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        //Crear un InboundEnvelope e InboundEmail de entrada
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'Error en la contratación';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.htmlBody = 'He tenido un error en la contratación #@SEG:1610473621456#';
        
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1};
        
        System.runAs (usuarioTest) {
            Test.startTest();
                SEG_EmailService emailServiceSEG = new SEG_EmailService();
                Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assert( header.value != null,'El resultado ha sido el correcto');
        }   
    }

    @IsTest
    public static void respuestaHtml() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String ccRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
         
        Account acc = [SELECT id, RecordTypeId FROM Account Limit 1];
        acc.RecordTypeId = ccRT;
        update acc;
                     
        //Crear un InboundEnvelope e InboundEmail de entrada
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = '03928257';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.htmlBody = 'email body\n#@SEG:1610385724410#\n#@SEG:1610473621456# 03928088';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1};

        SEG_EmailService emailServiceSEG = new SEG_EmailService();

        System.runAs (usuarioTest) {
            Test.startTest();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assert(header.value != null,'El resultado ha sido el correcto');
        }
                             
     }
     @IsTest
     public static void respuestaPlaintText() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
         
        //Crear un InboundEnvelope e InboundEmail de entrada
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = '#@SEG:1610540342877# asd 03928257 asd 03928234';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = '#@SEG:1611676158418#';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        
        SEG_EmailService emailServiceSEG = new SEG_EmailService();
        System.runAs (usuarioTest) {
            Test.startTest();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assert(header.value != null,'El resultado ha sido el correcto');
        }
    }
    
    @IsTest
    public static void respuestaPlaintText2() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'PacoD' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c LIMIT 1];

        CC_Grupo_Colaborador_Contact__c grupoColab = new CC_Grupo_Colaborador_Contact__c();
        grupoColab.CC_Contacto__c = cont.Id; //jslasnd_TEST@gmail.com
        grupoColab.CC_Grupo_Colaborador__c = grupo.Id;
        insert grupoColab;

        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = '#@SEG:1610540342877# asd 03928257 asd 03928234';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = '#@SEG:1611676158418#';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assert(header.value != null,'El resultado ha sido el correcto');
        }
    }
    
    @IsTest
    public static void multipleCaseNumbers() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asd 04030904 asd 04030905';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'test case numbers';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');
        }
     }
     @IsTest
     public static void testEmail0() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        String ccRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            
        Account acc = [SELECT id, RecordTypeId FROM Account Limit 1];
        acc.RecordTypeId = ccRT;
        update acc;
            
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'VFR_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromAddress = 'VFR_TEST@gmail.com';
        correo.fromname = 'FirstName1 LastName1';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');     
        }  
    }
    @IsTest
    public static void testEmail1() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        String ccRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            
        Account acc = [SELECT id, RecordTypeId FROM Account Limit 1];
        acc.RecordTypeId = ccRT;
        update acc;
                        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');
        }
    }
    @IsTest
    public static void testEmail2() {


        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'sin_contacto_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'sin_contacto_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};

        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');
        }
    }

    @IsTest
    public static void testEmail3() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        Contact contactoExtra = [Select id FROM Contact WHERE FirstName = 'Contacto Cliente'];
        delete contactoExtra;

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};
 
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};
 
        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');   
        }              
     }

     @IsTest
     public static void testEmail4() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa segmentos2';
        cuentaSEG2.SEG_DominioMail__c = '@cuenta2SEG';
        cuentaSEG2.CC_Numero_Documento__c = '11241211H';
        insert cuentaSEG2;

        Contact contactoExtra = [Select id FROM Contact WHERE FirstName = 'Contacto Cliente'];
        delete contactoExtra;
 
         //Crear un InboundEnvelope e InboundEmail de entrada
         Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
         Messaging.InboundEmail correo = new Messaging.InboundEmail();
         Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
         header.value = headerValueStr;
         header.name = 'X-SFDC-Original-RCPT';
         envelope.fromAddress = 'jslasnd_TEST@gmail.com';
         envelope.toAddress = 'tiha.invalidad@invalid.com';
         correo.subject = 'TESTCATCHMETHOD';
         correo.fromName='Nombre Apellido1 Apellido 2';
         correo.fromAddress = 'jslasnd_TEST@gmail.com';
         correo.plainTextBody = 'email body\n2225256325\nTitle';
         correo.headers = new List<Messaging.InboundEmail.Header>{header};
         //Adjuntos binarios
         Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
         adjuntoBinario1.body = blob.valueOf('my attachment text');
         adjuntoBinario1.fileName = 'textfileone.txt';
         adjuntoBinario1.mimeTypeSubType = 'text/plain';
         adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};
  
         Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
         adjuntoBinario2.body = blob.valueOf('my attachment text 2');
         adjuntoBinario2.fileName = 'text2fileone.txt';
         adjuntoBinario2.mimeTypeSubType = 'text/plain';
         
         correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
         
         //Adjunto de texto
         Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
         adjuntoTexto.body = 'my attachment text';
         adjuntoTexto.fileName = 'textfiletwo3.txt';
         adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
         correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};
  
         System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);   
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');   
         }           
    }

    @IsTest
    public static void identificarEmailSalienteTest1() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'Subject caso 1'];
        List<Contact> lstcontacto = [SELECT Id FROM Contact WHERE Email = 'jslasnd_TEST@gmail.com'];
        for (Contact contacto : lstcontacto) {
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        }
        update lstcontacto;

        System.runAs (usuarioTest) {
            Test.startTest();
                    List<String> result = SEG_EmailService.identificarEmailSaliente('jslasnd_TEST@gmail.com', caso);
            Test.stopTest();
            System.assert(caso != null,'ok');
        }
    }

    @IsTest
    public static void identificarEmailSalienteTest2() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'Subject caso 1'];
        List<Contact> lstcontacto = [SELECT Id FROM Contact WHERE Email = 'jslasnd_TEST@gmail.com'];
        for (Contact contacto : lstcontacto) {
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        }
        update lstcontacto;

        System.runAs (usuarioTest) {
            Test.startTest();
                    List<String> result = SEG_EmailService.identificarEmailSaliente('jslasnd_TEST@gmail.com', caso);
            Test.stopTest();
            System.assert(caso != null,'ok');
        }
    }

    @IsTest
    public static void identificarEmailSalienteTest3() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'Subject caso 1'];
        List<Contact> lstcontacto = [SELECT Id FROM Contact WHERE Email = 'jslasnd_TEST@gmail.com'];
        for (Contact contacto : lstcontacto) {
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        }
        update lstcontacto;
        
        System.runAs (usuarioTest) {
            Test.startTest();
                    List<String> result = SEG_EmailService.identificarEmailSaliente('jslasnd_TEST@gmail.com', caso);
            Test.stopTest();
            System.assert(caso != null,'ok');
        }
    }
    @IsTest
    public static void identificarEmailSalienteTest4() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_MCC__c mcc1 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TE-000001'];
        CC_MCC__c mcc2 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'PR-000001'];
        CC_MCC__c mcc3 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'MO-000001'];
        CC_MCC__c mcc4 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'DE-000001'];

        List<Contact> lstcontacto = [SELECT Id, AccountId FROM Contact WHERE Email = 'jslasnd_TEST@gmail.com'];
        for (Contact contacto : lstcontacto) {
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        }
        update lstcontacto;

        Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'Subject caso 1'];
        caso.ContactId = lstcontacto[0].Id;
        caso.AccountId = lstcontacto[0].AccountId;
        caso.CC_MCC_Tematica__c = mcc1.Id;
        caso.CC_MCC_ProdServ__c = mcc2.Id;
        caso.CC_MCC_Motivo__c = mcc3.Id;
        caso.SEG_Detalle__c = mcc4.Id;
        caso.CC_Detalles_Consulta__c = 'F';
        caso.Status = 'Cerrado';
        update caso;

        System.runAs (usuarioTest) {
            Test.startTest();
                    List<String> result = SEG_EmailService.identificarEmailSaliente('jslasnd_TEST@gmail.com', caso);
            Test.stopTest();
            System.assert(caso != null,'ok');
        }
    }

    @IsTest
    public static void identificarEmailSalienteTest5() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_MCC__c mcc1 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TE-000001'];
        CC_MCC__c mcc2 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'PR-000001'];
        CC_MCC__c mcc3 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'MO-000001'];
        CC_MCC__c mcc4 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'DE-000001'];

        List<Contact> lstcontacto = [SELECT Id, AccountId FROM Contact WHERE Email = 'jslasnd_TEST@gmail.com'];
        for (Contact contacto : lstcontacto) {
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        }
        update lstcontacto;

        Account cuenta = new Account();
        cuenta.Id = lstcontacto[0].AccountId;
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();
        update cuenta;

        Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'Subject caso 1'];
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso.ContactId = lstcontacto[0].Id;
        caso.AccountId = lstcontacto[0].AccountId;
        caso.CC_MCC_Tematica__c = mcc1.Id;
        caso.CC_MCC_ProdServ__c = mcc2.Id;
        caso.CC_MCC_Motivo__c = mcc3.Id;
        caso.SEG_Detalle__c = mcc4.Id;
        caso.CC_Detalles_Consulta__c = 'F';
        caso.Status = 'Cerrado';
        update caso;

        System.runAs (usuarioTest) {
            Test.startTest();
                    List<String> result = SEG_EmailService.identificarEmailSaliente('jslasnd_TEST@gmail.com', caso);
            Test.stopTest();
            System.assert(caso != null,'ok');
        }
    }

    @IsTest
    public static void identificarEmailSalienteTest6() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_MCC__c mcc1 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'TE-000001'];
        CC_MCC__c mcc2 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'PR-000001'];
        CC_MCC__c mcc3 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'MO-000001'];
        CC_MCC__c mcc4 = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'DE-000001'];

        List<Contact> lstcontacto = [SELECT Id, AccountId FROM Contact WHERE Email = 'jslasnd_TEST@gmail.com'];
        for (Contact contacto : lstcontacto) {
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        }
        update lstcontacto;

        Case caso = [SELECT Id, Status FROM Case WHERE Subject = 'Subject caso 1'];
        caso.ContactId = lstcontacto[0].Id;
        caso.AccountId = lstcontacto[0].AccountId;
        caso.CC_MCC_Tematica__c = mcc1.Id;
        caso.CC_MCC_ProdServ__c = mcc2.Id;
        caso.CC_MCC_Motivo__c = mcc3.Id;
        caso.SEG_Detalle__c = mcc4.Id;
        caso.CC_Detalles_Consulta__c = 'F';
        caso.Status = 'Cerrado';
        update caso;
        
        System.runAs (usuarioTest) {
            Test.startTest();
                    List<String> result = SEG_EmailService.identificarEmailSaliente('jslasnd_TEST@gmail.com', caso);
            Test.stopTest();
            System.assert(caso != null,'ok');
        }
    }

     @IsTest
     public static void determinarCR1() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'invalida_canal_comunicacion@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Clasificación rápida    
        SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
        clasR.SEG_Canaldeentrada__c = 'Oficina';
        clasR.CBK_Negocio__c = 'Segmentos';
        clasR.SEG_Inactiva__c	= false;
        insert clasR;
        
        //Reglas de clasificación
        SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
        reglas.SEG_PeticionarioAsunto__c = true;
        reglas.SEG_PeticionarioCuerpo__c = true;
        reglas.SEG_ClasificacionRapida__c = clasR.id;
        reglas.CBK_Negocio__c = 'Segmentos';
        reglas.SEG_Inactiva__c = false;
		insert reglas;
        
        List<SEG_Multivalor__c> multivLst = new List<SEG_Multivalor__c>();
        //Multivalor
	    SEG_Multivalor__c multiV1 = new SEG_Multivalor__c();
        multiV1.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV1.CBK_Negocio__c = 'Segmentos';
        multiV1.SEG_TipodeValor__c = 'Remitente';
        multiV1.SEG_Valor__c = 'Valor';
        //insert multiV1;
        multivLst.add(multiV1);
        
        //Multivalor
	    SEG_Multivalor__c multiV2 = new SEG_Multivalor__c();
        multiV2.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV2.CBK_Negocio__c = 'Segmentos';
        multiV2.SEG_TipodeValor__c = 'Asunto';
        multiV2.SEG_Valor__c = 'Valor';
        //insert multiV2;
        multivLst.add(multiV2);
        
        //Multivalor
	    SEG_Multivalor__c multiV3 = new SEG_Multivalor__c();
        multiV3.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV3.CBK_Negocio__c = 'Segmentos';
        multiV3.SEG_TipodeValor__c = 'Remitente';
        multiV3.SEG_Valor__c = 'Valor';
        //insert multiV3;
        multivLst.add(multiV3);
        
        //Multivalor
	    SEG_Multivalor__c multiV4 = new SEG_Multivalor__c();
        multiV4.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV4.CBK_Negocio__c = 'Segmentos';
        multiV4.SEG_TipodeValor__c = 'Cuerpo';
        multiV4.SEG_Valor__c = 'Valor';
        //insert multiV4;
        multivLst.add(multiV4);
        
        //Multivalor a excluir 
	    SEG_Multivalor__c multiV5 = new SEG_Multivalor__c();
        multiV5.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV5.CBK_Negocio__c = 'Segmentos';
        multiV5.SEG_TipodeValor__c = 'Asunto a excluir';
        multiV5.SEG_Valor__c = 'test';
        //insert multiV5;
        multivLst.add(multiV5);
        
        insert multivLst;
        
        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');     
        }
    }

    @IsTest
    public static void determinarCR9() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
       //Crear un InboundEnvelope e InboundEmail de entrada
       Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
       Messaging.InboundEmail correo = new Messaging.InboundEmail();
       Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
       header.value = headerValueStr;
       header.name = 'X-SFDC-Original-RCPT';
       envelope.fromAddress = 'invalida_canal_comunicacion@gmail.com';
       envelope.toAddress = 'tiha.invalidad@invalid.com';
       correo.subject = 'asunto';
       correo.fromName='Nombre Apellido1 Apellido 2';
       correo.fromAddress = 'jslasnd_TEST@gmail.com';
       correo.plainTextBody = 'email body\n2225256325\nTitle';
       correo.headers = new List<Messaging.InboundEmail.Header>{header};
       //Clasificación rápida    
       SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
       clasR.SEG_Canaldeentrada__c = 'Oficina';
       clasR.CBK_Negocio__c = 'Segmentos';
       clasR.SEG_Inactiva__c	= false;
       insert clasR;
       
       //Reglas de clasificación
       SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
       reglas.SEG_PeticionarioAsunto__c = true;
       reglas.SEG_PeticionarioCuerpo__c = true;
       reglas.SEG_ClasificacionRapida__c = clasR.id;
       reglas.CBK_Negocio__c = 'Segmentos';
       reglas.SEG_Inactiva__c = false;
       insert reglas;
       
       List<SEG_Multivalor__c> multivLst = new List<SEG_Multivalor__c>();
       //Multivalor
       SEG_Multivalor__c multiV1 = new SEG_Multivalor__c();
       multiV1.SEG_Reglas_Clasificacion__c = reglas.id;
       multiV1.CBK_Negocio__c = 'Segmentos';
       multiV1.SEG_TipodeValor__c = 'Destinatario';
       multiV1.SEG_Valor__c = 'Valor';
       multivLst.add(multiV1);

       SEG_Multivalor__c multiV3 = new SEG_Multivalor__c();
       multiV3.SEG_Reglas_Clasificacion__c = reglas.id;
       multiV3.CBK_Negocio__c = 'Segmentos';
       multiV3.SEG_TipodeValor__c = 'Destinatario';
       multiV3.SEG_Valor__c = 'Valor2';
       multivLst.add(multiV3);
       
       SEG_Multivalor__c multiV2 = new SEG_Multivalor__c();
       multiV2.SEG_Reglas_Clasificacion__c = reglas.id;
       multiV2.CBK_Negocio__c = 'Segmentos';
       multiV2.SEG_TipodeValor__c = 'Destinatario CC';
       multiV2.SEG_Valor__c = 'Valor3';
       multivLst.add(multiV2);

       SEG_Multivalor__c multiV4 = new SEG_Multivalor__c();
       multiV4.SEG_Reglas_Clasificacion__c = reglas.id;
       multiV4.CBK_Negocio__c = 'Segmentos';
       multiV4.SEG_TipodeValor__c = 'Destinatario CC';
       multiV4.SEG_Valor__c = 'Valor4';
       multivLst.add(multiV4);
       
       insert multivLst;
       
       System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');  
       }   
    }
    @IsTest
    public static void determinarCR2() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'invalida_canal_comunicacion@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'test VFR';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        SEG_ClasificacionRapida__c clasR = [SELECT id, SEG_Detalle__c, SEG_Producto__c, SEG_Motivo__c, SEG_Tematica__c FROM SEG_ClasificacionRapida__c WHERE Name = 'CR1' LIMIT 1];
        
        //Reglas de clasificación
        SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
        reglas.SEG_PeticionarioAsunto__c = true;
        reglas.SEG_PeticionarioCuerpo__c = true;
        reglas.SEG_ClasificacionRapida__c = clasR.id;
        reglas.CBK_Negocio__c = 'Segmentos';
        reglas.SEG_Inactiva__c = false;
		insert reglas;
        
        List<SEG_Multivalor__c> multivLst = new List<SEG_Multivalor__c>();
        //Multivalor
	    SEG_Multivalor__c multiV = new SEG_Multivalor__c();
        multiV.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV.CBK_Negocio__c = 'Segmentos';
        multiV.SEG_TipodeValor__c = 'Asunto';
        multiV.SEG_Valor__c = 'test VFR';
        //insert multiV;
        multivLst.add(multiV);
        
        //Multivalor a excluir 
	    SEG_Multivalor__c multiE1 = new SEG_Multivalor__c();
        multiE1.SEG_Reglas_Clasificacion__c = reglas.id;
        multiE1.CBK_Negocio__c = 'Segmentos';
        multiE1.SEG_TipodeValor__c = 'Asunto a excluir';
        multiE1.SEG_Valor__c = 'excluir';
        //insert multiE1;
        multivLst.add(multiE1);

        //Multivalor a excluir 
	    SEG_Multivalor__c multiE2 = new SEG_Multivalor__c();
        multiE2.SEG_Reglas_Clasificacion__c = reglas.id;
        multiE2.CBK_Negocio__c = 'Segmentos';
        multiE2.SEG_TipodeValor__c = 'Asunto a excluir';
        multiE2.SEG_Valor__c = 'excluir';
        //insert multiE2;
        multivLst.add(multiE2);
        
        insert multivLst;

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);   
            Test.stopTest();  
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');  
        }               
    }
    @IsTest
    public static void determinarCR3() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'invalida_canal_comunicacion@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'Valor';
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Clasificación rápida    
        SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
        clasR.SEG_Canaldeentrada__c = 'Oficina';
        clasR.CBK_Negocio__c = 'Segmentos';
        clasR.SEG_Inactiva__c	= false;
        insert clasR;
        
        //Reglas de clasificación
        SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
        reglas.SEG_PeticionarioAsunto__c = true;
        reglas.SEG_PeticionarioCuerpo__c = true;
        reglas.CBK_Negocio__c = 'Segmentos';
        reglas.SEG_ClasificacionRapida__c = clasR.id;
        reglas.SEG_Inactiva__c = false;
		insert reglas;
        
        List<SEG_Multivalor__c> multivLst = new List<SEG_Multivalor__c>();
        //Multivalor
	    SEG_Multivalor__c multiV1 = new SEG_Multivalor__c();
        multiV1.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV1.CBK_Negocio__c = 'Segmentos';
        multiV1.SEG_TipodeValor__c = 'Cuerpo';
        multiV1.SEG_Valor__c = 'test1';
        //insert multiV1;
        multivLst.add(multiV1);
        
        //Multivalor
	    SEG_Multivalor__c multiV2 = new SEG_Multivalor__c();
        multiV2.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV2.CBK_Negocio__c = 'Segmentos';
        multiV2.SEG_TipodeValor__c = 'Asunto';
        multiV2.SEG_Valor__c = 'Valor1';
        //insert multiV2;  
        multivLst.add(multiV2);
        
        //Multivalor
	    SEG_Multivalor__c multiV3 = new SEG_Multivalor__c();
        multiV3.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV3.CBK_Negocio__c = 'Segmentos';
        multiV3.SEG_TipodeValor__c = 'Asunto';
        multiV3.SEG_Valor__c = 'Valor2';
        //insert multiV3;
        multivLst.add(multiV3);
        
        //Multivalor
	    SEG_Multivalor__c multiV4 = new SEG_Multivalor__c();
        multiV4.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV4.CBK_Negocio__c = 'Segmentos';
        multiV4.SEG_TipodeValor__c = 'Cuerpo';
        multiV4.SEG_Valor__c = 'test2';
        //insert multiV4; 
        multivLst.add(multiV4);
        
        insert multivLst;

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);  
            Test.stopTest();
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');       
        }                  
    }
    @IsTest
    public static void determinarCR4() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'invalida_canal_comunicacion@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Clasificación rápida    
        SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
        clasR.SEG_Organizacion__c = 'Banca Corporativa';
        clasR.SEG_Canaldeentrada__c = 'Oficina';
        clasR.CBK_Negocio__c = 'Segmentos';
        clasR.SEG_Inactiva__c	= false;
        insert clasR;
        
        //Reglas de clasificación
        SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
        reglas.SEG_PeticionarioAsunto__c = true;
        reglas.SEG_PeticionarioCuerpo__c = true;
        reglas.CBK_Negocio__c = 'Segmentos';
        reglas.SEG_ClasificacionRapida__c = clasR.id;
        reglas.SEG_Inactiva__c = false;
		insert reglas;
        
        //Multivalor
	    SEG_Multivalor__c multiV = new SEG_Multivalor__c();
        multiV.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV.CBK_Negocio__c = 'Segmentos';
        multiV.SEG_TipodeValor__c = 'Cuerpo';
        multiV.SEG_Valor__c = 'email';
        insert multiV;
        
        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope); 
            Test.stopTest();     
            System.assertEquals(result.success,true,'El resultado ha sido el correcto'); 
        }                    
    }
    
    @IsTest
    public static void variasCRTest() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'invalida_canal_comunicacion@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Clasificaciones rápidas   
        SEG_ClasificacionRapida__c cr1 = new SEG_ClasificacionRapida__c();
        cr1.SEG_Organizacion__c = 'Banca Corporativa';
        cr1.SEG_Canaldeentrada__c = 'Oficina';
        cr1.CBK_Negocio__c = 'Segmentos';
        cr1.SEG_Inactiva__c	= false;
        insert cr1;
          
        SEG_ClasificacionRapida__c cr2 = new SEG_ClasificacionRapida__c();
        cr2.SEG_Organizacion__c = 'Banca Corporativa';
        cr2.SEG_Canaldeentrada__c = 'Email';
        cr2.CBK_Negocio__c = 'Segmentos';
        cr2.SEG_Inactiva__c	= false;
        insert cr2;
        
        //Reglas de clasificación
        SEG_Regladeclasificacion__c regla1 = new SEG_Regladeclasificacion__c();
        regla1.SEG_PeticionarioAsunto__c = true;
        regla1.SEG_PeticionarioCuerpo__c = true;
        regla1.CBK_Negocio__c = 'Segmentos';
        regla1.SEG_ClasificacionRapida__c = cr1.id;
        regla1.SEG_Inactiva__c = false;
		insert regla1;
        
        SEG_Regladeclasificacion__c regla2 = new SEG_Regladeclasificacion__c();
        regla2.CBK_Negocio__c = 'Segmentos';
        regla2.SEG_ClasificacionRapida__c = cr2.id;
        regla2.SEG_Inactiva__c = false;
        insert regla2;
        
        //Multivalores
        SEG_Multivalor__c mv1 = new SEG_Multivalor__c();
        mv1.SEG_Reglas_Clasificacion__c = regla1.id;
        mv1.CBK_Negocio__c = 'Segmentos';
        mv1.SEG_TipodeValor__c = 'Cuerpo';
        mv1.SEG_Valor__c = 'email';
        insert mv1;
        
        SEG_Multivalor__c mv2 = new SEG_Multivalor__c();
        mv2.SEG_Reglas_Clasificacion__c = regla2.id;
        mv2.CBK_Negocio__c = 'Segmentos';
        mv2.SEG_TipodeValor__c = 'Cuerpo';
        mv2.SEG_Valor__c = 'email';
        insert mv2;        

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);  
            Test.stopTest(); 
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');   
        }                  
    }

    @IsTest
    public static void determinarCRX1() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        toAddresses.add('test@mail.com');
        toAddresses.add('invalidtest@mail.com');
        ccAddresses.add('test@mail.com');
        ccAddresses.add('invalidtest@mail.com');

        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'test@mail.com';
        envelope.toAddress = 'test@mail.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.toAddresses = toAddresses;
        correo.ccAddresses = ccAddresses;
        correo.plainTextBody = 'Cuerpo body\n2225256325\nTitle';
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Clasificación rápida    
        SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
        clasR.SEG_Organizacion__c = 'Banca Corporativa';
        clasR.SEG_Canaldeentrada__c = 'Oficina';
        clasR.CBK_Negocio__c = 'Segmentos';
        clasR.SEG_Inactiva__c	= false;
        insert clasR;
        
        //Reglas de clasificación
        SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
        reglas.SEG_PeticionarioAsunto__c = true;
        reglas.SEG_PeticionarioCuerpo__c = true;
        reglas.CBK_Negocio__c = 'Segmentos';
        reglas.SEG_ClasificacionRapida__c = clasR.id;
        reglas.SEG_Inactiva__c = false;
		insert reglas;

        List<SEG_Multivalor__c> multivLst = new List<SEG_Multivalor__c>();
        SEG_Multivalor__c multiV6 = new SEG_Multivalor__c();
        multiV6.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV6.CBK_Negocio__c = 'Segmentos';
        multiV6.SEG_TipodeValor__c = 'Destinatario';
        multiV6.SEG_Valor__c = 'test@mail.com';
        //insert multiV5;
        multivLst.add(multiV6);

        SEG_Multivalor__c multiV7 = new SEG_Multivalor__c();
        multiV7.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV7.CBK_Negocio__c = 'Segmentos';
        multiV7.SEG_TipodeValor__c = 'Destinatario CC';
        multiV7.SEG_Valor__c = 'test@mail.com';
        //insert multiV5;
        multivLst.add(multiV7);

        SEG_Multivalor__c multiV8 = new SEG_Multivalor__c();
        multiV8.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV8.CBK_Negocio__c = 'Segmentos';
        multiV8.SEG_TipodeValor__c = 'Remitente a excluir';
        multiV8.SEG_Valor__c = 'test@mail.com';
        //insert multiV5;
        multivLst.add(multiV8);

        SEG_Multivalor__c multiV9 = new SEG_Multivalor__c();
        multiV9.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV9.CBK_Negocio__c = 'Segmentos';
        multiV9.SEG_TipodeValor__c = 'Destinatario a excluir';
        multiV9.SEG_Valor__c = 'invalidtest@mail.com';
        //insert multiV5;
        multivLst.add(multiV9);

        SEG_Multivalor__c multiV10 = new SEG_Multivalor__c();
        multiV10.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV10.CBK_Negocio__c = 'Segmentos';
        multiV10.SEG_TipodeValor__c = 'Destinatario CC a excluir';
        multiV10.SEG_Valor__c = 'invalidtest@mail.com';
        //insert multiV5;
        multivLst.add(multiV10);

        insert multivLst;
        
        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope); 
            Test.stopTest();     
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');   
        }                  
    }

    @IsTest
    public static void determinarCRX2() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        toAddresses.add('test@mail.com');
        toAddresses.add('invalidtest@mail.com');
        ccAddresses.add('test@mail.com');
        ccAddresses.add('invalidtest@mail.com');

        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'test@mail.com';
        envelope.toAddress = 'test@mail.com';
        correo.subject = 'asunto';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.toAddresses = toAddresses;
        correo.ccAddresses = ccAddresses;
        correo.plainTextBody = ' 33333333H Y24558798 Y2455879M Cuerpo body\n2225256325\nTitle';
    	correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Clasificación rápida    
        SEG_ClasificacionRapida__c clasR = new SEG_ClasificacionRapida__c();
        clasR.SEG_Organizacion__c = 'Banca Corporativa';
        clasR.SEG_Canaldeentrada__c = 'Oficina';
        clasR.CBK_Negocio__c = 'Segmentos';
        clasR.SEG_Inactiva__c	= false;
        insert clasR;
        
        //Reglas de clasificación
        SEG_Regladeclasificacion__c reglas = new SEG_Regladeclasificacion__c();
        reglas.SEG_PeticionarioAsunto__c = true;
        reglas.SEG_PeticionarioCuerpo__c = true;
        reglas.CBK_Negocio__c = 'Segmentos';
        reglas.SEG_ClasificacionRapida__c = clasR.id;
        reglas.SEG_Inactiva__c = false;
		insert reglas;

        List<SEG_Multivalor__c> multivLst = new List<SEG_Multivalor__c>();
        SEG_Multivalor__c multiV3 = new SEG_Multivalor__c();
        multiV3.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV3.CBK_Negocio__c = 'Segmentos';
        multiV3.SEG_TipodeValor__c = 'Cuerpo';
        multiV3.SEG_Valor__c = 'Cuerpo';
        //insert multiV5;
        multivLst.add(multiV3);

        SEG_Multivalor__c multiV4 = new SEG_Multivalor__c();
        multiV4.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV4.CBK_Negocio__c = 'Segmentos';
        multiV4.SEG_TipodeValor__c = 'Asunto';
        multiV4.SEG_Valor__c = 'Asunto';
        //insert multiV5;
        multivLst.add(multiV4);

        SEG_Multivalor__c multiV5 = new SEG_Multivalor__c();
        multiV5.SEG_Reglas_Clasificacion__c = reglas.id;
        multiV5.CBK_Negocio__c = 'Segmentos';
        multiV5.SEG_TipodeValor__c = 'Remitente';
        multiV5.SEG_Valor__c = 'test@mail.com';
        //insert multiV5;
        multivLst.add(multiV5);

        insert multivLst;

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService emailServiceSEG = new SEG_EmailService();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope); 
            Test.stopTest();     
            System.assertEquals(result.success,true,'El resultado ha sido el correcto');           
        }          
    }

    @IsTest
    public static void crearLinkNotaTest() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String mensajenota = 'Test mensaje crearlinknotas';
        String objCnt = SEG_EmailService.crearNotas(mensajenota);
        List<Case> lstcase = [Select Id from Case Limit 1];

        System.runAs (usuarioTest) {
            Test.startTest();
                    SEG_EmailService.crearLinkNota(lstcase,objCnt);    
            Test.stopTest();
            System.assert(mensajenota != null,'Se ha encontrado el mensaje');    
        }
    }


    @isTest
    public static void getIdPlantillaIdioma() {
        

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        SEG_Plantilla__c configuracionPlantilla = [SELECT SEG_PlantillaGalegoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaInglesID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaCastellanoID__c
                                                    FROM SEG_Plantilla__c WHERE Name = 'Acuse de recibo' LIMIT 1];

        Id idRecordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Account> cuentas = new List<Account>{
            new Account(RecordTypeId = idRecordTypeCuenta, Name = 'A', AV_Idioma__c = '004'),
            new Account(RecordTypeId = idRecordTypeCuenta, Name = 'B', AV_Idioma__c = '001'),
            new Account(RecordTypeId = idRecordTypeCuenta, Name = 'C', AV_Idioma__c = '010'),
            new Account(RecordTypeId = idRecordTypeCuenta, Name = 'D', AV_Idioma__c = '003'),
            new Account(RecordTypeId = idRecordTypeCuenta, Name = 'E', AV_Idioma__c = '002')
        };
        insert cuentas;

        Id idRecordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Contact> contactos = new List<Contact>{
            new Contact(RecordTypeId = idRecordTypeContacto, LastName = 'a', CC_Idioma__c = 'ga'),
            new Contact(RecordTypeId = idRecordTypeContacto, LastName = 'b', CC_Idioma__c = 'ca'),
            new Contact(RecordTypeId = idRecordTypeContacto, LastName = 'c', CC_Idioma__c = 'en'),
            new Contact(RecordTypeId = idRecordTypeContacto, LastName = 'd', CC_Idioma__c = 'eu'),
            new Contact(RecordTypeId = idRecordTypeContacto, LastName = 'e', CC_Idioma__c = 'es')
        };
        insert contactos;

        Id idRecordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        List<Case> casos = new List<Case>{
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = 'ga', SEG_Idioma__c = 'ga'),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = 'ca', SEG_Idioma__c = 'ca'),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = 'en', SEG_Idioma__c = 'en'),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = 'eu', SEG_Idioma__c = 'eu'),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = 'es', SEG_Idioma__c = 'es'),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, ContactId = contactos[0].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, ContactId = contactos[1].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, ContactId = contactos[2].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, ContactId = contactos[3].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, ContactId = contactos[4].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, AccountId = cuentas[0].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, AccountId = cuentas[1].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, AccountId = cuentas[2].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, AccountId = cuentas[3].Id),
            new Case(RecordTypeId = idRecordTypeCaso, CC_Idioma__c = null, AccountId = cuentas[4].Id)
        };
        insert casos;

        System.runAs (usuarioTest) {
            Test.startTest();
            
                List<Id> result = new List<Id>();
                for (Case caso : [SELECT SEG_Idioma__c, Contact.CC_Idioma__c, Account.AV_Idioma__c FROM Case WHERE Id IN :CC_MetodosUtiles.listaCampo(casos, 'Id')]) {
                    result.add(SEG_Detector_Idioma.getIdPlantillaIdioma(configuracionPlantilla, caso));
                }
            Test.stopTest();
                
            System.assertNotEquals(result,null,'Contiene las plantillas correctas'); 
        } 
    }
    
    @isTest
    public static void procesarReferencias() {
        
        
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Id idRecordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        List<Case> casos = new List<Case>{
            new Case(RecordTypeId = idRecordTypeCaso, 
                    CC_Idioma__c = 'es', 
                    SEG_Idioma__c = 'es', 
                    SEG_Organizacion__c = 'Banca Corporativa',
                    SEG_Zona__c = 'Corporativa')
        };
        insert casos;
        List<String> lstSemillas = new List<String>();
        List<String> lstCaseNumbers = new List<String>();
        
        Case casoNumber = [SELECT CaseNumber FROM Case WHERE Id =: casos[0].Id LIMIT 1];
        
        lstCaseNumbers.add(casoNumber.CaseNumber);
        
        System.runAs (usuarioTest) {
            Test.startTest();
				List<Case> returnCasos = SEG_EmailService.procesarReferencias(lstSemillas,lstCaseNumbers,'Banca Corporativa','Corporativa');
            Test.stopTest();
            System.assertNotEquals(returnCasos, null,'No se ha encontrado el caso');  
        }
    }

    @IsTest
    public static void encontrarCasosExistentes() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        SEG_EmailService emailServiceSEG = new SEG_EmailService();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asd 04030904 asd 04030905';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'test case numbers';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        //Se envía un primer mail que generará un caso
        Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
        //Se obtiene el caso creado
        Case casoCreado = [SELECT Id, CaseNumber,SEG_Organizacion__c, SEG_Zona__c, RecordType.DeveloperName FROM Case WHERE Subject like '%asd 04030904 asd 04030905%' LIMIT 1];
        correo.subject = 'Respuesta al correo ' + casoCreado.CaseNumber;
        System.runAs (usuarioTest) {
            Test.startTest();
                    Messaging.InboundEmailResult resultDos = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(resultDos.success,true,'El resultado ha sido el correcto');
        }
    }

    @IsTest
    public static void encontrarVariasCuentas() {


        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        SEG_EmailService emailServiceSEG = new SEG_EmailService();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asd 04030904 asd 04030905';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'test case numbers';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        List<Contact> contactos = [SELECT Id FROM Contact WHERE LastName = 'Paco' OR LastName = 'PacoD'];

        //Creamos una segunda cuenta para asociar al mismo contacto
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa segmentos Segunda';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG2.CC_Numero_Documento__c = '11141211H';
        insert cuentaSEG2;

        //Asociamos el contacto a la nueva cuenta para que esté asociado a dos

        AccountContactRelation relacionSEG1 = new AccountContactRelation();
        relacionSEG1.AccountId = cuentaSEG2.Id;
        relacionSEG1.ContactId = contactos[0].Id;
        insert relacionSEG1;

        AccountContactRelation relacionSEG2 = new AccountContactRelation();
        relacionSEG2.AccountId = cuentaSEG2.Id;
        relacionSEG2.ContactId = contactos[1].Id;
        insert relacionSEG2;

        System.runAs (usuarioTest) {
            Test.startTest();
                    Messaging.InboundEmailResult resultado = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(resultado.success,true,'El resultado ha sido el correcto');
        }
    }

    @IsTest
    public static void encontrarUnaCuentayContacto() {


        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        SEG_EmailService emailServiceSEG = new SEG_EmailService();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'asd 04030904 asd 04030905';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'test case numbers';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        List<Contact> contactos = [SELECT Id FROM Contact WHERE LastName = 'Paco' LIMIT 1];
        contactos[0].email = 'jslasnd_TEST_noValido@gmail.com';
        update contactos;

        List<Account> cuentas = [SELECT Id FROM Account];
        cuentas.remove(0);
        delete cuentas;
       
        System.runAs (usuarioTest) {
            Test.startTest();
                    Messaging.InboundEmailResult resultado = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assertEquals(resultado.success,true,'El resultado ha sido el correcto');
        }
    }

    @IsTest
    public static void testCatchGrande() {


       User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
       String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
       Account cuentaSEG2 = new Account();
       cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
       cuentaSEG2.Name = 'Empresa segmentos2';
       cuentaSEG2.SEG_DominioMail__c = '@cuenta2SEG';
       cuentaSEG2.CC_Numero_Documento__c = '11241211H';
       insert cuentaSEG2;

       Contact contactoExtra = [Select id FROM Contact WHERE FirstName = 'Contacto Cliente'];
       delete contactoExtra;

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail();
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'TESTCATCHGRANDE';
        correo.fromName='Nombre Apellido1 Apellido 2';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = 'email body\n2225256325\nTitle';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};
 
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};
 
        System.runAs (usuarioTest) {
           Test.startTest();
                   SEG_EmailService emailServiceSEG = new SEG_EmailService();
                   Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);   
           Test.stopTest();
           System.assertEquals(result ,null,'El forzado de error no ha funcionado correctamente');   
        }           
    }

    @IsTest
    public static void testparseoDatetime() {

 
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        String dateString = 'Tue, 8 Aug 2023 06:57:56 +0000';

        System.runAs (usuarioTest) {
            Test.startTest();
                Datetime result = SEG_EmailService.parseoDatetime(dateString);   
            Test.stopTest();
            System.assertNotEquals(result ,null,'No he se calculado la fecha correctamente');   
        }           
   }
   
   @IsTest
     public static void subjectMoreThan255() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';
        envelope.fromAddress = 'jslasnd_TEST@gmail.com';
        envelope.toAddress = 'tiha.invalidad@invalid.com';
        correo.subject = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras quis dolor et orci dignissim posuere. Sed ultricies porttitor nulla sit amet aliquam. Sed feugiat quis eros sit amet mollis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
        correo.fromAddress = 'jslasnd_TEST@gmail.com';
        correo.plainTextBody = '#@SEG:1611676158418#';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};
        
        SEG_EmailService emailServiceSEG = new SEG_EmailService();
        System.runAs (usuarioTest) {
            Test.startTest();
                    Messaging.InboundEmailResult result = emailServiceSEG.handleInboundEmail(correo, envelope);
            Test.stopTest();
            System.assert(header.value != null,'El resultado ha sido el correcto');
        }
    }
}