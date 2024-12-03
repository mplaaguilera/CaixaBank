public with sharing class OB_Parametrizacion_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<OB_Parametrizacion__c>)tp.newList, (Map<Id, OB_Parametrizacion__c>)tp.newMap, (List<OB_Parametrizacion__c>)tp.oldList, (Map<Id, OB_Parametrizacion__c>)tp.oldMap);
    }

    private void process(List<OB_Parametrizacion__c> listNewObj, Map<Id, OB_Parametrizacion__c> mapNewObj, List<OB_Parametrizacion__c> listOldObj, Map<Id, OB_Parametrizacion__c> mapOldObj) {
        nombreRelacionCampanyaProducto(listNewObj);
        validacionNombreUnico(mapOldObj, mapNewObj);
        validacionActivoCodigoExternoUnico(mapOldObj, mapNewObj);
        validacionesRelacionCampanyaProducto(listNewObj);
    }

    private static void validacionNombreUnico(Map<Id, OB_Parametrizacion__c> parametrizacionesOld, Map<Id, OB_Parametrizacion__c> parametrizacionesNew) {
        List<OB_Parametrizacion__c> parametrizacionesCambioNombre = new List<OB_Parametrizacion__c>();
        for (OB_Parametrizacion__c parametrizacion : parametrizacionesNew.values()) {
            if (parametrizacion.Name != parametrizacionesOld.get(parametrizacion.Id).Name) {
                parametrizacionesCambioNombre.add(parametrizacion);
            }
        }
        List<String> nombresDuplicados = CC_MetodosUtiles.listaCampo(
            [SELECT Name FROM OB_Parametrizacion__c WHERE Name IN :CC_MetodosUtiles.listaCampo(parametrizacionesCambioNombre, 'Name')]
            , 'Name'
        );
        for (OB_Parametrizacion__c parametrizacion : parametrizacionesCambioNombre) {
            if (nombresDuplicados.contains(parametrizacion.Name)) {
                parametrizacionesNew.get(parametrizacion.Id).addError('Ya existe un registro de parametrización con el mismo nombre.');
            } 
        }
    }

    private static void validacionActivoCodigoExternoUnico(Map<Id, OB_Parametrizacion__c> parametrizacionesOld, Map<Id, OB_Parametrizacion__c> parametrizacionesNew) {
        List<OB_Parametrizacion__c> parametrizacionesCambioCodigo = new List<OB_Parametrizacion__c>();
        for (OB_Parametrizacion__c parametrizacion : parametrizacionesNew.values()) {
            if (parametrizacion.OB_Activo__c != parametrizacionesOld.get(parametrizacion.Id).OB_Activo__c) {
                parametrizacionesCambioCodigo.add(parametrizacion);
            }else if (parametrizacion.OB_Codigo_Externo__c != parametrizacionesOld.get(parametrizacion.Id).OB_Codigo_Externo__c) {
                parametrizacionesCambioCodigo.add(parametrizacion);
            }
        }

        List<String> activosDuplicados = CC_MetodosUtiles.listaCampo(
            [SELECT OB_Activo__c FROM OB_Parametrizacion__c WHERE OB_Codigo_Externo__c IN :CC_MetodosUtiles.listaCampo(parametrizacionesCambioCodigo, 'OB_Codigo_Externo__c') AND
            OB_Activo__c = True AND
            RecordType.DeveloperName = 'OB_Producto']
            , 'OB_Activo__c'
        );

        List<String> codigosDuplicados = CC_MetodosUtiles.listaCampo(
            [SELECT OB_Codigo_Externo__c FROM OB_Parametrizacion__c WHERE OB_Codigo_Externo__c IN :CC_MetodosUtiles.listaCampo(parametrizacionesCambioCodigo, 'OB_Codigo_Externo__c') AND
            OB_Activo__c = True AND
            RecordType.DeveloperName = 'OB_Producto']
            , 'OB_Codigo_Externo__c'
        );

        for (OB_Parametrizacion__c parametrizacion : parametrizacionesCambioCodigo) {
            if(parametrizacion.OB_Activo__c == true){
                if (activosDuplicados.size() != 0) {
                    parametrizacionesNew.get(parametrizacion.Id).addError('Ya existe un registro de parametrización que está activo.');
                } 

                if (codigosDuplicados.contains(parametrizacion.OB_Codigo_Externo__c)) {
                    parametrizacionesNew.get(parametrizacion.Id).addError('Ya existe un registro de parametrización con el mismo código externo.');
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
        Map<Id, OB_Parametrizacion__c> productos = new Map<Id, OB_Parametrizacion__c>(
            [SELECT OB_Parametrizacion_Padre__r.OB_Envio_GDD__c FROM OB_Parametrizacion__c
                WHERE Id IN :CC_MetodosUtiles.listaCampo(parametrizaciones, 'OB_Parametrizacion_Relacionada__c')]
        );
        for (OB_Parametrizacion__c parametrizacion : parametrizaciones) {
            if (parametrizacion.RecordTypeId == CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto')
            && parametrizacion.OB_Envio_GDD__c) {
                if (!productos.get(parametrizacion.OB_Parametrizacion_Relacionada__c).OB_Parametrizacion_Padre__r.OB_Envio_GDD__c) {
                    parametrizacion.addError('El producto pertenece a una familia que no admite envío a GDD');
                }
            }
        }
    }
}