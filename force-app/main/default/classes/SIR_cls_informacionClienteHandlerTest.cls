/*****************************************************************
 Name:  SIR_cls_informacionClienteHandlerTest
 Copyright © 2021  CaixaBank
  
 Proposito :   Clase Test de la clase SIR_cls_informacionClienteHandler                                                                                                                  
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         18/11/2022     	 Created    

*****************************************************************/
@isTest
public with sharing class SIR_cls_informacionClienteHandlerTest {

    @testSetup static void setupMethod(){
        SIR_TestDataFactory.CrearIntegrationSetting('altaComentarioGestor');
    }


    @isTest
    public static void sendComentario() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
   		System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            informacionCliente.SIREC__SIREC_fld_codigoEmpleado__c = 'CódigoEmpleado';
            informacionCliente.SIREC__SIREC_fld_fechaModificacion__c = Datetime.now();
            informacionCliente.SIREC__SIREC_fld_masterRecordId__c = 'masterRecordId';
            informacionCliente.SIREC__SIREC_fld_comentariosRecuperaciones__c = 'Comentario correcto';
            List<SIREC__SIREC_obj_informacionCliente__c> lstInformacionCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();

            lstInformacionCliente.add(informacionCliente);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_EnviarComentarioMock());  
            test.startTest();
            update informacionCliente;
            test.stopTest();
        }
        System.assertEquals(0, [Select Id, Apex_Class__c from CBK_Log__c where Apex_Class__c = 'SIR_cls_WS_EnviarComentario'].size(), 'SIR_cls_WS_EnviarComentarioTest.sirClsWsEnviarComentarioCorrectoTest: Se ha producido un error no esperado');

    }
}