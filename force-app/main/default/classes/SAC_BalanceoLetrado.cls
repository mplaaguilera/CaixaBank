/*****************************************************************
 * Name: SAC_BalanceoLetrado
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Tratar el balanceo de las pretensiones, asignando un owner y grupo al caso
 * dependiendo de los porcentajes de asignación de este.
 * Esta clase se lanza en el before update del objeto caso.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US204898         Nicolás García 4/06/21      Creación
 * 1.1            US277148         Luis Mesa      1/12/21      Modificación
 * 1.2            US520791         Raúl Santos    30/05/23     Modificación: balanceo de letrado por Marca
 * 1.3            US488768         Raúl Santos    29/09723     Modificación: balanceo por importe MCC y organizar balanceo en métodos
*****************************************************************/
public without sharing class SAC_BalanceoLetrado {

    private static Set<String> objetos = new Set<String>{'Case','CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();   
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId(); 
    private static final Id RECTYPEGRUPOLETRADO = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();
    private static final String RECTYPEGRUPOLETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();
    


    public static void determinarOwner(List<Case> listSelect, List<Case> reclamaciones, Map<Id, Case> mapaDatosCasosActualizar, Group cola) {
        
        //Cogemos la primera reclamación, porque a pesar de recibir una lista, el cambio de estado de 'Alta' a 'Analisis' solo pude hacerse por la botonera (debido a una validation rule), por lo tanto solo entrará una reclamación
        Case reclamacion = reclamaciones[0];

        List<SAC_Marca_Case__c> marcasReclamacion = [SELECT Id, SAC_Marca__c, SAC_Marca__r.Name, SAC_Marca__r.SAC_OrdenPrelacion__c, SAC_Marca__r.SAC_GrupoLetrado__c  FROM SAC_Marca_Case__c WHERE SAC_Case__c =: reclamacion.Id
                                                        AND SAC_Marca__r.SAC_OrdenPrelacion__c != null AND SAC_Marca__r.SAC_GrupoLetrado__c != null];

        List<CC_Grupo_Colaborador__c> listaGrupoFT = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOLETRADOS AND SAC_DeveloperName__c = 'FASTTRACK' LIMIT 1];
        
        //Si la reclamación que va a balancearse tiene marcas, el balanceo de letrado se hace por MARCA.
        if(!marcasReclamacion.isEmpty()){
            balanceoPorMarca(marcasReclamacion, listSelect, mapaDatosCasosActualizar, cola);
        }else{
            // Comprobamos si la reclamación tiene importe reclamado, si es así, posible balanceo por importe. Si no, balanceo por detalle MCC
            if(reclamacion.CC_Importe_Reclamado__c != 0){
                balanceoPorImporteMCC(reclamacion, listSelect, mapaDatosCasosActualizar, cola, listaGrupoFT);
            }else{
                balanceoPorDetalleMCC(reclamacion, listSelect, mapaDatosCasosActualizar, cola, listaGrupoFT);
            }
        }  
	}

    public static void balanceoPorMarca(List<SAC_Marca_Case__c> marcasReclamacion, List<Case> listSelect, Map<Id, Case> mapaDatosCasosActualizar, Group cola) {

        //US675863 - Comentado debido a: ante una reclamación este vinculada si tiene marca con letrado asignado debería saltarse las reglas de vinculación e ir al letrado de la marca
        //Recorremos las pretensiones para ver si la reclamación tiene una reclamación vinculada
        /*for (Case cs : listSelect) {
            //Si está relacionado con otra reclamación, debemos heredar el grupo de la reclamación relacionada
            if(cs.SAC_Reclamacion__c == reclamacion.Id && !String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && !String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c)
            && (cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.isClosed || cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.Status == 'SAC_004' || (!listaGrupoFT.isEmpty() && String.isNotBlank(listaGrupoFT[0].Id) && cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c != listaGrupoFT[0].Id))){
                grupoCasoRelacionado = cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c;
                pretensiones.add(cs);
            }
        }

        //Si stá relacionado con otra reclamación, hacemos el balanceo con el grupo de la reclamación relacionada. Sino, entran en juego las marcas
        if(!pretensiones.isEmpty()){
            balancearPretensiones(pretensiones, mapaDatosCasosActualizar, grupoCasoRelacionado, false, cola);
        }else{*/
            if(marcasReclamacion.size() == 1){
                balancearPretensiones(listSelect, mapaDatosCasosActualizar, marcasReclamacion[0].SAC_Marca__r.SAC_GrupoLetrado__c, false, cola);
            }else{
                //Cogemos como como orden minimo y marca de balanceo la priemra de la lista, y a partir de esta comparamos para ver si hay otra más prioritaria
                Decimal ordenAux = marcasReclamacion[0].SAC_Marca__r.SAC_OrdenPrelacion__c; 
                SAC_Marca_Case__c marcaBalanceo = marcasReclamacion[0];

                for(SAC_Marca_Case__c marca : marcasReclamacion){

                    //Si encontramos una marca con orden más prioritario que la actual, asignamos esta marca como la marca del balanceo.
                    if(marca.SAC_Marca__r.SAC_OrdenPrelacion__c < ordenAux){
                        ordenAux = marca.SAC_Marca__r.SAC_OrdenPrelacion__c;
                        marcaBalanceo = marca;
                    }
                }

                balancearPretensiones(listSelect, mapaDatosCasosActualizar, marcaBalanceo.SAC_Marca__r.SAC_GrupoLetrado__c, false, cola);
            }
        //}
    }

    public static void balanceoPorImporteMCC(Case reclamacion, List<Case> listSelect, Map<Id, Case> mapaDatosCasosActualizar, Group cola, List<CC_Grupo_Colaborador__c> listaGrupoFT) {

        Case pretPrincipal = null;
        List<Case> pretensiones = new List<Case>();
        Id grupoCasoRelacionado = null;
        Boolean balanceoPorImporte = false;

        //Recorremos las pretensiones para ver si la reclamación tiene una reclamación vinculada
        for (Case cs : listSelect) {
            //Si está relacionado con otra reclamación, debemos heredar el grupo de la reclamación relacionada
            //MOD 14/05/2024. US777530. Raúl Santos. Añadida condición para que haga balanceo normal (no por vinculacion) en caso de que la reclamación sea Money To Pay (SAC_M2P__c == true)
            if(cs.RecordTypeId == RECTYPEPRETENSION && cs.SAC_Reclamacion__c == reclamacion.Id && !cs.SAC_Reclamacion__r.SAC_M2P__c  && !String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && !String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c)
            && (cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.isClosed || cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.Status == 'SAC_004' || (!listaGrupoFT.isEmpty() && String.isNotBlank(listaGrupoFT[0].Id) && cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c != listaGrupoFT[0].Id))){
                grupoCasoRelacionado = cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c;
                pretensiones.add(cs);
            }

            if(cs.RecordTypeId == RECTYPEPRETENSION && cs.SAC_Reclamacion__c == reclamacion.Id && cs.Id == reclamacion.SAC_PretensionPrincipal__c){
                pretPrincipal = cs;
            }
        }

        //Si stá relacionado con otra reclamación, hacemos el balanceo con el grupo de la reclamación relacionada. Sino, entran en juego los importes del MCC
        if(!pretensiones.isEmpty()){
            balancearPretensiones(pretensiones, mapaDatosCasosActualizar, grupoCasoRelacionado, false, cola);
        }else{
            if(pretPrincipal.SEG_Detalle__r.SAC_ImporteDesdeMCC__c != null &&  pretPrincipal.SEG_Detalle__r.SAC_ImporteHastaMCC__c != null && pretPrincipal.SEG_Detalle__r.SAC_GrupoLetradoMCC__c != null && (pretPrincipal.SEG_Detalle__r.SAC_ImporteDesdeMCC__c <= reclamacion.CC_Importe_Reclamado__c && pretPrincipal.SEG_Detalle__r.SAC_ImporteHastaMCC__c >= reclamacion.CC_Importe_Reclamado__c)){
                //El importe reclamado está dentro del rango de los importes del detalle y el detalle tiene el grupo letrado informado
                grupoCasoRelacionado = pretPrincipal.SEG_Detalle__r.SAC_GrupoLetradoMCC__c;
                balanceoPorImporte = true;
            }else if(pretPrincipal.CC_MCC_Motivo__r.SAC_ImporteDesdeMCC__c != null &&  pretPrincipal.CC_MCC_Motivo__r.SAC_ImporteHastaMCC__c != null && pretPrincipal.CC_MCC_Motivo__r.SAC_GrupoLetradoMCC__c != null && (pretPrincipal.CC_MCC_Motivo__r.SAC_ImporteDesdeMCC__c <= reclamacion.CC_Importe_Reclamado__c && pretPrincipal.CC_MCC_Motivo__r.SAC_ImporteHastaMCC__c >= reclamacion.CC_Importe_Reclamado__c)){
                //El importe reclamado está dentro del rango de los importes del motivo y el motivo tiene el grupo letrado informado
                grupoCasoRelacionado = pretPrincipal.CC_MCC_Motivo__r.SAC_GrupoLetradoMCC__c;
                balanceoPorImporte = true;
            }else if(pretPrincipal.CC_MCC_ProdServ__r.SAC_ImporteDesdeMCC__c != null &&  pretPrincipal.CC_MCC_ProdServ__r.SAC_ImporteHastaMCC__c != null && pretPrincipal.CC_MCC_ProdServ__r.SAC_GrupoLetradoMCC__c != null && (pretPrincipal.CC_MCC_ProdServ__r.SAC_ImporteDesdeMCC__c <= reclamacion.CC_Importe_Reclamado__c && pretPrincipal.CC_MCC_ProdServ__r.SAC_ImporteHastaMCC__c >= reclamacion.CC_Importe_Reclamado__c)){
                //El importe reclamado está dentro del rango de los importes del producto/servicio y el producto/servicio tiene el grupo letrado informado
                grupoCasoRelacionado = pretPrincipal.CC_MCC_ProdServ__r.SAC_GrupoLetradoMCC__c;
                balanceoPorImporte = true;
            }else if(pretPrincipal.CC_MCC_Tematica__r.SAC_ImporteDesdeMCC__c != null &&  pretPrincipal.CC_MCC_Tematica__r.SAC_ImporteHastaMCC__c != null && pretPrincipal.CC_MCC_Tematica__r.SAC_GrupoLetradoMCC__c != null && (pretPrincipal.CC_MCC_Tematica__r.SAC_ImporteDesdeMCC__c <= reclamacion.CC_Importe_Reclamado__c && pretPrincipal.CC_MCC_Tematica__r.SAC_ImporteHastaMCC__c >= reclamacion.CC_Importe_Reclamado__c)){
                //El importe reclamado está dentro del rango de los importes de la tematica y la tematica tiene el grupo letrado informado
                grupoCasoRelacionado = pretPrincipal.CC_MCC_Tematica__r.SAC_GrupoLetradoMCC__c;
                balanceoPorImporte = true;
            }else{
                //Si no se cumple ninguna de las condiciones anteriores para el balanceo por importe, realizamos el balanceo por detalle MCC
                balanceoPorImporte = false;
                balanceoPorDetalleMCC(reclamacion, listSelect, mapaDatosCasosActualizar, cola, listaGrupoFT);
            }

            //Realizamos el balanceo por importe (detalle, motivo, producto/servicio o tematica)
            if(balanceoPorImporte == true){
                balancearPretensiones(listSelect, mapaDatosCasosActualizar, grupoCasoRelacionado, false, cola);
            }                    
        }
    }

    public static void balanceoPorDetalleMCC(Case reclamacion, List<Case> listSelect, Map<Id, Case> mapaDatosCasosActualizar, Group cola, List<CC_Grupo_Colaborador__c> listaGrupoFT) {

        List<Case> pretensiones = new List<Case>();
        Boolean grupoReclamacionEnd2End = false;
        Id mccPretensionPrincipal = null;
        Id mccVidaCaixa = null;
                
        //Recorremos las pretensiones entrantes
        for (Case cs : listSelect) {
            //Sólo actuaremos sobre las pretensiones hijas de las reclamaciones que han pasado de estado Alta a Análisis
            
            //MOD --> US426108 Mejora: Vinculación reclamaciones MNR 25/08/2022
            //Cuando se vincula se informa el grupo letrado en la pretensión, Cuando el grupo esté relleno no se debe balancear se añade cs.SEG_Grupo__c ==null
            //MOD 14/12/22. Si la reclamación no tiene caso relacionado, se balancea. Si tiene caso relacionado, se balancea si el relacionado está abierto (la operativa que tienen que hacer los usuarios en este caso, es convertirlo en consulta)
            //MOD 20/03/23. Añadida condición para que tambien balancee en caso de que el caso relacionado no esté en blanco y el canal de entrada (Origin) sea CC
            //MOD 24/05/2023. Añadida condición para que también balancee en caso de que el caso relacionado no esté en blanco y venga de una conversión de de una consulta COPS
            //MOD 09/06/2023. Añadida condición para que también balancee en caso de que el caso relacionado no esté en blanco y el grupo letrado de la pretension de la reclamación a la que nos vinculamos sea igual a el grupo letrado fast track (queremos que cuando sea grupo letrado fast track, siempre balancee)
            //MOD 26/04/2024. Añadida condición para que también balancee en caso de que el caso relacionado no esté en blanco y el caso relacionado no tenga pret principal (este rechazado, derivado, sea una consuta SAC...) o el grupo letrado de la pretensión principal de la reclamación relacionada esté en blanco.
            //MOD 14/05/2024. US777530. Raúl Santos. Añadida condición para que también balancee en caso de que la reclamación sea Money To Pay (SAC_M2P__c == true)
            if(cs.RecordTypeId == RECTYPEPRETENSION && cs.SAC_Reclamacion__c == reclamacion.Id && (cs.SAC_Reclamacion__r.SAC_M2P__c || String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c)
            || (String.isNotBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && (!cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.isClosed && cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.Status != 'SAC_004'))
            || (String.isNotBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && cs.Origin == 'CC') || (String.isNotBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.RecordTypeId == RECTYPECONSULTA)
            || (String.isNotBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && !listaGrupoFT.isEmpty() && String.isNotBlank(listaGrupoFT[0].Id) && cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c == listaGrupoFT[0].Id)
            || (String.isNotBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && (String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__c) || String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c))))){
                //Almacenamos la pretensión en las pretensiones de la reclamación afectada
                pretensiones.add(cs);
                //Almacenamos si el grupo de la reclamación padre es End to End
                grupoReclamacionEnd2End = cs.SAC_Reclamacion__r.SEG_Grupo__r.SAC_EndToEnd__c;

                //Almacenamos el Id del MCC correspondiente a la pretensión principal
                if(cs.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == cs.Id && String.isNotBlank(cs.SEG_Detalle__c)){
                    mccPretensionPrincipal = cs.SEG_Detalle__c;
                }
                else if(cs.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == cs.Id && String.isNotBlank(cs.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.CC_MCC_Motivo__c)){
                    mccPretensionPrincipal = cs.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.CC_MCC_Motivo__c;
                }
                
                /*Añadido VidaCaixa 5/04/22. Si la pretension es de vidacaixa, ignora la pretension principal y se balancea a el mcc de vidacaixa     SAC_007 - VidaCaixa*/
                if (cs.SAC_Entidad_Afectada__c == 'SAC_007' && String.isNotBlank(cs.SEG_Detalle__c)) {
                    mccVidaCaixa = cs.SEG_Detalle__c;
                }
            //si está relacionado con otra reclamación, heredar el grupo de la reclamación relacionada
            } //else if(!String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && !String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SEG_Grupo__c)) {
                ////MOD 14/12/22. Si la reclamacion tiene un caso relacionado, y este ya está cerrado, la pretensiopn se balancea al grupo de la pretension principal del caso relacionado 
                //Siempre hay que hacer un balanceo, a no ser que la reclamacion a la que está vinculada esté cerrada. en ese caso, se coge el mismo grupo de la pret principal
                else if(!String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__c) && !String.isBlank(cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c) && (cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.isClosed || cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.Status == 'SAC_004')) {
                    pretensiones.add(cs);
                balancearPretensiones(pretensiones, mapaDatosCasosActualizar, cs.SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c, false, cola);
            }
        }
        if (String.isNotBlank(mccVidaCaixa)) {
            mccPretensionPrincipal = mccVidaCaixa;
        }

        if (mccPretensionPrincipal != null) {
            //obtenemos todos los grupos
            Set<Id> mccs = new Set<Id>();
            List<CC_MCC_Grupo_Colaborador__c> listMccGrupos = [SELECT CC_MCC__c, CC_Grupo_Colaborador__c, SAC_PorcentajeAsignacion__c, Name, SAC_MaximoDeCasosDiarios__c
                        FROM CC_MCC_Grupo_Colaborador__c 
                        WHERE CC_MCC__c = :mccPretensionPrincipal AND SPV_Tipo_Cliente__c = 'SAC'];
            //Lista de casos por cada grupo  
            
            //mapa de Grupo colaborador - numero de pretensiones
            Map<Id, Integer> mapGrupoCasos = new Map<Id, Integer>();

            //mapa de id Grupo colaborador - grupo en si
            Map<Id, CC_MCC_Grupo_Colaborador__c> mapIdGrupo = new Map<Id, CC_MCC_Grupo_Colaborador__c>();

            //relleno las keys del mapa
            for(CC_MCC_Grupo_Colaborador__c mccGrupo : listMccGrupos){
                mapGrupoCasos.put(mccGrupo.CC_Grupo_Colaborador__c, 0);
                mapIdGrupo.put(mccGrupo.CC_Grupo_Colaborador__c, mccGrupo);
            }

            //Si se cumplen las condiciones, el balanceo es End to End, por lo que tiene que hacerse al Grupo de la reclamación padre
            Boolean balanceoEnd2End = false;
            if(grupoReclamacionEnd2End && mapGrupoCasos.keySet().contains(pretensiones[0].SAC_Reclamacion__r.SEG_Grupo__c)){
                balanceoEnd2End = true;
            }
            
            //Obtener aquellas pretensiones en las que la pretension principal de su familia tiene el mcc localizado anteriormente al obtener los grupos, ayudandonos del set<id>
            List<AggregateResult> listaCasos = [SELECT count(Id)countCasos, SEG_Grupo__c FROM Case
                        WHERE RecordTypeId = :RECTYPEPRETENSION
                        AND SEG_Grupo__c != null
                        AND (SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Detalle__c = :mccPretensionPrincipal 
                        OR SAC_Reclamacion__r.SAC_PretensionPrincipal__r.CC_MCC_Motivo__c = :mccPretensionPrincipal)
                        AND CC_Fecha_Traslado_Colaborador__c = today
                        GROUP BY SEG_Grupo__c];
            

            //relleno los valores del mapa -> tendre registros del mapa con clave - 0 o clave - numero de pretensiones
            for(AggregateResult caso : listaCasos){
                if(mapGrupoCasos.containsKey(String.valueOf(caso.get('SEG_Grupo__c')))){
                    mapGrupoCasos.put(String.valueOf(caso.get('SEG_Grupo__c')), Integer.valueOf(caso.get('countCasos')));
                }
            }
            
            //inicio calculo balanceo
            //episodio 1: obtener el total de casos
            Integer numTotalCasos = recuperarTotalCasos(mapGrupoCasos, listMccGrupos);
            
            //episodio 2: comprobar si se ha excedido el número de casos totales para los grupos ej:(tengo gestionando 50 casos y solo me puedo ocupar de 30)
            Boolean todosLosGruposLLenos = compruebaGruposLlenos(mapGrupoCasos, listMccGrupos);
            //comentar con carlos que pasa si un grupo se excede, otro no, pero el total de casos es mayor que el maximo aceptado

            //episodio 3: el calculo y decision de cual es el grupo que se va a balancear
            Decimal porcentajeActual = 0;
            Decimal desviacion = -100;
            Id grupoAsociado = null;
            for (Id grupoId : mapIdGrupo.keySet()) {
                //calculo del porcentaje actual
                if (!todosLosGruposLLenos && numTotalCasos != 0) { //Si no estan todos los grupos en su máxima capacidad de casos diarios, calculo el porcentaje actual normalmente
                    porcentajeActual = (mapGrupoCasos.get(grupoId) * 100) / numTotalCasos;
                }
                else if(!todosLosGruposLLenos && numTotalCasos == 0){
                    porcentajeActual = 0;
                }
                else{//De lo contrario, calculo el porcentaje actual restando el valor de el maximo de casos diarios y con el valor del nuevo numTotalCasos
                    porcentajeActual = (mapGrupoCasos.get(grupoId) - mapIdGrupo.get(grupoId).SAC_MaximoDeCasosDiarios__c) * 100 / numTotalCasos;
                }

                //calculo de la desviacion para saber que grupo tiene la desviacion mas grande y asignar ese grupo a las pretensiones
                if(mapIdGrupo.get(grupoId).SAC_PorcentajeAsignacion__c - porcentajeActual > desviacion  
                    && (todosLosGruposLLenos || mapIdGrupo.get(grupoId).SAC_MaximoDeCasosDiarios__c >= mapGrupoCasos.get(grupoId))
                ){
                    desviacion = mapIdGrupo.get(grupoId).SAC_PorcentajeAsignacion__c - porcentajeActual;
                    grupoAsociado = mapIdGrupo.get(grupoId).CC_Grupo_Colaborador__c;
                }
            }
            
            //episodio 4: asignar el grupo seleccionado a las pretensiones
            balancearPretensiones(pretensiones, mapaDatosCasosActualizar, grupoAsociado, balanceoEnd2End, cola);
        }
    }

    /*****************************************************************
     * Proposito: Método para recuperar el numero total de casos que hay que tener en cuenta para los calculos de asignación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         --             6/05/21      Creación
    *****************************************************************/
    private static Integer recuperarTotalCasos(Map<Id, Integer> mapGrupos, List<CC_MCC_Grupo_Colaborador__c> listMccGrupos) {
        
        Integer totalCasos = 0;
        Integer totalMaximosDiarios = 0;

        //Mapa para transversar la informacion de la lista listMccGrupos, a usar en el bucle for
        Map<Id, CC_MCC_Grupo_Colaborador__c> mapaGrupoAJunction = new Map<Id, CC_MCC_Grupo_Colaborador__c>();
        
        //Mapa para poder iterar y nutrir el mapa definido anteriormente
        Map<Id, CC_MCC_Grupo_Colaborador__c> mapaMccGrupoCol = new Map<Id, CC_MCC_Grupo_Colaborador__c>(listMccGrupos);
        for(Id grupo : mapaMccGrupoCol.keySet()){
            mapaGrupoAJunction.put(mapaMccGrupoCol.get(grupo).CC_Grupo_Colaborador__c, mapaMccGrupoCol.get(grupo));
        }

        //Bucle para comprobar los casos de los grupos y sus maximos diarios
        for(Id grupo : mapGrupos.keySet()) {
            totalCasos += mapGrupos.get(grupo);

            if(mapaGrupoAJunction.containsKey(grupo)){
                totalMaximosDiarios += Integer.valueOf(mapaGrupoAJunction.get(grupo).SAC_MaximoDeCasosDiarios__c);
            }
            else{
                throw new AuraHandledException('No existe ningún grupo asignado al MCC seleccionado');
            }
        }

        //Si todos los grupos llenos
        if (totalCasos >= totalMaximosDiarios) { 
            Boolean gruposLlenos = compruebaGruposLlenos(mapGrupos, listMccGrupos);

            if(gruposLlenos){
                totalCasos = totalCasos - totalMaximosDiarios;
            }
        }

        return totalCasos;
    }

    /*****************************************************************
     * Proposito: Método para recuperar el numero total de casos que hay que tener en cuenta para los calculos de asignación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         --             6/05/21      Creación
    *****************************************************************/
    private static Boolean compruebaGruposLlenos(Map<Id, Integer> mapGrupos, List<CC_MCC_Grupo_Colaborador__c> listMccGrupos) {
        Boolean resultado = false;

        Integer contador = 0;

        for(CC_MCC_Grupo_Colaborador__c gruposCol : listMccGrupos){
            if(mapGrupos.containsKey(gruposCol.CC_Grupo_Colaborador__c) && gruposCol.SAC_MaximoDeCasosDiarios__c < mapGrupos.get(gruposCol.CC_Grupo_Colaborador__c)){
                contador = contador + 1;
            }
        }

        if(contador == listMccGrupos.size()){
            resultado = true;
        }

        return resultado;
    }

    /*****************************************************************
     * Proposito: En caso de tener la reclamación un MCC End to End y un grupo asociado que también sea End to End, 
     * se asigna a las pretensiones el mismo grupo que tiene la reclamación sin pasar por ningún balanceo.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         --             6/05/21      Creación
    *****************************************************************/

	private static void balancearPretensiones(List<Case> pretensiones, Map<Id, Case> mapaDatosCasosActualizar, Id grupoAsociado, Boolean end2End, Group cola) {

        for(Case pretension : pretensiones){

            Id grupoFinal = null;

            if(end2End){
                grupoFinal = pretension.SAC_Reclamacion__r.SEG_Grupo__c;
            }
            else{
                grupoFinal = grupoAsociado;
            }

            if(mapaDatosCasosActualizar.containsKey(pretension.Id)){
                mapaDatosCasosActualizar.get(pretension.Id).SEG_Grupo__c = grupoFinal;
                mapaDatosCasosActualizar.get(pretension.Id).CC_Fecha_Traslado_Colaborador__c = Datetime.now();
            }
            else{
                pretension.SEG_Grupo__c = grupoFinal;
                pretension.CC_Fecha_Traslado_Colaborador__c = Datetime.now();
                mapaDatosCasosActualizar.put(pretension.Id, pretension);
            }

            pretension.OwnerId = cola.Id;

            //CS Añadido 24/08/2022. Rellenar el campo SAC_Letrado__c de la reclamacion padre
            //Añadido 23/03/2023. Rellenar el campo SAC_GrupoLetrado__c de la reclamación padre
            if (mapaDatosCasosActualizar.containsKey(pretension.SAC_Reclamacion__c)) {
                mapaDatosCasosActualizar.get(pretension.SAC_Reclamacion__c).SAC_Letrado__c = 'Pdte. Asignar';
            } else {
                Case reclamacionActualizar = new Case();
                reclamacionActualizar.Id = pretension.SAC_Reclamacion__c;
                reclamacionActualizar.SAC_Letrado__c = 'Pdte. Asignar';
                reclamacionActualizar.SAC_GrupoLetrado__c = grupoFinal;
                mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
            }
        }
	}

    /*****************************************************************
     * Proposito: Balancear las pretensiones de manera que cuando la reclamación es especial,
     * se asigne directamente a el grupo letrado que se encarga de esa especialidad (presidencia, sensible, etc)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200258         Carlos Solis   10/02/22     Creación
    *****************************************************************/
    public static void balanceoLetradoEspecial(List<Case> listaReclamacionEspecial, List<Case> listaCasosSelect, Map<Id, Case> mapaDatosCasosActualizar, Group cola) {

        //Recuperar grupos letrados que pueden tratar casos especiales (Con los respectivos checks activos)
        List<CC_Grupo_Colaborador__c> listaGruposEspeciales = [SELECT Id, SAC_Presidencia__c, SAC_Sensible__c FROM CC_Grupo_Colaborador__c 
                                                                WHERE RecordTypeId = :RECTYPEGRUPOLETRADO 
                                                                AND (SAC_Presidencia__c = true OR SAC_Sensible__c = true)];
        //Almacenar la id de cada grupo letrado especial                                                                
        Id grupoLetradoPresidencia;
        Id grupoLetradoSensible;
        if (!listaGruposEspeciales.isempty()) {
            for (CC_Grupo_Colaborador__c grupo : listaGruposEspeciales) {
                if (grupo.SAC_Presidencia__c) {
                    grupoLetradoPresidencia = grupo.Id;
                }
                if (grupo.SAC_Sensible__c) {
                    grupoLetradoSensible = grupo.Id;
                }
            }
        }
        
        //Mapa para las reclamaciones de presidencia
        Map<Id, Case> mapaReclamacionesPresidencia = new Map<Id, Case>();
        //Mapa para las reclamaciones sensibles
        Map<Id, Case> mapaReclamacionesSensibles = new Map<Id, Case>();
        //Rellenar mapas
        for (Case reclamacion : listaReclamacionEspecial) {
            if (reclamacion.SAC_CasoEspecial__c == 'SAC_Presidencia') {
                mapaReclamacionesPresidencia.put(reclamacion.Id, reclamacion);
            }
            if (reclamacion.SAC_CasoEspecial__c == 'SAC_Sensible') {
                mapaReclamacionesSensibles.put(reclamacion.Id, reclamacion);
            }
        }

        //Asignación de grupos
        for (Case caso : listaCasosSelect) {
            //Si es pretension y su padre se encuentra en el mapa de presidencia, le asigno el grupo que se encarga de presidencia (si existe)
            if (caso.recordTypeId == RECTYPEPRETENSION && mapaReclamacionesPresidencia.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaDatosCasosActualizar.containsKey(caso.Id) && String.isNotBlank(grupoLetradoPresidencia)) {
                    mapaDatosCasosActualizar.get(caso.Id).SEG_Grupo__c = grupoLetradoPresidencia;
                    mapaDatosCasosActualizar.get(caso.Id).OwnerId = cola.Id;
                } else if (!mapaDatosCasosActualizar.containsKey(caso.Id) && String.isNotBlank(grupoLetradoPresidencia)) {
                    caso.SEG_Grupo__c = grupoLetradoPresidencia;
                    caso.OwnerId = cola.Id;
                    mapaDatosCasosActualizar.put(caso.Id, caso);
                }
                //Añadido 23/03/2023 Se rellena el campo SAC_GrupoLetrado__c de la reclamación padre y también se updatea
                if (mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaDatosCasosActualizar.get(caso.SAC_Reclamacion__c).SAC_GrupoLetrado__c = grupoLetradoPresidencia;
                } else {
                    Case rec = new Case();
                    rec.Id = caso.SAC_Reclamacion__c;
                    rec.SAC_GrupoLetrado__c = grupoLetradoPresidencia;
                    mapaDatosCasosActualizar.put(rec.Id, rec);
                }
            }
            //Si es pretension y su padre se encuentra en el mapa de casos sensibles, le asigno el grupo que se encarga de los casos sensibles (si existe)
            if (caso.recordTypeId == RECTYPEPRETENSION && mapaReclamacionesSensibles.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaDatosCasosActualizar.containsKey(caso.Id) && String.isNotBlank(grupoLetradoSensible)) {
                    mapaDatosCasosActualizar.get(caso.Id).SEG_Grupo__c = grupoLetradoSensible;
                    mapaDatosCasosActualizar.get(caso.Id).OwnerId = cola.Id;
                } else if (!mapaDatosCasosActualizar.containsKey(caso.Id) && String.isNotBlank(grupoLetradoSensible)) {
                    caso.SEG_Grupo__c = grupoLetradoSensible;
                    caso.OwnerId = cola.Id;
                    mapaDatosCasosActualizar.put(caso.Id, caso);
                }
                //Añadido 23/03/2023 Se rellena el campo SAC_GrupoLetrado__c de la reclamación padre y también se updatea
                if (mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaDatosCasosActualizar.get(caso.SAC_Reclamacion__c).SAC_GrupoLetrado__c = grupoLetradoSensible;
                } else {
                    Case rec = new Case();
                    rec.Id = caso.SAC_Reclamacion__c;
                    rec.SAC_GrupoLetrado__c = grupoLetradoSensible;
                    mapaDatosCasosActualizar.put(rec.Id, rec);
                }
            }
        }
    }
}