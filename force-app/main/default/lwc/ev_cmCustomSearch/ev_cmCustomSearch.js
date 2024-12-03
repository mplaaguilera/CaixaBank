import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getCampaignMembers from '@salesforce/apex/EV_CMCustomController.getCampaignMembers';
import updateCampaignMemberStatus from '@salesforce/apex/EV_CMCustomController.updateCampaignMemberStatus';


export default class Ev_cmCustomSearch extends LightningElement {
@api recordId;
@api typeUpdate;
data = [];
datasize = 0;
pageNumber = 1;
pageSize = 100;
isLastPage = false;
resultSize = 0;
selection = [];
hasPageChanged;
error;
@track isUpdateDisabled = true;

  columns = [
    { label: 'Nombre', fieldName: 'EV_FirstName__c'},
    { label: 'Apellidos', fieldName: 'EV_LastName__c'},
    { label: 'Estado', fieldName: 'EV_Status__c'},
    { label: 'Email', fieldName: 'EV_Email__c'}
  ];



  connectedCallback() {
    console.log('@@type update '+ this.typeUpdate);
    this.campaigMember();
  }
  
  rowSelection(evt) {
    // List of selected items from the data table event.
    let updatedItemsSet = new Set();
    // List of selected items we maintain.
    let selectedItemsSet = new Set(this.selection);
    // List of items currently loaded for the current view.
    let loadedItemsSet = new Set();


    this.data.map((event) => {
        loadedItemsSet.add(event.Id);
    });


    if (evt.detail.selectedRows) {
        evt.detail.selectedRows.map((event) => {
            updatedItemsSet.add(event.Id);
        });


        // Add any new items to the selection list
        updatedItemsSet.forEach((id) => {
            if (!selectedItemsSet.has(id)) {
                selectedItemsSet.add(id);
            }
        });        
    }


    loadedItemsSet.forEach((id) => {
        if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
            // Remove any items that were unselected.
            selectedItemsSet.delete(id);
        }
    });


    this.selection = [...selectedItemsSet];
    console.log('@this.selection '+ this.selection.length);
    if(this.selection.length < 1){
        this.isUpdateDisabled = true;
    }else if(this.selection.length > 100){
        console.log('@@entro en error ');
        // Muestra un mensaje de error o realiza alguna acción adecuada
        this.isUpdateDisabled = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'No puedes seleccionar más de 100 miembros de campaña. Por favor, deselecciona para poder actualizar.',
                variant: 'error'
            })
        );
    }else{
        this.isUpdateDisabled = false;
    }
    console.log('---selection---'+JSON.stringify(this.selection));
    
  }


  previousEve() {
    //Setting current page number
    let pageNumber = this.pageNumber;
    this.pageNumber = pageNumber - 1;
    //Setting pageChange variable to true
    this.hasPageChanged = true;
    this.campaigMember();
  }


  nextEve() {
    //get current page number
    let pageNumber = this.pageNumber;
    //Setting current page number
    this.pageNumber = pageNumber + 1;
    //Setting pageChange variable to true
    this.hasPageChanged = true;
    this.campaigMember();
  }


  get recordCount() {
    return (
      (this.pageNumber - 1) * this.pageSize +
      " to " +
      ((this.pageNumber - 1) * this.pageSize + this.resultSize)
    );
  }


  get disPre() {
    return this.pageNumber === 1 ? true : false;
  }


  campaigMember() {
    getCampaignMembers({
      recordId: this.recordId,
      pageSize: this.pageSize,
      pageNumber: this.pageNumber,
      typeUpdate: this.typeUpdate
    })
      .then(result => {
        let accountData = JSON.parse(JSON.stringify(result));
        this.dataSize = result.length;
        this.data = accountData;
        if (accountData.length < this.pageSize) {
          this.isLastPage = true;
        } else {
          this.isLastPage = false;
        }
        this.resultSize = accountData.length;
        this.template.querySelector(
            '[data-id="datarow"]'
          ).selectedRows = this.selection;
      })
      .catch(error => {
        this.error = error;
      });
  }

  updateAttendance() {
    updateCampaignMemberStatus({ 
        selection: this.selection, 
        typeUpdate: this.typeUpdate
    })
        .then(() => {
            // Actualización exitosa
            console.log('@@actualizacion exitosa');
            this.selection = [];
            this.isUpdateDisabled = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Se actualizaron los miembros de campaña marcados correctamente.',
                    variant: 'success'
                })
            );
            return refreshApex(this.campaigMember());
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No se han podido actualizar los miembros de campaña. Por favor, contacte con el administrador',
                    variant: 'error'
                })
            );
            console.error(error);
        });
}
}