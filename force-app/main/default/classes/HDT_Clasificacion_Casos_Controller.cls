public with sharing class HDT_Clasificacion_Casos_Controller {

    @AuraEnabled
    public static Boolean actividadesTrasladoColaborador(Id recordId) {
        
        return ![SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Traslado Colaborador' LIMIT 1].isEmpty();
    }

    /*@Testvisible
    private static String recuperarOrderBy() {
        if ([SELECT Count() FROM GroupMember
            WHERE Group.DeveloperName = 'Cola_3N_CSBD' AND UserOrGroupId = :UserInfo.getUserId()] == 0) {
            return 'ORDER BY Name ASC';
        } else {
            return 'ORDER BY CC_3N_CSBD__c DESC, Name ASC';
        }
    }*/

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
    public static List<OT_Picklist.Item> getTematicas() { //String tipoCliente, String canalOperativo, String canalProcedencia
        //if (tipoCliente == 'CC_Empleado') {
			return OT_Picklist.picklistSoql([SELECT Name FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Tematica'
				AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC], 'Id', 'Name');

                //AND CC_Tipo_Cliente__c = :tipoCliente
        /*
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
        */
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getProductos(String tematica) {//String tipoCliente, String canalProcedencia
        //if (tipoCliente == 'CC_Empleado') {
        if (String.isBlank(tematica)) {
            return new List<OT_Picklist.Item>{new OT_Picklist.Item('', '')};
        } else {
            //if (tipoCliente == 'Empleado') {
				return OT_Picklist.picklistSoql([SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = :tematica
                                                    AND RecordType.DeveloperName = 'CC_Producto_Servicio'
                                                    AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC], 'Id', 'Name');

                                                    //AND CC_Tipo_Cliente__c = :tipoCliente
            /*
            } else if (tipoCliente == 'Empleado Bankia') {
                return OT_Picklist.picklistSoql([SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = :tematica
                                                    AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio')
                                                    AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC], 'Id', 'Name');
            } else {
                String stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = \'' + tematica + '\' AND RecordType.Id = \'' + CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio') + '\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                return OT_Picklist.picklistSoql(Database.query(stringQuery), 'Id', 'Name');
            }
            */
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getMotivos(String producto) {//String tipoCliente, String canalProcedencia
        if (String.isBlank(producto)) {
            return new List<PickListWrapper>();
        } else {
            List<PickListWrapper> motivos = new List<PickListWrapper>();
            //if (tipoCliente == 'Empleado') {
				for (CC_MCC__c motivo : [SELECT Name FROM CC_MCC__c  WHERE CC_Producto_Servicio__c = :producto
											AND RecordType.DeveloperName = 'CC_Motivo'
											AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC]) {
					PickListWrapper wrap = new PickListWrapper(motivo.Name, motivo.Id);
					motivos.add(new PickListWrapper(motivo.Name, motivo.Id));
				}
            /*
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
            */
            return motivos;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getCausas(String motivo) {//String tipoCliente, String canalProcedencia
        if (String.isBlank(motivo)) {
            return new List<PickListWrapper>();
        } else {
            List<PickListWrapper> causas = new List<PickListWrapper>();
            //if (tipoCliente == 'Empleado') {
				for (CC_MCC__c causa : [SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = :motivo
									AND RecordType.DeveloperName = 'CC_Causa'
									AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC]) {
					causas.add(new PickListWrapper(causa.Name, causa.Id));
				}
            /*
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
            */
            return causas;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getSoluciones(String causa) {//String tipoCliente, String canalProcedencia
        if (String.isBlank(causa)) {
            return new List<PickListWrapper>();
        } else {
            List<PickListWrapper> soluciones = new List<PickListWrapper>();
            //if (tipoCliente == 'Empleado') {
				for (CC_MCC__c solucion : [SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = :causa
											AND RecordType.DeveloperName = 'CC_Solucion'
											AND CC_Tipo_Cliente__c = 'HDT Empleado' AND CC_Activo__c = true ORDER BY Name ASC]) {
					soluciones.add(new PickListWrapper(solucion.Name, solucion.Id));
				}
            /*
            } else if (tipoCliente == 'Empleado Bankia') {
                for (CC_MCC__c solucion : [SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = :causa
                                            AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion')
                                            AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC]) {
                    soluciones.add(new PickListWrapper(solucion.Name, solucion.Id));
                }
            } else {
                Id idMCCySolucion = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
                String stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = \'' + causa + '\' AND RecordType.Id = \'' + idMCCySolucion + '\' AND CC_Tipo_Cliente__c = \'' + tipoCliente + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                for (CC_MCC__c solucion : Database.query(stringQuery)) {
                    PickListWrapper wrap = new PickListWrapper(solucion.Name, solucion.Id);
                    soluciones.add(new PickListWrapper(solucion.Name, solucion.Id));
                }
            }
            */
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
    public static Map<String, Object> validarGuardar(Id recordId, String nuevoCanalRespuesta, Id nuevaTematica, Id nuevoProducto, Id nuevoMotivo) {
        Case caso = [SELECT OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c,
						CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :recordId];

        if (caso.OwnerId != UserInfo.getUserId()) {
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
        return resultado;
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
        HDT_Case.crearActividadRetipificacion(recordId, tematicaAnterior, productoAnterior, motivoAnterior);
    }

    @AuraEnabled
    public static void reabrirTareaTrasladoColaborador(Id recordId) {
        //Si ya existe alguna tarea de Traslado a Colaborador abierta, no se debe hacer nada. En caso contrario se busca la más reciente de entre las cerradas
        if ([SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Traslado Colaborador' AND IsClosed = FALSE].isEmpty()) {
            List<Task> tareasTrasladoColaboradorCerradas = [SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Traslado Colaborador'
                                                            AND IsClosed = TRUE ORDER BY CreatedDate DESC LIMIT 1];
            //Se reabre la última tarea que estaba cerrada
            if (!tareasTrasladoColaboradorCerradas.isEmpty()) {
                tareasTrasladoColaboradorCerradas[0].Status = 'Open';
                update tareasTrasladoColaboradorCerradas[0];

                /* Este cambio de estado del caso hay que hacerlo en el LWC

                Case caso = new Case(Id = recordId);
                caso.Status = 'Pendiente Colaborador';
                update caso;
                */
            }
        }
    }

    @AuraEnabled
    public static void cerrarActividadSolicitudInformacion(Id recordId) {
        HDT_Activity.finalizarActividadCaso(recordId, 'Solicitud Información', null, null);
        Case caso = [SELECT Status from Case where id = :recordId];
        if(caso.Status == 'Pendiente Cliente'){
            caso.Status = 'Activo';
            update caso;
        }
    }

    /*
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
    }*/
    

    /*
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
    }*/

    /*
    @AuraEnabled
    public static Map<String, Object> initOld(Id recordId) {

        Map<String, Object> retorno = new Map<String, Object>();

        Case caso = [SELECT RecordTypeId, RecordType.Name, RecordType.DeveloperName, CC_Tipo_Cliente__c,
                        CC_Canal_Operativo__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_MCC_Causa__c,  CC_Causa__c
                        FROM Case WHERE Id = :recordId];

        List<PickListWrapper> tematicas = new List<PickListWrapper>();
        List<PickListWrapper> productos = new List<PickListWrapper>();
        List<PickListWrapper> motivos = new List<PickListWrapper>();
        List<PickListWrapper> causas = new List<PickListWrapper>();
        List<PickListWrapper> soluciones = new List<PickListWrapper>();

        if (caso.RecordType.Name == 'Empleado') {
            for (CC_MCC__c tematica : [SELECT Name FROM CC_MCC__c
                                        WHERE RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
                                        AND CC_Tipo_Cliente__c = :caso.RecordType.Name AND CC_Activo__c = true ORDER BY Name ASC]) {
                PickListWrapper wrap = new PickListWrapper(tematica.Name, tematica.Id);
                tematicas.add(wrap);
            }

            if (caso.CC_MCC_Tematica__c != null) {
                Id recordTypeIdProductoServicio = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                List <CC_MCC__c> listaProductos = [SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = :caso.CC_MCC_Tematica__c
                                                    AND RecordType.Id = :recordTypeIdProductoServicio AND CC_Tipo_Cliente__c = :caso.RecordType.Name AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c producto : listaProductos) {
                    PickListWrapper wrap = new PickListWrapper(producto.Name, producto.Id);
                    productos.add(wrap);
                }
            }

            if (caso.CC_MCC_ProdServ__c != null) {
                Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                List <CC_MCC__c> listaMotivos = [SELECT Name FROM CC_MCC__c WHERE CC_Producto_Servicio__c = :caso.CC_MCC_ProdServ__c
                                                    AND RecordType.Id = :recordTypeIdMotivo AND CC_Tipo_Cliente__c = :caso.RecordType.Name AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c motivo : listaMotivos) {
                    PickListWrapper wrap = new PickListWrapper(motivo.Name, motivo.Id);
                    motivos.add(wrap);
                }
            }

            if (caso.CC_MCC_Motivo__c != null) {
                Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
                List <CC_MCC__c> listaCausas = [SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = :caso.CC_MCC_Motivo__c
                                                AND RecordType.Id=:recordTypeIdCausa  AND CC_Tipo_Cliente__c = :caso.RecordType.Name AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c causa : listaCausas) {
                    PickListWrapper wrap = new PickListWrapper(causa.Name, causa.Id);
                    causas.add(wrap);
                }
            }

            if (caso.CC_MCC_Causa__c != null) {
                Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
                List <CC_MCC__c> listaSoluciones = [SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = :caso.CC_MCC_Causa__c
                                                    AND RecordType.Id=:recordTypeIdSolucion AND CC_Tipo_Cliente__c = :caso.RecordType.Name AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c solucion : listaSoluciones) {
                    PickListWrapper wrap = new PickListWrapper(solucion.Name, solucion.Id);
                    soluciones.add(wrap);
                }
            }
        } else if (caso.RecordType.Name == 'Empleado Bankia') {
            for (CC_MCC__c tematica : [SELECT Name FROM CC_MCC__c
                                        WHERE RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
                                        AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC]) {
                PickListWrapper wrap = new PickListWrapper(tematica.Name, tematica.Id);
                tematicas.add(wrap);
            }

            if (caso.CC_MCC_Tematica__c != null) {
                Id recordTypeIdProductoServicio = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                List <CC_MCC__c> listaProductos = [SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = :caso.CC_MCC_Tematica__c
                                                    AND RecordType.Id = :recordTypeIdProductoServicio AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c producto : listaProductos) {
                    PickListWrapper wrap = new PickListWrapper(producto.Name, producto.Id);
                    productos.add(wrap);
                }
            }

            if (caso.CC_MCC_ProdServ__c != null) {
                Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                List <CC_MCC__c> listaMotivos = [SELECT Name FROM CC_MCC__c WHERE CC_Producto_Servicio__c = :caso.CC_MCC_ProdServ__c
                                                    AND RecordType.Id = :recordTypeIdMotivo AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c motivo : listaMotivos) {
                    PickListWrapper wrap = new PickListWrapper(motivo.Name, motivo.Id);
                    motivos.add(wrap);
                }
            }

            if (caso.CC_MCC_Motivo__c != null) {
                Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
                List <CC_MCC__c> listaCausas = [SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = :caso.CC_MCC_Motivo__c
                                                AND RecordType.Id=:recordTypeIdCausa  AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c causa : listaCausas) {
                    PickListWrapper wrap = new PickListWrapper(causa.Name, causa.Id);
                    causas.add(wrap);
                }
            }

            if (caso.CC_MCC_Causa__c != null) {
                Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
                List <CC_MCC__c> listaSoluciones = [SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = :caso.CC_MCC_Causa__c
                                                    AND RecordType.Id=:recordTypeIdSolucion AND CC_Tipo_Cliente__c = 'CSI Bankia' AND CC_Activo__c = true ORDER BY Name ASC];
                for (CC_MCC__c solucion : listaSoluciones) {
                    PickListWrapper wrap = new PickListWrapper(solucion.Name, solucion.Id);
                    soluciones.add(wrap);
                }
            }
        } else {
            //ordenamos o por name o por Cola_3N_CSBD
            Id tematicaRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            String stringQuery;
            if(caso.CC_Canal_Operativo__c != null && caso.CC_Canal_Operativo__c != ''){
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE RecordType.Id = \'' + tematicaRecordType + '\' AND CC_Tipo_Cliente__c = \'' + caso.RecordType.Name + '\' AND CC_Activo__c = true AND CC_Canal_Operativo__c INCLUDES (\''+ caso.CC_Canal_Operativo__c+'\') ' + recuperarOrderBy();
            }else{
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE RecordType.Id = \'' + tematicaRecordType + '\' AND CC_Tipo_Cliente__c = \'' + caso.RecordType.Name + '\' AND CC_Activo__c = true '+ recuperarOrderBy();
            }
            for (CC_MCC__c tematica : Database.query(stringQuery)) {
                PickListWrapper wrap = new PickListWrapper(tematica.Name, tematica.Id);
                tematicas.add(wrap);
            }

            if (caso.CC_MCC_Tematica__c != null) {
                Id recordTypeIdProductoServicio = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = \'' + caso.CC_MCC_Tematica__c + '\' AND RecordType.Id = \'' + recordTypeIdProductoServicio + '\' AND CC_Tipo_Cliente__c = \'' + caso.RecordType.Name + '\' AND CC_Activo__c = true ' + recuperarOrderBy();


                List <CC_MCC__c> listaProductos = database.query(stringQuery);
                for (CC_MCC__c producto : listaProductos) {
                    PickListWrapper wrap = new PickListWrapper(producto.Name, producto.Id);
                    productos.add(wrap);
                }
            }

            if (caso.CC_MCC_ProdServ__c != null) {
                Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Producto_Servicio__c = \'' + caso.CC_MCC_ProdServ__c + '\' AND RecordType.Id = \'' + recordTypeIdMotivo + '\' AND CC_Tipo_Cliente__c = \'' + caso.RecordType.Name + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                List <CC_MCC__c> listaMotivos = Database.query(stringQuery);
                for (CC_MCC__c motivo : listaMotivos) {
                    PickListWrapper wrap = new PickListWrapper(motivo.Name, motivo.Id);
                    motivos.add(wrap);
                }
            }

            if (caso.CC_MCC_Motivo__c != null) {
                Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = \'' + caso.CC_MCC_Motivo__c + '\' AND RecordType.Id = \'' + recordTypeIdCausa + '\' AND CC_Tipo_Cliente__c = \'' + caso.RecordType.Name + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                List <CC_MCC__c> listaCausas = Database.query(stringQuery);
                for (CC_MCC__c causa : listaCausas) {
                    PickListWrapper wrap = new PickListWrapper(causa.Name, causa.Id);
                    causas.add(wrap);
                }
            }

            if (caso.CC_MCC_Causa__c != null) {
                Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
                stringQuery = 'SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = \'' + caso.CC_MCC_Causa__c + '\' AND RecordType.Id = \'' + recordTypeIdSolucion + '\' AND CC_Tipo_Cliente__c = \'' + caso.RecordType.Name + '\' AND CC_Activo__c = true ' + recuperarOrderBy();
                List <CC_MCC__c> listaSoluciones = Database.query(stringQuery);
                for (CC_MCC__c solucion : listaSoluciones) {
                    PickListWrapper wrap = new PickListWrapper(solucion.Name, solucion.Id);
                    soluciones.add(wrap);
                }
            }
        }

        retorno.put('Tematicas', tematicas);
        retorno.put('Productos', productos);
		retorno.put('Motivos', motivos);
		retorno.put('Causas', causas);
        retorno.put('Soluciones', soluciones);

        List<PickListWrapper> canalesoperativos = new List<PickListWrapper>();
        for (Schema.PicklistEntry f : Case.CC_Canal_Operativo__c.getDescribe().getPicklistValues()) {
            canalesoperativos.add(new PickListWrapper(f.getLabel(), f.getValue()));
        }
        retorno.put('CanalesOperativos', canalesoperativos);

        //Campañas
        List<PickListWrapper> campanas = new List<PickListWrapper>();
        for (CC_Caracteristica__c caract : [SELECT Name FROM CC_Caracteristica__c WHERE recordtypeId = :Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId()]) {
            PickListWrapper wrap = new PickListWrapper(caract.Name, caract.Id);
            campanas.add(wrap);
        }
        retorno.put('Campanas', campanas);

        //Errores TF
        List<PickListWrapper> errores = new List<PickListWrapper>();
        for (CC_Lista_Valores__c error : [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Errores Terminal Financiero']) {
            PickListWrapper wrap = new PickListWrapper(error.CC_Valor__c, error.CC_Valor__c);
            errores.add(wrap);
        }
        retorno.put('ErroresTF', errores);
        retorno.put('actividadesTrasladoColanorador', ![SELECT Id FROM Task WHERE WhatId = :recordId AND Type = 'Traslado Colaborador'].isEmpty());

        return retorno;
    }
    */
}