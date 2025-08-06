public with sharing class CC_Clasificacion_Casos_Controller {
    
    @AuraEnabled
    public static Boolean actividadesTrasladoColaborador(Id recordId) {
        return ![SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Traslado Colaborador'].isEmpty();
    }
    
    private static String recuperarOrderBy() {
        if ([SELECT Count() FROM GroupMember
        WHERE Group.DeveloperName = 'Cola_3N_CSBD' AND UserOrGroupId = :UserInfo.getUserId()] == 0) {
            return 'ORDER BY Name ASC';
        } else {
            return 'ORDER BY CC_3N_CSBD__c DESC, Name ASC';
        }
    }
    
    @AuraEnabled
    public static Boolean operativaActiva(String operativa) {
        Boolean operativaAbierta = false;
        CC_Settings__c configuracion = CC_Settings__c.getValues(operativa);
        if (configuracion.CC_Activa__c == true) {
            operativaAbierta = true;
        }
        return operativaAbierta;
    }
    
    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        
        public PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;

        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getCanalesOperativos() {
        return OT_Picklist.picklistCampo('Case', 'CC_Canal_Operativo__c');
    }

    @AuraEnabled
    public static Boolean validarActividadesFraude(Id recordId) {
        List<String> tiposCita = new List<String>{'Fraude', 'Cita gestor', 'Cita rápida gestor', 'Tarea Oficina', 'Tarea gestor'};
        List<Task> actividades = [SELECT Id FROM Task WHERE WhatId = :recordId AND Type IN :tiposCita];
        return actividades.isEmpty();
    }

    @AuraEnabled
    public static void crearCasoFraude(Id recordId) {
        CC_Operativa_Oficina_Controller.crearNuevoCasoFraude(recordId);
    }
    
    // @AuraEnabled
    // public static Map<String, Object> getObjetosRelacionados(Id recordId) {
    //     Map<String, Object> mapRelacionados = new Map<String, Id>();
    //     List<Case> caso = [SELECT Id FROM Case WHERE CC_CasoRelacionado__c = :recordId ORDER BY CreatedDate DESC LIMIT 1 ];
    //     mapRelacionados.put('caso', caso[0]);
    //     //mapRelacionados.put('oportunidad', [SELECT Id FROM Opportunity WHERE CSBD_CasoOrigen__c = :recordId ORDER BY CreatedDate DESC LIMIT 1 ]);
    //     return mapRelacionados;
    // }
    
    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getTematicas(String tipoCliente, String canalProcedencia, String canalOperativo) {
        Id idRecordTypeTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        if (tipoCliente == 'Empleado') {
            return OT_Picklist.picklistSoql([SELECT Name FROM CC_MCC__c WHERE RecordType.Id = :idRecordTypeTematica
            AND CC_Tipo_Cliente__c = :tipoCliente AND CC_Activo__c = true ORDER BY Name ASC], 'Id', 'Name');
        } else if (tipoCliente == 'Empleado Bankia') {
            return OT_Picklist.picklistSoql([SELECT Name FROM CC_MCC__c WHERE RecordType.Id = :idRecordTypeTematica
            AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC], 'Id', 'Name');
        } else {
            String stringQuery;
            if (canalOperativo != null && canalOperativo != '') {
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE RecordType.Id = \'' + idRecordTypeTematica + '\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true AND CC_Canal_Operativo__c INCLUDES (\''+ canalOperativo+'\') '+ recuperarOrderBy();
            } else {
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE RecordType.Id = \'' + idRecordTypeTematica + '\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true '+ recuperarOrderBy();
            }
            return OT_Picklist.picklistSoql(Database.query(stringQuery), 'Id', 'Name');
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getProductos(String tipoCliente, String tematica, String canalProcedencia) {
        if (String.isBlank(tematica)) {
            return new List<OT_Picklist.Item>{new OT_Picklist.Item('', '')};
        } else {
            if (tipoCliente == 'Empleado') {
                return OT_Picklist.picklistSoql([SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = :tematica
                AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio')
                AND CC_Tipo_Cliente__c = :tipoCliente AND CC_Activo__c = true ORDER BY Name ASC], 'Id', 'Name');
            } else if (tipoCliente == 'Empleado Bankia') {
                return OT_Picklist.picklistSoql([SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = :tematica
                AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio')
                AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC], 'Id', 'Name');
            } else {
                String stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = \'' + tematica + '\' AND RecordType.Id = \'' + CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio') + '\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                return OT_Picklist.picklistSoql(Database.query(stringQuery), 'Id', 'Name');
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getMotivos(String tipoCliente, String producto, String canalProcedencia) {
        if (String.isBlank(producto)) {
            return new List<PickListWrapper>();
        } else {
            List<PickListWrapper> motivos = new List<PickListWrapper>();
            if (tipoCliente == 'Empleado') {
                for (CC_MCC__c motivo : [SELECT Name FROM CC_MCC__c  WHERE CC_Producto_Servicio__c = :producto
                AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo')
                AND CC_Tipo_Cliente__c = :tipoCliente AND CC_Activo__c = true ORDER BY Name ASC]) {
                    PickListWrapper wrap = new PickListWrapper(motivo.Name, motivo.Id);
                    motivos.add(new PickListWrapper(motivo.Name, motivo.Id));
                }
            } else if (tipoCliente == 'Empleado Bankia') {
                for (CC_MCC__c motivo : [SELECT Name FROM CC_MCC__c  WHERE CC_Producto_Servicio__c = :producto
                AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo')
                AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC]) {
                    motivos.add(new PickListWrapper(motivo.Name, motivo.Id));
                }
            } else {
                Id idMCCyMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                String stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Producto_Servicio__c = \'' + producto + '\' AND RecordType.Id = \'' + idMCCyMotivo + '\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                for (CC_MCC__c motivo : Database.query(stringQuery)) {
                    motivos.add(new PickListWrapper(motivo.Name, motivo.Id));
                }
            }
            return motivos;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getCausas(String tipoCliente, String motivo, String canalProcedencia) {
        if (String.isBlank(motivo)) {
            return new List<PickListWrapper>();
        } else {
            List<PickListWrapper> causas = new List<PickListWrapper>();
            if (tipoCliente == 'Empleado') {
                for (CC_MCC__c causa : [SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = :motivo
                AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa')
                AND CC_Tipo_Cliente__c = :tipoCliente AND CC_Activo__c = true ORDER BY Name ASC]) {
                    causas.add(new PickListWrapper(causa.Name, causa.Id));
                }
            } else if (tipoCliente == 'Empleado Bankia') {
                for (CC_MCC__c causa : [SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = :motivo
                AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa')
                AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC]) {
                    causas.add(new PickListWrapper(causa.Name, causa.Id));
                }
            } else {
                Id idMCCyCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
                String stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = \'' + motivo + '\' AND RecordType.Id = \'' + idMCCyCausa + '\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                for (CC_MCC__c causa : Database.query(stringQuery)) {
                    causas.add(new PickListWrapper(causa.Name, causa.Id));
                }
            }
            return causas;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSoluciones(String tipoCliente, String causa, String canalProcedencia) {
        if (String.isBlank(causa)) {
            return new List<Map<String, String>>();
        } else {
            List<Map<String, String>> soluciones = new List<Map<String, String>>();
            if (tipoCliente == 'Empleado') {
                for (CC_MCC__c solucion : [SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = :causa AND RecordType.DeveloperName = 'CC_Solucion'
                AND CC_Tipo_Cliente__c = :tipoCliente AND CC_Activo__c = true ORDER BY Name ASC]) {
                    soluciones.add(new Map<String, String>{'label' => solucion.Name, 'value' => solucion.Id});
                }
            } else if (tipoCliente == 'Empleado Bankia') {
                for (CC_MCC__c solucion : [SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = :causa AND RecordType.DeveloperName = 'CC_Solucion'
                AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC]) {
                    soluciones.add(new Map<String, String>{'label' => solucion.Name, 'value' => solucion.Id});
                }
            } else {
                String stringQuery = 'SELECT Name, CC_Agrupacion_Solucion__c FROM CC_MCC__c WHERE CC_Causa__c = \'' + causa + '\' AND RecordType.DeveloperName = \'CC_Solucion\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                for (CC_MCC__c solucion : Database.query(stringQuery)) {
                    soluciones.add(new Map<String, String>{'label' => solucion.Name, 'value' => solucion.Id, 'agrupacion' => solucion.CC_Agrupacion_Solucion__c});
                }
            }
            return soluciones;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getCampanas() {
        return OT_Picklist.picklistSoql([SELECT Name FROM CC_Caracteristica__c WHERE recordtypeId = :Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId()], 'Id', 'Name');
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getErroresTf7() {
        return OT_Picklist.picklistSoql([SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Errores Terminal Financiero'], 'CC_Valor__c', 'CC_Valor__c');
    }
    
    @AuraEnabled
    public static Map<String, Object> validarGuardar(Id recordId, String nuevoCanalRespuesta, Id nuevaTematica, Id nuevoProducto, Id nuevoMotivo, Boolean tieneActividad) {
        Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c,
        CC_MCC_ProdServ__r.Name, recordTypeId, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name, Account.AV_IndicadoresClientes__c, 
        CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, recordType.DeveloperName FROM Case WHERE Id = :recordId]; 
        return validarGuardar(caso, nuevoCanalRespuesta, nuevaTematica, nuevoProducto, nuevoMotivo, tieneActividad, false);
    }

    
    public static Map<String, Object> validarGuardar(Case caso, String nuevoCanalRespuesta, Id nuevaTematica, Id nuevoProducto, Id nuevoMotivo, Boolean tieneActividad, Boolean cambiarStatusAuto) {
        
        Id profileId = UserInfo.getProfileId();
        String profileName;
        if(profileId != null){
            profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        }
        
        if (caso.OwnerId != UserInfo.getUserId() && profileName != 'CC_Supervisor') { 
            throw new AuraHandledException('Solo el propietario del caso puede modificarlo.');
        } else if (nuevoCanalRespuesta == 'Twitter' && caso.Origin != 'Twitter' || nuevoCanalRespuesta == 'Comentarios APPs' && caso.Origin != 'Comentarios Stores') {
            throw new AuraHandledException('No se puede indicar el canal de respuesta "' + nuevoCanalRespuesta + '" si el canal de entrada no es "' + nuevoCanalRespuesta + '".');
        } else if (caso.Origin == 'Comentarios Stores' && String.isNotBlank(nuevoCanalRespuesta)) {
            throw new AuraHandledException('No es posible cambiar el canal de respuesta de un caso procedente de Comentarios Apps.');
        }
        
        Map<String, Object> resultado = new Map<String, Object>();
        if (caso.CC_MCC_Tematica__c == nuevaTematica && caso.CC_MCC_ProdServ__c == nuevoProducto && caso.CC_MCC_Motivo__c == nuevoMotivo) {
            resultado.put('retipificar', false);
        } else {
            //Validación de los permisos de reclasificación
            if (CC_Permisos_Tercer_Nivel__c.getInstance().CC_Bloquear__c) {
                throw new AuraHandledException('Los usuarios con perfil de tercer nivel no pueden clasificar casos.');
            }
            resultado.put('retipificar', true);
            resultado.put('tematicaAnteriorName', caso.CC_MCC_Tematica__r.Name);
            resultado.put('productoAnteriorName', caso.CC_MCC_ProdServ__r.Name);
            resultado.put('motivoAnteriorName', caso.CC_MCC_Motivo__r.Name);
        }
        //verificar si es ambito CSBD
        String ambitoMotivo = '';
        if (caso.RecordType.DeveloperName == 'CC_Cliente') {
        if(caso?.Account?.AV_IndicadoresClientes__c != null && caso?.Account?.AV_IndicadoresClientes__c?.contains('28')) {
            ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c;        
        } else {
            ambitoMotivo = caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c;        
        }
        List<String> motivosCSBD = new List<String>{'CSBD 3N', 'CSBD Contratar', 'CSBD No Contratar'}; 
        //para identificar si el ambito es CSBD y no hacer la pregunta de derivarción. 
        if(motivosCSBD.contains(ambitoMotivo)) {
            resultado.put('ambitoCSBD', true);
        } else {
            resultado.put('ambitoCSBD', false);
        }

    }   

        resultado.put('tieneActividad',tieneActividad);
        resultado.put('cambiarStatusAuto', cambiarStatusAuto);
        return resultado;
    }
    
    @AuraEnabled
    public static Map<String, Object> validarGuardarCerrar(Id recordId,Boolean cerrar, String nuevoCanalRespuesta, Id nuevaTematica, Id nuevoProducto, Id nuevoMotivo, String agrupacionComprobacion) {
        Boolean tieneActividad = false;
        Boolean cambiarStatusAuto = false;

        Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c, 
                    CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
                    CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
                    Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
                    CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
                    CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, 
                    CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, 
                    CC_OTP_Nivel__c, CC_Status_Autorizacion__c, CC_Id_Cognitivo__c, ContactEmail
                    FROM Case WHERE Id = :recordId];

  
        if(cerrar) {
               String errores = '';            
            if (caso.RecordType.DeveloperName.startsWith('CC')){
                List<CC_MCC__c> tematica = [SELECT Id FROM CC_MCC__c WHERE Id = :nuevaTematica AND CC_Activo__c = true];
                if(tematica.isEmpty()){
                    errores += ' Temática';
                    List<CC_MCC__c> producto = [SELECT Id FROM CC_MCC__c WHERE Id = :nuevoProducto AND CC_Activo__c = true];
                    if(producto.isEmpty()){
                        errores += ', Producto';
                        List<CC_MCC__c> motivo = [SELECT Id FROM CC_MCC__c WHERE Id = :nuevoMotivo AND CC_Activo__c = true];
                        if(motivo.isEmpty()){
                            errores += ', Motivo';
                            List<CC_MCC__c> causa = [SELECT Id FROM CC_MCC__c WHERE Id = :caso.CC_MCC_Causa__c AND CC_Activo__c = true];
                            if(causa.isEmpty()){
                                errores += ', Causa';
                                if(caso.recordType.DeveloperName != 'CC_Cliente'){
                                    List<CC_MCC__c> solucion = [SELECT Id FROM CC_MCC__c WHERE Id = :caso.CC_MCC_Solucion__c AND CC_Activo__c = true];
                                    if(solucion.isEmpty()){
                                        errores += 'y Solución';
                                    }
                                }
                            }
                        }
                    }
                }
                if(errores != '') {
                    throw new AuraHandledException('No se puede cerrar un caso sí los campos ' + errores + ' no estan vigentes'); 
                }                
            }
            if (caso.RecordType.DeveloperName == 'CC_Cliente') {
                // MGT: Verificar si todas las tareas protocolarias están completadas
                CC_Gestion_Checklist_Case.chequearChecklistAlGuardar(caso);         
            }
        }
                    
        //NUEVO DPK ARGOS
        if(caso.AccountId != null && caso.ContactId != null && caso.RecordType.DeveloperName == 'CC_Cliente') {
            List<Task> tareas = [SELECT Id,CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, Status, Type FROM Task WHERE (AV_Case__c = :recordId OR WhatId = :recordId) AND Type IN ('Tarea gestor', 'Oportunidad CSBD', 'Argos') ORDER BY CreatedDate DESC];
            Boolean tieneActividadAux = false;
            String keyAccCont,  keyTareaAccCont;
            Boolean tieneTareaArgos = false;
            Boolean retipificado = false;
            
            if(!tareas.isEmpty()) {
                for(Task tarea : tareas) {
                    if(tarea.Type == 'Oportunidad CSBD' && tarea.Status == 'Completed') {
                        tieneActividadAux = true;
                    }else if (tarea.Type == 'Argos'  && keyTareaAccCont == null) {
                        keyTareaAccCont = tarea.CC_Detalles_Solucion__c;
                        tieneTareaArgos = true;
                    }
                }
            }
                        
            CC_Settings__c configuracionFuncionalidad = CC_Settings__c.getValues('CC_OperativaOficinaGuardar');
            if (configuracionFuncionalidad.CC_Configuracion_1__c == 'true' && (agrupacionComprobacion == 'Derivar a oficina' || agrupacionComprobacion == 'Derivar a oficina: Limitación protocolo')) {
                if(tieneActividadAux  || caso.CC_Oportunidad_creada__c) {
                    tieneActividad = true;
                }                    
            } else {
                tieneActividad = true;
            }

            if(nuevaTematica != null && nuevoProducto != null && nuevoMotivo != null && CC_Settings__c.getValues('CC_Parametrizacion_WS_Argos')?.CC_Activa__c){
                retipificado = (caso.CC_MCC_Tematica__c != nuevaTematica || caso.CC_MCC_ProdServ__c != nuevoProducto || caso.CC_MCC_Motivo__c != nuevoMotivo) ? true : false;
                keyAccCont = (caso.AccountId + ' - ' + caso.ContactId).left(255);
                //valores para cuando se reclasifica el caso
                Map<String, String> nuevosValores = new Map<String, String>{
                'tematicaId' => String.valueOf(nuevaTematica),
                'prodServId' => String.valueOf(nuevoProducto),
                'motivoId' => String.valueOf(nuevoMotivo)
                };

                //invocar Argos start  
                if((!cerrar  && !tieneTareaArgos) ||  //llamamos a guardar por primera vez y no hay una tarea
                    (retipificado && !cerrar) ||                           //llamamos a guardar porque cambio el mcc   
                    (keyAccCont != keyTareaAccCont && !cerrar) ||                   //llamamos a guardar porque cambio la ceunta/contacto
                    ( !retipificado && keyAccCont == keyTareaAccCont && cerrar) //se le da al boton de guardar & cerrar y no cambio nada, solo se cierra
                ){                 
                    cambiarStatusAuto = CC_WS_Comunicaciones_Argos.process(caso, cerrar, false, nuevosValores);


                } else if((!tieneTareaArgos && cerrar ) || //se le da al boton de guardar & cerrar no hay tareas de la llamada previa
                ( retipificado && cerrar) ||                                    //se le da al boton de guardar & cerrar y cambio el mcc
                (keyAccCont != keyTareaAccCont && cerrar)                               //se le da al boton de guardar & cerrar y cambio la ceunta/contacto
                ){

                    cambiarStatusAuto = CC_WS_Comunicaciones_Argos.process(caso, cerrar, true, nuevosValores); //multicall 
                }                
                //invocar Argos end
            }
        } else {
            tieneActividad = true;
        }
        
        return validarGuardar(caso, nuevoCanalRespuesta, nuevaTematica, nuevoProducto, nuevoMotivo, tieneActividad, cambiarStatusAuto);
    }
    
    @AuraEnabled(cacheable=true)
    public static String clasificacionRapida(Id motivoId) {
        String respuesta = '';
        List<CC_MCC__c> mcc = [SELECT CC_Clasificacion_Rapida__c FROM CC_MCC__c WHERE Id = :motivoId AND CC_Clasificacion_Rapida__c != NULL];
        
        if (!mcc.isEmpty()) {
            String clasificacion = mcc[0].CC_Clasificacion_Rapida__c;
            Id recordTypeIdLOV = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            CC_Lista_Valores__c lovpadre = [SELECT Id FROM CC_Lista_Valores__c
            WHERE Name = 'MCC clasificación rápida' AND RecordTypeId = :recordTypeIdLOV LIMIT 1];
            if (lovpadre != null) {
                List<CC_Lista_Valores__c> valorClasificacion = [SELECT CC_Texto_Clasificacion_Rapida__c FROM CC_Lista_Valores__c
                WHERE Name = :clasificacion AND CC_Lista__c = :lovpadre.Id AND CC_Activa__c = true];
                if (!valorClasificacion.isEmpty()) {
                    respuesta = valorClasificacion[0].CC_Texto_Clasificacion_Rapida__c;
                }
            }
        }
        return respuesta;
    }
    
    @AuraEnabled
    public static void crearActividadRetipificacion(Id recordId, String tematicaAnterior, String productoAnterior, String motivoAnterior) {
        CC_Case.crearActividadRetipificacion(recordId, tematicaAnterior, productoAnterior, motivoAnterior);
    }
    
    @AuraEnabled
    public static void reabrirTareaTrasladoColaborador(Id recordId) {
        CC_Traslado_Colab.reabrirTareaTrasladoColab(new List<Id>{recordId});
    }
    
    @AuraEnabled
    public static void cerrarActividadSolicitudInformacion(Id recordId) {
        CC_Activity.finalizarActividadCaso(recordId, 'Solicitud Información', null, null);
        Case caso = [SELECT Status from Case where id = :recordId];
        if(caso.Status == 'Pendiente Cliente'){
            caso.Status = 'Activo';
            update caso;
        }
        
    }
    
    
    @AuraEnabled
    public static Map<String, Object> casoOrigenAbierto(Id idCaso) {
        Case caso = [SELECT CC_Caso_Origen__c, CC_Caso_Origen__r.CaseNumber, CC_Caso_Origen__r.Status,
        CC_Caso_Origen__r.CreatedDate, CC_Caso_Origen__r.CC_MCC_Tematica__r.Name, CC_Caso_Origen__r.Subject
        FROM Case WHERE Id = :idCaso AND CC_Caso_Origen__r.IsClosed = FALSE
        AND CC_Caso_Origen__r.Status NOT IN ('Pendiente Incidencia', 'Pendiente Colaborador	', 'Pendiente Interno')];
        if (String.isNotBlank(caso.CC_Caso_Origen__c)) {
            return new Map<String, Object>{
                'Id' => caso.CC_Caso_Origen__c,
                'CaseNumber' => caso.CC_Caso_Origen__r.CaseNumber,
                'Status' => caso.CC_Caso_Origen__r.Status,
                'CreatedDate' => caso.CC_Caso_Origen__r.CreatedDate,
                'tematicaName' => caso.CC_Caso_Origen__r.CC_MCC_Tematica__r.Name,
                'Subject' => caso.CC_Caso_Origen__r.Subject
            };
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Case cerrarCasoOrigen(Id idCasoOrigen, Id idCaso) {
        try {
            Case casoSeguimiento = [SELECT CC_Detalles_Solucion__c, CC_MCC_Motivo__c, CC_MCC_Causa__c, CC_MCC_Solucion__c
            FROM Case WHERE Id = :idCaso];
            
            Case casoOrigen = [SELECT CC_MCC_Motivo__c FROM Case WHERE Id = :idCasoOrigen];
            casoOrigen.CC_Detalles_Solucion__c = casoSeguimiento.CC_Detalles_Solucion__c;
            if (casoOrigen.CC_MCC_Motivo__c == casoSeguimiento.CC_MCC_Motivo__c) {
                casoOrigen.CC_MCC_Causa__c = casoSeguimiento.CC_MCC_Causa__c;
                casoOrigen.CC_MCC_Solucion__c = casoSeguimiento.CC_MCC_Solucion__c;
            }
            casoOrigen.Status = 'Cerrado';
            update casoOrigen;
            return casoOrigen;
        } catch (Exception e) {
            AuraHandledException auraExc = new AuraHandledException(e.getMessage());
            auraExc.setMessage(e.getMessage());
            throw auraExc;
        }
    }
    
    @AuraEnabled
    public static Boolean comprobarTareaOperativaOficina(Id recordId) {
        Boolean tieneActividad = false;
        List<Task> tareas = [SELECT Id FROM Task WHERE AV_Case__c = :recordId AND Type = 'Tarea gestor'];
        if(!tareas.isEmpty()) {
            tieneActividad = true;
        }
        return tieneActividad;
    }

    @AuraEnabled
    public static Boolean comprobarReaperturaValida(Id recordId) {
        Boolean tieneActividad = false;
        //Recuperamos la ultima tarea de Reapertura automatica
        List<Task> ultimaTareaRA = [SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Reapertura automatica' ORDER BY CreatedDate DESC LIMIT 1];
        if (!ultimaTareaRA.isEmpty()) {
            List<CBK_Activity_Extension__c> tareaExtension = [SELECT CC_Reapertura_Valida_Task__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :ultimaTareaRA[0].Id ORDER BY CreatedDate DESC LIMIT 1];
            if(!tareaExtension.isEmpty()) {
                if (tareaExtension[0].CC_Reapertura_Valida_Task__c == null) {
                    tieneActividad = true;
                }
            }
        }
        return tieneActividad;
    }

    @AuraEnabled
    public static void informarReaperturaValida(Id recordId, String valor) {
        List<Task> ultimaTareaRA = [SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Reapertura automatica' ORDER BY CreatedDate DESC LIMIT 1];
        if (!ultimaTareaRA.isEmpty()) {
            List<CBK_Activity_Extension__c> tareaExtension = [SELECT CC_Reapertura_Valida_Task__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :ultimaTareaRA[0].Id ORDER BY CreatedDate DESC LIMIT 1];
            if(!tareaExtension.isEmpty()) {
                tareaExtension[0].CC_Reapertura_Valida_Task__c = valor;
                update tareaExtension;
            }
        }
    }
    
   
    @AuraEnabled
    public static Boolean comprobarAutenticacion(Id recordId){
        Boolean resultado = false;
        if(recordId != null){
            Case caso = [SELECT CC_Status_Autorizacion__c FROM Case WHERE Id = :recordId];
            if(caso.CC_Status_Autorizacion__c == 'APPROVED'){
               resultado = true;
            }
        }
        return resultado;
    }

    @AuraEnabled
    public static String crearTareaTF9(String recordId, String motivo){
        String resultado = '';
        if(!String.isEmpty(recordId) && !String.isEmpty(motivo)){
            resultado = getUrl(recordId, motivo);


            String idTask = '';
            List<Task> tareas = new List<Task>();
            //Crear actividad
            Task task = new Task();
            task.WhatId = recordId;
            task.Status = 'Completed';
            task.ActivityDate = System.today();
            task.Subject = motivo;
            task.Type = 'TF';
            task.CC_Fecha_Inicio__c = Datetime.valueOf(System.now());
            tareas.add(task);
            Database.SaveResult[] resultsTask =  CC_Activity.crearActividades(tareas, false);

        }
        return resultado;
    }

    public static String getUrl(String recordId, String motivo){
        //Inicializamos la variable
        String url = '';
        if(!String.isEmpty(recordId) && !String.isEmpty(motivo)){
        
        String cmtTraer = 'Ficha de tarjetas'.equals(motivo) ? 'CC_Ficha_Tarjetas' : 'Ficha de línea abierta'.equals(motivo) ? 'CC_Ficha_Linea_Abierta' : 'Ficha de Cuentas a la vista'.equals(motivo) ? 'CC_Ficha_Cuentas_Vista' : 'CC_Ficha_Cliente';
       
        if(!string.isEmpty(cmtTraer)){
            CIBE_Link__mdt result = CIBE_Link__mdt.getInstance(cmtTraer);
            Case  datosCaso = new Case();
            // Creamos un try catch para capturar los errores
               try{
                datosCaso = [SELECT Id,Account.Name, Account.AV_NumPerso__c, Account.CC_Numero_Documento__c, Account.CC_NumPerso__c FROM Case WHERE Id = :recordId];        
                if(String.isNotBlank(result.CIBE_Parameters__c)) { 
                    String identificadorAccount = String.isNotBlank(datosCaso.Account.CC_Numero_Documento__c) ? datosCaso.Account.CC_Numero_Documento__c : '';
                    String numperAccount = !String.isEmpty(datosCaso.Account.AV_NumPerso__c) ? datosCaso.Account.AV_NumPerso__c : !String.isEmpty(datosCaso.Account.CC_NumPerso__c) ? datosCaso.Account.CC_NumPerso__c : '';
                    String nombre = String.isNotBlank(datosCaso.Account.Name) ? datosCaso.Account.Name : '';

                    url=  result.CIBE_URL__C.replace('{numperso}',numperAccount ).replace('{nif}',identificadorAccount ).replace('{nombre}',nombre);
                    }
            
                }
                 catch(Exception e){
                    url = null;
                 }
            }  
        }
        return url;
    }

    @AuraEnabled
    public static CC_Lista_Valores__c mensajeValidacionPreguntas(String validacion) {
        CC_Lista_Valores__c valorValidacion = new CC_Lista_Valores__c();
        valorValidacion.CC_Valor__c = '';
        if(!String.isEmpty(validacion)){
            List<CC_Lista_Valores__c> valorValidaciones = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_Mensajes_Parametrizables_Clientes' AND CC_Valor2__c = :validacion LIMIT 1];
            if(!valorValidaciones.isEmpty()){
                valorValidacion = valorValidaciones[0];
            }
        }
		return valorValidacion;
    }

    @AuraEnabled
    public static String llamadaWSOnboardingApex(String recordId, String nif) {
        if (nif == null || nif == '') {
            nif = [SELECT Account.CC_Numero_Documento__c FROM Case WHERE Id = :recordId LIMIT 1].Account.CC_Numero_Documento__c;
        }
        return CC_WS_Onboarding.recuperarClienteOnboarding(recordId, nif);
    }

    @AuraEnabled
    public static String tituloDerivar(String validacion) {
        String resultado = '';
        if(!String.isEmpty(validacion)){
            List<CC_Lista_Valores__c> valorValidaciones = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Textos operativa Derivar' AND Name = :validacion LIMIT 1];
            if(!valorValidaciones.isEmpty()){
                resultado = valorValidaciones[0].CC_Mensajes_Mostrar__c;
            }
        }
        return resultado;
    }

    @AuraEnabled
    public static Map<String, String> recuperarAmbitoMotivo(String recordId) {
        Map<String, String> mapaAmbitos = new Map<String, String>();
        List<CC_MCC__c> motivos = [SELECT CC_Ambito_Tareas_Caixa__c, CC_Ambito_Tareas_Imagin__c FROM CC_MCC__c WHERE Id = :recordId LIMIT 1];
        if(!motivos.isEmpty()){
             CC_MCC__c motivo = motivos[0];
            if (motivo.CC_Ambito_Tareas_Caixa__c != null){
            	mapaAmbitos.put('Caixa', motivo.CC_Ambito_Tareas_Caixa__c);
            }
            if (motivo.CC_Ambito_Tareas_Imagin__c != null){
            	mapaAmbitos.put('Imagin', motivo.CC_Ambito_Tareas_Imagin__c);
            }
        }
        return mapaAmbitos;
    }

    @AuraEnabled
    public static void envioCorreoOnboardingApex(String recordId) {
        CC_Gestion_Derivar_Onboarding.envioCorreoAutomatico(recordId);
    }

    @AuraEnabled
    public static Boolean comprobarCodigoOnboarding(String codigo) {
        String settingCodigos = CC_Settings__c.getValues('CC_CodigosOnboarding')?.CC_Configuracion_2__c;
        List<String> codigos = settingCodigos.split(';');
        return codigos.contains(codigo);
    }

    @AuraEnabled
    public static String tituloYaDerivado() {
        String titulo = '';
        List<CC_Lista_Valores__c> valorValidaciones = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Textos operativa Derivar' AND Name = 'Texto modal Onboarding ya derivado' LIMIT 1];
        if(!valorValidaciones.isEmpty()){
            titulo = valorValidaciones[0].CC_Mensajes_Mostrar__c;
        }
		return titulo;
    }

    @AuraEnabled
    public static List<String> getCanalesEscritos() {
        List<String> canales = new List<String>();
        List<CC_Lista_Valores__c> listaValores = [
            SELECT CC_Valor__c
            FROM CC_Lista_Valores__c
            WHERE CC_Lista__r.Name = 'CC_CanalesEscritos'
        ];

        for (CC_Lista_Valores__c valor : listaValores) {
            canales.add(valor.CC_Valor__c);
        }
        return canales;
    }

    //Mostrar modal guardar en Argos
    @AuraEnabled
    public static Boolean mostrarModalArgos(String recordId) {
        try {
            String config = CC_Settings__c.getValues('CC_AmbitosArgosGuardar').CC_Configuracion_1__c;
            List<String> ambitos = config.split(';');
            Boolean retorno=false;
            Boolean argos = false;
            Boolean restricted = false;
            Boolean ambitoCorrecto = false;
            Case caso = [SELECT Account.AV_IndicadoresClientes__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c FROM Case WHERE Id = :recordId ];
            if( caso.Account != null && caso.CC_MCC_Motivo__r != null) {
                Boolean esImagin = caso.Account.AV_IndicadoresClientes__c != null && caso.Account.AV_IndicadoresClientes__c.contains('28');
                String ambitoActual = esImagin ? caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c : caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c;
                
                if (!ambitos.contains(ambitoActual)) {
                    ambitoCorrecto = false;
                }else{
                    ambitoCorrecto = true;
                    argos = CC_Gestion_Derivar_Global.recuperarArgos(recordId);
                }
                retorno = argos && ambitoCorrecto;
            }
            return retorno;
        } catch (Exception e) {
            return false;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getMensajeOperativaDerivarArgos() {
        Map<String, Object> textosMap = CC_MetodosUtiles.getLOVNameValue(new List<String>{'Textos operativa Derivar'}, 'CC_Mensajes_Mostrar__c');       

        return textosMap.get('Argos true guardar').toString();
    }
    //Mostrar modal guardar en Argos

}