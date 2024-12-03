import LightningDatatable from 'lightning/datatable';
import picklistColumn from './cibe_picklistColumn.html';
import picklistStatic from './cibe_picklistStatic.html';

import picklistColumnVisto from './cibe_picklistColumnVisto.html';

export default class Cibe_CustomDatatable extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: picklistStatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'options']
        },

        picklistColumnVisto: {
            template: picklistStatic,
            editTemplate: picklistColumnVisto,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'options']
        }

    };

    renderedCallback() {
        let childs = this.template.querySelectorAll('tbody > tr');
        childs.forEach(tr => {
            tr.style.height = "35px";
        });


        if (LightningDatatable.prototype.renderedCallback) { // Run this check to bypass lwc jest error
            LightningDatatable.prototype.renderedCallback.call(this);
        }
    }
}