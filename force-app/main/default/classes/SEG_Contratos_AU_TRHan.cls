/**
*   @description SEG_Contratos_AU_TRHan
*/
public with sharing class SEG_Contratos_AU_TRHan  extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_Contratos__c>)tp.newList, (List<SEG_Contratos__c>)tp.oldList, (Map<ID, SEG_Contratos__c>)tp.newMap, (Map<ID, SEG_Contratos__c>)tp.oldMap);
	}
    private void process(List<SEG_Contratos__c> newList, List<SEG_Contratos__c> oldList, Map<ID, SEG_Contratos__c> newMap, Map<ID, SEG_Contratos__c> oldMap) {

        // Procesar las posibles nuevas marcas del contrato.
        Set<Id> listadoMarcasCuenta = new Set<Id>();
        Set<Id> listadoCuentasReclamacionesAgotadas = new Set<Id>();
        for (Id contratoId : newMap.keySet())
        {
            SEG_Contratos__c contratoNew = newMap.get(contratoId);
            SEG_Contratos__c contratoOld = oldMap.get(contratoId);

            if (contratoNew.SEG_Estado__c != contratoOld.SEG_Estado__c && 
                (contratoOld.SEG_Estado__c == 'Reclamaciones Agotadas' || contratoNew.SEG_Estado__c == 'Reclamaciones Agotadas'))
            {
                listadoCuentasReclamacionesAgotadas.add(contratoNew.SEG_NombreCuenta__c);
                listadoCuentasReclamacionesAgotadas.add(contratoOld.SEG_NombreCuenta__c);
            }
            listadoMarcasCuenta.add(contratoNew.SEG_NombreCuenta__c);
            listadoMarcasCuenta.add(contratoOld.SEG_NombreCuenta__c);
        }
        // Gestión de las marcas del cliente.
        if (!listadoMarcasCuenta.isEmpty())
        {
            SEG_Contratos_BI_TRHan.actualizarMarcasReclamaciones (listadoMarcasCuenta, listadoCuentasReclamacionesAgotadas);
        }

        // Procesar las excepciones del contrato.
        getExcepcionesContrato (newMap, oldMap);
    }

    /**
     * @description Gestión de excepciones de contratos.
     * @param newMap Mapa new del contexto del trigger.
     * @param oldMap Mapa old del contexto del trigger.
     */
    private void getExcepcionesContrato (Map<Id,SEG_Contratos__c> newMap, Map<Id,SEG_Contratos__c> oldMap)
    {
        List<Id> listaContratos = new List<Id>();
        for (Id contratoId : newMap.keySet())
        {
            SEG_Contratos__c contratoNew = newMap.get(contratoId);
            SEG_Contratos__c contratoOld = oldMap.get(contratoId);

            // Comprobar cambios que han de evaluar excepciones
            if (contratoNew.SEG_SR_Seguimiento__r?.SEG_Organizacion__c <> contratoOld.SEG_SR_Seguimiento__r?.SEG_Organizacion__c 
                || contratoNew.SEG_SR_Seguimiento__r?.SEG_Zona__c <> contratoOld.SEG_SR_Seguimiento__r?.SEG_Zona__c
                || contratoNew.SEG_SR_Seguimiento__r?.SEG_ClasificacionRapida__c <> contratoOld.SEG_SR_Seguimiento__r?.SEG_ClasificacionRapida__c 
                || contratoNew.SEG_SR_Seguimiento__r?.SEG_Grupo__c <> contratoOld.SEG_SR_Seguimiento__r?.SEG_Grupo__c
                || contratoNew.SEG_SR_Seguimiento__r?.SEG_Numero_de_centro__c <> contratoOld.SEG_SR_Seguimiento__r?.SEG_Numero_de_centro__c 
                || contratoNew.SEG_NombreCuenta__c <> contratoOld.SEG_NombreCuenta__c) 
            {
                listaContratos.add(contratoNew.Id);
            } 
        }

        // Gestionar las excepciones de los contratos.
        if (!listaContratos.isEmpty())
        {
            SEG_ExcepcionesHandler.calcularExcepcionesCasosYContratos(0, null, false, listaContratos);
        }
    }
 }