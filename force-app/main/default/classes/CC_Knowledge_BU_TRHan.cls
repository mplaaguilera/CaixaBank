public with sharing class CC_Knowledge_BU_TRHan extends CC_TriggerHandlerBase{
    
    public override void mainEntry(CC_TriggerParameters tp) {
        
     process((List<Knowledge__kav>)tp.newList, (Map<Id, Knowledge__kav>)tp.newMap, (List<Knowledge__kav>)tp.oldList, (Map<Id, Knowledge__kav>)tp.oldMap);
    }

    private void process(List<Knowledge__kav> listNewObj, Map<Id, Knowledge__kav> mapNewObj, List<Knowledge__kav> listOldObj, Map<Id, Knowledge__kav> mapOldObj) {
        Id idRtInformacionGeneral = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Informacion_General').getRecordTypeId();
        Id idRtCCProcedimiento = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Procedimiento').getRecordTypeId();
        Id idRtCCArbol = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Arbol_Decision').getRecordTypeId();
        Id idRtCCFicha = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Ficha_Producto').getRecordTypeId();
        Id idRtCCPregunta = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Pregunta_Respuesta').getRecordTypeId();
        Id idRtCCVideo = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Video').getRecordTypeId();

        List<Id>listaCC = new List<Id>();
        listaCC.add(idRtInformacionGeneral);
        listaCC.add(idRtCCArbol);
        listaCC.add(idRtCCProcedimiento);
        listaCC.add(idRtCCFicha);
        listaCC.add(idRtCCPregunta);
        listaCC.add(idRtCCVideo);

    //Procedemos a asignar como propietario de los knowledge la cola para que los agregados a la cola tengan permisos de editar por código
    List<Group> colasKnowledge = [SELECT id, DeveloperName  FROM Group WHERE DeveloperName IN ('CC_Knowledge_Cliente','CC_Knowledge_Empleado') and Type = 'Queue'];
    id colaKnowledgeCliente;
    id colaKnowledgeEmpleado;
        if(!colasKnowledge.isEmpty()){
        for (Group g : colasKnowledge)
        {
            if (g.DeveloperName == 'CC_Knowledge_Cliente'){
              	colaKnowledgeCliente = g.id;  
            }else if(g.DeveloperName == 'CC_Knowledge_Empleado'){
                colaKnowledgeEmpleado = g.id;
            }   
        }
            
        for (Knowledge__kav k : listNewObj){
            if(k.CC_Tipo__c != null && !listaCC.isEmpty()){
        		if (k.CC_Tipo__c == 'Cliente' && k.OwnerId != colaKnowledgeCliente && k.PublishStatus == 'Draft' && listaCC.contains(k.recordTypeId)){
            		k.OwnerId = colaKnowledgeCliente;
        		}else if(k.CC_Tipo__c == 'Empleado' && k.OwnerId != colaKnowledgeEmpleado && k.PublishStatus == 'Draft'&& listaCC.contains(k.recordTypeId)){
            		k.OwnerId = colaKnowledgeEmpleado;
        		}
        	}    
    	}
    }
        
    
}

}