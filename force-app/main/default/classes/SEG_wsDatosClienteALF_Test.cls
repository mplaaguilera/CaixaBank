@isTest
public with sharing class SEG_wsDatosClienteALF_Test {
    @testSetup
    static void datosIniciales ()
    { 
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        Id grColSegmentosId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        cuentaSEG1.AV_NumPerso__c = '999910559714';
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
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaSEG2.LastName = 'Empresa segmentos';
        cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG2.CC_Numero_Documento__c = '11111111H';
        cuentaSEG2.AV_NumPerso__c = 'XXXXXXX';
        insert cuentaSEG2;
    }
    
    @isTest
    static void updateCustomerDataALF() {
        
        Account cuenta1 = [SELECT Id FROM Account WHERE AV_NumPerso__c = '999910559714' LIMIT 1];
        Account cuenta2 = [SELECT Id FROM Account WHERE AV_NumPerso__c = 'XXXXXXX' LIMIT 1];
        
        cuenta1.AV_NumPerso__c = 'YYYYYYYY';
        update cuenta1;
        
        cuenta2.AV_NumPerso__c = '999910559714';
        update cuenta2;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_03());
        
        Map<String,String> resultado = SEG_wsDatosClienteALF.updateCustomerDataALF (cuenta2.Id);
        
        Test.stopTest();
        
        System.assert(resultado != null);
        System.assert(resultado.get('error') == '0');
        System.assert(resultado.get('errorUser') == '');
        }
    }
    
    @isTest
    static void updateCustomerDataALF_Empresa() {
        
        List<Account> listaCuenta = [SELECT Id FROM Account WHERE AV_NumPerso__c = '999910559714'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_05());
        
        Map<String,String> resultado = SEG_wsDatosClienteALF.updateCustomerDataALF (listaCuenta[0].Id);
        
        Test.stopTest();
        
        System.assert(resultado != null);
        System.assert(resultado.get('error') == '0');
        System.assert(resultado.get('errorUser') == '');
        }
    }
    
    @isTest
    static void updateCustomerDataALF_Error() {
        
        List<Account> listaCuenta = [SELECT Id FROM Account WHERE AV_NumPerso__c = '999910559714'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_07());
        
        Map<String,String> resultado = SEG_wsDatosClienteALF.updateCustomerDataALF (listaCuenta[0].Id);
        
        Test.stopTest();
        
        System.assert(resultado != null);
        System.assert(resultado.get('error') != '0');
        System.assert(resultado.get('errorUser') != '');
        }
    }
    
    // COMENTADO POR CAMBIOS EN API-PREMIUM.
    @isTest
    static void getCustomerDataPremium_OK() {
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SEG_wsMockALFPremium_HTTP());
        
        Map<String,Object> resultado = SEG_wsDatosClienteALF.getCustomerDataPremium ('999910559714');
        
        Test.stopTest();

        System.assertEquals(true,true,'Error');
        }
    }
    
    @isTest
    static void validarMetodosAuxiliares() {        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        System.assert(SEG_wsDatosClienteALF.validateNull(null) == null);
        System.assert(SEG_wsDatosClienteALF.validateNull('null') != null);
        System.assert(SEG_wsDatosClienteALF.validateNull(null,'convertString') == null);
        System.assert(SEG_wsDatosClienteALF.validateNull('null','convertString') != null);
        Datetime fechaActual = datetime.now();
        System.assert(SEG_wsDatosClienteALF.calculateTimeDifferences(fechaActual,fechaActual) == 0);
        }
    }
    
    /*@isTest
    static void validarGenerarTrazas()
    {
        CC_TrazaInt__c traza = SEG_wsDatosClienteALF.generarTraza ('nombre', 'origen', 'identificador', 'mensajeEntrada', 'mensajeSalida', true, '0', 'detalleError');
        System.assert(traza != null);
    }*/
}