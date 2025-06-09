import { LightningElement, api } from 'lwc';
export default class CscProgressBarInFlow extends LightningElement {
    @api currentStep = 1;
    @api totalSteps = 4;

get blockList() {
    return Array.from({ length: this.totalSteps }, (_, i) => {
        const blockNum = i + 1;
        let blockClass = 'block';
        if (blockNum < this.currentStep) {
            blockClass += ' completed';
        } else if (blockNum === this.currentStep) {
            blockClass += ' active';
        }
        return { blockNum, blockClass };
    });
}
}