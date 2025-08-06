public with sharing class SPV_LCMP_OficinasAfectadas {


    private static Set<String> objetos = new Set<String>{'Case', 'SAC_ImagenDocumento__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //RT reclamaciones SPV
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();

    //RT del objeto intermedio reclamación-oficinas afectadas
    private static final Id RECTYPEOFICINAS = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SPV_OficinaAfectada').getRecordTypeId();


    /*****************************************************************
     * Proposito: Recuperar las oficinas afectadas de una reclamación al cargar el registro
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0          US1037919         Álex Polo     21/05/2024        Creación
     *****************************************************************/
    /**
	 * @description     Recuperar las oficinas afectadas de una reclamación al cargar el registro
	 * @param casoId -> Id del caso a obtener sus oficinas afectadas
	 */

    @AuraEnabled(cacheable=true)
    public static InfoOficinasWrapper getOficinasAfectadas(String casoId){
        List<SAC_ImagenDocumento__c> listaOficinasDevolver = new List<SAC_ImagenDocumento__c>();

        try{
            //Se obtienen los objetos intermedios de la reclamación actual, para obtener todas sus oficinas afectadas
            
                listaOficinasDevolver = [SELECT Id, SAC_Caso__c, SPV_DAN_OficinaAfectada__c, SPV_OficinaAfectada_Lookup__c, SPV_OficinaAfectada_Lookup__r.Name FROM SAC_ImagenDocumento__c WHERE RecordTypeId = :RECTYPEOFICINAS AND SAC_Caso__r.RecordTypeId = :RECTYPERECLAMACION AND SAC_Caso__c = :casoId];
            
            InfoOficinasWrapper infoOficinas = new InfoOficinasWrapper(listaOficinasDevolver);
            return infoOficinas;

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

    }


    /*****************************************************************
     * Proposito: Recuperar las oficinas afectadas de una reclamación al actualizar el registro
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0          US1037919         Álex Polo     21/05/2024        Creación
     *****************************************************************/
    /**
	 * @description     Recuperar las oficinas afectadas de una reclamación al actualizar el registro
	 * @param casoId 
	 */

    @AuraEnabled
    public static InfoOficinasWrapper getOficinasActualizadas(String casoId){
        List<SAC_ImagenDocumento__c> listaOficinasDevolver = new List<SAC_ImagenDocumento__c>();

        try{
            //Se obtienen los objetos intermedios de la reclamación actual, para obtener todas sus oficinas afectadas

            
                listaOficinasDevolver = [SELECT Id, SAC_Caso__c, SPV_DAN_OficinaAfectada__c, SPV_OficinaAfectada_Lookup__c, SPV_OficinaAfectada_Lookup__r.Name FROM SAC_ImagenDocumento__c WHERE RecordTypeId = :RECTYPEOFICINAS AND SAC_Caso__r.RecordTypeId = :RECTYPERECLAMACION AND SAC_Caso__c = :casoId];
            
            
            InfoOficinasWrapper infoOficinas = new InfoOficinasWrapper(listaOficinasDevolver);
            return infoOficinas;

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

    }


    /*****************************************************************
     * Proposito: Eliminar el registro de la oficina afectada relacionada con el caso
     * cuando se pulsa el botón de eliminar
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1037919       Álex Polo     21/05/2024       Creación
     *****************************************************************/
    /**
	 * @description     Eliminar el registro de la oficina afectada relacionada
	 * @param objetoIntermedioId 
     * @param casoId
     * @param ownerIdReclamacion
	 */

    @AuraEnabled
    public static void eliminarOficinaAfectada(String objetoIntermedioId, String casoId, String ownerIdReclamacion){
        if (!propietarioReclamacion(ownerIdReclamacion)) {
            throw new AuraHandledException('Debes ser el propietario del caso para poder realizar la acción');
        }

        List<SAC_ImagenDocumento__c> listaOficinasAfectadas = new List<SAC_ImagenDocumento__c>();
        SAC_ImagenDocumento__c oficinaAfectadaEliminar = new SAC_ImagenDocumento__c();

        //Se obtienen los objetos intermedios relaconados a la reclamación, para verificar que existe el que se va a eliminar antes de eliminarlo
        listaOficinasAfectadas = [SELECT Id, SAC_Caso__c, SPV_DAN_OficinaAfectada__c, SPV_OficinaAfectada_Lookup__c, SPV_OficinaAfectada_Lookup__r.Name FROM SAC_ImagenDocumento__c WHERE RecordTypeId = :RECTYPEOFICINAS AND SAC_Caso__r.RecordTypeId = :RECTYPERECLAMACION AND SAC_Caso__c = :casoId];

        //Se elimina la oficina seleccionada
        for(SAC_ImagenDocumento__c oficina : listaOficinasAfectadas){
            if(oficina.Id == objetoIntermedioId){
                oficinaAfectadaEliminar = oficina;
            }
        }

        SPV_DatabaseDML.deleteDML(oficinaAfectadaEliminar, true);

    }


    /*****************************************************************
     * Proposito: Comprobar que el user que realiza la acción es owner 
     * del caso (de la reclamación)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1037919       Álex Polo     21/05/2024       Creación
     *****************************************************************/
    /**
	 * @description     Comprobar que el user que realiza la acción es owner del caso
	 * @param ownerIdReclamacion 
	 */

    @AuraEnabled
    public static Boolean propietarioReclamacion(String ownerIdReclamacion) {
        Id usuarioActual = UserInfo.getUserId();
        if(usuarioActual == ownerIdReclamacion){
            return true;
        }else{
            return false;
        }
    }


        /*****************************************************************
     * Proposito: Wrapper en el que se devolverá la lista de oficinas afectadas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0          US1037919         Álex Polo     21/05/2024        Creación
     *****************************************************************/
    /**
	 * @description     Wrapper en el que se devolverá la lista de oficinas afectadas
	 */
    public class InfoOficinasWrapper{

        @AuraEnabled public List<SAC_ImagenDocumento__c> listOficinasActual {get; set;}

        public InfoOficinasWrapper(List<SAC_ImagenDocumento__c> listOficinas)
        {
            listOficinasActual = listOficinas;
        }
    }

}