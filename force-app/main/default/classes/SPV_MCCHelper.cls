public with sharing class SPV_MCCHelper {

    private static Set<String> objetos = new Set<String>{'CC_MCC__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEDETALLE = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
    private static final Id RECTYPEPRODUCTO = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
    private static final Id RECTYPEMOTIVO = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
  
     /**************************************************************************
     * Proposito: Cuando se activa/desactiva el check SPV_BalanceoForzado__c en un MCC, los niveles de MCC que vayan por debajo de este deben activar/desactivar
     * este campo acorde con el valor del MCC superior
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE        Description
     * 1.0             US909081      Raúl Santos     10/06/24       Creación
    **************************************************************************/ 
    public static void checkBalaceoForzado(List<CC_MCC__c> lstMCC, Map<Id, CC_MCC__c> mapNewObj){

        Set<Id> idsMcc = new Set<Id>();
        Map<Id, Boolean> mapaMccEscalado = new Map<Id, Boolean>();

        for(CC_MCC__c mcc : lstMCC){
            idsMcc.add(mcc.Id);
            mapaMccEscalado.put(mcc.Id, mcc.SPV_BalanceoForzado__c);
        }

        if(Schema.sObjectType.CC_MCC__c.isAccessible()){
            List<CC_MCC__c> listaMccHijos = [SELECT id, RecordType.DeveloperName, SPV_BalanceoForzado__c, CC_Tematica__c, CC_Producto_Servicio__c, CC_Motivo__c, CC_Producto_Servicio__r.CC_Tematica__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c FROM CC_MCC__c WHERE CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__c IN :idsMcc OR CC_Motivo__c IN :idsMcc
                                            OR CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Motivo__r.CC_Producto_Servicio__c IN :idsMcc];

            try { 
                for(CC_MCC__c mcc : listaMccHijos) {
                    if(mcc.RecordTypeId == RECTYPEPRODUCTO){
                        if(mapaMccEscalado.containsKey(mcc.CC_Tematica__c)){
                            mcc.SPV_BalanceoForzado__c = mapaMccEscalado.get(mcc.CC_Tematica__c);
                        }
                    }else if(mcc.RecordTypeId == RECTYPEMOTIVO){
                        if(mapaMccEscalado.containsKey(mcc.CC_Producto_Servicio__c)){
                            mcc.SPV_BalanceoForzado__c = mapaMccEscalado.get(mcc.CC_Producto_Servicio__c);
                        }else if(mapaMccEscalado.containsKey(mcc.CC_Producto_Servicio__r.CC_Tematica__c)){
                            mcc.SPV_BalanceoForzado__c = mapaMccEscalado.get(mcc.CC_Producto_Servicio__r.CC_Tematica__c);
                        }
                    }else if(mcc.RecordTypeId == RECTYPEDETALLE){
                        if(mapaMccEscalado.containsKey(mcc.CC_Motivo__c)){
                            mcc.SPV_BalanceoForzado__c = mapaMccEscalado.get(mcc.CC_Motivo__c);
                        }else if(mapaMccEscalado.containsKey(mcc.CC_Motivo__r.CC_Producto_Servicio__c)){
                            mcc.SPV_BalanceoForzado__c = mapaMccEscalado.get(mcc.CC_Motivo__r.CC_Producto_Servicio__c);
                        }else if(mapaMccEscalado.containsKey(mcc.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c)){
                            mcc.SPV_BalanceoForzado__c = mapaMccEscalado.get(mcc.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c);
                        }
                    }
                }
                
                SPV_DatabaseDML.updateListDML(listaMccHijos, true);

            } catch (Exception e) {
                CBK_Log.error(e);
            }    
        }
    }

    /*****************************************************************
     * Proposito: Cuando en un MCC se añade un nuevo grupo colaborador se valida antes de añadirlo que si tiene el check de BalanceoForzado marcado, ese MCC solo puede tener un
     * grupo colaborador asociado, mostrando un mensaje informativo en caso de tener ya un grupo.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/ 
    public static void comprobarGruposColaboradores(List<CC_MCC__c> lstMCC){

        Set<Id> idsMcc = new Set<Id>();
        Map<Id, List<CC_MCC_Grupo_Colaborador__c>> mapaMccGrupo = new Map<Id, List<CC_MCC_Grupo_Colaborador__c>>();

        for(CC_MCC__c mcc : lstMCC){
            idsMcc.add(mcc.Id);
        }

        if(Schema.sObjectType.CC_MCC_Grupo_Colaborador__c.isAccessible()){
            List<CC_MCC_Grupo_Colaborador__c> listTodosGruposColabMcc = [SELECT Id, CC_MCC__c FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c IN :idsMcc AND SPV_Tipo_Cliente__c = 'SPV'];

            if(!listTodosGruposColabMcc.isEmpty()){

                for(CC_MCC_Grupo_Colaborador__c grupo : listTodosGruposColabMcc){
                    if(!mapaMccGrupo.containsKey(grupo.CC_MCC__c)){    //Si el MCC  no está en el mapa, se añade la el MCC y el gruo
                        List<CC_MCC_Grupo_Colaborador__c> listaGrupos = new List<CC_MCC_Grupo_Colaborador__c>();
                        listaGrupos.add(grupo);
                        mapaMccGrupo.put(grupo.CC_MCC__c, listaGrupos);
                    }else{ //Si el MCC sí está, se actualiza el mapa de grupos añadiendo la nueva
                        List<CC_MCC_Grupo_Colaborador__c> listaGrupos = mapaMccGrupo.get(grupo.CC_MCC__c);
                        listaGrupos.add(grupo);
                        mapaMccGrupo.put(grupo.CC_MCC__c, listaGrupos);
                    }
                }

                for(CC_MCC__c mcc : lstMCC){
                    if(mapaMccGrupo.containsKey(mcc.Id)){
                        List<CC_MCC_Grupo_Colaborador__c> gruposMCC = mapaMccGrupo.get(mcc.Id);
                        
                        if(gruposMCC.size() > 1){
                            mcc.addError('Para activar el balanceo forzado, el MCC solo puede tener un grupo colaborador asociado.');
                        }
                    }
                }
            }
        }
    }
    /**************************************************************************
    * Proposito: Añadir identificador ATR a todos los MCCs. 
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE        Description
    * 1.0             			      Iria ANPC      20/11/24       Creación
    **************************************************************************/ 
    /*public static void checkExistingMCC(List<CC_MCC__c> listNewObj) {
        List<String> tematicaIds = new List<String>();
        List<String> motivoIds = new List<String>();
        Decimal highestValueProducto = 0;
        Decimal highestValueMotivo = 0;
        // Get MCC highest value
        List<CC_MCC__c> highestValueMCCProducto = [SELECT Id, SPV_IdProductoATR__c FROM CC_MCC__c WHERE SPV_IdProductoATR__c != null AND Id NOT IN: listNewObj ORDER BY SPV_IdProductoATR__c DESC LIMIT 1];
        if(!highestValueMCCProducto.isEmpty()){
            if(highestValueMCCProducto[0].SPV_IdProductoATR__c != null){
                highestValueProducto = highestValueMCCProducto[0].SPV_IdProductoATR__c;
            }
        }
        List<CC_MCC__c> highestValueMCCMotivo = [SELECT Id, SPV_IdMotivoATR__c FROM CC_MCC__c WHERE SPV_IdMotivoATR__c != null AND Id NOT IN: listNewObj ORDER BY SPV_IdMotivoATR__c DESC LIMIT 1];
        if(!highestValueMCCMotivo.isEmpty()){
            if(highestValueMCCMotivo[0].SPV_IdMotivoATR__c != null){
                highestValueMotivo = highestValueMCCMotivo[0].SPV_IdMotivoATR__c;
            }
        }
        // Get parent MCCs
        for(CC_MCC__c mcc : listNewObj){   
            if(mcc.RecordTypeId == RECTYPEPRODUCTO && mcc.CC_Tematica__c != null){
                tematicaIds.add(mcc.CC_Tematica__c);
            }else if(mcc.RecordTypeId == RECTYPEDETALLE && mcc.CC_Motivo__c != null){
                motivoIds.add(mcc.CC_Motivo__c);
            }
        }
        // Get sibling MCC highest value
        Map<Id, Decimal> mapMCCs = new Map<Id, Decimal>();
        for(CC_MCC__c mcc: [SELECT Id, RecordTypeId, CC_Tematica__c, CC_Motivo__c, SPV_Nivel2ATR__c FROM CC_MCC__c WHERE CC_Tipo_Cliente__c = 'SAC' AND ((CC_Tematica__c IN: tematicaIds AND RecordTypeId =: RECTYPEPRODUCTO) OR (CC_Motivo__c IN: motivoIds AND RecordTypeId =: RECTYPEDETALLE)) ORDER BY SPV_Nivel2ATR__c DESC]){
            if(mcc.RecordTypeId == RECTYPEPRODUCTO && !mapMCCs.containsKey(mcc.CC_Tematica__c)){
                mapMCCs.put(mcc.CC_Tematica__c, mcc.SPV_Nivel2ATR__c);
            }else if(mcc.RecordTypeId == RECTYPEDETALLE && !mapMCCs.containsKey(mcc.CC_Motivo__c)){
                mapMCCs.put(mcc.CC_Motivo__c, mcc.SPV_Nivel2ATR__c);
            }
        }
        // Update ID, Nivel 1 and Nivel 2
        for(CC_MCC__c mcc : listNewObj){
            // Temática
            if(mcc.RecordTypeId == RECTYPETEMATICA){
                highestValueProducto += 1;
                mcc.SPV_IdProductoATR__c = highestValueProducto;
                mcc.SPV_Nivel2ATR__c = 0;
            }
            // Producto/Servicio
            else if(mcc.RecordTypeId == RECTYPEPRODUCTO){
                highestValueProducto += 1;
                mcc.SPV_IdProductoATR__c = highestValueProducto;
                Decimal nivel2 = 1;
                if(mapMCCs.containsKey(mcc.CC_Tematica__c)){
                    nivel2 = mapMCCs.get(mcc.CC_Tematica__c) + 1;
                }
                mcc.SPV_Nivel2ATR__c = nivel2;
            }
            // Motivo
            else if(mcc.RecordTypeId == RECTYPEMOTIVO){
                highestValueMotivo += 1;
                mcc.SPV_IdMotivoATR__c = highestValueMotivo;
                mcc.SPV_Nivel2ATR__c = 0;
            }
            // Detalle
            else if(mcc.RecordTypeId == RECTYPEDETALLE){
                highestValueMotivo += 1;       
                mcc.SPV_IdMotivoATR__c = highestValueMotivo;
                Decimal nivel2 = 1;
                if(mapMCCs.containsKey(mcc.CC_Motivo__c)){
                    nivel2 = mapMCCs.get(mcc.CC_Motivo__c) + 1;
                }
                mcc.SPV_Nivel2ATR__c = nivel2;
            }
        }
    } */
}