@IsTest
public with sharing class SIR_formSELDAT_Test {
    @TestSetup
    static void makeData(){
        Id recordTypeIdPresol = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();

        Account account = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(account);
        proceso.OwnerId = UserInfo.getUserId();
        proceso.RecordTypeId = recordTypeIdPresol;
        update proceso;
    }

    @isTest
    public static void getTareaTest(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,lstProcesos[0]);

        Test.startTest();
        //Modificado por Kevin, pendiente de eliminar
        //String propietario = sir_LCMP_FormSELDAT.comprobarPropietarioProceso(lstProcesos[0].Id);
        SIREC__SIREC_obj_proceso__c tareaResultado = sir_LCMP_FormSELDAT.getTarea(lstProcesos[0].Id);
        Test.stopTest();

        System.assertEquals(tareaResultado.SIREC__SIREC_fld_tarea__c, lstTarea[0].Id, 'No se obtiene la tarea experada en SIR_formSELDAT_Test.getTarea');
    
    }

    
   @isTest
    public static void updateTareaTest0(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea0 = SIR_TestDataFactory.createTarea(1,lstProcesos.get(0)).get(0);
        tarea0.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_SEL;
        tarea0.SIREC__SIREC_fld_seleccion__c = 'seleccion0';
        tarea0.SIREC__SIREC_fld_SEL_opciones_cod__c = 'seleccion0';
        tarea0.SIREC__SIREC_fld_SEL_opciones_desc__c = 'seleccion0';
        update tarea0;
        String seleccion0 = 'seleccion0';
        Test.startTest();
        sir_LCMP_FormSELDAT.updateTarea(tarea0.Id,seleccion0,'',false);
        Test.stopTest();
        List<SIREC__SIREC_obj_tarea__c> lstNTareas = [SELECT Id,SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_DAT_fecha__c,SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_texto__c
                                            FROM SIREC__SIREC_obj_tarea__c];
        System.assertEquals('seleccion0', lstNTareas.get(0).SIREC__SIREC_fld_SEL_respuestas_cod__c, 'Los Códigos seleccionados no se han guardado');
    }
    
    @isTest
    public static void updateTareaTest1(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea1 = SIR_TestDataFactory.createTarea(1,lstProcesos.get(0)).get(0);
        tarea1.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
        tarea1.SIREC__SIREC_fld_seleccion__c = SIR_Constantes.CODIGO_SELECCION_FECHA;
        update tarea1;
        String seleccion1 = String.valueOf(Date.today());
        Test.startTest();
        sir_LCMP_FormSELDAT.updateTarea(tarea1.Id,seleccion1,'',false);
        Test.stopTest();
        List<SIREC__SIREC_obj_tarea__c> lstNTareas = [SELECT Id,SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_DAT_fecha__c,SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_texto__c
                                            FROM SIREC__SIREC_obj_tarea__c];
        System.assertEquals(Date.today(), lstNTareas.get(0).SIREC__SIREC_fld_DAT_fecha__c, 'La fecha seleccionados no se han guardado');
            
    }
    
    @isTest
    public static void updateTareaTest2(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea2 = SIR_TestDataFactory.createTarea(1,lstProcesos.get(0)).get(0);
        tarea2.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
        tarea2.SIREC__SIREC_fld_seleccion__c = SIR_Constantes.CODIGO_SELECCION_NUMERO;
        update tarea2;
        String seleccion2 = String.valueOf(10000);
        Test.startTest();
        sir_LCMP_FormSELDAT.updateTarea(tarea2.Id,seleccion2,'',false);
        Test.stopTest();
        List<SIREC__SIREC_obj_tarea__c> lstNTareas = [SELECT Id,SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_DAT_fecha__c,SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_texto__c
                                            FROM SIREC__SIREC_obj_tarea__c];
        System.assertEquals(10000, lstNTareas.get(0).SIREC__SIREC_fld_DAT_importe__c, 'El Valor seleccionados no se han guardado');
            
    }
    
    @isTest
    public static void updateTareaTest3(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea3 = SIR_TestDataFactory.createTarea(1,lstProcesos.get(0)).get(0);
        tarea3.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
        tarea3.SIREC__SIREC_fld_seleccion__c = SIR_Constantes.CODIGO_SELECCION_ALFANUMERICO;
        update tarea3;
        String seleccion3 = 'seleccion3';
        Test.startTest();
        sir_LCMP_FormSELDAT.updateTarea(tarea3.Id,seleccion3,'',false);
        Test.stopTest();
        List<SIREC__SIREC_obj_tarea__c> lstNTareas = [SELECT Id,SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_DAT_fecha__c,SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_texto__c
                                            FROM SIREC__SIREC_obj_tarea__c];
        System.assertEquals('seleccion3', lstNTareas.get(0).SIREC__SIREC_fld_DAT_texto__c, 'El texto no se han guardado');
            
    }


}