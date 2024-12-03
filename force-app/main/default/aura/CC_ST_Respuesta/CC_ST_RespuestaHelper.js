({
    copyTextHelper : function(component,event,text) {
        // Create an hidden input
        var hiddenInput = document.createElement("input");
        // passed text into the input
        hiddenInput.setAttribute("value", text);
        // Append the hiddenInput input to the body
        document.body.appendChild(hiddenInput);
        // select the content
        hiddenInput.select();
        // Execute the copy command
        document.execCommand("copy");
        // Remove the input from the body after copy text
        document.body.removeChild(hiddenInput); 
        // store target button label value
        var orignalLabel = event.getSource().get("v.label");
        // change button icon after copy text
        event.getSource().set("v.iconName" , 'utility:check');
        // change button label with 'copied' after copy text 
        event.getSource().set("v.label" , 'copied');
        
        // set timeout to reset icon and label value after 700 milliseconds 
        setTimeout(function(){ 
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard'); 
            event.getSource().set("v.label" , orignalLabel);
        }, 700);
        
    },
    // Displays the given toast message.
    displayToast: function (component, source, type) {
        var message = "";
        if (type == "success"){
            if (source == "Apple App Store"){
                message = "Respuesta copiada.";
            } else {
                message = "Respuesta enviada.";
            }
        } else {
            if (source == "Apple App Store"){
            	message = "Error al copiar el mensaje.";
            } else{
                message = "Error comunicaciones.";
            }
        }
        
		const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message,
            mode : "dismissible"
        });
        toastEvent.fire();
    }
})