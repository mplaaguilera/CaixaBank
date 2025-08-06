/**
*   @description SEG_Case_BI_TRHan
*/
public with sharing class SEG_Grupo_Colaborador_Contact_BI_TRHan extends CC_TriggerHandlerBase{
    /**
     * @description   Método principal del trigger.
     * @param tp -> Contexto del trigger. 
     */ 
    
    public override void mainEntry(CC_TriggerParameters tp){
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList); 
	}
    
    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObjSeg) {
        
        Id recordTypeGrupoOperativoSEG = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        List<CC_Grupo_Colaborador_Contact__c> listColaboradoresSeg = new List<CC_Grupo_Colaborador_Contact__c>();
        Set<Id> idsGruposColaboradores = new Set<Id>();
        
        for(CC_Grupo_Colaborador_Contact__c contactoColaborador : listNewObjSeg){
            if(contactoColaborador.CC_Grupo_Colaborador__c != null){
                idsGruposColaboradores.add(contactoColaborador.CC_Grupo_Colaborador__c);
            }
        }
        
        if(!idsGruposColaboradores.isEmpty()){
        	Map<Id,CC_Grupo_Colaborador__c> mapGruposColaboradores = new Map<Id,CC_Grupo_Colaborador__c>([SELECT Id, RecordTypeId FROM CC_Grupo_Colaborador__c WHERE Id IN :idsGruposColaboradores]);
        
            for(CC_Grupo_Colaborador_Contact__c contactoColaborador : listNewObjSeg){
                if(mapGruposColaboradores.containsKey(contactoColaborador.CC_Grupo_Colaborador__c) && mapGruposColaboradores.get(contactoColaborador.CC_Grupo_Colaborador__c).RecordTypeId == recordTypeGrupoOperativoSEG){
                    listColaboradoresSeg.add(contactoColaborador);
                }
            }
        }
        
        // Validación de usuario único en los grupos colaboradores
		comprobarUsuarioExistente(listColaboradoresSeg);
	}
    
    /**
    * @description   Proceso de negocio del trigger.
    * @param listaCasosSegmentos -> Listado de casos de segmentos.
    * @param listNewObjSeg -> Lista de casos con los valores nuevos.
    */ 
    public static void comprobarUsuarioExistente(List<CC_Grupo_Colaborador_Contact__c> listColaboradoresSeg) {

        Map<Id,List<CC_Grupo_Colaborador_Contact__c>> mapaColaboradoresEnGrupos = new Map<Id,List<CC_Grupo_Colaborador_Contact__c>>();
        Set<Id> idsGruposColaboradores = new Set<Id>();
        
        for(CC_Grupo_Colaborador_Contact__c contactoColabSeg : listColaboradoresSeg){
            idsGruposColaboradores.add(contactoColabSeg.CC_Grupo_Colaborador__c);
        }
        
        List<CC_Grupo_Colaborador_Contact__c> lstColaboradoresExistentes = [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c IN :idsGruposColaboradores];
        
        for(CC_Grupo_Colaborador_Contact__c colaboradoresExistente : lstColaboradoresExistentes){
            List<CC_Grupo_Colaborador_Contact__c> lstColaboradoresPorGrupo = new List<CC_Grupo_Colaborador_Contact__c>();
            if(mapaColaboradoresEnGrupos.containsKey(colaboradoresExistente.CC_Grupo_Colaborador__c)){
				lstColaboradoresPorGrupo = mapaColaboradoresEnGrupos.get(colaboradoresExistente.CC_Grupo_Colaborador__c);
                lstColaboradoresPorGrupo.add(colaboradoresExistente);
                mapaColaboradoresEnGrupos.put(colaboradoresExistente.CC_Grupo_Colaborador__c, lstColaboradoresPorGrupo);                
            } else {
                lstColaboradoresPorGrupo.add(colaboradoresExistente);
                mapaColaboradoresEnGrupos.put(colaboradoresExistente.CC_Grupo_Colaborador__c, lstColaboradoresPorGrupo);
            }
        }
        
        for(CC_Grupo_Colaborador_Contact__c contactoColabSeg :listColaboradoresSeg){
            if(mapaColaboradoresEnGrupos.containsKey(contactoColabSeg.CC_Grupo_Colaborador__c)){
                for(CC_Grupo_Colaborador_Contact__c contactoEncontrado :mapaColaboradoresEnGrupos.get(contactoColabSeg.CC_Grupo_Colaborador__c)){
                    if(contactoColabSeg.CC_Usuario__c == contactoEncontrado.CC_Usuario__c){
                        contactoColabSeg.addError('El usuario ya existe en el grupo colaborador');
                    }
                }
            }
        }
    }
}