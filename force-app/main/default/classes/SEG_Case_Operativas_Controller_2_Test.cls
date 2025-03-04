@isTest
public class SEG_Case_Operativas_Controller_2_Test {

    @TestSetup
    public static void crearDatosPrueba()  {
        
        List<Case> caseContList = new List<Case>();
        List<SEG_Plantilla__c> plantillas = new List<SEG_Plantilla__c>();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id idDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id grupoAutoSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        Id accountId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id accountGrupoGestor = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id contactId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
        Id recordTexto = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();


        Id recordTypeIdTematica = tematicaId;
        CC_MCC__c mccTematicaSEGTOS = new CC_MCC__c();
		mccTematicaSEGTOS.Name = 'Segmentos';
        mccTematicaSEGTOS.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEGTOS.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEGTOS.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEGTOS.CC_Codigo_Externo__c = 'TE-100008';
        insert mccTematicaSEGTOS;

        Id recordTypeIdProducto = productoId;
        CC_MCC__c mccProductoSEGTOS = new CC_MCC__c();
        mccProductoSEGTOS.Name = 'No procede';
        mccProductoSEGTOS.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEGTOS.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEGTOS.RecordTypeId = recordTypeIdProducto;
        mccProductoSEGTOS.CC_Tematica__c = mccTematicaSEGTOS.Id;
        mccProductoSEGTOS.CC_Codigo_Externo__c = 'PR-100008'; 
        
        insert mccProductoSEGTOS; 
        
        Id recordTypeIdMotivo = motivoId;
       	CC_MCC__c mccMotivoSEGTOS = new CC_MCC__c();
        mccMotivoSEGTOS.Name = 'No procede';
        mccMotivoSEGTOS.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEGTOS.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEGTOS.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEGTOS.CC_Tematica__c = mccTematicaSEGTOS.Id;
        mccMotivoSEGTOS.CC_Producto_Servicio__c = mccProductoSEGTOS.Id;
        mccMotivoSEGTOS.CC_Codigo_Externo__c = 'MO-100008';
        insert mccMotivoSEGTOS;

        Id recordTypeIdDetalle = idDetalle;
       	CC_MCC__c mccDetalleSEGTOS = new CC_MCC__c();
        mccDetalleSEGTOS.Name = 'No procede';
        mccDetalleSEGTOS.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEGTOS.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEGTOS.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEGTOS.CC_Tematica__c = mccTematicaSEGTOS.Id;
        mccDetalleSEGTOS.CC_Producto_Servicio__c = mccProductoSEGTOS.Id;
        mccDetalleSEGTOS.CC_Motivo__c = mccMotivoSEGTOS.Id;
        mccDetalleSEGTOS.CC_Codigo_Externo__c = 'DE-100008';
        insert mccDetalleSEGTOS;

        SEG_ClasificacionRapida__c regla3 = new SEG_ClasificacionRapida__c();
        regla3.Name = 'No procede';
        regla3.SEG_Tematica__c = mccTematicaSEGTOS.Id;
        regla3.SEG_Producto__c = mccProductoSEGTOS.Id;
        regla3.SEG_Motivo__c = mccMotivoSEGTOS.Id;
        regla3.SEG_Detalle__c = mccDetalleSEGTOS.Id;
        regla3.SEG_CRContratos__c  = false;
        regla3.CBK_Negocio__c = 'Segmentos';
        regla3.SEG_CRAuditoria__c = false;
        insert regla3;

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
            Name = 'GrupoSegOp1',
            RecordTypeId = grupoOpSegId
        );
        grupos.add(grupoCol1);

        CC_Grupo_Colaborador__c grupoDatos = new CC_Grupo_Colaborador__c(
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
            Name = 'GrupoSegOp1',
            RecordTypeId = grupoOpSegId,
            SEG_GrupoSegmentos__c = true,
            SEG_No_visible__c = false,
            SEG_Inactivo__c = false
        );
        grupos.add(grupoDatos);

        CC_Grupo_Colaborador__c grupoBoAst = new CC_Grupo_Colaborador__c();
            grupoBoAst.Name = 'BO*';
            grupoBoAst.RecordTypeId = grupoAutoSegId;
            grupoBoAst.SEG_Zona__c = 'Corporativa';
            grupoBoAst.SEG_Organizacion__C = 'Banca Corporativa';
        grupos.add(grupoBoAst);

        CC_Grupo_Colaborador__c grupoGestComer = new CC_Grupo_Colaborador__c();
            grupoGestComer.Name = 'Gestor Comercial';
            grupoGestComer.RecordTypeId = grupoAutoSegId;
        grupos.add(grupoGestComer);

        CC_Grupo_Colaborador__c gestorOperNaci = new CC_Grupo_Colaborador__c();
            gestorOperNaci.Name = 'Gestor Operativa Nacional';
            gestorOperNaci.RecordTypeId = grupoAutoSegId;
        grupos.add(gestorOperNaci);

        CC_Grupo_Colaborador__c gestorFinancEstruct = new CC_Grupo_Colaborador__c();
            gestorFinancEstruct.Name = 'Gestor Financiación Estructurada';
            gestorFinancEstruct.RecordTypeId = grupoAutoSegId;
        grupos.add(gestorFinancEstruct);

        CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
            grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
            grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
        grupos.add(grupoGestorOperativaInternacional);

        insert grupos;

        List<Account> cuentas = new List<Account>();
        Account acc = new Account(
            Name = 'account',
            RecordTypeId = accountId
        );
        cuentas.add(acc);

        Contact contacto = new Contact(
            AccountId = acc.id,
            LastName = 'Empleado',
            RecordTypeId = contactId,
            CC_Idioma__c = 'ca'
        );
        insert contacto;

        SEG_Gestor_Grupo__c gestorGrupo = new SEG_Gestor_Grupo__c();
            gestorGrupo.SEG_EmpleadoGestor__c = contacto.id;
            gestorGrupo.SEG_GrupoOperativa__c = grupoDatos.Id;
        insert gestorGrupo;

        Account centro = new Account();
            centro.RecordTypeId = accountId;
            centro.Name = 'Oficina 00001';
            centro.CC_Numero_Oficina_Empresa__c = '001-00001';
            centro.SEG_Organizacion__c = 'Banca Corporativa';
            centro.SEG_Zona__c = 'Corporativa';
        insert centro;

        Account account = new Account(
            Name = 'acc',
            CC_Numero_Oficina__c = '001',
            RecordTypeId = accountGrupoGestor,
            SEG_CentroSegmento__c = acc.id,
            //AV_EAPGestor__c = contacto.id,
            SEG_GestorOperativaNacional__c = contacto.id,
            SEG_GestorOperativaInternacional__c = contacto.id,
            SEG_GestorFinEstructurada__c = contacto.id,
            SEG_Prioridad_Carterizacion_Segmentos__c = true,
            SEG_Oficina_Gestora_Segmentos__c = centro.id
        );
        insert account;

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
        insert plantillas;

        //Crear MCC para CR

        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
        mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = tematicaId;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000007';
        insert mccTematicaSEG;

        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'Producto1SEG';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = productoId;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000007';
        insert mccProductoSEG;

        CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'Motivo1SEG';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = motivoId;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000007';
        insert mccMotivoSEG;

        CC_MCC__c mccDetalleSEG = new CC_MCC__c();
        mccDetalleSEG.Name = 'Detalle1SEG';
        mccDetalleSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG.RecordTypeId = idDetalle;
        mccDetalleSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccDetalleSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccDetalleSEG.CC_Motivo__c = mccMotivoSEG.Id;
        mccDetalleSEG.CC_Codigo_Externo__c = 'DE-000007';
        insert mccDetalleSEG;

        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.RecordTypeId = motivoId;
        mccMotivo.Name = 'Motivo';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Codigo_Externo__c = 'DE-000004';
        insert mccMotivo;

        //Crear reclamaciones
        SEG_Reclamaciones__c recl2 = new SEG_Reclamaciones__c();
        recl2.Name = 'Testreclamaciones';
        recl2.SEG_Plazo1Reclamacion__c = 2;
        recl2.SEG_Plazo2Reclamacion__c = 3;
        recl2.SEG_Plazo3Reclamacion__c = 4;
        recl2.SEG_PlazoEnvioGestor__c = 4;
        recl2.SEG_PlazoLlamada__c = 1;
        insert recl2;

        SEG_ClasificacionRapida__c regla3TOS = new SEG_ClasificacionRapida__c();
        regla3TOS.Name = 'CR3';
        regla3TOS.SEG_Tematica__c = mccTematicaSEG.Id;
        regla3TOS.SEG_Producto__c = mccProductoSEG.Id;
        regla3TOS.SEG_Motivo__c = mccMotivoSEG.Id;
        regla3TOS.SEG_Detalle__c = mccDetalleSEG.Id;
        regla3TOS.SEG_CRContratos__c  = false;
        regla3TOS.CBK_Negocio__c = 'Segmentos';
        insert regla3TOS;

        // Creación cuentas a tratar.
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

        //Asignamos el RecordType ='Grupo Colaborador'
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador Externo';
        grupoRTGrupoCol.RecordTypeId = grColId;
        grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoCol;

        //Grupo MCC link Grupo Colaborador
        CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccMotivoSEG.Id;
        grupoCol.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        insert grupoCol;

        //Crear MCC para CR contratos

        CC_MCC__c mccTematicaSEG2 = new CC_MCC__c();
        mccTematicaSEG2.Name = 'Tematica1SEG2';
        mccTematicaSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG2.RecordTypeId = tematicaId;
        mccTematicaSEG2.CC_Codigo_Externo__c = 'TE-000008';
        insert mccTematicaSEG2;

        CC_MCC__c mccProductoSEG2 = new CC_MCC__c();
        mccProductoSEG2.Name = 'Producto1SEG2';
        mccProductoSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG2.RecordTypeId = productoId;
        mccProductoSEG2.CC_Tematica__c = mccTematicaSEG2.Id;
        mccProductoSEG2.CC_Codigo_Externo__c = 'PR-000008';
        insert mccProductoSEG2;

        CC_MCC__c mccMotivoSEG2 = new CC_MCC__c();
        mccMotivoSEG2.Name = 'Motivo1SEG2';
        mccMotivoSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG2.RecordTypeId = motivoId;
        mccMotivoSEG2.CC_Tematica__c = mccTematicaSEG2.Id;
        mccMotivoSEG2.CC_Producto_Servicio__c = mccProductoSEG2.Id;
        mccMotivoSEG2.CC_Codigo_Externo__c = 'MO-000008';
        insert mccMotivoSEG2;

        CC_MCC__c mccDetalleSEG2 = new CC_MCC__c();
        mccDetalleSEG2.Name = 'Detalle1SEG2';
        mccDetalleSEG2.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG2.RecordTypeId = idDetalle;
        mccDetalleSEG2.CC_Tematica__c = mccTematicaSEG2.Id;
        mccDetalleSEG2.CC_Producto_Servicio__c = mccProductoSEG2.Id;
        mccDetalleSEG2.CC_Motivo__c = mccMotivoSEG2.Id;
        mccDetalleSEG2.CC_Codigo_Externo__c = 'DE-000008';
        insert mccDetalleSEG2;

        SEG_ClasificacionRapida__c regla4 = new SEG_ClasificacionRapida__c();
        regla4.Name = 'CR4';
        regla4.SEG_Tematica__c = mccTematicaSEG2.Id;
        regla4.SEG_Producto__c = mccProductoSEG2.Id;
        regla4.SEG_Motivo__c = mccMotivoSEG2.Id;
        regla4.SEG_Detalle__c = mccDetalleSEG2.Id;
        regla4.SEG_ReclamacionesContratos__c = recl2.Id;
        regla4.SEG_CRContratos__c  = true;
        regla4.CBK_Negocio__c = 'Segmentos';
        insert regla4;

        SEG_Excepciones__c excepcion = new SEG_Excepciones__c();
        excepcion.RecordTypeId = recordAsig;
        excepcion.SEG_FechaActivacion__c  = Date.today().addDays(-2);
        excepcion.SEG_Organizacion__c = 'Banca Corporativa';
        excepcion.SEG_Zona__c = 'Corporativa';
        excepcion.SEG_Grupoasignado__c = grupoGestorOperativaInternacional.Id;
        insert excepcion;

        Case casoMotivo = new Case(AccountId = cuentaSEG1.Id,
                            ContactId = contactoSEG1.Id,
                            Status = 'Activo',
                            CC_Idioma__c = 'es',
                            Subject = 'Motivo',
                            CC_Tipo_Cliente__c = 'Cliente',
                            Origin = 'Email',
                            CC_Canal_Procedencia__c = 'Servicios Centrales',
                            CC_Tipo_Contacto__c = 'Consulta',
                            SEG_Organizacion__c = 'Banca Corporativa',
                            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId(),
                            SEG_Zona__c = 'Corporativa',
                            CC_MCC_Motivo__c = mccMotivo.id,
                            SEG_N_operaciones_del_caso__c = 1.0);
        caseContList.add(casoMotivo);

        Case casoSinClas = new Case(
            AccountId = account.id,
            Subject = 'caso0',
            SEG_Numero_de_centro__c = account.id,
            RecordTypeId = rt,
            SEG_Grupo__c = grupoCol1.id,
            SEG_Grupo_Anterior__c = grupoBoAst.id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso',
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa'
        );
        caseContList.add(casoSinClas);

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.SEG_Idioma__c = 'es';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        caso1.SEG_Grupo__c = grupoCol1.id;
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

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso2.AccountId = cuentaSEG1.Id;
        caso2.ContactId = contactoSEG1.Id;
        caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso2.SEG_Idioma__c = 'es';
        caso2.CC_AcuseRecibo__c ='1';
        caso2.Subject = 'test seg';
        caso2.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso2.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso2.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso2.SEG_ClasificacionRapida__c = regla4.Id;
        caso2.Status = 'Activo';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.SEG_Organizacion__C = 'Banca Corporativa';
        caseContList.add(caso2);

        Case caso3 = new Case();
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso3.AccountId = account.Id;
        caso3.ContactId = contacto.Id;
        caso3.SEG_Idioma__c = 'es';
        caso3.Subject = 'casoEmpleado';
        caso3.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso3.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso3.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso3.SEG_ClasificacionRapida__c = regla3.Id;
        caso3.Status = 'Activo';
        caso3.SEG_Zona__c = 'Corporativa';
        caso3.SEG_Organizacion__C = 'Banca Corporativa';
        caseContList.add(caso3);
        
        Case caso4 = new Case();
        caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso4.AccountId = account.Id;
        caso4.ContactId = contacto.Id;
        caso4.SEG_Idioma__c = 'es';
        caso4.Subject = 'casoNoZona';
        caso4.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso4.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso4.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso4.SEG_ClasificacionRapida__c = regla3.Id;
        caso4.Status = 'Activo';
        caseContList.add(caso4);
        insert caseContList;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        EmailMessage msg = new EmailMessage();
        msg.ParentId = caso1.Id;
        msg.FromAddress='test@test.com';
        msg.ToAddress = 'tiha.invalidad@invalid.com';
        msg.HtmlBody = 'He tenido un error en la contratación';
        msg.TextBody = 'He tenido un error en la contratación';
        msg.Subject = 'Subject Test';
        msg.Incoming = true;
        msg.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert msg;

        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='ABC.pdf';
        cv.SEG_Firmado__c = false;
        Blob b= Blob.toPdf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
        ];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = caso1.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                    emailencodingkey='UTF-8', lastname='Smith',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='testSEGBI@acme.com');
            insert thisUser;

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Supervisor'];
            insert new PermissionSetAssignment(AssigneeId = thisUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = thisUser.id, PermissionSetId = ps2.Id);
        }
    }
    
    // postOnChatterObject a null
    @isTest
    static void testpostOnChatterObjectNotaNull() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
  		Case caso = [SELECT Id FROM Case WHERE subject = 'caso0' LIMIT 1];
        SEG_NotasTipificadas__c nota = [SELECT Id FROM SEG_NotasTipificadas__c LIMIT 1];
        String observacion;
        
        Test.startTest();
            System.runAs (usuarioTest){
            	SEG_Case_Operativas_Controller.postOnChatter(caso.Id, observacion ,'Test Operativa',String.valueOf(nota.Id));
                String casoId =  caso.Id;
                // FeedItem feed = [SELECT Id FROM FeedItem WHERE ParentId = :casoId LIMIT 1];
                 System.assertNotEquals(null, caso.Id, 'No se ha insertado el feed item');
                }
        Test.stopTest();
	}
    
    // Método de prueba para verificar el caso en el que el grupo está habilitado.
    @isTest
    static void testGrupoHabilitado() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        // Crear un caso de prueba con datos simulados.
        Case caso = [SELECT Id FROM Case WHERE subject = 'caso0' LIMIT 1];
        
        Test.startTest();
            System.runAs (usuarioTest) {
        // Llamar a la función y verificar que devuelve false.
        System.assertEquals(false, SEG_Case_Operativas_Controller.comprobacionGrupo(caso.Id));
                }
        Test.stopTest();
    }
    
    // Método de prueba para verificar el caso en el que el grupo está deshabilitado.
    @isTest
    static void testGrupoDeshabilitado() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        // Crear un caso de prueba con datos simulados.
        Case caso = [SELECT Id FROM Case WHERE subject = 'test seg' LIMIT 1];
        
        Test.startTest();
            System.runAs (usuarioTest) {
        // Llamar a la función y verificar que devuelve true.
        System.assertEquals(true, SEG_Case_Operativas_Controller.comprobacionGrupo(caso.Id));
                }
        Test.stopTest();
    }
    
    // Método de prueba para verificar el caso en el que el grupo tiene una organización o zona nula.
    @isTest
    static void testGrupoNulo() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        // Crear un caso de prueba con datos simulados.
        Case caso = [SELECT Id FROM Case WHERE subject = 'casoNoZona' LIMIT 1];
        
         Test.startTest();
            System.runAs (usuarioTest) {
        // Llamar a la función y verificar que devuelve true.
        System.assertEquals(true, SEG_Case_Operativas_Controller.comprobacionGrupo(caso.Id));
                    }
        Test.stopTest();
    }

    @isTest
    public static void autoAsignarGrupo1Test(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id,SEG_Grupo__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
        Test.startTest();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                SEG_Case_Operativas_Controller.autoAsignarGrupo(caso.id);
            }
        Test.stopTest();
        Case caso2 = [SELECT id,SEG_Grupo__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.assertEquals(caso.SEG_Grupo__c, caso2.SEG_Grupo__c, 'El grupo no ha cambiado');
    }

    @isTest
    public static void autoAsignarGrupo2Test(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_Grupo_Colaborador__c grupoUpdate = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Externo' LIMIT 1];
        grupoUpdate.SEG_TipoColaboradorWS__c = 'VALIJA';
        update grupoUpdate;

        Case caso = [SELECT id, SEG_Grupo__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_Case_Operativas_Controller.autoAsignarGrupo(caso.id);
        }
        Test.stopTest();
        Case caso2 = [SELECT id,SEG_Grupo__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.assertEquals(caso.SEG_Grupo__c, caso2.SEG_Grupo__c, 'El grupo no ha cambiado');
    }

    @isTest
    public static void autoasignarGrupoPaqueteriaTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_Grupo_Colaborador__c grupoUpdate = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Externo' LIMIT 1];
        grupoUpdate.SEG_TipoColaboradorWS__c = 'VALIJA';
        update grupoUpdate;

        Case caso = [SELECT id, SEG_Grupo__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_Case_Operativas_Controller.autoAsignarGrupoPaqueteria(caso.id, true);
        }
        Test.stopTest();
        Case caso2 = [SELECT id,SEG_Grupo__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.assertEquals(caso.SEG_Grupo__c, caso2.SEG_Grupo__c, 'El grupo no ha cambiado');
    }

    @isTest
    public static void fetchEmail(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            Map<id,String> mapCase = SEG_Case_Operativas_Controller.fetchEmailsCaso(caso.id);

            Test.stopTest();
        System.assertNotEquals(mapCase, null, 'No se han traído resultados');
        }
    }

    @isTest
    public static void recuperarResultados(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();

            List<String> lstString = SEG_Case_Operativas_Controller.recuperarResultados();
            Test.stopTest();
            System.assertNotEquals(lstString, null, 'No se han traído resultados');
        }
    }

    @isTest
    public static void rechazarSR(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case LIMIT 1];
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_Case_Operativas_Controller.rechazarCaso(caso.Id);
        }
        Test.stopTest();
        Case caso2 = [SELECT id, Status FROM Case LIMIT 1];
        System.assertEquals(caso2.Status, 'Descartado', 'No se han cambiado el estado');
    }

    @isTest
    public static void asignarGrupoAsterisco(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case LIMIT 1];
        caso.SEG_Numero_centro__c='001';
        update caso;
        CC_Grupo_Colaborador__c grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'BO*' LIMIT 1];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        String retorno = SEG_Case_Operativas_Controller.asignarGrupo(caso.Id, grupo.Id);
        Test.stopTest();
        System.assertNotEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void asignarGrupoAutomaticoSeg(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id ,subject FROM Case WHERE Subject = 'caso0' LIMIT 1];
        caso.SEG_Numero_centro__c='001';
        update caso;
        CC_Grupo_Colaborador__c grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor Comercial' LIMIT 1];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        String retorno = SEG_Case_Operativas_Controller.asignarGrupo(caso.Id, grupo.Id);
        Test.stopTest();
        System.assertNotEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void asignarGrupoSinCaracter(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id ,subject, AccountId FROM Case WHERE Subject = 'caso0' LIMIT 1];
        caso.SEG_Numero_centro__c='001';
        update caso;
        Account cuenta =[SELECT Id, SEG_Prioridad_Carterizacion_Segmentos__c FROM account WHERE Id =: caso.AccountId];
        cuenta.SEG_Prioridad_Carterizacion_Segmentos__c = false;

        update cuenta;
        CC_Grupo_Colaborador__c grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor Comercial' LIMIT 1];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        String retorno = SEG_Case_Operativas_Controller.asignarGrupo(caso.Id, grupo.Id);
        Test.stopTest();
        System.assertNotEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void asignarGrupoGestorComercial(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Contact contact = [SELECT id FROM Contact WHERE LastName = 'Empleado' LIMIT 1];
        Case caso = [SELECT id,accountId FROM Case WHERE Subject = 'casoEmpleado' LIMIT 1];
        CC_Grupo_Colaborador__c gestorComercial = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor Comercial' LIMIT 1];
        SEG_Gestor_Grupo__c gestorGrupo = [SELECT id FROM SEG_Gestor_Grupo__c WHERE SEG_EmpleadoGestor__c =: contact.Id];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        String retorno = SEG_Case_Operativas_Controller.asignarGrupo(caso.Id, gestorComercial.Id);
        Test.stopTest();
        System.assertNotEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void asignarGrupoGestorOperativaNacional(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, Subject FROM Case WHERE Subject = 'casoEmpleado' LIMIT 1];
        Contact contact = [SELECT id FROM Contact WHERE LastName = 'Empleado' LIMIT 1];
        CC_Grupo_Colaborador__c gestorComercial = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor Operativa Nacional' LIMIT 1];
        SEG_Gestor_Grupo__c gestorGrupo = [SELECT id FROM SEG_Gestor_Grupo__c WHERE SEG_EmpleadoGestor__c =: contact.Id];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        String retorno = SEG_Case_Operativas_Controller.asignarGrupo(caso.Id, gestorComercial.Id);
        Test.stopTest();
        System.assertEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void asignarGrupoGestorOperativaInternacional(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, accountId FROM Case WHERE Subject = 'casoEmpleado' LIMIT 1];
        Contact contact = [SELECT id FROM Contact WHERE LastName = 'Empleado' LIMIT 1];

        CC_Grupo_Colaborador__c gestorComercial = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor Operativa Internacional' LIMIT 1];
        SEG_Gestor_Grupo__c gestorGrupo = [SELECT id FROM SEG_Gestor_Grupo__c WHERE SEG_EmpleadoGestor__c =: contact.Id];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        String retorno = SEG_Case_Operativas_Controller.asignarGrupo(caso.Id, gestorComercial.Id);
        Test.stopTest();
        System.assertEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void gestorFinanciacionEstructurada(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'casoEmpleado' LIMIT 1];
        Contact contact = [SELECT id FROM Contact WHERE LastName = 'Empleado' LIMIT 1];

        CC_Grupo_Colaborador__c gestorComercial = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor Financiación Estructurada' LIMIT 1];
        SEG_Gestor_Grupo__c gestorGrupo = [SELECT id FROM SEG_Gestor_Grupo__c WHERE SEG_EmpleadoGestor__c =: contact.Id];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        String retorno = SEG_Case_Operativas_Controller.asignarGrupo(caso.Id, gestorComercial.Id);
        Test.stopTest();
        System.assertEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void autoAsignarGrupoY(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, CC_MCC_Motivo__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Motivo' LIMIT 1];
        String observacion = '';

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Map<String,String> retorno = SEG_Case_Operativas_Controller.autoAsignarGrupo(caso.Id);
        Test.stopTest();
        System.assertNotEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void autoAsignarGrupoN(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, CC_MCC_Motivo__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'caso0' LIMIT 1];


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<String,String> retorno = SEG_Case_Operativas_Controller.autoAsignarGrupo(caso.Id);
        Test.stopTest();
        System.assertNotEquals(retorno, null, 'No se ha asignado un grupo');
        }

    }

    @isTest
    public static void controlarOrgZona(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, CC_MCC_Motivo__c, SEG_Zona__c, SEG_Organizacion__c FROM Case WHERE Subject = 'Motivo' LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Boolean hasOrgZona = SEG_Case_Operativas_Controller.initComponentOp(caso.Id).vControlarOrgZona;
            Test.stopTest();
            System.assertEquals(hasOrgZona, true, 'El caso no tiene zona');
        }

    }

    @isTest
    public static void recuperarDatos1(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case LIMIT 1];
        SEG_NotasTipificadas__c ntsTpf = [SELECT Id, Name FROM SEG_NotasTipificadas__c WHERE Name = 'prueba' LIMIT 1];
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_Case_Operativas_Controller.recuperarCaso(caso.Id);
            SEG_Case_Operativas_Controller.postOnChatter(caso.id, 'Observación ejemplo', 'Operativa ejemplo', ntsTpf.Id);
        }
        Test.stopTest();

        FeedItem feed = [SELECT id FROM FeedItem LIMIT 1];
        System.assertNotEquals(feed, null, 'No se ha insertado feed');
    }

    @isTest
    public static void recuperarDatos2(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE subject= 'test 1' LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        String status = SEG_Case_Operativas_Controller.devolverSegBO(caso.id);
        Test.stopTest();
        System.assertEquals(status, 'Actualizado', 'No se ha actualizado');
        }

    }

    @isTest
    public static void recuperarDatos3(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, SEG_Grupo__c FROM Case WHERE subject= 'test 1' LIMIT 1];
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_Case_Operativas_Controller.devolverGrupoAnterior(caso.id);
        }
        Test.stopTest();
        Case caso2 = [SELECT id, SEG_Grupo__c FROM Case WHERE subject= 'test 1' LIMIT 1];
        System.assertNotEquals(caso2.SEG_Grupo__c, caso.SEG_Grupo__c, 'No se ha actualizado el grupo');
    }

    @isTest
    public static void recuperarDatos4(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoSegOp1' LIMIT 1];


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        String grupoName = SEG_Case_Operativas_Controller.buscarGrupoColaborador(grupo.id);
        Test.stopTest();
        System.assertNotEquals(grupoName, null, 'No se ha encontrado el grupo');
        }

    }


    @isTest
    public static void getFilesCase(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        List<ContentVersion> listContent = SEG_Case_Operativas_Controller.getFilesCase(caso.Id);
        Test.stopTest();
        System.assertNotEquals(listContent, null, 'No se han encontrado archivos');
        }

    }

    @isTest
    public static void fetchCRSeguimientoControllerTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<id,String> mapString = SEG_Case_Operativas_Controller.fetchCRSeguimientoController();
        Test.stopTest();
        System.assertNotEquals(mapString, null, 'No se han encontrado clasificaciones');
        }

    }

    @isTest
    public static void crearCasos(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        SEG_ClasificacionRapida__c crObj = [Select Id from SEG_ClasificacionRapida__c where Name = 'CR3' Limit 1];
        //String listFiles= '["0"]';
        List<ContentVersion> lstCntVersion = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId, PathOnClient FROM ContentVersion LIMIT 1];
        String listFiles= '["'+String.valueOf(lstCntVersion[0].ContentDocumentId)+'"]';
        String listFilesnull = '0';
        String crId;


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<String,String> mapCasos = SEG_Case_Operativas_Controller.crearCasos(caso.Id,listFiles,crObj.Id);
        Test.stopTest();
        System.assertNotEquals(mapCasos, null, 'No se han creado casos');
        }

    }

    @isTest
    public static void crearCasosCRId(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        SEG_ClasificacionRapida__c crObj = [Select Id from SEG_ClasificacionRapida__c where Name = 'CR3' Limit 1];
        //String listFiles= '["0"]';
        List<ContentVersion> lstCntVersion = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId,PathOnClient FROM ContentVersion LIMIT 1];
        String listFiles= '["'+String.valueOf(lstCntVersion[0].ContentDocumentId)+'"]';


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Map<String,String> mapCasos = SEG_Case_Operativas_Controller.crearCasos(caso.Id,listFiles,crObj.Id);
            Test.stopTest();
            System.assertNotEquals(mapCasos, null, 'No se han creado casos');
        }

    }

    @isTest
    public static void crearCasosRecicladosTest(){
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        EmailMessage emMess = [SELECT Id FROM EmailMessage WHERE ParentId =: caso.Id LIMIT 1];
        //String listFiles= '["0"]';
        List<ContentVersion> lstCntVersion = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId,PathOnClient FROM ContentVersion LIMIT 1];
        String listFiles= '["'+String.valueOf(lstCntVersion[0].ContentDocumentId)+'"]';
        String listFilesnull = '0';
        String crId;

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            List<String> lstString = SEG_Case_Operativas_Controller.crearCasosReciclados(caso.Id,listFiles,emMess.Id);
            Test.stopTest();
            System.assertNotEquals(lstString, null, 'No se han creado casos');
        }
    }

    @isTest
    public static void crearCasoSeguimientoTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        SEG_ClasificacionRapida__c crObj = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];
        List<ContentVersion> lstCntVersion = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId,PathOnClient FROM ContentVersion LIMIT 1];
        String listFiles= '["'+String.valueOf(lstCntVersion[0].ContentDocumentId)+'"]';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Map<String, String> lstString = SEG_Case_Operativas_Controller.crearCasoSeguimiento(caso.Id,listFiles,crObj.Id, '1');
            Test.stopTest();
            System.assertNotEquals(lstString, null, 'No se han creado casos');
        }

    }

    @isTest
    public static void crearContratosTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test seg' LIMIT 1];
        String casoid = caso.id;
        String ids = '';
        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            SEG_Case_Operativas_Controller.crearContratos(casoid,2,caso.Id, ids);
        }
        Test.stopTest();
        SEG_Contratos__c contrato = [SELECT id FROM SEG_Contratos__c LIMIT 1];
        System.assertNotEquals(contrato, null, 'No se han creado contrato');
    }

    @isTest
    public static void buscadorCasesTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, CaseNumber FROM Case WHERE Subject = 'test 1' LIMIT 1];
        String searchkey = 'test 1';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
            List<Case> lstCase = SEG_Case_Operativas_Controller.buscadorCases(searchkey, caso.Id);
            List<Case> lstCaseNum = SEG_Case_Operativas_Controller.buscadorCases(caso.CaseNumber, null);
        Test.stopTest();
            System.assertNotEquals(lstCase, null, 'No se han traído casos');
            System.assertEquals(lstCaseNum[0].CaseNumber, caso.CaseNumber, 'No se han traído casos');
        }

    }

    @isTest
    public static void buscadorGruposTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        String searchkey = 'test 1';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<Id, CC_Grupo_Colaborador__c> mapGrupo = SEG_Case_Operativas_Controller.buscadorGrupos(caso.id, searchkey);
        Test.stopTest();
        System.assertNotEquals(mapGrupo, null, 'No se han enontrado grupos');
        }

    }

     @isTest
    public static void importarEmailsAnexos(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        List<Case> caso = [SELECT id FROM Case];
        SEG_ClasificacionRapida__c clasR = [SELECT id FROM SEG_ClasificacionRapida__c LIMIT 1];
        EmailMessage em = [SELECT id FROM EmailMessage LIMIT 1];
        //String listFiles= '["0"]';
        List<ContentVersion> lstCntVersion = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId,PathOnClient FROM ContentVersion limit 1];
        String listFiles= '["'+String.valueOf(lstCntVersion[0].ContentDocumentId)+'"]';
        String crId = clasR.id;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        List<String> lstString = SEG_Case_Operativas_Controller.importarEmailsAnexos(caso[0].Id,listFiles,em.id, caso[1].id);
        Test.stopTest();
        System.assertNotEquals(lstString, null, 'No se ha creado el caso');
        }

    }

        @isTest
    public static void checkBPOPermision(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Boolean permission = SEG_Case_Operativas_Controller.checkBPOPermision(caso.Id);
        Test.stopTest();
        System.assertNotEquals(permission, true, 'El caso no tiene permisos');
        }

    }

        @isTest
    public static void enviarCanalBPO(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, subject FROM Case WHERE subject = 'test 1' LIMIT 1];
        boolean status= true;


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<String,String> mapString = SEG_Case_Operativas_Controller.enviarCanalBPO(caso.id, status, null, null);
        Test.stopTest();
        System.assertNotEquals(mapString, null, 'No se ha enviado');
        }

    }

    @isTest
    public static void fetchNotasTipificadas(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case LIMIT 1];
        String listFiles= '';
        String crId;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<Id, String> mapIdString = SEG_Case_Operativas_Controller.fetchNotasTipificadas(caso.Id);
        Test.stopTest();
        System.assertNotEquals(mapIdString, null, 'No se han generado las notas');
        }

    }

    @isTest
    public static void recuperarGrupos(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE SEG_Subestado__c ='En curso' LIMIT 1];

        Test.startTest();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Map<Id, String> mapIdString = SEG_Case_Operativas_Controller.recuperarGrupos(caso.id);
        Test.stopTest();
        System.assertNotEquals(mapIdString, null, 'No se han recuperado los grupos');
        }

    }

    @isTest
    public static void envioCierre(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case casoEnvio = [SELECT id, ContactId,CC_Idioma__c, SEG_Organizacion__c,SEG_Zona__c, AccountID FROM Case WHERE Subject = 'test 1' LIMIT 1];


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        String mensj = SEG_Case_Operativas_Controller.envioCierre(casoEnvio, 'Respuesta a peticionario');
        Test.stopTest();
        System.assertEquals(mensj, 'No plantilla', 'Se ha enviado el correo');
        }
    }

    @isTest
    public static void desplanificarCasoTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            SEG_Case_Operativas_Controller.desplanificarCaso(caso.Id);
            Test.stopTest();
            Case caso2 = [SELECT id, SEG_Fecha_planificaci_n__c FROM Case WHERE Subject = 'test 1' LIMIT 1];
            System.assertEquals(caso2.SEG_Fecha_planificaci_n__c, null, 'No se ha actualizado el caso');
        }
    }

    @isTest
    public static void tomarPropiedadCasoOldTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id, ownerId FROM Case WHERE Subject = 'test 1' LIMIT 1];


        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Case_Operativas_Controller.tomarPropiedadCasoOld(caso.Id, caso.OwnerId);
        }
        Case caso2 = [SELECT id, Status FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.assertEquals(caso2.Status, 'Activo', 'No se ha actualizado el caso');
        Test.stopTest();

    }

    @isTest
    public static void controlarPermissionSetTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Boolean resultado = SEG_Case_Operativas_Controller.initComponentOp(caso.Id).vControlarPS;
            System.assertEquals(resultado, false, 'No se ha deshabilitado el caso');
            Test.stopTest();
        }


    }

    @isTest
    public static void recuperarMapResultadosTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<String,String> mapString = SEG_Case_Operativas_Controller.recuperarMapResultados();
        Test.stopTest();
        System.assertNotEquals(mapString, null, 'No se han encontrado resultados');
        }

    }


    @isTest
    public static void enviarCorreoAutoOperativaTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id,SEG_Resultado__C FROM Case WHERE Subject = 'test 1' LIMIT 1];
        caso.SEG_Resultado__c = 'Respuesta a peticionario';
        update caso;

        Case datosCaso = SEG_wsValijaCasosComunes.recuperarInformacionCaso (caso.Id);
            Map<String,String> mapaDatosCaso = new Map<String,String>();
            mapaDatosCaso.put('caseId', caso.Id);
            mapaDatosCaso.put('accountId', datosCaso?.AccountId);
            mapaDatosCaso.put('contactId', datosCaso?.ContactId);
            mapaDatosCaso.put('organizacion', datosCaso?.SEG_Organizacion__c);
            mapaDatosCaso.put('zona', datosCaso?.SEG_Zona__c);
            mapaDatosCaso.put('idiomaCaso', datosCaso?.CC_Idioma__c);

        Map<String,String> configuracion = new Map<String,String>();
            configuracion.put('operativa','Cierre');
            configuracion.put('resultadoCaso', caso.SEG_Resultado__c);
            configuracion.put('primerCorreo','1');

        List<String> emails = new List<String>();
        emails.add('test@mail.com');
        List<String> adjuntos = new List<String>();

        List<ContentDocument> document = [SELECT Id, Title, LatestPublishedVersionId, filetype, fileExtension FROM ContentDocument LIMIT 1];
        adjuntos.add(document[0].LatestPublishedVersionId);


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
        Map<String,String> mapString = SEG_Case_Operativas_Controller.enviarCorreoAutoOperativa(mapaDatosCaso, configuracion, emails, adjuntos);
        Test.stopTest();
        System.assertNotEquals(mapString, null, 'No se han encontrado resultados');
        }

    }

    @isTest
    public static void enviarCorreoAutoOperativaTest2(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id,SEG_Resultado__C FROM Case WHERE Subject = 'test 1' LIMIT 1];

        Case datosCaso = SEG_wsValijaCasosComunes.recuperarInformacionCaso (caso.Id);
            Map<String,String> mapaDatosCaso = new Map<String,String>();
            mapaDatosCaso.put('caseId', caso.Id);
            mapaDatosCaso.put('accountId', datosCaso?.AccountId);
            mapaDatosCaso.put('contactId', datosCaso?.ContactId);
            mapaDatosCaso.put('organizacion', datosCaso?.SEG_Organizacion__c);
            mapaDatosCaso.put('zona', datosCaso?.SEG_Zona__c);
            mapaDatosCaso.put('idiomaCaso', datosCaso?.CC_Idioma__c);

        Map<String,String> configuracion = new Map<String,String>();
            configuracion.put('operativa','Cierre');
            configuracion.put('resultadoCaso', caso.SEG_Resultado__c);
            configuracion.put('primerCorreo','1');

        List<String> emails = new List<String>();
        emails.add('test@mail.com');
        List<String> adjuntos = new List<String>();

        List<ContentDocument> document = [SELECT Id, Title, LatestPublishedVersionId, filetype, fileExtension FROM ContentDocument LIMIT 1];
        adjuntos.add(document[0].LatestPublishedVersionId);


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String,String> mapString = SEG_Case_Operativas_Controller.enviarCorreoAutoOperativa(mapaDatosCaso, configuracion, emails, adjuntos);
        Test.stopTest();
        System.assertNotEquals(mapString, null, 'No se han encontrado resultados');
        }

    }

    /*
    @isTest
    public static void controlarAccountTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();

        Boolean isDisabled = SEG_Case_Operativas_Controller.controlarAccount(caso.id);
        Test.stopTest();
        System.assertEquals(isDisabled, false, 'No se ha deshabilitado');
        }

    }

    @isTest
    public static void controlarAccountYContactTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();

        Boolean isDisabled = SEG_Case_Operativas_Controller.controlarAccountYContact(caso.id);

        Test.stopTest();
        System.assertEquals(isDisabled, false, 'No se ha deshabilitado');
        }
    }

    @isTest
    public static void controlarValijaSinEmailTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1' LIMIT 1];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();

        Boolean isDisabled = SEG_Case_Operativas_Controller.controlarValijaSinEmail(caso.id);

        Test.stopTest();
        System.assertEquals(isDisabled, false, 'No se ha deshabilitado');
        }
    }
    */

    @isTest
    public static void comprobarClienteCasoApex() {
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            Case caso = [SELECT Id FROM Case WHERE Subject = 'test 1' LIMIT 1];
            Map<String, Boolean> retorno = SEG_Case_Operativas_Controller.comprobarClienteCasoApex(caso.Id);
            Test.stopTest();

            System.assert(!retorno.isEmpty(), 'No se ha recuperado la info del cliente');
        }
    }
}