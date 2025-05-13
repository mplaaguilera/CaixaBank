/*****************************************************************
 * Name: SAC_LCMP_ProductosPretension
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente sac_ProductosPretension
 * Clase test: SAC_LCMP_ProductosPretension_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            --               Raúl Santos    15/06/23     Creación
*****************************************************************/

public with sharing class SAC_LCMP_ProductosPretension {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEREC = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRET =mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    

    /**************************************************************************
     * Proposito: Método para recuperar los productos de pretensiones de la reclamación o pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Raúl Santos    15/06/23     Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ProductosPretension getProductosPretensiones(String recordId) {

        List<SAC_ProductCase__c> productos = new List<SAC_ProductCase__c>();
        Case caso = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Case WHERE Id = :recordId LIMIT 1];

        if(caso.RecordTypeId == RECTYPEREC){
            productos = [SELECT Id, SAC_Pretension__c, SAC_Pretension__r.CaseNumber, SAC_Tipo__c, SAC_Descripcion__c, N_Contrato__c, SAC_TaeMaximoAplicado__c, SAC_TaeInicialContrato__c, SAC_Negociar__c, SAC_DisponemosDeContrato__c, SAC_FechaApertura__c, SAC_FechaCancelacion__c, SAC_ProcedenciaContrato__c, SAC_CajaProcedencia__c
                         FROM SAC_ProductCase__c WHERE SAC_Pretension__r.SAC_Reclamacion__c = :recordId];

        }else if(caso.RecordTypeId == RECTYPEPRET){
            productos = [SELECT Id, SAC_Tipo__c, SAC_Descripcion__c, N_Contrato__c, SAC_TaeMaximoAplicado__c, SAC_TaeInicialContrato__c, SAC_Negociar__c, SAC_DisponemosDeContrato__c, SAC_FechaApertura__c, SAC_FechaCancelacion__c, SAC_ProcedenciaContrato__c, SAC_CajaProcedencia__c
                        FROM SAC_ProductCase__c WHERE SAC_Pretension__c = :recordId];      
        }

        if(!productos.isEmpty()){
            ProductosPretension  prodPret = new ProductosPretension(caso.RecordType.DeveloperName, productos);
            return  prodPret;
        }else{
            ProductosPretension  prodPret = new ProductosPretension(caso.RecordType.DeveloperName, productos);
            return  prodPret;
        }
    }

    /**************************************************************************
     * Proposito: Clase wrapper para los productos de pretensiones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Raúl Santos    15/06/23     Creación
    **************************************************************************/  

    public class ProductosPretension{
        @AuraEnabled public String caso {get; set;}
        @AuraEnabled public List<SAC_ProductCase__c> listaProductos {get; set;}

        public ProductosPretension(String casoC, List<SAC_ProductCase__c> listaProductosC){
            caso = casoC;
            listaProductos = listaProductosC;
        }
    }
    
    
    /**************************************************************************
     * Propósito: Método para crear los productos de pretensiones de la reclamación o pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1091686       Iria ANPC     20/12/2024      Creación
    *****************************************************************************/
    
    @AuraEnabled
    public static void createProductCase(String descripcion, String contrato, String tipo, Date fechaApertura, Date fechaCancelacion, Id pretensionId, Decimal taeInicial, Decimal taeMaximo, String negociar, String disponemosContrato, String procedenciaContrato, String cajaProcedencia){
        try {
            SAC_ProductCase__c productCase = new SAC_ProductCase__c(
                SAC_Descripcion__c = descripcion,
                N_Contrato__c = contrato,
                SAC_Tipo__c = tipo,
                SAC_FechaApertura__c = fechaApertura,
                SAC_FechaCancelacion__c = fechaCancelacion,
                SAC_Pretension__c = pretensionId,
                SAC_TaeInicialContrato__c = taeInicial,
                SAC_TaeMaximoAplicado__c = taeMaximo,
                SAC_Negociar__c = negociar,
                SAC_DisponemosDeContrato__c = disponemosContrato,
                SAC_ProcedenciaContrato__c = procedenciaContrato,
                SAC_CajaProcedencia__c = cajaProcedencia
            );

            SAC_DatabaseDML.insertDML(productCase, true);
            //insert productCase;
        } catch (Exception e) {
            throw new AuraHandledException('Error al crear el Producto: ' + e.getMessage());
        }
    }

    /**************************************************************************
     * Propósito: Método para editar los productos de pretensiones de la reclamación o pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1091686       Iria ANPC     20/12/2024      Creación
    *****************************************************************************/
    @AuraEnabled
    public static void editProductCase(String productId, String descripcion, String contrato, String tipo, Date fechaApertura, Date fechaCancelacion, Id pretensionId, Decimal taeInicial, Decimal taeMaximo, String negociar, String disponemosContrato, String procedenciaContrato, String cajaProcedencia) {
        try {
            SAC_ProductCase__c productCase = [SELECT Id, SAC_Descripcion__c, N_Contrato__c, SAC_Tipo__c, SAC_FechaApertura__c, SAC_FechaCancelacion__c,
                                                SAC_TaeInicialContrato__c, SAC_TaeMaximoAplicado__c, SAC_Negociar__c, SAC_DisponemosDeContrato__c, SAC_ProcedenciaContrato__c, SAC_CajaProcedencia__c
                                                FROM SAC_ProductCase__c WHERE Id =: productId LIMIT 1];
            productCase.SAC_Descripcion__c = descripcion;
            productCase.N_Contrato__c = contrato;
            productCase.SAC_Tipo__c = tipo;
            productCase.SAC_FechaApertura__c = fechaApertura;
            productCase.SAC_FechaCancelacion__c = fechaCancelacion;
            productCase.SAC_TaeInicialContrato__c = taeInicial;
            productCase.SAC_TaeMaximoAplicado__c = taeMaximo;
            productCase.SAC_Negociar__c = negociar;
            productCase.SAC_DisponemosDeContrato__c = disponemosContrato;
            productCase.SAC_ProcedenciaContrato__c = procedenciaContrato;
            productCase.SAC_CajaProcedencia__c = cajaProcedencia;

            SAC_DatabaseDML.updateDML(productCase, true);
            //update productCase;
        } catch (Exception e) {
            throw new AuraHandledException('Error al actualizar el registro: ' + e.getMessage());
        }
    }

        /**************************************************************************
     * Propósito: Método para eliminar el producto seleccionado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1103407       Álex Polo     12/02/2025      Creación
    *****************************************************************************/
    @AuraEnabled
    public static void eliminarProducto(Id idProducto) {
        try {
            SAC_ProductCase__c producto = new SAC_ProductCase__c();
            producto.Id = idProducto;
            SAC_DatabaseDML.deleteDML(producto, true);
            //update productCase;
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar el registro: ' + e.getMessage());
        }
    }

}