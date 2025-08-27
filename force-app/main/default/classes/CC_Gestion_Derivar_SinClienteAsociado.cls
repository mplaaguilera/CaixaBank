public with sharing class CC_Gestion_Derivar_SinClienteAsociado {

    @AuraEnabled
    public static Map<String, Object> identificarCliente(String sTipoBusqueda, String sBusqueda) {
        return CC_IdentCliente_Future.IdentificarPersALFSync(sTipoBusqueda, sBusqueda);
    }

    @AuraEnabled
    public static void actualizarCasoMGT(Id recordId, Id cuentaId) {
        try {
            Case caso = new Case(Id = recordId);
            caso.AccountId = cuentaId;
            // caso.CC_No_Identificado__c = false;
            update caso;
        } catch (Exception e) {
            throw new AuraHandledException('Error al actualizar el caso: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> crearTareaDerivacionesSinCliente(String recordId, String asunto, String fechaActividad, String comentarios, String cuentaFicticia, Boolean crearTareaCitaGestor, List<String> archivos, Id oficinaDestino, Boolean enviarTareaOficinaCliente, Contact gestorSeleccionadoBuscador, Boolean otpDerivar) {

       Map<String, Object> retorno = new Map<String, Object>();
       Map<String, Object> datos = new Map<String, Object>();
       datos.put('recordId', recordId);
       datos.put('asunto', asunto);
       datos.put('fechaActividad', fechaActividad);
       datos.put('comentarios', comentarios);
       datos.put('crearTareaCitaGestor', crearTareaCitaGestor);
       datos.put('archivos', archivos);
       datos.put('oficinaDestino', oficinaDestino);
       datos.put('enviarTareaOficinaCliente', enviarTareaOficinaCliente);
       datos.put('gestorSeleccionadoBuscador', gestorSeleccionadoBuscador);
       datos.put('otpDerivar', otpDerivar);
       datos.put('cuentaFicticia', cuentaFicticia);

       CC_Gestion_Derivar_Tarea gestionDerivarTarea = new CC_Gestion_Derivar_Tarea(datos);
       retorno = gestionDerivarTarea.crearTarea();

       return retorno;
    }

    @AuraEnabled
    public static String recuperarMensaje(Integer numero) {
        String mensaje = '';
        String nombreListaValores = 'Derivaciones sin cliente asociado ' + numero;
        List<CC_Lista_Valores__c> listaValores = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = :nombreListaValores LIMIT 1];
        if(!listaValores.isEmpty()){
            mensaje = listaValores[0].CC_Mensajes_Mostrar__c;
        }
        return mensaje;
    }

    @AuraEnabled
    public static Boolean buscarTareaSinCliente(Id recordId) {
        try {
            Case caso = [SELECT Id FROM Case WHERE Id = :recordId LIMIT 1];
            if (caso == null) {
                throw new AuraHandledException('No se encontró el caso con el Id proporcionado');
            }
            List<Task> tareas = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Subject = 'Derivaciones sin cliente asociado' LIMIT 1];
            return !tareas.isEmpty();
        } catch (QueryException e) {
            throw new AuraHandledException('Error al consultar el caso o las tareas');
        }
    }

    @AuraEnabled
    public static boolean casoNoSeIdentifica(Id recordId) {
        try {
            Case caso = [SELECT Id, CC_No_Identificado__c FROM Case WHERE Id = :recordId LIMIT 1];
            if (caso == null) {
                throw new AuraHandledException('No se encontró el caso con el Id proporcionado');
            }
            return caso.CC_No_Identificado__c;
        } catch (QueryException e) {
            throw new AuraHandledException('Error al consultar el caso');
        }
    }
}