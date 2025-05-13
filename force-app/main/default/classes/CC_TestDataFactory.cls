@isTest
public class CC_TestDataFactory {
    public static Map<String, Id> getPermissionSet() {
        Map<String, Id> returnMap = new Map<String, Id>();
        Set<String> psNames = new Set<String> {
            'CC_Operador_Cliente',
            'CC_Operador_CCO',
            'AV_GestorOperativa',
            'CC_Classes',
            'CSBD_PS_Gestor'
        };
        List<PermissionSet> psContactCenter = [
            SELECT Id, Name FROM PermissionSet WHERE Name IN: psNames
        ];

        for(PermissionSet ps: psContactCenter){
            returnMap.put(ps.Name, ps.Id);
        }

        return returnMap;
    }
  
    public static Map<String, Id> getProfiles() {
        Map<String, Id> returnMap = new Map<String, Id>();
        Set<String> profileNames = new Set<String> {
            'CC_Usuario_CaixaBank',
            'System Administrator'
        };
        List<Profile> profilesCC = [
            SELECT Id, Name FROM Profile WHERE Name IN: profileNames
        ];

        for(Profile prof: profilesCC){
            returnMap.put(prof.Name, prof.Id);
        }

        return returnMap;
    }

    public static Map<String, Id> getRoles() {
        Map<String, Id> returnMap = new Map<String, Id>();
        Set<String> rolesNames = new Set<String> {
            'Contact_Center',
            'Contact_Center_sin_acceso_a_Directorio'
        };
        List<UserRole> rolesCC = [
            SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN: rolesNames
        ];

        for(UserRole rol: rolesCC){
            returnMap.put(rol.DeveloperName, rol.Id);
        }

        return returnMap;
    }

    public static User createUserAdmin(Id profileAdmin, Id roleCC){
        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;        
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';

        return usuarioAdmin;
    }

    public static User createtUserOperador(Id profileId, Id roleDirectorioCC, String matricula){
       return createtUserOperador(profileId, roleDirectorioCC, matricula, 'Operador');
    }

    public static User createtUserOperador(Id profileId, Id roleDirectorioCC, String matricula, String nombre){
        User operadorCliente = new User();
        operadorCliente.profileId = profileId;
        operadorCliente.UserRoleId = roleDirectorioCC;
        operadorCliente.AV_ExternalID__c = matricula;
        operadorCliente.FirstName = nombre;
        operadorCliente.LastName = 'Operador Cliente';
        operadorCliente.Email = 'tuser001@amamama.com';
        operadorCliente.Username = 'tuser001@amamama.com' + System.currentTimeMillis();
        operadorCliente.CompanyName = 'MST';
        operadorCliente.Title = 'title';
        operadorCliente.Alias = 'alias';
        operadorCliente.TimeZoneSidKey = 'Europe/Paris';
        operadorCliente.EmailEncodingKey = 'UTF-8';
        operadorCliente.LanguageLocaleKey = 'es';
        operadorCliente.LocaleSidKey = 'es_ES';

        return operadorCliente;
    }

    public static User insertUserAdmin(){
        Map<String, Id> profilesCC = getProfiles();
        Map<String, Id> rolesCC = getRoles();
        Map<String, Id> psCC = getPermissionSet();


        User admin = createUserAdmin(profilesCC.get('System Administrator'), rolesCC.get('Contact_Center'));
        insert admin;
        //PS AV Clientes

        PermissionSetAssignment psaAdminAV = new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        insert psaAdminAV;

        return admin;        
    }

    public static User insertUserOperadorCliente(String matricula){
        Map<String, Id> profilesCC = getProfiles();
        Map<String, Id> rolesCC = getRoles();
        Map<String, Id> psCC = getPermissionSet();


        User operadorCliente = createtUserOperador(profilesCC.get('CC_Usuario_CaixaBank'), rolesCC.get('Contact_Center_sin_acceso_a_Directorio'), matricula);
        insert operadorCliente;

        //Agregar PS              
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId =  psCC.get('CC_Operador_Cliente'));
        PermissionSetAssignment psaOperadorEmpleado = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId =  psCC.get('CC_Operador_CCO'));
        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('CC_Classes'));
        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        PermissionSetAssignment psaOperadorCSBD = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('CSBD_PS_Gestor'));
        
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>{
            psaOperadorCliente, 
            psaOperadorEmpleado,
            psaOperadorClasses,
            psaOperadorAV,
            psaOperadorCSBD
        };    

        insert insertPSAssOperadores;

        return operadorCliente;        
    }

    public static Map<String, User> insertUserOperadoresCliente(List<String> matriculas){
        Map<String, Id> profilesCC = getProfiles();
        Map<String, Id> rolesCC = getRoles();
        Integer i = 0;

        Map<String,User> returnValue = new Map<String,User>();

        List<User> operadoresCliente = new List<User>();
        for(String matricula : matriculas){
            User operadorCliente = createtUserOperador(profilesCC.get('CC_Usuario_CaixaBank'), rolesCC.get('Contact_Center_sin_acceso_a_Directorio'), matricula, 'Operador' + i );
            operadorCliente.Username += '' + i;
            operadoresCliente.add(operadorCliente);
            i++;
        }
        if(!operadoresCliente.isEmpty()){
            insert operadoresCliente;
            for(User operadorCliente : operadoresCliente){
                returnValue.put(operadorCliente.AV_ExternalID__c, operadorCliente);
            }
        }
        
        return returnValue;        
    }

    public static Map<String, User> insertUserAdminOperador(String matriculaOperador){
        Map<String, User> returnValue = new Map<String, User>();
        Map<String, Id> profilesCC = getProfiles();
        Map<String, Id> rolesCC = getRoles();
        Map<String, Id> psCC = getPermissionSet();

        User usuarioAdmin = createUserAdmin(profilesCC.get('System Administrator'), rolesCC.get('Contact_Center'));
        User operadorCliente = createtUserOperador(profilesCC.get('CC_Usuario_CaixaBank'), rolesCC.get('Contact_Center_sin_acceso_a_Directorio'), matriculaOperador);
        List<User> usuarios = new List<User>{usuarioAdmin, operadorCliente};
        insert usuarios;

        PermissionSetAssignment psaAdminAV = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId =  psCC.get('CC_Operador_Cliente'));
        PermissionSetAssignment psaOperadorEmpleado = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId =  psCC.get('CC_Operador_CCO'));
        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('CC_Classes'));
        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        PermissionSetAssignment psaOperadorCSBD = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('CSBD_PS_Gestor'));
        
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>{
            psaOperadorCliente, 
            psaOperadorEmpleado,
            psaOperadorClasses,
            psaOperadorAV,
            psaOperadorCSBD,
            psaAdminAV
        };    

        insert insertPSAssOperadores;

        returnValue.put('admin', usuarioAdmin);
        returnValue.put('operador', operadorCliente);

        return returnValue;
    }

    public static User getUserAdmin(){
        return [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
    }

    public static User getUserOperadorCliente(){
        return [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1];
    }

    public static void insertarLOVDerivar(){
        Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        List<CC_Lista_Valores__c> listas = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c ();
        lista.Name = 'Gestor por defecto CC';
        lista.RecordTypeId = recordTypeLista;
        listas.add(lista);
        
        CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
        listaDerivar.Name = 'Textos operativa Derivar';
        listaDerivar.RecordTypeId = recordTypeLista;
        listas.add(listaDerivar);
        insert listas;
        
        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c valorExId = new CC_Lista_Valores__c ();
        valorExId.Name = 'ExternalID';
        valorExId.RecordTypeId = recordTypeValor;
        valorExId.CC_Lista__c = lista.Id;
        valorExId.CC_Valor__c ='000000';        
        valores.add(valorExId);

        CC_Lista_Valores__c valorName = new CC_Lista_Valores__c ();
        valorName.Name = 'Nombre';
        valorName.RecordTypeId = recordTypeValor;
        valorName.CC_Lista__c = lista.Id;
        valorName.CC_Valor__c ='No asignado';
        valores.add(valorName);
        
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
        valor1.Name = 'Comentario cambio oficina';
        valor1.RecordTypeId = recordTypeValor;
        valor1.CC_Lista__c = listaDerivar.Id;
        valor1.CC_Mensajes_Mostrar__c = 'El cliente [nombre], [apellidos], [dni] solicita el cambio de oficina de la [oficina origen] a la [oficina destino].';
        valores.add(valor1);
        
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.Name = 'Comentario cambio gestor';
        valor2.RecordTypeId = recordTypeValor;
        valor2.CC_Lista__c = listaDerivar.Id;
        valor2.CC_Mensajes_Mostrar__c = 'El cliente [nombre], [apellidos], [dni] solicita el cambio de gestor.';
        valores.add(valor2);
        
        CC_Lista_Valores__c valor3 = new CC_Lista_Valores__c();
        valor3.Name = 'Pregunta traslado colaborador';
        valor3.RecordTypeId = recordTypeValor;
        valor3.CC_Lista__c = listaDerivar.Id;
        valor3.CC_Mensajes_Mostrar__c = '¿La gestión a realizar es una consulta a expensas de recibir respuesta o es derivar al caso a un tercero para su gestión?';
        valores.add(valor3);
        
        CC_Lista_Valores__c valor4 = new CC_Lista_Valores__c();
        valor4.Name = 'Pregunta cajeros';
        valor4.RecordTypeId = recordTypeValor;
        valor4.CC_Lista__c = listaDerivar.Id;
        valor4.CC_Mensajes_Mostrar__c = '¿El cajero es externalizado?';
        valores.add(valor4);
        
        CC_Lista_Valores__c valor5 = new CC_Lista_Valores__c();
        valor5.Name = 'Pregunta cajero externalizado';
        valor5.RecordTypeId = recordTypeValor;
        valor5.CC_Lista__c = listaDerivar.Id;
        valor5.CC_Mensajes_Mostrar__c = 'Para dar de alta esta reclamación accede en TFC > Diario de operaciones de cajeros , localiza la operación y reclámala. ¿Lo has podido hacer?';
        valores.add(valor5);
        
        CC_Lista_Valores__c valor6 = new CC_Lista_Valores__c();
        valor6.Name = 'Toast cajero externalizado';
        valor6.RecordTypeId = recordTypeValor;
        valor6.CC_Lista__c = listaDerivar.Id;
        valor6.CC_Mensajes_Mostrar__c = 'Esta es una operación en un cajero cuya gestión resolverá la misma Oficina. Por tanto no es necesario avisar a la oficina';
        valores.add(valor6);
        
        CC_Lista_Valores__c valor7 = new CC_Lista_Valores__c();
        valor7.Name = 'Pregunta realizar remitido';
        valor7.RecordTypeId = recordTypeValor;
        valor7.CC_Lista__c = listaDerivar.Id;
        valor7.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
        valores.add(valor7);
        
        CC_Lista_Valores__c valor8 = new CC_Lista_Valores__c();
        valor8.Name = 'Toast remitir';
        valor8.RecordTypeId = recordTypeValor;
        valor8.CC_Lista__c = listaDerivar.Id;
        valor8.CC_Mensajes_Mostrar__c = 'Antes de proseguir, intenta transferir el caso en online.';
        valores.add(valor8);
        
        CC_Lista_Valores__c valor9 = new CC_Lista_Valores__c();
        valor9.Name = 'Url cajeros';
        valor9.RecordTypeId = recordTypeValor;
        valor9.CC_Lista__c = listaDerivar.Id;
        valor9.CC_Mensajes_Mostrar__c = 'https://frmfrm.pro.absiscloud.lacaixa.es/?id=22337';
        valores.add(valor9);
        
        CC_Lista_Valores__c valor10 = new CC_Lista_Valores__c();
        valor10.Name = 'Mensaje imagin oficina';
        valor10.RecordTypeId = recordTypeValor;
        valor10.CC_Lista__c = listaDerivar.Id;
        valor10.CC_Mensajes_Mostrar__c = 'El cliente debe acudir presencialmente a la oficina';
        valores.add(valor10);
        
        CC_Lista_Valores__c valor11 = new CC_Lista_Valores__c();
        valor11.Name = 'Mensaje imagin ventas';
        valor11.RecordTypeId = recordTypeValor;
        valor11.CC_Lista__c = listaDerivar.Id;
        valor11.CC_Mensajes_Mostrar__c = 'En un plazo máximo de 48h se pondrán en contacto con el cliente';
        valores.add(valor11);
        
        CC_Lista_Valores__c valor12 = new CC_Lista_Valores__c();
        valor12.Name = 'Mensaje imagin cambio de oficina';
        valor12.RecordTypeId = recordTypeValor;
        valor12.CC_Lista__c = listaDerivar.Id;
        valor12.CC_Mensajes_Mostrar__c = 'Informar al cliente que hemos derivado su petición a los responsables de organización para su valoración';
        valores.add(valor12);
        
        CC_Lista_Valores__c valor14 = new CC_Lista_Valores__c();
        valor14.Name = 'Mensaje imagin cambio de gestor';
        valor14.RecordTypeId = recordTypeValor;
        valor14.CC_Lista__c = listaDerivar.Id;
        valor14.CC_Mensajes_Mostrar__c = 'En un plazo máximo de 48h se pondrán en contacto con el cliente';
        valores.add(valor14);
        
        CC_Lista_Valores__c valor15 = new CC_Lista_Valores__c();
        valor15.Name = 'Mensaje imagin else';
        valor15.RecordTypeId = recordTypeValor;
        valor15.CC_Lista__c = listaDerivar.Id;
        valor15.CC_Mensajes_Mostrar__c = 'En un plazo máximo de 48h se pondrán en contacto con el cliente';
        valores.add(valor15);
        
        CC_Lista_Valores__c valor16 = new CC_Lista_Valores__c();
        valor16.Name = 'Mensaje caixabank cita tarea gestor';
        valor16.RecordTypeId = recordTypeValor;
        valor16.CC_Lista__c = listaDerivar.Id;
        valor16.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
        valores.add(valor16);
        
        CC_Lista_Valores__c valor17 = new CC_Lista_Valores__c();
        valor17.Name = 'Mensaje caixabank cita tarea gestor else';
        valor17.RecordTypeId = recordTypeValor;
        valor17.CC_Lista__c = listaDerivar.Id;
        valor17.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
        valores.add(valor17);
        
        CC_Lista_Valores__c valor18 = new CC_Lista_Valores__c();
        valor18.Name = 'Mensaje caixabank oficina cliente';
        valor18.RecordTypeId = recordTypeValor;
        valor18.CC_Lista__c = listaDerivar.Id;
        valor18.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
        valores.add(valor18);
        
        CC_Lista_Valores__c valor19 = new CC_Lista_Valores__c();
        valor19.Name = 'Mensaje caixabank oficina cliente else';
        valor19.RecordTypeId = recordTypeValor;
        valor19.CC_Lista__c = listaDerivar.Id;
        valor19.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
        valores.add(valor19);
        
        CC_Lista_Valores__c valor20 = new CC_Lista_Valores__c();
        valor20.Name = 'Mensaje caixabank cambio de gestor';
        valor20.RecordTypeId = recordTypeValor;
        valor20.CC_Lista__c = listaDerivar.Id;
        valor20.CC_Mensajes_Mostrar__c = 'Informar al cliente que hemos derivado su petición a los responsables de organización para su valoración';
        valores.add(valor20);
        
        CC_Lista_Valores__c valor21 = new CC_Lista_Valores__c();
        valor21.Name = 'Mensaje caixabank cambio de oficina';
        valor21.RecordTypeId = recordTypeValor;
        valor21.CC_Lista__c = listaDerivar.Id;
        valor21.CC_Mensajes_Mostrar__c = 'Informar al cliente que hemos derivado su petición a los responsables de organización para su valoración';
        valores.add(valor21);
        
        CC_Lista_Valores__c valor22 = new CC_Lista_Valores__c();
        valor22.Name = 'Hub gestion';
        valor22.RecordTypeId = recordTypeValor;
        valor22.CC_Lista__c = listaDerivar.Id;
        valor22.CC_Mensajes_Mostrar__c = '05202';
        valores.add(valor22);
        
        CC_Lista_Valores__c valor23 = new CC_Lista_Valores__c();
        valor23.Name = 'Hub sales';
        valor23.RecordTypeId = recordTypeValor;
        valor23.CC_Lista__c = listaDerivar.Id;
        valor23.CC_Mensajes_Mostrar__c = '04563';
        valores.add(valor23);

        CC_Lista_Valores__c valor24 = new CC_Lista_Valores__c();
        valor24.Name = 'Pregunta Enrollment Sign';
        valor24.RecordTypeId = recordTypeValor;
        valor24.CC_Lista__c = listaDerivar.Id;
        valor24.CC_Mensajes_Mostrar__c = '¿El cliente se encuentra en el extranjero?';
        valores.add(valor24);

        CC_Lista_Valores__c valor25 = new CC_Lista_Valores__c();
        valor25.Name = 'Pregunta realizar remitido	';
        valor25.RecordTypeId = recordTypeValor;
        valor25.CC_Lista__c = listaDerivar.Id;
        valor25.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
        valores.add(valor25);            

        CC_Lista_Valores__c valor26 = new CC_Lista_Valores__c();
        valor26.Name = 'Pregunta CSBD Contratar 2';
        valor26.RecordTypeId = recordTypeValor;
        valor26.CC_Lista__c = listaDerivar.Id;
        valor26.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
        valores.add(valor26);

        CC_Lista_Valores__c valor27 = new CC_Lista_Valores__c();
        valor27.Name = 'Pregunta CSBD Contratar';
        valor27.RecordTypeId = recordTypeValor;
        valor27.CC_Lista__c = listaDerivar.Id;
        valor27.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
        valores.add(valor27);

        CC_Lista_Valores__c valor28 = new CC_Lista_Valores__c();
        valor28.Name = 'Toast CSBD No Contratar';
        valor28.RecordTypeId = recordTypeValor;
        valor28.CC_Lista__c = listaDerivar.Id;
        valor28.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
        valores.add(valor28);

        
        CC_Lista_Valores__c valor29 = new CC_Lista_Valores__c();
        valor29.Name = 'Texto documentacion certificado';
        valor29.RecordTypeId = recordTypeValor;
        valor29.CC_Lista__c = listaDerivar.Id;
        valor29.CC_Mensajes_Mostrar__c = 'textoDocumentacionCertificado';
        valores.add(valor29);

        CC_Lista_Valores__c valor30 = new CC_Lista_Valores__c();
        valor30.Name = 'Documentacion certificado caixa';
        valor30.RecordTypeId = recordTypeValor;
        valor30.CC_Lista__c = listaDerivar.Id;
        valor30.CC_Mensajes_Mostrar__c = 'Ventas';
        valores.add(valor30);

        CC_Lista_Valores__c valor31 = new CC_Lista_Valores__c();
        valor31.Name = 'Texto oportunidad tarea existente';
        valor31.RecordTypeId = recordTypeValor;
        valor31.CC_Lista__c = listaDerivar.Id;
        valor31.CC_Mensajes_Mostrar__c = 'No es posible crear una oportunidad porque ya existe una cita o tarea creada';
        valores.add(valor31);

        CC_Lista_Valores__c valor32 = new CC_Lista_Valores__c();
        valor32.Name = 'Texto cita o tarea existe';
        valor32.RecordTypeId = recordTypeValor;
        valor32.CC_Lista__c = listaDerivar.Id;
        valor32.CC_Mensajes_Mostrar__c = 'No es posible crear una nueva cita o tarea porque ya existe una cita o tarea creada';
        valores.add(valor32);

        insert valores;
    }

    public static void insertarLOVGestorDefault(String externalId, String nombre){
        Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        List<CC_Lista_Valores__c> listas = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c ();
        lista.Name = 'Gestor por defecto CC';
        lista.RecordTypeId = recordTypeLista;
        listas.add(lista);
        insert listas;
       
        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c valorExId = new CC_Lista_Valores__c ();
        valorExId.Name = 'ExternalID';
        valorExId.RecordTypeId = recordTypeValor;
        valorExId.CC_Lista__c = lista.Id;
        valorExId.CC_Valor__c = externalId;        
        valores.add(valorExId);

        CC_Lista_Valores__c valorName = new CC_Lista_Valores__c ();
        valorName.Name = 'Nombre';
        valorName.RecordTypeId = recordTypeValor;
        valorName.CC_Lista__c = lista.Id;
        valorName.CC_Valor__c = nombre;
        valores.add(valorName);
        
        insert valores;
    }

    /*public static Case insertarCasoDocumentacion(Id operadorCliente){

        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
        Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
       
        Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');


        Account cuentaCaixa = new Account();
        cuentaCaixa.LastName = 'Cliente Senior';
        cuentaCaixa.AV_EAPGestor__c = contactoEmple.Id;
        cuentaCaixa.CC_NumPerso__c = '0000015';
        cuentaCaixa.AV_OficinaPrincipal__c = centro.Id;
        cuentaCaixa.RecordtypeId =  rtClientePA;
        cuentaCaixa.CC_Numero_Documento__c = '45729937B';
        cuentaCaixa.AV_Cliente__c = true;
        insert cuentaCaixa;

        //Share account

        //MCC
        List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();
        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
            );
        insert tematica;
        mccCreado.add(tematica);

        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
            );        
        insert producto;
        mccCreado.add(producto);
        
        CC_MCC__c motivoDocumentacion = new CC_MCC__c(
            Name = 'Documentación',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Documentación',
            CC_Ambito_Tareas_Imagin__c = 'Documentación',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000018'
            );
        insert motivoDocumentacion;
        mccCreado.add(motivoDocumentacion);

        for(CC_MCC__c record : mccCreado) {
            CC_MCC__Share mccShare = new CC_MCC__Share();
            mccShare.ParentId = record.Id;
            mccShare.UserOrGroupId = operadorCliente;
            mccShare.AccessLevel = 'Edit';
            totalPermisosMCC.add(mccShare);
        }
        insert totalPermisosMCC;    

        Case casoDocumentacionNoImagin = new Case(
            Description = 'casoDocumentacionNoImagin',
            Subject = 'casoDocumentacionNoImagin',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaCaixa.Id,
            CC_Idioma__c = 'es',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoDocumentacion.Id,
            CC_Canal_Respuesta__c = 'Email',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
        );

        insert casoDocumentacionNoImagin;
    }
*/
    public static void insertarMCCsDerivar(User operadorCliente){
        List<CC_MCC__c> tematicas = new List<CC_MCC__c>();
        List<CC_MCC__c> productos = new List<CC_MCC__c>();
        List<CC_MCC__c> motivos = new List<CC_MCC__c>();
        List<CC_MCC__c> causas = new List<CC_MCC__c>();
        List<CC_MCC__c> soluciones = new List<CC_MCC__c>();
        List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();

        Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
        Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        Id causaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        Id solucionId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');

        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();
        
        CC_MCC__c tematica = new CC_MCC__c(
        Name = 'Tematica Test',
        RecordTypeId = tematicaId,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Canal_Operativo__c = 'Cajero',
        CC_Codigo_Externo__c = 'TE-000001'
        );
        tematicas.add(tematica);
        mccCreado.add(tematica);

        CC_MCC__c tematicaCaixaBankNow = new CC_MCC__c(
        Name = 'CaixaBankNow',
        RecordTypeId = tematicaId,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Canal_Operativo__c = 'Cajero',
        CC_Codigo_Externo__c = 'TE-000002'
        );
        tematicas.add(tematicaCaixaBankNow);
        mccCreado.add(tematicaCaixaBankNow);
        insert tematicas;

        CC_MCC__c producto = new CC_MCC__c(
        Name = 'Producto Test',
        RecordTypeId = productoId,
        CC_Tematica__c = tematica.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'PR-000001'
        );        
        productos.add(producto);
        mccCreado.add(producto);

        CC_MCC__c productoMecanismo = new CC_MCC__c(
        Name = 'Mecanismo de Firma',
        RecordTypeId = productoId,
        CC_Tematica__c = tematicaCaixaBankNow.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'PR-000002'
        );        
        productos.add(productoMecanismo);
        mccCreado.add(productoMecanismo);
        insert productos;

        CC_MCC__c motivoOficina = new CC_MCC__c(
        Name = 'Cambio de Oficina',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'Cambio de Oficina',
        CC_Ambito_Tareas_Imagin__c = 'Cambio de Oficina',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000001'
        );
        motivos.add(motivoOficina);
        mccCreado.add(motivoOficina);
        
        CC_MCC__c motivoGestor = new CC_MCC__c(
        Name = 'Cambio de Gestor',
        CC_Ambito_Tareas_Caixa__c = 'Cambio de Gestor',
        CC_Ambito_Tareas_Imagin__c = 'Cambio de Gestor',
        RecordTypeId = motivoId,
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000002'
        );
        motivos.add(motivoGestor);
        mccCreado.add(motivoGestor);
        
        CC_MCC__c motivoPrueba = new CC_MCC__c(
        Name = 'Cambio de Prueba',
        RecordTypeId = motivoId,
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000003'
        );
        motivos.add(motivoPrueba);
        mccCreado.add(motivoPrueba);
        
        CC_MCC__c motivoOffice = new CC_MCC__c(
        Name = 'Oficina',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'Oficina',
        CC_Ambito_Tareas_Imagin__c = 'Oficina',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000004'
        );
        motivos.add(motivoOffice);
        mccCreado.add(motivoOffice);
        
        CC_MCC__c motivoVentas = new CC_MCC__c(
        Name = 'Ventas',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'Ventas',
        CC_Ambito_Tareas_Imagin__c = 'Ventas',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000005'
        );
        motivos.add(motivoVentas);
        mccCreado.add(motivoVentas);
        
        CC_MCC__c motivoVacio = new CC_MCC__c(
        Name = 'Vacio',
        RecordTypeId = motivoId,
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000006'
        );
        motivos.add(motivoVacio);
        mccCreado.add(motivoVacio);
        
        CC_MCC__c motivoCajeros = new CC_MCC__c(
        Name = 'Cajeros',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'Cajeros',
        CC_Ambito_Tareas_Imagin__c = 'Cajeros',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000007'
        );
        motivos.add(motivoCajeros);
        mccCreado.add(motivoCajeros);
        
        CC_MCC__c motivoFraude = new CC_MCC__c(
        Name = 'Fraude',
        RecordTypeId = motivoId,
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000008'
        );
        motivos.add(motivoFraude);
        mccCreado.add(motivoFraude);

        CC_MCC__c motivoNoCliente = new CC_MCC__c(
        Name = 'No clientes',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'No clientes',
        CC_Ambito_Tareas_Imagin__c = 'No clientes',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000009'
        );
        motivos.add(motivoNoCliente);
        mccCreado.add(motivoNoCliente);

        CC_MCC__c motivoTestamentaria = new CC_MCC__c(
        Name = 'Testamentaria',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'Testamentaría',
        CC_Ambito_Tareas_Imagin__c = 'Testamentaría',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000010'
        );
        motivos.add(motivoTestamentaria);
        mccCreado.add(motivoTestamentaria);

        CC_MCC__c motivoActivacionCaixaBank = new CC_MCC__c(
        Name = 'Activación CaixaBankSign',
        RecordTypeId = motivoId,
        CC_Producto_Servicio__c = productoMecanismo.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000011'
        );
        motivos.add(motivoActivacionCaixaBank);
        mccCreado.add(motivoActivacionCaixaBank);

        CC_MCC__c motivoEnrollment = new CC_MCC__c(
        Name = 'Enrollment Sign',
        RecordTypeId = motivoId,
        //CC_Ambito_Tareas_Caixa__c = 'Enrollment Sign',
        CC_Ambito_Tareas_Caixa__c = 'Testamentaría',
        CC_Ambito_Tareas_Imagin__c = 'Testamentaría',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000012'
        );
        motivos.add(motivoEnrollment);
        mccCreado.add(motivoEnrollment);

        CC_MCC__c motivoCSBD3N = new CC_MCC__c(
        Name = 'CSBD 3N',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'CSBD 3N',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000013'
        );
        motivos.add(motivoCSBD3N);
        mccCreado.add(motivoCSBD3N);

        CC_MCC__c motivoCSBDContratar = new CC_MCC__c(
        Name = 'CSBD Contratar',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'CSBD Contratar',
        CC_Ambito_Tareas_Imagin__c = 'CSBD Contratar',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000014'
        );
        motivos.add(motivoCSBDContratar);
        mccCreado.add(motivoCSBDContratar);

        CC_MCC__c motivoCSBDNoContratar = new CC_MCC__c(
        Name = 'CSBD No Contratar',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'CSBD No Contratar',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000015'
        );
        motivos.add(motivoCSBDNoContratar);
        mccCreado.add(motivoCSBDNoContratar);

        CC_MCC__c motivoHubImagin = new CC_MCC__c(
        Name = 'Hub Imagin',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Imagin__c = 'Hub Imagin',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000016'
        );
        motivos.add(motivoHubImagin);
        mccCreado.add(motivoHubImagin);

        CC_MCC__c motivoOficinaFisica = new CC_MCC__c(
        Name = 'Oficina fisica',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'Oficina física',
        CC_Ambito_Tareas_Imagin__c = 'Oficina física',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000017'
        );
        motivos.add(motivoOficinaFisica);
        mccCreado.add(motivoOficinaFisica);

        CC_MCC__c motivoDocumentacion = new CC_MCC__c(
            Name = 'Documentación',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Documentación',
            CC_Ambito_Tareas_Imagin__c = 'Documentación',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000018'
            );
            motivos.add(motivoDocumentacion);
            mccCreado.add(motivoDocumentacion);

        insert motivos;
        
        CC_MCC__c causaFraude = new CC_MCC__c(
        Name = 'Fraude',
        RecordTypeId = causaId,
        CC_Producto_Servicio__c = motivoFraude.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'CA-000001'
        );
        causas.add(causaFraude);
        mccCreado.add(causaFraude);

        CC_MCC__c causaExtranjero = new CC_MCC__c(
        Name = 'Cliente en el extranjero',
        RecordTypeId = causaId,
        CC_Producto_Servicio__c = motivoActivacionCaixaBank.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'CA-000002'
        );
        causas.add(causaExtranjero);
        mccCreado.add(causaExtranjero);
        insert causas;

        CC_MCC__c solucionFraude = new CC_MCC__c(
        Name = 'Fraude',
        RecordTypeId = solucionId,
        CC_Producto_Servicio__c = causaFraude.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'SO-000001',
        CC_AmbitoTareas__c = 'Fraude'
        );
        soluciones.add(solucionFraude);
        mccCreado.add(solucionFraude);
        insert soluciones;

        for(CC_MCC__c record : mccCreado) {
            CC_MCC__Share mccShare = new CC_MCC__Share();
            mccShare.ParentId = record.Id;
            mccShare.UserOrGroupId = operadorCliente.Id;
            mccShare.AccessLevel = 'Edit';
            totalPermisosMCC.add(mccShare);
        }
        insert totalPermisosMCC;
    }

    public static List<CC_MCC__c> insertCustomMCC(Map<String, String> params, User operadorCliente){

        Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
        Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        Id causaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        Id solucionId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();
        List<CC_MCC__c> mcc = new List<CC_MCC__c>();


        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica ' + params.get('Name'),
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = params.get('CC_Tipo_Cliente__c'),
            CC_Canal_Operativo__c = params.get('CC_Canal_Operativo__c'),
            CC_Codigo_Externo__c = 'CSTE-00000' + params.get('CC_Codigo_Externo__c')
        );
        mcc.add(tematica);

        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto' + params.get('Name'),
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,CC_Tipo_Cliente__c = params.get('CC_Tipo_Cliente__c'),
            CC_Codigo_Externo__c = 'CSPR-00000' + params.get('CC_Codigo_Externo__c')
        );    
        mcc.add(producto);

        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo' + params.get('Name').toString(),
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = params.get('CC_Ambito_Tareas_Caixa__c'),
            CC_Ambito_Tareas_Imagin__c = params.get('CC_Ambito_Tareas_Imagin__c'),
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = params.get('CC_Tipo_Cliente__c'),
            CC_Codigo_Externo__c = 'CSMO-0000' + params.get('CC_Codigo_Externo__c').toString()
        );
        mcc.add(motivo);

        CC_MCC__c causa = new CC_MCC__c(
            Name = 'Causa' + params.get('Name'),
            RecordTypeId = causaId,
            CC_Motivo__c = motivo.Id,
            CC_Tipo_Cliente__c = params.get('CC_Tipo_Cliente__c'),
            CC_Codigo_Externo__c = 'CSCA-0000' + params.get('CC_Codigo_Externo__c')
        );
        mcc.add(causa);

        CC_MCC__c solucion = new CC_MCC__c(
            Name = 'Solucion' + params.get('Name'),
            RecordTypeId = solucionId,
            CC_Causa__c = causa.Id,
            CC_Tipo_Cliente__c = params.get('CC_Tipo_Cliente__c'),
            CC_Codigo_Externo__c = 'CSSO-0000' + params.get('CC_Codigo_Externo__c'),
            CC_AmbitoTareas__c = params.get('CC_AmbitoTareas__c')
        );
        mcc.add(solucion);

        insert tematica;
        insert producto;
        insert motivo;
        insert causa;
        insert solucion;

        for(CC_MCC__c record : mcc) {
            CC_MCC__Share mccShare = new CC_MCC__Share();
            mccShare.ParentId = record.Id;
            mccShare.UserOrGroupId = operadorCliente.Id;
            mccShare.AccessLevel = 'Edit';
            totalPermisosMCC.add(mccShare);
        }
        insert totalPermisosMCC;

        return mcc;
    }

    public static Account insertAccount(Map<String, Object> params){
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        params.put('recordTypeId', recordTypeCaso);
        Account nuevoAccount = new Account();
        for (String campo : params.keySet()) {
            try {
                nuevoAccount.put(campo, params.get(campo));
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        try {
            insert nuevoAccount;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());

        }
        return nuevoAccount;
    }

    public static Contact insertContacts(Map<String, Object> params){
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        params.put('recordTypeId', recordTypeCaso);
        Contact nuevoContact = new Contact();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        for (String campo : params.keySet()) {
            if (fieldMap.containsKey(campo)) {
                try {
                    nuevoContact.put(campo, params.get(campo));
                } catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
        }
        try {
            insert nuevoContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());

        }
        return nuevoContact;
    }

    public static Case insertCase(Map<String, Object> params){
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id tematicaId = (Id) params.get('tematicaId');
        Id productoId = (Id) params.get('productoId');
        Id motivoId = (Id) params.get('motivoId');
        Id accountId = (Id) params.get('accountId');
        String description = (String) params.get('description');
        String motivoText = (String) params.get('motivoText');

        Case casoPrueba = new Case(
            Description = description,
            Subject = description,
            Origin = 'Email',
            Status = 'Activo',
            accountId = accountId,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematicaId, 
            CC_MCC_ProdServ__c = productoId,
            CC_MCC_Motivo__c = motivoId,
            CC_Motivo__c = motivoText,
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_OTP_Nivel__c = 'Nivel 2',
            CC_Status_Autorizacion__c = 'APPROVED',
            CC_OTP_Valido__c = true,
            RecordTypeId = recordTypeCaso
        );
        insert casoPrueba;

        return casoPrueba;
    }

    public static CC_MCC__c getMCC(String externalId){
        CC_MCC__c mcc = [SELECT Id  FROM CC_MCC__c WHERE CC_Codigo_Externo__c = :externalId LIMIT 1];
        return mcc;
    }
}