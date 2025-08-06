public with sharing class SEG_GrupoGestorCaseQueable implements Queueable{
    List<Id> casosSEG;
    Map<Id,Case> mapNewObj;
    
    public SEG_GrupoGestorCaseQueable(List<Id> casosIds, Map<Id, Case> mapaCasosNewObj) {
        casosSEG = casosIds;
        mapNewObj = mapaCasosNewObj;
    }

    public void execute(QueueableContext context){
        String gestorComercial;
        String splitedName;
        Map<Id,String> mapaIdGestor = new map<Id,String>();

        for (Id casoId : casosSEG){
            if (mapNewObj.containskey(casoId)){
                gestorComercial = mapNewObj.get(casoId).SEG_Gestor_comercial__c;
                if (gestorComercial != null && gestorComercial != ' '){
                    String[] gestComerSplited = gestorComercial.split(' ');
                    splitedName = gestComerSplited[0];
                    mapaIdGestor.put(casoId, splitedName);
                }
            }
        }
        if (!mapaIdGestor.isEmpty()){
            List<SEG_Gestor_Grupo__c> gruposGestores = [SELECT id, SEG_GrupoOperativa__r.Name, SEG_GrupoOperativa__r.SEG_Tipologia__c, SEG_EmpleadoGestor__r.FirstName   
                                                        FROM SEG_Gestor_Grupo__c 
                                                        WHERE SEG_GrupoOperativa__r.SEG_Tipologia__c = 'BO' AND SEG_EmpleadoGestor__r.FirstName IN: mapaIdGestor.values()];
            Map<String,SEG_Gestor_Grupo__c> nombreGestGrupo = new Map<String, SEG_Gestor_Grupo__c>();

            for (SEG_Gestor_Grupo__c grupoGestor : gruposGestores){
                for(String nombre : mapaIdGestor.values()){ 
                    if (nombre == grupoGestor.SEG_EmpleadoGestor__r.FirstName){
                        nombreGestGrupo.put(nombre, grupoGestor);
                    }	
                }
            }
            for(Id caseId : mapaIdGestor.keySet()){ 
                if(nombreGestGrupo.containsKey(mapaIdGestor.get(caseId))){
                    system.debug('estopy en el if contains kety ' + nombreGestGrupo.get(mapaIdGestor.get(caseId)));
                    mapNewObj.get(caseId).SEG_Grupo_BO_Gestor_Comercial__c = nombreGestGrupo.get(mapaIdGestor.get(caseId)).SEG_GrupoOperativa__r.Name;
                }	
                else{
                    system.debug('estopy en el else contains kety ' + nombreGestGrupo.get(mapaIdGestor.get(caseId)));
					mapNewObj.get(caseId).SEG_Grupo_BO_Gestor_Comercial__c = '';
				}
            }
        }
    }
}