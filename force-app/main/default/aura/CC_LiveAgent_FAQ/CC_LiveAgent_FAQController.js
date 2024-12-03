({
    init : function(cmp, event, helper) {
		var espacio = ''; 
        var categoria='';
              
        var action = cmp.get("c.getValues");        
        var recordId = cmp.get("v.recordId");     	
        action.setParams({
            chatId: recordId
        });
        
        var idioma='';
        action.setCallback(this, function(response) {
            idioma = response.getReturnValue();            
                   
            cmp.set("v.idioma", idioma);

            helper.getFAQs(cmp,espacio,categoria,idioma,searchKey);
            var searchKey= '';
        
            var controllingFieldAPI = cmp.get("v.controllingFieldAPI");
            var dependingFieldAPI = cmp.get("v.dependingFieldAPI");
            var activo = cmp.get("v.isActive");
            var objDetails = cmp.get("v.objDetail");
            // call the helper function
            helper.fetchPicklistValues(cmp,objDetails,controllingFieldAPI, dependingFieldAPI);
            
        })
         $A.enqueueAction(action);
        
    }, 
    onIdiomaChange : function(cmp, event, helper) {
        var idioma=cmp.find('idiomaselect').get('v.value');
        cmp.set("v.idioma" ,idioma);
        helper.searchKeyChange(cmp, event, helper);
    },
    
    searchKeyChange: function(cmp, event, helper) {
        helper.searchKeyChange(cmp,event, helper);
    },

    updateSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set("v.selectedRowsList" ,selectedRows);
        if (selectedRows.length>0){
            cmp.set('v.envioDisabled',false);
        }
        else{
            cmp.set('v.envioDisabled',true);
        }
    },
    
    sendFAQ: function (cmp, event,helper) {
        //var arr = cmp.get('v.data');
        var idioma =  cmp.get("v.idioma");       
        var obj =  cmp.get("v.selectedRowsList");      
        var recordIdChat = cmp.get("v.recordId");        
        var name;
        var vinculo;
        var recordId;
        var faqCa;
        var faqEs;
     
        for (var i = 0; i < obj.length; i++){                      
            recordId = obj[i].Id;
            name = obj[i].Name;  
            faqCa = obj[i].FAQCa__c;
            faqEs = obj[i].FAQEs__c;
            vinculo = obj[i].V_nculo__c;            
        }    
        
        var modalBody;
        $A.createComponent("c:CC_FAQ_Edit", {idioma: idioma, recordIdChat: recordIdChat, recordId : recordId, name : name, faqCa : faqCa, faqEs: faqEs, vinculo : vinculo},
           function(content, status) {              
               if (status === "SUCCESS") {
                   modalBody = content;
                   cmp.find('overlayLib').showCustomModal({
                       header: "Enviar FAQ",
                       body: modalBody, 
                       showCloseButton: true,
                       cssClass: "mymodal",
                       closeCallback: function() {
                           //alert('You closed the alert!');
                       }
                   })
               }                               
           });
        
        helper.handleClose(cmp, event, helper);         
        
    },
    handleClose: function(cmp, event, helper) {
        helper.handleClose(cmp, event, helper);
    },
    
    getValueFromApplicationEvent : function(cmp, event) {
        var ShowResultValue = event.getParam("showBuscar");
        var recordIdReturned = event.getParam("recordId");
        var recordId = cmp.get("v.recordId");
        if (recordId==recordIdReturned){
            cmp.set("v.isActive", ShowResultValue);
        }
        
    },
    
    onControllerFieldChange: function(component, event, helper) {    
        helper.searchKeyChange(component, event, helper);
        
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['']);
                component.set("v.objDetail.Categor_a__c", '');
            }  
            
        } else {
            component.set("v.listDependingValues", ['']);
            component.set("v.bDisabledDependentFld" , true);
            component.set("v.objDetail.Categor_a__c", '');
        }
        
    },
})