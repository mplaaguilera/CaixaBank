public with sharing class SPV_CaseBUTRHan extends CC_TriggerHandlerBase {


    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
   

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        //Llamada al método que filtra los casos de SPV
        List<Case> listCasosSPV = SPV_CaseHelper.filtrarCasosSPV(listNewObj);
            

        if(!listCasosSPV.isEmpty()){
            SPV_CaseHelper.rellenarCampos(listCasosSPV, mapOldObj);
            SPV_CaseHelper.validarCambioEstado(listCasosSPV, mapOldObj, mapNewObj);

            SPV_CaseHelper.asignarDTyDAN(listCasosSPV, mapOldObj, mapNewObj);   //Se comprobará si se ha actualizado el AccountId de una reclamación, si cambia, se actualiza su DAN y DT

            SPV_CaseHelper.asignarEmpresaReclamacion(listCasosSPV, mapOldObj);   //Si la lista de reclamaciones con grupo cambiado no está vacía, se le asignará la empresa del grupo
            
            SPV_CaseHelper.cambiarFechaAlegacionAllanamiento(listCasosSPV, mapOldObj);  //Si la reclamación cambia al estado de alegación o allanamiento, se actualiza su fecha correspondiente

            // SPV_CaseHelper.cambiarFechaAlegacionAllanamiento(listCasosSPV, mapOldObj);  //Si la reclamación cambia al estado de alegación o allanamiento, se actualiza su fecha correspondiente
            
            SPV_CaseHelper.camposRepresentanteValido(listCasosSPV, mapOldObj);    //Si se actualiza campo de representante, y se marca que se usarán sus datos, se actualizan los campos de la reclamación correspondientes

            SPV_CaseHelper.usarDatosDeAlf(listCasosSPV, mapOldObj);   //Si se actualiza el cliente de la reclamación, y se maraca que se usarán sus datos, se actualziam los campos necesarios

            SPV_CaseHelper.actualizarMCCYEntidadRelamacion(listCasosSPV, mapOldObj); //Si se actualiza el campo SAC_PretensionPrincipal__c en la reclamación, traemos la información del MCC de la pret principal y las entidasdes a la reclamación
        
            SPV_CaseHelper.guardarUsuario(listCasosSPV, mapOldObj); //Si se actualiza la reclamación a subestado 'Negociacion' se actualiza el campo CC_SuppliedUser__c de la reclamación

            SPV_CaseHelper.validarEntidadAfectadaReclamacion(listCasosSPV, mapOldObj); //Si se actualiza la entidad afectada de la reclamación, validar que el usuario tiene permisos para hacerlo

            SPV_CaseHelper.desactivarEscaladoAJ(listCasosSPV, mapOldObj);  //Si la reclamación cambia de estado se debe desactivar el campo SPV_EscaladoAJ__c de la reclamacion
       
           SPV_CaseHelper.arrastrarReclamantePretension(listCasosSPV, mapOldObj, new Map<Id, Case>()); //Al actualizar el AccountId una pretensión, se rellenan sus campso de reclamante con los de la reclamación
        }

        //Recuperar las colas del cache
        List<Group> listaColas = new List<Group>();
        Group cola;
        listaColas = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND  DeveloperName = 'SPV_PendienteAsignar'];

        if(!listaColas.isEmpty()){
            for (Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SPV_PendienteAsignar'){
                    cola = grupoAux;
                }
            }
        }

        String usuarioActual = UserInfo.getUserId();        //Se obtiene el id del usuario actual

        //Si hay casos de SPV almacenados en la lista de casos actualizados (con sus valores actualizados):
        List<Case> casosOwnerActualizados = new List<Case>();
        List<Case> listaRecCambioPretPrincipal = new List<Case>();
        List<Id> listaIdsRec = new List<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        if(!listCasosSPV.isEmpty()){
            for(Case caso: listCasosSPV){
                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId && caso.OwnerId != usuarioActual){      //Si el ownerId antiguo no es igual al nuevo, se añade a la lista de casos con owner cambiado
                    casosOwnerActualizados.add(caso);
                }
                if (caso.RecordTypeId == RECTYPERECLAMACION) {
                    listaReclamaciones.add(caso);

                    if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SAC_002') {
                        listaIdsRec.add(caso.Id);
                    }
                }
            }
        }

        //Si hay algúuna reclamación/pretensión con owner modificado, se llamará a permitirCambiarOwner
        if(!casosOwnerActualizados.isEmpty()){
                SPV_GrupoColaboradorContactHelper.permitirCambiarOwner(casosOwnerActualizados, mapOldObj, cola);
        }
        if(!listaIdsRec.isEmpty()){
            SPV_CaseHelper.marcarPretensionPrincipal(listaReclamaciones, listaIdsRec, listaRecCambioPretPrincipal); //En caso de Unipretensión, la pretension se marca como principal automáticamente (al pasar a estado Análisis)
            SPV_CaseHelper.validarPretensionPrincipal(listaReclamaciones, listaIdsRec); //En caso de multipretension, valida que la pretensión principal esté informada     
        }


    }

}