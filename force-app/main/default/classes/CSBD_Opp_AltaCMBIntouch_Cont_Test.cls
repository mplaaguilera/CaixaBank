@isTest
public class CSBD_Opp_AltaCMBIntouch_Cont_Test {

    @TestSetup
    static void cargaDeDatos(){
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdministrador) {
            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cuenta.Name = 'test@test.com';
            cuenta.CC_Numero_Documento__c = '12345678N';
            insert cuenta;

            /*AccountShare acshare = new AccountShare();
            acshare.AccountId = cuenta.Id;
            acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1].Id;
            acshare.AccountAccessLevel = 'Edit';
            acshare.OpportunityAccessLevel = 'Edit';
            acshare.CaseAccessLevel = 'Edit';
            insert acshare;*/
        }
    }

    @isTest
    public static void altaOportunidadCMB(){
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        String nombreCliente = 'test@test.com';
        String dniCliente = '12345678N';
        Datetime fechaDate = System.today();
        String fechaContacto = fechaDate.format('yyyy-MM-dd');
        String tramoHorario = '10h-12h';
        String codigoProducto = 'Seviam';
        String operativa = 'operativa';
        String numeroContrato = 'contrato';
        String descripcion = 'descripción1';
        
        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            CSBD_Opp_AltaCMBIntouch_Controller.altaCMBIntouch(nombreCliente, dniCliente, fechaContacto, tramoHorario, codigoProducto, operativa, numeroContrato, descripcion);
            Test.stopTest();
            
            Opportunity oppCMB = [SELECT Id, CSBD_Now_NombreCompleto__c, CSBD_Now_NIF__c FROM Opportunity WHERE CSBD_Now_NIF__c = '12345678N' LIMIT 1];
            
            System.assertEquals(nombreCliente, oppCMB.CSBD_Now_NombreCompleto__c);
            System.assertEquals(dniCliente, oppCMB.CSBD_Now_NIF__c);
        }
    }

    @isTest
    public static void altaOportunidadCMBtramoDos(){
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        String nombreCliente = 'test@test.com';
        String dniCliente = '12345678N';
        Datetime fechaDate = System.today().addDays(-2);
        String fechaContacto = fechaDate.format('yyyy-MM-dd');
        String tramoHorario = '12h-14h';
        String codigoProducto = 'Seviam';
        String operativa = 'operativa';
        String numeroContrato = 'contrato';
        String descripcion = 'descripción2';

        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            CSBD_Opp_AltaCMBIntouch_Controller.altaCMBIntouch(nombreCliente, dniCliente, fechaContacto, tramoHorario, codigoProducto, operativa, numeroContrato, descripcion);
            Test.stopTest();
            
            Opportunity oppCMB = [SELECT Id, CSBD_Now_NombreCompleto__c, CSBD_Now_NIF__c FROM Opportunity WHERE CSBD_Now_NIF__c = '12345678N' LIMIT 1];
            
            System.assertEquals(nombreCliente, oppCMB.CSBD_Now_NombreCompleto__c);
            System.assertEquals(dniCliente, oppCMB.CSBD_Now_NIF__c);
        }   
    }

    @isTest
    public static void altaOportunidadCMBtramoTres(){
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        String nombreCliente = 'test@test.com';
        String dniCliente = '12345678N';
        Datetime fechaDate = System.today().addDays(2);
        String fechaContacto = fechaDate.format('yyyy-MM-dd');
        String tramoHorario = '16h-18h';
        String codigoProducto = 'Seviam';
        String operativa = 'operativa';
        String numeroContrato = 'contrato';
        String descripcion = 'descripción3';
        
        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            CSBD_Opp_AltaCMBIntouch_Controller.altaCMBIntouch(nombreCliente, dniCliente, fechaContacto, tramoHorario, codigoProducto, operativa, numeroContrato, descripcion);
            Test.stopTest();
            
            Opportunity oppCMB = [SELECT Id, CSBD_Now_NombreCompleto__c, CSBD_Now_NIF__c FROM Opportunity WHERE CSBD_Now_NIF__c = '12345678N' LIMIT 1];
            
            System.assertEquals(nombreCliente, oppCMB.CSBD_Now_NombreCompleto__c);
            System.assertEquals(dniCliente, oppCMB.CSBD_Now_NIF__c);
        }
    }
}