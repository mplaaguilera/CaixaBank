public class EV_ConfirmarAsistencia_Controller {
    
    public static String ESTADO_PREASISTENCIA = 'QR enviado'; 
    public static String ESTADO_ASISTENCIA = 'Asistió'; 
    
    public PageReference init(){
        Id idCampaignMember = apexpages.currentPage().getparameters().get('id');
        CampaignMember asistente = [SELECT Id, Status FROM CampaignMember WHERE Id = :idCampaignMember LIMIT 1];
        
        //if(asistente.Status == ESTADO_PREASISTENCIA)
        update new CampaignMember(Id = idCampaignMember, Status = ESTADO_ASISTENCIA);
        
        String recordUrl ='/' + idCampaignMember;
        PageReference pReference = new PageReference(recordUrl);
        pReference.setRedirect(true);
        return pReference;
    }
    
    /*
    @auraEnabled
    public static CampaignMember cargarMiembro(Id idMiembro)
    {
        CampaignMember member = [SELECT Id, Status, Name
                                 FROM CampaignMember WHERE Id = :idMiembro LIMIT 1];

        return member;
    }

    @auraEnabled
    public static Boolean esEstadoCorrecto(Id memberId)
    {
        CampaignMember member = [SELECT Status FROM CampaignMember WHERE Id = :memberId LIMIT 1];
        return (member.Status == ESTADO_PREASISTENCIA);
    }
    
    @auraEnabled
    public static String actualizarEstado(Id memberId)
    {
        String resultado = 'OK';
        CampaignMember memberUPD = new CampaignMember(Id = memberId,
                                                      Status = ESTADO_ASISTENCIA);
        
        try{
        	update memberUPD;    
        }catch(DmlException e) {
			return 'Se ha producido el siguiente error: ' + e.getMessage();
        }
        
        return resultado;
    }*/
}