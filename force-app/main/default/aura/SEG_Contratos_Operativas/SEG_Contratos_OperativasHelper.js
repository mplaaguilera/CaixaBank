({
	reinit : function(component) {
        
        var getCaso = component.get('c.recuperarContrato');
        getCaso.setParam('contratoId', component.get('v.recordId'));
        
        getCaso.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				
                component.set('v.caso', response.getReturnValue());
                //Get userId
                var getUser = component.get('c.recuperarUser');

                getUser.setCallback(this, function(response){
                
                	component.set('v.user', response.getReturnValue());
                });º
				$A.get('e.force:refreshView').fire();
				$A.enqueueAction(getUser); 
        	}            
        });
        
		$A.enqueueAction(getCaso); 
	},
	
	closeLightningTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
       })
        .catch(function(error) {
            console.log(error);
        });
    
	 },

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': 4000});
		toastEvent.fire();
	},

	abrirTab: function(component, tabRecordId) {
		component.find('workspace').openTab({'recordId': tabRecordId, 'focus': true});
		component.find('caseData').saveRecord($A.getCallback(() => {}));
	},
	setDataAnexos: function(component){
		var data;
		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.recordId'));
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.dataAnexos', response.getReturnValue());
			}
		});
		$A.enqueueAction(getAnexos);
	},
	fetchEmail: function(component){
		
		var actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.recordId'));
		actionEm.setCallback(this, function(response){
			var values=[];
			var result = response.getReturnValue();
			for(var key in result){
				values.push({
					label:result[key],
					value:key});
				
			}
			component.set('v.Emailcaso', values);
			
		});
		
		$A.enqueueAction(actionEm);
	},

	fetchEmailcaso: function(component){
		
		var actionEm = component.get('c.fetchContratoCaso');
		actionEm.setParam('contratoId', component.get('v.recordId'));
		actionEm.setCallback(this, function(response){
			var values=[];
			var result = response.getReturnValue();
			for(var key in result){
				values.push({
					label:result[key],
					value:key});
				
			}
			component.set('v.casNum', values);
			
		});
		
		$A.enqueueAction(actionEm);
	}
});