({
    selectOffice : function(component, event) {
        component.set("v.accountId", event.target.getAttribute("data-placeid"));
        component.set("v.sBusqueda", event.target.getAttribute("data-placeName"));
        let sCuenta = event.getSource().get('v.name');
            //component.set('v.bEsperaSFDC', true);
        component.set('v.accountId',sCuenta);
    }
})