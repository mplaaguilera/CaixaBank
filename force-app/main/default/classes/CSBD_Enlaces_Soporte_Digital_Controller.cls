public with sharing class CSBD_Enlaces_Soporte_Digital_Controller {

    @TestVisible
    private class Enlace {
        @AuraEnabled public String label;
        @AuraEnabled public String url;

        public Enlace(String label, String url) {
            this.label = label;
            this.url = url;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Enlace> getEnlaces(String nombreProducto, String origen) {
        if (String.isBlank(nombreProducto)) {
            return null;
        }

        List<CC_Lista_Valores__c> valores = [SELECT CSBD_Soporte_Digital_Ficha_Producto__c, CSBD_Soporte_Digital_Argumentario__c,
                                                CSBD_Soporte_Digital_Campanyas__c, CSBD_Soporte_Digital_Material_Apoyo__c,
                                                CSBD_Soporte_Digital_Origen__c
                                                FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: Enlaces de soporte digital'
                                                AND Name IN :(new List<String>{nombreProducto, origen}) LIMIT 2];
        if (valores.isEmpty()) {
            return null;
        } else {
            List<Enlace> enlaces = new List<Enlace>();

            for (CC_Lista_Valores__c valor : valores) {
                if (String.isNotBlank(valor.CSBD_Soporte_Digital_Ficha_Producto__c)) {
                    enlaces.add(new Enlace('Ficha del producto', valor.CSBD_Soporte_Digital_Ficha_Producto__c));
                }
                if (String.isNotBlank(valor.CSBD_Soporte_Digital_Argumentario__c)) {
                    enlaces.add(new Enlace('Argumentario comercial', valor.CSBD_Soporte_Digital_Argumentario__c));
                }
                if (String.isNotBlank(valor.CSBD_Soporte_Digital_Campanyas__c)) {
                    enlaces.add(new Enlace('Campañas', valor.CSBD_Soporte_Digital_Campanyas__c));
                }
                if (String.isNotBlank(valor.CSBD_Soporte_Digital_Material_Apoyo__c)) {
                    enlaces.add(new Enlace('Material de apoyo', valor.CSBD_Soporte_Digital_Material_Apoyo__c));
                }
                if (String.isNotBlank(valor.CSBD_Soporte_Digital_Origen__c)) {
                    enlaces.add(new Enlace('Origen', valor.CSBD_Soporte_Digital_Origen__c));
                }
            }
            return enlaces;
        }
    }
}