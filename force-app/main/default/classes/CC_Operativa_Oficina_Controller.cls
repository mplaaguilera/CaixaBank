public with sharing class CC_Operativa_Oficina_Controller {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDatos(Id recordId) {
        if (String.isBlank(recordId)) {
            return null;
        } else {
            Map<String, Object> retorno = new Map<String, Object>();
            Case caso = [SELECT CC_MCC_Tematica__c, CC_Derivar__c, CC_Canal_Operativo__c, AssetId, CC_MCC_Motivo__c, CC_MCC_Motivo__r.CC_Alerta_Caixa__c,CC_MCC_Motivo__r.CC_Alerta_Imagin__c, 
            Account.LastName, Account.AV_OficinaPrincipal__r.Name, CC_MCC_Motivo__r.Name, CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, Account.AV_EAPGestor__r.AccountId, Account.AV_OficinaPrincipal__c, 
            Account.FirstName, Account.CC_Numero_Documento__c, Account.AV_Cliente__c, CC_MCC_Solucion__r.Name, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, Account.Recordtype.Developername,
            CC_MCC_Solucion__r.CC_AmbitoTareas__c, Account.Name, CC_Detalles_Consulta__c, Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c, Account.AV_Confidencial__c, Account.AV_NumPerso__c,
            CC_Status_Autorizacion__c, CC_OTP_Nivel__c, CC_OTP_Valido__c, Account.AV_IndicadoresClientes__c, Account.AV_EAPGestor__c, Account.AV_EAPGestor__r.Name, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c
            FROM Case WHERE Id = :recordId LIMIT 1];
            List<CC_MCC_Grupo_Colaborador__c> listaGrupoColaborador = [SELECT Id, Name FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c in (:caso.CC_MCC_Motivo__c, :caso.CC_MCC_ProdServ__C) LIMIT 1];
            List<CC_Lista_Valores__c> textos = [SELECT Name, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Textos operativa Derivar' AND CC_Activa__c = true];
            Map<String, String> textosMap = new Map<String, String>();
            Boolean ambitoVentas = false;
            Boolean ambitoCSBD = false;
            Boolean imagin = false;
            String ambitoMotivo;
            Map<String, String> gestorGenerico = buscarGestorGenerico();
            String gestorGenericoName = gestorGenerico.get('nombre');
            
            for(CC_Lista_Valores__c texto : textos) {
                textosMap.put(texto.Name, texto.CC_Mensajes_Mostrar__c);
            }

            if(caso.Account.AV_IndicadoresClientes__c != null && caso.Account.AV_IndicadoresClientes__c.contains('28')) {
                imagin = true;
                ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c;
                retorno.put('alerta', caso.CC_MCC_Motivo__r.CC_Alerta_Imagin__c);
            } else {
                ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c;
                retorno.put('alerta', caso.CC_MCC_Motivo__r.CC_Alerta_Caixa__c);
            }

            if(/*!imagin && */(ambitoMotivo == 'CSBD 3N' || ambitoMotivo == 'CSBD Contratar' || ambitoMotivo == 'CSBD No Contratar')) {
                ambitoCSBD = true;
            }
            
            if(caso.CC_MCC_Solucion__r.CC_AmbitoTareas__c == 'Fraude') {
                retorno.put('toastTrasladarDesdeDerivar', textosMap.get('Toast remitir desde guardar'));
                retorno.put('preguntaSenal', textosMap.get('Pregunta señal'));
                retorno.put('preguntaRealizarRemitido', textosMap.get('Pregunta realizar remitido'));
                retorno.put('toastRemitir', textosMap.get('Toast remitir'));
                retorno.put('ambitoFraude', true);
            }
            
            if(caso.Account.AV_Confidencial__c) {
                retorno.put('toastTrasladar3N', textosMap.get('Toast traslado 3N confidencial'));
            } else {
                if(!listaGrupoColaborador.isEmpty()) {
                    retorno.put('preguntaGrupoColaborador', textosMap.get('Pregunta traslado colaborador'));
                    retorno.put('toastTrasladarDesdeDerivar', textosMap.get('Toast trasladar desde guardar'));
                    retorno.put('grupoColaborador', listaGrupoColaborador[0]);
                }
                if(!caso.Account.AV_Cliente__c && (caso.Account.Recordtype.Developername == 'CC_ClientePA'|| caso.Account.Recordtype.Developername == 'CC_Cliente')) {
                    retorno.put('cambioOficina', true);
                    retorno.put('mostrarModalCreacionTarea', true);
                } else if(ambitoMotivo == '' || ambitoMotivo == null) {
                    if(imagin) {
                        retorno.put('mostrarModalCreacionTarea', true);
                    } else {
                        ambitoVentas = true;
                    }
                } else if(ambitoMotivo == 'Ventas') {
                    if(imagin) {
                        retorno.put('mostrarModalCreacionTarea', true);
                    } else {
                        ambitoVentas = true;
                    }
                } else if(ambitoMotivo == 'Oficina') {
                    if(imagin) {
                        retorno.put('mostrarModalCreacionTarea', true);
                    } else {
                        ambitoVentas = true;
                    }
                } else if(ambitoMotivo == 'Cambio de oficina') {
                    if(caso.Account.CC_Numero_Documento__c == null || caso.Account.AV_OficinaPrincipal__c == null) {
                        throw new AuraHandledException('El cliente debe tener número de documento y oficina principal asignada');
                    } else {
                        String comentarioCambioOficina = textosMap.get('Comentario cambio oficina');
                        comentarioCambioOficina = comentarioCambioOficina.replace('[dni]', caso.Account.CC_Numero_Documento__c);
                        comentarioCambioOficina = comentarioCambioOficina.replace('[oficina origen]', caso.Account.AV_OficinaPrincipal__r.Name);
                        if (caso.Account.Recordtype.Developername == 'CC_Cliente' && caso.Account.Name != null) {
                            comentarioCambioOficina = comentarioCambioOficina.replace('[nombre], [apellidos]', caso.Account.Name);
                        } else if(caso.Account.Recordtype.Developername == 'CC_ClientePA') {
                            if(caso.Account.FirstName != null) {
                                comentarioCambioOficina = comentarioCambioOficina.replace('[nombre]', caso.Account.FirstName);
                            }
                            if(caso.Account.LastName != null) {
                                comentarioCambioOficina = comentarioCambioOficina.replace('[apellidos]', caso.Account.LastName);
                            }
                        }
                        retorno.put('comentarioCambioOficina', comentarioCambioOficina);
                        retorno.put('mostrarModalCreacionTarea', true);
                        retorno.put('cambioOficina', true);
                    }
                } else if(ambitoMotivo == 'Cambio de gestor') {
                    if(caso.Account.CC_Numero_Documento__c == null) {
                        throw new AuraHandledException('El cliente debe tener número de documento y oficina principal asignada');
                    } else {
                        String comentarioCambioGestor = textosMap.get('Comentario cambio gestor');
                        comentarioCambioGestor = comentarioCambioGestor.replace('[dni]', caso.Account.CC_Numero_Documento__c);
                        if(caso.Account.Recordtype.Developername == 'CC_Cliente' && caso.Account.Name != null) {
                            comentarioCambioGestor = comentarioCambioGestor.replace('[nombre], [apellidos]', caso.Account.Name);
                        } else if(caso.Account.Recordtype.Developername == 'CC_ClientePA') {
                            if(caso.Account.FirstName != null) {
                                comentarioCambioGestor = comentarioCambioGestor.replace('[nombre]', caso.Account.FirstName);
                            }
                            if(caso.Account.LastName != null) {
                                comentarioCambioGestor = comentarioCambioGestor.replace('[apellidos]', caso.Account.LastName);
                            }
                        }
                        retorno.put('comentarioCambioGestor', comentarioCambioGestor);
                        retorno.put('mostrarModalCreacionTarea', true);
                        retorno.put('cambioGestor', true);
                    }
                } else if(ambitoMotivo == 'Cajeros') {
                    retorno.put('preguntaCajeros', textosMap.get('Pregunta cajeros'));
                    retorno.put('preguntaCajerosExternos', textosMap.get('Pregunta cajero externalizado'));
                    retorno.put('toastCajerosExternos', textosMap.get('Toast cajero externalizado'));
                    retorno.put('urlCajeros', textosMap.get('Url cajeros'));
                } else if(ambitoMotivo == 'Cajeros Incidencias') {
                    if(caso.AssetId == null) {
                        retorno.put('toastCajerosIncidencias', textosMap.get('Error Incidencias Cajeros'));
                        retorno.put('tituloCajerosIncidencias', textosMap.get('Titulo Error Incidencias Cajeros'));
                    } else {
                        retorno.put('flowDerivar', true);
                    }
                } else if(ambitoMotivo == 'Testamentaría') {
                    String preguntaRealizarRemitido = textosMap.get('Pregunta realizar remitido');
                    retorno.put('mostrarModalDNITestamentaria', true);
                } else if(ambitoMotivo == 'Vidacaixa' || ambitoMotivo == 'CaixaBank Talks') {
                    retorno.put('realizarRemitido', true);
                } else if(ambitoMotivo == 'No clientes') {
                    retorno.put('toastNoCliente', textosMap.get('Mensaje derivar no clientes'));
                    retorno.put('cambioOficina', true);
                    retorno.put('mostrarModalCreacionTarea', true);
                } else if(ambitoCSBD) {
                    if(caso.Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c) {
                        if(caso.CC_OTP_Nivel__c != null && caso.CC_Status_Autorizacion__c != 'APPROVED' && caso.CC_OTP_Valido__c == false) {
                            ambitoVentas = true;
                        } else {
                            if(ambitoMotivo == 'CSBD 3N') {
                                retorno.put('toastTrasladar3N', textosMap.get('Toast trasladar 3N'));
                            } else if(ambitoMotivo == 'CSBD No Contratar') {
                                retorno.put('toastCSBDNoContratar', textosMap.get('Toast CSBD No Contratar'));
                            } else if(ambitoMotivo == 'CSBD Contratar') {
                                ambitoVentas = true;
                                retorno.put('urlTF', textosMap.get('URL TF'));
                                retorno.put('preguntaCSBDContratar', textosMap.get('Pregunta CSBD Contratar'));
                                retorno.put('toastCrearOportunidad', textosMap.get('Toast crear oportunidad'));
                                retorno.put('preguntaCSBDContratar2', textosMap.get('Pregunta CSBD Contratar 2'));
                            }
                        }
                    } else {
                        ambitoVentas = true;
                    }
                }

                if(ambitoVentas) {                    
                    if(!imagin || ambitoCSBD || (ambitoMotivo == 'Oficina' && !imagin)) {
                        if(gestorGenericoName == caso.Account.AV_EAPGestor__r.Name || caso.Account.AV_EAPGestor__c == null) {
                            retorno.put('mostrarModalGestionGestorGenerico', true);
                        } else {
                            retorno.put('mostrarModalGestionGestorAsignado', true);
                        }
                    } else {
                        retorno.put('mostrarModalCreacionTarea', true);
                    }
                }                
            }

            retorno.put('gestorGenericoName' , gestorGenericoName);
            retorno.put('detallesConsulta', caso.CC_Detalles_Consulta__c);
            retorno.put('numperso' , caso.Account.AV_NumPerso__c);
            retorno.put('nif' , caso.Account.CC_Numero_Documento__c);
            retorno.put('derivar', caso.CC_Derivar__c);
            retorno.put('gestor', caso.Account.AV_EAPGestor__c);
            retorno.put('oficinaPrincipal', caso.Account.AV_OficinaPrincipal__c);            
            retorno.put('gestores', buscarGestores(caso.Account.AV_OficinaPrincipal__c));
            return retorno;
        }
    }
    
    @AuraEnabled
    public static void realizarTraslado3N(String recordId) {
        Id recordTypeIdGrupo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel');
        CC_MCC_Grupo_Colaborador__c grupoColaborador = [SELECT CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.RecordtypeId, 
        CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.CC_Queue_Traslado__c
        FROM CC_MCC_Grupo_Colaborador__c
        WHERE CC_Grupo_Colaborador__r.CC_Queue_Traslado__c = 'Cola_3N_CSBD'
        AND CC_Grupo_Colaborador__r.RecordtypeId = :recordTypeIdGrupo
        ORDER BY Name ASC LIMIT 1];
        CC_EmailSendController.cambiarPropietario(grupoColaborador.CC_Grupo_Colaborador__r.Name, grupoColaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c, recordId, '', grupoColaborador.CC_Grupo_Colaborador__r.Id);
    }
    
    @AuraEnabled
    public static Map<String, Object> crearOportunidad(String recordId) {
        Map<String, Object> retorno = new Map<String, Object>();
        if(!String.isEmpty(recordId)) {
            try {
                retorno = CSBD_WS_AltaOportunidad.altaOportunidadMac(recordId);
            } catch (Exception e) {
                throw new AuraHandledException('Error en el proceso de creacion de oportunidad ' + e.getMessage());
            }
            if(retorno.get('success') == true) {
                Id recordTypeTareaCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
                Case caso = [SELECT OwnerId, ContactId FROM CASE WHERE Id = :recordId LIMIT 1];
                Task tareaOportunidad = new Task();
                tareaOportunidad.recordTypeId = recordTypeTareaCC;
                tareaOportunidad.Subject = 'Creación oportunidad';
                tareaOportunidad.Status = 'Completed';
                tareaOportunidad.Priority = 'Normal';
                tareaOportunidad.Description = '';
                tareaOportunidad.WhatId = recordId;
                tareaOportunidad.AV_OrigenAct__c = 'Contact Center';
                tareaOportunidad.OwnerId = caso.OwnerId;
                tareaOportunidad.Type = 'Oportunidad CSBD';
                tareaOportunidad.WhoId = caso.ContactId;
                insert tareaOportunidad;
                
                caso.CC_CierreAutomaticoCSBD__c = true;
                caso.Status = 'Cerrado';
                update caso;
            }
        }
        return retorno;
    }
    
    @AuraEnabled
    public static Map<String, Object> crearTarea(String recordId, String asunto, String fechaActividad, String comentarios, List<String> archivos, Id oficinaDestino, Boolean enviarTareaOficinaCliente, Boolean crearTareaCitaGestor, Contact gestorSeleccionadoBuscador) {
        Map<String, Object> retorno = new Map<String, Object>();
        String mensaje;
        String numeroGestor;
        Boolean ambitoCSBD = false;
        Boolean imagin = false;
        User gestorCliente;
        Account resultado = new Account();
        List<Task> lstTask = new List<Task>();
        List<Task> lstTaskDirectores = new List<Task>();
        Date fechaActividadDate = Date.valueOf(fechaActividad);
        Id recordTypeTareaAV = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AV_AlertaComercial');
        Id recordTypeTareaCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        Case caso = [SELECT ContactId, Account.AV_OficinaPrincipal__c, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AccountId, OwnerId, CC_MCC_Motivo__r.CC_AmbitoTareas__c, Account.AV_EAPGestor__r.CC_Matricula__c, 
        Account.AV_EAPGestor__c, Account.AV_IndicadoresClientes__c, Account.AV_EAPGestor__r.AV_EmpleadoIntouch__c, Account.AV_EAPGestor__r.CC_Numero_Oficina__c, Account.AV_EAPGestor__r.Name, CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c,
        Account.AV_EAPGestor__r.AccountId, CC_Detalles_Consulta__c,Account.AV_Cliente__c, Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c
        FROM Case WHERE Id = :recordId LIMIT 1];
        List<CC_Lista_Valores__c> textos = [SELECT Name, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Textos operativa Derivar'];
        Map<String, String> textosMap = new Map<String, String>();
        for (CC_Lista_Valores__c texto : textos) {
            textosMap.put(texto.Name, texto.CC_Mensajes_Mostrar__c);
        }

        String ambitoMotivo;
        if(caso.Account.AV_IndicadoresClientes__c != null && caso.Account.AV_IndicadoresClientes__c.contains('28')) {
            imagin = true;
            ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c;
        } else {
            ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c;
        }
        
        if(ambitoMotivo == 'CSBD 3N' || ambitoMotivo == 'CSBD Contratar' || ambitoMotivo == 'CSBD No Contratar') {
            ambitoCSBD = true;
        }
        
        Task tareaGestorCaso = new Task();
        tareaGestorCaso.recordTypeId = recordTypeTareaCC;
        tareaGestorCaso.Subject = asunto;
        tareaGestorCaso.Status = 'Open';
        tareaGestorCaso.Priority = 'Normal';
        tareaGestorCaso.Description = comentarios;
        tareaGestorCaso.ActivityDate = fechaActividadDate;
        tareaGestorCaso.WhatId = recordId;
        tareaGestorCaso.AV_OrigenAct__c = 'Contact Center';
        tareaGestorCaso.OwnerId = caso.OwnerId;
        
        Task tareaGestorAccount = new Task();
        tareaGestorAccount.recordTypeId = recordTypeTareaAV;
        tareaGestorAccount.Subject = asunto;
        tareaGestorAccount.Status = 'Open';
        tareaGestorAccount.Priority = 'Normal';
        tareaGestorAccount.Description = comentarios;
        tareaGestorAccount.ActivityDate = Date.Today().addDays(7);
        tareaGestorAccount.AV_Case__c = recordId;
        if(ambitoMotivo == 'No clientes' || caso.AccountId == null) {
            String numpersoGenerico = textosMap.get('Cuenta generica');
            tareaGestorAccount.WhatId = [SELECT Id FROM Account WHERE AV_NumPerso__c = :numpersoGenerico AND CC_Inactivo__c = FALSE LIMIT 1]?.Id;
        } else {
            tareaGestorAccount.WhatId = caso.AccountId;
        }
        tareaGestorAccount.Type = 'Tarea gestor';
        tareaGestorAccount.AV_OrigenAct__c = 'Contact Center';
        
        if(!caso.Account.AV_Cliente__c) {
            tareaGestorAccount.AV_Center__c = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :oficinaDestino LIMIT 1].CC_Numero_Oficina__c;
            gestorCliente = buscarGestor('generico');
            mensaje = textosMap.get('Mensaje caixabank oficina cliente else');
            tareaGestorCaso.Type = 'Tarea Oficina';
        } else if(imagin && !ambitoCSBD) {
            if(ambitoMotivo == 'Oficina') {
                resultado = [SELECT Id, Name, RecordType.DeveloperName, CC_Numero_Oficina__c  FROM Account WHERE Id = :caso.Account.AV_OficinaPrincipal__c AND RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];
                mensaje = textosMap.get('Mensaje imagin oficina');
                tareaGestorAccount.AV_Center__c = caso.Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
                tareaGestorCaso.Type = 'Tarea Oficina';
                gestorCliente = buscarGestor('generico');
                //tareaGestorAccount.Description += ' ' + caso.CC_Detalles_Consulta__c;
            } else if (ambitoMotivo == 'Ventas') {
                if (caso.Account.AV_EAPGestor__r.AV_EmpleadoIntouch__c) {
                    numeroGestor = caso.Account.AV_EAPGestor__r.CC_Matricula__c;
                    tareaGestorAccount.AV_Center__c = caso.Account.AV_EAPGestor__r.CC_Numero_Oficina__c;
                    tareaGestorCaso.Type = 'Tarea gestor';
                    gestorCliente = buscarGestor(numeroGestor);
                } else {
                    tareaGestorAccount.AV_Center__c = textosMap.get('Hub sales');
                    tareaGestorCaso.Type = 'Tarea Hub Sales';
                    gestorCliente = buscarGestor('generico');
                }
                //tareaGestorAccount.Description += ' ' + caso.CC_Detalles_Consulta__c;
                mensaje = textosMap.get('Mensaje imagin ventas');
            } else if(ambitoMotivo == 'Cambio de Oficina') {
                Id oficinaOrigen = caso.Account.AV_OficinaPrincipal__c;
                List<Contact> directoresOficina = [SELECT Id, AccountId, Account.CC_Numero_Oficina__c, CC_Matricula__c FROM Contact WHERE AV_DescFuncion__c = 'DIRECCION' AND CC_Inactivo__c = false AND AccountId IN (:oficinaDestino)];
                for(Contact director : directoresOficina) {
                    Task tareaDirector = new Task();
                    tareaDirector.recordTypeId = recordTypeTareaAV;
                    tareaDirector.Subject = asunto;
                    tareaDirector.Status = 'Open';
                    tareaDirector.Priority = 'Normal';
                    tareaDirector.Description = comentarios;
                    tareaDirector.ActivityDate = Date.Today().addDays(7);
                    tareaDirector.AV_Case__c = recordId;
                    tareaDirector.WhatId = caso.AccountId;
                    tareaDirector.AV_OrigenAct__c = 'Contact Center';
                    tareaDirector.AV_Center__c = director.Account.CC_Numero_Oficina__c;
                    tareaDirector.Type = 'Tarea gestor';
                    numeroGestor = director.CC_Matricula__c;
                    gestorCliente = buscarGestor(numeroGestor);
                    tareaDirector.OwnerId = gestorCliente.Id;
                    lstTaskDirectores.add(tareaDirector);
                }
                tareaGestorCaso.Type = 'Tarea Cambio Oficina';
                mensaje = textosMap.get('Mensaje imagin cambio de oficina');
            } else if(ambitoMotivo == 'Cambio de Gestor') {
                mensaje = textosMap.get('Mensaje imagin cambio de gestor');
                tareaGestorAccount.AV_Center__c = textosMap.get('Hub gestion');
                tareaGestorCaso.Type = 'Tarea Cambio Gestor';
                gestorCliente = buscarGestor('generico');
            } else if(ambitoMotivo == null || ambitoMotivo == '') {
                if (caso.Account.AV_EAPGestor__r.AV_EmpleadoIntouch__c) {
                    numeroGestor = caso.Account.AV_EAPGestor__r.CC_Matricula__c;
                    tareaGestorAccount.AV_Center__c = caso.Account.AV_EAPGestor__r.CC_Numero_Oficina__c;
                    tareaGestorCaso.Type = 'Tarea gestor';
                    gestorCliente = buscarGestor(numeroGestor);
                } else {
                    tareaGestorAccount.AV_Center__c = textosMap.get('Hub gestion');
                    tareaGestorCaso.Type = 'Tarea Hub Gestión';
                    gestorCliente = buscarGestor('generico');
                }
                //tareaGestorAccount.Description += ' ' + caso.CC_Detalles_Consulta__c;
                mensaje = textosMap.get('Mensaje imagin else');
            }
        } else if(!imagin || (ambitoCSBD && !caso.Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c) || (ambitoCSBD && imagin)) {
            if(ambitoMotivo == 'Ventas' || ambitoCSBD || ambitoMotivo == null || ambitoMotivo == '' || ambitoMotivo == 'Oficina') {
                Map<String, String> gestorGenerico = buscarGestorGenerico();
                String nombreGestorGenerico = gestorGenerico.get('nombre').toString();
                if(caso.Account.AV_EAPGestor__c != null && caso.Account.AV_EAPGestor__r.Name != nombreGestorGenerico) {
                    if(crearTareaCitaGestor) {
                        tareaGestorAccount.AV_Center__c = caso.Account.AV_EAPGestor__r.CC_Numero_Oficina__c;
                        numeroGestor = caso.Account.AV_EAPGestor__r.CC_Matricula__c;
                        gestorCliente = buscarGestor(numeroGestor);
                        mensaje = textosMap.get('Mensaje caixabank cita tarea gestor');
                    } else {
                        tareaGestorAccount.AV_Center__c = gestorSeleccionadoBuscador.CC_Numero_Oficina__c;
                        numeroGestor = gestorSeleccionadoBuscador.CC_Matricula__c;
                        gestorCliente = buscarGestor(gestorSeleccionadoBuscador.CC_Matricula__c);
                        mensaje = textosMap.get('Mensaje caixabank cita tarea gestor else');
                    }
                    tareaGestorCaso.Type = 'Tarea gestor';
                } else {
                    if(enviarTareaOficinaCliente) {
                        tareaGestorAccount.AV_Center__c = caso.Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
                        gestorCliente = buscarGestor('generico');
                        mensaje = textosMap.get('Mensaje caixabank oficina cliente');
                    } else {
                        tareaGestorAccount.AV_Center__c = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :oficinaDestino LIMIT 1].CC_Numero_Oficina__c;
                        gestorCliente = buscarGestor('generico');
                        mensaje = textosMap.get('Mensaje caixabank oficina cliente else');
                    }
                    tareaGestorCaso.Type = 'Tarea Oficina';
                }
            } else if (ambitoMotivo == 'Cambio de Oficina' || ambitoMotivo == 'Cambio de Gestor') {
                Id oficinaOrigen;
                String taskType;
                oficinaOrigen = caso.Account.AV_OficinaPrincipal__c;
                List<Contact> directoresOficina; 
                
                if(ambitoMotivo == 'Cambio de Gestor') {
                    directoresOficina = [SELECT Id, AccountId, Account.CC_Numero_Oficina__c, CC_Matricula__c FROM Contact WHERE AV_DescFuncion__c = 'DIRECCION' AND CC_Inactivo__c = false AND AccountId IN (:oficinaOrigen, :oficinaDestino)];
                    mensaje = textosMap.get('Mensaje caixabank cambio de gestor');
                    tareaGestorCaso.Type = 'Tarea Cambio Gestor';
                } else {
                    directoresOficina = [SELECT Id, AccountId, Account.CC_Numero_Oficina__c, CC_Matricula__c FROM Contact WHERE AV_DescFuncion__c = 'DIRECCION' AND CC_Inactivo__c = false AND AccountId IN (:oficinaDestino)];
                    mensaje = textosMap.get('Mensaje caixabank cambio de oficina');
                    tareaGestorCaso.Type = 'Tarea Oficina';
                }
                
                for(Contact director : directoresOficina) {
                    Task tareaDirector = new Task();
                    tareaDirector.recordTypeId = recordTypeTareaAV;
                    tareaDirector.Subject = asunto;
                    tareaDirector.Status = 'Open';
                    tareaDirector.Priority = 'Normal';
                    tareaDirector.Description = comentarios;
                    tareaDirector.ActivityDate = Date.Today().addDays(7);
                    tareaDirector.AV_Case__c = recordId;
                    tareaDirector.WhatId = caso.AccountId;
                    tareaDirector.AV_OrigenAct__c = 'Contact Center';
                    tareaDirector.AV_Center__c = director.Account.CC_Numero_Oficina__c;
                    tareaDirector.Type = 'Tarea gestor';
                    numeroGestor = director.CC_Matricula__c;
                    gestorCliente = buscarGestor(numeroGestor);
                    tareaDirector.OwnerId = gestorCliente.Id;
                    lstTaskDirectores.add(tareaDirector);
                }
            }
        }
        if (ambitoMotivo == 'No clientes') {
            tareaGestorAccount.AV_Center__c = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :oficinaDestino LIMIT 1].CC_Numero_Oficina__c;
            mensaje = textosMap.get('Mensaje derivar no clientes');
            tareaGestorCaso.Type = 'Tarea Oficina';
            //tareaGestorAccount.Description += '' + caso.CC_Detalles_Consulta__c;
            gestorCliente = buscarGestor('generico');
        } /*else if(ambitoMotivo == 'Enrollment Sign') {
        gestorCliente = buscarGestor('generico');
        tareaGestorAccount.AV_Center__c = caso.Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
        tareaGestorCaso.Type = 'Tarea Oficina';
        mensaje = textosMap.get('Toast enrollment no');
        }*/

        Set<Id> taskDirectoresId = new Set<Id>();

        retorno.put('mensaje', mensaje);
        retorno.put('cuenta', resultado);
        if(gestorCliente != null) {
            tareaGestorAccount.OwnerId = gestorCliente.Id;
        } /*else {
            gestorCliente = buscarGestor('generico');
            tareaGestorAccount.AV_Center__c = caso.Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
            mensaje = textosMap.get('Mensaje cliente no encontrado');
            tareaGestorCaso.Type = 'Tarea Oficina';
            CBK_Activity_Extension__c tareaGestorCasoExtension = new CBK_Activity_Extension__c();
            tareaGestorCasoExtension.AV_ActivityId__c = tareaGestorCaso.Id;
            tareaGestorCasoExtension.CC_Matricula_No_Encontrada__c = caso.Account.AV_EAPGestor__r.CC_Matricula__c;
        }*/
        if(caso != null && ambitoMotivo != 'No clientes') {
            tareaGestorAccount.WhoId = caso.ContactId;
            tareaGestorCaso.WhoId = caso.ContactId;
        }
        if(!lstTaskDirectores.isEmpty()) {
            insert lstTaskDirectores;
            for(Task tarea : lstTaskDirectores){
                taskDirectoresId.add(tarea.Id);
            }
        } else {
            lstTask.add(tareaGestorAccount);
        }

        lstTask.add(tareaGestorCaso);
        insert lstTask;

        if(tareaGestorAccount != null && lstTaskDirectores.isEmpty()) {
            taskDirectoresId.add(tareaGestorAccount.Id);
        }

        List<Task> taskAfter = [SELECT Id, OwnerId FROM Task WHERE Id IN :taskDirectoresId];
        if(archivos != null && !taskAfter.isEmpty()) {
            List<ContentVersion> files = [SELECT Title, VersionData, FileExtension, OwnerId FROM ContentVersion WHERE IsLatest = TRUE and Id IN :archivos];
            List <Attachment> at = new List <Attachment>();
            for(ContentVersion file : files) {
                for(Task tarea : taskAfter) {
                    Attachment attachment = new Attachment(
                        OwnerId = tarea.OwnerId,
                        ParentId = tarea.Id,
                        Name = file.Title + '.' + file.FileExtension,
                        Body = file.VersionData
                        );
                        at.add(attachment);
                }
            }
            insert at;
        }
        return retorno;
    }
    
    public static User buscarGestor(String numeroGestor) {
        List <User> gestorCliente = new List <User>();
        String matriculaGestor;
        String nameGestor;
        String externalID;
        if(numeroGestor != null && numeroGestor != 'generico') {
            if(numeroGestor.startsWith('U01')) {
                matriculaGestor = numeroGestor;
            } else if (numeroGestor != '000000') {
                matriculaGestor = 'U01'+ numeroGestor;
            }            
            gestorCliente = [SELECT Id FROM User WHERE AV_ExternalID__c = :matriculaGestor LIMIT 1];
        }
        if(gestorCliente.isEmpty() || numeroGestor == 'generico') {
            Map<String, String> retorno = buscarGestorGenerico();
            String matricula = retorno.get('matricula');
            String nombre = retorno.get('nombre');
            gestorCliente = [SELECT Id FROM User WHERE AV_ExternalID__c = :matricula LIMIT 1];
        }
        return gestorCliente[0];
    }
    
    public static Map<String, String> buscarGestorGenerico() {
        String nameGestor;
        String externalID;
        Map<String, String> retorno = new Map<String, String>();
        List<CC_Lista_Valores__c> listaLOV = [SELECT CC_Valor__c, Name FROM CC_Lista_Valores__c  WHERE CC_Lista__r.name = 'Gestor por defecto CC'];
        for(CC_Lista_Valores__c valor: listaLOV) {
            if(valor.Name == 'ExternalID') {
                externalID = valor.CC_Valor__c;
            }
            else if (valor.Name == 'Nombre') {
                nameGestor = valor.CC_Valor__c;
            }
        }
        retorno.put('nombre', nameGestor);
        retorno.put('matricula', externalID);
        return retorno;
    }
    
    @AuraEnabled
    public static Map<Object, Object> esClienteDigital(String recordId, String tipoActividad) {
        try {
            return CC_Int_ObtInfCarterizaCliente.esClienteDigital(recordId, tipoActividad);
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getUrlNumeroOficina(Id recordId) {
        String hostnameEntero = String.valueOf(System.Url.getOrgDomainUrl());
        String hostnameSubstring1 = hostnameEntero.remove('Url:[delegate=');
        String hostnameLimpio = hostnameSubstring1.remove(']');
        Account cuenta = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :recordId LIMIT 1];
        String url = hostnameLimpio + '/lightning/r/Account/' + cuenta.Id + '/view';
        return new Map<String, String>{'numeroOficina' => cuenta.CC_Numero_Oficina__c, 'url' => url};
    }
    
    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerGestoresBackup(String recordId, String employeeId, String gestorElegidoId, String eventType) {
        try {
            return CC_Int_AvailabilitiesGestor.obtenerGestoresBackup(recordId, employeeId, gestorElegidoId, eventType);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerFechasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType) {
        try {
            return CC_Int_AvailabilitiesGestor.obtenerFechasDisponiblidadGestor(recordId, employeeId, gestorElegidoId, eventType);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerHorasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType, String fechaElegida) {
        try {
            return CC_Int_AvailabilitiesGestor.obtenerHorasDisponiblidadGestor(recordId, employeeId, gestorElegidoId, eventType, fechaElegida);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> altaCitaGestor(String recordId, String empleadoEx, String nombreGestor, String centroEx, String asunto, String fecContacto, String horaIni, String medio) {
        try {
            return CC_Int_AltaCitaGestor.altaCitaGestor(recordId, empleadoEx, nombreGestor, centroEx, asunto, fecContacto, horaIni, medio);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> buscarOficinas(String cadenaBusqueda) {
        if (Schema.SObjectType.Account.isAccessible()) {
            return [FIND :cadenaBusqueda + '*' IN ALL FIELDS RETURNING Account(Name, BillingStreet, BillingCity WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 7)][0];
        } else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> buscarGestoresGlobal(String cadenaBusqueda) {
        if (Schema.SObjectType.Contact.isAccessible()) {
            return [FIND :cadenaBusqueda + '*' IN ALL FIELDS RETURNING Contact(Name, Account.BillingStreet, Account.BillingCity, CC_Nombre_Oficina__c, CC_Matricula__c, CC_Numero_Oficina__c WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Num_Empleado_Generico__c NOT IN('99999', '98999') /*AND CC_Inactivo__c = false*/ LIMIT 7)][0];
        } else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }
    
    //@AuraEnabled(cacheable=true)
    public static List<Contact> buscarGestores(String oficina) {
        if(!String.isEmpty(oficina)) {
            List<Contact> gestores = [SELECT Id, Name FROM Contact WHERE AccountId = :oficina AND CC_Inactivo__c = false AND CC_Num_Empleado_Generico__c NOT IN('99999', '98999')];
            return gestores;
        } else {
            return null;
        }        
    }
    
    @AuraEnabled
    public static Boolean recuperarCampoDerivar(Id recordId) {
        Boolean campoDerivar = [SELECT CC_Derivar__c FROM Case WHERE Id = :recordId LIMIT 1].CC_Derivar__c;
        return campoDerivar;
    }
    
    @AuraEnabled
    public static void dniTestamentaria(String dni, String recordId){
        Case caso = [SELECT Id, CC_DNI_Difunto__c FROM Case WHERE Id = :recordId LIMIT 1];
        caso.CC_DNI_Difunto__c = dni;
        update caso;
    }
    
    @AuraEnabled
    public static Map<String, Object> recuperarDatosEntradaFlow(String recordId){
        try {   
            Case caso = [SELECT Id, accountId, contactId, CC_Oficina__c,CC_Oficina_afectada__c, AssetId FROM Case WHERE Id = :recordId LIMIT 1];
            Map<String, Object> datos = new Map<String, Object>();
            if(caso != null){
                datos.put('recordId', caso.Id);
                datos.put('currentCase', caso);
            }
            return datos;          
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /*@AuraEnabled
    public static void preguntaEnrollmentDatosSi(String recordId){
    Case casoOrigen = [SELECT CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :recordId LIMIT 1];
    casoOrigen.Status = 'Cerrado';
    casoOrigen.CC_CierreAutomaticoCSBD__c = true;
    
    update casoOrigen;
    
    List<Group> cola =[SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Videollamada_Enrollment_Caixabank_Sign' LIMIT 1];
    Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
    CC_MCC__c tematica = [SELECT Id FROM CC_MCC__c WHERE Name= 'CaixaBankNow'LIMIT 1];
    CC_MCC__c producto = [SELECT Id FROM CC_MCC__c WHERE Name= 'Mecanismo de firma' LIMIT 1];
    CC_MCC__c motivo = [SELECT Id FROM CC_MCC__c WHERE Name= 'Activación CaixaBankSign' LIMIT 1];
    CC_MCC__c causa = [SELECT Id FROM CC_MCC__c WHERE Name= 'Cliente en el extranjero' LIMIT 1];
    
    
    Case casoNuevo= new Case();
    casoNuevo.RecordTypeId = recordTypeCaso;
    casoNuevo.Subject = 'Videollamada';
    casoNuevo.CC_MCC_Tematica__c = tematica.Id;
    casoNuevo.CC_MCC_ProdServ__c = producto.Id;
    casoNuevo.CC_MCC_Motivo__c =motivo.Id;
    casoNuevo.CC_MCC_Causa__c = causa.Id;
    casoNuevo.Origin = 'Teléfono';
    casoNuevo.CC_Idioma__c= casoOrigen.CC_Idioma__c;
    casoNuevo.AccountId = casoOrigen.AccountId;
    casoNuevo.ContactId = casoOrigen.ContactId;
    casoNuevo.OwnerId =cola[0].Id;
    
    insert casoNuevo;
    
    CC_Revincular_Caso_Controller.mergeCase(casoNuevo.Id, casoOrigen.Id);
    }*/
    
    public static void devolverCasoCSBD(Map<String, Object> respuesta) {
        String casoIdString = (String)respuesta.get('casoId');
        if(!String.isEmpty(casoIdString)){          
            //Publicar el platform event para que la transacción salga por el usuario integración
            CC_DevolverCaso__e devolverCasoEvent = new CC_DevolverCaso__e();
            devolverCasoEvent.CC_CasoId__c = casoIdString; 
            Database.SaveResult sr = EventBus.publish(devolverCasoEvent);            
        } else {
            throw new DefaultException('Error en el proceso de devolución, no se recibió ningún id de caso');
        }
    }
    
    public static void reabrirCasoCSBD(List<String> casosIds) {
        List<Case> casosAbrir =  new List<Case>();
        for(Case casoTarea : [
            SELECT Id, 
                (
                    SELECT OwnerId
                    FROM Tasks
                    WHERE Type = 'Cerrado' 
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                )
            FROM Case 
            WHERE Id IN :casosIds 
        ]){
            if(casoTarea.Tasks.size()> 0){               
                casoTarea.CC_DevolucionCSBD__c = true;
                casoTarea.OwnerId = casoTarea.Tasks[0].OwnerId;
                casoTarea.Status = 'Activo';
                casosAbrir.add(casoTarea);
            }     
        }     
      
        if(casosAbrir.size() > 0 ) {
            update casosAbrir;
        }   
    }

    //llamado desde el trigger de Platform Event
    public static void reabrirCasoCSBD(List<CC_DevolverCaso__e> reabrirEvents) {
        List<String> casesIds = new List<String>();
        for(CC_DevolverCaso__e reabrirEvent : reabrirEvents){
            if(String.isNotBlank(reabrirEvent.CC_CasoId__c)){
                casesIds.add(reabrirEvent.CC_CasoId__c);
            }
        }       
        if(casesIds.size() > 0){
            reabrirCasoCSBD(casesIds);
        }
    }
    
    // usar esta excepcion internamente
    private class DefaultException extends Exception {}
}