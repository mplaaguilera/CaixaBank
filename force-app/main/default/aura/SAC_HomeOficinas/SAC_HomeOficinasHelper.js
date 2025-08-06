({
    buscarPorOficina : function(component, event) {
        component.set("v.selectedSearch", 'Oficina');
    },

    buscarPorCliente : function(component, event){
        component.set("v.selectedSearch", 'Cliente');
    },

    buscarPorReclamacion : function(component, event){
        component.set("v.selectedSearch", 'Reclamacion');
    },

    changeColumns: function(component, event){
        if(component.get("v.selectedSearch") == 'Cliente' || component.get("v.selectedSearch") == 'Reclamacion'){
            component.set('v.mycolumns', [
                {label: 'Número del caso', fieldName: 'reclamacionLink', type: 'url', 
                typeAttributes: { label: { fieldName: 'CaseNumber' }, value:{fieldName: 'reclamacionLink'}, target: '_self'}, wrapText: true },
                {label: 'Asunto', fieldName: 'Subject', type: 'text', wrapText: true },
                {label: 'Nombre del cliente', fieldName: 'AccountName', type: 'text', wrapText: true },
                {label: 'NIF', fieldName: 'AccountCC_Numero_Documento__c', type: 'text', wrapText: true },
                {label: 'Fecha recepción', fieldName: 'SAC_FechaRecepcion__c', type: 'date', wrapText: true },
                {label: 'Fecha resolución', fieldName: 'OS_Fecha_Resolucion__c', type: 'date', wrapText: true },
                {label: 'Sentido resolución', fieldName: 'SAC_SentidoResolucion__c', type: 'text', wrapText: true },
                {label: 'Estado', fieldName: 'SAC_EstadoRed__c', type: 'text', wrapText: true },
                {label: 'Temática', fieldName: 'CC_MCC_Tematica__rName', type: 'text', wrapText: true },
                {label: 'Producto/Servicio', fieldName: 'CC_MCC_ProdServ__rName', type: 'text', wrapText: true },
                {label: 'Motivo', fieldName: 'CC_MCC_Motivo__rName', type: 'text', wrapText: true },
                {label: 'Detalle', fieldName: 'SEG_Detalle__rName', type: 'text', wrapText: true },
                {label: 'Importe reclamado', fieldName: 'CC_Importe_Reclamado__c', type: 'currency', wrapText: true },
                {label: 'Importe abonado', fieldName: 'CC_Importe_Abonado__c', type: 'currency', wrapText: true }
            ]);
        }
        else{
            component.set('v.mycolumns', [
                {label: 'Número del caso', fieldName: 'reclamacionLink', type: 'url', 
                typeAttributes: { label: { fieldName: 'CaseNumber' }, value:{fieldName: 'reclamacionLink'}, target: '_self'}, wrapText: true },
                {label: 'Asunto', fieldName: 'Subject', type: 'text', wrapText: true },
                {label: 'Nombre del cliente', fieldName: 'AccountName', type: 'text', wrapText: true },
                {label: 'NIF', fieldName: 'AccountCC_Numero_Documento__c', type: 'text', wrapText: true },
                {label: 'Fecha recepción', fieldName: 'SAC_FechaRecepcion__c', type: 'date', wrapText: true },
                {label: 'Fecha Resolución', fieldName: 'OS_Fecha_Resolucion__c', type: 'date', wrapText: true },
                {label: 'Grupo de trabajo', fieldName: 'SEG_Grupo__rName', type: 'text', wrapText: true },
                {label: 'Propietario del caso', fieldName: 'OwnerName', type: 'text', wrapText: true },
                {label: 'Temática', fieldName: 'CC_MCC_Tematica__rName', type: 'text', wrapText: true },
                {label: 'Producto/Servicio', fieldName: 'CC_MCC_ProdServ__rName', type: 'text', wrapText: true },
                {label: 'Motivo', fieldName: 'CC_MCC_Motivo__rName', type: 'text', wrapText: true },
                {label: 'Detalle', fieldName: 'SEG_Detalle__rName', type: 'text', wrapText: true },
                {label: 'Sentido resolución', fieldName: 'SAC_SentidoResolucion__c', type: 'text', wrapText: true },
                {label: 'Importe reclamado', fieldName: 'CC_Importe_Reclamado__c', type: 'currency', wrapText: true },
                {label: 'Importe abonado', fieldName: 'CC_Importe_Abonado__c', type: 'currency', wrapText: true },
                {label: '', type: 'button', initialWidth: 135, typeAttributes: { label: 'Ver detalles', name: 'view_details', title: 'Click para ver los detalles'}}

            ]);
        }

        component.set('v.mycolumnsATR', [
            {label: 'Número del caso', fieldName: 'reclamacionLink', type: 'url', 
                    typeAttributes: { label: { fieldName: 'CaseNumber' }, value:{fieldName: 'reclamacionLink'}, target: '_self'}, wrapText: true },
            {label: 'Reclamantes', fieldName: 'customers', type: 'text', initialWidth: 200, wrapText: true },
            {label: 'Fecha recepción', fieldName: 'creationDate', type: 'date', wrapText: true },
            {label: 'Producto/Servicio', fieldName: 'productService', type: 'text', initialWidth: 180, wrapText: true },
            {label: 'Contrato', fieldName: 'expedient', type: 'text', initialWidth: 120, wrapText: true },
            {label: 'Detalle', fieldName: 'causeDetail', type: 'text', initialWidth: 150, wrapText: true },
            {label: 'Sentido resolución', fieldName: 'resolutionType', type: 'text', initialWidth: 150, wrapText: true },
            {label: 'Importe reclamado', fieldName: 'claimAmount', type: 'currency', wrapText: true },
            {label: 'Importe abonado', fieldName: 'returnedAmount', type: 'currency', wrapText: true },
            {label: 'Oficina afectada', fieldName: 'affectedOffice', type: 'text', wrapText: true }
        ]);
        
    }
})