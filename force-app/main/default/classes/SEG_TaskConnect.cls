public with sharing class SEG_TaskConnect {

    @future(callout=true)
    public static void envioComunicacionTrigger(Map<Id, String> mapCasos) {
        if (!mapCasos.isEmpty()) {
            for (Id idCaso : mapCasos.keySet()) {
                envioComunicacion(idCaso, mapCasos.get(idCaso));
            }
        }
    }

    public static void envioComunicacion(id casoid, String tipoEnvio) {
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'SEG_TaskConnect';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;

        Case casoSeg = [SELECT Id,SEG_Numero_centro__c, CaseNumber, SEG_NIF_peticionario__c, Account.Name, Subject, SEG_ClasificacionRapida__r.Name, 
        CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name, Status, ClosedDate, SEG_Case_Owner__c, SEG_PropAnteriorGrupo__c, 
        SEG_Fechayhoracreacion__c, LastModifiedDate, SEG_Observaciones__c, SEG_Zona__c, SEG_Organizacion__c, SEG_N_operaciones_CSO__c, CC_Owner_Anterior__r.Name, 
        SEG_Subestado__c, SEG_Grupo__r.Name, Priority, OwnerId FROM Case WHERE Id=: casoid LIMIT 1];

        List<CaseMilestone> milestone = [SELECT id, TargetDate FROM CaseMilestone WHERE CaseId = :casoSeg.Id];

        //Generamos la estructura del envío a TaskConnect
        BODY_TaskConnect bodyEnvio = new BODY_TaskConnect();
        BODY_Event datosEvent = new BODY_Event();
        BODY_Parameters datosParameters = new BODY_Parameters();
        BODY_Parameters identificador = new BODY_Parameters();
        BODY_Parameters refID = new BODY_Parameters();
        BODY_Parameters timeStamp = new BODY_Parameters();
        BODY_Parameters tipo = new BODY_Parameters();
        List<BODY_Parameters> lstDatosParameters = new List<BODY_Parameters>();
        
        //Rellenamos la estrucutra Event del envío
        datosEvent.eventMessageId = '62f60516-9814-4dcb-863c-b1b70808d630';
        datosEvent.processApp = 'GDSC844';

        //Asignamos la estrucutra Event del envío
        bodyEnvio.event = datosEvent;

        //Rellenamos la estrucutra Parameters del envío

        identificador.key = 'identificador';
        identificador.value = 'SALESFORCE';
        lstDatosParameters.add(identificador);

        refID.key = 'refID';
        refID.value = casoSeg.CaseNumber != null ? casoSeg.CaseNumber : '';
        lstDatosParameters.add(refID);

        Datetime myDT = DateTime.now();
        String myDate = myDT.format('dd/MM/yyyy HH:mm:ss');
        
        timeStamp.key = 'timeStamp';
        timeStamp.value = myDate;
        lstDatosParameters.add(timeStamp);

        tipo.key = 'tipo';
        tipo.value = tipoEnvio;
        lstDatosParameters.add(tipo);

        datosParameters.key = 'datosNegocio';

        BODY_TaskConnect_Datos datosCaso = new BODY_TaskConnect_Datos();
        datosCaso.url = URL.getOrgDomainUrl().toExternalForm() + '/' + casoSeg.Id;
        datosCaso.numeroCentro = casoSeg.SEG_Numero_centro__c != null ? casoSeg.SEG_Numero_centro__c : '';
        datosCaso.numeroCaso = casoSeg.CaseNumber != null ? casoSeg.CaseNumber : '';
        datosCaso.nifPeticionario = casoSeg.SEG_NIF_peticionario__c != null ? casoSeg.SEG_NIF_peticionario__c : '';
        datosCaso.nombreCliente = casoSeg.Account?.Name != null ? casoSeg.Account.Name : '';
        datosCaso.asunto = casoSeg.Subject != null ? casoSeg.Subject : '';
        datosCaso.clasificacionRapida = casoSeg.SEG_ClasificacionRapida__r?.Name != null ? casoSeg.SEG_ClasificacionRapida__r.Name : '';
        datosCaso.tematica = casoSeg.CC_MCC_Tematica__r?.Name != null ? casoSeg.CC_MCC_Tematica__r.Name : '';
        datosCaso.productoServicio = casoSeg.CC_MCC_ProdServ__r?.Name != null ? casoSeg.CC_MCC_ProdServ__r.Name : '';
        datosCaso.motivo = casoSeg.CC_MCC_Motivo__r?.Name != null ? casoSeg.CC_MCC_Motivo__r.Name : '';
        datosCaso.detalle = casoSeg.SEG_Detalle__r?.Name != null ? casoSeg.SEG_Detalle__r.Name : '';
        datosCaso.estado = casoSeg.Status != null ? casoSeg.Status : '';
        datosCaso.fechaHoraCierre = casoSeg.ClosedDate != null ? String.valueOf(casoSeg.ClosedDate) : '';
        datosCaso.propietarioCaso = casoSeg.SEG_Case_Owner__c != null ? casoSeg.SEG_Case_Owner__c : '';
        datosCaso.propietarioAnteriorGrupo = casoSeg.SEG_PropAnteriorGrupo__c != null ? casoSeg.SEG_PropAnteriorGrupo__c : '';
        datosCaso.fechaHoraApertura = casoSeg.SEG_Fechayhoracreacion__c != null ? casoSeg.SEG_Fechayhoracreacion__c : '';
        datosCaso.ultimaFechaHoraModificacion = casoSeg.LastModifiedDate != null ? String.valueOf(casoSeg.LastModifiedDate) : '';
        datosCaso.observaciones = casoSeg.SEG_Observaciones__c != null ? casoSeg.SEG_Observaciones__c : '';
        datosCaso.zona = casoSeg.SEG_Zona__c != null ? casoSeg.SEG_Zona__c : '';
        datosCaso.organizacion = casoSeg.SEG_Organizacion__c != null ? casoSeg.SEG_Organizacion__c : '';
        datosCaso.nOperacionesCso = casoSeg.SEG_N_operaciones_CSO__c != null ? String.valueOf(casoSeg.SEG_N_operaciones_CSO__c) : '';
        datosCaso.propietarioAnterior = casoSeg.CC_Owner_Anterior__r?.Name != null ? casoSeg.CC_Owner_Anterior__r.Name : '';
        datosCaso.subestado = casoSeg.SEG_Subestado__c != null ? casoSeg.SEG_Subestado__c : '';
        datosCaso.grupo = casoSeg.SEG_Grupo__r?.Name != null ? casoSeg.SEG_Grupo__r?.Name : '';
        datosCaso.prioridad = casoSeg.Priority != null ? casoSeg.Priority : '';
        datosCaso.numeroEmpleado = '';

        if (String.valueOf(casoSeg.ownerId).startsWith('005')) {
            List<User> propietario = [SELECT id, EmployeeNumber FROM User WHERE Id = :casoSeg.OwnerId LIMIT 1];
            datosCaso.numeroEmpleado = propietario[0].EmployeeNumber != null ? propietario[0].EmployeeNumber : '';
        }
        
        if(!milestone.isEmpty()){
            datosCaso.fechaLimiteSla = milestone[0].TargetDate?.format('dd-MM-yyyy HH:mm:ss');
        }

        String datosCasoJSON = JSON.serialize(datosCaso);
        String datosCasoEnconded = EncodingUtil.Base64Encode(Blob.valueOf(datosCasoJSON));

        datosParameters.value = datosCasoEnconded;
        lstDatosParameters.add(datosParameters);

        //Asignamos la estrucutra Parameters del envío
        bodyEnvio.parameters = lstDatosParameters;
        
        oTraza.CC_Identificador__c = casoSeg.CaseNumber;

        String jsonBody = JSON.serialize(bodyEnvio);

        // Custom Setting
        String intSetting = 'SEG_TaskConnect';
        
        try {
            // Crear HEADER
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            HttpRequest request = CBK_HttpServiceIntegration.getRequest(jsonBody, intSetting, 'POST', mHeaders);

            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);
            
            //oTraza.CC_MensajeEntrada__c = datosCasoJSON;
            oTraza.CC_MensajeEntrada__c = String.valueOf(jsonBody);

            if (response != null && response.getStatusCode() == 200) {
                Integer maxSize = 32767;
                SEG_receiveFromCognitive results = new SEG_receiveFromCognitive();
                
                if (response.getBody() != null && response.getBody().length() < maxSize) {
                    oTraza.CC_MensajeSalida__c = response.getBody();
                } else if(response.getBody() != null) {
                    oTraza.CC_MensajeSalida__c = response.getBody().substring(0, maxSize);
                }
                
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = true;
                
                results = SEG_receiveFromCognitive.parse(response.getBody());
            } else if(response != null){
                oTraza.CC_MensajeSalida__c = response.getBody();
                oTraza.CC_FechaFin__c = datetime.now();
            } else {
                oTraza.CC_MensajeSalida__c = 'Sin respuesta del servidor';
                oTraza.CC_FechaFin__c = datetime.now();
            }
        } catch (Exception e) {
            //Traza - Error de Apex
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = 'Error comunicaciones.';
            oTraza.CC_DetalleError__c = e.getMessage();
        }

        insert oTraza;       
    }

    public class BODY_TaskConnect {
        public BODY_Event event;
        public List<BODY_Parameters> parameters;
    }

    public class BODY_Event {
        public String eventMessageId = ''; //62f60516-9814-4dcb-863c-b1b70808d630
        public String processApp = ''; //GDSC844
    }

    public class BODY_Parameters {
        public String key = ''; //datosNegocio
        public String value = ''; //BODY_TaskConnect_Datos
    }

    public class BODY_TaskConnect_Datos {
        public String url = ''; //https://caixabankcc--devboseg01.sandbox.my.salesforce.com/5005r00000CgbZuAAJ
        public String numeroCentro = ''; //03071
        public String numeroCaso = ''; //03934551
        public String nifPeticionario = ''; //00000000T
        public String nombreCliente = ''; //Fruterías
        public String asunto = ''; //03934551 - Prueba desde gmail 2
        public String clasificacionRapida = ''; //CR test SLAs 2 dias habiles despues recepción
        public String tematica = ''; //test 2 dias
        public String productoServicio = ''; //2 dias habiles
        public String motivo = ''; //2 dias habiles
        public String detalle = ''; //Ejemplo detalle
        public String estado = ''; //Activo
        public String fechaHoraCierre = ''; //2023-08-08 11:36:50
        public String propietarioCaso = ''; //Arnau Quiros
        public String propietarioAnteriorGrupo = ''; //Alejandro Rivera
        public String fechaHoraApertura = ''; //2023-08-08 11:36:50
        public String ultimaFechaHoraModificacion = ''; //2023-08-08 11:36:50
        public String observaciones = ''; //Observacion test
        public String zona = ''; //Corporativa
        public String organizacion = ''; //Banca Corporativa
        public String nOperacionesCso = ''; //1
        public String propietarioAnterior = ''; //Arnau Quiros
        public String subestado = ''; //En curso
        public String grupo = ''; //MCC 0029
        public String prioridad = ''; //Media
        public String fechaLimiteSla = ''; //2023-08-08 11:36:50
        public String numeroEmpleado = ''; //U01A3F65
    }
}