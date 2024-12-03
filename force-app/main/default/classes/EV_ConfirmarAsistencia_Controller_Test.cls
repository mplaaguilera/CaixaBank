@isTest(SeeAllData=true)
public class EV_ConfirmarAsistencia_Controller_Test {
    
    static String ESTADO = 'QR enviado';
    
    @isTest(SeeAllData=true)
    static void testConfirmarAsistencia_estadoCorrecto()
    {
  		String SurveyId = [Select id from Survey where Name='Encuesta Subida Test'].Id;
        //Creamos la nueva campaña
        RecordType rt = AV_AppUtilities.getRecordType('Campaign', 'Fake_a_borrar');
        Campaign newCampaign = new Campaign(Name = 'CampaignTest',
                                            RecordTypeId = rt.Id,
                                            isActive = true,
                                            StartDate = Date.today().addDays(-5),
                                            EndDate = Date.today(),
                                           	EV_Encuesta__c = SurveyId);
        insert newCampaign;
        
        //Crear un Lead para asociarlo a la campaña como CampaignMember
        Lead newLead = new Lead(FirstName= 'TestApex',
                                LastName= 'TestApex',
                                EV_NumeroDocumento__c= '12345678H',
                                Phone= '987654321',
                                EV_Idiomas__c= '002',
                                EV_ConsentimientoTerceros__c= true,
                                EV_Marketing__c= false,
                                EV_ConsentimientoGeneral__c= false,
                                Email= 'test@h123456789.com'
                               );   
        insert newLead;            
        
        //Creamos el miembro de la campaña en estado inicial
        
        
        CampaignMember member = new CampaignMember(CampaignId = newCampaign.Id,
                                                   LeadId = newLead.Id,
                                                   Status = ESTADO);
        
        insert member;
        
        member.Status = 'QR enviado';
        update member;
        
        PageReference vfConfirmarAsistenciaPage = Page.EV_ConfirmarAsistencia_Page;
        Test.setCurrentPage(vfConfirmarAsistenciaPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id', member.Id);
        
        test.startTest();
        EV_ConfirmarAsistencia_Controller reference = new EV_ConfirmarAsistencia_Controller();
        reference.init();
        test.stopTest();
        
        CampaignMember resultado = [SELECT Status FROM CampaignMember LIMIT 1];
        System.debug('Resultado@:' + resultado);
        
        //System.assert(resultado.Status == 'Asistencia confirmada');
    }
    /*
@isTest 
static void testConfirmarAsistencia_cargarMiembro() 
{
CampaignMember member = [SELECT Status FROM CampaignMember LIMIT 1];

test.startTest();
CampaignMember memberResult = EV_ConfirmarAsistencia_Controller.cargarMiembro(member.Id);
test.stopTest();

System.assert(member.Id == memberResult.Id);
}

@isTest 
static void testActualizarEstado_OK() 
{
CampaignMember member = [SELECT Status FROM CampaignMember LIMIT 1];

test.startTest();
String result = EV_ConfirmarAsistencia_Controller.actualizarEstado(member.Id);
test.stopTest();

System.assert(result == 'OK');
}*/
    
}