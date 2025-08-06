import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import comprobarTareas from '@salesforce/apex/SAC_LCMP_GastosHipotecarios.comprobarTareas';
import modificarImportesTarea from '@salesforce/apex/SAC_LCMP_GastosHipotecarios.modificarImportesTarea';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import sacOtrosGastosField from '@salesforce/schema/Case.SAC_Otros_gastos__c';
import sacOriginField from '@salesforce/schema/Case.Origin';
import sacNotariaRecField from '@salesforce/schema/Case.SAC_NotariaReclamado__c';
import sacImpRecNotField from '@salesforce/schema/Case.SAC_ImpReclamadoNotaria__c';
import sacImpResNotField from '@salesforce/schema/Case.SAC_ImpResueltoNotaria__c';
import sacGestoriaRecField from '@salesforce/schema/Case.SAC_GestoriaReclamado__c';
import sacImpRecGesField from '@salesforce/schema/Case.SAC_ImpReclamadoGestoria__c';
import sacImpResGesField from '@salesforce/schema/Case.SAC_ImpResueltoGestoria__c';
import sacRegistrosRecField from '@salesforce/schema/Case.SAC_RegistrosReclamado__c';
import sacImpRecRegField from '@salesforce/schema/Case.SAC_ImpReclamadoRegistros__c';
import sacImpResRegField from '@salesforce/schema/Case.SAC_ImpResueltoRegistros__c';
import sacTasacionRecField from '@salesforce/schema/Case.SAC_TasacionReclamado__c';
import sacImpRecTasField from '@salesforce/schema/Case.SAC_ImpReclamadoTasacion__c';
import sacImpResTasField from '@salesforce/schema/Case.SAC_ImpResueltoTasacion__c';
import sacImpRecIntLegField from '@salesforce/schema/Case.SAC_ImpReclamadoInteresesLegales__c';
import sacImpResIntLegField from '@salesforce/schema/Case.SAC_ImpResueltoInteresesLegales__c';
import sacImpAbIntLegField from '@salesforce/schema/Case.SAC_ImpAbonadoInteresesLegales__c';
import impResueltoTotal from '@salesforce/schema/Case.SAC_Importe_Resuelto__c';


export default class Sac_GastosHipotecarios extends LightningElement {
 
    @api recordId;
    @api spinnerLoading = false;
    @track A1;
    @track A2; 
    @track A3;
    @track A4; 
    @track A5;
    @track resultA;
    @track readOnly = true;
    @track impNotariaBloqueado = false;
    @track impGestoriaBloqueado = false;
    @track impRegistrosBloqueado = false;
    @track impTasacionBloqueado = false;
    @track impNotariaReclamado;
    @track impNotariaResuelto;
    @track impGestoriaReclamado;
    @track impGestoriaResuelto;
    @track impRegistroReclamado;
    @track impRegistroResuelto;
    @track impTasacionReclamado;
    @track impTasacionResuelto;
    @track lanzarWarning = false;
    sacOtrosGastosValue;
    sacOriginValue;
    showSacOtrosGastos = false;
    @track showImpInteresesLegales = false;
    @track impTotalResueltoInicial;
    @track sumatorioImpResueltosInicio;


    @wire(getRecord, { recordId: '$recordId', fields: [sacOtrosGastosField, sacOriginField, sacNotariaRecField, sacGestoriaRecField, sacRegistrosRecField, sacTasacionRecField, sacImpRecNotField, sacImpResNotField, sacImpRecGesField, sacImpResGesField, sacImpRecRegField, sacImpResRegField, sacImpRecTasField, sacImpResTasField, sacImpRecIntLegField, sacImpResIntLegField, sacImpAbIntLegField, impResueltoTotal] })
    caseRecord({ error, data }) {
        if (data) {
            this.sacOtrosGastosValue = data.fields.SAC_Otros_gastos__c.value;
            this.sacOriginValue = data.fields.Origin.value;
            
            if(this.sacOtrosGastosValue != null && this.sacOriginValue == 'SAC_Formulario'){
                this.showSacOtrosGastos = true;
            }

            //Notaria
            this.impNotariaReclamado = data.fields.SAC_ImpReclamadoNotaria__c.value;
            this.impNotariaResuelto = data.fields.SAC_ImpResueltoNotaria__c.value;
            if(!this.lanzarWarning && data.fields.SAC_NotariaReclamado__c.value !== 'SAC_Yes' && (data.fields.SAC_NotariaReclamado__c.value === 'SAC_No' || (!(this.impNotariaReclamado > 0) && !(this.impNotariaResuelto > 0)))){
                this.impNotariaBloqueado = true;               
            }

            //Gestoria
            this.impGestoriaReclamado = data.fields.SAC_ImpReclamadoGestoria__c.value;
            this.impGestoriaResuelto = data.fields.SAC_ImpResueltoGestoria__c.value;
            if(!this.lanzarWarning && data.fields.SAC_GestoriaReclamado__c.value !== 'SAC_Yes' && (data.fields.SAC_GestoriaReclamado__c.value === 'SAC_No' || (!(this.impGestoriaReclamado > 0) && !(this.impGestoriaResuelto > 0)))){
                this.impGestoriaBloqueado = true;
            }

            //Registros
            this.impRegistroReclamado = data.fields.SAC_ImpReclamadoRegistros__c.value;
            this.impRegistroResuelto = data.fields.SAC_ImpResueltoRegistros__c.value;
            if(!this.lanzarWarning && data.fields.SAC_RegistrosReclamado__c.value !== 'SAC_Yes' && (data.fields.SAC_RegistrosReclamado__c.value === 'SAC_No' || (!(this.impRegistroReclamado > 0) && !(this.impRegistroResuelto > 0)))){
                this.impRegistrosBloqueado = true;
            }

            //Tasacion
            this.impTasacionReclamado = data.fields.SAC_ImpReclamadoTasacion__c.value;
            this.impTasacionResuelto = data.fields.SAC_ImpResueltoTasacion__c.value;
            
            if(!this.lanzarWarning && data.fields.SAC_TasacionReclamado__c.value !== 'SAC_Yes' && (data.fields.SAC_TasacionReclamado__c.value === 'SAC_No' || (!(this.impTasacionReclamado > 0) && !(this.impTasacionResuelto > 0)))){
                this.impTasacionBloqueado = true;
            }

            //Intereses Legales, si estan informados se muestran como readonly, sino no se muestran
            if(data.fields.SAC_ImpReclamadoInteresesLegales__c.value > 0 || data.fields.SAC_ImpResueltoInteresesLegales__c.value > 0 || data.fields.SAC_ImpAbonadoInteresesLegales__c.value > 0){
                this.showImpInteresesLegales = true;
            }else{
                this.showImpInteresesLegales = false;
            }

            //Comprobar si el importe resuelto de la pretensión es igual a la suma de importes resuelto de notaria, gestoria, registros y tasación, en caso contrario significa que tiene tareas con importe resuelto de intereses legales informado
            this.impTotalResueltoInicial = data.fields.SAC_Importe_Resuelto__c.value;
            var impResueltoNotariaInicio = (this.impNotariaResuelto == '' || this.impNotariaResuelto == null) ? 0 : this.impNotariaResuelto;
            var impResueltoGestoriaInicio = (this.impGestoriaResuelto == '' || this.impGestoriaResuelto == null) ? 0 : this.impGestoriaResuelto;
            var impResueltoRegistrosInicio = (this.impRegistroResuelto == '' || this.impRegistroResuelto == null) ? 0 : this.impRegistroResuelto;
            var impResueltoTasacionInicio = (this.impTasacionResuelto == '' || this.impTasacionResuelto == null) ? 0 : this.impTasacionResuelto;
            this.sumatorioImpResueltosInicio = Number((Number(impResueltoNotariaInicio) + Number(impResueltoGestoriaInicio) + Number(impResueltoRegistrosInicio) + Number(impResueltoTasacionInicio)).toFixed(2));
        } else if (error) {
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Error al cargar el componente de gastos hipotecarios.',
                variant: 'error'
            }),);
        }
    }

    @wire(getRecord, { recordId: '$recordId'})
    case;
    
    @wire(comprobarTareas, { caseId: '$recordId' })
    tareasGGH(result){
        this.readOnly = result.data;
    }

    handleSubmit(event) {
        this.spinnerLoading = true;

        const bloquearEnvio = this.validarEnvioFormulario();

        if(!bloquearEnvio){
            const fields = event.detail.fields;

            //Damos valor a los campos de importe reclamado para actualizar el caso
            fields.SAC_ImpReclamadoNotaria__c = (this.impNotariaReclamado === '') ? null : this.impNotariaReclamado;
            fields.SAC_ImpReclamadoGestoria__c = (this.impGestoriaReclamado === '') ? null : this.impGestoriaReclamado;
            fields.SAC_ImpReclamadoRegistros__c = (this.impRegistroReclamado === '') ? null : this.impRegistroReclamado;
            fields.SAC_ImpReclamadoTasacion__c = (this.impTasacionReclamado === '') ? null : this.impTasacionReclamado;
            fields.CC_Importe_Reclamado__c = Number((Number(fields.SAC_ImpReclamadoNotaria__c) + Number(fields.SAC_ImpReclamadoGestoria__c) + Number(fields.SAC_ImpReclamadoRegistros__c) + Number(fields.SAC_ImpReclamadoTasacion__c)).toFixed(2));
            

            //Damos valor a los campos de importe resuelto para actualizar el caso
            fields.SAC_ImpResueltoNotaria__c = (this.impNotariaResuelto === '') ? null : this.impNotariaResuelto;
            fields.SAC_ImpResueltoGestoria__c = (this.impGestoriaResuelto === '') ? null : this.impGestoriaResuelto;
            fields.SAC_ImpResueltoRegistros__c = (this.impRegistroResuelto === '') ? null : this.impRegistroResuelto;
            fields.SAC_ImpResueltoTasacion__c = (this.impTasacionResuelto === '') ? null : this.impTasacionResuelto;

            
            //Si no es igual, significa que existen tareas de intereses legales, luego para el total de SAC_Importe_Resuelto__c debemos tener en cuenta esto
            if(this.impTotalResueltoInicial !== this.sumatorioImpResueltosInicio){
                //Con la diferencia calculamos el total de imp resuelto de intereses legales (en el momento de la carga del componente)
                var impInteresesLegales = this.impTotalResueltoInicial - this.sumatorioImpResueltosInicio;

                //Al nuevo sumatorio de imp resueltos, le sumamos el impInteresesLegales, para obtener el SAC_Importe_Resuelto__c correcto
                fields.SAC_Importe_Resuelto__c = Number((Number(fields.SAC_ImpResueltoNotaria__c) + Number(fields.SAC_ImpResueltoGestoria__c) + Number(fields.SAC_ImpResueltoRegistros__c) + Number(fields.SAC_ImpResueltoTasacion__c) + Number(impInteresesLegales)).toFixed(2));
            }else{
                fields.SAC_Importe_Resuelto__c = Number((Number(fields.SAC_ImpResueltoNotaria__c) + Number(fields.SAC_ImpResueltoGestoria__c) + Number(fields.SAC_ImpResueltoRegistros__c) + Number(fields.SAC_ImpResueltoTasacion__c)).toFixed(2));
            }

            let arrayImportes= [
                        fields.SAC_ImpResueltoNotaria__c,
                        fields.SAC_ImpResueltoGestoria__c,
                        fields.SAC_ImpResueltoRegistros__c,
                        fields.SAC_ImpResueltoTasacion__c] //Number(fields.SAC_ImpResueltoInteresesLegales__c)
                        
            this.template.querySelector('lightning-record-edit-form').submit(fields);

            modificarImportesTarea({caseId: this.recordId, arrayImportes: arrayImportes}).then(result => {
                
            }).catch(error => {
                this.isLoading = false;
                this.errorMsg = error;

                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar los importes en la tarea',
                    message: error.message,
                    variant: 'error'
                }),);
            })
        }
    }

    handleSuccess(event) {
        if(!this.lanzarWarning){
            const updatedRecord = event.detail.id;

            const toast = new ShowToastEvent({
                title: 'Gestión del caso',
                message: 'Se han actualizado campos del caso.',
                variant: 'success'
            });
            this.dispatchEvent(toast);
            this.spinnerLoading = false;
        }
    }

    //Logica notaria
    handleChangeNotaria(event){
        const valueNotaria = event.detail.value;

        if(valueNotaria === 'SAC_Yes'){
            this.impNotariaBloqueado = false;
        }else{
            this.impNotariaBloqueado = true;
            this.impNotariaReclamado = '';
            this.impNotariaResuelto = '';
        }
    }

    changeImpNotariaRec(event){
        this.impNotariaReclamado = event.detail.value;
    }

    changeImpNotariaRes(event){
        this.impNotariaResuelto = event.detail.value;
    }


    //Logica gestoria
    handleChangeGestoria(event){
        const valueGestoria = event.detail.value;

        if(valueGestoria === 'SAC_Yes'){
            this.impGestoriaBloqueado = false;
        }else{
            this.impGestoriaBloqueado = true;
            this.impGestoriaReclamado = '';
            this.impGestoriaResuelto = '';
        }
    }

    changeImpGestoriaRec(event){
        this.impGestoriaReclamado = event.detail.value;
    }

    changeImpGestoriaRes(event){
        this.impGestoriaResuelto = event.detail.value;
    }

    //Logica registros
    handleChangeRegistros(event){
        const valueRegistros = event.detail.value;

        if(valueRegistros === 'SAC_Yes'){
            this.impRegistrosBloqueado = false;
        }else{
            this.impRegistrosBloqueado = true;
            this.impRegistroReclamado = '';
            this.impRegistroResuelto = '';
        }
    }

    changeImpRegistroRec(event){
        this.impRegistroReclamado = event.detail.value;
    }

    changeImpRegistroRes(event){
        this.impRegistroResuelto = event.detail.value;
    }

    //Logica tasacion
    handleChangeTasacion(event){
        const valueTasacion= event.detail.value;

        if(valueTasacion === 'SAC_Yes'){
            this.impTasacionBloqueado = false;
        }else{
            this.impTasacionBloqueado = true;
            this.impTasacionReclamado = '';
            this.impTasacionResuelto = '';
        }
    }

    changeImpTasacionRec(event){
        this.impTasacionReclamado = event.detail.value;
    }

    changeImpTasacionRes(event){
        this.impTasacionResuelto = event.detail.value;
    }

    validarEnvioFormulario(){
        this.lanzarWarning = false;
        var mensajeWarning = '';
            

        if(!this.impNotariaBloqueado){
            var noTieneReclamado = (this.impNotariaReclamado == '' || this.impNotariaReclamado == null) ? true : false;
            var noTtieneResuelto = (this.impNotariaResuelto == '' || this.impNotariaResuelto == null) ? true : false;

            if(noTieneReclamado && noTtieneResuelto){
                this.lanzarWarning = true;
                mensajeWarning = 'notaría';
            }
        }
        if(!this.impGestoriaBloqueado){
            var noTieneReclamado = (this.impGestoriaReclamado == '' || this.impGestoriaReclamado == null) ? true : false;
            var noTtieneResuelto = (this.impGestoriaResuelto == '' || this.impGestoriaResuelto == null) ? true : false;

            if(noTieneReclamado && noTtieneResuelto){
                this.lanzarWarning = true;
                mensajeWarning = (mensajeWarning == '') ? 'gestoria': mensajeWarning + ', gestoria';
            }
        }
        if(!this.impRegistrosBloqueado){
            var noTieneReclamado = (this.impRegistroReclamado == '' || this.impRegistroReclamado == null) ? true : false;
            var noTtieneResuelto = (this.impRegistroResuelto == '' || this.impRegistroResuelto == null) ? true : false;

            if(noTieneReclamado && noTtieneResuelto){
                this.lanzarWarning = true;
                mensajeWarning = (mensajeWarning == '') ? 'registros': mensajeWarning + ', registros';
            }
        }
        if(!this.impTasacionBloqueado){
            var noTieneReclamado = (this.impTasacionReclamado == '' || this.impTasacionReclamado == null) ? true : false;
            var noTtieneResuelto = (this.impTasacionResuelto == '' || this.impTasacionResuelto == null) ? true : false;

            if(noTieneReclamado && noTtieneResuelto){
                this.lanzarWarning = true;
                mensajeWarning = (mensajeWarning == '') ? 'tasación': mensajeWarning + ', tasación';
            }
        }

        if(this.lanzarWarning){
            this.spinnerLoading = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Debe completar los importes',
                    message: 'Complete los importes reclamado/resuelto de: ' + mensajeWarning + '.',
                    variant: 'warning'
                }),
            );

            return true;
        }else{
            return false;
        }
    }

}