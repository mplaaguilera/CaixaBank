public class CC_AsociarCasos_CI_Queueable implements Queueable, Finalizer{
    public void execute(QueueableContext context) {
	}
	public void execute(FinalizerContext context) {        
	}
    /* private List<Id> idsCasos;
		
		public void setParams(List<Id> idsCasos) {
			this.idsCasos = idsCasos;
		}

		public void execute(QueueableContext context) {

			String jobId;

			try {
				jobId = 'CC_AsociarCasos_CI_Queueable-' + context.getJobId();      
            	//poner el attachFinalizer   
				Finalizer finalizer = new CC_AsociarCasos_CI_Queueable();
        		System.attachFinalizer(finalizer);
           		CC_Agrupador_CI_Asignacion_Casos.asociarCasosAComunicacionInformativaNoFuture(idsCasos);
			}catch (Exception e) {
				System.debug('Error executing the job [' + jobId + ']: ' + e.getMessage());
			} finally {
				System.debug('Completed: execution of queueable job: ' + jobId);
			}
    	}

        public void execute(FinalizerContext context) {           
           //si hubo exception de tipo unable to lock o la otra...
           //volver a poner en la cola. 
		   String parentJobId = 'CC_AsociarCasos_CI_Queueable-' + context.getAsyncApexJobId();

		   if (context.getResult() == ParentJobResult.SUCCESS) {
				System.debug('Parent queueable job [' + parentJobId + '] completed successfully.');
		   }else{
				System.enqueueJob(new CC_AsociarCasos_CI_Queueable());
		   }
		
    	}*/
}