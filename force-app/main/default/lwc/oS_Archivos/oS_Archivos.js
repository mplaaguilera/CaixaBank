import { LightningElement, api, track, wire} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import recuperarArchivos from '@salesforce/apex/OS_Archivos_Controller.recuperarCampos';


const columns = [
    {label: 'Título', fieldName: 'urlTitulo', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'titulo' }, target: '_self', tooltip: { fieldName: 'titulo' }},
            cellAttributes: { iconName: { fieldName: 'iconoArchivo', iconPosition: 'left'},
            width: 600 }
    },
    { label: 'Remitente', fieldName: 'remitente', type: 'text', sortable: true, initialWidth: 190},
    {label: 'Propietario', fieldName: 'urlPropietario', type: 'url', sortable: true, initialWidth: 190,
            typeAttributes: {label: { fieldName: 'propietario' }, target: '_self', tooltip: { fieldName: 'propietario' }}},
    { label: 'Última modificación', fieldName: 'ultimaModificacion', type: 'text', sortable: true,initialWidth: 180},
    { label: 'Extensión', fieldName: 'ext', type: 'text', initialWidth: 100, actions: [{ label: 'Todos', checked: true, name:'all' }]},
    { label: 'Tamaño', fieldName: 'tamano', type: 'text', sortable: true, initialWidth: 92},
    {label: 'Asunto', fieldName: 'urlOrigen', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'origen' }, target: '_self', tooltip: { fieldName: 'origen' }}, 
            cellAttributes: { iconName: { fieldName: 'iconoOrigen', iconPosition: 'left', width:300}}
    }        
];


export default class OS_Archivos extends LightningElement {
    @api recordId;

    @track archivos = [];
    @track tieneArchivos =  false;
    @track cargarHeaderActions =  true;


    //filtro ext
    @track filter = ['all'];
    @track actionsExt = [];

    @track sorted_by = 'ultimaModificacion';
    @track sorted_direction = 'desc';
    @track wiredResult = [];


    @wire(recuperarArchivos, {
        caseId: '$recordId',
        campo: '$sorted_by',
        orden: '$sorted_direction',
        filtroExt: '$filter',
    })wiredArchivos(result) {
        this.wiredResult = result;
        if (result.data) {
            this.archivos = JSON.parse(JSON.stringify(result.data));
            this.error = '';
            if (this.archivos.length > 0) {
                this.tieneArchivos = true;
            }
            this.actionsExt= [];
            for(var i=0;i<this.archivos.length;i++){
                if (!this.actionsExt.includes(this.archivos[i].ext)) {
                    this.actionsExt.push(this.archivos[i].ext);
                }
            }
            this.actionsExt.sort();
            columns.forEach(columna => {
                if (columna.fieldName === 'ext') {                    
                    if (this.cargarHeaderActions) {
                        this.actionsExt.forEach(action => {
                            
                            columna.actions.push({ label: action, checked: this.filter.includes(action), name: action },);
                        });
                        this.cargarHeaderActions = false;
                    }
                    columna.actions.forEach(action => {
                        action.checked = this.filter.includes(action.name);
                    });
                    

                }
            });

            this.columns = JSON.parse(JSON.stringify(columns));

        } else if (result.error) {
            this.error = result.error;
            this.archivos = '';
        }
    }
    
    sortColumns( event ) {
        this.sorted_by = event.detail.fieldName;
        this.sorted_direction = event.detail.sortDirection;
        return refreshApex(this.wiredResult);
        
        
    }

    handleHeaderAction(event) {
        const actionName = event.detail.action.name;
        const colName = event.detail.columnDefinition.fieldName;
        const columnas = this.columns; 

        if (!this.filter.includes(actionName)) {
            this.filter.push(actionName);
        } else {
            const arrayFiltro = [];
            this.filter.forEach(filtro => {
                if (filtro != actionName) {
                arrayFiltro.push(filtro);
                }
            });
            this.filter = JSON.parse(JSON.stringify(arrayFiltro));
        }

        if (this.filter.length > 1 && this.filter.includes('all') && actionName == 'all') {
            const arrayFiltro = [];
            this.filter.forEach(filtro => {
                if (filtro == 'all') {
                arrayFiltro.push(filtro);
                }
            });
            this.filter = JSON.parse(JSON.stringify(arrayFiltro));
        } else if (this.filter.length > 1 && this.filter.includes('all') && actionName != 'all') {
            const arrayFiltro = [];
            this.filter.forEach(filtro => {
                if (filtro != 'all') {
                arrayFiltro.push(filtro);
                }
            });
            this.filter = JSON.parse(JSON.stringify(arrayFiltro));
        }else if (this.filter.length === 0) {
            this.filter.push('all');
            
        }

        columnas.map((col) => {                  
            if(col.fieldName === colName){
                var actions = col.actions;
                actions.forEach((action) => {
                    action.checked = this.filter.includes(action.name);
                });
            }
        });    
        
        

        //alert('FILTROS: '+ this.filter);
        this.filter = JSON.parse(JSON.stringify(this.filter));

        this.columns = JSON.parse(JSON.stringify(columnas));
        refreshApex(this.wiredResult);

    }
}