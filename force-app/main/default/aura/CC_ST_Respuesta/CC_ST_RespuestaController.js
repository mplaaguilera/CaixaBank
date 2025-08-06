({
	doInit : function(component, event, helper) 
    {
        console.log('in doinit');
        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
        var action = component.get("c.getItem");
        console.log(component.get("v.recordId"));
        action.setParams({CaseId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            var rec = response.getReturnValue();
            console.log(rec);
            if(rec!=null)
            {
                var caseExist;
                if(rec.Case__c == '' || rec.Case__c == undefined)
                    caseExist = false;
                else
                    caseExist = true;
                if($A.util.isUndefinedOrNull(rec.Image_Id__c))
                {
                    //console.log('####true');
                }
                else
                {
                    console.log('false######');
                    component.set("v.imageContentId",rec.Image_Id__c);
                }
                var output = {};
                component.set("v.AppReviewsID",rec.Id);
                component.set("v.AuthorName",rec.Author_Name__c);
                component.set("v.Title",rec.Title__c);
                component.set("v.Rating",rec.Rating__c);
                component.set("v.Content",rec.Content__c);
                component.set("v.AppName",rec.App__c);
                component.set("v.App_ID",rec.App_ID__c);
                component.set("v.ImgURL",rec.App_Image__c);
                component.set("v.ReviewId",rec.Review_ID__c);
                component.set("v.Fecha",rec.Fecha__c); 
                component.set("v.Version",rec.Version__c); 
                component.set("v.Source",rec.Source__c);
                component.set("v.caseExist",caseExist);
                if (caseExist) {
                    component.set("v.CaseId",rec.Case__c);
                    component.set("v.CaseNumber",rec.Case__r.CaseNumber);
                    component.set("v.CaseStatus",rec.Case__r.Status);
                    component.set("v.Origin",rec.Case__r.Origin);
                    component.set("v.CaseIdioma",rec.Case__r.CC_Idioma__c)
                }
                // Si es Apple recuperar el mensaje automático y ponerlo en el cuerpo para que el agente pueda copiar
                if ( rec.Rating__c == "4" || rec.Rating__c == "5" ) {
                    var idioma = '';
                    if (caseExist) {
                        idioma = rec.Case__r.CC_Idioma__c;
                    }
                    var action2 = component.get("c.recuperaMensajeAutomatico");
                    //TODO: Falta servicio Cognitive para recuperar idioma
                    action2.setParams({
                        idioma : idioma,
                        nombre : rec.Author_Name__c,
                        aplicacion: rec.App__c
                    });
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var mensaje = response.getReturnValue();
                            component.find('inputF').set("v.value",mensaje);
                        }
                    })
                    $A.enqueueAction(action2);
                }
            }
        });
        $A.enqueueAction(action);
    },
    RespuestaStore : function(component, event, helper) {
        var textForCopy = component.find('inputF').get("v.value");
        var LastMsg = component.get("v.LastMsg");
        var source = component.get("v.Source");
        
        // calling common helper class to copy selected text value
        helper.copyTextHelper(component,event,textForCopy);
        component.find('inputF').set("v.value","");
        $A.util.addClass(component.find("Respuesta"), "slds-hide");
        $A.util.removeClass(component.find("BotonRespuesta"), "slds-hide");
        
        if ((textForCopy.length >0) && (textForCopy != LastMsg)) {
            var action = component.get("c.createSocialPost");
            action.setParams({Review_ID : component.get("v.ReviewId"),
                              CaseId : component.get("v.recordId"),
                              Author_Name : component.get("v.Source"),
                              Content : textForCopy,
                              Title : "Respuesta a cliente",
                              MessageType : "Reply",
                              IsOutbound : true,
                              salvar : true
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                //Si success confirmación publicación, sino error comunicación
				if (state === "SUCCESS") {
                    console.log(state);
                    component.set("v.LastMsg",textForCopy);
                    var type = "success";
                    helper.displayToast(component,source, type);
                    // Update Case fecha respuesta Stores
                    var action2 = component.get("c.actualizaCasoFechaRespuesta");
                    action2.setParams({CaseId : component.get("v.recordId")});
                    action2.setCallback(this, function(response) {
                        var stateFecha = response.getState();
                        console.log(stateFecha);
                    });
                    $A.enqueueAction(action2);
                    // Update AppReview la respuesta que se le da al cliente
                    var action3 = component.get("c.actualizaComentarioAppReview");
                    action3.setParams({AppReviewId : component.get("v.AppReviewsID"),
                                       comRespuesta : textForCopy});
                    action3.setCallback(this, function(response) {
                        var stateFecha = response.getState();
                        console.log(stateFecha);
                    });
                    $A.enqueueAction(action3);
                    // Enviamos respuesta al comentario del cliente de las Stores
                    if (source != 'Apple App Store'){
                        var action4 = component.get("c.replyAppGoogleReview");
                        action4.setParams({packageName : component.get("v.App_ID"),
                                           reviewId : component.get("v.ReviewId"),
                                           reviewSource : source,
                                           replyText : textForCopy});
                        action4.setCallback(this, function(response) {
                            var stateFecha = response.getState();
                            console.log(stateFecha);
                        });
                        $A.enqueueAction(action4);
	                }
                    $A.get('e.force:refreshView').fire();
                } else{
                    var type = "error";
                    helper.displayToast(component,source, type);
                }
            });
            $A.enqueueAction(action); 
        }        
    },
    Habilitar_respuesta : function(component, event, helper) {

        $A.util.removeClass(component.find("Respuesta"), "slds-hide");
        $A.util.addClass(component.find("BotonRespuesta"), "slds-hide");

    },
    buscarTabuladaStore : function(component, event, helper) {
        var open = component.get('c.abrirModal');
       	$A.enqueueAction(open);
        
    	var action = component.get("c.buscarTabuladaStores");
    	action.setParams({CaseId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oTabuladas = response.getReturnValue();
                if (oTabuladas !== null){
                    // Hay tabuladas
					if (oTabuladas.length > 0){
						component.set("v.oTabuladas", oTabuladas);
                    }
                }
            }
        });
		$A.enqueueAction(action); 
    },
    abrirModal : function(component, event, helper){
		var modalboxColab = component.find('Modalbox');
        $A.util.addClass(modalboxColab, 'slds-fade-in-open');  
        var modalbackdrop = component.find('Modalbackdrop');
        $A.util.addClass(modalbackdrop, 'slds-backdrop--open'); 
    },
    cerrarModal: function(component, event, helper){  
        var cmpTarget = component.find('Modalbox');        
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        var modalbackdrop = component.find('Modalbackdrop');
        $A.util.removeClass(modalbackdrop, 'slds-backdrop--open');     
        //$A.get('e.force:refreshView').fire();
    },
    selTabulada: function(component, event, helper){
        var sTabulada = event.getSource().get("v.name");
        component.find('inputF').set("v.value",sTabulada);
        var close = component.get('c.cerrarModal');
       	$A.enqueueAction(close);
    }
})