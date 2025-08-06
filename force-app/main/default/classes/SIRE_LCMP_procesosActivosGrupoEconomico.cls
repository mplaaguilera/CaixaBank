/*****************************************************************
 Name:  SIRE_LCMP_procesosActivosGrupoEconomico
 Copyright © 2023  CaixaBank

 Proposito:   Clase controladora externa del LWC Sire_lwc_procesosActivosGrupoEconomico                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         07/03/2023     	  Created    

*****************************************************************/
public with sharing class SIRE_LCMP_procesosActivosGrupoEconomico {
	
	/*****************************************************************
        Proposito:  Realizamos query y montar la informacion para el arbol                                                   
        Parameters: String idCliente
        Returns: List<ProcesoWrapper>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         07/03/2023     	  Created         
	*****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ProcesoWrapper> getProcesos(String idCliente){

        List<ProcesoWrapper> pro = new List<ProcesoWrapper>(); 
        if(Schema.SObjectType.FinServ__AccountAccountRelation__c.isAccessible() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            // Buscamos todas las empresas que pertenecen a este grupo Economico
            List<FinServ__AccountAccountRelation__c> empresas = new List<FinServ__AccountAccountRelation__c>();
            empresas = [SELECT Id, FinServ__RelatedAccount__c FROM FinServ__AccountAccountRelation__c 
                        WHERE RecordType.DeveloperName = 'CIBE_GrupoEconomico' AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoEconomico' 
                        AND FinServ__Account__c = :idCliente  AND FinServ__Role__r.Name = 'Parent' 
                        ORDER BY FinServ__RelatedAccount__c ASC];
            if(!empresas.isEmpty()){
                Set<Id> idEmpresas = new Set<Id>();                
                for(FinServ__AccountAccountRelation__c empresa : empresas){
                    idEmpresas.add(empresa.FinServ__RelatedAccount__c);
                }
                List<SIREC__SIREC_obj_proceso__c> todosProcesos = [SELECT Id, RecordType.Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_cliente__r.Name,  
                                                                    SIREC__SIREC_fld_fechaInicio__c, SIREC__SIREC_fld_fechaSituacion__c, toLabel(SIR_PropuestaNivelGrupo__c), 
                                                                    SIREC__SIREC_fld_descEstrategiaCatalogo__c, toLabel(SIREC__SIREC_fld_situacion__c),
                                                                    SIR_DeudaTotal__c, SIR_MaximoDiasImpago__c, Owner.Name, SIR_PropuestaProceso__c
                                                                    FROM SIREC__SIREC_obj_proceso__c 
                                                                    WHERE SIREC__SIREC_fld_cliente__c in :idEmpresas 
                                                                    AND (RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO 
                                                                        OR RecordType.Name = : SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO)
                                                                    AND SIREC__SIREC_fld_situacion__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                                                                    AND SIR_ObjetivoProceso__c != :SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO
                                                                    ORDER BY SIREC__SIREC_fld_cliente__c];
                if(!todosProcesos.isEmpty()){
                    Set<Id> idsEmp = new Set<Id>();
                    Boolean primeraVez;
                    ProcesoWrapper padreWraper = new ProcesoWrapper();
                    List<Items> procesosMismaEmpresa = new List<Items>();                   
                    for(Integer i=0; i < todosProcesos.size(); i++){    
                        if(idsEmp.contains(todosProcesos[i].SIREC__SIREC_fld_cliente__c)){
                            primeraVez = false;
                            // Creamos otro registro hijo
                            Items procesoWrapp = new Items();
                            procesoWrapp.idProceso      = URL.getSalesforceBaseUrl().toExternalForm() + '/' + todosProcesos[i].Id;
                            procesoWrapp.tipoProceso    = todosProcesos[i].RecordType.Name;
                            procesoWrapp.estrategia     = todosProcesos[i].SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                            procesoWrapp.fechaInicio    = string.valueOf(todosProcesos[i].SIREC__SIREC_fld_fechaInicio__c);
                            procesoWrapp.fechaSituacion = string.valueOf(todosProcesos[i].SIREC__SIREC_fld_fechaSituacion__c);
                            procesoWrapp.situacion      = todosProcesos[i].SIREC__SIREC_fld_situacion__c;
                            procesoWrapp.deudaTotal     = string.valueOf(todosProcesos[i].SIR_DeudaTotal__c);
                            procesoWrapp.diasImpago     = string.valueOf(todosProcesos[i].SIR_MaximoDiasImpago__c);
                            procesoWrapp.gestor         = todosProcesos[i].Owner.Name;
                            procesoWrapp.propuesta      = todosProcesos[i].SIR_PropuestaProceso__c;
                            procesoWrapp.propuestaNivelGrupo = todosProcesos[i].SIR_PropuestaNivelGrupo__c;
                            procesosMismaEmpresa.add(procesoWrapp);                           
                            if(i == todosProcesos.size()-1){
                                padreWraper.items = procesosMismaEmpresa;
                                pro.add(padreWraper);
                            }                            
                        } else { 
                            if(primeraVez == true || primeraVez == false ){
                                padreWraper.items = procesosMismaEmpresa;
                                pro.add(padreWraper);
                            } 
                            primeraVez = true;                                                    
                            // Añadimos el idAccount
                            idsEmp.add(todosProcesos[i].SIREC__SIREC_fld_cliente__c);
                            // Creamos el registro padre
                            padreWraper = new ProcesoWrapper(); 
                            padreWraper.nombreEmpresa  = todosProcesos[i].SIREC__SIREC_fld_cliente__r.Name;
                            padreWraper.idEmpresa      = URL.getSalesforceBaseUrl().toExternalForm() + '/' + todosProcesos[i].SIREC__SIREC_fld_cliente__c;
                            // Creamos registro hijo
                            procesosMismaEmpresa = new List<Items>();
                            Items procesoWrapp = new Items();
                            procesoWrapp.idProceso      = URL.getSalesforceBaseUrl().toExternalForm() + '/' + todosProcesos[i].Id;
                            procesoWrapp.tipoProceso    = todosProcesos[i].RecordType.Name;
                            procesoWrapp.estrategia     = todosProcesos[i].SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                            procesoWrapp.fechaInicio    = string.valueOf(todosProcesos[i].SIREC__SIREC_fld_fechaInicio__c);
                            procesoWrapp.fechaSituacion = string.valueOf(todosProcesos[i].SIREC__SIREC_fld_fechaSituacion__c);
                            procesoWrapp.situacion      = todosProcesos[i].SIREC__SIREC_fld_situacion__c;
                            procesoWrapp.deudaTotal     = string.valueOf(todosProcesos[i].SIR_DeudaTotal__c);
                            procesoWrapp.diasImpago     = string.valueOf(todosProcesos[i].SIR_MaximoDiasImpago__c);
                            procesoWrapp.gestor         = todosProcesos[i].Owner.Name;
                            procesoWrapp.propuesta      = todosProcesos[i].SIR_PropuestaProceso__c;
                            procesoWrapp.propuestaNivelGrupo = todosProcesos[i].SIR_PropuestaNivelGrupo__c;
                            procesosMismaEmpresa.add(procesoWrapp);
                            if(i == todosProcesos.size()-1){
                                padreWraper.items = procesosMismaEmpresa;                                
                                pro.add(padreWraper);
                            }
                        }
                    }
                }
            }                  
        }
        return pro;
    } 
	
	
    public Class ProcesoWrapper{
        @AuraEnabled
        public String nombreEmpresa {get;set;}
        @AuraEnabled
        public String idEmpresa {get;set;}        
        @AuraEnabled
        public List<Items> items {get;set;}
    }
	
    public Class Items{
        @AuraEnabled
        public String tipoProceso {get;set;}       
        @AuraEnabled
        public String estrategia {get;set;}
		@AuraEnabled
        public String fechaInicio {get;set;}
		@AuraEnabled
        public String fechaSituacion {get;set;}
		@AuraEnabled
        public String situacion {get;set;}
        @AuraEnabled
        public String deudaTotal {get;set;}
        @AuraEnabled
        public String diasImpago {get;set;}
		@AuraEnabled
        public String gestor {get;set;}
        @AuraEnabled
        public String propuesta {get;set;}
        @AuraEnabled
        public String idProceso {get;set;}
        @AuraEnabled
        public String propuestaNivelGrupo {get;set;} 
    }
   
}