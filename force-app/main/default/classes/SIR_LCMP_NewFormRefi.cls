/*****************************************************************
 Name:  SIR_LCMP_NewFormRefi
 Copyright © 2021  CaixaBank

Proposito:   Clase controladora externa del LWC sir_lwc_newFormRefi                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244049         Atmira         21/06/2021     	  Created    

*****************************************************************/

public with sharing class SIR_LCMP_NewFormRefi {
    
    /*****************************************************************
        Proposito:  Realizamos query para encontrar todos los contratos con deuda                                                        
        Parameters: IdAccount
        Returns: List<Contract>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US244049         Atmira         21/06/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public Static List<SIREC__SIREC_obj_intervinientesContrato__c> queryContratosConDeuda (Id idAccount) {
        SIR_Constantes constante = new SIR_Constantes();
        List<SIREC__SIREC_obj_intervinientesContrato__c> contratosConDeuda = new List<SIREC__SIREC_obj_intervinientesContrato__c>(); 
        String titular = Label.SIR_TIT;
        String avalista = Label.SIR_AVA;
        if(Schema.SObjectType.Contract.isAccessible() && Schema.SObjectType.SIREC__SIREC_obj_intervinientesContrato__c.isAccessible() ){
            contratosConDeuda = [ SELECT SIREC__SIREC_fld_contract__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c, 
                                    tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c), tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c), 
                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__c,
                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c,
                                    SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c
                                    FROM SIREC__SIREC_obj_intervinientesContrato__c
                                    WHERE (SIREC__SIREC_fld_relacionContract__c = :titular OR SIREC__SIREC_fld_relacionContract__c = :avalista) AND SIR_estadoCarga__c != 'B' 
                                    AND SIREC__SIREC_fld_persona__c = :idAccount AND SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_indicadorDeuda__c = 'S'
                                    AND SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_fechaActualizacionSIREC__c >=  LAST_N_DAYS:2];                     
        }    
        return contratosConDeuda;
    }
    
    
    /*****************************************************************
        Proposito:  Realizamos query para encontrar todos los contratos sin deuda                                                        
        Parameters: IdAccount
        Returns: List<Contract>                                                                
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US244049         Atmira         21/06/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public Static List<SIREC__SIREC_obj_intervinientesContrato__c> queryContratosSinDeuda (Id idAccount) {
        SIR_Constantes constante = new SIR_Constantes();
        List<SIREC__SIREC_obj_intervinientesContrato__c> contratosSinDeuda = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
        String titular = Label.SIR_TIT;
        String avalista = Label.SIR_AVA;
        if(Schema.SObjectType.Contract.isAccessible() && Schema.SObjectType.SIREC__SIREC_obj_intervinientesContrato__c.isAccessible() ){
            contratosSinDeuda = [ SELECT SIREC__SIREC_fld_contract__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c, 
                                tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c), tolabel(SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c), 
                                SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__c,
                                SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c,
                                SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c
                                FROM SIREC__SIREC_obj_intervinientesContrato__c
                                WHERE (SIREC__SIREC_fld_relacionContract__c = :titular OR SIREC__SIREC_fld_relacionContract__c = :avalista) AND SIR_estadoCarga__c != 'B' 
                                AND SIREC__SIREC_fld_persona__c = :idAccount AND SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_indicadorDeuda__c = 'N'
                                AND SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_fechaActualizacionSIREC__c >=  LAST_N_DAYS:2]; 
        }
        return contratosSinDeuda;
    }
    
    /*****************************************************************
        Proposito:  Crear un registro del objeto SIREC_obj_proceso__c, crear n registros del objeto SIREC_obj_procesoContrato__c, 
					crear n registros del objeto SIREC_obj_personaAsociada__c y crear n registros del objeto Formulario_Refinanciaci_n__c                                                         
        Parameters: IdAccount, ListIdContracts
        Returns: String
        Throws [Exceptions]: Se controla las Exceptions devolviendo el mensaje al LWC para que se muestre por pantalla                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
		1.0            US244049         Atmira         21/06/2021	      Created    
    *****************************************************************/
    @AuraEnabled(Cacheable=false)
    public Static String crearRegistros (Id idAccount, String idContracts) {
        try{
            String titular = Label.SIR_TIT;
        	String avalista = Label.SIR_AVA;
            // Creamos un registro del objeto SIREC__SIREC_obj_proceso__c
            if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isCreateable() && Schema.SObjectType.SIREC__SIREC_obj_procesoContrato__c.isCreateable()
                && Schema.SObjectType.SIR_FormularioRefinanciacion__c.isCreateable() &&
                Schema.SObjectType.SIREC__SIREC_obj_personaAsociada__c.isCreateable() && Schema.SObjectType.SIR_IntervinienteFormulario__c.isCreateable()
            ){
                SIREC__SIREC_obj_proceso__c newProceso = new SIREC__SIREC_obj_proceso__c();
                Id procesoAmistosoRecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
                newProceso.name = SIR_Constantes.PROCESO_NAME_REFINANCIACION;
                newProceso.RecordTypeId = procesoAmistosoRecordTypeId;
                newProceso.SIREC__SIREC_fld_cliente__c = idAccount;
                newProceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_EN_CURSO_REFINANCIACION;
                newProceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_EN_CURSO_REFINANCIACION;
                newProceso.SIREC__SIREC_fld_fechaSituacion__c = Date.today();
                newProceso.SIREC__SIREC_fld_fechaInicio__c = Date.today();
                // Buscamos si el cliente tiene algun Proceso Activo
                // Los Procesos activos son los procesos con recordType=Amistoso, que el name no es 'Proceso de Refinanciación' 
                // y el campo ‘Situacion del proceso’ sea != Finalizado/Ilocalizado/Recobrado 
                List<SIREC__SIREC_obj_proceso__c> procesoActivo = new List<SIREC__SIREC_obj_proceso__c>();
             
                procesoActivo = [SELECT Id, SIREC__SIREC_fld_estrategia__c, SIREC__SIREC_fld_estrategiaCatalogo__c, SIREC__SIREC_fld_informacionCliente__c FROM SIREC__SIREC_obj_proceso__c 
                                WHERE SIREC__SIREC_fld_cliente__c = :idAccount 
                                AND Name != :SIR_Constantes.PROCESO_NAME_REFINANCIACION 
                                AND SIR_ObjetivoProceso__c != :SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                                AND ((RecordType.Name =: SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO AND SIR_fld_Situacion_SF__c != :SIR_Constantes.PROCESO_SITUACION_FINALIZADO) 
                                 OR(RecordType.Name =: SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL AND SIR_AccionActual__c = true))
                                ORDER BY RecordType.Name DESC LIMIT 1];
                if(!procesoActivo.isEmpty()){
                   newProceso.SIREC__SIREC_fld_estrategia__c = procesoActivo[0].SIREC__SIREC_fld_estrategia__c;
                    newProceso.SIREC__SIREC_fld_estrategiaCatalogo__c =  procesoActivo[0].SIREC__SIREC_fld_estrategiaCatalogo__c;
                    newProceso.SIREC__SIREC_fld_procesoSuperior__c = procesoActivo[0].Id;
                    newProceso.SIREC__SIREC_fld_informacionCliente__c = procesoActivo[0].SIREC__SIREC_fld_informacionCliente__c;
                }
                insert newProceso;                    
            
                // Creamos N registros del objeto SIREC__SIREC_obj_procesoContrato__c (tantos como contratos hay en IdContracts)            
                List<SIREC__SIREC_obj_procesoContrato__c> listNewProcesoContrato = new List<SIREC__SIREC_obj_procesoContrato__c>();
                List<Id> listIdContracts = idContracts.split(',');
                for(Id idContract: listIdContracts){
                    SIREC__SIREC_obj_procesoContrato__c newProcesoContrato = new SIREC__SIREC_obj_procesoContrato__c();
                    Id procesoContratoRecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_procesoContrato__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESOCONTRATO_RECORDTYPE_NAME_PROCESO_CONTRATOS).getRecordTypeId();
                    newProcesoContrato.RecordTypeId = procesoContratoRecordTypeId;
                    newProcesoContrato.SIREC__SIREC_fld_contract__c = idContract;
                    newProcesoContrato.SIREC__SIREC_fld_proceso__c = newProceso.Id;
                    newProcesoContrato.SIR_estadoCarga__c = 'A';
                    newProcesoContrato.SIR_fechaCarga__c = date.today();
                    listNewProcesoContrato.add(newProcesoContrato);
                } 
                insert listNewProcesoContrato;
            
                // Buscamos todos los Intervinientes (SIREC__SIREC_obj_intervinientesContrato__c) de los Contratos que ha seleccionado el usuario
                // Y que el campo SIREC__SIREC_fld_relacionContract__c = TIT (TITULAR) O AVA (AVALISTA)
                List<SIREC__SIREC_obj_intervinientesContrato__c> lInterContract = [SELECT SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_relacionContract__c, SIREC__SIREC_fld_ordenRelacion__c FROM SIREC__SIREC_obj_intervinientesContrato__c WHERE 
                                                                                    SIREC__SIREC_fld_contract__c in: listIdContracts
                                                                                    AND (SIREC__SIREC_fld_relacionContract__c = :titular OR SIREC__SIREC_fld_relacionContract__c = :avalista)
                                                                                    AND SIR_estadoCarga__c != 'B'];
                List<SIREC__SIREC_obj_intervinientesContrato__c> lIntervinientesContract = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
                Boolean dupli = false;
                for(SIREC__SIREC_obj_intervinientesContrato__c inter: lInterContract){
                    dupli = false;
                    for(SIREC__SIREC_obj_intervinientesContrato__c intervinientes: lIntervinientesContract){
                        if(inter.SIREC__SIREC_fld_persona__c != null && intervinientes.SIREC__SIREC_fld_persona__c == inter.SIREC__SIREC_fld_persona__c ){
                            dupli = true;                        
                        }                    
                    }
                    if(dupli == false){
                        lIntervinientesContract.add(inter);
                    }                
                }
                List<SIREC__SIREC_obj_personaAsociada__c> listNewPersonaAsociada = new List<SIREC__SIREC_obj_personaAsociada__c>();                
                List<SIR_IntervinienteFormulario__c> listNewIntervinienteForm = new List<SIR_IntervinienteFormulario__c>();
                Set<id> idCliente = new set<id>();
                Id personaAsociadaRecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_personaAsociada__c.getRecordTypeInfosByName().get(SIR_Constantes.PERSONAASOCIADA_RECORDTYPE_NAME_PERSONA_ASOCIADA).getRecordTypeId();
                Id infoRecordTypeId = Schema.SObjectType.SIR_IntervinienteFormulario__c.getRecordTypeInfosByName().get(SIR_Constantes.INTERVINIENTEFORMULARIO_RECORDTYPE_NAME_INFORMACION).getRecordTypeId();
                Integer numTitulares = 0;
                Integer numAvalistas = 0;
                if(!lIntervinientesContract.isEmpty()){
                    // Creamos tantos registros de Persona Asociada como intevinientes ha recogido la query                
                    for(SIREC__SIREC_obj_intervinientesContrato__c intervinientes: lIntervinientesContract){
                        SIREC__SIREC_obj_personaAsociada__c newPersonaAsociada = new SIREC__SIREC_obj_personaAsociada__c();                   
                        newPersonaAsociada.RecordTypeId = personaAsociadaRecordTypeId;
                        newPersonaAsociada.SIREC__SIREC_fld_proceso__c = newProceso.Id;
                        newPersonaAsociada.SIREC__SIREC_fld_persona__c = intervinientes.SIREC__SIREC_fld_persona__c;
                        newPersonaAsociada.SIR_estadoCarga__c = 'A';
                    	newPersonaAsociada.SIR_fechaCarga__c = date.today();
                        listNewPersonaAsociada.add(newPersonaAsociada);
                        
                        if(intervinientes.SIREC__SIREC_fld_relacionContract__c == avalista){
                            numAvalistas = numAvalistas + 1;                        
                        } else if(intervinientes.SIREC__SIREC_fld_relacionContract__c == titular){
                            numTitulares = numTitulares + 1; 
                        }
                        
                        // Creamos tantos SIR_IntervinienteFormulario__c como SIREC__SIREC_obj_personaAsociada__c
                        SIR_IntervinienteFormulario__c newIntervinienteForm = new SIR_IntervinienteFormulario__c();                    
                        newIntervinienteForm.RecordTypeId = infoRecordTypeId;
                        newIntervinienteForm.SIR_Cliente__c = intervinientes.SIREC__SIREC_fld_persona__c;
                        String relacion;
                        String titularLabel = Label.SIR_Titular;
                        String avalistaLabel = Label.SIR_Avalista;
                        if(intervinientes.SIREC__SIREC_fld_relacionContract__c == titular){
                            relacion = titularLabel;
                        }
                        if(intervinientes.SIREC__SIREC_fld_relacionContract__c == avalista){
                            relacion = avalistaLabel;
                        }
                        newIntervinienteForm.SIR_Relacion__c = relacion;
                        listNewIntervinienteForm.add(newIntervinienteForm);
                        
                        idCliente.add(intervinientes.SIREC__SIREC_fld_persona__c);
                    }
                    insert listNewPersonaAsociada;  
                }
            
                // Calculamos la deuda total de los contratos con deuda seleccionados
                /* P2253-569 - Modificacion HSC 25/10/2022 - Se deben tener en cuenta TODOS los contratos del cliente (con y sin impago) y no solo los seleccionados en el proceso de Refi*/
                List<Contract> contratosDeudaSeleccionados = [SELECT id, SIREC__SIREC_fld_deudaTotalContrato__c , SIREC__SIREC_fld_importeImpagado__c, SIREC__SIREC_fld_tipoGarantia__c, 
                                                                SIREC__SIREC_fld_tipoContrato__c, SIREC__SIREC_fld_formulaEntidad__c
                                                                FROM Contract 
                                                                WHERE id IN :ListIdContracts];
                
                
                List<SIREC__SIREC_obj_intervinientesContrato__c> conIntDeudaSeleccionados = [SELECT id, SIREC__SIREC_fld_contract__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c,  
                                                                                            SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoGarantia__c, 
                                                                                            SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_formulaEntidad__c,
                                                                                            SIREC__SIREC_fld_relacionContract__c, SIR_estadoCarga__c
                                                                                            FROM SIREC__SIREC_obj_intervinientesContrato__c
                                                                                            WHERE SIREC__SIREC_fld_persona__c =: idAccount 
                                                                                            AND SIREC__SIREC_fld_relacionContract__c =: titular
                                                                                            AND SIR_estadoCarga__c !='B'
                                                                                            AND SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_fechaActualizacionSIREC__c >=  LAST_N_DAYS:2];

                SIR_Constantes constantes = new SIR_Constantes();
                Decimal deudaTotal             = 0;
                Decimal deudaGarantiaReal      = 0; // SIR_deudaTotalGarantiaReal__c
                Decimal cuotaGarantiaReal      = 0; // SIR_cuotaGarantiaReal__c
                Decimal deudaGarantiaPersonal  = 0; // SIR_deudaTotalGarantiaPersonal__c
                Decimal cuotaGarantiaPersonal  = 0; // SIR_CuotaGarantiaPersonal__c
                Decimal deudaTarjeta           = 0; // SIR_deudaTotalTarjeta__c
                Decimal cuotaTarjeta           = 0; // SIR_CuotaMensualTarjetas__c
                Decimal deudaEmpresa           = 0; // SIR_deudaTotalEmpresasGrupo__c
                Decimal cuotaEmpresa           = 0; // SIR_CuotaMensualEmpresasGrupo__c
                Decimal deudaOtros             = 0; // SIR_deudaTotalOtros__c
                Decimal cuotaOtros             = 0; // SIR_CuotaMensualOtros__c

                /* P2253-569 - INICIO Modificacion HSC 25/10/2022 - Se deben tener en cuenta TODOS los contratos del cliente (con y sin impago) y no solo los seleccionados en el proceso de Refi*/
                Decimal cuotaCaixa                  = 0; // SIREC__SIREC_fld_importeImpagado__c
    
                if(!conIntDeudaSeleccionados.isEmpty() && !contratosDeudaSeleccionados.isEmpty() ){ 
                    for(Contract contract : contratosDeudaSeleccionados){
                        
                        Decimal sirecDeudaTotalCont = 0;
                        Decimal sirecCuotaTotalCont = 0;

                        if(contract.SIREC__SIREC_fld_deudaTotalContrato__c != null) {
                        	sirecDeudaTotalCont = contract.SIREC__SIREC_fld_deudaTotalContrato__c;
                        }
                        deudaTotal = deudaTotal + sirecDeudaTotalCont;

                        if(contract.SIREC__SIREC_fld_importeImpagado__c != null) {
                        	sirecCuotaTotalCont = contract.SIREC__SIREC_fld_importeImpagado__c;
                        }
                        cuotaCaixa = cuotaCaixa + sirecCuotaTotalCont;
                    }  

                    for(SIREC__SIREC_obj_intervinientesContrato__c con: conIntDeudaSeleccionados){
                        // comprobar Garantia Real
                        Boolean checkGarantiaReal           = constantes.garantiaReal.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoGarantia__c);  
                        // comprobamos mismos productos para Real Y Personal
                        Boolean checkProductos              = constantes.tipoProductos.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c);
                        // comprobamos productos Tarjetas
                        Boolean checkProductosTarjetas      = constantes.tipoProductosTarjeas.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c);
                        // Comprobamos Todos Tipos Productos
                        Boolean checkAllProductos           = constantes.todosTipoProductos.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c);

                        Decimal sirecDeudaTotalContrato = 0;
                        Decimal sirecImporteImpagado = 0;
                        
                        if(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c != null) {
                        	sirecDeudaTotalContrato = con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c;
                        }
                        
                        if(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c != null) {
                        	sirecImporteImpagado = con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c;
                        }
                        
                        // Añadimos la deuda total y importe cuota de garantia real de los contratos que cumplen las condiciones
                        // P2253-1107 24/01/23 Se cambia las condiciones
                        // if( checkGarantiaReal && checkProductos && con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_formulaEntidad__c == constantes.STRING_00001){
                        if( checkGarantiaReal && checkProductos ){
                            deudaGarantiaReal = deudaGarantiaReal + sirecDeudaTotalContrato;
                            cuotaGarantiaReal = cuotaGarantiaReal + sirecImporteImpagado ;  
                        }
                        // Añadimos la deuda total y importe cuota de garantia Personal
                        // P2253-1107 24/01/23 Se cambia las condiciones
                        // if( con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoGarantia__c == constantes.STRING_1 && checkProductos && con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_formulaEntidad__c == constantes.STRING_00001){
                        if( con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoGarantia__c == constantes.STRING_1 && checkProductos ){
                            deudaGarantiaPersonal = deudaGarantiaPersonal + sirecDeudaTotalContrato;
                            cuotaGarantiaPersonal = cuotaGarantiaPersonal + sirecImporteImpagado ;
                        }
                        // Añadidos la deuda total y importe cuota de las tarjetas
                        if(checkProductosTarjetas && con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_formulaEntidad__c == constantes.STRING_00001){
                            deudaTarjeta = deudaTarjeta + sirecDeudaTotalContrato;
                            cuotaTarjeta = cuotaTarjeta + sirecImporteImpagado ;
                        }// Añadimos la deuda total y importe cuota Empresas Grupo
                        else if(checkProductosTarjetas && con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_formulaEntidad__c != constantes.STRING_00001 ){
                            deudaEmpresa = deudaEmpresa + sirecDeudaTotalContrato;
                            cuotaEmpresa = cuotaEmpresa + sirecImporteImpagado ;
                        }
                        // Añadimos la deuda Total y importe cuota de otros
                        // P2253-1107 24/01/23 Se cambia las condiciones
                        // if(!checkAllProductos && con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_formulaEntidad__c != constantes.STRING_00001 ){
                        if(!checkAllProductos ){
                            deudaOtros = deudaOtros + sirecDeudaTotalContrato;
                            cuotaOtros = cuotaOtros + sirecImporteImpagado ;
                        }
                    }
                }
                
                 /* P2253-569 - FIN Modificacion HSC 25/10/2022 - Se deben tener en cuenta TODOS los contratos del cliente (con y sin impago) y no solo los seleccionados en el proceso de Refi*/

                // Creamos un registro del objeto SIR_FormularioRefinanciacion__c               
                SIR_FormularioRefinanciacion__c newFormulario = new SIR_FormularioRefinanciacion__c();
                Id formRefiRecordTypeId = Schema.SObjectType.SIR_FormularioRefinanciacion__c.getRecordTypeInfosByName().get(SIR_Constantes.FORMULARIOREFINANCIACION_RECORDTYPE_NAME_FORMULARIO_REFINANCIACION).getRecordTypeId();
                newFormulario.RecordTypeId = formRefiRecordTypeId;          
                newFormulario.SIR_Proceso__c = newProceso.Id;
                List<SIR_FormularioRefinanciacion__c> numeroFormRefi = [SELECT id, SIR_NumFormRefi__c FROM SIR_FormularioRefinanciacion__c WHERE SIR_NumFormRefi__c != null ORDER BY SIR_NumFormRefi__c desc];
                if(!numeroFormRefi.isEmpty()){
                    newFormulario.Name = numeroFormRefi[0].SIR_NumFormRefi__c + ' - ' + SIR_Constantes.FORMULARIOREFINANCIACION_CHECK_LIST_REFINANCIACION;
                } else {
                    newFormulario.Name = '0001 - ' + SIR_Constantes.FORMULARIOREFINANCIACION_CHECK_LIST_REFINANCIACION;
                }    
                newFormulario.SIR_Estado__c                     = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_EN_CURSO;
                newFormulario.SIR_persona__c                    = idAccount;            
                newFormulario.SIR_deudaTotal__c                 = deudaTotal;
                newFormulario.SIR_NumTitulares__c               = numTitulares;            
                newFormulario.SIR_NumAvalistas__c               = numAvalistas;
                // Cargas Financieras
                newFormulario.SIR_deudaTotalGarantiaReal__c     = deudaGarantiaReal;
                newFormulario.SIR_cuotaGarantiaReal__c          = cuotaGarantiaReal;
                newFormulario.SIR_deudaTotalGarantiaPersonal__c = deudaGarantiaPersonal;
                newFormulario.SIR_CuotaGarantiaPersonal__c      = cuotaGarantiaPersonal;
                newFormulario.SIR_deudaTotalTarjeta__c          = deudaTarjeta;
                newFormulario.SIR_CuotaMensualTarjetas__c       = cuotaTarjeta;
                newFormulario.SIR_deudaTotalEmpresasGrupo__c    = deudaEmpresa;
                newFormulario.SIR_CuotaMensualEmpresasGrupo__c  = cuotaEmpresa;
                newFormulario.SIR_deudaTotalOtros__c            = deudaOtros;
                newFormulario.SIR_CuotaMensualOtros__c          = cuotaOtros;
                newFormulario.SIR_TotalDeudaCaixabank__c        = deudaGarantiaReal + deudaGarantiaPersonal + deudaEmpresa + deudaTarjeta + deudaOtros;
                newFormulario.SIR_TotalCuotaCaixabank__c        = cuotaGarantiaReal + cuotaGarantiaPersonal + cuotaEmpresa + cuotaTarjeta + cuotaOtros;
                
                
                
                /* P2253-569 - INICIO Modificacion HSC 25/10/2022 - Se deben tener en cuenta TODOS los contratos del cliente (con y sin impago) y no solo los seleccionados en el proceso de Refi*/
                //newFormulario.SIR_DeudaOperacionRefCaixa__c     = deudaTotal;
                // estos dos campos estan pendientes de confirmar
                //newFormulario.SIR_prestamoDeudaCaixa__c         = deudaGarantiaReal + deudaGarantiaPersonal + deudaEmpresa + deudaTarjeta + deudaOtros;
                newFormulario.SIR_prestamoDeudaCaixa__c         = deudaTotal;
                //newFormulario.SIR_prestamoCuotaCaixa__c         = cuotaGarantiaReal + cuotaGarantiaPersonal + cuotaEmpresa + cuotaTarjeta + cuotaOtros;
                newFormulario.SIR_prestamoCuotaCaixa__c         = cuotaCaixa;
                /* P2253-569 - FIN Modificacion HSC 25/10/2022 - Se deben tener en cuenta TODOS los contratos del cliente (con y sin impago) y no solo los seleccionados en el proceso de Refi*/
                newFormulario.SIR_TotalCuotaRefCaixa__c         = newFormulario.SIR_TotalCuotaCaixabank__c - newFormulario.SIR_prestamoCuotaCaixa__c + 0;
                insert newFormulario;                 
                
                decimal totalIngresosTrabajo = 0;
                // Modificamos la lista de listNewIntervinienteForm para ponerle el ID del Formulario y para rellenar campos de SIREC__SIREC_obj_informacionCliente__c
                if(!listNewIntervinienteForm.isEmpty()){  
                    List<SIREC__SIREC_obj_informacionCliente__c> infoCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();
                    List<SIREC__SIREC_obj_Catalogo__c > catalogos = new List<SIREC__SIREC_obj_Catalogo__c >();
                    if(Schema.SObjectType.SIREC__SIREC_obj_informacionCliente__c.isAccessible() && Schema.SObjectType.SIREC__SIREC_obj_Catalogo__c .isAccessible()){          
                        infoCliente = [SELECT id, SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c, SIREC__SIREC_fld_cliente__c, 
                                        SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c, SIREC__SIREC_fld_ingresosTotal__c
                                        FROM SIREC__SIREC_obj_informacionCliente__c WHERE SIREC__SIREC_fld_cliente__c=: idCliente];                       
                        
                    }
                    if(!infoCliente.isEmpty()){
                        Map<Id, SIREC__SIREC_obj_informacionCliente__c> mapInfoCliente = new Map<Id, SIREC__SIREC_obj_informacionCliente__c>();
                        for(SIREC__SIREC_obj_informacionCliente__c info: infoCliente){
                            mapInfoCliente.put(info.SIREC__SIREC_fld_cliente__c, info);
                        }
                        for(SIR_IntervinienteFormulario__c intervinienteForm: listNewIntervinienteForm){                 
                            if(mapInfoCliente.containsKey(intervinienteForm.SIR_Cliente__c)){
                                intervinienteForm.SIR_Profesion__c = mapInfoCliente.get(intervinienteForm.SIR_Cliente__c).SIREC__SIREC_fld_CNAECatalogo__r.SIREC__SIREC_fld_Descripcion__c;
                                intervinienteForm.SIR_IngresosTrabajo__c = mapInfoCliente.get(intervinienteForm.SIR_Cliente__c).SIREC__SIREC_fld_ingresosTotal__c;
                                if(intervinienteForm.SIR_IngresosTrabajo__c == null){
                                    intervinienteForm.SIR_IngresosTrabajo__c = 0;
                                }
                                totalIngresosTrabajo = totalIngresosTrabajo + intervinienteForm.SIR_IngresosTrabajo__c;               
                            }  
                            intervinienteForm.SIR_FormularioRefinanciacion__c = newFormulario.Id;
                        } 
                        insert listNewIntervinienteForm;
                    }
                }
                // añadimos la suma de Ingresos totales del trabajo al crear el formulario
                newFormulario.SIR_TotalIngresosTrabajo__c = totalIngresosTrabajo;
                if(Schema.SObjectType.SIR_FormularioRefinanciacion__c.isUpdateable()){
                    update(newFormulario);
                }
                // Devolvemos el id del formulario que hemos creado, para luego navegar a ese registro
                return newFormulario.Id; 
            }     
            return null;
            
        } catch (Exception e) {
            CBK_log.error(e, 'Error : sir_lwc_newFormRefi - ' + e.getTypeName() + ': ' + e.getMessage());
            return String.valueOf(e);
        }
    }

    @AuraEnabled(Cacheable=false)
    public Static Boolean isEnabledNuevoProceso(Id idAccount){  
        List<SIREC__SIREC_obj_proceso__c> listaProceso = [SELECT Id FROM SIREC__SIREC_obj_proceso__c 
                                                          WHERE SIREC__SIREC_fld_cliente__c = :idAccount 
                                                          AND Name != :SIR_Constantes.PROCESO_NAME_REFINANCIACION 
                                                          AND SIR_ObjetivoProceso__c != :SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
														  AND ((RecordType.Name =: SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO AND SIR_fld_Situacion_SF__c != :SIR_Constantes.PROCESO_SITUACION_FINALIZADO) 
                                                           OR(RecordType.Name =: SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL AND SIR_AccionActual__c = true))];
        return !listaProceso.isEmpty();
    }
}