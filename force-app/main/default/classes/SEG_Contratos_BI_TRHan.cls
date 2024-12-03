/**
*   @description SEG_Contratos_BI_TRHan
*/
public with sharing class SEG_Contratos_BI_TRHan extends CC_TriggerHandlerBase{
    
    /**
     * @description Entrada principal del trigger BI.
     * @param tp Parámetros de contexto del trigger.
     */
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_Contratos__c>)tp.newList);
	}

    /**
     * @description Proceso principal del trigger BI.
     * @param listNewObj Listado de objetos New del trigger.
     */
    private void process(List<SEG_Contratos__c> listNewObj)
    {
        Set<Id> listadoMarcasCuenta = new Set<Id>();
        Set<Id> listadoCuentasReclamacionesAgotadas = new Set<Id>();

        // Procesar los datos de entrada para gestiones en la creación del contrato.
        for (SEG_Contratos__c contrato : listNewObj)
        {
            if(String.isNotBlank(contrato.SEG_Estado__c) && contrato.SEG_Estado__c == 'Reclamaciones Agotadas')
            {
                listadoCuentasReclamacionesAgotadas.add(contrato.SEG_NombreCuenta__c);
            }
            listadoMarcasCuenta.add(contrato.SEG_NombreCuenta__c);
        }

        // Gestión de las marcas del cliente.
        if (!listadoMarcasCuenta.isEmpty())
        {
            actualizarMarcasReclamaciones (listadoMarcasCuenta, listadoCuentasReclamacionesAgotadas);
        }

        // Gestión de las fechas de reclamación del contrato.
        actualizarFechasReclamacion (listNewObj);
        fechaFirma(listNewObj);
        noReclamar(listNewObj);
        reclamacion1RM(listNewObj);
        reclamacion2RM(listNewObj);
        reclamacion3RM(listNewObj);
        reclamacionesAgotadas(listNewObj);
	}

    /**
     * @description Actualización de las fechas de reclamación que están parametrizadas.
     * @param listNewObj Listado de objetos New del trigger.
     */
    private void actualizarFechasReclamacion (List<SEG_Contratos__c> listNewObj)
    {
        // Recuperar la CR asociada al caso de seguimiento.
        List<Id> listadoCasos = new List<Id>();
        for (SEG_Contratos__c contrato : listNewObj)
        {
            if (contrato.SEG_SR_Seguimiento__c != null)
            {
                listadoCasos.add(contrato.SEG_SR_Seguimiento__c);
            }
        }

        // Recuperar los casos de seguimiento y su configuración.
        Map<Id,Case> mapaCasos = new Map<Id,Case>([SELECT Id, CreatedDate, SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__c, 
                                                    SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_Plazo1Reclamacion__c,
                                                    SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_Plazo2Reclamacion__c,
                                                    SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_Plazo3Reclamacion__c,
                                                    SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_PlazoEnvioGestor__c,
                                                    SEG_ClasificacionRapida__r.SEG_ReclamacionesContratos__r.SEG_PlazoLlamada__c
                                                    FROM Case
                                                    WHERE Id IN :listadoCasos
                                                    ]);

        // Con los datos de configuración y casos recuperados, vamos a proceder a asignar las fechas de reclamaciones.
        for (SEG_Contratos__c contrato : listNewObj)
        {
            // Recuperar caso asociado.
            Case casoAsociado = mapaCasos.get(contrato.SEG_SR_Seguimiento__c);

            //A partir de la fecha del contrato rellenamos las fechas de las reclamaciones
            Date creacionContrato = System.today();
            contrato.SEG_Fecha_Contrato__c = (contrato.SEG_Fecha_Contrato__c == null) ? creacionContrato : contrato.SEG_Fecha_Contrato__c;
            creacionContrato = contrato.SEG_Fecha_Contrato__c;

            // Calcular las fechas asociadas al contrato.
            Integer reclamacion1 = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_Plazo1Reclamacion__c?.intValue();
            Integer reclamacion2 = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_Plazo2Reclamacion__c?.intValue();
            Integer reclamacion3 = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_Plazo3Reclamacion__c?.intValue();
            Integer envioGestor = casoAsociado?.SEG_ClasificacionRapida__r?.SEG_ReclamacionesContratos__r?.SEG_PlazoEnvioGestor__c?.intValue();
            
            contrato.SEG_Fecha_1_Reclamacion__c = (reclamacion1 !=  null && reclamacion1 > 0) ? creacionContrato.addDays(reclamacion1): null;
            contrato.SEG_Fecha_2_Reclamacion__c =  (reclamacion2 !=  null && reclamacion2 > 0) ? creacionContrato.addDays(reclamacion2): null;
            contrato.SEG_Fecha_3_Reclamacion__c = (reclamacion3 !=  null && reclamacion3 > 0) ? creacionContrato.addDays(reclamacion3): null;
            contrato.SEG_Fecha_Envio_Gestor__c = (envioGestor !=  null && envioGestor > 0) ? creacionContrato.addDays(envioGestor): null;
        }
    }

    /**
     * @description Gestión de las marcas de cliente asociadas a reclamaciones.
     * @param setCuentasMarcas Set de identificadores de cuentas a evaluar.
     * @param setCuentasCreacionAgotadas Set de identificadores de cuentas que se crean contratos con reclamaciones agotadas.
     */
    public static void actualizarMarcasReclamaciones(Set<Id> setCuentasMarcas, Set<Id> setCuentasCreacionAgotadas)
    {
        // Control para salir.
        if (setCuentasMarcas == null || setCuentasMarcas.isEmpty())
        {
            return;
        }

        // Buscamos la característica de reclamaciones agotadas.
        List<CC_Caracteristica__c> listadoCaracteristicas = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Reclamaciones Agotadas' LIMIT 1];
        if (listadoCaracteristicas.isEmpty())
        {
            // No está configurada la característica. Salimos.
            return;
        }
        Id caracteristicaReclamaciones = listadoCaracteristicas[0].Id;

        // Buscamos las marcas asociadas al cliente.
        Set<Id> setCuentasConMarca = new Set<Id>();
        Map<Id,List<SEG_Marca_de_un_cliente__c>> mapaCuentasMarcas = new Map<Id,List<SEG_Marca_de_un_cliente__c>>();
        for (SEG_Marca_de_un_cliente__c marcaCliente : [SELECT Id, SEG_Caracteristica__c, SEG_Cliente__c FROM SEG_Marca_de_un_cliente__c
                                                        WHERE SEG_Cliente__c IN :setCuentasMarcas AND SEG_Caracteristica__c = :caracteristicaReclamaciones])
        {
            setCuentasConMarca.add(marcaCliente.SEG_Cliente__c);
            
            List<SEG_Marca_de_un_cliente__c> setMarcasExistentes;
            if (mapaCuentasMarcas.get(marcaCliente.SEG_Cliente__c) != null)
            {
                setMarcasExistentes = mapaCuentasMarcas.get(marcaCliente.SEG_Cliente__c);
            }else{
                setMarcasExistentes = new List<SEG_Marca_de_un_cliente__c>();
            }
            setMarcasExistentes.add(marcaCliente);
            mapaCuentasMarcas.put(marcaCliente.SEG_Cliente__c, setMarcasExistentes);
        }

        // Buscamos los contratos de las cuentas para comprobar si alguno está en estado "RECLAMACIONES AGOTADAS".
        Set<Id> setCuentasContratosAgotadas = new Set<Id>();
        for (SEG_Contratos__c contrato : [SELECT Id, SEG_NombreCuenta__c, SEG_Estado__c 
                                            FROM SEG_Contratos__c 
                                            WHERE SEG_NombreCuenta__c IN :setCuentasMarcas
                                            AND SEG_Estado__c = 'Reclamaciones Agotadas'])
        {
            setCuentasContratosAgotadas.add(contrato.SEG_NombreCuenta__c);
        }

        // Evaluar la gestión de las marcas.
        List<SEG_Marca_de_un_cliente__c> listadoMarcasCrear = new List<SEG_Marca_de_un_cliente__c>();
        List<SEG_Marca_de_un_cliente__c> listadoMarcasBorrar = new List<SEG_Marca_de_un_cliente__c>();
        for (Id accountId : setCuentasMarcas)
        {
            Boolean contieneMarca = setCuentasMarcas.contains(accountId);
            Boolean contieneContrato = (setCuentasContratosAgotadas.contains(accountId) || setCuentasCreacionAgotadas.contains(accountId)) ? true : false;

            if (!contieneMarca && contieneContrato)
            {
                // Crear marca de reclamaciones agotadas.
                SEG_Marca_de_un_cliente__c nuevaMarca = new SEG_Marca_de_un_cliente__c();
                nuevaMarca.SEG_Cliente__c = accountId;
                nuevaMarca.SEG_Caracteristica__c = caracteristicaReclamaciones;
                listadoMarcasCrear.add(nuevaMarca);
            }

            if (contieneMarca && !contieneContrato && mapaCuentasMarcas.get(accountId) != null)
            {
                // Borrar marca de reclamaciones agotadas que tiene el cliente.
                listadoMarcasBorrar.addAll(mapaCuentasMarcas.get(accountId));
            }
        }

        if (!listadoMarcasCrear.isEmpty())
        {
            insert listadoMarcasCrear;
        }

        if (!listadoMarcasBorrar.isEmpty())
        {
            delete listadoMarcasBorrar;
        }
    }

    /**
     * @description Si el  campo SEG_Estado__c es 'Firmado' actualiza el campo de la fecha SEG_Fecha_Firma__c a Hoy 
     * @param listNewObjSeg -> Lista de SEG_Contratos__c con los valores nuevos.
     */ 
    public static void fechaFirma(List<SEG_Contratos__c> listNewObjSeg)
    {     
        for (SEG_Contratos__c contrato : listNewObjSeg)
        {
            if (contrato.SEG_Estado__c == 'Firmado' )
            {
                contrato.SEG_Fecha_Firma__c= Date.today();             
            }
        }      
    }

    /**
     * @description Si el  campo SEG_Estado__c es 'No reclamar' actualiza el campo de la fecha SEG_Fecha_Parada_Reclamacion__c a Hoy 
     * @param listNewObjSeg -> Lista de SEG_Contratos__c con los valores nuevos.
     */ 
    public static void noReclamar(List<SEG_Contratos__c> listNewObjSeg)
    {     
        for (SEG_Contratos__c contrato : listNewObjSeg)
        {
            if (contrato.SEG_Estado__c == 'No reclamar' )
            {
                contrato.SEG_Fecha_Parada_Reclamacion__c= Date.today();             
            }
        }      
    }

    /**
     * @description Si los  campos SEG_1a_Reclamacion_ejecutada_manualmente__c, SEG_2a_Reclamacion_ejecutada_manualmente__c, SEG_3a_Reclamacion_ejecutada_manualmente__c y SEG_Fecha_Envio_Gestor_Proceso__c son true actualiza el campo de  SEG_Estado__c a 'Reclamaciones agotadas'
     * @param listNewObjSeg -> Lista de SEG_Contratos__c con los valores nuevos.
     */ 
    public static void reclamacionesAgotadas(List<SEG_Contratos__c> listNewObjSeg)
    { 
        for (SEG_Contratos__c contrato : listNewObjSeg)
        {
            if (contrato.SEG_1a_Reclamacion_ejecutada_manualmente__c != false &&  contrato.SEG_2a_Reclamacion_ejecutada_manualmente__c != false && contrato.SEG_3a_Reclamacion_ejecutada_manualmente__c != false && contrato.SEG_Fecha_Envio_Gestor_Proceso__c != null)
            {
                contrato.SEG_Estado__c = 'Reclamaciones agotadas' ;                
            }
        }      
    }

    /**
     * @description Si el  campo SEG_1a_Reclamacion_ejecutada_manualmente__c es true actualiza el campo de la fecha SEG_Fecha_1a_Reclamacion_Proceso__c a Hoy 
     * @param listNewObjSeg -> Lista de SEG_Contratos__c con los valores nuevos.
     */ 
    public static void reclamacion1RM(List<SEG_Contratos__c> listNewObjSeg)
    { 
        for (SEG_Contratos__c contrato : listNewObjSeg)
        {
            if (contrato.SEG_1a_Reclamacion_ejecutada_manualmente__c == true)
            {
                contrato.SEG_Fecha_1a_Reclamacion_Proceso__c =  Date.today();              
            }
        }      
    }

    /**
     * @description Si el  campo SEG_2a_Reclamacion_ejecutada_manualmente__c es true actualiza el campo de la fecha SEG_Fecha_2a_Reclamacion_Proceso__c a Hoy 
     * @param listNewObjSeg -> Lista de SEG_Contratos__c con los valores nuevos.
     */ 
    public static void reclamacion2RM(List<SEG_Contratos__c> listNewObjSeg)
    { 
        for (SEG_Contratos__c contrato : listNewObjSeg)
        {
            if (contrato.SEG_2a_Reclamacion_ejecutada_manualmente__c == true)
            {
                contrato.SEG_Fecha_2a_Reclamacion_Proceso__c =  Date.today();   
            }
        }      
    }

    /**
     * @description Si el  campo SEG_3a_Reclamacion_ejecutada_manualmente__c es true actualiza el campo de la fecha SEG_Fecha_3a_Reclamacion_Proceso__c a Hoy 
     * @param listNewObjSeg -> Lista de SEG_Contratos__c con los valores nuevos.
     */ 
    public static void reclamacion3RM(List<SEG_Contratos__c> listNewObjSeg)
    { 
        for (SEG_Contratos__c contrato : listNewObjSeg)
        {
            if (contrato.SEG_3a_Reclamacion_ejecutada_manualmente__c == true)
            {
                contrato.SEG_Fecha_3a_Reclamacion_Proceso__c =  Date.today();               
            }
        }      
    }
}