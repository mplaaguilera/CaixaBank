//OS_LLAMADA DEVCOPS
public without sharing class OS_Llamada {
    
    public class Input {
        public String usuario {get;set;}
        public String connId {get;set;}
        public String ani {get;set;}
        public String dnis {get;set;}
        public String casoId {get;set;} 
        public String nombreFicheroGrabacion {get;set;}
        public String servicio {get;set;} //PENDENT
        public String transfDestino {get;set;} //PENDENT
        public String cola {get;set;}
        public String multiParametros {get;set;}
    }
    
    public class Output_RegistrarLlamadaEntrante {
        public String recordId {get;set;}
    }
    
    public static String openCTI_obtenerPrefijo(Input parametrosCTI) {
        //De momento COPS no tiene requerimientos para cálculo de prefijos, siempre se envía vacío
        return '';
    }
    
    public static CC_Llamada__c openCTI_registrarLlamadaSaliente(Input parametrosCTI) {
        
        //Comprueba que no han quedado llamadas anteriores abiertas para el agente que realiza la llamada
        completarLlamadasUsuario();
        
        Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordType.DeveloperName
        FROM Case WHERE Id = :parametrosCTI.casoId];
        
        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', caso.RecordType.DeveloperName);
        llamada.CC_ConnId__c = parametrosCTI.connId;
        llamada.CC_Tipo__c = 'Saliente';
        llamada.CC_Agente__c = parametrosCTI.usuario.toUpperCase();
        llamada.CC_ANI__c = parametrosCTI.ani;
        llamada.CC_DNIS__c = parametrosCTI.dnis;
        llamada.CC_Idioma__c = caso.CC_Idioma__c;
        llamada.CC_Asunto__c = caso.Subject;
        llamada.CC_Cuenta__c = caso.AccountId;
        llamada.CC_Contacto__c = caso.ContactId;
        llamada.CC_No_Identificado__c = caso.CC_No_Identificado__c;
        llamada.CC_Fecha_Inicio__c = System.now();
        llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
        llamada.OS_Nombre_Fichero_Grabacion__c = parametrosCTI.nombreFicheroGrabacion;
        insert llamada;
        
        crearTarea(parametrosCTI.casoId, llamada.Id, 'Llamada saliente', null);
        
        return llamada;
    }
    
    public static String openCTI_obtenerColaCarteraCops(String telefono) {
        String retorno = '';Map<Account, List<Contact>> mapaCuentasContactos = OS_Identificacion_Auto.identificarCliente('Telefono', telefono, '');
        if (mapaCuentasContactos.size() == 1) {
            Account cuentaIdentificada = new List<Account>(mapaCuentasContactos.keySet())[0];
            if (cuentaIdentificada.OS_Cartera__c != NULL) { retorno = 'OK#C' + [SELECT OS_Cola_Telefonia__c FROM OS_Cartera__c WHERE Recordtype.Developername ='OS_Cartera' AND Id = :cuentaIdentificada.OS_Cartera__c].OS_Cola_Telefonia__c; }
        }return retorno;
    }
    
    public static OS_Llamada.Output_RegistrarLlamadaEntrante openCTI_registrarLlamadaEntrante(Input parametrosCTI) {
        OS_Llamada.Output_RegistrarLlamadaEntrante respuesta = new OS_Llamada.Output_RegistrarLlamadaEntrante();
        Map<String, String> multiParametros = New Map<String, String>();
        
        if (parsearMultiparametros(parametrosCTI.multiParametros) != null) {
            multiParametros = parsearMultiparametros(parametrosCTI.multiParametros);
        } 
        
        //¿Es una llamada entrante inicial o es una consulta sobre una llamada entrante anterior?
        CC_Llamada__c llamadaOrigenConsulta = llamadaOrigenConsulta(parametrosCTI.connId);
        
        if (llamadaOrigenConsulta == null) {
            //Llamada entrante inicial
            //Comprueba que no han quedado llamadas anteriores abiertas para el agente que recibe la llamada
            completarLlamadasUsuario();

            string stringtipocliente = '';
            if (multiParametros.containsKey('tipoCliente')) {
                stringtipocliente = multiParametros.get('tipoCliente');
            } 

            //Identificación de la procedencia de la llamada
            List <CC_Lista_Valores__c> procedenciaTelefonia = [SELECT Name, CC_Valor__c, CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'COPS: Relación DNIS y Canal de procedencia' AND CC_Valor__c = :parametrosCTI.dnis LIMIT 1];
            
            // if (!procedenciaTelefonia.isEmpty()) {
            //     //Llamadas pertenecientes al departamento GOC son tratadas siempre como de Empleado
            //     if (procedenciaTelefonia[0].CC_Valor2__c == 'GOC'){
            //         stringtipocliente = 'empleado';
            //     }
            // }
            
            //Identificación del cliente si hay una sola cuenta y contacto
            Id accountId = null;
            Id contactId = null;
            String recordTypeContacto = '';
            String recordTypeCuenta = ''; 

            Map<Account, List<Contact>> mapaCuentasContactos = new  Map<Account, List<Contact>>();
            
            if (!multiParametros.containsKey('tipoCliente') && stringtipocliente != 'empleado') {
                //Map<Account, List<Contact>> 
                mapaCuentasContactos = OS_Identificacion_Auto.identificarCliente('Telefono', parametrosCTI.ani, ''); 
            }
            else {
                //Map<Account, List<Contact>> 
                mapaCuentasContactos = OS_Identificacion_Auto.identificarCliente('Telefono', parametrosCTI.ani, stringtipocliente);
            }

            //El formato del resultado de la identificación automática es <Account, List<Contact>>
            if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values()[0].size() == 1) {
                Contact contactoIdentificado = mapaCuentasContactos.values()[0][0];
                accountId = contactoIdentificado.AccountId;
                contactId = contactoIdentificado.Id;
                recordTypeContacto = contactoIdentificado.RecordType.DeveloperName;
                recordTypeCuenta = contactoIdentificado.Account.RecordType.DeveloperName;
            }

            string clientellamada = '';
            if (mapaCuentasContactos.size() > 0 && mapaCuentasContactos.values()[0].size() > 0) {
                clientellamada = mapaCuentasContactos.values()[0][0].Account.RecordType.DeveloperName;
            }

            //List<CC_Grupo_Colaborador__c> grupoTrabajo = parametrosCTI.cola != '' || parametrosCTI.cola != null ? [SELECT Id, OS_Cola_Telefonia__c, OS_Tematica__c, OS_GrupoTrabajo__c FROM CC_Grupo_Colaborador__c WHERE Recordtype.DeveloperName LIKE 'OS_%' AND OS_Cola_Telefonia__c = :parametrosCTI.cola LIMIT 1]:new List<CC_Grupo_Colaborador__c>();
            List<OS_Cartera__c> colasTelefonia  = parametrosCTI.cola != '' || parametrosCTI.cola != null ? [SELECT OS_GrupoTrabajo_ColaTelefonia__c, OS_GrupoTrabajo_ColaTelefonia__r.OS_GrupoTrabajo__c, OS_GrupoTrabajo_ColaTelefonia__r.OS_Tematica__c FROM OS_Cartera__c WHERE RecordType.developerName = 'OS_Cola_Telefonia' AND Name = :parametrosCTI.cola]:new List<OS_Cartera__c>();

            //Creación de la llamada entrante inicial
            CC_Llamada__c llamada = new CC_Llamada__c();
            
            if (!multiParametros.containsKey('tipoCliente')) {
                if (clientellamada == 'CC_CentroCaixaBank' || clientellamada == 'OS_Buzon_Account' || stringtipocliente == 'empleado') {
                    llamada.RecordTypeId = recordTypeLlamada('empleado');
                    multiparametros.put('tipoCliente','empleado');
                } else {
                    llamada.RecordTypeId = recordTypeLlamada('cliente');
                    multiparametros.put('tipoCliente','cliente');
                }
            } else {
                llamada.RecordTypeId = recordTypeLlamada(stringtipocliente); 
            }

            llamada.CC_ConnId__c = parametrosCTI.connId;
            llamada.CC_Tipo__c = 'Entrante';
            llamada.CC_Idioma__c = 'es';
            llamada.CC_Agente__c = parametrosCTI.usuario.toUpperCase();
            llamada.CC_ANI__c = parametrosCTI.ani;

            llamada.OS_Cola__c = parametrosCTI.cola != null ? parametrosCTI.cola:'';

            llamada.CC_DNIS__c = parametrosCTI.dnis;
            llamada.CC_Fecha_Inicio__c = System.now();
            if (((stringtipocliente == 'cliente' || stringtipocliente == '') && (recordTypeContacto == 'CC_Cliente' || recordTypeCuenta == 'CC_ClientePA' )) || ((stringtipocliente == 'empleado' || stringtipocliente == '') && (recordTypeContacto == 'OS_Buzon_Contact' || recordTypeContacto == 'CC_Empleado'))) {
                llamada.CC_Cuenta__c = accountId;
                llamada.CC_Contacto__c = contactId;
            }
            llamada.OS_Nombre_Fichero_Grabacion__c = parametrosCTI.nombreFicheroGrabacion;
            insert llamada;
            
            //¿Crear nuevo caso?
            if (contactId == null || [SELECT Count() FROM Case WHERE ContactId = :contactId AND IsClosed = false AND recordType.DeveloperName LIKE 'OS_%' LIMIT 1] > 0) {
                //Cliente no identificado o con caso activo existente, no se crea caso ni tarea
                respuesta.recordId = llamada.Id; //Masvoz abrirá el tab de la llamada
            } else {
                //Cliente identificado sin caso activo existente
                Case caso = new Case();
                caso.CC_Tipo_Contacto__c = 'Asesoramiento';
                caso.CC_Idioma__c='es';
                caso.OS_Telefono__c = parametrosCTI.ani;
                caso.OS_GrupoTrabajo__c = !colasTelefonia.isEmpty() && colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_GrupoTrabajo__c != null ? colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_GrupoTrabajo__c:''; 
                caso.CC_MCC_Tematica__c = !colasTelefonia.isEmpty() && colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_Tematica__c != null ? colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_Tematica__c:null; 
                caso.OS_Cola_Telefonia__c = parametrosCTI.cola != null ? parametrosCTI.cola:'';
                caso.OS_Numero_Operaciones__c = 1;
                if ((stringtipocliente == 'cliente' || stringtipocliente == '') && (recordTypeContacto == 'CC_Cliente' || recordTypeCuenta == 'CC_ClientePA')) { //Si el contacto y la llamada son de tipo cliente, se crea caso y tarea de llamada entrante                    
                    caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
                    if (!procedenciaTelefonia.isEmpty()){
                        caso.CC_Canal_Procedencia__c = procedenciaTelefonia[0].Name;
                        caso.CC_Canal_Resolucion__c = procedenciaTelefonia[0].Name;
                    }
                    caso.Origin = 'Phone';
                    caso.Subject = 'Llamada entrante ' + parametrosCTI.ani + ' ' + System.today().format();
                    caso.AccountId = accountId;
                    caso.ContactId = contactId;
                    insert caso;
                    
                    //Creación de tarea de llamada entrante
                    crearTarea(caso.Id, llamada.Id, 'Llamada entrante', null);
                    
                    //Masvoz abrirá el tab del caso
                    respuesta.recordId = caso.Id;
                 } else if ((stringtipocliente == 'empleado' || stringtipocliente == '') && (recordTypeContacto == 'OS_Buzon_Contact' || recordTypeContacto == 'CC_Empleado')) { //Si el contacto y la llamada son de tipo empleado, se crea caso y tarea de llamada entrante
                    caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');
                    if (!procedenciaTelefonia.isEmpty()){
                        caso.CC_Canal_Procedencia__c = procedenciaTelefonia[0].Name; 
                        caso.CC_Canal_Resolucion__c = procedenciaTelefonia[0].Name;
                    }
                    caso.Origin = 'Phone';
                    caso.Subject = 'Llamada entrante ' + parametrosCTI.ani + ' ' + System.today().format();
                    caso.AccountId = accountId;
                    caso.ContactId = contactId;
                    insert caso;
                    
                    //Creación de tarea de llamada entrante
                    crearTarea(caso.Id, llamada.Id, 'Llamada entrante', null);
                    
                    //Masvoz abrirá el tab del caso
                    respuesta.recordId = caso.Id;
                } else {
                    llamada.CC_Cuenta__c = null;
                    llamada.CC_Contacto__c = null;
                    update llamada;
                    respuesta.recordId = llamada.Id; //Masvoz abrirá el tab de la llamada
                }
                
            }
            
        } else {
            //Consulta
            
            //Creación de la llamada de consulta
            CC_Llamada__c llamadaConsulta = new CC_Llamada__c();
            llamadaConsulta.RecordTypeId = recordTypeLlamada(multiParametros.get('tipoCliente'));
            llamadaConsulta.CC_ConnId_Consulta__c = parametrosCTI.connId;
            llamadaConsulta.CC_Tipo__c = 'Entrante';llamadaConsulta.CC_Agente__c = parametrosCTI.usuario.toUpperCase();
            llamadaConsulta.CC_ANI__c = parametrosCTI.ani; llamadaConsulta.CC_DNIS__c = parametrosCTI.dnis;
            llamadaConsulta.CC_Fecha_Inicio__c = System.now();
            llamadaConsulta.CC_Cuenta__c = llamadaOrigenConsulta.CC_Cuenta__c; llamadaConsulta.CC_Contacto__c = llamadaOrigenConsulta.CC_Contacto__c;
            llamadaConsulta.CC_Llamada_Padre__c = llamadaOrigenConsulta.Id;
            llamadaConsulta.OS_Nombre_Fichero_Grabacion__c = parametrosCTI.nombreFicheroGrabacion;
            llamadaConsulta.OS_Cola__c = parametrosCTI.cola != null ? parametrosCTI.cola:'';//transfDestino
            insert llamadaConsulta;
            
            //Nueva tarea de consulta en el caso apuntando a la nueva llamada de consulta
            Case caso = ultimoCasoVinculadoLlamada(llamadaOrigenConsulta);
            if (caso != null) {
                crearTarea(caso.Id, llamadaConsulta.Id, 'Consulta', null);
                
                //Masvoz abrirá el tab del caso
                respuesta.recordId = caso.Id;
            }
        }
        return respuesta;
    }
    
    public static String openCTI_registrarConsulta(Input parametros) {
        //Sin acciones cuando el agente origen inicia consulta al agente destino
        //Las consultas se crean cuando el agente destino descuelga la consulta entrante (método registrarLlamadaEntrante).
        return '';
    }
    
    public static String openCTI_finalizarConsulta(Input parametrosCTI) {
        
        //Finaliza cualquier consulta con el connId indicado no finalizada
        for (CC_Llamada__c llamada : [SELECT CC_ConnId__c,CC_ConnId_Consulta__c FROM CC_Llamada__c
        WHERE RecordTypeId IN :recordTypesLlamadasCOPS()
        AND CC_ConnId_Consulta__c = :parametrosCTI.connId AND CC_Fecha_Fin__c = NULL]) {
            
            completarLlamada(llamada, 'Consulta cancelada', 'Consulta%'); //El label de este valor es "Consulta atendida"
        }
        return '';
    }
    
    public static CC_Llamada__c openCTI_transferirLlamada(Input parametrosCTI) {
        
        CC_Llamada__c llamadaOrigenConsulta = llamadaOrigenConsulta(parametrosCTI.connId);
        
        if (llamadaOrigenConsulta != null) {
            //Finalización de llamada origen de la consulta
            completarLlamada(llamadaOrigenConsulta, 'Llamada transferida');
            
            //Actualización de llamada destino de la consulta
            CC_Llamada__c llamadaDestinoConsulta = llamadaDestinoConsulta(parametrosCTI.connId);
            if (llamadaDestinoConsulta != null) {
                llamadaDestinoConsulta.CC_ConnId__c = llamadaDestinoConsulta.CC_ConnId_Consulta__c;update llamadaDestinoConsulta;
            }
            
            //Se localiza el caso de la llamada origen (la consulta solo tiene sentido en el contexto de un caso)
            List<Task> tareasOrigen = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaOrigenConsulta.Id ORDER BY CreatedDate ASC LIMIT 1];
            if (!tareasOrigen.isEmpty()) {
                Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :tareasOrigen[0].WhatId];              
                //Nueva tarea de llamada transferida 
                crearTarea(caso.Id, llamadaDestinoConsulta.Id, 'Llamada transferida', 'Llamada transferida');
            }
        }
        return null;
    }
    
    private static void completarLlamadasUsuario() {
        
        for (CC_Llamada__c llamada : [SELECT CC_ConnId__c, CC_ConnId_Consulta__c FROM CC_Llamada__c
        WHERE RecordTypeId IN :recordTypesLlamadasCOPS()
        AND CC_Fecha_Fin__c = NULL AND OwnerId = :UserInfo.getUserId()]) {
            completarLlamada(llamada, 'Llamada finalizada');
        }
    }
    
    private static Task crearTarea(Id idCaso, Id idLlamada, String tipoTarea, String tipoCierre) {
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tarea.WhatId = idCaso;
        tarea.CC_Llamada_Id__c = idLlamada;
        tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();
        tarea.Type = tipoTarea;
        tarea.Subject = tipoTarea;
        
        if (String.isNotEmpty(tipoCierre)) {
            tarea.CC_Fecha_Fin__c = System.now();tarea.CC_Tipo_Cierre__c = labelTipoCierre(tipoCierre);tarea.Status = 'Completed';
        }
        if(tipoTarea == 'Llamada transferida' || tipoTarea == 'Consulta'){
            String cola = [SELECT OS_Cola__c FROM CC_Llamada__c WHERE Id = :idLlamada].OS_Cola__c;
            tarea.CC_Consulta__c = cola;
        } 
        insert tarea;
        return tarea;
    }
    
    public static void openCTI_finalizarLlamada(Input parametrosCTI) {
        
        for (CC_Llamada__c llamada : [SELECT CC_ConnId__c, CC_ConnId_Consulta__c FROM CC_Llamada__c
        WHERE RecordTypeId IN :recordTypesLlamadasCOPS()
        AND (CC_ConnId__c = :parametrosCTI.connId OR CC_ConnId_Consulta__c = :parametrosCTI.connId)
        AND CC_Agente__c = :parametrosCTI.usuario.toUpperCase()
        AND CC_Fecha_Fin__c = NULL]) {
            completarLlamada(llamada, 'Llamada finalizada');
        }
    }
    
    public static Case crearCaso(CC_Llamada__c llamada) {
        //Creación de caso invocada por el Aura CC_Llamada_Caso_Nuevo desde llamadas COPS
        
        CC_Lista_Valores__c procedenciaTelefonia = [SELECT name, CC_Valor__c, CC_Valor2__c FROM CC_Lista_Valores__c
        WHERE CC_Lista__r.Name = 'COPS: Relación DNIS y Canal de procedencia'
        AND CC_Valor__c = :llamada.CC_DNIS__c LIMIT 1];
        //List<CC_Grupo_Colaborador__c> grupoTrabajo = llamada.OS_Cola__c != '' || llamada.OS_Cola__c != null ? [SELECT Id, OS_Cola_Telefonia__c, OS_Tematica__c, OS_GrupoTrabajo__c FROM CC_Grupo_Colaborador__c WHERE Recordtype.DeveloperName LIKE 'OS_%' AND OS_Cola_Telefonia__c = :llamada.OS_Cola__c LIMIT 1]:new List<CC_Grupo_Colaborador__c>();
        List<OS_Cartera__c> colasTelefonia  = llamada.OS_Cola__c != '' || llamada.OS_Cola__c != null ?[SELECT OS_GrupoTrabajo_ColaTelefonia__c, OS_GrupoTrabajo_ColaTelefonia__r.OS_GrupoTrabajo__c, OS_GrupoTrabajo_ColaTelefonia__r.OS_Tematica__c FROM OS_Cartera__c WHERE RecordType.developerName = 'OS_Cola_Telefonia' AND Name = :llamada.OS_Cola__c]:new List<OS_Cartera__c>();
                
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = procedenciaTelefonia.Name;
        caso.CC_Canal_Resolucion__c = procedenciaTelefonia.Name;
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OS_Telefono__c = llamada.CC_ANI__c;
        caso.OS_GrupoTrabajo__c = !colasTelefonia.isEmpty() && colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_GrupoTrabajo__c != null ? colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_GrupoTrabajo__c:''; 
        caso.CC_MCC_Tematica__c = !colasTelefonia.isEmpty() && colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_Tematica__c != null ? colasTelefonia[0].OS_GrupoTrabajo_ColaTelefonia__r.OS_Tematica__c:null; 
        caso.OS_Numero_Operaciones__c = 1;
        caso.Subject = llamada.CC_Asunto__c;
        caso.CC_No_Identificado__c = llamada.CC_No_Identificado__c;
        caso.AccountId = llamada.CC_Cuenta__c;
        caso.ContactId = llamada.CC_Contacto__c;
        caso.CC_IdentCliente__c = llamada.CC_IdentCliente__c;
        caso.OS_Cola_Telefonia__c = llamada.OS_Cola__c;

        // if (procedenciaTelefonia.CC_Valor2__c == 'GOC') {
        //     caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');
        // } else {
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosById().get(llamada.RecordTypeId).getDeveloperName());
        // }

        insert caso;
        
        crearTarea(caso.Id, llamada.Id, llamada.CC_Tipo__c == 'Entrante' ? 'Llamada entrante' : 'Llamada saliente', null);
        
        return caso;
    }
    
    private static Map<String, String> parsearMultiparametros(String multiParametros) {
        
        //Ejemplo multiParametros: 'tipoCliente=cliente&nuevoParametro=valorNuevoParametro'
        
        if (String.isBlank(multiParametros)) {
            return null;
        } else {
            List<String> multiParametrosList = multiParametros.split('&');
            Map<String, String> multiParametrosMap = new Map<String, String>();
            
            for (String parametro : multiParametrosList) {
                List<String> parametroList = parametro.split('=');
                multiParametrosMap.put(parametroList[0], parametroList[1]);
            }
            return multiParametrosMap;
        }
    }
    
    @TestVisible 
    private static void completarLlamada(CC_Llamada__c llamada, String tipoCierre, String filtroTipoTarea) {
        
        //Completa la llamada indicada y cierra sus taras con el tipo de cierre indicado
        //filtroTipoTarea permite filtrar el dominio de tareas a cerrar
        
        //Completar llamada
        if (String.isNotEmpty(llamada.CC_ConnId_Consulta__c) && tipoCierre == 'Llamada finalizada') {
            //Para consultas el tipo de cierre es distinto
            tipoCierre = 'Consulta cancelada'; //El label de este valor es "Consulta atendida"
        }
        
        llamada.CC_Fecha_Fin__c = System.now();
        llamada.CC_Tipo_Cierre__c = tipoCierre;
        update llamada;
        
        //Cerrar tareas de la llamada
        filtroTipoTarea = String.isNotBlank(filtroTipoTarea) ? filtroTipoTarea : '%';
        
        List<Task> tareas = [SELECT Id FROM Task
        WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')
        AND CC_Llamada_Id__c = :llamada.Id AND Status = 'Open'
        AND Type LIKE :filtroTipoTarea];
        for (Task tarea : tareas) {
            tarea.CC_Fecha_Fin__c = System.now();
            tarea.CC_Tipo_Cierre__c = labelTipoCierre(tipoCierre);
            tarea.Status = 'Completed';
        }
        update tareas;
    }
    
    private static void completarLlamada(CC_Llamada__c llamada, String tipoCierre) {
        completarLlamada(llamada, tipoCierre, '%');
    }
    
    private static void completarTarea(CC_Llamada__c llamada, String tipoTarea, String tipoCierre) {
        List<Task> tareas = [SELECT Id FROM Task
        WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')
        AND CC_Llamada_Id__c = :llamada.Id];
        for (Task tarea : tareas) {
            tarea.CC_Fecha_Fin__c = System.now();
            tarea.CC_Tipo_Cierre__c = labelTipoCierre(tipoCierre);
            tarea.Status = 'Completed';
        }
        update tareas;
    }
    
    private static CC_Llamada__c llamadaOrigenConsulta(String connId) {
        //Retorna la última llamada no cerrada con el connId indicado
        CC_Llamada__c llamadaOrigen = null;
        List<CC_Llamada__c> llamadas = [SELECT CC_ConnId__c, CC_ConnId_Consulta__c, CC_Cuenta__c, CC_Contacto__c
        FROM CC_Llamada__c WHERE RecordTypeId IN :recordTypesLlamadasCOPS()
        AND CC_ConnId__c = :connId AND CC_Fecha_Fin__c = NULL ORDER BY CreatedDate DESC LIMIT 1];
        if (!llamadas.isEmpty()) {
            llamadaOrigen = llamadas[0];
        }
        return llamadaOrigen;
    }
    
    private static CC_Llamada__c llamadaDestinoConsulta(String connId) {
        //Retorna la última llamada no cerrada con el connId_consulta indicado
        CC_Llamada__c llamadaOrigen = null;
        List<CC_Llamada__c> llamadas = [SELECT CC_ConnId__c, CC_ConnId_Consulta__c, CC_Cuenta__c, CC_Contacto__c
        FROM CC_Llamada__c WHERE RecordTypeId IN :recordTypesLlamadasCOPS()
        AND CC_ConnId_Consulta__c = :connId AND CC_Fecha_Fin__c = NULL ORDER BY CreatedDate DESC LIMIT 1];
        if (!llamadas.isEmpty()) {
            llamadaOrigen = llamadas[0];
        }
        return llamadaOrigen;
    }
    
    private static Case ultimoCasoVinculadoLlamada(CC_Llamada__c llamada) {
        //Retorna el caso vinculado más recientemente a la llamada
        Case caso = null;
        
        if (llamada != null) {
            List<Task> tareasLlamada = [SELECT WhatId FROM Task
            WHERE CC_Llamada_Id__c = :llamada.Id ORDER BY CreatedDate DESC LIMIT 1];
            if (!tareasLlamada.isEmpty()) {
                caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :tareasLlamada[0].WhatId];
            }
        }
        return caso;
    }
    
    private static List<Id> recordTypesLlamadasCOPS() {
        List<Id> retorno = new List<Id>();
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente'));
        retorno.add(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Empleado'));
        return retorno;
    }
    
    private static Id recordTypeLlamada(String tipoCliente) {
        if (tipoCliente == 'cliente') {
            return CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente');
        } 
        else {
            return CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Empleado');
        }  
    }
    
    private static String labelTipoCierre(String nombreTipoCierre) {
        for (Schema.PicklistEntry tipo : CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe().getPicklistValues()) {
            if (tipo.getValue().equals(nombreTipoCierre)) {
                return tipo.getLabel();
            }
        }
        return nombreTipoCierre;        
    }
}