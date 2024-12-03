/*****************************************************************
 * Name: SAC_MetodosSinSharing
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: funciones en las que es necesario mayor visibilidad sin que 
 * influyan las sharing rules
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            genIAl           Alexandre Pérez      23/11/2023   Creación
 * 1.1            US895283        Alexandre Pérez      18/04/24     cambio funcion modificarInsertarObjetos
 *                                                                   para que retorne los inserts/updates realizados
 * 1.2            US957620         Alexandre Pérez      15/07/2024   Modificación de creación reclamantes secundarios sin principal
****************************************************************/
public without sharing class SAC_MetodosSinSharing {

    /*funcion para poder detectar accounts que estén en AV_Confidencial que no son visibles
    para SAC necesarios para crear el registro CONFIDENCIAL en el proyecto genIAl*/
    public static list<account> listaDeClientesPorDoc(set<string> numDocumentos){
        list<account> listaAccount;
        if(Schema.SObjectType.Account.isAccessible()) {
            listaAccount = [SELECT id, CC_Numero_Documento__c, recordTypeId, AV_Confidencial__c, AV_Numperso__c 
                                            FROM Account WHERE CC_Numero_Documento__c != null AND CC_Numero_Documento__c IN : numDocumentos
                                            AND recordType.developerName IN ('CC_Cliente', 'CC_ClientePA', 'CC_Cliente', 'SAC_NoCliente_PA')];
        }
        return listaAccount;
    }

    /*updatear reclamación y los registros de sac_genial_resultado__c para el usuario de integración de genIAl sin sharing*/
    //utilizando database se guardaran los objetos que no generen error
    public static integer modificarInsertarObjetos(list<sObject> obj, string operacion){
        Database.SaveResult[] srList;
        boolean hasError = false;
        List<Object> errorObjs = new List<Object>();
        Map<String, String> errorMsjs = new Map<String, String>();
        integer registrosOK = 0;
        if(operacion == 'insert'){
            //unificar los dos bucles de errores en 1
            srList = Database.insert(obj, false);
            for (Integer i = 0; i < obj.size(); i++) {
                Database.SaveResult sr = srList[i];
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    errorMsjs.put(sr.getErrors()[0].getStatusCode() + '', ((String)sr.getErrors()[0].getMessage()));
                    errorObjs.add(obj[i]);
                    hasError = true;
                } else {
                    registrosOK++;
                }
            }
        } else {
            //update obj;
            srList = Database.update(obj, false);
            for (Integer i = 0; i < obj.size(); i++) {
                //unificar los dos bucles de errores en 1
                Database.SaveResult sr = srList[i];
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    errorMsjs.put(obj[i].Id, ((String)sr.getErrors()[0].getMessage()));
                    errorObjs.add(obj[i]);
                    hasError = true;
                } else {
                    registrosOK++;
                }
            } 
        }
        if(hasError) {
            CBK_Log.error(errorMsjs, errorObjs);
        }

        return registrosOK;
    }

    /*updatear reclamación y los registros de sac_genial_resultado__c para el usuario de integración de genIAl sin sharing*/
    //si hay un error en los datos de la operacion sera cazado por un catch superior
    public static void modificarInsertarObjetos(sObject obj, string operacion){
        if(operacion == 'insert'){
            insert obj;
        } else {
            update obj;
        }
    }

     /****************************************************************************************************************
     * @description : función que comprueba si existe ya un case reclamante asociado y si hay reclamantes secundarios
     * @params : 
     *      Entrada:
     *          casoId -> Id de la reclamación
     *          datosReclamante -> lista de reclamantes que se reciben de la integración SAC_Genial_WS
     *      Salida:
     *          resultado -> booleano true -> se tienen que insertar los reclamantes secundarios
     * 
     * Historial
     * -----------------------------------------------------------------------------------------------------------
     *   VERSION        USER_STORY       AUTHOR               DATE         Description
     *   1.0            US957620         Alex Pérez           15/07/2024   Creación
     *******************************************************************************************************************/  
    public static boolean comprobarCaseReclamante(Id casoId){
        //boolean resultado = false;
        list<SAC_CaseReclamante__c> listaReclamantes = new list<SAC_CaseReclamante__c>();
        if(Schema.SObjectType.SAC_CaseReclamante__c.isAccessible()) {
            listaReclamantes = [SELECT id FROM SAC_CaseReclamante__c 
                                WHERE SAC_Case__c = : casoId AND SAC_ReclamantePrincipal__c = true WITH SECURITY_ENFORCED];
        }
        if(!listaReclamantes.isEmpty()){
            /*for (SAC_Genial_WS.datosReclamante reclamante : datosReclamante) {
                if(!reclamante.reclamantePrincipal){
                    resultado = true;
                    break;
                }
            }*/
            return true;
        }

        return false;
    }
}