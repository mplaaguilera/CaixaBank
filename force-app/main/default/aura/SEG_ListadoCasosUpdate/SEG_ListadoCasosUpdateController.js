({
    
    
	doInit : function(component, event, helper) {
      	let user = component.get("v.User");
        let cases = component.get('c.getCaseList');
       
        let getCaseList = component.get('c.getCaseList');
		//getCaseList.setParam('caseId', component.get('v.User'));
		getCaseList.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					values.push({ label: result[key].CaseNumber, value: key });
				}
    			
				component.set('v.caseList', values);
			}
		});
		$A.enqueueAction(getCaseList);

	},
        
    setCaseData : function(component){
            component.set('v.columnasAnexos', [
			{
				label: 'Título', fieldName: 'ContentUrl', type: 'url',
				typeAttributes: {label: {fieldName: 'Title'}, target: '_blank'}
			},
			//{label: "Título", fieldName: "Title", type: "text"},
			{label: 'Extensión', fieldName: 'FileExtension', type: 'text'}
		]);
		//Llamada al helper para rellenar datos de la tabla anexos
		//helper.setDataAnexos(component);
		//component.set('v.rendermostrarModalCasosHijos', true);
        
    },
            
    getUser : function(component, event, helper){
        let user = component.get('c.getCurrentUser');
        user.setCallback(this, function(v) {
            
            component.set("v.User", v.getReturnValue());

        });
        $A.enqueueAction(user);
    },
        
    viewCase : function(component, event){ 
        var ctarget = event.currentTarget;
   		var id_str = ctarget.dataset.value;
        //https://caixabankcc--devboseg01.lightning.force.com/lightning/r/Case/5005r0000039kYRAAY/view
        //https://caixabankcc--devboseg01.lightning.force.com/one/one.app#
        //https://caixabankcc--devboseg01--c.vf.force.com/apex/SEG_SeguirCaso?wrapMassAction=1&use307redirect=true&tour=&isdtp=p1&sfdcIFrameOrigin=https://caixabankcc--devboseg01.lightning.force.com&sfdcIFrameHost=web&nonce=3aed40cdd12f31803ecf9b81ba17a469735dcaf4a737a90d2dbf4edee4c1f9e0&ltn_app_id=06m5r0000008XI5AAM&clc=1
        var data;
		let urlpath = window.location.href;
		let urlpathsplit = urlpath.split("--c.vf.force");
		urlpath = urlpathsplit[0];
		urlpath = urlpath + '.lightning.force.com/lightning/r/Case/' + id_str + '/view';
        window.open(urlpath, '_blank').focus();
    },
       

        
    dejarDeSeguir : function(component, event, helper) {
        let target = event.currentTarget.dataset.value;
        var deleteSub = component.get('c.deleteSubscription');
        deleteSub.setParam('caseId', target);
        deleteSub.setCallback(component,
            function(response) {
                var state = response.getState();
                if (state === 'SUCCESS'){
                    //$A.get('e.force:refreshView').fire();
                    let getCaseList = component.get('c.getCaseList');
					getCaseList.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						let values = [];
						let result = response.getReturnValue();
						for (let key in result) {
							values.push({ label: result[key].CaseNumber, value: key });
						}
				component.set('v.caseList', values);
			}
		});
		$A.enqueueAction(getCaseList);
                } else {
                     // Handle the 'ERROR' or 'INCOMPLETE' state
                }
            }
        );
        $A.enqueueAction(deleteSub);
    },
        
        
    
    closeTab : function(component) {
        /*
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });	*/
        
		window.history.back();        
	}
})