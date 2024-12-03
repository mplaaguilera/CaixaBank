/**
 * @description       : Javascript del componente para la asignación de usuarios a grupos públicos
 * @author            : fzaragoza
 * @group             : 
 * @last modified on  : 11-05-2022
 * @last modified by  : fzaragoza
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   11-01-2022   fzaragoza   Initial Version
**/
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CBK_PublicGroupManage from '@salesforce/customPermission/CBK_PublicGroupManage'
import getPublicGroupMatrix from '@salesforce/apex/CBK_PublicGroupManageController.getPublicGroupMatrix'
import getPublicGroupList from '@salesforce/apex/CBK_PublicGroupManageController.getPublicGroupList'
import deleteUserGroupMembership from '@salesforce/apex/CBK_PublicGroupManageController.deleteUserGroupMembership'
import createUserGroupMembership from '@salesforce/apex/CBK_PublicGroupManageController.createUserGroupMembership'

import CBK_AdmPG_Clickto from '@salesforce/label/c.CBK_AdmPG_Clickto';
import CBK_AdmPG_Remove from '@salesforce/label/c.CBK_AdmPG_Remove';
import CBK_AdmPG_Add from '@salesforce/label/c.CBK_AdmPG_Add';
import CBK_AdmPG_UserToPG from '@salesforce/label/c.CBK_AdmPG_UserToPG';
import CBK_AdmPG_ClickAddUserToPG from '@salesforce/label/c.CBK_AdmPG_ClickAddUserToPG';
import CBK_AdmPG_ActionSuccess from '@salesforce/label/c.CBK_AdmPG_ActionSuccess';
import CBK_AdmPG_SuccessDisassociatedUser from '@salesforce/label/c.CBK_AdmPG_SuccessDisassociatedUser';
import CBK_AdmPG_OfPG from '@salesforce/label/c.CBK_AdmPG_OfPG';
import CBK_AdmPG_ActionFailure from '@salesforce/label/c.CBK_AdmPG_ActionFailure';
import CBK_AdmPG_UnableRemoveUser from '@salesforce/label/c.CBK_AdmPG_UnableRemoveUser';
import CBK_AdmPG_ToPG from '@salesforce/label/c.CBK_AdmPG_ToPG';
import CBK_AdmPG_ClickRemoveUserToPG from '@salesforce/label/c.CBK_AdmPG_ClickRemoveUserToPG';
import CBK_AdmPG_SuccessAssociatedUser from '@salesforce/label/c.CBK_AdmPG_SuccessAssociatedUser';
import CBK_AdmPG_FailureCreateUser from '@salesforce/label/c.CBK_AdmPG_FailureCreateUser';
import CBK_AdmPG_FilterTitle from '@salesforce/label/c.CBK_AdmPG_FilterTitle';
import CBK_AdmPG_FilterMessage from '@salesforce/label/c.CBK_AdmPG_FilterMessage';
import CBK_AdmPG_Name from '@salesforce/label/c.CBK_AdmPG_Name';
import CBK_AdmPG_User from '@salesforce/label/c.CBK_AdmPG_User';
import CBK_AdmPG_NoData from '@salesforce/label/c.CBK_AdmPG_NoData';
import CBK_AdmPG_NoAccess from '@salesforce/label/c.CBK_AdmPG_NoAccess';
import CBK_AdmPG_NoFilteredData from '@salesforce/label/c.CBK_AdmPG_NoFilteredData';

class PersonMatrix {
    constructor(id, elems) {
        this.id = id;
        this.Matrix = elems;
    }
}
class MatrixElement {
    constructor(elem) {
        this.checked = (elem.id !== undefined);
        this.variant = (elem.id ? "success" : "destructive");
        this.iconName = (elem.id ? "utility:adduser" : "utility:resource_absence");
	    this.cssClass =  (elem.id ? "existe slds-button_full-width" : "noExiste")
        this.fullnameUser = elem.fullnameUser;
        this.id = elem.id;
        this.idGroup = elem.idGroup;
        this.idUser = elem.idUser;
        this.key = elem.key;
        this.nameGroup = elem.nameGroup;
        this.title = CBK_AdmPG_Clickto + " " + (elem.id ? CBK_AdmPG_Remove : CBK_AdmPG_Add) + " " + CBK_AdmPG_UserToPG + " " + this.nameGroup;
    }
}

String.prototype.removeDiacritics = function() {
    var diacritics = [
        [/[\300-\306]/g, 'A'],
        [/[\340-\346]/g, 'a'],
        [/[\310-\313]/g, 'E'],
        [/[\350-\353]/g, 'e'],
        [/[\314-\317]/g, 'I'],
        [/[\354-\357]/g, 'i'],
        [/[\322-\330]/g, 'O'],
        [/[\362-\370]/g, 'o'],
        [/[\331-\334]/g, 'U'],
        [/[\371-\374]/g, 'u'],
        //[/[\307]/g, 'C'],
        //[/[\347]/g, 'c'],
    ];
    var s = this;
    for (var i = 0; i < diacritics.length; i++) {
        s = s.replace(diacritics[i][0], diacritics[i][1]);
    }
    return s;
}


export default class Cbk_MatrizGruposPublicos extends LightningElement {
    
    groups
    userGroupMatrix
    reordered
    splitted
    @api reorderedSplitted
    error;
    hierarchicalGroup = false
    datosCargados=false;
    isLoading = true;
    hayDatosFiltrados = false;
    
    labels = {
        CBK_AdmPG_Clickto:CBK_AdmPG_Clickto,
        CBK_AdmPG_Remove:CBK_AdmPG_Remove,
        CBK_AdmPG_Add:CBK_AdmPG_Add,
        CBK_AdmPG_UserToPG:CBK_AdmPG_UserToPG,
        CBK_AdmPG_ClickAddUserToPG:CBK_AdmPG_ClickAddUserToPG,
        CBK_AdmPG_ActionSuccess:CBK_AdmPG_ActionSuccess,
        CBK_AdmPG_SuccessDisassociatedUser:CBK_AdmPG_SuccessDisassociatedUser,
        CBK_AdmPG_OfPG:CBK_AdmPG_OfPG,
        CBK_AdmPG_ActionFailure:CBK_AdmPG_ActionFailure,
        CBK_AdmPG_UnableRemoveUser:CBK_AdmPG_UnableRemoveUser,
        CBK_AdmPG_ToPG:CBK_AdmPG_ToPG,
        CBK_AdmPG_ClickRemoveUserToPG:CBK_AdmPG_ClickRemoveUserToPG,
        CBK_AdmPG_SuccessAssociatedUser:CBK_AdmPG_SuccessAssociatedUser,
        CBK_AdmPG_FailureCreateUser:CBK_AdmPG_FailureCreateUser,
        CBK_AdmPG_FilterTitle:CBK_AdmPG_FilterTitle,
        CBK_AdmPG_FilterMessage:CBK_AdmPG_FilterMessage,
        CBK_AdmPG_Name:CBK_AdmPG_Name,
        CBK_AdmPG_User:CBK_AdmPG_User,
        CBK_AdmPG_NoData:CBK_AdmPG_NoData,
        CBK_AdmPG_NoAccess:CBK_AdmPG_NoAccess,
        CBK_AdmPG_NoFilteredData:CBK_AdmPG_NoFilteredData,
    };

    clickHandler(event){
        let checked = event.currentTarget.dataset.checked;
        let key= event.currentTarget.dataset.key;
        let idrec = event.currentTarget.dataset.idrec;
        let iduser = event.currentTarget.dataset.iduser;
        let idgroup = event.currentTarget.dataset.idgroup;
        let namegroup = event.currentTarget.dataset.namegroup;
        let fullnameuser = event.currentTarget.dataset.fullnameuser;
        if (checked==true||checked=="true"){
            deleteUserGroupMembership({ strID: idrec })
            .then((result) => {
                const searchIndex = this.reorderedSplitted.findIndex((person) => person.id==fullnameuser);
                const searchGMIndex = this.reorderedSplitted[searchIndex].Matrix.findIndex((gm) => gm.key==key);
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].id=undefined;
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].checked = false;
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].variant =  "destructive"
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].iconName = "utility:resource_absence";
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].cssClass =  "noExiste";
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].title = this.labels.CBK_AdmPG_ClickAddUserToPG + " " + namegroup;
                
                let valorQuerySelector = 'lightning-button[data-key="'+key+'"]';
                let boton = this.template.querySelector(valorQuerySelector);
                boton.dataset.checked = false;
                boton.dataset.idrec = undefined;
                boton.variant =  "destructive"
                boton.iconName = "utility:resource_absence";
                boton.cssClass = "noExiste";
                boton.title = this.labels.CBK_AdmPG_ClickAddUserToPG + " " + namegroup;

                const evt = new ShowToastEvent({
                    title: this.labels.CBK_AdmPG_ActionSuccess,
                    message: this.labels.CBK_AdmPG_SuccessDisassociatedUser + " " + fullnameuser + " " + this.labels.CBK_AdmPG_OfPG + " " + namegroup,
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            })
            .catch((error) => {
                this.error = error;
                const evt = new ShowToastEvent({
                    title: this.labels.CBK_AdmPG_ActionFailure,
                    message: this.labels.CBK_AdmPG_UnableRemoveUser + " " + fullnameuser + " " + this.labels.CBK_AdmPG_OfPG + " " + namegroup,
                    variant: 'error',
                    mode: 'dismissable'
                });
            });
        }
        else{
            createUserGroupMembership({ idGroup: idgroup, idUser: iduser })
            .then((result) => {
                const searchIndex = this.reorderedSplitted.findIndex((person) => person.id==fullnameuser);
                const searchGMIndex = this.reorderedSplitted[searchIndex].Matrix.findIndex((gm) => gm.key==key);
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].id=result;
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].checked = true;
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].variant =  "success"
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].iconName = "utility:adduser";
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].cssClass = "existe slds-button_full-width";
                this.reorderedSplitted[searchIndex].Matrix[searchGMIndex].title = this.labels.CBK_AdmPG_ClickRemoveUserToPG + " " + namegroup;

                let valorQuerySelector = 'lightning-button[data-key="'+key+'"]';
                let boton = this.template.querySelector(valorQuerySelector);
                boton.dataset.checked = true;
                boton.dataset.idrec = result;
                boton.variant =  "success"
                boton.iconName = "utility:adduser";
                boton.cssClass = "existe slds-button_full-width";
                boton.title = this.labels.CBK_AdmPG_ClickRemoveUserToPG + " " + namegroup;

                const evt = new ShowToastEvent({
                    title: this.labels.CBK_AdmPG_ActionSuccess,
                    message: this.labels.CBK_AdmPG_SuccessAssociatedUser + " " + fullnameuser + " " + this.labels.CBK_AdmPG_ToPG + " " + namegroup,
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            })
            .catch((error) => {
                this.error = error;
                const evt = new ShowToastEvent({
                    title: this.labels.CBK_AdmPG_ActionFailure,
                    message: this.labels.CBK_AdmPG_FailureCreateUser + " " + fullnameuser + " " + this.labels.CBK_AdmPG_ToPG + " " + namegroup,
                    variant: 'error',
                    mode: 'dismissable'
                });
            });
        }
    }

    filterHandler (event){
        let filterText = event.target.value;
        let filas = this.template.querySelectorAll('tr');
        let arrayFilas =Array.from(this.template.querySelectorAll('tr'));
        let tabla = this.template.querySelector('table');
        if (filterText != "") {
            this.hayDatosFiltrados = false;
            this.estiloTabla = "slds-table slds-table_cell-buffer slds-no-row-hover";
            this.template.querySelector('table').classList.remove('slds-table_bordered');
            arrayFilas.forEach(item=>{if(item.dataset.user != undefined){ item.style.display = (item.dataset.user.removeDiacritics().toUpperCase().includes(filterText.removeDiacritics().toUpperCase())? "":"none"); if(item.dataset.user.removeDiacritics().toUpperCase().includes(filterText.removeDiacritics().toUpperCase())){this.hayDatosFiltrados = true;this.estiloTabla = "slds-table slds-table_cell-buffer slds-no-row-hover slds-table_bordered";this.template.querySelector('table').classList.add('slds-table_bordered');}}});
        }
        else{
            arrayFilas.forEach(item=>item.style.display = "");
            this.hayDatosFiltrados = true;
            this.estiloTabla = "slds-table slds-table_cell-buffer slds-no-row-hover slds-table_bordered";
            this.template.querySelector('table').classList.add('slds-table_bordered');
        }
    }

    get usuarioAutorizado(){
        return CBK_PublicGroupManage;
    }

    connectedCallback() {
        if (CBK_PublicGroupManage){
            getPublicGroupList({ hierarchicalGroups: this.hierarchicalGroup })
                .then((result) => {
                    this.groups = result; 
                    this.error = undefined;
                    this.groups=[...this.groups].sort((a, b) => a.Name < b.Name ? -1 : a.Name > b.Name ? 1 : 0);
                })
                .catch((error) => {
                    this.error = error;
                    this.groups = undefined;
                });
            getPublicGroupMatrix()
                .then((result) => {
                    this.userGroupMatrix = result;
                    this.error = undefined;
                    this.userGroupMatrix = [...this.userGroupMatrix].sort((a, b) => a.fullnameUser < b.fullnameUser ? -1 : a.fullnameUser > b.fullnameUser ? 1 : 0); 
                    this.splitted = this.getGroupedBy([...this.userGroupMatrix],'fullnameUser');
                    let newArray = [];
                    this.splitted.forEach(elemento => {
                        newArray.push(elemento.sort((a, b) => a.nameGroup < b.nameGroup ? -1 : a.nameGroup > b.nameGroup ? 1 : 0));
                    });
                    this.reorderedSplitted = [...newArray];
                    let newArrayOjb = [];
                    let newArrayElem = [];
                    this.reorderedSplitted.forEach(elem => {
                        newArrayElem = [];
                        elem.forEach(el => {newArrayElem.push(new MatrixElement(el));})
                        newArrayOjb.push(new PersonMatrix(elem[0].fullnameUser,newArrayElem));
                    });
                    this.reorderedSplitted = [...newArrayOjb];   
                    this.reorderedSplitted = [... this.reorderedSplitted].sort((a, b) => a.id.localeCompare(b.id));
                    if(this.reorderedSplitted.length>0){
                        this.datosCargados=true;
                        this.hayDatosFiltrados = true;
                        this.estiloTabla = "slds-table slds-table_cell-buffer slds-no-row-hover slds-table_bordered";
                    }
                    this.isLoading = false;
                })
                .catch((error) => {
                    this.error = error;
                    this.reorderedSplitted = undefined;
                    this.datosCargados=false;
                    this.isLoading = false;
                });
        } else{
            this.isLoading = false;
        }         
    }

    getGroupedBy(elements, key) {
        let groups = {}, result = [];
        elements.forEach(function (a) {
            if (!(a[key] in groups)) {
                groups[a[key]] = [];
                result.push(groups[a[key]]);
            }
            groups[a[key]].push(a);
        });
        return result;
    } 

}