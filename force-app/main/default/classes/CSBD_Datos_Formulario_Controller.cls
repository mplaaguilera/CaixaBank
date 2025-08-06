public with sharing class CSBD_Datos_Formulario_Controller {

    @AuraEnabled(cacheable=true)
    public static Retorno getSolicitud(Id idOportunidad) {
        try {
            Retorno retorno = new Retorno();
            List<Map<String, String>> datosFormulario = new List<Map<String, String>>();
            List<Task> tareasSolicitudRecibida = [SELECT CC_Fecha_Inicio__c, Description FROM Task WHERE RecordType.DeveloperName = 'CSBD_Task'
                                                    AND WhatId = :idOportunidad AND Type = 'Solicitud recibida'];
            if (tareasSolicitudRecibida.size() == 1 && String.isNotBlank(tareasSolicitudRecibida[0].Description)) {
                tareasSolicitudRecibida[0].Description = JSON.serializePretty(JSON.deserializeUntyped(tareasSolicitudRecibida[0].Description), true);
                retorno.tareaSolicitudRecibida = tareasSolicitudRecibida[0];
                Map<String, Object> valores = (Map<String, Object>)JSON.deserializeUntyped(tareasSolicitudRecibida[0].Description);
                for (String clave : valores.keySet()) {
                    datosFormulario.add(new Map<String, String>{
                        'nombre' => clave,
                        'valor' => String.isNotBlank(String.valueOf(valores.get(clave))) ? String.valueOf(valores.get(clave)) : ''
                    });
                }
            }
            retorno.datosFormulario = datosFormulario;
            return retorno;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Retorno {
        @AuraEnabled
        public List<Map<String, String>> datosFormulario {get;set;}
        @AuraEnabled
        public Task tareaSolicitudRecibida {get;set;}

        Retorno() {
            this.datosFormulario = new List<Map<String, String>>();
        }
    }
}