public with sharing class SPV_LCMP_PaginaDetalles {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c', 'SPV_Formulario__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //RT de escalado SPV
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    
    //Rec Type de Formulario
    private static final Id RECTYPEFORMNEGOCIACION = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioNegociacion').getRecordTypeId();
    private static final Id RECTYPEFORMCOMPLEMENTARIA = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioComplementarias').getRecordTypeId();
    private static final Id RECTYPEFORMRECTIFICACION = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioRectificacion').getRecordTypeId();
    private static final Id RECTYPEFORMDECISIONANALISIS = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioAnalisisDecision').getRecordTypeId();


    /*****************************************************************
    * Proposito: Updatear los objetos que vienen de la página de detalles
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0            US1126342     Sergio Martín     05/05/25        Creación
    *****************************************************************/
    /**
	 * @description    Updatear los objetos que vienen de la página de detalles
	 * @param recordsToUpdate
	 */
    @AuraEnabled
    public static void updateRecordsForm(List<SObject> recordsToUpdate) {
        if (recordsToUpdate == null || recordsToUpdate.isEmpty()) {
            throw new AuraHandledException('No se recibieron registros para actualizar.');
        }

        try {
            SPV_DatabaseDML.updateListDML(recordsToUpdate, false);
        } catch (DmlException e) {
            throw new AuraHandledException('Error al actualizar los registros: ' + e.getMessage());
        }
    }

    /*****************************************************************
    * Proposito: Recuperar las negociaciones de una reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1126342     Sergio Martín     07/02/25        Creación
    *****************************************************************/
    /**
	 * @description    Recuperar las negociaciones de una reclamación
	 * @param casoId
	 */
    @AuraEnabled
    public static NegociacionesReclamacionWrapper getNegociacionesReclamacion(String casoId) {
        List <SPV_Formulario__c> listaNegociacionPreviaInforme = new List<SPV_Formulario__c>();            //Almacenar las negociaciones previas al informe supervisor
        List <SPV_Formulario__c> listaNegociacionPosteriorInforme = new List<SPV_Formulario__c>();         //Almacenar las negociaciones posteriores al informe supervisor
        Boolean existeNegociacionPreviaInforme = false;
        Boolean existeNegociacionPosteriorInforme = false;  

        try{
            List<SPV_Formulario__c> listaFormulariosNegociacion = [SELECT id, SPV_EstadoNegociacion__c, SPV_NegociacionEnCurso__c, SPV_ResultadoNegociacion__c, SPV_MotivoRechazoNegociacion__c, SPV_FechaInicioNegociacion__c, SPV_FechaFinNegociacion__c 
                            FROM SPV_Formulario__c WHERE RecordTypeId =: RECTYPEFORMNEGOCIACION AND SPV_Caso__c =: casoId ORDER BY CreatedDate DESC];

            //Clasificar las negociaciones en función del tipo que sean
            if(!listaFormulariosNegociacion.isEmpty()){
                for(SPV_Formulario__c negociacion : listaFormulariosNegociacion){
                    if(negociacion.SPV_EstadoNegociacion__c == 'SPV_Rectificacion') { // Si la negociación se produce en estado de Rectificación es posterior al informe supervisor
                        listaNegociacionPosteriorInforme.add(negociacion);
                        existeNegociacionPosteriorInforme = true;
                    }else { // Si la negociación se produce en cualquier otro estado es previa al informe supervisor
                        listaNegociacionPreviaInforme.add(negociacion);
                        existeNegociacionPreviaInforme = true;
                    }
                }
                
                //Se construye el wrapper que se va a devolver, con todos las negociaciones
                NegociacionesReclamacionWrapper wrapperNegociaciones = new NegociacionesReclamacionWrapper(listaNegociacionPreviaInforme, existeNegociacionPreviaInforme, listaNegociacionPosteriorInforme, existeNegociacionPosteriorInforme);
                return wrapperNegociaciones;
            }else{
                //Devolver nada
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }    


    /*****************************************************************************************************
     * Proposito: Wrapper en el que se devolverán las negociaciones que se deben tener en cuenta de 
     * la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1208202    Sergio Martín     07/02/25        Creación
     *****************************************************************************************************/
    /**
	 * @description     Wrapper en el que se devolverán las negociaciones de la reclamación
	 */
    public class NegociacionesReclamacionWrapper{

        @AuraEnabled public List<SPV_Formulario__c> listNegociacionPreviaInforme {get; set;}
        @AuraEnabled public Boolean existeNegociacionPreviaInforme {get; set;}
        @AuraEnabled public List<SPV_Formulario__c> listNegociacionPosteriorInforme {get; set;}
        @AuraEnabled public Boolean existeNegociacionPosteriorInforme {get; set;}

        public NegociacionesReclamacionWrapper(List<SPV_Formulario__c> formNegociacionPreviaInforme, Boolean varExisteNegociacionPreviaInforme, List<SPV_Formulario__c> formNegociacionPosteriorInforme, Boolean varExisteNegociacionPosteriorInforme)
        {
            listNegociacionPreviaInforme = formNegociacionPreviaInforme;
            existeNegociacionPreviaInforme = varExisteNegociacionPreviaInforme;
            listNegociacionPosteriorInforme = formNegociacionPosteriorInforme;
            existeNegociacionPosteriorInforme = varExisteNegociacionPosteriorInforme;
        }
    }


    /*****************************************************************
    * Proposito: Recuperar las complementarias de una reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR           DATE         Description
    * 1.0            US1126342     Sergio Martín     09/04/25        Creación
    *****************************************************************/
    /**
	 * @description    Recuperar las complementarias de una reclamación
	 * @param casoId
	 */
    // @AuraEnabled
    // public static ComplementariasReclamacionWrapper getComplementariasReclamacion(String casoId) {
    //     List <SPV_Formulario__c> listaComplementariasEntidad = new List<SPV_Formulario__c>();            //Almacenar las complementarias entidad
    //     List <SPV_Formulario__c> listaComplementariasOrganismo = new List<SPV_Formulario__c>();         //Almacenar las complementarias organismo
    //     Boolean existeComplementariasEntidad = false;
    //     Boolean existeComplementariasOrganismo = false;  

    //     try{
    //         List<SPV_Formulario__c> listaFormulariosComplementarias = [SELECT id, SPV_TipoComplementaria__c FROM SPV_Formulario__c WHERE RecordTypeId =: RECTYPEFORMCOMPLEMENTARIA AND SPV_Caso__c =: casoId ORDER BY CreatedDate ASC];

    //         //Clasificar las complementarias en función del tipo que sean
    //         if(!listaFormulariosComplementarias.isEmpty()){
    //             for(SPV_Formulario__c complementaria : listaFormulariosComplementarias){
    //                 if(complementaria.SPV_TipoComplementaria__c == 'SPV_Organismo') { // Si la complementaria es de organismo
    //                     listaComplementariasOrganismo.add(complementaria);
    //                     existeComplementariasOrganismo = true;
    //                 }else if(complementaria.SPV_TipoComplementaria__c == 'SPV_Entidad'){ // Si la complementaria es de entidad
    //                     listaComplementariasEntidad.add(complementaria);
    //                     existeComplementariasEntidad = true;
    //                 }
    //             }
                
    //             //Se construye el wrapper que se va a devolver, con todas las complementarias
    //             ComplementariasReclamacionWrapper wrapperComplementarias = new ComplementariasReclamacionWrapper(listaComplementariasEntidad, existeComplementariasEntidad, listaComplementariasOrganismo, existeComplementariasOrganismo);
    //             return wrapperComplementarias;
    //         }else{
    //             //Devolver nada
    //             return null;
    //         }
    //     }catch(Exception e){
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }    
    @AuraEnabled
    public static ComplementariasReclamacionWrapper getComplementariasReclamacion(String casoId) {
        List <SPV_Formulario__c> listaComplementarias = new List<SPV_Formulario__c>();            //Almacenar las complementarias 
        Boolean existeComplementarias = false;  

        try{
            List<SPV_Formulario__c> listaFormulariosComplementarias = [SELECT id, SPV_TipoComplementaria__c, SPV_FechaAperturaEntidad__c, SPV_FechaAperturaOrganismo__c FROM SPV_Formulario__c WHERE RecordTypeId =: RECTYPEFORMCOMPLEMENTARIA AND SPV_Caso__c =: casoId ORDER BY CreatedDate DESC];

            //Clasificar las complementarias en función del tipo que sean
            if(!listaFormulariosComplementarias.isEmpty()){
                for(SPV_Formulario__c complementaria : listaFormulariosComplementarias){
                    listaComplementarias.add(complementaria);
                    existeComplementarias = true;
                }
                
                //Se construye el wrapper que se va a devolver, con todas las complementarias
                ComplementariasReclamacionWrapper wrapperComplementarias = new ComplementariasReclamacionWrapper(listaComplementarias, existeComplementarias);
                return wrapperComplementarias;
            }else{
                //Devolver nada
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }    


    /*****************************************************************************************************
     * Proposito: Wrapper en el que se devolverán las complementarias que se deben tener en cuenta de 
     * la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE         Description
     * 1.0            US1126342     Sergio Martín     09/04/25        Creación
     *****************************************************************************************************/
    /**
	 * @description     Wrapper en el que se devolverán las complementarias de la reclamación
	 */
    public class ComplementariasReclamacionWrapper{

        @AuraEnabled public List<SPV_Formulario__c> listComplementarias {get; set;}
        @AuraEnabled public Boolean existeComplementarias {get; set;}

        public ComplementariasReclamacionWrapper(List<SPV_Formulario__c> formComplementarias, Boolean varExisteComplementarias)
        {
            listComplementarias = formComplementarias;
            existeComplementarias = varExisteComplementarias;
        }
    }    


    /*****************************************************************
    * Proposito: Recuperar las rectificaciones de una reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR           DATE         Description
    * 1.0            US1126342     Sergio Martín     10/04/25        Creación
    *****************************************************************/
    /**
	 * @description    Recuperar las rectificaciones de una reclamación
	 * @param casoId
	 */
    @AuraEnabled
    public static RectificacionesReclamacionWrapper getRectificacionesReclamacion(String casoId) {
        List <SPV_Formulario__c> listaRectificaciones = new List<SPV_Formulario__c>();            //Almacenar las rectificaciones
        Boolean existeRectificaciones = false;

        try{
            List<SPV_Formulario__c> listaFormulariosRectificaciones = [SELECT id FROM SPV_Formulario__c WHERE RecordTypeId =: RECTYPEFORMRECTIFICACION AND SPV_Caso__c =: casoId ORDER BY CreatedDate ASC];

            if(!listaFormulariosRectificaciones.isEmpty()){
                for(SPV_Formulario__c rectificacion : listaFormulariosRectificaciones){
                    listaRectificaciones.add(rectificacion);
                    existeRectificaciones = true;
                }
                
                //Se construye el wrapper que se va a devolver, con todas las rectificaciones
                RectificacionesReclamacionWrapper wrapperRectificaciones = new RectificacionesReclamacionWrapper(listaRectificaciones, existeRectificaciones);
                return wrapperRectificaciones;
            }else{
                //Devolver nada
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }    


    /*****************************************************************************************************
     * Proposito: Wrapper en el que se devolverán las rectificaciones que se deben tener en cuenta de 
     * la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE         Description
     * 1.0            US1126342     Sergio Martín     10/04/25        Creación
     *****************************************************************************************************/
    /**
	 * @description     Wrapper en el que se devolverán las rectificaciones de la reclamación
	 */
    public class RectificacionesReclamacionWrapper{

        @AuraEnabled public List<SPV_Formulario__c> listRectificaciones {get; set;}
        @AuraEnabled public Boolean existeRectificaciones {get; set;}

        public RectificacionesReclamacionWrapper(List<SPV_Formulario__c> formRectificaciones, Boolean varExisteRectificaciones)
        {
            listRectificaciones = formRectificaciones;
            existeRectificaciones = varExisteRectificaciones;
        }
    }    


    /*****************************************************************
    * Proposito: Recuperar las decisiones de una reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR           DATE         Description
    * 1.0            US1126342     Sergio Martín     11/04/25        Creación
    *****************************************************************/
    /**
	 * @description    Recuperar las decisiones de una reclamación
	 * @param casoId
	 */
    @AuraEnabled
    public static DecisionesReclamacionWrapper getDecisionesReclamacion(String casoId) {
        List <SPV_Formulario__c> listaDecisiones = new List<SPV_Formulario__c>();            //Almacenar las decisiones
        Boolean existeDecisiones = false;

        try{
            List<SPV_Formulario__c> listaFormulariosDecisiones = [SELECT id FROM SPV_Formulario__c WHERE RecordTypeId =: RECTYPEFORMDECISIONANALISIS AND SPV_Caso__c =: casoId ORDER BY CreatedDate ASC];

            if(!listaFormulariosDecisiones.isEmpty()){
                for(SPV_Formulario__c decision : listaFormulariosDecisiones){
                    listaDecisiones.add(decision);
                    existeDecisiones = true;
                }
                
                //Se construye el wrapper que se va a devolver, con todas las decisiones
                DecisionesReclamacionWrapper wrapperDecisiones = new DecisionesReclamacionWrapper(listaDecisiones, existeDecisiones);
                return wrapperDecisiones;
            }else{
                //Devolver nada
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }    


    /*****************************************************************************************************
     * Proposito: Wrapper en el que se devolverán las decisiones que se deben tener en cuenta de 
     * la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE         Description
     * 1.0            US1126342     Sergio Martín     11/04/25        Creación
     *****************************************************************************************************/
    /**
	 * @description     Wrapper en el que se devolverán las decisiones de la reclamación
	 */
    public class DecisionesReclamacionWrapper{

        @AuraEnabled public List<SPV_Formulario__c> listDecisiones {get; set;}
        @AuraEnabled public Boolean existeDecisiones {get; set;}

        public DecisionesReclamacionWrapper(List<SPV_Formulario__c> formDecisiones, Boolean varExisteDecisiones)
        {
            listDecisiones = formDecisiones;
            existeDecisiones = varExisteDecisiones;
        }
    }    
}