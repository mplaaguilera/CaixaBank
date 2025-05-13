public with sharing class CSBD_DetectarOportunidadesSimilares {

    public static final String ERROR_DOCUMENT_ID_REQUEST_PRESCRIBER_ID = 'documentId y requestPrescriberId son requeridos';
    public static final String ERROR_AL_OBTENER_OPORTUNIDADES = 'Error al obtener las oportunidades';
    public static final String OPORTUNIDAD_ENCONTRADA = 'Se ha encontrado un Lead existente';
    public static final String RECORD_TYPE_NAME_HIPOTECA = 'CSBD_Hipoteca';    

    public List<String> documentsIds;
    public String requestPrescriberId;
    public Opportunity oportunidadIdentificada;
    public Boolean esFacilitea;
    public Boolean esPHD;
    public CSBD_IdentificarOppsPHDSettingManager settingManager;
    public String origenLeadExistente;

    public CSBD_DetectarOportunidadesSimilares(List<String> documentsIds, String requestPrescriberId, String origenLeadExistente) {
        this.documentsIds = documentsIds;
        this.requestPrescriberId = requestPrescriberId;
        this.settingManager = CSBD_IdentificarOppsPHDSettingManager.getInstance();
        this.origenLeadExistente = origenLeadExistente;
    }

    public static CSBD_DetectarOportunidadesSimilares getInstance(List<String> documentsIds, String requestPrescriberId, String origenLeadExistente) {
        return new CSBD_DetectarOportunidadesSimilares(documentsIds, requestPrescriberId, origenLeadExistente);
    }

    public Map<String, Object> buscarOportunidadSimilares() {
        Map<String, Object> respuesta = new Map<String, Object>();
        if(this.documentsIds != null && !this.documentsIds.isEmpty()) {
                    
            try{
                Integer days = this.settingManager.getDias();
                List<String> stagesList = this.settingManager.getStagesList();
                Boolean envioCorreo = this.settingManager.getEnvioCorreo();
                List<String> canalesProcedenciaList = this.settingManager.getCanalesProcedenciaList();
                List<String> origenList = this.settingManager.getOrigenList();

                Id recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', RECORD_TYPE_NAME_HIPOTECA);
        
                List<Opportunity> oportunidades = [
                    SELECT Id,
                        Name, 
                        LastModifiedDate, 
                        IsClosed, 
                        CSBD_Now_Origen__c, 
                        CSBD_Canal__c,
                        CSBD_Parent_Id__r.CSBD_Now_Origen__c, 
                        CSBD_Ultima_Etapa_Ventas__c, 
                        CSBD_Contact__c, 
                        CSBD_Identificador__c,
                        OwnerId, 
                        Owner.Email, 
                        Owner.ManagerId, 
                        Owner.Manager.Email, 
                        Owner.Manager.ManagerId, 
                        Owner.Manager.Manager.Email, 
                        CSBD_Empresa_Proveedora__c
                    FROM Opportunity 
                    WHERE (CSBD_Now_NIF__c IN :this.documentsIds OR 
                        CSBD_ContactoTitular1__r.CC_Numero_Documento__c IN :this.documentsIds OR 
                        CSBD_ContactoTitular2__r.CC_Numero_Documento__c IN :this.documentsIds) 
                    AND RecordTypeId = :recordTypeId 
                    AND (IsClosed = false OR 
                        (IsClosed = true AND StageName NOT IN :stagesList AND LastModifiedDate > :Date.today().addDays(-days))) 
                    AND (CSBD_Canal__c IN :canalesProcedenciaList OR 
                        CSBD_Now_Origen__c IN :origenList OR 
                        CSBD_Parent_Id__r.CSBD_Now_Origen__c IN :origenList)
                    ORDER BY LastModifiedDate DESC
                ];

                if(!oportunidades.isEmpty()) {
                    //aplicar la lógica para sabe cuál identifico...              
                    Opportunity plataformaHipotecaria = null;
                    Opportunity faciliteaOpp = null;       
                    
                    for(Opportunity opp : oportunidades) {
                        // Primera prioridad: Oportunidad de Plataforma Hipotecaria
                        if(canalesProcedenciaList.contains(opp.CSBD_Canal__c)) {
                            plataformaHipotecaria = seleccionarOportunidadPrioritaria(opp, plataformaHipotecaria);
                        }
                        // Segunda prioridad: Oportunidad de Facilitea
                        else if(origenList.contains(opp.CSBD_Now_Origen__c) || 
                           (opp.CSBD_Parent_Id__r != null && origenList.contains(opp.CSBD_Parent_Id__r.CSBD_Now_Origen__c))) {
                            faciliteaOpp = seleccionarOportunidadPrioritaria(opp, faciliteaOpp);
                        }
                    }
                    
                    // Asignar la oportunidad identificada según la prioridad
                    this.oportunidadIdentificada = plataformaHipotecaria != null ? plataformaHipotecaria : faciliteaOpp;
                    //determinar si es PHD o Facilitea
                    this.esPHD = canalesProcedenciaList.contains(this.oportunidadIdentificada?.CSBD_Canal__c);
                    this.esFacilitea = origenList.contains(this.oportunidadIdentificada?.CSBD_Now_Origen__c) || 
                        (this.oportunidadIdentificada?.CSBD_Parent_Id__r != null && origenList.contains(this.oportunidadIdentificada?.CSBD_Parent_Id__r.CSBD_Now_Origen__c));
                    
                    //reabrir/marcar opp identificada
                    procesarOportunidadIdentificada();                    
                    //enviar correo al owner, manager y director si está habilitado
                    if(envioCorreo) {
                        enviarCorreoInformativo();
                    }
                    
                    String origenLead = this.esFacilitea ? 
                        CSBD_IdentificarOppsPHDSettingManager.ORIGEN_FACILITEACASAS : 
                        CSBD_IdentificarOppsPHDSettingManager.ORIGEN_PLATAFORMA_HIPOTECARIA;
                    respuesta.put('opportunityId', this.oportunidadIdentificada.Id);
                    respuesta.put('opportunityName', this.oportunidadIdentificada.CSBD_Identificador__c);
                    respuesta.put('success', true);
                    respuesta.put('existLead', true);
                    respuesta.put('rejectReason', OPORTUNIDAD_ENCONTRADA + ' desde ' + origenLead);
                    respuesta.put('origenLead', origenLead);
                }else{
                    respuesta.put('success', true);
                    respuesta.put('existLead', false);
                }
            }catch(Exception e){
                respuesta.put('error', ERROR_AL_OBTENER_OPORTUNIDADES + ': ' + e.getMessage() + e.getStackTraceString());
                respuesta.put('success', false);
            }
        }else{
            respuesta.put('error', ERROR_DOCUMENT_ID_REQUEST_PRESCRIBER_ID);
            respuesta.put('success', false);
        }
        return respuesta;
    }

    public void procesarOportunidadIdentificada(){
        //hay que marcar la opp y poner la fecha en la que se recibio la peticion
        this.oportunidadIdentificada.CSBD_FechaEntradaUltimoLead__c = Datetime.now();
       //Informar un campo origen de la peticion duplicada
        this.oportunidadIdentificada.CSBD_OrigenLeadExistente__c = this.origenLeadExistente;

        if(this.esFacilitea){
            //Informarlo solo para las de facilitea
            this.oportunidadIdentificada.CSBD_MostrarAviso__c = 'Nueva búsqueda en facilitea casa';
        }
     
        //si la oportunidad esta cerrada, hay que reabrirla
        List<Task> tareas = new List<Task>();
        if(this.oportunidadIdentificada.IsClosed){          
            //Reabrirla con el propietario anterior, con la etapa de ventas anterior y con el estado activo
            this.oportunidadIdentificada = CSBD_Opportunity.reactivarOportunidad(this.oportunidadIdentificada, null, false, false);           
            tareas.add(creacionTareaReactivacion());
        }
        
        tareas.add(creacionTareaIdentificacion());
        if(!tareas.isEmpty()){
            insert tareas;
        }
 
        update this.oportunidadIdentificada;
     }

     public void enviarCorreoInformativo(){        
        String nombreBuzonSalida = this.oportunidadIdentificada.CSBD_Empresa_Proveedora__c == 'imaginBank' ? 'CSBD - ImaginBank' : 'CSBD - CaixaBank';
        String plantillaName = this.esFacilitea ? this.settingManager.getPlantillaCorreoFacilitea() : this.esPHD ? this.settingManager.getPlantillaCorreoPHD() : '';
        if(String.isBlank(plantillaName)){
            CSBD_Activity.crearActividad(
                this.oportunidadIdentificada.Id,
                'Error enviando correo automatico de duplicado',
                'Completed',
                'Error enviando correo automatico de duplicado porque no se ha configurado la plantilla de correo',
                 null
            );
        }
        Id plantilla = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :plantillaName LIMIT 1]?.Id;
        Id buzonSalida = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :nombreBuzonSalida LIMIT 1]?.Id;
        if (plantilla == null || buzonSalida == null) {
            CSBD_Activity.crearActividad(this.oportunidadIdentificada.Id,
                'Error enviando correo automatico de duplicado',
                'Completed',
                'Error enviando correo automatico de duplicado porque no se ha encontrado la plantilla de correo o el buzon de salida',
                null
            );
        }else{
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();    
            List<String> destinatarios = new List<String>{this.oportunidadIdentificada.Owner.Email};

            if(this.oportunidadIdentificada.Owner.ManagerId != null){
                destinatarios.add(this.oportunidadIdentificada.Owner.Manager.Email);
            }
            if(this.oportunidadIdentificada.Owner.Manager.ManagerId != null){
                destinatarios.add(this.oportunidadIdentificada.Owner.Manager.Manager.Email);
            }
            Messaging.SingleEmailMessage correoEnviar = CSBD_MetodosComunes.enviarCorreoReturnCorreo(
                correo,
                this.oportunidadIdentificada.Id, //opp Id
                this.oportunidadIdentificada.CSBD_Contact__c, //WhoId
                buzonSalida, //nombre buzon salida
                plantilla, //nombre plantilla correo
                destinatarios //destinatarios
            );
            if (correoEnviar != null) {
                List<Messaging.SendEmailResult> resultadoEnvioCorreo = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correoEnviar});
                if(!resultadoEnvioCorreo.isEmpty() && !resultadoEnvioCorreo[0].isSuccess()){  
                    CSBD_Activity.crearActividad(this.oportunidadIdentificada.Id,
                        'Error enviando correo automatico de duplicado',
                        'Completed',
                        'Error enviando correo automatico de duplicado',
                        null
                    );
                }
            }
        }
     }

    private Opportunity seleccionarOportunidadPrioritaria(Opportunity oppActual, Opportunity oppAlmacenada) {
        if(oppAlmacenada == null) {
            return oppActual;
        }        
        // Si la oportunidad actual está abierta y la almacenada está cerrada, priorizar la actual
        if(!oppActual.IsClosed && oppAlmacenada.IsClosed) {
            return oppActual;        }
        
        // Si ambas están abiertas o ambas cerradas, priorizar la más reciente
        if(oppActual.IsClosed == oppAlmacenada.IsClosed && 
           oppActual.LastModifiedDate > oppAlmacenada.LastModifiedDate) {
            return oppActual;
        }
        
        return oppAlmacenada;
    }

    private Task creacionTareaReactivacion(){
        String descripcion = 'Esta oportunidad ha sido reactivada porque se ha identificado como Lead existente desde el origen ' + this.origenLeadExistente + '. Los números de documento recibidos son: ' + String.join(this.documentsIds, ', ');
        return CSBD_Activity.crearActividadReturn(
            new Task(), 
            this.oportunidadIdentificada.Id, 
            'Reactivación', 
            'Completed', 
            'Reactivación de oportunidad por Lead existente', 
            descripcion, 
            null
        );     
    }

    private Task creacionTareaIdentificacion(){
        String descripcion = 'Esta oportunidad ha sido identificada como Lead existente desde el origen ' + this.origenLeadExistente + '. Los números de documento recibidos son: ' + String.join(this.documentsIds, ', ');
        Map<String, String> camposActividad = new Map<String, String>();
        if(String.isNotBlank(this.requestPrescriberId)){
            camposActividad.put('AV_ExternalID__c', this.requestPrescriberId);
        }
        return CSBD_Activity.crearActividadReturn(
            new Task(), 
            this.oportunidadIdentificada.Id, 
            'Identificación de Lead existente', 
            'Completed', 
            'Identificación de Lead existente desde ' + this.origenLeadExistente,          
            descripcion, 
            camposActividad
        );            
    }
    
}