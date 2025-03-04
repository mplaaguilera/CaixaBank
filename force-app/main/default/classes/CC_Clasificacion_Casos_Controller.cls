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
        Case caso = [SELECT OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c,
        CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :recordId];
        
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
        resultado.put('tieneActividad',tieneActividad);
        return resultado;
    }
    
    @AuraEnabled
    public static Map<String, Object> validarGuardarCerrar(Id recordId,boolean cerrar, String nuevoCanalRespuesta, Id nuevaTematica, Id nuevoProducto, Id nuevoMotivo, String agrupacionComprobacion) {
        Case caso = [SELECT RecordType.DeveloperName,CC_MCC_Causa__c,CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_Creada__c FROM Case WHERE Id = :recordId];
        CC_Settings__c configuracionFuncionalidad = CC_Settings__c.getValues('CC_OperativaOficinaGuardar');
        Boolean tieneActividad = false;
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
                                List<CC_MCC__c> solucion = [SELECT Id FROM CC_MCC__c WHERE Id = :caso.CC_MCC_Solucion__c AND CC_Activo__c = true];
                                if(solucion.isEmpty()){
                                    errores += 'y Solución';
                                }
                            }
                        }
                    }
                }
                if(errores != '') {
                    throw new AuraHandledException('No se puede cerrar un caso sí los campos ' + errores + ' no estan vigentes'); 
                }                
            }
        }

        if (configuracionFuncionalidad.CC_Configuracion_1__c == 'true' && caso.AccountId != null && caso.ContactId != null && caso.RecordType.DeveloperName == 'CC_Cliente' && (agrupacionComprobacion == 'Derivar a oficina' || agrupacionComprobacion == 'Derivar a oficina: Limitación protocolo')) {
            List<Task> tareas = [SELECT Id FROM Task WHERE AV_Case__c = :recordId AND Type IN ('Tarea gestor', 'Oportunidad CSBD')];
            if(!tareas.isEmpty() || caso.CC_Oportunidad_Creada__c) {
                tieneActividad = true;
            }                    
        } else {
            tieneActividad = true;
        }
        return validarGuardar(recordId, nuevoCanalRespuesta, nuevaTematica, nuevoProducto, nuevoMotivo, tieneActividad);
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
        CC_Lista_Valores__c valorValidacion = null;
        if(!String.isEmpty(validacion)){
            valorValidacion = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_Mensajes_Parametrizables_Clientes' AND CC_Valor2__c = :validacion LIMIT 1];
        }
		return valorValidacion;
    }
}