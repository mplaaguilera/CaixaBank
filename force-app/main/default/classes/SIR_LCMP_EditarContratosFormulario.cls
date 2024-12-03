/*****************************************************************
 Name:  SIR_LCMP_EditarContratosFormulario
 Copyright © 2021  CaixaBank

Proposito:   Clase controladora externa del LWC Sir_lwc_EditarContratosFormulario                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US484767         Atmira         28/11/2022     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_EditarContratosFormulario {

    /*****************************************************************
        Proposito:  Realizamos query para el Account del Formulario                                                        
        Parameters: idFormulario
        Returns: String                                                               
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US484767         Atmira         28/11/2022     	  Created  
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String queryContratos (Id idFormulario) {        
        String idAccountMasIdProceso = '';
        if(SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isAccessible()){         
            List<SIR_FormularioRefinanciacion__c> formulario = [ SELECT id, SIR_Persona__c, SIR_Proceso__c  FROM SIR_FormularioRefinanciacion__c 
                                                                 WHERE Id =: idFormulario LIMIT 1];  
            if(!formulario.isEmpty()){
                idAccountMasIdProceso = formulario[0].SIR_Persona__c + '*' + formulario[0].SIR_Proceso__c; 
            }                                                                                     
        }    
        return idAccountMasIdProceso;
    }

    /*****************************************************************
        Proposito:  Realizamos query para encontrar todos los contratos que ya estan relacionados con el proceso                                                       
        Parameters: idProceso
        Returns: List<SIREC__SIREC_obj_procesoContrato__c>                                                               
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US484767         Atmira         28/11/2022     	  Created  
    *****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_procesoContrato__c> queryContratatosFormulario (Id idProceso) {
        List<SIREC__SIREC_obj_procesoContrato__c> procesoContrato = new List<SIREC__SIREC_obj_procesoContrato__c>();        
        if(SIREC__SIREC_obj_procesoContrato__c.SObjectType.getDescribe().isAccessible()){         
            procesoContrato = [SELECT SIREC__SIREC_fld_contract__c FROM SIREC__SIREC_obj_procesoContrato__c WHERE SIREC__SIREC_fld_proceso__c =: idProceso AND SIR_estadoCarga__c != 'B'];                                                                                              
        }  
        return procesoContrato;
    }

    /*****************************************************************
        Proposito:  Realizamos query para el Account del Formulario                                                        
        Parameters: Id idFormulario, Id idProceso, Id idAccount, String contractsAntiguos, String contractsNuevos
        Returns: String                                                               
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US484767         Atmira         28/11/2022     	  Created  
    *****************************************************************/
    @AuraEnabled
    public static String apexCrearBorrarRegistros (Id idFormulario, Id idProceso, Id idAccount, String contractsAntiguos, String contractsNuevos) {        
        String resultado = '';
        String titular = Label.SIR_TIT;
        String avalista = Label.SIR_AVA;  
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible() && SIREC__SIREC_obj_procesoContrato__c.SObjectType.getDescribe().isCreateable()
            && SIR_FormularioRefinanciacion__c.SObjectType.getDescribe().isUpdateable() && SIREC__SIREC_obj_personaAsociada__c.SObjectType.getDescribe().isCreateable() 
            && SIR_IntervinienteFormulario__c.SObjectType.getDescribe().isCreateable() && SIREC__SIREC_obj_informacionCliente__c.SObjectType.getDescribe().isAccessible() 
            && SIR_CatalogoSirec__c.SObjectType.getDescribe().isAccessible() && SIR_IntervinienteFormulario__c.SObjectType.getDescribe().isUpdateable()
            && SIREC__SIREC_obj_personaAsociada__c.SObjectType.getDescribe().isUpdateable() && SIREC__SIREC_obj_procesoContrato__c.SObjectType.getDescribe().isUpdateable()
            && Contract.SObjectType.getDescribe().isAccessible() && SIREC__SIREC_obj_intervinientesContrato__c.SObjectType.getDescribe().isAccessible()){
            try {  
                List<Id> idContractsAntiguos = contractsAntiguos.split(',');
                List<Id> idContractsNuevos = contractsNuevos.split(',');                 
                Set<Id> setIdContratosAntiguosTemporal = new Set<Id>();
                Set<Id> setIdContratosNuevos = new Set<Id>();
                Set<Id> setIdContratosAntiguos = new Set<Id>();
                Set<Id> setIdContratosBorrar = new Set<Id>();
                Set<Id> todosLosContratos = new Set<Id>();
                for(String contratosAntiguos: idContractsAntiguos){  
                    setIdContratosAntiguosTemporal.add(contratosAntiguos);
                    todosLosContratos.add(contratosAntiguos);
                }
                for(String contratosNuevos: idContractsNuevos){                 
                    // Si el contrato nuevo no existia antes lo ponemos en la variable (set) de nuevos              
                    if(!setIdContratosAntiguosTemporal.contains(contratosNuevos)){
                        setIdContratosNuevos.add(contratosNuevos); 
                        todosLosContratos.add(contratosNuevos);                               
                    } else {
                        // Si el contrato nuevo existia se pone en la variable de Antiguos
                        setIdContratosAntiguos.add(contratosNuevos); 
                        // Se borra de la variable temporal
                        setIdContratosAntiguosTemporal.remove(contratosNuevos);                    
                    }           
                }
                // En la variable temporal se han quedado todos los contratos que hay que borrar porque el usuario no los ha seleccionado
                setIdContratosBorrar = setIdContratosAntiguosTemporal;   
                // Creamos N registros del objeto SIREC__SIREC_obj_procesoContrato__c (tantos como contratos hay en la variable setIdContratosNuevos)            
                List<SIREC__SIREC_obj_procesoContrato__c> listNewProcesoContrato = new List<SIREC__SIREC_obj_procesoContrato__c>();
                for(Id idContractNuevos: setIdContratosNuevos){
                    SIREC__SIREC_obj_procesoContrato__c newProcesoContrato = new SIREC__SIREC_obj_procesoContrato__c();
                    Id procesoContratoRecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_procesoContrato__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESOCONTRATO_RECORDTYPE_NAME_PROCESO_CONTRATOS).getRecordTypeId();
                    newProcesoContrato.RecordTypeId = procesoContratoRecordTypeId;
                    newProcesoContrato.SIREC__SIREC_fld_contract__c = idContractNuevos;
                    newProcesoContrato.SIREC__SIREC_fld_proceso__c = idProceso;
                    newProcesoContrato.SIR_estadoCarga__c = 'A';
                    newProcesoContrato.SIR_fechaCarga__c = date.today();
                    listNewProcesoContrato.add(newProcesoContrato);
                }  
                insert listNewProcesoContrato;

                // Ponemos una marca BAJA (B) los ProcesosContratos de la lista de setIdContratosBorrar
                if(!setIdContratosBorrar.isEmpty()){
                    List<SIREC__SIREC_obj_procesoContrato__c> lProcesosContratosBorrar = [SELECT Id, SIR_estadoCarga__c FROM SIREC__SIREC_obj_procesoContrato__c WHERE 
                                                                                          SIREC__SIREC_fld_proceso__c =: idProceso AND SIREC__SIREC_fld_contract__c IN :setIdContratosBorrar];
                    for(SIREC__SIREC_obj_procesoContrato__c proConBorrar: lProcesosContratosBorrar){
                        proConBorrar.SIR_estadoCarga__c = 'B';
                    }
                    update lProcesosContratosBorrar;
                }            
                
                // Buscamos todos los Intervinientes (SIREC__SIREC_obj_intervinientesContrato__c) de los Contratos que ha seleccionado el usuario
                // Y que el campo SIREC__SIREC_fld_relacionContract__c = TIT (TITULAR) O AVA (AVALISTA)    
                List<SIREC__SIREC_obj_intervinientesContrato__c> lInterContract = [SELECT Id, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_relacionContract__c, SIREC__SIREC_fld_ordenRelacion__c,
                                                                                    SIREC__SIREC_fld_contract__c 
                                                                                    FROM SIREC__SIREC_obj_intervinientesContrato__c 
                                                                                    WHERE SIREC__SIREC_fld_contract__c in : todosLosContratos AND SIR_estadoCarga__c != 'B'
                                                                                    AND (SIREC__SIREC_fld_relacionContract__c = :titular OR SIREC__SIREC_fld_relacionContract__c = :avalista)];           
                List<SIREC__SIREC_obj_intervinientesContrato__c> interMantener = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
                List<SIREC__SIREC_obj_intervinientesContrato__c> interNuevos = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
                List<SIREC__SIREC_obj_intervinientesContrato__c> interBorrar = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
                List<SIREC__SIREC_obj_intervinientesContrato__c> lIntervinientesContractSeleccionados = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
                Set<Id> interPersonaMantener = new Set<Id>();
                Set<Id> interPersonaNueva = new Set<Id>();
                Set<Id> interPersonaBorrar = new Set<Id>();                
                List<SIREC__SIREC_obj_intervinientesContrato__c> interSinMantener = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
                // Recorremos la query y miramos que intervinientes se han de mantener
                for(SIREC__SIREC_obj_intervinientesContrato__c inter: lInterContract){
                    // Si el interviniente tiene un contrato que se mantiene lo ponemos en la variable de mantener y lo ponemos en un set de id's de Personas Mantener
                    if(setIdContratosAntiguos.contains(inter.SIREC__SIREC_fld_contract__c)){
                        interMantener.add(inter);
                        interPersonaMantener.add(inter.SIREC__SIREC_fld_persona__c);
                        lIntervinientesContractSeleccionados.add(inter);
                    } else {
                        //Ponemos en una variable todos los intervinientes menos los que hay que mantener
                        interSinMantener.add(inter);
                    }
                }
                List<SIREC__SIREC_obj_intervinientesContrato__c> interSinMantenerSinNuevos = new List<SIREC__SIREC_obj_intervinientesContrato__c>();
                // Recorremos la variable de todos los intervinientes menos los intervinientes que hay que mantener
                for(SIREC__SIREC_obj_intervinientesContrato__c inter: interSinMantener){                    
                    // Si el interviniente tiene un contrato nuevo y no esta en el set de id's de persona a mantener, ni esta en el set de nuevos
                    // lo añadimos en la variable de interMantener y lo ponemos en un set de id's de Personas Nuevas
                    if(setIdContratosNuevos.contains(inter.SIREC__SIREC_fld_contract__c) && !interPersonaMantener.contains(inter.SIREC__SIREC_fld_persona__c)
                      && !interPersonaNueva.contains(inter.SIREC__SIREC_fld_persona__c)){
                        interNuevos.add(inter);
                        interPersonaNueva.add(inter.SIREC__SIREC_fld_persona__c);
                        lIntervinientesContractSeleccionados.add(inter);                        
                    } else {
                        //Ponemos en una variable todos los intervinientes menos los que hay que hay nuevos
                        interSinMantenerSinNuevos.add(inter);
                    }
                }
                // Recorremos la query menos los intervinientes que hay que mantener, menos los intervinientes nuevos
                for(SIREC__SIREC_obj_intervinientesContrato__c inter: interSinMantenerSinNuevos){                 
                    // Si el interviniente tiene un contrato a borrar y no esta en el set de id's de persona a mantener ni en el set de nuevos lo añadimos para borrar
                    if(setIdContratosBorrar.contains(inter.SIREC__SIREC_fld_contract__c) && !interPersonaMantener.contains(inter.SIREC__SIREC_fld_persona__c)
                       && !interPersonaNueva.contains(inter.SIREC__SIREC_fld_persona__c)){
                        interBorrar.add(inter);
                        interPersonaBorrar.add(inter.SIREC__SIREC_fld_persona__c);
                    }
                }            
                Set<id> idCliente = new set<id>();
                // Calculamos el numero de avalistas y de titulares
                Integer numTitulares = 0;
                Integer numAvalistas = 0;         
                if(!lIntervinientesContractSeleccionados.isEmpty()){  
                    for(SIREC__SIREC_obj_intervinientesContrato__c intervinientesTodos: lIntervinientesContractSeleccionados){                          
                        if(intervinientesTodos.SIREC__SIREC_fld_persona__c != null && !idCliente.contains(intervinientesTodos.SIREC__SIREC_fld_persona__c)){              
                            if(intervinientesTodos.SIREC__SIREC_fld_relacionContract__c == avalista){
                                numAvalistas = numAvalistas + 1;                        
                            } else if(intervinientesTodos.SIREC__SIREC_fld_relacionContract__c == titular){
                                numTitulares = numTitulares + 1; 
                            }
                            idCliente.add(intervinientesTodos.SIREC__SIREC_fld_persona__c);                        
                        }
                    }  
                }
                // Ponemos la marca de BAJA (B) los registros de SIREC__SIREC_obj_personaAsociada__c y de SIR_IntervinienteFormulario__c de los contratos que estan en setIdContratosBorrar
                if(!interBorrar.isEmpty()){
                    List<SIR_IntervinienteFormulario__c> interFormularioBorrar = [SELECT Id, SIR_Cliente__c, SIR_Relacion__c FROM SIR_IntervinienteFormulario__c 
                                                                                    WHERE SIR_FormularioRefinanciacion__c =: idFormulario AND SIR_Cliente__c IN : interPersonaBorrar 
                                                                                    AND SIR_Relacion__c != 'B'];
                    List<SIR_IntervinienteFormulario__c> interFormularioBorrarDefinitivo = new List<SIR_IntervinienteFormulario__c>();
                    for(SIR_IntervinienteFormulario__c inFormBorrar : interFormularioBorrar){                        
                        if(!idCliente.contains(inFormBorrar.SIR_Cliente__c)){           
                            interFormularioBorrarDefinitivo.add(inFormBorrar);
                        }
                    }
                    for(SIR_IntervinienteFormulario__c interFormBorrar: interFormularioBorrarDefinitivo){
                        interFormBorrar.SIR_Relacion__c = 'B';
                    }
                    update interFormularioBorrarDefinitivo;

                    List<SIREC__SIREC_obj_personaAsociada__c> personaAsociadaBorrarDefinitivo = new List<SIREC__SIREC_obj_personaAsociada__c>();
                    List<SIREC__SIREC_obj_personaAsociada__c> personaAsociadaBorrar = [SELECT Id, SIREC__SIREC_fld_persona__c, SIR_estadoCarga__c FROM SIREC__SIREC_obj_personaAsociada__c 
                                                                                        WHERE SIREC__SIREC_fld_proceso__c =: idProceso AND SIREC__SIREC_fld_persona__c IN : interPersonaBorrar
                                                                                        AND SIR_estadoCarga__c != 'B'];
                    
                    for(SIREC__SIREC_obj_personaAsociada__c personaAsoBorrar : personaAsociadaBorrar){                        
                        if(!idCliente.contains(personaAsoBorrar.SIREC__SIREC_fld_persona__c)){           
                            personaAsociadaBorrarDefinitivo.add(personaAsoBorrar);
                        }
                    } 
                    for(SIREC__SIREC_obj_personaAsociada__c perAsoBorrar: personaAsociadaBorrarDefinitivo){
                        perAsoBorrar.SIR_estadoCarga__c = 'B';
                    }                                                                   
                    update personaAsociadaBorrarDefinitivo;
                }

                List<SIREC__SIREC_obj_personaAsociada__c> listNewPersonaAsociada = new List<SIREC__SIREC_obj_personaAsociada__c>();                
                List<SIR_IntervinienteFormulario__c> listNewIntervinienteForm = new List<SIR_IntervinienteFormulario__c>();            
                Id personaAsociadaRecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_personaAsociada__c.getRecordTypeInfosByName().get(SIR_Constantes.PERSONAASOCIADA_RECORDTYPE_NAME_PERSONA_ASOCIADA).getRecordTypeId();
                Id infoRecordTypeId = Schema.SObjectType.SIR_IntervinienteFormulario__c.getRecordTypeInfosByName().get(SIR_Constantes.INTERVINIENTEFORMULARIO_RECORDTYPE_NAME_INFORMACION).getRecordTypeId();
                decimal totalIngresosTrabajo = 0;
                if(!interNuevos.isEmpty()){
                    // Creamos tantos registros de Persona Asociada como intevinientes ha recogido la query                
                    for(SIREC__SIREC_obj_intervinientesContrato__c intervinientes: interNuevos){
                        SIREC__SIREC_obj_personaAsociada__c newPersonaAsociada = new SIREC__SIREC_obj_personaAsociada__c();                   
                        newPersonaAsociada.RecordTypeId = personaAsociadaRecordTypeId;
                        newPersonaAsociada.SIREC__SIREC_fld_proceso__c = idProceso;
                        newPersonaAsociada.SIREC__SIREC_fld_persona__c = intervinientes.SIREC__SIREC_fld_persona__c;
                        newPersonaAsociada.SIR_estadoCarga__c = 'A';
                        newPersonaAsociada.SIR_fechaCarga__c = date.today();
                        listNewPersonaAsociada.add(newPersonaAsociada);
                        
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
                    }
                    insert listNewPersonaAsociada;
                                            
                    List<SIREC__SIREC_obj_informacionCliente__c> infoCliente = [SELECT id, SIREC__SIREC_fld_CNAETexto__c, SIREC__SIREC_fld_CNOTexto__c, SIREC__SIREC_fld_cliente__c, 
                                                                                SIREC__SIREC_fld_cliente__r.CC_TipoPersona__c, SIREC__SIREC_fld_ingresosTotal__c 
                                                                                FROM SIREC__SIREC_obj_informacionCliente__c WHERE SIREC__SIREC_fld_cliente__c=: idCliente];                                  
                    if(!infoCliente.isEmpty()){
                        // Realizamos query para recoger catalogo de CNAE y CNO     
                        List<SIR_CatalogoSirec__c> catalogos = [SELECT id, SIR_Codigo__c, SIR_Descripcion__c, Name FROM SIR_CatalogoSirec__c WHERE Name='CNAE' OR Name='CNO']; 
                        Map<Id, SIREC__SIREC_obj_informacionCliente__c> mapInfoCliente = new Map<Id, SIREC__SIREC_obj_informacionCliente__c>();
                        for(SIREC__SIREC_obj_informacionCliente__c info: infoCliente){
                            mapInfoCliente.put(info.SIREC__SIREC_fld_cliente__c, info);
                        }
                        for(SIR_IntervinienteFormulario__c intervinienteForm: listNewIntervinienteForm){                 
                            if(mapInfoCliente.containsKey(intervinienteForm.SIR_Cliente__c)){
                                if(!catalogos.isEmpty()){                                   
                                    for(SIR_CatalogoSirec__c cat: catalogos){ 
                                        if(mapInfoCliente.get(intervinienteForm.SIR_Cliente__c).SIREC__SIREC_fld_CNOTexto__c == cat.SIR_Codigo__c && cat.Name == 'CNO'){
                                            intervinienteForm.SIR_Profesion__c = cat.SIR_Descripcion__c;
                                        }
                                        if(mapInfoCliente.get(intervinienteForm.SIR_Cliente__c).SIREC__SIREC_fld_CNAETexto__c == cat.SIR_Codigo__c && cat.Name == 'CNAE'){
                                            intervinienteForm.SIR_Profesion__c = cat.SIR_Descripcion__c;
                                        }
                                    }                                 
                                }
                                intervinienteForm.SIR_IngresosTrabajo__c = mapInfoCliente.get(intervinienteForm.SIR_Cliente__c).SIREC__SIREC_fld_ingresosTotal__c;
                                if(intervinienteForm.SIR_IngresosTrabajo__c == null){
                                    intervinienteForm.SIR_IngresosTrabajo__c = 0;
                                }
                                totalIngresosTrabajo = totalIngresosTrabajo + intervinienteForm.SIR_IngresosTrabajo__c;               
                            }  
                            intervinienteForm.SIR_FormularioRefinanciacion__c = idFormulario;
                        } 
                        insert listNewIntervinienteForm;
                    }                 
                }   
                // Calculamos la deuda total de los contratos con deuda seleccionados            
                List<Contract> contratosDeudaSeleccionados = [SELECT id, SIREC__SIREC_fld_deudaTotalContrato__c , SIREC__SIREC_fld_importeImpagado__c, SIREC__SIREC_fld_tipoGarantia__c, 
                                                                SIREC__SIREC_fld_tipoContrato__c, SIREC__SIREC_fld_formulaEntidad__c
                                                                FROM Contract WHERE id IN :idContractsNuevos];  
                // Se deben tener en cuenta TODOS los contratos del cliente (con y sin impago) y no solo los seleccionados en el proceso de Refi         
                List<SIREC__SIREC_obj_intervinientesContrato__c> conIntDeudaSeleccionados = [SELECT id, SIREC__SIREC_fld_contract__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c,  
                                                                                            SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoGarantia__c, 
                                                                                            SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_formulaEntidad__c,
                                                                                            SIREC__SIREC_fld_relacionContract__c, SIR_estadoCarga__c
                                                                                            FROM SIREC__SIREC_obj_intervinientesContrato__c
                                                                                            WHERE SIREC__SIREC_fld_persona__c =: idAccount  AND SIREC__SIREC_fld_relacionContract__c =: titular 
                                                                                            AND SIR_estadoCarga__c !='B'];
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
                Decimal cuotaCaixa             = 0; // SIREC__SIREC_fld_importeImpagado__c
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
                        Boolean checkGarantiaReal = constantes.garantiaReal.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoGarantia__c);  
                        // comprobamos mismos productos para Real Y Personal
                        Boolean checkProductos  = constantes.tipoProductos.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c);
                        // comprobamos productos Tarjetas
                        Boolean checkProductosTarjetas = constantes.tipoProductosTarjeas.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c);
                        // Comprobamos Todos Tipos Productos
                        Boolean checkAllProductos = constantes.todosTipoProductos.contains(con.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c);
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
                // Modificamos el registro SIR_FormularioRefinanciacion__c               
                List<SIR_FormularioRefinanciacion__c> formRefi = [SELECT id, SIR_deudaTotal__c, SIR_NumTitulares__c, SIR_NumAvalistas__c, SIR_deudaTotalGarantiaReal__c, SIR_cuotaGarantiaReal__c,
                                                                    SIR_deudaTotalGarantiaPersonal__c, SIR_CuotaGarantiaPersonal__c,SIR_deudaTotalTarjeta__c, SIR_CuotaMensualTarjetas__c, 
                                                                    SIR_deudaTotalEmpresasGrupo__c, SIR_CuotaMensualEmpresasGrupo__c, SIR_deudaTotalOtros__c, SIR_CuotaMensualOtros__c, 
                                                                    SIR_TotalDeudaCaixabank__c, SIR_prestamoDeudaCaixa__c, SIR_prestamoCuotaCaixa__c, SIR_CuotaOperacionRefCaixa__c, 
                                                                    SIR_TotalCuotaRefCaixa__c
                                                                    FROM SIR_FormularioRefinanciacion__c WHERE Id =: idFormulario LIMIT 1];           
                formRefi[0].SIR_deudaTotal__c                 = deudaTotal;
                formRefi[0].SIR_NumTitulares__c               = numTitulares;            
                formRefi[0].SIR_NumAvalistas__c               = numAvalistas;
                formRefi[0].SIR_deudaTotalGarantiaReal__c     = deudaGarantiaReal;
                formRefi[0].SIR_cuotaGarantiaReal__c          = cuotaGarantiaReal;
                formRefi[0].SIR_deudaTotalGarantiaPersonal__c = deudaGarantiaPersonal;
                formRefi[0].SIR_CuotaGarantiaPersonal__c      = cuotaGarantiaPersonal;
                formRefi[0].SIR_deudaTotalTarjeta__c          = deudaTarjeta;
                formRefi[0].SIR_CuotaMensualTarjetas__c       = cuotaTarjeta;
                formRefi[0].SIR_deudaTotalEmpresasGrupo__c    = deudaEmpresa;
                formRefi[0].SIR_CuotaMensualEmpresasGrupo__c  = cuotaEmpresa;
                formRefi[0].SIR_deudaTotalOtros__c            = deudaOtros;
                formRefi[0].SIR_CuotaMensualOtros__c          = cuotaOtros;
                formRefi[0].SIR_TotalDeudaCaixabank__c        = deudaGarantiaReal + deudaGarantiaPersonal + deudaEmpresa + deudaTarjeta + deudaOtros;
                formRefi[0].SIR_TotalCuotaCaixabank__c        = cuotaGarantiaReal + cuotaGarantiaPersonal + cuotaEmpresa + cuotaTarjeta + cuotaOtros;         
                formRefi[0].SIR_prestamoDeudaCaixa__c         = deudaTotal;           
                formRefi[0].SIR_prestamoCuotaCaixa__c         = cuotaCaixa;    
                formRefi[0].SIR_TotalIngresosTrabajo__c       = totalIngresosTrabajo;   
                if(formRefi[0].SIR_TotalCuotaCaixabank__c == null){
                    formRefi[0].SIR_TotalCuotaCaixabank__c = 0;
                } 
                if(formRefi[0].SIR_prestamoCuotaCaixa__c == null){
                    formRefi[0].SIR_prestamoCuotaCaixa__c = 0;
                }     
                if(formRefi[0].SIR_CuotaOperacionRefCaixa__c == null){
                    formRefi[0].SIR_CuotaOperacionRefCaixa__c = 0;
                }        
                formRefi[0].SIR_TotalCuotaRefCaixa__c         = formRefi[0].SIR_TotalCuotaCaixabank__c - formRefi[0].SIR_prestamoCuotaCaixa__c + formRefi[0].SIR_CuotaOperacionRefCaixa__c;
                update(formRefi[0]);   
                resultado = 'OK';            
            } catch (DmlException e) {
                resultado = 'KO' + e; 
            }       
        }    
        return resultado;
    }    
}