({
    buscarlabel : function(lOpciones, vId) {
        try {
            var toFind = vId;
            var lista = lOpciones;
            var filtered = lista.filter(function(el) {
                return el.value === toFind;
            });
            console.log(filtered);
            console.log(filtered[0]);
            return(filtered[0].label);
        }
        catch(e){
            alert(vId);
        }
    }
})