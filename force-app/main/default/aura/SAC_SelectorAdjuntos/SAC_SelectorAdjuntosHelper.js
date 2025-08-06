({
    mostrarDetalle : function(component, event, row) {
        component.set("v.ContentDocumentId", row);
        component.set("v.anchoTabla", 8);
        component.set("v.anchodetalle", 3);
        component.set("v.verDetalle", 'true');
    }
})