public with sharing class CC_CaseTriggerHelper {

    public static void accionesBeforeUpdate(List<Case> listNewObjCC, Map<Id, Case> mapOldObjCC, List<Id> idsCAM) {
        comprobacionTransferBU(listNewObjCC, mapOldObjCC, idsCAM);
        cambiosEstadoPendiente(listNewObjCC, mapOldObjCC);
        desvinculacionAgrupadorBU(listNewObjCC, mapOldObjCC);
        cambioPropietarioBU(listNewObjCC, mapOldObjCC);
        cambioPropietarioOriginal(listNewObjCC, mapOldObjCC);
        contadorSLAsinTareas(listNewObjCC, mapOldObjCC);
        permiteCambioOwnerCC(listNewObjCC, mapOldObjCC, idsCAM);
        personAccountBU(listNewObjCC, mapOldObjCC, idsCAM);
        identificarClienteAlfBU(listNewObjCC, mapOldObjCC, idsCAM);
        identificarCambioOficinaAfectadaBU(listNewObjCC, mapOldObjCC, idsCAM);
        blanqueoAccountBU(listNewObjCC, mapOldObjCC, idsCAM);
        contactoIncoherenteBU(listNewObjCC, mapOldObjCC, idsCAM);
        informarOficinaAfectadaBU(listNewObjCC, mapOldObjCC, idsCAM);
        seAsignaPropietario3NBU(listNewObjCC, mapOldObjCC, idsCAM);
        cuentaDesasociadaBU(listNewObjCC, mapOldObjCC, idsCAM);
        identificarCambioClienteAlfBU(listNewObjCC, mapOldObjCC, idsCAM);
        seInformaCanalRespuestaBU(listNewObjCC, mapOldObjCC, idsCAM);
        empleadoCuentaBU(listNewObjCC, mapOldObjCC, idsCAM);
        tematicaInformadoBU(listNewObjCC, mapOldObjCC, idsCAM);
        productoInformadoBU(listNewObjCC, mapOldObjCC, idsCAM);
        motivoInformadoBU(listNewObjCC, mapOldObjCC, idsCAM);
        actualizarColaProcedenciaBU(listNewObjCC, mapOldObjCC, idsCAM);
        asociaActivoBU(listNewObjCC, mapOldObjCC, idsCAM);
        causaInformadoBU(listNewObjCC, mapOldObjCC, idsCAM);
        solucionInformadoBU(listNewObjCC, mapOldObjCC, idsCAM);
        informarOficinaAfectadaDetalleBU(listNewObjCC, mapOldObjCC, idsCAM);
        cambioContactoEmpleadoBU(listNewObjCC, mapOldObjCC, idsCAM);
        reperturaCaso(listNewObjCC, mapOldObjCC, idsCAM);

        //generarEncuestaHDT1N(listNewObjCC, mapOldObjCC);
    }

    public static void caseGestionado(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {

        for(Case caso : lstCasos){
            if(!idsCAM.contains(caso.Id)){
                //CONDICIONAL ANTIGUO, SOLO SE QUIERE MARCAR EL CHECK A TRUE CUANDO EL CASO PASA DE PROPIETARIO DE COLA A AGENTE
                //if(String.valueOf(caso.OwnerId).left(3) == '005' && (mapOldObj == null || (mapOldObj != null && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId)) && !caso.CC_Gestionado_Agente__c)
                if(mapOldObj != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).left(3) == '00G' && String.valueOf(caso.OwnerId).left(3) == '005' &&  !caso.CC_Gestionado_Agente__c)
                {
                    caso.CC_Gestionado_Agente__c = true;
                }
            }
        }
    }

    public static void calcularNumAgrupadores(List<Case> lstCasesCC, Map<Id, Case> mapOldObj) {

        CC_CaseTriggerHelperNoSharing.calcularNumAgrupadores(lstCasesCC,mapOldObj);

        /*

        List<Id> lstIdsAgrupador = new List<Id>();
        Map<Id, List<Case>> mapaCasosAgrupados = new Map<Id, List<Case>>();
        List<CC_Agrupador__c> agrupadores = new List<CC_Agrupador__c>();


        for(Case caso : lstCasesCC){
            if(caso.CC_Agrupador_Id__c != mapOldObj.get(caso.Id).CC_Agrupador_Id__c){
              if(caso.CC_Agrupador_Id__c != null){
                    lstIdsAgrupador.add(caso.CC_Agrupador_Id__c);
                }
                if(mapOldObj.get(caso.Id).CC_Agrupador_Id__c != null){
                    lstIdsAgrupador.add(mapOldObj.get(caso.Id).CC_Agrupador_Id__c);
                }
            }
        }

        if(!lstIdsAgrupador.isEmpty()){
            List<Case> lstCasos = [SELECT Id, CC_Agrupador_Id__c FROM Case WHERE CC_Agrupador_Id__c IN :lstIdsAgrupador ORDER BY CC_Agrupador_Id__c ];
            if (!lstCasos.isEmpty()) {
                for (Case casoAgrupado : lstCasos) {
                    if(mapaCasosAgrupados.containsKey(casoAgrupado.CC_Agrupador_Id__c)) {
                        List<Case> lstCasosAgrupados = mapaCasosAgrupados.get(casoAgrupado.CC_Agrupador_Id__c);
                        lstCasosAgrupados.add(casoAgrupado);
                        mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c,lstCasosAgrupados);
                     } else {
                        mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c, new List<Case> {casoAgrupado});
                    }
                }
            }
            for (Id idAgrupador : lstIdsAgrupador) {
                CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = idAgrupador);
                if(mapaCasosAgrupados.containsKey(idAgrupador)){
                    agrupador.CC_Numero_Casos__c = mapaCasosAgrupados.get(idAgrupador).size();
                }else{
                    agrupador.CC_Numero_Casos__c = 0;
                }
                agrupadores.add(agrupador);
            }
            if (!agrupadores.isEmpty()) {
                String jsonAgrupadores = JSON.serialize(agrupadores);
                actualizarAgrupador(jsonAgrupadores);
            }
        }*/
    }


    public static void modificarActivarCasoChat(List<Case> casos) {
        for (Case caso : casos) {
            if (caso.Origin == 'Chat' && caso.Status == 'New') {
                caso.Status = 'Activo';
            }
        }
    }

    //Reapertura de casos
    public static void reperturaCaso(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        for(Case caso : lstCasos){
            if(!idsCAM.contains(caso.Id)){
                if(caso.Status != mapOldObj.get(caso.Id).Status && (mapOldObj.get(caso.Id).Status == 'Cerrado' || mapOldObj.get(caso.Id).Status == 'Rechazado') && caso.Status == 'Activo'  && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'){
                	caso.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
                }
            }
        }

    }
        //Calcular catalogo, precio y margen de facturación
    public static void calcularFacturacion(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {

        //Set<String> setProcedencia = new Set<String>();
        Set<Id> setIdCuentas = new Set<Id>();
        Set<Id> setIdCasosCerrados = new Set<Id>();
        Set<String> setCanalOperativo = new Set<String>();
        Set<String> setTematica = new Set<String>();
        Set<String> setProducto = new Set<String>();
        Set<String> setIdCasos = new Set<String>();
        Set<String> setOrigin = new Set<String>();
        Set<String> setOwner = new Set<String>();
        Set<String> setOwnerAnterior = new Set<String>();
        Set<String> setCompany = new Set<String>();
        Set<String> setAreaNegocio = new Set<String>();
        Map<String, CBK_CatalogoFacturacion__c> mapKeyCatalogo = new Map<String, CBK_CatalogoFacturacion__c>();
        Map<String, String> mapUserCompany = new Map<String, String>();
        Map<String, CBK_Precio_Facturacion__c> mapKeyPrecio = new Map<String, CBK_Precio_Facturacion__c>();
        Map<String, CBK_Margen_Facturacion__c> mapKeyMargen = new Map<String, CBK_Margen_Facturacion__c>();
        List<Case> lstCasosCerrados = new List<Case>();
        List<Case> lstCasosActualizar = new List<Case>();
        Boolean casosExcepcionar = false;

        for(Case caso : lstCasos){
            if(!idsCAM.contains(caso.Id)){
                if(caso.Status != mapOldObj.get(caso.Id).Status && (caso.Status == 'Cerrado' || caso.Status == 'Rechazado') && !caso.CC_No_Facturable__c && !caso.CC_Facturado__c){
                    setCanalOperativo.add(caso.CC_Canal_Operativo__c);
                    setTematica.add(caso.CC_MCC_Tematica__c);
                    setProducto.add(caso.CC_MCC_ProdServ__c);
                    setOrigin.add(caso.Origin);
                    setOwner.add(caso.OwnerId);
                    setOwnerAnterior.add(caso.CC_Owner_Anterior__c);
                    setIdCuentas.add(caso.AccountId);
                    setIdCasosCerrados.add(caso.Id);
                    lstCasosCerrados.add(caso);
                }
            }
        }

        if(!lstCasosCerrados.isEmpty()){
            //Calculamos el catalogo
            List<CBK_CatalogoFacturacion__c> lstCatalogoFacturacion = [SELECT CC_Area_Negocio__c, CC_Canal_Operativo__c, CC_Tematica__c, CC_Producto__c, CC_ImaginBank__c FROM CBK_CatalogoFacturacion__c WHERE CC_Canal_Operativo__c IN :setCanalOperativo AND CC_Tematica__c IN :setTematica AND CC_Producto__c IN :setProducto AND CC_Activo__c = true];
            if(!lstCatalogoFacturacion.isEmpty()){
                for(CBK_CatalogoFacturacion__c catalogo : lstCatalogoFacturacion){
                    String key = catalogo.CC_Area_Negocio__c + '-' + catalogo.CC_Canal_Operativo__c + '-' + catalogo.CC_Tematica__c + '-' + catalogo.CC_Producto__c + '-' + catalogo.CC_ImaginBank__c;
                    if(!mapKeyCatalogo.containsKey(key)){
                        mapKeyCatalogo.put(key, catalogo);
                    }
                }
                List<CC_Settings__c> lstCanalesOperativos = [SELECT CC_Configuracion_1__c, CC_Configuracion_2__c, CC_Configuracion_3__c, CC_Configuracion_4__c, CC_Configuracion_6__c, CC_Configuracion_7__c, CC_Configuracion_8__c, CC_Configuracion_9__c, CC_Configuracion_10__c, CC_Configuracion_11__c, CC_Configuracion_12__c, CC_Configuracion_13__c, CC_Configuracion_14__c, CC_Configuracion_15__c, CC_Configuracion_16__c, CC_Configuracion_17__c, CC_Configuracion_18__c, CC_Configuracion_19__c, CC_Configuracion_20__c FROM CC_Settings__c WHERE Name = 'CC_CanalOperativoFacturacion' AND CC_Activa__c = true];
                Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT AV_IndicadoresClientes__c FROM Account WHERE Id IN :setIdCuentas]);
                Map<Id, CC_MCC__c> mapMCCs = new Map<Id, CC_MCC__c>([SELECT CC_Omitir_Facturacion_Imagin__c FROM CC_MCC__c WHERE Id IN :setTematica OR Id IN :setProducto]);
                for(Case casoCerrado : lstCasosCerrados) {
                    casosExcepcionar = false;
                    if (!lstCanalesOperativos.isEmpty() && casoCerrado.CC_MCC_Tematica__c != null && casoCerrado.CC_MCC_ProdServ__c != null) {
                        if (mapMCCs.get(casoCerrado.CC_MCC_Tematica__c).CC_Omitir_Facturacion_Imagin__c == true ||
                        mapMCCs.get(casoCerrado.CC_MCC_ProdServ__c).CC_Omitir_Facturacion_Imagin__c == true ||
                        String.valueOf(lstCanalesOperativos).contains(casoCerrado.CC_Canal_Operativo__c)) {
                            casosExcepcionar = true;
                        }
                    }

                    for (String key : mapKeyCatalogo.keySet()) {
                        if(key.contains(casoCerrado.CC_MCC_Tematica__c) && key.contains(casoCerrado.CC_MCC_ProdServ__c) && key.contains(casoCerrado.CC_Canal_Operativo__c)){
                            if (!mapAccount.isEmpty()) {
                                String valorIndicadoresClientes = mapAccount.get(casoCerrado.AccountId).AV_IndicadoresClientes__c;
                                if (valorIndicadoresClientes!=null && valorIndicadoresClientes.contains('28') && !casosExcepcionar) {
                                    if (mapKeyCatalogo.get(key).CC_Area_Negocio__c == 'IMAGINBANK') {
                                        casoCerrado.CC_Area_Negocio__c = mapKeyCatalogo.get(key).CC_Area_Negocio__c;
                                        casoCerrado.CC_Catalogo_Facturacion__c = mapKeyCatalogo.get(key).Id;
                                        setAreaNegocio.add(casoCerrado.CC_Area_Negocio__c);

                                    }
                                } else {
                                    if ((mapKeyCatalogo.get(key).CC_Area_Negocio__c == 'IMAGINBANK' && mapKeyCatalogo.get(key).CC_ImaginBank__c == false) || mapKeyCatalogo.get(key).CC_Area_Negocio__c != 'IMAGINBANK') {
                                        casoCerrado.CC_Area_Negocio__c = mapKeyCatalogo.get(key).CC_Area_Negocio__c;
                                        casoCerrado.CC_Catalogo_Facturacion__c = mapKeyCatalogo.get(key).Id;
                                        setAreaNegocio.add(casoCerrado.CC_Area_Negocio__c);
                                    }
                                }
                            } else {
                                if ((mapKeyCatalogo.get(key).CC_Area_Negocio__c == 'IMAGINBANK' && mapKeyCatalogo.get(key).CC_ImaginBank__c == false) || mapKeyCatalogo.get(key).CC_Area_Negocio__c != 'IMAGINBANK') {
                                    casoCerrado.CC_Area_Negocio__c = mapKeyCatalogo.get(key).CC_Area_Negocio__c;
                                    casoCerrado.CC_Catalogo_Facturacion__c = mapKeyCatalogo.get(key).Id;
                                    setAreaNegocio.add(casoCerrado.CC_Area_Negocio__c);
                                }
                            }
                        }
                    }
                }

                //Calculamos el precio
                Date fechaActual = Date.today();
                List<User> lstUsuario = [SELECT CompanyName FROM User WHERE id in :setOwner or id in :setOwnerAnterior];
                if(!lstUsuario.isEmpty()){
                    for(User usuario :lstUsuario){
                        if(!mapUserCompany.containsKey(usuario.Id)){
                            mapUserCompany.put(usuario.Id, usuario.CompanyName);
                        }
                        if(Test.isRunningTest()){
                            setCompany.add('COMDATA');
                        } else {
                            setCompany.add(usuario.CompanyName);
                        }
                    }
                }
                List<CBK_Precio_Facturacion__c> lstPrecioFacturacion = [SELECT Id, CC_Precio_Contacto__c, CC_Canal_Entrada__c, CC_Area_Negocio__c, CC_Nombre_Empresa__c FROM CBK_Precio_Facturacion__c WHERE CC_Canal_Entrada__c in :setOrigin AND CC_Area_Negocio__c in :setAreaNegocio AND CC_Nombre_Empresa__c in :setCompany AND CC_Fecha_Inicio_Vigencia__c <= :fechaActual AND (CC_Fecha_Fin_Vigencia__c > :fechaActual or CC_Fecha_Fin_Vigencia__c = null)];
                if(!lstPrecioFacturacion.isEmpty()){

                    for(CBK_Precio_Facturacion__c precio :lstPrecioFacturacion){
                        String key =  precio.CC_Canal_Entrada__c + '-' + precio.CC_Area_Negocio__c + '-' + precio.CC_Nombre_Empresa__c;
                        if(!mapKeyPrecio.containsKey(key)){
                            mapKeyPrecio.put(key, precio);
                        }
                    }
                    for(Case casoCerrado : lstCasosCerrados){
                        String keyCaso;
                        if(!casoCerrado.CC_En_Tercer_Nivel__c && mapUserCompany.containsKey(casoCerrado.OwnerId)){
                            keyCaso = casoCerrado.Origin + '-' + casoCerrado.CC_Area_Negocio__c + '-' + mapUserCompany.get(casoCerrado.OwnerId);
                        }else if(casoCerrado.CC_En_Tercer_Nivel__c && mapUserCompany.containsKey(casoCerrado.CC_Owner_Anterior__c)){
                            keyCaso = casoCerrado.Origin + '-' + casoCerrado.CC_Area_Negocio__c + '-' + mapUserCompany.get(casoCerrado.CC_Owner_Anterior__c);
                        }
                        if(keyCaso != null && mapKeyPrecio.containsKey(keyCaso)){
                            casoCerrado.CC_Precio_Facturar__c = mapKeyPrecio.get(keyCaso).CC_Precio_Contacto__c;
                            casoCerrado.CC_Precio_Facturacion__c = mapKeyPrecio.get(keyCaso).Id;
                            casoCerrado.CC_Fecha_Facturacion__c = Date.Today();
                        }
                    }
                }

                //Calculamos el margen
                List<CBK_Margen_Facturacion__c> lstMargen = [SELECT CC_Area_de_Negocio__c FROM CBK_Margen_Facturacion__c WHERE CC_Area_de_Negocio__c in :setAreaNegocio AND CC_Fecha_Inicio__c <= :fechaActual AND (CC_Fecha_Fin__c > :fechaActual or CC_Fecha_Fin__c = null)];
                if(!lstMargen.isEmpty()) {
                    for(CBK_Margen_Facturacion__c margen :lstMargen){
                        if(!mapKeyMargen.containsKey(margen.CC_Area_de_Negocio__c)) {
                            mapKeyMargen.put(margen.CC_Area_de_Negocio__c, margen);
                        }
                    }
                    for(Case casoCerrado : lstCasosCerrados){
                        if(mapKeyMargen.containsKey(casoCerrado.CC_Area_Negocio__c)) {
                            casoCerrado.CC_Margen_Facturacion__c = mapKeyMargen.get(casoCerrado.CC_Area_Negocio__c).Id;
                        }
                    }
                }
            }
        }
    }


    @future
	public static void actualizarAgrupador(String jsonString) {
		List<CC_Agrupador__c> lstAgrupador = (List<CC_Agrupador__c>)Json.deserialize(jsonString,List<CC_Agrupador__c>.class);
        Database.update(lstAgrupador);
    }


    public static void cambiosEstadoPendiente(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Cliente'  || caso.Status == 'Pendiente Incidencia'  || caso.Status == 'Pendiente Interno'  || caso.Status == 'Pendiente Revisión')){
                caso.CC_Cambio_Estado_Pendiente__c = Date.today();
                if (caso.Status == 'Pendiente Interno' && caso.CC_En_Tercer_Nivel__c) {
                    caso.CC_Fecha_Traslado_3N__c = DateTime.now();
                } else if (caso.Status == 'Pendiente Interno' && caso.CC_En_Segundo_Nivel__c) {
                    caso.CC_Fecha_Traslado_2N__c = DateTime.now();
                }
            }
        }
    }

    public static void crearActividadCierreCC(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado' && caso.OwnerId != null){
                String detallesConsulta = null;
                String detallesSolucion = null;

                if (caso.CC_Detalles_Consulta__c != null && caso.CC_Detalles_Consulta__c.length() > 254) {
                    detallesConsulta = caso.CC_Detalles_Consulta__c.substring(0,255);
                } else {
                    detallesConsulta = caso.CC_Detalles_Consulta__c;
                }

                if (caso.CC_Detalles_Solucion__c != null && caso.CC_Detalles_Solucion__c.length() > 254) {
                    detallesSolucion = caso.CC_Detalles_Solucion__c.substring(0,255);
                } else {
                    detallesConsulta = caso.CC_Detalles_Solucion__c;
                }

                Task createTask = new Task( Type = 'Cerrado' ,Subject = 'Cerrado' ,ActivityDate = System.today() ,Status = 'Completed' ,WhatId = caso.Id ,CC_Detalles_Consulta__c = detallesConsulta ,CC_Detalles_Solucion__c = detallesSolucion ,CC_Fecha_Inicio__c = Datetime.now() ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            CC_Activity.crearActividades(lstTareas);
        }
    }

    public static void crearActividadReactivacionCC(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_Reactivado_Operativa__c != mapOldObj.get(caso.Id).CC_Reactivado_Operativa__c && caso.CC_Reactivado_Operativa__c != null){
                Task createTask = new Task( Type = 'Reactivación' ,Subject = 'Reactivación'  ,Description = caso.CC_Motivo_Reactivacion__c ,Status = 'Completed' ,WhatId = caso.Id ,CC_Fecha_Inicio__c = Datetime.now() ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            CC_Activity.crearActividades(lstTareas);
        }
    }

    public static void crearActividadTraslado(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        List<Case> casosTrasladados = new List<Case>();
        Set<Id> setAgrupadores = new Set<Id>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.CC_Agrupador_Id__c  != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c  != null){
                casosTrasladados.add(caso);
                setAgrupadores.add(caso.CC_Agrupador_Id__c);
            }
        }

        if(!casosTrasladados.isEmpty() && !setAgrupadores.IsEmpty()){
            Map<ID, CC_Agrupador__c> mapAgrupadores = new Map<ID, CC_Agrupador__c>([SELECT Id, Name FROM CC_Agrupador__c WHERE Id IN :setAgrupadores]);

            for (Case casoTrasladado : casosTrasladados) {
                String titulo = 'Traslado a Incidencia';
                if(mapAgrupadores.containsKey(casoTrasladado.CC_Agrupador_Id__c)){
                    titulo = 'Traslado a ' + mapAgrupadores.get(casoTrasladado.CC_Agrupador_Id__c).Name + ' de Incidencia';
                }
                Task createTask = new Task( Type = 'Traslado Incidencia' , Subject = titulo, Status = 'Pendiente' ,Agrupador__c = casoTrasladado.CC_Agrupador_Id__c, WhatId = casoTrasladado.Id ,CC_Fecha_Inicio__c = Datetime.now() ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            CC_Activity.crearActividades(lstTareas);
        }
    }

    public static void desvinculacionAgrupadorBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.CC_Agrupador_Id__c  != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c  == null){
                caso.Status = mapOldObj.get(caso.Id).Status;
            }
        }
    }

    public static void desvinculacionAgrupadorAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Case> lstCasosDesvinculados = new List<Case>();
        List<Task> lstTareasRechazables = new List<Task>();
        Map<Id, Case> mapIdCasosDesvinculados = new Map<Id, Case>();
        Set<Id> setIdAgrupadores = new Set<Id>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.CC_Agrupador_Id__c  != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c  == null){
                lstCasosDesvinculados.add(caso);
                mapIdCasosDesvinculados.put(caso.Id, mapOldObj.get(caso.Id));
                setIdAgrupadores.add(mapOldObj.get(caso.Id).CC_Agrupador_Id__c);
            }
        }

        if(!lstCasosDesvinculados.isEmpty() && !mapIdCasosDesvinculados.isEmpty() && !setIdAgrupadores.isEmpty()){
            List<Task> lstTraslados = [SELECT Id, Status, WhatId, Agrupador__c FROM Task WHERE Type = 'Traslado Incidencia' AND WhatId IN :mapIdCasosDesvinculados.keySet() AND Agrupador__c IN :setIdAgrupadores];
            if (!lstTraslados.isEmpty()) {
                for(Task tareaTraslado : lstTraslados) {
                    if(mapIdCasosDesvinculados.containsKey(tareaTraslado.WhatId) && mapIdCasosDesvinculados.get(tareaTraslado.WhatId).CC_Agrupador_Id__c == tareaTraslado.Agrupador__c){
                        tareaTraslado.Status = 'Rechazada';
                        lstTareasRechazables.add(tareaTraslado);
                    }
                }
            }
        }

        if(!lstTareasRechazables.isEmpty()){
            Database.update(lstTareasRechazables, false);
        }
    }

    public static void cambioPropietarioBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('005')){
                caso.CC_Autoasignado_Coordinador__c = false;
            }
        }
    }

    public static void cambioPropietarioAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        List<Case> casosTraspasados = new List<Case>();
        Set<Id> setIdCasos = new Set<Id>();

        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('005')){
                casosTraspasados.add(caso);
                setIdCasos.add(caso.Id);
            }
        }

        if(!casosTraspasados.isEmpty()){
            Map<ID, Case> mapCasos = new Map<ID, Case>([SELECT Id, Owner.Name FROM Case WHERE Id IN :setIdCasos ORDER BY Owner.Name]);
            for (Case casoTrasladado : casosTraspasados) {
                String titulo = 'Reasignación del caso';
                if((String.valueOf(casoTrasladado.OwnerId).startsWith('005') || String.valueOf(casoTrasladado.OwnerId).startsWith('00G')) && mapCasos.containsKey(casoTrasladado.Id)){
                    titulo = 'Reasignación del caso a ' + mapCasos.get(casoTrasladado.Id).Owner.Name;
                }
                Task createTask = new Task(Type = 'Reasignación ' , Subject = titulo, ActivityDate = System.today(), Status = 'Completed', WhatId = casoTrasladado.Id ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            CC_Activity.crearActividades(lstTareas);
        }
    }

    public static void cambioPropietarioOriginal(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('005') && !(caso.CC_En_Tercer_Nivel__c && mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c)){
                caso.CC_Owner_Anterior__c = mapOldObj.get(caso.Id).OwnerId;
            }
        }
    }

    public static void cambioPropietarioActividades(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCaso = new Set<Id>();
        Map<Id, Case> mapIdCaso = new Map<Id, Case>();

        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(caso.OwnerId).startsWith('005')){
                setIdCaso.add(caso.Id);
                mapIdCaso.put(caso.Id,caso);
            }
        }
        if(!setIdCaso.isEmpty()){
            List<Task> lstTareas = [SELECT Id, WhatId FROM Task WHERE WhatId IN :setIdCaso AND IsClosed = FALSE];
            if(!lstTareas.isEmpty()){
                for (Task tarea : lstTareas) {
                    if( mapIdCaso.containsKey(tarea.WhatId)){
                        tarea.OwnerId = mapIdCaso.get(tarea.WhatId).OwnerId;
                    }
                }
                Database.update(lstTareas);
            }
        }
    }

    // Metodo para comprobar si la oficina asociada al clientes se en cuentra en la lista de valores de oficinas de telefono unico
    static public void getOficinaPersonAccount(List<Case> lstCasos, Map<Id, Case> mapOldObj){

        Id clienteRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id clientePARTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();


        Set<String> setNumOficinas = new Set<String>();
        Set<String> setValores = new Set<String>();
        List<Account> clienteUpdate = new List<Account>();
        List<Id> lstClientes = new List<Id>();

        for (Case caso : lstCasos) {
            if (!String.isBlank(caso.AccountId) && (mapOldObj == null || (mapOldObj != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId))) {
                lstClientes.add(caso.AccountId);
            }
        }

        if(!lstClientes.isEmpty()){
            List<Account> clientes = [SELECT CC_Nombre_Oficina__pc, CC_Telefono_Unico__c, CC_Numero_Oficina__c,AV_OficinaPrincipal__c, CC_OficinaGestoraId__c, CC_OficinaGestoraId__r.CC_Numero_Oficina__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c FROM Account WHERE Id =: lstClientes AND RecordtypeId IN (:clienteRTId, :clientePARTId)];


            // Comprobar si se encuentra en la lista de valores de oficinas
            for(Account cliente : clientes){
                if(cliente.AV_OficinaPrincipal__c != null && !cliente.CC_Telefono_Unico__c){

                    if(cliente.AV_OficinaPrincipal__r.CC_Numero_Oficina__c != null && cliente.AV_OficinaPrincipal__r.CC_Numero_Oficina__c != ''){

                        setNumOficinas.add(cliente.AV_OficinaPrincipal__r.CC_Numero_Oficina__c);
                    }
                }
            }

            if(!setNumOficinas.isEmpty()){
                List<CC_Lista_Valores__c> lstValores = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.name = 'Oficinas' AND RecordType.DeveloperName ='CC_Valor' AND Name in :setNumOficinas];
                if(!lstValores.isEmpty()){
                    for(CC_Lista_Valores__c valor : lstValores){
                        setValores.add(valor.Name);
                    }
                }
            }

            if(!setValores.isEmpty()){
                for(Account cliente: clientes){
                    if(!cliente.CC_Telefono_Unico__c && setValores.contains(cliente.AV_OficinaPrincipal__r.CC_Numero_Oficina__c)){
                        cliente.CC_Telefono_Unico__c = true;
                        clienteUpdate.add(cliente);
                    }
                }
            }

            if (!clienteUpdate.isEmpty()) {
                update clienteUpdate;
            }
        }
    }

    public static void routingEmailCasesAProveedor (List<Case> listNewObjCC) {
        // Se consideran para enrutar solamente los Cases de Cliente, con canal de entrada Email y cuyo propietario original sea una cola
        ID caseClienteRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Case> casesQueEnrutarLst = new List<Case>();
        List<String> canalesProcedenciaLst = new List<String>();
        if (!listNewObjCC.isEmpty()) {
            for (Case caso : listNewObjCC) {
                if (caso.RecordTypeId == caseClienteRTId && caso.Origin == 'Email' && !String.isBlank(String.valueOf(caso.OwnerId))) {
                    casesQueEnrutarLst.add(caso);
                    // Se guarda una lista con los canales de procedencia de los casos, para buscar solamente las configuraciones necesarias
                    if (!canalesProcedenciaLst.contains(caso.CC_Canal_Procedencia__c)) {
                        canalesProcedenciaLst.add(caso.CC_Canal_Procedencia__c);
                    }
                }
            }
        }
        // Se aplica el enrutamiento a los Cases de Cliente y con canal de entrada Email
        if (!casesQueEnrutarLst.isEmpty() && !canalesProcedenciaLst.isEmpty()) {
            // Se obtiene la capacidad de los proveedores
            List<CC_Capacidad_Proveedores__c> listCapacidad = [SELECT Id, CC_Canal_Procedencia__c, CC_Capacidad__c, CC_Proveedor__c, CC_Queue_Name__c FROM CC_Capacidad_Proveedores__c
                WHERE CC_Canal_Entrada__c = 'Email' AND CC_Canal_Procedencia__c IN :canalesProcedenciaLst AND
                RecordTypeId=:Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId() AND CC_Capacidad__c > 0
                ORDER BY CC_Canal_Procedencia__c, CC_Proveedor__c];

            // Se han encontrado configuraciones para los canales de procedencia de los casos cuya capacidad es mayor que 0
            if (!listCapacidad.isEmpty()) {
                Map<String, List<CC_Capacidad_Proveedores__c>> mapProcedenciaCapacidad = new Map<String, List<CC_Capacidad_Proveedores__c>>();
                for (CC_Capacidad_Proveedores__c cap : listCapacidad) {
                    List<CC_Capacidad_Proveedores__c> tmpList;
                    if (mapProcedenciaCapacidad.containsKey(cap.CC_Canal_Procedencia__c)) {
                        tmpList = mapProcedenciaCapacidad.get(cap.CC_Canal_Procedencia__c);
                    } else {
                        tmpList = new List<CC_Capacidad_Proveedores__c>();
                    }
                    tmpList.add(cap);
                    mapProcedenciaCapacidad.put(cap.CC_Canal_Procedencia__c, tmpList);
                }
                // Se sacan solamente aquellos Cases que se tendrían que enrutar: Cases de cliente que coincidan con los canales de entrada y procedencia de alguna capacidad
                List<Case> casesQueEnrutarProcedenciaLst = new List<Case>();
                if (!mapProcedenciaCapacidad.isEmpty()) {
                    for (Case caso : casesQueEnrutarLst) {
                        if (mapProcedenciaCapacidad.containsKey(caso.CC_Canal_Procedencia__c)) {
                            casesQueEnrutarProcedenciaLst.add(caso);
                        }
                    }
                }

                // Se enrutan solamente aquellos casos que cumplen todas las condiciones
                if (!casesQueEnrutarProcedenciaLst.isEmpty()) {
                    // Se crea un map por cada canal de procedencia con el porcentaje de capacidad acumulado para cada proveedor
                    Map<String, Map<Double, String>> mapPorcentajeProveedor = new Map<String, Map<Double, String>>();
                    Double capacidadAcumulada;
                    for (String procedencia : mapProcedenciaCapacidad.keySet()) {
                        capacidadAcumulada = 0;
                        for (CC_Capacidad_Proveedores__c capacidad : mapProcedenciaCapacidad.get(procedencia)) {
                            Map<Double, String> tmpMap;
                            if (mapPorcentajeProveedor.containsKey(procedencia)) {
                                tmpMap = mapPorcentajeProveedor.get(procedencia);
                                tmpMap.put(Double.valueOf(capacidadAcumulada), capacidad.CC_Queue_Name__c);
                            } else {
                                tmpMap = new Map<Double, String>();
                                tmpMap.put(Double.valueOf(0), capacidad.CC_Queue_Name__c);
                            }
                            mapPorcentajeProveedor.put(procedencia, tmpMap);
                            capacidadAcumulada += capacidad.CC_Capacidad__c/100;
                        }
                    }
                    // Se genera un map para guardar el Id de cada queue
                    Map<String, ID> mapQueuesIds = new Map<String, ID>();
                    Set<String> queuesSet = new Set<String>();
                    for (String procedencia : mapPorcentajeProveedor.keySet()) {
                        if (mapPorcentajeProveedor.containsKey(procedencia)) {
                            queuesSet.addAll(mapPorcentajeProveedor.get(procedencia).values());
                        }
                    }
                    List<Group> queuesList = [SELECT Id, DeveloperName FROM Group WHERE Type='Queue' AND DeveloperName IN :queuesSet];
                    for (Group queue : queuesList) {
                        mapQueuesIds.put(queue.DeveloperName, queue.Id);
                    }

                    // Enrutamiento
                    for (Case caso : listNewObjCC) {
                        // Se enruta el Case solamente si cumple todas las condiciones
                        if (casesQueEnrutarProcedenciaLst.contains(caso)) {
                            // Se obtiene un número aleatorio entre 0 y 1 que se usará para repartir la carga
                            Double randomNumber = Math.random();
                            // Se asigna el case a la cola cuyo rango de porcentaje contenga el número aleatorio obtenido previamente
                            List<Double> listRepartoCarga = new List<Double>(mapPorcentajeProveedor.get(caso.CC_Canal_Procedencia__c).keySet());
                            listRepartoCarga.sort();
                            for (Integer i=0; i < listRepartoCarga.size(); i++) {
                                if (randomNumber >= Double.valueOf(listRepartoCarga[i])) {
                                    if (i+1 == listRepartoCarga.size()) {
                                        // Se ha llegado al último elemento de la lista, por lo que se establece esta capacidad como la elegida
                                        if (mapQueuesIds.containsKey(mapPorcentajeProveedor.get(caso.CC_Canal_Procedencia__c).get(listRepartoCarga[i]))) {
                                            caso.OwnerId = mapQueuesIds.get(mapPorcentajeProveedor.get(caso.CC_Canal_Procedencia__c).get(listRepartoCarga[i]));
                                        }
                                    } else if (randomNumber < Double.valueOf(listRepartoCarga[i+1])) {
                                        // Se establece esta capacidad como la elegida
                                        if (mapQueuesIds.containsKey(mapPorcentajeProveedor.get(caso.CC_Canal_Procedencia__c).get(listRepartoCarga[i]))) {
                                            caso.OwnerId = mapQueuesIds.get(mapPorcentajeProveedor.get(caso.CC_Canal_Procedencia__c).get(listRepartoCarga[i]));
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static void contadorSLAsinTareas(List<Case> listNewObjCC, Map<Id, Case> mapOldObj){
        List<Case> casosConsultasOperativas = new List<Case>();
        Map<Integer, List<Integer>> festivosPorMesMap = new  Map<Integer, List<Integer>>();

        for (Case caso : listNewObjCC) {
			if (caso.Status == 'Cerrado' && mapOldObj.get(caso.Id).Status != caso.Status && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas') {
				casosConsultasOperativas.add(caso);
			}
		}

        if(!casosConsultasOperativas.isEmpty()){
            diasFestivos(casosConsultasOperativas);
        }

    }

    public static void diasFestivos(List<Case> cs) {
        Map<Id, String> mapaCreated = new Map<Id, String>();
        Map<Id, String> mapaClosed = new Map<Id, String>();
        for(Case c : cs){
            if(!mapaCreated.containsKey(c.Id)){
                mapaCreated.put(c.Id, string.valueOfGmt(c.CreatedDate).substring(0,10));
                mapaClosed.put(c.Id, string.valueOfGmt(System.now()).substring(0,10));
            }
        }

        List <CC_Lista_Valores__c> listaFestivos = [SELECT Name, CC_Valor__c, CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Festivos nacionales' AND CC_Activa__c = true ORDER BY CC_Valor2__c];
        BusinessHours diasLaborables = [SELECT Id FROM BusinessHours WHERE name='CC_Empleados'];
        if (!String.isBlank(diasLaborables.Id) && !listaFestivos.isEmpty()) {
            for(Case caso : cs){
                Integer contadorDias = 0;
                //devuelve en milisegundos los lunes a viernes, sin tener en cuenta los dias festivos.
                Long horasNegocioMiliseg = BusinessHours.diff(diasLaborables.Id, caso.CreatedDate, System.now());
                Integer actualYear = System.Today().year();
                //se hace todo en el mismo año
                if(actualYear == Integer.valueOf(mapaCreated.get(caso.Id).substring(0, 4)) && actualYear == Integer.valueOf(mapaClosed.get(caso.Id).substring(0, 4))){
                    for(CC_Lista_Valores__c posibleFestivo : listaFestivos){

                        DateTime valorFestivo = Datetime.newInstance(actualYear, Integer.valueof(posibleFestivo.CC_Valor2__c), Integer.valueof(posibleFestivo.CC_Valor__c));

                        if(caso.CreatedDate <= valorFestivo && valorFestivo <= System.now()){
                            if(!isWeekend(valorFestivo)){
                                contadorDias++;
                            }
                        }
                    }
                }

                //se abre en el año anterior al que se cierra EJ: diciembre 2022 - enero 2023
                else if(actualYear > Integer.valueOf(mapaCreated.get(caso.Id).substring(0, 4)) && actualYear == Integer.valueOf(mapaClosed.get(caso.Id).substring(0, 4))){

                    for(CC_Lista_Valores__c posibleFestivo : listaFestivos){
                        DateTime valorFestivo = Datetime.newInstance(actualYear - 1, Integer.valueof(posibleFestivo.CC_Valor2__c), Integer.valueof(posibleFestivo.CC_Valor__c)).addHours(1);
                        if(caso.CreatedDate <= valorFestivo){
                            if(!isWeekend(valorFestivo)){
                                contadorDias++;
                            }
                        }
                    }

                    for(CC_Lista_Valores__c posibleFestivo : listaFestivos){
                        DateTime valorFestivo = Datetime.newInstance(actualYear, Integer.valueof(posibleFestivo.CC_Valor2__c), Integer.valueof(posibleFestivo.CC_Valor__c));
                        if(valorFestivo <= System.now()){
                            if(!isWeekend(valorFestivo)){
                                contadorDias++;
                            }
                        }
                    }
                }


                Decimal diasTotales = (horasNegocioMiliseg / 86400000) - contadorDias;
                Integer i1 = Math.round(diasTotales);
                DateTime dt = caso.CreatedDate.addDays(i1);

                caso.CC_FechaSLAsinEstados__c = String.valueOf(caso.CreatedDate) + '-' + String.valueOf(dt);
            }
        }
    }

    public static Boolean isWeekend (Datetime fecha){
		Boolean isWeekend = false;
		Integer diaSemana = Integer.valueOf(fecha.format('u'));
		isWeekend = (diaSemana > 5);

		return (isWeekend);
	}

    public static void permiteCambioOwnerCC(List<Case> listNewCases, Map<Id, Case> mapOldObj, List<Id> idsCAM){
        List<Id> usuarioNuevo = new List<Id>();
        Map<Id, Case> usuarioNuevoPorCase = new Map<Id, Case>();
        for(Case caso : listNewCases){
            if (!idsCAM.contains(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueof(caso.OwnerId).startsWithIgnoreCase('005')){
                usuarioNuevo.add(caso.OwnerId);
                usuarioNuevoPorCase.put(caso.OwnerId, caso);
            }
        }
        if(!usuarioNuevo.isEmpty()){
            List<UserRole> roles = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center' or DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'];
            List<User> usuarios = [SELECT Id, Name, UserRoleId FROM User WHERE Id IN: usuarioNuevo AND (UserRoleId NOT IN :roles AND Name != 'System' AND Name != 'Automated Process'AND Name != 'Administrador de sistema')];
            if(!usuarios.isEmpty()){
                for(User usuario : usuarios){
                    ///if(usuario.UserRoleId != rol.Id && (usuario.Name != 'System' && usuario.Name != 'Automated Process' && usuario.Name != 'Administrador de sistema')){
                        usuarioNuevoPorCase.get(usuario.Id).addError('Únicamente se pueden vincular a trabajadores del Contact Center');
                    //}
                }
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Creacion_Caso) a Trigger
    public static void comprobacionContactoAI(List<Case> lstCasos) {
        List<Id> casosConContacto = new List<Id>();
        for (Case caso : lstCasos) {
            if(caso.ContactId != null){
                casosConContacto.add(caso.Id);
            }
        }

        if (!casosConContacto.isEmpty()) {
            CC_Caracteristica.RelacionarCaso(casosConContacto);
        }
    }

    //Método creado a partir del traspaso de PB (cc_Creacion_Caso) a Trigger
    public static void procedenciaEmailBI(List<Case> lstCasos) {

        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Procedencia__c == 'Formulario web' && caso.SuppliedEmail != null && caso.CC_MailTelfNotif__c == null) {
                caso.CC_MailTelfNotif__c = caso.SuppliedEmail;
            }
        }
    }


    //Método creado a partir del traspaso de PB (cc_Creacion_Caso) a Trigger
    public static void casosFaxAI(List<Case> lstCasos) {
        List<Task> lstTareas = new List<Task>();
        List<Case> lstCasosFax = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Origin == 'Fax') {
                Task createTask = new Task( Type = 'Fax entrante' ,Subject = caso.Subject ,Description = caso.Description ,ActivityDate = System.today() ,Status = 'Completed' ,WhatId = caso.Id ,Priority = 'Normal');
                lstTareas.add(createTask);
                Flow.Interview flowEmpleados = new Flow.Interview.CC_Obtener_MCC_Tematica_Tarjetas(new map<String,Object> {'CC_Caso' => caso});
                flowEmpleados.start();
                lstCasosFax.add(caso);
            }
        }

        if (!lstTareas.isEmpty()) {
            CC_Activity.crearActividades(lstTareas);
        }

        if (!lstCasosFax.isEmpty()) {
            CC_Aviso_Coordinador_FAX.publicarToast(lstCasosFax);
        }
    }

    public static void casosFaxBI(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if (caso.Origin == 'Fax') {
                caso.CC_Canal_Operativo__c = 'Sin canal';
                caso.CC_Canal_Procedencia__c = 'Redsys-Sermepa';
                caso.CC_Tipo_Contacto__c = 'Petición de servicio';
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Creacion_Caso) a Trigger
    public static void casosWebAI(List<Case> lstCasos) {
        List<Case> lstCasosWeb = new List<Case>();
        List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
        for (Case caso : lstCasos) {
            if (caso.CC_SuppliedApp__c != null && caso.CC_AcuseRecibo__c == '1' && caso.CC_AcuseDelay__c != null) {
                lstCasosWeb.add(caso);
            }
        }

        if (!lstCasosWeb.isEmpty()) {
            for (Case casoSchedule : lstCasosWeb) {
                lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c = casoSchedule.CC_AcuseDelay__c,
                ClassName__c = 'CC_NotifSegAcuse', RecordId__c = casoSchedule.Id));
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Creacion_Caso) a Trigger
    public static void casosSegunColaBI(List<Case> lstCasos) {
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        List<Case> listaCasosUpdate = new List<Case>();
        for (Schema.RecordTypeInfo rt: lstRT){
            if ((rt.getDeveloperName().left(3)=='CC_')) {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }

        Map<Id,Group> mapColas = new Map<Id, Group>([SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN ('CC_Formulario_Terminal_Financiero','CC_Buzon_Usuario_Publico')]);
        for (Case caso : lstCasos) {
            if(setIdsRt.contains(caso.RecordtypeId)){
                listaCasosUpdate.add(caso);
            }
        }
        for (Case caso : listaCasosUpdate) {
            if (caso.Origin == 'Email' && caso.OwnerId != null && String.valueOf(caso.OwnerId).startsWith('00G') && mapColas.containsKey(caso.OwnerId)) {
                if (mapColas.get(caso.OwnerId).DeveloperName == 'CC_Formulario_Terminal_Financiero') {
                    caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
                    caso.CC_Cola_Procedencia__c = 'CC_Formulario_Terminal_Financiero';
                } else {
                    caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
                    caso.CC_Cola_Procedencia__c = 'CC_Buzon_Usuario_Publico';
                }
            }
        }
    }


    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void personAccountBI(List<Case> lstCasos) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.CC_Representante__c == null) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :setIdCuentas AND RecordType.DeveloperName = 'CC_ClientePA']);

            for (Case caso : casosAlf) {
                if (mapAccount.containsKey(caso.AccountId)) {
                    caso.ContactId = mapAccount.get(caso.AccountId).PersonContactId;
                }
            }
        }
    }


    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void personAccountBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.AccountId != null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :setIdCuentas AND RecordType.DeveloperName = 'CC_ClientePA']);

            for (Case caso : casosAlf) {
                if (mapAccount.containsKey(caso.AccountId)) {
                    caso.ContactId = mapAccount.get(caso.AccountId).PersonContactId;
                }
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void identificarClienteAlfBI(List<Case> lstCasos) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.CC_IdentCliente__c != '0') {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, true);
        }
    }

    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void identificarClienteAlfBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            //caso.CC_IdentCliente__c != '0' no existe en el PB, añadido para contuniar la lógica del BI
            if (!idsCAM.contains(caso.Id) && caso.AccountId != null && mapOldObj.get(caso.Id).CC_IdentCliente__c != caso.CC_IdentCliente__c && caso.CC_IdentCliente__c != '0') {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, true);
        }
    }

    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void identificarCambioClienteAlfBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.AccountId != null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, false);
        }
    }

    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    private static void alfAux(List<Case> lstCasos, Set<Id> setIdCuentas, Boolean cambioDocumen) {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, CC_Email__c, CC_NumPerso__c, CC_Numero_Documento__c, CC_OficinaGestoraId__c, CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c,
        CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId FROM Account WHERE Id IN :setIdCuentas]);

        for (Case caso : lstCasos) {
            if (mapAccount.containsKey(caso.AccountId)) {
                if(cambioDocumen || (!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web')){
                    caso.CC_MailTelfNotif__c = mapAccount.get(caso.AccountId).CC_NumPerso__c;
                    caso.CC_Numero_Documento__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    if(!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web'){
                        caso.CC_NumPerso__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    }
                }
                if (caso.RecordTypeId == rtCliente && mapAccount.get(caso.AccountId).CC_OficinaGestoraId__c != null) {
                    if (mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c != null){
                        caso.CC_DAN__c = mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c;
                    }
                    if (mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId != null){
                        caso.CC_DG__c = mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId;
                    }
                }
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void identificarCambioOficinaAfectadaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.recordTypeId == rtCliente && caso.CC_Oficina_Afectada_Lookup__c != null && mapOldObj.get(caso.Id).CC_Oficina_Afectada_Lookup__c != caso.CC_Oficina_Afectada_Lookup__c) {
                if(!setIdCuentas.contains(caso.CC_Oficina_Afectada_Lookup__c)){
                    setIdCuentas.add(caso.CC_Oficina_Afectada_Lookup__c);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){

            Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, CC_Gerencia_Comercial__c, CC_Gerencia_Comercial__r.ParentId FROM Account WHERE Id IN :setIdCuentas]);

            for (Case caso : casosAlf) {

                if (mapAccount.containsKey(caso.CC_Oficina_Afectada_Lookup__c)) {
                    caso.CC_DAN__c = mapAccount.get(caso.CC_Oficina_Afectada_Lookup__c).CC_Gerencia_Comercial__c;

                    if (mapAccount.get(caso.CC_Oficina_Afectada_Lookup__c).CC_Gerencia_Comercial__r.ParentId != null) {
                        caso.CC_DG__c = mapAccount.get(caso.CC_Oficina_Afectada_Lookup__c).CC_Gerencia_Comercial__r.ParentId;
                    }
                }
            }
        }
    }
    
    public static void informarOficinaAfectadaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosOficina = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosOficina.add(caso);
            }
        }
        Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT AV_OficinaPrincipal__c FROM Account WHERE Id IN :setIdCuentas AND AV_OficinaPrincipal__c != null]);

        for (Case caso : casosOficina) {
            if (mapCuentas.containsKey(caso.AccountId)) {
                //caso.CC_Oficina_afectada__c = mapCuentas.get(caso.AccountId).CC_OficinaGestoraId__c;
                caso.CC_Oficina_Afectada_Lookup__c = mapCuentas.get(caso.AccountId).AV_OficinaPrincipal__c;
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void cambioContactoEmpleadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            //Si es un caso de empleado y ha cambiado su ContactId (y no se está vaciando)
            if (!idsCAM.contains(caso.Id) && (caso.RecordTypeId == rtEmpleado || caso.RecordTypeId == rtBankia)
            && (mapOldObj.get(caso.Id).ContactId != caso.ContactId) && caso.ContactId != null) {
                if (!setIdContacto.contains(caso.ContactId)) {
                    setIdContacto.add(caso.ContactId);
                }
                casosAlf.add(caso);
            }
        }

        if (!setIdContacto.isEmpty()) {
            Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Email FROM Contact WHERE Id IN :setIdContacto]);
            for (Case caso : casosAlf) {
                if (mapContacts.containsKey(caso.ContactId) && mapContacts.get(caso.ContactId).Email != null) {
                    caso.CC_MailTelfNotif__c = mapContacts.get(caso.ContactId).Email;
                }
            }
        }
    }

    public static void cambioContactoEmpleadoBI(List<Case> lstCasos, List<Id> idsCAM) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosModificar = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && (caso.RecordTypeId == rtEmpleado || caso.RecordTypeId == rtBankia)
                && caso.ContactId != null) {
                if (!setIdContacto.contains(caso.ContactId)) {
                    setIdContacto.add(caso.ContactId);
                }
                casosModificar.add(caso);
            }
        }

        if (!setIdContacto.isEmpty()) {
            Map<Id,Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id IN :setIdContacto]);

            for (Case caso : casosModificar) {
                if (mapContacts.containsKey(caso.ContactId) && mapContacts.get(caso.ContactId).Email != null) {
                    caso.CC_MailTelfNotif__c = mapContacts.get(caso.ContactId).Email;
                }
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
    public static void blanqueoAccountBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.AccountId == null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                caso.CC_MailTelfNotif__c = null;
                caso.CC_Numero_Documento__c = null;
                caso.CC_NumPerso__c = null;
            }
        }
    }

    //Método creado a partir del traspaso de PB (cc_Gestion_Caso) a Trigger
    public static void estadoCerradoAI(List<Case> lstCasos) {
        Set<Id> setIdCasos = new Set<Id>();
        Map<Id, Case> casosCerrados = new Map<Id,Case>();
        for (Case caso : lstCasos) {
            if (caso.Status == 'Cerrado' && caso.CC_Resolucion__c != null && caso.OwnerId != null) {
                setIdCasos.add(caso.Id);
                casosCerrados.put(caso.Id, caso);
            }
        }

        if (!setIdCasos.isEmpty()) {
            estadoCerradoAux(setIdCasos, casosCerrados);
        }
    }

    //Método creado a partir del traspaso de PB (cc_Gestion_Caso) a Trigger
    public static void estadoCerradoAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCasos = new Set<Id>();
        Map<Id, Case> casosCerrados = new Map<Id,Case>();
        for (Case caso : lstCasos) {
            if (caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_Resolucion__c != null && caso.OwnerId != null) {
                setIdCasos.add(caso.Id);
                casosCerrados.put(caso.Id, caso);
            }
        }

        if (!setIdCasos.isEmpty()) {
            estadoCerradoAux(setIdCasos, casosCerrados);
        }
    }

    //Método creado a partir del traspaso de PB (cc_Gestion_Caso) a Trigger
    public static void estadoCerradoAux(Set<Id> setIdCasos, Map<Id, Case> mapaCasosCerrados) {
        List<Task> lstTareas = [SELECT Id, WhatId FROM Task WHERE Status = 'Pendiente' AND Type = 'Traslado Tercer Nivel' AND WhatId IN :setIdCasos];

        for (Task tarea : lstTareas) {
            tarea.Status = 'Completed';
            tarea.CC_Tipo_Cierre__c = 'Cierre Tercer Nivel';

            tarea.CC_Fecha_Fin__c = Datetime.now();
            if(mapaCasosCerrados.containsKey(tarea.WhatId) && mapaCasosCerrados.get(tarea.WhatId).CC_Resolucion__c != null){
                tarea.Description = mapaCasosCerrados.get(tarea.WhatId).CC_Resolucion__c;
            }
        }
        if (!lstTareas.isEmpty()) {
            Database.update(lstTareas,false);
        }
        List<CC_Llamada__c> llamadasSalientes = new List<CC_Llamada__c>();
        List<Case> casosUpdate = new List<Case>();
        List<Case> casosFCO = [SELECT Id, CC_Llamada_Saliente__c FROM Case WHERE Id IN :setIdCasos AND CC_Canal_Procedencia__c = 'Formulario Consultas Operativas' AND RecordType.DeveloperName = 'CC_Empleado'];
        if(!casosFCO.isEmpty()){
            llamadasSalientes = [SELECT Id, CC_Case_Consulta__c FROM CC_Llamada__c WHERE CC_Case_Consulta__c IN :casosFCO AND CC_Tipo__c = 'Saliente'];

            if(!llamadasSalientes.isEmpty()){
                for( Case caso : casosFCO ){
                    for( CC_Llamada__c llamada : llamadasSalientes ){

                        if(llamada.CC_Case_Consulta__c == caso.Id){
                            caso.CC_Llamada_Saliente__c = true;
                            casosUpdate.add(caso);
                        }
                    }
                }
            }
        }
        if(!casosUpdate.isEmpty()){
            update casosUpdate;
        }
    }

    //Método creado a partir del traspaso de PB (cc_Gestion_Caso) a Trigger
    public static void creacionCasoBI(List<Case> lstCasos) {
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        List<Case> listaCasosUpdate = new List<Case>();
        for (Schema.RecordTypeInfo rt: lstRT){
            if ((rt.getDeveloperName().left(3)=='CC_')) {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }

        Set<Id> setIdsGrupos = new Set<Id>();
        Map<Id,Group> mapaGruposCasos = new Map<Id, Group>();
        for (Case caso : lstCasos) {
            if(setIdsRt.contains(caso.RecordtypeId)){
                listaCasosUpdate.add(caso);
                if (caso.OwnerId != null && String.valueOf(caso.OwnerId).startsWith('00G')) {
                    setIdsGrupos.add(caso.OwnerId);
                }
            }

        }

        if (!setIdsGrupos.isEmpty()) {
            List<Group> lstGruposCasos = [SELECT Id, DeveloperName FROM Group WHERE Id IN :setIdsGrupos];
            if(!lstGruposCasos.isEmpty()){
                for (Group grupo : lstGruposCasos) {
                    mapaGruposCasos.put(grupo.Id, grupo);
                }
            }
        }

        for (Case caso : listaCasosUpdate) {
            caso.CC_Admin__c = true;
            caso.CC_Tramo_TRZ__c = 'Recibida - En evaluacion';
            caso.CC_CanalNotifCli__c = 'Email';
            caso.CC_Canal_Respuesta__c = caso.Origin;

            if (caso.Origin == 'Twitter') {
                caso.CC_CanalNotifCli__c = 'Twitter';
            }

            if (caso.Origin == null) {
                caso.CC_Canal_Respuesta__c = 'Email';
            } else if (caso.Origin == 'Comentarios Stores') {
                caso.CC_Canal_Respuesta__c = 'Comentarios APPs';
            }

            if (mapaGruposCasos.containsKey(caso.OwnerId)) {
                caso.CC_Cola_Procedencia__c = mapaGruposCasos.get(caso.OwnerId).DeveloperName;
            }
        }
    }
    public static void creacionCasoPropuestasBI(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if (caso.Origin == 'Propuestas de mejora') {
                caso.CC_Descripcion_Problematica__c = caso.Description;
                caso.CC_Titulo_Propuesta__c = caso.Subject;
            }
        }
    }

    public static void seInformaCanalRespuestaBI(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Respuesta_Modificar__c != null && caso.Status != 'Cerrado' && caso.Status != 'Rechazado') {
                caso.CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta_Modificar__c;
            }
        }
    }

    public static void seInformaCanalRespuestaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.CC_Canal_Respuesta_Modificar__c != null && caso.CC_Canal_Respuesta_Modificar__c != mapOldObj.get(caso.Id).CC_Canal_Respuesta_Modificar__c && caso.Status != 'Cerrado' && caso.Status != 'Rechazado') {
                caso.CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta_Modificar__c;
            }
        }
    }

    public static void seAsignaPropietario3NBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        for (Case caso : lstCasos) {
                if (!idsCAM.contains(caso.Id) && caso.Status == 'Pendiente Interno' && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('00G') && String.valueOf(caso.OwnerId).startsWith('005')) {
                    caso.Status = 'Activo';
                }
            }
    }

    public static void actualizarAgrupadorAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> agrupadoresId = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.CC_Agrupador_Id__c != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c != null) {
                agrupadoresId.add(caso.CC_Agrupador_Id__c);
            }
        }

        if(!agrupadoresId.isEmpty()){
            CC_Agrupador_Controller.actualizarAgrupador(agrupadoresId);
        }
    }

    /*public static void revisarReclamacionesTwitterAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> listIdsCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.Status != mapOldObj.get(caso.Id).Status && caso.Status !='Pendiente Cliente' && caso.Origin == 'Twitter'){
                listIdsCasos.add(caso.Id);
            }
        }

        if (!listIdsCasos.isEmpty()) {
            CC_SocialPost_CasoEstadoRecl.CC_SocialPost_CasoEstado_Reclamacion_Gestion(listIdsCasos);
        }
    }*/

	public static void cierreCasoAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> idsCasos = new List<Id>();
        List<Id> idsCasosC = new List<Id>();
        List<Id> idsCasosM = new List<Id>();
        Set<Id> idCausas = new Set<Id>();
        Map<Id, List<CC_Marca_Case__C>> mapCaseMarca = new Map<Id, List<CC_Marca_Case__C>>();
        Date hoy = Date.today();
        Integer d = hoy.day();
        Integer mo = hoy.month();
        Integer yr = hoy.year();
        DateTime fechaHoraActual = DateTime.newInstance(yr, mo, d);
        List<CC_Marca_Case__C> lstMarcaCase = [SELECT CC_Case__c, CC_Marca__c FROM CC_Marca_Case__c WHERE CC_Case__c IN :lstCasos];

        if(!lstMarcaCase.isEmpty()){
            for (CC_Marca_Case__C marca : lstMarcaCase) {
                    Id key = marca.CC_Case__c;
                    if (!mapCaseMarca.containsKey(key)) {
                        mapCaseMarca.put(key, new List<CC_Marca_Case__C>());
                    }
                    mapCaseMarca.get(key).add(marca);
            }
        }

        for (Case caso : lstCasos) {

            if (caso.CreatedDate >= fechaHoraActual && caso.Status == 'Cerrado' && mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.CC_Tipo_Contacto__c != 'Incidencia' && caso.CC_Agrupador_Id__c == null &&
                caso.CC_MCC_Tematica__c != null && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_Motivo__c != null && caso.CC_MCC_Causa__c != null) {
                    if (caso.CC_Campana__c != mapOldObj.get(caso.Id).CC_Campana__c && caso.CC_Campana__c != null) {
                        idsCasosC.add(caso.Id);
                    } else if (mapCaseMarca.containsKey(caso.Id)) {
                        idsCasosM.add(caso.Id);
                    } else if (caso.CreatedDate.date() == System.today()) {
                        idsCasos.add(caso.Id);
                    }
            }
        }
        
        Map<String,Boolean> procesos = new Map<String, Boolean>();
        List <CC_Settings__c> procesosComunicacionesInformativas = [SELECT Name, CC_Activa__c FROM CC_Settings__c 
                                                 WHERE Name IN ('CC_Agrupador_CI_Asignacion_Casos',
                                                                'CC_Agrupador_CIC_Asignacion_Casos',
                                                                'CC_Agrupador_CIM_Asignacion_Casos')];

        for(CC_Settings__c setting : procesosComunicacionesInformativas){
            procesos.put(setting.Name, setting.CC_Activa__c);
        
        }

        if (!idsCasos.isEmpty() && procesos.get('CC_Agrupador_CI_Asignacion_Casos')) {
            CC_Agrupador_CI_Asignacion_Casos.asociarCasosAComunicacionInformativa(idsCasos);
        }
        if(!idsCasosC.isEmpty() && procesos.get('CC_Agrupador_CIC_Asignacion_Casos')) {
            CC_Agrupador_CIC_Asignacion_Casos.asociarCasosAComunicacionInformativa(idsCasosC);
        }
        if(!idsCasosM.isEmpty() && procesos.get('CC_Agrupador_CIM_Asignacion_Casos')) {
            CC_Agrupador_CIM_Asignacion_Casos.asociarCasosAComunicacionInformativa(idsCasosM);
        }
    }

    public static void incrementoEnNumeroReclamacionesClienteAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        CC_Parametros__mdt parametroMd = CC_Parametros__mdt.getInstance('CC_Umbral_Reclamaciones_Cliente_Aviso');
        List<Case> lstCasosReclamados = new List<Case>();
        for (Case caso : lstCasos) {
            if (parametroMd != null && caso.CC_Numero_Reclamaciones_Cliente__c != mapOldObj.get(caso.Id).CC_Numero_Reclamaciones_Cliente__c && caso.CC_Numero_Reclamaciones_Cliente__c > mapOldObj.get(caso.Id).CC_Numero_Reclamaciones_Cliente__c && caso.CC_Numero_Reclamaciones_Cliente__c == parametroMd.Valor_Numerico_Entero__c) {
                lstCasosReclamados.add(caso);
            }
        }

        if (!lstCasosReclamados.isEmpty()) {
            Id idCustomNotification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'CC_Caso_Umbral_Reclamaciones'].Id;
            Id idGrupoCoordinadores = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Coordinadores'].Id;

            if(idGrupoCoordinadores != null){
                for (Case caso : lstCasosReclamados) {
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setBody('El caso '+ caso.CaseNumber + ' ha sido reclamado ' + caso.CC_Numero_Reclamaciones_Cliente__c + ' veces por el cliente. Acceda al Caso aquí.');
                    notification.setTitle('Caso reclamado por cliente');
                    notification.setNotificationTypeId(idCustomNotification);
                    notification.setTargetId(caso.Id);
                    notification.send(new Set<String> { idGrupoCoordinadores });
                }
            }
        }
    }

    public static void actualizarFechaLimiteAU(List<Case> lstCasos) {

        List<Id> idsCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.Status != 'Rechazado' &&
                ((caso.Origin == 'Email' && (caso.CC_Canal_Resolucion__c == 'Atención al Cliente' || caso.CC_Canal_Resolucion__c == 'Oficina Preventiva' || caso.CC_Canal_Resolucion__c == 'Junta Andalucia' || caso.CC_Canal_Resolucion__c == 'Omic' || caso.CC_Canal_Resolucion__c == 'Asociación Consumidores' || caso.CC_Canal_Resolucion__c == 'Dirección'))
                || (caso.Origin == 'Phone' && caso.CC_Canal_Resolucion__c == 'Atención al Cliente'))) {
                idsCasos.add(caso.Id);
            }
        }

        if (!idsCasos.isEmpty()) {
            CC_Agrupador_Fecha_Limite_Caso.asignarFechaLimite(idsCasos);
        }
    }

    public static void empleadoCuentaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        List<Case> casosCuentaRellenada = new List<Case>();
        Set<Id> setCuentasCasos = new Set<Id>();
        for (Case caso : lstCasos) {
                        //if (!idsCAM.contains(caso.Id) && caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId) {

            if (!idsCAM.contains(caso.Id) && caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId && (caso.RecordtypeId == rtEmpleado || caso.RecordtypeId == rtBankia)) {
                casosCuentaRellenada.add(caso);
                if(!setCuentasCasos.contains(caso.AccountId)){
                    setCuentasCasos.add(caso.AccountId);
                }
            }
        }

        if (!casosCuentaRellenada.isEmpty()) {

            Map<Id, Account> mapCuentasCasos = new Map<Id, Account>([SELECT Id, CC_Numero_Oficina__c FROM Account WHERE Id IN :setCuentasCasos]);

            for (Case caso : casosCuentaRellenada) {
                    caso.CC_Oficina_Afectada_Lookup__c = caso.AccountId;
                    caso.CC_Oficina__c = caso.AccountId;
                    caso.CC_Oficina_afectada__c = mapCuentasCasos.get(caso.AccountId).CC_Numero_Oficina__c;
            }
        }
    }

    public static void cuentaDesasociadaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.AccountId == null && caso.AccountId != mapOldObj.get(caso.Id).AccountId) {
                caso.CC_Oficina_Afectada_Lookup__c = null;
                caso.CC_Oficina__c = null;
                caso.CC_Oficina_afectada__c = null;
            }
        }
    }

    public static void asociaActivoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {

        Set<Id> setIdAssets = new Set<Id>();
        List<Case> lstCasosAsociados = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.AssetId != mapOldObj.get(caso.Id).AssetId && caso.AssetId != null) {
                if(!setIdAssets.contains(caso.AccountId)){
                    setIdAssets.add(caso.AssetId);
                }
                lstCasosAsociados.add(caso);
            }
        }
        if(!setIdAssets.isEmpty()){
            Map<Id,Asset> mapAsset = new Map<Id, Asset>([SELECT Id, AccountId FROM Asset WHERE Id IN :setIdAssets AND AccountId != null]);

            for (Case caso : lstCasosAsociados) {
                if (mapAsset.containsKey(caso.AssetId) && caso.CC_Oficina__c != mapAsset.get(caso.AssetId).AccountId) {
                    caso.CC_Oficina__c = mapAsset.get(caso.AssetId).AccountId;
                }
            }
        }
    }

    public static void asociaActivoAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {

        Set<Id> setIdAssets = new Set<Id>();
        List<Case> lstCasosAsociados = new List<Case>();
        List<Id> idsCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.AssetId != mapOldObj.get(caso.Id).AssetId && caso.AssetId != null) {
                if(!setIdAssets.contains(caso.AccountId)){
                    setIdAssets.add(caso.AssetId);
                }
                lstCasosAsociados.add(caso);
            }
        }

        if(!setIdAssets.isEmpty()){
            Map<Id,Asset> mapAsset = new Map<Id, Asset>([SELECT Id, AccountId FROM Asset WHERE Id IN :setIdAssets AND AccountId != null]);

            for (Case caso : lstCasosAsociados) {
                if (mapAsset.containsKey(caso.AssetId) && caso.CC_Oficina__c != mapAsset.get(caso.AssetId).AccountId) {
                    //caso.CC_Oficina__c = mapAsset.get(caso.AssetId).AccountId;
                    idsCasos.add(caso.Id);
                }
            }
        }

        if (!idsCasos.isEmpty()) {
            CC_Avisos_Activo.avisoActivos(idsCasos);
        }
    }

    public static void limpiarCasosLeadsAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> idsCasos = new List<Id>();

        for (Case caso : lstCasos) {

            if (caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status && caso.Origin == 'Phone') {
                idsCasos.add(caso.Id);
            }
        }

        if (!idsCasos.isEmpty()) {
            CC_Borrado_Datos_Leads.borrarDatos(idsCasos);
        }
    }

    public static void notificarEmailAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {

        Set<Id> setIdCasos = new Set<Id>();
        List<Id> idCasosNotificar = new List<Id>();
        for (Case caso : lstCasos) {
            if ((caso.Origin == 'Email' || caso.Origin == 'Teléfono') && caso.CC_Canal_Procedencia__c == 'Atención al Cliente' && caso.CC_Tipo_Contacto__c != 'Llamada sencilla' && caso.AccountId != null && caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_MCC_Motivo__c != null) {
                setIdCasos.add(caso.Id);
            }
        }

        if(!setIdCasos.isEmpty()){
            List<Case> lstCasosNotificar = [SELECT Id FROM Case WHERE Id IN :setIdCasos AND Account.Name != 'CONFIDENCIAL' AND CC_MCC_Motivo__r.Name != 'LOPD'];
            if (!lstCasosNotificar.isEmpty()) {
                for (Case caso : lstCasosNotificar) {
                    idCasosNotificar.add(caso.Id);
                }
            }
            if (!idCasosNotificar.isEmpty()) {
                CC_Notificaciones_Oficina.notificarCasos(idCasosNotificar);
            }
        }
    }

    public static void enviarEncuestaAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosEncuesta = new List<Case>();
        List<Id> idsCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status) {
                if(!setIdContacto.contains(caso.CC_Agrupador_Id__c)){
                    setIdContacto.add(caso.CC_Agrupador_Id__c);
                }
                casosEncuesta.add(caso);
            }
        }

        if(!casosEncuesta.isEmpty() && !setIdContacto.IsEmpty()){
            Map<Id,CC_Agrupador__c> mapAgrupador = new Map<Id,CC_Agrupador__c>([SELECT Id FROM CC_Agrupador__c WHERE Id IN :setIdContacto AND CC_Record_Type_Name__c != 'Incidencia']);

            for (Case caso : casosEncuesta) {
                if (mapAgrupador.containsKey(caso.CC_Agrupador_Id__c) || caso.CC_Agrupador_Id__c == null || (caso.Origin == 'Phone' /*&& caso.Account.CC_Tipo_Centro__c == 'OF' && caso.Account.CC_SubTipo_Centro__c == 'BP'*/ && caso.RecordTypeId == rtEmpleado)) {
                    idsCasos.add(caso.Id);
                }
            }

            if (!idsCasos.isEmpty()) {
                CC_Envio_Encuestas_3N.enviarEncuesta(idsCasos);
            }
        }
    }

    public static void informarAltaGestorAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCasos = new Set<Id>();
        List<Id> idCasosInformar = new List<Id>();

        for (Case caso : lstCasos) {
            if ((caso.Origin == 'Email' || caso.Origin == 'Phone') && caso.Status == 'Activo' && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.CC_Canal_Resolucion__c == 'Atención al Cliente' && caso.CC_Tipo_Contacto__c != 'Llamada sencilla' && caso.AccountId != null && caso.CC_MCC_Motivo__c != null) {
                setIdCasos.add(caso.Id);
            }
        }

        if(!setIdCasos.isEmpty()){
            List<Case> lstCasosInformar = [SELECT Id FROM Case WHERE Id IN :setIdCasos AND Account.Name != 'CONFIDENCIAL' AND Account.AV_EAPGestor__c != null AND Account.AV_EAPGestor__c != null AND CC_MCC_Motivo__r.Name != 'LOPD'];
            if (!lstCasosInformar.isEmpty()) {
                for (Case caso : lstCasosInformar) {
                    idCasosInformar.add(caso.Id);
                }
            }
            if (!idCasosInformar.isEmpty()) {
                CC_Aviso_Alta_GestorInTouch.avisoGestor(idCasosInformar);
            }
        }
    }

    public static void informarCierreGestorAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCasos = new Set<Id>();
        List<Id> idCasosInformar = new List<Id>();

        for (Case caso : lstCasos) {
            if ((caso.Origin == 'Email' || caso.Origin == 'Phone') && caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_Canal_Procedencia__c == 'Atención al Cliente' && caso.CC_Tipo_Contacto__c != 'Llamada sencilla' && caso.AccountId != null && caso.CC_MCC_Motivo__c != null) {
                setIdCasos.add(caso.Id);
            }
        }

        if(!setIdCasos.isEmpty()){
            List<Case> lstCasosInformar = [SELECT Id FROM Case WHERE Id IN :setIdCasos AND Account.Name != 'CONFIDENCIAL' AND Account.AV_EAPGestor__c != null AND Account.AV_EAPGestor__c != null AND CC_MCC_Motivo__r.Name != 'LOPD'];
            if (!lstCasosInformar.isEmpty()) {
                for (Case caso : lstCasosInformar) {
                    idCasosInformar.add(caso.Id);
                }
            }
            if (!idCasosInformar.isEmpty()) {
                CC_Aviso_Cierre_GestorInTouch.avisoGestor(idCasosInformar);
            }
        }
    }

    public static void tematicaInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Tematica__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Tematica__c)){
                    setIdMCC.add(caso.CC_MCC_Tematica__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'tematica');
        }
    }

    public static void productoInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_ProdServ__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_ProdServ__c)){
                    setIdMCC.add(caso.CC_MCC_ProdServ__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'producto');
        }
    }

    public static void motivoInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Motivo__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Motivo__c)){
                    setIdMCC.add(caso.CC_MCC_Motivo__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'motivo');
        }
    }

    public static void causaInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Causa__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Causa__c)){
                    setIdMCC.add(caso.CC_MCC_Causa__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'causa');
        }
    }

    public static void solucionInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Solucion__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Solucion__c)){
                    setIdMCC.add(caso.CC_MCC_Solucion__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'solucion');
        }
    }

    public static void tematicaInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Tematica__c != null && caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Tematica__c)){
                    setIdMCC.add(caso.CC_MCC_Tematica__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'tematica');
        }
    }

    public static void productoInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c) {
                if(!setIdMCC.contains(caso.CC_MCC_ProdServ__c)){
                    setIdMCC.add(caso.CC_MCC_ProdServ__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'producto');
        }
    }

    public static void motivoInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Motivo__c != null && caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Motivo__c)){
                    setIdMCC.add(caso.CC_MCC_Motivo__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'motivo');
        }
    }

    public static void causaInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Causa__c != null && caso.CC_MCC_Causa__c != mapOldObj.get(caso.Id).CC_MCC_Causa__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Causa__c)){
                    setIdMCC.add(caso.CC_MCC_Causa__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'causa');
        }
    }

    public static void solucionInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Solucion__c != null && caso.CC_MCC_Solucion__c != mapOldObj.get(caso.Id).CC_MCC_Solucion__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Solucion__c)){
                    setIdMCC.add(caso.CC_MCC_Solucion__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'solucion');
        }
    }

    public static void mccInformadoAux( List<Case> lstCasosMCC , Set<Id> setIdMCC, String tipoMCC) {
        Map<Id,CC_MCC__c> mapMCCs = new Map<Id,CC_MCC__c>();
        mapMCCs = new Map<Id,CC_MCC__c>([SELECT Id, Name, CC_Codigo_Externo__c FROM CC_MCC__c WHERE Id IN :setIdMCC]);

        if (!mapMCCs.isEmpty()) {
            for (Case caso : lstCasosMCC) {
                switch on tipoMCC {
                    when 'tematica' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Tematica__c)){
                            caso.CC_Codigo_Externo_Tematica__c = mapMCCs.get(caso.CC_MCC_Tematica__c).CC_Codigo_Externo__c;
                            caso.CC_Tematica__c = mapMCCs.get(caso.CC_MCC_Tematica__c).Name;
                        }
                        break;
                    }
                    when 'producto' {
                        if(mapMCCs.containsKey(caso.CC_MCC_ProdServ__c)){
                            caso.CC_Codigo_Externo_Producto__c = mapMCCs.get(caso.CC_MCC_ProdServ__c).CC_Codigo_Externo__c;
                            caso.CC_Producto_Servicio__c = mapMCCs.get(caso.CC_MCC_ProdServ__c).Name;
                        }
                        break;
                    }
                    when 'motivo' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Motivo__c)){
                            caso.CC_Codigo_Externo_Motivo__c = mapMCCs.get(caso.CC_MCC_Motivo__c).CC_Codigo_Externo__c;
                            caso.CC_Motivo__c = mapMCCs.get(caso.CC_MCC_Motivo__c).Name;
                        }
                        break;
                    }
                    when 'causa' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Causa__c)){
                            caso.CC_Codigo_Externo_Causa__c = mapMCCs.get(caso.CC_MCC_Causa__c).CC_Codigo_Externo__c;
                            caso.CC_Causa__c = mapMCCs.get(caso.CC_MCC_Causa__c).Name;
                        }
                        break;
                    }
                    when 'solucion' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Solucion__c)){
                            caso.CC_Solucion__c = mapMCCs.get(caso.CC_MCC_Solucion__c).Name;
                        }
                        break;
                    }
                }
            }
        }
    }

    public static void contactoIncoherenteBI(List<Case> lstCasos) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        //Id rtEmpleadoCSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado_CSI').getRecordTypeId();

        Set<Id> idCuentas = new Set<Id>();
        Set<Id> idContactos = new Set<Id>();
        List<Case> casosComprobar = new List<Case>();

        for (Case caso : lstCasos) {
            if (caso.ContactId != null && caso.AccountId != null && caso.RecordTypeId != null) {
                if(!idCuentas.contains(caso.AccountId)){
                    idCuentas.add(caso.AccountId);
                }
                if(!idContactos.contains(caso.ContactId)){
                    idContactos.add(caso.ContactId);
                }
                casosComprobar.add(caso);
            }
        }

        if(!idCuentas.isEmpty() || !idContactos.isEmpty()){
            Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN :idCuentas]);
            Map<Id,Contact> mapContactos = new Map<Id,Contact>([SELECT Id, RecordType.DeveloperName FROM Contact WHERE Id IN :idContactos]);
            for (Case caso : casosComprobar) {
                if ((!mapCuentas.isEmpty() && mapCuentas.containsKey(caso.AccountId) && (caso.recordTypeId == rtEmpleado && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'CC_ClientePA'
                || caso.recordTypeId == rtCliente && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'CC_Empleado'
                && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'CC_ClientePA'))
                || (!mapContactos.isEmpty() && mapContactos.containsKey(caso.ContactId) && (caso.recordTypeId == rtEmpleado && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'CC_ClientePA'
                || caso.recordTypeId == rtCliente && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'CC_Empleado'
                && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'CC_ClientePA'))) {
                    caso.AccountId = null;
                    caso.ContactId = null;
                }
            }
        }
    }


    public static void contactoIncoherenteBU(List<Case> lstCasos ,Map<Id, Case> mapOldObj, List<Id> idsCAM) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        //Id rtEmpleadoCSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado_CSI').getRecordTypeId();

        Set<Id> idCuentas = new Set<Id>();
        Set<Id> idContactos = new Set<Id>();
        List<Case> casosComprobar = new List<Case>();

        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.ContactId != null && caso.AccountId != null && caso.RecordTypeId != null && caso.ContactId != mapOldObj.get(caso.Id).ContactId) {
                if(!idCuentas.contains(caso.AccountId)){
                    idCuentas.add(caso.AccountId);
                }
                if(!idContactos.contains(caso.ContactId)){
                    idContactos.add(caso.ContactId);
                }
                casosComprobar.add(caso);
            }
        }

        if(!idCuentas.isEmpty() || !idContactos.isEmpty()){
            Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN :idCuentas]);
            Map<Id,Contact> mapContactos = new Map<Id,Contact>([SELECT Id, RecordType.DeveloperName FROM Contact WHERE Id IN :idContactos]);
            for (Case caso : casosComprobar) {
                if ((!mapCuentas.isEmpty() && mapCuentas.containsKey(caso.AccountId) && (caso.recordTypeId == rtEmpleado && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'CC_ClientePA'
                || caso.recordTypeId == rtCliente && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'CC_Empleado'
                && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'CC_ClientePA'))
                || (!mapContactos.isEmpty() && mapContactos.containsKey(caso.ContactId) && (caso.recordTypeId == rtEmpleado && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'CC_ClientePA'
                || caso.recordTypeId == rtCliente && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'CC_Empleado'
                && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'CC_ClientePA'))) {
                    caso.AccountId = null;
                    caso.ContactId = null;
                }
            }
        }
    }

    public static void actualizarColaProcedenciaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        List<Case> lstCasosComprobar = new List<Case>();
        Set<Id> setIdGrupos = new Set<Id>();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(caso.OwnerId).startsWith('00G') && caso.Origin == 'Email') {
                if(!setIdGrupos.contains(caso.OwnerId)){
                    setIdGrupos.add(caso.OwnerId);
                }
                lstCasosComprobar.add(caso);
            }
        }

        if(!lstCasosComprobar.isEmpty()){
            Map<Id, Group> mapColas = new Map<Id, Group>([SELECT Id, DeveloperName FROM Group WHERE Id IN: setIdGrupos]);

            for (Case caso : lstCasosComprobar) {
                if(caso.CC_Canal_procedencia__c != 'Formulario Consultas Operativas')
                {
                    if(mapColas.containsKey(caso.OwnerId) && caso.CC_Cola_Procedencia__c != mapColas.get(caso.OwnerId).DeveloperName){
                        caso.CC_Cola_Procedencia__c = mapColas.get(caso.OwnerId).DeveloperName;
                    }
                }
            }
        }
    }

    public static void informarOficinaAfectadaDetalleBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        for (Case caso : lstCasos) {
            if (!idsCAM.contains(caso.Id) && caso.CC_Oficina__c != mapOldObj.get(caso.Id).CC_Oficina__c && caso.CC_Oficina__c != null && caso.AccountId == null && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia ) {
                caso.CC_Oficina_Afectada_Lookup__c = caso.CC_Oficina__c;
            }
        }
    }

    public static void informarOficinaAfectadaBI(List<Case> lstCasos) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosOficina = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia ) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosOficina.add(caso);
            }
        }
        Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, AV_OficinaPrincipal__c FROM Account WHERE Id IN :setIdCuentas AND AV_OficinaPrincipal__c != null]);
        for (Case caso : casosOficina) {
            if (mapCuentas.containsKey(caso.AccountId)) {
                caso.CC_Oficina_Afectada_Lookup__c = mapCuentas.get(caso.AccountId).AV_OficinaPrincipal__c;
            }
        }
    }

    public static void altaPeticionTRZBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> listIdCasos = new List<Id>();
        for (Case caso : lstCasos) {
            if (caso.CC_Oficina_Afectada_Lookup__c != mapOldObj.get(caso.Id).CC_Oficina_Afectada_Lookup__c || caso.CC_Fecha_Limite_Resolucion__c != null || (caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId )){
                listIdCasos.add(caso.id);
            }
        }
        if (!listIdCasos.isEmpty()) {
            CC_Trazabilidad_Methods.altaPeticion(listIdCasos);
        }
    }

    public static void informarDireccionTerritorialAU(List<Case> lstCasos, Map<Id, Case> mapOldObj/*, List<Id> idsCAM*/) {
        List<Id> listIdCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (/*!idsCAM.contains(caso.Id) &&*/ caso.CC_Oficina_Afectada_Lookup__c != null && caso.AccountId != null && (mapOldObj.get(caso.Id).AccountId != caso.AccountId || mapOldObj.get(caso.Id).CC_Oficina_Afectada_Lookup__c != caso.CC_Oficina_Afectada_Lookup__c)) {
                listIdCasos.add(caso.id);

            }
        }
        if (!listIdCasos.isEmpty()) {
            CC_Informar_DT_Caso.informaDireccionTerritorial(listIdCasos);
        }
    }

    public static void informarDireccionTerritorialAI(List<Case> lstCasos) {
        List<Id> listIdCasos = new List<Id>();
        for (Case caso : lstCasos) {
            if (caso.CC_Oficina_Afectada_Lookup__c != null && caso.AccountId != null) {
                listIdCasos.add(caso.Id);
            }
        }
        if (!listIdCasos.isEmpty()) {
            CC_Informar_DT_Caso.informaDireccionTerritorial(listIdCasos);
        }
    }

    public static Map<Id, CC_MCC__c> obtencionMCCAplicacionesYServicios() {
        Map<Id, CC_MCC__c> mapMCC = new Map<Id, CC_MCC__c>([SELECT Id, Name FROM CC_MCC__c WHERE Name IN ('Aplicaciones y servicios oficina','Protección de datos','LOPD')]);
        return mapMCC;
    }


    public static void nuevoCasoPreventivaAI(List<Case> lstCasos, Map<Id, CC_MCC__c> mapMCC) {
        List<Case> lstCasosPreventiva = new List<Case>();
        List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'
            && (caso.CC_MCC_Tematica__c == null || (caso.CC_MCC_Tematica__c != null && !mapMCC.containsKey(caso.CC_MCC_Tematica__c)))
            && (caso.CC_MCC_ProdServ__c == null || (caso.CC_MCC_ProdServ__c != null && !mapMCC.containsKey(caso.CC_MCC_ProdServ__c)))
            && (caso.CC_MCC_Motivo__c == null || (caso.CC_MCC_Motivo__c != null && !mapMCC.containsKey(caso.CC_MCC_Motivo__c)))
            && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && !caso.CC_Notif_Cont_Inter__c ) {
                lstCasosPreventiva.add(caso);
            }
        }

        if (!lstCasosPreventiva.isEmpty()) {
            for (Case casoSchedule : lstCasosPreventiva) {
                if(casoSchedule.CC_Cont_Interm_Delay__c != null) {
                    DateTime diasSchedule = casoSchedule.CC_Cont_Interm_Delay__c.addDays(6);
                    lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c= diasSchedule,
                    ClassName__c = 'CC_NotifContIntPreventiva', RecordId__c = casoSchedule.Id));
                }
            }
        }
    }

    public static void nuevoCasoPreventivaAU(List<Case> lstCasos, Map<Id, Case> mapOldObj, Map<Id, CC_MCC__c> mapMCC) {
        List<Case> lstCasosPreventiva = new List<Case>();
        List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
        for (Case caso : lstCasos) {
            if ((caso.CC_Canal_Resolucion__c != mapOldObj.get(caso.Id).CC_Canal_Resolucion__c || caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c || caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c || caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c)
            && caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'
            && (caso.CC_MCC_Tematica__c == null || (caso.CC_MCC_Tematica__c != null && !mapMCC.containsKey(caso.CC_MCC_Tematica__c)))
            && (caso.CC_MCC_ProdServ__c == null || (caso.CC_MCC_ProdServ__c != null && !mapMCC.containsKey(caso.CC_MCC_ProdServ__c)))
            && (caso.CC_MCC_Motivo__c == null || (caso.CC_MCC_Motivo__c != null && !mapMCC.containsKey(caso.CC_MCC_Motivo__c)))
            && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && !caso.CC_Notif_Cont_Inter__c ) {
                lstCasosPreventiva.add(caso);
            }
        }

        if (!lstCasosPreventiva.isEmpty()) {
            for (Case casoSchedule : lstCasosPreventiva) {
                if(casoSchedule.CC_Cont_Interm_Delay__c != null) {
                    DateTime diasSchedule = casoSchedule.CC_Cont_Interm_Delay__c.addDays(6);
                    lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c = diasSchedule,
                    ClassName__c = 'CC_NotifContIntPreventiva', RecordId__c = casoSchedule.Id));
                }
            }
        }
    }

    public static void notificacionAgenteNoCiAU(List<Case> lstCasos, Map<Id, Case> mapOldObj, Map<Id, CC_MCC__c> mapMCC) {
        List<Case> lstCasosPreventiva = new List<Case>();
        List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
        for (Case caso : lstCasos) {
            if ((caso.CC_Canal_Resolucion__c != mapOldObj.get(caso.Id).CC_Canal_Resolucion__c || caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c || caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c || caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c)
            && caso.CC_Canal_Procedencia__c == 'Atención al Cliente' && caso.Origin == 'Phone'
            && (caso.CC_MCC_Tematica__c == null || (caso.CC_MCC_Tematica__c != null && !mapMCC.containsKey(caso.CC_MCC_Tematica__c)))
            && (caso.CC_MCC_ProdServ__c == null || (caso.CC_MCC_ProdServ__c != null && !mapMCC.containsKey(caso.CC_MCC_ProdServ__c)))
            && (caso.CC_MCC_Motivo__c == null || (caso.CC_MCC_Motivo__c != null && !mapMCC.containsKey(caso.CC_MCC_Motivo__c)))
            && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && !caso.CC_Notif_Cont_Inter__c && caso.CC_Tipo_Contacto__c != 'Llamada sencilla'
            && (caso.CC_MailTelfNotif__c == '' || caso.CC_MailTelfNotif__c == null) ) {
                lstCasosPreventiva.add(caso);
            }
        }

        if (!lstCasosPreventiva.isEmpty()) {
            for (Case casoSchedule : lstCasosPreventiva) {
                if(casoSchedule.CC_Cont_Interm_Delay__c != null) {
                    DateTime diasSchedule = casoSchedule.CC_Cont_Interm_Delay__c.addDays(6);
                    lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c= diasSchedule,
                    ClassName__c = 'CC_NotifAgenteNoCI', RecordId__c = casoSchedule.Id));
                }
            }
        }
    }

    public static void notificacionAgenteNoCiAI(List<Case> lstCasos, Map<Id, CC_MCC__c> mapMCC) {
        List<Case> lstCasosPreventiva = new List<Case>();
        List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente' && caso.Origin == 'Phone'
            && (caso.CC_MCC_Tematica__c == null || (caso.CC_MCC_Tematica__c != null && !mapMCC.containsKey(caso.CC_MCC_Tematica__c)))
            && (caso.CC_MCC_ProdServ__c == null || (caso.CC_MCC_ProdServ__c != null && !mapMCC.containsKey(caso.CC_MCC_ProdServ__c)))
            && (caso.CC_MCC_Motivo__c == null || (caso.CC_MCC_Motivo__c != null && !mapMCC.containsKey(caso.CC_MCC_Motivo__c)))
            && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && !caso.CC_Notif_Cont_Inter__c && caso.CC_Tipo_Contacto__c != 'Llamada sencilla'
            && (caso.CC_MailTelfNotif__c == '' || caso.CC_MailTelfNotif__c == null) ) {
                lstCasosPreventiva.add(caso);
            }
        }

        if (!lstCasosPreventiva.isEmpty()) {
            for (Case casoSchedule : lstCasosPreventiva) {
                if(casoSchedule.CC_Cont_Interm_Delay__c != null) {
                    DateTime diasSchedule = casoSchedule.CC_Cont_Interm_Delay__c.addDays(6);
                    lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c= diasSchedule,
                    ClassName__c = 'CC_NotifAgenteNoCI', RecordId__c = casoSchedule.Id));
                }
            }
        }
    }

    public static void nuevoCasoACAU(List<Case> lstCasos, Map<Id, Case> mapOldObj, Map<Id, CC_MCC__c> mapMCC) {
        List<Case> lstCasosPreventiva = new List<Case>();
        List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
        for (Case caso : lstCasos) {
            if ((caso.CC_Canal_Resolucion__c != mapOldObj.get(caso.Id).CC_Canal_Resolucion__c || caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c || caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c || caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c)
            && caso.CC_Canal_Procedencia__c == 'Atención al Cliente'
            && (caso.CC_Canal_Resolucion__c == 'Atención al Cliente' || caso.CC_Canal_Resolucion__c == 'Junta Andalucia' || caso.CC_Canal_Resolucion__c == 'Omic' || caso.CC_Canal_Resolucion__c == 'Asociación Consumidores' || caso.CC_Canal_Resolucion__c == 'Dirección' || caso.CC_Canal_Resolucion__c == 'Formulario Web AC')
            && (caso.CC_MCC_Tematica__c == null || (caso.CC_MCC_Tematica__c != null && !mapMCC.containsKey(caso.CC_MCC_Tematica__c)))
            && (caso.CC_MCC_ProdServ__c == null || (caso.CC_MCC_ProdServ__c != null && !mapMCC.containsKey(caso.CC_MCC_ProdServ__c)))
            && (caso.CC_MCC_Motivo__c == null || (caso.CC_MCC_Motivo__c != null && !mapMCC.containsKey(caso.CC_MCC_Motivo__c)))
            && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && !caso.CC_Notif_Cont_Inter__c && caso.CC_Tipo_Contacto__c != 'Llamada sencilla') {
                lstCasosPreventiva.add(caso);
            }
        }

        if (!lstCasosPreventiva.isEmpty()) {
            for (Case casoSchedule : lstCasosPreventiva) {
                if(casoSchedule.CC_Cont_Interm_Delay__c != null) {
                    DateTime diasSchedule = casoSchedule.CC_Cont_Interm_Delay__c.addDays(6);
                    lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c= diasSchedule,
                    ClassName__c = 'CC_NotifContInterAC', RecordId__c = casoSchedule.Id));
                }
            }
        }
    }

    public static void nuevoCasoACAI(List<Case> lstCasos, Map<Id, CC_MCC__c> mapMCC) {
        List<Case> lstCasosPreventiva = new List<Case>();
        List<CBK_SCH_PendingProcess__c> lstSchedule = new List<CBK_SCH_PendingProcess__c>();
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente'
            && (caso.CC_Canal_Resolucion__c == 'Atención al Cliente' || caso.CC_Canal_Resolucion__c == 'Junta Andalucia' || caso.CC_Canal_Resolucion__c == 'Omic' || caso.CC_Canal_Resolucion__c == 'Asociación Consumidores' || caso.CC_Canal_Resolucion__c == 'Dirección' || caso.CC_Canal_Resolucion__c == 'Formulario Web AC')
            && (caso.CC_MCC_Tematica__c == null || (caso.CC_MCC_Tematica__c != null && !mapMCC.containsKey(caso.CC_MCC_Tematica__c)))
            && (caso.CC_MCC_ProdServ__c == null || (caso.CC_MCC_ProdServ__c != null && !mapMCC.containsKey(caso.CC_MCC_ProdServ__c)))
            && (caso.CC_MCC_Motivo__c == null || (caso.CC_MCC_Motivo__c != null && !mapMCC.containsKey(caso.CC_MCC_Motivo__c)))
            && caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && !caso.CC_Notif_Cont_Inter__c && caso.CC_Tipo_Contacto__c != 'Llamada sencilla') {
                lstCasosPreventiva.add(caso);
            }
        }

        if (!lstCasosPreventiva.isEmpty()) {
            for (Case casoSchedule : lstCasosPreventiva) {
                if(casoSchedule.CC_Cont_Interm_Delay__c != null) {
                    DateTime diasSchedule = casoSchedule.CC_Cont_Interm_Delay__c.addDays(6);
                    lstSchedule.add(new CBK_SCH_PendingProcess__c(Schedule_Time__c= diasSchedule,
                    ClassName__c = 'CC_NotifContInterAC', RecordId__c = casoSchedule.Id));
                }
            }
        }
    }

    public static String metodoMatcher(String campoCaso){

		// Se establece un patrón para el PAN
		String panRegex = '[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}';
		Pattern myPattern = Pattern.compile(panRegex);
        String encryptedPan;
		String campoCasoMatcher;

			Integer lognitudCampo = campoCaso.length();
			Matcher asuntoMatcher = myPattern.matcher(campoCaso);

			while (asuntoMatcher.find()) {
				encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
				Integer indexIncio = campoCaso.indexOf(asuntoMatcher.group()) != null ? campoCaso.indexOf(asuntoMatcher.group()): 0;
				Integer indexFinal = indexIncio + asuntoMatcher.group().length();
				Integer resta = 0;
				if (lognitudCampo != campoCaso.length()) {
					resta = lognitudCampo - campoCaso.length();
					indexIncio = indexIncio-resta;
					indexFinal = indexFinal-resta;
					lognitudCampo = campoCaso.length();

				}
				Boolean caracterDelante = false;
				if(indexIncio -1 > 0){
					caracterDelante = (indexIncio == 0) ? false : campoCaso.split('').get(indexIncio-1).isNumeric();
				}
				caracterDelante = (indexIncio == 0) ? false : campoCaso.split('').get(indexIncio-1).isNumeric();
				Boolean caracterDetras = (indexFinal == campoCaso.length()) ? false : campoCaso.split('').get(indexFinal).isNumeric();

				//Hay que mirar el inicio y el final de cada patrón para ver si hay un numérico.
				if (caracterDetras || caracterDelante){
					encryptedPan = asuntoMatcher.group();
				}
				campoCasoMatcher = campoCaso.replace(asuntoMatcher.group(), encryptedPan);
			}

            if(!String.isEmpty(campoCasoMatcher)){
                return campoCasoMatcher;
            }else{
                return campoCaso;
            }
	}
    /*
    public static void generarEncuestaHDT1N(List<Case> lstCasos, Map<Id, Case> oldMap){
        List<Case> lstCasosHDT = new List<Case>();
        for (Case caso : lstCasos) {
            if(oldMap.containsKey(caso.Id)){
                if (caso.CC_Resuelto_Primer_Contacto__c && caso.Origin == 'Phone' && caso.Status =='Cerrado' && oldMap.get(caso.Id).Status != 'Cerrado' && (caso.CC_Canal_Resolucion__c == 'Incidencias Técnicas' || caso.CC_Canal_Resolucion__c == 'Servicios Centrales' || caso.CC_Canal_Resolucion__c == 'SmartPhones')) {
                    lstCasosHDT.add(caso);
                }
            }
        }
        if(!lstCasosHDT.isEmpty()){
            List<CC_Envio_Encuesta__c> linkEncuestaEmpleado =[SELECT  CC_Id_Encuesta__c, CC_Link_LimeSurvey__c, CC_Tipo_Encuesta__c FROM CC_Envio_Encuesta__c WHERE CC_Id_Encuesta__c = '261467' LIMIT 1];
            if(!linkEncuestaEmpleado.isEmpty()){
                Map<Id, Case> mapInfoCasos = new Map<Id, Case>([SELECT Origin, CaseNumber, Contact.Email, CC_Idioma__c, CC_URL_Encuesta_3N__c,CC_Matricula_Empleado__c, CC_MCC_Tematica__r.name, CC_MCC_Tematica__r.CC_idCognitivo__c, CC_MCC_Tematica__c FROM Case WHERE Id IN :lstCasosHDT]);
                for(Case casoFiltrado : lstCasosHDT){
                        //Case casoCopia= new Case(Id = casoFiltrado.Id);
                        casoFiltrado.CC_URL_Encuesta_3N__c = linkEncuestaEmpleado[0].CC_Link_LimeSurvey__c+'sid='+linkEncuestaEmpleado[0].CC_Id_Encuesta__c+'&lang='+
                        mapInfoCasos.get(casoFiltrado.Id).CC_Idioma__c+'&userid='+mapInfoCasos.get(casoFiltrado.Id).CC_Matricula_Empleado__c+'&ticketid='+mapInfoCasos.get(casoFiltrado.Id).CaseNumber+'&idet='+mapInfoCasos.get(casoFiltrado.Id).CC_MCC_Tematica__c+'&et='+ mapInfoCasos.get(casoFiltrado.Id).CC_MCC_Tematica__r.name.replace(' ', '_')+ '&newtest=Y';
                }
            }
        }

    }
*/
/*
    public static void cierreCasoHDT1N(List<Case> lstCasos, Map<Id, Case> oldMap) {
        List<Case> lstCasosHDT = new List<Case>();
        for (Case caso : lstCasos) {
            if(oldMap.containsKey(caso.Id)){
                if (caso.CC_Resuelto_Primer_Contacto__c && caso.Origin == 'Phone' && caso.Status =='Cerrado' && oldMap.get(caso.Id).Status != 'Cerrado' && (caso.CC_Canal_Resolucion__c == 'Incidencias Técnicas' || caso.CC_Canal_Resolucion__c == 'Servicios Centrales' || caso.CC_Canal_Resolucion__c == 'SmartPhones')) {
                    lstCasosHDT.add(caso);
                }
            }
        }

        if(!lstCasosHDT.isEmpty()){
            List<CC_Envio_Encuesta__c> linkEncuestaEmpleado =[SELECT  CC_Id_Encuesta__c, CC_Link_LimeSurvey__c, CC_Tipo_Encuesta__c FROM CC_Envio_Encuesta__c WHERE CC_Id_Encuesta__c = '261467' LIMIT 1];
            if(!linkEncuestaEmpleado.isEmpty()){
                Map<Id, Case> mapInfoCasos = new Map<Id, Case>([SELECT Origin, CaseNumber, Contact.Email, CC_Idioma__c, CC_URL_Encuesta_3N__c,CC_Matricula_Empleado__c, CC_MCC_Tematica__r.name, CC_MCC_Tematica__r.CC_idCognitivo__c, CC_MCC_Tematica__c FROM Case WHERE Id IN :lstCasosHDT]);
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

                EmailTemplate plantillaCas = [SELECT Id,HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Encuesta_1N_HDT_1664260886802' LIMIT 1];
                EmailTemplate plantillaCat = [SELECT Id,HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Enquesta_1N_HDT_1664261031880' LIMIT 1];

                List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                        WHERE CC_Canal_Procedencia__c = :lstCasosHDT[0].CC_Canal_Procedencia__c
                                                        AND CC_Idioma__c =: lstCasosHDT[0].CC_Idioma__c];


                if (buzones.isEmpty()) {
                    buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                        WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c =: lstCasosHDT[0].CC_Idioma__c
                        AND CC_Activo__c = true];
                }

                if (buzones.isEmpty()) {
                    buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                            WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano'
                            AND CC_Activo__c = true];
                }
                String remitente;
                Id remitenteId;
                if (!buzones.isEmpty()) {
                    remitente = buzones[0].CC_Direccion_Correo__c;
                }
                if(remitente != null){
                    remitenteId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :remitente LIMIT 1].Id;
                }
                List<Case> lstCasosCopia = new List<Case>();
                for(Case casoFiltrado : lstCasosHDT){

                    List<String> body= new List<String>();
                    String subject;
                    //lstCasosCopia.add(casoCopia);
                    if(casoFiltrado.CC_Idioma__c == 'ca'){
                        body.add(plantillaCat.HtmlValue);
                        subject = plantillaCat.Subject;
                    }
                    else{
                        body.add(plantillaCas.HtmlValue);
                        subject = plantillaCas.Subject;
                    }
                    String stringFinal;

                    List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(UserInfo.getUserId(), casoFiltrado.Id, body);
                    if(!resList.isEmpty()){
                        stringFinal = resList[0].getMergedBody();
                    }


                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // mail.setTemplateId(plantilla.Id);
                    //System.debug('testing body ' + stringFinal);
                     mail.htmlBody = stringFinal;
                     mail.setSubject(subject + ' - ' + casoFiltrado.CaseNumber);
                     mail.setSaveAsActivity(true);
                     mail.setWhatId(casoFiltrado.Id);
                     mail.setTargetObjectId(casoFiltrado.ContactId);
                     mail.setTreatTargetObjectAsRecipient(false);
                     String[] toAddresses = new String[] {mapInfoCasos.get(casoFiltrado.Id).Contact.Email};
                         mail.setToAddresses(toAddresses);
                     mail.setOrgWideEmailAddressId(remitenteId);
                     allmsg.add(mail);

                }

               // if(!lstCasosCopia.isEmpty()){
                 //   update lstCasosCopia;
                //}

                if (!allmsg.isEmpty()){
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);
                }
            }
        }
    }
*/
    public static void comprobacionTransferBU(List<Case> lstCasos, Map<Id, Case> mapOldObj, List<Id> idsCAM) {
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId) {
                if (!idsCAM.contains(caso.Id) && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('00G') && String.valueOf(caso.OwnerId).startsWith('00G')/* &&
                ((caso.Status.startsWith('Pendiente') && mapOldObj.get(caso.Id).Status != caso.Status) || caso.CC_Grupo_Transfer__c == null)*/) {
                    caso.CC_Grupo_Transfer__c = caso.OwnerId;
                }
            }
        }
    }

    public static void reaperturaNoValida(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        //Conseguir los emails
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosReapertura = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado' && caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' && caso.CC_Reapertura_Valida__c == 'No') {
                if (!setIdContacto.contains(caso.ContactId)) {
                    setIdContacto.add(caso.ContactId);
                }
                casosReapertura.add(caso);
            }
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Map <String,OrgWideEmailAddress> owasMap = new Map<String,OrgWideEmailAddress>();
        for (OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            owasMap.put(String.valueOf(owa.Address), owa);
        }
        List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
        List<EmailTemplate> htmlBodyCas = [SELECT Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_ReaperturaNoValida_FCO_cas' LIMIT 1];
        List<EmailTemplate> htmlBodyCat = [SELECT Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_ReaperturaNoValida_FCO_cat' LIMIT 1];
        List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
        owa.add(owasMap.get(owaPorDefecto[0].CC_Direccion_Correo__c));
        if (!setIdContacto.isEmpty()) {
            Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Email FROM Contact WHERE Id IN :setIdContacto]);
            for (Case caso : casosReapertura) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if (caso.CC_Idioma__c == 'ca') {
                    email.setHtmlBody(htmlBodyCat[0].HtmlValue);
                    email.subject = htmlBodyCat[0].Subject;
                } else {
                    email.setHtmlBody(htmlBodyCas[0].HtmlValue);
                    email.subject = htmlBodyCas[0].Subject;
                }
                email.setSaveAsActivity(true);
                email.setTreatBodiesAsTemplate(true);
                email.setWhatId(caso.Id);
                email.setTargetObjectId(caso.ContactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setOrgWideEmailAddressId(owa[0].Id);
                List<String> toAddress = new List<String>();
                if (mapContacts.containsKey(caso.ContactId) && mapContacts.get(caso.ContactId).Email != null) {
                    toAddress.add(mapContacts.get(caso.ContactId).Email);
                }
                email.setToAddresses(toAddress);
                allmsg.add(email);
            }
        }
        
        if (!allmsg.isEmpty()){
            //Enviamos todos los mensajes
            try{
                Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false);
            }catch(exception e){
                String exc = e.getMessage();
                CBK_Log.error(e + '-' + exc);
                CBK_Log.error('Resultado error: ' + e);
            }
        }
    }

}