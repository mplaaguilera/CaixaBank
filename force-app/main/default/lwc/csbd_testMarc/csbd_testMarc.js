import {LightningElement} from 'lwc';

export default class ModalAnimation extends LightningElement {
    modalText = 'Contingut petit';

    isAnimating = false;

    handleSmall() {
    	this.updateContent('Contingut petit');
    }

    handleLarge() {
    	this.updateContent('Contingut gran<br>'.repeat(10));
    }

    handleMedium() {
    	this.updateContent('Contingut mitjà<br>'.repeat(5));
    }

    updateContent(newText) {
    	if (this.isAnimating) {return} //Evita canvis durant una animació en curs

    	const modal = this.refs.modal;
    	const content = this.refs.content;

    	//1️⃣ Clonar el contingut per mesurar la mida abans del canvi
    	const clone = content.cloneNode(true);
    	clone.style.visibility = 'hidden';
    	clone.style.position = 'absolute';
    	clone.innerHTML = `<p>${newText}</p>`;
    	modal.appendChild(clone);

    	//2️⃣ Mesurar la mida nova abans de canviar el contingut
    	const newHeight = clone.scrollHeight;
    	modal.removeChild(clone);

    	//3️⃣ Bloquejar la mida actual per evitar salts visuals
    	const prevHeight = modal.clientHeight;
    	modal.style.height = `${prevHeight}px`;
    	modal.style.willChange = 'height';

    	//🔹 **Forcem un reflow abans de començar l'animació** (Això fa que el canvi sigui suau)
    	modal.offsetHeight;

    	requestAnimationFrame(() => {
    		this.isAnimating = true; //Bloqueja altres canvis fins que acabi l'animació
    		modal.style.transition = 'height 0.3s ease-in-out';
    		modal.style.height = `${newHeight}px`;

    		//4️⃣ Un cop acaba l'animació, canviem el text i restablim height
    		modal.addEventListener(
    			'transitionend',
    			() => {
    				this.modalText = newText;

    				//🔹 **Forcem un segon reflow per fixar el nou contingut abans de fer el canvi definitiu**
    				modal.offsetHeight;

    				requestAnimationFrame(() => {
    					modal.style.transition = '';
    					modal.style.height = 'auto';
    					modal.style.willChange = 'auto';
    					this.isAnimating = false; //Permet nous canvis
    				});
    			},
    			{once: true}
    		);
    	});
    }
}