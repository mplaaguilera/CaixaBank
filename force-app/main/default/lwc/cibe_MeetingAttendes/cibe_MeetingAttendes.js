import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import LWC_DATATABLE_CSS from '@salesforce/resourceUrl/CIBE_MeetingAttendesIcon'
import { loadStyle } from 'lightning/platformResourceLoader';


import searchUserClientes from '@salesforce/apex/CIBE_NewEventCIBController.searchUserClientes';
import searchCXB from '@salesforce/apex/CIBE_NewEventCIBController.searchUserCXB';
import processAsistentes from '@salesforce/apex/CIBE_EventAttendesComponent_Controller.processAsistentes';
import getAsistentesCXB from '@salesforce/apex/CIBE_EventAttendesComponent_Controller.returnAttendeesCaixabank';
import getAsistentesClientes from '@salesforce/apex/CIBE_EventAttendesComponent_Controller.returnAttendeesCliente';
import getAsistentesNoRegistrados from '@salesforce/apex/CIBE_EventAttendesComponent_Controller.returnAttendeesSinRegistrar';
import getEvent from '@salesforce/apex/CIBE_EventAttendesComponent_Controller.getEvent';
import deleteAttende from '@salesforce/apex/CIBE_EventAttendesComponent_Controller.deleteAttende';

//labels
import assCXB from '@salesforce/label/c.CIBE_AsistentesCaixabank';
import nombreEmpleado from '@salesforce/label/c.CIBE_nombreEmpleado';
import funcion from '@salesforce/label/c.CIBE_funcion';
import centro from '@salesforce/label/c.CIBE_Centro';
import asistentesNoRegistrados from '@salesforce/label/c.CIBE_AsistentesNoRegistrados';
import escribirEmail from '@salesforce/label/c.CIBE_EscribirEmail';
import asistentesCaixa from '@salesforce/label/c.CIBE_AsistentesCaixabank';
import buscaContacto from '@salesforce/label/c.CIBE_BuscaContacto';
import anyadir from '@salesforce/label/c.CIBE_Add';
import asistentes from '@salesforce/label/c.CIBE_Asistentes';
import estado from '@salesforce/label/c.CIBE_Estado';
import apellido from '@salesforce/label/c.CIBE_Apellido';
import nombre from '@salesforce/label/c.CIBE_Nombre';
import cargo from '@salesforce/label/c.CIBE_Cargo';
import idioma from '@salesforce/label/c.CIBE_Idioma';
import email from '@salesforce/label/c.CIBE_Email';
import telefono from '@salesforce/label/c.CIBE_Telefono';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import assClientes from '@salesforce/label/c.CIBE_AsistentesClientes';
import assNoRegistrados from '@salesforce/label/c.CIBE_AsistentesNoRegistrados';
import deleteAtt from '@salesforce/label/c.CIBE_DeleteAttende';
import deleteAttende2 from '@salesforce/label/c.CIBE_DeleteAttende2';
import eliminar from '@salesforce/label/c.CIBE_Eliminar';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import add from '@salesforce/label/c.CIBE_Add';
import enviarCita from '@salesforce/label/c.CIBE_EnviarCita';
import tipoAsistente from '@salesforce/label/c.CIBE_TipoAsistente';




export default class Cibe_MeetingAttendes extends LightningElement {


    labels = {
        assCXB,
        nombreEmpleado,
        funcion,
        centro,
        asistentesNoRegistrados,
        escribirEmail,
        asistentesCaixa,
        buscaContacto,
        anyadir,
        asistentes,
        estado,
        apellido,
        nombre,
        cargo,
        idioma,
        email,
        telefono,
        confidencial,
        assClientes,
        assNoRegistrados,
        deleteAtt,
        deleteAttende2,
        eliminar,
        cancelar,
        add,
        enviarCita,
        tipoAsistente
    }

    connectedCallback() {
        loadStyle(this, LWC_DATATABLE_CSS);
    }

    @track columnsCXB = [
		{ label: this.labels.nombreEmpleado,   fieldName: 'empleadoId', sortable: true,  type: 'url', typeAttributes: {label: {fieldName: 'nombreEmpleado'}}},
		{ label: this.labels.funcion, fieldName: 'funcion'  },
		{ label: this.labels.centro, fieldName: 'centro'},
        
		{ label: this.labels.estado, fieldName : 'status', type: 'text', sortable: true, cellAttributes: { iconName: { fieldName: 'priorityicon' }, class: {fieldName: 'classEstado'}}},
        { label: '', type: 'button-icon', typeAttributes: { iconName: 'utility:delete',name: 'deleteAttende', class: 'icon-size_small' }, initialWidth : 80 }
	];

    columnsClientes = [

		{ label: this.labels.nombre,  fieldName: 'nombreId', sortable: true,  type: 'url', typeAttributes: {label: {fieldName: 'nombre'}}},
		{ label: this.labels.apellido, fieldName: 'nombreId', sortable: true, type: 'url', typeAttributes: {label: {fieldName: 'apellido'}}},
		{ label: this.labels.cargo, fieldName: 'cargo'},
        { label: this.labels.idioma, fieldName: 'idioma'},
        { label: this.labels.email, fieldName: 'email'},
        { label: this.labels.telefono, fieldName: 'telefono'},
        { label: this.labels.confidencial, fieldName: 'confidencial'},
		{ label: this.labels.estado, fieldName : 'status', sortable: true, type: 'text', cellAttributes: { iconName: { fieldName: 'priorityicon' }, class: {fieldName: 'classEstado'}}},
        { label: '', type: 'button-icon', typeAttributes: { iconName: 'utility:delete',name: 'deleteAttende', class: 'icon-size_small' }, initialWidth : 80 }

	];


    columnsNoRegistrados = [

        { label: this.labels.email, fieldName: 'email'},
		{ label: this.labels.estado, fieldName : 'status', sortable: true, type: 'text', cellAttributes: { iconName: { fieldName: 'priorityicon' }, class: {fieldName: 'classEstado'}}},
        { label: '', type: 'button-icon', typeAttributes: { iconName: 'utility:delete',name: 'deleteAttende', class: 'icon-size_small' }, initialWidth : 80 }

	];

    columnsAttendes = [
		{ label: this.labels.enviarCita, fieldName: 'cita', type: 'Boolean', initialWidth : 80 },
		{ label: this.labels.nombre, fieldName: 'name'  },
		{ label: this.labels.email, fieldName: 'email' },
		{ label: this.labels.tipoAsistente, fieldName: 'tipoAsistente' },
		{ label: '', type: 'button-icon', typeAttributes: { iconName: 'utility:delete',name: 'delete' }, initialWidth : 80 }
	];

    @api recordId;
    @track dataCXB;
    @track dataClientes;
    @track dataNoRegistrados;
    @track isModalOpen = false;
    @track isModalOpenDelete = false;
    @track selectedAttendes = [];
    buttonDisabled = true;
    añadirAttende = false;
    selectedItem
    @track attendeData = [];
	noRegistrado = false;
    @track selectedId =[];
    @track preSelectedRows = [];
    @track selectedAttendesToSend = [];
    @track _wiredDataCXB;
    @track _wiredDataClientes;
    @track _wiredDataNoRegistrados;
    @track selectedRows;
    @track accountId;
    @track row;
    @track showSpinner = false;
    @track showSpinnerAdd = false;

    @track sortByFieldName;
    @track sortByLabel;
    @track sortDirection;
    @track defaultSort = 'asc';
    @track dataValues = [];


    openModal() {
        this.isModalOpen = true;
        this.attendeData = [];
        this.añadirAttende = false;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    closeModalDelete() {
        this.isModalOpenDelete = false;
    }

    submitDetailsDelete(){
        this.showSpinner = true;
        deleteAttende({junctionId: this.row, eventId: this.recordId })
            .then((results) => {
                
                refreshApex(this._wiredDataCXB);
                refreshApex(this._wiredDataClientes);
                refreshApex(this._wiredDataNoRegistrados);
            })
            .catch((error) => {
                console.log(error);
            }).finally(() => {
                this.showSpinner = false;
                this.isModalOpenDelete = false;
            })
    }

    submitDetails() {
        this.showSpinnerAdd = true;
        this.selectedAttendesToSend = [];
		if(this.attendeData.length > 0){
			this.attendeData.forEach(att =>{
				this.selectedAttendesToSend.push(att);
			});
		}
        processAsistentes({evt: this.recordId, asistentes: this.selectedAttendesToSend })
        .then((results) => {
            this.loading = true;
            refreshApex(this._wiredDataCXB);
            refreshApex(this._wiredDataClientes);
            refreshApex(this._wiredDataNoRegistrados);

        })
        .catch((error) => {
            console.log(error);
        })
        .finally(() => {
            this.añadirAttende = false;
            this.showSpinnerAdd = false;
            this.isModalOpen = false;
            
        })
    }

    @wire(getEvent, {recordId: '$recordId'})
    getEvent({ data, error }){
        if(data){
            this.selectedItem = data[0].AV_Tipo__c;
            this.accountId = data[0].AccountId;
        }else if(error){
            console.log(error);
        }
    }

    @wire(getAsistentesCXB, {recordId: '$recordId'})
    getAsistentesCXB(wiredData){
        this._wiredDataCXB = wiredData;
        const { data, error } = wiredData;
        if(data){
            this.dataCXB = data;

            this.dataCXB = data.map((item) => {
                const iconObj = {...item};
                if(item.estado == 'Accepted'){
                    iconObj.priorityicon = "utility:success" ;
                    iconObj.status = 'Aceptado';
                    iconObj.classEstado = 'classCheck'
                }else if(item.estado == 'Declined'){
                    iconObj.priorityicon = "utility:clear";
                    iconObj.status = 'Declinado';
                    iconObj.classEstado = 'classError'
                }else if (item.estado == 'New'){
                    iconObj.priorityicon = "utility:clock";
                    iconObj.status = 'Sin respuesta';
                }else if (item.estado == 'No enviado'){
                    iconObj.status = 'No enviado';
                }
                return iconObj;
                
            });
        }else if(error){
            console.log(error);
        }
    }

    @wire(getAsistentesClientes, {recordId: '$recordId'})
    getAsistentesClientes(wiredData){
        this._wiredDataClientes = wiredData;
        const { data, error } = wiredData;
        if(data){
            this.dataClientes = data;

            this.dataClientes = data.map((item) => {
				const iconObj = {...item};
                if(item.estado == 'Accepted'){
                    iconObj.priorityicon = "utility:success";
                    iconObj.status = 'Aceptado';
                }else if(item.estado == 'Declined'){
                    iconObj.priorityicon = "utility:clear";
                    iconObj.status = 'Declinado';
                }else if (item.estado == 'New'){
                    iconObj.priorityicon = "utility:clock";
                    iconObj.status = 'Sin respuesta';
                }else if (item.estado == 'No enviado'){
                    iconObj.status = 'No enviado';
                }
                return iconObj;
                
            });

        }else if(error){
            console.log(error);
        }
    }

    @wire(getAsistentesNoRegistrados, {recordId: '$recordId'})
    getAsistentesNoRegistrados(wiredData){
        this._wiredDataNoRegistrados = wiredData;
        const { data, error } = wiredData;
        if(data){
            this.dataNoRegistrados = data;

            this.dataNoRegistrados = data.map((item) => {
				const iconObj = {...item};
                if(item.estado == 'Accepted'){
                    iconObj.priorityicon = "utility:success";
                    iconObj.status = 'Aceptado';
                }else if(item.estado == 'Declined'){
                    iconObj.priorityicon = "utility:clear";
                    iconObj.status = 'Declinado';
                }else if (item.estado == 'New'){
                    iconObj.priorityicon = "utility:clock";
                    iconObj.status = 'Sin respuesta';
                }else if (item.estado == 'No enviado'){
                    iconObj.status = 'No enviado';
                }
                return iconObj;
                
            });

        }else if(error){
            console.log(error);
        }
    }

    handleSearchAttendes3(e){

		searchUserClientes({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedId, recordId: this.accountId})
			.then((results) => {
				this.template.querySelector('[data-id="attendeeslookupClientes"]').setSearchResults(results);
			})
			.catch((error) => {
                console.error(error);
				this.errors = [error];
			});
	}

	handleSelectionAttendee3(){
        let attendeeLookup = this.template.querySelector('[data-id="attendeeslookupClientes"]');
		let attendeeSelection = attendeeLookup.getSelection()[0];
		this.añadirAttende = true;
		attendeeLookup.handleClearSelection();

		if(attendeeSelection != null && attendeeSelection != undefined && this.selectedItem !== 'VLD'){
			this.buttonDisabled = false;
			this.selectedAttendes.push({
				id:attendeeSelection.id,
				name:attendeeSelection.title,
				email:attendeeSelection.subtitle,
				tipoAsistente: 'Cliente'
			}
			);
		}else if (attendeeSelection != null && attendeeSelection != undefined && this.selectedItem == 'VLD'){
			this.buttonDisabled = false;
			this.selectedAttendes.push({
				id:attendeeSelection.id,
				name:attendeeSelection.title,
				email:attendeeSelection.subtitle,
				tipoAsistente: 'Cliente',
				enviarCita: true
			}
			);
		}


		this.selectedAttendes.forEach(element => {

			if(this.selectedItem == 'VLD'){
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}else if(element.tipoAsistente == 'CaixaBank'){
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}

			var myId = element.id;
			this.selectedId = [...this.selectedId, myId];
			
			this.attendeData = [...this.attendeData, element];
			this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id );
		
		});

	}

    handleEmail(event){
		this.email = event.target.value;
        const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;    // expresión regular utilizada para validar el formato del correo electrónico    
		let isValidEmail = emailPattern.test(this.email); // comprueba que this.email cumple la expresión regular

		if(this.email != null && isValidEmail == true){
			this.buttonDisabled = false;
		}else{
            this.buttonDisabled = true;
		}
	}

    handleEmailEnter(){
		this.añadirAttende = true;
		let emailValue = this.template.querySelector('[data-id="email"]').value;
        let contador = Math.floor(Math.random() * 100);

		if(this.email != null && this.selectedItem !== 'VLD'){
			this.selectedAttendes.push({
				id:'Idprovisional' + contador,
				email:emailValue,
				tipoAsistente: 'No registrado',
                enviarCita: false
			}
			);
		}else if (this.email != null && this.selectedItem == 'VLD'){
			this.selectedAttendes.push({
				id:'Idprovisional'+ contador,
				email:emailValue,
				tipoAsistente: 'No registrado',
				enviarCita: true
			}
			);
		}

		this.selectedAttendes.forEach(element => {

			this.selectedId.push(element.id);

			if(this.selectedItem == 'VLD'){
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}else if(element.tipoAsistente == 'CaixaBank'){
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}
			
			this.attendeData = [...this.attendeData, element];
			this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id );
		
		});

        this.email = null;

	}

    handleEnter(event){
        const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;    // expresión regular utilizada para validar el formato del correo electrónico    
		let isValidEmail = emailPattern.test(this.email); // comprueba que this.email cumple la expresión regular
		if(event.keyCode === 13 && isValidEmail == true){
			this.handleEmailEnter();
            this.buttonDisabled = true;
		  }
	}

    handleSearchAttendes(e){

		searchCXB({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedId, recordId: this.recordId})
			.then((results) => {
				this.template.querySelector('[data-id="attendeeslookupCXB"]').setSearchResults(results);
			})
			.catch((error) => {
                console.error(error);
				this.errors = [error];
			});
	}
	
	handleSelectionAttendee(){

		let attendeeLookup = this.template.querySelector('[data-id="attendeeslookupCXB"]');
		let attendeeSelection = attendeeLookup.getSelection()[0];
		this.añadirAttende = true;
		attendeeLookup.handleClearSelection();

		if(attendeeSelection != null && attendeeSelection != undefined ){
			this.buttonDisabled = false;
			this.selectedAttendes.push({
				id:attendeeSelection.id,
				name:attendeeSelection.title,
				email:attendeeSelection.subtitle,
				tipoAsistente: 'CaixaBank',
				enviarCita: true
			}
			);
		}

		this.selectedAttendes.forEach(element => {

			if(this.selectedItem == 'VLD'){
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}else if(element.tipoAsistente == 'CaixaBank'){
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}

			var myId = element.id;
			this.selectedId = [...this.selectedId, myId];
			
			this.attendeData = [...this.attendeData, element];
			this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id );
		
		});

	}

    handleRowAction(event) {
		if (event.detail.action.name === 'delete') {
			this.attendeData = this.attendeData.filter((i) => i.email !== event.detail.row.email );

            if(this.attendeData.length <= 0){
                this.añadirAttende = false;
            }
		}else if(event.detail.action.name === 'deleteAttende'){
            this.row = event.detail.row.junctionId;
            this.isModalOpenDelete = true;
        }

	

	}

    @track selectedData = [];
    @track currentlySelectedData = [];

    handleRowSelection(event){

        switch (event.detail.config.action) {
            case 'selectAllRows':
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.selectedData.push(event.detail.selectedRows[i]);
                    this.currentlySelectedData.push(event.detail.selectedRows[i]);
                }
                this.selectedData.forEach(element => {
                    element.enviarCita = true;
                });
                break;
            case 'deselectAllRows':
                this.attendeData.forEach(element => {
                    element.enviarCita = false;
                });
                break;
            case 'rowSelect':
                this.selectedData.push(event.detail.config.value);
                const found = this.attendeData.find((element) => element.id == this.selectedData);
                found.enviarCita = true;

                break;
            case 'rowDeselect':
                this.selectedData.push(event.detail.config.value);
                const found2 = this.attendeData.find((element) => element.id == this.selectedData);
                found2.enviarCita = false;
                break;
            default:
                break;
        }

        this.selectedData = [];

	}

    handleSortDataCXB(event) {
        this.sortByFieldName = event.detail.fieldName;
        let sortField = event.detail.fieldName;
        for (let col of this.columnsCXB) {
            if (col.fieldName == this.sortByFieldName && col.type == 'url'){
                sortField = col.typeAttributes.label.fieldName;
            }else if (col.fieldName == this.sortByFieldName && col.type == 'text'){
                sortField = col.fieldName;
            }
        }

        this.sortDirection = event.detail.sortDirection;

        this.sortDataCXB(sortField, this.sortDirection);

    }


    sortDataCXB(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataCXB));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;
        this.dataCXB = parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.dataCXB.forEach(e => {
            console.log(e.nombreEmpleado);
        })

    }    

    handleSortDataClientes(event) {
        this.sortByFieldName = event.detail.fieldName;
        let sortField = event.detail.fieldName;
        for (let col of this.columnsCXB) {
            if (col.fieldName == this.sortByFieldName && col.type == 'url'){
                sortField = col.typeAttributes.label.fieldName;
            }else if (col.fieldName == this.sortByFieldName && col.type == 'text'){
                sortField = col.fieldName;
            }
        }

        this.sortDirection = event.detail.sortDirection;

        this.sortDataClientes(sortField, this.sortDirection);

    }


    sortDataClientes(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataClientes));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;
        this.dataClientes = parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.dataClientes.forEach(e => {
            console.log(e.nombreEmpleado);
        })

    } 
    
    handleSortDataNoRegistrados(event) {
        this.sortByFieldName = event.detail.fieldName;
        let sortField = event.detail.fieldName;
        for (let col of this.columnsCXB) {
            if (col.fieldName == this.sortByFieldName && col.type == 'text'){
                sortField = col.fieldName;
            }
        }

        this.sortDirection = event.detail.sortDirection;

        this.sortDataNoRegistrados(sortField, this.sortDirection);

    }


    sortDataNoRegistrados(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataNoRegistrados));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;
        this.dataNoRegistrados = parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.dataNoRegistrados.forEach(e => {
            console.log(e.nombreEmpleado);
        })

    } 

    sortBy(field, reverse, primer) {
        const key = primer
        ? function(x) {
        return primer(x[field]);
        }
        : function(x) {
        return x[field];
        };return function(a, b) {
        a = key(a);
        b = key(b);
         return reverse * ((a > b) - (b > a));
        };
        }

    handleClick(){
        this.añadirAttende = true;
        let attendeeLookup = this.template.querySelector('[data-id="attendeeslookupClientes"]');
        let attendeeLookup2 = this.template.querySelector('[data-id="attendeeslookupCXB"]');
        let email = this.template.querySelector('[data-id="email"]').value;
        attendeeLookup.handleClearSelection();
        attendeeLookup2.handleClearSelection();
        this.buttonDisabled = true;
        let contador = Math.floor(Math.random() * 100);

        if(this.email != null && this.selectedItem !== 'VLD'){
            this.selectedAttendes.push({
                id:'Idprovisional' + contador,
                email:email,
                tipoAsistente: 'No registrado'
            }
            );
        }else if (this.email != null && this.selectedItem == 'VLD'){
            this.selectedAttendes.push({
                id:'Idprovisional' + contador,
                email:email,
                tipoAsistente: 'No registrado',
                enviarCita: true
            }
            );
        }


        this.selectedAttendes.forEach(element => {

            if(this.selectedItem == 'VLD'){
                var myId = element.id;
                this.preSelectedRows = [...this.preSelectedRows, myId];
            }else if(element.tipoAsistente == 'CaixaBank'){
                var myId = element.id;
                this.preSelectedRows = [...this.preSelectedRows, myId];
            }
            
            this.attendeData = [...this.attendeData, element];
            this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id );
        
        });

        this.email = null;

    }    


}