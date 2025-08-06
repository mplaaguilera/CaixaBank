import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";
import USER_ID from '@salesforce/user/Id';


//Labels
import title from '@salesforce/label/c.CIBE_HistorialOportunidades';
import titleEMP from '@salesforce/label/c.CIBE_HistorialOportunidadesEMP';
import fecha from '@salesforce/label/c.CIBE_Fecha';
import campo from '@salesforce/label/c.CIBE_Campo';
import user from '@salesforce/label/c.CIBE_Usuario';
import oldValue from '@salesforce/label/c.CIBE_ValorOriginal';
import newValue from '@salesforce/label/c.CIBE_ValorNuevo';

//import
import oppHistory 	    from '@salesforce/apex/CIBE_OppHistory_Controller.oppHistoryRole';
import getUserRole 	    from '@salesforce/apex/CIBE_CXBVisualizacionGC_Controller.getUserRole';


export default class cibe_OpportunityHistory extends NavigationMixin(LightningElement) {
    
    labels = {
        title,
        fecha,
        campo,
        user,
        oldValue,
        newValue,
        titleEMP
    };

    @track columns = [
        { label: this.labels.fecha,         fieldName: 'fecha',             type: "date",   typeAttributes:{    day: "2-digit", month: "2-digit", year: "numeric"}},
        { label: this.labels.campo,         fieldName: 'campo',             type: 'text'},
        { label: this.labels.user,          fieldName: 'user',              type: 'text' },
        { label: this.labels.oldValue,      fieldName: 'oldValue',          type: 'text'  },
        { label: this.labels.newValue,      fieldName: 'newValue',          type: 'text'}
    ];

    @track columnsEMP = [
        { label: this.labels.fecha,         fieldName: 'fecha',             type: "date",   typeAttributes:{    day: "2-digit", month: "2-digit", year: "numeric"}, initialWidth : 100},
        { label: this.labels.campo,         fieldName: 'campo',             type: 'text' },
        { label: this.labels.user,          fieldName: 'user',              type: 'text' },
        { label: this.labels.oldValue,      fieldName: 'oldValue',          type: 'text', cellAttributes: { alignment: 'left' } },
        { label: this.labels.newValue,      fieldName: 'newValue',          type: 'text', cellAttributes: { alignment: 'left' } }
    ];

    @api recordId;
    @track dataValues = [];

    @track pageNumber = 0;
    @track totalPages = 0;
    @track pageData = [];

    @track isShowSpinner = true;

    @track sortBy;
    @track sortDirection;
    @track defaultSort = 'asc';

    @track offSet = 0;
    @track isEMP = false;

    @track _wiredData;
    @wire(oppHistory, { recordId : '$recordId', offSet : 0 })
    getValues(wireResult) {
        const { data, error } = wireResult;
        this._wiredData = wireResult;
        if(data){
            if(this.isEMP){
                this.dataValues = data;
            }else{
                this.dataValues = this.sortData(data, 'fecha', 'desc');
                this.pageNumber = 0;
                this.totalPages = this.dataValues.length > 0 ? (Math.ceil(this.dataValues.length/10)-1) : 0;
                this.updatePage();
            }
          
            this.isShowSpinner = false;
        }else if(error) {
            this.isShowSpinner = false;
            console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
        }
    }

    viewMore() {
        this.offSet = (this.offSet <= 1990) ? (this.offSet + 10) : this.offSet;
        oppHistory({ recordId : this.recordId, offSet : this.offSet })
            .then((data) => {
                const dataConcat = this.dataValues;
                this.dataValues = dataConcat.concat(data);
            })
            .catch(error => {
                Console.log(error);
            })
    }

    handleSortData(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.dataValues = this.sortData(this.dataValues, event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(data, field, direction) {
        let fieldName = field;
        let dataToSort = [...data];
    
        let keyValue = (a) => {
            return a[fieldName];
        };
    
        let isReverse = direction === 'asc' ? 1: -1;
    
        dataToSort.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return dataToSort;
    }

    updatePage() {
        this.pageData = this.dataValues.slice(this.pageNumber*10, this.pageNumber*10+10);
    }
    
    previous() {
        this.pageNumber = Math.max(0, this.pageNumber - 1);
        this.updatePage();
    }
    
    first() {
        this.pageNumber = 0;
        this.updatePage();
    }
    
    next() {
        if((this.pageNumber+1)<=this.totalPages) {
            this.pageNumber = this.pageNumber + 1;
            this.updatePage();
        }
    }
    
    last() {
        this.pageNumber = this.pageNumber = this.totalPages;
        this.updatePage();
    }

    refresh(event) {
        this.isShowSpinner = true;
        refreshApex(this._wiredData)
            .finally(() => {
                this.isShowSpinner = false;
            });
    }

    get getPageNumber() {
        return (this.pageNumber+1);
    }

    get getTotalPageNumber() {
        return (this.totalPages+1);
    }

    @wire(getUserRole,{userId:USER_ID})
	wiredUser({error,data}){
        if (data) {
            this.userRoleName = data;
            if(this.userRoleName == 'EMP'){
                this.isEMP = true;
            }else{
                this.isEMP = false;
            }
        } else if (error) {
            Console.error(error);
        }
	}

}