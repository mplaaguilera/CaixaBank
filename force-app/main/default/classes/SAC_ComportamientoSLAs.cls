/*****************************************************************
 * Name: SAC_ComportamientoSLAs
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Tratar el comportamiento de las SLAs. Pausar y reanudar sus tiempos.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219261         Carlos Solis   14/05/21      Creación
 * 2.0            US219264         Carlos Solis   08/06/21      Añadidos los métodos actualizarFechaRecepcionPretensiones,
 *                                                              updateVacioPretRec y slaStartDatePretension
 * 2.1            US242679         Luis Mesa      29/09/21      Añadir método para poder volver a abrir los Milestones de los casos,
 *                                                                  metodo -> reabrirSLAs
 *                                                              refactorización de código
 *                                                                  finyReinicioSLAs (engloba la logica de completarSLAs y reabrirSLAs).
*****************************************************************/
public without sharing class SAC_ComportamientoSLAs {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static Id recTypeConsulta = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    private static Id recTypeConsultaSAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();

    /*****************************************************************
     * Proposito: En este método se completan y reinician las SLAs cuando un caso llega a un estado de cerrado, o sale del mismo
     * Agrupa los métodos completarSLAs y reabrirSLAs. Evitar sobrecarga en el trigger
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US242679         Luis Mesa      29/06/21     Creación
    *****************************************************************/
    public static List<CaseMilestone> finyReinicioSLAs(List<Case> listNewCase, Map<Id, Case> mapOldCase, List<Case> listaCasosSelect) {
        List<CaseMilestone> listaCaseMilestoneUpdatear = new List<CaseMilestone>();
        List<Case> listaCasos = new List<Case>();
        Set<Id> listaIdsCasos = new Set<Id>();
        Map<Id, Case> mapaRecSelect = new Map<Id, Case>();
        Map<Id, List<Case>> mapaRecPrets = new Map<Id, List<Case>>();
        //Recorrer lista del select para almacenar en un mapa la id de cada reclamacion padre y de valor todas sus pretensiones hijas
        for (Case caso : listaCasosSelect) {
            //Rellenar mapaRecPrets
            if (caso.RecordTypeId == recTypePretension && !mapaRecPrets.containsKey(caso.SAC_Reclamacion__c)) {
                List<Case> listaPrets = new List<Case>();
                listaPrets.add(caso);
                mapaRecPrets.put(caso.SAC_Reclamacion__c, listaPrets);
            } else if (caso.RecordTypeId == recTypePretension && mapaRecPrets.containsKey(caso.SAC_Reclamacion__c)) {
                mapaRecPrets.get(caso.SAC_Reclamacion__c).add(caso);
            }
            //Rellenar mapaRecSelect
              else if (caso.RecordTypeId == recTypeReclamacion && !mapaRecSelect.containsKey(caso.Id)) {
                mapaRecSelect.put(caso.Id, caso);
            }
        }
        
        //Recorrer lista de casos del trigger para guardar las ids de los casos y, en caso de que sea una reclamación, las ids de sus pretensiones hijas
        for (Case caso : listNewCase) {
            listaCasos.add(caso);
            listaIdsCasos.add(caso.Id);
            if (caso.recordTypeId == recTypeReclamacion && mapaRecPrets.containsKey(caso.Id)) {
                for (Case pret : mapaRecPrets.get(caso.Id)) {
                    listaIdsCasos.add(pret.Id);
                }
            }
            //Sustituir en el mapaRecSelect el caso del select por el caso que viene en el trigger new (ya que puede haber cambiado el check de casoNegociado en esta dml y en el select no se ve reflejado)
            if (caso.RecordTypeId == recTypeReclamacion) {
                mapaRecSelect.put(caso.Id, caso);
            }
        }
        
        if (!listaCasos.isEmpty()) {
            List<CaseMilestone> listaCaseMilestone = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name
                                                    FROM CaseMilestone WHERE caseId IN :listaIdsCasos];
            Map<Id, List<CaseMilestone>> mapaCaseMilestone = new Map<Id, List<CaseMilestone>>();
            for (CaseMilestone caseMil : listaCaseMilestone) {
                if (mapaCaseMilestone.get(caseMil.caseId) != null) {
                    mapaCaseMilestone.get(caseMil.caseId).add(caseMil);
                } else {
                    List<CaseMilestone> listaCM = new List<CaseMilestone>();
                    listaCM.add(caseMil);
                    mapaCaseMilestone.put(caseMil.CaseId, listaCM);
                }
            }
            listaCaseMilestoneUpdatear.addall(completarSLAs(listaCasos, mapaCaseMilestone, mapOldCase, mapaRecPrets));
            listaCaseMilestoneUpdatear.addall(reabrirSLAs(listaCasos, mapaCaseMilestone, mapOldCase, mapaRecSelect, mapaRecPrets));
        }
        return listaCaseMilestoneUpdatear;
    }

    /*****************************************************************
     * Proposito: En este método se completan las SLAs cuando un caso llega a un estado de cerrado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219261         Carlos Solis   17/04/21     Creación
     * 1.1            NaN              Luis Mesa      29/09/21     Modificación - DEL
     *                                                              Borrado de la gran parte del código para ser reutilizado por otros métodos. 
     * 1.2            US501943         CS             22/12/22     Se ha añadido el cierre de milestone al estado SAC_007 (Negociación)
     * 1.3            US505370         Raúl Santos    07/03/2023   Se ha añadido el cierre de milestone al estado SAC_014 (Cerrada sin resolver)
     * 1.4            US392178         Sergio Martín  01/08/2023   Modificado cierre de milestone (Regulatorio y Letrado) al estado SAC_007 (Negociación) solo cuando tiene fecha de resolución informada
     * 1.5            US750307         CS             10/11/23     Se ha añadido para que cierre los milestones de la reclamación y las pretensiones hijas cuando se informe la fecha de resolución
    *****************************************************************/
    public static List<CaseMilestone> completarSLAs(List<Case> listaCasos, Map<Id, List<CaseMilestone>> mapaCaseMilestone, Map<Id, Case> mapOldCase, Map<Id, List<Case>> mapaRecPrets) {
        List<CaseMilestone> listaCaseMilestoneUpdatear = new List<CaseMilestone>();
        for (Case caso : listaCasos) {
            if (mapaCaseMilestone.containsKey(caso.Id) && (caso.Status == 'SAC_004' || /*caso.status == 'SAC_005' ||*/ caso.status == 'Cerrado' || caso.Status == 'SAC_014' || caso.Status == 'SAC_009' || caso.Status == 'SAC_008' ||  caso.Status == 'SAC_013' ||  caso.Status == 'SAC_012' || caso.Status == 'Rechazado')) {
                for (CaseMilestone cm : mapaCaseMilestone.get(caso.Id)) {
                    if (String.isBlank(String.valueOf(cm.CompletionDate)) && cm.MilestoneType.Name != 'SLA Alta') {
                        cm.CompletionDate = system.now();
                        listaCaseMilestoneUpdatear.add(cm);
                    }
                }
            }
            //Si el caso pasa a negociación y el anterior estado ha sido resolución, se completa el sla regulatorio y sla letrado
            /*Añadido US750307 (finalizar SLA al poner fecha de resolución). Se ha añadido la condición OR 
            para que cierre el milestone de la reclamación y sus pretensiones hijas en caso de que se haya puesto una fecha de resolución*/
            if (caso.RecordTypeId == recTypeReclamacion && mapOldCase.containsKey(caso.Id) && (caso.status == 'SAC_007' && mapOldCase.get(caso.Id).Status == 'SAC_003') || (mapOldCase.get(caso.Id).OS_Fecha_Resolucion__c == null && caso.OS_Fecha_Resolucion__c != null)) {
                //Cerrar case milestone de la reclamación
                if (mapaCaseMilestone.containsKey(caso.Id)) {
                    for (CaseMilestone cm : mapaCaseMilestone.get(caso.Id)) {
                        if (String.isBlank(String.valueOf(cm.CompletionDate)) && cm.MilestoneType.Name == 'SLA Regulatorio') {
                            cm.CompletionDate = system.now();
                            listaCaseMilestoneUpdatear.add(cm);
                        }
                    }    
                }

                //Cerrar CaseMilestone de las pretensiones hijas de la reclamación
                if (mapaRecPrets.containsKey(caso.Id)) {
                    for (Case pret : mapaRecPrets.get(caso.Id)) {
                        if (mapaCaseMilestone.containsKey(pret.Id)) {
                            for (CaseMilestone cm : mapaCaseMilestone.get(pret.Id)) {
                                if (String.isBlank(String.valueOf(cm.CompletionDate)) && (cm.MilestoneType.Name == 'SLA Regulatorio' || cm.MilestoneType.Name == 'SLA Letrado')) {
                                    cm.CompletionDate = system.now();
                                    listaCaseMilestoneUpdatear.add(cm);
                                }
                            }
                        }
                    }
                }
            }
            //Completar el SLA Alta
            if ( (mapOldCase.containsKey(caso.Id) && mapaCaseMilestone.containsKey(caso.Id)) &&
                    (mapOldCase.get(caso.Id).Status == 'SAC_001' || mapOldCase.get(caso.Id).Status == 'SAC_006') &&
                    (caso.Status != 'SAC_001' && caso.Status != 'SAC_006')) {
                for (CaseMilestone cm : mapaCaseMilestone.get(caso.Id)) {                    
                    if (cm.MilestoneType.Name == 'SLA Alta') {
                        cm.CompletionDate = system.now();
                        listaCaseMilestoneUpdatear.add(cm);
                    }
                }
            }
        }
        return listaCaseMilestoneUpdatear;
    }

    /*****************************************************************
     * Proposito: En este método se completan las SLAs cuando un caso llega a un estado de cerrado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US242679         Luis Mesa      29/06/21     Modificación para tener en cuenta los estados
     *                                                             que consideran el caso Cerrado.
     * 1.1            US501943         CS             22/12/22     Se ha añadido para que no reabra el case milestone cuando habia sido cerrado por negociación.
     *                                                             Se puede reabrir si despues de la negociación, el caso se ha cerrado y vuelto a reabrir
     * 1.2            US505370         Raúl Santos    07/03/23     Modificación para tener en cuenta el estado SAC_014 (Cerrado sin resolver)
     * 1.3            US750307         CS             10/11/23     Añadido para que se reabran las reclamaciones cuando no tengan una fecha de resolución informada, ya que ahora cierran al
     *                                                             informarla. Se respetan los estados, pero no debe tener una fecha de resolución para reabrir.
    *****************************************************************/
    public static List<CaseMilestone> reabrirSLAs(List<Case> listaCasos, Map<Id, List<CaseMilestone>> mapaCaseMilestone, Map<Id, Case> mapOldCase, Map<Id, Case> mapaRecSelect, Map<Id, List<Case>> mapaRecPrets) {
        List<CaseMilestone> listaCaseMilestoneUpdatear = new List<CaseMilestone>();
        Map<Id, Boolean> mapaCasoNegociado = new Map<Id, Boolean>();
        Boolean reaperturaCaso = false;

        for (Case caso : listaCasos) {
            //Se separa la reapertura de la reclamacion de la de la pretension, para en la pretension comprobar si su reclamacion padre ha sido negociada (en ese caso no se reabre)
            //Reabrir si es reclamación, consulta o consulta sac
            //Añadido US750307. Reabrir si la fecha resolucion está vacía. Mientras tenga una fecha de resolución, seguirá cerrada.
            if (mapaCaseMilestone.containsKey(caso.Id) && (caso.RecordTypeId == recTypeReclamacion || caso.RecordTypeId == recTypeConsulta || caso.RecordTypeId == recTypeConsultaSAC)
            && (caso.Status != 'SAC_004' && /*caso.status != 'SAC_005' && */caso.status != 'Cerrado' && caso.Status != 'SAC_009' && caso.Status != 'SAC_008' && caso.Status != 'SAC_013' 
            && caso.Status != 'SAC_014' && caso.Status != 'SAC_012' && caso.Status != 'Rechazado' && (caso.Status != 'SAC_007' && !caso.SAC_CasoNegociado__c) && caso.OS_Fecha_Resolucion__c == null)) {
                for (CaseMilestone cm : mapaCaseMilestone.get(caso.Id)) {
                    if (String.isNotBlank(String.valueOf(cm.CompletionDate)) && cm.MilestoneType.Name != 'SLA Alta') {
                        cm.CompletionDate = null;
                        listaCaseMilestoneUpdatear.add(cm);
                    }
                }

                //Añadido US750307. Reabrir las pretensiones hijas si se elimina la fecha de resolución en la reclamación
                if (caso.RecordTypeId == recTypeReclamacion && mapOldCase.containsKey(caso.Id) && mapOldCase.get(caso.Id).OS_Fecha_Resolucion__c != null && caso.OS_Fecha_Resolucion__c == null && mapaRecPrets.containsKey(caso.Id)) {
                    for (Case pret : mapaRecPrets.get(caso.Id)) {
                        if (pret.Status != 'SAC_009') {
                            if (mapaCaseMilestone.containsKey(pret.Id)) {
                                for (CaseMilestone cm : mapaCaseMilestone.get(pret.Id)) {
                                    if (String.isNotBlank(String.valueOf(cm.CompletionDate)) && (cm.MilestoneType.Name == 'SLA Regulatorio' || cm.MilestoneType.Name == 'SLA Letrado')) {
                                        cm.CompletionDate = null;
                                        listaCaseMilestoneUpdatear.add(cm);
                                    }
                                }    
                            }
                        }
                    }
                }
            } 
            //Reabrir si es pretensión
            //Añadido US750307. Reabrir si la fecha resolucion de la reclamación padre está vacía, para evitar reabrir al cambiar de estado con una fecha de resolución informada en la reclamación padre
            if (mapaCaseMilestone.containsKey(caso.Id) && (caso.RecordTypeId == recTypePretension && caso.Status != 'SAC_004' && /*caso.status != 'SAC_005' && */caso.status != 'Cerrado'  && caso.Status != 'SAC_009' && caso.Status != 'SAC_008' && caso.Status != 'SAC_013' && caso.Status != 'SAC_012' && caso.Status != 'Rechazado' && (mapaRecSelect.containsKey(caso.SAC_Reclamacion__c) && mapaRecSelect.get(caso.SAC_Reclamacion__c).Status != 'SAC_007' && !mapaRecSelect.get(caso.SAC_Reclamacion__c).SAC_CasoNegociado__c) && (mapaRecSelect.containsKey(caso.SAC_Reclamacion__c) && mapaRecSelect.get(caso.SAC_Reclamacion__c).OS_Fecha_Resolucion__c == null))) {
                for (CaseMilestone cm : mapaCaseMilestone.get(caso.Id)) {
                    if (String.isNotBlank(String.valueOf(cm.CompletionDate)) && cm.MilestoneType.Name != 'SLA Alta') {
                        cm.CompletionDate = null;
                        listaCaseMilestoneUpdatear.add(cm);
                    }
                }
            }
            //Reabrir el SLA Alta
            if (mapOldCase.containsKey(caso.Id) && mapOldCase.get(caso.Id).Status != 'SAC_001' && mapOldCase.get(caso.Id).Status != 'SAC_006' && mapaCaseMilestone.containsKey(caso.Id) && caso.Status == 'SAC_001') {
                for (CaseMilestone cm : mapaCaseMilestone.get(caso.Id)) {
                    if (cm.MilestoneType.Name == 'SLA Alta') {
                        cm.CompletionDate = null;
                        listaCaseMilestoneUpdatear.add(cm);
                    }
                }
            }
        }
        return listaCaseMilestoneUpdatear;
    }
    
    /*****************************************************************
     * Proposito: Método para cerrar los case milestone de letrado cuando se pasa directamente de alta a
     * baja en una pretensión
     * Modificación: Llamada al Queueable SAC_QueueableCerrarMilestoneLetrado para el correcto ciierre del
     *          SLA Letrado en la conversión de reclamación a consulta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   22/02/22     Creación
     * 1.1             DE101079     Sergio Martín     05/09/24     Modificado
    *****************************************************************/
    public static void cerrarMilestoneLetradoAltaBaja(List<Case> listNewCase) {
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
        .addId(UserInfo.getUserId())
        .addString('listNewCase')
        .build();
        try {
            System.enqueueJob(new SAC_QueueableCerrarMilestoneLetrado(listNewCase), options);    
        } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }      
    }

    /*****************************************************************
     * Proposito: Método para actualizar la fecha de recepción de las pretensiones y traer el valor de su reclamacion padre
     * Además, ejecuta un update de la pretension cada vez que se updatea su reclamacion padre. Así refresca el valor de
     * la SAC_MilestoneTimeCalculator y refleja el cambio de tiempo tanto en la reclamación como en sus pretensiones.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219264         Carlos Solis   07/06/21     Creación
    *****************************************************************/
    public static void actualizarFechaRecepcionPretensiones(List<Case> listaCasosSelect, List<Case> listaReclamacionFechaRecepcion, Map<Id,Case> mapaDatosCasosActualizar) {
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        Map<Id,List<Case>> mapaCasos = new Map<Id,List<Case>>(); 
        List<Case> listaPretensiones = new List<case>();

        for (Case caso: listaReclamacionFechaRecepcion) {
            list<case> listaAux = new list<case>();
            mapaCasos.put(caso.id,listaAux );            
        }
        for (Case caso : listaCasosSelect) {            
            if(mapaCasos.containsKey(caso.SAC_Reclamacion__c) && caso.RecordTypeId == RECTYPEPRETENSION ){
                mapaCasos.get(caso.SAC_Reclamacion__c).add(caso);
            }        
        }
        for( ID ide : mapaCasos.keySet()){ 
            listaPretensiones.addAll(mapaCasos.get(ide) );         
        }

        Map<Id, List<Case>> mapReclamacionPretensiones = new Map<Id, List<Case>>();

        for(Case pretension : listaPretensiones){
            List<Case> pretensiones = new List<Case>();
            if(mapReclamacionPretensiones.containsKey(pretension.SAC_Reclamacion__c)){
                pretensiones = mapReclamacionPretensiones.get(pretension.SAC_Reclamacion__c);
            }
            pretensiones.add(pretension);
            mapReclamacionPretensiones.put(pretension.SAC_Reclamacion__c, pretensiones);
        }

        List<Case> pretensionesAActualizar = new List<Case>();

        
        for (Case reclamacion : listaReclamacionFechaRecepcion) {
            if(mapReclamacionPretensiones.containsKey(reclamacion.Id)){
                List<Case> pretensiones = mapReclamacionPretensiones.get(reclamacion.Id);
                for (Case pretension : pretensiones) {
                    pretension.SAC_FechaRecepcion__c = reclamacion.SAC_FechaRecepcion__c;
                    pretension.SlaStartDate = reclamacion.SAC_FechaRecepcion__c;
                    pretensionesAActualizar.add(pretension);
                }
            }
        }
       
        for (Case caso : pretensionesAActualizar) {
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).SAC_FechaRecepcion__c = caso.SAC_FechaRecepcion__c;
                mapaDatosCasosActualizar.get(caso.id).SlaStartDate = caso.SAC_FechaRecepcion__c;
            }else{
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
        }
        
    }

    /*****************************************************************
     * Proposito: Método para updatear las pretensiones o reclamaciones relacionadas con el caso.
     * Es un Update en el que no se cambiará nada, simplemente para que refresque el tiempo de las SLA
     * Updated: Llama al método comprobarPausas para pausar o reanudar SLAs
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219264         Carlos Solis   07/06/21     Creación
     * 1.1            US254534         Carlos Solis   27/08/21     Añadir funcionalidad (control de pausas y reanudaciones SLA)
    *****************************************************************/
    public static void updateVacioPretRec(List<Case> listNewCase, Map<Id, Case> mapNewCase) {
        List<Case> listaFamilia = new List<Case>();
        listaFamilia = SAC_ComportamientoSLAs.buscarFamiliaCasos(listNewCase);

        //Monto la lista de casos en una lista de ids para poder importarla al future y luego traer todos esos casos de un select
        if (!listaFamilia.isEmpty()) {
            List<String> listaIds = new List<String>();
            for (Case caso : listaFamilia) {
                listaIds.add(caso.Id);
            }
            //Se comprueban las pausas
            //Como es un método futuro, compruebo primero si existe algun batch o método futuro en ejecución para que no me de error
            if(System.IsBatch() == false && System.isFuture() == false){ 
                comprobarPausas(listaIds); 
            }
            
        }
        //Finalmente Updateo -- Por ahora no hace falta ya que updateo en el método de comprobar las pausas
        //update listaFamilia;
    }

    /*****************************************************************
     * Proposito: Controla si algun caso esta pausado y pausa su familia de casos. 
     * Si no hay ninguno pausado, los reanuda todos (los de su familia)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US254534         Carlos Solis   27/08/21     Creación
    *****************************************************************/
    @future
    public static void comprobarPausas(List<String> listaIds) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        List<Case> listaFamilia = new List<Case>();
        listaFamilia = [SELECT id, SAC_Reclamacion__c, RecordTypeId, Status, SAC_EnvioParcial__c, SAC_ReclamanteConformeNegociacion__c, isStopped FROM Case
                        WHERE (RecordTypeId = :recTypeReclamacion OR RecordTypeId = :recTypePretension)
                        AND Id IN :listaIds];

        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();
        List<Case> listaUpdatear = new List<Case>();

        //Separo las reclamaciones de las pretensiones
        for (Case caso : listaFamilia) {
            if (caso.RecordTypeId == recTypeReclamacion) {
                listaReclamaciones.add(caso);
            } else if (caso.RecordTypeId == recTypePretension) {
                listaPretensiones.add(caso);
            }
        }

        //Monto mapa llamando al método que lo hace
        Map<Id,List<Case>> mapaPadreHijas = new Map<Id,List<Case>>();
        mapaPadreHijas = SAC_ComportamientoSLAs.montarMapaReclamacionFamilia(listaFamilia);

        //Recorro el mapa y la lista de casos asociados a cada reclamación
        for (Case reclamacion : listaReclamaciones) {
            Boolean pausarFamilia = false;
            if (mapaPadreHijas.containsKey(reclamacion.Id)) {
                //Si alguno de los casos de cada familia está en estado de parada, lo guardo en el Boolean 'pausarFamilia'
                for (Case caso : mapaPadreHijas.get(reclamacion.Id)) {
                    // MOD: Comentado pausa subsanación por US959472
                    // if (caso.Status == 'SAC_006') { //Subsanación
                    //     caso.isStopped = true;
                    //     pausarFamilia = true;
                    // }
                    if (caso.Status == 'SAC_007' && caso.SAC_ReclamanteConformeNegociacion__c) { //Negociación
                        caso.isStopped = true;
                        pausarFamilia = true;
                    }
                }
                //Con el anterior Boolean, si alguno de los casos está pausado en la familia de esta reclamación, pauso el resto de la familia.
                //De lo contrario (es decir, si nadie de la familia está en estado de pausa), reanudo el SLA de toda la familia
                if (pausarFamilia) {
                    for (Case caso : mapaPadreHijas.get(reclamacion.Id)) {
                        //Cada caso lo devuelvo a una lista que posteriormente retornaré con todas las modificaciones hechas.
                        caso.isStopped = true;
                        listaUpdatear.add(caso);
                    }
                } else {
                    for (Case caso : mapaPadreHijas.get(reclamacion.Id)) {
                        //Cada caso lo devuelvo a una lista que posteriormente retornaré con todas las modificaciones hechas.
                        caso.isStopped = false;
                        listaUpdatear.add(caso);
                    }
                }
            }
        }
        //Finalmente, updateamos la lista con las pausas de los casos modificados
        //update listaUpdatear;
    }

    /*****************************************************************
     * Proposito: Método para insertar el SLA start date de las pretensiones acorde a su reclamación
     * cuando se cree un caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219264         Carlos Solis   08/06/21     Creación
    *****************************************************************/
    public static void slaStartDatePretension(List<Case> newListCase) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        List<Case> listaReclamacionesPadre = new List<Case>();
        List<Id> listaIdsPadrePretension = new List<Id>();

        for (Case caso : newListCase) {
            listaIdsPadrePretension.add(caso.SAC_Reclamacion__c);
        }

        Map<Id, Case> mapReclamacionesPadre = new Map<Id, Case>([SELECT Id, SAC_FechaRecepcion__c, SlaStartDate FROM Case WHERE RecordTypeId = :recTypeReclamacion
                                    AND Id in :listaIdsPadrePretension]);

        for (Case pretension : newListCase) {
            if (mapReclamacionesPadre.containsKey(pretension.SAC_Reclamacion__c)) {
                pretension.SAC_FechaRecepcion__c = mapReclamacionesPadre.get(pretension.SAC_Reclamacion__c).SAC_FechaRecepcion__c;
                pretension.SlaStartDate = mapReclamacionesPadre.get(pretension.SAC_Reclamacion__c).SAC_FechaRecepcion__c;
            }
        }
    }

    /*****************************************************************
     * Proposito: Método para buscar la familia de cada caso que entra en la lista, sean pretensiones, reclamaciones, o ambas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   31/08/21     Creación
    *****************************************************************/
    public static List<Case> buscarFamiliaCasos(List<Case> listaCasos) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();
        List<Id> listaIdsReclamacion = new List<Id>();
        List<Id> listaIdsPadrePretension = new List<Id>();
        Boolean entraReclamacion = false;
        Boolean entraPretension = false;

        for (Case caso : listaCasos) {
            if (caso.RecordTypeId == recTypeReclamacion) {
                listaIdsReclamacion.add(caso.Id);
                listaReclamaciones.add(caso);
                entraReclamacion = true;
            } else if (caso.RecordTypeId == recTypePretension) {
                listaIdsPadrePretension.add(caso.SAC_Reclamacion__c);
                listaPretensiones.add(caso);
                entraPretension = true;
            }
        }
        
        List<Case> listaPretensionesHermanas = new List<Case>();
        List<Case> listaPretensionesAsociadas = new List<Case>();
        List<Case> listaReclamacionesPadre = new List<Case>();
        List<Case> listaReclamacionesPadreTrigger = new List<Case>();

        if (entraReclamacion) {
            //Si se updatean reclamaciones, aqui saco sus hijos
            listaPretensionesAsociadas = [SELECT id, SAC_Reclamacion__c, RecordTypeId, Status, SAC_EnvioParcial__c, SAC_ReclamanteConformeNegociacion__c, isStopped FROM Case WHERE RecordTypeId = :recTypePretension AND SAC_Reclamacion__c IN :listaIdsReclamacion AND Status != 'SAC_009'];

            listaReclamacionesPadreTrigger = [SELECT Id, SAC_Reclamacion__c, RecordTypeId, Status, SAC_EnvioParcial__c, SAC_ReclamanteConformeNegociacion__c, isStopped FROM Case WHERE RecordTypeId = :recTypeReclamacion AND Id IN :listaIdsReclamacion];
            //Añado las reclamaciones padre a la lista de las pretensiones para tener toda la familia
            for (Case reclamacion : listaReclamacionesPadreTrigger) {
                listaPretensionesAsociadas.add(reclamacion);
            }

        } else if (entraPretension) {
            //Si updatean pretensiones, aquí saco sus hermanas
            listaPretensionesHermanas = [SELECT id, SAC_Reclamacion__c, RecordTypeId, Status, SAC_EnvioParcial__c, SAC_ReclamanteConformeNegociacion__c, isStopped FROM Case WHERE RecordTypeId = :recTypePretension AND SAC_Reclamacion__c IN :listaIdsPadrePretension AND Status != 'SAC_009'];

            //Si updatean pretensiones, aquí saco sus padres
            listaReclamacionesPadre = [SELECT id, RecordTypeId, Status, SAC_EnvioParcial__c, SAC_ReclamanteConformeNegociacion__c, isStopped FROM Case WHERE RecordTypeId = :recTypeReclamacion AND id IN :listaIdsPadrePretension];
        }

        List<Case> listaTotal = new List<Case>();

        for (Case caso : listaPretensionesAsociadas) {
            listaTotal.add(caso);
        }
        for (Case caso : listaPretensionesHermanas) {
            listaTotal.add(caso);
        }
        for (Case caso : listaReclamacionesPadre) {
            listaTotal.add(caso);
        }

        //Set para borrar duplicados
        Set<Case> myset = new Set<Case>();
        List<Case> result = new List<Case>();
        myset.addAll(listaTotal);
        result.addAll(myset);

        return result;
    }

    /*****************************************************************
     * Proposito: Crea un mapa con la id de las reclamaciones como key y una lista con toda la familia de esa
     * reclamacion (incluida la reclamación) como valor y lo retorna
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   31/08/21     Creación
     * 2.0            DE59893         Marcela Neira   02/05/2022   Modificación montar el mapa sin las pretensiones 
     *                                                             que estan en baja.
    *****************************************************************/
    public static Map<Id,List<Case>> montarMapaReclamacionFamilia(List<Case> listaCasosFamilia) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();

        //Separo las reclamaciones de las pretensiones
        for (Case caso : listaCasosFamilia) {
            if (caso.RecordTypeId == recTypeReclamacion) {
                listaReclamaciones.add(caso);
            } else if (caso.RecordTypeId == recTypePretension && caso.Status != 'SAC_009') {
                listaPretensiones.add(caso);
            }
        }

        //Monto un mapa con las reclamaciones como key (ademas de añadir la reclamación per se a su lista de casos)
        Map<Id,List<Case>> mapaPadreHijas = new Map<Id,List<Case>>();
        for (Case caso : listaReclamaciones) {
            List<Case> reclamaciones = new List<Case>();
            reclamaciones.add(caso);
            mapaPadreHijas.put(caso.Id, reclamaciones);
        }

        //Añado al mapa de reclamaciones, las pretensiones a la lista de cada reclamación correspondiente
        for (Case pret : listaPretensiones) {
            if (mapaPadreHijas.containsKey(pret.SAC_Reclamacion__c)) {
                mapaPadreHijas.get(pret.SAC_Reclamacion__c).add(pret);
            }
        }

        return mapaPadreHijas;
    }
}