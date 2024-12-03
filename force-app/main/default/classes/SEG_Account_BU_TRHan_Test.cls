@isTest

public with sharing class SEG_Account_BU_TRHan_Test{
//User operativo = SEG_Usuarios.usuarioOperativo();
//User supervisor = SEG_Usuarios.usuarioSupervisor();
    @testSetup
    static void testSetup() {
        // Creación cuentas a tratar.

            // Account gestores
            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa Test 1';
            cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
            cuentaSEG1.CC_Numero_Documento__c = '111111111';
            cuentaSEG1.CC_Numero_Oficina__c = '11111';
            cuentaSEG1.CC_Numero_Oficina_Empresa__c = '124456789';
            cuentaSEG1.AV_OficinasRelacionadas__c = '3210903219';
            insert cuentaSEG1;

            Account cuentaSEG2 = new Account();
            cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            cuentaSEG2.Name = 'Empresa Test 2';
            cuentaSEG2.SEG_DominioMail__c = '@cuentaSEG';
            cuentaSEG2.CC_Numero_Documento__c = '222222222';
            cuentaSEG2.CC_Numero_Oficina__c = '22222';
            cuentaSEG2.CC_Numero_Oficina_Empresa__c = '123456789';
            cuentaSEG2.AV_OficinasRelacionadas__c = '3210903219';
            insert cuentaSEG2;

            //Contactos gestores
            Contact gestor1 = new Contact();
            gestor1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            gestor1.LastName = 'Contacto SEG 1';
            gestor1.AccountId = cuentaSEG1.Id;
            gestor1.Email = 'test23@test.com';
            insert gestor1;

            Contact gestor2 = new Contact();
            gestor2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            gestor2.LastName = 'Contacto SEG 2';
            gestor2.AccountId = cuentaSEG2.Id;
            gestor2.Email = 'test23@test.com';
            insert gestor2;

            // Account empresa
            Account accGestor = new Account();
            accGestor.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            accGestor.Name = 'Test cuenta segmentos';
            accGestor.SEG_DominioMail__c = '@accGestor';
            accGestor.CC_Numero_Documento__c = '111111114';
            accGestor.AV_EAPGestor__c = gestor1.Id;
            accGestor.SEG_Empleado_gestor_Segmentos__c = gestor2.Id;
            accGestor.AV_OficinaPrincipal__c = cuentaSEG1.Id;
            accGestor.SEG_Oficina_Gestora_Segmentos__c = cuentaSEG2.Id;
            accGestor.SEG_Prioridad_Carterizacion_Segmentos__c = false;
            accGestor.SEG_Gestor_Comercial_Actual__c = null;
            accGestor.SEG_GestorOperativaNacionalActual__c = null;
            accGestor.AV_OficinasRelacionadas__c = '3210903219';
            accGestor.CC_Numero_Oficina_Empresa__c = '124456389';
            insert accGestor;
        
    }

    @isTest
    public static void actualizacionGestorComercial(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            List <Account> accGestorActual = [SELECT Id, AV_EAPGestor__c, SEG_Empleado_gestor_Segmentos__c, SEG_Empleado_gestor_Segmentos__r.Name, AV_OficinaPrincipal__c,
            SEG_Oficina_Gestora_Segmentos__c, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Gestor_Comercial_Actual__c FROM Account WHERE Name = 'Test cuenta segmentos' LIMIT 1];
    
            if (!accGestorActual.isEmpty()) {
                accGestorActual[0].SEG_Prioridad_Carterizacion_Segmentos__c = true;
            }

            Test.startTest();
                update accGestorActual;
            Test.stopTest();

            List <Account> casoRes = [SELECT Id, SEG_Gestor_Comercial_Actual__c, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Empleado_gestor_Segmentos__r.Name FROM Account WHERE Name = 'Test cuenta segmentos' LIMIT 1];
            System.assertEquals(casoRes[0].SEG_Gestor_Comercial_Actual__c, casoRes[0].SEG_Empleado_gestor_Segmentos__r.Name, 'El gestor comercial no es el correcto');
        }
    }

    @isTest
    public static void actualizacionGestor(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            List <Account> accGestorActual = [SELECT Id, AV_EAPGestor__c, SEG_Empleado_gestor_Segmentos__c, AV_OficinaPrincipal__c,
            SEG_Oficina_Gestora_Segmentos__c, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Gestor_Comercial_Actual__c FROM Account WHERE Name = 'Test cuenta segmentos' LIMIT 1];

            List <Contact> contactoActual = [SELECT Id, Name FROM Contact WHERE LastName = 'Contacto SEG 2' LIMIT 1];
    
            if (!accGestorActual.isEmpty()) {
                accGestorActual[0].AV_EAPGestor__c = contactoActual[0].Id;
            }

            Test.startTest();
                update accGestorActual;
            Test.stopTest();

            List <Account> casoRes = [SELECT Id, SEG_Gestor_Comercial_Actual__c, SEG_Prioridad_Carterizacion_Segmentos__c FROM Account WHERE Name = 'Test cuenta segmentos' LIMIT 1];
            System.assertEquals(casoRes[0].SEG_Gestor_Comercial_Actual__c, contactoActual[0].Name, 'El gestor comercial no es el correcto');
        }
    }

    @isTest
    public static void actualizacionGestorOperativaNacionalTest(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            List <Account> accGestorActual = [SELECT Id, AV_EAPGestor__c, SEG_Empleado_gestor_Segmentos__c, AV_OficinaPrincipal__c,
            SEG_Oficina_Gestora_Segmentos__c, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Gestor_Comercial_Actual__c, SEG_GestorOperativaNacional__c FROM Account WHERE Name = 'Test cuenta segmentos' LIMIT 1];

            List <Contact> contactoActual = [SELECT Id, Name FROM Contact WHERE LastName = 'Contacto SEG 2' LIMIT 1];
    
            if (!accGestorActual.isEmpty()) {
                accGestorActual[0].SEG_GestorOperativaNacional__c = contactoActual[0].Id;
            }

            Test.startTest();
                update accGestorActual;
            Test.stopTest();

            List <Account> casoRes = [SELECT Id, SEG_GestorOperativaNacionalActual__c FROM Account WHERE Name = 'Test cuenta segmentos' LIMIT 1];
            System.assertEquals(casoRes[0].SEG_GestorOperativaNacionalActual__c, contactoActual[0].Name, 'El gestor operativo nacional no es el correcto');
        }

    }
    
}