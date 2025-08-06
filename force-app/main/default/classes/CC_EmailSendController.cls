public with sharing class CC_EmailSendController {

    @AuraEnabled
    public static Case datosCaso(Id recordId) {
        return [SELECT Description, CC_Detalles_Consulta__c, Contact.Email, Contact.Name, Contact.RecordTypeId, RecordTypeId,
                RecordType.DeveloperName, Account.CC_Email__c, ContactId,  Account.CC_NumPerso__c, Account.AV_NumPerso__c, Account.AV_EAPGestor__r.Name,
                Account.AV_EAPGestor__r.AccountId, Account.AV_EAPGestor__c, Account.Name, AccountId, Account.AV_OficinaPrincipal__c,
                Account.AV_OficinaPrincipal__r.RecordTypeId, Account.AV_OficinaPrincipal__r.CC_Email__c,
                Account.AV_OficinaPrincipal__r.Name, Account.PersonEmail, Account.RecordType.DeveloperName, Account.RecordTypeId,
                Account.CC_MarcaSenior__c, CC_Tipo_Cliente__c, CC_Canal_Procedencia__c, Contact.Phone, CC_Tipo_Cliente_Formula__c,
                CC_MCC_Motivo__c, Origin, Status, Subject, CreatedDate, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, CC_Grupo_3N__c,
                CC_No_Identificado__c, CC_En_Segundo_Nivel__c, CC_Traslado_2N__c, CC_En_Tercer_Nivel__c, CC_Canal_Operativo__c, 
                CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c,CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c , CC_MCC_Causa__c,
                CC_MCC_Solucion__c, CC_Oportunidad_creada__c,CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c,ParentId, Parent.RecordType.DeveloperName, CC_MCC_Motivo__r.CC_Permitir_traslado_2_oficina__c, CC_Representante__c
                FROM Case WHERE Id = :recordId];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean oficinaPermiteTrasladarRemitir(Id recordId, Boolean otraOficina, String oficinaSeleccionada) {
        String oficinaAccount;
        if (otraOficina) {
            oficinaAccount = [SELECT Account.AV_OficinaPrincipal__r.Name FROM Case WHERE Id = :recordId LIMIT 1].Account.AV_OficinaPrincipal__r.Name;
        } else if (String.isNotBlank(oficinaSeleccionada)) {
            oficinaAccount = oficinaSeleccionada;
        }
        return [SELECT Name FROM CC_Lista_Valores__c
                WHERE CC_Lista__r.Name = 'Centros CaixaBank que no permiten remitidos o traslados'
                AND Name = :oficinaAccount AND CC_Activa__c = TRUE LIMIT 1].isEmpty();
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
        List<Case> caso = [SELECT CC_MCC_ProdServ__r.CC_GDPR__c, CC_Tipo_Contacto__c,Account.CC_NumPerso__c,
                            Account.CC_Numero_Documento__c, Contact.CC_Edad__c, Account.CC_Confidencial__c,
                            Contact.CC_FechaDefuncion__c, Account.CC_Tipo_Persona__c, Account.CC_IncapacitadoLegal__c
                            FROM Case WHERE Id = :recordId];
        DatosCasoGDPRWrapper datos = new DatosCasoGDPRWrapper();
        datos.productoGDPR = caso[0].CC_MCC_ProdServ__r.CC_GDPR__c == null ? false : caso[0].CC_MCC_ProdServ__r.CC_GDPR__c;
        datos.tipoContacto = caso[0].CC_Tipo_Contacto__c == null ? '' : caso[0].CC_Tipo_Contacto__c;
        datos.numPerso = caso[0].Account.CC_NumPerso__c == null ? '' : caso[0].Account.CC_NumPerso__c;
        datos.numeroDocumento = caso[0].Account.CC_Numero_Documento__c == null ? '' : caso[0].Account.CC_Numero_Documento__c;
        datos.edad = caso[0].Contact.CC_Edad__c == null ? 0 : caso[0].Contact.CC_Edad__c;
        datos.confidencial = caso[0].Account.CC_Confidencial__c == null ? false : caso[0].Account.CC_Confidencial__c;
        datos.tipoPersona = caso[0].Account.CC_Tipo_Persona__c == null ? '' : caso[0].Account.CC_Tipo_Persona__c;
        datos.fallecido = caso[0].Contact.CC_FechaDefuncion__c == null ? false : true;
        datos.incapacitado = caso[0].Account.CC_IncapacitadoLegal__c == null ? false : caso[0].Account.CC_IncapacitadoLegal__c;
        return datos;
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGruposColaboradores(String cadenaBusqueda, String negocio, Boolean remitir, String tipoCaso) {
        if(tipoCaso == 'CC_Cliente') {
            //Se buscan grupos de colaborador de tipo grupo colaborador o centro CaixaBank
            List<String> tipo = (remitir ? new List<String>{'Remitidos','Traslados y Remitidos'} : new List<String>{'Traslados','Traslados y Remitidos'});
            return [SELECT Name FROM CC_Grupo_Colaborador__c
                    WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND
                    RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador')
                    AND OS_Negocio__c = :negocio
                    AND CC_Queue_Traslado__c = null
                    AND CC_Tipo__c IN :tipo
                    LIMIT 30];
        } else {
            return [SELECT Name FROM CC_Grupo_Colaborador__c
                    WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND
                    RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador')
                    AND OS_Negocio__c = :negocio
                    AND CC_Queue_Traslado__c = null
                    LIMIT 30];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> buscarEmpleado(String cadenaBusqueda) {
        //Se buscan grupos de colaborador de tipo grupo colaborador o centro CaixaBank
        return [FIND :cadenaBusqueda RETURNING Contact(name, Email where RecordType.DeveloperName = 'CC_Empleado' AND CC_Inactivo__c = false)][0];
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> buscarOficina(String cadenaBusqueda, String filtrarNombreOficina) {
        //Se buscan grupos de colaborador de tipo grupo colaborador o centro CaixaBank
        return [FIND :cadenaBusqueda IN NAME FIELDS RETURNING Account(Name, CC_Email__c WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' AND Id != :filtrarNombreOficina LIMIT 7)][0];
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
    public static Map<String, String> buscarEmpleadoOficina(String idOficina, String emailAccountCase, String nombreAccount, Boolean flagCamino, String empleadoGestorId, String idSegundaOficina)
    {
        Map<String, String> idMapContacto = new Map<String, String>();
        List<String> descFunciones = new List<String>{'DIRECCION','DIRECTOR','SUBDIRECCION COMERCIAL','SUBDIRECTOR','DIRECCIÓN','SUBDIRECCIÓN COMERCIAL'};

        if(flagCamino)
        {
            if(String.isNotBlank(empleadoGestorId))
            {
                List<Contact> empleadoGestor = [SELECT Name, Email  FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Inactivo__c = false AND Id =: empleadoGestorId LIMIT 1];

                if(!empleadoGestor.isEmpty())
                {
                    idMapContacto.put(empleadoGestor[0].Email, empleadoGestor[0].Name);
                }
            }

            if(String.isBlank(idSegundaOficina))
            {
                if(String.isNotBlank(idOficina))
                {
                    List<Contact> empleadosOficina = [SELECT Name, Email  FROM Contact
                    WHERE RecordType.DeveloperName = 'CC_Empleado'
                    AND AccountId =: idOficina
                    AND CC_Inactivo__c = false
                    AND AV_DescFuncion__c IN : descFunciones];

                    if(!empleadosOficina.isEmpty())
                    {
                        for (Contact empleadoOficina : empleadosOficina)
                        {
                            idMapContacto.put(empleadoOficina.Email, empleadoOficina.Name);
                        }
                    }
                }
            }
            else
            {
                if(String.isNotBlank(idOficina))
                {
                    List<Contact> empleadosOficina = [SELECT Name, Email  FROM Contact
                    WHERE RecordType.DeveloperName = 'CC_Empleado'
                    AND AccountId =: idOficina
                    AND CC_Inactivo__c = false
                    AND AV_DescFuncion__c IN : descFunciones LIMIT 5];

                    if(!empleadosOficina.isEmpty())
                    {
                        for (Contact empleadoOficina : empleadosOficina)
                        {
                            idMapContacto.put(empleadoOficina.Email, empleadoOficina.Name);
                        }
                    }
                }
                if(String.isNotBlank(idSegundaOficina))
                {
                    List<Contact> empleadosSegundaOficina = [SELECT Name, Email  FROM Contact
                    WHERE RecordType.DeveloperName = 'CC_Empleado'
                    AND AccountId =: idSegundaOficina
                    AND CC_Inactivo__c = false
                    AND AV_DescFuncion__c IN : descFunciones LIMIT 5];

                    if(!empleadosSegundaOficina.isEmpty())
                    {
                        for (Contact empleadoOficina : empleadosSegundaOficina)
                        {
                            idMapContacto.put(empleadoOficina.Email, empleadoOficina.Name);
                        }
                    }
                }
            }



            //Falta AV_EAPGestor sustituir por lo de abajo
            /*if(String.isNotBlank(emailAccountCase) && String.isNotBlank(nombreAccount)){
                idMapContacto.put(emailAccountCase, nombreAccount);
            }*/
        }
        else
        {
            List<Contact> empleadosOficina;
            if(String.isNotBlank(idOficina)){
                List<Contact> contactoOficina = [SELECT AccountId,Name, Email  FROM Contact WHERE Id =: idOficina AND CC_Inactivo__c = false LIMIT 1];
                if(!contactoOficina.isEmpty()){
                    if(empleadoGestorId == 'empleado'){
                        idMapContacto.put(contactoOficina[0].Email, contactoOficina[0].Name);
                    }else{
                        empleadosOficina = [SELECT Name, Email  FROM Contact
                        WHERE RecordType.DeveloperName = 'CC_Empleado'
                        AND AccountId =: contactoOficina[0].AccountId
                        AND CC_Inactivo__c = false
                        AND AV_DescFuncion__c IN : descFunciones];

                        if(!empleadosOficina.isEmpty()){
                            for (Contact empleadoOficina : empleadosOficina) {
                                idMapContacto.put(empleadoOficina.Email, empleadoOficina.Name);
                            }
                        }
                    }
                }
            }
        }

        return idMapContacto;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> buscarColaboradorGestor(String idGrupoColaborador, String idCaso) {
        Map<String, String> idMapContacto = new Map<String, String>();

        //Buscar si se tiene informado el campo Empleado Gestor y añadir el email correspondiente a CC.
        List<Case> lstCase = [SELECT Account.AV_EAPGestor__r.Email, Account.CC_Tipo_Centro__c FROM Case WHERE Id = :idCaso LIMIT 1];

        if (!lstCase.isEmpty() && lstCase.get(0).Account.AV_EAPGestor__r?.Email != null) {
            idMapContacto.put(lstCase.get(0).Account.AV_EAPGestor__r.Email, 'CC');
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
        Id recordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Tercer_Nivel').getRecordTypeId();

        return [SELECT Id, Name, CC_Queue_Traslado__c FROM CC_Grupo_Colaborador__c
                WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND RecordTypeId = :recordTypeId AND CC_Queue_Traslado__c != null];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> buscarGrupos2N(String cadenaBusqueda) {
        Id recordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Segundo_Nivel').getRecordTypeId();

        return [SELECT Id, Name, CC_Queue_Traslado__c FROM CC_Grupo_Colaborador__c
                WHERE Name LIKE :('%' + cadenaBusqueda + '%') AND RecordTypeId = :recordTypeId AND CC_Queue_Traslado__c != null];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_3N__mdt> buscarGrupos3NOld(String cadenaBusqueda) {
        return [SELECT MasterLabel, CC_Queue_Developer_Name__c FROM CC_Grupo_3N__mdt WHERE MasterLabel LIKE :('%' + cadenaBusqueda + '%')];
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
                String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
                Pattern myPattern = Pattern.compile(emailRegex);
                Matcher myMatcher = myPattern.matcher(casos[0].CC_MailTelfNotif__c);
                if(myMatcher.matches()){
                    sAuxMail = casos[0].CC_MailTelfNotif__c;
                }else {
                    sAuxMail = casos[0].Contact.Email;
                } 
            } else {
                sAuxMail = casos[0].Contact.Email;
            }
            return sAuxMail;
        }
    }

    @AuraEnabled
    public static void cambiarPropietario(String grupoName, String colaName, String recordId, String comentario, String grupoId) {

        List<Group> colas = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = :colaName LIMIT 1];

        if(!colas.isEmpty() && String.isNotBlank(recordId)) {
            Case caso = new Case(Id = recordId);
            caso.OwnerId = colas[0].Id;
            caso.Status = 'Pendiente Interno';
            caso.CC_En_Tercer_Nivel__c = true;
            caso.CC_En_Segundo_Nivel__c = false;
            caso.CC_Grupo_3N__c = grupoName;
            if(colas[0].Name == '3N de CSBD'){caso.CC_Status_Autorizacion__c = 'SIN ESTADO';}
            update caso;
            //actualizarCasoAsync(caso.Id, colas[0].Id);

            String subject = 'Traslado a ' + colas[0].Name + ' de Tercer Nivel';
            String tipo = 'Traslado Tercer Nivel';
            createActivityTraslados(recordId, comentario, subject, tipo, colas[0].Name, grupoId);

            if(colas[0].DeveloperName == 'Cola_3N_CSBD') {
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

    @future
    public static void actualizarCasoAsync(Id casoId, Id nuevoOwnerId) {
        Case caso = new Case(Id = casoId);
        caso.OwnerId = nuevoOwnerId;
        update caso;
    }

    @AuraEnabled
    public static void cambiarPropietario2N(String grupoName, String colaName, String recordId, String comentario, String grupoId) {

        List<Group> colas = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = :colaName LIMIT 1];

        if(!colas.isEmpty()){
            Case caso = new Case(Id = recordId);
            caso.OwnerId = colas[0].Id;
            caso.Status = 'Pendiente Interno';
            caso.CC_En_Segundo_Nivel__c = true;
            caso.CC_En_Tercer_Nivel__c = false;
            caso.CC_Traslado_2N__c = true;
            caso.CC_Grupo_2N__c = grupoName;
            update caso;

            String subject = 'Traslado a ' + colas[0].Name + ' de Segundo Nivel';
            String tipo = 'Traslado Segundo Nivel';
            createActivityTraslados(recordId, comentario, subject, tipo, colas[0].Name, grupoId);
        }
    }

    @AuraEnabled
    public static String devolver(String recordId, String comentario, String tipo, Boolean ampliarInformacion) {
        String resultado = 'OK';

        Case caso = [SELECT ContactId, Contact.Email, Owner.Name, OwnerId, CC_Owner_Anterior__c, CC_Owner_Anterior__r.Name, Status, CC_En_Segundo_Nivel__c, CC_En_Tercer_Nivel__c,CC_Cola_Procedencia__c,
                            CC_Fecha_Activo_Formulario__c, CC_Canal_Procedencia__c, CC_Resolucion2Nivel__c, CC_Resolucion__c, CC_Grupo_Transfer__c, Origin, CC_Canal_Resolucion__c,CC_Idioma__c,CC_Matricula_Empleado__c,
                            CaseNumber,CC_MCC_Tematica__c,CC_MCC_Tematica__r.Name
                    FROM Case WHERE Id = :recordId LIMIT 1];

        // Se comprueba si se ha informado el campo resolucion 3N para permitir devolver/rechazar
        if (((caso.CC_En_Segundo_Nivel__c && caso.CC_Resolucion2Nivel__c == null) || (caso.CC_En_Tercer_Nivel__c && caso.CC_Resolucion__c == null)) && ampliarInformacion == false) {
        //if (caso.CC_Resolucion__c == null && ampliarInformacion == false) {
                resultado = 'KO';

        } else {
            String grupo3N = caso.Owner.Name;
            // DE72570 --> En caso de que el canal de procedencia sea Formulario Consultas Operativas debe devolverse a la cola de procedencia
            if(caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas')
            {
                if (caso.CC_Grupo_Transfer__c != null) {
                    caso.OwnerId = caso.CC_Grupo_Transfer__c;
                } else {
                    if(caso.CC_Cola_Procedencia__c != null && caso.CC_Cola_Procedencia__c != ''){
                        Group cola = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c AND Type = 'Queue'];
                        if(cola != null)
                        {
                            caso.OwnerId = cola.Id;
                        }
                    }

                }
            }
            else
            {
                if(caso.CC_Owner_Anterior__c != null){
                    caso.OwnerId = caso.CC_Owner_Anterior__c;
                }
            }
            //Controlamos si es un Formulario Web para informar la fecha en la que ha vuelto a Activo
            if (caso.CC_Canal_Procedencia__c == 'Caixabank Talks' || caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }
            //Controlamos cuando se hace la devolución y se pone Activo para report de Accionistas.
            if (caso.CC_Canal_Procedencia__c == 'Accionista') {
                caso.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionista');
            }
            //caso.CC_Owner_Anterior__c = null; // El campo CC_Owner_Anterior__c ahora se actualiza desde un proceso cada vez que hay un cambio de propietario
            if (caso.CC_En_Tercer_Nivel__c == true) {
                caso.CC_En_Tercer_Nivel__c = false;
                if (tipo == 'devolver') {
                    CC_Activity.finalizarActividadCaso(recordId, 'Traslado Tercer Nivel', 'Devuelto por Tercer Nivel', comentario);
                    caso.Status = 'Activo';
                    //caso.CC_Grupo_3N__c = ''; comentado 25/05/2020 no queremos que se blanquee el valor en el campo grupo
                    caso.CC_Situacion_Caso__c = 'Devuelto 3N';
                } else if (tipo == 'rechazar') {
                    CC_Activity.finalizarActividadCaso(recordId, 'Traslado Tercer Nivel', 'Rechazado por Tercer Nivel', comentario);
                    caso.Status = 'Activo';
                    //caso.CC_Grupo_3N__c = ''; comentado 25/05/2020 no queremos que se blanquee el valor en el campo grupo
                    caso.CC_Situacion_Caso__c = 'Rechazado 3N';
                }
            } else if (caso.CC_En_Segundo_Nivel__c == true) {
                caso.CC_En_Segundo_Nivel__c = false;
                if (tipo == 'devolver') {
                    CC_Activity.finalizarActividadCaso(recordId, 'Traslado Segundo Nivel', 'Devuelto por Segundo Nivel', comentario);
                    caso.Status = 'Activo';
                    caso.CC_Situacion_Caso__c = 'Devuelto 2N';

                } else if (tipo == 'rechazar') {
                    CC_Activity.finalizarActividadCaso(recordId, 'Traslado Segundo Nivel', 'Rechazado por Segundo Nivel', comentario);
                    caso.Status = 'Activo';
                    caso.CC_Situacion_Caso__c = 'Rechazado 2N';
                }
            }
            caso.CC_Grupo_Transfer__c = null;
            update caso;
            resultado = 'OK';
        }

        return resultado;
    }

    public static void createActivityTraslados(Id recordId, String comentario, String subject, String tipoTarea, String grupo3N, String grupoId) {
        createActivityTraslados(recordId, comentario, subject, tipoTarea, grupo3N, grupoId, null);
    }

    public static void createActivityTraslados(Id recordId, String comentario, String subject, String tipoTarea, String grupo3N, String grupoId, Id llamadaId) {

        //"24-02-2020" -> llamamos a la funcion para realizarlo tambien desde una llamada cuando trasladan a 3N
        valorPorDefectocanalOperativo(recordId);
        //Crear actividad
        Task task = new Task();
        task.WhatId = recordId;
        task.Status = 'Open';
        task.ActivityDate = System.today();
        task.Subject = subject;
        task.Type = tipoTarea;
        task.CallObject = grupo3N;
        task.Description = comentario;
        task.CC_Fecha_Inicio__c = Datetime.valueOf(System.now());
        task.CC_Llamada_Id__c = llamadaId;
        task.CC_Grupo_Colaborador_Id__c = grupoId;
        task.CC_validacion_tarea_manual__c = true;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
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
        CC_Activity.crearActividad(task);

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
        permisos.put('CC_Trasladar_Colaborador', FeatureManagement.checkPermission('CC_Trasladar_Colaborador'));
        permisos.put('CC_Realizar_Transfer', FeatureManagement.checkPermission('CC_Realizar_Transfer'));
        permisos.put('CC_Remitir_Colaborador', FeatureManagement.checkPermission('CC_Remitir_Colaborador'));
        permisos.put('CC_Solicitar_Informacion', FeatureManagement.checkPermission('CC_Solicitar_Informacion'));
        permisos.put('CC_Trasladar_2N', FeatureManagement.checkPermission('CC_Trasladar_2N'));
        permisos.put('CC_Trasladar_3N', FeatureManagement.checkPermission('CC_Trasladar_3N'));
        permisos.put('CC_Devolver_1N', FeatureManagement.checkPermission('CC_Devolver_1N'));
        permisos.put('CC_Devolver_1N_LOV', [SELECT COUNT() FROM CC_Lista_Valores__c WHERE (CC_Lista__r.Name = '3N - Grupos con devolución a 1N' OR CC_Lista__r.Name = '2N - Grupos con devolución a 1N') AND Name = :nombreGrupo3N] > 0);
        permisos.put('CC_Rechazar_1N', FeatureManagement.checkPermission('CC_Rechazar_1N'));
        permisos.put('CC_Responder_Cliente', FeatureManagement.checkPermission('CC_Responder_Cliente'));
        permisos.put('CC_Crear_Incidencia', FeatureManagement.checkPermission('CC_Crear_Incidencia'));
        permisos.put('CC_Asociar_Incidencia', FeatureManagement.checkPermission('CC_Asociar_Incidencia'));
        permisos.put('CC_Autoasignarme_Caso', FeatureManagement.checkPermission('CC_Autoasignarme_Caso'));
        permisos.put('CC_OTP', FeatureManagement.checkPermission('CC_OTP'));
        permisos.put('CC_Envio_Notificacion_Push', FeatureManagement.checkPermission('CC_Envio_Notificacion_Push'));
        permisos.put('CC_DeepLinking', FeatureManagement.checkPermission('CC_DeepLinking'));
        permisos.put('CC_GDPR', FeatureManagement.checkPermission('CC_GDPR'));
		permisos.put('CC_Lync', FeatureManagement.checkPermission('CC_Lync'));
        permisos.put('CC_Transferir_HDT', FeatureManagement.checkPermission('CC_Transferir_HDT'));

        //permisos SAC
        permisos.put('CC_parentIdRecordTypeIsSAC', caso.ParentId != null && CC_Revincular_Caso_Controller.getParentIdRecordTypeDeveloperName(caso) == 'SAC_Reclamacion');
        for (CC_DevolverDerivarSAC__c boton : CC_DevolverDerivarSAC__c.getAll().values()) {
            if (boton.Name == 'CC_Derivar') {
                permisos.put('CC_DerivarAlSac', boton.CC_Activo__c);
            } else if (boton.Name == 'CC_Devolver') {
                permisos.put('CC_DevolverAlSac', boton.CC_Activo__c);
            }
        }

        //Ini: añadido por JorgeH para US504352-->
        List<GroupMember> listaUsers3NCSBD = [SELECT UserOrGroupId FROM GroupMember
                                                WHERE Group.DeveloperName = 'Cola_3N_CSBD' AND UserOrGroupId = :UserInfo.getUserId() LIMIT 1];
        if (!listaUsers3NCSBD.isEmpty()) {
            Case currentCase = [SELECT Contact.CC_Confidencial__c FROM Case WHERE Id = :caso.Id];
            permisos.put('CC_Confidencial', currentCase.Contact.CC_Confidencial__c);
        } else {
            permisos.put('CC_Confidencial', false);
        }

        return permisos;
    }

     public class PickListWrapperTraslados {
        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public String idRegistro {get; set;}


        public PickListWrapperTraslados(String label, String value, String idRegistro) {
            this.label = label;
            this.value = value;
            this.idRegistro = idRegistro;
        }
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
            carpeta = 'CC_Trasladar_es';
        } else if (tipoOperativa == 'solicitar') {
            carpeta = 'CC_Solicitar_es_formal';
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
    public static WrapperGrupoColabPara getAccountFromClient(Id clienteId) {
        WrapperGrupoColabPara obj = null;

        if(clienteId != null){
            Contact cliente=[SELECT Account.AV_OficinaPrincipal__c FROM Contact WHERE Id = :clienteId LIMIT 1];
            if(String.isNotBlank(cliente.Account.AV_OficinaPrincipal__c)){
                Account accCaixaBank = [SELECT Name, CC_Email__c FROM Account WHERE Id =:cliente.Account.AV_OficinaPrincipal__c LIMIT 1];
                obj = new WrapperGrupoColabPara(accCaixaBank.CC_Email__c, accCaixaBank.Name);
            }
            else{
                obj = new WrapperGrupoColabPara('', '');
            }
        }

        return obj;
    }

    @AuraEnabled
    public static CC_CaseTransfer.TransferResult callTransferCaseToHDT(Id caseId) {
        // Llamamos directamente al método de la clase CC_CaseTransfer
        CC_CaseTransfer.TransferResult result = CC_CaseTransfer.transferCaseToHDT(caseId);
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static WrapperGrupoColabPara getAccountFromClient2(Id clienteId) {
        WrapperGrupoColabPara obj = null;

        if(clienteId != null){
            Contact cliente=[SELECT Id, Email, Name FROM Contact WHERE Id = :clienteId LIMIT 1];
            if(cliente != null){
                obj = new WrapperGrupoColabPara(cliente.Email, cliente.Name);
            }
            else{
                obj = new WrapperGrupoColabPara('', '');
            }
        }

        return obj;
    }

    public class WrapperGrupoColabPara {
        @AuraEnabled
        public String paraEmail{get;set;}
        @AuraEnabled
        public String grupoColab{get;set;}


        public WrapperGrupoColabPara (String paraEmail, String grupoColab){
            this.paraEmail = paraEmail;
            this.grupoColab = grupoColab;
        }
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

    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getPlantillaOficinaList(Id ofiId, String tipoOperativa, String recTypeCase, String recTypeAccountId ) {
        List<pickListWrapper> optionsPlantillas = new List<pickListWrapper>();
        List<String> nombresPlantilla = new List<String>();
        List<CC_Lista_Valores__c> lstPlantillasOfi = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Relacion_plantilla_Objeto' LIMIT 1];

        if (!lstPlantillasOfi.isEmpty()) {
            String recTypeAcc = '';
            if(recTypeAccountId == null || recTypeAccountId == ''){
                recTypeAcc = [SELECT RecordType.DeveloperName FROM Account WHERE Id =: ofiId LIMIT 1].RecordType.DeveloperName;
            }else{
            	recTypeAcc = [SELECT DeveloperName FROM RecordType WHERE Id =: recTypeAccountId LIMIT 1].DeveloperName;
            }

            Id idLista = lstPlantillasOfi[0].Id;
            //String filtroQuery =  '%' + tipoOperativa.substring(0, tipoOperativa.length()-2) + '%';

            List<CC_Lista_Valores__c> plantillasOfi = [SELECT CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Servicio__c =: tipoOperativa AND CC_Lista__c =: idLista AND CC_Valor2__c =: recTypeCase AND CC_Valor__c =: recTypeAcc];

            if(!plantillasOfi.isEmpty()){
                for (CC_Lista_Valores__c plantilla : plantillasOfi) {
                    nombresPlantilla.add(plantilla.CC_Valor_SFDC__c);
                }
                List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :nombresPlantilla ORDER BY Name ASC];


                if(!plantillas.isEmpty()){

                    for (EmailTemplate plantilla : plantillas) {
                        PickListWrapper wrap = new PickListWrapper(plantilla.Name, plantilla.Id);
                        optionsPlantillas.add(wrap);
                    }
                }
            }
        }
        return optionsPlantillas;
    }

    @AuraEnabled(cacheable=true)
    public static List<pickListWrapper> getPlantillaEmpleadoList(Id empleId, String tipoOperativa, String recTypeCase, String recTypeAccountId) {
        List<pickListWrapper> optionsPlantillas = new List<pickListWrapper>();
        List<String> nombresPlantilla = new List<String>();
        List<CC_Lista_Valores__c> lstPlantillasOfi = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Relacion_plantilla_Objeto'];

        if(!lstPlantillasOfi.isEmpty()){

            Id idLista = lstPlantillasOfi[0].Id;
            //String filtroQuery =  '%' + tipoOperativa.substring(0, tipoOperativa.length()-2) + '%';

            List<CC_Lista_Valores__c> plantillasOfi = [SELECT CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Servicio__c =: tipoOperativa AND CC_Lista__c =: idLista AND CC_Valor2__c =: recTypeCase AND CC_Valor__c =: recTypeAccountId];

            if(!plantillasOfi.isEmpty()){
                for (CC_Lista_Valores__c plantilla : plantillasOfi) {
                    nombresPlantilla.add(plantilla.CC_Valor_SFDC__c);
                }
                List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :nombresPlantilla ORDER BY Name ASC];

                if(!plantillas.isEmpty()){

                    for (EmailTemplate plantilla : plantillas) {
                        PickListWrapper wrap = new PickListWrapper(plantilla.Name, plantilla.Id);
                        optionsPlantillas.add(wrap);
                    }
                }
            }
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
        return (!carpetaPrincipal.isEmpty() ? true : false);
    }

    @AuraEnabled(cacheable=true)
    public static List<Folder> getCarpetas(String carpetaDeveloperName, String carpetaGenerica) {
        List<Folder> carpetas = new List<Folder>();
        Id parentId;
        if (carpetaDeveloperName == null) {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'CC_Operativas' LIMIT 1].Id;
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
        Id recordTypeIdCentro = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank');
        Id recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador');

        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c
                                                WHERE (RecordTypeId = :recordTypeIdCentro
                                                AND (CC_Cuenta__r.CC_Tipo_Centro__c = 'OF' OR CC_Cuenta__r.CC_Tipo_Centro__c = 'GC'))
                                                OR RecordTypeId = :recordTypeId
                                                ORDER BY RecordType.Name ASC LIMIT 10];

        for (CC_Grupo_Colaborador__c grupo : grupos) {
            PickListWrapper wrap = new PickListWrapper(grupo.Name, grupo.Name);
            optionsGrupos.add(wrap);
        }

        return optionsGrupos;
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListWrapperTraslados> getMCCGrupoList(String recordId, String tipoGrupo, Boolean remitir, String grupoColaboradorDerivarFraude) {
        List<Case> casos = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_Canal_Operativo__c, RecordTypeId FROM Case WHERE Id = :recordId LIMIT 1];
        String tematica;
        String prodServicio;
        String motivo;
        List<String> trasladarORemitir = (remitir ? new List<String>{'Remitidos','Traslados y Remitidos'} : new List<String>{'Traslados','Traslados y Remitidos'});
        Id recordTypecaso;

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

            recordTypecaso = caso.RecordTypeId;

        }

        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordTypeIdProductoServicio = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        Id recordTypeIdGrupo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel');
        Id recordTypeIdGrupo2N = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Segundo_Nivel');
        Id recordTypeIdCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');

        List<CC_MCC_Grupo_Colaborador__c> grupos = new List<CC_MCC_Grupo_Colaborador__c>();

        List<PickListWrapperTraslados> optionsGrupos = new List<PickListWrapperTraslados>();
        List<String> nombreGrupo = new List<String>();

        if(tipoGrupo == '3N'){
        	grupos = [SELECT CC_Grupo_Colaborador__r.CC_Queue_Traslado__c, CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.CC_Tipo__c
                      FROM CC_MCC_Grupo_Colaborador__c
                      WHERE CC_MCC__c IN :idsMCC
                      AND CC_Grupo_Colaborador__r.RecordtypeId = :recordTypeIdGrupo
                      ORDER BY Name ASC];

            for (CC_MCC_Grupo_Colaborador__c grupo : grupos) {
                PickListWrapperTraslados wrap = new PickListWrapperTraslados(grupo.CC_Grupo_Colaborador__r.Name, grupo.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c, grupo.CC_Grupo_Colaborador__r.Id);
                if (!nombreGrupo.contains(grupo.CC_Grupo_Colaborador__r.Name)) {
                    nombreGrupo.add(grupo.CC_Grupo_Colaborador__r.Name);
                    optionsGrupos.add(wrap);
                }
            }
        }else if (tipoGrupo == '2N') {
        	grupos = [SELECT CC_Grupo_Colaborador__r.CC_Queue_Traslado__c, CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.CC_Tipo__c
                      FROM CC_MCC_Grupo_Colaborador__c
                      WHERE CC_MCC__c IN :idsMCC
                      AND CC_Grupo_Colaborador__r.RecordtypeId = :recordTypeIdGrupo2N
                      ORDER BY Name ASC];

            for (CC_MCC_Grupo_Colaborador__c grupo : grupos) {
                PickListWrapperTraslados wrap = new PickListWrapperTraslados(grupo.CC_Grupo_Colaborador__r.Name, grupo.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c, grupo.CC_Grupo_Colaborador__r.Id);
                if (!nombreGrupo.contains(grupo.CC_Grupo_Colaborador__r.Name)) {
                    nombreGrupo.add(grupo.CC_Grupo_Colaborador__r.Name);
                    optionsGrupos.add(wrap);
                }
            }
        } else {
            if(recordTypecaso != null && recordTypecaso == recordTypeIdCliente){
                if(grupoColaboradorDerivarFraude != '' && grupoColaboradorDerivarFraude != null){
                    grupos = [SELECT CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.CC_Tipo__c
                    FROM CC_MCC_Grupo_Colaborador__c
                    WHERE CC_MCC__c IN :idsMCC 
                    AND CC_Grupo_Colaborador__r.RecordtypeId != :recordTypeIdGrupo 
                    AND CC_Grupo_Colaborador__r.CC_Tipo__c IN :trasladarORemitir AND CC_Grupo_Colaborador__r.Name =: grupoColaboradorDerivarFraude
                    ORDER BY Name ASC];
                } else {
                    grupos = [SELECT CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.CC_Tipo__c
                    FROM CC_MCC_Grupo_Colaborador__c
                    WHERE CC_MCC__c IN :idsMCC
                    AND CC_Grupo_Colaborador__r.RecordtypeId != :recordTypeIdGrupo AND CC_Grupo_Colaborador__r.CC_Tipo__c IN :trasladarORemitir
                    ORDER BY Name ASC];
                }

            } else {
                grupos = [SELECT CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__r.Id, CC_Grupo_Colaborador__r.CC_Tipo__c
                    FROM CC_MCC_Grupo_Colaborador__c
                    WHERE CC_MCC__c IN :idsMCC
                    AND CC_Grupo_Colaborador__r.RecordtypeId != :recordTypeIdGrupo
                    ORDER BY Name ASC];
            }
          	for (CC_MCC_Grupo_Colaborador__c grupo : grupos) {
                PickListWrapperTraslados wrap = new PickListWrapperTraslados(grupo.CC_Grupo_Colaborador__r.Name, grupo.CC_Grupo_Colaborador__r.Id, grupo.CC_Grupo_Colaborador__r.Id);
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
		Case caso = new Case(Id = idCaso);
        List<Case> casoRef = [SELECT Id, CC_MCC_Plantilla__c,CC_Email_Cabecera__c, CC_Email_Pie__c, CC_Matricula_Empleado__c, CaseNumber, CC_MCC_Tematica__r.name, CC_MCC_Tematica__c, CC_Tematica__c, CC_Idioma__c, Origin, CC_Canal_Procedencia__c, CC_Grupo_Colaborador__c, RecordtypeId, CC_En_Tercer_Nivel__c, CC_Fecha_Traslado_3N__c FROM Case WHERE Id = :idCaso LIMIT 1];
        if(casoRef[0].CC_MCC_Plantilla__c != null || casoRef[0].CC_Email_Cabecera__c != null || casoRef[0].CC_Email_Pie__c != null){
            vaciarPlantilla(idCaso);
            }
        String casoNumber = casoRef[0].CaseNumber;

        if (idCaso != null && (plantilla != null || informarReferenciaCorreo)) {
            String nombrePlantillaCabecera;
            String nombrePlantillaPie;
            String bodyCabecera;
            String bodyPie;

            if (operativa == 'responder' || operativa == 'responderClienteDerivar') {
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
                     if(casoRef[0].CC_Canal_Procedencia__c != 'Formulario Consultas Operativas'){
                        nombrePlantillaCabecera = mdts.get(0).CC_Nombre_plantilla_cabecera__c;
                    }
                    nombrePlantillaPie = mdts.get(0).CC_Nombre_plantilla_pie__c;
                }
            }


            if (plantilla != null) {
                caso.CC_MCC_Plantilla__c = plantilla;
                String tipoPlantilla = [SELECT DeveloperName FROM EmailTemplate WHERE Id = :plantilla].DeveloperName;
                if ((operativa == 'responder' || operativa == 'responderClienteDerivar') && tipoPlantilla.startsWith('Personalizada')) {
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
                caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(casoNumber);
            }

            /*if (canalRespuesta != null) {
                caso.CC_Canal_Respuesta__c = canalRespuesta;
            }*/

            caso.CC_Ultima_Operativa_Correo__c = operativa;

            Id rtCaseEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

            Map<Id, String> encuesta = new Map<Id, String>();
            if(casoRef[0].RecordTypeId == rtCaseEmpleado){
                encuesta = CC_MetodosUtiles.generarURLsLimeSurvey(casoRef);
            }
            if(!encuesta.isEmpty()){
                if(String.isBlank(caso.CC_URL_Encuesta_Formulario__c) && casoRef[0].CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'){
                        caso.CC_URL_Encuesta_Formulario__c = encuesta.get(idCaso);
                }else if (casoRef[0].RecordTypeId == rtCaseEmpleado && casoRef[0].CC_Canal_Procedencia__c != 'Formulario Consultas Operativas'){
                    caso.CC_URL_Encuesta_3N__c = encuesta.get(idCaso);
    
                }
            }
            update caso;
        }
    }

    @AuraEnabled
    public static List<String> validarCamposCaso(String recordId) {

        Case caso = [SELECT CC_Representante__c, CC_Detalles_Consulta__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
                            CC_MCC_Tematica__r.CC_Activo__c, CC_MCC_ProdServ__r.CC_Activo__c, CC_MCC_Motivo__r.CC_Activo__c,
                            Origin, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Contacto__c, CC_Canal_Operativo__c, CC_En_Segundo_Nivel__c,
                     		CC_Resolucion2Nivel__c, CC_En_Tercer_Nivel__c, CC_Resolucion__c
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

    /*
    @AuraEnabled
    public static Boolean getEsPropietarioCaso(String sIdCaso) {
        //Rescatamos el id de usuario y lo comparamos con el del usuario asignado al caso, si no es el mismo
        //devolvemos error por no ser propietario
        return CC_busqueda_alf_controller.getEsPropietarioCaso(sIdCaso);
    }
    */

    @AuraEnabled(cacheable=true)
    public static Boolean getEsPropietarioCaso(Id ownerId) {
        return ownerId == UserInfo.getUserId();
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
            update caso;
        }
    }

    @AuraEnabled
    public static String enviarNotificacinPushSMS(Id sObjectId, String destinatario, String texto) {
        return CC_Push_SMS.enviarNotificacionPush(sObjectId, destinatario, texto);
    }


    public class CustomWrappedObj {
        @AuraEnabled
        public Boolean validacion{get;set;}

        @AuraEnabled
        public String app{get;set;}

        public CustomWrappedObj (Boolean validacion, String app){
            this.validacion = validacion;
            this.app = app;
        }

    }


    @AuraEnabled
    public static List<CustomWrappedObj> validarEnrollment(String numPerso){
        if(String.isNotBlank(numPerso)){
            Map<String, Boolean> res = CC_Push_Notificacion_App.validarEnrollmentPUSH(numPerso);
            List<CustomWrappedObj> validaciones = new List<CustomWrappedObj>();
            for(String app : res.keySet()){
                CustomWrappedObj aux = new CustomWrappedObj(res.get(app), app);
                validaciones.add(aux);
            }
            return validaciones;
        }
        else{
            throw new AuraHandledException('No existe un NumPerso asociado a esta cuenta.');
        }
    }

    @AuraEnabled
    public static Boolean envioPoseidon(String sObjectId, String app, String numPer, String textoPublico, String textoPrivado, String asunto, String deeplink, String idioma,String titulo, String sobreTitulo, String textoBoton, String segundoParametro){
        Boolean validacion = true;
        String res = CC_Push_Notificacion_App.enviarNotificacionPushApp(sObjectId, app, numPer, textoPublico, textoPrivado, asunto, deeplink, idioma, titulo, sobreTitulo, textoBoton, segundoParametro);
        system.debug('Resultado envioPoseidon: ' + res);
        if(String.isBlank(res)){
            validacion = false;
        }

            // Actualizar el campo físico en el Caso
        try {
            Case c = [SELECT Id, CC_Excluido_Poseidon__c FROM Case WHERE Id = :sObjectId LIMIT 1];
            c.CC_Excluido_Poseidon__c = !validacion; // true si falló => excluido
            system.debug('Validacion '+validacion);
            system.debug('Caso actualizado: ' + c.Id + ' | CC_Excluido_Poseidon__c = ' + c.CC_Excluido_Poseidon__c);
            update c;
        } catch (Exception e) {
            CBK_Log.debug('Error al actualizar campo CC_Excluido_Poseidon__c: ' + e.getMessage());
        }

        //update caso;
        return validacion;
    }

    @AuraEnabled
    public static CC_Deeplink__c obtenerDatosSeleccionado(String idDeeplink) {
        CC_Deeplink__c result = new CC_Deeplink__c();
        if(String.isNotBlank(idDeeplink)) {
            result = [SELECT Id, CC_App__c, CC_Deeplink__c,
            CC_Asunto_Cas__c, CC_Asunto_Cat__c, CC_Asunto_Ing__c, CC_TextoPrivado_Cas__c, CC_TextoPrivado_Cat__c, CC_TextoPrivado_Ing__c,
            CC_TextoPublico_Cas__c, CC_TextoPublico_Cat__c, CC_TextoPublico_Ing__c, CC_Sobretitulo_Cas__c, CC_Sobretitulo_Cat__c, CC_Sobretitulo_Ing__c,
            CC_Texto_Bot_Cas__c, CC_Texto_Bot_Cat__c, CC_Texto_Bot_Ing__c, CC_Titulo_Cas__c, CC_Titulo_Cat__c, CC_Titulo_Ing__c, CC_TituloConsentimientoCliente__c, CC_CuerpoConsentimientoCliente__c
            FROM CC_Deeplink__c WHERE Id =: idDeeplink LIMIT 1];
        }
        return result;
    }

    @AuraEnabled
    public static List<PickListWrapper> getDeeplinks(String motivoId, String canalOperativo, List<String> apps, String idioma) {
        List<PickListWrapper> results = new List<PickListWrapper>();
        Set<Id> plantillaIds = new Set<Id>();
        for(CC_MCC_Poseidon__c aux: [SELECT CC_Deeplink__c FROM CC_MCC_Poseidon__c WHERE CC_MCC__c =: motivoId]) {
            plantillaIds.add(aux.CC_Deeplink__c);
        }
        List<CC_Deeplink__c> plantillas = new List<CC_Deeplink__c>();
        if(!plantillaIds.isEmpty()) {
            if (idioma == 'es') {
                plantillas = [SELECT CC_Asunto_Cas__c FROM CC_Deeplink__c WHERE CC_App__c IN: apps AND Id IN: plantillaIds];
            } else if (idioma == 'ca') {
                plantillas = [SELECT CC_Asunto_Cat__c FROM CC_Deeplink__c WHERE CC_App__c IN: apps AND Id IN: plantillaIds];
            } else if (idioma == 'en') {
                plantillas = [SELECT CC_Asunto_Ing__c FROM CC_Deeplink__c WHERE CC_App__c IN: apps AND Id IN: plantillaIds];
            }

            if(!plantillas.isEmpty()){
                for(CC_Deeplink__c plantilla : plantillas){
                    String asunto;
                    if (idioma == 'es') {
                        asunto = plantilla.CC_Asunto_Cas__c;
                    } else if (idioma == 'ca') {
                        asunto = plantilla.CC_Asunto_Cat__c;
                    } else if (idioma == 'en') {
                        asunto = plantilla.CC_Asunto_Ing__c;
                    }

                    PickListWrapper res = new PickListWrapper(asunto, plantilla.Id);
                    results.add(res);
                }
                return results;
            }
            else{
                throw new AuraHandledException('No hay registros en la selección.');
            }
        }else{
            throw new AuraHandledException('No hay registros en la selección.');
        }

    }

    public class ParametrosDeeplinkWrapper {
        @AuraEnabled
        public Boolean bool        {get; set;}   //Boolean para determinar si se ve o no el parametro en el modal de poseidon

        @AuraEnabled
        public String valorLabel   {get; set;}   //El nombre que tendra el Label en el modal de poseidon

        @AuraEnabled
        public Integer valor2      {get; set;}   //Valor 2 para determinar el tamaño maximo del parametro.

        public ParametrosDeeplinkWrapper() {
            this.bool = false;
            this.valorLabel = null;
            this.valor2 = null;
        }

        public ParametrosDeeplinkWrapper(Boolean bool, String valorLabel, Integer valor2) {
            this.bool = bool;
            this.valorLabel = valorLabel;
            this.valor2 = valor2;
        }
    }

    @AuraEnabled
    public static ParametrosDeeplinkWrapper validacionParametroDeeplink(String idDeeplink){
        ParametrosDeeplinkWrapper parametross = new ParametrosDeeplinkWrapper(false, '', 255);
        if(String.isNotBlank(idDeeplink)){
            CC_Deeplink__c deeplink = [SELECT CC_Asunto_Cas__c, CC_Asunto_Cat__c, CC_Asunto_Ing__c FROM CC_Deeplink__c WHERE Id =: idDeeplink LIMIT 1];
            if (deeplink != null) {
                CC_Lista_Valores__c valorDeeplink = [SELECT CC_Valor__c, CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Deeplinks dinamicos' AND (CC_Valor__c = :deeplink.CC_Asunto_Cas__c OR CC_Valor__c = :deeplink.CC_Asunto_Cat__c OR CC_Valor__c = :deeplink.CC_Asunto_Ing__c) AND CC_Activa__c = true LIMIT 1];
                if (valorDeeplink != null) {
                    if (deeplink.CC_Asunto_Cas__c == valorDeeplink.CC_Valor__c || deeplink.CC_Asunto_Cat__c == valorDeeplink.CC_Valor__c || deeplink.CC_Asunto_Ing__c == valorDeeplink.CC_Valor__c) {
                        parametross.bool = true;
                        parametross.valorLabel = valorDeeplink.CC_Valor2__c;
                        CC_Lista_Valores__c parametroDeeplink = [SELECT CC_Valor__c, CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Parametros Deeplink' AND CC_Valor__c = :valorDeeplink.CC_Valor2__c AND CC_Activa__c = true LIMIT 1];
                        if (parametroDeeplink != null) {
                            if (String.isNotBlank(parametroDeeplink.CC_Valor2__c)) {
                                parametross.valor2 = Integer.valueOf(parametroDeeplink.CC_Valor2__c);
                            }
                        } else {
                            parametross.valor2 = 255;
                        }
                    }
                }
            }
        }
        return parametross;
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
        String idTask = '';
        List<Task> tareas = new List<Task>();
        //Crear actividad
        Task task = new Task();
        task.WhatId = recordId;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        task.Status = 'Open';
        task.ActivityDate = System.today();
        task.Subject = 'Solicitud de Compartición de pantalla';
        task.Type = 'Automática';
        task.Description = 'Se comparte pantalla con el empleado: ' + empleado;
        task.CC_Fecha_Inicio__c = Datetime.valueOf(System.now());
        tareas.add(task);
        //DataBase Insert para la lista de Tareas.
        Database.SaveResult[] resultsTask = Database.insert(tareas, false);
        for (Database.SaveResult sr : resultsTask) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                idTask = sr.getId();
            }
        }

        return idTask;
    }

    @AuraEnabled
    public static String updateTaskWebCollab(String recordId){
        String idTask = '';
        List<Task> idTareaActualizar = [SELECT Id FROM Task WHERE WhatId = :recordId AND Subject = 'Solicitud de Compartición de pantalla' AND Status = 'Open'];
        if(!idTareaActualizar.isEmpty()){
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

    @AuraEnabled
    public static Id getOficinaAfectada(Id recordId) {
        return [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :recordId].CC_Oficina_Afectada_Lookup__c;
    }

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
    public static void derivarCasoAlSAC(Case casoContactCenter, String motivo) {
        CC_Revincular_Caso_Controller.derivarCasoAlSAC(casoContactCenter, motivo);
    }

    @AuraEnabled
    public static void devolverCasoAlSAC(String motivo, Case casoContactCenter){
        CC_Revincular_Caso_Controller.devolverCasoAlSAC(motivo, casoContactCenter);
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
    @AuraEnabled
    public static List<OT_Picklist.Item> obtenerGestoresBackup(String recordId, String employeeId, String gestorElegidoId, String eventType){
        try {
            return CC_Int_AvailabilitiesGestor.obtenerGestoresBackup(recordId, employeeId, gestorElegidoId, eventType);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

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

    public class cuentaYURL {
        @AuraEnabled
        public Account getCuenta {get;set;}
        @AuraEnabled
        public String getMensaje {get;set;}

        public cuentaYURL(Account getCuenta, String getMensaje) {
            this.getCuenta = getCuenta;
            this.getMensaje = getMensaje;
        }
    }

    @AuraEnabled
    public static cuentaYURL devolverMensaje(Id recordId) {
        String hostnameEntero = String.valueOf(System.Url.getOrgDomainUrl());
        String hostnameSubstring1 = hostnameEntero.remove('Url:[delegate=');
        String hostnameLimpio = hostnameSubstring1.remove(']');
        Account cuenta = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :recordId LIMIT 1];
        String URL = hostnameLimpio + '/lightning/r/Account/' + cuenta.Id + '/view';
        cuentaYURL elementosDevolver = new cuentaYURL(cuenta, URL);
        return elementosDevolver;
    }

    @AuraEnabled
    public static Map<String, Object> crearTareaGestor(String recordId, Boolean esClienteDigital, String numeroGestor, String asunto, String fechaActividad, String comentarios) {
        Map<String, Object> retorno = new Map<String, Object>();
        Boolean gestorGenerico = false;
        Boolean buscarGestor = false;
        String nameGestor;
        String externalID;
        String matriculaGestor;
        String mensaje;
        Account resultado = new Account();
        List<User> gestorCliente = new List<User>();
        List<Task> lstTask = new List<Task>();
        CC_Settings__c configuracionToast = CC_Settings__c.getValues('CC_ToastTareaGestor');
        Date fechaActividadDate = date.valueOf(fechaActividad);
        Id recordTypeTareaAV = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AV_AlertaComercial').getRecordTypeId();
        Id recordTypeTareaCC = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        Case[] caso = [SELECT ContactId, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AccountId, OwnerId, CC_MCC_Motivo__r.CC_AmbitoTareas__c, Account.AV_EAPGestor__r.CC_Matricula__c, Account.AV_EAPGestor__c, Account.AV_IndicadoresClientes__c, Account.AV_EAPGestor__r.AV_EmpleadoIntouch__c, Account.AV_EAPGestor__r.CC_Numero_Oficina__c, Account.AV_EAPGestor__r.Name FROM Case WHERE Id = :recordId];

        Task tareaGestorCaso = new Task();
        tareaGestorCaso.recordTypeId = recordTypeTareaCC;
        tareaGestorCaso.Subject = asunto;
        tareaGestorCaso.Status = 'Open';
        tareaGestorCaso.Priority = 'Normal';
        tareaGestorCaso.Description = comentarios;
        tareaGestorCaso.ActivityDate = fechaActividadDate;
        tareaGestorCaso.WhatId = recordId;
        tareaGestorCaso.AV_OrigenAct__c = 'Contact Center';
        tareaGestorCaso.OwnerId = caso[0].OwnerId;

        Task tareaGestorAccount = new Task();
        tareaGestorAccount.recordTypeId = recordTypeTareaAV;
        tareaGestorAccount.Subject = asunto;
        tareaGestorAccount.Status = 'Open';
        tareaGestorAccount.Priority = 'Normal';
        tareaGestorAccount.Description = comentarios;
        tareaGestorAccount.ActivityDate = Date.Today().addDays(7);
        tareaGestorAccount.AV_Case__c = recordId;
        tareaGestorAccount.WhatId = caso[0].AccountId;
        tareaGestorAccount.Type = 'Tarea gestor';
        tareaGestorAccount.AV_OrigenAct__c = 'Contact Center';
        if(caso[0].Account.AV_IndicadoresClientes__c != null && caso[0].Account.AV_IndicadoresClientes__c.contains('28')) {
            if(caso[0].CC_MCC_Motivo__r.CC_AmbitoTareas__c == 'Oficina') {
                // La tarea se envía a la oficina gestora del cliente. Assigned al sin gestor eap 0000 y que el av_center tenga 5 dígitos.
                resultado = [SELECT Id, Name, RecordType.DeveloperName, CC_Numero_Oficina__c  FROM Account WHERE Id = :caso[0].Account.AV_OficinaPrincipal__c AND RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];
                mensaje = configuracionToast.CC_Configuracion_1__c;
                retorno.put('mensaje', mensaje);
                retorno.put('cuenta', resultado);
                tareaGestorAccount.AV_Center__c = caso[0].Account.AV_EAPGestor__r.CC_Numero_Oficina__c;
                tareaGestorCaso.Type = 'Tarea Oficina';
                gestorGenerico = true;
            } else if (caso[0].CC_MCC_Motivo__r.CC_AmbitoTareas__c == 'Ventas') {
                if (caso[0].Account.AV_EAPGestor__r.AV_EmpleadoIntouch__c) {
                    // la tarea se envía al gestor Intouch del cliente
                    numeroGestor = caso[0].Account.AV_EAPGestor__r.CC_Matricula__c;
                    tareaGestorAccount.AV_Center__c = caso[0].Account.AV_EAPGestor__r.CC_Numero_Oficina__c;
                    tareaGestorCaso.Type = 'Tarea gestor';
                    buscarGestor = true;
                } else {
                    // la tarea se envía al Hub Sales (centro 4563). Assigned al sin gestor eap 0000 y que el av_center tenga 5 dígitos.
                    CC_Settings__c configuracion = CC_Settings__c.getValues('CC_HubSales');
                    tareaGestorAccount.AV_Center__c = configuracion.CC_Configuracion_1__c;
                    tareaGestorCaso.Type = 'Tarea Hub Sales';
                    gestorGenerico = true;
                }
                mensaje = configuracionToast.CC_Configuracion_2__c;
                retorno.put('mensaje', mensaje);
                retorno.put('cuenta', resultado);
            } else {
                if (caso[0].Account.AV_EAPGestor__r.AV_EmpleadoIntouch__c) {
                    // la tarea se envía al gestor Intouch del cliente.
                    numeroGestor = caso[0].Account.AV_EAPGestor__r.CC_Matricula__c;
                    tareaGestorAccount.AV_Center__c = caso[0].Account.AV_EAPGestor__r.CC_Numero_Oficina__c;
                    tareaGestorCaso.Type = 'Tarea gestor';
                    buscarGestor = true;
                } else {
                    // la tarea se envía al Hub Gestión (centro 5202). Assigned al sin gestor eap 0000 y que el av_center tenga 5 dígitos.
                    CC_Settings__c configuracion = CC_Settings__c.getValues('CC_HubGestion');
                    tareaGestorAccount.AV_Center__c = configuracion.CC_Configuracion_1__c;
                    tareaGestorCaso.Type = 'Tarea Hub Gestión';
                    gestorGenerico = true;
                }
                mensaje = configuracionToast.CC_Configuracion_2__c;
                retorno.put('mensaje', mensaje);
                retorno.put('cuenta', resultado);
            }

        } else {
            // COMO ESTABA
            tareaGestorCaso.Type = 'Tarea gestor';
            resultado = null;
            mensaje = configuracionToast.CC_Configuracion_3__c;
            retorno.put('mensaje', mensaje);
            retorno.put('cuenta', resultado);
            tareaGestorAccount.AV_Center__c = caso[0].Account.AV_EAPGestor__r.CC_Numero_Oficina__c;
            buscarGestor = true;
        }

        if(buscarGestor) {
            if(numeroGestor != null) {
                if(numeroGestor.startsWith('U01')) {
                    matriculaGestor = numeroGestor;
                } else if (numeroGestor != '000000') {
                    matriculaGestor = 'U01'+numeroGestor;
                }
                gestorCliente = [SELECT Id FROM User WHERE AV_ExternalID__c =: matriculaGestor];
            }
            if(gestorCliente != null && !gestorCliente.isEmpty()) {
                tareaGestorAccount.OwnerId = gestorCliente[0]?.Id;
            } else {
                gestorGenerico = true;
            }
        }

        if(gestorGenerico) {
            List<CC_Lista_Valores__c> listaLOV = [SELECT CC_Valor__c, Name FROM CC_Lista_Valores__c  WHERE CC_Lista__r.name = 'Gestor por defecto CC'];
            for(CC_Lista_Valores__c valor: listaLOV) {
                if(valor.Name == 'ExternalID') {
                    externalID = valor.CC_Valor__c;
                }
                else if (valor.Name == 'Nombre') {
                    nameGestor = valor.CC_Valor__c;
                }
            }
            gestorCliente = [SELECT Id FROM User WHERE AV_ExternalID__c = :externalID AND Name = :nameGestor LIMIT 1];
            tareaGestorAccount.OwnerId = gestorCliente[0].Id;
        }

        if(!caso.isEmpty())
        {
            tareaGestorAccount.WhoId = caso[0].ContactId;
            tareaGestorCaso.WhoId = caso[0].ContactId;
        }

        lstTask.add(tareaGestorAccount);
        lstTask.add(tareaGestorCaso);
        insert lstTask;
        //return resultado;
        return retorno;

        /* US589281 - Escalados de clientes SIN gestor SE HA PARADO EL DESARROLLO
        List<CC_Lista_Valores__c> listaDT = [SELECT Id, Name, CC_Valor__c FROM CC_Lista_Valores__c  WHERE CC_Lista__r.name = 'DT Tarea Gestor'];
        Boolean dtActiva;
        if(caso[0].Account.CC_Direccion_Territorial__c != null)
        {
            if(!listaDT.isEmpty())
            {
                for(CC_Lista_Valores__c valor : listaDT)
                {
                    if(valor.CC_Valor__c == caso[0].Account.CC_Direccion_Territorial__r.Name)
                    {
                        dtActiva = true;
                    }
                }
            }
        }
        if((gestorCliente[0] == null || gestorCliente[0].Name == 'Sin Gestor/EAP') && dtActiva)
        {
            if(caso[0].Account.AV_OficinaPrincipal__r.CC_Tipo_Centro__c == 'OF' && caso[0].Account.AV_OficinaPrincipal__r.CC_Tipo_Oficina__c == 'G' && caso[0].Account.AV_OficinaPrincipal__r.RecordType.DeveloperName == 'CC_CentroCaixaBank')
            {
                if(caso[0].Account.PersonEmail != null)
                {
                    List<CC_Buzones_Por_Defecto__mdt> buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = :caso[0].CC_Canal_Resolucion__c AND CC_Activo__c = true ];
                    //Si el buzón está vacío usamos el por defecto
                    if (buzonDefault.isEmpty())
                    {
                        buzonDefault  = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                        WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano'
                        AND CC_Activo__c = true ];
                    }

                    //Solo se envía en caso de que haya alguna dirección
                    if (!buzonDefault.isEmpty())
                    {
                        OrgWideEmailAddress oweaid = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c ];
                        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                        Id idEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Now_In_Tel_fono_nico_Remitido_gestor_1629449714874' LIMIT 1].Id;

                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(idEmailTemplate, caso[0].ContactId, recordId);
                        email.subject = 'Respuesta Automática';
                        email.setSaveAsActivity(true);
                        email.setWhatId(recordId);
                        email.setTargetObjectId(caso[0].ContactId);
                        email.setTreatTargetObjectAsRecipient(false);
                        email.setOrgWideEmailAddressId(oweaid.Id);
                        email.setToAddresses(new String[] {caso[0].Account.PersonEmail});
                        allmsg.add(email);
                        Messaging.sendEmail(allmsg, false);

                        EmailMessage correoEM = [SELECT Id, ParentId, CC_Procedencia__c, CC_Grupo_Colab__c, TextBody FROM EmailMessage WHERE ParentId = :caso[0].Id];

                        List<Task> actividadesTraslado = new List<Task>();
                        Task actividadTraslado = new Task();
                        actividadTraslado.Type = 'Remitir Colaborador';
                        actividadTraslado.Subject = 'Remitir Colaborador';
                        actividadTraslado.WhatId = correoEM.ParentId;
                        actividadTraslado.Subject = correoEM.CC_Procedencia__c;
                        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correoEM.CC_Grupo_Colab__c];
                        List<Contact> empleadosLst = new List<Contact>();
                        if(!grupos.isEmpty()){
                            actividadTraslado.CC_Grupo_Colaborador_Id__c = grupos[0].Id;
                        }else{
                            empleadosLst = [FIND :correoEM.CC_Grupo_Colab__c RETURNING Contact (Id, Name WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Inactivo__c = false LIMIT 1)][0];
                            if(!empleadosLst.isEmpty()){
                                actividadTraslado.CC_Empleado_Gestor__c = empleadosLst[0].Id;
                            }
                        }
                        actividadTraslado.Description = correoEM.TextBody.left(32000);
                        actividadTraslado.Status = 'Completed';
                        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
                        actividadTraslado.CC_Correo_Asociado_Id__c = correoEM.Id;
                        actividadesTraslado.add(actividadTraslado);
                        if (!actividadesTraslado.isEmpty())
                        {
                            CC_Activity.crearActividades(actividadesTraslado);
                        }

                        caso.CC_Referencia_Correo_Saliente__c = '';
                        caso.CC_Grupo_Colaborador__c = correoEM.CC_Grupo_Colab__c;
                        casos.add(caso);
                        if(Schema.sObjectType.Case.fields.Status.isUpdateable())
                        {
                            update casos;
                        }
                    }
                }
            }
            else
            {
                // TRASLADO A 3N DE CSBD
                cambiarPropietario('3N de CSBD', 'Cola_3N_CSBD', recordId, '');
            }
        }*/
    }

    //Ini: añadido por JorgeH para US504352-->
    @AuraEnabled
    public static Account getCuentaConfidencial (String accountId){
        Account cliente = [SELECT id, AV_NumPerso__c FROM Account WHERE id =: accountId LIMIT 1];
        Account cuentaConfidencial=null;
        if(cliente!=null){
            try{
                cuentaConfidencial = [SELECT id FROM Account WHERE AV_NumPerso__c =: cliente.AV_NumPerso__c LIMIT 1];
            } catch(Exception e){
                cuentaConfidencial=null;
            }
        }
        return cuentaConfidencial;
    }
    //Fin: añadido por JorgeH para US504352-->

    @AuraEnabled
    public static Map<String, String> mostrarToastPoseidon(Id recordId) {
        Map<String, String> resultado = new Map<String, String>();
        String tituloConsentimiento;
        String cuerpoConsentimiento;
        Id motivo = [SELECT CC_MCC_Motivo__r.Id FROM Case WHERE Id = :recordId].CC_MCC_Motivo__r.Id;

        if(motivo != null) {
            tituloConsentimiento = [SELECT CC_Deeplink__r.CC_TituloConsentimientoCliente__c FROM CC_MCC_Poseidon__c WHERE CC_MCC__c = :motivo].CC_Deeplink__r.CC_TituloConsentimientoCliente__c;
            cuerpoConsentimiento = [SELECT CC_Deeplink__r.CC_CuerpoConsentimientoCliente__c FROM CC_MCC_Poseidon__c WHERE CC_MCC__c = :motivo].CC_Deeplink__r.CC_CuerpoConsentimientoCliente__c;
        }
        if(tituloConsentimiento != null && cuerpoConsentimiento != null) {
            resultado.put('titulo', tituloConsentimiento);
            resultado.put('cuerpo', cuerpoConsentimiento);
        }
        return resultado;
    }

    @AuraEnabled(cacheable=true)
    public static List<QueueSobject> buscarColasTransfer(String cadenaBusqueda) {
        return [SELECT Queue.name, QueueId FROM QueueSobject WHERE Queue.name LIKE :('Cons%') AND Queue.name LIKE :('%' + cadenaBusqueda + '%') ORDER BY Queue.Name LIMIT 30];
    }

    @AuraEnabled
    public static void cambiarPropietarioTransferApex(Id recordId, Id idCola) {
        if (idCola != null) {
            Case caso = new Case(Id = recordId);
            caso.OwnerId = idCola;
            caso.CC_Transfer_Realizado__c = true;
            update caso;
        }
    }

    @AuraEnabled
    public static Map<String,Boolean> comprobarVisibilidadBotonTareaCitaGestor() {
        Map<String,Boolean> resultado = new Map<String,Boolean>();
        CC_Settings__c visibilidadBotones = CC_Settings__c.getValues('CC_VisibilidadCitaTareaGestor');
        resultado.put('botonCita', Boolean.valueOf(visibilidadBotones.CC_Configuracion_1__c));
        resultado.put('botonTarea', Boolean.valueOf(visibilidadBotones.CC_Configuracion_2__c));
        return resultado;
    }

    /*@AuraEnabled(cacheable=true)
    public static Map<String, String> realizarRemitirDesdeDerivar(String recordId) {
        Map<String,String> resultado = new Map<String,String>();
        Case caso = [SELECT CC_MCC_Tematica__r.Name FROM Case WHERE Id = :recordId LIMIT 1];
        CC_Settings__c configuracionDestinatario = CC_Settings__c.getValues('CC_OperativaOficina');
        String destinatario;
        String plantilla;
        if(caso.CC_MCC_Tematica__r.Name == 'Tarjetas') {
            destinatario = configuracionDestinatario.CC_Configuracion_16__c;
            plantilla = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = 'OperativaDerivarGestionFraudeTarjetas' LIMIT 1].HtmlValue;
        } else {
            destinatario = configuracionDestinatario.CC_Configuracion_17__c;
            plantilla = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = 'OperativaDerivarGestionDemasTematicas' LIMIT 1].HtmlValue;
        }
        resultado.put('destinatario' , destinatario);
        resultado.put('plantilla', plantilla);
        return resultado;
    }*/

    @AuraEnabled
    public static void reiniciarDerivar(String recordId) {
        Case caso = new Case(Id = recordId);
        caso.CC_Derivar__c = true;
        update caso;
    }

    /*@AuraEnabled(cacheable=true)
    public static List<Contact> getEmpleadosTareaGestor(Id recordId) {
        Id idOficinaGestora = [SELECT Account.CC_OficinaGestoraId__c FROM Case WHERE Id = :recordId AND Account.CC_OficinaGestoraId__r.RecordType.DeveloperName = 'CC_CentroCaixaBank'].Account.CC_OficinaGestoraId__c;

        if (idOficinaGestora == null) {
            return new List<Contact>();
        } else {
            return [SELECT Name, CC_Matricula__c FROM Contact WHERE AccountId = :idOficinaGestora AND CC_Inactivo__c = FALSE AND RecordType.DeveloperName = 'CC_Empleado' AND CC_Matricula__c != NULL];
        }
    }*/

    @AuraEnabled
    public static Map<String, Object> getMostrarBotonOficinaEmpleadoCaixaBank() {
        List<String> listaCanales = new List<String>();
        CC_Settings__c visibilidad = CC_Settings__c.getValues('CC_OperativaTrasladarRemitir');

        listaCanales.add(visibilidad.CC_Configuracion_2__c);
        listaCanales.add(visibilidad.CC_Configuracion_3__c);
        listaCanales.add(visibilidad.CC_Configuracion_4__c);
        listaCanales.add(visibilidad.CC_Configuracion_6__c);
        listaCanales.add(visibilidad.CC_Configuracion_7__c);
        listaCanales.add(visibilidad.CC_Configuracion_8__c);
        listaCanales.add(visibilidad.CC_Configuracion_9__c);
        listaCanales.add(visibilidad.CC_Configuracion_10__c);
        listaCanales.add(visibilidad.CC_Configuracion_11__c);
        listaCanales.add(visibilidad.CC_Configuracion_12__c);
        listaCanales.add(visibilidad.CC_Configuracion_13__c);
        listaCanales.add(visibilidad.CC_Configuracion_14__c);
        listaCanales.add(visibilidad.CC_Configuracion_15__c);
        listaCanales.add(visibilidad.CC_Configuracion_16__c);
        listaCanales.add(visibilidad.CC_Configuracion_17__c);
        listaCanales.add(visibilidad.CC_Configuracion_18__c);
        listaCanales.add(visibilidad.CC_Configuracion_19__c);
        listaCanales.add(visibilidad.CC_Configuracion_20__c);

        for (Integer i = 0; i < listaCanales.size(); i++) {
            if (listaCanales[i] == null) {
                listaCanales.remove(i);
            }
        }

        Boolean mostrarBoton = Boolean.valueOf(visibilidad.CC_Configuracion_1__c);

        Map<String, Object> resultado = new Map<String, Object>();
        resultado.put('canales', listaCanales);
        resultado.put('mostrarBoton', mostrarBoton);

        return resultado;
    }

    @AuraEnabled
    public static String obtenerCCLink(String motivoId) {
        // Realizar la consulta para obtener el campo CC_Link__c del MCC_Motivo__c
        CC_MCC__c motivo = [SELECT CC_Link__c FROM CC_MCC__c WHERE Id = :motivoId LIMIT 1];

        // Retornar el valor del campo CC_Link__c
        return motivo.CC_Link__c;
    }

    @AuraEnabled
    public static Boolean getPSGestorDocumentos() {
        List<PermissionSetAssignment> permiso = [SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() AND PermissionSet.Name = 'CC_Sdocs' LIMIT 1];
        return (!permiso.isEmpty()) ? true : false;
    }

    // @AuraEnabled
    // public static String llamadaWSOnboardingApex(String recordId, String nif) {
    //     if (nif == null || nif == '') {
    //         nif = [SELECT Account.CC_Numero_Documento__c FROM Case WHERE Id = :recordId LIMIT 1].Account.CC_Numero_Documento__c;
    //     }
    //     return CC_WS_Onboarding.recuperarClienteOnboarding(recordId, nif);
    // }

}