@isTest
public with sharing class SAC_Asignacion_Plantillas_Test {
    
    @TestSetup
    static void makeData(){
        
        User usuarioAdmin;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC Admin
            usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];   
            Database.insert(usuarioAdmin);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioAdmin.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        /*Folder newFolder = new Folder(
            Name='folderNameTest',
            Type='Document',
            AccessType='Public'); 
        Database.insert(newFolder);

        EmailTemplate e = new EmailTemplate (
            developerName = 'EmailTemplateTest', 
            FolderId = newFolder.Id, 
            TemplateType= 'Text', 
            Name = 'emailTest'); 

        Database.insert(e);*/
    }

    @isTest
    public static void getPlantillasTest(){
        //String nombreCarpeta = [SELECT Name FROM Folder WHERE Name = 'folderNameTest'].Name;
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuario){
            Test.startTest();
            List<EmailTemplate> resultado = SAC_Asignacion_Plantillas.getPlantillas('nombreCarpeta');
            Test.stopTest();

            System.assertNotEquals(null, resultado, 'No hay plantillas en la carpeta actual');
        }
    }
}