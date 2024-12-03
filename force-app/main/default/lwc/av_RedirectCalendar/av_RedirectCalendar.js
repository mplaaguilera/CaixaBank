import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ButtonCalendar from '@salesforce/label/c.AV_ButtonCalendar';

export default class Av_RedirectCalendar extends NavigationMixin(LightningElement) {

    // Expose the labels to use in the template.
    label = {
        ButtonCalendar,
    };

    // Navigate to Calendar Page
    navigateToCalendarPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Event',
                actionName: 'home'
            }
        });
    }


}