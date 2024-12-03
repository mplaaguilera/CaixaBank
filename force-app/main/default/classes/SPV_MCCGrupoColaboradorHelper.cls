/*****************************************************************
 * Name: SPV_MCCGrupoColaboradorHelper
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase controladora de los trigger del objeto CC_MCC_Grupo_colaborador__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US909081      Raúl Santos    24/06/24        Creación
****************************************************************/ 

public with sharing class SPV_MCCGrupoColaboradorHelper {

    private static Set<String> objetos = new Set<String>{'CC_MCC__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEDETALLE = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
    private static final Id RECTYPEPRODUCTO = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
    private static final Id RECTYPEMOTIVO = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
    private static final Id RECTYPETEMATICA = mapRTsObjects.get('CC_MCC__c').get('CC_Tematica').getRecordTypeId();
   
    /*****************************************************************
     * Proposito: Tras insertar un nuevo grupo colaborador en un MCC, este se debe heredar hacia los niveles inferiores del MCC insertandose también en estos.
     * Esta herencia se produce desde el nivel superior a los inferiores.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/ 
    public static void heredarGrupoColaborador(List<CC_MCC_Grupo_Colaborador__c> lstMCCColaborador){

        //Recuperar el nivel del MCC en el que se inserta, y sus niveles inferiores (no recuperaremos si es detalle ya que este no propagará el grupo colaborador)
        Set<Id> idsMcc = new Set<Id>();
        Map<Id, CC_MCC_Grupo_Colaborador__c> mapaMccGrupoColaborador = new Map<Id, CC_MCC_Grupo_Colaborador__c>();

        for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : lstMCCColaborador){
            idsMcc.add(mccGrupoColab.CC_MCC__c);
            mapaMccGrupoColaborador.put(mccGrupoColab.CC_MCC__c, mccGrupoColab);
        }

        if(Schema.sObjectType.CC_MCC__c.isAccessible()){
            List<CC_MCC__c> listaMccHijos = [SELECT id, RecordType.DeveloperName, SPV_BalanceoForzado__c, CC_Tematica__c, CC_Producto_Servicio__c, CC_Motivo__c, CC_Producto_Servicio__r.CC_Tematica__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c FROM CC_MCC__c WHERE CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__c IN :idsMcc OR CC_Motivo__c IN :idsMcc
                                            OR CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Motivo__r.CC_Producto_Servicio__c IN :idsMcc];

            try {
                List<CC_MCC_Grupo_Colaborador__c> listMccGruposColaboradores = new List<CC_MCC_Grupo_Colaborador__c>();
                for(CC_MCC__c mcc : listaMccHijos) {
                    if(mcc.RecordTypeId == RECTYPEPRODUCTO){
                        if(mapaMccGrupoColaborador.containsKey(mcc.CC_Tematica__c)){
                            CC_MCC_Grupo_Colaborador__c mccGrupoColab = crearMccGrupoColaborador(mcc, mapaMccGrupoColaborador.get(mcc.CC_Tematica__c));
                            listMccGruposColaboradores.add(mccGrupoColab);
                        }
                    }else if(mcc.RecordTypeId == RECTYPEMOTIVO){
                        if(mapaMccGrupoColaborador.containsKey(mcc.CC_Producto_Servicio__c)){
                            CC_MCC_Grupo_Colaborador__c mccGrupoColab = crearMccGrupoColaborador(mcc, mapaMccGrupoColaborador.get(mcc.CC_Producto_Servicio__c));
                            listMccGruposColaboradores.add(mccGrupoColab);
                        }else if(mapaMccGrupoColaborador.containsKey(mcc.CC_Producto_Servicio__r.CC_Tematica__c)){
                            CC_MCC_Grupo_Colaborador__c mccGrupoColab = crearMccGrupoColaborador(mcc, mapaMccGrupoColaborador.get(mcc.CC_Producto_Servicio__r.CC_Tematica__c));
                            listMccGruposColaboradores.add(mccGrupoColab);
                        }
                    }else if(mcc.RecordTypeId == RECTYPEDETALLE){
                        if(mapaMccGrupoColaborador.containsKey(mcc.CC_Motivo__c)){
                            CC_MCC_Grupo_Colaborador__c mccGrupoColab = crearMccGrupoColaborador(mcc, mapaMccGrupoColaborador.get(mcc.CC_Motivo__c));
                            listMccGruposColaboradores.add(mccGrupoColab);
                        }else if(mapaMccGrupoColaborador.containsKey(mcc.CC_Motivo__r.CC_Producto_Servicio__c)){
                            CC_MCC_Grupo_Colaborador__c mccGrupoColab = crearMccGrupoColaborador(mcc, mapaMccGrupoColaborador.get(mcc.CC_Motivo__r.CC_Producto_Servicio__c));
                            listMccGruposColaboradores.add(mccGrupoColab);
                        }else if(mapaMccGrupoColaborador.containsKey(mcc.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c)){
                            CC_MCC_Grupo_Colaborador__c mccGrupoColab = crearMccGrupoColaborador(mcc, mapaMccGrupoColaborador.get(mcc.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c));
                            listMccGruposColaboradores.add(mccGrupoColab);
                        }
                    }
                }
                
                SPV_DatabaseDML.insertListDML(listMccGruposColaboradores, false);

            } catch (Exception e) {
                CBK_Log.error(e);
            }    
        }
    }

    /*****************************************************************
     * Proposito: Creación de un nuevo CC_MCC_Grupo_colaborador__c
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/ 
    private static CC_MCC_Grupo_Colaborador__c crearMccGrupoColaborador (CC_MCC__c mcc, CC_MCC_Grupo_Colaborador__c mccGrupoColaborador){
        CC_MCC_Grupo_Colaborador__c mccGrupoColab = new CC_MCC_Grupo_Colaborador__c();

        mccGrupoColab.CC_Grupo_Colaborador__c = mccGrupoColaborador.CC_Grupo_Colaborador__c;
        mccGrupoColab.CC_MCC__c = mcc.Id;
        mccGrupoColab.Name = mccGrupoColaborador.Name;
        mccGrupoColab.SAC_MaximoDeCasosDiarios__c = mccGrupoColaborador.SAC_MaximoDeCasosDiarios__c;
        mccGrupoColab.SAC_PorcentajeAsignacion__c = mccGrupoColaborador.SAC_PorcentajeAsignacion__c;
        mccGrupoColab.SPV_Tipo_Cliente__c = mccGrupoColaborador.SPV_Tipo_Cliente__c;

        return mccGrupoColab;
    }

    /*****************************************************************
     * Proposito: Tras actualizar un grupo colaborador en un MCC, este se debe heredar hacia los niveles inferiores del MCC (si estos heredaron previamente ese grupo colaborador)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/ 
    public static void heredarActGrupoColaborador(List<CC_MCC_Grupo_Colaborador__c> lstMCCColaborador, Map<Id, CC_MCC_Grupo_Colaborador__c> mapOldObj){

        //Recuperar el nivel del MCC en el que se updatea, y sus niveles inferiores (no recuperaremos si es detalle ya que este no propagará el grupo colaborador)
        Set<Id> idsMcc = new Set<Id>();
        Set<Id> idsGrupoColab = new Set<Id>();
        Set<String> nameGrupoColab = new Set<String>();

        for (Id key : mapOldObj.keySet()) {
            CC_MCC_Grupo_Colaborador__c mccGrupoColab = mapOldObj.get(key);
            idsMcc.add(mccGrupoColab.CC_MCC__c);
            idsGrupoColab.add(mccGrupoColab.CC_Grupo_Colaborador__c);
            nameGrupoColab.add(mccGrupoColab.Name);
        }

        if(Schema.sObjectType.CC_MCC__c.isAccessible() && Schema.sObjectType.CC_MCC_Grupo_Colaborador__c.isAccessible()){
            List<CC_MCC__c> listaMccHijos = [SELECT Id FROM CC_MCC__c WHERE CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__c IN :idsMcc OR CC_Motivo__c IN :idsMcc
                                            OR CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Motivo__r.CC_Producto_Servicio__c IN :idsMcc];

            //Recuperamos el MCC Grupo Colaborador equivalente al que se actualiza.
            List<CC_MCC_Grupo_Colaborador__c> listaMccGrupoColab = [SELECT Id, CC_Grupo_Colaborador__c FROM CC_MCC_Grupo_Colaborador__c WHERE CC_Grupo_Colaborador__c IN :idsGrupoColab AND CC_MCC__c IN :listaMccHijos AND Name IN :nameGrupoColab];

            if(!listaMccGrupoColab.isEmpty()){
                List<CC_MCC_Grupo_Colaborador__c> listaMccGrupoColabToUpdate = new List<CC_MCC_Grupo_Colaborador__c>();
                Map<Id, CC_MCC_Grupo_Colaborador__c> mapaMccGrupoColaborador = new Map<Id, CC_MCC_Grupo_Colaborador__c>();

                for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : lstMCCColaborador){
                    mapaMccGrupoColaborador.put(mccGrupoColab.CC_Grupo_Colaborador__c, mccGrupoColab);
                }

                for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : listaMccGrupoColab){

                    CC_MCC_Grupo_Colaborador__c mccGrupoColaborador = mapaMccGrupoColaborador.get(mccGrupoColab.CC_Grupo_Colaborador__c);

                    //Actualiza los campos del registro mccGrupoColab
                    mccGrupoColab.Name = mccGrupoColaborador.Name;
                    mccGrupoColab.SAC_MaximoDeCasosDiarios__c = mccGrupoColaborador.SAC_MaximoDeCasosDiarios__c;
                    mccGrupoColab.SAC_PorcentajeAsignacion__c = mccGrupoColaborador.SAC_PorcentajeAsignacion__c;
                    mccGrupoColab.SPV_Tipo_Cliente__c = mccGrupoColaborador.SPV_Tipo_Cliente__c;
                    mccGrupoColab.CC_Grupo_Colaborador__c = mccGrupoColaborador.CC_Grupo_Colaborador__c;

                    //Agrega el registro actualizado a la lista listaMccGrupoColabToUpdate
                    listaMccGrupoColabToUpdate.add(mccGrupoColab);
                }

                SPV_DatabaseDML.updateListDML(listaMccGrupoColabToUpdate, true);
            }
        }
    }

    /*****************************************************************
     * Proposito: Tras eliminar un grupo colaborador en un MCC, este se debe eliminar de los niveles inferiores del MCC (si estos heredaron previamente ese grupo colaborador)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/ 
    public static void desheredarGrupoColaborador(List<CC_MCC_Grupo_Colaborador__c> lstMCCColaborador){

        //Recuperar el nivel del MCC en el que se elimina, y sus niveles inferiores (no recuperaremos si es detalle ya que este no propagará el grupo colaborador)
        Set<Id> idsMcc = new Set<Id>();
        Set<Id> idsGrupoColab = new Set<Id>();
        Set<String> nameGrupoColab = new Set<String>();

        for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : lstMCCColaborador){
            idsMcc.add(mccGrupoColab.CC_MCC__c);
            idsGrupoColab.add(mccGrupoColab.CC_Grupo_Colaborador__c);
            nameGrupoColab.add(mccGrupoColab.Name);
        }

        if(Schema.sObjectType.CC_MCC__c.isAccessible() && Schema.sObjectType.CC_MCC_Grupo_Colaborador__c.isAccessible()){
            List<CC_MCC__c> listaMccHijos = [SELECT Id FROM CC_MCC__c WHERE CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__c IN :idsMcc OR CC_Motivo__c IN :idsMcc
                                            OR CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Motivo__r.CC_Producto_Servicio__c IN :idsMcc];

            //Recuperamos el MCC Grupo Colaborador equivalente al que se actualiza.
            List<CC_MCC_Grupo_Colaborador__c> listaMccGrupoColab = [SELECT Id, CC_Grupo_Colaborador__c FROM CC_MCC_Grupo_Colaborador__c WHERE CC_Grupo_Colaborador__c IN :idsGrupoColab AND CC_MCC__c IN :listaMccHijos AND Name IN :nameGrupoColab];

            if(!listaMccGrupoColab.isEmpty()){
                List<CC_MCC_Grupo_Colaborador__c> listaMccGrupoColabToDelete = new List<CC_MCC_Grupo_Colaborador__c>();

                for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : listaMccGrupoColab){
                    //Agrega el registro actualizado a la lista listaMccGrupoColabToDelete
                    listaMccGrupoColabToDelete.add(mccGrupoColab);
                }

                SPV_DatabaseDML.deleteListDML(listaMccGrupoColabToDelete, true);
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
    public static void validarBalanceoForzado(List<CC_MCC_Grupo_Colaborador__c> lstMCCColaborador){

        Set<Id> idsMcc = new Set<Id>();
        Set<Id> idsMccBalanceo = new Set<Id>();
        Set<Id> setIdMCC = new Set<id>{ RECTYPETEMATICA, RECTYPEPRODUCTO, RECTYPEMOTIVO, RECTYPEDETALLE };

        for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : lstMCCColaborador){
            idsMcc.add(mccGrupoColab.CC_MCC__c);
        }

        List<CC_MCC__c> mccs = [SELECT Id, SPV_BalanceoForzado__c FROM CC_MCC__c WHERE RecordTypeId IN :setIdMCC AND Id IN :idsMcc];

        for(CC_MCC__c mcc : mccs){
            if(mcc.SPV_BalanceoForzado__c == true){
                idsMccBalanceo.add(mcc.Id);
            }
        }

        if(!idsMccBalanceo.isEmpty()){
            List<CC_MCC_Grupo_Colaborador__c> listTodosGruposColabMcc = [SELECT Id, CC_MCC__c FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c IN :idsMccBalanceo AND SPV_Tipo_Cliente__c = 'SPV'];

            if(!listTodosGruposColabMcc.isEmpty()){
                Set<Id> mccConGruposColab = new Set<Id>();
                for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : listTodosGruposColabMcc){
                    mccConGruposColab.add(mccGrupoColab.CC_MCC__c);
                }

                for(CC_MCC_Grupo_Colaborador__c mccGrupoColab : lstMCCColaborador){
                    if(mccConGruposColab.contains(mccGrupoColab.CC_MCC__c)){
                        mccGrupoColab.addError('Este MCC tiene el check de balanceo forzado activado, lo que implica que solo puede tener un grupo colaborador asociado.');
                    }
                }
            }
        }
    }
}