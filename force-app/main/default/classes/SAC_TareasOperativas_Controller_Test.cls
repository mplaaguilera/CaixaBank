/*****************************************************************
 * Name: SAC_TareaOperativasController_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_TareaOperativasController
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US227438      Marcela Neira   20/05/21     Creación
*****************************************************************/
@istest
public with sharing class SAC_TareasOperativas_Controller_Test {
 @TestSetup
 static void makeData(){
    Account cuentaOficina = SAC_TestDataFactory.crearCuentasOficina(1)[0];
    cuentaOficina.CC_Email__c = 'test@test.com';
    Database.insert(cuentaOficina);

    List<CC_Grupo_Colaborador__c> gruposColaboradores = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',3);
    gruposColaboradores[0].Name = 'grupo de tareas';
    gruposColaboradores[0].SAC_DeveloperName__c = 'grupo de tareas';
    gruposColaboradores[0].SAC_PermiteTareas__c = true;

    gruposColaboradores[1].Name = 'Grupo B';
    gruposColaboradores[1].SAC_DeveloperName__c = 'Grupo B';
    gruposColaboradores[1].SAC_PermiteTareas__c = true;

    gruposColaboradores[2].Name = 'COPS AJ';
    gruposColaboradores[2].SAC_DeveloperName__c = 'COPS AJ';
    gruposColaboradores[2].SAC_NivelGrupo__c= 'SAC_Nivel3';

    Database.insert(gruposColaboradores);

    //Usuarios SAC General
    List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(4);
    usuarios[0].Username = 'usergeneral@test.com';
    usuarios[0].Email = 'pablo@test.com';
    usuarios[0].LastName = 'usuarioPablo Test';
    usuarios[0].Alias = 'pablo';
  
    usuarios[1].Username = 'usergeneral2@test.com';
    usuarios[1].Email = 'maria@test.com';
    usuarios[1].LastName = 'usuarioMaria Test';
    usuarios[1].Alias = 'maria';    
   
    usuarios[2].Username = 'usergeneral3@test.com';
    usuarios[2].Email = 'sofia@test.com';
    usuarios[2].LastName = 'sofia Test';
    usuarios[2].Alias = 'sofia';

    usuarios[3].Username = 'usergeneral4@test.com';
    usuarios[3].Email = 'dani@test.com';
    usuarios[3].LastName = 'usuarioDani Test';
    usuarios[3].Alias = 'dani';
    Database.insert(usuarios);

    Test.startTest();
    //Contactos colaboradores
    List<CC_Grupo_Colaborador_Contact__c> contactoscolab = new List<CC_Grupo_Colaborador_Contact__c>();
    CC_Grupo_Colaborador_Contact__c grupoTareas1 = SAC_TestDataFactory.crearColaboradorContact(usuarios[0].id, gruposColaboradores[0].id);
    contactoscolab.add(grupoTareas1) ;

    CC_Grupo_Colaborador_Contact__c grupoTareas2 = SAC_TestDataFactory.crearColaboradorContact(usuarios[1].id, gruposColaboradores[1].id);
    contactoscolab.add(grupoTareas2) ;
    
    CC_Grupo_Colaborador_Contact__c grupoTareas3 = SAC_TestDataFactory.crearColaboradorContact(usuarios[2].id, gruposColaboradores[1].id);
    contactoscolab.add(grupoTareas3) ;

    CC_Grupo_Colaborador_Contact__c grupoTareas4 = SAC_TestDataFactory.crearColaboradorContact(usuarios[3].id, gruposColaboradores[2].id);
    contactoscolab.add(grupoTareas4) ;
    Database.insert(contactoscolab);

    //Reclamacion
    Map<String, Object> camposRecl = new Map<String, Object>();
    camposRecl.put('Subject', 'TestRec');
    camposRecl.put('Status', 'SAC_001');
    camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
    camposRecl.put('Origin', 'Otros');

    Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
    Database.insert(reclamacion);

    //Pretension
    Map<String, Object> camposPret = new Map<String, Object>();
    camposPret.put('Origin', 'Otros');
    camposPret.put('Status', 'SAC_001');
    camposPret.put('SuppliedCompany', 'testPret');
    camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
    camposPret.put('SAC_Reclamacion__c', reclamacion.id);

    Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
    Database.insert(pretension);

    SAC_MaestroAccionesReclamacion__c maestro = SAC_TestDataFactory.crearMaestroAcciones(1,gruposColaboradores[0].Id)[0];
    maestro.name = 'GENERAL PARA OFICINAS';
    maestro.SAC_Descripcion__c = 'Descripción';
    maestro.SAC_PlazoMaximo__c = 15;
    maestro.SAC_Prorroga__c = 30;
    maestro.SAC_DeveloperName__c = 'GENERAL PARA OFICINAS';
    maestro.SAC_EquipoResponsable__c = gruposColaboradores[0].id;
    maestro.SAC_Activo__c = true;
    Database.insert(maestro);

    List<SAC_Accion__c> tareas = new List<SAC_Accion__c>();

    List<SAC_Accion__c> listaDeTareasOtras = SAC_TestDataFactory.crearTareas(4,reclamacion,false);
    listaDeTareasOtras[0].SAC_EquipoResponsable__c = gruposColaboradores[1].id;
    listaDeTareasOtras[0].OwnerId = usuarios[1].id;
    listaDeTareasOtras[0].SAC_Prorroga__c = 10;
    listaDeTareasOtras[0].SAC_Observaciones__c = 'Llamar'; 
    listaDeTareasOtras[0].SAC_Pretension__c = pretension.id;
    listaDeTareasOtras[0].SAC_Antecedentes_Revisados__c = true;

    listaDeTareasOtras[1].SAC_EquipoResponsable__c = gruposColaboradores[0].id;
    listaDeTareasOtras[1].SAC_Observaciones__c = 'tareaClic'; 
    listaDeTareasOtras[1].OwnerId = usuarios[1].id;

    listaDeTareasOtras[2].SAC_EquipoResponsable__c = gruposColaboradores[0].id;
    listaDeTareasOtras[2].SAC_Observaciones__c = 'tarea'; 

    listaDeTareasOtras[3].SAC_EquipoResponsable__c = gruposColaboradores[1].id;
    listaDeTareasOtras[3].SAC_Observaciones__c = 'devolverGestLet'; 
    listaDeTareasOtras[3].OwnerId = usuarios[0].id;
    tareas.addAll(listaDeTareasOtras);
    
    List<SAC_Accion__c> listaDeTareasMaestro = SAC_TestDataFactory.crearTareas(1,reclamacion,true);
    listaDeTareasMaestro[0].SAC_MaestroAccionesReclamacion__c = maestro.Id;
    listaDeTareasMaestro[0].SAC_EquipoResponsable__c = gruposColaboradores[0].id;
    listaDeTareasMaestro[0].SAC_Observaciones__c ='tarea5'; 
    listaDeTareasMaestro[0].SAC_PlazoMaximo__c = 10; 
    listaDeTareasMaestro[0].SAC_Prorroga__c = 5;
    listaDeTareasMaestro[0].OwnerId = usuarios[0].id;
    listaDeTareasMaestro[0].SAC_Oficina__c = cuentaOficina.id;
    listaDeTareasMaestro[0].SAC_ImporteNotariaAbonar__c = 20;
    listaDeTareasMaestro[0].SAC_ImporteGestoriaAbonar__c = 30;
    listaDeTareasMaestro[0].SAC_ImporteRegistroAbonar__c = 35;
    listaDeTareasMaestro[0].SAC_ImporteTasacionAbonar__c = 25;
    listaDeTareasMaestro[0].SAC_NCuentaAbono__c = '1234567890';
    listaDeTareasMaestro[0].SAC_Comentarios__c = 'Comentario prueba';
    tareas.addAll(listaDeTareasMaestro);
    Database.insert(tareas);
     
    Test.stopTest();
 }  
 @isTest
    static void tomarPropiedadTest(){
        Test.startTest();
        User usuario = [select id, name, UserRole.name from user where Username = 'usergeneral2@test.com' AND isActive = true limit 1];
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        permisos.add(psa);  
        
        SAC_Accion__c tarea = [SELECT id, ownerId, SAC_EquipoResponsable__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];
        
        System.runAs(usuario) {
            
            SAC_TareasOperativas_Controller.tomarPropiedadTarea(tarea.Id, usuario.Id);
            
        }

        String nuevoPropetarioTarea = [SELECT id, ownerId
                                        FROM   SAC_Accion__c
                                        WHERE SAC_Observaciones__c = 'Llamar'     
                                        LIMIT 1].ownerId;


        System.assertEquals(usuario.id, nuevoPropetarioTarea, 'No ha cambiado de propietario');
        Test.stopTest();
    }
 @isTest
    static void autoasignarPropiedadTareaTest() {
        Test.startTest();
        User usuario = [select id, name from user where Username = 'usergeneral@test.com' AND isActive = true];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);       
        Database.insert(psa); 

        SAC_Accion__c tarea = [SELECT id
                                FROM   SAC_Accion__c 
                                WHERE SAC_Observaciones__c='tarea'    
                                LIMIT 1]; 
        
        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.RunAs(usr){   
            tarea.SAC_Estado__c='SAC_PendienteAsignar';
            Database.update(tarea); 
        }

        System.runAs(usuario) {
            SAC_TareasOperativas_Controller.autoasignarPropiedadTarea(tarea.Id, usuario.Id);
            
        }

        String ideNuevoUsuario =[SELECT id, OwnerId
                                FROM   SAC_Accion__c 
                                WHERE SAC_Observaciones__c='tarea'     
                                LIMIT 1].OwnerId;

        System.assertEquals(usuario.id, ideNuevoUsuario, 'No se ha cambiado el propietario');
        Test.stopTest();
    }

    @isTest
    static void mostrarBotonTest(){
        Test.startTest();
        String mostrarBotones = '';
        User usuario = [SELECT id FROM user WHERE username = 'usergeneral2@test.com' AND IsActive = true limit 1];
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        permisos.add(psa);       
        
        PermissionSet ps2 = [select id from PermissionSet where  PermissionSet.Label ='SAC_Letrados'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = ps2.id, AssigneeId = usuario.id);    
        permisos.add(psa2);   
        Database.insert(permisos);

        SAC_Accion__c tarea = [SELECT id
                                    FROM   SAC_Accion__c
                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                    LIMIT 1];

        
        System.runAs(usuario) {
            
            mostrarBotones = SAC_TareasOperativas_Controller.mostrarBotones(tarea.id, usuario.id);
            
        }


        System.assertNotEquals(null, mostrarBotones, 'Si se debería mostrar el botón');
        Test.stopTest();
    }

    @istest
    static void devolverTareaTest(){
        Test.startTest();
        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        User usuario = [select id, name, UserRole.name from user where Username = 'usergeneral2@test.com' AND isActive = true limit 1];
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        permisos.add(psa);  

        Database.insert(permisos);
        
        SAC_Accion__c tarea = [SELECT id, ownerId, SAC_EquipoResponsable__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];

        
        System.runAs(usuario) {
            
            SAC_TareasOperativas_Controller.devolverTarea(tarea.Id, usuario.Id);
            
        }

        String nuevoPropetarioTarea = [SELECT id, ownerId
                                        FROM   SAC_Accion__c
                                        WHERE SAC_Observaciones__c = 'Llamar'     
                                        LIMIT 1].ownerId;


        System.assertEquals(cola[0].id, nuevoPropetarioTarea, 'No ha devuelto la tarea');
        Test.stopTest();
    }

    @istest 
    static void finalizarTareaTest(){
        
        User usuario = [select id, name, UserRole.name from user where Username = 'usergeneral2@test.com' AND isActive = true limit 1];
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        permisos.add(psa);  

        Database.insert(permisos);
        
        SAC_Accion__c tarea = [SELECT id, ownerId, SAC_EquipoResponsable__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];

        
        System.runAs(usuario) {
            Test.startTest();
            SAC_TareasOperativas_Controller.finalizarTarea(tarea.Id, usuario.Id,'y un comentario');
            Test.stopTest();
        }

        String nuevoPropetarioTarea = [SELECT id, ownerId
                                        FROM   SAC_Accion__c
                                        WHERE SAC_Observaciones__c = 'Llamar'    
                                        LIMIT 1].ownerId;


        System.assertEquals(usuario.id, nuevoPropetarioTarea, 'No ha cambiado de propietario');
        
    }


    @istest 
    static void finalizarTareaObservacionesTest(){
        
        User usuario = [select id, name, UserRole.name from user where Username = 'usergeneral2@test.com' AND isActive = true limit 1];
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        permisos.add(psa);  

        Database.insert(permisos);
        
        SAC_Accion__c tarea = [SELECT id, ownerId, SAC_EquipoResponsable__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];

        
        System.runAs(usuario) {
            Test.startTest();
            SAC_TareasOperativas_Controller.finalizarTareaObservacion(tarea.Id, usuario.Id,'y un comentario', 'SAC_FinalizadaIncompleta');
            Test.stopTest();
        }

        String nuevoPropetarioTarea = [SELECT id, ownerId
                                        FROM   SAC_Accion__c
                                        WHERE SAC_Observaciones__c = 'Llamar'     
                                        LIMIT 1].ownerId;


        System.assertEquals(usuario.id, nuevoPropetarioTarea, 'No ha cambiado de propietario');
        
    }

    @istest
    static void mostrarBotonesTest(){
        Test.startTest();
        User usuario = [select id, name, UserRole.name from user where Username = 'usergeneral4@test.com' AND isActive = true limit 1];
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        String respuesta='';
        
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        permisos.add(psa);  

        Database.insert(permisos);
        
        SAC_Accion__c tarea = [SELECT id, ownerId, SAC_EquipoResponsable__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];

        System.runAs(usuario) {
          
            
            respuesta = SAC_TareasOperativas_Controller.mostrarBotones(tarea.Id, usuario.Id);
            
        }


        System.assertEquals('0000000', respuesta, 'No se muestra los botones');
        Test.stopTest();
    }
 
    @isTest
    static void postOnChatter(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];
        List<FeedItem> antes = [SELECT Id FROM FeedItem];

        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
            
            SAC_TareasOperativas_Controller.postOnChatter(tarea.Id, 'cuerpo de la notifiación');
            
        }
           
         List<FeedItem> despues = [SELECT Id FROM FeedItem];

        System.assertNotEquals(antes.size(), despues.size(), 'No se ha insertado el feed.');
        Test.stopTest();  
    }

    @isTest
    static void notificarPropietarioAccion_Test(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];

        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        Boolean resultado;

        System.RunAs(usr){   
            
            resultado = SAC_TareasOperativas_Controller.notificarPropietarioAccion(tarea.Id, 'cuerpo de la notifiación');
            
        }
                
         system.assertEquals(true, resultado, 'No se ha notificado al propietario de la tarea.');
         Test.stopTest();  

    }

    @isTest
    static void envioTarea_Test(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'Llamar'     
                                                LIMIT 1];
                                                
        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
            
            SAC_TareasOperativas_Controller.enviarTarea(tarea.Id);
            
        }

        SAC_Accion__c tareav2 = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c, SAC_Estado__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'Llamar'     
                                                LIMIT 1];
    
        System.assertEquals(tareav2.OwnerId, cola[0].Id, 'No se devuelto la tarea a la cola pendiente de asignar.');
        System.assertEquals(tareav2.SAC_Estado__c, 'SAC_PendienteAsignar', 'No se ha modificado el estado a En gestión.');
        Test.stopTest();  
    }


    @isTest
    static void envioTarea2_Test(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'tarea5'     
                                                LIMIT 1];
                                                
        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

        User usr = [Select id from User where Username = 'usergeneral@test.com' AND isActive = true];

        System.RunAs(usr){   
            
            SAC_TareasOperativas_Controller.enviarTarea(tarea.Id);
            
        }

        SAC_Accion__c tareav2 = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c, SAC_Estado__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'tarea5'     
                                                LIMIT 1];
    
        System.assertEquals(tareav2.OwnerId, cola[0].Id, 'No se devuelto la tarea a la cola pendiente de asignar.');
        System.assertEquals(tareav2.SAC_Estado__c, 'SAC_PendienteAsignar', 'No se ha modificado el estado a En gestión.');
        Test.stopTest();  
    }

    @isTest
    static void cargarComentarios2_Test(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];
        

        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        String resultado;

        System.RunAs(usr){   
            
            resultado = SAC_TareasOperativas_Controller.cargarComentarios2(tarea.Id);
             
        }                                         
               
         System.assertNotEquals(null, resultado, 'No hay comentarios');
         Test.stopTest();  

    }

    @isTest
    static void devolverTareaGestorLetradoTest(){
        Test.startTest();
        List<User> listaUsuario = [SELECT id, name, Username, UserRole.name FROM user WHERE (Username = 'usergeneral@test.com' OR Username = 'usergeneral2@test.com') AND isActive = true limit 2];
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c, SAC_Estado__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'devolverGestLet'     
                                                    LIMIT 1];
        
        User usuario = new User();
        User usuarioMaria = new User();
        for (User usuari : listaUsuario) {
            if (usuari.Username == 'usergeneral@test.com') {
                usuario = usuari;
            }
            if (usuari.Username == 'usergeneral2@test.com') {
                usuarioMaria = usuari;
            }
        }

        
        System.runAs(usuario){
            PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioMaria.id);
            insert psa;
        }
        
        SAC_TareasOperativas_Controller.devolverTareaGestorLetrado(tarea.Id, usuario.Id, 'este es el motivo de la devolucion');
        

         SAC_Accion__c tareaResult = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c, SAC_Estado__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'devolverGestLet'     
                                                    LIMIT 1];

         System.assertEquals('SAC_Devuelta', tareaResult.SAC_Estado__c, 'No se ha podido cambiar el estado');
         Test.stopTest();
    }

    @isTest
    static void enviarTareaDevueltaTest(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'Llamar'     
                                                LIMIT 1];

        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
            
            tarea.SAC_Estado__c = 'SAC_Devuelta';
            Database.update(tarea);
            SAC_TareasOperativas_Controller.enviarTarea(tarea.Id);
            
        }                                        
                
        SAC_Accion__c tareav2 = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c, SAC_Estado__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'Llamar'     
                                                LIMIT 1];
    
        System.assertEquals(tareav2.SAC_Estado__c, 'SAC_PendienteAsignar', 'No se ha modificado el estado a En gestión.');
        Test.stopTest();  
    }

    @isTest
    static void comprobarUserEsDelGrupoTest(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'Llamar'     
                                                LIMIT 1];

        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        Boolean resultado;

        System.RunAs(usr){   
            
            resultado = SAC_TareasOperativas_Controller.comprobarUserEsDelGrupo(tarea.OwnerId, tarea.SAC_EquipoResponsable__c);
            
        }
    
        System.assertEquals(true, resultado, 'No se ha podido comprobar si el user pertenece al grupo.');
        Test.stopTest();  
    }

    
    @isTest
    static void finalizarTareaGGHTest(){
        
        Boolean hayError = false; 
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c
                                                FROM   SAC_Accion__c
                                                WHERE SAC_Observaciones__c = 'Llamar'     
                                                LIMIT 1];

        User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
            try {
                Test.startTest();
                SAC_TareasOperativas_Controller.enviarTareaGGH(tarea.Id);
                SAC_TareasOperativas_Controller.finalizarTareaGGH(tarea.Id);
                Test.stopTest();
            } catch (Exception e) {
                hayError = true; 
            }   
        }
                                                 
        System.assertEquals(true, hayError, 'No ha saltado el error');
        
    }

    /*
    @isTest
    static void clicPorrogaTest(){

        SAC_Accion__c tarea = [SELECT id, ownerId, SAC_ProrrogaTareaCheck__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'tareaClic'     
                                                    LIMIT 1];
        
         Test.startTest();
         SAC_TareasOperativas_Controller.clicPorroga(tarea.Id, tarea.ownerId);
         Test.stopTest();        

         SAC_Accion__c resultado = [SELECT SAC_ProrrogaTareaCheck__c
                                        FROM   SAC_Accion__c
                                        WHERE SAC_Observaciones__c = 'tareaClic'    
                                        LIMIT 1];


        System.assertEquals(true, resultado.SAC_ProrrogaTareaCheck__c, 'No ha cambiado de propietario');

    }
    */

    @isTest
    static void devolverAntecedentesRevisados_Test(){
        Test.startTest();
        SAC_Accion__c tarea = [SELECT id, ownerId, Name, SAC_EquipoResponsable__c, SAC_Reclamacion__C, SAC_Pretension__c, SAC_Antecedentes_Revisados__c
                                                    FROM   SAC_Accion__c
                                                    WHERE SAC_Observaciones__c = 'Llamar'     
                                                    LIMIT 1];
        User usuario = [SELECT id FROM user WHERE username = 'usergeneral2@test.com' AND IsActive = true limit 1];
        Boolean resultado;

        System.RunAs(usuario){            
            resultado = SAC_TareasOperativas_Controller.devolverAntecedentesRevisados(tarea.Id);   
        }                                         
               
        System.assertNotEquals(false, resultado, 'Los antecedentes no han sido revisados');
        Test.stopTest();  
    }
}