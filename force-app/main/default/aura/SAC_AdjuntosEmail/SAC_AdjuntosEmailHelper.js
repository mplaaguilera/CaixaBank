({
    actualizaSeleccionados : function(component, event) {
        let strBusqueda = component.get('v.busqueda');
        let ficherosAdjuntosFiltrado = [];
        let ficherosVisibles = component.get('v.ficherosAdjuntos');
        let ficherosValidados = component.get('v.validateItems');
        let pills = component.get('v.pills');
        let ficheroSeleccionado = false;
        let pillsDerivacion = component.get('v.pillsDervacionAdj');

        if(component.get('v.adjuntosDerivar') === true  && component.get('v.derivarAQuien') === 'grupo' && component.get('v.adjCargados') === false){

            for(let i = 0; i < ficherosVisibles.length; i++){
                pillsDerivacion.push({
                    type: 'icon',
                    id: ficherosVisibles[i].ContentDocumentId,
                    label: ficherosVisibles[i].Title,
                    iconName: 'doctype:attachment',
                    origen: 'SF'
                });
            }

            if(pillsDerivacion != ''){
                component.set('v.adjCargados', true);
                pills = pillsDerivacion;
                component.set('v.pills', pills);
            }
        }
        if(component.get('v.procedencia') === 'SAC_003'){
            for(let i = 0; i < ficherosValidados.length; i++){
                ficheroSeleccionado = false;
                for(let j = 0; j < pills.length; j++){
                    if(ficherosValidados[i].ContentDocumentId == pills[j].id){
                        ficheroSeleccionado = true;
                    }
                }
                ficherosValidados[i].seleccionado = ficheroSeleccionado;
            }
            for(let i = 0; i < ficherosValidados.length; i++){
                if(ficherosValidados[i].Title.includes(strBusqueda)){
                    ficherosAdjuntosFiltrado.push(ficherosValidados[i]);
                }
            }
            component.set('v.validateItems',ficherosValidados);
        }else{
            for(let i = 0; i < ficherosVisibles.length; i++){
                ficheroSeleccionado = false;
                for(let j = 0; j < pills.length; j++){
                    if(ficherosVisibles[i].ContentDocumentId == pills[j].id){
                        ficheroSeleccionado = true;
                    }
                }
                ficherosVisibles[i].seleccionado = ficheroSeleccionado;
            }
            
            for(let i = 0; i < ficherosVisibles.length; i++){
                if(ficherosVisibles[i].Title.includes(strBusqueda)){
                    ficherosAdjuntosFiltrado.push(ficherosVisibles[i]);
                }
            }
            component.set('v.ficherosAdjuntos',ficherosVisibles);
            }

            component.set('v.ficherosAdjuntosVisibles', ficherosAdjuntosFiltrado);

            let idsFicherosAdjuntos = [];
            pills.forEach(file => idsFicherosAdjuntos.push((file.id)));

            component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
    },

    showNonValidatedPopup: function(component, event) {
        component.set('v.popupValidate', true);
    }
})