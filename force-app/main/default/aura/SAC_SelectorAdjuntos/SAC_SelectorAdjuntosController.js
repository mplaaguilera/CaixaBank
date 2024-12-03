({
    tmpInicial : function(component, event, helper) {
        var action = component.get('c.obtieneAdjuntos');
        action.setParams({'id':component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                let ficherosAdjuntos = response.getReturnValue();
                let ficherosBorrados = component.get('v.ficherosBorrados');
                var selected = [];
                component.set('v.ficherosAdjuntosOrigen', ficherosAdjuntos);


                //NGM
                //No mostramos los elementos que han sido borrados previamente en esta ejecución
                for(let i = 0; i < ficherosAdjuntos.length; i++){
                    let existe = false;
                    for(let j = 0; j < ficherosBorrados.length; j++){
                        if(ficherosAdjuntos[i].Id == ficherosBorrados[j]){
                            existe = true;
                            selected.push(ficherosAdjuntos[i].Id );
                        }
                    }
                    if (existe== false)
                    {
                        selected.push(ficherosAdjuntos[i].Id );

                    }
                }
                console.log(selected );

                component.set("v.preselectedRow", selected);

                component.set('v.ficherosAdjuntos', ficherosAdjuntos);

                let idsFicherosAdjuntos = [];
                ficherosAdjuntos.forEach(file => idsFicherosAdjuntos.push((file.contentVersionId)));
                component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
            }
            else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].pageErrors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        })

        $A.enqueueAction(action);
    },
    Inicial : function(component, event, helper) {
                let ficherosAdjuntos = component.get('v.ficherosAdjuntosOrigen');
                let ficherosBorrados = component.get('v.ficherosBorrados');
                var selected = [];

                for(let i = 0; i < ficherosAdjuntos.length; i++){
                    let existe = false;
                    for(let j = 0; j < ficherosBorrados.length; j++){
                        if(ficherosAdjuntos[i].Id == ficherosBorrados[j]){
                            existe = true;
                           // selected.push(ficherosAdjuntos[i].Id );
                        }
                    }
                    if (existe== false)
                    {
                        selected.push(ficherosAdjuntos[i].Id );

                    }
                }
                component.set("v.preselectedRow", selected);
                component.set('v.ficherosAdjuntos', ficherosAdjuntos);
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'show_details':
                helper.mostrarDetalle(component, event, row.ContentDocumentId);
                break;
            case 'delete':
                helper.removeBook(component, row);
                break;
        }
    },
    cambiaFiltro : function (component, event, helper) {
        let strBusqueda = component.get('v.busqueda');
        let ficherosAdjuntos = component.get('v.ficherosAdjuntosOrigen');
        let ficherosAdjuntosFiltrado = [];

        for(let i = 0; i < ficherosAdjuntos.length; i++){
            if(ficherosAdjuntos[i].Title.includes(strBusqueda)){
                ficherosAdjuntosFiltrado.push(ficherosAdjuntos[i]);
            }

        }
        component.set('v.ficherosAdjuntos', ficherosAdjuntosFiltrado);
        //actualizar selected
        var selected = [];
        let FicherosIncluidos = [];
        let ficherosBorrados = component.get('v.ficherosBorrados');

        for(let i = 0; i < ficherosAdjuntos.length; i++){
            let existe = false;
            for(let j = 0; j < ficherosBorrados.length; j++){
                if(ficherosAdjuntos[i].Id == ficherosBorrados[j]){
                    existe = true;
                }
            }
            if (existe== false)
            {
                selected.push(ficherosAdjuntos[i].Id );
                FicherosIncluidos.push(ficherosAdjuntos[i] );
                
            }
        }

        component.set("v.preselectedRow", selected);
        //component.set("v.ficherosAdjuntosIncluidos",FicherosIncluidos);
       

    },
    updateSelected : function(component, event, helper){
        let ficherosBorrados = component.get('v.ficherosBorrados');
        let borradosPrevia= ficherosBorrados;
        let ficherosVisibles = component.get('v.ficherosAdjuntos');
        let selectedRows = event.getParam('selectedRows');
		let borrados= [];
        let pills = [];


        for(let i = 0; i < ficherosVisibles.length; i++){
            let existe = false;
            for(let j = 0; j < selectedRows.length; j++){
                if(ficherosVisibles[i].Id == selectedRows[j].Id){
                    existe = true;
                }
            }
            if (existe== false)
            {
                borrados.push(ficherosVisibles[i].Id );
            }
        }
        
        //incluir borrado previo que no sean visibles 
        //let borradosPrevia= component.get('v.ficherosBorradosPrevia');
        for(let i = 0; i < borradosPrevia.length; i++){
            let existe = false;
            for(let j = 0; j < ficherosVisibles.length; j++){
                if(borradosPrevia[i] == ficherosVisibles[j].Id){
                    existe = true;
                }
            }
            if (existe== false)
            {
                borrados.push(borradosPrevia[i]);
            }
        }
        component.set('v.ficherosBorrados',borrados);
        let ficherosAdjuntos = component.get('v.ficherosAdjuntosOrigen');
        let FicherosIncluidos = [];
        for(let i = 0; i < ficherosAdjuntos.length; i++){
            let existe = false;
            for(let j = 0; j < borrados.length; j++){
                if(ficherosAdjuntos[i].Id == borrados[j]){
                    existe = true;
                }
            }
            if (existe== false)
            {
                FicherosIncluidos.push(ficherosAdjuntos[i] );
                pills.push({
                    type: 'icon',
                    id: ficherosAdjuntos[i].Id,
                    label: ficherosAdjuntos[i].Title,
                    iconName: 'doctype:attachment'
                });
            }
        }
        component.set("v.ficherosAdjuntosIncluidos",FicherosIncluidos);
        component.set('v.pills', pills);

    },
    mostrarDetalle: function(component, event, helper){
        console.log(event.target.name);
        var row = event.getParam('name');
        alert(row);
        helper.mostrarDetalle(component, event, row);
    },
    alerta: function(component, event, helper){
        event.preventDefault();
        alert('Remove button was clicked!');

    },
    handleRemoveOnly: function (cmp, event) {
        event.preventDefault();
        alert('Remove button was clicked!');
    },
    handleClick: function (cmp, event) {
        // this won't run when you click the remove button
        alert('The pill was clicked!');
    }
})