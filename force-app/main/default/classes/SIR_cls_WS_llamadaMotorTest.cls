@isTest
public with sharing class SIR_cls_WS_llamadaMotorTest {
    @TestSetup
    static void makeData(){

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('llamadaMotorTest',rol,'AV_Usuario_CaixaBank','U012222');  

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
           Account cuenta = SIR_TestDataFactory.crearCuenta();
        
           SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644'); 
                
           SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);        
           SIREC__SIREC_obj_tarea__c tareaDAT = SIR_TestDataFactory.crearTareaTipoDAT(proceso);        
           SIR_TestDataFactory.CrearIntegrationSetting('llamadaMotor');
        }   
    }

    @isTest
    public static void avanzaMotorSELTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
           SIREC__SIREC_obj_tarea__c tarea = [SELECT SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_accessToken__c 
                                               FROM SIREC__SIREC_obj_tarea__c 
                                               WHERE SIREC__SIREC_fld_tipo_tarea__c ='SEL'
                                               LIMIT 1];        
        
           tarea.SIREC__SIREC_fld_SEL_respuestas_cod__c = 'resps';
           List<Object> response;
           Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
           Test.startTest();
           response = SIR_cls_WS_llamadaMotor.avanzaMotor(tarea);
           Test.stopTest();        
           System.assertEquals('OK', (String)response[0], 'SIR_cls_WS_llamadaMotorSELTest.avanzaMotorTest No devuelve respuesta OK cuando debería');
        }
    }
    @isTest
    public static void avanzaMotorDATFTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
           SIREC__SIREC_obj_tarea__c tarea = [SELECT SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_accessToken__c, SIREC__SIREC_fld_codigo_tarea__c 
                                               FROM SIREC__SIREC_obj_tarea__c 
                                               WHERE SIREC__SIREC_fld_tipo_tarea__c ='DAT'                                             
                                               LIMIT 1];                
        
            tarea.SIREC__SIREC_fld_DAT_fecha__c = Date.today();
            tarea.SIREC__SIREC_fld_seleccion__c ='F';
            List<Object> response;
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
            Test.startTest();
            response = SIR_cls_WS_llamadaMotor.avanzaMotor(tarea);
            Test.stopTest();        
            System.assertEquals('OK', (String)response[0], 'SIR_cls_WS_llamadaMotorTest.avanzaMotorDATDTest No devuelve respuesta OK cuando debería');
        }
    }
        @isTest
        public static void avanzaMotorDATNTest() {
            User usuario = [SELECT Id FROM User LIMIT 1];
            System.runAs(usuario){
                SIREC__SIREC_obj_tarea__c tarea = [SELECT SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_accessToken__c,SIREC__SIREC_fld_codigo_tarea__c 
                                                    FROM SIREC__SIREC_obj_tarea__c 
                                                    WHERE SIREC__SIREC_fld_tipo_tarea__c ='DAT'                                          
                                                    LIMIT 1];                
                
                tarea.SIREC__SIREC_fld_DAT_importe__c = 100;
                tarea.SIREC__SIREC_fld_seleccion__c ='N';
                List<Object> response;
                Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
                Test.startTest();
                response = SIR_cls_WS_llamadaMotor.avanzaMotor(tarea);
                Test.stopTest();        
                System.assertEquals('OK', (String)response[0], 'SIR_cls_WS_llamadaMotorTest.avanzaMotorDATDTest No devuelve respuesta OK cuando debería');
            }
        }

    @isTest
      public static void avanzaMotorDATATest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            SIREC__SIREC_obj_tarea__c tarea = [SELECT SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_accessToken__c, SIREC__SIREC_fld_codigo_tarea__c 
                                                FROM SIREC__SIREC_obj_tarea__c 
                                                WHERE SIREC__SIREC_fld_tipo_tarea__c ='DAT'                                          
                                                LIMIT 1];                
            
            tarea.SIREC__SIREC_fld_DAT_texto__c = 'Texto de la DAT';
            tarea.SIREC__SIREC_fld_seleccion__c ='A';
            List<Object> response;
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
            Test.startTest();
            response = SIR_cls_WS_llamadaMotor.avanzaMotor(tarea);
            Test.stopTest();        
            System.assertEquals('OK', (String)response[0], 'SIR_cls_WS_llamadaMotorTest.avanzaMotorDATDTest No devuelve respuesta OK cuando debería');
        }   
    }
    @isTest
    public static void avanzaMotorErrorTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            SIREC__SIREC_obj_tarea__c tarea = [SELECT SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_accessToken__c 
                                                FROM SIREC__SIREC_obj_tarea__c 
                                                LIMIT 1];
            
            tarea.SIREC__SIREC_fld_tipo_tarea__c ='ERROR';
            List<Object> response;
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
            Test.startTest();
            response = SIR_cls_WS_llamadaMotor.avanzaMotor(tarea);
            Test.stopTest();        
            System.assertEquals('KO', (String)response[0], 'SIR_cls_WS_llamadaMotorTest.avanzaMotorTest No devuelve respuesta OK cuando debería');
            System.assertEquals('Error: 0 - Descripcion de tipo tarea Erroneo', (String)response[2], 'SIR_cls_WS_llamadaMotorTest.avanzaMotorTest No devuelve respuesta OK cuando debería');
        }
    }
}