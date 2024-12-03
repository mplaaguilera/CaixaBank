@isTest
public class CSBD_InfobipControllerTest {

    @testSetup
    static void setupData() {
        // Insert necessary setup data here
        CSBD_Infobip_Setting__c settings = new CSBD_Infobip_Setting__c(
            CSBD_Envio_Automatico_Activo__c = true
        );
        insert settings;

        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();

        Map<String, SObject> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678Z');
        Account cuenta = (Account)cuentaContacto.get('cuenta');
        Opportunity opportunity = CSBD_Opportunity_Test.crearOportunidadPrestamo(cuenta);
       
    }

    @isTest
    static void testSendInfobipMessage() {
       
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        System.runAs (usuarioAdministrador) {
             // Prepare input JSON
            String inputJson = '{"idOportunidades":["' + [SELECT Id FROM Opportunity LIMIT 1][0].Id + '"]}';
            Test.startTest();
                CSBD_InfobipController.sendInfobipMessage(inputJson);             
                Integer jobCount = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name LIKE 'CSBD_InfobipSender'];
                System.assertEquals(1, jobCount, 'The Queueable job should be enqueued');   
            Test.stopTest();          
        }
    }

 
    @isTest
    static void testCheckConditionsBeforeSend() {

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs (usuarioAdministrador) {
            CSBD_InfobipController controller = new CSBD_InfobipController();
            // Validate the condition check
            Boolean result = controller.checkConditionsBeforeSend();
            System.assertEquals(true, result, 'Automatic sending should be active as per settings');
        }
    }

}