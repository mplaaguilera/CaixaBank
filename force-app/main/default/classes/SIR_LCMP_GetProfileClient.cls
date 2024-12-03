/*****************************************************************
 Name:  SIR_LCMP_GetProfileClient
 Copyright © 2021  CaixaBank

Proposito:   Clase controladora externa de los LWC:
                - sir_lwc_cabeceraCliente, 
                - sir_lwc_cabeceraClienteTabs, 
                - sir_lwc_cabeceraProcesoPRESOL                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244035      Atmira         21/06/2021         Created    

*****************************************************************/
public with sharing class SIR_LCMP_GetProfileClient {
    public static string clase = 'SIR_LCMP_GetProfileClient';
    
	/*****************************************************************
        Proposito:  Recuperar datos del objeto SIREC__SIREC_obj_informacionCliente__c                                                         
        LWC asociado:  sir_lwc_cabeceraCliente
        Parameters: recordId, tipoFicha
        Returns: List<SIR_wrapperCabecera>
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US244035      Atmira         21/06/2021     	  Created    
    *****************************************************************/
	@AuraEnabled(cacheable=true)
	public static List<SIR_WrapperCabecera> wrapperCabecera(string recordId){
        String metodo = 'wrapperCabecera';
        List<SIR_WrapperCabecera> wrapper = new List<SIR_WrapperCabecera>();
        try{
            String clienteId = null;

            // Variables Convert 
            String saldoPositivo  =  null;
            String nomina         =  null;
            String pension        =  null;
            String paro           =  null;
            String deudaTotal     =  null;
            String deudaPendiente =  null;
            String deudaVencida   =  null;
            String ingresosTotal  =  null;
            
            if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
                SIREC__SIREC_obj_proceso__c[] procesoCliente =  [SELECT SIREC__SIREC_fld_cliente__c 
                                                            FROM SIREC__SIREC_obj_proceso__c 
                                                            WHERE Id =: recordId
                                                            LIMIT 1];

                if(procesoCliente.size() > 0 && procesoCliente[0].SIREC__SIREC_fld_cliente__c != null){ 
                    clienteId = procesoCliente[0].SIREC__SIREC_fld_cliente__c;
                }
            }
            /*
            if(clienteId != null){
                if(SIREC__SIREC_obj_informacionCliente__c.SObjectType.getDescribe().isAccessible()){
                    SIREC__SIREC_obj_informacionCliente__c[] infoCliente = [SELECT tolabel(SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c), tolabel(SIREC__SIREC_fld_segmentoSiREC__c) , SIREC__SIREC_fld_saldPasivo__c,SIREC__SIREC_fld_ingresosTotal__c,
                                                                        SIREC__SIREC_fld_ingresosNomina__c, SIREC__SIREC_fld_ingresosPension__c, SIREC__SIREC_fld_ingresosParo__c , SIREC__SIREC_fld_deudaTotal__c, SIREC__SIREC_fld_segmentoSiRECTexto__c,
                                                                        SIREC__SIREC_fld_deudaVencidaTotal__c , SIREC__SIREC_fld_deudaPendienteTotal__c , SIREC__SIREC_fld_diasImpago__c ,SIREC__SIREC_fld_ciclosImpago__c,
                                                                        SIREC__SIREC_fld_numCiclosImpago__c , SIREC__SIREC_fld_detaSolucion__c, SIREC__SIREC_fld_arquetipo__c , SIREC__SIREC_fld_capacidadDePago__c , SIREC__SIREC_fld_solucionMotor__c
                                                                        FROM SIREC__SIREC_obj_informacionCliente__c
                                                                        WHERE SIREC__SIREC_fld_cliente__c =:clienteId
                                                                        LIMIT 1];

                    if(infoCliente.size() > 0){
                                                                   
                        // Conversión a divisa 
                        
                        saldoPositivo  = valorConvert(infoCliente[0].SIREC__SIREC_fld_saldPasivo__c); 
                        nomina         = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosNomina__c);
                        pension        = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosPension__c);
                        paro           = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosParo__c);
                        deudaTotal     = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaTotal__c);                  
                        deudaPendiente = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaPendienteTotal__c);                  
                        deudaVencida   = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaVencidaTotal__c);                        
                        ingresosTotal   = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosTotal__c);
                        List<SIR_CatalogoSirec__c> lstCatalogo = new List<SIR_CatalogoSirec__c>();
                        if(SIR_CatalogoSirec__c.SObjectType.getDescribe().isAccessible()){
                            lstCatalogo = [SELECT SIR_Codigo__c, SIR_Descripcion__c FROM SIR_CatalogoSirec__c WHERE SIR_MasterRecordId__c = : SIR_Constantes.CATALOGO_PREFIJO_SEGMENTO + infoCliente[0].SIREC__SIREC_fld_segmentoSiRECTexto__c];
                        }
                        // Rellenar el Wrapper
                        SIR_WrapperCabecera wrapperCabecera = new SIR_WrapperCabecera();
                        wrapperCabecera.persona 					= infoCliente[0].SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c;
                        wrapperCabecera.segmento                    = lstCatalogo.isEmpty() ? '' : lstCatalogo.get(0).SIR_Descripcion__c;
                        wrapperCabecera.saldoPasivo                 = saldoPositivo;
                        wrapperCabecera.ingresosNomina              = nomina;
                        wrapperCabecera.ingresosPension             = pension;
                        wrapperCabecera.ingresosParo                = paro;
                        wrapperCabecera.deudaTotal 					= deudaTotal;
                        wrapperCabecera.deudaPendienteVencer		= deudaPendiente;
                        wrapperCabecera.deudaVencida			    = deudaVencida;
                        wrapperCabecera.diasImpagoPeor				= infoCliente[0].SIREC__SIREC_fld_diasImpago__c;
                        wrapperCabecera.numeroCliclos				= infoCliente[0].SIREC__SIREC_fld_numCiclosImpago__c;
                        wrapperCabecera.numeroCiclosTotal			= infoCliente[0].SIREC__SIREC_fld_ciclosImpago__c;
                        wrapperCabecera.prioridad					= infoCliente[0].SIREC__SIREC_fld_detaSolucion__c;
                        wrapperCabecera.arquetipo					= infoCliente[0].SIREC__SIREC_fld_arquetipo__c;
                        wrapperCabecera.capacidadDePago 			= infoCliente[0].SIREC__SIREC_fld_capacidadDePago__c;
                        wrapperCabecera.motorSolucion 			    = infoCliente[0].SIREC__SIREC_fld_solucionMotor__c;
                        wrapperCabecera.ingresosTotal 			    = ingresosTotal;
                        
                        wrapper.add(wrapperCabecera);
                    }
                }	
            }       */ 
            SIREC__SIREC_obj_informacionCliente__c[] infoCliente;
            if(clienteId != null && SIREC__SIREC_obj_informacionCliente__c.SObjectType.getDescribe().isAccessible()){
                    infoCliente = [SELECT tolabel(SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c), tolabel(SIREC__SIREC_fld_segmentoSiREC__c) , SIREC__SIREC_fld_saldPasivo__c,SIREC__SIREC_fld_ingresosTotal__c,
                                        SIREC__SIREC_fld_ingresosNomina__c, SIREC__SIREC_fld_ingresosPension__c, SIREC__SIREC_fld_ingresosParo__c , SIREC__SIREC_fld_deudaTotal__c, SIREC__SIREC_fld_segmentoSiRECTexto__c,
                                        SIREC__SIREC_fld_deudaVencidaTotal__c , SIREC__SIREC_fld_deudaPendienteTotal__c , SIREC__SIREC_fld_diasImpago__c ,SIREC__SIREC_fld_ciclosImpago__c,
                                        SIREC__SIREC_fld_numCiclosImpago__c , SIREC__SIREC_fld_detaSolucion__c, SIREC__SIREC_fld_arquetipo__c , SIREC__SIREC_fld_capacidadDePago__c , SIREC__SIREC_fld_solucionMotor__c
                                        FROM SIREC__SIREC_obj_informacionCliente__c
                                        WHERE SIREC__SIREC_fld_cliente__c =:clienteId
                                        LIMIT 1];
            }

            if(infoCliente.size() > 0){
                                                            
                // Conversión a divisa 
                
                saldoPositivo  = valorConvert(infoCliente[0].SIREC__SIREC_fld_saldPasivo__c); 
                nomina         = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosNomina__c);
                pension        = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosPension__c);
                paro           = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosParo__c);
                deudaTotal     = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaTotal__c);                  
                deudaPendiente = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaPendienteTotal__c);                  
                deudaVencida   = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaVencidaTotal__c);                        
                ingresosTotal   = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosTotal__c);
                List<SIR_CatalogoSirec__c> lstCatalogo = new List<SIR_CatalogoSirec__c>();
                if(SIR_CatalogoSirec__c.SObjectType.getDescribe().isAccessible()){
                    lstCatalogo = [SELECT SIR_Codigo__c, SIR_Descripcion__c FROM SIR_CatalogoSirec__c WHERE SIR_MasterRecordId__c = : SIR_Constantes.CATALOGO_PREFIJO_SEGMENTO + infoCliente[0].SIREC__SIREC_fld_segmentoSiRECTexto__c];
                }
                // Rellenar el Wrapper
                SIR_WrapperCabecera wrapperCabecera = new SIR_WrapperCabecera();
                wrapperCabecera.persona 					= infoCliente[0].SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c;
                wrapperCabecera.segmento                    = lstCatalogo.isEmpty() ? '' : lstCatalogo.get(0).SIR_Descripcion__c;
                wrapperCabecera.saldoPasivo                 = saldoPositivo;
                wrapperCabecera.ingresosNomina              = nomina;
                wrapperCabecera.ingresosPension             = pension;
                wrapperCabecera.ingresosParo                = paro;
                wrapperCabecera.deudaTotal 					= deudaTotal;
                wrapperCabecera.deudaPendienteVencer		= deudaPendiente;
                wrapperCabecera.deudaVencida			    = deudaVencida;
                wrapperCabecera.diasImpagoPeor				= infoCliente[0].SIREC__SIREC_fld_diasImpago__c;
                wrapperCabecera.numeroCliclos				= infoCliente[0].SIREC__SIREC_fld_numCiclosImpago__c;
                wrapperCabecera.numeroCiclosTotal			= infoCliente[0].SIREC__SIREC_fld_ciclosImpago__c;
                wrapperCabecera.prioridad					= infoCliente[0].SIREC__SIREC_fld_detaSolucion__c;
                wrapperCabecera.arquetipo					= infoCliente[0].SIREC__SIREC_fld_arquetipo__c;
                wrapperCabecera.capacidadDePago 			= infoCliente[0].SIREC__SIREC_fld_capacidadDePago__c;
                wrapperCabecera.motorSolucion 			    = infoCliente[0].SIREC__SIREC_fld_solucionMotor__c;
                wrapperCabecera.ingresosTotal 			    = ingresosTotal;
                
                wrapper.add(wrapperCabecera);
            }	
        }catch(exception e){
            CBK_log.error(e, 'Error : Sir_lwc_cabeceraCliente - ' + e.getTypeName() + ': ' + e.getMessage());
        }
        return wrapper;
    }

    /*****************************************************************
        Proposito:  Recuperar datos del objeto SIREC__SIREC_obj_informacionCliente__c que serán mostrados en la Ficha Cliente                                                       
        LWC asociado:  sir_lwc_cabeceraClienteTabs
        Parameters: recordId
        Returns: List<SIR_wrapperCabeceraT>
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         08/04/2022     	  Created    
    *****************************************************************/
    @AuraEnabled(cacheable=true)
	public static Map<String,List<SIR_WrapperCabecera>> wrapperCabeceraTabs(string recordId){
        String metodo = 'wrapperCabeceraTabs';

        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_FINALIZADO};
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        
        List<SIREC__SIREC_obj_informacionCliente__c> infoCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();
        //List<SIREC__SIREC_obj_proceso__c> infoProcesoLst = new List<SIREC__SIREC_obj_proceso__c>();	
        //List<SIREC__SIREC_obj_proceso__c> infoProcesoIMPA = new List<SIREC__SIREC_obj_proceso__c>();	
        List<SIREC__SIREC_obj_proceso__c> infoProcesoPRESOL = new List<SIREC__SIREC_obj_proceso__c>();	
        
        List<SIR_WrapperCabecera> wrapperIMPA = new List<SIR_WrapperCabecera>();
        List<SIR_WrapperCabecera> wrapperPRESOL = new List<SIR_WrapperCabecera>();
        Map<String,List<SIR_WrapperCabecera>> wrapperMap = new Map<String,List<SIR_WrapperCabecera>>();

        try{
            // Variables Convert 
            //impa
            String nomina         =  null;
            String pension        =  null;
            String paro           =  null;
            String saldoPositivo  =  null;
            String ingresosTotal  =  null;
            String deudaTotal     =  null;
            String deudaPendiente =  null;
            String deudaVencida   =  null;

            //PRESOL
            String saldoActivo  =    null;
            String saldoPasivo  =    null;
            String saldoDispuesto  = null;
            String deudaTotalPRESOL     =  null;
            String deudaPendientePRESOL =  null;
            String deudaVencidaPRESOL   =  null;
            String circulante = null;
            

            if(recordId != null){
                //Se busca el registro de Informacion Cliente vinculado al Cliente
                if(SIREC__SIREC_obj_informacionCliente__c.SObjectType.getDescribe().isAccessible()){
                    infoCliente = [SELECT tolabel(SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c), tolabel(SIREC__SIREC_fld_segmentoSiREC__c) , SIREC__SIREC_fld_saldPasivo__c,SIREC__SIREC_fld_ingresosTotal__c,
                                   SIREC__SIREC_fld_ingresosNomina__c, SIREC__SIREC_fld_ingresosPension__c, SIREC__SIREC_fld_ingresosParo__c , SIREC__SIREC_fld_deudaTotal__c, SIREC__SIREC_fld_segmentoSiRECTexto__c,
                                   SIREC__SIREC_fld_deudaVencidaTotal__c , SIREC__SIREC_fld_deudaPendienteTotal__c , SIREC__SIREC_fld_diasImpago__c ,SIREC__SIREC_fld_ciclosImpago__c,
                                   SIREC__SIREC_fld_numCiclosImpago__c , SIREC__SIREC_fld_detaSolucion__c, SIREC__SIREC_fld_arquetipo__c , SIREC__SIREC_fld_capacidadDePago__c , SIREC__SIREC_fld_solucionMotor__c 
                                   FROM SIREC__SIREC_obj_informacionCliente__c
                                   WHERE SIREC__SIREC_fld_cliente__c =:recordId
                                   LIMIT 1];
                }

                //Se buscan los registros de Procesos vinculados al Cliente
                if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
                    
                    /*infoProcesoIMPA = [SELECT tolabel(SIREC__SIREC_fld_estrategia__c), SIR_SegmentoPRESOL__c, SIR_PrioridadPRESOL__c, SIR_MotivoInclusion__c, tolabel(SIR_IndEnvio3m__c),
                                        SIR_ResGestion3m__c, SIR_RatingScoring__c, SIR_SaldoPasivoMedio__c, SIR_SaldoDispuesto__c, SIR_Circulante__c, SIR_DeudaTotal__c,
                                        SIR_DeudaPendienteDeVencer__c, SIR_DeudaVencidaImpagada__c, SIR_MaximoDiasImpago__c, SIR_FechaVtoCarenciaCBP__c, SIR_FechaVencimientoICO__c,
                                        SIR_FechaVtoCarencia__c, SIR_FechaVtoCCR__c, SIR_AvisoCentralizado__c, SIR_TenenciaICO__c, SIR_AlertaPRESOL__c, RecordTypeId, SIREC__SIREC_fld_situacion__c
                                        FROM SIREC__SIREC_obj_proceso__c
                                        WHERE SIREC__SIREC_fld_cliente__c =:recordId 
                                        AND RecordTypeId =: recordTypeIdAmistoso
                                        LIMIT 1];*/

                    infoProcesoPRESOL = [SELECT tolabel(SIREC__SIREC_fld_estrategia__c), SIR_SegmentoPRESOL__c, SIR_PrioridadPRESOL__c, SIR_MotivoInclusion__c, tolabel(SIR_IndEnvio3m__c),
                                        SIR_ResGestion3m__c, SIR_RatingScoring__c, SIR_SaldoPasivoMedio__c, SIR_SaldoDispuesto__c, SIR_Circulante__c, SIR_DeudaTotal__c,
                                        SIR_DeudaPendienteDeVencer__c, SIR_DeudaVencidaImpagada__c, SIR_MaximoDiasImpago__c, SIR_FechaVtoCarenciaCBP__c, SIR_FechaVencimientoICO__c,
                                        SIR_FechaVtoCarencia__c, SIR_FechaVtoCCR__c, SIR_AvisoCentralizado__c, SIR_TenenciaICO__c, SIR_AlertaPRESOL__c, RecordTypeId, SIREC__SIREC_fld_situacion__c, SIR_saldActivo__c
                                        FROM SIREC__SIREC_obj_proceso__c
                                        WHERE SIREC__SIREC_fld_cliente__c =:recordId 
                                        AND RecordTypeId =: recordTypeIdPRESOL
                                        AND SIREC__SIREC_fld_situacion__c !=: SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                                        LIMIT 1];
                }

                  
                //Proceso IMPA
                if(!infoCliente.isEmpty()){
                    //for(SIREC__SIREC_obj_proceso__c infoProceso : infoProcesoIMPA){
                        //if(infoProceso.RecordTypeId == recordTypeIdAmistoso){
                            // Conversión a divisa 
                            saldoPositivo  = valorConvert(infoCliente[0].SIREC__SIREC_fld_saldPasivo__c); 
                            nomina         = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosNomina__c);
                            pension        = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosPension__c);
                            paro           = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosParo__c);
                            deudaTotal     = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaTotal__c);                  
                            deudaPendiente = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaPendienteTotal__c);                  
                            deudaVencida   = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaVencidaTotal__c);                        
                            ingresosTotal  = valorConvert(infoCliente[0].SIREC__SIREC_fld_ingresosTotal__c);

                            List<SIR_CatalogoSirec__c> lstCatalogo = new List<SIR_CatalogoSirec__c>();
                            if(SIR_CatalogoSirec__c.SObjectType.getDescribe().isAccessible()){
                                lstCatalogo = [SELECT SIR_Codigo__c, SIR_Descripcion__c FROM SIR_CatalogoSirec__c WHERE SIR_MasterRecordId__c = : SIR_Constantes.CATALOGO_PREFIJO_SEGMENTO + infoCliente[0].SIREC__SIREC_fld_segmentoSiRECTexto__c];
                            }
                            //Creamos el Wrapper
                            SIR_WrapperCabecera wrapperCabecera = new SIR_WrapperCabecera();
                            // Rellenar el Wrapper
                            wrapperCabecera.persona 					= infoCliente[0].SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c;
                            wrapperCabecera.segmento                    = lstCatalogo.isEmpty() ? '' : lstCatalogo.get(0).SIR_Descripcion__c;
                            wrapperCabecera.saldoPasivo                 = saldoPositivo;
                            wrapperCabecera.ingresosNomina              = nomina;
                            wrapperCabecera.ingresosPension             = pension;
                            wrapperCabecera.ingresosParo                = paro;
                            wrapperCabecera.deudaTotal 					= deudaTotal;
                            wrapperCabecera.deudaPendienteVencer		= deudaPendiente;
                            wrapperCabecera.deudaVencida			    = deudaVencida;
                            wrapperCabecera.diasImpagoPeor				= infoCliente[0].SIREC__SIREC_fld_diasImpago__c;
                            wrapperCabecera.numeroCliclos				= infoCliente[0].SIREC__SIREC_fld_numCiclosImpago__c;
                            wrapperCabecera.numeroCiclosTotal			= infoCliente[0].SIREC__SIREC_fld_ciclosImpago__c;
                            wrapperCabecera.prioridad					= infoCliente[0].SIREC__SIREC_fld_detaSolucion__c;
                            wrapperCabecera.arquetipo					= infoCliente[0].SIREC__SIREC_fld_arquetipo__c;
                            wrapperCabecera.capacidadDePago 			= infoCliente[0].SIREC__SIREC_fld_capacidadDePago__c;
                            wrapperCabecera.motorSolucion 			    = infoCliente[0].SIREC__SIREC_fld_solucionMotor__c;
                            wrapperCabecera.ingresosTotal 			    = ingresosTotal;
                            wrapperIMPA.add(wrapperCabecera);

                            wrapperMap.put('IMPA',wrapperIMPA);
                        //}
                    //}
                }

                //Proceso PRESOL
                if(!infoProcesoPRESOL.isEmpty() && !infoCliente.isEmpty()){
                    for(SIREC__SIREC_obj_proceso__c infoProceso : infoProcesoPRESOL){

                        //Situacion Proceso no Finalizado
                        if(infoProceso.SIREC__SIREC_fld_situacion__c != SIR_Constantes.PROCESO_SITUACION_FINALIZADO){
                            // Conversión a divisa 
                            saldoActivo    = valorConvert(infoProceso.SIR_saldActivo__c); 
                            saldoPasivo    = valorConvert(infoProceso.SIR_SaldoPasivoMedio__c); 
                            saldoDispuesto = valorConvert(infoProceso.SIR_SaldoDispuesto__c); 
                            deudaTotalPRESOL     = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaTotal__c);                  
                            deudaPendientePRESOL = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaPendienteTotal__c);                 
                            deudaVencidaPRESOL   = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaVencidaTotal__c);
                            circulante =   valorConvert(infoProceso.SIR_Circulante__c);                      
                    
                            //Creamos el Wrapper
                            SIR_WrapperCabecera wrapperCabecera = new SIR_WrapperCabecera();
                            // Rellenar el Wrapper
                            wrapperCabecera.estrategiaPRESOL            = infoProceso.SIREC__SIREC_fld_estrategia__c;
                            wrapperCabecera.personaPRESOL 				= infoCliente[0].SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c;
                            wrapperCabecera.segmentoPRESOL              = infoProceso.SIR_SegmentoPRESOL__c;
                            wrapperCabecera.prioridadPRESOL             = infoProceso.SIR_PrioridadPRESOL__c;
                            wrapperCabecera.motivoInclusion             = infoProceso.SIR_MotivoInclusion__c;
                            wrapperCabecera.indEnvio                    = infoProceso.SIR_IndEnvio3m__c;
                            wrapperCabecera.resGestion                  = infoProceso.SIR_ResGestion3m__c;
                            if(infoProceso.SIR_RatingScoring__c != null){
                                wrapperCabecera.rating                  = infoProceso.SIR_RatingScoring__c.format();
                            } else {
                                wrapperCabecera.rating = '';
                            }
                            wrapperCabecera.saldoActivo                 = saldoActivo;
                            wrapperCabecera.saldoPasivoPRESOL           = saldoPasivo;
                            wrapperCabecera.saldoDispuestoPRESOL        = saldoDispuesto;
                            wrapperCabecera.circulante                  = circulante;
                            wrapperCabecera.deudaTotalPRESOL            = deudaTotalPRESOL;
                            wrapperCabecera.deudaPendienteVencerPRESOL  = deudaPendientePRESOL;
                            wrapperCabecera.deudaVencidaPRESOL          = deudaVencidaPRESOL;
                            wrapperCabecera.diasImpagoPeorPRESOL        = infoCliente[0].SIREC__SIREC_fld_diasImpago__c;
                            wrapperCabecera.numeroCiclosPRESOL          = infoCliente[0].SIREC__SIREC_fld_numCiclosImpago__c;
                            wrapperCabecera.numeroCiclosTotalPRESOL     = infoCliente[0].SIREC__SIREC_fld_ciclosImpago__c;
                            wrapperCabecera.vtoCBP                      = infoProceso.SIR_FechaVtoCarenciaCBP__c;
                            wrapperCabecera.vtoICO                      = infoProceso.SIR_FechaVencimientoICO__c;
                            wrapperCabecera.vtoCarencia                 = infoProceso.SIR_FechaVtoCarencia__c;
                            wrapperCabecera.vtoCCR                      = infoProceso.SIR_FechaVtoCCR__c;
                            wrapperCabecera.aviso                       = infoProceso.SIR_AvisoCentralizado__c;
                            wrapperCabecera.tenenciaICO                 = infoProceso.SIR_TenenciaICO__c;
                            wrapperCabecera.alertaPRESOL                = infoProceso.SIR_AlertaPRESOL__c;
                            wrapperPRESOL.add(wrapperCabecera);

                            wrapperMap.put('PRESOL',wrapperPRESOL);
                        }

                    }
                }        	
            }        
        }catch(exception e){
            CBK_log.error(e, 'Error : Clase Sir_lwc_cabeceraCliente - Método wrapperCabeceraTabs -- ' + e.getTypeName() + ': ' + e.getMessage());
        }	
        return wrapperMap;
    }

    /*****************************************************************
        Proposito:  Recuperar datos del objeto SIREC__SIREC_obj_informacionCliente__c que serán mostrados en la Ficha Proceso                                                       
        LWC asociado:  sir_lwc_cabeceraProcesoPRESOL
        Parameters: recordId
        Returns: List<SIR_wrapperCabecera>
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         11/04/2022     	  Created    
    *****************************************************************/
    @AuraEnabled(cacheable=true)
	public static List<SIR_WrapperCabecera> wrapperProcesoPRESOL(string recordId){
        String metodo = 'wrapperProcesoPRESOL';
        
        Set<String> setSituaciones = new Set<String>{SIR_Constantes.PROCESO_SITUACION_FINALIZADO};
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();
        
        List<SIREC__SIREC_obj_informacionCliente__c> infoCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();
        List<SIREC__SIREC_obj_proceso__c> infoProceso = new List<SIREC__SIREC_obj_proceso__c>();	
        List<SIR_WrapperCabecera> wrapper = new List<SIR_WrapperCabecera>();

        try{ 
            String clienteId = null;
            // Variables Convert
            String saldoActivo   =  null; 
            String saldoPasivo  =    null;
            String saldoDispuesto  = null;
            String deudaTotalPRESOL     =  null;
            String deudaPendientePRESOL =  null;
            String deudaVencidaPRESOL   =  null;
            String circulante = null;

            
            if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
                infoProceso = [SELECT SIREC__SIREC_fld_cliente__c, tolabel(SIREC__SIREC_fld_estrategia__c), SIR_SegmentoPRESOL__c, SIR_PrioridadPRESOL__c, SIR_MotivoInclusion__c, tolabel(SIR_IndEnvio3m__c),
                                   SIR_ResGestion3m__c, SIR_RatingScoring__c, SIR_SaldoPasivoMedio__c, SIR_SaldoDispuesto__c, SIR_Circulante__c, SIR_DeudaTotal__c,
                                   SIR_DeudaPendienteDeVencer__c, SIR_DeudaVencidaImpagada__c, SIR_MaximoDiasImpago__c, SIR_FechaVtoCarenciaCBP__c, SIR_FechaVencimientoICO__c,
                                   SIR_FechaVtoCarencia__c, SIR_FechaVtoCCR__c, SIR_AvisoCentralizado__c, SIR_TenenciaICO__c, SIR_AlertaPRESOL__c, SIR_saldActivo__c
                                   FROM SIREC__SIREC_obj_proceso__c
                                   WHERE Id =:recordId 
                                   AND RecordTypeId =: recordTypeIdPRESOL
                                   LIMIT 1];

                if(infoProceso.size() > 0 && infoProceso[0].SIREC__SIREC_fld_cliente__c != null){
                    clienteId = infoProceso[0].SIREC__SIREC_fld_cliente__c;
                }
            }
            
            if(clienteId != null){
                if(SIREC__SIREC_obj_informacionCliente__c.SObjectType.getDescribe().isAccessible()){
                    infoCliente = [SELECT tolabel(SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c), tolabel(SIREC__SIREC_fld_segmentoSiREC__c) , SIREC__SIREC_fld_saldPasivo__c,SIREC__SIREC_fld_ingresosTotal__c,
                                    SIREC__SIREC_fld_ingresosNomina__c, SIREC__SIREC_fld_ingresosPension__c, SIREC__SIREC_fld_ingresosParo__c , SIREC__SIREC_fld_deudaTotal__c, SIREC__SIREC_fld_segmentoSiRECTexto__c,
                                    SIREC__SIREC_fld_deudaVencidaTotal__c , SIREC__SIREC_fld_deudaPendienteTotal__c , SIREC__SIREC_fld_diasImpago__c ,SIREC__SIREC_fld_ciclosImpago__c,
                                    SIREC__SIREC_fld_numCiclosImpago__c , SIREC__SIREC_fld_detaSolucion__c, SIREC__SIREC_fld_arquetipo__c , SIREC__SIREC_fld_capacidadDePago__c , SIREC__SIREC_fld_solucionMotor__c 
                                   FROM SIREC__SIREC_obj_informacionCliente__c
                                   WHERE SIREC__SIREC_fld_cliente__c =:clienteId
                                   LIMIT 1];
                }
                
                if(infoCliente.size() > 0 && infoProceso.size() > 0){
                                                                 
                    // Conversión a divisa 
                    saldoActivo     = valorConvert(infoProceso[0].SIR_saldActivo__c); 
                    saldoPasivo    = valorConvert(infoProceso[0].SIR_SaldoPasivoMedio__c); 
                    saldoDispuesto = valorConvert(infoProceso[0].SIR_SaldoDispuesto__c); 
                    deudaTotalPRESOL     = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaTotal__c);                  
                    deudaPendientePRESOL = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaPendienteTotal__c);                  
                    deudaVencidaPRESOL   = valorConvert(infoCliente[0].SIREC__SIREC_fld_deudaVencidaTotal__c); 
                    circulante = valorConvert(infoProceso[0].SIR_Circulante__c); 
 
                    // Rellenar el Wrapper
                    SIR_WrapperCabecera wrapperCabecera = new SIR_WrapperCabecera();
                    wrapperCabecera.estrategiaPRESOL            = infoProceso[0].SIREC__SIREC_fld_estrategia__c;
                    wrapperCabecera.personaPRESOL 				= infoCliente[0].SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c;
                    wrapperCabecera.segmentoPRESOL              = infoProceso[0].SIR_SegmentoPRESOL__c;
                    wrapperCabecera.prioridadPRESOL             = infoProceso[0].SIR_PrioridadPRESOL__c;
                    wrapperCabecera.motivoInclusion             = infoProceso[0].SIR_MotivoInclusion__c;
                    wrapperCabecera.indEnvio                    = infoProceso[0].SIR_IndEnvio3m__c;
                    wrapperCabecera.resGestion                  = infoProceso[0].SIR_ResGestion3m__c;
                    if(infoProceso[0].SIR_RatingScoring__c != null){
                        wrapperCabecera.rating                  = infoProceso[0].SIR_RatingScoring__c.format();
                    } else {
                        wrapperCabecera.rating = '';
                    }    
                    wrapperCabecera.saldoActivo                 = saldoActivo;            
                    wrapperCabecera.saldoPasivoPRESOL           = saldoPasivo;
                    wrapperCabecera.saldoDispuestoPRESOL        = saldoDispuesto;
                    wrapperCabecera.circulante                  = circulante;
                    wrapperCabecera.deudaTotalPRESOL            = deudaTotalPRESOL;
                    wrapperCabecera.deudaPendienteVencerPRESOL  = deudaPendientePRESOL;
                    wrapperCabecera.deudaVencidaPRESOL          = deudaVencidaPRESOL;
                    wrapperCabecera.diasImpagoPeorPRESOL        = infoCliente[0].SIREC__SIREC_fld_diasImpago__c;
                    wrapperCabecera.numeroCiclosPRESOL          = infoCliente[0].SIREC__SIREC_fld_numCiclosImpago__c;
                    wrapperCabecera.numeroCiclosTotalPRESOL     = infoCliente[0].SIREC__SIREC_fld_ciclosImpago__c;
                    wrapperCabecera.vtoCBP                      = infoProceso[0].SIR_FechaVtoCarenciaCBP__c;
                    wrapperCabecera.vtoICO                      = infoProceso[0].SIR_FechaVencimientoICO__c;
                    wrapperCabecera.vtoCarencia                 = infoProceso[0].SIR_FechaVtoCarencia__c;
                    wrapperCabecera.vtoCCR                      = infoProceso[0].SIR_FechaVtoCCR__c;
                    wrapperCabecera.aviso                       = infoProceso[0].SIR_AvisoCentralizado__c;
                    wrapperCabecera.tenenciaICO                 = infoProceso[0].SIR_TenenciaICO__c;
                    wrapperCabecera.alertaPRESOL                = infoProceso[0].SIR_AlertaPRESOL__c;

                    wrapper.add(wrapperCabecera);
                }
            }	
        }        
        catch(exception e){
            CBK_log.error(e, 'Error : Clase Sir_lwc_cabeceraCliente - Método wrapperProcesoPRESOL -- ' + e.getTypeName() + ': ' + e.getMessage());
        }
        return wrapper;
    }

    /*****************************************************************
        Proposito:  Recuperar los Procesos abiertos y de que recordtype   
        LWC asociado:  sir_lwc_cabeceraClienteTabs                                                      
        Parameters: recordId
        Returns: String procesosPendientes
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         08/04/2022     	  Created    
    *****************************************************************/
    @AuraEnabled(cacheable=true)
	public static string procesosPendientes(string recordId){
        String resultado;
        Id recordTypeIdAmistoso = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
        Id recordTypeIdPRESOL = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId();
        List<SIREC__SIREC_obj_proceso__c> lstProcesoIMPA = new List<SIREC__SIREC_obj_proceso__c>();
        List<SIREC__SIREC_obj_proceso__c> lstProcesoPRESOL = new List<SIREC__SIREC_obj_proceso__c>();
        List<SIREC__SIREC_obj_proceso__c> lstProcesosActivos = new List<SIREC__SIREC_obj_proceso__c>();
        try{

            if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
                lstProcesosActivos = [SELECT Id, RecordTypeId
                                        FROM SIREC__SIREC_obj_proceso__c 
                                        WHERE SIREC__SIREC_fld_cliente__c =:recordId 
                                        AND SIREC__SIREC_fld_situacion__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO 
                                        ORDER BY createddate DESC];
            }

            if(!lstProcesosActivos.isEmpty()){
                for(SIREC__SIREC_obj_proceso__c proceso : lstProcesosActivos){
                    if(proceso.RecordTypeId == recordTypeIdAmistoso){
                        lstProcesoIMPA.add(proceso);
                    }else if(proceso.RecordTypeId == recordTypeIdPRESOL){
                        lstProcesoPRESOL.add(proceso);
                    }
                }
            }

            if(!lstProcesoIMPA.isEmpty()){
                resultado = 'IMPA';
            }else if(!lstProcesoPRESOL.isEmpty()){
                resultado = 'PRESOL';
            }else{
                resultado = 'IMPA';
            }

        }catch(exception e){
            CBK_log.error(e, 'Error : Clase Sir_lwc_cabeceraCliente - Método procesosPendientes -- ' + e.getTypeName() + ': ' + e.getMessage());
        }
        return resultado;
    }

    /*****************************************************************
        Proposito:  convertir datos                                                         
        Parameters: valor
        Returns: String
        Throws                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US244035      Atmira         21/06/2021     	  Created    
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static String valorConvert(decimal valor){
        
        String campo = null;
        SIR_Constantes constante = new SIR_Constantes();
        List<String> args = new String[]{constante.STRING_0,constante.STRING_NUMBER,constante.STRING_EXPRE_REGU};
        if(valor != null){
            campo =  String.format(valor.format(), args);
       
            if(!campo.contains(constante.STRING_COMA)){
                campo = campo + constante.STRING_COMILLA_00;
            }else{
                string campoSplit = campo.substringAfter(constante.STRING_COMA); 
                if(campoSplit.length() == 1 ){
                    campo = campo + constante.STRING_0;
                }
                
                campo = campo + constante.STRING_EURO;
            }  
        }else{
            campo = constante.STRING_0_COMA_00;
        }
            
        return campo;
    }
}