public with sharing class OS_EmailMessage_BD_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EmailMessage>)tp.oldList, (Map<Id, EmailMessage>)tp.oldMap);
    }
    
    private void process(List<EmailMessage> listOldObj, Map<Id, EmailMessage> mapOldObj) {
                   
        List<EmailMessage> listOldObjFilt = new List<EmailMessage>();
        for(EmailMessage email : listOldObj){
            if(email.Parent.RecordType.DeveloperName.left(2)=='OS'){
                listOldObjFilt.add(email);
            }
        }
        
        if(!listOldObjFilt.isEmpty()){

            Boolean permisoBorrado = FeatureManagement.checkPermission('OS_Borrado_EmailMessage');	
            if (Test.isRunningTest()){
                permisoBorrado =false;
            }        
            
            for (EmailMessage email: listOldObjFilt){
                if (email.Parent.RecordType.DeveloperName.left(2)=='OS'){  
                    email.addError('No tiene permisos para eliminar el registro'); 
                } else if(permisoBorrado == false) {
                    email.addError('SIIIIIIIIIIII tiene permisos para eliminar el registro');
                }
            }   
            
        }
    }
}