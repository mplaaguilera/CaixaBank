public with sharing class CC_Operativa_Oficina_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDatos(Id recordId, Boolean otpDerivar) {
        return CC_Gestion_Derivar_Inicializar.getDatos(recordId, otpDerivar);
    }

    @AuraEnabled
    public static Boolean updateCasoOperativaDerivar(Id recordId){
        Case caso = [SELECT Id FROM Case WHERE Id = :recordId AND SAC_EnvioParcial__c = false] ?? null;
        if (caso != null) {
            caso.SAC_EnvioParcial__c = true;
            update caso;
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static void realizarTraslado3N(String recordId) {
        Id recordTypeIdGrupo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel');
        List <CC_MCC_Grupo_Colaborador__c> grupoColaborador = [SELECT CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.RecordtypeId,
        CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.CC_Queue_Traslado__c
        FROM CC_MCC_Grupo_Colaborador__c
        WHERE CC_Grupo_Colaborador__r.CC_Queue_Traslado__c = 'Cola_3N_CSBD'
        AND CC_Grupo_Colaborador__r.RecordtypeId = :recordTypeIdGrupo
        ORDER BY Name ASC LIMIT 1];
        try{
            if(!grupoColaborador.isEmpty()){
                CC_EmailSendController.cambiarPropietario(grupoColaborador[0].CC_Grupo_Colaborador__r.Name, grupoColaborador[0].CC_Grupo_Colaborador__r.CC_Queue_Traslado__c, recordId, '', grupoColaborador[0].CC_Grupo_Colaborador__r.Id);
            } else {
                CC_CustomException.throwCustomException('El grupo colaborador no está correctamente informado');
            }
        } catch(Exception e){
            throw new AuraHandledException('Ha ocurrido un error al trasladar el caso a Tercer Nivel: ' + e.getMessage());
        }
    }

    /************* Gestion de Oportunidades *********/
    @AuraEnabled
    public static Map<String, Object> crearOportunidad(String recordId) {
        return CC_Gestion_Derivar_CSBD.crearOportunidad(recordId);
    }

    @AuraEnabled
    public static Boolean comprobarOportunidadExistente(String recordId) {
        return CC_Gestion_Derivar_CSBD.comprobarOportunidadExistente(recordId);
    }

      //metodo que se llama desde CSBD
    public static void devolverCasoCSBD(Map<String, Object> respuesta) {
        CC_Gestion_Derivar_CSBD.devolverCasoCSBD(respuesta);
    }
   /************* Gestion de Oportunidades *********/


    @AuraEnabled
    public static Map<String, Object> crearTarea(String recordId, String asunto, String fechaActividad, String comentarios, List<String> archivos, Id oficinaDestino, Boolean enviarTareaOficinaCliente, Boolean crearTareaCitaGestor, Contact gestorSeleccionadoBuscador, Boolean otpDerivar) {

       Map<String, Object> retorno = new Map<String, Object>();
       Map<String, Object> datos = new Map<String, Object>();
       datos.put('recordId', recordId);
       datos.put('asunto', asunto);
       datos.put('fechaActividad', fechaActividad);
       datos.put('comentarios', comentarios);
       datos.put('archivos', archivos);
       datos.put('oficinaDestino', oficinaDestino);
       datos.put('enviarTareaOficinaCliente', enviarTareaOficinaCliente);
       datos.put('crearTareaCitaGestor', crearTareaCitaGestor);
       datos.put('gestorSeleccionadoBuscador', gestorSeleccionadoBuscador);
       datos.put('otpDerivar', otpDerivar);

       CC_Gestion_Derivar_Tarea gestionDerivarTarea = new CC_Gestion_Derivar_Tarea(datos);
       retorno = gestionDerivarTarea.crearTarea();

       return retorno;

      // return CC_Crear_Tarea_OLD.crearTarea(recordId, asunto, fechaActividad, comentarios, archivos, oficinaDestino, enviarTareaOficinaCliente, crearTareaCitaGestor, gestorSeleccionadoBuscador, otpDerivar);
    }

    @AuraEnabled
    public static Map<Object, Object> esClienteDigital(String recordId, String tipoActividad) {
        try {
            return CC_Int_ObtInfCarterizaCliente.esClienteDigital(recordId, tipoActividad);
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getUrlNumeroOficina(Id recordId) {
        String hostnameEntero = String.valueOf(System.Url.getOrgDomainUrl());
        String hostnameSubstring1 = hostnameEntero.remove('Url:[delegate=');
        String hostnameLimpio = hostnameSubstring1.remove(']');
        Account cuenta = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :recordId LIMIT 1];
        String url = hostnameLimpio + '/lightning/r/Account/' + cuenta.Id + '/view';
        return new Map<String, String>{'numeroOficina' => cuenta.CC_Numero_Oficina__c, 'url' => url};
    }

    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerGestoresBackup(String recordId, String employeeId, String gestorElegidoId, String eventType) {
        try {
            return CC_Int_AvailabilitiesGestor.obtenerGestoresBackup(recordId, employeeId, gestorElegidoId, eventType);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerFechasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType) {
        try {
            return CC_Int_AvailabilitiesGestor.obtenerFechasDisponiblidadGestor(recordId, employeeId, gestorElegidoId, eventType);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerHorasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType, String fechaElegida) {
        try {
            return CC_Int_AvailabilitiesGestor.obtenerHorasDisponiblidadGestor(recordId, employeeId, gestorElegidoId, eventType, fechaElegida);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> altaCitaGestor(String recordId, String empleadoEx, String nombreGestor, String centroEx, String asunto, String fecContacto, String horaIni, String medio) {
        try {
            return CC_Int_AltaCitaGestor.altaCitaGestor(recordId, empleadoEx, nombreGestor, centroEx, asunto, fecContacto, horaIni, medio);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> buscarOficinas(String cadenaBusqueda) {
        if (Schema.SObjectType.Account.isAccessible()) {
            return [FIND :cadenaBusqueda + '*' IN ALL FIELDS RETURNING Account(Name, BillingStreet, BillingCity WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 7)][0];
        } else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> buscarEmpleados(String cadenaBusqueda) {
        if (Schema.SObjectType.Account.isAccessible()) {
            return [FIND :cadenaBusqueda + '*' IN ALL FIELDS RETURNING Contact(Name, CC_Matricula__c WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Inactivo__c = false LIMIT 7)][0];
        } else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> buscarGestoresGlobal(String cadenaBusqueda) {
        if (Schema.SObjectType.Contact.isAccessible()) {
            return [FIND :cadenaBusqueda + '*' IN ALL FIELDS RETURNING Contact(Name, Account.BillingStreet, Account.BillingCity, CC_Nombre_Oficina__c, CC_Matricula__c, CC_Numero_Oficina__c WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Num_Empleado_Generico__c NOT IN('99999', '98999') AND CC_Inactivo__c = false LIMIT 7)][0];
        } else {
            throw new AuraHandledException('Permisos insuficientes');
        }
    }

    @AuraEnabled
    public static Boolean recuperarCampoDerivar(Id recordId) {
        Boolean campoDerivar = [SELECT CC_Derivar__c FROM Case WHERE Id = :recordId LIMIT 1].CC_Derivar__c;
        return campoDerivar;
    }

    @AuraEnabled
    public static void dniTestamentaria(String dni, String recordId){
        Case caso = [SELECT Id, CC_DNI_Difunto__c FROM Case WHERE Id = :recordId LIMIT 1];
        caso.CC_DNI_Difunto__c = dni;
        update caso;
    }

    @AuraEnabled
    public static Map<String, Object> recuperarDatosEntradaFlow(String recordId){
        try {
            Case caso = [SELECT Id, accountId, contactId, CC_Oficina__c,CC_Oficina_afectada__c, AssetId FROM Case WHERE Id = :recordId LIMIT 1];
            Map<String, Object> datos = new Map<String, Object>();
            if(caso != null){
                datos.put('recordId', caso.Id);
                datos.put('currentCase', caso);
            }
            return datos;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void loguearTrazasAutenticacionSAU(List<String> reqAutenticacionSAU,List<String> resAutenticacionSAU,String recordId,String nombreTraza) {
        try {
            List<CC_TrazaInt__c> lstRegInt = new List<CC_TrazaInt__c>();

            for (Integer i = 0; i < reqAutenticacionSAU.size(); i++) {
                CC_TrazaInt__c traza = new CC_TrazaInt__c();
                traza.Name = 'CC_Autenticacion_SAU';
                traza.CC_FechaInicio__c = CBK_UtilsDate.nowDT();
                traza.CC_FechaFin__c = CBK_UtilsDate.nowDT();
                traza.CC_MensajeEntrada__c = reqAutenticacionSAU[i]?.left(32760);
                traza.CC_MensajeSalida__c = resAutenticacionSAU[i]?.left(32760);
                traza.CC_Identificador__c = nombreTraza;
                traza.CC_IdOrigen__c = recordId;
                traza.CC_FinOK__c = true;
                lstRegInt.add(traza);
            }

            if (!lstRegInt.isEmpty()) {
                insert lstRegInt;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /************* Gestion de Documentacion *********/
    @AuraEnabled
    public static void crearNuevoCasoDocumentacion(String recordId) {
        CC_Gestion_Derivar_Documentacion.crearNuevoCasoDocumentacion(recordId);
    }
    /************* Gestion de Documentacion *********/

    /************* Gestion de Fraude *********/
    @AuraEnabled
    public static void crearNuevoCasoFraude(String recordId) {
        CC_Gestion_Derivar_Fraude.crearCasoFraude(recordId);
    }
    /************* Gestion de Documentacion *********/


    /************* Gestion del Platform Evento de intercambio entre aplicaciones *********/
    public static void gestionarDevolucionAContact(List<CC_DevolverCaso__e> reabrirEvents) {
        List<CC_DevolverCaso__e> reabrirEventsCsbd = new List<CC_DevolverCaso__e>();
        List<CC_DevolverCaso__e> reabrirFraude = new List<CC_DevolverCaso__e>();
        for(CC_DevolverCaso__e reabrirEvent : reabrirEvents){
            String origen = String.isNotBlank(reabrirEvent.CC_Origen__c) ? reabrirEvent.CC_Origen__c : 'CSBD';
            if(origen == 'CSBD'){
                reabrirEventsCsbd.add(reabrirEvent);
            } else if(origen == 'Fraude'){
                reabrirFraude.add(reabrirEvent);
            }
        }

        if(!reabrirEventsCsbd.isEmpty()){
            CC_Gestion_Derivar_CSBD.reabrirCasoCSBD(reabrirEventsCsbd);
        }

        if(!reabrirFraude.isEmpty()){
            CC_Gestion_Derivar_Fraude.reabrirCasoFraude(reabrirFraude);
        }

    }
    /************* Gestion del Platform Evento de intercambio entre aplicaciones  *********/

    /************* Derivar al SAC *********/
    @AuraEnabled
    public static void derivarSAC (Case casoContactCenter, String motivo) {
        CC_Revincular_Caso_Controller.derivarCasoAlSAC(casoContactCenter, motivo);
    }
    /************* Derivar al SAC *********/

    /************* Devolver al SAC *********/
    @AuraEnabled
    public static void devolverSAC (String motivo, Case casoContactCenter) {
        CC_Revincular_Caso_Controller.devolverCasoAlSAC(motivo, casoContactCenter);
    }
    /************* Devolver al SAC *********/
}