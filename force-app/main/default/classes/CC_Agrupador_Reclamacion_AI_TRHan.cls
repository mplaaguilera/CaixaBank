public with sharing class CC_Agrupador_Reclamacion_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Agrupador_Reclamacion__c>)tp.newList, (Map<Id, CC_Agrupador_Reclamacion__c>)tp.newMap);
    }

    private void process(List<CC_Agrupador_Reclamacion__c> listNewObj, Map<Id, CC_Agrupador_Reclamacion__c> mapNewObj) {
        //Envio a Maximo
        envioMaximo(listNewObj);
    }

    private void envioMaximo(List<CC_Agrupador_Reclamacion__c> listNewObj) {
        List<Id> listAgrupadoresActualizar = new List<Id>();
        for (CC_Agrupador_Reclamacion__c agrupador : listNewObj) {
            if(agrupador.CC_Enviado__c == false){
                listAgrupadoresActualizar.add(agrupador.Id);
            }
        }
        if(!listAgrupadoresActualizar.isEmpty()){
            //Llamar al metodo de envio a Maximo
            CC_WS_Methods_Maximo.enviarReclamacionMAXIMO(listAgrupadoresActualizar);
        }
        
    }
}