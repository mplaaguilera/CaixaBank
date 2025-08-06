public with sharing class SPV_BalanceoLetrado {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();   

    public static void determinarOwner(List<Case> listSelect, List<Case> reclamaciones, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar){

        List<Case> listaCasosBalancear = new List<Case>();
        Case reclamacion;
        List<Case> listaPretensiones = new List<Case>();
        for(Case caseReclamacion : reclamaciones){
            if(mapOldObj.containsKey(caseReclamacion.Id) && caseReclamacion.Status == 'SPV_AnalisisDecision' && mapOldObj.get(caseReclamacion.Id).Status == 'SAC_001'){
                listaCasosBalancear.add(caseReclamacion);
            }
        }

        if(!listaCasosBalancear.isEmpty()){
            reclamacion = listaCasosBalancear[0];   //Aunque se recibe una lista, el paso a Análisis y Decisión se hace a través del botón, asique recibe solo una reclamación
            Group cola = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

            //Para las reclamaciones con organismo BDE
            if(reclamacion.SPV_Organismo__c == 'SPV_BDE'){
                List<SAC_Marca_Case__c> marcasReclamacion = [SELECT Id, SAC_Marca__c, SAC_Marca__r.Name, SAC_Marca__r.SAC_OrdenPrelacion__c, SAC_Marca__r.SAC_GrupoLetrado__c  FROM SAC_Marca_Case__c WHERE SAC_Case__c =: reclamacion.Id AND SAC_Marca__r.SAC_OrdenPrelacion__c != null AND SAC_Marca__r.SAC_GrupoLetrado__c != null];
                listaPretensiones = [SELECT Id, SAC_Reclamacion__c, CBK_Case_Extension_Id__c FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c = :reclamacion.Id];

                if(!marcasReclamacion.isEmpty()){
                    balanceoPorMarca(marcasReclamacion, listaPretensiones, mapaDatosCasosActualizar, cola);
                }
            }


        }
    }

    public static void balanceoPorMarca(List<SAC_Marca_Case__c> marcasReclamacion, List<Case> listaPretensiones, Map<Id, Case> mapaDatosCasosActualizar, Group cola){

        if(marcasReclamacion.size() == 1){
            balancearPretensiones(listaPretensiones, mapaDatosCasosActualizar, marcasReclamacion[0].SAC_Marca__r.SAC_GrupoLetrado__c, false, cola);    //Si solo hay una, se utiliza esa directamente
        }else{
            Decimal ordenAux = marcasReclamacion[0].SAC_Marca__r.SAC_OrdenPrelacion__c;
            SAC_Marca_Case__c marcaBalanceo = marcasReclamacion[0];

            for(SAC_Marca_Case__c marca : marcasReclamacion){
                //Si alguna marca tiene un orden con más prioridad que la actual, se establecerá esa como Nueva marca para el balanceo
                if(marca.SAC_Marca__r.SAC_OrdenPrelacion__c < ordenAux){
                    ordenAux = marca.SAC_Marca__r.SAC_OrdenPrelacion__c;
                    marcaBalanceo = marca;
                }
            }
            balancearPretensiones(listaPretensiones, mapaDatosCasosActualizar, marcaBalanceo.SAC_Marca__r.SAC_GrupoLetrado__c, false, cola);
        }
    }

    private static void balancearPretensiones(List<Case> pretensiones, Map<Id, Case> mapaDatosCasosActualizar, Id grupoAsociado, Boolean end2End, Group cola){
        
        List<CBK_Case_Extension__c> listaCaseExtensionActualizar = new List<CBK_Case_Extension__c>();

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
                mapaDatosCasosActualizar.get(pretension.Id).OwnerId = cola.Id;
                mapaDatosCasosActualizar.get(pretension.Id).CC_Fecha_Traslado_Colaborador__c = CBK_UtilsDate.nowDT();
            }
            else{ 
                pretension.SEG_Grupo__c = grupoFinal;
                pretension.CC_Fecha_Traslado_Colaborador__c = CBK_UtilsDate.nowDT();
                pretension.OwnerId = cola.Id;
                mapaDatosCasosActualizar.put(pretension.Id, pretension);
            }

            //Actualizar y vaciar el campo Letrado Propietario del Case Extension
            /*CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Id = pretension.CBK_Case_Extension_Id__c;
            caseExtension.SPV_LetradoPropietario__c = null;
            listaCaseExtensionActualizar.add(caseExtension);*/

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

        if(!listaCaseExtensionActualizar.isEmpty()){
            SPV_DatabaseDML.updateListDML(listaCaseExtensionActualizar, true);
        }
    }
}