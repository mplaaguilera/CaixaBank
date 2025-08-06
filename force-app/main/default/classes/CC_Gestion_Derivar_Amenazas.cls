public with sharing class CC_Gestion_Derivar_Amenazas {

    /**
     * Envía un email de amenazas, diferenciando entre empleados y suicidios.
     */
    @AuraEnabled
    public static void operativasEmail(
        Id recordId, 
        Boolean tipo, 
        String grupoCol, 
        String nombrePlantilla, 
        Map<String, String> parametrizacionesMensaje, 
        String ambito, 
        String nameOWA
    ) {
        if (recordId == null || String.isBlank(grupoCol) || String.isBlank(nombrePlantilla) || String.isBlank(nameOWA)) {
            throw new AuraHandledException('Parámetros obligatorios no informados.');
        }
        Case caso = [
            SELECT Id, ContactId, Account.CC_Direccion_Territorial__c, 
                   Account.CC_Direccion_Territorial__r.CC_Numero_Oficina__c, 
                   CC_Referencia_Correo_Saliente__c, AccountId 
            FROM Case 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        if (tipo) {
            emailAmenazasEmpleados(caso, grupoCol, nombrePlantilla, parametrizacionesMensaje, nameOWA);
        } else {
            emailAmenazasSuicidios(caso, grupoCol, nombrePlantilla, parametrizacionesMensaje, nameOWA);
        }
    }

    /**
     * Envía un email de amenazas a empleados.
     */
    @AuraEnabled
    public static void emailAmenazasEmpleados(
        Case caso, 
        String grupoCol, 
        String nombrePlantilla, 
        Map<String, String> parametrizacionesMensaje, 
        String nameOWA
    ) {
        List<String> grupos = new List<String>{grupoCol};
        String[] destinatarios = obtenerDestinatariosGrupoCol(grupos);
        if (destinatarios == null || destinatarios.isEmpty()) {
            throw new AuraHandledException('No se encontraron emails para el grupo colaborador.');
        }
        // Añadir URL de llamada si existe
        if (parametrizacionesMensaje != null) {
            String url = obtenerUrlLlamadaEntrante(caso.Id);
            parametrizacionesMensaje.put('[URL de la llamada]', url);
        }
        enviarEmail(caso, destinatarios, null, null, nombrePlantilla, grupoCol, parametrizacionesMensaje, nameOWA);
    }

    /**
     * Envía un email de amenazas por suicidio.
     */
    @AuraEnabled
    public static void emailAmenazasSuicidios(
        Case caso, 
        String grupoCol, 
        String nombrePlantilla, 
        Map<String, String> parametrizacionesMensaje, 
        String nameOWA
    ) {
        String[] destinatariosRisk;
        String[] destinatarios = obtenerDestinatariosGrupoCol(new List<String>{grupoCol});
        String numOficina = (caso.Account != null && caso.Account.CC_Direccion_Territorial__r != null)
            ? caso.Account.CC_Direccion_Territorial__r.CC_Numero_Oficina__c
            : null;

        destinatariosRisk = obtenerDestinatariosRiesgoReputacional(numOficina);
       


        enviarEmail(caso, destinatarios, null, destinatariosRisk, nombrePlantilla, grupoCol, parametrizacionesMensaje, nameOWA);
    }

    /**
     * Obtiene los destinatarios de un grupo colaborador.
     */
    private static String[] obtenerDestinatariosGrupoCol(List<String> grupos) {
        try {
            return CC_Gestion_Derivar_Emails_Auto.sendEmailGrupoCol(grupos);
        } catch (Exception e) {
            throw new AuraHandledException('Error obteniendo emails del grupo colaborador: ' + e.getMessage());
        }
    }

    /**
     * Obtiene los destinatarios de riesgo reputacional.
     */
    @TestVisible
    private static String[] obtenerDestinatariosRiesgoReputacional(String denominacionTerritorial) {
        if (String.isBlank(denominacionTerritorial)) {
            denominacionTerritorial = CC_Settings__c.getValues('CC_Centro_Riesgo_Reputacional_Default').CC_Configuracion_1__c != null ? CC_Settings__c.getValues('CC_Centro_Riesgo_Reputacional_Default').CC_Configuracion_1__c : null;
        }
        List<CC_Riesgo_Reputacional_Derivar__mdt> centros = [
            SELECT CC_Numero_centro_riesgo_reputacional__c
            FROM CC_Riesgo_Reputacional_Derivar__mdt
            WHERE CC_Numero_direccion_territorial__c = :denominacionTerritorial
            LIMIT 1
        ];

        if (centros.isEmpty() || String.isBlank(centros[0].CC_Numero_centro_riesgo_reputacional__c) || String.isBlank(denominacionTerritorial)) {
            throw new AuraHandledException('Centro de Riesgo Reputacional no encontrado para la territorial: ' + denominacionTerritorial);
        }
        
        List<Contact> empleados = [
            SELECT Email
            FROM Contact
            WHERE Account.CC_Numero_Oficina__c = :centros[0].CC_Numero_centro_riesgo_reputacional__c
            AND Email != null AND Email != ''
        ];

        if (empleados.isEmpty()) {
            throw new AuraHandledException('No se encontraron empleados con email en el centro de Riesgo Reputacional ' + centros[0].CC_Numero_centro_riesgo_reputacional__c);
        }
        List<String> emailsEmpleados = new List<String>();
        for (Contact empleado : empleados) {
            emailsEmpleados.add(empleado.Email);
        }
        return emailsEmpleados;
    }

    /**
     * Obtiene la URL de la llamada entrante asociada al caso.
     */
    private static String obtenerUrlLlamadaEntrante(Id casoId) {
        List<Task> tareas = [
            SELECT CC_Llamada_Id__r.KIN_Genesys_Cloud_URL_Grabacion__c 
            FROM Task 
            WHERE WhatId = :casoId AND Type = 'Llamada entrante' 
            LIMIT 1
        ];
        if (!tareas.isEmpty() && tareas[0].CC_Llamada_Id__r.KIN_Genesys_Cloud_URL_Grabacion__c != null) {
            return tareas[0].CC_Llamada_Id__r.KIN_Genesys_Cloud_URL_Grabacion__c;
        }
        return 'Llamada no encontrada';
    }

    /**
     * Llama a la lógica de envío de email.
     */
    private static void enviarEmail(
        Case caso, 
        String[] toAddress,
        String[] bccAddress,
        String[] ccAddress,
        String nombrePlantilla, 
        String grupoCol, 
        Map<String, String> parametrizacionesMensaje, 
        String nameOWA
    ) {
        CC_Gestion_Derivar_Emails_Auto.createEmail(
            caso, // caso
            toAddress, //toAddress
            bccAddress, //bccAddress
            ccAddress, //ccAddress
            nombrePlantilla, //nombrePlantilla
            grupoCol, //grupoColaborador
            parametrizacionesMensaje, //parametrizacionesMensaje
            nameOWA //nameOWA
        );
    }
}