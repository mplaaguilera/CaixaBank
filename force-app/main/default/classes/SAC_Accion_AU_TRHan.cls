/*****************************************************************
 * Name: SAC_Accion_AU_TRHan
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: After Update tareas
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US356803         alex perez     11/10/22      Creación
 * 1.1            US477799         Raúl Santos    02/11/22      Modificación TMOProrroga
*****************************************************************/
public without sharing class SAC_Accion_AU_TRHan extends CC_TriggerHandlerBase {

    private static Set<String> objetos = new Set<String>{'SAC_Accion__c', 'SAC_TMECaso__c', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private final static Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private final static Id RECTYPEACCIONRESPONDERESC = mapRTsObjects.get('SAC_Accion__c').get('SAC_AccionResponderEsc').getRecordTypeId();
    private final static Id RECTYPETMETAREA = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMETarea').getRecordTypeId();
    private final static Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private final static Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.oldMap);
	}

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapOldObj){
        List<SAC_Accion__c> listNewObjSAC = new List<SAC_Accion__c>();
        Map<Id, SAC_Accion__c> mapOldObjSAC = new Map<Id, SAC_Accion__c>();

        for(SAC_Accion__c accion : listNewObj){
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                listNewObjSAC.add(accion);
            }
        }

        for(SAC_Accion__c accion : mapOldObj.values()){
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                mapOldObjSAC.put(accion.Id, accion);
            }
        }

        if (!listNewObjSAC.isEmpty()) {
            processSAC(listNewObjSAC, mapOldObjSAC);
        }
    }

    private void processSAC(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapOldObj){

        map<Id, decimal> pretenImporteAbonado = new map<Id, decimal>();
        map<Id, decimal> pretenImporteResuelto = new map<Id, decimal>();
        map<Id, decimal> pretenAccion = new map<Id, decimal>();

        List<SAC_TMECaso__c> tmeTareas = new List<SAC_TMECaso__c>();  //Lista para crear los tme de Tareas
        Boolean clicProrrogaFinal = false;
        SAC_Accion__c tarea = new SAC_Accion__c();

        for(SAC_Accion__c accion : listNewObj){
            decimal calculadoAbonado = 0.0;
            decimal calculadoResuelto = 0.0;
            
            //Si se ha clicado en Prorroga en la tarea, se creará un tme de prorroga que se asociará a esta
            //If donde se compruebe si ya se ha prorrogado, en caso de no, crear el tme
            if(accion.SAC_ProrrogaTareaCheck__c == true){
                
                //Nunca antes he prorrogado, creo un nuevo TME
                if(String.isBlank(accion.SAC_TMEProrroga__c)){
                    SAC_TMECaso__c tme = new SAC_TMECaso__c();
                    tme.name = 'Prorroga de la tarea'; // TME de prorroga de la tarea
                    tme.RecordTypeId = RECTYPETMETAREA;
                    tme.SAC_Accion__c= accion.id;
                    tmeTareas.add(tme);
                }

                /* Código necesario en caso de que cada vez que se pulse en el botón prorroga se cree un nuevo tme, sustituyendo al anterior.
                // clicProrrogaFinal = true;
                // tarea.id = tme.SAC_Accion__c;
                // tarea.SAC_ProrrogaTareaCheck__c = false;
                */   
            }
            
            if(accion.SAC_Estado__c != mapOldObj.get(accion.Id).SAC_Estado__c &&
            (accion.SAC_Estado__c == 'SAC_Descartada' || mapOldObj.get(accion.Id).SAC_Estado__c == 'SAC_Descartada')) {
                if(accion.SAC_Estado__c == 'SAC_Descartada') {
                    calculadoAbonado = calcularDescartado(calculadoAbonado, mapOldObj.get(accion.Id).SAC_ImporteAbonar__c, -1);
                    calculadoResuelto = calcularDescartado(calculadoResuelto, mapOldObj.get(accion.Id).SAC_ImporteResuelto__c, -1) + 
                    calcularDescartado(calculadoResuelto, mapOldObj.get(accion.Id).SAC_ImpResueltoInteresesLegales__c, -1);
                } else if(mapOldObj.get(accion.Id).SAC_Estado__c == 'SAC_Descartada') {
                    calculadoAbonado = calcularDescartado(calculadoAbonado, accion.SAC_ImporteAbonar__c, 1);
                    calculadoResuelto = calcularDescartado(calculadoResuelto, accion.SAC_ImporteResuelto__c, 1) +
                    calcularDescartado(calculadoResuelto, accion.SAC_ImpResueltoInteresesLegales__c, 1);
                }
            } else {
                if(accion.SAC_ImporteAbonar__c != mapOldObj.get(accion.Id).SAC_ImporteAbonar__c) {
                    calculadoAbonado = calcularDiferencia(mapOldObj.get(accion.Id).SAC_ImporteAbonar__c, accion.SAC_ImporteAbonar__c);
                }
                //el importeAbonarCalc es la suma del importeResuelto/Revisado + importe resuelto intereses legales y su suma es el total resuelto          
                if(accion.SAC_ImporteAbonarCalc__c != mapOldObj.get(accion.Id).SAC_ImporteAbonarCalc__c) {
                    calculadoResuelto = calcularDiferencia(mapOldObj.get(accion.Id).SAC_ImporteAbonarCalc__c, accion.SAC_ImporteAbonarCalc__c);
                }
            }      

            if(calculadoAbonado != 0) {
                mapearImporte(accion, pretenImporteAbonado, calculadoAbonado);
            }
            if(calculadoResuelto != 0) {
                mapearImporte(accion, pretenImporteResuelto, calculadoResuelto);
            }
        }

        updatearReclamaPreten(pretenImporteAbonado, pretenImporteResuelto);

        /* Código necesario en caso de que cada vez que se pulse en el botón prorroga se cree un nuevo tme, sustituyendo al anterior.
        //Updateamos la tarea, con el valor de SAC_ProrrogaTareaCheck__c a falso, lo que indicará que en proximos update (que no se correspondan con una porroga) 
        //no se ha pulsado el botón prorroga de la tarea, y por lo tanto no se creará un nuevo tme.
        if(clicProrrogaFinal == true){
            update tarea;       
        }
        */
        
        insert tmeTareas; 
    }

    /*****************************************************************
     * Name: calcularDiferencia
     * Copyright © 2022  CaixaBank
     * 
     * Proposito: calcular la diferencia en importe respecto al importe anterior
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US356803        alex perez     19/10/22      Creación
    *****************************************************************/
    private decimal calcularDiferencia(decimal importeAnterior, decimal importeActual) {
        decimal calculado = 0.0;
        if(importeActual != importeAnterior) {
            //decimal calculado;
            //calcular la diferencia del valor anterior
            if(importeActual == null) {
                calculado = importeAnterior*(-1);
            } else if(importeAnterior == null) {
                calculado = importeActual;
            } else {
                calculado = importeActual - importeAnterior;
            }
        }
        return calculado;
    }

    /*****************************************************************
     * Name: calcularDescartado
     * Copyright © 2022  CaixaBank
     * 
     * Proposito: resta o suma en funcion si la tarea se descarta o se vuelve 
     * a tener en cuenta cuando ya se había descartado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US356803        alex perez     19/10/22      Creación
    *****************************************************************/
    private decimal calcularDescartado(decimal sumatorio, decimal importeAnterior, integer signo) {

        if(importeAnterior != null) {
            sumatorio += importeAnterior*signo;
        }
        return sumatorio;
    }

    /*****************************************************************
     * Name: mapearImporte
     * Copyright © 2022  CaixaBank
     * 
     * Proposito: meter el importe calculado en el mapa correcto
     * usado en SAC_Accion_AD_TRHan
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US356803        alex perez     19/10/22      Creación
    *****************************************************************/
    public void mapearImporte(SAC_Accion__c tarea, map<Id, decimal> mapImporte, decimal importe) {
 
        id caseId = tarea.SAC_Pretension__c != null ? tarea.SAC_Pretension__c : tarea.SAC_Reclamacion__c;
        if(mapImporte.containsKey(caseId)) {
                
            mapImporte.put(caseId, mapImporte.get(caseId) + importe);
        } else {
            mapImporte.put(caseId, importe);
        }
    }

    /*****************************************************************
     * Name: mapearImporte
     * Copyright © 2022  CaixaBank
     * 
     * Proposito: meter el importe calculado en el mapa correcto
     * usado en SAC_Accion_AD_TRHan
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US356803        alex perez     19/10/22      Creación
     * 1.1            US1063712       Raúl Santos    15/11/24      Modificación: Añadida la llamada al método calcularImportes()
    *****************************************************************/
    public void updatearReclamaPreten(map<Id, decimal> pretenImporteAbonado, map<Id, decimal> pretenImporteResuelto) {

        Set<Id> setIdesRec = new Set<Id>();

        list<Case> casosUpdate = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c, SAC_Reclamacion__C, RecordTypeId FROM Case WHERE Id IN : pretenImporteAbonado.KeySet() OR Id IN : pretenImporteResuelto.KeySet()];
        for(Case caso : casosUpdate) {
            if(pretenImporteAbonado.containsKey(caso.Id)) {
                if(caso.CC_Importe_Abonado__c == null) {
                    caso.CC_Importe_Abonado__c = pretenImporteAbonado.get(caso.Id);
                } else {
                    caso.CC_Importe_Abonado__c += pretenImporteAbonado.get(caso.Id);
                }  
            }
            if(pretenImporteResuelto.containsKey(caso.Id)) {
                if(caso.SAC_Importe_Resuelto__c == null) {
                    caso.SAC_Importe_Resuelto__c = pretenImporteResuelto.get(caso.Id);
                } else {
                    caso.SAC_Importe_Resuelto__c += pretenImporteResuelto.get(caso.Id);
                }
            }
            if(caso.RecordTypeId == RECTYPEPRETENSION){
                setIdesRec.add(caso.SAC_Reclamacion__C);
            }
        }

        //Actualizar las reclamaciones/pretensiones con sus importes correspondientes
        // update casosUpdate;
        SAC_DatabaseDML.updateListDML(casosUpdate, false);

        //Cuando se actualiza el importe abonado/resuelto en una tarea (creada en la pretensión) los cambios no se reflejan en la reclamación ya que no entra por el trigger SAC_Case_AU.
        //Por ello, se simula el funcionamiento a seguir con este método.
        calcularImportes(setIdesRec);
    }

    /**
    * @description método que actualiza los importes de la reclamación cuando se actualiza una tarea de una pretensión
    */
    public void calcularImportes(Set<Id> setIdsReclamacion) {
        List<Case> listCasosSelect = [SELECT Id, RecordTypeId, SAC_Reclamacion__c, CC_Importe_Reclamado__c, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c, SAC_Quebranto__c, Status FROM Case 
                                        WHERE (RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsReclamacion) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__C IN :setIdsReclamacion)];
        
        if (setIdsReclamacion == null) {
            setIdsReclamacion = new Set<Id>();
        }

        Map<Id, List<Case>> mapListPretensiones = new Map<Id, List<Case>> ();
		List<Case> listReclaUpdatear = new List<Case> ();
        Map<Id, Case> mapaDatosCasosActualizar = new Map<Id, Case>();

        for (Id ide : setIdsReclamacion) {
            mapListPretensiones.put(ide, new List<Case>());
        }

		for (Case csPre : listCasosSelect) {
            if(csPre.RecordTypeId == RECTYPEPRETENSION){
                if (mapListPretensiones.containsKey(csPre.SAC_Reclamacion__c)) {
                    mapListPretensiones.get(csPre.SAC_Reclamacion__c).add(csPre);
                }
            }
		}

        if(!mapListPretensiones.isEmpty()){
            listReclaUpdatear = SAC_CaseCalcularImporte.calcularImporte(mapListPretensiones);
        }

        if(!listReclaUpdatear.isEmpty()){
            for (Case caso : listReclaUpdatear) {
                if(mapaDatosCasosActualizar.containsKey(caso.id)){
                    mapaDatosCasosActualizar.get(caso.id).CC_Importe_Reclamado__c = caso.CC_Importe_Reclamado__c;
                    mapaDatosCasosActualizar.get(caso.id).CC_Importe_Abonado__c = caso.CC_Importe_Abonado__c;
                }else{
                    mapaDatosCasosActualizar.put(caso.id, caso);
                }
            }
        }

        SAC_DatabaseDML.updateListDML(mapaDatosCasosActualizar.values(), false);
    }
}