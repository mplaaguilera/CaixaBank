import { LightningElement, track } from 'lwc';

export default class MyComponent extends LightningElement {
  @track showMessage = false;

  toggleMessage() {
    this.showMessage = !this.showMessage;
  }
}