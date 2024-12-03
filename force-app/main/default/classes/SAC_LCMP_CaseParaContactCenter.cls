/*****************************************************************
 * Name: SAC_LCMP_CaseParaContactCenter
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Cambiar el estado de la Reclamación a "Derivación" y 
 * apartir de esta crear un nuevo caso para que sea tratado en Contact center
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0            US213189         Marcela Neira   29/04/21      Creación Clase
*****************************************************************/
public with sharing class SAC_LCMP_CaseParaContactCenter {
    /************************************************************************************************************
     * Proposito:  Actualizar el estado del Case a 'Derivación' y Crear un Caso Nuevo para CC 
     *                                                        
     * Parameters: String con el id del Caso que Dispara la acción
     *                                                           
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                    US213189     Marcela Neira          29/04/2021         Creación
     * *********************************************************************************************************/
    @AuraEnabled
    public static void crearCase(String idCasoDisparador) {

        Id recType =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
       
        if (Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.Case.isCreateable()){

            
            Case casoParaContact = new Case();

            Case casoParaActualizar = [SELECT status, Description, Subject, ownerId, Origin
                                      FROM Case
                                      WHERE Id =: idcasoDisparador 
                                      AND RecordTypeId =: recType];                                     
         

            //Preparamos el caso con los datos necesarios para pasar a Contact Center
            casoParaContact.Description = casoParaActualizar.Description;
            casoParaContact.Subject =  casoParaActualizar.Subject;
            casoParaContact.ParentId = casoParaActualizar.Id; 
            casoParaContact.Origin = casoParaActualizar.Origin;
            //casoParaContact.Status =           
            //casoParaContact.Origin =
            //casoParaContact.recordTypeId = 
            //casoParaContact.CC_Idioma__c =
            //casoParaContact.AccountId =
            
            insert casoParaContact;

            //Ponemos el estado del caso  de SAC en Derivación
            casoParaActualizar.status = 'SAC_008'; 
            casoParaActualizar.SAC_StatusAuxiliar__c = 'SAC_008'; 
            update casoParaActualizar;

       }    
        
    }

    /************************************************************************************************************
     * Proposito: Comprobar si tiene que mostrar el botón de Derivar a Contact Center
     *                                                        
     * Parameters: String con el Id del usuario, String con el Id del Caso 
     *                                                           
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                    US213189     Marcela Neira          30/04/2021         Creación
     * *********************************************************************************************************/

    @AuraEnabled
    public static Boolean mostrarBoton(String idUsuario, String idCasoDisparador){
       
        Boolean noMostrar = true;

        try{
            Case casoDelUser =[SELECT id FROM  Case WHERE Owner.Id =: idUsuario  AND id =:idCasoDisparador]; 

            try{
                Case casoEnCC = [SELECT id FROM  Case WHERE parentId =: idCasoDisparador];
                noMostrar = true;
            }catch (Exception er){
                noMostrar = false;
            }               
                    
        } catch (Exception e) {            
            noMostrar = true;
        }
        
        return noMostrar;
             
    }
}