import { LightningElement } from 'lwc';
export default class CaseToTranscriptLinkCmp extends LightningElement {
     isModalOpen = false;

    // Sample data to populate the table
    tableData = [
        { id: 1, name: 'John Doe', age: 30, city: 'New York' },
        { id: 2, name: 'Jane Smith', age: 25, city: 'Los Angeles' },
        { id: 3, name: 'Emily Davis', age: 35, city: 'Chicago' }
    ];

    // Handle click on the "Show Table" button
    handleClick() {
        this.isModalOpen = true;
    }

    // Close the modal
    closeModal() {
        this.isModalOpen = false;
    }

    // Handle the "Print Row" button click
    handlePrintRow(event) {
        const rowId = event.target.dataset.id;
        const row = this.tableData.find(r => r.id == rowId);
        console.log('Row data:', row); // Prints the row data to the console
    }
}