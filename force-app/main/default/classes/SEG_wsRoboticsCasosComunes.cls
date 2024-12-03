/**
*   @description SEG_wsRoboticsCasosComunes
*/
public with sharing class SEG_wsRoboticsCasosComunes {

    /**
     *  @description Identificar al cliente / contacto de la petición.
     *  @param cifCliente -> CIF del cliente
     *  @param idContacto -> Identificador del contacto
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda
     */
    public static Map<String,String> identificarClienteContacto (String cifCliente, String idContacto)
    {
        Map<String,String> resultadoBusqueda = new Map<String,String>();
        ID recordTypeCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        ID recordTypeClienteSEG = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        //ID recordTypeClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        String sError = '0';
        String sDescError = '';
        String clienteId = '';
        String contactoId = '';
        String direccionMail = '';
        String oficinaGestora = '';
        String numeroOficinaGestora = '';
        String idiomaCliente = 'es';

        if (String.isNotBlank(cifCliente))
        {
            List<Account> listaCuentas = [SELECT Id, SEG_Prioridad_Carterizacion_Segmentos__c, SEG_Oficina_Gestora_Segmentos__c, AV_OficinaPrincipal__c,
                                            AV_OficinaPrincipal__r.CC_Numero_Oficina__c, SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, RecordTypeId, SEG_IdiomaFx__c
                                            FROM Account 
                                            WHERE (RecordTypeId = :recordTypeCliente OR RecordTypeId = :recordTypeClienteSEG)
                                            AND CC_Numero_Documento__c = :cifCliente];
            if (listaCuentas.size() == 1)
            {
                // Cliente identificado.
                clienteId = listaCuentas[0].Id;
                idiomaCliente = listaCuentas[0].SEG_IdiomaFx__c;
                Boolean priorizacionSegmentos = (listaCuentas[0].SEG_Prioridad_Carterizacion_Segmentos__c != null) ? listaCuentas[0].SEG_Prioridad_Carterizacion_Segmentos__c : false;
                priorizacionSegmentos = (listaCuentas[0].RecordTypeId == recordTypeClienteSEG) ? false : priorizacionSegmentos;
                if (priorizacionSegmentos)
                {
                    oficinaGestora = listaCuentas[0].SEG_Oficina_Gestora_Segmentos__c;
                    numeroOficinaGestora = listaCuentas[0].SEG_Oficina_Gestora_Segmentos__r?.CC_Numero_Oficina__c;
                }else{
                    oficinaGestora = listaCuentas[0].AV_OficinaPrincipal__c;
                    numeroOficinaGestora = listaCuentas[0].AV_OficinaPrincipal__r?.CC_Numero_Oficina__c;
                }

            }else if (listaCuentas.size() == 0){
                // Ningún clientes.
                sError = '1';
                sDescError = 'El CIF informado no se ha encontrado';
            }else{
                // Varios clientes.
                sError = '2';
                sDescError = 'El CIF informado está duplicado';
            }
        }

        if(clienteId != null && String.isBlank(idContacto)){
            List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :clienteId LIMIT 1];
            if (!contacto.isEmpty()){
                idContacto = contacto[0].Id;
            }
        }
        
        if (sError == '0' && String.isNotBlank(idContacto))
        {
            // Comprobar el tipo de registro que viene informado.
            String tipoObjeto = obtenerTipoObjeto (idContacto);

            if (tipoObjeto == 'Contact')
            {
                List<AccountContactRelation> contactoRelacionado = [SELECT Id, AccountId, ContactId, Contact.Email
                                                        FROM AccountContactRelation
                                                        WHERE ContactId = :idContacto AND IsActive = true
                                                        ORDER BY AccountId, ContactId];
                if (contactoRelacionado.size() == 0)
                {
                    sError = '3';
                    sDescError = 'El contacto informado no se ha encontrado';
                }else{
                    if (String.isNotBlank(clienteId))
                    {
                        Boolean bEncontrado = false;
                        for (AccountContactRelation contacto : contactoRelacionado)
                        {
                            if (contacto.AccountId == clienteId)
                            {
                                bEncontrado = true;
                                break;
                            }
                        }

                        if (!bEncontrado)
                        {
                            sError = '4';
                            sDescError = 'El contacto informado no tiene relación con el CIF';
                            clienteId = '';
                        }
                    }else if (contactoRelacionado.size() > 1)
                    {
                        sError = '5';
                        sDescError = 'El contacto está asociado a más de una empresa';
                    }
                    contactoId = idContacto;
                    // Nos han enviado el contacto principal, recoger su e-mail.
                    direccionMail = contactoRelacionado[0].Contact.Email;
                }
            }else{
                // Canal de comunicación.
                List<CC_Canal_Com__c> contactoRelacionado = [SELECT Id, CC_CuentaId__c, CC_ContactoId__c, CC_Email__c
                                                        FROM CC_Canal_Com__c
                                                        WHERE Id = :idContacto AND CC_CuentaId__c <> null
                                                        ORDER BY CC_CuentaId__c, CC_ContactoId__c];
                if (contactoRelacionado.size() == 0)
                {
                    sError = '3';
                    sDescError = 'El contacto informado no se ha encontrado';
                }else{
                    if (String.isNotBlank(clienteId) && contactoRelacionado[0].CC_CuentaId__c != clienteId)
                    {
                        sError = '4';
                        sDescError = 'El contacto informado no tiene relación con el CIF';
                        clienteId = '';
                    }

                    contactoId = contactoRelacionado[0].CC_ContactoId__c;
                    // Nos han enviado el canal de comunicación, recoger su e-mail.
                    direccionMail = contactoRelacionado[0].CC_Email__c;
                }
            }
        }

        resultadoBusqueda.put('codigo',sError);
        resultadoBusqueda.put('detalle',sDescError);
        resultadoBusqueda.put('clienteId',clienteId);
        resultadoBusqueda.put('contactoId',contactoId);
        resultadoBusqueda.put('direccionMail', direccionMail);
        resultadoBusqueda.put('oficinaGestora', oficinaGestora);
        resultadoBusqueda.put('numeroOficinaGestora', numeroOficinaGestora);
        resultadoBusqueda.put('idiomaCliente', idiomaCliente);
        return resultadoBusqueda;
    }

    /**
     *  @description Buscar el MCC mediante la clasificación rápida.
     *  @param clasificacionRapida -> Nombre de la clasificación rápida a buscar.
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda
     */
    public static Map<String,String> determinarMCCporCR (String clasificacionRapida)
    {
        Map<String,String> resultadoBusqueda = new Map<String,String>();
        String sError = '0';
        String sDescError = '';
        String tematicaMCC = '';
        String productoMCC = '';
        String motivoMCC = '';
        String detalleMCC = '';
        String idClasificacion = '';

        if (String.isNotBlank(clasificacionRapida))
        {
            List<SEG_ClasificacionRapida__c> listaCR = [SELECT Id, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c
                                            FROM SEG_ClasificacionRapida__c 
                                            WHERE Name = :clasificacionRapida
                                            AND CBK_Negocio__c = 'Segmentos'
                                            AND SEG_Inactiva__c = false];
            if (listaCR.size() == 1)
            {
                // Cliente identificado.
                idClasificacion = listaCR[0].Id;
                tematicaMCC = listaCR[0].SEG_Tematica__c;
                productoMCC = listaCR[0].SEG_Producto__c;
                motivoMCC = listaCR[0].SEG_Motivo__c;
                detalleMCC = listaCR[0].SEG_Detalle__c;
            }else if (listaCR.size() == 0){
                // Ningún clientes.
                sError = '1';
                sDescError = 'La CR no se ha encontrado';
            }else{
                // Varios clientes.
                sError = '2';
                sDescError = 'La CR encontrada no es única';
            }
        }

        resultadoBusqueda.put('codigo',sError);
        resultadoBusqueda.put('detalle',sDescError);
        resultadoBusqueda.put('CRId', idClasificacion);
        resultadoBusqueda.put('tematicaMCC',tematicaMCC);
        resultadoBusqueda.put('productoMCC',productoMCC);
        resultadoBusqueda.put('motivoMCC',motivoMCC);
        resultadoBusqueda.put('detalleMCC',detalleMCC);
        return resultadoBusqueda;
    }

    /**
     *  @description Método para recuperar la organización de cada zona, en base a la definición de dependencias de campos en Salesforce.
     *  @param dependToken -> Campo dependiente que corresponde a la zona.
     *  @return Map<String,String> -> Mapa con los resultados de zona - organización.
     */
    public static Map<String,String> obtenerRelacionZonaOrganizacion(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String,String>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,String> dependentPicklistValues = new Map<String,String>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    /*
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                    */
                    dependentPicklistValues.put(entry.getValue(), (String) controlValue);
                }
            }
        }
        return dependentPicklistValues;
    }

    /**
     *  @description Recuperar los valores por defecto de la Organización y Zona.
     *  @param organizacion -> Organización a consultar
     *  @param zona -> Zona a consultar
     *  @return SEG_Buzon_mdt -> Objeto con la configuración de la Organización y Zona.
     */
    public static SEG_Buzon__mdt recuperarDatosOrganizacionZona (String organizacion, String zona)
    {
        Boolean bPorDefecto = false;
        SEG_Buzon__mdt retornoOZ = new SEG_Buzon__mdt();
        //String nombreGrupoMCC = '';

        if (String.isBlank(organizacion) || String.isBlank(zona))
        {
            // Recuperar la configuración por defecto.
            bPorDefecto = true;
        }else{
            List<SEG_Buzon__mdt> listaBuzon = [SELECT Id, SEG_Grupo_MCC__c, SEG_Correo_de_procedencia__c
                                                FROM SEG_Buzon__mdt
                                                WHERE SEG_Zona__c = :zona AND SEG_Organizacion__c = :organizacion];
            if (listaBuzon.isEmpty())
            {
                bPorDefecto = true;
            }else{
                //nombreGrupoMCC = listaBuzon[0].SEG_Grupo_MCC__c;
                retornoOZ = listaBuzon[0];
            }
        }

        // Si hay que recuperar el por defecto.
        if (bPorDefecto)
        {
            List<SEG_Buzon__mdt> listaBuzon = [SELECT Id, SEG_Grupo_MCC__c, SEG_Correo_de_procedencia__c
                                                FROM SEG_Buzon__mdt
                                                WHERE SEG_Zona__c = 'Por defecto' AND SEG_Organizacion__c = 'Por defecto'];
            if (!listaBuzon.isEmpty())
            {
                //nombreGrupoMCC = listaBuzon[0].SEG_Grupo_MCC__c;
                retornoOZ = listaBuzon[0];
            }
        }

        if (Test.isRunningTest() && retornoOZ != null)
        {
            // Devolver el grupo colaborador para la clase de test.
            retornoOZ.SEG_Grupo_MCC__c = 'MCC 0029';
        }

        return retornoOZ;
    }

    /**
     *  @description Búsqueda de un grupo de segmentos por nombre.
     *  @param nombreGrupo -> Nombre del grupo
     *  @return String -> Identificador Salesforce del grupo encontrado.
     */
    public static String buscarGrupoPorNombre (String nombreGrupo)
    {
        String grupoId = '';
        if (String.isNotBlank(nombreGrupo))
        {
            List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name =:nombreGrupo 
                                                        AND SEG_GrupoSegmentos__c = true
                                                        AND RecordType.DeveloperName = 'SEG_GrupoOperativoSegmentos' LIMIT 1];
            if (!listaGrupos.isEmpty())
            {
                grupoId = listaGrupos[0].Id;
            }
        }
        return grupoId;
    }

    /**
     *  @description Recuperar el buzón de salida por el nombre del perfil de envío.
     *  @param perfilEnvio -> Nombre del perfil a buscar.
     *  @return String -> Dirección del buzón de salida.
     */
    public static String recuperarBuzonSalida (String perfilEnvio)
    {
        String buzonSalida = '';

        if (String.isNotBlank(perfilEnvio))
        {
            List<SEG_Buzon__mdt> listaBuzon = [SELECT Id, DeveloperName, SEG_Correo_de_procedencia__c
                                                FROM SEG_Buzon__mdt
                                                WHERE DeveloperName = :perfilEnvio];
            if (!listaBuzon.isEmpty())
            {
                buzonSalida = listaBuzon[0].SEG_Correo_de_procedencia__c;
            }
        }

        return buzonSalida;
    }

    /**
     *  @description Recuperar el ID del usuario que será el propietario del caso.
     *  @param grupoCasoId -> Identificador de Salesforce del grupo.
     *  @param usuario -> Código de usuario a recuperar (U01xxxx).
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda.
     */
    public static Map<String,String> recuperarPropietarioCaso (String grupoCasoId, String usuario)
    {
        Map<String,String> resultado = new Map<String,String>();
        resultado.put('codigo','0');
        resultado.put('detalle','');

        if (String.isNotBlank(grupoCasoId) && String.isNotBlank(usuario))
        {
            List<CC_Grupo_Colaborador_Contact__c> usuarioGrupo = [SELECT Id, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :grupoCasoId
                                                                    AND CC_Grupo_Colaborador__r.SEG_GrupoSegmentos__c = true
                                                                    AND CC_Usuario__r.EmployeeNumber = :usuario];
            if (!usuarioGrupo.isEmpty())
            {
                resultado.put('propietarioId',usuarioGrupo[0].CC_Usuario__c);
            }else{
                resultado.put('codigo','1');
                resultado.put('detalle','El propietario del caso no pertenece al grupo de segmentos');
            }
        }

        return resultado;
    }

    /**
     *  @description Validar y recuperar si el usuario está en un centro CSO y cuál es su centro.
     *  @param usuario -> Código de usuario a recuperar (U01xxxx).
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda.
     */
    public static Map<String,String> validarUsuarioCSO (String usuario)
    {
        Map<String,String> resultado = new Map<String,String>();
        resultado.put('codigo','0');
        resultado.put('detalle','');
        resultado.put('usuarioCSOId','');

        if (String.isNotBlank(usuario))
        {
            List<SEG_UsuariosCSO__c> listaUsuarios = [SELECT Id, SEG_Usuario__c, SEG_Usuario__r.EmployeeNumber, SEG_GrupoCSO__c, SEG_GrupoCSO__r.SEG_ActivoCSO__c
                                                        FROM SEG_UsuariosCSO__c
                                                        WHERE SEG_Usuario__r.EmployeeNumber = :usuario
                                                        AND SEG_ActivoCSO__c = true];
            // Se toma como asunción que un usuario solo puede existir en un grupo CSO (req. de negocio)
            if (listaUsuarios.isEmpty())
            {
                resultado.put('codigo','2');
                resultado.put('detalle','El usuario no está dado de alta en un centro CSO');
            }else{
                resultado.put('centroCSO', listaUsuarios[0].SEG_GrupoCSO__c);
                resultado.put('usuarioCSOId', listaUsuarios[0].SEG_Usuario__c);
                if (listaUsuarios[0].SEG_GrupoCSO__r?.SEG_ActivoCSO__c == false)
                {
                    resultado.put('codigo','3');
                    resultado.put('detalle','El centro CSO no está activo');
                }
            }
        }else{
            resultado.put('codigo','1');
            resultado.put('detalle','El usuario no se ha informado');
        }

        return resultado;
    }

    /**
     *  @description Identificación del centro CaixaBank para el caso.
     *  @param oficina -> Número de oficina.
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> identificarCentroCaixa (String oficina, String idContacto)
    {
        Map<String,String> resultadoBusqueda = new Map<String,String>();
        ID recordTypeCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        String sError = '0';
        String sDescError = '';
        String clienteId = '';
        String contactoId = '';
        String direccionMail = '';
        String numeroOficinaGestora = '';
        String idiomaOficina = 'es';
        String organizacion = '';
        String zona = '';

        if (String.isNotBlank(oficina))
        {
            // Tratamos las oficinas de la empresa 001.
            String claveOficina = '001-' + oficina;

            List<Account> listaCuentas = [SELECT Id, CC_Idioma_Oficina__c, SEG_Organizacion__c, SEG_Zona__c 
                                            FROM Account 
                                            WHERE RecordTypeId = :recordTypeCliente
                                            AND CC_Numero_Oficina_Empresa__c = :claveOficina];
            if (listaCuentas.size() == 1)
            {
                // Cliente identificado.
                clienteId = listaCuentas[0].Id;
                numeroOficinaGestora = oficina;
                idiomaOficina = (String.isNotBlank(listaCuentas[0].CC_Idioma_Oficina__c) && listaCuentas[0].CC_Idioma_Oficina__c == '001') ? 'ca' : idiomaOficina;
                organizacion = listaCuentas[0].SEG_Organizacion__c;
                zona = listaCuentas[0].SEG_Zona__c;
            }else if (listaCuentas.size() == 0){
                // Ningún clientes.
                sError = '1';
                sDescError = 'La oficina informada no se ha encontrado';
            }else{
                // Varios clientes.
                sError = '2';
                sDescError = 'La oficina informada está duplicada';
            }
        }

        if (sError == '0' && String.isNotBlank(idContacto))
        {
            // Comprobar el tipo de registro que viene informado.
            String tipoObjeto = obtenerTipoObjeto (idContacto);

            if (tipoObjeto == 'Contact')
            {
                List<AccountContactRelation> contactoRelacionado = [SELECT Id, AccountId, ContactId, Contact.Email
                                                        FROM AccountContactRelation
                                                        WHERE ContactId = :idContacto AND IsActive = true AND IsDirect = true
                                                        ORDER BY AccountId, ContactId];
                if (contactoRelacionado.size() == 0)
                {
                    sError = '3';
                    sDescError = 'El contacto informado no se ha encontrado';
                }else{
                    if (String.isNotBlank(clienteId))
                    {
                        Boolean bEncontrado = false;
                        for (AccountContactRelation contacto : contactoRelacionado)
                        {
                            if (contacto.AccountId == clienteId)
                            {
                                bEncontrado = true;
                                break;
                            }
                        }

                        if (!bEncontrado)
                        {
                            sError = '4';
                            sDescError = 'El contacto informado no tiene relación con la oficina';
                            clienteId = '';
                        }
                    }else if (contactoRelacionado.size() > 1)
                    {
                        sError = '5';
                        sDescError = 'El contacto está asociado a más de una oficina';
                    }
                    contactoId = idContacto;
                    // Nos han enviado el contacto principal, recoger su e-mail.
                    direccionMail = contactoRelacionado[0].Contact.Email;
                }
            }
        }

        resultadoBusqueda.put('codigo',sError);
        resultadoBusqueda.put('detalle',sDescError);
        resultadoBusqueda.put('clienteId',clienteId);
        resultadoBusqueda.put('contactoId',contactoId);
        resultadoBusqueda.put('direccionMail', direccionMail);
        resultadoBusqueda.put('numeroOficinaGestora', numeroOficinaGestora);
        resultadoBusqueda.put('idiomaOficina', idiomaOficina);
        resultadoBusqueda.put('organizacion', organizacion);
        resultadoBusqueda.put('zona', zona);
        return resultadoBusqueda;
    }

    /**
     *  @description Recuperar si el grupo del caso es un colaborador externo en base a la parametrización del MCC.
     *  @param organizacion -> Organización del caso.
     *  @param zona -> Zona del caso.
     *  @param grupo -> Identificador del grupo del caso.
     *  @param mccsCaso -> MCC de clasificación del caso.
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda y validación.
     */
    /* OLD. SE DESCATALOGA ESTE METODO PARA LA PARTE DE ROBOTICS.
    public static Map<String,String> recuperarColaboradorExterno (String organizacion, String zona, String grupo, Set<String> mccsCaso, String numeroOficinaGestora)
    {
        Map<String,String> resultado = new Map<String,String>();
        resultado.put('error','0');
        resultado.put('esExterno', 'N');
        resultado.put('cierreCaso','N');

        List<CC_MCC_Grupo_Colaborador__c> gcolab = new List<CC_MCC_Grupo_Colaborador__c>(
            [SELECT Id, CC_MCC__c,SEG_Organizacion__c,SEG_Zona__c,SEG_Grupo_respuesta__c,CC_Grupo_Colaborador__c,
            CC_Grupo_Colaborador__r.RecordType.DeveloperName, SEG_Prioridad__c, SEG_Grupo_respuesta__r.Name,
            CC_Grupo_Colaborador__r.SEG_CierreAutomaticoSR__c
            FROM CC_MCC_Grupo_Colaborador__c 
            WHERE CC_MCC__c in :mccsCaso 
            AND (SEG_Organizacion__c=:organizacion OR SEG_Organizacion__c='Todas') 
            AND (SEG_Zona__c=:zona OR SEG_Zona__c='Todas') and CC_Grupo_Colaborador__c=:grupo
            ORDER BY SEG_Prioridad__c ASC
            LIMIT 1]);
        
        if(gcolab.size() > 0)
        {
            if(gcolab[0].CC_Grupo_Colaborador__r.RecordType.DeveloperName == 'CC_Grupo_Colaborador')
            {
                String grupoRespuesta = gcolab[0].SEG_Grupo_respuesta__c;
                String grupoRespuestaName = gcolab[0].SEG_Grupo_respuesta__r?.Name;
                Boolean bCierreCaso = false;

                resultado.put('esExterno', 'Y');
                resultado.put('grupoRespuesta', grupoRespuesta);

                // Gestionar el cierre del caso, según la parametrización del grupo colaborador.
                bCierreCaso = (gcolab[0].CC_Grupo_Colaborador__r?.SEG_CierreAutomaticoSR__c != null) ? gcolab[0].CC_Grupo_Colaborador__r.SEG_CierreAutomaticoSR__c : false;

                // Migración del código de autoasignación SEG_Case_Operativas_Controller.
                // Revisar el grupo de respuesta, que no contenga '*'
                
                // Control del número de oficina informado.
                if (String.isNotBlank(grupoRespuestaName) && grupoRespuestaName.endsWith('*') && String.isBlank(numeroOficinaGestora))
                {
                    resultado.put('error','1');
                }

                if (String.isNotBlank(grupoRespuestaName) && String.isNotBlank(numeroOficinaGestora) && grupoRespuestaName.endsWith('*'))
                {
                    String nuevoGrupoRespuesta = grupoRespuestaName.replace('*', ' ') + numeroOficinaGestora;
                    List<CC_Grupo_Colaborador__c> listadoGrupo = [SELECT Id, SEG_CierreAutomaticoSR__c FROM CC_Grupo_Colaborador__c WHERE Name = :nuevoGrupoRespuesta LIMIT 1];
                    if (!listadoGrupo.isEmpty())
                    {
                        // Grupo encontrado, sustituir por el nuevo grupo.
                        resultado.put('grupoRespuesta', listadoGrupo[0].Id);

                        // Gestionar el cierre del caso, según parametrización del nuevo grupo.
                        bCierreCaso = (listadoGrupo[0].SEG_CierreAutomaticoSR__c != null) ? listadoGrupo[0].SEG_CierreAutomaticoSR__c : false;
                    }
                }

                // Estado inicial en el que quedará el caso.
                resultado.put('nuevoEstadoCaso','Pendiente');
                resultado.put('nuevoSubEstadoCaso', 'En colaborador');

                if (bCierreCaso)
                {
                    // El caso se cerrará después de crearlo.
                    resultado.put('cierreCaso','Y');
                    resultado.put('estadoCierre','Cerrado');
                    resultado.put('subestadoCierre', 'Envío cierre Colaborador');
                }
            }
        }

        return resultado;
    }
    FIN OLD.*/

    /**
     * 
     */
    public static Case recuperarInformacionCaso (String identificadorCaso)
    {
        Case casoEncontrado;

        if (String.isNotBlank(identificadorCaso))
        {
            List<Case> listadoCasos = [SELECT Id, Status, IsClosed, SEG_Grupo__c, OwnerId, SEG_Organizacion__c, SEG_Zona__c, Origin,
                                        CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c, AccountId, Account.CC_Numero_Documento__c,
                                        SEG_N_operaciones_CSO__c
                                        FROM Case
                                        WHERE Id = :identificadorCaso
                                        AND RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')];
            if (!listadoCasos.isEmpty())
            {
                casoEncontrado = listadoCasos[0];
            }
        }

        return casoEncontrado;
    }

    public static Map<String,String> recuperarConfiguracionNuevoEstado (String estado)
    {
        Map<String,String> retorno = new Map<String,String>();
        retorno.put('encontrado','N');
        retorno.put('cerrado','N');

        if (String.isNotBlank(estado))
        {
            List<CaseStatus> configuracionEstados = [SELECT Id, ApiName, IsClosed FROM CaseStatus WHERE ApiName = :estado];
            if (!configuracionEstados.isEmpty())
            {
                String estadoCierre = (configuracionEstados[0].IsClosed)?'Y':'N';
                retorno.put('encontrado','Y');
                retorno.put('cerrado',estadoCierre);
            }
        }

        return retorno;
    }

    public static String obtenerTipoObjeto (String identificador)
    {
        String sObjName = '';
        ID iRegistro = identificador;
        Schema.SObjectType oTipoObj = iRegistro.getSobjectType();
        if (oTipoObj != null)
        {
            try {
                sObjName = oTipoObj.getDescribe().getName();
            } catch (Exception e) {
                sObjName = '';
            }
        }
        return sObjName;
    }

    public static Map<String,String> validarDatosMCC (String tematica, String producto, String motivo, String detalle)
    {
        Map<String,String> resultado = new Map<String,String>();
        resultado.put('codigo','0');
        resultado.put('detalle','');

        // Si no hay datos informados, salir.
        if (String.isBlank(tematica) && String.isBlank(producto) && String.isBlank(motivo) && String.isBlank(detalle))
        {
            return resultado;
        }

        // Validar coherencia de datos.
        if (String.isBlank(tematica) && (String.isNotBlank(producto) || String.isNotBlank(motivo) || String.isNotBlank(detalle)))
        {
            resultado.put('codigo','1');
            resultado.put('detalle','MCC informado incorrectamente.');
            return resultado;
        }

        if (String.isNotBlank(tematica) && String.isBlank(producto) && (String.isNotBlank(motivo) || String.isNotBlank(detalle)))
        {
            resultado.put('codigo','2');
            resultado.put('detalle','MCC informado incorrectamente.');
            return resultado;
        }

        if (String.isNotBlank(tematica) && String.isNotBlank(producto) && String.isBlank(motivo) && String.isNotBlank(detalle))
        {
            resultado.put('codigo','3');
            resultado.put('detalle','MCC informado incorrectamente.');
            return resultado;
        }

        // Preparar la query SOQL a lanzar.
        String querySOQL = 'SELECT Id, CC_Motivo__c, CC_Motivo__r.CC_Producto_Servicio__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c'; // Detalle
        querySOQL = querySOQL + ', CC_Producto_Servicio__c, CC_Producto_Servicio__r.CC_Tematica__c'; // Motivo
        querySOQL = querySOQL + ', CC_Tematica__c'; // Producto
        querySOQL = querySOQL + ' FROM CC_MCC__c WHERE ';

        if (String.isNotBlank(detalle))
        {
            querySOQL = querySOQL + ' RecordType.DeveloperName = \'SEG_Detalle\'';
            querySOQL = querySOQL + ' AND Name = \'' + detalle + '\'';
            querySOQL = querySOQL + ' AND CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Activo__c = true';

            querySOQL = querySOQL + ' AND CC_Motivo__r.RecordType.DeveloperName = \'CC_Motivo\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.Name = \'' + motivo + '\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Activo__c = true';

            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.RecordType.DeveloperName = \'CC_Producto_Servicio\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.Name = \'' + producto + '\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.CC_Activo__c = true';

            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.RecordType.DeveloperName = \'CC_Tematica\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name = \'' + tematica + '\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Activo__c = true';
        }else if (String.isNotBlank(motivo))
        {
            querySOQL = querySOQL + ' RecordType.DeveloperName = \'CC_Motivo\'';
            querySOQL = querySOQL + ' AND Name = \'' + motivo + '\'';
            querySOQL = querySOQL + ' AND CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Activo__c = true';

            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.RecordType.DeveloperName = \'CC_Producto_Servicio\'';
            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.Name = \'' + producto + '\'';
            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.CC_Activo__c = true';

            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.CC_Tematica__r.RecordType.DeveloperName = \'CC_Tematica\'';
            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.CC_Tematica__r.Name = \'' + tematica + '\'';
            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.CC_Tematica__r.CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Producto_Servicio__r.CC_Tematica__r.CC_Activo__c = true';
        }else if (String.isNotBlank(producto))
        {
            querySOQL = querySOQL + ' RecordType.DeveloperName = \'CC_Producto_Servicio\'';
            querySOQL = querySOQL + ' AND Name = \'' + producto + '\'';
            querySOQL = querySOQL + ' AND CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Activo__c = true';

            querySOQL = querySOQL + ' AND CC_Tematica__r.RecordType.DeveloperName = \'CC_Tematica\'';
            querySOQL = querySOQL + ' AND CC_Tematica__r.Name = \'' + tematica + '\'';
            querySOQL = querySOQL + ' AND CC_Tematica__r.CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Tematica__r.CC_Activo__c = true';
        }else if (String.isNotBlank(tematica))
        {
            querySOQL = querySOQL + ' RecordType.DeveloperName = \'CC_Tematica\'';
            querySOQL = querySOQL + ' AND Name = \'' + tematica + '\'';
            querySOQL = querySOQL + ' AND CC_Tipo_Cliente__c = \'Segmentos\'';
            querySOQL = querySOQL + ' AND CC_Activo__c = true';
        }

        List<CC_MCC__c> listadoMCC = Database.query(querySOQL);
        if (listadoMCC.isEmpty() || listadoMCC.size() > 1)
        {
            resultado.put('codigo','4');
            resultado.put('detalle','La clasificación MCC informada no es correcta.');
            return resultado;
        }

        if (String.isNotBlank(detalle))
        {
            resultado.put('mccTematica',listadoMCC[0].CC_Motivo__r?.CC_Producto_Servicio__r?.CC_Tematica__c);
            resultado.put('mccProducto',listadoMCC[0].CC_Motivo__r?.CC_Producto_Servicio__c);
            resultado.put('mccMotivo',listadoMCC[0].CC_Motivo__c);
            resultado.put('mccDetalle',listadoMCC[0].Id);
        }else if (String.isNotBlank(motivo))
        {
            resultado.put('mccTematica',listadoMCC[0].CC_Producto_Servicio__r?.CC_Tematica__c);
            resultado.put('mccProducto',listadoMCC[0].CC_Producto_Servicio__c);
            resultado.put('mccMotivo',listadoMCC[0].Id);
            resultado.put('mccDetalle','');
        }else if (String.isNotBlank(producto))
        {
            resultado.put('mccTematica',listadoMCC[0].CC_Tematica__c);
            resultado.put('mccProducto',listadoMCC[0].Id);
            resultado.put('mccMotivo','');
            resultado.put('mccDetalle','');
        }else if (String.isNotBlank(tematica))
        {
            resultado.put('mccTematica',listadoMCC[0].Id);
            resultado.put('mccProducto','');
            resultado.put('mccMotivo','');
            resultado.put('mccDetalle','');
        }


        // Recuperar los datos del MCC y validar coherencia.
        /*List<CC_MCC__c> listaTematica = [SELECT Id FROM CC_MCC__c 
                                            WHERE RecordType.DeveloperName = 'CC_Tematica'
                                            AND Name = :tematica
                                            AND CC_Tipo_Cliente__c = 'Segmentos'
                                            AND CC_Activo__c = true];
        if (listaTematica.isEmpty() || listaTematica.size() > 1)
        {
            resultado.put('codigo','4');
            resultado.put('detalle','La temática informada no es correcta.');
            return resultado;
        }

        if (String.isNotBlank(producto))
        {
            List<CC_MCC__c> listaProducto = [SELECT Id FROM CC_MCC__c 
                                                WHERE RecordType.DeveloperName = 'CC_Tematica'
                                                AND Name = :producto
                                                AND CC_Tematica__r.Name = 
                                                AND CC_Tipo_Cliente__c = 'Segmentos'
                                                AND CC_Activo__c = true];
            if (listaProducto.isEmpty() || listaProducto.size() > 1)
            {
                resultado.put('codigo','5');
                resultado.put('detalle','El producto informada no es correcta.');
                return resultado;
            }
        }*/

        return resultado;
    }

    /**
     *  @description Crear el registro de operaciones CSO.
     *  @param casoId -> Identificador de caso.
     *  @param usuarioId -> Identificador del usuario CSO.
     *  @param numeroOperaciones -> Número de operaciones CSO.
     */
    public static void crearRegistroOperacionCSO (String casoId, String usuarioId, Integer numeroOperaciones)
    {
        SEG_Operacion__c operacionCSO = new SEG_Operacion__c();
        operacionCSO.RecordTypeId = Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName().get('CSO').getRecordTypeId();
        operacionCSO.SEG_N_Operaciones__c = numeroOperaciones;
        operacionCSO.SEG_SR__c = casoId;
        operacionCSO.SEG_Usuario__c = usuarioId;
        insert operacionCSO;

        return;
    }

    /**
     *  @description Crear el registro de operaciones CSO.
     *  @param casoId -> Identificador de caso.
     *  @param usuarioId -> Identificador del usuario CSO.
     *  @param numeroOperaciones -> Número de operaciones CSO.
     */
    public static void crearRegistroOperacionCSO (String casoId, String usuarioId, Integer numeroOperaciones, String tematica, String producto, String motivo, String detalle, String mcc)
    {
        SEG_Operacion__c operacionCSO = new SEG_Operacion__c();
        operacionCSO.RecordTypeId = Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName().get('CSO').getRecordTypeId();
        operacionCSO.SEG_N_Operaciones__c = numeroOperaciones;
        operacionCSO.SEG_SR__c = casoId;
        operacionCSO.SEG_Usuario__c = usuarioId;
        operacionCSO.SEG_Tematica__c = !String.IsBlank(tematica) ? tematica : null;
        operacionCSO.SEG_Producto__c = !String.IsBlank(producto) ? producto : null;
        operacionCSO.SEG_Motivo__c = !String.IsBlank(motivo) ? motivo : null;
        operacionCSO.SEG_Detalle__c = !String.IsBlank(detalle) ? detalle : null;
        operacionCSO.SEG_MCC__c = !String.IsBlank(mcc) ? mcc : null;
        insert operacionCSO;

        return;
    }

    /**
     * @description Calcular las excepciones de un caso.
     * @param caseId Identificador del caso
     */
    /* OLD. NO UTILIZAMOS AL UTILIZAR EL MÉTODO DE AUTOASIGNAR.
    @future
    public static void calcularExcepcionesCasoFuture (String caseId)
    {
        if (String.isNotBlank(caseId))
        {
            try{
                SEG_Case_Operativas_Controller.identificarExcepciones(caseId); 
            }catch (Exception e) {
                CBK_Log.error(e);
            }
        }
    }
    */

    /**
     * @description Calcular las excepciones de un caso (sin excepciones de Asignación)
     * @param caseId Identificador del caso
     */
    /*@future
    public static void calcularExcepcionesNoAsignacionCasoFuture (String caseId)
    {
        if (String.isNotBlank(caseId))
        {
            try{
                SEG_Case_Operativas_Controller.identificarExcepcionesSinAsignacion(caseId); 
            }catch (Exception e) {
                CBK_Log.error(e);
            }
        }
    }*/
}