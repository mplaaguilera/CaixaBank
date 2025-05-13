public with sharing class FRA_Case_Gestion_Controller {

    @AuraEnabled
    public static Map<String, Object> init(Id recordId) {
        Map<String, Object> retorno = new Map<String, Object>();
        Case caso = [SELECT RecordType.Name,
                        CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name,
                        CC_MCC_Causa__c, CC_MCC_Causa__r.Name, CC_MCC_Solucion__c, CC_MCC_Solucion__r.Name, FRA_CampanaFraude__c
                        FROM Case WHERE Id = :recordId];

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
        retorno.put('FRA_CampanaFraude__c', caso.FRA_CampanaFraude__c);
        return retorno; 
    }

    @AuraEnabled(cacheable=true)
    public static List<CBK_CustomPicklist_Controller.PicklistItems> getPicklistValuesFMW(){
        return CBK_CustomPicklist_Controller.picklistValues('FRA_CampanaFraude__c', 'Case');
    }

    @AuraEnabled(cacheable=true)
    public static List<OT_Picklist.Item> getTematicas(String tipoCliente, Id recordId) {
        List<OT_Picklist.Item> tematicas = new List<OT_Picklist.Item>();
        String buzonOrigen;
        Case[] casoOrigen = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id=:recordId];
        
        // Case tiene buzón origen --- filtramos
        if(!casoOrigen.isEmpty() && casoOrigen[0].CC_Canal_Procedencia__c!=null){
            buzonOrigen=casoOrigen[0].CC_Canal_Procedencia__c;

            for (CC_MCC__c tematica : [SELECT Name FROM CC_MCC__c
            WHERE RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
            AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (FRA)')
            AND CC_Activo__c = true ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item(tematica.Id, tematica.Name);
                tematicas.add(wrap);
            }
        }
        else{
            for (CC_MCC__c tematica : [SELECT Name FROM CC_MCC__c
            WHERE RecordType.Id = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
            AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (FRA)') 
            AND CC_Activo__c = true ORDER BY Name ASC]) {
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
                                       AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (FRA)')  
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
                                     AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (FRA)') 
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
                                    AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (FRA)')  
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
                                        AND (CC_Tipo_Cliente__c = :tipoCliente OR CC_Tipo_Cliente__c = 'Cliente (FRA)')  
                                        AND CC_Activo__c = true ORDER BY Name ASC]) {
                OT_Picklist.Item wrap = new OT_Picklist.Item(solucion.Id, solucion.Name);
                soluciones.add(wrap);
            }
            return soluciones;
        }
    }

    private static String nullValue(String valor, String valorSiNulo) {
        return valor != null ? valor : valorSiNulo != null ? valorSiNulo : '';
    }

    @AuraEnabled
    public static Map<String, Object> validarGuardar(Id recordId, Id nuevaTematica, Id nuevoProducto, Id nuevoMotivo, Boolean esCierre,
                                                     String nuevoTipoContacto, String referenciaOperacion, String nuevaCausa, String nuevaSolucion) {
        Case caso = [SELECT Status,CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name
                        FROM Case WHERE Id = :recordId];

        Map<String, Object> resultado = new Map<String, Object>();

        resultado.put('caseStatus', caso.Status);

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

            if (String.isNotBlank(erroresCierre)) {
                throw new AuraHandledException(erroresCierre.removeEnd('\n'));
            }
        }
        return resultado; 
    }

    // Creación de actividades
    @AuraEnabled @future
    public static void crearActividad(Id recordId, String tipo, String motivo) {
        Case caso = [SELECT Id, Status, CC_CasoRelacionado__c FROM Case WHERE Id = :recordId LIMIT 1];
    
        if (caso.CC_CasoRelacionado__c != null) {     //Caso que sea derivado del contact
            insert new Task(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task'), 
                WhatId = recordId, //idCaso
                Type = 'Devuelto al Contact Center',
                Status = 'Rechazada',
                Subject = (tipo=='Reclasificación')?'Reclasificación del caso':tipo,
                Description = motivo,
                ActivityDate = System.today()
    
            );
        }else{
        insert new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task'), 
            WhatId = recordId, //idCaso
            Type = tipo,
            Status = 'Completed',
            Subject = (tipo=='Reclasificación')?'Reclasificación del caso':tipo,
            Description = motivo,
            ActivityDate = System.today()
        );
    }
}
@AuraEnabled @future
    public static void rechazarCasoFraude(Id recordId, String motivo) {
        
            // Obtener el caso de Fraude rechazado
            Case casoFraude = [SELECT Id, Status, CC_CasoRelacionado__c FROM Case WHERE Id = :recordId LIMIT 1];
            
            
            // (Opcional) Cerrar el caso de Fraude si ya no es necesario
            casoFraude.Status = 'Rechazado';

            // Actualizar los casos
            update new List<Case>{casoFraude};
            if (casoFraude.CC_CasoRelacionado__c != null){

                Map<String, Object> parametro = new Map<String, Object>{
                        'casoId' => casoFraude.CC_CasoRelacionado__c,
                        'motivo' => motivo
                };
                CC_Gestion_Derivar_Fraude.devolverCasoCC(parametro);

            }
           

            
    }

}