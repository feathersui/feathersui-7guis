/*
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import feathers.controls.LayoutGroup;
import feathers.controls.Application;
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.layout.HorizontalLayout;
import openfl.events.Event;

class Main extends Application {
	public function new() {
		super();
	}

	private var celcius:Int = 0;
	private var fahrenheit:Int = 32;

	private var celciusInput:TextInput;
	private var celciusLabel:Label;
	private var fahrenheitInput:TextInput;
	private var fahrenheitLabel:Label;

	override private function initialize():Void {
		super.initialize();

		var container = new LayoutGroup();
		var layout = new HorizontalLayout();
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 6.0;
		layout.verticalAlign = MIDDLE;
		container.layout = layout;
		this.addChild(container);

		this.celciusInput = new TextInput();
		this.celciusInput.restrict = "0-9";
		this.celciusInput.text = Std.string(this.celcius);
		this.celciusInput.addEventListener(Event.CHANGE, celciusInput_changeHandler);
		container.addChild(this.celciusInput);

		this.celciusLabel = new Label();
		this.celciusLabel.text = "Celcius = ";
		container.addChild(this.celciusLabel);

		this.fahrenheitInput = new TextInput();
		this.fahrenheitInput.restrict = "0-9";
		this.fahrenheitInput.text = Std.string(this.fahrenheit);
		this.fahrenheitInput.addEventListener(Event.CHANGE, fahrenheitInput_changeHandler);
		container.addChild(this.fahrenheitInput);

		this.fahrenheitLabel = new Label();
		this.fahrenheitLabel.text = "Fahrenheit";
		container.addChild(this.fahrenheitLabel);
	}

	private var _ignoreCelciusChange = false;
	private var _ignoreFarenheitChange = false;

	private function celciusInput_changeHandler(event:Event):Void {
		if (this._ignoreCelciusChange) {
			return;
		}

		this.celcius = Std.parseInt(this.celciusInput.text);
		this.fahrenheit = Std.int(this.celcius * (9 / 5) + 32);

		this._ignoreFarenheitChange = true;
		this.fahrenheitInput.text = Std.string(this.fahrenheit);
		this._ignoreFarenheitChange = false;
	}

	private function fahrenheitInput_changeHandler(event:Event):Void {
		if (this._ignoreFarenheitChange) {
			return;
		}

		this.fahrenheit = Std.parseInt(this.fahrenheitInput.text);
		this.celcius = Std.int((this.fahrenheit - 32) * (5 / 9));

		this._ignoreCelciusChange = true;
		this.celciusInput.text = Std.string(this.celcius);
		this._ignoreCelciusChange = false;
	}
}
