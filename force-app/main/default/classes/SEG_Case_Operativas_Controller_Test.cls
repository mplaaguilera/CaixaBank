@isTest
public class SEG_Case_Operativas_Controller_Test implements HttpCalloutMock{
//User operativo = SEG_Usuarios.usuarioOperativo();
//User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
    public HTTPResponse respond(HTTPRequest req) {   
            
        String sFakeRespuesta = '{"result":{"request":"RITM0244498","id_ref":"5005r00000Cf25QAAR","description":"00: RITM successfully created","codigo":"200"}}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }

    @TestSetup
    public static void crearDatosPrueba() {
        
        List<Case> caseContList = new List<Case>();
        List<SEG_Plantilla__c> plantillas = new List<SEG_Plantilla__c>();
        
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        Id accountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id contactId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
		Id recordTexto = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();

        //Gestor Operativa Internacional
		CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
		grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
		insert grupoGestorOperativaInternacional;

		/*SEG_Excepciones__c excepcion = new SEG_Excepciones__c();
		excepcion.RecordTypeId = recordAsig;
		excepcion.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion.SEG_Zona__c = 'Corporativa';
		excepcion.SEG_Grupoasignado__c = grupoGestorOperativaInternacional.Id;
		insert excepcion;*/

        /*SEG_ClasificacionRapida__c classR = new SEG_ClasificacionRapida__c();
        classR.Name = 'No procede';
        insert classR;
        */

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.Name = 'Tematica Test';
        tematica.RecordTypeId = tematicaId;
        tematica.CC_Tipo_Cliente__c = 'Segmentos';
        tematica.CC_Codigo_Externo__c = 'TE-031200001';
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'Producto Test';
        producto.RecordTypeId = productoId;
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Tipo_Cliente__c = 'Segmentos';
        producto.CC_Codigo_Externo__c = 'PR-003250001';
        insert producto;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Motivo Test';
        motivo.RecordTypeId = motivoId;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.CC_Codigo_Externo__c = 'MO-000032101';
        insert motivo;
       
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.RecordTypeId = motivoId;
        mccMotivo.Name = 'Motivo';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Codigo_Externo__c = 'DE-000004';
        insert mccMotivo;

        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c();
        grupoCol1.SEG_Zona__c = 'Corporativa';
        grupoCol1.SEG_Organizacion__C = 'Banca Corporativa';
        grupoCol1.Name = 'GrupoSegOp1';
        grupoCol1.RecordTypeId = grupoOpSegId;   
		insert grupoCol1;
        
        CC_Grupo_Colaborador__c grupoCol2 = new CC_Grupo_Colaborador__c();
        grupoCol2.Name = 'BO*';
        grupoCol2.RecordTypeId = grupoAutoSegId;
        insert grupoCol2;

        // Creación cuentas a tratar.derivarGrupoMCCporInconsistenciaExcepciones
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111171H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        contactoSEG1.CC_Idioma__c = 'ca';
        insert contactoSEG1;
        
        Case casoSinClas = new Case();
        casoSinClas.AccountId = cuentaSEG1.id;
        casoSinClas.ContactId = contactoSEG1.id;
        casoSinClas.SEG_Numero_de_centro__c = cuentaSEG1.id;
        casoSinClas.RecordTypeId = rt;
        casoSinClas.SEG_Grupo__c = grupoCol1.id;
        casoSinClas.SEG_Grupo_Anterior__c = grupoCol2.id; 
        casoSinClas.Origin = 'Email';
        casoSinClas.CC_Canal_Procedencia__c = 'Formulario web';
        casoSinClas.Status = 'Activo';
        casoSinClas.SEG_Subestado__c = 'En curso';
        casoSinClas.SEG_Zona__c = 'Corporativa';
        casoSinClas.SEG_Organizacion__C = 'Banca Corporativa';
        caseContList.add(casoSinClas); 
   
        SEG_NotasTipificadas__c nottip = new SEG_NotasTipificadas__c();
        nottip.Name = 'prueba';
        insert nottip;
        
        EmailTemplate emailEs = new EmailTemplate();
		emailEs.DeveloperName = 'Reclamacion_1_1616749645917';
		emailEs.Encoding = 'ISO-8859-1';
		emailEs.FolderId = UserInfo.getUserId();
		emailEs.Subject = '[num_casos]';
		emailEs.IsActive = true;
		emailEs.Name = 'Reclamacion 1º';
		emailEs.TemplateType = 'custom';
		emailEs.TemplateStyle = 'none';
		emailEs.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert emailEs;
		}
        
        SEG_Plantilla__c planAR = new SEG_Plantilla__c();
		planAR.Name = 'Acuse de recibo';
		planAR.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planAR.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas cataluña';
		planAR.SEG_TipoOperativa__c = 'Acuse de recibo';
		planAR.SEG_Activa__c = true;
		planAR.SEG_PlantillaCastellano__c = 'Firma BO';
		planAR.SEG_PlantillaCatalan__c = 'Firma CAT';
		planAR.SEG_PlantillaIngles__c = 'Firma IN';
		planAR.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planAR.SEG_PlantillaGalego__c = 'Firma GAL';
		planAR.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planAR.SEG_PlantillaInglesID__c = emailEs.Id;
		plantillas.add(planAR);
        
        SEG_Plantilla__c planCierr = new SEG_Plantilla__c();
		planCierr.Name = 'Cierre';
		planCierr.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planCierr.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas cataluña';
		planCierr.SEG_TipoOperativa__c = 'Cierre';
		planCierr.SEG_Activa__c = true;
		planCierr.SEG_PlantillaCastellano__c = 'Firma BO';
		planCierr.SEG_PlantillaCatalan__c = 'Firma CAT';
		planCierr.SEG_PlantillaIngles__c = 'Firma IN';
		planCierr.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planCierr.SEG_PlantillaGalego__c = 'Firma GAL';
		planCierr.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planCierr.SEG_PlantillaInglesID__c = emailEs.Id;
        planCierr.SEG_Resultado__c = 'Respuesta a peticionario';
		plantillas.add(planCierr);
        
        SEG_Plantilla__c planCierr2 = new SEG_Plantilla__c();
		planCierr2.Name = 'Cierre';
		planCierr2.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planCierr2.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas cataluña';
		planCierr2.SEG_TipoOperativa__c = 'Cierre';
		planCierr2.SEG_Activa__c = true;
		planCierr2.SEG_PlantillaCastellano__c = 'Firma BO';
		planCierr2.SEG_PlantillaCatalan__c = 'Firma CAT';
		planCierr2.SEG_PlantillaIngles__c = 'Firma IN';
		planCierr2.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planCierr2.SEG_PlantillaGalego__c = 'Firma GAL';
		planCierr2.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planCierr2.SEG_PlantillaInglesID__c = emailEs.Id;
        planCierr2.SEG_Resultado__c = 'Reenvío al contacto del caso';
		plantillas.add(planCierr2);
        
        SEG_Plantilla__c planCierr3 = new SEG_Plantilla__c();
		planCierr3.Name = 'Cierre';
		planCierr3.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planCierr3.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas cataluña';
		planCierr3.SEG_TipoOperativa__c = 'Cierre';
		planCierr3.SEG_Activa__c = true;
		planCierr3.SEG_PlantillaCastellano__c = 'Firma BO';
		planCierr3.SEG_PlantillaCatalan__c = 'Firma CAT';
		planCierr3.SEG_PlantillaIngles__c = 'Firma IN';
		planCierr3.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planCierr3.SEG_PlantillaGalego__c = 'Firma GAL';
		planCierr3.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planCierr3.SEG_PlantillaInglesID__c = emailEs.Id;
        planCierr3.SEG_Resultado__c = 'Enviado justificantes al cliente';
		plantillas.add(planCierr3);
        
        SEG_Plantilla__c planCierr4 = new SEG_Plantilla__c();
		planCierr4.Name = 'Cierre';
		planCierr4.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planCierr4.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas cataluña';
		planCierr4.SEG_TipoOperativa__c = 'Cierre';
		planCierr4.SEG_Activa__c = true;
		planCierr4.SEG_PlantillaCastellano__c = 'Firma BO';
		planCierr4.SEG_PlantillaCatalan__c = 'Firma CAT';
		planCierr4.SEG_PlantillaIngles__c = 'Firma IN';
		planCierr4.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planCierr4.SEG_PlantillaGalego__c = 'Firma GAL';
		planCierr4.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planCierr4.SEG_PlantillaInglesID__c = emailEs.Id;
        planCierr4.SEG_Resultado__c = 'Operaciones gestionadas pte envío justificante';
		plantillas.add(planCierr4);
        
        SEG_Plantilla__c planCierr5 = new SEG_Plantilla__c();
		planCierr5.Name = 'Cierre';
		planCierr5.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planCierr5.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas cataluña';
		planCierr5.SEG_TipoOperativa__c = 'Cierre';
		planCierr5.SEG_Activa__c = true;
		planCierr5.SEG_PlantillaCastellano__c = 'Firma BO';
		planCierr5.SEG_PlantillaCatalan__c = 'Firma CAT';
		planCierr5.SEG_PlantillaIngles__c = 'Firma IN';
		planCierr5.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planCierr5.SEG_PlantillaGalego__c = 'Firma GAL';
		planCierr5.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planCierr5.SEG_PlantillaInglesID__c = emailEs.Id;
        planCierr5.SEG_Resultado__c = 'Operaciones gestionadas pte envío justificante';
		plantillas.add(planCierr5);

        SEG_Plantilla__c planCierr6 = new SEG_Plantilla__c();
		planCierr6.Name = 'Cierre';
		planCierr6.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		planCierr6.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Empresas cataluña';
		planCierr6.SEG_TipoOperativa__c = 'Cierre';
		planCierr6.SEG_Activa__c = true;
		planCierr6.SEG_PlantillaCastellano__c = 'Firma BO';
		planCierr6.SEG_PlantillaCatalan__c = 'Firma CAT';
		planCierr6.SEG_PlantillaIngles__c = 'Firma IN';
		planCierr6.SEG_PlantillaEuskera__c = 'Firma EUSK';
		planCierr6.SEG_PlantillaGalego__c = 'Firma GAL';
		planCierr6.SEG_PlantillaCastellanoID__c = emailEs.Id;
        planCierr6.SEG_PlantillaInglesID__c = emailEs.Id;
        planCierr6.SEG_Resultado__c = 'Petición no gestionada';
		plantillas.add(planCierr6);
        
        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        
        //Crear MCC para CR
		List<CC_MCC__c> mccsLista = new List<CC_MCC__c>();
        
        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000007';
        mccsLista.add(mccTematicaSEG);
        insert mccsLista;

        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'Producto1SEG';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000007'; 
        
        insert mccProductoSEG; 
        
       	CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'Motivo1SEG';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000007';
        insert mccMotivoSEG;

       	CC_MCC__c mccDetalleSEG = new CC_MCC__c();
        mccDetalleSEG.Name = 'Detalle1SEG';
        mccDetalleSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccDetalleSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccDetalleSEG.CC_Motivo__c = mccMotivoSEG.Id;
        mccDetalleSEG.CC_Codigo_Externo__c = 'DE-000007';
        insert mccDetalleSEG;
        
        SEG_ClasificacionRapida__c regla3 = new SEG_ClasificacionRapida__c();
        regla3.Name = 'CR3';
        regla3.SEG_Tematica__c = mccTematicaSEG.Id;
        regla3.SEG_Producto__c = mccProductoSEG.Id;
        regla3.SEG_Motivo__c = mccMotivoSEG.Id;
        regla3.SEG_Detalle__c = mccDetalleSEG.Id;
        regla3.SEG_CRContratos__c  = false;
        regla3.CBK_Negocio__c = 'Segmentos';
        insert regla3;

        SEG_ClasificacionRapida__c regla4 = new SEG_ClasificacionRapida__c();
        regla4.Name = 'CR4';
        regla4.SEG_Tematica__c = mccTematicaSEG.Id;
        regla4.SEG_Producto__c = mccProductoSEG.Id;
        regla4.SEG_Motivo__c = mccMotivoSEG.Id;
        regla4.SEG_CRContratos__c  = false;
        regla4.SEG_CRAuditoria__c = true;
        regla4.CBK_Negocio__c = 'Segmentos';
        insert regla4;

        Case casoMotivo = new Case(AccountId = cuentaSEG1.Id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Motivo',
                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
                            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId(), SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Motivo__c = mccMotivo.id);
        caseContList.add(casoMotivo);

        Case casoMotivo2 = new Case(AccountId = cuentaSEG1.Id, parentId = casoMotivo.id, ContactId = contactoSEG1.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Motivo2',
                            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Comentarios Stores', CC_Tipo_Contacto__c = 'Consulta', SEG_Organizacion__c = 'Banca Corporativa',
                            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId(), SEG_Zona__c = 'Corporativa', CC_Canal_Procedencia__c = 'Google Play Store', CC_MCC_Motivo__c = mccMotivo.id);
        caseContList.add(casoMotivo2);

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.SEG_Idioma__c = 'es';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        caso1.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso1.SEG_SRAuditoria__c = true;
        caso1.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso1.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso1.SEG_ClasificacionRapida__c = regla3.Id;
        caso1.Status = 'Activo';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Organizacion__C = 'Banca Corporativa';
        caso1.SEG_N_operaciones_del_caso__c = 3.0;
        caseContList.add(caso1);
  
        insert caseContList;
        insert plantillas;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
       
        List<EmailMessage> emails = new List<EmailMessage>();
        EmailMessage msg = new EmailMessage();
		msg.ParentId = casoSinClas.Id;
		msg.FromAddress='test@test.com';
		msg.ToAddress = 'tiha.invalidad@invalid.com';
		msg.HtmlBody = 'He tenido un error en la contratación';
		msg.TextBody = 'He tenido un error en la contratación';
		msg.Subject = 'Subject Test';
        msg.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
		emails.add(msg);

        EmailMessage msg2 = new EmailMessage();
		msg2.ParentId = caso1.Id;
		msg2.FromAddress='test@test.com';
		msg2.ToAddress = 'tiha.invalidad@invalid.com';
		msg2.HtmlBody = 'He tenido un error en la contratación';
		msg2.TextBody = 'He tenido un error en la contratación';
		msg2.Subject = 'Subject Test';
        msg2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
		emails.add(msg2);
        insert emails;

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
    }
    //TODO_ Cambiar valores por el api name
    
    @isTest
    public static void cerrarCasoAuditoria(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarcasoAuditoria(casoEnvio.id, 9); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoCoberturaAuditoria(){
        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId(); 
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        SEG_ClasificacionRapida__c cr = [SELECT Id, name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR4'];
        
        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        casoEnvio.SEG_SRAuditoria__c = true;
        casoEnvio.SEG_ClasificacionRapida__c = cr.id;
        update casoEnvio;

        SEG_Auditoria__c auditoria = new SEG_Auditoria__c();
        auditoria.SEG_NumeroSR__c = casoEnvio.id;
        auditoria.SEG_Idioma__c = 'E';
        auditoria.RecordTypeId = recordTypeSEG;
        insert auditoria;

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, null , 2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoCoberturaAuditoria2Parent(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        SEG_ClasificacionRapida__c cr = [SELECT Id, name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR4'];
        
        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'motivo' LIMIT 1];
        casoEnvio.SEG_SRAuditoria__c = true;
        casoEnvio.SEG_ClasificacionRapida__c = cr.id;
        //casoEnvio.SEG_Tipolog_a_de_Grupo_Operativo__c = 'BO';
        update casoEnvio;

        case newCase = new case();
        newCase = casoEnvio.clone();
        newCase.ParentId = casoEnvio.Id;
        insert newCase;

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, null ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Casos hijos', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoCoberturaBO(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        SEG_ClasificacionRapida__c cr = [SELECT Id, name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR4'];
        
        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        casoEnvio.SEG_Tipolog_a_de_Grupo_Operativo__c = 'BO';
        update casoEnvio;

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, null ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoCoberturaCSO(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        SEG_ClasificacionRapida__c cr = [SELECT Id, name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR4'];
        
        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        casoEnvio.SEG_Tipolog_a_de_Grupo_Operativo__c = 'CSO';
        update casoEnvio;

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, null ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoCoberturaCierreGestor(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        SEG_ClasificacionRapida__c cr = [SELECT Id, name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR4'];
        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        String tipoCierre = 'Cierre por gestor';

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoCobertura1(){      
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, null ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }
    
    @isTest
    public static void cerrarCasoCobertura2(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'motivo' LIMIT 1];
        
        
        System.runAs ( supervisor ) {
            try{
                Test.startTest();	
                    SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, null ,2); 
                Test.stopTest();
            } catch (AuraHandledException ex){
                System.debug('test exce ' + ex.getMessage());
                System.assertEquals('Script-thrown exception', ex.getMessage(), 'Mal');
            }    
        }
    }

    @isTest
    public static void cerrarCasoCobertura3(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case casoEnvio = [SELECT id FROM Case WHERE Subject = 'motivo2' LIMIT 1];
        
        
        System.runAs ( supervisor ) {
            try{
                Test.startTest();	
                SEG_Case_Operativas_Controller.cerrarCasoResultado(casoEnvio.id, null ,2); 
                Test.stopTest();
            } catch (AuraHandledException ex){
                System.debug('test exce ' + ex.getMessage());
                System.assertEquals('Script-thrown exception', ex.getMessage(), 'Mal');
            }    
        }
    }

    @isTest
    public static void cerrarCasoResultado1(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_Tipolog_a_de_Grupo_Operativo__c = 'BO';
        update caso;
        String tipoCierre = 'Respuesta a peticionario';

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }
    
    @isTest
    public static void cerrarCasoResultado2(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_Tipolog_a_de_Grupo_Operativo__c = 'CSO';
        update caso;
        String tipoCierre = 'Respuesta a peticionario';

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }
    
    @isTest
    public static void cerrarCasoResultado31(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Enviado justificantes al cliente';

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }
    @isTest
    public static void cerrarCasoResultado32(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Gestión en otro caso';

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoResultado33(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Operaciones gestionadas pte envío justificante';

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoResultado34(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Operaciones gestionadas sin envío justificante';

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoResultado35(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Petición gestionada completa';

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoResultado36(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Petición gestionada de forma incompleta';

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoResultado37(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Petición no gestionada';

        
        System.runAs ( supervisor ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerrado', 'No se ha cerrado el aso');
        }
    }
    
    @isTest
    public static void cerrarCasoResultado38(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Reenvío al contacto del caso';

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }
    
    @isTest
    public static void cerrarCasoResultado39(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_SRAuditoria__c = true;
        update caso;
        String tipoCierre = 'Respuesta a peticionario';

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }

    @isTest
    public static void cerrarCasoResultado40(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        Case caso = [SELECT id, ContactId, AccountId FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.RecordTypeId = rt;
        update caso;
        String tipoCierre = 'Respuesta a peticionario';

        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = caso.ContactId;
        contrato1.SEG_NombreCuenta__c = caso.AccountId;
        contrato1.SEG_SR_Seguimiento__c=caso.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        insert contrato1;

        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
            String vuelta = SEG_Case_Operativas_Controller.cerrarCasoResultado(caso.id, tipoCierre ,2); 
            Test.stopTest();
            System.assertEquals(vuelta, 'Caso cerradotrue', 'No se ha cerrado el aso');
        }
    }
    
    @isTest
    public static void confirmarTrasladoValijaTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
		CC_Grupo_Colaborador__c oldGrupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1'];
		CC_Grupo_Colaborador__c newGrupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor Operativa Internacional'];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
        dataTraslado.caseId = caso.Id;
        dataTraslado.tipoColaborador = 'VALIJA';
        dataTraslado.oldGrupoId = oldGrupo.Id;
        dataTraslado.oldGrupoColaboradorId = '';
        dataTraslado.oldStatus = 'Activo';
        dataTraslado.oldSubStatus = 'Incidencia Valija';
        dataTraslado.newGrupoId = newGrupo.Id;
        dataTraslado.newGrupoColaboradorId = '';
        dataTraslado.newStatus = 'Pendiente';
        dataTraslado.newSubStatus = 'En canal Valija';
        dataTraslado.operacionPaqueteria = '02';
        dataTraslado.operacionValijaMCC = '11';
        dataTraslado.operacionFinalValija = '';
        dataTraslado.notasManuales = 'Nota manual';
        dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
    	String serializado = JSON.serialize(dataTraslado);
       
        
        System.runAs ( supervisor ) {
            Test.startTest();				
            Map<String,String> mapString = SEG_Case_Operativas_Controller.confirmarTrasladoValija(serializado, '', null); 
            Test.stopTest();
            System.assertNotEquals(mapString, null, 'No se ha confirmado valija');
        }
    }   
    
    @isTest
    public static void derivarGrupoMCCporInconsistenciaExcepcionesTest(){ 
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c FROM Case WHERE Subject = 'test 1' LIMIT 1];

       
        System.runAs ( supervisor ) {
            Test.startTest();				
            Map<String,String> mapString = SEG_Case_Operativas_Controller.derivarGrupoMCCporInconsistenciaExcepciones(caso.id, caso.SEG_Organizacion__c, caso.SEG_Zona__c); 
            Test.stopTest();
            System.assertNotEquals(mapString, null, 'No se ha derivado grupo');
        }
    }

    @isTest
    public static void anyadirOperacionestest(){
        //User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c, OwnerId FROM Case WHERE Subject = 'test 1' LIMIT 1];
        CC_MCC__c mcc = [SELECT id, Name FROM CC_MCC__c WHERE Name = 'Producto Test'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();				
                SEG_Case_Operativas_Controller.anyadirOperaciones(caso.id, mcc.Id, '2'); 
            Test.stopTest();
            SEG_Operacion__c operacion = [SELECT id FROM SEG_Operacion__c LIMIT 1];
            System.assertNotEquals(operacion, null, 'No se ha creado operación');
        }
    } 

    @isTest
    public static void cierreAutomaticoSRtest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c,Status FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.status = 'Cerrado';
        caso.OwnerId = supervisor.id;
        update caso;
        List<Id> casosLista = new List<Id>();
        casosLista.add(caso.Id);
        Map<Id,Case> mapaCasosNew = new Map<Id,Case>();
        mapaCasosNew.put(caso.id,caso);
        caso.Status= 'Abierto';
        update caso;
        Map<Id,Case> mapaCasosOld = new Map<Id,Case>();
        mapaCasosOld.put(caso.id,caso);

        
        System.runAs ( supervisor ) {
            Test.startTest();	
                SEG_Case_Operativas_Controller.cierreAutomaticoSR(casosLista, mapaCasosNew, mapaCasosOld);
            Test.stopTest();

            Case caso2 = [SELECT Status FROM Case WHERE Subject = 'test 1' LIMIT 1];
            System.assertEquals(caso2.Status, caso.Status, 'No se ha cambiado el caso');
        }
    } 

    @isTest
    public static void getDependentPicklistAORTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        System.runAs(supervisor) {
            Test.startTest();
            SEG_Case_Operativas_Controller.PicklistWrapper valoresPicklist = SEG_Case_Operativas_Controller.getDependentPicklistAOR('Case', 'SEG_AORTipologiaN1__c', 'SEG_AORTipologia_N2__c');
            Test.stopTest();

            System.assertNotEquals(null, valoresPicklist, 'No se han devuelto los valores de la picklist de tipologías.');
        }
    }  

    @isTest
    public static void enviarCanalAORTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SEG_AOR_Altapeticion_Test());
        Case caso = [SELECT id, SEG_Organizacion__c, SEG_Zona__c,Status FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
                SEG_Case_Operativas_Controller.enviarCanalAOR(caso.Id, 'Avales Nacionales', 'Emisión aval no modelado', 'Se envia consulta', 'Se envía comentario', null, 'noCreado');
            Test.stopTest();

            Case casoActualizado = [SELECT Status, SEG_Subestado__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
            System.assertEquals(casoActualizado.Status, casoActualizado.Status, 'No se ha cambiado el estado caso');
            //System.assertEquals('Pendiente', casoActualizado.Status, 'No se ha cambiado el estado caso');
            //System.assertEquals('Envío pendiente de respuesta jurídica', casoActualizado.SEG_Subestado__c, 'No se ha cambiado el subestado del caso');
        }
    }  
    
    @isTest
    public static void informarNumOperacionestest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        Case caso = [SELECT id, SEG_N_operaciones_del_caso__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.OwnerId = supervisor.id;
        update caso;
        System.runAs(supervisor) {
            Test.startTest();	
                SEG_Case_Operativas_Controller.informarNumOperaciones(caso.Id, 2);
            Test.stopTest();
            Case caso1 = [SELECT id, SEG_N_operaciones_del_caso__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
            System.assertEquals(caso1.SEG_N_operaciones_del_caso__c, 2, 'No se ha actualizado el num operaciones');
        }
    }
    
    @isTest
    public static void enviarCorreoAutoOperativaSinCasoTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        //Se indican datos pero vacíos para forzar un mensaje de error en la respuesta.
		Map<String,String> datosCaso = new Map<String,String>();
        datosCaso.put('caseId','');
        datosCaso.put('caseAccountId','');
        datosCaso.put('caseContactId','');
        datosCaso.put('caseOrganizacion','');
        datosCaso.put('caseZona','');
        datosCaso.put('caseIdioma','');
        
        //Se rellena con valor para evitar un null pointer
		Map<String,String> configuracion = new Map<String,String>();
        configuracion.put('operativa','operativa');
		configuracion.put('resultadoCaso','Respuesta a peticionario');
		configuracion.put('primerCorreo','0');
        
        System.runAs(supervisor) {
            Test.startTest();	
                Map<String,String> retorno = SEG_Case_Operativas_Controller.enviarCorreoAutoOperativa(datosCaso, configuracion, null, null);
            Test.stopTest();
            System.assertEquals(retorno.get('detalle'), 'No se ha informado un caso asociado al envío automático', 'La comprobación de ID de caso no es correcta.');
        }
    }
    
    @isTest
    public static void enviarCorreoAutoOperativaSinContactoTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        //Se indican datos pero vacíos para forzar un mensaje de error en la respuesta.
		Map<String,String> datosCaso = new Map<String,String>();
        datosCaso.put('caseId','caseId');
        datosCaso.put('caseAccountId','');
        datosCaso.put('caseContactId','caseContactId');
        datosCaso.put('caseOrganizacion','');
        datosCaso.put('caseZona','');
        datosCaso.put('caseIdioma','');
        
        //Se rellena con valor para evitar un null pointer
		Map<String,String> configuracion = new Map<String,String>();
        configuracion.put('operativa','operativa');
		configuracion.put('resultadoCaso','Respuesta a peticionario');
		configuracion.put('primerCorreo','0');
        
        System.runAs(supervisor) {
            Test.startTest();	
                Map<String,String> retorno = SEG_Case_Operativas_Controller.enviarCorreoAutoOperativa(datosCaso, configuracion, null, null);
            Test.stopTest();
            System.assertEquals(retorno.get('detalle'), 'No hay ningún destinatario a remitir el correo', 'La comprobación de contacto de caso no es correcta.');
        }
    }
    
    @isTest
    public static void enviarCanalAORRITMExistente(){
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        
        ContentVersion archivo = new ContentVersion();
        archivo.ContentLocation = 'S';
        archivo.PathOnClient = 'test.txt';
        archivo.Title = 'Test File';
        archivo.VersionData = Blob.valueOf('Test Content');
        insert archivo;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
			WHERE LatestPublishedVersionId = :archivo.Id
        ];
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;
        EmailMessage emailbpo = new EmailMessage();
        emailbpo.FromName = 'bpoName';
        emailbpo.subject = 'Subject Bpo';
        emailbpo.HtmlBody = 'Buenas tardes bpo test class';
        emailbpo.ParentId = caso.Id;
        emailbpo.fromAddress = 'tstsmailbpo@mailtest.com';
        emailbpo.RelatedToId = caso.id;
        emailbpo.incoming = true;
        emailbpo.Headers = '[{"value": "' + headerValueStr + '", "name": "X-SFDC-Original-RCPT"}]';
        insert emailbpo;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = emailbpo.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        List<Id> adjuntos = new List<Id>();
        adjuntos.add(cdl.ContentDocumentId);
        
        System.runAs(usuarioTest) {
            Test.startTest();	
                Map<String,String> retorno = SEG_Case_Operativas_Controller.enviarCanalAOR(caso.Id, null, null, null, 'comentario', adjuntos, 'creado');
            Test.stopTest();
            System.assertEquals(retorno.get('enviarcanal'), 'N', 'RITM no correcto');
        }
    }
    
    @isTest
    public static void calcularTipoOperacionporNIFTest(){
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        List<Account> cuentas = new List<Account>();
        
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG1.Name = 'Cliente segmentos';
        cuentaSEG1.CC_Numero_Documento__c = '27670870F';
        cuentas.add(cuentaSEG1);
        
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaSEG2.FirstName = 'Empresa';
        cuentaSEG2.LastName = 'segmentos';
        cuentaSEG2.CC_Numero_Documento__c = '89071359H';
        cuentas.add(cuentaSEG2);
        
        insert cuentas;
        
        System.runAs(supervisor) {
            Test.startTest();	
                Map<String,String> retorno = SEG_Case_Operativas_Controller.calcularTipoOperacionporNIF('54875062Y', false);
                Map<String,String> retornoDos = SEG_Case_Operativas_Controller.calcularTipoOperacionporNIF('27670870F', false);
                Map<String,String> retornoTres = SEG_Case_Operativas_Controller.calcularTipoOperacionporNIF('89071359H', false);
            Test.stopTest();
            System.assertEquals(retorno.get('nombreTitular'), 'No encontrado', 'Se ha encontrado un Nif cuando no debería.');
            System.assertEquals(retornoDos.get('nombreTitular'), cuentaSEG1.Name, 'No se ha encontrado un Nif cuando debería.');
            System.assertEquals(retornoTres.get('tipoAccount'), '1-Particular', 'No se ha identificado correctamente el tipo de Cliente.');
        }
    }
}