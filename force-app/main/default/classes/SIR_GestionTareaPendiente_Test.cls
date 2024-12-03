/*****************************************************************
 Name:  SIR_GestionTareaPendiente_Test
 Copyright © 2022  CaixaBank

Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_GestionTareaPendiente (sir_lwc_GestionTareaPendiente)                                                                                                                  

Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         10/05/2022     	  Created    

*****************************************************************/
@isTest 
public class SIR_GestionTareaPendiente_Test {

    @TestSetup
    static void makeData(){
        SIR_TestDataFactory.CrearIntegrationSetting('procesoInfo');
    }
    /*****************************************************************
        Proposito:  test1 sirve para comprobar toda la logica del controlador SIR_LCMP_GestionTareaPendiente                                                      
        Parameters: No
        Returns: No                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         10/05/2022     	  Created    
        
	*****************************************************************/
    @isTest static void getTipoTareaTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','09999');
        System.runAs(usuario){
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        List<SIREC__SIREC_obj_proceso__c> proceso = SIR_TestDataFactory.crearProceso(1, cuenta);
        SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso.get(0));
        tarea.SIREC__SIREC_fld_tipo_tarea__c = 'ACT';
        update tarea;    
        Test.startTest();
            proceso = SIR_LCMP_GestionTareaPendiente.getTipoTarea(proceso.get(0).id, true);
        Test.stopTest();
        System.assertEquals(tarea.SIREC__SIREC_fld_tipo_tarea__c, proceso.get(0).SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, 'Algo ha en el getTipoTarea');
        }
    }    

    @isTest static void testException() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','09999');
        System.runAs(usuario){
            boolean ex = false;
            Test.startTest();
                try {
                    SIR_LCMP_GestionTareaPendiente.getTipoTarea('', true);
                } catch (Exception e) {
                    ex = true;
                }
            Test.stopTest();
            System.assertEquals(true, ex, 'Se esperaba una Excepción y no ha saltado');
        }
    }

    @isTest static void accionEnviadaTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','09999');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            List<SIREC__SIREC_obj_proceso__c> proceso = SIR_TestDataFactory.crearProceso(1, cuenta);
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoCTLWS(proceso.get(0));
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.crearAccion(proceso.get(0));
            accion.SIREC__SIREC_fld_tarea__c = tarea.Id;
            accion.SIR_accionEnviada__c = true;
            update accion;
            Boolean accionEnviada=false;
            Test.startTest();
                accionEnviada = SIR_LCMP_GestionTareaPendiente.accionEnviada(tarea.Id);
            Test.stopTest();
            System.assertEquals(accionEnviada, true, 'Se esperaba accionEnviada a true');
        }
    }         

    @isTest static void sinAccionEnviadaTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','09999');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            List<SIREC__SIREC_obj_proceso__c> proceso = SIR_TestDataFactory.crearProceso(1, cuenta);
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoCTLWS(proceso.get(0));        
            Boolean accionEnviada=false;
            Test.startTest();
                accionEnviada = SIR_LCMP_GestionTareaPendiente.accionEnviada(tarea.Id);
            Test.stopTest();
            System.assertEquals(accionEnviada, false, 'Se esperaba accionEnviada a false');
        }
    }

    @isTest static void puedeGestionarUserNotApiTest(){
        Boolean puedeGestionar;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuarioPropietario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmpPropietario',rol,'System Administrator','U0111112','001-06403');
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','09999');
        usuario.AV_tipoGestor__c = SIR_Constantes.TIPO_TGA;
        update usuario;
        System.runAs(usuarioPropietario) {           
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            List<SIREC__SIREC_obj_proceso__c> proceso = SIR_TestDataFactory.crearProceso(1, cuenta);
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso.get(0));
            SIREC__SIREC_obj_proceso__c proceso2 = SIR_TestDataFactory.crearProceso(cuenta);
            proceso2.recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO).getRecordTypeId();
            proceso2.SIR_EmpleadoPREVEMP__c = 'NEGOCIO';
            update proceso2;
            System.runAs(usuario) {            
                Test.startTest();
                    puedeGestionar = SIR_LCMP_GestionTareaPendiente.puedeGestionar(proceso.get(0).Id);            	
                    SIR_LCMP_GestionTareaPendiente.puedeGestionar(proceso2.Id);
                    proceso2.SIR_EmpleadoPREVEMP__c = 'RIESGOS';
                    update proceso2;
                    SIR_LCMP_GestionTareaPendiente.puedeGestionar(proceso2.Id);
                    proceso2.SIR_AnalistaRiesgo__c = usuario.Id;
                    update proceso2;
                    SIR_LCMP_GestionTareaPendiente.puedeGestionar(proceso2.Id);
                Test.stopTest();
        	}
            System.assertEquals(puedeGestionar,false,'');            
        }
    }

    @isTest static void puedeGestionarCambioOwnerTest(){
        Boolean puedeGestionar;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','001-06403');
        User usuarioApi = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp2',rol,'Api Only','U0111111','001-06403');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIRE_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuarioApi.Id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            cuenta.CC_Numero_Oficina_Empresa__c = '001-06403';
            update cuenta;
            List<SIREC__SIREC_obj_proceso__c> proceso = SIR_TestDataFactory.crearProceso(1, cuenta);
            proceso[0].OwnerId = usuarioApi.Id;
            update proceso;
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso.get(0));
            Test.startTest();
                puedeGestionar = SIR_LCMP_GestionTareaPendiente.puedeGestionar(proceso.get(0).Id);
            	puedeGestionar = SIR_LCMP_GestionTareaPendiente.puedeGestionar(cuenta.Id);
            Test.stopTest();
        }
        System.assertEquals(puedeGestionar,false,'Se esperaba puedeGestionar a false');
    }

    @isTest static void puedeGestionarNoAccessTest(){
        Boolean puedeGestionar;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','001-06401');
        User usuarioApi = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp2',rol,'Api Only','U0111111','001-06402');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            cuenta.CC_Numero_Oficina_Empresa__c = '001-06403';
            update cuenta;
            List<SIREC__SIREC_obj_proceso__c> proceso = SIR_TestDataFactory.crearProceso(1, cuenta);
            proceso[0].OwnerId = usuarioApi.Id;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIRE_gestorSolutions'];
            insert new PermissionSetAssignment(AssigneeId = usuarioApi.Id, PermissionSetId = ps.Id);
            update proceso;
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso.get(0));
            Test.startTest();
                puedeGestionar = SIR_LCMP_GestionTareaPendiente.puedeGestionar(proceso.get(0).Id);
            Test.stopTest();
        }
        System.assertEquals(puedeGestionar,false,'Se esperaba puedeGestionar a false');
    }

    @Istest
    static void sincronizarProcesoTest(){
        List<Object> response;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345645');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
            response = SIR_LCMP_GestionTareaPendiente.sincronizaProceso(proceso.Id);
            Test.stopTest();
            Assert.areEqual('OK', (String)response[0], 'SIR_GestionTareaPendiente_Test.sincronizarProcesoTest No devuelve respuesta OK cuando debería');
        }
    }
}