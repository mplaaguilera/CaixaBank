({      
    onStatusChanged : function(component, event, helper) {
        var statusName = event.getParam('statusName');        
        var utilityAPI = component.find("utilitybar");
        utilityAPI.setUtilityLabel({ label: statusName });
        if (statusName.includes("Offline")){
            utilityAPI.setUtilityIcon ({icon:'ban'});
        } else {
        	utilityAPI.setUtilityIcon ({icon:'success'});    
        }        
    },
    onLogout : function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.setUtilityLabel({ label: "Offline" });
        utilityAPI.setUtilityIcon ({icon:'ban'});

    }, 
    onWorkAssigned : function(component, event, helper) {
        
        helper.onWorkAssigned (component, event, helper);
    }, 
    onWorkAccepted : function(component, event, helper) {
        
        helper.onWorkAccepted (component, event, helper);
    }, 
    getInput : function (component, event, helper){

        // Refresco de la pantalla. No refresca la pantalla de chat. Abrir caso a Salesforce.
        $A.get('e.force:refreshView').fire();  

        
        // Primera versión refresco TAB. En liveagentchat da problemas.
        /*           	console.log('Refrescar2');
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
            		console.log(focusedTabId);
                    workspaceAPI.refreshTab({
                    tabId: focusedTabId,
                    includeAllSubtabs: true
                });
                                 })
                .catch(function(error) {
                    console.log(error);
                });*/
    },
    doInit : function (component, event, helper) {

    },
    doInit2 : function(component, event, helper) {
        
        console.log(component.get('v.recordId'));
        
        // Get the empApi component.
        var empApi = component.find("empApi");
        
		/* Componente genérico. Nos suscribimos a todos los cambios configurados.
        var channel = '/data/';
        
        var sObjectName = 'LiveChatTranscript';
        if (sObjectName.endsWith('__c')) {
            // Custom object
            channel = channel + sObjectName.substring('0', sObjectName.length-3) + '__ChangeEvent';
        }
        else {
            // Standard object
            channel = channel + sObjectName + 'ChangeEvent';
        }
        */
        
        var channel = '/data/ChangeEvents';        
        var replayId = '-1';
        
        
        // Subscribe to an event2
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
            console.log('Usuario event ', JSON.stringify(eventReceived.data.payload.ChangeEventHeader.commitUser));
            console.log('Entidad event ', JSON.stringify(eventReceived.data.payload.ChangeEventHeader.entityName));
            console.log('Tipo event ', JSON.stringify(eventReceived.data.payload.ChangeEventHeader.changeType));
            //console.log('Registro', component.get("v.recordId"));
            //console.log('sObjectName', component.get("v.sObjectName"));
            
            var sObjeto = JSON.stringify(eventReceived.data.payload.ChangeEventHeader.entityName).split('"').join('');
            //var sObjetoScreen = component.get("v.sobjecttype");
            //console.log(sObjetoScreen);
            //sObjeto.replace(/\"([^(\")"]+)\":/g,'');
            var sUsuario = JSON.stringify(eventReceived.data.payload.ChangeEventHeader.commitUser).split('"').join('');
            //sUsuario.replace(/b/gi,'');
            var sEvento = JSON.stringify(eventReceived.data.payload.ChangeEventHeader.changeType).split('"').join('');
            //sEvento.replace(/c/gi,'');
            
            console.log('Usuario conectado2: ' + $A.get("$SObjectType.CurrentUser.Id"));
            
            console.log(sObjeto);
            console.log(sEvento);
            
            var s1 = 'Contact';
            var s2 = 'UPDATE';
            
            //helper.onReceiveNotification(component, eventReceived, sObjeto, sEvento);
            
            if (sObjeto === 'Contact' && sEvento === 'UPDATE') //&& sObjetoScreen === 'LiveChatTranscript') //&& sUsuario != $A.get("$SObjectType.CurrentUser.Id"))
            {
            	// Refrescar pantalla.
            	console.log('RefrescarXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
            	$A.get('e.force:refreshView').fire();
            
            
            	/*console.log('Refrescar2');
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
            		console.log(focusedTabId);
                    workspaceAPI.refreshTab({
                    tabId: focusedTabId,
                    includeAllSubtabs: true
                });
                                 })
                .catch(function(error) {
                    console.log(error);
                });*/
        	}
            
            /*var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
            tabId: focusedTabId,
            includeAllSubtabs: true
        });
                         })
        .catch(function(error) {
            console.log(error);
        });*/
            
            
            //console.log('Refresco2');
        }))
            .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            console.log('Subscribed to channel ', subscription.channel);
            // Save subscription to unsubscribe later
            component.set('v.subscription', subscription);
        });
        
        
        
        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console.
        /*var callback = function (message) {
            
            console.log(message);
            
            var modifiedRecords = message.data.payload.ChangeEventHeader.recordIds;
            var commitUser = message.data.payload.ChangeEventHeader.commitUser;
            var currentRecordId = component.get('v.recordId');
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            
            

            if (modifiedRecords.includes(currentRecordId)
                && commitUser != userId) {

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Someone else modified the record you're viewing!",
                    "type": "warning",
                    "mode": "sticky"
                });
                toastEvent.fire();
            }
        }.bind(this);

        // Error handler function that prints the error to the console.
        var errorHandler = function (message) {
            console.log("Received error ", message);
        }.bind(this);

        // Register error listener and pass in the error handler function.
        empApi.onError(errorHandler);

        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, callback).then(function(value) {
            console.log("Subscribed to channel " + channel);
        });*/
    }
})