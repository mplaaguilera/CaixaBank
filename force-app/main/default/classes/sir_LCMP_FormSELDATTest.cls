@istest
public with sharing class sir_LCMP_FormSELDATTest {
    @TestSetup
    static void makeData(){
        List<Account> lstAccount = SIR_TestDataFactory.crearCuenta(1);
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = SIR_TestDataFactory.crearProceso(1,lstAccount.get(0));
        //List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,lstProcesos.get(0));
    }

    @isTest
    public static void getTareaTest(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c 
                                                        LIMIT 1];
        List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,lstProcesos.get(0));
        Test.startTest();
        SIREC__SIREC_obj_proceso__c tarea = SIR_LCMP_FormSELDAT.getTarea(lstProcesos.get(0).Id);
        Test.stopTest();
        System.assertEquals(tarea.SIREC__SIREC_fld_tarea__r.id, lstTarea.get(0).id, 'No se obtiene la tarea experada en SIREC_LCMP_formulario.getTarea');
    }

    @isTest
    public static void updateTareaTest(){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,lstProcesos.get(0));
        lstTarea.addALL(SIR_TestDataFactory.createTarea(1,lstProcesos.get(0)));
        lstTarea.addALL(SIR_TestDataFactory.createTarea(1,lstProcesos.get(0)));
        lstTarea.addALL(SIR_TestDataFactory.createTarea(1,lstProcesos.get(0)));
        lstTarea.get(0).SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_SEL;
        lstTarea.get(0).SIREC__SIREC_fld_SEL_opciones_cod__c = 'opcion1|opcion2';
        lstTarea.get(0).SIREC__SIREC_fld_SEL_opciones_desc__c = 'desc1|desc2';
        lstTarea.get(0).SIREC__SIREC_fld_SEL_respuestas_cod__c = 'opcion2';
        lstTarea.get(1).SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
        lstTarea.get(1).SIREC__SIREC_fld_seleccion__c = SIR_Constantes.CODIGO_SELECCION_FECHA;
        lstTarea.get(2).SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
        lstTarea.get(2).SIREC__SIREC_fld_seleccion__c = SIR_Constantes.CODIGO_SELECCION_NUMERO;
        lstTarea.get(3).SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
        lstTarea.get(3).SIREC__SIREC_fld_seleccion__c = SIR_Constantes.CODIGO_SELECCION_ALFANUMERICO;
        update lstTarea;
        String seleccion0 = 'seleccion0';
        String seleccion1 = String.valueOf(Date.today());
        String seleccion2 = String.valueOf(10000);
        String seleccion3 = 'seleccion3';
        Test.startTest();
        SIR_LCMP_FormSELDAT.updateTarea(lstTarea.get(0).Id,seleccion0,'comentario0',false);
        SIR_LCMP_FormSELDAT.updateTarea(lstTarea.get(1).Id,seleccion1,'comentario1',false);
        SIR_LCMP_FormSELDAT.updateTarea(lstTarea.get(2).Id,seleccion2,'comentario2',false);
        SIR_LCMP_FormSELDAT.updateTarea(lstTarea.get(3).Id,seleccion3,'comentario3',false);
        Test.stopTest();
        List<SIREC__SIREC_obj_tarea__c> lstNTareas = [SELECT Id,SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_DAT_fecha__c,SIREC__SIREC_fld_DAT_importe__c, SIREC__SIREC_fld_DAT_texto__c
                                            FROM SIREC__SIREC_obj_tarea__c];
        System.assertEquals('seleccion0', lstNTareas.get(0).SIREC__SIREC_fld_SEL_respuestas_cod__c, 'Los Códigos seleccionados no se han guardado');
        System.assertEquals(Date.today(), lstNTareas.get(1).SIREC__SIREC_fld_DAT_fecha__c, 'La fecha seleccionados no se han guardado');
        System.assertEquals(10000, lstNTareas.get(2).SIREC__SIREC_fld_DAT_importe__c, 'El Valor seleccionados no se han guardado');
        System.assertEquals('seleccion3', lstNTareas.get(3).SIREC__SIREC_fld_DAT_texto__c, 'El texto no se han guardado');
            
    }

    @isTest
    public static void respTextTareaTest (){
        List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(lstProcesos.get(0));
        tarea.SIREC__SIREC_fld_SEL_respuestas_cod__c = 'opcion2';
        Test.startTest();
        String resultado = SIR_LCMP_FormSELDAT.respTextTarea(tarea, tarea.SIREC__SIREC_fld_SEL_respuestas_cod__c);
        Test.stopTest();
        System.assertEquals('desc2', resultado, 'La descripción es incorrecta');
    }
}