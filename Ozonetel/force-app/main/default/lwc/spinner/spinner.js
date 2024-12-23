/**
 * **********************************************************************************************************
 * Lightning Web Component   :   spinner
 * Includes                  :   spinner.html, spinner.js, spinner.js-meta.xml files.
 * ***********************************************************************************************************
 * @author       VR Sudarshan 
 * @created      2022-Oct-13
 * @description  This is a genreic spinner component which can be consumed accross all LWC Components.
 */


import { LightningElement, api } from 'lwc';

export default class Spinner extends LightningElement {
    @api isLoading=false;
}