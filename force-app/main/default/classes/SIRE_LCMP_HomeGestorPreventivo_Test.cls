/*****************************************************************
 Name:  SIRE_LCMP_HomeGestorPreventivo
 Copyright © 2023  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIRE_LCMP_HomeGestorPreventivo                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         29/03/2023     	  Created    

*****************************************************************/
@istest
public class SIRE_LCMP_HomeGestorPreventivo_Test {

    @istest
    public static void homeGestorPreventivoTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeGestorPreventivo',rol,'AV_Usuario_CaixaBank','U012222'); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
     
        System.runAs(usuario){            
            Test.startTest();           
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            List<SIREC__SIREC_obj_proceso__c> proceso = SIR_TestDataFactory.crearProceso(1, cuenta, SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO);            
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoCTLWS(proceso[0]);
            tarea.SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_PENDIENTE;
            update tarea;
            
            SIRE_LCMP_HomeGestorPreventivo.getUsuarioLogeado(usuario.Id);
            Id recordTypeProceso = SIRE_LCMP_HomeGestorPreventivo.getQueryRecordTypeProceso();
            List<SIREC__SIREC_obj_proceso__c> procesos = SIRE_LCMP_HomeGestorPreventivo.getQueryProcesos();
            SIRE_LCMP_HomeGestorPreventivo.getQueryReports();
            
            System.assertEquals(proceso[0].id, procesos[0].id, 'SIRE_LCMP_HomeGestorPreventivo.HomeGestorPreventivoTest La query no está trayendo el proceso correcto');
            Test.stopTest();
        }
        
    }

}