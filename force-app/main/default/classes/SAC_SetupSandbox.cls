/*****************************************************************
 * Name: SAC_SetupSandbox
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Carga de datos.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0                     		   Daniel Benito        06/10/21     Creación
 * 1.1            US507573         Jose Carlos Blanco   19/01/23     Modificación
*****************************************************************/


/*
Cosas a añadir:
    Maestro temas:
        nombre: Resolución SAC
        record type: SAC_TipoAdjuntos
        SAC_DeveloperName__c: RESOLUCION
    Oficinas
    grupos de trabajo en cada mcc
*/

public with sharing class SAC_SetupSandbox {
    //Nombre de la Org
    public static String nombreOrg = UserInfo.getUserName().substringAfterLast('.');
    //Fecha y hora actual
    public static DateTime inicioVigencia = System.now();
    
    //RecordTypes grupos colaboradores
    public static Id recTypeProveedor = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
    public static Id recTypeLetrados = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();
    public static Id recTypeResponsable = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();

    //RecordTypes MCCs
    public static Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
    public static Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
    public static Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
    public static Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

    //RecordType Accounts(cliente particular)
    public static Id recTypeClienteParticular = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

    //RecordTypes antecedentes
    public static Id recTypeContactCenter = Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName().get('SAC_AntecedentesCC').getRecordTypeId();
    public static Id recTypeCBPO = Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName().get('SAC_AntecedentesSupervisoresCBPO').getRecordTypeId();
    public static Id recTypeDemandas = Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName().get('SAC_DemandasJudicialesContraLaEntidad').getRecordTypeId();
    public static Id recTypeMorosidad = Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName().get('SAC_DemandasJudicialesPorMorosidad').getRecordTypeId();
    public static Id recTypeHistoricas = Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName().get('SAC_ReclamacionesHistoricas').getRecordTypeId();
    public static Id recTypeCPC = Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName().get('SAC_ReclamacionesPrescriptoresCPC').getRecordTypeId();
    
    //RecordTypes maestro acciones
    public static Id recTypeMaestroAcciones = Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroAcciones').getRecordTypeId();

    public static void crearUsuarios(){

        List<User> usuarios = new List<User>();

        //Perfil y rol de los usuarios 

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General' LIMIT 1];
        UserRole roleId = [SELECT Id FROM UserRole WHERE Name = 'SAC General' LIMIT 1]; 

        
        String usernameCom = 'rocio.martin.m' + nombreOrg + '@caixabank.com';
        List<User> usuarioComprueba = [SELECT id FROM User WHERE username = :usernameCom];

        //Creación de Usuarios

        User user1 = new User(
            firstName = 'Rocío',
            lastName = 'Martin',
            username = 'rocio.martin.m' + nombreOrg + '@caixabank.com',
            email = 'rocio.martin.m@caixabank.com',
            TimeZoneSidKey = 'Europe/Paris',
            Alias = 'RocíoM11',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId.id,
            UserRoleId = roleId.id);
        usuarios.add(user1);

        User user2 = new User(
            firstName = 'Ana',
            lastName = 'Calabuig',
            username = 'ana.calabuig.jaquotot' + nombreOrg + '@dxc.com',
            email = 'ana.calabuig.jaquotot@dxc.com',
            TimeZoneSidKey = 'Europe/Paris',
            Alias = 'AnaCala1',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId.id,
            UserRoleId = roleId.id);
            usuarios.add(user2);

        User user3 = new User(
            firstName = 'José',
            lastName = 'Catalan',
            username = 'jose.catalan' + nombreOrg + '@caixabankops.com',
            email = 'jose.catalan@caixabankops.com',
            TimeZoneSidKey = 'Europe/Paris',
            Alias = 'JoséCa11',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId.id,
            UserRoleId = roleId.id);
        usuarios.add(user3);

        User user4 = new User(
            firstName = 'Carlos',
            lastName = 'Ordovas',
            username = 'cordovas' + nombreOrg + '@caixabank.com',
            email = 'cordovas@caixabank.com',
            TimeZoneSidKey = 'Europe/Paris',
            Alias = 'Carlos11',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId.id,
            UserRoleId = roleId.id);
        usuarios.add(user4);

        User user5 = new User(
            firstName = 'Edgar',
            lastName = 'Vazquez',
            username = 'ejmarquez' + nombreOrg + '@caixabank.com',
            email = 'ejmarquez@caixabank.com',
            TimeZoneSidKey = 'Europe/Paris',
            Alias = 'EdgarV11',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId.id,
            UserRoleId = roleId.id);
        usuarios.add(user5);

        User user6 = new User(
            firstName = 'Agustin',
            lastName = 'Castellanos',
            username = 'acastellanos' + nombreOrg + '@viewnext.com',
            email = 'acastellanos@viewnext.com',
            TimeZoneSidKey = 'Europe/Paris',
            Alias = 'Agusti11',
            LocaleSidKey = 'es_ES',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId.id,
            UserRoleId = roleId.id);
        usuarios.add(user6);
	
        if(usuarioComprueba.isEmpty()){
            SAC_DatabaseDML.insertListDML(usuarios, true); 
            //Database.insert(usuarios);
        }
    }

     /*****************************************************************
    * Proposito: Cargar de datos la Org.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR                DATE         Description
    * 1.0                             Daniel Benito         06/10/21     Creación
    * 1.1            US507573         Jose Carlos Blanco    19/01/23     Modificación
    *****************************************************************/

    public static void parametrizacionDatos(){

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        List<SAC_MaestroAccionesReclamacion__c> acciones = new List<SAC_MaestroAccionesReclamacion__c>();
        List<CC_MCC__c> mccs = new List<CC_MCC__c>();
        List<CC_MCC_Grupo_Colaborador__c> mccGrupos = new List<CC_MCC_Grupo_Colaborador__c>();
        List<Account> clientesParticulares = new List<Account>();
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        List<SAC_Antecedentes__c> antecedentes = new List<SAC_Antecedentes__c>();

        //Usuarios

        /*String username1 = 'rocio.martin.m' + nombreOrg + '@caixabank.com';
        String username2 = 'ana.calabuig.jaquotot' + nombreOrg + '@dxc.com';
        String username3 = 'jose.catalan' + nombreOrg + '@caixabankops.com';
        String username4 = 'cordovas' + nombreOrg + '@caixabank.com';
        String username5 = 'ejmarquez' + nombreOrg + '@caixabank.com';
        String username6 = 'acastellanos' + nombreOrg + '@viewnext.com';*/

        List <User> users = [SELECT id, username FROM User WHERE Alias = 'RocíoM11'
                                                 OR Alias = 'AnaCala1'
                                                 OR Alias = 'JoséCa11'
                                                 OR Alias = 'Carlos11'
                                                 OR Alias = 'EdgarV11'
                                                 OR Alias = 'Agusti11'];

        User user1 = users[0];
        User user2 = users[1];
        User user3 = users[2];
        User user4 = users[3];
        User user5 = users[4];
        User user6 = users[5];

        /*User user2 = [SELECT id FROM User WHERE username = :username2 LIMIT 1];
        User user3 = [SELECT id FROM User WHERE username = :username3 LIMIT 1];
        User user4 = [SELECT id FROM User WHERE username = :username4 LIMIT 1];
        User user5 = [SELECT id FROM User WHERE username = :username5 LIMIT 1];
        User user6 = [SELECT id FROM User WHERE username = :username6 LIMIT 1];*/

        

        //Creación grupos colaboradores

        /*
        CC_Grupo_Colaborador__c g1 = new CC_Grupo_Colaborador__c();
        g1.Name = 'Proveedor DXC_TESTER1';
        g1.RecordTypeId = recTypeProveedor;
        g1.SAC_PorcentajeAsignacion__c = 60;
        g1.SAC_MaximoCasosDiarios__c = 10;

        grupos.add(g1);

        CC_Grupo_Colaborador__c g2 = new CC_Grupo_Colaborador__c();
        g2.Name = 'Proveedor INDA_TESTER1';
        g2.RecordTypeId = recTypeProveedor;
        g2.SAC_PorcentajeAsignacion__c = 40;
        g2.SAC_MaximoCasosDiarios__c = 5;

        grupos.add(g2);

        */
        
        CC_Grupo_Colaborador__c g3 = new CC_Grupo_Colaborador__c(
            Name = 'FORCADA',
            RecordTypeId = recTypeLetrados);
        grupos.add(g3);

        CC_Grupo_Colaborador__c g4 = new CC_Grupo_Colaborador__c(
            Name = 'VILAR RIBA',
            RecordTypeId = recTypeLetrados);
        grupos.add(g4);
        
        CC_Grupo_Colaborador__c g5 = new CC_Grupo_Colaborador__c(
            Name = 'Bufet Baro',
            RecordTypeId = recTypeLetrados);
        grupos.add(g5);

        CC_Grupo_Colaborador__c g6 = new CC_Grupo_Colaborador__c(
            Name = 'COPS',
            RecordTypeId = recTypeResponsable,
            SAC_PermiteConsultas__c = true,
            SAC_PermiteTareas__c = true,
            SAC_PermiteEscalado__c = true,
            SAC_DeveloperName__c = 'COPS');
       // g6.SAC_NivelGrupo__c = 'Nivel 1';
       grupos.add(g6);

        CC_Grupo_Colaborador__c g7 = new CC_Grupo_Colaborador__c(
            Name = 'Asesoría Jurídica',
            RecordTypeId = recTypeResponsable,
            SAC_PermiteConsultas__c = false,
            SAC_PermiteTareas__c = false,
            SAC_PermiteEscalado__c = true,
            SAC_NivelGrupo__c = 'SAC_Nivel2',
            SAC_DeveloperName__c = 'AJ');
        grupos.add(g7);

        CC_Grupo_Colaborador__c g8 = new CC_Grupo_Colaborador__c(
            Name = 'DXC Zaragoza',
            RecordTypeId = recTypeResponsable,
            SAC_PermiteConsultas__c = true,
            SAC_PermiteTareas__c = true,
            SAC_PermiteEscalado__c = false);
        grupos.add(g8);

        CC_Grupo_Colaborador__c g9 = new CC_Grupo_Colaborador__c(
            Name = 'Departamento ENS',
            RecordTypeId = recTypeResponsable,
            SAC_PermiteConsultas__c = true,
            SAC_PermiteTareas__c = true,
            SAC_PermiteEscalado__c = false);
        grupos.add(g9);

        CC_Grupo_Colaborador__c g10 = new CC_Grupo_Colaborador__c(
            Name = 'DXC SCV',
            RecordTypeId = recTypeResponsable,
            SAC_PermiteConsultas__c = true,
            SAC_PermiteTareas__c = true,
            SAC_PermiteEscalado__c = false);
        grupos.add(g10);


        CC_Grupo_Colaborador__c g11 = new CC_Grupo_Colaborador__c(
            Name = 'Vida/Segu',
            RecordTypeId = recTypeResponsable,
            SAC_PermiteConsultas__c = true,
            SAC_PermiteTareas__c = true,
            SAC_PermiteEscalado__c = false);
        grupos.add(g11);

        SAC_DatabaseDML.insertListDML(grupos, true); 
        //Database.insert(grupos);


        //Creación Acciones

        SAC_MaestroAccionesReclamacion__c ac1 = new SAC_MaestroAccionesReclamacion__c(
            Name = 'Comisiones descubierto',
            SAC_Descripcion__c = 'Comisiones descubierto',
            RecordTypeId = recTypeMaestroAcciones,
            SAC_PlazoMaximo__c = 2,
            SAC_Prorroga__c = 1,
            SAC_Activo__c = true,
            SAC_EquipoResponsable__c = g8.id);

        acciones.add(ac1);

        SAC_MaestroAccionesReclamacion__c ac2 = new SAC_MaestroAccionesReclamacion__c(
            Name = 'Comisiones descubierto',
            SAC_Descripcion__c = 'Intereses, Reliquidación de intereses',
            RecordTypeId = recTypeMaestroAcciones,
            SAC_PlazoMaximo__c = 3,
            SAC_Prorroga__c = 2,
            SAC_Activo__c = true,
            SAC_EquipoResponsable__c = g9.id);
        acciones.add(ac2);

        SAC_MaestroAccionesReclamacion__c ac3 = new SAC_MaestroAccionesReclamacion__c(
            Name = 'Comisiones descubierto',
            SAC_Descripcion__c = 'Tarjetas, Operaciones TCO tarjetas de  fraude',
            RecordTypeId = recTypeMaestroAcciones,
            SAC_PlazoMaximo__c = 2,
            SAC_Prorroga__c = 1,
            SAC_Activo__c = true,
            SAC_EquipoResponsable__c = g8.id);
        acciones.add(ac3);

        SAC_MaestroAccionesReclamacion__c ac4 = new SAC_MaestroAccionesReclamacion__c(
            Name = 'Gastos de formalización, GGH',
            SAC_Descripcion__c = 'Gastos de formalización, GGH',
            RecordTypeId = recTypeMaestroAcciones,
            SAC_PlazoMaximo__c = 3,
            SAC_Prorroga__c = 1,
            SAC_Activo__c = true,
            SAC_EquipoResponsable__c = g10.id);
        acciones.add(ac4);
        
        SAC_MaestroAccionesReclamacion__c ac5 = new SAC_MaestroAccionesReclamacion__c(
            Name = 'Seguros, Devolución recibos',
            SAC_Descripcion__c = 'Seguros, Devolución recibos',
            RecordTypeId = recTypeMaestroAcciones,
            SAC_PlazoMaximo__c = 3,
            SAC_Prorroga__c = 1,
            SAC_Activo__c = true,
            SAC_EquipoResponsable__c = g11.id);
        acciones.add(ac5);

        SAC_DatabaseDML.insertListDML(acciones, true); 
        //Database.insert(acciones);

        //Creación MCCs 

        CC_MCC__c mccTematica1 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Avales',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-0101');
        mccs.add(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'Avales Fianzas y Otras Garantías',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-010101',
            CC_Tematica__c = mccTematica1.id);
        mccs.add(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'Discrepancia con importe deuda reclamada',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Producto_Servicio__c = mccProdServ1.id,
            CC_Codigo_Externo__c = 'TEST-0102');
        mccs.add(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'Discrepancia con importe deuda reclamada',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-01010101',
            CC_Motivo__c = mccMotivo1.id);
        mccs.add(mccDetalle1);

        //////////////////////

        CC_MCC__c mccTematica2 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Avales',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Tipo_Cliente__c = 'SAC',
            CC_Codigo_Externo__c = 'TEST-0201');
        mccs.add(mccTematica2);

        CC_MCC__c mccProdServ2 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'Avales Fianzas y Otras Garantías',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-01010102',
            CC_Tematica__c = mccTematica2.id);
        mccs.add(mccProdServ2);

        CC_MCC__c mccMotivo2 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'Gastos de formalización, gestorías, tasación',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Producto_Servicio__c = mccProdServ2.id,
            CC_Codigo_Externo__c = 'TEST-0202');
        mccs.add(mccMotivo2);

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'Gastos de formalización, gestorías, tasación',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-01010103',
            CC_Motivo__c = mccMotivo2.id);
        mccs.add(mccDetalle2);

        //////////////////////

        CC_MCC__c mccTematica3 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Créditos',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-0301');
        mccs.add(mccTematica3);

        CC_MCC__c mccProdServ3 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'Créditos Hipotecarios Interés Variable',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-010101004',
            CC_Tematica__c = mccTematica3.id);
        mccs.add(mccProdServ3);

        CC_MCC__c mccMotivo3 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'IRPH',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Producto_Servicio__c = mccProdServ3.id,
            CC_Codigo_Externo__c = 'TEST-0302');
        mccs.add(mccMotivo3);

        CC_MCC__c mccDetalle3 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'IRPH',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-010101005',
            CC_Motivo__c = mccMotivo3.id);
        mccs.add(mccDetalle3);

        SAC_DatabaseDML.insertListDML(mccs, true); 
        //Database.insert(mccs);

        //Creación grupos colaboradores MCCs

        CC_MCC_Grupo_Colaborador__c mccGrupo1 = new CC_MCC_Grupo_Colaborador__c(
            Name = 'VILAR RIBA',
            CC_MCC__c = mccDetalle1.id,
            CC_Grupo_Colaborador__c = g4.id);
            mccGrupos.add(mccGrupo1);

        CC_MCC_Grupo_Colaborador__c mccGrupo2 = new CC_MCC_Grupo_Colaborador__c(
            Name = 'Proveedor HP SAC',
            CC_MCC__c = mccDetalle2.id,
            CC_Grupo_Colaborador__c = g4.id);
            mccGrupos.add(mccGrupo2);

        CC_MCC_Grupo_Colaborador__c mccGrupo3 = new CC_MCC_Grupo_Colaborador__c(
            Name = 'FORCADA',
            CC_MCC__c = mccDetalle3.id,
            CC_Grupo_Colaborador__c = g3.id);
            mccGrupos.add(mccGrupo3);

            SAC_DatabaseDML.insertListDML(mccGrupos, true); 
            //Database.insert(mccGrupos);


        //Creación de colaboradores

        /*
        CC_Grupo_Colaborador_Contact__c gC1 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g1.id
        );
        insert gC1;

        CC_Grupo_Colaborador_Contact__c gC2 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g1.id
        );
        insert gC2;

        CC_Grupo_Colaborador_Contact__c gC3 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g1.id
        );
        insert gC3;

        CC_Grupo_Colaborador_Contact__c gC4 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g1.id
        );
        insert gC4;
        */

        ///////////

        /*
        CC_Grupo_Colaborador_Contact__c gC5 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g2.id
        );
        insert gC5;

        CC_Grupo_Colaborador_Contact__c gC61 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g2.id
        );
        insert gC61;

        CC_Grupo_Colaborador_Contact__c gC62 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g2.id
        );
        insert gC62;

        CC_Grupo_Colaborador_Contact__c gC63 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g2.id
        );
        insert gC63;
        */

        ///////////

        CC_Grupo_Colaborador_Contact__c gC6 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g3.id
        );
        colaboradores.add(gC6);

        CC_Grupo_Colaborador_Contact__c gC7 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g3.id
        );
        colaboradores.add(gC7);

        CC_Grupo_Colaborador_Contact__c gC8 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g3.id
        );
        colaboradores.add(gC8);

        CC_Grupo_Colaborador_Contact__c gC9 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g3.id
        );
        colaboradores.add(gC9);

        CC_Grupo_Colaborador_Contact__c gC10 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g3.id
        );
        colaboradores.add(gC10);

        CC_Grupo_Colaborador_Contact__c gC11 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g3.id
        );
        colaboradores.add(gC11);

        ////////////

        CC_Grupo_Colaborador_Contact__c gC12 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g4.id
        );
        colaboradores.add(gC12);

        CC_Grupo_Colaborador_Contact__c gC13 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g4.id
        );
        colaboradores.add(gC13);

        CC_Grupo_Colaborador_Contact__c gC14 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g4.id
        );
        colaboradores.add(gC14);

        CC_Grupo_Colaborador_Contact__c gC15 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g4.id
        );
        colaboradores.add(gC15);

        CC_Grupo_Colaborador_Contact__c gC16 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g4.id
        );
        colaboradores.add(gC16);

        CC_Grupo_Colaborador_Contact__c gC17 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g4.id
        );
        colaboradores.add(gC17);

        ////////////

        CC_Grupo_Colaborador_Contact__c gC18 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g5.id
        );
        colaboradores.add(gC18);

        CC_Grupo_Colaborador_Contact__c gC19 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g5.id
        );
        colaboradores.add(gC19);

        CC_Grupo_Colaborador_Contact__c gC20 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g5.id
        );
        colaboradores.add(gC20);

        CC_Grupo_Colaborador_Contact__c gC21 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g5.id
        );
        colaboradores.add(gC21);

        CC_Grupo_Colaborador_Contact__c gC22 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g5.id
        );
        colaboradores.add(gC22);

        CC_Grupo_Colaborador_Contact__c gC23 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g5.id
        );
        colaboradores.add(gC23);

        ////////////

        CC_Grupo_Colaborador_Contact__c gC24 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g6.id
        );
        colaboradores.add(gC24);

        CC_Grupo_Colaborador_Contact__c gC25 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g6.id
        );
        colaboradores.add(gC25);

        CC_Grupo_Colaborador_Contact__c gC26 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g6.id
        );
        colaboradores.add(gC26);

        CC_Grupo_Colaborador_Contact__c gC27 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g6.id
        );
        colaboradores.add(gC27);

        CC_Grupo_Colaborador_Contact__c gC28 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g6.id
        );
        colaboradores.add(gC28);

        CC_Grupo_Colaborador_Contact__c gC29 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g6.id
        );
        colaboradores.add(gC29);

        ////////////

        CC_Grupo_Colaborador_Contact__c gC30 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g7.id
        );
        colaboradores.add(gC30);

        CC_Grupo_Colaborador_Contact__c gC31 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g7.id
        );
        colaboradores.add(gC31);

        CC_Grupo_Colaborador_Contact__c gC32 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g7.id
        );
        colaboradores.add(gC32);

        CC_Grupo_Colaborador_Contact__c gC33 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g7.id
        );
        colaboradores.add(gC33);

        CC_Grupo_Colaborador_Contact__c gC34 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g7.id
        );
        colaboradores.add(gC34);

        CC_Grupo_Colaborador_Contact__c gC35 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g7.id
        );
        colaboradores.add(gC35);

        ////////////

        CC_Grupo_Colaborador_Contact__c gC36 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g8.id
        );
        colaboradores.add(gC36);

        CC_Grupo_Colaborador_Contact__c gC37 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g8.id
        );
        colaboradores.add(gC37);

        CC_Grupo_Colaborador_Contact__c gC38 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g8.id
        );
        colaboradores.add(gC38);

        CC_Grupo_Colaborador_Contact__c gC39 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g8.id
        );
        colaboradores.add(gC39);

        CC_Grupo_Colaborador_Contact__c gC40 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g8.id
        );
        colaboradores.add(gC40);

        CC_Grupo_Colaborador_Contact__c gC41 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g8.id
        );
        colaboradores.add(gC41);

        ////////////

        CC_Grupo_Colaborador_Contact__c gC42 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user1.id,
            CC_Grupo_Colaborador__c = g9.id
        );
        colaboradores.add(gC42);

        CC_Grupo_Colaborador_Contact__c gC43 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user2.id,
            CC_Grupo_Colaborador__c = g9.id
        );
        colaboradores.add(gC43);

        CC_Grupo_Colaborador_Contact__c gC44 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user3.id,
            CC_Grupo_Colaborador__c = g9.id
        );
        colaboradores.add(gC44);

        CC_Grupo_Colaborador_Contact__c gC45 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user4.id,
            CC_Grupo_Colaborador__c = g9.id
        );
        colaboradores.add(gC45);

        CC_Grupo_Colaborador_Contact__c gC46 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user5.id,
            CC_Grupo_Colaborador__c = g9.id
        );
        colaboradores.add(gC46);

        CC_Grupo_Colaborador_Contact__c gC47 = new CC_Grupo_Colaborador_Contact__c(

            CC_Usuario__c = user6.id,
            CC_Grupo_Colaborador__c = g9.id
        );
        colaboradores.add(gC47);

        SAC_DatabaseDML.insertListDML(colaboradores, true); 
        //Database.insert(colaboradores);
    }

    public static List<Account> creacionPersonAccount(){
        //Creacion de Person Account
        List<Account> clientesParticulares = new List<Account>();

        Account pA1 = new Account(
            FirstName = 'Ana',
            LastName = 'Belén García López',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '87654321A',
            CC_Email__c = 'ana.calabuig.jaquotot@dxc.com',
            Phone = '967856596',
            PersonMobilePhone = '666555444',
            BillingStreet = 'C/ San Vicente Mártir 80 5A',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA1);

        Account pA2 = new Account(
            FirstName = 'Anastasio',
            LastName = 'Suarez Garcia',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '98765432B',
            CC_Email__c = 'ana.calabuig.jaquotot@dxc.com',
            Phone = '967856596',
            PersonMobilePhone = '766555444',
            BillingStreet = 'C/ San Vicente Mártir 80 5A',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA2);

        Account pA3 = new Account(
            FirstName = 'Ana',
            LastName = 'Lopez Martín',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '76543210C',
            CC_Email__c = 'ana.calabuig.jaquotot@dxc.com',
            Phone = '967586966',
            PersonMobilePhone = '666854236',
            BillingStreet = 'Avd. Francia 90 4C',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA3);

        Account pA4 = new Account(
            FirstName = 'Jose',
            LastName = 'Ignacio Sanchez Lopez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '66658520D',
            CC_Email__c = 'jose.catalan@caixabankops.com',
            Phone = '934207752',
            PersonMobilePhone = '666856985',
            BillingStreet = 'Paseo de Gracia 101 8C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA4);

        Account pA5 = new Account(
            FirstName = 'Josefa',
            LastName = ' Lopez Sanchez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '55585620A',
            CC_Email__c = 'jose.catalan@caixabankops.com',
            Phone = '934256365',
            PersonMobilePhone = '666525633',
            BillingStreet = 'Ramblas 40 8C',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA5);

        Account pA6 = new Account(
            FirstName = 'Jose',
            LastName = 'Luis Martin Grau',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '4585630Z',
            CC_Email__c = 'jose.catalan@caixabankops.com',
            PersonMobilePhone = '658965230',
            BillingStreet = 'Ramblas 40 8C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA6);

        Account pA7 = new Account(
            FirstName = 'Iván',
            LastName = 'Sanchez Romero',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '1234585C',
            CC_Email__c = 'igomez@bankia.com',
            Phone = '917523696',
            PersonMobilePhone = '696332556',
            BillingStreet = 'Ramblas 89 5H',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA7);

        Account pA8 = new Account(
            FirstName = 'Ivana',
            LastName = 'Sanz Sanchez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '4785203B',
            CC_Email__c = 'igomez@bankia.com',
            Phone = '912603630',
            PersonMobilePhone = '622114520',
            BillingStreet = 'C/ Alcalá 40 5C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA8);

        Account pA9 = new Account(
            FirstName = 'Isidoro',
            LastName = 'Lopez Garcia',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '5555555C',
            CC_Email__c = 'igomez@bankia.com',
            Phone = '915862360',
            PersonMobilePhone = '686525552',
            BillingStreet = 'C/ Toledo 55 8F',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA9);

        Account pA10 = new Account(
            FirstName = 'Estefania',
            LastName = 'Nuñez Martinez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '1478563L',
            CC_Email__c = 'ejmarquez@caixabank.com',
            Phone = '915854125',
            PersonMobilePhone = '654545545',
            BillingStreet = 'C/Floristas 15 8C',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA10);

        Account pA11 = new Account(
            FirstName = 'Esteban',
            LastName = 'Galán Sanchez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '0124857M',
            CC_Email__c = 'ejmarquez@caixabank.com',
            Phone = '917508965',
            PersonMobilePhone = '658965603',
            BillingStreet = 'C/ Floristas 15 8C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA11);

        Account pA12 = new Account(
            FirstName = 'Eusebio',
            LastName = 'Morales Maroto',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '0001154C',
            CC_Email__c = 'ejmarquez@caixabank.com',
            Phone = '915896321',
            PersonMobilePhone = '655555553',
            BillingStreet = 'C/ García Marquez 1',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA12);

        Account pA13 = new Account(
            FirstName = 'Agustina',
            LastName = 'Martinez Lopez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '0154874E',
            CC_Email__c = 'acastellanos@viewnext.com',
            Phone = '916325632',
            PersonMobilePhone = '658656352',
            BillingStreet = 'C/Dalias 40 8G',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA13);

        Account pA14 = new Account(
            FirstName = 'Agapito',
            LastName = 'Maroto Romero',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '6398545R',
            CC_Email__c = 'acastellanos@viewnext.com',
            Phone = '917896510',
            PersonMobilePhone = '654555555',
            BillingStreet = 'C/Dalí 89 6C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA14);

        Account pA15 = new Account(
            FirstName = 'Agripina',
            LastName = 'Mangas Romero',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '1154512F',
            CC_Email__c = 'acastellanos@viewnext.com',
            Phone = '914556931',
            PersonMobilePhone = '658799999',
            BillingStreet = 'C/Rosal 25 6C',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA15);

        Account pA16 = new Account(
            FirstName = 'Rosaura',
            LastName = 'Lopez López',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '0147856S',
            CC_Email__c = 'rocio.martin.m@caixabank.com',
            Phone = '917895360',
            PersonMobilePhone = '658966963',
            BillingStreet = 'C/ Leones 8',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA16);

        Account pA17 = new Account(
            FirstName = 'Roberto',
            LastName = 'Suarez Ortega',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '7458523F',
            CC_Email__c = 'rocio.martin.m@caixabank.com',
            PersonMobilePhone = '625778522',
            BillingStreet = 'C/ Leones 8',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA17);

        Account pA18 = new Account(
            FirstName = 'Rogelio',
            LastName = 'Grau Sanz',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '0147856C',
            CC_Email__c = 'rocio.martin.m@caixabank.com',
            Phone = '917820021',
            PersonMobilePhone = '636969696',
            BillingStreet = 'C/Luz 25 8C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA18);

        Account pA19 = new Account(
            FirstName = 'Carla',
            LastName = 'Torres García',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '9874563D',
            CC_Email__c = 'cordovas@caixabank.com',
            Phone = '917896565',
            PersonMobilePhone = '636785896',
            BillingStreet = 'C/ Iglesia 8 9C',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA19);

        Account pA20 = new Account(
            FirstName = 'Carlos',
            LastName = 'Martínez Simón',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '0120210A',
            CC_Email__c = 'cordovas@caixabank.com',
            Phone = '912356442',
            PersonMobilePhone = '689696969',
            BillingStreet = 'C/Madrid 25 2C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA20);

        Account pA21 = new Account(
            FirstName = 'Carolina',
            LastName = 'Rodriguez Sanz',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '7845611T',
            CC_Email__c = 'cordovas@caixabank.com',
            Phone = '914548787',
            PersonMobilePhone = '658745669',
            BillingStreet = 'C/ Luis Gomez 1 2A',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA21);

        Account pA22 = new Account(
            FirstName = 'Octavio',
            LastName = 'Piqueras Romero',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '0100000F',
            CC_Email__c = 'obartoli@caixabank.com',
            Phone = '934204441',
            PersonMobilePhone = '658969875',
            BillingStreet = 'Paseo de Gracia 107 8C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA22);

        Account pA23 = new Account(
            FirstName = 'Oliver',
            LastName = 'Suárez Gómez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '7845856Z',
            CC_Email__c = 'obartoli@caixabank.com',
            Phone = '935004644',
            PersonMobilePhone = '658965885',
            BillingStreet = 'Avd. Diagonal 48 8C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pA23);

        Account pA24 = new Account(
            FirstName = 'Ofelia',
            LastName = 'Garcia Rodriguez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '1547811N',
            CC_Email__c = 'obartoli@caixabank.com',
            Phone = '931554540',
            PersonMobilePhone = '659658962',
            BillingStreet = 'Avd. Diagonal 48 8C',
            CC_Sexo__pc = 'M'
        );
        clientesParticulares.add(pA24);

        Account pAntecedentes = new Account(
            FirstName = 'Julio',
            LastName = 'Garcia Perez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '1547888N',
            CC_Email__c = 'julio@outlook.com',
            Phone = '931554540',
            PersonMobilePhone = '659658962',
            BillingStreet = 'Avd. Diagonal 48 8C',
            CC_Sexo__pc = 'V'
        );
        clientesParticulares.add(pAntecedentes);

        SAC_DatabaseDML.insertListDML(clientesParticulares, true); 
        //Database.insert(clientesParticulares);
        return clientesParticulares;
    }

    public static Entitlement creacionEntitlement(){
        //Creación Entitlement

        SlaProcess slaProceso = [SELECT id FROM SlaProcess WHERE Name = 'SAC_Process' ORDER BY VersionNumber DESC LIMIT 1];
        
        Account pA23 = new Account(
            FirstName = 'Cuenta',
            LastName = 'Entitlement',
            RecordTypeId = recTypeClienteParticular//tiene que ser el record type generico
        );
        SAC_DatabaseDML.insertDML(pA23, false); 
        //Database.insert(pA23);

        Entitlement et = new Entitlement(
            Name = 'Entitlement SAC Reclamacion',
            SlaProcessId = slaProceso.id,
            AccountId = pA23.id,
            StartDate =  Date.newInstance(2021, 02, 15),
            EndDate = Date.newInstance(2050, 02, 15));

        SAC_DatabaseDML.insertDML(et, false); 
        //Database.insert(et);
        return et;
    }
        
    public static List<SAC_Antecedentes__c> creacionCasoAnt(){
        //Creación de casos con antecedentes
        List<SAC_Antecedentes__c> antecedentes = new List<SAC_Antecedentes__c>();

        Account pAntecedentes = new Account(
            FirstName = 'Julio',
            LastName = 'Garcia Perez',
            RecordTypeId = recTypeClienteParticular,
            CC_Numero_Documento__c = '1547888N',
            CC_Email__c = 'julio@outlook.com',
            Phone = '931554540',
            PersonMobilePhone = '659658962',
            BillingStreet = 'Avd. Diagonal 48 8C',
            CC_Sexo__pc = 'V'
        );
        SAC_DatabaseDML.insertDML(pAntecedentes, false); 
        //Database.insert(pAntecedentes);

        Case casoReclamacion1 = new Case(
        Subject = 'Reclamacion con antecedentes',
        Origin = 'Email',
        Status = 'Alta',
        AccountId = pAntecedentes.Id,
        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId());

        SAC_DatabaseDML.insertDML(casoReclamacion1, false); 
        //Database.insert(casoReclamacion1);

        SAC_Antecedentes__c antecedente1 = new SAC_Antecedentes__c(
            Name = 'Antecedente Contact Center',
            RecordTypeId = recTypeContactCenter,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionAntCCCaso__c = casoReclamacion1.Id
        );
        antecedentes.add(antecedente1);

        SAC_Antecedentes__c antecedente2 = new SAC_Antecedentes__c(
            Name = 'Antecedente CBPO',
            RecordTypeId = recTypeCBPO,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionAntSupCBPOCaso__c = casoReclamacion1.Id
        );
        antecedentes.add(antecedente2);

        SAC_Antecedentes__c antecedente3 = new SAC_Antecedentes__c(
            Name = 'Antecedente demanda entidad',
            RecordTypeId = recTypeDemandas,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionDemJudEntCaso__c = casoReclamacion1.Id
        );
        antecedentes.add(antecedente3);

        SAC_Antecedentes__c antecedente4 = new SAC_Antecedentes__c(
            Name = 'Antecedente por morosidad',
            RecordTypeId = recTypeMorosidad,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionDemJudMorCaso__c = casoReclamacion1.Id
        );
        antecedentes.add(antecedente4);

        SAC_Antecedentes__c antecedente5 = new SAC_Antecedentes__c(
            Name = 'Antecedente histórico',
            RecordTypeId = recTypeHistoricas,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionHistRecCaso__c = casoReclamacion1.Id
        );
        antecedentes.add(antecedente5);

        SAC_Antecedentes__c antecedente6 = new SAC_Antecedentes__c(
            Name = 'Antecedente CPC',
            RecordTypeId = recTypeCPC,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionAntPresCPCCaso__c = casoReclamacion1.Id
        );
        antecedentes.add(antecedente6);

        /////////////////

        Case casoReclamacion2 = new Case(
            Subject = 'Alta de errores con antecedentes',
            Origin = 'Email',
            Status = 'Alta',
            AccountId = pAntecedentes.Id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId());
    
        SAC_DatabaseDML.insertDML(casoReclamacion2, false); 
        //Database.insert(casoReclamacion2);

        SAC_Antecedentes__c antecedente7 = new SAC_Antecedentes__c(
            Name = 'Antecedente Contact Center 2',
            RecordTypeId = recTypeContactCenter,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionAntCCCaso__c = casoReclamacion2.Id
        );
        antecedentes.add(antecedente7);

        SAC_Antecedentes__c antecedente8 = new SAC_Antecedentes__c(
            Name = 'Antecedente CBPO 2',
            RecordTypeId = recTypeCBPO,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionAntSupCBPOCaso__c = casoReclamacion2.Id
        );
        antecedentes.add(antecedente8);

        SAC_Antecedentes__c antecedente9 = new SAC_Antecedentes__c(
            Name = 'Antecedente demanda a la entidad 2',
            RecordTypeId = recTypeDemandas,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionDemJudEntCaso__c = casoReclamacion2.Id
        );
        antecedentes.add(antecedente9);

        SAC_Antecedentes__c antecedente10 = new SAC_Antecedentes__c(
            Name = 'Antecedente por morosidad 2',
            RecordTypeId = recTypeMorosidad,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionDemJudMorCaso__c = casoReclamacion2.Id
        );
        antecedentes.add(antecedente10);

        SAC_Antecedentes__c antecedente11 = new SAC_Antecedentes__c(
            Name = 'Antecedente histórico 2',
            RecordTypeId = recTypeHistoricas,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionHistRecCaso__c = casoReclamacion2.Id
        );
        antecedentes.add(antecedente11);

        SAC_Antecedentes__c antecedente12 = new SAC_Antecedentes__c(
            Name = 'Antecedente CPC 2',
            RecordTypeId = recTypeCPC,
            SAC_NIF__c = '12345678Y',
            SAC_Estado__c = 'Trámite',
            SAC_RelacionAntPresCPCCaso__c = casoReclamacion2.Id
        );
        antecedentes.add(antecedente12);
    
        SAC_DatabaseDML.insertListDML(antecedentes, true); 
        //Database.insert(antecedentes);
        return antecedentes;
    }    
}