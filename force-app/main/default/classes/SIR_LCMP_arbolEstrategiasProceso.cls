/*****************************************************************
 Name:  SIR_LCMP_arbolEstrategiasProceso
 Copyright © 2021  CaixaBank

 Proposito:   Clase controladora externa del LWC Sir_lwc_arbolEstrategiasProceso                                                                                                                 

 
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US291328         Atmira         16/11/2021     	  Created  
    2.0                             Atmira         21/12/2022         Modificación 

*****************************************************************/
public with sharing class SIR_LCMP_arbolEstrategiasProceso {
	
	/*****************************************************************
        Proposito:  Realizamos query y montar la informacion para el arbol                                                   
        Parameters: String idProceso
        Returns: List<ProcesoWrapper>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US291328         Atmira         16/11/2021     	  Created  
        2.0                             Atmira         21/12/2022         Modificación  
        
	*****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ProcesoWrapper> getProcesos(String idCliente){

        List<ProcesoWrapper> pro = new List<ProcesoWrapper>(); 
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() && Schema.SObjectType.SIR_HistoricoProceso__c.isAccessible()){
            // Buscamos el numero actual del Ciclo de Impago
            List<SIREC__SIREC_obj_proceso__c> procesoMaxNumCicloImpago = [ SELECT SIR_CicloImpago__c FROM SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_cliente__c =: idCliente 
                                                                            AND SIREC__SIREC_fld_situacion__c != : SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                                                                            AND RecordType.DeveloperName != : SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_AP_PP
                                                                            order by SIR_CicloImpago__c NULLS LAST limit 1];                                                                            
            if(!procesoMaxNumCicloImpago.isEmpty()){
                // Por si el ciclo esta vacio ponemos uno por defecto que nunca podria estar
                Decimal numeroCicloImpagoActual = 99.99;    
                if(procesoMaxNumCicloImpago[0].SIR_CicloImpago__c != null){
                    numeroCicloImpagoActual = procesoMaxNumCicloImpago[0].SIR_CicloImpago__c;
                }   
                // Buscamos todos los procesos Presol/Impa que no estan finalizados + procesos informativos que tienen el ciclo de impago actual
                List<SIREC__SIREC_obj_proceso__c> procesoSF = [SELECT SIREC__SIREC_fld_descEstrategiaCatalogo__c, SIREC__SIREC_fld_fechaInicio__c, SIREC__SIREC_fld_fechaSituacion__c,
                                                                Name, toLabel(SIREC__SIREC_fld_situacion__c), Owner.Name, SIR_FechaInicioEstrategia__c, toLabel(SIR_fld_Situacion_SF__c),
                                                                SIR_ObjetivoProceso__c, SIR_CicloImpago__c, SIREC__SIREC_fld_cliente__c, SIR_AlertaSIREC__c, RecordType.Name, SIREC__SIREC_fld_fechaBaja__c
                                                                FROM SIREC__SIREC_obj_proceso__c 
                                                                WHERE SIREC__SIREC_fld_cliente__c =:idCliente
                                                                AND RecordType.DeveloperName != : SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_AP_PP
                                                                AND ( 
                                                                    (   SIREC__SIREC_fld_situacion__c !=: SIR_Constantes.PROCESO_SITUACION_FINALIZADO) 
                                                                    OR
                                                                    (SIR_CicloImpago__c =: numeroCicloImpagoActual
                                                                     AND  SIREC__SIREC_fld_situacion__c =: SIR_Constantes.PROCESO_SITUACION_FINALIZADO 
	                                                	             AND  RecordType.Name !=: SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL
	                                                                 AND  RecordType.Name !=: SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO
                                                                     AND  Name !=: SIR_Constantes.PROCESO_NAME_REFINANCIACION
	                                                                )
                                                                )
                                                                ORDER BY createddate DESC];
                                                                
                Set<Id> idProcesoImpa = new Set<Id>();
                Boolean primerImpa = false;
                List<SIREC__SIREC_obj_proceso__c> procesosEnGestion = new List<SIREC__SIREC_obj_proceso__c>(); 
                List<SIREC__SIREC_obj_proceso__c> procesosInformativos = new List<SIREC__SIREC_obj_proceso__c>(); 
                // Recorremos los procesos para clasificarlos en variables                
                for(SIREC__SIREC_obj_proceso__c proceso : procesoSF){                    
                    // Cualquier Proceso PRESOL o de Refinanciación debe estar en procesosEnGestion
                    if( proceso.Name == SIR_Constantes.PROCESO_NAME_REFINANCIACION || proceso.RecordType.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL 
                        || proceso.RecordType.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO){
                        procesosEnGestion.add(proceso);
                    } else {
                         // Si es IMPA ( GESTIÓN O NO GESTION) activo debe estar en procesosEnGestion
                         // En el caso de dos activos IMPA escogeremos el mas reciente ( ya viene ordenado por createddate desc) para que sea el padre 
                         // y se mostrará en procesosEnGestion, el resto en procesosInformativos
                         if ( proceso.SIREC__SIREC_fld_situacion__c != SIR_Constantes.PROCESO_FINALIZADO && primerImpa == false) { 
                           procesosEnGestion.add(proceso);
                           primerImpa = true;
                         } else {
                                 // Si es IMPA ( GESTIÓN O NO GESTION) finalizado debe estar en procesosInformativos para poder ordenarlo como si fuera un cambio de estrategia
                                 procesosInformativos.add(proceso);
                         }
                         // Si es un proceso IMPA de Gestión debe estar en idProcesoImpa, para buscar su historia en histórico
                         if(proceso.SIR_ObjetivoProceso__c != SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO){
                            idProcesoImpa.add(proceso.Id);
                        }
                    }
                }    

                List<Items> proHistYProInfor = new List<Items>();
                // Si hay procesos Impa en Gestion y hay procesos Informativos, pondremos los procesos informativos en la variable 
				if(!procesosInformativos.isEmpty()){  				
                    for(SIREC__SIREC_obj_proceso__c proInfo : procesosInformativos){
                        Items infoProWrapp = new Items();
                        infoProWrapp.name = '';
                        infoProWrapp.idProceso = '';
                        infoProWrapp.estrategia = proInfo.SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                        infoProWrapp.fechaInicio = string.valueOf(proInfo.SIR_FechaInicioEstrategia__c);
                        infoProWrapp.fechaFin =  string.valueOf(proInfo.SIREC__SIREC_fld_fechaBaja__c);
                        infoProWrapp.fechaSituacion = string.valueOf(proInfo.SIREC__SIREC_fld_fechaSituacion__c);	
                        infoProWrapp.alertaSirec = proInfo.SIR_AlertaSIREC__c; //AÑADIR ALERTA SIREC
                        // Si el proceso no esta finalizado se pone en En Curso, sino se deja lo que tiene
                        if(proInfo.SIREC__SIREC_fld_situacion__c != SIR_Constantes.PROCESO_FINALIZADO && proInfo.SIR_ObjetivoProceso__c == SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO){
                            infoProWrapp.situacion = 'En Curso';
                        } else {
                            infoProWrapp.situacion = proInfo.SIREC__SIREC_fld_situacion__c;
                        }                  
                        infoProWrapp.gestor = proInfo.Owner.name;
                        proHistYProInfor.add(infoProWrapp);
                    }                
                }  
                if(!idProcesoImpa.isEmpty()){  
                    List<SIR_HistoricoProceso__c> historicoProcesoSF = [SELECT SIR_Proceso__c, SIR_Estrategia__c, SIR_FechaFinEstrategia__c, SIR_FechaInicioEstrategia__c,
                                                                        SIR_FechaSituacion__c, SIR_Situacion__c, SIR_Tipo__c, SIR_Proceso__r.owner.name, SIR_Proceso__r.SIR_FechaInicioEstrategia__c
                                                                        FROM SIR_HistoricoProceso__c 
                                                                        WHERE SIR_Proceso__c in :idProcesoImpa AND SIR_Tipo__c = 'Estrategia'                                                                         
                                                                        ORDER BY createddate DESC];
                    for(SIR_HistoricoProceso__c procesoHist : historicoProcesoSF){
                        if(procesoHist.SIR_FechaInicioEstrategia__c != procesoHist.SIR_Proceso__r.SIR_FechaInicioEstrategia__c){
                            Items histProWrapp = new Items();
                            histProWrapp.name = '';
                            histProWrapp.idProceso = '';
                            histProWrapp.estrategia = procesoHist.SIR_Estrategia__c;
                            histProWrapp.fechaInicio = string.valueOf(procesoHist.SIR_FechaInicioEstrategia__c);
                            histProWrapp.fechaFin = string.valueOf(procesoHist.SIR_FechaFinEstrategia__c);
                            histProWrapp.fechaSituacion = string.valueOf(procesoHist.SIR_FechaSituacion__c);				
                            histProWrapp.situacion = procesoHist.SIR_Situacion__c;
                            histProWrapp.alertaSirec = '';
                            histProWrapp.gestor = procesoHist.SIR_Proceso__r.owner.name;
                            proHistYProInfor.add(histProWrapp);
                        }      
                    } 
                }
                // Ordenamos por fecha Inicio los hijos
                if(!proHistYProInfor.isEmpty()){
                    Map<String,List<Items>> itemsMap = new Map<String,List<Items>>();
                    Map<String,List<Items>> itemsMapSorted = new Map<String,List<Items>>();
                    List<String> orderingList = new List<String>();
                    List<Items> sortedItemsList = new List<Items>();                    
                    for(Items elemento: proHistYProInfor){
                        if(itemsMap.containsKey(elemento.fechaInicio)) {
                            itemsMap.get(elemento.fechaInicio).add(elemento);
                        } else {
                            List<Items> arr = new List<Items>();     
                            arr.add(elemento);
                            itemsMap.put(elemento.fechaInicio, arr);
                        }
                    } 
                    orderingList.addAll(itemsMap.keyset());
                    // ordenamos la lista
                    orderingList.sort();  
                    for(Integer i=0; i < orderingList.size(); i++){
                        if(itemsMapSorted.containsKey(orderingList[i])) {
                            itemsMapSorted.get(orderingList[i]).addAll(itemsMap.get(orderingList[i]));
                        } else {
                            List<Items> arr = new List<Items>();     
                            arr.addAll(itemsMap.get(orderingList[i]));
                            itemsMapSorted.put(orderingList[i], arr);
                        }
                    }
                    for(List<Items> items : itemsMapSorted.values()){
                        sortedItemsList.addAll(items);
                    }
                    // limpiamos la variable
                    proHistYProInfor = new List<Items>();
                    // Recorremos al reves la lista para ordenarla por fecha inicio de mas antigua a mas actual
                    for(Integer i=sortedItemsList.size()-1; i >= 0; i--){
                        proHistYProInfor.add(sortedItemsList[i]);
                    }
                }               
                for(SIREC__SIREC_obj_proceso__c proceso : procesosEnGestion){
                    ProcesoWrapper procesoWraper = new ProcesoWrapper() ; 
                    procesoWraper.name = proceso.Name;
                    // Si es un proceso Informativo no navega
                    if(proceso.SIR_ObjetivoProceso__c == SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO){
                        procesoWraper.idProceso = URL.getSalesforceBaseUrl().toExternalForm() + '/' + proceso.SIREC__SIREC_fld_cliente__c;
                    } else {
                        procesoWraper.idProceso = URL.getSalesforceBaseUrl().toExternalForm() + '/' + proceso.Id;    
                    }                
                    procesoWraper.estrategia = proceso.SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                    if(proceso.Name == SIR_Constantes.PROCESO_NAME_REFINANCIACION){
                        procesoWraper.fechaInicio = string.valueOf(proceso.SIREC__SIREC_fld_fechaInicio__c);                
                    } else {
                        procesoWraper.fechaInicio = string.valueOf(proceso.SIR_FechaInicioEstrategia__c);
                    }			
                    procesoWraper.fechaFin = '';
                    procesoWraper.fechaSituacion = string.valueOf(proceso.SIREC__SIREC_fld_fechaSituacion__c);
                    // Si el proceso no esta finalizado se pone en En Curso, sino se deja lo que tiene
                    if(proceso.SIREC__SIREC_fld_situacion__c != 'Finalizado' && proceso.SIR_ObjetivoProceso__c == SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO){
                        procesoWraper.situacion = 'En Curso';
                    } else {
                        procesoWraper.situacion = proceso.SIR_fld_Situacion_SF__c;
                    }                    
                    procesoWraper.gestor = proceso.Owner.Name;      
                    procesoWraper.alertaSirec = proceso.SIR_AlertaSIREC__c;
                
                    //  comentamos todo el for porque informamos el gestor antes
                    /*
                    for(Items histProInfo : proHistYProInfor){                        
                      //if(proceso.Name == SIR_Constantes.tipoProceso_Gestion1_90 && histProInfo.fechaInicio != string.valueOf(proceso.SIR_FechaInicioEstrategia__c)){
                        if(proceso.RecordType.Name != SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL && proceso.Name != SIR_Constantes.PROCESO_NAME_REFINANCIACION && histProInfo.fechaInicio != string.valueOf(proceso.SIR_FechaInicioEstrategia__c)){
                            histProInfo.gestor = proceso.Owner.Name;
                        }               
                    } */

                    //if(!proHistYProInfor.isEmpty() && proceso.Name == SIR_Constantes.tipoProceso_Gestion1_90){
                    if(!proHistYProInfor.isEmpty() && proceso.RecordType.Name != SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL 
                        && proceso.Name != SIR_Constantes.PROCESO_NAME_REFINANCIACION && proceso.RecordType.Name != SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO){
                        procesoWraper.items = proHistYProInfor;                    
                    }            
                    pro.add(procesoWraper);            
                }
            }
            return pro ;           
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