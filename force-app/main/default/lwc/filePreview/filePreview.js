import { LightningElement,api } from 'lwc';

export default class FilePreview extends LightningElement {
  @api fileId;
  @api heightInRem;
  @api message;
  getDocBaseUrl = () => {
    return `https://${
      window.location.hostname.split(".")[0]
    }.file.force.com`;
  };
  getContentDocUrl = (fileId) => {
    return `/lightning/r/ContentDocument/${fileId}/view`;
  };
  getDownloadUrl = (fileId) => {
    return `${getDocBaseUrl()}/sfc/servlet.shepherd/version/download/${fileId}`;
  };
    get url() {
    return `${this.getDocBaseUrl()}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=${this.fileId}&operationContext=CHATTER&page=0`;
  }

  fallback(event) {
    if (event.target.src != NOPREVIEWIMGURL) {
      event.target.src = NOPREVIEWIMGURL;
      this.template.querySelector("img").style.width = "200px";
      this.template.querySelector("img").style.height = "100px";
    }
  }
}