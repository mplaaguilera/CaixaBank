/*****************************************************************
 Name:  SIRE_LCMP_procesosActivosGrupoEco_Test
 Copyright © 2023  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIRE_LCMP_procesosActivosGrupoEconomico                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         10/03/2023     	  Created    

*****************************************************************/
@isTest
public class SIRE_LCMP_procesosActivosGrupoEco_Test {

    @isTest
    public static void testProcesosActivos() {
        
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario =SIR_TestDataFactory.createTestUser('UserTest1', rol, 'System Administrator');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_Integracion']; 
		insert new PermissionSetAssignment(AssigneeId = usuario.Id, PermissionSetId = ps.Id);
        
        Test.startTest();
        System.runAs(usuario) {
            List<SIRE_LCMP_procesosActivosGrupoEconomico.ProcesoWrapper> lstProcesoWrapper;
            SIR_Constantes constantes = new SIR_Constantes();
            
            Account cuenta = SIR_TestDataFactory.crearCuenta();            
            Account cuentaGrupoEconomico = SIR_TestDataFactory.crearCuentaGrupoEconomico();
            
            FinServ__ReciprocalRole__c reciprocalRol = SIR_TestDataFactory.crearReciprocalRole();
            FinServ__AccountAccountRelation__c relacion1GE = SIR_TestDataFactory.crearAccountAccountRelationGE(cuentaGrupoEconomico, cuenta, reciprocalRol);
            
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProcesoFechaConcreta(cuenta);
            proceso.SIR_ObjetivoProceso__c = 'EN GESTION';
            proceso.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E6;//'E.6 – Sin prioridad';
            proceso.name  = SIR_Constantes.TIPOPROCESO_FLUJO;
            proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION; 
            proceso.recordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId();
            update proceso;
            
            SIREC__SIREC_obj_proceso__c proceso2 = SIR_TestDataFactory.crearProcesoFechaConcreta(cuenta);
            proceso2.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E0;//'E.6 – Sin prioridad';
            proceso2.name  = SIR_Constantes.TIPOPROCESO_FLUJO;
            proceso2.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION;   
            proceso2.recordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId(); 
            update proceso2;  
            
            lstProcesoWrapper = SIRE_LCMP_procesosActivosGrupoEconomico.getProcesos(cuentaGrupoEconomico.id);
        	System.assertEquals(1, lstProcesoWrapper.size(),'No se ha generado el wrapper de proceso correctamente');
            Test.stopTest();            
        }       
    }
}