({

    doInit: function (component, event, helper) {
        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
        component.set("v.columnasOTPCliente", [{
            label: "Acciones", type: "button", typeAttributes: {
                label: { fieldName: "nombreBoton" },
                name: { fieldName: "nombreBoton" },
                title: { fieldName: "nombreBoton" },
                value: { fieldName: "nombreBoton" },
                iconPosition: "left"
            }
        },
        { label: "Estado", fieldName: "estado", type: "text", sortable: false, initialWidth: 50},
        { label: "Nivel", fieldName: "nivel", type: "text", sortable: false, initialWidth: 40 },
        {
            label: "Fecha envío", fieldName: "fechaEnvio", type: "date", sortable: true, typeAttributes: {
                year: "numeric",
                month: "numeric",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        {
            label: "Fecha validación", fieldName: "fechaValidacion", type: "date", sortable: true, typeAttributes: {
                year: "numeric",
                month: "numeric",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        { label: "Caso", fieldName: "numeroCaso", type: "text", sortable: false },

        { label: "Intentos", fieldName: "intentosValidacion", type: "number", initialWidth: 70 },

        { label: "Código OTPSMS", fieldName: "codigoOTP" },
        { label: "Resultado validación", fieldName: "resultado" },
        { label: "Mensaje de error", fieldName: "codigoError" }]);

         // Columnas para "Autenticaciones recientes"
        component.set("v.columnasAutenticacionesRecientes", [
            {
            label: "Acciones", type: "button", typeAttributes: {
                label: { fieldName: "nombreBoton" },
                name: { fieldName: "nombreBoton" },
                title: { fieldName: "nombreBoton" },
                value: { fieldName: "nombreBoton" },
                iconPosition: "left"
            }
            },
            { label: "Caso", fieldName: "numeroCaso", type: "text", sortable: false },
            { label: "Nivel", fieldName: "nivel", type: "text", sortable: false },
            { label: "Estado", fieldName: "estado", type: "text", sortable: false },
            { label: "Resultado de validación", fieldName: "resultado", type: "text", sortable: false },
            {
                label: "Fecha de envío", fieldName: "fechaEnvio", type: "date", sortable: true, typeAttributes: {
                    year: "numeric",
                    month: "numeric",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                }
            },
            { label: "Intentos", fieldName: "intentosValidacion", type: "number", initialWidth: 70 },
            { label: "Código OTPSMS", fieldName: "codigoOTP" },
            { label: "Resultado validación", fieldName: "resultado" },
            { label: "Mensaje de error", fieldName: "codigoError" }
        ]);

           // Columnas para "Histórico autenticaciones" (antiguas)
        component.set("v.columnasHistoricoAutenticacionesAntiguas", [
            {
            label: "Acciones", type: "button", typeAttributes: {
                label: { fieldName: "nombreBoton" },
                name: { fieldName: "nombreBoton" },
                title: { fieldName: "nombreBoton" },
                value: { fieldName: "nombreBoton" },
                iconPosition: "left"
            }
            },
            { label: "Caso", fieldName: "numeroCaso", type: "text", sortable: false },
            { label: "Nivel", fieldName: "nivel", type: "text", sortable: false },
            { label: "Estado", fieldName: "estado", type: "text", sortable: false },
            { label: "Resultado de validación", fieldName: "resultado", type: "text", sortable: false },
            {
                label: "Fecha de envío", fieldName: "fechaEnvio", type: "date", sortable: true, typeAttributes: {
                    year: "numeric",
                    month: "numeric",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                }
            },
            { label: "Intentos", fieldName: "intentosValidacion", type: "number", initialWidth: 70 },
            { label: "Código OTPSMS", fieldName: "codigoOTP" },
            { label: "Resultado validación", fieldName: "resultado" },
            { label: "Mensaje de error", fieldName: "codigoError" }
        ]);

        component.set("v.columnasOTPHistoricoCliente", [
            { label: "Caso", fieldName: "numeroCaso", type: "text", sortable: false },
            { label: "Estado", fieldName: "estado", type: "text", sortable: false },
            { label: "Nivel", fieldName: "nivel", type: "text", sortable: false },
            {
                label: "Fecha de envío", fieldName: "fechaEnvio", type: "date", sortable: true, typeAttributes: {
                    year: "numeric",
                    month: "numeric",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                }
            },
            {
                label: "Fecha de validación", fieldName: "fechaValidacion", type: "date", sortable: true, typeAttributes: {
                    year: "numeric",
                    month: "numeric",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                }
            },
            { label: "Intentos validación", fieldName: "intentosValidacion", type: "number", sortable: false },
            { label: "Código OTPSMS", fieldName: "codigoOTP", sortable: false },
            { label: "Resultado de validación", fieldName: "resultado", sortable: false },
            { label: "Mensaje de error", fieldName: "codigoError", sortable: false }
        ]);
        helper.existeOTPCasoHelper(component, event, helper);
    },

    //Boton Nivel 2
    segundoNivelAut: function (component, event, helper) {
        if (component.get('v.nuevaLogicaAut') === false) {
            component.set("v.nivelSeleccionado", event.getSource().getLocalId());
        } else {
            component.set("v.nivelSeleccionado", 'Nivel 2');
        }
        component.set("v.disabledBotones", true);
        $A.enqueueAction(component.get("c.cerrarModalValidarDos"));
        $A.enqueueAction(component.get("c.cerrarModalMecanismoAutenticacion"));
        var listaPreguntas;
        if (component.get("v.ambitoMotivoCaixa") === 'Onboarding' || component.get("v.ambitoMotivoImagin") === 'Onboarding') {
            listaPreguntas = 'Preguntas Autenticación Nivel 2 (Onboarding)';
        } else {
            listaPreguntas = 'Preguntas OTPSMS 2 Nivel';
        }
                var comprobarDatos2Nivel = component.get("c.comprobarDatos2Nivel");
                comprobarDatos2Nivel.setParams({ "recordId": component.get("v.recordId"), "nombreLista": listaPreguntas });
                comprobarDatos2Nivel.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS") {
                        var respuesta = response.getReturnValue();
                        for (let key in respuesta) {
                            if (key === "Pregunta1") {
                                component.set("v.labelPregunta1", respuesta[key]);
                            }else if (key === "Pregunta2") {
                                component.set("v.labelPregunta2", respuesta[key]);
                            }else if (key === "TextoAyudaPregunta1") {
                                component.set("v.textoAyudaPregunta1", respuesta[key]);
                            }else if (key === "TextoAyudaPregunta2") {
                                component.set("v.textoAyudaPregunta2", respuesta[key]);
                            }else if (key === "error") {
                                component.set("v.datosVacios", respuesta[key]);
                            }else if(key === "OmitirPreguntas"){
                                component.set("v.omitirPreguntasNvl2", respuesta[key]);
                            }else if(key === "listaCuentas"){
                                component.set("v.listaCuentas", respuesta[key]);
                            }else if(key === "listaTarjetas"){
                                component.set("v.listaTarjetas", respuesta[key]);
                            }
                        }

                        if (component.get("v.datosVacios") === "SIN DATOS") {
                            helper.recuperarMensajeToast(component, "error", "DATOS_VACIOS");
                            component.set("v.disabledBotones", false);
                        }else if(component.get("v.datosVacios") === "CLIENTE BLOQUEADO") {
                            helper.recuperarMensajeToast(component, "error", "CLIENTE_BLOQUEADO");
                            component.set("v.disabledBotones", false);
                        }else if(component.get("v.datosVacios") === "SIN LLAMADAS") {
                            helper.recuperarMensajeToast(component, "error", "SIN_LLAMADAS");
                            component.set("v.disabledBotones", false);
                        }else if(component.get("v.datosVacios") === "SIN DATOS API") {
                            helper.recuperarMensajeToast(component, "error", "SIN_DATOS_API");
                            component.set("v.disabledBotones", false);
                        } else if ((component.get("v.labelPregunta1") == null || component.get("v.labelPregunta2") == null) && component.get("v.omitirPreguntasNvl2") === false) {
                            helper.recuperarMensajeToast(component, "error", "DATOS_VACIOS");
                            component.set("v.disabledBotones", false);
                        } else if (component.get("v.datosVacios") === "OK") {
                            helper.obtenerPreguntasAleatorias(component);
                        }
                    }
                });
                $A.enqueueAction(comprobarDatos2Nivel);
    },

    //Boton Emergencia
    emergenciaAut: function(component, event, helper){
        component.set("v.nivelSeleccionado", event.getSource().getLocalId());
        helper.obtenerPreguntasEmergencia(component);
        $A.util.addClass(component.find("ModalboxPreguntas"), "slds-fade-in-open");
        $A.util.addClass(component.find("ModalBackdropPreguntas"), "slds-backdrop--open");

        window.setTimeout($A.getCallback(() => component.find("Validado").focus()), 0);
    },

    //Boton Cliente Digital
    clienteDigitalAut: function(component, event, helper) {
        if (component.get('v.nuevaLogicaAut') === false) {
            component.set("v.nivelSeleccionado", event.getSource().getLocalId());
        } else {
            component.set("v.nivelSeleccionado", 'Cliente Digital');
        }
        component.set("v.disabledBotones", true);
        $A.enqueueAction(component.get("c.cerrarModalValidarDos"));
        $A.enqueueAction(component.get("c.cerrarModalMecanismoAutenticacion"));
        let validarCanalAutenticacionApex = component.get("c.validarCanalAutenticacion");
        validarCanalAutenticacionApex.setParam("recordId", component.get("v.recordId"));
        validarCanalAutenticacionApex.setCallback(this, function (responseValidarCanalAutenticacion) {
            if (responseValidarCanalAutenticacion.getState() === "SUCCESS") {
                let canalValido = responseValidarCanalAutenticacion.getReturnValue();
                if (canalValido != null) {
                    if (canalValido) {
                        $A.enqueueAction(helper.enviarSegundoNivelAux(component, event));
                    } else {
                        helper.mostrarToast("error", "Operativa no disponible", "Operativa no disponible para este canal de entrada o tipo de cliente del caso.");
                    }
                } else {
                    component.set("v.disabledBotones", false);
                    helper.mostrarToast("error", "Operativa no disponible", "Operativa no disponible para este canal de entrada o tipo de cliente del caso.");
                }
            }
        });
        if (validarCanalAutenticacionApex) {
            $A.enqueueAction(validarCanalAutenticacionApex);
        }
    },
    
    //Boton Enviar/Validar de nivel 2
    accionRegistroController: function (component, event, helper) {
        var id = event.getParam("row").recordId;
        var actionName = event.getParam("row").nombreBoton;
        console.log("::: id: " + id);
        console.log("::: actionName: " + actionName);
        let enviarRegistro;
        if (actionName === "Enviar") {
            if (component.get("v.settingIntegracionNivelDos") === true || (component.get("v.settingIntegracionNivelDos") === false && component.get("v.nivelDosAUTTerceros"))) {
                enviarRegistro = component.get("c.enviarAutorizacion");
                enviarRegistro.setParams({ "recordId": component.get("v.recordIdPdteValidar"), "casoId": component.get("v.recordId"), "tipoAutenticacion": "Nivel2" });
            } else {enviarRegistro = component.get("c.enviarRegistro");
                enviarRegistro.setParams({ "recordId": id });
            }
            enviarRegistro.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    component.set("v.validarRegistro", true);
                    component.set("v.recordIdPdteValidar", id);
                    $A.enqueueAction(component.get("c.abrirModalValidarRegistro"));
                }
            });
            $A.enqueueAction(enviarRegistro);
        } else if (actionName === "Validar") {
            component.set("v.validarRegistro", true);
            component.set("v.recordIdPdteValidar", id);
            $A.enqueueAction(component.get("c.abrirModalValidarRegistro"));
        } else if (actionName === "Cancelar") {
            component.set("v.recordIdPdteValidar", id);
            $A.enqueueAction(component.get("c.cancelarAut"));
        }
    },

    //Abrir modal de validar
    abrirModalValidarRegistro: function (component, event, helper) {
        component.set("v.disabledBotones", true);
        if (!component.get("v.validarRegistro")) {
            component.set("v.recordIdPdteValidar", event.getParam("row").recordId);
        }

        let comprobarIntentos = component.get("c.comprobarIntentos");
        comprobarIntentos.setParams({ "casoId": component.get("v.recordId"), "idCliente": component.get("v.idCliente")});
        comprobarIntentos.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                if (response.getReturnValue() === "KO") {
                    helper.mostrarToast("error", "Operativa no disponible", "Existe un bloqueo por reintentos.");
                }else if (response.getReturnValue() === "Cliente Bloqueado"){
                    helper.recuperarMensajeToast(component, "error", "CLIENTE_BLOQUEADO");
                } else {
                    $A.util.addClass(component.find("ModalboxValidar"), "slds-fade-in-open");
                    $A.util.addClass(component.find("ModalBackdropValidar"), "slds-backdrop--open");

                    //Damos el foco a un elemento para que desde el primer momento funcione el cierre mediante la tecla ESC
                    window.setTimeout($A.getCallback(() => component.find("botonValidar").focus()), 0);
                }
            }
        });
        $A.enqueueAction(comprobarIntentos);
    },

    //Validar registro de Cliente Digital
    validarRegistroController: function (component, event, helper) {
        event.preventDefault();
        component.set("v.disabledBotonValidar", true);
        let fields = event.getParams().fields;
        let codigoOTP = fields.CC_Codigo_OTPSMS__c;
        let otpId = component.get("v.recordIdPdteValidar");
        var nivel = component.get("v.nivel");
        let validarRegistro;
        if (nivel === "Cliente Digital") {
            validarRegistro = component.get("c.validarAutorizacion");
            validarRegistro.setParams({ "recordId": otpId, "casoId": component.get("v.recordId") });
        } else {
            validarRegistro = component.get("c.validarRegistro");
            validarRegistro.setParams({ "casoId": component.get("v.recordId"), "otpId": otpId, "codigoOTP": codigoOTP });
        }

        validarRegistro.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                let resultado = response.getReturnValue();
                if (resultado === "OK") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: "Se ha validado correctamente.",
                        key: "info_alt", type: "success", mode: "dismissible", duration: "10000"
                    });
                    toastEvent.fire();
                    $A.enqueueAction(component.get("c.cerrarModalValidar"));
                    $A.enqueueAction(component.get("c.doInit"));
                    helper.cerrarModalQuickAction(component);
                } else if (resultado === "La autorización ha sido aprobada por el cliente" || resultado === "La autorización ha finalizado correctamente") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: resultado,
                        key: "info_alt", type: "success", mode: "dismissible", duration: "10000"
                    });
                    toastEvent.fire();
                    $A.enqueueAction(component.get("c.cerrarModalValidar"));
                    $A.enqueueAction(component.get("c.doInit"));
                    helper.cerrarModalQuickAction(component);
                } else if (resultado === "La autorización está pendiente (pendiente cliente)" || resultado == "La autorización está en progreso (pendiente cliente)") {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: "La autenticación está en progreso",
                        key: "info_alt", type: "warning", mode: "dismissible", duration: "10000"
                    });
                    toastEvent.fire();
                    component.set("v.disabledBotonValidar", false);
                } else if (resultado === "Se identifica riesgo alto de fraude (NO se permite nuevo intento)") {
                    helper.recuperarMensajeToast(component, "error", "DERIVAR_DENIED");
                    $A.enqueueAction(component.get("c.cerrarModalValidar"));
                    $A.enqueueAction(component.get("c.handleModalOficinaAbierto"));
                } else if (resultado === 'La autorización ha expirado (se permite un nuevo intento)') {
                    $A.enqueueAction(component.get("c.doInit"));
                    window.setTimeout($A.getCallback(() => {
                        let edadLimite = component.get("v.edadLimite");  
                        if (!component.get("v.clienteBloqueado") && component.get('v.impedirClienteDigital') === false && (component.get("v.edadCliente") >= edadLimite || (component.get("v.edadCliente") < edadLimite && component.get("v.menorDe65")))){
                            helper.modalNuevoMecanismo(component, 'CLIENTE_DIGITAL_EXPIRED');
                        }
                        component.set("v.disabledBotonValidar", false);
                        $A.enqueueAction(component.get("c.cerrarModalValidar"));
                    }), 2000);

                } else {
                    let toastEvent = $A.get("e.force:showToast");
                    if (nivel === "Cliente Digital") {
                        if (resultado.includes('(ERROR)') || resultado === 'Estado desconocido') {
                            if (component.get("v.impedirNivel2")) {
                            	helper.recuperarMensajeToast(component, "warning", "DERIVAR_ERROR");
                                $A.enqueueAction(component.get("c.cerrarModalValidar"));
                                $A.enqueueAction(component.get("c.handleModalOficinaAbierto"));
                            } else {
                    			helper.recuperarMensajeToast(component, "warning", "NIVEL_2_ERROR");
                                $A.enqueueAction(component.get("c.segundoNivelAut"));
                            }
                        }
                    } else {
                        if(resultado ==='OTP fallo en la integración'){
                            helper.recuperarMensajeToast(component, "warning", "LLAMADA_SALIENTE");
                        }else{
                            toastEvent.setParams({
                                title: "Error: " + resultado, message: "Se he producido un error en la validación.",
                                key: "info_alt", type: "error", mode: "dismissible", duration: "10000"
                            });
                        }
                    }

                    toastEvent.fire();
                    component.set("v.disabledBotonValidar", false);
                    $A.enqueueAction(component.get("c.cerrarModalValidar"));
                    $A.enqueueAction(component.get("c.doInit"));
                }
            } else {
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (nivel === "Cliente Digital") {
                    toastEvent.setParams({
                        title: resultado, message: "Se he producido un error en la validación.",
                        key: "info_alt", type: "error", mode: "dismissible", duration: "10000"
                    });
                } else {
                    toastEvent.setParams({
                        title: errors, message: "Se he producido un error en la validación.",
                        key: "info_alt", type: "error", mode: "dismissible", duration: "10000"
                    });
                }
                toastEvent.fire();
                component.set("v.disabledBotonValidar", false);
                $A.enqueueAction(component.get("c.cerrarModalValidar"));
                $A.enqueueAction(component.get("c.doInit"));
            }
        });
        $A.enqueueAction(validarRegistro);
    },

    //Cerrar modal de preguntas Nivel 2 y Emergencia
    cerrarModalPreguntas: function (component, event, helper) {
        component.set("v.valorInputPregunta1", null);
        component.set("v.valorInputPregunta1", null);
        component.set("v.valorInputPregunta2", null);
        component.set("v.noValidado", false);
        component.set("v.disabledBotonesValidar", false);
        component.set("v.disabledBotones", false);
        component.set("v.nivelDosCancelada", false);

        $A.util.removeClass(component.find("ModalboxPreguntas"), "slds-fade-in-open");
        $A.util.removeClass(component.find("ModalBackdropPreguntas"), "slds-backdrop--open");
    },

    cerrarModalPreguntasBotonCancelar: function (component, event, helper) {
        component.set("v.nivelDosCancelada", true);
        helper.generarComunicacionNivelDos(component, event, helper);
        $A.enqueueAction(component.get("c.cerrarModalPreguntas"));
        component.set("v.disabledBotones", false);
    },

    //Icono de cruz
    cerrarModalValidar: function (component) {
        $A.util.removeClass(component.find("ModalboxValidar"), "slds-fade-in-open");
        $A.util.removeClass(component.find("ModalBackdropValidar"), "slds-backdrop--open");
    },

    cerrarModalValidarDos: function (component) {
        $A.util.removeClass(component.find("ModalboxValidarIntento"), "slds-fade-in-open");
        $A.util.removeClass(component.find("ModalBackdropValidarDos"), "slds-backdrop--open");
        component.set("v.nuevoIntento", false);
    },

    cerrarModalMecanismoAutenticacion: function (component) {
        $A.util.removeClass(component.find("ModalboxMecanismoAutenticacion"), "slds-fade-in-open");
        $A.util.removeClass(component.find("ModalBackdropMecanismoAutenticacion"), "slds-backdrop--open");
    },

    // Boton Validado de modal de Autenticacion de Emergencia
    enviarSegunNivel: function (component, event, helper) {
        component.set("v.disabledBotones", true);
        let validarCanalAutenticacionApex = component.get("c.validarCanalAutenticacion");
        validarCanalAutenticacionApex.setParam("recordId", component.get("v.recordId"));
        validarCanalAutenticacionApex.setCallback(this, responseValidarCanalAutenticacion => {
            if (responseValidarCanalAutenticacion.getState() === "SUCCESS") {
                let canalValido = responseValidarCanalAutenticacion.getReturnValue();
                if (canalValido != null) {
                    if (canalValido) {
                        $A.enqueueAction(helper.enviarSegundoNivelAux(component, event));
                    } else {
                        helper.mostrarToast("error", "Operativa no disponible", "Operativa no disponible para este canal de entrada o tipo de cliente del caso.");
                    }
                }
            } else {
                component.set("v.disabledBotones", false);
                helper.mostrarToast("error", "Operativa no disponible", "Operativa no disponible para este canal de entrada o tipo de cliente del caso.");
            }
        });
        $A.enqueueAction(validarCanalAutenticacionApex);

    },

    //Boton Validar de autenticacion de Nivel 2
    enviarNivelDos: function (component, event, helper) {
        let respuestasErroneas = false;
        if(component.get("v.omitirPreguntasNvl2") === false){
            helper.comprobarPreguntas(component, event); //Comprobamos las respuestas antes de hacer nada
            //Validacion preguntas Nivel 2
            if ((component.get("v.valorInputPregunta1") == null || component.get("v.valorInputPregunta1") === "") || component.get("v.valorInputPregunta2") === null || component.get("v.valorInputPregunta2") === "") {
                helper.mostrarToast("error", "Campos vacíos", "Los campos no pueden estar en blanco.");
                component.set("v.disabledBotonesValidar", false);
                respuestasErroneas = true;
            } else if (component.get("v.valorInputPregunta1").length < component.get("v.minLengthPregunta1") || component.get("v.valorInputPregunta2").length < component.get("v.minLengthPregunta2")) {
                helper.mostrarToast("error", "Valores incorrectos", "Los campos no pueden tener longitud menor a la especificada.");
                component.set("v.disabledBotonesValidar", false);
                respuestasErroneas = true;
            } else if (component.get('v.caracteresNoPermitidos1') || component.get('v.caracteresNoPermitidos2')) {
                helper.mostrarToast("error", "Caracteres no permitidos", "Los campos no pueden tener caracteres no permitidos.");
                component.set("v.disabledBotonesValidar", false);
                respuestasErroneas = true;
            }
        }
        if (!respuestasErroneas) {
            let validacionPreguntas = component.get("c.validacionPreguntas");
            validacionPreguntas.setParams({
                "recordId": component.get("v.recordId"),
                "pregunta1": component.get("v.labelPregunta1"),
                "pregunta2": component.get("v.labelPregunta2"),
                "respuesta1": component.get("v.valorInputPregunta1"),
                "respuesta2": component.get("v.valorInputPregunta2"),
                "listaCuentas" : component.get("v.listaCuentas"),
                "listaTarjetas" : component.get("v.listaTarjetas")
            });
            validacionPreguntas.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    let resultado = validacionPreguntas.getReturnValue();
                    component.set("v.validacionPregunta1", resultado[0]);
                    component.set("v.validacionPregunta2", resultado[1]);
                    component.set("v.OmitirSMSNvl2", resultado[2]);

                    if ((component.get("v.validacionPregunta1") === false || component.get("v.validacionPregunta2") === false) && component.get("v.omitirPreguntasNvl2") === false) {
                        helper.generarComunicacionNivelDos(component, event, helper).then(() => {
                            helper.recuperarMensajeToast(component, "error", "NOK");
                        });
                    } else {
                        if(component.get("v.omitirPreguntasNvl2") === false){
                            helper.recuperarMensajeToast(component, "success", "OK");                            
                        }
                        let validarCanalAutenticacionApex = component.get("c.validarCanalAutenticacion");
                        validarCanalAutenticacionApex.setParam("recordId", component.get("v.recordId"));
                        validarCanalAutenticacionApex.setCallback(this, function (response) {
                            if (response.getState() === "SUCCESS") {
                                let canalValido = response.getReturnValue();
                                if (canalValido != null) {
                                    if (canalValido) {
                                        helper.generarComunicacionNivelDos(component, event, helper).then(() => {
                                            if ((component.get("v.validacionPregunta1") === true && component.get("v.validacionPregunta2") === true) || component.get("v.omitirPreguntasNvl2") === 'true') {
                                                if(component.get("v.OmitirSMSNvl2") === false) {
                                                    console.log("::: Enviando SMS Nivel 2");
                                                    let id = component.get("v.recordIdPdteValidar");
                                                    // let enviarRegistro = component.get("c.enviarRegistro");
                                                    let enviarRegistro;
                                                    console.log("::: settingIntegracionNivelDos: " + component.get("v.settingIntegracionNivelDos"));
                                                    console.log("::: nivelDosAUTTerceros: " + component.get("v.nivelDosAUTTerceros"));
                                                    if (component.get("v.settingIntegracionNivelDos") === true || (component.get("v.settingIntegracionNivelDos") === false && component.get("v.nivelDosAUTTerceros"))) {
                                                        console.log("::: dentro if");
                                                        enviarRegistro = component.get("c.enviarAutorizacion");
                                                        enviarRegistro.setParams({ "recordId": component.get("v.recordIdPdteValidar"), "casoId": component.get("v.recordId"), "tipoAutenticacion": "Nivel2" });
                                                    } else {
                                                        console.log("::: dentro else");
                                                        enviarRegistro = component.get("c.enviarRegistro");
                                                        enviarRegistro.setParams({ "recordId": id });
                                                    }
                                                    enviarRegistro.setCallback(this, function (response) {
                                                        if (response.getState() === "SUCCESS") {
                                                            console.log("::: SUCCESS");
                                                            component.set("v.validarRegistro", true);            
                                                            $A.enqueueAction(component.get("c.abrirModalValidarRegistro"));
                                                        }
                                                    });
                                                    $A.enqueueAction(enviarRegistro);
                                                    
                                                }else{
                                                    $A.enqueueAction(component.get("c.cerrarModalPreguntas"));
                                                }
                                            }
                                        });
                                    } else {
                                        helper.mostrarToast("error", "Operativa no disponible", "Operativa no disponible para este canal de entrada o tipo de cliente del caso.");
                                    }
                                }

                            } else {
                                component.set("v.disabledBotones", false);
                                helper.mostrarToast("error", "Operativa no disponible", "Operativa no disponible para este canal de entrada o tipo de cliente del caso.");
                            }
                        });
                        $A.enqueueAction(validarCanalAutenticacionApex);
                    }
                }
            });
            $A.enqueueAction(validacionPreguntas);
        }
    },

    //Cancelar autenticación
    cancelarAut: function (component, event, helper) {
        let edadLimite = component.get("v.edadLimite");
        let recordId = component.get("v.recordId");
        component.set("v.disabledBotones", false);
        var id = component.get("v.recordIdPdteValidar");
        let mensajeCancelar = component.get("c.autenticacionCancelada");
        mensajeCancelar.setParams({"recordId": id, "casoId": recordId});
        $A.enqueueAction(mensajeCancelar);
        $A.enqueueAction(component.get("c.doInit"));    
        helper.mostrarToast("warning","", "Se ha cancelado la validación.");

       if (component.get("v.nivelSeleccionado") === 'Cliente Digital' && !component.get("v.clienteBloqueado") && component.get('v.impedirClienteDigital') === false &&
            ((component.get("v.edadCliente") >= edadLimite) || (component.get("v.edadCliente") < edadLimite && component.get("v.menorDe65")))) {
                helper.modalNuevoMecanismo(component, 'CLIENTE_DIGITAL_CANCELAR');
        }
        if(event.getSource().get("v.name") === "cancelarModal") {
            $A.enqueueAction(component.get("c.cerrarModalValidar"));
        }
    },

    noRecibido: function (component) {
        let recordId = component.get("v.recordId");
        if (component.get("v.recordIdPdteValidar") != undefined || component.get("v.recordIdPdteValidar") != null) {
            let mensajeNoValidado = component.get("c.mensajeNoRecibido");
            mensajeNoValidado.setParams({ "recordId": component.get("v.recordIdPdteValidar"), "casoId": recordId });
            $A.enqueueAction(mensajeNoValidado);
            component.set("v.disabledBotones", false);
            $A.enqueueAction(component.get("c.cerrarModalValidar"));
            $A.enqueueAction(component.get("c.doInit"));
        }
    },

    modalPreguntasTeclaPulsada: function (component, event) {
        if (event.keyCode === 27 && !component.get("v.disabledBotonesValidar")) { //ESC
            $A.enqueueAction(component.get("c.cerrarModalPreguntas"));
        }
    },

    modalValidarTeclaPulsada: function (component, event) {
        if (event.keyCode === 27) { //ESC
            $A.enqueueAction(component.get("c.cerrarModalValidar"));
        }
    },

    enviarAutenticacionClienteDigital: function (component, event, helper) {
        let enviarRegistro;
        var recupOTP = component.get("c.getOTP");
        recupOTP.setParams({ "casoId": component.get("v.recordId"), "nivel": "Cliente Digital", "status": "Pdte. Envío" });
        recupOTP.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.recordIdPdteValidar", response.getReturnValue());
            }
            enviarRegistro = component.get("c.enviarAutorizacion");
            enviarRegistro.setParams({ "recordId": component.get("v.recordIdPdteValidar"), "casoId": component.get("v.recordId"), "tipoAutenticacion": "ClienteDigital" });
            enviarRegistro.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    if (response.getReturnValue() === "KO") {
                        $A.enqueueAction(component.get("c.doInit"));
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: "Error en la Autenticación.",
                            key: "info_alt", type: "Error", mode: "dismissible", duration: "10000"
                        });
                        toastEvent.fire();
                        let edadLimite = component.get("v.edadLimite");  
                        if (!component.get("v.clienteBloqueado") && ((component.get("v.edadCliente") >= edadLimite) || (component.get("v.edadCliente") < edadLimite && component.get("v.menorDe65")))) {
                            helper.modalNuevoMecanismo(component, 'CLIENTE_DIGITAL_ERROR');
                        }
                    } 
                    else if (response.getReturnValue() === "NOK"){
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: "Error en la Autenticación. No hay llamadas abiertas pendientes",
                            key: "info_alt", type: "Error", mode: "dismissible", duration: "10000"
                        });
                       toastEvent.fire();
                    }
                    else {
                        component.set("v.validarRegistro", true);
                        component.set("v.recordIdPdteValidar", component.get("v.recordIdPdteValidar"));
                        $A.enqueueAction(component.get("c.abrirModalValidarRegistro"));
                    }
                    }
                }
            );
            $A.enqueueAction(enviarRegistro);
        });
        $A.enqueueAction(recupOTP);

    },
    
    //Refresca el componente cuando detecta que se agrego una cuenta
    handleRecordUpdated : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            var changedFields = eventParams.changedFields;
            var camposCambiados = JSON.stringify(changedFields);
            if(camposCambiados.includes("AccountId") && changedFields.AccountId.oldValue == null && changedFields.AccountId.value != null || 
                camposCambiados.includes("Representante")){
                component.set("v.disabledBotones", false);
            }
            $A.enqueueAction(component.get("c.doInit"));
        }
    },


    //---------------------------
    validarContrato : function(component, event, helper) {
        component.set("v.disabledBotones", true);
        if (component.get("v.ambitoMotivoCaixa") !== 'Onboarding' || component.get("v.ambitoMotivoImagin") !== 'Onboarding') {
            let comprobarCaracteristicas = component.get("c.comprobarCaracteristicasCliente");
            comprobarCaracteristicas.setParams({"recordId": component.get('v.recordId')});
            comprobarCaracteristicas.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    if (response.getReturnValue() === 'restriccion_total' || response.getReturnValue() === 'restriccion_parcial') {
                        if (response.getReturnValue() === 'restriccion_total') {
                            helper.recuperarMensajeToast(component, "error", "RESTRICCION_TOTAL");
                        } else {
                            helper.recuperarMensajeToast(component, "error", "RESTRICCION_PARCIAL");
                        }
                        $A.enqueueAction(component.get("c.cerrarModalValidar"));
                        component.set("v.disabledBotones", false);
                        $A.enqueueAction(component.get("c.handleModalOficinaAbierto"));
                    } else {
                        let validarContrato = component.get("c.validarContratoSAU");
                        validarContrato.setParams({"recordId": component.get('v.recordId')});
                        validarContrato.setCallback(this, function (response) {
                            if (response.getState() === "SUCCESS") {
                                if (response.getReturnValue().includes('numperso')) { //Numperso vacio
                                    helper.recuperarMensajeToast(component, "error", "NUMPERSO_VACIO");
                                    component.set("v.disabledBotones", false);
                                } else if (response.getReturnValue().includes('problema')) {
                                    helper.mostrarToast("error","Autenticación fallida", response.getReturnValue());
                                    component.set("v.disabledBotones", false);
                                } else {
                                    if (component.get('v.impedirClienteDigital') === true) { // Campo 'Impedir Cliente Digital' del motivo en True
                                        helper.recuperarMensajeToast(component, "warning", "IMPEDIR_CLIENTE_DIGITAL");
                                        component.set("v.nivel", "Nivel 2");
                                        component.set("v.nuevaLogicaAut", true);
                                        $A.enqueueAction(component.get("c.cerrarModalValidar"));
                                        $A.enqueueAction(component.get("c.segundoNivelAut"));
                                    } else if (component.get('v.impedirNivel2') === true) { // Campo 'Impedir Nivel 2' del motivo en True
                                        if (response.getReturnValue() === 'exist_contract') { // Cliente Digital
                                            component.set("v.nivel", "Cliente Digital");
                                            component.set("v.nuevaLogicaAut", true);
                                            $A.enqueueAction(component.get("c.clienteDigitalAut"));
                                        } else { //Derivar
                                            helper.recuperarMensajeToast(component, "warning", "DERIVAR_CONTRATO");
                                            $A.enqueueAction(component.get("c.cerrarModalValidar"));
                                            $A.enqueueAction(component.get("c.handleModalOficinaAbierto"));
                                            component.set("v.disabledBotones", false);
                                        }
                                    } else { // Campo 'Impedir Nivel 2' y 'Impedir Cliente Digital' del motivo en False
                                        if (response.getReturnValue() === 'exist_contract') { // Cliente Digital
                                            component.set("v.nivel", "Cliente Digital");
                                            component.set("v.nuevaLogicaAut", true);
                                            $A.enqueueAction(component.get("c.clienteDigitalAut"));
                                        } else if (response.getReturnValue() === 'no_contract') { // Nivel 2
                                            helper.recuperarMensajeToast(component, "warning", "NIVEL_2_CONTRATO");
                                            component.set("v.nivel", "Nivel 2");
                                            component.set("v.nuevaLogicaAut", true);
                                            $A.enqueueAction(component.get("c.cerrarModalValidar"));
                                            $A.enqueueAction(component.get("c.segundoNivelAut"));
                                        }
                                    }
                                }
                            }
                        });
                        $A.enqueueAction(validarContrato);
                    }
                }
            });
            $A.enqueueAction(comprobarCaracteristicas);
        } else {
            component.set("v.nivel", "Nivel 2");
            component.set("v.nuevaLogicaAut", true);
            $A.enqueueAction(component.get("c.cerrarModalValidar"));
            $A.enqueueAction(component.get("c.segundoNivelAut"));
        }
    },

    handleModalOficinaAbierto: function(component, event, helper) {
        $A.enqueueAction(component.get("c.cerrarModalMecanismoAutenticacion"));
        //llamar un metodo que pone el campo CC Derivar en true
        let reiniciarDerivar = component.get('c.reiniciarDerivar');
        reiniciarDerivar.setParam('recordId', component.get('v.recordId'));
        reiniciarDerivar.setCallback(this, response => {
                if (response.getState() === 'SUCCESS') {
               //publicar mensaje en el channel
               helper.publicarMensajeChannel(component, 'otp', 'derivarPopup', '');
               helper.cerrarModalQuickAction(component);
               
            }
        });	
        $A.enqueueAction(reiniciarDerivar);
	},

    handleModalOficinaCerrado: function(component, event) {
		component.set('v.mostrarModalOficina', false);
        component.set("v.disabledBotones", false);
	},

    refreshTab: function(component) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.getFocusedTabInfo().then(response => {
			let focusedTabId = response.tabId;
			workspaceAPI.refreshTab({
				tabId: focusedTabId,
				includeAllSubtabs: true
			});
		})
		.catch();
	},

    desactivarSpinnerDerivar: function(component) {
		component.set('v.spinnerActivado', false);
    },

    onDerivarInteraccionChannel: function(component, message, helper) {

    }
});