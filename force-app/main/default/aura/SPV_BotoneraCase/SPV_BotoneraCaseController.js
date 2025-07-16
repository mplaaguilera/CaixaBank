({
    derivacion: function (component) {
        component.set("v.derivar", true);
    },
    
    cerrarDerivar: function (component) {
        component.set("v.derivar", false);
    }
})