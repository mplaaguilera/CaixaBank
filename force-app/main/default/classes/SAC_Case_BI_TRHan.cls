/*****************************************************************
 * Name: SAC_Case_BI_TRHan
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Insert del objeto Case
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200213         Carlos Solis   22/04/21     Creación
*****************************************************************/
public without sharing class SAC_Case_BI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
	}

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        for (Schema.RecordTypeInfo rt: lstRT){
            if (rt.getDeveloperName().left(4)=='SAC_') {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }
        List<Case> listNewObjSAC= New List<Case>();
        Map<Id, Case> mapNewObjSAC = New Map<Id, Case>();
        for (Case tk: listNewObj){
            if((setIdsRt).contains(tk.RecordTypeId)){
                listNewObjSAC.add(tk);
                mapNewObjSAC.put(tk.Id,tk);
            }
        }
        if (listNewObjSAC.size()!=0) {
            processSAC(listNewObjSAC,mapNewObjSAC);
        }
    }
    private void processSAC(List<Case> listNewObj, Map<Id, Case> mapNewObj) {
        //Obtener record Type
        Set<String> objetos = new Set<String>{'Case'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
        Id recTypeConsulta = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
        Id recTypeConsultaSAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();

        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretension = new List<Case>();          
        List<Case> listaCasos = new List<Case>();     
        List<Case> listaConsultas = new List<Case>();
        List<Case> listaReclamacionesBalancear = new List<Case>();
        List<Case> listaReclamacionesSLA = new List<Case>();
        List<Id> listaIdsCuentas = new List<Id>();
        List<Case> listaCasosCuenta = new List<Case>();
        List<Case> listaCaseAccALF = new List<Case>();
        List<Case> listaCasosMCC = new List<Case>();
        List<Id> listaTematicaMCC = new List<Id>();
        Map<Id,Case> mapaCasos = new Map<Id,Case>();
        group cola = new group();
        group colaIA = new group();
        group colaPdte = new group();
        //GENIAL reducir queries metiendo la de grupo IA aquí
        for (group col : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('SAC_PendienteAsignar','SAC_GenialPdteIA') LIMIT 2]) {
            if(col.developerName == 'SAC_PendienteAsignar') {
                colaPdte = col;
            } else {
                colaIA = col;
            }
        }
        //Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

        //Recorrer la lista del trigger new y asignar los casos que tengan el record type SAC_Reclamacion a la lista con la que queremos trabajar.
        for (case caso : listNewObj) {
            cola = caso.ownerId == colaIA.Id ? colaIA : colaPdte;
            if (caso.RecordTypeId == recTypeReclamacion) {

                // Vaciar el campo SAC_Naturaleza__c en la creación de la reclamación
                if (caso.SAC_Naturaleza__c != null && !Test.isRunningTest()) {
                    caso.SAC_Naturaleza__c = '';
                }

                // US994116 - Vaciar el campo CC_Idioma__c en la creación de la reclamación, tiene que salir por defecto en "Ninguno"
                if (caso.CC_Idioma__c != null && !Test.isRunningTest()) {
                    caso.CC_Idioma__c = '';
                }

                listaReclamaciones.add(caso);
                mapaCasos.put(caso.Id, caso);

                if(String.isNotBlank(caso.SEG_Detalle__c) || String.isNotBlank(caso.CC_MCC_Tematica__c) || String.isNotBlank(caso.CC_MCC_ProdServ__c) || String.isNotBlank(caso.CC_MCC_Motivo__c)){
                    listaCasosMCC.add(caso);
                    listaTematicaMCC.add(caso.SEG_Detalle__c);
                } 

                if (caso.AccountId != null && String.isBlank(caso.SAC_CasoRelacionado__c)) { //Si SAC_CasoRelacionado__c viene lleno, significa que es una copia y no debe balancearse
                     
                    listaIdsCuentas.add(caso.AccountId);
                    listaCasosCuenta.add(caso);
                    if (caso.SAC_UsarDatos__c) { 
                        listaCaseAccALF.add(caso);
                    }
                }
                if (String.isBlank(caso.SAC_CasoRelacionado__c)) {
                    listaReclamacionesBalancear.add(caso);
                }
                listaCasos.add(caso);
                //Hacemos Bypass para calcular el SAC_FechaVencimientoSLA__c de forma custom evitando SAC_MilestoneTimeCalculator en la creación de casos IA 

                if (!String.isBlank(caso.SAC_GenialEstado__c)) {
                    listaReclamacionesSLA.add(caso);
                }
                
            }
            if (caso.RecordTypeId == recTypePretension) { 
                listaPretension.add(caso);
                listaCasos.add(caso);

                if(String.isNotBlank(caso.SEG_Detalle__c) || String.isNotBlank(caso.CC_MCC_Tematica__c) || String.isNotBlank(caso.CC_MCC_ProdServ__c) || String.isNotBlank(caso.CC_MCC_Motivo__c)){
                    listaCasosMCC.add(caso);
                    listaTematicaMCC.add(caso.SEG_Detalle__c);
                }
            }
            if (caso.RecordTypeId == recTypeConsulta) {
                listaCasos.add(caso);
                listaConsultas.add(caso);
            } 
            if (caso.RecordTypeId == recTypeConsultaSAC) {
                listaCasos.add(caso);
            }
        }

        List<Case> listaCasosSelect = new List<Case>();
        listaCasosSelect = [SELECT Id, SAC_Reclamacion__c, Status, RecordTypeId, SEG_Detalle__c,subject, ownerId, AccountId, SEG_Grupo__c, isClosed, SAC_CasoRelacionado__c
                        FROM Case 
                        WHERE RecordTypeId = :recTypeReclamacion  AND isClosed = false  AND AccountId IN :listaIdsCuentas /**Lista para el balanceo */]; 

        //Si la lista con los casos no está vacia, trabajamos con nuestros métodos
        List<Case> casosSinReclamacionAnterior = new List<Case>();
        list<Case> casosSinIA = new list<Case>();
        if (!listaReclamacionesBalancear.isEmpty()) {
            //nuevo paso del filtro
            //casosSinIA = casosIA(listaReclamacionesBalancear, colaIA);
            
            //casosSinReclamacionAnterior = SAC_Balanceo.asignarOwnerCaso(listaCasosSelect, casosSinIA, listaIdsCuentas); //Comprueba si hay alguna reclamacion abierta con el mismo AccountID y le asigna el mismo caseOwnerId. Devuelve una lista con los que no tienen esa coincidencia.
            if(colaIA.Id != cola.id){
                casosSinReclamacionAnterior = SAC_Balanceo.asignarOwnerCaso(listaCasosSelect, listaReclamacionesBalancear, listaIdsCuentas);
            } else {
                casosSinReclamacionAnterior = listaReclamacionesBalancear;
            }
            SAC_Balanceo.balanceoGrupos(casosSinReclamacionAnterior, cola); //Asigna un grupo al caso siguiendo los porcentajes de asignacion de los grupos. Se le pasa por parametro la lista con los casos que no ha podido asignar el anterior metodo.
        }
        if (!listaReclamacionesSLA.isEmpty()) {
            for (Case caso : listaReclamacionesSLA) {
                Datetime fechaVencimiento = SAC_GenialUtils.calculateMilestoneTriggerTime(caso);
                if (fechaVencimiento != null) {
                    caso.SAC_FechaVencimientoSLA__c = fechaVencimiento;
                }
            }
        }
        system.debug('***listaCasos '+listaCasos);
        if(!listaCasos.isEmpty()){
            system.debug('***listaCasos no empty ');
            asignarEntitlement(listaCasos);
            rellenarStatusAuxiliar(listaCasos);
            informarImporteReclamado(listaCasos); 
            calcularCanalRespuesta(listaCasos);
        }

        if(!listaReclamaciones.isEmpty()){
            SAC_Pretension.rellenarCodigosExternosMCC(listaCasosMCC, listaTematicaMCC); //Rellena los campos con los códigos externos que tiene el mcc.
        }

        if(!listaCasosCuenta.isEmpty()){
            SAC_Reclamacion.recuperarGestorCliente(listaCasosCuenta);
            SAC_SeleccionDireccionRespuesta.setCanalRespuesta(listaCasosCuenta);
            rellenarNIFCuenta(listaCasosCuenta, listaIdsCuentas);
            SAC_Reclamacion.informarEsCliente(listaCasosCuenta);
        }

        if(!listaCaseAccALF.isEmpty()){
            SAC_LCMP_RepresentanteValido.usarDatosDeAlf(listaCaseAccALF);
        }

        if (!listaPretension.isEmpty()) {
            SAC_ComportamientoSLAs.slaStartDatePretension(listaPretension);
            SAC_Pretension.rellenarCodigosExternosMCC(listaCasosMCC, listaTematicaMCC); //Rellena los campos con los códigos externos que tiene el mcc.
        }

        if(!listaConsultas.isEmpty()){
            SAC_Consulta.rellenarDatosCreacion(listaConsultas);
        }
	}

    /*****************************************************************
     * Proposito: Método para asignar un entitlement al caso y asi disponer del Entitlement Process en un caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200213         Carlos Solis   22/04/21     Creación
    *****************************************************************/
    public static void asignarEntitlement(List<Case> listNewCase) {
        system.debug('***asignarEntitlement ');
        if (Schema.sObjectType.Entitlement.isAccessible()) {
            List <Entitlement> entls = [SELECT id, SlaProcess.name FROM Entitlement WHERE SlaProcess.name = 'SAC_Process' ORDER BY LastModifiedDate desc limit 1];   
            system.debug('***entls ');
            for (Case newCase : listNewCase) {
                system.debug('***newCase ' + newCase);
                if (String.isBlank(newCase.SAC_CasoRelacionado__c)) { //Si SAC_CasoRelacionado__c está lleno, significa que viene de una copia y la fecha de recepción ya viene rellena
                    system.debug('***asignar fecha recepción ');
                    newCase.SAC_FechaRecepcion__c = system.now();
                }
                if (!entls.isEmpty()) {
                    newCase.entitlementId = entls[0].Id;
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Método para asignar un entitlement al caso y asi disponer del Entitlement Process en un caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            -            Nicolás García   22/12/21        Creación
    *****************************************************************/
    public static void rellenarStatusAuxiliar(List<Case> listNewCase) {
        
        for (Case newCase : listNewCase) {
            newCase.SAC_StatusAuxiliar__c = newCase.Status;
        }
    }

    /*****************************************************************
     * Proposito: Método para asignar un entitlement al caso y asi disponer del Entitlement Process en un caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            -            Nicolás García   22/12/21        Creación
    *****************************************************************/
    public static void calcularCanalRespuesta(List<Case> listNewCase) {

        for (Case newCase : listNewCase) {
            if(newCase.Origin == 'SAC_Manual' || newCase.Origin == 'SAC_CartaPostal' || newCase.Origin == 'SAC_FormularioOficina'){
                newCase.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            }
            else{
                newCase.CC_Canal_Respuesta__c = 'Email';
            }
        }
        
    }

    /*****************************************************************
     * Proposito: Método para informar el valor del importe reclamado por defecto a 0
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            -                 IBM        22/12/21        Creación
    *****************************************************************/
    public static void informarImporteReclamado(List<Case> listNewCase) {
        for (Case newCase : listNewCase) {
            if(newCase.CC_Importe_Reclamado__c==null){
                newCase.CC_Importe_Reclamado__c = 0;
            }
        }
    }

    /*****************************************************************
     * Proposito: Método para informar el NIF con el valor del Account
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            -                 IBM        24/05/22        Creación
    *****************************************************************/
    public static void rellenarNIFCuenta(List<Case> listNewCase, List<Id> listaIdsAccounts) {

        Map <Id, Account> mapaCuentas = new Map <Id, Account>([SELECT Id, CC_Numero_Documento__c FROM Account WHERE Id IN : listaIdsAccounts]);
        for (Case caso : listNewCase) {
            if (String.isNotBlank(caso.AccountId) && mapaCuentas.containsKey(caso.AccountId)) {
                caso.CC_SuppliedNIF__c = mapaCuentas.get(caso.AccountId).CC_Numero_Documento__c;
            }
        }
    }
    
      /*****************************************************************
     * Proposito: Valorar si el caso debe ejecutarse como caso IA
     * necesario hacerlo en el BI porque se necesita el autonumber para hacer la seleccion
     * el fwk debe evitar que vuelva entrar así podremos evitar el balanceo.
     * Devuelve una lista de casos que no han sido seleccionados para tratarse por IA.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR                 DATE         Description
     * 1.0            US727970         Alexandre perez        24/10/23       Creación
    *****************************************************************/
    /*public static list<case> casosIA(list<case> reclamaciones, group cola){
        //llamada al mtd/settings
        list<case> reclamacionesManuales = new list<case>();
        /*SAC_GenialSettings__c  settings = SAC_GenialSettings__c.getInstance();
        
        list<case> reclamacionesIA = new list<case>();
        
        //comprobamos si está activo el envío a IA
        //group pdteIA = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_GenialPdteIA' LIMIT 1];
        if(settings.SAC_IAactiva__c){
            for(case reclamacion : reclamaciones) {   
                //randomizador por porcentaje. La funcion math.random devuelve un numero de entre 0 y 1
                if((reclamacion.origin == 'Email' || reclamacion.origin == 'SAC_Formulario') && math.random()*100 < settings.SAC_Porcentaje__c){
                    reclamacion.ownerId = cola.Id;
                    //marcar el caso de alguna manera para saber que es un caso IA??
                    reclamacionesIA.add(reclamacion);
                } else {
                    reclamacionesManuales.add(reclamacion);
                }
            }
        }else{
            return reclamaciones;
        } 
        return reclamacionesManuales;//fin primer comment
        // system.debug('ha entrado en casosIA');
        for(case reclamacion : reclamaciones){
            if(reclamacion.ownerId != cola.id){
                // system.debug('se pone en reclamacionesManuales');
                // system.debug(reclamacion.ownerId);
                reclamacionesManuales.add(reclamacion);
            } else {
                //envío api rest
                //en caso de que el envío falle hay que meterlo en reclamacionesManuales
                reclamacion.SAC_GenialEstado__c = 'SAC_001';


                // //enviarlo en schedule para asegurar que estan todos los datos
                // system.debug('ha entrado una reclamacion en casosIA');
                // List<CBK_SCH_PendingProcess__c> launchSchedule = new List<CBK_SCH_PendingProcess__c>();
                // String scheduleClass = 'SAC_GenialSendAzure';
                // CBK_SCH_PendingProcess__c pp = new CBK_SCH_PendingProcess__c();
                // pp.RecordId__c = reclamacion.Id;
                // Datetime execTime = Datetime.now();
                // execTime.addMinutes(1);
                // pp.Schedule_Time__c = execTime;
                // pp.Queued__c = false;
                // pp.ClassName__c = scheduleClass;
                // system.debug('id reclamacion');
                // system.debug(reclamacion.Id);
                // system.debug(reclamacion);
                // pp.Param1__c = reclamacion.Id;
                // launchSchedule.add(pp);
                // List<CBK_ScheduleProcess_Controller.ResponseInsert> result = new List<CBK_ScheduleProcess_Controller.ResponseInsert>();
                // if(launchSchedule != null && !launchSchedule.isEmpty()){
                //     result = CBK_ScheduleProcess_Controller.createRecordSchProcess(launchSchedule);
                //     system.debug('ha lanzado el schedulable');
                //     system.debug(result);
                // }

                
                // Boolean envioCorrecto = SAC_GenialSendAzure.sendToIA(reclamacion);
                // if (envioCorrecto){
                //     reclamacion.SAC_GenialEstado__c = 'SAC_001';
                // }
                // else{
                //     reclamacion.SAC_GenialEstado__c = 'SAC_004';
                //     //en caso de que el envío falle hay que meterlo en reclamacionesManuales
                //     reclamacionesManuales.add(reclamacion);
                // }
            }
        }
        return reclamacionesManuales;
    }
    */
}