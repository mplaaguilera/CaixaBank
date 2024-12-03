/*****************************************************************
 * Name: SPV_CaseBITRHan
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Insert del objeto Case
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0               ---         Raúl Santos    08/05/24         Creación
*****************************************************************/

public with sharing class SPV_CaseBITRHan extends CC_TriggerHandlerBase{
    
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
	}

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {

        List<Case> listCasosSPV = SPV_CaseHelper.filtrarCasosSPV(listNewObj);
        List<Case> lstReclamaciones = new List<Case>();
        List<Case> lstPretensiones = new List<Case>();
        for(Case caso :listCasosSPV){
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                lstReclamaciones.add(caso);
            }else if(caso.RecordTypeId == RECTYPEPRETENSION){
                lstPretensiones.add(caso);
            }
        }

        if(!listCasosSPV.isEmpty()){
            Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

            SPV_CaseHelper.asignarEntitlementProcess(listCasosSPV); //Al añadir una reclamación, se le añade el entitlement process
            SPV_CaseHelper.asignarGrupoReclamacion(listCasosSPV); //Asigna el grupo proveedor de la reclamación que esté informado en el metadata SPV_Configuraciones__mdt, también añade la empresa del grupo a la reclamación
            SPV_CaseHelper.asignarFechaRecepcionYColaReclamacion(listCasosSPV, cola); //Al añadir una reclamación, se rellena la fecha de recepción
            SPV_CaseHelper.asignarDTyDAN(listcasosSPV, new Map<Id, Case>(), mapNewObj); //Al añadir una nueva reclamación, se comprueba su AccountId para asignarle un valor de DAN y DT (Dirección Territorial). El segundo parámetro es un mapa vacío porque es Insert.(Representa a mapOldObj)
        
            SPV_CaseHelper.usarDatosDeAlf(listCasosSPV, new Map<Id, Case>());   //Al insertar reclamación con cliente, se  rellenan los campos de la reclamación correspondientes

            SPV_CaseHelper.arrastrarReclamantePretension(listcasosSPV, new Map<Id, Case>(), mapNewObj);     //Al añadir una pretensión, se rellenan sus campso de reclamante con los de la reclamación
        }
        
     }



    }