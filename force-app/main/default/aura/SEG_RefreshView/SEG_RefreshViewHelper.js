({
   refreshListView : function(component) {
      let navigationItemAPI = component.find("navigationItemAPI");
      navigationItemAPI.getSelectedNavigationItem()
         .then((response) => {
            // Only refresh if viewing an object-page
            const objPage = 'standard__objectPage';
            var url = window.location.href;
             
            if (response.pageReference && response.pageReference.type === objPage && url.includes('Case/list')) {
                // Do the refresh
				//$A.get('e.force:refreshView').fire();
             	navigationItemAPI.refreshNavigationItem()
                    .catch(function(error) {
                        console.log('Error in auto-refresh', error);
                });
            } 
            if (response.pageReference && url.includes('Casos_de_Segmentos')) {
                // Do the refresh
				//$A.get('e.force:refreshView').fire();
             	navigationItemAPI.refreshNavigationItem()
                    .catch(function(error) {
                        console.log('Error in auto-refresh', error);
                });
            } 
		});
    },
        
	mostrarToast: function(tipo, mensaje, modo) {
		let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({'message': mensaje, 'type': tipo, 'mode': modo});
		toastEvent.fire();
	}

})