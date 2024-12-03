/**
*   @description SEG_BuscadorClientes
*/
public with sharing class SEG_BuscadorClientes {

    /**
    *   @description BusquedaWrapper
    */
    public class BusquedaWrapper
    {
        /**
        *   @description tipoRegistro
        */
        @AuraEnabled
        public String tipoRegistro {get;set;}

        /**
        *   @description idContacto
        */
        @AuraEnabled
        public String idContacto{get;set;}

        /**
        *   @description idCuenta
        */
        @AuraEnabled
        public String idCuenta{get;set;}

        /**
        *   @description idRelacion
        */
        @AuraEnabled
        public String idRelacion{get;set;}

        /**
        *   @description nombre
        */
        @AuraEnabled
        public String nombre{get;set;}

        /**
        *   @description nombreCuenta
        */
        @AuraEnabled
        public String nombreCuenta{get;set;}

        /**
        *   @description cargos
        */
        @AuraEnabled
        public String cargos {get;set;}

        /**
        *   @description email principal del contacto
        */
        @AuraEnabled
        public String emailPrincipal {get;set;}

        /**
        *   @description primer nombre del contacto
        */
        @AuraEnabled
        public String primerNombre {get;set;}
        /**
        *   @description segundo nombre  del contacto
        */
        @AuraEnabled
        public String segundoNombre {get;set;}
    }

    public class infoCasoPermissionSets{
		@AuraEnabled public sObject infoCaso {get; set;}
		@AuraEnabled public Boolean permissionSetSup {get; set;}

		public infoCasoPermissionSets(sObject infoCasoWrapper, Boolean permissionSetSupWrapper){
			infoCaso = infoCasoWrapper;
			permissionSetSup = permissionSetSupWrapper;
		}
	}

    /**
    *   @description Recuperar datos de la entidad origen asociada al buscador.
    *       SEGMENTOS. Devolver el recordType asociado al caso.
    *       Migrada del actual buscador de clientes.
    *       ELB: Añadida restriccion al botón solo para ps Supervisor y Supervisor2
    *   @param recordId -> Identificador del objeto asociado al buscador.
    *   @return -> Datos del objeto asociado al buscador.
    */
    @AuraEnabled
    public static infoCasoPermissionSets datosRegistro(Id recordId) {
        sObject retorno;
        Boolean noEsSupervisor = true;
        if ((recordId).getSObjectType() == Schema.getGlobalDescribe().get('Case')){
            retorno = [SELECT CC_No_Identificado__c, Account.Name, AccountId, ContactId, RecordType.DeveloperName, Status FROM Case WHERE Id = :recordId];
        }
        
        List<String> psApiNames = new List<String> ();
        psApiNames.add('SEG_Supervisor');
        psApiNames.add('SEG_Supervisor2');
        List<PermissionSetAssignment> permisset = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =:Userinfo.getUserId() 
                                                    AND PermissionSet.Name IN: psApiNames];
        

        if(permisset.isEmpty()){
            noEsSupervisor = true;
        }
        else{
            noEsSupervisor = false;
        }

        infoCasoPermissionSets infoCasoYps = new infoCasoPermissionSets(retorno, noEsSupervisor);
        
        return infoCasoYps;
    }



        /**
    *   @description Recuperar parametro de setbackground.
    *   @return -> Parametro para poner en setbackground o deshabilitar la llamada a ALF
    */
    @AuraEnabled
    public static String datosParamALFBackgroundAura() {
        String valorSetBKground = SEG_MetodosComunes.recuperarParametrosValor('SEG_IdentificacionALFBackgroundAura');
        return valorSetBKground;
    }

    /**
    *   @description Recuperar el propietario del caso.
    *       Migrada del actual buscador de clientes.
    *   @param recordId -> Identificador del objeto asociado al buscador.
    *   @return -> True / False para indicar si el usuario es el propietario del caso.
    */
    @AuraEnabled
    public static Boolean getEsPropietarioObjeto(Id recordId)
    {
        Id propietarioRegistro;

        //Comparamos el usuario logado con el propietario del registro y devolvemos si coinciden o no
        if ((recordId).getSObjectType() == Schema.getGlobalDescribe().get('Case'))
        {
            propietarioRegistro = [SELECT OwnerId FROM Case WHERE Id = :recordId].OwnerId;
        }

        return (propietarioRegistro == UserInfo.getUserId());
	}

    /**
    *   @description Búsqueda de cuentas, contactos y canales de comunicación en Salesforce.
    *   @param cuentaPadre -> Identificador de la cuenta a buscar la información de contactos.
    *   @param valorBusqueda -> Valor de búsqueda a realizar.
    *   @param tipoFiltroContacto -> Tipo de filtro a aplicar en los contactos. Actualmente "Cargo".
    *   @param filtroContacto -> Valor a buscar en los contactos.
    *   @return -> Mapa con los clientes y contactos encontrados.
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getIdentidad(String cuentaPadre, String valorBusqueda, String tipoFiltroContacto, String filtroContacto)
    {

        Map<String,Object> resultadoBusqueda = new Map<String,Object>();

        Map<String,BusquedaWrapper> mapaResultadosContacto = new Map<String,BusquedaWrapper>();
        Map<String,BusquedaWrapper> mapaResultadosCuenta = new Map<String,BusquedaWrapper>();
        List<ID> listadoObjetosEncontrados = new List<ID>();

        // Bifurcamos la búsqueda. Contactos de una cuenta o valor a buscar por SOSL.
        if (String.isBlank(cuentaPadre))
        {
            // Búsqueda global.
            if (String.isBlank(valorBusqueda))
            {
                resultadoBusqueda.put('RESULTADO','0');
                resultadoBusqueda.put('DETALLE','Has de informar un criterio de búsqueda.');
                return resultadoBusqueda;
            }else{
                // Quitar caracteres especiales para comprobar la longitud mínima que necesita Salesforce para buscar.
                String regExpChars = '[^A-ZÀ-ȕa-z0-9@\\.\'"]';
                String valorSinEspeciales = valorBusqueda.replaceAll(regExpChars,'');
                if (valorSinEspeciales.length() <= 2)
                {
                    resultadoBusqueda.put('RESULTADO','0');
                    resultadoBusqueda.put('DETALLE','Has de informar más de 2 caracteres para buscar.');
                    return resultadoBusqueda;
                }
            }

            // Añadir wildcard para la búsqueda.
            valorBusqueda = valorBusqueda + '*';

            String limitRowsValue = SEG_MetodosComunes.recuperarParametrosValor('SEG_BuscadorLimitRows');
            Integer limitRows = 50; // Valor por defecto.
            if (String.isNotBlank(limitRowsValue))
            {
                limitRows = Integer.valueOf(limitRowsValue);
            }

            // Lanzar búsqueda de datos.
            // Eliminado Record type cliente particular
            List<List<SObject>> searchList = [FIND :valorBusqueda IN ALL FIELDS 
                                                RETURNING 
                                                Account (Name WHERE RecordType.DeveloperName IN ('CC_Cliente', 'CC_ClienteSEG', 'CC_CentroCaixaBank')), 
                                                Contact (Name, FirstName, LastName, Email WHERE RecordType.DeveloperName IN ('CC_Cliente', 'CC_Representante', 'CC_Empleado') AND SEG_Estado__c != 'Inactivo'),
                                                CC_Canal_Com__c (Name, CC_CuentaId__c, CC_CuentaId__r.Name, CC_ContactoId__c, CC_ContactoId__r.Name, CC_ContactoId__r.FirstName, CC_ContactoId__r.LastName, CC_ContactoId__r.Email)
                                                LIMIT :limitRows];

            for (List<SObject> searchSubList : searchList)
            {
                for (SObject objetoSearch : searchSubList)
                {
                    BusquedaWrapper resultado = new BusquedaWrapper();

                    // Los resultados de la SOSL se devuelven ordenados por la query, el tratamiento si existe se realiza a nivel de Canal de Comunicación.

                    if (objetoSearch.getSObjectType() == Schema.Account.getSObjectType())
                    {
                        // Objeto de tipo cuenta. Preparar el Wrapper.
                        Account cuenta = (Account)objetoSearch;

                        resultado.tipoRegistro = 'cuenta';
                        resultado.idCuenta = cuenta.Id;
                        resultado.idContacto = '';
                        resultado.nombre = cuenta.Name;
                        resultado.nombreCuenta = cuenta.Name;
                        resultado.cargos = '';
                        mapaResultadosCuenta.put(resultado.idCuenta, resultado);

                        // No lanzamos búsqueda relacionada por la cuenta.
                        //listadoObjetosEncontrados.add(cuenta.Id);

                    }else if (objetoSearch.getSObjectType() == Schema.Contact.getSObjectType())
                    {
                        // Nos guardamos los Ids de contactos para buscarlos por las relaciones de contactos y recuperar los cargos.
                        Contact contacto = (Contact)objetoSearch;
                        listadoObjetosEncontrados.add(contacto.Id);

                        // No creamos Wrapper de contacto directo, solo aquellos que estén relacionados con una cuenta.

                    }else if (objetoSearch.getSObjectType() == Schema.CC_Canal_Com__c.getSObjectType())
                    {
                        // Objeto de tipo canal de comunicación.
                        CC_Canal_Com__c canalCom = (CC_Canal_Com__c)objetoSearch;

                        String claveRelacion = (canalCom.CC_CuentaId__c != null) ? String.valueOf(canalCom.CC_CuentaId__c) : '';
                        claveRelacion = claveRelacion + ((canalCom.CC_ContactoId__c != null) ? ((String.isNotBlank(claveRelacion)) ? '##' : '') + String.valueOf(canalCom.CC_ContactoId__c) : '');
                        
                        if (canalCom.CC_ContactoId__c != null && canalCom.CC_CuentaId__c != null && mapaResultadosContacto.get(claveRelacion) == null)
                        {
                            // Creamos un nuevo contacto no identificado por la búsqueda.
                            resultado.tipoRegistro = 'contacto';
                            resultado.idCuenta = (canalCom.CC_CuentaId__c != null) ? String.valueOf(canalCom.CC_CuentaId__c) : '';
                            resultado.nombre = canalCom.CC_ContactoId__r.Name;
                            resultado.nombreCuenta = (canalCom.CC_CuentaId__c != null) ? canalCom.CC_CuentaId__r.Name : '';
                            resultado.idContacto = canalCom.CC_ContactoId__c;
                            resultado.idRelacion = resultado.idCuenta + '##' + resultado.idContacto;
                            resultado.cargos = '';
                            // Eric - US375641 - Contactos- En Gestión poder buscar por Nombre/email
                            resultado.primerNombre = canalCom.CC_ContactoId__r.FirstName;
                            resultado.segundoNombre = canalCom.CC_ContactoId__r.LastName;
                            resultado.emailPrincipal = canalCom.CC_ContactoId__r.Email;

                            mapaResultadosContacto.put(resultado.idCuenta + '##' + resultado.idContacto, resultado);

                            BusquedaWrapper resultadoCuenta = new BusquedaWrapper();
                            resultadoCuenta.tipoRegistro = 'cuenta';
                            resultadoCuenta.idCuenta = canalCom.CC_CuentaId__c;
                            resultadoCuenta.nombre = canalCom.CC_CuentaId__r.Name;
                            resultadoCuenta.nombreCuenta = canalCom.CC_CuentaId__r.Name;
                            resultadoCuenta.idContacto = '';
                            resultadoCuenta.cargos = '';
                            mapaResultadosCuenta.put(resultadoCuenta.idCuenta, resultadoCuenta);

                            listadoObjetosEncontrados.add(canalCom.CC_ContactoId__c);
                            // No lanzamos búsqueda relacionada por la cuenta.
                            /*if (String.isNotBlank(resultado.idCuenta))
                            {
                                listadoObjetosEncontrados.add(resultado.idCuenta);
                            }*/

                        }else if (canalCom.CC_ContactoId__c == null && canalCom.CC_CuentaId__c != null && mapaResultadosCuenta.get(canalCom.CC_CuentaId__c) == null)
                        {
                            // Tratar la cuenta. Recuperar si existe en el mapa de resultados para actualizar información.
                            resultado.tipoRegistro = 'cuenta';
                            resultado.idCuenta = canalCom.CC_CuentaId__c;
                            resultado.nombre = canalCom.CC_CuentaId__r.Name;
                            resultado.nombreCuenta = canalCom.CC_CuentaId__r.Name;
                            resultado.idContacto = '';
                            resultado.cargos = '';
                            mapaResultadosCuenta.put(resultado.idCuenta, resultado);

                            // No lanzamos búsqueda relacionada por la cuenta.
                            //listadoObjetosEncontrados.add(canalCom.CC_CuentaId__c);
                        }else if (canalCom.CC_ContactoId__c != null && canalCom.CC_CuentaId__c == null)
                        {
                            // Dato en contacto directo, preparar búsqueda relación.
                            listadoObjetosEncontrados.add(canalCom.CC_ContactoId__c);
                        }
                    }
                }
            }
        }else{
            // Búsqueda contactos de la cuenta.
            listadoObjetosEncontrados.add(cuentaPadre);
        }

        // Para todos los contactos encontrados, buscar los datos relacionados.
        Map<String,Object> mapaRetornoRelaciones = getClientesContactosRelacionadosSEG(listadoObjetosEncontrados);


        Map<String,BusquedaWrapper> mapaGestores = new Map<String,BusquedaWrapper>();
        if (String.isNotBlank(cuentaPadre))
        {
            // Buscar los gestores de la cuenta.
            mapaGestores = getGestoresCuenta(cuentaPadre);
        }

        // Preparar resultado a devolver.
        Map<String,BusquedaWrapper> mapaFinalCuentas = new Map<String,BusquedaWrapper>();
        Map<String,BusquedaWrapper> mapaFinalContactos = new Map<String,BusquedaWrapper>();

        // Mapa de cuentas
        if (!mapaResultadosCuenta.isEmpty())
        {
            mapaFinalCuentas.putAll(mapaResultadosCuenta);
        }
        mapaResultadosCuenta.clear();

        // Si no hay cuentas encontradas en los criterios de búsqueda, añadir las cuentas padres encontradas por las relaciones.
        if (mapaFinalCuentas.isEmpty())
        {
            mapaResultadosCuenta = (Map<String,BusquedaWrapper>)mapaRetornoRelaciones.get('CUENTAS_ENCONTRADAS');
            mapaFinalCuentas.putAll(mapaResultadosCuenta);
        }

        // Mapa de contactos.
        if (!mapaResultadosContacto.isEmpty())
        {
            mapaFinalContactos.putAll(mapaResultadosContacto);
        }
        mapaResultadosContacto.clear();
        mapaResultadosContacto = (Map<String,BusquedaWrapper>)mapaRetornoRelaciones.get('CONTACTOS_ENCONTRADAS');
        if (!mapaResultadosContacto.isEmpty())
        {
            mapaFinalContactos.putAll(mapaResultadosContacto);
        }


        // Incorporar los gestores.
        if(!mapaGestores.isEmpty())
        {
            mapaFinalContactos.putAll(mapaGestores);
        }

        // Si estamos en una búsqueda de contactos, eliminamos los datos de cuentas relacioandas encontradas.
        if ((String.isNotBlank(tipoFiltroContacto) && String.isNotBlank(filtroContacto)) || String.isNotBlank(cuentaPadre))
        {
            mapaFinalCuentas.clear();
        }

        /*
            Ajustes sobre el resultado.
                -> Filtrar contactos
                -> Ajustar texto de cargos.
        */

        for (String clave : mapaFinalContactos.keySet())
        {
            // Aplicar filtros sobre la búsqueda realizada.
            if (String.isNotBlank(tipoFiltroContacto) && String.isNotBlank(filtroContacto))
            {
                BusquedaWrapper contacto = mapaFinalContactos.get(clave);

                // Filtro por cargo.
                if (tipoFiltroContacto == 'Cargo')
                {
                    if (String.isBlank(contacto.cargos) || !contacto.cargos.containsIgnoreCase(filtroContacto))
                    {
                        mapaFinalContactos.remove(clave);
                    }
                }

                // Filtro por nombre.
                if (tipoFiltroContacto == 'Nombre')
                {
                    if (String.isBlank(contacto.primerNombre) || !contacto.primerNombre.containsIgnoreCase(filtroContacto))
                    {
                        mapaFinalContactos.remove(clave);
                    }
                }

                // Filtro por apellidos.
                if (tipoFiltroContacto == 'Apellido')
                {
                    if (String.isBlank(contacto.segundoNombre) || !contacto.segundoNombre.containsIgnoreCase(filtroContacto))
                    {
                        mapaFinalContactos.remove(clave);
                    }
                }

                // Filtro por email.
                if (tipoFiltroContacto == 'Email')
                {
                    if (String.isBlank(contacto.emailPrincipal) || !contacto.emailPrincipal.containsIgnoreCase(filtroContacto))
                    {
                        mapaFinalContactos.remove(clave);
                    }
                }
                
            }


            // Ajustar visualización de campos.
            if (mapaFinalContactos.containsKey(clave))
            {
                if (String.isNotBlank(mapaFinalContactos.get(clave).cargos))
                {
                    // Acortar la visualización de los cargos.
                    String cargo = mapaFinalContactos.get(clave).cargos;
                    if (cargo.length()>40)
                    {
                        mapaFinalContactos.get(clave).cargos = cargo.left(40) + ' [...]';
                    }
                }else{
                    mapaFinalContactos.get(clave).cargos = 'Contacto sin cargo';
                }
            }
        }


        /*
            Preparar paginación de resultados a mostrar en el Aura.
        */

        resultadoBusqueda = paginarResultados (mapaFinalCuentas, mapaFinalContactos);

        resultadoBusqueda.put('RESULTADO','1');
        resultadoBusqueda.put('DETALLE','');

        return resultadoBusqueda;
    }

    /**
    *   @description Buscar los clientes y contactos relacionados a partir de sus identificadores.
    *   @param listaIdentificadores -> Lista de identificadores a buscar.
    *   @return -> Listado de contactos y cuentas encontrados.
    */
    private static Map<String,Object> getClientesContactosRelacionadosSEG (List<String> listaIdentificadores)
    {
        Map<String,Object> retornoRelacion = new Map<String,Object>();
        Map<String,BusquedaWrapper> mapCuentas = new Map<String,BusquedaWrapper>();
        Map<String,BusquedaWrapper> mapContactos = new Map<String,BusquedaWrapper>();
        
		// Si no hay datos, salir.
        if (listaIdentificadores == null || listaIdentificadores.isEmpty())
        {
            retornoRelacion.put('CUENTAS_ENCONTRADAS', mapCuentas);
            retornoRelacion.put('CONTACTOS_ENCONTRADAS', mapContactos);
            return retornoRelacion;
        }

        // Valores fijos.
        ID rtRepresentantes = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();

        // Buscar la relación de contactos y cuentas.
        for (AccountContactRelation contactoRelacionado : [SELECT AccountId, ContactId, Contact.RecordTypeId, Contact.Name,
                                                            Account.Name, Contact.CC_CuentaRepresentada__r.Name,
                                                            Contact.CC_CargoRepresentante__c, Contact.CC_CuentaRepresentada__c,
                                                            IsDirect, IsActive, SEG_Cargos_Operativa__c, SEG_Cargos_en_la_empresa__c, 
                                                            SEG_Reportar_temas_nuevos__c, SEG_Creditos_sindicados__c, Contact.Email, Roles,
                                                            Contact.RecordType.DeveloperName, Contact.FirstName, Contact.LastName
                                                            FROM AccountContactRelation
                                                            WHERE (AccountId = :listaIdentificadores OR ContactId = :listaIdentificadores) AND IsActive = true
                                                            ORDER BY AccountId, ContactId])
        {
            String claveRelacion = contactoRelacionado.AccountId + '##' + contactoRelacionado.ContactId;

            List<String> cargosContacto = new List<String>();

            BusquedaWrapper datosBusqueda = new BusquedaWrapper();
            datosBusqueda.tipoRegistro = 'contacto';
            datosBusqueda.idCuenta = contactoRelacionado.AccountId;
            datosBusqueda.idContacto = contactoRelacionado.ContactId;
            datosBusqueda.idRelacion = claveRelacion;
            datosBusqueda.nombre = contactoRelacionado.Contact.Name;
            datosBusqueda.nombreCuenta = contactoRelacionado.Account.Name;            
            datosBusqueda.cargos = '';
            datosBusqueda.emailPrincipal = contactoRelacionado.Contact.Email;
            // Eric - US375641 - Contactos- En Gestión poder buscar por Nombre/email
            datosBusqueda.primerNombre = contactoRelacionado.Contact.FirstName;
            datosBusqueda.segundoNombre = contactoRelacionado.Contact.LastName;
            
            if (contactoRelacionado.Contact.RecordTypeId == rtRepresentantes)
            {
                // Representante.
                if (String.isNotBlank(contactoRelacionado.Contact.CC_CargoRepresentante__c))
                {
                    cargosContacto.add(contactoRelacionado.Contact.CC_CargoRepresentante__c);
                }
            }

            // Creamos el cargo 'Empleado' para los contactos de tipo empleado.
            if (contactoRelacionado?.Contact?.RecordType?.DeveloperName == 'CC_Empleado')
            {
                cargosContacto.add('Empleado oficina');
            }

            // Tratar los cargos de la relación.
            if (String.isNotBlank(contactoRelacionado.SEG_Cargos_en_la_empresa__c))
            {
                cargosContacto.add(contactoRelacionado.SEG_Cargos_en_la_empresa__c);
            }

            if (String.isNotBlank(contactoRelacionado.SEG_Cargos_Operativa__c))
            {
                cargosContacto.add(contactoRelacionado.SEG_Cargos_Operativa__c);
            }

            if (String.isNotBlank(contactoRelacionado.SEG_Creditos_sindicados__c))
            {
                cargosContacto.add(contactoRelacionado.SEG_Creditos_sindicados__c);
            }

            if (String.isNotBlank(contactoRelacionado.SEG_Reportar_temas_nuevos__c))
            {
                cargosContacto.add(contactoRelacionado.SEG_Reportar_temas_nuevos__c);
            }

            if (String.isNotBlank(contactoRelacionado.Roles))
            {
                cargosContacto.add(contactoRelacionado.Roles);
            }

            datosBusqueda.cargos = String.join(cargosContacto,';');

            mapContactos.put(claveRelacion, datosBusqueda);

            BusquedaWrapper datosBusquedaCuenta = new BusquedaWrapper();
            datosBusquedaCuenta.tipoRegistro = 'cuenta';
            datosBusquedaCuenta.idCuenta = contactoRelacionado.AccountId;
            datosBusquedaCuenta.idContacto = '';
            datosBusquedaCuenta.nombre = contactoRelacionado.Account.Name;
            datosBusquedaCuenta.nombreCuenta = contactoRelacionado.Account.Name;            
            datosBusquedaCuenta.cargos = '';
            mapCuentas.put(contactoRelacionado.AccountId, datosBusquedaCuenta);
        }

        // Buscar los contactos directos --> Representantes que vienen de ALF.        
        for (Contact representante : [SELECT Id, CC_CuentaRepresentada__c, CC_CuentaRepresentada__r.Name, Name, 
                                        CC_CargoRepresentante__c, AccountId, Account.Name, Email, FirstName, LastName
                                        FROM Contact
                                        WHERE (CC_CuentaRepresentada__c = :listaIdentificadores OR AccountId = :listaIdentificadores OR Id = :listaIdentificadores)
                                        AND RecordTypeId = :rtRepresentantes])
        {
            if (representante.CC_CuentaRepresentada__c != null || representante.AccountId != null)
            {
                String claveRelacion = (representante.CC_CuentaRepresentada__c != null) ? representante.CC_CuentaRepresentada__c : representante.AccountId;
                claveRelacion = claveRelacion + representante.Id;

                BusquedaWrapper datosBusqueda;
                if (mapContactos.get(claveRelacion) != null)
                {
                    datosBusqueda = mapContactos.get(claveRelacion);
                }else{
                    datosBusqueda = new BusquedaWrapper();
                }

                // Datos comunes.
                datosBusqueda.tipoRegistro = 'contacto';
                datosBusqueda.idCuenta = (representante.CC_CuentaRepresentada__c != null) ? representante.CC_CuentaRepresentada__c : representante.AccountId;
                datosBusqueda.idContacto = representante.Id;
                datosBusqueda.idRelacion = claveRelacion;
                datosBusqueda.nombre = representante.Name;
                datosBusqueda.nombreCuenta = (representante.CC_CuentaRepresentada__c != null) ? representante.CC_CuentaRepresentada__r.Name : representante.Account.Name;
                datosBusqueda.cargos = '';
                datosBusqueda.emailPrincipal = representante.Email;
                // Eric - US375641 - Contactos- En Gestión poder buscar por Nombre/email
                datosBusqueda.primerNombre = representante.FirstName;
                datosBusqueda.segundoNombre = representante.LastName;
                
                if (String.isNotBlank(representante.CC_CargoRepresentante__c))
                {
                    if (String.isNotBlank(datosBusqueda.cargos))
                    {
                        datosBusqueda.cargos = representante.CC_CargoRepresentante__c + ';' + datosBusqueda.cargos;
                    }else{
                        datosBusqueda.cargos = representante.CC_CargoRepresentante__c;
                    }
                }
    
                mapContactos.put(claveRelacion, datosBusqueda);


                BusquedaWrapper datosBusquedaCuenta = new BusquedaWrapper();
                datosBusquedaCuenta.tipoRegistro = 'cuenta';
                datosBusquedaCuenta.idCuenta = (representante.CC_CuentaRepresentada__c != null) ? representante.CC_CuentaRepresentada__c : representante.AccountId;
                datosBusquedaCuenta.idContacto = '';
                datosBusquedaCuenta.nombre = (representante.CC_CuentaRepresentada__c != null) ? representante.CC_CuentaRepresentada__r.Name : representante.Account.Name;
                datosBusquedaCuenta.nombreCuenta = (representante.CC_CuentaRepresentada__c != null) ? representante.CC_CuentaRepresentada__r.Name : representante.Account.Name;
                datosBusquedaCuenta.cargos = '';
                mapCuentas.put(datosBusquedaCuenta.idCuenta, datosBusquedaCuenta);
            }
        }

        // Preparar salida.
        retornoRelacion.put('CUENTAS_ENCONTRADAS', mapCuentas);
        retornoRelacion.put('CONTACTOS_ENCONTRADAS', mapContactos);


        return retornoRelacion;
    }

    /**
     * @description Buscar los gestores de la cuenta que está seleccionada.
     * @param cuentaPadre Identificador de la cuenta
     * @return Listado de gestores encontrados.
     */
    private static Map<String,BusquedaWrapper> getGestoresCuenta (String cuentaPadre)
    {
        Map<String,BusquedaWrapper> mapaGestores = new Map<String,BusquedaWrapper>();

        if (String.isNotBlank(cuentaPadre))
        {
            List<Account> listadoCuentas = [SELECT Id, Name, SEG_Empleado_gestor_Segmentos__c, SEG_GestorFinEstructurada__c, SEG_GestorOperativaInternacional__c, SEG_GestorOperativaNacional__c,AV_EAPGestor__c, SEG_Prioridad_Carterizacion_Segmentos__c 
                                            FROM Account WHERE Id = :cuentaPadre];
            if (!listadoCuentas.isEmpty())
            {
                ID empleadoGestorId;
                Account cuenta = listadoCuentas[0];
                Boolean priorizacionSegmentos = (cuenta.SEG_Prioridad_Carterizacion_Segmentos__c != null) ? cuenta.SEG_Prioridad_Carterizacion_Segmentos__c : false;
                
                empleadoGestorId = (priorizacionSegmentos) ? cuenta.SEG_Empleado_gestor_Segmentos__c : null;
                empleadoGestorId = (empleadoGestorId == null) ? cuenta.AV_EAPGestor__c : empleadoGestorId;

                Set<Id> gestoresBusqueda = new Set<Id>();
                if (empleadoGestorId != null)
                {
                    gestoresBusqueda.add(empleadoGestorId);
                }
                if (cuenta.SEG_GestorFinEstructurada__c != null)
                {
                    gestoresBusqueda.add(cuenta.SEG_GestorFinEstructurada__c);
                }
                if (cuenta.SEG_GestorOperativaInternacional__c != null)
                {
                    gestoresBusqueda.add(cuenta.SEG_GestorOperativaInternacional__c);
                }
                if (cuenta.SEG_GestorOperativaNacional__c != null)
                {
                    gestoresBusqueda.add(cuenta.SEG_GestorOperativaNacional__c);
                }

                for (Contact gestor : [SELECT Id, Name, Email FROM Contact WHERE Id IN :gestoresBusqueda])
                {
                    String claveRelacion = cuentaPadre + '##' + gestor.Id;
                    String cargos = '';

                    // Calcular los cargos.
                    cargos = ((gestor.Id == empleadoGestorId) ? (cargos + ((String.isNotBlank(cargos))?',':'') + ' Cliente') : cargos);
                    cargos = ((gestor.Id == cuenta.SEG_GestorOperativaNacional__c) ? (cargos + ((String.isNotBlank(cargos))?',':'') + ' Nacional') : cargos);
                    cargos = ((gestor.Id == cuenta.SEG_GestorOperativaInternacional__c) ? (cargos + ((String.isNotBlank(cargos))?',':'') + ' Internacional') : cargos);
                    cargos = ((gestor.Id == cuenta.SEG_GestorFinEstructurada__c) ? (cargos + ((String.isNotBlank(cargos))?',':'') + ' Fin. estructurada') : cargos);
                    cargos = 'Gestor: ' + cargos;

                    BusquedaWrapper datosBusqueda = new BusquedaWrapper();
                    datosBusqueda.tipoRegistro = 'contacto';
                    datosBusqueda.idCuenta = cuentaPadre;
                    datosBusqueda.idContacto = gestor.Id;
                    datosBusqueda.idRelacion = claveRelacion;
                    datosBusqueda.nombre = gestor.Name;
                    datosBusqueda.nombreCuenta = 'GESTOR';            
                    datosBusqueda.cargos = cargos;
                    datosBusqueda.emailPrincipal = gestor.Email;

                    mapaGestores.put(claveRelacion, datosBusqueda);
                }
            }
        }

        return mapaGestores;
    }

    /**
    *   @description Paginar los resultados de cuentas y contactos.
    *   @param mapaFinalCuentas -> Mapa con las cuentas a paginar
    *   @param mapaFinalContactos -> Mapa con los contactos a paginar
    *   @return -> Mapa de contactos y cuentas paginados.
    */
    private static Map<String,Object> paginarResultados (Map<String,BusquedaWrapper> mapaFinalCuentas, Map<String,BusquedaWrapper> mapaFinalContactos)
    {
        Map<String,Object> resultadoBusqueda = new Map<String,Object>();

        /*
            Preparar paginación de resultados a mostrar en el Aura.
        */
        Integer pageSize = 10; // Valor por defecto.
        Integer limitRows = 50; // Valor por defecto.

        String sizePageValue = SEG_MetodosComunes.recuperarParametrosValor('SEG_BuscadorPageSize');
        String limitRowsValue = SEG_MetodosComunes.recuperarParametrosValor('SEG_BuscadorLimitRows');

        if (String.isNotBlank(sizePageValue))
        {
            pageSize = Integer.valueOf(sizePageValue);
        }

        if (String.isNotBlank(limitRowsValue))
        {
            limitRows = Integer.valueOf(limitRowsValue);
        }

        Boolean limiteRowsExcedido = false;
        Integer totalRegistros = 0;
        Integer pagina = 1;
        Integer numRegPagina = 1;
        
        // Tratar las cuentas resultantes.
        for (String claveDatos : mapaFinalCuentas.keySet())
        {
            totalRegistros = totalRegistros + 1;
            if (totalRegistros > limitRows)
            {
                limiteRowsExcedido = true;
                break;
            }

            List<BusquedaWrapper> datosPagina; 

            if (resultadoBusqueda.get('BUSQUEDA_CUENTAS_' + String.valueOf(pagina)) == null)
            {
                datosPagina = new List<BusquedaWrapper>();
            }else{
                if (numRegPagina > pageSize)
                {
                    pagina = pagina + 1;
                    numRegPagina = 1;
                    datosPagina = new List<BusquedaWrapper>();
                }else{
                    datosPagina = (List<BusquedaWrapper>)resultadoBusqueda.get('BUSQUEDA_CUENTAS_' + String.valueOf(pagina));
                }
            }

            datosPagina.add(mapaFinalCuentas.get(claveDatos));
            resultadoBusqueda.put('BUSQUEDA_CUENTAS_' + String.valueOf(pagina), datosPagina);
            numRegPagina = numRegPagina + 1;            
        }

        // Preparar salto de página si hay registros de contactos.
        if (numRegPagina > pageSize && !mapaFinalContactos.isEmpty())
        {
            pagina = pagina + 1;
            numRegPagina = 1;
        }
        
        Map<String,BusquedaWrapper> mapaFinalContactosConEmail = new Map<String,BusquedaWrapper>();
        Map<String,BusquedaWrapper> mapaFinalContactosSinEmail = new Map<String,BusquedaWrapper>();
        Map<String,BusquedaWrapper> mapaFinalContactosOrdenados = new Map<String,BusquedaWrapper>();

        for (String claveDatos : mapaFinalContactos.keySet()){
            if(mapaFinalContactos.get(claveDatos).emailPrincipal != null){
                mapaFinalContactosConEmail.put(claveDatos, mapaFinalContactos.get(claveDatos));
            }else{
                mapaFinalContactosSinEmail.put(claveDatos, mapaFinalContactos.get(claveDatos));
            }
        }
        mapaFinalContactosOrdenados = mapaFinalContactosConEmail;
        mapaFinalContactosOrdenados.putAll(mapaFinalContactosSinEmail);

        // Tratar los contactos resultantes.
        for (String claveDatos : mapaFinalContactosOrdenados.keySet())
        {
            totalRegistros = totalRegistros + 1;
            if (totalRegistros > limitRows)
            {
                limiteRowsExcedido = true;
                break;
            }

            List<BusquedaWrapper> datosPagina; 

            if (resultadoBusqueda.get('BUSQUEDA_CONTACTOS_' + String.valueOf(pagina)) == null)
            {
                datosPagina = new List<BusquedaWrapper>();
            }else{
                if (numRegPagina > pageSize)
                {
                    pagina = pagina + 1;
                    numRegPagina = 1;
                    datosPagina = new List<BusquedaWrapper>();
                }else{
                    datosPagina = (List<BusquedaWrapper>)resultadoBusqueda.get('BUSQUEDA_CONTACTOS_' + String.valueOf(pagina));
                }
            }

            datosPagina.add(mapaFinalContactosOrdenados.get(claveDatos));
            resultadoBusqueda.put('BUSQUEDA_CONTACTOS_' + String.valueOf(pagina), datosPagina);
            numRegPagina = numRegPagina + 1;            
        }

        resultadoBusqueda.put('LIMIT_EXCEEDED', limiteRowsExcedido);
        resultadoBusqueda.put('REGISTROS', totalRegistros);
        resultadoBusqueda.put('TOTAL_PAGINAS',pagina);

        return resultadoBusqueda;
    }

    /**
    *   @description Función para actualizar el caso. Casuistica no se identifica.
    *                   Migrada del actual buscador de clientes.
    *   @param recordId -> Identificador del caso
    *   @param noIdentificado -> Valor de la marca de identificación del caso.
    *   @param tipoRegistro -> Tipo de objeto. Uso futuro.
    */
    @AuraEnabled
    public static void actualizarIdentificacion(Id recordId, Boolean noIdentificado, String tipoRegistro)
    {
        if (tipoRegistro == 'Case') {
            Case caso = new Case(Id = recordId);
            caso.CC_No_Identificado__c = noIdentificado;
            if (noIdentificado) {
                caso.AccountId = null;
                caso.ContactId = null;
                caso.CC_Representante__c = null;
                caso.CC_IdentCliente__c = '0'; // Sin datos ALF
            }
            update caso;
        }
    }

    /**
    *   @description Actualizar los datos del caso asociado (Cliente o Contacto).
    *       SEGMENTOS. No actualizar el contactId si la cuenta sólo tiene un contacto asociado.
    *       Migrada del actual buscador de clientes.
    *   @param clienteId -> Identificador de cuenta
    *   @param contactoId -> Identificador de contacto
    *   @param casoId -> Identificador de caso
    *   @return -> Detalle del proceso de actualización.
    */
    @AuraEnabled
    public static String setClienteContactoCaso(String clienteId, String contactoId, String casoId)
    {
        Map<String, Object> oRes = new Map<String, Object>();
        
        // Si no hay datos, salir.
        if (String.isBlank(clienteId)) {
            return 'No se ha seleccionado un registro válido';
        }
        
        if (String.isBlank(casoId)) {
            return 'No hay un caso vinculado';
        }
        
        // Actualizamos el caso con los datos facilitados por el usuario.
        Case oCaseUpd = new Case(Id = casoId);
            
        if (String.isNotBlank(contactoId)) {
            oCaseUpd.ContactId = contactoId;
        } else {
            oCaseUpd.ContactId = null;
        }
        
        if (String.isNotBlank(clienteId)) {
            oCaseUpd.AccountId = clienteId;
        }
        
        /*if (oCaseUpd.AccountId == null && oCaseUpd.ContactId == null) {
            oCaseUpd.CC_No_Identificado__c = true;
            oCaseUpd.CC_IdentCliente__c = '0'; // Sin datos ALF
        } else {*/
        
        oCaseUpd.CC_No_Identificado__c = false;
        oCaseUpd.CC_IdentCliente__c = '2'; // Alfabetico manual
        //}
        update oCaseUpd;
        
        return '';
    }

    /**
    *   @description Actualizar los datos del cliente con los datos de Alfabético
    *   @param clienteId -> Identificador de cuenta
    *   @return -> Detalle del proceso de actualización.
    */
    @AuraEnabled
    public static Map<String,String> actualizarClienteAlfabetico(String clienteId)
    {
        Map<String,String> resultado = new Map<String,String>();
        Map<String, Object> oRes = new Map<String, Object>();
        
        // Si no hay datos, salir.
        if (String.isBlank(clienteId)) {
            resultado.put('error','10');
            resultado.put('errorUser','No se ha seleccionado un registro válido.');
            resultado.put('errorDetail','');
            return resultado;
        }
        
        // Actualizar los datos del cliente seleccionado en el buscador.
        resultado = SEG_wsDatosClienteALF.updateCustomerDataALF(clienteId);
        
        return resultado;
    }
}