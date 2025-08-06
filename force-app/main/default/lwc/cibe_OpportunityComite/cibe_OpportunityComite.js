import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from "@salesforce/apex";


//labels
import cancel from '@salesforce/label/c.CIBE_Cancelar';
import save from '@salesforce/label/c.CIBE_Guardar';
import updateOpp from '@salesforce/label/c.CIBE_OportunidadActualizada';
import updateOppOk from '@salesforce/label/c.CIBE_OportunidadActualizadaCorrectamente';
import updateOppKo from '@salesforce/label/c.CIBE_ErrorActualizandoOpp';
import syndicationTeamError from '@salesforce/label/c.CIBE_SyndicationTeamError';
import equipoAnalistas from '@salesforce/label/c.CIBE_EquipoAnalistas';
import relatedTeamError from '@salesforce/label/c.CIBE_RelatedTeamError';
import creditoPortfolioError from '@salesforce/label/c.CIBE_CreditPortfolioError';
import equipoRelaMssg from '@salesforce/label/c.CIBE_EquipoRelacionadoMssg';
import equipoRelaCP from '@salesforce/label/c.CIBE_EquiposRelacionadosCP';
import analystTeam from '@salesforce/label/c.CIBE_AnalystTeam';
import chiefOpOff from '@salesforce/label/c.CIBE_ChiefOpOff';
import syndicateSales from '@salesforce/label/c.CIBE_LoanSyndicateSales';
import alm from '@salesforce/label/c.CIBE_ALM';
import notificationChief from '@salesforce/label/c.CIBE_NotificationChiefSend';
import almTeam from '@salesforce/label/c.CIBE_ALMTeam';


//apex
import updateEquipoSindicaciones from '@salesforce/apex/CIBE_OpportunityComite.updateEquipoSindicaciones';
import updateCreditoPortfolio from '@salesforce/apex/CIBE_OpportunityComite.updateCreditoPortfolio';
import updateLoanSyndicateSalesCheckBox from '@salesforce/apex/CIBE_OpportunityComite.updateLoanSyndicateSalesCheckBox';
import updateALMCheckBox from '@salesforce/apex/CIBE_OpportunityComite.updateALMCheckBox';
import updateChiefCheckBox from '@salesforce/apex/CIBE_OpportunityComite.updateChiefCheckBox';
import getOpportunity from '@salesforce/apex/CIBE_OpportunityComite.getOpportunity';
import updateALM from '@salesforce/apex/CIBE_OpportunityComite.updateALM';


export default class Cibe_OpportunityComite extends LightningElement {


  @api recordId;

  labels = {
    cancel,
    save,
    updateOpp,
    updateOppOk,
    updateOppKo,
    syndicationTeamError,
    equipoAnalistas,
    relatedTeamError,
    creditoPortfolioError,
    equipoRelaMssg,
    equipoRelaCP,
    analystTeam,
    chiefOpOff,
    syndicateSales,
    alm,
    notificationChief,
    almTeam
    
  }


  @track showEquipoAnalista = true;
  @track editMode = false;

  @track showEquipoRelacionado = true;

  @track valueEquipoSind;
  @track valueCreditoPortfolio;
  @track valueALM;
  @track commentALM;
  @track isShowSpinner = false;

  @track valueEquipoSindB = false;
  @track valueCreditoPortfolioB = false;
  @track valueALMB = false;
  @track commentALMB = false;

  @track sindNeg = 'Structured Finance';
  @track sindRed = 'Loan Syndicate & Sales';

  @track creditNeg = 'CIB Solutions';
  @track creditRed = 'Credit Portfolio Analysis';

  @track almRed = 'ALM';


  @track chiefOpOff;
  @track syndicateSales;
  @track alm;

  wireData;

  @wire(getOpportunity, { recordId: '$recordId'})
    wireOpp(wireResult) {
      const { data, error } = wireResult;
      this.wireData = wireResult;
        if (data) {
          this.syndicateSales = data[0].CIBE_LoanSyndicateSales__c;
          this.alm = data[0].CIBE_ALM__c;
          this.chiefOpOff = data[0].CIBE_ChiefOperationsOfficer__c;

          this.creditPortfolio = data[0].CIBE_CreditPortAnalystReview__c;
          this.equipoSindicaciones = data[0].CIBE_SyndicationTeamOpinion__c;
          this.almField = data[0].CIBE_DicALM__c;
          this.almComment = data[0].CIBE_DicALMComment__c;
        } else if (error) {
            console.log(error);
        }
  }

  toggleShowEquipoAnalista() {
    this.showEquipoAnalista = !this.showEquipoAnalista;

  }

  toggleShowEquipoRelacionado() {
    this.showEquipoRelacionado = !this.showEquipoRelacionado;
  }

  handleEnableEdit() {
    this.editMode = true;
  }

  handleCancel() {
    refreshApex(this.wireData);
    this.valueCreditoPortfolio = this.creditPortfolio;
    this.valueCreditoPortfolioB = false;

    this.valueEquipoSind = this.equipoSindicaciones;
    this.valueEquipoSindB = false;

    this.valueALM = this.almField;
    this.valueALMB = false;
    this.editMode = false;
    
    this.commentALM = this.almComment;
    this.commentALMB = false;
    this.syndicateEdit = false;
    this.analystEdit = false;
    this.almEdit = false;



  }




  handleValueEquipoSind(event) {
    this.valueEquipoSind = event.target.value;
    this.valueEquipoSindB = true;

  }

  handleValueCredPort(event) {
    this.valueCreditoPortfolio = event.target.value;
    this.valueCreditoPortfolioB = true;
  }

  handleValueALM(event) {
    this.valueALM = event.target.value;
    this.valueALMB = true;
  }

  handleValueALMComment(event) {
    this.commentALM = event.target.value;
    this.commentALMB = true;
  }

  handleSuccess(event) {
    this.isShowSpinner = false;
    this.valueEquipoSindB = false;
    this.valueALMB = false;

  }

  handleSubmitDef(event) {
    let record = [];
    if(!record.includes(this.recordId)){
      record.push(this.recordId);
    }
    this.isShowSpinner = true;
    event.preventDefault();
    if (this.valueCreditoPortfolioB) {
      const fieldsCreditoPortfolio = event.detail.fields;
      updateCreditoPortfolio({ recordId: this.recordId, creditoPortfolio: this.valueCreditoPortfolio, negocioV: this.creditNeg, redesV: this.creditRed })
      .then((data) => { 
        if (data === 'NOK') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: this.labels.updateOppKo,
              message: this.labels.creditoPortfolioError,
              variant: 'error'
            })
          );
          this.valueCreditoPortfolio = this.creditPortfolio;
        } else if(data === 'OK') {
          this.template.querySelector('lightning-record-edit-form').submit(fieldsCreditoPortfolio);
        }else{
          this.valueCreditoPortfolio = this.creditPortfolio;
          this.dispatchEvent(
            new ShowToastEvent({
              title: this.labels.updateOppKo,
              message: data,
              variant: 'error'
            })
          );
        }
      }).catch(error => {
        console.log(error);
      }).finally(() => {
        refreshApex(this.wireData);
        this.valueEquipoSindB = false;
        this.valueCreditoPortfolioB = false;
        this.valueALMB = false;
        this.editMode = false;
        this.syndicateEdit = false;
        this.analystEdit = false;
        this.almEdit = false;    
        this.isShowSpinner = false;
      });
      
    } 


    if(this.valueALMB || this.commentALMB){
      const fields = event.detail.fields;
      updateALM({ recordId: this.recordId, valueALM: this.valueALM, commentALM: this.commentALM, negocioV: this.creditNeg, redesV: this.almRed, listado: false })
      .then((data) => { 
        if (data === 'NOK') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: this.labels.updateOppKo,
              message: this.labels.almTeam,
              variant: 'error'
            })
          );
          this.valueALM = this.almField;
          this.commentALM = this.almComment;
        }else if(data === 'OK') {
          this.template.querySelector('lightning-record-edit-form').submit(fields);
        }else{
          this.valueALM = this.almField;
          this.commentALM = this.almComment;
          this.dispatchEvent(
            new ShowToastEvent({
              title: this.labels.updateOppKo,
              message: data,
              variant: 'error'
            })
          );
        }
      }).catch(error => {
        console.log(error);
      }).finally(() => {
        refreshApex(this.wireData);
        this.valueEquipoSindB = false;
        this.valueALMB = false;
        this.valueCreditoPortfolioB = false;
        this.editMode = false;
        this.syndicateEdit = false;
        this.analystEdit = false;
        this.almEdit = false;
        this.isShowSpinner = false;

      });
    }


    if (this.valueEquipoSindB) {
      const fields = event.detail.fields;
      updateEquipoSindicaciones({ recordId: this.recordId, equipoSindicaciones: this.valueEquipoSind, negocioV: this.sindNeg, redesV: this.sindRed, listado: false })
        .then((data) => {
          if (data === 'NOK') {
            this.dispatchEvent(
              new ShowToastEvent({
                title: this.labels.updateOppKo,
                message: this.labels.syndicationTeamError,
                variant: 'error'
              })
            );
            this.valueEquipoSind = this.equipoSindicaciones;
          } else if(data === 'OK'){
            this.template.querySelector('lightning-record-edit-form').submit(fields[1]);
          }else{
            this.valueEquipoSind = this.equipoSindicaciones;
            this.dispatchEvent(
              new ShowToastEvent({
                title: this.labels.updateOppKo,
                message: data,
                variant: 'error'
              })
            );
          }
        }).catch(error => {
          console.log(error);
        }).finally(() => {
          refreshApex(this.wireData);
          this.valueEquipoSindB = false;
          this.valueALMB = false;
          this.valueCreditoPortfolioB = false;
          this.editMode = false;
          this.syndicateEdit = false;
          this.analystEdit = false;
          this.almEdit = false;
          this.isShowSpinner = false;
				});
    }


    record = null;
    this.dispatchEvent(new RefreshEvent());



  }



  handleChief(event){
    this.isShowSpinner = true;
    this.chiefOpOff = event.target.checked;
    updateChiefCheckBox({recordId: this.recordId, chiefOperations: this.chiefOpOff})
    .then((result) =>{
      if(result !== 'OK'){
        this.chiefOpOff = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: this.labels.updateOppKo,
            message: result,
            variant: 'error'
          })
        );
      }
    }).catch ((error) =>{
      console.log(error);
    })
    .finally(() => {
      this.isShowSpinner = false;
    })
  }


  handleSyndicateSales(event){
    this.isShowSpinner = true;
    this.syndicateSales = event.target.checked;
    updateLoanSyndicateSalesCheckBox({recordId: this.recordId, loanSyndicateSales: this.syndicateSales})
    .then((result) =>{
      if(result !== 'OK'){
        this.syndicateSales = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: this.labels.updateOppKo,
            message: result,
            variant: 'error'
          })
        );
      }else{
        this.dispatchEvent(new RefreshEvent());
      }
    }).catch ((error) =>{
      console.log(error);
    })
    .finally(() => {
      this.isShowSpinner = false;
    })
  }

  handleALM(event){
    this.isShowSpinner = true;
    this.alm = event.target.checked;
    updateALMCheckBox({recordId: this.recordId, alm: this.alm})
    .then((result) =>{
      if(result !== 'OK'){
        this.alm = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: this.labels.updateOppKo,
            message: result,
            variant: 'error'
          })
        );
      }else{
        this.dispatchEvent(new RefreshEvent());
      }
    }).catch ((error) =>{
      console.log(error);
    })
    .finally(() => {
      this.isShowSpinner = false;
    })
  }



  @track analystEdit = false;
  @track syndicateEdit = false;
  @track almEdit = false;
  buttonEditAnalyst(){
    this.editMode = true;
    this.analystEdit = true;
  }

  buttonEditSyndicate(){
    this.editMode = true;
    this.syndicateEdit = true;
  }


  buttonEditALM(){
    this.editMode = true;
    this.almEdit = true;
  }




}