({
    doInit : function(cmp) {
        var action = cmp.get("c.getValues");
        var recordId = cmp.get("v.recordId");
        action.setParams({            
            ChatId: recordId
        });
        action.setCallback(this, function(response) {
            var idioma = response.getReturnValue();
            cmp.set("v.idioma", idioma);
        })
        $A.enqueueAction(action);
    },
    
    onAgentMessage: function(cmp, evt){
        var content = evt.getParam('content');
        cmp.set("v.msg", "Mensaje enviado: " + content);      
        var content = evt.getParam("content");
        //evt.stopPropagation(); //Para bloquear el envío de mensajes.
        
    },   
 	onNewMessage : function(cmp, evt) {   
        var content = evt.getParam('content');
        cmp.set("v.msg", "Mensaje recibido: " + content);
	},
 	onCustomEvent : function(cmp, evt) {   
        var conversation = cmp.find("conversationKit");
        var data = evt.getParam("data");
        cmp.set("v.msg", "Evento Recibido: " + data);
        console.log(data);
	},
 	onChatEnded : function(cmp, evt) {   
        var conversation = cmp.find("conversationKit");
        var data = evt.getParam("recordId");
        console.log(data);
        console.log(evt);
        console.log(evt.getParam("disconnectedBy"));
        console.log(evt.toString());
        
        var params = evt.getParams();
        for (var f in params) {
            console.log(f + ' = ' + params[f])
        }
	},
	sendMessage : function(cmp, evt) { 
        var msg= evt.getSource().get("v.label");
        
        var conversationKit = cmp.find("conversationKit");
        var recordId = cmp.get("v.recordId");
        var recordId = recordId.substring(0, 15);
        
        conversationKit.sendMessage({
            recordId: recordId,
            message: { text: msg }
        });        
	},
    noSoportada : function(cmp, evt) {         
        var childComponent = cmp.find("compNoSoportada");
  		childComponent.refresh();
        cmp.set('v.showNoSoportada', true);
	},
    buscar : function(cmp, evt, helper) {
        var evt = $A.get("e.c:CC_LiveAgent_Event");
        var recordId = cmp.get("v.recordId");
        evt.setParams({"showBuscar": true});
        evt.setParams({"recordId": cmp.get("v.recordId")});
        
        evt.fire();
    },
    
    sendCustomEvent: function(cmp, evt, helper) {
        var conversationKit = cmp.find("conversationKit");
        var recordId = cmp.get("v.recordId");
        var recordId = recordId.substring(0, 15); 
        
        var type = "myCustomEventType";
        var data = "{color: 'red', value: '#f00'}";

        //cmp.set("v.msg", "Evento Enviado: " + data);	
        
        conversationKit.sendCustomEvent({
            recordId: recordId,
            type:type,
            data: data 
        })
        .then(function(result){
            if (result) {
                    console.log("Successfully sent custom event");
                } else {
                    console.log("Failed to send custom event");
                }
        });
    },
    handleShowModal: function(component, evt, helper) {
        var modalBody;
        $A.createComponent("c:CC_LiveAgent_NoSoportada", {},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: "Application Confirmation",
                       body: modalBody, 
                       showCloseButton: true,
                       cssClass: "mymodal",
                       closeCallback: function() {
                           //alert('You closed the alert!');
                       }
                   })
               }                               
           });
    }
})