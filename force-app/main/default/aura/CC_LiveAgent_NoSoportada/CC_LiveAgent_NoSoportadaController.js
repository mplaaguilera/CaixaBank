({
     doInit : function(component) {
         
        var action = component.get("c.getMensajesChat");
        action.setParams({
            sCodigoMsj : 'No Soportada',
            idioma : component.get("v.idioma"),
            //oGlobalIds : component.get("v.oIdentGlobales"),
            oGlobalIds : null,
            sOrigen : component.get("v.origen"),
            sAreaChat : component.get("v.areaChat")
        });
         
        action.setCallback(this, function(response) {
            
            var list = response.getReturnValue();
            if (list !== null)
            {
                if (list.length > 0){
                    var msgCognitivo = [];
                    var auto = [];
                    var codCognitive;
                    
                    codCognitive = list[0].CC_Codigo_Cognitive__c;
                    for(var i = 0; i < list.length; i++){
                        msgCognitivo.push(list[i].CC_Respuesta_Mensaje_Automatico_es__c);
                        auto.push(list[i].CC_Mensaje_Agente_es__c);
                    }
                    
                    list = msgCognitivo;
                    component.set("v.picklistValues", list);
                    component.set("v.codCognitive", codCognitive);
                    component.set("v.auto", auto);
                } else {
                    component.set("v.picklistValues", list);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleCancel: function(cmp) {
        cmp.set('v.isActive', false);
    },
    aceptar: function(cmp) {
        var conversationKit = cmp.find("conversationKit");
        var recordId = cmp.get("v.chatId"); 
        var recordId2 = cmp.get("v.chatId");
        var recordId = recordId.substring(0, 15);
        var cognitiveId = cmp.get("v.cognitiveId");
        var caseId = cmp.get("v.caseId");
        var msgCog=cmp.get("v.picklistValues");
        var codCognitive=cmp.get("v.codCognitive");
        var autoMsg=cmp.get("v.auto");
        var autoIter = cmp.find('selectId').get('v.value');
        var auto;
        var msg;
        
        if (autoIter == '')
        {
            return;
        }
        
        auto = autoMsg[autoIter];
        msg = msgCog[autoIter];
        
        conversationKit.sendMessage({
            recordId: recordId, 
            message: { text : auto}
        });
        cmp.set('v.isActive', false);
        cmp.set("v.valor","");
        // Envio del evento a Watson
        var type = "AGENT_ACTION";
        var data2 = {
            "responseType": codCognitive, //"MSG",
            "txtMsg" : msg
        };
        var data = JSON.stringify(data2);
        conversationKit.sendCustomEvent({
            recordId: recordId,
            type:type,
            data: data 
        }).then(function(result){
            console.log('OK');
        }, function(result){
            console.log('KO');
        });
        // Crear la actividad de No Soportada
        var action = cmp.get("c.ActivityNoSoportada");
        action.setParams({
            recordId : caseId,
            comentario : msg,
            cognitiveId : cognitiveId,
            subject : "Chat - No Soportada",
            transcriptId : recordId2
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})