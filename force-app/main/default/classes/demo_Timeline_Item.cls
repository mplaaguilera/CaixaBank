public with sharing class demo_Timeline_Item {

    @AuraEnabled public Id id;
    @AuraEnabled public String objectApiName;
    @AuraEnabled public String titulo;
    @AuraEnabled public String subtitulo;
    @AuraEnabled public String campoFechaLabel;
    @AuraEnabled public String campoFechaValor;
    @AuraEnabled public String campo1Label;
    @AuraEnabled public String campo1Valor;
    @AuraEnabled public String campo2Label;
    @AuraEnabled public String campo2Valor;
    @AuraEnabled public String campo3Label;
    @AuraEnabled public String campo3Valor;
    @AuraEnabled public Map<String, Boolean> mapaSoloFecha = new Map<String, Boolean>();
    @AuraEnabled public Id idPadre;
    @AuraEnabled public String padreObjectRecordName;
    @AuraEnabled public String padreRecordTypeDeveloperName;
    @AuraEnabled public String padreTooltip;


    public static demo_Timeline_Item nuevoItem(Map<String, Map<String, Schema.SObjectField>> definicionCampos, SObject registro, Map<String, String> nombreCampos, Id idPadre, String padreRecordTypeDeveloperName, String padreTooltip) {

        String objectApiName = registro.getSObjectType().getDescribe().getName();
        /*
        if (objectApiName == 'Task' && registro.get('TaskSubtype') == 'Call') {
        objectApiName = 'Llamada';
        }
        */

        if (!definicionCampos.containsKey(objectApiName)) {
            definicionCampos.put(objectApiName, Schema.getGlobalDescribe().get(registro.getSObjectType().getDescribe().getName()).getDescribe().fields.getMap());
        }

        demo_Timeline_Item item = new demo_Timeline_Item();
        item.idPadre = idPadre;
        item.id = registro.Id;
        item.padreRecordTypeDeveloperName = padreRecordTypeDeveloperName;
        item.padreObjectRecordName = idPadre.getSObjectType().getDescribe().getName();
        item.padreTooltip = padreTooltip;
        item.objectApiName = objectApiName;
        item.titulo = valorCampo(registro, nombreCampos.get('campoTitulo'));
        item.subtitulo = valorCampo(registro, nombreCampos.get('campoSubtitulo'));
        item.campoFechaLabel = definicionCampos.get(objectApiName).get(nombreCampos.get('campoFecha').toLowerCase()).getDescribe().getLabel();
        item.campoFechaValor = valorCampo(registro, nombreCampos.get('campoFecha'));

        if (registro.get(nombreCampos.get('campoFecha')) instanceof Date) {
            item.mapaSoloFecha.put(item.campoFechaLabel, true);
        } else {
            item.mapaSoloFecha.put(item.campoFechaLabel, false);
        }
        if (String.isNotBlank(nombreCampos.get('campo1'))) {
            item.campo1Label = definicionCampos.get(objectApiName).get(nombreCampos.get('campo1').toLowerCase()).getDescribe().getLabel();
            item.campo1Valor = valorCampo(registro, nombreCampos.get('campo1'));
            if (registro.get(nombreCampos.get('campo1')) instanceof Date) {
                item.mapaSoloFecha.put(item.campo1Label, true);
            } else if (registro.get(nombreCampos.get('campo1')) instanceof Datetime) {
                item.mapaSoloFecha.put(item.campo1Label, false);
            }
        }
        if (String.isNotBlank(nombreCampos.get('campo2'))) {
            item.campo2Label = definicionCampos.get(objectApiName).get(nombreCampos.get('campo2').toLowerCase()).getDescribe().getLabel();
            item.campo2Valor = valorCampo(registro, nombreCampos.get('campo2'));
            if (registro.get(nombreCampos.get('campo2')) instanceof Date) {
                item.mapaSoloFecha.put(item.campo2Label, true);
            } else if (registro.get(nombreCampos.get('campo2')) instanceof Datetime) {
                item.mapaSoloFecha.put(item.campo2Label, false);
            }
        }
        if (String.isNotBlank(nombreCampos.get('campo3'))) {
            item.campo3Label = definicionCampos.get(objectApiName).get(nombreCampos.get('campo3').toLowerCase()).getDescribe().getLabel();
            item.campo3Valor = valorCampo(registro, nombreCampos.get('campo3'));
            if (registro.get(nombreCampos.get('campo3')) instanceof Date) {
                item.mapaSoloFecha.put(item.campo3Label, true);
            } else if (registro.get(nombreCampos.get('campo3')) instanceof Datetime) {
                item.mapaSoloFecha.put(item.campo3Label, false);
            }
        }

        return item;
    }

    private static String valorCampo(SObject registro, String nombreCampo) {
        //Campos de objeto relacionados
        Object valorCampo = null;
        if (nombreCampo != null) {
            if (nombreCampo.containsNone('.')) {
                valorCampo = registro.get(nombreCampo);
            } else {
                Map<String, Object> mapaCamposActual = registro.getPopulatedFieldsAsMap();
                for (String campoJoin : nombreCampo.split('\\.')) {
                    if (nombreCampo.contains('.') && campoJoin != nombreCampo.substringAfterLast('.')) { //Lookup
                        if (mapaCamposActual.get(campoJoin) != null) {
                            mapaCamposActual = ((SObject)mapaCamposActual.get(campoJoin)).getPopulatedFieldsAsMap();
                        }
                    } else {
                        valorCampo = mapaCamposActual.get(campoJoin);
                    }
                }
            }
        }
        return valorCampo == null ? null : String.valueOf(valorCampo);
    }
}