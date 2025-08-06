({
    handleSubmit : function(component,event,helper) {
        component.find("editForm").submit();
    },
    handleSuccessMessage : function(component,event,helper) {
        
        component.find('popuplib').showCustomPopover({
            body: "FAQ Is Updated",
            referenceSelector: ".mypopover",
            cssClass: "slds-popover slds-nubbin_left"
        }).then(function (overlay) {
            setTimeout(function(){ 
                //close the popover after 3 seconds
                overlay.close(); 
            }, 3000);
        });
        
        component.find("popuplib").notifyClose();
    },
    sendFAQ: function(cmp, evt) { 
        var conversationKit = cmp.find("conversationKit");
        
        var recordId = cmp.get("v.recordIdChat");
        recordId = recordId.substring(0, 15);
        var vinculo = cmp.get("v.vinculo");
        var faqCa = cmp.get("v.faqCa");
        var faqEs = cmp.get("v.faqEs");
        var idioma = cmp.get("v.idioma");
         
        if (faqCa != '' && idioma =='ca') {
            conversationKit.sendMessage({
                recordId: recordId, 
                message: {text: faqCa }
            });
        }
        if (faqEs != '' && idioma =='es') {                
            conversationKit.sendMessage({
                recordId: recordId, 
                message: {text: faqEs }
            });
        }
        if (vinculo != '') {                
            conversationKit.sendMessage({
                recordId: recordId, 
                message: {text: vinculo }
            });
        }            
    
       // helper.handleClose(cmp, event, helper);        
        
    }
})