({
    init : function(cmp, event, helper) {
        // Inicializar datos del chat al cargar el componente.
        var action = cmp.get("c.getLiveChatTranscript"); 
        var recordId = cmp.get("v.recordId");        
        action.setParams({
            chatId: recordId
        });
        
        action.setCallback(this, function(response) {
            var oMap = response.getReturnValue();
            var idioma='';
            var espacio = ''; 
            var categoria='';
            var aplicacion = '';
            var oIdentGlobales;
            var areaChat = '';
            var tipoChat = '';
            
            if (oMap !== null)
            {
                for (var key in oMap) {
                    
                    if(key === "DatosChat"){
                        if (oMap[key].length === 1){
                            idioma = oMap[key][0].CC_IdiomaCV__c;
                            espacio = oMap[key][0].CC_Espacio__c;               
                            categoria = oMap[key][0].CC_Categoria__c;
                            aplicacion = oMap[key][0].CC_Aplicacion__c;
                            tipoChat = oMap[key][0].CC_Tipo__c;
                            cmp.set("v.espacio", espacio);
                            cmp.set("v.categoria", categoria);
                            cmp.set("v.idioma", idioma);
                            cmp.set("v.aplicacion", aplicacion);
                            cmp.set("v.tipoChat", tipoChat);
                            
                        }
                    }
                    
                    if(key === "IdsGlobales"){
                        oIdentGlobales = oMap[key];
                        cmp.set("v.oIdentGlobales", oMap[key]);
                    } 
                    
                    if (key === "AreaChat")
                    {
                        areaChat = oMap[key];
                        cmp.set("v.areaChat", oMap[key]);
                    }
                    
                    if (key === "FaqsCognitivo")
                    {
                        cmp.set("v.FaqsCognitivo", oMap[key]);
                    }
                }
            }
            
                var limite = 10;
            	
            	if (areaChat == 'Empleado')
                {
                    helper.getFAQsWrapperCache(cmp,espacio,idioma,searchKey);
                }else{
                    helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey,limite,oIdentGlobales);
                }
            
                //helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey,limite,oIdentGlobales);
                //helper.getFAQsWrapper(cmp,espacio,idioma,searchKey);
                var searchKey= '';
                var activo = cmp.get("v.isActive");
                helper.getPicklistEspacio(cmp,event,helper);
                helper.getPicklistCategoria(cmp,event,helper);
        })
        $A.enqueueAction(action);
    },
    refrescoDatos : function(cmp, event, helper) 
    {  
		var espacio = ''; 
        var categoria='';        
        var recordIdReturned = event.getParam("recordId");
        var recordId2 = cmp.get("v.recordId");
        var areaChat = '';
        if (recordId2==recordIdReturned)
        { 
            var action = cmp.get("c.getLiveChatTranscript");
            var recordId = cmp.get("v.recordId");        
            action.setParams({
                chatId: recordId
            });
            
            var idioma='';
            action.setCallback(this, function(response) {                
                var oMap = response.getReturnValue();
                var oIdentGlobales;
                
                if (oMap !== null)
                {
                    for (var key in oMap) {
                        if(key === "DatosChat"){
                            if (oMap[key].length === 1){
                                idioma = oMap[key][0].CC_IdiomaCV__c;
                                espacio = oMap[key][0].CC_Espacio__c;               
                                categoria = oMap[key][0].CC_Categoria__c;
                                cmp.set("v.espacio", espacio);
                                cmp.set("v.categoria", categoria);
                                cmp.set("v.idioma", idioma);
                            }
                        }
                        
                        if(key === "IdsGlobales"){
                            cmp.set("v.oIdentGlobales", oMap[key]);
                            oIdentGlobales = oMap[key];
                        }  
                        
                        if (key === "AreaChat")
                        {
                            areaChat = oMap[key];
                            cmp.set("v.areaChat", oMap[key]);
                        }
                        
                        if (key === "FaqsCognitivo")
                        {
                            cmp.set("v.FaqsCognitivo", oMap[key]);
                        }
                    }
                }

                var limite = 10;
                
            	if (areaChat == 'Empleado')
                {
                    helper.getFAQsWrapperCache(cmp,espacio,idioma,searchKey);
                }else{
                    helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey,limite,oIdentGlobales);
                }
                
                //helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey, limite,oIdentGlobales);
                //console.log(espacio);
                //console.log(idioma);
                //helper.getFAQsWrapper(cmp,espacio,idioma,searchKey);
                var searchKey= '';
                var activo = cmp.get("v.isActive");                
            	helper.getPicklistEspacio(cmp,event,helper);
                helper.getPicklistCategoria(cmp,event,helper);                
            })
             $A.enqueueAction(action);
        }
        
    },
    sendFAQChat: function (cmp, event,helper) {
        var faqPropuesta = false;
        var selectedRows = cmp.get('v.optionSelected');        
        var conversationKit = cmp.find("conversationKit");       
        var recordIdChat = cmp.get("v.recordId");       
        recordIdChat = recordIdChat.substring(0, 15); 
        
        var idioma =  cmp.get("v.idioma");  
        var obj =  cmp.get("v.optionsCheckbox");
        var intent = '';
        var idFaq = '';
        var preguntaFaq = '';  
        var sAreaChat = cmp.get("v.areaChat");
        
        var sEspacio = '';
        var sdescripcionEspacio = '';

        if(cmp.get('v.espacio') != null && cmp.get('v.espacio') != undefined){
            sEspacio = cmp.get('v.espacio');       
        }
        
        //Obtenemos campos de Live Chat Transcript
        var getDescripcionEspacio = cmp.get("c.datosLiveChatTranscript");
        getDescripcionEspacio.setParams({
            "recordId": recordIdChat,
            "idioma" : idioma,
            "espacio": sEspacio,
            "categoria" : null,
        });

        getDescripcionEspacio.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var respuestaDatos = response.getReturnValue();
                if (respuestaDatos !== null) {
                    for (let key in respuestaDatos) {
                         if (key === "DescripcionEspacio" && respuestaDatos[key] != "") {
							sdescripcionEspacio = respuestaDatos[key];
                        } 
                    }
                }
                
            // Acciones a hacer luego de buscar la descripción del espacio
            // Buscar la FAQ escogida dentro del array de resultados marcados.
            for (var i = 0; i < obj.length; i++){
                if(obj[i].value == selectedRows){
                    intent = obj[i].label; 
                    idFaq = obj[i].name;
                    preguntaFaq = obj[i].pregunta;     
                    
                    if (obj[i].propuestaWatson == 'Y'){
                        faqPropuesta = true;
                    }
                }
            }
            
            if (intent != ''){
                var codigoCognitivo = '';
                var mensajeAgente = '';
                var msgCognitive = '';
                var action = cmp.get("c.getMensaje");
                var codigo = '';
                
                if(faqPropuesta==true){
                    codigo = 'Buscar FAQ ya ofrecida';
                }else{
                    codigo = 'Buscar FAQ';
                }
                
                action.setParams({
                    sCodigoMsj: codigo,
                    sIdioma: idioma,
                    //oGlobalIds: cmp.get("v.oIdentGlobales"),
                    oGlobalIds: null,
                    sOrigen : '',
                    sAreaChat : sAreaChat
                });
    
                action.setCallback(this, function(response){
                    var state = response.getState();
    
                    if (state === "SUCCESS" ) {
                        var resultData = response.getReturnValue();
                        if(resultData.length==1){
                            codigoCognitivo = resultData[0].CC_Codigo_Cognitive__c;
                            mensajeAgente = resultData[0].CC_Mensaje_Agente_es__c;
                            msgCognitive = resultData[0].CC_Respuesta_Mensaje_Automatico_es__c;
                        }else{
                            // Mensaje por defecto.
                            codigoCognitivo = 'MSG_HA_FAQ';
                            mensajeAgente = '<auto>Mensaje Sistema. FAQ enviada:';
                            msgCognitive = 'La FAQ que mejor se adecua a su pregunta es la siguiente:';
                        }
                    }
                    
                    if (msgCognitive != null && msgCognitive != ""){
                        codigoCognitivo = null;
                    }
                    
                    var msg = mensajeAgente+' '+preguntaFaq+'\n '+intent;              
                    conversationKit.sendMessage({
                        recordId: recordIdChat, 
                        message: {text: msg }
                    });
                
                    var type = "AGENT_ACTION";
                    var data2 = {
                        "responseType": "FAQ",
                        "faq": {
                            
                            "id": idFaq,
                            "espacio": sEspacio,
                            "espacioDescripcion": sdescripcionEspacio,
                        },
                        "msg": codigoCognitivo,
                        //or ms
                        "txtMsg": msgCognitive,
                        "idioma": null,
                        "idiomaSeleccionado": null
                    };
                    var data = JSON.stringify(data2);
                    
                    conversationKit.sendCustomEvent({
                        recordId: recordIdChat,
                        type:type,
                        data: data
                    }).then(function(result){                   
                        //console.log('OK test');
                        //Finalizar chat si es Hidden
                        if (cmp.get("v.tipoChat")=="Hidden") {
                            conversationKit.endChat({
                                recordId: recordIdChat
                            }).then(function(result){
                                if (result) {
                                    console.log("Successfully ended chat");
                                } else {
                                    console.log("Failed to end chat");
                                }
                            });
                        }
                    }, function(result){                    
                        //console.log('KO');
                    });
                
                })
                $A.enqueueAction(action);
            	//$A.enqueueAction(cmp.get('c.finalizarchat'));
        	}
            	}
        	});
        $A.enqueueAction(getDescripcionEspacio);
        
        helper.handleClose(cmp, event, helper);
    },
    
    
    handleClose: function(cmp, event, helper) {
        helper.handleClose(cmp, event, helper);
    },
    seleccionarFAQ: function (component, event) {
       component.set('v.envioDisabled', false);
       component.set('v.faqPropuesta', true);
       var optionSelected = component.get('v.optionSelected'); 
        
       var options = event.getParam('value');
       
        if (options.length > 0)
        {
            //console.log('seleccion');
        }else{
            //console.log('deseleccion');
            component.set('v.envioDisabled', true);
        }

       if(optionSelected === undefined)
       {
           component.set('v.optionSelected', event.getParam('value')[0]);
       }else{
           for (var i = 0; i < options.length; i++) {
               if(options[i] !== optionSelected)
               {
                   component.set('v.optionSelected', options[i]);
                   component.set('v.value', options[i]);
               }
           }
       }
   },
    seleccionarFAQNew: function (component, event) {
        
       var bSel = event.getSource().get("v.checked");
        var sIntentId = event.getSource().get("v.name");
        var obj =  component.get("v.optionsCheckbox");
        
        if (bSel)
        {
            // Intent Seleccionada.
            component.set('v.envioDisabled', false);
        }else{
            // Intent Deseleccionada.
            component.set('v.envioDisabled', true);
        }
        
        // Buscar la FAQ escogida dentro del array de resultados marcados.
        for (var i = 0; i < obj.length; i++)
        {
            if(obj[i].value == sIntentId)
            {
				component.set('v.optionSelected', sIntentId);
                obj[i].seleccion = bSel;
            }else{
                obj[i].seleccion = false;
            }
        }
        
        component.set("v.optionsCheckbox", obj);
        
   },
    searchKeyChange: function(cmp, event, helper) {
        //var keySearch = cmp.get("v.search");
        var keySearch = event.getSource().get("v.value");
        cmp.set("v.temporalSearch", keySearch);
        // Sólo se busca con 3+ caracteres
        if (keySearch.length > 2) {
            window.setTimeout($A.getCallback(() => {
                if (keySearch === cmp.get("v.temporalSearch")) {
                helper.searchKeyChange(cmp,event, helper, false);
            }
                                             }),300);
        }else{
            if (keySearch.length == 0)
            {
                helper.searchKeyChange(cmp,event, helper, true);
            }
        }
    },  
    desplegarFAQ: function (component, event, helper) {
        // Evitar ejecución en carga / descarga del accordion.
        if (component.get("v.isActive") == false)
        {
            return;
        }

        // Evitar ejecutar código sin sección seleccionada.
        var sSeccionSel = component.find('accordion').get('v.activeSectionName');
        if (sSeccionSel == undefined)
        {
            return;
        }
        
        component.set('v.optionsCheckbox', "");        
        var options = [];
        var idioma =  component.get("v.idioma");
        
        // Recuperar FAQ seleccionada.
        var iIndex = component.find('accordion').get('v.activeSectionName');

        // Offset Array.
        //iIndex = iIndex -1;
        
        // Obtener datos sobre el objeto de FAQs.        
        //var faqId = component.get('v.gridData')[iIndex].faqRecord.Id;
        var arrayFaq = iIndex.split('#');
        var faqId = arrayFaq[0];
        var ofrecidaWatson = arrayFaq[1];
        var oIdentGlobal = component.get("v.oIdentGlobales");
        
        var action = component.get("c.getFaqWithIntentsByFAQ");
        action.setParams({
            'oFaqCustId' : faqId,
            'oGlobalId' : oIdentGlobal
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                
                for (var i=0; i<resultData.length; i++) {
        			var element = {};
                    
                    // Preparar la estructura de elementos de selección de FAQs.
                    element.name = resultData[i].CC_Nombre__c;
                    element.value = String(resultData[i].Id);
                    element.pregunta = resultData[i].CC_FAQ_Id__r.CC_TextoMostrar__c;
                    element.label = resultData[i].CC_TextoMostrar__c;
                    //element.propuestaWatson = component.get('v.gridData')[iIndex].sOfrecidaWatson;
                    element.propuestaWatson = ofrecidaWatson;
                    element.seleccion = false;
                    element.identificador = String(resultData[i].Id);
                    element.mostrarURL = false;
                    element.url = resultData[i].CC_FAQ_Id__r.CC_URL__c;
                    if (resultData[i].CC_FAQ_Id__r.CC_URL__c !== '')
                    {
                        element.contieneURL = true;
                    }else{
                        element.contieneURL = false;
                    }
                    
                    
                    options.push(element); 
                    
                    /*var element2 = {};
                    element2.label = 'test';
                    element2.value = 'test';
                    element2.name = 'test';
                    element2.pregunta = 'test';
                    element.propuestaWatson = component.get('v.gridData')[iIndex].sOfrecidaWatson;
                    options.push(element2); */
                }   
                component.set('v.optionsCheckbox', options);  
            }
        });
        $A.enqueueAction(action);
    },   
    verURLIntent: function (component, event, helper) { 
        
        var sIntentId = event.getSource().get("v.name");
        var obj =  component.get("v.optionsCheckbox");
        var bMostrarURL = false;
        
        // Buscar la FAQ escogida dentro del array de resultados marcados.
        for (var i = 0; i < obj.length; i++)
        {
            if(obj[i].value == sIntentId)
            {
                bMostrarURL = true;
                obj[i].mostrarURL = true;
            }else{
                obj[i].mostrarURL = false;
            }
        }
        
        component.set("v.verURL", bMostrarURL);        
        component.set("v.optionsCheckbox", obj);        
    },
    verURLFAQ: function (component, event, helper) {  
        
        var sFAQId = event.getSource().get("v.name");
        var obj =  component.get("v.gridData");
        var bMostrarURL = false;
        
        // Buscar la FAQ escogida dentro del array de resultados marcados.
        for (var i = 0; i < obj.length; i++)
        {
            if(obj[i].faqRecord.Id == sFAQId)
            {
                bMostrarURL = true;
                obj[i].bMostrarURL = true;
            }else{
                obj[i].bMostrarURL = false;
            }
        }
        
        component.set("v.verURL", bMostrarURL);        
        component.set("v.gridData", obj);        
    },
    cerrarURLIntent: function (component, event, helper) { 
        
        var sIntentId = event.getSource().get("v.name");
        var obj =  component.get("v.optionsCheckbox");
        var bMostrarURL = true;
        
        // Buscar la FAQ escogida dentro del array de resultados marcados.
        for (var i = 0; i < obj.length; i++)
        {
            if(obj[i].value == sIntentId)
            {
                bMostrarURL = false;
                obj[i].mostrarURL = false;
            }else{
                obj[i].mostrarURL = false;
            }
        }
        
        component.set("v.verURL", bMostrarURL);        
        component.set("v.optionsCheckbox", obj);        
    },
    cerrarURLFAQ: function (component, event, helper) { 
        
        var sFAQId = event.getSource().get("v.name");
        var obj =  component.get("v.gridData");
        var bMostrarURL = true;
        
        // Buscar la FAQ escogida dentro del array de resultados marcados.
        for (var i = 0; i < obj.length; i++)
        {
            if(obj[i].faqRecord.Id == sFAQId)
            {
                bMostrarURL = false;
                obj[i].bMostrarURL = false;
            }else{
                obj[i].bMostrarURL = false;
            }
        }
        
        component.set("v.verURL", bMostrarURL);        
        component.set("v.gridData", obj);        
    },
    getValueFromApplicationEvent : function(cmp, event,helper) {
        var ShowResultValue = event.getParam("showBuscar");
        var recordIdReturned = event.getParam("recordId");
        var recordId = cmp.get("v.recordId");
        var areaChat = event.getParam("areaChat");
        var idioma = event.getParam("idioma");
        var espacio = event.getParam("espacio");
        
        if (areaChat == undefined || areaChat == null)
        {
            areaChat = cmp.get("v.areaChat");
        }
        
        if (idioma == undefined || idioma == null)
        {
            idioma = cmp.get("v.idioma");
        }
        
        if (espacio == undefined || espacio == null)
        {
            espacio = cmp.get("v.espacio");
        }
        
        if (recordId==recordIdReturned)
        {
            // Novedad. Al levatar las FAQs, no vamos a servidor a buscar las FAQs.
            //var idioma = cmp.get("v.idioma");
            var espacio = cmp.get("v.espacio"); 
            var categoria = cmp.get("v.categoria");
            var aplicacion = cmp.get("v.aplicacion");
            var oIdentGlobales = cmp.get("v.oIdentGlobales");
            //var areaChat = cmp.get("v.areaChat");
            
            cmp.set("v.isActive", ShowResultValue);
                
                var limite = 10;

            	if (areaChat == 'Empleado')
                {
                    helper.getFAQsWrapperCache(cmp,espacio,idioma,searchKey);
                }else{
                    helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey,limite,oIdentGlobales);
                }
            
                //helper.getFAQsWrapper(cmp,recordId,espacio,categoria,idioma,searchKey,limite,oIdentGlobales);
                //helper.getFAQsWrapperCache(cmp,espacio,idioma,searchKey);
                var searchKey= '';
                var activo = cmp.get("v.isActive");
                helper.getPicklistEspacio(cmp,event,helper);
                helper.getPicklistCategoria(cmp,event,helper);      
        }             
    },
    
    onCodeSelectFirstChangeEspacio: function(cmp, event, helper) {
       var actualOption = cmp.find("firstOptionEspacio").get("v.value");            
       cmp.set("v.espacio", actualOption);        
       cmp.set("v.selectedFirstOption", actualOption);
       cmp.set("v.actualFirstOption", actualOption);
       
       var picklistOptionsEspacio = cmp.get("v.picklistFirstOptionEspacio");

       cmp.set("v.categoria", '');  
       helper.getPicklistCategoria(cmp,event,helper);
       helper.searchKeyChange(cmp,event, helper, false);
   },
    
    onCodeSelectFirstChange: function(cmp, event, helper) {
       var actualOption = cmp.find("firstOptionCategoria").get("v.value");            
       cmp.set("v.categoria", actualOption);        
       cmp.set("v.selectedFirstOption", actualOption);
       cmp.set("v.actualFirstOption", actualOption);
       var picklistOptionsCategoria = cmp.get("v.picklistFirstOptionsCategoria");
        
       helper.searchKeyChange(cmp,event, helper, false);
   },
        
})