/*
*   Clase creada para la insercion de datos en el setup para la realizacion de pruebas de QA.
*   Previamente han de existir los usuarios que realizan dichas pruebas.
*   Para insertar los usuarios lanzaremos desde la anonima el codigo que se encuentra en el metodo insercionUsers de la clase CC_Script_Pruebas_Auto_SetUp_Helper entre los comentarios
*   INICIO EJECUCION ANONIMO Y  FIN EJECUCION ANONIMO.
*   PASOS PARA LA EJECUCION:
*   1.- Comprobar que existan los usuarios, en caso de que no se encuentren ejecutar el codigo entre INICIO EJECUCION ANONIMO Y  FIN EJECUCION ANONIMO.
*   2.- Desde la anonima ejecutar: 
*       CC_Script_Pruebas_Auto_Han.insercionDatos();
*       CC_Script_Pruebas_Auto_SetUp_Han.insercionDatos();
*/

public with sharing class CC_Script_Pruebas_Auto_SetUp_Helper
{
    /*public static void insercionUsers()
    {        */
        /**************************************** INICIO EJECUCION ANONIMO ****************************************/
        /*
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<User> listaComprobacionUsuario;
        List<User> userToInsert = new List<User>();
        User usuario1 = new user();
        User usuario2 = new user();
        List<User> user1Exist = [SELECT Id, EmployeeNumber FROM User WHERE FirstName like 'U0190044 % ROBOT' AND LastName= 'GENERICO NTTDATA' AND IsActive = TRUE];
        List<User> user2Exist = [SELECT Id, EmployeeNumber FROM User WHERE FirstName like 'U01A1526 % ROBOT' AND LastName= 'EVERIS SELENIUM' AND IsActive = TRUE];
        Map<String, User> insertedUser = new Map <String, User>();
        Map<String, Id> mapUsers = new Map <String, Id>();
        List<PermissionSetAssignment> permisos = new List <PermissionSetAssignment>();
        String sandboxName = System.Url.getSalesforceBaseUrl().getHost();
        List<String> lstString = sandboxName.split('\\.');

        Id rolCC = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id profileCC = [SELECT Id FROM Profile WHERE Name = 'CC_Operador básico RRHH'].Id;
        
        usuario1.FirstName = 'U0190044 - ROBOT';
        usuario1.LastName = 'GENERICO NTTDATA';
        usuario1.UserRoleId = rolCC;
        usuario1.ProfileId = profileCC;
        usuario1.Email = 'adrian.zapatalopez@nttdata.com';
        usuario1.Username = 'robot.generico@nttdata.com.' + lstString[0];
        usuario1.Alias = 'ugene';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.FederationIdentifier = 'U0190044@caixabankpre.com';
        usuario1.EmployeeNumber = 'U0190044';
        if(user1Exist.isEmpty())
        {
            userToInsert.add(usuario1);
        }

        usuario2.FirstName = 'U01A1526 - ROBOT';
        usuario2.LastName = 'EVERIS SELENIUM';
        usuario2.UserRoleId = rolCC;
        usuario2.ProfileId = profileCC;
        usuario2.Email = 'adrian.zapatalopez@nttdata.com';
        usuario2.Username = 'robot.everis@nttdata.com.' + lstString[0];
        usuario2.Alias = 'uever';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.FederationIdentifier = 'U01A1526@caixabankpre.com';
        usuario2.EmployeeNumber = 'U01A1526';
        if(user2Exist.isEmpty())
        {
            userToInsert.add(usuario2);
        }

        try
        {
            if(!userToInsert.isEmpty())
            {
                Database.Insert(userToInsert, false);
            }            
        }
        catch(DmlException e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        listaComprobacionUsuario = [SELECT Id, EmployeeNumber FROM User WHERE ((FirstName like 'U0190044 % ROBOT' AND LastName= 'GENERICO NTTDATA') OR (FirstName like 'U01A1526 % ROBOT' AND LastName= 'EVERIS SELENIUM')) AND IsActive = TRUE];
        
        for(User usuario: listaComprobacionUsuario)
        {
            if(usuario.EmployeeNumber.contains('U0190044'))
            {
                usuario1 = usuario;
            }
            if(usuario.EmployeeNumber.contains('U01A1526'))
            {
                usuario2 = usuario;
            }
        }

        permisos.add(new PermissionSetAssignment(AssigneeId = usuario1.Id, PermissionSetId = ps.Id));
        permisos.add(new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = ps.Id));

        try
        {
            Database.Insert(permisos, false);
        } 
        catch(DmlException e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        */
        /**************************************** FIN EJECUCION ANONIMO ****************************************/
        
    //}

    public static void insercionPlantilla()
    {        
        EmailTemplate plantilla3N;
        EmailTemplate plantillaDesestimiento;
        EmailTemplate plantillaComuninicacion;
        EmailTemplate plantillaRemitido;
        EmailTemplate plantillaTraslado;
        List<EmailTemplate> listaComprobacionPlantilla;
        List<EmailTemplate> listaInsertPlantilla= new List<EmailTemplate>();
        Map<String, Id> mapPlantilla = new Map <String, Id>();

        
        listaComprobacionPlantilla = [SELECT Id, DeveloperName FROM EmailTemplate WHERE Developername IN ('CSBD_3N', 'Desistimiento_Moratoria_Adjuntar_modelo_1589988526320', 'Primera_comunicaci_n_Castellano_formal_1563465938755', 'Remitido_Generico_Telefono_Clientes', 'Traslado_Generico_Telefono_Clientes')];
        
        for(EmailTemplate plantilla: listaComprobacionPlantilla)
        {
            mapPlantilla.put(plantilla.DeveloperName, plantilla.Id);
        }

        plantilla3N = new EmailTemplate();
        plantilla3N.Id = mapPlantilla.get('CSBD_3N');
        plantilla3N.Developername = 'CSBD_3N';
        plantilla3N.HTMLValue= '3N de CSBD';
        plantilla3N.Subject = '3N de CSBD';
        plantilla3N.FolderId = UserInfo.getUserId();
        plantilla3N.name = '3N de CSBD';
        plantilla3N.IsActive = true;
        if(!mapPlantilla.containsKey('CSBD_3N'))
        {
            plantilla3N.TemplateType = 'custom';
            listaInsertPlantilla.add(plantilla3N);
        }
        
        plantillaDesestimiento = new EmailTemplate();
        plantillaDesestimiento.Id = mapPlantilla.get('Desistimiento_Moratoria_Adjuntar_modelo_1589988526320');
        plantillaDesestimiento.Developername = 'Desistimiento_Moratoria_Adjuntar_modelo_1589988526320';
        plantillaDesestimiento.HTMLValue= 'Desistimiento Moratoria. Adjuntar modelo';
        plantillaDesestimiento.Subject = 'Respuesta al caso {{{Case.CaseNumber}}}_ Contact Center Clientes Grupo CaixaBank';
        plantillaDesestimiento.FolderId = UserInfo.getUserId();        
        plantillaDesestimiento.name = 'Desistimiento Moratoria. Adjuntar modelo';
        plantillaDesestimiento.IsActive = true;
        if(!mapPlantilla.containsKey('Desistimiento_Moratoria_Adjuntar_modelo_1589988526320'))
        {
        plantillaDesestimiento.TemplateType = 'custom';
        listaInsertPlantilla.add(plantillaDesestimiento);
        }

        plantillaComuninicacion = new EmailTemplate();
        plantillaComuninicacion.Id = mapPlantilla.get('Primera_comunicaci_n_Castellano_formal_1563465938755');
        plantillaComuninicacion.Developername = 'Primera_comunicaci_n_Castellano_formal_1563465938755';
        plantillaComuninicacion.HTMLValue= 'Primera comunicación - Castellano formal';
        plantillaComuninicacion.Subject = 'Contact Center Clientes Grupo CaixaBank- {{{Case.CaseNumber}}} -Solicitud de documentación';
        plantillaComuninicacion.FolderId = UserInfo.getUserId();            
        plantillaComuninicacion.name = 'Primera comunicación - Castellano formal';
        plantillaComuninicacion.IsActive = true;
        if(!mapPlantilla.containsKey('Primera_comunicaci_n_Castellano_formal_1563465938755'))
        {
            plantillaComuninicacion.TemplateType = 'custom';
            listaInsertPlantilla.add(plantillaComuninicacion);
        }
        
        plantillaRemitido = new EmailTemplate();
        plantillaRemitido.Id = mapPlantilla.get('Remitido_Generico_Telefono_Clientes');
        plantillaRemitido.Developername = 'Remitido_Generico_Telefono_Clientes';
        plantillaRemitido.HTMLValue= 'Remitido Genérico Teléfono-Clientes';
        plantillaRemitido.Subject = 'Remitido Genérico Teléfono-Clientes';
        plantillaRemitido.FolderId = UserInfo.getUserId();        
        plantillaRemitido.name = 'Remitido Genérico Teléfono-Clientes';
        plantillaRemitido.IsActive = true;
        if(!mapPlantilla.containsKey('Remitido_Generico_Telefono_Clientes'))
        {
            plantillaRemitido.TemplateType = 'custom';
            listaInsertPlantilla.add(plantillaRemitido);
        }
        
        plantillaTraslado = new EmailTemplate();
        plantillaTraslado.Id = mapPlantilla.get('Traslado_Generico_Telefono_Clientes');
        plantillaTraslado.Developername = 'Traslado_Generico_Telefono_Clientes';
        plantillaTraslado.HTMLValue= 'Traslado Genérico Teléfono-Clientes';
        plantillaTraslado.Subject = 'Traslado Genérico Teléfono-Clientes';
        plantillaTraslado.FolderId = UserInfo.getUserId();        
        plantillaTraslado.name = 'Traslado Genérico Teléfono-Clientes';
        plantillaTraslado.IsActive = true;
        if(!mapPlantilla.containsKey('Traslado_Generico_Telefono_Clientes'))
        {
            plantillaTraslado.TemplateType = 'custom';
            listaInsertPlantilla.add(plantillaTraslado);
        }
        try
        {
            Database.Insert(listaInsertPlantilla, false);
        } 
        catch(DmlException e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }   
    }
}