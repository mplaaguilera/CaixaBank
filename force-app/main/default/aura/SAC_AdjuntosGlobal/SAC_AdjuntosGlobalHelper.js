({
    actualizaSeleccionadosCase : function(component, event) {
        let strBusqueda = component.get('v.busqueda');
        let ficherosVisiblesCase = component.get('v.ficherosAdjuntosCase');
        let ficherosAdjuntosFiltradoCase = [];
        let pills = component.get('v.pills');
        let ficheroSeleccionadoCase = false;

        for(let i = 0; i < ficherosVisiblesCase.length; i++){
            ficheroSeleccionadoCase = false;
            for(let j = 0; j < pills.length; j++){
                if(ficherosVisiblesCase[i].ContentDocumentId == pills[j].id){
                    ficheroSeleccionadoCase = true;
                }
            }
            ficherosVisiblesCase[i].seleccionado = ficheroSeleccionadoCase;
        }
        
        for(let i = 0; i < ficherosVisiblesCase.length; i++){
            if(ficherosVisiblesCase[i].Title.includes(strBusqueda)){
                ficherosAdjuntosFiltradoCase.push(ficherosVisiblesCase[i]);
            }
        }
        component.set('v.ficherosAdjuntosCase',ficherosVisiblesCase);
        component.set('v.ficherosAdjuntosVisiblesCase', ficherosAdjuntosFiltradoCase);

        let idsFicherosAdjuntos = [];
        pills.forEach(file => idsFicherosAdjuntos.push((file.id)));
        component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
    },

    actualizaSeleccionados : function(component, event) {
        let strBusqueda = component.get('v.busqueda');
        let ficherosAdjuntosFiltrado = [];
        let ficherosVisibles = component.get('v.ficherosAdjuntos');
        let pills = component.get('v.pills');
        let ficheroSeleccionado = false;

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
        component.set('v.ficherosAdjuntosVisibles', ficherosAdjuntosFiltrado);

        let idsFicherosAdjuntos = [];
        pills.forEach(file => idsFicherosAdjuntos.push((file.id)));
        component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
    },
    cambioIconoVisibilidad: function(component, contentVersion, oculto) {
        let ficherosVisibles = component.get('v.ficherosAdjuntos');
        let ficherosAdjuntosFiltrado = component.get('v.ficherosAdjuntosVisibles');
        let ficherosVisiblesCase = component.get('v.ficherosAdjuntosCase');
        let ficherosAdjuntosFiltradoCase = component.get('v.ficherosAdjuntosVisiblesCase');

        var index = ficherosVisibles.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosVisibles[index].SAC_Oculto__c = oculto;
        }
        
        index = ficherosAdjuntosFiltrado.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosAdjuntosFiltrado[index].SAC_Oculto__c = oculto;
        }

        index = ficherosVisiblesCase.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosVisiblesCase[index].SAC_Oculto__c = oculto;
        }

        index = ficherosAdjuntosFiltradoCase.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosAdjuntosFiltradoCase[index].SAC_Oculto__c = oculto;
        }

        component.set('v.ficherosAdjuntos',ficherosVisibles);
        component.set('v.ficherosAdjuntosVisibles', ficherosAdjuntosFiltrado);
        component.set('v.ficherosAdjuntosCase',ficherosVisiblesCase);
        component.set('v.ficherosAdjuntosVisiblesCase', ficherosAdjuntosFiltradoCase);

    }
})