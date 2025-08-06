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

public with sharing class CC_Script_Pruebas_Auto_Helper
{
    public static void insercionMCC()
    {
        // Lista para añadir
        List<CC_MCC__c> lstInsertTematica = new List<CC_MCC__c>();
        List<CC_MCC__c> lstInsertProducto = new List<CC_MCC__c>();
        List<CC_MCC__c> lstInsertMotivo = new List<CC_MCC__c>();
        List<CC_MCC__c> lstInsertCausa = new List<CC_MCC__c>();
        List<CC_MCC__c> lstInsertSolucion = new List<CC_MCC__c>();

        // TEMATICA
        CC_MCC__c tematica, tematica1, tematica2, tematica3, tematica4, tematica5, tematica6, tematica7;

        List<CC_MCC__c> listaComprobacionTematica = [SELECT Id FROM CC_MCC__c WHERE Name = 'Accionistas CBK' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica.isEmpty())
        {
            tematica = new CC_MCC__c();
                tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica.Name = 'Accionistas CBK';
                tematica.CC_Tipo_Cliente__c = 'Cliente';
                tematica.CC_Codigo_Externo__c = 'TE00-00';
                tematica.CC_Canal_Operativo__c = 'App Imagin';
            lstInsertTematica.add(tematica);
        }

        List<CC_MCC__c> listaComprobacionTematica1 = [SELECT Id FROM CC_MCC__c WHERE Name = 'US89305_004' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica1.isEmpty())
        {
            tematica1 = new CC_MCC__c();
                tematica1.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica1.Name = 'US89305_004';
                tematica1.CC_Tipo_Cliente__c = 'Cliente';
                tematica1.CC_Codigo_Externo__c = 'TE00-01';
                tematica1.CC_Canal_Operativo__c = 'App BrokerNow';
            lstInsertTematica.add(tematica1);
        }

        List<CC_MCC__c> listaComprobacionTematica2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Alfabético' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica2.isEmpty())
        {
            tematica2 = new CC_MCC__c();
                tematica2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica2.Name = 'Alfabético';
                tematica2.CC_Tipo_Cliente__c = 'Cliente';
                tematica2.CC_Codigo_Externo__c = 'TE00-12';
                tematica2.CC_Canal_Operativo__c = 'App CaixaBankSign';
            lstInsertTematica.add(tematica2);
        }

        List<CC_MCC__c> listaComprobacionTematica3 = [SELECT Id FROM CC_MCC__c WHERE Name = 'US89305_001' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica3.isEmpty())
        {
            tematica3 = new CC_MCC__c();
                tematica3.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica3.Name = 'US89305_001';
                tematica3.CC_Tipo_Cliente__c = 'Cliente';
                tematica3.CC_Codigo_Externo__c = 'TE00-03';
                tematica3.CC_Canal_Operativo__c = 'App BrokerNow';
            lstInsertTematica.add(tematica3);
        }

        List<CC_MCC__c> listaComprobacionTematica4 = [SELECT Id FROM CC_MCC__c WHERE Name = 'US89305_002' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica4.isEmpty())
        {
            tematica4 = new CC_MCC__c();
                tematica4.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica4.Name = 'US89305_002';
                tematica4.CC_Tipo_Cliente__c = 'Cliente';
                tematica4.CC_Codigo_Externo__c = 'TE00-04';
                tematica4.CC_Canal_Operativo__c = 'App BrokerNow';
            lstInsertTematica.add(tematica4);
        }

        List<CC_MCC__c> listaComprobacionTematica5 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tarjetas' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica5.isEmpty())
        {
            tematica5 = new CC_MCC__c();
                tematica5.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica5.Name = 'Tarjetas';
                tematica5.CC_Tipo_Cliente__c = 'Cliente';
                tematica5.CC_Codigo_Externo__c = 'TE00-05';
                tematica5.CC_Canal_Operativo__c = 'Sin canal';
            lstInsertTematica.add(tematica5);
        }

        List<CC_MCC__c> listaComprobacionTematica6 = [SELECT Id FROM CC_MCC__c WHERE Name = 'US89305_005' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica6.isEmpty())
        {
            tematica6 = new CC_MCC__c();
                tematica6.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica6.Name = 'US89305_005';
                tematica6.CC_Tipo_Cliente__c = 'Cliente';
                tematica6.CC_Codigo_Externo__c = 'TE00-06';
                tematica6.CC_Canal_Operativo__c = 'App BrokerNow';
            lstInsertTematica.add(tematica6);
        }

        List<CC_MCC__c> listaComprobacionTematica7 = [SELECT Id FROM CC_MCC__c WHERE Name = 'US89305_003' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE];
        if(listaComprobacionTematica7.isEmpty())
        {
            tematica7 = new CC_MCC__c();
                tematica7.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
                tematica7.Name = 'US89305_003';
                tematica7.CC_Tipo_Cliente__c = 'Cliente';
                tematica7.CC_Codigo_Externo__c = 'TE00-07';
                tematica7.CC_Canal_Operativo__c = 'App BrokerNow';
            lstInsertTematica.add(tematica7);
        }

        if (!lstInsertTematica.isEmpty()){
            insert lstInsertTematica;
        }
        
        // PRODUCTO
        CC_MCC__c producto, producto1, producto2, producto3;
        List<CC_MCC__c> listaComprobacionProducto = [SELECT Id FROM CC_MCC__c WHERE Name = 'Configuración personal' AND RecordType.Developername = 'CC_Producto_Servicio' AND CC_Activo__c = TRUE AND CC_Tematica__r.Name = 'Alfabético'];
        if(listaComprobacionProducto.isEmpty())
        {
            producto = new CC_MCC__c();
                producto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                producto.Name = 'Configuración personal';
                producto.CC_Tipo_Cliente__c = 'Cliente';
                producto.CC_Codigo_Externo__c = 'PR00-04';
            if(tematica2 != null)
           		{producto.CC_Tematica__c = tematica2.Id;
                } 
            else
            {
                producto.CC_Tematica__c = listaComprobacionTematica2[0].Id;
            }
                
            lstInsertProducto.add(producto);
        }

        List<CC_MCC__c> listaComprobacionProducto1 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Dividendos' AND RecordType.Developername = 'CC_Producto_Servicio' AND CC_Activo__c = TRUE AND CC_Tematica__r.Name = 'Accionistas CBK'];
        if(listaComprobacionProducto1.isEmpty())
        {
            producto1 = new CC_MCC__c();
                producto1.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                producto1.Name = 'Dividendos';
                producto1.CC_Tipo_Cliente__c = 'Cliente';
                producto1.CC_Codigo_Externo__c = 'PR00-12';
                if(tematica != null)
           			{producto1.CC_Tematica__c = tematica.Id;
                	}
           		else
            		{
                	producto1.CC_Tematica__c = listaComprobacionTematica[0].Id;
            		}
               
            lstInsertProducto.add(producto1);
        }

        List<CC_MCC__c> listaComprobacionProducto2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'MyCard' AND RecordType.Developername = 'CC_Producto_Servicio' AND CC_Activo__c = TRUE AND CC_Tematica__r.Name = 'Tarjetas'];
        if(listaComprobacionProducto2.isEmpty())
        {
            producto2 = new CC_MCC__c();
                producto2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                producto2.Name = 'MyCard';
                producto2.CC_Tipo_Cliente__c = 'Cliente';
                producto2.CC_Codigo_Externo__c = 'PR00-130';
                if(tematica5 != null)
           			{producto2.CC_Tematica__c = tematica5.Id;
                	}
           		else
            		{
                	producto2.CC_Tematica__c = listaComprobacionTematica5[0].Id;
            		}
            lstInsertProducto.add(producto2);
        }


        List<CC_MCC__c> listaComprobacionProducto3 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tarjeta de débito' AND RecordType.Developername = 'CC_Producto_Servicio' AND CC_Activo__c = TRUE AND CC_Tematica__r.Name = 'Tarjetas'];
        if(listaComprobacionProducto3.isEmpty())
        {
            producto3 = new CC_MCC__c();
                producto3.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                producto3.Name = 'Tarjeta de débito';
                producto3.CC_Tipo_Cliente__c = 'Cliente';
                producto3.CC_Codigo_Externo__c = 'PR00-14';
                if(tematica5 != null)
           			{producto3.CC_Tematica__c = tematica5.Id;
                	}
           		else
            		{
                	producto3.CC_Tematica__c = listaComprobacionTematica5[0].Id;
            		}
            lstInsertProducto.add(producto3);
        }

        if (!lstInsertProducto.isEmpty()){
            insert lstInsertProducto;
        }

        // MOTIVO
        CC_MCC__c motivo, motivo1, motivo2, motivo3, motivo4;
        List<CC_MCC__c> listaComprobacionMotivo = [SELECT Id FROM CC_MCC__c WHERE Name = 'Activación servicio/ producto' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'MyCard'];
        if(listaComprobacionMotivo.isEmpty())
        {
            motivo = new CC_MCC__c();
                motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                motivo.Name = 'Activación servicio/ producto';
                motivo.CC_Tipo_Cliente__c = 'Cliente';
                motivo.CC_Codigo_Externo__c = 'MO00-10';
                if(producto2 != null)
           			{motivo.CC_Producto_Servicio__c = producto2.Id;
                	}
           		else
            		{
                	motivo.CC_Producto_Servicio__c = listaComprobacionProducto2[0].Id;
            		}
            lstInsertMotivo.add(motivo);
        }

        List<CC_MCC__c> listaComprobacionMotivo1 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Alta/contratación de servicio/producto' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'MyCard'];
        if(listaComprobacionMotivo.isEmpty())
        {
            motivo1 = new CC_MCC__c();
                motivo1.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                motivo1.Name = 'Alta/contratación de servicio/producto';
                motivo1.CC_Tipo_Cliente__c = 'Cliente';
                motivo1.CC_Codigo_Externo__c = 'MO00-011';
                if(producto2 != null)
           			{motivo1.CC_Producto_Servicio__c = producto2.Id;
                	}
           		else
            		{
                	motivo1.CC_Producto_Servicio__c = listaComprobacionProducto2[0].Id;
            		}
            lstInsertMotivo.add(motivo1);
        }

        List<CC_MCC__c> listaComprobacionMotivo2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Información sobre Calendario' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'Dividendos'];
        if(listaComprobacionMotivo.isEmpty())
        {
            motivo2 = new CC_MCC__c();
                motivo2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                motivo2.Name = 'Información sobre Calendario';
                motivo2.CC_Tipo_Cliente__c = 'Cliente';
                motivo2.CC_Codigo_Externo__c = 'MO00-12';
                if(producto1 != null)
           			{motivo2.CC_Producto_Servicio__c = producto1.Id;
                	}
           		else
            		{
                	motivo2.CC_Producto_Servicio__c = listaComprobacionProducto1[0].Id;
            		}
            lstInsertMotivo.add(motivo2);
        }

        List<CC_MCC__c> listaComprobacionMotivo3 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Robo móvil' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'Configuración personal'];
        if(listaComprobacionMotivo.isEmpty())
        {
            motivo3 = new CC_MCC__c();
                motivo3.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                motivo3.Name = 'Robo móvil';
                motivo3.CC_Tipo_Cliente__c = 'Cliente';
                motivo3.CC_Codigo_Externo__c = 'MO00-13';
                if(producto != null)
           			{motivo3.CC_Producto_Servicio__c = producto.Id;
                	}
           		else
            		{
                	motivo3.CC_Producto_Servicio__c = listaComprobacionProducto[0].Id;
            		}
            lstInsertMotivo.add(motivo3);
        }


        List<CC_MCC__c> listaComprobacionMotivo4 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Alta/contratación de servicio/producto' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'Tarjeta de débito'];
        if(listaComprobacionMotivo.isEmpty())
        {
            motivo4 = new CC_MCC__c();
                motivo4.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                motivo4.Name = 'Alta/contratación de servicio/producto';
                motivo4.CC_Tipo_Cliente__c = 'Cliente';
                motivo4.CC_Codigo_Externo__c = 'MO00-14';
                if(producto3 != null)
           			{motivo4.CC_Producto_Servicio__c = producto3.Id;
                	}
           		else
            		{
                	motivo4.CC_Producto_Servicio__c = listaComprobacionProducto3[0].Id;
            		}
            lstInsertMotivo.add(motivo4);
        }

        if (!lstInsertMotivo.isEmpty()){
            insert lstInsertMotivo;
        }

        // CAUSA
        CC_MCC__c causa, causa1, causa2;
        List<CC_MCC__c> listaComprobacionCausa = [SELECT Id FROM CC_MCC__c WHERE Name = 'Desconoce información/operativa' AND RecordType.Developername = 'CC_Causa' AND CC_Activo__c = TRUE AND CC_Motivo__r.Name = 'Alta/contratación de servicio/producto'];
        if(listaComprobacionCausa.isEmpty())
        {
            causa = new CC_MCC__c();
                causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
                causa.Name = 'Desconoce información/operativa';
                causa.CC_Tipo_Cliente__c = 'Cliente';
                causa.CC_Codigo_Externo__c = 'CA00-01';
                if(motivo1 != null)
           			{causa.CC_Motivo__c = motivo1.Id;
                	}
           		else
            		{
                	causa.CC_Motivo__c = listaComprobacionMotivo1[0].Id;
            		}
            lstInsertCausa.add(causa);
        }

        List<CC_MCC__c> listaComprobacionCausa1 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Error en alfabético' AND RecordType.Developername = 'CC_Causa' AND CC_Activo__c = TRUE AND CC_Motivo__r.Name = 'Activación servicio/ producto'];
        if(listaComprobacionCausa.isEmpty())
        {
            causa1 = new CC_MCC__c();
                causa1.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
                causa1.Name = 'Error en alfabético';
                causa1.CC_Tipo_Cliente__c = 'Cliente';
                causa1.CC_Codigo_Externo__c = 'CA00-02';
                if(motivo != null)
           			{causa1.CC_Motivo__c = motivo.Id;
                	}
           		else
            		{
                	causa1.CC_Motivo__c = listaComprobacionMotivo[0].Id;
            		}
            lstInsertCausa.add(causa1);
        }

        List<CC_MCC__c> listaComprobacionCausa2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Robo' AND RecordType.Developername = 'CC_Causa' AND CC_Activo__c = TRUE AND CC_Motivo__r.Name = 'Robo móvil'];
        if(listaComprobacionCausa.isEmpty())
        {
            causa2 = new CC_MCC__c();
                causa2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
                causa2.Name = 'Robo';
                causa2.CC_Tipo_Cliente__c = 'Cliente';
                causa2.CC_Codigo_Externo__c = 'CA00-03';
                if(motivo3 != null)
           			{causa2.CC_Motivo__c = motivo3.Id;
                	}
           		else
            		{
                	causa2.CC_Motivo__c = listaComprobacionMotivo3[0].Id;
            		}
            lstInsertCausa.add(causa2);
        }

        if (!lstInsertCausa.isEmpty()){
            insert lstInsertCausa;
        }

        List <CC_MCC__c> listaComprobacionSolucion = [SELECT Id FROM CC_MCC__c WHERE Name = 'Desconoce información/operativa' AND RecordType.Developername = 'CC_Solucion' AND CC_Activo__c = TRUE AND CC_Causa__r.Name = 'Desconoce información/operativa'];
        if(listaComprobacionSolucion.isEmpty())
        {
            CC_MCC__c solucion = new CC_MCC__c();
                solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
                solucion.Name = 'Desconoce información/operativa';
                solucion.CC_Tipo_Cliente__c = 'Cliente';
                solucion.CC_Codigo_Externo__c = 'SO00-03';
                if(causa != null)
           			{solucion.CC_Causa__c = causa.Id;
                	}
           		else
            		{
                	solucion.CC_Causa__c = listaComprobacionCausa[0].Id;
            		}
            lstInsertSolucion.add(solucion);
        }

        if (!lstInsertSolucion.isEmpty()){
            insert lstInsertSolucion;
        }
    }

    public static void insercionCuentas()
    {
        // Lista comprobaciones Account
        List<Account> listaComprobacionCuenta, listaComprobacionClienteParticular;
        Account cuentaCliente = new Account();
        Account cuentaClientePA = new Account();

        // Lista comprobaciones Contact
        List<Contact> listaComprobacionContacto;
        Contact contacto = new Contact();

        // CLIENTE PARTICULAR
        listaComprobacionClienteParticular = [SELECT Id FROM Account WHERE LastName = 'Prueba Creacion' AND RecordType.Developername = 'CC_ClientePA' AND CC_Inactivo__c = FALSE];
        if(listaComprobacionClienteParticular.isEmpty())
        {
            cuentaClientePA.LastName = 'Prueba Creacion';
            cuentaClientePA.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
            insert cuentaClientePA;
        }

        listaComprobacionCuenta = [SELECT Id FROM Account WHERE CC_NumPerso__c = 'CCTestRegre1' AND RecordType.Developername = 'CC_Cliente' AND CC_Inactivo__c = FALSE];
        if(listaComprobacionCuenta.isEmpty())
        {
            cuentaCliente.Name = 'RAQUEL COSTA AGUILAR';
            cuentaCliente.CC_Numero_Documento__c = '74288741Y';
            cuentaCliente.CC_NumPerso__c = 'CCTestRegre1';
            cuentaCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            insert cuentaCliente;
        }

        // CONTACT
        listaComprobacionContacto = [SELECT Id FROM Contact WHERE FirstName = '999999999' and LastName= 'Prueba' AND RecordType.Developername = 'CC_Cliente' AND CC_Inactivo__c = FALSE];
        if(listaComprobacionContacto.isEmpty())
        {
            contacto.FirstName = '999999999';
            contacto.LastName = 'Prueba';
            contacto.CC_NumPerso__c = '25345561';
            contacto.AccountId = cuentaCliente.Id;
            contacto.CC_Idioma__c = 'Es';
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            insert contacto;
        }
    }

    // MARCA 
    public static void insercionMarca()
    {    
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        Datetime myDateNow = Datetime.valueOf(System.now());
        Datetime newDate = myDateNow.addHours(1);
        List<CC_Caracteristica__c> listaComprobacionMarca;
        List<CC_Caracteristica__c> listaInsertMarca = new List<CC_Caracteristica__c>();
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        CC_Caracteristica__c caracteristica1= new CC_Caracteristica__c();

        listaComprobacionMarca = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'ABIERTO POR TEMA LOGISTICO COVID' AND RecordType.DeveloperName = 'Marca' AND CC_Activo__c = TRUE];
        if(listaComprobacionMarca.isEmpty())
        {
            
            caracteristica.Name = 'ABIERTO POR TEMA LOGISTICO COVID';
            caracteristica.CC_Descripcion__c = 'ABIERTO POR TEMA LOGISTICO COVID';
            caracteristica.RecordTypeId = caracteristicaRecordTypeId;
            caracteristica.CC_Fecha_vigencia_inicio__c = myDateNow;
            caracteristica.CC_Fecha_vigencia_fin__c = newDate;
            caracteristica.OS_Negocio__c = 'CC';
            listaInsertMarca.add(caracteristica);
        }

        listaComprobacionMarca = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'US89305_004' AND RecordType.DeveloperName = 'Marca' AND CC_Activo__c  = TRUE];
        if(listaComprobacionMarca.isEmpty())
        {
           
            caracteristica1.Name = 'US89305_004';
            caracteristica1.CC_Descripcion__c = 'US89305_004';
            caracteristica1.RecordTypeId = caracteristicaRecordTypeId;
            caracteristica1.CC_Fecha_vigencia_inicio__c = myDateNow;
            caracteristica1.CC_Fecha_vigencia_fin__c = newDate;
            caracteristica1.OS_Negocio__c = 'CC';
            listaInsertMarca.add(caracteristica1);
        }
        insert listaInsertMarca;
    }

    // AGRUPADOR
    public static void insercionAgrupador()
    {
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Seguimiento').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'CC_GrupoMaximo' LIMIT 1];
        CC_Clasificacion_Maximo__c oClasif = [SELECT Id FROM CC_Clasificacion_Maximo__c LIMIT 1];
        CC_Caracteristica__c caracteristicaAgrupador = [SELECT Id FROM CC_Caracteristica__c LIMIT 1];

        List<CC_Agrupador__c> listaComprobacionAgrupador = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Agrupador prueba creacion incidencia' AND CC_Estado__c  = 'Activo'];
        if(listaComprobacionAgrupador.isEmpty())
        {
            agrupador.RecordTypeId = sRecordType;
            agrupador.CC_Titulo__c = 'Agrupador prueba creacion incidencia';
            agrupador.CC_Descripcion__c = 'Prueba creacion incidencia';
            agrupador.CC_GrupoMaximo__c = oGrupo.Id;
            agrupador.CC_Opcion_Call_Center__c = 'Opcion Call Center';
            agrupador.CC_Clasificacion_Maximo__c = oClasif.Id;
            agrupador.CC_Estado__c = 'Activo';
            agrupador.CC_Numero_Casos__c = 0;
            agrupador.CC_Campana__c = caracteristicaAgrupador.Id;
            insert agrupador;
        }
    }

    // GRUPO COLABORADOR
    public static void insercionGrupoColaborador()
    {    
        Id grupoRT = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        Id grupoRTCentroCB = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        List<CC_Grupo_Colaborador__c> listaComprobacionGrupoColaborador;
        List<CC_Grupo_Colaborador__c> listaInsertGrupoColaborador = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoCol, grupoCol1, grupoCol2, grupoCol3 = new CC_Grupo_Colaborador__c();
        Boolean grupoColaboradorCreado = false;
        CC_Grupo_Colaborador_Plantilla__c plantillaGrupo = new CC_Grupo_Colaborador_Plantilla__c();
        CC_Grupo_Colaborador_Plantilla__c plantillaGrupo1 = new CC_Grupo_Colaborador_Plantilla__c();
        List<CC_Grupo_Colaborador_Plantilla__c> listaInsertPlantilla = new List<CC_Grupo_Colaborador_Plantilla__c>();

        listaComprobacionGrupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Everis'];
        if(listaComprobacionGrupoColaborador.isEmpty())
        {
            grupoCol = new CC_Grupo_Colaborador__c();
                grupoCol.Name = 'Grupo Everis';
                grupoCol.RecordTypeId = grupoRT;
                listaInsertGrupoColaborador.add(grupoCol);
        }

        listaComprobacionGrupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'NombreGrupoPrueba'];
        if(listaComprobacionGrupoColaborador.isEmpty())
        {
            grupoCol1 = new CC_Grupo_Colaborador__c();
                grupoCol1.Name = 'NombreGrupoPrueba';
                grupoCol1.RecordTypeId = grupoRT;
                listaInsertGrupoColaborador.add(grupoCol1);
        }

        listaComprobacionGrupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = '09721 - MADRID AG. 82'];
        if(listaComprobacionGrupoColaborador.isEmpty())
        {
            grupoCol3 = new CC_Grupo_Colaborador__c();
                grupoCol3.Name = '09721 - MADRID AG. 82';
                grupoCol3.RecordTypeId = grupoRTCentroCB;
                listaInsertGrupoColaborador.add(grupoCol3);
                grupoColaboradorCreado = true;
        }

        listaComprobacionGrupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COLAB-003'];
        if(listaComprobacionGrupoColaborador.isEmpty())
        {
            grupoCol2 = new CC_Grupo_Colaborador__c();
                grupoCol2.Name = 'COLAB-003';
                grupoCol2.RecordTypeId = grupoRT;
                listaInsertGrupoColaborador.add(grupoCol2);
        }

        if(!listaInsertGrupoColaborador.isEmpty())
        {
            insert listaInsertGrupoColaborador;
        }
        
        if(grupoColaboradorCreado == true)
        {            
            plantillaGrupo.CC_Grupo_Colaborador__c = grupoCol3.Id;
            plantillaGrupo.CC_Plantilla_Name__c = 'Traslado Genérico Teléfono-Clientes';
            plantillaGrupo.CC_Plantilla_DeveloperName__c = 'Traslado_Generico_Telefono_Clientes';
            plantillaGrupo.CC_Operativa__c = 'Trasladar';
            listaInsertPlantilla.add(plantillaGrupo);

            plantillaGrupo1.CC_Grupo_Colaborador__c = grupoCol3.Id;
            plantillaGrupo1.CC_Plantilla_Name__c = 'Remitido Genérico Teléfono-Clientes';
            plantillaGrupo1.CC_Plantilla_DeveloperName__c = 'Remitido_Generico_Telefono_Clientes';
            plantillaGrupo1.CC_Operativa__c = 'Trasladar';
            listaInsertPlantilla.add(plantillaGrupo1);
        }

        if(!listaInsertPlantilla.isEmpty())
        {
            insert listaInsertPlantilla;
        }
    }


    // CASOS
    public static void insercionCasos()
    {
        CC_MCC__C tematica = [SELECT Id FROM CC_MCC__c WHERE Name = 'Accionistas CBK' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE LIMIT 1];
        CC_MCC__C tematica2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Alfabético' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE LIMIT 1];
        CC_MCC__C tematica5 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tarjetas' AND RecordType.Developername = 'CC_Tematica' AND CC_Activo__c = TRUE LIMIT 1];
        CC_MCC__C producto = [SELECT Id FROM CC_MCC__c WHERE Name = 'Configuración personal' AND RecordType.Developername = 'CC_Producto_Servicio' AND CC_Activo__c = TRUE AND CC_Tematica__r.Name = 'Alfabético' LIMIT 1];
        CC_MCC__C producto1 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Dividendos' AND RecordType.Developername = 'CC_Producto_Servicio' AND CC_Activo__c = TRUE AND CC_Tematica__r.Name = 'Accionistas CBK' LIMIT 1];
        CC_MCC__C producto2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'MyCard' AND RecordType.Developername = 'CC_Producto_Servicio' AND CC_Activo__c = TRUE AND CC_Tematica__r.Name = 'Tarjetas' LIMIT 1];
        CC_MCC__C motivo = [SELECT Id FROM CC_MCC__c WHERE Name = 'Activación servicio/ producto' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'MyCard' LIMIT 1];
        CC_MCC__C motivo1 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Alta/contratación de servicio/producto' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'MyCard' LIMIT 1];
        CC_MCC__C motivo2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Información sobre Calendario' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'Dividendos' LIMIT 1];
        CC_MCC__C motivo3 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Robo móvil' AND RecordType.Developername = 'CC_Motivo' AND CC_Activo__c = TRUE AND CC_Producto_Servicio__r.Name = 'Configuración personal' LIMIT 1];
        CC_MCC__C causa = [SELECT Id FROM CC_MCC__c WHERE Name = 'Desconoce información/operativa' AND RecordType.Developername = 'CC_Causa' AND CC_Activo__c = TRUE AND CC_Motivo__r.Name = 'Alta/contratación de servicio/producto' LIMIT 1];
        CC_MCC__C causa1 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Error en alfabético' AND RecordType.Developername = 'CC_Causa' AND CC_Activo__c = TRUE AND CC_Motivo__r.Name = 'Activación servicio/ producto' LIMIT 1];
        CC_MCC__C causa2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Robo' AND RecordType.Developername = 'CC_Causa' AND CC_Activo__c = TRUE AND CC_Motivo__r.Name = 'Robo móvil' LIMIT 1];
        CC_MCC__C solucion = [SELECT Id FROM CC_MCC__c WHERE Name = 'Desconoce información/operativa' AND RecordType.Developername = 'CC_Solucion' AND CC_Activo__c = TRUE AND CC_Causa__r.Name = 'Desconoce información/operativa' LIMIT 1];
        User usuario1 = [SELECT Id FROM User WHERE FirstName like 'U0190044 % ROBOT' AND LastName= 'GENERICO NTTDATA' AND IsActive = TRUE LIMIT 1];
        User usuario2 = [SELECT Id FROM User WHERE FirstName like 'U01A1526 % ROBOT' AND LastName= 'EVERIS SELENIUM' AND IsActive = TRUE LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE FirstName = '999999999' AND LastName = 'Prueba' AND RecordType.Developername = 'CC_Cliente' AND CC_Inactivo__c = FALSE LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE CC_NumPerso__c  = 'CCTestRegre1' LIMIT 1];
        Account cuentaPA = [SELECT Id FROM Account WHERE LastName = 'Prueba Creacion' LIMIT 1];
        CC_Agrupador__c agrupador = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Agrupador prueba creacion incidencia' LIMIT 1];
        
        List<Case> lstcasos = new List<Case>();
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso;
        caso = new Case();
            caso.Subject = 'Caso QA - GC-025- Autoasignarme & GC-028- Asociar a Caso - Procedencias permitidas';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-001-Caso no asignado';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-030- Cerrar caso & GC-029- Crear actividad manual';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App BrokerNow';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto1.Id;
            caso.CC_MCC_Motivo__c = motivo2.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            caso.CC_MCC_Solucion__c = solucion.Id;
            caso.ContactId = contacto.Id;
            caso.AccountId = cuenta.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c = 'es';
            caso.CC_Tipo_Contacto__c ='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-007-Clasificar caso - manualmente - Temática Tarjetas';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'Sin canal';
            caso.CC_MCC_Tematica__c = tematica5.Id;
            caso.CC_MCC_ProdServ__c = producto2.Id;
            caso.CC_MCC_Motivo__c = motivo.Id;
            caso.CC_MCC_Causa__c = causa1.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - US89273-002-Identificacion manual de clientes en Alfabetico';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.ContactId = contacto.Id;
            caso.AccountId = cuenta.Id; 
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - US89269-001-Alta manual de clientes';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.AccountId = cuentaPA.Id;
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - IN-003- Incidencias - Envío Máximo Error & IN-006- Incidencias - Marca Evento & IN-009- Incidencias - Pública';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Agrupador_Id__c = agrupador.Id;
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);

        
        caso = new Case();
            caso.Subject = 'Caso QA - GC-004-Clasificar caso-Buscador & GC-008-Clasificar caso-Buscador';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_MCC_Tematica__c = tematica5.Id;
            caso.CC_MCC_ProdServ__c = producto2.Id;
            caso.CC_MCC_Motivo__c = motivo1.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-009-Reclasificar Caso - Manualmente & GC-026- Marcas de un caso - Asignar & GC-027- Asociar a Caso - Procedencias no permitidas';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'Sin canal';
            caso.CC_MCC_Tematica__c = tematica5.Id;
            caso.CC_MCC_ProdServ__c = producto2.Id;
            caso.CC_MCC_Motivo__c = motivo.Id;
            caso.CC_MCC_Causa__c = causa1.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-005-Clasificar caso - manualmente & GC-006-Clasificar caso - Buscador - Temática Tarjetas';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App BrokerNow';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto1.Id;
            caso.CC_MCC_Motivo__c = motivo2.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);

        
        caso = new Case();
            caso.Subject = 'Caso QA - GC-002-Caso no clasificado';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - US89270-001- Edición de clientes creados manualmente & US89270-002- Edicion de clientes creados desde Alfabetico';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.AccountId = cuentaPA.Id;
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);

        
        caso = new Case();
            caso.Subject = 'Caso QA - IN-010- Incidencias - Asociar incidencia existente & IN-011- Incidencias - Desasociar incidencia existente & IN-012- Incidencias - Rechazar Máximo & IN-018- Incidencias - Cerrar Máximo';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Agrupador_Id__c = agrupador.Id;
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-033- Enviar encuestas & GC-034- Responder encuestas';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App BrokerNow';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto1.Id;
            caso.CC_MCC_Motivo__c = motivo2.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            caso.CC_MCC_Solucion__c = solucion.Id;
            caso.ContactId = contacto.Id;
            caso.AccountId = cuenta.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-023- Caso clasificado (Responder cliente) & GC-024- Caso clasificado (Responder cliente)';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - IN-001-Incidencias-Notificacion cierre & IN-002-Incidencias-Creacion';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-012- Caso clasificado (Respuesta del colaborador)';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-013- Caso clasificado (Remitir a Colaborador)';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);



        caso = new Case();
            caso.Subject = 'Caso QA - GC-020- Caso clasificado (Caso clasificado (Solicitar información)) & GC-021- Caso clasificado (Caso clasificado (Solicitar información))';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);



        caso = new Case();
            caso.Subject = 'Caso QA - GC-022- Caso clasificado (Respuesta del cliente a la solicitud de información)';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);



        caso = new Case();
            caso.Subject = 'Caso QA - GC-019- Caso clasificado (Caso clasificado (Solicitar información))';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-003-No activo';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
            caso.Status = 'Cerrado';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-014- Caso clasificado (Trasladar 3N) & GC-015-Caso clasificado (Devolver Nivel 1) & GC-016- Caso clasificado (Rechazar traslado) & GC-017- Caso clasificado (Devolver Nivel 1) & GC-018- Caso clasificado (Rechazar traslado)';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - GC-010-Caso clasificado (Trasladar a Colaborador) & GC-011- Trasladar a Colaborador - Cancelar traslado';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario1.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Operativo__c = 'App CaixaBankSign';
            caso.CC_MCC_Tematica__c = tematica2.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo3.Id;
            caso.CC_MCC_Causa__c = causa2.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Avería';
            caso.CC_Detalles_Consulta__c = 'Carga automatica caso';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);

        caso = new Case();
            caso.Subject = 'Caso QA - IN-004- Incidencias - Envío de nuevo a Máximo';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Microbank';
            caso.CC_Canal_Operativo__c = 'App BrokerNow';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto1.Id;
            caso.CC_MCC_Motivo__c = motivo2.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            caso.ContactId = contacto.Id;
            caso.AccountId = cuenta.Id;
            caso.CC_Agrupador_Id__c = agrupador.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Incidencia';
            caso.CC_Detalles_Consulta__c = 'Value';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);


        caso = new Case();
            caso.Subject = 'Caso QA - IN-005- Incidencias - Envío Máximo OK';
            caso.RecordTypeId = RecordTypeCliente;
            caso.OwnerId = usuario2.Id;
            caso.Origin= 'Email';
            caso.CC_Canal_Procedencia__c = 'Microbank';
            caso.CC_Canal_Operativo__c = 'App BrokerNow';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto1.Id;
            caso.CC_MCC_Motivo__c = motivo2.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            caso.ContactId = contacto.Id;
            caso.AccountId = cuenta.Id;
            caso.CC_Agrupador_Id__c = agrupador.Id;
            caso.CC_Tipo_Gestion__c = 'Gestión';
            caso.CC_Idioma__c= 'es';
            caso.CC_Tipo_Contacto__c='Incidencia';
            caso.CC_Detalles_Consulta__c = 'Value';
            caso.CC_Detalles_Solucion__c = 'Carga automatica caso';
        lstcasos.add(caso);

        insert lstcasos;
    }
}