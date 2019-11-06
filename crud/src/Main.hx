/*
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import openfl.events.Event;
import feathers.data.ArrayCollection;
import feathers.controls.ListBox;
import feathers.layout.VerticalLayout;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.layout.HorizontalLayout;
import feathers.events.FeathersEvent;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.Application;

class Main extends Application {
	public function new() {
		super();
	}

	private var savedNames:ArrayCollection<NameVO>;

	private var filterForm:LayoutGroup;
	private var filterLabel:Label;
	private var filterInput:TextInput;

	private var middleContainer:LayoutGroup;
	private var namesListBox:ListBox;

	private var nameForm:LayoutGroup;
	private var nameLabel:Label;
	private var nameInput:TextInput;
	private var surnameLabel:Label;
	private var surnameInput:TextInput;

	private var buttonsContainer:LayoutGroup;
	private var createButton:Button;
	private var updateButton:Button;
	private var deleteButton:Button;

	override private function initialize():Void {
		super.initialize();

		// a list of saved names, with filtering
		this.savedNames = new ArrayCollection();
		this.savedNames.filterFunction = this.namesListBox_filterFunction;

		// the main layout consists of three sections, stacked vertically
		var layout = new VerticalLayout();
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 6.0;
		this.layout = layout;

		// the top section is a form containing a text input to filter items
		// in the list of names
		this.createFilterForm();

		// the middle section contains a list of names on the left and two
		// text inputs on the right to edit the first and last name
		this.createMiddleSection();

		// the bottom section contains some buttons to perform various actions
		// on the list of names
		this.createButtons();

		// let's get things started by setting up the initial enabled state
		// of various components
		this.refreshNameForm();
		this.refreshButtons();
	}

	private function createFilterForm():Void {
		var filterFormLayout = new HorizontalLayout();
		filterFormLayout.gap = 6.0;

		this.filterForm = new LayoutGroup();
		this.filterForm.layout = filterFormLayout;
		this.addChild(this.filterForm);

		this.filterLabel = new Label();
		this.filterLabel.text = "Filter surname:";
		this.filterForm.addChild(this.filterLabel);

		this.filterInput = new TextInput();
		this.filterInput.addEventListener(Event.CHANGE, filterInput_changeHandler);
		this.filterForm.addChild(this.filterInput);
	}

	private function createMiddleSection():Void {
		var middleLayout = new HorizontalLayout();
		middleLayout.gap = 6.0;
		this.middleContainer = new LayoutGroup();
		this.middleContainer.layout = middleLayout;
		this.addChild(this.middleContainer);

		this.namesListBox = new ListBox();
		this.namesListBox.dataProvider = savedNames;
		this.namesListBox.addEventListener(Event.CHANGE, namesListBox_changeHandler);
		this.middleContainer.addChild(this.namesListBox);

		this.createNameForm();
	}

	private function createNameForm():Void {
		var nameFormLayout = new VerticalLayout();
		nameFormLayout.gap = 6.0;
		nameFormLayout.horizontalAlign = RIGHT;
		this.nameForm = new LayoutGroup();
		this.nameForm.layout = nameFormLayout;
		this.middleContainer.addChild(this.nameForm);

		var nameFieldLayout = new HorizontalLayout();
		nameFieldLayout.gap = 6.0;
		var nameField = new LayoutGroup();
		nameField.layout = nameFieldLayout;
		this.nameForm.addChild(nameField);

		this.nameLabel = new Label();
		this.nameLabel.text = "Name:";
		nameField.addChild(this.nameLabel);

		this.nameInput = new TextInput();
		this.nameInput.addEventListener(Event.CHANGE, nameInput_changeHandler);
		nameField.addChild(this.nameInput);

		var sunameFieldLayout = new HorizontalLayout();
		sunameFieldLayout.gap = 6.0;
		var surnameField = new LayoutGroup();
		surnameField.layout = sunameFieldLayout;
		this.nameForm.addChild(surnameField);

		this.surnameLabel = new Label();
		this.surnameLabel.text = "Surname:";
		surnameField.addChild(this.surnameLabel);

		this.surnameInput = new TextInput();
		this.surnameInput.addEventListener(Event.CHANGE, surnameInput_changeHandler);
		surnameField.addChild(this.surnameInput);
	}

	private function createButtons():Void {
		var buttonsLayout = new HorizontalLayout();
		buttonsLayout.gap = 6.0;
		this.buttonsContainer = new LayoutGroup();
		this.buttonsContainer.layout = buttonsLayout;
		this.addChild(this.buttonsContainer);

		this.createButton = new Button();
		this.createButton.text = "Create";
		this.createButton.addEventListener(FeathersEvent.TRIGGERED, createButton_triggeredHandler);
		this.buttonsContainer.addChild(this.createButton);

		this.updateButton = new Button();
		this.updateButton.text = "Update";
		this.updateButton.addEventListener(FeathersEvent.TRIGGERED, updateButton_triggeredHandler);
		this.buttonsContainer.addChild(this.updateButton);

		this.deleteButton = new Button();
		this.deleteButton.text = "Delete";
		this.deleteButton.addEventListener(FeathersEvent.TRIGGERED, deleteButton_triggeredHandler);
		this.buttonsContainer.addChild(this.deleteButton);
	}

	private function refreshButtons():Void {
		var item = cast(this.namesListBox.selectedItem, NameVO);
		this.createButton.enabled = this.nameInput.text.length > 0 && this.surnameInput.text.length > 0;
		this.updateButton.enabled = item != null;
		this.deleteButton.enabled = item != null;
	}

	private function refreshNameForm():Void {
		var item = cast(this.namesListBox.selectedItem, NameVO);
		if (item == null) {
			this.nameInput.text = "";
			this.surnameInput.text = "";
		} else {
			this.nameInput.text = item.name;
			this.surnameInput.text = item.surname;
		}
	}

	private function namesListBox_filterFunction(item:NameVO):Bool {
		var filterText = this.filterInput.text.toLowerCase();
		if (filterText.length > 0) {
			return item.surname.toLowerCase().indexOf(filterText) == 0;
		}
		return true;
	}

	private function namesListBox_changeHandler(event:Event):Void {
		this.refreshNameForm();
		this.refreshButtons();
	}

	private function filterInput_changeHandler(event:Event):Void {
		this.namesListBox.dataProvider.refresh();
	}

	private function nameInput_changeHandler(event:Event):Void {
		this.refreshButtons();
	}

	private function surnameInput_changeHandler(event:Event):Void {
		this.refreshButtons();
	}

	private function createButton_triggeredHandler(event:FeathersEvent):Void {
		if (this.nameInput.text.length == 0 || this.surnameInput.text.length == 0) {
			return;
		}
		var newItem = new NameVO(this.nameInput.text, this.surnameInput.text);
		this.savedNames.add(newItem);
		this.namesListBox.selectedItem = newItem;
	}

	private function updateButton_triggeredHandler(event:FeathersEvent):Void {
		var newItem = new NameVO(this.nameInput.text, this.surnameInput.text);
		this.savedNames.set(this.namesListBox.selectedIndex, newItem);
	}

	private function deleteButton_triggeredHandler(event:FeathersEvent):Void {
		this.savedNames.removeAt(this.namesListBox.selectedIndex);
	}
}

class NameVO {
	public function new(name:String, surname:String) {
		this.name = name;
		this.surname = surname;
	}

	public var name:String;
	public var surname:String;

	// since we don't call toString() directly, dce might decide to remove it,
	// but we want to keep it to display the name correctly in the list box

	@:keep
	public function toString():String {
		return '${this.surname}, ${this.name}';
	}
}
