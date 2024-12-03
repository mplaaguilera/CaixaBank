import { api, LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';




//methods
import createProductCIB					  	   from '@salesforce/apex/CIBE_EventProductsCIBController.createProductCIB';
import deleteProductCIB					  	   from '@salesforce/apex/CIBE_EventProductsCIBController.deleteProductCIB';
import getProductosCita					  	   from '@salesforce/apex/CIBE_EventProductsCIBController.getProductosCita';
import searchFamily from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.searchFamily';
import searchProductsCIB from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.search';

//labels
import producto from '@salesforce/label/c.CIBE_Producto';
import familia from '@salesforce/label/c.CIBE_Familia';
import buscarFamilia from '@salesforce/label/c.CIBE_BuscarFamilia';
import buscarProducto from '@salesforce/label/c.CIBE_BuscarProductos';
import anyadir from '@salesforce/label/c.CIBE_Add';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import errorActualizandoEvento from '@salesforce/label/c.CIBE_ErrorActualizandoEvento';
import eventoActualizado from '@salesforce/label/c.CIBE_EventoActualizado';
import eventoActualizadoCorrectamente from '@salesforce/label/c.CIBE_EventoActualizadoCorrectamente';
import eliminarProducto from '@salesforce/label/c.CIBE_EliminarProducto';
import eliminarProducto2 from '@salesforce/label/c.CIBE_DeseaEliminarProducto';
import nuevoProducto from '@salesforce/label/c.CIBE_NuevoProducto';
import productosVinculados from '@salesforce/label/c.CIBE_ProductosVinculados';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import guardar from '@salesforce/label/c.CIBE_Guardar';



export default class Cibe_EventProductsCIB extends LightningElement {

    labels = {
        producto,
        familia,
        buscarFamilia,
        buscarProducto,
        anyadir,
        comentario,
        eventoActualizado,
        eventoActualizadoCorrectamente,
        errorActualizandoEvento,
        eliminarProducto,
        eliminarProducto2,
        nuevoProducto,
        productosVinculados,
        cancelar,
        guardar

        
    }


    @track productData = [];
    @api recordId;
    @track addProduct = false;
    @track productComment;
    @track selectedIdFamilia =[];
	@track selectedFamilia = [];
	@track selectedIdProduct =[];
	@track selectedProduct = [];
    @track buttonDisabled = true;
    @track isModalOpenDelete = false;
    @track idCitaRelacionada;
    @track _wiredData;
    @track loading = false;
    data = false;
    dataProduct = false;
    @track producto;
	@track initialSelection = [];
	@track valueSubProducto;

    @wire(getProductosCita, {recordId: '$recordId'})
    getProductosCita(wireResult){
        this._wiredData = wireResult;
        const { data, error } = wireResult;

        if(data){
            this.dataProduct = data.length == 0 ? false : true;
            let options = [];
            for (var key in data) {
                options.push({ 
                    idFamilia:data[key].CIBE_Producto__r?.CIBE_Familia__c,
                    nameFamilia:data[key].CIBE_Producto__r?.CIBE_Familia__r.Name,
                    idProducto:data[key].CIBE_Producto__c,
                    nameProducto: data[key].CIBE_Producto__r?.Name,
                    comentario: data[key].CIBE_Comentario__c,
                    Id: data[key].Id
                });
            }
            this.productData = options;
        }else if(error){
            console.log(error);
        }
    }

    handleRowActionProduct(event) {
        this.isModalOpenDelete = true;
		if (event.detail.action.name === 'deleteProduct') {
            this.idCitaRelacionada = event.detail.row.Id;
		}
	}

    submitDetails(){
        this.isModalOpenDelete = false;
        this.loading = true;
        deleteProductCIB({recordId : this.idCitaRelacionada })
        .then((results => {
            refreshApex(this._wiredData)
            .finally(() => {
                this.loading = false;
            });


            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.eventoActualizado,
                    message: this.labels.eventoActualizadoCorrectamente,
                    variant: 'success'
                })
            );
        }))
        .catch((error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.eventoActualizado,
                    message: this.labels.errorActualizandoEvento,
                    variant: 'error'
                })
            );
            console.log(error);
        }))
    }

    columnsProduct = [
		{ label: this.labels.familia, fieldName: 'nameFamilia' },
		{ label: this.labels.producto, fieldName: 'nameProducto'  },
		{ label: this.labels.comentario, fieldName: 'comentario', type: 'text', wrapText: true},
		{ label: '', type: 'button-icon', typeAttributes: { iconName: 'utility:delete',name: 'deleteProduct' }, initialWidth : 80 },
	];

    handleAddProduct(){
        this.addProduct = true;

    }

    handleSearchFamily(e){
		searchFamily({searchTerm: e.detail.searchTerm, producto: this.valueSubProducto})
			.then((results) => {
				console.log(results);
				this.template.querySelector('[data-id="familySearch"]').setSearchResults(results);
			})
			.catch((error) => {
                console.error(error);
				this.errors = [error];
			});
	}

	handleFamily(event){
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		this.buttonDisabled = false;

		if(selection.length !== 0){
				for(let sel of selection) {
					this.producto  = String(sel.id);
				}
		} else {
			this.producto = null;
			this.template.querySelector('[data-id="familySearch"]').selection = [];
            this.template.querySelector('[data-id="familySearch"]').handleBlur();
		}
		this.template.querySelector('[data-id="familySearch"]').handleBlur();
	}

    handleSearchFamilyClick(e) {
        if (this.producto == null) {
           searchFamily({searchTerm: e.detail.searchTerm, producto: null})
           .then((results) => {
               console.log(results);
               this.template.querySelector('[data-id="familySearch"]').setSearchResults(results);
           })
           .catch((error) => {
               console.error(error);
               this.errors = [error];
           });
       }
       
   }

    handleSearchProduct(e){
		searchProductsCIB({ searchTerm: e.detail.searchTerm, familia: this.producto})
			.then((results) => {
				this.template.querySelector('[data-id="productSearch"]').setSearchResults(results);
			})
			.catch((error) => {
                console.error(error);
				this.errors = [error];
			});
	}

    

	handleProduct(event){
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		this.buttonDisabled = false;

		if(selection.length !== 0){
				for(let sel of selection) {
					this.valueSubProducto  = String(sel.id);
				}
                this.autoSelectFamily(this.valueSubProducto);
		} else {
			this.valueSubProducto = null;
            this.template.querySelector('[data-id="productSearch"]').handleBlur();
		}
	}

    autoSelectFamily(valueProducto){
        searchFamily ({searchTerm: '', producto: valueProducto})
            .then((results) => {
                    let targetId = results[0].id;           
                    this.producto  = targetId;       
                    this.template.querySelector('[data-id="familySearch"]').selection = results[0];
            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleSearchProductClick(e) {
		if(this.valueSubProducto == null){
			searchProductsCIB({searchTerm: e.detail.searchTerm,familia: this.producto})
			.then((results) => {
				console.log(results);
				this.template.querySelector('[data-id="productSearch"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
		}
		
	}

    handleProdComment(event){
		this.productComment = event.target.value
	}

    handleClickProduct(){
		this.añadirProduct = true;
		let familylookup = this.template.querySelector('[data-id="familySearch"]');
		let familySelection = familylookup.getSelection()[0];
		let productlookup = this.template.querySelector('[data-id="productSearch"]');
		let productSelection = productlookup.getSelection()[0];
		this.buttonDisabled = true;

		this.template.querySelector('lightning-input[data-id="comentarioProduct"]').value = '';

		familylookup.handleClearSelection();
		productlookup.handleClearSelection();

		if((familySelection != null && familySelection != undefined) && (productSelection != null && productSelection != undefined) ){
			this.selectedProduct.push({
				idFamilia:familySelection.id,
				nameFamilia:familySelection.title,
				idProducto:productSelection.id,
				nameProducto: productSelection.title,
                comentario: this.productComment
			}
			);
		}
		this.selectedProduct.forEach(element => {
			this.productData = [...this.productData, element];	
            //this.selectedProduct = this.selectedProduct.filter((i) => i.idProducto !== element.idProducto );	
        });

        this.createProduct();
        this.selectedProduct = [];
        this.productComment = null;

        //refreshApex(this._wiredData);

	}


    createProduct(){
		createProductCIB({takedProducts:this.selectedProduct, evt:this.recordId})
		.then(result =>{
            refreshApex(this._wiredData)
            .finally(() => {
                this.loading = false;
            });
		}).catch(error => {
			console.log(error)
		})
	}

    closeModal(){
        this.isModalOpenDelete = false;
    }

    refreshCmp(){
        //this._wiredData = [];
        refreshApex(this._wiredData);
        //window.location.reload();
    }
}