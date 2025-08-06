import { LightningElement, api } from "lwc";
import cargarComentarios from "@salesforce/apex/SAC_LCMP_ComentariosSupervisor.cargarComentarios";

export default class SAC_ComentariosDeElevacionSupervisor extends LightningElement {
  @api recordId;
  @api mensaje;
  @api mostrarMensaje;
  @api mostrarComentarios;
  @api comentarios;
  @api mostrarComprobar = false;
  @api mostrarOcultar = false;

  connectedCallback() {
    this.mostrarComprobar = true;
  }

  comprobarClick() {
    cargarComentarios({ caseId: this.recordId })
      .then((result) => {
        this.mostrarComentarios = true;
        this.mostrarMensaje = false;
        this.comentarios = result;
        this.mostrarOcultar = true;
        this.mostrarComprobar = false;
      })
      .catch((error) => {
        this.mostrarMensaje = true;
        this.mostrarComentarios = false;
        this.mensaje = error.body.message;
        this.mostrarOcultar = true;
        this.mostrarComprobar = false;
      });
  }

  ocultarClick() {
    this.mostrarComprobar = true;
    this.mostrarComentarios = false;
    this.mostrarOcultar = false;
    this.mostrarMensaje = false;
  }
}