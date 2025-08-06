/**
 *   @description SEG_EmailService
*/
public with sharing class SEG_EmailService implements Messaging.InboundEmailHandler {

    private static Id recordTypeSEG;
    private static Id recordTypeSeguimiento;
    private static Id recordTypesClienteContacto;
    private static Id recordTypeEmpleado;
    private static Id recordTypeColaborador;
    private static Id recordTypeCliente;
    private static Id recordTypeClienteSeg;
    private static Id recordTypesCentroCaixaBank;
    private static Id recordTypesClientePA;

    /**
     *  @description Clase que recibe email 
     *  @param email -> email entrante
     *  @param envelope -> envolpe entrante
     *  @return result de tipo Messaging.InboundEmailResult 
     */

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        String messageId = null;
        String parentMessageId = null;
        String foundBuzon;
        String foundOrg;
        String foundZona;
        String foundContact;
        String foundAccount;
        String foundStatus;
        String foundSubestado;
        String foundOwner;
        String foundGrupo;
        string buzonCaixa = null;
        String body = '';
        String foundRC;
        String subjectAcortado = '';
        String subjectAcortadoCaso = '';
        String numCentroIden;
        Boolean casoCreado = false; 
        Boolean emailCreado = false;    
        Boolean casoCreadoError = false; 
        Boolean emailMessageCreado = false;
        EmailMessage mensaje = new EmailMessage();
        SEG_ClasificacionRapida__c foundCR = new SEG_ClasificacionRapida__c();

        Set<String> objetos = new Set<String>{'Case','Contact','Account'};
        Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
        recordTypeSEG = rtObjetos.get('Case').get('SEG_Cliente').getRecordTypeId();
        recordTypeSeguimiento = rtObjetos.get('Case').get('SEG_Seguimiento').getRecordTypeId();
        recordTypesClienteContacto = rtObjetos.get('Contact').get('CC_Cliente').getRecordTypeId();
        recordTypeEmpleado = rtObjetos.get('Contact').get('CC_Empleado').getRecordTypeId();
        recordTypeColaborador =  rtObjetos.get('Contact').get('CC_Colaborador').getRecordTypeId();
        recordTypeCliente = rtObjetos.get('Account').get('CC_Cliente').getRecordTypeId();
        recordTypeClienteSeg = rtObjetos.get('Account').get('CC_ClienteSEG').getRecordTypeId();
        recordTypesCentroCaixaBank = rtObjetos.get('Account').get('CC_CentroCaixaBank').getRecordTypeId();
        recordTypesClientePA = rtObjetos.get('Account').get('CC_ClientePA').getRecordTypeId();
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success=false;

        try{
            if (!Test.isRunningTest()) {CBK_log.auditemail(email,envelope);}
            
            String descriptionBody = null;
            if (String.isNotBlank(email.htmlBody)) {
                body = email.htmlBody.stripHtmlTags().left(131000);
                descriptionBody = (String.isNotBlank(email.plainTextBody))?email.plainTextBody.left(131000):email.htmlBody.stripHtmlTags().left(131000);
            } else if (String.isNotBlank(email.plainTextBody)) {
                body = email.plainTextBody.left(131000);
                descriptionBody = body;
                body = body.replace('\n','<br/>').replace('\r','<br/>');
            } 

            String organizacionBuzon = null;
            String zonaBuzon = null;
            String organizacionEmpresa = null;
            String zonaEmpresa = null;
            Id mccBuzon = null;

            List<SEG_Buzon__mdt> mcs = [SELECT SEG_OZ_Preferente__c, SEG_Organizacion__c, SEG_Zona__c, SEG_Grupo_MCC__c, SEG_Email_SF__c, SEG_Correo_de_procedencia__c
            FROM SEG_Buzon__mdt WHERE SEG_Email_SF__c = :envelope.toAddress  LIMIT 1];

            List<OS_Correo__mdt> buzonesOS = [SELECT OS_Email__c, OS_Cola_Procedencia__c, OS_Canal_Procedencia__c, OS_Correo__c, OS_Recordtype_Caso_Defecto__c
            FROM OS_Correo__mdt WHERE OS_Canal_Procedencia__c IN ('Buzón UAFE Express','Buzón UAFE')];
            List<String> direccionesOS = new List<String>();
            for (OS_Correo__mdt buzon : buzonesOS) {
                direccionesOS.add(buzon.OS_Correo__c);
            }
            Boolean oSMailRelated =false;

            //Jaime: si el mail entrante viene de COPS o no 
            Boolean oSMailRelatedFrom = false;

            for (String address : direccionesOS){
                if((email.toAddresses!=null && !email.toAddresses.isEmpty() && email.toAddresses.contains(address)) || (email.ccAddresses!=null && !email.ccAddresses.isEmpty() && email.ccAddresses.contains(address))) {
                    oSMailRelated = true;    
                }

                //Jaime: Con que 1 de las direcciones en el FROM del mail entrante coincida con uno de los buzones de COPS, se considera que es un mail entrante de COPS
                if (email.fromAddress.contains(address)) {
                    oSMailRelatedFrom = true;
                }
            }

            if (Test.isRunningTest()) {
                mcs.add(SEG_TestHelper.createBuzon());
            }
            if (mcs.size() == 1) {
                organizacionBuzon = mcs[0].SEG_Organizacion__c;
                zonaBuzon = mcs[0].SEG_Zona__c;
                buzonCaixa = mcs[0].SEG_Correo_de_procedencia__c;
                foundOrg = organizacionBuzon;
                foundZona = zonaBuzon;
                foundBuzon = buzonCaixa;
                    
                if (String.isNotBlank(mcs[0].SEG_Grupo_MCC__c)) {
                    CC_Grupo_Colaborador__c[] colab = [SELECT id, SEG_GrupoAlternativo__c, SEG_Inactivo__c FROM CC_Grupo_Colaborador__c where Name = :mcs[0].SEG_Grupo_MCC__c  LIMIT 1];
                    if (colab[0].SEG_Inactivo__c && colab[0].SEG_GrupoAlternativo__c != null) {
                        mccBuzon = colab[0].SEG_GrupoAlternativo__c;
                    } else {
                        mccBuzon = colab[0].id;
                    }
                }
                foundGrupo = mccBuzon;  
            }
            //identificarCliente
            String emailfrom = email.fromAddress;
            //US829509: Correos - Limitación caracteres asunto
            if(email.subject.length() > 3000){
                subjectAcortado = email.subject.left(3000);
            }else{
                subjectAcortado = email.subject;
            }

            if(email.subject.length() > 255){
                subjectAcortadoCaso = email.subject.left(255);
            }else{
                subjectAcortadoCaso = email.subject;
            }

            String subjectBody  = subjectAcortado + ' ' + body;
            List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' ];
            foundOwner = colasBO[0].id; 
            //Identificamos si el correo tiene una semilla con un caso existente
            String[] semillaId = SEG_EmailService.identificarSemillaId(subjectBody);
            String[] srNumbers = SEG_EmailService.identificarsrNumber(subjectAcortado);
            numCentroIden = identificarNumCentro(email.toAddresses);
            List<Case> casosEncontrados = new List<Case>();
            List<Case> lstCasosReferenciados = new List<Case>();
            List<Case> lstCasosCOPS = new List<Case>();

            //Registros de casos con las semillas y caseNumbers del correo
            Map<String,List<Case>> mapCasosProcesados = procesarReferencias(semillaId, srNumbers, organizacionBuzon, zonaBuzon);

            if (mapCasosProcesados.containsKey('casoReciente')) {
                casosEncontrados = mapCasosProcesados.get('casoReciente');
            }

            if (mapCasosProcesados.containsKey('casosReferenciados')) {
                lstCasosReferenciados = mapCasosProcesados.get('casosReferenciados');
            }

            //cops
            //Jaime: No existe un caso relacionado, por lo que se crea el de SEG y se actualiza el de COPS
            if (mapCasosProcesados.containsKey('casosCOPS')) {
                lstCasosCOPS = mapCasosProcesados.get('casosCOPS');
            }


            //Alejandro:
            /* if (mapCasosProcesados.containsKey('casosCOPS')) {
                lstCasosReferenciados = mapCasosProcesados.get('casosCOPS');
            } */

            
            //Arnau:
            /*
            if (mapCasosProcesados.containsKey('casosCOPS')) {
                lstCasosReferenciados = mapCasosProcesados.get('casosCOPS');
            } */

            //Jaime:
            /* if (!mapCasosProcesados.containsKey('casosCOPS')) {
                //No existe un caso relacionado, por lo que se crea el de SEG y se actualiza el de COPS
                //Y para poder actualizar el de COPS la query de procesarReferencias debe devolver un Caso, y actualmente sólo lo hace al estar relacionados
            } */

            /*  Jaime: ¿esta comprobacion de casosEncontrados se pisa con la de casosCOPS? Es la que decide si el caso es nuevo o una respuesta
                Más adelante estamos informando SEG_Id_Related_Mail__c
            */
            //Comprobamos si el email es una repuesta o un caso nuevo
            if (!casosEncontrados.isEmpty() || (semillaId.size() > 0 && checkmailad(semillaId, buzonCaixa))) {
                //El correo es una respuesta a uno previo
                Map<Id, Id> mapCasosGruposExternos = new Map<Id, Id> (); //primer id, caso | segundo id, SEG_Grupo_colaborador_Externo__c
                for (Case casoEncontrado : casosEncontrados)  {
                    if (String.isNotBlank(casoEncontrado.SEG_Grupo_colaborador_Externo__c)) {
                        mapCasosGruposExternos.put(casoEncontrado.id, casoEncontrado.SEG_Grupo_colaborador_Externo__c);
                    }
                }
                //Buscamos posibles coindicencias de colaboradores: select de personas con grupo colaborador externo del caso y que figuren en grupo del caso
                List<CC_Grupo_Colaborador_Contact__c> contactosColaboradores = new List<CC_Grupo_Colaborador_Contact__c> ();
                contactosColaboradores = [SELECT id, CC_Contacto__r.Email, CC_Email__c, CC_Grupo_Colaborador__c, CC_Contacto__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Contacto__r.Email = :emailfrom and CC_Grupo_Colaborador__c in :mapCasosGruposExternos.values() and CC_Contacto__c<> '' ];

                for (Case caso : casosEncontrados) {
                    //buscamos el remitente del email en las estructuras creadas  
                    if (!contactosColaboradores.isEmpty()) {
                        for (CC_Grupo_Colaborador_Contact__c colabAux : contactosColaboradores){
                            if (colabAux.CC_Email__c == emailfrom && colabAux.CC_Grupo_Colaborador__c == caso.SEG_Grupo_colaborador_Externo__c) {
                                //modificamos el estado del caso a Activo, y borramos el SEG_Grupo_colaborador_Externo__c. Aseguraremos ademas que esté asignado al grupo respuesta que aplica
                                //comprobamos recordType de grupo
                            
                                caso.SEG_Grupo_colaborador_Externo__c = null;
                                caso.Status = 'High';
                                caso.SEG_Subestado__c = 'Recibida respuesta Colaborador';
                                caso.OwnerId = colasBO[0].id;
                            }
                        }
                    } else if(caso.Status == 'Activo' && caso.SEG_Case_Owner__c == 'SEG_BO' && caso.Priority != 'Critical'){
                        caso.Priority = 'High';
                    } else {
                        if (caso.Status != 'Merged') {
                            caso.Status = 'Activo';
                            caso.SEG_Subestado__c = 'Reactivada por comunicación de cliente';
                        }
                    }

                    List<String> stats = identificarEmailSaliente(emailfrom, caso);
                    caso.Status = stats[0];
                    caso.SEG_Subestado__c = stats[1];
                    caso.SEG_Fecha_planificaci_n__c = null;

                    //Jaime: En el caso ENCONTRADO se informa el id del mail origen
                    if(oSMailRelated){
                        caso.SEG_Id_Related_Mail__c = email.messageId;
                    }
                    
                }

                String objCnt;
                if (!lstCasosReferenciados.isEmpty() && lstCasosReferenciados.size() > 1) {
                    String asociadosReferencia = 'Este caso contiene emails con referencias a los siguientes casos: ';
                    for (Case casoReferenciado : lstCasosReferenciados) {
                        asociadosReferencia = asociadosReferencia + ' ' + casoReferenciado.caseNumber;
                    }

                    objCnt = crearNotas(asociadosReferencia);
                    crearLinkNota(lstCasosReferenciados, objCnt);
                }

                List<Case> casoUpdt = new List<Case>();
                for (Case caso : casosEncontrados) {
                    try{
                        if (emailMessageCreado == false){
                            Map<String, sObject> mapResultado = procesarAdjuntos(caso.Id, caso, email, envelope, body, buzonCaixa);
                            if (mapResultado.containsKey('correo')) {
                                mensaje  = (EmailMessage)mapResultado.get('correo');
                            }
                            if (mapResultado.containsKey('caso')) {
                                casoUpdt.add((Case)mapResultado.get('caso'));
                            }
                            
                            messageId = mensaje.Id;
                            parentMessageId = mensaje.ParentId;
                            emailMessageCreado = true;
                        }   
                    }catch(Exception e){
                        // Registrar error
                        // CBK_Log.error(e, 'Error en el envio de email', email);
                        CBK_Log.addError(null, e, 'Error en el envio de email ' + e.getMessage(), null, null);
                    }   
                    
                    //Detectar duplicados del caso insertado
                    Set<Id> caseIds = new Set<Id> { caso.Id };
                    SEG_Case_Duplicated caseDulicatedProcess = new SEG_Case_Duplicated(caseIds);
                    System.enqueueJob(caseDulicatedProcess);
                } 

                //Se insertan los CBK_Logs
                CBK_Log.insertDML();
                
                if (!casoUpdt.isEmpty()) {
                    update(casoUpdt);
                }

                result.success = true;

                CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                wResult.Status = (result.success) ? 'OK' : 'KO';
                wResult.Detail = (result.success) ? 'Envio correcto' : 'Error procesando el correo';
                wResult.CaseId = parentMessageId;
                wResult.EmailMessageId = messageId;
                CBK_Log.auditemailResult(wResult, email);

                return result;
            } else {
                //el correo no es una respuesta, se crea un CASO NUEVO
                //cuando recibimos un email, intentamos identificar los datos del remitente
                Id accountId = null;
                Id contactaccountId = null;
                Id contactId = null;
                Id cntctmultIdAR = null; 
                Integer contactNum = null;
                String recordTypeContact = null;
                string organizacion = null;
                string zona = null;
                string centroCaixaBankCliente = null;
                Account accountInfo = new Account();

                Map<Account, List<Contact>> mapaCuentasContactos = identificarCliente(email.fromAddress, body, subjectAcortado);


                if (mapaCuentasContactos.size() > 1)  {
                    //JAV: identificamos el contacto al que se le enviará el AR por el email aunque hayan varios contactos(el mail es el mismo para todos)
                    for (Account accountIdentificada : mapaCuentasContactos.keySet()) {
                        if (mapaCuentasContactos.get(accountIdentificada) != null){
                            for (Contact contacto : mapaCuentasContactos.get(accountIdentificada)) {
                                cntctmultIdAR = contacto.id;
                                recordTypeContact = contacto.recordType.DeveloperName;
                                contactaccountId = contacto.AccountId;
                                contactNum = +1;
                            }   
                        }
                    }
                    
                    //JAV: Tratar lista de accounts y quedarnos con la que tiene misma org y zona que buzón
                    //Cuentas relacionadas con el contacto identificado 
                    Account cuentaIdentificada = new Account();
                    List<AccountContactRelation> relatedContactAccounts = new List<AccountContactRelation>([SELECT AccountId, Account.SEG_Organizacion__c, Account.SEG_Zona__c,Account.SEG_FormulaOrganizacion__c, Account.SEG_FormulaZona__c FROM AccountContactRelation WHERE ContactId = :cntctmultIdAR]);
                    List<Id> accountIds = new List<Id>();

                    if(relatedContactAccounts.size() == 1){
                        cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :relatedContactAccounts[0].AccountId LIMIT 1];
                    } else {
                        for(AccountContactRelation aC : relatedContactAccounts) {
                            if(aC.Account.SEG_FormulaOrganizacion__c == organizacionBuzon && aC.Account.SEG_FormulaZona__c == zonaBuzon){
                                accountIds.add(aC.AccountId);
                            }
                        }
                        if(accountIds.size() == 1){
                            cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :accountIds[0] LIMIT 1];
                        }
                        //FIX: Cuándo el contacto es un empleado puede tener más de un centrocaixabank, le asignaremos su cuenta principal.
                        // US453615 0. Contacto- identificación cuando está en más de una cuenta. Si hay un contacto y + de una cuenta se la asigna la primera
                        //else if(contactNum == 1 && recordTypeContact == 'CC_Empleado'){
                        else if(contactNum == 1){
                            cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :contactaccountId LIMIT 1];
                        } else{                         
                            Account acc = new Account(
                                Name = 'CUENTA PENDIENTE ASOCIAR',RecordTypeId = recordTypeClienteSeg,SEG_Estado__c = 'Activo');
                            
                            if(Schema.sObjectType.Account.fields.Name.isCreateable()){
                                insert acc; 
                            }                                               
                            cuentaIdentificada = acc;       
                        }   
                    }                       
                    //VFR org/zonaKO 03/03/2022
                    if(cuentaIdentificada.RecordType.DeveloperName == 'CC_CentroCaixaBank'){
                        organizacionEmpresa = cuentaIdentificada.SEG_Organizacion__c;
                        zonaEmpresa = cuentaIdentificada.SEG_Zona__c;
                    } else{
                        organizacionEmpresa = cuentaIdentificada.SEG_FormulaOrganizacion__c;
                        zonaEmpresa = cuentaIdentificada.SEG_FormulaZona__c;
                    }
                    if (cuentaIdentificada != null) {
                        accountId = cuentaIdentificada.Id;

                        if (cuentaIdentificada.RecordTypeId == recordTypesCentroCaixaBank) {
                            centroCaixaBankCliente = accountId;
                        } else {
                            if (cuentaIdentificada.SEG_Prioridad_Carterizacion_Segmentos__c == true) {
                                centroCaixaBankCliente = cuentaIdentificada.SEG_Oficina_Gestora_Segmentos__c;
                            } else {
                                centroCaixaBankCliente = cuentaIdentificada.AV_OficinaPrincipal__c;
                            }
                        }
                    }
                    contactId = cntctmultIdAR;
                } else if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values() [0].size() == 1) {
                    //se identifica claramente cuenta y empresa
                    Contact contactoIdentificado = mapaCuentasContactos.values() [0] [0];
                    
                    Account cuentaIdentificada = new Account();
                    for (Account key : mapaCuentasContactos.keySet())  {
                        cuentaIdentificada = key;
                    }

                    //Cuentas relacionadas con el contacto identificado 
                    List<AccountContactRelation> relatedContactAccounts = new List<AccountContactRelation>([SELECT AccountId, Account.SEG_Organizacion__c, Account.SEG_Zona__c,Account.SEG_FormulaOrganizacion__c, Account.SEG_FormulaZona__c FROM AccountContactRelation WHERE ContactId = :contactoIdentificado.id]);
                    List<Id> accountIds = new List<Id>();

                    if(relatedContactAccounts.size() == 1){
                        cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :relatedContactAccounts[0].AccountId  LIMIT 1];
                    } else {
                        for(AccountContactRelation aC : relatedContactAccounts) {
                            if(aC.Account.SEG_Organizacion__c == organizacionBuzon && aC.Account.SEG_Zona__c == zonaBuzon) {
                                accountIds.add(aC.AccountId);
                            }
                        }
    
                        if(accountIds.size() == 1) {
                            cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :accountIds[0]  LIMIT 1];
                        } else if(contactoIdentificado.IsPersonAccount){ //JAV:Controlar particulares, no salen en accountcontactrelation
                            cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :contactoIdentificado.AccountId  LIMIT 1];
                        } else {    
                            Account acc = new Account(
                                Name = 'CUENTA PENDIENTE ASOCIAR',RecordTypeId = recordTypeClienteSeg,SEG_Estado__c = 'Activo');
                            if(Schema.sObjectType.Account.fields.Name.isCreateable()){
                                insert acc; 
                            }                   
                            cuentaIdentificada = acc;
                        }   
                    }                       
                    //VFR org/zonaKO 03/03/2022
                    if(cuentaIdentificada.RecordType.DeveloperName == 'CC_CentroCaixaBank') {
                        organizacionEmpresa = cuentaIdentificada.SEG_Organizacion__c;
                        zonaEmpresa = cuentaIdentificada.SEG_Zona__c;
                    } else{
                        organizacionEmpresa = cuentaIdentificada.SEG_FormulaOrganizacion__c;
                        zonaEmpresa = cuentaIdentificada.SEG_FormulaZona__c;
                    }

                    if (cuentaIdentificada != null) {
                        accountId = cuentaIdentificada.Id;

                        if (cuentaIdentificada.RecordTypeId == recordTypesCentroCaixaBank) {
                            centroCaixaBankCliente = accountId;
                        } else {
                            if (cuentaIdentificada.SEG_Prioridad_Carterizacion_Segmentos__c == true) {
                                centroCaixaBankCliente = cuentaIdentificada.SEG_Oficina_Gestora_Segmentos__c;
                            } else {
                                centroCaixaBankCliente = cuentaIdentificada.AV_OficinaPrincipal__c;
                            }
                        }
                    }

                    contactId = contactoIdentificado.Id;
                } else if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values() [0].size() == 0) {

                    //debemos crear el contacto con la información de la cual se dispone y meterlo en lista gris, siempre y cuando no sea CENTROCAIXABANK
                    Account cuentaIdentificada = new Account();
                    for (Account key : mapaCuentasContactos.keySet()) {
                        cuentaIdentificada = key;
                    }
                    if (cuentaIdentificada.RecordTypeId != recordTypesCentroCaixaBank) {    
                        //VFR 21/12 -> Cuando se identifica una cuenta por peticionario no es necesario asignar contacto al caso.
                        //List<String> nombreSplitter = CC_WS_Methods_ALF.getNombreSeparado(email.fromName);
                        List<String> nombreSplitter = new List<String>();
                        String apellidosSplit;
                        if(String.isNotBlank(email.fromName)){
                            nombreSplitter = CC_WS_Methods_ALF.getNombreSeparado(email.fromName);
                            apellidosSplit = nombreSplitter[1] + ' ' + nombreSplitter[2];
                        } else{
                            nombreSplitter.add(' ');
                        }
                        //String apellidosSplit = nombreSplitter[1] + ' ' + nombreSplitter[2];
                        Contact contactoListaGris = new Contact();
                        contactoListaGris.RecordTypeId = recordTypesClienteContacto;
                        contactoListaGris.FirstName = nombreSplitter[0];
                        contactoListaGris.LastName = (String.isNotBlank(apellidosSplit?.trim()))?apellidosSplit:email.FromAddress;
                        contactoListaGris.SEG_Estado__c = 'Pendiente de verificación';
                        contactoListaGris.AccountId = cuentaIdentificada.Id;
                        contactoListaGris.email = email.fromAddress;
                        if(Schema.sObjectType.Contact.fields.AccountId.isCreateable()){
                            Database.insert(contactoListaGris,false);
                            contactId = contactoListaGris.Id;
                        }
                        
                        accountId = cuentaIdentificada.Id; 
                    }
                }
                //JAV Detectamos una sola cuenta y multiples contactos con el mismo email
                else if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values() [0].size() > 1) {
                    //se identifica claramente cuenta y empresa
                    Contact contactoIdentificado = mapaCuentasContactos.values() [0] [0];
                    
                    Account cuentaIdentificada = new Account();
                    for (Account key : mapaCuentasContactos.keySet()) {
                        cuentaIdentificada = key;
                    }

                    //Cuentas relacionadas con el contacto identificado 
                    List<AccountContactRelation> relatedContactAccounts = new List<AccountContactRelation>([SELECT AccountId, Account.SEG_Organizacion__c, Account.SEG_Zona__c,Account.SEG_FormulaOrganizacion__c, Account.SEG_FormulaZona__c FROM AccountContactRelation WHERE ContactId = :contactoIdentificado.id]);
                    List<Id> accountIds = new List<Id>();

                    if(relatedContactAccounts.size() == 1) {
                        cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :relatedContactAccounts[0].AccountId  LIMIT 1];
                    } else {
                        for(AccountContactRelation aC : relatedContactAccounts) {
                            if(aC.Account.SEG_Organizacion__c == organizacionBuzon && aC.Account.SEG_Zona__c == zonaBuzon) {
                                accountIds.add(aC.AccountId);
                            }
                        }
    
                        if(accountIds.size() == 1) {
                            cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :accountIds[0]  LIMIT 1];
                        }
                        //JAV:Controlar particulares, no salen en accountcontactrelation
                        else if(contactoIdentificado.IsPersonAccount){
                            cuentaIdentificada = [SELECT RecordTypeId, RecordType.DeveloperName, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c, SEG_Organizacion__c, SEG_Zona__c, SEG_FormulaOrganizacion__c, SEG_FormulaZona__c FROM Account WHERE Id = :contactoIdentificado.AccountId  LIMIT 1]; }
                        else{   
                            Account acc = new Account(
                                Name = 'CUENTA PENDIENTE ASOCIAR',RecordTypeId = recordTypeClienteSeg,SEG_Estado__c = 'Activo');
                            if(Schema.sObjectType.Account.fields.Name.isCreateable()){
                                insert acc; 
                            }                       
                            cuentaIdentificada = acc;
                        }   
                    }                       
                    //VFR org/zonaKO 03/03/2022
                    if(cuentaIdentificada.RecordType.DeveloperName == 'CC_CentroCaixaBank'){
                        organizacionEmpresa = cuentaIdentificada.SEG_Organizacion__c;
                        zonaEmpresa = cuentaIdentificada.SEG_Zona__c;
                    }
                    else{
                        organizacionEmpresa = cuentaIdentificada.SEG_FormulaOrganizacion__c;
                        zonaEmpresa = cuentaIdentificada.SEG_FormulaZona__c;
                    }
                    if (cuentaIdentificada != null){
                        accountId = cuentaIdentificada.Id;
                        if (cuentaIdentificada.RecordTypeId == recordTypesCentroCaixaBank){
                            centroCaixaBankCliente = accountId;
                        }
                        else {
                            if (cuentaIdentificada.SEG_Prioridad_Carterizacion_Segmentos__c == true){
                                centroCaixaBankCliente = cuentaIdentificada.SEG_Oficina_Gestora_Segmentos__c;
                            }
                            else {
                                centroCaixaBankCliente = cuentaIdentificada.AV_OficinaPrincipal__c;
                            }
                        }
                    }

                    contactId = contactoIdentificado.Id;
                }
                //fin control contactos duplicados misma cuenta
                
                //JAV creamos contacto aunque no hayamos detectado Account que asignarle y este contacto va a la lista gris
                else if (mapaCuentasContactos.size() == 0) {

                    Account acc = new Account(
                        Name = 'CUENTA PENDIENTE ASOCIAR',
                        RecordTypeId = recordTypeClienteSeg,
                        SEG_Estado__c = 'Activo'
                    );
                    if(Schema.sObjectType.Account.fields.Name.isCreateable()){
                        insert acc; 
                    }

                    List<String> nombreSplitter = new List<String>();
                    String apellidosSplit;
                    Boolean vacio = false;
                    if(String.isNotBlank(email.fromName)){
                        nombreSplitter = CC_WS_Methods_ALF.getNombreSeparado(email.fromName);
                        apellidosSplit = nombreSplitter[1] + ' ' + nombreSplitter[2];
                    }
                    else{
                        nombreSplitter.add(' ');
                        vacio = true;
                    }               
                    ///apellidosSplit = nombreSplitter[1] + ' ' + nombreSplitter[2];
                    Contact contactoListaGris = new Contact();
                    contactoListaGris.RecordTypeId = recordTypesClienteContacto;
                    if (!vacio){
                        contactoListaGris.FirstName = nombreSplitter[0];
                        contactoListaGris.LastName = (String.isNotBlank(apellidosSplit?.trim()))?apellidosSplit:email.FromAddress;
                    }
                    else{
                        contactoListaGris.FirstName = email.FromAddress;
                    }
                    contactoListaGris.SEG_Estado__c = 'Pendiente de verificación';
                    //contactoListaGris.AccountId = listadoCuentas[0].Id;º
                    contactoListaGris.AccountId = acc.Id;
                    contactoListaGris.email = email.fromAddress;
                    if(Schema.sObjectType.Contact.fields.AccountId.isCreateable()){
                        Database.insert(contactoListaGris,false);
                        contactId = contactoListaGris.Id;
                    }
                }

                //Comprobación de email en listaNegra
                Boolean listaNegra = bloqueoListaNegra(email.fromAddress);

                Boolean rechazarCaso = false;
                Boolean cerrarCaso = false;
                Boolean crSalesforce = false;
                Boolean peticionarioCuerpo = false;
                Boolean peticionarioAsunto = false;
                Boolean controlMismaCR = false;
                List<SEG_Regladeclasificacion__c> reglaClasificacionRapida = new List<SEG_Regladeclasificacion__c>();
                List<SEG_Regladeclasificacion__c> reglaClas = new List<SEG_Regladeclasificacion__c>();
                SEG_ClasificacionRapida__c clasificacionRapida = new SEG_ClasificacionRapida__c();
                List<SEG_ClasificacionRapida__c> crLst = new List<SEG_ClasificacionRapida__c>();

                if (!listaNegra) {
                    // LLAMADA A LA FUNCION DEL MOTOR DE ASIGNACIÓN
                    List<Id> reglaClaisificacionId = determinarCR(email.fromAddress, email.toAddresses, email.ccAddresses, subjectAcortado, body);

                    reglaClasificacionRapida = [SELECT id, SEG_PeticionarioAsunto__c, SEG_PeticionarioCuerpo__c, SEG_ClasificacionRapida__c,SEG_ClasificacionRapida__r.SEG_Organizacion__c,SEG_Zona_RC__c, SEG_RechazarCaso__c, SEG_Cerrar_caso__c 
                                                FROM SEG_Regladeclasificacion__c 
                                                WHERE id IN :reglaClaisificacionId 
                                                AND SEG_ClasificacionRapida__r.SEG_Organizacion__c INCLUDES(:organizacionBuzon)]  ;
                    
                    for(SEG_Regladeclasificacion__c regla : reglaClasificacionRapida){
                        if(regla.SEG_Zona_RC__c == null || regla.SEG_Zona_RC__c.contains(zonaBuzon) || regla.SEG_Zona_RC__c.contains('Todas')){
                            reglaClas.add(regla);
                        }
                    }
                    if (reglaClas.size() == 1){
                        crSalesforce = true;
                        
                        if (!reglaClas.isEmpty()) {
                            peticionarioAsunto = reglaClas[0].SEG_PeticionarioAsunto__c;
                            peticionarioCuerpo = reglaClas[0].SEG_PeticionarioCuerpo__c;
                            rechazarCaso = reglaClas[0].SEG_RechazarCaso__c;
                            /* ARS - Cerrar Caso Cr */
                            cerrarCaso = reglaClas[0].SEG_Cerrar_caso__c;
                            
                            clasificacionRapida = [SELECT id, SEG_Canaldeentrada__c, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, SEG_Prioridad__c,SEG_CRAuditoria__c FROM SEG_ClasificacionRapida__c WHERE id = :reglaClas[0].SEG_ClasificacionRapida__c LIMIT 1];
                        }
                    } else if(reglaClas.size() > 1){
                        Set<Id> idRC = new Set<Id>();
                        
                        for(SEG_Regladeclasificacion__c rcfor: reglaClas){
                            idRC.add(rcfor.SEG_ClasificacionRapida__c);
                        }
                        crLst = [SELECT id, SEG_Canaldeentrada__c, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, SEG_Prioridad__c,SEG_CRAuditoria__c FROM SEG_ClasificacionRapida__c where id IN :idRC ];
                        if(!crLst.isEmpty() && crLst.size() == 1){
                            crSalesforce = true;
                            peticionarioAsunto = reglaClas[0].SEG_PeticionarioAsunto__c;
                            peticionarioCuerpo = reglaClas[0].SEG_PeticionarioCuerpo__c; 
                            rechazarCaso = reglaClas[0].SEG_RechazarCaso__c;
                            /* ARS - Cerrar Caso Cr */
                            cerrarCaso = reglaClas[0].SEG_Cerrar_caso__c;

                            clasificacionRapida = crLst[0]; 
                            controlMismaCR = true;
                        }
                    }
                }

                String asuntoCIF = identificarCIF(subjectAcortado);
                String cuerpoCIF = identificarCIF(body);

                Boolean findAccount = false;
                Boolean findAsunto = false;
                Boolean findCuerpo = false;

                //Si checks de identificación de peticionario en asunto y cuerpo estan marcados se deben buscar patrones de CIF en asunto y cuerpo 
                if (mapaCuentasContactos.size() > 0){
                    if(asuntoCIF != 'KO'){ //Se ha encontrado el identificador en el asunto
                        findAccount = true;
                        findAsunto = true;
                    } else if (peticionarioCuerpo && cuerpoCIF != 'KO'){ //Se ha encontrado el identificador en el cuerpo y en la regla de clasificación se ha marcado el peticionario en el cuerpo
                        findAccount = true;
                        findCuerpo = true;
                    }
                } else if(asuntoCIF != 'KO'){
                    findAccount = true;
                }

                List<Account> ac = new List<Account>();
                if (findAccount){
                    if(findAsunto && findCuerpo){
                        for (Account acc :[SELECT id, Name, Phone, SEG_Prioridad_Carterizacion_Segmentos__c, BillingAddress,AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c, CC_Numero_Oficina__c, SEG_Oficina_Gestora_Segmentos__c, SEG_N_centro__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, SEG_Prioridad__c, RecordTypeId FROM Account WHERE (CC_Numero_Documento__c = :cuerpoCIF OR CC_Numero_Documento__c = :asuntoCIF) AND RecordType.DeveloperName != 'CC_ClientePA' LIMIT 1]){ //DE76085 - Se añade una comprobación para que no se detecten clientes de tipo PA (Person Account) -- AND RecordType.DeveloperName != 'CC_ClientePA' 
                            accountInfo = acc;
                            accountId = acc.id;
                            ac.add(acc);
                        }
                    } else if(findAsunto){
                        for (Account acc :[SELECT id, Name, Phone, SEG_Prioridad_Carterizacion_Segmentos__c, BillingAddress,AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c, CC_Numero_Oficina__c, SEG_Oficina_Gestora_Segmentos__c, SEG_N_centro__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, SEG_Prioridad__c, RecordTypeId FROM Account WHERE CC_Numero_Documento__c = :asuntoCIF AND RecordType.DeveloperName != 'CC_ClientePA' LIMIT 1]){ //DE76085 - Se añade una comprobación para que no se detecten clientes de tipo PA (Person Account) -- AND RecordType.DeveloperName != 'CC_ClientePA' 
                            accountInfo = acc;
                            accountId = acc.id;
                            ac.add(acc);
                        }
                    } else if(findCuerpo){
                        for (Account acc :[SELECT id, Name, Phone, SEG_Prioridad_Carterizacion_Segmentos__c, BillingAddress,AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c, CC_Numero_Oficina__c, SEG_Oficina_Gestora_Segmentos__c, SEG_N_centro__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, SEG_Prioridad__c, RecordTypeId FROM Account WHERE CC_Numero_Documento__c = :cuerpoCIF AND RecordType.DeveloperName != 'CC_ClientePA' LIMIT 1]){ //DE76085 - Se añade una comprobación para que no se detecten clientes de tipo PA (Person Account) -- AND RecordType.DeveloperName != 'CC_ClientePA' 
                            accountInfo = acc;
                            accountId = acc.id;
                            ac.add(acc);
                        }
                    }
                } else {
                    ac = [SELECT Id, Name, Phone, SEG_Prioridad_Carterizacion_Segmentos__c, BillingAddress,AV_OficinaPrincipal__c,AV_OficinaPrincipal__r.CC_Numero_Oficina__c, RecordTypeId, CC_Numero_Oficina__c, SEG_Oficina_Gestora_Segmentos__c, SEG_N_centro__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c FROM Account where Id = :accountId  LIMIT 1];
                }

                foundAccount = accountId;
                foundContact = contactId;
                foundCR = clasificacionRapida;

                //Jaime: El correo no es una respuesta, se debe crear un nuevo Caso
                Case caso = new Case();


                


                caso.RecordTypeId = recordTypeSEG;
                caso.Origin = 'Email';
                caso.Subject = subjectAcortadoCaso;
                caso.Description = (String.isNotBlank(descriptionBody))?descriptionBody.left(32000):'';
                caso.SEG_ClasificacionRapida__c = clasificacionRapida?.id;
                caso.CC_MCC_Tematica__c = clasificacionRapida?.SEG_Tematica__c;
                caso.CC_MCC_ProdServ__c = clasificacionRapida?.SEG_Producto__c;
                caso.CC_MCC_Motivo__c = clasificacionRapida?.SEG_Motivo__c;
                caso.SEG_Detalle__c = clasificacionRapida?.SEG_Detalle__c;
                caso.SEG_SRAuditoria__c = clasificacionRapida?.SEG_CRAuditoria__c;
                
                if (accountInfo?.SEG_Prioridad__c == true) {
                    caso.Priority = 'High'; 
                } else if (foundCR.SEG_Prioridad__c == null && accountInfo?.SEG_Prioridad__c == false){
                    caso.Priority = 'Medium';
                } else {
                    caso.Priority = clasificacionRapida?.SEG_Prioridad__c;
                }

                if(caso.SEG_ClasificacionRapida__c != null){
                    caso.SEG_TipoClasificacion__c = 'Regla de clasificación';
                    caso.SEG_ClasificacionRapidaOrigen__c = caso.SEG_ClasificacionRapida__c;
                    caso.OS_ReglaUtilizada__c = reglaClas[0].Id;
                    caso.SEG_N_operaciones_del_caso__c = 1;
                    foundRC = reglaClas[0].Id;
                }

                if (clasificacionRapida?.SEG_Canaldeentrada__c == null) {
                    Caso.Origin = 'Email';
                } else{
                    caso.Origin = clasificacionRapida?.SEG_Canaldeentrada__c;
                }

                caso.AccountId = accountId;
                caso.ContactId = contactId;
                caso.SEG_Centro_Identificado__c = numCentroIden;
                caso.CC_MailTelfNotif__c = email.fromAddress;
                caso.SEG_Organizacion__c = organizacionBuzon;
                caso.SEG_Zona__c = zonaBuzon;

                //VFR org/zonaKO 07/10/2021
                if(organizacionEmpresa != null && zonaEmpresa != null){
                    if(organizacionEmpresa != organizacionBuzon && zonaEmpresa != zonaBuzon)
                    {
                        caso.SEG_orgZonaKO__c = true;
                    }
                }
                caso.OwnerId = colasBO[0].id;

                if(rechazarCaso){
                    caso.Status = 'Descartado';
                    caso.SEG_Subestado__c = 'Rechazada';
                }
                else if(cerrarCaso){
                    /* ARS - Cerrar Caso Cr */
                    caso.Status = 'Cerrado';
                    /* caso.SEG_Subestado__c = 'Rechazada'; */
                }
                else{
                    caso.Status = 'Activo';
                    caso.SEG_Subestado__c = 'Sin propietario anterior';
                }
                caso.CC_AcuseRecibo__c = '0';
                caso.SEG_Email_Buzon_Entrada__c = buzonCaixa;

                //Asignar número de centro

                if (!ac.isEmpty()){
                    if(ac[0].Phone != null){
                        caso.SEG_Telefono_Centro__c = ac[0].Phone;
                    }
                    if (ac[0].BillingAddress != null) {
                        String ciudad = ac[0].BillingAddress.getCity();
                        String pais = ac[0].BillingAddress.getCountry();
                        String postal = ac[0].BillingAddress.getPostalCode();
                        String calle = ac[0].BillingAddress.getStreet();
                        caso.SEG_Direccion_del_Centro__c = + pais + ', ' + ciudad + ', ' + postal + ', ' + calle;
                    }
                    if(ac[0].CC_Numero_Oficina__c != null && ac[0].RecordTypeId == recordTypesCentroCaixaBank){
                        caso.SEG_Numero_de_centro__c = ac[0].Id;
                        caso.SEG_Numero_centro__c = ac[0].CC_Numero_Oficina__c;
                    } else {
                        if(ac[0].SEG_Prioridad_Carterizacion_Segmentos__c == true && ac[0].SEG_Oficina_Gestora_Segmentos__c != null){
                            caso.SEG_Numero_de_centro__c = ac[0].SEG_Oficina_Gestora_Segmentos__c;
                            caso.SEG_Numero_centro__c = ac[0].SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c;
                        } else if(ac[0].AV_OficinaPrincipal__c != null){
                            caso.SEG_Numero_de_centro__c = ac[0].AV_OficinaPrincipal__c;
                            caso.SEG_Numero_centro__c = ac[0].AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
                        } else {
                            caso.SEG_Numero_centro__c = ac[0].SEG_N_centro__c;
                        }
                    }
                }

                if (listaNegra){
                    caso.Status = 'Descartado';
                    caso.SEG_Subestado__c = 'Lista negra';
                }
                foundStatus = caso.Status;
                foundSubestado = caso.SEG_Subestado__c;
    

                // Por defecto, preparamos el caso al grupo mccBuzon.
                caso.SEG_Grupo__c = mccBuzon;
                caso.SEG_Email_Generador__c = emailfrom?.left(200);


                /* Jaime: El correo va a un buzón de COPS (UAFE/EXPRESS), se informa el id del mail origen, ya se hacía
                OR El correo viene de COPS y su caso no está relacionado
                Indico el messageId en el campo SEG_Id_Related_Mail__c del caso que voy a crear. - Se hace */
                if(oSMailRelated || (oSMailRelatedFrom && lstCasosCOPS.size() > 0)){
                    caso.SEG_Id_Related_Mail__c = email.messageId;
                }

                try{
                    if(Test.isRunningTest() && subjectAcortado == 'TESTCATCHMETHOD'){
                        Case casoTest = new Case();
                        casoTest.Id = '54654654654654';

                        //Jaime: la nueva llamada a SEG_CasosSEG_COPSrelacionados cómo afecta a los test?
                        insert(casoTest);
                    }else{
                        insert(caso);
                        casoCreado = true;

                        //Jaime: DESPUÉS de insertar el Caso se añade la preparación del encolado de Relacionados ya existente en OS_EmailService.procesarCorreoEntrante()
                        if(caso.SEG_Id_Related_Mail__c != null && caso.Id != null)
                        {
                            SEG_Settings__c delay = SEG_Settings__c.getValues('SEG_DelaySEGCOPS');//.getAll().values();
                            Integer tiempo = delay != null ? Integer.valueOf(delay.SEG_Delay__c) : 1;
                            DateTime dt = DateTime.now();
                            Long dateInMilliseconds = dt.getTime();

                            AsyncOptions options = new AsyncOptions();
                            options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(caso.Id).addString(String.valueOf(dateInMilliseconds)).build();
                            options.MinimumQueueableDelayInMinutes = Integer.valueOf(tiempo);
            
                            lstCasosCOPS[0].SEG_Id_Related_Mail__c = email.messageId;
                            update lstCasosCOPS[0];

                            try {
                                //Jaime: si no añadimos el cuarto parámetro idCasoExistente no tendremos forma de encontrar el caso de COPS en la BD, además evitamos tener que hacer un UPDATE sobre el caso de COPS de su SEG_Id_Related_Mail__c
                                ID jobID = System.enqueueJob(new SEG_CasosSEG_COPSrelacionados(email.messageId, email.htmlBody, email.subject), options);
                                
                            } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);  }
                        }
                        
                    }
                }catch(Exception ex){
                    if(!casoCreado){
                        CBK_Log.error(ex, 'Error en el envio de email', email);
                        caso.RecordTypeId = recordTypeSEG;
                        caso.Origin = 'Email';
                        caso.Subject = subjectAcortadoCaso;
                        caso.Description = (String.isNotBlank(descriptionBody))?descriptionBody.left(32000):'';
                        caso.SEG_ClasificacionRapida__c = clasificacionRapida?.id;
                        caso.SEG_Centro_Identificado__c = numCentroIden;

                        //DE70923: Cognitive- Tipo de clasificación en blanco
                        if(caso.SEG_ClasificacionRapida__c != null){
                            caso.SEG_TipoClasificacion__c = 'Regla de clasificación';
                            caso.SEG_ClasificacionRapidaOrigen__c = clasificacionRapida?.id;
                            caso.OS_ReglaUtilizada__c = reglaClas[0]?.Id;
                            caso.SEG_N_operaciones_del_caso__c = 1;                         
                        } else {
                            caso.SEG_TipoClasificacion__c = 'No se ha podido clasificar';
                        }
                        caso.CC_MCC_Tematica__c = clasificacionRapida?.SEG_Tematica__c;
                        caso.CC_MCC_ProdServ__c = clasificacionRapida?.SEG_Producto__c;
                        caso.CC_MCC_Motivo__c = clasificacionRapida?.SEG_Motivo__c;
                        caso.SEG_Detalle__c = clasificacionRapida?.SEG_Detalle__c;
                        caso.SEG_SRAuditoria__c = clasificacionRapida?.SEG_CRAuditoria__c;
                        //Por defecto ponemos idioma es
                        caso.SEG_Idioma__c = 'es';
                        caso.AccountId = (String.isNotBlank(foundAccount)&& !ex.getMessage().contains('UNABLE_TO_LOCK_ROW'))?foundAccount:null;
                        caso.ContactId = (String.isNotBlank(foundContact)&& !ex.getMessage().contains('UNABLE_TO_LOCK_ROW'))?foundContact:null;

                        if(foundOwner != null){
                            caso.OwnerId = foundOwner;
                        }
                        caso.CC_MailTelfNotif__c = email.fromAddress;
                        caso.SEG_Organizacion__c = (String.isNotBlank(foundOrg))?foundOrg:null;
                        caso.SEG_Zona__c = (String.isNotBlank(foundOrg)&& String.isNotBlank(foundZona))?foundZona:null;
                        caso.Status = (String.isNotBlank(foundStatus))?foundStatus:null;
                        caso.SEG_Subestado__c = (String.isNotBlank(foundSubestado)&&String.isNotBlank(foundStatus))?foundSubestado:null;
                        caso.CC_AcuseRecibo__c = '0';
                        caso.SEG_Email_Buzon_Entrada__c = (String.isNotBlank(foundBuzon))?foundBuzon:null;
                        caso.SEG_Grupo__c = (String.isNotBlank(foundGrupo))?foundGrupo:null;
                        caso.SEG_Email_Generador__c = emailfrom?.left(200);
                        insert(caso);
                        casoCreadoError = true;
                        
                        // DS1365 - Se corrige la creación de casos con cuentas y contactos en blanco
                        if(caso.Id != null && ex.getMessage().contains('UNABLE_TO_LOCK_ROW') || Test.isRunningTest()){
                            CBK_SCH_PendingProcess__c actualizacionCuentas = new CBK_SCH_PendingProcess__c(Schedule_Time__c= DateTime.now().addMinutes(3),
                            ClassName__c = 'SEG_Queueable_UpdtCase', RecordId__c = caso.Id, Param1__c = foundAccount, Param2__c = foundContact);
                            insert actualizacionCuentas;
                        }

                        //Trazabilidad Emailservice y emailmessage COE
                        CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                        wResult.Status = 'KO';
                        wResult.Detail = ex.getMessage()?.left(255);
                        wResult.CaseId = parentMessageId;
                        wResult.EmailMessageId = messageId;
                        CBK_Log.auditemailResult(wResult, email);
                    }

                    try{
                        // Se comenta la autoasignación par que no se haga dos veces cuando el caso haya fallado la primera inserción. Se hace más tarde en el código igualmente
                        //SEG_Case_Operativas_Controller.autoAsignarGrupo(caso.Id);
                        if (emailMessageCreado == false){
                            Map<String, sObject> mapResultado = procesarAdjuntos(caso.Id, caso, email, envelope, body, buzonCaixa);
                            if (mapResultado.containsKey('correo')) {
                                mensaje  = (EmailMessage)mapResultado.get('correo');
                            }
                            List<Case> casoUpdt = new List<Case>();
                            if (mapResultado.containsKey('caso')) {
                                casoUpdt.add((Case)mapResultado.get('caso'));
                            }

                            if (!casoUpdt.isEmpty()) {
                                update casoUpdt;
                            }

                            messageId = mensaje.Id;
                            parentMessageId = mensaje.ParentId;
                            emailMessageCreado = true;
                        }
                    } catch(Exception e){
                        // Registrar error
                        CBK_Log.error(e, 'Error en el envio de email', email);
    
                        FeedItem errorAsignacion = new FeedItem();
                        errorAsignacion.ParentId = caso.id;
                        errorAsignacion.Body = 'Ha habido un error al procesarAdjuntos del mail. Error : ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
                        errorAsignacion.Type = 'TextPost';
                        if(Schema.sObjectType.FeedItem.fields.Body.isCreateable()){
                            insert errorAsignacion;
                        }
                    }
                }

                List<Id> casoId = new List<Id> ();
                casoId.add(caso.id);
                
                // JAV 18/06 ya identificamos la excepción en SEG_Case_Operativas_Controller.autoAsignarGrupo y la insertamos, estamos duplicando con la línea de abajo
                //identificarExcepciones(caso.Id);

                //DE66400 aunque no aplican se están añadiendo en reglas inconsistentes reglas que no coinciden con el buzón de entrada
                if(reglaClas.size() > 1 && !controlMismaCR){
                    List<SEG_Reglas_inconsitentes__c> listRI = new List<SEG_Reglas_inconsitentes__c> ();
                    for (SEG_Regladeclasificacion__c rcId : reglaClas){
                        SEG_Reglas_inconsitentes__c reglaInconistente = new SEG_Reglas_inconsitentes__c();
                        reglaInconistente.SEG_Regla_de_clasificacion__c = rcId.Id;
                        reglaInconistente.SEG_Caso__c = caso.id;
                        listRI.add(reglaInconistente);
                    }
                    if (listRI.size() >= 1 && Schema.sObjectType.SEG_Reglas_inconsitentes__c.fields.SEG_Caso__c.isCreateable()) {
                        insert(listRI);
                    }
                }
                
                try{
                    if (emailMessageCreado == false){

                        Map<String, sObject> mapResultado = procesarAdjuntos(caso.Id, caso, email, envelope, body, buzonCaixa);

                        if (mapResultado.containsKey('correo')) {
                            mensaje  = (EmailMessage)mapResultado.get('correo');
                        }
                        List<Case> casoUpdt = new List<Case>();
                        if (mapResultado.containsKey('caso')) {
                            casoUpdt.add((Case) mapResultado.get('caso'));
                        }

                        if (!casoUpdt.isEmpty()) {
                            update casoUpdt;
                        }

                        messageId = mensaje.Id;
                        parentMessageId = mensaje.ParentId;
                        emailMessageCreado = true;
                    }
                } catch(Exception e){
                    // Registrar error
                    CBK_Log.error(e, 'Error en el envio de email', email);
                    FeedItem errorEmail = new FeedItem();
                    errorEmail.ParentId = caso.id;
                    errorEmail.Body = 'Ha habido un error al procesar el correo electrónico.Error : ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
                    errorEmail.Type = 'TextPost';
                    insert errorEmail;
                }

                if (!listaNegra){
                    //VFR 22/12 Detectar idioma por cognitive y mandar ACUSE de recibo 
                    SEG_Detector_Idioma.setIdiomaCaso(casoId, email.fromAddress, subjectAcortado, body );
                }

                try{
                    SEG_Case_Operativas_Controller.autoAsignarGrupo(caso.Id);
                }
                catch(Exception e){
                    // Registrar error
                    CBK_Log.error(e, 'Error en el envio de email', email);

                    FeedItem errorAsignacion = new FeedItem();
                    errorAsignacion.ParentId = caso.id;
                    errorAsignacion.Body = 'Ha habido un error al autoasignar el caso. Error : ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
                    errorAsignacion.Type = 'TextPost';
                    if(Schema.sObjectType.FeedItem.fields.Body.isCreateable()){
                        insert errorAsignacion;
                    }
                }
                
                emailCreado = true;
                if (!crSalesforce && !Test.isRunningTest()){
                    //al no encontrar clasificación rapida en SF llamamos a Cognitive
                    if(organizacionBuzon =='Financiación Estructurada'){
                        SEG_Cognitive_FFEE.getCRFFEE(caso.id);
                    }
                    else{
                        SEG_CognitiveCR.getCRCognitive(caso.id);
                    }
                }
                
                //Detectar duplicados del caso insertado
                Set<Id> caseIds = new Set<Id> { caso.Id };
                SEG_Case_Duplicated caseDulicatedProcess = new SEG_Case_Duplicated(caseIds);
                System.enqueueJob(caseDulicatedProcess);

                result.success = true;

                CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
                wResult.Status = 'OK';
                wResult.Detail = 'Envio correcto';
                wResult.CaseId = parentMessageId;
                wResult.EmailMessageId = messageId;
                CBK_Log.auditemailResult(wResult, email);

                if(Test.isRunningTest() && subjectAcortado == 'TESTCATCHGRANDE'){
                    casoCreado = false;
                    casoCreadoError = false;
                    emailCreado = false;
                    Case casoTest = new Case();
                    casoTest.Id = '54654654654654';
                    insert(casoTest);
                }

                return result;
            }
        } catch(Exception e){
            // Registrar error
            CBK_Log.error(e, 'Error en el envio de email', email);
            String bodycatch = '';
            if (String.isNotBlank(email.plainTextBody)) {
                bodycatch = email.plainTextBody.left(131000);
            } else if (String.isNotBlank(email.htmlBody)) {
                bodycatch = email.htmlBody.stripHtmlTags().left(131000);
            }

            Case nuevoCaso = new Case();
            List<Id> listaCaso = new List<Id>();
            listacaso.add(nuevoCaso.Id);
            //Si la creación de caso da error 
            if(!casoCreado && !casoCreadoError){
                nuevoCaso.RecordTypeId = recordTypeSEG;
                nuevoCaso.Origin = 'Email';
                nuevoCaso.Subject = subjectAcortadoCaso;
                //String body = email.Body;

                nuevoCaso.Description = bodycatch.left(32000);
                nuevoCaso.AccountId = (String.isNotBlank(foundAccount)&& !e.getMessage().contains('UNABLE_TO_LOCK_ROW'))?foundAccount:null;
                nuevoCaso.ContactId = (String.isNotBlank(foundContact)&& !e.getMessage().contains('UNABLE_TO_LOCK_ROW'))?foundContact:null;
                nuevoCaso.SEG_Centro_Identificado__c = numCentroIden;
                if(foundOwner != null){
                    nuevoCaso.OwnerId = foundOwner;
                }
                nuevoCaso.CC_MailTelfNotif__c = email.fromAddress;
                nuevoCaso.SEG_Organizacion__c = (String.isNotBlank(foundOrg))?foundOrg:null;
                nuevoCaso.SEG_Zona__c = (String.isNotBlank(foundOrg)&& String.isNotBlank(foundZona))?foundZona:null;
                nuevoCaso.Status = (String.isNotBlank(foundStatus))?foundStatus:null;
                nuevoCaso.SEG_Subestado__c = (String.isNotBlank(foundSubestado)&&String.isNotBlank(foundStatus))?foundSubestado:null;
                nuevoCaso.CC_AcuseRecibo__c = '0';
                nuevoCaso.SEG_Email_Buzon_Entrada__c = (String.isNotBlank(foundBuzon))?foundBuzon:null;
                nuevoCaso.SEG_Grupo__c = (String.isNotBlank(foundGrupo))?foundGrupo:null;
                nuevoCaso.SEG_ClasificacionRapida__c = (String.isNotBlank(foundCR.Id))?foundCR.Id:null;

                //DE70923: Cognitive- Tipo de clasificación en blanco
                if(nuevoCaso.SEG_ClasificacionRapida__c != null){
                    nuevoCaso.SEG_TipoClasificacion__c = 'Regla de clasificación';
                    nuevoCaso.SEG_ClasificacionRapidaOrigen__c = foundCR.Id;
                    nuevoCaso.OS_ReglaUtilizada__c = foundRC;
                    nuevoCaso.SEG_N_operaciones_del_caso__c = 1;                            
                }
                nuevoCaso.SEG_Email_Generador__c = email.fromAddress?.left(200);
                insert nuevoCaso; 
                
                // DS1365 - Se corrige la creación de casos con cuentas y contactos en blanco
                if(nuevoCaso.Id != null && e.getMessage().contains('UNABLE_TO_LOCK_ROW') || Test.isRunningTest()){
                    CBK_SCH_PendingProcess__c actualizacionCuentas = new CBK_SCH_PendingProcess__c(Schedule_Time__c= DateTime.now().addMinutes(3),
                    ClassName__c = 'SEG_Queueable_UpdtCase', RecordId__c = nuevoCaso.Id, Param1__c = foundAccount, Param2__c = foundContact);
                    insert actualizacionCuentas;
                }
            } 
            //Si la creación del emailMessage da error
            if(!emailCreado) {
                
                //EmailMessage mensaje = procesarAdjuntos(nuevoCaso.id, email, envelope, bodycatch, buzonCaixa);
                if (emailMessageCreado == false){
                    Map<String, sObject> mapResultado = procesarAdjuntos(nuevoCaso.Id, nuevoCaso, email, envelope, body, buzonCaixa);
                    if (mapResultado.containsKey('correo')) {
                        mensaje  = (EmailMessage)mapResultado.get('correo');
                    }
                    List<Case> casoUpdt = new List<Case>();
                    if (mapResultado.containsKey('caso')) {
                        casoUpdt.add((Case)mapResultado.get('caso'));
                    }

                    if (!casoUpdt.isEmpty()) {
                        update casoUpdt;
                    }

                    messageId = mensaje.Id;
                    parentMessageId = mensaje.ParentId;
                    emailMessageCreado = true;
                }
                SEG_Detector_Idioma.setIdiomaCaso(listaCaso, email.fromAddress, subjectAcortado, body);

                if(!Test.isRunningTest() && mensaje.ParentId != null){
                    FeedItem post = new FeedItem();
                    post.ParentId = mensaje.ParentId;
                    post.Body = 'Ha habido un error al crear el caso. Debe ser revisado manualmente por un agente. Error : ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
                    post.Type = 'TextPost';
                    insert post;
                }
            }
            //Trazabilidad Emailservice y emailmessage COE
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'KO';
            wResult.Detail = e.getMessage()?.left(255);
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);
            return null;            
        }
    }

    public static boolean checkmailad(String[] semillas, string buzonCaixa) {
        //Comprobamos si el email (Organizacion y Zona) al que se envia la respuesta al caso concuerda con el caso
        List<Case> caso = [SELECT SEG_Zona__c, SEG_Organizacion__c FROM case WHERE (CreatedDate = LAST_N_MONTHS:6 OR CreatedDate = THIS_MONTH OR CreatedDate = TODAY) AND  SEG_semillaId__c = :semillas[0] LIMIT 1];
        List<SEG_Buzon__mdt> buzonMail = [SELECT SEG_Organizacion__c, SEG_Zona__c FROM SEG_Buzon__mdt WHERE SEG_Correo_de_procedencia__c = :buzonCaixa and SEG_Organizacion__c<> 'Por defecto' and SEG_Zona__c<> 'Por defecto'  LIMIT 1];
        if (!caso.isEmpty() && caso[0].SEG_Organizacion__c == buzonMail[0].SEG_Organizacion__c && caso[0].SEG_Zona__c == buzonMail[0].SEG_Zona__c) { //NPC: 17 febrero 2020: posible impacto si se reutilizan buzones por dis
            return true;
        } else {
            return false;
        }
    }

    public static Map<String,List<Case>> procesarReferencias(String[] semillas, String[] sNumbers, String organizacionBuzon, String zonaBuzon) {
        //JAV PARA PODER BUSCAR SEMILLAS EN CASOS FUSIONADOS A TRAVÉS DEL CAMPO SEG_Fusion_Semilla1__c
        List<Id> listIdRecordTypeSegmentos = new List<Id> ();
        Map<String,List<Case>> respuestaReferencias = new Map<String,List<Case>>();
        List<Case> caseUpdate = new List<Case>();
        List<Case> lstCasereferenciados = new List<Case>();
        String[] filters = new String[] { };
        for (string semillaref : semillas) {
            filters.add('%' + semillaref + '%');
        }
    
        recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
    
        listIdRecordTypeSegmentos.add(recordTypeSEG);
        listIdRecordTypeSegmentos.add(recordTypeSeguimiento);
    
        //Se obtiene el caso con el id de la semilla más reciente
        List<Case> casosSemilla = [SELECT id, SEG_Case_Owner__c, SEG_OldSubStatus__c, Priority, SEG_OldStatus__c, SEG_Subestado__c, CreatedDate, CaseNumber, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, AccountId, SEG_Zona__c, SEG_Organizacion__c, SEG_Grupo__c, SEG_Grupo_colaborador_Externo__c, Status FROM Case WHERE  (CreatedDate = LAST_N_MONTHS:6 OR CreatedDate = THIS_MONTH OR CreatedDate = TODAY) AND RecordTypeId IN :listIdRecordTypeSegmentos AND (SEG_SemillaId__c IN :semillas OR SEG_Fusion_Semilla1__c Like :filters) AND SEG_Organizacion__c = :organizacionBuzon AND SEG_Zona__c = :zonaBuzon  ORDER BY createdDate DESC LIMIT 1];

        //Se obtiene el caso con el casenumber más reciente de Segmentos o de COPS que esté relacionado a un caso de Segmentos
        List<Case> casosNumber = new List<Case> ([SELECT id, CC_CasoRelacionado__c, CC_CasoRelacionado__r.SEG_Case_Owner__c,CC_CasoRelacionado__r.SEG_OldSubStatus__c,CC_CasoRelacionado__r.Priority,CC_CasoRelacionado__r.SEG_OldStatus__c,CC_CasoRelacionado__r.SEG_Subestado__c,CC_CasoRelacionado__r.CreatedDate,CC_CasoRelacionado__r.CaseNumber,CC_CasoRelacionado__r.SEG_Detalle__c,CC_CasoRelacionado__r.CC_MCC_Motivo__c,CC_CasoRelacionado__r.CC_MCC_ProdServ__c,CC_CasoRelacionado__r.CC_MCC_Tematica__c,CC_CasoRelacionado__r.AccountId,CC_CasoRelacionado__r.SEG_Zona__c,CC_CasoRelacionado__r.SEG_Organizacion__c,CC_CasoRelacionado__r.SEG_Grupo__c,CC_CasoRelacionado__r.SEG_Grupo_colaborador_Externo__c,CC_CasoRelacionado__r.Status, recordTypeId, SEG_Case_Owner__c, SEG_OldSubStatus__c, Priority, SEG_OldStatus__c, SEG_Subestado__c, CreatedDate, CaseNumber, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, AccountId, SEG_Zona__c, SEG_Organizacion__c, SEG_Grupo__c, SEG_Grupo_colaborador_Externo__c, Status 
        FROM Case 
        WHERE (CreatedDate = LAST_N_MONTHS:6 OR CreatedDate = THIS_MONTH OR CreatedDate = TODAY) 
        AND CaseNumber IN :sNumbers 
        AND ((RecordTypeId IN :listIdRecordTypeSegmentos 
        AND SEG_Organizacion__c = :organizacionBuzon 
        AND SEG_Zona__c = :zonaBuzon) 
        OR (RecordType.DeveloperName IN ('OS_Cliente','OS_Empleado')
        AND CC_CasoRelacionado__c != NULL)) 
        ORDER BY createdDate DESC LIMIT 1]);

        //Alejandro: Se obtiene el caso con el casenumber más reciente de COPS que esté relacionado a un caso de Segmentos

        /* List<Case> casosNumberCOPS = new List<Case> ([SELECT id, CC_CasoRelacionado__c, CC_CasoRelacionado__r.SEG_Case_Owner__c,CC_CasoRelacionado__r.SEG_OldSubStatus__c,CC_CasoRelacionado__r.Priority,CC_CasoRelacionado__r.SEG_OldStatus__c,CC_CasoRelacionado__r.SEG_Subestado__c,CC_CasoRelacionado__r.CreatedDate,CC_CasoRelacionado__r.CaseNumber,CC_CasoRelacionado__r.SEG_Detalle__c,CC_CasoRelacionado__r.CC_MCC_Motivo__c,CC_CasoRelacionado__r.CC_MCC_ProdServ__c,CC_CasoRelacionado__r.CC_MCC_Tematica__c,CC_CasoRelacionado__r.AccountId,CC_CasoRelacionado__r.SEG_Zona__c,CC_CasoRelacionado__r.SEG_Organizacion__c,CC_CasoRelacionado__r.SEG_Grupo__c,CC_CasoRelacionado__r.SEG_Grupo_colaborador_Externo__c,CC_CasoRelacionado__r.Status, recordTypeId, SEG_Case_Owner__c, SEG_OldSubStatus__c, Priority, SEG_OldStatus__c, SEG_Subestado__c, CreatedDate, CaseNumber, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, AccountId, SEG_Zona__c, SEG_Organizacion__c, SEG_Grupo__c, SEG_Grupo_colaborador_Externo__c, Status 
        FROM Case 
        WHERE (CreatedDate = LAST_N_MONTHS:6 OR CreatedDate = THIS_MONTH OR CreatedDate = TODAY) 
        AND RecordType.DeveloperName IN ('OS_Cliente','OS_Empleado')
        AND (CC_CasoRelacionado__c != NULL OR Casenumber IN :sNumbers)
        ORDER BY createdDate DESC LIMIT 1]); */

        //Jaime: Se obtiene el caso de COPS con el caseNumber del Subject del Email y que no esté ya relacionado a un caso de Segmentos.
        List<Case> casosNumberCOPS = new List<Case> ([SELECT id, CC_CasoRelacionado__c, CC_CasoRelacionado__r.SEG_Case_Owner__c,CC_CasoRelacionado__r.SEG_OldSubStatus__c,CC_CasoRelacionado__r.Priority,CC_CasoRelacionado__r.SEG_OldStatus__c,CC_CasoRelacionado__r.SEG_Subestado__c,CC_CasoRelacionado__r.CreatedDate,CC_CasoRelacionado__r.CaseNumber,CC_CasoRelacionado__r.SEG_Detalle__c,CC_CasoRelacionado__r.CC_MCC_Motivo__c,CC_CasoRelacionado__r.CC_MCC_ProdServ__c,CC_CasoRelacionado__r.CC_MCC_Tematica__c,CC_CasoRelacionado__r.AccountId,CC_CasoRelacionado__r.SEG_Zona__c,CC_CasoRelacionado__r.SEG_Organizacion__c,CC_CasoRelacionado__r.SEG_Grupo__c,CC_CasoRelacionado__r.SEG_Grupo_colaborador_Externo__c,CC_CasoRelacionado__r.Status, recordTypeId, SEG_Case_Owner__c, SEG_OldSubStatus__c, Priority, SEG_OldStatus__c, SEG_Subestado__c, CreatedDate, CaseNumber, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, AccountId, SEG_Zona__c, SEG_Organizacion__c, SEG_Grupo__c, SEG_Grupo_colaborador_Externo__c, Status 
        FROM Case 
        WHERE (CreatedDate = LAST_N_MONTHS:6 OR CreatedDate = THIS_MONTH OR CreatedDate = TODAY) 
        AND RecordType.DeveloperName IN ('OS_Cliente','OS_Empleado')
        AND CC_CasoRelacionado__c = NULL 
        AND Casenumber IN :sNumbers
        ORDER BY createdDate DESC LIMIT 1]);

        //Si el caso de es COPS, se toman los datos del caso de segmentos a partir del de cops para poder utilizar el caso de Segmentos.
        if (!casosNumber.isEmpty() && casosNumber[0].RecordTypeId != recordTypeSEG && casosNumber[0].RecordTypeId != recordTypeSeguimiento) {
            Case casoSEG = casosNumber[0].CC_CasoRelacionado__r;
            casosNumber[0] = casoSEG;
        }

        if(!casosSemilla.isEmpty() && casosNumber.isEmpty()){
            caseUpdate.add(casosSemilla[0]);
        } else if(casosSemilla.isEmpty() && !casosNumber.isEmpty()){
            caseUpdate.add(casosNumber[0]);
        } else if(!casosSemilla.isEmpty() && !casosNumber.isEmpty()){
            lstCasereferenciados.add(casosSemilla[0]);
            if (casosSemilla[0].Id != casosNumber[0].Id) {
                lstCasereferenciados.add(casosNumber[0]);
            }
            
            Case casoReciente = casosSemilla[0];
            if(casosNumber[0].CreatedDate > casoReciente.CreatedDate){
                casoReciente = casosNumber[0];
            }
            caseUpdate.add(casoReciente);
        }

        if (!caseUpdate.isEmpty()) {
            caseUpdate[0].SEG_OldStatus__c = caseUpdate[0].status;
            caseUpdate[0].SEG_OldSubStatus__c = caseUpdate[0].SEG_Subestado__c;
        }

        respuestaReferencias.put('casoReciente', caseUpdate);
        respuestaReferencias.put('casosReferenciados', lstCasereferenciados);
        /* Alejandro:
         respuestaReferencias.put('casosCOPS', lstCasereferenciados); */

        //Jaime:
        if(!casosNumberCOPS.isEmpty()){
            respuestaReferencias.put('casosCOPS', casosNumberCOPS);
        }
        

        return respuestaReferencias;
    }

    public static String crearNotas(String mensajenota) {
        //Creamos una nota con todos los casos relacionados en el cuerpo de la misma
        ContentNote objCntNote = new ContentNote();
        objCntNote.Title = 'Casos Relacionados';
        objCntNote.Content = Blob.valueOf(mensajenota);
        if(Schema.sObjectType.ContentNote.fields.Title.isCreateable()){
            insert objCntNote;
        }
        return objCntNote.Id;
    }
    public static void crearLinkNota(List<Case> listCasos, String objCntNoteid) {
        //Linkeamos la nota a todos los casos involucrados en el email
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink> ();
        for (Case caso : listCasos){
            ContentDocumentLink objCntDocLink = new ContentDocumentLink();
            objCntDocLink.LinkedEntityId = caso.id;
            objCntDocLink.ContentDocumentId = objCntNoteid;
            objCntDocLink.shareType = 'V';
            listContentDocumentLink.add(objCntDocLink);
        }
        if (listContentDocumentLink.size() > 0 && Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
            insert listContentDocumentLink;
        }
    }

    public static String[] identificarsrNumber(String asunto) { 
        //El casenumber es una cadena de 8 dígitos
        // Con el cambio en la metadata el número de dígitos ahora sera dinámico
        String nDigitos = '8';
        String[] referencia = new List<String> ();
        // Pattern pattern = Pattern.compile('\\d{8}'); 
        Pattern pattern = Pattern.compile('(?<![a-zA-Z])(?<!\\d)\\d{'+nDigitos +'}(?!\\d)(?![a-zA-Z])');
        Matcher matcher = pattern.matcher(asunto);      
        while (matcher.find()){
            referencia.add(matcher.group());        
        }
            
        return referencia;
    }


    public static String[] identificarSemillaId(String correo) {
        //Buscamos semillaId en el body del correo
        //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes
        String[] referencia = new List<String> ();
        if (correo != null) {
            String[] splitCorreo = correo.split('(?U)\\s+');
            for (Integer i = 0; i<splitCorreo.size(); i++) {
                if (splitCorreo[i].substringBetween('#@SEG', '#') != null) {
                    referencia.add('#@SEG' + splitCorreo[i].substringBetween('#@SEG', '#') + '#');
                }
            }
        }
        //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
        //Espacio para HTMLBody
        return referencia;
    }

    public static String identificarNumCentro(List<String> emailAddress) {
        Pattern patron = Pattern.compile('^[0-9]{4,5}@caixabank');
        String numCentro = '';
        if(!(emailAddress == null) && !emailAddress.isEmpty()){
            for (String address : emailAddress){
                Matcher match = patron.matcher(address);
                if (match.find() && address.contains('@')) {
                    numCentro = address.substring(0,address.indexOf('@'));
                    break;
                }
            }
            if (!String.isBlank(numCentro)) {
                numCentro= numCentro.leftPad(5,'0');
            }
        }
        return numCentro;
    }

    public static List<String> identificarEmailSaliente(String fromAddress, Case caso){

        List<String> estados = new List<String>();
        String status;
        String subStatus;
        //contacto: según contacto haremos posible que sea cliente, colab o bien empleado
        Contact contacto = new Contact();
        List<Contact> lstContact = [SELECT id, Name, RecordTypeId, Email, SEG_Estado__c FROM Contact WHERE Email = :fromAddress ];
        
        if(!lstContact.isEmpty()){

            for (Contact contactoEncontrado : lstContact) {
                if(contactoEncontrado.SEG_Estado__c != 'Inactivo'){
                    contacto = contactoEncontrado;
                }
            }

            if (contacto == null) {
                contacto = lstContact[0];
            }

            if(recordTypesClienteContacto == null){
                recordTypesClienteContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            }
            
            if(recordTypeEmpleado == null){
                recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            }
            
            if(recordTypeColaborador == null){
                recordTypeColaborador = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            }
            
            if(contacto.RecordTypeId == recordTypesClienteContacto && caso.Status == 'Cerrado'){
                status = 'Reabierto';
                subStatus = 'Recibida respuesta Cliente';
            } else if(contacto.RecordTypeId == recordTypesClienteContacto){
                status = 'Activo';
                subStatus = 'Pendiente asignación de propietario';
            }else if(contacto.RecordTypeId == recordTypeEmpleado && caso.Status == 'Cerrado'){
                status = 'Reabierto';
                subStatus = 'Recibida respuesta Gestor';
            } else if(contacto.RecordTypeId == recordTypeEmpleado){
                status = 'Activo';
                subStatus = 'Recibida respuesta Gestor';
            }else if(contacto.RecordTypeId == recordTypeColaborador && caso.Status == 'Cerrado'){
                status = 'Reabierto';
                subStatus = 'Recibida respuesta Colaborador';
            } else if(contacto.RecordTypeId == recordTypeColaborador){ 
                status = 'Activo';
                subStatus = 'Recibida respuesta Colaborador';
            } else{
                status = 'Activo';
                subStatus = 'Recibida respuesta otros';
            }

            estados.add(status);
            estados.add(subStatus);
            
        }else{
            status = 'Activo';
            subStatus = 'Recibida respuesta otros';
            estados.add(status);
            estados.add(subStatus);
        }
        return estados;
    }

    /**
     *  @description Clase para identificar cuentas y contactos
     *  @param fromAddress -> dirección de correo del email
     *  @return resultados de tipo Map<Account, List<Contact>>
     */
    public static Map<Account, List<Contact>> identificarCliente(String fromAddress, String body, String subject){
        Map<Account, List<Contact>> resultados = new Map<Account, List<Contact>> ();
        List<Contact> contactos = new List<Contact> ();
        List<Id> listIdRecordTypeClientes = new List<Id> ();
        listIdRecordTypeClientes.add(recordTypeCliente);
        listIdRecordTypeClientes.add(recordTypeClienteSeg);
        List<Id> listIdRecordTypeContactos = new List<Id> ();
        listIdRecordTypeContactos.add(recordTypesClienteContacto);
        listIdRecordTypeContactos.add(recordTypeEmpleado);
        listIdRecordTypeContactos.add(recordTypeColaborador);
        List<id> accountIds = new List<id>();

        contactos = [SELECT RecordType.DeveloperName, AccountId, Name, Email, SEG_Estado__c,IsPersonAccount 
                    FROM Contact 
                    WHERE (RecordTypeId in :listIdRecordTypeContactos OR RecordTypeId = null) AND Email = :fromAddress AND SEG_Estado__c != 'Inactivo' ];

        //ELB modificado metodo para buscar en las relaciones los contactos vinculados a sus cuentas.
        for (AccountContactRelation accCont : [SELECT id,Account.Name, AccountId,ContactId FROM AccountContactRelation WHERE ContactId IN:contactos ]) {
            if (accCont.AccountId != null){
                accountIds.add(accCont.AccountId);
            }
        }
        Integer contactSize = contactos.size();

        if (contactSize >= 0 ){
            for (Account cuenta :[SELECT RecordType.DeveloperName, Name, SEG_Organizacion__c, SEG_Zona__c, AV_OficinaPrincipal__c, SEG_Oficina_Gestora_Segmentos__c, SEG_Prioridad_Carterizacion_Segmentos__c FROM Account WHERE Id IN :accountIds AND RecordTypeId != :recordTypesClientePA]){
                //Añadimos cada cuenta al mapa con la lista de sus contactos encontrados
                List<Contact> contactosCuenta = new List<Contact> ();
                for (Contact contacto : contactos) {
                    if (contacto.AccountId == cuenta.Id) {
                        contactosCuenta.add(contacto);
                    }
                }
                resultados.put(cuenta, contactosCuenta);
            }
        }
        if (contactSize == 0)  {
            List<Account> cuentasDominio = [SELECT RecordType.DeveloperName, Name, SEG_Organizacion__c, SEG_Zona__c, SEG_DominioMail__c, RecordTypeId, AV_OficinaPrincipal__c, SEG_Oficina_Gestora_Segmentos__c, SEG_Prioridad_Carterizacion_Segmentos__c FROM Account WHERE RecordTypeId in :listIdRecordTypeClientes and SEG_DominioMail__c like :'%' + fromAddress.split('@').get(1) + '%' ];
            if (cuentasDominio.size()> 0) {
                for (Account cuentaDominio : cuentasDominio){
                    resultados.put(cuentaDominio, new List<Contact> ());
                }
            }  
        }
        return resultados;
    }

    /**
     *  @description Clase para procesar los adjuntos del correo
     *  @param casoId -> id del caso creado
     */
    public static Map<String, sObject> procesarAdjuntos(String casoId, Case caso, Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, String body, String buzonCaixa){
        List<Id> listaContentVersionIdEmail = New List<Id> ();
        Boolean hasAnexos = false;

        String nuevoHtmlBody = email.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131000) { 
            nuevoHtmlBody = nuevoHtmlBody.left(131000);
        }

        if (email.textAttachments != null) {
            //Insertar registros Content Version
            List<ContentVersion> listaContentVersion = new List<ContentVersion> ();
            for (Messaging.Inboundemail.TextAttachment textAttachment : email.textAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.PathOnClient = textAttachment.fileName;
                cv.Origin = 'H';
                cv.Title = textAttachment.fileName;
                //Por si el adjunto llega con el body vacío
                if(textAttachment.body == '' || textAttachment.body == null){
                    textAttachment.body = ' ';
                }
                cv.VersionData = Blob.valueOf(textAttachment.body);
                listaContentVersion.add(cv);
            }
            if(Schema.sObjectType.ContentVersion.fields.ContentLocation.isCreateable()){
                insert listaContentVersion;
            }

            //Recuperar ContentDocumentId de los registros Content Version insertados
            List<Id> listaContentVersionId = new List<Id> ();
            for (ContentVersion cv : listaContentVersion) {
                listaContentVersionId.add(cv.Id);
                listaContentVersionIdEmail.add(cv.Id);
            }
            listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId ];

            //Insertar registros ContentDocumentLink
            List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink> ();
            for (ContentVersion cv : listaContentVersion) {
                ContentDocumentLink cdLink = new ContentDocumentLink();
                cdLink.LinkedEntityId = casoId;
                cdLink.ContentDocumentId = cv.ContentDocumentId;
                cdLink.ShareType = 'I';
                listaContentDocumentLink.add(cdLink);
            }
            if(Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()){
                insert listaContentDocumentLink;
            }
            hasAnexos = true;
        }

        if (email.binaryAttachments != null) {
            //Insertar registros Content Version
            List<ContentVersion> listaContentVersion = new List<ContentVersion> ();
            Map<String, String> mapaImagenes = new Map<String, String> ();
            for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.PathOnClient = binaryAttachment.fileName;
                cv.Origin = 'H';
                cv.Title = binaryAttachment.fileName;
                cv.VersionData = binaryAttachment.body;

                //Se almacena el identificador de la imagen para poder realizar un reemplazo posterior
                if (binaryAttachment.headers != null) {
                    for (Integer i = 0; i<binaryAttachment.headers.size(); i++) {
                        if (binaryAttachment.headers[i].name == 'Content-Id') {
                            String headerValue = binaryAttachment.headers[i].value;
                            headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                            cv.ExternalDocumentInfo1 = headerValue;
                        }
                    }
                    hasAnexos = true;
                }
                listaContentVersion.add(cv);
            }
            if(Schema.sObjectType.ContentVersion.fields.Origin.isCreateable()){
                try{
                    Database.SaveResult[] adjuntosSubidos = database.insert(listaContentVersion,false);
                    List<FeedItem> feedItems = new List<FeedItem>();
                    for (Database.SaveResult adjunto : adjuntosSubidos) {
                        if (adjunto.isSuccess()) {
                            // CBK_log.debug('SEG_EmailService: Successfully attached files.', LoggingLevel.INFO);
                        	CBK_Log.addError(null, null, 'SEG_EmailService: Successfully attached files.' +  LoggingLevel.INFO, null, null);

                        } else {
                            FeedItem errorAdjuntos = new FeedItem();
                            errorAdjuntos.ParentId = casoId;
                            errorAdjuntos.Body = 'Han ocurrido errores al adjuntar los archivos al caso : Numero de errores: ' + adjunto.getErrors().size();
                            errorAdjuntos.Type = 'TextPost';
                            feedItems.add(errorAdjuntos);

                            for(Database.Error err : adjunto.getErrors()){
                                // CBK_log.debug('SEG_EmailService: Attachment error returned: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
                                CBK_Log.addError(null, null, 'SEG_EmailService: Attachment error returned: ' + err.getMessage(), null, null);
                            }
                        }   
                    }
                    //Se insertan los CBK_Logs
                    CBK_Log.insertDML();

                    insert feedItems;
                }
                catch(Exception e){
                    // Registrar error
                    CBK_Log.error(e, 'Error en el envio de email', email);
                }   
            }
            
            nuevoHtmlBody = prepararImagenesInline(email, listaContentVersion);

            //Recuperar ContentDocumentId de los registros Content Version insertados
            List<Id> listaContentVersionId = new List<Id> ();
            for (ContentVersion cv : listaContentVersion) {
                listaContentVersionId.add(cv.Id);
                listaContentVersionIdEmail.add(cv.Id);
            }
            listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId ];

            //Insertar registros ContentDocumentLink
            List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink> ();
            for (ContentVersion cv : listaContentVersion) {
                ContentDocumentLink cdLink = new ContentDocumentLink();
                cdLink.LinkedEntityId = casoId;
                cdLink.ContentDocumentId = cv.ContentDocumentId;
                cdLink.ShareType = 'I';
                listaContentDocumentLink.add(cdLink);
            }
            if(Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()){
                insert listaContentDocumentLink;
            }
        }
        
        Map<String, sObject> mapResultado = crearEmailMessage(email,envelope.toAddress, casoid, caso, null, body, nuevoHtmlBody, buzonCaixa, hasAnexos);
        EmailMessage crearEmailMessage  = (EmailMessage)mapResultado.get('correo');

        //Insertar registros ContentDocumentLink asociados al email
        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink> ();
        List<ContentVersion> listaContentVersionEmail = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionIdEmail ];
        for (ContentVersion cv : listaContentVersionEmail) {
            ContentDocumentLink cdLink = new ContentDocumentLink();
            cdLink.LinkedEntityId = crearEmailMessage.Id;
            cdLink.ContentDocumentId = cv.ContentDocumentId;
            cdLink.ShareType = 'V';
            listaContentDocumentLink.add(cdLink);
            //TRAZABILIDAD EMAILSERVICE
        }
        if(Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()){
            insert listaContentDocumentLink;
        }
        return mapResultado;
    }

    public static String prepararImagenesInline(Messaging.InboundEmail email, List<ContentVersion> listaContentVersion) {
        //Para imágenes, se modifica el tag <image> para que apunte al nuevo registro de ContentVersion:
        //String nuevoHtmlBody = email.htmlBody;
        
        String nuevoHtmlBody = '';
        if (String.isNotBlank(email.htmlBody)) {
            nuevoHtmlBody = email.htmlBody.left(131000);
        }
        for (ContentVersion cv : listaContentVersion) {
            if (cv.ExternalDocumentInfo1 != null) {
                //Se actualiza el HTMLBody
                //Ejemplo de URL: https://caixabankcc--devcops--c.documentforce.com/sfc/servlet.shepherd/version/download/0681X000001Fg9kQAC
                try {
                    nuevoHtmlBody = nuevoHtmlBody?.replaceAll('cid:' + cv.ExternalDocumentInfo1, '/sfc/servlet.shepherd/version/download/' + cv.Id);
                } catch(Exception e) {
                    //CBK_Log.error(e, 'Error en el envio de email', email);
                    CBK_Log.addError(null, e, 'Error en el envio de email' + e.getMessage(), null, null);
                }
            }
        }
        //Se insertan los CBK_Logs
        CBK_Log.insertDML();

        return nuevoHtmlBody;
    }
    public static Map<String, sObject> crearEmailMessage(Messaging.InboundEmail email,String toAddress, Id idCaso, Case caso, Id contactId, String body, String nuevoHtmlBody, String buzonCaixa, Boolean hasAnexos) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = false;
        EmailMessage correo = new EmailMessage();
        Map<String, sObject> mapResultado = new Map<String, sObject>();
        try {
            
            Datetime parsedDatetime;

            String subjectAcortado = '';
            //US829509: Correos - Limitación caracteres asunto
            if(email.subject.length() > 3000){
                subjectAcortado = email.subject.left(3000);
            }else{
                subjectAcortado = email.subject;
            }

            for(Messaging.InboundEmail.Header header : email.headers){
                if(header.Name.equalsIgnoreCase('Date')){
                    try {
                        if(header.value != null){
                            parsedDatetime = parseoDatetime(header.value);
                        }
                        CBK_log.debug('Parseo temporal SEG_EmailService correcto - Subject : ' + subjectAcortado + ' MessageDate: ' + parsedDatetime + ' DateTime.Now(): ' + DateTime.now());
                    } catch (Exception e) {
                        //CBK_log.debug('Parseo temporal SEG_EmailService incorrecto - Subject : ' + subjectAcortado + ' header.value: ' + header?.value);
                     	CBK_Log.addError(null, e, 'Parseo temporal SEG_EmailService incorrecto - Subject :' + subjectAcortado + ' header.value: ' + header?.value, null, null);
                    }
                }
            } 

            //Se insertan los CBK_Logs
            CBK_Log.insertDML();
                
            correo.Subject = subjectAcortado;
            correo.SEG_BotonPulsado__c = 'Responder';
            correo.Status = '1';
            if (email.ccAddresses != null) {
                correo.CcAddress = String.join(email.ccAddresses, ',');
            }

            correo.FromAddress = email.fromAddress;
            correo.FromName = email.fromName;

            CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
            petition.app = 'SEG';
            petition.header = email.headers;
            petition.limitCharacters = 31999;

            CBK_InboundEmailUtils.PriorityHeaderResult headerResult = CBK_InboundEmailUtils.getPriorityHeader(petition);

            if(headerResult.priorityHeaders != null){
                correo.Headers = JSON.serialize(headerResult.priorityHeaders);
                if(headerResult.secondPriorityHeaders != null){
                    correo.CBK_Second_Priority_Headers__c = JSON.serialize(headerResult.secondPriorityHeaders);
                }
            }
            //correo.Headers = JSON.serialize(email.headers)?.left(31999);
            //Trazabilidad Emailservice petición coe
            correo.MessageIdentifier = email.messageId;
            correo.CBK_sfdcMessageId__c = email.messageId?.left(255);
            correo.ThreadIdentifier = email.inReplyTo;
            //fin petición coe
            if (String.isBlank(nuevoHtmlBody)) {
                String cuerpo = email.htmlBody;
                if (cuerpo != null) {
                    correo.HtmlBody = cuerpo.left(131000);
                } else {
                    //JAV SI VIENE A NULL EL HTMLBODY NO TIENE SENTIDO ESTA LINEA DE ABAJO
                    //correo.HtmlBody = cuerpo;
                    correo.HtmlBody = body.left(131000);
                }
            } else {
                correo.HtmlBody = nuevoHtmlBody.left(131000);
            }
            
            correo.Incoming = true;
            correo.MessageDate = parsedDatetime;
            correo.ParentId = idCaso;
            result.success = true;

            if (email.toAddresses != null && !email.toAddresses.isEmpty()) {
                //EDC US617581 - Creo una lista para contar los caracteres y otra lista para pasar el límite de direcciones
                List<String> contDir = new List<String>();  
                List<String> contDirIncluidas = new List<String>();
                List<String> contDirExcluidas = new List<String>();
                Boolean limiteCaracteres = false;               
                
                if(String.join(email.toAddresses, ',').length() >= 3501 || Test.isRunningTest()) {
                    for (String varDir : email.toAddresses) {
                        contDir.add(varDir);
                        if (!limiteCaracteres && String.join(contDir, ',').length() < 3500) {
                            contDirIncluidas.add(varDir);
                        } else  {
                            contDirExcluidas.add(varDir);
                            limiteCaracteres = true;
                        }
                    }
                    if (limiteCaracteres || Test.isRunningTest()) {
                        if(Test.isRunningTest()){
                            contDirExcluidas.add('direccionTest@test.com');
                        }
                        caso.SEG_limiteToAddress__c = true;
                        caso.SEG_toAddressNoAnadidos__c = contDirExcluidas.toString();
    
                        FeedItem feed = new FeedItem();
                        feed.ParentId = caso.Id; 
                        feed.Body = 'No se han podido incluir los siguientes destinatarios del email entrante ' + caso.SEG_toAddressNoAnadidos__c; 
                        feed.Type = 'TextPost';
                        insert feed;
                    }
                    correo.ToAddress = String.join(contDirIncluidas, ',');
                } else {
                    correo.ToAddress = String.join(email.toAddresses, ',');
                }
            }
            correo.SEG_HasAnexo__c = hasAnexos;
            //Añadimos el campo CC_Aplicacion__c para que no salte el PB CC_Inbound_Email y nos salté un error de too many queries
            correo.CC_Aplicacion__c = 'SEG';
            //quitamos propietario del caso
            
            List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' ];
            if (!colasBO.isEmpty() ){
                caso.OwnerId = colasBO[0].id;
            }
            
            if(Schema.sObjectType.EmailMessage.fields.ToAddress.isCreateable()){
                insert correo;
            }

            mapResultado.put('caso', caso);
            mapResultado.put('correo', correo);
        } catch (Exception e) {
            CBK_Log.error(e, 'Error en la creación del email para el caso ' + caso.Id + ' : ' + caso.CaseNumber, email);
        }

        return mapResultado;
    }

    //ANOTACIONES ELB: Modificar el metodo para incluir un nuevo parametro: ToAdress, CcAddress 
    public static List<Id> determinarCR(String fromAddress, List<String> toAddresses, List<String> ccAddresses, String subject, String body){
        //en base a los datos del correo  se busca la regla de clasificación pertinente
        String remitenteUC = fromAddress.toUpperCase();
        String asuntoUC = subject.toUpperCase();
        String cuerpoUC = body.toUpperCase();
        String destinatariosUC = toAddresses?.toString().toUpperCase();
        String destinatariosCcUc = ccAddresses?.toString().toUpperCase();
        Map<Id,id> clasificacionRapidaMap = new Map<id,id>();
        Map<Id,id> clasificacionRapidaMapV2 = new Map<id,id>();
        List<Id> clasificacionRapida = new List<Id> ();
        //JAV ELIMINAR CR DUPLICADAS
        List<Id> crSinDUPlst = new List<Id> ();
        Set<Id> crIdset = new Set<Id>();

        //V2: Con MAP de Regla de clasificación y lista de multivalor
        List<Id> reglasClasificacionIds = new List<Id> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorRemitentesIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorAsuntosIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorCuerposIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioCCIncluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorRemitentesExcluir= new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorAsuntosExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorCuerposExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatarioCCExcluir = new Map<Id, Map<String, SEG_Multivalor__c>> ();

        for (SEG_Multivalor__c multivalor :[SELECT id, SEG_Reglas_Clasificacion__c, SEG_TipodeValor__c, SEG_Valor__c, SEG_ReglaInactiva__c FROM SEG_Multivalor__c WHERE SEG_ReglaInactiva__c = false AND SEG_CRInactiva__c = false AND SEG_Reglas_Clasificacion__c<> '' AND SEG_Reglas_Clasificacion__r.CBK_Negocio__c = 'Segmentos' AND SEG_Valor__c != null AND SEG_Valor__c != '']){
            if (multivalor.SEG_TipodeValor__c == 'Remitente'){
                reglasClasificacionIds.add(multivalor.SEG_Reglas_Clasificacion__c);
                if (maplistOfMultivalorRemitentesIncluir.size() == 0 || (!maplistOfMultivalorRemitentesIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorRemitentesIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorRemitentesIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorRemitentesIncluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorRemitentesIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Asunto') {
                reglasClasificacionIds.add(multivalor.SEG_Reglas_Clasificacion__c);
                if (maplistOfMultivalorAsuntosIncluir.size() == 0 || (!maplistOfMultivalorAsuntosIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorAsuntosIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorAsuntosIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorAsuntosIncluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorAsuntosIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Cuerpo') {
                reglasClasificacionIds.add(multivalor.SEG_Reglas_Clasificacion__c);
                if (maplistOfMultivalorCuerposIncluir.size() == 0 || (!maplistOfMultivalorCuerposIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorCuerposIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorCuerposIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorCuerposIncluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorCuerposIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Destinatario'){
                reglasClasificacionIds.add(multivalor.SEG_Reglas_Clasificacion__c);
                if (maplistOfMultivalorDestinatarioIncluir.size() == 0 || (!maplistOfMultivalorDestinatarioIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorDestinatarioIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorDestinatarioIncluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Destinatario CC'){
                reglasClasificacionIds.add(multivalor.SEG_Reglas_Clasificacion__c);
                if (maplistOfMultivalorDestinatarioCCIncluir.size() == 0 || (!maplistOfMultivalorDestinatarioCCIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioCCIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorDestinatarioCCIncluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorDestinatarioCCIncluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioCCIncluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Remitente a excluir'){
                if (maplistOfMultivalorRemitentesExcluir.size() == 0 || (!maplistOfMultivalorRemitentesExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorRemitentesExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorRemitentesExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorRemitentesExcluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorRemitentesExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Asunto a excluir'){
                if (maplistOfMultivalorAsuntosExcluir.size() == 0 || (!maplistOfMultivalorAsuntosExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorAsuntosExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorAsuntosExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorAsuntosExcluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorAsuntosExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Cuerpo a excluir'){
                if (maplistOfMultivalorCuerposExcluir.size() == 0 || (!maplistOfMultivalorCuerposExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorCuerposExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorCuerposExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorCuerposExcluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorCuerposExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Destinatario a excluir'){
                if (maplistOfMultivalorDestinatarioExcluir.size() == 0 || (!maplistOfMultivalorDestinatarioExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorDestinatarioExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorDestinatarioExcluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            } else if (multivalor.SEG_TipodeValor__c == 'Destinatario CC a excluir'){
                if (maplistOfMultivalorDestinatarioCCExcluir.size() == 0 || (!maplistOfMultivalorRemitentesExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c))){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioCCExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
                else if (maplistOfMultivalorDestinatarioCCExcluir.containsKey(multivalor.SEG_Reglas_Clasificacion__c)){
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c> ();
                    listMV = maplistOfMultivalorDestinatarioCCExcluir.get(multivalor.SEG_Reglas_Clasificacion__c);
                    listMV.put(multivalor.SEG_Valor__c, multivalor);
                    maplistOfMultivalorDestinatarioCCExcluir.put(multivalor.SEG_Reglas_Clasificacion__c, listMV);
                }
            }
        }
        //V2: Comparamos los Asuntos Cuerpos y Remitentes
        Map<Id, Id> reglasClasificacionOK = new Map<Id, Id> ();

        for (Id target : reglasClasificacionIds){
            //por cada iteración instanciamos Listas de Remitentes, Asuntos y Cuerpos
            Map<String, SEG_Multivalor__c> listRemitentes = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listAsuntos = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listCuerpos = new Map<String, SEG_Multivalor__c> ();
            //Map<String, SEG_Multivalor__c> listExclusiones = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listDestinatarios = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listDestinatariosCC = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listRemitentesExcluir = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listAsuntosExcluir = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listCuerposExcluir = new Map<String, SEG_Multivalor__c> ();
            //Map<String, SEG_Multivalor__c> listExclusiones = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listDestinatariosExcluir = new Map<String, SEG_Multivalor__c> ();
            Map<String, SEG_Multivalor__c> listDestinatariosCCExcluir = new Map<String, SEG_Multivalor__c> ();

            if (maplistOfMultivalorRemitentesIncluir.containsKey(target)){
                listRemitentes = maplistOfMultivalorRemitentesIncluir.get(target);          
            }
            if (maplistOfMultivalorAsuntosIncluir.containsKey(target)){
                listAsuntos = maplistOfMultivalorAsuntosIncluir.get(target);
            }
            if (maplistOfMultivalorCuerposIncluir.containsKey(target)){
                listCuerpos = maplistOfMultivalorCuerposIncluir.get(target);
            }
            if (maplistOfMultivalorDestinatarioIncluir.containsKey(target)){
                listDestinatarios = maplistOfMultivalorDestinatarioIncluir.get(target);
            }
            if (maplistOfMultivalorDestinatarioCCIncluir.containsKey(target)){
                listDestinatariosCC = maplistOfMultivalorDestinatarioCCIncluir.get(target);
            }
            if (maplistOfMultivalorRemitentesExcluir.containsKey(target)){
                listRemitentesExcluir = maplistOfMultivalorRemitentesExcluir.get(target);           
            }
            if (maplistOfMultivalorAsuntosExcluir.containsKey(target)){
                listAsuntosExcluir = maplistOfMultivalorAsuntosExcluir.get(target);
            }
            if (maplistOfMultivalorCuerposExcluir.containsKey(target)){
                listCuerposExcluir = maplistOfMultivalorCuerposExcluir.get(target);
            }
            if (maplistOfMultivalorDestinatarioExcluir.containsKey(target)){
                listDestinatariosExcluir = maplistOfMultivalorDestinatarioExcluir.get(target);
            }
            if (maplistOfMultivalorDestinatarioCCExcluir.containsKey(target)){
                listDestinatariosCCExcluir= maplistOfMultivalorDestinatarioCCExcluir.get(target);
            }
            //TODO: FALTA EL *
            //posibles valores--> 0: no configurado | 1:configurado y encontrado | 2.configurado y no encontrado
            //Inclusiones
            integer remitenteFound = 0;
            integer asuntoFound = 0;
            integer cuerpoFound = 0;
            integer destinatarioFound = 0;
            integer destinatarioCCFound = 0;
            //Exclusiones
            integer exclusion = 0;
            integer exclusionCuerpo = 0;
            integer exclusionAsunto = 0;
            integer exclusionRemitente = 0;
            integer exclusionDestinatario = 0;
            integer exclusionDestinatarioCC = 0;

            for (String valor : listRemitentes.KeySet()){
                remitenteFound = 2;
                //if (remitenteUC.contains(valor.toUpperCase()) || remitenteUC == '*') {
                if (remitenteUC.contains(valor.toUpperCase()) || valor == '*') {
                    remitenteFound = 1;
                    break;
                }   
            }
            for (String valor : listAsuntos.KeySet()){
                asuntoFound = 2;
                if (asuntoUC.contains(valor.toUpperCase()) || valor == '*') {
                    asuntoFound = 1;
                    break;
                }
            }
            for (String valor : listCuerpos.KeySet()){
                cuerpoFound = 2;
                if (cuerpoUC.contains(valor.toUpperCase()) || valor == '*') {
                    cuerpoFound = 1;
                    break;
                }
            }
            for (String valor : listDestinatarios.KeySet()){
                if (destinatariosUc != null){
                    if (destinatariosUC.contains(valor.toUpperCase()) || valor == '*') {
                        destinatarioFound = 1;
                        break;
                    }
                }
            }
            for (String valor : listDestinatariosCC.KeySet()){
                if (destinatariosCcUc != null){
                    if (destinatariosCcUc.contains(valor.toUpperCase()) || valor == '*') {
                        destinatarioCCFound = 1;
                        break;
                    }
                }
            }
            //exlcusiones
            for (String valor : listAsuntosExcluir.KeySet()){
                if (asuntoUC.contains(valor.toUpperCase())) {
                    exclusionAsunto = 1;
                    exclusion = 1;
                    break;
                }
            }
            for (String valor : listCuerposExcluir.KeySet()){
                if (cuerpoUC.contains(valor.toUpperCase())) {
                    exclusionCuerpo = 1;
                    exclusion = 1;
                    break;
                }
            }
            for (String valor : listRemitentesExcluir.KeySet()){
                if (remitenteUC.contains(valor.toUpperCase())) {
                    exclusionRemitente = 1;
                    exclusion = 1;
                    break;
                }
            }
            for (String valor : listDestinatariosExcluir.KeySet()){
                if (destinatariosUC != null ){
                    if (destinatariosUC.contains(valor.toUpperCase())){
                        exclusionDestinatario = 1;
                        exclusion = 1;
                        break;
                    }
                }
            }
            for (String valor : listDestinatariosCCExcluir.KeySet()){
                if (destinatariosCcUc != null ){
                    if (destinatariosCcUc.contains(valor.toUpperCase())){
                        exclusionDestinatarioCC = 1;
                        exclusion = 1;
                        break;
                    }
                }
            }
            //nuevo desarrollo
            if ((remitenteFound == 1 && destinatarioFound == 1 && destinatarioCCFound == 1) && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) {clasificacionRapidaMap.put(target,target);}
            else if ((remitenteFound == 1 && destinatarioFound == 1 && (destinatarioCCFound == 0 && listDestinatariosCC.isEmpty())) && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) {clasificacionRapidaMap.put(target,target);}
            else if ((remitenteFound == 1 && (destinatarioFound == 0 && listDestinatarios.isEmpty()) && (destinatarioCCFound == 0 && listDestinatariosCC.isEmpty()))  && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) {clasificacionRapidaMap.put(target,target);}
            else if ((remitenteFound == 1 && (destinatarioFound == 0  && listDestinatarios.isEmpty()) && destinatarioCCFound == 1) && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) {clasificacionRapidaMap.put(target,target);}
            else if (((remitenteFound == 0 && listRemitentes.isEmpty())&& destinatarioFound == 1 && destinatarioCCFound == 1) && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) {clasificacionRapidaMap.put(target,target);  }
            else if (((remitenteFound == 0 && listRemitentes.isEmpty()) && destinatarioFound == 1 && (destinatarioCCFound == 0 && listDestinatariosCC.isEmpty())) && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) {clasificacionRapidaMap.put(target,target);}
            else if (((remitenteFound == 0 && listRemitentes.isEmpty())&& (destinatarioFound == 0 && listDestinatarios.isEmpty()) && destinatarioCCFound == 1) && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) {clasificacionRapidaMap.put(target,target); }
            else if (((remitenteFound == 0 && listRemitentes.isEmpty()) && (destinatarioFound == 0 && listDestinatarios.isEmpty())) && (destinatarioCCFound == 0 && listDestinatariosCC.isEmpty()) && (asuntoFound == 1 || cuerpoFound == 1) && exclusion != 1) { clasificacionRapidaMap.put(target,target);}
        }
        for(id crRapida:clasificacionRapidaMap.keyset()){
            clasificacionRapida.add(crRapida);
        }
        crIdset.addAll(clasificacionRapida);
        crSinDUPlst.addAll(crIdset);
        return crSinDUPlst;
        //return clasificacionRapida;
    }

    public static String identificarCIF(String email) {
        //Pattern pat = Pattern.compile('^([a-z]|[A-Z]|[0-9])[0-9]{7}([a-z]|[A-Z]|[0-9])$');
        Pattern patCIF = Pattern.compile('[a-zA-Z][0-9]{8}');
        Pattern patDNI = Pattern.compile('[0-9]{8}[a-zA-Z]');
        Pattern patNIE = Pattern.compile('[a-zA-Z][0-9]{7}[a-zA-Z]');
        Set<String> listaIdentificadores = new Set<String>();
        
        if (email != null) {
            String cadenaLimpia;
            List<String> listadoStrings = new List<String>();
            String delSpecialChars = '[^\\w\\s\\-]';
            String newStr = email.replaceAll(delSpecialChars, ' ');
            listadoStrings = newStr.split(' ');
            for (String cadena : listadoStrings){
                cadenaLimpia = cadena;
                if (string.isNotBlank(cadena)){
                    if (cadena.charAt(0) == 45){
                        cadenaLimpia = cadena.substring(1);
                    }
                    if (cadena.charAt(cadena.length() -1) == 45){
                        cadenaLimpia = cadena.substring(0, cadena.length() -1);
                    }
                }
                //Busqueda de DNI'sz
                Matcher matcherDNI = patDNI.matcher(cadenaLimpia);
                if (matcherDNI.find()){
                    listaIdentificadores.add(matcherDNI.group());    
                }
                //Busqueda de CIF's
                Matcher matcherCIF = patCIF.matcher(cadenaLimpia);
                if (matcherCIF.find()){
                    listaIdentificadores.add(matcherCIF.group());    
                }
                //Busqueda de NIF's
                Matcher matcherNIF = patNIE.matcher(cadenaLimpia);
                if (matcherNIF.find()){
                    listaIdentificadores.add(matcherNIF.group());    
                }
            } 
        }
        Set<String> finalIdented = new Set<String>();
        for (String ident :listaIdentificadores){
            String newStr = ident.replaceAll('-', '');
            finalIdented.add(newStr);
        }
        if (finalIdented.isEmpty()){
            return 'KO';
        }
        else {
            return new List<String> ( finalIdented )[0];
        }
    }

    public static Boolean bloqueoListaNegra(String email){
        List<SEG_ListaNegra__c> listaNegra = new List<SEG_ListaNegra__c> ();
        Boolean encontrado = false;
        listaNegra = [SELECT id, SEG_Email__c, SEG_Inactivo__c FROM SEG_ListaNegra__c WHERE SEG_Inactivo__c = false and SEG_Email__c like :'%' + email + '%' ];
        if (!listaNegra.isEmpty()){
            encontrado = true;
        }
        return encontrado;
    }

    public static Datetime parseoDatetime(String fechaEmail){

        Map<String, Integer> monthMap = new Map<String, Integer>{
            'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4,
            'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8,
            'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
        };
        
        List<String> parts = fechaEmail.split(' ');
        
        Integer year = Integer.valueOf(parts[3]);
        Integer month = monthMap.get(parts[2]);
        Integer day = Integer.valueOf(parts[1]);
		Integer gmtEmail = Integer.valueOf(fechaEmail.right(4).left(2));
       
        List<String> timeParts = parts[4].split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Integer second = Integer.valueOf(timeParts[2]);
        
        Datetime parsedDatetime = Datetime.newInstanceGMT(year, month, day, hour, minute, second);
        Integer horaSumar = 0;
		if(fechaEmail.contains('+')){
            horaSumar = horaSumar - gmtEmail;
		} else {
			horaSumar = horaSumar + gmtEmail;
		}
        parsedDatetime = parsedDatetime.addHours(horaSumar);
        return parsedDatetime;
    }
}