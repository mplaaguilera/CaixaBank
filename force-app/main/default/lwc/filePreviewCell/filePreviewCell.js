import { LightningElement,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class FilePreviewCell extends NavigationMixin(LightningElement) {
  showPreview = false;
  @api label = "";
  @api versionId = "";
  @api fileId = "";
  navigateToFile(event) {
    event.preventDefault();
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        recordIds: this.fileId,
        selectedRecordId: this.fileId
      }
    });
  }
  get message() {
    return 'No File found. Please specify correct File ID.';
  }
  get fileOrVersionId() {
    return this.versionId || this.fileId;
  }

  handleMouseOver() {
    this.showPreview = true;
  }

  handleMouseOut() {
    this.showPreview = false;
  }
}