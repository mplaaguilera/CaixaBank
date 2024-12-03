@isTest
public with sharing class SIR_cls_WS_consultaPropuestaTest {

    @TestSetup 
    static void makeData(){

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('consultaPropuesta',rol,'AV_Usuario_CaixaBank','U012222');  
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
           SIR_TestDataFactory.CrearIntegrationSetting('consultaPropuesta','{idPropuesta}');
        }   
    }

        @isTest static void consultaPropuestaOkTest() {
        List<Object> response;
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_consultaPropuestaMock());
            Test.startTest();
            response = SIR_cls_WS_consultaPropuesta.consultaPropuesta('OK');
            Test.stopTest();
            Assert.areEqual('OK', (String)response[0], 'SIR_cls_WS_consultaPropuestaTest.consultaPropuestaOkTest No devuelve respuesta OK cuando debería');
        }
    }
}