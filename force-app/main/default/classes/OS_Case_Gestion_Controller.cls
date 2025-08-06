public with sharing class OS_Case_Gestion_Controller {

    @AuraEnabled
    public static Map<String, Object> init(Id recordId) {

        List<Case> casos = new List<Case>();

        // Comprobamos que el recorId no venga nulo
        if (recordId != null) {
            casos = [SELECT RecordType.Name,
            CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name,
            CC_MCC_Causa__c, CC_MCC_Causa__r.Name, CC_MCC_Solucion__c, CC_MCC_Solucion__r.Name, OS_Departamento__c, Origin, CC_Canal_Procedencia__c
            FROM Case WHERE Id = :recordId];
        }

        Map<String, Object> retorno = new Map<String, Object>();

        // Verificar que la lista 'caso' no está vacía antes de intentar acceder a sus campos
        if (!casos.isEmpty()) {
            // Asignamos al caso el registro de la lista
            Case caso = casos[0];
    
            retorno.put('RecordTypeName', caso.RecordType.Name);
            retorno.put('Tematica_Caso', String.valueOf(caso.CC_MCC_Tematica__c));
            retorno.put('Tematica_Caso_Name', String.valueOf(caso.CC_MCC_Tematica__r.Name));
            retorno.put('Producto_Caso', String.valueOf(caso.CC_MCC_ProdServ__c));
            retorno.put('Producto_Caso_Name', String.valueOf(caso.CC_MCC_ProdServ__r.Name));
            retorno.put('Motivo_Caso', String.valueOf(caso.CC_MCC_Motivo__c));
            retorno.put('Motivo_Caso_Name', String.valueOf(caso.CC_MCC_Motivo__r.Name));
            retorno.put('Causa_Caso', nullValue(String.valueOf(caso.CC_MCC_Causa__c), 'NULL'));
            retorno.put('Causa_Caso_Name', nullValue(String.valueOf(caso.CC_MCC_Causa__r.Name), 'NULL'));
            retorno.put('Solucion_Caso', nullValue(String.valueOf(caso.CC_MCC_Solucion__c), 'NULL'));
            retorno.put('Solucion_Caso_Name', nullValue(String.valueOf(caso.CC_MCC_Solucion__r.Name), 'NULL'));
            retorno.put('Departamento', caso.OS_Departamento__c);
            retorno.put('Canal_Entrada', caso.Origin);
            retorno.put('Canal_Procedencia', caso.CC_Canal_Procedencia__c);
            retorno.put('Tarea_Traslado', false);
    
            if([SELECT Count() FROM Task WHERE WhatId = :caso.Id AND OS_Tipo__c = 'Traslado Colaborador'] > 0){
                retorno.put('Tarea_Traslado', true);
            }
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getTematicas(String tipoCliente, String departamento) {
        List<OT_Picklist.Item> tematicas = new List<OT_Picklist.Item>();
         
        if(String.isBlank(departamento)){
            for (CC_MCC__c tematica : [SELECT Name FROM CC_MCC__c
                                        WHERE RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
                                        AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)') 
                                        AND CC_Activo__c = true ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item(tematica.Id, tematica.Name);
                tematicas.add(wrap);
                                        }
        } else {
            for (CC_MCC__c tematica : [SELECT Name FROM CC_MCC__c
                                        WHERE RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
                                        AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)') 
                                        AND CC_Activo__c = true AND OS_Departamento__c = :departamento ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item(tematica.Id, tematica.Name);
                tematicas.add(wrap);
                                        }
        }
        
        return tematicas;
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getProductos(String tipoCliente, String tematica) {
        if (String.isBlank(tematica)) {
            return new List<OT_Picklist.Item>();
        } else {
            List<OT_Picklist.Item> productos = new List<OT_Picklist.Item>();

            for (CC_MCC__c producto : [SELECT Name FROM CC_MCC__c WHERE CC_Tematica__c = :tematica
                                        AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio')
                                        AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)') 
                                        AND CC_Activo__c = true ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item( producto.Id,producto.Name);
                productos.add(wrap);
            }                    
            
            return productos;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getMotivos(String tipoCliente, String producto) {
        if (String.isBlank(producto)) {
            return new List<OT_Picklist.Item>();
        } else {
            List<OT_Picklist.Item> motivos = new List<OT_Picklist.Item>();

            for (CC_MCC__c motivo : [SELECT Name FROM CC_MCC__c  WHERE CC_Producto_Servicio__c = :producto
                                        AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo')
                                        AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)') 
                                        AND CC_Activo__c = true ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item(motivo.Id, motivo.Name);
                motivos.add(wrap);
            }
            
            return motivos;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getCausas(String tipoCliente, String motivo) {
        if (String.isBlank(motivo)) {
            return new List<OT_Picklist.Item>();
        } else {
            List<OT_Picklist.Item> causas = new List<OT_Picklist.Item>();
                        
            for (CC_MCC__c causa : [SELECT Name FROM CC_MCC__c WHERE CC_Motivo__c = :motivo
                                    AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa')
                                    AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)') 
                                    AND CC_Activo__c = true ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item(causa.Id, causa.Name);
                causas.add(wrap);
            }
            
            return causas;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getSoluciones(String tipoCliente, String causa) {
        if (String.isBlank(causa)) {
            return new List<OT_Picklist.Item>();
        } else {
            List<OT_Picklist.Item> soluciones = new List<OT_Picklist.Item>();

            for (CC_MCC__c solucion : [SELECT Name FROM CC_MCC__c WHERE CC_Causa__c = :causa
                                        AND RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion')
                                        AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)') 
                                        AND CC_Activo__c = true ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item(solucion.Id, solucion.Name);
                soluciones.add(wrap);
            }
            return soluciones;
        }
    }

    private static String nullValue(String valor, String valorSiNulo) {
        //Si la cadena es nula se retorna valorSiNulo (si éste es nulo se retorna una cadena vacía)
        return valor != null ? valor : valorSiNulo != null ? valorSiNulo : '';
    }
    
    @AuraEnabled
    public static String envioCorreoTrasladoAutomatico(Id idMotivo) {
        return [SELECT Id, CBK_Traslado_Remitido__c FROM CC_MCC__c WHERE Id = :idMotivo LIMIT 1].CBK_Traslado_Remitido__c;
    }

    @AuraEnabled
    public static Map<String, Object> validarGuardar(Id recordId, Id nuevaTematica, Id nuevoProducto, Id nuevoMotivo, Boolean esCierre,
                                                    String nuevoTipoContacto, String referenciaOperacion, String nuevaCausa, String nuevaSolucion) {

        List<Case> casos = new List<Case>();

        // Comprobamos que el recorId no venga nulo
        if (recordId != null) {
        casos = [SELECT CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name
                        FROM Case WHERE Id = :recordId];
        }

        Map<String, Object> resultado = new Map<String, Object>();
        // Verificar que la lista 'caso' no está vacía antes de intentar acceder a sus campos
        if (!casos.isEmpty()) {
            // Asignamos al caso el registro de la lista
            Case caso = casos[0];

            if (caso.CC_MCC_Tematica__c == nuevaTematica && caso.CC_MCC_ProdServ__c == nuevoProducto && caso.CC_MCC_Motivo__c == nuevoMotivo) {
                resultado.put('retipificar', false);
            } else {
                resultado.put('retipificar', true);
                resultado.put('tematicaAnteriorName', caso.CC_MCC_Tematica__r.Name);
                resultado.put('productoAnteriorName', caso.CC_MCC_ProdServ__r.Name);
                resultado.put('motivoAnteriorName', caso.CC_MCC_Motivo__r.Name);            
            }

            //Validaciones específicas para cierre
            if (esCierre) {
                String erroresCierre = '';
                //Tipo de contacto
                if (String.isEmpty(nuevoTipoContacto)) {
                    erroresCierre = '· Es necesario indicar el "Tipo de contacto" antes de cerrar el caso.\n';
                }
                            
                //Causa y solución
                if (String.isEmpty(nuevaCausa) || String.isEmpty(nuevaSolucion)) {
                    erroresCierre += '· Es necesario indicar una "Causa" y una "Solución" antes de cerrar el caso.\n';
                }
                
                //Referencia de la operación
                if (String.isNotEmpty(nuevoMotivo) && String.isEmpty(referenciaOperacion)
                && [SELECT OS_Requiere_Ref_Operacion__c FROM CC_MCC__c WHERE Id = :nuevoMotivo].OS_Requiere_Ref_Operacion__c) {
                    erroresCierre += '· La clasificación actual requiere informar la "Referencia de la operación" antes de cerrar el caso.\n';
                }

                if (String.isNotBlank(erroresCierre)) {
                    throw new AuraHandledException(erroresCierre.removeEnd('\n'));
                }
            }
        }
        return resultado;
    }

    @AuraEnabled
    public static void crearActividadRetipificacion(Id recordId, String tematicaAnterior, String productoAnterior, String motivoAnterior) {
        OS_Case.crearActividadRetipificacion(recordId, tematicaAnterior, productoAnterior, motivoAnterior);
    }

    @AuraEnabled
    public static void reabrirTareaTrasladoColaborador(Id recordId) {
        CC_Traslado_Colab.reabrirTareaTrasladoColab(new List<Id>{recordId});
    }

    @AuraEnabled @future
    public static void crearActividad(Id recordId, String tipo, String motivo) {
        OS_Activity.crearActividad(recordId, tipo, motivo);
    }

    @AuraEnabled
    public static void accionesCambioCanalProcedencia(Id idCaso, String canalProcedenciaAnterior) {
        OS_Case.accionesCambioCanalProcedencia(idCaso, canalProcedenciaAnterior);
    }
}