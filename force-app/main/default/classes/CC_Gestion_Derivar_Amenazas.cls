public with sharing class CC_Gestion_Derivar_Amenazas {

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
        // Validación de parámetros obligatorios
        if (recordId == null || String.isBlank(grupoCol) || String.isBlank(nombrePlantilla) || String.isBlank(nameOWA)) {
            throw new AuraHandledException('Parámetros obligatorios no informados.');
        }
        
        Case caso = [
            SELECT Id, ContactId,
                    CC_Referencia_Correo_Saliente__c,
                    AccountId,
                    Account.AV_OficinaPrincipal__c,
                    Account.AV_OficinaPrincipal__r.Parent.Parent.Parent.ParentId
            FROM Case 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        
        if (tipo) {
            // Amenaza a empleados
            emailAmenazasEmpleados(caso, grupoCol, nombrePlantilla, parametrizacionesMensaje, nameOWA);
        } else {
            // Amenaza por suicidio
            emailAmenazasSuicidios(caso, grupoCol, nombrePlantilla, parametrizacionesMensaje, nameOWA);
        }
    }

    @AuraEnabled
    public static void emailAmenazasEmpleados(
        Case caso, 
        String grupoCol, 
        String nombrePlantilla, 
        Map<String, String> parametrizacionesMensaje, 
        String nameOWA
    ) {
        List<String> grupos = new List<String>{grupoCol};
        Map<String, List<String>> destinatariosMap = obtenerDestinatariosGrupoCol(grupos);
        
        if (destinatariosMap == null || destinatariosMap.isEmpty()) {
            throw new AuraHandledException('No se encontraron emails para el grupo colaborador.');
        }
        
        String[] destinatarios = destinatariosMap.get('Para') != null ? destinatariosMap.get('Para') : new List<String>();
        
        if (destinatarios.isEmpty()) {
            throw new AuraHandledException('No se encontraron emails para el grupo colaborador.');
        }
        
        if (parametrizacionesMensaje != null) {
            String url = obtenerUrlLlamadaEntrante(caso.Id);
            parametrizacionesMensaje.put('[URL de la llamada]', url);
        }
        
        enviarEmail(caso, destinatarios, null, null, nombrePlantilla, grupoCol, parametrizacionesMensaje, nameOWA);
    }
    @AuraEnabled
    public static void emailAmenazasSuicidios(
        Case caso, 
        String grupoCol, 
        String nombrePlantilla, 
        Map<String, String> parametrizacionesMensaje, 
        String nameOWA
    ) {
        String[] destinatariosRisk;
        Map<String, List<String>> destinatarios = obtenerDestinatariosGrupoCol(new List<String>{grupoCol});

        List<CC_Riesgo_Reputacional_Derivar__mdt> centros = obtenerCentroRiesgoReputacional(caso);
        destinatariosRisk = obtenerDestinatariosRiesgoReputacional(centros);

        String[] para = destinatariosRisk != null ? destinatariosRisk : 
                       (destinatarios.get('Para') != null ? destinatarios.get('Para') : new List<String>());
        
        String[] cc;
        if(destinatariosRisk != null){
            List<String> ccList = new List<String>();
            if(destinatarios.get('Para') != null) {
                ccList.addAll(destinatarios.get('Para'));
            }
            if(destinatarios.get('CC') != null) {
                ccList.addAll(destinatarios.get('CC'));
            }
            cc = ccList;
        } else {
            cc = destinatarios.get('CC') != null ? destinatarios.get('CC') : null;
        }

        enviarEmail(caso, para, null, cc, nombrePlantilla, grupoCol, parametrizacionesMensaje, nameOWA);
    }

    private static Map<String, List<String>> obtenerDestinatariosGrupoCol(List<String> grupos) {
        try {
            return CC_Gestion_Derivar_Emails_Auto.sendEmailGrupoCol(grupos);
        } catch (Exception e) {
            throw new AuraHandledException('Error obteniendo emails del grupo colaborador: ' + e.getMessage());
        }
    }

    private static List<CC_Riesgo_Reputacional_Derivar__mdt> obtenerCentroRiesgoReputacional(Case caso) {
        if (caso.Account.AV_OficinaPrincipal__c == null) return null;
        
        String numeroOficinaDT = buscarNumeroOficinaDT(caso.Account.AV_OficinaPrincipal__c, 5);
        if (String.isNotBlank(numeroOficinaDT)) {
            return buscarCentroRiesgoReputacional(numeroOficinaDT);
        }
        
        List<Account> cuentaNivel5 = [SELECT Id FROM Account WHERE Id = :caso.Account.AV_OficinaPrincipal__r.Parent.Parent.Parent.ParentId LIMIT 1];
        if (!cuentaNivel5.isEmpty() && cuentaNivel5[0].Id != null) {
            numeroOficinaDT = buscarNumeroOficinaDT(cuentaNivel5[0].Id, 5);
            if (String.isNotBlank(numeroOficinaDT)) {
                return buscarCentroRiesgoReputacional(numeroOficinaDT);
            }
        }
        return null;
    }

    private static String buscarNumeroOficinaDT(Id cuentaId, Integer niveles) {
        List<Account> jerarquia = [
            SELECT Id, CC_Tipo_Centro__c, CC_Numero_Oficina__c,
                   Parent.CC_Tipo_Centro__c, Parent.CC_Numero_Oficina__c,
                   Parent.Parent.CC_Tipo_Centro__c, Parent.Parent.CC_Numero_Oficina__c,
                   Parent.Parent.Parent.CC_Tipo_Centro__c, Parent.Parent.Parent.CC_Numero_Oficina__c,
                   Parent.Parent.Parent.Parent.CC_Tipo_Centro__c, Parent.Parent.Parent.Parent.CC_Numero_Oficina__c,
                   Parent.Parent.Parent.Parent.Parent.CC_Tipo_Centro__c, Parent.Parent.Parent.Parent.Parent.CC_Numero_Oficina__c
            FROM Account 
            WHERE Id = :cuentaId 
            LIMIT 1
        ];
        
        if (jerarquia.isEmpty()) return null;
        
        Account cuenta = jerarquia[0];
        
        if (cuenta.CC_Tipo_Centro__c == 'DT' && String.isNotBlank(cuenta.CC_Numero_Oficina__c)) {
            return cuenta.CC_Numero_Oficina__c;
        }
        else if (cuenta.Parent?.CC_Tipo_Centro__c == 'DT' && String.isNotBlank(cuenta.Parent.CC_Numero_Oficina__c)) {
            return cuenta.Parent.CC_Numero_Oficina__c;
        }
        else if (cuenta.Parent?.Parent?.CC_Tipo_Centro__c == 'DT' && String.isNotBlank(cuenta.Parent.Parent.CC_Numero_Oficina__c)) {
            return cuenta.Parent.Parent.CC_Numero_Oficina__c;
        }
        else if (cuenta.Parent?.Parent?.Parent?.CC_Tipo_Centro__c == 'DT' && String.isNotBlank(cuenta.Parent.Parent.Parent.CC_Numero_Oficina__c)) {
            return cuenta.Parent.Parent.Parent.CC_Numero_Oficina__c;
        }
        else if (cuenta.Parent?.Parent?.Parent?.Parent?.CC_Tipo_Centro__c == 'DT' && String.isNotBlank(cuenta.Parent.Parent.Parent.Parent.CC_Numero_Oficina__c)) {
            return cuenta.Parent.Parent.Parent.Parent.CC_Numero_Oficina__c;
        }
        
        return null;
    }

    private static List<CC_Riesgo_Reputacional_Derivar__mdt> buscarCentroRiesgoReputacional(String numeroOficinaDT) {

        List<CC_Riesgo_Reputacional_Derivar__mdt> centros = [
            SELECT CC_Numero_centro_riesgo_reputacional__c, CC_Numero_direccion_territorial__c
            FROM CC_Riesgo_Reputacional_Derivar__mdt
            WHERE CC_Numero_direccion_territorial__c = :numeroOficinaDT 
            LIMIT 1
        ];
        return (centros.isEmpty() || String.isBlank(centros[0].CC_Numero_centro_riesgo_reputacional__c)) ? null : centros;
    }


    @TestVisible
    private static String[] obtenerDestinatariosRiesgoReputacional(List<CC_Riesgo_Reputacional_Derivar__mdt> centros) {
        if (centros == null || centros.isEmpty() || String.isBlank(centros[0].CC_Numero_centro_riesgo_reputacional__c)) {
            return null;
        }
        
        List<Contact> empleados = [
            SELECT Email
            FROM Contact
            WHERE Account.CC_Numero_Oficina__c = :centros[0].CC_Numero_centro_riesgo_reputacional__c
            AND Email != null AND Email != ''
        ];

        if (empleados.isEmpty()) {
            return null;
        }
        
        Set<String> emailsUnicos = new Set<String>();
        for (Contact empleado : empleados) {
            if (String.isNotBlank(empleado.Email)) {
                emailsUnicos.add(empleado.Email.toLowerCase().trim());
            }
        }
        
        List<String> emailsEmpleados = new List<String>(emailsUnicos);
        return emailsEmpleados;
    }

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
            caso, 
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