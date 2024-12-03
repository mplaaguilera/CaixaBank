@isTest
public class SEG_Account_BI_TRHan_Test{
    //User operativo = SEG_Usuarios.usuarioOperativo();
    //User supervisor = SEG_Usuarios.usuarioSupervisor();

    /*@isTest
    public static void nuevoColaborador() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        // Alta de datos para la prueba
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Account acc = new Account(RecordTypeId=rtId);
        acc.Name = 'Prueba';
        System.runAs (supervisor) {
            Test.startTest();
                    insert acc;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Account accInsertado = [SELECT Id FROM Account WHERE Id = :acc.Id];
            if (accInsertado != null) {
                System.assertNotEquals(accInsertado.Id, null);
            }
        }
    }*/

    //Test para la inserción de cuentas que deban rellenar el campo gestor comercial
    @isTest
    public static void actualizacionGestorComercial() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            // Alta de datos para la prueba
            Contact contactoSEG = new Contact();
            contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            contactoSEG.FirstName = 'Yaiza';
            contactoSEG.LastName = 'Contacto 2';
            contactoSEG.Email = 'testasdas@test.com';
            contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
            insert contactoSEG;

            Contact contactoSEG2 = new Contact();
            contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            contactoSEG2.FirstName = 'Yaiza';
            contactoSEG2.LastName = 'Contacto 2';
            contactoSEG2.Email = 'testasdas@test.com';
            contactoSEG2.SEG_No_enviar_Acuse_Recibo__c = false;
            insert contactoSEG2;

            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa segmentos 2';
            cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG2';
            cuentaSEG1.CC_Numero_Documento__c = '11111111F';
            cuentaSEG1.AV_EAPGestor__c = contactoSEG.Id;
            cuentaSEG1.SEG_Empleado_gestor_Segmentos__c = contactoSEG2.Id;
            cuentaSEG1.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;

        
            Test.startTest();
                insert cuentaSEG1;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Account accInsertado = [SELECT Id, SEG_Gestor_Comercial_Actual__c FROM Account WHERE Id = :cuentaSEG1.Id];
            if (accInsertado != null) {
                System.assertNotEquals(accInsertado.SEG_Gestor_Comercial_Actual__c, null);
            }
        }
    }

    //Test para la inserción de cuentas que deban rellenar el campo gestor comercial
    @isTest
    public static void actualizacionGestorComercial2() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        // Alta de datos para la prueba
        Contact contactoSEG = new Contact();
        contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactoSEG.FirstName = 'Yaiza';
        contactoSEG.LastName = 'Contacto 2';
        contactoSEG.Email = 'testasdas@test.com';
        contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
        insert contactoSEG;

        Contact contactoSEG2 = new Contact();
        contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactoSEG2.FirstName = 'Yaiza';
        contactoSEG2.LastName = 'Contacto 2';
        contactoSEG2.Email = 'testasdas@test.com';
        contactoSEG2.SEG_No_enviar_Acuse_Recibo__c = false;
        insert contactoSEG2;

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos 2';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG2';
        cuentaSEG1.CC_Numero_Documento__c = '11111111F';
        cuentaSEG1.AV_EAPGestor__c = contactoSEG.Id;
        cuentaSEG1.SEG_Empleado_gestor_Segmentos__c = contactoSEG2.Id;
        cuentaSEG1.SEG_No_enviar_Acuse_Recibo_Empresa__c = true;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                    insert cuentaSEG1;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Account accInsertado = [SELECT Id, SEG_Gestor_Comercial_Actual__c FROM Account WHERE Id = :cuentaSEG1.Id];
            if (accInsertado != null) {
                System.assertNotEquals(accInsertado.SEG_Gestor_Comercial_Actual__c, null);
            }
        }
    }

        //Test para la inserción de cuentas que deban rellenar el campo gestor comercial
        @isTest
        public static void actualizacionGestorComercial3() {
            User supervisor = SEG_Usuarios.usuarioSupervisor();

            // Alta de datos para la prueba
            Contact contactoSEG = new Contact();
            contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            contactoSEG.FirstName = 'Yaiza';
            contactoSEG.LastName = 'Contacto 2';
            contactoSEG.Email = 'testasdas@test.com';
            contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
            insert contactoSEG;
    
            Contact contactoSEG2 = new Contact();
            contactoSEG2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            contactoSEG2.FirstName = 'Yaiza';
            contactoSEG2.LastName = 'Contacto 2';
            contactoSEG2.Email = 'testasdas@test.com';
            contactoSEG2.SEG_No_enviar_Acuse_Recibo__c = false;
            insert contactoSEG2;
    
            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa segmentos 2';
            cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG2';
            cuentaSEG1.CC_Numero_Documento__c = '11111111F';
            cuentaSEG1.AV_EAPGestor__c = contactoSEG.Id;
            cuentaSEG1.SEG_Empleado_gestor_Segmentos__c = contactoSEG2.Id;
            cuentaSEG1.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;
    
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                Test.startTest();
                        insert cuentaSEG1;
                Test.stopTest();
                
                // Evaluación del resultado de la prueba
                Account accInsertado = [SELECT Id, SEG_Gestor_Comercial_Actual__c FROM Account WHERE Id = :cuentaSEG1.Id];
                if (accInsertado != null) {
                    System.assertNotEquals(accInsertado.SEG_Gestor_Comercial_Actual__c, null);
                }
            }
        }

    //Test para la inserción de cuentas que deban rellenar el campo Gestor Operativa Nacional
    @isTest
    public static void actualizacionGestorOperativaNacionalTest() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        
        // Alta de datos para la prueba
        Contact contactoSEG = new Contact();
        contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactoSEG.FirstName = 'Test';
        contactoSEG.LastName = 'Test Apellido';
        contactoSEG.Email = 'testapellido@test.com';
        contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
        insert contactoSEG;

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos 3';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG3';
        cuentaSEG1.CC_Numero_Documento__c = '222222222F';
        cuentaSEG1.SEG_GestorOperativaNacional__c = contactoSEG.Id;
        cuentaSEG1.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;
    
        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
                insert cuentaSEG1;
            Test.stopTest();
        }
        // Evaluación del resultado de la prueba
        Account accInsertado = [SELECT Id, SEG_GestorOperativaNacionalActual__c FROM Account WHERE Id = :cuentaSEG1.Id];
        if (accInsertado != null) {
            System.assertNotEquals(accInsertado.SEG_GestorOperativaNacionalActual__c, null);
        }
    }
}