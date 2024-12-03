@isTest
public with sharing class SEG_ConciliacionAccount_Batch_Test {
    @testSetup
    static void datosIniciales ()
    {         
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;

        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa segmentos 2';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG2';
        cuentaSEG2.CC_Numero_Documento__c = '22222222J';
        insert cuentaSEG2;

        Account cuentaALF1 = new Account();
        cuentaALF1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaALF1.Name = 'Empresa ALF 1';
        cuentaALF1.SEG_DominioMail__c = '@cuentaALF1';
        cuentaALF1.CC_Numero_Documento__c = '11111111H';
        cuentaALF1.CC_NumPerso__c = '00000001';
        cuentaALF1.AV_NumPerso__c = '00000001';
        cuentaALF1.SEG_Prioridad_Carterizacion_Segmentos__c = false;
        insert cuentaALF1;

        Account cuentaALF2 = new Account();
        cuentaALF2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaALF2.Name = 'Empresa ALF 2';
        cuentaALF2.SEG_DominioMail__c = '';
        cuentaALF2.CC_Numero_Documento__c = '22222222J';
        cuentaALF2.CC_NumPerso__c = '00000002';
        cuentaALF2.AV_NumPerso__c = '00000002';
        cuentaALF2.SEG_Prioridad_Carterizacion_Segmentos__c = false;
        insert cuentaALF2;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        insert contactoSEG1;

        Contact contactoSEG2 = new Contact();
        contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG2.LastName = 'Contacto SEG 2';
        contactoSEG2.AccountId = cuentaSEG2.Id;
        insert contactoSEG2;

        Contact contactoSEG3 = new Contact();
        contactoSEG3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG3.LastName = 'Contacto SEG 1.1';
        contactoSEG3.AccountId = cuentaSEG1.Id;
        insert contactoSEG3;

        Contact contactoSEG4 = new Contact();
        contactoSEG4.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG4.LastName = 'Contacto SEG 2.1';
        contactoSEG4.AccountId = cuentaSEG2.Id;
        insert contactoSEG4;

        // Crear contacto para cuenta ALF.
        Contact contactoALF1 = new Contact();
        contactoALF1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoALF1.LastName = 'Contacto ALF 1';
        contactoALF1.AccountId = cuentaALF1.Id;
        insert contactoALF1;
        
        // Crear un canal de comunicación
        List<CC_Canal_Com__c> listadoCanales = new List<CC_Canal_Com__c>();
        
        CC_Canal_Com__c canal1 = new CC_Canal_Com__c();
        canal1.CC_CuentaId__c = cuentaSEG1.Id;
        listadoCanales.add(canal1);
        
        CC_Canal_Com__c canal2 = new CC_Canal_Com__c();
        canal2.CC_CuentaId__c = cuentaSEG1.Id;
        canal2.CC_ContactoId__c = contactoSEG4.Id;
        listadoCanales.add(canal2);
        
        insert listadoCanales;

        // Crear contactos relacionados entre las cuentas de segmentos
        List<AccountContactRelation> relacionContactos = new List<AccountContactRelation>();
        
        AccountContactRelation relacionSEG1 = new AccountContactRelation();
        relacionSEG1.AccountId = cuentaSEG1.Id;
        relacionSEG1.ContactId = contactoSEG4.Id;
        relacionContactos.add(relacionSEG1);

        AccountContactRelation relacionSEG2 = new AccountContactRelation();
        relacionSEG2.AccountId = cuentaSEG2.Id;
        relacionSEG2.ContactId = contactoSEG3.Id;
        relacionContactos.add(relacionSEG2);

        AccountContactRelation relacionSEG3 = new AccountContactRelation();
        relacionSEG3.AccountId = cuentaSEG1.Id;
        relacionSEG3.ContactId = contactoALF1.Id;
        relacionContactos.add(relacionSEG3);

        AccountContactRelation relacionSEG4 = new AccountContactRelation();
        relacionSEG4.AccountId = cuentaALF1.Id;
        relacionSEG4.ContactId = contactoSEG1.Id;
        relacionContactos.add(relacionSEG4);

        insert relacionContactos;

        // Crear fichero asociado a la cuenta SEG.
        ContentVersion ficheroSFDC = new ContentVersion();
        ficheroSFDC.ContentLocation = 'S';
        ficheroSFDC.Description = 'fichero_SEG_1';
        ficheroSFDC.PathOnClient = 'fichero_SEG_1.txt';
        ficheroSFDC.Title = 'fichero_SEG_1';
        ficheroSFDC.VersionData = Blob.valueOf('test');
        ficheroSFDC.IsMajorVersion = true;
        insert ficheroSFDC;

        ContentVersion ficheroAdjuntado1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroSFDC.Id];

        ContentDocumentLink linkFichero = new ContentDocumentLink();
        linkFichero.ContentDocumentId = ficheroAdjuntado1.ContentDocumentId;
        linkFichero.LinkedEntityId = cuentaSEG1.Id;
        linkFichero.ShareType = 'V'; 
        linkFichero.Visibility = 'AllUsers'; 
        
        insert linkFichero;

        ContentVersion ficheroSFDC2 = new ContentVersion();
        ficheroSFDC2.ContentLocation = 'S';
        ficheroSFDC2.Description = 'fichero_SEG_2';
        ficheroSFDC2.PathOnClient = 'fichero_SEG_2.txt';
        ficheroSFDC2.Title = 'fichero_SEG_2';
        ficheroSFDC2.VersionData = Blob.valueOf('test2');
        ficheroSFDC2.IsMajorVersion = true;
        insert ficheroSFDC2;

        ContentVersion ficheroAdjuntado2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroSFDC2.Id];

        ContentDocumentLink linkFichero2 = new ContentDocumentLink();
        linkFichero2.ContentDocumentId = ficheroAdjuntado2.ContentDocumentId;
        linkFichero2.LinkedEntityId = cuentaSEG2.Id;
        linkFichero2.ShareType = 'V'; 
        linkFichero2.Visibility = 'AllUsers'; 
        
        insert linkFichero2;

        // Crear notas asociadas a las cuentas
        ContentNote notaSEG1 = new ContentNote();
        notaSEG1.Title = 'Nota 1';
        notaSEG1.Content = Blob.valueOf('Nota 1');
        insert notaSEG1;

        ContentNote notaSEG2 = new ContentNote();
        notaSEG2.Title = 'Nota 2';
        notaSEG2.Content = Blob.valueOf('Nota 2');
        insert notaSEG2;

        List<ContentDocumentLink> listaNotasLink = new List<ContentDocumentLink>();

        ContentDocumentLink linkNota1 = new ContentDocumentLink();
        linkNota1.ContentDocumentId = notaSEG1.Id;
        linkNota1.LinkedEntityId = cuentaSEG1.Id;
        linkNota1.ShareType = 'V'; 
        linkNota1.Visibility = 'AllUsers';
        listaNotasLink.add(linkNota1);

        ContentDocumentLink linkNota2 = new ContentDocumentLink();
        linkNota2.ContentDocumentId = notaSEG2.Id;
        linkNota2.LinkedEntityId = cuentaSEG2.Id;
        linkNota2.ShareType = 'V'; 
        linkNota2.Visibility = 'AllUsers';
        listaNotasLink.add(linkNota2);

        insert listaNotasLink;

        // Crear una marca a cada cliente.
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        caracteristica.Name = 'marca 1';
        caracteristica.CC_Descripcion__c = 'descripción';
        caracteristica.OS_Negocio__c = 'SEGMENTOS';
        insert caracteristica;

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c();
        caracteristica2.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        caracteristica2.Name = 'marca 2';
        caracteristica2.CC_Descripcion__c = 'descripción';
        caracteristica2.OS_Negocio__c = 'SEGMENTOS';
        insert caracteristica2;

        List<SEG_Marca_de_un_cliente__c> listaMarcas = new List<SEG_Marca_de_un_cliente__c>();

        SEG_Marca_de_un_cliente__c marca1 = new SEG_Marca_de_un_cliente__c();
        marca1.SEG_Cliente__c = cuentaALF1.Id;
        marca1.SEG_Caracteristica__c = caracteristica.Id;
        listaMarcas.add(marca1);

        SEG_Marca_de_un_cliente__c marca11 = new SEG_Marca_de_un_cliente__c();
        marca11.SEG_Cliente__c = cuentaALF2.Id;
        marca11.SEG_Caracteristica__c = caracteristica2.Id;
        listaMarcas.add(marca11);

        SEG_Marca_de_un_cliente__c marca2 = new SEG_Marca_de_un_cliente__c();
        marca2.SEG_Cliente__c = cuentaSEG2.Id;
        marca2.SEG_Caracteristica__c = caracteristica.Id;
        listaMarcas.add(marca2);

        insert listaMarcas;
        
		//Gestor Operativa Internacional
		Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
        Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();

        // Crear casos de los clientes.
        List<Case> listadoCasos = new List<Case>();

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.Subject = 'test 1';
        listadoCasos.add(caso1);

        Case caso11 = new Case();
        caso11.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso11.AccountId = cuentaSEG1.Id;
        caso11.ContactId = contactoSEG1.Id;
        caso11.Subject = 'test 1 caso11';
        listadoCasos.add(caso11);

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.AccountId = cuentaSEG2.Id;
        caso2.ContactId = contactoSEG2.Id;
        caso2.Subject = 'test 1';
        listadoCasos.add(caso2);

        insert listadoCasos;

        // Crear feedItems
        List<FeedItem> listadoFeeds = new List<FeedItem>();

        FeedItem post1 = new FeedItem();
        post1.ParentId = caso2.Id;
        post1.Type = 'TextPost';
        post1.Revision = 1;
        post1.Body = 'texto';
        post1.IsRichText = true;
        post1.NetworkScope = 'AllNetworks';
        listadoFeeds.add(post1);

        FeedItem post2 = new FeedItem();
        post2.ParentId = caso2.Id;
        post2.Type = 'TextPost';
        post2.Revision = 1;
        post2.Body = 'texto 2';
        post2.IsRichText = true;
        post2.NetworkScope = 'AllNetworks';
        listadoFeeds.add(post2);

        insert listadoFeeds;
        
		CC_Grupo_Colaborador__c grupoExcepcion = new CC_Grupo_Colaborador__c();
		grupoExcepcion.Name = 'Gestor Operativa Internacional';
		grupoExcepcion.RecordTypeId = autoSegId;
		insert grupoExcepcion;
        
		Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();

		List<SEG_Excepciones__c> lstEx = new List<SEG_Excepciones__c>();
		SEG_Excepciones__c excepcion = new SEG_Excepciones__c();
		excepcion.RecordTypeId = recordAsig;
		excepcion.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion.SEG_Zona__c = 'Corporativa';
		excepcion.SEG_Grupoasignado__c = grupoExcepcion.Id;
        insert excepcion;
        
		List<SEG_Excepciones_Empresa__c> lstExEmpresa = new List<SEG_Excepciones_Empresa__c>();
		SEG_Excepciones_Empresa__c exEmpresa = new SEG_Excepciones_Empresa__c();
		exEmpresa.SEG_Excepciones__c = excepcion.id;
		exEmpresa.Empresa__c = cuentaSEG1.id;
		exEmpresa.SEG_Activo__c = true;
		lstExEmpresa.add(exEmpresa);

		SEG_Excepciones_Empresa__c exEmpresa5 = new SEG_Excepciones_Empresa__c();
		exEmpresa5.SEG_Excepciones__c = excepcion.id;
		exEmpresa5.Empresa__c = cuentaSEG1.id;
		exEmpresa5.SEG_Activo__c = true;
		lstExEmpresa.add(exEmpresa5);
		insert lstExEmpresa;
        
		Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id recordMotiv = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.RecordTypeId = recordDet;
        mccDetalle.Name = 'Detalle';
        mccDetalle.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle.CC_Codigo_Externo__c = 'DE-000003';
        insert mccDetalle;  
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.RecordTypeId = recordMotiv;
        mccMotivo.Name = 'Motivo';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Codigo_Externo__c = 'DE-000004';
        insert mccMotivo;  
        
        CC_MCC__c mccProdServ = new CC_MCC__c();
        mccProdServ.RecordTypeId = recordProdServ;
        mccProdServ.Name = 'ProdSev';
        mccProdServ.CC_Tipo_Cliente__c = 'Cliente';
        mccProdServ.CC_Codigo_Externo__c = 'DE-000005';
        insert mccProdServ;  
        
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.RecordTypeId = recordTem;
        mccTematica.Name = 'Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Codigo_Externo__c = 'DE-000006';
        mccTematica.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica; 
        
        CC_MCC__c mccTematicaColaborador = new CC_MCC__c();
        mccTematicaColaborador.RecordTypeId = recordTem;
        mccTematicaColaborador.Name = 'Tematica';
        mccTematicaColaborador.CC_Tipo_Cliente__c = 'Cliente';
        mccTematicaColaborador.CC_Codigo_Externo__c = 'DE-000007';
        mccTematicaColaborador.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematicaColaborador; 
             
		List<CC_Grupo_Colaborador__c> lstGrupoColaborador = new List<CC_Grupo_Colaborador__c>();
        //Grupo Operativo Segmentos
        CC_Grupo_Colaborador__c grupoOpSeg = new CC_Grupo_Colaborador__c();
        grupoOpSeg.RecordTypeId = opSegId;
        lstGrupoColaborador.add(grupoOpSeg);
        
        //Grupo Automático Segmentos
        CC_Grupo_Colaborador__c grupoAutoSeg = new CC_Grupo_Colaborador__c();
        grupoAutoSeg.Name = 'BO*';
        grupoAutoSeg.RecordTypeId = autoSegId;
        lstGrupoColaborador.add(grupoAutoSeg);
        
        //Gestor Comercial
        CC_Grupo_Colaborador__c grupoGestorComercial = new CC_Grupo_Colaborador__c();
        grupoGestorComercial.Name = 'Gestor Comercial';
        grupoGestorComercial.RecordTypeId = opSegId;
        lstGrupoColaborador.add(grupoGestorComercial);
        
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
        clasRapida.SEG_CRContratos__c = true;
        clasRapida.SEG_ReclamacionesContratos__c = recl.Id;
        clasRapida.SEG_Organizacion__c = 'Banca Corporativa';
        insert clasRapida;

        // Crear casos de los clientes.
        List<Case> listadoCasos2 = new List<Case>();

        Case caso13 = new Case();
        caso13.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso13.AccountId = cuentaSEG1.Id;
        caso13.ContactId = contactoSEG1.Id;
        caso13.Subject = 'test 1';
        caso13.Status = 'Cerrado';
        caso13.SEG_Organizacion__c = 'Banca Corporativa';
        caso13.SEG_Zona__c ='Corporativa';
		caso13.SEG_Grupo__c = grupoGestorComercial.Id;
        caso13.SEG_ClasificacionRapida__c = clasRapida.Id;
		caso13.SEG_Detalle__c = mccDetalle.Id;
        listadoCasos2.add(caso13);

        Case caso12 = new Case();
        caso12.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso12.AccountId = cuentaSEG1.Id;
        caso12.ContactId = contactoSEG1.Id;
        caso12.Subject = 'test 1 caso11';
        caso12.Status = 'Cerrado';
        caso12.SEG_Organizacion__c = 'Banca Corporativa';
        caso12.SEG_Zona__c ='Corporativa';
		caso12.SEG_Grupo__c = grupoGestorComercial.Id;
		caso12.CC_MCC_ProdServ__c = mccProdServ.id;
        listadoCasos2.add(caso12);

        Case caso21 = new Case();
        caso21.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso21.AccountId = cuentaSEG1.Id;
        caso21.ContactId = contactoSEG1.Id;
        caso21.Subject = 'test 1';
        caso21.Status = 'Activo';
        caso21.SEG_Organizacion__c = 'Banca Corporativa';
        caso21.SEG_Zona__c ='Corporativa';
		caso21.SEG_Grupo__c = grupoGestorComercial.Id;
		caso21.CC_MCC_Tematica__c = mccTematica.id;
        listadoCasos2.add(caso21);

		Case caso31 = new Case();
        caso31.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso31.AccountId = cuentaSEG1.Id;
        caso31.ContactId = contactoSEG1.Id;
        caso31.Subject = 'test 1';
        caso31.Status = 'Cerrado';
        caso31.SEG_Organizacion__c = 'Banca Corporativa';
        caso31.SEG_Zona__c ='Corporativa';
		caso31.SEG_Grupo__c = grupoGestorComercial.Id;
		caso31.CC_MCC_Tematica__c = mccTematica.id;
        listadoCasos2.add(caso31);

        insert listadoCasos2;

        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso13.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        listadoContratos.add(contrato1);

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso12.Id;
        contrato2.SEG_Estado__c = 'No firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato2);

        SEG_Contratos__c contrato3 = new SEG_Contratos__c();
        contrato3.Name = 'Number3';
        contrato3.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato3.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato3.SEG_SR_Seguimiento__c=caso21.Id;
        contrato3.SEG_Estado__c = 'No Firmado';
        contrato3.SEG_Fecha_Envio_Gestor__c = date.Today();
        contrato3.SEG_Fecha_2_Reclamacion__c = date.Today();
		listadoContratos.add(contrato3);

		SEG_Contratos__c contrato4 = new SEG_Contratos__c();
        contrato4.Name = 'Number4';
        contrato4.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato4.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato4.SEG_SR_Seguimiento__c=caso21.Id;
        contrato4.SEG_Estado__c = 'No Firmado';
		listadoContratos.add(contrato4);

		SEG_Contratos__c contrato5 = new SEG_Contratos__c();
        contrato5.Name = 'Number5';
        contrato5.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato5.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato5.SEG_SR_Seguimiento__c=caso31.Id;
        contrato5.SEG_Estado__c = 'No Firmado';

        listadoContratos.add(contrato5);

        insert listadoContratos;

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

		SEG_Plantilla__c plantilla = new SEG_Plantilla__c();
		plantilla.Name = 'Acuse de recibo';
		plantilla.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		plantilla.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Instituciones Este';
		plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
		plantilla.SEG_Activa__c = true;
		plantilla.SEG_PlantillaCastellano__c = 'Firma BO';
		plantilla.SEG_PlantillaCatalan__c = 'Firma CAT';
		plantilla.SEG_PlantillaIngles__c = 'Firma IN';
		plantilla.SEG_PlantillaEuskera__c = 'Firma EUSK';
		plantilla.SEG_PlantillaGalego__c = 'Firma GAL';
		plantilla.SEG_PlantillaCastellanoID__c = emailEs.Id;
		insert plantilla;

		SEG_ExcepcionesEmpresa__c exEmpresa2 = new SEG_ExcepcionesEmpresa__c();
		exEmpresa2.SEG_Plantilla__c = plantilla.id;
		exEmpresa2.SEG_Empresa__c = cuentaSEG1.id;
		insert exEmpresa2;

		SEG_ExcepcionesGrupoEmpresa__c exGrupoEmpresa = new SEG_ExcepcionesGrupoEmpresa__c();
		exGrupoEmpresa.SEG_Plantilla__c = plantilla.id;
		exGrupoEmpresa.SEG_GrupoEmpresa__c = cuentaSEG1.id;
		insert exGrupoEmpresa;

        SEG_Excepciones_Grupo_Empresa__c exGrupoEmpresa2 = new SEG_Excepciones_Grupo_Empresa__c();
		exGrupoEmpresa2.SEG_GrupoEmpresa__c = cuentaSEG1.id;
		insert exGrupoEmpresa2;
    }

    @isTest
    public static void conciliarCuentasSegmentos()
    {        
        //Se ejecuta el batch
		Test.startTest();
        	Database.executeBatch(new SEG_ConciliacionAccount_Batch());
        Test.stopTest();

        ID recordTypeSEG = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        List<Account> listadoCuentasSEG = [SELECT Id FROM Account WHERE RecordTypeId = :recordTypeSEG];
        System.assert(listadoCuentasSEG.size() == 0);
    } 

    @isTest
    public static void conciliarCuentasSegmentosLimit()
    {
        //Se ejecuta el batch
		Test.startTest();
        	Database.executeBatch(new SEG_ConciliacionAccount_Batch('20'));
        Test.stopTest();

        ID recordTypeSEG = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        List<Account> listadoCuentasSEG = [SELECT Id FROM Account WHERE RecordTypeId = :recordTypeSEG];
        System.assert(listadoCuentasSEG.size() == 0);
    }
}