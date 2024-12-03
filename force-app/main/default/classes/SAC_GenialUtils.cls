/*****************************************************************
 * Name: SAC_GenialUtils
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: funciones útiles para el proyecto genial
 * 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US727970         Alexandre perez        26/10/23       Creación     
* 1.1            US866221         David Ramos            02/04/24       Modificar randomizador para que use el nuevo custom 
                                                                        setting que separa configuraciones por canal 
                                                                        + Añadir restriccion por rango de horas
                                                                        + Añadir restriccion por dia de la semana
                                                                        + Añadir restriccion por rango de fechas
                                                                        + Añadir restriccion por cantidad al dia
* 1.2            US914420         Alex Perez             07/05/24     nueva funcionalidad programarEnviarAzure
* 1.3            US930430         Alex Perez             20/05/24     Añadir al filtro del conteo los casos convertidos a consulta
* 1.4            US976182         Borja Lavesiera        26/07/2024   Adaptación programarEnviar para el balanceador de integraciones
* 1.5            US967476         Borja Lavesiera        12/08/2024   Creación MilestoneTimeCalcultor para casos IA
*****************************************************************/
public with sharing class SAC_GenialUtils {

    /***
     * segun la configuracion del custom setting de genial, decide si el caso entrante de mail debe ser objeto de IA.
     * devuelve el nombre de la cola de pendiente estardard o la cola de pendiente de IA
     */
    public static string randomizador(String canal) {
        try{
            SAC_GenialSettingsCanal__c  settings = SAC_GenialSettingsCanal__c.getInstance(canal);
        // public static string randomizador() {
        //     SAC_GenialSettings__c  settings = SAC_GenialSettings__c.getInstance();
            string nombreCola;
            if((settings.SAC_IAactiva__c || settings.SAC_shadow__c)){
                if((math.random()*100 < settings.SAC_Porcentaje__c) && (comprobarRestriccionesSetting(settings))){
                    if(settings.SAC_IAactiva__c){
                        nombreCola = 'SAC_GenialPdteIA;IA';
                    } else {
                        nombreCola =  'SAC_PendienteAsignar;Shadow';
                    }      
                } else {
                    nombreCola = 'SAC_PendienteAsignar';
                }
            }else{
                nombreCola = 'SAC_PendienteAsignar';
            } 
    
            return nombreCola;
        }
        catch(Exception e){
            List<Object> detalle = new List<Object>();
            detalle.add((Object)canal);
            CBK_Log.error(e, detalle);
            return 'SAC_PendienteAsignar';
        }
    }

    /*
    *Hacer todas las comprobaciones adicionales segun la configuracion que hay en el custom setting, 
    * y devolver si se cumplen o no.
    * Solo se llamará si la comparacion con el math.random() da true, 
    * por lo que será con casos que se enviarian a la IA
    */
    public static Boolean comprobarRestriccionesSetting(SAC_GenialSettingsCanal__c  settings){
        //para hacer la comprobacion por horas
        DateTime fechaHoraActual = Datetime.now();
        //Si el rango de horas está vacío no se tendrá en cuenta la restriccion
        if (settings.SAC_HoraInicio__c != null && settings.SAC_HoraFin__c != null){
            //Si el rango de horas no está vacío hay que comprobar si la hora actual esta dentro
            Decimal minutoActual = fechaHoraActual.minute();
            Decimal horaActual = fechaHoraActual.hour() + minutoActual/100;
            if (horaActual < settings.SAC_HoraInicio__c || horaActual > settings.SAC_HoraFin__c){
                return false;
            }
        }

        //comprobacion por dia de la semana
        if (!(Boolean)settings.get('SAC_'+fechaHoraActual.format('EEEE')+'ON__c')){
            return false;
        }

        //Comprobación por fecha
        //Si el rango de fechas está vacío no se tendrá en cuenta la restriccion
        if (settings.SAC_FechaInicio__c != null && settings.SAC_FechaFin__c != null){
            //Si el rango de fechas no está vacío hay que comprobar si la fecha actual esta dentro
            if (fechaHoraActual < settings.SAC_FechaInicio__c || fechaHoraActual > settings.SAC_FechaFin__c){
                return false;
            }
        }        

        //comprobación por cantidad de casos al dia
        if (!comprobarRestriccionCantidad(settings)){
            return false;
        }

        //si no ha incumplido ninguna de las restricciones entonces se puede envias a IA
        return true;
    }

    /*
    * Repartir las comprobaciones de restricciones en funciones separadas para evitar que tengan demasiadas lines de codigo
    */
    public static Boolean comprobarRestriccionCantidad(SAC_GenialSettingsCanal__c settings){
        DateTime fechaHoraActual = Datetime.now();
        //String recordTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        //String recordTypeConsulta = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
        //String recordTypeConsultaCops = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
        list<string> rtslist = new list<string>();
        RTslist.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId());
        RTslist.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId());
        RTslist.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId());
        //Si la cantidad maxima está vacía no se tendrá en cuenta la restriccion
        /*if(settings.SAC_CantidadCasosMax__c != null && settings.SAC_MaxCasosAlcanzado__c && fechaHoraActual.date() == settings.SAC_FechaConteoCasos__c){
            //Si el maximo ya esta alcanzado la restriccion no se cumple
            return false;
        }*/
        if(settings.SAC_CantidadCasosMax__c != null && settings.SAC_MaxCasosAlcanzado__c && fechaHoraActual.date() == settings.SAC_FechaConteoCasos__c){
            //Si el maximo ya esta alcanzado la restriccion no se cumple
            return false;
        }
        //else if(settings.SAC_CantidadCasosMax__c != null && (!settings.SAC_MaxCasosAlcanzado__c || fechaHoraActual.date() != settings.SAC_FechaConteoCasos__c )) {
        else if(settings.SAC_CantidadCasosMax__c != null) {
            Boolean updatePendiente = false;
            integer contadorCasos = 0;
            if(fechaHoraActual.date() != settings.SAC_FechaConteoCasos__c){
                updatePendiente = true;
                settings.SAC_FechaConteoCasos__c = fechaHoraActual.date();
                settings.SAC_MaxCasosAlcanzado__c = false;
                //contadorCasos = 1;
            } 
            
            if(!settings.SAC_MaxCasosAlcanzado__c) {
                list<AggregateResult> listaCasosIA = [SELECT count(Id) contadorCasosActual FROM Case 
                                                        WHERE CreatedDate = TODAY AND recordTypeId IN : RTslist
                                                         AND Origin = :settings.Name AND SAC_GenialEstado__c != null WITH SECURITY_ENFORCED];
                contadorCasos = (Integer)listaCasosIA[0].get('contadorCasosActual');
            }
            //Si la cantidad maxima no esta vacia hay que hacer la comprobacion
            //version usando cache
            //Boolean updatePendiente = false;
            //obtener el contador actual
            //Integer contadorCasos = 0; 
            //String canalAlfanumerico = settings.Name.replaceAll('[^a-zA-Z0-9]', '');
            //las keys de cache solo admiten caracteres alfanumericos
            //String idContadorCache = 'local.SAC.CantidadCasosActual'+ canalAlfanumerico +'Genial';
            
        
            /*if (Cache.Org.contains(idContadorCache) && fechaHoraActual.date() == settings.SAC_FechaConteoCasos__c){
                //si esta usamos el valor
                contadorCasos = (Integer)Cache.Org.get(idContadorCache);
            }
            else if (fechaHoraActual.date() != settings.SAC_FechaConteoCasos__c){
                //si esta pero la fecha es diferente hay que recalcular el contador para que solo tenga los del dia actual
                settings.SAC_FechaConteoCasos__c = fechaHoraActual.date();
                settings.SAC_MaxCasosAlcanzado__c = false;
                updatePendiente = true;

                //String recordTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
                //String recordTypeConsulta = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
                /*
                list<Case> listaCasosIA = [SELECT Id FROM Case WHERE CreatedDate = TODAY AND recordTypeId = :recordTypeReclamacion AND Origin = :settings.Name AND SAC_GenialEstado__c != null WITH SECURITY_ENFORCED];
                contadorCasos = listaCasosIA.size();
                */
               /* list<AggregateResult> listaCasosIA = [SELECT count(Id) contadorCasosActual FROM Case 
                                                        WHERE CreatedDate = TODAY AND recordTypeId IN : RTslist
                                                         AND Origin = :settings.Name AND SAC_GenialEstado__c != null WITH SECURITY_ENFORCED];
                contadorCasos = (Integer)listaCasosIA[0].get('contadorCasosActual');
                Cache.Org.put(idContadorCache, contadorCasos);
            }*/
            //else {
                //si no esta y es la misma fecha hacemos una query para saber cuantos hay
                //String recordTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
				/*
                list<Case> listaCasosIA = [SELECT Id FROM Case WHERE CreatedDate = TODAY AND recordTypeId = :recordTypeReclamacion AND Origin = :settings.Name AND SAC_GenialEstado__c != null WITH SECURITY_ENFORCED];
                contadorCasos = listaCasosIA.size();
                */                
               /* list<AggregateResult> listaCasosIA = [SELECT count(Id) contadorCasosActual FROM Case 
                                                        WHERE CreatedDate = TODAY AND recordTypeId = : RTslist
                                                        AND Origin = :settings.Name AND SAC_GenialEstado__c != null WITH SECURITY_ENFORCED];
                contadorCasos = (Integer)listaCasosIA[0].get('contadorCasosActual');
                Cache.Org.put(idContadorCache, contadorCasos);
            }*/

            /*
            //primero comprobar si la fecha es la del dia, por si hay que resetear
            if(fechaHoraActual.date() != settings.SAC_FechaConteoCasos__c){
                //si es diferente (null incluido) hay que resetear los valores
                settings.SAC_FechaConteoCasos__c = fechaHoraActual.date();
                settings.SAC_MaxCasosAlcanzado__c = false;
                updatePendiente = true;

                contadorCasos = 0;
                Cache.Org.put(idContadorCache, contadorCasos);
            }
            */

            //si la cantidad es menor que el maximo se permite que el caso se envie a IA
            //si no hay que marcar el check  
            if (contadorCasos >= settings.SAC_CantidadCasosMax__c){
                settings.SAC_MaxCasosAlcanzado__c = true;
                updatePendiente = true;
            }

            //si se tienen que reiniciar los valores por cambio de fecha o poner el check de maximo alcanzado hacer el update del custom setting
            if(updatePendiente){
                //intentar hacer el update
                Database.SaveResult sr;
                List<Object> errorObjs = new List<Object>();
                Map<String, String> errorMsjs = new Map<String, String>();
                sr = Database.update(settings, false);
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    errorMsjs.put(settings.Id, ((String)sr.getErrors()[0].getMessage()));
                    errorObjs.add((sObject)settings);
                    CBK_Log.error(errorMsjs, errorObjs);
                }
            }
            if(settings.SAC_MaxCasosAlcanzado__c){
                //esperarse a haber hecho el update para devolver que no cumple la restriccion
                return false;
            }
        }
        return true;
    }

    /*
    *Castear la clase de Case a SAC_Genial_Resultado__c, convierte campos standard en el caso, a campos custom en el objeto de SAC resultado y
    *y los campos custom de case que en origen fueron creados por otras aplicaciones, los convierte a campos SAC de genial resultado.
    */
    public static SAC_Genial_Resultado__c casteoCaseAgenialResultado(case caso){
        Map<String, Object> camposCaso = caso.getPopulatedFieldsAsMap();
        SAC_Genial_Resultado__c casteoGenial = new SAC_Genial_Resultado__c();
        //para saber si el campo casteado existe en el objeto obtenemos el esquema de campos del objeto destino
        SObjectType genialType = Schema.getGlobalDescribe().get('SAC_Genial_Resultado__c');
        Map<String,Schema.SObjectField> camposGenial = genialType.getDescribe().fields.getMap();

        for (String nombreCampo : camposCaso.keySet()){
            string campoFinal;
            if(nombreCampo.right(3) == '__c'){
                /*if(nombreCampo.left(3) != 'SAC'){
                    //casteoGenial.put(nombreCampo.replace(nombreCampo.left(nombreCampo.indexOf('_'))), camposCaso.get(nombreCampo));
                    campoFinal = 'SAC' + nombreCampo.substring(nombreCampo.indexOf('_'));
                } else {
                    campoFinal = nombreCampo;
                }*/
                campoFinal = 'SAC' + nombreCampo.substring(nombreCampo.indexOf('_'));
                //comprobamos que el campo exista en el objeto destino
                if(camposGenial.containsKey(campoFinal)) {
                    casteoGenial.put(campoFinal, camposCaso.get(nombreCampo)); 
                }
               
            } else if(nombreCampo != 'Id' && nombreCampo != 'RecordTypeId') {
                campoFinal = 'SAC_' + nombreCampo + '__c';
                if(camposGenial.containsKey(campoFinal)) {
                    casteoGenial.put(campoFinal, camposCaso.get(nombreCampo));
                }
            }        
        }
        return casteoGenial;
    }

    //funcion para ver cuales campos de un Case son diferentes a los equivalentes de un SAC_Genial_Result
    //devuelve un Map con los nombres de los campos de SAC_Genial_Resultado__c como keys
    //y valor true si su contenido es igual al del caso original, false si es diferente.
    public static Map<String, Boolean> comparaCampos(Case casoOriginal, SAC_Genial_Resultado__c resultadoIA){
        Map<String, Boolean> comparaciones = new Map<String, Boolean>();

        SAC_Genial_Resultado__c casoOriginalFormatoGR = casteoCaseAgenialResultado(casoOriginal);
        Map<String, Object> camposCasoGR = casoOriginalFormatoGR.getPopulatedFieldsAsMap();
        Map<String, Object> camposResult = resultadoIA.getPopulatedFieldsAsMap();

        for (String nombreCampo : camposCasoGR.keySet()){
            if(nombreCampo == 'SAC_FechaRecepcion__c'){
                //comparar hasta los minutos
                if (resultadoIA.SAC_FechaRecepcion__c != null && casoOriginal.SAC_FechaRecepcion__c != null){
                    String dateRes = resultadoIA.SAC_FechaRecepcion__c.format('dd-MM-yyyy hh:mm');
                    String dateOrig = casoOriginal.SAC_FechaRecepcion__c.format('dd-MM-yyyy hh:mm');
                    if(dateRes.equals(dateOrig)){
                        comparaciones.put(nombreCampo,true);
                    } else {
                        comparaciones.put(nombreCampo,false);
                    }
                }
                else{
                    comparaciones.put(nombreCampo,false);
                }
            }
            else if(camposCasoGR.get(nombreCampo) != camposResult.get(nombreCampo)){
                comparaciones.put(nombreCampo,false);
            }
            else{
                comparaciones.put(nombreCampo,true);
            }
        }
        return comparaciones;
    }

    /*comparamos los campos para asignar unos valores a variables booleanas contenidas en el objeto*/
    public static void comparaCamposYcasteo(Case casoOriginal, SAC_Genial_Resultado__c resultadoIA){
        //Map<String, Boolean> comparaciones = new Map<String, Boolean>();

        SAC_Genial_Resultado__c casoOriginalFormatoGR = casteoCaseAgenialResultado(casoOriginal);
        Map<String, Object> camposCasoGR = casoOriginalFormatoGR.getPopulatedFieldsAsMap();
        Map<String, Object> camposResult = resultadoIA.getPopulatedFieldsAsMap();

        //para saber si el campo casteado existe en el objeto obtenemos el esquema de campos del objeto destino
        SObjectType genialType = Schema.getGlobalDescribe().get('SAC_Genial_Resultado__c');
        //obtenemos un mapa de los campos posibles del objeto para saber si el campo existe al construir su API name
        Map<String,Schema.SObjectField> camposGenial = genialType.getDescribe().fields.getMap();
        
        for (String nombreCampo : camposCasoGR.keySet()){
            

            if(nombreCampo.right(3) == '__c'){
                list<string> cabecera = nombreCampo.split('__c');
                //el campo booleano se llamará igual con el añadido
                string nombreCampoBooleano = cabecera[0] + '_OK__c';
                if(!camposGenial.containsKey(nombreCampoBooleano)){
                    continue;
                }
                ////comparaciones.put(nombreCampo,false);
                // if(nombreCampo == 'SAC_FechaRecepcion__c'){
                //     //comparar hasta los minutos
                //     if (resultadoIA.SAC_FechaRecepcion__c != null && casoOriginal.SAC_FechaRecepcion__c != null){
                //         String dateRes = resultadoIA.SAC_FechaRecepcion__c.format('dd-MM-yyyy hh:mm');
                //         String dateOrig = casoOriginal.SAC_FechaRecepcion__c.format('dd-MM-yyyy hh:mm');
                //         if(dateRes.equals(dateOrig)){
                //             resultadoIA.put(nombreCampoBooleano, true);
                //         } else {
                //             resultadoIA.put(nombreCampoBooleano, false);
                //         }
                //     }
                //     else{
                //         resultadoIA.put(nombreCampoBooleano, false);
                //     }
                // }
                if(camposCasoGR.get(nombreCampo) != camposResult.get(nombreCampo)){
                    resultadoIA.put(nombreCampoBooleano, false);
                } else {
                    resultadoIA.put(nombreCampoBooleano, true);
                }
            }
            /*else{
                comparaciones.put(nombreCampo,true);
            }*/
        }
    }

    /*
    * Programa la comunicación con azure o la envía directamente según la configuración del
    * campo SAC_DelayEnvio__c guardado en el custom setting SAC_GenialSettingsCanal__c
    * Entradas: reclamacionId
                canal -> canal de comunicación necesario ya que la configuración es dependiente del canal
                description -> body del email/formulario
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0                             Alex Perez      07/05/24     Creación 
    * 2.0            US976182         Borja Lavesiera 26/07/2024   Adaptación para balanceador integraciones
    * 2.1            US967489         Alex Perez      06/08/2024   Llamadas al queueable/schedulable de OpenServices
    */
    public static void programarEnviar(id reclamacionId, string canal, string description, string typeOfIntegration){
        SAC_GenialSettingsCanal__c  settings = SAC_GenialSettingsCanal__c.getInstance(canal);
        if(settings.SAC_DelayEnvio__c == null || settings.SAC_DelayEnvio__c == 0){
            if(typeOfIntegration == 'Azure') {
                SAC_GenialSendAzure.sendToIA(reclamacionId, description);
            } else if(typeOfIntegration == 'OpenServices') {
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(reclamacionId)
                                        .addString('progEnv')
                                        .build();
                //System.enqueueJob(new SAC_GenialOpenServices_Queueable(null, null, reclamacionId), options);
                System.enqueueJob(new SAC_GenialOpenServices_Queueable(new list<id>{reclamacionId}), options);
            }
        } else {
            CBK_SCH_PendingProcess__c pendingProcessConsultaCopia = new CBK_SCH_PendingProcess__c();
            list<sObject> insertarPending = new list<sObject>();
            pendingProcessConsultaCopia.recordId__c = reclamacionId;
            pendingProcessConsultaCopia.Schedule_Time__c = system.now().addSeconds(integer.valueOf(settings.SAC_DelayEnvio__c));
            pendingProcessConsultaCopia.className__c = 'SAC_GenialScheEnvioIntegracion';
            pendingProcessConsultaCopia.param1__c = typeOfIntegration;
            /* if(typeOfIntegration == 'Azure') {
                //pendingProcessConsultaCopia.className__c = 'SAC_GenialScheSendAzure';
                pendingProcessConsultaCopia.param1__c = 'Azure';
            } else if(typeOfIntegration == 'OpenServices') {
                //System.debug('Se llamará a la clase integradora de OpenServices mediante Framework con Delay.');
                //pendingProcessConsultaCopia.className__c = 'SAC_GenialScheSendAzure';
                pendingProcessConsultaCopia.param1__c = 'Azure';
            } */
            insertarPending.add((sObject)pendingProcessConsultaCopia);
            modificarInsertarObjetos(insertarPending, 'insert');
        }
    }


    /*Método general para la inserción o modificación de datos con tratamiento de errores 
    * Entradas: obj -> lista de objetos en formato sObject
    *           operacion -> insert/update
    * Salida: integer -> numero de operaciones realizadas con éxito
    Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0                             Alex Perez      07/05/24     Creación          
    */
    public static integer modificarInsertarObjetos(list<sObject> obj, string operacion){
        Database.SaveResult[] srList;
        boolean hasError = false;
        List<Object> errorObjs = new List<Object>();
        Map<String, String> errorMsjs = new Map<String, String>();
        //conteo operaciones con exito
        integer registrosOK = 0;
        if(operacion == 'insert'){
            //unificar los dos bucles de errores en 1
            srList = Database.insert(obj, false);
            for (Integer i = 0; i < obj.size(); i++) {
                Database.SaveResult sr = srList[i];
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    errorMsjs.put(sr.getErrors()[0].getStatusCode() + '', ((String)sr.getErrors()[0].getMessage()));
                    errorObjs.add(obj[i]);
                    hasError = true;
                } else {
                    registrosOK++;
                }
            }
        } else {
            //update obj;
            srList = Database.update(obj, false);
            for (Integer i = 0; i < obj.size(); i++) {
                //unificar los dos bucles de errores en 1
                Database.SaveResult sr = srList[i];
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    errorMsjs.put(obj[i].Id, ((String)sr.getErrors()[0].getMessage()));
                    errorObjs.add(obj[i]);
                    hasError = true;
                } else {
                    registrosOK++;
                }
            } 
        }
        if(hasError) {
            CBK_Log.error(errorMsjs, errorObjs);
        }

        return registrosOK;
    }
    /*Método para balancear la integración a distintos sistemas en función del Custom Settings SAC_GenialSettingsCanal__c
    *Historial
    * -------
    * VERSION        USER_STORY       AUTHOR             DATE         Description
    * 1.0                             Borja Lavesiera    19/07/24     Creación          
    */
    public static void balanceador (id reclamacionId, string canal, string description) {
        try {
            // Encolar el trabajo para procesar la lógica
            SAC_GenialBalanceador.enqueueJob(reclamacionId, canal, description);
        } catch (Exception e) {
            CBK_Log.error('The following exception has occurred: ' + e.getMessage());
        }
    }
     /*****************************************************************
     * @description: En este método se calcula la Fecha Vencimiento SLA mediante el SLA Regulatorio del caso IA
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR            DATE         Description
     * 1.0            US967476         Borja Lavesiera   12/08/24     Creación
     *****************************************************************/
    public static DateTime calculateMilestoneTriggerTime(Case caso) {
        // Obtener record Type
        Set<String> objetos = new Set<String>{'Case'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

        Integer retornarDias = 30;
        Integer masDiaHabil = 0;
        Integer diasProrroga = 0;
        Datetime fechaFin = null;
        Datetime fechaInicial; 
        Id ideBH;

        if (Schema.sObjectType.Case.isAccessible()) {

            retornarDias = calcularDiasARetornar(caso, recTypeReclamacion, recTypePretension);

            if (Cache.Org.contains('local.SAC.SACCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SAC_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }

            /*Calculo de 1 mes:
            Se empieza a contar desde el siguiente día hábil a la fecha de recepción y será el mismo día del mes siguiente (ejemplo: 26/10-->26/11)
            En caso que el mes en curso tengas más días que mes siguiente (enero, marzo, mayo, agosto, octubre) la fecha fin será el último día del mes siguiente, si es hábil, y si no será el siguiente. (Por ejemplo: 29/01→28/02; 31/03-->30/04)
            Fecha inicio cálculo de SLA Regulatorio: Será el día siguiente hábil a la fecha de recepción. Ejemplo: Fecha recepción: 29/10/21→ Fecha inicio calculo:02/11/21
            Fecha fin SLA Regulatorio: Será el primer día hábil según el cálculo anterior. En caso que caiga en festivo o fin de semana pasará al siguiente día hábil
            Día hábil: Será cualquier día que no sea fin de semana o festivo nacional
            En caso del cálculo de 2 meses (no consumidores en el picklist SAC_TipoConsumidor__c) se aplicará las mismas reglas anteriores pero con dos meses
            */
            
            if(retornarDias == 30){ 
                //US347830 Según el campo consumidor la SLA tendrá diferentes tiempos:  Persona física consumidor: SLA Regulatorio (1 mes) Persona física no consumidor (autónomo): 2 meses desde la fecha inicio cálculo
                
                masDiaHabil = 1;
                Integer mesesAnadir = calcularMesesAnadir(caso); 
                fechaInicial = calcularFechaInicial(caso);

                //Para empezar a contar desde el siguiente día hábil a la fecha de recepción debemos comprobar que es día hábil 
                fechaInicial = fechaInicial.addDays(1);
                while(!BusinessHours.isWithin(ideBH, fechaInicial)) {  //Es día hábil? 
                    fechaInicial = fechaInicial.addDays(1); 
                }
                
                //Calculamos la fecha final del SLA regulatorio
                fechaFin = fechaInicial.addMonths(mesesAnadir);
                Boolean esDiaHabil = BusinessHours.isWithin(ideBH, fechaFin);

                if(!esDiaHabil){//Si no entra en horario de BH necesitamos calcular el siguiente día hábil                    
                    fechaFin = BusinessHours.nextStartDate(ideBH, fechaFin); 
                } 
                 
                //Calcula la diferencia que hay de la fecha incial y la fecha fin con la condiciones antes mencionadas
                Long diferencia = BusinessHours.diff(ideBH, fechaInicial, fechaFin); 

                //Calcular el número de días dados los milisegundos que se han calculado anteriormente
                Double numeroDias = ((Double) diferencia)/(1440*60*1000);
                //numeroDias = numeroDias.round();
                Decimal numeroDias2 = (Decimal)numeroDias;
                Decimal numeroDias3 = numeroDias2 - (numeroDias2.round(System.RoundingMode.DOWN));

                if (numeroDias3>0) { //Para hacer el calculo de añadir días enteros
                    numeroDias++; 
                } 
                retornarDias = numeroDias.intValue();

                fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(retornarDias)); 
                
            }else{ 
                fechaInicial = calcularFechaInicial(caso); 
                fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(retornarDias));
            }
        }
       
        /** Se vuelven a cambiar las BBHH de 10 a 24 horas (Antes se tenia una horario de 8:00 - 18:00)*/
        Integer tiempoTotal = (retornarDias + masDiaHabil + diasProrroga) * 1440; //se hacia la mulplicación por 1440 cuando eran días de 24 horas 
        
        //el ultimo + masDiaHabil es para que agregue el día hábil ya que los Milestones hacen los calculos desde la fecha de recepcion será uno cuando
        //tenga que calcular el mes pero será 0 cuando encuentre las parametrizaciones de junta de andalucia, castilla la mancha y PSD2 sin prorrogar
        //tiempoTotal = (retornarDias + tiempoProrroga) * 600; // ahora con las Business Hour los días son de 10 horas es decir 600 minutos
        system.debug('@@tiempoTotal'+tiempoTotal);
        system.debug('@@fechaFin'+fechaFin);
        system.debug('@@caso.SAC_FechaVencimientoSLA__c'+caso.SAC_FechaVencimientoSLA__c);
        if(caso.SAC_FechaVencimientoSLA__c != fechaFin){
            system.debug('@@Entra en fecha fin' +fechaFin);
            return fechaFin;
        }
        return null;      
    }

    /********************************************************************************************
     * @description	: calculo de Meses en función de los campos Consumidor y prorroga 
     * 
     * US347830 Según el campo consumidor la SLA tendrá diferentes tiempos:
     * Persona física consumidor: SLA Regulatorio (1 mes)
     * Persona física no consumidor (autónomo): 2 meses desde la fecha inicio cálculo
     * 
     ********************************************************************************************/
    public static Integer calcularMesesAnadir(Case caso) {

        Integer mesesAnadir = 0;

        if(caso.SAC_TipoConsumidor__c == 'Si' || caso.SAC_Reclamacion__r.SAC_TipoConsumidor__c =='Si' || caso.SAC_Prorrogado__c){
            mesesAnadir = 1;
        }else if(caso.SAC_TipoConsumidor__c == 'No' || caso.SAC_Reclamacion__r.SAC_TipoConsumidor__c =='No'){
            mesesAnadir = 2;
        }else if(String.isBlank(caso.SAC_TipoConsumidor__c) || String.isBlank(caso.SAC_Reclamacion__r.SAC_TipoConsumidor__c)){
            mesesAnadir = 2;
        }
        return mesesAnadir;
    }


    /********************************************************************************************
     * @description	calculo de días 
     * Método: calcularDiasARetornar
     * 
     * DE64525 MOD MNR 30/08/2022 La prórroga es de 1 mes y no 30 días hábiles, así que se retorna un 30 para que se calcule 
     * con las reglas del mes, que estan especificadas abajo.
     * 
     ********************************************************************************************/
    public static Integer calcularDiasARetornar(Case caso, Id recTypeReclamacion, Id recTypePretension) {

        Integer retornarDias = 30;

        if (caso != null && (caso.RecordTypeId == recTypeReclamacion || caso.RecordTypeId == recTypePretension)) {
            if(caso.SAC_TiempoSLARegulatorio__c != null ){
                retornarDias = Integer.valueOf(caso.SAC_TiempoSLARegulatorio__c);
            }               
        }
        return retornarDias;
    }

    /**********************************************************************************************
    * @description	calculo fecha inicial
    * 
    * Rellenamos una fecha inicial porque cuando se hace una copia de una reclamación vinculada se ha 
    * pedido que la SAC_FechaRecepcion__c esté en blanco
    *
    *
    ***********************************************************************************************/

    public static Datetime calcularFechaInicial(Case caso) {
        
        Datetime fechaInicial; 
        if(caso.SAC_FechaRecepcion__c == null){
            fechaInicial = System.now();
        }else{
            fechaInicial = caso.SAC_FechaRecepcion__c;
        }
        return fechaInicial;
    }
    /**********************************************************************************************
    * @description	calculo milisegundos
    * 
    * Método adicional para milisegundos de los días recibidos por parámetro
    *
    ***********************************************************************************************/
    public static Long calcularMilisegundos(Integer dias) {
 
        //Por errores del campo long, la multiplicación por 1000 se pasa a concatenar el resultado más tres ceros en forma de String
        Integer resultado; 

        resultado = dias*24*60*60;
        //resultado = (dias*24*60*60*1000); Esta multiplicación es la que hace que el Long aparezca como valor negativo (es un error?)
        //Por eso se hace con un String y se devuelve con un Long.valueOf()
        String num = resultado + '000';
 
        return Long.valueOf(num);
    }
}