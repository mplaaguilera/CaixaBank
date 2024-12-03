/*****************************************************************
 Name:  SIR_cls_tareaHandlerTest
 Copyright © 2021  CaixaBank
  
Proposito:   Clase Test de la clase SIR_cls_tareaHandler                                                                                                                   
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US449066         atmira         03/10/2022	      Created    

*****************************************************************/

@istest
public with sharing class SIR_cls_tareaHandlerTest {
    @TestSetup
    static void makeData(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProcesoPRESOL(cuenta);
        }   
    }
    
    @isTest
    public static void updateTareaProcesoTest() {
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_tarea__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.stopTest();  
        }
        SIREC__SIREC_obj_proceso__c procesoUpdate = [SELECT Id, SIREC__SIREC_fld_tarea__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];

        System.assertEquals(proceso.SIREC__SIREC_fld_tarea__c != procesoUpdate.SIREC__SIREC_fld_tarea__c, true, 'Fallo test updateTareaProcesoTest');
    }


    @isTest
    public static void updateEstadoFinalizadaTest() {
        
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_tarea__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea2 = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
        tarea2.Name = 'Tarea 2';
        tarea2.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_ENVIADA;
        tarea2.SIREC__SIREC_fld_insertWS__c = true;
        update tarea2;
		User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
        Test.startTest();
        SIREC__SIREC_obj_tarea__c tarea3 = SIR_TestDataFactory.crearTareaTipoCTLWS(proceso);
        Test.stopTest();  
        }
        SIREC__SIREC_obj_tarea__c tarea2Update = [SELECT Id, Name, SIREC__SIREC_fld_estado__c FROM SIREC__SIREC_obj_tarea__c WHERE Name = 'Tarea 2' LIMIT 1];

        System.assertEquals(tarea2Update.SIREC__SIREC_fld_estado__c == 'Finalizada', true, 'Fallo test updateEstadoFinalizadaTest --> tarea 2 - '+ tarea2Update.SIREC__SIREC_fld_estado__c + ' - tarea 2 update - '+tarea2Update.SIREC__SIREC_fld_estado__c);
    }


    @isTest
    public static void asignarClienteTest(){
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_tarea__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
            Test.startTest();
            System.runAs(usuario){
                SIR_TestDataFactory.createTarea(1,proceso);
            }
            Test.stopTest();
        }
        
        Assert.areEqual([SELECT Id FROM Account LIMIT 1].Id, [SELECT SIR_cliente__c FROM SIREC__SIREC_obj_tarea__c].SIR_cliente__c, 'SIR_cls_tareaHandlerTest.asignarClienteTest: No se ha asignado correctamente el cliente');
    }
}