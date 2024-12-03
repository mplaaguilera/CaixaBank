/*****************************************************************
 Name:  SIR_LCMP_arbolProceso
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase controladora externa del LWC Sir_lwc_arbolProceso                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US291328         Atmira         18/11/2021     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_arbolProceso {
	
	/*****************************************************************
        Proposito:  Realizamos query y montar la informacion para el arbol                                                   
        Parameters: String idProceso
        Returns: List<ProcesoWrapper>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US291328         Atmira         18/11/2021     	  Created    
        
	*****************************************************************/
   @AuraEnabled(cacheable=true)
    public static List<ProcesoWrapper> getProcesos(String idProceso){

        List<ProcesoWrapper> pro = new List<ProcesoWrapper>();

        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() && Schema.SObjectType.SIR_HistoricoProceso__c.isAccessible()){

            List<SIREC__SIREC_obj_proceso__c> procesoSF = [SELECT  SIREC__SIREC_fld_descEstrategiaCatalogo__c, SIREC__SIREC_fld_fechaInicio__c, SIREC__SIREC_fld_fechaSituacion__c,
                                                            Name, toLabel(SIREC__SIREC_fld_situacion__c), Owner.Name, SIR_FechaInicioEstrategia__c,SIR_AlertaSIREC__c, toLabel(SIR_fld_Situacion_SF__c)
                                                            FROM SIREC__SIREC_obj_proceso__c WHERE id =:idProceso ORDER BY createddate DESC];
            List<SIR_HistoricoProceso__c> historicoProcesoSF = [SELECT SIR_Proceso__c, SIR_Estrategia__c, SIR_FechaFinEstrategia__c, SIR_FechaInicioEstrategia__c,
                                                                SIR_FechaSituacion__c, SIR_Situacion__c, SIR_Tipo__c
                                                                FROM SIR_HistoricoProceso__c 
                                                                WHERE SIR_Proceso__c =:idProceso AND SIR_Tipo__c = 'Estrategia'
                                                                ORDER BY createddate DESC];
                    
            for(SIREC__SIREC_obj_proceso__c proceso : procesoSF){
                ProcesoWrapper procesoWraper = new ProcesoWrapper() ; 
                procesoWraper.name = proceso.Name;
                procesoWraper.idProceso = URL.getSalesforceBaseUrl().toExternalForm() + '/' + proceso.Id;
                procesoWraper.estrategia = proceso.SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                if(proceso.Name == 'Proceso de Refinanciación'){
                    procesoWraper.fechaInicio = string.valueOf(proceso.SIREC__SIREC_fld_fechaInicio__c);                
                } else {
                    procesoWraper.fechaInicio = string.valueOf(proceso.SIR_FechaInicioEstrategia__c);
                }
                procesoWraper.fechaFin = '';
                procesoWraper.fechaSituacion = string.valueOf(proceso.SIREC__SIREC_fld_fechaSituacion__c);
                procesoWraper.situacion = proceso.SIR_fld_Situacion_SF__c;
                procesoWraper.gestor = proceso.Owner.Name;
                procesoWraper.alertaSirec = proceso.SIR_AlertaSIREC__c;          
            
                List<Items> histProceso = new List<Items>();            
                for(SIR_HistoricoProceso__c histPro : historicoProcesoSF){
                    if(histPro.SIR_Proceso__c == proceso.Id && proceso.Name != 'Proceso de Refinanciación' && histPro.SIR_FechaInicioEstrategia__c != proceso.SIR_FechaInicioEstrategia__c){
                        Items histProWrapp = new Items();
                        histProWrapp.name = '';
                        histProWrapp.idProceso = '';
                        histProWrapp.estrategia = histPro.SIR_Estrategia__c;
                        histProWrapp.fechaInicio = string.valueOf(histPro.SIR_FechaInicioEstrategia__c);
                        histProWrapp.fechaFin = string.valueOf(histPro.SIR_FechaFinEstrategia__c);
                        histProWrapp.fechaSituacion = string.valueOf(histPro.SIR_FechaSituacion__c);				
                        histProWrapp.situacion = histPro.SIR_Situacion__c;
                        histProWrapp.gestor = proceso.Owner.Name;
                        histProceso.add(histProWrapp);
                    }               
                }
                if(!histProceso.isEmpty()){
                    procesoWraper.items = histProceso;
                }            
                pro.add(procesoWraper);            
            }
        }
        return pro ;
    } 
	
	
    public Class ProcesoWrapper{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String idProceso {get;set;}        
        @AuraEnabled
        public String estrategia {get;set;}
		@AuraEnabled
        public String fechaInicio {get;set;}
		@AuraEnabled
        public String fechaFin {get;set;}
		@AuraEnabled
        public String fechaSituacion {get;set;}
		@AuraEnabled
        public String situacion {get;set;}
		@AuraEnabled
        public String gestor {get;set;}
		@AuraEnabled
        public String alertaSirec {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
	
    public Class Items{
        @AuraEnabled
        public String name {get;set;}
         @AuraEnabled
        public String idProceso {get;set;}
        @AuraEnabled
        public String estrategia {get;set;}
		@AuraEnabled
        public String fechaInicio {get;set;}
		@AuraEnabled
        public String fechaFin {get;set;}
		@AuraEnabled
        public String fechaSituacion {get;set;}
		@AuraEnabled
        public String situacion {get;set;}
		@AuraEnabled
        public String gestor {get;set;}
		@AuraEnabled
        public String alertaSirec {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
}