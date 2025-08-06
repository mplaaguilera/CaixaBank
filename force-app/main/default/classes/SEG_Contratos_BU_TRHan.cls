public with sharing class SEG_Contratos_BU_TRHan extends CC_TriggerHandlerBase {

		
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_Contratos__c>)tp.newList, (Map<Id, SEG_Contratos__c>)tp.newMap, (Map<Id, SEG_Contratos__c>) tp.oldMap);
    }
    
    private void process(List<SEG_Contratos__c> listNewObj, Map<Id, SEG_Contratos__c> mapNewObj, Map<Id, SEG_Contratos__c> mapOldObj) {

        List<Id> contratosSegmentos = new List<Id>();
        
        for (SEG_Contratos__c contrato : listNewObj) {
				contratosSegmentos.add(contrato.Id);
			}

            if(!contratosSegmentos.isEmpty()){
                fechaFirma(contratosSegmentos, mapNewObj, mapOldObj);	
                noReclamar(contratosSegmentos, mapNewObj, mapOldObj);
                reclamacion1RM(contratosSegmentos, mapNewObj, mapOldObj);
                reclamacion2RM(contratosSegmentos, mapNewObj, mapOldObj);	
                reclamacion3RM(contratosSegmentos, mapNewObj, mapOldObj);
                reclamacionesAgotadas(contratosSegmentos, mapNewObj, mapOldObj);	
            }
	}   

    /**
     * @description Si el  campo SEG_Estado__c es 'Firmado' actualiza el campo de la fecha SEG_Fecha_Firma__c a Hoy 
     *  @param contratosSEG -> Lista de contratos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void fechaFirma(List<Id> contratosSEG, Map<Id, SEG_Contratos__c> mapNewObj, Map<Id, SEG_Contratos__c> mapOldObj) {
        for (Id  contratoId : contratosSEG) {
            if(mapOldObj.get(contratoId).SEG_Estado__c != mapNewObj.get(contratoId).SEG_Estado__c && mapNewObj.get(contratoId).SEG_Estado__c == 'Firmado'){
                mapNewObj.get(contratoId).SEG_Fecha_Firma__c = date.Today();                
            }
        }      
    }

    /**
     * @description Si el  campo SEG_Estado__c es 'No reclamar' actualiza el campo de la fecha SEG_Fecha_Parada_Reclamacion__c a Hoy 
     *  @param contratosSEG -> Lista de contratos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void noReclamar(List<Id> contratosSEG, Map<Id, SEG_Contratos__c> mapNewObj, Map<Id, SEG_Contratos__c> mapOldObj)
    {
        for (Id  contratoId : contratosSEG)
        {
                if (mapNewObj.get(contratoId).SEG_Estado__c == 'No reclamar' || mapOldObj.get(contratoId).SEG_Estado__c == 'No reclamar')
                {
                    mapNewObj.get(contratoId).SEG_Fecha_Parada_Reclamacion__c= date.Today();
                }
        }      
    }

    /**
     * @description Si los  campos SEG_1a_Reclamacion_ejecutada_manualmente__c, SEG_2a_Reclamacion_ejecutada_manualmente__c, SEG_3a_Reclamacion_ejecutada_manualmente__c y SEG_Fecha_Envio_Gestor_Proceso__c son true actualiza el campo de  SEG_Estado__c a 'Reclamaciones agotadas'
     *  @param contratosSEG -> Lista de contratos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void reclamacionesAgotadas(List<Id> contratosSEG, Map<Id, SEG_Contratos__c> mapNewObj, Map<Id, SEG_Contratos__c> mapOldObj)
    { 
        for (Id  contratoId : contratosSEG)
        {
            if (mapNewObj.get(contratoId).SEG_1a_Reclamacion_ejecutada_manualmente__c != false &&  mapNewObj.get(contratoId).SEG_2a_Reclamacion_ejecutada_manualmente__c != false && mapNewObj.get(contratoId).SEG_3a_Reclamacion_ejecutada_manualmente__c != false && mapNewObj.get(contratoId).SEG_Fecha_Envio_Gestor_Proceso__c != null)
            {
            mapNewObj.get(contratoId).SEG_Estado__c = 'Reclamaciones agotadas' ;  
            }
        }      
    }

    /**
     * @description Si el  campo SEG_1a_Reclamacion_ejecutada_manualmente__c es true actualiza el campo de la fecha SEG_Fecha_1a_Reclamacion_Proceso__c a Hoy 
     *  @param contratosSEG -> Lista de contratos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void reclamacion1RM(List<Id> contratosSEG, Map<Id, SEG_Contratos__c> mapNewObj, Map<Id, SEG_Contratos__c> mapOldObj)
    { 
        for (Id  contratoId : contratosSEG)
        {
            if(mapOldObj.get(contratoId).SEG_1a_Reclamacion_ejecutada_manualmente__c!=mapNewObj.get(contratoId).SEG_1a_Reclamacion_ejecutada_manualmente__c && mapNewObj.get(contratoId).SEG_1a_Reclamacion_ejecutada_manualmente__c == true){   
                mapNewObj.get(contratoId).SEG_Fecha_1a_Reclamacion_Proceso__c = date.Today();        
            }
        }      
    }

    /**
     * @description Si el  campo SEG_2a_Reclamacion_ejecutada_manualmente__c es true actualiza el campo de la fecha SEG_Fecha_2a_Reclamacion_Proceso__c a Hoy 
     *  @param contratosSEG -> Lista de contratos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void reclamacion2RM(List<Id> contratosSEG, Map<Id, SEG_Contratos__c> mapNewObj, Map<Id, SEG_Contratos__c> mapOldObj)
    { 
        for (Id  contratoId : contratosSEG)
        {
            if(mapOldObj.get(contratoId).SEG_2a_Reclamacion_ejecutada_manualmente__c!=mapNewObj.get(contratoId).SEG_2a_Reclamacion_ejecutada_manualmente__c && mapNewObj.get(contratoId).SEG_2a_Reclamacion_ejecutada_manualmente__c == true){
                mapNewObj.get(contratoId).SEG_Fecha_2a_Reclamacion_Proceso__c = date.Today();
            }
        }      
    }

    /**
     * @description Si el  campo SEG_3a_Reclamacion_ejecutada_manualmente__c es true actualiza el campo de la fecha SEG_Fecha_3a_Reclamacion_Proceso__c a Hoy 
     *  @param contratosSEG -> Lista de contratos con los valores nuevos.
	 *  @param mapNewObj
	 *  @param mapOldObj
     */ 
    public static void reclamacion3RM(List<Id> contratosSEG, Map<Id, SEG_Contratos__c> mapNewObj, Map<Id, SEG_Contratos__c> mapOldObj)
    { 
        for (Id  contratoId : contratosSEG)
        {
            if(mapOldObj.get(contratoId).SEG_3a_Reclamacion_ejecutada_manualmente__c!=mapNewObj.get(contratoId).SEG_3a_Reclamacion_ejecutada_manualmente__c && mapNewObj.get(contratoId).SEG_3a_Reclamacion_ejecutada_manualmente__c == true){
                    mapNewObj.get(contratoId).SEG_Fecha_3a_Reclamacion_Proceso__c = date.Today();
            }
        }      
    }
}