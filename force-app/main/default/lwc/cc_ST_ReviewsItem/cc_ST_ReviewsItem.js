import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createCase from '@salesforce/apex/CC_ST_ReviewsController.createCase';
import createSocialPost from '@salesforce/apex/CC_ST_ReviewsController.createSocialPost';
import buscarSocialPersona from '@salesforce/apex/CC_ST_ReviewsController.buscarSocialPersona';
import refrechItem from '@salesforce/apex/CC_ST_ReviewsController.refrechItem';
import LOGOS from '@salesforce/resourceUrl/CC_Iconos';
import SFDC_Images from '@salesforce/resourceUrl/CC_Iconos';


import { updateRecord } from 'lightning/uiRecordApi';

export default class cc_ST_ReviewsItem extends NavigationMixin(LightningElement) {
    @api msg;
    @api msgapex;
    @track pending = false;
    @track logo = LOGOS + '/android.png';
    Sfdcimage1 = SFDC_Images + 'twitter.png';


    connectedCallback() {
        if (this.msg.Source__c === 'Apple App Store') {
            this.logo = LOGOS + '/ios.png';
        } else {
            this.logo = LOGOS + '/android.png';
        }

    }
    
    get existeCaso() {
        var existe;
        if (this.msg.Case__c === undefined) {
            existe = false;
        } else {
            existe = true;
            if (this.msg.Case__r.Status==='Cerrado'){
                this.existeCasoAbierto=false;
            }else{
                this.existeCasoAbierto=true;
            }            
        }
        return (existe);
    }

    get dosestrellas(){
        var res=false;
        this.tresestrellas=false;
        this.cuatroestrellas=false;
        this.cincoestrellas=false;
        if (this.msg.Rating__c>1 ) {
            res=true;
            if (this.msg.Rating__c>2 ){
                this.tresestrellas=true;
                if (this.msg.Rating__c>3 ){
                    this.cuatroestrellas=true;
                    if (this.msg.Rating__c>4 ){
                        this.cincoestrellas=true;
                        
                    }   
                }   
            }
        }
        return (res);
    }

    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.msg.Case__r.Id,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    handleClick(event) {
        this.clickedButtonLabel = event.target.label;
    }
    
    refrescar(){
        refrechItem({
            ReviewId: this.msg.Id
        }).then(resultReview => {
            this.msg = resultReview;
            
        })
        .catch(error => {
            console.log(error);
        });

    }
    crearcaso(){
        this.pending=true;
        createCase({
            Title: this.msg.Title__c,
            Content: this.msg.Content__c,
            Origin: 'Comentarios Stores',
            ReviewId: this.msg.Id,
            Valoracion: this.msg.Rating__c,
            Store: this.msg.App_ID__c,
            salvar: true,
            Estado_Caso:'',
            Accion: ''
        }).then(result => {
            let record = {
                fields: {
                    Id: this.msg.Id,
                    Case__c: result.Id
                }
            };
            //Actualizar Revire con Id del Caso
            createSocialPost({
                Review_ID : this.msg.Id,
                CaseId : result.Id,
                Author_Name : this.msg.Author_Name__c,
                Content : this.msg.Content__c,
                Title : this.msg.Title__c,
                Source : this.msg.Source__c,
                MessageType : "Comment",
                IsOutbound : false,
                salvar : true           
            }).then(resultPost => {
                buscarSocialPersona({
                    Nombre : this.msg.Author_Name__c ,
                    Red : this.msg.Source__c,
                    Padre : resultPost.Id
                });

            });
            updateRecord(record)
                .then(() => {
                    refrechItem({
                        ReviewId: this.msg.Id
                    }).then(resultReview => {
                        this.pending=false;
                        this.msg = resultReview;
                        //Navegar al Caso creaado
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result.Id,
                                objectApiName: 'Case',
                                actionName: 'view'
                            }
                        });        
                    })
                    .catch(error => {
                        console.log(error);
                    });
                })
                .catch(error => {
                    console.log(error)
                });
        })
        .catch(error => {
            console.log(error);
        });
   
   
    }
}