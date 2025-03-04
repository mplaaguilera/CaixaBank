public with sharing class SPV_LCMP_CamposDesplegables {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

        //RT de escalado SPV
        private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();



    /*****************************************************************
     * Proposito: Recuperar los escalados de una reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1037919         Álex Polo     25/05/2024        Creación
     *****************************************************************/
    /**
	 * @description     Recuperar los escalados de una reclamación
	 * @param casoId
	 */

    @AuraEnabled(cacheable=true)    
    public static escaladosReclamacionWrapper getEscaladosReclamacion(String casoId){

        try{
            List <SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
            
                listaEscalados = [SELECT Id, CreatedDate, SAC_GrupoColaborador__r.Name, SAC_MotivoEscalado__c,SAC_Propuesta__c, SAC_FechaRespuesta__c,
                SPV_FechaEscalado__c, SPV_TipoRespuesta__c, SAC_Observaciones_Interaccion__c, SAC_CasoEscalado__r.CC_Importe_Reclamado__c, SPV_Importe__c, SPV_TipoAllanamiento__c,
                SPV_AnalisisSedeOrganismo__c 
                FROM SAC_Interaccion__c WHERE SAC_CasoEscalado__c = :casoId AND RecordTypeId = :RECTYPEESCALADO ORDER BY CreatedDate DESC];

            
            List <SAC_Interaccion__c> listaEscaladosAlegacion = new List<SAC_Interaccion__c>();                 //Almacenar los escalados que tienen de motivo: Alegación
            List <SAC_Interaccion__c> listaEscaladosAllanamiento = new List<SAC_Interaccion__c>();              //Almacenar los escalados que tienen de motivo: Allanamiento
            
            SAC_Interaccion__c escaladoAlegacion = new SAC_Interaccion__c();                                    //Solo se muestran los datos del último escalado de cada tipo
            SAC_Interaccion__c escaladoAllanamiento = new SAC_Interaccion__c();                                 //Solo se muestran los datos del último escalado de cada tipo


            //Clasificar los escalados en función del tipo que sean
            if(!listaEscalados.isEmpty()){
                for(SAC_Interaccion__c escalado : listaEscalados){
                    if(escalado.SAC_MotivoEscalado__c == 'SPV_Alegación'){
                        listaEscaladosAlegacion.add(escalado);
                    }else if(escalado.SAC_MotivoEscalado__c == 'SPV_Allanamiento'){
                        listaEscaladosAllanamiento.add(escalado);
                    }
                }

                //Solo coger el último escalado de cada tipo. El más reciente es el de la pos. 0, porque de la query se recuperaron en order desc. Y si solo hay uno, coincide con el pos. 0 también
                if(!listaEscaladosAlegacion.isEmpty()){
                    escaladoAlegacion = listaEscaladosAlegacion[0];
                }

                if(!listaEscaladosAllanamiento.isEmpty()){
                    escaladoAllanamiento = listaEscaladosAllanamiento[0];
                }



                //Se construye el wrapper que se va a devolver, con todos los escalados necesarios para el componente
                escaladosReclamacionWrapper wrapperEscalados = new escaladosReclamacionWrapper(escaladoAlegacion, escaladoAllanamiento);
                return wrapperEscalados;

            }else{
                //Devolver nada
                return null;
            }


        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }


    }    

    @AuraEnabled(cacheable=true)  
    public static List<RecordType> obtenerRecordTypes(){
        
        List<String> nombresObjetos = new List<String>{'Case', 'SAC_Interaccion__c', 'CBK_Case_Extension__c'};
        List<String> nombresRT = new List<String>{'SPV_Reclamacion', 'SPV_Escalado', 'SPV_ReclamacionCaseExt'};
        List<RecordType> listaRecordTypes = new List<RecordType>();

        
    listaRecordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType IN :nombresObjetos AND DeveloperName IN :nombresRT];
        
        return listaRecordTypes;
    }


    /*****************************************************************
     * Proposito: Wrapper en el que se devolveráán los escalados que se deben tener en cuenta de 
     * la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1037919         Álex Polo     25/05/2024        Creación
     *****************************************************************/
    /**
	 * @description     Wrapper en el que se devolverán los escalados de la reclamación
	 */
    public class EscaladosReclamacionWrapper{

        @AuraEnabled public SAC_Interaccion__c escaladoAlegacion {get; set;}
        @AuraEnabled public SAC_Interaccion__c escaladoAllanamiento {get; set;}

        public EscaladosReclamacionWrapper(SAC_Interaccion__c elEscaladoAlegaciones, SAC_Interaccion__c elEscaladoAllanamientos)
        {
            escaladoAlegacion = elEscaladoAlegaciones;
            escaladoAllanamiento = elEscaladoAllanamientos;
        }
    }



    
}