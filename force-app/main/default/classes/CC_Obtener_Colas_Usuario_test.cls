@isTest
public class CC_Obtener_Colas_Usuario_test {    
    @isTest
    static void test01UpdateUserExistente() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        //Id roleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        //Creación de usuario        
        //Profile pf= [Select Id from profile where Name in ('Standard User','Usuario estándar') LIMIT 1];         
        
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Prueba Colas';
        usuario1.LastName = 'last1';
        usuario1.Email = 'tuser000Cola@amamama.com';
        usuario1.EmployeeNumber = 'U0199999';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.UserRoleId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        insert usuario1;

        Group grupo = new Group();
        grupo.Type ='Queue';
        grupo.name = 'Cola Test';
        grupo.DeveloperName = 'TestDevep';
        insert grupo;
        
        GroupMember grupoMiembro = new GroupMember();
        grupoMiembro.GroupId = grupo.Id;
        grupoMiembro.UserorGroupId = usuario1.Id;

        insert grupoMiembro;

        List<Id> usrLst = new List<Id>();
        usrLst.add(usuario1.Id);
        CC_Obtener_Colas_Usuario.informarcolas(usrLst);
        
        
        List<User> o5 = [SELECT Id,CC_Colas__c FROM User WHERE Id=:usuario1.Id];
        System.assertEquals(o5.size(), 1, 'Assert fallado');
    }
}