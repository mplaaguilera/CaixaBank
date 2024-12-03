public with sharing class SACH_Case_Operativa {

    //Comprobar si la validacion es necesario tras obtener el MCC final
    @AuraEnabled
    public static List<String> validarCamposCaso(Id recordId) {
        List<String> camposNoValidos = new List<String>();
        Case caso = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
                        Origin, CC_Canal_Procedencia__c, CC_Idioma__c, ContactId, CC_No_Identificado__c
                        FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED];
        if (caso.CC_MCC_Tematica__c == null) { camposNoValidos.add('Temática'); }
        if (caso.CC_MCC_ProdServ__c == null) { camposNoValidos.add('Producto/Servicio'); }
        if (caso.CC_MCC_Motivo__c == null) { camposNoValidos.add('Motivo'); }
        if (caso.Origin == null) { camposNoValidos.add('Canal de entrada'); }
        if (caso.CC_Canal_Procedencia__c == null) { camposNoValidos.add('Canal de procedencia'); }
        if (caso.CC_Idioma__c == null) {  camposNoValidos.add('Idioma'); }
        if (caso.ContactId == null && caso.CC_No_Identificado__c == false) {  camposNoValidos.add('Cuenta y contacto'); }

        //Si las claves foráneas a MCCs no son nulas, se mira además que los MCCs a los que apuntan estén activos
        if (caso.CC_MCC_Tematica__c != null && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_Motivo__c != null) {
            //Se preparan los Ids en una lista para poder la comprobación en una sola consulta
            List<Id> idsMCC = new List<Id>{caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, caso.CC_MCC_Motivo__c};
            for (CC_MCC__c mcc : [SELECT Name, CC_Activo__c FROM CC_MCC__c WHERE Id IN :idsMCC WITH SECURITY_ENFORCED]) {
                if (!mcc.CC_Activo__c) {
                    camposNoValidos.add('Clasificación ' + mcc.Name + ' inactiva');
                    break;
                }
            }
        }
        return camposNoValidos;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGruposColaboradores(String cadenaBusqueda) {
        return [SELECT Name FROM CC_Grupo_Colaborador__c WHERE
                Name LIKE :('%' + cadenaBusqueda + '%')
                AND ((OS_Negocio__c = 'CC' AND RecordType.DeveloperName = 'CC_CentroCaixaBank') 
                    OR (OS_Negocio__c = 'SACH' AND RecordType.DeveloperName = 'CC_Grupo_Colaborador')) 
                WITH SECURITY_ENFORCED LIMIT 20];
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getPlantillasSach() {
        //Se buscan todas las plantillas
        return [SELECT Name FROM EmailTemplate WHERE Folder.DeveloperName LIKE 'SACH_%' WITH SECURITY_ENFORCED LIMIT 30];
    }

    @AuraEnabled
    public static void prepararCaso(Id idCaso, Id idPlantilla, Boolean informarReferenciaCorreo, String operativa) {
        Case caso = [SELECT CC_Canal_Procedencia__c, CC_Buzon_Salida__c FROM Case WHERE Id = :idCaso WITH SECURITY_ENFORCED];
        caso.CC_MCC_Plantilla__c = idPlantilla;
        caso.CC_Ultima_Operativa_Correo__c = operativa;
        if (caso.CC_Buzon_Salida__c == null) {
            List<SACH_Correo__mdt> configBuzones = [SELECT SACH_Correo__c FROM SACH_Correo__mdt WHERE SACH_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c WITH SECURITY_ENFORCED LIMIT 1];
            if (configBuzones.isEmpty()) {
                throw new AuraHandledException('Problema recuperando los datos del buzón de correo');
            } else {
                caso.CC_Buzon_Salida__c = configBuzones[0].SACH_Correo__c;
            }
        }
        if (informarReferenciaCorreo) {
            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente();
        }
        if (!Schema.sObjectType.Case.fields.CC_Buzon_Salida__c.isUpdateable() || !Schema.sObjectType.Case.fields.CC_Referencia_Correo_Saliente__c.isUpdateable()) {
            return;
        }
        Database.update(caso);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> destinatariosColaborador(Id idGrupoColaborador) {
        Map<String, String> idMapContacto = new Map<String, String>();
        for (CC_Grupo_Colaborador_Contact__c contactoGrupoColab : [SELECT CC_Para_CC__c, CC_Email__c FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :idGrupoColaborador AND (CC_Contacto__c != null OR CC_Usuario__c != null)
                                                                    WITH SECURITY_ENFORCED]) {
            idMapContacto.put(contactoGrupoColab.CC_Email__c, contactoGrupoColab.CC_Para_CC__c);
        }
        return idMapContacto;
    }

    @AuraEnabled
    public static Event crearEvento(String recordId, Date fecha, String descripcion) {
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('WhatId', recordId);
        campos.put('Type', 'Alerta programada');
        campos.put('Subject','Alerta programada');
        campos.put('Description', descripcion);
        campos.put('StartDateTime', fecha);
        campos.put('EndDateTime', fecha);
        return SACH_Activity.crearEvento('SACH_Event', campos);
    }
    
    @AuraEnabled
    public static void borrarEvento(Id recordId) {
        List<Event> eventos = [SELECT Id FROM Event WHERE WhatId = :recordId AND RecordType.DeveloperName = 'SACH_Event' AND Type = 'Alerta programada'
                                WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        if (!eventos.isEmpty()) {
            SACH_Activity.eliminarTareas(eventos);
        }
    }

    /**
     * @description método para fusionar los correos, actividades, adjuntos de los casos.
     * @param masterCaseId
     * @param idCasoSelected
     * @return String 
     */
    @AuraEnabled
    public static String mergeCase(String masterCaseId, String idCasoSelected) {
        return SACH_Case_Merge.fusionarCaso(masterCaseId, idCasoSelected);
    }

    @AuraEnabled
    public static String vincularLlamada(Id recordId) {
        List<CC_Llamada__c> llamadas = [SELECT Name, CC_Tipo__c FROM CC_Llamada__c WHERE RecordType.DeveloperName = 'SACH_Cliente'
                                        AND OwnerId = :UserInfo.getUserId() AND CC_Fecha_Fin__c = NULL LIMIT 2];
        if (llamadas.size() != 1) {
            throw new AuraHandledException('No se ha encontrado ninguna llamada en curso que vincular al caso');
        } else {
            if ([SELECT Count() FROM Task WHERE WhatId = :recordId AND CC_Llamada_Id__c = :llamadas[0].Id] > 0) {
                throw new AuraHandledException('El caso ya se encuentra vinculado con la llamada en curso');
            } else {
                //Se vincula la llamada
                String tipo = llamadas[0].CC_Tipo__c == 'Entrante' ? 'Llamada entrante' : 'Llamada saliente';
                Map<String, Object> camposTarea = new Map<String, Object>();
                camposTarea.put('WhatId', recordId);
                camposTarea.put('Type', tipo);
                camposTarea.put('Subject', tipo);
                camposTarea.put('ActivityDate', System.today());
                camposTarea.put('Status', 'Open');
                camposTarea.put('CC_Llamada_Id__c', llamadas[0].Id);
                camposTarea.put('CC_Fecha_Inicio__c', System.now());
                SACH_Activity.crearlstTareas(new List<Task>{SACH_Activity.crearTarea('SACH_Task', camposTarea)});

                SACH_Case.reapertura(recordId, 'Reapertura por vinculación de llamada');

                return llamadas[0].Name;
            }
        }
    }
}