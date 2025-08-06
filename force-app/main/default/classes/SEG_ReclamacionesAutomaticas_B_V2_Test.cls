@isTest
public class SEG_ReclamacionesAutomaticas_B_V2_Test {
    @testSetup
    static void datosIniciales ()
    { 
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'email@test.com';
        contactoSEG1.CC_Idioma__c = 'es';
        insert contactoSEG1;

		Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id recordMotiv = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.RecordTypeId = recordDet;
        mccDetalle.Name = 'Detalle';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Codigo_Externo__c = 'DE-000003';
        insert mccDetalle;  
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.RecordTypeId = recordMotiv;
        mccMotivo.Name = 'Motivo';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Codigo_Externo__c = 'DE-000004';
        insert mccMotivo;  
        
        CC_MCC__c mccProdServ = new CC_MCC__c();
        mccProdServ.RecordTypeId = recordProdServ;
        mccProdServ.Name = 'ProdSev';
        mccProdServ.CC_Tipo_Cliente__c = 'Segmentos';
        mccProdServ.CC_Codigo_Externo__c = 'DE-000005';
        insert mccProdServ;  
        
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.RecordTypeId = recordTem;
        mccTematica.Name = 'Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Codigo_Externo__c = 'DE-000006';
        insert mccTematica; 
        
        CC_MCC__c mccTematicaColaborador = new CC_MCC__c();
        mccTematicaColaborador.RecordTypeId = recordTem;
        mccTematicaColaborador.Name = 'Tematica';
        mccTematicaColaborador.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaColaborador.CC_Codigo_Externo__c = 'DE-000007';
        insert mccTematicaColaborador; 
        
        Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();     
		List<CC_Grupo_Colaborador__c> lstGrupoColaborador = new List<CC_Grupo_Colaborador__c>();
        //Grupo Operativo Segmentos
        CC_Grupo_Colaborador__c grupoOpSeg = new CC_Grupo_Colaborador__c();
        grupoOpSeg.RecordTypeId = opSegId;
        grupoOpSeg.SEG_GrupoSegmentos__c = true;
        lstGrupoColaborador.add(grupoOpSeg);
        
        //Grupo Automático Segmentos
        CC_Grupo_Colaborador__c grupoAutoSeg = new CC_Grupo_Colaborador__c();
        grupoAutoSeg.Name = 'BO*';
        grupoAutoSeg.RecordTypeId = autoSegId;
        grupoAutoSeg.SEG_GrupoSegmentos__c = true;
        lstGrupoColaborador.add(grupoAutoSeg);
        
        //Gestor Comercial
        CC_Grupo_Colaborador__c grupoGestorComercial = new CC_Grupo_Colaborador__c();
        grupoGestorComercial.Name = 'Gestor Comercial';
        grupoGestorComercial.RecordTypeId = autoSegId;
        grupoGestorComercial.SEG_GrupoSegmentos__c = true;
        lstGrupoColaborador.add(grupoGestorComercial);
        
        //Gestor Operativa Nacional
        CC_Grupo_Colaborador__c grupoGestorOperativaNacional = new CC_Grupo_Colaborador__c();
        grupoGestorOperativaNacional.Name = 'Gestor Operativa Nacional';
        grupoGestorOperativaNacional.RecordTypeId = autoSegId;
        grupoGestorOperativaNacional.SEG_GrupoSegmentos__c = true;
        lstGrupoColaborador.add(grupoGestorOperativaNacional);
        
        //Gestor Operativa Internacional
        CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
        grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
        grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
        grupoGestorOperativaInternacional.SEG_GrupoSegmentos__c = true;
        lstGrupoColaborador.add(grupoGestorOperativaInternacional);
        
        //Gestor Financiación Estructurada
        CC_Grupo_Colaborador__c grupoGestorFinanciacionEstruct = new CC_Grupo_Colaborador__c();
        grupoGestorFinanciacionEstruct.Name = 'Gestor Financiación Estructurada';
        grupoGestorFinanciacionEstruct.RecordTypeId = autoSegId;
        grupoGestorFinanciacionEstruct.SEG_GrupoSegmentos__c = true;
        lstGrupoColaborador.add(grupoGestorFinanciacionEstruct);
		insert lstGrupoColaborador;
        
        //Asignamos el RecordType ='Grupo Colaborador'
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='BO*';
        grupoRTGrupoCol.RecordTypeId = autoSegId;
        grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoCol;
        
        //Grupo MCC link Grupo Colaborador
        CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccTematicaColaborador.Id; 
        grupoCol.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        insert grupoCol;
        
        //Relacionamos MCC con Grupos Colaborador
        CC_MCC_Grupo_Colaborador__c grupoDetalle = new CC_MCC_Grupo_Colaborador__c();
        grupoDetalle.Name = 'detalle';
        grupoDetalle.CC_MCC__c = mccDetalle.Id;
        grupoDetalle.CC_Grupo_Colaborador__c = grupoRTGrupoCol.Id;
        grupoDetalle.SEG_Zona__c = 'Todas';
        grupoDetalle.SEG_Organizacion__c = 'Todas';
        grupoDetalle.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
        insert grupoDetalle;
        
        CC_MCC_Grupo_Colaborador__c grupoMotivo = new CC_MCC_Grupo_Colaborador__c();
        grupoMotivo.Name = 'motivo';
        grupoMotivo.CC_MCC__c = mccMotivo.Id;
        grupoMotivo.CC_Grupo_Colaborador__c = grupoRTGrupoCol.Id;
        grupoMotivo.SEG_Zona__c = 'Todas';
        grupoMotivo.SEG_Organizacion__c = 'Banca Corporativa';
        grupoMotivo.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
        insert grupoMotivo;
        
        CC_MCC_Grupo_Colaborador__c grupoProdServ = new CC_MCC_Grupo_Colaborador__c();
        grupoProdServ.Name = 'prodServ';
        grupoProdServ.CC_MCC__c = mccProdServ.Id;
        grupoProdServ.CC_Grupo_Colaborador__c = grupoRTGrupoCol.Id;
        grupoProdServ.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
        insert grupoProdServ;
        
        CC_MCC_Grupo_Colaborador__c grupoTematica = new CC_MCC_Grupo_Colaborador__c();
        grupoTematica.Name = 'Tematica';
        grupoTematica.CC_MCC__c = mccTematica.Id;
        grupoTematica.CC_Grupo_Colaborador__c = grupoRTGrupoCol.Id;
        grupoTematica.SEG_Zona__c = 'Corporativa';
        grupoTematica.SEG_Organizacion__c = 'Banca Corporativa';
        grupoTematica.SEG_Grupo_respuesta__c = grupoRTGrupoCol.id;
        insert grupoTematica; 
        
        CC_MCC_Grupo_Colaborador__c grupoGesComer = new CC_MCC_Grupo_Colaborador__c();
        grupoGesComer.Name = 'Gestor Comercial';
        grupoGesComer.CC_MCC__c = mccTematica.Id;
        grupoGesComer.CC_Grupo_Colaborador__c = grupoGestorComercial.Id;
        insert grupoGesComer;
        
        CC_MCC_Grupo_Colaborador__c grupoGesOpNacional = new CC_MCC_Grupo_Colaborador__c();
        grupoGesOpNacional.Name = 'Gestor Operativa Nacional';
        grupoGesOpNacional.CC_MCC__c = mccTematica.Id;
        grupoGesOpNacional.CC_Grupo_Colaborador__c = grupoGestorOperativaNacional.Id;
        insert grupoGesOpNacional;
        
        CC_MCC_Grupo_Colaborador__c grupoGesOpInt = new CC_MCC_Grupo_Colaborador__c();
        grupoGesOpInt.Name = 'Gestor Operativa Internacional'; 
        grupoGesOpInt.CC_MCC__c = mccTematica.Id;
        grupoGesOpInt.CC_Grupo_Colaborador__c = grupoGestorOperativaInternacional.Id;
        insert grupoGesOpInt;
        
        CC_MCC_Grupo_Colaborador__c grupoGesFinEs = new CC_MCC_Grupo_Colaborador__c();
        grupoGesFinEs.Name = 'Gestor Financiación Estructurada';
        grupoGesFinEs.CC_MCC__c = mccTematica.Id;
        grupoGesFinEs.CC_Grupo_Colaborador__c = grupoGestorFinanciacionEstruct.Id;
        insert grupoGesFinEs;

		CC_Grupo_Colaborador_Contact__c grupColContact = new CC_Grupo_Colaborador_Contact__c();
		grupColContact.CC_Grupo_Colaborador__c = grupoGestorComercial.Id;
		grupColContact.CC_Usuario__c = UserInfo.getUserId();
		insert grupColContact;


        SEG_Reclamaciones__c recl = new SEG_Reclamaciones__c();
        recl.Name = 'Reclamacion 0';
        recl.OwnerId = UserInfo.getUserId();
        recl.SEG_Plazo1Reclamacion__c = 0;
        recl.SEG_Plazo2Reclamacion__c = 0;
        recl.SEG_Plazo3Reclamacion__c = 0;
        recl.SEG_PlazoEnvioGestor__c = 0;
        recl.SEG_PlazoLlamada__c = 0;
        insert recl;

        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c();
        clasRapida.SEG_Canaldeentrada__c = 'Email';
        /*clasRapida.SEG_Detalle__c
        clasRapida.SEG_Motivo__c*/
        clasRapida.SEG_CRContratos__c = true;
        clasRapida.SEG_ReclamacionesContratos__c = recl.Id;
        clasRapida.SEG_Organizacion__c = 'Banca Corporativa';
        insert clasRapida;

        // Crear casos de los clientes.
        List<Case> listadoCasos = new List<Case>();

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.Subject = 'test 1';
        caso1.Status = 'Cerrado';
        caso1.SEG_Organizacion__c = 'Banca Corporativa';
        caso1.SEG_Zona__c ='Corporativa';
		caso1.SEG_Grupo__c = grupoOpSeg.Id;
        caso1.SEG_ClasificacionRapida__c = clasRapida.Id;
		caso1.SEG_Detalle__c = mccDetalle.Id;
        listadoCasos.add(caso1);

        Case caso11 = new Case();
        caso11.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso11.AccountId = cuentaSEG1.Id;
        caso11.ContactId = contactoSEG1.Id;
        caso11.Subject = 'test 1 caso11';
        caso11.Status = 'Cerrado';
        caso11.SEG_Organizacion__c = 'Banca Corporativa';
        caso11.SEG_Zona__c ='Corporativa';
		caso11.SEG_Grupo__c = grupoOpSeg.Id;
		caso11.CC_MCC_ProdServ__c = mccProdServ.id;
        listadoCasos.add(caso11);

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso2.AccountId = cuentaSEG1.Id;
        caso2.ContactId = contactoSEG1.Id;
        caso2.Subject = 'test 1';
        caso2.Status = 'Cerrado';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c ='Corporativa';
		caso2.SEG_Grupo__c = grupoOpSeg.Id;
		caso2.CC_MCC_Tematica__c = mccTematica.id;
        listadoCasos.add(caso2);

		Case caso3 = new Case();
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso3.AccountId = cuentaSEG1.Id;
        caso3.ContactId = contactoSEG1.Id;
        caso3.Subject = 'test 1';
        caso3.Status = 'Cerrado';
        caso3.SEG_Organizacion__c = 'Banca Corporativa';
        caso3.SEG_Zona__c ='Corporativa';
		caso3.SEG_Grupo__c = grupoOpSeg.Id;
		caso3.CC_MCC_Tematica__c = mccTematica.id;
        listadoCasos.add(caso3);

        insert listadoCasos;

        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso1.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = system.today();
        contrato1.SEG_1a_Reclamacion_ejecutada_manualmente__c = false;
        contrato1.SEG_Fecha_1a_Reclamacion_Proceso__c = null;
        listadoContratos.add(contrato1);

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso1.Id;
        contrato2.SEG_Estado__c = 'No firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = system.today();
        contrato2.SEG_2a_Reclamacion_ejecutada_manualmente__c = false ;
        contrato2.SEG_Fecha_2a_Reclamacion_Proceso__c = null;
        listadoContratos.add(contrato2);

        SEG_Contratos__c contrato3 = new SEG_Contratos__c();
        contrato3.Name = 'Number3';
        contrato3.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato3.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato3.SEG_SR_Seguimiento__c=caso2.Id;
        contrato3.SEG_Estado__c = 'No Firmado';
        contrato3.SEG_Fecha_3_Reclamacion__c = system.today();
        contrato3.SEG_3a_Reclamacion_ejecutada_manualmente__c = false;
        contrato3.SEG_Fecha_3a_Reclamacion_Proceso__c = null;
		listadoContratos.add(contrato3);

		SEG_Contratos__c contrato4 = new SEG_Contratos__c();
        contrato4.Name = 'Number4';
        contrato4.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato4.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato4.SEG_SR_Seguimiento__c=caso2.Id;
        contrato4.SEG_Estado__c = 'No Firmado';
        contrato4.SEG_Fecha_Envio_Gestor__c = system.today();
        contrato4.SEG_Fecha_Envio_Gestor_Proceso__c = null;
		listadoContratos.add(contrato4);

		SEG_Contratos__c contrato5 = new SEG_Contratos__c();
        contrato5.Name = 'Number5';
        contrato5.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato5.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato5.SEG_SR_Seguimiento__c=caso3.Id;
        contrato5.SEG_Estado__c = 'No Firmado';
        listadoContratos.add(contrato5);

        insert listadoContratos;

        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test.pdf';
		cv.SEG_Firmado__c = false;
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = contrato1.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;


        EmailTemplate emailEs = new EmailTemplate();
        emailEs.DeveloperName='Reclamacion_1_1616749645917';
        emailEs.Encoding = 'ISO-8859-1';
        emailEs.FolderId = UserInfo.getUserId();
        emailEs.Subject = '[num_casos]';
        emailEs.IsActive = true;
        emailEs.Name = 'Reclamacion 1º';
        emailEs.TemplateType = 'custom';
        emailEs.TemplateStyle = 'none';
        emailEs.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert emailEs;
        }

        SEG_Plantilla__c plantilla = new  SEG_Plantilla__c();
        plantilla.Name =  'Plantilla reclamaciones';
        plantilla.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
        plantilla.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias';
        plantilla.SEG_TipoOperativa__c = 'Reclamaciones';
        plantilla.Reclamaciones__c = '1ª Reclamación';
        plantilla.SEG_Activa__c = true;
        plantilla.SEG_PlantillaCastellano__c='Firma BO';
        plantilla.SEG_PlantillaCatalan__c ='Firma CAT'; 
        plantilla.SEG_PlantillaIngles__c = 'Firma IN';
        plantilla.SEG_PlantillaEuskera__c = 'Firma EUSK';
        plantilla.SEG_PlantillaGalego__c = 'Firma GAL';
        plantilla.SEG_PlantillaCastellanoID__c = emailEs.Id;
        insert plantilla;

		//Creamos una plantilla para usar en RT = 'Grupo Colaborador'
        CC_Grupo_Colaborador_Plantilla__c plantillagrupo = new CC_Grupo_Colaborador_Plantilla__c();
        plantillagrupo.CC_Operativa__c= 'Trasladar';
        plantillagrupo.SEG_Plantilla__c=plantilla.id;
        plantillagrupo.CC_Grupo_Colaborador__c = grupoRTGrupoCol.id;
        insert plantillagrupo;

        CC_Caracteristica__c cc = new CC_Caracteristica__c();
        cc.Name='Reclamaciones Agotadas';
        cc.CC_Descripcion__c='Reclamaciones Agotadas';
        cc.CC_Fecha_vigencia_inicio__c = date.Today();
        cc.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        insert cc;
    }
    @isTest
	private static void startCalled() {
        List<sObject> result = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile profile = (Profile)result.get(0);
		User testUser = new User(
				Alias = 'Seg',
				Email = 'BatchSegmentos@Segmentos.com',
				LastName = 'testLastName',
				ProfileId = profile.Id,
				UserName = 'BatchSegmentos@Segmentos.com',
                emailencodingkey='UTF-8',
                languagelocalekey='en_US',
                localesidkey='en_US',
                timezonesidkey='America/Los_Angeles');
		insert testUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Supervisor'];
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();

            PermissionSetAssignment psAssign = new PermissionSetAssignment();
            psAssign.AssigneeId = testUser.id;
            psAssign.PermissionSetId = ps.Id;
            listPermissionSetAssignment.add(psAssign);

            PermissionSetAssignment psAssign2 = new PermissionSetAssignment();
            psAssign2.AssigneeId = testUser.id;
            psAssign2.PermissionSetId = ps2.Id;
            listPermissionSetAssignment.add(psAssign2);

            insert listPermissionSetAssignment;
        }

        List<SEG_Contratos__c> lstContrato1s = [SELECT Id, CreatedById, CreatedDate, Name, OwnerId, LastModifiedById,SEG_1a_Reclamacion_ejecutada_manualmente__c, 
                                                SEG_2a_Reclamacion_ejecutada_manualmente__c, SEG_3a_Reclamacion_ejecutada_manualmente__c, SEG_Centro__c, SEG_CIF__c,
                                                SEG_Descripcion__c, SEG_Estado__c, SEG_Fecha_1_Reclamacion__c,SEG_Fecha_1a_Reclamacion_Proceso__c,
                                                SEG_Fecha_2_Reclamacion__c, SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3_Reclamacion__c, SEG_Fecha_3a_Reclamacion_Proceso__c, 
                                                SEG_Fecha_Contrato__c, SEG_Fecha_Envio_Gestor__c, SEG_Fecha_Envio_Gestor_Proceso__c, SEG_Fecha_Firma__c, 
                                                SEG_Fecha_Parada_Reclamacion__c,SEG_Fecha_Recepcion_Original__c, SEG_Gestor_comercial__c, SEG_Idioma__c, 
                                                SEG_Motivo_No_Reclamacion__c,SEG_NombreCliente__c, 
                                                SEG_NombreCuenta__r.SEG_Prioridad_Carterizacion_Segmentos__c, SEG_NombreCuenta__r.SEG_Empleado_gestor_Segmentos__c, SEG_NombreCuenta__r.CC_EmpleadoGestorId__c,
                                                SEG_NombreCuenta__r.SEG_GestorOperativaNacional__c,SEG_NombreCuenta__c, SEG_NombreCuenta__r.SEG_GestorOperativaInternacional__c,SEG_NombreCuenta__r.SEG_GestorFinEstructurada__c, 
                                                SEG_NombreCuenta__r.CC_OficinaGestoraId__r.CC_Numero_Oficina__c, 
                                                SEG_NombreCliente__r.FirstName,SEG_NombreCliente__r.LastName, SEG_NombreCliente__r.Name, SEG_NombreCliente__r.CC_Idioma__c,SEG_NombreCliente__r.Email,
                                                SEG_Situacion_Contrato__c, SEG_SR_Seguimiento__c, SEG_SROriginal__c, SEG_Zona__c,SEG_SR_Seguimiento__r.Status,SEG_SR_Seguimiento__r.ContactId,SEG_SR_Seguimiento__r.AccountId,
                                                SEG_SR_Seguimiento__r.SEG_Organizacion__c,SEG_SR_Seguimiento__r.SEG_Zona__c,SEG_SR_Seguimiento__r.SEG_Grupo__c,SEG_SR_Seguimiento__r.SEG_Grupo_Empresa__c,
                                                SEG_SR_Seguimiento__r.SEG_ClasificacionRapida__c,SEG_SR_Seguimiento__r.CC_MCC_Motivo__c,SEG_SR_Seguimiento__r.CC_MCC_ProdServ__c,
                                                SEG_SR_Seguimiento__r.CC_MCC_Tematica__c,SEG_SR_Seguimiento__r.SEG_Numero_de_centro__c,SEG_SR_Seguimiento__r.SEG_Detalle__c
                                                FROM SEG_Contratos__c ];
        
        List<SEG_Contratos__c> contratoList = new List<SEG_Contratos__c>();
        for (SEG_Contratos__c contrato : lstContrato1s) { 
            if (contrato.Name == 'Number1'){
                contrato.SEG_Fecha_1_Reclamacion__c = date.today();
                contratoList.add(contrato);
            }
            if (contrato.Name == 'Number2'){
                contrato.SEG_Fecha_2_Reclamacion__c = date.today();
                contratoList.add(contrato);
            }
            if (contrato.Name == 'Number3'){
                contrato.SEG_Fecha_3_Reclamacion__c = date.today();
                contratoList.add(contrato);
            }
            if (contrato.Name == 'Number4'){
                contrato.SEG_Fecha_Envio_Gestor__c = date.today();
                contratoList.add(contrato);
            }
        }   
        
        update contratoList;
    
        System.assertEquals(testUser.ProfileId,profile.Id, 'Se ha modificado el perfil del usuario que ejecuta el batch');

        Test.startTest();
        System.runAs (testUser) {            
            SEG_ReclamacionesAutomaticas_Batch_V2 batch = new SEG_ReclamacionesAutomaticas_Batch_V2();
            Id batchId = Database.executeBatch(batch, 10);
        }
		Test.stopTest();  
        List<SEG_Contratos__c> lstContratos = [SELECT Id,Name, SEG_Fecha_1a_Reclamacion_Proceso__c,SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3a_Reclamacion_Proceso__c 
                                                FROM SEG_Contratos__c];
        for(SEG_Contratos__c c : lstContratos){
            if(c.Name == 'Number1'){
                System.assertEquals(date.Today(),c.SEG_Fecha_1a_Reclamacion_Proceso__c);
            }
            else if(c.Name == 'Number2'){
                System.assertEquals(null,c.SEG_Fecha_2a_Reclamacion_Proceso__c);
            }
            else if(c.Name == 'Number3'){
                System.assert(c.SEG_Fecha_2a_Reclamacion_Proceso__c==null);
            }
        }
	}

    @isTest
	private static void startCalledWithInputCases() {
        List<sObject> result = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		Profile profile = (Profile)result.get(0);
		User testUser = new User(
				Alias = 'Seg',
				Email = 'BatchSegmentos@Segmentos.com',
				LastName = 'testLastName',
				ProfileId = profile.Id,
				UserName = 'BatchSegmentos@Segmentos.com',
                emailencodingkey='UTF-8',
                languagelocalekey='en_US',
                localesidkey='en_US',
                timezonesidkey='America/Los_Angeles');
		insert testUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Supervisor'];
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();

            PermissionSetAssignment psAssign = new PermissionSetAssignment();
            psAssign.AssigneeId = testUser.id;
            psAssign.PermissionSetId = ps.Id;
            listPermissionSetAssignment.add(psAssign);

            PermissionSetAssignment psAssign2 = new PermissionSetAssignment();
            psAssign2.AssigneeId = testUser.id;
            psAssign2.PermissionSetId = ps2.Id;
            listPermissionSetAssignment.add(psAssign2);

            insert listPermissionSetAssignment;
        }

        List<SEG_Contratos__c> lstContrato1s = [SELECT Id, CreatedById, CreatedDate, Name, OwnerId, LastModifiedById,SEG_1a_Reclamacion_ejecutada_manualmente__c, 
                                                SEG_2a_Reclamacion_ejecutada_manualmente__c, SEG_3a_Reclamacion_ejecutada_manualmente__c, SEG_Centro__c, SEG_CIF__c,
                                                SEG_Descripcion__c, SEG_Estado__c, SEG_Fecha_1_Reclamacion__c,SEG_Fecha_1a_Reclamacion_Proceso__c,
                                                SEG_Fecha_2_Reclamacion__c, SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3_Reclamacion__c, SEG_Fecha_3a_Reclamacion_Proceso__c, 
                                                SEG_Fecha_Contrato__c, SEG_Fecha_Envio_Gestor__c, SEG_Fecha_Envio_Gestor_Proceso__c, SEG_Fecha_Firma__c, 
                                                SEG_Fecha_Parada_Reclamacion__c,SEG_Fecha_Recepcion_Original__c, SEG_Gestor_comercial__c, SEG_Idioma__c, 
                                                SEG_Motivo_No_Reclamacion__c,SEG_NombreCliente__c, 
                                                SEG_NombreCuenta__r.SEG_Prioridad_Carterizacion_Segmentos__c, SEG_NombreCuenta__r.SEG_Empleado_gestor_Segmentos__c, SEG_NombreCuenta__r.CC_EmpleadoGestorId__c,
                                                SEG_NombreCuenta__r.SEG_GestorOperativaNacional__c,SEG_NombreCuenta__c, SEG_NombreCuenta__r.SEG_GestorOperativaInternacional__c,SEG_NombreCuenta__r.SEG_GestorFinEstructurada__c, 
                                                SEG_NombreCuenta__r.CC_OficinaGestoraId__r.CC_Numero_Oficina__c, 
                                                SEG_NombreCliente__r.FirstName,SEG_NombreCliente__r.LastName, SEG_NombreCliente__r.Name, SEG_NombreCliente__r.CC_Idioma__c,SEG_NombreCliente__r.Email,
                                                SEG_Situacion_Contrato__c, SEG_SR_Seguimiento__c, SEG_SROriginal__c, SEG_Zona__c,SEG_SR_Seguimiento__r.Status,SEG_SR_Seguimiento__r.ContactId,SEG_SR_Seguimiento__r.AccountId,
                                                SEG_SR_Seguimiento__r.SEG_Organizacion__c,SEG_SR_Seguimiento__r.SEG_Zona__c,SEG_SR_Seguimiento__r.SEG_Grupo__c,SEG_SR_Seguimiento__r.SEG_Grupo_Empresa__c,
                                                SEG_SR_Seguimiento__r.SEG_ClasificacionRapida__c,SEG_SR_Seguimiento__r.CC_MCC_Motivo__c,SEG_SR_Seguimiento__r.CC_MCC_ProdServ__c,
                                                SEG_SR_Seguimiento__r.CC_MCC_Tematica__c,SEG_SR_Seguimiento__r.SEG_Numero_de_centro__c,SEG_SR_Seguimiento__r.SEG_Detalle__c
                                                FROM SEG_Contratos__c ];
        
        List<SEG_Contratos__c> contratoList = new List<SEG_Contratos__c>();
        for (SEG_Contratos__c contrato : lstContrato1s) { 
            if (contrato.Name == 'Number1'){
                contrato.SEG_Fecha_1_Reclamacion__c = date.today();
                contratoList.add(contrato);
            }
            if (contrato.Name == 'Number2'){
                contrato.SEG_Fecha_2_Reclamacion__c = date.today();
                contratoList.add(contrato);
            }
            if (contrato.Name == 'Number3'){
                contrato.SEG_Fecha_3_Reclamacion__c = date.today();
                contratoList.add(contrato);
            }
            if (contrato.Name == 'Number4'){
                contrato.SEG_Fecha_Envio_Gestor__c = date.today();
                contratoList.add(contrato);
            }
        }   
        
        update contratoList;

        List<String> lstCasosIds = new List<String>();
        List<Case> lstCasos = [SELECT Id FROM Case];
        for (Case caso : lstCasos) {
            lstCasosIds.add(caso.Id);
        }

        Test.startTest();
        System.runAs (testUser) {            
            SEG_ReclamacionesAutomaticas_Batch_V2 batch = new SEG_ReclamacionesAutomaticas_Batch_V2(lstCasosIds);
            Id batchId = Database.executeBatch(batch, 10);
        }
		Test.stopTest();  
        List<SEG_Contratos__c> lstContratos = [SELECT Id,Name, SEG_Fecha_1a_Reclamacion_Proceso__c,SEG_Fecha_2a_Reclamacion_Proceso__c,SEG_Fecha_3a_Reclamacion_Proceso__c 
                                                FROM SEG_Contratos__c];
        for(SEG_Contratos__c c : lstContratos){
            if(c.Name == 'Number1'){
                System.assertEquals(date.Today(),c.SEG_Fecha_1a_Reclamacion_Proceso__c);
            }
            else if(c.Name == 'Number2'){
                System.assertEquals(null,c.SEG_Fecha_2a_Reclamacion_Proceso__c);
            }
            else if(c.Name == 'Number3'){
                System.assert(c.SEG_Fecha_2a_Reclamacion_Proceso__c==null);
            }
        }
	}
}