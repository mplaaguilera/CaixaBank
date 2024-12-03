/*****************************************************************
 * Name: SAC_LCMP_BuscadorTopic
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controller para el componente sAC_BuscadorTopic
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US300439       Marcela Neira   10/12/21     Creación
*****************************************************************/
public without sharing class SAC_LCMP_BuscadorTopic {

    public class MyException extends Exception {}

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPETEMAS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_Temas').getRecordTypeId();


    /*****************************************************************
     * Proposito: Busca la información incial (Caso y topics asignados) 
     *             y devuelve un Wrapper con la información para que el 
     *             Js la pueda tratar
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   10/12/21     Creación
     * 1.1            US520791       Raúl Santos     01/06/23     Modificación: recuperar los topics asignados al caso (tanto si estan activos como si fueron asignados y posteriormente inactivados)
    *****************************************************************/

    @AuraEnabled(cacheable=true) 
    public static TopicsWrapper cargarDatos(String idUsuario, String idCaso) {

        List<String> listaNombresTopics = new List<String>();
        Case caso= [SELECT id, OwnerId, SAC_PretensionPrincipal__r.OwnerId, Status FROM Case WHERE id =:idCaso limit 1];

        List<SAC_MaestroTemas__c> listTopics =  [SELECT Name FROM SAC_MaestroTemas__c 
                                                WHERE RecordTypeId =:RECTYPETEMAS];
        
        if(!listTopics.isEmpty()){
            for (SAC_MaestroTemas__c topicMaestro : listTopics) {
                listaNombresTopics.add(topicMaestro.Name);
            }
        }

        List<TopicAssignment> listaTopicsCaso = [SELECT id, TopicId 
                                                FROM TopicAssignment    
                                                WHERE EntityId =:caso.id 
                                                AND Topic.Name IN :listaNombresTopics
                                                ORDER BY CreatedDate DESC];

        Set<Id> idTopics = new Set<Id>();
        List<Topic> listaTopics = new List<Topic>();

        if(!listaTopicsCaso.isempty()){
            for (TopicAssignment ta : listaTopicsCaso) {
                idTopics.add(ta.TopicId);
            }
        }

        listaTopics = [SELECT id, Name, Description FROM Topic WHERE id in: idTopics];

        //Si el usuario es el owner de la reclamacion o de la pretension principal (es decir, todas las pretensiones) puede usar la aplicación
        Boolean esPropietario = (idUsuario == caso.OwnerId || idUsuario == caso.SAC_PretensionPrincipal__r.OwnerId) ? true : false;

        TopicsWrapper tw= new TopicsWrapper(esPropietario, listaTopics);
        return tw;
    }
    

    /*****************************************************************
     * Proposito: Busca dentro del maestro de topic los topic que están 
     *            activos para usar
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   10/12/21     Creación
    *****************************************************************/
    @AuraEnabled   
    public static List<SAC_MaestroTemas__c> getResultados(String nombre) {
        nombre = '%' + nombre +'%';
        return  [SELECT id, name FROM SAC_MaestroTemas__c WHERE Name like :nombre AND SAC_Activo__c = true AND RecordTypeId =:RECTYPETEMAS];
    }


    /*****************************************************************
     * Proposito: Hace la asignación de el topic al caso
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   10/12/21     Creación
     * 1.1            DE67918          Raúl Santos   07/11/22     Modificación: el propietario de la reclamación también debe poder añadir marcas
     * 1.2            US515064       Sergio Martín   14/02/23     Modificación: Añadido creación de registro del objeto junction SAC_Marca_Case__c
    *****************************************************************/
    @AuraEnabled
    public static void setTopicACase(String idCaso, String topic){
        try {
            Case caso= [SELECT id, OwnerId, SAC_PretensionPrincipal__r.OwnerId FROM Case WHERE id =:idCaso limit 1];
            if((caso.OwnerId == UserInfo.getUserId()) || (caso.SAC_PretensionPrincipal__r.OwnerId == UserInfo.getUserId())) {
                List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name, SAC_Activo__c FROM SAC_MaestroTemas__c WHERE Name = :topic AND SAC_Activo__c = true LIMIT 1];
                List<Topic> topicBD = [SELECT id FROM Topic WHERE  name = :topic];
                Topic t = new Topic();
                if(!temaEnMaestro.isEmpty() && topicBD.isEmpty()){
                    Topic tema = new Topic(Name = topic);        
                    Database.SaveResult result = Database.insert(tema, false); 
                }

                t = [SELECT id FROM Topic WHERE  name = :topic];
                TopicAssignment topicAssig = new TopicAssignment(TopicId=t.Id, EntityId=caso.Id);
                Database.insert(topicAssig);

                if(!temaEnMaestro.isEmpty()) {
                    // Creación del registro del objeto junction SAC_Marca_Case__c que relaciona la marca con el caso
                    SAC_Marca_Case__c marcaCaso = new SAC_Marca_Case__c(SAC_Case__c = caso.id, SAC_Marca__c = temaEnMaestro[0].id);
                    Database.insert(marcaCaso);
                }
                
            } else {
                throw new MyException('No eres el propietario de esta reclamación.');
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*****************************************************************
     * Proposito: Busca dentro de la BBDD si existe el Topic, si se puede
     *            usar y devuelve un boolean si no existe se crea tanto en 
     *            objeto estandar de Topics como en el Maestro
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   13/12/21     Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean newTopic(String topic){
        Boolean sePuedeUsar= false;
        //List<Topic> topicBD = [SELECT id FROM Topic WHERE  name = :topic];
        List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name, SAC_Activo__c FROM SAC_MaestroTemas__c WHERE Name = :topic AND SAC_Activo__c = true];
        if(!temaEnMaestro.isEmpty()){
            sePuedeUsar = true;
        }/*else{
            Topic tema = new Topic(Name = topic);        
            Database.SaveResult result = Database.insert(tema, false);
            if(result.isSuccess()){
                SAC_MaestroTemas__c temaMaestro = new SAC_MaestroTemas__c(Name = tema.Name);
                insert temaMaestro;
                sePuedeUsar = true;
            }         
        }*/
        
        return sePuedeUsar;
    }


    /*****************************************************************
     * Proposito: Borrar la asignacion de un topic a un case
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   14/12/21     Creación
     * 1.1            US515064       Sergio Martín   14/02/23     Modificación: Añadido eliminación de registro del objeto junction SAC_Marca_Case__c
    *****************************************************************/
    @AuraEnabled   
    public static void deleteTopicACase(String topic, String idCaso) {
        List<TopicAssignment> listaTopicsCaso = [SELECT id, TopicId 
                                                FROM TopicAssignment
                                                WHERE EntityId =: idCaso AND TopicId =: topic];
        Database.delete(listaTopicsCaso);

        Topic t = [SELECT name FROM Topic WHERE id = :topic];
        List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name FROM SAC_MaestroTemas__c WHERE Name =: t.name AND SAC_Activo__c = true];
        List<SAC_Marca_Case__c> listaMarcaCaso = [SELECT id 
                                                FROM SAC_Marca_Case__c
                                                WHERE SAC_Case__c =: idCaso AND SAC_Marca__c =: temaEnMaestro[0].id];
        Database.delete(listaMarcaCaso);
    }


    /*****************************************************************
     * Proposito: Recuperar el estado del caso a la hora de añadir/eliminar una marca
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US523475       Raúl Santos    22/06/23       Creación
    *****************************************************************/
    @AuraEnabled
    public static Case cargarEstado(String idCaso){
        return [SELECT id, Status FROM Case WHERE id =:idCaso LIMIT 1];
    }

    /*****************************************************************
     * Name: ReclamacionWrapper
     * Copyright © 2021  CaixaBank
     *                                                                                        
     * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
     *  del Lightning Web Component: sAC_BuscadorTopic.
     *                                                                                        
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439     Marcela Neira     10/12/21      Creación Clase
    *****************************************************************/


    public class TopicsWrapper{        
        
        @AuraEnabled public Boolean esPropietario {get; set;}
        @AuraEnabled public List<Topic> listaTopics {get; set;}
        
        public TopicsWrapper(Boolean esPropietarioActual, List<Topic> listaTopicsActual)
        {
            esPropietario = esPropietarioActual;
            listaTopics = listaTopicsActual;
        }
        
    }
}