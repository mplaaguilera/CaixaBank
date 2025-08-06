({
    doInit: function (component, event, helper) {
        var texto_badge = component.get("v.text");
        texto_badge = texto_badge.toLowerCase();
        var enteredValue = component.get("v.enteredValue");
        //Se ignoran los espacios consecutivos y los espacios al inicio y final de la cadena
        enteredValue = enteredValue.toLowerCase().trim().replace(/\s+/g, ' ');
        var terminos_busqueda = enteredValue.split(" ");
        var encontrado = false;
                
		for (var i = 0; i < terminos_busqueda.length && !encontrado; i++) {
            if (texto_badge.includes(terminos_busqueda[i])) {
                encontrado = true;
            }
        }
        
        component.set("v.destacar", encontrado);
	}
})