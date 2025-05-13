@isTest
public with sharing class SEG_Case_Utilities_Test {
    @testSetup
    static void testSetup() { 
        
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'GrupoColabSeg';
        grupoColab.SEG_Tipologia__c = 'BO';
        grupoColab.RecordTypeId = grupoOpSegId;
		insert grupoColab;

        Account cuentaSEG = new Account();
        cuentaSEG.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG.Name = 'test segmentos';
        cuentaSEG.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG.CC_Numero_Documento__c = '111111114';
        cuentaSEG.CC_Grupo_Colaborador__c = grupoColab.Id;
        cuentaSEG.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;
        insert cuentaSEG;

        
        Contact contactoSEG = new Contact();
        contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactoSEG.FirstName = 'Yaiza';
        contactoSEG.LastName = 'Contacto 2';
        contactoSEG.Email = 'testasdas@test.com';
        contactoSEG.AccountId = cuentaSEG.Id;
        contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
        insert contactoSEG;

        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'FIRMA OK';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.Name = 'FIRMA OK';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.CC_Tematica__c = mccTematica.Id;
        mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle.CC_Motivo__c = mccMotivo.Id;
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;
        
        CC_MCC__c mccDetalle2 = new CC_MCC__c();
        mccDetalle2.Name = 'FIRMA NOK';
        mccDetalle2.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle2.RecordTypeId = recordTypeIdDetalle;
        mccDetalle2.CC_Tematica__c = mccTematica.Id;
        mccDetalle2.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle2.CC_Motivo__c = mccMotivo.Id;
        mccDetalle2.CC_Codigo_Externo__c = 'DE-000002';
        insert mccDetalle2;

        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.CBK_Negocio__c = 'Segmentos';
        insert regla1;

        User supervisor = SEG_Usuarios.usuarioSupervisor();

        CC_Grupo_Colaborador_Contact__c contactoGrupo = new CC_Grupo_Colaborador_Contact__c();
        contactoGrupo.CC_Usuario__c = supervisor.id;
        contactoGrupo.CC_Grupo_Colaborador__c = grupoColab.id;
        insert contactoGrupo;

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.AccountId = cuentaSEG.Id;
        caso2.ContactId = contactoSEG.Id;
        caso2.OwnerId = supervisor.id;
        caso2.SEG_grupo__c = grupoColab.id;
        caso2.CC_MailTelfNotif__c = contactoSEG.Email;
        caso2.SEG_Idioma__c = 'es';
        caso2.CC_AcuseRecibo__c ='1';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.SEG_ClasificacionRapida__c = regla1.id;
        caso2.Status = 'Activo';
        caso2.Subject = 'test 2';
        caso2.Origin = 'Email';
        caso2.SEG_Organizacion__c = 'Centro Soporte Especialistas';
        caso2.SEG_Zona__c = 'CSE';
        caso2.SEG_N_operaciones_del_caso__c = 1.0;
        insert caso2;
    }

    @isTest
    public static void insertarMarcasSinCaracteristica() {

        User supervisor = [SELECT Id FROM User WHERE FirstName = 'supervisor' LIMIT 1];
        Case caso = [SELECT Id, SEG_Detalle__r.Name FROM Case  WHERE Subject = 'test 2' LIMIT 1];
        CC_MCC__c mccOK = [SELECT Id FROM CC_MCC__c WHERE Name = 'FIRMA NOK' LIMIT 1];
        System.debug('caso detalle: ' + caso.SEG_Detalle__r.Name);
        System.runAs (new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            caso.SEG_Detalle__c = mccOK.Id;
            update caso;
            Test.stopTest();

            SEG_Marcasdeuncaso__c marcaDelCaso = [SELECT Id FROM SEG_Marcasdeuncaso__c WHERE SEG_Caso__c = :caso.Id LIMIT 1];
            System.assertNotEquals(marcaDelCaso, null, 'No se ha generado la marca');
        }
    } 

    @isTest
    public static void insertarMarcasConCaracteristica() {

        User supervisor = [SELECT Id FROM User WHERE FirstName = 'supervisor' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2' LIMIT 1];
        CC_MCC__c mccOK = [SELECT Id FROM CC_MCC__c WHERE Name = 'FIRMA OK' LIMIT 1];

        Id recordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
        List<CC_Caracteristica__c> caraceteristicas = new List<CC_Caracteristica__c>();

        CC_Caracteristica__c caractOK = new CC_Caracteristica__c();
        caractOK.RecordTypeId = recordTypeId;
        caractOK.Name = 'FIRMA OK';
        caractOK.CC_Descripcion__c = 'FIRMA OK';
        caractOK.OS_Negocio__c = 'SEGMENTOS';
        caractOK.CC_Fecha_vigencia_inicio__c = System.now();
        caraceteristicas.add(caractOK);

        CC_Caracteristica__c caractNOK = new CC_Caracteristica__c();
        caractNOK.RecordTypeId = recordTypeId;
        caractNOK.Name = 'FIRMA NOK';
        caractNOK.CC_Descripcion__c = 'FIRMA NOK';
        caractNOK.OS_Negocio__c = 'SEGMENTOS';
        caractNOK.CC_Fecha_vigencia_inicio__c = System.now();
        caraceteristicas.add(caractNOK);

        insert caraceteristicas;

        System.runAs (new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            caso.SEG_Detalle__c = mccOK.Id;
            update caso;
            Test.stopTest();

            SEG_Marcasdeuncaso__c marcaDelCaso = [SELECT Id FROM SEG_Marcasdeuncaso__c WHERE SEG_Caso__c = :caso.Id LIMIT 1];
            System.assertNotEquals(marcaDelCaso, null, 'No se ha generado la marca');
        }
    } 
}