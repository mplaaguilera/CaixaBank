/*****************************************************************
 * Name: SAC_Balanceo
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Tratar el balanceo de los casos, asignando un owner al caso
 * o un grupo dependiendo de los porcentajes de asignación de este.
 * Esta clase se lanza en el before insert y el before update del objeto caso.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213183         Carlos Solis   6/05/21      Creación
 * 2.0            US270297         Marcela Neira  10/09/21     Optimización de los métodos y
 *                                 Esteve  Llaó                revisión del trigger de Case
*****************************************************************/
public without sharing class SAC_Balanceo {

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPECONSULTA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
    
    /*****************************************************************
     * Proposito: Cambio owner en la Reclamación se tiene que cambiar todas las 
     *            reclamaciones con esa misma cuenta a ese Usuario
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   6/05/21      Creación
    *****************************************************************/
    public static void asignarCasosAlOwner (List<Case> listaCasos /**Query */, List<Case> listNewCaseAsignarCasosAlOwner, List<Id> listaIdsCuentas, Map<Id,Case> mapaDatosCasosActualizar) {
       
        Map<Id,List<Case>> mapaListCasos = new Map<Id,List<Case>>(); 
        List<case> listaCasos2 = new List<case>();

        Map<Id,List<Case>> mapaListConsultas= new Map<Id,List<Case>>(); 
        List<case> listaConsultas = new List<case>();

        for (Id ide: listaIdsCuentas) {
            list<case> listaAux = new list<case>();
            mapaListCasos.put(ide,listaAux );
            mapaListConsultas.put(ide,listaAux );           
        }
        for (Case caso : listaCasos) {            
            if(mapaListCasos.containsKey(caso.AccountId) && caso.RecordTypeId == RECTYPERECLAMACION  && !caso.isClosed ){
                mapaListCasos.get(caso.AccountId).add(caso);
            }  
            if(mapaListCasos.containsKey(caso.AccountId) && caso.RecordTypeId == RECTYPECONSULTA  && !caso.isClosed ){    
                mapaListConsultas.get(caso.AccountId).add(caso);
            }  
        }
        for( ID ide : mapaListCasos.keySet()){ 
            listaCasos2.addAll(mapaListCasos.get(ide) );        
        } 
        for( ID ide : mapaListConsultas.keySet()){ 
            listaCasos2.addAll(mapaListConsultas.get(ide) );        
        }   

        Map<Id, Case> mapaCasos = new Map<Id, Case>();
        List<Case> casosParaUpdatear = new List<Case>();
 
        for (Case caso : listNewCaseAsignarCasosAlOwner) {
            mapaCasos.put(caso.AccountId, caso);
        }
 
        for (Case caso : listaCasos2) {
            if (mapaCasos.containsKey(caso.AccountId)) {
                caso.OwnerId = mapaCasos.get(caso.AccountId).OwnerId;
                caso.SEG_Grupo__c = mapaCasos.get(caso.AccountId).SEG_Grupo__c;
                casosParaUpdatear.add(caso);
            }
        }
        
        for(Case caso : casosParaUpdatear){
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).OwnerId = caso.OwnerId;
                mapaDatosCasosActualizar.get(caso.id).SEG_Grupo__c = caso.SEG_Grupo__c;
            }else{
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
        }
    }

    /*****************************************************************
     * Proposito:  Al cambiar el AccountId de un caso comprueba si existen más casos (que estan abiertos) con ese AccountId
     * si encuentra coincidencias, cambia el owner y pone el owner que lleva esos casos con ese cliente
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   6/05/21      Creación
    *****************************************************************/
    public static List<Case> asignarOwnerCaso (List<Case> listaCasos, List<Case> listNewCase, list<Id> listaIdsCuentas) {
        
        Map<Id,List<Case>> mapaCasos = new Map<Id,List<Case>>(); 
        List<case> listaCasos2 = new List<case>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        for (Id ide: listaIdsCuentas) {
            list<case> listaAux = new list<case>();
            mapaCasos.put(ide,listaAux );            
        }
        for (Case caso : listaCasos) {            
            if(mapaCasos.containsKey(caso.AccountId) && caso.RecordTypeId == RECTYPERECLAMACION  && !caso.isClosed ){
                mapaCasos.get(caso.AccountId).add(caso);
            }        
        }
        for( ID ide : mapaCasos.keySet()){ 
            listaCasos2.addAll(mapaCasos.get(ide) );         
        }
        
        List<Case> listaCasosNoTratados = new List<Case>();
        Map<Id, Id> mapaIdOwner = new Map<Id, Id>();
        Map<Id, Id> mapaIdGrupo = new Map<Id, Id>();

        for (Case caso : listaCasos2) {
            mapaIdOwner.put(caso.AccountId, caso.OwnerId);
            mapaIdGrupo.put(caso.AccountId, caso.SEG_Grupo__c);
        }

        for (Case caso : listNewCase) {
            if (mapaIdOwner.containsKey(caso.AccountId)) {
                caso.OwnerId = mapaIdOwner.get(caso.AccountId);
                caso.SEG_Grupo__c = mapaIdGrupo.get(caso.AccountId);
                //Notifico a estos usuarios de que se les ha asignado un nuevo caso
                if (String.isNotBlank(caso.Id)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                        'SAC_NuevoPropietarioCasoOwner',
                                                                        'El caso ' + caso.CaseNumber + ' ha pasado a ser de tu propiedad!',
                                                                        caso.OwnerId,
                                                                        '',
                                                                        '',
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);

                    /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                    SAC_Notificacion.enviarNotificacion(caso.OwnerId,
                    caso.Id,
                    ' Cambio de propietario en el caso ' + caso.CaseNumber,
                    'El caso ' + caso.CaseNumber + ' ha pasado a ser de tu propiedad!');*/   
                }
            } else {
                listaCasosNoTratados.add(caso);
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }

        return listaCasosNoTratados;
    }

    /*****************************************************************
     * Proposito: Método para asignar un grupo a los casos que entran nuevos al sistema cada dia.
     * Asigna un grupo u otro dependiendo del porcentaje de asignacion de cada grupo y de cuan llenos estan,
     * respetando el máximo de casos que puede tener cada grupo al dia. Cuando todos superan su máximo diario, vuelve a empezar con 
     * las reglas de asignacion de porcentajes sin tener en cuenta el máximo diario.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   6/05/21      Creación
    *****************************************************************/
    public static void balanceoGrupos(List<Case> listaNewCase, Group cola){
        //RecordTypesIds
        Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        //Listas
        List<AggregateResult> listaCasos = new List<AggregateResult>();
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        if (Schema.sObjectType.Case.isAccessible()) {
            listaCasos = [select count(Id)countCasos, SEG_Grupo__c from Case
                         where RecordTypeId = :RECTYPERECLAMACION
                         and createdDate = today
                         group by SEG_Grupo__c];
        }
        if (Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()) {
            listaGrupos = [select id, name, SAC_PorcentajeAsignacion__c, SAC_MaximoCasosDiarios__c from CC_Grupo_Colaborador__c
                          where RecordTypeId = :recTypeProveedores
                          and SAC_PorcentajeAsignacion__c > 0];
        }
        //Mapa de los grupos
        Map<Id, CC_Grupo_Colaborador__c> mapGrupos = new Map<Id, CC_Grupo_Colaborador__c>();

        //Asignacion del mapa que contiene todos los grupos
        for (CC_Grupo_Colaborador__c grupo : listaGrupos) {
            mapGrupos.put(grupo.id, grupo);
        }
        
        //Asigno casos a los grupos que no tengan ningun caso y retorno un booleano para saber si ya tienen todos algun caso
        Boolean todosLosGruposTienenCaso = rellenarGruposVacios(listaCasos, mapGrupos, listaNewCase, cola);

        //Si todos los grupos tienen al menos un caso, empiezo con la asignación de grupos al caso dependiendo de sus porcentajes
        if (todosLosGruposTienenCaso) {
            asignarCasoConBalanceoPorcentaje(listaCasos, mapGrupos, listaNewCase, cola);
        }
    }

    /*****************************************************************
     * Proposito: Método para recuperar el numero total de casos que hay que tener en cuenta para los calculos de asignación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   6/05/21      Creación
    *****************************************************************/
    private static Integer recuperarTotalCasos(List<AggregateResult> listaCasos, Map<Id, CC_Grupo_Colaborador__c> mapGrupos) {
        Integer totalCasos = 0;
        Integer totalDeMaximos = 0;

        for (AggregateResult caso : listaCasos) {
            if (mapGrupos.containsKey(String.valueOf(caso.get('SEG_Grupo__c')))) {
                totalCasos += Integer.valueOf(caso.get('countCasos'));
                totalDeMaximos += Integer.valueOf(mapGrupos.get(String.valueOf(caso.get('SEG_Grupo__c'))).SAC_MaximoCasosDiarios__c);
            }
        }
        //Compruebo si todos los grupos estan en su máxima capacidad de casos diarios.
        //Si lo están, lo indico en el booleano y paso a asignar el nuevo valor al total de casos.
        //Este nuevo valor es igual a el total de casos menos el campo SAC_MaximoDiarios__c de todos los grupos.
        Boolean todosLosGruposLLenos = comprobarGruposEnMaximaCapacidad(listaCasos, mapGrupos);
        if (todosLosGruposLLenos) {
            totalCasos = totalCasos - totalDeMaximos + 1;
        }
        return totalCasos;
    }

    /*****************************************************************
     * Proposito: Método para comprobar si todos los grupos han llegado a su máximo de capacidad diaria
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   6/05/21      Creación
    *****************************************************************/
    private static Boolean comprobarGruposEnMaximaCapacidad(List<AggregateResult> listaCasos, Map<Id, CC_Grupo_Colaborador__c> mapGrupos) {
        //Mapa con los grupos que ya han superado el máximo de casos diarios
        Map<Id, Boolean> mapaGruposEnMaximaCapacidad = new Map<Id, Boolean>();
        //Boolean para indicar cuando todos los grupos esten en su maxima capacidad
        Boolean todosLosGruposLLenos = false;
        for (AggregateResult caso : listaCasos) {
            if (mapGrupos.containsKey(String.valueOf(caso.get('SEG_Grupo__c')))) {
                if (mapGrupos.get(String.valueOf(caso.get('SEG_Grupo__c'))).SAC_MaximoCasosDiarios__c <= Integer.valueOf(caso.get('countCasos'))) {
                    mapaGruposEnMaximaCapacidad.put(String.valueOf(caso.get('SEG_Grupo__c')), true);
                }
            }
        }
        //Compruebo si todos los grupos estan en su máxima capacidad de casos diarios.
        if (mapaGruposEnMaximaCapacidad.size() == mapGrupos.size()) {
            todosLosGruposLLenos = true;
        }
        return todosLosGruposLLenos;
    }

    /*****************************************************************
     * Proposito: Método para asignar casos primero a los grupos que aun no tengan ningun caso asignado.
     * Retorna un boleano para indicar si todos los grupos tienen algun caso asignado o si aún no.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   6/05/21      Creación
    *****************************************************************/
    private static Boolean rellenarGruposVacios(List<AggregateResult> listaCasos, Map<Id, CC_Grupo_Colaborador__c> mapGrupos, List<Case> listaNewCase, Group cola) {
        //Mapa con id del grupo y boleano para indicar si posee o no algun caso
        Map<Id, Boolean> mapaGruposConCasos = new Map<Id, Boolean>();
        //Asignacion del mapa que contiene si el grupo tiene algun caso
        for (Id idGrupo : mapGrupos.keySet()) {
            mapaGruposConCasos.put(idGrupo, false); //Los inicio todos en falso
        }
        //Comprobar que grupos tienen al menos un caso y lo indico con un true
        for (AggregateResult caso : listaCasos) {
            if (mapaGruposConCasos.containsKey(String.valueOf(caso.get('SEG_Grupo__c')))) {
                mapaGruposConCasos.put(String.valueOf(caso.get('SEG_Grupo__c')), true);
            }
        }
        
        //Si el grupo no tiene ningun caso, le añado el caso del trigger new.
        //De lo contrario, indico en una nueva lista que ese grupo ya tiene al menos un caso
        set<id> keysMapaGruposConCasos = mapaGruposConCasos.keySet();
        List<String> listaGruposConCaso = new List<String>();
        Boolean todosLosGruposTienenCaso = false;
        for (id key : keysMapaGruposConCasos) {
            if (!mapaGruposConCasos.get(key)) {
                for (Case newCase : listaNewCase) {
                    newCase.SEG_Grupo__c = key;
                    if (!Test.isRunningTest()) {
                        newCase.OwnerId = cola.id;  
                    }
                }
            } else {
                listaGruposConCaso.add('El grupo : ' + key + ' ya tiene un caso');
            }
        }
        //Si todos los grupos tienen al menos un caso, lo indico en un boleano y lo retorno
        if (listaGruposConCaso.size() == mapaGruposConCasos.size()) {
            todosLosGruposTienenCaso = true;
        }
        return todosLosGruposTienenCaso;
    }

    /*****************************************************************
     * Proposito: Método para asignar los casos a el grupo que más capacidad tenga acorde a sus porcentajes de asignación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   6/05/21      Creación
    *****************************************************************/
    private static void asignarCasoConBalanceoPorcentaje(List<AggregateResult> listaCasos, Map<Id, CC_Grupo_Colaborador__c> mapGrupos, List<Case> listaNewCase, Group cola) {        
        //Asignación de valores en el total de casos y comprobacion de la capacidad maxima de cada grupo
        Integer totalCasos = recuperarTotalCasos(listaCasos, mapGrupos);
        //Boolean para indicar cuando todos los grupos esten en su maxima capacidad
        Boolean todosLosGruposLLenos = comprobarGruposEnMaximaCapacidad(listaCasos, mapGrupos);

        Decimal porcentajeActual = 0;
        Decimal desviacion = -100;
        Id grupoAsociado = null;
        for (AggregateResult caso : listaCasos) {
            if (mapGrupos.containsKey(String.valueOf(caso.get('SEG_Grupo__c')))) {
                if (!todosLosGruposLLenos) { //Si no estan todos los grupos en su máxima capacidad de casos diarios, calculo el porcentaje actual normalmente
                    porcentajeActual = ((Integer.valueOf(caso.get('countCasos')) * 100) / totalCasos);
                } else { //De lo contrario, calculo el porcentaje actual restando el valor de el maximo de casos diarios y con el valor del nuevo totalCasos
                    porcentajeActual = (Integer.valueOf(caso.get('CountCasos')) - Integer.valueOf(mapGrupos.get(String.valueOf(caso.get('SEG_Grupo__c'))).SAC_MaximoCasosDiarios__c)) * 100 / totalCasos;
                }
                    if ((mapGrupos.get(String.valueOf(caso.get('SEG_Grupo__c'))).SAC_PorcentajeAsignacion__c - porcentajeActual) > desviacion 
                        && (todosLosGruposLLenos || mapGrupos.get(String.valueOf(caso.get('SEG_Grupo__c'))).SAC_MaximoCasosDiarios__c > Integer.valueOf(caso.get('countCasos')))) {
                    desviacion = mapGrupos.get(String.valueOf(caso.get('SEG_Grupo__c'))).SAC_PorcentajeAsignacion__c - porcentajeActual;
                    grupoAsociado = String.valueOf(caso.get('SEG_Grupo__c'));
                }
            }
        }
        for (Case newCase : listaNewCase) {
            newCase.SEG_Grupo__c = grupoAsociado;
            if (!Test.isRunningTest()) {
                newCase.OwnerId = cola.id;  
            }
        }
    }
}