public with sharing class SEG_Case_EmailBuscador_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getDatosDestinatario(Id recordId) {
        //Sacar datos del destinatario
        Map<String, String> datosDestinatario = new Map<String, String>();

        if ((recordId).getSObjectType() == Schema.SObjectType.AccountContactRelation.getSObjectType()){
            AccountContactRelation c = [SELECT Contact.Name, Contact.Email FROM AccountContactRelation WHERE id = :recordId];
            if (c.Contact.Email == null) {
                datosDestinatario.put(c.Contact.Name, 'Sin correo');
            } else{
                datosDestinatario.put(c.Contact.Name, c.Contact.Email);
            }
        } else if ((recordId).getSObjectType() == Schema.SObjectType.CC_Grupo_Colaborador__c.getSObjectType()){
            CC_Grupo_Colaborador__c g = [SELECT Name, CC_Cuenta__r.CC_Email__c FROM CC_Grupo_Colaborador__c WHERE Id = :recordId];
            datosDestinatario.put(g.Name, g.CC_Cuenta__r.CC_Email__c);
            if(datosDestinatario.get(g.Name) == null){
                datosDestinatario.put(g.Name, 'Sin correo');
            }
        }
        return datosDestinatario;
    }

    @AuraEnabled(cacheable=true)
    public static sObject datosRegistro(Id recordId) {
        sObject retorno;
        if ((recordId).getSObjectType() == Schema.SObjectType.Case.getSObjectType()){
            retorno = [SELECT CC_No_Identificado__c, AccountId, ContactId, RecordType.DeveloperName FROM Case WHERE Id = :recordId];
        }
        return retorno;
    }

    @AuraEnabled
    public static Boolean getEsPropietarioObjeto(Id recordId) {
        Id propietarioRegistro;
        //Comparamos el usuario logado con el propietario del registro y devolvemos si coinciden o no
        if ((recordId).getSObjectType() == Schema.SObjectType.Case.getSObjectType()){
            propietarioRegistro = [SELECT OwnerId FROM Case WHERE Id = :recordId].OwnerId;
        }
        return (propietarioRegistro == UserInfo.getUserId());
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador_Contact__c> colaboradoresPara(Id idGrupo) {
        return [SELECT CC_Nombre__c, CC_Email__c, CC_Grupo_Colaborador__c, CC_Para_CC__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c = :idGrupo];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> canalComunicacionPara(Id idCaso, Id idContacto) {

        Set<String> listaPara = new Set<String>();
        Set<String> listaCc = new Set<String>();
        Set<String> listaCco = new Set<String>();
            
        if ((idContacto).getSObjectType() == Schema.SObjectType.Contact.getSObjectType()){
            List<Contact> contactos = [SELECT Email FROM Contact WHERE Id = :idContacto];
            if (!contactos.isEmpty()) {
                String direccionCorreoPrincipal = [SELECT Email FROM Contact WHERE Id = :idContacto].Email;
                if (String.isNotBlank(direccionCorreoPrincipal)) {
                    listaPara.add(direccionCorreoPrincipal);
                }

                //TODO: CONTROLAR QUE direccionCorreoPrincipal no sea null, porque sino va a petar en la query de arriba.
                Case caso = [SELECT AccountId FROM Case WHERE Id = :idCaso];
                for (CC_Canal_Com__c canalComunicacion : [SELECT CC_Email__c, SEG_ParaCC__c, CC_CuentaId__c FROM CC_Canal_Com__c
                                                            WHERE RecordType.DeveloperName = 'CC_Email' AND CC_Email__c != NULL
                                                            AND (CC_CuentaId__c = :caso.AccountId OR CC_CuentaId__c = NULL)
                                                            AND CC_ContactoId__c = :idContacto]) {
                    if (canalComunicacion.SEG_ParaCC__c == 'Para') {
                        listaPara.add(canalComunicacion.CC_Email__c);
                    } if (canalComunicacion.SEG_ParaCC__c == 'CC') {
                        listaCc.add(canalComunicacion.CC_Email__c);
                    } if (canalComunicacion.SEG_ParaCC__c == 'CCO') {
                        listaCco.add(canalComunicacion.CC_Email__c);
                    }
                }
            }
        }
        else if ((idContacto).getSObjectType() == Schema.SObjectType.CC_Grupo_Colaborador__c.getSObjectType()) {
            List<CC_Grupo_Colaborador_Contact__c> grupocolab = [SELECT Id, CC_Contacto__r.Name, CC_Contacto__r.Id, CC_Email__c, toLabel(CC_Para_CC__c) FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c =:idContacto];
            List<Id> contacts = new List<Id>();
            for (CC_Grupo_Colaborador_Contact__c colabo : grupocolab) {
                if (colabo.CC_Para_CC__c == 'Para') {
                    contacts.add(colabo.CC_Contacto__r.Id);
                }
            }
            if (!contacts.isEmpty()) {
                Case caso = [SELECT AccountId FROM Case WHERE Id = :idCaso];
                for (CC_Canal_Com__c canalComunicacion : [SELECT CC_Email__c, SEG_ParaCC__c, CC_CuentaId__c FROM CC_Canal_Com__c
                                                            WHERE RecordType.DeveloperName = 'CC_Email' AND CC_Email__c != NULL
                                                            AND (CC_CuentaId__c =:caso.AccountId OR CC_CuentaId__c = NULL)
                                                            AND CC_ContactoId__c IN: contacts]) {
                    if (canalComunicacion.SEG_ParaCC__c == 'Para') {
                        listaPara.add(canalComunicacion.CC_Email__c);
                    } if (canalComunicacion.SEG_ParaCC__c == 'CC') {
                        listaCc.add(canalComunicacion.CC_Email__c);
                    } if (canalComunicacion.SEG_ParaCC__c == 'CCO') {
                        listaCco.add(canalComunicacion.CC_Email__c);
                    }
                }
            }
        }
        return new Map<String, List<String>>{
            'Para' => new List<String>(listaPara),
            'Cc' => new List<String>(listaCc),
            'Cco' => new List<String>(listaCco)
        };
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getIdentidad(String valorBusqueda, Id caseId) {
        String valorBusqueda2 = valorBusqueda;
        Case caso = [SELECT AccountId, SEG_Numero_de_centro__c FROM Case WHERE Id = :caseId];
        Integer labelLimit = Integer.valueOf(Label.SEG_Limite_Busaqueda_Contactos);

        Map<String, Object> resultadoBusqueda = new Map<String, Object>();
        Map<String, BusquedaWrapperOtroGestor> mapaResultadosOtrosGestores = new Map<String, BusquedaWrapperOtroGestor>();
        Map<String, BusquedaWrapperColaborador> mapaResultadosColaborador = new Map<String, BusquedaWrapperColaborador>();
        Map<String, BusquedaWrapperGrupoColaborador> mapaResultadosGruposColaboradores = new Map<String, BusquedaWrapperGrupoColaborador>();
        Map<String, BusquedaWrapperGestor> mapaResultadosContactoGestor = new Map<String, BusquedaWrapperGestor>();
        Map<String, BusquedaWrapperEmpresa> mapaResultadosContacto = new Map<String, BusquedaWrapperEmpresa>();

        List<Id> listadoObjetosEncontrados = new List<Id>();
        if (String.isBlank(valorBusqueda2)) {
            resultadoBusqueda.put('RESULTADO', '0');
            resultadoBusqueda.put('DETALLE', 'Has de informar un criterio de búsqueda.');
            return resultadoBusqueda;
        } else {
            // Quitar caracteres especiales para comprobar la longitud mínima que necesita Salesforce para buscar.
            String regExpChars = '[^A-ZÀ-ȕa-z0-9@\\.\'"]';
            String valorSinEspeciales = valorBusqueda2.replaceAll(regExpChars, '');
            if (valorSinEspeciales.length() <= 2) {
                resultadoBusqueda.put('RESULTADO', '0');
                resultadoBusqueda.put('DETALLE', 'Has de informar más de 2 caracteres para buscar.');
                return resultadoBusqueda;
            }
        }

        // Añadir wildcard para la búsqueda
        valorBusqueda2 += '*';
        String limitRowsValue = SEG_MetodosComunes.recuperarParametrosValor('SEG_BuscadorLimitRows');

        Integer limitRows = 50; // Valor por defecto
        if (String.isNotBlank(limitRowsValue)) {
            limitRows = Integer.valueOf(limitRowsValue);
        }
        
        List<List<SObject>> searchListOtros = [FIND :valorBusqueda2 IN ALL FIELDS 
                                                RETURNING Contact(Name, AccountId, Email, FirstName, LastName,CC_Nombre_Oficina__c, CC_Cargo__c, SEG_Centro__c, RecordType.DeveloperName, SEG_Estado__c, Account.CC_Numero_Oficina__c)
                                                LIMIT :limitRows];
        
        List<Contact> contactosNumOficina = [SELECT Name, AccountId, Email, FirstName, LastName,CC_Nombre_Oficina__c, CC_Cargo__c, SEG_Centro__c, RecordType.DeveloperName, SEG_Estado__c, Account.CC_Numero_Oficina__c FROM Contact WHERE Account.CC_Numero_Oficina__c LIKE :valorBusqueda LIMIT :limitRows];

        if(!contactosNumOficina.isEmpty()){
            searchListOtros[0].addAll(contactosNumOficina);
        }

        Set<Id> setidContacto = new Set<Id>();
        for (List<SObject> searchSubList : searchListOtros) {
            for (SObject objetoSearch : searchSubList) {
                Contact contacto = (Contact)objetoSearch;
                setidContacto.add(contacto.Id);
            }
        }

        Map<String,List<CC_Grupo_Colaborador_Contact__c>> mapGrupoColaborador = new Map<String,List<CC_Grupo_Colaborador_Contact__c>>();
        List<CC_Grupo_Colaborador_Contact__c> listGrupoColaboradorContact;

        if(!setidContacto.isEmpty()){
            listGrupoColaboradorContact = [SELECT Id, CC_Grupo_Colaborador__r.Name, CC_Contacto__r.FirstName, CC_Contacto__r.Id
            FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Contacto__r.Id  IN :setidContacto]; //LIMIT :labelLimit
        
            if(listGrupoColaboradorContact != null && !listGrupoColaboradorContact.isEmpty()){ 
                for (CC_Grupo_Colaborador_Contact__c grupoColaboradorContact : listGrupoColaboradorContact) {
                    if(mapGrupoColaborador.containsKey(grupoColaboradorContact.CC_Contacto__r.Id)) {
                        List<CC_Grupo_Colaborador_Contact__c> lstGrupos = mapGrupoColaborador.get(grupoColaboradorContact.CC_Contacto__r.Id);
                        lstGrupos.add(grupoColaboradorContact);
                       if(lstGrupos.size() < labelLimit){
                        mapGrupoColaborador.put(grupoColaboradorContact.CC_Contacto__r.Id,lstGrupos);

                       }
                    } else {
                        mapGrupoColaborador.put(grupoColaboradorContact.CC_Contacto__r.Id, new List<CC_Grupo_Colaborador_Contact__c> {grupoColaboradorContact});
                    }
                 }
            }
        }

        for (List<SObject> searchSubList : searchListOtros) {
            for (SObject objetoSearch : searchSubList) {
                Contact contacto = (Contact)objetoSearch;
                if (contacto.RecordType.DeveloperName == 'CC_Empleado' && contacto.Email != null) {
                    BusquedaWrapperOtroGestor resultado = new BusquedaWrapperOtroGestor();
                    resultado.tipoRegistro = 'contacto';
                    resultado.idContacto = contacto.Id;
                    resultado.nombre = contacto.FirstName;
                    resultado.apellido = contacto.LastName;
                    if (contacto.Email != null) {
                        resultado.email = contacto.Email;
                    }/* else {
                        resultado.email = 'Sin correo';
                    }*/
                    if (contacto.Account.CC_Numero_Oficina__c != null) {
                        resultado.centro = contacto.Account.CC_Numero_Oficina__c;
                    } else {
                        resultado.centro = 'Sin centro';
                    }

                    mapaResultadosOtrosGestores.put(resultado.idContacto, resultado);
                    listadoObjetosEncontrados.add(contacto.Id);

                } else if (contacto.RecordType.DeveloperName == 'CC_Cliente' && contacto.SEG_Estado__c != 'Inactivo' && contacto.Email != null) {
                    BusquedaWrapperEmpresa resultado = new BusquedaWrapperEmpresa();
                    resultado.tipoRegistro = 'contacto';
                    resultado.idContacto = contacto.Id;
                    resultado.nombre = contacto.FirstName;
                    resultado.apellido = contacto.LastName;
                    resultado.empresa = contacto.CC_Nombre_Oficina__c;

                    if (contacto.Email != null) {
                        resultado.email = contacto.Email;
                    } /*else {
                        resultado.email = 'Sin correo';
                    }*/
                    if (contacto.CC_Cargo__c != null) {
                        resultado.cargos = contacto.CC_Cargo__c;
                    } else {
                        resultado.cargos = 'Sin cargo';
                    }

                    mapaResultadosContacto.put(resultado.idContacto, resultado);
                    listadoObjetosEncontrados.add(contacto.Id);

                } else if (contacto.RecordType.DeveloperName == 'CC_Colaborador' && mapGrupoColaborador.containsKey(contacto.Id)){
                    BusquedaWrapperColaborador resultado = new BusquedaWrapperColaborador();
                    List<CC_Grupo_Colaborador_Contact__c> gc = mapGrupoColaborador.get(contacto.Id);
                    resultado.tipoRegistro = 'contacto';
                    resultado.idContacto = contacto.Id;
                    resultado.nombre = contacto.FirstName;
                    resultado.apellido = contacto.LastName;

                    if (contacto.Email != null) {
                        resultado.email = contacto.Email;
                    } else {
                        resultado.email = 'Sin correo';
                    }

                    if (!gc.isEmpty()) {
                        resultado.grupo = gc[0].CC_Grupo_Colaborador__r.Name;
                    }

                    mapaResultadosColaborador.put(resultado.idContacto, resultado);
                    listadoObjetosEncontrados.add(contacto.Id);
                }
            }
        }

        List<List<SObject>> searchList = [FIND :valorBusqueda2 IN ALL FIELDS
                                            RETURNING
                                            Contact (Name, AccountId, Email, FirstName,LastName, CC_Cargo__c, RecordType.DeveloperName, SEG_Centro__c),
                                            CC_Grupo_Colaborador__c (Name, RecordType.Name WHERE RecordType.Name = 'Grupo Colaborador' AND OS_Negocio__c = 'SEGMENTOS')
                                            LIMIT :limitRows];

        for (List<SObject> searchSubList : searchList) {
            for (SObject objetoSearch : searchSubList) {
                if (objetoSearch.getSObjectType() == Schema.CC_Grupo_Colaborador__c.getSObjectType()) {
                    BusquedaWrapperGrupoColaborador resultado = new BusquedaWrapperGrupoColaborador();
                    CC_Grupo_Colaborador__c grupo = (CC_Grupo_Colaborador__c)objetoSearch;
                    resultado.tipoRegistro = 'grupo';
                    resultado.idGrupo = grupo.Id;
                    resultado.nombre = grupo.Name;
                    resultado.tipo = 'Grupo Colaborador';
                    mapaResultadosGruposColaboradores.put(resultado.idGrupo, resultado);
                    listadoObjetosEncontrados.add(grupo.Id);
                }
            }
        }

        //Nueva búsqueda por nombre o número de centro
        // System.debug('valorBusqueda: ' + valorBusqueda2);
        // List<Contact> empleadosCentro = [SELECT FirstName, LastName, Email, Account.CC_Numero_Oficina__c FROM Contact
        //                                     WHERE RecordType.DeveloperName = 'CC_Empleado'
        //                                     AND Account.RecordType.DeveloperName = 'CC_CentroCaixaBank'
        //                                     AND (Account.Name = :valorBusqueda OR Account.CC_Numero_Oficina__c LIKE :valorBusqueda)];
        // System.debug('empleadosCentro: ' + empleadosCentro);
        // for (Contact empleadoCentro : empleadosCentro) {
        //     System.debug('empleadoCentro.LastName: ' + empleadoCentro.LastName);

        //     BusquedaWrapperOtroGestor resultado = new BusquedaWrapperOtroGestor();
        //     resultado.tipoRegistro = 'contacto';
        //     resultado.idContacto = empleadoCentro.Id;
        //     resultado.nombre = empleadoCentro.FirstName;
        //     resultado.apellido = empleadoCentro.LastName;
        //     if (empleadoCentro.Email != null) {
        //         resultado.email = empleadoCentro.Email;
        //     } else {
        //         resultado.email = 'Sin correo';
        //     }
        //     resultado.centro = empleadoCentro.Account.CC_Numero_Oficina__c;

        //     mapaResultadosOtrosGestores.put(empleadoCentro.Id, resultado);
        //     listadoObjetosEncontrados.add(empleadoCentro.Id);
        // }                                            

        // Preparar resultado a devolver
        Map<String, BusquedaWrapperEmpresa> mapaFinalContactos = new Map<String, BusquedaWrapperEmpresa>();
        Map<String, BusquedaWrapperColaborador> mapaFinalColaboradores = new Map<String, BusquedaWrapperColaborador>();
        Map<String, BusquedaWrapperGrupoColaborador> mapaFinalGrupoColaborador = new Map<String, BusquedaWrapperGrupoColaborador>();
        Map<String, BusquedaWrapperOtroGestor> mapaFinalOtrosGestores = new Map<String, BusquedaWrapperOtroGestor>();
        Map<String, BusquedaWrapperGestor> mapaFinalGestores= new Map<String, BusquedaWrapperGestor>();

        // Mapa de contactos
        if (!mapaResultadosContacto.isEmpty()){
            mapaFinalContactos.putAll(mapaResultadosContacto);
        }
        mapaResultadosContacto.clear();

        // Mapa de colaboradores
        if (!mapaResultadosColaborador.isEmpty()){
            mapaFinalColaboradores.putAll(mapaResultadosColaborador);
        }
        mapaResultadosColaborador.clear();

        // Mapa de grupos.
        if (!mapaResultadosGruposColaboradores.isEmpty()){
            mapaFinalGrupoColaborador.putAll(mapaResultadosGruposColaboradores);
        }
        mapaResultadosGruposColaboradores.clear();

        // Mapa de otros gestores.

        if (!mapaResultadosOtrosGestores.isEmpty()){
            mapaFinalOtrosGestores.putAll(mapaResultadosOtrosGestores);
        }
        mapaResultadosOtrosGestores.clear();

        //Mapa de gestores.
        if (!mapaResultadosContactoGestor.isEmpty()){
            mapaFinalGestores.putAll(mapaResultadosContactoGestor);
        }
        mapaResultadosContactoGestor.clear();

        //Recuperar cargos de los resultados de tipo contactos de empresa
        recuperarCargos(mapaFinalContactos, caso.AccountId);

        Integer numeroRegistros = mapaFinalColaboradores.size()
            + mapaFinalContactos.size()
            + mapaFinalGrupoColaborador.size()
            + mapaFinalGestores.size()
            + mapaFinalOtrosGestores.size();

        resultadoBusqueda.put('RESULTADO', '1');
        resultadoBusqueda.put('DETALLE', '');
        resultadoBusqueda.put('BUSQUEDA_COLABORADORES', mapaFinalColaboradores.values());
        resultadoBusqueda.put('BUSQUEDA_CONTACTOS', mapaFinalContactos.values());
        resultadoBusqueda.put('BUSQUEDA_GRUPOS', mapaFinalGrupoColaborador.values());
        resultadoBusqueda.put('BUSQUEDA_GESTORES', mapaFinalGestores.values());
        resultadoBusqueda.put('BUSQUEDA_OTROSGESTORES', mapaFinalOtrosGestores.values());
        resultadoBusqueda.put('REGISTROS', numeroRegistros);
        return resultadoBusqueda;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getIdentidadBoton(Id caseId) {

        Map<String, BusquedaWrapperEmpresa> mapaResultadosContactoBoton = new Map<String, BusquedaWrapperEmpresa>();
        Map<String, BusquedaWrapperGestor> mapaResultadosGestoresBoton = new Map<String, BusquedaWrapperGestor>();
        List<Id> listadoObjetosEncontrados = new List<Id>();
        Integer labelLimit = Integer.valueOf(Label.SEG_Limite_Busaqueda_Contactos);
        
        Case caso = [SELECT AccountId, SEG_Numero_de_centro__c FROM Case WHERE Id = :caseId];

        List<Account> cuentas = [SELECT  SEG_Empleado_gestor_Segmentos__c, SEG_Prioridad_Carterizacion_Segmentos__c, RecordType.DeveloperName,
                                    SEG_GestorOperativaInternacional__c, SEG_GestorFinEstructurada__c, SEG_GestorOperativaNacional__c, AV_EAPGestor__c
                                    FROM Account WHERE Id = :caso.AccountId];
        if (!cuentas.isEmpty()) {
            Account cuenta = cuentas[0];
            
            String limitRowsValue = SEG_MetodosComunes.recuperarParametrosValor('SEG_BuscadorLimitRows');
            Integer limitRows = 50; //Valor por defecto.
            if (String.isNotBlank(limitRowsValue)) {
                limitRows = Integer.valueOf(limitRowsValue);
            }

            //Lanzar búsqueda de datos
            List<Id> idContactos = new List<Id>();
            for (AccountContactRelation cuentaContactoRel : [SELECT Account.Name, ContactId, Contact.Email, Contact.FirstName, Contact.LastName,
                                                                SEG_Creditos_sindicados__c, SEG_Cargos_en_la_empresa__c,
                                                                SEG_Cargos_Operativa__c, SEG_Reportar_temas_nuevos__c
                                                                FROM AccountContactRelation
                                                                WHERE AccountId = :cuenta.Id
                                                                AND Contact.SEG_Estado__c != 'Inactivo' 
                                                                AND Contact.Email != null 
                                                                LIMIT :labelLimit]) {
                BusquedaWrapperEmpresa resultado = new BusquedaWrapperEmpresa();
                resultado.tipoRegistro = 'contacto';
                resultado.idContacto = cuentaContactoRel.ContactId;
                resultado.nombre = cuentaContactoRel.Contact.FirstName;
                resultado.apellido = cuentaContactoRel.Contact.LastName;
                resultado.empresa = cuentaContactoRel.Account.Name;

                if (cuentaContactoRel.Contact.Email != null) {
                    resultado.email = cuentaContactoRel.Contact.Email;
                }/* else {
                    resultado.email = 'Sin correo';
                }*/

                //Cargos
                List<String> cargos = new List<String>();
                if (String.isNotBlank(cuentaContactoRel.SEG_Creditos_sindicados__c)) {
                    cargos.addAll(cuentaContactoRel.SEG_Creditos_sindicados__c.split(';'));
                }
                if (String.isNotBlank(cuentaContactoRel.SEG_Cargos_en_la_empresa__c)) {
                    cargos.addAll(cuentaContactoRel.SEG_Cargos_en_la_empresa__c.split(';'));
                }
                if (String.isNotBlank(cuentaContactoRel.SEG_Cargos_Operativa__c)) {
                    cargos.addAll(cuentaContactoRel.SEG_Cargos_Operativa__c.split(';'));
                }
                if (String.isNotBlank(cuentaContactoRel.SEG_Reportar_temas_nuevos__c)) {
                    cargos.addAll(cuentaContactoRel.SEG_Reportar_temas_nuevos__c.split(';'));
                }
                
                if (!cargos.isEmpty()) {
                    for (Integer i = 0; i < cargos.size(); i++) {
                        cargos[i] = cargos[i].normalizeSpace();
                    }
                    resultado.cargos = String.join(cargos, '; ');
                } else {
                    resultado.cargos = 'Sin cargos';
                }

                mapaResultadosContactoBoton.put(resultado.idContacto, resultado);
                listadoObjetosEncontrados.add(cuentaContactoRel.Id);
            }

            if (cuenta.SEG_Prioridad_Carterizacion_Segmentos__c) {
                List<Contact> searchListOtros = [SELECT Name,Account.RecordType.DeveloperName,AccountId, Email, FirstName, LastName, CC_Cargo__c, RecordType.DeveloperName
                                                    FROM Contact
                                                    WHERE (Id = :cuenta.SEG_Empleado_gestor_Segmentos__c
                                                    OR Id = :cuenta.SEG_GestorOperativaInternacional__c
                                                    OR id = :cuenta.SEG_GestorFinEstructurada__c
                                                    OR id = :cuenta.SEG_GestorOperativaNacional__c)
                                                    AND Account.RecordType.DeveloperName != 'CC_ClientePA'
                                                    AND Email != null
                                                    LIMIT :labelLimit];

                for (Contact contacto : searchListOtros) {
                    BusquedaWrapperGestor resultado = new BusquedaWrapperGestor();
                    resultado.tipoRegistro = 'contacto';
                    resultado.idContacto = contacto.Id;
                    resultado.nombre = contacto.FirstName;
                    resultado.apellido = contacto.LastName;

                    if (contacto.Email != null) {
                        resultado.email = contacto.Email;
                    } else {
                        resultado.email = 'Sin correos';
                    }
                    if (contacto.Id == cuenta.SEG_Empleado_gestor_Segmentos__c) {
                        resultado.tipoGestor = 'Empleado gestor segmentos';
                    } else if (contacto.Id == cuenta.SEG_GestorOperativaInternacional__c ) {
                        resultado.tipoGestor = 'Gestor operativa internacional';
                    } else if (contacto.Id == cuenta.SEG_GestorFinEstructurada__c) {
                        resultado.tipoGestor = 'Gestor fin estructurada';
                    } else if (contacto.Id == cuenta.SEG_GestorOperativaNacional__c) {
                        resultado.tipoGestor = 'Gestor operativa nacional';
                    }
                    mapaResultadosGestoresBoton.put(resultado.idContacto, resultado);
                    listadoObjetosEncontrados.add(contacto.Id);
                }
            } else if (!cuenta.SEG_Prioridad_Carterizacion_Segmentos__c) {
                List<Contact> searchListOtros = [SELECT Name,Account.RecordType.DeveloperName, AccountId, Email, FirstName, LastName, CC_Cargo__c, RecordType.DeveloperName
                                                    FROM Contact
                                                    WHERE (Id = :cuenta.AV_EAPGestor__c
                                                    OR Id = :cuenta.SEG_GestorOperativaInternacional__c
                                                    OR Id = :cuenta.SEG_GestorFinEstructurada__c
                                                    OR Id = :cuenta.SEG_GestorOperativaNacional__c) 
                                                    AND Account.RecordType.DeveloperName != 'CC_ClientePA'
                                                    AND Email != null
                                                    LIMIT :labelLimit];
                for (Contact contacto : searchListOtros) {
                    BusquedaWrapperGestor resultado = new BusquedaWrapperGestor();
                    resultado.tipoRegistro = 'contacto';
                    resultado.idContacto = contacto.Id;
                    resultado.nombre = contacto.FirstName;
                    resultado.apellido = contacto.LastName;

                    if (contacto.Email != null) {
                        resultado.email = contacto.Email;
                    }/* else {
                        resultado.email = 'Sin correos';
                    }*/

                    if (contacto.Id == cuenta.AV_EAPGestor__c) {
                        resultado.tipoGestor = 'Empleado gestor';
                    } else if (contacto.Id == cuenta.SEG_GestorOperativaInternacional__c ) {
                        resultado.tipoGestor = 'Gestor operativa internacional';
                    } else if (contacto.Id == cuenta.SEG_GestorFinEstructurada__c) {
                        resultado.tipoGestor = 'Gestor fin estructurada';
                    } else if (contacto.Id == cuenta.SEG_GestorOperativaNacional__c) {
                        resultado.tipoGestor = 'Gestor operativa nacional';
                    }
                    mapaResultadosGestoresBoton.put(resultado.idContacto, resultado);
                    listadoObjetosEncontrados.add(contacto.Id);
                }
            }
        }

        // Preparar resultado a devolver.
        Map<String, BusquedaWrapperEmpresa> mapaFinalContactosBoton = new Map<String, BusquedaWrapperEmpresa>();
        Map<String, BusquedaWrapperGestor> mapaFinalGestoresBoton = new Map<String, BusquedaWrapperGestor>();

        // Mapa de contactos
        if (!mapaResultadosContactoBoton.isEmpty()) {
            mapaFinalContactosBoton.putAll(mapaResultadosContactoBoton);
        }
        mapaResultadosContactoBoton.clear();
        //Mapa otros gestores
        if (!mapaResultadosGestoresBoton.isEmpty()) {
            mapaFinalGestoresBoton.putAll(mapaResultadosGestoresBoton);
        }
        mapaResultadosGestoresBoton.clear();

        return new Map<String, Object>{
            'BUSQUEDA_CONTACTOS' => mapaFinalContactosBoton.values(),
            'BUSQUEDA_GESTORES' => mapaFinalGestoresBoton.values(),
            'LIMIT_EXCEEDED' => false,
            'REGISTROS' => mapaFinalContactosBoton.size() + mapaFinalGestoresBoton.size(),
            'RESULTADO' => '1',
            'DETALLE' => ''
        };
    }

    @AuraEnabled(cacheable=true)
    static public ListadoEmailsWrapper getCanalesComunicacion(String caseId, String emails, Boolean noCanales, String idBotonEntrada) {
        List<String> emailsListado = new List<String>();
        List<String> listadoFormateado = new List<String>();
        Set<Id> setContactosFiltrados = new Set<id>();
        List<String> listadoCorrecto = new List<String>();
        List<String> emailsComPara = new List<String>();
        List<String> emailsComCc = new List<String>();
        List<String> emailsComCco = new List<String>();
        List<ListadoEmailsWrapper> listadoFinal = new List<ListadoEmailsWrapper>();
        Set<String> emailsComSet = new Set<String>();
        Set<String> emailsComSetPara = new Set<String>();
        Set<String> emailsComSetCc = new Set<String>();
        Set<String> emailsComSetCco = new Set<String>();

        Case caso = [SELECT AccountId FROM Case WHERE id = :caseId];

        if (!noCanales) {
            if (emails != null) {
                emailsListado.addAll(emails.split(','));
            }
            for (String email : emailsListado) {
                listadoCorrecto.add(email.replaceAll('\\s+', ''));
            }

            List<Contact> contactosRelacionados = [SELECT Name, Email, AccountId, SEG_Estado__c FROM Contact WHERE Email IN :listadoCorrecto];

            if(contactosRelacionados.size() > 1)
            {
                for (Contact contacto : contactosRelacionados) 
                {
                    if(contacto.SEG_Estado__c != 'Inactivo')
                    {
                        setContactosFiltrados.add(contacto.Id); 
                    }
                }
            }
            
            if(setContactosFiltrados.isEmpty())
            {
                for (Contact contacto : contactosRelacionados) 
                {
                    setContactosFiltrados.add(contacto.Id);
                }                
            }
            
            List<CC_Canal_Com__c> canalComunicacion = [SELECT CC_Email__c, SEG_ParaCC__c FROM CC_Canal_Com__c
                                                        WHERE CC_ContactoId__c IN :setContactosFiltrados
                                                        AND (CC_CuentaId__c = NULL OR CC_CuentaId__c = :caso.AccountId)];
            if (!listadoCorrecto.isEmpty()) {
                emailsComSetPara.addAll(listadoCorrecto);
            }

            if (!canalComunicacion.isEmpty()) {
                for (CC_Canal_Com__c canalesCom : canalComunicacion) {
                    if (canalesCom.SEG_ParaCC__c == 'Para') {
                        if (emailsComSetPara.isEmpty()) {
                            emailsComSetPara.add(canalesCom.CC_EMail__c);
                        } else {
                            emailsComSetPara.add(' ' + canalesCom.CC_EMail__c);
                        }
                    }
                }
                for (CC_Canal_Com__c canalesCom : canalComunicacion) {
                    if (canalesCom.SEG_ParaCC__c == 'CC') {
                        if (emailsComSetCc.isEmpty()) {
                            emailsComSetCc.add(canalesCom.CC_EMail__c);
                        } else {
                            emailsComSetCc.add(' ' + canalesCom.CC_EMail__c);
                        }
                    }
                }
                for (CC_Canal_Com__c canalesCom : canalComunicacion) {
                    if (canalesCom.SEG_ParaCC__c == 'CCO') {
                        if (emailsComSetCco.isEmpty()) {
                            emailsComSetCco.add(canalesCom.CC_EMail__c);
                        } else{
                            emailsComSetCco.add(' ' + canalesCom.CC_EMail__c);
                        }
                    }
                }
            }
        } else {
            if (emails != null) {
                emailsListado.addAll(emails.split(','));
            }
            for (String email : emailsListado) {
                listadoCorrecto.add(email.replaceAll('\\s+',''));
            }
            if (!listadoCorrecto.isEmpty() && idBotonEntrada == 'BotonCc') {
                emailsComSetCc.addAll(listadoCorrecto);
            } else if (!listadoCorrecto.isEmpty() && idBotonEntrada == 'BotonCco') {
                emailsComSetCco.addAll(listadoCorrecto);
            }
        }

        if (emailsComSetPara != null) {
            emailsComPara.addAll(emailsComSetPara);
        }
        if (emailsComSetCc != null) {
            emailsComCc.addAll(emailsComSetCc);
        }
        if (emailsComSetCco != null) {
            emailsComCco.addAll(emailsComSetCco);
        }
        ListadoEmailsWrapper listadoAuxiliar = new ListadoEmailsWrapper(emailsComPara,emailsComCc,emailsComCco);
        return listadoAuxiliar;
    }

    private static void recuperarCargos(Map<String, BusquedaWrapperEmpresa> resultadosEmpresa, Id idAccount) {
                
        //Cargos de los contactos relacionados con la empresa
        Set<Id> idContactosEmpresa = new Set<Id>();

        for (AccountContactRelation rel : [SELECT Account.Name, ContactId, SEG_Creditos_sindicados__c, SEG_Cargos_en_la_empresa__c,
                                            SEG_Cargos_Operativa__c, SEG_Reportar_temas_nuevos__c
                                            FROM AccountContactRelation WHERE AccountId = :idAccount AND ContactId IN :resultadosEmpresa.keySet()]) {
            
            idContactosEmpresa.add(rel.ContactId);

            List<String> cargos = new List<String>();
            if (String.isNotBlank(rel.SEG_Creditos_sindicados__c)) {
                cargos.addAll(rel.SEG_Creditos_sindicados__c.split(';'));
            }
            if (String.isNotBlank(rel.SEG_Cargos_en_la_empresa__c)) {
                cargos.addAll(rel.SEG_Cargos_en_la_empresa__c.split(';'));
            }
            if (String.isNotBlank(rel.SEG_Cargos_Operativa__c)) {
                cargos.addAll(rel.SEG_Cargos_Operativa__c.split(';'));
            }
            if (String.isNotBlank(rel.SEG_Reportar_temas_nuevos__c)) {
                cargos.addAll(rel.SEG_Reportar_temas_nuevos__c.split(';'));
            }
            
            if (!cargos.isEmpty()) {
                for (Integer i = 0; i < cargos.size(); i++) {
                    cargos[i] = cargos[i].normalizeSpace();
                }
                resultadosEmpresa.get(rel.ContactId).cargos = String.join(cargos, '; ');
            } else {
                resultadosEmpresa.get(rel.ContactId).cargos = 'Sin cargos';
            }

            resultadosEmpresa.get(rel.ContactId).empresa = rel.Account.Name;
        }

        //Contactos no relacionados con la empresa
        for (Id idContacto : resultadosEmpresa.keySet()) {
            if (!idContactosEmpresa.contains(idContacto)) {
                resultadosEmpresa.get(idContacto).cargos = 'No pertenece a la empresa';
            }
        }
    }

    @AuraEnabled(cacheable=true)
    static public ListadoEmailsWrapper getCanalesComunicacionGrupo(String idGrupo, String idCaso){
        //List<ListadoEmailsWrapper> listadoFinal = new List<ListadoEmailsWrapper>();
        List<String> adresses = new List<String>();
        List<String> adressesCC = new List<String>();
        List<String> adressesCCO = new List<String>();

        List<CC_Grupo_Colaborador_Contact__c> colaboradoresContact = [SELECT Id,CC_Email__c, CC_Para_CC__c,CC_Grupo_Colaborador__c,CC_Contacto__c  FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c =:idGrupo];
        List<Case> caso = [SELECT id, accountId, contactId FROM Case WHERE id =:idCaso];
        String accountId = caso[0].AccountId;

        List<String> contactEmails = new List<String>();
        Map<String,String> idContCase = new map<String,String>();

        for (CC_Grupo_Colaborador_Contact__c colab : colaboradoresContact) {
            if (colab.CC_Para_CC__c == 'Para') {
                contactEmails.add(colab.CC_Contacto__c);
            }
        }
        for (String contacto : contactEmails){
            idContCase.put(contacto, accountId);
        }

        Map<String,Map<String,Set<String>>> destinatariosCorreo = SEG_MetodosComunes.getDestinatariosContactos(idContCase);
        Map<String,Set<String>> contactosDestinoMail = new Map<String,Set<String>>();

        for (String contactoID : contactEmails) {
            if(destinatariosCorreo.containsKey(contactoID)){
                if(!contactosDestinoMail.containsKey('Para')){
                    contactosDestinoMail.put('Para', destinatariosCorreo.get(contactoID).get('Para'));
                }
                else{
                    contactosDestinoMail.get('Para').addall(destinatariosCorreo.get(contactoID).get('Para'));
                }
                if(!contactosDestinoMail.containsKey('CC')){
                    contactosDestinoMail.put('CC', destinatariosCorreo.get(contactoID).get('CC'));
                }
                else{
                    contactosDestinoMail.get('CC').addall(destinatariosCorreo.get(contactoID).get('CC'));
                }
                if(!contactosDestinoMail.containsKey('CCO')){
                    contactosDestinoMail.put('CCO', destinatariosCorreo.get(contactoID).get('CCO'));
                }  
                else{
                    contactosDestinoMail.get('CCO').addall(destinatariosCorreo.get(contactoID).get('CCO'));
                }
            }
        }
        // Calcular las direcciones del para, cc y cco
        if (contactosDestinoMail != null){
            for (String direccion : contactosDestinoMail.get('Para')){
                adresses.add(direccion);
            }
            for (String direccion : contactosDestinoMail.get('CC')){
                adressesCC.add(direccion);
            }
            for (String direccion : contactosDestinoMail.get('CCO')){
                adressesCCO.add(direccion);
            }
        }
        ListadoEmailsWrapper listadoAuxiliar = new ListadoEmailsWrapper(adresses,adressesCC,adressesCCO);
        return listadoAuxiliar;
    }

    @AuraEnabled
	static public Case getInfoCaso(String caseId){
		List<Case> caso = [SELECT Id, SEG_Organizacion__c, SEG_Contactos_SOE_JSON__c, SEG_Contactos_OSN_JSON__c FROM Case WHERE id = :caseId LIMIT 1];
		return caso[0];
	}

    //Método para recoger los contactos SOE u OSN según el botón pulsado por el usuario
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getContactosSOE_OSN(Id caseId, Boolean botonSOE) {
        List<Case> jsonContactos = new List<Case>();
        List<Contact> contactList = new List <Contact>();
        List<BusquedaWrapperGestorOSNSOE> resultadoList = new List<BusquedaWrapperGestorOSNSOE>();
        String valoresContactosFormateados;
        if (botonSOE){
            jsonContactos = [SELECT SEG_Contactos_SOE_JSON__c FROM Case WHERE Id = :caseId];
            valoresContactosFormateados = jsonContactos[0]?.SEG_Contactos_SOE_JSON__c.replace('entityName','CC_Numero_Oficina__c');
            contactList = (List<Contact>)JSON.deserialize(valoresContactosFormateados, List<Contact>.class);
        }else {
            jsonContactos = [SELECT SEG_Contactos_OSN_JSON__c FROM Case WHERE Id = :caseId];
            valoresContactosFormateados = jsonContactos[0]?.SEG_Contactos_OSN_JSON__c.replace('entityName','CC_Numero_Oficina__c');
            contactList = (List<Contact>)JSON.deserialize(valoresContactosFormateados, List<Contact>.class);
        }

        for (Contact contacto : contactList) {
            BusquedaWrapperGestorOSNSOE resultado = new BusquedaWrapperGestorOSNSOE();
            resultado.tipoRegistro = 'contacto';
            resultado.nombre = contacto.name;

            if (contacto.Email != null) {
                resultado.email = contacto.Email;
                resultado.empresa = contacto.CC_Numero_Oficina__c;
            }
            resultadoList.add(resultado);
        }

        return new Map<String, Object>{
            'BUSQUEDA_CONTACTOS' => resultadoList,
            'LIMIT_EXCEEDED' => false,
            'REGISTROS' => contactList.size(),
            'RESULTADO' => '1',
            'DETALLE' => ''
        };

    }


    public class ListadoEmailsWrapper {
        @AuraEnabled
        public List<String> listadoPara {get;set;}
        @AuraEnabled
        public List<String> listadoCc {get;set;}
        @AuraEnabled
        public List<String> listadoCco {get;set;}

        public ListadoEmailsWrapper(List<String> listadoParaWrap, List<String> listadoCcWrap, List<String> listadoCcoWrap) {
            listadoPara = listadoParaWrap;
            listadoCc = listadoCcWrap;
            listadoCco = listadoCcoWrap;
        }
    }

    private class BusquedaWrapperEmpresa {
        @AuraEnabled
        public String tipoRegistro {get;set;}
        @AuraEnabled
        public String idContacto{get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String apellido{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String cargos {get;set;}
        @AuraEnabled
        public String empresa {get;set;}
    }

    private class BusquedaWrapperOtroGestor {
        @AuraEnabled
        public String tipoRegistro {get;set;}
        @AuraEnabled
        public String idContacto{get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String apellido{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String centro{get;set;}
    }

    private class BusquedaWrapperGestor {
        @AuraEnabled
        public String tipoRegistro {get;set;}
        @AuraEnabled
        public String idContacto{get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String apellido{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String tipoGestor {get;set;}
    }

    private class BusquedaWrapperGestorOSNSOE {
        @AuraEnabled
        public String tipoRegistro {get;set;}
        @AuraEnabled
        public String idContacto{get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String apellido{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String tipoGestor {get;set;}
        @AuraEnabled
        public String empresa {get;set;}
    }

    private class BusquedaWrapperColaborador {
        @AuraEnabled
        public String tipoRegistro {get;set;}
        @AuraEnabled
        public String idContacto{get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String apellido{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String grupo{get;set;}
    }

    private class BusquedaWrapperGrupoColaborador {
        @AuraEnabled
        public String tipoRegistro {get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String tipo{get;set;}
        @AuraEnabled
        public String idGrupo{get;set;}
    }
}