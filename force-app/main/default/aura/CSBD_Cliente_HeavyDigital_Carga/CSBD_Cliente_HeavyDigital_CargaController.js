({
	handleClickCancelar : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
	handleClickAceptar : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
	handleShowLogToast : function(component, event, helper) {
        var myData = event.getParam('myData');
        var logUrl = myData[0];
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            title: 'Carga finalizada',
            message: 'Informe', // you will need to keep this attribute
            type: 'success',
            key: 'utility:check',
            messageTemplate: 'Descargue el informe {0}',
            messageTemplateData: [
                {
                    url: logUrl,
                    label: 'aquí'
                }
            ]
        });
        toastEvent.fire();
    } 
})