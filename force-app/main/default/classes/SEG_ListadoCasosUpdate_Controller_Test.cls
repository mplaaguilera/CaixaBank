@isTest
public class SEG_ListadoCasosUpdate_Controller_Test {
    /**
     * @description   Preparación de los datos.
     */
    @testSetup
    public static void testSetup() 
    {
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;
        
        Account cuentaSEG2 = new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        cuentaSEG2.Name = 'Empresa Test';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG2.CC_Numero_Documento__c = '11111112H';
        cuentaSEG2.CC_Numero_Oficina__c = '74512';
        insert cuentaSEG2;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;

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
        
        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;


        regla1.CBK_Negocio__c = 'Segmentos';


        insert regla1;

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.SEG_Idioma__c = 'en';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        caso1.Status = 'Pendiente';

        insert caso1;

        Id currentUser =  UserInfo.getUserId();

        EntitySubscription eSub1 = new EntitySubscription(ParentID = caso1.Id, SubscriberId = currentUser);
        insert eSub1;


    }
    @isTest
    private static void test() {
        
        Test.startTest();
        SEG_ListadoCasosUpdate_Controller.getCurrentUser();
        Test.stopTest();


    }
    @isTest
    private static void test2() {
        Test.startTest();
        SEG_ListadoCasosUpdate_Controller.getCaseList();
        Test.stopTest();


    }
    
    @isTest
    private static void TestStandardSetController () {
        List<Case> lstcase = [Select Id from Case];
        Test.startTest();
        Test.setCurrentPage(Page.SEG_SeguirCaso);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstcase);
        stdSetController.setSelected(lstcase);
        SEG_SeguirCaso_Controller ext = new SEG_SeguirCaso_Controller(stdSetController);
        Test.stopTest();


    }
    
    @isTest
    private static void SEG_SeguirCaso_ControllerTest () {
        List<Case> lstcase = [Select Id from Case];
        Test.startTest();
        Test.setCurrentPage(Page.SEG_SeguirCaso);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstcase);
        stdSetController.setSelected(lstcase);
        SEG_SeguirCaso_Controller ext = new SEG_SeguirCaso_Controller(stdSetController);
        ext.main();
        Test.stopTest();


    }
    
    @isTest
    private static void SEG_PropietarioAnterior_ControllerTest () {
        List<Case> lstcase = [Select Id from Case];
        Test.startTest();
        Test.setCurrentPage(Page.SEG_PropietarioAnterior);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstcase);
        stdSetController.setSelected(lstcase);
        SEG_PropietarioAnterior_Controller ext = new SEG_PropietarioAnterior_Controller(stdSetController);
        ext.main();
        Test.stopTest();


    }
    
}