public with sharing class CC_MCC_Preclasificacion {
    @InvocableMethod
    public static void preclasificarCasos(List<Id> idsChats) {
        Set<Id> idsChatsSet = new Set<Id>(idsChats);
        List<LiveChatTranscript> objChats = [SELECT Id, CC_Espacio__c, OwnerId, CC_Categoria__c, CaseId, CC_Tipo__c, CC_Chat_Transferido__c, CC_Espacio_Transfer__c, CC_Categoria_Transfer__c, CC_Aplicacion_Origen__c  FROM LiveChatTranscript WHERE Id IN :idsChatsSet];
        preclasificarCasosObj(objChats);
    }
    
    
    public static void preclasificarCasosObj(List<LiveChatTranscript> objChats) {
        Map<Id, LiveChatTranscript> mapaCasoChat = new Map<Id, LiveChatTranscript>();
        List<Case> casosActualizar = new List<Case>();
        for (LiveChatTranscript chat : objChats) {
            mapaCasoChat.put(chat.CaseId, chat);
        }    
    
        List<Id> idsCasos = new List<Id>();
        for (Case caso : [SELECT Id, OwnerId, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_Canal_Procedencia__c, Status FROM Case WHERE Id IN :mapaCasoChat.keySet()]) {
            if ((caso.Status!='Cerrado') && (caso.Status!='Rechazado')){
                idsCasos.add(caso.Id);
                Boolean chatTransferido = mapaCasoChat.get(caso.Id).CC_Chat_Transferido__c;
                //String espacio = mapaCasoChat.get(caso.Id).CC_Espacio__c;
                //String categoria = mapaCasoChat.get(caso.Id).CC_Categoria__c;
                String espacio = '';
                String categoria = '';
                if(chatTransferido){
                    espacio = mapaCasoChat.get(caso.Id).CC_Espacio_Transfer__c;
                     
                    if(String.isBlank(espacio)){
                    	espacio = mapaCasoChat.get(caso.Id).CC_Espacio__c;    
                    }
                    categoria = mapaCasoChat.get(caso.Id).CC_Categoria_Transfer__c;
                    if(String.isBlank(categoria)){
                   		categoria = mapaCasoChat.get(caso.Id).CC_Categoria__c; 
                    }
                }else{
                    espacio = mapaCasoChat.get(caso.Id).CC_Espacio__c;
                    categoria = mapaCasoChat.get(caso.Id).CC_Categoria__c;
                }

                
                Map<String, String> mapaClasificacionEquivalente = CC_MCC_Metodos.obtenerClasificacionEquivalente(espacio, categoria);
                caso.CC_MCC_Tematica__c = mapaClasificacionEquivalente.get('Temática');
                caso.CC_MCC_ProdServ__c = mapaClasificacionEquivalente.get('Producto');
                caso.CC_MCC_Motivo__c = null;
                caso.CC_MCC_Causa__c = null;
                caso.CC_MCC_Solucion__c = null;
        
                if (mapaClasificacionEquivalente.get('Canal de procedencia') != null & chatTransferido == false) {
                    if(mapaCasoChat.get(caso.Id).CC_Aplicacion_Origen__c != 'Whatsapp'){
                    caso.CC_Canal_Procedencia__c = mapaClasificacionEquivalente.get('Canal de procedencia');
                    }
                }
                if(mapaClasificacionEquivalente.get('Canal de procedencia') != null && mapaCasoChat.get(caso.Id).CC_Aplicacion_Origen__c != 'Whatsapp'){
                    caso.CC_Canal_Resolucion__c = mapaClasificacionEquivalente.get('Canal de procedencia');
                }
                
                caso.OwnerId = mapaCasoChat.get(caso.Id).OwnerId;
                casosActualizar.add(caso);
            }
        }
        if(!casosActualizar.isEmpty()){
            update casosActualizar;
            CC_Encuestas_Chat.generarEncuesta(casosActualizar);
        }
    }
    
}