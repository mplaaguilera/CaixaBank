public with sharing class HDT_EmailSendController {

    @AuraEnabled
    public static Case datosCaso(Id recordId) {
        return [SELECT CC_Detalles_Consulta__c, RecordTypeId, RecordType.DeveloperName, ContactId, AccountId, Account.Recordtype.DeveloperName, Account.CC_Marca_senior__c, CC_Tipo_Cliente__c, CC_Canal_Procedencia__c, Contact.Phone, CC_Tipo_Cliente_Formula__c,
        Origin, Status, Subject, createddate, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, CC_Grupo_3N__c, CC_No_Identificado__c, CC_En_Tercer_Nivel__c, CC_Canal_Operativo__c, CC_MCC_Causa__c, CC_MCC_Solucion__c, parentId, parent.RecordType.DeveloperName FROM Case WHERE Id = :recordId];
    }

    public class DatosCasoGDPRWrapper {
        @AuraEnabled
        public Boolean productoGDPR{get;set;}
        @AuraEnabled
        public String tipoContacto{get;set;}
        @AuraEnabled
        public String numPerso{get;set;}
        @AuraEnabled
        public String numeroDocumento{get;set;}
        @AuraEnabled
        public Decimal edad{get;set;}
        @AuraEnabled
        public Boolean confidencial{get;set;}
        @AuraEnabled
        public String tipoPersona{get;set;}
        @AuraEnabled
        public Boolean fallecido{get;set;}
        @AuraEnabled
        public Boolean incapacitado{get;set;}
    }

    @AuraEnabled
    public static DatosCasoGDPRWrapper obtenerDatosCasoGDPR(String recordId) {
        List<Case> caso = [SELECT CC_MCC_ProdServ__r.CC_GDPR__c, CC_Tipo_Contacto__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c, Contact.CC_Edad__c, Account.CC_Confidencial__c, Contact.CC_FechaDefuncion__c, Account.CC_TipoPersona__c, Account.CC_IncapacitadoLegal__c FROM Case WHERE Id =:recordId LIMIT 1];
        DatosCasoGDPRWrapper datos = new DatosCasoGDPRWrapper();
        datos.productoGDPR = caso[0].CC_MCC_ProdServ__r.CC_GDPR__c == null ? false : caso[0].CC_MCC_ProdServ__r.CC_GDPR__c;
        datos.tipoContacto = caso[0].CC_Tipo_Contacto__c == null ? '' : caso[0].CC_Tipo_Contacto__c;
        datos.numPerso = caso[0].Account.CC_NumPerso__c == null ? '' : caso[0].Account.CC_NumPerso__c;
        datos.numeroDocumento = caso[0].Account.CC_Numero_Documento__c == null ? '' : caso[0].Account.CC_Numero_Documento__c;
        datos.edad = caso[0].Contact.CC_Edad__c == null ? 0 : caso[0].Contact.CC_Edad__c;
        datos.confidencial = caso[0].Account.CC_Confidencial__c == null ? false : caso[0].Account.CC_Confidencial__c;
        datos.tipoPersona = caso[0].Account.CC_TipoPersona__c == null ? '' : caso[0].Account.CC_TipoPersona__c;
        datos.fallecido = caso[0].Contact.CC_FechaDefuncion__c == null ? false : true;
        datos.incapacitado = caso[0].Account.CC_IncapacitadoLegal__c == null ? false : caso[0].Account.CC_IncapacitadoLegal__c;

        return datos;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGruposColaboradores(String cadenaBusqueda, String negocio) {
        //Se buscan grupos de colaborador de tipo grupo colaborador o centro CaixaBank
        return [SELECT Name FROM CC_Grupo_Colaborador__c
                WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND
                (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador')
                OR RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank'))
                AND OS_Negocio__c = :negocio
                LIMIT 30];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> buscarColaborador(String idGrupoColaborador) {

        Map<String, String> idMapContacto = new Map<String, String>();

        List<CC_Grupo_Colaborador_Contact__c> contactosGrupoColab = [SELECT CC_Para_CC__c, CC_Email__c FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :idGrupoColaborador AND (CC_Contacto__c != null OR CC_Usuario__c != null)];

        for (CC_Grupo_Colaborador_Contact__c contactoGrupoColab : contactosGrupoColab) {
            idMapContacto.put(contactoGrupoColab.CC_Email__c, contactoGrupoColab.CC_Para_CC__c);
        }

        return idMapContacto;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> buscarColaboradorGestor(String idGrupoColaborador, String idCaso) {
        Map<String, String> idMapContacto = new Map<String, String>();

        //Buscar si se tiene informado el campo Empleado Gestor y añadir el email correspondiente a CC.
        List<Case> lstCase = [SELECT Account.AV_EAPGestor__r.Email, Account.CC_Tipo_Centro__c FROM Case WHERE Id = :idCaso LIMIT 1];

        if (!lstCase.isEmpty() && lstCase.get(0).Account.AV_EAPGestor__r?.Email != null) {
            idMapContacto.put(lstCase.get(0).Account.AV_EAPGestor__r.Email, 'HDT');
        }

        List<CC_Grupo_Colaborador__c> grupos = [SELECT CC_Cuenta__r.CC_Email__c FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__r.Recordtype.DeveloperName= 'CC_CentroCaixaBank' and  Id = :idGrupoColaborador];
		for (CC_Grupo_Colaborador__c grupo : grupos) {
            idMapContacto.put(grupo.CC_Cuenta__r.CC_Email__c, 'Para');
        }

        List<CC_Grupo_Colaborador_Contact__c> contactosGrupoColab = [SELECT CC_Para_CC__c, CC_Email__c FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :idGrupoColaborador AND (CC_Contacto__c != null OR CC_Usuario__c != null)];

        for (CC_Grupo_Colaborador_Contact__c contactoGrupoColab : contactosGrupoColab) {
            idMapContacto.put(contactoGrupoColab.CC_Email__c, contactoGrupoColab.CC_Para_CC__c);
        }

        return idMapContacto;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGrupos3N(String cadenaBusqueda) {
        return [SELECT Name, CC_Queue_Traslado__c FROM CC_Grupo_Colaborador__c
                WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND RecordType.DeveloperName = 'CC_Grupo_Tercer_Nivel' AND CC_Queue_Traslado__c != null];
    }

    @AuraEnabled(cacheable=true)
    public static string buscarCorreoContacto(Id idCaso) {
        List<Case> casos = [SELECT SuppliedEmail, CC_MailTelfNotif__c, Contact.Email FROM Case WHERE Id = :idCaso LIMIT 1];
        if (casos.isEmpty()) {
            return '';
        } else {
            String sAuxMail = '';
            if (casos[0].SuppliedEmail != '' && casos[0].SuppliedEmail != null) {
                sAuxMail = casos[0].SuppliedEmail;
            } else if (casos[0].CC_MailTelfNotif__c != '' && casos[0].CC_MailTelfNotif__c != null) {
                sAuxMail = casos[0].CC_MailTelfNotif__c;
            } else {
                sAuxMail = casos[0].Contact.Email;
            }
            return sAuxMail;
        }
    }

    @AuraEnabled
    public static void cambiarPropietario(String grupoName, String colaName, String recordId, String comentario) {

        List<Group> colas = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = :colaName LIMIT 1];
        if(!colas.isEmpty()){
            Case caso = new Case(Id = recordId);
            caso.OwnerId = colas[0].Id;
            caso.Status = 'Pendiente Interno';
            caso.CC_En_Tercer_Nivel__c = true;
            caso.CC_Grupo_3N__c = grupoName;
            update caso;

            String subject = 'Traslado a ' + colas[0].Name + ' de Tercer Nivel';
            String tipo = 'Traslado Tercer Nivel';
            createActivityTraslados(recordId, comentario, subject, tipo, colas[0].Name);

            if(colas[0].DeveloperName == 'Cola_3N_CSBD'){
                String numeroCaso = [SELECT CaseNumber FROM Case WHERE Id = :recordId LIMIT 1].CaseNumber;
                List<CC_Aviso_Case__e> avisos = new List<CC_Aviso_Case__e>();

                String tipoToast = 'warning';
        		String mensaje = 'Ha llegado un nuevo caso a la cola 3N_CSBD (caso NUMERO_CASO)';
                mensaje = mensaje.replace('NUMERO_CASO', numeroCaso);

                avisos.add(new CC_Aviso_Case__e(Mensaje__c = mensaje, Case_Id__c = recordId,  Tipo__c = tipoToast));

                if (!avisos.isEmpty()) {
                    EventBus.publish(avisos);
                }

            }
        }
    }

    @AuraEnabled
    public static String devolver(String recordId, String comentario, String tipo, Boolean ampliarInformacion) {
        String resultado = 'OK';

        Case caso = [SELECT Owner.Name, OwnerId, CC_Owner_Anterior__c, CC_Owner_Anterior__r.Name, Status, CC_En_Tercer_Nivel__c,
                            CC_Fecha_Activo_Formulario__c, CC_Canal_Procedencia__c, CC_Resolucion__c
                    FROM Case WHERE Id = :recordId LIMIT 1];

        // Se comprueba si se ha informado el campo resolucion 3N para permitir devolver/rechazar
        if (caso.CC_Resolucion__c == null && ampliarInformacion == false) {
            resultado = 'KO';
        } else {
            String grupo3N = caso.Owner.Name;
            caso.OwnerId = caso.CC_Owner_Anterior__c;
            //Controlamos si es un Formulario Web para informar la fecha en la que ha vuelto a Activo
            if (caso.CC_Canal_Procedencia__c == 'Caixabank Talks' || caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }
            //Controlamos cuando se hace la devolución y se pone Activo para report de Accionistas.
            if (caso.CC_Canal_Procedencia__c == 'Accionista') {
                caso.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionista');
            }
            //caso.CC_Owner_Anterior__c = null; // El campo CC_Owner_Anterior__c ahora se actualiza desde un proceso cada vez que hay un cambio de propietario
            caso.CC_En_Tercer_Nivel__c = false;

            if (tipo == 'devolver') {
                HDT_Activity.finalizarActividadCaso(recordId, 'Traslado Tercer Nivel', 'Devuelto por Tercer Nivel', comentario);
                caso.Status = 'Activo';
                //caso.CC_Grupo_3N__c = ''; comentado 25/05/2020 no queremos que se blanquee el valor en el campo grupo
                caso.CC_Situacion_Caso__c = 'Devuelto 3N';
            } else if (tipo == 'rechazar') {
                HDT_Activity.finalizarActividadCaso(recordId, 'Traslado Tercer Nivel', 'Rechazado por Tercer Nivel', comentario);
                caso.Status = 'Activo';
                //caso.CC_Grupo_3N__c = ''; comentado 25/05/2020 no queremos que se blanquee el valor en el campo grupo
                caso.CC_Situacion_Caso__c = 'Rechazado 3N';
            }
            update caso;
            resultado = 'OK';
        }
        return resultado;
    }

    public static void createActivityTraslados(Id recordId, String comentario, String subject, String tipoTarea, String grupo3N) {
        createActivityTraslados(recordId, comentario, subject, tipoTarea, grupo3N, null);
    }

    public static void createActivityTraslados(Id recordId, String comentario, String subject, String tipoTarea, String grupo3N, Id llamadaId) {

        //"24-02-2020" -> llamamos a la funcion para realizarlo tambien desde una llamada cuando trasladan a 3N
        valorPorDefectocanalOperativo(recordId);

        //Crear actividad
        Task task = new Task();
        //string recordTipe = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');

        task.WhatId = recordId;
        task.Status = 'Open';
        task.ActivityDate = System.today();
        task.Subject = subject;
        task.Type = tipoTarea;

        task.CallObject = grupo3N;
        task.Description = comentario;
        task.CC_Fecha_Inicio__c = Datetime.valueOf(System.now());
        task.CC_Llamada_Id__c = llamadaId;

        //Cálculo de la fecha límite
        String horasSLA = CC_Listas_Valores.lookupValue('Configuración de SLA para 3N', grupo3N);
        String nombreBusinessHours = CC_Listas_Valores.lookupValue('Configuración de horario de oficina para 3N', grupo3N);

        if (horasSLA != null && nombreBusinessHours != null) {
            String idBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = :nombreBusinessHours LIMIT 1].Id;
            task.CC_Tiempo_Resolucion__c = Integer.valueof(horasSLA);
            Datetime fechaVencimiento = BusinessHours.add(idBusinessHours, System.now(), Integer.valueof(horasSLA) * 60 * 60 * 1000); //en milisegundos
            if (fechaVencimiento != null) {
                Task.CC_Fecha_Vencimiento__c = fechaVencimiento;
            }
        }

        if (tipoTarea == 'Rechazar Primer Nivel') {
            //Bell notification
            task.IsReminderSet = true;
            Datetime myDateNow = Datetime.valueOf(System.now());
            Datetime newDate = myDateNow.addMinutes(2); //Fix temporal!
            task.ReminderDateTime = newDate;
        }
        //insert task;
        HDT_Activity.crearActividad(task);

    }

    @AuraEnabled(cacheable=true)
    public static String obtenerSubjectEmailTemplate(String idPlantilla) {
        return [SELECT Subject FROM EmailTemplate WHERE Id = :idPlantilla LIMIT 1].Subject;
    }

    @AuraEnabled
    public static Boolean mostrarBotonesPendienteColaborador(String recordId){
        List<Case> statusCase = [SELECT Status FROM Case WHERE Id = :recordId];
        String statusCaso = statusCase[0].Status;
        Boolean botonesPendienteColaborador = true;
        if (statusCaso == 'Pendiente Colaborador') {
            botonesPendienteColaborador = false;
        }
        return botonesPendienteColaborador;
    }

    @AuraEnabled
    public static Boolean mostrarBotonesPendienteInterno(String recordId){
        List<Case> statusCase = [SELECT Status FROM Case WHERE Id = :recordId];
        String statusCaso = statusCase[0].Status;
        Boolean botonesPendienteInterno = true;
        if (statusCaso == 'Pendiente Interno') {
            botonesPendienteInterno = false;
        }
        return botonesPendienteInterno;
    }

    @AuraEnabled
    public static Boolean mostrarBotonesPendienteCliente(String recordId){
        List<Case> statusCase = [SELECT Status FROM Case WHERE Id = :recordId];
        String statusCaso = statusCase[0].Status;
        Boolean botonesPendienteCliente = true;
        if (statusCaso == 'Pendiente Cliente') {
            botonesPendienteCliente = false;
        }
        return botonesPendienteCliente;
    }


    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getCustomPermissions(String nombreGrupo3N, Case caso) {
        Map<String, Boolean> permisos = new Map<String, Boolean>();


        permisos.put('HDT_Trasladar_Colaborador', FeatureManagement.checkPermission('HDT_Trasladar_Colaborador'));
        permisos.put('HDT_Remitir_Colaborador', FeatureManagement.checkPermission('HDT_Remitir_Colaborador'));
        permisos.put('HDT_Solicitar_Informacion', FeatureManagement.checkPermission('HDT_Solicitar_Informacion'));
        permisos.put('HDT_Trasladar_3N', FeatureManagement.checkPermission('HDT_Trasladar_3N'));
        permisos.put('HDT_Devolver_1N', FeatureManagement.checkPermission('HDT_Devolver_1N'));
        permisos.put('HDT_Devolver_1N_LOV', [SELECT Count() FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = '3N - Grupos con devolución a 1N' AND Name = :nombreGrupo3N] > 0);
        permisos.put('HDT_Rechazar_1N', FeatureManagement.checkPermission('HDT_Rechazar_1N'));
        permisos.put('HDT_Responder_Cliente', FeatureManagement.checkPermission('HDT_Responder_Cliente'));
        permisos.put('HDT_Crear_Incidencia', FeatureManagement.checkPermission('HDT_Crear_Incidencia'));
        permisos.put('HDT_Asociar_Incidencia', FeatureManagement.checkPermission('HDT_Asociar_Incidencia'));
        permisos.put('HDT_Autoasignarme_Caso', FeatureManagement.checkPermission('HDT_Autoasignarme_Caso'));
        permisos.put('HDT_OTP', FeatureManagement.checkPermission('HDT_OTP'));
        permisos.put('HDT_Envio_Notificacion_Push', FeatureManagement.checkPermission('HDT_Envio_Notificacion_Push'));
        permisos.put('HDT_GDPR', FeatureManagement.checkPermission('HDT_GDPR'));
		permisos.put('HDT_Lync', FeatureManagement.checkPermission('HDT_Lync'));
        permisos.put('CC_parentIdRecordTypeIsSAC', false);

        return permisos;
    }


    @AuraEnabled
    public static String hdtgetParentIdRecordTypeDeveloperName(Id casoparentid){
        String developerName = '';
        List<Case> casoParent = [SELECT RecordTypeId, RecordType.DeveloperName, Id FROM Case WHERE ID = :casoparentid];
        if (!casoParent.isEmpty()) {
            developerName = casoParent.get(0).RecordType.DeveloperName;
        }
        return developerName;
    }


    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> hdtgetCustomPermissions(String nombreGrupo3N, Id caseparentId) {
        Map<String, Boolean> permisos = new Map<String, Boolean>();

        permisos.put('HDT_Trasladar_Colaborador', FeatureManagement.checkPermission('HDT_Trasladar_Colaborador'));
        permisos.put('HDT_Remitir_Colaborador', FeatureManagement.checkPermission('HDT_Remitir_Colaborador'));
        permisos.put('HDT_Solicitar_Informacion', FeatureManagement.checkPermission('HDT_Solicitar_Informacion'));
        permisos.put('HDT_Trasladar_3N', FeatureManagement.checkPermission('HDT_Trasladar_3N'));
        permisos.put('HDT_Devolver_1N', FeatureManagement.checkPermission('HDT_Devolver_1N'));
        permisos.put('HDT_Devolver_1N_LOV', [SELECT Count() FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = '3N - Grupos con devolución a 1N' AND Name = :nombreGrupo3N] > 0);
        permisos.put('HDT_Rechazar_1N', FeatureManagement.checkPermission('HDT_Rechazar_1N'));
        permisos.put('HDT_Responder_Empleado', FeatureManagement.checkPermission('HDT_Responder_Empleado'));
        permisos.put('HDT_Crear_Incidencia', FeatureManagement.checkPermission('HDT_Crear_Incidencia'));
        permisos.put('HDT_Asociar_Incidencia', FeatureManagement.checkPermission('HDT_Asociar_Incidencia'));
        permisos.put('HDT_Autoasignarme_Caso', FeatureManagement.checkPermission('HDT_Autoasignarme_Caso'));
        permisos.put('HDT_OTP', FeatureManagement.checkPermission('HDT_OTP'));
        permisos.put('HDT_Envio_Notificacion_Push', FeatureManagement.checkPermission('HDT_Envio_Notificacion_Push'));
        permisos.put('HDT_GDPR', FeatureManagement.checkPermission('HDT_GDPR'));
		permisos.put('HDT_Lync', FeatureManagement.checkPermission('HDT_Lync'));
        permisos.put('HDT_parentIdRecordTypeIsSAC', false);

        if (caseparentId != null) {
            permisos.put('CC_parentIdRecordTypeIsSAC', hdtgetParentIdRecordTypeDeveloperName(caseparentId) == 'SAC_Reclamacion');
        }
        return permisos;
    }


    public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        public PickListWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getPlantillaList(String tipoOperativa, String recordId) {
        String carpeta = '';
        if (tipoOperativa == 'trasladar') {
            carpeta = 'HDT_Trasladar_Empleado';
        } else if (tipoOperativa == 'solicitar') {
            carpeta = 'HDT_Solicitar_Empleado_es';
        }

        List<pickListWrapper> optionsPlantillas = new List<pickListWrapper>();
        List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];

        for (EmailTemplate plantilla : plantillas) {
            PickListWrapper wrap = new PickListWrapper(plantilla.Name, plantilla.Id);
            optionsPlantillas.add(wrap);
        }
        return optionsPlantillas;
    }

    @AuraEnabled(cacheable=true)
    public static List<Folder> subdirectorios(String rutaDevName) {
        //Devuelve la lista de carpetas dentro de la carpeta indicada
        List<Folder> retorno = new List<Folder>();
        List<Folder> directorios = [SELECT Id FROM Folder WHERE DeveloperName = :rutaDevName];
        if (!directorios.isEmpty()) {
            for (Folder directorio : [SELECT Name, DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :directorios[0].Id]) {
                retorno.add(directorio);
            }
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> plantillas(String rutaDevName) {
        //Devuelve la lista de plantillas dentro de la carpeta indicada
        List<EmailTemplate> retorno = new List<EmailTemplate>();

        List<Folder> directorios = [SELECT Id FROM Folder WHERE DeveloperName = :rutaDevName];
        if (!directorios.isEmpty()) {
            for (EmailTemplate plantilla : [SELECT Name, DeveloperName FROM EmailTemplate WHERE FolderId = :directorios[0].Id]) {
                retorno.add(plantilla);
            }
        }
        return retorno;
    }

    @AuraEnabled(cacheable=true)
    public static String plantillaCuerpo(String developerName, Boolean convertirATextoPlano) {
        //Devuelve el cuerpo de la plantilla indicada
        String cuerpo = [SELECT HtmlValue FROM EmailTemplate WHERE developerName = :developerName].HtmlValue;

        //Si se ha indicado que se devuelva en texto plano se quitan los tags HTML
        if (convertirATextoPlano) {
            cuerpo = cuerpo.stripHtmlTags();
        }
        return cuerpo;
    }

    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getPlantillaGrupoList(Id grupoId, String tipoOperativa) {
        List<CC_Grupo_Colaborador_Plantilla__c> plantillasGrupo = [SELECT CC_Plantilla_DeveloperName__c FROM CC_Grupo_Colaborador_Plantilla__c WHERE CC_Grupo_Colaborador__c = :grupoId AND CC_Operativa__c = :tipoOperativa];
        List<String> nombresPlantilla = new List<String>();
        for (CC_Grupo_Colaborador_Plantilla__c plantilla : plantillasGrupo) {
            nombresPlantilla.add(plantilla.CC_Plantilla_DeveloperName__c);
        }
        List<pickListWrapper> optionsPlantillas = new List<pickListWrapper>();
        List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :nombresPlantilla ORDER BY Name ASC];

        for (EmailTemplate plantilla : plantillas) {
            PickListWrapper wrap = new PickListWrapper(plantilla.Name, plantilla.Id);
            optionsPlantillas.add(wrap);
        }

        return optionsPlantillas;
    }

    @AuraEnabled
    public static String obtenerIdioma(String recordId) {
        string resultado = [SELECT CC_Idioma__c FROM Case WHERE Id = :recordId LIMIT 1].CC_Idioma__c;
        return resultado;
    }


    @AuraEnabled
    public static String obtenerCanalRespuesta(String recordId) {
        string resultado = [SELECT CC_Canal_Respuesta__c FROM Case WHERE Id = :recordId LIMIT 1].CC_Canal_Respuesta__c;
        return resultado;
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> buscarPlantillasResponder(String cadenaBusqueda, String carpeta) {
        List<EmailTemplate> plantillas = [SELECT Name FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta AND Name LIKE :('%'+cadenaBusqueda + '%')];
        return plantillas;
    }

    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getPlantillasResponder(String recordId, String carpeta) {
        List<Case> casos = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :recordId LIMIT 1];
        List<Task> tareasDelCaso = [SELECT Id
                                    FROM Task
                                        WHERE WhatId =:recordId AND
                                        (Type = 'Traslado Tercer Nivel' OR Type = 'Traslado Colaborador' OR Type = 'Traslado Incidencia')];

        String tematica;
        String prodServicio;
        String motivo;

        Set<String> idsMCC = new Set<String>();
        if (!casos.isEmpty()) {
            Case caso = casos.get(0);
            if (caso.CC_MCC_Tematica__c != null) {
                tematica = caso.CC_MCC_Tematica__c;
                idsMCC.add(tematica);
            }

            if (caso.CC_MCC_ProdServ__c != null) {
                prodServicio = caso.CC_MCC_ProdServ__c;
                idsMCC.add(prodServicio);
            }

            if (caso.CC_MCC_Motivo__c != null) {
                motivo = caso.CC_MCC_Motivo__c;
                idsMCC.add(motivo);
            }
        }

        List<CC_MCC_Plantilla__c> plantillasMCC = [SELECT CC_MCC_Plantilla_DeveloperName__c FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN :idsMCC];
        List<EmailTemplate> plantillasEmail = new  List<EmailTemplate>();
        List<pickListWrapper> wrapPlantilla = new List<pickListWrapper>();
        if (!plantillasMCC.isEmpty()) {
            Set<String> opcionesPlantillaMCC = new Set<String>();
            for (CC_MCC_Plantilla__c plantillaMCC : plantillasMCC) {
                opcionesPlantillaMCC.add(plantillaMCC.CC_MCC_Plantilla_DeveloperName__c);
            }

            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta AND DeveloperName IN :opcionesPlantillaMCC ORDER BY Name ASC];
            if (plantillasEmail.isEmpty()) {
                plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :carpeta ORDER BY Name ASC];
            }
        } else {
            plantillasEmail = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName =: carpeta ORDER BY Name ASC];
        }

        if(tareasDelCaso.isEmpty()){
            for (EmailTemplate plantillaEmail : plantillasEmail) {
                if(plantillaEmail.DeveloperName != 'CC_ConsultasOperativasCanalFormulario_Gestionado_CAT_SIN' && plantillaEmail.DeveloperName != 'CC_ConsultasOperativasCanalFormulario_Gestionado_CAS_SIN'){
                    PickListWrapper wrap = new PickListWrapper(plantillaEmail.Name, plantillaEmail.Id);
                    wrapPlantilla.add(wrap);
                }
            }
        }
        else{
            for (EmailTemplate plantillaEmail : plantillasEmail) {
                if(plantillaEmail.DeveloperName != 'CC_ConsultasOperativasCanalFormulario_Gestionado_CAT_BOT' && plantillaEmail.DeveloperName != 'CC_ConsultasOperativasCanalFormulario_Gestionado_CAS_BOT'){
                    PickListWrapper wrap = new PickListWrapper(plantillaEmail.Name, plantillaEmail.Id);
                    wrapPlantilla.add(wrap);
                }
            }
        }

        return wrapPlantilla;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean existeCarpeta(String carpetaDeveloperName) {
        List<Folder> carpetaPrincipal = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
        return (!carpetaPrincipal.isEmpty() ? false : true);
    }

    @AuraEnabled(cacheable=true)
    public static List<Folder> getCarpetas(String carpetaDeveloperName, String carpetaGenerica) {
        List<Folder> carpetas = new List<Folder>();
        Id parentId;
        if (carpetaDeveloperName == null) {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'HDT_Operativas' LIMIT 1].Id;
        } else {
            //parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
            List<Folder> carpetaPrincipal = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName];
            if (!carpetaPrincipal.isEmpty()) {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
            } else {
                parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaGenerica LIMIT 1].Id;
            }
        }

        for (Folder carpeta : [SELECT Name, DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :parentId]) {
            carpetas.add(carpeta);
        }
        return carpetas;
    }

    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getGrupoList() {
        List<pickListWrapper> optionsGrupos = new List<pickListWrapper>();
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c
                                                WHERE (RecordType.DeveloperName = 'CC_CentroCaixaBank'
                                                AND (CC_Cuenta__r.CC_Tipo_Centro__c = 'OF' OR CC_Cuenta__r.CC_Tipo_Centro__c = 'GC'))
                                                OR RecordType.DeveloperName = 'CC_Grupo_Colaborador'
                                                ORDER BY RecordType.Name ASC LIMIT 10];

        for (CC_Grupo_Colaborador__c grupo : grupos) {
            PickListWrapper wrap = new PickListWrapper(grupo.Name, grupo.Name);
            optionsGrupos.add(wrap);
        }

        return optionsGrupos;
    }

    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getMCCGrupoList(String recordId, String tipoGrupo) {

        List<Case> casos = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_Canal_Operativo__c FROM Case WHERE Id = :recordId LIMIT 1];
        String tematica;
        String prodServicio;
        String motivo;

        Set<String> idsMCC = new Set<String>();

        if (!casos.isEmpty()) {
            Case caso = casos.get(0);
            if (caso.CC_MCC_Tematica__c != null) {
                tematica = caso.CC_MCC_Tematica__c;
                idsMCC.add(tematica);
            }

            if (caso.CC_MCC_ProdServ__c != null) {
                prodServicio = caso.CC_MCC_ProdServ__c;
                idsMCC.add(prodServicio);
            }

            if (caso.CC_MCC_Motivo__c != null) {
                motivo = caso.CC_MCC_Motivo__c;
                idsMCC.add(motivo);
            }
        }

        Id recordTypeIdGrupo = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Tercer_Nivel').getRecordTypeId();
        List<CC_MCC_Grupo_Colaborador__c> grupos = new List<CC_MCC_Grupo_Colaborador__c>();

        List<pickListWrapper> optionsGrupos = new List<pickListWrapper>();
        List<String> nombreGrupo = new List<String>();

        if(tipoGrupo == '3N'){
        	grupos = [SELECT CC_Grupo_Colaborador__r.CC_Queue_Traslado__c, CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.Id
                      FROM CC_MCC_Grupo_Colaborador__c
                      WHERE CC_MCC__c IN :idsMCC
                      AND CC_Grupo_Colaborador__r.RecordtypeId = :recordTypeIdGrupo
                      ORDER BY Name ASC];

            for (CC_MCC_Grupo_Colaborador__c grupo : grupos) {
                PickListWrapper wrap = new PickListWrapper(grupo.CC_Grupo_Colaborador__r.Name, grupo.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c);
                if (!nombreGrupo.contains(grupo.CC_Grupo_Colaborador__r.Name)) {
                    nombreGrupo.add(grupo.CC_Grupo_Colaborador__r.Name);
                    optionsGrupos.add(wrap);
                }
            }
        }else{
            grupos = [SELECT CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.Id
                      FROM CC_MCC_Grupo_Colaborador__c
                      WHERE CC_MCC__c IN :idsMCC
                      AND CC_Grupo_Colaborador__r.RecordtypeId != :recordTypeIdGrupo
                      ORDER BY Name ASC];
          	for (CC_MCC_Grupo_Colaborador__c grupo : grupos) {
                PickListWrapper wrap = new PickListWrapper(grupo.CC_Grupo_Colaborador__r.Name, grupo.CC_Grupo_Colaborador__r.Id);
                if (!nombreGrupo.contains(grupo.CC_Grupo_Colaborador__r.Name)) {
                    nombreGrupo.add(grupo.CC_Grupo_Colaborador__r.Name);
                    optionsGrupos.add(wrap);
                }
            }
        }



        return optionsGrupos;
    }

    @AuraEnabled
    public static void vaciarPlantilla(String recordId) {
        Case caso = new Case(Id = recordId);
        caso.CC_MCC_Plantilla__c = null;
        caso.CC_Email_Cabecera__c = null;
        caso.CC_Email_Pie__c = null;
        update caso;
    }

    @AuraEnabled
    public static void actualizarCaso(Id idCaso, String plantilla, Boolean informarReferenciaCorreo, String tratamiento, String operativa, String canalRespuesta, String canalProcedencia, String tipoRegistro) {

        vaciarPlantilla(idCaso);
        Case casoRef = [SELECT Id, CC_Matricula_Empleado__c, CaseNumber, CC_MCC_Tematica__r.name, CC_MCC_Tematica__c, CC_Idioma__c FROM Case WHERE Id = :idCaso LIMIT 1];
        String casoNumber = casoRef.CaseNumber;

        if (idCaso != null && (plantilla != null || informarReferenciaCorreo)) {
            String nombrePlantillaCabecera;
            String nombrePlantillaPie;
            String bodyCabecera;
            String bodyPie;

            if (operativa == 'responder') {
                List<CC_Plantillas_Canal_Procedencia__mdt> mdts = new List<CC_Plantillas_Canal_Procedencia__mdt>();
                mdts = [SELECT CC_Nombre_plantilla_cabecera__c, CC_Nombre_plantilla_pie__c
                        FROM CC_Plantillas_Canal_Procedencia__mdt
                        WHERE CC_Canal_procedencia__c = :canalProcedencia
                        AND CC_Operativa__c = :operativa
                        AND CC_Tratamiento__c = :tratamiento
                        AND CC_Tipo_Registro__c = :tipoRegistro LIMIT 1];
                if (mdts.isEmpty()) {
                    mdts = [SELECT CC_Nombre_plantilla_cabecera__c, CC_Nombre_plantilla_pie__c
                            FROM CC_Plantillas_Canal_Procedencia__mdt
                            WHERE CC_Canal_procedencia__c = 'Por defecto'
                            AND CC_Operativa__c = :operativa
                            AND CC_Tratamiento__c = :tratamiento
                            AND CC_Tipo_Registro__c = :tipoRegistro LIMIT 1];
                }

                if (!mdts.isEmpty()) {
                    nombrePlantillaCabecera = mdts.get(0).CC_Nombre_plantilla_cabecera__c;
                    nombrePlantillaPie = mdts.get(0).CC_Nombre_plantilla_pie__c;
                }
            }

            Case caso = new Case(Id = idCaso);
            if (plantilla != null) {
                caso.CC_MCC_Plantilla__c = plantilla;
               String tipoPlantilla = [SELECT DeveloperName FROM EmailTemplate WHERE Id = :plantilla].DeveloperName;
                if (operativa == 'responder' && tipoPlantilla.startsWith('Personalizada')) {
                    caso.CC_Respuesta_Personalizada__c = true;
                }
            }

            if (nombrePlantillaCabecera != null) {
                caso.CC_Email_Cabecera__c = nombrePlantillaCabecera;
            }

            if (nombrePlantillaPie != null) {
                caso.CC_Email_Pie__c = nombrePlantillaPie;
            }

            if (informarReferenciaCorreo) {

                string casonumerico = CC_EmailMessage.generarReferenciaCorreoSaliente(casoNumber);
                caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(casoNumber);
            }

            caso.CC_Ultima_Operativa_Correo__c = operativa;

            if(String.isBlank(caso.CC_URL_Encuesta_Formulario__c)){
                List<CC_Envio_Encuesta__c> linkEncuestaEmpleado = [SELECT CC_Link_LimeSurvey__c, CC_Id_Encuesta__c FROM CC_Envio_Encuesta__c WHERE Name = 'CC_EncuestaFormularioOperativas' LIMIT 1];
                if(!linkEncuestaEmpleado.isEmpty()){
                    //Actualizar URL de la encuesta en el caso
                    caso.CC_URL_Encuesta_Formulario__c = (String)linkEncuestaEmpleado[0].CC_Link_LimeSurvey__c+'sid='+(String)linkEncuestaEmpleado[0].CC_Id_Encuesta__c+'&lang='+
                    casoRef.CC_Idioma__c+'&userid='+casoRef.CC_Matricula_Empleado__c+'&ticketid='+casoRef.CaseNumber+'&idet='+casoRef.CC_MCC_Tematica__c+'&et='+ casoRef.CC_MCC_Tematica__r.name.replace(' ', '_')+ '&newtest=Y';
                }
            }


            update caso;
        }
    }

    @AuraEnabled
    public static List<String> validarCamposCaso(String recordId) {

        Case caso = [SELECT CC_Detalles_Consulta__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
                            CC_MCC_Tematica__r.CC_Activo__c, CC_MCC_ProdServ__r.CC_Activo__c, CC_MCC_Motivo__r.CC_Activo__c,
                            Origin, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Contacto__c, CC_Canal_Operativo__c
                        FROM Case WHERE Id = :recordId];

        //Validación de campos nulos
        List<String> camposNoValidos = new List<String>();

        if (caso.CC_MCC_Tematica__c == null) {
            camposNoValidos.add('Temática');
        }
        if (caso.CC_MCC_ProdServ__c == null) {
            camposNoValidos.add('Producto/Servicio');
        }
        if (caso.CC_MCC_Motivo__c == null) {
            camposNoValidos.add('Motivo');
        }
        if (caso.Origin == null) {
            camposNoValidos.add('Canal de entrada');
        }
        if (caso.CC_Canal_Procedencia__c == null) {
            camposNoValidos.add('Canal de procedencia');
        }
        if (caso.CC_Idioma__c == null) {
            camposNoValidos.add('Idioma');
        }
        if (caso.CC_Tipo_Contacto__c == null) {
            camposNoValidos.add('Tipo de contacto');
        }
        if (caso.Origin != 'Propuestas de mejora' && caso.CC_Detalles_Consulta__c == null) {
            camposNoValidos.add('Detalles Consulta');
        }

        //Si las claves foráneas a MCCs no son nulas, se mira además que los MCCs a los que apuntan estén activos
        if (caso.CC_MCC_Tematica__c != null && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_Motivo__c != null) {
            //Se preparan los Ids en una lista para poder la comprobación en una sola consulta
            List<Id> idsMCC = new List<Id>{caso.CC_MCC_Tematica__c, caso.CC_MCC_ProdServ__c, caso.CC_MCC_Motivo__c};
            List<CC_MCC__c> mccs = [SELECT CC_Activo__c, RecordType.DeveloperName FROM CC_MCC__c WHERE Id IN :idsMCC];

            for (CC_MCC__c mcc : mccs) {
                if (!mcc.CC_Activo__c) {
                    camposNoValidos.add('Clasificación inactiva');
                    break;
                }
            }
        }

        return camposNoValidos;
    }


    @AuraEnabled(cacheable=true)
    public static String obtenerEmailFromHDT(String idiomaCaso) {

        String email = '';

        //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta (Configuracion_1 : Castellano, Configuracion_2 : Catalan)
        List<HDT_Parametros__c> parametrosEmail = [SELECT HDT_Configuracion_1__c, HDT_Configuracion_2__c, HDT_Configuracion_3__c
                                                    FROM HDT_Parametros__c WHERE Name = 'HDT_Email_Respuesta_Empleados_New' LIMIT 1];
        if (!parametrosEmail.isEmpty()) {
            String campoEmail; //Variable para almacenar el campo de configuración según el idioma
            if (idiomaCaso == 'Castellano') {
                campoEmail = parametrosEmail[0].HDT_Configuracion_1__c;
            } else if (idiomaCaso == 'Catalán') {
                campoEmail = parametrosEmail[0].HDT_Configuracion_2__c;
            } else if (idiomaCaso == 'Inglés') {
                campoEmail = parametrosEmail[0].HDT_Configuracion_3__c;
            } else {
                //Manejar otros idiomas o asignar un valor por defecto si es necesario
                campoEmail = parametrosEmail[0].HDT_Configuracion_1__c;
            }

            if (String.isNotBlank(campoEmail)) {
                List<OrgWideEmailAddress> owa = [SELECT Address FROM OrgWideEmailAddress WHERE Address = :campoEmail LIMIT 1];
                if (!owa.isEmpty()) {
                    email = owa[0].Address;
                }
            }
        }
        return email;
    }

    @AuraEnabled(cacheable=true)
    public static String obtenerEmailFrom(String idioma) {
        String displayName = '';
        String email = '';
        if (idioma == 'es') {
            displayName = 'Atención al Cliente Cas';
        } else if (idioma == 'ca') {
            displayName = 'Atención al Cliente Cat';
        } else if (idioma == 'en') {
            displayName = 'Atención al Cliente Eng';
        }

        List<OrgWideEmailAddress> emailOrg = [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName = :displayName LIMIT 1];
        if (!emailOrg.isEmpty()) {
            email = emailOrg.get(0).Address;
        }
        return email;
    }

    @AuraEnabled
    public static void autoasignarmeCaso(Id recordId) {
        Case caso = new Case(Id = recordId);
        caso.OwnerId = UserInfo.getUserId();
        caso.CC_Autoasignado_Coordinador__c = true;
        update caso;
    }

    @AuraEnabled
    public static Boolean getEsPropietarioCaso(String sIdCaso) {
        //Rescatamos el id de usuario y lo comparamos con el del usuario asignado al caso, si no es el mismo
        //devolvemos error por no ser propietario
        return CC_busqueda_alf_controller.getEsPropietarioCaso(sIdCaso);
    }

    @AuraEnabled
    public static void guardaTipoGestion(String sIdCaso, string tipoGestion) {
        //si el tipo gestion no es nulo, lo guardamos en el caso
        if (tipoGestion != '' && tipoGestion != null) {
            Case caso = [SELECT CC_Tipo_Gestion_3N_Demanda__c FROM Case WHERE Id = :sIdCaso LIMIT 1];
            caso.CC_Tipo_Gestion_3N_Demanda__c = tipoGestion;
            update caso;
        }
    }

    @AuraEnabled
    public static void valorPorDefectocanalOperativo(String sIdCaso) {
        Case caso = [SELECT CC_Canal_Operativo__c FROM Case WHERE Id = :sIdCaso LIMIT 1];
        if (caso.CC_Canal_Operativo__c == null) {
            caso.CC_Canal_Operativo__c = 'Sin canal';
        }
        update caso;
    }

    @AuraEnabled
    public static String enviarNotificacinPushSMS(Id sObjectId, String destinatario, String texto) {
        return CC_Push_SMS.enviarNotificacionPush(sObjectId, destinatario, texto);
    }


    @AuraEnabled(cacheable=true)
    public static List<Case> recuperaMailEmpleado(String recordId){
        List<Case> datosEmpleado = new List<Case>();
        List<Case> emailEmpleadoCase = [SELECT Contact.Email, Contact.Name FROM Case WHERE Id = :recordId LIMIT 1];
        if(!emailEmpleadoCase.isEmpty()){
			datosEmpleado = emailEmpleadoCase;
        }
        return datosEmpleado;
    }


    @AuraEnabled
    public static String crearTaskWebCollab(String recordId, String empleado){
        //Crear actividad
        Task task = new Task();
        task.WhatId = recordId;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.Status = 'Open';
        task.ActivityDate = System.today();
        task.Subject = 'Solicitud de Compartición de pantalla';
        task.Type = 'Automática';
        task.Description = 'Se comparte pantalla con el empleado: ' + empleado;
        task.CC_Fecha_Inicio__c = Datetime.valueOf(System.now());
        insert task;
        return task.Id;
    }

    @AuraEnabled
    public static String updateTaskWebCollab(String recordId){
        String idTask = '';
        List<Task> idTareaActualizar = [SELECT Id FROM Task WHERE WhatId = :recordId AND Subject = 'Solicitud de Compartición de pantalla' AND Status = 'Open'];
        if (!idTareaActualizar.isEmpty()){
            idTask = idTareaActualizar[0].Id;
        }

        if (idTask != null && idTask != ''){
			Task task = new Task();
            task.Id = idTask;
            task.CC_Fecha_Fin__c = Datetime.valueOf(System.now());
            task.Status = 'Completed';
            update task;
        }
        return idTask;
    }
    /*
    @AuraEnabled
    public static Id getOficinaAfectada(Id recordId) {
        return [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :recordId].CC_Oficina_Afectada_Lookup__c;
    }*/

    @AuraEnabled
    public static Boolean validarCanalAutenticacion(Id recordId) {
        List<CC_Lista_Valores__c> listaCanalesAutenticacion = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_Autenticacion_Cliente'];
        Set<String> valoresCanales = new Set<String>();
        for (CC_Lista_Valores__c canal : listaCanalesAutenticacion) {
            if(canal.CC_Activa__c){
                valoresCanales.add(canal.CC_Valor__c);
            }
        }
        List<Case> casos = [SELECT toLabel(Origin) FROM Case WHERE Id = :recordId AND toLabel(Origin) IN :valoresCanales];
		return casos.isEmpty() ? false : true;
    }

    @AuraEnabled
    public static Map<Object,Object> esClienteDigital(String recordId, String tipoActividad) {
        try {
            return CC_Int_ObtInfCarterizaCliente.esClienteDigital(recordId, tipoActividad);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerFechasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType){
        try {
            return CC_Int_AvailabilitiesGestor.obtenerFechasDisponiblidadGestor(recordId, employeeId, gestorElegidoId, eventType);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerHorasDisponiblidadGestor(String recordId, String employeeId, String gestorElegidoId, String eventType, String fechaElegida){
        try {
            return CC_Int_AvailabilitiesGestor.obtenerHorasDisponiblidadGestor(recordId, employeeId, gestorElegidoId, eventType, fechaElegida);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

    @AuraEnabled
    public static String vincularLlamadaEnCurso(Id recordId) {
        List<CC_Llamada__c> llamadas = [SELECT Name, CC_Tipo__c FROM CC_Llamada__c WHERE RecordType.DeveloperName = 'HDT_Empleado'
                                        AND OwnerId = :UserInfo.getUserId() AND CC_Fecha_Fin__c = NULL LIMIT 2];
        if (llamadas.size() != 1) {
            throw new AuraHandledException('No se ha encontrado ninguna llamada en curso que vincular al caso');
        } else {
            if ([SELECT Count() FROM Task WHERE WhatId = :recordId AND CC_Llamada_Id__c = :llamadas[0].Id] > 0) {
                throw new AuraHandledException('El caso ya se encuentra vinculado con la llamada en curso');
            } else {
                //Se vincula la llamada
                String tipo = llamadas[0].CC_Tipo__c == 'Entrante' ? 'Llamada entrante' : 'Llamada saliente';

                Task tarea = new Task();
                tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                tarea.WhatId = recordId;
                tarea.Type = tipo;
                tarea.Subject = tipo;
                tarea.ActivityDate = System.today();
                tarea.Status = 'Open';
                tarea.CC_Llamada_Id__c = llamadas[0].Id;
                tarea.CC_Fecha_Inicio__c = System.now();
                insert tarea;
                return llamadas[0].Name;
            }
        }
    }
}