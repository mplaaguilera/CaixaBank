@isTest
public class SEG_Contratos_TRHan_Test {
    /**
     * @description   Preparación de los datos.
     */
    @testSetup
    public static void testSetup() 
    {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
            Profile perfil2 = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol2 = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser2 = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil2.Id, userroleid = rol2.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
            insert thisUser2;
            List<PermissionSetAssignment> listPermissionSetAssignment2 = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment2.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment2.isEmpty()){
                insert listPermissionSetAssignment2;
            }
        }

        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        // Creación cuentas a tratar.
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa numero2';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG2.CC_Numero_Documento__c = '11111112H';
        insert cuentaSEG2;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG2 = new Contact();
        contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG2.LastName = 'Contacto SEG 2';
        contactoSEG2.AccountId = cuentaSEG2.Id;
        contactoSEG2.Email = 'test2@test.com';
        insert contactoSEG2;



        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        
        //Crear reclamaciones
        SEG_Reclamaciones__c recl = new SEG_Reclamaciones__c();
        recl.Name = 'Testreclamaciones';
        recl.SEG_Plazo1Reclamacion__c = 1;
        recl.SEG_Plazo2Reclamacion__c = 2;
        recl.SEG_Plazo3Reclamacion__c = 3;
        recl.SEG_PlazoEnvioGestor__c = 4;
        recl.SEG_PlazoLlamada__c = 1;

        insert recl;

        //Crear MCC para CR
        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000007';
        insert mccTematicaSEG;
        
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
        regla3.SEG_ReclamacionesContratos__c = recl.Id;
        regla3.SEG_CRContratos__c  = true;
        regla3.CBK_Negocio__c = 'Segmentos';
        insert regla3;


        //Caso de seguimiento
        Case caso3 = new Case();
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso3.AccountId = cuentaSEG1.Id;
        caso3.ContactId = contactoSEG1.Id;
        caso3.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso3.SEG_Idioma__c = 'es';
        caso3.CC_AcuseRecibo__c ='1';
        caso3.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso3.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso3.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso3.Status = 'Activo';
        caso3.Subject = 'test Seguimiento';
        caso3.SEG_ClasificacionRapida__c = regla3.Id;
        caso3.SEG_Zona__c = 'Corporativa';
        caso3.SEG_Organizacion__C = 'Banca Corporativa';

        insert caso3;
        
        //Caso de seguimiento
        Case caso4 = new Case();
        caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso4.AccountId = cuentaSEG2.Id;
        caso4.ContactId = contactoSEG2.Id;
        caso4.CC_MailTelfNotif__c = contactoSEG2.Email;
        caso4.SEG_Idioma__c = 'es';
        caso4.CC_AcuseRecibo__c ='1';
        caso4.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso4.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso4.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso4.Status = 'Activo';
        caso4.Subject = 'test Seguimiento';
        caso4.SEG_ClasificacionRapida__c = regla3.Id;
        caso4.SEG_Zona__c = 'Corporativa';
        caso4.SEG_Organizacion__C = 'Banca Corporativa';

        insert caso4;
        
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        caracteristica.Name = 'Reclamaciones Agotadas';
        caracteristica.CC_Descripcion__c = 'descripción';
        caracteristica.OS_Negocio__c = 'SEGMENTOS';
        insert caracteristica;
        
        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c();
        caracteristica2.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        caracteristica2.Name = 'Errores22';
        caracteristica2.CC_Descripcion__c = 'test';
        caracteristica2.OS_Negocio__c = 'SEGMENTOS';
        insert caracteristica2;
        
        SEG_Marca_de_un_cliente__c marca1 = new SEG_Marca_de_un_cliente__c();
        marca1.SEG_Cliente__c = cuentaSEG2.Id;
        marca1.SEG_Caracteristica__c = caracteristica.Id;
        insert marca1;
        
        SEG_Marca_de_un_cliente__c marca2 = new SEG_Marca_de_un_cliente__c();
        marca2.SEG_Cliente__c = cuentaSEG1.Id;
        marca2.SEG_Caracteristica__c = caracteristica2.Id;
        insert marca2;
        
        //Crear contratos
        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso4.Id;
        contrato1.SEG_Estado__c = 'No Firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        listadoContratos.add(contrato1);

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso3.Id;
        contrato2.SEG_Estado__c = 'No Firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato2);
        
       	SEG_Contratos__c contrato3 = new SEG_Contratos__c();
        contrato3.Name = 'Number3';
        contrato3.SEG_NombreCliente__c = contactoSEG2.Id;
        contrato3.SEG_NombreCuenta__c = cuentaSEG2.Id;
        contrato3.SEG_SR_Seguimiento__c=caso3.Id;
        contrato3.SEG_Estado__c = 'Reclamaciones Agotadas';
        contrato3.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato3);
        insert listadoContratos;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
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
        
        cdl.Visibility= 'InternalUsers';
        update cdl;

    }
    @isTest
    private static void test() {
        
        SEG_Contratos__c contratUpd = [SELECT Id, SEG_Estado__c FROM SEG_Contratos__c WHERE Name ='Number2'];
        
        Test.startTest();
        contratUpd.SEG_Estado__c = 'Reclamaciones Agotadas';
        update contratUpd;
        Test.stopTest();
    }
    
    @isTest
    private static void test2() {
        
        SEG_Contratos__c contratUpd = [SELECT Id, SEG_Estado__c FROM SEG_Contratos__c WHERE Name ='Number1'];
        
        Test.startTest();
        contratUpd.SEG_Estado__c = 'Reclamaciones Agotadas';
        update contratUpd;
        Test.stopTest();
        
        
    }


    //Metodo Test para probar el rellenado automático de los datos de reclamación (SEG_1a_Reclamacion_ejecutada_manualmente__c, SEG_2a_Reclamacion_ejecutada_manualmente__c y SEG_3a_Reclamacion_ejecutada_manualmente__c) en la inserción.
    @isTest
    public static void reclamacionesBITest(){
 
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact LIMIT 1];
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso.Subject = 'Prueba primer caso';
        caso.Status = 'Pendiente';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.OwnerId = usuarioTest.Id;

        Test.startTest();
        System.runAs(usuarioTest) { 
            insert caso;
            SEG_Contratos__c contrato = new SEG_Contratos__c();
            contrato.Name = 'Contrato 3 Fechas';
            contrato.SEG_NombreCliente__c = contacto.Id;
            contrato.SEG_NombreCuenta__c = cuenta.Id;
            contrato.SEG_SR_Seguimiento__c = caso.Id;
            contrato.SEG_1a_Reclamacion_ejecutada_manualmente__c = true;
            contrato.SEG_2a_Reclamacion_ejecutada_manualmente__c = true;
            contrato.SEG_3a_Reclamacion_ejecutada_manualmente__c = true;
            contrato.SEG_Fecha_Envio_Gestor_Proceso__c = Date.today();
            insert contrato;
        }
        Test.stopTest();
        SEG_Contratos__c carTrasInsert = [SELECT Id, SEG_Estado__c, SEG_Fecha_1a_Reclamacion_Proceso__c, SEG_Fecha_2a_Reclamacion_Proceso__c, SEG_Fecha_3a_Reclamacion_Proceso__c FROM SEG_Contratos__c WHERE Name = 'Contrato 3 Fechas' LIMIT 1];
        System.assertNotEquals(null , carTrasInsert.SEG_Fecha_1a_Reclamacion_Proceso__c,'No se ha rellenado la SEG_Fecha_1a_Reclamacion_Proceso__c');
        System.assertNotEquals(null , carTrasInsert.SEG_Fecha_2a_Reclamacion_Proceso__c,'No se ha rellenado la SEG_Fecha_2a_Reclamacion_Proceso__c');
        System.assertNotEquals(null , carTrasInsert.SEG_Fecha_3a_Reclamacion_Proceso__c,'No se ha rellenado la SEG_Fecha_3a_Reclamacion_Proceso__c');
        System.assertEquals('Reclamaciones agotadas' , carTrasInsert.SEG_Estado__c,'No se ha modificado el estado del contrato');
    }

    //Metodo Test para probar el rellenado automático de los datos de reclamación (SEG_1a_Reclamacion_ejecutada_manualmente__c, SEG_2a_Reclamacion_ejecutada_manualmente__c y SEG_3a_Reclamacion_ejecutada_manualmente__c) en la actualización.
    @isTest
    public static void reclamacionesBUTest(){
    
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact LIMIT 1];
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso.Subject = 'Prueba primer caso';
        caso.Status = 'Pendiente';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.OwnerId = usuarioTest.Id;

        Test.startTest();
        System.runAs(usuarioTest) { 
            insert caso;
            SEG_Contratos__c contrato = new SEG_Contratos__c();
            contrato.Name = 'Contrato 3 Fechas';
            contrato.SEG_NombreCliente__c = contacto.Id;
            contrato.SEG_NombreCuenta__c = cuenta.Id;
            contrato.SEG_SR_Seguimiento__c = caso.Id;
            contrato.SEG_1a_Reclamacion_ejecutada_manualmente__c = false;
            contrato.SEG_2a_Reclamacion_ejecutada_manualmente__c = false;
            contrato.SEG_3a_Reclamacion_ejecutada_manualmente__c = false;
            insert contrato;
        
            contrato.SEG_1a_Reclamacion_ejecutada_manualmente__c = true;
            contrato.SEG_2a_Reclamacion_ejecutada_manualmente__c = true;
            contrato.SEG_3a_Reclamacion_ejecutada_manualmente__c = true;
            contrato.SEG_Fecha_Envio_Gestor_Proceso__c = Date.today();
            update contrato;
        }
        Test.stopTest();

        SEG_Contratos__c carTrasInsert = [SELECT Id, SEG_Estado__c, SEG_Fecha_1a_Reclamacion_Proceso__c, SEG_Fecha_2a_Reclamacion_Proceso__c, SEG_Fecha_3a_Reclamacion_Proceso__c FROM SEG_Contratos__c WHERE Name = 'Contrato 3 Fechas'  LIMIT 1];
        System.assertNotEquals(null , carTrasInsert.SEG_Fecha_1a_Reclamacion_Proceso__c,'No se ha rellenado la SEG_Fecha_1a_Reclamacion_Proceso__c');
        System.assertNotEquals(null , carTrasInsert.SEG_Fecha_2a_Reclamacion_Proceso__c,'No se ha rellenado la SEG_Fecha_2a_Reclamacion_Proceso__c');
        System.assertNotEquals(null , carTrasInsert.SEG_Fecha_3a_Reclamacion_Proceso__c,'No se ha rellenado la SEG_Fecha_3a_Reclamacion_Proceso__c');
        System.assertEquals('Reclamaciones agotadas' , carTrasInsert.SEG_Estado__c,'No se ha modificado el estado del contrato');
    }
}