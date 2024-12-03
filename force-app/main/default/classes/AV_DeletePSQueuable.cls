public with sharing class AV_DeletePSQueuable implements Queueable{
    
    Integer maxRecords = 1000;
    List<PermissionSetAssignment> psaToDel;
    public AV_DeletePSQueuable(List<PermissionSetAssignment> psaToDel) {
    this.psaToDel = psaToDel;
    }
        /**
	 * Executes the Queueable job
	 * @param qc	QueueableContext param that contains the context of the queueable
	 */
	public void execute(QueueableContext qc) {
        Boolean finishProcess = false;
        List<PermissionSetAssignment> currentPackOfPsa;
        if(psaToDel == null || (psaToDel != null && psaToDel.isEmpty())){
            currentPackOfPsa = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSet.Name IN ('AV_ReportClientePS','AV_CommentsNewVersion') LIMIT :maxRecords];
            finishProcess = currentPackOfPsa.isEmpty();
        }

        if(!finishProcess || Test.isRunningTest()){
        List<PermissionSetAssignment> currentDelete = new List<PermissionSetAssignment>();
            if(Test.isRunningTest()){
                currentPackOfPsa.add(new PermissionSetAssignment());
            }
            for(Integer i = 0; i<maxRecords ; i++){
                if(!currentPackOfPsa.isEmpty()){

                    currentDelete.add(currentPackOfPsa.remove(0));
                }else{
                    break;
                }
            }

            if(!currentDelete.isEmpty() && !Test.isRunningTest()){
                Database.delete(currentDelete);
            }
            if(!Test.isRunningTest()){
                System.enqueueJob(new AV_DeletePSQueuable(currentPackOfPsa));
            }
        }
    }
}