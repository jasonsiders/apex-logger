import { api } from "lwc";
import {
	CustomPropertyEditor,
	DataTypes,
	Error,
	TypeChangedEvent,
	ValueChangedEvent,
	ValueDeletedEvent
} from "c/customPropertyEditor";

const BODY_VAR_NAME = "body";
const LEVEL_VAR_NAME = "level";
// This is the absolute max for all long-text area fields in SFDC
const MAX_LENGTH = 131072;

const LEVEL_OPTIONS = [
	{ label: "FINEST", value: "FINEST" },
	{ label: "FINER", value: "FINER" },
	{ label: "FINE", value: "FINE" },
	{ label: "INFO", value: "INFO" },
	{ label: "DEBUG", value: "DEBUG" },
	{ label: "WARN", value: "WARN" },
	{ label: "ERROR", value: "ERROR" }
];

export default class CpeLogger extends CustomPropertyEditor {
	levelOptions = LEVEL_OPTIONS;
	levelVariable = LEVEL_VAR_NAME;
	bodyVariable = BODY_VAR_NAME;
	maxLength = MAX_LENGTH;

	@api validate() {
		let errors = [];
		const innerComponents = ["c-cpe-combobox", "lightning-textarea"];
		innerComponents?.forEach((componentName) => {
			const component = this.template.querySelector(componentName);
			if (!component?.reportValidity()) {
				errors.push(new Error(component?.label, `${component?.label} is invalid`));
			}
		});
		return errors;
	}

	get messageValue() {
		return this.getInvocableVariable(BODY_VAR_NAME)?.value;
	}

	handleChange(event) {
		const elementName = event?.target?.name || event?.detail?.name;
		const newValue = event?.detail?.newValue || event?.detail?.value;
		const valueChangedEvent = new ValueChangedEvent(elementName, newValue, DataTypes.STRING);
		this.dispatchEvent(valueChangedEvent);
	}
}
