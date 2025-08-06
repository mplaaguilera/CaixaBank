({   
	onWorkAssigned: function () {
        
        var sTitulo = 'Nueva interacción';
        var sIcono = 'https://pbs.twimg.com/media/CwMtj4BWEAAFuFe.png';
        var sCuerpo = 'Tienes una nueva interacción asignada para gestionar en Salesforce.';
        var sModo = 'dismissible';
        var sTipo = 'success';
        var sTiempoNot = '30000';
        
        /* Se desactiva por ahora.
        // Notificación Toast.
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: sTipo,
            message: sCuerpo,
            mode : sModo,
            duration : sTiempoNot
        });
        toastEvent.fire();
        */
        
        // Notificación de navegador cuando no tiene el foco.
        if (document.hasFocus()==false)
        {
            // Let's check if the browser supports notifications
            if (!("Notification" in window)) {
              alert("This browser does not support desktop notification");
            }        
            // Let's check if the user is okay to get some notification
            else if (Notification.permission == "granted") {
              // If it's okay let's create a notification
                
                var notification = new Notification(sTitulo, {
                    icon: sIcono,
                    body: sCuerpo,
                });
                
                notification.onclick = function(x) { window.focus(); };
            }        
            // Otherwise, we need to ask the user for permission
            // Note, Chrome does not implement the permission static property
            // So we have to check for NOT 'denied' instead of 'default'
            else if (Notification.permission != 'denied') {
              Notification.requestPermission(function (permission) {
        
                // Whatever the user answers, we make sure we store the information
                if(!('permission' in Notification)) {
                  Notification.permission = permission;
                }
        
                // If the user is okay, let's create a notification
                if (permission === "granted") {
                    
                    var sTitulo = 'Nueva interacción';
                    var sIcono = 'https://pbs.twimg.com/media/CwMtj4BWEAAFuFe.png';
                    var sCuerpo = 'Tienes una nueva interacción asignada para gestionar en Salesforce.';
                    var sModo = 'dismissible';
                    var sTipo = 'success';
                    var sTiempoNot = '30000';
                    
                    var notification = new Notification(sTitulo, {
                        icon: sIcono,
                        body: sCuerpo,
                    });
                    
                    notification.onclick = function(x) { window.focus(); };
                }
              });
            }
        
            // At last, if the user already denied any notification, and you
            // want to be respectful there is no need to bother him any more.
        }
    },
	onWorkAccepted: function (component, event, helper) {
        
        //console.log("Work accepted.");
        var workItemId = event.getParam('workItemId');
        workItemId = workItemId.substring(0, 15);
        
        var action = component.get("c.getAvisosCaracteristicas");
        action.setParams({
            sID : workItemId
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var rtnValue = result.getReturnValue();
                if (rtnValue !== null && rtnValue !== '') {
                    if (rtnValue.length > 0) {
                        // Mostramos un toast para cada aviso de característica (por orden de prioridad)
                        for (var i = rtnValue.length-1; i > -1; i--) {
                            var sModo = 'dismissible';
                            var sTipo = 'warning';
                            var sTiempoNot = '15000';
                            const toastEvent = $A.get('e.force:showToast');
                            toastEvent.setParams({
                                message: rtnValue[i],
                                mode : sModo,
                                type: sTipo,
                                duration : sTiempoNot
                            });
                            toastEvent.fire();
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
        
        
        //var workId = event.getParam('workId');
        //console.log(workItemId);
        //console.log(workId);
    }
})