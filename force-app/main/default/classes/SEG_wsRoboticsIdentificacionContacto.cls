/**
*   @description SEG_wsRoboticsIdentificacionContacto
*/
@RestResource(urlMapping='/v1/segRoboticsIdentificacionContacto/*')
global with sharing class SEG_wsRoboticsIdentificacionContacto {

    global class SEG_WS_IdentContacto_GetOutput {
        global String resultado {get;set;}
        global String mensaje {get;set;}
        global String codigo {get;set;}
        global List<SEG_WS_Empresa> listaEmpresas {get;set;}
    }

    global class SEG_WS_Empresa {
        global String cuentaId {get;set;}
        global String nombre {get;set;} 

        // Datos grupo económico.
        global String grupoEmpresa {get;set;}
        global String grupoEmpresaCIF {get;set;}
        global String grupoEmpresaNumPer {get;set;}

        global String oficinaGestora {get;set;}
        global String oficinaGestoraNombre {get;set;}
        global String empleadoGestor {get;set;}
        global String empleadoGestorNombre {get;set;}
        global String empleadoGestorEmail {get;set;}
        global String centroSegmentos {get;set;}
        global String centroSegmentosNombre {get;set;}
        global String gestorOperativaNacional {get;set;}
        global String gestorOperativaNacionalNombre {get;set;}
        global String gestorOperativaInternacional {get;set;}
        global String gestorOperativaInternacionalNombre {get;set;}
        global String gestorFinanciacionEstructurada {get;set;}
        global String gestorFinanciacionEstructuradaNombre {get;set;}
        global List<SEG_WS_Contacto> listaContactos {get;set;}
        /*global String centroEmpresa {get;set;}
        global String centroBO {get;set;}
        global String gestor1 {get;set;}
        global String gestor2 {get;set;}*/
    }

    global class SEG_WS_Contacto {
        global String nombreCompleto {get;set;}
        global List<String> cargosCreditos {get;set;}
        global List<String> cargosOperativa {get;set;}
        global List<String> cargosEmpresa {get;set;}
        global List<String> cargosReporte {get;set;}
        global List<SEG_WS_Mail> listaMails {get;set;}
    }

    global class SEG_WS_Mail {
        global String contactoId {get;set;}
        global String email {get;set;}
    }

    /**
     * ***************************************************************
     * ***************************************************************
     * @description Método GET del servicio REST.
     * ***************************************************************
     * ***************************************************************
     */
    @HttpGet
    global static SEG_WS_IdentContacto_GetOutput getContactos ()
    {
        CC_TrazaInt__c traza;
        SEG_WS_IdentContacto_GetOutput resultadoWS = new SEG_WS_IdentContacto_GetOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;

        // Tratar los datos de entrada.
        String zona = peticionREST.params.get('zona');
        String cif = peticionREST.params.get('cif');

        // Registrar traza.
        CC_TrazaInt__c trazaPOST;
        try {
            //trazaPOST = CC_TrazaInt.inicioTraza ('segRoboticsIdentificacionContacto_GET',zona,cif,JSON.serialize(peticionREST.params));
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsIdentContacto_GET',zona,cif,JSON.serialize(peticionREST.params));
        } catch (Exception e) {
            trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), e.getTypeName(), e.getMessage());          
        }

        // Validar URI.
        if (bOk)
        {
            List<String> elemURI = RestContext.request.requestURI.split('/');
            if (elemURI.size() != 3)
            {
                bOk = false;
                resultadoWS.codigo = '9002';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = 'La URI del servicio no está bien formada';
            }
        }

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = validarDatosEntradaGET (zona, cif);
            if (datosValidacionEntrada.get('resultado') != 'OK')
            {
                bOk = false;
                resultadoWS.resultado = datosValidacionEntrada.get('resultado');
                resultadoWS.codigo = datosValidacionEntrada.get('codigo');
                resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
            }
        }

        // Crear el caso si las validaciones se cumplen.
        if (bOk)
        {
            resultadoWS = recuperarDatosContactoSalesforce (zona, cif);
        }

        try {
            if (trazaPOST != null)
            {
                if (resultadoWS.resultado == 'NOK')
                {
                    //trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                }else{
                    //trazaPOST = CC_TrazaInt.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                }
            }
        } catch (Exception e) {
            trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), e.getTypeName(), e.getMessage());   
        }

        return resultadoWS;
    }

    public static Map<String,String> validarDatosEntradaGET (String zona, String cif)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (String.isBlank(zona) || String.isBlank(cif))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje','No se han informado los datos obligatorios para la consulta');
            return resultadoValidacion;
        }

        // Si llegamos hasta aquí, la validación es correcta para realizar la consulta.
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');

        return resultadoValidacion;
    }

    public static SEG_WS_IdentContacto_GetOutput recuperarDatosContactoSalesforce (String zona, String cif)
    {
        List<SEG_WS_Empresa> listaEmpresas = new List<SEG_WS_Empresa>();
        Map<String, List<AccountContactRelation>> mapContactosCuentas = new Map<String, List<AccountContactRelation>>();
        Map<String, List<CC_Canal_Com__c>> mapCanalesContactosCuentas = new Map<String, List<CC_Canal_Com__c>>();
        
        SEG_WS_IdentContacto_GetOutput retornoWS = new SEG_WS_IdentContacto_GetOutput();
        retornoWS.codigo = '0000';
        retornoWS.resultado = 'OK';
        retornoWS.mensaje = '';
        retornoWS.listaEmpresas = new List<SEG_WS_Empresa>();

        try {

            cif = (String.isNotBlank(cif))?cif:'';

            Boolean bCentroCaixa = false;

            // Comprobar si es un centro CaixaBank.
            Pattern oPatt = Pattern.compile('^\\d{5}$');
            Matcher oMatcher = oPatt.matcher(cif);
            if(oMatcher.find()) {
                // Han informado una oficina.
                bCentroCaixa = true;
            }

            if (!bCentroCaixa)
            {
                // Datos de cliente, recuperar cuentas.
                ID recordTypeCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                ID recordTypeClienteSEG = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
                ID recordTypeClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

                List<ID> cuentasEncontradas = new List<ID>();
                List<ID> contactosEncontrados = new List<ID>();
                List<Account> listaCuentas = [SELECT Id, Name,  SEG_Prioridad_Carterizacion_Segmentos__c, 
                                                SEG_Oficina_Gestora_Segmentos__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, SEG_Oficina_Gestora_Segmentos__r.Name, 
                                                AV_OficinaPrincipal__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AV_OficinaPrincipal__r.Name,
                                                SEG_Empleado_gestor_Segmentos__c, SEG_Empleado_gestor_Segmentos__r.Name, SEG_Empleado_gestor_Segmentos__r.CC_Matricula__c, SEG_Empleado_gestor_Segmentos__r.Email,
                                                AV_EAPGestor__c, AV_EAPGestor__r.Name, AV_EAPGestor__r.CC_Matricula__c, AV_EAPGestor__r.Email,
                                                SEG_CentroSegmento__c, SEG_CentroSegmento__r.Name, SEG_CentroSegmento__r.CC_Numero_Oficina__c,
                                                SEG_GestorOperativaNacional__c, SEG_GestorOperativaNacional__r.Name, SEG_GestorOperativaNacional__r.CC_Matricula__c,
                                                SEG_GestorOperativaInternacional__c, SEG_GestorOperativaInternacional__r.Name, SEG_GestorOperativaInternacional__r.CC_Matricula__c,
                                                SEG_GestorFinEstructurada__c, SEG_GestorFinEstructurada__r.Name, SEG_GestorFinEstructurada__r.CC_Matricula__c,
                                                SEG_GrupoEmpresaId__c, SEG_GrupoEmpresaId__r.Name, SEG_GrupoEmpresaId__r.CC_Numero_Documento__c, SEG_GrupoEmpresaNumPer__c
                                                FROM Account 
                                                WHERE (RecordTypeId = :recordTypeCliente OR RecordTypeId = :recordTypeClienteSEG OR RecordTypeId = :recordTypeClientePA)
                                                AND CC_Numero_Documento__c = :cif
                                                /* vfr - AND SEG_Zona__c = :zona*/];
                for (Account cuenta : listaCuentas)
                {
                    // Gestión de la priorización de segmentos.
                    Boolean priorizacionSegmentos = (cuenta.SEG_Prioridad_Carterizacion_Segmentos__c != null) ? cuenta.SEG_Prioridad_Carterizacion_Segmentos__c : false;
                    String oficinaGestoraAux = (priorizacionSegmentos == true) ? cuenta.SEG_Oficina_Gestora_Segmentos__r?.CC_Numero_Oficina__c : cuenta.AV_OficinaPrincipal__r?.CC_Numero_Oficina__c;
                    String oficinaGestoraNombreAux = (priorizacionSegmentos == true) ? cuenta.SEG_Oficina_Gestora_Segmentos__r?.Name : cuenta.AV_OficinaPrincipal__r?.Name;
                    String empleadoGestorAux = (priorizacionSegmentos == true) ? cuenta.SEG_Empleado_gestor_Segmentos__r?.CC_Matricula__c : cuenta.AV_EAPGestor__r?.CC_Matricula__c;
                    String empleadoGestorNombreAux = (priorizacionSegmentos == true) ? cuenta.SEG_Empleado_gestor_Segmentos__r?.Name : cuenta.AV_EAPGestor__r?.Name;
                    String empleadoGestorEmailAux = (priorizacionSegmentos == true) ? cuenta.SEG_Empleado_gestor_Segmentos__r?.Email : cuenta.AV_EAPGestor__r?.Email;

                    SEG_WS_Empresa empresaSEG = new SEG_WS_Empresa();
                    empresaSEG.cuentaId = cuenta.Id;
                    empresaSEG.nombre = cuenta.Name;
                    empresaSEG.grupoEmpresa = cuenta.SEG_GrupoEmpresaId__r?.Name;
                    empresaSEG.grupoEmpresaCIF = cuenta.SEG_GrupoEmpresaId__r?.CC_Numero_Documento__c;
                    empresaSEG.grupoEmpresaNumPer = cuenta.SEG_GrupoEmpresaNumPer__c;
                    empresaSEG.centroSegmentos = cuenta.SEG_Oficina_Gestora_Segmentos__r?.CC_Numero_Oficina__c; //cuenta.SEG_CentroSegmento__r?.CC_Numero_Oficina__c;
                    empresaSEG.centroSegmentosNombre = cuenta.SEG_Oficina_Gestora_Segmentos__r?.Name; //cuenta.SEG_CentroSegmento__r?.Name;
                    empresaSEG.oficinaGestora = oficinaGestoraAux; //(cuenta.SEG_Oficina_Gestora_Segmentos__c != null) ? cuenta.SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c : cuenta.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
                    empresaSEG.oficinaGestoraNombre = oficinaGestoraNombreAux; //(cuenta.SEG_Oficina_Gestora_Segmentos__c != null) ? cuenta.SEG_Oficina_Gestora_Segmentos__r.Name : cuenta.AV_OficinaPrincipal__r.Name;
                    empresaSEG.empleadoGestor = empleadoGestorAux; //(cuenta.SEG_Empleado_gestor_Segmentos__c != null) ? cuenta.SEG_Empleado_gestor_Segmentos__r.CC_Matricula__c : cuenta.AV_EAPGestor__r.CC_Matricula__c;
                    empresaSEG.empleadoGestorNombre = empleadoGestorNombreAux; //(cuenta.SEG_Empleado_gestor_Segmentos__c != null) ? cuenta.SEG_Empleado_gestor_Segmentos__r.Name : cuenta.AV_EAPGestor__r.Name;
                    empresaSEG.empleadoGestorEmail = empleadoGestorEmailAux;
                    empresaSEG.gestorOperativaNacional = cuenta.SEG_GestorOperativaNacional__r?.CC_Matricula__c;
                    empresaSEG.gestorOperativaNacionalNombre = cuenta.SEG_GestorOperativaNacional__r?.Name;
                    empresaSEG.gestorOperativaInternacional = cuenta.SEG_GestorOperativaInternacional__r?.CC_Matricula__c;
                    empresaSEG.gestorOperativaInternacionalNombre = cuenta.SEG_GestorOperativaInternacional__r?.Name;
                    empresaSEG.gestorFinanciacionEstructurada = cuenta.SEG_GestorFinEstructurada__r?.CC_Matricula__c;
                    empresaSEG.gestorFinanciacionEstructuradaNombre = cuenta.SEG_GestorFinEstructurada__r?.Name;
                    listaEmpresas.add(empresaSEG);
                    cuentasEncontradas.add(cuenta.Id);
                }

                // Buscar contactos vinculados a las cuentas encontradas.
                if (!cuentasEncontradas.isEmpty())
                {
                    List<AccountContactRelation> listadoContactos = [SELECT Id, AccountId, ContactId, Contact.Name, Contact.Email, IsDirect,
                                                                        SEG_Creditos_sindicados__c, SEG_Cargos_Operativa__c, 
                                                                        SEG_Cargos_en_la_empresa__c, SEG_Reportar_temas_nuevos__c
                                                                        FROM AccountContactRelation
                                                                        WHERE AccountId IN :cuentasEncontradas AND IsActive = true
                                                                        ORDER BY AccountId, ContactId];
                    for (AccountContactRelation contacto : listadoContactos)
                    {
                        List<AccountContactRelation> listaContactosAux;
                        String sClave = contacto.AccountId;
                        if (mapContactosCuentas.get(sClave) == null)
                        {
                            listaContactosAux = new List<AccountContactRelation>();
                        }else{
                            listaContactosAux = mapContactosCuentas.get(sClave);
                        }
                        listaContactosAux.add(contacto);
                        mapContactosCuentas.put(sClave, listaContactosAux);
                        contactosEncontrados.add(contacto.ContactId);

                        // Crear un canal de contacto directo con la cuenta directa asociada al contacto
                        if (contacto.IsDirect)
                        {
                            String sClaveCanal = contacto.AccountId + '_' + contacto.ContactId;
                            CC_Canal_Com__c canalDirecto = new CC_Canal_Com__c();
                            canalDirecto.CC_CuentaId__c = contacto.AccountId;
                            canalDirecto.CC_ContactoId__c = contacto.ContactId;
                            canalDirecto.CC_Email__c = contacto.Contact.Email;

                            List<CC_Canal_Com__c> listaCanalesAux = new List<CC_Canal_Com__c>();
                            listaCanalesAux.add(canalDirecto);
                            mapCanalesContactosCuentas.put(sClaveCanal, listaCanalesAux);
                        }
                    }
                }

                // Buscar canales de comunicación de los contactos encontrados.
                if (!cuentasEncontradas.isEmpty() && !contactosEncontrados.isEmpty())
                {
                    ID recordTypeCanalMail = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
                    List<CC_Canal_Com__c> listadoCanalesComunicacion = [SELECT Id, CC_Email__c, CC_CuentaId__c, CC_ContactoId__c
                                                                        FROM CC_Canal_Com__c
                                                                        WHERE RecordTypeId = :recordTypeCanalMail
                                                                        AND CC_CuentaId__c IN :cuentasEncontradas
                                                                        AND CC_ContactoId__c IN :contactosEncontrados];
                    for (CC_Canal_Com__c canal : listadoCanalesComunicacion)
                    {
                        if (String.isNotBlank(canal.CC_Email__c))
                        {
                            List<CC_Canal_Com__c> listaCanalesAux;
                            String sClave = canal.CC_CuentaId__c + '_' + canal.CC_ContactoId__c;
                            if (mapCanalesContactosCuentas.get(sClave) == null)
                            {
                                listaCanalesAux = new List<CC_Canal_Com__c>();
                            }else{
                                listaCanalesAux = mapCanalesContactosCuentas.get(sClave);
                            }
                            listaCanalesAux.add(canal);
                            mapCanalesContactosCuentas.put(sClave, listaCanalesAux);
                        }
                    }
                }

                // Tratar los retornos encontrados y montar el mensaje de respuesta.
                for (SEG_WS_Empresa empresa : listaEmpresas)
                {
                    List<AccountContactRelation> contactosRelacionados = mapContactosCuentas.get(empresa.cuentaId);
                    if (contactosRelacionados != null)
                    {
                        // Preparar la lista de contactos.
                        empresa.listaContactos = new List<SEG_WS_Contacto>();

                        for (AccountContactRelation contacto : contactosRelacionados)
                        {
                            // Informar los datos de contacto.
                            SEG_WS_Contacto contactoEmpresa = new SEG_WS_Contacto();
                            contactoEmpresa.nombreCompleto = contacto.Contact.Name;

                            // Informar los cargos.
                            contactoEmpresa.cargosCreditos = (String.isNotBlank(contacto.SEG_Creditos_sindicados__c))?contacto.SEG_Creditos_sindicados__c.split(';'):null;
                            contactoEmpresa.cargosEmpresa = (String.isNotBlank(contacto.SEG_Cargos_en_la_empresa__c))?contacto.SEG_Cargos_en_la_empresa__c.split(';'):null;
                            contactoEmpresa.cargosOperativa = (String.isNotBlank(contacto.SEG_Cargos_Operativa__c))?contacto.SEG_Cargos_Operativa__c.split(';'):null;
                            contactoEmpresa.cargosReporte = (String.isNotBlank(contacto.SEG_Reportar_temas_nuevos__c))?contacto.SEG_Reportar_temas_nuevos__c.split(';'):null;

                            // Preparar la lista de canales.
                            contactoEmpresa.listaMails = new List<SEG_WS_Mail>();

                            String sClaveCom = empresa.cuentaId + '_' + contacto.ContactId;

                            List<CC_Canal_Com__c> canalesRelacionados = mapCanalesContactosCuentas.get(sClaveCom);
                            if (canalesRelacionados != null)
                            {
                                // Preparar los canales de contacto.
                                for (CC_Canal_Com__c canal : canalesRelacionados)
                                {
                                    SEG_WS_Mail canalContactoEmpresa = new SEG_WS_Mail();
                                    canalContactoEmpresa.contactoId = (canal.Id != null) ? canal.Id : contacto.ContactId;
                                    canalContactoEmpresa.email = canal.CC_Email__c;
                                    
                                    // Añadir el e-mail al retorno.
                                    contactoEmpresa.listaMails.add(canalContactoEmpresa);
                                }
                            }

                            // Añadir el contacto al retorno.
                            empresa.listaContactos.add(contactoEmpresa);
                        }
                    }

                    // Añadir la empresa al retorno.
                    retornoWS.listaEmpresas.add(empresa);
                }

            }else{
                // Datos de oficina, recuperar centros.

                String claveOficina = '001-' + cif;
                ID recordTypeCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

                List<ID> cuentasEncontradas = new List<ID>();
                List<ID> contactosEncontrados = new List<ID>();
                List<Account> listaCuentas = [SELECT Id, Name
                                                FROM Account 
                                                WHERE RecordTypeId = :recordTypeCliente
                                                // VFR - AND SEG_Zona__c = :zona
                                                AND CC_Numero_Oficina_Empresa__c = :claveOficina];
                for (Account cuenta : listaCuentas)
                {
                    SEG_WS_Empresa empresaSEG = new SEG_WS_Empresa();
                    empresaSEG.cuentaId = cuenta.Id;
                    empresaSEG.nombre = cuenta.Name;
                    listaEmpresas.add(empresaSEG);
                    cuentasEncontradas.add(cuenta.Id);
                }

                // Buscar contactos vinculados a las cuentas encontradas.
                if (!cuentasEncontradas.isEmpty())
                {
                    List<AccountContactRelation> listadoContactos = [SELECT Id, AccountId, ContactId, Contact.Name, Contact.Email, IsDirect
                                                                            FROM AccountContactRelation
                                                                            WHERE AccountId IN :cuentasEncontradas AND IsActive = true
                                                                            AND IsDirect = true
                                                                            ORDER BY AccountId, ContactId];
                    for (AccountContactRelation contacto : listadoContactos)
                    {
                        List<AccountContactRelation> listaContactosAux;
                        String sClave = contacto.AccountId;
                        if (mapContactosCuentas.get(sClave) == null)
                        {
                            listaContactosAux = new List<AccountContactRelation>();
                        }else{
                            listaContactosAux = mapContactosCuentas.get(sClave);
                        }
                        listaContactosAux.add(contacto);
                        mapContactosCuentas.put(sClave, listaContactosAux);
                        contactosEncontrados.add(contacto.ContactId);

                        // Crear un canal de contacto directo con la cuenta directa asociada al contacto
                        if (contacto.IsDirect)
                        {
                            String sClaveCanal = contacto.AccountId + '_' + contacto.ContactId;
                            CC_Canal_Com__c canalDirecto = new CC_Canal_Com__c();
                            canalDirecto.CC_CuentaId__c = contacto.AccountId;
                            canalDirecto.CC_ContactoId__c = contacto.ContactId;
                            canalDirecto.CC_Email__c = contacto.Contact.Email;

                            List<CC_Canal_Com__c> listaCanalesAux = new List<CC_Canal_Com__c>();
                            listaCanalesAux.add(canalDirecto);
                            mapCanalesContactosCuentas.put(sClaveCanal, listaCanalesAux);
                        }
                    }
                }

                // Tratar los retornos encontrados y montar el mensaje de respuesta.
                for (SEG_WS_Empresa empresa : listaEmpresas)
                {
                    List<AccountContactRelation> contactosRelacionados = mapContactosCuentas.get(empresa.cuentaId);
                    if (contactosRelacionados != null)
                    {
                        // Preparar la lista de contactos.
                        empresa.listaContactos = new List<SEG_WS_Contacto>();

                        for (AccountContactRelation contacto : contactosRelacionados)
                        {
                            // Informar los datos de contacto.
                            SEG_WS_Contacto contactoEmpresa = new SEG_WS_Contacto();
                            contactoEmpresa.nombreCompleto = contacto.Contact.Name;

                            // Preparar la lista de canales.
                            contactoEmpresa.listaMails = new List<SEG_WS_Mail>();

                            String sClaveCom = empresa.cuentaId + '_' + contacto.ContactId;
                            List<CC_Canal_Com__c> canalesRelacionados = mapCanalesContactosCuentas.get(sClaveCom);
                            if (canalesRelacionados != null)
                            {
                                // Preparar los canales de contacto.
                                for (CC_Canal_Com__c canal : canalesRelacionados)
                                {
                                    SEG_WS_Mail canalContactoEmpresa = new SEG_WS_Mail();
                                    canalContactoEmpresa.contactoId = (canal.Id != null) ? canal.Id : contacto.ContactId;
                                    canalContactoEmpresa.email = canal.CC_Email__c;
                                    
                                    // Añadir el e-mail al retorno.
                                    contactoEmpresa.listaMails.add(canalContactoEmpresa);
                                }
                            }

                            // Añadir el contacto al retorno.
                            empresa.listaContactos.add(contactoEmpresa);
                        }
                    }

                    // Añadir la empresa al retorno.
                    retornoWS.listaEmpresas.add(empresa);
                }
            }
            
        } catch (Exception e) {
            retornoWS.codigo = '9999';
            retornoWS.resultado = 'NOK';
            retornoWS.mensaje = 'Error al recuperar los datos. Detalle: ' + e.getMessage();
            CBK_Log.error(e);
        }

        return retornoWS;
    }
}