public with sharing class CC_LiveAgentTransEvent_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<LiveChatTranscriptEvent>)tp.newList, tp.newMap, (List<LiveChatTranscriptEvent>)tp.oldList, tp.oldMap);
    }
    
    private void process(List<LiveChatTranscriptEvent> listNewObj, Map<Id, SObject> mapNewObj, List<LiveChatTranscriptEvent> listOldObj, Map<Id, SObject> mapOldObj) {
        try {
            //al finalizar el chat se debe generar una Actividad de Fin de Chat
            List<Task> tasks = new List<Task>();
            Set<Id> setIdsChat = new Set<Id>();
            Map<String, List<Task>> mapIdChatTask = new Map<String, List<Task>>();
            Map<String, LiveChatTranscript> mapIdChatTrans = new Map<String, LiveChatTranscript>();
            //List<LiveChatTranscript> ChatUpd = new List<LiveChatTranscript>();
            ID sRTEmpleado = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
            
            for (LiveChatTranscriptEvent eventoChat : listNewObj)  {
                setIdsChat.add(eventoChat.LiveChatTranscriptId);
            }
            
            if(setIdsChat !=null){
                
                List<LiveChatTranscript> listChat = [SELECT Id,Case.Owner.Name, Status, CaseId, CC_Tipo__c, OwnerId, CC_Categoria__c, CC_Espacio__c, CC_Id_Cognitive__c, RecordTypeId, CC_Tiempo_Pausado__c 
                                                     FROM LiveChatTranscript WHERE Id IN : setIdsChat AND RecordTypeId = :sRTEmpleado ];
                
                if(!listChat.isEmpty()){
                    List<Task> tareasChatQuery = [SELECT Id,CreatedDate,Status,Type, CC_LiveChatTranscript_Id__c FROM Task WHERE CC_LiveChatTranscript_Id__c IN :setIdsChat 
                                                  AND (Type = : 'Time Out' OR Type = : 'Fin' OR Type = 'Pausa Chat')
                                                  AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')) ];
                    
                    
                    for (Task tareaChat : tareasChatQuery) {
                        if(mapIdChatTask.containsKey(tareaChat.CC_LiveChatTranscript_Id__c)){
                            List<Task> listTareaChat = mapIdChatTask.get(tareaChat.CC_LiveChatTranscript_Id__c);
                            listTareaChat.add(tareaChat);
                            mapIdChatTask.put(tareaChat.CC_LiveChatTranscript_Id__c, listTareaChat);
                        } else {
                            List<Task> listTareaChat = new List<Task>();
                            listTareaChat.add(tareaChat);
                            mapIdChatTask.put(tareaChat.CC_LiveChatTranscript_Id__c, listTareaChat);
                        }
                    }
                    
                    for (LiveChatTranscript chatTranscript : listChat) {
                        mapIdChatTrans.put(chatTranscript.Id, chatTranscript);
                    }
                    //Set<Id> setIdChatUpd = new Set<Id>();
                    
                    for (LiveChatTranscriptEvent eventoChat : listNewObj)  {
                        if (eventoChat.Type == 'LeaveAgent' || eventoChat.Type == 'EndAgent' || eventoChat.Type == 'EndVisitor' || eventoChat.Type == 'LeaveVisitor') {
                        
                            /*if(mapIdChatTrans.containsKey(eventoChat.LiveChatTranscriptId) && eventoChat.Type == 'EndVisitor'
                               && mapIdChatTrans.get(eventoChat.LiveChatTranscriptId).Status == 'Missed' 
                               && (mapIdChatTrans.get(eventoChat.LiveChatTranscriptId).CaseId != null 
                               		&& mapIdChatTrans.get(eventoChat.LiveChatTranscriptId).Case.Owner.Name == 'Automated Process')){
                                //setIdChatUpd.add(eventoChat.LiveChatTranscriptId);
                                LiveChatTranscript chat = new LiveChatTranscript();
                                chat.Id= eventoChat.LiveChatTranscriptId;
                                chat.CC_Proveedor_Inicial_Reparto__c  = 'SIN PROVEEDOR';
                                chat.CC_Proveedor_Enrutado__c = 'SIN PROVEEDOR';
                                ChatUpd.add(chat);
                                
                            }*/
                            //Si ya existe alguna Actividad de Fin o de Time Out, no se debe crear
                            List<Task> tareasChatAux = new List<Task>();
                            if(mapIdChatTask.containsKey(eventoChat.LiveChatTranscriptId)){
                                tareasChatAux = mapIdChatTask.get(eventoChat.LiveChatTranscriptId);
                            }
                            
                            List<Task> tareasChat = new List<Task>();
                            List<Task> tareasChatPausa = new List<Task>();
                            for(Task task:tareasChatAux){
                                if(task.Type.equals('Pausa Chat')){
                                    tareasChatPausa.add(task);
                                }else{
                                    tareasChat.add(task);
                                }
                            }
                            
                            if (tareasChat.isEmpty() && !String.valueOf(mapIdChatTrans.get(eventoChat.LiveChatTranscriptId).OwnerId).startsWith('00G')) {
                                LiveChatTranscript chat = mapIdChatTrans.get(eventoChat.LiveChatTranscriptId);
                                Task nuevaActividad = new Task();
                                nuevaActividad.Status = 'Completed';
                                nuevaActividad.Priority = 'Normal';
                                nuevaActividad.WhatId = chat.CaseId;
                                nuevaActividad.OwnerId = chat.OwnerId;
                                nuevaActividad.CC_Categoria__c = chat.CC_Categoria__c;
                                nuevaActividad.CC_Espacio__c = chat.CC_Espacio__c;
                                nuevaActividad.CC_Chat_Cognitivo_Id__c = chat.CC_Id_Cognitive__c;
                                nuevaActividad.CC_LiveChatTranscript_Id__c = chat.Id;
                                nuevaActividad.Type = 'Fin';
                                if (eventoChat.Type == 'LeaveAgent' || eventoChat.Type == 'EndAgent')
                                {
                                    if(chat.CC_Tipo__c == 'Hidden')
                                    {
                                        nuevaActividad.Subject = 'Chat finalizado por agente Hidden';    
                                    }else{
                                        nuevaActividad.Subject = 'Chat finalizado por agente';    
                                    }
                                } else {
                                    if (chat.RecordTypeId == sRTEmpleado)
                                    {
                                        nuevaActividad.Subject = 'Chat finalizado por empleado';
                                    }else{
                                        nuevaActividad.Subject = 'Chat finalizado por cliente';
                                    }
                                }
                                
                                tasks.add(nuevaActividad);
                            }
                            
                            if(!tareasChatPausa.isEmpty()){
                                for(Task task:tareasChatPausa){
                                    if(task.Status == 'Open'){
                                        Long dt1Long = DateTime.now().getTime();
                                        Long dt2Long = task.CreatedDate.getTime();
                                        Long milliseconds = dt1Long - dt2Long;
                                        Integer seconds = Integer.valueOf(milliseconds / 1000);
                                        
                                        LiveChatTranscript chat = mapIdChatTrans.get(eventoChat.LiveChatTranscriptId);
                                        
                                        Integer total;
                                        if(chat.CC_Tiempo_Pausado__c == 0){
                                            total = Integer.valueOf(seconds + chat.CC_Tiempo_Pausado__c);
                                        }else{
                                            total= Integer.valueOf(seconds);
                                        }
                                        
                                        CC_LiveAgent_BotonesController.CloseActivityPausa(task.Id,eventoChat.LiveChatTranscriptId,total,seconds,'Chat abandonado');
                                    }
                                }
                            }
                        }
                    }    
                }
                
                
                if (!tasks.isEmpty()) {
                    //insert tasks;
                    CC_Activity.llamadaQueueableCrearActividades(tasks);
                }
               
                /*if (ChatUpd.size()>0) {
                    Database.update(ChatUpd, false);
                }*/
                
                
                
            }
            
        } catch (Exception e) {

            CBK_Log.error(e, 'Error en el chat recibido');
            throw e;
        }
    }
}