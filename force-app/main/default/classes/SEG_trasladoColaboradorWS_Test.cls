@isTest
public class SEG_trasladoColaboradorWS_Test {

	@testSetup
    public static void datosTest() {


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com', 
                    emailencodingkey='UTF-8', lastname='Smith', 
                    languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                    timezonesidkey='America/Los_Angeles', 
                    Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
            insert new PermissionSetAssignment(AssigneeId = thisUser.id, PermissionSetId = ps.Id);


            CBK_IntegrationSetting__c csIntValija = new CBK_IntegrationSetting__c();
            csIntValija.Name = 'SEG_Int_Valija';
            csIntValija.NamedCredential__c = 'callout:API_SEG_PRO/tech/evssbb/ServidorValija/api/connectorSalesforce/sendValijaSalesforce';
            insert csIntValija;

            CBK_IntegrationSetting__c csIntValija2 = new CBK_IntegrationSetting__c();
            csIntValija2.Name = 'SEG_Int_Valija_2';
            csIntValija2.NamedCredential__c = 'callout:API_SEG_PRO/tech/evssbb/ServidorValija/api/connectorSalesforce/sendValijaSalesforce';
            insert csIntValija2;

            SEG_Settings__c csValija = new SEG_Settings__c();
            csValija.Name = 'SEG_Flujo_Valija_Viejo';
            csValija.SEG_Activo__c = true;
            insert csValija;
        }

        System.runAs (new User(Id = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1].id)){
            
        // RT utilizados.
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        cuentaSEG1.SEG_Organizacion__c = 'Banca Corporativa';
        cuentaSEG1.SEG_Zona__c = 'Corporativa';
        cuentaSEG1.CBK_Negocio__c = 'Segmentos';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        //GRUPOS COLABORADORES
        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List<CC_Grupo_Colaborador__c>();
        
        //Grupo Colaborador Operativo Segmentos
		Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c();
        grupoCol1.Name = 'MCC 0029';
        grupoCol1.RecordTypeId = grupoOpSegId;
        grupoCol1.SEG_GrupoSegmentos__c = true;
        grupoCol1.SEG_NotaGrupoPlantillaEN__c = 'notaGrupoEN';
        grupoCol1.SEG_NotaGrupoPlantillaES__c = 'notaGrupoES';
        grupoCol1.SEG_NotaGrupoPlantillaCAT__c = 'notaGrupoCAT';
        grupoCol1.SEG_NotaGrupoPlantillaEU__c = 'notaGrupoEU';
        grupoCol1.SEG_NotaGrupoPlantillaGL__c = 'notaGrupoGA';
        gruposColaboradores.add(grupoCol1);
        
        //Grupo colaborador CC
		Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoValija = new CC_Grupo_Colaborador__c();
		grupoValija.Name = 'Grupo Colaborador Valija';
        grupoValija.SEG_GrupoSegmentos__c = true;
		grupoValija.RecordTypeId = grColId;
		grupoValija.SEG_CierreAutomaticoSR__c = true;
        grupoValija.SEG_TipoColaboradorWS__c = 'VALIJA';
		gruposColaboradores.add(grupoValija);
        insert gruposColaboradores;

        // Crear MCC Tematica
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        // Crear MCC Producto Servicio
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        // Crear MCC Motivo
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        // Crear MCC Detalle
        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
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
               
        //CASOS DE FICHEROS PROCESADOS
        List<Case> casosFicherosProcesadosList = new List<Case>();

        Case casoFicherosProcesados = new Case();
        casoFicherosProcesados.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        casoFicherosProcesados.AccountId = cuentaSEG1.Id;
        casoFicherosProcesados.ContactId = contactoSEG1.Id;
        casoFicherosProcesados.CC_MailTelfNotif__c = contactoSEG1.Email;
        casoFicherosProcesados.SEG_Idioma__c = 'es';
        casoFicherosProcesados.CC_AcuseRecibo__c ='1';
        casoFicherosProcesados.CC_MCC_Tematica__c = mccTematica.Id;
        casoFicherosProcesados.CC_MCC_ProdServ__c = mccProducto.Id;
        casoFicherosProcesados.CC_MCC_Motivo__c = mccMotivo.Id;
        casoFicherosProcesados.Status = 'Activo';
        casoFicherosProcesados.Subject = 'SEG_trasladoColaboradorWS_1';
        casoFicherosProcesados.SEG_Organizacion__c = 'Banca Corporativa';
        casoFicherosProcesados.OS_Referencia_Valija__c = '0012345';
        casoFicherosProcesados.SEG_RefSalienteValija__c = '0012345';
        casoFicherosProcesados.SEG_Zona__c = 'Corporativa';
        casoFicherosProcesados.Origin = 'Paquetería';
        casoFicherosProcesados.SEG_EstadoTrasladoValija__c = '';
        casoFicherosProcesados.SEG_N_operaciones_del_caso__c = 1;
        casosFicherosProcesadosList.add(casoFicherosProcesados);

        Case casoFicherosProcesados2 = new Case();
        casoFicherosProcesados2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        casoFicherosProcesados2.AccountId = cuentaSEG1.Id;
        casoFicherosProcesados2.ContactId = contactoSEG1.Id;
        casoFicherosProcesados2.CC_MailTelfNotif__c = contactoSEG1.Email;
        casoFicherosProcesados2.SEG_Idioma__c = 'es';
        casoFicherosProcesados2.CC_AcuseRecibo__c ='1';
        casoFicherosProcesados2.CC_MCC_Tematica__c = mccTematica.Id;
        casoFicherosProcesados2.CC_MCC_ProdServ__c = mccProducto.Id;
        casoFicherosProcesados2.CC_MCC_Motivo__c = mccMotivo.Id;
        casoFicherosProcesados2.Status = 'Activo';
        casoFicherosProcesados2.Subject = 'SEG_trasladoColaboradorWS_2';
        casoFicherosProcesados2.SEG_Organizacion__c = 'Banca Corporativa';
        casoFicherosProcesados2.OS_Referencia_Valija__c = '1012345';
        casoFicherosProcesados2.SEG_RefSalienteValija__c = '1012345';
        casoFicherosProcesados2.SEG_Zona__c = 'Corporativa';
        casoFicherosProcesados2.Origin = 'Paquetería';
        casoFicherosProcesados2.SEG_EstadoTrasladoValija__c = '';
        casoFicherosProcesados2.SEG_N_operaciones_del_caso__c = 1;
        casosFicherosProcesadosList.add(casoFicherosProcesados2);
        insert casosFicherosProcesadosList;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        
        // Crear mail entrante.
        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = casoFicherosProcesados2.Id;
        emailmes.TextBody='CORREO ENTRANTE';
        emailmes.Incoming=true;
        emailmes.Status = '1';
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;
        
        // Crear fichero asociado al caso.
        ContentVersion ficheroValija2 = new ContentVersion();
        ficheroValija2.ContentLocation = 'S';
        ficheroValija2.SEG_ValijaId__c = '0054321';
        ficheroValija2.Description = 'fichero_SEG_2';
        ficheroValija2.PathOnClient = 'fichero_SEG_2.txt';
        ficheroValija2.Title = 'fichero_SEG_2';
        ficheroValija2.VersionData = Blob.valueOf('test');
        ficheroValija2.IsMajorVersion = true;
        insert ficheroValija2;

        ContentVersion ficheroAdjuntado2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroValija2.Id];

        ContentDocumentLink linkFichero = new ContentDocumentLink();
        linkFichero.ContentDocumentId = ficheroAdjuntado2.ContentDocumentId;
        linkFichero.LinkedEntityId = casoFicherosProcesados2.Id;
        linkFichero.Visibility = 'AllUsers';
        linkFichero.ShareType = 'V'; 
        
        insert linkFichero;
        }
    }
    
    @isTest
    public static void iniciarTrasladoColaboradorWS_OK_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';

        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                Map<String,String> retorno = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.get('codigo') == '0');
        }
    }
    
    @isTest
    public static void iniciarTrasladoColaboradorWS_KO_Test()
    {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('myStaticResourceName');
            mock.setStatusCode(400);
            mock.setHeader('Content-Type', 'application/json');
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '';
		dataTraslado.operacionValijaMCC = '';
		dataTraslado.operacionFinalValija = '';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                Map<String,String> retorno = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.get('codigo') != '0');
        }
    }
    
    @isTest
    public static void preparacionDatosAdicionalesTrasladoValijaNoMail_OK_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        
        Map<Id,SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador> mapaDatosTraslados = new Map<Id,SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador>();
        mapaDatosTraslados.put(caso.Id, dataTraslado);
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                SEG_trasladoColaboradorWS.preparacionDatosAdicionalesTrasladoValija(null);
                SEG_trasladoColaboradorWS.preparacionDatosAdicionalesTrasladoValija(mapaDatosTraslados);
            Test.stopTest();
            
            List<ContentDocumentLink> listadoFiles = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
            System.assert(!listadoFiles.isEmpty());
        }
    }
    
    @isTest
    public static void preparacionDatosAdicionalesTrasladoValijaConMail_OK_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        EmailMessage emailmes = new EmailMessage();
        emailmes.RelatedToId = caso.Id;
        emailmes.TextBody='CORREO ENTRANTE';
        emailmes.Incoming=true;
        emailmes.Status = '1';
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        
        Map<Id,SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador> mapaDatosTraslados = new Map<Id,SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador>();
        mapaDatosTraslados.put(caso.Id, dataTraslado);

        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Test.StartTest();
                SEG_trasladoColaboradorWS.preparacionDatosAdicionalesTrasladoValija(null);
                SEG_trasladoColaboradorWS.preparacionDatosAdicionalesTrasladoValija(mapaDatosTraslados);
            Test.stopTest();
            
            List<ContentDocumentLink> listadoFiles = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
            System.assert(!listadoFiles.isEmpty());
        }
    }
    
    @isTest
    public static void realizarTrasladoValija_OK_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        
        // Crear fichero asociado al caso.
        ContentVersion ficheroValija2 = new ContentVersion();
        ficheroValija2.ContentLocation = 'S';
        ficheroValija2.SEG_ValijaId__c = '0054321';
        ficheroValija2.Description = 'fichero_SEG_2';
        ficheroValija2.PathOnClient = 'fichero_SEG_2.txt';
        ficheroValija2.Title = 'fichero_SEG_2';
        ficheroValija2.VersionData = Blob.valueOf('test');
        ficheroValija2.IsMajorVersion = true;
        insert ficheroValija2;

        ContentVersion ficheroAdjuntado2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroValija2.Id];

        ContentDocumentLink linkFichero = new ContentDocumentLink();
        linkFichero.ContentDocumentId = ficheroAdjuntado2.ContentDocumentId;
        linkFichero.LinkedEntityId = caso.Id;
        linkFichero.Visibility = 'AllUsers'; 
        
        insert linkFichero;
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new SEG_wsMockTrasladoColaborador());
                SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS retorno = SEG_trasladoColaboradorWS.realizarTrasladoValija (dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            //System.assert(retorno.status == 'OK');
        }
    }
    
    @isTest
    public static void realizarTrasladoValija_OK2_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_2'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        ContentDocumentLink linkFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        dataTraslado.ficherosSeleccionados.add(linkFile.ContentDocumentId);
        
        Map<String,String> retornoInicio = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new SEG_wsMockTrasladoColaborador());
                SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS retorno = SEG_trasladoColaboradorWS.realizarTrasladoValija (dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            //System.assert(retorno.status == 'OK');
        }
    }
    
    @isTest
    public static void realizarTrasladoValija_KO_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';

        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new SEG_wsMockTrasladoValijaKO());
                SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS retorno = SEG_trasladoColaboradorWS.realizarTrasladoValija (dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.status != 'OK');
        }
    }
    
    @isTest
    public static void realizarTrasladoValija_KO2_Test()
    {
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = grupo.Id; 
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new SEG_wsMockTrasladoValijaKO());
                SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS retorno = SEG_trasladoColaboradorWS.realizarTrasladoValija (dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.status != 'OK');
        }
    }
    
    @isTest
    public static void recuperarDatosParaValija_OK_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_2'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        ContentDocumentLink linkFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        dataTraslado.ficherosSeleccionados.add(linkFile.ContentDocumentId);
        
        Map<String,String> retornoInicio = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                SEG_trasladoColaboradorWS.SEG_DataTrasladoValija retorno = SEG_trasladoColaboradorWS.recuperarDatosParaValija (dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.codigo == '0');
        }
    }
    
    @isTest
    public static void recuperarDatosParaValija_KO_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_2'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        ContentDocumentLink linkFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = grupo.Id;    
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        dataTraslado.ficherosSeleccionados.add(linkFile.ContentDocumentId);
        
        Map<String,String> retornoInicio = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                SEG_trasladoColaboradorWS.SEG_DataTrasladoValija retorno = SEG_trasladoColaboradorWS.recuperarDatosParaValija (dataTraslado);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.codigo != '0');
        }
    }
    
    @isTest
    public static void enviarTrasladoValija_KO500_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_2'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        ContentDocumentLink linkFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        dataTraslado.ficherosSeleccionados.add(linkFile.ContentDocumentId);
        
        Map<String,String> retornoInicio = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
        
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                SEG_trasladoColaboradorWS.SEG_DataTrasladoValija retorno = SEG_trasladoColaboradorWS.recuperarDatosParaValija (dataTraslado);
                Test.setMock(HttpCalloutMock.class, new SEG_wsMockTrasladoValijaKO500());
                SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS retornoWS = SEG_trasladoColaboradorWS.enviarTrasladoValija(retorno);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.codigo == '0');
            System.assert(retornoWS != null);
            System.assert(retornoWS.status != 'OK');
        }
    }
    
    @isTest
    public static void generarJSONValija_OK_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_2'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        ContentDocumentLink linkFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        dataTraslado.ficherosSeleccionados.add(linkFile.ContentDocumentId);
        
        Map<String,String> retornoInicio = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                SEG_trasladoColaboradorWS.SEG_DataTrasladoValija retorno = SEG_trasladoColaboradorWS.recuperarDatosParaValija (dataTraslado);

                String json1 = SEG_trasladoColaboradorWS.generarJSONValija(retorno);
            
                retorno.procesoValija = '02';
                String json2 = SEG_trasladoColaboradorWS.generarJSONValija(retorno);
            
                retorno.procesoValija = '08';
                String json3 = SEG_trasladoColaboradorWS.generarJSONValija(retorno);
            
                retorno.procesoValija = '64';
                String json4 = SEG_trasladoColaboradorWS.generarJSONValija(retorno);
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.codigo == '0');
        }
    }

    
    @isTest
    public static void generarJSONValija_Operacion01_Test() {
        SEG_trasladoColaboradorWS.SEG_DataTrasladoValija datosValija = new SEG_trasladoColaboradorWS.SEG_DataTrasladoValija();
        datosValija.procesoValija = '01';
        datosValija.tipoOperacion = 'TIPO1';
        datosValija.numExpediente = 'EXP123';
        datosValija.cifNif = 'A12345678';
        datosValija.nombreTitular = 'Titular Principal';
        datosValija.cifNif2 = 'B87654321';
        datosValija.nombreTitular2 = 'Titular Secundario';
        datosValija.cifNif3 = 'C33333333';
        datosValija.nombreTitular3 = 'Titular Tercero';
        datosValija.cifNif4 = 'D44444444';
        datosValija.nombreTitular4 = 'Titular Cuarto';
        datosValija.cifNif5 = 'E55555555';
        datosValija.nombreTitular5 = 'Titular Quinto';
        datosValija.contacto = 'Persona Contacto';
        datosValija.telefono = '600123123';
        datosValija.prestamoICO = 'NO';
        datosValija.idEER = 'EER001';
        String json = SEG_trasladoColaboradorWS.generarJSONValija(datosValija);
        System.debug(json);
        System.assert(!String.isBlank(json), 'El JSON generado no debe estar vacío');
        System.assertEquals(true, json.contains('"operationId":"01"'), 'El JSON debe contener la operación 01');
        System.assertEquals(true, json.contains('"Metadatas":[{"value":"TIPO1","key":"TIPO_OPERACION"},{"value":"EXP123","key":"NUM_EXPEDIENTE"},{"value":"A12345678","key":"CIF_NIF"},{"value":"Titular Principal","key":"NOMBRE_TITULAR"},{"value":"B87654321","key":"CIF_NIF_2"},{"value":"Titular Secundario","key":"NOMBRE_TITULAR2"},{"value":"C33333333","key":"CIF_NIF_3"},{"value":"Titular Tercero","key":"NOMBRE_TITULAR3"},{"value":"D44444444","key":"CIF_NIF_4"},{"value":"Titular Cuarto","key":"NOMBRE_TITULAR4"},{"value":"E55555555","key":"CIF_NIF_5"},{"value":"Titular Quinto","key":"NOMBRE_TITULAR5"},{"value":"Persona Contacto","key":"CONTACTO"},{"value":"600123123","key":"TELEFONO"},{"value":"NO","key":"PRESTAMO_ICO"},{"value":"EER001","key":"ID_EER"}]'), 'El JSON debe contener la Metadata introducida');
    }

    @isTest
    public static void generarJSONValija_Operacion06_Test() {
        SEG_trasladoColaboradorWS.SEG_DataTrasladoValija datosValija = new SEG_trasladoColaboradorWS.SEG_DataTrasladoValija();
        datosValija.procesoValija = '06';
        datosValija.cifOrdenante = '12345678Z';
        datosValija.nombreTitular = 'Persona Física';
        datosValija.contacto = 'Contacto PF';
        datosValija.telefono = '600987654';
        datosValija.numPer = '123456';
        datosValija.prestamoICO = 'NO';
        String json = SEG_trasladoColaboradorWS.generarJSONValija(datosValija);
        System.debug(json);
        System.assert(!String.isBlank(json), 'El JSON generado no debe estar vacío');
        System.assertEquals(true, json.contains('"Metadatas":[{"value":"12345678Z","key":"CIF_NIF"},{"value":"Persona Física","key":"NOMBRE_TITULAR"},{"value":"Contacto PF","key":"CONTACTO"},{"value":"600987654","key":"TELEFONO"},{"value":"123456","key":"NUMPER"},{"value":"NO","key":"PRESTAMO_ICO"}]'), 'El JSON debe contener la Metadata introducida');
    }
    
    
    @isTest
    public static void actualizarCasoDerivadoValija_OK_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_2'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        ContentDocumentLink linkFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        dataTraslado.ficherosSeleccionados.add(linkFile.ContentDocumentId);
        
        Map<String,String> retornoInicio = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                SEG_trasladoColaboradorWS.SEG_DataTrasladoValija retorno = SEG_trasladoColaboradorWS.recuperarDatosParaValija (dataTraslado);

                Map<String,String> retornoUpdate = SEG_trasladoColaboradorWS.actualizarCasoDerivadoValija(dataTraslado, retorno, String.valueOf(Datetime.now().getTime()));
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.codigo == '0');
            System.assert(retornoUpdate != null);
            System.assert(retornoUpdate.get('codigo') == '0');
        }
    }
    
    @isTest
    public static void actualizarCasoDerivadoValija_KO_Test()
    {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_2'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];
        ContentDocumentLink linkFile = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caso.Id];
        
        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
 		dataTraslado.caseId = caso.Id;
		dataTraslado.tipoColaborador = 'VALIJA';
		dataTraslado.oldGrupoId = grupo.Id;             
		dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
		dataTraslado.oldStatus = 'Activo';
		dataTraslado.oldSubStatus = 'Incidencia Valija';
		dataTraslado.newGrupoId = grupo.Id; 
		dataTraslado.newGrupoColaboradorId = grupoValija.Id;
		dataTraslado.newStatus = 'Pendiente';
		dataTraslado.newSubStatus = 'En canal Valija';
		dataTraslado.operacionPaqueteria = '02';
		dataTraslado.operacionValijaMCC = '11';
		dataTraslado.operacionFinalValija = '12';
		dataTraslado.notasManuales = 'Nota manual';
		dataTraslado.cuerpoTraslado = 'Cuerpo traslado';
        dataTraslado.ficherosSeleccionados.add(linkFile.ContentDocumentId);
        
        Map<String,String> retornoInicio = SEG_trasladoColaboradorWS.iniciarTrasladoColaboradorWS(dataTraslado);
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.StartTest();
                SEG_trasladoColaboradorWS.SEG_DataTrasladoValija retorno = SEG_trasladoColaboradorWS.recuperarDatosParaValija (dataTraslado);

                Map<String,String> retornoUpdate = SEG_trasladoColaboradorWS.actualizarCasoDerivadoValija(null, retorno, null);
            
                Map<String,String> retornoUpdate2 = SEG_trasladoColaboradorWS.actualizarCasoDerivadoValija(dataTraslado, retorno, '0012345');
            Test.stopTest();
            
            System.assert(retorno != null);
            System.assert(retorno.codigo == '0');
            System.assert(retornoUpdate != null);
            System.assert(retornoUpdate.get('codigo') != '0');
            System.assert(retornoUpdate2 != null);
            System.assert(retornoUpdate2.get('codigo') != '0');
        }
    }

    /**
     * @description       : Realiza el traslado final a Valija 2.0 con una operación 01. La respuesta del WS se simula con un mock.
     * @param             : None
     * @return            : void
     * @author            : Jaime Villarón
     * @group             : 
     * @last modified on  : 2025-07-28
     * @last modified by  : Jaime Villarón
     * Modifications Log 
     * Ver   Date         Author             Modification
     * 1.0   2025-07-21  Jaime Villarón   Initial Version
     */
    @isTest
    public static void realizarTrasladoValija_Operacion01_Test() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];

        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
        dataTraslado.caseId = caso.Id;
        dataTraslado.tipoColaborador = 'VALIJA';
        dataTraslado.oldGrupoId = grupo.Id;
        dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
        dataTraslado.oldStatus = 'Activo';
        dataTraslado.oldSubStatus = 'Incidencia Valija';
        dataTraslado.newGrupoId = grupo.Id;
        dataTraslado.newGrupoColaboradorId = grupoValija.Id;
        dataTraslado.newStatus = 'Pendiente';
        dataTraslado.newSubStatus = 'En canal Valija';
        dataTraslado.operacionFinalValija = '01'; // Operación 01
        dataTraslado.tipoOperacion = 'TIPO1';
        dataTraslado.numExpediente = 'EXP123';
        dataTraslado.cifNif = 'A12345678';
        dataTraslado.nombreTitular = 'Titular Principal';
        dataTraslado.cifNif2 = 'B87654321';
        dataTraslado.nombreTitular2 = 'Titular Secundario';
        dataTraslado.cifNif3 = 'C33333333';
        dataTraslado.nombreTitular3 = 'Titular Tercero';
        dataTraslado.cifNif4 = 'D44444444';
        dataTraslado.nombreTitular4 = 'Titular Cuarto';
        dataTraslado.cifNif5 = 'E55555555';
        dataTraslado.nombreTitular5 = 'Titular Quinto';
        dataTraslado.contacto = 'Persona Contacto';
        dataTraslado.telefono = '600123123';
        dataTraslado.prestamoICO = 'NO';
        dataTraslado.idEER = 'EER001';

        /* SEG_Settings__c flujoValija = SEG_Settings__c.getValues('SEG_Flujo_Valija_Viejo');
        flujoValija.SEG_Activo__c = true;
        update flujoValija; */

        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs(usuarioTest) {

            

            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SEG_wsMockTrasladoColaborador());
                SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS retorno = SEG_trasladoColaboradorWS.realizarTrasladoValija(dataTraslado);
            Test.stopTest();
            System.debug('retorno: ' + retorno);
            System.assert(retorno != null, 'El resultado no debe ser null');
            System.assertEquals('OK', retorno.status, 'El estado del retorno debe ser OK');
            System.assertNotEquals(null, retorno.mensajeEnviado, 'El mensaje enviado no debe ser null');
            System.assertNotEquals('', retorno.mensajeEnviado, 'El mensaje enviado no debe estar vacío');
            System.assertEquals('0000', retorno.codigo, 'El código de retorno debe ser 0000');
        }
    }       


    /**
     * @description       : Realiza el traslado final a Valija 2.0 con una operación 06. La respuesta del WS se simula con un mock.
     * @param             : None
     * @return            : void
     * @author            : Jaime Villarón
     * @group             : 
     * @last modified on  : 2025-07-28
     * @last modified by  : Jaime Villarón
     * Modifications Log 
     * Ver   Date         Author             Modification
     * 1.0   2025-07-21  Jaime Villarón   Initial Version
     */
    @isTest
    public static void realizarTrasladoValija_Operacion06_Test() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'SEG_trasladoColaboradorWS_1'];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'MCC 0029'];
        CC_Grupo_Colaborador__c grupoValija = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Colaborador Valija'];

        SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador dataTraslado = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
        dataTraslado.caseId = caso.Id;
        dataTraslado.tipoColaborador = 'VALIJA';
        dataTraslado.oldGrupoId = grupo.Id;
        dataTraslado.oldGrupoColaboradorId = grupoValija.Id;
        dataTraslado.oldStatus = 'Activo';
        dataTraslado.oldSubStatus = 'Incidencia Valija';
        dataTraslado.newGrupoId = grupo.Id;
        dataTraslado.newGrupoColaboradorId = grupoValija.Id;
        dataTraslado.newStatus = 'Pendiente';
        dataTraslado.newSubStatus = 'En canal Valija';
        dataTraslado.operacionFinalValija = '06'; // Operación 06
        dataTraslado.cifOrdenante = '12345678Z';
        dataTraslado.nombreTitular = 'Persona Física';
        dataTraslado.contacto = 'Contacto PF';
        dataTraslado.telefono = '600987654';
        dataTraslado.numPer = '123456';
        dataTraslado.prestamoICO = 'NO';

        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs(usuarioTest) {
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SEG_wsMockTrasladoColaborador());
                SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS retorno = SEG_trasladoColaboradorWS.realizarTrasladoValija(dataTraslado);
            Test.stopTest();
            System.assert(retorno != null, 'El resultado no debe ser null');
            System.assertEquals('OK', retorno.status, 'El estado del retorno debe ser OK');
            System.assertNotEquals(null, retorno.mensajeEnviado, 'El mensaje enviado no debe ser null');
            System.assertNotEquals('', retorno.mensajeEnviado, 'El mensaje enviado no debe estar vacío');
            System.assertEquals('0000', retorno.codigo, 'El código de retorno debe ser 0000');
        }
    }
}