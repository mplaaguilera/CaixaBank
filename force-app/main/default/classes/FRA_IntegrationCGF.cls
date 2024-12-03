@RestResource(urlMapping='/CGFIntegrationCases/v0/*')
global with sharing class FRA_IntegrationCGF extends CBK_HttpServiceIntegration_Abstract{
 
    @HttpPost
    global static FRA_IntegrationCGF.output traspasoInfoSFC() {
        Datetime dtStart = Datetime.now(); //Tiempo de inicio integración
        Boolean bOk = true; //Si se desearliza JSON correctamente
        Boolean esActualizar = false; //Booleano para saber si se trata de una actualización o creación de estructura en SF (caso + alertas cgf + tarea)
        Case caseToUpdate; //Caso que se tiene que actualizar
        Boolean esCierreCGF = false; //Booleano para saber si se trata de un cierre del caso o no
        String statusAnterior = ''; //Variable para guardar el estado anterior del caso antes de cerrarlo
        RestRequest req = RestContext.request;
        FRA_RequestWrapperCGF rw = new FRA_RequestWrapperCGF(); //Entrada Integración
        FRA_IntegrationCGF.Output output = new FRA_IntegrationCGF.Output(); //Salida Integración
 
        if (req?.requestBody != null){  
            try {
                rw = (FRA_RequestWrapperCGF)JSON.deserializeStrict(req.requestBody.toString(), FRA_RequestWrapperCGF.class);
            } catch (Exception e) {
                bOk = false;
                output.resultado = 'KO';
                output.codigo = '400';
                output.descripcion = 'Error - Estructura de parámetros de entrada no válidos. ' + e.getMessage();
                output.caseId = '';
            }
        }

        if (bOk){ 
            try {
                //Búsqueda del usuario/agente
                List<User> listaUsuarios = [SELECT Id, Name, EmployeeNumber FROM User WHERE EmployeeNumber = :rw.userId_CGF LIMIT 1];
                User user = (!listaUsuarios.isEmpty()) ? listaUsuarios[0]: null;

                if ((user != null) && (rw.tipoOperacion_CGF.equals('trasladoInfoCGF'))){   //Tipo de Operación : TRASLADO INFORMACIÓN
                    caseToUpdate = busquedaCasoCliente(rw);

                    if(caseToUpdate != null && !String.isBlank(caseToUpdate.Id)){    
                        esActualizar = true; //Ya existe el caso en SF, se actualiza la estructura
                        Case casoActualizado = actualizarCrearCaso(caseToUpdate, user, rw, esActualizar);

                        crearAlertasCGF(rw, casoActualizado, user, esActualizar);

                        crearTarea(casoActualizado, user, 'FRA_Traslado_Información_CGF', esCierreCGF, statusAnterior);

                        //Se asigna el owner al caso 
                        casoActualizado.OwnerId = user.Id;
                        update casoActualizado;

                        //Salida
                        output.caseId = casoActualizado.Id;

                    }else{                 
                        esActualizar = false; //No existe el caso en SF, se crea la estructura
                        Case casoCreado = actualizarCrearCaso(caseToUpdate, user, rw, esActualizar);
                        
                        crearAlertasCGF(rw, casoCreado, user, esActualizar);

                        crearTarea(casoCreado, user, 'FRA_Traslado_Información_CGF', esCierreCGF, statusAnterior);

                        //Se asigna el owner al caso 
                        casoCreado.OwnerId = user.Id;
                        update casoCreado;

                        //Salida
                        output.caseId = casoCreado.Id;
                    }

                    //Salida
                    output.resultado = 'OK';
                    output.codigo = '200';
                    output.descripcion = 'OK - La información solicitada ha sido registrada en Salesforce correctamente';

                } else if ((user != null)&&(rw.tipoOperacion_CGF.equals('cierreCGF'))){ //Tipo de Operación : CIERRE CGF 
                    Id sCasoRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'); 
                    List<Case> listaCasoCierre = [SELECT Id, FRA_Id_Expediente_CGF__c, Status FROM Case WHERE FRA_Id_Expediente_CGF__c = :rw.idExpediente_CGF AND (RecordTypeId = :sCasoRecordType) LIMIT 1];

                    if (!listaCasoCierre.isEmpty()){
                        Case caseCierreCGF = listaCasoCierre[0];
                        statusAnterior = caseCierreCGF.Status;
                        esCierreCGF = true;
                        
                        caseCierreCGF.Status = 'Cerrado';    
                        update caseCierreCGF;
                        
                        crearTarea(caseCierreCGF, user, 'FRA_Cerrado_CGF', esCierreCGF, statusAnterior);

                        //Salida
                        output.resultado = 'OK';
                        output.codigo = '200';
                        output.descripcion = 'OK - La información solicitada ha sido registrada en Salesforce correctamente';
                        output.caseId = caseCierreCGF.Id;

                    } else { 
                        output.resultado = 'KO';
                        output.codigo = '401';
                        output.descripcion = 'Error - No existe ningún caso con el valor de idExpediente_CGF informado: ' + rw.idExpediente_CGF;
                        output.caseId = '';
                    }

                } else if (user != null){ //Tipo de Operación : NO VÁLIDO
                    output.resultado = 'KO';
                    output.codigo = '405';
                    output.descripcion = 'Error - El tipo de operación recibido no es correcto. Tipos de operación válidos(cierreCGF o trasladoInfoCGF)';
                    output.caseId = '';
                
                } else { 
                    output.resultado = 'KO';
                    output.codigo = '403';
                    output.descripcion = 'Error - No existe ningún usuario con el valor de userId_CGF informado';
                    output.caseId = '';
                }
                
            } catch (Exception e) {
                output.resultado = 'KO';
                output.codigo = '404';
                output.descripcion = e.getMessage();
                output.caseId = '';
            }
        } 

        // Framework Integración
        String jsonRes = '{"Result":"' + output.descripcion + '"}'; 
        RestResponse res = RestContext.response;
        res.statusCode = integer.valueof(output.codigo);
        res.addHeader('Content-Type', 'application/json; charset=utf-8');
        res.responseBody = Blob.valueOf(jsonRes);
        Datetime dtStop = Datetime.now();
        register(req, res, dtStart, dtStop, output.caseId, 'FRA_IntegrationCGF');

        return output; 
    }

    global class Output {
        public String resultado {get;set;}
        public String descripcion {get;set;}
        public String caseId {get;set;}
        public String codigo {get;set;}
    }

    public static Case busquedaCasoCliente(FRA_RequestWrapperCGF rw){
        Case casoEncontrado;
        Id sCasoRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        List<Case> caseUpdate = [SELECT Id, FRA_Id_Expediente_CGF__c, Status, Origin, CC_Idioma__c, OwnerId, Subject, Description, AccountId, ContactId, CC_Telefono_Contacto__c FROM Case WHERE FRA_Id_Expediente_CGF__c = :rw.idExpediente_CGF AND 
                                    (RecordTypeId = :sCasoRecordType) AND (Status = 'Activo' OR Status = 'FRA_001') LIMIT 1]; // Estado: activo o pendiente contactar cliente

        if (!caseUpdate.isEmpty()){
            casoEncontrado = caseUpdate[0];
        }else{ //No se encuentra ningún caso con el ID Expediente, podría ser llamada entrante (existe caso en SF) o llamada saliente (no existe caso en SF)
            Account cuentaIdentificada = identificarCliente(rw);

            if(cuentaIdentificada != null && !String.isBlank(cuentaIdentificada.Id)){
                List<Case> listaCasosCliente = [SELECT Id, FRA_Id_Expediente_CGF__c, Status, Origin, CC_Idioma__c, OwnerId, Subject, Description, AccountId, ContactId, CC_Telefono_Contacto__c FROM Case 
                                            WHERE AccountId = :cuentaIdentificada.Id AND (RecordTypeId = :sCasoRecordType) AND (Status = 'Activo' OR Status = 'FRA_001') ORDER BY LastModifiedDate DESC];
                casoEncontrado = busquedaCasoClienteAux(listaCasosCliente);
            }
        }

        return casoEncontrado;
    }

    public static Case busquedaCasoClienteAux(List<Case> listaCasos){
        Case casoEncontradoAux;
        
        if(!listaCasos.isEmpty()){
            // Consultando todos los casos del cliente, buscar aquellos que tengan una tarea de tipo "llamada entrante" y estado "Pendiente" 
            List<ID> oAuxCasosIds = new List<ID>();
            for (Case oCaso : listaCasos){
                oAuxCasosIds.add(oCaso.Id);
            }

            List<Task> oTareas = [SELECT Id, WhatId FROM Task WHERE WhatId IN :oAuxCasosIds AND ( Status = 'Open') AND (Type = 'Llamada entrante') ORDER BY CreatedDate DESC];

            if(!oTareas.isEmpty()){ 
                Task tarea = oTareas[0];
                Id caseIdToUpdate = tarea.WhatId;
                
                //Buscar el caso asociado a esta tarea
                for (Case oCasoAux : listaCasos) {
                    if (oCasoAux.Id == caseIdToUpdate) {
                    casoEncontradoAux = oCasoAux;
                    //break;  
                    }
                }
            } 
        } 
        return casoEncontradoAux;
    }

    public static Account identificarCliente(FRA_RequestWrapperCGF rw){
        Id sClienteRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        Id sClientePARecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Boolean esNumPerso = true;
        Account cuentaIdentificada;

        if (String.isBlank(rw.numPerso_CGF)){ 
            //Búsqueda por Num Documento
            esNumPerso = false;
            List<Account> listaCuentasIdentificadas = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = :rw.numDoc_CGF 
                                                        AND (RecordTypeId = :sClienteRecordType OR RecordTypeId = :sClientePARecordType) LIMIT 1];

            if (!listaCuentasIdentificadas.isEmpty()) {
                cuentaIdentificada = listaCuentasIdentificadas[0];
            }
        } else {
            //Búsqueda por Num Perso
            esNumPerso = true;
            List<Account> listaCuentasIdentificadas  = [SELECT Id, Name, CC_NumPerso__c FROM Account WHERE CC_NumPerso__c = :rw.numPerso_CGF 
                                                            AND (RecordTypeId = :sClienteRecordType OR RecordTypeId = :sClientePARecordType) LIMIT 1];
           
            if (!listaCuentasIdentificadas.isEmpty()) {
                cuentaIdentificada = listaCuentasIdentificadas[0];
            }
        } 
        return cuentaIdentificada;
    }

    public static Case actualizarCrearCaso(Case caso, User agente, FRA_RequestWrapperCGF rw, Boolean esActualizar){
        if (!esActualizar){
            Boolean esCaixaBankNow = (rw.negocio_CGF.equalsIgnoreCase('Teléfono FRAUDE CaixaBankNow'));
            Boolean esFicheros = (String.isNotBlank(rw.canal_CGF) && rw.canal_CGF.equalsIgnoreCase('Ficheros'));
            rw.negocio_CGF = (esCaixaBankNow && esFicheros) ? 'Teléfono FRAUDE Ficheros' : rw.negocio_CGF;

            caso = new Case();
            caso.CC_Canal_Procedencia__c = rw.negocio_CGF;
            caso.CC_Canal_Resolucion__c = rw.negocio_CGF;
            caso.FRA_Canal_CGF__c = (esCaixaBankNow) ? rw.canal_CGF : ''; 
            caso.FRA_Origen_Creacion__c = 'CGF';
            if(String.isNotBlank(rw.negocio_CGF)){
                caso.CC_Canal_Contacto__c = (rw.negocio_CGF == 'Teléfono FRAUDE Tarjetas Consumer') ? 'FRA_Cliente Consumer' : 'FRA_Cliente cbk'; 
            }
        }

        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        caso.Status = 'Activo';
        caso.Origin = 'Phone';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Caso CGF: ' + rw.idExpediente_CGF;
        caso.Description = caso.Subject;
        caso.FRA_Id_Expediente_CGF__c = rw.idExpediente_CGF;

        Boolean esNumPerso = true;
        
        if (!esActualizar){

            if (String.isBlank(rw.numPerso_CGF)){
                esNumPerso = false;
                identificarPorNumBusqueda(caso, rw.numDoc_CGF, esNumPerso); //Búsqueda por Num Documento
            } else {
                esNumPerso = true;
                identificarPorNumBusqueda(caso, rw.numPerso_CGF, esNumPerso);//Búsqueda por Num Perso
            } 
            insert caso;
            
        } else{
            update caso;

        }
        return caso;
    }

    public static void crearAlertasCGF(FRA_RequestWrapperCGF rw, Case caso, User agente, Boolean actualizoAlerta){
        List<FRA_Alerta_CGF__c > oAlertas = [SELECT Id, Name, FRA_Id_Operacion_CGF__c FROM FRA_Alerta_CGF__c WHERE FRA_Caso_Relacionado__c = :caso.Id];

        List<String> oAuxAlertas = new List<String>();
        for (FRA_Alerta_CGF__c oAlerta : oAlertas){
            oAuxAlertas.add(oAlerta.FRA_Id_Operacion_CGF__c);
        }
        
        Integer contadorAlertaCGF = (actualizoAlerta) ? oAuxAlertas.size() : 0;
        List<FRA_Alerta_CGF__c> oAlertasNuevas = new List<FRA_Alerta_CGF__c>();

        if (rw.alertas_CGF != null && !rw.alertas_CGF.isEmpty()) {
            for (FRA_RequestWrapperCGF.Alertas_CGF alerta : rw.alertas_CGF) {
                if(!oAuxAlertas.contains(alerta.idOperacion_CGF) ){
                    FRA_Alerta_CGF__c thisAlertaCGF = New FRA_Alerta_CGF__c(); 
                    contadorAlertaCGF++;
                    thisAlertaCGF.Name = 'Alerta CFG ' + String.valueOf(contadorAlertaCGF) + ' - Expediente ' + caso.FRA_Id_Expediente_CGF__c;
                    thisAlertaCGF.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('FRA_Alerta_CGF__c', 'FRA_Cliente');
                    thisAlertaCGF.FRA_Caso_Relacionado__c = caso.Id;
                    thisAlertaCGF.OwnerId = agente.Id;
                    thisAlertaCGF.FRA_Id_Operacion_CGF__c = alerta.idOperacion_CGF;
                    thisAlertaCGF.FRA_Tipo_de_Operacion__c = alerta.tipoOperacion;
                    thisAlertaCGF.FRA_Fecha_Operacion__c = Datetime.valueOf(alerta.fechaOperacion);
                    thisAlertaCGF.FRA_Importe__c = Decimal.valueOf(alerta.importe); 
                    thisAlertaCGF.FRA_Cuenta_Origen__c = alerta.cuenta_Origen;
                    thisAlertaCGF.FRA_Cuenta_Destino__c = alerta.cuenta_Destino;
                    thisAlertaCGF.FRA_Tipologia__c = alerta.tipologia;
                    thisAlertaCGF.FRA_Campana__c = alerta.campana;
                    thisAlertaCGF.FRA_Estado__c = alerta.estado;
                    thisAlertaCGF.FRA_Numero_Tarjeta__c = alerta.numeroTarjeta;
                    thisAlertaCGF.FRA_MCC_Alerta_CGF__c = alerta.MCC;
                    thisAlertaCGF.FRA_Pais__c = alerta.pais;
                    thisAlertaCGF.FRA_Nombre_Comercio__c = alerta.nombreComercio;

                    identificarContactoAlertaCGF (alerta, thisAlertaCGF, caso);

                    oAlertasNuevas.add(thisAlertaCGF);
                }   
            }
        }

        if (!oAlertasNuevas.isEmpty()){
            insert oAlertasNuevas;
        }
    }

    public static void identificarContactoAlertaCGF (FRA_RequestWrapperCGF.Alertas_CGF alertaWrapper, FRA_Alerta_CGF__c nuevaAlerta, Case caso){
        Id sClientePARecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Id sContactoClienteRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        List<Contact> contactoAlerta = [SELECT Id, AccountId FROM Contact WHERE CC_Numero_Documento__c = :alertaWrapper.numDocPersonaConectada AND (AccountId = :caso.AccountId) 
                                        AND RecordTypeId = :sContactoClienteRecordType LIMIT 1];

        if (!contactoAlerta.isEmpty()) {    
            nuevaAlerta.FRA_Contacto__c = contactoAlerta[0].Id; //Asocia el contacto 
        } else{
            List<Account> cuentaAlerta = [SELECT Id, PersonContactId FROM Account WHERE CC_Numero_Documento__c = :alertaWrapper.numDocPersonaConectada AND (Id= :caso.AccountId) 
                                        AND (RecordTypeId = :sClientePARecordType) LIMIT 1];

            if(!cuentaAlerta.isEmpty()){
                nuevaAlerta.FRA_Contacto__c = cuentaAlerta[0].PersonContactId; //Asocia el contacto particular
            }
        }
    }


    public static void crearTarea(Case caso, User agente, String tipo,  Boolean esCierre, String estadoAnterior){
        Task thisTask = new Task();
        thisTask.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
        thisTask.WhatId = caso.Id; 
        thisTask.Type = tipo; 
        thisTask.Status = 'Completed';
        thisTask.Priority = 'Normal';
        thisTask.Subject = (tipo.equals('FRA_Traslado_Información_CGF')) ? 'Traslado Información CGF' : 'Cerrado CGF';
        estadoAnterior = (estadoAnterior.equals('FRA_001')) ? 'Pendiente Contactar Cliente' : estadoAnterior;
        thisTask.Description = (esCierre) ? 'El estado del caso ha cambiado de ' + estadoAnterior + ' a Cerrado.': thisTask.Subject;
        thisTask.ActivityDate = System.today();
        thisTask.OwnerId = agente.Id;
        insert thisTask;
    }


    @TestVisible
	public static void identificarPorNumBusqueda(Case caso, String numBusqueda, Boolean esNumPerso) {
		if (!String.isEmpty(numBusqueda)) {
			List<Contact> contactos = new List<Contact>();
			Map<String, Object> mapaCuentasContactos = FRA_IntegrationCGF.identificarPersSFC(numBusqueda, esNumPerso);

			List<Account> cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');

			if ((cuentas.size() == 1) && (mapaCuentasContactos.containsKey('REPRESENTANTES'))) {
                contactos = (List<Contact>)mapaCuentasContactos.get('REPRESENTANTES');

                if (contactos.size() == 1) {
                    caso.AccountId = cuentas[0].Id;
                    caso.ContactId = contactos[0].Id;
                    caso.CC_Telefono_Contacto__c = seleccionarTelefono(contactos[0].MobilePhone, contactos[0].Phone, contactos[0].OtherPhone);
                } else{
                    caso.AccountId = cuentas[0].Id;
                    caso.ContactId = null;
                    caso.CC_Telefono_Contacto__c = seleccionarTelefono(cuentas[0].Phone, cuentas[0].PersonMobilePhone, cuentas[0].PersonOtherPhone); //Teléfono de la cuenta/empresa
                }

            } else if((cuentas.size() == 1) && (mapaCuentasContactos.containsKey('CONTACTOS'))){
                contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');

                if (contactos.size() == 1) {
                    caso.AccountId = cuentas[0].Id;
                    caso.ContactId = contactos[0].Id;
                    caso.CC_Telefono_Contacto__c = seleccionarTelefono(contactos[0].MobilePhone, contactos[0].Phone, contactos[0].OtherPhone);
                } else{
                    caso.AccountId = cuentas[0].Id;
                    caso.ContactId = null;
                    caso.CC_Telefono_Contacto__c = seleccionarTelefono(cuentas[0].Phone, cuentas[0].PersonMobilePhone, cuentas[0].PersonOtherPhone); //Teléfono de la cuenta/empresa
                }

            } else if (cuentas.size() == 1) { 
                caso.AccountId = cuentas[0].Id;
                caso.ContactId = cuentas[0].PersonContactId;
                caso.CC_Telefono_Contacto__c = seleccionarTelefono(cuentas[0].PersonMobilePhone, cuentas[0].Phone, cuentas[0].PersonOtherPhone); //Teléfono de la cuenta/empresa
            } else { //No se identifican cuentas o hay varias
                caso.AccountId = null;
                caso.ContactId = null;
            }
		}
	}

	public static String seleccionarTelefono(String telefono1, String telefono2, String telefono3) {
        String telefono; 

        if (String.isNotBlank(telefono1)) {
            telefono = telefono1;
        } else if (String.isNotBlank(telefono2)) {
            telefono = telefono2;
        } else if (String.isNotBlank(telefono3)) {
            telefono = telefono3;
        }
        return telefono;
    }


    public static Map<String,Object> identificarPersSFC (String numBusqueda, Boolean esNumPerso) {
        Map<String,Object> oRes = new Map<String,Object>();
        List<Contact> oContactos = new List<Contact>();
        List<Account> oCuentas = new List<Account>();
        List<Contact> oRepresentantes = new List<Contact>();

    
        // Buscar en cuentas
        Id sClienteRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        Id sClientePARecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        
        if (esNumPerso){
            oCuentas = [SELECT Id, Name, PersonContactId, Phone, PersonMobilePhone, PersonOtherPhone FROM Account WHERE CC_NumPerso__c = :numBusqueda AND (RecordTypeId = :sClienteRecordType OR RecordTypeId = :sClientePARecordType)];
        }else{
            oCuentas = [SELECT Id, Name, PersonContactId, Phone, PersonMobilePhone, PersonOtherPhone FROM Account WHERE CC_Numero_Documento__c = :numBusqueda AND (RecordTypeId = :sClienteRecordType OR RecordTypeId = :sClientePARecordType)];
        }
        
        // Buscar contactos de la cuenta.
        List<ID> oAuxCli = new List<ID>();
        for (Account oCliente : oCuentas)
        {
            oAuxCli.add(oCliente.Id);
        }

        
        Id sRTRep = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Representante'); 
        oContactos = [SELECT Id, AccountId, Name, Account.Name, Phone, MobilePhone, OtherPhone
                        FROM Contact
                        WHERE AccountId IN :oAuxCli
                        AND (RecordTypeId <> :sRTRep)];  

        oRepresentantes = [SELECT Id, AccountId, Name, Account.Name, Phone, MobilePhone, OtherPhone
                            FROM Contact
                            WHERE CC_CuentaRepresentada__c IN :oAuxCli
                            AND RecordTypeId = :sRTRep];

    
        // Devuelve los datos encontrados
        if (!oContactos.isEmpty()){
            oRes.put('CONTACTOS', oContactos);
        }
        oRes.put('CUENTAS', oCuentas);

        if (!oRepresentantes.isEmpty()){
            oRes.put('REPRESENTANTES', oRepresentantes);
        }
        return oRes;
    }

}