/*****************************************************************
 Name:  SIR_TareaCTL_Test
 Copyright © 2023  CaixaBank

 Proposito:   Clase Test de la clase controladora externa del LWC SIRE_LCMP_HomeGestorFlujo                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         23/02/2023     	  Created    

*****************************************************************/
@istest
public class SIRE_LCMP_HomeGestorFlujo_Test {

    @istest
    public static void homeGestorFlujoTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeGestorFlujo',rol,'AV_Usuario_CaixaBank','U012222');        
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        List<SIREC__SIREC_obj_proceso__c> procesos;
        List<SIREC__SIREC_obj_proceso__c> procesoTest;
        List<Report> informes = new List<Report>();
        Id recordTypeProceso;
        SIREC__SIREC_obj_tarea__c tarea = new SIREC__SIREC_obj_tarea__c();
        List<SIREC__SIREC_obj_tarea__c> lstTarea = new List<SIREC__SIREC_obj_tarea__c>();
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            procesoTest = SIR_TestDataFactory.crearProceso(1, cuenta, SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO);
            tarea = SIR_TestDataFactory.crearTareaTipoCTLWS(procesoTest[0]);
            tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_PENDIENTE;
            update tarea;
            Test.startTest();
            recordTypeProceso = SIRE_LCMP_HomeGestorFlujo.getQueryRecordTypeProceso();
            procesos = SIRE_LCMP_HomeGestorFlujo.getQueryProcesos();
            informes = SIRE_LCMP_HomeGestorFlujo.getQueryReports();
            Test.stopTest();
        }
        List<RecordType> procesosRT = new List<RecordType>();
        procesosRT = [SELECT DeveloperName FROM RecordType WHERE SobjectType ='SIREC__SIREC_obj_proceso__c' AND id =: recordTypeProceso LIMIT 1];
        System.assertEquals(procesoTest[0].id, procesos[0].id, 'SIRE_LCMP_HomeGestorFlujo.HomeGestorFlujoTest La query no está trayendo el proceso correcto');
        System.assertEquals('SIRE_RT_Amistoso', procesosRT[0].DeveloperName, 'SIRE_LCMP_HomeGestorFlujo.HomeGestorFlujoTest El recordType no es el correcto');
        System.assertNotEquals(null, informes);
    }
}