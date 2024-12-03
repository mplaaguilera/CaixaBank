public with sharing class OB_Parametrizacion_BI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<OB_Parametrizacion__c>)tp.newList);
	}
    
    private void process(List<OB_Parametrizacion__c> parametrizaciones) {
        nombreRelacionCampanyaProducto(parametrizaciones);
        validacionNombreUnico(parametrizaciones);
        validacionCodigoExternoActivoUnico(parametrizaciones);
        validacionesRelacionCampanyaProducto(parametrizaciones);
	}

    private static void validacionNombreUnico(List<OB_Parametrizacion__c> parametrizaciones) {
        List<String> nombresDuplicados = CC_MetodosUtiles.listaCampo(
            [SELECT Name FROM OB_Parametrizacion__c WHERE Name IN :CC_MetodosUtiles.listaCampo(parametrizaciones, 'Name')]
            , 'Name'
        );
        
        for (OB_Parametrizacion__c parametrizacion : parametrizaciones) {
            if (nombresDuplicados.contains(parametrizacion.Name)) {
                parametrizacion.addError('Ya existe un registro de parametrización con el mismo nombre.');
            } 
        }
    }

    private static void validacionCodigoExternoActivoUnico(List<OB_Parametrizacion__c> parametrizaciones) {
        List<String> codigosActivos = CC_MetodosUtiles.listaCampo(
            [SELECT OB_Codigo_Externo__c FROM OB_Parametrizacion__c WHERE OB_Codigo_Externo__c IN :CC_MetodosUtiles.listaCampo(parametrizaciones, 'OB_Codigo_Externo__c') AND
            OB_Activo__c = True AND
            RecordType.DeveloperName = 'OB_Producto']
            , 'OB_Codigo_Externo__c'
        );

        for (OB_Parametrizacion__c parametrizacion : parametrizaciones) {
            if(parametrizacion.OB_Activo__c == true){
                if (codigosActivos.size() != 0) {
                    parametrizacion.addError('Ya existe un registro de parametrización que está activo.');
                } 

                if (codigosActivos.contains(parametrizacion.OB_Codigo_Externo__c)) {
                    parametrizacion.addError('Ya existe un registro de parametrización con el mismo código externo.');
                } 
            }
        }
    }

    private static void nombreRelacionCampanyaProducto(List<OB_Parametrizacion__c> parametrizaciones) {
        Set<Id> idCampanyasProductos = new Set<Id>();
        for (OB_Parametrizacion__c parametrizacion : parametrizaciones) {
            idCampanyasProductos.add(parametrizacion.OB_Parametrizacion_Padre__c);
            idCampanyasProductos.add(parametrizacion.OB_Parametrizacion_Relacionada__c);
        }

        Map<Id, String> campanyasProductos = new Map<Id, String>();
        for (OB_Parametrizacion__c campanyaProducto : [SELECT Name FROM OB_Parametrizacion__c WHERE Id IN :idCampanyasProductos]) {
            campanyasProductos.put(campanyaProducto.Id, campanyaProducto.Name);
        }

        for (OB_Parametrizacion__c parametrizacion : parametrizaciones) {
            if (parametrizacion.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto')) {
                parametrizacion.Name = campanyasProductos.get(parametrizacion.OB_Parametrizacion_Padre__c);
                parametrizacion.Name += ' - ' + campanyasProductos.get(parametrizacion.OB_Parametrizacion_Relacionada__c);
            }
        }
    }

    private static void validacionesRelacionCampanyaProducto(List<OB_Parametrizacion__c> parametrizaciones) {

        Id idRtRelacionCampanyaProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto');
        List<OB_Parametrizacion__c> relacionesCampanyaProductoConEnvioGdd = new List<OB_Parametrizacion__c>();
        for (OB_Parametrizacion__c parametrizacion : parametrizaciones) {
            if (parametrizacion.RecordTypeId == idRtRelacionCampanyaProducto && parametrizacion.OB_Envio_GDD__c) {
                relacionesCampanyaProductoConEnvioGdd.add(parametrizacion);
            }
        }

        if (!relacionesCampanyaProductoConEnvioGdd.isEmpty()) {
            Map<Id, OB_Parametrizacion__c> productos = new Map<Id, OB_Parametrizacion__c>(
                [SELECT OB_Parametrizacion_Padre__r.OB_Envio_GDD__c FROM OB_Parametrizacion__c
                    WHERE Id IN :CC_MetodosUtiles.listaCampo(relacionesCampanyaProductoConEnvioGdd, 'OB_Parametrizacion_Relacionada__c')]
            );
            for (OB_Parametrizacion__c relacionCampanyaProducto : relacionesCampanyaProductoConEnvioGdd) {
                if (!productos.get(relacionCampanyaProducto.OB_Parametrizacion_Relacionada__c).OB_Parametrizacion_Padre__r.OB_Envio_GDD__c) {
                    relacionCampanyaProducto.addError('El producto pertenece a una familia que no admite envío a GDD');
                }
            }
        }
    }
}