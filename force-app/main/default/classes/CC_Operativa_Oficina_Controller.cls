public with sharing class CC_Operativa_Oficina_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDatos(Id recordId, Boolean otpDerivar) {
        return CC_Gestion_Derivar_Inicializar.getDatos(recordId, otpDerivar);
    }

    @AuraEnabled
    public static void updateCasoOperativaDerivar(Id recordId){
        List<Case> caso = [SELECT Id, SAC_EnvioParcial__c FROM Case WHERE Id = :recordId LIMIT 1];
        try {
            if(!caso.isEmpty()){
                caso[0].SAC_EnvioParcial__c = true;
                update caso;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
    
    /************* Gestion de Mecanismo de firma *********/

    @AuraEnabled
    public static void crearCasoMecanismoFirma(String recordId, Boolean clienteExtranjero){
        //Obtener el custom setting con los circuitos
        CC_Settings__c configuracion = CC_Settings__c.getValues('CC_MecanismoFirmaCircuitos');
        String circuitoExtranjero = configuracion.CC_Configuracion_1__c;
        String circuitoCodigoFirma = configuracion.CC_Configuracion_2__c;

        Case casoOrigen = [SELECT CC_Idioma__c, CC_Detalles_Consulta__c, CC_Canal_Procedencia__c,CC_Tipo_Contacto__c, OwnerId, AccountId, Origin, CC_Canal_Operativo__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_MCC_Causa__c, CC_MCC_Solucion__c,  ContactId 
                           FROM Case WHERE Id = :recordId LIMIT 1];
        //casoOrigen.Status = 'Cerrado';
        //casoOrigen.CC_CierreAutomaticoCSBD__c = true;
        
        //update casoOrigen;
        
        List<Group> cola =[SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Videollamada_Enrollment_Caixabank_Sign' LIMIT 1];
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        
        CBK_Case_Extension__c extension = new CBK_Case_Extension__c();
        extension.CC_MecanismoFirma__c = true;
        insert extension;

        Case casoNuevo= new Case();
        casoNuevo.RecordTypeId = recordTypeCaso;
        casoNuevo.CC_Canal_Operativo__c = casoOrigen.CC_Canal_Operativo__c;
        casoNuevo.CC_MCC_Tematica__c = casoOrigen.CC_MCC_Tematica__c;
        casoNuevo.CC_MCC_ProdServ__c = casoOrigen.CC_MCC_ProdServ__c;
        casoNuevo.CC_MCC_Motivo__c =casoOrigen.CC_MCC_Motivo__c;
        casoNuevo.CC_MCC_Causa__c = casoOrigen.CC_MCC_Causa__c;
        casoNuevo.CC_MCC_Solucion__c = casoOrigen.CC_MCC_Solucion__c;
        casoNuevo.CC_Canal_Procedencia__c = casoOrigen.CC_Canal_Procedencia__c;
        casoNuevo.CC_Tipo_Contacto__c = casoOrigen.CC_Tipo_Contacto__c;
        casoNuevo.CC_Canal_Operativo__c = casoOrigen.CC_Canal_Operativo__c;
        casoNuevo.CC_Detalles_Consulta__c = casoOrigen.CC_Detalles_Consulta__c;
        casoNuevo.Origin = casoOrigen.Origin;
        casoNuevo.CC_Idioma__c= casoOrigen.CC_Idioma__c;
        casoNuevo.AccountId = casoOrigen.AccountId;
        casoNuevo.ContactId = casoOrigen.ContactId;
        //casoNuevo.OwnerId =cola[0].Id;
        casoNuevo.OwnerId =casoOrigen.OwnerId;
        casoNuevo.CBK_Case_Extension_Id__c = extension.Id;
        casoNuevo.CC_CasoRelacionado__c = casoOrigen.Id;

        if(clienteExtranjero){
            casoNuevo.Subject = circuitoExtranjero;
        } else{
            casoNuevo.Subject = circuitoCodigoFirma;
        }
        insert casoNuevo;

        //Asociamos el caso nuevo al caso origen
        casoOrigen.CC_CasoRelacionado__c = casoNuevo.Id;
        update casoOrigen;

        System.debug('Caso nuevo: ' + casoNuevo.Id);
        System.debug('Extension: ' + extension.Id);
        System.debug('Cola ID: ' + cola[0].Id);
        System.debug('Cola nombre: ' + cola[0].Name);
        System.debug('Record '+  casoNuevo.RecordTypeId);

        //Crear la actividad en el caso
        CC_Activity.crearActividadMecanismoFirma(casoNuevo, clienteExtranjero);
    }
    
    @AuraEnabled
    public static Boolean elegirCircuitoMecanismoFirma(String recordId) {
        Case caso = [SELECT Id, Subject FROM Case WHERE Id = :recordId LIMIT 1];
        CC_Settings__c configuracion = CC_Settings__c.getValues('CC_MecanismoFirmaCircuitos');
        String circuitoExtranjero = configuracion.CC_Configuracion_1__c;
        String circuitoCodigoFirma = configuracion.CC_Configuracion_2__c;
        Boolean retorno;

        if (caso.Subject ==circuitoExtranjero) {
            //Se va por circuito extranjero
            retorno = true;
        }else if(caso.Subject ==circuitoCodigoFirma) {
            //Se va por circuito codigo firma
            retorno = false;
        }

        System.debug('Circuito: ' + caso.Subject);
        System.debug('Retorno: ' + retorno);
        System.debug('Circuito extranjero: ' + circuitoExtranjero);
        System.debug('Circuito codigo firma: ' + circuitoCodigoFirma);

        return retorno;
    }

    @AuraEnabled
    public static Boolean comprobarCasoCreadoMecanismoFirma(String recordId) {
        Case caso = [SELECT Id, Subject FROM Case WHERE Id = :recordId LIMIT 1];
        Boolean retorno;
        if(caso.CC_CasoRelacionado__c != null){
            //El caso ya tiene un caso relacionado
            retorno = true;
        } else {
            //El caso no tiene un caso relacionado
            retorno = false;
        }
        return retorno;
    }
    /************* Gestion de Mecanismo de firma *********/

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


}