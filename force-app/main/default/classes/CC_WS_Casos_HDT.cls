@RestResource(urlMapping='/CC_Casos_HDT/*')
global with sharing class CC_WS_Casos_HDT extends CBK_HttpServiceIntegration_Abstract{
	/*  Clase para publicar un servicio Rest de consulta del detalle del Casos de una oficina.
        Clase para los parámetros de entrada. */ 
    global class CC_WS_Casos_HDT_Input {
        global String tiempo {get;set;}
    }

    /* Clase para el detalle del caso de salida. */
    global class CC_WS_Casos_HDT_Output {
        global String resultado {get;set;}
        global String descripcion {get;set;}
        global List<Miscasos> datosCasos {get;set;}
    }

    /* Nueva clase CaseExtendido que contiene todos los datos del caso más los objetos relacionados */
global class CaseExtendido {
    global String id;
    global String propietario;
    global String numerooficina;
    global String matriculacontacto;
    global String creadopor;
    global String status;
    global String numerodecaso;
    global String asunto;
    global Datetime fechacreacion;
    global Datetime fechacierre;
    global String detallesconsulta;
    global Datetime fechaultiimamodificacion;
    global String canalentrada;
    global Boolean resueltoprimerallamada;
    global String canalresolucion;
    global Boolean notificacionintermedia;
    global Decimal tiemporesolucion;
    global String tematica;
    global String producto;
    global String motivo;
    global String causa;
    global String solucion;
    global String nombrecliente;
    global String propietarioanterior;
    global String idioma;
    global String direccionterritorial;
    global String linea1facturacion;
    global String estadoprovincia;
    global String canalempleado;
    global String tipocargo;
    global String tipocierre;
    global String telefonocontacto;
    global String correocontacto;
    global String nombrecontacto;
    global String nombrepropietarioanterior;

    
    
    
    
    
    global List<Task> tareasOutput {get;set;}
    global List<LiveChatTranscript> chatsOutput {get;set;}
    global List<CC_Agrupador__c> agrupadoresOutput {get;set;}
    global List<CC_Llamada__c> llamadasOutput {get;set;}

    global CaseExtendido(Case c) {
        this.nombrepropietarioanterior = c.CC_Owner_Anterior__r.Name;
        this.nombrecontacto = c.Contact.Name;
        this.correocontacto = c.Contact.Email;
        this.telefonocontacto = c.CC_Telefono_Contacto__c;
        this.tipocierre = c.HDT_Tipo_de_Cierre__c;
        this.estadoprovincia = c.Account.BillingState;
        this.linea1facturacion = c.CC_Recipient_BillingAddress__c;
        this.direccionterritorial = c.CC_Direccion_Territorial__r.Name;
        this.idioma = c.CC_Idioma__c;
        this.nombrecliente = c.Account.Name;
        this.propietarioanterior = c.CC_Owner_Anterior__r.EmployeeNumber;
        this.Id = c.Id;
        this.matriculacontacto = c.Contact.CC_Matricula__c;
        this.numerooficina = c.Account.CC_Numero_Oficina_Empresa__c;
        this.Status = c.Status;
        this.numerodecaso = c.CaseNumber;
        this.creadopor = c.CreatedBy.EmployeeNumber;
        this.asunto = c.Subject;
        this.fechacreacion = c.CreatedDate;
        this.detallesconsulta = c.CC_Detalles_Consulta__c;
        this.fechaultiimamodificacion = c.LastModifiedDate;
        this.fechacierre = c.ClosedDate;
        this.canalentrada = c.Origin;
        this.resueltoprimerallamada = c.HDT_Resuelto_Primera_Llamada__c;
        this.canalresolucion = c.CC_Canal_Resolucion__c;
        this.notificacionintermedia = c.CC_Notif_Cont_Inter__c;
        this.tiemporesolucion = c.HDT_Tiempo_Resolucion__c;
        this.propietario = c.Owner.Name;
        this.tematica = c.CC_MCC_Tematica__r.Name;
        this.producto = c.CC_MCC_ProdServ__r.Name;
        this.motivo = c.CC_MCC_Motivo__r.Name;
        this.causa = c.CC_MCC_Causa__r.Name;
        this.solucion = c.CC_MCC_Solucion__r.Name;
        this.canalempleado = c.Canal_del_Empleado__c;
        this.tipocargo = c.SEG_TipoCargo__c;
        

        // Inicializar listas vacías
        this.tareasOutput = new List<Task>();
        this.chatsOutput = new List<LiveChatTranscript>();
        this.agrupadoresOutput = new List<CC_Agrupador__c>();
        this.llamadasOutput = new List<CC_Llamada__c>();
    }
}

/* Clase que representa el formato de salida */
global class Miscasos {
    global CaseExtendido casosOutput {get;set;}

    global Miscasos(Case c) {
        this.casosOutput = new CaseExtendido(c);
    }
}

    
    
    /* Método para validar los inputs obligatorios.*/
    private static String validarDatosEntrada (CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDatos){
        if (oDatos != null){
            if (oDatos.tiempo == null){
                return 'KO';
            }else if (oDatos.tiempo.trim() == '') {
                return 'KO';
            }
        }

        return 'OK';
    }
    
    /* Método para preparar la búsqueda de casos con los criterios de entrada. */
    private static List<Case> prepararListadoCasos (CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oForm){
        List<Case> oRes = new List<Case>();
         
        try {
            
            if (oForm != null && oForm.tiempo != null){
                
                datetime intervalo = datetime.now().addMinutes(-(integer.valueof(oForm.tiempo)));
                         oRes = [SELECT Id,  OwnerId, OS_Propietario__c , Status , CaseNumber ,  CC_Matricula_Empleado__c , CC_Recipient_Name__c ,
                                Subject, CreatedDate , CC_MCC_Tematica__c , CC_Producto_Servicio__c, CC_MCC_Motivo__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c,
                                ClosedDate, LastModifiedDate, Origin, CC_Agrupador_Identificador_Maximo__c, CC_Owner_Anterior__c, Language, CC_Agrupador_Id__c,
                                CC_Direccion_Territorial__c, CC_Causa__c, Canal_del_Empleado__c, SEG_TipoCargo__c, CC_Oficina__c, HDT_Tipo_de_Cierre__c, 
                                HDT_Resuelto_Primera_Llamada__c, CC_Canal_Resolucion__c, ContactEmail,Account.BillingState,CC_Notif_Cont_Inter__c,HDT_Tiempo_Resolucion__c,
                                Account.BillingAddress,CreatedBy.EmployeeNumber,Owner.Name,Account.CC_Numero_Oficina_Empresa__c,Contact.CC_Matricula__c,CC_MCC_Tematica__r.Name,
                                CC_MCC_ProdServ__r.Name,CC_MCC_Motivo__r.Name,CC_MCC_Causa__r.Name,CC_MCC_Solucion__r.Name,Account.Name,CC_Owner_Anterior__r.EmployeeNumber,CC_Idioma__c,
                                CC_Recipient_BillingAddress__c,Contact.Email,CC_Telefono_Contacto__c,CC_Direccion_Territorial__r.Name,Contact.Name,CC_Owner_Anterior__r.Name

                                FROM CASE WHERE (RecordType.DeveloperName ='HDT_Empleado') 
                                AND LastModifiedDate >= :intervalo];   
            }
        } catch (Exception e) {
            // Error tratando el caso.
            oRes=null;
        }

        return oRes;
    }

     /* Recogemos todos las tareas relacionadas que tenemos relacionadas con los casos*/
     public static List<Task> obtenerTareasRelacionadas(List<Case> listaCasos) {
        // Verificar si la lista de casos no está vacía
        if (listaCasos == null || listaCasos.isEmpty()) {
            return new List<Task>();
        }
    
        // Extraer los IDs de los casos
        Set<Id> setIdCasos = new Set<Id>();
        for (Case caso : listaCasos) {
            setIdCasos.add(caso.Id);
        }
    
        // Obtener las tareas relacionadas con los casos
        List<Task> lstTareas = [SELECT Id, WhatId,CC_Llamada_Id__c,Subject, Status, LastModifiedBy.EmployeeNumber, CreatedDate, Type,CC_LiveChatTranscript_Id__c,
                                CC_Chat_Cognitivo_Id__c,CC_Fecha_Fin__c,Owner.Name,CreatedBy.EmployeeNumber
                                FROM Task 
                                WHERE WhatId IN :setIdCasos ];
        
        
            return lstTareas;
        
    }



    /* Recogemos todos las llamadas que tenemos relacionadas con los casos*/
    public static List<CC_Llamada__c> obtenerLlamadasRelacionadas(List<Case> listaCasos) {
        // Verificar si la lista de casos no está vacía
        if (listaCasos == null || listaCasos.isEmpty()) {
            return new List<CC_Llamada__c>();
        }
    
        // Extraer los IDs de los casos
        Set<Id> setIdCasos = new Set<Id>();
        for (Case caso : listaCasos) {
            setIdCasos.add(caso.Id);
        }
    
        // Obtener las tareas relacionadas con los casos
        List<Task> lstTareas = [SELECT Id, WhatId, CC_Llamada_Id__c,Subject, OwnerId, Status, CreatedById, LastModifiedById, CreatedDate, Type,CC_LiveChatTranscript_Id__c,
                                CC_Chat_Cognitivo_Id__c
                                FROM Task 
                                WHERE WhatId IN :setIdCasos 
                                AND CC_Llamada_Id__c != NULL];
    
        // Extraer los IDs de las llamadas desde las tareas
        Set<Id> setIdLlamadas = new Set<Id>();
        for (Task tarea : lstTareas) {
            setIdLlamadas.add(tarea.CC_Llamada_Id__c);
        }
    
        // Verificar si hay llamadas asociadas
        if (setIdLlamadas.isEmpty()) {
            return new List<CC_Llamada__c>();
        }
    
        // Obtener las llamadas usando los IDs recopilados
        List<CC_Llamada__c> lstLlamadas = [SELECT Id,CreatedDate,CreatedById,CC_Fecha_Inicio__c,CC_Fecha_Fin__c,CC_ConnId__c,CC_Tipo__c,CC_Servicio__c,CC_ANI__c,
                                           CC_Idioma__c,CC_URL_Grabacion__c,CreatedBy.EmployeeNumber
                                           FROM CC_Llamada__c
                                           WHERE Id IN :setIdLlamadas];
    
        return lstLlamadas;
    }

    /* Método para devolver los chats que tiene relacionados con los casos*/
    public static List<LiveChatTranscript> obtenerChatsRelacionados(List<Case> listaCasos) {
        // Verificar si la lista de casos no está vacía
        if (listaCasos == null || listaCasos.isEmpty()) {
            return new List<LiveChatTranscript>();
        }
    
        // Extraer los IDs de los casos
        Set<Id> setIdCasos = new Set<Id>();
        for (Case caso : listaCasos) {
            setIdCasos.add(caso.Id);
        }
    
        // Obtener los chats relacionados con los casos
        List<LiveChatTranscript> lstChats = [SELECT Id, CaseId, Name, CreatedDate, Status, RequestTime,EndTime,CC_Canal_Procedencia__c,Abandoned,ChatDuration,
                                            CC_Tiempo_Espera__c,CC_Encolado_N_Agentes__c,CC_Situacion_Chat__c,CC_Franja_Horaria__c,UserAgent,CC_CasoAsociado__c,CC_Categoria__c,
                                            CC_ChatOrigen__c,CreatedById,SupervisorTranscriptBody,CC_Espacio__c,LastModifiedDate,EndedBy,CC_Id_Cognitive__c,CC_Idioma__c,
                                            OperatorMessageCount,VisitorMessageCount,CC_Subject__c,MaxResponseTimeOperator,MaxResponseTimeVisitor,AverageResponseTimeOperator,
                                            AverageResponseTimeVisitor,CC_Tipo__c,CC_Abandonado_15s__c,CC_Aceptado__c,CC_Aceptada_30s__c,LastModifiedBy.EmployeeNumber,
                                            Contact.Name,Owner.Name
                                             FROM LiveChatTranscript 
                                             WHERE CaseId IN :setIdCasos];
    
        return lstChats;
    }

    /* Método para devolver los agrupadores relacionados con los casos*/

    public static List<CC_Agrupador__c> obtenerAgrupadoresRelacionados(List<Case> listaCasos) {
        // Verificar si la lista de casos no está vacía
        if (listaCasos == null || listaCasos.isEmpty()) {
            return new List<CC_Agrupador__c>();
        }
    
        // Extraer los IDs de los agrupadores desde los casos
        Set<Id> setIdAgrupadores = new Set<Id>();
        for (Case caso : listaCasos) {
            if (caso.CC_Agrupador_Id__c != null) {
                setIdAgrupadores.add(caso.CC_Agrupador_Id__c);
            }
        }
    
        // Si no hay IDs de agrupadores, retornar lista vacía
        if (setIdAgrupadores.isEmpty()) {
            return new List<CC_Agrupador__c>();
        }
    
        // Obtener los agrupadores relacionados con los casos
        List<CC_Agrupador__c> lstAgrupadores = [SELECT Id, Name, CreatedDate,CC_Titulo__c,CC_Id_Maximo__c,OwnerId,LastModifiedById,CC_Estado__c,
                                                CC_Estado_Maximo__c,CC_Fecha_Deteccion__c,LastModifiedDate,CC_Fecha_Cierre__c,CC_GrupoMaximo__r.Name,CC_Opcion_Call_Center__c,
                                                CC_Tematica_Id__r.Name,CC_Producto_Servicio__r.Name,CC_Motivo__r.Name,CC_Causa__r.Name,CC_Clasificacion_Maximo_1__c,CC_Clasificacion_Maximo_2__c,
                                                CC_Clasificacion_Maximo_3__c,CC_Clasificacion_Maximo_4__c,CC_Clasificacion_Maximo_5__c,CC_Publica__c,CC_Numero_Casos__c,
                                                CC_Evento__c,CC_Numero_Reclamaciones__c,CC_Persona_Afectada__c,LastModifiedBy.EmployeeNumber,Owner.Name,LastModifiedBy.Name
                                                FROM CC_Agrupador__c 
                                                WHERE Id IN :setIdAgrupadores];
    
        return lstAgrupadores;
    }

    
    
    
    /* Principal por aqui entramos */
    /* Método publicado para devolver el resultado de la busqueda de casos. */

    @HttpPost
    global static CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output searchDetailCase(CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn){
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oRes = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
        Map<String,CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oMapForm = new Map<String,CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        List<Case> oListCasos = new List<Case>();

        // Lista de trazas a crear.
        String resultado;
        Datetime dtStart = Datetime.now();
        Datetime dtEnd;
        RestRequest req =  RestContext.request;

        String test = String.valueOf(req.requestBody);
        RestResponse res = RestContext.response;
        String sErrGen = '';
        try {
            // Control de datos.
            if (oDataIn != null){
                    String sValido = validarDatosEntrada (oDataIn);
                    if (sValido == 'OK'){
                        // Validados los datos realizamos las acciones necesarias
                        oMapForm.put(oDataIn.tiempo, oDataIn);
                         req.requestBody =  Blob.valueOf(oDataIn.tiempo);
                    }else{
                    	// Error validación datos entrada.
                        resultado = '{"Result":"KO","Description":"Datos obligatorios no informados."}';
                         req.requestBody =  Blob.valueOf('vino vacio');
                        registrarTraza(req, res, dtStart, resultado, 412);
                        
                        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                        oAux.resultado = '412';
                        oAux.descripcion = 'Datos obligatorios no informados.';
                        oAux.datosCasos = null;
                        oRes = oAux;
                    }
                
            }else{
                    	// Error validación datos entrada.
                        resultado = '{"Result":"KO","Description":"Datos obligatorios no informados."}';
                		req.requestBody =  Blob.valueOf('vino vacio');
                        registrarTraza(req, res, dtStart, resultado, 412);
                        
                        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                        oAux.resultado = '412';
                        oAux.descripcion = 'Datos obligatorios no informados.';
                        oAux.datosCasos = null;
                        oRes = oAux;
                    }

            // Preparar la busqueda de los casos.
            if (!oMapForm.isEmpty()){
                // Procesar los criterios de entrada.
            
                List<Case> oResListCasos = prepararListadoCasos(oDataIn);
                //oRes.datosCasos = new List<Miscasos>();

                if (!oResListCasos.isEmpty()){
                    //Aqui hacemos la busqueda de los diferentes objetos
                    //Llamadas , Chats, Agrupadores y Task
                    List<Task> oResListTareas = obtenerTareasRelacionadas(oResListCasos);
                    List<CC_Llamada__c> oResListLlamadas = obtenerLlamadasRelacionadas(oResListCasos);
                    List<LiveChatTranscript> oResListChats = obtenerChatsRelacionados(oResListCasos);
                   

                    resultado = '{"Result":"OK","Description":"Búsqueda realizada."}';
                    CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                    oAux.resultado = '200';
                    oAux.descripcion = 'Búsqueda realizada.';

                    Map<Id, List<Task>> tareasPorCaso = new Map<Id, List<Task>>();
                    Map<Id, List<LiveChatTranscript>> chatsPorCaso = new Map<Id, List<LiveChatTranscript>>();
                    // Lista de agrupadores obtenidos previamente
                    List<CC_Agrupador__c> oResListAgrupadores = obtenerAgrupadoresRelacionados(oResListCasos);

                    // Mapa para almacenar los agrupadores relacionados con su ID
                    Map<Id, CC_Agrupador__c> mapaAgrupadores = new Map<Id, CC_Agrupador__c>();

                    // Poblar el mapa con los agrupadores por su Id
                    for (CC_Agrupador__c agrupador : oResListAgrupadores) {
                        mapaAgrupadores.put(agrupador.Id, agrupador);
                    }

                    // Mapa para almacenar la relación de casos con sus agrupadores
                    Map<Id, List<CC_Agrupador__c>> agrupadoresPorCaso = new Map<Id, List<CC_Agrupador__c>>();

                    // Asociar los agrupadores a sus respectivos casos
                    for (Case c : oResListCasos) {
                        if (c.CC_Agrupador_Id__c != null && mapaAgrupadores.containsKey(c.CC_Agrupador_Id__c)) {
                            if (!agrupadoresPorCaso.containsKey(c.Id)) {
                                agrupadoresPorCaso.put(c.Id, new List<CC_Agrupador__c>());
                            }
                            agrupadoresPorCaso.get(c.Id).add(mapaAgrupadores.get(c.CC_Agrupador_Id__c));
                        }
                    }

                    // Mapa para almacenar llamadas asociadas a un TaskId
                    Map<Id, CC_Llamada__c> llamadasPorTask = new Map<Id, CC_Llamada__c>();

                    // Poblar el mapa con llamadas asociadas a su Task correspondiente
                    for (CC_Llamada__c llamada : oResListLlamadas) {
                        llamadasPorTask.put(llamada.Id, llamada);
                    }

                    // Mapa para almacenar llamadas agrupadas por caso
                    Map<Id, List<CC_Llamada__c>> llamadasPorCaso = new Map<Id, List<CC_Llamada__c>>();

                    // Asociar llamadas a casos a través de tareas
                    for (Task tarea : oResListTareas) {
                        if (tarea.WhatId != null && tarea.CC_Llamada_Id__c != null && llamadasPorTask.containsKey(tarea.CC_Llamada_Id__c)) {
                            if (!llamadasPorCaso.containsKey(tarea.WhatId)) {
                                llamadasPorCaso.put(tarea.WhatId, new List<CC_Llamada__c>());
                            }
                            llamadasPorCaso.get(tarea.WhatId).add(llamadasPorTask.get(tarea.CC_Llamada_Id__c));
                        }
                    }

                     //Buscamos las tareas asociadas
                    for (Task t : oResListTareas) {
                        if (!tareasPorCaso.containsKey(t.WhatId)) {
                            tareasPorCaso.put(t.WhatId, new List<Task>());
                        }
                        tareasPorCaso.get(t.WhatId).add(t);
                    }

                    //Buscamos los chats asociadas
                    for (LiveChatTranscript chat : oResListChats) {
                        if (!chatsPorCaso.containsKey(chat.CaseId)) {
                            chatsPorCaso.put(chat.CaseId, new List<LiveChatTranscript>());
                        }
                        chatsPorCaso.get(chat.CaseId).add(chat);
                    }

                   

                    oAux.datosCasos = new List<Miscasos>();
                    for (Case c : oResListCasos) {
                        Miscasos misCaso = new Miscasos(c);
                        
                        
                        // Asignar datos relacionados dentro del caso extendido
                        misCaso.casosOutput.tareasOutput = tareasPorCaso.containsKey(c.Id) ? tareasPorCaso.get(c.Id) : new List<Task>();
                        misCaso.casosOutput.chatsOutput = chatsPorCaso.containsKey(c.Id) ? chatsPorCaso.get(c.Id) : new List<LiveChatTranscript>();
                        misCaso.casosOutput.agrupadoresOutput = agrupadoresPorCaso.containsKey(c.Id) ? agrupadoresPorCaso.get(c.Id) : new List<CC_Agrupador__c>();
                        misCaso.casosOutput.llamadasOutput = llamadasPorCaso.containsKey(c.Id) ? llamadasPorCaso.get(c.Id) : new List<CC_Llamada__c>();

                        // Agregar el objeto a la lista de salida
                        oAux.datosCasos.add(misCaso);

                        /*
                        misCaso.casosOutput = c;
                        misCaso.tareasOutput = tareasPorCaso.containsKey(c.Id) ? tareasPorCaso.get(c.Id) : new List<Task>();
                        misCaso.chatsOutput = chatsPorCaso.containsKey(c.Id) ? chatsPorCaso.get(c.Id) : new List<LiveChatTranscript>();
                        misCaso.agrupadoresOutput = agrupadoresPorCaso.containsKey(c.Id) ? agrupadoresPorCaso.get(c.Id) : new List<CC_Agrupador__c>();
                        misCaso.llamadasOutput = llamadasPorCaso.containsKey(c.Id) ? llamadasPorCaso.get(c.Id) : new List<CC_Llamada__c>();*/

                        
                        //oAux.datosCasos.add(misCaso);
                    }

                    oRes = oAux;
                    registrarTraza(req, res, dtStart, resultado, 200);
                }else{
                    // Error al preparar el caso.
                    resultado = '{"Result":"OK","Description":"No hay datos para retornar."}';
                    registrarTraza(req, res, dtStart, resultado, 201);
                    
                    CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
                    oAux.resultado = '201';
                	oAux.descripcion = 'No hay datos para retornar.';
                    oAux.datosCasos = null;
                    oRes = oAux;
                }                   
            }
            
        } catch (Exception e) {
            // Trazar error.
            resultado = '{"Result":"KO","Description":"Error en la ejecución del proceso CC_WS_Casos_HDT. ' + e.getMessage()+'"}';
            registrarTraza(req, res, dtStart, resultado, 500);
            sErrGen = 'Error en la ejecución del proceso CC_WS_Casos_HDT. ' + e.getMessage();

            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oAux = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output();
            oAux.resultado = '500';
            oAux.descripcion = sErrGen;
            oAux.datosCasos = null;
            oRes = oAux;
        }

        return oRes;        
    }

    public static void registrarTraza(RestRequest req, RestResponse res, Datetime dtStart, String resultado, Integer error){
        res.statusCode=error;
        res.responseBody= Blob.valueOf(resultado);
        req.requestURI = '/CC_Casos_HDT/*';
        Datetime dtEnd = Datetime.now();
        register(req,res,dtStart,dtEnd,'CC_WS_Casos_HDT_DET','CC_WS_Casos_HDT_DET');
    }
}