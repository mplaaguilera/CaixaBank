public with sharing class CSBD_InfobipUpdaterQueueable implements Queueable {
    public List<CSBD_InfobipController.InfobipDataWrapper> infoList {set;get;}
    public String origin {set;get;}
   // public CSBD_InfobipController.InfobipDataWrapper info {set;get;}

  /*  public CSBD_InfobipUpdaterQueueable(CSBD_InfobipController.InfobipDataWrapper info){    
        this.info = info;
    } */

    public CSBD_InfobipUpdaterQueueable(List<CSBD_InfobipController.InfobipDataWrapper> infoList, String origin){    
        this.infoList = infoList;
        this.origin = origin;
    } 
    
    //execute queueable
    public void execute(QueueableContext ctx) {         
        try {
          //  info.handleQueueable = false;
            CSBD_InfobipController.upsertTask(infoList, origin);  
            if(Test.isRunningTest()){
               throw new CSBD_InfobipSender.InfobipSenderException('Enforce UNABLE_TO_LOCK_ROW error');
            }
        } catch (Exception ex) {         
            CBK_Log.debug('CSBD_InfobipUpdaterQueueable', 'Info Received => ' + JSON.serialize(infoList) + ' Exception Thrown => ' + ex.getMessage());        
        }   
    }  
    
}