@isTest
public class SIRE_LCMP_ListaProcesosGestorFlujo_Test {

    /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIRE_LCMP_ListaProcesosGestorFlujo                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249684         Atmira         29/07/2021     	  Created    
        
	*****************************************************************/    
    @isTest static void listaProcesosGestorFlujoTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        SIR_Constantes constantes = new SIR_Constantes();
        System.runAs(usuario){
            List<SIREC__SIREC_obj_proceso__c> procesos = new List<SIREC__SIREC_obj_proceso__c>();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIR_TestDataFactory.ProcesosTest procesoTest = new SIR_TestDataFactory.procesosTest('mrid2',SIR_Constantes.PROCESO_ESTRATEGIA_E0_NAME, SIR_Constantes.TIPOPROCESO_FLUJO, cuenta);
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(procesoTest);
            proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_SIRE_PENDIENTE_INICIO_GESTION;
            update proceso;
            String valueIdOwner = [SELECT OwnerId from SIREC__SIREC_obj_proceso__c where Id = :proceso.Id].OwnerId;
            String url;
            Test.startTest();
            procesos = SIRE_LCMP_ListaProcesosGestorFlujo.getProcesos();
            url = SIRE_LCMP_ListaProcesosGestorFlujo.getURL();
            Test.stopTest();
            Id recordTypeIdFlujo = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO).getRecordTypeId();
            Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_SIRE_PENDIENTE_INICIO_GESTION};
            List<SIREC__SIREC_obj_proceso__c> procesoCuenta = [SELECT id, 
            SIREC__SIREC_fld_cliente__r.Name, SIREC__SIREC_fld_cliente__r.Id, 
            name, 
            toLabel(SIREC__SIREC_fld_estrategia__c), 
            toLabel(SIREC__SIREC_fld_situacion__c), 
            SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_fechaInicio__c, 
            Owner.Name
            FROM SIREC__SIREC_obj_proceso__c 
            WHERE SIREC__SIREC_fld_situacion__c IN :setSituaciones 
            AND OwnerId =: valueIdOwner
            AND RecordTypeId =: recordTypeIdFlujo
            AND SIR_ObjetivoProceso__c !=: SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
            ORDER BY SIREC__SIREC_fld_fechaSituacion__c];
            Assert.areEqual(procesoCuenta,  procesos, 'No está devolviendo el proceso correcto');        
            Assert.areEqual(true, url.contains('SIRE_Inicio_FLUJO'), 'La url no está devolviendo bien la home de flujo');
            Assert.areEqual(true, url.contains('c__SIRE_MisClientesSolucionesEMP'), 'No está llevando a la home de empresas');
        } 
    }
}