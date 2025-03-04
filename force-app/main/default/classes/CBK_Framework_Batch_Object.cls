public with sharing class CBK_Framework_Batch_Object {
    
    /** 
    * US928820 - FWK Batch - Validation Rule Usuario Contexto Fase II
    * Cambiar interfaz de sobrecargas de métodos por un Builder.
    * Obligar a que el usuario de contexto sea obligado el utilizar el builder
    * Solamente coger los que tengan el usuario de contexto

    * 1.- Se recibe un registro del objeto : CBK_Framework_Batch__c
    * 2.- Solamente tiene que ejecutar el build si tiene usuario de contexto
    * 3.- Si lo tiene se ejecuta
    */
    public class BatchProcessConfig  {

        // Atributos privados
        private String tipo;
        private String usuariodecontexto;
        private Datetime proximaEjecucion;
        private Decimal priority;
        private Decimal batchSize;
        private String parametros;
        private Boolean notificarErrores;
        private String proyecto;
        private String emaildenotificacion;
        private String className;
        

        // Constructor privado
        private BatchProcessConfig (BatchProcessConfigBuilder builder) {
            this.tipo = builder.tipo;
            this.usuariodecontexto = builder.usuariodecontexto;
            this.proximaEjecucion = builder.proximaEjecucion;
            this.priority = builder.priority;
            this.batchSize = builder.batchSize;
            this.parametros = builder.parametros;
            this.notificarErrores = builder.notificarErrores;
            this.proyecto = builder.proyecto;
            this.emaildenotificacion = builder.emaildenotificacion;
            this.className = builder.className;

        }

        // Getters
        public String getTipo() { return tipo; }
        public String getUsuariodecontexto() { return usuariodecontexto; }
        public Datetime getProximaEjecucion() { return proximaEjecucion; }
        public Decimal getPriority() { return priority; }
        public Decimal getBatchSize() { return batchSize; }
        public String getParametros() { return parametros; }
        public Boolean getNotificarErrores() { return notificarErrores; }
        public String getProyecto() { return proyecto; }
        public String getEmaildenotificacion() { return emaildenotificacion; }
        public String getclassName() { return className; }
    }

     // Clase Builder
     public class BatchProcessConfigBuilder {
        String tipo;
        String usuariodecontexto;
        Datetime proximaEjecucion;
        Decimal priority;
        Decimal batchSize;
        String parametros;
        Boolean notificarErrores;
        String proyecto;
        String emaildenotificacion;
        String className;

       // Métodos del Builder para establecer los valores
       public BatchProcessConfigBuilder setClassName(String classname) {
            this.className = classname;
            return this;
        }

       public BatchProcessConfigBuilder setTipo(String tipo) {
           this.tipo = tipo;
           return this;
       }

       public BatchProcessConfigBuilder setUsuariodecontexto(String usuariodecontexto) {
           this.usuariodecontexto = usuariodecontexto;
           return this;
       }

       public BatchProcessConfigBuilder setProximaEjecucion(Datetime proximaEjecucion) {
           this.proximaEjecucion = proximaEjecucion;
           return this;
       }

       public BatchProcessConfigBuilder setPriority(Decimal priority) {
           this.priority = priority;
           return this;
       }

       public BatchProcessConfigBuilder setBatchSize(Decimal batchSize) {
           this.batchSize = batchSize;
           return this;
       }

       public BatchProcessConfigBuilder setParametros(String parametros) {
           this.parametros = parametros;
           return this;
       }

       public BatchProcessConfigBuilder setNotificarErrores(Boolean notificarErrores) {
           this.notificarErrores = notificarErrores;
           return this;
       }

       public BatchProcessConfigBuilder setProyecto(String proyecto) {
           this.proyecto = proyecto;
           return this;
       }

       public BatchProcessConfigBuilder setEmaildenotificacion(String emaildenotificacion) {
           this.emaildenotificacion = emaildenotificacion;
           return this;
       }

       // Método build para crear una instancia de MyClass
       public BatchProcessConfig  build() {

           if (usuariodecontexto == null || usuariodecontexto == '') {
               throw new IllegalArgumentException('El usuario de contexto no puede ser vacio.');
           }else {
               return new BatchProcessConfig (this);
           }
       }
   }

   public static Id executeBatchBuilder(BatchProcessConfigBuilder builder) {
    
        BatchProcessConfig myInstance = builder.build();
        
        // Lógica adicional para utilizar myInstance
        Id batchprocessid = executeBatch(myInstance);
        return batchprocessid;

    }

    /**
     * @description Formateo de fecha-hora
     * @return fecha hora en
     **/
    public static String timestamp() {
		return String.valueof(DateTime.now().getTime());
	}

     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @param priority   : Orden de ejecución (0=inmediata)
     * @param userContext   : Usuario de contexto de ejecución
	 * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(BatchProcessConfig myInstance){         
        Id batchprocessid;
       CBK_Framework_Batch__c jobDef;
       try {

            String classname = myInstance.getClassName();
            Integer prioridad = myInstance.getPriority().intValue();
            Integer batchSize = myInstance.getBatchSize().intValue();
            Map<String, Object> parametrosMap;

            if (myInstance.getParametros() != null && myInstance.getParametros() != '') {
                parametrosMap = (Map<String, Object>) JSON.deserializeUntyped(myInstance.getParametros());
            } else {
                parametrosMap = new Map<String, Object>();
            }


           //Alta del Batch
           if (Schema.sObjectType.CBK_Framework_Batch__c.isCreateable()) {

                jobDef = New CBK_Framework_Batch__c(name=myInstance.getClassName() + '_' + timestamp(),Class_Name__c= myInstance.getClassName());
                jobDef.tipo__c = myInstance.getTipo();
                jobDef.UsuarioContexto__c = myInstance.getUsuariodecontexto();
                jobDef.Notif__c = myInstance.getNotificarErrores();
                jobDef.Proyecto__c = myInstance.getProyecto();
                jobDef.Email_Notif__c = myInstance.getEmaildenotificacion();
                jobDef.NextExec__c=DateTime.now();
                jobDef.Priority__c = myInstance.getPriority();
                jobDef.BatchSize__c = batchSize;
                jobDef.params__c = JSON.serialize(myInstance.getParametros());
                
                CBK_Framework_Batch_Apex__mdt conf =new CBK_Framework_Batch_Apex__mdt();
                jobDef.proyecto__c = CBK_BatchJob_Helper.findProjectName(myInstance.getClassName());
                if (conf!=null) {
                    jobDef.Notif__c= conf.Notif__c;
                    jobDef.Email_Notif__c= conf.Email_Notif__c;
                }
                
                insert jobDef;   
        }
             
           //Planificación inmediata del Batch   
           if (prioridad == 0) {
               batchprocessid = CBK_BatchJob.runBatch(classname,batchSize,parametrosMap);
               AsyncApexJob aAj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
               jobDef.RunningJobId__c=batchprocessid; 
               jobDef.status__c=aAj.Status; 
               jobDef.NextExec__c=DateTime.now();
               jobDef.Orden__c=0;
               update jobDef;
           } else {
               batchprocessid = jobDef.Id;
           }
       } catch (Exception e) {
           CBK_BatchJob_Helper.errorJob(e,jobDef);
           throw(e); 
       }
       return jobDef.Id;
   } 
}