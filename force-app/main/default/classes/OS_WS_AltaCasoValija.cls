@RestResource(urlMapping='/AltaCasoValija/*')
global with sharing class OS_WS_AltaCasoValija {

    static OS_WS_AltaCasoValija.Output output = new OS_WS_AltaCasoValija.Output();
    static OS_WS_AltaCasoValija.Input input = new OS_WS_AltaCasoValija.Input();

    public class WrapperValores {
        public OS_WS_AltaCasoValija.Input input {get;set;}
        public Map<String, Integer> reintentosMap {get;set;}
    }
    //Método principal de la integración
    @HttpPost
    global static OS_WS_AltaCasoValija.Output altaCasoValija(){
        Boolean bOk = true;
        Map<String, Integer> mapaReintentos = new Map<String, Integer>();
        
        RestRequest peticionREST = RestContext.request;

        if (peticionREST?.requestBody != null)
        {
            try {
                input = (OS_WS_AltaCasoValija.Input)JSON.deserializeStrict(
                    peticionREST.requestBody.toString(), OS_WS_AltaCasoValija.Input.class
                );
            } catch (Exception e) {
                // Error al serializar la entrada.
                bOk = false;
                output.resultado = 'KO';
                output.codigo = '0000';
                output.error = 'Mensaje de entrada no válido. ' + e.getMessage();
                output.caseId = '';
                return output;
            }
        }
        output = principal(input, mapaReintentos, bOk);
        return output;

    }

    public static OS_WS_AltaCasoValija.Output principal(OS_WS_AltaCasoValija.Input input, Map<String, Integer> reintentos, Boolean bOk) {

        String areaPeticionValija = '';
        RestRequest peticionREST = RestContext.request;

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            String mensajeEntrada = JSON.serialize(input);
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segAltaValija_POST','POST','POST',mensajeEntrada);
        } catch (Exception e) {
            CBK_log.debug('Ha ocurrido la siguiente excepción: ' + e.getMessage());
        }

        if (bOk)
        {
            // Recuperar el área del proceso.
            areaPeticionValija = recuperarAreaValija (input.tipoProceso);

            if (areaPeticionValija == 'COPS')
            {
                // PETICIONES DE COPS.

                if (Test.isRunningTest())
                {
                    // Generar petición Mock.
                    input = generarMockCOPS (input);
                }
                output = gestionPeticionCOPS (input, reintentos);
            }else if (areaPeticionValija == 'SEGMENTOS')
            {
                // PETICIONES DE SEGMENTOS.

                output = SEG_wsValijaAltaCaso.gestionPeticionSegmentos (input);
            }else{
                // Error petición.
                bOk = false;
                output.resultado = 'KO';
                output.codigo = '9001';
                output.error = 'El proceso indicado no está configurado en Salesforce.';
                output.caseId = '';
            }
        }

        try {
            if (trazaPOST != null)
            {
                if (output.resultado != 'OK')
                {
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(output), output.codigo, output.error);
                }else{
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(output));
                }
            }
        } catch (Exception e) {
            CBK_log.debug('Ha ocurrido la siguiente excepción: ' + e.getMessage());
            
        }

        return output;
    }

    private static List<Id> recordTypesContactosEmpleado() {
        List<Id> retorno = new List<Id>();
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado'));
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'OS_Buzon_Contact'));
        return retorno;
    }

    private static List<Id> recordTypesCuentasEmpleado() {
        List<Id> retorno = new List<Id>();
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank'));
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'OS_Buzon_Account'));
        return retorno;
    }

    private class Attach {
        String body;
        String contentType;
        String name;
	}   
    
    public class Input {
        public String tipo {get;set;}
        public String description {get;set;}
        public String titulo {get;set;}
        public String officeNum {get;set;}
        public String empNum {get;set;}
        public String idFaq {get;set;}
        public String email {get;set;}
        public String idValija {get;set;}
        public String numSr {get;set;}
        public String origen {get;set;}
        public String tipoProceso {get;set;}
        public String nombreProceso {get;set;}
        public String zona {get;set;}
        public String cif {get;set;}
        public String cifOrdenante {get;set;}
        public Boolean grupo {get;set;}
        public String numOperaciones {get;set;}
        public String importeTotal {get;set;}
        public String resultado {get;set;}
        public String url {get;set;}
        public String tipoCargo {get;set;}
        public String pagoAgrupado {get;set;}
        public String comunidad {get;set;}
        public String premium {get;set;}
        public String adjuntos {get;set;}
        //public List<Attach> adjuntos {get;set;}
        public String conceptoAsociado {get;set;}
        public Integer numeroDocumentos {get;set;}
    }

    global class Output {
        public String resultado {get;set;}
        public String error {get;set;}
        public String caseId {get;set;}
        public String codigo {get;set;}
    }

    /**
     * @description Método movido para generar una entrada mock para los test de COPS.
     */
    public static OS_WS_AltaCasoValija.Input generarMockCOPS (OS_WS_AltaCasoValija.Input input)
    {
        //Insertamos valores manualmente para la clase de test
        input.tipo = 'Bastanteo Analizar';
        input.description = 'descripció';
        input.titulo = 'Bastanteo Analizar17022230022032000005';
        input.officeNum = '09000';
        input.empNum = '12345';
        input.idFaq = null;
        input.email = null;
        input.idValija = '17022230022032000005';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = null;
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = null;
        input.cif = null;
        input.cifOrdenante = null;
        input.conceptoAsociado = null;
        input.numeroDocumentos = null;
        input.grupo = true;
        input.numOperaciones = null;
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = null;
        input.pagoAgrupado = null;
        input.comunidad = null;
        input.premium = null;
        input.adjuntos = '2';

        OS_WS_AltaCasoValija.Input inputMock = new OS_WS_AltaCasoValija.Input();
        inputMock = input;
        return inputMock;
    }

    /**
     * @description Método para recuperar el área de la petición en base al proceso de Valija.
     * @param procesoValija Código del proceso de valija que viene en el servicio. Tras hablar con el equipo de Valija, Segmentos vendrá informado el tipoProceso y COPS siempre viene a Null.
     * @return Área del proceso de valija.
     */
    public static String recuperarAreaValija (String procesoValija)
    {
        String areaProceso = '';

        areaProceso = (String.isNotBlank(procesoValija)) ? 'SEGMENTOS' : 'COPS';

        /* OBSOLETO. El criterio se simplifica por lo comentado con el equipo de Valija.
        Map<String,String> busqueda = SEG_wsValijaCasosComunes.recuperarProcesoValija (procesoValija, false);
        if (busqueda.get('codigo') == '0')
        {
            // Incorporar valor de retorno.
            areaProceso = busqueda.get('areaProceso');
        }

        // Para no impactar en los procesos de COPS, si no se encuentra nada configurado, se marca como proceso de COPS.
        areaProceso = (String.isNotBlank(areaProceso)) ? areaProceso : 'COPS';
        */

        return areaProceso;
    }

    /**
     * @description Función core para la parte de COPS. Se mueve aquí para separar la parte de Segmentos y COPS.
     * @param input Estructura de entrada del servicio REST
     * @return retorno del servicio REST
     */
    public static OS_WS_AltaCasoValija.Output gestionPeticionCOPS (OS_WS_AltaCasoValija.Input input, Map<String, Integer> reintentos)
    {
        OS_WS_AltaCasoValija.Output output = new OS_WS_AltaCasoValija.Output();

        try {
            
            if (![SELECT Id, OS_Referencia_Valija__c FROM Case WHERE OS_Referencia_Valija__c = :input.idValija].isEmpty()) {
                output.resultado = 'OK';
                output.codigo = '0001';
            	output.error = 'El idValija esta asociado a un caso ya existente.';
            	output.caseId = [SELECT Id, OS_Referencia_Valija__c FROM Case WHERE OS_Referencia_Valija__c = :input.idValija LIMIT 1].Id;
                
            } else {                
                Case caso = new Case();
                caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');
                caso.Origin = 'Valija digital';
                caso.OS_Referencia_Valija__c = input.idValija;
                caso.CC_Canal_Procedencia__c = 'Valija digital';
                caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'OS_Buzon_Valija_Digital'].Id;
                caso.Subject = input.titulo;
                caso.Description = input.description;
                caso.OS_Adjuntos_Valija__c = String.isNotBlank(input.adjuntos) ? Integer.valueOf(input.adjuntos) : 1;
                caso.OS_Nombre_Proceso_Valija__c = input.nombreProceso;
    
                //Cuenta y contacto
                String numOficina = input.officeNum;
                if (String.isNotBlank(numOficina)) {
                    numOficina = numOficina.length() == 4 ? '0'+numOficina : numOficina;

                    List<Account> accounts = [SELECT Id FROM Account WHERE RecordTypeId IN :recordTypesCuentasEmpleado() AND CC_Numero_Oficina__c = :numOficina LIMIT 1];
                    if (!accounts.isEmpty()) {
                        caso.AccountId = accounts[0].Id;
                        caso.CC_Oficina__c = accounts[0].Id;
                        caso.CC_Oficina_Afectada_Lookup__c = accounts[0].Id;
                    } 

                } else {
                    String numEmpleado = input.empNum;
                    if (String.isNotBlank(numEmpleado)) {
                        List<Contact> empleados = [SELECT AccountId FROM Contact WHERE RecordTypeId IN :recordTypesContactosEmpleado() AND CC_Num_Empleado__c = :input.empNum LIMIT 1];
                        if (!empleados.isEmpty()) {
                            caso.ContactId = empleados[0].Id;
                            caso.AccountId = empleados[0].AccountId;
                            caso.CC_Oficina__c = empleados[0].AccountId;
                            caso.CC_Oficina_Afectada_Lookup__c = empleados[0].AccountId;
                        }
                    }
                }
                
                
    
                //Clasificación
                List<CC_Lista_Valores__c> clasificacionesAutomaticas = [SELECT CC_Valor__c FROM CC_Lista_Valores__c
                                                                        WHERE CC_Lista__r.Name = 'COPS: Clasificaciones automáticas para valija digital'
                                                                        AND Name = :input.nombreProceso LIMIT 1];
                if (!clasificacionesAutomaticas.isEmpty()) {
                    //Clasificación automática definida para el proceso de valija recibido
                    Id idMotivo = clasificacionesAutomaticas[0].CC_Valor__c;
    
                    List<CC_MCC__c> motivos = [SELECT CC_Producto_Servicio__c FROM CC_MCC__c WHERE Id = :idMotivo];
                    if (!motivos.isEmpty()) {
    
                        //La clasificación indicada existe
                        Id idProducto = motivos[0].CC_Producto_Servicio__c;
                        caso.CC_MCC_Tematica__c = [SELECT CC_Tematica__c FROM CC_MCC__c WHERE Id = :idProducto].CC_Tematica__c;
                        caso.CC_MCC_ProdServ__c = idProducto;
                        caso.CC_MCC_Motivo__c = idMotivo;
                    }
                }
                List<OS_TrasladoColaborador_Valija__mdt> trasladosColabAutomaticos = [SELECT OS_Grupo_Colaborador__c, OS_Plantilla__c
                                                                                            FROM OS_TrasladoColaborador_Valija__mdt WHERE OS_Nombre_Proceso__c = :input.nombreProceso LIMIT 1];
                

                insert caso;
                Boolean condicional = false;
                if (!trasladosColabAutomaticos.isEmpty()) {
                    caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);
                    condicional = true;
                }
                
                //Acuse de recibo para valija digital
                if(String.isBlank(caso.CC_Referencia_Correo_Saliente__c)){
                    caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);
                    condicional = true;
                }

                if(condicional){
                    update caso;
                }

                List<Case> cases = new List<Case>{caso};
                envioAcuseReciboValija(cases);

                Task tarea = new Task();
                tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                tarea.WhatId = caso.Id;
                tarea.Type = 'Recepción de valija digital';
                tarea.Description = 'Proceso valija: ' + input.nombreProceso;
                tarea.Subject = 'Recepción de valija digital';
                tarea.Status = 'Completed';
                insert tarea;
    
                output.resultado = 'OK';
                output.codigo = '0000';
                output.caseId = caso.Id;
                
        	}
            //Se utilizan estas condiciones para poder forzar en el test que entre por el catch
            if(Test.isRunningTest() && input.idValija.equalsIgnoreCase('00000000')){
                Case caso2 = new Case();
                caso2.Id = '8745848';
                insert caso2;
            }
            
        } catch (Exception e) {
            output.resultado = 'KO';
            output.codigo = '9999';
            output.error = e.getMessage();
            output.caseId = '';
            //CBK_Log.error(e);

            if(e.getMessage().contains('UNABLE_TO_LOCK_ROW') ||(Test.isRunningTest() && input.idValija.equalsIgnoreCase('00000000'))){
                if(reintentos.isEmpty() || !reintentos.containsKey(input.idValija)){
                        reintentos.put(String.valueof(input.idValija), 0);
                }

                WrapperValores parametrosJob = new WrapperValores();
                parametrosJob.input = input;
                parametrosJob.reintentosMap = reintentos;
                

                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(UserInfo.getUserId())

                                .addString(String.valueOf(input.idValija))

                                .build();
                //System.enqueueJob(new MyQueueable(), options);
                try {
                    System.enqueueJob(new OS_WS_AltaCasoValija_Queueable(parametrosJob), options);
                } catch (DuplicateMessageException ex) {
                    //Exception is thrown if there is already an enqueued job with the same signature
                    CBK_Log.error(ex);
                }
            }
        }

        return output;
    }


    public static void envioAcuseReciboValija(List<Case> casesToSend) {
        List<Case> casesQueried = [SELECT Id, Account.CC_Email__c, CC_Referencia_Correo_Saliente__c FROM Case WHERE Id IN: casesToSend];
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> et = [SELECT Id, htmlValue FROM EmailTemplate WHERE DeveloperName = 'OS_AcuseReciboValija_EN' LIMIT 1];
        String whoId = UserInfo.getUserId();
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Buzón International Support' LIMIT 1];
        String usernamewhoId = [SELECT Id, Username FROM User WHERE Id =: whoId LIMIT 1].Username;
        
        if(!casesQueried.isEmpty() && !et.isEmpty()){
            List<Task> tareasInsert = new List<Task>();
            for(Case cs : casesQueried){
                if(String.isNotBlank(cs.Account.CC_Email__c)){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(et[0].Id, whoId, cs.Id); 
        
                    message.setOrgWideEmailAddressId(owea.Id);
                    //Falla porque hay que recuperar el account.CC_Email__c mediante query
                    
                    message.setToAddresses(new String[] {cs.Account.CC_Email__c});
                    String referencia = '';
                    if(Test.isRunningTest()) {
                        message.htmlBody = 'test';
                    }else{
                        message.htmlBody = renderStored.getHtmlBody();
    
                        //Generar semilla 
                        String mensajeSemilla = '';

                        if(String.isNotBlank(cs.CC_Referencia_Correo_Saliente__c)){                             
                            mensajeSemilla += '<br/><br/><font color="gray">';
                            mensajeSemilla += 'Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@' + cs.CC_Referencia_Correo_Saliente__c + '#.';
                            mensajeSemilla += '</font>';
                            referencia = cs.CC_Referencia_Correo_Saliente__c;
                        }
                        else{
                            referencia = CC_EmailMessage.generarReferenciaCorreoSaliente(cs.Id);
                            mensajeSemilla += '<br/><br/><font color="gray">';
                            mensajeSemilla += 'Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@' + referencia + '#.';
                            mensajeSemilla += '</font>';
                        }
    
                        message.htmlBody += mensajeSemilla;
                    }
                    message.setSubject(renderStored.getSubject());
                    message.setWhatId(cs.Id);
                    message.optOutPolicy = 'FILTER';
    
                    Task tarea = new Task();
                    tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                    tarea.Type = 'Acuse de recibo';
                    tarea.TaskSubtype = 'Email';
                    tarea.Subject = message.subject.left(255);
                    tarea.ActivityDate = System.today();
                    tarea.Status = 'Completed';
                    tarea.Description = message.htmlBody.left(32000);
                    tarea.CC_Referencia_Correo_Saliente__c = referencia;
                    tarea.WhatId = cs.Id;
                    
                    tareasInsert.add(tarea);
                    messageList.add(message);
                }
            }
            
            if(!messageList.isEmpty() && !tareasInsert.isEmpty()){
                insert tareasInsert;
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);
            }
        }
    }
}