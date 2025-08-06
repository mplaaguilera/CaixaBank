({
    validarReclamante : function(component, event, helper){
        let cuenta = component.get('v.cuentaId');
        let contacto = component.get('v.contactoId');
        if(cuenta==null || cuenta == '' ||  contacto == null || contacto == '')
        {
            component.set('v.errorStep',true);
            component.set('v.mensajeError','No ha informado los datos del reclamante.');
        }
        else
        {
            component.set('v.errorStep',false);
            component.set('v.mensajeError','');
        }
    },
    validarRepresentante : function(component, event, helper){
        let rperesentante = component.get('v.verRepresentante');
        if(!rperesentante)
        {
            component.set('v.TipoDeRepresentante','');
            component.set('v.TipoDeDocumentoRepresentante','');
            component.set('v.NombreRepresentante','');
            component.set('v.EmailRepresentante','');

            component.set('v.DespachoRepresentante','');
            component.set('v.NumeroDelDocumentoRepresentante','');
            component.set('v.DireccionPostalRepresentante','');
            component.set('v.TelefonoRepresentante','');
            
            component.set('v.errorStep',false);
            component.set('v.mensajeError','');


        }
        else
        {
            let tipoDoc = component.get('v.TipoDeDocumentoRepresentante');
            let nomRep = component.get('v.NombreRepresentante');
            if(tipoDoc==null || tipoDoc == '' ||  nomRep == null || nomRep == '')
            {
                component.set('v.errorStep',true);
                component.set('v.mensajeError','No ha informado los datos del representante.');
            }
        }

    }

})