/**********************************************************************************************************************
Name: Cibe_ComentarioCitaActExControllerTest
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test del controlador Cibe_ComentarioCitaActExController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY               AUTHOR              DATE                Description
    1.0            PPM100458164             Luis Martínez       07/08/2024          Init version
***********************************************************************************************************************/
@IsTest
public with sharing class CIBE_ComentarioCitaActExControllerTest {
    @TestSetup
    static void setUp(){
        CIBE_TestInitialSetup.setupInitialDataEMP();

        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];


        System.runAs(admin){
            Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' AND ownerId =: u.id];

            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
            Account acc =  CIBE_TestHelper.createCustomer();
            Event evnt = CIBE_TestHelper.createEvent(u, System.now(), acc);

            RecordType rtC = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
            Contact employee = new Contact();
            employee.RecordTypeId = rtC.Id;
            employee.FirstName = 'Empleado Test';
            employee.LastName = '1';
            employee.CC_Idioma__c = 'es';
            employee.CC_Matricula__c = 'U01';
            employee.CIBE_Cartera__c = '001';
            employee.CIBE_Sector__c = '001';
            employee.AccountId = acc.Id;
            employee.AV_UsuarioAsociado__c = usrTest.Id;
            employee.OwnerId = u.Id;
            insert employee;

            }
        
    }

    @IsTest
    static void getComentarioTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        System.runAs(usuario){
        Test.StartTest();
            List<Event> e = [SELECT Id, CIBE_Confidential__c FROM Event WHERE Subject = 'Call' LIMIT 1];
            List <CBK_Activity_Extension__c> lstActEx = [select Id,CIBE_ComentarioCita__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c =:e[0].ID];
            String com = CIBE_ComentarioCitaActExController.getComentario(e[0].Id);
            System.assertEquals(lstActEx[0].CIBE_ComentarioCita__c, com);
            Test.StopTest();
        }
    }
}