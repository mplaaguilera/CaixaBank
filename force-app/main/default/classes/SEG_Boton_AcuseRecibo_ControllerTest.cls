@IsTest
private class SEG_Boton_AcuseRecibo_ControllerTest {
    @IsTest
    static void testUpdateContactField_False() {
        //Se genera el usuario de pruebas
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        // Se inserta el contacto que se modificará

        Contact testContact = new Contact();
        testContact.SEG_No_enviar_Acuse_Recibo__c = false;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        testContact.FirstName = 'Yaiza';
        testContact.LastName = 'Contacto 2';
        testContact.Email = 'testasdas@test.com';
        insert testContact;
        
        System.runAs (supervisor) {
            Test.startTest();
            // llamada al método a probar
            Contact updatedContact = SEG_Boton_AcuseRecibo_Controller.updateContactField(testContact.Id);
            Test.stopTest();
        }

        Contact refreshedContact = [SELECT Id, SEG_No_enviar_Acuse_Recibo__c FROM Contact WHERE Id = :testContact.Id];
        // Assert para comprobar que se ha modificado el campo
        System.assertNotEquals(testContact.SEG_No_enviar_Acuse_Recibo__c, refreshedContact.SEG_No_enviar_Acuse_Recibo__c, 'No se ha modificado el campo Acuse Recibo');
    }

    @IsTest
    static void testUpdateContactField_True() {
        //Se genera el usuario de pruebas
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        // Se inserta el contacto que se modificará

        Contact testContact = new Contact();
        testContact.SEG_No_enviar_Acuse_Recibo__c = true;
        testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        testContact.FirstName = 'Yaiza';
        testContact.LastName = 'Contacto 2';
        testContact.Email = 'testasdas@test.com';
        insert testContact;
        
        System.runAs (supervisor) {
            Test.startTest();
            // llamada al método a probar
            Contact updatedContact = SEG_Boton_AcuseRecibo_Controller.updateContactField(testContact.Id);
            Test.stopTest();
        }

        Contact refreshedContact = [SELECT Id, SEG_No_enviar_Acuse_Recibo__c FROM Contact WHERE Id = :testContact.Id];
        // Assert para comprobar que se ha modificado el campo
        System.assertNotEquals(testContact.SEG_No_enviar_Acuse_Recibo__c, refreshedContact.SEG_No_enviar_Acuse_Recibo__c, 'No se ha modificado el campo Acuse Recibo');
    }
}