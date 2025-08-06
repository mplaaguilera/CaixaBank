({
    searchKeyChange: function(cmp, event, helper) {
        var espacio = cmp.get("v.objDetail.CC_Espacio__c"); 
        var categoria = cmp.get("v.objDetail.CC_Categoria__c"); 
        var idioma = cmp.get("v.idioma"); 
        var searchKey = cmp.get("v.search");
        
        //var searchKey = event.getSource().get("v.value"); 
        this.getFAQs(cmp,espacio,categoria,idioma,searchKey);
    },
    getFAQs : function(component,espacio,categoria,idioma,searchKey) {
        
        var action = component.get("c.getFAQs");        
        action.setParams({
            "espacio": espacio,
            "categoria" : categoria,
            "idioma": idioma,
            "searchKey": searchKey
        }); 
        
        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.data", actionResult.getReturnValue());             
        	}
            
        });
        
        if (idioma=="ca") {
            component.set('v.columns', [
                {label: 'Espacio',   fieldName: 'Espacio__c', type: 'text'},
                {label: 'Categoría', fieldName: 'Categor_a__c', type: 'text'},
                {label: 'F.A.Q.',    fieldName: 'FAQCa__c', type: 'text'},
                //{label: 'Respuesta', fieldName: 'RespuestaCa__c', type: 'text'},
                {label: 'Vínculo',   fieldName: 'V_nculo__c', type: 'url'},
                ]);
         } else {
           component.set('v.columns', [
            {label: 'Espacio',   fieldName: 'Espacio__c', type: 'text'},
            {label: 'Categoría', fieldName: 'Categor_a__c', type: 'text'},
            {label: 'F.A.Q.',    fieldName: 'FAQEs__c', type: 'text'},
            //{label: 'Respuesta', fieldName: 'RespuestaEs__c', type: 'text'},
            {label: 'Vínculo',   fieldName: 'V_nculo__c', type: 'url'},
            ]);
         }
        $A.enqueueAction(action);
    },
               
    handleClose: function(cmp, event, helper) {
        var searchKey= '';
        helper.getFAQs(cmp,searchKey);
        cmp.set('v.envioDisabled',true);
        cmp.set('v.isActive', false);
        cmp.set('v.SelectedRows', '');
        cmp.set("v.objDetail.Espacio__c" , '');
        cmp.set("v.listDependingValues", ['']);
        cmp.set("v.bDisabledDependentFld" , true);
    },
    
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");   
            
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
    },
})