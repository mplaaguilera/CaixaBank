/*****************************************************************
 Name:  SIR_Batch_ControlCompromiso
 Copyright © 2021  CaixaBank
  
Proposito:   Clase Batch que controla el cumplimiento del compromiso de un cliente                                                                                                                 
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         16/12/2021     	 Created    

*****************************************************************/

public with sharing class SIR_Batch_ControlCompromiso implements Database.Batchable<SObject>, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        Id recordTypeAccAmistoso = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByName().get(SIR_Constantes.ACCION_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        Id recordTypeProcesoAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        
		return Database.getQueryLocator( 'SELECT Id, (SELECT Id, SIR_CodigoEstrategia__c, SIR_estrategia__c, SIR_FechaCompromisoPago__c, SIR_ResultadoVacio__c, SIR_valorAccion__c, '+
                                            'SIREC__SIREC_fld_accion__c, SIREC__SIREC_fld_comentarios__c, SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_fechaContacto__c, SIREC__SIREC_fld_fechaRealizacion__c, '+
                                            'SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_intervinientes__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_proceso__c, SIREC__SIREC_fld_responsable__c, '+
                                            'SIREC__SIREC_fld_resultado__c, SIREC__SIREC_fld_tipo__c, SIREC__SIREC_fld_voluntad__c, RecordTypeId FROM SIREC__Acciones__r ' +
                                            ' WHERE SIREC__SIREC_fld_resultado__c =\''+ SIR_Constantes.ACCION_RESULTADO_COMPROMISO_DE_PAGO + '\' AND RecordTypeId = \''+ recordTypeAccAmistoso + '\' ORDER BY SIR_FechaCompromisoPago__c DESC LIMIT 2 )' +
                                            'FROM SIREC__SIREC_obj_proceso__c ' + 
                                            'WHERE SIR_fld_Situacion_SF__c =\''+ SIR_Constantes.PROCESO_SITUACION_COMPROMISO_DE_PAGO + '\' AND RecordTypeId = \'' + recordTypeProcesoAmistoso + '\' '+
                                            'AND  SIR_FechaCompromisoPago__c <=' + todaysDateStr);
        
                                            
	}

    public void execute(Database.BatchableContext context, List<SIREC__SIREC_obj_proceso__c> scope) {
        //Se define vacio aquí porque el FWK da error si se hace fuera de los metodos
        List<SIREC__SIREC_obj_acciones__c> lstAcciones = new List<SIREC__SIREC_obj_acciones__c>();
        try{
            for(SIREC__SIREC_obj_proceso__c proceso : scope){
                if(proceso.SIREC__Acciones__r.size() >0){
                    String resultado = SIR_Constantes.ACCION_RESULTADO_COMPROMISO_PAGO_INCUMPLIDO ;

                    if(proceso.SIREC__Acciones__r.size() > 1){
                        resultado = SIR_Constantes.ACCION_RESULTADO_NO_COLABORA_CON_ACUERDO_INCUMPLIDO;
                    }
                    lstAcciones.add(new SIREC__SIREC_obj_acciones__c(
                        SIR_CodigoEstrategia__c = proceso.SIREC__Acciones__r.get(0).SIR_CodigoEstrategia__c,
                        SIR_estrategia__c = proceso.SIREC__Acciones__r.get(0).SIR_estrategia__c,
                        SIR_FechaCompromisoPago__c = proceso.SIREC__Acciones__r.get(0).SIR_FechaCompromisoPago__c,
                        SIR_valorAccion__c = proceso.SIREC__Acciones__r.get(0).SIR_valorAccion__c,
                        SIREC__SIREC_fld_accion__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_accion__c,
                        SIREC__SIREC_fld_comentarios__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_comentarios__c,
                        SIREC__SIREC_fld_estado__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_estado__c,
                        SIREC__SIREC_fld_fechaContacto__c = Date.today(),
                        SIREC__SIREC_fld_fechaRealizacion__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_fechaRealizacion__c,
                        SIREC__SIREC_fld_interviniente__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_interviniente__c,
                        SIREC__SIREC_fld_intervinientes__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_intervinientes__c,
                        SIREC__SIREC_fld_persona__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_persona__c,
                        SIREC__SIREC_fld_proceso__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_proceso__c,
                        SIREC__SIREC_fld_responsable__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_responsable__c,
                        SIREC__SIREC_fld_resultado__c = resultado,
                        SIREC__SIREC_fld_tipo__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_tipo__c,
                        SIREC__SIREC_fld_voluntad__c = proceso.SIREC__Acciones__r.get(0).SIREC__SIREC_fld_voluntad__c,
                        RecordTypeId = proceso.SIREC__Acciones__r.get(0).RecordTypeId));                
                }
            }
            insert lstAcciones;
            if(lstAcciones != null){
                System.enqueueJob(new SIR_QueueableSendAction(lstAcciones));
            } 
        }
        catch(Exception ex){
            if(lstAcciones != null){
                CBK_log.error(ex, 'Error : SIR_Batch_ControlCompromiso - ' + ex.getTypeName() + ': ' + ex.getMessage(), lstAcciones);
            }else{
                CBK_log.error(ex, 'Error : SIR_Batch_ControlCompromiso - ' + ex.getTypeName() + ': ' + ex.getMessage());
            }
            
        }       
	}

    public void finish(Database.BatchableContext context) {
        
	}
}