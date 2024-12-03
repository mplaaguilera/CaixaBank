@isTest
public class EV_AsignarPlantilla_Controller_Test {    
    
    static String FOLDER_REGISTRO = 'EV_Registro_Email_ES';
    static String PUBLICGROUP_DEVNAME = 'EV_Configuradores_Eventos';
    static String PROFILE_NAME = 'EV_Administrador de eventos';
    
    @testSetup
    static void setup()
    {
        Group publicGroup = [SELECT Type, Email, Name, DeveloperName, Id FROM Group WHERE DeveloperName = :PUBLICGROUP_DEVNAME LIMIT 1];
        
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME].Id,
            LastName = 'LastNameTest',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;
        
        GroupMember gMember = new GroupMember(UserOrGroupId = user.Id, GroupId = publicGroup.Id);
        insert gMember;
    }
    
    @isTest
    public static void obtenerCarpetas() {
        User user = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'test@test.com' LIMIT 1];
        
        System.runAs(user)
        {
            List<Folder> carpetas = EV_AsignarPlantilla_Controller.getCarpetas(null);
            
            System.assert(carpetas.size() > 0);
        }
    }
    @isTest
    public static void obtenerCarpetasConPadre() {        
        User user = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'test@test.com' LIMIT 1];
        
        System.runAs(user)
        {
            List<Folder> carpetas = EV_AsignarPlantilla_Controller.getCarpetas('EV_EventosMarketing');
            System.assert(carpetas.size() > 0);
        }
    }
    
    @isTest
    public static void obtenerPlantillas() {
        User user = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'test@test.com' LIMIT 1];
        
        System.runAs(user)
        {
            Folder carpeta = [SELECT Id, DeveloperName FROM Folder WHERE DeveloperName LIKE 'EV_%Email%ES' LIMIT 1];
            
            List<EmailTemplate> plantillas = EV_AsignarPlantilla_Controller.getPlantillas(carpeta.DeveloperName);
            System.assert(!plantillas.isEmpty());
        }
    }
    
    @isTest
    public static void guardarPlantilla() {    
        User user = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'test@test.com' LIMIT 1];
        
        System.runAs(user)
        {
            //Creamos la nueva campaña
            Campaign newCampaign = new Campaign(Name = 'CampaignTest',
                                                isActive = true,
                                                StartDate = Date.today().addDays(-5),
                                                EndDate = Date.today(),
                                                EV_DiaHora_evento__c = Datetime.now());
            insert newCampaign;
            
            Folder carpeta = [SELECT Id, DeveloperName FROM Folder WHERE DeveloperName = :FOLDER_REGISTRO LIMIT 1];
            EmailTemplate plantilla = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE FolderId = :carpeta.Id LIMIT 1];
            
            EV_AsignarPlantilla_Controller.guardarPlantilla(newCampaign.Id, carpeta.DeveloperName, plantilla.Name, plantilla.Id);
            
            Campaign campaignResult = [SELECT Id,  EV_API_Plantilla_Registro_Email_ES__c FROM Campaign
                                       WHERE Id = :newCampaign.Id];
            System.assert(campaignResult.EV_API_Plantilla_Registro_Email_ES__c == plantilla.Id);
        }
    }
    
}