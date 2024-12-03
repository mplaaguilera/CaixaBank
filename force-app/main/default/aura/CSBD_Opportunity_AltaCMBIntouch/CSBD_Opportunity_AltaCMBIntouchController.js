({
  init : function(component, event, helper) {
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    component.set('v.today', today);
  },  
  
  enviar: function(component, event, helper){

    if(component.find('nombreCliente').get('v.value')==='' || component.find('DNICliente').get('v.value')==='' || component.find('fechaContacto').get('v.value')===null ||
      component.find('tramoHorario').get('v.value')==='' || component.find('codigoProducto').get('v.value')==='' ||
      component.find('operativa').get('v.value')==='' || component.find('numeroContrato').get('v.value')==='' || component.find('descripcion').get('v.value')===''){
        helper.mostrarToast('warning', 'Campos vacíos', 'Por favor, informe todos los campos del formulario');
    }
    else{

      let button = event.getSource();
      button.set('v.disabled',true);


      let altaCMB = component.get('c.altaCMBIntouch');
      altaCMB.setParams({
        'nombreCliente': component.find('nombreCliente').get('v.value'),
        'DNICliente': component.find('DNICliente').get('v.value'),
        'fechaContacto': component.find('fechaContacto').get('v.value'),
        'tramoHorario': component.find('tramoHorario').get('v.value'),
        'codigoProducto': component.find('codigoProducto').get('v.value'),
        'operativa': component.find('operativa').get('v.value'),
        'numeroContrato': component.find('numeroContrato').get('v.value'),
        'descripcion': component.find('descripcion').get('v.value')
      });
      altaCMB.setCallback(this, response => {
        if (response.getState() === 'SUCCESS') {
          helper.mostrarToast('success', 'Solicitud enviada con éxito', 'Su solicitud será revisada por un gestor del Centro 4223');
          $A.get('e.force:refreshView').fire();
        }
        else if (response.getState() === "ERROR") {
          helper.mostrarToast('error', 'Error al enviar la solicitud', 'Su solicitud no ha podido ser enviada. Por favor, vuelta a intentarlo o contacte con su administrador');
          var errors = response.getError();
          if (errors) {
              if (errors[0] && errors[0].message) {
                  console.log("Error message: " +
                    errors[0].message);
              }
          } else {
              console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(altaCMB);
    }
  }
})