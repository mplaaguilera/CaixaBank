import { LightningElement, api, track, wire } from 'lwc';
import searchEmployees from '@salesforce/apex/EV_lookupEmployees_Controller.searchEmployees';
import getCentrosHierarchy from '@salesforce/apex/EV_lookupEmployees_Controller.getCentrosHierarchy';
import getDirectGestContactIds from '@salesforce/apex/EV_lookupEmployees_Controller.getDirectGestContactIds';

/**
 *  VERSION     AUTHOR             USER_STORY           DATE               Description
 *   1.0        Carolina Lopez     US680535             14/08/2023         Init version
 *   1.1        Carolina Lopez     US680535             14/08/2023         Add user filtering logic to avoid showing records that were already selected,
 *                                                                         delete record with buttons, mouse management functionality.
 *   1.2        Carolina Lopez     US680535             23/08/2023         Add corfirmation popup delete all seleted records, add data summary layout and data transfer between components.
 *   1.3        Carolina Lopez     US680535             25/08/2023         Add page records up to 100
 *   1.4        Carolina Lopez     US704873             28/09/2023         Add responsanility filtering logic for summary
 *   1.5        Humberto Vilchez   US704873             04/10/2023         Change filter table for summary
 **/

const columnCentro = [
    {
      fieldName: "Name",
      label: "Nombre"
    },
    {
        fieldName: "BillingState",
        label: "Provincia"
    }
  ];

const columnContact = [
    {
      fieldName: "Name",
      label: "Nombre"
    },
    {
        fieldName: "CC_Nombre_Oficina__c",
        label: "Oficina"
    },
    {
        fieldName: "AV_Responsabilidad__c",
        label: "Responsabilidad"
    }
  ];

export default class Ev_lwc_lookupEmployees extends LightningElement {

    optionsUpdate = [];
    filteredData = [];
    selectedOptions = [];
 
    responsabilidadValue = [];
    @api campaignName = '';
    @api inputValue = 0;
    @api inputAforo = 0;
    @api estadoFilter = '';
    @api valueAsign='';
    @api labelName = 'Asignación individual';
    @api placeholder = 'Buscar Usuarios';
    employeesFound = [];

    @track isModalOpen = false;

    //Contacto
    @track currentPage = 1;
    @track recordsPerPage = 100;
    //Centro
    @track recordsPerPageCentro = 10;
    @track currentPageCentro = 1;
    //Individual
    @track currentPageInd = 1;
    @track recordsPerPageInd = 100;


    @api employeesToSelected = [];
    employeesToSelectedConst = [];
    nameToSearch;
    selectedRecord = false;
    selectedIsSelected = false;
    
    @api isCentros = false;
    @api isIndividual = false;
    @api isResponsabilidad = false;

    ICON_URL = '/apexpages/slds/latest/assets/icons/standard-sprite/svg/symbols.svg#contact';
    ICON_SEARCH_URL = '/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#search';

    @api showFirstPage = false;
    @api showSecondPage = false;
    @api showThirdPage = false;

    @track hierarchy = [];
    columnCentro = columnCentro;
    columnContact = columnContact;
    
    gridData = [];
    @track selectedTreeGRows    = [];
    @track selectedOfficeList    = [];
    @track expandedTreeGRows    = [];
    contactCentrosSelected      = [];    
    contactIdsList              = [];

    hierarchyMap5 = new Map();
    hierarchyMap4 = new Map();
    hierarchyMap3 = new Map();
    hierarchyMap2 = new Map();
    hierarchyMap1 = new Map();
    hierarchyMap0 = new Map();

    showDropdown = false;

    selectedItems = [];
    @track selectionlimit;
    @track searchTerm = '';
    @track showsApliBtn = false;
    @track showselectall = false;
    @track itemcounts = 'Ninguna responsabilidad seleccionada';
    @track errors;

    connectedCallback(){
        if(!this.isIndividual){
            this.wiredAccounts();
        }        
    }


    wiredAccounts() {
        this.isLoading = true;

		getCentrosHierarchy()
			.then(result => {
				if (result != null) {
                    this.buildHierarchy(result);                    
                } else {
                    this.isLoading = false;
                }
            });
    } 

    buildHierarchy(data) {

        let hierarchyMapFinalValues = [];

        let hierarchyList4 = new Set();
        let hierarchyList3 = new Set();
        let hierarchyList2 = new Set();
        let hierarchyList1 = new Set();

        let hierarchyIdsList4 = new Set();
        let hierarchyIdsList3 = new Set();
        let hierarchyIdsList2 = new Set();
        let hierarchyIdsList1 = new Set();

        let hierarchyParnetsList = [];
        let hierarchyParnetsListId = new Set();
        
        let strData = JSON.parse(JSON.stringify(data));

        strData.forEach(account => {
            account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id = account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id + 'V5';
            account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id = account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id + 'V4';
            account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id = account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id + 'V3';
            account.AV_CentroSuperior__r.Id = account.AV_CentroSuperior__r.Id + 'V2'

            if(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c != null && 
                !hierarchyParnetsListId.has(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id)){                        
                    hierarchyParnetsListId.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id );                
                    hierarchyParnetsList.push(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r);
            }          

            //V5
            if(this.hierarchyMap4.has( account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id)){                
                if(!hierarchyIdsList4.has(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id)){
                    hierarchyIdsList4.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id);    
                    hierarchyList4 = this.hierarchyMap4.get(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id);
                    hierarchyList4.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r);    
                    this.hierarchyMap4.set(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id, hierarchyList4);                               
                }                    
            } else {
                hierarchyIdsList4 = new Set();
                hierarchyList4 = new Set();
                hierarchyIdsList4.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id);    
                hierarchyList4.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r);
                this.hierarchyMap4.set(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id, hierarchyList4); 
            }

            //V4
            if(this.hierarchyMap3.has( account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id)){                
                if(!hierarchyIdsList3.has(account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id)){
                    hierarchyIdsList3.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id);    
                    hierarchyList3 = this.hierarchyMap3.get(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id);
                    hierarchyList3.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r);    
                    this.hierarchyMap3.set(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id, hierarchyList3);                               
                }                    
            } else {
                hierarchyIdsList3 = new Set();
                hierarchyList3 = new Set();
                hierarchyIdsList3.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id);    
                hierarchyList3.add(account.AV_CentroSuperior__r.AV_CentroSuperior__r);
                this.hierarchyMap3.set(account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.Id, hierarchyList3); 
            }

            if(this.hierarchyMap2.has( account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id)){

                if(!hierarchyIdsList2.has(account.AV_CentroSuperior__r.Id)){
                    hierarchyIdsList2.add(account.AV_CentroSuperior__r.Id);   
                    hierarchyList2 = this.hierarchyMap2.get(account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id);
                    hierarchyList2.add(account.AV_CentroSuperior__r);
                    this.hierarchyMap2.set(account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id, hierarchyList2);
                }
                
            } else {
                hierarchyIdsList2   = new Set();
                hierarchyList2      = new Set();
                hierarchyIdsList2.add(account.AV_CentroSuperior__r.Id);    
                hierarchyList2.add(account.AV_CentroSuperior__r);
                this.hierarchyMap2.set(account.AV_CentroSuperior__r.AV_CentroSuperior__r.Id, hierarchyList2); 
            }

            if(this.hierarchyMap1.has( account.AV_CentroSuperior__r.Id)){
                if(!hierarchyIdsList1.has(account.Id)){
                    hierarchyIdsList1.add(account.Id);   
                    hierarchyList1 = this.hierarchyMap1.get(account.AV_CentroSuperior__r.Id);
                    hierarchyList1.add(account);
                    this.hierarchyMap1.set(account.AV_CentroSuperior__r.Id, hierarchyList1);
                }
            } else {                
                hierarchyIdsList1   = new Set();
                hierarchyList1      = new Set();
                hierarchyIdsList1.add(account.Id);   
                hierarchyList1.add(account);
                this.hierarchyMap1.set(account.AV_CentroSuperior__r.Id, hierarchyList1); 
            }

        });            

        let idRow4List = [];
        let idRow3List = [];
        let idRow2List = [];
        let idRow1List = [];   

        for (const row of hierarchyParnetsList) {

            let rowAux = {
                Id: row.Id,
                Name: row.Name,
                BillingState: row.BillingState,
                Contact: row.AV_EAPGestor__r,
                _children: []
            };
            
            
            for (const row4 of this.hierarchyMap4.get(row.Id)){

                if(!idRow4List.includes(row4.Id)){
                    rowAux._children.push({
                        Id: row4.Id,
                        Name: row4.Name,
                        BillingState: row4.BillingState,
                        _children: []
                    });
                    idRow4List.push( row4.Id );
                }     



                for (const row3 of this.hierarchyMap3.get(row4.Id)){
                    rowAux._children.map((rowAux2, index) => {
                        if(rowAux2.Id == row3.AV_CentroSuperior__r.Id){
                        if(!idRow3List.includes(row3.Id)){
                            rowAux2._children.push({
                            Id: row3.Id,
                            Name: row3.Name,
                            BillingState: row3.BillingState,
                            _children: []
                        });
                        idRow3List.push( row3.Id );
                    }                         

                    for (const row2 of this.hierarchyMap2.get(row3.Id)){

                        rowAux2._children.map((rowAux1, index) => {
                            if(rowAux1.Id == row2.AV_CentroSuperior__r.Id){

                                if(!idRow2List.includes(row2.Id)){
                                    rowAux1._children.push({
                                        Id: row2.Id,
                                        Name: row2.Name,
                                        BillingState: row2.BillingState,
                                        _children: []
                                    });
                                idRow2List.push( row2.Id);
                                

                                for (const row1 of this.hierarchyMap1.get(row2.Id)){
                                    
                                    rowAux1._children.map((element, index) => {
                                        if(element.Id == row1.AV_CentroSuperior__r.Id){
                                            if(!idRow1List.includes(row1.Id)){
                                                element._children.push({
                                                    Id: row1.Id,
                                                    Name: row1.Name,
                                                    BillingState: row1.BillingState
                                                });
                                            idRow1List.push( row1.Id);
                                            }
                                        }
                                    });

                                };// END FOR MAP 1
                                }// END FOR MAP 1

                            }
                        });  // END FOR MAP 2                
                    } // END FOR MAP 2     
                    

                }
                });  // END FOR MAP 3                               
                } //END FOR MAP3


            } //END FOR MAP4


            hierarchyMapFinalValues.push(rowAux);
        }      
        
        this.gridData = hierarchyMapFinalValues;

        this.isLoading = false;
    }


    handleRowSelection(event) {   
        this.isLoading = true;
        this.showSecondPage = false;
        let filterListDeselected = [];
        let infoDeseselect = event.detail.config;               

        if(infoDeseselect.action == 'rowDeselect'){
            filterListDeselected = this.selectedTreeGRows;
            filterListDeselected = this.selectedTreeGRows.filter(item => item !== infoDeseselect.value);

            if(infoDeseselect.value.includes("V5")){           

                this.hierarchyMap4.get(infoDeseselect.value).forEach((centro) => {
                    filterListDeselected = filterListDeselected.filter(item => item !== centro.Id);
                    
                    this.hierarchyMap3.get(centro.Id).forEach((centro1) => {
                        filterListDeselected = filterListDeselected.filter(item => item !== centro1.Id);
                        
                        this.hierarchyMap2.get(centro1.Id).forEach((centro2) => {
                            filterListDeselected = filterListDeselected.filter(item => item !== centro2.Id);

                            this.hierarchyMap1.get(centro2.Id).forEach((centro3) => {
                                filterListDeselected = filterListDeselected.filter(item => item !== centro3.Id);     
                                this.selectedOfficeList = this.selectedOfficeList.filter(item => item !== centro3.Id);                                                
                            });
                        });
                    });  
                });  

            } else if(infoDeseselect.value.includes("V4")){           
                this.hierarchyMap3.get(infoDeseselect.value).forEach((centro1) => {
                    filterListDeselected = filterListDeselected.filter(item => item !== centro1.Id);
                    
                    this.hierarchyMap2.get(centro1.Id).forEach((centro2) => {
                        filterListDeselected = filterListDeselected.filter(item => item !== centro2.Id);

                        this.hierarchyMap1.get(centro2.Id).forEach((centro3) => {
                            filterListDeselected = filterListDeselected.filter(item => item !== centro3.Id);     
                            this.selectedOfficeList = this.selectedOfficeList.filter(item => item !== centro3.Id);                                                
                        });
                    });
                });  

            } else if(infoDeseselect.value.includes("V3")){           
                this.hierarchyMap2.get(infoDeseselect.value).forEach((centro2) => {                    
                    filterListDeselected = filterListDeselected.filter(item => (item !== centro2.Id ));
                    //level 3
                    this.hierarchyMap1.get(centro2.Id).forEach((centro3) => {
                        filterListDeselected = filterListDeselected.filter(item => item !== centro3.Id);   
                        this.selectedOfficeList = this.selectedOfficeList.filter(item => item !== centro3.Id);                                                  
                    });
                });

            } else if(infoDeseselect.value.includes("V2")){           
                this.hierarchyMap1.get(infoDeseselect.value).forEach((centro3) => {
                    
                    filterListDeselected = filterListDeselected.filter(item => item !== centro3.Id);   

                    this.selectedOfficeList = this.selectedOfficeList.filter(item => item !== centro3.Id);                                 
                });

            } else {
                this.selectedOfficeList = this.selectedOfficeList.filter(item => item !== infoDeseselect.value);                                                
            }    

            this.selectedTreeGRows = filterListDeselected;

        } else if(infoDeseselect.action == 'rowSelect') {
            const selectedRows = event.detail.selectedRows;

                if(selectedRows.length > 0){

                    selectedRows.forEach((centro) => {
                        if(!this.selectedTreeGRows.includes(centro.Id)){
                            this.selectedTreeGRows.push(centro.Id);
                        }  
                        if(centro.level === 1){
                            this.hierarchyMap4.get(centro.Id).forEach((centro3) => {
                                if(!this.selectedTreeGRows.includes(centro3.Id)){
                                    this.selectedTreeGRows.push(centro3.Id);
                                } 
                                
                                this.hierarchyMap3.get(centro3.Id).forEach((centro2) => {   
                                    if(!this.selectedTreeGRows.includes(centro2.Id)){
                                        this.selectedTreeGRows.push(centro2.Id);
                                    }                                                          
                                    //level 3
                                    this.hierarchyMap2.get(centro2.Id).forEach((centro3) => {   
                                        if(!this.selectedTreeGRows.includes(centro3.Id)){
                                            this.selectedTreeGRows.push(centro3.Id);
                                        }                                                          
                                        //level 4
                                        this.hierarchyMap1.get(centro3.Id).forEach((centro4) => {
                                            if(!this.selectedOfficeList.includes(centro4.Id)){
                                                this.selectedOfficeList.push(centro4.Id);
                                            }
                                        });
                                    
                                    });
    
                                });
                            });       
                        } else if(centro.level === 2){  
                                //level 2
                            this.hierarchyMap3.get(centro.Id).forEach((centro2) => {   
                                if(!this.selectedTreeGRows.includes(centro2.Id)){
                                    this.selectedTreeGRows.push(centro2.Id);
                                }                                                          
                                //level 3
                                this.hierarchyMap2.get(centro2.Id).forEach((centro3) => {   
                                    if(!this.selectedTreeGRows.includes(centro3.Id)){
                                        this.selectedTreeGRows.push(centro3.Id);
                                    }                                                          
                                    //level 4
                                    this.hierarchyMap1.get(centro3.Id).forEach((centro4) => {
                                        if(!this.selectedOfficeList.includes(centro4.Id)){
                                            this.selectedOfficeList.push(centro4.Id);
                                        }
                                    });
                                
                                });

                            });
                        //END LEVEL 2
                        } else if(centro.level === 3){   

                            this.hierarchyMap2.get(centro.Id).forEach((centro3) => {   
                                if(!this.selectedTreeGRows.includes(centro3.Id)){
                                    this.selectedTreeGRows.push(centro3.Id);
                                }                                                          
                                //level 4
                                this.hierarchyMap1.get(centro3.Id).forEach((centro4) => {
                                    if(!this.selectedOfficeList.includes(centro4.Id)){
                                        this.selectedOfficeList.push(centro4.Id);
                                    }
                                });

                            });
                        //END LEVEL 3
                        } else if(centro.level === 4){ 
                            this.hierarchyMap1.get(centro.Id).forEach((centro4) => {
                                if(!this.selectedOfficeList.includes(centro4.Id)){
                                    this.selectedOfficeList.push(centro4.Id);
                                }
                            });
                        //END LEVEL 4
                        } else {
                            if(!this.selectedOfficeList.includes(centro.Id)){
                                this.selectedOfficeList.push(centro.Id);
                            }                        
                        }            

                    });
                    this.selectedOfficeList.forEach((oficinasId) => {
                        if(!this.selectedTreeGRows.includes(oficinasId)){
                            this.selectedTreeGRows.push(oficinasId);
                        }
                    });                                          

                } else {
                }
        } else if(infoDeseselect.action == 'deselectAllRows') {
            this.selectedOfficeList = [];
            this.selectedTreeGRows = [];                    
        } else if(infoDeseselect.action == 'selectAllRows') {
            let selectedRowKeysV = event.detail.selectedRows.filter(item => item.level == '1');
            selectedRowKeysV.forEach((centro) => {
                if(!this.selectedTreeGRows.includes(centro.Id)){
                    this.selectedTreeGRows.push(centro.Id);
                }  
                if(centro.level === 1){
                    this.hierarchyMap4.get(centro.Id).forEach((centro3) => {
                        if(!this.selectedTreeGRows.includes(centro3.Id)){
                            this.selectedTreeGRows.push(centro3.Id);
                        } 
                        
                        this.hierarchyMap3.get(centro3.Id).forEach((centro2) => {   
                            if(!this.selectedTreeGRows.includes(centro2.Id)){
                                this.selectedTreeGRows.push(centro2.Id);
                            }                                                          
                            //level 3
                            this.hierarchyMap2.get(centro2.Id).forEach((centro3) => {   
                                if(!this.selectedTreeGRows.includes(centro3.Id)){
                                    this.selectedTreeGRows.push(centro3.Id);
                                }                                                          
                                //level 4
                                this.hierarchyMap1.get(centro3.Id).forEach((centro4) => {
                                    if(!this.selectedOfficeList.includes(centro4.Id)){
                                        this.selectedOfficeList.push(centro4.Id);
                                    }
                                });
                            
                            });

                        });
                    });       
                }

            });
                              
        }

            
        if(this.selectedOfficeList.length > 0 && infoDeseselect.action){
            this.getDirectContacts();   
        } else {
            this.employeesToSelected = [];
            this.optionsUpdate = [];
            this.dispatchEmployeeList(this.employeesToSelected);
        }

        setTimeout(() => {
            this.showSecondPage = true;
            this.isLoading = false;
        }, 5);
     
    }

    getDirectContacts() {  

        getDirectGestContactIds({
            officeList          : JSON.stringify(this.selectedOfficeList),
            isCentros           : this.isCentros,
            isResponsabilidad   : this.isResponsabilidad
        })
			.then(result => { 
				if (result) {                 
                    this.employeesToSelected = result
                    this.employeesToSelectedConst = result                    
                    this.optionsUpdate = this.responsabilidadOptions;
                    this.filteredData = this.employeesToSelected;
                    this.dispatchEmployeeList(this.employeesToSelected);
                    this.selectionlimit = this.optionsUpdate.length;                         
                } 
            });
    } 

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.showDropdown = true;
        this.mouse = false;
        this.focus = false;
        this.blurred = false;
        if (this.selectedItems.length !== 0) {
            if (this.selectedItems.length >= this.selectionlimit) {
                this.showDropdown = false;
            }
        }
    }


    get filteredResults() {
        if (this.responsabilidadOptions.length > 0) {
            if (this.responsabilidadOptions) {
                const selectedProfileNames = this.selectedItems.map(resp => resp.value);
                return this.responsabilidadOptions.map(resp => {
                    const isChecked = selectedProfileNames.includes(resp.value);
                    return {
                        ...resp,
                        isChecked
                    };
                }).filter(resp =>
                    resp.value.toLowerCase().includes(this.searchTerm.toLowerCase())
                ).slice(0, 20);
            } else {
                return [];
            }
        }
    }


    handleSelection(event) {
        const selectedResponsabilityId = event.target.value;
        const isChecked = event.target.checked;

        if (this.selectedItems.length < this.selectionlimit) {

            if (isChecked) {
                const selectedResponsability = this.responsabilidadOptions.find(resp => resp.value === selectedResponsabilityId);
                if (selectedResponsability) {
                    this.selectedItems = [...this.selectedItems, selectedResponsability];
                }
            } else {
                this.selectedItems = this.selectedItems.filter(resp => resp.value !== selectedResponsabilityId);
                if (this.selectedItems.length === 0) {
                    this.showsApliBtn = false;
                }
            }
        } else {

            if (isChecked) {
                this.showDropdown = false;
                this.showselectall = false;
                this.errormessage();
            } else {
                this.selectedItems = this.selectedItems.filter(resp => resp.value !== selectedResponsabilityId);
            }

        }

        if (this.selectedItems.length > 0 && !this.showsApliBtn){
            this.showsApliBtn = true;
        }

        this.itemcounts = this.selectedItems.length > 0 ? this.selectedItems.length +  ' Responsabilidades seleccionadas' : 'Ninguna responsabilidade seleccionado'

    }

    handleclearall(event) {
        event.preventDefault();
        this.showDropdown = false;
        this.showselectall = false;
        this.selectedItems = [];
        this.allValues = [];
        this.itemcounts = 'Ninguna responsabilidad seleccionada';
        this.searchTerm = '';
        this.handleFilterNegocio();
    }

    selectall(event) {
        if (this.responsabilidadOptions) {
            this.selectedItems = [];
            this.responsabilidadOptions.forEach(item =>{
                item.isChecked = true
                this.selectedItems.push(item);
            });
       
            this.itemcounts = this.selectedItems.length + 'Responsabilidades seleccionadas';
            this.showsApliBtn = true;
        }

    }

    handleRemove(event) {
        const valueRemoved = event.target.name;
        this.selectedItems = this.selectedItems.filter(res => res.value !== valueRemoved);
        this.itemcounts = this.selectedItems.length > 0 ? this.selectedItems.length + ' Responsabilidades seleccionadas' : 'Ninguna responsabilidad seleccionada';        
        this.handleFilterNegocio();
    }

    clickhandler(event) {
        this.mouse = false;
        this.showDropdown = true;
        this.clickHandle = true;
        this.showselectall = true;
    }

    focuhandler(event) {
        this.focus = true;
    }

    blurhandler(event) {
        this.blurred = true;
        this.dropdownclose();
    }

    dropdownclose() {
        if (this.mouse == true && this.blurred == true && this.focus == true) {
            this.searchTerm = '';
            this.showDropdown = false;
            this.clickHandle = false;
        }
    }
    
    handleExpandedRow(event) {        
        let idRowExpanded = event.detail.name;        
        if(!this.expandedTreeGRows.includes(idRowExpanded)){
            this.expandedTreeGRows.push(idRowExpanded);
        } else {
            this.expandedTreeGRows = this.expandedTreeGRows.filter(item => item !== idRowExpanded);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'selectRow') {
            this.data = this.data.map(item =>
                item.Id === row.Id ? { ...item, isChecked: !item.isChecked } : item
            );
        }
    }

    get responsabilidadOptions() {

        const allResponsabilities = this.employeesToSelectedConst.map((option) => option.AV_Responsabilidad__c);
        const uniqueResponsabilities = [...new Set(
            allResponsabilities
                .filter(responsability => responsability && responsability.trim() !== '')
                .map(responsability => responsability.toLowerCase())
        )];
        const opt = uniqueResponsabilities.map((responsability) => ({
            label: responsability.charAt(0).toUpperCase() + responsability.slice(1),
            value: responsability, 
            isChecked: false, 
            estilo: ''
        }));

        return opt;
        
    }

    handleResponsabilidadClick(event) {
        const optionValue = String(event.target.value);
        const index = this.selectedOptions.indexOf(optionValue);
        if (index !== -1) {
            this.selectedOptions.splice(index, 1);
        } else {
            this.selectedOptions.push(optionValue);
        }
        this.updateOptionStyles();
        
    }

    handleResponsabilidadChange() { 
        this.updateOptionStyles();
    }

    updateOptionStyles() {
        const selectElement = this.template.querySelector('select');
        const options = selectElement.options;
        for (let i = 0; i < options.length; i++) {
            const option = options[i];
            const optionValue = option.value;
            option.style.backgroundColor = this.selectedOptions.includes(optionValue) ? '#0070d2' : 'transparent';
        }
        if (selectElement) {
            selectElement.blur(); 
        }
    }

    handleFilterNegocio() {

        if(this.selectedItems.length > 0){
            const selectedOptionsLower = [];
            this.selectedItems.forEach(option => selectedOptionsLower.push(option.value.toLowerCase()));

            const filteredOptions = this.filteredData.filter(option => {
                return selectedOptionsLower.includes(option.AV_Responsabilidad__c.toLowerCase());
            });
            this.employeesToSelected = filteredOptions;  

            this.currentPage = 1; 
        } else {
            this.employeesToSelected = this.employeesToSelectedConst;  
        }

        this.dispatchEmployeeList(this.employeesToSelected);
    }

    

    // Método para mandar el evento con la lista de empleados
    dispatchEmployeeList(empleado) {

        const employeeListEvent = new CustomEvent('employeelistchange', {
            detail: empleado
        });
        this.dispatchEvent(employeeListEvent);
    }

    get valueAsign() {
        return this.employeesToSelected.length;
    }

    handleInputChange(event){
        this.nameToSearch = event.target.value;
        searchEmployees({ 
            valueIn     : this.nameToSearch                    
        })
        .then(result => {
            this.employeesFound = result.filter(contact => 
                !this.employeesToSelected.some(selected => selected.Id === contact.Id)
            );
        })
        .catch(error => {
            console.error('Error:', error);
        })
        .finally( ()=>{
        });
    }

    handleSelect(event){
        let recordId  = event.currentTarget.dataset.recordId;
        let contactSelected = this.employeesFound.filter((contact) => contact.Id == recordId );

        if(contactSelected){
            this.employeesToSelected.push(contactSelected[0]);
            this.selectedIsSelected = true;

            const updatedEmployees = this.employeesToSelected.map(record => {
                if (record.Id === recordId) {
                    return { ...record, iconName: 'utility:check' };
                }
                return record;
            });
            this.employeesToSelected = updatedEmployees;
 
            this.dispatchEmployeeList(this.employeesToSelected);
        }
        this.employeesFound = [];

    }
    
    handleMouseOverIcon(event) {
        const recordId = event.currentTarget.dataset.key;
        const updatedEmployees = this.employeesToSelected.map(record => {
            if (record.Id === recordId) {
                return { ...record, iconName: 'utility:dash' };
            }
            return record;
        });
        this.employeesToSelected = updatedEmployees;
    }

    handleMouseOutIcon(event) {
        const recordId = event.currentTarget.dataset.key;
        const updatedEmployees = this.employeesToSelected.map(record => {
            if (record.Id === recordId) {
                return { ...record, iconName: 'utility:check' };
            }
            return record;
        }); 
        this.employeesToSelected = updatedEmployees;
    }

    //Método para eliminar el registro seleccionado
    handleRowDelete(event){
        const recordId = event.target.getAttribute('data-id');
        const recordIndex = this.employeesToSelected.findIndex(record => record.Id === recordId);
    
        if (recordIndex !== -1) {
            this.employeesToSelected.splice(recordIndex, 1);
            this.employeesToSelected = [...this.employeesToSelected];
        }

        this.dispatchEmployeeList(this.employeesToSelected);
    }

get totalPages() {
    if (this.employeesToSelected && this.employeesToSelected.length > 0) {
        if(this.isIndividual === false){
            return Math.ceil(this.employeesToSelected.length / this.recordsPerPage);
        }else{
            return Math.ceil(this.employeesToSelected.length / this.recordsPerPageInd);
        }
    }else{
        return 1;
    }
}

get totalPagesResp() {
    if (this.gridData && this.gridData.length > 0) {
        return Math.ceil(this.gridData.length / this.recordsPerPageCentro);
    }else{
        return 1;
    }
}

//Mostrar los registros en las paginas Individual
get displayedRecords() {
    if (this.employeesToSelected && this.employeesToSelected.length > 0) {
        const startIndex = (this.currentPageInd - 1) * this.recordsPerPageInd;
        const endIndex = startIndex + this.recordsPerPageInd;
        return this.employeesToSelected.slice(startIndex, endIndex);
    }else{
        return [];
    }
}

//Mostrar los registros en las paginas Centro
get displayedRecordsResp(){
    if (this.gridData && this.gridData.length > 0) {
        const startIndex = (this.currentPageCentro - 1) * this.recordsPerPageCentro;
        const endIndex = startIndex + this.recordsPerPageCentro;
        return this.gridData.slice(startIndex, endIndex);
    }else{
        return [];
    }
}

//Mostrar los registros en las paginas Contacto 
get displayedRecordsResumen(){ 
    if (this.employeesToSelected && this.employeesToSelected.length > 0) {
        const startIndex = (this.currentPage - 1) * this.recordsPerPage;
        const endIndex = startIndex + this.recordsPerPage;
        return this.employeesToSelected.slice(startIndex, endIndex);
        
    }else{
        return [];
    }
}

get pagesResp() {
    const pagesArray = [];
    for (let i = 1; i <= this.totalPagesResp; i++) {
        pagesArray.push(i);
    }
    return pagesArray;
}

get pages() {
    const pagesArray = [];
    for (let i = 1; i <= this.totalPages; i++) {
        pagesArray.push(i);
    }
    return pagesArray;
}

handlePageChange(event) {
    if(this.isIndividual === false && this.isResponsabilidad === true &&  this.showThirdPage === true){
        this.currentPage = event.target.value;
    }if(this.isIndividual === false && this.isCentros === true && this.showSecondPage === true){
        this.currentPageCentro = event.target.value;
    }if(this.isIndividual === true){
        this.currentPageInd = event.target.value;
    }
}

//Muestra el popup de confirmación
handleDone(event){
    if(this.employeesToSelected.length > 0 || this.isResponsabilidad === true || this.isCentros === true){
        this.isModalOpen = true;
    }
}
closeModal() {
    this.isModalOpen = false;
}
submitDetails() {
    this.employeesToSelected = [];
    this.isModalOpen = false;
}

}