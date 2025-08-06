@isTest
public with sharing class SIR_cls_WS_procesosAgenciasTest {

    @TestSetup 
    static void makeData(){

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('procesosAgencias',rol,'AV_Usuario_CaixaBank','U012222');  
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        SIR_Constantes con = new SIR_Constantes();
        System.runAs(usuario){
            SIR_TestDataFactory.CrearIntegrationSetting('procesosAgencias');
        }   
    }

        @isTest 
        public static void procesosAgenciasOkTest(){
        List<Object> response;
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesosAgenciasMock());
            Test.startTest();
            response = SIR_cls_WS_procesosAgencias.procesosAgencias('OK', true);
            Test.stopTest();
            Assert.areEqual('OK', (String)response[0], 'SIR_cls_WS_procesosAgenciasTest.procesosAgenciasOkTest No devuelve respuesta OK cuando debería');
        }
    }
}