public with sharing class CC_Llamada_Caso_Nuevo_Controller {

    @AuraEnabled
    public static Case crearCasoLlamada(Id recordId, String asunto) {
        CC_Llamada__c llamada = [SELECT CC_Contacto__r.CC_Matricula__c,RecordType.DeveloperName, CC_Representante__c, CC_Sentimiento__c,CC_Resumen_AI__c, CC_Respuesta_Asistente__c,  CC_Servicio_Genesys__c,
                                    CC_Fecha_Inicio__c, CC_Fecha_Fin__c, CC_Idioma__c, CC_Asunto__c, CC_DNIS__c, CC_ANI__c, CC_No_Identificado__c, CC_Cuenta__c, CC_Contacto__c, CC_Tipo__c, CC_ConnId__c,
                                    CC_Cuenta__r.CC_OficinaGestoraId__c, CC_Cuenta__r.AV_OficinaPrincipal__c, CC_ConnId_Consulta__c, CC_Id_Cognitivo__c, CC_Canal_del_Empleado__c,
                                    CC_IdentCliente__c, CC_Status_Autorizacion__c, OS_Cola__c, CC_Case_Consulta__c, HDT_Desborde__c
                                    FROM CC_Llamada__c WHERE Id = :recordId];
        if (!llamada.HDT_Desborde__c && llamada.CC_Fecha_Fin__c != null) {
            throw new AuraHandledException('No se permite crear un caso desde una llamada finalizada');
        } else {
            llamada.CC_Asunto__c = asunto;

            if (llamada.RecordType.DeveloperName.startsWith('OS')) {
                return OS_Llamada.crearCaso(llamada);

            } else if (llamada.RecordType.DeveloperName.startsWith('SACH_')) {
                return SACH_Llamada.crearVincularCaso(llamada);

            } else if (llamada.RecordType.DeveloperName == 'HDT_Empleado') {
                return HDT_Llamada_GC.crearVincularCaso(llamada);

            } else {
                return CC_Llamada_GC.crearVincularCaso(llamada);
            }
        }
    }

    public class Retorno {
        @AuraEnabled
        public Case getCaso {get;set;}
        @AuraEnabled
        public String getMensaje {get;set;}

        public Retorno(Case getCaso, String getMensaje) {
            this.getCaso = getCaso;
            this.getMensaje = getMensaje;
        }
    }

    @AuraEnabled
    public static Retorno devolverMensaje(Id recordId) {
        List<Task> tarea = [SELECT WhatId, Subject FROM Task WHERE CC_Llamada_Id__c = :recordId LIMIT 1];
        if (!tarea.isEmpty()) {
            Case caso = [SELECT CaseNumber FROM Case WHERE Id = :tarea[0].WhatId LIMIT 1];
            String url = String.valueOf(System.Url.getOrgDomainUrl()).remove('Url:[delegate=').remove(']');
            url += '/lightning/r/Case/' + caso.Id + '/view';
            return new Retorno(caso, URL);
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean cuentaAsociada(Id recordId) {
        CC_Llamada__c llamada = [SELECT CC_Cuenta__c, CC_No_Identificado__c FROM CC_Llamada__c WHERE Id = :recordId];
        return llamada.CC_Cuenta__c != null || llamada.CC_No_Identificado__c;
    }

    @AuraEnabled
    public static Boolean getLlamada(Id recordId) {
        return [SELECT CC_Fecha_Fin__c FROM CC_Llamada__c WHERE Id = :recordId].CC_Fecha_Fin__c != null;
    }

    // Método nuevo IOP - Abril 25 - Para asociar caso a masiva desde HDT
    @AuraEnabled(cacheable=true)
    public static List<CC_Agrupador__c > getAgrupadores() {
        return [SELECT Id, Name,CC_Titulo__c
                FROM CC_Agrupador__c 
                WHERE CC_Tematica_Id__r.Name IN (
                    'Aplicaciones Oficina', 
                    'Aplicaciones y Servicios Oficina', 
                    'Cajeros', 
                    'Conectividad', 
                    'Contactos erróneos', 
                    'Estación de Trabajo', 
                    'Gestión de Usuarios', 
                    'Ofimática', 
                    'Outlook', 
                    'Periféricos', 
                    'Smartphones', 
                    'Terminal Financiero', 
                    'Servicio.SIT'
                ) AND CC_Publica__C = true AND CC_Estado__c = 'Activo' AND RecordType.DeveloperName = 'CC_Incidencia'
                ORDER BY Name ASC];
    }

   
    @AuraEnabled
    public static Case crearCasoLlamadaMasiva(Id recordId, String agrupadorId) {
       
        CC_Llamada__c llamada = [SELECT CC_Contacto__r.CC_Matricula__c,RecordType.DeveloperName, CC_Representante__c, CC_Sentimiento__c,CC_Resumen_AI__c, CC_Respuesta_Asistente__c,  CC_Servicio_Genesys__c,
                                    CC_Fecha_Inicio__c, CC_Fecha_Fin__c, CC_Idioma__c, CC_Asunto__c, CC_DNIS__c, CC_ANI__c, CC_No_Identificado__c, CC_Cuenta__c, CC_Contacto__c, CC_Tipo__c, CC_ConnId__c,
                                    CC_Cuenta__r.CC_OficinaGestoraId__c, CC_Cuenta__r.AV_OficinaPrincipal__c, CC_ConnId_Consulta__c, CC_Id_Cognitivo__c, CC_Canal_del_Empleado__c,
                                    CC_IdentCliente__c, CC_Status_Autorizacion__c, OS_Cola__c, CC_Case_Consulta__c, HDT_Desborde__c
                                    FROM CC_Llamada__c WHERE Id = :recordId];
        if (!llamada.HDT_Desborde__c && llamada.CC_Fecha_Fin__c != null) {
            throw new AuraHandledException('No se permite crear un caso desde una llamada finalizada');
        } else {
            return HDT_Llamada_GC.crearVincularCasoMasiva(llamada,agrupadorId);
        }
    }


}