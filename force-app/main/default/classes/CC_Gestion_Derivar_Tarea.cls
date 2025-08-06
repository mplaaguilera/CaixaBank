public with sharing class CC_Gestion_Derivar_Tarea {
    
    public String recordId;
    public String asunto;
    public String fechaActividad;
    public String comentarios;
    public List<String> archivos;
    public Id oficinaDestino;
    public Boolean enviarTareaOficinaCliente;
    public Boolean crearTareaCitaGestor;
    public Contact gestorSeleccionadoBuscador;
    public Boolean otpDerivar;
    public Case caso;
    public Map<String, Object> textosMap;
    public CC_Settings__c consultarGestorPool;
    public Boolean configuracionGestorPool = false;
    public Boolean oficinaPpalDerivacionCSBD = false;
    public String mensaje = '';
    public String numOficinaGestor = '';
    public String matriculaGestor = '';
    public String numOficinaPpal = '';
    public String tipoPersona = '';
    public String segmentoCliente = '';
    public Boolean gestorNoEncontradoEnSalesforce = false;
    public String mensajeGestorNoEncontrado = '';
    public String cuentaFicticia;
    //se rellena en la logica de crear tarea
    public User gestorCliente;
    
    //Constructor
    public CC_Gestion_Derivar_Tarea(Map<String, Object> params) {
        this.recordId = (String) params.get('recordId');
        this.asunto = (String) params.get('asunto');
        this.fechaActividad = (String) params.get('fechaActividad');
        this.comentarios = (String) params.get('comentarios');
        this.archivos = (List<String>) params.get('archivos');
        this.oficinaDestino = (Id) params.get('oficinaDestino');
        this.enviarTareaOficinaCliente = (Boolean) params.get('enviarTareaOficinaCliente');
        this.crearTareaCitaGestor = (Boolean) params.get('crearTareaCitaGestor');
        this.gestorSeleccionadoBuscador = (Contact) params.get('gestorSeleccionadoBuscador');
        this.otpDerivar = (Boolean) params.get('otpDerivar');
        this.cuentaFicticia = (String) params.get('cuentaFicticia');
        
        this.caso = CC_Gestion_Derivar_Global.obtenerCaso(recordId);
        this.textosMap = CC_MetodosUtiles.getLOVNameValue(new List<String>{'Textos operativa Derivar'}, 'CC_Mensajes_Mostrar__c');
        this.consultarGestorPool = CC_Settings__c.getValues('CC_Configuracion_Cita_Rapida');
        this.configuracionGestorPool = Boolean.valueOf(consultarGestorPool?.CC_Configuracion_3__c);
        this.oficinaPpalDerivacionCSBD = this.caso?.Account?.AV_OficinaPrincipal__r?.Parent?.CC_Derivacion_CSBD__c;
        this.numOficinaGestor = this.caso?.Account?.AV_EAPGestor__r?.CC_Numero_Oficina__c;
        this.matriculaGestor = this.caso?.Account?.AV_EAPGestor__r?.CC_Matricula__c;
        this.numOficinaPpal = this.caso?.Account?.AV_OficinaPrincipal__r?.CC_Numero_Oficina__c;
        this.tipoPersona = this.caso?.Account?.CC_Tipo_Persona__c;
        this.segmentoCliente = this.caso?.Account?.AV_Segmento__c;
    }
    
    public Map<String, Object> crearTarea() {
        Map<String, Object> retorno = new Map<String, Object>();
        Boolean crearTareaVentas = false;
        Account oficinaPrincipal;
        List<Task> lstTaskDirectores = new List<Task>();
        
        CC_Gestion_Derivar_Global.inicializarVariables(this.caso, this.otpDerivar, retorno, this.textosMap, this.consultarGestorPool);
        
        String ambitoMotivo = (String) retorno.get('ambitoMotivo');
        Boolean imagin = (Boolean) retorno.get('imagin');
        Boolean ambitoCSBD = (Boolean) retorno.get('ambitoCSBD');
        CC_Lista_Valores__c listaValorTareaCita = [SELECT Id, CC_Activa__c, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Texto cita o tarea existe' LIMIT 1];
        Boolean existenTareasCitas = CC_Activity.identificarTareasCitasExistentes(caso, listaValorTareaCita);
        
        // Boolean crearTareaVentas = chequearAmbitoVentas(ambitoMotivo, imagin, ambitoCSBD);
        
        Task tareaGestorCaso = crearTareaGestorCaso();
        Task tareaGestorAccount;
        
        // Si el caso no tiene cuenta: US1182624: Derivar - Derivaciones sin cliente asociado
        if(caso.AccountId == null && caso.CC_No_Identificado__c) {
            String recordType;
            String numpersoGenerico;
            if (this.cuentaFicticia == 'F') {
                recordType = 'AV_AlertaComercial';
                tareaGestorAccount = crearTareaGestorAccountCasoSinCuenta(recordType);
                numpersoGenerico = (String) textosMap.get('Cuenta genérica F');
                tareaGestorAccount.WhatId = [SELECT Id FROM Account WHERE AV_NumPerso__c = :numpersoGenerico AND CC_Inactivo__c = FALSE LIMIT 1]?.Id;
            } else if (this.cuentaFicticia == 'J') {
                recordType = 'CIBE_AlertaComercialEMP';
                tareaGestorAccount = crearTareaGestorAccountCasoSinCuenta(recordType);
                numpersoGenerico = (String) textosMap.get('Cuenta genérica J');
                tareaGestorAccount.WhatId = [SELECT Id FROM Account WHERE AV_NumPerso__c = :numpersoGenerico AND CC_Inactivo__c = FALSE LIMIT 1]?.Id;
            }
            if(this.oficinaDestino != null) {
                tareaGestorAccount.AV_Center__c = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :this.oficinaDestino LIMIT 1]?.CC_Numero_Oficina__c;
            }
        }
        // Si el caso tiene cuenta, verificamos ámbitos y si es cliente o no.
        else{
            
            tareaGestorAccount = crearTareaGestorAccount();
            
            tareaGestorAccount.WhatId = caso.AccountId;
            if (ambitoMotivo == 'No clientes' || !caso.Account.AV_Cliente__c) {
                rellenarNoCliente(tareaGestorAccount, tareaGestorCaso, ambitoMotivo);
            }
            //Cliente IMAGIN
            else if (imagin && !ambitoCSBD) {
                switch on ambitoMotivo {
                    when 'Oficina' {
                        oficinaPrincipal = obtenerOficinaPrincipal();
                        rellenarTareaOficinaImagin(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'Ventas' {
                        if (caso.Account.CC_EsIntouch__c) {
                            rellenarTareaVentasImaginInTouch(tareaGestorAccount, tareaGestorCaso);
                        } else {
                            rellenarTareaVentasImagin(tareaGestorAccount, tareaGestorCaso);
                        }
                    }
                    when 'Cambio de oficina' {
                        lstTaskDirectores = rellenarTareaCambioOficinaImagin(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'Cambio de gestor' {
                        lstTaskDirectores = rellenarTareaCambioGestorImagin(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'Oficina física' {
                        oficinaPrincipal = obtenerOficinaPrincipal();
                        rellenarTareaOficinaFisicaImagin(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'CBP' {
                        oficinaPrincipal = obtenerOficinaPrincipal();
                        rellenarTareaCBP(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'Hub Imagin' {
                        rellenarTareaHubImagin(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'Documentación' {
                        if(caso.Origin != 'Phone' && caso.Origin != 'Teléfono'){
                            rellenarTareaAmbitoNullImagin(tareaGestorAccount, tareaGestorCaso, null);
                            crearTareaVentas = chequearAmbitoVentas(ambitoMotivo, imagin, ambitoCSBD);
                        } else {
                            rellenarTareaDocumentacionImagin(tareaGestorAccount, tareaGestorCaso);
                        }
                    }
                    when 'Colectivo vulnerable'{
                        oficinaPrincipal = obtenerOficinaPrincipal();
                        rellenarTareaColectivosVulnerables(tareaGestorAccount, tareaGestorCaso);
                    }
                    //ambitoMotivo es null o ''
                    when else {
                        rellenarTareaAmbitoNullImagin(tareaGestorAccount, tareaGestorCaso, ambitoMotivo);
                        crearTareaVentas = chequearAmbitoVentas(ambitoMotivo, imagin, ambitoCSBD);
                    }
                }
                //Cliente CAIXA OR ambitoCSBD
            } else if (!imagin || (ambitoCSBD && !this.oficinaPpalDerivacionCSBD) || (ambitoCSBD && imagin)) {
                switch on ambitoMotivo {
                    when 'Cambio de gestor' {
                        lstTaskDirectores = rellenarTareaCambioGestor(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'Cambio de oficina' {
                        lstTaskDirectores = rellenarTareaCambioOficina(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'CBP' {
                        oficinaPrincipal = obtenerOficinaPrincipal();
                        rellenarTareaCBP(tareaGestorAccount, tareaGestorCaso);
                    }
                    when 'Oficina física' {
                        if (caso.Account.CC_EsIntouch__c) {
                            oficinaPrincipal = obtenerOficinaPrincipal();
                            rellenarTareaOficinaFisica(tareaGestorAccount, tareaGestorCaso);
                        }else{
                            crearTareaVentas = chequearAmbitoVentas(ambitoMotivo, imagin, ambitoCSBD);
                        }
                    }
                    when 'Colectivo vulnerable'{
                        oficinaPrincipal = obtenerOficinaPrincipal();
                        rellenarTareaColectivosVulnerables(tareaGestorAccount, tareaGestorCaso);
                    }
                    when else {
                        crearTareaVentas = chequearAmbitoVentas(ambitoMotivo, imagin, ambitoCSBD);
                    }
                }
            }
        }
        
        if(crearTareaVentas) {
            rellenarTareaAmbitoVentas(tareaGestorAccount, tareaGestorCaso, mensaje);
        }
        
        // US1182624: Derivar - Derivaciones sin cliente asociado: Se añade a la validación: "|| caso.CC_No_Identificado__c"
        // if(this.caso?.Contact?.AccountId != null){
            if(this.caso?.Contact?.AccountId != null || caso.CC_No_Identificado__c){
                if(!existenTareasCitas){
                    insertarRegistros(ambitoMotivo, tareaGestorAccount, tareaGestorCaso, lstTaskDirectores);
                }else{
                    retorno.put('textoTareaCitaCreada', listaValorTareaCita.CC_Mensajes_Mostrar__c);
                    retorno.put('existeTareaCitaCreada', true);
                }
            } else {
                retorno.put('contactoSinAccount', (String) this.textosMap.get('Contacto sin account en creacion tarea'));
            }
            
            retorno.put('mensaje', this.mensaje);
            retorno.put('cuenta', oficinaPrincipal);
            
            retorno.put('gestorNoEncontradoEnSalesforce', this.gestorNoEncontradoEnSalesforce);
            retorno.put('mensajeGestorNoEncontrado', this.mensajeGestorNoEncontrado);
            return retorno;
        }
        
        public void insertarRegistros(String ambitoMotivo, Task tareaGestorAccount, Task tareaGestorCaso, List<Task> lstTaskDirectores){
            List<Task> lstTask = new List<Task>();
            Set<Id> tareasCreadasId = new Set<Id>();
            if(this.gestorCliente != null) {
                tareaGestorAccount.OwnerId = this.gestorCliente.Id;
            }
            
            if(ambitoMotivo != 'No clientes') {
                tareaGestorAccount.WhoId = caso.ContactId;
                tareaGestorCaso.WhoId = caso.ContactId;
            }
            if(!lstTaskDirectores.isEmpty()) {
                insert lstTaskDirectores;
                for(Task tarea : lstTaskDirectores){
                    tareasCreadasId.add(tarea.Id);
                }
            } else {
                lstTask.add(tareaGestorAccount);
            }
            
            lstTask.add(tareaGestorCaso);
            insert lstTask;
            
            if(tareaGestorAccount != null && lstTaskDirectores.isEmpty()) {
                tareasCreadasId.add(tareaGestorAccount.Id);
            }
            
            if(!tareasCreadasId.isEmpty()) {
                insertarArchivos(tareasCreadasId);
            }
            
        }
        
        public void insertarArchivos(Set<Id> taskDirectoresId){
            List<Task> taskAfter = [SELECT Id, OwnerId FROM Task WHERE Id IN :taskDirectoresId];
            if(this.archivos != null && !taskAfter.isEmpty()) {
                List<ContentVersion> files = [
                SELECT Title, VersionData, FileExtension, OwnerId 
                FROM ContentVersion 
                WHERE IsLatest = TRUE AND
                Id IN :this.archivos
            ];
                List <Attachment> at = new List <Attachment>();
                for(ContentVersion file : files) {
                    for(Task tarea : taskAfter) {
                        Attachment attachment = new Attachment(
                            OwnerId = tarea.OwnerId,
                        ParentId = tarea.Id,
                        Name = file.Title + '.' + file.FileExtension,
                        Body = file.VersionData
                            );
                        at.add(attachment);
                    }
                }
                insert at;
            }
        }
        
        public Task crearTareaGestorCaso(){
            Id recordTypeTareaCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            Date fechaActividadDate = Date.valueOf(fechaActividad);
            Map<String, Object> paramsGestorCaso = new Map<String, Object>{
                'recordTypeTarea' => recordTypeTareaCC,
                'asunto' => this.asunto,
                'comentarios' => this.comentarios,
                'fechaActividad' => fechaActividadDate,
                'whatId' => this.caso.Id,
                'ownerId' => this.caso.ownerId,
                'type' => 'Tarea Oficina'
            };
            
            return CC_Activity.crearTareaGestor( paramsGestorCaso);
        }
        
        // US1182624: Derivar - Derivaciones sin cliente asociado
        public Task crearTareaGestorAccountCasoSinCuenta(String recordType){
            Id recordTypeTareaAV = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', recordType);
            Map<String, Object> paramsGestorAccount = new Map<String, Object>{
                'recordTypeTarea' => recordTypeTareaAV,
                'asunto' => this.asunto,
                'comentarios' => this.comentarios,
                'fechaActividad' => Date.Today().addDays(7),
                'avCaseId' => this.caso.Id,
                'type' => 'Tarea gestor'
            };
            
            return CC_Activity.crearTareaGestor(paramsGestorAccount);
        }
        
        public Task crearTareaGestorAccount(){
            CC_Settings__c settings = CC_Settings__c.getValues('CC_SegmentosTarea');
            String segmentos = String.valueOf(settings);
            String recordType = this.tipoPersona == 'J' && segmentos.contains(this.segmentoCliente) ? 'CIBE_AlertaComercialEMP' : 'AV_AlertaComercial';
            Id recordTypeTareaAV = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', recordType);
            Map<String, Object> paramsGestorAccount = new Map<String, Object>{
                'recordTypeTarea' => recordTypeTareaAV,
                'asunto' => this.asunto,
                'comentarios' => this.comentarios,
                'fechaActividad' => Date.Today().addDays(7),
                'avCaseId' => this.caso.Id,
                'type' => 'Tarea gestor'
            };
            
            return CC_Activity.crearTareaGestor(paramsGestorAccount);
        }
        
        public Task crearTareaDirector(Contact director, User gestorCliente){
            String recordType = this.tipoPersona == 'J' && this.segmentoCliente == 'PIM' ? 'CIBE_AlertaComercialEMP' : 'AV_AlertaComercial';
            Id recordTypeTareaAV = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', recordType);
            User generico = CC_MetodosUtiles.buscarGestor('generico');
            Map<String, Object> params = new Map<String, Object>{
                'recordTypeTarea' => recordTypeTareaAV,
                'asunto' => asunto,
                'comentarios' => comentarios,
                'recordId' => this.caso.Id,
                'accountId' => this.caso.AccountId,
                'numeroOficina' => director.Account.CC_Numero_Oficina__c,
                'gestorClienteId' => gestorCliente != null ? gestorCliente.Id : generico.Id
            };
            
            return CC_Activity.crearTareaDirector(params);
        }
        
        
        public List<Task> sumarTareaDirector(List<Id> oficinas){
            
            List<Task> lstTaskDirectores = new List<Task>();
            List<Contact> directoresOficina = [
            SELECT Id, AccountId, Account.CC_Numero_Oficina__c, CC_Matricula__c 
            FROM Contact 
            WHERE AV_DescFuncion__c = 'DIRECCION' 
            AND CC_Inactivo__c = false 
            AND AccountId IN :oficinas
        ];
            
            List<String> matriculasGestor = new List<String>();
            for(Contact director : directoresOficina) {
                matriculasGestor.add(director.CC_Matricula__c);
            }
            
            Map<String, User> gestores = CC_MetodosUtiles.buscarGestoresPorMatricula(matriculasGestor);
            for(Contact director : directoresOficina) {
                if(gestores.containsKey(director.CC_Matricula__c)) {
                    User gestorCliente = gestores.get(director.CC_Matricula__c);
                    Task tareaDirector = crearTareaDirector(director, gestorCliente);
                    lstTaskDirectores.add(tareaDirector);
                } else {
                    Task tareaDirector = crearTareaDirector(director, null);
                    lstTaskDirectores.add(tareaDirector);
                }
            }
            
            return lstTaskDirectores;
        }
        
        public Boolean chequearAmbitoVentas(String ambitoMotivo, Boolean imagin, Boolean ambitoCSBD){
            Boolean crearTareaVentas = false;
            //CLIENTE IMAGIN
            if(imagin && !ambitoCSBD) {
                List<String> ambitos = new List<String>{'Accionistas','Mecanismo de firma','Argos General','Argos Xpays','Caso a Fraude','Phising/Smishing/Malware','Documentación'};
                if(String.isBlank(ambitoMotivo) ||ambitos.contains(ambitoMotivo) ) {
                    if(this.configuracionGestorPool) {
                        crearTareaVentas = true;
                    }
                }
            }
            //CLIENTE CAIXA OR ambitoCSBD
            else if(!imagin || (ambitoCSBD && !this.oficinaPpalDerivacionCSBD) || (ambitoCSBD && imagin)) {
                List<String> ambitos = new List<String>{'Ventas', 'Oficina','Mecanismo de firma','Accionistas','Argos General','Argos Xpays','Caso a Fraude','Phising/Smishing/Malware'};
                if(
                    String.isBlank(ambitoMotivo) ||
                    ambitos.contains(ambitoMotivo) ||
                    ambitoCSBD ||
                    (ambitoMotivo == 'Oficina física' && !this.caso.Account.CC_EsIntouch__c) ||
                    (ambitoMotivo == 'Documentación' && this.caso.CBK_Case_Extension_Id__r.CC_Documentacion__c == false)
                ) {
                    crearTareaVentas = true;
                }
            }
            return crearTareaVentas;
        }
        
        public void rellenarNoCliente(Task tareaGestorAccount, Task tareaGestorCaso, String ambitoMotivo){
            if(this.oficinaDestino != null) {
                tareaGestorAccount.AV_Center__c = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = :this.oficinaDestino LIMIT 1].CC_Numero_Oficina__c;
            }
            this.gestorCliente = CC_MetodosUtiles.buscarGestor('generico');
            tareaGestorCaso.Type = 'Tarea Oficina';
            if(ambitoMotivo == 'No clientes') {
                String numpersoGenerico = (String) this.textosMap.get('Cuenta generica');
                tareaGestorAccount.WhatId = [SELECT Id FROM Account WHERE AV_NumPerso__c = :numpersoGenerico AND CC_Inactivo__c = FALSE LIMIT 1]?.Id;
                this.mensaje = (String) this.textosMap.get('Mensaje derivar no clientes');
            } else {
                this.mensaje = (String) this.textosMap.get('Mensaje caixabank oficina cliente else');
            }
        }
        
        public void rellenarTareaOficinaImagin(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => this.numOficinaPpal,
                'type' => 'Tarea Oficina',
                'mensajeKey' => 'Mensaje imagin oficina',
                'numeroGestor' => 'generico'
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }
        
        public void rellenarTareaVentasImaginInTouch(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => this.numOficinaGestor,
                'type' => 'Tarea gestor',
                'mensajeKey' => 'Mensaje imagin ventas',
                'numeroGestor' => this.matriculaGestor
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }
        
        public void rellenarTareaVentasImagin(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => (String) this.textosMap.get('Hub sales'),
                'type' => 'Tarea Hub Sales',
                'mensajeKey' => 'Mensaje imagin ventas',
                'numeroGestor' => 'generico'
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }
        
        public List<Task> rellenarTareaCambioOficinaImagin(Task tareaGestorAccount, Task tareaGestorCaso){
            List<Task> lstTaskDirectores = sumarTareaDirector(new List<String>{this.oficinaDestino});
            tareaGestorCaso.Type = 'Tarea Cambio Oficina';
            this.mensaje = (String) this.textosMap.get('Mensaje imagin cambio de oficina');
            return lstTaskDirectores;
        }
        
        public List<Task> rellenarTareaCambioGestorImagin(Task tareaGestorAccount, Task tareaGestorCaso){
            List<Task> lstTaskDirectores = new List<Task>();
            if (caso.Account.AV_EAPGestor__r.AV_Pool__c && this.configuracionGestorPool) {
                lstTaskDirectores = sumarTareaDirector(new List<String>{this.caso.Account.AV_OficinaPrincipal__c});
                this.mensaje = (String) this.textosMap.get('Mensaje caixabank cambio de gestor'); //TODO: verificar en codigo original
                tareaGestorCaso.Type = 'Tarea Cambio Gestor';
            } else {
                Map<String, Object> params = new Map<String, Object>{
                    'center' => (String) this.textosMap.get('Hub gestion'),
                    'type' => 'Tarea Cambio Gestor',
                    'mensajeKey' => 'Mensaje imagin cambio de gestor',
                    'numeroGestor' => 'generico'
                };
                rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
            }
            return lstTaskDirectores;
        }
        
        public void rellenarTareaOficinaFisicaImagin(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => this.numOficinaPpal,
                'type' => 'Tarea Oficina Física',
                'mensajeKey' => 'Toast oficina fisica',
                'numeroGestor' => 'generico'
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }
        
        public void rellenarTareaCBP(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => this.numOficinaPpal,
                'type' => 'Tarea Oficina',
                'mensajeKey' => 'Mensaje CBP',
                'numeroGestor' => 'generico'
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }

        public void rellenarTareaColectivosVulnerables(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => this.numOficinaPpal,
                'type' => 'Tarea Oficina',
                'mensajeKey' => 'Modal final colectivo vulnerable',
                'numeroGestor' => 'generico'
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }
        
        public void rellenarTareaHubImagin(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => (String) this.textosMap.get('Hub Imagin'),
                'type' => 'Tarea Hub Imagin',
                'mensajeKey' => 'Toast Hub Imagin',
                'numeroGestor' => 'generico'
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }
        
        public void rellenarTareaDocumentacionImagin(Task tareaGestorAccount, Task tareaGestorCaso){
            if (!caso.CBK_Case_Extension_Id__r.CC_Documentacion__c) {
                Map<String, Object> params = new Map<String, Object>{
                    'center' => (String) this.textosMap.get('Hub gestion'),
                    'type' => 'Tarea Hub Gestión',
                    'mensajeKey' => 'Toast Hub Gestión documentacion',
                    'numeroGestor' => 'generico'
                };
                rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
            }
        }
        
        public void rellenarTareaAmbitoNullImagin(Task tareaGestorAccount, Task tareaGestorCaso, String ambitoMotivo){
            if (String.isBlank(ambitoMotivo) ) {
                if (caso.Account.CC_EsIntouch__c) {
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => this.numOficinaGestor,
                        'type' => 'Tarea gestor',
                        'mensajeKey' => 'Mensaje imagin else',
                        'numeroGestor' => this.matriculaGestor
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                    
                } else {
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => (String) this.textosMap.get('Hub gestion'),
                        'type' => 'Tarea Hub Gestión',
                        'mensajeKey' => 'Mensaje imagin else',
                        'numeroGestor' => 'generico'
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                }
            }
        }
        
        public List<Task> rellenarTareaCambioGestor(Task tareaGestorAccount, Task tareaGestorCaso){
            List<Task> lstTaskDirectores = sumarTareaDirector(new List<String>{this.caso.Account.AV_OficinaPrincipal__c, this.oficinaDestino});
            this.mensaje = (String) this.textosMap.get('Mensaje caixabank cambio de gestor');
            tareaGestorCaso.Type = 'Tarea Cambio Gestor';
            return lstTaskDirectores;
        }
        
        public List<Task> rellenarTareaCambioOficina(Task tareaGestorAccount, Task tareaGestorCaso){
            List<Task> lstTaskDirectores = sumarTareaDirector(new List<String>{this.oficinaDestino});
            this.mensaje = (String) this.textosMap.get('Mensaje caixabank cambio de oficina');
            tareaGestorCaso.Type = 'Tarea Cambio Oficina';
            return lstTaskDirectores;
        }
        
        public void rellenarTareaOficinaFisica(Task tareaGestorAccount, Task tareaGestorCaso){
            Map<String, Object> params = new Map<String, Object>{
                'center' => this.numOficinaPpal,
                'type' => 'Tarea Oficina Física',
                'mensajeKey' => 'Toast oficina fisica',
                'numeroGestor' => 'generico'
            };
            rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
        }
        
        public void rellenarTareaAmbitoVentas(Task tareaGestorAccount, Task tareaGestorCaso, String mensaje){
            Map<String, String> gestorGenerico = CC_MetodosUtiles.buscarGestorGenerico();
            String nombreGestorGenerico = gestorGenerico.get('nombre').toString();
            if(this.caso.Account.AV_EAPGestor__c != null && this.caso.Account.AV_EAPGestor__r.Name != nombreGestorGenerico) {
                if(this.crearTareaCitaGestor && this.caso.Account.AV_EAPGestor__r.AV_Pool__c && this.configuracionGestorPool) {
                    String numCentro = obtenerNumeroOficinaCartera();
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => numCentro,
                        'type' => 'Tarea Oficina',
                        'mensajeKey' => 'Mensaje caixabank cita tarea gestor',
                        'numeroGestor' => 'generico'
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                } else if(this.crearTareaCitaGestor && (!caso.Account.AV_EAPGestor__r.AV_Pool__c || !this.configuracionGestorPool)) {
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => this.numOficinaGestor,
                        'type' => 'Tarea gestor',
                        'mensajeKey' => 'Mensaje caixabank cita tarea gestor',
                        'numeroGestor' => this.matriculaGestor
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                } else if(this.gestorSeleccionadoBuscador != null) {
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => this.gestorSeleccionadoBuscador.CC_Numero_Oficina__c,
                        'type' => 'Tarea gestor',
                        'mensajeKey' => 'Mensaje caixabank cita tarea gestor else',
                        'numeroGestor' => this.gestorSeleccionadoBuscador.CC_Matricula__c
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                } else if(oficinaDestino != null) {
                    String numCentro =  obtenerNumeroOficinaDestino();
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => numCentro,
                        'type' => 'Tarea Oficina',
                        'mensajeKey' => 'Mensaje caixabank cita tarea gestor else',
                        'numeroGestor' => 'generico'
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                }
            } else {
                if(this.enviarTareaOficinaCliente) {
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => this.numOficinaPpal,
                        'type' => 'Tarea Oficina',
                        'mensajeKey' => 'Mensaje caixabank oficina cliente',
                        'numeroGestor' => 'generico'
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                } else {
                    String numCentro =  obtenerNumeroOficinaDestino();
                    Map<String, Object> params = new Map<String, Object>{
                        'center' => numCentro,
                        'type' => 'Tarea Oficina',
                        'mensajeKey' => 'Mensaje caixabank oficina cliente else',
                        'numeroGestor' => 'generico'
                    };
                    rellenarValoresComunes(params, tareaGestorAccount, tareaGestorCaso);
                    
                }
            }
        }
        
        public void rellenarValoresComunes(Map<String, Object> params, Task tareaGestorAccount, Task tareaGestorCaso)
        {
            String center = (String) params.get('center');
            String type = (String) params.get('type');
            String mensajeKey = (String) params.get('mensajeKey');
            String numeroGestor = (String) params.get('numeroGestor'); //generico, U01
            //String comentarios = (String) params.get('comentarios');
            this.mensaje = (String) this.textosMap.get(mensajeKey);
            this.gestorCliente = CC_MetodosUtiles.buscarGestor(numeroGestor); //U01555555
            //tareaGestorCaso.Description = comentarios != null ? comentarios : '';
            //verificar si el gestor con U01 se ha encontrado como usuario en Salesforce
            if(numeroGestor != 'generico' && CC_MetodosUtiles.gestorEsGenerico(this.gestorCliente)) {
                //Poner el centro de la tarea de AV a la Oficina del gestor.
                center = this.numOficinaGestor;
                type = 'Tarea Oficina';
                tareaGestorCaso.Description = 'Se ha intentado crear la tarea a un gestor que no se encontró como usuario. El U01 recibido es: ' + numeroGestor;
                this.gestorNoEncontradoEnSalesforce = true;
                this.mensajeGestorNoEncontrado = (String) this.textosMap.get('Toast gestor no encontrado en Salesforce');
            }
            
            tareaGestorAccount.AV_Center__c = center;
            tareaGestorCaso.Type = type;
        }
        
        public Account obtenerOficinaPrincipal(){
            List<Account> oficinas = [
            SELECT Id, Name, RecordType.DeveloperName, CC_Numero_Oficina__c 
            FROM Account 
            WHERE Id = :this.caso.Account.AV_OficinaPrincipal__c 
            AND RecordType.DeveloperName = 'CC_CentroCaixaBank' 
            LIMIT 1
        ];
            return oficinas.isEmpty() ? null : oficinas[0];
        }
        
        public String obtenerNumeroOficinaDestino(){
            if(this.oficinaDestino != null) {
                List<Account> oficina = [SELECT CC_Numero_Oficina__c FROM Account WHERE Id = : this.oficinaDestino LIMIT 1];
                return oficina.isEmpty() ? '' : oficina[0].CC_Numero_Oficina__c;
            }
            return '';
        }
        
        public String obtenerNumeroOficinaCartera(){
            List<AV_BookMember__c> bookmember = [
            SELECT Id, AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c 
            FROM AV_BookMember__c 
            WHERE AV_Cliente__c = :this.caso.AccountId 
            AND AV_Cartera__r.AV_TipoCartera__c = 'BPA' 
            AND AV_Cartera__r.AV_Activa__c = 'S'
        ];
            return bookmember.isEmpty() ? '' : bookmember[0].AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c;
        }
        
    }