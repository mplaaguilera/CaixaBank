public with sharing class CC_MetodosUtiles {

    //Crear función para recuperar los valores del custom setting CC_Settings
    public static CC_Settings__c getCustomSetting(String name){
        CC_Settings__c mcs = new CC_Settings__c();

        mcs = [SELECT Id, Name, CC_Configuracion_1__c, CC_Configuracion_2__c, CC_Configuracion_3__c, 
                CC_Configuracion_4__c,CC_Configuracion_5__c, CC_Descripcion__c
                FROM CC_Settings__c
                WHERE Name = :name];

        return mcs;
    }

    //Método para recuperar valores configurados en META
    public static Map<String, Object> getLOVMeta(List<String> oListaOrig) {
        Map<String, Object> oData = new Map<String, Object>();
        for (CC_Valores__mdt oVal : [SELECT CC_Activa__c, CC_Valor__c, CC_Valor_SFDC__c, CC_Lista__c
                                        FROM CC_Valores__mdt WHERE CC_Lista__c IN :oListaOrig AND CC_Activa__c = true]) {
            if (oData.get(oVal.CC_Lista__c) == null) {
                Map<String, String> oMap = new Map<String, String>();
                oData.put(oVal.CC_Lista__c, oMap);
            }
            ((Map<String, String>)oData.get(oVal.CC_Lista__c)).put(oVal.CC_Valor__c, oVal.CC_Valor_SFDC__c);
        }
        return oData;
    }    

    //Método para recuperar un valor SFDC configurado en META de una LOV
    public static String getValueLOVMeta(String sLista, String sValor) {
        String sValorSFDC = '';
        if (sLista != '' && sValor != '') {
            List<CC_Valores__mdt> oLOV = [SELECT CC_Activa__c, CC_Valor_SFDC__c FROM CC_Valores__mdt WHERE CC_Lista__c = :sLista AND CC_Valor__c = :sValor AND CC_Activa__c = true];
            for (CC_Valores__mdt oVal : oLOV) {
                // Nos quedamos con el primer valor encontrado.
                if (oVal.CC_Valor_SFDC__c != '') {
                    sValorSFDC = oVal.CC_Valor_SFDC__c;
                    break;
                }
            }
        }
        return sValorSFDC;
    }

    //Método para recuperar un valor destino configurado en META de una LOV
    static public String getDestValueLOVMeta (String sLista, String sValorSFDC) {
        String sValor = '';

        if (sLista != '' && sValorSFDC != '')
        {
            List<CC_Valores__mdt> oLOV = [SELECT Id, CC_Activa__c, CC_Valor__c FROM CC_Valores__mdt WHERE CC_Lista__c = :sLista AND CC_Valor_SFDC__c = :sValorSFDC AND CC_Activa__c = true];
            for (CC_Valores__mdt oVal : oLOV)
            {
                // Nos quedamos con el primer valor encontrado.
                if (oVal.CC_Valor__c != '')
                {
                    sValor = oVal.CC_Valor__c;
                    break;
                }
            }
        }

        return sValor;
    }

    /*
        Método para recuperar valores configurados en LOV.
    */
    public static Map<String, Object> getLOV(List<String> oListaOrig) {
        Map<String, Object> oData = new Map<String, Object>();

        if (oListaOrig == null || oListaOrig.isEmpty()) {
            return oData;
        }
        List<CC_Lista_Valores__c> oLista = [SELECT Id, Name, RecordTypeId, CC_Activa__c, CC_Valor__c, CC_Valor_SFDC__c, CC_Lista__r.Name
                            FROM CC_Lista_Valores__c
                            WHERE CC_Lista__r.Name IN :oListaOrig AND CC_Activa__c = true];

        for (CC_Lista_Valores__c oVal : oLista)
        {
            if (oData.get(oVal.CC_Lista__r.Name) == null)
            {
                Map<String,String> oMap = new Map<String,String>();
                oData.put(oVal.CC_Lista__r.Name, oMap);
            }
            ((Map<String,String>)oData.get(oVal.CC_Lista__r.Name)).put(oVal.Name, oVal.CC_Valor_SFDC__c);


        }

        return oData;
    }

    // Método para recuperar valores de la LoV devolviendo un mapa con el value dinámico.
    public static Map<String, Object> getLOVNameValue(List<String> oListaName, String fieldToMap) {
        Map<String, Object> oData = new Map<String, Object>();

        if (oListaName == null || oListaName.isEmpty() || String.isBlank(fieldToMap)) {
            return oData;
        }

        // Construir la consulta SOQL dinámica
        String query = 'SELECT Name, ' + fieldToMap + ' FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name IN :oListaNames AND CC_Activa__c = true';
        Map<String, Object> bindParams = new Map<String, Object>{
            'oListaNames' => oListaName
        };

        // Ejecutar la consulta utilizando Database.queryWithBinds con accessLevel
        List<SObject> results = Database.queryWithBinds(query, bindParams, AccessLevel.SYSTEM_MODE);

        for (SObject record : results) {
            String name = (String)record.get('Name');
            Object value = record.get(fieldToMap);
            oData.put(name, value);
        }

        return oData;
    }

    /*
        Método para recuperar valores configurados en LOV y Determinados valores de ella.
    */
    static public Map<String, Object> getLOVWithVal(Set<String> oListaOrig, Set<String> oValoresOrig) {
        Map<String, Object> oData = new Map<String, Object>();

        if (oListaOrig == null || oValoresOrig == null) {
            return oData;
        }

        if (oListaOrig.isEmpty() || oValoresOrig.isEmpty()) {
            return oData;
        }

        List<CC_Lista_Valores__c> oLista = [SELECT Name, RecordTypeId, CC_Activa__c, CC_Valor__c, CC_Valor_SFDC__c, CC_Lista__r.Name
                                            FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name IN :oListaOrig AND Name IN :oValoresOrig AND CC_Activa__c = true];

        for (CC_Lista_Valores__c oVal : oLista) {
            if (oData.get(oVal.CC_Lista__r.Name) == null) {
                Map<String, String> oMap = new Map<String, String>();
                oData.put(oVal.CC_Lista__r.Name, oMap);
            }
            ((Map<String, String>)oData.get(oVal.CC_Lista__r.Name)).put(oVal.Name, oVal.CC_Valor_SFDC__c);
        }

        return oData;
    }

    /*
        Recuperar configuración integración.
    */
    static public CC_InterfaceSettings__mdt getInterfazConfig(String sInterfaz) {
        CC_InterfaceSettings__mdt oInterfaz;

        List<CC_InterfaceSettings__mdt> oConfig = [SELECT CC_Certificado__c, CC_EndPoint__c, CC_TimeOut__c, CC_TipoPeticion__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c, CC_ContentType__c
                                                    FROM CC_InterfaceSettings__mdt
                                                    WHERE DeveloperName = :sInterfaz AND CC_Activa__c = TRUE];
        if (!oConfig.isEmpty()) {
            return oConfig[0];
        } else {
            return oInterfaz;
        }
    }

    /*
        Recuperar configuración integración con Body petición.
    */
    static public CC_InterfaceSettings__mdt getInterfazConfigBody(String sInterfaz) {
        List<CC_InterfaceSettings__mdt> oConfig = [SELECT CC_Certificado__c, CC_EndPoint__c, CC_TimeOut__c, CC_TipoPeticion__c, CC_CharSet__c, CC_ContentType__c, CC_HttpRequest__c, CC_SoapAction__c, CC_Body__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c, CC_ALF_CliConf__c, CC_CliConfiErr__c FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz AND CC_Activa__c = true];
        if (!oConfig.isEmpty() && oConfig[0] != null) {
            return oConfig[0];
        } else {
            return null;
        }
    }

    /*
        Recuperar configuración de las notificaciones de seguimiento para un determinado canal.
    */
    static public List<CC_ConfigNotifCliente__mdt> getNotificacionesConfig (String sProceso, String sCanal) {
        List<CC_ConfigNotifCliente__mdt> oConfig;

        if (sProceso != '' && sCanal != '') {
            oConfig = [SELECT CC_OrigenCasoNotificacion__c, CC_ProcedenciaOrigenNotificacion__c, CC_Idioma__c, CC_Cuerpo__c,
                        CC_EtiRemitente__c, CC_Remitente__c, CC_Plantilla__c, CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c,
                        CC_TaskOrigenProc__c, CC_TiposTareaCaso__c, CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c,
                        CC_Tipo_Cliente__c
                        FROM CC_ConfigNotifCliente__mdt
                        WHERE CC_Proceso__c = :sProceso AND CC_Canal__c = :sCanal AND CC_Activa__c = true];

            if (Test.isRunningTest()) {
                oConfig = [SELECT CC_OrigenCasoNotificacion__c, CC_Idioma__c, CC_Cuerpo__c, CC_EtiRemitente__c, CC_Remitente__c,
                            CC_Plantilla__c, CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c, CC_TaskOrigenProc__c, CC_TiposTareaCaso__c,
                            CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c, CC_ProcedenciaOrigenNotificacion__c,
                            CC_Tipo_Cliente__c
                            FROM CC_ConfigNotifCliente__mdt
                            WHERE CC_Proceso__c = :sProceso AND CC_Canal__c = :sCanal LIMIT 1];
            }
        }

        if (sProceso != '' && sCanal == '') {
            oConfig = [SELECT CC_OrigenCasoNotificacion__c, CC_ProcedenciaOrigenNotificacion__c, CC_Idioma__c, CC_Cuerpo__c,
                        CC_EtiRemitente__c, CC_Remitente__c, CC_Plantilla__c, CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c,
                        CC_TaskOrigenProc__c, CC_TiposTareaCaso__c, CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c,
                        CC_Tipo_Cliente__c
                        FROM CC_ConfigNotifCliente__mdt
                        WHERE DeveloperName = :sProceso AND CC_Proceso__c = :sProceso AND CC_Activa__c = true];

            if (Test.isRunningTest()) {
                oConfig = [SELECT CC_Idioma__c, CC_Cuerpo__c, CC_EtiRemitente__c, CC_Remitente__c, CC_Plantilla__c,
                            CC_PlantillaBase__c, CC_Carpeta__c, CC_Proceso__c, CC_TaskOrigenProc__c, CC_TiposTareaCaso__c,
                            CC_CaseOrigenProc__c, CC_EntidadOrigen__c, CC_EstadoTarea__c, CC_ProcedenciaOrigenNotificacion__c,
                            CC_Tipo_Cliente__c
                            FROM CC_ConfigNotifCliente__mdt
                            WHERE DeveloperName = :sProceso AND CC_Proceso__c = :sProceso LIMIT 1];
            }
        }
        return oConfig;
    }

    // Devuelve los record types de un objeto en forma de mapa recordTypeId-recordTypeName (excluyendo el record type 'master')
    public static Map<Id, String> mapaRecordTypes;
    public static Map<Id, String> obtenerRecordTypes(String nombreObjeto) {

        List<Schema.RecordTypeInfo> recordTypes = Schema.getGlobalDescribe().get(nombreObjeto).getDescribe().getRecordTypeInfos();
        mapaRecordTypes = new Map<Id, String>();
        for (RecordTypeInfo rt : recordTypes) {
            if (rt.getName() != 'Master' && rt.getName() != 'Principal' && rt.getName().trim() != '') {
                mapaRecordTypes.put(rt.getRecordTypeId(), rt.getName());
            }
        }
        return mapaRecordTypes;
    }

    //Devuelve un subconjunto de items de la lista
    public static List<Object> subLista(List<Object> lista, Integer inicio, Integer largo) {
        List<Object> retorno = lista.clone();

        //Quitar los elementos previos al elemento inicial
        for (Integer i = 0; i < inicio; i++) {
            retorno.remove(0);
        }
        //Quitar los elementos posteriores al elemento final
        while (retorno.size() > largo) {
            retorno.remove(retorno.size() - 1);
        }
        return retorno;
    }

    public static String getRecordTypeIdFromDeveloperName(String sObjectName, String rtDeveloperName) {
        if (sObjectName == 'Case') {
            return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'Opportunity') {
            return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'Task') {
            return Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'Event') {
            return Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'Account') {
            return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'Contact') {
            return Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'CC_Llamada__c') {
            return Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'CC_Lista_Valores__c') {
            return Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'CC_Comunicaciones__c') {
            return Schema.SObjectType.CC_Comunicaciones__c.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else if (sObjectName == 'CC_Agrupador__c') {
            return Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        } else {
            return Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
        }
    }

    public static String getRecordTypeNameFromDeveloperName(String objeto, String recordTypeDeveloperName) {
        //Devuelve el id del record type indicado. En caso de no encontrarlo devuelve null
        try {
            return Schema.getGlobalDescribe().get(objeto).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getName();
        } catch(Exception e) {
            return null;
        }
    }

    public static String getRecordTypeDeveloperNameFromId(String objeto, Id recordTypeId) {
        try {
            return Schema.getGlobalDescribe().get(objeto).getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
        } catch(Exception e) {
            return null;
        }
    }

    public static String getRecordTypeNameFromId(String objeto, Id recordTypeId) {
        //Devuelve el id del record type indicado. En caso de no encontrarlo devuelve null
        try {
            return Schema.getGlobalDescribe().get(objeto).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        } catch(Exception e) {
            return null;
        }
    }

    //Método para recuperar valores configurados en LOV y Determinados valores de ella
    public static Map<String, String> getLOVSimpleMethod(String lovName, String valorName) {
        Map<String, String> oData = new Map<String, String>();
        if (lovName == null || valorName == null) {
            return oData;
        }
        if (lovName == '' || valorName == '') {
            return oData;
        }
        List<CC_Lista_Valores__c> oLista = [SELECT Name, RecordTypeId, CC_Activa__c, CC_Valor__c, CC_Valor_SFDC__c, CC_Lista__r.Name
                                            FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = :lovName AND Name = :valorName AND CC_Activa__c = true];

        for (CC_Lista_Valores__c oVal : oLista) {
            oData.put(oVal.Name, oVal.CC_Valor_SFDC__c);
        }
        return oData;
    }

    //Funciones para realizar una encriptacion en Hexadecimal
    public static Decimal modulus(Decimal dividend, Decimal divisor) {
        Decimal d = dividend.divide(divisor, 0, RoundingMode.FLOOR);
        return dividend - (d * divisor);
    }

    public static String decimalToHex(Decimal d) {
        String hex = '';
        while (d > 0) {
            Decimal digit = modulus(d, 16); // rightmost digit
            String digits = '0123456789abcdef';
            hex = digits.substring(digit.intValue(), digit.intValue() + 1) + hex; // string concatenation
            d = d.divide(16, 0, RoundingMode.FLOOR);
        }
        return hex;
    }

    public static Boolean modificadorApex(String nombreModificadorApex) {
        List<CC_Modificador_Apex__mdt> modificadoresApex = [SELECT CC_Activo__c FROM CC_Modificador_Apex__mdt
                                                            WHERE DeveloperName = :nombreModificadorApex LIMIT 1];
        return !modificadoresApex.isEmpty() && modificadoresApex[0].CC_Activo__c;
    }

    /*
     * Función para calcular fin de plazo/fecha límite teniendo en cuenta fines de semana y festivos (metadata)
     */
    public static Datetime fechaLimiteFinSemanaFestivos(String limiteSLA, Datetime fechaInicio) {
        BusinessHours diasLaborables = [SELECT Id FROM BusinessHours WHERE name='CC_Empleados'];
        CC_Festivos_Estatales__mdt[] listaFestivosEstatales = [SELECT CC_Anyo__c, CC_Dia__c, CC_Mes__c FROM CC_Festivos_Estatales__mdt];

        //Empezamos por la fecha de inicio y vamos sumando
        Datetime result = fechaInicio;

		Integer diasPlazo = Integer.valueOf(limiteSLA);
        Boolean esJornadaLaboral;
        Boolean esVacaciones;
        while (diasPlazo > 0) {
            result = result.addDays(1);
            esJornadaLaboral = BusinessHours.isWithin(diasLaborables.id, result);

            esVacaciones = false;
            for (CC_Festivos_Estatales__mdt festivoEstatal : listaFestivosEstatales) {
                Date festivo = Date.newInstance(Integer.valueOf(festivoEstatal.CC_Anyo__c), Integer.valueOf(festivoEstatal.CC_Mes__c), Integer.valueOf(festivoEstatal.CC_Dia__c));
                if (result.date() == festivo) {
                    esVacaciones = true;
                    break;
                }
            }

            if (esJornadaLaboral && !esVacaciones) {
                --diasPlazo;
            }
        }
        return result;
    }

    // Función auxiliar sin tener que pedir el día por parámetro
    public static Datetime fechaLimiteFinSemanaFestivos (String limiteSLA) {
        return fechaLimiteFinSemanaFestivos(limiteSLA, (Datetime)System.now());
    }

    // Función auxiliar para recuperar el delay en la configuración del Contacto Intermedio
    public static DateTime delayContactoIntermedio(String devName, String proceso) {
        Integer iDelay = 1;
        if (!Test.isRunningTest()) {
            List<CC_ConfigNotifCliente__mdt> oConfigContInt = [SELECT CC_DelayMinAcuse__c FROM CC_ConfigNotifCliente__mdt
                                                                WHERE DeveloperName = :devName AND CC_Proceso__c = :proceso AND CC_Activa__c = TRUE LIMIT 1];
            if (!oConfigContInt.isEmpty() && oConfigContInt[0].CC_DelayMinAcuse__c != null) {
                iDelay = Integer.valueOf(oConfigContInt[0].CC_DelayMinAcuse__c);
            }
        }
        Datetime oDelay = Datetime.now();
        oDelay = oDelay.addMinutes(iDelay);
        return oDelay;
    }

    public static Double HexToDecimal(String hexadecimal) {
        Map<String, Integer> hexMap = new Map<String, Integer>();
        hexMap.put('0', 0);
        hexMap.put('1', 1);
        hexMap.put('2', 2);
        hexMap.put('3', 3);
        hexMap.put('4', 4);
        hexMap.put('5', 5);
        hexMap.put('6', 6);
        hexMap.put('7', 7);
        hexMap.put('8', 8);
        hexMap.put('9', 9);
        hexMap.put('A', 10);
        hexMap.put('B', 11);
        hexMap.put('C', 12);
        hexMap.put('D', 13);
        hexMap.put('E', 14);
        hexMap.put('F', 15);
        hexMap.put('a', 10);
        hexMap.put('b', 11);
        hexMap.put('c', 12);
        hexMap.put('d', 13);
        hexMap.put('e', 14);
        hexMap.put('f', 15);

        Double retDecimal = 0;

        for (Integer i = 0; i < hexadecimal.length(); i++) {
            retDecimal += (hexMap.get(hexadecimal.substring(i, i + 1)) * Math.pow(16, hexadecimal.length() - (i + 1)));
        }
        return retDecimal;
    }

    /*
     * Método para retornar si se trata de un CIF o NIF/NIE
     */
    public static String validarCIFNIF(String nif) {
		String result = '';

        String dniRegex = '[0-9]{8}[A-Z]{1}';
        String cifRegex = '[ABCDEFGHJKLMNPQRSUVW]{1}[0-9]{7}[0-9A-J]{1}';
        String nieRegex = '[XYZ]{1}[0-9]{7,8}[A-Z]{1}';
        //NIF
        pattern myPatternDNI = pattern.compile(dniRegex);
		matcher myMatcherDNI = myPatternDNI.matcher(nif);
        //CIF
        pattern myPatternCIF = pattern.compile(cifRegex);
		matcher myMatcherCIF = myPatternCIF.matcher(nif);
        //NIE
        pattern myPatternNIE = pattern.compile(nieRegex);
		matcher myMatcherNIE = myPatternNIE.matcher(nif);
		if (myMatcherDNI.matches() == true) {
            result = 'NIF';
		} else if (myMatcherCIF.matches() == true) {
			result = 'CIF';
		} else if (myMatcherNIE.matches() == true) {
            result = 'NIE';
		}
        return result;
    }

    /*
     * Metodo para recuperar el valor de un parametro
     */

    public static String getParamValue(String param) {
        return [SELECT Valor_Texto__c FROM CC_Parametros__mdt WHERE DeveloperName = :param].Valor_Texto__c;
    }

    public static List<String> listaCampo(List<SObject> registros, String campo, Boolean quitarDuplicados) {
        /* Marc Pla, 19/8/2020: Dada una lista de SObject, retorna una lista con los valores del campo indicado.
            Ejemplo:
                List<String> nombresCuentas = listaCampo([SELECT Name FROM Account LIMIT 3], 'Name', false);
                retorna {'JOAN MERCADER OBIOLS', 'PERE CRUZ', 'RAMON MESSEGUER'} */

        List<String> retorno = new List<String>();
        if (registros != null) {
            for (SObject registro : registros) {
                String valor;
                Map<String, Object> mapaCamposActual = registro.getPopulatedFieldsAsMap();
                for (String campoJoin : campo.split('\\.')) {
                    if (campo.containsNone('.') || campoJoin == campo.substringAfterLast('.')) {
                        valor = String.valueOf(mapaCamposActual.get(campoJoin));
                    } else { //Lookup
                        if (mapaCamposActual.get(campoJoin) != null) {
                            mapaCamposActual = ((SObject)mapaCamposActual.get(campoJoin)).getPopulatedFieldsAsMap();
                        }
                    }
                }
                retorno.add(valor);
            }
        }
        return quitarDuplicados ? new List<String>(new Set<String>(retorno)) : retorno;
    }

    public static List<String> listaCampo(List<SObject> lista, String campo) {
        return listaCampo(lista, campo, false);
    }

    public static Map<String, SObject> mapaCampo(List<SObject> lista, String campo) {
        /* Marc Pla, 9/4/2021: Dada una lista de SObject, retorna un mapa con
            los valores del campo indicado como clave y el SObject como valor.

            Ejemplo:
                Map<String, Object> mapaCuentas = listaMapa([SELECT Name FROM Account LIMIT 3], 'Name');
                retorna {'JOAN MERCADER OBIOLS'=(account1), 'PERE CRUZ'=(account2), 'RAMON MESSEGUER'=(account3)} */

        Map<String, SObject> retorno = new Map<String, SObject>();
        if (lista != null) {
            for (SObject item : lista) {
                if (item.getPopulatedFieldsAsMap().containsKey(campo)) {
                    retorno.put(String.valueOf(item.get(campo)), item);
                }
            }
        }
        return retorno;
    }

    public static List<String> descartarDuplicadosLista(List<String> lista) {

        if (lista == null) {
            return null;
        } else {
            Set<String> aux = new Set<String>();
            for (String item : lista) {
                aux.add(item);
            }
            return new List<String>(aux);
        }
    }

    /*
    Retorna el nombre de la aplicación
    */
    static public String getApplicationName() {

        String appDef = '';
        if(!Test.isRunningTest()){
            List<UserAppInfo> userAppInfo = [SELECT Id, AppDefinitionId, User.UserRole.DeveloperName FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];

            if(!userAppInfo.isEmpty()){
                if(userAppInfo[0].User.UserRole.DeveloperName == 'SAC_General') {
                    return 'SAC';
                }
                List<AppDefinition> appDefinition = [SELECT DurableId, Label FROM AppDefinition Where DurableId = :userAppInfo[0].AppDefinitionId LIMIT 1];
                if(!appDefinition.isEmpty()){
                    return appDefinition[0].Label;
                }
            }
        }

        return appDef;
    }
    
    static public Double restarHoras (Time fecha1, Time fecha2){
        Datetime fechaA = Datetime.newInstance(Date.today(), fecha1);

        Datetime fechaB = Datetime.newInstance(Date.today(), fecha2);

        Double horaResultadoResta = restarHoras(fechaA, fechaB);

        return (horaResultadoResta);
    }
    
     //Método para restar horas
    //hora1:minuto1 - hora2:minuto2
    static public Double restarHoras (DateTime fecha1, DateTime fecha2){
        Double horaResultadoResta = 0;

        Long msegRestados = 0;
        if (fecha1 >= fecha2){
            msegRestados = fecha1.getTime() - fecha2.getTime();

        }
        else{
            msegRestados = fecha2.getTime() - fecha1.getTime();
        }
        horaResultadoResta = (Double)msegRestados/(1000L*60L*60L);


        return (horaResultadoResta);
    }
   
	static public Time horarioDiaTurno (Map<String, List <Time>> horario, String diaSemana, String entradaOsalida){
        Time horarioDiaTurno;
        if (Integer.valueOf(diaSemana) == 5){
            if (entradaOsalida == 'Entrada'){
                if (horario.size() > 1) {
                    horarioDiaTurno = horario.get('V').get(0);
                }
                else {
                    horarioDiaTurno = horario.get('L-V').get(0);
                }
            }
            else{
                if (horario.size() > 1) {
                    horarioDiaTurno = horario.get('V').get(1);
                }
                else {
                    horarioDiaTurno = horario.get('L-V').get(1);
                }
            }
        }
        else{
            if (entradaOsalida == 'Entrada'){
                if (horario.size() > 1){
                    horarioDiaTurno = horario.get('L-J').get(0);
                }
                else{
                    horarioDiaTurno = horario.get('L-V').get(0);
                }
            }
            else{
                if (horario.size() > 1){
                    horarioDiaTurno = horario.get('L-J').get(1);
                }
                else{
                    horarioDiaTurno = horario.get('L-V').get(1);
                }
            }
        }
        return horarioDiaTurno;
    }
    //Método para saber si la fecha que se le pasa por parámetro es fin de semana
    static public Boolean isWeekend (Datetime fecha){
        Boolean isWeekend = false;
        Integer diaSemana = Integer.valueOf(fecha.format('u'));
        isWeekend = (diaSemana > 5);

        return (isWeekend);
    }
    
    //Método para saber si el día que se pasa por parámetro con la lista de valores pasada por parámetro es festivo o no
    static public Boolean isFestive (Datetime fecha, Map <Integer, List <Integer>> listaFestivos){
        Boolean isFestivo = false;
        if (!listaFestivos.isEmpty()) {
            Integer mes = fecha.month();
            Integer dia = fecha.day();
            if (listaFestivos != null && mes >= 1 && dia >= 1 && listaFestivos.get(mes)!=null){
                isFestivo = listaFestivos.get(mes).contains(dia);
            }
        }

        return (isFestivo);
    }
    
    //Metodo para sacar el horario de toda la semana a partir de una Lista de valores
    static public Map<String, Map<String, List <Time>>> horariosPorCanalProcedencia (){
    List <CC_Lista_Valores__c> listaHorarios = new List < CC_Lista_Valores__c>();
    Map<String, Map<String, List <Time>>> horarioPorCanalProcedenciaMap = new Map<String, Map<String, List <Time>>> ();

    listaHorarios = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Calendario_servicios' AND CC_Activa__c = true ORDER BY CC_Valor__c];
    String nombre;
    Boolean valido;
    nombre = '';
    valido = true;

    if (!listaHorarios.isEmpty()){

        for(CC_Lista_Valores__c val : listaHorarios){

        nombre = val.Name;
        Map<String, List <Time>> horarioSemanaCanalProcedencia = new Map<String, List <Time>>();
        for(CC_Lista_Valores__c val2 : listaHorarios){

            if(nombre == val2.Name){
                List<Time> horariosDiaList = new List<Time>();
                horariosDiaList = pasarHorasListaValores(val2);
                horarioSemanaCanalProcedencia.put(val2.CC_Valor_SFDC__c, horariosDiaList);

            }

        }
        if (!horarioSemanaCanalProcedencia.isEmpty()){
            horarioPorCanalProcedenciaMap.put(nombre, horarioSemanaCanalProcedencia);
        }
        }


        // CODIGO SUSTITUIDO POR EL FOR ->while (i < listaHorarios.size()){
             /*
             Integuer = 0;
            for(List<CC_Lista_Valores__c> i :listaHorarios){
            nombre = i.get(Name);
            System.debug('Nombre ' + nombre);
            Map<String, List <Time>> horarioSemanaCanalProcedencia = new Map<String, List <Time>>();

           
            while (i < listaHorarios.size() && nombre == listaHorarios.get(i).Name){
                //Sacar horas y ponerlas en formato Time horariosDiaList -> List<Time> -> 8:30:0:0; 20:30:0:0
                
                List<Time> horariosDiaList = new List<Time>();
                horariosDiaList = pasarHorasListaValores(listaHorarios.get(i));
                horarioSemanaCanalProcedencia.put(listaHorarios.get(i).CC_Valor_SFDC__c, horariosDiaList);
                System.debug('horarioSemanaCanalProcedencia 1) ' + horarioSemanaCanalProcedencia);
                i++;
            }
           
            System.debug('horarioSemanaCanalProcedencia 2 ' + horarioSemanaCanalProcedencia);
             */
           
        }
        return horarioPorCanalProcedenciaMap;
    }
    
    //Metodo para obtener los festivos a partir de una lista de valores
    static public Map<Integer, List<Integer>> sacarFestivosPorMes (){       
        Map<Integer, List<Integer>> festivos = new Map<Integer, List<Integer>> ();
        List <CC_Lista_Valores__c> listaFestivos = [SELECT Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Festivos nacionales' AND CC_Activa__c = true ORDER BY CC_Valor2__c];

        if (!listaFestivos.isEmpty()){       
            for(CC_Lista_Valores__c val : listaFestivos){
                if (val.CC_Valor2__c != null && val.CC_Valor__c != null){
                    Integer mes = Integer.valueOf(val.CC_Valor2__c);
                    List <Integer> dias = new List <Integer>();
                    if (!festivos.containsKey(mes)){
                        festivos.put(mes, new List <Integer>());                 
                    }
                    festivos.get(mes).add(Integer.valueOf(val.CC_Valor__c)); 
                }            
            }
        }

        return festivos;
    }
    
    static public List<Time> pasarHorasListaValores (CC_Lista_Valores__c listaHorarios){
        List<Time> horarioDia = new List<Time>();

        //Hacemos el split por si la hora de entrada o de salida es del formato 8:30 o 8'30
        if (listaHorarios != null){
            List<String> splitEntrada = listaHorarios.CC_Valor__c.splitByCharacterType();
            List<String> splitSalida = listaHorarios.CC_Valor2__c.splitByCharacterType();
            Integer minutos = 0;
            if (splitEntrada.size() > 1) {
                minutos = Integer.valueOf(splitEntrada.get(splitEntrada.size()-1));
            }
            Time hora = Time.newInstance(Integer.valueOf(splitEntrada.get(0)), minutos, 0, 0);
            horarioDia.add(hora);
            minutos = 0;
            if (splitSalida.size() > 1) {
                minutos = Integer.valueOf(splitSalida.get(splitSalida.size()-1));
            }
            hora = Time.newInstance(Integer.valueOf(splitSalida.get(0)), minutos, 0, 0);
            horarioDia.add(hora);
        }

        return horarioDia;
    }
//Metodo para encriptar en SHA
    static public String encriptarSHA (String tipoSha, String key){
    String result = '';
    if(String.isNotEmpty(tipoSha) && String.isNotEmpty(key) ){
        Blob digest = Crypto.generateDigest(tipoSha, Blob.valueOf(key));
        result = EncodingUtil.convertToHex(digest);
    }
        return result;
    }

    public static User buscarGestor(String numeroGestor) {
        List <User> gestorCliente = new List <User>();
        String matriculaGestor;
        String nameGestor;
        String externalID;
        if(numeroGestor != null && numeroGestor != 'generico') {
            if(numeroGestor.startsWith('U01')) {
                matriculaGestor = numeroGestor;
            } else if (numeroGestor != '000000') {
                matriculaGestor = 'U01'+ numeroGestor;
            }            
            gestorCliente = [SELECT Id, AV_ExternalID__c, Name FROM User WHERE AV_ExternalID__c = :matriculaGestor AND isActive = true LIMIT 1];
        }
        if(gestorCliente.isEmpty() || numeroGestor == 'generico') {
            Map<String, String> retorno = buscarGestorGenerico();
            String matricula = retorno.get('matricula');
            gestorCliente = [SELECT Id, Name, AV_ExternalID__c FROM User WHERE AV_ExternalID__c = :matricula LIMIT 1];
        }
        return gestorCliente.isEmpty() ? null : gestorCliente[0];
    }

    public static Boolean gestorEsGenerico(User gestor) {
        Map<String, String> retorno = buscarGestorGenerico();
        return gestor.Name == retorno.get('nombre') && gestor.AV_ExternalID__c == retorno.get('matricula');
    }

     public static Map<String, User> buscarGestoresPorMatricula(List<String> numeroGestores) {
        Map<String, User> gestores = new Map<String, User>();
        //Construir matricula a partir del  numero de Gestor
        List<String> matriculasGestor = new List<String>();
        for(String numeroGestor : numeroGestores) {            
            if(numeroGestor.startsWith('U01')) {
                matriculasGestor.add(numeroGestor);
            } else if (numeroGestor != '000000') {
                matriculasGestor.add('U01'+ numeroGestor);
            }    
        }

        //Buscar gestores por matricula
        if(!matriculasGestor.isEmpty()) {
            List<User> gestoresEncontrados = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c IN :matriculasGestor];
            for(User gestor : gestoresEncontrados) {
                gestores.put(gestor.AV_ExternalID__c, gestor);
            }
        }
        
        if(gestores.isEmpty()) {
            Map<String, String> retorno = buscarGestorGenerico();
            String matricula = retorno.get('matricula');
            List<User> gestoresEncontrados = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c = :matricula LIMIT 1];
            if(!gestoresEncontrados.isEmpty()) {
                gestores.put(gestoresEncontrados[0].AV_ExternalID__c, gestoresEncontrados[0]);
            }
        }

        return gestores;
    }
    
    public static Map<String, String> buscarGestorGenerico() {
        String nameGestor;
        String externalID;
        Map<String, String> retorno = new Map<String, String>();
        List<CC_Lista_Valores__c> listaLOV = [SELECT CC_Valor__c, Name FROM CC_Lista_Valores__c  WHERE CC_Lista__r.name = 'Gestor por defecto CC'];
        for(CC_Lista_Valores__c valor: listaLOV) {
            if(valor.Name == 'ExternalID') {
                externalID = valor.CC_Valor__c;
            }
            else if (valor.Name == 'Nombre') {
                nameGestor = valor.CC_Valor__c;
            }
        }
        retorno.put('nombre', nameGestor);
        retorno.put('matricula', externalID);
        return retorno;
    }

    public static List<Contact> buscarGestores(String oficina) {
        if(!String.isEmpty(oficina)) {
            List<Contact> gestores = [SELECT Id, Name FROM Contact WHERE AccountId = :oficina AND CC_Inactivo__c = false AND CC_Num_Empleado_Generico__c NOT IN('99999', '98999')];
            return gestores;
        } else {
            return null;
        }        
    }


    public static Map<Id, String> generarURLsLimeSurvey(List<Case> listaCasos) {
        Map<Id, String> urlsEncuestas = new Map<Id, String>();
        Id rtCaseEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
    
        if (listaCasos == null || listaCasos.isEmpty()) {
            return urlsEncuestas;
        }

        List<Task> tasks = [
            SELECT Id, CC_Grupo_Colaborador_Id__r.Name, WhatId, Type, What.RecordTypeId, Status
            FROM Task
            WHERE WhatId IN :listaCasos
            AND Type IN ('Traslado Tercer Nivel', 'Traslado colaborador', 'Llamada transferida')
            ORDER BY WhatId, CreatedDate DESC
        ];
        Map<Id, String> caseToGroupMap = new Map<Id, String>();
        Set<Id> processedCaseIds = new Set<Id>();
        Set<Id> casoConTrasladoColaborador = new Set<Id>();
        Map<Id, List<Task>> mapCasoTasks = new Map<Id, List<Task>>();
        for (Task t : tasks) {
            if (!processedCaseIds.contains(t.WhatId)) {
                //Añadido controlar que si son llamadas transferidas, que solo sean las de tipo empleado US
                if (t.Type != 'Llamada transferida') {
                    caseToGroupMap.put(t.WhatId, t.CC_Grupo_Colaborador_Id__r.Name);
                    processedCaseIds.add(t.WhatId);
                } else if (String.isNotBlank(t.WhatId) && t.WhatId.getSObjectType().getDescribe().getName() == 'Case' && t.What.RecordTypeId == rtCaseEmpleado) {
                    caseToGroupMap.put(t.WhatId, t.CC_Grupo_Colaborador_Id__r.Name);
                    processedCaseIds.add(t.WhatId);
                }
                //Añadido controlar que si es una tarea de traslado colaborador, ese caso debe enviar una encuesta con el código de tercer nivel
                if (t.Type == 'Traslado colaborador' && String.isNotBlank(t.WhatId) && t.WhatId.getSObjectType().getDescribe().getName() == 'Case' && t.What.RecordTypeId == rtCaseEmpleado) {
                    casoConTrasladoColaborador.add(t.WhatId);
                }
            }
            //Rellenar mapa con las task de cada caso
            if (mapCasoTasks.containsKey(t.WhatId)) {
                mapCasoTasks.get(t.WhatId).add(t);
            } else {
                List<Task> listaTasks = new List<Task>();
                listaTasks.add(t);
                mapCasoTasks.put(t.WhatId, listaTasks);
            }
        }
    
        // Obtener la configuración de encuestas
        String linkBase = null, idEncuestaGenerico = null;
        String idEncuestaLlamada = null, idEncuestaChat = null, idEncuestaTercerNivel = null, idFCO = null;
    
        List<CC_Envio_Encuesta__c> linkEncuestaEmpleado = [
            SELECT CC_Link_LimeSurvey__c, CC_Id_Encuesta__c, CC_Tipo_Encuesta__c, Name 
            FROM CC_Envio_Encuesta__c 
            WHERE Name IN ('CC_URL_Encuesta', 'CC_TipoLlamada', 'TipoChat', 'CC_TercerNivel', 'CC_EncuestaFormularioOperativas')
        ];
    
        for (CC_Envio_Encuesta__c e : linkEncuestaEmpleado) {
            if (e.CC_Tipo_Encuesta__c == 'URL base') {
                linkBase = e.CC_Link_LimeSurvey__c;
                idEncuestaGenerico = e.CC_Id_Encuesta__c;
            } else if (e.CC_Tipo_Encuesta__c == 'Phone') {
                idEncuestaLlamada = e.CC_Id_Encuesta__c;
            } else if (e.CC_Tipo_Encuesta__c == 'Chat') {
                idEncuestaChat = e.CC_Id_Encuesta__c;
            } else if (e.CC_Tipo_Encuesta__c == 'Caso Tercer Nivel') {
                idEncuestaTercerNivel = e.CC_Id_Encuesta__c;
            }else if(e.Name == 'CC_EncuestaFormularioOperativas'){
                idFCO = e.CC_Id_Encuesta__c;
            }
        }
    
        if (linkBase == null) {
            return urlsEncuestas;
        }
    
        // Obtener información de LiveChatTranscript en una sola consulta
        Map<Id, String> mapInfoChat = new Map<Id, String>();
        Set<Id> caseIds = new Set<Id>();
    
        for (Case caso : listaCasos) {
            if (caso != null && caso.Id != null) {
                caseIds.add(caso.Id);
            }
        }
    
        if (!caseIds.isEmpty()) {
            for (LiveChatTranscript chat : [SELECT CC_Espacio__c, CaseId FROM LiveChatTranscript WHERE CaseId IN :caseIds AND CC_Tipo__c = 'Agente' AND RecordTypeId = :getRecordTypeIdFromDeveloperName('LiveChatTranscript', 'CC_Empleados') 
                ORDER BY CreatedDate DESC
            ]) {
                mapInfoChat.put(chat.CaseId, chat.CC_Espacio__c);
            }
        }
    
        // Procesar cada caso
        for (Case caso : listaCasos) {
            if (caso == null || caso.Id == null || caso.CC_Idioma__c == null || caso.CC_Matricula_Empleado__c == null || 
                caso.CC_MCC_Tematica__c == null || caso.CC_Tematica__c == null) {
                continue;
            }
    
            // Determinar identificador de encuesta
            String idEncuesta = idEncuestaGenerico;
                
            if (caso.RecordtypeId == rtCaseEmpleado) {
                if(caso.CC_En_Tercer_Nivel__c || casoConTrasladoColaborador.contains(caso.Id)){ //Añadido que si este caso es de empleados y tiene traslado colaborador, también debe mandar el codigo de encuesta 3N
                idEncuesta = idEncuestaTercerNivel;
                }else if (caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas') {
                    idEncuesta = idFCO;
                } else if ('Phone'.equals(caso.Origin)) {
                    idEncuesta = idEncuestaLlamada;
                } else if ('Chat'.equals(caso.Origin)) {
                    idEncuesta = idEncuestaChat;
                }
            } else {
                if(caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas'){
                idEncuesta = idFCO;
                }else if (caso.CC_En_Tercer_Nivel__c) {
                    idEncuesta = idEncuestaTercerNivel;
                } else if ('Phone'.equals(caso.Origin)) {
                    idEncuesta = idEncuestaLlamada;
                } else if ('Chat'.equals(caso.Origin)) {
                    idEncuesta = idEncuestaChat;
                }
            }
    
            // Determinar grupo o temática
            Boolean hayTrasladoColaborador = false;
            if (mapCasoTasks.containsKey(caso.Id)) {
                for (Task tarea : mapCasoTasks.get(caso.Id)) {
                    if (tarea.Type == 'Traslado colaborador') {
                        hayTrasladoColaborador = true;
                    }
                }    
            }

            String grupoTematica = (caseToGroupMap.containsKey(caso.Id) && !String.isEmpty(caseToGroupMap.get(caso.Id)) && (caso.CC_En_Tercer_Nivel__c || hayTrasladoColaborador)) 
            ? caseToGroupMap.get(caso.Id) 
            : caso.CC_Tematica__c;

            // Determinar identificador del espacio
            String idEspacio = mapInfoChat.containsKey(caso.Id) 
                ? mapInfoChat.get(caso.Id).replace(' ', '_') 
                : caso.CC_Tematica__c.replace(' ', '_');
    
            // Construcción de la URL
            String encuestaURL = construirURL(linkBase, idEncuesta, caso, idEspacio, grupoTematica);
    
            // Agregar al mapa de resultados
            urlsEncuestas.put(caso.Id, encuestaURL);
        }
    
        return urlsEncuestas;
    }
    
    // Método auxiliar para construir la URL
    private static String construirURL(String base, String idEncuesta, Case caso, String idEspacio, String grupoTematica) {
        return base + 'sid=' + idEncuesta 
            + '&lang=' + caso.CC_Idioma__c 
            + '&userid=' + caso.CC_Matricula_Empleado__c 
            + '&ticketid=' + caso.CaseNumber 
            + '&idet=' + idEspacio 
            + '&et=' + grupoTematica.replace(' ', '_') 
            + '&newtest=Y';
    }
    

    public static List<String> getValoresCS(String nombreCS) {
        CC_Settings__c cs = CC_Settings__c.getValues(nombreCS);
        if (cs == null) return new List<String>(); 
    
        List<String> listaValores = new List<String>();
    
        // Iterar directamente sobre los campos poblados
        for (String campo : cs.getPopulatedFieldsAsMap().keySet()) {
            if (campo.startsWith('CC_Configuracion_')) {
                listaValores.add(String.valueOf(cs.get(campo))); 
            }
        }
    
        return listaValores;
    }
    
    public static Map<Id, String> recuperarNumpersoPorComunicaciones(List<CC_Comunicaciones__c> comunicaciones) {
        Map<Id, String> idToNumPersoMap = new Map<Id, String>();
    
        for (CC_Comunicaciones__c comunicacion : comunicaciones) {
            String numPerso = '';
    
            if (comunicacion.CC_Case__r.CC_Representante__c != null) {
                // Si hay representante, se toma el NumPerso del representante
                numPerso = !String.isEmpty(comunicacion.CC_Case__r.CC_Representante__r?.CC_Representante__r?.AV_NumPerso__c) ? comunicacion.CC_Case__r.CC_Representante__r?.CC_Representante__r?.AV_NumPerso__c : !String.isEmpty(comunicacion.CC_Case__r.CC_Representante__r?.CC_Representante__r?.CC_NumPerso__c) ? comunicacion.CC_Case__r.CC_Representante__r?.CC_Representante__r?.CC_NumPerso__c : '';
            } else if (comunicacion.CC_Case__r.Account.RecordType.DeveloperName == 'CC_Cliente' && comunicacion.CC_Case__r.Contact.RecordType.DeveloperName == 'CIBE_Apoderado') {
                // Si es cliente jurídico con apoderado
                numPerso = !String.isEmpty(comunicacion.CC_Case__r.Contact?.CIBE_NumPerso__c) ? comunicacion.CC_Case__r.Contact?.CIBE_NumPerso__c : !String.isEmpty(comunicacion.CC_Case__r.Contact?.AV_NumPerso__c) ? comunicacion.CC_Case__r.Contact?.AV_NumPerso__c : !String.isEmpty(comunicacion.CC_Case__r.Contact?.CC_NumPerso__c) ? comunicacion.CC_Case__r.Contact?.CC_NumPerso__c : '';
            } else if (comunicacion.CC_Case__r.Account.RecordType.DeveloperName == 'CC_Cliente' && comunicacion.CC_Case__r.Contact.RecordType.DeveloperName == 'CC_Cliente' && comunicacion.CC_Case__r.Account.AV_Segmento__c == 'RPF') {
                // Si el segmento es RPF, se toma el AV_NumPerso de la cuenta
                numPerso = !String.isEmpty(comunicacion.CC_Case__r.Account?.AV_NumPerso__c) ? comunicacion.CC_Case__r.Account?.AV_NumPerso__c : !String.isEmpty(comunicacion.CC_Case__r.Account?.CC_NumPerso__c) ? comunicacion.CC_Case__r.Account?.CC_NumPerso__c : '';
            } else {
                // Para otros casos, se toma el NumPerso de la cuenta
                numPerso = !String.isEmpty(comunicacion.CC_Case__r.Account?.AV_NumPerso__c) ? comunicacion.CC_Case__r.Account?.AV_NumPerso__c : !String.isEmpty(comunicacion.CC_Case__r.Account?.CC_NumPerso__c) ? comunicacion.CC_Case__r.Account?.CC_NumPerso__c : '';
            }
    
            // Agregar al mapa
            idToNumPersoMap.put(comunicacion.Id, numPerso);
        }
    
        return idToNumPersoMap;
    }

    public static Map<String, String> inicializarCuerpoCorreo(EmailTemplate plantilla, Case caso) {

        String textoCuerpo = '';
        Map<String, String> datosPlantilla = new Map<String, String>();

        if (plantilla.HtmlValue != null) {
            textoCuerpo = plantilla.HtmlValue;
            textoCuerpo = textoCuerpo.replaceAll('<html>','');
            textoCuerpo = textoCuerpo.replaceAll('<body style="height: auto; min-height: auto;">','');
            textoCuerpo = textoCuerpo.replaceAll('<body>','');
            textoCuerpo = textoCuerpo.replaceAll('<head>','');
            textoCuerpo = textoCuerpo.replaceAll('</body>','');
            textoCuerpo = textoCuerpo.replaceAll('</head>','');
            textoCuerpo = textoCuerpo.replaceAll('</html>','');
            textoCuerpo = textoCuerpo.replaceAll('<title>','');
            textoCuerpo = textoCuerpo.replaceAll('</title>','');
            datosPlantilla = datosPlantilla(plantilla);

        }
        if (caso.CC_Referencia_Correo_Saliente__c == null || datosPlantilla.get('operativa') == null) {
            throw new AuraHandledException('No se permiten enviar correos que no se originen de una operativa.');
        }
        //En función de la operativa recupera el histórico de correos para añadirlo al final del correo
        String idioma = datosPlantilla.get('idioma');
        String operativa = datosPlantilla.get('operativa');
        String tratamiento = datosPlantilla.get('tratamiento');

        String historicoCorreos = '';
        try{
            if (operativa == 'Responder a cliente') {
                historicoCorreos = CC_Case.correoInicialCliente(caso.Id);
            } else {
                historicoCorreos = CC_Case.historicoCorreosCliente(caso.Id, false);
            }
        } catch(Exception e) {
            throw new AuraHandledException('Error recopilando histórico de correos para el caso');
        }

        //Semilla multi idioma
        List<CC_Texto_MultiIdioma__mdt> frasesSemilla = new List<CC_Texto_MultiIdioma__mdt>();
        
        if (operativa == 'Traslado Colaborador'){
            frasesSemilla = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'CC_Semilla_Traslado_Colaborador_ESP' LIMIT 1];
        } else if (operativa == 'Solicitud Información') {
            String nombreMetadataSolInfo = idioma == 'en' ? 'CC_Semilla_Solicitud_Info' : 'CC_Semilla_Solicitud_Info_';
            frasesSemilla = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt
                            WHERE CC_Nombre__c = :(nombreMetadataSolInfo + tratamiento) AND CC_Idioma__c = :idioma LIMIT 1];
        } else if (operativa == 'Responder Cliente') {
            String nombreMetadataResponder = idioma == 'en' ? 'CC_Semilla_Responder' : 'CC_Semilla_Responder_';
            frasesSemilla = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt
                            WHERE CC_Nombre__c = :(nombreMetadataResponder + tratamiento) AND CC_Idioma__c = :idioma LIMIT 1];
        }

        textoCuerpo += '<br/><br/><font color="gray">';
        if (!frasesSemilla.isEmpty()) {
            textoCuerpo += frasesSemilla[0].CC_Texto__c + ' #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
        } else if (frasesSemilla.isEmpty() && operativa != 'Traslado Colaborador' && operativa != 'Responder Cliente') {
            textoCuerpo += 'Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
        } else if (frasesSemilla.isEmpty() && operativa == 'Responder Cliente') {
            textoCuerpo += 'Por favor, no responder a este correo electrónico: #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
        }
        textoCuerpo += '</font>';

        String textoTotal = textoCuerpo + historicoCorreos;

        if (textoTotal.length() >= 131072) {
            textoTotal = textoTotal.substring(0, 131072);
        }
        plantilla.HtmlValue = textoTotal;
        return datosPlantilla;
    }

    private static Map<String, String> datosPlantilla(EmailTemplate plantilla) {
        /* La operativa se puede deducir de la jerarquía de carpetas en la que se encuentra la plantilla. Ejemplo para operativas CC:

        TIPO PLANTILLA              JERARQUÍA CARPETAS
        Traslado a colaborador      Operativas > Trasladar a colaborador > Castellano > PLANTILLA
        Remitir a colaborador       Operativas > Remitir a colaborador > Castellano
        Solicitud de información    Operativas > Solicitud de información > Idioma (Castellano/Catalán/Inglés) > Tratamiento (Formal/Informal)
        Responder a cliente         Operativas > Responder a cliente > Idioma (Castellano/Catalán/Inglés) > Tratamiento (Formal/Informal)
        ---
        * NOTA: Para idioma inglés no aplica subcarpeta de tratamiento.

        Como en función de la operativa la carpeta que la define no siempre está a la misma distancia de
        la plantilla, se concatenan en una cadena los nombres de las carpetas de los 3 últimos niveles de la
        jerarquía y se busca en dicha cadena el nombre de la operativa. */

        try {
            Folder carpeta = [SELECT Name, ParentId FROM Folder WHERE Id = :plantilla.FolderId LIMIT 1];
            String jerarquiaCarpetas = carpeta.Name;
            
            if(carpeta.ParentId != null){
                carpeta = [SELECT Name, ParentId FROM Folder WHERE Id = :carpeta.ParentId LIMIT 1];
                jerarquiaCarpetas = carpeta.Name + '-' + jerarquiaCarpetas;
            }

            if(carpeta.ParentId != null){
                carpeta = [SELECT Name, ParentId FROM Folder WHERE Id = :carpeta.ParentId LIMIT 1];
                jerarquiaCarpetas = carpeta.Name + '-' + jerarquiaCarpetas;
            }

            String operativa = null;
            if (jerarquiaCarpetas.contains('Trasladar a colaborador')) {
                operativa = 'Traslado Colaborador';
            } else if (jerarquiaCarpetas.contains('Remitir a colaborador')) {
                operativa = 'Remitir Colaborador';
            } else if (jerarquiaCarpetas.contains('Solicitud de información')) {
                operativa = 'Solicitud Información';
            } else if (jerarquiaCarpetas.contains('Responder a cliente')) {
                operativa = 'Responder Cliente';
            } else if (jerarquiaCarpetas.contains('Enviar correo')) {
                operativa = 'Enviar correo';
            }


            String idioma = null;
            if (jerarquiaCarpetas.contains('Catalán')) {
                idioma = 'ca';
            } else if (jerarquiaCarpetas.contains('Inglés')) {
                idioma = 'en';
            } else {
                idioma = 'es';
            }

            String tratamiento = null;
            if (jerarquiaCarpetas.contains('Informal')) {
                tratamiento = 'Tu';
            } else if (jerarquiaCarpetas.contains('Genérico')) {
                tratamiento = '';
            } else {
                tratamiento = 'Usted';
            }

            Map<String, String> retorno = new Map<String, String>();
            retorno.put('operativa', operativa);
            retorno.put('idioma', idioma);
            retorno.put('tratamiento', tratamiento);
            return retorno;
        } catch (Exception e) {
            throw new AuraHandledException('Error recuperando la jerarquía de carpetas para la plantilla "' + plantilla.DeveloperName + '"');
        }
    }
   
}