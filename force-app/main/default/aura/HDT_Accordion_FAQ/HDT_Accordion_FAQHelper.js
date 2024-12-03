({
	getPicklistEspacio: function(cmp,event,helper) {   
        var espacio = cmp.get("v.espacio");
        var idioma = cmp.get("v.idioma");
        var aplicacion = cmp.get("v.aplicacion");
        var action = cmp.get("c.getValuesPicklistEspacios");  
        action.setParams({
            'idioma': idioma,
            'espacio' : espacio,
            'aplicacion' : aplicacion
                        
        });
        action.setStorable();
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var options = response.getReturnValue();
				cmp.set("v.picklistFirstOptionsEspacio", options);
            }
        });
        $A.enqueueAction(action); 
    },
    
    getPicklistCategoria: function(cmp,event,helper) {
        //alert('categoria');
        var espacio = cmp.get("v.espacio");   
        var categoria = cmp.get("v.categoria");
        var aplicacion = cmp.get("v.aplicacion");

        var action = cmp.get("c.getValuesPicklistFiltersCategoria");  
        action.setParams({
            'espacio' : espacio,
            'categoria' : categoria,
            'aplicacion' : aplicacion            
        });
        action.setStorable();
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var options = response.getReturnValue();
				cmp.set("v.picklistFirstOptionsCategoria", options);
            }
        });
        $A.enqueueAction(action); 
    },
    searchKeyChange: function(cmp, event, helper, bResetSearch) {
        
        var espacio = cmp.get("v.espacio");
        var categoria = cmp.get("v.categoria");
		var areaChat = cmp.get("v.areaChat");
        var idioma = cmp.get("v.idioma");   
        var searchKey = cmp.get("v.search"); 
        var recordId = cmp.get("v.recordId");
        var identGlobales = cmp.get("v.oIdentGlobales");
        var limite = 0;
        
        if (bResetSearch)
        {
            limite = 10;
        }

        //this.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey,limite,identGlobales);
        //this.getFAQsWrapperCache(cmp,espacio,idioma,searchKey);
        if (areaChat == 'Empleado')
        {
            helper.getFAQsWrapperCache(cmp,espacio,idioma,searchKey);
        }else{
            helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey,limite,identGlobales);
        }
    },
    handleClose: function(cmp, event, helper) {        
        var searchKey= '';
        var espacio = '';
        var categoria = ''; 
        var idioma = ''; 
        var recordId = '';     
        cmp.set('v.envioDisabled',true);
        cmp.set('v.isActive', false);
        cmp.set('v.search', '');  
        //helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey);
    }, 
    getFAQsWrapper : function(component,recordId,espacio,categoria,idioma,searchKey,limite, oIdentGlobales) 
    {
        var action = component.get("c.getFAQsWrapper");
        action.setParams({
            "recordId": recordId,
            "espacio": espacio,
            "categoria" : categoria,
            "idioma": idioma,
            "searchKey": searchKey,
            "limite": limite,
            "oGlobalId": oIdentGlobales
        });         
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue(); 
                component.set('v.gridData', resultData);
            }
        });
        $A.enqueueAction(action);
    }, 
    //getFAQsWrapper : function(component,recordId,espacio,categoria,idioma,searchKey,limite, oIdentGlobales) 
    getFAQsWrapperCache : function(component,espacio,idioma,searchKey) 
    {
        var limiteFAQs = 15;
        var limiteFAQsNoOfrecidas = 10;
        var categoria = component.get("v.categoria");
		var action = component.get("c.getFAQsWrapper_Cache");        
        action.setParams({
            "espacio": espacio,
            "idioma": idioma
        });
      	action.setStorable();
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                let options = [];
                var faqsMostradas = 0;
                var bSalir = false;
                
                var faqsCognitivo = component.get("v.FaqsCognitivo");
                for (var i=0; i<faqsCognitivo.length; i++) {
                    
                    if (searchKey == '' || searchKey == null || searchKey == undefined)
                    {
                        if (faqsCognitivo[i].faqRecord.CC_Espacio__c == espacio && (categoria == '' || categoria == null || categoria == undefined || categoria == '--Selecciona una categoría--'))
                        {
                            options.push(faqsCognitivo[i]);
                            if (i > limiteFAQs)
                            {
                                break;
                            }
                        }else{
                            if (faqsCognitivo[i].faqRecord.CC_Espacio__c == espacio && faqsCognitivo[i].faqRecord.CC_Categoria__c == categoria)
                            {
                                options.push(faqsCognitivo[i]);
                                if (i > limiteFAQs)
                                {
                                    break;
                                }
                            }
                        }
                    }else{
                        if (categoria == '' || categoria == null || categoria == undefined || categoria == '--Selecciona una categoría--')
                        {
                            if (faqsCognitivo[i].faqRecord.CC_TextoMostrar__c.toLowerCase().includes(searchKey.toLowerCase()))
                            {
                                options.push(faqsCognitivo[i]);
                            }
                        }else{
                            if (faqsCognitivo[i].faqRecord.CC_Categoria__c == categoria)
                            {
                                if (faqsCognitivo[i].faqRecord.CC_TextoMostrar__c.toLowerCase().includes(searchKey.toLowerCase()))
                                {
                                    options.push(faqsCognitivo[i]);
                                }
                            }
                        }
                    }
                }
                
                if (resultData != null)
                {
                    for (var i=0; i<resultData.length; i++) {
                        var element = {};
                        
                        if (categoria == '' || categoria == null || categoria == undefined || categoria == '--Selecciona una categoría--')
                        {
                            if (searchKey == '' || searchKey == null || searchKey == undefined)
                            {
                                options.push(resultData[i]);
                                if (i > limiteFAQsNoOfrecidas)
                                {
                                	break;
                                }
                            }else{
                                if (resultData[i].faqRecord.CC_TextoMostrar__c.toLowerCase().includes(searchKey.toLowerCase()))
                                {
                                    options.push(resultData[i]);
                                }
                            }
                        }else{
                            if (searchKey == '' || searchKey == null || searchKey == undefined)
                            {
                                if (resultData[i].faqRecord.CC_Categoria__c == categoria)
                                {
                                    options.push(resultData[i]);
                                    if (i > limiteFAQs)
                                    {
                                        break;
                                    }
                                }
                            }else{
                                if (resultData[i].faqRecord.CC_Categoria__c == categoria)
                                {
                                    if (resultData[i].faqRecord.CC_TextoMostrar__c.toLowerCase().includes(searchKey.toLowerCase()))
                                    {
                                        options.push(resultData[i]);
                                    }
                                }
                            }
                        }
                    }
                }
                component.set('v.gridData', options);             
                
            }else{
                //console.log('salir');
            }
        });
        $A.enqueueAction(action);
    }
})