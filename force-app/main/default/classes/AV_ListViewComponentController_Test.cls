/**********************************************************************************************************************
Name:     AV_ListViewComponentController_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test class of AV_ListViewComponentController
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY          AUTHOR              DATE                Description
1.0                             Carolina Alonso     20/05/2020          Init version
1.1                             Carolina Alonso     18/09/2020          Add test classes for new functionality
1.2         FIX                 Sandra Gómez        27/08/2021          Fix product opportunity
1.3          US649249           Oscar Moreno        27/11/2023          Modify setup method
 
***********************************************************************************************************************/
@isTest
public with sharing class AV_ListViewComponentController_Test {
   
    static final String CON_VENTA = 'Con venta';
    static final String VIGENTE = 'Vigentes';
    static final String HISTORICO = 'Historico';
    static final String ALL = 'All';
   
    /**
* Create Contact without an associated Supervisor.
*/
    @TestSetup
    static void setup() {
        AV_TestHelper.activateLogger();
       
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
 
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;
       
       
        System.runAs(userGcf){
           
            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            userGestor.Email = 'gestor-test@test.com';
            User usrTest = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01543678');
            List<User> listUserInsert = new List<User>();
            listUserInsert.add(userGestor);
            listUserInsert.add(usrTest);
            insert listUserInsert;
            AV_TestHelper.insertNeededPermissions(userGestor);  
           
            Account accountCenter = AV_TestHelper.createCaixaCenterSinInsert();
            Account accountClient = AV_TestHelper.createCustomerSinInsert();
            insert new List<Account>{accountCenter, accountClient};
 
            Contact contactGestor = AV_TestHelper.createEmployee(accountCenter,userGestor);
 
            Opportunity oppTest = AV_TestHelper.createOpportunityWithEmpleadoSinInsert(accountCenter, contactGestor);
            oppTest.AV_ExternalId__c = '12345';
            oppTest.OwnerId = userGestor.id;
            oppTest.AccountId = accountClient.Id;
            insert oppTest;
           
           
         
       
           AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();
       
           AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperienceSinInsert();
           prodExp.OwnerId = userGestor.id;
           prodExp.AV_Activo__c = true;
           prodExp.AV_ProductoFicha__c = oppTest.AV_PF__c;
           prodExp.AV_ExperienciaNegocio__c = exp.Id;
           insert prodExp;
       
       
       
            AV_ProductClient__c prodCliente = AV_TestHelper.createPFClienteSinInsert();
            prodCliente.OwnerId = userGestor.id;
            prodCliente.AV_ProductoFicha__c = prodExp.Id;
            prodCliente.AV_Cliente__c =  accountClient.Id;
            prodCliente.AV_TieneOportunidad__c = 'OPORT';
            prodCliente.AV_TenenciaProducto__c = '1';
            prodCliente.AV_Potencialidad__c = 'N';
            insert prodCliente;
 
            AV_ProductClient__c prodCliente2 = AV_TestHelper.createPFClienteSinInsert();
            prodCliente2.OwnerId = userGestor.id;
            prodCliente2.AV_ProductoFicha__c = prodCliente.AV_ProductoFicha__c;
            insert prodCliente2;
 
            AV_ProductClient__c prodCliente3 = AV_TestHelper.createPFClienteSinInsert();
            prodCliente3.OwnerId = userGestor.id;
            prodCliente3.AV_ProductoFicha__c = prodCliente2.AV_ProductoFicha__c;
            insert prodCliente3;        
        }
    }
   
    @isTest
    public static void testGetInitDataTask() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' AND IsActive = true];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '12345'];
       
       
        Test.startTest();  
         
        System.runAs(userGestor){
 
            Task tarea  = AV_TestHelper.createTarea(null);
            String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
            AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidad(opp, idCabeceraTarea);
           
            AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
            response = AV_ListViewComponentController.getInitData(tarea.Id, VIGENTE);
           
            String listRowData = 'listRowData';
            AV_ListViewComponentController.RowData[] setModel = response.listRowData;
            System.assertEquals(1, setModel.size());
        }
       
        Test.stopTest();
    }
   
    @isTest
    public static void testGetInitDataEvent() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' AND IsActive = true];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '12345'];
        Account acc = [Select id FROM Account WHERE recordType.DeveloperName = 'CC_ClientePA'];
        DateTime activityDate = Datetime.newInstance(2020, 5, 4);
       
       
       Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
       Test.startTest();
       
       System.runAs(userGestor){
       Event event = AV_TestHelper.createEventExternalIdSinInsert(null,activityDate,'',acc);
       insert event;
 
       String idCabeceraTarea = [SELECT AV_Task__c FROM Event WHERE Id =:event.Id LIMIT 1].AV_Task__c;
       
       AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidad(opp, idCabeceraTarea);
           
            AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
            response = AV_ListViewComponentController.getInitData(event.Id, VIGENTE);
           
           
            String listRowData = 'listRowData';
            AV_ListViewComponentController.RowData[] setModel = response.listRowData;
            System.assertEquals(1, setModel.size());
        }
       
        Test.stopTest();
 
 
       
    }
   
    @isTest
    public static void testGetInitDataPFClienteOppVigentes() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' AND IsActive = true];
        Account acc = [Select id FROM Account WHERE recordType.DeveloperName = 'CC_ClientePA'];
        Test.startTest();
        Opportunity opp = [SELECT Id, AV_PF__c FROM Opportunity WHERE AV_ExternalId__c = '12345'];
       
        AV_ProductClient__c prodCliente = [SELECT Id FROM AV_ProductClient__c WHERE AV_Potencialidad__c = 'N'];
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_TieneOportunidad__c = 'OPORT';
        prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
        update prodCliente;
 
        String message;
       
        System.runAs(userGestor){
           
            AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
            try {
                response = AV_ListViewComponentController.getInitData(prodCliente.Id, VIGENTE);
               
            } catch (Exception e) {
                message = e.getMessage();
            }
            System.assert(message != 'ID has no value' , 'ID is empty');
            String listRowData = 'listRowData';
            AV_ListViewComponentController.RowData[] setModel = response.listRowData;
        }
        Test.stopTest();
       
    }
   
    @isTest
    public static void testGetInitDataPFClienteOppHistorico() {
       
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' AND IsActive = true];
        Opportunity opp = [SELECT Id, AV_PF__c FROM Opportunity WHERE AV_ExternalId__c = '12345'];
        Account acc = [Select id FROM Account WHERE recordType.DeveloperName = 'CC_ClientePA'];
       
        AV_ProductClient__c prodCliente = [SELECT Id FROM AV_ProductClient__c WHERE AV_Potencialidad__c = 'N'];
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_TieneOportunidad__c = 'OPORT';
        prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
        update prodCliente;
       
 
     
       
        Test.startTest();
        System.runAs(userGestor){
 
            SObjectAccessDecision securityDecision =
            Security.stripInaccessible(AccessType.READABLE,
                 [SELECT Id, IsDeleted, AccountId, RecordTypeId, Name, Description, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, SyncedQuoteId, HasOpenActivity, HasOverdueTask, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, CSBD_Circuito_Contratacion_Online__c, Loss_Reason__c, CSBD_Contact__c, CSBD_Diferencial_Limite__c, CSBD_Email_Solicitud__c, CSBD_Empresa_Proveedora_Logo__c, CSBD_Empresa_Proveedora__c, CSBD_Estado_Tracking__c, CSBD_Estado__c, CSBD_Id_Aux__c, CSBD_Identificador__c, CSBD_Idioma_Solicitud__c, CSBD_Importe_Producto_Principal__c, CSBD_Limite_Compra_Estrella__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c, CSBD_Motivo_Pendiente_Interno__c, CSBD_Now_Boton__c, CSBD_Now_Codigo_Producto_Formato__c, CSBD_IWD_PendienteCita__c, CSBD_Now_Canal_Peticion__c, CSBD_Now_NIF_Mascara__c, CSBD_Now_Id_Producto__c, CSBD_Skill__c, AV_ProductName__c, CSBD_Plantilla_Correo__c, CSBD_Prioridad_Tracking__c, CSBD_Propietario_Aux__c, CSBD_Referencia_Correo_Saliente__c, CSBD_Resolucion__c, CSBD_Scoring_Riesgo__c, CSBD_Subestado_Tracking__c, CSBD_Telefono_Solicitud__c, CSBD_Titulo__c, AV_EmployeeCustomer__c, CSBD_Codigo_Estado_Tracking__c, AV_ALVEN__c, AV_FechaActivacion__c, AV_FechaFinAccionComercial__c, AV_FechaInicioVigencia__c, AV_PrioritzingSort__c, CSBD_Now_Apellido1__c, CSBD_Now_Apellido2__c, CSBD_Now_Apellidos1_1Tit__c, CSBD_Now_Apellidos1_2Tit__c, CSBD_Now_Apellidos2_1Tit__c, CSBD_Now_Apellidos2_2Tit__c, AV_CenterIndex__c, CSBD_Now_Canal__c, CSBD_Now_CodProducto__c, CSBD_Now_Cod_Retorn__c, AV_AnalyticsStage__c, CSBD_Now_CodiFormaExercir2Tit__c, CIBE_ImporteOtraEntidad__c, CSBD_Now_DescripMotivo__c, CSBD_Now_Descripcion__c, CSBD_Now_DirVivienda__c, CSBD_Now_EmailGestor__c, CSBD_Now_EmailOficinaLO__c, CSBD_Now_EstatCivil2Tit__c, CSBD_Now_Finalidad__c, CSBD_Now_Hora__c, CSBD_Now_Horario2Tit__c, CSBD_Now_Id_Tarjeta__c, CSBD_Now_Importe__c, CSBD_Now_Missatge__c, CSBD_Now_NIF1Tit__c, CSBD_Now_NIF2Tit__c, CSBD_Now_NIFSolicitante__c, CSBD_Now_NIF__c, CSBD_Now_NUMPERSO__c, CSBD_Now_Nacionalidad2Tit__c, CSBD_Now_Nombre1Tit__c, CSBD_Now_Nombre2Tit__c, CSBD_Now_NombreCompleto__c, CSBD_Now_NombreProducto__c, CSBD_Now_NombreSolicitante__c, CSBD_Now_Nombre__c, CSBD_Now_Nomina2Tit__c, CSBD_Now_Num_Oficina__c, CSBD_Now_Numsolicitud__c, CSBD_Now_Origen__c, CSBD_Now_Pais_Residencia2Tit__c, CSBD_Now_Plazo__c, CSBD_Now_Pobl2Tit__c, CSBD_Now_PoblVivienda__c, CSBD_Now_Presolicitud__c, CSBD_Now_Resultado__c, CSBD_Now_SeguroHogar__c, CSBD_Now_Subproducto_1__c, CSBD_Now_TipoObra__c, CSBD_Now_ValorVivienda__c, CSBD_Now_Vehiculo__c, CSBD_Ultima_Etapa_Ventas__c, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Contact_Escala_Maestra__c, CSBD_Contact_Heavy_Digital__c, CSBD_Dif_Importe_Preconcedido_Imagen__c, CSBD_Dif_Importe_Preconcedido_Label__c, CSBD_Dif_Importe_Preconcedido__c, CSBD_PushTopic_Estado__c, CSBD_PushTopic_InteractionId__c, CSBD_PushTopic_ProxyClientId__c, CSBD_PushTopic_TicketId__c, CSBD_RecordType_DeveloperName__c, FinServ__FinancialAccount__c, FinServ__Household__c, FinServ__ReferredByContact__c, FinServ__ReferredByUser__c, AV_Aviso__c, AV_CentroOrigen__c, AV_Comentarios__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_Cuota__c, AV_EmpleadoAlta__c, AV_EmpleadoModificacion__c, AV_Entidad__c, AV_ExternalID__c, AV_Familia__c, AV_FechaAlta__c, AV_FechaAviso__c, AV_FechaModificacion__c, AV_FechaPlanificacion__c, AV_FechaProximoRecordatorio__c, AV_FechaVencimiento__c, AV_Gestor__c, AV_NoOfrecerHasta__c, AV_NumeroDias__c, AV_OfrecerHasta__c, AV_Online__c, AV_PEA__c, AV_PF__c, AV_Potencial__c, AV_Producto__c, AV_Tenencia__c, AV_TipoInteres__c, AV_ToDelete__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_ClienteConfidencial__c, AV_AreaDelContrato__c, AV_Contrato__c, AV_EstadoOportunidad__c, AV_ModificacionTelefonica__c, AV_Operacion__c, AV_OrigenApp__c, AV_PFExperiencia__c, AV_ProductoMifid__c, AV_ProductoSSCC__c, AV_SemanaAlta__c, AV_VisibleByLoggedUser__c, AV_VisibleByOfficeUser__c, AV_Origen__c, AV_ApiGCF_DateSend__c, AV_ApiGCF_ResponseBody__c, AV_ApiGCF_ResponseStatusCode__c, CBK_ForbiddenWords__c, AV_BatchProcessChangeStatus__c, AV_assignContact__c, AV_Center__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c, AV_ClientProduct__c, AV_Product__c, AV_IncludeInPrioritizingCustomers__c, AV_LicensePlate__c, AV_OficinaPrincipalRelacionas__c, CSBD_Canal__c, CSBD_Con_Duplicados__c, CSBD_Dejar_Pendiente_Cliente__c, CSBD_Dispone_Importe_Preconcedido__c, CSBD_Familia_Producto__c, CSBD_Fecha_Cita__c, CSBD_Finalidad__c, CSBD_Horario_Contacto_IWD__c, CSBD_Horario_Contacto__c, CSBD_Hoy__c, CSBD_IWD_DiferencialLimiteOficina__c, CSBD_IWD_Fecha_Actualizacion__c, CSBD_IWD_InteractionId__c, CSBD_IWD_MediaType__c, CSBD_IWD_Operacion__c, CSBD_IWD_TramoHorarioContacto__c, CSBD_IWD_TurnoContacto__c, CSBD_IWD__c, CSBD_Importe_Disponible_Contacto__c, CSBD_Now_Campanya__c, CSBD_Now_Codigo_Producto__c, CSBD_Now_Contrato__c, CSBD_Now_DiaPeticion__c, CSBD_Now_FechaContratacion__c, CSBD_Now_USUCLO__c, CSBD_OficinaLO__c, CSBD_Parent_Id__c, CSBD_Producto__c, CSBD_Programar_Propietario_Id__c, CSBD_Reactivada_Respuesta_Recibida__c, CSBD_Resolucion_QuickAction_Cerrar__c, CSBD_Resumen__c, CSBD_StageName_QuickAction_Cerrar__c, CSBD_Turno_Contacto__c, CSBD_Vehiculo_Renting__c, AV_PriorityOpportunity__c, AV_Resolucion__c, AV_AmountSales__c, AV_AssignedManagerSales__c, AV_CancellationDateSales__c, AV_ChannelSales__c, AV_ImportDisponiblePrestamosOficinas__c, AV_MarginSales__c, AV_ProductSales__c, AV_SalesCenter__c, AV_SalesDate__c, CSBD_Detalle_producto__c, CIBE_Numero_de_Simulador__c, CIBE_Tipo_de_simulacion__c, AV_PEA2__c, AV_Company__c, AV_Channel__c, AV_MarginEuro__c, AV_ByProduct__c, CIBE_Familia__c, AV_AmountEuro__c, AV_DueDateTask__c, AV_Propensity__c,
                        RecordType.Name, RecordType.DeveloperName, AV_PF__r.Name
                        FROM Opportunity ORDER BY LastModifiedDate DESC LIMIT 1]
                 );
 
            // Get the removed field names - these are the fields they don't have read access to.
            System.debug('Debug CustomAcivity' +securityDecision.getRemovedFields().get('AV_CustomActivityOpportunity__c')); // put sobject here
            System.debug('Debug Oportunity'+securityDecision.getRemovedFields().get('Opportunity')); // put sobject here
           
            AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
            response = AV_ListViewComponentController.getInitData(prodCliente.Id, HISTORICO);
           
           
            String listRowData = 'listRowData';
            AV_ListViewComponentController.RowData[] setModel = response.listRowData;
            System.assertEquals(1, setModel.size());
        }
        Test.stopTest();
    }
   
    @isTest
    public static void testGetInitDataPFClienteOppAll() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' AND IsActive = true];
       
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        AV_ListViewComponentController.RowData[] setModel;
        //AV_ProductClient__c prodCliente = new AV_ProductClient__c();
        AV_ProductClient__c prodCliente = [SELECT Id FROM AV_ProductClient__c WHERE AV_Potencialidad__c = 'N'];
        AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
        Opportunity opp = [SELECT Id, AV_PF__c FROM Opportunity WHERE AV_ExternalId__c = '12345'];
       
        Account acc = [Select id FROM Account WHERE recordType.DeveloperName = 'CC_ClientePA'];
               
        System.runAs(userGcf){
           
            PermissionSetGroup psg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = 'AV_Gestor' LIMIT 1];
            Map<String, PermissionSetAssignment> mapPs = new Map<String, PermissionSetAssignment>();
            List<PermissionSetAssignment> listAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroupId =:psg.Id AND AssigneeId=:userGestor.Id];
            for (PermissionSetAssignment ass: listAssignment) {
                mapPs.put(ass.AssigneeId, ass);
            }
            if(psg.Status != 'Updated'){
                Test.calculatePermissionSetGroup(psg.Id);
            }
            if(!mapPs.containsKey(userGestor.id)) {
                insert new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId = userGestor.Id);    
            }
           
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'Standard Price Book';
            insert pb;
           
           
            opp.CloseDate = System.today() +2;
            update opp;
           
        }        
           
                   
        Test.startTest();
        System.runAs(userGestor){ 

            AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
            response = AV_ListViewComponentController.getInitData(prodCliente.Id, opp.AV_PF__c);
            String listRowData = 'listRowData';
            setModel = response.listRowData;
           
        }
        Test.stopTest();
        System.assertEquals(1, setModel.size());
    }
   
    @isTest
    public static void testgetInitData() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' AND IsActive = true];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '12345'];
        Account acc = [Select id FROM Account WHERE recordType.DeveloperName = 'CC_ClientePA'];
       
        Test.startTest();      
        System.runAs(userGestor){
 
            Task tarea  = AV_TestHelper.createTarea(null);
            String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
            AV_CustomActivityOpportunity__c tareaOpp= AV_TestHelper.createTareaOportunidad(opp, idCabeceraTarea);
           
            AV_ListViewComponentController.Response response = new AV_ListViewComponentController.Response();
            response = AV_ListViewComponentController.getInitData(tarea.Id, VIGENTE);
           
           
            String listRowData = 'listRowData';
            AV_ListViewComponentController.RowData[] setModel = response.listRowData;
            System.assertEquals(1, setModel.size());
        }
       
        Test.stopTest();
    }
   
    @isTest
    public static void testgetInitDataMapProducts() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' AND IsActive = true];
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book'];
        Account acc = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T'];
        Opportunity opp = [SELECT Id, AV_PF__c FROM Opportunity WHERE AV_ExternalId__c = '12345'];
        Boolean check = false;
        Test.startTest();
        System.runAs(userGestor){  
            AV_ListViewComponentController.Response response = AV_ListViewComponentController.getInitDataMapProducts(acc.Id, opp.Id);
            System.assertNotEquals(response,null);
 
        }
        Test.stopTest();
       
       
    }
   
   
   
   
}