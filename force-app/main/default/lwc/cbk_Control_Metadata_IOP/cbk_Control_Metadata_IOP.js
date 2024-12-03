import { LightningElement, track, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/CBK_Control_Metadata.getIOPs';
import getPicklistValuesEnt from '@salesforce/apex/CBK_Control_Metadata.getEntornos';

import getobjetosIOP from '@salesforce/apex/CBK_Control_Metadata.getobjetosIOP';
import { refreshApex } from '@salesforce/apex';



export default class Example extends LightningElement {
		picklistValues;
		picklistValuesEnt;
		isLoaded = true;
		@track lstIOP='';
		@track Entorno ='Estrés/Migración';
		@track Tipo ='';
		@track wiredResult;
		
		@wire(getPicklistValues, {Entorno:'$Entorno'})
		wiredPicklist({ data,error }){

        if(data){
            console.log(' data ', data);
						this.picklistValues = data.values;
            this.error = undefined;
        }
        if(error){
            this.picklistValues = undefined;
            this.error = error;
        }
    }

		@wire(getPicklistValuesEnt, {})
		wiredPicklistEnt({ data,error }){
        if(data){            						
            console.log(' data ', data);
						this.picklistValuesEnt = data.values;
						this.Entorno='Estrés/Migración';
						this.error = undefined;
        }
        if(error){
            this.picklistValuesEnt = undefined;
            this.error = error;
        }
    }

		
    @track gridColumns = [
    {
        type: 'text',
        fieldName: 'Objeto',
        label: 'Objeto',
				wrapText: true		
    },
    {
        type: 'text',
        fieldName: 'UserStory',
        label: 'UserStory',
				wrapText: true				
    },
    {
        type: 'text',
        fieldName: 'Proyecto',
        label: 'Proyecto',
				wrapText: true				
    },
    {
        type: 'text',
        fieldName: 'Entorno',
        label: 'Entorno Actual',
				wrapText: true				
    },
		{
        type: 'text',
        fieldName: 'IOP',
        label: 'IOP'
    },
    {
        type: 'date',
        fieldName: 'LastCommitDate',
        label: 'LastCommitDate',
				wrapText: true,				
				typeAttributes: {
						day: 'numeric', 
						month: 'numeric', 
						year: 'numeric', 
						hour: '2-digit', 
						minute: '2-digit', 
						second: '2-digit', 
						hour12: false}
    },
    {
        type: 'date',
        fieldName: 'LastPromotionDate',
        label: 'LastPromotionDate',
				wrapText: true,				
				typeAttributes: {
						day: 'numeric', 
						month: 'numeric', 
						year: 'numeric', 
						hour: '2-digit', 
						minute: '2-digit', 
						second: '2-digit', 
						hour12: false}
		}];
    @track gridData;
    @track activeFilter = '--None--';
    @track allRows;

		
		
    @wire(getobjetosIOP,{
				IOP : '$lstIOP' ,Entorno:'$Entorno', Tipo: '$Tipo'
		})
		
    metaTreeData(result) {
    this.wiredResults = result;
				this.isLoaded=true;
				
				if ( result.data ) {

            var tempData = JSON.parse( JSON.stringify( result.data ) );
            /*var tempjson = JSON.parse( JSON.stringify( result.data ).split( 'UserStorys' ).join( '_children' ) );
            console.log( 'Temp JSON is ' + tempjson );*/
            for ( var i = 0; i < tempData.length; i++ ) {

                var cons = tempData[ i ][ 'UserStorys' ];

                if ( cons ) {
									console.log(cons);
                    tempData[ i ]._children = cons;
                    delete tempData[ i ].UserStorys;

                }

            }
            this.gridData = tempData;
            this.allRows = tempData;

        } else if ( result.error ) {
         
            if ( Array.isArray( result.error.body ) )
                console.log( 'Error is ' + result.error.body.map( e => e.message ).join( ', ' ) );
            else if ( typeof result.error.body.message === 'string' )
                console.log( 'Error is ' + result.error.body.message );

        }

    }

    handleHeaderAction( event ) {
				console.log("event: " + event);

        const actionName = event.detail.action.name;
        let columns = this.gridColumns;
        const activeFilter = this.activeFilter;
				console.log("actionName: " + actionName);
				
				if (actionName=='wrapText'){
						return false;
				}
   
   //     if ( actionName !== activeFilter ) {

   //         var actions = columns[ 2 ].actions;
   //         actions.forEach((action) => {
   //             action.checked = action.name === actionName;
   //         });
   //         columns[ 2 ].actions = actions;
   //         this.activeFilter = actionName;
   //         this.gridColumns = columns;
   //         this.updateRows();
    //    }
    }

    updateRows() {

        const rows = this.allRows;
        let filteredRows = rows;
        const activeFilter = this.activeFilter;

        if (activeFilter !== '--None--') {
            filteredRows = rows.filter(function (row) {
                return ( activeFilter === row.Active__c );
            });
        }

        this.gridData = filteredRows;   

    }
		handleValueChange(event){
        console.log(JSON.stringify(event.detail));
				this.lstIOP=JSON.stringify(event.detail);
				this.isLoaded=false;
				refreshApex(this.wiredResults);
				
    }
		
		handleValueChangeEnt(event) {
        this.selectedValueEnt = event.target.value;
				this.Entorno = event.target.value;
				this.isLoaded=false;
				refreshApex(this.wiredResults);
    }
		
    value = '';
    get options() {
        return [
            { label: 'Colisión por User Story', value: 'US' },
            { label: 'Colisión por Proyeto', value: 'Proyecto' },
        ];
    }
		
		handleValueChangeTipo(event) {
				this.Tipo=event.target.value;
				this.isLoaded=false;
				refreshApex(this.wiredResults);
		}
		
}